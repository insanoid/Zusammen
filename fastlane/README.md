fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
### setup
```
fastlane setup
```
Initalise the project.
### lint
```
fastlane lint
```
Does a static analysis of the project. Configure the options in .swiftlint.yml
### format
```
fastlane format
```
Run swiftformat and format all the files.
### synx
```
fastlane synx
```
Synx to format the folder structure to be idendical between file-system and xcode project.
### doc
```
fastlane doc
```
Generate the documentation for the project.
### check
```
fastlane check
```
Run checks for liniting, formatting, folder structure - all in one go.
### cov
```
fastlane cov
```
Generates coverage for the project using xcov.
### podcheck
```
fastlane podcheck
```
Validates the pod file and find if there are any updates.
### bump_version
```
fastlane bump_version
```
Bump the version number of the app, only the minor version.

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
