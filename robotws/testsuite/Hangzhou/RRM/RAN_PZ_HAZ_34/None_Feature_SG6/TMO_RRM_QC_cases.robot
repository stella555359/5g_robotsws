*** Settings ***
Documentation    TMO Automation for TMO E2E CDRT cases
...              Author: lei.jia@nokia-sbell.com
Suite Setup    TMO_Common_Suite_Setup    is_commission=${True}
Test Teardown    TMO_Common_Case_Teardown
Suite Teardown    TMO_Suite_Teardown
Force Tags    5G_TOL    SG_06
...    PY36

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/TMO/TMO_common_keywords.robot
Resource    ../../../resources/RAN_PZ_HAZ_34/lines/SG6/Module_And_KW/interface_resource.robot


*** Test Cases ***
5603009_TOL_CB7922_IWK_CB5876_1UE_CA_TT_SA_call_InterRAT_HO_basedon_B2_measured_with_DL_data_forwarding_to_LTE
    [Documentation]    TL813:UE0, QC UE OK. handover from 5Gcell_301 to ltecell_11.
    ...                2023.12.14: FOR tl813, lock AHFIG cell21 to prevent a3/a5 event
    [Tags]    T813_QC    T080_QC    T073_QC
    [Setup]    TMO_Common_Case_Setup   ue_index=${CASE_FOR_B2_HO_CHOOSED_UE['${tl_prefix}']}
    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
    ${eutranCellId}    ${physicalCellId}    ${earfcnDL}    Get Some Related Parameters Of LTE Cell    cell_index=${LTE_CELL_INDEX}
    ...                                   enb_index=${fdd_enb_index}
    ${nrhoirDNList_value}    Get nrhoirDNList value From SCF    cell_id=${PCELL_INDEX}
    Set Test Variable    ${nrhoirDNList_value}
    Update Values Of Some Parameters    cell_index=${PCELL_INDEX}    lte_cell_earfcnDL=${earfcnDL}    nrhoirDNList_value=${nrhoirDNList_value}
    FOR    ${enb_index}    IN RANGE    ${enb_length}
        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
    END
    ${ru_type}    Set Variable If
    ... 	      '${tl_prefix}'=='T813' 	AHFIG
    ... 	      '${tl_prefix}'=='T073' 	AHFIB
    Run Keyword If    '${tl_prefix}'!='T080'     Lock AHFII FDD cells    ru_type=${ru_type}    cell_type=nr    ru_index=6
    ...    whether_get_first_ru_only=${True}    action=block
    Get Syslog Start Time
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${CASE_FOR_B2_HO_CHOOSED_UE['${tl_prefix}']}
    ${whether_do_ue_prepare}    Set Variable If    '${tl_prefix}'=='T080'     ${True}       ${False}
    Procedures.Verify CA Basic L3 Call    ue_index=${CASE_FOR_B2_HO_CHOOSED_UE['${tl_prefix}']}
    ...                                   ue_type=${ue_type}
    ...                                   ul_throughput=50M
    ...                                   dl_throughput=300MKbits/sec
    ...                                   tput_collect_duration=90
    ...                                   whether_need_ue_log=${False}
    ...                                   ignore_time=45sec
