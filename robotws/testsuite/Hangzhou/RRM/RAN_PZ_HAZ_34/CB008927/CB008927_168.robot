*** Settings ***
Documentation    author: Deng Xueqin
...              Group: RAN_PZ_HAZ3_SG02
...              contact: xueqin.deng@nokia-sbell.com

Resource          Resources/common_keyword.robot

Suite Setup    CB008927_168_Suite_Setup
Suite Teardown    CB008927_Suite_Teardown

*** Test Cases ***
[1][1.0] CB008927-K_3_check CA type3 start PRB with dynamicswitch enable
    [Setup]    case_common_setup
    power_ue.Prepare UE    ue_index=${dynamic_ue_index}    ue_type=${dynamic_ue_type}
    sleep    5s
    ${dynamic_ue_ip}    MTP attach and verify    ue_index=${dynamic_ue_index}    ue_type=${dynamic_ue_type}    apn=${apn0}
	log to console      dynamic ue ip: ${dynamic_ue_ip}
    sleep    5s
    power_ue.Start traffic    ue_type=${dynamic_ue_type}    direction=dl    throughput=100Mbits/sec    apn_address=${apn0}
    ...   protocol=udp    duration=1200    ue_index=${dynamic_ue_index}
    log to console    dynamic UE start dl traffic
    power_ue.Prepare UE    ue_index=2    ue_type=${ue_type}     power_reset=true    get_spark_license=false
    sleep    1s
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=2    ue_type=${ue_type}    log_type=Aasyslog
    ...    attach_mode=5G_SA    power_reset=true
    sleep    1s
    spark verify attach and retry if attach failed   5Grach_ed=${5Grach_ed_0}    ue_index=2    retry_times=2
    sleep    5s
    ${tput_log}    power_ue.Collect Tput    ue_type=${dynamic_ue_type}    duration=1m    ue_index=${dynamic_ue_index}
    Run Keyword And Ignore Error    power_ue.Stop traffic    direction=dl    ue_index=${dynamic_ue_index}
    ...    ue_type=${dynamic_ue_type}    apn_address=${apn0}
    ${all_tp}    power_ue.Check Bi Tput    ue_type=${dynamic_ue_type}    log=${tput_log}    cells=${cell_list}    ue_index=${dynamic_ue_index}
    ...    ultarget_throughput=0    dltarget_throughput=90
    log to console    dynamic UE check dl tput
    [Teardown]    run keywords    Run Keyword And Ignore Error    power_ue.UE Detach    ue_index=${dynamic_ue_index}    ue_type=${dynamic_ue_type}
	...    AND    case_common_teardown

[1]CB008927-WB_4_single UDP DL throughput peak with good condition based on dynamic FDD CA
    [Setup]    case_common_setup
    power_ue.Prepare UE    ue_index=${dynamic_ue_index}    ue_type=${dynamic_ue_type}
    sleep    5s
    ${dynamic_ue_ip}    MTP attach and verify    ue_index=${dynamic_ue_index}    ue_type=${dynamic_ue_type}    apn=${apn0}
	log to console      dynamic ue ip: ${dynamic_ue_ip}
    sleep    5s
    power_ue.Start traffic    ue_type=${dynamic_ue_type}    direction=dl    throughput=900Mbits/sec    apn_address=${apn0}
    ...   protocol=udp    duration=1200    ue_index=${dynamic_ue_index}
    log to console    dynamic UE start dl traffic
    sleep    20s
    ${tput_log}    power_ue.Collect Tput    ue_type=${dynamic_ue_type}    duration=1m    ue_index=${dynamic_ue_index}
    Run Keyword And Ignore Error    power_ue.Stop traffic    direction=dl    ue_index=${dynamic_ue_index}
    ...    ue_type=${dynamic_ue_type}    apn_address=${apn0}
    ${all_tp}    power_ue.Check Bi Tput    ue_type=${dynamic_ue_type}    log=${tput_log}    cells=${cell_list}    ue_index=${dynamic_ue_index}
    ...    ultarget_throughput=0    dltarget_throughput=810
    log to console    dynamic UE check dl tput
    [Teardown]    run keywords    Run Keyword And Ignore Error    power_ue.UE Detach    ue_index=${dynamic_ue_index}    ue_type=${dynamic_ue_type}
	...    AND    case_common_teardown

