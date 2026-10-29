*** Settings ***
Documentation   this is RIMRS common keywords
Library        ./lib/string_list.py
Library        ./lib/get_bts_info.py

*** Variables ***
${OAM_ALIAS_GNB0}                     GNB_OAM
${OAM_ALIAS_GNB1}                     GNB_OAM_GNB1
${ASIK_ALIAS_GNB0}                    ASIK Master
${ASIK_ALIAS_GNB1}                    ASIK Master GNB1

${RS_TRANS_TRIGGER}    RI trigger
${RS_TRANS_TRIGGER_AGGRESSOR}    constantly trigger
${DL_MUTE_SLOTS_SPECIAL}     special slot
${DL_MUTE_SLOTS_SPECIAL_PRECEDING}    special slot plus the preceding slot
${DL_MUTE_SLOTS_SPECIAL_2PRECEDING}    special slot plus two preceding slots
${DL_MUTE_SLOTS_1st_PRECEDING}    preceding slot
${MITIGATION_SCHEME_DL_UL}    UL and DL mitigation
${MITIGATION_SCHEME_DL_ONLY}    DL mitigation only
${MITIGATION_SCHEME_UL_ONLY}    UL mitigation only
${MITIGATION_SCHEME_NO_MITIGATION}    no mitigation

#for CM
${ASYMMETRIC}     asymmetric state detected
${NOT_ASYMMETRIC}     no asymmetric
${NO_RI}     no RI
${RI_DETECTED}     	RI detected
${NO_MUTING}     no muting
${S_MUTING}     special slot muting
${1DL_S_MUTING}     1DL+special slot muting
${2DL_S_MUTING}     2DL+special slot muting
${1DL_MUTING}     1DL slot muting
${2DL_MUTING}     2DL slot muting

@{SPECIAL_SLOT_LIST_1116_0}    ${3}    ${13}
@{SPECIAL_SLOT_LIST_1116_3}    ${7}    ${17}
@{SPECIAL_SLOT_LIST_1208}    ${3}    ${8}    ${13}    ${18}
@{SPECIAL_SLOT_LIST_1070}    ${3}    ${7}    ${13}    ${17}
@{PRECED_DL_SLOT_LIST_1116_0}    ${2}    ${12}
@{PRECED_2DL_SLOT_LIST_1116_0}    ${1}    ${11}
@{PRECED_DL_SLOT_LIST_1116_3}    ${6}    ${16}
@{PRECED_DL_SLOT_LIST_1208}    ${2}    ${7}    ${12}    ${17}
@{PRECED_DL_SLOT_LIST_1070}    ${2}    ${6}    ${12}    ${16}
@{UL_SLOT_LIST_1116_0}    ${4}    ${5}   ${14}   ${15}
@{UL_SLOT_LIST_1116_3}    ${8}    ${9}   ${18}   ${19}
@{UL_SLOT_LIST_1208}    ${4}    ${9}    ${14}    ${19}
@{UL_SLOT_LIST_1070}    ${4}    ${8}    ${9}    ${14}    ${18}   ${19}

${NEAR_ONLY}    near only
${NEAR_FAR_1}    near-far config1
${NEAR_FAR_2}    near-far config2

#For PCMD rdRiMonitorInterval=1
@{RI_MONITOR_S_SLOT_LIST_1116_0}    ${3}
@{RI_MONITOR_S_SLOT_LIST_1116_3}    ${7}
@{RI_MONITOR_S_SLOT_LIST_1208}    ${3}    ${13}
@{RI_MONITOR_S_SLOT_LIST_1070}    ${7}

@{RI_MONITOR_UL_SLOT_LIST_1116_0}    ${4}    ${5}
@{RI_MONITOR_UL_SLOT_LIST_1116_3}    ${8}    ${9}
@{RI_MONITOR_UL_SLOT_LIST_1208}    ${4}    ${14}
@{RI_MONITOR_UL_SLOT_LIST_1070}    ${8}    ${9}

#For PCMD rdRiMonitorInterval=2 from 25R1 CNI-131193
@{RI_MONITOR_S_SLOT_LIST_1116_0_V2}    ${3}    ${13}
@{RI_MONITOR_S_SLOT_LIST_1116_3_V2}    ${7}
@{RI_MONITOR_S_SLOT_LIST_1208_V2}    ${3}    ${13}    ${8}    ${18}
@{RI_MONITOR_S_SLOT_LIST_1070_V2}    ${7}    ${17}

@{RI_MONITOR_UL_SLOT_LIST_1116_0_V2}    ${4}    ${5}    ${14}    ${15}
@{RI_MONITOR_UL_SLOT_LIST_1116_3_V2}    ${8}    ${9}    ${18}    ${19}
@{RI_MONITOR_UL_SLOT_LIST_1208_V2}    ${4}    ${14}    ${9}    ${19}
@{RI_MONITOR_UL_SLOT_LIST_1070_V2}    ${8}    ${9}    ${18}    ${19}

${NOT_ENOUGH}    0
${ENOUGH}    1
${FILTER_PCMD_RI}    (nsetapx.riSlopeMeasRecord == 0) && (nsetapx.ulDropHeightDataList)
${UL_SYMBOL_RI_LIST_XPATH}    .//nsetapx.ulSymbolRiDataList//..//nsetapx.UlSymbolRiDataItem_element//nsetapx.slotNumber
${UL_DROP_HEIGHT_LIST_XPATH}    .//nsetapx.ulDropHeightDataList//nsetapx.slotNumber
${FILTER_PCMD_RIMRS1_MONITOR}    nsetapx.rimRsMonitoringRecord == 0
${FILTER_PCMD_RIMRS1_MONITOR_FW1}    nsetapx.rimRsMonitoringRecord && nsetapx.rimRsType == 0
${FILTER_PCMD_RIMRS2_MONITOR_FW1}    nsetapx.rimRsMonitoringRecord && nsetapx.rimRsType == 1
${FILTER_PCMD_RIMRS_MONITOR_FW1}    nsetapx.rimRsMonitoringRecord && (nsetapx.rimRsType == 1 || nsetapx.rimRsType == 0)