#    ...                                   whether_do_ue_prepare=${True}
    ...                                   check_pcell_tput_type=not_peak
    ...                                   check_scell_tput=${False}
    ...                                   whether_check_on_air=${False}
    ...                                   check_ul_pcell_tput_type=not_peak
    ...                                   whether_do_ue_prepare=${whether_do_ue_prepare}
    ...                                   enb_index=${fdd_enb_index}
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log
    ...    tcpdump_collector_name=sa_ho_lte
    ...    asik_connection_alias=ASIK Master
    ...    gnb_index=${0}
    Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=${LTE_CELL_INDEX}    enb_index=${fdd_enb_index}
    Get RU Index Of LTE Cell    cell_index=${LTE_CELL_INDEX}    enb_index=${fdd_enb_index}
    ${lte_cell_pa_value}=   Set Variable If     '${tl_prefix}'=='T073'     6
    ...                                         '${tl_prefix}'=='T080'     10
    ...                                         '${tl_prefix}'=='T813'     15
    Modify PA Value Setting For Required RU    modify_ru_id=${NSA_PA_RU_INDEX}    ue_index=${CASE_FOR_B2_HO_CHOOSED_UE['${tl_prefix}']}
    ...          pa_off_value=${lte_cell_pa_value}
    ${nr_cell_PA_HO}=   Set Variable If     '${tl_prefix}'=='T080'    10
    ...                                      '${tl_prefix}'=='T073'    70
    ...                                      '${tl_prefix}'=='T813'    48
    FOR    ${attenuator}    IN    @{attenuator_list}
        Run Keyword If    '${attenuator}'=='pa'    Modify PA Value Setting For Required RU    modify_ru_id=${PCELL_MAPPING['ru_index_mapping']}
        ...                                                                                   ue_index=${0}
        ...                                                                                   pa_off_value=${nr_cell_PA_HO}
        ...    ELSE IF    '${attenuator}'=='mcs'    Set Case Related MCS Port Value    att_value=40
        ...                                                                            ue_index=${0}
        ...                                                                            whether_do_mcs_setup=${False}
        ...    ELSE    Log To Console     ${\n}INFO: --Use the wrong attenuator type(${attenuator}), need to check TMO_Data.py--
    END
    Sleep    60sec
    ${sa_ho_lte_wireshark}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection    tcpdump_collector_name=sa_ho_lte
    ${syslog_file}    Run Keyword And Continue On Failure    Get Syslog File During Specific Time    syslog_start_time=${SYSLOG_START_TIME}
    ${syslog_file_path}    Run Keyword And Continue On Failure   Evaluate    '/'.join(${syslog_file.split('/')[0:-1]})
    Run Keyword And Ignore Error    Check ERR Or WRN From Syslog    sys_logs_path=${syslog_file_path}
    ...     UTE_logs_path=/home/ute/ERR_WRN_logs    Fail_Case=True    Check_RF_Log=True    timeout=50 minutes
    Run Keyword And Continue On Failure    Check ERR Syslog Existed
    # Check TUPT for ${LTE_CELL_INDEX} on enb/spark
    Run Keyword And Continue On Failure    Check InterRAT HO To LTE Success
    ...                                    log_path=${sa_ho_lte_wireshark}    eutranCellId=${eutranCellId}    physicalCellId=${physicalCellId}
#     Check measurement
#     Add fualt 49 in allowed history fault as "lock AHFIG cell21 to prevent a3/a5 event"
    &{fault_49}     Create Dictionary     faultId=${49}
    ${ALLOWED_HISTORY_FAULT}   Create List   @{ALLOWED_HISTORY_FAULT}   ${fault_49}
    Set Test Variable    ${ALLOWED_HISTORY_FAULT}
    Run Keyword And Continue On Failure    Check RU Calibration Status And Power on Specifc RU
#    ${syslog_file}    Run Keyword And Continue On Failure    Get Syslog File During Specific Time    syslog_start_time=${SYSLOG_START_TIME}
#    ${syslog_file_path}    Run Keyword And Continue On Failure   Evaluate    '/'.join(${syslog_file.split('/')[0:-1]})
#    Run Keyword And Continue On Failure    Check ERR Or WRN From Syslog    sys_logs_path=${syslog_file_path}
#    ...     UTE_logs_path=/home/ute/ERR_WRN_logs    Fail_Case=True    Check_RF_Log=True    timeout=50 minutes
    [Teardown]    Run Keywords    Lock AHFII FDD cells    ru_type=${ru_type}    cell_type=nr    ru_index=6
    ...                                              whether_get_first_ru_only=${True}    action=unblock
    ...                    AND    Update Values Of Some Parameters    cell_index=${PCELL_INDEX}
    ...                                                               lte_cell_earfcnDL=${earfcnDL}
    ...                                                               nrhoirDNList_value=${nrhoirDNList_value}
    ...                                                               a2ThresholdhoSsbRsrpSA_value=54
    ...                                                               b2Threshold1hoRsrp_value=42
    ...                                                               b2Threshold2hoRsrp_value=29
    ...                                                               a1ThresholdSCellAddSsbRsrpTDD_value=40
    ...                                                               a1ThresholdSCellAddSsbRsrpFDD_value=40
    ...                                                               a1ThresholdhoSsbRsrpSA_value=58
    ...                AND     TMO_Common_Case_Teardown    ue_index=${0}    ue_type=${ue_type}

5603078_TOL_case_78_SISO_Block_unBlock_cell_from_TDD_RF_reset_from_gNB
    [Documentation]    TL813:UE0-SDX65, AEHC0 5G SA call
    [Tags]    T813_QC    T080_QC    T073_QC
    [Setup]    TMO_Common_Case_Setup    whether_get_ca_info=${False}    whether_set_pa_value=${False}
    ${aehc_nr_cell_list}    Get Cell List For Special RU    cell_type=nr    whether_get_first_ru_only=${True}
    ${aehc_lte_cell_list}    Get Cell List For Special RU    cell_type=lte    whether_get_first_ru_only=${True}
    ${origin_aehc_nr_cell_list}    Copy List    ${aehc_nr_cell_list}
    ${origin_aehc_nr_cell_list_backup}    Copy List    ${aehc_nr_cell_list}
    ${origin_aehc_lte_cell_list}    Copy List    ${aehc_lte_cell_list}
    ${origin_aehc_lte_cell_list_backup}    Copy List    ${aehc_lte_cell_list}
    ${aehc_lte_cell_list_length}     Get Length    ${aehc_lte_cell_list}
    FOR    ${enb_index}    IN RANGE    ${enb_length}
        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
    END
    Get Syslog Start Time
    ${ue_index}  Set Variable If    '${tl_prefix}'=='T080'    0    0
    Run Keyword If   '${tl_prefix}'=='T080'       Multi-UE_Case_Setup    ue_index=${ue_index}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Run Keyword If    '${tl_prefix}'=='T080'    Procedures.Start UE Prepare    ue_index=${ue_index}
    ...               ue_type=${ue_type}
    # L3 call for nrcell-301 and nrcell-401, lncell-131 and lncell-141
