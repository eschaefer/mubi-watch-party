// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Curry from "rescript/lib/es6/curry.js";
import * as React from "react";
import * as Header from "../shared/components/Header.bs.js";
import * as WebextensionPolyfill from "webextension-polyfill";
import * as Browser$ReScriptLogger from "rescript-logger/src/loggers/Browser.bs.js";

function Popup$Alert(Props) {
  return React.createElement("div", {
              className: "bg-yellow-50 p-4 rounded-lg"
            }, React.createElement("div", {
                  className: "flex"
                }, React.createElement("div", {
                      className: "flex-shrink-0"
                    }, React.createElement("svg", {
                          className: "h-5 w-5 text-yellow-400",
                          fill: "none",
                          stroke: "currentColor",
                          strokeWidth: "1.5",
                          viewBox: "0 0 24 24",
                          xmlns: "http://www.w3.org/2000/svg"
                        }, React.createElement("path", {
                              d: "M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126zM12 15.75h.007v.008H12v-.008z",
                              strokeLinecap: "round",
                              strokeLinejoin: "round"
                            }))), React.createElement("div", {
                      className: "ml-3"
                    }, React.createElement("p", {
                          className: "text-sm text-yellow-700"
                        }, "You are not on a Mubi video player page."))));
}

var Alert = {
  make: Popup$Alert
};

function Popup$PlayerPageUI(Props) {
  var resetEnv = Props.resetEnv;
  var setRemoteHostId = Props.setRemoteHostId;
  var remoteHostId = Props.remoteHostId;
  var match = React.useState(function () {
        return "";
      });
  var setInput = match[1];
  var input = match[0];
  return React.createElement("div", undefined, remoteHostId !== undefined ? React.createElement("div", undefined, "Connected to remote host") : React.createElement("form", {
                    onSubmit: (function ($$event) {
                        $$event.preventDefault();
                        Curry._1(setRemoteHostId, input);
                      })
                  }, React.createElement("label", undefined, "Enter host ID", React.createElement("input", {
                            type: "text",
                            value: input,
                            onChange: (function ($$event) {
                                Curry._1(setInput, (function (param) {
                                        return $$event.target.value.trim();
                                      }));
                              })
                          })), React.createElement("button", {
                        type: "submit"
                      }, "Connect")), React.createElement("button", {
                  onClick: (function (param) {
                      Curry._1(resetEnv, undefined);
                    })
                }, "Reset"));
}

var PlayerPageUI = {
  make: Popup$PlayerPageUI
};

function Popup(Props) {
  var match = React.useState(function () {
        return false;
      });
  var setIsOnPlayerPage = match[1];
  var getMubiTab = React.useCallback((async function (param) {
          var tabs = await WebextensionPolyfill.tabs.query({
                active: true,
                currentWindow: true
              });
          Browser$ReScriptLogger.debug1({
                rootModule: "Popup",
                subModulePath: /* [] */0,
                value: "make",
                fullPath: "Popup.make"
              }, "Got tabs", [
                "tabs",
                tabs
              ]);
          var mubiPlayerTab = tabs.find(function (tab) {
                if (tab.url.startsWith("https://mubi.com")) {
                  return tab.url.endsWith("/player");
                } else {
                  return false;
                }
              });
          if (mubiPlayerTab !== undefined) {
            return Curry._1(setIsOnPlayerPage, (function (param) {
                          return true;
                        }));
          } else {
            return Curry._1(setIsOnPlayerPage, (function (param) {
                          return false;
                        }));
          }
        }), []);
  React.useEffect((function () {
          Curry._1(getMubiTab, undefined);
          var intervalId = setInterval((function (param) {
                  Curry._1(getMubiTab, undefined);
                }), 500);
          return (function (param) {
                    clearInterval(intervalId);
                  });
        }), [getMubiTab]);
  return React.createElement("main", {
              className: "p-4 w-80"
            }, React.createElement("div", {
                  className: "pb-2"
                }, React.createElement(Header.make, {})), React.createElement("div", {
                  className: "pb-2"
                }, React.createElement("div", {
                      className: "rounded-md bg-blue-50 p-4"
                    }, React.createElement("div", {
                          className: "flex text-blue-600"
                        }, React.createElement("div", {
                              className: "flex-shrink-0 "
                            }, React.createElement("svg", {
                                  className: "h-5 w-5",
                                  fill: "none",
                                  stroke: "currentColor",
                                  strokeWidth: "1.5",
                                  viewBox: "0 0 24 24",
                                  xmlns: "http://www.w3.org/2000/svg"
                                }, React.createElement("path", {
                                      d: "M11.25 11.25l.041-.02a.75.75 0 011.063.852l-.708 2.836a.75.75 0 001.063.853l.041-.021M21 12a9 9 0 11-18 0 9 9 0 0118 0zm-9-3.75h.008v.008H12V8.25z",
                                      strokeLinecap: "round",
                                      strokeLinejoin: "round"
                                    }))), React.createElement("div", {
                              className: "ml-3 flex-1 md:flex md:justify-between"
                            }, React.createElement("p", {
                                  className: "text-sm"
                                }, "When on a movie player page, look for the Watch Party button near the video controls."), React.createElement("p", {
                                  className: "mt-3 text-sm md:ml-6 md:mt-0"
                                }))))), match[0] ? React.createElement(React.Fragment, undefined) : React.createElement(Popup$Alert, {}));
}

var make = Popup;

export {
  Alert ,
  PlayerPageUI ,
  make ,
}
/* react Not a pure module */