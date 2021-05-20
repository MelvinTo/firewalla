/*    Copyright 2021 Firewalla Inc.
 *
 *    This program is free software: you can redistribute it and/or  modify
 *    it under the terms of the GNU Affero General Public License, version 3,
 *    as published by the Free Software Foundation.
 *
 *    This program is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU Affero General Public License for more details.
 *
 *    You should have received a copy of the GNU Affero General Public License
 *    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
'use strict';

const log = require('../net2/logger.js')(__filename)

const Sensor = require('./Sensor.js').Sensor

const extensionManager = require('./ExtensionManager.js')

const Promise = require('bluebird');

const fireRouter = require('../net2/FireRouter.js')

const delay = require('../util/util.js').delay;

const flowTool = require('../net2/FlowTool');

const fs = require('fs');
Promise.promisifyAll(fs);

const exec = require('child-process-promise').exec;

const sysManager = require('../net2/SysManager.js');

const _ = require('lodash');


class LiveStatsPlugin extends Sensor {

  registerStreaming(streaming) {
    const id = streaming.id;
    if (! (id in this.streamingCache)) {
      this.streamingCache[id] = {}
    }
  }

  lastStreamingTS(id) {
    return this.streamingCache[id] && this.streamingCache[id].ts;
  }

  updateStreamingTS(id, ts) {
    this.streamingCache[id].ts = ts;
  }

  cleanupStreaming() {
    for(const id in this.streamingCache) {
      const cache = this.streamingCache[id];
      if(cache.ts < Math.floor(new Date() / 1000) - 1800) {
        delete this.streamingCache[id];
      }
    }
    if(_.isEmpty(this.streamingCache)) {
      this.clearRecordJobTimer();
    }
  }

  async recordJob() {
    if (!_.isEmpty(streamingCache)) {
      const intfStats = [];
      const interval = 500; // 500ms
      const intfs = fireRouter.getLogicIntfNames();
      const promises = intfs.map( async (intf) => {
        const rate = await this.getRate(intf);
        rate.tx = Math.floor(rate.tx * 1000 / interval); // in seconds
        rate.rx = Math.floor(rate.rx * 1000 / interval); // in seconds
        intfStats.push(rate);
      });
      promises.push(delay(interval)); // at least wait for interval seconds
      await Promise.all(promises);
      this.lastIntfStats = intfStats;
      this.lastIntfStatsTimestamp = Math.floor(Date.now() / 1);
    }
  }

  clearRecordJobTimer() {
    if(this.jobTimer) {
      clearInterval(this.jobTimer);
      this.jobTimer = null;
    }
  }
  
  launchRecordJobTimer() {
    // clear before launch
    this.clearRecordJobTimer();

    this.jobTimer = setInterval(() => {
      this.recordJob();
    }, 50); // 50 ms
  }

  lastFlowTS(flows) { // flows must be in asc order
    if (flows.length == 0) {
      return 0;
    }
    return flows[flows.length-1].ts;
  }

  async apiRun() {
    this.activeConnCount = await this.getActiveConnections();
    this.streamingCache = {};

    setInterval(() => {
      this.cleanupStreaming();
    }, 600 * 1000); // cleanup every 10 mins

    this.timer = setInterval(async () => {
      this.activeConnCount = await this.getActiveConnections();      
    }, 300 * 1000); // every 5 mins;

    extensionManager.onGet("liveStats", async (msg, data) => {
      const streaming = data.streaming;
      const id = streaming.id;
      this.registerStreaming(streaming);
      this.launchRecordJobTimer();

      const containFlows = data.flows || true;
      const containIntfStats = data.intfs || true;

      const now = Math.floor(new Date() / 1000);
      
      let flows = [];

      if (containFlows) {
        let lastTS = this.lastStreamingTS(id);
        if(!lastTS) {
          const prevFlows = (await this.getPreviousFlows()).reverse();
          flows.push.apply(flows, prevFlows);
          lastTS = this.lastFlowTS(prevFlows) && now;
        } else {
          if (lastTS < now - 60) {
            lastTS = now - 60; // self protection, ignore very old ts
          }
        }

        const newFlows = await this.getFlows(lastTS);
        flows.push.apply(flows, newFlows);

        let newFlowTS = this.lastFlowTS(newFlows) || lastTS;
        this.updateStreamingTS(id, newFlowTS);
      }

      let intfStats = [];
      
      if(containIntfStats) {
        if(this.lastIntfStats && this.lastIntfStatsTimestamp > Math.floor(new Date() / 1) - 5000) { // within 5 seconds, consider as valid
        } else {
          // recalculate
          await this.recordJob();
        }

        intfStats = this.lastIntfStats;
      }

      return {ts: now, flows, intfStats, activeConn: this.activeConnCount};
    });
  }

  async getIntfStats(intf) {
    const rx = await fs.readFileAsync(`/sys/class/net/${intf}/statistics/rx_bytes`, 'utf8').catch(() => 0);
    const tx = await fs.readFileAsync(`/sys/class/net/${intf}/statistics/tx_bytes`, 'utf8').catch(() => 0);
    return {rx, tx};
  }

  // return number of bytes transferred during the interval
  async getRate(intf, interval = 1000) {
    const s1 = await this.getIntfStats(intf);
    await delay(interval);
    const s2 = await this.getIntfStats(intf);
    return {
      name: intf,
      rx: s2.rx > s1.rx ? s2.rx - s1.rx : 0,
      tx: s2.tx > s1.tx ? s2.tx - s1.tx : 0
    };
  }

  async getPreviousFlows() {
    const now = Math.floor(new Date() / 1000);
    const flows = await flowTool.prepareRecentFlows({}, {
      ts: now,
      ets: now-60, // one minute
      count: 100,
      auditDNSSuccess: true,
      audit: true
    });
    return flows;
  }

  async getFlows(ts) {
    const now = Math.floor(new Date() / 1000);
    const flows = await flowTool.prepareRecentFlows({}, {
      ts,
      ets: now-2,
      count: 100,
      asc: true,
      auditDNSSuccess: true,
      audit: true
    });
    return flows;
  }

  buildActiveConnGrepString() {
    const wanIPs = sysManager.myWanIps().v4;
    let str = "grep -v TIME_WAIT | fgrep -v '127.0.0.1' ";
    for(const ip of wanIPs) {
      str += `| egrep -v '=${ip}.*=${ip}'`;
    }
    return str;
  }

  async getActiveConnections() {
    // TBD, to be improved on the data accuracy and data parsing
    try {
      const ipv4Cmd = `sudo conntrack -o extended -L | ${this.buildActiveConnGrepString()} | wc -l`;
      log.debug(ipv4Cmd);
      const ipv4Count = await exec(ipv4Cmd);
      try {
        await exec("sudo modinfo nf_conntrack_ipv6"); // check if ipv6 kernel module is loaded, if not loaded, do not use the ipv6 data, which is not correct
        const ipv6Cmd = "sudo conntrack -L -f ipv6 2>/dev/null | fgrep -v =::1 | wc -l";
        const ipv6Count = await exec(ipv6Cmd);
        return Number(ipv4Count.stdout) + Number(ipv6Count.stdout);
      } catch(err) {
        log.debug("IPv6 conntrack kernel module not available");
        return Number(ipv4Count.stdout);
      }
    } catch(err) {
      log.error("Failed to get active connections, err:", err);
      return 0;
    }
  }
}

module.exports = LiveStatsPlugin;
