fastlane documentation
================
# Installation
```
sudo gem install fastlane
```
# Available Actions
## iOS
### ios test
```
fastlane ios test
```
Runs all the tests
### ios beta_build
```
fastlane ios beta_build
```
Submit a new beta build to TestFlight.

This will also make sure the profile is up to date.
### ios beta_patch
```
fastlane ios beta_patch
```
This bumps the version one patch, sets the build number to 1, and submits a new beta build to TestFlight.

This will also make sure the profile is up to date.
### ios beta_minor
```
fastlane ios beta_minor
```
This bumps the version one patch, sets the build number to 1, and submits a new beta build to TestFlight.

This will also make sure the profile is up to date.

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [https://fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [GitHub](https://github.com/fastlane/fastlane/tree/master/fastlane).