[1]CB008927-S_16_check medium BWP UE PRB allocation with reserved PBRs less than prioritized PRB region IWK CB012669 with multi dedicated BWP
    [Setup]    case_common_setup
    update_scf    scfpath=${s16_scf}
    sleep    120s
    ${ue_list}    Create List    1   2
    &{ues_tput}    Create Dictionary    1=10MKbits/sec    2=100MKbits/sec
    &{ues_exp}    Create Dictionary    1=8    2=90
    set test variable    ${ue_list}
    MultiUE L3 call DL and check throughput    ue_list=${ue_list}    apn=${apn0}    ues_tput=${ues_tput}    ues_exp=${ues_exp}
    Start to collect bip log new    nr_phy_cell_ids=${nr_phy_cell_ids}
    sleep    1s
    Stop to collect bip log new
    ${bip_files}    Get BIP Filelist
    Check prb allocation iwk 12669    bip_files=${bip_files}    prioritizedprb=80    ssbend=33    prefix=8927-S16-log
    [Teardown]    run keywords    Run Keyword And Ignore Error    MultiUE Stop dl traffic    ue_list=${ue_list}    apn=${apn0}
    ...    AND    case_common_teardown

*** Keywords ***
Check prb allocation iwk 12669
    [Arguments]    ${bip_files}    ${prioritizedprb}    ${ssbend}    ${prefix}
    log to console    \ncheck prb allocation iwk 12669
    ${field_list}    Create List    DlData_PdschGrant.startPrb    DlData_PdschGrant.numOfPrb
    ${bip_csv}    Decode bip log to csv file with filter
    ...    bip_list=${bip_files}
    ...    filter=dldata_pdschsendreq
    ...    field_list=${field_list}
    ...    prefix=${prefix}
    ${result1}=    Run    cat ${bip_csv}
    ${line_list}    Split String    string=${result1}    separator=\n
    ${line_to_remove}     set variable    ${line_list}[0]
    Remove Values From List    ${line_list}    ${line_to_remove}
    FOR    ${line_info}    IN    @{line_list}
        ${line}    Split String    string=${line_info}    separator=,
        ${sfn}    ${slot}    ${rnti}    ${startprb}    ${numofprb}
        ...		set variable    ${line}[1]    ${line}[2]    ${line}[3]    ${line}[4]    ${line}[5]
        ${status0}    run keyword and return status    should be true    ${rnti}==65535 or ${startprb}==0
        Continue For Loop If	${status0}==True
        ${status1}    check_prballocated_inpriority
        ...		startprb=${startprb}    numofprb=${numofprb}    prioritizedprb=${prioritizedprb}
        Continue For Loop If	${status1}==True
        ${subareaexist}    check_if_subareaexist    sfn=${sfn}    slot=${slot}    bip_csv=${bip_csv}
        ${status2}
        ...	   Run Keyword If    '${subareaexist}'=='True'    check_prballocated_frombottomofsubarea
        ...    sfn=${sfn}    slot=${slot}    rnti=${rnti}    startprb=${startprb}    bip_csv=${bip_csv}
        ...    ELSE IF    ${sfn}%2==0 and ${slot}==0	   check_ssbslot_prbuse
        ...	   sfn=${sfn}    slot=${slot}    rnti=${rnti}    startprb=${startprb}    ssbend=${ssbend}    bip_csv=${bip_csv}
        ...    ELSE    check_prballocated_frombottomofregion
        ...	   sfn=${sfn}    slot=${slot}    rnti=${rnti}    startprb=${startprb}    regionstart=0    bip_csv=${bip_csv}
        should be true    ${status2}
    END

