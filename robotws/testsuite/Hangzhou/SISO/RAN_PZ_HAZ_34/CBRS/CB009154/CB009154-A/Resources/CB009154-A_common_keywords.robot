*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    ../../../resources/cbrs_common_keywords.robot

Documentation    This is for SG8 common keywords
...              Author: wangqingqing
...              Squard: HZ SG8

*** Variables ***
${conf_path}    ${CURDIR}/conf
${CB009154_A_29_conf}    ${conf_path}/CB009154_A_29.conf
${CB009154_A_17_conf}    ${conf_path}/CB009154_A_17.conf
${CB009154_A_20_conf}    ${conf_path}/CB009154_A_20.conf
${CB009154_A_26_conf}    ${conf_path}/CB009154_A_26.conf
${CB009154_A_13_conf}    ${conf_path}/CB009154_A_13.conf
${CB009154_A_json_path}    ${CURDIR}/json
${disable_actcbrs}    ${CB009154_A_json_path}/disable_actcbrs.json
*** Keywords ***
Case Preparation
    ${SCF_CB009154_A}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CB009154_A_
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB009154_A}
    &{fault_6826}     Create Dictionary     faultId=${6826}
    &{fault_7313}     Create Dictionary     faultId=${7313}
    ${ALLOWED_FAULT}   Create List   @{ALLOWED_FAULT}   ${fault_6826}    ${fault_7313}
    set suite variable  ${ALLOWED_FAULT}

CB009154-A_13_Verify_the_behavior_of_Heartbeat_failure_with_responseCode_500_TS2.0
    start SAS server    path=${sas_2_0}    config_name=${CB009154_A_13_conf}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Check GrantOperationState Status Success
    ${nrcbsdid}    Get Parameter value via COAM    class_name=NRCBSD_R    pattern=assignedCbsdId    connection=GNB_OAM
    Check Case 13 SAS step    cbsdid=${nrcbsdid}
    Sleep    30s

CB009154-A_27_gNB CBSD Cell Activation - TS version 2.0_1NR_concurrency_SBTS
    ${SCF_CB009154_A_27}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CB009154_A_27_
    COAM Commission with scf file    scf_file_path=${SCF_CB009154_A_27}    timeout=600    is_pdl_checking_needed=${if_pdl_check}
    Sleep    300s
    start SAS server    path=${sas_2_0}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    Check GrantOperationState Status Success
    ${State_lte}    Get Parameter value via COAM    class_name=CBSDCEL_R    pattern=grantOperationState    connection=GNB_OAM
    Should be True    '${State_lte}' == 'Authorized'
    Check Register Status By Coam
    ${register_lte}    Get Parameter value via COAM    class_name=CBSD_R   pattern=cbsdRegistrationState    connection=GNB_OAM
    Should be True    '${register_lte}' == 'Registered'
    [Teardown]    coam.perform_delta_recommissioning    delta_file=${disable_actcbrs}    connection=GNB_OAM

