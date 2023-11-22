open Webapi.Dom

@send external play: Dom.element => unit = "play"
@send external pause: Dom.element => unit = "pause"
@get external duration: Dom.element => int = "duration"
@get external currentTime: Dom.eventTarget => float = "currentTime"
@set external setCurrentTime: (Dom.element, float) => unit = "currentTime"

type timestamp = float

type currentFilm = {
  title: string,
  url: string,
}

type transmittableAction =
  Film(currentFilm) | Play(timestamp) | Pause(timestamp) | TimeUpdate(timestamp)

type localAction =
  | Reset
  | LocalHostTime(float)
  | SetLocalHostId(string)
  | SetRemoteHostId(string)
  | ErrorMessage(string)

type localState = {
  localHostId: option<string>,
  remoteHostId: option<string>,
  localHostTime: float,
  errorMessage: option<string>,
}

let initialLocalState = {
  localHostId: None,
  remoteHostId: None,
  localHostTime: 0.0,
  errorMessage: None,
}

let localStateReducer = (state, action) => {
  @log
  switch action {
  | Reset => {
      ...state,
      remoteHostId: None,
      localHostTime: 0.0,
    }
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
  | ErrorMessage(message) => {
      ...state,
      errorMessage: Some(message),
    }
  }
}

let useLocalState = () => {
  let (state, dispatch) = React.useReducer(localStateReducer, initialLocalState)

  (state, dispatch)
}

let useVideo = () => {
  let (hasVideoEl, setHasVideoEl) = React.useState(() => false)

  // Get video element from page
  React.useEffect0(() => {
    let interval = ref(Js.Nullable.null)

    let cancelInterval = () =>
      Js.Nullable.iter(interval.contents, (. intervalId) => Js.Global.clearInterval(intervalId))

    let checkVideoEl = () => {
      switch Utils.getVideoEl() {
      | Some(el) =>
        if el->duration > 60 {
          setHasVideoEl(_ => true)
        } else {
          %log.debug("Video element probably an ad")
          setHasVideoEl(_ => false)
        }
      | None => setHasVideoEl(_ => false)
      }
    }

    interval := Js.Nullable.return(Js.Global.setInterval(checkVideoEl, 500))

    Some(cancelInterval)
  })

  hasVideoEl
}

let usePeer = (~remoteHostId, ~setErrorMessage) => {
  let peer = React.useRef(Peer.makePeer((), ~config={debug: 2, secure: true}))
  let (localPeerId, setLocalPeerId) = React.useState(() => None)
  let (connections, setConnections) = React.useState(() => list{})
  let (currentFilm, setCurrentFilm) = React.useState(() => None)
  let firstIncomingDataFromHostRef = React.useRef(false)

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

  // When first data is received from remote, set video time to match
  let handleFirstDataFromRemote = React.useCallback0(data => {
    switch (firstIncomingDataFromHostRef.current, data) {
    | (false, TimeUpdate(timestamp)) => {
        firstIncomingDataFromHostRef.current = true
        switch Utils.getVideoEl() {
        | Some(el) => {
            el->setCurrentTime(timestamp)
            el->play
          }
        | None => failwith("Can't sync time without video element")
        }
      }
    | _ => ()
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
  React.useEffect1(() => {
    let videoEl = switch Utils.getVideoEl() {
    | Some(el) => el
    | None => failwith("Video element went missing")
    }

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
    // videoEl->Element.addEventListener("seeked", handleSeek)
    videoEl->Element.addEventListener("timeupdate", throttledHandleTimeUpdate)

    Some(
      () => {
        videoEl->Element.removeEventListener("play", handlePlay)
        videoEl->Element.removeEventListener("pause", handlePause)
        // videoEl->Element.removeEventListener("seeked", handleSeek)
        videoEl->Element.removeEventListener("timeupdate", throttledHandleTimeUpdate)
      },
    )
  }, [emitToPeers])

  React.useEffect2(() => {
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
                      connection->Peer.DataConnection.on(#data(handleFirstDataFromRemote))

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
  }, (handlePeerData, handleFirstDataFromRemote))

  // When remoteHostId is provided, connect to that peer
  React.useEffect3(() => {
    // Only after local id is available.
    switch (localPeerId, remoteHostId) {
    | (Some(_), Some(remoteHostId)) =>
      try {
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
      } catch {
      | _ => {
          %log.error("Failed to connect to peer")
          setErrorMessage("Failed to connect to peer")
        }
      }
    | _ => ()
    }

    None
  }, (remoteHostId, handlePeerData, localPeerId))

  React.useEffect0(() => {
    let cleanup = () => {
      peer.current->Peer.destroy()
      setConnections(_ => list{})
    }

    Some(cleanup)
  })

  (peer.current, localPeerId, connections)
}
