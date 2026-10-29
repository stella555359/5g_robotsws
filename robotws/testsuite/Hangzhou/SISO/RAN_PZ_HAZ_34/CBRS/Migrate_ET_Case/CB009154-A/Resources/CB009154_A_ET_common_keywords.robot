*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    ../../../resources/cbrs_common_keywords.robot

Documentation    This is for SG8 common keywords
...              Author: wangqingqing
...              Squard: HZ SG8

*** Variables ***
${CB009154_A_SAS_log}    ${CURDIR}/../../../resources/SASSim_TS2/SAS_Sim.log
${CB009154_A_conf_path}    ${CURDIR}/conf
${CB009154_A_5}    ${CB009154_A_conf_path}/CB009154_A_5.conf
${CB009154_A_9}    ${CB009154_A_conf_path}/CB009154_A_9.conf
${CB009154_A_76}    ${CB009154_A_conf_path}/CB009154_A_76.conf
${CB009154_A_78}    ${CB009154_A_conf_path}/CB009154_A_78.conf
${CB009154_A_73}    ${CB009154_A_conf_path}/CB009154_A_73.conf
${CB009154_A_74}    ${CB009154_A_conf_path}/CB009154_A_74.conf
${CB009154_A_65}    ${CB009154_A_conf_path}/CB009154_A_65.conf
${CB009154_A_90}    ${CB009154_A_conf_path}/CB009154_A_90.conf
${CB009154_A_91}    ${CB009154_A_conf_path}/CB009154_A_91.conf
${CB009154_A_95}    ${CB009154_A_conf_path}/CB009154_A_95.conf
${CB009154_A_97}    ${CB009154_A_conf_path}/CB009154_A_97.conf
${CB009154_A_104}    ${CB009154_A_conf_path}/CB009154_A_104.conf
${MSG_TS12}    POST /v2.0/registration HTTP/1.1
${MSG_TS20}    POST /v2.0/registration HTTP/1.1
${CB009154_A_json_path}    ${CURDIR}/json
${DeltaplanForcase65}    ${CB009154_A_json_path}/DeltaplanForcase65.json
${DeltaplanForcase65_trunk}    ${CB009154_A_json_path}/DeltaplanForcase65_trunk.json
*** Keywords ***
CB009154-A ET CBRS Suite Setup
    CBRS Suite Setup    feature_scf_flag=${True}    UTECloud=${True}
    ${SCF_CB009154_A}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CB009154-A_ET_
    set suite variable  ${SCF_CB009154_A}
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB009154_A}

CB009154-A_9_REG_CbrsaVersion_Mismatch_Retry_Registration_TS20
    start SAS server    path=${sas_2_0}    config_name=${CB009154_A_9}
    sleep    300s
    verify all cells should be onair
	Check Register Status By Coam
    Grep Message In The Saslog    msg=${MSG_TS20}    path=${CB009154_A_SAS_log}
    Check TS Version By Coam    expect_version=version 2.0
    Check Case CB009154-A_9 Step

CB009154-A_65_2_20Mhz_Cells_With_5M_Boundary_With_CbsdFrequencyGuidance_Update_Can_Be_OnAir
    Set diff json based on release branch    json1=${DeltaplanForcase65_trunk}    json2=${DeltaplanForcase65}
    sleep    30s
    start SAS server    path=${sas_2_0}    config_name=${CB009154_A_65}
    sleep    300s
    Check Case 65_2 Step

CB009154-A_95_Grant_Update_Failed_Since_Relinquish_Failed_With_106_When_Sas_Not_Support_WF_GRANT_UPDATE
    start SAS server    path=${sas_2_0}    config_name=${CB009154_A_95}
    sleep    300s
    Check Case 95 Step

CB009154-A_90_Grant_update_failed_responseCode_Grant_Conflict_401_TS20
    start SAS server    path=${sas_2_0}    config_name=${CB009154_A_90}
    sleep    300s
    Check Case 90 Step

CB009154-A_91_HB_With_Second_Grant_RC401_No_WF_GRANT_UPDATE_TS20
    start SAS server    path=${sas_2_0}    config_name=${CB009154_A_91}
    sleep    300s
    Check Case 91 Step

CB009154-A_97_Grant_Update_MaxEirp_Higher_Together_With_Heartbeat_500
    start SAS server    path=${sas_2_0}    config_name=${CB009154_A_97}
    sleep    300s
    Check Case 97 Step

CB009154-A_104_Grant_Update_When_Maxeirp_Exceed_FCC_Limit
    start SAS server    path=${sas_2_0}    config_name=${CB009154_A_104}
    sleep    300s
    Check Case 104 Step

