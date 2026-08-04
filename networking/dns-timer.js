import { lookup } from "node:dns/promises";
import http from "node:http";
import { performance } from "node:perf_hooks";


const timeRequest = async (hostname = "example.com", path = "/") => {
    const dnsStart = performance.now();
    const {address} = await lookup(hostname);
    const dnsEnd = performance.now();
    
    const requestStart = performance.now();

    const req = http.request({
        host: address, path, headers: { Host: hostname }, port: 80
    }, (res) => {
       let firstByteTime = null;
       let data = "";

         res.on("data", (chunk) => {
            if (firstByteTime === null) {
                firstByteTime = performance.now();
            }
            data += chunk;
        });

        res.on("end", () => {
            const requestEnd = performance.now();
            console.log(`DNS Lookup Time: ${(dnsEnd - dnsStart).toFixed(2)} ms`);
            console.log(`Time to First Byte: ${(firstByteTime - requestStart).toFixed(2)} ms`);
            console.log(`Total transfer time: ${(requestEnd - requestStart).toFixed(2)} ms`);
            console.log(`Status: ${res.statusCode}, Bytes received: ${data.length}`);
         })
    });

    req.on("error", (err) => {
        console.error(`Request error: ${err.message}`);
    });
    req.end();
}

timeRequest("paulserban.eu", "/");