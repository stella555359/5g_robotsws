*** Settings ***
Documentation
...    Author: sudi Lou
...    Contact: sudi.lou@nokia-sbell.com
...    this file is module case template,you can create your test case according to this template.
...    Please do not modify the file without notification to author

Suite Setup    Run keywords    Common Suite Setup For AIC
...            AND    Config network For Local Env_250
Suite Teardown    Run keywords     Custom Suite Teardown For AIC

Force Tags
...      CRT             #Tag Item
...      VRF_HAZ1             #Competence Area
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout    600 minutes

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
Resource          ../../T02/Common_Case/common_resource_new.robot
Resource          ../CB015045/Resource_CB015045.robot

*** Variables ***
${SA_UE_ID}    1
${NSA_UE_ID}    31
${counter_rule_folder}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/TL_Airphone_AIC
${delta_file}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/TL_Airphone_AIC/CB007292-B_B3_delta.json
${wait_time}    300
${log_type}    syslog+emil
@{maxPLMN}
...    NRCELL:actEmergencyCallExtensions=true
...    NRBTS-1/NREMERGARP_PROFILE-1:emergArpList=1,8

*** Test Cases ***
Upgrade_airphone_and_wts_build
    [Tags]    upgrade_airphone
    Config Iphy Ip For Local Env_250
    [Teardown]    Case Postcondition For AP

CB007292-B_B3_Successful_Emergency_call_intra_gNB_RRC_reestablishment_with_multiple_Emergency_ARP_values
    [Documentation]
    ...    1. The purpose of this test case is:
    ...         This case will cover Successful Emergency call
    ...    intra-gNB RRC re-establishment with multiple Emergency ARP values.
    ...    2. Test Case Steps:
    ...         a. UE1 setup emergenct call with 5QI5 , with emergency ARP2
    ...         and 5QI1, with emergency ARP1
    ...         b. trigger reestablish to neighbor cell
    ...    3. Expected Results:
    ...         Step a: EC call with PDU setup successfully
    ...         setp b: EC call reestablish to neighbor cell
    ...         check counters on CU and DU
    [Tags]    RRE
    [Setup]    Case Precondition
    Parameter Updated In vDU and vCU for CB007292    rrcReestabTypeSA=sameGNB
    Execute Egate Command    cmd=smf_param id=1 reset
    Execute Egate Command    cmd=qosflow_modify qos_flow=1 priority=7 default=on
    Execute Egate Command    cmd=qosflow_modify qos_flow=3 priority=7
    Counter Operation    operation=start_collect_counter
    ...                  product_type=vcu
    ...                  bts_index=0
    ...                  counter_rule=${counter_rule_folder}/CB007292-B_B3_counter_check.txt

    ${result}    Counter Operation    operation=collect_counter    product_type=vcu    bts_index=0    cudu_index=0
    Log To Console    \nCounter Rule Collect Result is: ${result}
    start_log_collection    log_type=${log_type}    product_type=vcu
