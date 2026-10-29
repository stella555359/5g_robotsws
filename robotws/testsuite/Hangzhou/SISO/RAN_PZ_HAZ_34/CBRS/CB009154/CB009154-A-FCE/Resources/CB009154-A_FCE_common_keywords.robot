*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    ../../../resources/cbrs_common_keywords.robot

Documentation    This is for SG8 common keywords
...              Author: wangqingqing
...              Squard: HZ SG8

*** Variables ***
${conf_path}    ${CURDIR}/conf
${CB009154_A_FCE_103_conf}    ${conf_path}/CB009154_A_FCE_103.conf
${CB009154_A_FCE_102_conf}    ${conf_path}/CB009154_A_FCE_102.conf
${CB009154_A_FCE_101_conf}    ${conf_path}/CB009154_A_FCE_101.conf
*** Keywords ***
Case Preparation
    ${SCF_CB009154_A_FCE}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CB009154_A_
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB009154_A_FCE}
    &{fault_6826}     Create Dictionary     faultId=${6826}
    &{fault_7313}     Create Dictionary     faultId=${7313}
    ${ALLOWED_FAULT}   Create List   @{ALLOWED_FAULT}   ${fault_6826}    ${fault_7313}
    set suite variable  ${ALLOWED_FAULT}

CB009154-A_FCE_Heartbeatresponse_0_featureCapabilityExchangeresponse_103
    start SAS server    path=${sas_3}    config_name=${CB009154_A_FCE_103_conf}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    ${nrcbsdid}    Get Parameter value via COAM    class_name=NRCBSD_R    pattern=assignedCbsdId    connection=GNB_OAM
    Sleep    240s
    Check featureCapabilityExchangeresponse 103 SAS step    cbsdid=${nrcbsdid}
    verify all cells should be onair

CB009154-A_FCE_Heartbeatresponse_500_featureCapabilityExchangeresponse_102
    ${stamp_case_start}    Get Timestamp For Current Time
    start SAS server    path=${sas_3}    config_name=${CB009154_A_FCE_102_conf}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    ${nrcbsdid}    Get Parameter value via COAM    class_name=NRCBSD_R    pattern=assignedCbsdId    connection=GNB_OAM
    Sleep    240s
    Check featureCapabilityExchangeresponse 102 SAS step    cbsdid=${nrcbsdid}
    Wait Until Keyword Succeeds    2min    5s    Check Alarm in Alarm List    type=History    faultId=6829
    ...    stamp_case_start=${stamp_case_start}    expect=${True}
    ...    Supplementary=FeatureCapabilityExchange Exception with Reason: 102. ResponseMessage: Required parameters missing. ResponseData: .
    verify all cells should be onair

CB009154-A_FCE_SpectrumInquiryresponse_300_featureCapabilityExchangeresponse_101
    ${stamp_case_start}    Get Timestamp For Current Time
    start SAS server    path=${sas_3}    config_name=${CB009154_A_FCE_101_conf}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    ${nrcbsdid}    Get Parameter value via COAM    class_name=NRCBSD_R    pattern=assignedCbsdId    connection=GNB_OAM
    Sleep    240s
    Check featureCapabilityExchangeresponse 101 SAS step    cbsdid=${nrcbsdid}
#    Wait Until Keyword Succeeds    2min    5s    Check Alarm in Alarm List    type=History    faultId=6827
#    ...    stamp_case_start=${stamp_case_start}    expect=${True}
#    ...    Supplementary=FeatureCapabilityExchange Exception with Reason: 101. ResponseMessage: CBSD is blacklisted.
    Wait until keyword succeeds    5min    30s    verify all cells should be onair

Check featureCapabilityExchangeresponse 101 SAS step
    [Arguments]     ${cbsdid}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*\"cbrsaGroupId\":.*\"cbrsaGroupId\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"cbsdId\": \"${cbsdid}\".*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 300.*
    Check if message is found in saslog    tag={\"featureCapabilityExchangeRequest\":.*
    Check if message is found in saslog    tag={\"featureCapabilityExchangeResponse\":.*\"responseCode\": 101.*
    Check if message is found in saslog    tag={\"deregistrationRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"deregistrationResponse\":.*\"cbsdId\": \"${cbsdid}\".*
    Check if message is found in saslog    tag={\"registrationRequest\":.*\"cbrsaGroupId\":.*\"cbrsaGroupId\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"cbsdId\": \"${cbsdid}\".*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    [Teardown]    end_to_check


Check featureCapabilityExchangeresponse 102 SAS step
    [Arguments]     ${cbsdid}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*\"cbrsaGroupId\":.*\"cbrsaGroupId\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"cbsdId\": \"${cbsdid}\".*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"featureCapabilityExchangeRequest\":.*
    Check if message is found in saslog    tag={\"featureCapabilityExchangeResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"featureCapabilityExchangeRequest\":.*
    Check if message is found in saslog    tag={\"featureCapabilityExchangeResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"featureCapabilityExchangeRequest\":.*
    Check if message is found in saslog    tag={\"featureCapabilityExchangeResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"featureCapabilityExchangeRequest\":.*
    Check if message is found in saslog    tag={\"featureCapabilityExchangeResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"responseCode\": 500.*
    Check if message is found in saslog    tag={\"featureCapabilityExchangeRequest\":.*
    Check if message is found in saslog    tag={\"featureCapabilityExchangeResponse\":.*\"responseCode\": 102.*
    Check if message is found in saslog    tag={\"deregistrationRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"deregistrationResponse\":.*\"cbsdId\": \"${cbsdid}\".*
    Check if message is found in saslog    tag={\"registrationRequest\":.*\"cbrsaGroupId\":.*\"cbrsaGroupId\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"cbsdId\": \"${cbsdid}\".*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    [Teardown]    end_to_check

Check featureCapabilityExchangeresponse 103 SAS step
    [Arguments]     ${cbsdid}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*\"cbrsaGroupId\":.*\"cbrsaGroupId\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"cbsdId\": \"${cbsdid}\".*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"featureCapabilityExchangeRequest\":.*
    Check if message is found in saslog    tag={\"featureCapabilityExchangeResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"featureCapabilityExchangeRequest\":.*
    Check if message is found in saslog    tag={\"featureCapabilityExchangeResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"featureCapabilityExchangeRequest\":.*
    Check if message is found in saslog    tag={\"featureCapabilityExchangeResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"featureCapabilityExchangeRequest\":.*
    Check if message is found in saslog    tag={\"featureCapabilityExchangeResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"featureCapabilityExchangeRequest\":.*
    Check if message is found in saslog    tag={\"featureCapabilityExchangeResponse\":.*\"responseCode\": 103.*
    Check if message is found in saslog    tag={\"deregistrationRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"deregistrationResponse\":.*\"cbsdId\": \"${cbsdid}\".*
    Check if message is found in saslog    tag={\"registrationRequest\":.*\"cbrsaGroupId\":.*\"cbrsaGroupId\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"cbsdId\": \"${cbsdid}\".*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    [Teardown]    end_to_check
