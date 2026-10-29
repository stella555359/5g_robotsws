*** Settings ***
Documentation
...    author: Qingqing Wang
...    contact: qingqing.1.wang@nokia-sbell.com
...    squad group: SG_08
...    feature : CB008498

Library       taf.selenium.sbts    WITH NAME    selenium_coam
Resource    ../../resources/cbrs_common_keywords.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common.py
Variables    ../TestData/8498_variables.py

*** Variables ***
@{cell_id2}    ${2}
@{cell_id1}    ${1}
${CB008498_conf_path}    ${CURDIR}/conf
${CB008498_7_conf}    ${CB008498_conf_path}/CB008498_7.conf
${CB008498_9_conf}    ${CB008498_conf_path}/CB008498_9.conf
${CB008498_12_conf}    ${CB008498_conf_path}/CB008498_12.conf
${CB008498_14_conf}    ${CB008498_conf_path}/CB008498_14.conf
${CB008498_19_conf}    ${CB008498_conf_path}/CB008498_19.conf
${CB008498_20_conf}    ${CB008498_conf_path}/CB008498_20.conf
${CB008498_21_conf}    ${CB008498_conf_path}/CB008498_21.conf
${CB008498_27_conf}    ${CB008498_conf_path}/CB008498_27.conf
${CB008498_30_conf}    ${CB008498_conf_path}/CB008498_30.conf
${CB009154_A_FCE_102_conf}    ${CB008498_conf_path}/CB009154_A_FCE_102.conf

${CB008498_json_path}    ${CURDIR}/json
${attach_cell1}    ${CB008498_json_path}/attach_cell1.json
${attach_cell2}    ${CB008498_json_path}/attach_cell2.json
${disable_actcbrs_actnrcbrs}    ${CB008498_json_path}/disable_actcbrs_actnrcbrs_TL993.json
${enable_actcbrs_actnrcbrs}    ${CB008498_json_path}/enable_actcbrs_actnrcbrs_TL993.json
${FCC_V2_Update}    ${CB008498_json_path}/FCC_V2_Update.json
*** Keywords ***
CB009154-C_9_CBSD_behavior_check_when_BBMOD_reset_MP
    ${SCF_CB009154_C_MP}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CB009154_C_MP_
    Commissioning SCF And Check RU On Air    scf_file_path=${SCF_CB009154_C_MP}
    Sleep    30s
    coam.perform_delta_recommissioning    delta_file=${enable_actcbrs_actnrcbrs}    connection=GNB_OAM
    Sleep    30s
    start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    ${grant_info_nr_old}    Get Grant Parameters By Coam
    ${grantId_lte_old}    Get Parameter value via COAM    class_name=CBSDCEL_R    pattern=grantId    connection=GNB_OAM
    coam.reset_unit    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/CABINET-1/BBMOD-1    reset_type=Warm    force_radio_reset=${True}
    ...    timeout=300s    connection=GNB_OAM
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    ${grant_info_nr_new}    Get Grant Parameters By Coam
    ${grantId_lte_new}    Get Parameter value via COAM    class_name=CBSDCEL_R    pattern=grantId    connection=GNB_OAM
    Should be True    '${grant_info_nr_new}[grantId]'=='${grant_info_nr_old}[grantId]'
    Should be True    '${grantId_lte_new}'=='${grantId_lte_old}'
    [Teardown]    coam.perform_delta_recommissioning    delta_file=${disable_actcbrs_actnrcbrs}    connection=GNB_OAM

CB009154-A_FCE_Heartbeatresponse_500_featureCapabilityExchangeresponse_102_MP
    ${SCF_CB009154_A_FCE}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CB009154_A_FCE_
    Commissioning SCF And Check RU On Air    scf_file_path=${SCF_CB009154_A_FCE}
    Sleep    60s
    Activate feature CBRS By Coam
    ${stamp_case_start}    Get Timestamp For Current Time
    start SAS server    path=${sas_3}    config_name=${CB009154_A_FCE_102_conf}
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    ${nrcbsdid}    Get Parameter value via COAM    class_name=NRCBSD_R    pattern=assignedCbsdId    connection=GNB_OAM
    Sleep    240s
    Check featureCapabilityExchangeresponse 102 SAS step    cbsdid=${nrcbsdid}
    Wait Until Keyword Succeeds    2min    5s    Check Alarm in Alarm List    type=History    faultId=6829
    ...    stamp_case_start=${stamp_case_start}    expect=${True}
    ...    Supplementary=FeatureCapabilityExchange Exception with Reason: 102. ResponseMessage: Required parameters missing. ResponseData: .
    verify all cells should be onair

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

