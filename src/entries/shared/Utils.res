open Webapi.Dom

let getPageTitle = () =>
  switch document->Document.asHtmlDocument {
  | Some(doc) => doc->HtmlDocument.title->Js.String2.split("|")->Array.get(0)->Js.String2.trim
  | None => failwith("No document")
  }

let getPageUrl = () => location->Location.href

let getVideoEl = () => {
  document->Document.querySelector(".video-player video")
}

let getNestedControlEl = () => {
  document->Document.querySelector("div[title='Enter full screen']")
}
