import { logger } from "@bzznbyd/lib";
import { log } from "@bzznbyd/decorator";

import Config from "@src/Config";
import GqlFunction from "@src/component/GqlFunction";

import Garden from "./index.js";

class Resolver {
  static async Resolvers_getMyName(){
    return await new Garden().getGardenName(Config.get()); 
  }
};

export const resolvers = {
  Query: {
    getMyName: Resolver.Resolvers_getMyName,
  }
};