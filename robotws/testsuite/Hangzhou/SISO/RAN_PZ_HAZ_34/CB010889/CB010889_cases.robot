*** Settings ***
Documentation    TMO Automation for TMO E2E CDRT cases
...              Author: xiaoxia.hao@nokia-sbell.com
Suite Setup    TMO_Common_Suite_Setup    is_commission=${True}
Test Teardown    TMO_Common_Case_Teardown
Suite Teardown    TMO_Suite_Teardown
Force Tags    5G_TOL    SG_06

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/TMO/TMO_common_keywords.robot

*** Test Cases ***
[1]CB010889_SR_AA_01_2CC_16D8U_data_transfer_100+90_1116_0ms
    [Documentation]    TL813:UE0-SDX65, 100M+40M_cellID_301_311. UE1: MTK M70, AHLOA0+AEHC0, 15M+100M, cellID_1_311.
    ...                TL813:UE0-SDX70, 100M+40M_cellID_301_311. UE1: SDX65 shared with TL283, AHLOA0+AEHC0, 15M+100M, cellID_1_311.
    [Setup]    TMO_Common_Case_Setup_For_10889    scf_name=Configuration_16D8U_10889_${stream_version}.xml    is_commission=${True}
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
    [Teardown]    Run Keywords
#    ...     Power On RF For Recover Env    AND
    ...    Run Keyword And Ignore Error    Common_setup_and_teardown.Common Suite Setup    scf_name=${tl_prefix}_gNB_${stream_version}.xml   AND
    ...    Run Keyword If    '${tl_prefix}'!='T813'  Lock Or Unlock Single Cell
    ...    cell_index=${LTE_CELL_INDEX}    cell_type=lte    action=unlock    AND
    ...    Run Keyword If    '${tl_prefix}'!='T813'  Verify The Status Of Single Cell    cell_index=${LTE_CELL_INDEX}
    ...    cell_type=lte    action=unlock    AND    Check TMO Gnb Ready And All Cell On Air    AND
    ...    Run Keyword And Ignore Error    TMO_Common_Case_Teardown

[1]CB010744_C_04_General_SiSo_E2E_system_setup_with_data_transfer_for_conducted_multicarrier_1x16DL8UL_2x8DL4UL
    [Setup]    TMO_Common_Case_Setup    scf_name=Configuration_16D8U_10744.xml    is_commission=${True}    whether_get_ca_info=${False}
    ...                                 whether_set_pa_value=${False}
#    Delete NRREL Objects Based On Technology
    Wait Until Keyword Succeeds   2 min   5 sec   Connect to gnb coam via ssl   connection=GNB_OAM0   gnb_index=${0}
    ${pcell_ru_index}    Get 5G Related Info Of Cell    cell_index=${PCELL_INDEX}
    ${ue_index0}    Set Variable If    '${tl_prefix}'=='T816'     ${3}     ${0}
    FOR    ${attenuator}    IN    @{attenuator_list}
        Run Keyword If    '${attenuator}'=='pa'
        ...     Modify PA Value Setting For Required RU    modify_ru_id=${pcell_ru_index}    ue_index=${ue_index0}
        ...     ELSE IF    '${attenuator}'=='mcs'    Set Case Related MCS Port Value    ue_index=${ue_index0}   whether_do_mcs_setup=${False}
        ...     ELSE    Log To Console     ${\n}INFO: --Use the wrong attenuator type(${attenuator}), need to check TMO_Data.py--
    END
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
    ...                                   check_scell_tput=${False}
    ...                                   scell_mapping=${None}
    ...                                   expect_addition_scell_indexs=${None}
    ...                                   whether_check_scell_addition=${False}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    Common_setup_and_teardown.Common Suite Setup
    ...                                                                                 scf_name=${tl_prefix}_gNB_${stream_version}.xml    AND
    ...    Run Keyword If    '${tl_prefix}'!='T813'  Lock Or Unlock Single Cell
    ...    cell_index=${LTE_CELL_INDEX}    cell_type=lte    action=unlock    AND
    ...    Run Keyword If    '${tl_prefix}'!='T813'  Verify The Status Of Single Cell    cell_index=${LTE_CELL_INDEX}
    ...    cell_type=lte    action=unlock    AND    Check TMO Gnb Ready And All Cell On Air    AND
    ...    Run Keyword And Ignore Error    TMO_Common_Case_Teardown

*** Keywords ***
Power Off RF For 10889
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${rf_index}=${0}
    ${poweroff_pb_list}    Create List    9    10    11    12    13    14
    ${rus}   Set Variable   ${tl.gnbs[0].dus[0].rus}
    FOR    ${rf_index}    IN     @{poweroff_pb_list}
        ${pb_host}   Set Variable   ${rus[${rf_index}].pdu_port.pdu.addr}
        ${pb_port}   Set Variable   ${rus[${rf_index}].pdu_port.port_no}
        ${pb_model}   Set Variable   ${rus[${rf_index}].pdu_port.pdu.__class__.__name__}
        BuiltIn.Log    RF${rf_index} Power off
        pdu.setup_pdu    model=${pb_model}   host=${pb_host}   alias=ru_${rf_index}
        pdu.power_off    port=${pb_port}    pdu_device=ru_${rf_index}
        Sleep    2sec
    END

