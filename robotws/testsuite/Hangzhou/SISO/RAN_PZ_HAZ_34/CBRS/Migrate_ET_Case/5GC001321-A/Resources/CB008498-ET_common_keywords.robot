*** Settings ***
Resource    ../../../resources/cbrs_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Library    taf.sbts.oam.coam.admin    WITH NAME    coam

Documentation    This is for CB008498 ET CBRS common keywords
...              Author: Gao melinda
...              Squard: HZ SG8

*** Variables ***
${CB008498-02_conf}    ${5GC001321_A_conf_path}/SAS_Sim02.conf
${CB008498-44_conf}    ${5GC001321_A_conf_path}/SAS_Sim44.conf
${CB008498-45_conf}    ${5GC001321_A_conf_path}/SAS_Sim45.conf
${CB008498-39_conf}    ${5GC001321_A_conf_path}/SAS_Sim39.conf
${CB008498-36_conf}    ${5GC001321_A_conf_path}/SAS_Sim36.conf
${CB008498-27_conf}    ${5GC001321_A_conf_path}/SAS_Sim27.conf
${CB008498-28_conf}    ${5GC001321_A_conf_path}/SAS_Sim28.conf
${CB008498-25_conf}    ${5GC001321_A_conf_path}/SAS_Sim25.conf
${CB008498-19_conf}    ${5GC001321_A_conf_path}/SAS_Sim19.conf
${CB008498-05_conf}    ${5GC001321_A_conf_path}/SAS_Sim05.conf
${CB008498-11_conf}    ${5GC001321_A_conf_path}/SAS_Sim11.conf
${CB008498-70_conf}    ${5GC001321_A_conf_path}/SAS_Sim70.conf
${CB008498-77_conf}    ${5GC001321_A_conf_path}/SAS_Sim77.conf
${CB008498-68_conf}    ${5GC001321_A_conf_path}/SAS_Sim68.conf
${CB008498-64_conf}    ${5GC001321_A_conf_path}/SAS_Sim64.conf
${CB008498-55_conf}    ${5GC001321_A_conf_path}/SAS_Sim55.conf

