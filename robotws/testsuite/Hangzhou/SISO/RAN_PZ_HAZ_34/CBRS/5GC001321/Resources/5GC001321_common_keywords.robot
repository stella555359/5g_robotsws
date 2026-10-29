*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    ../../resources/cbrs_common_keywords.robot
Variables    ../TestData/1321_variables.py

Documentation    This is for SG8 common keywords
...              Author: linjiangjing & cailanwen & wangqingqing
...              Squard: HZ SG8

*** Variables ***
${sas_log_path}    ${CURDIR}/../../resources/SASSim_HZ/SAS_Sim.log
${conf_path}    ${CURDIR}/conf
${proxy_conf_path}    ${CURDIR}/../../resources/Proxy_Config
${5GC001321_A_13_conf}    ${conf_path}/5GC001321_A_13.conf
${5GC001321_A_17_conf}    ${conf_path}/5GC001321_A_17.conf
${5GC001321_A_24_conf}    ${conf_path}/5GC001321_A_24.conf
${5GC001321_A_29_conf}    ${conf_path}/5GC001321_A_29.conf
${5GC001321_A_38_conf}    ${conf_path}/5GC001321_A_38.conf
${5GC001321_A_39_conf}    ${conf_path}/5GC001321_A_39.conf
${5GC001321_A_44_conf}    ${conf_path}/5GC001321_A_44.conf
${5GC001321_A_46_conf}    ${conf_path}/5GC001321_A_46.conf
${5GC001321_A_47_conf}    ${conf_path}/5GC001321_A_47.conf
${5GC001321_A_49_conf}    ${conf_path}/5GC001321_A_49.conf
${5GC001321_A_60_conf}    ${conf_path}/5GC001321_A_60.conf
${5GC001321_A_64_conf}    ${conf_path}/5GC001321_A_64.conf
${5GC001321_A_65_conf}    ${conf_path}/5GC001321_A_65.conf
${5GC001321_A_66_conf}    ${conf_path}/5GC001321_A_66.conf
${5GC001321_A_68_conf}    ${conf_path}/5GC001321_A_68.conf
${5GC001321_A_69_conf}    ${conf_path}/5GC001321_A_69.conf
${5GC001321_A_70_conf}    ${conf_path}/5GC001321_A_70.conf
${5GC001321_A_71_conf}    ${conf_path}/5GC001321_A_71.conf
${5GC001321_A_76_conf}    ${conf_path}/5GC001321_A_76.conf
${5GC001321_A_79_conf}    ${conf_path}/5GC001321_A_79.conf
${5GC001321_A_81_conf}    ${conf_path}/5GC001321_A_81.conf
${5GC001321_A_82_conf}    ${conf_path}/5GC001321_A_82.conf
${5GC001321_E_7_proxy_conf}    ${proxy_conf_path}/Second_Https_Proxy.conf
${group_type}    lx
${group_id}    liuxu
${ENB_WEBUI_IP}          ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${USERNAME}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
*** Keywords ***
5GC001321_A_13_Verify_the_behavior_of_CBSD_registration_failure_due_to_group_error
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] To verify the registration failure due to group error
    ...    *******************
    ...    jiangjing.lin@nokia-sbell.com
    ${cbsd_nums}    Get CBSD Numbers    scf_file_path=${scf_path}
    Run Keyword If    ${cbsd_nums}!=1    Run Keywords
    ...    Commissioning SCF And Check RU On Air   scf_file_path=${Golden_SCF_Path}
    ...    AND    Activate feature CBRS By Coam
    start SAS server    config_name=${5GC001321_A_13_conf}
    Wait Until Keyword Succeeds    5min    5s    Check Register Status By Coam    expect_register_status=Unregistered
    log to console    wait for fault 6826
    Wait For Expect Fault Present    faultId=6826   timeout=1200
    Wait Until Keyword Succeeds    5min    5s    Check Register Fail Message Dueto Code 201

5GC001321_A_17_Verify_the_registration_with_groupID_groupType_configured_is_successful
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] To verify the registration with groupID and groupType configured is successful
    ...    *******************
    ...    jiangjing.lin@nokia-sbell.com

    ${cbsd_nums}    Get CBSD Numbers    scf_file_path=${scf_path}
    Run Keyword If    ${cbsd_nums}!=1    Run Keywords
    ...    Commissioning SCF And Check RU On Air   scf_file_path=${Golden_SCF_Path}
    ...    AND    Activate feature CBRS By Coam
    Set SAS UserGroup By Coam    groupType=${group_type}    groupIdString=${group_id}
    start SAS server    config_name=${5GC001321_A_17_conf}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Wait Until Keyword Succeeds    5min    5s    Check Register Status By Coam
    Wait Until Keyword Succeeds    5min    5s    Check TS Version By Coam
    Check Register Success Message

5GC001321_A_24_Verify_CBSD_Spectrum_Inquiry_failure_due_to_responde_code_106
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] To verify the spectrum inquiry failure due to respond code 106
    ...    *******************
    ...    jiangjing.lin@nokia-sbell.com
    ${cbsd_nums}    Get CBSD Numbers    scf_file_path=${scf_path}
    Run Keyword If    ${cbsd_nums}!=1    Run Keywords
    ...    Commissioning SCF And Check RU On Air   scf_file_path=${Golden_SCF_Path}
    ...    AND    Activate feature CBRS By Coam
    start SAS server    config_name=${5GC001321_A_24_conf}
    Wait Until Keyword Succeeds    5min    5s    Check Register Status By Coam
    log to console    wait for fault 6827
    wait For Expect Fault Present    faultId=6827   timeout=1200
    Check Register Success Message    groupId_need=${False}    groupType_need=${False}
    Wait Until Keyword Succeeds    5min    5s    Check Spectrum Inquiry Fail Message Dueto Code 106

5GC001321_A_29_Verify_GAA_channel_will_be_allocated_when_no_PAL_channel_available_but_PAL_configured
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] To verify GAA channel will be allocated when no PAL channal available but PAL configured
    ...    *******************
    ...    jiangjing.lin@nokia-sbell.com
    ${cbsd_nums}    Get CBSD Numbers    scf_file_path=${scf_path}
    Run Keyword If    ${cbsd_nums}!=1    Run Keywords
    ...    Commissioning SCF And Check RU On Air   scf_file_path=${Golden_SCF_Path}
    ...    AND    Activate feature CBRS By Coam
    start SAS server    config_name=${5GC001321_A_29_conf}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Wait Until Keyword Succeeds    5min    5s    Check Register Status By Coam
    Wait Until Keyword Succeeds    5min    5s    Check GAA Channel Create Success Request
    ${grant_info_from_log}    get_grant_value_from_saslog    filepath=${sas_log_path}
    log to console    grant info from saslog: ${grant_info_from_log}
    ${grant_info_coam}    Get Grant Parameters By Coam
    log to console    grant info by coam: ${grant_info_coam}
    Should be True    '${grant_info_from_log}[grantId]'=='${grant_info_coam}[grantId]'
    Should be True    '${grant_info_from_log}[maxEirp]'=='${grant_info_coam}[maxEirp]'
    Should be True    '${grant_info_from_log}[highFrequency]'=='${grant_info_coam}[SpectrumFreqHigh]'
    Should be True    '${grant_info_from_log}[lowFrequency]'=='${grant_info_coam}[SpectrumFreqLow]'
    Should be True    '${grant_info_coam}[grantChannelType]'=='GAA'
    ${status}    Get Op State By Coam
    Should be True    '${status}'    'Authorized'

