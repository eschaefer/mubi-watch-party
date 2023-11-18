// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Curry from "rescript/lib/es6/curry.js";
import * as Hooks from "./Hooks.bs.js";
import * as Utils from "../../shared/Utils.bs.js";
import * as React from "react";
import * as Header from "../../shared/components/Header.bs.js";
import * as Belt_List from "rescript/lib/es6/belt_List.js";
import * as GroupIcon from "../../shared/components/GroupIcon.bs.js";
import * as Belt_Array from "rescript/lib/es6/belt_Array.js";
import * as Caml_option from "rescript/lib/es6/caml_option.js";
import ElementVisible from "element-visible";
import * as Js_null_undefined from "rescript/lib/es6/js_null_undefined.js";
import * as Browser$ReScriptLogger from "rescript-logger/src/loggers/Browser.bs.js";

function Content$LinkIcon(Props) {
  return React.createElement("svg", {
              className: "w-4 h-4",
              fill: "none",
              stroke: "currentColor",
              strokeWidth: "1.5",
              viewBox: "0 0 24 24",
              xmlns: "http://www.w3.org/2000/svg"
            }, React.createElement("path", {
                  d: "M13.19 8.688a4.5 4.5 0 011.242 7.244l-4.5 4.5a4.5 4.5 0 01-6.364-6.364l1.757-1.757m13.35-.622l1.757-1.757a4.5 4.5 0 00-6.364-6.364l-4.5 4.5a4.5 4.5 0 001.242 7.244",
                  strokeLinecap: "round",
                  strokeLinejoin: "round"
                }));
}

var LinkIcon = {
  make: Content$LinkIcon
};

function Content$Trigger(Props) {
  var state = Props.state;
  var setRemoteHostId = Props.setRemoteHostId;
  var reset = Props.reset;
  var setLocalHostId = Props.setLocalHostId;
  var match = Hooks.usePeer(state.remoteHostId);
  var localPeerId = match[1];
  var match$1 = React.useState(function () {
        return false;
      });
  var setIsOpen = match$1[1];
  var match$2 = React.useState(function () {
        return "";
      });
  var setInput = match$2[1];
  var input = match$2[0];
  var match$3 = React.useState(function () {
        return false;
      });
  var setIsControlVisible = match$3[1];
  var match$4 = React.useState(function () {
        return false;
      });
  var setCopied = match$4[1];
  var localHostId = state.localHostId;
  var connectionCount = Belt_List.length(match[2]);
  var visibility = match$3[0] ? "opacity-100" : "opacity-0";
  var connected = connectionCount > 0 ? "text-emerald-600 bg-emerald-50 hover:bg-emerald-100" : "text-indigo-600 bg-indigo-50 hover:bg-indigo-100";
  React.useEffect((function () {
          if (localPeerId !== undefined) {
            Curry._1(setLocalHostId, localPeerId);
          }
          
        }), [localPeerId]);
  React.useEffect((function () {
          var url = Utils.getPageUrl(undefined);
          var urlWithPartyParam = url.split("?party=");
          var id = Belt_Array.get(urlWithPartyParam, 1);
          Browser$ReScriptLogger.debug1({
                rootModule: "Content",
                subModulePath: {
                  hd: "Trigger",
                  tl: /* [] */0
                },
                value: "make",
                fullPath: "Content.Trigger.make"
              }, "Params check", [
                "id",
                id
              ]);
          if (id !== undefined && localHostId !== undefined) {
            Curry._1(setRemoteHostId, id);
          }
          
        }), [localHostId]);
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
  if (match$1[0]) {
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
                              }, id), React.createElement("button", {
                                className: "mt-2",
                                onClick: (function (param) {
                                    var url = Utils.getPageUrl(undefined);
                                    var urlWithId = url + "?party=" + id;
                                    navigator.clipboard.writeText(urlWithId);
                                    Curry._1(setCopied, (function (param) {
                                            return true;
                                          }));
                                    setTimeout((function (param) {
                                            Curry._1(setCopied, (function (param) {
                                                    return false;
                                                  }));
                                          }), 3000);
                                  })
                              }, React.createElement("div", {
                                    className: "flex gap-2 items-center font-semibold"
                                  }, React.createElement(Content$LinkIcon, {}), match$4[0] ? React.createElement("span", undefined, "Copied!") : React.createElement("span", undefined, "Copy link to share")))) : React.createElement(React.Fragment, undefined), connectionCount > 0 ? React.createElement("button", {
                            className: "rounded-md bg-white px-3.5 py-2.5 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50",
                            onClick: (function (param) {
                                Curry._1(reset, undefined);
                              })
                          }, "Disconnect") : React.createElement("form", {
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
                                  })), React.createElement("div", {
                                className: "flex gap-3"
                              }, React.createElement("button", {
                                    className: "rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600",
                                    type: "submit"
                                  }, "Connect")))), React.createElement("div", {
                      className: "inline-block overflow-hidden rounded-lg bg-white px-2 py-3 shadow"
                    }, React.createElement("p", {
                          className: "truncate text-xs font-medium text-gray-500"
                        }, "Currently connected"), React.createElement("p", {
                          className: "mt-1 text-xl font-semibold tracking-tight text-gray-900"
                        }, String(connectionCount))))));
  } else {
    tmp = React.createElement(React.Fragment, undefined);
  }
  return React.createElement(React.Fragment, undefined, React.createElement("div", {
                  className: "fixed z-10 bottom-0 left-1/2 -translate-x-1/2 h-[65px] flex items-center"
                }, React.createElement("button", {
                      className: "" + visibility + " " + connected + " transition-opacity duration-200 flex items-center gap-2 rounded-md px-3 py-2 text-sm font-semibold shadow-sm",
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

function Content(Props) {
  var match = Hooks.useLocalState(undefined);
  var dispatch = match[1];
  var video = Hooks.useVideo(undefined);
  if (video) {
    return React.createElement(Content$Trigger, {
                state: match[0],
                setRemoteHostId: (function (id) {
                    Curry._1(dispatch, {
                          TAG: /* SetRemoteHostId */2,
                          _0: id
                        });
                  }),
                reset: (function (param) {
                    Curry._1(dispatch, /* Reset */0);
                  }),
                setLocalHostId: (function (id) {
                    Curry._1(dispatch, {
                          TAG: /* SetLocalHostId */1,
                          _0: id
                        });
                  })
              });
  } else {
    return React.createElement(React.Fragment, undefined);
  }
}

var make = Content;

export {
  LinkIcon ,
  Trigger ,
  make ,
}
/* Hooks Not a pure module */
