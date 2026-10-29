*** Settings ***
Documentation    author: Deng Xueqin
...              Group: RAN_PZ_HAZ3_SG02
...              contact: xueqin.deng@nokia-sbell.com

Resource          Resources/124_trunk_keyword.robot

Suite Setup    CB008927_124_Suite_Setup
Suite Teardown    CB008927_Suite_Teardown

*** Test Cases ***
[1][1.0] CB008927-J_6_check PRB allocation number and location with Single UE (dynamicswitch capable) in FDD in single dedicated BWP
    [Setup]    case_common_setup
    power_ue.Prepare UE    ue_index=${dynamic_ue_index}    ue_type=${dynamic_ue_type}
	sleep    5s
	power_ue.UE Attach    ue_index=${dynamic_ue_index}    ue_type=${dynamic_ue_type}
	sleep    5s
    ${UE_IP}    MTPx80 get UE ip    ue_index=${dynamic_ue_index}    apn=${apn1}
    MTPx80 start dl traffic    UE_IP=${UE_IP}    dltput=200M
    log to console    dynamic UE start dl traffic
    sleep    10s
    ${tput_log}    power_ue.Collect Tput    ue_type=${dynamic_ue_type}    duration=1m    ue_index=${dynamic_ue_index}    check_source=aasyslog
    Start to collect bip log new    nr_phy_cell_ids=${nr_phy_cell_ids}
    sleep    1s
    Stop to collect bip log new
    Run Keyword And Ignore Error    MTPx80 stop dl traffic
    ${all_tp}    power_ue.Check Bi Tput    ue_type=${dynamic_ue_type}    log=${tput_log}    cells=${cell_list}    ue_index=${dynamic_ue_index}
    ...    ultarget_throughput=0    dltarget_throughput=180    check_source=aasyslog
    log to console    dynamic UE check dl tput
    ${bip_files}    Get BIP Filelist
    Check dynamicswitch with DCI_1_0    bip_files=${bip_files}    prefix=8927-J6-log
    [Teardown]    case_common_teardown

[2][1.0] CB008927-J_6_check PRB allocation number and location with Single UE (dynamicswitch capable) in FDD in single dedicated BWP
    [Setup]    case_common_setup
    log to console    This testcase is working as J6 checked
    [Teardown]    case_common_teardown

[1][1.0] CB008927-K_14_check random ratX scheduled in the same slot with dynamicswitch enable
    [Setup]    case_common_setup
    ${ue_list}    Create List    1
    &{ues_tput}    Create Dictionary    1=100MKbits/sec
    &{ues_exp}    Create Dictionary    1=90
    MultiUE L3 call DL and check throughput    ue_list=${ue_list}    apn=${apn0}    ues_tput=${ues_tput}    ues_exp=${ues_exp}
    sleep    5s
    power_ue.Prepare UE    ue_index=${dynamic_ue_index}    ue_type=${dynamic_ue_type}
	sleep    5s
	power_ue.UE Attach    ue_index=${dynamic_ue_index}    ue_type=${dynamic_ue_type}
	sleep    5s
    ${UE_IP}    MTPx80 get UE ip    ue_index=${dynamic_ue_index}    apn=${apn1}
    MTPx80 start dl traffic    UE_IP=${UE_IP}    dltput=100M
    log to console    dynamic UE start dl traffic
    sleep    10s
    ${tput_log}    power_ue.Collect Tput    ue_type=${dynamic_ue_type}    duration=1m    ue_index=${dynamic_ue_index}    check_source=aasyslog
    Start to collect bip log new    nr_phy_cell_ids=${nr_phy_cell_ids}
    sleep    1s
    Stop to collect bip log new
    Run Keyword And Ignore Error    MTPx80 stop dl traffic
    ${all_tp}    power_ue.Check Bi Tput    ue_type=${dynamic_ue_type}    log=${tput_log}    cells=${cell_list}    ue_index=${dynamic_ue_index}
    ...    ultarget_throughput=0    dltarget_throughput=90    check_source=aasyslog
    log to console    dynamic UE check dl tput
    ${bip_files}    Get BIP Filelist
    Check rat0 and rat1 scheduled in the same slot    bip_files=${bip_files}    prefix=8927-K14-log
    [Teardown]    run keywords    Run Keyword And Ignore Error    UE Stop dl traffic    ue_index=1
    ...    AND    case_common_teardown