${RIMRS_TYPE1_XPATH}      nsetapx.rimRsType[@showname=\'rimRsType: type1 (0)\']
${RIMRS_TYPE2_XPATH}      nsetapx.rimRsType[@showname=\'rimRsType: type2 (1)\']

${RIMRS_MONITOR_XPATH}    .//nsetapx.rimRsMonitoringRecord
${RIMRS_SETID_XPATH_MONITOR}    ${RIMRS_MONITOR_XPATH}//..//nsetapx.RimRsDataItem_element//nsetapx.rimRsSetId
${RIMRS_SETID_FW1_XPATH_MONITOR}    ${RIMRS_MONITOR_XPATH}//..//nsetapx.RimRsDataItem_r1_element//nsetapx.rimRsSetId
${RIMRS_MAX_POWER_XPATH_MONITOR}   .//nsetapx.rimRSMaxPowerLevelDatalList//..//nsetapx.RimRSMaxPowerLevelDatalItem_element//nsetapx.rimRSMaxPowerLevel
${RIMRS_AVG_POWER_XPATH_NEW_MONITOR}   ${RIMRS_MONITOR_XPATH}//..//nsetapx.RimRsMonitoringRepetitionItem_element//nsetapx.rimRsAvgPowerLevel
${RIMRS_REPET_XPATH_MONITOR}    ${RIMRS_MONITOR_XPATH}//..//nsetapx.RimRSMaxPowerLevelDatalItem_element//nsetapx.repetitionIndex
${RIMRS_REPET_XPATH_MONITOR_NEW}    ${RIMRS_MONITOR_XPATH}//..//nsetapx.RimRsMonitoringRepetitionItem_element//nsetapx.repetitionIndex
${RIMRS_NEARFAR_XPATH_MONITOR}    ${RIMRS_MONITOR_XPATH}//..//nsetapx.RimRsMonitoringRepetitionItem_element//nsetapx.rimRsNearFarIndicator
${RIMRS_PROPAGA_DELAY_XPATH_MONITOR}    ${RIMRS_MONITOR_XPATH}//..//nsetapx.RimRsDataItem_r1_element//nsetapx.propagationDelayInSymbol
${RIMRS_SETID_REMOVED_XPATH_MONITOR}    ${RIMRS_MONITOR_XPATH}//..//nsetapx.RimRsDataItem_r1_element//nsetapx.removed
${RIMRS_SETID_RESET_XPATH_MONITOR}    ${RIMRS_MONITOR_XPATH}//..//nsetapx.rimRsSetIdListReset

${RIMRS_TYPE1_ENOUGH_IND_XPATH_MONITOR}    ${RIMRS_MONITOR_XPATH}//..//${RIMRS_TYPE1_XPATH}//..//nsetapx.enoughIndicator
${RIMRS_TYPE2_ENOUGH_IND_XPATH_MONITOR}    ${RIMRS_MONITOR_XPATH}//..//${RIMRS_TYPE2_XPATH}//..//nsetapx.enoughIndicator
${RIMRS_TYPE1_ENOUGH_VERDIC_XPATH_MONITOR}    ${RIMRS_MONITOR_XPATH}//..//${RIMRS_TYPE1_XPATH}//..//nsetapx.enoughVerdict
${RIMRS_TYPE2_ENOUGH_VERDIC_XPATH_MONITOR}    ${RIMRS_MONITOR_XPATH}//..//${RIMRS_TYPE2_XPATH}//..//nsetapx.enoughVerdict

${FILTER_PCMD_RIMRS1_TRANSMIT_FW1}    nsetapx.rimRsTransmissionRecord && nsetapx.rimRsType == 0
${FILTER_PCMD_RIMRS2_TRANSMIT_FW1}    nsetapx.rimRsTransmissionRecord && nsetapx.rimRsType == 1
${RIMRS_TRANSMIT_XPATH}    .//nsetapx.rimRsTransmissionRecord
${RIMRS_REPET_XPATH_TRANSMIT}    ${RIMRS_TRANSMIT_XPATH}//..//nsetapx.RimRsTransmissionRepetitionItem_element//nsetapx.repetitionIndex
${RIMRS_TYPE1_ENOUGH_IND_XPATH_TRANSMIT}    ${RIMRS_TRANSMIT_XPATH}//..//${RIMRS_TYPE1_XPATH}//..//nsetapx.enoughIndicator
${RIMRS_TYPE2_ENOUGH_IND_XPATH_TRANSMIT}    ${RIMRS_TRANSMIT_XPATH}//..//${RIMRS_TYPE2_XPATH}//..//nsetapx.enoughIndicator

#0xe118: dldata_pdschsendreq
#0xe113: dldata_pdcchsendreq
#0xe24e: uldata_rimreceivereq
#0xe24f: uldata_rimreceiverespps
#0xe120: dldata_rimrssendreq
#0xe255: uldata_srsreceivereq
#0xe126: DlData_PdschPayloadTbSendReq/DlData_PdschPayloadTbSendReqL1sw
${MESSAGE_ID_PDSCH_SEND_REQ}    0xe118
${MESSAGE_ID_PDCCH_SEND_REQ}    0xe113
${MESSAGE_ID_PDSCH_PAYLOAD_REQ}    0xe126
${MESSAGE_ID_RIM_RECEIVE_REQ}    0xe24e
${MESSAGE_ID_RIM_RECEIVE_RSPS}    0xe24f
${MESSAGE_ID_RIM_SENT_REQ}    0xe120
${MESSAGE_ID_SRS_RECEIVE_REQ}    0xe255
${RIM_ALLOWED_FAULTS_IDS}    7525,7527,7535,7532
${ALL_SRS_FALSE_FILTER}    (UlData_srsReceiveReqSubcell_t.srsBmEnable == False) && (UlData_srsReceiveReqSubcell_t.srsBwvEnable == False)
...    && (UlData_srsReceiveReqSubcell_t.srsRtBfEnable == False)

*** Keywords ***
Rim suite common setup preparation
    [Documentation]    author: Wang Yixiang, mofified by catherine cheng to adapt cases to UTE CLOUD
    ...    move gnb commission to common case setup
    [Arguments]    ${ue_index}=${0}    ${prepare_ue}=${False}    ${detach_request}=${True}    ${ui_version}=default
    ...    &{kwargs}
    _CI Keyword run on GNB0    ue_index=${ue_index}
    run keyword if    ${prepare_ue}   UE preparation and restart UE Proxy if UE preparation fails    ue_index=${ue_index}
    ...    detach_request=${detach_request}    ui_version=${ui_version}

UE preparation and restart UE Proxy if UE preparation fails
    [Documentation]    Author: Catherine Cheng,  UE preparation and restart UE Proxy if UE preparation fails
    [Arguments]    ${ue_index}=${0}    ${detach_request}=${True}    ${ui_version}=default
    ${prepare_results}    run keyword and return status     power_ue.Prepare UE    ue_type=${UE_TYPE}
    ...    ue_index=${ue_index}   detach_request=${detach_request}    ui_version=${ui_version}
    run keyword if    "${prepare_results}"!="${True}"    Restart UE Proxy and Retry UE preparation    ue_index=${ue_index}
    ...    detach_request=${detach_request}    ui_version=${ui_version}

Restart UE Proxy and Retry UE preparation
    [Documentation]    Author: Catherine Cheng,  Restart UE Proxy and Retry UE preparation
    [Arguments]    ${ue_index}=${0}    ${detach_request}=${True}    ${ui_version}=default
    Restart UE proxy service with nssm on CPC    ue_index=${ue_index}
    Wait Until Keyword Succeeds    2min    20 sec    power_ue.Prepare UE    ue_type=${UE_TYPE}    ue_index=${ue_index}
    ...    detach_request=${detach_request}    ui_version=${ui_version}


Case common setup multiGNB
    [Documentation]    author: Catherine Cheng
    ...    case setup for both classical
    ...    is_pdl_checking_needed=${True}
    ...    if ${enb_default_scf_file}!=${None}, commission LTE
    ...    there will be suite variable ${PDL_VALIDATION_RESULT} generated after KW executed.
    ...        if you need to check PDL validation result, you can check the this suite variable in case part, then it will affect minimum case.
    ...        for example: run keyword and continue on failure    Should be true    ${PDL_VALIDATION_RESULT}!=${False}
    ...                     msg=Commissioned with error exists, pdl validation result is not in OK status.
    ...    Process classical gnb scf  example:
    ...         if process scf is needed, then the unified arguments should be set
    ...         ${PARAMS_TO_DELETE_DIC} for delete, ${PARAMS_TO_MODIFY_DIC} for modify, ${PARAMS_TO_ADD_DIC} for add, seperately.
    ...         format of the arguments can be referred in scf_process.py
    ...    Following action need to be done if testline run with UTE Cloud environment ,for example tl045 :
    ...         if you need to use eNB or case run with NSA, note1,2 is needed, else ignore.
    ...         1. enb object predefined in testline configuration __init__.py, but added to ues, not into enbs, else enb install package
    ...         will be triggered by ute task, and meet others preprare issue;
    ...         2. add enb object into testline enbs with robotws/commissionings/HGZ/7_5_UTE5G402T045/__init__.py
    ...         3. Call "Set variables for UTE cloud" keyword before keyword "Suite common setup preparation", some parameters need to be predefined,
    ...         for example ${testline_name} need to be setted first, then scf path value can be setted normal, else meet error.
    # classical testline commission
    [Arguments]    ${is_pdl_checking_needed}=${True}
    ...    ${scf_template_path}=${SCF_DEFAULT_FILE_PATH}
    ...    ${scf_name_suffix}=${None}
    ...    ${swconfig_template_path}=${SWCONFIG_DEFAULT_FILE_PATH}
    ...    ${is_enb_status_check_needed}=${True}
    ...    ${is_x2_check_from_enb_needed}=${True}
    # NSA need to check enb status and x2, but SA don't need to check enb and x2
    ...    ${NSA_SA}=NSA
    ...    ${gnb_num}=${2}
    ...    ${fail_with_alarms}=${True}    ${allowed_faults_ids}=${RIM_ALLOWED_FAULTS_IDS}
    ...    &{kwargs}
    ${IS_UTE_ENV}      get_variable_value    ${IS_UTE_ENV}
    run keyword if     ${IS_UTE_ENV}    CI_interface.Common Case Setup     # ute cloud case setup

    COAM Create log directory
    #no matter ute cloud or lightweight, need to call following KW, report configuration ID
    robot_common_operations.Common Case Setup    allowed_faults_ids=${allowed_faults_ids}    fail_with_alarms=${fail_with_alarms}

    Comissioning and Wait for Cell on air multiGNB    is_pdl_checking_needed=${is_pdl_checking_needed}
    ...    scf_template_path=${scf_template_path}
    ...    scf_name_suffix=${scf_name_suffix}
    ...    swconfig_template_path=${swconfig_template_path}
    ...    is_enb_status_check_needed=${is_enb_status_check_needed}
    ...    is_x2_check_from_enb_needed=${is_x2_check_from_enb_needed}
    ...    NSA_SA=${NSA_SA}
    ...    gnb_num=${gnb_num}

    Common case setup    NSA_SA=${NSA_SA}

Comissioning and Wait for Cell on air multiGNB
    [Documentation]    author: Catherine Cheng
    ...    Comissioning and Wait for Cell on air multiGNB for classical
    ...    if ${enb_default_scf_file}!=${None}, commission LTE
    ...    there will be suite variable ${PDL_VALIDATION_RESULT} generated after KW executed.
    ...        if you need to check PDL validation result, you can check the this suite variable in case part, then it will affect minimum case.
    ...        for example: run keyword and continue on failure    Should be true    ${PDL_VALIDATION_RESULT}!=${False}
    ...                     msg=Commissioned with error exists, pdl validation result is not in OK status.
    ...    Process classical gnb scf  example:
    ...         if process scf is needed, then the unified arguments should be set
    ...         ${PARAMS_TO_DELETE_DIC} for delete, ${PARAMS_TO_MODIFY_DIC} for modify, ${PARAMS_TO_ADD_DIC} for add, seperately.
    ...         format of the arguments can be referred in scf_process.py
    ...    Following action need to be done if testline run with UTE Cloud environment ,for example tl045 :
    ...         if you need to use eNB or case run with NSA, note1,2 is needed, else ignore.
    ...         1. enb object predefined in testline configuration __init__.py, but added to ues, not into enbs, else enb install package
    ...         will be triggered by ute task, and meet others preprare issue;
    ...         2. add enb object into testline enbs with robotws/commissionings/HGZ/7_5_UTE5G402T045/__init__.py
    ...         3. Call "Set variables for UTE cloud" keyword before keyword "Suite common setup preparation", some parameters need to be predefined,
    ...         for example ${testline_name} need to be setted first, then scf path value can be setted normal, else meet error.
    # classical testline commission
    [Arguments]     ${is_pdl_checking_needed}=${True}
    ...    ${scf_template_path}=${SCF_DEFAULT_FILE_PATH}
    ...    ${scf_name_suffix}=${None}
    ...    ${swconfig_template_path}=${SWCONFIG_DEFAULT_FILE_PATH}
    ...    ${is_enb_status_check_needed}=${True}
    ...    ${is_x2_check_from_enb_needed}=${True}
    # NSA need to check enb status and x2, but SA don't need to check enb and x2
    ...    ${NSA_SA}=NSA
    ...    ${gnb_num}=${2}
    ...    &{kwargs}
    ${is_enb_status_check_needed}     set variable if    '${NSA_SA}'=='SA'    ${False}    ${is_enb_status_check_needed}
    ${is_x2_check_from_enb_needed}    set variable if    '${NSA_SA}'=='SA'    ${False}    ${is_x2_check_from_enb_needed}

    log to console    start to commission in case setup...
    FOR    ${gnb_id}    IN RANGE     ${gnb_num}
        ${scf_template_path}     Set Variable if  '${scf_name_suffix}'=='${None}'
        ...   /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${tl.gnbs[${gnb_id}].instance_id}.xml
        ...   /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${tl.gnbs[${gnb_id}].instance_id}${scf_name_suffix}.xml
        ${swconfig_template_path}      Set Variable
        ...    /home/ute/Projects/mmw1_config/${testline_name}/swconfig/swconfig_MMW1_TL${tl.gnbs[${gnb_id}].instance_id}.txt

        @{params_to_delete}    Set Variable    ${PARAMS_TO_DELETE_DIC[${gnb_id}]}
        @{params_to_modify}    Set Variable     ${PARAMS_TO_MODIFY_DIC[${gnb_id}]}
        @{params_to_add}    Set Variable     ${PARAMS_TO_ADD_DIC[${gnb_id}]}
        ${scf_template_path}    Get scf template file with release considered    scf_template_file_path=${scf_template_path}    program=${PROGRAM}

        ${template_for_process}    scfpro.SCFProcess    scf_template_path=${scf_template_path}    scf_process_folder=${SUITE_LOG_PATH}
        ...    list_para_to_delete=${params_to_delete}
        ...    list_para_to_modify=${params_to_modify}
        ...    list_para_to_add=${params_to_add}
        ...    scf_file_name_after_process=SCFProcessed_TL${tl.gnbs[${gnb_id}].instance_id}.xml

        Connect to gnb coam via ssl   connection=${OAM_ALIAS_GNB${gnb_id}}    gnb_index=${gnb_id}

        Preparation with swconfig modification and comissioning    swconfig_modify=${None}
                                                ...    swconfig_template_path=${swconfig_template_path}
                                                ...    scf_template_path=${template_for_process}
                                                ...    gnb_index=${gnb_id}
                                                ...    connection=${OAM_ALIAS_GNB${gnb_id}}
                                                ...    alias=${ASIK_ALIAS_GNB${gnb_id}}
                                                ...    is_pdl_checking_needed=${is_pdl_checking_needed}
        run keyword and continue on failure    Wait until gnb connection lost
        run keyword and continue on failure    Wait Until Keyword Succeeds    2min    3 sec    gNB connection status
    END

    log to console    Wait onair for GNB...
    Wait on cell on air status multi GNB   NSA_SA=${NSA_SA}    gnb_num=${gnb_num}

Wait until gnb connection lost
    [Documentation]    Wait until gnb connection lost
    [Arguments]    ${interval}=${5}    ${try_time}=${10}
    FOR    ${i}    IN RANGE    ${try_time}
        ${status}=    Run Keyword And Return Status    gNB connection status
        Run Keyword If    not ${status}    Exit For Loop
        Sleep    ${interval}
    END

gNB connection status
    [Documentation]    gNB connection status
    ...    Author: Wang Yixiang
    Connect to Common Unit Master    alias=ASIK Master
    [Teardown]    csn.disconnect    connection=ASIK Master

_CI Keyword run on GNB0
    [Documentation]    Keyword run on GNB0
    ...    Author: Wang Yixiang
    [Arguments]   ${ue_index}=${0}
    robot_common_operations.Common Suite Setup

    ${cur_program}    gnb_classical_hangzhou.Get program version based on stream version
    set suite variable    ${PROGRAM}    ${cur_program}
    COAM Create log directory    is_set_to_test_case_level=${False}
    ${UE_status}    run keyword and return status    ue.translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${UE_TYPE}   run keyword if   ${UE_status}   ue.translate_power_ue_type_from_testline    ue_index=${ue_index}
    run keyword if   ${UE_status}    set suite variable    ${UE_TYPE}

Wait on cell on air status multi GNB
    [Documentation]     Wait on cell on air status multi GNB
    ...    Author: Wang Yixiang
    [Arguments]   ${NSA_SA}    ${gnb_num}=${2}
    ...    ${timeout}=${CLASSICAL_COMMISSION_ONAIR_TIMEOUT}    ${is_all_cells_checking_needed}=${True}
    ...    ${enb_index}=${None}

    ${is_enb_status_check_needed}     set variable if    '${NSA_SA}'=='SA'    ${False}    ${is_enb_status_check_needed}
    ${is_x2_check_from_enb_needed}    set variable if    '${NSA_SA}'=='SA'    ${False}    ${is_x2_check_from_enb_needed}

    FOR    ${gnb_id}    IN RANGE     ${gnb_num}
        Wait until cluster is on cell on air status    timeout=${timeout}
        ...    is_all_cells_checking_needed=${is_all_cells_checking_needed}    enb_index=${enb_index}
        ...    is_enb_status_check_needed=${is_enb_status_check_needed}    is_x2_check_from_enb_needed=${is_x2_check_from_enb_needed}
        ...    connection=${OAM_ALIAS_GNB${gnb_id}}
        ...    gnb_index=${gnb_id}
    END

Common case teardown multiGNB
    [Documentation]    author: Wang Yixiang, modified by catherine cheng to adapt cases to UTE CLOUD
    ...    Common case teardown multiGNB
    [Arguments]    ${gnb0_snapshot}=${True}    ${gnb1_snapshot}=${True}    ${detach_ue}=${True}   ${is_btslog_required}=${False}
    run keyword if   ${gnb0_snapshot}    Collect logs in teardown   is_called_in_test_case_level=${True}
    ...    is_btslog_required=${False}    gnb_index=0    connection=${OAM_ALIAS_GNB0}
    run keyword if   ${gnb1_snapshot}    Collect logs in teardown   is_called_in_test_case_level=${True}
    ...    is_btslog_required=${False}    gnb_index=1    connection=${OAM_ALIAS_GNB1}
    coam_gnb_classical.COAM Teardown gnb connections    connection=${OAM_ALIAS_GNB1}
    Common case teardown    detach_ue=${detach_ue}    is_btslog_required=${is_btslog_required}    is_log_required=${False}

Get Muti NIDD value via rest api
    [Documentation]    Author: Wang Yixiang
    ...                Description:
    ...    parameter = [dict(dist_name=DN_NRRIM,p_name='repetitionRsType1')]
    [Arguments]  ${parameter}  ${connection}=GNB_OAM
    ${ret_dict}   create dictionary
    FOR    ${item}    IN     @{parameter}
        ${para}   Get From Dictionary    ${item}        p_name
        ${dist_name}   Get From Dictionary    ${item}        dist_name
        ${value}   coam_parameter.get_single_value_from_scf_file   parameter=${para}   dist_name=${dist_name}    connection=${connection}
        Set To Dictionary    ${ret_dict}    ${para}=${value}
    END
    [Return]   ${ret_dict}

#Check SRS not exist in bip log
#    [Documentation]    Author: Wang Yixiang
#    ...                Description: check uldata_srsreceivereq not exist while 7525 exist
#    [Arguments]  ${bip_log}
#    ${srs_receive_request_flag}    Check SRS in bip log    bip_log=${bip_log}
#    Should Be Equal    ${srs_receive_request_flag}    ${False}   SRS should not exist when RI is appeared
#
#Check SRS exist in bip log
#    [Documentation]    Author: Wang Yixiang
#    ...                Description:check uldata_srsreceivereq restore while 7525 not exist
#    [Arguments]  ${bip_log}
#    ${srs_receive_request_flag}    Check SRS in bip log    bip_log=${bip_log}
#    Should Be Equal    ${srs_receive_request_flag}    ${True}   SRS should exist when RI is disappeared
#
#Check SRS in bip log
#    [Documentation]    Author: Wang Yixiang
#    ...                Description:check uldata_srsreceivereq exist or not in bip log
#    [Arguments]  ${bip_log}
#    pcap.setup    infile=${bip_log}    display_filter=uldata_srsreceivereq
#    sleep    5s
#    ${result}    pcap.get_field_value_by_name   field_name=UlData_SrsReceiveReq_t.addrSrsReceiveResp
#                                    ...    attribute_name=show
#    ${count}    Get Length    ${result}
#    ${srs_receive_request_flag}    set variable if   ${count}>3    ${True}    ${False}
#    [Return]   ${srs_receive_request_flag}

Lock cells
    [Documentation]    Author: Cheng Catherine
    ...    Description: lock cells via rest api
    [Arguments]    ${lock_cell_list}=@{CELL_LIST_GNB1}    ${lock_cell_connection}=${OAM_ALIAS_GNB1}
    ...    ${lock_cell_gnb_id}=1
    FOR    ${cell_idx}    IN     @{lock_cell_list}
        Perform cell lock via rest api    cell_idx=${cell_idx}
                                    ...    gnb_id=${lock_cell_gnb_id}
                                    ...    connection=${lock_cell_connection}
        Wait Until Keyword Succeeds    90 sec    3 sec     Cell Should Be Locked    cell_idx=${cell_idx}
                                                                        ...    connection=${lock_cell_connection}
    END


Unlock cells
    [Documentation]    Author: Cheng Catherine
    ...    Description: unlock cells via rest api
    [Arguments]    ${lock_cell_list}=@{CELL_LIST_GNB1}    ${lock_cell_connection}=${OAM_ALIAS_GNB1}
    ...    ${lock_cell_gnb_id}=1
    FOR    ${cell_idx}    IN     @{lock_cell_list}
        Perform cell unlock via rest api    cell_idx=${cell_idx}
                                    ...    gnb_id=${lock_cell_gnb_id}
                                    ...    connection=${lock_cell_connection}
        Wait Until Keyword Succeeds    5 min    3 sec     Cell Should Be Unlocked    cell_idx=${cell_idx}
                                                                ...    connection=${lock_cell_connection}
    END


Set aggressor targetTotalLoad via restAPI
    [Documentation]    Set targetTotalLoad via restAPI
    ...    Author: Wang Yixiang
    [Arguments]    ${paras}
    coam_gnb_classical.COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${paras}
    ...    skip_parameter_relation_errors=${False}
    ...    connection=${OAM_ALIAS_GNB1}
    ...    timeout=${120}

Expect Fault Present on Cells or not
    [Documentation]    Author: Cheng Catherine
    ...    Description: check fault should present on cells if ${present}=${True}, else fault should not present
    ...    cell_list:       default value is @{TDD_CELL_ID_LIST}, which is define in ../TestData/NIDD_modify_scf.py
    ...    faultId:         faultId
    ...    alarmId:         alarmId
    ...    severity:        severity, default value is Minor
    ...    supplementary:   supplementary alarm information should contain
    ...    supplementary_not_contain:   supplementary alarm information should not contain
    ...    present:      fault should present on cells if ${present}=${True}, else fault should not present on cells
    ...    gnb_index:    default value is 0
    ...    connection:   default value is GNB_OAM
    [Arguments]    ${cell_list}    ${faultId}    ${alarmId}    ${severity}=Minor    ${supplementary}=${None}
    ...    ${supplementary_not_contain}=${None}     ${present}=${True}    ${connection}=GNB_OAM    ${gnb_index}=0
    ${instance_id}     set variable    ${tl.gnbs[${gnb_index}].instance_id}
    ${bts_id}     set variable    ${tl.gnbs[${gnb_index}].global_bts_id}
    FOR  ${cell_id}  IN   @{cell_list}
        ${configObject}    catenate    MRBTS-${instance_id}/NRBTS-${bts_id}/NRCELL-${cell_id}
        run keyword if     ${present}==${True}    Expect Fault Should Present    faultId=${faultId}
                                                    ...    alarmId=${alarmId}
                                                    ...    severity=${severity}
                                                    ...    configObjectName=${configObject}
                                                    ...    supplementary=${supplementary}
                                                    ...    supplementary_not_contain=${supplementary_not_contain}
                                                    ...    connection=${connection}
        ...    ELSE    Expect Fault Should Absent   faultId=${faultId}
    END


Wait and Verify Fault Present on Cells
    [Documentation]    Author: Cheng Catherine
    ...    Description: wait and check fault raised on WEBEM, and check supplementary alarm info is also possible
    ...    cell_list:       default value is @{TDD_CELL_ID_LIST}, which is define in ../TestData/NIDD_modify_scf.py
    ...    faultId:         faultId
    ...    alarmId:         alarmId
    ...    supplementary:   supplementary alarm information should contain
    ...    supplementary_not_contain:   supplementary alarm information should not contain
    ...    severity:        severity, default value is Minor
    ...    alarm_check_timeout:    alarm check timeout
    ...    alarm_check_interval:    alarm check interval
    ...    gnb_index:    default value is 0
    ...    connection:   default value is GNB_OAM
    ...    CM_check_timeout :   CM_check_timeout
    ...    cm_ri_state:  off: means riStateReport is FM on, CM off or FM off, CM off;
    ...                  on: means riStateReport is FM off, CM on
    ...    cm_rimrssetid_state: off: means rimRsStateReport is FM on, CM off or FM off, CM off;
    ...                         on: means rimRsStateReport is FM off, CM on
    ...    cm_dlmuting_state: off: means dlMutingStateReport is FM on, CM off or FM off, CM off;
    ...                       on: means dlMutingStateReport is FM off, CM on
    ...    cm_asymmetric_state: off: means dlMutingStateReport is FM on, CM off or FM off, CM off;
    ...                         on: means dlMutingStateReport is FM off, CM on
    ...    asymmetricState: not check： means not check this value; ${None} means empty on WEBEM
    ...    riState: not check, means not check this value; ${None} means empty on WEBEM
    ...    rimRsSetIdType1: not check, means not check this value; ${None} means empty on WEBEM
    ...    rimRsSetIdType2: not check, means not check this value; ${None} means empty on WEBEM
    ...    pdcchMutingStatus: not check means not check this value; ${None} means empty on WEBEM
    ...    pdschMutingStatus: not check means not check this value; ${None} means empty on WEBEM
    [Arguments]    ${cell_list}=@{TDD_CELL_ID_LIST}    ${faultId}=7525    ${alarmId}=7115    ${supplementary}=${None}
    ...    ${supplementary_not_contain}=${None}    ${severity}=Minor    ${alarm_check_timeout}=1m    ${alarm_check_interval}=2s
    ...    ${gnb_index}=0        ${connection}=GNB_OAM    ${cm_ri_state}=off    ${cm_rimrssetid_state}=off
    ...    ${cm_dlmuting_state}=off    ${cm_asymmetric_state}=off    ${CM_check_timeout}=30m
    ...    ${asymmetricState}=not check    ${riState}=not check    ${rimRsSetIdType1}=not check
    ...    ${rimRsSetIdType2}=not check     ${pdcchMutingStatus}=not check    ${pdschMutingStatus}=not check
    Run Keyword If    '${cm_ri_state}'=='on' or '${cm_dlmuting_state}'=='on' or '${cm_rimrssetid_state}'=='on' or '${cm_asymmetric_state}'=='on'
    ...    Wait and Get NRRIMINFO via WEBEM and Check NRRIMINFO Value is as Expected    riState=${riState}
    ...    asymmetricState=${asymmetricState}    rimRsSetIdType1=${rimRsSetIdType1}    rimRsSetIdType2=${rimRsSetIdType2}
    ...    pdschMutingStatus=${pdschMutingStatus}    pdcchMutingStatus=${pdcchMutingStatus}    wait_time=${CM_check_timeout}
    ...    time_interval=${alarm_check_interval}
    ...    ELSE     Wait Until Keyword Succeeds    ${alarm_check_timeout}    ${alarm_check_interval}
    ...    Expect Fault Present on Cells or not    cell_list=${cell_list}    faultId=${faultId}
                                                            ...    alarmId=${alarmId}    severity=${severity}
                                                            ...    supplementary=${supplementary}
                                                            ...    supplementary_not_contain=${supplementary_not_contain}
                                                            ...    gnb_index=${gnb_index}    connection=${connection}

Wait and Verify Fault 7525 not Present on Cells
    [Documentation]    Author: Cheng Catherine
    ...    Description:  wait and check Fault 7525 not exist on WebUI
    ...    fault_cancel_cell_list:      fault not exist on which cells
    ...    7525_check_timeout:          alarm check timeout for fault 7525
    ...    alarm_check_interval:        alarm_check_interval for both fault 7525
    ...    connection:
    ...    gnb_index:
    ...    cm_ri_state:  off: means riStateReport is FM on, CM off or FM off, CM off;
    ...                  on: means riStateReport is FM off, CM on
    [Arguments]    ${fault_cancel_cell_list}=@{TDD_CELL_ID_LIST}    ${7525_check_timeout}=${RI_TIMEOUT}
    ...    ${alarm_check_interval}=20s    ${connection}=GNB_OAM    ${gnb_index}=0
    ...    ${cm_ri_state}=off   ${CM_check_timeout}=30min
    Run Keyword If    '${cm_ri_state}' == 'off'    Wait Until Keyword Succeeds    ${7525_check_timeout}    ${alarm_check_interval}
    ...    Expect Fault Present on Cells or not    ${fault_cancel_cell_list}
                                        ...    faultId=7525    alarmId=7115   present=${False}
                                        ...    connection=${connection}    gnb_index=${gnb_index}
    ...    ELSE    Wait and Get NRRIMINFO via WEBEM and Check NRRIMINFO Value is as Expected
    ...    wait_time=${CM_check_timeout}    riState=no RI    time_interval=${alarm_check_interval}


Wait and Verify Fault 7527 not Present on Cells
    [Documentation]    Author: Cheng Catherine
    ...    Description:  wait and check Fault 7527 not exist on WebUI
    ...    fault_cancel_cell_list:      fault not exist on which cells
    ...    7527_check_timeout:          alarm check timeout for fault 7527
    ...    alarm_check_interval:        alarm_check_interval for both fault 7527
    ...    connection:
    ...    gnb_index:
    ...    cm_rimrssetid_state: off: means rimRsStateReport is FM on, CM off or FM off, CM off;
    ...                         on: means rimRsStateReport is FM off, CM on
    [Arguments]    ${fault_cancel_cell_list}=@{TDD_CELL_ID_LIST}    ${7527_check_timeout}=10m
    ...    ${alarm_check_interval}=20s    ${connection}=GNB_OAM    ${gnb_index}=0
    ...    ${cm_rimrssetid_state}=off    ${CM_check_timeout}=30min
    Run Keyword If    '${cm_rimrssetid_state}' == 'off'     Wait Until Keyword Succeeds    ${7527_check_timeout}    ${alarm_check_interval}
    ...    Expect Fault Present on Cells or not    ${fault_cancel_cell_list}
                                        ...    faultId=7527    alarmId=7115   present=${False}
                                        ...    connection=${connection}    gnb_index=${gnb_index}
    ...    ELSE    Wait and Get NRRIMINFO via WEBEM and Check NRRIMINFO Value is as Expected
    ...    wait_time=${CM_check_timeout}    rimRsSetIdType1=${None}    rimRsSetIdType2=${None}
    ...    time_interval=${alarm_check_interval}

Wait and Verify Fault 7535 not Present on Cells
    [Documentation]    Author: Cheng Catherine
    ...    Description:  wait and check Fault 7535 not exist on WebUI
    ...    fault_cancel_cell_list:      fault not exist on which cells
    ...    7535_check_timeout:          alarm check timeout for fault 7535
    ...    alarm_check_interval:        alarm_check_interval for both fault 7535
    ...    connection:
    ...    gnb_index:
    ...    cm_dlmuting_state: off: means dlMutingStateReport is FM on, CM off or FM off, CM off;
    ...                       on: means dlMutingStateReport is FM off, CM on
    ...    actRimPdcchMutingOnSpecialSlot: true: means NIDD actRimPdcchMutingOnSpecialSlot is true
    ...                                    false: means NIDD actRimPdcchMutingOnSpecialSlot is false
    [Arguments]    ${fault_cancel_cell_list}=@{TDD_CELL_ID_LIST}    ${7535_check_timeout}=2m
    ...    ${alarm_check_interval}=10s    ${connection}=GNB_OAM    ${gnb_index}=0
    ...    ${cm_dlmuting_state}=off    ${actRimPdcchMutingOnSpecialSlot}=false
    ...    ${CM_check_timeout}=30min
    ${pdcchMuting}    Set Variable If    '${actRimPdcchMutingOnSpecialSlot}'=='true'    no muting
    Run Keyword If    '${cm_dlmuting_state}' == 'off'    Wait Until Keyword Succeeds    ${7535_check_timeout}    ${alarm_check_interval}
    ...    Expect Fault Present on Cells or not    ${fault_cancel_cell_list}
                                        ...    faultId=7535    alarmId=7115   present=${False}
                                        ...    connection=${connection}    gnb_index=${gnb_index}
    ...    ELSE    Wait and Get NRRIMINFO via WEBEM and Check NRRIMINFO Value is as Expected
    ...    wait_time=${CM_check_timeout}    pdschMutingStatus=no muting    pdcchMutingStatus=${pdcchMuting}
    ...    time_interval=${alarm_check_interval}

Wait and Verify Fault 7532 not Present on Cells
    [Documentation]    Author: Wang Yixiang
    ...    Description:  wait and check Fault 7532 not exist on WebUI
    ...    fault_cancel_cell_list:      fault not exist on which cells
    ...    7532_check_timeout:          alarm check timeout for fault 7532
    ...    alarm_check_interval:        alarm_check_interval for both fault 7532
    ...    connection:
    ...    gnb_index:
    ...    cm_asymmetric_state: off: means dlMutingStateReport is FM on, CM off or FM off, CM off;
    ...                         on: means dlMutingStateReport is FM off, CM on
    ...    asymmetricState: not check： means not check this value; ${None} means empty on WEBEM
    [Arguments]    ${fault_cancel_cell_list}=@{TDD_CELL_ID_LIST}    ${7532_check_timeout}=10m
    ...    ${alarm_check_interval}=10s    ${connection}=GNB_OAM    ${gnb_index}=0
    ...    ${cm_asymmetric_state}=off    ${CM_check_timeout}=30min
    Run Keyword If    '${cm_asymmetric_state}' == 'off'    Wait Until Keyword Succeeds    ${7532_check_timeout}    ${alarm_check_interval}
    ...    Expect Fault Present on Cells or not    ${fault_cancel_cell_list}
                                        ...    faultId=7532    alarmId=7115   present=${False}
                                        ...    connection=${connection}    gnb_index=${gnb_index}
    ...    ELSE    Wait and Get NRRIMINFO via WEBEM and Check NRRIMINFO Value is as Expected
    ...    wait_time=${CM_check_timeout}    time_interval=${alarm_check_interval}    asymmetricState=no asymmetric


Wait and Verify Expect Fault Present or not from History List on Cells
    [Documentation]    Author: Cheng Catherine
    ...    Description:  wait and verify if Fault present from history list on cells
    ...    cell_list:      fault should present or not on which cells
    ...    faultId:        fault id
    ...    alarmId:        alarm id
    ...    severity:       severity
    ...    source:         source
    ...    supplementary:        supplementary
    ...    expect_present:        expect_present, true or false, default is true
    ...    connection:  default is GNB_OAM
    ...    check_timeout:   default is 1min
    ...    alarm_check_interval:   default is 20s
    [Arguments]    ${cell_list}=@{TDD_CELL_ID_LIST}    ${faultId}=7527    ${alarmId}=7115    ${severity}=Minor
    ...    ${source}=${None}    ${supplementary}=${None}    ${expect_present}=${True}   ${connection}=GNB_OAM
    ...    ${check_timeout}=1m    ${alarm_check_interval}=20s

    Wait Until Keyword Succeeds    ${check_timeout}    ${alarm_check_interval}
    ...    Expect Fault Present or not from History List on Cells     cell_list=${cell_list}
                                                            ...    faultId=${faultId}    alarmId=${alarmId}
                                                            ...    severity=${severity}    source=${source}
                                                            ...    supplementary=${supplementary}
                                                            ...    expect_present=${expect_present}
                                                            ...    connection=${connection}


Expect Fault Present or not from History List on Cells
    [Documentation]    Author: Cheng Catherine
    ...    Description:  verify if Fault present from history list on cells
    ...    cell_list:      fault should present or not on which cells
    ...    faultId:        fault id
    ...    alarmId:        alarm id
    ...    severity:       severity
    ...    source:         source
    ...    supplementary:        supplementary
    ...    expect_present:        expect_present, true or false, default is true
    ...    connection:  default is GNB_OAM
    ...    gnb_index:   default is 0
    [Arguments]    ${cell_list}=@{TDD_CELL_ID_LIST}    ${faultId}=7527    ${alarmId}=7115    ${severity}=Minor
    ...   ${source}=${None}    ${supplementary}=${None}    ${expect_present}=${True}    ${connection}=GNB_OAM    ${gnb_index}=0

    ${instance_id}     set variable    ${tl.gnbs[${gnb_index}].instance_id}
    ${bts_id}     set variable    ${tl.gnbs[${gnb_index}].global_bts_id}
    FOR  ${cell_id}  IN  @{cell_list}
        ${configObject}    catenate    MRBTS-${instance_id}/NRBTS-${bts_id}/NRCELL-${cell_id}
        Expect Fault Present or not from History List    faultId=${faultId}    alarmId=${alarmId}    severity=${severity}
                                                ...    source=${source}    config_object_name=${configObject}
                                                ...    supplementary=${supplementary}    expect_present=${expect_present}
                                                ...    connection=${connection}
    END


Expect Fault Present or not from History List
    [Documentation]    Author: Cheng Catherine
    ...    Description:  verify if Fault present from history list
    ...    faultId:        fault id
    ...    alarmId:        alarm id
    ...    severity:       severity
    ...    source:         source
    ...    supplementary:        supplementary
    ...    expect_present:        expect_present, true or false, default is true
    ...    connection:  default is GNB_OAM
    [Arguments]    ${faultId}    ${alarmId}=${None}    ${severity}=${None}   ${source}=${None}
    ...    ${config_object_name}=${None}    ${supplementary}=${None}    ${expect_present}=${True}
    ...    ${connection}=GNB_OAM

    ${history_alarms_list}    coam.get_historic_alarms    connection=${connection}    timeout=100    load_history=${True}
    ${alarm_present}    set variable    ${false}
    FOR  ${alarm}  IN  @{history_alarms_list}
        ${alarm_status}    Run Keyword And Return Status    Run Keywords
                  ...                      Dictionary Should Contain Item    ${alarm}    faultId    ${faultId}    AND
                  ...                      Run Keyword If    '${alarmId}'!='${None}'
                  ...                      Should Be Equal As Strings    ${alarm['alarmId']}    ${alarmId}    AND
                  ...                      Run Keyword If    '${severity}'!='${None}'
                  ...                      Should Contain     ${alarm['severity']}   ${severity}    case_insensitive=True    AND
                  ...                      Run Keyword If    '${source}'!='${None}'
                  ...                      Should Contain     ${alarm['notifier']}    ${source}    case_insensitive=True    AND
                  ...                      Run Keyword If    '${config_object_name}'!='${None}'
                  ...                      Should Contain    ${alarm['configObjectName']}    ${config_object_name}    AND
                  ...                      Run Keyword If    '${supplementary}'!='${None}'
                  ...                      Should Contain   ${alarm['supplAlarmInfo']}    ${supplementary}
        ${alarm_present}    set variable if     ${alarm_status}==${true}    ${true}    ${alarm_present}
    END
    should be true    ${expect_present}==${alarm_present}    Fault status from history alarm list is not expected, please check!!!


Captrue bip then Stop Traffic Detach UE and Check if DL and S slot scheduled on Aggressor
    [Documentation]    Author: Cheng Catherine
    ...    Description:  capture local gnb bip logs for ${capture_time}, and to check if pdsch is scheduled
    ...    on Special and the preceding DL slot
    ...    pdsch_slot_list:        pdsch slot list to check mitiagtion for different frame structure
    ...    capture_time:           start capture, and wait for some time, then stop
    ...    is_pdsch_scheduled_on_s_d_slot:   ${True} means pdsch is scheduled at Special slot and the preceeding DL slot;
    ...                             ${False} means pdsch is not scheduled at Special slot and the preceeding DL slot
#    ...    filter:                   default value is dldata_pdschsendreq && 3gpp.rnti!=65535
    ...    srs_check: Value can be "exist" or "not exist" or ${False},filter uldata_srsreceivereq from BIP log,
    ...               pSRS should disable after 7525, and resume after 7525 disappear (precondition nidd:actUlSrsBm=true, actDlSrsBm=true)
    ...    mirroring_filter: – Optional, [Default | AllMessages | SpecificL1L2Messages]. Only supported when
    ...                           interface is ‘L1-L2’ and destination is ‘Local’. Only available from SBTS24R1 onwards.
    ...    specific_message_ids: – Optional, only supported when mirroring_filter is ‘SpecificL1L2Messages’.
    ...                           string using comma separate. Must be in hex format. e.g: 0xe118,0xe113, message id from SW event
    [Arguments]      ${pdsch_slot_list}    ${capture_time}=3 sec
    ...    ${is_pdsch_scheduled_on_s_d_slot}=${True}
    ...    ${mirroring_filter}=SpecificL1L2Messages
#    ...    ${specific_message_ids}=${MESSAGE_ID_PDSCH_SEND_REQ},${MESSAGE_ID_SRS_RECEIVE_REQ},${MESSAGE_ID_RIM_RECEIVE_REQ}
    ...    ${target_file_name}=bip_log_dl_data
    ...    ${srs_check}=${False}
    ...    ${check_rs_detect_false}=${False}
    ...    ${feature}=9823
    Connect to Common Unit Master
    ${bip_log_PDSCH_RIM}    Collect Bip logs and Return Files Path    target_file_name=${target_file_name}_PDSCH_RIM    capture_time=${capture_time}
    ...    mirroring_filter=${mirroring_filter}    specific_message_ids=${MESSAGE_ID_PDSCH_SEND_REQ},${MESSAGE_ID_RIM_RECEIVE_REQ}
    sleep   3s
    ${bip_log_SRS}    Collect Bip logs and Return Files Path    target_file_name=${target_file_name}_SRS   capture_time=${capture_time}
    ...    mirroring_filter=${mirroring_filter}    specific_message_ids=${MESSAGE_ID_SRS_RECEIVE_REQ}

    run keyword and ignore error    Stop data transfer and detach UE
    run keyword and continue on failure    Check if DL and Special slot scheduled    log_path=${bip_log_PDSCH_RIM[0]}
                                                          ...    pdsch_slot_list=${pdsch_slot_list}
                                                          ...    is_pdsch_scheduled_on_s_d_slot=${is_pdsch_scheduled_on_s_d_slot}
    run keyword and continue on failure   run keyword if   '${srs_check}'=='not exist'     OperatingSystem.File Should not Exist   ${bip_log_SRS[0]}
#    ...    Verify srsBm is enabled or disabled from bip log    log_path=${bip_log_SRS[0]}    feature=${feature}    srsBmEnable=False
    run keyword and continue on failure    run keyword if   '${srs_check}'=='exist'
    ...    Verify srsBm is enabled or disabled from bip log    log_path=${bip_log_SRS[0]}    feature=${feature}    srsBmEnable=True
    run keyword and continue on failure    run keyword if   ${check_rs_detect_false}    Check new detection is disabled
                                                                                        ...    log_path=${bip_log_PDSCH_RIM[0]}
    [Teardown]    run keyword and ignore error    Stop data transfer and detach UE


Collect Bip logs and Return Files Path one time
    [Documentation]    Author: Cheng Catherine
    ...    Description:  Collect Bip logs and Return Files Path
    [Arguments]    ${target_file_name}    ${mirroring_filter}    ${specific_message_ids}    ${capture_time}    ${gnb_index}=${0}
    run keyword and continue on failure     Collect Interface Mirroring Bip Collector    target_file_name=${target_file_name}
                                          ...    mirroring_filter=${mirroring_filter}
                                          ...    specific_message_ids=${specific_message_ids}
                                          ...    gnb_index=${gnb_index}
    Sleep    ${capture_time}
    ${bip_log}    Get Bip Log Via Interface Mirroring Collector    target_file_name=${target_file_name}
    [Return]     ${bip_log}


Collect Bip logs and Return Files Path
    [Documentation]    Author: Liu Zheng
    ...    Description:  Collect Bip logs and Return Files Path with retry
    [Arguments]    ${target_file_name}    ${mirroring_filter}    ${specific_message_ids}    ${capture_time}    ${gnb_index}=${0}
    ...    ${retry_time}=3
    ${bip_log}    Wait until keyword succeeds    ${retry_time}X    3 s       Collect Bip logs and Return Files Path one time
    ...    target_file_name=${target_file_name}    mirroring_filter=${mirroring_filter}
    ...    specific_message_ids=${specific_message_ids}    capture_time=${capture_time}    gnb_index=${gnb_index}
    [Return]     ${bip_log}


Check if DL and Special slot scheduled
    [Documentation]    Author: Cheng Catherine
    ...    Description:  check if pdsch is scheduled at Special slot and the DL slot before Special slot.
    ...    pdsch_slot_list:        pdsch slot list to check mitiagtion for different frame structure
    ...    is_pdsch_scheduled_on_s_d_slot:   ${True} means pdsch is scheduled at Special slot and the DL preceeding slot;
    ...                              ${False} means pdsch is not scheduled at Special slot and the DL preceeding slot
#    ...    filter:                   default value is dldata_pdschsendreq && 3gpp.rnti!=65535
    [Arguments]    ${pdsch_slot_list}    ${log_path}    ${is_pdsch_scheduled_on_s_d_slot}
    ${pdsch_name}    set variable if     "${PROGRAM}">="25R2"    dldata_pdschsendreql1sw    dldata_pdschsendreq
    ${filter}    set variable     ${pdsch_name} && 3gpp.rnti!=65535 && 3gpp.rnti!=65534
    ${field_name}  set variable if   "${PROGRAM}">="25R2"    DlData_PdschGrantL1sw.dlDmrsConfigType  DlData_PdschGrant.dlDmrsConfigType
    FOR   ${slot}    IN     @{pdsch_slot_list}
        pcap.setup    infile=${log_path}    display_filter=${filter} && 3gpp.slot == ${slot}
        sleep    1s
        ${result}    pcap.get_field_value_by_name   field_name=${field_name}
                                            ...    attribute_name=show
        run keyword if   ${is_pdsch_scheduled_on_s_d_slot}     should not be empty   ${result}
                                        ...    ELSE    should be empty   ${result}
    END


Captrue bip logs and Check RimRs Detection enable
    [Documentation]    Author: Cheng Catherine
    ...    Description:  Captrue bip logs and check rimrsdetection equals to true from uldata_rimreceivereq
    ...    capture_time:             start capture, and wait for some time, then stop
    ...    special_slot_list:        special slot list for different frame structure
    ...    filter:      default value is uldata_rimreceivereq
    ...    asil_interface: default is nac_eth2
    ...    target_file_name: default is l1l2bip_log_rimrs_detection
    ...    mirroring_filter: – Optional, [Default | AllMessages | SpecificL1L2Messages]. Only supported when
    ...                           interface is ‘L1-L2’ and destination is ‘Local’. Only available from SBTS24R1 onwards.
    ...    specific_message_ids: – Optional, only supported when mirroring_filter is ‘SpecificL1L2Messages’.
    ...                           string using comma separate. Must be in hex format. e.g: 0xe24e,0xe24f, message id from SW event
    [Arguments]    ${capture_time}=3 sec    ${special_slot_list}=${SPECIAL_SLOT_LIST}
    ...    ${filter}=UlData_rimReceiveReqSubcell_t.rimRsDetectionRequest == 1    ${target_file_name}=l1l2bip_log_rimrs_detect
    ...    ${mirroring_filter}=SpecificL1L2Messages    ${specific_message_ids}=${MESSAGE_ID_RIM_RECEIVE_REQ},${MESSAGE_ID_RIM_RECEIVE_RSPS}
    ...    ${detection_disable_ul_slot_list}=${False}    ${rimrs_enable_slot_list}=${False}
    Connect to Common Unit Master
    ${bip_log}    Collect Bip logs and Return Files Path    target_file_name=${target_file_name}    capture_time=${capture_time}
    ...    mirroring_filter=${mirroring_filter}    specific_message_ids=${specific_message_ids}

    Check sloppingBased RimRs Detection enable from Bip     log_path=${bip_log[0]}
                                    ...    special_slot_list=${special_slot_list}
                                    ...    filter=${filter}
                                    ...    detection_disable_ul_slot_list=${detection_disable_ul_slot_list}

	run keyword if    ${rimrs_enable_slot_list}!=${False}    Check staticWindow RimRs Detection enable from Bip
	...    log_path=${bip_log[0]}    rimrs_enable_slot_list=${rimrs_enable_slot_list}

Captrue bip logs and Check RimRs Detection disable
    [Documentation]    Author: Wang Yixiang
    ...    Description:  Captrue bip logs and check rimrsdetection equals to true from uldata_rimreceivereq
    ...    capture_time:             start capture, and wait for some time, then stop
    ...    special_slot_list:        special slot list for different frame structure
    ...    filter:      default value is uldata_rimreceivereq
    ...    asil_interface: default is nac_eth2
    ...    target_file_name: default is l1l2bip_log_rimrs_detection
    ...    mirroring_filter: – Optional, [Default | AllMessages | SpecificL1L2Messages]. Only supported when
    ...                           interface is ‘L1-L2’ and destination is ‘Local’. Only available from SBTS24R1 onwards.
    ...    specific_message_ids: – Optional, only supported when mirroring_filter is ‘SpecificL1L2Messages’.
    ...                           string using comma separate. Must be in hex format. e.g: 0xe24e,0xe24f, message id from SW event
    [Arguments]    ${capture_time}=3 sec    ${specific_message_ids}=${MESSAGE_ID_RIM_RECEIVE_REQ},${MESSAGE_ID_RIM_RECEIVE_RSPS}
    ...    ${target_file_name}=l1l2bip_log_rimrs_detect
    ...    ${mirroring_filter}=SpecificL1L2Messages
    Connect to Common Unit Master

    ${bip_log}    Collect Bip logs and Return Files Path    target_file_name=${target_file_name}    capture_time=${capture_time}
    ...    mirroring_filter=${mirroring_filter}    specific_message_ids=${specific_message_ids}

    Check new detection is disabled     log_path=${bip_log[0]}


Check sloppingBased RimRs Detection enable from Bip
    [Documentation]    Author: Cheng Catherine
    ...    Description:  check uldata_rimreceivereq received on special slot from Bip
    ...    log_path:    bip log path
    ...    special_slot_list:        special slot list for different frame structure
    ...    filter:      default value is uldata_rimreceivereq
    [Arguments]    ${log_path}    ${special_slot_list}=${SPECIAL_SLOT_LIST}
    ...    ${filter}=UlData_rimReceiveReqSubcell_t.rimRsDetectionRequest == 1    ${detection_disable_ul_slot_list}=${False}
    ${rim_rs_detection_request}    set variable    ${False}
    FOR   ${slot}    IN     @{special_slot_list}
        ${1st_UL_slot}    evaluate     ${slot}+${1}
        ${2nd_UL_slot}    evaluate    ${slot}+${2}
        ${filter_slot}    set variable     (3gpp.slot == ${slot} || 3gpp.slot == ${1st_UL_slot} || 3gpp.slot == ${2nd_UL_slot})
        pcap.setup    infile=${log_path}    display_filter=${filter} && ${filter_slot}
        sleep    1s
        ${result}    pcap.get_field_value_by_name   field_name=UlData_rimReceiveReqSubcell_t.rimRsDetectionRequest
                                            ...    attribute_name=show
        ${count}    Get Length    ${result}
        ${rim_rs_detection_request}    set variable if   ${count}>5    ${True}    ${rim_rs_detection_request}
    END
    should be true    ${rim_rs_detection_request}

    run keyword if    ${detection_disable_ul_slot_list}!=${False}    Check new detection is disabled per slot
    ...    log_path=${log_path}    ul_slot_list=${detection_disable_ul_slot_list}

Check staticWindow RimRs Detection enable from Bip
    [Documentation]    Author: Wang Yixiang
    ...    Description:  check uldata_rimreceivereq received on special slot from Bip
	...    staticWindow means rsDetectionWindow is "special+UL slots" or "special+2UL slots"
    ...    log_path:    bip log path
    ...    rimrs_enable_slot_list:   slot list which RIM RS detection is enabled.
    ...    filter:      default value is uldata_rimreceivereq
    [Arguments]    ${log_path}    ${rimrs_enable_slot_list}
    ...    ${filter}=UlData_rimReceiveReqSubcell_t.rimRsDetectionRequest == 1
    ${rim_rs_detection_request}    set variable    ${False}
    FOR   ${slot}    IN     @{rimrs_enable_slot_list}
        ${filter_slot}    set variable     3gpp.slot == ${slot}
        pcap.setup    infile=${log_path}    display_filter=${filter} && ${filter_slot}
        sleep    1s
        ${result}    pcap.get_field_value_by_name   field_name=UlData_rimReceiveReqSubcell_t.rimRsDetectionRequest
                                            ...    attribute_name=show
        ${count}    Get Length    ${result}
        ${rim_rs_detection_request}    set variable if   ${count}>5    ${True}    ${rim_rs_detection_request}
    END
    should be true    ${rim_rs_detection_request}

Check new detection is disabled
    [Documentation]    Author: Wang Yixiang
    ...    Description:  filter:When RI disappear(7525 disappeared), new detection is disable in next RIM-RS period,
    ...    the detection of existing RIM-RS still ongoing, after 1st PT of 7525 disappeared, suspected setid position still monitored
    ...    after 2nd PT of 7525 disappeared, only real rim-rs position monitored, not monitor suspected position.
    ...    log_path:    bip log path
    ...    filter:      UlData_rimReceiveReqSubcell_t.rimRsDetectionRequest == 1
    [Arguments]    ${log_path}    ${filter}=UlData_rimReceiveReqSubcell_t.rimRsDetectionRequest == 1
    ${rim_rs_detection_request}    set variable    ${False}
    pcap.setup    infile=${log_path}    display_filter=${filter}
    sleep    1s
    ${result}    pcap.get_field_value_by_name   field_name=UlData_rimReceiveReqSubcell_t.rimRsDetectionRequest
                                            ...    attribute_name=show
    ${count}    Get Length    ${result}

    ${rim_rs_detection_request}    set variable if   ${count}==${0}    ${True}    ${rim_rs_detection_request}
    should be true    ${rim_rs_detection_request}


Check new detection is disabled per slot
    [Documentation]    Author: Wang Yixiang
    ...    Description:  filter:When RI disappear(7525 disappeared), new detection is disable in next RIM-RS period,
    ...    the detection of existing RIM-RS still ongoing, after 1st PT of 7525 disappeared, suspected setid position still monitored
    ...    after 2nd PT of 7525 disappeared, only real rim-rs position monitored, not monitor suspected position.
    ...    log_path:    bip log path
    ...    filter:      UlData_rimReceiveReqSubcell_t.rimRsDetectionRequest == 1
    [Arguments]    ${log_path}    ${ul_slot_list}    ${filter}=UlData_rimReceiveReqSubcell_t.rimRsDetectionRequest == 1
    ${rim_rs_detection_request}    set variable    ${False}
    FOR    ${slot}   IN    @{ul_slot_list}
        pcap.setup    infile=${log_path}    display_filter=${filter} && 3gpp.slot == ${slot}
        sleep    1s
        ${result}    pcap.get_field_value_by_name   field_name=UlData_rimReceiveReqSubcell_t.rimRsDetectionRequest
                                            ...    attribute_name=show
        ${count}    Get Length    ${result}
        ${rim_rs_detection_request}    set variable if   ${count}==${0}    ${True}    ${rim_rs_detection_request}
        should be true    ${rim_rs_detection_request}
    END

Check enough and not enough from bip
    [Documentation]    Author: Wang Yixiang
    ...    Description:  When RI is detected and Enough Indication is enabled on gNB,
    ...                         RS1 will be transmitted with RIM-RS sequence index belonging to [0, #(rsType1NScId)/2-1].
    ...                  When RI disappears, RS1 will be transmitted with RIM-RS sequence index belonging to [#(rsType1NScId)/2, #(rsType1NScId)-1].
    ...    log_path:    bip log path
    ...    enough_indicator:      ${ENOUGH}, ${NOT_ENOUGH}, ${None}
    [Arguments]    ${log_path}    ${enough_indicator}    ${rsType1NScId}   ${rsType2NScId}    ${filter}=dldata_rimrssendreq
    pcap.setup    infile=${log_path}    display_filter=${filter}
    sleep    1s
    ${nscid_log}    pcap.get_field_value_by_name   field_name=DlData_RimRsSendReq_t.nscID
                                        ...    attribute_name=show
    ${nscid_log}   remove duplicates    ${nscid_log}
    should not be empty    ${nscid_log}    nscid list from bip log is empty!!

    FOR  ${nscid}  IN   @{nscid_log}
        ${status}   Run keyword and return status    List Should Contain Value    ${rsType2NScId}    ${nscid}
        run keyword if    ${status}==${True}   Remove Values From List    ${nscid_log}    ${nscid}
    END

    ${list_len}    Get Length    ${rsType1NScId}
    ${list_half_len}    evaluate     ${list_len}/2
    ${rsType1NScId_not_enough_list}    Get Slice From List	${rsType1NScId}   start=0   end=${list_half_len}
    ${rsType1NScId_enough_list}    Get Slice From List	${rsType1NScId}   start=${list_half_len}   end=${list_len}
    run keyword if    '${enough_indicator}'=='${ENOUGH}'     List Should Contain Sub List
    ...    ${rsType1NScId_enough_list}    ${nscid_log}    msg=When RI not exist, nscid should be in second half of rsType1NScId
    run keyword if    '${enough_indicator}'=='${NOT_ENOUGH}'     List Should Contain Sub List
    ...    ${rsType1NScId_not_enough_list}    ${nscid_log}    msg=When RI exist, nscid should be in first half of rsType1NScId


Captrue bip logs and Check RimRs Sent on Special or DL Slot by Victim
    [Documentation]   Author: Cheng Catherine
    ...    Captrue bip logs and check dldata_rimrssendreq on Special or DL Slot by Victim from Bip
    ...    for Repetition N
    ...    Check dldata_rimrssendreq is sent on correct slot
    ...    1. for near only, dldata_rimrssendreq only sent on the N special slots
    ...    2. for near-far config1, former N/2 dldata_rimrssendreq sent on special slots,
    ...     and later N/2 sent on DL(1 preceding slot)
    ...    3. for near-far config2, former N/2 dldata_rimrssendreq sent on special slots,
    ...     and later N/2 sent on DL(2 preceding slot)
    ...    Check start symbol on special slot or DL slot is correct
    ...    1. check start symbol on special slot is 8, for DL slot is 12 during one SFN for 1070 or 1208
    ...    2. check start symbol on special slot is 4, for DL slot is 12 during one SFN for 1116 4GP
    ...    3. check start symbol on special slot is 2, for DL slot is 12 during one SFN for 1116 6GP
    ...    framestructure:        special slot list for different frame structure
    ...    near_far:        special slot list for different frame structure
    ...    repetition:        special slot list for different frame structure
    ...    special_slot_list:        special slot list for different frame structure
    ...    transmission_window:      RIMRS transmission window on victim side
    ...    asil_interface: default is nac_eth2
    ...    target_file_name: default is l1l2bip_log_rimrs_sent
    ...    connection_victim:   default is ${OAM_ALIAS_GNB1}
    ...    du_index: default is 0
    ...    gnb_index: default is 1 cause this is vivtim gnb
    ...    mirroring_filter: – Optional, [Default | AllMessages | SpecificL1L2Messages]. Only supported when
    ...                           interface is ‘L1-L2’ and destination is ‘Local’. Only available from SBTS24R1 onwards.
    ...    specific_message_ids: – Optional, only supported when mirroring_filter is ‘SpecificL1L2Messages’.
    ...                           string using comma separate. Must be in hex format. e.g: 0xe118,0xe113, message id from SW event
    [Arguments]    ${framestructure}     ${near_far}    ${repetition}    ${transmission_window}
    ...    ${target_file_name}=l1l2bip_log_rimrs_sent
    ...    ${connection_victim}=${OAM_ALIAS_GNB1}    ${du_index}=${0}    ${gnb_index}=${1}
    ...    ${mirroring_filter}=SpecificL1L2Messages
    ...    ${specific_message_ids}=${MESSAGE_ID_RIM_SENT_REQ}
    Connect to Common Unit Master     du_index=${du_index}    alias=${connection_victim}    gnb_index=${gnb_index}

    ${bip_log}    Collect Bip logs and Return Files Path    target_file_name=${target_file_name}    capture_time=${transmission_window}
    ...    mirroring_filter=${mirroring_filter}    specific_message_ids=${specific_message_ids}    gnb_index=${gnb_index}

    Check RimRs Sent on Special or DL Slot by Victim from Bip     log_path=${bip_log[0]}
                                                            ...    framestructure=${framestructure}
                                                            ...    near_far=${near_far}
                                                            ...    repetition=${repetition}

Captrue bip logs and Check RimRs Sent enough and not enough
    [Documentation]   Author: Wang Yixiang
    ...    Captrue bip logs and check dldata_rimrssendreq on Special or DL Slot by Victim from Bip
    ...    framestructure:        special slot list for different frame structure
    ...    near_far:        special slot list for different frame structure
    ...    repetition:        special slot list for different frame structure
    ...    special_slot_list:        special slot list for different frame structure
    ...    transmission_window:      RIMRS transmission window on victim side
    ...    asil_interface: default is nac_eth2
    ...    target_file_name: default is l1l2bip_log_rimrs_sent
    ...    connection_victim:   default is ${OAM_ALIAS_GNB1}
    ...    du_index: default is 0
    ...    gnb_index: default is 1 cause this is vivtim gnb
    ...    mirroring_filter: – Optional, [Default | AllMessages | SpecificL1L2Messages]. Only supported when
    ...                           interface is ‘L1-L2’ and destination is ‘Local’. Only available from SBTS24R1 onwards.
    ...    specific_message_ids: – Optional, only supported when mirroring_filter is ‘SpecificL1L2Messages’.
    ...                           string using comma separate. Must be in hex format. e.g: 0xe118,0xe113, message id from SW event
    [Arguments]    ${transmission_window}=3min
    ...    ${target_file_name}=l1l2bip_log_rimrs
    ...    ${connection_victim}=${OAM_ALIAS_GNB0}    ${du_index}=${0}    ${gnb_index}=${0}
    ...    ${mirroring_filter}=SpecificL1L2Messages
    ...    ${specific_message_ids}=${MESSAGE_ID_RIM_SENT_REQ}
    ...    ${enough_indicator}=${None}    ${rsType1NScId}=${False}    ${rsType2NScId}=${False}

    Connect to Common Unit Master     du_index=${du_index}    alias=${connection_victim}    gnb_index=${gnb_index}
    ${bip_log}    Collect Bip logs and Return Files Path    target_file_name=${target_file_name}   capture_time=${transmission_window}
    ...    mirroring_filter=${mirroring_filter}    specific_message_ids=${specific_message_ids}    gnb_index=${gnb_index}

    run keyword and continue on failure    Check enough and not enough from bip    log_path=${bip_log[0]}   enough_indicator=${enough_indicator}
    ...    rsType1NScId=${rsType1NScId}    rsType2NScId=${rsType2NScId}


Check RimRs Sent on Special or DL Slot by Victim from Bip
    [Documentation]   Author: Cheng Catherine
    ...    check dldata_rimrssendreq on Special or DL Slot by Victim from Bip for Repetition N
    ...    check dldata_rimrssendreq is sent on correct slot
    ...    1. for near only, dldata_rimrssendreq only sent on the N special slots
    ...    2. for near-far config1, former N/2 dldata_rimrssendreq sent on special slots,
    ...     and later N/2 sent on DL(1 preceding slot)
    ...    3. for near-far config2, former N/2 dldata_rimrssendreq sent on special slots,
    ...     and later N/2 sent on DL(2 preceding slot)
    ...    check start symbol on special slot or DL slot is correct
    ...    1. check start symbol on special slot is 8, for DL slot is 12 during one SFN for 1070 or 1208
    ...    2. check start symbol on special slot is 4, for DL slot is 12 during one SFN for 1116 4GP
    ...    3. check start symbol on special slot is 2, for DL slot is 12 during one SFN for 1116 6GP
    ...    log_path:        bip log path
    ...    framestructure:        special slot list for different frame structure
    ...    near_far:        special slot list for different frame structure
    ...    repetition:        special slot list for different frame structure
    [Arguments]    ${log_path}    ${framestructure}     ${near_far}    ${repetition}
    ${rimrs_send_config_list}    6991_rim_rs.Get Rim Rs Sent Config List    ${framestructure}    ${near_far}
                                                                    ...    ${repetition}
    _Check dldata_rimrssendreq Sent Correctly from Bip     ${log_path}    ${rimrs_send_config_list}


_Check dldata_rimrssendreq Sent Correctly from Bip
    [Documentation]   check dldata_rimrssendreq on Special or DL Slot by Victim from Bip
    [Arguments]    ${log_path}    ${rimrs_send_config_list}
    ${first_slot}    set variable    ${rimrs_send_config_list[0]["slot"]}
    pcap.setup    infile=${log_path}    display_filter=dldata_rimrssendreq && 3gpp.slot == ${first_slot}
    sleep    1s
    ${sfns}    pcap.get_field_value_by_name   field_name=3gpp.sfn    attribute_name=show
    should not be empty   ${sfns}
    FOR   ${rimrs_send_config}    IN     @{rimrs_send_config_list}
        ${sfn_to_check}    evaluate    ${sfns[1]}-${rimrs_send_config["sfn_offset"]}
        ${slot}    set variable   ${rimrs_send_config["slot"]}
        pcap.setup   infile=${log_path}   display_filter=dldata_rimrssendreq && 3gpp.slot==${slot} && 3gpp.sfn==${sfn_to_check}
        sleep    1s
        ${start_symbol}    pcap.get_field_value_by_name   field_name=DlData_RimRsSendReq_t.startSymbol
                                                    ...     attribute_name=show
        should be equal as integers    ${start_symbol}    ${rimrs_send_config["start_symbol"]}
    END



Check no DL Mitigation from Fault When RI Happen
    [Documentation]    Author: Cheng Catherine
    ...    Description:  Check no DL Mitigation When RI Happen by:
    ...    1) Fault should not contain DL mitigation info
    ...    2) DL and Special slot should be scheduled from bip ->remove this step, as when no mitigation, UE attach will fail
    ...    3) check from history alarm, should not contain 7525 or 7527
    ...    supplementary:               supplementary alarm information should contain
    ...    supplementary_not_contain:   supplementary alarm information should not contain
    [Arguments]   ${supplementary}    ${supplementary_not_contain}    ${supplementary_7535}=${None}

    run keyword and continue on failure    Wait and Verify Fault Present on Cells    faultId=7525
                                                                    ...    alarm_check_timeout=2m
                                                                    ...    alarm_check_interval=10sec
    # wait and check fault 7527 info changed
    run keyword and continue on failure    Wait and Verify Fault Present on Cells    faultId=7527
                                                        ...    alarm_check_timeout=10m
                                                        ...    alarm_check_interval=10sec
                                                        ...    supplementary=${supplementary}
                                                        ...    supplementary_not_contain=${supplementary_not_contain}

    run keyword and continue on failure    run keyword if   '${PROGRAM}'>='24R3' and '${supplementary_7535}'!='${None}'
    ...    Wait and Verify Fault 7535 not Present on Cells

    # check from history alarm, should not contain 7525 or 7527
    run keyword and continue on failure    Expect Fault Present or not from History List on Cells
                                                        ...    faultId=7525
                                                        ...    expect_present=${False}
    run keyword and continue on failure    Expect Fault Present or not from History List on Cells
                                                        ...    faultId=7527
                                                        ...    supplementary=${supplementary}
                                                        ...    expect_present=${False}
    run keyword and continue on failure    run keyword if   '${PROGRAM}'>='24R3' and '${supplementary_7535}'!='${None}'
    ...    Expect Fault Present or not from History List on Cells    faultId=7535
                                                            ...    expect_present=${True}
                                                            ...    supplementary=${supplementary_7535}

Get tput details for cell
    [Documentation]    Get tput details for cell
    ...    Author: Wang Yixiang
    [Arguments]    ${cell_id}    ${tput_log}    ${connection}=GNB_OAM   ${cell_mapping}=${CELL_MAPPING}
    ${list_cell_index}    string2list    ${cell_id}
    @{list_nrCellIdentity}    _Get nrCellIdentity based on cell index    list_cell_index=${list_cell_index}    connection=${connection}
    ...    cell_mapping=${cell_mapping}

    ${ul_tput}    ${record}    aastp.get_aasyslog_throughput
    ...                            direction=ul    log=${tput_log}    cells=${list_nrCellIdentity}
    ...                            actCarrierAggregation=${False}

    ${dl_tput}    ${record}    aastp.get_aasyslog_throughput
    ...                            direction=dl    log=${tput_log}    cells=${list_nrCellIdentity}
    ...                            actCarrierAggregation=${False}
    ${ul_avg_tput}   set variable   ${ul_tput[0]['average']}
    ${dl_avg_tput}   set variable   ${dl_tput[0]['average']}
    ${avg_tput}    Create Dictionary    DL=${dl_avg_tput}    UL=${ul_avg_tput}
    [Return]    ${avg_tput}

L3 call and check tput for each cell
    [Documentation]    L3 call and check tput for each cell
    ...    Author: Cheng Catherine
    [Arguments]    ${cell_id}    ${dl_tput}    ${exp_dl}    ${ul_tput}    ${exp_ul}    ${duration_time}=1200
    ...    ${tput_check_duration}=30s     ${data_transfer_direction}=both    ${prepare_ue_needed}=${False}
    ...    ${customized_log_name}=L3 Call    ${target_avg_percent}=${TARGET_AVG_PERCENT}    ${min_percent}=${MIN_PERCENT}
    ...    ${ignore_time}=30s    ${filter}=L2Lo    ${before_ri}=${False}    ${after_ri}=${False}
    ...    ${exp_dl_tput_gap}=5    ${exp_ul_tput_gap}=3   ${tput_check}=${true}
    L3 call and Start Traffic    dl_tput=${dl_tput}    ul_tput=${ul_tput}    duration=${duration_time}
    ...    data_transfer_direction=${data_transfer_direction}    prepare_ue_needed=${prepare_ue_needed}
    run keyword and ignore error    check iperf process on appserver
    ${tput_log}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=${tput_check_duration}
    ...        ignore_time=${ignore_time}    filter=${filter}    check_source=Aasyslog
    run keyword and ignore error    check iperf process on appserver
    run keyword and continue on failure   run keyword if    ${tput_check}  Check tput via power UE optimized
                                                                ...    cell_index=${cell_id}
                                                                ...    exp_ul=1
                                                                ...    exp_dl=1
                                                                ...    tput_log_path=${tput_log}
                                                                ...    direction=both
                                                                ...    customized_log_name=${customized_log_name}
                                                                ...    exp_ul_indiv=${exp_ul}
                                                                ...    exp_dl_indiv=${exp_dl}
                                                                ...    is_analysis_log_captured=${False}
                                                                ...    target_avg_percent=${target_avg_percent}
                                                                ...    min_percent=${min_percent}

    run keyword if    ${before_ri}    Set test variable before RI    cell_id=${cell_id}    tput_log=${tput_log}
    run keyword if    ${after_ri}   Compare tput of before RI and after RI
    ...    cell_id=${cell_id}    tput_log=${tput_log}   avg_tput_before_ri=${avg_tput_before_ri}
    ...    exp_dl_tput_gap=${exp_dl_tput_gap}    exp_ul_tput_gap=${exp_ul_tput_gap}

Compare tput of before RI and after RI
    [Documentation]     Compare tput of before RI and after RI
    ...    Author: Wang Yixiang
    [Arguments]    ${cell_id}    ${tput_log}   ${avg_tput_before_ri}    ${exp_dl_tput_gap}=5    ${exp_ul_tput_gap}=3
    ${avg_tput_after_ri}    Get tput details for cell    cell_id=${cell_id}    tput_log=${tput_log}
    ${real_dl_tput_gap}    Evaluate    ${avg_tput_before_ri['DL']}-${avg_tput_after_ri['DL']}
    ${real_ul_tput_gap}    Evaluate    ${avg_tput_before_ri['UL']}-${avg_tput_after_ri['UL']}
    ${dl_tput_check_status}    Evaluate    int(math.fabs(${real_dl_tput_gap}))<=${exp_dl_tput_gap}     modules=math
    ${ul_tput_check_status}    Evaluate    int(math.fabs(${real_ul_tput_gap}))<=${exp_ul_tput_gap}     modules=math
    Should be true     ${dl_tput_check_status}     DL tput gap is bigger than ${exp_dl_tput_gap}M of before RI and after RI
    Should be true     ${ul_tput_check_status}     UL tput gap is bigger than ${exp_ul_tput_gap}M of before RI and after RI

Set test variable before RI
    [Documentation]     Set test variable before RI
    ...    Author: Wang Yixiang
    [Arguments]    ${cell_id}    ${tput_log}
    ${avg_tput_before_ri}    Get tput details for cell    cell_id=${cell_id}    tput_log=${tput_log}
    set test variable   ${avg_tput_before_ri}

L3 call and Start Traffic
    [Documentation]     make L3 call and Start Traffic with DL and UL traffic
    ...    Author: Cheng Catherine
    [Arguments]    ${dl_tput}    ${ul_tput}    ${duration}=1200     ${data_transfer_direction}=both
    ...    ${prepare_ue_needed}=${False}
    Retry commercial ue attach if failed    prepare_ue_needed=${prepare_ue_needed}
    Start data transfer based on direction    dl_tput=${dl_tput}    ul_tput=${ul_tput}    duration=${duration}
    ...    data_transfer_direction=${data_transfer_direction}


Check RI or RS status from aasyslog
    [Documentation]    Author: Cheng Catherine
    ...    Description: check isRiDetected:1 or isRsDetected:1 from syslog
    [Arguments]    ${isRiDetected}    ${isRs1Detected}    ${isRs2Detected}=${False}   ${log_name}=RI_status.txt    ${type}=MCU    ${duration}=300s
    ${log_path}    Capturing Aasyslog with duration    log_name=${log_name}    type=${type}
                                                ...    filter=rim    duration=${duration}
    ${RI_status}    Grep File    ${log_path}    isRiDetected:1
    ${RS1_status}    Grep File    ${log_path}    isRs1Detected:1
    ${RS2_status}    Grep File    ${log_path}    isRs2Detected:1
    run keyword if     ${isRiDetected}==${True}    Should Not Be Empty    ${RI_status}
    run keyword if     ${isRs1Detected}==${True}    Should Not Be Empty    ${RS1_status}
    run keyword if     ${isRs2Detected}==${True}    Should Not Be Empty    ${RS2_status}


Start Capture PCMD with filter port
    [Documentation]    Author: Cheng Catherine
    ...    Description:  Start capture pcmd with filter -i any tcp
    [Arguments]   ${tcpdump_collector_name}    ${port}=${TCE_PORT}
    Start capture F1AP log    tcpdump_collector_name=${tcpdump_collector_name}    options=-i any port ${port}


Stop Tcpdump and Check RI info from PCMD log
    [Documentation]    Author: Cheng Catherine
    ...    Description:  Steps Stop Tcpdump and Check RI infofrom PCMD log
    ...    1. Stop Tcpdump
    ...    2. Check RI info in PCMD log, UL_SYMBOL_RI_LIST and UL_drop_height_list
    [Arguments]   ${ri_monitor_special_slot_list}    ${ri_monitor_ul_slot_list}    ${tcpdump_collector_name}=CB0010437_PCMD_RI
    ${ute_log_path_pcmd}    Stop tcpdump log collection    tcpdump_collector_name=${tcpdump_collector_name}
    ${filter_RI}    set variable     ${FILTER_PCMD_RI}
#    ${filter_RI}    set variable if    '${PROGRAM}'>='25R1'    ${FILTER_PCMD_RI_25R1}     ${FILTER_PCMD_RI}
    run keyword and continue on failure   Check RI Measurement record from PCMD log    log_file_path=${ute_log_path_pcmd}
                                                            ...    ri_monitor_special_slot_list=${ri_monitor_special_slot_list}
                                                            ...    ri_monitor_ul_slot_list=${ri_monitor_ul_slot_list}
                                                            ...    display_filter=${filter_RI}


Stop Tcpdump and Check RIMRS info from PCMD log
    [Documentation]    Author: Cheng Catherine
    ...    Description:  Steps Stop Tcpdump and Check RIMRS info from PCMD log
    ...    1. Stop Tcpdump
    ...    2. Check RIMRS info in PCMD log, rimrs_setid, rimrs_max_power and repetition
    [Arguments]   ${SetId_Aggressor}    ${repetitionRsType1}=${None}     ${repetitionRsType2}=${None}     ${tcpdump_collector_name}=CB0010437_PCMD
    ...     ${repetition1_no_check}=${0}    ${repetition2_no_check}=${0}    ${feature}=6991    ${near_far}=${False}    ${check_enough}=${False}
    ...     ${enough_indicator_monitor}=${None}     ${enough_verdict_monitor}=${None}    ${enough_indicator_transmit}=${None}
    ...     ${check_repetition}=${True}
    ${ute_log_path_pcmd}    Stop tcpdump log collection    tcpdump_collector_name=${tcpdump_collector_name}
    run keyword and continue on failure    Check RIMRS Monitoring Record from PCMD log    log_file_path=${ute_log_path_pcmd}
                                                            ...    rimrs_setid=${SetId_Aggressor}
                                                            ...    repetitionRsType1=${repetitionRsType1}
                                                            ...    repetitionRsType2=${repetitionRsType2}
                                                            ...    repetition1_no_check=${repetition1_no_check}
                                                            ...    repetition2_no_check=${repetition2_no_check}
															...    feature=${feature}
                                                            ...    near_far=${near_far}
                                                            ...    check_repetition=${check_repetition}
                                                            ...    check_enough=${check_enough}
                                                            ...    enough_indicator=${enough_indicator_monitor}
                                                            ...    enough_verdict=${enough_verdict_monitor}
    run keyword and continue on failure    run keyword if    ${check_enough} and '${feature}'=='9823'   Check RIMRS Transmission Record from PCMD log
                                                            ...    log_file_path=${ute_log_path_pcmd}
                                                            ...    enough_indicator=${enough_indicator_transmit}


Stop Tcpdump and Check no RI or RIMRS info from PCMD log
    [Documentation]    Author: Cheng Catherine
    ...    Description:  Stop Tcpdump and Check no RI or RIMRS info from PCMD log
    ...    1. Stop Tcpdump
    ...    2. Check no RI or RIMRS info in PCMD log
    [Arguments]   ${tcpdump_collector_name}=CB0010437_PCMD_stop
    ${ute_log_path_pcmd}    Stop tcpdump log collection    tcpdump_collector_name=${tcpdump_collector_name}
    run keyword and continue on failure    Check no RI Measurement Record from PCMD log    log_file_path=${ute_log_path_pcmd}
    run keyword and continue on failure    Check no RIMRS Transmission Record from PCMD log    log_file_path=${ute_log_path_pcmd}
    run keyword and continue on failure    Check no RIMRS Monitoring Record from PCMD log    log_file_path=${ute_log_path_pcmd}


Check no RI Measurement Record from PCMD log
    [Documentation]   author: Cheng Catherine
    ...    Check no RI Measurement Record from PCMD log
    [Arguments]    ${log_file_path}    ${alias}=check_no_ri
    ${display_filter_ri}    set variable    ${FILTER_PCMD_RI}
    pcap.setup    infile=${log_file_path}    display_filter=${display_filter_ri}    alias=${alias}
    ${UL_symbol_RI_list}    pcap.get_field_value_by_xpath    xpath=${UL_SYMBOL_RI_LIST_XPATH}    pcap_parser=${alias}
    should be empty    ${UL_symbol_RI_list}


Check RI Measurement Record from PCMD log
    [Documentation]   author: Xian Jiang
    ...    Check RI Measurement Record from PCMD log, UL_SYMBOL_RI_LIST and UL_drop_height_list
    ...    Need to download plugin nsetapx, copy nsetapx-3.2-1.0.0+buster.so to /usr/lib/x86_64-linux-gnu/wireshark/plugins/3.6/epan
    ...    guide: https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1370150863
    ...    and add TCP ports(tcePortNumber on gnb side) to wireshark(Editor->Preferences->Protocols->ntrstr->TCP Ports)
    [Arguments]    ${log_file_path}    ${ri_monitor_special_slot_list}     ${ri_monitor_ul_slot_list}
    ...    ${display_filter}=${FILTER_PCMD_RI}    ${alias}=check_RI
    pcap.setup    infile=${log_file_path}    display_filter=${display_filter}    alias=${alias}
    ${UL_symbol_RI_list}    pcap.get_field_value_by_xpath    xpath=${UL_SYMBOL_RI_LIST_XPATH}    pcap_parser=${alias}
    ${UL_drop_height_list}    pcap.get_field_value_by_xpath    xpath=${UL_DROP_HEIGHT_LIST_XPATH}    pcap_parser=${alias}
    ${UL_symbol_RI_list_new}   remove duplicates    ${UL_symbol_RI_list}
    ${UL_drop_height_list_new}   remove duplicates    ${UL_drop_height_list}
    Check UL impact on Special and UL slot   ${UL_symbol_RI_list_new}   ${UL_drop_height_list_new}    ${ri_monitor_special_slot_list}
                                    ...    ${ri_monitor_ul_slot_list}

Check no RIMRS Transmission Record from PCMD log
    [Documentation]   author: Cheng Catherine
    ...    Check no RIMRS Transmission Record from PCMD log for CB006991
    [Arguments]    ${log_file_path}    ${alias}=check_no_RIMRS_transmit
    ${display_filter_rs1}    set variable    ${FILTER_PCMD_RIMRS1_TRANSMIT_FW1}
    pcap.setup    infile=${log_file_path}    display_filter=${display_filter_rs1}    alias=${alias}
    ${rimrs_transmit_list}    pcap.get_field_value_by_xpath    xpath=${RIMRS_TRANSMIT_XPATH}    pcap_parser=${alias}
    should be empty    ${rimrs_transmit_list}


Check RIMRS Transmission Record from PCMD log
    [Documentation]   author: Cheng Catherine
    ...    Check RIMRS Transmission Record from PCMD log, e.g.
    ...    RIM-RS Transmission Trace Record
    ...    RIM-RS Type = RS type1
    ...    RIM-RS Repetition List
    ...    Repetition Index
    ...    enoughIndicator = enough or not enough(only for rimrs type 1)
    ...    Need to download plugin nsetapx, copy nsetapx-3.2-1.0.0+buster.so to /usr/lib/x86_64-linux-gnu/wireshark/plugins/3.6/epan
    ...    guide: https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1370150863
    ...    and add TCP ports(tcePortNumber on gnb side) to wireshark(Editor->Preferences->Protocols->ntrstr->TCP Ports)
    [Arguments]    ${log_file_path}    ${enough_indicator}         ${alias}=check_RIMRS_transmit
    ${display_filter_rs1}    set variable    ${FILTER_PCMD_RIMRS1_TRANSMIT_FW1}
    ${display_filter_rs2}    set variable    ${FILTER_PCMD_RIMRS2_TRANSMIT_FW1}
    Check RIMRS Transmission Record for dedicate rimrs type    log_file_path=${log_file_path}    display_filter=${display_filter_rs1}
    ...    rimrs_type=${1}    enough_indicator=${enough_indicator}    alias=${alias}
    Check RIMRS Transmission Record for dedicate rimrs type    log_file_path=${log_file_path}    display_filter=${display_filter_rs2}
    ...    rimrs_type=${2}    alias=${alias}


Check RIMRS Transmission Record for dedicate rimrs type
    [Documentation]   author: Cheng Catherine
    ...    Check RIMRS Transmission Record from PCMD log for dedicate rimrs type, e.g.
    ...    RIM-RS Transmission Trace Record
    ...    rimRsType = type1
    ...    rimRsTransmissionRepetitionList
    ...    repetitionIndex
    ...    enoughIndicator = enough or not enough
    ...    Need to download plugin nsetapx, copy nsetapx-3.2-1.0.0+buster.so to /usr/lib/x86_64-linux-gnu/wireshark/plugins/3.6/epan
    ...    guide: https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1370150863
    ...    and add TCP ports(tcePortNumber on gnb side) to wireshark(Editor->Preferences->Protocols->ntrstr->TCP Ports)
    [Arguments]    ${log_file_path}    ${display_filter}    ${rimrs_type}    ${enough_indicator}=${None}
    ...    ${alias}=check_RIMRS_transmit
    pcap.setup    infile=${log_file_path}    display_filter=${display_filter}    alias=${alias}
    ${rimrs_repetition_list}    pcap.get_field_value_by_xpath    xpath=${RIMRS_REPET_XPATH_TRANSMIT}    pcap_parser=${alias}
    ${rimrs_repetition_list_new}   remove duplicates    ${rimrs_repetition_list}
    ${count}    Get Length    ${rimrs_repetition_list_new}
    should be true    ${count}>${0}

    run keyword if   ${rimrs_type}==${1}     Check RIMRS Transmission RIMRS type1 Enough    expect_enough_indicator=${enough_indicator}
    ...    alias=${alias}
    run keyword if   ${rimrs_type}==${2}     Check RIMRS Transmission RIMRS type2 Enough    alias=${alias}


Check RIMRS Transmission RIMRS type1 Enough
    [Documentation]   author: Cheng Catherine
    ...    Check RIMRS type1 Enough
    ...    enoughIndicator = enough or not enough
    ...    Need to download plugin nsetapx, copy nsetapx-3.2-1.0.0+buster.so to /usr/lib/x86_64-linux-gnu/wireshark/plugins/3.6/epan
    ...    guide: https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1370150863
    ...    and add TCP ports(tcePortNumber on gnb side) to wireshark(Editor->Preferences->Protocols->ntrstr->TCP Ports)
    [Arguments]    ${expect_enough_indicator}    ${alias}
    ${enough_indicator_list}    pcap.get_field_value_by_xpath    xpath=${RIMRS_TYPE1_ENOUGH_IND_XPATH_TRANSMIT}    pcap_parser=${alias}
    ${enough_indicator_list_new}   remove duplicates    ${enough_indicator_list}
    ${expect_indicator_list}    Create List    ${expect_enough_indicator}
    lists_should_be_equal    ${enough_indicator_list_new}     ${expect_indicator_list}


Check RIMRS Transmission RIMRS type2 Enough
    [Documentation]   author: Cheng Catherine
    ...    Check RIMRS type2 without Enough/notEnough
    ...    Enough/notEnough Indicator = not enough or not enough
    ...    Need to download plugin nsetapx, copy nsetapx-3.2-1.0.0+buster.so to /usr/lib/x86_64-linux-gnu/wireshark/plugins/3.6/epan
    ...    guide: https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1370150863
    ...    and add TCP ports(tcePortNumber on gnb side) to wireshark(Editor->Preferences->Protocols->ntrstr->TCP Ports)
    [Arguments]    ${alias}
    ${enough_indicator_list}    pcap.get_field_value_by_xpath    xpath=${RIMRS_TYPE2_ENOUGH_IND_XPATH_TRANSMIT}    pcap_parser=${alias}
    ${count}    Get Length    ${enough_indicator_list}
    should be true    ${count}==${0}


Check no RIMRS Monitoring Record from PCMD log
    [Documentation]   author: Cheng Catherine
    ...    Check no RIMRS Monitoring Record from PCMD log for CB006991
    [Arguments]    ${log_file_path}    ${alias}=check_no_RIMRS_monitor
    ${display_filter_rs1}    set variable    ${FILTER_PCMD_RIMRS1_MONITOR_FW1}
    pcap.setup    infile=${log_file_path}    display_filter=${display_filter_rs1}    alias=${alias}
    ${rimrs_monitor_list}    pcap.get_field_value_by_xpath    xpath=${RIMRS_MONITOR_XPATH}    pcap_parser=${alias}
    should be empty    ${rimrs_monitor_list}


Check RIMRS Monitoring Record from PCMD log
    [Documentation]   author: Cheng Catherine
    ...    Check RIMRS Monitoring Record from PCMD log, rimrs_setid, rimrs_max_power and repetition
    ...    Need to download plugin nsetapx, copy nsetapx-3.2-1.0.0+buster.so to /usr/lib/x86_64-linux-gnu/wireshark/plugins/3.6/epan
    ...    guide: https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1370150863
    ...    and add TCP ports(tcePortNumber on gnb side) to wireshark(Editor->Preferences->Protocols->ntrstr->TCP Ports)
    ...    ${near_far} can be values ${False},near(only near detected),far(only far detected),both(near far both detected)
    [Arguments]    ${log_file_path}   ${rimrs_setid}    ${repetitionRsType1}    ${repetitionRsType2}=${None}
    ...           ${repetition1_no_check}=${0}    ${repetition2_no_check}=${0}
    ...           ${feature}=6991   ${near_far}=${False}    ${alias}=check_RIMRS_monitor    ${check_repetition}=${True}
    ...           ${check_enough}=${False}    ${enough_indicator}=${None}    ${enough_verdict}=${None}
    ${RIMRS1_filter}     Set variable if    '${PROGRAM}'<='24R2'    ${FILTER_PCMD_RIMRS1_MONITOR}    ${FILTER_PCMD_RIMRS1_MONITOR_FW1}
    ${RIMRS2_filter}     Set variable  ${FILTER_PCMD_RIMRS2_MONITOR_FW1}
    Check RIMRS Monitoring Record for dedicate rimrs type    log_file_path=${log_file_path}
                                                    ...    rimrs_setid=${rimrs_setid}
                                                    ...    repetitionRsType=${repetitionRsType1}
                                                    ...    display_filter=${RIMRS1_filter}
                                                    ...    rimrs_type=${1}
                                                    ...    repetition_no_check=${repetition1_no_check}
                                                    ...    near_far=${near_far}
                                                    ...    check_repetition=${check_repetition}
                                                    ...    check_enough=${check_enough}
                                                    ...    enough_indicator=${enough_indicator}
                                                    ...    enough_verdict=${enough_verdict}
                                                    ...    alias=${alias}_type1
    run keyword if   '${feature}'=='9823' and '${PROGRAM}'>'24R2'    Check RIMRS Monitoring Record for dedicate rimrs type
                                                    ...    log_file_path=${log_file_path}
                                                    ...    rimrs_setid=${rimrs_setid}
                                                    ...    repetitionRsType=${repetitionRsType2}
                                                    ...    display_filter=${RIMRS2_filter}
                                                    ...    rimrs_type=${2}
                                                    ...    repetition_no_check=${repetition2_no_check}
                                                    ...    check_repetition=${check_repetition}
                                                    ...    check_enough=${check_enough}
                                                    ...    near_far=${near_far}
                                                    ...    alias=${alias}_type2


Check RIMRS Monitoring Record for dedicate rimrs type
    [Documentation]   author: Cheng Catherine
    ...    Check RIMRS Monitoring Record from PCMD log for dedicate rimrs type, rimrs_setid, rimrs_max_power and repetition
    ...    Need to download plugin nsetapx, copy nsetapx-3.2-1.0.0+buster.so to /usr/lib/x86_64-linux-gnu/wireshark/plugins/3.6/epan
    ...    guide: https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1370150863
    ...    and add TCP ports(tcePortNumber on gnb side) to wireshark(Editor->Preferences->Protocols->ntrstr->TCP Ports)
    ...    ${near_far} can be values ${False},near(only near detected),far(only far detected),both(near far both detected)
    [Arguments]    ${log_file_path}   ${rimrs_setid}    ${repetitionRsType}     ${display_filter}    ${rimrs_type}
    ...        ${repetition_no_check}=${0}    ${near_far}=${False}    ${alias}=check_RIMRS
    ...        ${check_enough}=${False}    ${enough_indicator}=${None}    ${enough_verdict}=${None}
    ...        ${check_repetition}=${True}
    pcap.setup    infile=${log_file_path}    display_filter=${display_filter}    alias=${alias}
    ${RIMRS_SETID_XPATH_MONITOR}    Set variable if    '${PROGRAM}'<='24R2'    ${RIMRS_SETID_XPATH_MONITOR}    ${RIMRS_SETID_FW1_XPATH_MONITOR}
    ${RIMRS_POWER_XPATH_MONITOR}    Set variable if    '${PROGRAM}'<='24R2'   ${RIMRS_MAX_POWER_XPATH_MONITOR}   ${RIMRS_AVG_POWER_XPATH_NEW_MONITOR}
    ${rimrs_setid_log}    pcap.get_field_value_by_xpath    xpath=${RIMRS_SETID_XPATH_MONITOR}    pcap_parser=${alias}
    ${rimrs_setid_log}   remove duplicates    ${rimrs_setid_log}
    ${rimrs_setid}    Convert To String    ${rimrs_setid}
    ${rimrs_setid_list}   create list   ${rimrs_setid}
    Should Be Equal    ${rimrs_setid_log}    ${rimrs_setid_list}    Aggressor setid not same as expected in PCMD log, pls check.

    ${rimrs_max_power_list}    pcap.get_field_value_by_xpath    xpath=${RIMRS_POWER_XPATH_MONITOR}    pcap_parser=${alias}
    ${rimrs_max_power_list_new}   remove duplicates    ${rimrs_max_power_list}
    should not be empty    ${rimrs_max_power_list_new}    rimrs max power list from PCMD log is empty!!

    run keyword if   ${check_repetition}    Check RIMRS Repetion for dedicate rimrs type    ${repetitionRsType}   ${repetition_no_check}
    ...    ${near_far}    alias=${alias}
    run keyword if   '${near_far}'!='${False}'  Check RIMRS Monitoring Nearfar for dedicate rimrs type    ${near_far}    alias=${alias}
    run keyword if   ${check_enough}   Check RIMRS Monitoring Enough for dedicate rimrs type    rimrs_type=${rimrs_type}
    ...    expect_enough_indicator=${enough_indicator}    expect_enough_verdict=${enough_verdict}    alias=${alias}


Check RIMRS Monitoring Enough for dedicate rimrs type
    [Documentation]   author: Cheng Catherine
    ...    Check RIMRS Monitoring Enough for dedicate rimrs type, e.g.
    ...    rimRsMonitoringRecord
    ...    enoughIndicator = enough or not enough
    ...    enoughVerdict = enough or not enough
    ...    Need to download plugin nsetapx, copy nsetapx-3.2-1.0.0+buster.so to /usr/lib/x86_64-linux-gnu/wireshark/plugins/3.6/epan
    ...    guide: https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1370150863
    ...    and add TCP ports(tcePortNumber on gnb side) to wireshark(Editor->Preferences->Protocols->ntrstr->TCP Ports)
    [Arguments]    ${rimrs_type}    ${expect_enough_indicator}=${None}     ${expect_enough_verdict}=${None}     ${alias}=check_RIMRS_monitoring

    run keyword if  ${rimrs_type}==${1}   Check RIMRS Monitoring RIMRS type1 Enough   ${expect_enough_indicator}   ${expect_enough_verdict}  ${alias}
    run keyword if  ${rimrs_type}==${2}   Check RIMRS Monitoring RIMRS type2 Enough   ${alias}


Check RIMRS Monitoring RIMRS type1 Enough
    [Documentation]   author: Cheng Catherine
    ...    Check RIMRS type1 Enough
    ...    enoughIndicator = not enough or not enough
    ...    enoughVerdict = not enough or not enough
    ...    Need to download plugin nsetapx, copy nsetapx-3.2-1.0.0+buster.so to /usr/lib/x86_64-linux-gnu/wireshark/plugins/3.6/epan
    ...    guide: https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1370150863
    ...    and add TCP ports(tcePortNumber on gnb side) to wireshark(Editor->Preferences->Protocols->ntrstr->TCP Ports)
    [Arguments]    ${expect_enough_indicator}    ${expect_enough_verdict}    ${alias}
    ${enough_indicator_list}    pcap.get_field_value_by_xpath    xpath=${RIMRS_TYPE1_ENOUGH_IND_XPATH_MONITOR}    pcap_parser=${alias}
    ${enough_verdict_list}    pcap.get_field_value_by_xpath    xpath=${RIMRS_TYPE1_ENOUGH_VERDIC_XPATH_MONITOR}    pcap_parser=${alias}
    ${enough_indicator_list_new}   remove duplicates    ${enough_indicator_list}
    ${enough_verdict_list_new}   remove duplicates    ${enough_verdict_list}
    should be true    '${expect_enough_indicator}'!='${None}'
    ${expect_enough_indicator_list}    Create List    ${expect_enough_indicator}
    ${expect_enough_verdict_list}    Create List    ${expect_enough_verdict}
    lists_should_be_equal    ${enough_indicator_list_new}     ${expect_enough_indicator_list}
    lists_should_be_equal    ${enough_verdict_list_new}     ${expect_enough_verdict_list}


Check RIMRS Monitoring RIMRS type2 Enough
    [Documentation]   author: Cheng Catherine
    ...    Check RIMRS type2 with no Enough/NotEnough item
    ...    Need to download plugin nsetapx, copy nsetapx-3.2-1.0.0+buster.so to /usr/lib/x86_64-linux-gnu/wireshark/plugins/3.6/epan
    ...    guide: https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1370150863
    ...    and add TCP ports(tcePortNumber on gnb side) to wireshark(Editor->Preferences->Protocols->ntrstr->TCP Ports)
    [Arguments]    ${alias}
    ${enough_indicator_list}    pcap.get_field_value_by_xpath    xpath=${RIMRS_TYPE2_ENOUGH_IND_XPATH_MONITOR}    pcap_parser=${alias}
    ${enough_verdict_list}    pcap.get_field_value_by_xpath    xpath=${RIMRS_TYPE2_ENOUGH_VERDIC_XPATH_MONITOR}    pcap_parser=${alias}
    ${count_enough_indicator}    Get Length    ${enough_indicator_list}
    should be true    ${count_enough_indicator}==${0}
    ${count_enough_verdict}    Get Length    ${enough_verdict_list}
    should be true    ${count_enough_verdict}==${0}


Stop Tcpdump and Check RIMRS Setid Reset from PCMD log
    [Documentation]    Author: Cheng Catherine
    ...    Description:  Steps Stop Tcpdump and Check RIMRS Setid Reset from PCMD log
    ...    1. Stop Tcpdump
    ...    2. Check RIMRS Setid Reset in PCMD log
    [Arguments]   ${tcpdump_collector_name}=CB0010437_PCMD
    ${RIMRS_filter}     Set variable    ${FILTER_PCMD_RIMRS_MONITOR_FW1}
    ${ute_log_path_pcmd}    Stop tcpdump log collection    tcpdump_collector_name=${tcpdump_collector_name}
    run keyword and continue on failure    Check RIMRS Setid Reset for Type1 and Type2    log_file_path=${ute_log_path_pcmd}
                                                            ...     display_filter=${RIMRS_filter}
                                                            ...     alias=RIMRS_setid_reset

Stop Tcpdump and Check RIMRS Setid Removed from PCMD log
    [Documentation]    Author: Cheng Catherine
    ...    Description:  Steps Stop Tcpdump and Check RIMRS Setid Removed from PCMD log
    ...    1. Stop Tcpdump
    ...    2. Check RIMRS Setid Removed in PCMD log
    [Arguments]   ${tcpdump_collector_name}=CB0010437_PCMD
    ${RIMRS_filter}     Set variable    ${FILTER_PCMD_RIMRS_MONITOR_FW1}
    ${ute_log_path_pcmd}    Stop tcpdump log collection    tcpdump_collector_name=${tcpdump_collector_name}
    run keyword and continue on failure    Check RIMRS Setid Removed for Type1 and Type2    log_file_path=${ute_log_path_pcmd}
                                                            ...     display_filter=${RIMRS_filter}
                                                            ...     alias=RIMRS1_setid_removed

Check RIMRS Setid Reset for Type1 and Type2
    [Documentation]   author: Cheng Cathrine
	...    Check RIMRS Setid Reset from RIMRS Monitoring for Type1 and Type2
    [Arguments]    ${log_file_path}    ${display_filter}   ${alias}=check_RIMRS
    pcap.setup    infile=${log_file_path}    display_filter=${display_filter}    alias=${alias}
    ${setid_reset}    pcap.get_field_value_by_xpath    xpath=${RIMRS_SETID_RESET_XPATH_MONITOR}    pcap_parser=${alias}
    ${expect_list}    Create List     0    0
    Lists Should Be Equal    ${setid_reset}    ${expect_list}

Check RIMRS Setid Removed for Type1 and Type2
    [Documentation]   author: Cheng Cathrine
	...    Check RIMRS Setid Removed from RIMRS Monitoring for Type1 and Type2
    [Arguments]    ${log_file_path}    ${display_filter}   ${alias}=check_RIMRS
    pcap.setup    infile=${log_file_path}    display_filter=${display_filter}    alias=${alias}
    ${setid_removed}    pcap.get_field_value_by_xpath    xpath=${RIMRS_SETID_REMOVED_XPATH_MONITOR}    pcap_parser=${alias}
    ${expect_list}    Create List     0    0
    Lists Should Be Equal    ${setid_removed}    ${expect_list}


Check RIMRS Repetion for dedicate rimrs type
    [Documentation]   author: Wang Yixiang
	...    Check RIMRS Monitoring Repetition from PCMD log for dedicate rimrs type
    [Arguments]    ${repetitionRsType}    ${repetition_no_check}    ${near_far}    ${alias}=check_RIMRS
    ${RIMRS_REPET_XPATH_MONITOR}    Set variable if    '${PROGRAM}'<='24R2'    ${RIMRS_REPET_XPATH_MONITOR}    ${RIMRS_REPET_XPATH_MONITOR_NEW}
    ${rimrs_repetition}    pcap.get_field_value_by_xpath    xpath=${RIMRS_REPET_XPATH_MONITOR}    pcap_parser=${alias}
    ${rimrs_repetition_log}   remove duplicates    ${rimrs_repetition}
    should not be empty    ${rimrs_repetition_log}    rimrs repetition from PCMD log is empty!!

    ${tmp_list}    set variable    ${repetitionRsType.split('r')}
    ${repetition_str}    set variable     ${tmp_list[1]}
    ${repetition}     convert to integer    ${repetition_str}
    ${repetition_1}   evaluate    ${repetition}+${1}
    ${half_repetition_1}   evaluate    ${repetition}/${2}+${1}
    ${half_repetition_1}     convert to integer    ${half_repetition_1}

    set test variable   ${start}    ${1}
    set test variable   ${end}    ${repetition_1}
    run keyword if   '${near_far}'=='near'    set test variable   ${end}    ${half_repetition_1}
    run keyword if   '${near_far}'=='far'     set test variable   ${start}    ${half_repetition_1}

    ${repetition_expected}    create list
    FOR   ${index}    IN RANGE    ${start}    ${end}
        ${index_str}    convert to string    ${index}
        run keyword if   '${index}'!='${repetition_no_check}'    Append to list    ${repetition_expected}   ${index_str}
    END

    run keyword if   '${near_far}'=='both'    Should Be Equal    ${rimrs_repetition_log}    ${repetition_expected}    Repetition is not as expected.
    ...   ELSE   _List Should begin with SubList    ${rimrs_repetition_log}    ${repetition_expected}

_List Should begin with SubList
    [Documentation]   Author: Catherine.cheng@nokia-sbell.com
	...    list should begin with subList
    [Arguments]    ${list}    ${subList}
    ${sub_length}     Get Length    ${subList}
    ${sliced_list}    Get Slice From List    ${list}    ${0}    ${sub_length}
    Should Be Equal    ${sliced_list}    ${subList}

Check RIMRS Monitoring Nearfar for dedicate rimrs type
    [Documentation]   author: Wang Yixiang
	...    ${near_far} can be values ${False},near(only near detected),far(only far detected),both(near far both detected)
    [Arguments]    ${near_far}    ${alias}
    ${near_far_list_log}    pcap.get_field_value_by_xpath    xpath=${RIMRS_NEARFAR_XPATH_MONITOR}    pcap_parser=${alias}
    ${near_far_list_log}   remove duplicates    ${near_far_list_log}
    should not be empty    ${near_far_list_log}    rimrs near far from PCMD log is empty!!
    ${near_far_list_log_convert}    create list
    FOR    ${item}    IN    @{near_far_list_log}
        ${tmp_value}    set variable if    '${item}'=='0'   near     '${item}'=='1'    far
        Append to list    ${near_far_list_log_convert}    ${tmp_value}
    END
	${near_far}     set variable if    '${near_far}'=='both'    near,far    ${near_far}
    ${near_far_list}   string2list   ${near_far}

    run keyword if   '${near_far}'=='both'    Should Be Equal    ${near_far_list_log_convert}    ${near_far_list}    Near far is not as expected.
    ...   ELSE   _List Should begin with SubList    ${near_far_list_log_convert}    ${near_far_list}


#Check RIMRS Transmission Record from PCMD log
#    [Documentation]   author: Cheng Catherine
#    ...    Check RIMRS Transmission Record from PCMD log, rimrs_setid, rimrs_max_power and repetition
#    ...    Need to download plugin nsetapx, copy nsetapx-3.2-1.0.0+buster.so to /usr/lib/x86_64-linux-gnu/wireshark/plugins/3.6/epan
#    ...    guide: https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1370150863
#    ...    and add TCP ports(tcePortNumber on gnb side) to wireshark(Editor->Preferences->Protocols->ntrstr->TCP Ports)
#    ...    ${near_far} can be values ${False},near(only near detected),far(only far detected),both(near far both detected)
#    [Arguments]    ${log_file_path}   ${repetitionRsType1}    ${display_filter}=${FILTER_PCMD_RIMRS1_MONITOR}    ${alias}=check_RIMRS
#    ...           ${repetition_no_check}=${0}    ${feature}=6991   ${near_far}=${False}
#    pcap.setup    infile=${log_file_path}    display_filter=${display_filter}    alias=${alias}


Check UL impact on Special and UL slot
    [Documentation]  Check UL impact on Special and UL slot
    [Arguments]   ${UL_symbol_RI_list}    ${UL_drop_height_list}    ${ri_monitor_special_slot_list}    ${ri_monitor_ul_slot_list}
    ${expect_ul_ri_slot_list}    combine_lists       ${ri_monitor_special_slot_list}    ${ri_monitor_ul_slot_list}
    FOR   ${expect_slot}    IN    @{ri_monitor_ul_slot_list}
        ${expect_slot_str}    convert to string    ${expect_slot}
        ${index}    get_index_from_list    ${UL_drop_height_list}    ${expect_slot_str}
        should be true    ${index}>=0    ${expect_slot} not contained in PCMD log: nsetapx.ulDropHeightDataList !!!
    END
    FOR   ${expect_slot}    IN    @{expect_ul_ri_slot_list}
        ${expect_slot_str}    convert to string    ${expect_slot}
        ${index}    get_index_from_list    ${UL_symbol_RI_list}    ${expect_slot_str}
        should be true   ${index}>=0   ${expect_slot} not contained in PCMD log: nsetapx.ulSymbolRiDataList !!!
    END


Steps Make L3 call and Check no DL Mitigation before RI
    [Documentation]    Author: Cheng Catherine
    ...    Description:  Steps Make L3 call and Check no DL Mitigation before RI then stop traffic, detach UE
    [Arguments]   ${pdsch_slot_list}=${MUTE_SLOT_LIST}    ${check_bip_needed}=${True}
    ...    ${before_ri}=${False}   ${target_file_name}=bip_log_before_RI  ${dl_exp}=${TDD_DL_EXP_TPUT}
    ...    ${ul_exp}=${TDD_UL_EXP_TPUT}
    Make L3 call then Check DL Mitigation and SRS Status   pdsch_slot_list=${pdsch_slot_list}
                                        ...    check_bip_needed=${check_bip_needed}
                                        ...    is_pdsch_scheduled_on_s_d_slot=${True}
                                        ...    before_ri=${before_ri}
                                        ...    target_file_name=${target_file_name}
                                        ...    dl_exp=${dl_exp}
                                        ...    ul_exp=${ul_exp}


Make L3 call then Check DL Mitigation and SRS Status
    [Documentation]    Author: Cheng Catherine
    ...    Description:  Make L3 call then Check DL Mitigation status and SRS status, then stop traffic, detach UE
    [Arguments]   ${pdsch_slot_list}=${MUTE_SLOT_LIST}    ${check_bip_needed}=${True}    ${is_pdsch_scheduled_on_s_d_slot}=${True}
    ...    ${before_ri}=${False}   ${target_file_name}=bip_log_before_RI  ${dl_exp}=${TDD_DL_EXP_TPUT}
    ...    ${ul_exp}=${TDD_UL_EXP_TPUT}     ${tput_check}=${true}    ${srs_check}=${False}
    run keyword and continue on failure    L3 call and check tput for each cell
                                                                            ...    cell_id=${TDD_CELL_ID}
                                                                            ...    dl_tput=${DL_TPUT}
                                                                            ...    ul_tput=${UL_TPUT}
                                                                            ...    exp_dl=${dl_exp}
                                                                            ...    exp_ul=${ul_exp}
                                                                            ...    customized_log_name=beforeRI
                                                                            ...    before_ri=${before_ri}
                                                                            ...    tput_check=${tput_check}
    run keyword and continue on failure    run keyword if    ${check_bip_needed}
    ...    Captrue bip then Stop Traffic Detach UE and Check if DL and S slot scheduled on Aggressor
                                                       ...    is_pdsch_scheduled_on_s_d_slot=${is_pdsch_scheduled_on_s_d_slot}
                                                       ...    pdsch_slot_list=${pdsch_slot_list}
                                                       ...    target_file_name=${target_file_name}
                                                       ...    srs_check=${srs_check}

    [Teardown]   run keyword and ignore error    Stop data transfer and detach UE


Steps Check Fault 7525 raised and RI PCMD When RI
    [Documentation]    Author: Cheng Catherine
    ...    Description:  Steps Check Fault 7525 raised and RI PCMD When RI
    ...    1. Check fault 7525 raised
    ...    2. Check RI status from aasyslog, this step may not needed
    ...    3. CHeck RI PCMD log if check_ri_pcmd = true and 'PROGRAM'>='23R4'
    ...    4. Captrue bip logs and Check RimRs Sent on Special or DL Slot by Victim, this step may not needed
    ...    5. Capture tcpdump and check RI info in PCMD log, UL_SYMBOL_RI_LIST and UL_drop_height_list
    ...    ri_monitor_special_slot_list and ri_monitor_ul_slot_list not equal None while check_ri_pcmd=True
    [Arguments]   ${framestructure}     ${transmission_window}    ${near_far}=${NEAR_ONLY}    ${repetition}=r1
    ...    ${ri_monitor_special_slot_list}=${None}
    ...    ${ri_monitor_ul_slot_list}=${None}    ${check_rimrs_sent}=${False}    ${check_ri_pcmd}=${False}
    ...    ${tcpdump_collector_name}=CB0010437_PCMD_RI    ${alarm_check_timeout}=${RI_TIMEOUT}
    ...    ${check_asymmetric}=${False}
    ...    ${cm_ri_state}=off    ${cm_rimrssetid_state}=off    ${cm_dlmuting_state}=off    ${cm_asymmetric_state}=off
    ...    ${asymmetricState}=not check    ${riState}=not check    ${rimRsSetIdType1}=not check
    ...    ${rimRsSetIdType2}=not check     ${pdcchMutingStatus}=not check    ${pdschMutingStatus}=not check
    Run Keyword If    '${cm_ri_state}' == 'off'    AlarmWatchdog.add_allow_alarms    fault_id=7525
    Run Keyword If    '${cm_rimrssetid_state}'=='off'    AlarmWatchdog.add_allow_alarms    fault_id=7527
    Run Keyword If    '${cm_dlmuting_state}'=='off'    AlarmWatchdog.add_allow_alarms    fault_id=7535
    run keyword if    '${PROGRAM}'>='24R3' and '${check_asymmetric}'=='${True}' and '${cm_asymmetric_state}'=='off'
    ...    AlarmWatchdog.add_allow_alarms    fault_id=7532
    run keyword and continue on failure    run keyword if     ${check_ri_pcmd} and '${PROGRAM}'>='23R4'
    ...    Start Capture PCMD with filter port      tcpdump_collector_name=${tcpdump_collector_name}

    # check fault 7525 raised, check RI from syslog, check RimRs Sent on Special or DL Slot by Victim and check RIMRS PCMD

    run keyword and continue on failure    Wait and Verify Fault Present on Cells    faultId=7525
                                                                    ...    alarm_check_timeout=${alarm_check_timeout}
                                                                    ...    alarm_check_interval=30sec
                                                                    ...    cm_ri_state=${cm_ri_state}
                                                                    ...    riState=${riState}
                                                                    ...    asymmetricState=${asymmetricState}
                                                                    ...    rimRsSetIdType1=${rimRsSetIdType1}
                                                                    ...    rimRsSetIdType2=${rimRsSetIdType2}
                                                                    ...    pdschMutingStatus=${pdschMutingStatus}
                                                                    ...    pdcchMutingStatus=${pdcchMutingStatus}
                                                                    ...    CM_check_timeout=30m
#    run keyword and ignore error    Check RI or RS status from aasyslog    isRiDetected=${True}
#                                                                    ...    isRs1Detected=${False}
    run keyword and ignore error    run keyword if     ${check_rimrs_sent}
    ...    Captrue bip logs and Check RimRs Sent on Special or DL Slot by Victim
                                                                    ...    framestructure=${framestructure}
                                                                    ...    transmission_window=${transmission_window}
                                                                    ...    near_far=${near_far}
                                                                    ...    repetition=${repetition}

    run keyword and continue on failure    run keyword if     ${check_ri_pcmd} and '${PROGRAM}'>='23R4'
    ...    Stop Tcpdump and Check RI info from PCMD log    ri_monitor_special_slot_list=${ri_monitor_special_slot_list}
                                                    ...    ri_monitor_ul_slot_list=${ri_monitor_ul_slot_list}
                                                    ...    tcpdump_collector_name=${tcpdump_collector_name}

Steps Check Fault 7527 raised and RIMRS PCMD and DL Mitigation started from Bip When RI
    [Documentation]    Author: Cheng Catherine
    ...    Description:  Steps Check Fault 7527 raised and RIMRS PCMD and DL Mitigation started from Bip When RI
    ...    1. check fault 7527 raised
    ...    2. Captrue bip logs and Check RimRs Received on Special Slot by Aggressor
    ...    3. Check RIMRS info from PCMD log if check_rimrs_pcmd = true and 'PROGRAM'>='23R4'
    ...    4. Captrue bip then Stop Traffic Detach UE and Check if DL and S slot scheduled on Aggressor
    ...    srs_check: Value can be "exist" or "not exist" or ${False},filter uldata_srsreceivereq from BIP log,
    ...               pSRS should disable after 7525, and resume after 7525 disappear (precondition nidd:actUlSrsBm=true, actDlSrsBm=true)
    ...    repetition_no_check: which repetition no need to check
    [Arguments]   ${SetId_Aggressor}    ${dlMuteSlotsStr}    ${repetitionRsType1}=r1    ${repetitionRsType2}=${None}
    ...         ${is_pdsch_scheduled_on_s_d_slot}=${False}    ${special_slot_list}=${SPECIAL_SLOT_LIST}    ${check_rimrs_pcmd}=${False}
    ...         ${feature}=6991    ${srs_check}=${False}    ${pcmd_log_time}=5min   ${tcpdump_collector_name}=CB0010437_PCMD_RIMRS
    ...         ${target_file_name}=bip_log_during_RI     ${pdsch_slot_list}=${MUTE_SLOT_LIST}    ${alarm_check_timeout}=30m
    ...         ${check_rimrs_detect_enable}=${True}    ${detection_disable_ul_slot_list}=${False}    ${near_far}=${False}
    ...         ${check_asymmetric}=${False}    ${own_setid}=${False}    ${rimrs_enable_slot_list}=${False}    ${check_bip_needed}=${True}
    ...         ${setId_show_in_fault}=${False}    ${repetition1_no_check}=${0}      ${repetition2_no_check}=${0}
    ...         ${check_enough}=${False}     ${enough_indicator_monitor}=${None}     ${enough_verdict_monitor}=${None}
    ...         ${enough_indicator_transmit}=${None}     ${rsType1NScId}=${False}   ${rsType2NScId}=${False}     ${transmission_window}=3min
    ...         ${cm_rimrssetid_state}=off    ${cm_dlmuting_state}=off    ${cm_asymmetric_state}=off
    ...         ${asymmetricState}=not check     ${rimRsSetIdType1}=not check
    ...         ${rimRsSetIdType2}=not check     ${pdcchMutingStatus}=not check    ${pdschMutingStatus}=not check

    ${supplementary}    Get Supplementary for Fault 7527    ${SetId_Aggressor}    ${dlMuteSlotsStr}    ${feature}    ${setId_show_in_fault}
    ${supplementary_7535}    Get Supplementary for Fault 7535    ${dlMuteSlotsStr}
    ${supplementary_7532}    set variable    rsSetId: ${own_setid} is in asymmetric ducting state

    run keyword and continue on failure    run keyword if     ${check_rimrs_pcmd} and '${PROGRAM}'>='23R4'
    ...    Start Capture PCMD with filter port      tcpdump_collector_name=${tcpdump_collector_name}

    # check fault 7527 raised, check RimRs Received on Special Slot by Aggressor
    run keyword and continue on failure    Wait and Verify Fault Present on Cells    faultId=7527
                                                                    ...    alarm_check_timeout=${alarm_check_timeout}
                                                                    ...    alarm_check_interval=1min
                                                                    ...    supplementary=${supplementary}
                                                                    ...    cm_rimrssetid_state=${cm_rimrssetid_state}
                                                                    ...    CM_check_timeout=30min
                                                                    ...    rimRsSetIdType1=${rimRsSetIdType1}
                                                                    ...    rimRsSetIdType2=${rimRsSetIdType2}

    run keyword and continue on failure    run keyword if   '${PROGRAM}'>='24R3' and '${supplementary_7535}'!='${None}'
                            ...    Wait and Verify Fault Present on Cells    faultId=7535
                                                                    ...    alarm_check_timeout=1m
                                                                    ...    alarm_check_interval=10sec
                                                                    ...    supplementary=${supplementary_7535}
                                                                    ...    cm_dlmuting_state=${cm_dlmuting_state}
                                                                    ...    pdschMutingStatus=${pdschMutingStatus}
                                                                    ...    pdcchMutingStatus=${pdcchMutingStatus}
                                                                    ...    CM_check_timeout=1min

    run keyword and continue on failure    run keyword if     ${check_rimrs_detect_enable}    Captrue bip logs and Check RimRs Detection enable
                                                                    ...    special_slot_list=${special_slot_list}
                                                                    ...    target_file_name=${target_file_name}_rs_detet
                                                                    ...    detection_disable_ul_slot_list=${detection_disable_ul_slot_list}
																	...    rimrs_enable_slot_list=${rimrs_enable_slot_list}

    run keyword and continue on failure    run keyword if    '${PROGRAM}'>='24R3' and ${check_enough}
    ...    Captrue bip logs and Check RimRs Sent enough and not enough    enough_indicator=${enough_indicator_transmit}
    ...    rsType1NScId=${rsType1NScId}    rsType2NScId=${rsType2NScId}    transmission_window=${transmission_window}

    # capture bip log, and check DL mitigation(maybe S+DL sysmbol muted) from bip log
    Make L3 call then Check DL Mitigation and SRS Status   pdsch_slot_list=${pdsch_slot_list}
                                        ...    is_pdsch_scheduled_on_s_d_slot=${is_pdsch_scheduled_on_s_d_slot}
                                        ...    target_file_name=${target_file_name}_mute_check
                                        ...    dl_exp=${TDD_DL_EXP_TPUT}
                                        ...    ul_exp=${TDD_UL_EXP_TPUT}
                                        ...    srs_check=${srs_check}
                                        ...    tput_check=${false}
                                        ...    check_bip_needed=${check_bip_needed}

    # check RIMRS from PCMD log
    run keyword if     ${check_rimrs_pcmd} and '${PROGRAM}'>='23R4'    sleep    ${pcmd_log_time}
    run keyword and continue on failure    run keyword if     ${check_rimrs_pcmd} and '${PROGRAM}'>='23R4'
    ...    Stop Tcpdump and Check RIMRS info from PCMD log    SetId_Aggressor=${SetId_Aggressor}
                                                        ...    repetitionRsType1=${repetitionRsType1}
                                                        ...    repetitionRsType2=${repetitionRsType2}
                                                        ...    tcpdump_collector_name=${tcpdump_collector_name}
                                                        ...    repetition1_no_check=${repetition1_no_check}
                                                        ...    repetition2_no_check=${repetition2_no_check}
														...    feature=${feature}
                                                        ...    near_far=${near_far}
                                                        ...    check_enough=${check_enough}
                                                        ...    enough_indicator_monitor=${enough_indicator_monitor}
                                                        ...    enough_verdict_monitor=${enough_verdict_monitor}
                                                        ...    enough_indicator_transmit=${enough_indicator_transmit}

    run keyword and continue on failure    run keyword if   '${PROGRAM}'>='24R3' and '${check_asymmetric}'=='${True}'
                            ...    Wait and Verify Fault Present on Cells    faultId=7532
                                                                    ...    alarm_check_timeout=3m
                                                                    ...    alarm_check_interval=10sec
                                                                    ...    supplementary=${supplementary_7532}
                                                                    ...    cm_asymmetric_state=${cm_asymmetric_state}
                                                                    ...    CM_check_timeout=15m
                                                                    ...    asymmetricState=${asymmetricState}

Remove NRMTRACEDU MO by rest api and wait onair
    [Documentation]   author: Cheng Catherine
    ...   online delete DELETE_MO_NRMTRACEDU_RESTAPI and wait onair
    [Arguments]     ${parameters}=${DELETE_MO_NRMTRACEDU_RESTAPI}    ${timeout}=5min
    COAM delete objects via rest api    objects_to_delete_via_api=${parameters}    timeout=${timeout}
    Wait until cluster is on cell on air status    timeout=${timeout}
    ...    is_enb_status_check_needed=${false}
    ...    is_x2_check_from_enb_needed=${false}
    ...    is_all_cells_checking_needed=${True}


Steps Check no RI or RIMRS PCMD after PCMD MO deleted
    [Documentation]    Author: Cheng Catherine
    ...    Description:  Steps Check Fault 7525 raised and RI PCMD When RI
    ...    1. Check fault 7525 raised
    ...    2. Check RI status from aasyslog, this step may not needed
    ...    3. CHeck RI PCMD log if check_ri_pcmd = true and 'PROGRAM'>='23R4'
    ...    4. Captrue bip logs and Check RimRs Sent on Special or DL Slot by Victim, this step may not needed
    ...    5. Capture tcpdump and check RI info in PCMD log, UL_SYMBOL_RI_LIST and UL_drop_height_list
    ...    ri_monitor_special_slot_list and ri_monitor_ul_slot_list not equal None while check_ri_pcmd=True
    [Arguments]    ${tcpdump_collector_name}=CB0010437_PCMD_stop
    run keyword and continue on failure    Remove NRMTRACEDU MO by rest api and wait onair
    run keyword and continue on failure    Start Capture PCMD with filter port      tcpdump_collector_name=${tcpdump_collector_name}
    sleep    3min
    run keyword and continue on failure    Stop Tcpdump and Check no RI or RIMRS info from PCMD log
                                                                             ...    tcpdump_collector_name=${tcpdump_collector_name}


Steps Trigger RI Disappear and Check Fault 7525 7527 canceled and DL Mitigation stopped
    [Documentation]    Author: Cheng Catherine
    ...    Description:  Steps Trigger RI Disappear and Check Fault 7525 7527 canceled and DL Mitigation stopped
    ...    1. lock aggressor cell, wait and verify fault 7525 & 7527 disappeared
    ...    2. check from history alarm, should contain 7525 or 7527
    ...    3. capture bip log and check Special+DL symbols all scheduled from bip log
    ...    srs_check: Value can be "exist" or "not exist" or ${False},filter uldata_srsreceivereq from BIP log,
    ...               pSRS should disable after 7525, and resume after 7525 disappear (precondition nidd:actUlSrsBm=true, actDlSrsBm=true)
    [Arguments]   ${SetId_Aggressor}    ${dlMuteSlotsStr}     ${pdsch_slot_list}=${MUTE_SLOT_LIST}
    ...    ${is_pdsch_scheduled_on_s_d_slot}=${True}    ${check_bip_needed}=${False}    ${feature}=6991    ${srs_check}=${False}
    ...    ${after_ri}=${False}    ${exp_dl_tput_gap}=5    ${exp_ul_tput_gap}=3    ${check_rs_detect_false}=${False}
    ...    ${sleep_time}=3min     ${lock_cell}=${True}    ${targetTotalLoad}=${False}    ${dlMuteSlotsStr}=${None}
    ...    ${setId_show_in_fault}=${False}    ${check_pcmd_setid_removed}=${False}   ${tcpdump_collector_name}=PCMD_RIMRS_AFTER_RI
    ${supplementary}    Get Supplementary for Fault 7527    ${SetId_Aggressor}    ${dlMuteSlotsStr}    ${feature}   ${setId_show_in_fault}
    ${supplementary_7535}    Get Supplementary for Fault 7535    ${dlMuteSlotsStr}

    run keyword and continue on failure    run keyword if     ${check_pcmd_setid_removed} and '${PROGRAM}'>='24R3'
    ...    Start Capture PCMD with filter port      tcpdump_collector_name=${tcpdump_collector_name}
    # lock aggressor cell, wait and verify fault 7525 & 7527 disappeared
    run keyword and continue on failure    run keyword if   ${lock_cell}    Lock cells
    run keyword and continue on failure    run keyword if   ${targetTotalLoad}
                                                        ...    coam_gnb_classical.COAM Update several parameters via rest api
                                                        ...    parameters_to_update_via_api=${RESTAPI_Cancel_RI}
                                                        ...    skip_parameter_relation_errors=${False}
                                                        ...    connection=${OAM_ALIAS_GNB1}
                                                        ...    timeout=${120}
    run keyword and continue on failure    Wait and Verify Fault 7525 not Present on Cells
    run keyword and continue on failure    Wait and Verify Fault 7527 not Present on Cells
    run keyword and continue on failure    run keyword if   '${PROGRAM}'>='24R3'
                                                        ...    Wait and Verify Fault 7535 not Present on Cells

    run keyword and continue on failure    run keyword if     ${check_pcmd_setid_removed} and '${PROGRAM}'>='24R3'
    ...    Stop Tcpdump and Check RIMRS Setid Removed from PCMD log    tcpdump_collector_name=${tcpdump_collector_name}


    # check from history alarm, should contain 7525 or 7527
    run keyword and continue on failure    Wait and Verify Expect Fault Present or not from History List on Cells
                                                        ...    faultId=7525
                                                        ...    expect_present=${True}
    run keyword and continue on failure    Wait and Verify Expect Fault Present or not from History List on Cells
                                                        ...    faultId=7527
                                                        ...    expect_present=${True}
	run keyword and continue on failure    run keyword if   '${PROGRAM}'>='24R3'
    ...    Expect Fault Present or not from History List on Cells    faultId=7535
                                                            ...    expect_present=${True}
                                                            ...    supplementary=${supplementary_7535}

    AlarmWatchdog.remove_allow_alarms    fault_id=7525
    AlarmWatchdog.remove_allow_alarms    fault_id=7527
    AlarmWatchdog.remove_allow_alarms    fault_id=7535

    # capture bip log and check Special+DL symbols all scheduled from bip log
    run keyword and continue on failure    L3 call and check tput for each cell    cell_id=${TDD_CELL_ID}
                                                                            ...    dl_tput=${DL_TPUT}
                                                                            ...    ul_tput=${UL_TPUT}
                                                                            ...    exp_dl=${TDD_DL_EXP_TPUT}
                                                                            ...    exp_ul=${TDD_UL_EXP_TPUT}
                                                                            ...    customized_log_name=afterRI
                                                                            ...    after_ri=${after_ri}
                                                                            ...    exp_dl_tput_gap=${exp_dl_tput_gap}
                                                                            ...    exp_ul_tput_gap=${exp_ul_tput_gap}
    run keyword if   ${check_rs_detect_false} or '${srs_check}'=='exist'
                               ...   sleep   ${sleep_time}    Wait for one PT to check rs revalidate stop and srs recover
    run keyword and continue on failure        run keyword if    "${check_bip_needed}"!="${False}"
    ...    Captrue bip then Stop Traffic Detach UE and Check if DL and S slot scheduled on Aggressor
                                                           ...    is_pdsch_scheduled_on_s_d_slot=${is_pdsch_scheduled_on_s_d_slot}
                                                           ...    pdsch_slot_list=${pdsch_slot_list}
                                                           ...    target_file_name=l1l2bip_log_after_RI
                                                           ...    srs_check=${srs_check}
                                                           ...    check_rs_detect_false=${check_rs_detect_false}
    [Teardown]   run keywords    run keyword and ignore error    Stop data transfer and detach UE    AND
                        ...    run keyword and continue on failure    Unlock cells


Steps Trigger RI Disappear but RIMRS exist then Check Fault 7525 7527 canceled and DL Mitigation stopped
    [Documentation]    Author: Cheng Catherine
    ...    Description:  Steps Trigger RI Disappear but RIMRS exist, then Check Fault 7525 7527 canceled
    ...    and DL Mitigation stopped
    ...    1. set targetTotalLoad=0 on victim cell, wait and verify fault 7525 disappeared but 7527 still exist
    ...    2. fault 7527 should disappear after maxRsDetectDurationWithoutRi expires
    ...    3. check from history alarm, should contain 7525 and 7527
    ...    4. capture bip log and check Special+DL symbols all scheduled from bip log
    ...    srs_check: Value can be "exist" or "not exist" or ${False},filter uldata_srsreceivereq from BIP log,
    ...               pSRS should disable after 7525, and resume after 7525 disappear (precondition nidd:actUlSrsBm=true, actDlSrsBm=true)
    [Arguments]       ${SetId_Aggressor}    ${dlMuteSlotsStr}     ${pdsch_slot_list}=${MUTE_SLOT_LIST}
    ...    ${is_pdsch_scheduled_on_s_d_slot}=${True}    ${check_bip_needed}=${False}    ${connection_victim}=${OAM_ALIAS_GNB1}
    ...    ${feature}=6991    ${rs_detect_duration_without_Ri}=${10}    ${srs_check}=${False}    ${after_ri}=${False}
    ...    ${exp_dl_tput_gap}=5    ${exp_ul_tput_gap}=3    ${repetition1_no_check}=${0}    ${repetition2_no_check}=${0}
    ...    ${check_rs_detect_false}=${False}    ${repetitionRsType1}=${None}   ${repetitionRsType2}=${None}
    ...    ${sleep_time}=3min    ${check_repetition}=${True}
    ...    ${check_enough}=${False}    ${rsType1NScId}=${False}    ${rsType2NScId}=${False}  ${check_asymmetric}=${False}
	...    ${bip_rimrs_file}=bip_rimrs_7525_disappear    ${setId_show_in_fault}=${False}    ${check_rimrs_pcmd}=${False}
    ...    ${enough_indicator_monitor}=${None}    ${enough_verdict_monitor}=${None}
    ...    ${enough_indicator_transmit}=${None}    ${tcpdump_collector_name}=PCMD_RIMRS_AFTER_RI_check_enough
    ...    ${cm_ri_state}=off    ${cm_rimrssetid_state}=off    ${cm_dlmuting_state}=off    ${cm_asymmetric_state}=off
    ...    ${pdcchMutingStatus}=not check    ${pdschMutingStatus}=not check    ${rimRsSetIdType1}=not check
    ...    ${rimRsSetIdType2}=not check    ${actRimPdcchMutingOnSpecialSlot}=false
    ${supplementary}    Get Supplementary for Fault 7527    ${SetId_Aggressor}    ${dlMuteSlotsStr}    ${feature}   ${setId_show_in_fault}
    ${supplementary_7535}    Get Supplementary for Fault 7535    ${dlMuteSlotsStr}
    # set targetTotalLoad=0 on victim cell, wait and verify fault 7525 disappeared but 7527 still exist
    coam_gnb_classical.COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${RESTAPI_MODIFY_NO_TARGET_TOTAL_LOAD}
    ...    skip_parameter_relation_errors=${True}
    ...    connection=${connection_victim}
    ...    timeout=${120}

    run keyword and continue on failure    Wait and Verify Fault 7525 not Present on Cells
    ...    cm_ri_state=${cm_ri_state}
    run keyword and continue on failure    Wait and Verify Fault Present on Cells    faultId=7527
                                                                    ...    alarm_check_timeout=3sec
                                                                    ...    alarm_check_interval=3sec
                                                                    ...    supplementary=${supplementary}
                                                                    ...    cm_rimrssetid_state=${cm_rimrssetid_state}
                                                                    ...    rimRsSetIdType1=${rimRsSetIdType1}
                                                                    ...    rimRsSetIdType2=${rimRsSetIdType2}
                                                                    ...    CM_check_timeout=3sec

    run keyword and continue on failure    run keyword if   '${PROGRAM}'>='24R3' and '${supplementary_7535}'!='${None}'
    ...    Wait and Verify Fault Present on Cells    faultId=7535
                                            ...    alarm_check_timeout=3sec
                                            ...    alarm_check_interval=3sec
                                            ...    supplementary=${supplementary_7535}
                                            ...    cm_dlmuting_state=${cm_dlmuting_state}
                                            ...    pdschMutingStatus=${pdschMutingStatus}
                                            ...    pdcchMutingStatus=${pdcchMutingStatus}
                                            ...    CM_check_timeout=3sec

    AlarmWatchdog.remove_allow_alarms    fault_id=7525
    run keyword and continue on failure    run keyword if     ${check_enough} and '${PROGRAM}'>='24R3'
    ...    Start Capture PCMD with filter port      tcpdump_collector_name=${tcpdump_collector_name}

    run keyword and continue on failure    run keyword if   '${PROGRAM}'>='24R3' and '${check_asymmetric}'=='${True}'
    ...    Wait and Verify Fault 7532 not Present on Cells    cm_asymmetric_state=${cm_asymmetric_state}

    run keyword and continue on failure    run keyword if   '${PROGRAM}'>='24R3' and '${check_asymmetric}'=='${True}'
    ...    AlarmWatchdog.remove_allow_alarms    fault_id=7532

    run keyword and continue on failure    run keyword if   '${PROGRAM}'>='24R3' and ${check_enough}
    ...    Captrue bip logs and Check RimRs Sent enough and not enough    enough_indicator=${enough_indicator_transmit}
    ...    rsType1NScId=${rsType1NScId}    rsType2NScId=${rsType2NScId}    target_file_name=${bip_rimrs_file}

    #do not delete this info, not to check rimrs detection status here because new detection will stop until next beginning of PT,
    #and revalidate will keep ongoing, but need to capture logs for at least one PT; it's hard to check new detection stopped in TA
#    run keyword and continue on failure    Captrue bip logs and Check RimRs Detection enable
#                                                                    ...    special_slot_list=${special_slot_list}
#                                                                    ...    target_file_name=l1l2bip_7525_cancel_rs_detet
    # fault 7527 should disappear after maxRsDetectDurationWithoutRi expires
    ${wait_time}    evaluate    ${rs_detect_duration_without_Ri}+${5}
    run keyword and continue on failure    Wait and Verify Fault 7527 not Present on Cells    7527_check_timeout=${wait_time}min
    ...    cm_rimrssetid_state=${cm_rimrssetid_state}

    run keyword and continue on failure    run keyword if   '${PROGRAM}'>='24R3'    Wait and Verify Fault 7535 not Present on Cells
    ...    cm_dlmuting_state=${cm_dlmuting_state}    actRimPdcchMutingOnSpecialSlot=${actRimPdcchMutingOnSpecialSlot}
    ...    CM_check_timeout=1min
    AlarmWatchdog.remove_allow_alarms    fault_id=7527
    AlarmWatchdog.remove_allow_alarms    fault_id=7535

    run keyword and continue on failure    run keyword if     ${check_rimrs_pcmd} and '${PROGRAM}'>='23R4'
    ...    Stop Tcpdump and Check RIMRS info from PCMD log    SetId_Aggressor=${SetId_Aggressor}
                                                        ...    repetitionRsType1=${repetitionRsType1}
                                                        ...    repetitionRsType2=${repetitionRsType2}
                                                        ...    tcpdump_collector_name=${tcpdump_collector_name}
                                                        ...    repetition1_no_check=${repetition1_no_check}
                                                        ...    repetition2_no_check=${repetition2_no_check}
														...    feature=${feature}
                                                        ...    near_far=${False}
                                                        ...    check_repetition=${check_repetition}
                                                        ...    check_enough=${check_enough}
                                                        ...    enough_indicator_monitor=${enough_indicator_monitor}
                                                        ...    enough_verdict_monitor=${enough_verdict_monitor}
                                                        ...    enough_indicator_transmit=${enough_indicator_transmit}

    # check from history alarm, should contain 7525, 7527 and 7535
    run keyword and continue on failure    Run Keyword If    '${cm_ri_state}' == 'off'
    ...    Wait and Verify Expect Fault Present or not from History List on Cells
                                                        ...    faultId=7525
                                                        ...    expect_present=${True}
    run keyword and continue on failure    Run Keyword If    '${cm_rimrssetid_state}' == 'off'
    ...    Wait and Verify Expect Fault Present or not from History List on Cells
                                                        ...    faultId=7527
                                                        ...    expect_present=${True}
	run keyword and continue on failure    run keyword if   '${PROGRAM}'>='24R3' and '${cm_dlmuting_state}' == 'off'
                            ...    Expect Fault Present or not from History List on Cells    faultId=7535
                                                        ...    expect_present=${True}
                                                        ...    supplementary=${supplementary_7535}

    # capture bip log and check Special+DL symbols all scheduled from bip log
    run keyword and continue on failure    L3 call and check tput for each cell    cell_id=${TDD_CELL_ID}
                                                                            ...    dl_tput=${DL_TPUT}
                                                                            ...    ul_tput=${UL_TPUT}
                                                                            ...    exp_dl=${TDD_DL_EXP_TPUT}
                                                                            ...    exp_ul=${TDD_UL_EXP_TPUT}
                                                                            ...    customized_log_name=afterRI
                                                                            ...    after_ri=${after_ri}
                                                                            ...    exp_dl_tput_gap=${exp_dl_tput_gap}
                                                                            ...    exp_ul_tput_gap=${exp_ul_tput_gap}
    run keyword if   ${check_rs_detect_false}    sleep   ${sleep_time}    Wait for 1st RIM-RS PT to check rs revalidate stop and srs recover
    run keyword and continue on failure    run keyword if    "${check_bip_needed}"!="${False}"
    ...    Captrue bip then Stop Traffic Detach UE and Check if DL and S slot scheduled on Aggressor
                                                           ...    is_pdsch_scheduled_on_s_d_slot=${is_pdsch_scheduled_on_s_d_slot}
                                                           ...    pdsch_slot_list=${pdsch_slot_list}
                                                           ...    target_file_name=l1l2bip_log_after_RI
                                                           ...    srs_check=${srs_check}
                                                           ...    check_rs_detect_false=${check_rs_detect_false}
    [Teardown]   run keyword and ignore error    Stop data transfer and detach UE


Steps Trigger rsDetectionWindow disable then Check Fault 7527 canceled and DL Mitigation stopped then RI disappear and 7525 cancel
    [Documentation]    Author: Wang Yixiang
    ...    Description:  rsDetectionWindow=disable then RIMRS not detected, then Check Fault 7527 canceled, and DL Mitigation stopped,
    ...    set targetTotalLoad=0, then 7525 canceled
    ...
    ...    1. set rsDetectionWindow=disable on victim cell, wait 7527 and 7535 disappear
    ...    2. set targetTotalLoad=0 on aggressor, and wait 7525 disappear
    ...    3. check from history alarm, should contain 7525 and 7527
    ...    4. capture bip log and check Special+DL symbols all scheduled from bip log
    ...    srs_check: Value can be "exist" or "not exist" or ${False},filter uldata_srsreceivereq from BIP log,
    ...               pSRS should disable after 7525, and resume after 7525 disappear (precondition nidd:actUlSrsBm=true, actDlSrsBm=true)
    [Arguments]       ${SetId_Aggressor}    ${dlMuteSlotsStr}     ${pdsch_slot_list}=${MUTE_SLOT_LIST}
    ...    ${is_pdsch_scheduled_on_s_d_slot}=${True}    ${connection_victim}=${OAM_ALIAS_GNB1}
    ...    ${feature}=6991    ${srs_check}=${False}    ${7527_timeout}=10min
    ...    ${after_ri}=${False}    ${exp_dl_tput_gap}=5    ${exp_ul_tput_gap}=3    ${target_file_name}=after_RI
    ...    ${check_rs_detect_false}=${False}    ${sleep_time}=3min    ${setId_show_in_fault}=${False}
    ...    ${check_pcmd_setid_reset}=${False}    ${tcpdump_collector_name}=PCMD_RIMRS_DETCT_DISABLE
    ...    ${cm_ri_state}=off    ${cm_rimrssetid_state}=off    ${cm_dlmuting_state}=off
    ...    ${actRimPdcchMutingOnSpecialSlot}=false    ${riState}=not check
    ${supplementary}    Get Supplementary for Fault 7527    ${SetId_Aggressor}    ${dlMuteSlotsStr}    ${feature}    ${setId_show_in_fault}
    ${supplementary_7535}    Get Supplementary for Fault 7535    ${dlMuteSlotsStr}

    run keyword and continue on failure    run keyword if     ${check_pcmd_setid_reset} and '${PROGRAM}'>='24R3'
    ...    Start Capture PCMD with filter port      tcpdump_collector_name=${tcpdump_collector_name}

    # set rsDetectionWindow=disable on victim cell, wait and verify fault 7527 and 7535 disappeared but 7525 still exist
    Set rsDetectionWindow via restAPI    paras=${RESTAPI_rsDetectionWindow_disable}

    run keyword and continue on failure    Wait and Verify Fault 7527 not Present on Cells    7527_check_timeout=${7527_timeout}
    ...    cm_rimrssetid_state=${cm_rimrssetid_state}
    run keyword and continue on failure    run keyword if   '${PROGRAM}'>='24R3'   Wait and Verify Fault 7535 not Present on Cells
    ...    cm_dlmuting_state=${cm_dlmuting_state}    actRimPdcchMutingOnSpecialSlot=${actRimPdcchMutingOnSpecialSlot}
    ...    CM_check_timeout=1min
    AlarmWatchdog.remove_allow_alarms    fault_id=7527
    AlarmWatchdog.remove_allow_alarms    fault_id=7535

    run keyword and continue on failure    Wait and Verify Fault Present on Cells    faultId=7525
                                                                    ...    alarm_check_timeout=10sec
                                                                    ...    alarm_check_interval=3sec
                                                                    ...    cm_ri_state=${cm_ri_state}
                                                                    ...    riState=${riState}
                                                                    ...    CM_check_timeout=10sec
    run keyword and continue on failure    run keyword if     ${check_pcmd_setid_reset} and '${PROGRAM}'>='24R3'
    ...    Stop Tcpdump and Check RIMRS Setid Reset from PCMD log    tcpdump_collector_name=${tcpdump_collector_name}

    run keyword and continue on failure    Captrue bip logs and Check RimRs Detection disable   target_file_name=${target_file_name}_rs_detct_disable

    coam_gnb_classical.COAM Update several parameters via rest api
        ...    parameters_to_update_via_api=${RESTAPI_MODIFY_NO_TARGET_TOTAL_LOAD}
        ...    skip_parameter_relation_errors=${False}
        ...    connection=${connection_victim}
        ...    timeout=${120}
    run keyword and continue on failure    Lock cells

    run keyword and continue on failure    Wait and Verify Fault 7525 not Present on Cells
    ...    cm_ri_state=${cm_ri_state}
    AlarmWatchdog.remove_allow_alarms    fault_id=7525

    # check from history alarm, should contain 7525, 7527 and 7535
    run keyword and continue on failure    Run Keyword If    '${cm_ri_state}' == 'off'
    ...    Wait and Verify Expect Fault Present or not from History List on Cells
                                                        ...    faultId=7525
                                                        ...    expect_present=${True}
    run keyword and continue on failure    Run Keyword If    '${cm_rimrssetid_state}' == 'off'
    ...    Wait and Verify Expect Fault Present or not from History List on Cells
                                                        ...    faultId=7527
                                                        ...    expect_present=${True}
	run keyword and continue on failure    run keyword if   '${PROGRAM}'>='24R3' and '${cm_dlmuting_state}' == 'off'
                            ...    Expect Fault Present or not from History List on Cells    faultId=7535
                                                        ...    expect_present=${True}
                                                        ...    supplementary=${supplementary_7535}

    # capture bip log and check Special+DL symbols all scheduled from bip log
    run keyword and continue on failure    L3 call and check tput for each cell    cell_id=${TDD_CELL_ID}
                                                                            ...    dl_tput=${DL_TPUT}
                                                                            ...    ul_tput=${UL_TPUT}
                                                                            ...    exp_dl=${TDD_DL_EXP_TPUT}
                                                                            ...    exp_ul=${TDD_UL_EXP_TPUT}
                                                                            ...    customized_log_name=afterRI
                                                                            ...    after_ri=${after_ri}
                                                                            ...    exp_dl_tput_gap=${exp_dl_tput_gap}
                                                                            ...    exp_ul_tput_gap=${exp_ul_tput_gap}
    run keyword if   ${check_rs_detect_false}    sleep   ${sleep_time}    Wait for 1st RIM-RS PT to check rs revalidate stop and srs recover
    run keyword and continue on failure    Captrue bip then Stop Traffic Detach UE and Check if DL and S slot scheduled on Aggressor
                                                           ...    is_pdsch_scheduled_on_s_d_slot=${is_pdsch_scheduled_on_s_d_slot}
                                                           ...    pdsch_slot_list=${pdsch_slot_list}
                                                           ...    target_file_name=l1l2bip_log_after_RI_1
                                                           ...    srs_check=${srs_check}
                                                           ...    check_rs_detect_false=${check_rs_detect_false}
    [Teardown]   run keyword and ignore error    Stop data transfer and detach UE

Steps set rsDetectionWindow SUU then Check Fault 7527 and 7535 cancel
    [Documentation]    Author: Wang Yixiang
    ...    Description: check after set rsDetectionWindow=special+2UL slots, wait and verify fault 7527 and 7535 disappeared but 7525 still exist
    [Arguments]   ${dlMuteSlotsStr}
    ${supplementary_7535}    Get Supplementary for Fault 7535    ${dlMuteSlotsStr}
    # set rsDetectionWindow=special+2UL slots, wait and verify fault 7527 and 7535 disappeared but 7525 still exist
    Set rsDetectionWindow via restAPI    paras=${RESTAPI_rsDetectionWindow_SUU}

    run keyword and continue on failure    Wait and Verify Fault 7527 not Present on Cells    7527_check_timeout=15min
#    run keyword and continue on failure    run keyword if   '${PROGRAM}'>='24R3'   Wait and Verify Fault 7535 not Present on Cells
    sleep    1s
	run keyword and continue on failure    run keyword if   '${PROGRAM}'>='24R3' and '${PROGRAM}'<'25R3'
                            ...    Expect Fault Present or not from History List on Cells    faultId=7535
                                                        ...    expect_present=${True}
                                                        ...    supplementary=${supplementary_7535}
    run keyword and continue on failure    Wait and Verify Fault Present on Cells    faultId=7525
                                                                    ...    alarm_check_timeout=20sec
                                                                    ...    alarm_check_interval=10sec

Steps enable RSDistanceThreshold and Check Fault cancel
   [Documentation]    Author: Cheng Catherine
    ...    Description:  Steps Set RSDistanceThreshold to 10 and Check Fault 7527 7535 cancel
    [Arguments]       ${7527_wait_time}=10min    ${7535_wait_time}=3min
    ...         ${cm_rimrssetid_state}=off    ${cm_dlmuting_state}=off
    ...         ${actRimPdcchMutingOnSpecialSlot}=false
    Set victim rsDistanceThreshold via restAPI    ${RESTAPI_rsDistanceThreshold_10}
    run keyword and continue on failure    Wait and Verify Fault 7527 not Present on Cells    7527_check_timeout=${7527_wait_time}
    ...    cm_rimrssetid_state=${cm_rimrssetid_state}

    run keyword and continue on failure    Wait and Verify Fault 7535 not Present on Cells    7535_check_timeout=${7535_wait_time}
    ...    cm_dlmuting_state=${cm_dlmuting_state}    actRimPdcchMutingOnSpecialSlot=${actRimPdcchMutingOnSpecialSlot}
    ...    CM_check_timeout=1min


Steps disable RSDistanceThreshold and Check Fault raised
   [Documentation]    Author: Cheng Catherine
    ...    Description:  Steps Set RSDistanceThreshold to 0 and Check Fault 7527 7535 raised
    [Arguments]   ${SetId_Aggressor}    ${dlMuteSlotsStr}    ${feature}=6991    ${alarm_check_timeout}=30m    ${setId_show_in_fault}=${False}
    ...         ${cm_rimrssetid_state}=off    ${cm_dlmuting_state}=off    ${rimRsSetIdType1}=not check    ${rimRsSetIdType2}=not check
    ...         ${pdcchMutingStatus}=not check    ${pdschMutingStatus}=not check
    ${supplementary}    Get Supplementary for Fault 7527    ${SetId_Aggressor}    ${dlMuteSlotsStr}    ${feature}    ${setId_show_in_fault}
    ${supplementary_7535}    Get Supplementary for Fault 7535    ${dlMuteSlotsStr}
    Set victim rsDistanceThreshold via restAPI    ${RESTAPI_rsDistanceThreshold_0}
    run keyword and continue on failure    Wait and Verify Fault Present on Cells    faultId=7527
                                                                    ...    alarm_check_timeout=${alarm_check_timeout}
                                                                    ...    alarm_check_interval=1min
                                                                    ...    supplementary=${supplementary}
                                                                    ...    cm_rimrssetid_state=${cm_rimrssetid_state}
                                                                    ...    CM_check_timeout=30min
                                                                    ...    rimRsSetIdType1=${rimRsSetIdType1}
                                                                    ...    rimRsSetIdType2=${rimRsSetIdType2}
    run keyword and continue on failure    run keyword if   '${PROGRAM}'>='24R3' and '${supplementary_7535}'!='${None}'
                            ...    Wait and Verify Fault Present on Cells    faultId=7535
                                                                    ...    alarm_check_timeout=1m
                                                                    ...    alarm_check_interval=10sec
                                                                    ...    supplementary=${supplementary_7535}
                                                                    ...    cm_dlmuting_state=${cm_dlmuting_state}
                                                                    ...    pdschMutingStatus=${pdschMutingStatus}
                                                                    ...    pdcchMutingStatus=${pdcchMutingStatus}
                                                                    ...    CM_check_timeout=1min

Get Supplementary for Fault 7527
    [Documentation]    Author: Cheng Catherine
    ...    Description:  Get Supplementary for Fault 7527
    ...    SetId_Aggressor: SetId for aggressor site
    ...    dlMuteSlotsStr: if dlMuteSlotsStr=${None} means no DL mitigation started
    ...    feature: for 6991 or 9823
    [Arguments]       ${SetId_Aggressor}    ${dlMuteSlotsStr}=${None}    ${feature}=6991    ${setId_show_in_fault}=${False}
    ${supplementary}    run keyword if    '${feature}'=='9823'    Get Supplementary for Fault 7527 for CB009823
    ...    SetId_Aggressor=${SetId_Aggressor}    dlMuteSlotsStr=${dlMuteSlotsStr}    setId_show_in_fault=${setId_show_in_fault}
    ...    ELSE IF    '${feature}'=='6991'    Get Supplementary for Fault 7527 for CB006991
    ...    SetId_Aggressor=${SetId_Aggressor}    dlMuteSlotsStr=${dlMuteSlotsStr}    setId_show_in_fault=${setId_show_in_fault}
    [Return]     ${supplementary}

Get Supplementary for Fault 7527 for CB009823
    [Documentation]    Author: Cheng Catherine
    ...    Description:  Get Supplementary for Fault 7527
    ...    SetId_Aggressor: SetId for aggressor site
    ...    dlMuteSlotsStr: if dlMuteSlotsStr=${None} means no DL mitigation started, dl mitiagtion info move to fault 7535 on 24R3
    ...    setId_show_in_fault: setid display in fault 7527 when setId_show_in_fault equals to true on 24R3
    ...    feature: for 9823 Get Supplementary for Fault 7527 for CB009823
    [Arguments]       ${SetId_Aggressor}    ${dlMuteSlotsStr}=${None}    ${setId_show_in_fault}=${False}

    ${supplementary}    set variable if
    ...    '${dlMuteSlotsStr}'=='${None}' and '${PROGRAM}'<='24R2'   RIM RS1 and RS2 is detected
    ...    '${dlMuteSlotsStr}'!='${None}' and '${PROGRAM}'<='24R2'   RIM RS1 and RS2 is detected, DL muting in ${dlMuteSlotsStr}
    ...    '${setId_show_in_fault}'=='${False}' and '${PROGRAM}'=='24R3'   RIM RS1 and RS2 is detected
    ...    '${setId_show_in_fault}'=='${False}' and '${PROGRAM}'>'24R3'   Both RIM RS1 and RS2 are detected
    ...    '${setId_show_in_fault}'=='${True}' and '${PROGRAM}'=='24R3'
    ...    RIM RS1 and RS2 is detected, detected RIM RS1 setIDs list is ${SetId_Aggressor}, detected RIM RS2 setIDs list is ${SetId_Aggressor}
    ...    '${setId_show_in_fault}'=='${True}' and '${PROGRAM}'>'24R3'
    ...    Both RIM RS1 and RS2 are detected, detected RIM RS1 setIDs list is ${SetId_Aggressor}, detected RIM RS2 setIDs list is ${SetId_Aggressor}


    [Return]     ${supplementary}

Get Supplementary for Fault 7527 for CB006991
    [Documentation]    Author: Cheng Catherine
    ...    Description:  Get Supplementary for Fault 7527
    ...    SetId_Aggressor: SetId for aggressor site
    ...    dlMuteSlotsStr: if dlMuteSlotsStr=${None} means no DL mitigation started, dl mitiagtion info move to fault 7535 on 24R3
    ...    setId_show_in_fault: setid display in fault 7527 when setId_show_in_fault equals to true on 24R3
    ...    feature: for 6991
    [Arguments]       ${SetId_Aggressor}    ${dlMuteSlotsStr}=${None}    ${setId_show_in_fault}=${False}
    ${supplementary}    set variable if
    ...    '${dlMuteSlotsStr}'=='${None}' and '${PROGRAM}'<'24R2'
    ...                                           RIM-RS detected with set-id: SetId=${SetId_Aggressor}
    ...    '${dlMuteSlotsStr}'=='${None}' and '${PROGRAM}'=='24R2'   RIM RS1 is detected
    ...    '${dlMuteSlotsStr}'!='${None}' and '${PROGRAM}'<'24R2'
    ...                                           RIM-RS detected with set-id: SetId=${SetId_Aggressor}, DL muting in ${dlMuteSlotsStr}
    ...    '${dlMuteSlotsStr}'!='${None}' and '${PROGRAM}'=='24R2'
    ...                                           RIM RS1 is detected, DL muting in ${dlMuteSlotsStr}
    ...    '${setId_show_in_fault}'=='${False}' and '${PROGRAM}'>='24R3'   RIM RS1 is detected
    ...    '${setId_show_in_fault}'=='${True}' and '${PROGRAM}'>='24R3'    RIM RS1 is detected, detected RIM RS1 setIDs list is ${SetId_Aggressor}
    [Return]     ${supplementary}


Get Supplementary for Fault 7535
    [Documentation]    Author: Wang Yixiang
    ...    Description:  Get Supplementary for Fault 7535
    ...    dlMuteSlotsStr: if dlMuteSlotsStr=${None} means no DL mitigation started
    ...    feature: for 6991 or 9823
    [Arguments]       ${dlMuteSlotsStr}
    ${rimrs_mute_pdsch}    set variable      DL mitigation on PDSCH
    ${supplementary}    set variable if
    ...    '${dlMuteSlotsStr}'!='${None}' and '${PROGRAM}'>='24R3'   ${rimrs_mute_pdsch} ${dlMuteSlotsStr}     ${None}
    [Return]     ${supplementary}

Steps Check PM Counters for RI and RIMRS
    [Documentation]    Author: Cheng Catherine
    ...    Description:  Check PM Counters for RI and RIMRS1 or RIMRS2 (TODO: RSIMRS2 counters to be added)
    ...    Here are counters for RI:
    ...    M55194C00001	NUM_UL_SYMB_IMPACT_RI. This counter is updated with the latest measured RI slope length
    ...    M55194C00002	DUR_UL_IMPACT_RI. This counter is incremented by 1 after each 1 s period if RI sloping
    ...                 was detected during the last RI monitoring window.
    ...    M55194C00009	AVG_RSSI_1_SYMB_UL_DL_SW_SB0. Each SB contains 20Mhz, e.g chBW=30Mhz means SB0 and SB1 is measured
    ...    M55194C00010	AVG_RSSI_1_SYMB_UL_DL_SW_SB1
    ...    M55194C00011	AVG_RSSI_1_SYMB_UL_DL_SW_SB2
    ...    M55194C00012	AVG_RSSI_1_SYMB_UL_DL_SW_SB3
    ...    M55194C00013	AVG_RSSI_1_SYMB_UL_DL_SW_SB4
    ...    Here are counters for Mitigation:
    ...    M55194C00003	DUR_DL_SPCL_MUT_RIM_MITG
    ...    M55194C00004	DUR_DL_MUT_RIM_MITG(before 13138), TODO: M55194C00281 DUR_1ST_DL_MUT_RIM_MITG(after 13138)
    ...    M55194C00282 DUR_2ND_DL_MUT_RIM_MITG
    ...    Here are counters for RIMRS1:
    ...    M55194C00005	NUM_RIM_RS_TYP_1_SETID_CONF. Should equal to nums of setid from victim gnb
    ...    M55194C00006	NUM_RIM_RS_TYP_2_SETID_CONF. Should equal to nums of setid from victim gnb
    ...    M55194C00007	NUM_RIM_RS_TYP_1_SETID_SUSP. Counters only updated with last measurement interval, so >=0 is all possible
    ...    M55194C00008	NUM_RIM_RS_TYP_2_SETID_SUSP. Counters only updated with last measurement interval, so >=0 is all possible
    ...    M55308C22008 RIM_RS_NEW_DET_EXP, counters for new detect RimRS ,so >0 is all possible
    ...    Here are counters for RIMRS2:TODO

    [Arguments]   ${list_measurement_ids}    ${ul_ri_symbols}    ${rimrs_setid_num}    ${reporting_interval}=5
    ...     ${RSSI_SB0}=${True}    ${RSSI_SB1}=${True}    ${RSSI_SB2}=${True}    ${RSSI_SB3}=${True}    ${RSSI_SB4}=${True}
    ...    ${cell_check_list}=${TDD_CELL_ID_LIST}    ${Check_RI}=${True}    ${Check_Mitigation}=${True}    ${Check_RIMRS1}=${True}
    ...    ${Check_RIMRS2}=${False}   ${Check_RIMRS_new_DET_EXP}=${False}
    ...    ${is_sl_mute}=${True}    ${is_1st_dl_mute}=${True}    ${is_2nd_dl_mute}=${False}
    ${start_time}    Prepare for counter log    reporting_interval=${reporting_interval}
    ${pm_files_local_path}    Wait for PM file generated and download    starting_log_timestamp=${start_time['log_generator_timestamp']}

    ${cell_id}    set variable   ${cell_check_list[0]}
    FOR    ${file_path}    IN    @{pm_files_local_path}
        ${dict_meas_val}    counter.get_cell_counters_from_file    file_path=${file_path}
                                                        ...      list_cell=${cell_check_list}
                                                        ...      list_measurement_ids=${list_measurement_ids}
        run keyword and continue on failure    run keyword if    ${Check_RI}    Check PM Counters for RI
                                                                                    ...    ${dict_meas_val}
                                                                                    ...    ${cell_id}
                                                                                    ...    ${ul_ri_symbols}
                                                                                    ...    RSSI_SB0=${RSSI_SB0}
                                                                                    ...    RSSI_SB1=${RSSI_SB1}
                                                                                    ...    RSSI_SB2=${RSSI_SB2}
                                                                                    ...    RSSI_SB3=${RSSI_SB3}
                                                                                    ...    RSSI_SB4=${RSSI_SB4}
        run keyword and continue on failure    run keyword if    ${Check_Mitigation}    Check PM Counters for Mitigation
                                                                                    ...    ${dict_meas_val}
                                                                                    ...    ${cell_id}
                                                                                    ...    is_sl_mute=${is_sl_mute}
                                                                                    ...    is_1st_dl_mute=${is_1st_dl_mute}
                                                                                    ...    is_2nd_dl_mute=${is_2nd_dl_mute}
        run keyword and continue on failure    run keyword if    ${Check_RIMRS1}    Check PM Counters for RIMRS1
                                                                                    ...    ${dict_meas_val}
                                                                                    ...    ${cell_id}
                                                                                    ...    ${rimrs_setid_num}
        run keyword and continue on failure    run keyword if    ${Check_RIMRS_new_DET_EXP}    Check PM Counters for RIMRS newdetect
                                                                                    ...    ${dict_meas_val}
                                                                                    ...    ${cell_id}
        run keyword and continue on failure    run keyword if    ${Check_RIMRS2}    Check PM Counters for RIMRS2
                                                                                    ...    ${dict_meas_val}
                                                                                    ...    ${cell_id}
                                                                                    ...    ${rimrs_setid_num}
    END


Check PM Counters for RI
    [Documentation]    Author: Cheng Catherine
    ...    Description:  Check PM Counters for RI and RIMRS1
    ...    M55194C00001	NUM_UL_SYMB_IMPACT_RI. This counter is updated with the latest measured RI slope length
    ...    M55194C00002	DUR_UL_IMPACT_RI. This counter is incremented by 1 after each 1 s period if RI sloping
    ...                 was detected during the last RI monitoring window.
    ...    M55194C00005	NUM_RIM_RS_TYP_1_SETID_CONF. Should equal to nums of setid from victim gnb
    ...    M55194C00007	NUM_RIM_RS_TYP_1_SETID_SUSP. Counters only updated with last measurement interval, so >=0 is all possible
    ...    M55194C00009	AVG_RSSI_1_SYMB_UL_DL_SW_SB0. Each SB contains 20Mhz, e.g chBW=30Mhz means SB0 and SB1 is measured
    ...    M55194C00010	AVG_RSSI_1_SYMB_UL_DL_SW_SB1
    ...    M55194C00011	AVG_RSSI_1_SYMB_UL_DL_SW_SB2
    ...    M55194C00012	AVG_RSSI_1_SYMB_UL_DL_SW_SB3
    ...    M55194C00013	AVG_RSSI_1_SYMB_UL_DL_SW_SB4
    [Arguments]   ${dict_meas_val}     ${cell_id}    ${ul_ri_symbols}    ${RSSI_SB0}=${True}   ${RSSI_SB1}=${True}
    ...    ${RSSI_SB2}=${True}    ${RSSI_SB3}=${True}    ${RSSI_SB4}=${True}
    ${no_rssi_value}    set variable   0.00
    ${rssi_sb0_actual}    set variable     ${dict_meas_val['${cell_id}']['M55194C00009']}
    ${rssi_sb1_actual}    set variable     ${dict_meas_val['${cell_id}']['M55194C00010']}
    ${rssi_sb2_actual}    set variable     ${dict_meas_val['${cell_id}']['M55194C00011']}
    ${rssi_sb3_actual}    set variable     ${dict_meas_val['${cell_id}']['M55194C00012']}
    ${rssi_sb4_actual}    set variable     ${dict_meas_val['${cell_id}']['M55194C00013']}
    ${ul_ri_symbols_actual}    convert to integer    ${dict_meas_val['${cell_id}']['M55194C00001']}
    ${ul_ri_symbols_expect}    convert to integer    ${ul_ri_symbols}
    ${ul_ri_symbols_expect_min}    evaluate    ${ul_ri_symbols_expect}-${2}
    ${ul_ri_symbols_expect_max}    evaluate    ${ul_ri_symbols_expect}+${1}
    ${dur_ul_impact}    set variable   ${dict_meas_val['${cell_id}']['M55194C00002']}
    run keyword and continue on failure     should be true
        ...    ${ul_ri_symbols_actual}<=${ul_ri_symbols_expect_max} and ${ul_ri_symbols_actual}>=${ul_ri_symbols_expect_min}
    run keyword and continue on failure     should be true    '${dur_ul_impact}'=='299' or '${dur_ul_impact}'=='300' or '${dur_ul_impact}'=='301'
    run keyword and continue on failure
        ...    run keyword if    ${RSSI_SB0}     should not be equal as strings    ${rssi_sb0_actual}   ${no_rssi_value}
        ...    ELSE     should be equal as strings    ${rssi_sb0_actual}   ${no_rssi_value}
    run keyword and continue on failure
        ...    run keyword if    ${RSSI_SB1}     should not be equal as strings    ${rssi_sb1_actual}   ${no_rssi_value}
        ...    ELSE     should be equal as strings    ${rssi_sb1_actual}   ${no_rssi_value}
    run keyword and continue on failure
        ...    run keyword if    ${RSSI_SB2}     should not be equal as strings    ${rssi_sb2_actual}   ${no_rssi_value}
        ...    ELSE     should be equal as strings    ${rssi_sb2_actual}   ${no_rssi_value}
    run keyword and continue on failure
        ...    run keyword if    ${RSSI_SB3}     should not be equal as strings    ${rssi_sb3_actual}   ${no_rssi_value}
        ...    ELSE     should be equal as strings    ${rssi_sb3_actual}   ${no_rssi_value}
    run keyword and continue on failure
        ...    run keyword if    ${RSSI_SB4}     should not be equal as strings    ${rssi_sb4_actual}   ${no_rssi_value}
        ...    ELSE     should be equal as strings    ${rssi_sb4_actual}   ${no_rssi_value}


Check PM Counters for Mitigation
    [Documentation]    Author: Cheng Catherine
    ...    Description:  Check PM Counters for Mitigation
    ...    M55194C00003	DUR_DL_SPCL_MUT_RIM_MITG
    ...    M55194C00004	DUR_DL_MUT_RIM_MITG(before 13138), TODO: M55194C00281 DUR_1ST_DL_MUT_RIM_MITG(after 13138)
    ...    M55194C00282 DUR_2ND_DL_MUT_RIM_MITG
    [Arguments]   ${dict_meas_val}     ${cell_id}    ${is_sl_mute}=${True}    ${is_1st_dl_mute}=${True}    ${is_2nd_dl_mute}=${False}
    ${dur_spcl_mut}    set variable     ${dict_meas_val['${cell_id}']['M55194C00003']}
    ${dur_dl_mut}    set variable     ${dict_meas_val['${cell_id}']['M55194C00004']}
    ${dur_dl_mut_after_13138}    set variable     ${dict_meas_val['${cell_id}']['M55194C00281']}
    ${dur_2nd_dl_mut}    set variable     ${dict_meas_val['${cell_id}']['M55194C00282']}
    ${dur_dl_mut}    set variable if    '${PROGRAM}'>='25R1'    ${dur_dl_mut_after_13138}    ${dur_dl_mut}
    run keyword and continue on failure    run keyword if    ${is_sl_mute}
    ...    should be true    '${dur_spcl_mut}'=='299.0' or '${dur_spcl_mut}'=='300.0' or '${dur_spcl_mut}'=='301.0'
    run keyword and continue on failure    run keyword if    ${is_1st_dl_mute}
    ...    should be true    '${dur_dl_mut}'=='299.0' or '${dur_dl_mut}'=='300.0' or '${dur_dl_mut}'=='301.0'
    run keyword and continue on failure    run keyword if    ${is_2nd_dl_mute}
    ...    should be true    '${dur_2nd_dl_mut}'=='299.0' or '${dur_2nd_dl_mut}'=='300.0' or '${dur_2nd_dl_mut}'=='301.0'


Check PM Counters for RIMRS1
    [Documentation]    Author: Cheng Catherine
    ...    Description:  Check PM Counters for RIMRS1
    ...    M55194C00005	NUM_RIM_RS_TYP_1_SETID_CONF. Should equal to nums of setid from victim gnb
    ...    M55194C00007	NUM_RIM_RS_TYP_1_SETID_SUSP. Counters only updated with last measurement interval, so >=0 is all possible
    [Arguments]   ${dict_meas_val}     ${cell_id}    ${rimrs_setid_num}
    run keyword and continue on failure     should be equal as strings    ${dict_meas_val['${cell_id}']['M55194C00005']}   ${rimrs_setid_num}
    run keyword and continue on failure     should be true    '${dict_meas_val['${cell_id}']['M55194C00007']}'>='0'

Check PM Counters for RIMRS newdetect
    [Documentation]    Author: Fang Ludan
    ...    Description:  Check PM Counters for RIMRS newdetect EXP
    ...    M55308C22008	 RIM_RS_NEW_DET_EXP
    [Arguments]   ${dict_meas_val}     ${cell_id}
    run keyword and continue on failure     should be true    '${dict_meas_val['${cell_id}']['M55308C22008']}'>='0'

Check PM Counters for RIMRS2
    [Documentation]    Author: Cheng Catherine
    ...    Description:  Check PM Counters for RIMRS1
    ...    M55194C00005	NUM_RIM_RS_TYP_2_SETID_CONF. Should equal to nums of setid from victim gnb
    ...    M55194C00007	NUM_RIM_RS_TYP_2_SETID_SUSP. Counters only updated with last measurement interval, so >=0 is all possible
    [Arguments]   ${dict_meas_val}     ${cell_id}    ${rimrs_setid_num}
    run keyword and continue on failure     should be equal as strings    ${dict_meas_val['${cell_id}']['M55194C00006']}   ${rimrs_setid_num}
    run keyword and continue on failure     should be true    '${dict_meas_val['${cell_id}']['M55194C00008']}'>='0'


Check RI state from aasyslog
    [Documentation]    Author: Jin Journey
    ...    Description: check RI state in aasyslog, involve isRiSuspected:1 and isRiDetected:1
    [Arguments]    ${log_path}
    ${RI_state_1}    Grep File    ${log_path}    isRiSuspected:1
    ${RI_state_2}    Grep File    ${log_path}    isRiDetected:1
    run keyword and continue on failure    Should Not Be Empty    ${RI_state_1}
    run keyword and continue on failure    Should Not Be Empty    ${RI_state_2}

Capture Bip log and Check UL mitigation after RI detected in bip log
    [Documentation]    Author: Jin Journey
    ...    check point1:srsBm is disable
    ...    check point2:S1B 1 powerRampingStep=nrRimPowerRampingStep is updated
    ...    check point3:Msg2 TPC=nrRimRarTpcCommand is updated, need to re-attach
    [Arguments]    ${asil_interface}=nac_eth2    ${mirroring_filter}=SpecificL1L2Messages
    Retry commercial ue detach if failed
    Connect to Common Unit Master
    Start Bip Capture for different program
    Retry commercial ue attach if failed    prepare_ue_needed=${False}
    ${bip_log}    Stop Bip Capture and Collect logs for different program    asil_interface=${asil_interface}    is_return_original_file=${True}
    run keyword and continue on failure    Verify TPC value is updated in msg2    ${bip_log[-1]}
    run keyword and continue on failure    Verify PRACH power ramping step is updated in SIB1    log_path=${bip_log[-1]}

    Retry commercial ue detach if failed
    run keyword and continue on failure    L3 call and check tput for each cell    cell_id=${TDD_CELL_ID}    dl_tput=${DL_TPUT}
    ...    ul_tput=${UL_TPUT}    exp_dl=${TDD_DL_EXP_TPUT}    exp_ul=${TDD_UL_EXP_TPUT}    tput_check=${False}
    ${bip_log_srs}    Collect Bip logs and Return Files Path    target_file_name=bip_log_srs    capture_time=3s
    ...    mirroring_filter=${mirroring_filter}    specific_message_ids=${MESSAGE_ID_SRS_RECEIVE_REQ}
    run keyword and continue on failure    Verify srsBm is enabled or disabled from bip log    log_path=${bip_log_srs[-1]}
    ...    feature=8249    srsBmEnable=False

    [Teardown]   run keyword and ignore error    Stop data transfer and detach UE

Verify srsBm is enabled or disabled from bip log
    [Documentation]    Author: Jin Journey
    ...    Description:filter uldata_srsreceivereq
    ...    get the value of field UlData_srsReceiveReqSubcell_t.srsBmEnable
    ...    value should be equal 0, means srsBm disabled; catherine 20241212: uldata_srsreceivereq not sent when 25R2
    [Arguments]    ${log_path}    ${feature}=9823    ${srsBmEnable}=False
    ${filter}    set variable    uldata_srsreceivereq
    ${srsBmEnable_list_expected}    create list    ${srsBmEnable}
    pcap.setup    infile=${log_path}    display_filter=${filter}
    ${srsBmEnable_list}    pcap.get_field_value_by_name    field_name=UlData_srsReceiveReqSubcell_t.srsBmEnable    attribute_name=show
    ${srsBmEnable_expect_count}    evaluate    ${srsBmEnable_list}.count('${srsBmEnable}')
    ${all_srs_false_list}    pcap.get_field_value_by_name    field_name=${ALL_SRS_FALSE_FILTER}    attribute_name=show
    ${all_srs_false_list_length}    Get Length   ${all_srs_false_list}

    run keyword if    '${feature}'=='8249' and '${srsBmEnable}'=='False' and '${PROGRAM}'>='25R2'    Should Be Empty    ${srsBmEnable_list}
    ...    ELSE IF     '${feature}'!='8249' and '${srsBmEnable}'=='False'    should be empty    ${srsBmEnable_list}
    ...    ELSE    Should Be True    ${srsBmEnable_expect_count}>${0} and ${all_srs_false_list_length}==${0}

Verify PRACH power ramping step is updated in SIB1
    [Documentation]    Author: Jin Journey
    ...    Description:filter dldata_pdschpayloadtbsendreq
    ...    get the value of field nr-rrc.powerRampingStep
    ...    value should be equal nidd nrRimPowerRampingStep, "3" means 6db
    [Arguments]    ${log_path}
    ${filter}    set variable if    '${PROGRAM}'>='25R2'    dldata_pdschpayloadtbsendreql1sw    dldata_pdschpayloadtbsendreq
    pcap.setup    infile=${log_path}    display_filter=${filter}
    ${powerRampingStep_list}    pcap.get_field_value_by_name    field_name=nr-rrc.powerRampingStep    attribute_name=show
    @{powerRampingStep_list_unique}    Evaluate    set(${powerRampingStep_list})
    ${len}    Get Length    ${powerRampingStep_list_unique}
    should be equal as integers    ${len}    1
    should be equal as integers    ${powerRampingStep_list_unique[0]}    3

Verify TPC value is updated in msg2
    [Documentation]  Author: Jin Journey
    ...    Description:filter dldata_pdschpayloadtbsendreq
    ...    get the value of field mac-nr.rar.grant.tcsp, value should be equal nidd nrRimRarTpcCommand, "7" means 8db
    [Arguments]    ${log_path}
    ${filter}    set variable if    '${PROGRAM}'>='25R2'    dldata_pdschpayloadtbsendreql1sw    dldata_pdschpayloadtbsendreq
    pcap.setup    infile=${log_path}    display_filter=${filter}
    ${tpc_list}    pcap.get_field_value_by_name    field_name=mac-nr.rar.grant.tcsp    attribute_name=show
    @{tpc_list_unique}    Evaluate    set(${tpc_list})
    ${len}    Get Length    ${tpc_list_unique}
    should be equal as integers    ${len}    1
    should be equal as integers    ${tpc_list_unique[0]}    7

Get NRRIMINFO via WEBEM and Check NRRIMINFO Value is as Expected
    [Documentation]    Author: Catherine Cheng
    ...    1. Get NRRIMINFO via WEBEM
    ...    nrriminfo_dict_expect: dict nrriminfo, e.g.
    ...    {
    ...        "asymmetricState": "not asymmetric",
    ...        "dlMutingState": {"pdcchMutingStatus":None, "pdschMutingStatus":None},
    ...        "riState": "no RI",
    ...        "rimRsSetIdType1": [],
    ...        "rimRsSetIdType2": []}
    ...    2. Check following values are same with NRRIMINFO get from WEBEM
    ...    and also check worstRimRSSI, worstRimSsbId, worstRimSubbId are not empty on WEBEM
    ...    asymmetricState: not check： means not check this value; ${None} means empty on WEBEM
    ...    riState: not check, means not check this value; ${None} means empty on WEBEM
    ...    rimRsSetIdType1: not check, means not check this value; ${None} means empty on WEBEM; multi-setid supported, e.g 1112,1223
    ...    rimRsSetIdType2: not check, means not check this value; ${None} means empty on WEBEM; multi-setid supported, e.g 1112,1223
    ...    pdcchMutingStatus: not check means not check this value; ${None} means empty on WEBEM
    ...    pdschMutingStatus: not check means not check this value; ${None} means empty on WEBEM
    [Arguments]    ${asymmetricState}=not check    ${riState}=not check    ${rimRsSetIdType1}=not check
    ...    ${rimRsSetIdType2}=not check     ${pdcchMutingStatus}=not check    ${pdschMutingStatus}=not check
    ...    ${cell_id}=${1}    ${connection}=GNB_OAM
    ${nrriminfo_dict_get}     get_bts_info.get_nrriminfo_based_on_cell_id     cell_id=${cell_id}    connection_alias=${connection}
    # change setid to string
    ${rimRsSetIdType1_get}    create list
    FOR   ${i}    IN RANGE    len(${nrriminfo_dict_get['rimRsSetIdType1']})
        ${setid_str}    convert to string    ${${nrriminfo_dict_get['rimRsSetIdType1'][${i}]}}
        Append To List    ${rimRsSetIdType1_get}    ${setid_str}
    END
    ${rimRsSetIdType2_get}    create list
    FOR   ${i}    IN RANGE    len(${nrriminfo_dict_get['rimRsSetIdType2']})
        ${setid_str}    convert to string    ${${nrriminfo_dict_get['rimRsSetIdType2'][${i}]}}
        Append To List    ${rimRsSetIdType2_get}    ${setid_str}
    END
    Sort List    ${rimRsSetIdType1_get}
    Sort List    ${rimRsSetIdType2_get}
    # ${worstRimRSSI}    Pop From Dictionary     ${nrriminfo_dict_get}     worstRimRSSI
    # ${worstRimSsbId}    Pop From Dictionary     ${nrriminfo_dict_get}     worstRimSsbId
    # ${worstRimSubbId}    Pop From Dictionary     ${nrriminfo_dict_get}     worstRimSubbId
    ${rimRsSetIdType1_list}    string2list    ${rimRsSetIdType1}
    ${rimRsSetIdType2_list}    string2list    ${rimRsSetIdType2}
    Sort List    ${rimRsSetIdType1_list}
    Sort List    ${rimRsSetIdType2_list}
    run keyword if     '${asymmetricState}' != 'not check'
    ...    should be equal as strings     ${nrriminfo_dict_get['asymmetricState']}    ${asymmetricState}
    run keyword if     '${riState}' != 'not check'
    ...    should be equal as strings     ${nrriminfo_dict_get['riState']}    ${riState}
    run keyword if     '${rimRsSetIdType1}' == '${None}'    should be true    len(${rimRsSetIdType1_get}) == ${0}
    ...    ELSE IF    '${rimRsSetIdType1}' != 'not check'    Lists Should Be Equal     ${rimRsSetIdType1_get}    ${rimRsSetIdType1_list}
    run keyword if     '${rimRsSetIdType2}' == '${None}'    should be true    len(${rimRsSetIdType2_get}) == ${0}
    ...    ELSE IF    '${rimRsSetIdType2}' != 'not check'    Lists Should Be Equal     ${rimRsSetIdType2_get}    ${rimRsSetIdType2_list}
    run keyword if     '${pdcchMutingStatus}' != 'not check'    should be equal as strings
    ...    ${nrriminfo_dict_get['dlMutingState']['pdcchMutingStatus']}    ${pdcchMutingStatus}
    run keyword if     '${pdschMutingStatus}' != 'not check'    should be equal as strings
    ...     ${nrriminfo_dict_get['dlMutingState']['pdschMutingStatus']}    ${pdschMutingStatus}
    # should be true     '${worstRimRSSI}' != '${None}'
    # should be true     '${worstRimSsbId}' != '${None}'
    # should be true     '${worstRimSubbId}' != '${None}'

Wait and Get NRRIMINFO via WEBEM and Check NRRIMINFO Value is as Expected
    [Documentation]    Author: Catherine Cheng
    ...    Wait and Get NRRIMINFO via WEBEM and Check value is same with NRRIMINFO get from WEBEM
    ...    wait_time: wait time
    ...    time_interval: time interval
    ...    asymmetricState: not check： means not check this value; ${None} means empty on WEBEM
    ...    riState: not check, means not check this value; ${None} means empty on WEBEM
    ...    rimRsSetIdType1: not check, means not check this value; ${None} means empty on WEBEM
    ...    rimRsSetIdType2: not check, means not check this value; ${None} means empty on WEBEM
    ...    pdcchMutingStatus: not check means not check this value; ${None} means empty on WEBEM
    ...    pdschMutingStatus: not check means not check this value; ${None} means empty on WEBEM
    [Arguments]    ${wait_time}=30min    ${time_interval}=10s    ${asymmetricState}=not check    ${riState}=not check
    ...    ${rimRsSetIdType1}=not check    ${rimRsSetIdType2}=not check     ${pdcchMutingStatus}=not check    ${pdschMutingStatus}=not check
    ...    ${cell_id}=${1}    ${connection}=GNB_OAM
    Wait until keyword succeeds    ${wait_time}    ${time_interval}    Get NRRIMINFO via WEBEM and Check NRRIMINFO Value is as Expected
    ...    asymmetricState=${asymmetricState}    riState=${riState}    rimRsSetIdType1=${rimRsSetIdType1}
    ...    rimRsSetIdType2=${rimRsSetIdType2}    pdcchMutingStatus=${pdcchMutingStatus}    pdschMutingStatus=${pdschMutingStatus}
    ...    cell_id=${cell_id}    connection=${connection}
