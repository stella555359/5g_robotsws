*** Settings ***
Resource    ../../../resources/cbrs_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    CB008923-E.py

Documentation    This is for CB007857 common keywords
...              Author: cailanwen
...              Squard: HZ SG8

*** Variables ***
${sas_2_0}    /testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CBRS/resources/SASSim_TS2
#${SAS_V2_ET}    /testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CBRS/resources/SASSim_5GV2
${sas_2_0_log}    ${CURDIR}/../../../resources/SASSim_TS2/SAS_Sim.log
${sas_log}    ${CURDIR}/../../../resources/SASSim_HZ/SAS_Sim.log

${CB008923-E-ET_conf_path}    ${CURDIR}/conf
${CB008923-E-49_conf}    ${CB008923-E-ET_conf_path}/SAS_Sim49.conf
${CB008923-E-74_conf}    ${CB008923-E-ET_conf_path}/SAS_Sim74.conf
${CB008923-E-54_conf}    ${CB008923-E-ET_conf_path}/SAS_Sim54.conf
${CB008923-E-63_conf}    ${CB008923-E-ET_conf_path}/SAS_Sim63.conf
${CB008923-E-16_conf}    ${CB008923-E-ET_conf_path}/SAS_Sim16.conf
${CB008923-E-24_conf}    ${CB008923-E-ET_conf_path}/SAS_Sim24.conf
${CB008923-E-03_conf}    ${CB008923-E-ET_conf_path}/SAS_Sim03.conf
${CB008923-E-04_conf}    ${CB008923-E-ET_conf_path}/SAS_Sim04.conf
${CB008923-E-10_conf}    ${CB008923-E-ET_conf_path}/SAS_Sim10.conf
${CB008923-E-19_conf}    ${CB008923-E-ET_conf_path}/SAS_Sim19.conf
${CB008923-E-07_conf}    ${CB008923-E-ET_conf_path}/SAS_Sim07.conf
${CB008923-E-42_conf}    ${CB008923-E-ET_conf_path}/SAS_Sim42.conf
${CB008923-E-40_conf}    ${CB008923-E-ET_conf_path}/SAS_Sim40.conf
${CB008923-E-38_conf}    ${CB008923-E-ET_conf_path}/SAS_Sim38.conf
${CB008923-E-31_conf}    ${CB008923-E-ET_conf_path}/SAS_Sim31.conf
${CB008923-E-33_conf}    ${CB008923-E-ET_conf_path}/SAS_Sim33.conf
${CB008923-E-16_19_conf}    ${CB008923-E-ET_conf_path}/SAS_Sim16_19.conf
${CB008923-E-31_33_conf}    ${CB008923-E-ET_conf_path}/SAS_Sim31_33.conf

${CB008923-E_json_path}    ${CURDIR}/json
${CB008923-E-49_JSON}    ${CB008923-E_json_path}/actnrCBRS.json
${CB008923-E-74_JSON}    ${CB008923-E_json_path}/GroupIdStringDel.json
${CB008923-E-74_Lcg/Ccg01_JSON}    ${CB008923-E_json_path}/LcgAndccg01.json
${CB008923-E-74_Lcg/Ccg02_JSON}    ${CB008923-E_json_path}/LcgAndccg02.json
${CB008923-E-63_GAA_JSON}    ${CB008923-E_json_path}/GAA.json
${CB008923-E-63_PAL_JSON}    ${CB008923-E_json_path}/PAL.json
${CB008923-E-03_DPModel_JSON}    ${CB008923-E_json_path}/DPModelDelta.json
${CB008923-E-03_recovery_JSON}    ${CB008923-E_json_path}/RecoveryForcase3.json
${CB008923-E-42_V2_JSON}    ${CB008923-E_json_path}/V2.json
${CB008923-E-42_V2Recovery_JSON}    ${CB008923-E_json_path}/V2Recovery.json
${CB008923-E-40_V2_JSON}    ${CB008923-E_json_path}/V2.json
${CB008923-E-40_V2Recovery_JSON}    ${CB008923-E_json_path}/V2Recovery.json
${CB008923-E-38_V2_JSON}    ${CB008923-E_json_path}/V2.json
${CB008923-E-38_V2Recovery_JSON}    ${CB008923-E_json_path}/V2Recovery.json
${CB008923-E-38_V2RecoverytoAll_JSON}    ${CB008923-E_json_path}/V2RecoverytoAll.json