CB008498_9_Online_change_CBSD_parameter
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] Online change CBSD parameter
    ...    *******************
    ...    qingqing.wang.1@nokia-sbell.com
    ${SCF_CB008498_9}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CB008498_9_
    Commissioning SCF And Check RU On Air    scf_file_path=${SCF_CB008498_9}
    Activate feature CBRS By Coam
    start SAS server    config_name=${CB008498_9_conf}
    Selenium Login And Disable Screen Lock
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    ${grant_info_original}    Get Grant Parameters By Coam
    Should be True    '${grant_info_original}[grantId]'=='3570000000_3590000000'
    coam.perform_delta_recommissioning    delta_file=${FCC_V2_Update}    connection=GNB_OAM
    Sleep    120s
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    ${grant_info_new}    Get Grant Parameters By Coam
    Should be True    '${grant_info_new}[grantId]'=='3550000000_3590000000'
    Selenium Logout And Close Browser
    Selenium Login And Disable Screen Lock
    Set actIpThpt value by webem    actIpThpt=false
    Wait until keyword succeeds    5min    30s    Verify all cells should be disabled
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    [Teardown]    Run keywords    Commissioning SCF And Check RU On Air    scf_file_path=${Golden_SCF_Path}    AND
    ...    Selenium Logout And Close Browser

CB008498_16_HW_validation_for_desirepmax_of_two_cell
    start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Selenium Login And Disable Screen Lock
    selenium_coam.set_parameter_value  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1/NRCBSDCELL-0
    ...    filter_param=Desired maximum output power
    ...    abbr=desiredPmax    new_value=35
    selenium_coam.set_parameter_value  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-2/NRCBSDCELL-0
    ...    filter_param=Desired maximum output power
    ...    abbr=desiredPmax    new_value=35
    selenium_coam.validate_plan
    ${hardware_errors}      selenium_coam.get_hardware_errors
    ${errors}=    catenate    SEPARATOR=    configured power limits are too high for the radio module - the sum [linear sum of CB
    ...    RS NRCELL: (maximum value of NRCELL/NRCBSDCELL.configSetForVariChBw.desiredPmax) where TX is used from this antenna]- [sum of relat
    ...    ed PASSDEV: additionalTxGain]+ [sum of related PASSDEV: additionalTxAttenuation] is outside of the supported range. PASSDEV.addition
    ...    alTxGain and PASSDEV.additionalTxAttenuation are only considered if LOGLINK.linkModeData=true
    ${antl_index_list}    create list    1    2    3    4
    FOR  ${index}  IN  @{antl_index_list}
        ${status}    get_errors_common_part    error_msg=${hardware_errors}  module=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-1/ANTL-${index}
        ...    msg=${errors}
        should be equal as strings  ${status}    True
    END
    [Teardown]    Selenium Logout And Close Browser

CB008498_14_config_PAL_grant_PAL+GAA
    Set cbrsFreqPriority value    value=3rd priority
    Set cbrsFreqPriority value    value=2nd priority    cellid=2
    Sleep    60s
    start SAS server    config_name=${CB008498_14_conf}
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    ${grant_info_coam_cell1}    Get Grant Parameters By Coam
    Should be True    '${grant_info_coam_cell1}[grantChannelType]'=='GAA'
	${grant_info_coam_cell2}    Get Grant Parameters By Coam    cellID=2
    Should be True    '${grant_info_coam_cell2}[grantChannelType]'=='PAL'
    Wait Until Keyword Succeeds    10min    10s    Check Case CB008498 14 CBRS Process    groupId_need=${False}    groupType_need=${False}

