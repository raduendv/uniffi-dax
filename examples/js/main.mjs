import {
  add,
  loadFromEnv,
  sdkConfigRegion,
} from "../../target/js/index.js";

const result = add(2n, 3n);
console.log(`2 + 3 = ${result}`);

const config = await loadFromEnv();
try {
  console.log(`region: ${sdkConfigRegion(config) ?? "<not set>"}`);
} finally {
  config.dispose();
}
