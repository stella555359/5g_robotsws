*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    ../../../resources/cbrs_common_keywords.robot

Documentation    This is for SG8 common keywords
...              Author: wangqingqing
...              Squard: HZ SG8

*** Variables ***
${hostip}    ${tl.test_pc.default_ssh_connection_details.addr}
${5GC001321_E_conf_path}    ${CURDIR}/conf
${5GC001321_E_B5_1}    ${5GC001321_E_conf_path}/5GC001321-E-B5_1.conf
${5GC001321_E_B3_19}    ${5GC001321_E_conf_path}/5GC001321-E-B3_19.conf
${5GC001321_E_B3_5}    ${5GC001321_E_conf_path}/5GC001321-E-B3_5.conf
${5GC001321_E_B3_1}    ${5GC001321_E_conf_path}/5GC001321-E-B3_1.conf
${5GC001321_E_B2_1}    ${5GC001321_E_conf_path}/5GC001321-E-B2_1.conf
${5GC001321_E_B2_1S}    ${5GC001321_E_conf_path}/5GC001321-E-B2_1S.conf
${5GC001321_E_B4_2_5533}    ${5GC001321_E_conf_path}/5GC001321-E-B4_2_5533.conf
${5GC001321_E_B4_2_6633}    ${5GC001321_E_conf_path}/5GC001321-E-B4_2_6633.conf
${5GC001321_E_json_path}    ${CURDIR}/json
${B5_deltplan}    ${5GC001321_E_json_path}/B5_deltplan.json
${B3_deltplan}    ${5GC001321_E_json_path}/B3_deltplan.json
${B3_deltplan_Trunk}    ${5GC001321_E_json_path}/B3_deltplan_Trunk.json
${B2_deltplan}    ${5GC001321_E_json_path}/B2_deltplan.json
${B2_deltplan_Trunk}    ${5GC001321_E_json_path}/B2_deltplan_Trunk.json
${B4_deltplan}    ${5GC001321_E_json_path}/B4_deltplan.json
${B4_deltplan_Trunk}    ${5GC001321_E_json_path}/B4_deltplanTrunk.json
${B4_changeSecondIP}    ${5GC001321_E_json_path}/B4_changeSecondIP.json
${B4_changeSecondIP_Trunk}    ${5GC001321_E_json_path}/B4_changeSecondIP_Trunk.json
${changeDp}    ${5GC001321_E_json_path}/B5_changeDp.json
${changeDp_Trunk}    ${5GC001321_E_json_path}/B5_changeDp_Trunk.json
${DOMAIN_PROXY_SERVER_STATE_PRIMARY}    POST.*HTTP.*
*** Keywords ***
Config DP Environment
    Connect to Common Unit Master
    csn.execute  command=echo '${hostip} www.dp1.com'>>/etc/hosts    connection=ASIK Master
    csn.execute  command=echo '${hostip} www.dp2.com'>>/etc/hosts    connection=ASIK Master
    [Teardown]    csn.disconnect    connection=ASIK Master

5GC001321-E CBRS Suite Setup
    [Arguments]   ${delta_file_trunk}    ${delta_file}
    CBRS Suite Setup        UTECloud=${True}
    Config DP Environment
    ${release}    Get program version based on gNB active version
    Run Keyword If   "${release}"=="master"    coam.perform_delta_recommissioning    delta_file=${delta_file_trunk}    connection=GNB_OAM
    ...    ELSE    coam.perform_delta_recommissioning    delta_file=${delta_file}    connection=GNB_OAM
    sleep    30s

Check if message is found from alias
    [Arguments]    ${tag}    ${alias}
    ${output}=    find_message    messageTag=${tag}    alias=${alias}
    Should Be True    '${output}' != '${None}'

