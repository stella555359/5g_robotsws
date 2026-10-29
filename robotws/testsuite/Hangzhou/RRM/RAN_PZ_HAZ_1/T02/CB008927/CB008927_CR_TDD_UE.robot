*** Settings ***
Documentation
...                 author:  Liu AnAn

Resource    ../../../../resources/RAN_PZ_HAZ_1/Module/Module.robot
Library     ../../../../resources/RAN_PZ_HAZ_1/Module/Commercial_UE_Operation.py

Test Setup          Setup for CB008927_CR
Test Teardown       Teardown for CB008927_CR

Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    CA_RAN_PZ_HAZ_1    RAN_PZ_HAZ1_SG05_ST_RRM    CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC

*** Variables ***
${call_duration_short}   20
${call_duration_long}    300

${ue1_serialno}    SSXSOZYHZDGAAQ5L

${trf_server_ip}    10.106.200.83
&{dcap_info}    host=10.106.200.83    port=9443    username=${None}    password=${None}

*** Test Cases ***
CB008927_CR_R2_Active_Deactive_actRat1Alloc
    [Documentation]
    ...    author: LAA
    [Tags]    QC_7803

    # Feature off
    @{vdu_para_list}          Create List    actRat1Alloc    percRedSEDlRat1VoNR
    @{vdu_mo_list}            Create List    MRBTS-37357/NRBTS-37357/NRCELL-1
    ...                                      MRBTS-37357/NRBTS-37357/NRCELL-1
    @{vdu_value_list}         Create List    false    0
    Modify_CB008927_Parameters  para_list=@{vdu_para_list}  mo_list=@{vdu_mo_list}  value_list=@{vdu_value_list}

    # dcap start
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}
    Log Collection    start    tti    product_type=vdu    bts_index=${0}    cudu_index=${0}    dict_argument=${dict_argument}

    VoNR_Call_Setup_and_Release  ue_serialno=${ue1_serialno}  call_duration=${call_duration_short}

    # dcap stop
    ${local_file_path}    Log Collection    stop_and_download    tti    product_type=vdu    bts_index=${0}    cudu_index=${0}
    Log To Console    \nTTI log of VDU: ${local_file_path}

    # Feature on
    @{vdu_para_list}          Create List    actRat1Alloc    percRedSEDlRat1VoNR
    @{vdu_mo_list}            Create List    MRBTS-37357/NRBTS-37357/NRCELL-1
    ...                                      MRBTS-37357/NRBTS-37357/NRCELL-1
    @{vdu_value_list}         Create List    true    0
    Modify_CB008927_Parameters  para_list=@{vdu_para_list}  mo_list=@{vdu_mo_list}  value_list=@{vdu_value_list}

    # dcap start
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}
    Log Collection    start    tti    product_type=vdu    bts_index=${0}    cudu_index=${0}    dict_argument=${dict_argument}

    VoNR_Call_Setup_and_Release  ue_serialno=${ue1_serialno}  call_duration=${call_duration_short}

    # dcap stop
    ${local_file_path}    Log Collection    stop_and_download    tti    product_type=vdu    bts_index=${0}    cudu_index=${0}
    Log To Console    \nTTI log of VDU: ${local_file_path}


