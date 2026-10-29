*** Settings ***

Documentation     Keywords related to git handling or git project workspace
...

Library    String
Library    OperatingSystem

Resource   testline.robot

*** Variables ***

*** Keywords ***
Save Current Workspace Info
    [Documentation]
    ...    Save repository branch and commit ID information for debugging or reproducing.
    ...    Save modified files in repository.
    ...
    ${resultSuiteBaseDir}   testline.Get Test Suite Result Base Directory
    ${workspaceDir}         testline.Get Workspace Directory

    ${output_1}   OperatingSystem.Run   cd ${workspaceDir}; git rev-parse --abbrev-ref HEAD
    ${output_2}   OperatingSystem.Run   cd ${workspaceDir}; git rev-parse HEAD

    Save Modified Files In Git    targetDir=${resultSuiteBaseDir}   workspaceDir=${workspaceDir}

    OperatingSystem.Create File   ${resultSuiteBaseDir}/repoInfo.txt   Working on branch: ${output_1} with Commit-ID ${output_2}


Save Virtual Environment Info
    [Documentation]
    ...    This KW saves the python libryry version in the active environment.
    ...
    ${resultSuiteBaseDir}   testline.Get Test Suite Result Base Directory
    ${workspaceDir}         testline.Get Workspace Directory

    OperatingSystem.Run   pip list > ${resultSuiteBaseDir}/pip_list.txt 2>/dev/null



### private ###
Save Modified Files In Git
    [Documentation]
    ...    This KW saves all locally modified but not committed files in archive modifedFiles.tgz.
    ...    The KW is used in `Save Current Workspace Info`.
    ...
    ...    *Scope*  Internal
    ...
    [Arguments]  ${targetDir}   ${workspaceDir} 
    ${modifiedFiles}   OperatingSystem.Run   cd ${workspaceDir}; git ls-files -m
    ${modifiedFiles}   String.Replace String   ${modifiedFiles}   search_for=\n   replace_with=${SPACE}

    Run Keyword If   '${modifiedFiles}'!=''
    ...   OperatingSystem.Run   cd ${workspaceDir}; tar czvf ${targetDir}/modifedFiles.tgz ${modifiedFiles}