[1][1.0] CB008927-L_20_check rrc re establishment procedures with FDD actDlDynSwitchAlloc activation and operator disables the dynamicswitch flag
    [Setup]    case_common_setup
	modify actDlDynSwitchAlloc online    attr_value=false
    power_ue.Prepare UE    ue_index=${dynamic_ue_index}    ue_type=${dynamic_ue_type}
	sleep    5s
	power_ue.UE Attach    ue_index=${dynamic_ue_index}    ue_type=${dynamic_ue_type}
	sleep    5s
    ${UE_IP}    MTPx80 get UE ip    ue_index=${dynamic_ue_index}    apn=${apn1}
    #wait until keyword succeeds    5min    5s    Check rrc state    status=Idle    ue_index=${dynamic_ue_index}
	sleep    1min
	trigger_rrcreconfiguration_via_ping    ue_ip=${UE_IP}
    MTPx80 start dl traffic    UE_IP=${UE_IP}    dltput=200M
    log to console    dynamic UE start dl traffic
    sleep    10s
    ${tput_log}    power_ue.Collect Tput    ue_type=${dynamic_ue_type}    duration=1m    ue_index=${dynamic_ue_index}    check_source=aasyslog
    Start to collect bip log new    nr_phy_cell_ids=${nr_phy_cell_ids}
    sleep    1s
    Stop to collect bip log new
    Run Keyword And Ignore Error    MTPx80 stop dl traffic
    ${all_tp}    power_ue.Check Bi Tput    ue_type=${dynamic_ue_type}    log=${tput_log}    cells=${cell_list}    ue_index=${dynamic_ue_index}
    ...    ultarget_throughput=0    dltarget_throughput=180    check_source=aasyslog
    log to console    dynamic UE check dl tput
	${bip_files}    Get BIP Filelist
    Check dynamicswitch activated or dedicated    bip_files=${bip_files}    prefix=8927-L20-1-log   flag=false
	modify actDlDynSwitchAlloc online    attr_value=true
	#wait until keyword succeeds    5min    5s    Check rrccstate    status=Idle    ue_index=${dynamic_ue_index}
	sleep    1min
    trigger_rrcreconfiguration_via_ping    ue_ip=${UE_IP}
    MTPx80 start dl traffic    UE_IP=${UE_IP}    dltput=200M
    log to console    dynamic UE start dl traffic
    sleep    10s
    ${tput_log}    power_ue.Collect Tput    ue_type=${dynamic_ue_type}    duration=1m    ue_index=${dynamic_ue_index}    check_source=aasyslog
    Start to collect bip log new    nr_phy_cell_ids=${nr_phy_cell_ids}
    sleep    1s
    Stop to collect bip log new
    Run Keyword And Ignore Error    MTPx80 stop dl traffic
    ${all_tp}    power_ue.Check Bi Tput    ue_type=${dynamic_ue_type}    log=${tput_log}    cells=${cell_list}    ue_index=${dynamic_ue_index}
    ...    ultarget_throughput=0    dltarget_throughput=180    check_source=aasyslog
    log to console    dynamic UE check dl tput
    ${bip_files_new}    Get BIP Filelist
    Check dynamicswitch activated or dedicated    bip_files=${bip_files_new}    prefix=8927-L20-2-log   flag=true
    [Teardown]    case_common_teardown

[1][1.0] CB008927-A_10_check msg2 or msg4 and DCI 1_1 in the same slot based on mulitiple UEs with NRCELL.actRat1Alloc activition
    [Setup]    case_common_setup
    ${ue_list}    Create List    1
    &{ues_tput}    Create Dictionary    1=10MKbits/sec
    &{ues_exp}    Create Dictionary    1=5
    ${ue_prach_list}    Create List    0
    MultiUE L3 call DL and check throughput    ue_list=${ue_list}
    ...    apn=${apn0}    ues_tput=${ues_tput}    ues_exp=${ues_exp}    get_spark_license=true
    MultiUE Prepare    ue_list=${ue_prach_list}
    sleep    3s
    ${retry_times}    set variable    5
    FOR    ${times}    IN RANGE    ${retry_times}
	    log to console    check msg2ormsg4 with dci11: ${times} times
	    MultiUE Detach    ue_list=${ue_prach_list}
		Start to collect bip log new    nr_phy_cell_ids=${nr_phy_cell_ids}
		MultiUE Attach    ue_list=${ue_prach_list}
		Stop to collect bip log new
		${bip_files}    Get BIP Filelist
		${field_list}    Create List    DlData_DciInfoLoner.rachStatus
		${bip_csv}    Decode bip log to csv file with filter  bip_list=${bip_files}
		...    filter=DlData_DciInfoLoner.dciSize == 48 && (DlData_DciInfoLoner.rachStatus == 2 || DlData_DciInfoLoner.rachStatus == 4)
		...    field_list=${field_list}
		...    prefix=8927-A10-1-log
		${msg2_check}    Check DCI 1_0 and DCI 1_1 in the same slot
		...  bip_csv=${bip_csv}  dci10_filed=DCI_1_0 - RA-RNTI
		${msg4_check}    Check DCI 1_0 and DCI 1_1 in the same slot
		...  bip_csv=${bip_csv}  dci10_filed=DCI_1_0 - C_RNTI
		${check_result}    set variable    ${msg2_check} or ${msg4_check}
		Exit For Loop If    ${check_result}
    END
    should be true    ${check_result}
    [Teardown]    run keywords    UE Stop dl traffic    ue_index=1
    ...    AND    case_common_teardown