check_prballocated_inpriority
    [Arguments]    ${startprb}    ${numofprb}    ${prioritizedprb}
    ${status}    run keyword and return status    should be true    ${startprb}+${numofprb}<=${prioritizedprb}
    [Return]    ${status}

check_if_subareaexist
    [Arguments]    ${sfn}    ${slot}    ${bip_csv}
    ${result}=    Run     awk 'BEGIN{FS=","}{if($2==${sfn}&&$3==${slot}&&$4==65535)print $5, $6}' ${bip_csv}
    ${subareaexist}    run keyword and return status    Should Not Be Empty    ${result}
    [Return]    ${subareaexist}

check_prballocated_frombottomofsubarea
    [Arguments]    ${sfn}    ${slot}    ${rnti}    ${startprb}    ${bip_csv}
    ${result}=    Run     awk 'BEGIN{FS=","}{if($2==${sfn}&&$3==${slot}&&$4==65535)print $5, $6}' ${bip_csv}
    ${lines}    Split String    string=${result}    separator=\n
    ${subareaend}    set variable    0
    FOR    ${line}    IN    @{lines}
        ${prb_start_num}=    Split String    string=${line}    separator=${SPACE}
        ${start}    set variable    ${prb_start_num}[0]
        ${end}    Evaluate    ${prb_start_num}[0]+${prb_start_num}[1]
        ${subareaend}    run keyword if    ${end}>${subareaend}    set variable   ${end}
    END
    ${status}    run keyword if    ${startprb}==${subareaend}    set variable    True
    ...    ELSE    check_multiueinsubarea
    ...    sfn=${sfn}    slot=${slot}    rnti=${rnti}    subareaend=${subareaend}    startprb=${startprb}    bip_csv=${bip_csv}
    [Return]    ${status}

check_multiueinsubarea
    [Arguments]    ${sfn}    ${slot}    ${rnti}    ${startprb}    ${subareaend}    ${bip_csv}
    ${result1}=    Run    awk 'BEGIN{FS=","}{if($2==${sfn}&&$3==${slot}&&$4!=65535&&$4!=${rnti})print $5, $6}' ${bip_csv}
    ${lines1}    Split String    string=${result1}    separator=\n
    FOR    ${line}    IN    @{lines1}
        ${prb_start_num}=    Split String    string=${line}    separator=${SPACE}
        ${start}    set variable    ${prb_start_num}[0]
        ${end}    Evaluate    ${prb_start_num}[0]+${prb_start_num}[1]
        ${status}    run keyword and return status    should be true    ${start}==${subareaend} and ${startprb}==${end}
        Exit For Loop If    '${status}'=='True'
    END
    [Return]    ${status}

check_prballocated_frombottomofregion
    [Arguments]    ${sfn}    ${slot}    ${rnti}    ${startprb}    ${regionstart}    ${bip_csv}
    ${result}=    Run     awk 'BEGIN{FS=","}{if($2==${sfn}&&$3==${slot}&&$4!=${rnti})print $5, $6}' ${bip_csv}
    ${lines}    Split String    string=${result}    separator=\n
    FOR    ${line}    IN    @{lines}
        ${prb_start_num}=    Split String    string=${line}    separator=${SPACE}
        ${start}    ${num}    set variable    ${prb_start_num}[0]    ${prb_start_num}[1]
        ${status}    run keyword and return status    should be true    ${start}==${regionstart} and ${startprb}==${start}+${num}
        Exit For Loop If    '${status}'=='True'
    END
    [Return]    ${status}

check_ssbslot_prbuse
    [Arguments]    ${sfn}    ${slot}    ${rnti}    ${startprb}    ${ssbend}    ${bip_csv}
    ${status}    run keyword if    ${startprb}==${ssbend}    set variable    True
    ...    ELSE    check_prballocated_frombottomofregion
    ...	   sfn=${sfn}    slot=${slot}    rnti=${rnti}    startprb=${startprb}    regionstart=${ssbend}    bip_csv=${bip_csv}
    [Return]    ${status}