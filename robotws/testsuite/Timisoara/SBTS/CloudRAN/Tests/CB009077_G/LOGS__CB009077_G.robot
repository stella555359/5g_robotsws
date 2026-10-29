*** Settings ***
Library    BuiltIn
Library    DateTime
Library    Collections
Library    taf.ul.verify_snapshot    WITH NAME    snapshot
Resource    ../../../resources/unpacking.robot
Resource    ../../../resources/verdicts.robot
Resource    ../../Resources/common_keywords.robot
Resource    ../../Resources/common_logging.robot

Suite Setup       Suite Precondition
Test Teardown     Test Teardown
*** Variables ***
${VDU_SCFC_PATH}  ${CURDIR}/SCF/vCu/vDu.xml
${VCU_SCFC_PATH}  ${CURDIR}/SCF/vCu/vCu.xml
@{LIST_OF_DIRECTORY_TO_DEL_AFTER_UNPACK}=    Create List


*** Test Cases ***
LOGS_CB009077_G
    [Documentation]
    ...  CB009077 test

    Log    \nPreconditions    console=${True}
    Log    \nConnecting to vDU and set all necessary variables   console=${True}
    log to console    ip:${UTE_SSH_IP} u:${UTE_SSH_USER_NAME} p:${UTE_SSH_PASSWORD}
    common_vdu.vDU Rest Login
    Set Test Variable    ${REVERT_DELTA_CHANGES}  ${False}
    ${rmod_listed}    vduint.get rmods status
    ${ids}    Create List
    Set Test Variable    ${ids}
    ${serial_numbers}      Create List

    FOR    ${item}    IN    @{rmod_listed}
        ${serial_number}    Get From Dictionary    ${item}    serial_number
        ${id}    Get From Dictionary    ${item}    id
        ${dist_names}    Get From Dictionary    ${item}    dist_names
        Append To List    ${serial_numbers}    ${serial_number}
        Append To List    ${ids}    ${id}
    END
    Set Test Variable    ${serial_numbers}
    ${config_value}    Set Variable    ${dist_names['config']}
    ${split}    Split String    ${config_value}    /
    ${mr_id}    Get From List    ${split}    0
    ${vdu_id}    Split String    ${mr_id}    -
    ${vdu_id}    Get From List    ${vdu_id}   1
    Set Test Variable  ${vdu_id}
    ${mo_dn_1}    Set Variable    MRBTS-${vdu_id}/MNL-1/MNLENT-1/FEATCADM-1
    ${changed_preventParamModifList}  Create dictionary
    ...                   preventParamModifList=${EMPTY}
    ${changed_parameter1}  Create dictionary  actLocInfoStore=true
    Set Test Variable    ${changed_parameter1}
    ${changed_parameter2}  Create dictionary  accLevSet=High
    Set Test Variable    ${changed_parameter2}
    ${changed_parameter3}  Create dictionary
    ...                   modulePositionInformation=${EMPTY}
    ...                   modulePositionInformation/0=${EMPTY}
    ...                   modulePositionInformation/0/altitude=123
    ...                   modulePositionInformation/0/latitude=123
    ...                   modulePositionInformation/0/longitude=123
    ${changed_parameter4}  Create dictionary
    ...                   modulePositionInformation=${EMPTY}
    Set Test Variable    ${changed_parameter4}
    ${date}     Get Current Date    time_zone=UTC    result_format=%Y-%m-%d
    Set Test Variable    ${date}
    Set Test Variable    ${logs_dir}    /home/ute/logs
    Run    mkdir -p ${logs_dir}/snapshotON
    Run    mkdir -p ${logs_dir}/snapshotOFF
    Run    mkdir -p ${logs_dir}/RU_permanent_filesON
    Run    mkdir -p ${logs_dir}/RU_permanent_filesOFF



    Log  \nCheck plan list, if exist plan will be removed    console=${True}
    ${delta_plan_list}     vduint.get_delta_plan_info_list
    Run Keyword If   ${delta_plan_list}  vduint.delete_delta_plan_file  ${delta_plan_list[0]['plan_id']}

    Log    \nGenerate Delta Plan: actLocInfoStore:true and modulePositionInformation are set    console=${True}
    ${delta_res}    vduint.Generate Delta Plan    actlocon
    ${plan_id}     Set variable    ${delta_res['plan_id']}
    Wait until keyword succeeds  3x  2s    Check if delta plan was created on DU    ${delta_res['action_id']}

    ${mo_parameters}=           Run Keyword And Ignore Error
    ...    search_parameter_of_current_plan    MRBTS-${vdu_id}/MNL-1/MNLENT-1/FEATCADM-1    preventParamModifList
    ${contains_pass}=    Run Keyword And Return Status    Should Contain    ${mo_parameters}[0]    PASS

    Run Keyword If    ${contains_pass}    Update Vdu Parameter
    ...    ${plan_id}    MRBTS-${vdu_id}/MNL-1/MNLENT-1/FEATCADM-1    ${changed_preventParamModifList}    remove

    Update Vdu Parameter
    ...    ${plan_id}    MRBTS-${vdu_id}/MNL-1/MNLENT-1/FEATCADM-1    ${changed_parameter1}    add

    Update Vdu Parameter
    ...    ${plan_id}    MRBTS-${vdu_id}/MNL-1/MNLENT-1/FEATCADM-1    ${changed_parameter2}    add

    FOR    ${id}  IN  @{ids}
      Update Vdu Parameter
      ...    ${plan_id}    MRBTS-${vdu_id}/EQM-1/APEQM-1/RMOD-${id}    ${changed_parameter3}    add

    END

    Log    \nValidate Plan   console=${True}

    ${delta_validation}    vduint.validate_delta_plan   ${plan_id}
    Wait until keyword succeeds  10x  2s    Check if delta plan was validated on DU    ${plan_id}    ${delta_validation['action_id']}

    Log    \nActivate Plan   console=${True}

    ${delta_act}    vduint.Activate Delta Plan    ${plan_id}
    Wait until keyword succeeds  24x  10s    Check if delta plan was activated on DU    ${plan_id}    ${delta_act['id']}
    Set Test Variable    ${REVERT_DELTA_CHANGES}  ${True}
    Log    \nGet Local Snapshot from vDU    console=${True}
    ${collect_vdu_snapshot_status}    ${ignored_error}    Run Keyword And Ignore Error
    ...  vduint.Get Local Snapshot  directory=${logs_dir}/snapshotON/
    ...  compressed_or_not=True

    Run Keyword If    '${collect_vdu_snapshot_status}' == 'PASS'
    ...  Log to console  snapshot fron vDU was downloaded
    ...  ELSE    Fail    Snapshot downlaod ${collect_vdu_snapshot_status}

    ${files}    OperatingSystem.List Files In Directory    ${logs_dir}/snapshotON/    Snapshot_*.zip
    ${snapshot_name}    Get From List    ${files}    0
    Set Test Variable  ${snapshot_name}
    ${found_file_dict}    snapshot.Get Data From Snapshot    ${logs_dir}/snapshotON/${snapshot_name}
    Set Test Variable  ${found_file_dict}
    Verify snapshot
    ${delta_plan_list}     vduint.get_delta_plan_info_list
    Run Keyword If   ${delta_plan_list}  vduint.delete_delta_plan_file  ${delta_plan_list[0]['plan_id']}

    Log    \nGenerate Delta Plan: actLocInfoStore and modulePositionInformation remove    console=${True}
    Revert Delta Changes
    Set Test Variable    ${REVERT_DELTA_CHANGES}  ${False}
    Log    \nGet Local Snapshot from vDU    console=${True}
    ${collect_vdu_snapshot_status}    ${ignored_error}    Run Keyword And Ignore Error
    ...  vduint.Get Local Snapshot  directory=${logs_dir}/snapshotOFF/
    ...  compressed_or_not=True

    Run Keyword If    '${collect_vdu_snapshot_status}' == 'PASS'
    ...  Log to console  snapshot fron vDU was downloaded
    ...  ELSE    Fail    Snapshot downlaod ${collect_vdu_snapshot_status}

    ${files}    OperatingSystem.List Files In Directory    ${logs_dir}/snapshotOFF/    Snapshot_*.zip
    ${snapshot_name}    Get From List    ${files}    0
    Set Test Variable  ${snapshot_name}
    ${found_file_dict}    snapshot.Get Data From Snapshot    ${logs_dir}/snapshotOFF/${snapshot_name}
    Set Test Variable  ${found_file_dict}
    ${number}    Set Variable    0
    Set Test Variable  ${number}
    FOR  ${serial_number}  IN  @{serial_numbers}
      ${permanent_xml_file_name}  Set Variable  BTS_${serial_number}_RMOD_*_*_permanent.xml.gz
      Set Test Variable    ${permanent_xml_file_name}
      ${found_permanent_file}    Get Match Count    ${found_file_dict}    ${permanent_xml_file_name}
      Run Keyword If    ${found_permanent_file}==1
      ...   Log    \npermanent.xml file for RU: sn: ${serial_number} was found.    console=${TRUE}

      Run Keyword If    ${found_permanent_file}==0  Fail  permanent file for RU: sn ${serial_number} wasn`t found.

      ${number}    Evaluate    ${number} + 1
      unpacking.Unpack Archive Content To Directory  ${logs_dir}/snapshotOFF/${snapshot_name}  ${logs_dir}/snapshotOFF/ex
      unpacking.Unpack Archive Content To Directory  ${logs_dir}/snapshotOFF/ex/RU_${number}.zip  ${logs_dir}/snapshotOFF/ex/ex2
      ${files}    OperatingSystem.List Files In Directory    ${logs_dir}/snapshotOFF/ex/ex2   *_permanent.xml.gz
      ${permanent_file_name}    Get From List    ${files}    0
      unpacking.Unpack Archive Content To Directory  ${logs_dir}/snapshotOFF/ex/ex2/${permanent_file_name}   ${logs_dir}/snapshotOFF/ex/ex2/ex3
      ${permanent_file_name_without_qz}  Fetch From Left  ${permanent_file_name}  .gz
      ${file_content}  OperatingSystem.Get File  ${logs_dir}/snapshotOFF/ex/ex2/ex3/${permanent_file_name_without_qz}
      ${contains_moduleConfiguredLocation}=    Run Keyword And Return Status    Should Contain    ${file_content}    moduleConfiguredLocation
      Run Keyword If    "${contains_moduleConfiguredLocation}"== "False"    Log
      ...    File does not contains entry: moduleConfiguredLocation [OK]    console=${TRUE}
      ...    ELSE    Set Test Failed    failed File contain entry: moduleConfiguredLocation [NOK]
      Run
      ...  cp ${logs_dir}/snapshotOFF/ex/ex2/ex3/${permanent_file_name_without_qz} ${logs_dir}/RU_permanent_filesOFF/${permanent_file_name_without_qz}
    END

*** Keywords ***
Test Teardown
    Run Keyword If  ${REVERT_DELTA_CHANGES}  Run Keywords
    ...    Revert Delta Changes
    ...    AND    Set Test Variable    ${REVERT_DELTA_CHANGES}  ${False}
    Run keyword if  ${LIST_OF_DIRECTORY_TO_DEL_AFTER_UNPACK}!='[]'    Remove All Directories After Unpack
    ${delta_plan_list}     vduint.get_delta_plan_info_list
    Run Keyword If   ${delta_plan_list}  vduint.delete_delta_plan_file  ${delta_plan_list[0]['plan_id']}

Revert Delta Changes
    ${delta_plan_list}     vduint.get_delta_plan_info_list
    Run Keyword If   ${delta_plan_list}  vduint.delete_delta_plan_file  ${delta_plan_list[0]['plan_id']}
    ${delta_res2}    vduint.Generate Delta Plan    actlocoff
    ${plan_id}     Set variable    ${delta_res2['plan_id']}
    Wait until keyword succeeds  3x  2s    Check if delta plan was created on DU    ${delta_res2['action_id']}
    Update Vdu Parameter    ${plan_id}    MRBTS-${vdu_id}/MNL-1/MNLENT-1/FEATCADM-1    ${changed_parameter1}    remove
    Update Vdu Parameter    ${plan_id}    MRBTS-${vdu_id}/MNL-1/MNLENT-1/FEATCADM-1    ${changed_parameter2}    remove
    FOR    ${id}  IN  @{ids}
      Update Vdu Parameter
      ...    ${plan_id}    MRBTS-${vdu_id}/EQM-1/APEQM-1/RMOD-${id}    ${changed_parameter4}    remove

    END

    Log    \nValidate Plan   console=${True}
    ${delta_validation}    vduint.validate_delta_plan   ${plan_id}
    Wait until keyword succeeds  10x  2s    Check if delta plan was validated on DU    ${plan_id}    ${delta_validation['action_id']}

    Log    \nActivate Plan   console=${True}
    ${delta_act}    vduint.Activate Delta Plan    ${plan_id}
    Wait until keyword succeeds  24x  10s    Check if delta plan was activated on DU    ${plan_id}    ${delta_act['id']}

Remove All Directories After Unpack
    FOR  ${dir_to_del}  IN  @{LIST_OF_DIRECTORY_TO_DEL_AFTER_UNPACK}
      Run    rm -rf ${dir_to_del}
    END

Check if delta plan was updated on DU
    [Arguments]    ${plan_id}     ${action_id}
    ${delta_upd}=  vduint.get_update_paras_action_status_of_delta_plan    ${plan_id}    ${action_id}
    Should be true    '${delta_upd['status']}'=='success' or '${delta_upd['status']}'=='failure'
    Run keyword if    '${delta_upd['status']}'=='failure'
    ...    Fail    DU delta plan update failed

Update Vdu Parameter
    [Arguments]    ${plan_id}    ${mo_dn}    ${changed_parameter}    ${operation}
    ${update_res}    vduint.update_vdu_parameter_of_delta_plan
    ...  plan_id=${plan_id}
    ...  mo_dn=${mo_dn}
    ...  updated_paras_dict=${changed_parameter}
    ...  operation=${operation}
    Wait until keyword succeeds  5x  1s    Check if delta plan was updated on DU    ${plan_id}    ${update_res['action_id']}

Check if delta plan was created on DU
    [Arguments]    ${action_id}
    ${delta_gen}=  vduint.get_delta_plan_generated_action_status    ${action_id}
    Should be true    '${delta_gen['status']}'=='success' or '${delta_gen['status']}'=='failure'
    Run keyword if    '${delta_gen['status']}'=='failure'
    ...    Fail    DU delta plan creation failed

Check if delta plan was activated on DU
    [Arguments]    ${plan_id}     ${operation_id}
    ${delta_act}=  vduint.get_activate_delta_plan_operation_status    ${plan_id}    ${operation_id}
    Should be true    '${delta_act['status']}'=='success' or '${delta_act['status']}'=='failure'
    Run keyword if    '${delta_act['status']}'=='failure'
    ...    Fail    DU delta plan activation failed

Check if delta plan was validated on DU
    [Arguments]    ${plan_id}     ${action_id}
    ${delta_validation}=  vduint.get_validate_plan_operation_status    ${plan_id}    ${action_id}
    Should be true    '${delta_validation['status']}'=='success' or '${delta_validation['status']}'=='failure'
    Run keyword if    '${delta_validation['status']}'=='failure'
    ...    Fail    DU delta plan validation failed

Verify snapshot
    [Documentation]
    ...  KW check if snapshot contain permanen file ex.
    ...  BTS_${serial_number}_RMOD_*_*_permanen.xml.gz
    ...  all radios on BTS listed on @{All_supported_ERM6_RU} should have permanen.xml file

    ${number}    Set Variable    0
    Set Test Variable  ${number}
    FOR  ${serial_number}  IN  @{serial_numbers}
        ${permanent_xml_file_name}  Set Variable  BTS_${serial_number}_RMOD_*_*_permanent.xml.gz
        Set Test Variable    ${permanent_xml_file_name}
        ${found_permanent_file}    Get Match Count    ${found_file_dict}    ${permanent_xml_file_name}
        Run Keyword If    ${found_permanent_file}==1
        ...   Log    \npermanent.xml file for RU: sn: ${serial_number} was found.    console=${TRUE}

        Run Keyword If    ${found_permanent_file}==0  Fail  permanent file for RU: sn ${serial_number} wasn`t found.

        ${number}    Evaluate    ${number} + 1
        Check permanent_xml file    ${number}    ${serial_number}
    END
    Log    \n    console=${TRUE}

    ${delta_plan_list}     vduint.get_delta_plan_info_list
    Run Keyword If   ${delta_plan_list}  vduint.delete_delta_plan_file  ${delta_plan_list[0]['plan_id']}