#    Run Keyword If    '${tl_prefix}'=='T073'    Set Case Related MCS Port Value    ue_index=${ue_index}
#    ...    whether_do_mcs_setup=${True}    whether_do_Angles=${False}
    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
    Verify Non-CA Basic L3 Call One By One    cell_list=${origin_aehc_nr_cell_list}    ue_type=${ue_type}    ue_index=${ue_index}
    ...                                   enb_index=${fdd_enb_index}
    Run Keyword If    '${aehc_lte_cell_list_length}'!='${0}'      Verify 4G Non-CA Basic L3 Call One By One
    ...     cell_list=${origin_aehc_lte_cell_list}    ue_type=${ue_type}    ue_index=${ue_index}    whether_do_barred_action=${True}
    ## Below for operation(locked nrcell401 and reset gnb site)
    Log To Console     ${\n}INFO: Lock nrcell with Max id of one AEHC---
    ${nr_max_cell_id}    Remove From List    ${aehc_nr_cell_list}    -1
#    ${nr_min_cell_id}    Remove From List    ${aehc_nr_cell_list}    0
#    @{nr_min_cell}    Create list     ${nr_min_cell_id}
    Do Type Cell Action Then Verify Status And Alarm    cell_index=${nr_max_cell_id}    cell_action=locked    cell_type=nr
    # L3 call for nrcell-301,lncell-131 and lncell-141
    Verify Non-CA Basic L3 Call One By One    cell_list=${aehc_nr_cell_list}    ue_type=${ue_type}    ue_index=${ue_index}
    ...                                   enb_index=${fdd_enb_index}
    Run Keyword If    '${aehc_lte_cell_list_length}'!='${0}'      Verify 4G Non-CA Basic L3 Call One By One
    ...     cell_list=${origin_aehc_lte_cell_list}    ue_type=${ue_type}    ue_index=${ue_index}    whether_do_barred_action=${True}
    Log To Console     ${\n}INFO: --start to reset gnb site
    Perform BTS Site Reset
    Check All Cells Should Be On Air Except One Locked Cell    cell_id=${nr_max_cell_id}
    # L3 call for nrcell-301,lncell-131 and lncell-141
    Verify Non-CA Basic L3 Call One By One    cell_list=${aehc_nr_cell_list}    ue_type=${ue_type}    ue_index=${ue_index}
    ...                                   enb_index=${fdd_enb_index}
    Run Keyword If    '${aehc_lte_cell_list_length}'!='${0}'      Verify 4G Non-CA Basic L3 Call One By One
    ...     cell_list=${origin_aehc_lte_cell_list}    ue_type=${ue_type}    ue_index=${ue_index}    whether_do_barred_action=${True}
    # Below for operation(locked nrcell301)
    Log To Console     ${\n}INFO: ---Step4: Lock nr-cell from high cellid to low cellid---
    Loop For Do Type Cell Action Then Verify Status And Alarm    cell_list=${aehc_nr_cell_list}    list_index=-1
    ...                                                          cell_action=locked    cell_type=nr
    # L3 call for lncell-131 and lncell-141
    Run Keyword If    '${aehc_lte_cell_list_length}'!='${0}'      Verify 4G Non-CA Basic L3 Call One By One
    ...     cell_list=${origin_aehc_lte_cell_list}    ue_type=${ue_type}    ue_index=${ue_index}    whether_do_barred_action=${True}
    ## Below for operation(unlocked nrcell401 and nrcell301)
    Log To Console     ${\n}INFO: ---Step5: Unlock nr-cell from high cellid to low cellid---
    Loop For Do Type Cell Action Then Verify Status And Alarm    cell_list=${origin_aehc_nr_cell_list}    list_index=-1
    ...                                                          cell_action=unlocked    cell_type=nr
    # L3 call for nrcell-301,nrcell-401,lncell-131 and lncell-141
    Verify Non-CA Basic L3 Call One By One    cell_list=${origin_aehc_nr_cell_list_backup}    ue_type=${ue_type}    ue_index=${ue_index}
    ...                                   enb_index=${fdd_enb_index}
    Run Keyword If    '${aehc_lte_cell_list_length}'!='${0}'      Verify 4G Non-CA Basic L3 Call One By One
    ...     cell_list=${origin_aehc_lte_cell_list}    ue_type=${ue_type}    ue_index=${ue_index}    whether_do_barred_action=${True}
    ## Below for operation(locked ltecell131 and ltecell141)
    Log To Console     ${\n}INFO: ---Step6: Lock lte-cell from low cellid to high cellid---
    Loop For Do Type Cell Action Then Verify Status And Alarm    cell_list=${aehc_lte_cell_list}    list_index=0
    ...                                                          cell_action=locked    cell_type=lte
    # L3 call for nrcell-301,nrcell-401
    Verify Non-CA Basic L3 Call One By One    cell_list=${origin_aehc_nr_cell_list_backup}    ue_type=${ue_type}    ue_index=${ue_index}
    ## Below for operation(unlocked ltecell131 and ltecell141)
    Log To Console     ${\n}INFO: ---Step7: Unlock lte-cell from low cellid to high cellid---
    Loop For Do Type Cell Action Then Verify Status And Alarm    cell_list=${origin_aehc_lte_cell_list}    list_index=0
    ...                                                          cell_action=unlocked    cell_type=lte
    # L3 call for nrcell-301 and nrcell-401, lncell-131 and lncell-141
    Verify Non-CA Basic L3 Call One By One    cell_list=${origin_aehc_nr_cell_list_backup}    ue_type=${ue_type}    ue_index=${ue_index}
    ...                                   enb_index=${fdd_enb_index}
    Run Keyword If    '${aehc_lte_cell_list_length}'!='${0}'      Verify 4G Non-CA Basic L3 Call One By One
    ...     cell_list=${origin_aehc_lte_cell_list_backup}    ue_type=${ue_type}    ue_index=${ue_index}    whether_do_barred_action=${True}
    Run Keyword And Continue On Failure    Check RU Calibration Status And Power on Specifc RU