#    Log Collection    start    wireshark_cp    product_type=vcu    bts_index=${0}    cudu_index=${0}
    Execute Egate Command    cmd=ue_location_change id=${SA_UE_ID} enb=2 cell=1
    Execute Egate Command    cmd=ue_register id=${SA_UE_ID}    pass_regexp=UE now in NG RM Registered
    Trigger UE MO VoNR Call With PDU Modify     ue_id=1    pdu_id=1    gw=1    request_type=initial-request
    Execute Egate Command    cmd=qosflow_modify qos_flow=1 priority=8 default=on
    Execute Egate Command    cmd=qosflow_modify qos_flow=3 priority=1
    Execute Egate Command    cmd=set_pdu_param ue=1 pdu=2 trf_type=internal
    Trigger UE MO VoNR Call With PDU Modify     ue_id=1    pdu_id=2    gw=2    request_type=initial-emergency-request
    Send NonGBR Throughput    ue_id=${SA_UE_ID}     pdu_id=1    qfi_id=1
    Send GBR Throughput    ue_id=${SA_UE_ID}     pdu_id=1    qfi_id=2
    Send NonGBR Throughput    ue_id=${SA_UE_ID}     pdu_id=2    qfi_id=1
    Send GBR Throughput    ue_id=${SA_UE_ID}     pdu_id=2    qfi_id=2
    sleep    5s
    ${max_tput}    ${ave_tput}    ${min_tput}    Module AP Get Average Throughput    ue_id=${SA_UE_ID}
    ...                                                  qfi=1    dir=dlul    trf_id=1    type=l3
    ...                                                  call_type=SA    pdu_id=1
    sleep    5s
    ${max_tput}    ${ave_tput}    ${min_tput}    Module AP Get Average Throughput    ue_id=${SA_UE_ID}
    ...                                                  qfi=2    dir=dlul    trf_id=1    type=l3
    ...                                                  call_type=SA    pdu_id=1
    sleep    5s
    ${max_tput}    ${ave_tput}    ${min_tput}    Module AP Get Average Throughput    ue_id=${SA_UE_ID}
    ...                                                  qfi=1    dir=dlul    trf_id=1    type=l3
    ...                                                  call_type=SA    pdu_id=2
    sleep    5s
    ${max_tput}    ${ave_tput}    ${min_tput}    Module AP Get Average Throughput    ue_id=${SA_UE_ID}
    ...                                                  qfi=2    dir=dlul    trf_id=1    type=l3
    ...                                                  call_type=SA    pdu_id=2
    Execute Egate Command    cmd=ue_rrc_reestablish id=1 gnb=2 cell=2 cause=reconfigurationFailure
    sleep    5s
    ${max_tput}    ${ave_tput}    ${min_tput}    Module AP Get Average Throughput    ue_id=${SA_UE_ID}
    ...                                                  qfi=1    dir=dlul    trf_id=1    type=l3
    ...                                                  call_type=SA    pdu_id=1
    sleep    5s
    ${max_tput}    ${ave_tput}    ${min_tput}    Module AP Get Average Throughput    ue_id=${SA_UE_ID}
    ...                                                  qfi=2    dir=dlul    trf_id=1    type=l3
    ...                                                  call_type=SA    pdu_id=1
    sleep    5s
    ${max_tput}    ${ave_tput}    ${min_tput}    Module AP Get Average Throughput    ue_id=${SA_UE_ID}
    ...                                                  qfi=1    dir=dlul    trf_id=1    type=l3
    ...                                                  call_type=SA    pdu_id=2
    sleep    5s
    ${max_tput}    ${ave_tput}    ${min_tput}    Module AP Get Average Throughput    ue_id=${SA_UE_ID}
    ...                                                  qfi=2    dir=dlul    trf_id=1    type=l3
    ...                                                  call_type=SA    pdu_id=2
    Execute Egate Command    cmd=ue_deregister id=1 ue_deregister_type=switch_off by=ue
    ${local_file_path}  Log Collection  stop_and_download  ${log_type}  product_type=vcu  bts_index=${0}
#    ${local_file_path}    Log Collection    stop_and_download    wireshark_cp    product_type=vcu    bts_index=${0}    cudu_index=${0}
#    Log To Console    \nWireshark log of VCU: ${local_file_path}
    Sleep     300s
    ${result}    Counter Operation    operation=collect_counter_and_check_rule    product_type=vcu    bts_index=0    cudu_index=0
    Log To Console    \nCounter Rule Collect and Check Result is: ${result}
    [Teardown]    Case Postcondition

CB011169_01_CNI-79164_01_NSA_Preventing_PSCELL_change_loop_due_to_RLF
    [Documentation]
    ...    Verify Cloud NSA TDD cmWave Intra-freq
    [Tags]    CRT   CB011169    QC_32520    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Case Precondition
    Start Counter For CB011169
    X2 Link for external gNB
    UE attach and traffic    local_cell_id=1
    Trigger UE Iniated RLF for Pscell Change    failure_type=T310_expiry
    ...    meas=05936D40864A0A0866A2D0
    Execute Egate Command    cmd=ue_detach id=31    pass_regexp=UE IS OFF
    sleep    12s
    UE attach and traffic    local_cell_id=1
    Trigger UE Iniated RLF for Pscell Release    failure_type=T310_expiry
    ...    meas=05936D40864A0A0866A190
    Execute Egate Command    cmd=ue_detach id=31    pass_regexp=UE IS OFF
    sleep    12s
    UE attach and traffic    local_cell_id=1
    Trigger UE Iniated RLF for Pscell Release    failure_type=random_access_problem
    ...    meas=05936D40864A190866A370
    Execute Egate Command    cmd=ue_detach id=31    pass_regexp=UE IS OFF
    UE attach and traffic    local_cell_id=1
    Trigger UE Iniated RLF for Pscell Change    failure_type=rlc_max_num_retx
    ...    meas=05936D40864A190866A370
    Execute Egate Command    cmd=ue_detach id=31    pass_regexp=UE IS OFF
    UE attach and traffic    local_cell_id=1
    Trigger UE Iniated RLF for Pscell Change    failure_type=synch_reconfiguration_failure_scg
    ...    meas=05936D40864A190866A370
    Execute Egate Command    cmd=ue_detach id=31    pass_regexp=UE IS OFF
    UE attach and traffic    local_cell_id=1
    Trigger UE Iniated RLF for Pscell Change    failure_type=scg_reconfig_failure
    ...    meas=05936D40864A190866A370
    Execute Egate Command    cmd=ue_detach id=31    pass_regexp=UE IS OFF
    UE attach and traffic    local_cell_id=1
    Trigger UE Iniated RLF for Pscell Change    failure_type=srb3_integrity_failure
    ...    meas=05936D40864A190866A370
    Execute Egate Command    cmd=ue_detach id=31    pass_regexp=UE IS OFF
    Sleep     300s
    ${result}    Counter Operation    operation=collect_counter_and_check_rule    product_type=vcu    bts_index=0    cudu_index=0
    [Teardown]    Case Postcondition

