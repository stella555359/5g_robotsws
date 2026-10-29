*** Settings ***
Documentation
...                 author:  Liu AnAn

Resource    ../../../../resources/RAN_PZ_HAZ_1/Module/Module.robot

# Test Setup          Setup for CB008927_CR
# Test Teardown       Teardown for CB008927_CR

Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    CA_RAN_PZ_HAZ_1    RAN_PZ_HAZ1_SG05_ST_RRM    CLOUD_5G_CLASSICAL_ANDROID_CA_ASIBL_ABIOB1_AEQN

*** Variables ***
${call_duration_short}   20
${call_duration_long}    300

# ${ue_imsi}    262033031398172
${ue_imsi}    460023100010572

${trf_server_ip}    10.106.200.83
&{dcap_info}    host=10.106.200.83    port=9443    username=${None}    password=${None}

*** Test Cases ***
CB008927_CR_R1_Active_Deactive_actRat1Alloc
    [Documentation]
    ...    author: LAA
    [Tags]    QC_7792

    ${out}    Parameter Operation    operation=full_commission   product_type=vcu
    ...                              scf_path=${CURDIR}/config/SCFC_vCU0_FDD_20MHz.xml
    Log To Console    VCU full commission result: ${out}
    ${out}    Parameter Operation    operation=full_commission   product_type=vdu
    ...                              scf_path=${CURDIR}/config/SCFC_vDU0_FDD_20MHz.xml
    Log To Console    VDU full commission result: ${out}

    # Feature off
    @{vdu_para_list}          Create List    actRat1Alloc    percRedSEDlRat1VoNR
    @{vdu_mo_list}            Create List    MRBTS-37359/NRBTS-37359/NRCELL-1
    ...                                      MRBTS-37359/NRBTS-37359/NRCELL-1
    @{vdu_value_list}         Create List    false    0
    Modify_CB008927_Parameters  para_list=@{vdu_para_list}  mo_list=@{vdu_mo_list}  value_list=@{vdu_value_list}

    # dcap start
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}
    Log Collection    start    tti    product_type=vdu    bts_index=${0}    cudu_index=${0}    dict_argument=${dict_argument}

    VoNR_Call_Setup_and_Release  ue_imsi=${ue_imsi}  call_duration=${call_duration_short}

    # dcap stop
    ${local_file_path}    Log Collection    stop_and_download    tti    product_type=vdu    bts_index=${0}    cudu_index=${0}
    Log To Console    \nTTI log of VDU: ${local_file_path}

    # Feature on
    @{vdu_para_list}          Create List    actRat1Alloc    percRedSEDlRat1VoNR
    @{vdu_mo_list}            Create List    MRBTS-37359/NRBTS-37359/NRCELL-1
    ...                                      MRBTS-37359/NRBTS-37359/NRCELL-1
    @{vdu_value_list}             Create List    true    0
    Modify_CB008927_Parameters  para_list=@{vdu_para_list}  mo_list=@{vdu_mo_list}  value_list=@{vdu_value_list}

    # dcap start
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}
    Log Collection    start    tti    product_type=vdu    bts_index=${0}    cudu_index=${0}    dict_argument=${dict_argument}

    VoNR_Call_Setup_and_Release  ue_imsi=${ue_imsi}  call_duration=${call_duration_short}

    # dcap stop
    ${local_file_path}    Log Collection    stop_and_download    tti    product_type=vdu    bts_index=${0}    cudu_index=${0}
    Log To Console    \nTTI log of VDU: ${local_file_path}


