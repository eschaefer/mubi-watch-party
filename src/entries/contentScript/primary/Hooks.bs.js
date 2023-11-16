// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Curry from "rescript/lib/es6/curry.js";
import * as Utils from "../../shared/Utils.bs.js";
import * as React from "react";
import * as Peerjs from "peerjs";
import * as Browser from "./Browser.bs.js";
import * as Belt_Int from "rescript/lib/es6/belt_Int.js";
import * as Throttle from "rescript-throttle/src/Throttle.bs.js";
import * as Belt_List from "rescript/lib/es6/belt_List.js";
import * as Belt_Float from "rescript/lib/es6/belt_Float.js";
import * as Pervasives from "rescript/lib/es6/pervasives.js";
import * as Caml_option from "rescript/lib/es6/caml_option.js";
import * as Js_null_undefined from "rescript/lib/es6/js_null_undefined.js";
import * as Json$JsonCombinators from "@glennsl/rescript-json-combinators/src/Json.bs.js";
import * as WebextensionPolyfill from "webextension-polyfill";

var initialState = {
  localHostId: undefined,
  remoteHostId: undefined,
  localHostTime: 0.0,
  connectedPeers: 0,
  playerState: /* Unknown */2
};

function storageReducer(state, action) {
  if (typeof action === "number") {
    return initialState;
  }
  switch (action.TAG | 0) {
    case /* LocalHostTime */0 :
        return {
                localHostId: state.localHostId,
                remoteHostId: state.remoteHostId,
                localHostTime: action._0,
                connectedPeers: state.connectedPeers,
                playerState: state.playerState
              };
    case /* SetLocalHostId */1 :
        return {
                localHostId: action._0,
                remoteHostId: state.remoteHostId,
                localHostTime: state.localHostTime,
                connectedPeers: state.connectedPeers,
                playerState: state.playerState
              };
    case /* SetRemoteHostId */2 :
        return {
                localHostId: state.localHostId,
                remoteHostId: action._0,
                localHostTime: state.localHostTime,
                connectedPeers: state.connectedPeers,
                playerState: state.playerState
              };
    case /* SetConnectedPeers */3 :
        return {
                localHostId: state.localHostId,
                remoteHostId: state.remoteHostId,
                localHostTime: state.localHostTime,
                connectedPeers: action._0,
                playerState: state.playerState
              };
    case /* SetPlayerState */4 :
        return {
                localHostId: state.localHostId,
                remoteHostId: state.remoteHostId,
                localHostTime: state.localHostTime,
                connectedPeers: state.connectedPeers,
                playerState: action._0
              };
    
  }
}

