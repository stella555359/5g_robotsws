*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    ../../../resources/cbrs_common_keywords.robot
Variables    ../TestData/ET_variables.py

Documentation    This is for SG8 common keywords
...              Author: wangqingqing
...              Squard: HZ SG8

*** Variables ***
${hostip}    ${tl.test_pc.default_ssh_connection_details.addr}
${5GC001321_A_SAS_log}    ${CURDIR}/../../../resources/SASSim_HZ/SAS_Sim.log
${5GC001321_A_conf_path}    ${CURDIR}/conf
${5GC001321_A_B10_1}    ${5GC001321_A_conf_path}/5GC001321-A-B10_1.conf
${5GC001321_A_B11_1}    ${5GC001321_A_conf_path}/5GC001321-A-B11_1.conf
${5GC001321_A_B12_20}    ${5GC001321_A_conf_path}/5GC001321-A-B12_20.conf
${5GC001321_A_B12_15}    ${5GC001321_A_conf_path}/5GC001321-A-B12_15.conf
${5GC001321_A_B12_17}    ${5GC001321_A_conf_path}/5GC001321-A-B12_17.conf
${5GC001321_A_B12_Merge}    ${5GC001321_A_conf_path}/5GC001321-A-B12_merge.conf
${5GC001321_A_B13_Merge}    ${5GC001321_A_conf_path}/5GC001321-A-B13_merge.conf
${5GC001321_A_B13_8}    ${5GC001321_A_conf_path}/5GC001321-A-B13_8.conf
${5GC001321_A_B13_1}    ${5GC001321_A_conf_path}/5GC001321-A-B13_1.conf
${5GC001321_A_B13_3}    ${5GC001321_A_conf_path}/5GC001321-A-B13_3.conf
${5GC001321_A_B13_9}    ${5GC001321_A_conf_path}/5GC001321-A-B13_9.conf
${5GC001321_A_B15_7}    ${5GC001321_A_conf_path}/5GC001321-A-B15_7.conf
${5GC001321_A_B16_7}    ${5GC001321_A_conf_path}/5GC001321-A-B16_7.conf
${5GC001321_A_B18_9}    ${5GC001321_A_conf_path}/5GC001321-A-B18_9.conf
${5GC001321_A_B18_8}    ${5GC001321_A_conf_path}/5GC001321-A-B18_8.conf
${5GC001321_A_B18_2}    ${5GC001321_A_conf_path}/5GC001321-A-B18_2.conf
${5GC001321_A_B19_3}    ${5GC001321_A_conf_path}/5GC001321-A-B19_3.conf
${5GC001321_A_B19_1}    ${5GC001321_A_conf_path}/5GC001321-A-B19_1.conf
${5GC001321_A_B19_4}    ${5GC001321_A_conf_path}/5GC001321-A-B19_4.conf
${5GC001321_A_B20_1}    ${5GC001321_A_conf_path}/5GC001321-A-B20_1.conf
${5GC001321_A_B20_18}    ${5GC001321_A_conf_path}/5GC001321-A-B20_18.conf
${5GC001321_A_B20_11}    ${5GC001321_A_conf_path}/5GC001321-A-B20_11.conf
${5GC001321_A_B21_3}    ${5GC001321_A_conf_path}/5GC001321-A-B21_3.conf
${5GC001321_A_B23_merge}    ${5GC001321_A_conf_path}/5GC001321-A-B23_merge.conf
${5GC001321_A_B7_merge}    ${5GC001321_A_conf_path}/5GC001321-A-B7_merge.conf
${5GC001321_A_B7_7}    ${5GC001321_A_conf_path}/5GC001321-A-B7_7.conf
${5GC001321_A_B9_merge}    ${5GC001321_A_conf_path}/5GC001321-A-B9_merge.conf
${5GC001321_E_B5_1}    ${5GC001321_A_conf_path}/5GC001321-E-B5_1.conf
${5GC001321_E_B3_19}    ${5GC001321_A_conf_path}/5GC001321-E-B3_19.conf
${5GC001321_E_B3_5}    ${5GC001321_A_conf_path}/5GC001321-E-B3_5.conf
${5GC001321_A_json_path}    ${CURDIR}/json
${deltaPlan23}    ${5GC001321_A_json_path}/deltaPlan23_jas.json
${deltaPlan23_trunk}    ${5GC001321_A_json_path}/deltaPlan23_jas_trunk.json
${recovery_deltaPlan23}    ${5GC001321_A_json_path}/recovery_deltaPlan23_jas.json
${recovery_deltaPlan23_trunk}    ${5GC001321_A_json_path}/recovery_deltaPlan23_jas_trunk.json
${deltaPlanB13_8}    ${5GC001321_A_json_path}/deltaPlan08_jas.json
${deltaPlanB19_query}    ${5GC001321_A_json_path}/deltaPlan_query.json
${recovery_query}    ${5GC001321_A_json_path}/recovery_deltaPlan_query.json
${deltaPlanB19_1}    ${5GC001321_A_json_path}/deltaPlan01_jas.json
${deltaPlanB19_1_trunk}    ${5GC001321_A_json_path}/deltaPlan01_jas_trunk.json
${deltaPlanB19_4}    ${5GC001321_A_json_path}/deltaPlan04_jas.json
${deltaPlanB20_1}    ${5GC001321_A_json_path}/deltaPlan01_jas_B20.json
${deltaPlanB20_1_desired}    ${5GC001321_A_json_path}/desirePmax23_B20.json
${deltaPlanB20_1_desired_trunk}    ${5GC001321_A_json_path}/desirePmax23_B20_trunk.json
${deltaPlanB20_base}    ${5GC001321_A_json_path}/deltaPlanBase_jas_B20.json
${deltaPlanB20_base_trunk}    ${5GC001321_A_json_path}/deltaPlanBase_jas_B20_trunk.json
${deltaPlanB20_query}    ${5GC001321_A_json_path}/ChangequerySasServerPeriod.json
${MSG_TS12}    POST /v1.2/registration HTTP/1.1
${TRANSMITTIMER_EXPIRTED}        "eventType": "intTransmitTimeoutEvent"
${GRANT_EXPIRTED}               "eventType": "intGrantTimeoutEvent"
${changeDp}    ${5GC001321_A_json_path}/B5_changeDp.json
${changeDp_Trunk}    ${5GC001321_A_json_path}/B5_changeDp_Trunk.json
${B3_deltplan}    ${5GC001321_A_json_path}/B3_deltplan.json
${B3_deltplan_Trunk}    ${5GC001321_A_json_path}/B3_deltplan_Trunk.json
${B5_deltplan}    ${5GC001321_A_json_path}/B5_deltplan.json
${DOMAIN_PROXY_SERVER_STATE_PRIMARY}    POST.*HTTP.*
*** Keywords ***
Config DP Environment
    Connect to Common Unit Master
    csn.execute  command=echo '${hostip} www.dp1.com'>>/etc/hosts    connection=ASIK Master
    csn.execute  command=echo '${hostip} www.dp2.com'>>/etc/hosts    connection=ASIK Master
    [Teardown]    csn.disconnect    connection=ASIK Master