*** Keywords ***
Case Preparation for CB008923-E
    ${SCF_8923-E_2CC}    Replace String    ${Golden_SCF_Path}    .xml    _8923E_2CC.xml
    set suite variable  ${SCF_8923-E_2CC}
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_8923-E_2CC}
    &{fault_7313}     Create Dictionary     faultId=${7313}
    ${ALLOWED_FAULT}   Create List   @{ALLOWED_FAULT}   ${fault_7313}
    set suite variable  ${ALLOWED_FAULT}

CB008923-E_49_CBSD_TS20_supportGrantUpdate_desiredPmax_reach_maxEirp_more_channelType_same
    [Arguments]    ${connection}=GNB_OAM    ${NRCBSDID}=1
    start SAS server    config_name=${CB008923-E-49_conf}    path=${sas_2_0}
    Wait until keyword succeeds    20min    30s    verify all cells should be onair
    prepare_to_check_message_from_start
    log to console   start check message info...
    check register request and response info
    Check Register Status By Coam    expect_register_status=Registered    NRCBSDID=${NRCBSDID}
    check SI request and response info
    check grant request and response info
    check heartbeat request and response info
    [Teardown]    end to check
#    [Teardown]    coam.perform_delta_recommissioning    delta_file=${CB008923-E-49_JSON}    connection=${connection}

CB008923-E_74_CBSD_TS20_HB_modify_cbrsaGroupParam_trigger_re-registration
    [Arguments]    ${connection}=GNB_OAM    ${NRCBSDID}=1
    coam.perform_delta_recommissioning    delta_file=${CB008923-E-74_JSON}    connection=${connection}
    sleep    300s    msg=wait update...
    start SAS server    config_name=${CB008923-E-74_conf}    path=${sas_2_0}
    Wait until keyword succeeds    20min    30s    verify all cells should be onair
    prepare_to_check_message_from_start
    log to console   start check message info...
    check register request and response info
    Check Register Status By Coam    expect_register_status=Registered    NRCBSDID=${NRCBSDID}
    check SI request and response info
    check grant request and response info
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"responseCode\": 106.*
    log to console    start update Lcg and Ccg...
    coam.perform_delta_recommissioning    delta_file=${CB008923-E-74_Lcg/Ccg01_JSON}    connection=${connection}
    sleep    300s
    check deregister request and response info
    log to console    start update Lcg and Ccg...
    coam.perform_delta_recommissioning    delta_file=${CB008923-E-74_Lcg/Ccg02_JSON}    connection=${connection}
    sleep    300s
    check deregister request and response info
    [Teardown]    end to check
    #    [Teardown]    coam.perform_delta_recommissioning    delta_file=${CB008923-E-49_JSON}    connection=${connection}

