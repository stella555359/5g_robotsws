*** Settings ***
Resource    ../../../resources/cbrs_common_keywords.robot
Library    taf.sbts.oam.coam.admin    WITH NAME    coam

Documentation    This is for CB007857 ET common keywords
...              Author: Gao,melinda
...              contact: melinda.gao@nokia-sbell.com
...              Squard: HZ SG8

*** Variables ***
${CB007857-ET_conf_path}    ${CURDIR}/conf
${CB007857-A_06_conf}    ${CB007857-ET_conf_path}/SAS_Sim_6.conf
${CB007857-A_23_conf}    ${CB007857-ET_conf_path}/SAS_Sim_23.conf
${CB007857-A_29_conf}    ${CB007857-ET_conf_path}/SAS_Sim_29.conf

${CB007857_json_path}    ${CURDIR}/json
${A-06_Scf_delta_6}    ${CB007857_json_path}/Delta_plan_6.json
${A-06_Scf_delta_pmax}    ${CB007857_json_path}/Delta_plan_desiredpmax_27.json
${A-06_Scf_delta_recovery}    ${CB007857_json_path}/Delta_plan_6_recovery.json
${A-23_scf_delta_23}    ${CB007857_json_path}/Delta_plan_23.json
${A-23_scf_delta_chbw}    ${CB007857_json_path}/Delta_plan_change_desiredChBw.json
${A_23_scf_delta_recovery}    ${CB007857_json_path}/Delta_plan_23_recovery.json
${A-29_scf_delta}    ${CB007857_json_path}/Delta_plan_25.json
${A-29_scf_delta_1}    ${CB007857_json_path}/Delta_plan_29.json
${A-29_scf_recovery}    ${CB007857_json_path}/Scfc_recover.json

${A-06_Scf_delta_6_master}    ${CB007857_json_path}/Delta_plan_6_master.json
${A-06_Scf_delta_pmax_master}    ${CB007857_json_path}/Delta_plan_desiredpmax_27_master.json
${A-06_Scf_delta_recovery_master}    ${CB007857_json_path}/Delta_plan_6_recovery_master.json
${A-23_scf_delta_23_master}    ${CB007857_json_path}/Delta_plan_23_master.json
${A-23_scf_delta_chbw_master}    ${CB007857_json_path}/Delta_plan_change_desiredChBw_master.json
${A_23_scf_delta_recovery_master}    ${CB007857_json_path}/Delta_plan_23_recovery_master.json
${A-29_scf_delta_master}    ${CB007857_json_path}/Delta_plan_25_master.json
${A-29_scf_delta_1_master}    ${CB007857_json_path}/Delta_plan_29_master.json
${A-29_scf_recovery_master}    ${CB007857_json_path}/Scfc_recover_master.json


*** Keywords ***
Case Preparation for CB007857 ET
    &{fault_7313}     Create Dictionary     faultId=${7313}
    ${ALLOWED_FAULT}   Create List   @{ALLOWED_FAULT}   ${fault_7313}
    set suite variable  ${ALLOWED_FAULT}

CB007857-A_06_pmax_exceed_fcc_limitation
    [Arguments]    ${NRCBSDID}=1    ${connection}=GNB_OAM    ${delta_file_1}=${A-06_Scf_delta_6}
    ...    ${delta_file_1_master}=${A-06_Scf_delta_6_master}    ${delta_file_2}=${A-06_Scf_delta_pmax}
    ...    ${delta_file_2_master}=${A-06_Scf_delta_pmax_master}    ${delta_file_teardown}=${A-06_Scf_delta_recovery}
    ...    ${delta_file_teardown_master}=${A-06_Scf_delta_recovery_master}
    Set diff json based on release branch    json1=${delta_file_1_master}    json2=${delta_file_1}
#    coam.perform_delta_recommissioning    delta_file=${delta_file_1}    connection=${connection}
    Sleep    300s    msg= wait for channel changed
    start SAS server    config_name=${CB007857-A_06_conf}
    Wait until keyword succeeds    20min    30s    verify all cells should be onair
    prepare_to_check_message_from_start
    log to console    start check message info...
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 0.*
    Check Register Status By Coam    expect_register_status=Registered    NRCBSDID=${NRCBSDID}
    check SI request and response info
    check grant request and response info
    ${maximumOutputPower}    check_maximumOutputPower_status    value=${14}
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3610000000_3650000000\".*\"responseCode\": 0.*
#    coam.perform_delta_recommissioning    delta_file=${delta_file_2}    connection=${connection}
    Set diff json based on release branch    json1=${delta_file_2_master}    json2=${delta_file_2}
    sleep    600s
    check SI request and response info
    check grant request and response info
    ${maximumOutputPower}    check_maximumOutputPower_status    value=${26.9}
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3610000000_3650000000\".*\"responseCode\": 0.*
    [Teardown]    Run Keywords
    ...    Set diff json based on release branch    json1=${delta_file_teardown_master}    json2=${delta_file_teardown}    AND
    ...    end_to_check