#    ${syslog_file}    Run Keyword And Continue On Failure    Get Syslog File During Specific Time    syslog_start_time=${SYSLOG_START_TIME}
#    ${syslog_file_path}    Run Keyword And Continue On Failure   Evaluate    '/'.join(${syslog_file.split('/')[0:-1]})
#    Run Keyword And Continue On Failure    Check ERR Or WRN From Syslog    sys_logs_path=${syslog_file_path}
#    ...     UTE_logs_path=/home/ute/ERR_WRN_logs    Fail_Case=True    Check_RF_Log=True    timeout=50 minutes
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    Do All Type Cells Lock Or Unlock    cell_action=unlocked    cell_type=nr
    ...    AND    Run Keyword And Ignore Error    Do All Type Cells Lock Or Unlock    cell_action=unlocked    cell_type=lte    enb_index=${0}
    ...    AND    Run Keyword And Ignore Error    TMO_Common_Case_Teardown

5603011_TOL_22R1_1UE_FTCA_1UE_TTCA_modifyNIDD_dmrsTypeAPosition_from_Pos3_to_Pos2_1UE_FTCA_1UE_TFCA
    [Documentation]    TL813:UE0-SDX65, 100M+40M_cellID_301_311. UE1: MTK M70, AHLOA0+AEHC0, 15M+100M, cellID_1_311.
    ...                TL813:UE0-SDX70, 100M+40M_cellID_301_311. UE1: SDX65 shared with TL283, AHLOA0+AEHC0, 15M+100M, cellID_1_311.
    ...                20230811: fault1927 appeared on TL813, wait for 03228289 solved
    [Tags]    T813_QC    T073_QC   T816_QC
    [Setup]    TMO_Common_Case_Setup
    Delete NRREL Objects Based On Technology
    FOR    ${enb_index}    IN RANGE    ${enb_length}
        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
    END
    ${target_DL_avg_percent}     Set Variable If    '${tl_prefix}'=='T080'    0.5     0.9
    ${target_UL_avg_percent}     Set Variable If    '${tl_prefix}'=='T080'    0.5     0.9
    ${min_DL_percent}     Set Variable If    '${tl_prefix}'=='T080'     0.1     0.85
    ${min_UL_percent}     Set Variable If    '${tl_prefix}'=='T080'     0.1     0.85
    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
    ${LTE_CELL_INDEX}    Set Variable If    '${tl_prefix}'=='T073'     ${61}    ${61}
    Set Test Variable    ${LTE_CELL_INDEX}
    Log to console    perform ltecell locked
    Run Keyword If    '${tl_prefix}'!='T813'    Lock Or Unlock Single Cell    cell_index=${LTE_CELL_INDEX}
    ...    cell_type=lte    action=lock
    Run Keyword If    '${tl_prefix}'!='T813'    Verify The Status Of Single Cell
    ...    cell_index=${LTE_CELL_INDEX}    cell_type=lte    action=lock
    Get Syslog Start Time
    ${ue_index0}    Set Variable If    '${tl_prefix}'=='T816'     ${3}     ${0}
    ${ue_type0}    translate_power_ue_type_from_testline    ue_index=${ue_index0}
    Procedures.Verify CA Basic L3 Call    ue_index=${ue_index0}
    ...                                   ue_type=${ue_type0}
    ...                                   ul_throughput=250M
    ...                                   dl_throughput=2860MKbits/sec
    ...                                   whether_need_ue_log=${False}
    ...                                   start_keep_on_duration=1800
    ...                                   ignore_time=1min
    ...                                   tput_collect_duration=120
    ...                                   target_DL_avg_percent=${target_DL_avg_percent}
    ...                                   target_UL_avg_percent=${target_UL_avg_percent}
    ...                                   min_DL_percent=${min_DL_percent}
    ...                                   min_UL_percent=${min_UL_percent}
    ...                                   enb_index=${fdd_enb_index}
    ...                                   whether_check_on_air=${False}
    ${ue_index1}    Set Variable If    '${tl_prefix}'=='T080'     ${3}
    ...                                '${tl_prefix}'=='T073'     ${14}
    ...                                '${tl_prefix}'=='T813'     ${1}
    ...                                '${tl_prefix}'=='T283'     ${1}
    ...                                '${tl_prefix}'=='T284'     ${1}
    ...                                '${tl_prefix}'=='T816'     ${2}
    ${specified_scell_index}   Set Variable If    '${tl_prefix}'=='T073'     ${311}    ${311}
    Multi-UE_Case_Setup    ue_index=${ue_index1}    specified_scell_index=${specified_scell_index}
    ${ue_type1}    translate_power_ue_type_from_testline    ue_index=${ue_index1}