5GC001321_A_38_Verify_the_behavior_of_receiving_Grant_responsecode_interference_with_usable_operationParam_contains_20Mhz_channel_and_MaxEIRP
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] To verify
    ...    *******************
    ...    jiangjing.lin@nokia-sbell.com
    ${cbsd_nums}    Get CBSD Numbers    scf_file_path=${scf_path}
    Run Keyword If    ${cbsd_nums}!=1    Run Keywords
    ...    Commissioning SCF And Check RU On Air   scf_file_path=${Golden_SCF_Path}
    ...    AND    Activate feature CBRS By Coam
    Set CBRS Frequency Type By Coam    type=GAA
    Set Frequency Channel Value By Coam    frequency_channel=${frequency_first_8}
    coam.reset_site    connection=GNB_OAM
    Check RU Onair
    start SAS server    config_name=${5GC001321_A_38_conf}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Wait Until Keyword Succeeds    5min    5s    Check Register Status By Coam
    Wait Until Keyword Succeeds    5min    5s    Check Register Success Message    groupId_need=${False}    groupType_need=${False}
    Wait Until Keyword Succeeds    5min    5s    Check Spectrum Inquiry Success Message
    Wait Until Keyword Succeeds    5min    5s    Check Grant Request with Code 400
    ${grant_info_coam}    Get Grant Parameters By Coam
    log to console    grant info by coam: ${grant_info_coam}
    ${highFreq_log}    Evaluate    int(${highFreq_log} / 1000000)
    ${lowFreq_log}    Evaluate    int(${lowFreq_log} / 1000000)
    Should be True    '${grant_info_coam}[grantId]'=='${grantId_log}'
    Should be True    '${grant_info_coam}[maxEirp]'=='${maxEirp_log}'
    Should be True    '${grant_info_coam}[SpectrumFreqHigh]'=='${highFreq_log}'
    Should be True    '${grant_info_coam}[SpectrumFreqLow]'=='${lowFreq_log}'
    Should be True    '${grant_info_coam}[cbrsFreqTyp]'=='GAA'
    ${status}    Get Op State By Coam
    Should be True    '${status}'    'Authorized'
#    [Teardown]    Run Keywords    Set CBRS Frequency Type By Coam    AND
#    ...    Set Frequency Channel Value By Coam    frequency_channel=${frequency_all}

5GC001321_A_39_Verify_the_behavior_of_receiving_Grant_responsecode_interference_with_usable_operationParam_contains_20Mhz_channel_and_MaxEIRP
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] To verify
    ...    *******************
    ...    jiangjing.lin@nokia-sbell.com
    ${cbsd_nums}    Get CBSD Numbers    scf_file_path=${scf_path}
    Run Keyword If    ${cbsd_nums}!=1    Run Keywords
    ...    Commissioning SCF And Check RU On Air   scf_file_path=${Golden_SCF_Path}
    ...    AND    Activate feature CBRS By Coam
    Set Frequency Channel Value By Coam    frequency_channel=${frequency_first_8}
    Set CBRS Frequency Type By Coam
    coam.reset_site    connection=GNB_OAM
    Check RU Onair
    start SAS server    config_name=${5GC001321_A_39_conf}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Wait Until Keyword Succeeds    5min    5s    Check Register Status By Coam
    Wait Until Keyword Succeeds    5min    5s    Check Grant Request with Code 400
    ${grant_info_coam}    Get Grant Parameters By Coam
    ${highFreq_log}    Evaluate    int(${highFreq_log} / 1000000)
    ${lowFreq_log}    Evaluate    int(${lowFreq_log} / 1000000)
    ${maxEirp_log}    Evaluate    int(${maxEirp_log})
    Should be True    '${grant_info_coam}[grantId]'=='${grantId_log}'
    Should be True    '${grant_info_coam}[maxEirp]'=='${maxEirp_log}'
    Should be True    '${grant_info_coam}[SpectrumFreqHigh]'=='${highFreq_log}'
    Should be True    '${grant_info_coam}[SpectrumFreqLow]'=='${lowFreq_log}'
    Should be True    '${grant_info_coam}[cbrsFreqTyp]'=='PAL'
    ${status}    Get Op State By Coam
    Should be True    '${status}'    'Authorized'
#    [Teardown]    Set Frequency Channel Value By Coam    frequency_channel=${frequency_all}

5GC001321_A_44_SyVe_09_Verify_the_behavior_of_ unsuccessful_Grant_with_GRANT_CONFLICT
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] To verify
    ...    *******************
    ...    jiangjing.lin@nokia-sbell.com
    ${cbsd_nums}    Get CBSD Numbers    scf_file_path=${scf_path}
    Run Keyword If    ${cbsd_nums}!=1    Run Keywords
    ...    Commissioning SCF And Check RU On Air   scf_file_path=${Golden_SCF_Path}
    ...    AND    Activate feature CBRS By Coam
    start SAS server    config_name=${5GC001321_A_44_conf}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    # get grantid from the first grant request
    # check the response code in the first grant response is 401
    # check a second grant request is sent with the grantid used before
    # check the response code in the second grant response is 0
    FOR    ${i}    IN RANGE    0    10
        ${heartbeat_msg}    get_all_heartbeat_msg_from_log    filepath=${sas_log_path}
        ${length}      Get Length       ${heartbeat_msg}
        Exit For Loop If    ${length} >=1
        Sleep    30s
    END
    Check Grant Msg with Code 401
    ${status}    Get Op State By Coam
    Should be True    '${status}'    'Authorized'

5GC001321_A_46_Verify_the_grant_renew_is_successful
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] To verify
    ...    *******************
    ...    jiangjing.lin@nokia-sbell.com
    ${cbsd_nums}    Get CBSD Numbers    scf_file_path=${scf_path}
    Run Keyword If    ${cbsd_nums}!=1    Run Keywords
    ...    Commissioning SCF And Check RU On Air   scf_file_path=${Golden_SCF_Path}
    ...    AND    Activate feature CBRS By Coam
    start SAS server    config_name=${5GC001321_A_46_conf}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    FOR    ${i}    IN RANGE    0    10
        ${heartbeat_msg}    get_all_heartbeat_msg_from_log    filepath=${sas_log_path}
        ${length}      Get Length       ${heartbeat_msg}
        Exit For Loop If    ${length} >=8
        Sleep    30s
    END
    # check frequency range and power exists in grantRequest
    # check cbsdId and grantId exists in the first and second heartbeatRequest, and the responseCode is 0
    Check heartbeat Success According Pointed Times    times=2
    # check the operationState is Authorized in the first heartbeatRequest
    ${status}    get_op_state_from_pointed_msg    filepath=${sas_log_path}    msgType=heartbeatRequest    msg_index=1
    # check  transmitExpireTime is test start + 60s in the first heartbeatResponse
    Should be True    '${status}'    'Authorized'
    ${interval}    get_time_interval_between_send_and_expired    filepath=${sas_log_path}    msgType=heartbeatResponse
    ...    msg_index=1    expire_type=transmit
    should be true    ${55} < ${interval} < ${65}
    # check the grantExpireTime is test start + 120s in the first heartbeatResponse
    ${interval}    get_time_interval_between_send_and_expired    filepath=${sas_log_path}    msgType=heartbeatResponse
    ...    msg_index=1    expire_type=grant
    should be true    ${115} < ${interval} < ${125}
    # check the  heartbeatInterval is less than 60s between the first and the second heartbeatResponse
    ${interval}    get_time_interval_between_two_msg    filepath=${sas_log_path}    msgType=heartbeatResponse
    ...    msg_index_1=1    msg_index_2=2
    should be true    ${30}< ${interval} < ${60}
    # check  transmitExpireTime is test start + 60s in the second heartbeatResponse
    ${interval}    get_time_interval_between_send_and_expired    filepath=${sas_log_path}    msgType=heartbeatResponse
    ...    msg_index=2    expire_type=transmit
    should be true    ${55} < ${interval} < ${65}
    # check the grantExpireTime is test start + 120s in the second heartbeatResponse
    ${interval}    get_time_interval_between_send_and_expired    filepath=${sas_log_path}    msgType=heartbeatResponse
    ...    msg_index=2    expire_type=grant
    should be true    ${115} < ${interval} < ${125}
    # check the  heartbeatInterval is less than 60s between the second and the third heartbeatResponse
    ${interval}    get_time_interval_between_two_msg    filepath=${sas_log_path}    msgType=heartbeatResponse
    ...    msg_index_1=2    msg_index_2=3
    should be true    ${30} < ${interval} < ${60}
    ${status}    Get Op State By Coam
    Should be True    '${status}'    'Authorized'