${CB008498-02_JSON}    ${5GC001321_A_json_path}/ChangeDesiredpmax.json
${CB008498-02_JSON_trunk}    ${5GC001321_A_json_path}/ChangeDesiredpmax_trunk.json
${CB008498-02_recovery_JSON}    ${5GC001321_A_json_path}/ChangeDesiredpmaxRecovery.json
${CB008498-02_recovery_JSON_trunk}    ${5GC001321_A_json_path}/ChangeDesiredpmaxRecovery_trunk.json
${CB008498-44_JSON}    ${5GC001321_A_json_path}/cbrsFreqPriorityDesiredPmaxcCell2.json
${CB008498-44_JSON_trunk}    ${5GC001321_A_json_path}/cbrsFreqPriorityDesiredPmaxcCell2_trunk.json
${CB008498-44_01_JSON}    ${5GC001321_A_json_path}/cbrsFreqPriorityCell2.json
${CB008498-44_recovery_JSON}    ${5GC001321_A_json_path}/cbrsFreqPriorityDesiredPmaxCell2Recovery.json
${CB008498-44_recovery_JSON_trunk}    ${5GC001321_A_json_path}/cbrsFreqPriorityDesiredPmaxCell2Recovery_trunk.json
${CB008498-45_JSON}    ${5GC001321_A_json_path}/deltaForCase45.json
${CB008498-45_JSON_trunk}    ${5GC001321_A_json_path}/deltaForCase45_trunk.json
${CB008498-45_recovery_JSON}    ${5GC001321_A_json_path}/deltaForCase45recovery.json
${CB008498-45_recovery_JSON_trunk}    ${5GC001321_A_json_path}/deltaForCase45recovery_trunk.json
${CB008498-39_JSON}    ${5GC001321_A_json_path}/deltaPlanForCase39Init.json
${CB008498-39_JSON_trunk}    ${5GC001321_A_json_path}/deltaPlanForCase39Init_trunk.json
${CB008498-39_V2_JSON}    ${5GC001321_A_json_path}/ChangeSupportedSpectrumV2Recovery.json
${CB008498-39_recovery_JSON}    ${5GC001321_A_json_path}/deltaPlanForCase39InitRecovery.json
${CB008498-39_recovery_JSON_trunk}    ${5GC001321_A_json_path}/deltaPlanForCase39InitRecovery_trunk.json
${CB008498-36_JSON}    ${5GC001321_A_json_path}/ChangeDesiredpmax.json
${CB008498-36_JSON_trunk}    ${5GC001321_A_json_path}/ChangeDesiredpmax_trunk.json
${CB008498-36_V2_JSON}    ${5GC001321_A_json_path}/ChangeSupportedSpectrumV2.json
${CB008498-36_recovery_JSON}    ${5GC001321_A_json_path}/deltaPlanForCase36InitRecovery.json
${CB008498-36_recovery_JSON_trunk}    ${5GC001321_A_json_path}/deltaPlanForCase36InitRecovery_trunk.json
${CB008498-27_JSON}    ${5GC001321_A_json_path}/ChangeDesiredpmax.json
${CB008498-27_JSON_trunk}    ${5GC001321_A_json_path}/ChangeDesiredpmax_trunk.json
${CB008498-27_recovery_JSON}    ${5GC001321_A_json_path}/ChangeDesiredpmaxRecovery.json
${CB008498-27_recovery_JSON_trunk}    ${5GC001321_A_json_path}/ChangeDesiredpmaxRecovery_trunk.json
${CB008498-28_JSON}    ${5GC001321_A_json_path}/disenable_ca.json
${CB008498-28_JSON_trunk}    ${5GC001321_A_json_path}/disenable_ca_trunk.json
${CB008498-28_CA_JSON}    ${5GC001321_A_json_path}/carrierAggregationSupportListRecovery.json
${CB008498-25_JSON}    ${5GC001321_A_json_path}/cbrsFreqPriorityDesiredPmax.json
${CB008498-25_JSON_trunk}    ${5GC001321_A_json_path}/cbrsFreqPriorityDesiredPmax_trunk.json
${CB008498-25_period_1min_JSON}    ${5GC001321_A_json_path}/querySasServerPeriod1min.json
${CB008498-25_recovery_JSON}    ${5GC001321_A_json_path}/cbrsFreqPriorityDesiredPmaxRecovery.json
${CB008498-25_recovery_JSON_trunk}    ${5GC001321_A_json_path}/cbrsFreqPriorityDesiredPmaxRecovery_trunk.json
${CB008498-19_JSON}    ${5GC001321_A_json_path}/administrativeStateDesiredPmax.json
${CB008498-19_JSON_trunk}    ${5GC001321_A_json_path}/administrativeStateDesiredPmax_trunk.json
${CB008498-19_01_JSON}    ${5GC001321_A_json_path}/administrativeStateRecovery.json
${CB008498-19_recovery_JSON}    ${5GC001321_A_json_path}/administrativeStateDesiredPmaxRecovery.json
${CB008498-19_recovery_JSON_trunk}    ${5GC001321_A_json_path}/administrativeStateDesiredPmaxRecovery_trunk.json
${CB008498-05_JSON}    ${5GC001321_A_json_path}/administrativeState.json
${CB008498-05_01_JSON}    ${5GC001321_A_json_path}/administrativeStateRecovery.json
${CB008498-11_JSON}    ${5GC001321_A_json_path}/desiredPmaxAndQuerySas.json
${CB008498-11_JSON_trunk}    ${5GC001321_A_json_path}/desiredPmaxAndQuerySas_trunk.json
${CB008498-11_recovery_JSON}    ${5GC001321_A_json_path}/desiredPmaxAndQuerySasRecovery.json
${CB008498-11_recovery_JSON_trunk}    ${5GC001321_A_json_path}/desiredPmaxAndQuerySasRecovery_trunk.json
${CB008498-70_JSON}    ${5GC001321_A_json_path}/cbrsFreqPriority.json
${CB008498-70_recovery_JSON}    ${5GC001321_A_json_path}/cbrsFreqPriorityRecovery.json
${CB008498-77_JSON}    ${5GC001321_A_json_path}/cbrsFreqPriority.json
${CB008498-77_recovery_JSON}    ${5GC001321_A_json_path}/cbrsFreqPriorityRecovery.json
${CB008498-68_JSON}    ${5GC001321_A_json_path}/cbrsFreqPriority.json
${CB008498-68_recovery_JSON}    ${5GC001321_A_json_path}/cbrsFreqPriorityRecovery.json
${CB008498-64_JSON}    ${5GC001321_A_json_path}/cbrsFreqPriority.json
${CB008498-64_recovery_JSON}    ${5GC001321_A_json_path}/cbrsFreqPriorityRecovery.json