#    Run Keyword If    '${ue_type1}'=='samsung'
#    ...       Change Network Mode For Samsung    ue_type=${ue_type1}    ue_index=${1}    netword_mode=5G
    ${target_DL_avg_percent1}     Set Variable If    '${tl_prefix}'=='T080'    0.3     0.75
    ${target_UL_avg_percent1}     Set Variable If    '${tl_prefix}'=='T080'    0.3     0.75
    ${min_DL_percent1}     Set Variable If    '${tl_prefix}'=='T080'     0.1     0.7
    ${min_UL_percent1}     Set Variable If    '${tl_prefix}'=='T080'     0.1     0.2
    Procedures.Verify CA Basic L3 Call    ue_index=${ue_index1}
    ...                                   ue_type=${ue_type1}
    ...                                   ul_throughput=250M
    ...                                   dl_throughput=3040MKbits/sec
    ...                                   whether_need_ue_log=${False}
    ...                                   notbarred_cell_index=${PCELL_INDEX_${ue_index1}}
    ...                                   expect_addition_scell_indexs=${SCELL_INDEX_LIST_${ue_index1}}
    ...                                   start_keep_on_duration=1200
    ...                                   whether_do_ue_prepare=${True}
    ...                                   ignore_time=1min
    ...                                   tput_collect_duration=120
    ...                                   pcell_mapping=${PCELL_MAPPING_${ue_index1}}
    ...                                   scell_mapping=${SCELL_MAPPING_${ue_index1}}
    ...                                   target_DL_avg_percent=${target_DL_avg_percent1}
    ...                                   target_UL_avg_percent=${target_UL_avg_percent1}
    ...                                   min_DL_percent=${min_DL_percent1}
    ...                                   min_UL_percent=${min_UL_percent1}
    ...                                   enb_index=${fdd_enb_index}
    ...                                   whether_check_on_air=${False}
    ${host}   Start To Capture Aasyslog    gnb_index=${0}    du_index=${0}
    Sleep    20sec
    ${tupt_file_path}    Stop To Capture And Download Aasyslog    host=${host}
    Procedures.Stop TMO L3 Call And Detach    ue_index=${ue_index0}    ue_type=${ue_type0}
    Procedures.Stop TMO L3 Call And Detach    ue_index=${ue_index1}    ue_type=${ue_type1}
    Sleep    60sec
    Update The DmrsTypeAPosition Value Of Cell
    Sleep    60sec
    Procedures.Verify CA Basic L3 Call    ue_index=${ue_index0}
    ...                                   ue_type=${ue_type0}
    ...                                   ul_throughput=250M
    ...                                   dl_throughput=2860MKbits/sec
    ...                                   whether_need_ue_log=${False}
    ...                                   start_keep_on_duration=1800
    ...                                   ignore_time=1min
    ...                                   tput_collect_duration=120
    ...                                   target_DL_avg_percent=${target_DL_avg_percent}
    ...                                   target_UL_avg_percent=${target_UL_avg_percent}
    ...                                   min_DL_percent=${min_DL_percent}
    ...                                   min_UL_percent=${min_UL_percent}
    ...                                   enb_index=${fdd_enb_index}
    ...                                   whether_check_on_air=${False}
