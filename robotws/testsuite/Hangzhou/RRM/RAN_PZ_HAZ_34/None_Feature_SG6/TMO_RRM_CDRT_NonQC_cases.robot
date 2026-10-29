*** Settings ***
Documentation    TMO Automation for TMO E2E CDRT cases
...              Author: lei.jia@nokia-sbell.com
Suite Setup    TMO_Common_Suite_Setup    is_commission=${True}
Suite Teardown    TMO_Suite_Teardown
Force Tags    5G_TOL    SG_06
...    PY36

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/TMO/TMO_common_keywords.robot

*** Test Cases ***
5603108_E2E_RRM_multiCC_SA_1UE_PCELLN41
    [Documentation]    N41(PCell)+N25+N71, TL283: SDX65 cell301+1+21
    ...                B25 LTE FDD cells need to be locked, and N41 pcell 8247 off(in order to make N25 DL tput high)
    ...               for TL073, SDX70, 4CC cell301+1+21+401, pcell ul is only layer1, for N71 dl tput is only layer2, while N25 layer4
    ...               2024.06.18: jialei: for TL080, spark x75, SA call, support 4CC ，N41+N41+n71+n25
    ...                L3 call: SA
    [Tags]    T813_RRM    T283_RRM    T073_RRM    T080_RRM    T819_RRM
    [Setup]    TMO_Common_Case_Setup    3CC_support=${True}    is_pdl_checking_needed=${False}
    ...        ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
    Log To Console     ${\n}INFO: --disable 8247 on N41 pcell, in order to make N25 dl TPUT HIGH
#    ${org_actDlSrsBm_value}    ${org_actDlMuMimoEnh_value}    ${org_actMuAwareTdSch_value}
#    ...    ${org_actDlRankProbing_value}    ${org_actDlSrsSubbandBm_value}    ${org_actPdschBeamPowerBalance_value}
#    ...    ${org_actSrsBeamFallbackByRetrx_value}    Get actDlSrsBm Param Value    cell_index=${PCELL_INDEX}
#    Run Keyword If    '${org_actDlSrsBm_value}'!='false' and '${tl_prefix}'!='T080'    Disable actDlSrsBm and releated params via Admin API
#    ...                value=false
    Disable actDlSrsBm and releated params via Admin API
    IF    '${tl_prefix}'=='T073'
        ${scell_index_list}    Create List    ${311}    ${1}    ${21}    ${11}    ${41}
    ELSE IF    '${tl_prefix}'=='T283'
        ${scell_index_list}    Create List    ${351}    ${1}    ${2}    ${3}    ${21}    ${22}    ${23}
        ...        ${11}    ${12}    ${13}    ${41}    ${42}    ${43}
    ELSE IF    '${tl_prefix}'=='T819'
        ${scell_index_list}    Create List    ${311}    ${21}    ${22}    ${23}
    ELSE IF    '${tl_prefix}'=='T813'
        ${scell_index_list}    Create List    ${311}    ${1}    ${2}    ${3}
    ELSE
        ${scell_index_list}    Create List    ${311}    ${21}    ${22}    ${23}
    END
    ${all_scell_list}    Get Dictionary Keys   ${SCELL_MAPPING}
    Modify WeightForSCellSelection Parameter Value On Gnb    scell_list_used_in_fact=${scell_index_list}
    ...                                                      scell_list_supported=${all_scell_list}
    Log To Console     ${\n}INFO: --for 813, ul 2cc checked
    ${whether_check_scell_ul_tupt}    set variable if    '${tl_prefix}'=='T080'    True     False
    ${special_scell_index_for_UL}    set variable if    '${whether_check_scell_ul_tupt}'=='True'      ${case_params.get('scell_ul_idx')}
    Log To Console     ${\n}INFO: --LOCK B25 LTE CELLS, in order to reduce distractions for N25 cells
    ${ru_type}   set variable if    '${tl_prefix}'=='T283' or '${tl_prefix}'=='T080' or '${tl_prefix}'=='T073'    AHFII
    ...                             '${tl_prefix}'=='T813'    AHFIG
    ...                             '${tl_prefix}'=='T819'    AWMFIA
    ${ru_index}   set variable if    '${tl_prefix}'=='T080'    7
    ...                              '${tl_prefix}'=='T819'    0    6
    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
    Lock AHFII FDD cells    ru_type=${ru_type}    cell_type=lte    ru_index=${ru_index}
    ...    whether_get_first_ru_only=${True}    enb_index=${fdd_enb_index}    action=lock
    Sleep    300s    Wait for error log disappear after cell lock!
    Log To Console     ${\n}INFO: --set anchor enb barred, to make SA calls
    FOR    ${enb_index}    IN RANGE    ${enb_length}
        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
    END
    ${LTE_CELL_INDEX}    Set Variable If    '${tl_prefix}'=='T073'    ${61}    ${61}
    ${hwcheck_index}     Set Variable If    '${tl_prefix}'=='T073'    ${5}    ${1}
    Set Test Variable    ${LTE_CELL_INDEX}
    Log to console    perform ltecell locked
    Run Keyword If    '${tl_prefix}'=='T073'    Lock Or Unlock Single Cell    cell_index=${LTE_CELL_INDEX}
    ...    cell_type=lte    action=lock
    Run Keyword If    '${tl_prefix}'=='T073'    Verify The Status Of Single Cell
    ...    cell_index=${LTE_CELL_INDEX}    cell_type=lte    action=lock
    Run keyword if    '${ue_type}' == 'mtk'    MTK_common_keywords.Get UE Airmode status and Turnoff Airplane Mode
    ...               ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
    Log To Console     ${\n}INFO: --make SA l3 call
    Get Syslog Start Time
    ${whether_do_ue_prepare}    Set Variable If    'spark' in '${ue_type}'    ${True}    ${False}
    ${dl_throughput}    Set Variable If    '${tl_prefix}'=='T073'    4000MKbits/sec    3000MKbits/sec
    Procedures.Verify CA Basic L3 Call    ul_throughput=350M
    ...                                   dl_throughput=${dl_throughput}
    ...                                   ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
    ...                                   check_ul_pcell_tput_type=layer1
    ...                                   whether_check_on_air=${False}
    ...                                   whether_check_scell_ul_tupt=${whether_check_scell_ul_tupt}
    ...                                   special_scell_index_for_UL=${special_scell_index_for_UL}
    ...                                   enb_index=${fdd_enb_index}
    ...                                   whether_need_ue_log=${False}
    ...                                   whether_do_ue_prepare=${whether_do_ue_prepare}
    ...                                   hwcheck_index=${hwcheck_index}
    ${syslog_file}    Run Keyword And Continue On Failure    Get Syslog File During Specific Time    syslog_start_time=${SYSLOG_START_TIME}
    ${syslog_file_path}    Run Keyword And Continue On Failure   Evaluate    '/'.join(${syslog_file.split('/')[0:-1]})
    Run Keyword And Ignore Error    Check ERR Or WRN From Syslog    sys_logs_path=${syslog_file_path}
    ...     UTE_logs_path=/home/ute/ERR_WRN_logs    Fail_Case=True    Check_RF_Log=True    timeout=50 minutes
    Run Keyword And Continue On Failure    Check ERR Syslog Existed
    [Teardown]    Run Keywords   Run Keyword If    '${tl_prefix}'=='T073'  Lock Or Unlock Single Cell
    ...    cell_index=${LTE_CELL_INDEX}    cell_type=lte    action=unlock    AND
    ...    Run Keyword If    '${tl_prefix}'=='T073'    Verify The Status Of Single Cell    cell_index=${LTE_CELL_INDEX}
    ...    cell_type=lte    action=unlock    AND
    ...    Lock AHFII FDD cells    ru_type=${ru_type}    cell_type=lte    ru_index=${ru_index}
    ...    whether_get_first_ru_only=${True}    enb_index=${fdd_enb_index}    action=unlock
#    ...    AND    Disable actDlSrsBm and releated params via Admin API    value=${org_actDlSrsBm_value}
#    ...           actDlMuMimoEnh_value=${org_actDlMuMimoEnh_value}
    ...    AND    TMO_Common_Case_Teardown    ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}    is_save_snapshot=${True}    AND
    ...    Run Keyword And Continue On Failure    SetUp.Precondition For First gNB    is_commission=${True}
    ...    check_rollback_is_needed=${False}    AND    csn.reset_cache

5603109_E2E_RRM_multiCC_SA_1UE_PCELLN71
    [Documentation]    N71(PCell)+N25+N41, TL283: SDX65 cell1+21+301
    ...                for TL073, SDX85 cell1+21+301+311+11+41
    ...               for TL080, spark x75, only support 3CC ，n71+N41+N41，UL support CA
    ...    L3 call: SA
    [Tags]    T813_RRM    T283_RRM    T073_RRM    T080_RRM
    [Setup]    TMO_Common_Case_Setup    3CC_support=${True}    is_pdl_checking_needed=${False}
    ...        ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
    IF    '${tl_prefix}'=='T073'
        ${scell_index_list}    Create List    ${301}    ${311}    ${21}    ${11}    ${41}
    ELSE IF    '${tl_prefix}'=='T283'
        ${scell_index_list}    Create List    ${301}    ${351}    ${21}    ${22}    ${23}    ${11}    ${12}    ${13}
        ...        ${41}    ${42}    ${43}
    ELSE
        ${scell_index_list}    Create List    ${301}    ${21}    ${22}    ${23}
    END
    ${all_scell_list}    Get Dictionary Keys   ${SCELL_MAPPING}
    Modify WeightForSCellSelection Parameter Value On Gnb    scell_list_used_in_fact=${scell_index_list}
    ...                                                      scell_list_supported=${all_scell_list}
    ${whether_check_scell_ul_tupt}    set variable if    '${tl_prefix}'=='T080'    True     False
    ${special_scell_index_for_UL}    set variable if    '${whether_check_scell_ul_tupt}'=='True'      ${case_params.get('scell_ul_idx')}
    ${org_actDlSrsBm_value}    ${org_actDlMuMimoEnh_value}    ${org_actMuAwareTdSch_value}
    ...    ${org_actDlRankProbing_value}    ${org_actDlSrsSubbandBm_value}    ${org_actPdschBeamPowerBalance_value}
    ...    ${org_actSrsBeamFallbackByRetrx_value}    Get actDlSrsBm Param Value    cell_index=${PCELL_INDEX}
    ${ru_type}   set variable    AHLOB
    ${ru_index}   set variable if    '${tl_prefix}'=='T080'    4     3
    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
    Lock AHFII FDD cells    ru_type=${ru_type}    cell_type=lte    ru_index=${ru_index}
    ...    whether_get_first_ru_only=${True}    enb_index=${fdd_enb_index}    action=lock
    Sleep    300s    Wait for error log disappear after cell lock!
    FOR    ${enb_index}    IN RANGE    ${enb_length}
        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
    END
    Run keyword if    '${ue_type}' == 'mtk'    MTK_common_keywords.Get UE Airmode status and Turnoff Airplane Mode
    ...               ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
    Get Syslog Start Time
    ${whether_do_ue_prepare}    Set Variable If    'spark' in '${ue_type}'    ${True}    ${False}
    ${dl_throughput}    Set Variable If    '${tl_prefix}'=='T073'    4000MKbits/sec    3000MKbits/sec
    Procedures.Verify CA Basic L3 Call    ul_throughput=350M
    ...                                   dl_throughput=${dl_throughput}
    ...                                   ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
    ...                                   whether_check_on_air=${False}
    ...                                   whether_check_scell_ul_tupt=${whether_check_scell_ul_tupt}
    ...                                   special_scell_index_for_UL=${special_scell_index_for_UL}
    ...                                   enb_index=${fdd_enb_index}
    ...                                   whether_need_ue_log=${False}
    ...                                   whether_do_ue_prepare=${whether_do_ue_prepare}
    ${syslog_file}    Run Keyword And Continue On Failure    Get Syslog File During Specific Time    syslog_start_time=${SYSLOG_START_TIME}
    ${syslog_file_path}    Run Keyword And Continue On Failure   Evaluate    '/'.join(${syslog_file.split('/')[0:-1]})
    Run Keyword And Ignore Error    Check ERR Or WRN From Syslog    sys_logs_path=${syslog_file_path}
    ...     UTE_logs_path=/home/ute/ERR_WRN_logs    Fail_Case=True    Check_RF_Log=True    timeout=50 minutes
    Run Keyword And Continue On Failure    Check ERR Syslog Existed
    [Teardown]    Run Keywords    Lock AHFII FDD cells    ru_type=${ru_type}    cell_type=lte    ru_index=${ru_index}
    ...    whether_get_first_ru_only=${True}    enb_index=${fdd_enb_index}     action=unlock
    ...    AND    TMO_Common_Case_Teardown    ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}    is_save_snapshot=${True}
    ...    AND    Run Keyword And Continue On Failure
    ...    Common_setup_and_teardown.Common Suite Setup    scf_name=${tl_prefix}_gNB_${stream_version}.xml
    ...                                                                           is_commission=True
    ...                                                                           timeout_for_commission=20 min

