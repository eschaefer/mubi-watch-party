open Hooks

@val @scope(("navigator", "clipboard"))
external writeText: string => unit = "writeText"

module LinkIcon = {
  @react.component
  let make = () => {
    <svg
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
      viewBox="0 0 24 24"
      strokeWidth="1.5"
      stroke="currentColor"
      className="w-4 h-4">
      <path
        strokeLinecap="round"
        strokeLinejoin="round"
        d="M13.19 8.688a4.5 4.5 0 011.242 7.244l-4.5 4.5a4.5 4.5 0 01-6.364-6.364l1.757-1.757m13.35-.622l1.757-1.757a4.5 4.5 0 00-6.364-6.364l-4.5 4.5a4.5 4.5 0 001.242 7.244"
      />
    </svg>
  }
}

module Trigger = {
  @module("element-visible") external elementVisible: Dom.element => bool = "default"

  @react.component
  let make = (~state, ~setRemoteHostId, ~reset, ~setLocalHostId, ~setErrorMessage) => {
    let (peer, localPeerId, connections) = usePeer(
      ~remoteHostId=state.remoteHostId,
      ~setErrorMessage,
    )
    let (isOpen, setIsOpen) = React.useState(() => false)
    let (input, setInput) = React.useState(() => "")
    let (isControlVisible, setIsControlVisible) = React.useState(() => false)
    let (copied, setCopied) = React.useState(() => false)
    let localHostId = state.localHostId
    let connectionCount = connections->Belt.List.length

    let visibility = isControlVisible ? "opacity-100" : "opacity-0"
    let connected =
      connectionCount > 0
        ? "text-emerald-600 bg-emerald-50 hover:bg-emerald-100"
        : "text-indigo-600 bg-indigo-50 hover:bg-indigo-100"

    React.useEffect1(() => {
      switch localPeerId {
      | Some(id) => setLocalHostId(id)
      | None => ()
      }

      None
    }, [localPeerId])

    React.useEffect1(() => {
      // For links shared with a party ID, set the ID as the remote host ID
      let id = Utils.getPartyId()

      %log.debug(
        "Params check"
        ("id", id)
      )

      switch (id, localHostId) {
      | (Some(id), Some(_)) => setRemoteHostId(id)
      | _ => ()
      }

      None
    }, [localHostId])

    // Interval to observe if the control bar is visible or not
    React.useEffect0(() => {
      let interval = ref(Js.Nullable.null)

      let cancelInterval = () =>
        Js.Nullable.iter(interval.contents, (. intervalId) => Js.Global.clearInterval(intervalId))

      let checkControlVisibility = () => {
        switch Utils.getNestedControlEl() {
        | Some(el) =>
          switch elementVisible(el) {
          | true => setIsControlVisible(_ => true)
          | false => setIsControlVisible(_ => false)
          }
        | None => setIsControlVisible(_ => false)
        }
      }

      interval := Js.Nullable.return(Js.Global.setInterval(checkControlVisibility, 500))

      checkControlVisibility()

      Some(cancelInterval)
    })

    <>
      <div className="fixed z-10 bottom-0 left-1/2 -translate-x-1/2 h-[65px] flex items-center">
        <button
          onClick={_ => setIsOpen(_ => true)}
          className={`${visibility} ${connected} transition-opacity duration-200 flex items-center gap-2 rounded-md px-3 py-2 text-sm font-semibold shadow-sm`}>
          <GroupIcon className="w-4 h-4" />
          <span> {React.string("Watch Party")} </span>
        </button>
      </div>
      {switch isOpen {
      | false => <> </>
      | true =>
        <div className="fixed inset-0 z-10 w-screen overflow-y-auto bg-gray-500 bg-opacity-50">
          <div
            className="flex min-h-full items-end justify-center p-4 text-center sm:items-center sm:p-0">
            <div
              className="overflow-hidden rounded-lg bg-white px-4 pb-4 pt-5 text-left shadow-xl sm:my-8 sm:w-full sm:max-w-md">
              <div className="flex w-full justify-between">
                <Header />
                <button onClick={_ => setIsOpen(_ => false)}>
                  <svg
                    fill="none"
                    viewBox="0 0 24 24"
                    strokeWidth="1.5"
                    stroke="currentColor"
                    className="w-6 h-6">
                    <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>
              <div className="py-4">
                {switch state.localHostId {
                | None => <> </>
                | Some(id) =>
                  <div className="pb-4">
                    <p className="font-medium text-gray-900"> {React.string("Your ID is")} </p>
                    <p className="font-semibold font-mono"> {React.string(id)} </p>
                    <button
                      className="mt-2"
                      onClick={_ => {
                        // Get current player URL, and append id as a query param
                        let url = Utils.getPageUrl()
                        let urlWithId = url ++ "?party=" ++ id
                        writeText(urlWithId)
                        setCopied(_ => true)
                        let _ = Js.Global.setTimeout(() => {
                          setCopied(_ => false)
                        }, 3000)
                      }}>
                      <div className="flex gap-2 items-center font-semibold">
                        <LinkIcon />
                        {switch copied {
                        | true => <span> {React.string("Copied!")} </span>
                        | false => <span> {React.string("Copy link to share")} </span>
                        }}
                      </div>
                    </button>
                  </div>
                }}
                {switch connectionCount > 0 {
                | true =>
                  <button
                    onClick={_ => {
                      %log.debug(
                        "Disconnecting all connections"
                        ("connections", connections)
                      )
                      connections->Belt.List.forEach(connection => {
                        connection->Peer.DataConnection.close()
                      })
                    }}
                    className="rounded-md bg-white px-3.5 py-2.5 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50">
                    {React.string("Disconnect")}
                  </button>
                | false =>
                  <form
                    onSubmit={event => {
                      ReactEvent.Form.preventDefault(event)
                      setRemoteHostId(input)
                    }}>
                    <label htmlFor="peerid" className="block font-medium leading-6 text-gray-900">
                      {React.string("Connect to another ID")}
                    </label>
                    <div className="mt-2 pb-2">
                      <input
                        onChange={event => setInput(_ => ReactEvent.Form.target(event)["value"])}
                        type_="text"
                        name="peerid"
                        autoComplete="off"
                        id="peerid"
                        placeholder="Get this ID from another user"
                        className="block w-full rounded-md border-0 py-1.5 px-2 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6"
                      />
                    </div>
                    <div className="flex gap-3">
                      <button
                        type_="submit"
                        className="rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600">
                        {React.string("Connect")}
                      </button>
                    </div>
                  </form>
                }}
              </div>
              <div className="inline-block overflow-hidden rounded-lg bg-white px-2 py-3 shadow">
                <p className="truncate text-xs font-medium text-gray-500">
                  {React.string("Currently connected")}
                </p>
                <p className="mt-1 text-xl font-semibold tracking-tight text-gray-900">
                  {React.string(Belt.Int.toString(connectionCount))}
                </p>
              </div>
              {switch state.errorMessage {
              | None => <> </>
              | Some(msg) => <Alert> {React.string(msg)} </Alert>
              }}
            </div>
          </div>
        </div>
      }}
    </>
  }
}

@react.component
let make = () => {
  let (state, dispatch) = useLocalState()
  let video = useVideo()

  switch video {
  | true =>
    <Trigger
      state={state}
      setErrorMessage={msg => {
        dispatch(ErrorMessage(msg))
      }}
      setRemoteHostId={id => {
        dispatch(SetRemoteHostId(id))
      }}
      setLocalHostId={id => {
        dispatch(SetLocalHostId(id))
      }}
      reset={_ => dispatch(Reset)}
    />

  | false => <> </>
  }
}