#    Multi-UE_Case_Setup    ue_index=${1}
    ${ue_type1}    translate_power_ue_type_from_testline    ue_index=${ue_index1}
    Procedures.Verify CA Basic L3 Call    ue_index=${ue_index1}
    ...                                   ue_type=${ue_type1}
    ...                                   ul_throughput=250M
    ...                                   dl_throughput=3040MKbits/sec
    ...                                   whether_need_ue_log=${False}
    ...                                   notbarred_cell_index=${PCELL_INDEX_${ue_index1}}
    ...                                   expect_addition_scell_indexs=${SCELL_INDEX_LIST_${ue_index1}}
    ...                                   start_keep_on_duration=1200
    ...                                   whether_do_ue_prepare=${False}
    ...                                   ignore_time=1min
    ...                                   tput_collect_duration=120
    ...                                   pcell_mapping=${PCELL_MAPPING_${ue_index1}}
    ...                                   scell_mapping=${SCELL_MAPPING_${ue_index1}}
    ...                                   target_DL_avg_percent=${target_DL_avg_percent1}
    ...                                   target_UL_avg_percent=${target_UL_avg_percent1}
    ...                                   min_DL_percent=${min_DL_percent1}
    ...                                   min_UL_percent=${min_UL_percent1}
    ...                                   enb_index=${fdd_enb_index}
    ...                                   whether_check_on_air=${False}
#    ${syslog_file}    Run Keyword And Continue On Failure    Get Syslog File During Specific Time    syslog_start_time=${SYSLOG_START_TIME}
#    ${syslog_file_path}    Run Keyword And Continue On Failure   Evaluate    '/'.join(${syslog_file.split('/')[0:-1]})
#    Run Keyword And Continue On Failure    Check ERR Or WRN From Syslog    sys_logs_path=${syslog_file_path}
#    ...     UTE_logs_path=/home/ute/ERR_WRN_logs    Fail_Case=True    Check_RF_Log=True    timeout=100 minutes
#    ...     server_type=remote
    ${host}   Start To Capture Aasyslog    gnb_index=${0}    du_index=${0}
    Sleep    20sec
    ${tupt_file_path}    Stop To Capture And Download Aasyslog    host=${host}
    Run Keyword And Continue On Failure    Check RU Calibration Status And Power on Specifc RU
    Log to console    perform lte cell unlocked
#    Lock Or Unlock Single Cell    cell_index=${LTE_CELL_INDEX}    cell_type=lte    action=unlock
#    Verify The Status Of Single Cell    cell_index=${LTE_CELL_INDEX}    cell_type=lte    action=unlock
    #     Add fualt 49 in allowed history fault as "lock LTE cell as WA"
    &{fault_49}     Create Dictionary     faultId=${49}
    ${ALLOWED_HISTORY_FAULT}   Create List   @{ALLOWED_HISTORY_FAULT}   ${fault_49}
    Set Test Variable    ${ALLOWED_HISTORY_FAULT}
    [Teardown]    Run Keywords    Run Keyword If    '${tl_prefix}'!='T813'  Lock Or Unlock Single Cell
    ...    cell_index=${LTE_CELL_INDEX}    cell_type=lte    action=unlock    AND
    ...    Run Keyword If    '${tl_prefix}'!='T813'  Verify The Status Of Single Cell    cell_index=${LTE_CELL_INDEX}
    ...    cell_type=lte    action=unlock    AND    Check TMO Gnb Ready And All Cell On Air    AND
    ...    Run Keyword And Ignore Error    TMO_Common_Case_Teardown
    ...    AND    Run Keyword And Ignore Error    TMO_Common_Case_Teardown    ue_index=${ue_index1}    ue_type=${ue_type1}
    ...    AND    Update The DmrsTypeAPosition Value Of Cell


5603100_TOL_case_100_AEHC_5G_1CC_40Mhz_arfcn_gscn_modification
    [Documentation]    TL813:UE0-SDX65, AEHC0 5G SA call(5gcell_301)
    ...    load scf with 1CC 4OM
    [Tags]    T080_QC      T813_QC    T073_QC
    [Setup]    TMO_Common_Case_Setup    is_commission=True    scf_name=${tl_prefix}_5603100.xml
    ...                                                 whether_get_ca_info=${False}    whether_set_pa_value=${False}
    Wait Until Keyword Succeeds   2 min   5 sec   Connect to gnb coam via ssl   connection=GNB_OAM0   gnb_index=${0}
    ${pcell_ru_index}    Get 5G Related Info Of Cell    cell_index=${PCELL_INDEX}
    FOR    ${attenuator}    IN    @{attenuator_list}
        Run Keyword If    '${attenuator}'=='pa'
        ...        Modify PA Value Setting For Required RU    modify_ru_id=${pcell_ru_index}    ue_index=${0}
        ...    ELSE IF    '${attenuator}'=='mcs'    Set Case Related MCS Port Value    ue_index=${0}   whether_do_mcs_setup=${False}
        ...    ELSE    Log To Console     ${\n}INFO: --Use the wrong attenuator type(${attenuator}), need to check TMO_Data.py--
    END
    Log To Console    \n----Start L3 call----
    FOR    ${enb_index}    IN RANGE    ${enb_length}
        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
    END
    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
    Get Syslog Start Time