function useStorage(param) {
  var match = React.useReducer(storageReducer, initialState);
  var dispatch = match[1];
  React.useEffect((function () {
          var load = async function (param) {
            var res = await WebextensionPolyfill.storage.local.get([
                  "localHostTime",
                  "localHostId",
                  "remoteHostId",
                  "connectedPeers",
                  "playerState"
                ]);
            var res$1 = Json$JsonCombinators.decode(res, Browser.$$Storage.Decode.initialStorageItem);
            var decodedRes;
            decodedRes = res$1.TAG === /* Ok */0 ? res$1._0 : Pervasives.failwith(res$1._0);
            var timestamp = decodedRes.localHostTime;
            if (timestamp !== undefined) {
              var timestamp$1 = Belt_Float.fromString(timestamp);
              if (timestamp$1 !== undefined) {
                Curry._1(dispatch, {
                      TAG: /* LocalHostTime */0,
                      _0: timestamp$1
                    });
              }
              
            }
            var id = decodedRes.localHostId;
            if (id !== undefined) {
              Curry._1(dispatch, {
                    TAG: /* SetLocalHostId */1,
                    _0: id
                  });
            }
            var id$1 = decodedRes.remoteHostId;
            if (id$1 !== undefined) {
              Curry._1(dispatch, {
                    TAG: /* SetRemoteHostId */2,
                    _0: id$1
                  });
            }
            var count = decodedRes.connectedPeers;
            if (count !== undefined) {
              var count$1 = Belt_Int.fromString(count);
              if (count$1 !== undefined) {
                Curry._1(dispatch, {
                      TAG: /* SetConnectedPeers */3,
                      _0: count$1
                    });
              }
              
            }
            var playerState = decodedRes.playerState;
            if (playerState === undefined) {
              return ;
            }
            switch (playerState) {
              case "paused" :
                  return Curry._1(dispatch, {
                              TAG: /* SetPlayerState */4,
                              _0: /* Paused */1
                            });
              case "playing" :
                  return Curry._1(dispatch, {
                              TAG: /* SetPlayerState */4,
                              _0: /* Playing */0
                            });
              default:
                return Curry._1(dispatch, {
                            TAG: /* SetPlayerState */4,
                            _0: /* Unknown */2
                          });
            }
          };
          load(undefined);
        }), []);
  React.useEffect((function () {
          var handleChange = function (changes, param) {
            var changes$1 = Json$JsonCombinators.decode(changes, Browser.$$Storage.Decode.storageChange);
            var decodedChanges;
            decodedChanges = changes$1.TAG === /* Ok */0 ? changes$1._0 : Pervasives.failwith(changes$1._0);
            var clocalHostTime = decodedChanges.changedLocalHostTime;
            if (clocalHostTime !== undefined) {
              var timestamp = Belt_Float.fromString(clocalHostTime.newValue);
              if (timestamp !== undefined) {
                Curry._1(dispatch, {
                      TAG: /* LocalHostTime */0,
                      _0: timestamp
                    });
              } else {
                Pervasives.failwith("Could not parse timestamp");
              }
            }
            var clocalHostId = decodedChanges.changedLocalHostId;
            if (clocalHostId !== undefined) {
              Curry._1(dispatch, {
                    TAG: /* SetLocalHostId */1,
                    _0: clocalHostId.newValue
                  });
            }
            var cremoteHostId = decodedChanges.changedRemoteHostId;
            if (cremoteHostId !== undefined) {
              Curry._1(dispatch, {
                    TAG: /* SetRemoteHostId */2,
                    _0: cremoteHostId.newValue
                  });
            }
            var cconnectedPeers = decodedChanges.changedConnectedPeers;
            if (cconnectedPeers !== undefined) {
              var count = Belt_Int.fromString(cconnectedPeers.newValue);
              if (count !== undefined) {
                Curry._1(dispatch, {
                      TAG: /* SetConnectedPeers */3,
                      _0: count
                    });
              } else {
                Pervasives.failwith("Could not parse connected peers");
              }
            }
            var cplayerState = decodedChanges.changedPlayerState;
            if (cplayerState === undefined) {
              return ;
            }
            var match = cplayerState.newValue;
            switch (match) {
              case "paused" :
                  return Curry._1(dispatch, {
                              TAG: /* SetPlayerState */4,
                              _0: /* Paused */1
                            });
              case "playing" :
                  return Curry._1(dispatch, {
                              TAG: /* SetPlayerState */4,
                              _0: /* Playing */0
                            });
              default:
                return Curry._1(dispatch, {
                            TAG: /* SetPlayerState */4,
                            _0: /* Unknown */2
                          });
            }
          };
          WebextensionPolyfill.storage.onChanged.addListener(handleChange);
          return (function (param) {
                    WebextensionPolyfill.storage.onChanged.removeListener(handleChange);
                  });
        }), []);
  var setItem = function (action) {
    var dict = {};
    if (typeof action === "number") {
      WebextensionPolyfill.storage.local.clear();
    } else {
      switch (action.TAG | 0) {
        case /* LocalHostTime */0 :
            dict["localHostTime"] = action._0.toString();
            break;
        case /* SetLocalHostId */1 :
            dict["localHostId"] = action._0;
            break;
        case /* SetRemoteHostId */2 :
            dict["remoteHostId"] = action._0;
            break;
        case /* SetConnectedPeers */3 :
            dict["connectedPeers"] = action._0.toString();
            break;
        case /* SetPlayerState */4 :
            switch (action._0) {
              case /* Playing */0 :
                  dict["playerState"] = "playing";
                  break;
              case /* Paused */1 :
                  dict["playerState"] = "paused";
                  break;
              case /* Unknown */2 :
                  dict["playerState"] = "unknown";
                  break;
              
            }
            break;
        
      }
    }
    WebextensionPolyfill.storage.local.set(dict);
  };
  return [
          match[0],
          setItem
        ];
}

function useVideo(param) {
  var match = React.useState(function () {
        
      });
  var setVideoEl = match[1];
  React.useEffect((function () {
          var interval = {
            contents: null
          };
          var cancelInterval = function (param) {
            Js_null_undefined.iter(interval.contents, (function (intervalId) {
                    clearInterval(intervalId);
                  }));
          };
          var checkVideoEl = function (param) {
            var el = Utils.getVideoEl(undefined);
            if (el === undefined) {
              return Curry._1(setVideoEl, (function (param) {
                            
                          }));
            }
            var el$1 = Caml_option.valFromOption(el);
            if (el$1.duration > 60) {
              return Curry._1(setVideoEl, (function (param) {
                            return Caml_option.some(el$1);
                          }));
            } else {
              return Curry._1(setVideoEl, (function (param) {
                            
                          }));
            }
          };
          interval.contents = setInterval(checkVideoEl, 500);
          return cancelInterval;
        }), []);
  return match[0];
}