5GC001321-E-B5_1_CBSD_trigger_deregistration_procedure_after_change_primary_DP_URI_which_is_servingDomainProxy
    Commissioning SCF And Check RU On Air    scf_file_path=${Golden_SCF_Path}
    Config DP Environment
    sleep    30s
    coam.perform_delta_recommissioning    delta_file=${B5_deltplan}    connection=GNB_OAM
    sleep    30s
    Activate feature CBRS By Coam
    start SAS server    config_name=${5GC001321_E_B5_1}
    sleep    60s
    Wait until keyword succeeds    5min    5s    verify all cells should be onair
    ${release}    Get program version based on gNB active version
    Run Keyword If   "${release}"=="master"    coam.perform_delta_recommissioning    delta_file=${changeDp_Trunk}    connection=GNB_OAM
    ...    ELSE    coam.perform_delta_recommissioning    delta_file=${changeDp}    connection=GNB_OAM
    sleep    120s
    Wait until keyword succeeds    5min    5s    verify all cells should be onair
    Check Case E B5-1 Step

Check Case E B5-1 Step
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"deregistrationRequest\":.*
    Check if message is found in saslog    tag={\"deregistrationResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"responseCode\": 0.*
    [Teardown]    end_to_check

Check Case E B3-5 Step
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"responseCode\": 0.*
    ${BeforeSwitchOver}    Verify Current DomainProxyServer On SAS server
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"responseCode\": 602472448.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"responseCode\": 0.*
    ${AfterSwitchOver}    Verify Current DomainProxyServer On SAS server
	Should Be True    '${BeforeSwitchOver}' != '${AfterSwitchOver}'
    [Teardown]    end_to_check

Check Case E B3-19 Step
    prepare_to_check_message_from_start
    ${BeforeSwitchOver}    Verify Current DomainProxyServer On SAS server
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 0.*
    ${AfterSwitchOver}    Verify Current DomainProxyServer On SAS server
	Should Be True    '${BeforeSwitchOver}' != '${AfterSwitchOver}'
    [Teardown]    end_to_check

Verify Current DomainProxyServer On SAS server
    [Arguments]   ${request}=${DOMAIN_PROXY_SERVER_STATE_PRIMARY}
    ${output}=    find_message    ${DOMAIN_PROXY_SERVER_STATE_PRIMARY}
    ${DP_MODE}=    Set Variable If    'Primary' in '''${output}'''    Primary
    ...    'Secondary' in '''${output}'''    Secondary
    Should Not Be Equal    '${DP_MODE}'    'None'
    [return]    ${DP_MODE}

5GC001321-E-B3_19_DP_switchover_is_triggered_by_fault6832_due_to_registrationResponse_timeout
    Commissioning SCF And Check RU On Air    scf_file_path=${Golden_SCF_Path}
    Config DP Environment
    sleep    30s
    ${release}    Get program version based on gNB active version
    Run Keyword If   "${release}"=="master"    coam.perform_delta_recommissioning    delta_file=${B3_deltplan_Trunk}    connection=GNB_OAM
    ...    ELSE    coam.perform_delta_recommissioning    delta_file=${B3_deltplan}    connection=GNB_OAM
    sleep    30s
    Activate feature CBRS By Coam
    start SAS server    config_name=${5GC001321_E_B3_19}
    sleep    60s
    Wait until keyword succeeds    5min    5s    verify all cells should be onair
    Check Case E B3-19 Step

5GC001321-E-B3_5_DP_switchover_is_triggered_when_non_first_heartbeatResponse_with_91930000_and_long_transmitTimer
    Commissioning SCF And Check RU On Air    scf_file_path=${Golden_SCF_Path}
    Config DP Environment
    sleep    30s
    ${release}    Get program version based on gNB active version
    Run Keyword If   "${release}"=="master"    coam.perform_delta_recommissioning    delta_file=${B3_deltplan_Trunk}    connection=GNB_OAM
    ...    ELSE    coam.perform_delta_recommissioning    delta_file=${B3_deltplan}    connection=GNB_OAM
    sleep    30s
    Activate feature CBRS By Coam
    start SAS server    config_name=${5GC001321_E_B3_5}
    sleep    360s
    Check Case E B3-5 Step

5GC001321-A-B9_4_NRCBSD_received_spectrum_inquiry_response_with_response_code_105_or_not_received_spectrum_inquiry_response
    start SAS server    config_name=${5GC001321_A_B9_merge}
    sleep    300s
    Check Case B9-Merge Step
    verify all cells should be onair

5GC001321-A-B7_9_NRCBSD_Registration_failed_when_receive_response_code_with_unknown_or_since_the_SasCommunicationGuardTimer_expired
    start SAS server    config_name=${5GC001321_A_B7_merge}
    sleep    300s
    Grep Message In The Saslog    msg=${MSG_TS12}    path=${5GC001321_A_SAS_log}
    Check Case B7-Merge Step
    verify all cells should be onair

5GC001321-A-B7_7_NRCBSD_Registration_failed_since_the_responseCode_is_106_which_bring_valid_interval_in_responseData
    start SAS server    config_name=${5GC001321_A_B7_7}
    sleep    300s
    Grep Message In The Saslog    msg=${MSG_TS12}    path=${5GC001321_A_SAS_log}
    Check Case B7-7 Step
    Check Register Status By Coam
    verify all cells should be onair

Check Case B7-7 Step
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 106.*\"responseData\":.*50.*
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 0.*
    [Teardown]    end_to_check

Check Case B9-Merge Step
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 105.*
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    [Teardown]    end_to_check

Check Case B7-Merge Step
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 500.*
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    [Teardown]    end_to_check

5GC001321-A-B23_5_NRCBSD_received_heartbeat_response_with_response_code_502_and_code_100_101_102_103_104_106
    start SAS server    config_name=${5GC001321_A_B23_merge}
    sleep    600s
    Check Case B23-5 Step

Check Case B23-5 Step
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"responseCode\": 100.*
    Check if message is found in saslog    tag={\"deregistrationRequest\":.*
    Check if message is found in saslog    tag={\"deregistrationResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"responseCode\": 502.*
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*
	Check if message is found in saslog    tag={\"relinquishmentResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"responseCode\": 106.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"responseCode\": 100.*
    Check if message is found in saslog    tag={\"deregistrationRequest\":.*
    Check if message is found in saslog    tag={\"deregistrationResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"responseCode\": 0.*
    [Teardown]    end_to_check

5GC001321-A-B21_3_CBSD_trigger_first_heartbeat_process_directly_after_gNB_reset_when_grant_in_granted_state
    start SAS server    config_name=${5GC001321_A_B21_3}
    Wait until keyword succeeds    5min    5s    verify all cells should be onair
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*
    coam.reset_site   connection=GNB_OAM
    Wait until keyword succeeds    10min    5s    verify all cells should be onair
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"grantRenew\":true.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*
    [Teardown]    end_to_check

5GC001321-A-B20_1_Grant_relinquished_directly_if_current_pMax_more_than_desiredpMax_after_update_desiredpMax_smaller
    Set diff json based on release branch    json1=${deltaPlanB19_1_trunk}    json2=${deltaPlanB19_1}
    sleep    30s
    start SAS server    config_name=${5GC001321_A_B20_1}
    Wait until keyword succeeds    5min    5s    verify all cells should be onair
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"operationParam\":.*\"maxEirp\":28.1.*\"
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    Set diff json based on release branch    json1=${deltaPlanB20_1_desired_trunk}    json2=${deltaPlanB20_1_desired}
    sleep    120s
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*
	Check if message is found in saslog    tag={\"relinquishmentResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"operationParam\":.*\"maxEirp\":26.1.*\"
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*
    [Teardown]    end_to_check

5GC001321-A-B20_18_CBSD_will_try_to_background_hunting_more_better_channel_after_update_QuerySasServerPeriod_from_zero_to_non_zero
    Set diff json based on release branch    json1=${deltaPlanB20_base_trunk}    json2=${deltaPlanB20_base}
    sleep    30s
    start SAS server    config_name=${5GC001321_A_B20_18}
    Wait until keyword succeeds    5min    5s    verify all cells should be onair
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"PAL\".*\"responseCode\": 0.*
    coam.perform_delta_recommissioning    delta_file=${deltaPlanB20_query}    connection=GNB_OAM
    sleep    350s
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"GAA\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*
	Check if message is found in saslog    tag={\"relinquishmentResponse\":.*\"responseCode\": 0.*
    [Teardown]    end_to_check

5GC001321-A-B20_11_Get_more_better_channel_after_update_cbrsFreqType
    Set diff json based on release branch    json1=${deltaPlanB20_base_trunk}    json2=${deltaPlanB20_base}
    sleep    30s
    start SAS server    config_name=${5GC001321_A_B20_11}
    Wait until keyword succeeds    5min    5s    verify all cells should be onair
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"GAA\".*\"responseCode\": 0.*
    Set CBRS Frequency Type By Coam
    sleep    60s
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*
	Check if message is found in saslog    tag={\"relinquishmentResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"PAL\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*
    [Teardown]    end_to_check

Check Case B19-1 Step
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"operationParam\":.*\"maxEirp\":26.0.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"operationParam\":.*\"maxEirp\":28.1.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"3570000000_3590000000\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*\"grantId\":\"3550000000_3570000000\".*
	Check if message is found in saslog    tag={\"relinquishmentResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3570000000_3590000000\".*\"responseCode\": 0.*
    [Teardown]    end_to_check

5GC001321-A-B19_1_CBSD_background_hunt_to_get_more_better_channel_with_satify_maxEirp
    Set diff json based on release branch    json1=${deltaPlanB19_1_trunk}    json2=${deltaPlanB19_1}
    sleep    30s
    coam.perform_delta_recommissioning    delta_file=${deltaPlanB19_query}    connection=GNB_OAM
    sleep    30s
    start SAS server    config_name=${5GC001321_A_B19_1}
    Wait until keyword succeeds    5min    5s    verify all cells should be onair
    Check Register Status By Coam
    sleep    150s
    Check Case B19-1 Step
    sleep    20s
    [Teardown]    Run Keywords    Set CBRS Frequency Type By Coam    AND
    ...    coam.perform_delta_recommissioning    delta_file=${recovery_query}    connection=GNB_OAM

Check Case B19-4 Step
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"operationParam\":.*\"maxEirp\":26.0.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"3550000000_3570000000\".*\"PAL\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"operationParam\":.*\"maxEirp\":26.0.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"3590000000_3610000000\".*\"GAA\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3590000000_3610000000\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*\"grantId\":\"3550000000_3570000000\".*
	Check if message is found in saslog    tag={\"relinquishmentResponse\":.*\"responseCode\": 0.*
    [Teardown]    end_to_check

5GC001321-A-B19_4_CBSD_background_hunt_to_get_more_better_channel_with_higher_priority_for_channelType_than_maxEirp
    coam.perform_delta_recommissioning    delta_file=${deltaPlanB19_4}    connection=GNB_OAM
    sleep    30s
    coam.perform_delta_recommissioning    delta_file=${deltaPlanB19_query}    connection=GNB_OAM
    sleep    30s
    start SAS server    config_name=${5GC001321_A_B19_4}
    Wait until keyword succeeds    5min    5s    verify all cells should be onair
    Check Register Status By Coam
    sleep    150s
    Check Case B19-4 Step
    sleep    20s
    [Teardown]    Run Keywords    Set CBRS Frequency Type By Coam    AND
    ...    coam.perform_delta_recommissioning    delta_file=${recovery_query}    connection=GNB_OAM

Check Case B19-3 Step
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"3550000000_3570000000\".*\"GAA\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"3570000000_3590000000\".*\"PAL\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3570000000_3590000000\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*\"grantId\":\"3550000000_3570000000\".*
	Check if message is found in saslog    tag={\"relinquishmentResponse\":.*\"responseCode\": 0.*
    [Teardown]    end_to_check

5GC001321-A-B19_3_CBSD_background_hunt_to_get_more_better_channel_with_matched_channelType_cbrsFreqType_configured_PAL
    coam.perform_delta_recommissioning    delta_file=${deltaPlanB19_query}    connection=GNB_OAM
    sleep    30s
    start SAS server    config_name=${5GC001321_A_B19_3}
    Wait until keyword succeeds    5min    5s    verify all cells should be onair
    Check Register Status By Coam
    sleep    150s
    Check Case B19-3 Step
    [Teardown]    coam.perform_delta_recommissioning    delta_file=${recovery_query}    connection=GNB_OAM

5GC001321-A-B13_6_CBSD_will_grant_GAA_channel_when_heartbeatResponse_501_with_valid_operationParam_not_contain_PAL_channel_and_cbrsFreqType_PAL
    Set Frequency Channel Value By Coam    frequency_channel=${frequency_3550_and_3600}
    sleep    30s
    start SAS server    config_name=${5GC001321_A_B13_Merge}
    Wait until keyword succeeds    7min    5s    verify all cells should be onair
    Check Register Status By Coam
    sleep    150s
    Check Case B13-3 Step
    [Teardown]    Set Frequency Channel Value By Coam    frequency_channel=${frequency_all}
	
Check Case B12-merge Step
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 101.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 105.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 106.*\"responseData\":.*40.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 500.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 401.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    [Teardown]    end_to_check

5GC001321-A-B12_14_NRCBSD_received_first_grant_response_with_response_code_401_no_response_data
    Set Frequency Channel Value By Coam    frequency_channel=${frequency_3550}
    sleep    30s
    start SAS server    config_name=${5GC001321_A_B12_Merge}
    ${stamp_case_start}    Get Timestamp For Current Time
    sleep    120s
    Wait until keyword succeeds    7min    5s    verify all cells should be onair
    Check Register Status By Coam
    Check Case B12-merge Step
    Check Alarm in Alarm List    type=History    faultId=6832    stamp_case_start=${stamp_case_start}    expect=${True}
    Check Alarm in Alarm List    type=History    faultId=6828    stamp_case_start=${stamp_case_start}    expect=${True}
    [Teardown]    Set Frequency Channel Value By Coam    frequency_channel=${frequency_all}

Check Case B18-8 Step
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 9191.*
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"responseCode\": 0.*
    [Teardown]    end_to_check

5GC001321-A-B18_08_NRCBSD_spectrumInquiry_with_responseCode_9191_via_Domain_Proxy
    Connect to SAS server mode By Coam    connectToSasMode=connect through domain proxy
    sleep    40s
    start SAS server    config_name=${5GC001321_A_B18_8}
    Wait until keyword succeeds    5min    5s    verify all cells should be onair
    Check Register Status By Coam
    sleep    120s
    Check Case B18-8 Step
    sleep    10s
    [Teardown]    Connect to SAS server mode By Coam    connectToSasMode=direct connect to SAS server

Check Case B18-2 Step
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 9192.*
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"responseCode\": 0.*
    [Teardown]    end_to_check

5GC001321-A-B18_02_NRCBSD_Registration_with_responseCode_9192_via_Domain_Proxy
    Connect to SAS server mode By Coam    connectToSasMode=connect through domain proxy
    sleep    40s
    start SAS server    config_name=${5GC001321_A_B18_2}
    Wait until keyword succeeds    5min    5s    verify all cells should be onair
    Check Register Status By Coam
    sleep    120s
    Check Case B18-2 Step
    sleep    10s
    [Teardown]    Connect to SAS server mode By Coam    connectToSasMode=direct connect to SAS server

5GC001321-A-B18_09_NRCBSD_grant_with_responseCode_9190_and_backoffInterval_is_populated_via_Domain_Proxy
    Connect to SAS server mode By Coam    connectToSasMode=connect through domain proxy
    sleep    40s
    start SAS server    path=${sas_2_0}    config_name=${5GC001321_A_B18_9}
    Wait until keyword succeeds    5min    5s    verify all cells should be onair
    Check Register Status By Coam
    sleep    120s
    Check Case B18-9 Step
    sleep    10s
    [Teardown]    Connect to SAS server mode By Coam    connectToSasMode=direct connect to SAS server

Check Case B18-9 Step
    ${resp}    Set variable    {\"grantResponse\":.*\"responseCode\": 9190.*\"DP is not able to communicate with SAS\".*\"backoffInterval\": 10.*
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag=${resp}
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"responseCode\": 0.*
    [Teardown]    end_to_check

Check Case B10 Step
    [Arguments]    ${cbsdid}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"cbsdId\": \"${cbsdid}\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"grantRenew\":true.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    [Teardown]    end_to_check

Check CBRS Normal Step
    [Arguments]    ${cbsdid}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"cbsdId\": \"${cbsdid}\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    [Teardown]    end_to_check

Check Case 11 Step
    [Arguments]    ${cbsdid}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"cbsdId\": \"${cbsdid}\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 500.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"3600000000_3620000000\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3600000000_3620000000\".*\"responseCode\": 0.*
    [Teardown]    end_to_check

Check Case B12-20 Step
    [Arguments]    ${cbsdid}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"cbsdId\": \"${cbsdid}\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    [Teardown]    end_to_check

Check Case B12-15 Step
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"deregistrationRequest\":.*
    Check if message is found in saslog    tag={\"deregistrationResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 0.*
    [Teardown]    end_to_check

Check Case B12-17 Step
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"liuxu\".*\"lx\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"PAL\".*\"responseCode\": 0.*
    [Teardown]    end_to_check

Check Case B13-8 Step
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 501.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"3570000000_3590000000\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3570000000_3590000000\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*\"grantId\":\"3550000000_3570000000\".*
    [Teardown]    end_to_check

Check Case B13-1 Step
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 501.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"3600000000_3620000000\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3600000000_3620000000\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*\"grantId\":\"3550000000_3570000000\".*
    [Teardown]    end_to_check

Check Case B13-9 Step
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 501.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 501.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 501.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 501.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 0.*
    [Teardown]    end_to_check

Check Case B13-3 Step
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 501.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"3600000000_3620000000\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3600000000_3620000000\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*\"grantId\":\"3550000000_3570000000\".*
    [Teardown]    end_to_check

Check Case B15-7 Step
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 501.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"3570000000_3590000000\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3570000000_3590000000\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*\"grantId\":\"3550000000_3570000000\".*
    Check if message is found in saslog    tag={\"relinquishmentResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 106.*
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*\"grantId\":\"3550000000_3570000000\".*
    Check if message is found in saslog    tag={\"relinquishmentResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3570000000_3590000000\".*\"responseCode\": 0.*
    [Teardown]    end_to_check

Check Case B16-7 Step
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"deregistrationRequest\":.*
    Check if message is found in saslog    tag={\"deregistrationResponse\":.*\"responseCode\": 106.*
    Check if message is found in saslog    tag={\"deregistrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"responseCode\": 0.*
    [Teardown]    end_to_check

5GC001321-A-B16_7_NRCBSD_deRegistration_failed_since_the_responseCode_is_106_which_bring_valid_interval_in_responseData
    start SAS server    config_name=${5GC001321_A_B16_7}
    ${stamp_case_start}    Get Timestamp For Current Time
    sleep    240s
    Check Case B16-7 Step
    sleep    10s

5GC001321-A-B15_7_Relinquish_process_is_retriggered_due_to_relinquishResponse_with_106_with_valid_interval
    Set CBRS Frequency Type By Coam    type=GAA
    start SAS server    config_name=${5GC001321_A_B15_7}
    sleep    600s
    Check Register Status By Coam
    Check Case B15-7 Step
    sleep    10s
    [Teardown]    Set CBRS Frequency Type By Coam

5GC001321-A-B13_1_CBSD_will_grant_channel_immediately_when_first_heartbeatResponse_501_with_valid_operationParam
    Set CBRS Frequency Type By Coam    type=GAA
    start SAS server    config_name=${5GC001321_A_B13_1}
    Wait until keyword succeeds    5min    5s    verify all cells should be onair
    Check Register Status By Coam
    sleep    40s
    Check Case B13-1 Step
    sleep    20s
    [Teardown]    Set CBRS Frequency Type By Coam

5GC001321-A-B13_9_gNB_resume_work_normally_once_current_suspend_grant_recover
    Set CBRS Frequency Type By Coam    type=GAA
    start SAS server    config_name=${5GC001321_A_B13_9}
    Wait until keyword succeeds    5min    5s    verify all cells should be onair
    Check Register Status By Coam
    sleep    300s
    Check Case B13-9 Step
    sleep    20s
    [Teardown]    Set CBRS Frequency Type By Coam

5GC001321-A-B13_3_CBSD_will_grant_channel_consider_channelType_when_heartbeatResponse_501_with_valid_operationParam_and_cbrsFreqType_PAL
    start SAS server    config_name=${5GC001321_A_B13_3}
    Wait until keyword succeeds    6min    5s    verify all cells should be onair
    sleep    150s
    Check Case B13-3 Step
    sleep    20s

5GC001321-A-B13_8_CBSD_wil_inquiry_new_channel_when_heartbeatResponse_501_with_invalid_operationParam_due_to_no_available_maxEirp
    coam.perform_delta_recommissioning    delta_file=${deltaPlanB13_8}    connection=GNB_OAM
    sleep    40s
    start SAS server    config_name=${5GC001321_A_B13_8}
    Wait until keyword succeeds    5min    5s    verify all cells should be onair
    Check Register Status By Coam
    sleep    120s
    Wait until keyword succeeds    5min    5s    verify all cells should be onair
    Check Case B13-8 Step

5GC001321-A-B12_23_NRCBSD_20MHz_desiredPmax_exceeds_FCC_limitation_range_maxGrantPwrRed
    Set diff json based on release branch    json1=${deltaPlan23_trunk}    json2=${deltaPlan23}
    sleep    40s
    start SAS server
    ${stamp_case_start}    Get Timestamp For Current Time
    sleep    60s
    Wait until keyword succeeds    5min    5s    verify all cells should be onair
    Check Register Status By Coam
    ${nrcbsdid}    Get Parameter value via COAM    class_name=NRCBSD_R    pattern=assignedCbsdId    connection=GNB_OAM
    Check CBRS Normal Step    cbsdid=${nrcbsdid}
    Wait Until Keyword Succeeds    5min    5s    Check Alarm in Alarm List    type=History    faultId=4532
    ...    stamp_case_start=${stamp_case_start}
    ...    Supplementary=MaxEirp truncated, configured desiredPmax/antennaGain/maxGrantPwrRed need to be adjust.    expect=${True}
    [Teardown]    Set diff json based on release branch    json1=${recovery_deltaPlan23_trunk}    json2=${recovery_deltaPlan23}

5GC001321-A-B12_15_NRCBSD_received_grant_response_with_response_code_404
    ${stamp_case_start}    Get Timestamp For Current Time
    start SAS server    config_name=${5GC001321_A_B12_15}
    Wait Until Keyword Succeeds    6min    5s    Check Alarm in Alarm List    type=History    faultId=6828
    ...    stamp_case_start=${stamp_case_start}
    ...    Supplementary=Grant Exception with Reason: 404.    expect=${True}
    sleep    40s
    Check Case B12-15 Step

5GC001321-A-B12_17_NRCBSD_support_grant_request_with_SAS_config_no_GAA_but_bts_config_cbrsFreqType_to_GAA
    Set CBRS Frequency Type By Coam    type=GAA
    start SAS server    config_name=${5GC001321_A_B12_17}
    Wait until keyword succeeds    5min    5s    verify all cells should be onair
    Check Register Status By Coam
    sleep    40s
    Check Case B12-17 Step
    sleep    20s
    [Teardown]    Set CBRS Frequency Type By Coam

5GC001321-A-B12_20_NRCBSD_no_available_frequency_channels
#    ${stamp_case_start}    Get Timestamp For Current Time
    start SAS server    config_name=${5GC001321_A_B12_20}
    Wait until keyword succeeds    5min    5s    verify all cells should be onair
    ${nrcbsdid}    Get Parameter value via COAM    class_name=NRCBSD_R    pattern=assignedCbsdId    connection=GNB_OAM
    Check Register Status By Coam
#    Wait Until Keyword Succeeds    6min    5s    Check Alarm in Alarm List    type=History    faultId=6828
#    ...    stamp_case_start=${stamp_case_start}
#    ...    Supplementary=No available frequency.    expect=${True}
    Check Case B12-20 Step    cbsdid=${nrcbsdid}
    Wait until keyword succeeds    5min    5s    verify all cells should be onair

5GC001321-A-B11_1_CBSD_prefer_to_grant_channel_consider_channelType_when_heartbeatResponse_500_with_valid_operationParam_and_cbrsFreqType_GAA
    Set CBRS Frequency Type By Coam    type=GAA
    start SAS server    config_name=${5GC001321_A_B11_1}
    Wait until keyword succeeds    5min    5s    verify all cells should be onair
    ${stamp_case_start}    Get Timestamp For Current Time
    ${nrcbsdid}    Get Parameter value via COAM    class_name=NRCBSD_R    pattern=assignedCbsdId    connection=GNB_OAM
    Check Register Status By Coam
    Check GrantOperationState Status Success
    ${result}    coam.get real time measurements    timeout=30    connection=GNB_OAM
    Check CBRS Normal Step    cbsdid=${nrcbsdid}
    ${result}    coam.get real time measurements    timeout=180    connection=GNB_OAM
    Wait Until Keyword Succeeds    6min    5s    Check Alarm in Alarm List    type=History    faultId=6824
    ...    stamp_case_start=${stamp_case_start}
    ...    Supplementary=Heartbeat Exception with Reason: 500. ResponseMessage: The grant is terminated.    expect=${True}
    Check Case 11 Step    cbsdid=${nrcbsdid}
    sleep    40s
    [Teardown]    Set CBRS Frequency Type By Coam

5GC001321-A-B10_1_Ternimate_grant_when_grant_time_expires_due_to_SAS_does_not_renew_the_timer
    start SAS server    config_name=${5GC001321_A_B10_1}
    Wait until keyword succeeds    5min    5s    verify all cells should be onair
    ${nrcbsdid}    Get Parameter value via COAM    class_name=NRCBSD_R    pattern=assignedCbsdId    connection=GNB_OAM
    Check Register Status By Coam
    Wait Until Keyword Succeeds    3min    5s    Check GrantOperationState Status Success    Status=Granted
    ${stamp_case_start}    Get Timestamp For Current Time
    Sleep    130s
    Run Keyword And Ignore Error    Check GrantOperationState Status Success    Status=Idle
    Wait Until Keyword Succeeds    4min    5s    Check Alarm in Alarm List    type=History    faultId=6823
    ...    stamp_case_start=${stamp_case_start}    Supplementary=grantExpireTime expires.    expect=${True}
    Check Case B10 Step    cbsdid=${nrcbsdid}
    Grep Message In The Saslog    msg=${TRANSMITTIMER_EXPIRTED}    path=${5GC001321_A_SAS_log}
    Grep Message In The Saslog    msg=${GRANT_EXPIRTED}    path=${5GC001321_A_SAS_log}
    Sleep    60s
    ${stamp_case_start}    Get Timestamp For Current Time
    Wait Until Keyword Succeeds    10min    5s    Check Alarm in Alarm List    type=History    faultId=6823
    ...    stamp_case_start=${stamp_case_start}    Supplementary=grantExpireTime expires.    expect=${True}
