*** Settings ***
Documentation
...    author: Qingqing Wang
...    contact: qingqing.1.wang@nokia-sbell.com
...    squad group: SG_08
...    feature : CB012365

Resource    testsuite/Timisoara/Handover/CBRS/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Timisoara/Handover/CBRS/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
Resource    testsuite/Timisoara/Handover/CBRS/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    testsuite/Timisoara/Handover/CBRS/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    ../../resources/cbrs_common_keywords.robot
Library    testsuite/Timisoara/Handover/CBRS/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common.py

*** Variables ***
${CB012365_conf_path}    ${CURDIR}/conf
${CB012365_2_conf}    ${CB012365_conf_path}/CB012365_2.conf
${CB012365_24_conf}    ${CB012365_conf_path}/CB012365_24.conf
${CB012365_10_conf}    ${CB012365_conf_path}/CB012365_10.conf
${CB012365_21_conf}    ${CB012365_conf_path}/CB012365_21.conf
${CB012365_34_conf}    ${CB012365_conf_path}/CB012365_34.conf
${CB012365_39_conf}    ${CB012365_conf_path}/CB012365_39.conf
${CB012365_json_path}    ${CURDIR}/json
${CB012365_palGaaPwrDiff_0}    ${CB012365_json_path}/palGaaPwrDiff_0.json
${CB012365_palGaaPwrDiff_3}    ${CB012365_json_path}/palGaaPwrDiff_3.json


*** Keywords ***
CB012365 CBRS Suite Setup
    CBRS Suite Setup    feature_scf_flag=${True}
    ${SCF_CB012365_common}    Replace String    ${Golden_SCF_Path}    SCF_   SCF_CB012365_
    set suite variable  ${SCF_CB012365_common}
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB012365_common}

CB012365_39_CBSD_Behaviors_after_online_change_of_palGaaPwrDiff_noimpact_impact
#    Check LTE whether need power off
    ${SCF_CB012365_4cc_case39}    Replace String    ${Golden_SCF_Path}    SCF_   SCF_CB012365_4cc_case39_
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB012365_4cc_case39}
    Activate feature CBRS By Coam
    start SAS server    config_name=${CB012365_39_conf}    path=${sas_3}
    Wait until keyword succeeds    10min    10s    verify cell status not degrade or disable by cellid    cellid=999
    ...    administrative=Unlocked    operationalState=enabled
    Wait until keyword succeeds    6min    10s    verify all cells should be onair
    ${chBw_cell1}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw
    ${chBw_cell2}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw    cellID=2
    ${chBw_cell3}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw    cellID=3
    ${chBw_cell4}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw    cellID=4
    Should be True    '${chBw_cell1}'=='60MHz'
    Should be True    '${chBw_cell2}'=='40MHz'
    Should be True    '${chBw_cell3}'=='20MHz'
    Should be True    '${chBw_cell4}'=='20MHz'
    coam.perform_delta_recommissioning    delta_file=${CB012365_palGaaPwrDiff_3}    connection=GNB_OAM
    sleep    100s
    verify cell status not degrade or disable by cellid    cellid=999
    ...    administrative=Unlocked    operationalState=enabled
    verify all cells should be onair
    ${chBw_cell1}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw
    ${chBw_cell2}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw    cellID=2
    ${chBw_cell3}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw    cellID=3
    ${chBw_cell4}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw    cellID=4
    Should be True    '${chBw_cell1}'=='60MHz'
    Should be True    '${chBw_cell2}'=='40MHz'
    Should be True    '${chBw_cell3}'=='20MHz'
    Should be True    '${chBw_cell4}'=='20MHz'
    coam.perform_delta_recommissioning    delta_file=${CB012365_palGaaPwrDiff_0}    connection=GNB_OAM
    sleep    100s
    Wait until keyword succeeds    10min    10s    verify cell status not degrade or disable by cellid    cellid=999
    ...    administrative=Unlocked    operationalState=enabled
    Wait until keyword succeeds    6min    10s    verify all cells should be onair
    ${chBw_cell1}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw
    ${chBw_cell2}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw    cellID=2
    ${chBw_cell3}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw    cellID=3
    ${chBw_cell4}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw    cellID=4
    Should be True    '${chBw_cell1}'=='10MHz'
    Should be True    '${chBw_cell2}'=='10MHz'
    Should be True    '${chBw_cell3}'=='10MHz'
    Should be True    '${chBw_cell4}'=='10MHz'

