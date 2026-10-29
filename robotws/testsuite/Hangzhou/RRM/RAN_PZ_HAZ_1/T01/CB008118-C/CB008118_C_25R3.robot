*** Settings ***
Documentation
...   Author: yangjun.zhan@nokia-sbell.com
...   Contact: yangjun.zhan@nokia-sbell.com
...   Description: This user scenario describes

Suite Setup       Run keywords   Common Suite Setup For RRM   AND   Update bsr package
Test Setup        Common Test Setup For RRM
Suite Teardown    Common Suite Teardown For RRM
Test Teardown     Common Test Teardown For RRM

Test Timeout    120 minutes

Resource          ../../Resources/Classical/RRM_Common_Resource.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/Module/Module.robot
Resource       ../../T01/Resources/RRM2_RRM_Resource.robot

*** Variables ***
${Added_5QI1_Success}
...    Added QosFlow with QFI:4 5QI:1
${Setup_5QI5_Success}
...    Setup QosFlow with QFI:1 5QI:5
${Added_5QI5_Success}
...    Added QosFlow with QFI:3 5QI:5
${Setup_5QI7_Success}
...    Setup QosFlow with QFI:1 5QI:7
${Setup_5QI9_Success}
...    Setup QosFlow with QFI:1 5QI:9
${Added_5QI65_Success}
...    Added QosFlow with QFI:2 5QI:65
${Added_5QI66_Success}
...    Added QosFlow with QFI:2 5QI:66
${Setup_5QI65_Success}
...    Setup QosFlow with QFI:1 5QI:65
${Setup_5QI69_Success}
...    Setup QosFlow with QFI:1 5QI:69
${TC16_Setup_5QI70_Success}
...    Setup QosFlow with QFI:1 5QI:70
${TC16_Added_5QI69_Success}
...    Added QosFlow with QFI:2 5QI:69
${TC16_Added_5QI65_Success}
...    Added QosFlow with QFI:3 5QI:65
${Remove_5QI65_Success}
...    Deleting QosFlow with QFI:2 5QI:65
${Added_5QI9_Success}
...    Added QosFlow with QFI:2 5QI:9
${ROHC_maxCID}
...    maxCID 4
${DRX_5QI69}
...    drx-LongCycleStartOffset ms160
${DRX_5QI65}
...    drx-LongCycleStartOffset ms40
&{dcap_info}    host=127.0.0.1    port=9443    username=${None}    password=${None}

*** Test Cases ***
#Case_Precondition
#    Case Precondition

USCB008118-C#IWK1_TC01
    [Tags]    QC_203332       QCD_MN_RAN      QCP_RAN_VRF
    [Setup]    Case Precondition
    Run Keyword And Ignore Error   Scout_cli start
    Start TTI Emil For GNB
    sleep    60s
    UE Deregister From gNB      ue_id=1
    Establish mcs-PriorityAccess    ue_id=1
    UE Register And PDU Session Setup   ue_id=1   qos_flow=19   pass_regexp=${Setup_5QI69_Success}
    UE Modify new PDU    ue_id=1    pdu=1    qosflows_to_add=15    pass_regexp=${ROHC_maxCID}
    Send GBR Throughput    ue_id=1    pdu_id=1    qfi_id=2
    sleep    5s
    Check GBR UE Tput    ue_id=1
    Stop TTI Emil For GNB

USCB008118-C#IWK2_TC06
    [Tags]    QC_203331       QCD_MN_RAN      QCP_RAN_VRF
    #[Setup]    Case Precondition Debug
    Run Keyword And Ignore Error   Scout_cli start
    Start TTI Emil For GNB
    sleep    60s
    UE Deregister From gNB      ue_id=1
    Establish mcs-PriorityAccess    ue_id=1
    UE Register And PDU Session Setup   ue_id=1   qos_flow=19   pass_regexp=${DRX_5QI69}
    UE Modify new PDU    ue_id=1    pdu=1    qosflows_to_add=15    pass_regexp=${DRX_5QI65}
    Send GBR Throughput    ue_id=1    pdu_id=1    qfi_id=2
    sleep    5s
    Check GBR UE Tput    ue_id=1
    Stop TTI Emil For GNB


