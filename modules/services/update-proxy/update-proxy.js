const nunjucks = require('nunjucks');
const {Etcd3} = require('etcd3');
const client = new Etcd3(options={hosts: get_etcd_addr()} );
const fs = require('fs');
const { exec } = require('child_process');
const sleep = ms => { return new Promise(resolve => setTimeout(resolve,ms)) }
var nunjucks_cfg = nunjucks.configure(require('path').dirname(process.env.CFG_TEMPLATE),{autoescape: true});
var nunjucks_idx = nunjucks.configure(require('path').dirname(process.env.INDEX_TEMPLATE),{autoescape: true});
var nunjucks_idx2 = nunjucks.configure(require('path').dirname(process.env.INDEX2_TEMPLATE),{autoescape: true});


function get_etcd_addr() {
  if (!process.env.ETCD_HOST) {
    console.log('ETCD_HOST not defined');
    process.exit(1);
    }
  host = process.env.ETCD_HOST;

  if (host.indexOf(":") < 0) {
    host = host + ":2379";
    }
  return host;
  }

function hasChanged(d1,d2) {
  console.log(`oldkeys: ${Object.keys(d1).length}, keys: ${Object.keys(d2).length}`);
  if (Object.keys(d1).length != Object.keys(d2).length) { return true; }
  for (const [key,value] of Object.entries(d1)) {
    if (d1[key] !== d2[key]) { return true; }
  }
  return false;
  }

main = async() => {
  var oldKeys = {};
  while(true) {
   await sleep(10000);
   keys = await client.getAll().prefix('/services');
   if (hasChanged(keys,oldKeys)) {
     services = {};
     for (const [key, value] of Object.entries(keys)) {
       var parts = key.split("/");
       if (parts.length == 5) {
         if (!(parts[2] in services)) {
           services[parts[2]] = {};
         }
         services[parts[2]][parts[4]] = value;
       } else if (parts.length == 4) {
         if (!(parts[2] in services)) {
           services[parts[2]] = {};
         }
         services[parts[2]][parts[3]] = value;
      }
         
     }

     console.log(services);
     cfg_template = process.env.CFG_TEMPLATE;
     index_template = process.env.INDEX_TEMPLATE;
     index2_template = process.env.INDEX2_TEMPLATE;
     index = nunjucks_idx.render(require('path').basename(index_template),{services: services});
     fs.writeFileSync('/var/lib/haproxy/index.html',index);
     index2 = nunjucks_idx.render(require('path').basename(index2_template),{services: services});
     fs.writeFileSync('/var/lib/haproxy/index2.html',index2);
     config =  nunjucks_cfg.render(require('path').basename(cfg_template),{services: services});
     fs.writeFileSync('/var/lib/haproxy/haproxy.cfg',config);
      // console.log('restarting haproxy with: ');
     //console.log('haproxy -f /var/lib/haproxy/haproxy.cfg -p /var/run/haproxy.pid -sf $(cat /var/run/haproxy.pid)');
     //exec('haproxy -f /var/lib/haproxy/haproxy.cfg -p /var/run/haproxy.pid -sf $(cat /var/run/haproxy.pid)', (error,stdout,stderr) => {
     //console.log(`error: ${error}\n\nstdout: ${stdout}\n\nstderr: ${stderr}`) });
     oldKeys = keys;
     } else {
     console.log('services unchanged');
     }
  }
 }


main()
