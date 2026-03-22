# Codemagic CI/CD Troubleshooting Guide

## Setup Summary
- **CI/CD**: Codemagic
- **App**: milk-count (Flutter iOS)
- **Bundle ID**: `com.milkcount.app`
- **API Key Integration**: Avolution Tech
- **Distribution**: App Store (TestFlight)

---

## Issue 1: "No matching profiles found for bundle identifier and distribution type app_store"

**Error**: `No matching profiles found for bundle identifier "com.milkcount.app" and distribution type "app_store"`

**Cause**: Codemagic can't find a provisioning profile for the bundle ID.

**Checklist**:
1. **Register the App ID** in Apple Developer Portal → Certificates, Identifiers & Profiles → Identifiers. Ensure `com.milkcount.app` exists.
2. **Do NOT use `ios_signing` in the `environment` section** of `codemagic.yaml`. This causes Codemagic to check for profiles *before* scripts run, and it will fail if no profile exists yet.
3. **Use `fetch-signing-files --create` in the scripts** instead — this auto-creates the provisioning profile:
   ```yaml
   - name: Set up code signing
     script: |
       keychain initialize
       app-store-connect fetch-signing-files "$BUNDLE_ID" \
         --type IOS_APP_STORE \
         --create
       keychain add-certificates
       xcode-project use-profiles
   ```

**Fix applied**: Removed `ios_signing` block from `environment` and added `--create` flag to `fetch-signing-files` in the script step.

---

## Issue 2: "No valid code signing certificates were found" / "No development certificates available"

**Error**: Build step fails with `No valid code signing certificates were found` even though "Set up code signing" step passed.

**Cause**: The `xcode-project use-profiles` command sets up profiles, but the export options plist (needed by `flutter build ipa`) wasn't generated before the build.

**Fix**: Generate the export options plist in the signing step, *before* the build:
```yaml
- name: Set up code signing
  script: |
    keychain initialize
    app-store-connect fetch-signing-files "$BUNDLE_ID" \
      --type IOS_APP_STORE \
      --create
    keychain add-certificates
    xcode-project use-profiles
    xcode-project use-profiles --export-options-plist=/Users/builder/export_options.plist
- name: Build iOS release
  script: |
    flutter build ipa --release \
      --build-number=$PROJECT_BUILD_NUMBER \
      --export-options-plist=/Users/builder/export_options.plist
```

---

## Issue 3: "No valid code signing certificates" even after signing step passes

**Error**: "Set up code signing" step succeeds, but "Build iOS release" fails with:
```
No valid code signing certificates were found
No development certificates available to code sign app for device deployment
```

**Cause**: `flutter build ipa --export-options-plist=...` still tries to resolve signing during the Xcode build phase *before* applying the export options. The export plist only controls the *export* step, not the *archive* step.

**Fix**: Split the build into two steps — use `flutter build ios` (which builds the archive using profiles set by `xcode-project use-profiles`) then use Codemagic's `xcode-project build-ipa` to package and sign:

```yaml
- name: Build iOS release
  script: |
    flutter build ios --release \
      --build-number=$PROJECT_BUILD_NUMBER
    xcode-project build-ipa \
      --workspace ios/Runner.xcworkspace \
      --scheme Runner
```

**Why this works**: `xcode-project use-profiles` (from the signing step) configures the Xcode project's signing settings. `flutter build ios` respects those settings. Then `xcode-project build-ipa` handles archiving and exporting with the correct distribution profile.

---

## Issue 4: Wrong integration name

**Error**: Build fails because the App Store Connect integration name in `codemagic.yaml` doesn't match what's configured in Codemagic.

**How to check**: Go to Codemagic → your app → Settings → Distribution → Manage keys. Note the exact name (e.g., "Avolution Tech").

**Fix**: Update `codemagic.yaml`:
```yaml
integrations:
  app_store_connect: Avolution Tech  # Must match exactly
```

---

## Apple Developer Portal Checklist

Before building, ensure these exist in [Apple Developer Portal](https://developer.apple.com/account/resources):

| Item | Where | Required |
|------|-------|----------|
| App ID (`com.milkcount.app`) | Identifiers | Yes — create manually |
| Distribution Certificate | Certificates | Yes — Codemagic auto-creates via API key |
| App Store Provisioning Profile | Profiles | Auto-created by `--create` flag |

---

## GitHub → Codemagic Workflow

1. Push changes to `claude/flutter-milk-tracker-app-BWxZF` branch
2. Create PR on GitHub: **base: `main`** ← **compare: `claude/flutter-milk-tracker-app-BWxZF`**
3. Merge the PR
4. Codemagic auto-triggers on push to `main` (or manually start build)
5. Build signs the app and uploads to TestFlight

---

## Quick Reference: Full Working codemagic.yaml Signing Config

```yaml
workflows:
  ios-release:
    integrations:
      app_store_connect: Avolution Tech
    environment:
      flutter: stable
      xcode: latest
      cocoapods: default
      # NOTE: Do NOT add ios_signing here — handle in scripts instead
      vars:
        BUNDLE_ID: "com.milkcount.app"
    scripts:
      - name: Set up code signing
        script: |
          keychain initialize
          app-store-connect fetch-signing-files "$BUNDLE_ID" \
            --type IOS_APP_STORE \
            --create
          keychain add-certificates
          xcode-project use-profiles
          xcode-project use-profiles --export-options-plist=/Users/builder/export_options.plist
      - name: Build iOS release
        script: |
          flutter build ios --release \
            --build-number=$PROJECT_BUILD_NUMBER
          xcode-project build-ipa \
            --workspace ios/Runner.xcworkspace \
            --scheme Runner
```
