// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Curry from "rescript/lib/es6/curry.js";
import * as Hooks from "./Hooks.bs.js";
import * as Utils from "../../shared/Utils.bs.js";
import * as React from "react";
import * as Header from "../../shared/components/Header.bs.js";
import * as Belt_List from "rescript/lib/es6/belt_List.js";
import * as GroupIcon from "../../shared/components/GroupIcon.bs.js";
import * as Caml_option from "rescript/lib/es6/caml_option.js";
import ElementVisible from "element-visible";
import * as Js_null_undefined from "rescript/lib/es6/js_null_undefined.js";

function Content$Trigger(Props) {
  var state = Props.state;
  var setRemoteHostId = Props.setRemoteHostId;
  var match = React.useState(function () {
        return false;
      });
  var setIsOpen = match[1];
  var match$1 = React.useState(function () {
        return "";
      });
  var setInput = match$1[1];
  var input = match$1[0];
  var match$2 = React.useState(function () {
        return false;
      });
  var setIsControlVisible = match$2[1];
  var visibility = match$2[0] ? "opacity-100" : "opacity-0";
  React.useEffect((function () {
          var interval = {
            contents: null
          };
          var cancelInterval = function (param) {
            Js_null_undefined.iter(interval.contents, (function (intervalId) {
                    clearInterval(intervalId);
                  }));
          };
          var checkControlVisibility = function (param) {
            var el = Utils.getNestedControlEl(undefined);
            if (el !== undefined) {
              if (ElementVisible(Caml_option.valFromOption(el))) {
                return Curry._1(setIsControlVisible, (function (param) {
                              return true;
                            }));
              } else {
                return Curry._1(setIsControlVisible, (function (param) {
                              return false;
                            }));
              }
            } else {
              return Curry._1(setIsControlVisible, (function (param) {
                            return false;
                          }));
            }
          };
          interval.contents = setInterval(checkControlVisibility, 500);
          checkControlVisibility(undefined);
          return cancelInterval;
        }), []);
  var tmp;
  if (match[0]) {
    var id = state.localHostId;
    tmp = React.createElement("div", {
          className: "fixed inset-0 z-10 w-screen overflow-y-auto bg-gray-500 bg-opacity-50"
        }, React.createElement("div", {
              className: "flex min-h-full items-end justify-center p-4 text-center sm:items-center sm:p-0"
            }, React.createElement("div", {
                  className: "overflow-hidden rounded-lg bg-white px-4 pb-4 pt-5 text-left shadow-xl sm:my-8 sm:w-full sm:max-w-md"
                }, React.createElement("div", {
                      className: "flex w-full justify-between"
                    }, React.createElement(Header.make, {}), React.createElement("button", {
                          onClick: (function (param) {
                              Curry._1(setIsOpen, (function (param) {
                                      return false;
                                    }));
                            })
                        }, React.createElement("svg", {
                              className: "w-6 h-6",
                              fill: "none",
                              stroke: "currentColor",
                              strokeWidth: "1.5",
                              viewBox: "0 0 24 24"
                            }, React.createElement("path", {
                                  d: "M6 18L18 6M6 6l12 12",
                                  strokeLinecap: "round",
                                  strokeLinejoin: "round"
                                })))), React.createElement("div", {
                      className: "py-4"
                    }, id !== undefined ? React.createElement("div", {
                            className: "pb-4"
                          }, React.createElement("p", {
                                className: "font-medium text-gray-900"
                              }, "Your ID is"), React.createElement("p", {
                                className: "font-semibold font-mono"
                              }, id)) : React.createElement(React.Fragment, undefined), React.createElement("form", {
                          onSubmit: (function ($$event) {
                              $$event.preventDefault();
                              Curry._1(setRemoteHostId, input);
                            })
                        }, React.createElement("label", {
                              className: "block font-medium leading-6 text-gray-900",
                              htmlFor: "peerid"
                            }, "Connect to another ID"), React.createElement("div", {
                              className: "mt-2 pb-2"
                            }, React.createElement("input", {
                                  className: "block w-full rounded-md border-0 py-1.5 px-2 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6",
                                  id: "peerid",
                                  autoComplete: "off",
                                  name: "peerid",
                                  placeholder: "Get this ID from another user",
                                  type: "text",
                                  onChange: (function ($$event) {
                                      Curry._1(setInput, (function (param) {
                                              return $$event.target.value;
                                            }));
                                    })
                                })), React.createElement("button", {
                              className: "rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600",
                              type: "submit"
                            }, "Connect"))), React.createElement("div", {
                      className: "inline-block overflow-hidden rounded-lg bg-white px-2 py-3 shadow"
                    }, React.createElement("p", {
                          className: "truncate text-xs font-medium text-gray-500"
                        }, "Currently connected"), React.createElement("p", {
                          className: "mt-1 text-xl font-semibold tracking-tight text-gray-900"
                        }, String(state.connectedPeers))))));
  } else {
    tmp = React.createElement(React.Fragment, undefined);
  }
  return React.createElement(React.Fragment, undefined, React.createElement("div", {
                  className: "fixed z-10 bottom-0 left-1/2 -translate-x-1/2 h-[65px] flex items-center"
                }, React.createElement("button", {
                      className: "" + visibility + " transition-opacity duration-200 flex items-center gap-2 rounded-md bg-indigo-50 px-3 py-2 text-sm font-semibold text-indigo-600 shadow-sm hover:bg-indigo-100",
                      onClick: (function (param) {
                          Curry._1(setIsOpen, (function (param) {
                                  return true;
                                }));
                        })
                    }, React.createElement(GroupIcon.make, {
                          className: "w-4 h-4"
                        }), React.createElement("span", undefined, "Watch Party"))), tmp);
}

