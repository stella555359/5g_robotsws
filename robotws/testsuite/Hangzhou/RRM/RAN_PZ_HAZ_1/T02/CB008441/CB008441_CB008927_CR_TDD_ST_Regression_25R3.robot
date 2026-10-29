*** Settings ***
Documentation
...                 author:  Liu AnAn

Resource    ../../../../resources/RAN_PZ_HAZ_1/Module/Module.robot
Library     ../../../../resources/RAN_PZ_HAZ_1/Module/Commercial_UE_Operation.py

Test Setup          Setup for CB008441_CR
Test Teardown       Teardown for CB008441_CR

Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    CA_RAN_PZ_HAZ_1    RAN_PZ_HAZ1_SG05_ST_RRM    CLOUD_5GC_dRNIC_1vDU_TDD_DC

*** Variables ***
${ue_serialno}    SSXSOZYHZDGAAQ5L
${trf_duration}   300

${bts_id}  37357
${cell_id}  1

*** Test Cases ***
CB008441-CR-A_ST_Case01_Counter_PDCP_Discarted_SDUs_due_to_Delay_Based_Discarding_PI2
    [Documentation]
    ...    author: LAA
    [Tags]    QC_99335

    ${rule1}    Catenate
    ...         Distname: MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${cell_id};
    ...         Counter: M55350C00035;
    ...         Counter rule: sum(M55350C00035)
    ${rule2}    Catenate
    ...         Distname: MRBTS-${bts_id}/NRBTS-${bts_id};
    ...         Counter: M55323C00007;
    ...         Counter rule: sum(M55323C00007)
    ${rule3}    Catenate
    ...         Distname: MRBTS-${bts_id}/NRBTS-${bts_id};
    ...         Counter: M55327C01007;
    ...         Counter rule: sum(M55327C01007)
    ${rule4}    Catenate
    ...         Distname: MRBTS-${bts_id}/NRBTS-${bts_id};
    ...         Counter: M55320C20007,M55320C02007,M55320C04007,M55320C06007,M55320C09007;
    ...         Counter rule: sum(M55320C20007+M55320C02007+M55320C04007+M55320C06007+M55320C09007)
    ${rule5}    Catenate
    ...         Distname: MRBTS-${bts_id}/NRBTS-${bts_id};
    ...         Counter: M55319C12007;
    ...         Counter rule: sum(M55319C12007)
    ${rule6}    Catenate
    ...         Distname: MRBTS-${bts_id}/NRBTS-${bts_id}/MCC-460/MNC-02/SST-1/SD-13714341;
    ...         Counter: M55328C00006;
    ...         Counter rule: sum(M55328C00006)
    ${rule7}    Catenate
    ...         Distname: MRBTS-${bts_id}/NRBTS-${bts_id}/MCC-460/MNC-02/SST-1/SD-13714341;
    ...         Counter: M55328C00002;
    ...         Counter rule: sum(M55328C00002)
    ${rule_list_1}    Create List    ${rule1}    ${rule2}    ${rule3}    ${rule4}
    ...                            ${rule5}    ${rule6}    ${rule7}


    ${rule11}    Catenate
    ...         Distname: MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${cell_id};
    ...         Counter: M55365C00011;
    ...         Counter rule: M55365C00011>0
    ${rule12}    Catenate
    ...         Distname: MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${cell_id};
    ...         Counter: M55308C00092;
    ...         Counter rule: M55308C00092>0
    ${rule13}    Catenate
    ...         Distname: MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${cell_id};
    ...         Counter: M55308C00093;
    ...         Counter rule: M55308C00093>0
    ${rule_list_2}    Create List    ${rule11}    ${rule12}    ${rule13}


    Modify_CB008441_PI2_Default
    Modify_CB008927_EnableRAT1
    log to console  \nWait for New Counter Period
    Counter Operation    operation=start_collect_counter    product_type=vcu
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list_1}
    ...                                                     wait_for_next_counter_generate=${TRUE}

    Counter Operation    operation=start_collect_counter    product_type=vdu
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list_2}
    ...                                                     wait_for_next_counter_generate=${FALSE}

    Commercial UE Operation    attach    serialno=${ue_serialno}   forced=${True}
    log to console  \nUE_${ue_serialno} attached
    Commercial UE Operation  start uc test or sequence  serialno=${ue_serialno}  test_name=iperf3_server_port_5201
    ${ue_ip}=    Commercial UE Operation    get    serialno=${ue_serialno}  item=ueip   work_mode=adb    intf_name=ccmni1
    log to console  \nUE_${ue_serialno} IP is ${ue_ip}
    log to console  \nIPerf3 with UE_${ue_serialno} will last ${trf_duration}s
    ${tcp_command}=  Set Variable  iperf3 -c ${ue_ip} -p 5201 -P5 -i1 -t${trf_duration}
    run process  ${tcp_command}  timeout=${trf_duration}  shell=true  stdout=true  alias=tcp_dl
    # sleep  ${trf_duration}
    ${output}=  get process result  tcp_dl  stdout=true
    log to console  \n${output}
    log to console  \nIPerf3 with UE_${ue_serialno} Completed

    # Wait for Counter Period End
    log to console  \nWait for New Counter Period
    ${result}  Counter Operation  operation=collect_counter_and_calculate
    ...                           product_type=vcu    bts_index=0    cudu_index=0
    log to console  \n${result}
    ${value}   Counter Operation  operation=collect_counter_and_check_rule
    ...                           product_type=vdu    bts_index=0    cudu_index=0
    log to console  \n${value}

    ${pi2_pdcp_discard_num}  Set Variable  ${result}[check_result][${rule1}]
    ${f1u_pdcp_number}  Set Variable  ${result}[check_result][${rule2}]
    ${total_pdcp_sdu_num}  Set Variable  ${result}[check_result][${rule3}]
    ${total_pdcp_discard_num_exclude_pi2}  Set Variable  ${result}[check_result][${rule4}]
    ${total_pdcp_discard_num_include_pi2}  evaluate  ${total_pdcp_discard_num_exclude_pi2}+${pi2_pdcp_discard_num}
    log to console  \nPDCP discard SDU due to PI2: ${pi2_pdcp_discard_num}
    log to console  \nPDCP PDU number sent over F1-U: ${f1u_pdcp_number}
    log to console  \nPDCP SDU number received over NR NG-U DL GTP-U: ${total_pdcp_sdu_num}
    log to console  \nPDCP discard SDU total number excluded pi2: ${total_pdcp_discard_num_exclude_pi2}
    log to console  \nPDCP discard SDU total number included pi2: ${total_pdcp_discard_num_include_pi2}
    ${discard_ratio_exclude_pi2}  evaluate  ${total_pdcp_discard_num_exclude_pi2}/${total_pdcp_sdu_num}*100
    ${discard_ratio_include_pi2}  evaluate  ${total_pdcp_discard_num_include_pi2}/${total_pdcp_sdu_num}*100
    ${throughput}  evaluate  8*${result}[check_result][${rule5}]/${trf_duration}
    ${delay}   evaluate  ${result}[check_result][${rule6}]/${result}[check_result][${rule7}]/1000
    log to console  \nPDCP discard ratio exclude PI2: ${discard_ratio_exclude_pi2}%
    log to console  \nPDCP discard ratio include PI2: ${discard_ratio_include_pi2}%
    log to console  \nPDCP Throughput: ${throughput}kbps
    log to console  \nPDCP Delay: ${delay}ms
    Commercial UE Operation  stop uc test or sequence  serialno=${ue_serialno}  test_name=iperf3_server_port_5201
    Commercial UE Operation    detach    serialno=${ue_serialno}

    Should Be True  ${pi2_pdcp_discard_num}>0
    Run Keyword And Ignore Error
    ...  Should Be True  ${total_pdcp_discard_num_include_pi2}+${f1u_pdcp_number}==${total_pdcp_sdu_num}