*** Keywords ***
Case Preparation for CB008498 enable CA
    ${SCF_8498_CA_2CC}    Replace String    ${Golden_SCF_Path}    .xml    _8498_CA_2CC.xml
    set suite variable  ${SCF_8498_CA_2CC}
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_8498_CA_2CC}
    &{fault_7313}     Create Dictionary     faultId=${7313}
    ${ALLOWED_FAULT}   Create List   @{ALLOWED_FAULT}   ${fault_7313}
    set suite variable  ${ALLOWED_FAULT}

Case Preparation for CB008498 disable CA
    ${SCF_8498_disCA_2CC}    Replace String    ${Golden_SCF_Path}    .xml    _8498_disCA_2CC.xml
    set suite variable  ${SCF_8498_disCA_2CC}
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_8498_disCA_2CC}
    &{fault_7313}     Create Dictionary     faultId=${7313}
    ${ALLOWED_FAULT}   Create List   @{ALLOWED_FAULT}   ${fault_7313}
    set suite variable  ${ALLOWED_FAULT}

CB008498_02_disableCA_low_priority_cell_preempt_best_channel_when_two_cells_activated
    [Arguments]    ${connection}=GNB_OAM    ${NRCBSDID}=1
    coam.perform_delta_recommissioning    delta_file=${CB008498-02_JSON_trunk}    connection=${connection}