5603110_E2E_RRM_multiCC_SA_1UE_PCELLN25
    [Documentation]    N25(PCell)+N71+N41, TL283: SDX65 cell21+1+301
    ...    due to PR725059, when 3cc is true, pdl error occurs
    ...               for TL073, SDX70, cell21+1+301+401
    ...               for TL080, spark x75, only support 3CC ，n25+N41+N41，UL support CA
    ...    L3 call: SA
    [Tags]    T813_RRM    T283_RRM    T073_RRM    T080_RRM
    [Setup]    TMO_Common_Case_Setup    3CC_support=${True}    is_pdl_checking_needed=${False}
    ...        ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
    IF    '${tl_prefix}'=='T073'
        ${scell_index_list}    Create List    ${301}    ${311}    ${1}    ${21}    ${41}
    ELSE IF    '${tl_prefix}'=='T283'
        ${scell_index_list}    Create List    ${301}    ${351}    ${11}    ${12}    ${13}    ${1}    ${2}    ${3}
        ...        ${41}    ${42}    ${43}
    ELSE
        ${scell_index_list}    Create List    ${1}    ${2}    ${3}    ${301}
    END
    ${all_scell_list}    Get Dictionary Keys   ${SCELL_MAPPING}
    Modify WeightForSCellSelection Parameter Value On Gnb    scell_list_used_in_fact=${scell_index_list}
    ...                                                      scell_list_supported=${all_scell_list}
    ${whether_check_scell_ul_tupt}    set variable if    '${tl_prefix}'=='T080'    True     False
    ${special_scell_index_for_UL}    set variable if    '${whether_check_scell_ul_tupt}'=='True'      ${case_params.get('scell_ul_idx')}
    ${org_actDlSrsBm_value}    ${org_actDlMuMimoEnh_value}    ${org_actMuAwareTdSch_value}
    ...    ${org_actDlRankProbing_value}    ${org_actDlSrsSubbandBm_value}    ${org_actPdschBeamPowerBalance_value}
    ...    ${org_actSrsBeamFallbackByRetrx_value}    Get actDlSrsBm Param Value    cell_index=${PCELL_INDEX}
    ${ru_type}   set variable if    '${tl_prefix}'=='T283' or '${tl_prefix}'=='T080' or '${tl_prefix}'=='T073'    AHFII
    ...                             '${tl_prefix}'=='T813'    AHFIG
    ${ru_index}   set variable if    '${tl_prefix}'=='T080'    7     6
    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
    Lock AHFII FDD cells    ru_type=${ru_type}    cell_type=lte    ru_index=${ru_index}
    ...    whether_get_first_ru_only=${True}    enb_index=${fdd_enb_index}    action=lock
    Sleep    300s    Wait for error log disappear after cell lock!
    FOR    ${enb_index}    IN RANGE    ${enb_length}
        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
    END
    ${LTE_CELL_INDEX}    Set Variable If    '${tl_prefix}'=='T073'     ${61}    ${61}
    Set Test Variable    ${LTE_CELL_INDEX}
    Log to console    perform ltecell locked
    Run Keyword If    '${tl_prefix}'=='T073'    Lock Or Unlock Single Cell    cell_index=${LTE_CELL_INDEX}
    ...    cell_type=lte    action=lock
    Run Keyword If    '${tl_prefix}'=='T073'    Verify The Status Of Single Cell
    ...    cell_index=${LTE_CELL_INDEX}    cell_type=lte    action=lock
    ${GSM_CELL_INDEX}    Set Variable If    '${tl_prefix}'=='T073'     ${1}    ${1}
    Set Test Variable    ${GSM_CELL_INDEX}
    Log to console    perform GSMcell block
    Run Keyword If    '${tl_prefix}'=='T073'    Lock Or Unlock Single Cell    cell_index=${GSM_CELL_INDEX}
    ...    cell_type=gsm    action=block
    Run Keyword If    '${tl_prefix}'=='T073'    Verify The Status Of Single Cell
    ...    cell_index=${GSM_CELL_INDEX}    cell_type=gsm   action=block
    Run keyword if    '${ue_type}' == 'mtk'    MTK_common_keywords.Get UE Airmode status and Turnoff Airplane Mode
    ...               ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
    Get Syslog Start Time
    ${whether_do_ue_prepare}    Set Variable If    'spark' in '${ue_type}'    ${True}    ${False}
    ${dl_throughput}    Set Variable If    '${tl_prefix}'=='T073'    4000MKbits/sec    3000MKbits/sec
    ${hwcheck_index}     Set Variable If    '${tl_prefix}'=='T073'    ${6}    ${1}
    Procedures.Verify CA Basic L3 Call    ul_throughput=350M
    ...                                   dl_throughput=${dl_throughput}
    ...                                   ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
    ...                                   whether_check_on_air=${False}
    ...                                   whether_check_scell_ul_tupt=${whether_check_scell_ul_tupt}
    ...                                   special_scell_index_for_UL=${special_scell_index_for_UL}
    ...                                   enb_index=${fdd_enb_index}
    ...                                   whether_need_ue_log=${False}
    ...                                   whether_do_ue_prepare=${whether_do_ue_prepare}
    ...                                   hwcheck_index=${hwcheck_index}
    ...                                   target_UL_avg_percent=0.3
    ${syslog_file}    Run Keyword And Continue On Failure    Get Syslog File During Specific Time    syslog_start_time=${SYSLOG_START_TIME}
    ${syslog_file_path}    Run Keyword And Continue On Failure   Evaluate    '/'.join(${syslog_file.split('/')[0:-1]})
    Run Keyword And Ignore Error    Check ERR Or WRN From Syslog    sys_logs_path=${syslog_file_path}
    ...     UTE_logs_path=/home/ute/ERR_WRN_logs    Fail_Case=True    Check_RF_Log=True    timeout=50 minutes
    Run Keyword And Continue On Failure    Check ERR Syslog Existed
    #     Add fualt 49 in allowed history fault as "block GSM cell as WA"
    &{fault_49}     Create Dictionary     faultId=${49}
    ${ALLOWED_HISTORY_FAULT}   Create List   @{ALLOWED_HISTORY_FAULT}   ${fault_49}
    Set Test Variable    ${ALLOWED_HISTORY_FAULT}
    [Teardown]    Run Keywords      Run Keyword If    '${tl_prefix}'=='T073'  Lock Or Unlock Single Cell
    ...    cell_index=${LTE_CELL_INDEX}    cell_type=lte    action=unlock    AND
    ...    Run Keyword If    '${tl_prefix}'=='T073'  Lock Or Unlock Single Cell
    ...    cell_index=${GSM_CELL_INDEX}    cell_type=gsm    action=unblock    AND
    ...    Run Keyword If    '${tl_prefix}'=='T073'    Verify The Status Of Single Cell    cell_index=${GSM_CELL_INDEX}
    ...    cell_type=gsm    action=unblock    AND   Lock AHFII FDD cells    ru_type=${ru_type}    cell_type=lte    ru_index=${ru_index}
    ...    whether_get_first_ru_only=${True}    enb_index=${fdd_enb_index}    action=unlock
    ...    AND    TMO_Common_Case_Teardown    ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}    is_save_snapshot=${True}
    ...    AND    Run Keyword And Continue On Failure
    ...    Common_setup_and_teardown.Common Suite Setup    scf_name=${tl_prefix}_gNB_${stream_version}.xml
    ...                                                                           is_commission=True
    ...                                                                           timeout_for_commission=20 min

