*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    ../../../resources/cbrs_common_keywords.robot
Variables    ../TestData/9154-C_variables.py

Documentation    This is for SG8 common keywords
...              Author: wangqingqing
...              Squard: HZ SG8

*** Variables ***
${conf_path}    ${CURDIR}/conf
${CB009154_26_conf}    ${conf_path}/CB009154_26.conf
${CB009154_17_conf}    ${conf_path}/CB009154_17.conf
${CB009154_19_conf}    ${conf_path}/CB009154_19.conf
${CB009154-C_json_path}    ${CURDIR}/json
${disable_actcbrs}    ${CB009154-C_json_path}/disable_actcbrs.json
${enable_actcbrs}    ${CB009154-C_json_path}/enable_actcbrs.json
${modify_prioty_26}    ${CB009154-C_json_path}/modify_prioty_26.json
${modify_two_cell_prioty_26}    ${CB009154-C_json_path}/modify_two_cell_prioty_26.json
*** Keywords ***
Case Preparation
    ${mrbtsID_enb}    ${lnbtsID}    Get mrbtsID and lnbtsID via SCF for eNB    scf_path=${Golden_SCF_Path}
    log to console  ENB_MRBTS_ID:${mrbtsID_enb}, LNBTS_ID:${lnbtsID}
    set suite variable  ${mrbtsID_enb}
    set suite variable  ${lnbtsID}
    &{fault_6826}     Create Dictionary     faultId=${6826}
    &{fault_7312}     Create Dictionary     faultId=${7312}
    ${ALLOWED_FAULT}   Create List   @{ALLOWED_FAULT}   ${fault_6826}    ${fault_7312}
    set suite variable  ${ALLOWED_FAULT}
    ${SCF_1NRcell_2LTEcell}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_1NRcell_2LTEcell_
    set suite variable  ${SCF_1NRcell_2LTEcell}
    ${SCF_2NRcell_2LTEcell}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_2NRcell_2LTEcell_
    set suite variable  ${SCF_2NRcell_2LTEcell}

CB009154-C CBRS Test Setup
    [Arguments]    ${enable_delta_file}=${enable_actcbrs}
    CBRS Test Setup
    coam.perform_delta_recommissioning    delta_file=${enable_delta_file}    connection=GNB_OAM
    Sleep    60s

CB009154-C CBRS Test Teardown
    [Arguments]    ${disable_delta_file}=${disable_actcbrs}
    coam.perform_delta_recommissioning    delta_file=${disable_delta_file}    connection=GNB_OAM
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be disabled    connection=GNB_OAM
    CBRS Test Teardown

