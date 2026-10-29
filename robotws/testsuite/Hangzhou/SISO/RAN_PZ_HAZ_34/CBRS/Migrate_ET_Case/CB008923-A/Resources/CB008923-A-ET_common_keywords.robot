*** Settings ***
Resource    ../../../resources/cbrs_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Library    taf.sbts.oam.coam.admin    WITH NAME    coam

Documentation    This is for CB007857 common keywords
...              Author: cailanwen
...              Squard: HZ SG8

*** Variables ***
${CB008923-A-ET_conf_path}    ${CURDIR}/conf
${CB008923-A-15_conf}    ${CB008923-A-ET_conf_path}/SAS_Sim15.conf
${CB008923-A_json_path}    ${CURDIR}/json
${CB008923-A-15_recovery_JSON}    ${CB008923-A_json_path}/Delta_plan_13_recovery.json
${CB008923-A-15_recovery_JSON_master}    ${CB008923-A_json_path}/Delta_plan_13_recovery_master.json



*** Keywords ***
Case Preparation for CB008923-A
    ${SCF_8923-A_2CC}    Replace String    ${Golden_SCF_Path}    .xml    _8923-A_2CC.xml
    set suite variable  ${SCF_8923-A_2CC}
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_8923-A_2CC}
    &{fault_7313}     Create Dictionary     faultId=${7313}
    ${ALLOWED_FAULT}   Create List   @{ALLOWED_FAULT}   ${fault_7313}
    set suite variable  ${ALLOWED_FAULT}

CB008923-A_15_ca_enable_heartbeat_501_then_backgroud_hunting
    [Arguments]    ${connection}=GNB_OAM    ${NRCBSDID}=1
    start SAS server    config_name=${CB008923-A-15_conf}
    sleep    40s
#    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    prepare_to_check_message_from_start
    log to console   start check message info...
    Wait Until Keyword Succeeds    200    2    check register request and response info
    Wait Until Keyword Succeeds    200    2
    ...    Check Register Status By Coam    expect_register_status=Registered    NRCBSDID=${NRCBSDID}
    Wait Until Keyword Succeeds    200    2    check SI request and response info
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"grantRequest\":.*\"operationParam\":.*\"maxEirp\":30.1.*\"maxEirp\":31.1.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3610000000_3630000000\".*\"responseCode\": 0.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3630000000_3650000000\".*\"responseCode\": 0.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3630000000_3650000000\".*\"responseCode\": 501.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"grantRequest\":.*\"operationParam\":.*\"maxEirp\":31.0.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    Wait Until Keyword Succeeds    200    2
    ...    check relinquishment request and response info
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3610000000_3630000000\".*\"responseCode\": 0.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 0.*
    [Teardown]    Run Keywords
    ...    Set diff json based on release branch    json1=${CB008923-A-15_recovery_JSON_master}    json2=${CB008923-A-15_recovery_JSON}    AND
    ...    end_to_check

check register request and response info
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 0.*

check SI request and response info
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*

check grant request and response info
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*

check relinquishment request and response info
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*
    Check if message is found in saslog    tag={\"relinquishmentResponse\":.*\"responseCode\": 0.*

check_maximumOutputPower_status
    [Arguments]      ${value}    ${connection}=GNB_OAM    ${cell_index}=1
    ${cell_info}    coam.get_cell_specific_info    cell_id=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cell_index}    connection=${connection}
    ${maximumOutputPower}    Set Variable    ${cell_info['maximumOutputPower']}
    should be equal    ${maximumOutputPower}    ${value}
    [Return]    ${maximumOutputPower}
