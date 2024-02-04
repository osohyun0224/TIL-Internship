import { logger, util, error } from "@bzznbyd/lib";
import { RuntimeMode } from "@bzznbyd/lib/consts";
import { log } from "@bzznbyd/decorator";
import { getGlobalConnector } from "@connector";
import Singleton from "@src/component/Singleton";
import { Cache } from "@src/component/Cache";

import GqlFunction from "@src/component/GqlFunction";
import EntityLoader from "@src/component/EntityLoader";

const DefaultPostCacheTimeoutSeconds = 3600 * 24;
const PostCacheTimeoutSeconds = process.env.PostCacheTimeoutSeconds || DefaultPostCacheTimeoutSeconds;

export default class Garden {
  constructor(config){
    this.config = config;
  }
  getGardenName(config) {
    return config.mode;
  }
}