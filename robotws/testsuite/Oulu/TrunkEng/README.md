# Running scripts from robotws

To run test cases as single run in UTE from the robotws repository, you need to select tags (and env). In regression, the tags comes from the test_options field of test case defined in QC.

# Folder structure

Folders in Oulu/TrunkEng are Common + test area folders. They include Python and Robot folders.

## Python -folders

Python -folders contain two folders: Interfaces and Resources. Interfaces -folders include Python files that
are useful for the testers, i.e. they include Keywords that can be used in the test_case.robot. Resources -folders
contain files that are used within other Python files, which means that they are only useful for script developers.

## Robot -folders

Robot -folders include Resources and/or ExampleTestCases -folders. Resources -folder includes files that are
used within other .robot -files. ExampleTestCases -folders include example test cases made by the scriptors.
Actual test case -files are directly under Robot -folder.

# Documentation

Documentation can be found [here](https://ca_fsupport.gitlabe2-pages.ext.net.nokia.com/oulu-trunk-testing/).
It consists of the methods/KWs that can be used for example in your robot test cases.
