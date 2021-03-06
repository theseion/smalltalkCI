# smalltalkCI [![Build Status][travis_b]][travis_url] [![AppVeyor status][appveyor_b]][appveyor_url] [![Coverage Status][coveralls_b]][coveralls_url]

Community-supported framework for testing Smalltalk projects on Linux, OS X, and
Windows with built-in support for [Travis CI][travisCI] and
[AppVeyor][appveyor].

It is inspired by [builderCI][builderCI] and aims to provide a uniform and easy
way to load and test Smalltalk projects.


## Table Of Contents

- [Features](#features)
- [How to enable Travis CI for your Smalltalk project](#how-to-travis)
- [How to test your Smalltalk project locally](#how-to-local)
- [List Of Supported Images](#images)
- [Templates](#templates)
- [Further Configuration](#further-configuration)
- [Contributing](#contributing)
- [Projects using smalltalkCI](#projects-using-smalltalkci)


## Features

- Simple configuration via `.smalltalk.ston`, `.travis.yml`, and `appveyor.yml`
  ([see below for templates](#templates))
- Compatible across different Smalltalk dialects (Squeak, Pharo, GemStone)
- Runs on Travis' [container-based infrastructure][cbi]
  ([*"Builds start in seconds"*][bsis])
- Supports Linux, macOS, and Windows and can be run locally (e.g. for debug purposes)
- Exports test results in the JUnit XML format as part of the Travis build log
- Supports coverage testing and publishes results to [coveralls.io][coveralls]


<a name="how-to-travis"/>
## How To Enable Travis CI For Your Smalltalk Project

1. Export your project in a [compatible format](#load-specs).
2. [Enable Travis CI for your repository][travisHowTo].
3. Create a `.travis.yml` and specifiy the [Smalltalk image(s)](#images) you
   want your project to be tested against.
4. Create a `.smalltalk.ston` ([see below for templates](#templates)) and
   specify how to load and test your project.
5. Push all of this to GitHub and enjoy your fast Smalltalk builds!


<a name="how-to-local"/>
## How To Test Your Smalltalk Project Locally

You can use smalltalkCI to run your project's tests locally. Just [clone][clone]
or [download][download] smalltalkCI and then you are able to initiate a local
build in headfull-mode like this:

```bash
/path/to/smalltalkCI/run.sh --headfull /path/to/your/projects/.smalltalk.ston
```

`IMAGE` can be one of the [supported images](#images). You may also want to
have a look at [all supported options](#further-configuration).

*Please note: All builds will be stored in `_builds` within smalltalkCI's
directory. You may want to delete single or all builds if you don't need them as
they can take up a lot of space on your drive.*


<a name="images"/>
## List Of Supported Images

| Squeak          | Pharo             | GemStone             | Others          |
| --------------- | ----------------- | -------------------- | --------------- |
| `Squeak-trunk`  | `Pharo-alpha`     | `GemStone-3.3.x`     | `Moose-6.0`     |
| `Squeak-5.1`    | `Pharo-stable`    | `GemStone-3.2.x`     |                 |
| `Squeak-5.0`    | `Pharo-6.0`       | `GemStone-3.1.0.x`   |                 |
| `Squeak-4.6`    | `Pharo-5.0`       | `Gemstone-2.4.x`     |                 |
| `Squeak-4.5`    | `Pharo-4.0`       |                      |                 |
|                 | `Pharo-3.0`       |                      |                 |
|                 |                   |                      |                 |


<a name="templates"/>
## Templates

### Minimal `.smalltalk.ston` Template

The following `SmalltalkCISpec` will load `BaselineOfMyProject` using
Metacello/FileTree from the `./packages` directory in Squeak, Pharo, and
GemStone. See below how you can [customize your `SmalltalkCISpec`.]
(#SmalltalkCISpec)

```javascript
SmalltalkCISpec {
  #loading : [
    SCIMetacelloLoadSpec {
      #baseline : 'MyProject',
      #directory : 'packages',
      #platforms : [ #squeak, #pharo, #gemstone ]
    }
  ]
}
```

### `.travis.yml` Template

```yml
language: smalltalk
sudo: false

# Select operating system(s)
os:
  - linux
  - osx

# Select compatible Smalltalk image(s)
smalltalk:
  - Squeak-trunk
  - Squeak-5.1
  - Squeak-5.0
  - Squeak-4.6
  - Squeak-4.5

  - Pharo-alpha
  - Pharo-stable
  - Pharo-6.0
  - Pharo-5.0
  - Pharo-4.0
  - Pharo-3.0

  - GemStone-3.3.0
  - GemStone-3.2.12
  - GemStone-3.1.0.6

# Uncomment to enable dependency caching - especially useful for GemStone builds (3x faster)
#cache:
#  directories:
#    - $SMALLTALK_CI_CACHE
```

### `.travis.yml` Template With Multiple Configurations

```yml
language: smalltalk
sudo: false

# Select operating system(s)
os: linux

# Select compatible Smalltalk image(s)
smalltalk:
  - Pharo-alpha
  - Pharo-stable

# Loads `.smalltalk.ston` (if it exists), `myconfig1.ston` and `myconfig2.ston`
# **for each build step defined above**:
smalltalk_config:
  - myconfig1.ston
  - myconfig2.ston
```

### `.travis.yml` Template With Matrix Configuration

```yml
language: smalltalk
sudo: false

# Select operating system(s)
os: linux

# Select compatible Smalltalk image(s)
smalltalk:
  - Pharo-alpha
  - Pharo-stable

# Add two **additional** build steps
# The build steps from above will be run as before with `.smalltalk.ston` (the build will fail if `.smalltalk.ston` is not available). If you don't want the default build step to execute, simply remove everything before the `matrix:`.
# See https://docs.travis-ci.com/user/customizing-the-build/#Build-Matrix.
# Loads `.bleedingEdge.ston ` only:
matrix:
  include:
    - smalltalk: Pharo-alpha
      smalltalk_config: .bleedingEdge.ston
      os: linux
    - smalltalk: Pharo-alpha
      smalltalk_config: .bleedingEdge.ston
      os: osx
  allow_failures:
    - smalltalk_config: .bleedingEdge.ston
```

<details>
<summary>Build matrix for multiple Metacello versions and groups</summary>
```yml
matrix:
  include:
    # Squeak-trunk-> stable
    - smalltalk: Squeak-trunk
      smalltalk_config: .stable-default.ston
      os: linux
    # Squeak-5.1 -> stable
    - smalltalk: Squeak-5.1
      smalltalk_config: .stable-default.ston
      os: linux
    - smalltalk: Squeak-5.1
      smalltalk_config: .stable-default.ston
      os: osx
    # Pharo-alpha -> bleedingEdge
    - smalltalk: Pharo-alpha
      smalltalk_config: .bleedingedge-corewithextras.ston
      os: linux
    # Pharo-5.0 -> stable
    - smalltalk: Pharo-5.0
      smalltalk_config: .stable-default.ston
      os: linux
    - smalltalk: Pharo-5.0
      smalltalk_config: .stable-default.ston
      os: osx
```

#### The configuration for `.bleedingedge-corewithextras.ston` may look like this:

```javascript
SmalltalkCISpec {
  #loading : [
    SCIMetacelloLoadSpec {
      #configuration : 'Fuel',
      #repository : 'http://smalltalkhub.com/mc/...',
      #load : [ 'CoreWithExtras' ],
      #platforms : [
        #pharo ],
      #version : #bleedingEdge
    }
  ],
  #testing : {
    #categories : [ 'MyTests*' ]
  }
}
```
</details>

### `appveyor.yml` Template

```yml
environment:
  CYG_ROOT: C:\cygwin
  CYG_BASH: C:\cygwin\bin\bash
  CYG_CACHE: C:\cygwin\var\cache\setup
  CYG_EXE: C:\cygwin\setup-x86.exe
  CYG_MIRROR: http://cygwin.mirror.constant.com
  SCI_RUN: /cygdrive/c/smalltalkCI-master/run.sh
  matrix:
    # Currently, only Squeak and Pharo images are supported on AppVeyor.
    - SMALLTALK: Squeak-trunk
    - SMALLTALK: Squeak-5.0
    - SMALLTALK: Pharo-6.0
    - SMALLTALK: Pharo-5.0
    # ...

platform:
  - x86

install:
  - '%CYG_EXE% -qnNdO -R "%CYG_ROOT%" -s "%CYG_MIRROR%" -l "%CYG_CACHE%" -P unzip'
  - ps: Start-FileDownload "https://github.com/hpi-swa/smalltalkCI/archive/master.zip" "C:\smalltalkCI.zip"
  - 7z x C:\smalltalkCI.zip -oC:\ -y > NULL

build: false

test_script:
  - '%CYG_BASH% -lc "cd $APPVEYOR_BUILD_FOLDER; exec 0</dev/null; $SCI_RUN"'
```

<details>
  <summary>Build matrix for multiple Metacello versions and groups</summary>
```yml
environment:
  CYG_ROOT: C:\cygwin
  CYG_BASH: C:\cygwin\bin\bash
  CYG_CACHE: C:\cygwin\var\cache\setup
  CYG_EXE: C:\cygwin\setup-x86.exe
  CYG_MIRROR: http://cygwin.mirror.constant.com
  SCI_RUN: /cygdrive/c/SMALLTALKCI-master/run.sh

  matrix:
    - SMALLTALK: Squeak-trunk
      SMALLTALK_CONFIG: .stable-default.ston
    - SMALLTALK: Squeak-trunk
      SMALLTALK_CONFIG: .stable-tests.ston

platform:
  - x86

install:
  - '%CYG_EXE% -qnNdO -R "%CYG_ROOT%" -s "%CYG_MIRROR%" -l "%CYG_CACHE%" -P unzip'
  - ps: Start-FileDownload "https://github.com/hpi-swa/SMALLTALKCI/archive/master.zip" "C:\SMALLTALKCI.zip"
  - 7z x C:\SMALLTALKCI.zip -oC:\ -y > NULL

build: false

test_script:
  - '%CYG_BASH% -lc "cd $APPVEYOR_BUILD_FOLDER; exec 0</dev/null; $SCI_RUN $SMALLTALK_CONFIG"'
```
</details>

## Further Configuration

<a name="SmalltalkCISpec"/>
### Setting Up A Custom `.smalltalk.ston`

smalltalkCI requires a `.smalltalk.ston` configuration file which can be
customized for a project to cover various use cases.
The `.smalltalk.ston` must be a valid [STON][STON] file and has to contain a
single `SmalltalkCISpec` object.
This object can hold one or more [load specifications](#load-specs) in
`#loading` and configurations for the [TestCase selection](#testcase-selection)
in `#testing`.

```javascript
SmalltalkCISpec {
  #loading : [
    // List Of Load Specifications...
  ],
  #testing : {
    // TestCase Selection...
  }
}
```

<a name="load-specs"/>
#### Project Loading Specifications
smalltalkCI supports different mechanisms for loading Smalltalk projects.
One or more of those loading specifications have to be provided in the
`#loading` list as part of a [`SmalltalkCISpec`](#SmalltalkCISpec).
smalltalkCI will load all specifications that are compatible with the selected
Smalltalk image (specified via `#platforms`).

##### SCIMetacelloLoadSpec
A `SCIMetacelloLoadSpec` loads a project either via the specified Metacello
[`#baseline`][mc_baseline] or the Metacello
[`#configuration`][mc_configuration]. If a `#directory` is specified,
the project will be loaded using [FileTree][filetree]/[Metacello][metacello]
from the given directory.
Otherwise, it will be loaded from the specified `#repository`.

```javascript
SCIMetacelloLoadSpec {
  #baseline : 'MyProject',                            // Define MC Baseline
  #configuration : 'MyProject',                       // Alternatively, define MC Configuration
  #directory : 'packages',                            // Path to packages if FileTree is used
  #repository : 'http://smalltalkhub.com/mc/...',     // Alternatively, define MC repository
  #onWarningLog : true,                               // Handle Warnings and log message to Transcript
  #load : [ 'default' ],                              // Define MC load attributes
  #platforms : [ #squeak, #pharo, #gemstone ],        // Define compatible platforms
  #version : '1.0.0'                                  // Define MC version (for MC
                                                      // Configurations only)
}
```

##### SCIMonticelloLoadSpec
A `SCIMonticelloLoadSpec` loads a project with [Monticello][monticello]. It is
possible to load the latest version of packages from a remote repository
(`#packages`) or specific versions (`#versions`).

```javascript
SCIMonticelloLoadSpec {
  #url : 'http://ss3.gemtalksystems.com/ss/...',      // Define URL for repository
  #packages : ['MyProject-Core', 'MyProject-Tests'],  // Load packages and/or
  #versions : ['MyProject-Core-aa.12'],               // Load specific versions
  #platforms : [ #squeak, #pharo, #gemstone ]         // Define compatible platforms
}
```

##### SCIGoferLoadSpec
A `SCIGoferLoadSpec` works similar to a `SCIMonticelloLoadSpec`, but uses
[Gofer][gofer] on top of [Monticello][monticello] to load a project.

```javascript
SCIGoferLoadSpec {
  #url : 'http://smalltalkhub.com/mc/...',            // Define URL for repository
  #packages : ['MyProject-Core', 'MyProject-Tests'],  // Load packages and/or
  #versions : ['MyProject-Core-aa.12'],               // Load specific versions
  #platforms : [ #squeak, #pharo, #gemstone ]         // Define compatible platforms
}
```

#### TestCase Selection

smalltalkCI runs a list of TestCases during a build.
By default, smalltalkCI will use a list of all TestCases that it has loaded into
the image.
It is possible to adjust this list using the `#testing` slot.
In general, TestCases can be selected on class-level (`#classes`), on
category-level (`#categories`), on package-level (`#packages`) and on
project-level (`#projects`, GemStone only).
`#classes` expects a list of class name symbols, `#categories` and `#packages`
expect category names and prefixes or package names and prefixes respectively.
The default list can be replaced by a list of all TestCases that are present in
the image by setting `#allTestCases` to `true`.
Additionally, it is possible to add (`#include`) or remove (`#exclude`) classes
from this list.
The list can also be specified explicitly which means that *only* these
TestCases will run.

```javascript
SmalltalkCISpec {
  ...
  #testing : {
    // Include specific TestCases
    #include : {
      #classes : [ #AnotherProjectTestCase ],
      #categories : [ 'AnotherProject-Tests' ],
      #packages : [ 'AnotherProject.*' ],
      #projects : [ 'BaselineOfMyProject' ]
    },

    // Exclude specific TestCases from testing
    #exclude : {
      #classes : [ #AnotherProjectTestCase ],
      #categories : [ 'AnotherProject-Tests' ],
      #packages : [ 'AnotherProject.*' ],
      #projects : [ 'ConfigurationOfMyOtherProject' ]
    },

    #allTestCases : true, // Run all TestCases in image

    // Define TestCases explicitly
    #classes : [ #MyProjectTestCase ],
    #categories : [ 'MyProject-*' ],
    #packages : [ 'MyProject.*' ],
    #projects : [ 'BaselineOfMyProject' ]
  }
}
```

### Command Line Options

smalltalkCI has a couple of command line options that can be useful for
debugging purposes or when used locally:

```
USAGE: run.sh [options] /path/to/project/your_smalltalk.ston

This program prepares Smalltalk images/vms, loads projects and runs tests.

OPTIONS:
  --clean             Clear cache and delete builds.
  -d | --debug        Enable debug mode.
  -h | --help         Show this help text.
  --headfull          Open vm in headfull mode and do not close image.
  --install           Install symlink to this smalltalkCI instance.
  -s | --smalltalk    Overwrite Smalltalk image selection.
  --uninstall         Remove symlink to any smalltalkCI instance.
  -v | --verbose      Enable 'set -x'.

EXAMPLE:
  run.sh -s "Squeak-trunk" --headfull /path/to/project/.smalltalk.ston
```

### Travis-specific Options

Jobs on Travis CI [timeout if they don't produce output for
more than 10 minutes][travisTimeout]. In case of long running tests, it
is possible to increase this timeout by setting `$SMALLTALK_CI_TIMEOUT` in your
`.travis.yml` to a value greater than 10:

```yml
env:
- SMALLTALK_CI_TIMEOUT=30
```

The above sets the timeout to 30 minutes. Please note that Travis CI enforces
[a total build timeout of 50 minutes][travisTimeout].

### Using A Different smalltalkCI Branch Or Fork

By default, the smalltalkCI master branch is used to perform a build. It is
possible to select a different smalltalkCI branch or fork for testing/debugging
purposes by adding the following to the `.travis.yml`:

```yml
smalltalk_edge:
  source: hpi-swa/smalltalkCI
  branch: dev
```


## Contributing

Please feel free to [open issues][issues] or to
[send pull requests][pullRequests] if you'd like to discuss an idea or a
problem.


## Projects Using smalltalkCI

*In alphabetical order:*

- [@Cormas](https://github.com/cormas):
    [Cormas](https://github.com/cormas/cormas).
- [@dalehenrich](https://github.com/dalehenrich):
    [obex](https://github.com/dalehenrich/obex),
    [tode](https://github.com/dalehenrich/tode).
- [@dynacase](https://github.com/dynacase/):
    [borm-editor](https://github.com/dynacase/borm-editor),
    [borm-model](https://github.com/dynacase/borm-model),
    [borm-persistence](https://github.com/dynacase/borm-persistence),
    [class-editor](https://github.com/dynacase/class-editor),
    [demo-editor](https://github.com/dynacase/demo-editor),
    [dynacase](https://github.com/dynacase/dynacase),
    [dynacase-model](https://github.com/dynacase/dynacase-model),
    [fsm-editor](https://github.com/dynacase/fsm-editor).
- [@HPI-BP2015H](https://github.com/HPI-BP2015H):
    [squeak-parable](https://github.com/HPI-BP2015H/squeak-parable).
- [@HPI-SWA-Teaching](https://github.com/HPI-SWA-Teaching):
    [Algernon-Launcher](https://github.com/HPI-SWA-Teaching/Algernon-Launcher).
- [@hpi-swa](https://github.com/hpi-swa):
    [animations](https://github.com/hpi-swa/animations),
    [Ohm-S](https://github.com/hpi-swa/Ohm-S),
    [vivide](https://github.com/hpi-swa/vivide).
- [@marianopeck](https://github.com/marianopeck):
    [OSSubprocess](https://github.com/marianopeck/OSSubprocess),
    [FFICHeaderExtractor](https://github.com/marianopeck/FFICHeaderExtractor).
- [@pharo-project](https://github.com/pharo-project):
    [pharo-project-proposals](https://github.com/pharo-project/pharo-project-proposals).
- [@PolyMathOrg](https://github.com/PolyMathOrg):
    [PolyMath](https://github.com/PolyMathOrg/PolyMath).
- [@SeasideSt](https://github.com/SeasideSt):
    [Grease](https://github.com/SeasideSt/Grease),
    [Parasol](https://github.com/SeasideSt/Parasol),
    [Seaside](https://github.com/SeasideSt/Seaside).
- [@SergeStinckwich](https://github.com/SergeStinckwich):
    [PlayerST](https://github.com/SergeStinckwich/PlayerST).
- [@theseion](https://github.com/theseion):
    [Fuel](https://github.com/theseion/Fuel).
- [@Uko](https://github.com/Uko):
    [GitHubcello](https://github.com/Uko/GitHubcello),
    [QualityAssistant](https://github.com/Uko/QualityAssistant),
    [Renraku](https://github.com/Uko/Renraku).
- [@UMMISCO](https://github.com/UMMISCO/):
    [Kendrick](https://github.com/UMMISCO/kendrick).
- [@zecke](https://github.com/zecke):
    [osmo-smsc](https://github.com/zecke/osmo-smsc).
- [More Projects...][more_projects]

*Feel free to [send a PR][pullRequests] to add your Smalltalk project to the
list. Please add [`[ci skip]`][ci_skip] to your commit message.*


[travis_b]: https://travis-ci.org/hpi-swa/smalltalkCI.svg?branch=master
[travis_url]: https://travis-ci.org/hpi-swa/smalltalkCI
[appveyor_b]: https://ci.appveyor.com/api/projects/status/c2uchb5faykdrj3y/branch/master?svg=true
[appveyor_url]: https://ci.appveyor.com/project/smalltalkCI/smalltalkci/branch/master
[coveralls_b]: https://coveralls.io/repos/github/hpi-swa/smalltalkCI/badge.svg?branch=master
[coveralls_url]: https://coveralls.io/github/hpi-swa/smalltalkCI?branch=master

[appveyor]: https://www.appveyor.com/
[bsis]: http://docs.travis-ci.com/user/migrating-from-legacy/#Builds-start-in-seconds
[builderCI]: https://github.com/dalehenrich/builderCI
[cbi]: http://docs.travis-ci.com/user/workers/container-based-infrastructure/
[ci_skip]: https://docs.travis-ci.com/user/customizing-the-build/#Skipping-a-build
[clone]: https://help.github.com/articles/cloning-a-repository/
[coveralls]: https://coveralls.io/
[download]: https://github.com/hpi-swa/smalltalkCI/archive/master.zip
[filetree]: https://github.com/dalehenrich/filetree
[gofer]: http://www.lukas-renggli.ch/blog/gofer
[gs]: https://github.com/hpi-swa/smalltalkCI/issues/28
[issues]: https://github.com/hpi-swa/smalltalkCI/issues
[mc_baseline]: https://github.com/dalehenrich/metacello-work/blob/master/docs/GettingStartedWithGitHub.md#create-baseline
[mc_configuration]: https://github.com/dalehenrich/metacello-work/blob/master/docs/GettingStartedWithGitHub.md#create-configuration
[metacello]: https://github.com/dalehenrich/metacello-work
[monticello]: http://www.wiresong.ca/monticello/
[more_projects]: https://github.com/search?l=STON&q=SmalltalkCISpec&ref=advsearch&type=Code
[pullRequests]: https://help.github.com/articles/using-pull-requests/
[ston]: https://github.com/svenvc/ston/blob/master/ston-paper.md#smalltalk-object-notation-ston
[templates]:https://github.com/hpi-swa/smalltalkCI/wiki#templates
[travisCI]: http://travis-ci.org/
[travisHowTo]: http://docs.travis-ci.com/user/getting-started/#To-get-started-with-Travis-CI%3A
[travisTimeout]: https://docs.travis-ci.com/user/customizing-the-build/#Build-Timeouts