5GC001321_A_47_Verify_the_behavior_of_heartbeat_in_case_communication_error
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] To verify
    ...    *******************
    ...    jiangjing.lin@nokia-sbell.com
    ${cbsd_nums}    Get CBSD Numbers    scf_file_path=${scf_path}
    Run Keyword If    ${cbsd_nums}!=1    Run Keywords
    ...    Commissioning SCF And Check RU On Air   scf_file_path=${Golden_SCF_Path}
    ...    AND    Activate feature CBRS By Coam
    ${stamp_case_start}    Get Timestamp For Current Time
    start SAS server    config_name=${5GC001321_A_47_conf}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    FOR    ${i}    IN RANGE    0    10
        ${heartbeat_msg}    get_all_heartbeat_msg_from_log    filepath=${sas_log_path}
        ${length}      Get Length       ${heartbeat_msg}
        Exit For Loop If    ${length} >=3
        Sleep    30s
    END
    # check the first heartbeatRequest has no heartbeatResponse
#    ${heartbeat_msg}    get_all_heartbeat_msg_from_log    filepath=${sas_log_path}
    should be True    '${heartbeat_msg}[0]'    'heartbeatRequest'
    should be True    '${heartbeat_msg}[1]'    'heartbeatRequest'
    should be True    '${heartbeat_msg}[2]'    'heartbeatResponse'
    # check a second heartbeatRequest is sent, include cbsdid and grantid
    ${msg}    get_msg_by_type_and_index    filepath=${sas_log_path}    msgType=heartbeatRequest     msg_index=2
    Should match regexp    string=${msg}    pattern=cbsdId.*grantId
    # check the second heartbeatRequest has heartbeatResponse, and the responseCode is 0
    ${msg}    get_msg_by_type_and_index    filepath=${sas_log_path}    msgType=heartbeatResponse     msg_index=1
    Should match regexp    string=${msg}    pattern=\"responseCode\": 0
    ${status}    Get Op State By Coam
    Should be True    '${status}'    'Authorized'
    # check there is 6832 fault in history alarm, and not in current alarm
    Wait Until Keyword Succeeds    2min    5s    Check Alarm in Alarm List    type=Active    faultId=6832
    ...    Supplementary=Http receive response messsage timeout    expect=${False}
    Wait Until Keyword Succeeds    2min    5s    Check Alarm in Alarm List    type=History    faultId=6832
    ...    stamp_case_start=${stamp_case_start}    Supplementary=Http receive response message timeout   expect=${True}

5GC001321_A_49_Verify_the_behavior_of_heartbeat_failure_with_responsecode_106
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] To verify
    ...    *******************
    ...    jiangjing.lin@nokia-sbell.com
    ${cbsd_nums}    Get CBSD Numbers    scf_file_path=${scf_path}
    Run Keyword If    ${cbsd_nums}!=1    Run Keywords
    ...    Commissioning SCF And Check RU On Air   scf_file_path=${Golden_SCF_Path}
    ...    AND    Activate feature CBRS By Coam
    ${stamp_case_start}    Get Timestamp For Current Time
    start SAS server    config_name=${5GC001321_A_49_conf}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    FOR    ${i}    IN RANGE    0    30
        ${heartbeat_msg}    get_all_heartbeat_msg_from_log    filepath=${sas_log_path}
        ${length}      Get Length       ${heartbeat_msg}
        Exit For Loop If    ${length} >=26
        Sleep    30s
    END
    # check the first heartbeatRequest has heartbeatResponse, and the responsecode is 0
    should be True    '${heartbeat_msg}[0]'    'heartbeatRequest'
    should be True    '${heartbeat_msg}[1]'    'heartbeatResponse'
    ${msg}    get_msg_by_type_and_index    filepath=${sas_log_path}    msgType=heartbeatResponse     msg_index=1
    Should match regexp    string=${msg}    pattern=\"responseCode\": 0
    # the op status is Authorized in the first heartbeatRequest
    ${status}    get_op_state_from_pointed_msg    filepath=${sas_log_path}    msgType=heartbeatRequest    msg_index=1
    Should be True    '${status}'    'Authorized'
    # check when intTransmitTimeoutEvent happend, op status changed to Granted
    ${index}    get_msg_index_by_type_and_keywords    filepath=${sas_log_path}    msgType=heartbeatResponse    keywords=intTransmitTimeoutEvent
    ${status}    get_op_state_from_pointed_msg    filepath=${sas_log_path}    msgType=heartbeatResponse    msg_index=${index}
    Should be True    '${status}'    'Granted'
    # check the second to the 12th heartbeatRequest has heartbeatResponse, and the the responsecode is 106
    FOR    ${i}    IN RANGE    1    13
        ${index_1}    Evaluate    ${i}*2
        should be True    '${heartbeat_msg}[${index_1}]'=='heartbeatRequest'
        ${index_2}=   Evaluate  ${index_1}+1
        should be True    '${heartbeat_msg}[${index_2}]'=='heartbeatResponse'
    END
    FOR    ${i}    IN RANGE    2    13
        ${msg}    get_msg_by_type_and_index    filepath=${sas_log_path}    msgType=heartbeatResponse     msg_index=${i}
        Should match regexp    string=${msg}    pattern=\"responseCode\": 106
    END
    # to check the responsed code in the 13th heartbeatresponse is 0
    ${msg}    get_msg_by_type_and_index    filepath=${sas_log_path}    msgType=heartbeatResponse     msg_index=${13}
    Should match regexp    string=${msg}    pattern=\"responseCode\": 0
    ${status}    Get Op State By Coam
    Should be True    '${status}'    'Authorized'
    # check when intTransmitTimeoutEvent happend,  fault 6829 appeared
    # after the 12th heartbeatResponse, fault 6829 disappeared
#    Wait Until Keyword Succeeds    2min    5s    Check Alarm in Alarm List    type=Active    faultId=6825    expect=${False}
    Wait Until Keyword Succeeds    2min    5s    Check Alarm in Alarm List    type=Active    faultId=6829    expect=${False}
#    Wait Until Keyword Succeeds    2min    5s    Check Alarm in Alarm List    type=History    faultId=6825
#    ...    stamp_case_start=${stamp_case_start}    expect=${True}
    Wait Until Keyword Succeeds    2min    5s    Check Alarm in Alarm List    type=History    faultId=6829
    ...    stamp_case_start=${stamp_case_start}    expect=${True}