*** Keywords ***
Setup_for_CB008441_CR
    Log to Console  \nPA Setting....
    # ${source_pa_port_list}     Create List    40   40
    # ${source_pa_value_list}    Create List    0   0
    # &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}    pa_value=${source_pa_value_list}
    # ...                               step=${1}         pa_type=16*16
    # PA Operation    source=&{source}    target=none

    # ${out}    Parameter Operation    operation=full_commission   product_type=vcu
    # ...                              scf_path=${CURDIR}/APCFG/SCFC_vCU0_tdd_crt_25r2.xml
    # Log To Console    VCU full commission result: ${out}
    # ${out}    Parameter Operation    operation=full_commission   product_type=vdu
    # ...                              scf_path=${CURDIR}/APCFG/SCFC_vDU0_tdd_crt_25r2.xml
    # ...                              timeout=1800
    # Log To Console    VDU full commission result: ${out}

    @{vcu_para_list}      Create List    drbInactivityTimerSA  actServiceAwarePDCPConfig
    ...                                  queuingDelayDiscardStart  miNrPDCPCell
    @{vcu_mo_list}        Create List    MRBTS-${bts_id}/NRBTS-${bts_id}  MRBTS-${bts_id}/NRBTS-${bts_id}
    ...                                  MRBTS-${bts_id}/NRBTS-${bts_id}/NRDRB-7  MRBTS-${bts_id}/NRBTS-${bts_id}/NRPMRNL-1
    @{vcu_value_list}     Create List    3600  true  1  5min
    Modify_CB008441_Parameters  para_list=@{vcu_para_list}  mo_list=@{vcu_mo_list}
    ...                         value_list=@{vcu_value_list}  product_type=vcu

    @{vdu_para_list}      Create List    actServiceAwarePDCPConfig
    @{vdu_mo_list}        Create List    MRBTS-${bts_id}/NRBTS-${bts_id}
    @{vdu_value_list}     Create List    true
    Modify_CB008441_Parameters  para_list=@{vdu_para_list}  mo_list=@{vdu_mo_list}
    ...                         value_list=@{vdu_value_list}  product_type=vdu

