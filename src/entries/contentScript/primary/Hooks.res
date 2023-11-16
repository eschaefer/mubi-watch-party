open Webapi.Dom

@send external play: Dom.element => unit = "play"
@send external pause: Dom.element => unit = "pause"
@get external duration: Dom.element => int = "duration"
@get external currentTime: Dom.eventTarget => float = "currentTime"
@set external setCurrentTime: (Dom.element, float) => unit = "currentTime"

type storagePlayerState = Playing | Paused | Unknown

type timestamp = float

type currentFilm = {
  title: string,
  url: string,
}

// Not to be synced with storage
type hostAction = Film(currentFilm) | Play(timestamp) | Pause(timestamp) | TimeUpdate(timestamp)

type storageAction =
  | Reset
  | LocalHostTime(float)
  | SetLocalHostId(string)
  | SetRemoteHostId(string)
  | SetConnectedPeers(int)
  | SetPlayerState(storagePlayerState)

type storageState = {
  localHostId: option<string>,
  remoteHostId: option<string>,
  localHostTime: float,
  connectedPeers: int,
  playerState: storagePlayerState,
}

let initialState = {
  localHostId: None,
  remoteHostId: None,
  localHostTime: 0.0,
  connectedPeers: 0,
  playerState: Unknown,
}

let storageReducer = (state, action) => {
  @log
  switch action {
  | Reset => initialState
  | LocalHostTime(timestamp) => {
      ...state,
      localHostTime: timestamp,
    }
  | SetLocalHostId(id) => {
      ...state,
      localHostId: Some(id),
    }
  | SetRemoteHostId(id) => {
      ...state,
      remoteHostId: Some(id),
    }

  | SetConnectedPeers(count) => {
      ...state,
      connectedPeers: count,
    }
  | SetPlayerState(playerState) => {
      ...state,
      playerState,
    }
  }
}

let useStorage = () => {
  let (state, dispatch) = React.useReducer(storageReducer, initialState)

  // Get initial storage state
  React.useEffect0(() => {
    let load = async () => {
      // WARNING: If you add something here, make sure to update the decoders,
      // and dispatch the correct action below in this hook too.
      let res = await Browser.Storage.get([
        "localHostTime",
        "localHostId",
        "remoteHostId",
        "connectedPeers",
        "playerState",
      ])

      %log.debug(
        "Storage loaded"
        ("response", res)
      )

      let decodedRes = switch res->Json.decode(Browser.Storage.Decode.initialStorageItem) {
      | Ok(res) => res
      | Error(err) => failwith(err)
      }

      switch decodedRes.localHostTime {
      | Some(timestamp) =>
        switch Belt.Float.fromString(timestamp) {
        | Some(timestamp) => dispatch(LocalHostTime(timestamp))
        | None => ()
        }
      | None => ()
      }

      switch decodedRes.localHostId {
      | Some(id) => dispatch(SetLocalHostId(id))
      | None => ()
      }

      switch decodedRes.remoteHostId {
      | Some(id) => dispatch(SetRemoteHostId(id))
      | None => ()
      }

      switch decodedRes.connectedPeers {
      | Some(count) =>
        switch Belt.Int.fromString(count) {
        | Some(count) => dispatch(SetConnectedPeers(count))
        | None => ()
        }
      | None => ()
      }

      switch decodedRes.playerState {
      | Some(playerState) =>
        switch playerState {
        | "playing" => dispatch(SetPlayerState(Playing))
        | "paused" => dispatch(SetPlayerState(Paused))
        | _ => dispatch(SetPlayerState(Unknown))
        }
      | None => ()
      }
    }

    let _ = load()

    None
  })

  // Listen for storage changes
  React.useEffect0(() => {
    let handleChange = (changes: Js.Json.t, _) => {
      let decodedChanges =
        @log
        switch changes->Json.decode(Browser.Storage.Decode.storageChange) {
        | Ok(changes) => changes
        | Error(err) => failwith(err)
        }

      switch decodedChanges.changedLocalHostTime {
      | Some(clocalHostTime) => {
          let timestamp = Belt.Float.fromString(clocalHostTime.newValue)
          switch timestamp {
          | Some(timestamp) => dispatch(LocalHostTime(timestamp))
          | None => failwith("Could not parse timestamp")
          }
        }
      | None => ()
      }

      switch decodedChanges.changedLocalHostId {
      | Some(clocalHostId) => dispatch(SetLocalHostId(clocalHostId.newValue))
      | None => ()
      }

      switch decodedChanges.changedRemoteHostId {
      | Some(cremoteHostId) => dispatch(SetRemoteHostId(cremoteHostId.newValue))
      | None => ()
      }

      switch decodedChanges.changedConnectedPeers {
      | Some(cconnectedPeers) => {
          let count = Belt.Int.fromString(cconnectedPeers.newValue)
          switch count {
          | Some(count) => dispatch(SetConnectedPeers(count))
          | None => failwith("Could not parse connected peers")
          }
        }
      | None => ()
      }

      switch decodedChanges.changedPlayerState {
      | Some(cplayerState) =>
        switch cplayerState.newValue {
        | "playing" => dispatch(SetPlayerState(Playing))
        | "paused" => dispatch(SetPlayerState(Paused))
        | _ => dispatch(SetPlayerState(Unknown))
        }
      | None => ()
      }
    }

    Browser.Storage.OnChanged.addListener(handleChange)

    Some(
      () => {
        Browser.Storage.OnChanged.removeListener(handleChange)
      },
    )
  })

  let setItem = (action: storageAction) => {
    let dict = Js.Dict.empty()

    switch action {
    | LocalHostTime(timestamp) =>
      Js.Dict.set(dict, "localHostTime", Js.Json.string(Js.Float.toString(timestamp)))
    | SetLocalHostId(id) => Js.Dict.set(dict, "localHostId", Js.Json.string(id))
    | SetRemoteHostId(id) => Js.Dict.set(dict, "remoteHostId", Js.Json.string(id))
    | SetConnectedPeers(count) =>
      Js.Dict.set(dict, "connectedPeers", Js.Json.string(Js.Int.toString(count)))
    | SetPlayerState(playerState) =>
      switch playerState {
      | Playing => Js.Dict.set(dict, "playerState", Js.Json.string("playing"))
      | Paused => Js.Dict.set(dict, "playerState", Js.Json.string("paused"))
      | Unknown => Js.Dict.set(dict, "playerState", Js.Json.string("unknown"))
      }
    | Reset => Browser.Storage.clear()->ignore
    }

    Browser.Storage.set(Js.Json.object_(dict))->ignore
  }

  (state, setItem)
}