Check Case CB009154-A_9 Step
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag=\"cbrsaVersion\":\"v3.0\"
    Check if message is found in saslog    tag=\"cbrsaVersion\": \"v1.2\"
    Check if message is found in saslog    tag={\"deregistrationRequest\":.*
    Check if message is found in saslog    tag={\"deregistrationResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 0.*
    [Teardown]    end_to_check


Check Case 104 Step
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"operationParam\":.*\"maxEirp\":22.0.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"operationParam\":.*\"maxEirp\":23.1.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 0.*
    [Teardown]    end_to_check

Check Case 97 Step
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 500.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"operationParam\":.*\"maxEirp\":22.0.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3590000000_3610000000\".*\"maxEirp": 33.0.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"operationParam\":.*\"maxEirp\":23.1.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"responseCode\": 0.*
    [Teardown]    end_to_check

Check Case 95 Step
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*
    Check if message is found in saslog    tag={\"relinquishmentResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 106.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"responseCode\": 0.*
    [Teardown]    end_to_check

Check Case 91 Step
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*
    Check if message is found in saslog    tag={\"relinquishmentResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 400.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3570000000_3590000000\".*\"responseCode\": 0.*
    [Teardown]    end_to_check

Check Case 90 Step
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 401.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3570000000_3590000000\".*\"responseCode\": 0.*
    [Teardown]    end_to_check

Check Case 65_2 Step
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3615000000_3635000000\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3585000000_3605000000\".*\"responseCode\": 0.*
    [Teardown]    end_to_check

CB009154-A_5_REG_TS20_No_SasfeatureCapabilityList_Trigger_Deregister_Then_Reg_In_TS12
    start SAS server    path=${sas_2_0}    config_name=${CB009154_A_5}
    Wait until keyword succeeds    5min    5s    verify all cells should be onair
    sleep    60s
    Grep Message In The Saslog    msg=${MSG_TS12}    path=${CB009154_A_SAS_log}
    Check Case 5 Step
    Check TS Version By Coam

CB009154-A_74_HB_With_OperationParam_Is_Unusable_MaxEirp_Support_WF_GRANT_UPDATE
    start SAS server    path=${sas_2_0}    config_name=${CB009154_A_74}
    sleep    300s
    ${grant_info_from_log}    get_recommend_value_from_grant_response    filepath=${CB009154_A_SAS_log}
    ${maxEirp_log}    set variable    ${grant_info_from_log}[maxEirp]
    set test variable    ${maxEirp_log}
    Check Case 74 Step
    sleep    10s

CB009154-A_76_HB_With_OperationParam_Is_Diffenent_ChannelType_Support_WF_GRANT_UPDATE
    Set CBRS Frequency Type By Coam    type=GAA
    start SAS server    path=${sas_2_0}    config_name=${CB009154_A_76}
    sleep    480s
    Check Case 76 Step
    sleep    10s
    [Teardown]    Set CBRS Frequency Type By Coam

CB009154-A_78_HB_With_OperationParam_Is_Diffenent_ChannelType_No_WF_GRANT_UPDATE
    start SAS server    path=${sas_2_0}    config_name=${CB009154_A_78}
    sleep    600s
    Check Case 78 Step
    sleep    10s

CB009154-A_73_HB_With_OperationParam_Is_Notchange_MaxEirp_Support_WF_GRANT_UPDATE
    start SAS server    path=${sas_2_0}    config_name=${CB009154_A_73}
    sleep    300s
    ${grant_info_from_log}    get_recommend_value_from_grant_response    filepath=${CB009154_A_SAS_log}
    ${maxEirp_log}    set variable    ${grant_info_from_log}[maxEirp]
    set test variable    ${maxEirp_log}
    Check Case 73 Step
    sleep    10s

Check Case 74 Step
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"operationParam\":.*\"maxEirp\":${maxEirp_log}.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"maxEirp": 0.0.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3570000000_3590000000\".*\"responseCode\": 0.*
	Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 0.*
    [Teardown]    end_to_check

Check Case 73 Step
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"operationParam\":.*\"maxEirp\":${maxEirp_log}.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"maxEirp": ${maxEirp_log}.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3570000000_3590000000\".*\"responseCode\": 0.*
	Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 0.*
    [Teardown]    end_to_check

Check Case 78 Step
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"GAA\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3570000000_3590000000\".*\"responseCode\": 0.*
    [Teardown]    end_to_check

Check Case 76 Step
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3590000000_3610000000\".*\"PAL\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3610000000_3630000000\".*\"responseCode\": 0.*
    [Teardown]    end_to_check

Check Case 5 Step
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"deregistrationRequest\":.*
    Check if message is found in saslog    tag={\"deregistrationResponse\":.*\"responseCode\": 0.*
    [Teardown]    end_to_check