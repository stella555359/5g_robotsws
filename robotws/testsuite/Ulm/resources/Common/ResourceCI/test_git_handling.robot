*** Settings ***

Documentation
...   This is a test suite used in KW resourceCI. It doesn't need a real TL to pass.
...   It verifies proper function of KWs in git_handling.robot resource file.


Library     OperatingSystem

Resource    ../git_handling.robot

*** Test Cases ***
Test Save Current Workspace Info
    [TAGS]              GIT
    git_handling.Save Current Workspace Info
    OperatingSystem.File Should Not Be Empty   ${P_resultSuiteBaseDir}/repoInfo.txt

Test Save Virtual Environment Info
    [TAGS]              GIT
    git_handling.Save Virtual Environment Info
    OperatingSystem.File Should Not Be Empty   ${P_resultSuiteBaseDir}/pip_list.txt