Check permanent_xml file
    [Documentation]
    ...  Kw is responsible for Check permanent_xml file

    [Arguments]    ${number}    ${serial_number}

    Log  Check permanent_xml file  console=${True}

    unpacking.Unpack Archive Content To Directory  ${logs_dir}/snapshotON/${snapshot_name}  ${logs_dir}/snapshotON/ex
    unpacking.Unpack Archive Content To Directory  ${logs_dir}/snapshotON/ex/RU_${number}.zip  ${logs_dir}/snapshotON/ex/ex2

    ${files}    OperatingSystem.List Files In Directory    ${logs_dir}/snapshotON/ex/ex2   *_permanent.xml.gz
    ${permanent_file_name}    Get From List    ${files}    0
    unpacking.Unpack Archive Content To Directory  ${logs_dir}/snapshotON/ex/ex2/${permanent_file_name}   ${logs_dir}/snapshotON/ex/ex2/ex3
    ${permanent_file_name_without_qz}  Fetch From Left  ${permanent_file_name}  .gz
    ${file_content}  OperatingSystem.Get File  ${logs_dir}/snapshotON/ex/ex2/ex3/${permanent_file_name_without_qz}

    ${contains_moduleConfiguredLocation}=    Run Keyword And Return Status    Should Contain    ${file_content}    moduleConfiguredLocation
    ${contains_BtsVersion}=    Run Keyword And Return Status    Should Contain    ${file_content}    BtsVersion
    ${contains_Location}=    Run Keyword And Return Status    Should Contain    ${file_content}    Location
    ${contains_ModuleSerialNumberName}=    Run Keyword And Return Status    Should Contain    ${file_content}    ModuleSerialNumber
    ${contains_ModuleSerialNumber}=    Run Keyword And Return Status    Should Contain    ${file_content}    ${serial_number}
    ${contains_Timestamp}=    Run Keyword And Return Status    Should Contain    ${file_content}    Timestamp
    ${contains_date}=    Run Keyword And Return Status    Should Contain    ${file_content}    ${date}

    Run    cp ${logs_dir}/snapshotON/ex/ex2/ex3/${permanent_file_name_without_qz} ${logs_dir}/RU_permanent_filesON/${permanent_file_name_without_qz}

    Run Keyword If    "${contains_moduleConfiguredLocation}"== "True"    Log    File contains entry: moduleConfiguredLocation    console=${TRUE}
    ...    ELSE    verdicts.Set Test Failed    failed File does not contain entry: moduleConfiguredLocation
    Run Keyword If    "${contains_BtsVersion}"== "True"    Log    File contains entry: BtsVersion    console=${TRUE}
    ...    ELSE    verdicts.Set Test Failed    failed File does not contain entry: BtsVersion
    Run Keyword If    "${contains_Location}"== "True"    Log    File contains entry: Location    console=${TRUE}
    ...    ELSE    verdicts.Set Test Failed    failed File does not contain entry: Location
    Run Keyword If    "${contains_ModuleSerialNumberName}"== "True"    Log    File contains entry: ModuleSerialNumber    console=${TRUE}
    ...    ELSE    verdicts.Set Test Failed    failed File does not contain entry: ModuleSerialNumber
    Run Keyword If    "${contains_ModuleSerialNumber}"== "True"    Log    File contains entry: ${serial_number}    console=${TRUE}
    ...    ELSE    verdicts.Set Test Failed    failed File does not contain entry: ${serial_number}
    Run Keyword If    "${contains_Timestamp}"== "True"    Log    File contains entry: Timestamp    console=${TRUE}
    ...    ELSE    verdicts.Set Test Failed    failed File does not contain entry: Timestamp
    Run Keyword If    "${contains_date}"== "True"    Log    File contains entry: ${date}    console=${TRUE}
    ...    ELSE    verdicts.Set Test Failed    failed File does not contain entry: ${date}