5GC001321_A_60_Verify_single_CBSD_deregistration_is_successful_in_multi_CBSD_configuration
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] To check single CBSD deregistration is successful in multi CBSD configuration
    ...    *******************
    ...    qingqing.wang.1@nokia-sbell.com
    ${cbsd_nums}    Get CBSD Numbers    scf_file_path=${scf_path}
    ${CBSD_2_SCF}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_2CBSD_2RU_
    Run Keyword If    ${cbsd_nums}!= 2   Run Keywords
    ...    Commissioning SCF And Check RU On Air   scf_file_path=${CBSD_2_SCF}
    ...    AND    Activate feature CBRS By Coam
    ${stamp_case_start}    Get Timestamp For Current Time
    start SAS server    config_name=${5GC001321_A_60_conf}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Wait Until Keyword Succeeds    5min    5s    Check Alarm in Alarm List    type=History    faultId=6829
    ...    stamp_case_start=${stamp_case_start}    expect=${True}
    ${status}  run keyword and return status    Check heartbeat fail procedure with Code 100
	...    groupId_need=${False}    groupType_need=${False}    NRCBSDID=2    ru_index=2
    Run Keyword If   "${status}"=="True"
    ...    Check Register Success Message    groupId_need=${False}    groupType_need=${False}
	...    ELSE    Run Keywords     Check heartbeat fail procedure with Code 100    groupId_need=${False}    groupType_need=${False}
    ...    AND     Check Register Success Message    groupId_need=${False}    groupType_need=${False}    NRCBSDID=2    ru_index=2

5GC001321_A_61_Verify_online_CBRS_de-activation_is_successful_in_multi_CBSD_configuration
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] To check online de-activation is successful in multi CBSD configuration
    ...    *******************
    ...    qingqing.wang.1@nokia-sbell.com
    ${cbsd_nums}    Get CBSD Numbers    scf_file_path=${scf_path}
    ${CBSD_2_SCF}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_2CBSD_2RU_
    Run Keyword If    ${cbsd_nums}!= 2   Run Keywords
    ...    Commissioning SCF And Check RU On Air   scf_file_path=${CBSD_2_SCF}
    ...    AND    Activate feature CBRS By Coam
    start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Wait Until Keyword Succeeds    5min    30s    Check Register Status By Coam
    Wait Until Keyword Succeeds    5min    30s    Check Register Status By Coam    NRCBSDID=2
    Check Register Success Message    groupId_need=${False}    groupType_need=${False}
    Check Register Success Message    groupId_need=${False}    groupType_need=${False}    NRCBSDID=2    ru_index=2
    Change NR CBRS Flag By Coam    actNrCbrs=false
    Wait Until Keyword Succeeds    5min    30s    Check Deregister Success Message
    Wait Until Keyword Succeeds    5min    30s    Check Deregister Success Message    NRCBSDID=2
    Wait until keyword succeeds    5min    30s    Verify all cells should be disabled
    ${register}  run keyword and return status    Check Register Status By Coam
    Should be True    ${register} == False
    ${register2}  run keyword and return status    Check Register Status By Coam    NRCBSDID=2
    Should be True    ${register2} == False

5GC001321_A_79_Verify_online_modification_cbrsFreqType
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] To check online modification cbrsFreqType
    ...    *******************
    ...    qingqing.wang.1@nokia-sbell.com
    ${cbsd_nums}    Get CBSD Numbers    scf_file_path=${scf_path}
    Run Keyword If    ${cbsd_nums}!=1    Run Keywords
    ...    Commissioning SCF And Check RU On Air   scf_file_path=${Golden_SCF_Path}
    ...    AND    Activate feature CBRS By Coam
    start SAS server    config_name=${5GC001321_A_79_conf}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    ${grant_info_from_log}    get_grant_value_from_saslog    filepath=${sas_log_path}
    log to console    grant info from saslog: ${grant_info_from_log}
    ${grant_info_coam}    Get Grant Parameters By Coam
    log to console    grant info by coam: ${grant_info_coam}
    Should be True    '${grant_info_from_log}[grantId]'=='${grant_info_coam}[grantId]'
    Should be True    '${grant_info_from_log}[maxEirp]'=='${grant_info_coam}[maxEirp]'
    Should be True    '${grant_info_from_log}[highFrequency]'=='${grant_info_coam}[SpectrumFreqHigh]'
    Should be True    '${grant_info_from_log}[lowFrequency]'=='${grant_info_coam}[SpectrumFreqLow]'
    Should be True    '${grant_info_coam}[cbrsFreqTyp]'=='PAL'
    Should be True    '${grant_info_coam}[grantChannelType]'=='GAA'
    Should be True    '${grant_info_coam}[OperationState]' == 'Authorized'
    Set CBRS Frequency Type By Coam    type=GAA
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    ${grant_info_coam_new}    Get Grant Parameters By Coam
    Should be True    '${grant_info_coam_new}[grantChannelType]'=='GAA'
    Should be True    '${grant_info_coam_new}[OperationState]' == 'Authorized'
    Sleep    40s
    Set CBRS Frequency Type By Coam    type=PAL
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    ${grant_info_coam_new1}    Get Grant Parameters By Coam
    Should be True    '${grant_info_coam_new}[grantChannelType]'=='GAA'
    Should be True    '${grant_info_coam_new}[OperationState]' == 'Authorized'
    Sleep    40s
    Check cbrs Freq Type Online Change procedure
    ...    groupId_need=${False}    groupType_need=${False}
    Check No unexpected CBSD-SAS procedure triggered

5GC001321_A_80_Verify_online_modification_desiredPmax_maxEIRP_different_as_before
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] To verify online modification desiredPmax maxEIRP different as before
    ...    *******************
    ...    qingqing.wang.1@nokia-sbell.com
    ${cbsd_nums}    Get CBSD Numbers    scf_file_path=${scf_path}
    Run Keyword If    ${cbsd_nums}!=1    Run Keywords
    ...    Commissioning SCF And Check RU On Air   scf_file_path=${Golden_SCF_Path}
    ...    AND    Activate feature CBRS By Coam
    ${current_desiredPmax}    Get desiredPmax By Coam
    ${current_maxGrantPwrRed}    Get maxGrantPwrRed By Coam
    ${current_antennaGain}    Get antennaGain By Coam
    ${current_Pmax}    Get pMax By Coam
    ${current_desiredPmax}=   Evaluate    ${current_desiredPmax}*10
    ${current_maxGrantPwrRed}=   Evaluate    ${current_maxGrantPwrRed}*10
    ${current_desiredPmax}     convert to string      ${current_desiredPmax}
    ${current_antennaGain}     convert to string      ${current_antennaGain}
    ${current_maxGrantPwrRed}     convert to string      ${current_maxGrantPwrRed}
    Change desiredPmax maxGrantPwrRed And antennaGain by Coam
    ...    desiredPmax=230
    ...    antennaGain=11
    ...    maxGrantPwrRed=60
    start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    ${grant_info_coam}    Get Grant Parameters By Coam
    Should be True    '${grant_info_coam}[OperationState]' == 'Authorized'
    Should be True    '${grant_info_coam}[maxEirp]'    '27.1 (dBm)'
    ${new_Pmax}    Get pMax By Coam
    Should be True    '${new_Pmax}'    '${current_Pmax}'
    Change desiredPmax maxGrantPwrRed And antennaGain by Coam
    ...    desiredPmax=230
    ...    antennaGain=10
    ...    maxGrantPwrRed=60
    sleep    60s
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    ${grant_info_coam}    Get Grant Parameters By Coam
    Should be True    '${grant_info_coam}[OperationState]' == 'Authorized'
    Should be True    '${grant_info_coam}[maxEirp]'    '26.1 (dBm)'
    ${new1_Pmax}    Get pMax By Coam
    Should be True    '${new1_Pmax}'    '${current_Pmax}'
    Wait Until Keyword Succeeds    5min    10s    Check Case 80 CBRS Process    groupId_need=${False}    groupType_need=${False}
    [Teardown]    Change desiredPmax maxGrantPwrRed And antennaGain by Coam     desiredPmax=${current_desiredPmax}
    ...    maxGrantPwrRed=${current_maxGrantPwrRed}    antennaGain=${current_antennaGain}

