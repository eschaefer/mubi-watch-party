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

module Storage = {
  type storageValue
  type areaName = [#local]
  type changedStorageValue

  type storageNewResult = {newValue: string}

  type storageChange = {
    changedLocalHostTime: option<storageNewResult>,
    changedLocalHostId: option<storageNewResult>,
    changedRemoteHostId: option<storageNewResult>,
    changedConnectedPeers: option<storageNewResult>,
    changedPlayerState: option<storageNewResult>,
  }

  type storageItem = {key: string, value: string}

  type savedStorageItem = {
    localHostTime: option<string>,
    localHostId: option<string>,
    remoteHostId: option<string>,
    connectedPeers: option<string>,
    playerState: option<string>,
  }

  @module("webextension-polyfill") @scope(("storage", "local"))
  external get: array<string> => promise<Js.Json.t> = "get"

  @module("webextension-polyfill") @scope(("storage", "local"))
  external set: Js.Json.t => promise<unit> = "set"

  @module("webextension-polyfill") @scope(("storage", "local"))
  external clear: unit => promise<unit> = "clear"

  module OnChanged = {
    @module("webextension-polyfill") @scope(("storage", "onChanged"))
    external addListener: ((Js.Json.t, areaName) => unit) => unit = "addListener"

    @module("webextension-polyfill") @scope(("storage", "onChanged"))
    external removeListener: ((Js.Json.t, areaName) => unit) => unit = "removeListener"
  }

  module Decode = {
    open Json.Decode

    let initialStorageItem = object(field => {
      localHostTime: field.optional(. "localHostTime", string),
      localHostId: field.optional(. "localHostId", string),
      remoteHostId: field.optional(. "remoteHostId", string),
      connectedPeers: field.optional(. "connectedPeers", string),
      playerState: field.optional(. "playerState", string),
    })

    let storageNewResult = object(field => {
      newValue: field.required(. "newValue", string),
    })

    let storageChange = object(field => {
      changedLocalHostTime: field.optional(. "localHostTime", storageNewResult),
      changedLocalHostId: field.optional(. "localHostId", storageNewResult),
      changedRemoteHostId: field.optional(. "remoteHostId", storageNewResult),
      changedConnectedPeers: field.optional(. "connectedPeers", storageNewResult),
      changedPlayerState: field.optional(. "playerState", storageNewResult),
    })
  }
}