Check CB012365_34 SAS step by cbsdid
    [Arguments]    ${cbsdid}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"cbsdId\": \"${cbsdid}\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 501.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"relinquishmentResponse\":.*\"cbsdId\": \"${cbsdid}\".*
    [Teardown]    end_to_check

CB012365_34_Behavior_when_CBSD_Subsequent_Heartbeat_Receives_both_PAL_and_GAA_ResponseCode501_with_OperationParm
#    Check LTE whether need power off
    ${SCF_CB012365_1cc_case34}    Replace String    ${Golden_SCF_Path}    SCF_   SCF_CB012365_1cc_case34_
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB012365_1cc_case34}
    Activate feature CBRS By Coam
    start SAS server    config_name=${CB012365_34_conf}    path=${sas_3}
    Wait until keyword succeeds    10min    10s    verify cell status not degrade or disable by cellid    cellid=999
    ...    administrative=Unlocked    operationalState=enabled
    Wait until keyword succeeds    6min    10s    verify all cells should be onair
    ${nrcell1_grantid}    Get subGrantInfo Item by Coam    pattern=grantIdSub
    Should be True    '${nrcell1_grantid}'=='3550000000_3610000000_MIX'
    sleep    600s
    ${nrcell1_grantid}    Get subGrantInfo Item by Coam    pattern=grantIdSub
    Should be True    '${nrcell1_grantid}'=='3620000000_3680000000_MIX'
    Check CB012365_34 SAS step by cbsdid    cbsdid=1125_Nokia_EB2313R0212.NR

CB012365_21_gNB_Behavior_when_CBSD_Initial_Heartbeat_Receives_PAL_Success_Response_but_GAA_ResponseCode_501_PAL_drop_part
    ${SCF_CB012365_1cc_case21}    Replace String    ${Golden_SCF_Path}    SCF_   SCF_CB012365_1cc_case21_
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB012365_1cc_case21}
    Activate feature CBRS By Coam
    start SAS server    config_name=${CB012365_21_conf}    path=${sas_3}
    Wait until keyword succeeds    10min    10s    verify cell status not degrade or disable by cellid    cellid=999
    ...    administrative=Unlocked    operationalState=enabled
    Wait until keyword succeeds    6min    10s    verify all cells should be onair
    sleep    30s
    ${nrcell1_grantid}    Get subGrantInfo Item by Coam    pattern=grantIdSub
    Run Keyword If    '${nrcell1_grantid}'!='3550000000_3610000000_MIX'
    ...    Should be True    '${nrcell1_grantid}'=='3570000000_3610000000'
    ${grant_info_cell1}    Get Grant Parameters By Coam
	Should be True    '${grant_info_cell1}[grantChannelType]'=='PAL'
    ${tmp}=   Evaluate    ${grant_info_cell1}[SpectrumFreqHigh] - ${grant_info_cell1}[SpectrumFreqLow]
    Should be True    '${tmp}'=='30'
    sleep    600s
    ${nrcell1_grantid}    Get subGrantInfo Item by Coam    pattern=grantIdSub
    Should be True    '${nrcell1_grantid}'=='3550000000_3610000000_MIX'
    ${grant_info_cell1}    Get Grant Parameters By Coam
	Should be True    '${grant_info_cell1}[grantChannelType]'=='MIX'
    ${tmp}=   Evaluate    ${grant_info_cell1}[SpectrumFreqHigh] - ${grant_info_cell1}[SpectrumFreqLow]
    Should be True    '${tmp}'=='60'

Check CB012365_10 SAS step by cbsdid
    [Arguments]    ${cbsdid}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"cbsdId\": \"${cbsdid}\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 400.*
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"relinquishmentResponse\":.*\"cbsdId\": \"${cbsdid}\".*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"relinquishmentResponse\":.*\"cbsdId\": \"${cbsdid}\".*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    [Teardown]    end_to_check