TC03_CB012277_A_B2_Inter_Frequency_inter_en_gNB_PSCell_change_with_CGI_provisioning_without_ANR_for_NSA_Opt_3x
    [Documentation]
    ...    Verify Cloud NSA TDD cmWave Intra-freq inter-gNB handover  is successful
    [Tags]    QC_32519    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Case CB012277 Precondition
    Collect Wireshark Log    log_type=wireshark_cp    product_type=vcu    bts_index=${0}
    X2 Link for external gNB
    X2 Link for simulated gNB-35
    UE attach and traffic    local_cell_id=1
    UE Tigger Inter-gnb HO From RealGNB to SimGNB    phycell_id=384
    ${wireshark_cp_log_path}    Stop And Download Wireshark Log    log_type=wireshark_cp    product_type=vcu    bts_index=${0}
    Check Wireshark Log For CB012277    ${wireshark_cp_log_path}
    [Teardown]     Case CB012277 Postcondition

*** Keywords ***
Case Precondition
    Case Precondition For AP    tag=${none}    product_type=vdu    operation=env_setup_sa
    Common Test Setup For AIC

Case CB012277 Precondition
    Case Precondition For AP    tag=CB012277    product_type=vdu    operation=env_setup_sa
    Common Test Setup For AIC

Case Postcondition
    ${local_file_path}    Run Keyword And Ignore Error  Log Collection  stop_and_download  ${log_type}  product_type=vcu
      ...    bts_index=${0}
    Execute Egate Command    cmd=ue_deregister id=1 ue_deregister_type=switch_off by=ue
    Case Postcondition For AP
    Common Test Teardown For AIC
    Log To Console  \n===Case Postcondition ===

Case CB012277 Postcondition
    Execute Egate Command    cmd=ue_deregister id=1 ue_deregister_type=switch_off by=ue
    Run Keyword And Ignore Error    Stop And Download Wireshark Log    log_type=wireshark_cp    product_type=vcu    bts_index=${0}
    Case Postcondition For AP
    Common Test Teardown For AIC
    Log To Console  \n===Case Postcondition ===

Custom Suite Teardown For AIC
    Common Suite Teardown For AIC
    ${cmd}=    Set Variable    find ${SUITE_LOG_DIRECTORY} -type f -size +50M ! -name "*.xml" ! -name "*.html"
    ${result}    Run Process    ${cmd}    shell=True
    log to console    ${result.stdout}

    ${cmd_new}=    Set Variable    ${cmd} -exec rm -f {} \\;
    ${result}    Run Process    ${cmd_new}    shell=True
    log to console    ${result.stdout}
    log to console    ${result.stderr}
    log to console    ${result.rc}

Parameter Updated In vDU and vCU for CB007292
    [Arguments]   ${rrcReestabTypeSA}=sameGNB
    @{para_list}          Create List    rrcReestabTypeSA
    @{mo_list}        Create List    MRBTS-11073/NRBTS-11073
    @{value_list_true}    Create List    ${rrcReestabTypeSA}
    ${out}                Parameter Operation    operation=parameter_update    product_type=vdu
    ...                                          para_list=@{para_list}    value_list=@{value_list_true}    mo_list=@{mo_list}
    ${out}                Parameter Operation    operation=parameter_update    product_type=vcu
    ...                                          para_list=@{para_list}    value_list=@{value_list_true}    mo_list=@{mo_list}

    ${out}            Parameter Operation    operation=delta_plan_update   product_type=vdu
    ...                                      delta_file_path=${delta_file}
    ${out}            Parameter Operation    operation=delta_plan_update   product_type=vcu
    ...                                      delta_file_path=${delta_file}