var Trigger = {
  make: Content$Trigger
};

function Content$Manager(Props) {
  var setLocalHostId = Props.setLocalHostId;
  var syncConnectionsCountToStorage = Props.syncConnectionsCountToStorage;
  var remoteHostId = Props.remoteHostId;
  var videoEl = Props.videoEl;
  var match = Hooks.usePeer(remoteHostId, videoEl);
  var localPeerId = match[1];
  var connectionsCount = Belt_List.length(match[2]);
  React.useEffect((function () {
          if (localPeerId !== undefined) {
            Curry._1(setLocalHostId, localPeerId);
          }
          
        }), [
        localPeerId,
        setLocalHostId
      ]);
  React.useEffect((function () {
          Curry._1(syncConnectionsCountToStorage, connectionsCount);
        }), [connectionsCount]);
  return React.createElement(React.Fragment, undefined);
}

var Manager = {
  make: Content$Manager
};

function Content(Props) {
  var match = Hooks.useStorage(undefined);
  var setItem = match[1];
  var state = match[0];
  var video = Hooks.useVideo(undefined);
  if (video !== undefined) {
    return React.createElement(React.Fragment, undefined, React.createElement(Content$Manager, {
                    setLocalHostId: (function (id) {
                        Curry._1(setItem, {
                              TAG: /* SetLocalHostId */1,
                              _0: id
                            });
                      }),
                    syncConnectionsCountToStorage: (function (connectionsCount) {
                        Curry._1(setItem, {
                              TAG: /* SetConnectedPeers */3,
                              _0: connectionsCount
                            });
                      }),
                    remoteHostId: state.remoteHostId,
                    videoEl: Caml_option.valFromOption(video)
                  }), React.createElement(Content$Trigger, {
                    state: state,
                    setRemoteHostId: (function (id) {
                        Curry._1(setItem, {
                              TAG: /* SetRemoteHostId */2,
                              _0: id
                            });
                      })
                  }));
  } else {
    return React.createElement(React.Fragment, undefined);
  }
}

var make = Content;

export {
  Trigger ,
  Manager ,
  make ,
}
/* Hooks Not a pure module */
