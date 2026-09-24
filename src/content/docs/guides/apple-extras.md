---
title: Apple extras
description: Attachments, the App Store rating prompt, and funnel analytics in the Swift SDK.
---

The Swift SDK does a few things the Android and Web SDKs don't do yet. Each one is optional.

## Attachments

On iOS, `FeedbackSheet` has an **Add** button. It offers **Photo Library** (a screenshot is usually there) or **Files**. On other platforms it opens the file picker directly. Photos are converted from HEIC to JPEG, and their EXIF and GPS data is removed before upload.

Without the sheet, pass attachments on the report yourself:

```swift
let report = FeedbackReport(
  type: .bug,
  title: "Crash on launch",
  description: "Steps to reproduce…",
  attachments: [FeedbackAttachment(filename: "log.txt", mimeType: "text/plain", data: logData)]
)
```

Limits (`FeedbackAttachmentValidator`): **3 files** per report, **5 MB** per file, **10 MB** in total. Allowed types are PNG, JPEG, HEIC, GIF, plain text, JSON and PDF. The limits are public constants (`maxCount`, `maxFileBytes`, `maxTotalBytes`), so your own picker can use the same numbers.

:::caution[Direct transport only]
Only `GitHubDirectTransport` uploads attachments. `RelayTransport` sends the report without them.
:::

## App Store rating prompt

A user may send pure praise, like "love this app". When that happens, `FeedbackSheet` follows the successful submission with the system rating prompt. Apple Intelligence decides what counts as praise, on the device (Foundation Models, iOS/macOS/visionOS 26+). Any mention of a bug, complaint, question or request counts as not praise.

The report is always submitted first. The check can't affect it. If the model isn't available, isn't sure, or takes too long, no prompt appears. To turn the prompt off:

```swift
FeedbackSheet(client: feedback, requestsAppStoreReview: false)
```

watchOS and tvOS have no rating prompt, so this does nothing there.

## Analytics

Conform to `FeedbackAnalytics` and give it to the client. It then sees the whole feedback funnel: the sheet opening, type changes, attachments added or rejected, validation blocks, submissions starting, succeeding and failing, cancels, and rating-prompt decisions.

```swift
struct MyAnalytics: FeedbackAnalytics {
  func record(_ event: FeedbackEvent) {
    Analytics.logEvent(event.name, parameters: event.parameters)
  }
}

let feedback = FeedbackClient(appName: "Acme", transport: transport, analytics: MyAnalytics())
```

`event.name` and `event.parameters` already fit Firebase, Mixpanel, Amplitude, PostHog and TelemetryDeck. Events never include user content: a failure reports a stable `error_kind`, not the error message. Set the analytics object on the client only. `FeedbackSheet` has no analytics parameter, because a sheet-only object would never see submission events.

See the [DocC Analytics article](../../reference/swift/documentation/lovelettercore/analytics/) for every event name and parameter.