Power On RF For Recover Env
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${rf_index}=${0}
    ${poweroff_pb_list}    Create List    9    10    11    12    13    14
    ${rus}   Set Variable   ${tl.gnbs[0].dus[0].rus}
    FOR    ${rf_index}    IN     @{poweroff_pb_list}
        ${pb_host}   Set Variable   ${rus[${rf_index}].pdu_port.pdu.addr}
        ${pb_port}   Set Variable   ${rus[${rf_index}].pdu_port.port_no}
        ${pb_model}   Set Variable   ${rus[${rf_index}].pdu_port.pdu.__class__.__name__}
        BuiltIn.Log    RF${rf_index} Power on
        pdu.setup_pdu    model=${pb_model}   host=${pb_host}   alias=ru_${rf_index}
        pdu.power_on    port=${pb_port}    pdu_device=ru_${rf_index}
        Sleep    2sec
    END

TMO_Common_Case_Setup_For_10889
    [Arguments]    ${ue_index}=${0}    ${whether_get_ca_info}=${True}
    ...            ${whether_set_pa_value}=${True}    ${3CC_support}=${False}
    ...            ${scf_name}=None    ${is_commission}=False    ${is_pdl_checking_needed}=${True}
    log     ${is_pdl_checking_needed}
    csn.reset_cache
    Common_setup_and_teardown.Common Case Setup    scf_name=${scf_name}    is_commission=${is_commission}
    ...    timeout_for_commission=20 min
    Create Case Log Path
#    Power Off RF For 10889
    Perform gNB Reset site and Wait Onair
    Set Test Variable    ${test_case_id}    ${TEST NAME.split('_')[0]}
    Set Test Variable    ${case_params}    ${GNB_INFO_MAPPING_TO_CASE_TABLE['${test_case_id}']['${tl_prefix}']}
    Set Test Variable    ${PCELL_INDEX}    ${case_params.get('pcell_idx')}
    Set Test Variable    ${attenuator_list}    ${case_params.get('attenuator')}
    Set Test Variable    ${ca_technology}    ${case_params.get('ca_technology')}
    ${ca_technology_status}    Run Keyword And Return Status    Dictionary Should Contain Key    ${case_params}    ca_technology
    Run Keyword If    ${ca_technology_status}    Set Test Variable    ${scell_technology}
    ...                                                               ${case_params.get('ca_technology').split('+')[-1]}
    Set Test Variable    ${LTE_CELL_INDEX}    ${case_params.get('lte_cell_idx')}
#    Set Test Variable    ${NSA_PA_RU_INDEX}    ${case_params.get('nsa_pa_ru_idx')}
    Set Test Variable    ${HO_PCELL_INDEX}    ${case_params.get('after_ho_pcell_idx')}
    ${ho_ca_technology_status}    Run Keyword And Return Status    Dictionary Should Contain Key    ${case_params}    ho_ca_technology
    Run Keyword If    ${ho_ca_technology_status}    Set Test Variable    ${HO_SCELL_TECHNOLOGY}
    ...                                                                  ${case_params.get('ho_ca_technology').split('+')[-1]}
    Run Keyword If    ${whether_get_ca_info} and ${3CC_support}==${False}    Get CA Related Infomation    pcell_index=${PCELL_INDEX}
    ...    ELSE IF    ${whether_get_ca_info} and ${3CC_support}    Get 3CC Related Infomation    pcell_index=${PCELL_INDEX}
    Run Keyword If    ${whether_set_pa_value}    Set Case PA Or MCS Port Value    attenuator_list=${attenuator_list}    ue_index=${ue_index}
    Check TMO Gnb Ready And All Cell On Air
    Verify All Enbs Cell On Air
    ${lte_whether_in_gnb}    Check LTE Whether In Gnb
    Set Test Variable    ${LTE_WHETHER_IN_GNB}    ${lte_whether_in_gnb}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_type}
    ${gnb_allowed_fault_Before_Commission}   Create List    4203    1838    4741    4681   7311   7331    7107
    ...                                                     4293    4297    4420    4775   1932   1934    1933    8150
    ...                                                     4589    6261    4776    4569    8000    2403
    Set Test Variable    ${gnb_allowed_fault_Before_Commission}
    robot_common_operations.Common Case Setup    fail_with_alarms=${False}
    AlarmWatchdog.add_allow_alarms    fault_id=${gnb_allowed_fault_Before_Commission}