CB008923-E_54_CBSD_TS20_supportGrantUpdate_GRANT_RC401
    [Arguments]    ${connection}=GNB_OAM    ${NRCBSDID}=1
    start SAS server    config_name=${CB008923-E-54_conf}    path=${sas_2_0}
    Wait until keyword succeeds    20min    30s    verify all cells should be onair
    prepare_to_check_message_from_start
    log to console   start check message info...
    check register request and response info
    Check Register Status By Coam    expect_register_status=Registered    NRCBSDID=${NRCBSDID}
    check SI request and response info
    check grant request and response info
    check heartbeat request and response info
    Wait Until Keyword Succeeds    200    2    check heartbeat request and response info
    Wait Until Keyword Succeeds    200    2    check heartbeat request and response info
    Wait Until Keyword Succeeds    200    2    Check if message is found in saslog    tag={\"grantRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 401.*
    Wait Until Keyword Succeeds    200    2    check heartbeat request and response info
    [Teardown]    end to check
#    [Teardown]    coam.perform_delta_recommissioning    delta_file=${CB008923-E-49_JSON}    connection=${connection}

CB008923-E_63_CBSD_TS20_notSupportGrantUpdate_desiredPmax_not_reach_maxEirp_different_channelType_different
    [Arguments]    ${connection}=GNB_OAM    ${NRCBSDID}=1
    start SAS server    config_name=${CB008923-E-63_conf}    path=${sas_2_0}
    Wait until keyword succeeds    20min    30s    verify all cells should be onair
    prepare_to_check_message_from_start
    log to console   start check message info...
    check register request and response info
    Check Register Status By Coam    expect_register_status=Registered    NRCBSDID=${NRCBSDID}
    check SI request and response info
    check grant request and response info
    check heartbeat request and response info
    coam.perform_delta_recommissioning    delta_file=${CB008923-E-63_GAA_JSON}    connection=${connection}
    sleep    300s    msg=wait cbrsFreqType change to GAA...
    check relinquishment request and response info
    check grant request and response info
    check heartbeat request and response info
    coam.perform_delta_recommissioning    delta_file=${CB008923-E-63_PAL_JSON}    connection=${connection}
    sleep    300s    msg=wait cbrsFreqType change to PAL...
    check grant request and response info
    check heartbeat request and response info
    [Teardown]    end to check
    #    [Teardown]    coam.perform_delta_recommissioning    delta_file=${CB008923-E-49_JSON}    connection=${connection}

CB008923-E_16_CBSD_TS20_SI_RC300_featureCapabilityExchange
    [Arguments]    ${connection}=GNB_OAM    ${NRCBSDID}=1
    start SAS server    config_name=${CB008923-E-16_conf}    path=${sas_2_0}
    Wait until keyword succeeds    20min    30s    verify all cells should be onair
    prepare_to_check_message_from_start
    log to console   start check message info...
    check register request and response info
    Check Register Status By Coam    expect_register_status=Registered    NRCBSDID=${NRCBSDID}
    sleep    140s
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog
    ...    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 300.*\"featureCapabilityExchangeTrigger\": true.*
    Check if message is found in saslog    tag={\"featureCapabilityExchangeRequest\":.*
    Check if message is found in saslog    tag={\"featureCapabilityExchangeResponse\":.*\"responseCode\": 0.*
    check grant request and response info
    check heartbeat request and response info
    [Teardown]    end_to_check

CB008923-E_096_CBSD_FeatureCapabilityExchange_Check_after_SI_HB_error_code
    [Arguments]    ${connection}=GNB_OAM    ${NRCBSDID}=1
    start SAS server    config_name=${CB008923-E-16_19_conf}    path=${sas_2_0}
    Wait until keyword succeeds    20min    30s    verify all cells should be onair
    prepare_to_check_message_from_start
    log to console   start check message info...
    check register request and response info
    Check Register Status By Coam    expect_register_status=Registered    NRCBSDID=${NRCBSDID}
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Wait Until Keyword Succeeds    200    2    Check if message is found in saslog
    ...    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 300.*\"featureCapabilityExchangeTrigger\": true.*
    Check if message is found in saslog    tag={\"featureCapabilityExchangeRequest\":.*
    Check if message is found in saslog    tag={\"featureCapabilityExchangeResponse\":.*\"responseCode\": 0.*
    check SI request and response info
    check grant request and response info
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog
    ...    tag={\"heartbeatResponse\":.*\"responseCode\": 400.*\"featureCapabilityExchangeTrigger\": true.*
    Check if message is found in saslog    tag={\"featureCapabilityExchangeRequest\":.*
    Check if message is found in saslog    tag={\"featureCapabilityExchangeResponse\":.*\"responseCode\": 0.*
#    check grant request and response info
#    check heartbeat request and response info
    [Teardown]    end_to_check

CB008923-E_24_CBSD_TS20_supportEnhGroupHandling_cbrsaVersion_mismatch_HB_trigger_re-registration
    [Arguments]    ${connection}=GNB_OAM    ${NRCBSDID}=1
    start SAS server    config_name=${CB008923-E-24_conf}    path=${sas_2_0}
    Wait until keyword succeeds    20min    30s    verify all cells should be onair
    prepare_to_check_message_from_start
    log to console   start check message info...
    check register request and response info
    Check Register Status By Coam    expect_register_status=Registered    NRCBSDID=${NRCBSDID}
    check SI request and response info
    check grant request and response info
    check heartbeat request and response info
    sleep    140s
    check deregister request and response info
    check register request and response info
    check SI request and response info
    check grant request and response info
    check heartbeat request and response info
    [Teardown]    end to check

CB008923-E_03_SAS-CBSD_TS2.0_new_parameter_through_domainProxy
    [Arguments]    ${connection}=GNB_OAM    ${NRCBSDID}=1
    Set DPProxy Model and IP
    start SAS server    config_name=${CB008923-E-03_conf}    path=${sas_2_0}
    Wait until keyword succeeds    20min    30s    verify all cells should be onair
    prepare_to_check_message_from_start
    log to console   start check message info...
    Check if message is found in saslog    tag={\"registrationRequest\":.*\"cbsdFeatureCapabilityList\".*\"groupInfo\".*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 0.*
    Check Register Status By Coam    expect_register_status=Registered    NRCBSDID=${NRCBSDID}
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"groupInfo\".*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"cbsdFrequencyGuidance\".*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"grantRequest\":.*\"groupInfo\".*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"grantResponse\":.*\"cbsdFrequencyGuidance\".*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"groupInfo\".*\"cellInfo\".*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"cbsdFrequencyGuidance\".*
    [Teardown]    Run Keywords
    ...    coam.perform_delta_recommissioning    delta_file=${CB008923-E-03_recovery_JSON}    connection=${connection}    AND
    ...    end to check

CB008923-E_04_CBSD_TS20_RC100_REG_trigger_TS12_re-registration
    [Arguments]    ${connection}=GNB_OAM    ${NRCBSDID}=1
    Set DPProxy Model and IP
    start SAS server    config_name=${CB008923-E-04_conf}    path=${sas_2_0}
    Wait until keyword succeeds    20min    30s    verify all cells should be onair
    prepare_to_check_message_from_start
    log to console   start check message info...
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag=POST .*/v2.0/registration HTTP/1.1
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 100.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag=POST .*/v1.2/registration HTTP/1.1
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 100.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag=POST .*/v2.0/registration HTTP/1.1
    check register request and response info
    Wait Until Keyword Succeeds    200    2
    ...    Check Register Status By Coam    expect_register_status=Registered    NRCBSDID=${NRCBSDID}
    check SI request and response info
    check grant request and response info
    check heartbeat request and response info
    [Teardown]    end_to_check

CB008923-E_10_CBSD_TS20_RC100_HB_trigger_TS12_re-registration
    [Arguments]    ${connection}=GNB_OAM    ${NRCBSDID}=1
    Set DPProxy Model and IP
    start SAS server    config_name=${CB008923-E-10_conf}    path=${sas_2_0}
    Wait until keyword succeeds    20min    30s    verify all cells should be onair
    prepare_to_check_message_from_start
    log to console   start check message info...
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag=POST .*/v2.0/registration HTTP/1.1
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 100.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag=POST .*/v1.2/registration HTTP/1.1
    check register request and response info
    Wait Until Keyword Succeeds    200    2
    ...    Check Register Status By Coam    expect_register_status=Registered    NRCBSDID=${NRCBSDID}
    check SI request and response info
    check grant request and response info
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"responseCode\": 100.*
    check deregister request and response info
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag=POST .*/v2.0/registration HTTP/1.1
    check register request and response info
    Wait Until Keyword Succeeds    200    2
    ...    Check Register Status By Coam    expect_register_status=Registered    NRCBSDID=${NRCBSDID}
    check SI request and response info
    check grant request and response info
    check heartbeat request and response info
    [Teardown]    end_to_check

CB008923-E_19_CBSD_TS20_HB_invalidRC400_featureCapabilityExchange
    [Arguments]    ${connection}=GNB_OAM    ${NRCBSDID}=1
    start SAS server    config_name=${CB008923-E-19_conf}    path=${sas_2_0}
    Wait until keyword succeeds    20min    30s    verify all cells should be onair
    prepare_to_check_message_from_start
    log to console   start check message info...
    check register request and response info
    Check Register Status By Coam    expect_register_status=Registered    NRCBSDID=${NRCBSDID}
    check SI request and response info
    check grant request and response info
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog
    ...    tag={\"heartbeatResponse\":.*\"responseCode\": 400.*\"featureCapabilityExchangeTrigger\": true.*
    Check if message is found in saslog    tag={\"featureCapabilityExchangeRequest\":.*
    Check if message is found in saslog    tag={\"featureCapabilityExchangeResponse\":.*\"responseCode\": 0.*
    [Teardown]    end_to_check

CB008923-E_07_CBSD_TS20_HTTPSC404_SI_trigger_TS12_re-registration
    [Arguments]    ${connection}=GNB_OAM    ${NRCBSDID}=1
    start SAS server    config_name=${CB008923-E-07_conf}    path=${sas_2_0}
    Wait until keyword succeeds    20min    30s    verify all cells should be onair
    prepare_to_check_message_from_start
    log to console   start check message info...
    Wait Until Keyword Succeeds    200    2
    ...    grep if msg is found in saslog    msg=POST .*/v2.0/registration HTTP/1.1
    check register request and response info
    Wait Until Keyword Succeeds    200    2
    ...    Check Register Status By Coam    expect_register_status=Registered    NRCBSDID=${NRCBSDID}
    Wait Until Keyword Succeeds    200    2
    ...    grep if msg is found in saslog    msg=HTTP/1.1 404 Not Found
    check deregister request and response info
    check SI request and response info
    check grant request and response info
    check heartbeat request and response info
    Wait Until Keyword Succeeds    200    1
    ...    grep if msg is found in saslog    msg=POST .*/v1.2/registration HTTP/1.1
#    Check if message is found in saslog    tag=POST /v1.2/registration HTTP/1.1
    [Teardown]    end_to_check

CB008923-E_42_CBSD_TS20_cbsdFrequencyGuidance_match_operationParam
    [Arguments]    ${connection}=GNB_OAM    ${NRCBSDID}=1
    coam.perform_delta_recommissioning    delta_file=${CB008923-E-42_V2_JSON}    connection=${connection}
    sleep    300s    msg=wait update V2...
    start SAS server    config_name=${CB008923-E-42_conf}    path=${sas_2_0}
    Wait until keyword succeeds    20min    30s    verify all cells should be onair
    prepare_to_check_message_from_start
    log to console   start check message info...
    check register request and response info
    Check Register Status By Coam    expect_register_status=Registered    NRCBSDID=${NRCBSDID}
    check SI request and response info
    check grant request and response info
    check heartbeat request and response info
    Wait Until Keyword Succeeds    200    2    check heartbeat request and response info
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Wait Until Keyword Succeeds    200    2
    ...    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"responseCode\": 501.*
    Wait Until Keyword Succeeds    200    2    check SI request and response info
    Wait Until Keyword Succeeds    200    2    check grant request and response info
    Wait Until Keyword Succeeds    200    2    check heartbeat request and response info
    [Teardown]    Run Keywords
    ...    coam.perform_delta_recommissioning    delta_file=${CB008923-E-42_V2Recovery_JSON}    connection=${connection}    AND
    ...    end to check

CB008923-E_40_CBSD_TS20_cbsdFrequencyGuidance_match_supportedSpectrumV2_and_match_desiredChBw
    [Arguments]    ${connection}=GNB_OAM    ${NRCBSDID}=1
    coam.perform_delta_recommissioning    delta_file=${CB008923-E-40_V2_JSON}    connection=${connection}
    sleep    300s    msg=wait update V2...
    start SAS server    config_name=${CB008923-E-40_conf}    path=${sas_2_0}
    Wait until keyword succeeds    20min    30s    verify all cells should be onair
    prepare_to_check_message_from_start
    log to console   start check message info...
    check register request and response info
    Check Register Status By Coam    expect_register_status=Registered    NRCBSDID=${NRCBSDID}
    check SI request and response info
    check grant request and response info
    check heartbeat request and response info
    [Teardown]    Run Keywords
    ...    coam.perform_delta_recommissioning    delta_file=${CB008923-E-40_V2Recovery_JSON}    connection=${connection}    AND
    ...    end to check

CB008923-E_38_CBSD_TS20_cbsdFrequencyGuidance_mismatch_supportedSpectrumV2
    [Arguments]    ${connection}=GNB_OAM    ${NRCBSDID}=1
    ${stamp_case_start}    Get Timestamp For Current Time
    coam.perform_delta_recommissioning    delta_file=${CB008923-E-38_V2_JSON}    connection=${connection}
    sleep    300s    msg=wait update V2...
    start SAS server    config_name=${CB008923-E-38_conf}    path=${sas_2_0}
#    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    sleep    40s
    prepare_to_check_message_from_start
    log to console   start check message info...
    check register request and response info
    Check Register Status By Coam    expect_register_status=Registered    NRCBSDID=${NRCBSDID}
    check SI request and response info
    Wait Until Keyword Succeeds    5min    5s    Check Alarm in Alarm List    type=Active    faultId=6828
    ...    stamp_case_start=${stamp_case_start}    Supplementary=No available frequency.    expect=${True}
    coam.perform_delta_recommissioning    delta_file=${CB008923-E-38_V2RecoverytoAll_JSON}    connection=${connection}
    sleep    300s    msg=wait update V2...
#    Wait until keyword succeeds    200    2    check SI request and response info
    check grant request and response info
    check heartbeat request and response info
    Wait until keyword succeeds    20min    30s    verify all cells should be onair
    [Teardown]    Run Keywords
    ...    coam.perform_delta_recommissioning    delta_file=${CB008923-E-38_V2Recovery_JSON}    connection=${connection}    AND
    ...    end to check

CB008923-E_31_CBSD_TS20_notSupportEnhGroupHandling_cbrsaVersion_mismatch_GRANT_not_trigger_re-registration
    [Arguments]    ${connection}=GNB_OAM    ${NRCBSDID}=1
    start SAS server    config_name=${CB008923-E-31_conf}    path=${sas_2_0}
    Wait until keyword succeeds    20min    30s    verify all cells should be onair
    prepare_to_check_message_from_start
    log to console   start check message info...
    check register request and response info
    Check Register Status By Coam    expect_register_status=Registered    NRCBSDID=${NRCBSDID}
    check SI request and response info
    check grant request and response info
    Run Keyword And Expect Error    *    check deregister request and response info
    Wait Until Keyword Succeeds    200    2    check heartbeat request and response info
    [Teardown]    end to check

CB008923-E_33_CBSD_TS20_notSupportEnhGroupHandling_eutraTddConfig_mismatch_HB_not_trigger_re-registration
    [Arguments]    ${connection}=GNB_OAM    ${NRCBSDID}=1
    start SAS server    config_name=${CB008923-E-33_conf}    path=${sas_2_0}
    Wait until keyword succeeds    20min    30s    verify all cells should be onair
    prepare_to_check_message_from_start
    log to console   start check message info...
    check register request and response info
    Check Register Status By Coam    expect_register_status=Registered    NRCBSDID=${NRCBSDID}
    check SI request and response info
    check grant request and response info
    check heartbeat request and response info
    [Teardown]    end to check

CB008923-E_104_CBSD_TS20_notSupportEnhGroupHandling_cbrsaVersion_eutraTddConfig_mismatch_GRANT_HB
    [Arguments]    ${connection}=GNB_OAM    ${NRCBSDID}=1
    start SAS server    config_name=${CB008923-E-31_33_conf}    path=${sas_2_0}
    Wait until keyword succeeds    20min    30s    verify all cells should be onair
    prepare_to_check_message_from_start
    log to console   start check message info...
    check register request and response info
    Check Register Status By Coam    expect_register_status=Registered    NRCBSDID=${NRCBSDID}
    check SI request and response info
    check grant request and response info
    Run Keyword And Expect Error    *    check deregister request and response info
    Wait Until Keyword Succeeds    200    2    check heartbeat request and response info
    [Teardown]    end to check

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

Set DPProxy Model and IP
    [Arguments]    ${connection}=GNB_OAM
    ${ip}=    get_local_ip    ifname=eth0
    ${result}=    Run Process    sed -i 's/DpIPAndPort/${ip}/g' ${CB008923-E-03_DPModel_JSON}
    ...    shell=True    timeout=20
    coam.perform_delta_recommissioning    delta_file=${CB008923-E-03_DPModel_JSON}    connection=${connection}
    sleep    300s    msg=wait update...
#    Wait Until Keyword Succeeds    50    10    ADMIN Perform Delta Recommissioning
#    ...    ${COMMSSIONING_FILEPATH}${DPModelDelta}    True    timeout=300

grep if msg is found in saslog
    [Arguments]    ${msg}    ${SAS_version}=${2.0}
    ${result}=    Run Keyword If    ${SAS_version}==${2.0}    Run Process    cat ${sas_2_0_log} | grep '${msg}'    shell=True   timeout=2
    ...    ELSE    Run Process    cat ${sas_log} | grep '${msg}'    shell=True   timeout=2
    Should Not Be Empty    ${result.stdout}
    log    ${result.stdout}