Check CB009154-C Relinquish Message
    [Arguments]    ${cbsdid}    ${grantId}
    ${info}    Set variable    {\"relinquishmentResponse\":.*\"cbsdId\": \"${cbsdid}\".*\"grantId\": \"${grantId}\".*\"responseCode\": 0.*
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*\"cbsdId\":\"${cbsdid}\".*\"grantId\":\"${grantId}\"}]}
    Check if message is found in saslog    tag=${info}
    [Teardown]    end_to_check

HB terminat for first Grant
    [Arguments]     ${cbsdid}    ${grantId}
    prepare_to_check_message_from_start
    Check if message is found in saslog
    ...    tag={"heartbeatResponse":.*"cbsdId": "${cbsdid}".*"grantId": "${grantId}".*"responseCode": 500.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    [Teardown]    end_to_check

Import SCF and Enable CBRS
    [Arguments]    ${file_path}
    COAM Commission with scf file    scf_file_path=${file_path}    timeout=600    is_pdl_checking_needed=${if_pdl_check}
    Sleep    400s
    Activate feature CBRS By Coam
    Sleep    30s
    coam.perform_delta_recommissioning    delta_file=${enable_actcbrs}    connection=GNB_OAM
    Sleep    30s

CB009154-C_9_CBSD_behavior_check_when_BBMOD_reset
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

CB009154-C_8_CBSD_behavior_check_when_SBTS_reset
    start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    ${grant_info_nr_old}    Get Grant Parameters By Coam
    ${grantId_lte_old}    Get Parameter value via COAM    class_name=CBSDCEL_R    pattern=grantId    connection=GNB_OAM
    coam.reset_site   connection=GNB_OAM
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    ${grant_info_nr_new}    Get Grant Parameters By Coam
    ${grantId_lte_new}    Get Parameter value via COAM    class_name=CBSDCEL_R    pattern=grantId    connection=GNB_OAM
    Should be True    '${grant_info_nr_new}[grantId]'=='${grant_info_nr_old}[grantId]'
    Should be True    '${grantId_lte_new}'=='${grantId_lte_old}'

CB009154-C_13_online_add_NR_cell_under_RFS
    Import SCF and Enable CBRS    file_path=${SCF_1NRcell_2LTEcell}
    start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    Online Cell addition    file_path=${SCF_2NRcell_2LTEcell}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Verify all lte cells should be onair    connection=GNB_OAM
    Deactivate feature CBRS By Coam
    Sleep    10s
    Connect to gnb coam via ssl
    Wait until keyword succeeds    5min    30s    Verify all cells should be disabled
    Verify all lte cells should be onair    connection=GNB_OAM
    ${register_status}  run keyword and return status  wait until keyword succeeds    2min    30s    Check Register Status By Coam
    Should be True    ${register_status} == False
    Check GrantOperationState Status Success    Status=Idle
    Check GrantOperationState Status Success    cellID=2    Status=Idle
    ${nrcbsdid}    Get Parameter value via COAM    class_name=NRCBSD_R    pattern=assignedCbsdId    connection=GNB_OAM
    ${ltecbsdid}    Get Parameter value via COAM    class_name=CBSD_R   pattern=assignedCbsdId    connection=GNB_OAM
    Check No relinquishmentRequest procedure    cbsdid=${nrcbsdid}
    Check No relinquishmentRequest procedure    cbsdid=${ltecbsdid}

CB009154-C_26_CBSD_behavior_check_when_modify cbrsFreqPriority
    ${cell_id_list}  Get All Cell Id
    ${cell_num}    get length  ${cell_id_list}
    Run Keyword If    ${cell_num}!=2    Import SCF and Enable CBRS    file_path=${SCF_2NRcell_2LTEcell}
    coam.perform_delta_recommissioning    delta_file=${modify_prioty_26}    connection=GNB_OAM
    Sleep    10s
    start SAS server    config_name=${CB009154_26_conf}
    Sleep    480s
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    ${release}    Get program version based on gNB active version
    ${nrcell1_grantchanneltype}    Get NRCBSDCELL_R value via COAM    pattern=grantChannelType
    Should be True    '${nrcell1_grantchanneltype}'=='PAL'
    ${nrcell2_grantchanneltype}    Get NRCBSDCELL_R value via COAM    cellID=2    pattern=grantChannelType
    Should be True    '${nrcell2_grantchanneltype}'=='PAL'
	${ltecell11_grantchanneltype}    Get CBSDCEL_R value via COAM    cellID=11    pattern=grantChannelType
    Should be True    '${ltecell11_grantchanneltype}'=='GAA'
    ${ltecell12_grantchanneltype}    Get CBSDCEL_R value via COAM    cellID=12    pattern=grantChannelType
    Should be True    '${ltecell12_grantchanneltype}'=='GAA'
    ${nrcell1_grantid}    Run Keyword If   "${release}"=="SBTS24R1" or "${release}"=="SBTS23R4"
    ...    Get NRCBSDCELL_R value via COAM    pattern=grantId
	...    ELSE    Get subGrantInfo Item by Coam    pattern=grantIdSub
    ${ltecell11_grantid}    Get CBSDCEL_R value via COAM    cellID=11    pattern=grantId
    Sleep    10s
    coam.perform_delta_recommissioning    delta_file=${modify_two_cell_prioty_26}    connection=GNB_OAM
    Sleep    400s
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    ${nrcell1_grantchanneltype}    Get NRCBSDCELL_R value via COAM    pattern=grantChannelType
    Should be True    '${nrcell1_grantchanneltype}'=='GAA'
    ${ltecell11_grantchanneltype}    Get CBSDCEL_R value via COAM    cellID=11    pattern=grantChannelType
    Should be True    '${ltecell11_grantchanneltype}'=='PAL'
    ${nrcbsdid}    Get Parameter value via COAM    class_name=NRCBSD_R    pattern=assignedCbsdId    connection=GNB_OAM
    ${ltecbsdid}    Get Parameter value via COAM    class_name=CBSD_R   pattern=assignedCbsdId    connection=GNB_OAM
    Check CB009154-C Relinquish Message    cbsdid=${nrcbsdid}    grantId=${nrcell1_grantid}
    Check CB009154-C Relinquish Message    cbsdid=${ltecbsdid}    grantId=${ltecell11_grantid}

CB009154-C_17_verify_NR_preempt_LTE_grant
    COAM Commission with scf file    scf_file_path=${SCF_2NRcell_2LTEcell}    timeout=600    is_pdl_checking_needed=${if_pdl_check}
    Sleep    400s
    Set Frequency Channel Value By Coam    frequency_channel=${frequency_3550_3590}
    Sleep    60s
    Modify the parameter on NR    dist_name=MRBTS-${mrbtsID_enb}/LNBTS-${lnbtsID}/CBSD-1
    ...    parameter_name=supportedSpectrumV2    value=${frequency_3570_3610}
    Sleep    30s
    coam.perform_delta_recommissioning    delta_file=${modify_prioty_26}    connection=GNB_OAM
    Sleep    60s
    coam.perform_delta_recommissioning    delta_file=${enable_actcbrs}    connection=GNB_OAM
    ${release}    Get program version based on gNB active version
    start SAS server    config_name=${CB009154_17_conf}
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    ${ltecell11_grantid}    Get CBSDCEL_R value via COAM    cellID=11    pattern=grantId
    Should be True    '${ltecell11_grantid}'=='3570000000_3590000000'
    ${ltecell12_grantid}    Get CBSDCEL_R value via COAM    cellID=12    pattern=grantId
    Should be True    '${ltecell12_grantid}'=='3590000000_3610000000'
    ${stamp_case_start}    Get Timestamp For Current Time
    Activate feature CBRS By Coam
    Wait until keyword succeeds    5min    30s    Check cell status 
    Wait until keyword succeeds    2min    30s    Check cell status	   cell_idx=${2}   cell_group_idx=${1}   cellflag=${False}
    Check Alarm in Alarm List    type=Active    faultId=6828
    ...    stamp_case_start=${stamp_case_start}    Supplementary=No available frequency.    expect=${True}
    Sleep    360s
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    ${nrcell2_grantid}    Run Keyword If   "${release}"=="SBTS24R1" or "${release}"=="SBTS23R4"
    ...    Get NRCBSDCELL_R value via COAM    cellID=2    pattern=grantId
    ...    ELSE    Get subGrantInfo Item by Coam    pattern=grantIdSub    cellID=2
    Should be True    '${nrcell2_grantid}'=='3570000000_3590000000'
    Sleep    60s
    ${cells_info}   coam.get_cells_info  cell_type=lte    timeout=20    connection=GNB_OAM
    Run Keyword If    ${cells_info[${0}]['physicalCellId']} == 13
    ...    Verify lte cell should be onair    connection=GNB_OAM
    ...     ELSE     Verify lte cell should be onair    cell_index=${1}    connection=GNB_OAM
    ${ltecell11_grantid}    Get CBSDCEL_R value via COAM    cellID=11    pattern=grantId
    Should be True    '${ltecell11_grantid}'=='3590000000_3610000000'
    Run Keyword If    ${cells_info[${0}]['physicalCellId']} == 13
    ...    Verify lte cell should be disabled    cell_index=${1}    connection=GNB_OAM
    ...     ELSE     Verify lte cell should be disabled    connection=GNB_OAM
    Check Alarm in Alarm List    type=Active    faultId=6828
    ...    stamp_case_start=${stamp_case_start}    Supplementary=No available frequency.    expect=${True}
    Sleep    60s
    Change NR CBRS Flag By Coam    actNrCbrs=false
    Sleep    180s

CB009154-C_19_verify_the_behavior_when_NR_grant_terminated
    Set Frequency Channel Value By Coam    frequency_channel=${frequency_3550_3570}
    Sleep    60s
    Modify the parameter on NR    dist_name=MRBTS-${mrbtsID_enb}/LNBTS-${lnbtsID}/CBSD-1
    ...    parameter_name=supportedSpectrumV2    value=${frequency_3570_3590}
    Sleep    30s
    ${release}    Get program version based on gNB active version
    start SAS server    config_name=${CB009154_19_conf}
    Wait until keyword succeeds    8min    30s    verify all cells should be onair
    Wait until keyword succeeds    8min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    ${nrcbsdid}    Get Parameter value via COAM    class_name=NRCBSD_R    pattern=assignedCbsdId    connection=GNB_OAM
    ${nrcell_grantid}    Run Keyword If   "${release}"=="SBTS24R1" or "${release}"=="SBTS23R4"
    ...    Get NRCBSDCELL_R value via COAM    pattern=grantId
	...    ELSE    Get subGrantInfo Item by Coam    pattern=grantIdSub
    HB terminat for first Grant    cbsdid=${nrcbsdid}    grantId=${nrcell_grantid}
    Sleep    30s

CB009154-C_24_online_modify_supportedSpectrumV2_Volatile_MO_released
    Set Frequency Channel Value By Coam    frequency_channel=${frequency_3550_3590}
    Sleep    30s
    Modify the parameter on NR    dist_name=MRBTS-${mrbtsID_enb}/LNBTS-${lnbtsID}/CBSD-1
    ...    parameter_name=supportedSpectrumV2    value=${frequency_3550_3570}
    Sleep    30s
    Set cbrsFreqPriority value    value=2nd priority
    Modify the parameter on NR    dist_name=MRBTS-${mrbtsID_enb}/LNBTS-${lnbtsID}/LNCEL-11/CBSDCEL-0
    ...    parameter_name=cbrsFreqPriority    value=3rd priority
    coam.perform_delta_recommissioning    delta_file=${disable_actcbrs}    connection=GNB_OAM
    Sleep    60s
    ${stamp_case_start}    Get Timestamp For Current Time
    start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Sleep    120s
	Verify all lte cells should be disabled    connection=GNB_OAM
    coam.perform_delta_recommissioning    delta_file=${enable_actcbrs}    connection=GNB_OAM
    Wait Until Keyword Succeeds    5min    5s    Check Alarm in Alarm List    type=Active    faultId=6827
    ...    stamp_case_start=${stamp_case_start}    Supplementary=No available frequency.    expect=${True}
    Verify all lte cells should be disabled    connection=GNB_OAM
    ${grant_info_nr_old}    Get Grant Parameters By Coam
    Should be True    '${grant_info_nr_old}[grantId]'=='3550000000_3570000000'
    Set Frequency Channel Value By Coam    frequency_channel=${frequency_3570_3590}
    Sleep    60s
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    ${grant_info_nr}    Get Grant Parameters By Coam
    Should be True    '${grant_info_nr}[grantId]'=='3570000000_3590000000'
    Check relinquishment Success Message    grantId=${grant_info_nr_old}[grantId]
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    ${grantId_lte}    Get Parameter value via COAM    class_name=CBSDCEL_R    pattern=grantId    connection=GNB_OAM
    Should be True    '${grantId_lte}'=='3550000000_3570000000'