5603015_TOL_22R1_CB7922_IWK_CB7970_RRM02_1UE_CA_TT_call_NSA_All_cells_lock_unlock_1UE_CA_TT_call_NSA
    [Documentation]    TL813:UE0-SDX65, AEHC0 5G NSA CA call. 100M+40M. ltecell_11+5gcell_301+5gcell_311.
    ...                L3 call: NSA
    [Tags]    T813_RRM
    [Setup]    TMO_Common_Case_Setup
    FOR    ${enb_index}    IN RANGE    ${enb_length}
        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
    END
    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
    Get Syslog Start Time
    Procedures.Verify CA Basic L3 Call    ue_mode=NSA
    ...                                   ul_throughput=150M
    ...                                   dl_throughput=2500MKbits/sec
    ...                                   notbarred_cell_index=all
    ...                                   b1_select_cell_index=${PCELL_INDEX}
    ...                                   exp_status=barred
    ...                                   whether_do_lte_barred_action=${True}
    ...                                   whether_check_scell_addition=${False}
    ...                                   tput_collect_duration=120
    ...                                   ignore_time=1min
    ...                                   enb_index=${fdd_enb_index}
    Procedures.Stop TMO L3 Call And Detach
    Do All Type Cells Action And Verify Status    cell_action=locked    enb_index=${fdd_enb_index}
    Sleep    10sec
    Do All Type Cells Action And Verify Status    cell_action=unlocked    enb_index=${fdd_enb_index}
    Procedures.Verify CA Basic L3 Call    ue_mode=NSA
    ...                                   whether_do_barred_action=${False}
    ...                                   whether_do_ue_prepare=${False}
    ...                                   whether_do_lte_barred_action=${False}
    ...                                   whether_need_ue_log=${False}
    ...                                   whether_check_scell_addition=${False}
    ...                                   b1_select_cell_index=${PCELL_INDEX}
    ...                                   ul_throughput=150M
    ...                                   dl_throughput=2200MKbits/sec
    ...                                   tput_collect_duration=120
    ...                                   ignore_time=1min
    ...                                  enb_index=${fdd_enb_index}
    ${syslog_file}    Run Keyword And Continue On Failure    Get Syslog File During Specific Time    syslog_start_time=${SYSLOG_START_TIME}
    ${syslog_file_path}    Run Keyword And Continue On Failure   Evaluate    '/'.join(${syslog_file.split('/')[0:-1]})
    Run Keyword And Ignore Error    Check ERR Or WRN From Syslog    sys_logs_path=${syslog_file_path}
    ...     UTE_logs_path=/home/ute/ERR_WRN_logs    Fail_Case=True    Check_RF_Log=True    timeout=50 minutes
    Run Keyword And Continue On Failure    Check ERR Syslog Existed
    [Teardown]    Run Keywords    TMO_Common_Case_Teardown
    ...                    AND    Do All Type Cells Lock Or Unlock    cell_action=unlocked    enb_index=${fdd_enb_index}

5603018_TOL_case_18_RRM_1UE_CA_TT_SA
    [Documentation]    TL813:UE0-SDX65, AEHC0 5G SA CA 100M+40M call(5gcell_301+311)
    ...                L3 call: SA
    [Tags]    T080_RRM
    [Setup]    TMO_Common_Case_Setup
    FOR    ${enb_index}    IN RANGE    ${enb_length}
        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
    END
    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
    Get Syslog Start Time
    Procedures.Verify CA Basic L3 Call    ul_throughput=190M    dl_throughput=2500MKbits/sec    enb_index=${fdd_enb_index}
    ${syslog_file}    Run Keyword And Continue On Failure    Get Syslog File During Specific Time    syslog_start_time=${SYSLOG_START_TIME}
    ${syslog_file_path}    Run Keyword And Continue On Failure   Evaluate    '/'.join(${syslog_file.split('/')[0:-1]})
    Run Keyword And Ignore Error    Check ERR Or WRN From Syslog    sys_logs_path=${syslog_file_path}
    ...     UTE_logs_path=/home/ute/ERR_WRN_logs    Fail_Case=True    Check_RF_Log=True    timeout=50 minutes
    Run Keyword And Continue On Failure    Check ERR Syslog Existed
    [Teardown]    TMO_Common_Case_Teardown

5603001_TOL_21A_5GC1390_RRM01_1UE_TF_CA_SA_N41_100Mhz_N71
    [Documentation]    TL813:UE0-SDX65, AEHC0+AHLOB0 5G SA CA call, 100M+20M, (5gcell_301+1)
    ...                L3 call: SA
    [Tags]    T080_RRM
    [Setup]    TMO_Common_Case_Setup
    FOR    ${enb_index}    IN RANGE    ${enb_length}
        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
    END
    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
    Get Syslog Start Time
    Procedures.Verify CA Basic L3 Call    ul_throughput=100M    dl_throughput=1800MKbits/sec    check_ul_pcell_tput_type=layer1
    ...                                   enb_index=${fdd_enb_index}
    ${syslog_file}    Run Keyword And Continue On Failure    Get Syslog File During Specific Time    syslog_start_time=${SYSLOG_START_TIME}
    ${syslog_file_path}    Run Keyword And Continue On Failure   Evaluate    '/'.join(${syslog_file.split('/')[0:-1]})
    Run Keyword And Ignore Error    Check ERR Or WRN From Syslog    sys_logs_path=${syslog_file_path}
    ...     UTE_logs_path=/home/ute/ERR_WRN_logs    Fail_Case=True    Check_RF_Log=True    timeout=50 minutes
    Run Keyword And Continue On Failure    Check ERR Syslog Existed
    [Teardown]    TMO_Common_Case_Teardown

5603005_TOL_21A_5GC1390_RRM08_1UE_FT_CA_SA_mutiple_nonGBR
    [Documentation]    L3 call: SA
    [Tags]    T080_RRM
    [Setup]    TMO_Common_Case_Setup
    ${ue_index}    Set Variable If    '${tl_prefix}'=='T080'   2   0
    Update Special Apn    apn_address=${tl.core.pdns[0].apn}    except_apn=mdrb.nokia.com
    ...                   plmn=${tl.core.mcc}${tl.core.mnc}   mcc=${tl.core.mcc}    mnc=${tl.core.mnc}
    ...                   except_name=drb    ue_index=${ue_index}
    FOR    ${enb_index}    IN RANGE    ${enb_length}
        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
    END
    ${whether_do_ue_prepare}      Set Variable If   '${tl_prefix}'=='T080'     True     False
    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
    Get Syslog Start Time
    ${attach_info}    Procedures.Verify CA Basic L3 Call    ue_index=${ue_index}
    ...                                                     ue_type=${ue_type}
    ...                                                     ul_throughput=150M
    ...                                                     dl_throughput=2200MKbits/sec
    ...                                                     whether_do_ue_prepare=${whether_do_ue_prepare}
    ...                                                     whether_need_ue_log=${False}
    ...                                                     whether_start_dl_call=${True}
    ...                                                     whether_start_ul_call=${True}
    ...                                                     whether_check_scell_addition=${False}
    ...                                                     whether_check_tupt=${True}
    ...                                                     target_DL_avg_percent=0.3
    ...                                                     target_UL_avg_percent=0.3
    ...                                                     min_DL_percent=0.1
    ...                                                     min_UL_percent=0.1
    ...                                                     whether_DL_nonGBR=${True}
    ...                                                     enb_index=${fdd_enb_index}
    ${syslog_file}    Run Keyword And Continue On Failure    Get Syslog File During Specific Time    syslog_start_time=${SYSLOG_START_TIME}
    ${syslog_file_path}    Run Keyword And Continue On Failure   Evaluate    '/'.join(${syslog_file.split('/')[0:-1]})
    Run Keyword And Ignore Error    Check ERR Or WRN From Syslog    sys_logs_path=${syslog_file_path}
    ...     UTE_logs_path=/home/ute/ERR_WRN_logs    Fail_Case=True    Check_RF_Log=True    timeout=50 minutes
    Run Keyword And Continue On Failure    Check ERR Syslog Existed
    Check Mutiple NonGBR Success    wireshark_log=${attach_info['cpif_log_path']}
    [Teardown]    Run Keywords    TMO_Common_Case_Teardown   AND
    ...    Update Special Apn    apn_address=mdrb.nokia.com    except_apn=${tl.core.pdns[0].apn}
    ...                          plmn=${tl.core.mcc}${tl.core.mnc}   mcc=${tl.core.mcc}    mnc=${tl.core.mnc}
    ...                          except_name=sa    ue_index=${ue_index}


5603008_TOL_21A_5GC784_emergency_CALL_911
    [Documentation]    for qualcomm ue, power on screen and unlock screen first
    ...                L3 call: SA
    ...                for TL813, pcell 301
    [Tags]    T813_RRM    T080_RRM
    [Setup]    TMO_Common_Case_Setup
    FOR    ${enb_index}    IN RANGE    ${enb_length}
        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
    END
    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
    Get Syslog Start Time
    Procedures.Verify CA Basic L3 Call    ul_throughput=250M
    ...                                   dl_throughput=2500MKbits/sec
    ...                                   tput_collect_duration=120
    ...                                   whether_need_ue_log=${False}
    ...                                   whether_check_scell_addition=${False}
    ...                                   ignore_time=15sec
    ...                                   enb_index=${fdd_enb_index}
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log
    ...                                    tcpdump_collector_name=emergency_call
    ...                                    asik_connection_alias=ASIK Master
    ...                                    gnb_index=${0}
    Sleep    5sec
    Make Emergency Call
    Sleep    30sec
    Hang Up Emergency Call
    ${911_wireshark}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection    tcpdump_collector_name=emergency_call
    Procedures.Check TMO Throughput    ue_index=${0}
    ...                                addition_scell_index_list=${SCELL_INDEX_LIST}
    ...                                tput_collect_duration=120
    ...                                ignore_time=5sec
    ${syslog_file}    Run Keyword And Continue On Failure    Get Syslog File During Specific Time    syslog_start_time=${SYSLOG_START_TIME}
    ${syslog_file_path}    Run Keyword And Continue On Failure   Evaluate    '/'.join(${syslog_file.split('/')[0:-1]})
    Run Keyword And Ignore Error    Check ERR Or WRN From Syslog    sys_logs_path=${syslog_file_path}
    ...     UTE_logs_path=/home/ute/ERR_WRN_logs    Fail_Case=True    Check_RF_Log=True    timeout=50 minutes
    Run Keyword And Continue On Failure    Check ERR Syslog Existed
    Check Emergency Call Success    log_path=${911_wireshark}
    [Teardown]    TMO_Common_Case_Teardown


5603012_TOL_22R1_5GC2329_IWK_5GC1390_RRM01_1UE_CA_TF_L3Call_1UE_CA_FT_L3call_N41_N71
    [Documentation]    TL813:UE0-SDX65, 100M+20M_cellID_301_1. UE1: MTK M70, AHLOA0+AEHC0, 15M+100M, cellID_1_301.
    ...                L3 call: SA
    [Tags]    T813_RRM
    [Setup]    TMO_Common_Case_Setup
    ${scell_index_list}    Create List    ${1}    ${2}    ${3}    ${21}    ${22}    ${23}
    ${all_scell_list}    Get Dictionary Keys   ${SCELL_MAPPING}
    Modify WeightForSCellSelection Parameter Value On Gnb    scell_list_used_in_fact=${scell_index_list}
    ...                                                      scell_list_supported=${all_scell_list}
    FOR    ${enb_index}    IN RANGE    ${enb_length}
        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
    END
    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
    Get Syslog Start Time
    Procedures.Verify CA Basic L3 Call    ul_throughput=150M
    ...                                   dl_throughput=2200MKbits/sec
    ...                                   whether_need_ue_log=${False}
    ...                                   start_keep_on_duration=2400
    ...                                   ignore_time=1min
    ...                                   tput_collect_duration=60
    ...                                   check_ul_pcell_tput_type=layer1
    ...                                   enb_index=${fdd_enb_index}
    Multi-UE_Case_Setup    ue_index=${1}
    ${ue_type1}    translate_power_ue_type_from_testline    ue_index=${1}
    Run keyword if    '${ue_type1}' == 'mtk'    MTK_common_keywords.Get UE Airmode status and Turnoff Airplane Mode    ue_index=${1}