CB008927_CR_R2_Active_Deactive_percRedSEDlRat1VoNR
    [Documentation]
    ...    author: LAA
    [Tags]    QC_7804

    # Feature off
    @{vdu_para_list}          Create List    actRat1Alloc    percRedSEDlRat1VoNR
    @{vdu_mo_list}            Create List    MRBTS-37357/NRBTS-37357/NRCELL-1
    ...                                      MRBTS-37357/NRBTS-37357/NRCELL-1
    @{vdu_value_list}         Create List    false    0
    Modify_CB008927_Parameters  para_list=@{vdu_para_list}  mo_list=@{vdu_mo_list}  value_list=@{vdu_value_list}

    # dcap start
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}
    Log Collection    start    tti    product_type=vdu    bts_index=${0}    cudu_index=${0}    dict_argument=${dict_argument}

    VoNR_Call_Setup_and_Release  ue_serialno=${ue1_serialno}  call_duration=${call_duration_short}

    # dcap stop
    ${local_file_path}    Log Collection    stop_and_download    tti    product_type=vdu    bts_index=${0}    cudu_index=${0}
    Log To Console    \nTTI log of VDU: ${local_file_path}

    # Feature on
    @{vdu_para_list}          Create List    actRat1Alloc    percRedSEDlRat1VoNR
    @{vdu_mo_list}            Create List    MRBTS-37357/NRBTS-37357/NRCELL-1
    ...                                      MRBTS-37357/NRBTS-37357/NRCELL-1
    @{vdu_value_list}         Create List    true  95
    Modify_CB008927_Parameters  para_list=@{vdu_para_list}  mo_list=@{vdu_mo_list}  value_list=@{vdu_value_list}

    # dcap start
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}
    Log Collection    start    tti    product_type=vdu    bts_index=${0}    cudu_index=${0}    dict_argument=${dict_argument}

    VoNR_Call_Setup_and_Release  ue_serialno=${ue1_serialno}  call_duration=${call_duration_short}

    # dcap stop
    ${local_file_path}    Log Collection    stop_and_download    tti    product_type=vdu    bts_index=${0}    cudu_index=${0}
    Log To Console    \nTTI log of VDU: ${local_file_path}

CB008927_CR_R2_Active_Deactive_actDlDynSwitchAlloc
    [Documentation]
    ...    author: LAA
    [Tags]    QC_7805

    # Feature off
    @{vdu_para_list}          Create List    actRat1Alloc    actDlDynSwitchAlloc
    @{vdu_mo_list}            Create List    MRBTS-37357/NRBTS-37357/NRCELL-1
    ...                                      MRBTS-37357/NRBTS-37357/NRCELL-1
    @{vdu_value_list}         Create List    false    false
    Modify_CB008927_Parameters  para_list=@{vdu_para_list}  mo_list=@{vdu_mo_list}  value_list=@{vdu_value_list}

    # dcap start
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}
    Log Collection    start    tti    product_type=vdu    bts_index=${0}    cudu_index=${0}    dict_argument=${dict_argument}

    VoNR_Call_Setup_and_Release  ue_serialno=${ue1_serialno}  call_duration=${call_duration_short}

    # dcap stop
    ${local_file_path}    Log Collection    stop_and_download    tti    product_type=vdu    bts_index=${0}    cudu_index=${0}
    Log To Console    \nTTI log of VDU: ${local_file_path}

    # Feature on
    @{vdu_para_list}          Create List    actRat1Alloc    actDlDynSwitchAlloc
    @{vdu_mo_list}            Create List    MRBTS-37357/NRBTS-37357/NRCELL-1
    ...                                      MRBTS-37357/NRBTS-37357/NRCELL-1
    @{vdu_value_list}         Create List    true    true
    Modify_CB008927_Parameters  para_list=@{vdu_para_list}  mo_list=@{vdu_mo_list}  value_list=@{vdu_value_list}

    # dcap start
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}
    Log Collection    start    tti    product_type=vdu    bts_index=${0}    cudu_index=${0}    dict_argument=${dict_argument}

    VoNR_Call_Setup_and_Release  ue_serialno=${ue1_serialno}  call_duration=${call_duration_short}

    # dcap stop
    ${local_file_path}    Log Collection    stop_and_download    tti    product_type=vdu    bts_index=${0}    cudu_index=${0}
    Log To Console    \nTTI log of VDU: ${local_file_path}


CB008927_CR_R2_Check_Counter_MAX_ALLOC_PRB_PDSCH_RAT1_M55308C00092
    [Documentation]
    ...    author: LAA
    [Tags]    QC_7811

    @{vdu_para_list}          Create List    actRat1Alloc    percRedSEDlRat1VoNR
    @{vdu_mo_list}            Create List    MRBTS-37357/NRBTS-37357/NRCELL-1
    ...                                      MRBTS-37357/NRBTS-37357/NRCELL-1
    @{vdu_value_list}         Create List    true    50
    Modify_CB008927_Parameters  para_list=@{vdu_para_list}  mo_list=@{vdu_mo_list}  value_list=@{vdu_value_list}

    log to console  Wait for new counter period
    ${rule}    Catenate
    ...         Distname: MRBTS-37357/NRBTS-37357/NRCELL-1;
    ...         Counter: M55308C00092;
    ...         Counter rule: sum(M55308C00092)>0
    ${rule_list}    Create List    ${rule}
    Counter Operation    operation=start_collect_counter    product_type=vdu
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}
    ...                                                     wait_for_next_counter_generate=${TRUE}

    VoNR_Call_Setup_and_Release  ue_serialno=${ue1_serialno}  call_duration=${call_duration_long}

    log to console  Wait for new counter period
    ${value}    Counter Operation    operation=collect_counter_and_check_rule  product_type=vdu    bts_index=0    cudu_index=0
    log to console  \n${value}