5GC001321_A_81_Verify_online_modification_desiredPmax_maxEIRP_same_as_before
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] To verify online modification desiredPmax maxEIRP same as before
    ...    *******************
    ...    qingqing.wang.1@nokia-sbell.com
    ${cbsd_nums}    Get CBSD Numbers    scf_file_path=${scf_path}
    Run Keyword If    ${cbsd_nums}!=1    Run Keywords
    ...    Commissioning SCF And Check RU On Air   scf_file_path=${Golden_SCF_Path}
    ...    AND    Activate feature CBRS By Coam
    ${current_desiredPmax}    Get desiredPmax By Coam
    ${current_maxGrantPwrRed}    Get maxGrantPwrRed By Coam
    ${current_antennaGain}    Get antennaGain By Coam
    ${current_desiredPmax}=   Evaluate    ${current_desiredPmax}*10
    ${current_maxGrantPwrRed}=   Evaluate    ${current_maxGrantPwrRed}*10
    ${current_desiredPmax}     convert to string      ${current_desiredPmax}
    ${current_antennaGain}     convert to string      ${current_antennaGain}
    ${current_maxGrantPwrRed}     convert to string      ${current_maxGrantPwrRed}
    Change desiredPmax maxGrantPwrRed And antennaGain by Coam
    ...    desiredPmax=330
    ...    antennaGain=0
    ...    maxGrantPwrRed=50
    start SAS server    config_name=${5GC001321_A_81_conf}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    ${grant_info_coam}    Get Grant Parameters By Coam
    Should be True    '${grant_info_coam}[grantChannelType]'=='PAL'
    Should be True    '${grant_info_coam}[OperationState]' == 'Authorized'
    Change desiredPmax maxGrantPwrRed And antennaGain by Coam
    ...    desiredPmax=280
    ...    antennaGain=5
    ...    maxGrantPwrRed=50
    Wait Until Keyword Succeeds    5min    10s    Check Case 81 CBRS Process    groupId_need=${False}    groupType_need=${False}
    ${desiredPmax}    Get desiredPmax By Coam
    Should be True    ${desiredPmax}==28
    [Teardown]    Change desiredPmax maxGrantPwrRed And antennaGain by Coam     desiredPmax=${current_desiredPmax}
    ...    maxGrantPwrRed=${current_maxGrantPwrRed}    antennaGain=${current_antennaGain}

5GC001321_A_82_Verify_online_modification_desiredPmax_maxGrantPwrRed_antennaGain_before_granted_status
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] To verify online modification desiredPmax maxGrantPwrRed antennaGain before granted status
    ...    *******************
    ...    qingqing.wang.1@nokia-sbell.com
    ${cbsd_nums}    Get CBSD Numbers    scf_file_path=${scf_path}
    Run Keyword If    ${cbsd_nums}!=1    Run Keywords
    ...    Commissioning SCF And Check RU On Air   scf_file_path=${Golden_SCF_Path}
    ...    AND    Activate feature CBRS By Coam
    ${current_desiredPmax}    Get desiredPmax By Coam
    ${current_maxGrantPwrRed}    Get maxGrantPwrRed By Coam
    ${current_antennaGain}    Get antennaGain By Coam
    ${current_desiredPmax}=   Evaluate    ${current_desiredPmax}*10
    ${current_maxGrantPwrRed}=   Evaluate    ${current_maxGrantPwrRed}*10
    ${current_desiredPmax}     convert to string      ${current_desiredPmax}
    ${current_antennaGain}     convert to string      ${current_antennaGain}
    ${current_maxGrantPwrRed}     convert to string      ${current_maxGrantPwrRed}
    ${stamp_case_start}    Get Timestamp For Current Time
    Change desiredPmax maxGrantPwrRed And antennaGain by Coam
    ...    desiredPmax=370
    ...    antennaGain=11
    ...    maxGrantPwrRed=0
    start SAS server    config_name=${5GC001321_A_82_conf}
    Wait Until Keyword Succeeds    5min    5s    Check Alarm in Alarm List    type=Active    faultId=6828
    ...    stamp_case_start=${stamp_case_start}
    ...    Supplementary=Configuration error of possible desiredPmax/antennaGain/maxGrantPwrRed.    expect=${True}
    Change desiredPmax maxGrantPwrRed And antennaGain by Coam
    ...    desiredPmax=370
    ...    antennaGain=20
    ...    maxGrantPwrRed=300
    Wait Until Keyword Succeeds    2min    5s    Check Alarm in Alarm List    type=Active    faultId=6828
    ...    stamp_case_start=${stamp_case_start}    Supplementary=No available frequency.    expect=${True}
    Change desiredPmax maxGrantPwrRed And antennaGain by Coam
    ...    desiredPmax=370
    ...    antennaGain=0
    ...    maxGrantPwrRed=300
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    [Teardown]    Change desiredPmax maxGrantPwrRed And antennaGain by Coam     desiredPmax=${current_desiredPmax}
    ...    maxGrantPwrRed=${current_maxGrantPwrRed}    antennaGain=${current_antennaGain}

5GC001321_A_83_Verify_online_modification_registration_parameters
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] To check online modification registration parameters
    ...    *******************
    ...    qingqing.wang.1@nokia-sbell.com
    ${cbsd_nums}    Get CBSD Numbers    scf_file_path=${scf_path}
    Run Keyword If    ${cbsd_nums}!=1    Run Keywords
    ...    Commissioning SCF And Check RU On Air   scf_file_path=${Golden_SCF_Path}
    ...    AND    Activate feature CBRS By Coam
    start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Check Register Success Message    groupId_need=${False}    groupType_need=${False}
    ${userId_old}    Get CBRS User Identity By Coam
    ${fccId_old}    Get CBRS FCC identity By Coam
    Set CBRS User Identity By Coam    userId=10701
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Sleep    60s
    Check online modification registration procedure
    Set CBRS FCC identity By Coam    fccId=Nokia_tmp
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Sleep    60s
    Check online modification registration procedure
    [Teardown]    Set CBRS FCC And User identity By COAM    userId=${userId_old}    fccId=${fccId_old}

5GC001321_A_84_Verify_the_Spectrum Inquiry_after_online_modification_supportedSpectrumV2_granted_status
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] Verify the Spectrum Inquiry after online modification supportedSpectrumV2 granted status
    ...    *******************
    ...    qingqing.wang.1@nokia-sbell.com
    ${cbsd_nums}    Get CBSD Numbers    scf_file_path=${scf_path}
    Run Keyword If    ${cbsd_nums}!=1    Run Keywords
    ...    Commissioning SCF And Check RU On Air   scf_file_path=${Golden_SCF_Path}
    ...    AND    Activate feature CBRS By Coam
    Set Frequency Channel Value By Coam    frequency_channel=${frequency_last_26}
    start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Wait Until Keyword Succeeds    5min    30s    Check Register Status By Coam
    Check Register Success Message    groupId_need=${False}    groupType_need=${False}
    Check not find channel 3550-3570 in SI procedure
    Set Frequency Channel Value By Coam    frequency_channel=${frequency_all}
    Wait Until Keyword Succeeds    5min    10s    Check Case 84 CBRS Process    groupId_need=${False}    groupType_need=${False}

5GC001321-E_3_Connect to SAS Mode Online Change from through https proxy to direct connect to SAS
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] Connect to SAS Mode Online Change from through https proxy to direct connect to SAS
    ...    *******************
    ...    qingqing.wang.1@nokia-sbell.com
    ${cbsd_nums}    Get CBSD Numbers    scf_file_path=${scf_path}
    Run Keyword If    ${cbsd_nums}!=1    Run Keywords
    ...    Commissioning SCF And Check RU On Air   scf_file_path=${Golden_SCF_Path}
    ...    AND    Activate feature CBRS By Coam
    Connect to SAS server mode By Coam    connectToSasMode=connect through https proxy
    start proxy instance
    Sleep    5s
    start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Connect to SAS server mode By Coam    connectToSasMode=direct connect to SAS server
    verify all cells should be onair
    Check CBRS Process Success    groupId_need=${False}    groupType_need=${False}
    Check No unexpected CBSD-SAS procedure triggered
    [Teardown]    Run Keywords    kill proxy instance