#    Run Keyword If    '${ue_type1}'=='samsung'
#    ...       Change Network Mode For Samsung    ue_type=${ue_type1}    ue_index=${1}    netword_mode=5G
    Procedures.Verify CA Basic L3 Call    ue_index=${1}
    ...                                   ue_type=${ue_type1}
    ...                                   ul_throughput=100M
    ...                                   dl_throughput=1800MKbits/sec
    ...                                   whether_need_ue_log=${False}
    ...                                   notbarred_cell_index=${PCELL_INDEX_1}
    ...                                   expect_addition_scell_indexs=${SCELL_INDEX_LIST_1}
    ...                                   start_keep_on_duration=1200
    ...                                   whether_do_ue_prepare=${True}
    ...                                   ignore_time=1min
    ...                                   tput_collect_duration=60
    ...                                   pcell_mapping=${PCELL_MAPPING_1}
    ...                                   scell_mapping=${SCELL_MAPPING_1}
    ...                                   target_DL_avg_percent=0.75
    ...                                   target_UL_avg_percent=0.5
    ...                                   min_DL_percent=0.7
    ...                                   min_UL_percent=0.2
    ...                                   enb_index=${fdd_enb_index}
    ${syslog_file}    Run Keyword And Continue On Failure    Get Syslog File During Specific Time    syslog_start_time=${SYSLOG_START_TIME}
    ${syslog_file_path}    Run Keyword And Continue On Failure   Evaluate    '/'.join(${syslog_file.split('/')[0:-1]})
    Run Keyword And Ignore Error    Check ERR Or WRN From Syslog    sys_logs_path=${syslog_file_path}
    ...     UTE_logs_path=/home/ute/ERR_WRN_logs    Fail_Case=True    Check_RF_Log=True    timeout=50 minutes
    Run Keyword And Continue On Failure    Check ERR Syslog Existed
    ${host}   Start To Capture Aasyslog    gnb_index=${0}    du_index=${0}
    Sleep    15sec
    ${tupt_file_path2}    Stop To Capture And Download Aasyslog    host=${host}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    TMO_Common_Case_Teardown
    ...                    AND    Run Keyword And Ignore Error    TMO_Common_Case_Teardown    ue_index=${1}    ue_type=${ue_type1}

5603090_TOL_case_90_23R1_SA_intra-NR_inter-frequency_UE_based_ANR_HO_SA
    [Documentation]    TL813:UE0-SDX65, 5G SA, AEHC0 handover to AHLOA0, cellID301 to cell1
    ...                ANR handover should without call
    ...    L3 call: SA
    [Tags]    T813_RRM
    [Setup]    TMO_Common_Case_Setup
#    Update DrxLongCycle Of All 5G Cell    drxLongCycle=320ms
    ${ue_index}=  Get Variable Value    ${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}    ${ue_index}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_type}
    Update values of some ANR parameters    pcell_index=${PCELL_INDEX}    ho_pcell_index=${HO_PCELL_INDEX}
    Get NRREL Config For Intra Frequency    source_cell_idx=${PCELL_INDEX}    target_cell_idx=${HO_PCELL_INDEX}
#    ${not_barred_cell}    Create List    ${PCELL_INDEX}    ${HO_PCELL_INDEX}
    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
    Get Syslog Start Time
    ${attach_info}    Procedures.Verify CA Basic L3 Call    whether_start_dl_call=${False}
    ...                                                     whether_start_ul_call=${False}
    ...                                                     whether_check_tupt=${False}
    ...                                                     whether_do_barred_action=${False}
    ...                                                     whether_check_scell_addition=${False}
    ...                                                     enb_index=${fdd_enb_index}
    ...                                                     ue_index=${ue_index}
    ...                                                     ue_type=${ue_type}
#    ...                                                     notbarred_cell_index=${not_barred_cell}
    IF    '${tl_prefix}'=='T816'
    ${handover_wireshark}    Procedures.Verify CA Basic Handover Test    source_pa_value=40    target_pa_value=15
    ...           whether_check_scell_addition=${False}
    ELSE
	${handover_wireshark}    Procedures.Verify CA Basic Handover Test    source_pa_value=35    target_pa_value=15
    ...           whether_check_scell_addition=${False}
	END
    ${syslog_file}    Run Keyword And Continue On Failure    Get Syslog File During Specific Time    syslog_start_time=${SYSLOG_START_TIME}
    ${syslog_file_path}    Run Keyword And Continue On Failure   Evaluate    '/'.join(${syslog_file.split('/')[0:-1]})
    Run Keyword And Ignore Error    Check ERR Or WRN From Syslog    sys_logs_path=${syslog_file_path}
    ...     UTE_logs_path=/home/ute/ERR_WRN_logs    Fail_Case=True    Check_RF_Log=True    timeout=50 minutes
    Run Keyword And Continue On Failure    Check ERR Syslog Existed
    Run Keyword And Continue On Failure    Message_Flow_Check.Intra Frequency Handover Process    source_ho_cpif_log_path=${handover_wireshark}
    ...                                                    target_ho_cpif_log_path=${handover_wireshark}
#    ...                                                    addition_cpif_log_path=${attach_info['cpif_log_path']}
    ...                                                    mode=SA
    ...                                                    source_pci=${PCELL_MAPPING['physicalCellId']}
    ...                                                    target_pci=${HO_PCELL_MAPPING['physicalCellId']}
    ...                                                    whether_check_contain=${True}
    Check CGI For ANR From Wireshark    log_path=${handover_wireshark}
    Wait Until Keyword Succeeds    2 min    5 sec    Check The Lcrid For Special NRREL    source_cell_idx=${PCELL_INDEX}
    ...                                                                                   target_cell_idx=${HO_PCELL_INDEX}
    ...                                                                                   nrrel_index=256
    [Teardown]    Run Keywords    Common_setup_and_teardown.Common Suite Setup    scf_name=${tl_prefix}_gNB_${stream_version}.xml
    ...                                                                           is_commission=True
    ...                    AND    Run Keyword And Ignore Error    TMO_Common_Case_Teardown    ue_index=${0}    ue_type=${ue_type}


5603104_TOL_case_104_23R1_SA_UE_based_ANR_HO_SA_failed_with_256_NRRELs_configured
    [Documentation]    TL813:UE0-SDX65, 5G SA, handover from cell301 to cell1
    ...                Jia Lei: 20240125 update counter path for sbts24R2 and other releases
    ...    L3 call: SA
    [Tags]    T813_RRM
    [Setup]    TMO_Common_Case_Setup     is_commission=True    scf_name=${tl_prefix}_5603104.xml
    ...                                                 whether_get_ca_info=${False}    whether_set_pa_value=${False}
    Wait Until Keyword Succeeds   2 min   5 sec   Connect to gnb coam via ssl   connection=GNB_OAM0   gnb_index=${0}
    ${pcell_ru_index}    Get 5G Related Info Of Cell    cell_index=${PCELL_INDEX}
    FOR    ${attenuator}    IN    @{attenuator_list}
        Run Keyword If    '${attenuator}'=='pa'
        ...        Modify PA Value Setting For Required RU    modify_ru_id=${pcell_ru_index}    ue_index=${0}
        ...    ELSE IF    '${attenuator}'=='mcs'    Set Case Related MCS Port Value    ue_index=${0}   whether_do_mcs_setup=${False}
        ...    ELSE    Log To Console     ${\n}INFO: --Use the wrong attenuator type(${attenuator}), need to check TMO_Data.py--
    END
    Update values of some ANR parameters    pcell_index=${PCELL_INDEX}    ho_pcell_index=${HO_PCELL_INDEX}
    ...                                     a3HysteresisSsbRsrp=1
    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
    Get Syslog Start Time
    ${attach_info}    Procedures.Verify CA Basic L3 Call    whether_start_dl_call=${False}
    ...                                                     whether_start_ul_call=${False}
    ...                                                     whether_check_tupt=${False}
    ...                                                     whether_do_barred_action=${False}
    ...                                                     whether_check_scell_addition=${False}
    ...                                                     expect_addition_scell_indexs=${None}
    ...                                                     scell_mapping=${None}
    ...                                                     enb_index=${fdd_enb_index}
    ${handover_wireshark}    Procedures.Verify CA Basic Handover Test    source_pa_value=35    target_pa_value=15
    ...           whether_check_scell_addition=${False}
    ${syslog_file}    Run Keyword And Continue On Failure    Get Syslog File During Specific Time    syslog_start_time=${SYSLOG_START_TIME}
    ${syslog_file_path}    Run Keyword And Continue On Failure   Evaluate    '/'.join(${syslog_file.split('/')[0:-1]})
    Run Keyword And Ignore Error    Check ERR Or WRN From Syslog    sys_logs_path=${syslog_file_path}
    ...     UTE_logs_path=/home/ute/ERR_WRN_logs    Fail_Case=True    Check_RF_Log=True    timeout=50 minutes
    Run Keyword And Continue On Failure    Check ERR Syslog Existed
    sleep   5min
    Check Counter Value For ANR     cell_index=${PCELL_INDEX}
    Message_Flow_Check.Intra Frequency Handover Process
    ...                                                    source_ho_cpif_log_path=${handover_wireshark}
    ...                                                    target_ho_cpif_log_path=${handover_wireshark}
#    ...                                                    addition_cpif_log_path=${attach_info['cpif_log_path']}
    ...                                                    mode=SA
    ...                                                    source_pci=${PCELL_MAPPING['physicalCellId']}
    ...                                                    target_pci=${HO_PCELL_MAPPING['physicalCellId']}
    ...                                                    whether_check_contain=${True}
    Check CGI For ANR From Wireshark    log_path=${handover_wireshark}
    [Teardown]    Run Keywords    Common_setup_and_teardown.Common Suite Setup    scf_name=${tl_prefix}_gNB_${stream_version}.xml
    ...                                                                           is_commission=True
    ...                    AND    Run Keyword And Ignore Error    TMO_Common_Case_Teardown    ue_index=${0}    ue_type=${ue_type}



5603106_TOL_case_106_SA_2UE_L3_call_locked_all_cells_hanging_resource_check
    [Documentation]    TL813:UE0-SDX65, NSA call, ltecell_11+5gcell_301+cell_311. UE1: MTK M70, SA Call, cellID301+311.
    ...    L3 call: SA
    [Tags]    T813_RRM
    [Setup]    TMO_Common_Case_Setup
    FOR    ${enb_index}    IN RANGE    ${enb_length}
        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
    END
    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
    Get Syslog Start Time
    Procedures.Verify CA Basic L3 Call        ue_mode=NSA
        ...                                   ul_throughput=150M
        ...                                   dl_throughput=2500MKbits/sec
        ...                                   notbarred_cell_index=all
        ...                                   b1_select_cell_index=${PCELL_INDEX}
        ...                                   exp_status=barred
        ...                                   whether_do_lte_barred_action=${True}
        ...                                   whether_check_scell_addition=${False}
        ...                                   start_keep_on_duration=1200
        ...                                   tput_collect_duration=60
        ...                                   ignore_time=15sec
        ...                                   target_DL_avg_percent=0.1
        ...                                   target_UL_avg_percent=0.1
        ...                                   min_DL_percent=0.001
        ...                                   min_UL_percent=0.001
        ...                                   enb_index=${fdd_enb_index}
    FOR    ${enb_index}    IN RANGE    ${enb_length}
        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
    END
    Multi-UE_Case_Setup    ue_index=${1}
    ${ue_type1}    translate_power_ue_type_from_testline    ue_index=${1}
