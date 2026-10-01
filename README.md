# Concurrent Resource Loader

This repository contains an example iOS app that demonstrates a Swift
concurrency resource loader. It safely deduplicates simultaneous network
requests, caches successful responses, and cleans up failed in-flight work so
later retries can run normally.

## Project

The implementation lives in the `ResourceLab` Xcode project.

- `ResourceLoader` is an `actor` that owns the product cache and the in-flight
  request registry.
- `APIClient` fetches product data from the DummyJSON API.
- `ProductViewModel` drives the SwiftUI view with async loading states.
- `ProductView` provides a small UI for loading one product, loading the same
  product five times concurrently, and clearing the cache.
- `MockAPIClient` supports previews and tests without hitting the network.

## What it demonstrates

- Actor isolation for shared mutable state.
- Response caching for repeated product and product-list requests.
- Task coalescing so concurrent calls for the same resource await the same
  underlying request.
- Failure cleanup so a failed request is removed from the in-flight task store.
- SwiftUI integration through a main-actor observable view model.

## API configuration

The app reads its API host from Xcode configuration files:

- `ResourceLab/ResourceLab/configuration/Debug.xcconfig`
- `ResourceLab/ResourceLab/configuration/Release.xcconfig`

Both configurations currently point to:

```text
https://dummyjson.com
```

## Running the app

1. Open `ResourceLab/ResourceLab.xcodeproj` in Xcode.
2. Select the `ResourceLab` scheme.
3. Run the app on an iOS simulator.
4. Enter a product ID and use:
   - `Load Product` to fetch a single product.
   - `Load Same Product 5x` to exercise concurrent request coalescing.
   - `Clear Cache` to reset cached results.

## Tests

The test suite covers the loader's core behavior:

- Loading the same product twice uses the cache.
- Clearing the cache causes the product to be fetched again.
- Concurrent requests for the same product share one fetch.
- A failed request can be retried.

Run the tests from Xcode with `Product > Test`, or from the command line with:

```sh
xcodebuild test -project ResourceLab/ResourceLab.xcodeproj -scheme ResourceLab -destination 'platform=iOS Simulator,name=iPhone 16'
```
