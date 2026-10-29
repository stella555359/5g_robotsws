# robotws

robotws is a workspace with automated test cases written in Robot Framework.

## Repository tree structure

In general, the repository structure consist of the following directories:

- `testsuite/`
- `resources/` (deprecated)
- `sanity-checks/`

Additionally, it stores files with list of Python packages (dependencies) required to execute Robot Framework test cases (TCs):

- `requirements.cfg`
- `dependencies.py*.lock`

## Repository way of working (WoW)

### `testsuite/` directory

`testsuite/` is a directory tree of Robot Framework TCs stored within separate workspaces (different for each team, site, feature etc.). In order to deliver new content, you're obligated to create a new branch and submit a merge request (MR) which should be reviewed and merged back to the master branch by a Code Guard (CG). List of CGs for each team/site can be found at https://nok.it/aboutTACG

### `resources/` directory

`resources/` was meant to store additional Robot Framework keywords which could be shared and reused by multiple TCs. **Using these resources is now deprecated as testers should not import resources from outside their domain directory.** 

### `sanity-checks/` directory

Contains scripts for checking repository's code quality and structure within CI/CD pipelines. Its content is maintained exclusively by the TAF team.

### `requirements.cfg`, `dependencies.py*.lock` files

These files contain a list of Python libraries needed explicitly (imported) in Robot Framework TCs.

It is now testers' responsibility to keep the list of dependencies up-to-date. In order to do that, *requirements.cfg* has to be modified according to one's needs and delivered to the repo's master branch via a merge request. Even though comprehensive dry-runs are executed within Gitlab CI/CD pipelines to assert feasibility of the upgrade, such a modification must also be approved by a Code Guard.

Any change in *requirements.cfg* triggers a process of generating *dependencies.py\*.lock* files. They define exact versions of Python libraries that can be installed without any conflicts.

The project dependency management policy is also described in detail at http://nok.it/O0mKb5

**NOTE: Manual editing of *dependencies.py\*.lock* files is prohibited - they are only generated automatically**

### Restrictions

You must not modify the following files and directories:

- `.gitconfig`
- `.gitignore`
- `.gitlab-ci.yml`
- `README.md`
- `CONTRIBUTING.md`
- `dependency.py*.lock`
- `.gitlab/`
- `docs/`
- `sanity-checks/`

**NOTE: One must not add any new files or dirs in the root directory**

## Requirements

Make sure you've installed these before the next step.

### System requirements

UTE VM

### Python requirements

These requirements should be installed with `pip`:

- `pip >= 8.1.2`, please install the latest version available:

```
python -m pip install -U pip
```

## Environment preparation for development / test execution

With a properly defined `~/.pip/pip.conf` file (see [here](https://confluence.ext.net.nokia.com/display/UTE/Switching+to+Artifactory+PyPI) for
more details) you can install all Python dependencies from a lock file matching the Python version you use, e.g.,

```
pip install -r dependencies.py3.lock
```

## Test line configurations

Test line configuration files are stored in [Test Line Configuration repository](https://wrgitlab.ext.net.nokia.com/RAN/configuration-management/testline_configuration). Cloning this repo might be needed to execute tests locally, see examples below.

## How to execute a test?

Generic command:

```
robot -V PATH_TO_TL_CONFIG -L DEBUG -b debug.log -d PATH_TO_OUTPUT PATH_TO_TESTSUITES
```

Example:

```
robot -V /home/ute/testline_configuration/CV_WR_TL0017/ -L DEBUG -b debug.log -d /tmp/ testsuite/5GC000248/
```

## How to execute a dry run?

Test cases can be executed in a *dry run* mode to validate general correctness of the test script, without actually running any keywords. See the [official documentation](http://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#dry-run) for more.

Example:

```
robot --dryrun -V /home/ute/testline_configuration/CV_WR_TL0017/ -L DEBUG -b debug.log -d /tmp/ testsuite/5GC000248/
```

which is similar to the previous example but it calls `robot` command with `--dryrun` option.

Alternatively, you can use a [dummy config](https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/blob/master/dummy_config.py) file instead of an actual test line configuration

```
robot --dryrun -V dummy_config.py -L DEBUG -b debug.log -d /tmp/ testsuite/5GC000248/
```

## How to run Sanity checks locally?

First, install `ci_pipeline_steps` package:

```
pip install --user --upgrade ci_pipeline_steps -q
```

Check if the script is in your system path:

```
which ci-pipeline
```

If not, you will have to add the user site-packages location to your `PATH` environment variable.
By default (see PEP 370) it is located inside `~/.local/bin`.
Add the following to your `~/.bashrc` file:

```
# Add ~/.local/bin (pip install --user) directory to PATH
PATH=$PATH:~/.local/bin
```

After the above, you should be able to use `ci-pipeline` command in your shell:

```
ci-pipeline run_sanity /path/to/your/robotws
```

or:

```
cd path/to/your/robotws
ci-pipeline run_sanity .
```

(**Note "." at the end**)

## Verification against newer versions of Robot Framework

The procedure of TCs and resources verification against newer version of Robot Framework is described [here](/docs/RF_verification_procedure.md).
