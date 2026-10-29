*** Settings ***
Documentation
...    Tests for CB013203 snapshot with SDL
Library    BuiltIn
Library    DateTime
Library    Collections
Library    taf.ul.verify_snapshot    WITH NAME    snapshot
Resource    ../../common_resources/vdu_frame.robot
Resource    ../../common_resources/vdu_general.robot
Resource    ../../common_resources/vcu_frame.robot
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_logging.robot
Resource    ../resources/LOGS_general.robot
Resource    ../resources/unpacking.robot

Library  taf.gnb.oam.coam.vdu  WITH NAME  vdu
Library  taf.gnb.oam.coam.cu.interface    WITH NAME  vcu
#Library  taf.gnb.oam.coam.cu  WITH NAME  vcu



#Suite Setup       Suite Precondition
#Test Teardown     Test Teardown

*** Variables ***
${VDU_SCFC_PATH}  ${CURDIR}/SCF/vCu/vDu.xml
${VCU_SCFC_PATH}  ${CURDIR}/SCF/vCu/vCu.xml
@{LIST_OF_DIRECTORY_TO_DEL_AFTER_UNPACK}=    Create List
#${REVERT_DELTA_CHANGES}    ${False}
${SDL_LIST}    /home/ute/robotws/testsuite/Timisoara/CBTS/test_line_specific/TSR7/Vdu139/config/sdl.json
${SDL_FULL_LIST}    /home/ute/robotws/testsuite/Timisoara/CBTS/test_line_specific/TSR7/Vdu139/config/sdl_full.json
*** Keywords ***
TC__LOGS__CB013203_vCU_snapshot_with_SDL
    [Documentation]
    ...  CB013203 test


    Step 0: Precondition
    Step 1: Collect Local Snapshot from vCU with fullSDL
    Step 2: Check SDL file content
    Step 3: Collect Local Snapshot from vCU with shortSDL
    Step 4: Check SDL file content

Step 0: Precondition
   [Documentation]
    ...   In this step Precond
     Log    \nStep 0: Precondition    console=${True}

    ${date}     Get Current Date    time_zone=UTC    result_format=%Y-%m-%d
    Set Test Variable    ${date}
    Set Test Variable    ${logs_dir}    ${TEST_RESULTS_DIR}
#    log to console    testname:${TEST_NAME}
    Run    mkdir -p ${logs_dir}/snapshotSDL; mkdir -p ${logs_dir}/snapshotSDLshort


Step 1: Collect Local Snapshot from vCU with fullSDL
    Log    \nStep 1: Collect Local Snapshot from vCU with fullSDL    console=${True}

    ${STEP_NAME}    Set Variable    Step 1: Collect Local Snapshot from vCU with fullSDL
    ${status}    Run Keyword And Return Status    Should contain    ${STEP_NAME}    short
    Set Test Variable     ${status}
    Run keyword if    ${status}    Set Test Variable    ${snapshot_path}    ${logs_dir}/snapshotSDLshort
    ...    ELSE    Set Test Variable    ${snapshot_path}    ${logs_dir}/snapshotSDL

    ${path_SDL}    Set variable if    ${status}    ${SDL_LIST}
    ...                                            ${SDL_FULL_LIST}
    Set Test Variable    ${path_SDL}
    Collect snapshot SDL and check sdl files number


Step 2: Check SDL file content
    Log    \nStep 2: Check SDL file content    console=${True}
    Check SDL file content

Step 3: Collect Local Snapshot from vCU with shortSDL
    Log    \n Step 3: Collect Local Snapshot from vCU with shortSDL    console=${True}

    ${STEP_NAME}    Set Variable     Step 3: Collect Local Snapshot from vCU with shortSDL
    ${status}    Run Keyword And Return Status    Should contain    ${STEP_NAME}    short
    Set Test Variable     ${status}
    Run keyword if    ${status}    Set Test Variable    ${snapshot_path}    ${logs_dir}/snapshotSDLshort
    ...    ELSE    Set Test Variable    ${snapshot_path}    ${logs_dir}/snapshotSDL

    ${path_SDL}    Set variable if    ${status}    ${SDL_LIST}
    ...                                            ${SDL_FULL_LIST}
    Set Test Variable    ${path_SDL}
    Collect snapshot SDL and check sdl files number

Step 4: Check SDL file content
    Log    \nStep 4: Check SDL file content    console=${True}
    Check SDL file content

Collect snapshot SDL and check sdl files number
    Connect To VCU  host=${VCU_OAM_IP}

    ${source_data}=    OperatingSystem.Get File    path=${path_SDL}
    ${sdl_components}=    Evaluate     json.loads("""${source_data}""")    json
    vcu.Get Local Snapshot  directory=${snapshot_path}
    ...   use_m2m=False    sdl_components=${sdl_components}


    ${files}    OperatingSystem.List Files In Directory    ${snapshot_path}    Snapshot_*.zip
    ${snapshot_name}    Get From List    ${files}    0
    Set Test Variable    ${snapshot_name}

    Find SDL Files    ${snapshot_path}/${snapshot_name}

    log to console    SDLfiles number:${number}


    Run keyword if    ${status}    Check number of SDL files short
    ...    ELSE    Check number of SDL files full