Check Case E B4-2 Step FirstServer
    prepare_to_check_message_from_start    alias=FirstServer
    Check if message is found from alias   tag={\"registrationRequest\":.*    alias=FirstServer
    Check if message is found from alias    tag={\"registrationResponse\":.*\"responseCode\": 0.*    alias=FirstServer
    Check if message is found from alias    tag={\"spectrumInquiryRequest\":.*    alias=FirstServer
    Check if message is found from alias    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*    alias=FirstServer
    Check if message is found from alias    tag={\"grantRequest\":.*    alias=FirstServer
    Check if message is found from alias    tag={\"grantResponse\":.*\"responseCode\": 0.*    alias=FirstServer
    Check if message is found from alias    tag={\"heartbeatRequest\":.*    alias=FirstServer
    Check if message is found from alias    tag={\"heartbeatResponse\":.*\"responseCode\": 0.*    alias=FirstServer
    Check if message is found from alias    tag={\"deregistrationRequest\":.*    alias=FirstServer
    Check if message is found from alias    tag={\"deregistrationResponse\":.*\"responseCode\": 0.*    alias=FirstServer
    [Teardown]    end_to_check    alias=FirstServer
	
5GC001321-E-B4_2_CBSD_trigger_deregistration_procedure_after_change_secondary_SAS_URI_which_is_servingSasServer
#    coam.perform_delta_recommissioning    delta_file=${B4_deltplan}    connection=GNB_OAM
    Set diff json based on release branch    json1=${B4_deltplan_Trunk}    json2=${B4_deltplan}
    sleep    30s
    start SAS server    config_name=${5GC001321_E_B4_2_5533}    alias=FirstServer
    sleep    10s
    start SAS server    config_name=${5GC001321_E_B4_2_6633}
    sleep    800s
    Wait until keyword succeeds    5min    5s    verify all cells should be onair
#    coam.perform_delta_recommissioning    delta_file=${B4_changeSecondIP}    connection=GNB_OAM
    Set diff json based on release branch    json1=${B4_changeSecondIP_Trunk}    json2=${B4_changeSecondIP}
    sleep    800s
    Wait until keyword succeeds    5min    5s    verify all cells should be onair
    Check Case E B4-2 Step FirstServer
    Check Case E B2-1 Step
    [Teardown]    Run Keywords    save_sas_log    dstFile=${TS_CASE_LOG_PATH}/SAS_Sim1.log    alias=FirstServer    AND
    ...    kill process for SAS server    alias=FirstServer

5GC001321-E-B2_1_Switchover_to_secondarySasServer_when_communication_failure_with_primarySasServer_which_as_current_servingSasServer
#    coam.perform_delta_recommissioning    delta_file=${B2_deltplan}    connection=GNB_OAM
    Set diff json based on release branch    json1=${B2_deltplan_Trunk}    json2=${B2_deltplan}
    sleep    30s
    start SAS server    config_name=${5GC001321_E_B2_1}
    Wait until keyword succeeds    5min    5s    verify all cells should be onair
    sleep    60s
    Check Case E B2-1 Step
    sleep    30s
    kill process for SAS server
    sleep    10s
    start SAS server    config_name=${5GC001321_E_B2_1S}
    sleep    800s
    Wait until keyword succeeds    5min    5s    verify all cells should be onair
    Check Case E B2-1 Step

Check Case E B2-1 Step
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"responseCode\": 0.*
    [Teardown]    end_to_check

5GC001321-E-B3_1_DP_switchover_is_triggered_when_registartionResponse_with_91930000
    start SAS server    config_name=${5GC001321_E_B3_1}
    sleep    60s
    Wait until keyword succeeds    8min    5s    verify all cells should be onair
    Check Case E B3-1 Step

5GC001321-E-B3_5_DP_switchover_is_triggered_when_non_first_heartbeatResponse_with_91930000_and_long_transmitTimer
    start SAS server    config_name=${5GC001321_E_B3_5}
    sleep    360s
    Check Case E B3-5 Step

5GC001321-E-B3_19_DP_switchover_is_triggered_by_fault6832_due_to_registrationResponse_timeout
    start SAS server    config_name=${5GC001321_E_B3_19}
    sleep    60s
    Wait until keyword succeeds    5min    5s    verify all cells should be onair
    Check Case E B3-19 Step

Verify Current DomainProxyServer On SAS server
    [Arguments]   ${request}=${DOMAIN_PROXY_SERVER_STATE_PRIMARY}
    ${output}=    find_message    ${DOMAIN_PROXY_SERVER_STATE_PRIMARY}
    ${DP_MODE}=    Set Variable If    'Primary' in '''${output}'''    Primary
    ...    'Secondary' in '''${output}'''    Secondary
    Should Not Be Equal    '${DP_MODE}'    'None'
    [return]    ${DP_MODE}

Check Case E B3-1 Step
    prepare_to_check_message_from_start
    ${BeforeSwitchOver}    Verify Current DomainProxyServer On SAS server
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 602472448.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    ${AfterSwitchOver}    Verify Current DomainProxyServer On SAS server
	Should Be True    '${BeforeSwitchOver}' != '${AfterSwitchOver}'
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

5GC001321-E-B5_1_CBSD_trigger_deregistration_procedure_after_change_primary_DP_URI_which_is_servingDomainProxy
    Config DP Environment
    coam.perform_delta_recommissioning    delta_file=${B5_deltplan}    connection=GNB_OAM
    sleep    30s
    start SAS server    config_name=${5GC001321_E_B5_1}
    sleep    60s
    Wait until keyword succeeds    5min    5s    verify all cells should be onair
    ${release}    Get program version based on gNB active version
    Run Keyword If   "${release}"=="master"    coam.perform_delta_recommissioning    delta_file=${changeDp_Trunk}    connection=GNB_OAM
    ...    ELSE    coam.perform_delta_recommissioning    delta_file=${changeDp}    connection=GNB_OAM
    sleep    120s
    Wait until keyword succeeds    5min    5s    verify all cells should be onair
    Check Case E B5-1 Step