CB008927_CR_R1_Active_Deactive_percRedSEDlRat1VoNR
    [Documentation]
    ...    author: LAA
    [Tags]    QC_7793

    ${out}    Parameter Operation    operation=full_commission   product_type=vcu
    ...                              scf_path=${CURDIR}/config/SCFC_vCU0_FDD_15MHz.xml
    Log To Console    VCU full commission result: ${out}
    ${out}    Parameter Operation    operation=full_commission   product_type=vdu
    ...                              scf_path=${CURDIR}/config/SCFC_vDU0_FDD_15MHz.xml
    Log To Console    VDU full commission result: ${out}

    # Feature off
    @{vdu_para_list}          Create List    actRat1Alloc    percRedSEDlRat1VoNR
    @{vdu_mo_list}            Create List    MRBTS-37359/NRBTS-37359/NRCELL-1
    ...                                      MRBTS-37359/NRBTS-37359/NRCELL-1
    @{vdu_value_list}         Create List    false    0
    Modify_CB008927_Parameters  para_list=@{vdu_para_list}  mo_list=@{vdu_mo_list}  value_list=@{vdu_value_list}

    # dcap start
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}
    Log Collection    start    tti    product_type=vdu    bts_index=${0}    cudu_index=${0}    dict_argument=${dict_argument}

    VoNR_Call_Setup_and_Release  ue_imsi=${ue_imsi}  call_duration=${call_duration_short}

    # dcap stop
    ${local_file_path}    Log Collection    stop_and_download    tti    product_type=vdu    bts_index=${0}    cudu_index=${0}
    Log To Console    \nTTI log of VDU: ${local_file_path}

    # Feature on
    @{vdu_para_list}          Create List    actRat1Alloc    percRedSEDlRat1VoNR
    @{vdu_mo_list}            Create List    MRBTS-37359/NRBTS-37359/NRCELL-1
    ...                                      MRBTS-37359/NRBTS-37359/NRCELL-1
    @{vdu_value_list}         Create List    true  95
    Modify_CB008927_Parameters  para_list=@{vdu_para_list}  mo_list=@{vdu_mo_list}  value_list=@{vdu_value_list}

    # dcap start
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}
    Log Collection    start    tti    product_type=vdu    bts_index=${0}    cudu_index=${0}    dict_argument=${dict_argument}

    VoNR_Call_Setup_and_Release  ue_imsi=${ue_imsi}  call_duration=${call_duration_short}

    # dcap stop
    ${local_file_path}    Log Collection    stop_and_download    tti    product_type=vdu    bts_index=${0}    cudu_index=${0}
    Log To Console    \nTTI log of VDU: ${local_file_path}

CB008927_CR_R1_Active_Deactive_actDlDynSwitchAlloc
    [Documentation]
    ...    author: LAA
    [Tags]    QC_7794

    ${out}    Parameter Operation    operation=full_commission   product_type=vcu
    ...                              scf_path=${CURDIR}/config/SCFC_vCU0_FDD_10MHz.xml
    Log To Console    VCU full commission result: ${out}
    ${out}    Parameter Operation    operation=full_commission   product_type=vdu
    ...                              scf_path=${CURDIR}/config/SCFC_vDU0_FDD_10MHz.xml
    Log To Console    VDU full commission result: ${out}

    # Feature off
    @{vdu_para_list}          Create List    actRat1Alloc    actDlDynSwitchAlloc
    @{vdu_mo_list}            Create List    MRBTS-37359/NRBTS-37359/NRCELL-1
    ...                                      MRBTS-37359/NRBTS-37359/NRCELL-1
    @{vdu_value_list}         Create List    false    false
    Modify_CB008927_Parameters  para_list=@{vdu_para_list}  mo_list=@{vdu_mo_list}  value_list=@{vdu_value_list}

    # dcap start
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}
    Log Collection    start    tti    product_type=vdu    bts_index=${0}    cudu_index=${0}    dict_argument=${dict_argument}

    VoNR_Call_Setup_and_Release  ue_imsi=${ue_imsi}  call_duration=${call_duration_short}

    # dcap stop
    ${local_file_path}    Log Collection    stop_and_download    tti    product_type=vdu    bts_index=${0}    cudu_index=${0}
    Log To Console    \nTTI log of VDU: ${local_file_path}

    # Feature on
    @{vdu_para_list}          Create List    actRat1Alloc    actDlDynSwitchAlloc
    @{vdu_mo_list}            Create List    MRBTS-37359/NRBTS-37359/NRCELL-1
    ...                                      MRBTS-37359/NRBTS-37359/NRCELL-1
    @{vdu_value_list}         Create List    true    true
    Modify_CB008927_Parameters  para_list=@{vdu_para_list}  mo_list=@{vdu_mo_list}  value_list=@{vdu_value_list}

    # dcap start
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}
    Log Collection    start    tti    product_type=vdu    bts_index=${0}    cudu_index=${0}    dict_argument=${dict_argument}

    VoNR_Call_Setup_and_Release  ue_imsi=${ue_imsi}  call_duration=${call_duration_short}

    # dcap stop
    ${local_file_path}    Log Collection    stop_and_download    tti    product_type=vdu    bts_index=${0}    cudu_index=${0}
    Log To Console    \nTTI log of VDU: ${local_file_path}