#    Set diff json based on release branch    json1=${CB008498-02_JSON_trunk}    json2=${CB008498-02_JSON}
    sleep    300s
    start SAS server    config_name=${CB008498-02_conf}
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    prepare_to_check_message_from_start
    log to console   start check message info...
    check register request and response info
    Check Register Status By Coam    expect_register_status=Registered    NRCBSDID=${NRCBSDID}
    check SI request and response info
    Check if message is found in saslog    tag={\"grantRequest\":.*\"operationParam\":.*\"maxEirp\":24.1.*\"maxEirp\":24.1.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"PAL\".*\"PAL\".*\"responseCode\": 0.*
    check_maximumOutputPower_status    value=${20}    cell_index=1
    check_maximumOutputPower_status    value=${20}    cell_index=2
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3610000000_3630000000\".*\"responseCode\": 0.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3630000000_3650000000\".*\"responseCode\": 0.*
    end_to_check
    [Teardown]    coam.perform_delta_recommissioning    delta_file=${CB008498-02_recovery_JSON_trunk}    connection=${connection}
#    [Teardown]    Set diff json based on release branch    json1=${CB008498-02_recovery_JSON_trunk}    json2=${CB008498-02_recovery_JSON}

CB008498_44_enableCA_high_priority_cell_not_preempt_best_channel_when_cbrsfreqpriority_increased
    [Arguments]    ${connection}=GNB_OAM    ${NRCBSDID}=1
#    Set diff json based on release branch    json1=${CB008498-44_JSON_trunk}    json2=${CB008498-44_JSON}
    coam.perform_delta_recommissioning    delta_file=${CB008498-44_JSON_trunk}    connection=${connection}
    sleep    300s
    start SAS server    config_name=${CB008498-44_conf}
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    prepare_to_check_message_from_start
    log to console   start check message info...
    check register request and response info
    Check Register Status By Coam    expect_register_status=Registered    NRCBSDID=${NRCBSDID}
    check SI request and response info
    check grant request and response info
    check_maximumOutputPower_status    value=${25}    cell_index=1
    check_maximumOutputPower_status    value=${20}    cell_index=2
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3610000000_3630000000\".*\"responseCode\": 0.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3630000000_3650000000\".*\"responseCode\": 0.*
    coam.perform_delta_recommissioning    delta_file=${CB008498-44_01_JSON}    connection=${connection}
    sleep    300s
    check SI request and response info
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3610000000_3630000000\".*\"responseCode\": 0.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3630000000_3650000000\".*\"responseCode\": 0.*
    end_to_check
#    [Teardown]     Set diff json based on release branch    json1=${CB008498-44_recovery_JSON_trunk}    json2=${CB008498-44_recovery_JSON}
    [Teardown]    coam.perform_delta_recommissioning    delta_file=${CB008498-44_recovery_JSON_trunk}    connection=${connection}

CB008498_45_enableCA_low_priority_cell_preempt_best_channel_when_desiredpmax_increased
    [Arguments]    ${connection}=GNB_OAM    ${NRCBSDID}=1
#    Set diff json based on release branch    json1=${CB008498-45_JSON_trunk}    json2=${CB008498-45_JSON}
    coam.perform_delta_recommissioning    delta_file=${CB008498-45_JSON_trunk}    connection=${connection}
    sleep    300s
    start SAS server    config_name=${CB008498-45_conf}
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    prepare_to_check_message_from_start
    log to console   start check message info...
    check register request and response info
    Check Register Status By Coam    expect_register_status=Registered    NRCBSDID=${NRCBSDID}
    check SI request and response info
    Check if message is found in saslog    tag={\"grantRequest\":.*\"operationParam\":.*\"maxEirp\":24.1.*\"maxEirp\":24.1.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    check_maximumOutputPower_status    value=${20}    cell_index=1
    check_maximumOutputPower_status    value=${20}    cell_index=2
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3610000000_3630000000\".*\"responseCode\": 0.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3630000000_3650000000\".*\"responseCode\": 0.*
#    Set diff json based on release branch    json1=${CB008498-02_recovery_JSON_trunk}    json2=${CB008498-02_recovery_JSON}
    coam.perform_delta_recommissioning    delta_file=${CB008498-02_recovery_JSON_trunk}    connection=${connection}
    sleep    300s
    check SI request and response info
    check relinquishment request and response info
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"grantRequest\":.*\"operationParam\":.*\"maxEirp\":24.1.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3610000000_3630000000\".*\"responseCode\": 0.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3630000000_3650000000\".*\"responseCode\": 0.*
    end_to_check
#    [Teardown]    Set diff json based on release branch    json1=${CB008498-45_recovery_JSON_trunk}    json2=${CB008498-45_recovery_JSON}
    [Teardown]    coam.perform_delta_recommissioning    delta_file=${CB008498-45_recovery_JSON_trunk}    connection=${connection}

CB008498_39_disableCA_low_priority_cell_preempt_best_channel_when_new_channel_added
    [Arguments]    ${connection}=GNB_OAM    ${NRCBSDID}=1
    coam.perform_delta_recommissioning    delta_file=${CB008498-39_JSON_trunk}    connection=${connection}
#    Set diff json based on release branch    json1=${CB008498-39_JSON_trunk}    json2=${CB008498-39_JSON}
    sleep    300s
    start SAS server    config_name=${CB008498-39_conf}
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    prepare_to_check_message_from_start
    log to console   start check message info...
    check register request and response info
    Check Register Status By Coam    expect_register_status=Registered    NRCBSDID=${NRCBSDID}
    check SI request and response info
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"PAL\".*\"PAL\".*\"responseCode\": 0.*
    check_maximumOutputPower_status    value=${20}    cell_index=1
    check_maximumOutputPower_status    value=${20}    cell_index=2
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3630000000_3650000000\".*\"responseCode\": 0.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 0.*
    coam.perform_delta_recommissioning    delta_file=${CB008498-39_V2_JSON}    connection=${connection}
    sleep    300s
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*\"grantId\":\"3630000000_3650000000\".*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"relinquishmentResponse\":.*\"responseCode\": 0.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"grantRequest\":.*\"operationParam\":.*\"maxEirp\":29.1.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    check_maximumOutputPower_status    value=${25}    cell_index=1
    check_maximumOutputPower_status    value=${20}    cell_index=2
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3600000000_3620000000\".*\"responseCode\": 0.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 0.*
    end_to_check
    [Teardown]    coam.perform_delta_recommissioning    delta_file=${CB008498-39_recovery_JSON_trunk}    connection=${connection}
#    [Teardown]    Set diff json based on release branch    json1=${CB008498-39_recovery_JSON_trunk}    json2=${CB008498-39_recovery_JSON}

CB008498_36_disableCA_low_priority_cell_preempt_best_channel_when_used_channel_removed
    [Arguments]    ${connection}=GNB_OAM    ${NRCBSDID}=1
    coam.perform_delta_recommissioning    delta_file=${CB008498-36_JSON_trunk}    connection=${connection}
#    Set diff json based on release branch    json1=${CB008498-36_JSON_trunk}    json2=${CB008498-36_JSON}
    sleep    300s
    start SAS server    config_name=${CB008498-36_conf}
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    prepare_to_check_message_from_start
    log to console   start check message info...
    check register request and response info
    Check Register Status By Coam    expect_register_status=Registered    NRCBSDID=${NRCBSDID}
    check SI request and response info
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"PAL\".*\"PAL\".*\"responseCode\": 0.*
    check_maximumOutputPower_status    value=${25}    cell_index=1
    check_maximumOutputPower_status    value=${20}    cell_index=2
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3600000000_3620000000\".*\"responseCode\": 0.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 0.*
    coam.perform_delta_recommissioning    delta_file=${CB008498-36_V2_JSON}    connection=${connection}
    sleep    300s
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"grantResponse\":.*\"PAL\".*\"PAL\".*\"responseCode\": 0.*
    check_maximumOutputPower_status    value=${25}    cell_index=1
    check_maximumOutputPower_status    value=${20}    cell_index=2
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3630000000_3650000000\".*\"responseCode\": 0.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 0.*
    end_to_check
    [Teardown]    coam.perform_delta_recommissioning    delta_file=${CB008498-36_recovery_JSON_trunk}    connection=${connection}
#    [Teardown]    Set diff json based on release branch    json1=${CB008498-36_recovery_JSON_trunk}    json2=${CB008498-36_recovery_JSON}

CB008498_27_enableCA_high_priority_cell_not_preempt_best_channel_when_heartbeat50X_received
    [Arguments]    ${connection}=GNB_OAM    ${NRCBSDID}=1
#    Set diff json based on release branch    json1=${CB008498-27_JSON_trunk}    json2=${CB008498-27_JSON}
    coam.perform_delta_recommissioning    delta_file=${CB008498-27_JSON_trunk}    connection=${connection}
    sleep    300s
    start SAS server    config_name=${CB008498-27_conf}
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    prepare_to_check_message_from_start
    log to console   start check message info...
    check register request and response info
    Check Register Status By Coam    expect_register_status=Registered    NRCBSDID=${NRCBSDID}
    check SI request and response info
    check grant request and response info
    check_maximumOutputPower_status    value=${25}    cell_index=1
    check_maximumOutputPower_status    value=${20}    cell_index=2
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3610000000_3630000000\".*\"responseCode\": 0.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3590000000_3610000000\".*\"responseCode\": 0.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3590000000_3610000000\".*\"responseCode\": 501.*
    Wait Until Keyword Succeeds    200    2
    ...    check SI request and response info
    Wait Until Keyword Succeeds    200    2
    ...    check grant request and response info
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3630000000_3650000000\".*\"responseCode\": 0.*
    Wait Until Keyword Succeeds    200    2
    ...    check relinquishment request and response info
    end_to_check
#    [Teardown]     Set diff json based on release branch    json1=${CB008498-27_recovery_JSON_trunk}    json2=${CB008498-27_recovery_JSON}
    [Teardown]    coam.perform_delta_recommissioning    delta_file=${CB008498-27_recovery_JSON_trunk}    connection=${connection}

CB008498_28_enableCA_high_priority_cell_preempt_best_channel_when_ca_disabled_to_enable
    [Arguments]    ${connection}=GNB_OAM    ${NRCBSDID}=1
#    Set diff json based on release branch    json1=${CB008498-28_JSON_trunk}    json2=${CB008498-28_JSON}
    coam.perform_delta_recommissioning    delta_file=${CB008498-28_JSON_trunk}    connection=${connection}
    sleep    300s    msg=wait update channelSpacing...
    start SAS server    config_name=${CB008498-28_conf}
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    prepare_to_check_message_from_start
    log to console   start check message info...
    check register request and response info
    Check Register Status By Coam    expect_register_status=Registered    NRCBSDID=${NRCBSDID}
    check SI request and response info
    Check if message is found in saslog    tag={\"grantRequest\":.*\"operationParam\":.*\"maxEirp\":29.1.*\"maxEirp\":29.1.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    check_maximumOutputPower_status    value=${25}    cell_index=1
    check_maximumOutputPower_status    value=${25}    cell_index=2
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3610000000_3630000000\".*\"responseCode\": 0.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 0.*
    coam.perform_delta_recommissioning    delta_file=${CB008498-28_CA_JSON}    connection=${connection}
    sleep    300s    msg=wait update channelSpacing...
    Wait Until Keyword Succeeds    200    2
    ...    check SI request and response info
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"relinquishmentResponse\":.*\"responseCode\": 0.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"grantRequest\":.*
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
    check_maximumOutputPower_status    value=${20}    cell_index=1
    check_maximumOutputPower_status    value=${25}    cell_index=2
    end_to_check
    [Teardown]    coam.perform_delta_recommissioning    delta_file=${CB008498-28_CA_JSON}    connection=${connection}

CB008498_25_enableCA_low_priority_cell_preempt_best_channel_when_background_hunting
    [Arguments]    ${connection}=GNB_OAM    ${NRCBSDID}=1
#    Set diff json based on release branch    json1=${CB008498-25_JSON_trunk}    json2=${CB008498-25_JSON}
    coam.perform_delta_recommissioning    delta_file=${CB008498-25_JSON_trunk}    connection=${connection}
    sleep    300s    msg=wait update ...
    start SAS server    config_name=${CB008498-25_conf}
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    prepare_to_check_message_from_start
    log to console   start check message info...
    check register request and response info
    Check Register Status By Coam    expect_register_status=Registered    NRCBSDID=${NRCBSDID}
    check SI request and response info
    Check if message is found in saslog    tag={\"grantRequest\":.*\"operationParam\":.*\"maxEirp\":24.1.*\"maxEirp\":24.1.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    check_maximumOutputPower_status    value=${20}    cell_index=1
    check_maximumOutputPower_status    value=${20}    cell_index=2
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3610000000_3630000000\".*\"responseCode\": 0.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3630000000_3650000000\".*\"responseCode\": 0.*
    coam.perform_delta_recommissioning    delta_file=${CB008498-25_period_1min_JSON}    connection=${connection}
    sleep    300s    msg=wait update ...
    check SI request and response info
    check grant request and response info
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3610000000_3630000000\".*\"responseCode\": 0.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3630000000_3650000000\".*\"responseCode\": 0.*
    end_to_check
#    [Teardown]    Set diff json based on release branch    json1=${CB008498-25_recovery_JSON_trunk}    json2=${CB008498-25_recovery_JSON}
    [Teardown]    coam.perform_delta_recommissioning    delta_file=${CB008498-25_recovery_JSON_trunk}    connection=${connection}

CB008498_19_enableCA_high_priority_cell_not_preempt_best_channel_when_one_cell_activated
    [Arguments]    ${connection}=GNB_OAM    ${NRCBSDID}=1
#    Set diff json based on release branch    json1=${CB008498-19_JSON_trunk}    json2=${CB008498-19_JSON}
    coam.perform_delta_recommissioning    delta_file=${CB008498-19_JSON_trunk}    connection=${connection}
    sleep    300s    msg=wait update ...
    start SAS server    config_name=${CB008498-19_conf}
    sleep    60s
#    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    prepare_to_check_message_from_start
    log to console   start check message info...
    check register request and response info
    Check Register Status By Coam    expect_register_status=Registered    NRCBSDID=${NRCBSDID}
    check SI request and response info
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"grantRequest\":.*\"operationParam\":.*\"maxEirp\":29.1.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 0.*
    coam.perform_delta_recommissioning    delta_file=${CB008498-19_01_JSON}    connection=${connection}
    sleep    300s    msg=wait update ...
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3610000000_3630000000\".*\"responseCode\": 0.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3630000000_3650000000\".*\"responseCode\": 0.*
    check_maximumOutputPower_status    value=${25}    cell_index=1
    check_maximumOutputPower_status    value=${20}    cell_index=2
    end_to_check
#    [Teardown]    Set diff json based on release branch    json1=${CB008498-19_recovery_JSON_trunk}    json2=${CB008498-19_recovery_JSON}
    [Teardown]    coam.perform_delta_recommissioning    delta_file=${CB008498-19_recovery_JSON_trunk}    connection=${connection}

CB008498_05_disableCA_high_priority_cell_preempt_best_channel_when_one_cell_activated
    [Arguments]    ${connection}=GNB_OAM    ${NRCBSDID}=1
    coam.perform_delta_recommissioning    delta_file=${CB008498-05_JSON}    connection=${connection}
    sleep    300s    msg=wait update ...
    start SAS server    config_name=${CB008498-05_conf}
    sleep    5min
#    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    prepare_to_check_message_from_start
    log to console   start check message info...
    check register request and response info
#    Check Register Status By Coam    expect_register_status=Registered    NRCBSDID=${NRCBSDID}
    Check if message is found in saslog    tag={\"grantRequest\":.*\"operationParam\":.*\"maxEirp\":29.1.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"PAL\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3620000000_3640000000\".*\"responseCode\": 0.*
    coam.perform_delta_recommissioning    delta_file=${CB008498-05_01_JSON}    connection=${connection}
    sleep    300s    msg=wait update ...
    check SI request and response info
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"PAL\".*\"responseCode\": 0.*
    end_to_check
    [Teardown]    coam.perform_delta_recommissioning    delta_file=${CB008498-05_01_JSON}    connection=${connection}

CB008498_11_disableCA_high_priority_cell_not_preempt_best_channel_when_background_hunting
    [Arguments]    ${connection}=GNB_OAM    ${NRCBSDID}=1
    coam.perform_delta_recommissioning    delta_file=${CB008498-11_JSON_trunk}    connection=${connection}
#    Set diff json based on release branch    json1=${CB008498-11_JSON_trunk}    json2=${CB008498-11_JSON}
    sleep    300s    msg=wait update ...
    start SAS server    config_name=${CB008498-11_conf}
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    prepare_to_check_message_from_start
    log to console   start check message info...
    check register request and response info
    Check Register Status By Coam    expect_register_status=Registered    NRCBSDID=${NRCBSDID}
    check SI request and response info
    check grant request and response info
    check_maximumOutputPower_status   value=${25}    cell_index=1
    check_maximumOutputPower_status   value=${20}    cell_index=2
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3620000000_3640000000\".*\"responseCode\": 0.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 0.*
    Wait Until Keyword Succeeds    200    2    check SI request and response info
    Wait Until Keyword Succeeds    200    2
    ...    check relinquishment request and response info
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"grantRequest\":.*\"operationParam\":.*\"maxEirp\":24.1.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    sleep    20s
    check_maximumOutputPower_status   value=${20}    cell_index=1
    check_maximumOutputPower_status   value=${20}    cell_index=2
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3610000000_3630000000\".*\"responseCode\": 0.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3630000000_3650000000\".*\"responseCode\": 0.*
    end_to_check
    [Teardown]    coam.perform_delta_recommissioning    delta_file=${CB008498-11_recovery_JSON_trunk}    connection=${connection}
#    [Teardown]    Set diff json based on release branch    json1=${CB008498-11_recovery_JSON_trunk}    json2=${CB008498-11_recovery_JSON}

CB008498_70_second_grant_abort_relinquish102
    [Arguments]    ${connection}=GNB_OAM    ${NRCBSDID}=1
    coam.perform_delta_recommissioning    delta_file=${CB008498-70_JSON}    connection=${connection}
    sleep    300s    msg=wait update ...
    start SAS server    config_name=${CB008498-70_conf}
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    prepare_to_check_message_from_start
    log to console   start check message info...
    check register request and response info
    Check Register Status By Coam    expect_register_status=Registered    NRCBSDID=${NRCBSDID}
    check SI request and response info
    Check if message is found in saslog    tag={\"grantRequest\":.*\"operationParam\":.*\"maxEirp\":29.1.*\"maxEirp\":29.1.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"PAL\".*\"PAL\".*\"responseCode\": 0.*
    check_maximumOutputPower_status    value=${25}    cell_index=1
    check_maximumOutputPower_status    value=${25}    cell_index=2
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 0.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3570000000_3590000000\".*\"responseCode\": 0.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3570000000_3590000000\".*\"responseCode\": 501.*
    Wait Until Keyword Succeeds    200    2
    ...    check SI request and response info
    Wait Until Keyword Succeeds    200    2
    ...    check grant request and response info
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3590000000_3610000000\".*\"responseCode\": 0.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*\"grantId\":\"3570000000_3590000000\".*
    Check if message is found in saslog    tag={\"relinquishmentResponse\":.*\"responseCode\": 102.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 0.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3590000000_3610000000\".*\"responseCode\": 0.*
    end_to_check
    [Teardown]    coam.perform_delta_recommissioning    delta_file=${CB008498-70_recovery_JSON}    connection=${connection}

CB008498_77_heartbeat501_second_grant_no_available_channel
    [Arguments]    ${connection}=GNB_OAM    ${NRCBSDID}=1
    coam.perform_delta_recommissioning    delta_file=${CB008498-77_JSON}    connection=${connection}
    sleep    300s    msg=wait update ...
    start SAS server    config_name=${CB008498-77_conf}
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    prepare_to_check_message_from_start
    log to console   start check message info...
    check register request and response info
    Check Register Status By Coam    expect_register_status=Registered    NRCBSDID=${NRCBSDID}
    check SI request and response info
    Check if message is found in saslog    tag={\"grantRequest\":.*\"operationParam\":.*\"maxEirp\":29.1.*\"maxEirp\":29.1.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"PAL\".*\"PAL\".*\"responseCode\": 0.*
    check_maximumOutputPower_status    value=${25}    cell_index=1
    check_maximumOutputPower_status    value=${25}    cell_index=2
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3570000000_3590000000\".*\"responseCode\": 501.*
    Wait Until Keyword Succeeds    200    2    check SI request and response info
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 0.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3570000000_3590000000\".*\"responseCode\": 0.*
    end_to_check
    [Teardown]    coam.perform_delta_recommissioning    delta_file=${CB008498-77_recovery_JSON}    connection=${connection}

CB008498_68_second_grant_abort_heartbeat105
    [Arguments]    ${connection}=GNB_OAM    ${NRCBSDID}=1
    coam.perform_delta_recommissioning    delta_file=${CB008498-68_JSON}    connection=${connection}
    sleep    300s    msg=wait update ...
    start SAS server    config_name=${CB008498-68_conf}
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    prepare_to_check_message_from_start
    log to console   start check message info...
    check register request and response info
    Check Register Status By Coam    expect_register_status=Registered    NRCBSDID=${NRCBSDID}
    check SI request and response info
    Check if message is found in saslog    tag={\"grantRequest\":.*\"operationParam\":.*\"maxEirp\":29.1.*\"maxEirp\":29.1.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"PAL\".*\"PAL\".*\"responseCode\": 0.*
    check_maximumOutputPower_status    value=${25}    cell_index=1
    check_maximumOutputPower_status    value=${25}    cell_index=2
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 0.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3570000000_3590000000\".*\"responseCode\": 0.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3570000000_3590000000\".*\"responseCode\": 501.*
    Wait Until Keyword Succeeds    200    2
    ...    check SI request and response info
    Wait Until Keyword Succeeds    200    2    check grant request and response info
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3590000000_3610000000\".*\"responseCode\": 105.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 0.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3570000000_3590000000\".*\"responseCode\": 0.*
    end_to_check
    [Teardown]    coam.perform_delta_recommissioning    delta_file=${CB008498-68_recovery_JSON}     connection=${connection}

CB008498_64_second_grant_abort_grant100
    [Arguments]    ${connection}=GNB_OAM    ${NRCBSDID}=1
    coam.perform_delta_recommissioning    delta_file=${CB008498-64_JSON}    connection=${connection}
    sleep    300s    msg=wait update ...
    start SAS server    config_name=${CB008498-64_conf}
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    prepare_to_check_message_from_start
    log to console   start check message info...
    check register request and response info
    Check Register Status By Coam    expect_register_status=Registered    NRCBSDID=${NRCBSDID}
    check SI request and response info
    Check if message is found in saslog    tag={\"grantRequest\":.*\"operationParam\":.*\"maxEirp\":29.1.*\"maxEirp\":29.1.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"PAL\".*\"PAL\".*\"responseCode\": 0.*
    check_maximumOutputPower_status    value=${25}    cell_index=1
    check_maximumOutputPower_status    value=${25}    cell_index=2
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 0.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3570000000_3590000000\".*\"responseCode\": 0.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3570000000_3590000000\".*\"responseCode\": 501.*
    Wait Until Keyword Succeeds    200    2
    ...    check SI request and response info
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"grantRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 100.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3570000000_3590000000\".*\"responseCode\": 0.*
    end_to_check
    [Teardown]    coam.perform_delta_recommissioning    delta_file=${CB008498-64_recovery_JSON}     connection=${connection}

CB008498_55_pal_gaa_out_of_110mhz_range
    [Arguments]    ${connection}=GNB_OAM    ${NRCBSDID}=1
    start SAS server    config_name=${CB008498-55_conf}
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    prepare_to_check_message_from_start
    log to console   start check message info...
    check register request and response info
    Check Register Status By Coam    expect_register_status=Registered    NRCBSDID=${NRCBSDID}
    check SI request and response info
    check grant request and response info
    check_maximumOutputPower_status    value=${20}    cell_index=1
    check_maximumOutputPower_status    value=${25}    cell_index=2
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 0.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3570000000_3590000000\".*\"responseCode\": 0.*
    end_to_check

check register request and response info
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 0.*

check deregister request and response info
    Check if message is found in saslog    tag={\"deregistrationRequest\":.*
    Check if message is found in saslog    tag={\"deregistrationResponse\":.*\"responseCode\": 0.*

check SI request and response info
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*

check grant request and response info
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*

check relinquishment request and response info
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*
    Check if message is found in saslog    tag={\"relinquishmentResponse\":.*\"responseCode\": 0.*

check heartbeat request and response info
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"responseCode\": 0.*

check_maximumOutputPower_status
    [Arguments]      ${value}    ${connection}=GNB_OAM    ${cell_index}=1
    ${cell_info}    coam.get_cell_specific_info    cell_id=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cell_index}    connection=${connection}
    ${maximumOutputPower}    Set Variable    ${cell_info['maximumOutputPower']}
    should be equal    ${maximumOutputPower}    ${value}
    [Return]    ${maximumOutputPower}