#    Run Keyword If    '${ue_type1}'=='samsung'
#    ...       Change Network Mode For Samsung    ue_type=${ue_type1}    ue_index=${1}    netword_mode=5G
    Procedures.Verify CA Basic L3 Call    ue_index=${1}
    ...                                   ue_type=${ue_type1}
    ...                                   ul_throughput=100M
    ...                                   dl_throughput=2000MKbits/sec
    ...                                   whether_need_ue_log=${False}
    ...                                   notbarred_cell_index=${PCELL_INDEX_1}
    ...                                   expect_addition_scell_indexs=${SCELL_INDEX_LIST_1}
    ...                                   whether_check_scell_addition=${False}
    ...                                   start_keep_on_duration=1200
    ...                                   whether_do_ue_prepare=${True}
    ...                                   ignore_time=15sec
    ...                                   tput_collect_duration=120
    ...                                   pcell_mapping=${PCELL_MAPPING_1}
    ...                                   scell_mapping=${SCELL_MAPPING_1}
    ...                                   target_DL_avg_percent=0.1
    ...                                   target_UL_avg_percent=0.1
    ...                                   min_DL_percent=0.001
    ...                                   min_UL_percent=0.001
    ...                                   enb_index=${fdd_enb_index}
    Do All Type Cells Action And Verify Status    cell_action=locked    enb_index=${fdd_enb_index}
    Sleep    10sec
    Check site hanging resource     gnb_ips=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    Do All Type Cells Action And Verify Status    cell_action=unlocked    enb_index=${fdd_enb_index}
    ${syslog_file}    Run Keyword And Continue On Failure    Get Syslog File During Specific Time    syslog_start_time=${SYSLOG_START_TIME}
    ${syslog_file_path}    Run Keyword And Continue On Failure   Evaluate    '/'.join(${syslog_file.split('/')[0:-1]})
    Run Keyword And Ignore Error    Check ERR Or WRN From Syslog    sys_logs_path=${syslog_file_path}
    ...     UTE_logs_path=/home/ute/ERR_WRN_logs    Fail_Case=True    Check_RF_Log=True    timeout=50 minutes
    Run Keyword And Continue On Failure    Check ERR Syslog Existed
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    Do All Type Cells Action And Verify Status    cell_action=unlocked
    ...                                                           enb_index=${fdd_enb_index}
    ...     AND   Run Keyword And Ignore Error    TMO_Common_Case_Teardown    ue_index=${0}    ue_type=${ue_type}
    ...     AND   Run Keyword And Ignore Error    TMO_Common_Case_Teardown    ue_index=${1}    ue_type=${ue_type1}

5603049_TOL_case_62_SISO_1UE_NSA_1UE_SA_Lock_AMF_reset_NR_waitX2up_unlock_AMF_1UE_NSA_1UE_SA
     [Documentation]    author: xiangsheng.chu@nokia-sbell.com
     ...    UE1: SA call, nrcell 301
     ...    UE2: NSA call, ltecell 21
     ...    L3 call: SA
     [Tags]    T080_RRM
     [Setup]    TMO_Common_Case_Setup
     ${ru_type}    Set Variable If
     ... 	      '${tl_prefix}'=='T813'    AHFIG
     ... 	      '${tl_prefix}'=='T080' 	AHFII
     ... 	      '${tl_prefix}'=='T073' 	AHFIB
     &{fault_7107}     Create Dictionary     faultId=${7107}
     &{fault_6117}     Create Dictionary     faultId=${6117}
     ${GNB_ALLOWED_FAULT_AMF_LOCK}    Create List    @{GNB_ALLOWED_FAULT}    ${fault_7107}    ${fault_6117}
     ${lte_whether_in_gnb}    Check LTE Whether In Gnb
     ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
     Get Syslog Start Time
     Procedures.Verify CA Basic L3 Call    ue_index=${0}
     ...                                   ue_type=${ue_type}
     ...                                   ul_throughput=150M
     ...                                   dl_throughput=2200MKbits/sec
     ...                                   whether_do_ue_prepare=${False}
     ...                                   whether_need_ue_log=${False}
     ...                                   whether_start_dl_call=${True}
     ...                                   whether_start_ul_call=${True}
     ...                                   whether_check_scell_addition=${False}
     ...                                   whether_check_tupt=${True}
     ...                                   target_DL_avg_percent=0.1
     ...                                   target_UL_avg_percent=0.1
     ...                                   min_DL_percent=0.001
     ...                                   min_UL_percent=0.001
     ...                                   enb_index=${fdd_enb_index}
     ${ue_index1}  Set Variable If    '${tl_prefix}'=='T080'    1    1
     Multi-UE_Case_Setup    ue_index=${ue_index1}
     ${ue_type1}    translate_power_ue_type_from_testline    ue_index=${ue_index1}
     Procedures.Start UE Prepare    ue_index=${ue_index1}    ue_type=${ue_type1}
     ${check_scell_tput}  Set Variable If    '${tl_prefix}'=='T080'    False    True
     Procedures.Verify CA Basic L3 Call    ue_index=${ue_index1}
     ...                                   ue_type=${ue_type1}
     ...                                   ul_throughput=100M
     ...                                   dl_throughput=2000MKbits/sec
     ...                                   whether_need_ue_log=${False}
     ...                                   notbarred_cell_index=all
     ...                                   exp_status=barred
     ...                                   b1_select_cell_index=${PCELL_INDEX_1}
     ...                                   whether_check_scell_addition=${False}
     ...                                   start_keep_on_duration=1200
     ...                                   whether_do_ue_prepare=${False}
     ...                                   ignore_time=15sec
     ...                                   tput_collect_duration=120
     ...                                   pcell_mapping=${PCELL_MAPPING_1}
     ...                                   scell_mapping=${SCELL_MAPPING_1}
     ...                                   target_DL_avg_percent=0.1
     ...                                   target_UL_avg_percent=0.1
     ...                                   min_DL_percent=0.001
     ...                                   min_UL_percent=0.001
     ...                                   sleep_interval=50 sec
     ...                                   ue_mode=NSA
     ...                                   list_cell_ids=${LTE_CELL_INDEX_1}
     ...                                   whether_do_lte_barred_action=${True}
     ...                                   check_scell_tput=${check_scell_tput}
     ...                                   enb_index=${fdd_enb_index}
     Run Keyword And Continue On Failure    Procedures.Stop TMO L3 Call And Detach    ue_index=${0}
     Run Keyword And Continue On Failure    Procedures.Stop TMO L3 Call And Detach    ue_index=${ue_index1}    ue_type=${ue_type1}
     Update AMF Status   administrativeState=Locked
     ${expected_value_amf}  Set Variable If    '${tl_prefix}'=='T080'    Unlocked    Locked
     Verify SERVEDAMF Status On GNB    administrativeState=Locked   ngLinkStatus=Inactive    expected_value=${expected_value_amf}
     ...    ru_type=${ru_type}    allowed_faults=${GNB_ALLOWED_FAULT_AMF_LOCK}
     Connect to gnb coam via ssl    connection=GNB_OAM
     coam.reset_site    wait_for_reconnection=${True}    timeout=600    connection=GNB_OAM
     sleep     60s
     Check All Cells Should Be On Air Except Special RU Related Cells    ru_type=${ru_type}
     Connect to gnb coam via ssl    connection=GNB_OAM
     Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${GNB_ALLOWED_FAULT_AMF_LOCK}
     Update AMF Status   administrativeState=Unlocked
     Verify SERVEDAMF Status On GNB    administrativeState=Unlocked   ngLinkStatus=Active    expected_value=Unlocked
     Log To Console     ${\n}INFO: -- Start to test UE0 for SA mode--
     #Deployment SA And NSA Mode For 2UE Module    ue_mode=SA    ue_index=${0}    apn_address=${tl.core.pdns[0].apn}
#     Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=${LTE_CELL_INDEX_1}   exp_status=barred    enb_index=${fdd_enb_index}
     Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${fdd_enb_index}
     sleep     300s
     Procedures.Verify CA Basic L3 Call    ue_index=${0}
     ...                                                     ue_type=${ue_type}
     ...                                                     ul_throughput=150M
     ...                                                     dl_throughput=2200MKbits/sec
     ...                                                     whether_do_ue_prepare=${False}
     ...                                                     whether_need_ue_log=${False}
     ...                                                     whether_start_dl_call=${True}
     ...                                                     whether_start_ul_call=${True}
     ...                                                     whether_check_scell_addition=${False}
     ...                                                     whether_check_tupt=${True}
     ...                                                     target_DL_avg_percent=0.1
     ...                                                     target_UL_avg_percent=0.1
     ...                                                     min_DL_percent=0.001
     ...                                                     min_UL_percent=0.001
     ...                                                     enb_index=${fdd_enb_index}
     Procedures.Verify CA Basic L3 Call    ue_index=${ue_index1}
     ...                                   ue_type=${ue_type1}
     ...                                   ul_throughput=100M
     ...                                   dl_throughput=2000MKbits/sec
     ...                                   whether_need_ue_log=${False}
     ...                                   notbarred_cell_index=all
     ...                                   exp_status=barred
     ...                                   b1_select_cell_index=${PCELL_INDEX_1}
     ...                                   whether_check_scell_addition=${False}
     ...                                   start_keep_on_duration=1200
     ...                                   whether_do_ue_prepare=${False}
     ...                                   ignore_time=15sec
     ...                                   tput_collect_duration=120
     ...                                   pcell_mapping=${PCELL_MAPPING_1}
     ...                                   scell_mapping=${SCELL_MAPPING_1}
     ...                                   target_DL_avg_percent=0.1
     ...                                   target_UL_avg_percent=0.1
     ...                                   min_DL_percent=0.001
     ...                                   min_UL_percent=0.001
     ...                                   ue_mode=NSA
     ...                                   list_cell_ids=${LTE_CELL_INDEX_1}
     ...                                   whether_do_lte_barred_action=${True}
     ...                                   check_scell_tput=${check_scell_tput}
     ...                                   enb_index=${fdd_enb_index}
     Procedures.Stop TMO L3 Call And Detach    ue_index=${0}
     Procedures.Stop TMO L3 Call And Detach    ue_index=${ue_index1}    ue_type=${ue_type1}
    ${syslog_file}    Run Keyword And Continue On Failure    Get Syslog File During Specific Time    syslog_start_time=${SYSLOG_START_TIME}
    ${syslog_file_path}    Run Keyword And Continue On Failure   Evaluate    '/'.join(${syslog_file.split('/')[0:-1]})
    Run Keyword And Ignore Error    Check ERR Or WRN From Syslog    sys_logs_path=${syslog_file_path}
    ...     UTE_logs_path=/home/ute/ERR_WRN_logs    Fail_Case=True    Check_RF_Log=True    timeout=100 minutes
    Run Keyword And Continue On Failure    Check ERR Syslog Existed
     [Teardown]   Run Keywords    TMO_Common_Case_Teardown   ue_index=${0}   AND
     ...     TMO_Common_Case_Teardown   ue_index=${ue_index1}    ue_type=${ue_type1}    AND
     ...     Run Keyword And Continue On Failure    Update AMF Status    administrativeState=Unlocked

