*** Settings ***
Documentation
...                 author:

Resource    resource_dc.robot

Suite Setup         common_suite_setup_for_pet_aic
Suite Teardown      common_suite_teardown_for_pet_aic
Test Setup          Setup for CB008441 ET
Test Teardown       Teardown for CB008441 ET

Force Tags        CRT    QCD_MN_RAN    QCP_RAN_ST    CA_RAN_PZ_HAZ_1    RAN_PZ_HAZ1_SG05_ST_RRM    CLOUD_5G_CLASSICAL_ANDROID_CA_ASIBL_ABIOB1_AEQN

*** Variables ***
&{pi2_para1}
...    distname=MRBTS-1/NRBTS-1/NRDRB-11    operation_type=replace
...    parameter_path=/queuingDelayDiscarding    value=PI2
&{pi2_para2}
...    distname=MRBTS-1/NRBTS-1/NRDRB-11    operation_type=replace
...    parameter_path=/pi2TargetDelay    value=1200
&{pi2_para3}
...    distname=MRBTS-1/NRBTS-1/NRDRB-11    operation_type=replace
...    parameter_path=/pi2TargetSize     value=50
&{pi2_para4}
...    distname=MRBTS-1/NRBTS-1/NRDRB-11    operation_type=replace
...    parameter_path=/discardTimer       value=1500ms
@{pi2_paras}  &{pi2_para1}  &{pi2_para2}  &{pi2_para3}  &{pi2_para4}

&{counter_0}    dist_name=MRBTS-1/NRBTS-1/NRCELL-3  id=M55350C00035
...    name=DL PDCP SDUs discarded due to Delay Based Discarding PI2 for non-GBR bearers
&{counter_1}    dist_name=MRBTS-1/NRBTS-1  id=M55320C20006
...    name=DL PDCP SDUs discarded due to PDCP discard timer expiry
&{counter_2}    dist_name=MRBTS-1/NRBTS-1  id=M55320C02006
...    name=DL PDCP SDUs discarded due to bearer release
&{counter_3}    dist_name=MRBTS-1/NRBTS-1  id=M55320C04006
...    name=DL PDCP SDUs discarded due to other causes
&{counter_4}    dist_name=MRBTS-1/NRBTS-1  id=M55320C06006
...    name=DL PDCP SDUs discarded due to exceeding buffer threshold
&{counter_5}    dist_name=MRBTS-1/NRBTS-1  id=M55320C09006
...    name=DL PDCP SDUs discarded due to the exceeding Queuing delay
&{counter_6}    dist_name=MRBTS-1/NRBTS-1  id=M55323C00006
...    name=Number of downlink PDCP PDU sent over F1-U
&{counter_7}    dist_name=MRBTS-1/NRBTS-1  id=M55327C01006
...    name=Number of downlink PDCP SDU received over NR NG-U DL GTP-U tunnel
&{counter_8}    dist_name=MRBTS-1/NRBTS-1  id=M55319C12006
...    name=DL PDCP SDU volume transmitted for SA Bearer
&{counter_9}    dist_name=MRBTS-1/NRBTS-1  id=M55319C00001
...    name=Duration of the measurement period for the PDCP Report 1
&{counter_10}   dist_name=MRBTS-1/NRBTS-1/MCC-311/MNC-489/SST-1/SD-13714341  id=M55328C00006
...    name=DL PDCP SDU delay per slice per PLMN
&{counter_11}   dist_name=MRBTS-1/NRBTS-1/MCC-311/MNC-489/SST-1/SD-13714341  id=M55328C00002
...    name=DL PDCP SDUs transmitted per slice per PLMN
@{counter_list}  &{counter_0}  &{counter_1}  &{counter_2}  &{counter_3}
...              &{counter_4}  &{counter_5}  &{counter_6}  &{counter_7}
...              &{counter_8}  &{counter_9}  &{counter_10}  &{counter_11}

${ue_id_1}    51
${ue_id_2}    52

${trf_duration}  180
${tcp_command}  iperf3 -c 10.12.2.3 -p 7071 -P3 -i1 -t${trf_duration} -B 10.0.2.1

