open Hooks

module Trigger = {
  @module("element-visible") external elementVisible: Dom.element => bool = "default"

  @react.component
  let make = (~state: storageState, ~setRemoteHostId) => {
    let (isOpen, setIsOpen) = React.useState(() => false)
    let (input, setInput) = React.useState(() => "")
    let (isControlVisible, setIsControlVisible) = React.useState(() => false)
    let visibility = isControlVisible ? "opacity-100" : "opacity-0"

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
          className={`${visibility} transition-opacity duration-200 flex items-center gap-2 rounded-md bg-indigo-50 px-3 py-2 text-sm font-semibold text-indigo-600 shadow-sm hover:bg-indigo-100`}>
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
                  </div>
                }}
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
                  <button
                    type_="submit"
                    className="rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600">
                    {React.string("Connect")}
                  </button>
                </form>
              </div>
              <div className="inline-block overflow-hidden rounded-lg bg-white px-2 py-3 shadow">
                <p className="truncate text-xs font-medium text-gray-500">
                  {React.string("Currently connected")}
                </p>
                <p className="mt-1 text-xl font-semibold tracking-tight text-gray-900">
                  {React.string(Belt.Int.toString(state.connectedPeers))}
                </p>
              </div>
            </div>
          </div>
        </div>
      }}
    </>
  }
}

module Manager = {
  @react.component
  let make = (~setLocalHostId, ~syncConnectionsCountToStorage, ~remoteHostId, ~videoEl) => {
    let (_, localPeerId, connections) = usePeer(~remoteHostId, ~videoEl)
    let connectionsCount = connections->Belt.List.length

    React.useEffect2(() => {
      switch localPeerId {
      | Some(id) => setLocalHostId(id)
      | None => ()
      }

      None
    }, (localPeerId, setLocalHostId))

    React.useEffect1(() => {
      syncConnectionsCountToStorage(connectionsCount)

      None
    }, [connectionsCount])

    <> </>
  }
}

@react.component
let make = () => {
  let (state, setItem) = useStorage()
  let video = useVideo()

  switch video {
  | Some(el) =>
    <>
      <Manager
        videoEl={el}
        remoteHostId={state.remoteHostId}
        setLocalHostId={id => {
          setItem(SetLocalHostId(id))
        }}
        syncConnectionsCountToStorage={connectionsCount => {
          setItem(SetConnectedPeers(connectionsCount))
        }}
      />
      <Trigger
        state={state}
        setRemoteHostId={id => {
          setItem(SetRemoteHostId(id))
        }}
      />
    </>

  | None => <> </>
  }
}
