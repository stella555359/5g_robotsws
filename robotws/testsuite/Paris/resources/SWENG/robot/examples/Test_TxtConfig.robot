
*** Settings ***
Documentation
...          Just a test to generate a lua file from a txt config file from WTS

Resource            ../Connect.robot
Resource            ../Setup.robot
Resource            ../SetConfig.robot

Suite Setup         Suite setup         # listBackupFiles=${FD_ALL}

*** Test Cases ***
Test
    Dated log                       Start
    My TxtConfig Init


*** Keywords ***
My TxtConfig Init
    [Documentation]                 Generate lua file from txt config file from WTS
    ...                             it means from basic...cfg file we will generate basic...lua
    ...                             will Lua syntax (exec(...command...), for loop, ...)
    ...                             It returns name (not path) of Lua config file
    [Arguments]                     ${nbUe}=1       ${nbSaUe}=0    ${list_of_UE_tobe_created}=${None}
    ${alias}                        SSH Wait For Connect                ${HOST_EPCSIM}
    # Download .cfg file locally
    ${myFile}                       Set Variable                ESSAI.cfg
    ${TxtConfigLocalDir}            getTempDir
    Dated Log                       \tDownloading ${tl.core.dir_path}/${myFile} into ${TxtConfigLocalDir}
    ${outload}                      csn.download_file
    ...                                 remote_path=${tl.core.dir_path}/${myFile}
    ...                                 local_path=${TxtConfigLocalDir}/${myFile}
    ...                                 connection=${alias}
    # Generate .lua file upon nb of UE requested
    Dated Log                       \tGenerating Lua file with ${nbUe} UE
    ${LuaConfigName}                TxtConfig.generateLuaFile
    ...                                 path=${TxtConfigLocalDir}
    ...                                 name=${myFile}
    ...                                 nbUe=${nbUe}
    ...                                 nbSaUe=${nbSaUe}
    ...                                 list_of_UE_tobe_created=${list_of_UE_tobe_created}
    # Upload generated file (.lua) on WTS
    Dated Log                       \tUploading ${TxtConfigLocalDir}/${LuaConfigName} into ${tl.core.dir_path}/${LuaConfigName}
    ${outload}                      csn.upload_file
    ...                                 remote_path=${tl.core.dir_path}/${LuaConfigName}
    ...                                 local_path=${TxtConfigLocalDir}/${LuaConfigName}
    ...                                 connection=${alias}
    [Return]                        ${LuaConfigName}