5GC001321-E_7_Support of Secondary Https Proxy_switch_successfully
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] Support of Secondary Https Proxy switch successfully
    ...    *******************
    ...    qingqing.wang.1@nokia-sbell.com
    ${cbsd_nums}    Get CBSD Numbers    scf_file_path=${scf_path}
    Run Keyword If    ${cbsd_nums}!=1    Run Keywords
    ...    Commissioning SCF And Check RU On Air   scf_file_path=${Golden_SCF_Path}
    ...    AND    Activate feature CBRS By Coam
    Connect to SAS server mode By Coam    connectToSasMode=connect through https proxy
    start proxy instance
    Sleep    5s
    start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    kill proxy instance
    Sleep    120s
    verify all cells should be onair
    start proxy instance    config_name=${5GC001321_E_7_proxy_conf}
    verify all cells should be onair
    Sleep    120s
    Check CBRS Process Success    groupId_need=${False}    groupType_need=${False}
    Check No unexpected CBSD-SAS procedure triggered
    [Teardown]    Run Keywords    kill proxy instance    AND
    ...    Connect to SAS server mode By Coam    connectToSasMode=direct connect to SAS server

5GC001321-E_1_Connect to SAS Mode Online Change from through Domain Proxy to through https proxy
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] Connect to SAS Mode Online Change from through Domain Proxy to through https proxy
    ...    *******************
    ...    qingqing.wang.1@nokia-sbell.com
    ${cbsd_nums}    Get CBSD Numbers    scf_file_path=${scf_path}
    Run Keyword If    ${cbsd_nums}!=1    Run Keywords
    ...    Commissioning SCF And Check RU On Air   scf_file_path=${Golden_SCF_Path}
    ...    AND    Activate feature CBRS By Coam
    Connect to SAS server mode By Coam    connectToSasMode=connect through domain proxy
    start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    ${stamp_case_start}    Get Timestamp For Current Time
    Connect to SAS server mode By Coam    connectToSasMode=connect through https proxy
    Wait Until Keyword Succeeds    2min    5s    Check Alarm in Alarm List    type=Active    faultId=6832
    ...    stamp_case_start=${stamp_case_start}    expect=${True}
    ...    Supplementary=Unable to connect peer
    ${status}  run keyword and return status  wait until keyword succeeds    2min    30s    verify all cells should be onair
    Should be True    ${status} == False
    Check Register Status By Coam    expect_register_status=Unregistered
    Check GrantOperationState Status Success    Status=Idle
    start proxy instance
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Check SAS Mode Online Change procedure
    ...    groupId_need=${False}    groupType_need=${False}
    [Teardown]    Run Keywords    kill proxy instance    AND
    ...    Connect to SAS server mode By Coam    connectToSasMode=direct connect to SAS server

5GC001321-E_6_Connect to SAS Mode Online Change from direct connect to SAS to through Domain Proxy
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] Connect to SAS Mode Online Change from direct connect to SAS to through Domain Proxy
    ...    *******************
    ...    qingqing.wang.1@nokia-sbell.com
    ${cbsd_nums}    Get CBSD Numbers    scf_file_path=${scf_path}
    Run Keyword If    ${cbsd_nums}!=1    Run Keywords
    ...    Commissioning SCF And Check RU On Air   scf_file_path=${Golden_SCF_Path}
    ...    AND    Activate feature CBRS By Coam
    start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Connect to SAS server mode By Coam    connectToSasMode=connect through domain proxy
    Sleep    5s
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Check Register Status By Coam    expect_register_status=Registered
    Check GrantOperationState Status Success
    Check SAS Mode Online Change procedure
    ...    groupId_need=${False}    groupType_need=${False}
    [Teardown]    Connect to SAS server mode By Coam    connectToSasMode=direct connect to SAS server

Verify_the_LTE CBRS Mobility auto-configuration_ENDCDMEASCONF_update_after_NR_neighbor_freq_change
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] Verify the LTE CBRS Mobility auto-configuration ENDCDMEASCONF update after NR neighbor freq change
    ...    *******************
    ...    qingqing.wang.1@nokia-sbell.com
    ${SCF_NSA}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_NSA_
    COAM Commission with scf file    scf_file_path=${SCF_NSA}    timeout=600    is_pdl_checking_needed=${if_pdl_check}
    Sleep    300s
    Activate feature CBRS By Coam
    Sleep    60s
    start SAS server
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    ${arfcnSsbPbch_old}    Get arfcnSsbPbch By Coam
    Set Frequency Channel Value By Coam    frequency_channel=${frequency_last_26}
    Sleep    60s
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    ${arfcnSsbPbch_new}    Get arfcnSsbPbch By Coam
    Should be True    ${arfcnSsbPbch_new}!=${arfcnSsbPbch_old}
    ${release}     gnb_classical_hangzhou.Get sw build version
    ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS
    coam.connect_to    bts_host=${ENB_WEBUI_IP}    bts_port=${443}    username=${USERNAME}    password=${PASSWORD}
    ...   name=GNB_OAM    release=${release_sbts}
    ${carrierFreqNrCell}    Get carrierFreqNrCell From 4G By Coam
    Should be True    ${arfcnSsbPbch_new}==${carrierFreqNrCell}

5GC001321_A_65_Verify_the_behavior_of_gNB_CBSD_Cell_Grant_Timer_Expiry
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]Verify_the_behavior_of_gNB_CBSD_Cell_Grant_Timer_Expiry
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com    manual_hongwei.liu
#    ${stamp_case_start}    Get Timestamp For Current Time
    Start SAS server    config_name=${5GC001321_A_65_conf}
    Wait until keyword succeeds    5min    10s    Check CBRS Process Success    groupId_need=${False}    groupType_need=${False}
    Wait until keyword succeeds    5min    20s    verify all cells should be onair
    ${grant_info_from_log}    get_grant_value_from_saslog    filepath=${sas_log_path}
    ${grant_info_coam}    Get Grant Parameters By Coam
    Should be True    '${grant_info_coam}[OperationState]' == 'Authorized'
    Should be True    '${grant_info_from_log}[grantId]'=='${grant_info_coam}[grantId]'
    Should be True    '${grant_info_from_log}[maxEirp]'=='${grant_info_coam}[maxEirp]'
    Should be True    '${grant_info_from_log}[highFrequency]'=='${grant_info_coam}[SpectrumFreqHigh]'
    Should be True    '${grant_info_from_log}[lowFrequency]'=='${grant_info_coam}[SpectrumFreqLow]'
    log to console    \n*** Wait until CBSD Grant Timer expired ***
    sleep    5min
    Wait until keyword succeeds    5min    10s    Check grantExpireTimer expired Message
    Wait Until Keyword Succeeds    2min    5s    Check GrantOperationState Status Success
#    Wait Until Keyword Succeeds    2min    5s    Check Alarm in Alarm List    type=History    faultId=6823
#    ...    stamp_case_start=${stamp_case_start}    Supplementary=grantExpireTime expires.    expect=${True}
    Wait until keyword succeeds    5min    10s    verify all cells should be onair