Trigger UE MO VoNR Call With PDU Modify
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${fiveQI}=5    ${nwslice}=1    ${gw}=1    ${request_type}=initial-request
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    ${ret1}=    Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw} nwslice=${nwslice} request_type=${request_type}
    ...    pass_regexp=QoS Routing Table
    #Should Contain    ${ret1}    securityModeCommand
    #Should Contain    ${ret1}    Initial Context Setup Successful for UE with AMF UE
    Should Contain    ${ret1}    Setup QosFlow with QFI:1 5QI:${fiveQI}
    ${ret1}=    Execute Egate Command    cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=3 by=amf
    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]* handled successfully

Send NonGBR Throughput
    [Arguments]    ${ue_id}=${SA_UE_ID}    ${pdu_id}=1    ${qfi_id}=1
    Execute Egate Command    cmd=data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl trf_id=1 protocol=udp mbps=5
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    cmd=data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul trf_id=2 protocol=udp mbps=5
    ...    pass_regexp=UE ${ue_id}: UDP UL

Send GBR Throughput
    [Arguments]    ${ue_id}=${SA_UE_ID}    ${pdu_id}=1    ${qfi_id}=1
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=${pdu_id} qfi=${qfi_id} dir=dl trf_id=3 protocol=tcp mbps=2 seconds=600
    ...    pass_regexp=UE ${ue_id}: TCP DL
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=${pdu_id} qfi=${qfi_id} dir=ul trf_id=4 protocol=tcp mbps=2 seconds=600
    ...    pass_regexp=UE ${ue_id}: TCP UL

UE tigger Inter-gnb HO From RealGNB to SimGNB
    [Arguments]    ${phycell_id}    ${ue_id}=31
    Execute Egate Command    cmd=ue_enb_param id=${ue_id} measurement_gap=gp0:2 gap_trigger=gnb_triggered
    ${a2_meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=636576    event_type=A2
    ${ret1}=    Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${a2_meas_id} event=A2 srsrp_nr=30 srsrq_nr=30
    ...    pass_regexp=rrcReconfigurationComplete
    Execute Egate Command    cmd=ue_enb_param id=${ue_id} measurement_gap=off
    ${a5_meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=2071387    event_type=A5
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${a5_meas_id} event=A5 srsrp_nr=1 srsrq_nr=1
    ...    phycell_id=${phycell_id} nrsrp_nr=60 nrsrq_nr=60
    Execute Egate Command    ${cmd}    pass_regexp=Bearer-type change from MCG to SCG-split is successful

X2 Link for simulated gNB-35
    Execute Egate Command    cmd=enb_x2_link_up enb=1 target=3
    ...    pass_regexp=X2AP Link with GNB-3

X2 Link for external gNB
    Execute Egate Command    cmd=enb_x2_link_up enb=1 target=2
    ...    pass_regexp=X2AP Link with GNB-2

Trigger UE Iniated RLF for Pscell Change
    [Arguments]    ${ue_id}=31    ${failure_type}=T310_expiry    ${at}=gnb    ${meas}=0583D6E4864A190866A370
    Trigger RLF    ue_id=${ue_id}    failure_type=${failure_type}    at=${at}    meas=${meas}
    ...   pass_regexp=ENB-1: UE${ue_id}: Dispatch ScgFailureInformationNR_r15 Message

Trigger UE Iniated RLF for Pscell Release
    [Arguments]    ${ue_id}=31    ${failure_type}=T310_expiry    ${at}=gnb    ${meas}=0583D6E4864A190866A370
    Trigger RLF    ue_id=${ue_id}    failure_type=${failure_type}    at=${at}    meas=${meas}
    ...   pass_regexp=Bearer-type change from SCG-split to MCG is successful

Trigger RLF
    [Arguments]    ${ue_id}    ${failure_type}    ${at}    ${meas}
    ...            ${pass_regexp}
    ${V_1}    catenate
    ...    ue_dc_rlf ue=${ue_id} failure_type=${failure_type} at=${at} meas_result_scg=${meas}
    Execute Egate Command    cmd=${V_1}    pass_regexp=${pass_regexp}
    Sleep    1s    reason=wait command to be executed

UE attach and traffic
    [Arguments]    ${local_cell_id}
    Execute Egate Command    cmd=ue_attach id=${NSA_UE_ID}    pass_regexp=UE IS ACTIVE
    Execute Egate Command    cmd=ue_dc_enb_start ue=${NSA_UE_ID} target_gnb=2 target_cells=${local_cell_id} bearer=2 type=split_scg
    ...    pass_regexp=reported successful RA
    Send Throughput
#    Verify Throughput

UE tigger PScell Change To Specific Cell
    [Arguments]    ${phycell_id}    ${ue_id}=31
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${ret1}=     Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id}
    ...    nrsrp_nr=30 nrsrq_nr=30
    ...    pass_regexp=UE${ue_id}: Sending SgNB Modification Confirm

Send Throughput
    Execute Egate Command    cmd=data_trf_start ue=${NSA_UE_ID} id=2 dir=ul mbps=5 trf_id=1    pass_regexp=UDP UL
    Execute Egate Command    cmd=data_trf_start ue=${NSA_UE_ID} id=2 dir=dl mbps=5 trf_id=2    pass_regexp=UDP DL

Verify Throughput
    [Arguments]    ${sleep_time}=10s
    sleep    ${sleep_time}
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${NSA_UE_ID}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>4.5
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=${NSA_UE_ID}    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_throuput}/1000>4.5