5603070_VONRCALL_UE1MOC_to_UE2MTC
    [Documentation]    author: Jasper.jiao@nokia-sbell.com
    ...    Test UE1 (TDD CELL) call UE2(FDD CELL) at bad radio conditon
    [Tags]    T816_RRM   T813_RRM    T073_RRM   T283_RRM
    [Setup]    TMO_Common_Case_Setup    whether_set_pa_value=${False}
    ### setting PA ####
    Trun Off All PA Ports
    ${PA_TDD_RU}    Set Variable If    '${tl_prefix}'=='T816'     ${60}
    ...                                '${tl_prefix}'=='T073'     ${60}
    ...                                '${tl_prefix}'=='T813'     ${55}
    ...                                '${tl_prefix}'=='T283'     ${43}
    ${PA_FDD_RU}    Set Variable If    '${tl_prefix}'=='T816'     ${60}
    ...                                '${tl_prefix}'=='T073'     ${50}
    ...                                '${tl_prefix}'=='T813'     ${42}
    ...                                '${tl_prefix}'=='T283'     ${47}
    ${FDD_RU_index}   Set Variable If    '${tl_prefix}'=='T816'     ${2}     ${3}
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    RU_id=0   value=${PA_TDD_RU}
    ### Disable A2 measurement ###
    ${MRBTS_ID}    Set Variable    ${tl.gnbs[0].instance_id}
    ${NRBTS_ID}    Set Variable    ${tl.gnbs[0].global_bts_id}
    Log To Console    \n***start to modify parameters***
    ${a2MeashoEnabledSA_NRCELL-301}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-301',
    ...    'parameter':'a2MeashoEnabledSA','value':'none'}
    ${a2MeashoEnabledSA_NRCELL-1}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1',
    ...    'parameter':'a2MeashoEnabledSA','value':'none'}
    ${qRxLevMin_NRCELL-301}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-301',
    ...    'parameter':'qRxLevMin','value':'-62'}
    ${qRxLevMin_NRCELL-1}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1',
    ...    'parameter':'qRxLevMin','value':'-62'}
    ${update_param}    Catenate    ${a2MeashoEnabledSA_NRCELL-301},${a2MeashoEnabledSA_NRCELL-1},
    ...                            ${qRxLevMin_NRCELL-301},${qRxLevMin_NRCELL-1}
    ${update_param}     evaluate   [${update_param}]
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${update_param}    gnb_index=0
    #### start UE  RACH and L3 call ####
    ${ue_index0}    Set Variable If    '${tl_prefix}'=='T816'     ${3}     ${0}
    ${ue_type0}    translate_power_ue_type_from_testline    ue_index=${ue_index0}
    Procedures.Verify CA Basic L3 Call    ue_index=${ue_index0}
     ...                                  ul_throughput=10M
     ...                                  dl_throughput=20MKbits/sec
    ...                                   tput_collect_duration=120
    ...                                   whether_need_ue_log=${False}
    ...                                   whether_check_scell_addition=${False}
    ...                                   check_scell_tput=${False}
    ...                                   ignore_time=15sec
    ...                                   expect_addition_scell_indexs=${None}
    ...                                   scell_mapping=${None}
    ...                                   check_pcell_tput_type=not_peak
    ...                                   check_ul_pcell_tput_type=not_peak
    ...                                   ue_type=${ue_type0}
    ...                                   whether_check_tupt=${False}
    ...                                   start_keep_on_duration=3600
    ${ue_index1}    Set Variable If    '${tl_prefix}'=='T080'     ${3}
    ...                                '${tl_prefix}'=='T073'     ${14}
    ...                                '${tl_prefix}'=='T813'     ${1}
    ...                                '${tl_prefix}'=='T283'     ${1}
    ...                                '${tl_prefix}'=='T816'     ${2}
    Multi-UE_Case_Setup    ue_index=${ue_index1}
    ${ue_type1}    translate_power_ue_type_from_testline    ue_index=${ue_index1}
    Procedures.Start UE Prepare    ue_index=${ue_index1}    ue_type=${ue_type1}
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    RU_id=0   value=${PA_TDD_RU}
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    RU_id=${FDD_RU_index}
    ...         value=${PA_FDD_RU}
    Procedures.Verify CA Basic L3 Call    ue_index=${ue_index1}
    ...                                   ul_throughput=10M
    ...                                   dl_throughput=20MKbits/sec
    ...                                   tput_collect_duration=120
    ...                                   whether_need_ue_log=${False}
    ...                                   whether_check_scell_addition=${False}
    ...                                   check_scell_tput=${False}
    ...                                   ignore_time=15sec
    ...                                   expect_addition_scell_indexs=${None}
    ...                                   scell_mapping=${None}
    ...                                   check_pcell_tput_type=not_peak
    ...                                   check_ul_pcell_tput_type=not_peak
    ...                                   notbarred_cell_index=${PCELL_INDEX_${ue_index1}}
    ...                                   ue_type=${ue_type1}
    ...                                   whether_check_tupt=${False}
    ...                                   start_keep_on_duration=3600
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log
    ...                                    tcpdump_collector_name=vonr_call
    ...                                    asik_connection_alias=ASIK Master
    ...                                    gnb_index=${0}
    #### Vonr Test ####
    ${vonr_called_num}    Set Variable If    '${tl_prefix}'=='T073'     ${008613100020745}
    ...                                      '${tl_prefix}'=='T813'     ${13100011581}
    ...                                      '${tl_prefix}'=='T283'     ${13100011562}
    ...                                      '${tl_prefix}'=='T816'     ${13100008739}
    run keyword and continue on failure    Make Vonr Call    ue_index=${ue_index0}    phone_number=${vonr_called_num}
    Run Keyword And Ignore Error   Answer Vonr Call   ue_index=${ue_index1}
    sleep   60sec
    Run Keyword And Ignore Error   Hang Up Vonr Call  ue_index=${ue_index0}
    ${vonr_wireshark}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...   tcpdump_collector_name=vonr_call
    Check VoNR Call Success    log_path=${vonr_wireshark}
    #### ue deatach ####
    Procedures.Stop TMO L3 Call And Detach    ue_index=${ue_index0}
    Procedures.Stop TMO L3 Call And Detach    ue_index=${ue_index1}
    [Teardown]    Run Keywords    Common_setup_and_teardown.Common Suite Setup    scf_name=${tl_prefix}_gNB_${stream_version}.xml
    ...                                                                           is_commission=True
    ...                                                                           timeout_for_commission=20 min
    ...                    AND    Run Keyword And Ignore Error    TMO_Common_Case_Teardown    ue_index=${ue_index0}
    ...                                                                           ue_type=${ue_type0}
    ...                    AND    Run Keyword And Ignore Error    TMO_Common_Case_Teardown    ue_index=${ue_index1}
    ...                                                                           ue_type=${ue_type1}

#5603070_TOL_AZHL_08_NR_VONRCALL_UE1MOC_to_UE2MTC
#     [Documentation]    author: tingting.1.liu@nokia-sbell.com
#     ...    ue_index:0, 2UE-MultiUE, spark license needed before TA running!
#     [Tags]    T816_RRM
#     [Setup]    TMO_AZHL_case_setup
#     Trun Off All PA Ports
#     gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    RU_id=0   value=0
#     Log To Console     ${\n}INFO: -- Start to prepare ue--
#     Procedures.Start UE Prepare    ue_index=${0}
#     ${ue1_type}    translate_power_ue_type_from_testline    ue_index=${1}
#     Set Test Variable    ${ue1_type}
#     Procedures.Start UE Prepare    ue_index=${1}    ue_type=${ue1_type}
#     Change Network Mode Between SA And NSA For 2UE Module    ue_mode=SA    ue_index=${0}
#     #Deployment SA And NSA Mode For 2UE Module    ue_mode=SA    ue_index=${0}    apn_address=${tl.core.pdns[0].apn}
#     ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
#     Get Syslog Start Time
#     Procedures.Verify Non-CA Basic L3 Call    ue_index=${0}   whether_check_on_air=${False}
#     ...                                   is_power_ue_code=${True}
#     ...                                   whether_check_tupt=${False}
#     ...                                   whether_stop_uelog=${False}
#     ...                                   whether_start_uelog=${False}
#     ...                                   whether_do_barred_action=${False}
#     ...                                   whether_start_traffic=${False}
#     ...                                   whether_check_attach_cell=${False}
#     ...                                   whether_do_ue_prepare=${False}
#     ...                                   apn_address=${tl.core.pdns[0].apn}
#     ...                                   enb_index=${fdd_enb_index}
#	 Log To Console     ${\n}INFO: -- Start to test UE1 for SA mode--
#     Change Network Mode Between SA And NSA For 2UE Module    ue_mode=SA    ue_index=${1}
#     #Deployment SA And NSA Mode For 2UE Module    ue_mode=SA    ue_index=${1}    apn_address=${tl.core.pdns[0].apn}
#     Procedures.Verify Non-CA Basic L3 Call    ue_index=${1}   whether_check_on_air=${False}
#     ...                                   ue_type=${ue1_type}
#     ...                                   is_power_ue_code=${True}
#     ...                                   whether_check_tupt=${False}
#     ...                                   whether_stop_uelog=${False}
#     ...                                   whether_start_uelog=${False}
#     ...                                   whether_do_barred_action=${False}
#     ...                                   whether_start_traffic=${False}
#     ...                                   whether_check_attach_cell=${False}
#     ...                                   whether_do_ue_prepare=${True}
#     ...                                   apn_address=${tl.core.pdns[0].apn}
#     ...                                   enb_index=${fdd_enb_index}
#     Run Keyword And Continue On Failure    Start Container Capture Wireshark Log
#     ...                                    tcpdump_collector_name=vonr_call
#     ...                                    asik_connection_alias=ASIK Master
#     ...                                    gnb_index=${0}
#     Run Keyword And Ignore Error   Make Vonr Call From UE1 To UE2    ue_index=${0}    ue_phone_number=ATD008613032996636;
#     sleep   5sec
#     Run Keyword And Ignore Error   UE_Answer_Vonr_call    ue_index=${1}
#     sleep   10sec
#     Run Keyword And Ignore Error   Hang Up Vonr Call For Model     ue_index=${0}
#     sleep   10sec
#     Run Keyword And Ignore Error   Hang Up Vonr Call For Model     ue_index=${1}
#     ${vonr_wireshark}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection    tcpdump_collector_name=vonr_call
#     Run Keyword And Ignore Error   Spark_common_keywords.Stop L3 Traffic   ue_index=${0}
#     Run Keyword And Ignore Error   Spark_common_keywords.Stop L3 Traffic   ue_index=${1}
#     Procedures.Stop TMO L3 Call And Detach    ue_index=${0}    is_power_ue_code=${True}
#     Procedures.Stop TMO L3 Call And Detach    ue_index=${1}    is_power_ue_code=${True}    ue_type=${ue1_type}
#    ${syslog_file}    Run Keyword And Continue On Failure    Get Syslog File During Specific Time    syslog_start_time=${SYSLOG_START_TIME}
#    ${syslog_file_path}    Run Keyword And Continue On Failure   Evaluate    '/'.join(${syslog_file.split('/')[0:-1]})
#    Run Keyword And Continue On Failure    Check ERR Or WRN From Syslog    sys_logs_path=${syslog_file_path}
#    ...     UTE_logs_path=/home/ute/ERR_WRN_logs    Fail_Case=True    Check_RF_Log=True
#     [Teardown]   Run Keywords    TMO_Common_Case_Teardown   ue_index=${0}    is_power_ue_code=${True}   AND
#     ...             TMO_Common_Case_Teardown   ue_index=${1}    is_power_ue_code=${True}    ue_type=${ue1_type}

