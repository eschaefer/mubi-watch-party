// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Json_Decode$JsonCombinators from "@glennsl/rescript-json-combinators/src/Json_Decode.bs.js";

var OnHistoryStateUpdated = {};

var WebNavigation = {
  OnHistoryStateUpdated: OnHistoryStateUpdated
};

var Tabs = {};

var OnChanged = {};

var initialStorageItem = Json_Decode$JsonCombinators.object(function (field) {
      return {
              localHostTime: field.optional("localHostTime", Json_Decode$JsonCombinators.string),
              localHostId: field.optional("localHostId", Json_Decode$JsonCombinators.string),
              remoteHostId: field.optional("remoteHostId", Json_Decode$JsonCombinators.string),
              connectedPeers: field.optional("connectedPeers", Json_Decode$JsonCombinators.string),
              playerState: field.optional("playerState", Json_Decode$JsonCombinators.string)
            };
    });

var storageNewResult = Json_Decode$JsonCombinators.object(function (field) {
      return {
              newValue: field.required("newValue", Json_Decode$JsonCombinators.string)
            };
    });

var storageChange = Json_Decode$JsonCombinators.object(function (field) {
      return {
              changedLocalHostTime: field.optional("localHostTime", storageNewResult),
              changedLocalHostId: field.optional("localHostId", storageNewResult),
              changedRemoteHostId: field.optional("remoteHostId", storageNewResult),
              changedConnectedPeers: field.optional("connectedPeers", storageNewResult),
              changedPlayerState: field.optional("playerState", storageNewResult)
            };
    });

var Decode = {
  initialStorageItem: initialStorageItem,
  storageNewResult: storageNewResult,
  storageChange: storageChange
};

var $$Storage = {
  OnChanged: OnChanged,
  Decode: Decode
};

export {
  WebNavigation ,
  Tabs ,
  $$Storage ,
}
/* initialStorageItem Not a pure module */