Check Case 13 SAS step
    [Arguments]     ${cbsdid}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*\"cbrsaGroupId\":.*\"cbrsaGroupId\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"cbsdId\": \"${cbsdid}\".*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"responseCode\": 500.*
    Check if message is found in saslog    tag={\"featureCapabilityExchangeRequest\":.*
    Check if message is found in saslog    tag={\"featureCapabilityExchangeResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    [Teardown]    end_to_check

Set cbrsaGroupIdIcg And cbrsaGroupIdCcg By COAM
    [Arguments]    ${cbrsaGroupIdIcg}    ${cbrsaGroupIdCcg}    ${NRCBSDID}=1    ${connection}=GNB_OAM
    ${parameters}  create list
    ${item}  create dictionary  parameterName=cbrsaGroupIdIcg    operation=update    value=${cbrsaGroupIdIcg}
    append to list  ${parameters}  ${item}
    ${item}  create dictionary  parameterName=cbrsaGroupIdCcg    operation=update    value=${cbrsaGroupIdCcg}
    append to list  ${parameters}  ${item}
    coam.perform_object_recommissioning        dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCBSD-${NRCBSDID}
    ...                                        parameter=${parameters}
    ...                                        operation=update
    ...                                        skip_parameter_relation_errors=${True}
    ...                                        connection=${connection}

Check online modification cbrsaGroupIdIcg And cbrsaGroupIdCcg
    [Arguments]     ${cbsdid}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*\"cbrsaGroupId\":.*\"cbrsaGroupId\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"cbsdId\": \"${cbsdid}\".*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"deregistrationRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"deregistrationResponse\":.*\"cbsdId\": \"${cbsdid}\".*
    Check if message is found in saslog    tag={\"registrationRequest\":.*\"cbrsaGroupId\":.*\"cbrsaGroupId\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"cbsdId\": \"${cbsdid}\".*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    [Teardown]    end_to_check

Check Case 22 SAS step
    [Arguments]     ${cbsdid}    ${physcellid_old}    ${physcellid_new}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*\"cbrsaGroupId\":.*\"cbrsaGroupId\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"cbsdId\": \"${cbsdid}\".*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdid}\".*\"signalPci\":${physcellid_old}.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdid}\".*\"signalPci\":${physcellid_new}.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    [Teardown]    end_to_check

CB009154-A_26_Verify_the_behavior_of_heartbeat_with_maxEirp_different_between_operationParam_and_grant_when_WF_GRANT_UPDATE_supported_TS1.2
    start SAS server    path=${sas_2_0}    config_name=${CB009154_A_26_conf}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Check GrantOperationState Status Success
    ${release}    Get program version based on gNB active version
    ${channeltype_old}    Get NRCBSDCELL_R value via COAM    pattern=grantChannelType
    ${grantid_old}    Run Keyword If   "${release}"=="SBTS24R1" or "${release}"=="SBTS23R4"
    ...    Get NRCBSDCELL_R value via COAM    pattern=grantId
    ...    ELSE    Get subGrantInfo Item by Coam    pattern=grantIdSub
    Should be True    '${channeltype_old}'=='PAL'
    ${grantmaxeirp_old}    Get NRCBSDCELL_R value via COAM    pattern=grantMaxEirp
    Sleep    300s
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    ${channeltype_new}    Get NRCBSDCELL_R value via COAM    pattern=grantChannelType
    Should be True    '${channeltype_new}'=='PAL'
    ${grantmaxeirp_new}    Get NRCBSDCELL_R value via COAM    pattern=grantMaxEirp
    Should be True    '${grantmaxeirp_old}'!='${grantmaxeirp_new}'
    ${grantid_new}    Run Keyword If   "${release}"=="SBTS24R1" or "${release}"=="SBTS23R4"
    ...    Get NRCBSDCELL_R value via COAM    pattern=grantId
    ...    ELSE    Get subGrantInfo Item by Coam    pattern=grantIdSub
    Should be True    '${grantid_old}'=='${grantid_new}'
    Check Case 29 and 26 SAS step
    Sleep    30s

CB009154-A_22_Verify_the_behavior_of_CBSD_with_online_modifying_phyCellId_or_signalEcgi_related_parameters_TS2.0
    start SAS server    path=${sas_2_0}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    ${physcellid_pre}   Get physcellid By Coam
    modify physcellid by Coam    value=${780}
    sleep    20s
    Wait until keyword succeeds    2min    5s    verify all cells should be onair
    ${nrcbsdid}    Get Parameter value via COAM    class_name=NRCBSD_R    pattern=assignedCbsdId    connection=GNB_OAM
    Check Case 22 SAS step    physcellid_old=${physcellid_pre}    physcellid_new=${780}    cbsdid=${nrcbsdid}
    [Teardown]    modify physcellid by Coam    value=${physcellid_pre}

CB009154-A_21_Verify_the_behavior_of_CBSD_with_online_modifying_cbrsaGroupIdIcg_or_cbrasGroupIdCcg_TS2.0
    start SAS server    path=${sas_2_0}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Sleep    20s
    ${Icg_old}    Get Parameter value via COAM    class_name=NRCBSD_A    pattern=cbrsaGroupIdIcg    connection=GNB_OAM
    Sleep    10s
    ${Ccg_old}    Get Parameter value via COAM    class_name=NRCBSD_A    pattern=cbrsaGroupIdCcg    connection=GNB_OAM
    Set cbrsaGroupIdIcg And cbrsaGroupIdCcg By COAM    cbrsaGroupIdIcg=Nokia1tmp    cbrsaGroupIdCcg=Nokia2tmp
    Sleep    60s
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    ${nrcbsdid}    Get Parameter value via COAM    class_name=NRCBSD_R    pattern=assignedCbsdId    connection=GNB_OAM
    Check online modification cbrsaGroupIdIcg And cbrsaGroupIdCcg    cbsdid=${nrcbsdid}
    Sleep    60s
    [Teardown]    Set cbrsaGroupIdIcg And cbrsaGroupIdCcg By COAM    cbrsaGroupIdIcg=${Icg_old}    cbrsaGroupIdCcg=${Ccg_old}

CB009154-A_17_Verify_the_behavior_of_heartbeat_with_MaxEIRP_ChannelType_different_GRANT_UPDATE_supported_TS2.0
    start SAS server    path=${sas_2_0}    config_name=${CB009154_A_17_conf}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Check GrantOperationState Status Success
    ${release}    Get program version based on gNB active version
    ${grantchanneltype_old}    Get NRCBSDCELL_R value via COAM    pattern=grantChannelType
    Should be True    '${grantchanneltype_old}'=='GAA'
    ${grantid_old}    Run Keyword If   "${release}"=="SBTS24R1" or "${release}"=="SBTS23R4"
    ...    Get NRCBSDCELL_R value via COAM    pattern=grantId
	...    ELSE    Get subGrantInfo Item by Coam    pattern=grantIdSub
    ${grantmaxeirp_old}    Get NRCBSDCELL_R value via COAM    pattern=grantMaxEirp
    Sleep    120s
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    ${grantchanneltype_new}    Get NRCBSDCELL_R value via COAM    pattern=grantChannelType
    Should be True    '${grantchanneltype_new}'=='PAL'
    ${grantmaxeirp_new}    Get NRCBSDCELL_R value via COAM    pattern=grantMaxEirp
    ${grantid_new}    Run Keyword If   "${release}"=="SBTS24R1" or "${release}"=="SBTS23R4"
    ...    Get NRCBSDCELL_R value via COAM    pattern=grantId
	...    ELSE    Get subGrantInfo Item by Coam    pattern=grantIdSub
    Should be True    '${grantmaxeirp_old}'!='${grantmaxeirp_new}'
    Should be True    '${grantid_old}'=='${grantid_new}'
    ${nrcbsdid}    Get Parameter value via COAM    class_name=NRCBSD_R    pattern=assignedCbsdId    connection=GNB_OAM
    Check Case 17 SAS step
    Check No relinquishmentRequest procedure    cbsdid=${nrcbsdid}

CB009154-A_20_Verify_the_behavior_of_heartbeat_with_MaxEIRP_ChannelType_different_GRANT_UPDATE_unsupported_TS2.0
    start SAS server    path=${sas_2_0}    config_name=${CB009154_A_20_conf}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Check GrantOperationState Status Success
    ${release}    Get program version based on gNB active version
    ${grantchanneltype_old}    Get NRCBSDCELL_R value via COAM    pattern=grantChannelType
    ${grantid_old}    Run Keyword If   "${release}"=="SBTS24R1" or "${release}"=="SBTS23R4"
    ...    Get NRCBSDCELL_R value via COAM    pattern=grantId
    ...    ELSE    Get subGrantInfo Item by Coam    pattern=grantIdSub
    Should be True    '${grantchanneltype_old}'=='GAA'
    ${grantmaxeirp_old}    Get NRCBSDCELL_R value via COAM    pattern=grantMaxEirp
    Sleep    200s
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    ${grantchanneltype_new}    Get NRCBSDCELL_R value via COAM    pattern=grantChannelType
    Should be True    '${grantchanneltype_new}'=='GAA'
    ${grantmaxeirp_new}    Get NRCBSDCELL_R value via COAM    pattern=grantMaxEirp
    Should be True    '${grantmaxeirp_old}'!='${grantmaxeirp_new}'
    ${grantid_new}    Run Keyword If   "${release}"=="SBTS24R1" or "${release}"=="SBTS23R4"
    ...    Get NRCBSDCELL_R value via COAM    pattern=grantId
    ...    ELSE    Get subGrantInfo Item by Coam    pattern=grantIdSub
    Should be True    '${grantid_old}'=='${grantid_new}'
    Check Case 20 SAS step
    Sleep    30s

CB009154-A_29_Verify_the_behavior_of_heartbeat_with_maxEirp_different_between_operationParam_and_grant_when_WF_GRANT_UPDATE_unsupported_TS1.2
    start SAS server    path=${sas_2_0}    config_name=${CB009154_A_29_conf}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Check GrantOperationState Status Success
    ${release}    Get program version based on gNB active version
    ${grantchanneltype_old}    Get NRCBSDCELL_R value via COAM    pattern=grantChannelType
    ${grantid_old}    Run Keyword If   "${release}"=="SBTS24R1" or "${release}"=="SBTS23R4"
    ...    Get NRCBSDCELL_R value via COAM    pattern=grantId
    ...    ELSE    Get subGrantInfo Item by Coam    pattern=grantIdSub
    Should be True    '${grantchanneltype_old}'=='PAL'
    ${grantmaxeirp_old}    Get NRCBSDCELL_R value via COAM    pattern=grantMaxEirp
    Sleep    300s
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    ${grantchanneltype_new}    Get NRCBSDCELL_R value via COAM    pattern=grantChannelType
    Should be True    '${grantchanneltype_new}'=='PAL'
    ${grantmaxeirp_new}    Get NRCBSDCELL_R value via COAM    pattern=grantMaxEirp
    Should be True    '${grantmaxeirp_old}'!='${grantmaxeirp_new}'
    ${grantid_new}    Run Keyword If   "${release}"=="SBTS24R1" or "${release}"=="SBTS23R4"
    ...    Get NRCBSDCELL_R value via COAM    pattern=grantId
    ...    ELSE    Get subGrantInfo Item by Coam    pattern=grantIdSub
    Should be True    '${grantid_old}'=='${grantid_new}'
    Check Case 29 and 26 SAS step
    Sleep    30s

Check Case 20 SAS step
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"grantRequest\":.*\"maxEirp\":.*\"highFrequency\":.*\"lowFrequency\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"grantId\":.*\"channelType\": \"GAA\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"featureCapabilityExchangeRequest\":.*
    Check if message is found in saslog    tag={\"featureCapabilityExchangeResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*
    Check if message is found in saslog    tag={\"relinquishmentResponse\":.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"maxEirp\":.*\"highFrequency\":.*\"lowFrequency\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"grantId\":.*\"responseCode\": 0.*
    [Teardown]    end_to_check

Check Case 29 and 26 SAS step
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"grantRequest\":.*\"maxEirp\":.*\"highFrequency\":.*\"lowFrequency\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"grantId\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*
    Check if message is found in saslog    tag={\"relinquishmentResponse\":.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"maxEirp\":.*\"highFrequency\":.*\"lowFrequency\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"grantId\":.*\"responseCode\": 0.*
    [Teardown]    end_to_check

Check Case 17 SAS step
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"grantRequest\":.*\"maxEirp\":.*\"highFrequency\":.*\"lowFrequency\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"grantId\":.*\"channelType\": \"GAA\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"featureCapabilityExchangeRequest\":.*
    Check if message is found in saslog    tag={\"featureCapabilityExchangeResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"maxEirp\":.*\"highFrequency\":.*\"lowFrequency\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"grantId\":.*\"channelType\": \"PAL\".*\"responseCode\": 0.*
    [Teardown]    end_to_check
