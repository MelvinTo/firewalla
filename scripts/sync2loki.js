'use strict';

const log = require('../net2/logger.js')(__filename);

const flowTool = require('../net2/FlowTool');
const HM = require('../net2/HostManager');
const hostManager = new HM();
const idm = require('../net2/IdentityManager');
const { delay } = require('../util/util');
const rclient = require('../util/redis_manager.js').getRedisClient();

const rp = require('request-promise').defaults({ timeout: 30000 });

const fs = require('fs');
const fsp = fs.promises;

const lokiURL = "http://192.168.1.124:3100/loki/api/v1/push";
const lokiIterKey = "loki:offset"; // ts example: 1625555773.612 (in seconds)

const jobName = "netflows";

const lokiLabels = [
  "ltype",
  "type",
  "fd",
  "intf",
  "device",
  "protocol",
  "deviceIP",
  "devicePort",
  "ip",
  "country",
  "host",
  "port",
  "domain",
  "app",
  "category"
];  

async function getFlows(options) {
  
  let count = 0;
  let buffer = [];
  let flows = [];
  do {
    flows = await flowTool.prepareRecentFlows({}, options);
    log.info(`Fetched ${flows.length} flows for ts: ${new Date(options.ts*1000)}`);
    for (const flow of flows) {
      buffer.push(flow);
      if (buffer.length > 1000) {
        await send2Loki(buffer);
	count += buffer.length;
        buffer = [];
      }
    }
    options.ts = flows.length ? flows[flows.length - 1].ts : options.ts;
    await updateCurrentOffset(options.ts);
    
  } while(flows.length);

  log.info("Total processed count:", count);
}

async function getCurrentOffset() {
  const curTS = await rclient.getAsync(lokiIterKey);
  const minTS = new Date() / 1000 - 86400;
  
  if(curTS) {
    const n = Number(curTS);
    if(!Number.isNaN(n)) {
      if(minTS > n) {
        return minTS;
      }
      return n;
    }
  }

  return minTS;
}

async function updateCurrentOffset(ts) {
	log.info("Updating ts offset to", new Date(ts * 1000));
  await rclient.setAsync(lokiIterKey, ts);
  return;
}

async function send2Loki(flows) {
  const streams = flows.map((flow) => flow2stream(flow));

  const options = {
    uri: lokiURL,
    family: 4,
    method: 'POST',
    json: {streams}
  };

  await rp(options).catch((err) => {
    log.error("failed to post streams, err:", err);
  });
}

function flow2stream(flow) {  
  const ts = Math.floor(flow.ts * 1000);

  const stream = {job: jobName};

  for(const l of lokiLabels) {
    if(flow[l]) {
      stream[l] = `${flow[l]}`;
      delete flow[l];
    }
  }

  const message = JSON.stringify(flow);  
  
  return {stream: stream, values: [[ `${ts}000000`, message]]};
}

(async () => {
  log.info('Warming up...');
  await delay(10000)

  log.info("Loading hosts...");
  await hostManager.getHostsAsync();

  const startTS = await getCurrentOffset();
  log.info("Processing flows since:", new Date(startTS * 1000));
  
  const start = Math.floor(new Date() / 1000);
  await getFlows({
    audit:true,
    macs: idm.getAllIdentitiesGUID(),
    ts: startTS,
    asc:true
  });
  const end = Math.floor(new Date() / 1000);
  log.info(`It took ${end - start} seconds to finish`);
  
  process.exit(0);
})().catch( err => {
  console.log(err.message, err.stack);
  process.exit(1);
});
