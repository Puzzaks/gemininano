# Security Policy

## Supported Versions

The main compatibility concern comes from when Google will put AICore in the grave. No information leaks are possible via this component though.

Bear in mind, the app uses SharedPreferences plugin, which stores persistent data in plain text in the `/sdcard/Android/data/page.puzzak.gemininano/` - with root or adb access it is possible to get your previous conversation with Gemini, but nothing more.

## Reporting a Vulnerability

You can use Issues tab to report most issues, but if you feel like your issue is not publicly disclosable, you are more than welcome to send us your report to support@puzzak.page.