[1][1.0] CB008927-A_3_check multiple UE attach functionality with NRCELL.actRat1Alloc activition
    [Setup]    case_common_setup
    ${ue_list}    Create List    1    0
    set test variable    ${ue_list}
    &{ues_tput}    Create Dictionary    0=230MKbits/sec    1=230MKbits/sec
    &{ues_exp}    Create Dictionary    0=190    1=190
    MultiUE L3 call DL and check throughput    ue_list=${ue_list}
    ...    apn=${apn0}    ues_tput=${ues_tput}    ues_exp=${ues_exp}    get_spark_license=true
    Start to collect bip log new    nr_phy_cell_ids=${nr_phy_cell_ids}
    sleep    1s
    Stop to collect bip log new
    ${bip_files}    Get BIP Filelist
    ${bip_file}    set variable    ${bip_files}[0]
    ${ssb_filter}    set variable   (3gpp.slot==0&&3gpp.sfn%2==0)
    ${trs_filter}    set variable   (3gpp.slot==1&&3gpp.sfn%8==0)
    ${pure_pdsch_filter}    set variable   3gpp.slot>=3
    ${errors0}    Check all prb are used in slot    bip_file=${bip_file}    prb_count=${65}    slot_filter=${ssb_filter}    prefix=ssbcheck
    ${errors1}    Check all prb are used in slot    bip_file=${bip_file}    prb_count=${70}    slot_filter=${trs_filter}    prefix=trscheck
    ${errors2}    Check all prb are used in slot    bip_file=${bip_file}
    ...    prb_count=${106}    slot_filter=${pure_pdsch_filter}    prefix=purepdschcheck
    ${errorall}    Evaluate    ${errors0}+${errors1}+${errors2}
    should be equal    ${errorall}    ${0}
    [Teardown]    run keywords    MultiUE Stop dl traffic    ue_list=${ue_list}    apn=${apn0}
    ...    AND    case_common_teardown

[1][1.0] CB008927-H_14_check multiple PDSCH sub-areas schedule with DL RAT 1 activated on SA
    [Setup]    case_common_setup
    modify gscn online    attr_value=1
    ${ue_list}    Create List    1    0
    set test variable    ${ue_list}
    &{ues_tput}    Create Dictionary    0=220MKbits/sec    1=220MKbits/sec
    &{ues_exp}    Create Dictionary    0=150    1=150
    MultiUE L3 call DL and check throughput    ue_list=${ue_list}
    ...    apn=${apn0}    ues_tput=${ues_tput}    ues_exp=${ues_exp}    get_spark_license=true
	${retry_times}    set variable    5
    FOR    ${times}    IN RANGE    ${retry_times}
	    log to console    check multi subarea uesed: ${times} times
		Start to collect bip log new    nr_phy_cell_ids=${nr_phy_cell_ids}
		sleep    1s
		Stop to collect bip log new
		${bip_files}    Get BIP Filelist
		${r}    run keyword and return status    Check multiple PDSCH sub area used with DCI_1_0    bip_files=${bip_files}    prefix=8927-H14-log
		Exit For Loop If    ${r}
    END
    should be true    ${r}
    [Teardown]    run keywords    MultiUE Stop dl traffic    ue_list=${ue_list}    apn=${apn0}
	...    AND    modify gscn online    attr_value=0
    ...    AND    case_common_teardown

