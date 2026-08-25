# ConveyGrid Flutter SDK

Reusable **consent** SDK for Data Fiduciary Flutter apps. One package covers **Android and iOS**. LuxeStay is only a sample host; this SDK does not depend on LuxeStay screens, booking APIs, or LuxeStay notice codes.

Native Kotlin or Swift apps should keep using the native ConveyGrid SDKs. This package is for **Flutter** applications (including Flutter add-to-app inside an existing native shell).

## What you give an integrator

Ship the folder `packages/conveygrid_flutter_sdk` (this package). Do not ship `apps/luxestay_app` unless they want the demo.

Each integrator must get **their** values from ConveyGrid admin (same pairing as a working web or Swift app):

| Value | Purpose |
| --- | --- |
| `apiBaseUrl` | Host for that environment (`…apidev…` vs `…apiqa…`) |
| `applicationKey` | `X-Application-Key` for **their** application |
| `origin` / `referer` | Origins on that application’s allowlist (required on some hosts) |
| Cookie `configCode` | Their cookie banner code |
| Notice `noticeCode` | Their consent notice code |

Do not reuse another product’s key, origin, or notice code. Never commit or log the application key.

## Add the package

**Path (same repo or copied folder):**

```yaml
dependencies:
  conveygrid_flutter_sdk:
    path: packages/conveygrid_flutter_sdk
```

**Git (recommended for customers):**

```yaml
dependencies:
  conveygrid_flutter_sdk:
    git:
      url: https://github.com/YOUR_GITHUB_USERNAME/flutter-sdk.git
      ref: v0.1.0
```

Host apps may copy [`.env.example`](.env.example) into their own app as `.env` (never commit real keys). This SDK package does not load `.env` itself.

Then:

```bash
flutter pub get
```

`publish_to: none` is set until you publish to a private pub server. Do not publish this package to public pub.dev with customer keys inside.

## Android and iOS host app setup

The host app is a normal Flutter app. Minimums used by this SDK’s plugins:

- Android `minSdk` 21+
- iOS 12.0+
- Internet permission (Android default in Flutter)

No extra native Kotlin/Swift consent UI is required. Initialize from Dart.

### Android

In the host `android/app/src/main/AndroidManifest.xml`, keep internet enabled (Flutter template already has it).

### iOS

If you store subject identifiers in Keychain via this SDK’s session store, no extra Info.plist keys are required for anonymous session IDs. Add usage descriptions only if **your** app collects photos, location, etc.

## Initialize once

```dart
import 'package:conveygrid_flutter_sdk/conveygrid_flutter_sdk.dart';

final conveyGrid = ConveyGridClient(
  config: ConveyGridConfig(
    apiBaseUrl: 'https://your-conveygrid-host.example',
    applicationKey: applicationKey, // from secure config, not source control
    origin: 'https://your-allowed-origin.example',
    referer: 'https://your-allowed-origin.example/',
    sendOriginRefererHeaders: true,
    theme: const ConveyGridTheme(
      primaryColor: Color(0xFF2F64F5),
      secondaryColor: Color(0xFF0F172A),
    ),
  ),
);

final init = await conveyGrid.initialize();
if (init.isFailure) {
  // show init.failureOrNull?.message — do not print the key
}
```

Keep a single `ConveyGridClient` (for example in your DI container). Call `dispose()` when the process tears down.

## Cookie banner

```dart
ConveyGridCookieBanner(
  client: conveyGrid,
  configCode: yourCookieConfigCode,
  pageUrl: 'https://your-app.example/',
);
```

Gate analytics with `conveyGrid.isCategoryGranted(categoryCode)` using codes returned by **their** cookie config API, not hardcoded LuxeStay category names.

## Consent notice (before a business action)

```dart
final result = await conveyGrid.showConsentNotice(
  context,
  noticeCode: yourNoticeCode,
  subject: ConveyGridSubject(
    email: email,
    mobile: mobile,
    fullName: name,
  ),
  pageUrl: canonicalPageUrl,
);

final consent = result.valueOrNull;
if (consent == null || !consent.allMandatoryGranted) {
  return; // stop the business action
}

final created = await yourApi.createRecord(...);

if (consent.linkRequired) {
  await conveyGrid.linkReference(
    referenceId: created.id,
    artifactId: consent.artifactId,
    preferenceToken: consent.preferenceToken,
  );
}
```

You can also compose `ConveyGridConsentView`, `ConveyGridConsentBottomSheet`, or `ConveyGridConsentDialog`.

## Events and errors

```dart
conveyGrid.events.listen((event) {
  // ConsentLoaded, ConsentGranted, ConsentRejected, ConsentUpdated,
  // ConsentWithdrawn, ConsentFailed, CookiePreferencesUpdated
});
```

Events do not include email, mobile, or tokens. Methods return `Result<T>` (`Success` / `FailureResult`).

Typical host mismatches:

- Wrong `apiBaseUrl` for the key → invalid application key
- Missing or wrong `Origin` → origin not allowed
- Wrong `noticeCode` / `configCode` for that application → not found / validation error

## Reference app

`apps/luxestay_app` in this monorepo shows a full integration. Copy the **pattern** (init, banner, notice, link-reference). Replace every LuxeStay-specific code and URL with the integrator’s ConveyGrid application.

## License

See `LICENSE`.
# conveygrid-flutter-sdk