CB007857-A_23_desiredchbw_increased_supportedspectrumv2_widen
    [Arguments]    ${NRCBSDID}=1    ${connection}=GNB_OAM    ${delta_file_1}=${A-23_scf_delta_23}
    ...    ${delta_file_1_master}=${A-23_scf_delta_23_master}    ${delta_file_2}=${A-23_scf_delta_chbw}
    ...    ${delta_file_2_master}=${A-23_scf_delta_chbw_master}    ${delta_file_teardown}=${A_23_scf_delta_recovery}
    ...    ${delta_file_teardown_master}=${A_23_scf_delta_recovery_master}
    log to console    start commission delta plan...
#    coam.perform_delta_recommissioning    delta_file=${delta_file_1}    connection=${connection}
    Set diff json based on release branch    json1=${delta_file_1_master}    json2=${delta_file_1}
    sleep    300s
    start SAS server    config_name=${CB007857-A_23_conf}
    Wait until keyword succeeds    20min    30s    verify all cells should be onair
    prepare_to_check_message_from_start
    log to console   start check message info...
    check register request and response info
    Check Register Status By Coam    expect_register_status=Registered    NRCBSDID=${NRCBSDID}
    check SI request and response info
    check grant request and response info
    ${maximumOutputPower}    check_maximumOutputPower_status    value=${17.9}
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3630000000_3650000000\".*\"responseCode\": 0.*
    log to console    start commission delta plan...
#    coam.perform_delta_recommissioning    delta_file=${delta_file_2}    connection=${connection}
    Set diff json based on release branch    json1=${delta_file_2_master}    json2=${delta_file_2}
    Sleep    60    msg=wait for QuerySasServerPeriod time out
    Wait until keyword succeeds    5min    30s    check SI request and response info
    Wait until keyword succeeds    5min    30s    check grant request and response info
    ${maximumOutputPower}    check_maximumOutputPower_status    value=${19.7}
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3610000000_3640000000\".*\"responseCode\": 0.*
    [Teardown]    Run Keywords
    ...    Set diff json based on release branch    json1=${delta_file_teardown_master}    json2=${delta_file_teardown}    AND
    ...    end_to_check

CB007857-B_29_desiredpmax_decreased
    [Arguments]    ${NRCBSDID}=1    ${connection}=GNB_OAM    ${delta_file_1}=${A-29_scf_delta}
    ...    ${delta_file_1_master}=${A-29_scf_delta_master}    ${delta_file_2}=${A-29_scf_delta_1}
    ...    ${delta_file_2_master}=${A-29_scf_delta_1_master}    ${delta_file_teardown}=${A-29_scf_recovery}
    ...    ${delta_file_teardown_master}=${A-29_scf_recovery_master}
    log to console    start commission delta plan...
#    coam.perform_delta_recommissioning    delta_file=${delta_file_1}    connection=${connection}
    Set diff json based on release branch    json1=${delta_file_1_master}    json2=${delta_file_1}
    sleep    300s
    start SAS server    config_name=${CB007857-A_29_conf}
    Wait until keyword succeeds    20min    30s    verify all cells should be onair
    prepare_to_check_message_from_start
    log to console   start check message info...
    check register request and response info
    Check Register Status By Coam    expect_register_status=Registered    NRCBSDID=${NRCBSDID}
    check SI request and response info
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3650000000\".*\"responseCode\": 0.*
    ${maximumOutputPower}    check_maximumOutputPower_status    value=${27}
    log to console    start commission delta plan...
#    coam.perform_delta_recommissioning    delta_file=${delta_file_2}    connection=${connection}
    Set diff json based on release branch    json1=${delta_file_2_master}    json2=${delta_file_2}
    sleep    300s
    check SI request and response info
    Check if message is found in saslog    tag={\"grantRequest\":.*
#    Check if message is found in saslog    tag={\"grantRequest\":.*\"operationParam\":.*\"maxEirp\":14.1.*\"
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
#    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3650000000\".*\"responseCode\": 0.*
    ${maximumOutputPower}    check_maximumOutputPower_status    value=${14}
    [Teardown]    Run Keywords
    ...    Set diff json based on release branch    json1=${delta_file_teardown_master}    json2=${delta_file_teardown}    AND
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

check_maximumOutputPower_status
    [Arguments]      ${value}    ${connection}=GNB_OAM    ${cell_index}=1
    ${cell_info}    coam.get_cell_specific_info    cell_id=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cell_index}    connection=${connection}
    ${maximumOutputPower}    Set Variable    ${cell_info['maximumOutputPower']}
    should be equal    ${maximumOutputPower}    ${value}
    [Return]    ${maximumOutputPower}