CB008927_CR_R2_Check_Counter_DCI_ALLOC_PDSCH_RAT1_M55365C00011
    [Documentation]
    ...    author: LAA
    [Tags]    QC_7812

    @{vdu_para_list}          Create List    actRat1Alloc    percRedSEDlRat1VoNR
    @{vdu_mo_list}            Create List    MRBTS-37357/NRBTS-37357/NRCELL-1
    ...                                      MRBTS-37357/NRBTS-37357/NRCELL-1
    @{vdu_value_list}             Create List    true    90
    Modify_CB008927_Parameters  para_list=@{vdu_para_list}  mo_list=@{vdu_mo_list}  value_list=@{vdu_value_list}

    log to console  Wait for new counter period
    ${rule}    Catenate
    ...         Distname: MRBTS-37357/NRBTS-37357/NRCELL-1;
    ...         Counter: M55365C00011;
    ...         Counter rule: sum(M55365C00011)>0
    ${rule_list}    Create List    ${rule}
    Counter Operation    operation=start_collect_counter    product_type=vdu
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}
    ...                                                     wait_for_next_counter_generate=${TRUE}

    VoNR_Call_Setup_and_Release  ue_serialno=${ue1_serialno}  call_duration=${call_duration_long}

    log to console  Wait for new counter period
    ${value}    Counter Operation    operation=collect_counter_and_check_rule  product_type=vdu    bts_index=0    cudu_index=0
    log to console  \n${value}


CB008927_CR_R2_Check_Counter_PRB_USED_PDSCH_RAT1_M55308C00093
    [Documentation]
    ...    author: LAA
    [Tags]    QC_7813

    @{vdu_para_list}          Create List    actRat1Alloc    percRedSEDlRat1VoNR
    @{vdu_mo_list}            Create List    MRBTS-37357/NRBTS-37357/NRCELL-1
    ...                                      MRBTS-37357/NRBTS-37357/NRCELL-1
    @{vdu_value_list}             Create List    true    99
    Modify_CB008927_Parameters  para_list=@{vdu_para_list}  mo_list=@{vdu_mo_list}  value_list=@{vdu_value_list}

    log to console  Wait for new counter period
    ${rule}    Catenate
    ...         Distname: MRBTS-37357/NRBTS-37357/NRCELL-1;
    ...         Counter: M55308C00093;
    ...         Counter rule: sum(M55308C00093)>0
    ${rule_list}    Create List    ${rule}
    Counter Operation    operation=start_collect_counter    product_type=vdu
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}
    ...                                                     wait_for_next_counter_generate=${TRUE}

    VoNR_Call_Setup_and_Release  ue_serialno=${ue1_serialno}  call_duration=${call_duration_long}

    log to console  Wait for new counter period
    ${value}    Counter Operation    operation=collect_counter_and_check_rule  product_type=vdu    bts_index=0    cudu_index=0
    log to console  \n${value}

