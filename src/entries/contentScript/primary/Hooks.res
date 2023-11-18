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

type localState = {
  localHostId: option<string>,
  remoteHostId: option<string>,
  localHostTime: float,
}

let initialLocalState = {
  localHostId: None,
  remoteHostId: None,
  localHostTime: 0.0,
}

let localStateReducer = (state, action) => {
  @log
  switch action {
  | Reset => initialLocalState
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

let usePeer = (~remoteHostId) => {
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

    Some(
      () => {
        videoEl->Element.removeEventListener("play", handlePlay)
        videoEl->Element.removeEventListener("pause", handlePause)
        // videoEl->Element.removeEventListener("seeked", handleSeek)
        // videoEl->Element.removeEventListener("timeupdate", throttledHandleTimeUpdate)
      },
    )
  }, [emitToPeers])

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