Start Counter For CB011169
    ${MRBTS_ID}    Set Variable   ${MRBTS_ID_list}[0]
    ${dim_dn_base}    Set Variable   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}

    ${RLF_INITIATED_UE_PSCELL_CHANGE}    Catenate    Distname: ${dim_dn_base}/NRCELL-2; Counter: M55116C00007; Counter rule: sum(M55116C00007)>=5;
    ${RLF_INITIATED_UE_T310_EXPIRY}    Catenate    Distname: ${dim_dn_base}/NRCELL-1; Counter: M55116C00008; Counter rule: sum(M55116C00008)>=1;
    ${RLF_INITIATED_UE_RACH_FAIL}    Catenate    Distname: ${dim_dn_base}/NRCELL-1; Counter: M55116C00009; Counter rule: sum(M55116C00009)>=1;
    ${RLF_INIT_SGNB_MAX_RLC_RETX}    Catenate    Distname: ${dim_dn_base}/NRCELL-1; Counter: M55116C00015; Counter rule: sum(M55116C00015)==0;
    ${RLF_INITIATED_UE_SCG_RECNF_F}    Catenate    Distname: ${dim_dn_base}/NRCELL-1; Counter: M55116C00013; Counter rule: sum(M55116C00013)==0;
    ${RLF_INITIATED_UE_SCG_CHGE_FAIL}    Catenate    Distname: ${dim_dn_base}/NRCELL-1; Counter: M55116C00012; Counter rule: sum(M55116C00012)==0;
    ${RLF_INITIATED_UE_SRB_INTGRTY_F}    Catenate    Distname: ${dim_dn_base}/NRCELL-1; Counter: M55116C00011; Counter rule: sum(M55116C00011)==0;

    ${rule_list}    Create List    ${RLF_INITIATED_UE_PSCELL_CHANGE}    ${RLF_INITIATED_UE_T310_EXPIRY}    ${RLF_INITIATED_UE_RACH_FAIL}
    ...                            ${RLF_INIT_SGNB_MAX_RLC_RETX}    ${RLF_INITIATED_UE_SCG_RECNF_F}    ${RLF_INITIATED_UE_SCG_CHGE_FAIL}
    ...                            ${RLF_INITIATED_UE_SRB_INTGRTY_F}
    Start Counter    rule_list=${rule_list}    product_type=vcu    bts_index=0

Check Wireshark Log For CB012277
    [Arguments]    ${wireshark_path}
    Log to Console    \n***Check Wireshark Log For CB012277***
    ${SRBID_filter} =    catenate    f1ap.SRBID == 3
    ${measResult_Serving_Cell} =    catenate    nr-rrc.physCellId == 50
    ${measResult_Neigh_Cell_List_NR} =    catenate    nr-rrc.physCellId == 384
    ${x2ap_filter} =    catenate    x2ap

    ${output_info}=    Run    tshark -Y "${SRBID_filter}" -r ${wireshark_path}
    Should Contain    ${output_info}    ULRRCMessageTransfer

    ${output_info}=    Run    tshark -Y "${measResult_Serving_Cell}" -r ${wireshark_path}
    Should Contain    ${output_info}    SgNBChangeRequired

    ${output_info}=    Run    tshark -Y "${measResult_Neigh_Cell_List_NR}" -r ${wireshark_path}
    Should Contain    ${output_info}    SgNBChangeRequired

    ${output_info}=    Run    tshark -Y "${x2ap_filter}" -r ${wireshark_path}
    Should Contain Any    ${output_info}    SgNBChangeConfirm    SNStatusTransfer  UEContextRelease