CB008927_CR_R2_Check_Counter_CRT
    [Documentation]
    ...    author: LAA
    [Tags]    QC_

    ${out}    Parameter Operation    operation=full_commission   product_type=vcu
    ...                              scf_path=${CURDIR}/config/SCFC_vCU0_TDD_100MHz.xml
    Log To Console    VCU full commission result: ${out}
    ${out}    Parameter Operation    operation=full_commission   product_type=vdu
    ...                              scf_path=${CURDIR}/config/SCFC_vDU0_TDD_100MHz.xml
    Log To Console    VDU full commission result: ${out}

    @{vdu_para_list}          Create List    actRat1Alloc    percRedSEDlRat1VoNR
    @{vdu_mo_list}            Create List    MRBTS-37357/NRBTS-37357/NRCELL-1
    ...                                      MRBTS-37357/NRBTS-37357/NRCELL-1
    @{vdu_value_list}             Create List    true    50
    Modify_CB008927_Parameters  para_list=@{vdu_para_list}  mo_list=@{vdu_mo_list}  value_list=@{vdu_value_list}

    log to console  Wait for new counter period
    ${rule1}    Catenate
    ...         Distname: MRBTS-37357/NRBTS-37357/NRCELL-1;
    ...         Counter: M55365C00011;
    ...         Counter rule: M55365C00011>0
    ${rule2}    Catenate
    ...         Distname: MRBTS-37357/NRBTS-37357/NRCELL-1;
    ...         Counter: M55308C00092;
    ...         Counter rule: M55308C00092>0
    ${rule3}    Catenate
    ...         Distname: MRBTS-37357/NRBTS-37357/NRCELL-1;
    ...         Counter: M55308C00093;
    ...         Counter rule: M55308C00093>0
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}
    Counter Operation    operation=start_collect_counter    product_type=vdu
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}
    ...                                                     wait_for_next_counter_generate=${TRUE}

    VoNR_Call_Setup_and_Release  ue_serialno=${ue1_serialno}  call_duration=${call_duration_long}

    log to console  Wait for new counter period
    ${value}    Counter Operation    operation=collect_counter_and_check_rule  product_type=vdu    bts_index=0    cudu_index=0
    log to console  \n${value}

*** Keywords ***
Setup_for_CB008927_CR
    Log to Console  \nPA Setting....
    # ${source_pa_port_list}     Create List    15   16
    # ${source_pa_value_list}    Create List    0   0
    # &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}    pa_value=${source_pa_value_list}
    # ...                               step=${1}         pa_type=16*16
    # PA Operation    source=&{source}    target=none

Teardown_for_CB008927_CR
    # Collect vDU syslog
    ${local_file_path}    Log Collection    start    syslog    product_type=vdu    bts_index=${0}    cudu_index=${0}
    Log To Console    \nSyslog of VDU: ${local_file_path}
    # Collect vDU snapshot
    ${local_file_path}    Log Collection    start    snapshot    product_type=vdu    bts_index=${0}    cudu_index=${0}
    Log To Console    \nSnapshot of VDU: ${local_file_path}

    Log to Console  PA Setting....
    # ${source_pa_port_list}     Create List    15   16
    # ${source_pa_value_list}    Create List    120   120
    # &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}    pa_value=${source_pa_value_list}
    # ...                               step=${1}         pa_type=16*16
    # PA Operation    source=&{source}    target=none

VoNR_Call_Setup_and_Release
    [Arguments]    ${ue_serialno}  ${call_duration}=60

    Commercial UE Operation    attach    serialno=${ue_serialno}
    log to console  \nue_${ue_serialno} attached
    Commercial UE Operation    start call    serialno=${ue_serialno}    dial_number=+6688
    log to console  \nvonr call to "6688" for ${call_duration}s
    sleep  ${call_duration}
    Commercial UE Operation    stop call    serialno=${ue_serialno}
    log to console  \nvonr call released
    Commercial UE Operation    detach    serialno=${ue_serialno}
    log to console  \nue_${ue_serialno} detached

Modify_CB008927_Parameters
    [Arguments]  ${para_list}  ${mo_list}  ${value_list}  ${product_type}=vdu

    ${out}    Parameter Operation
    ...    operation=parameter_value_check    product_type=${product_type}
    ...    para_list=@{para_list}    mo_list=@{mo_list}
    Log To Console    \nGNB Parameter Check Result: ${out}

    ${out}    Parameter Operation
    ...    operation=parameter_update    product_type=${product_type}
    ...    para_list=@{para_list}    value_list=@{value_list}    mo_list=@{mo_list}

    ${out}    Parameter Operation
    ...    operation=parameter_value_check    product_type=${product_type}
    ...    para_list=@{para_list}    mo_list=@{mo_list}
    Log To Console    \nGNB Parameter Check Result: ${out}

    BTS Operation    operation=verify    product_type=${product_type}   distname_id=NRCELL-ALL
    ...              verify_status=CELL_ONAIR    timeout=180s