Teardown_for_CB008441_CR
    # Collect vCU syslog
    ${local_file_path}  Log Collection  start  syslog  product_type=vcu  bts_index=${0}  cudu_index=${0}
    Log To Console  \nSyslog of VCU: ${local_file_path}
    # Collect vCU snapshot
    ${local_file_path}  Log Collection  start  snapshot  product_type=vcu  bts_index=${0}  cudu_index=${0}
    Log To Console  \nSnapshot of VCU: ${local_file_path}

    # Collect vDU syslog
    ${local_file_path}    Log Collection    start    syslog    product_type=vdu    bts_index=${0}    cudu_index=${0}
    Log To Console    \nSyslog of VDU: ${local_file_path}
    # Collect vDU snapshot
    ${local_file_path}    Log Collection    start    snapshot    product_type=vdu    bts_index=${0}    cudu_index=${0}
    Log To Console    \nSnapshot of VDU: ${local_file_path}

    Log to Console  \nPA Setting....
    # ${source_pa_port_list}     Create List    15   16
    # ${source_pa_value_list}    Create List    120   120
    # &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}    pa_value=${source_pa_value_list}
    # ...                               step=${1}         pa_type=16*16
    # PA Operation    source=&{source}    target=none

Modify_CB008441_Parameters
    [Arguments]    ${product_type}  ${para_list}  ${mo_list}  ${value_list}

    Log To Console  \n Before Online Change
    ${out}    Parameter Operation
    ...    operation=parameter_value_check    product_type=${product_type}
    ...    para_list=@{para_list}    mo_list=@{mo_list}    timeout=${120}
    Log To Console    \nGNB Parameter Check Result: ${out}

    Log To Console  \n After Online Change
    ${out}    Parameter Operation
    ...    operation=parameter_update    product_type=${product_type}
    ...    para_list=@{para_list}    value_list=@{value_list}    mo_list=@{mo_list}    timeout=${180}

    ${out}    Parameter Operation
    ...    operation=parameter_value_check    product_type=${product_type}
    ...    para_list=@{para_list}    mo_list=@{mo_list}    timeout=${120}
    Log To Console    \nGNB Parameter Check Result: ${out}

Modify_CB008441_PI2_Default
    @{para_list}      Create List    queuingDelayDiscarding  pi2TargetDelay
    ...                              pi2TargetSize  discardTimer
    @{mo_list}        Create List    MRBTS-${bts_id}/NRBTS-${bts_id}/NRDRB-7  MRBTS-${bts_id}/NRBTS-${bts_id}/NRDRB-7
    ...                              MRBTS-${bts_id}/NRBTS-${bts_id}/NRDRB-7  MRBTS-${bts_id}/NRBTS-${bts_id}/NRDRB-7
    @{value_list}     Create List    PI2  1200  500  1500ms
    Modify_CB008441_Parameters  product_type=vcu  para_list=@{para_list}
    ...                         mo_list=@{mo_list}  value_list=@{value_list}

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

    Run Keyword And Ignore Error
    ...  BTS Operation    operation=verify    product_type=${product_type}   distname_id=NRCELL-ALL
    ...                   verify_status=CELL_ONAIR    timeout=180s

Modify_CB008927_EnableRAT1
    @{vdu_para_list}          Create List    actRat1Alloc    percRedSEDlRat1VoNR
    @{vdu_mo_list}            Create List    MRBTS-37357/NRBTS-37357/NRCELL-1
    ...                                      MRBTS-37357/NRBTS-37357/NRCELL-1
    @{vdu_value_list}         Create List    true    50
    Modify_CB008927_Parameters  para_list=@{vdu_para_list}  mo_list=@{vdu_mo_list}  value_list=@{vdu_value_list}