#5603049_TOL_case_62_SISO_1UE_NSA_1UE_SA_Lock_AMF_reset_NR_waitX2up_unlock_AMF_1UE_NSA_1UE_SA
#     [Documentation]    author: tingting.1.liu@nokia-sbell.com
#     ...    UE1: SA call, nrcell 301
#     ...    UE2: NSA call, ltecell 21
#     [Tags]    T816_RRM
#     [Setup]    TMO_AZHL_case_setup
#     ${lte_whether_in_gnb}    Check LTE Whether In Gnb
#     Set Test Variable    ${LTE_WHETHER_IN_GNB}    ${lte_whether_in_gnb}
#     Trun Off All PA Ports
#     gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    RU_id=0   value=0
#     gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    RU_id=2   value=20
#     ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
#     Change cellBarred Parameter Value Of Lte Cells        list_cell_ids=${21}    exp_status=notBarred
#     ...                                   enb_index=${fdd_enb_index}
#     Change cellBarred Parameter Value On Gnb    pcell_index=${301}    exp_status=notBarred
#     Log To Console     ${\n}INFO: -- Start to prepare ue--
#     Procedures.Start UE Prepare    ue_index=${0}
#     ${ue1_type}    translate_power_ue_type_from_testline    ue_index=${1}
#     Set Test Variable    ${ue1_type}
#     Procedures.Start UE Prepare    ue_index=${1}    ue_type=${ue1_type}
#     Log To Console     ${\n}INFO: -- Start to test UE0 for SA mode--
#     Change Network Mode Between SA And NSA For 2UE Module    ue_mode=SA    ue_index=${0}
##     #Deployment SA And NSA Mode For 2UE Module    ue_mode=SA    ue_index=${0}    apn_address=${tl.core.pdns[0].apn}
#     ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
#     Procedures.Verify Non-CA Basic L3 Call    ue_index=${0}
#     ...                                   ue_mode=SA
#     ...                                   is_power_ue_code=${True}
#     ...                                   whether_do_barred_action=${False}
#     ...                                   whether_do_lte_cell_barred=${False}
#     ...                                   dl_throughput=2000MKbits/sec
#     ...                                   notbarred_cell_index=${301}
#     ...                                   whether_stop_uelog=${False}
#     ...                                   whether_start_uelog=${False}
#     ...                                   whether_do_ue_prepare=${False}
#     ...                                   whether_check_attach_cell=${False}
#     ...                                   whether_check_on_air=${False}
#     ...                                   start_keep_on_duration=1200
#     ...                                   tput_collect_duration=180
#     ...                                   apn_address=${tl.core.pdns[0].apn}
#     ...                                   expect_dl_tput=500
#     ...                                   expect_ul_tput=25
#     ...                                   enb_index=${fdd_enb_index}
#     Log To Console     ${\n}INFO: -- Start to test UE1 for NSA mode--
#     Change Network Mode Between SA And NSA For 2UE Module    ue_mode=NSA    ue_index=${1}
##     #Deployment SA And NSA Mode For 2UE Module    ue_mode=NSA    ue_index=${1}    apn_address=${tl.core.pdns[0].apn}
#     Procedures.Verify Non-CA Basic L3 Call    ue_index=${1}
#     ...                                   ue_type=${ue1_type}
#     ...                                   ue_mode=NSA
#     ...                                   is_power_ue_code=${True}
#     ...                                   whether_do_barred_action=${False}
#     ...                                   whether_do_lte_cell_barred=${False}
#     ...                                   dl_throughput=2000MKbits/sec
#     ...                                   notbarred_cell_index=${301}
#     ...                                   whether_stop_uelog=${False}
#     ...                                   whether_start_uelog=${False}
#     ...                                   whether_check_attach_cell=${False}
#     ...                                   whether_do_lte_cell_barred=${False}
#     ...                                   whether_check_on_air=${False}
#     ...                                   whether_do_ue_prepare=${False}
#     ...                                   start_keep_on_duration=600
#     ...                                   tput_collect_duration=180
#     ...                                   apn_address=${tl.core.pdns[0].apn}
#     ...                                   expect_dl_tput=500
#     ...                                   expect_ul_tput=25
#     ...                                   enb_index=${fdd_enb_index}
#     Run Keyword And Continue On Failure    Procedures.Stop TMO L3 Call And Detach    ue_index=${0}    is_power_ue_code=${True}
#     ...                                    apn_address=${tl.core.pdns[0].apn}
#     Run Keyword And Continue On Failure    Procedures.Stop TMO L3 Call And Detach    ue_index=${1}    is_power_ue_code=${True}
#     ...                                    apn_address=${tl.core.pdns[0].apn}    ue_type=${ue1_type}
#     Update AMF Status   administrativeState=Locked
#     ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
#     Verify SERVEDAMF Status On GNB    administrativeState=Locked   ngLinkStatus=Inactive    expected_value=Unlocked
#     ...        enb_index=${fdd_enb_index}
#     Connect to gnb coam via ssl    connection=GNB_OAM
#     coam.reset_site    wait_for_reconnection=${True}    timeout=600    connection=GNB_OAM
#     sleep     180s
#     Check All Cells Should Be On Air Except Special RU Related Cells
#     Connect to gnb coam via ssl    connection=GNB_OAM
#     Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=@{ALLOWED_FAULT}
#     Update AMF Status   administrativeState=Unlocked
#     Verify SERVEDAMF Status On GNB    administrativeState=Unlocked   ngLinkStatus=Active    expected_value=Unlocked
#     ...        enb_index=${fdd_enb_index}
#     Log To Console     ${\n}INFO: -- Start to test UE0 for SA mode--
#     #Deployment SA And NSA Mode For 2UE Module    ue_mode=SA    ue_index=${0}    apn_address=${tl.core.pdns[0].apn}
#     Procedures.Verify Non-CA Basic L3 Call    ue_index=${0}
#     ...                                   is_power_ue_code=${True}
#     ...                                   whether_do_barred_action=${False}
#     ...                                   whether_do_lte_cell_barred=${False}
#     ...                                   dl_throughput=2000MKbits/sec
#     ...                                   notbarred_cell_index=${301}
#     ...                                   whether_stop_uelog=${False}
#     ...                                   whether_start_uelog=${False}
#     ...                                   whether_do_ue_prepare=${True}
#     ...                                   whether_check_attach_cell=${False}
#     ...                                   whether_check_on_air=${False}
#     ...                                   start_keep_on_duration=1200
#     ...                                   tput_collect_duration=180
#     ...                                   apn_address=${tl.core.pdns[0].apn}
#     ...                                   expect_dl_tput=500
#     ...                                   expect_ul_tput=25
#     ...                                   enb_index=${fdd_enb_index}
#     Log To Console     ${\n}INFO: -- Start to test UE1 for NSA mode--
#     #Deployment SA And NSA Mode For 2UE Module    ue_mode=NSA    ue_index=${1}    apn_address=${tl.core.pdns[0].apn}
#     Procedures.Verify Non-CA Basic L3 Call    ue_index=${1}
#     ...                                   ue_mode=NSA
#     ...                                   is_power_ue_code=${True}
#     ...                                   ue_type=${ue1_type}
#     ...                                   whether_do_barred_action=${False}
#     ...                                   whether_do_lte_cell_barred=${False}
#     ...                                   dl_throughput=2000MKbits/sec
#     ...                                   notbarred_cell_index=${301}
#     ...                                   whether_stop_uelog=${False}
#     ...                                   whether_start_uelog=${False}
#     ...                                   whether_check_attach_cell=${False}
#     ...                                   whether_do_lte_cell_barred=${False}
#     ...                                   whether_check_on_air=${False}
#     ...                                   whether_do_ue_prepare=${False}
#     ...                                   start_keep_on_duration=600
#     ...                                   tput_collect_duration=180
#     ...                                   apn_address=${tl.core.pdns[0].apn}
#     ...                                   expect_dl_tput=500
#     ...                                   expect_ul_tput=25
#     ...                                   enb_index=${fdd_enb_index}
#     Procedures.Stop TMO L3 Call And Detach    ue_index=${0}    is_power_ue_code=${True}    apn_address=${tl.core.pdns[0].apn}
#     Procedures.Stop TMO L3 Call And Detach    ue_index=${1}    is_power_ue_code=${True}    apn_address=${tl.core.pdns[0].apn}
#     ...                                       ue_type=${ue1_type}
#     [Teardown]   Run Keywords    TMO_Common_Case_Teardown   ue_index=${0}   is_power_ue_code=${True}    AND
#     ...     TMO_Common_Case_Teardown   ue_index=${1}   is_power_ue_code=${True}    ue_type=${ue1_type}    AND
#     ...     Run Keyword And Continue On Failure    Update AMF Status    administrativeState=Unlocked