5GC001321_A_64_Verify_the_behavior_of_gNB_CBSD_Cell_Grant_Transmission_Timer_Expiry
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]Check Grant_Transmission_Timer_Expiry
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com    manual_hongwei.liu
#    ${stamp_case_start}    Get Timestamp For Current Time
    Start SAS server    config_name=${5GC001321_A_64_conf}    path=${sas_3}
    Wait until keyword succeeds    5min    10s    Check CBRS Process Success    groupId_need=${False}    groupType_need=${False}
    Wait until keyword succeeds    5min    10s    verify all cells should be onair
    ${release}    Get program version based on gNB active version
    ${grantId_1}    Run Keyword If   "${release}"=="SBTS24R1" or "${release}"=="SBTS23R4"
    ...    Get NRCBSDCELL_R value via COAM    pattern=grantId
	...    ELSE    Get subGrantInfo Item by Coam    pattern=grantIdSub
    log to console    \n*** Wait until CBSD TransmitExpireTime expired ***
    Wait until keyword succeeds    5min    5s    Check heartbeat 501 with GrantId    grantId=${grantId_1}
    Wait Until Keyword Succeeds    2min    2s    Check Grant New Success    grantId_old=${grantId_1}
    Check heartbeat Success Message with GrantId    grantId=${grantId_new}
    Wait Until Keyword Succeeds    2min    5s    Check GrantOperationState Status Success
    Wait until keyword succeeds    5min    10s    verify all cells should be onair
#    Wait Until Keyword Succeeds    2min    5s    Check Alarm in Alarm List    type=History    faultId=6825
#    ...    stamp_case_start=${stamp_case_start}    expect=${True}

5GC001321_A_66_Verify_the_behavior_of_heartbeat_Suspend_for_first_Grant_in_granted_status
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]Check the_behavior_of_heartbeat_Suspend_for_first_Grant_in_granted_status
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com    manual_hongwei.liu
    Start SAS server    config_name=${5GC001321_A_66_conf}
    Wait Until Keyword Succeeds    2min    5s    Check SAS Running Success Message
    Wait Until Keyword Succeeds    2min    5s    Check heartbeat Suspend for first Grant
    Wait Until Keyword Succeeds    2min    5s    Check Grant New Success    grantId_old=${grantId_1}
    Wait Until Keyword Succeeds    2min    5s    Check GrantOperationState Status Success
    Check relinquishment Success Message    grantId=${grantId_1}

5GC001321_A_72_Verify_the_gNB_CBSD_reset_successfully
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]Verify_the_gNB_CBSD_reset_successfully
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com   manual_junxia.zhou
    Start SAS server
    Wait Until Keyword Succeeds    5min    10s    Check CBRS Process Success    groupId_need=${False}    groupType_need=${False}
    Wait until keyword succeeds    5min    10s    verify all cells should be onair
    ${grant_info_coam}    Get Grant Parameters By Coam
    ${chBw_nrarfcn}    Get chBw and nrarfcn By Coam
    Should be True    '${grant_info_coam}[OperationState]' == 'Authorized'
    coam.reset_site    connection=GNB_OAM
    Sleep    60s
    Wait until keyword succeeds    15min    30s    verify all cells should be onair
    Wait until keyword succeeds    1min    5s    Check grantRenew set to true
    Check No unexpected CBSD-SAS procedure triggered
    ${grant_info_coam_new}    Get Grant Parameters By Coam
    ${chBw_nrarfcn_new}    Get chBw and nrarfcn By Coam
    Should be True    '${grant_info_coam_new}[grantId]'=='${grant_info_coam}[grantId]'
    Should be True    '${grant_info_coam_new}[maxEirp]'=='${grant_info_coam}[maxEirp]'
    Should be True    '${grant_info_coam_new}[SpectrumFreqHigh]'=='${grant_info_coam}[SpectrumFreqHigh]'
    Should be True    '${grant_info_coam_new}[SpectrumFreqLow]'=='${grant_info_coam}[SpectrumFreqLow]'
    Should be True    '${grant_info_coam_new}[OperationState]' == 'Authorized'
    Should be True    '${chBw_nrarfcn_new}[chBw]'=='${chBw_nrarfcn}[chBw]'
    Should be True    '${chBw_nrarfcn_new}[nrarfcn]'=='${chBw_nrarfcn}[nrarfcn]'

5GC001321_A_68_Verify_the_behavior_of_heartbeat_Suspend_for_second_Grant
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]Verify_the_behavior_of_heartbeat_Suspend_for_second_Grant
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com   manual_tianyi.ye
    Start SAS server    config_name=${5GC001321_A_68_conf}
    Wait Until Keyword Succeeds    2min    5s    Check SAS Running Success Message
    log to console    \n*** Start Check heartbeat Suspend for second Grant ***
    Wait Until Keyword Succeeds    10min    10s    Check heartbeat Suspend for second Grant

5GC001321_A_69_Verify_the_behavior_of_heartbeat_termination_for_first_Grant
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]Verify heartbeat_termination_for_first_Grant
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com   manual_tianyi.ye
#    ${stamp_case_start}    Get Timestamp For Current Time
    Start SAS server    config_name=${5GC001321_A_69_conf}
    Wait Until Keyword Succeeds    5min    10s    Check CBRS Process Success    groupId_need=${False}    groupType_need=${False}
    Wait Until Keyword Succeeds    2min    5s    Check GrantOperationState Status Success
    ${grantId_list}    get_all_grantID_value_from_saslog    filepath=${sas_log_path}
    Set test variable    ${grantId_1}    ${grantId_list[0]}
    sleep    40s
    Wait Until Keyword Succeeds    5min    10s    Trigger heartbeat terminat for first Grant
    Wait Until Keyword Succeeds    10s     2s    Check Grant New Success    grantId_old=${grantId_1}
    Wait Until Keyword Succeeds    10s     2s    Check GrantOperationState Status Success
#    Wait Until Keyword Succeeds    2min    5s    Check Alarm in Alarm List    type=Active    faultId=6824    expect=${False}
#    Wait Until Keyword Succeeds    2min    5s    Check Alarm in Alarm List    type=History    faultId=6824
#    ...    stamp_case_start=${stamp_case_start}    expect=${True}
#    ...    Supplementary=Heartbeat Exception with Reason: 500. ResponseMessage: The grant is terminated.
    Wait until keyword succeeds    5min    10s    verify all cells should be onair

5GC001321_A_70_Verify_the_behavior_of_heartbeat_termination_for_second_Grant
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]Verify heartbeat_termination_for_second_Grant
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com   manual_tianyi.ye
    Start SAS server    config_name=${5GC001321_A_70_conf}
    Wait Until Keyword Succeeds    2min    5s    Check SAS Running Success Message
    sleep    10s
    log to console    Start Check heartbeat terminat for second Grant
    Wait Until Keyword Succeeds    5min    10s    Check heartbeat terminat for second Grant

5GC001321_A_74_Verify_the_behavior_of_parameter_change_that_not_impact_existing_Grant_but_requires_object_locking
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]Verify Online modify physcellid on WebEM
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com   manual_qingqing.wang
    Start SAS server
    Wait Until Keyword Succeeds    5min    10s    Check CBRS Process Success    groupId_need=${False}    groupType_need=${False}
    Wait Until Keyword Succeeds    2min    5s    Check GrantOperationState Status Success
    Wait until keyword succeeds    5min    20s    verify all cells should be onair
    ${physcellid_pre}   Get physcellid By Coam
    modify physcellid by Coam    value=${753}
    sleep    5s
    Wait until keyword succeeds    2min    5s    verify all cells should be onair
    Check No unexpected CBSD-SAS procedure triggered
    Check CBRS L3 call    tput=${TPUT}
    modify physcellid by Coam    value=${physcellid_pre}

