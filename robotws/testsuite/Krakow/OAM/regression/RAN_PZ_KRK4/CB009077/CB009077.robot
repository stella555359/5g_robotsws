*** Settings ***
Documentation
...         author: Weronika Wojcik
...         contact: weronika.wojcik@nokia.com
...         Feature CB009077 in 24R3

Library     taf.sbts.oam.coam.admin       WITH NAME    coam
Library     OperatingSystem
Library     ArchiveLibrary
Library     String
Library     Resources/get_time.py
Library     DateTime
Library     taf.transport.ssh      WITH NAME    csn
Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   Resources/delta.py

Suite Setup         Common Suite Setup
Suite Teardown      Common Suite Teardown
Test Setup          Common Preconditions
Test Teardown       Common Postconditions

*** Variables ***
${WEBUI_URL}        ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USER}       ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}   ${tl.gnbs[0].cu.oam_http_connection_details.password}
${GNB_SSH_ADDR}          ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${ssh_user}        ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${ssh_password}    ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${MRBTS_ID}        ${tl.gnbs[0].global_bts_id}
${type}     gNB
${searchName}     BTS79019_AH212500093_RMOD_L_1_permanent.xml.gz
${connection}    GNB_OAM
${TS_CASE_LOG_PATH}    /home/ute/logs/9077


*** Test Cases ***
[1]CB009077_E_06_Store_Location_info_during_run-time_ASMR
    Perform commissioning on gNB to onAir state
    ...  prefix_tag=customer_scf
     Perform Delta Commissioning On Gnb    ${actLocInfoDelete}
     Disable CB009077
     Configured RU Location    operation=delete
     ${Permanent_size_OFF}    Check Permanent File Exist in snapshot
     Log To Console    Disable CB009077 Permanent file size: ${Permanent_size_OFF}
     Enable CB009077
     ${Permanent_size_ON}    Check Permanent File Exist in snapshot
     Log To Console    Disable CB009077 Permanent file size: ${Permanent_size_ON}
     Configured RU Location
     ${Permanent_size_Config}    Check Permanent File Exist in snapshot
     Log To Console    Disable CB009077 Permanent file size: ${Permanent_size_Config}
     Should be true    ${Permanent_size_Config}>${Permanent_size_ON}>${Permanent_size_OFF}
     ...     msg=Permanent file has incorrect size: ${Permanent_size_ON}


*** Keywords ***
Check Permanent File Exist in snapshot
    Log To Console    SaveSnapshot_Started
    ${snapshot_file_path}    COAM Save snapshot via rest api    timeout=1500
    Log To Console    SaveSnapshot_Finished
    ${retrun_fault}    Extract Permanent from snapshot    searchName=${searchName}
    ...    snapshot_file=${snapshot_file_path}
    [Return]  ${retrun_fault}

Extract Permanent from snapshot
    [Documentation]   Auther:lijian.xia@nokia-sbell.com
    [Arguments]    ${searchName}    ${snapshot_file}
    Log To Console    ExtractSnapshot_Started
    ${timestamp}    Get Current Date    result_format=%Y-%m-%d%H:%M:%S
    ${zipout}    Set Variable    zipout_${timestamp}
    Log To Console    ExtractSnapshot_Started1
    Extract Zip File    ${snapshot_file}    ${TS_CASE_LOG_PATH}/${zipout}
    ${result_zip}    searchFile      filename=${TS_CASE_LOG_PATH}/${zipout}/snapshot_file_list.txt      searchName=${searchName}
    ${return_status}    run keyword and return status   should be equal as strings    ${result_zip}   not find
    ${permanent_path}     Run keyword if     ${return_status}
    ...   Extract Zip File    ${snapshot_file}    ${TS_CASE_LOG_PATH}/${zipout}
    ...   ELSE     Extract Zip File     ${TS_CASE_LOG_PATH}/${zipout}/${result_zip.split(":")[0]}       ${TS_CASE_LOG_PATH}/${zipout}
    ${permanent_path}    Run    command=cd ${TS_CASE_LOG_PATH}/${zipout};ls | grep -i ${searchName}
    Log To Console    CheckFileSize_Started
    Sleep    120
    ${file_size}    OperatingSystem.Get File Size    ${TS_CASE_LOG_PATH}/${zipout}/${permanent_path}
    Should be true    ${file_size}>1    msg=Permanent file has incorrect size: ${file_size}
    [Return]    ${file_size}

Enable CB009077
    log to console    Enable CB009077
    Conect to DU COAM
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    parameter=actLocInfoStore
    ...    operation=update
    ...    value=true
    ...    skip_parameter_relation_errors=True
    ...    connection=${connection}
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    parameter=accLevSet
    ...    operation=update
    ...    value=High
    ...    skip_parameter_relation_errors=True
    ...    connection=${connection}

Disable CB009077
    log to console    Disable CB009077
    Conect to DU COAM
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    parameter=actLocInfoStore
    ...    operation=update
    ...    value=false
    ...    skip_parameter_relation_errors=True
    ...    connection=${connection}

Remove CB009077
    log to console    Enable CB009077
    Conect to DU COAM
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    parameter=actLocInfoStore
    ...    operation=delete
    ...    value=true
    ...    skip_parameter_relation_errors=True
    ...    connection=${connection}
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    parameter=accLevSet
    ...    operation=delete
    ...    value=High
    ...    skip_parameter_relation_errors=True
    ...    connection=${connection}

Configured RU Location
    log to console    Configured Location
    [Arguments]      ${operation}=update
    Conect to DU COAM
    ${RU_location}=    Create Dictionary
    ...     altitude=12345
    ...     latitude=798654321
    ...     longitude=123456789
    @{list}=    create list    ${RU_location}
    coam.perform_parameter_recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    ...    parameter=modulePositionInformation
    ...    operation=${operation}
    ...    value=@{list}
    ...    skip_parameter_relation_errors=True
    ...    connection=${connection}

Conect to DU COAM
    [Arguments]    ${connection}=${connection}
    coam.connect to   bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
                  ...      username=${WEBUI_USER}
                  ...      password=${WEBUI_PASSWORD}
                  ...      name=${connection}

COAM Save snapshot via rest api
    [Arguments]    ${timeout}=1500
    ${timestamp}  Get Current Date     result_format=%Y-%m-%d%H:%M:%S
    ${coam_connection}    coam.Connect To    bts_host=${GNB_SSH_ADDR}
    ${snapshot_file_path}=    Set Variable    ${TS_CASE_LOG_PATH}/snapshot_rest_api_${timestamp}.zip
    coam.Get SnapShot    target_file_name=${snapshot_file_path}  timeout=${timeout}   connection=${connection}
    [Return]  ${snapshot_file_path}
    [Teardown]    coam.Teardown    ${connection}