CB008927_CR_R1_Support_VoNR_call_with_single_BWP
    [Documentation]
    ...    author: LAA
    [Tags]    QC_7795

    ${out}    Parameter Operation    operation=full_commission   product_type=vcu
    ...                              scf_path=${CURDIR}/config/SCFC_vCU0_FDD_15MHz.xml
    Log To Console    VCU full commission result: ${out}
    ${out}    Parameter Operation    operation=full_commission   product_type=vdu
    ...                              scf_path=${CURDIR}/config/SCFC_vDU0_FDD_15MHz.xml
    Log To Console    VDU full commission result: ${out}

    # Feature on
    @{vdu_para_list}          Create List    actRat1Alloc    percRedSEDlRat1VoNR
    @{vdu_mo_list}            Create List    MRBTS-37359/NRBTS-37359/NRCELL-1
    ...                                      MRBTS-37359/NRBTS-37359/NRCELL-1
    @{vdu_value_list}         Create List    true    25
    Modify_CB008927_Parameters  para_list=@{vdu_para_list}  mo_list=@{vdu_mo_list}  value_list=@{vdu_value_list}

    # dcap start
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}
    Log Collection    start    tti    product_type=vdu    bts_index=${0}    cudu_index=${0}    dict_argument=${dict_argument}

    VoNR_Call_Setup_and_Release  ue_imsi=${ue_imsi}  call_duration=${call_duration_long}

    # dcap stop
    ${local_file_path}    Log Collection    stop_and_download    tti    product_type=vdu    bts_index=${0}    cudu_index=${0}
    Log To Console    \nTTI log of VDU: ${local_file_path}

CB008927_CR_R1_Check_Counter_MAX_ALLOC_PRB_PDSCH_RAT1_M55308C00092
    [Documentation]
    ...    author: LAA
    [Tags]    QC_7800

    ${out}    Parameter Operation    operation=full_commission   product_type=vcu
    ...                              scf_path=${CURDIR}/config/SCFC_vCU0_FDD_15MHz.xml
    Log To Console    VCU full commission result: ${out}
    ${out}    Parameter Operation    operation=full_commission   product_type=vdu
    ...                              scf_path=${CURDIR}/config/SCFC_vDU0_FDD_15MHz.xml
    Log To Console    VDU full commission result: ${out}

    @{vdu_para_list}          Create List    actRat1Alloc    percRedSEDlRat1VoNR
    @{vdu_mo_list}            Create List    MRBTS-37359/NRBTS-37359/NRCELL-1
    ...                                      MRBTS-37359/NRBTS-37359/NRCELL-1
    @{vdu_value_list}         Create List    true    50
    Modify_CB008927_Parameters  para_list=@{vdu_para_list}  mo_list=@{vdu_mo_list}  value_list=@{vdu_value_list}

    ${rule}    Catenate
    ...         Distname: MRBTS-37359/NRBTS-37359/NRCELL-1;
    ...         Counter: M55308C00092;
    ...         Counter rule: M55308C00092>0
    ${rule_list}    Create List    ${rule}
    log to console  Wait for new period counter generated
    Counter Operation    operation=start_collect_counter    product_type=vdu
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}
    ...                                                     wait_for_next_counter_generate=${TRUE}

    VoNR_Call_Setup_and_Release  ue_imsi=${ue_imsi}  call_duration=${call_duration_long}
    log to console  Wait for new period counter generated
    ${value}    Counter Operation    operation=collect_counter_and_check_rule  product_type=vdu    bts_index=0    cudu_index=0
    log to console  \n${value}

CB008927_CR_R1_Check_Counter_DCI_ALLOC_PDSCH_RAT1_M55365C00011
    [Documentation]
    ...    author: LAA
    [Tags]    QC_7801

    ${out}    Parameter Operation    operation=full_commission   product_type=vcu
    ...                              scf_path=${CURDIR}/config/SCFC_vCU0_FDD_20MHz.xml
    Log To Console    VCU full commission result: ${out}
    ${out}    Parameter Operation    operation=full_commission   product_type=vdu
    ...                              scf_path=${CURDIR}/config/SCFC_vDU0_FDD_20MHz.xml
    Log To Console    VDU full commission result: ${out}

    @{vdu_para_list}          Create List    actRat1Alloc    percRedSEDlRat1VoNR
    @{vdu_mo_list}            Create List    MRBTS-37359/NRBTS-37359/NRCELL-1
    ...                                      MRBTS-37359/NRBTS-37359/NRCELL-1
    @{vdu_value_list}         Create List    true    90
    Modify_CB008927_Parameters  para_list=@{vdu_para_list}  mo_list=@{vdu_mo_list}  value_list=@{vdu_value_list}

    ${rule}    Catenate
    ...         Distname: MRBTS-37359/NRBTS-37359/NRCELL-1;
    ...         Counter: M55365C00011;
    ...         Counter rule: M55365C00011>0
    ${rule_list}    Create List    ${rule}
    log to console  Wait for new period counter generated
    Counter Operation    operation=start_collect_counter    product_type=vdu
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}
    ...                                                     wait_for_next_counter_generate=${TRUE}

    VoNR_Call_Setup_and_Release  ue_imsi=${ue_imsi}  call_duration=${call_duration_long}

    log to console  Wait for new period counter generated
    ${value}    Counter Operation    operation=collect_counter_and_check_rule  product_type=vdu    bts_index=0    cudu_index=0
    log to console  \n${value}


