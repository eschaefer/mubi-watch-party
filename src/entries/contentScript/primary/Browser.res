// Rescript binding for the WebExtension runtime API:
// https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/runtime

module WebNavigation = {
  module OnHistoryStateUpdated = {
    @module("webextension-polyfill") @scope(("webNavigation", "onHistoryStateUpdated"))
    external addListener: (_ => unit) => unit = "addListener"
  }
}

module Tabs = {
  type tabsQueryParams = {
    active: bool,
    currentWindow: bool,
  }

  type tab = {
    id: int,
    url: string,
    active: bool,
    title: string,
  }

  @module("webextension-polyfill") @scope("tabs")
  external query: tabsQueryParams => promise<array<tab>> = "query"
}