CB012365_10_Behavior_when_CBSD_Initial_Grant_receives_with_GAA_ResponseCode_400_PAL_need_drop
    ${SCF_CB012365_1cc_case10}    Replace String    ${Golden_SCF_Path}    SCF_   SCF_CB012365_1cc_case10_
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB012365_1cc_case10}
    Activate feature CBRS By Coam
    start SAS server    config_name=${CB012365_10_conf}    path=${sas_3}
    sleep    120s
    Wait until keyword succeeds    10min    10s    verify cell status not degrade or disable by cellid    cellid=999
    ...    administrative=Unlocked    operationalState=enabled
    Wait until keyword succeeds    6min    10s    verify all cells should be onair
    sleep    60s
    ${nrcell1_grantid}    Get subGrantInfo Item by Coam    pattern=grantIdSub
    Run Keyword If    '${nrcell1_grantid}'!='3560000000_3600000000'
    ...    Should be True    '${nrcell1_grantid}'=='3550000000_3590000000'
    sleep    300s
    ${nrcell1_grantid}    Get subGrantInfo Item by Coam    pattern=grantIdSub
    Should be True    '${nrcell1_grantid}'=='3550000000_3630000000_MIX'
    Wait until keyword succeeds    5min    10s    verify cell status not degrade or disable by cellid    cellid=999
    ...    administrative=Unlocked    operationalState=enabled
    Wait until keyword succeeds    5min    10s    verify all cells should be onair
    Check CB012365_10 SAS step by cbsdid    cbsdid=1125_Nokia_EB2313R0212.NR

Check CB012365_24 SAS step by cbsdid
    [Arguments]    ${cbsdid}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"cbsdId\": \"${cbsdid}\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 502.*
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"relinquishmentResponse\":.*\"cbsdId\": \"${cbsdid}\".*
    [Teardown]    end_to_check

CB012365_24_Behavior_when_CBSD_Initial_Heartbeat_Receives_GAA_Success_Response_but_PAL_ResponseCode_502_GAA_meet
#    Check LTE whether need power off
    ${SCF_CB012365_1cc}    Replace String    ${Golden_SCF_Path}    SCF_   SCF_CB012365_1cc_
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB012365_1cc}
    Activate feature CBRS By Coam
    start SAS server    config_name=${CB012365_24_conf}    path=${sas_3}
    Wait until keyword succeeds    10min    10s    verify cell status not degrade or disable by cellid    cellid=999
    ...    administrative=Unlocked    operationalState=enabled
    Wait until keyword succeeds    6min    10s    verify all cells should be onair
    sleep    60s
    ${nrcell1_grantid}    Get subGrantInfo Item by Coam    pattern=grantIdSub
    Should be True    '${nrcell1_grantid}'=='3570000000_3610000000'
    ${chBw_cell1}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw    cellID=1
    Should be True    '${chBw_cell1}'=='40MHz'
    Check CB012365_24 SAS step by cbsdid    cbsdid=1125_Nokia_EB2313R0212.NR

CB012365_2_Frequency_Selection_Algorithem_when_Both_Sides_GAA_with_PAL_not_Meet_desiredChBw
    start SAS server    config_name=${CB012365_2_conf}    path=${sas_3}
    Wait until keyword succeeds    10min    10s    verify cell status not degrade or disable by cellid    cellid=999
    ...    administrative=Unlocked    operationalState=enabled
    Wait until keyword succeeds    10min    10s    verify cell status not degrade or disable by cellid    cellid=1000
    ...    administrative=Unlocked    operationalState=enabled
    Wait until keyword succeeds    6min    10s    verify all cells should be onair
    sleep    60s
    ${nrcell1_grantid}    Get subGrantInfo Item by Coam    pattern=grantIdSub
    ${nrcell2_grantid}    Get subGrantInfo Item by Coam    pattern=grantIdSub    cellID=2
    Should be True    '${nrcell1_grantid}'=='3580000000_3620000000_MIX'
    Should be True    '${nrcell2_grantid}'=='3550000000_3580000000_MIX'
    ${nrcell1_status}    Get subGrantInfo Item by Coam    pattern=grantOperationStateSub
    ${nrcell2_status}    Get subGrantInfo Item by Coam    pattern=grantOperationStateSub    cellID=2
    Should be True    '${nrcell1_status}'=='Authorized'
    Should be True    '${nrcell2_status}'=='Authorized'