#    FOR    ${i}    IN RANGE    ${5}
        Procedures.Verify CA Basic L3 Call    ul_throughput=100M
        ...                                   dl_throughput=800MKbits/sec
        ...                                   tput_collect_duration=120
        ...                                   whether_need_ue_log=${False}
        ...                                   whether_check_scell_addition=${False}
        ...                                   check_scell_tput=${False}
        ...                                   ignore_time=15sec
        ...                                   expect_addition_scell_indexs=${None}
        ...                                   scell_mapping=${None}
        ...                                   target_DL_avg_percent=0.3
        ...                                   target_UL_avg_percent=0.3
        ...                                   min_DL_percent=0.1
        ...                                   min_UL_percent=0.1
        ...                                   enb_index=${fdd_enb_index}
        Procedures.Stop TMO L3 Call And Detach
#    END
    Update Nrarfcn And Gscn Of All AEHC    gscn=1
#    FOR    ${i}    IN RANGE    ${5}
        Procedures.Verify CA Basic L3 Call    ul_throughput=100M
        ...                                   dl_throughput=800MKbits/sec
        ...                                   tput_collect_duration=120
        ...                                   whether_need_ue_log=${False}
        ...                                   whether_check_scell_addition=${False}
        ...                                   check_scell_tput=${False}
        ...                                   ignore_time=15sec
        ...                                   expect_addition_scell_indexs=${None}
        ...                                   scell_mapping=${None}
        ...                                   target_DL_avg_percent=0.3
        ...                                   target_UL_avg_percent=0.3
        ...                                   min_DL_percent=0.1
        ...                                   min_UL_percent=0.1
        ...                                   enb_index=${fdd_enb_index}
        Procedures.Stop TMO L3 Call And Detach
#    ${syslog_file}    Run Keyword And Continue On Failure    Get Syslog File During Specific Time    syslog_start_time=${SYSLOG_START_TIME}
#    ${syslog_file_path}    Run Keyword And Continue On Failure   Evaluate    '/'.join(${syslog_file.split('/')[0:-1]})
#    Run Keyword And Continue On Failure    Check ERR Or WRN From Syslog    sys_logs_path=${syslog_file_path}
#    ...     UTE_logs_path=/home/ute/ERR_WRN_logs    Fail_Case=True    Check_RF_Log=True    timeout=50 minutes
#    END
#    Run Keyword And Continue On Failure    Check RU Calibration Status And Power on Specifc RU
    [Teardown]    Run Keywords    Common_setup_and_teardown.Common Suite Setup    scf_name=${tl_prefix}_gNB_${stream_version}.xml
    ...                                                                           is_commission=True
    ...                                                                           timeout_for_commission=20 min
    ...                    AND    Run Keyword And Ignore Error    TMO_Common_Case_Teardown    ue_index=${0}    ue_type=${ue_type}

5603160_CB012500_peaktput_with_2x4T4R_Non-beamforming_2NRCELLs-10Mhz-100Mhz_2LTECELLs
    [Documentation]    TL816:UE4-SDX70, 100M+41M_cellID_301_311.
    [Tags]    T816_QC
    [Setup]    TMO_Common_Case_Setup    is_commission=True    scf_name=${tl_prefix}_5603160.xml
    ${ue_index0}    Set Variable If    '${tl_prefix}'=='T816'     ${3}     ${0}
    ${ue_type0}    translate_power_ue_type_from_testline    ue_index=${ue_index0}
    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
    Get Syslog Start Time
    ${hwcheck_index}     Set Variable If    '${tl_prefix}'=='T816'     ${5}    ${1}
    Procedures.Verify CA Basic L3 Call    ue_index=${ue_index0}
    ...                                   ue_type=${ue_type0}
    ...                                   ul_throughput=250M
    ...                                   dl_throughput=1800MKbits/sec
    ...                                   whether_need_ue_log=${False}
    ...                                   start_keep_on_duration=600
    ...                                   ignore_time=1min
    ...                                   tput_collect_duration=120
    ...                                   enb_index=${fdd_enb_index}
    ...                                   whether_check_on_air=${False}
    ...                                   hwcheck_index=${hwcheck_index}
    ${host}   Start To Capture Aasyslog    gnb_index=${0}    du_index=${0}
    Sleep    120sec
    ${tupt_file_path}    Stop To Capture And Download Aasyslog    host=${host}
    Procedures.Stop TMO L3 Call And Detach    ue_index=${ue_index0}    ue_type=${ue_type0}
    [Teardown]    Run Keywords    Common_setup_and_teardown.Common Suite Setup    scf_name=${tl_prefix}_gNB_${stream_version}.xml
    ...                                                                           is_commission=True
    ...                                                                           timeout_for_commission=20 min
    ...    AND    Run Keyword And Ignore Error    TMO_Common_Case_Teardown    ue_index=${ue_index0}    ue_type=${ue_type0}