*** Keywords ***
Case Precondition Debug
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s

Case Precondition
    Airphone Operation    operation=edaemon_egate_teardown    product_type=${None}    traffic_info_dic=${None}
    ...                   tag=${None}    cmd=${None}    pass_regexp=${None}    timeout=100s
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=env_setup_sa
    ...                   product_type=gnb
    ...                   traffic_info_dic=${None}
    ...                   tag=CB008118_RJIO
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=12000s
    ...                   customer=RJIO
    #[Teardown]    Airphone Operation    operation=edaemon_egate_teardown    product_type=${None}    traffic_info_dic=${None}
    #...                                 tag=${None}    cmd=${None}    pass_regexp=${None}    timeout=100s
    Common Test Setup For RRM
    Start Btslog Collect    names=btslog1
    log_to_console     Plugin download
    start_dcap_controller_common

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Airphone Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off
    sleep     5s
UE Register And PDU Session Setup
    [Arguments]    ${ue_id}=1    ${qos_flow}=5    ${pdu}=1    ${pass_regexp}=QoS Routing Table
    Airphone Execute Egate Command    cmd=ue_register id=${ue_id}
    sleep   2s
    Airphone Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal default_qos_flow=${qos_flow}
    sleep   2s
    Airphone Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=${pdu} nwslice=1 gw=1    pass_regexp=${pass_regexp}
UE Modify new PDU
    [Arguments]    ${ue_id}=1    ${pdu}=1   ${qosflows_to_add}=65   ${pass_regexp}=QoS Routing Table
    Airphone Execute Egate Command
    ...    cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=${qosflows_to_add} by=amf    pass_regexp=${pass_regexp}
    sleep    10s
UE Delte PDU
    [Arguments]    ${ue_id}=1    ${pdu}=1   ${qosflows_to_del}=65   ${pass_regexp}=QoS Routing Table
    Airphone Execute Egate Command
    ...    cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_del=${qosflows_to_del} by=amf pass_regexp=${pass_regexp}
    sleep    5s
Send NonGBR Throughput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1
    Execute Egate Command    cmd=data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl trf_id=1 protocol=udp mbps=100 seconds=1200
#    ...    pass_regexp=UE ${ue_id}: UDP DL
    sleep   2s
    Execute Egate Command    cmd=data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul trf_id=2 protocol=udp mbps=10 seconds=1200
#    ...    pass_regexp=UE ${ue_id}: UDP UL
Stop NonGBR Throughput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1
    Execute Egate Command    cmd=trf_data_stop ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl trf_id=1
#    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    cmd=trf_data_stop ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul trf_id=2
#    ...    pass_regexp=UE ${ue_id}: UDP UL
Send GBR Throughput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl trf_id=3 protocol=tcp mbps=1 seconds=600
    ...    pass_regexp=UE ${ue_id}: TCP DL
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul trf_id=4 protocol=tcp mbps=1 seconds=600
    ...    pass_regexp=UE ${ue_id}: TCP UL
Stop GBR Throughput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1
    Execute Egate Command    cmd=trf_data_stop ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl trf_id=3
#    ...    pass_regexp=UE ${ue_id}: TCP DL
    Execute Egate Command    cmd=trf_data_stop ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul trf_id=4
#    ...    pass_regexp=UE ${ue_id}: TCP UL
Establish mcs-PriorityAccess
    [Arguments]    ${ue_id}=1
    Execute Egate Command    cmd=ue_nr_rrc_setup_param id=${ue_id} establishment_cause=mcs-PriorityAccess
Establish emergency
    [Arguments]    ${ue_id}=1
    Execute Egate Command    cmd=ue_nr_rrc_setup_param id=${ue_id} establishment_cause=emergency

Check Traffic
    [Arguments]    ${ue_id}=1
    Airphone Execute Egate Command     ue_stats_nr id=${ue_id} type=pdsch
    Airphone Execute Egate Command     ue_stats_nr id=${ue_id} type=pusch