function usePeer(remoteHostId, videoEl) {
  var peer = React.useRef(new Peerjs.Peer(undefined, {
            debug: 2,
            secure: true
          }));
  var match = React.useState(function () {
        
      });
  var setLocalPeerId = match[1];
  var match$1 = React.useState(function () {
        return /* [] */0;
      });
  var setConnections = match$1[1];
  var connections = match$1[0];
  var match$2 = React.useState(function () {
        
      });
  var setCurrentFilm = match$2[1];
  var handlePeerData = React.useCallback((function (data) {
          var v = Utils.getVideoEl(undefined);
          if (v === undefined) {
            return Pervasives.failwith("Video element went missing");
          }
          var el = Caml_option.valFromOption(v);
          switch (data.TAG | 0) {
            case /* Film */0 :
                var film = data._0;
                return Curry._1(setCurrentFilm, (function (param) {
                              return film;
                            }));
            case /* Play */1 :
                el.currentTime = data._0;
                el.play();
                return ;
            case /* Pause */2 :
                el.pause();
                el.currentTime = data._0;
                return ;
            case /* TimeUpdate */3 :
                return ;
            
          }
        }), []);
  var emitToPeers = React.useCallback((function (action) {
          switch (action.TAG | 0) {
            case /* Film */0 :
                var film = action._0;
                return Belt_List.forEach(connections, (function (connection) {
                              connection.send({
                                    TAG: /* Film */0,
                                    _0: film
                                  });
                            }));
            case /* Play */1 :
                var timestamp = action._0;
                return Belt_List.forEach(connections, (function (connection) {
                              connection.send({
                                    TAG: /* Play */1,
                                    _0: timestamp
                                  });
                            }));
            case /* Pause */2 :
                var timestamp$1 = action._0;
                return Belt_List.forEach(connections, (function (connection) {
                              connection.send({
                                    TAG: /* Pause */2,
                                    _0: timestamp$1
                                  });
                            }));
            case /* TimeUpdate */3 :
                var timestamp$2 = action._0;
                return Belt_List.forEach(connections, (function (connection) {
                              connection.send({
                                    TAG: /* TimeUpdate */3,
                                    _0: timestamp$2
                                  });
                            }));
            
          }
        }), [connections]);
  React.useEffect((function () {
          var handlePlay = function ($$event) {
            var currentTime = $$event.target.currentTime;
            Curry._1(emitToPeers, {
                  TAG: /* Play */1,
                  _0: currentTime
                });
          };
          var handlePause = function ($$event) {
            var currentTime = $$event.target.currentTime;
            Curry._1(emitToPeers, {
                  TAG: /* Pause */2,
                  _0: currentTime
                });
          };
          var handleTimeUpdate = function ($$event) {
            var currentTime = $$event.target.currentTime;
            Curry._1(emitToPeers, {
                  TAG: /* TimeUpdate */3,
                  _0: currentTime
                });
          };
          Throttle.make(2000, handleTimeUpdate);
          videoEl.addEventListener("play", handlePlay);
          videoEl.addEventListener("pause", handlePause);
          return (function (param) {
                    videoEl.removeEventListener("play", handlePlay);
                    videoEl.removeEventListener("pause", handlePause);
                  });
        }), [
        videoEl,
        emitToPeers
      ]);
  React.useEffect((function () {
          peer.current.on("open", (function (id) {
                  Curry._1(setLocalPeerId, (function (param) {
                          return id;
                        }));
                  peer.current.on("connection", (function (connection) {
                          connection.on("open", (function (param) {
                                  connection.on("data", handlePeerData);
                                  Curry._1(setConnections, (function (prev) {
                                          return {
                                                  hd: connection,
                                                  tl: prev
                                                };
                                        }));
                                }));
                          connection.on("close", (function (param) {
                                  Curry._1(setConnections, (function (prev) {
                                          return Belt_List.keep(prev, (function (item) {
                                                        return item.peer !== connection.peer;
                                                      }));
                                        }));
                                }));
                          connection.on("error", (function (error) {
                                  
                                }));
                        }));
                }));
        }), [handlePeerData]);
  React.useEffect((function () {
          if (remoteHostId !== undefined) {
            var peerConnection = peer.current.connect(remoteHostId, undefined);
            peerConnection.on("open", (function (param) {
                    Curry._1(setConnections, (function (prev) {
                            return {
                                    hd: peerConnection,
                                    tl: prev
                                  };
                          }));
                    peerConnection.on("data", handlePeerData);
                    peerConnection.on("close", (function (param) {
                            Curry._1(setConnections, (function (prev) {
                                    return Belt_List.keep(prev, (function (item) {
                                                  return item.peer !== peerConnection.peer;
                                                }));
                                  }));
                          }));
                    peerConnection.on("error", (function (error) {
                            
                          }));
                  }));
          }
          
        }), [
        remoteHostId,
        handlePeerData
      ]);
  React.useEffect((function () {
          return (function (param) {
                    peer.current.destroy();
                    Curry._1(setConnections, (function (param) {
                            return /* [] */0;
                          }));
                  });
        }), []);
  return [
          peer.current,
          match[0],
          connections
        ];
}

export {
  initialState ,
  storageReducer ,
  useStorage ,
  useVideo ,
  usePeer ,
}
/* Utils Not a pure module */