Check Case CB008498 14 CBRS Process
    [Arguments]    ${groupId_need}=${True}    ${groupType_need}=${True}    ${NRCBSDID}=1    ${ru_index}=1
    Get Correct Register Parameters Value By Coam    groupId_need=${groupId_need}    groupType_need=${groupType_need}
    ...    NRCBSDID=${NRCBSDID}    ru_index=${ru_index}
    ${cbsdId}    Get From Dictionary    dictionary=${cbsdIds}    key=${NRCBSDID}
    Set test variable    ${cbsdId}
    ${Resp}    Set variable    {\"grantResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*"responseCode": 0.*"responseCode": 0.*
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag=${register_info}
    Check if message is found in saslog    tag={\"registrationResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag=${Resp}
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    [Teardown]    end_to_check

Check Case CB008498 7 CBRS Process
    [Arguments]    ${groupId_need}=${True}    ${groupType_need}=${True}    ${NRCBSDID}=1    ${ru_index}=1
    Get Correct Register Parameters Value By Coam    groupId_need=${groupId_need}    groupType_need=${groupType_need}
    ...    NRCBSDID=${NRCBSDID}    ru_index=${ru_index}
    ${cbsdId}    Get From Dictionary    dictionary=${cbsdIds}    key=${NRCBSDID}
    Set test variable    ${cbsdId}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag=${register_info}
    Check if message is found in saslog    tag={\"registrationResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*"responseCode": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    [Teardown]    end_to_check

General_SiSo_Auto_E2E_system_setup_with_data_transfer_conducted_2CC_AZQC
    start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    CBRS make 2cc call    tput_expect=${tput_define}    attach_1=${attach_cell1}    attach_2=${attach_cell2}
    ...    target_avg=0.95    min_percent=0.85

CB008468_General_SiSo_Cell_block_and_unblock_2CC_AZQC
    start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    ${grant_info_cell1_old}    Get Grant Parameters By Coam
    ${grant_info_cell2_old}    Get Grant Parameters By Coam    cellID=2
    Selenium Login And Disable Screen Lock
    Get X2 link shutdown waiting time
    ${block_list}    Create List    1
    Block cells and check status    block_list=${block_list}   check_alarm=${False}    gnb_type='${gNb_CuType}'
    ${grant_info_cell1_new}    Get Grant Parameters By Coam
    ${grant_info_cell2_new}    Get Grant Parameters By Coam    cellID=2
    Should be True    '${grant_info_cell1_old}[grantId]'=='${grant_info_cell1_new}[grantId]'
    Should be True    '${grant_info_cell2_old}[grantId]'=='${grant_info_cell2_new}[grantId]'
    Sleep    180s
    ${grant_info_cell1_new}    Get Grant Parameters By Coam
    ${grant_info_cell2_new}    Get Grant Parameters By Coam    cellID=2
    Should be True    '${grant_info_cell1_old}[grantId]'=='${grant_info_cell1_new}[grantId]'
    Should be True    '${grant_info_cell2_old}[grantId]'=='${grant_info_cell2_new}[grantId]'
    Sleep    120s
    ${grant_info_cell1_new}    Get Grant Parameters By Coam
    ${grant_info_cell2_new}    Get Grant Parameters By Coam    cellID=2
    Should be True    '${grant_info_cell2_old}[grantId]'=='${grant_info_cell2_new}[grantId]'
    Should be True    '${grant_info_cell1_new}[grantId]'=='None'
    UnBlock Cells and check status    block_list=${block_list}   check_alarm=${False}    gnb_type='${gNb_CuType}'
    ${grant_info_cell1_new}    Get Grant Parameters By Coam
    ${grant_info_cell2_new}    Get Grant Parameters By Coam    cellID=2
    Should be True    '${grant_info_cell1_new}[grantId]'!='None'
    Should be True    '${grant_info_cell2_old}[grantId]'=='${grant_info_cell2_new}[grantId]'
    Wait Until Keyword Succeeds    2min    10s    Check Cell block and unblock CBRS Process    groupId_need=${False}    groupType_need=${False}
    reboot_asky_or_cpe_ue    ue_index=${0}
    reboot_asky_or_cpe_ue    ue_index=${1}
    Sleep    120s
    L3Call_And_Check_TPUT_2Cells    target_avg_percent=0.2    min_percent=0.2
    [Teardown]    Selenium Logout And Close Browser

Check Cell block and unblock CBRS Process
    [Arguments]    ${groupId_need}=${True}    ${groupType_need}=${True}    ${NRCBSDID}=1    ${ru_index}=1
    Get Correct Register Parameters Value By Coam    groupId_need=${groupId_need}    groupType_need=${groupType_need}
    ...    NRCBSDID=${NRCBSDID}    ru_index=${ru_index}
    ${cbsdId}    Get From Dictionary    dictionary=${cbsdIds}    key=${NRCBSDID}
    Set test variable    ${cbsdId}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag=${register_info}
    Check if message is found in saslog    tag={\"registrationResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*"responseCode": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*
    Check if message is found in saslog    tag={\"relinquishmentResponse\":.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*"responseCode": 0.*
    [Teardown]    end_to_check

CB008468_General_SiSo_RU_lock_unlock_AZQC
    ${SCF_10M}    Replace String    ${Golden_SCF_Path}    SCF_     SCF_CB008498_10M_
    Commissioning SCF And Check RU On Air    scf_file_path=${SCF_10M}
    Activate feature CBRS By Coam    actCbrsEnhMeas=${True}
    start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Selenium Login And Disable Screen Lock
    ${ru_index_list}    Get All RU Index
    ${cell_list}    Get All Cell Id
    sort list    ${cell_list}
    run keyword and continue on failure    Lock all RUs and check all status in AZQC    ru_index_list=${ru_index_list}
    UnLock all RUs and check all status in AZQC    ru_index_list=${ru_index_list}
    Sleep    60s
    ${release}    Get program version based on gNB active version
    Run Keyword If   "${release}"=="SBTS23R3"    Set PA Value For Pointed Port    PA_Port_List=${PA_OUT_PORTS_10M}    value=${10}
    ...    ELSE    Set PA Value For Pointed Port    PA_Port_List=${PA_OUT_PORTS_10M}    value=${3}
    coam.perform_delta_recommissioning    delta_file=${attach_cell1}    connection=GNB_OAM
    Sleep    60s
    data_transfer_common    tput_self_define=${tput_define_10M}    cell_id=${cell_id1}   loop_times=${1}    duration=${300}
    ...    target_avg_percent=0.98    min_percent=0.85    tput_from=self_define
    [Teardown]    Run keywords  Set PA Value For Pointed Port    PA_Port_List=${PA_OUT_PORTS_10M}    value=${3}    AND
    ...    Selenium Logout And Close Browser

CB008498_7_two_cell_different_priority_only_20MHz_available
    Set cbrsFreqPriority value    value=2nd priority
    Set cbrsFreqPriority value    value=3rd priority    cellid=2
    ${stamp_case_start}    Get Timestamp For Current Time
    Sleep    60s
    start SAS server    config_name=${CB008498_7_conf}
    Wait until keyword succeeds    5min    30s    Check cell status
    Wait until keyword succeeds    5min    30s    Check cell status	   cell_idx=${2}   cell_group_idx=${1}   cellflag=${False}
    Wait Until Keyword Succeeds    2min    10s    Check Case CB008498 7 CBRS Process    groupId_need=${False}    groupType_need=${False}
    Wait Until Keyword Succeeds    2min    5s    Check Alarm in Alarm List    type=Active    faultId=6828
    ...    stamp_case_start=${stamp_case_start}    Supplementary=No available frequency.    expect=${True}

Check Case CB008498 12 And 19 CBRS Process
    [Arguments]    ${groupId_need}=${True}    ${groupType_need}=${True}    ${NRCBSDID}=1    ${ru_index}=1
    Get Correct Register Parameters Value By Coam    groupId_need=${groupId_need}    groupType_need=${groupType_need}
    ...    NRCBSDID=${NRCBSDID}    ru_index=${ru_index}
    ${cbsdId}    Get From Dictionary    dictionary=${cbsdIds}    key=${NRCBSDID}
    Set test variable    ${cbsdId}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag=${register_info}
    Check if message is found in saslog    tag={\"registrationResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*"responseCode": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*
    Check if message is found in saslog    tag={\"relinquishmentResponse\":.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*"responseCode": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    [Teardown]    end_to_check

Check Case CB008498 20 CBRS Process
    [Arguments]    ${groupId_need}=${True}    ${groupType_need}=${True}    ${NRCBSDID}=1    ${ru_index}=1
    Get Correct Register Parameters Value By Coam    groupId_need=${groupId_need}    groupType_need=${groupType_need}
    ...    NRCBSDID=${NRCBSDID}    ru_index=${ru_index}
    ${cbsdId}    Get From Dictionary    dictionary=${cbsdIds}    key=${NRCBSDID}
    Set test variable    ${cbsdId}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag=${register_info}
    Check if message is found in saslog    tag={\"registrationResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*"responseCode": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*
    Check if message is found in saslog    tag={\"relinquishmentResponse\":.*
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*
    Check if message is found in saslog    tag={\"relinquishmentResponse\":.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*"responseCode": 0.*
    [Teardown]    end_to_check

CB008498_12_Online_change_cell_priority_higher_than_onair_one
    Set cbrsFreqPriority value    value=2nd priority
    Set cbrsFreqPriority value    value=3rd priority    cellid=2
    ${stamp_case_start}    Get Timestamp For Current Time
    start SAS server    config_name=${CB008498_12_conf}
    Wait until keyword succeeds    5min    30s    Check cell status
    Wait until keyword succeeds    5min    30s    Check cell status	   cell_idx=${2}   cell_group_idx=${1}   cellflag=${False}
    Wait Until Keyword Succeeds    2min    5s    Check Alarm in Alarm List    type=Active    faultId=6828
    ...    stamp_case_start=${stamp_case_start}    Supplementary=No available frequency.    expect=${True}
    Set cbrsFreqPriority value    value=top priority    cellid=2
    Wait until keyword succeeds    5min    30s    Check cell status    cellflag=${False}
    Wait until keyword succeeds    5min    30s    Check cell status	   cell_idx=${2}   cell_group_idx=${1}
    Wait Until Keyword Succeeds    2min    5s    Check Alarm in Alarm List    type=Active    faultId=6828
    ...    stamp_case_start=${stamp_case_start}    Supplementary=No available frequency.    expect=${True}
    Wait Until Keyword Succeeds    2min    10s    Check Case CB008498 12 And 19 CBRS Process    groupId_need=${False}    groupType_need=${False}
    Set qRxLevMin value    value=${-22}    cellid=1
    Set qRxLevMin value    value=${-40}    cellid=2
	data_transfer_common    tput_self_define=${tput_define}    cell_id=${cell_id2}   loop_times=${1}    duration=${120}
    ...    target_avg_percent=0.2    min_percent=0.2

CB008498_19_General_SiSo_online_add_one_higher_priority_CBRS_cell_20MHz_available
    ${SCF_new}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CB008498_19_config_
    COAM Commission with scf file    scf_file_path=${SCF_new}    timeout=600    is_pdl_checking_needed=${if_pdl_check}
    Sleep    300s
    Activate feature CBRS By Coam
    Sleep    60s
    ${stamp_case_start}    Get Timestamp For Current Time
    start SAS server    config_name=${CB008498_19_conf}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Check Register Success Message    groupId_need=${False}    groupType_need=${False}
    Online Cell addition    file_path=${Golden_SCF_Path}
    Sleep    60s
    Wait until keyword succeeds    5min    30s    Check cell status
    Wait until keyword succeeds    5min    30s    Check cell status	   cell_idx=${2}   cell_group_idx=${1}   cellflag=${False}
    Wait Until Keyword Succeeds    2min    5s    Check Alarm in Alarm List    type=Active    faultId=6828
    ...    stamp_case_start=${stamp_case_start}    Supplementary=No available frequency.    expect=${True}
    Set cbrsFreqPriority value    value=2nd priority    cellid=2
    Wait until keyword succeeds    5min    30s    Check cell status    cellflag=${False}
    Wait until keyword succeeds    5min    30s    Check cell status	   cell_idx=${2}   cell_group_idx=${1}
    Wait Until Keyword Succeeds    2min    5s    Check Alarm in Alarm List    type=Active    faultId=6828
    ...    stamp_case_start=${stamp_case_start}    Supplementary=No available frequency.    expect=${True}
    Wait Until Keyword Succeeds    2min    10s    Check Case CB008498 12 And 19 CBRS Process    groupId_need=${False}    groupType_need=${False}
    reboot_asky_or_cpe_ue    ue_index=${1}
    Sleep    120s
    Set qRxLevMin value    value=${-22}    cellid=1
    Set qRxLevMin value    value=${-40}    cellid=2
    UE attach and start traffic    ue_index=${1}    dl_tp=${tput['dl_send']}     ul_tp=${tput['ul_send']}
    log to console    \n***Start Collect Throughput***
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${1}
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${20}
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity
    ${cell_id2}    Convert To String    ${cell_mapping[2]['nrCellIdentity']}
    ${cell_id2}    Create List    ${cell_id2}
    log to console    \n***Start Check Throughput***
    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${tput_log}    cells=${cell_id2}    ultarget_throughput=${tput['ul_exp_tp']}
    ...    dltarget_throughput=${tput['dl_exp_tp']}    target_avg_percent=0.2    min_percent=0.2
   [Teardown]    Stop Single UE L3 Call    ue_index=${1}

CB008498_20_General_SiSo_delete_one_CBRS_cell
    Set cbrsFreqPriority value    value=2nd priority
    Set cbrsFreqPriority value    value=3rd priority    cellid=2
    Set qRxLevMin value    value=${-40}    cellid=2
    Sleep    60s
    start SAS server    config_name=${CB008498_20_conf}
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    ${grant_info_coam_cell1}    Get Grant Parameters By Coam
    Should be True    '${grant_info_coam_cell1}[grantChannelType]'=='PAL'
	${grant_info_coam_cell2}    Get Grant Parameters By Coam    cellID=2
    Should be True    '${grant_info_coam_cell2}[grantChannelType]'=='GAA'
    Online Cell deletion
    Sleep    60s
    Wait until keyword succeeds    3min    30s    verify all cells should be onair
    ${grant_info_coam_cell2}    Get Grant Parameters By Coam    cellID=2
    Should be True    '${grant_info_coam_cell2}[grantChannelType]'=='PAL'
    Wait Until Keyword Succeeds    2min    10s    Check Case CB008498 20 CBRS Process    groupId_need=${False}    groupType_need=${False}
    reboot_asky_or_cpe_ue    ue_index=${1}
    Sleep    120s
    UE attach and start traffic    ue_index=${1}    dl_tp=${tput['dl_send']}     ul_tp=${tput['ul_send']}
    log to console    \n***Start Collect Throughput***
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${1}
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${20}
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity
    ${cell_id2}    Convert To String    ${cell_mapping[2]['nrCellIdentity']}
    ${cell_id2}    Create List    ${cell_id2}
    log to console    \n***Start Check Throughput***
    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${tput_log}    cells=${cell_id2}    ultarget_throughput=${tput['ul_exp_tp']}
    ...    dltarget_throughput=${tput['dl_exp_tp']}    target_avg_percent=0.2    min_percent=0.2
   [Teardown]    Stop Single UE L3 Call    ue_index=${1}

Get the diff between two number
    [Arguments]  ${number1}    ${number2}
    ${diff}=   Run Keyword If    ${number1}>${number2}
	...    Evaluate    ${number1}-${number2}
    ...    ELSE    Evaluate    ${number2}-${number1}
    [Return]    ${diff}

CB008498_21_continue_channel_CA_channelSpace2020_is_20MHz
    ${SCF_new}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CA_
    COAM Commission with scf file    scf_file_path=${SCF_new}    timeout=600    is_pdl_checking_needed=${if_pdl_check}
    Sleep    300s
    start SAS server    config_name=${CB008498_21_conf}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Selenium Login And Disable Screen Lock
    ${carrier_freq_cell1}    Get cell carrier freq
    ${carrier_freq_cell2}    Get cell carrier freq    cell_idx=${2}
    ${distance}    Get the diff between two number    number1=${carrier_freq_cell1}    number2=${carrier_freq_cell2}
    ${diff}    Get the diff between two number    number1=${distance}    number2=${19.98}
    Should be True    ${diff}<0.0001
    [Teardown]    Selenium Logout And Close Browser

CB008498_27_continue_channel_CA_enable_channelSpace2020_change_to_19.2MHz
    ${SCF_new}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CA_
    COAM Commission with scf file    scf_file_path=${SCF_new}    timeout=600    is_pdl_checking_needed=${if_pdl_check}
    Sleep    300s
    start SAS server    config_name=${CB008498_27_conf}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Selenium Login And Disable Screen Lock
    ${carrier_freq_cell1_before}    Get cell carrier freq
    ${carrier_freq_cell2_before}    Get cell carrier freq    cell_idx=${2}
    ${distance}    Get the diff between two number    number1=${carrier_freq_cell1_before}    number2=${carrier_freq_cell2_before}
    ${diff}    Get the diff between two number    number1=${distance}    number2=${19.98}
    Should be True    ${diff}<0.0001
    ${release}    Get program version based on gNB active version
    ${flitervalue}=   Run Keyword If   "${release}"=="SBTS22R4"
    ...     Set Variable     Channel space between contiguous 20MHz spectrums
    ...     ELSE    Set Variable       Channel spacing between two cells
    ${value}=   Run Keyword If   "${release}"=="SBTS22R4"
    ...     Set Variable     19.2MHz
    ...     ELSE    Set Variable       19200
    Set channelSpace2020 By webem    channelSpace2020=${value}    flitervalue_channelSpace2020=${flitervalue}
    Sleep    100s
    ${carrier_freq_cell1_after}    Get cell carrier freq
    ${Pcell_shift}    Get the diff between two number    number1=${carrier_freq_cell1_before}    number2=${carrier_freq_cell1_after}
    run keyword if  not "${release}"=="master"    Should be True    ${Pcell_shift}<0.000001
    ${carrier_freq_cell2_after}    Get cell carrier freq    cell_idx=${2}
    run keyword if  not "${release}"=="master"    Should be True    ${carrier_freq_cell2_after}!=${carrier_freq_cell2_before}
    ${distance}    Get the diff between two number    number1=${carrier_freq_cell1_after}    number2=${carrier_freq_cell2_after}
    ${diff}    Get the diff between two number    number1=${distance}    number2=${19.2}
	Should be True    ${diff}<0.0001
    [Teardown]    Selenium Logout And Close Browser

CB008498_30_contiguous_CA_have_higher_priority
    ${SCF_new}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CA_
    COAM Commission with scf file    scf_file_path=${SCF_new}    timeout=600    is_pdl_checking_needed=${if_pdl_check}
    Sleep    300s
    Selenium Login And Disable Screen Lock
    ${is_startup_window_exist}    selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${release}    Get program version based on gNB active version
    ${flitervalue}=   Run Keyword If   "${release}"=="SBTS22R4"
    ...     Set Variable     Channel space between contiguous 20MHz spectrums
    ...     ELSE    Set Variable       Channel spacing between two cells
    ${value}=   Run Keyword If   "${release}"=="SBTS22R4"
    ...     Set Variable     19.2MHz
    ...     ELSE    Set Variable       19200
    Set channelSpace2020 By webem    channelSpace2020=${value}    flitervalue_channelSpace2020=${flitervalue}
    Sleep    60s
    start SAS server    config_name=${CB008498_30_conf}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    ${grant_info_cell1}    Get Grant Parameters By Coam
    ${grant_info_cell2}    Get Grant Parameters By Coam    cellID=2
    ${status}  run keyword and return status    Run Keyword If    '${grant_info_cell1}[grantId]'=='3610000000_3630000000'
    ...    Should be True    '${grant_info_cell2}[grantId]'=='3630000000_3650000000'
    ...    ELSE    Run Keyword If    '${grant_info_cell1}[grantId]'=='3630000000_3650000000'
    ...    Should be True    '${grant_info_cell2}[grantId]'=='3610000000_3630000000'
    Should be True    ${status} == True
    [Teardown]    Selenium Logout And Close Browser