Start Collect Wireshark For GNB
    ${wireshark_argument}   Create Dictionary   wireshark_options=-i any
    ${dict_argument}   Create Dictionary   argument=${wireshark_argument}
    Log Collection    start    wireshark    product_type=gnb    bts_index=${0}    dict_argument=${dict_argument}
    sleep     5s
Stop Wireshark log For GNB
    ${local_file_path}    Log Collection    stop_and_download    wireshark    product_type=gnb    bts_index=${0}
    sleep    2s
    [Return]    ${local_file_path}
Analyze Wireshark log
    [Arguments]    ${local_file_path}    ${wireshark_analysis_dict}
    ${result}=    Log Analysis    check    wireshark    ${local_file_path}    ${wireshark_analysis_dict}
    Log To Console    \nAnalyze log: ${result}
Start TTI For GNB
    start_dcap_controller_common
    ${dcap_argument}   Create Dictionary   nrCells=NRCELL_R-1
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}    argument=${dcap_argument}
    Log Collection    start    tti    product_type=gnb    bts_index=${0}    cudu_index=${0}    dict_argument=${dict_argument}
Stop TTI For GNB
    ${local_file_path}    Log Collection    stop_and_download    tti    product_type=gnb    bts_index=${0}    cudu_index=${0}
Modify Parameter
    [Arguments]    ${para}=actMcQosSupport    ${value}=true
    @{para_list}          Create List    ${para}
    @{mo_list_vdu}        Create List    MRBTS-1/NRBTS-1/NRCELL-1
    @{value_list_true}    Create List    ${value}
    ${out}                Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                          para_list=@{para_list}    value_list=@{value_list_true}    mo_list=@{mo_list_vdu}
    Log To Console        gnb paramter update result: ${out}
    sleep   5s
Check NonGBR UE Tput
    [Arguments]    ${ue_id}=1    ${qfi_id}=1
    ${max_tput}    ${ave_tput}    ${min_tput}    Module AP Get Average Throughput    ue_id=${ue_id}
    ...                                                  qfi=${qfi_id}    dir=dl    trf_id=1    type=l3
    ...                                                  call_type=SA    pdu_id=1
    ${ave_tput_str}    Convert To String    ${ave_tput}
    log_to_console     UE${ue_id} DL ave tput is ${ave_tput_str.lower()}
    ${max_tput}    ${ave_tput}    ${min_tput}    Module AP Get Average Throughput    ue_id=${ue_id}
    ...                                                  qfi=${qfi_id}    dir=ul    trf_id=2    type=l3
    ...                                                  call_type=SA    pdu_id=1
    ${ave_tput_str}    Convert To String    ${ave_tput}
    log_to_console     UE${ue_id} UL ave tput is ${ave_tput_str.lower()}
Check GBR UE Tput
    [Arguments]    ${ue_id}=1    ${qfi_id}=2
    ${max_tput}    ${ave_tput}    ${min_tput}    Module AP Get Average Throughput    ue_id=${ue_id}
    ...                                                  qfi=${qfi_id}    dir=dl    trf_id=3    type=l3
    ...                                                  call_type=SA    pdu_id=1
    ${ave_tput_str}    Convert To String    ${ave_tput}
    log_to_console     UE${ue_id} DL ave tput is ${ave_tput_str.lower()}
    ${max_tput}    ${ave_tput}    ${min_tput}    Module AP Get Average Throughput    ue_id=${ue_id}
    ...                                                  qfi=${qfi_id}    dir=ul    trf_id=4    type=l3
    ...                                                  call_type=SA    pdu_id=1
    ${ave_tput_str}    Convert To String    ${ave_tput}
    log_to_console     UE${ue_id} UL ave tput is ${ave_tput_str.lower()}