let useVideo = () => {
  let (videoEl, setVideoEl) = React.useState(() => None)

  // Get video element from page
  React.useEffect0(() => {
    let interval = ref(Js.Nullable.null)

    let cancelInterval = () =>
      Js.Nullable.iter(interval.contents, (. intervalId) => Js.Global.clearInterval(intervalId))

    let checkVideoEl = () => {
      switch Utils.getVideoEl() {
      | Some(el) =>
        if el->duration > 60 {
          setVideoEl(_ => Some(el))
        } else {
          %log.debug("Video element probably an ad")
          setVideoEl(_ => None)
        }
      | None => setVideoEl(_ => None)
      }
    }

    interval := Js.Nullable.return(Js.Global.setInterval(checkVideoEl, 500))

    Some(cancelInterval)
  })

  videoEl
}

let usePeer = (~remoteHostId, ~videoEl) => {
  let peer = React.useRef(Peer.makePeer((), ~config={debug: 2, secure: true}))
  let (localPeerId, setLocalPeerId) = React.useState(() => None)
  let (connections, setConnections) = React.useState(() => list{})
  let (currentFilm, setCurrentFilm) = React.useState(() => None)

  let handlePeerData = React.useCallback0(data => {
    let v = Utils.getVideoEl()

    @log
    switch v {
    | Some(el) =>
      @log
      switch data {
      | Film(film) => setCurrentFilm(_ => Some(film))
      | Play(timestamp) => {
          el->setCurrentTime(timestamp)
          el->play
        }

      | Pause(timestamp) => {
          el->pause
          el->setCurrentTime(timestamp)
        }

      | TimeUpdate(timestamp) => // Check for delta...
        ()
      }

    | None => failwith("Video element went missing")
    }
  })

  let emitToPeers = React.useCallback1(action => {
    @log
    switch action {
    | Film(film) =>
      Belt.List.forEach(connections, connection => {
        connection->Peer.DataConnection.send(Film(film))
      })
    | Play(timestamp) =>
      Belt.List.forEach(connections, connection => {
        connection->Peer.DataConnection.send(Play(timestamp))
      })
    | Pause(timestamp) =>
      Belt.List.forEach(connections, connection => {
        connection->Peer.DataConnection.send(Pause(timestamp))
      })
    | TimeUpdate(timestamp) =>
      Belt.List.forEach(connections, connection => {
        connection->Peer.DataConnection.send(TimeUpdate(timestamp))
      })
    }
  }, [connections])

  // Setup video element listeners
  React.useEffect2(() => {
    let handlePlay = event => {
      let currentTime = event->Event.target->currentTime
      %log.debug("Play movie")
      emitToPeers(Play(currentTime))
    }
    let handlePause = event => {
      let currentTime = event->Event.target->currentTime
      %log.debug("Pause movie")
      emitToPeers(Pause(currentTime))
    }
    let handleTimeUpdate = event => {
      let currentTime = event->Event.target->currentTime
      %log.debug("Time update")
      emitToPeers(TimeUpdate(currentTime))
    }
    let throttledHandleTimeUpdate = Throttle.make(~wait=2000, handleTimeUpdate)

    videoEl->Element.addEventListener("play", handlePlay)
    videoEl->Element.addEventListener("pause", handlePause)

    Some(
      () => {
        videoEl->Element.removeEventListener("play", handlePlay)
        videoEl->Element.removeEventListener("pause", handlePause)
        // videoEl->Element.removeEventListener("seeked", handleSeek)
        // videoEl->Element.removeEventListener("timeupdate", throttledHandleTimeUpdate)
      },
    )
  }, (videoEl, emitToPeers))

  React.useEffect1(() => {
    peer.current->Peer.on(
      #"open"(
        id => {
          %log.debug(
            "My peer ID is: "
            ("id", id)
          )
          setLocalPeerId(_ => Some(id))

          peer.current->Peer.on(
            #connection(
              connection => {
                connection->Peer.DataConnection.on(
                  #"open"(
                    _ => {
                      %log.debug("Data connection open")

                      connection->Peer.DataConnection.on(#data(handlePeerData))

                      setConnections(prev => list{connection, ...prev})

                      ()
                    },
                  ),
                )

                connection->Peer.DataConnection.on(
                  #close(
                    _ => {
                      %log.debug("data connection closed")
                      // Remove connection from list
                      setConnections(prev =>
                        prev->Belt.List.keep(
                          item => {
                            item->Peer.DataConnection.peer != connection->Peer.DataConnection.peer
                          },
                        )
                      )
                    },
                  ),
                )

                connection->Peer.DataConnection.on(
                  #error(
                    error => {
                      %log.error(
                        "data connection error"
                        ("error", error)
                      )
                    },
                  ),
                )
              },
            ),
          )
        },
      ),
    )

    None
  }, [handlePeerData])

  // When remoteHostId is provided, connect to that peer
  React.useEffect2(() => {
    switch remoteHostId {
    | None => ()
    | Some(remoteHostId) => {
        let peerConnection = peer.current->Peer.connect(~id=remoteHostId, ())

        peerConnection->Peer.DataConnection.on(
          #"open"(
            _ => {
              %log.debug("data connection open")

              setConnections(prev => list{peerConnection, ...prev})

              peerConnection->Peer.DataConnection.on(#data(handlePeerData))

              peerConnection->Peer.DataConnection.on(
                #close(
                  _ => {
                    %log.debug("data connection closed")
                    // Remove connection from list
                    setConnections(prev =>
                      prev->Belt.List.keep(
                        item => {
                          item->Peer.DataConnection.peer != peerConnection->Peer.DataConnection.peer
                        },
                      )
                    )
                  },
                ),
              )

              peerConnection->Peer.DataConnection.on(
                #error(
                  error => {
                    %log.error(
                      "data connection error"
                      ("error", error)
                    )
                  },
                ),
              )

              ()
            },
          ),
        )
      }
    }

    None
  }, (remoteHostId, handlePeerData))

  React.useEffect0(() => {
    let cleanup = () => {
      peer.current->Peer.destroy()
      setConnections(_ => list{})
    }

    Some(cleanup)
  })

  (peer.current, localPeerId, connections)
}