[2][1.0] CB008927-H_14_check multiple PDSCH sub-areas schedule with DL RAT 1 activated on SA
    [Setup]    case_common_setup
    log to console     This testcase is working as H14 checked
    [Teardown]    case_common_teardown

[1][1.0] CB008927-A_1_check single UE attach functionality with NRCELL.actRat1Alloc activition
    [Setup]    case_common_setup
    modify actDlDynSwitchAlloc online    attr_value=false
    ${ue_list}    Create List    1
    &{ues_tput}    Create Dictionary    1=10MKbits/sec
    &{ues_exp}    Create Dictionary    1=5
    MultiUE L3 call DL and check throughput    ue_list=${ue_list}    apn=${apn0}    ues_tput=${ues_tput}    ues_exp=${ues_exp}
    Start to collect bip log new    nr_phy_cell_ids=${nr_phy_cell_ids}
    sleep    1s
    Stop to collect bip log new
    ${bip_files}    Get BIP Filelist
    ${field_list}    Create List    DlData_PdschGrantLoner.rat0Bitmap
    ${bip_csv}    Decode bip log to csv file with filter
    ...    bip_list=${bip_files}
    ...    filter=dldata_pdschsendreqloner || DlData_DciInfoLoner.dciSize == 48
    ...    field_list=${field_list}
    ...    prefix=8927-A1-log
    Check Rat1 activited    bip_csv=${bip_csv}
    modify actDlDynSwitchAlloc online    attr_value=true
    [Teardown]    run keywords    UE Stop dl traffic    ue_index=1
    ...    AND    case_common_teardown

[1][1.0] CB008927-A_8_check SI and DCI 1_1 in the same slot based on mulitiple UEs with NRCELL.actRat1Alloc activition
    [Setup]    case_common_setup
    ${ue_list}    Create List    1    0
    set test variable    ${ue_list}
    &{ues_tput}    Create Dictionary    0=200MKbits/sec    1=200MKbits/sec
    &{ues_exp}    Create Dictionary    0=150    1=150
    MultiUE L3 call DL and check throughput    ue_list=${ue_list}    apn=${apn0}    ues_tput=${ues_tput}    ues_exp=${ues_exp}
    Start to collect bip log new    nr_phy_cell_ids=${nr_phy_cell_ids}
    sleep    1s
    Stop to collect bip log new
    ${bip_files}    Get BIP Filelist
    ${field_list}    Create List    DlData_DciInfoLoner.dciSize
    ${bip_csv}    Decode bip log to csv file with filter  bip_list=${bip_files}
    ...    filter=3gpp.rnti == 65535 && DlData_DciInfoLoner.dciSize == 48
    ...    field_list=${field_list}
    ...    prefix=8927-A8-log
    ${dci_check}    Check DCI 1_0 and DCI 1_1 in the same slot
    ...  bip_csv=${bip_csv}  dci10_filed=DCI_1_0 - SI_RNTI
    Should Be True    ${dci_check}
    [Teardown]    run keywords    MultiUE Stop dl traffic    ue_list=${ue_list}    apn=${apn0}
    ...    AND    case_common_teardown

[1][1.0] CB008927-WA_11_UDP DL peak throughput based on RAT1 FDD
    [Setup]    case_common_setup
    log to console     This testcase is working as A3 checked
    [Teardown]    case_common_teardown

[1][1.0] CB008927-A_5_check multiple UE attach functionality with PRB pooling and NRCELL.actRat1Alloc activition
    [Setup]    case_common_setup
    enable_prb_pooling
    ${ue_list}    Create List    1    0
    set test variable    ${ue_list}
    &{ues_tput}    Create Dictionary    0=200MKbits/sec    1=200MKbits/sec
    &{ues_exp}    Create Dictionary    0=150    1=150
    MultiUE L3 call DL and check throughput    ue_list=${ue_list}    apn=${apn0}    ues_tput=${ues_tput}    ues_exp=${ues_exp}
    [Teardown]    run keywords    MultiUE Stop dl traffic    ue_list=${ue_list}    apn=${apn0}
    ...    AND    case_common_teardown