Check number of SDL files short
    Run keyword if  ${number}==6    log    number of SDL=${number}
    ...    ELSE    Fail    SDL file different than 6

Check number of SDL files full
    Run keyword if  ${number}==28    log    number of SDL=${number}
    ...    ELSE    Fail    SDL file different than 28

Check SDL file content

    unpacking.Unpack Archive Content To Directory  ${snapshot_path}/${snapshot_name}  ${snapshot_path}/ex
    ${files}    OperatingSystem.List Files In Directory    ${snapshot_path}/ex   SdlDump_*.json.zip

    FOR   ${sdlfile}   IN   @{files}
        ${size}    OperatingSystem.Get File Size   ${snapshot_path}/ex/${sdlfile}
           Run Keyword If   ${size} > 1000    Run Keywords
            ...   Log   SDL file: found   console=${True}
            ...   AND   Set Test Variable    ${file_to_check}   ${sdlfile}
            ...   AND   Check file data
            ...   AND   exit for loop
    END

    Check file no data

Check file no data
    ##check not populated file
    ${output_no_data_file}    Run    grep -i -m 1 Namespace not found ${snapshot_path}/ex/MRBTS-*_metadata.txt | awk '{print $2}'
    log to console    file no data:${output_no_data_file}
    unpacking.Unpack Archive Content To Directory  ${snapshot_path}/ex/${output_no_data_file}  ${snapshot_path}/ex/ex2
    ${output_no_data_file}   Set Variable    ${output_no_data_file.rstrip(".zip")}
    ${string_to_check}     Run    grep -i dataMap ${snapshot_path}/ex/ex2/${output_no_data_file}
    ${output_no_data}    Fetch From Right    ${string_to_check}     dataMap
    Should Be Equal     ${output_no_data}    ":{}}

Check file data
    unpacking.Unpack Archive Content To Directory  ${snapshot_path}/ex/${file_to_check}  ${snapshot_path}/ex/ex2
    ##check populated file
    ${file_to_check}   Set Variable    ${file_to_check.rstrip(".zip")}

    ${string_to_check}     Run    grep -i dataMap ${snapshot_path}/ex/ex2/${file_to_check}
    ${output}    Fetch From Right    ${string_to_check}     dataMap
    ${len}    Get Length    ${output}
    Run keyword if     ${len} > 4    log to console    DataMap not empty !



Find SDL Files
    [Documentation]
    ...  This KW searches SDL Files in Snapshot and extracts it for further verification.

    [Arguments]   ${snapshot_path}

    Log   Find and extract DiagnosticReport file   console=${True}

    Set Test Variable   ${number}     0
    ${snapshot_dict}   snapshot.Get Data From Snapshot   ${snapshot_path}
    FOR   ${key}   IN   @{snapshot_dict.keys()}
#          ${MATCHES}   Get Regexp Matches   ${snapshot_dict["${key}"][0]}   SdlDump*.json.zip
             ${snap_file}    Fetch From Right    ${snapshot_dict["${key}"][0]}    /
             Set test variable    ${snap_file}

            ${Sdldump}    Run Keyword And Return Status    Should contain   ${snap_file}  SdlDump
            ${MATCHES}    Run Keyword And Return Status    Should contain   ${snap_file}   json.zip

            Run Keyword If   ${MATCHES} and ${Sdldump}    Run Keywords
            ...   Log   SDL file: found   console=${True}
#            ...   AND   OperatingSystem.Get File Size   ${snapshot_path}    #/${snap_file}
            ...   AND   Check SDL file    ${snap_file}
            ...   AND   Increase number

    END


#    ${extracted_file}   Extract Log File   ${snapshot_path}   ${MATCHES[0]}
#    Run Keyword Unless   ${MATCHES}   Fail   DiagnosticReport file not found
    [Return]   ${number}

unzip snapshot file
    log to console     unzip snapshot
    snapshot.un_zip   path_name=${SAVE LOG DIRECTORY}    file_name=${snapshot_name}
    ${p1}    ${e1}    OperatingSystem.Split Extension    ${SAVE LOG DIRECTORY}/${snapshot_name}
    [Return]      ${p1}


Check SDL file
    [Arguments]   ${snapshot_file}
    log to console    ${snapshot_file}

Increase number
    ${number}  Evaluate    ${number}+1
    Set test variable    ${number}


Test Teardown
    Run Keyword If  ${REVERT_DELTA_CHANGES}  Run Keywords
    ...    Revert commissioning
    Run keyword if  ${LIST_OF_DIRECTORY_TO_DEL_AFTER_UNPACK}!='[]'    Remove All Directories After Unpack

Remove All Directories After Unpack
    FOR  ${dir_to_del}  IN  @{LIST_OF_DIRECTORY_TO_DEL_AFTER_UNPACK}
      Run    rm -rf ${dir_to_del}
    END

TC Setup
    Common VDU Setup
    Common VCU Setup   modules_check=${FALSE}
#    Suite Precondition

TC Teardown
#    Run Keyword If Test Failed
#    ...  Delete Actual Delta Plan Via WebEM
#    VDU WebEM Teardown
#    Test Teardown
    Logs To Rotta Copy