CB008236-SR-A_12_VoNR UE in Slot Aggregation Mode – 1x, 2x, 4x Slot Aggregation determination
    [Documentation]    TL283:UE0-MTPX80, AHLOB1(SN:BL2236D50B9) NR pci: 101
    [Tags]    T283_QC
    [Setup]    TMO_Common_Case_Setup    is_commission=True    scf_name=${tl_prefix}_gNB_${stream_version}.xml
    ${ue_index0}    Set Variable If    '${tl_prefix}'=='T283'     ${0}
    ${ue_type0}    translate_power_ue_type_from_testline    ue_index=${ue_index0}
    Set cellBarred information for cell    dist_name=MRBTS-283/NRBTS-283/NRCELL-301    value=barred
    sleep    10sec
    Set cellBarred information for cell    dist_name=MRBTS-283/NRBTS-283/NRCELL-1    value=notBarred
    sleep    10sec
    ${rule1}    Catenate
    ...    Distname: MRBTS-283/NRBTS-283/NRCELL-1;
    ...    Counter: M55370C00001;
    ...    Counter rule: max(M55370C00001)>0;
    ${rule2}    Catenate
    ...    Distname: MRBTS-283/NRBTS-283/NRCELL-1;
    ...    Counter: M55370C00022;
    ...    Counter rule: max(M55370C00022)>0;
    ${rule_list}    Create List    ${rule1}    ${rule2}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    # Unlock AHLOB1 FDD cell 1 before attach
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    RU_id=3   value=0
    sleep    10sec
    #Procedures.Start UE Prepare    ue_index=${0}    ue_type=${ue_type}
    power_ue.UE Attach    ue_type=${ue_type}
    ...                                  ue_index=${0}
    ...                                  gnb_index=${0}
    ...                                  hwcheck_index=${0}
    ...                                  du_index=${0}
    ...                                  power_reset=${False}
    ...                                  ue_alias=UE_0
    ...                                  attach_mode=5G_SA
    sleep    5sec
    Procedures.Vonr Call Setup Test
    sleep    10sec
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    RU_id=3   value=15
    sleep   10sec
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    RU_id=3   value=30
    sleep   10sec
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    RU_id=3   value=45
    sleep   10sec
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    RU_id=3   value=60
    sleep   30sec
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    RU_id=3   value=68
    sleep   450sec
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule
    ...    product_type=gnb    interval=5
    Log To Console    ${value1}
    # # check counter value for slot aggregation
    # ${dis_name_dir}    set variable    MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}
    # ${M55370C00001_full_path}    set variable    ${dis_name_dir}/NRCELL-1/NULH/PUSCH_DFT_INI_64TBL_SAG_R1
    # Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    # ${M55370C00001_value}    Get counter latest value    BTS_or_TRS=BTS    counter_id=M55370C00001
    # ...                                                  counter_full_path=${M55370C00001_full_path}
    # ${M55370C00001_value}    convert to integer     ${M55370C00001_value}
    # run keyword and continue on failure    should be true    ${M55370C00001_value}>1
    # ${dis_name_dir}    set variable    MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}
    # ${M55370C00022_full_path}    set variable    ${dis_name_dir}/NRCELL-1/NULH/ACC_UE_SAG
    # Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    # ${M55370C00022_value}    Get counter latest value    BTS_or_TRS=BTS    counter_id=M55370C00022
    # ...                                                  counter_full_path=${M55370C00022_full_path}
    # ${M55370C00022_value}    convert to integer     ${M55370C00022_value}
    # run keyword and continue on failure    should be true    ${M55370C00022_value}>1
    # teatdown
    # [Teardown]    Run Keywords    Common_setup_and_teardown.Common Suite Setup    scf_name=${tl_prefix}_gNB_${stream_version}.xml
    # ...                                                                           is_commission=True
    # ...                                                                           timeout_for_commission=20 min
    # ...    AND    Run Keyword And Ignore Error    TMO_Common_Case_Teardown    ue_index=${ue_index0}    ue_type=${ue_type0}

    [Teardown]    Run Keyword And Ignore Error    TMO_Common_Case_Teardown    ue_index=${ue_index0}    ue_type=${ue_type0}