CB008927_CR_R1_Check_Counter_PRB_USED_PDSCH_RAT1_M55308C00093
    [Documentation]
    ...    author: LAA
    [Tags]    QC_7802

    ${out}    Parameter Operation    operation=full_commission   product_type=vcu
    ...                              scf_path=${CURDIR}/config/SCFC_vCU0_FDD_10MHz.xml
    Log To Console    VCU full commission result: ${out}
    ${out}    Parameter Operation    operation=full_commission   product_type=vdu
    ...                              scf_path=${CURDIR}/config/SCFC_vDU0_FDD_10MHz.xml
    Log To Console    VDU full commission result: ${out}

    @{vdu_para_list}          Create List    actRat1Alloc    percRedSEDlRat1VoNR
    @{vdu_mo_list}            Create List    MRBTS-37359/NRBTS-37359/NRCELL-1
    ...                                      MRBTS-37359/NRBTS-37359/NRCELL-1
    @{vdu_value_list}         Create List    true    99
    Modify_CB008927_Parameters  para_list=@{vdu_para_list}  mo_list=@{vdu_mo_list}  value_list=@{vdu_value_list}

    ${rule}    Catenate
    ...         Distname: MRBTS-37359/NRBTS-37359/NRCELL-1;
    ...         Counter: M55308C00093;
    ...         Counter rule: M55308C00093>0
    ${rule_list}    Create List    ${rule}
    log to console  Wait for new period counter generated
    Counter Operation    operation=start_collect_counter    product_type=vdu
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}
    ...                                                     wait_for_next_counter_generate=${TRUE}

    VoNR_Call_Setup_and_Release  ue_imsi=${ue_imsi}  call_duration=${call_duration_long}

    log to console  Wait for new period counter generated
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

    # Log to Console  PA Setting....
    # ${source_pa_port_list}     Create List    15   16
    # ${source_pa_value_list}    Create List    120   120
    # &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}    pa_value=${source_pa_value_list}
    # ...                               step=${1}         pa_type=16*16
    # PA Operation    source=&{source}    target=none

VoNR_Call_Setup_and_Release
    [Arguments]    ${ue_imsi}  ${call_duration}=60

    Traffic Uebox Operation    attach    ue_imsi=${ue_imsi}
    log to console  \nue_${ue_imsi} attached
    Traffic Uebox Operation    start voice call    ue_imsi=${ue_imsi}    number=6688
    log to console  \nvonr call to "6688" for ${call_duration}s
    sleep  ${call_duration}
    Traffic Uebox Operation    stop voice call    ue_imsi=${ue_imsi}
    log to console  \nvonr call released
    Traffic Uebox Operation    detach    ue_imsi=${ue_imsi}
    log to console  \nue_${ue_imsi} detached

Data_Traffic_Setup_and_Release
    [Arguments]    ${ue_imsi}  ${call_duration}=60

    Traffic Uebox Operation    attach    ue_imsi=${ue_imsi}
    log to console  \nue_${ue_imsi} attached
    Traffic Uebox Operation    start dl traffic  ue_imsi=${ue_imsi}
    ...                        remote_hostname=${trf_server_ip}  remote_username=ute  remote_password=uteUTE!
    ...                        options=-u -b 30M -t ${call_duration} -i 1 -p 50001
    Traffic Uebox Operation    stop dl traffic  ue_imsi=${ue_imsi}
    ...                        remote_hostname=${trf_server_ip}  remote_username=ute  remote_password=uteUTE!
    log to console  \ndl/ul data traffic call for ${call_duration}s
    sleep  ${call_duration}
    Traffic Uebox Operation    stop dl traffic  ue_imsi=${ue_imsi}
    ...                        remote_hostname=${trf_server_ip}  remote_username=ute  remote_password=uteUTE!
    Traffic Uebox Operation    stop ul traffic  ue_imsi=${ue_imsi}
    log to console  \ndl/ul data traffic call released
    Traffic Uebox Operation    detach    ue_imsi=${ue_imsi}
    log to console  \nue_${ue_imsi} detached

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