[1][1.0] CB008927-C_3_check minimum prioritized quota with Dynamic slice-aware scheduler and DL RAT 1 activated on SA
    [Setup]    case_common_setup
    ${cells}    Create List    1
    set test variable    ${cells}
    enable_slice    cells=${cells}
    sleep    60s
    ${ue_list}    Create List    3    0
    set test variable    ${ue_list}
    &{ues_tput}    Create Dictionary    0=240MKbits/sec    3=120MKbits/sec
    &{ues_exp}    Create Dictionary    0=180    3=90
    MultiUE L3 call DL and check throughput    ue_list=${ue_list}    apn=${apn0}    ues_tput=${ues_tput}    ues_exp=${ues_exp}
    [Teardown]    run keywords    MultiUE Stop dl traffic    ue_list=${ue_list}    apn=${apn0}
    ...    AND    disable_slice    cells=${cells}
    ...    AND    case_common_teardown

[1][1.0] CB008927-H_27_check PDSCH subareaes with DL RAT 1 activated based on 2 full buffer UEs
    [Setup]    case_common_setup
    config_h27_parameters_online   attr_value=1
    ${ue_list}    Create List    3    0
    set test variable    ${ue_list}
    &{ues_tput}    Create Dictionary    0=240MKbits/sec    3=120MKbits/sec
    &{ues_exp}    Create Dictionary    0=180    3=90
    MultiUE L3 call DL and check throughput    ue_list=${ue_list}    apn=${apn0}    ues_tput=${ues_tput}    ues_exp=${ues_exp}
	${retry_times}    set variable    5
    FOR    ${times}    IN RANGE    ${retry_times}
	    log to console    check multi subarea uesed: ${times} times
		Start to collect bip log new    nr_phy_cell_ids=${nr_phy_cell_ids}
		sleep    1s
		Stop to collect bip log new
		${bip_files}    Get BIP Filelist
		${r}    run keyword and return status    Check multiple PDSCH sub area used with DCI_1_0    bip_files=${bip_files}    prefix=8927-H27-log
		Exit For Loop If    ${r}
    END
    should be true    ${r}
    [Teardown]    run keywords    MultiUE Stop dl traffic    ue_list=${ue_list}    apn=${apn0}
    ...    AND    case_common_teardown

[1][1.0] CB008927-B_4_check PDSCH not in PRB blanking with NRCELL.actRat1Alloc activition
    [Setup]    case_common_setup
    update_scf    scfpath=${b4_scf}
    sleep    120s
    ${ue_list}    Create List    1    0
    set test variable    ${ue_list}
    &{ues_tput}    Create Dictionary    0=200MKbits/sec    1=200MKbits/sec
    &{ues_exp}    Create Dictionary    0=150    1=150
    MultiUE L3 call DL and check throughput    ue_list=${ue_list}    apn=${apn0}    ues_tput=${ues_tput}    ues_exp=${ues_exp}
    Start to collect bip log new    nr_phy_cell_ids=${nr_phy_cell_ids}
    sleep    1s
    Stop to collect bip log new
    ${bip_files}    Get BIP Filelist
    check_blanking_prb_not_used    bip_files=${bip_files}
    [Teardown]    run keywords    MultiUE Stop dl traffic    ue_list=${ue_list}    apn=${apn0}
    ...    AND    case_common_teardown

[1][1.0] CB013945-SR-A_12_check 1 dynamical UE DL throughput with single dedicated BWP
    [Setup]    case_common_setup
    #update_scf    scfpath=${A1_scf}
    ${vaildate_status}    run keyword and return status    check actDlDynSwitchAlloc modification online    attr_value=true
    run keyword if    ${vaildate_status}    run keyword     modify actRat1Alloc online    attr_value=true
    power_ue.Prepare UE    ue_index=${dynamic_ue_index}    ue_type=${dynamic_ue_type}
    sleep    5s
    power_ue.UE Attach    ue_index=${dynamic_ue_index}    ue_type=${dynamic_ue_type}
    sleep    5s
    ${UE_IP}    MTPx80 get UE ip    ue_index=${dynamic_ue_index}    apn=${apn1}
    MTPx80 start dl traffic    UE_IP=${UE_IP}    dltput=400M
    log to console    dynamic UE start dl traffic
    sleep    10s
    ${tput_log}    power_ue.Collect Tput    ue_type=${dynamic_ue_type}    duration=1m    ue_index=${dynamic_ue_index}         check_source=aasyslog
    Start to collect bip log new    nr_phy_cell_ids=${nr_phy_cell_ids}
    sleep    1s
    Stop to collect bip log new
    Run Keyword And Ignore Error    MTPx80 stop dl traffic
    ${bip_files}    Get BIP Filelist
    Check dynamicswitch activated or dedicated    bip_files=${bip_files}    prefix=13945-A-1-log   flag=true
    [Teardown]    case_common_teardown