Start Collect Mutli Counter For T16
    ${rule_list}    Create List
    ${rule1}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...         Counter: M55125C08501;
    ...         Counter rule:avg(M55125C08501)>=1;
    append to list  ${rule_list}    ${rule1}

    ${rule2}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...         Counter: M55163C00001;
    ...         Counter rule:avg(M55163C00001)>=1;
    append to list  ${rule_list}    ${rule2}

    ${rule3}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...         Counter: M55125C09012;
    ...         Counter rule:avg(M55125C09012)>=1;
    append to list  ${rule_list}    ${rule3}
    ${rule4}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...         Counter: M55163C00512;
    ...         Counter rule:avg(M55163C00512)>=1;
    append to list  ${rule_list}    ${rule4}
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}
Stop Collect Mutli Counter
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0    cudu_index=0
Start TTI Emil For GNB
    [Arguments]    ${cell_id}=NRCELL_R-1
    start_dcap_controller_common
    ${dcap_argument}   Create Dictionary   nrCells=${cell_id}
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}    argument=${dcap_argument}
    Log Collection    start    tti+emil    product_type=gnb    bts_index=${0}    cudu_index=${0}    dict_argument=${dict_argument}
Stop TTI Emil For GNB
    ${local_file_path}    Log Collection    stop_and_download    tti+emil    product_type=gnb    bts_index=${0}    cudu_index=${0}
Update bsr package
    Run     sshpass -p 'Ut3pa5s#ff97' scp ute@10.56.218.196:/home/ute/BSR_AQQJ_4_H4_ALN30_ARP30_P00_6TO4_60_00421_00001.zip /home/ute/
    ${dllink}   Set Variable     https://artifactory-espoo1.int.net.nokia.com/artifactory/mnpute-rotta-local/BSR
    ${filename}    Set variable     BSR_AQQJ_4_H4_ALN30_ARP30_P00_6TO4_60_00421_00001.zip
    Run     wget ${dllink}/${filename} -P /home/ute
    coam.setup admin
    ${ret}    coam.Update Software    /home/ute/${filename}
    coam.teardown admin
Delta plan operation for CB008118
    [Arguments]    ${delta_file_path}=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/HAZ2/CB009552/delta_plan.json
    ${out}     Parameter Operation    operation=delta_plan_update   product_type=gnb
    ...                               delta_file_path=${delta_file_path}
    Log To Console    delta plan update result: ${out}
    sleep    10s
Set UE RRC Establishment Cause to Emergency
    [Arguments]    ${ue_id}=2
    Airphone Execute Egate Command    cmd=ue_nr_rrc_setup_param id=${ue_id} establishment_cause=emergency
Set qosflow priority and smf param active
    [Arguments]    ${additional_qosflows_to_activate}=1    ${priority}=1
    Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=1 priority=${priority}
    Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=5 priority=${priority}
    Airphone Execute Egate Command    cmd=smf_param id=1 additional_qosflows_to_activate=${additional_qosflows_to_activate}
Emergency Call UE Register And PDU Session Setup
    [Arguments]    ${ue_id}=1    ${qos_flow}=5    ${pdu}=1    ${pass_regexp}=QoS Routing Table
    Airphone Execute Egate Command    cmd=ue_register id=${ue_id} registration_type=EmergencyRegistration withSim=on
    sleep   2s
    Airphone Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal default_qos_flow=${qos_flow}
    sleep   2s
    Airphone Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=${pdu} nwslice=1 gw=1 request_type=initial-emergency-request
    ...    pass_regexp=${pass_regexp}
Emergency Call UE Modify new PDU
    [Arguments]    ${ue_id}=1    ${pdu}=1   ${qosflows_to_add}=1   ${pass_regexp}=QoS Routing Table
    Airphone Execute Egate Command
    ...    cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=${qosflows_to_add} by=amf    pass_regexp=${pass_regexp}
    sleep    10s
Get Meas Configuration Received From gNB
    [Arguments]    ${ue_id}=1
    Airphone Execute Egate Command
    ...    cmd=ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr    #pass_regexp=${pass_regexp}
    sleep    10s
Ue Send Meas To gNB
    [Arguments]    ${ue_id}=1    ${meas_id}=2    ${event_name}=A3
    Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_name}
    ...    srsrp_nr=11 srsrq_nr=11 phycell_id=13 nrsrp_nr=20 nrsrq_nr=20 phycell_id=384
    ...    nrsrp_nr=30 nrsrq_nr=30    #pass_regexp=${pass_regexp}
    sleep    10s
Perform command to initiate UE reauthentication
    [Arguments]    ${ue_id}=1
    Execute egate command   cmd=ue_reauth id=${ue_id} nr_sec_cap=null|zuc
    Sleep  2