5603007_TOL_21A_5GC746_TestID_58895_Verify CMAS coded 4 pages broadcast in RRC_CONNECTED state
     [Tags]   T816_RRM
     [Setup]    TMO_AZHL_case_setup
     Run Keyword If    '${ue_type}'!='huawei_sigspark'    Fail    msg=This case need to run on the spark enviorment.
     Set Test Variable    ${test_case_id}    ${TEST NAME.split('_')[0]}
     Set Test Variable    ${PCELL_INDEX}    ${GNB_INFO_MAPPING_TO_CASE_TABLE['${test_case_id}']['${tl_prefix}']['pcell_idx']}
     Set Test Variable    ${attenuator_list}    ${GNB_INFO_MAPPING_TO_CASE_TABLE['${test_case_id}']['${tl_prefix}']['attenuator']}
     Generate Pcell Mapping Info   pcell_index=${PCELL_INDEX}
     ${pcell_pci}    Evaluate    str(${PCELL_MAPPING['physicalCellId']})
     ${pcell_ru_index}    Set Variable    ${PCELL_MAPPING['ru_index_mapping']}
     FOR    ${attenuator}    IN    @{attenuator_list}
         Run Keyword If    '${attenuator}'=='pa'   Modify PA Value Setting For Required RU
         ...                                       modify_ru_id=${pcell_ru_index}    ue_index=${0}
         ...    ELSE IF    '${attenuator}'=='mcs'    Set Case Related MCS Port Value    ue_index=${0}
     END
     ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
     Set Test Variable    ${ue_type}
     Procedures.Start UE Prepare    ue_index=${0}
	 Log To Console     ${\n}INFO: -- Start to test UE1 for SA mode--
     Change Network Mode Between SA And NSA For 2UE Module    ue_mode=SA    ue_index=${0}
     #Deployment SA And NSA Mode For 2UE Module    ue_mode=SA    ue_index=${0}    apn_address=${tl.core.pdns[0].apn}
     Run Keyword And Ignore Error    COAM Teardown gnb connections
     ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
     Get Syslog Start Time
     Procedures.Verify Non-CA Basic L3 Call    ue_index=${0}
     ...                                   is_power_ue_code=${True}
     ...                                   ul_throughput=100MKbits/sec
     ...                                   dl_throughput=2000MKbits/sec
     ...                                   expect_dl_tput=1400
     ...                                   expect_ul_tput=50
     ...                                   start_keep_on_duration=600
     ...                                   tput_collect_duration=180
     ...                                   notbarred_cell_index=${301}
     ...                                   apn_address=${tl.core.pdns[0].apn}
     ...                                   whether_do_ue_prepare=${False}
     ...                                   whether_start_uelog=${False}
     ...                                   whether_check_tupt=${False}
    ...                                    whether_start_traffic=${False}
    ...                                    ue_mode=SA
    ...                                    4G_check=${False}
    ...                                    enb_index=${fdd_enb_index}
     ${attach_time}    DateTime.Get Current Date    result_format=%Y-%m-%d%H:%M:%S
     Get Current AMF info
     Set Test Variable   ${default_serial_number}   29344
     Set Test Variable   ${default_message_identifier}   4372
     Set Test Variable   ${default_repetition_period}   10
     Set Test Variable   ${default_number_of_broadcasts_requested}   ${3}
     Connect to gnb coam via ssl    gnb_index=${0}
     ${number_of_beam}    Get The Numeber Of Beams From Cellgroup   cell_id=${PCELL_INDEX}
     Set Test Variable    ${default_last_segment_repeat_times}    ${number_of_beam}
     Set Test Variable    ${tac}   20300
     Run Keyword And Continue On Failure     Spark_common_keywords.Spark Start UE Log    ue_index=${0}
     Log To Console     ${\n}INFO: -- Start to Trigger CMAS Notification and Capture Logs
     ${bip_log}    ${ngap_log}   Trigger CMAS Notification and Capture Logs
     ...                                   amf=${current_amf}
     ...                                   tac=${tac}
     ...                                   warning_area_list_id=${CMAS_WARNING_AREA_LIST['tai_warning_area_list']}
     ...                                   nr_phy_cell_ids=${pcell_pci}
     ...                                   mcc=310
     ...                                   mnc=260
     Spark_common_keywords.Spark Stop UE Log    ue_index=${0}
     ${wmc}    ${wac}    Check Complete Procedure for CMAS broadcasting    cpif_CMAS_log_path=${ngap_log}
     ...                                                                   bip_log_path=${bip_log}
     Check UE Log for SIB8   wmc=${wmc}    wac=${wac}   ue_index=${0}
     ${syslog_file}    Run Keyword And Continue On Failure    Get Syslog File During Specific Time    syslog_start_time=${SYSLOG_START_TIME}
     ${syslog_file_path}    Run Keyword And Continue On Failure   Evaluate    '/'.join(${syslog_file.split('/')[0:-1]})
     Run Keyword And Ignore Error    Check ERR Or WRN From Syslog    sys_logs_path=${syslog_file_path}
     ...     UTE_logs_path=/home/ute/ERR_WRN_logs    Fail_Case=True    Check_RF_Log=True    timeout=50 minutes
     Run Keyword And Continue On Failure    Check ERR Syslog Existed
     [Teardown]   TMO_Common_Case_Teardown   ue_index=${0}   is_power_ue_code=${True}

5603106_TOL_case_106_SA_2UE_L3_call_locked_all_cells_hanging_resource_check_with_spark_UE
     [Documentation]    author: tingting.1.liu@nokia-sbell.com
     ...    UE1: SA call, nrcell 301
     ...    UE2: NSA call, ltecell 21
     [Tags]    T816_RRM
     [Setup]    TMO_AZHL_case_setup
     ${lte_whether_in_gnb}    Check LTE Whether In Gnb
     Set Test Variable    ${LTE_WHETHER_IN_GNB}    ${lte_whether_in_gnb}
     Trun Off All PA Ports
     gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    RU_id=0   value=0
     gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    RU_id=2   value=20
     ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
     Change cellBarred Parameter Value Of Lte Cells        list_cell_ids=${21}    exp_status=notBarred
     ...                                   enb_index=${fdd_enb_index}
     Change cellBarred Parameter Value On Gnb    pcell_index=${301}    exp_status=notBarred
     Log To Console     ${\n}INFO: -- Start to prepare ue--
     Procedures.Start UE Prepare    ue_index=${0}
     ${ue1_type}    translate_power_ue_type_from_testline    ue_index=${1}
     Set Test Variable    ${ue1_type}
     Procedures.Start UE Prepare    ue_index=${1}    ue_type=${ue1_type}
     Log To Console     ${\n}INFO: -- Start to test UE0 for SA mode--
     Change Network Mode Between SA And NSA For 2UE Module    ue_mode=SA    ue_index=${0}
#     #Deployment SA And NSA Mode For 2UE Module    ue_mode=SA    ue_index=${0}    apn_address=${tl.core.pdns[0].apn}
     ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
     Get Syslog Start Time
     Procedures.Verify Non-CA Basic L3 Call    ue_index=${0}
     ...                                   ue_mode=SA
     ...                                   is_power_ue_code=${True}
     ...                                   whether_do_barred_action=${False}
     ...                                   whether_do_lte_cell_barred=${False}
     ...                                   dl_throughput=2000MKbits/sec
     ...                                   notbarred_cell_index=${301}
     ...                                   whether_stop_uelog=${False}
     ...                                   whether_start_uelog=${False}
     ...                                   whether_do_ue_prepare=${False}
     ...                                   whether_check_attach_cell=${False}
     ...                                   whether_check_on_air=${False}
     ...                                   start_keep_on_duration=1200
     ...                                   tput_collect_duration=180
     ...                                   apn_address=${tl.core.pdns[0].apn}
     ...                                   expect_dl_tput=500
     ...                                   expect_ul_tput=25
     ...                                   enb_index=${fdd_enb_index}
     Log To Console     ${\n}INFO: -- Start to test UE1 for NSA mode--
     Change Network Mode Between SA And NSA For 2UE Module    ue_mode=NSA    ue_index=${1}
#     #Deployment SA And NSA Mode For 2UE Module    ue_mode=NSA    ue_index=${1}    apn_address=${tl.core.pdns[0].apn}
     Procedures.Verify Non-CA Basic L3 Call    ue_index=${1}
     ...                                   ue_type=${ue1_type}
     ...                                   ue_mode=NSA
     ...                                   is_power_ue_code=${True}
     ...                                   whether_do_barred_action=${False}
     ...                                   whether_do_lte_cell_barred=${False}
     ...                                   dl_throughput=2000MKbits/sec
     ...                                   notbarred_cell_index=${301}
     ...                                   whether_stop_uelog=${False}
     ...                                   whether_start_uelog=${False}
     ...                                   whether_check_attach_cell=${False}
     ...                                   whether_do_lte_cell_barred=${False}
     ...                                   whether_check_on_air=${False}
     ...                                   whether_do_ue_prepare=${False}
     ...                                   start_keep_on_duration=600
     ...                                   tput_collect_duration=180
     ...                                   apn_address=${tl.core.pdns[0].apn}
     ...                                   expect_dl_tput=500
     ...                                   expect_ul_tput=25
     ...                                   enb_index=${fdd_enb_index}
     Do All Type Cells Action And Verify Status    cell_action=locked    enb_index=${fdd_enb_index}
     Do All Type Cells Action And Verify Status    cell_action=locked    cell_type=lte    enb_index=${fdd_enb_index}
     Sleep    10sec
     Check site hanging resource     gnb_ips=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}    ue_index=${2}
     Do All Type Cells Action And Verify Status    cell_action=unlocked    enb_index=${fdd_enb_index}    timeout=600
     Do All Type Cells Action And Verify Status    cell_action=unlocked    cell_type=lte    enb_index=${fdd_enb_index}    timeout=600
     Procedures.Stop TMO L3 Call And Detach    ue_index=${0}    is_power_ue_code=${True}    apn_address=${tl.core.pdns[0].apn}
     Procedures.Stop TMO L3 Call And Detach    ue_index=${1}    is_power_ue_code=${True}    apn_address=${tl.core.pdns[0].apn}
     ...                                       ue_type=${ue1_type}
     ${syslog_file}    Run Keyword And Continue On Failure    Get Syslog File During Specific Time    syslog_start_time=${SYSLOG_START_TIME}
     ${syslog_file_path}    Run Keyword And Continue On Failure   Evaluate    '/'.join(${syslog_file.split('/')[0:-1]})
     Run Keyword And Ignore Error    Check ERR Or WRN From Syslog    sys_logs_path=${syslog_file_path}
     ...     UTE_logs_path=/home/ute/ERR_WRN_logs    Fail_Case=True    Check_RF_Log=True    timeout=50 minutes
     Run Keyword And Continue On Failure    Check ERR Syslog Existed
     [Teardown]   Run Keywords    TMO_Common_Case_Teardown   ue_index=${0}   is_power_ue_code=${True}    AND
     ...     TMO_Common_Case_Teardown   ue_index=${1}   is_power_ue_code=${True}    ue_type=${ue1_type}    AND
     ...     Run Keyword And Continue On Failure    Do All Type Cells Action And Verify Status    cell_action=unlocked    enb_index=${fdd_enb_index}
     ...     AND    Run Keyword And Continue On Failure    Do All Type Cells Action And Verify Status
     ...            cell_action=unlocked    cell_type=lte    enb_index=${fdd_enb_index}
