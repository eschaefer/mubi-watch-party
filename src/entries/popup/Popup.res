module PlayerPageUI = {
  @react.component
  let make = (~resetEnv, ~setRemoteHostId, ~remoteHostId) => {
    let (input, setInput) = React.useState(_ => "")

    <div>
      {switch remoteHostId {
      | None =>
        <form
          onSubmit={event => {
            ReactEvent.Form.preventDefault(event)
            setRemoteHostId(input)
          }}>
          <label>
            {React.string("Enter host ID")}
            <input
              type_="text"
              value={input}
              onChange={event => {
                setInput(_ => {
                  ReactEvent.Form.target(event)["value"]->Js.String2.trim
                })
              }}
            />
          </label>
          <button type_="submit"> {React.string("Connect")} </button>
        </form>
      | Some(_) => <div> {React.string("Connected to remote host")} </div>
      }}
      <button
        onClick={_ => {
          resetEnv()
        }}>
        {React.string("Reset")}
      </button>
    </div>
  }
}

@react.component
let make = () => {
  let (isOnPlayerPage, setIsOnPlayerPage) = React.useState(_ => false)

  let getMubiTab = React.useCallback0(async () => {
    let tabs = await Browser.Tabs.query({active: true, currentWindow: true})
    %log.debug(
      "Got tabs"
      ("tabs", tabs)
    )

    let mubiPlayerTab = tabs->Js.Array2.find(tab => {
      tab.url->Js.String2.startsWith("https://mubi.com") && tab.url->Js.String2.endsWith("/player")
    })

    switch mubiPlayerTab {
    | Some(_) => setIsOnPlayerPage(_ => true)
    | None => setIsOnPlayerPage(_ => false)
    }
  })

  React.useEffect1(() => {
    let _ = getMubiTab()

    // Also keep checking that we have a mubi tab
    let intervalId = Js.Global.setInterval(() => {
      let _ = getMubiTab()
    }, 500)

    Some(
      () => {
        Js.Global.clearInterval(intervalId)
      },
    )
  }, [getMubiTab])

  <main className="p-4 w-80">
    <div className="pb-2">
      <Header />
    </div>
    <div className="pb-2">
      <div className="rounded-md bg-blue-50 p-4">
        <div className="flex text-blue-600">
          <div className="flex-shrink-0 ">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              strokeWidth="1.5"
              stroke="currentColor"
              className="h-5 w-5">
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                d="M11.25 11.25l.041-.02a.75.75 0 011.063.852l-.708 2.836a.75.75 0 001.063.853l.041-.021M21 12a9 9 0 11-18 0 9 9 0 0118 0zm-9-3.75h.008v.008H12V8.25z"
              />
            </svg>
          </div>
          <div className="ml-3 flex-1 md:flex md:justify-between">
            <p className="text-sm">
              {React.string(
                "When on a movie player page, look for the Watch Party button near the video controls.",
              )}
            </p>
            <p className="mt-3 text-sm md:ml-6 md:mt-0" />
          </div>
        </div>
      </div>
    </div>
    {switch isOnPlayerPage {
    | false => <Alert> {React.string("You are not on a Mubi video player page.")} </Alert>
    | true => <> </>
    }}
  </main>
}