*** Test Cases ***
CB008441-CR-A_ST_Case01_Counter_PDCP_Discarted_SDUs_due_to_Delay_Based_Discarding_PI2
    [Documentation]
    ...    author: LAA
    [Tags]    QC_847353

    prepare iperf3
    ${distnames}  ${parameter_paths}  ${values}=  Convert NIDD Parameters  ${pi2_paras}
    ${out}   Parameter Operation    operation=parameter_update  product_type=vcu
    ...    para_list=@{parameter_paths}    value_list=@{values}    mo_list=@{distnames}
    Log to Console  \n${out}

    log to Console  \nPlan to perform TCP Download with PI2 Algorithm
    log to console  \nWait for Current Counter Generated
    paic_wait_until_new_counter_found  unit_name=vcu_0  counter_dn=&{counter_0}[dist_name]  counter_id=${counter_0}[id]
    get_counter_before_service  vcu_0  ${counter_list}

    attach_ue_and_activate_pdu  id=${ue_id_1}   trf_type=internal
    attach_ue_and_activate_pdu  id=${ue_id_2}  trf_type=external
    log to console  \nDownlink Traffic with UE${ue_id_1}(UDP) and UE${ue_id_2}(TCP-IPerf3) Started!
    log to console  \nUE${ue_id_1} start to run trf_data_start ue=${ue_id_1} pdu=1 qfi=1 trf_id=1 mbps=15 dir=dl seconds=${trf_duration}
    wts.execute_egate_command  cmd=trf_data_start ue=${ue_id_1} pdu=1 qfi=1 trf_id=1 mbps=15 dir=dl seconds=${trf_duration}
    ...    pass_regexp=UE${ue_id_1}: Started Downlink Internal traffic Receiver on Ue:${ue_id_1} Pdu:1 Qfi:1 TrfId:1
    log to console  \nUE${ue_id_2} Start to run - ${tcp_command}
    ${timeout}=  evaluate  ${trf_duration}+10
    run process  ${tcp_command}  timeout=${timeout}  shell=true  stdout=true  alias=tcp_dl
    ${output}=  get process result  tcp_dl  stdout=true
    log to console  \n${output}
    log to console  \nDownlink Traffic with UE${ue_id_1}(UDP) and UE${ue_id_2}(TCP-IPerf3) Completed!
    detach_ue_with_power_off  id=${ue_id_1}
    detach_ue_with_power_off  id=${ue_id_2}

    log to console  \nWait for New Counter Generated
    paic_wait_until_new_counter_found  unit_name=vcu_0  counter_dn=&{counter_0}[dist_name]  counter_id=${counter_0}[id]
    log to console  \nNew Counter Generated
    get_counter_after_service  vcu_0  ${counter_list}
    ${counter_result}=  calc_counter_diff
    FOR  ${key}  IN  @{counter_result}
        log to console  \n${key}:${counter_result}[${key}]
    END

    ${sum_discard}=  evaluate  ${counter_result}[M55320C20006]+${counter_result}[M55350C00035]
    ${sum_discard}=  evaluate  ${sum_discard}+${counter_result}[M55320C02006]+${counter_result}[M55320C04006]
    ${sum_discard}=  evaluate  ${sum_discard}+${counter_result}[M55320C06006]+${counter_result}[M55320C09006]
    log to console  \nPDCP SDU Discarded: ${sum_discard}
    ${pdcp_tput}=  evaluate  8*${counter_result}[M55319C12006]/${trf_duration}
    log to console  \nPDCP Throughput: ${pdcp_tput}kbps
    ${pdcp_delay}=  evaluate  ${counter_result}[M55328C00006]/${counter_result}[M55328C00002]/1000
    log to console  \nPDCP SDU Delay: ${pdcp_delay}ms

    Should Be True  ${counter_result}[M55350C00035]>0
    Should Be True  ${counter_result}[M55320C09006]==0
    Should Be True  ${counter_result}[M55327C01006]==${sum_discard}+${counter_result}[M55323C00006]