5GC001321_A_75_Verify_the_behavior_of_RU_lock_unlock_in_authorized_status
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]Verify RU_lock_unlock_in_authorized_status
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com   manual_qingqing.wang
    Start SAS server
    Wait Until Keyword Succeeds    5min    10s    Check CBRS Process Success    groupId_need=${False}    groupType_need=${False}
    Wait Until Keyword Succeeds    5min    5s    Check GrantOperationState Status Success
    Wait until keyword succeeds    5min    10s    verify all cells should be onair
    log to console    Verify RU_lock_unlock_in_authorized_status
    ${ru_index_list}    Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        coam.lock_RU    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_index}    connection=GNB_OAM
        wait until keyword succeeds  5min  20sec  RU Should Be Locked  ru_index=${ru_index}
    END
    Check GrantOperationState Status Success
    FOR  ${ru_index}  IN  @{ru_index_list}
        coam.unlock_RU    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_index}    connection=GNB_OAM
        wait until keyword succeeds  5min  20sec  RU Should Be unLocked  ru_index=${ru_index}
    END
    Check GrantOperationState Status Success
    Wait until keyword succeeds    5min    10s    verify all cells should be onair
    Check CBRS L3 call    tput=${TPUT}

5GC001321_A_73_Verify_the_behavior_of_Cell_Block_Unblock_in_authorized_status
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]Verify Cell_Block_Unblock_in_authorized_status
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com   manual_junxia.zhou
    Start SAS server
    Wait Until Keyword Succeeds    5min    10s    Check CBRS Process Success    groupId_need=${False}    groupType_need=${False}
    Wait Until Keyword Succeeds    5min    5s    Check GrantOperationState Status Success
    Wait until keyword succeeds    5min    10s    verify all cells should be onair
    Selenium Login And Disable Screen Lock
    Close Start Up View    timeout=60
    log to console    Verify RU lock unlock in authorized status
    ${cell_id_list}  Get All Cell Id
    FOR    ${idx}  IN  @{cell_id_list}
        selenium_coam.block_cell    cell_idx=${idx}
        ${cellgrp_id}   Get Cell Group From Cell   cell_id=${idx}
        Wait Until Keyword Succeeds   5min    10s    Cell Should Be Blocked   cell_idx=${idx}   cell_group_idx=${cellgrp_id}
    END
    Check GrantOperationState Status Success
    FOR    ${idx}  IN  @{cell_id_list}
        selenium_coam.unblock_cell    cell_idx=${idx}
        ${cellgrp_id}   Get Cell Group From Cell   cell_id=${idx}
        Wait Until Keyword Succeeds   5min    10s    Cell should be unblocked   cell_idx=${idx}    cell_group_idx=${cellgrp_id}
    END
    Check GrantOperationState Status Success
    Check No unexpected CBSD-SAS procedure triggered
    Wait until keyword succeeds    5min    10s    verify all cells should be onair
    Check CBRS L3 call    tput=${TPUT}
    [Teardown]    Selenium Logout And Close Browser

5GC001321_A_71_Verify_the_behavior_of_CBSD_second_grant_successfully
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]Verify CBSD_second_grant_successfully
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com   manual_junxia.zhou
    Start SAS server    config_name=${5GC001321_A_71_conf}
    Wait Until Keyword Succeeds    2min    5s    Check SAS Running Success Message
    Wait until keyword succeeds    5min    5s    Verify the First GAA Grant successfully
    log to console    ***Start Verify the Second Grant, querySasServerPeriod should not be 0***
    sleep    5min
    Wait until keyword succeeds    5min    5s    Verify the Second Grant successfully

5GC001321_A_76_Verify_the_gNB_CBSD_reset_successfully_after_grantExpireTimer_expired
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]Verify_the_gNB_CBSD_reset_successfully_after_grantExpireTimer_expired(15min)
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com   manual_qingqing.wang
    ${stamp_case_start}    Get Timestamp For Current Time
    Start SAS server    config_name=${5GC001321_A_76_conf}
    Wait Until Keyword Succeeds    5min    10s    Check CBRS Process Success    groupId_need=${False}    groupType_need=${False}
    Wait Until Keyword Succeeds    2min    5s    Check GrantOperationState Status Success
    Wait until keyword succeeds    5min    10s    verify all cells should be onair
    sleep    13min
    log to console    \n*** BTS reset and Check Grant Timer expired ***
    coam.reset_site    connection=GNB_OAM
    Sleep    60s
    Wait until keyword succeeds    15min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    10s    Check grantExpireTimer expired Message
    Wait Until Keyword Succeeds    2min    5s    Check GrantOperationState Status Success
    Wait Until Keyword Succeeds    2min    5s    Check Alarm in Alarm List    type=History    faultId=6823
    ...    stamp_case_start=${stamp_case_start}    Supplementary=grantExpireTime expires.    expect=${True}
    Wait until keyword succeeds    5min    10s    verify all cells should be onair
    run keyword and ignore error    csn.disconnect    connection=ASIK Master
    Check CBRS L3 call    tput=${TPUT}

5GC001321_C_1_Verify_the_Cell Based CBRS Mobility auto-configuration_intra-gnb_inter-CBSD_HO
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com   manual_hongli.xu
    ${cbsd_nums}    Get CBSD Numbers    scf_file_path=${scf_path}
    ${CBSD_2_SCF}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_2CBSD_2RU_
    Run Keyword If    ${cbsd_nums}!= 2   Run Keywords
    ...    Commissioning SCF And Check RU On Air   scf_file_path=${CBSD_2_SCF}
    ...    AND    Activate feature CBRS By Coam
    Set Frequency Channel Value By Coam    frequency_channel=${frequency_1}
    Start SAS server
    Wait until keyword succeeds    5min    10s    verify all cells should be onair
    log to console    \n*** Set supportedSpectrumV2 from 'F1' to 'F2' of first CBSD ***
    Set Frequency Channel Value By Coam    frequency_channel=${frequency_2}
    sleep    60s
    Wait until keyword succeeds    5min    10s    verify all cells should be onair
    ${arfcnSsbPbch_cell1}    Get NRCELL value by coam    class_name=NRCELL_R    pattern=arfcnSsbPbch
    sleep    10min
    ${ssbFrequency_cell2}    Get SsbFrequency value by coam
    should be True    '${ssbFrequency_cell2}'=='${arfcnSsbPbch_cell1}'
    Set PA To attach cell2
    ...    port1=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0]}
    ...    port2=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1]}
    ...    port3=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2]}
    ...    port4=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3]}
    ...    port5=${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0]}
    ...    port6=${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1]}
    UE attach and start traffic    ue_index=${0}    dl_tp=${tput['dl_send']}     ul_tp=${tput['ul_send']}
    log to console    \n***Start Collect Throughput***
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${20}
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity
    ${cell_id1}    Convert To String    ${cell_mapping[1]['nrCellIdentity']}
    ${cell_id1}    Create List    ${cell_id1}
    ${cell_id2}    Convert To String    ${cell_mapping[2]['nrCellIdentity']}
    ${cell_id2}    Create List    ${cell_id2}
    log to console    \n***Start Check Throughput***
    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${tput_log}    cells=${cell_id2}    ultarget_throughput=${tput['ul_exp_tp']}
    ...    dltarget_throughput=${tput['dl_exp_tp']}    target_avg_percent=0.3    min_percent=0.1
    Check HO success from BTSlog
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${20}
    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${tput_log}    cells=${cell_id1}    ultarget_throughput=${tput['ul_exp_tp']}
    ...    dltarget_throughput=${tput['dl_exp_tp']}    target_avg_percent=0.3    min_percent=0.1
    [Teardown]    Run keywords  run keyword and ignore error    csn.disconnect    connection=ASIK Master  AND
    ...    run keyword and ignore error    Stop Single UE L3 Call    AND    Set TL62 Peak PA
