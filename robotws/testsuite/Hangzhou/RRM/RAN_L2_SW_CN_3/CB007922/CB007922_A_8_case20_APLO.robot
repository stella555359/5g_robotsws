*** Settings ***
Suite Setup       Common Suite Setup
Suite Teardown   # Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown    # Common Test Teardown
Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD   CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_ningyang     SBTS22R4    SBTS23R1
...               AP
Resource          ../resources/KISS/robot/common_resource.robot
Resource          ../resources/sg10/internal_resource/internal_resource.robot

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}      SCFC_20_ABIO.xml
${AIRPHONE_NAME}    IPHY_AEQN_AEHC_2CELL_ABIO.xml
${WTS_NAME}       SANSA7922_interband_ho_10ue_ABIO.cfg
@{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
${HO_CMD1}     ue_enb_param id\=11 drx_config\=off measurement_gap\=gp0:20 gap_trigger\=gnb_triggered mgta\=ms0dot50 gap_purpose\=perUE
${HO_CMD2}     ue_measurement_send_nr event\=A2 id\=11 meas_id\=2 rs_type\=ssb srsrp_nr\=30
${HO_CMD3}     ue_enb_param id\=11 measurement_gap\=off
${HO_CMD4}     ue_measurement_send_nr id\=11 meas_id\=1 event\=A3 srsrp_nr\=11 srsrq_nr\=11 phycell_id\=54 nrsrp_nr\=20 nrsrq_nr\=20
${HO_CMD5}     ue_measurement_send_nr id\=11 meas_id\=1 event\=A3 srsrp_nr\=11 srsrq_nr\=11 phycell_id\=51 nrsrp_nr\=50 nrsrq_nr\=20
${STABLETIME}    1s
${UE_ID}          11
${EGATE_TAG}      ADD
${BIP_TAG}    ho
${UE_ID_2}        12
${UE_ID3}          13
${UE_ID4}          14
${RI}            csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=1 
*** Test Cases ***
CB007922_case20_A_8b_interL2RT_interBand_Inter_gNB_Inter_frequency_handover_for_A1_SCell_addition_NSA
    Modify counter Swconfig
    Prepare gnb onair
	#Online change dlMimoMode
	#Start WTS And Wait BTS Until Onair   ${WTS_NAME}  reload=${False}
    Start capture gnb and ap syslog in 'after_onair' file
    Execute AP Command before attach
    Attach LTE UE
	#Set '11' RI
    Attach LTE UE2
	Attach LTE UE3
	Attach LTE UE4	
	Check counter value
	Airphone NSA Detach    ${UE_ID_2}
    Airphone NSA Detach    ${UE_ID3}
    Airphone NSA Detach    ${UE_ID4}
    NSA send ue '${UE_ID}' mutiple trf '9' for each '160M' DL data
    Collect AP egate log    ${EGATE_TAG}
    #Analyse scelladd in rrclog
    Check throughput
    run keyword and continue on failure    Trigger inter gnb interband handover
    run keyword and continue on failure    Trigger inter gnb interband handover back
    Check throughput
    Start collect ttitrace
    Wait for '2s' to stop ttitrace with name'tti'
    Check ttitrace
     run keyword and continue on failure    Stop capture gnb and ap syslog in 'after_onair' file
    Airphone NSA Stop Data Traffic    ${UE_ID}    DL
    Airphone NSA Detach    ${UE_ID}
	
*** Keywords ***
Check scell add succesfully
    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All   unzip=TRUE
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/RRC_scelladd.ini    log_need_to_check=p    save_log_directory=${TEST_LOG_DIRECTORY()}/All

Trigger inter gnb interband handover
    airphone_execute_egate_command     ${HO_CMD1}
	Wait time to stable
    airphone_execute_egate_command     ${HO_CMD2}
	Wait time to stable
    airphone_execute_egate_command     ${HO_CMD3}
	Wait time to stable
    airphone_execute_egate_command     ${HO_CMD4}
	Wait time to stable
    Collect AP egate log    ho1
    check handovertotarget sucessfully
    Wait time to stable
Trigger inter gnb interband handover back
    airphone_execute_egate_command     ${HO_CMD5}
	#Set '11' RI
    Wait time to stable
    Collect AP egate log    ho2
    check handovertosource sucessfully
	
check handovertotarget sucessfully
    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/ho1   unzip=TRUE
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/totarget.ini    log_need_to_check=u    save_log_directory=${TEST_LOG_DIRECTORY()}/All/ho1

check handovertosource sucessfully
    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/ho2   unzip=TRUE
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tosource.ini   log_need_to_check=u    save_log_directory=${TEST_LOG_DIRECTORY()}/All/ho2

Wait time to stable
    sleep    ${STABLETIME}

Execute AP Command before attach
    airphone_cleanup_egate_console_log
    Airphone Setup X2 Connection
    Airphone Setup X2 Connection    gnb_id=3

Verify throughput
    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=8    type=pdsch    tput_type=ave
    ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=9    type=pdsch    tput_type=ave
    should_be_true    ${dl_throughput_pcell}>500000
    should_be_true    ${dl_throughput_scell1}>500000

Check throughput
    Wait until keyword succeeds    60s    5s    Verify throughput

Check ttitrace
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All

Attach LTE UE
    Airphone Nsa Attach    ${UE_ID}
    airphone_execute_egate_command    ue_measurement_send_nr id\=11 meas_id\=3 event\=A1 rs_type\=ssb srsrp_nr\=50

UE send A1 event
    airphone_execute_egate_command    ue_measurement_send_nr id\=11 meas_id\=3 event\=A1 rs_type\=ssb srsrp_nr\=50

Analyse scelladd in rrclog
    check_log_with_au2anlysis    ${CURDIR}/ini/RRC_scelladd_NSA.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
Check counter value
    Wait until keyword succeeds    120s    30s    counter value	
counter value
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}
    ${PM_counter_value_Pcell}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55114C00028    cell_id=1
	${PM_counter_value_Pcell2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55114C00035    cell_id=1
	${PM_counter_value_Pcell3}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55114C00021    cell_id=1
	${PM_counter_value_Pcell4}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55115C00008    cell_id=1
    ${PM_counter_value_Scell}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55115C00007    cell_id=2
    should be true    ${PM_counter_value_Pcell}==2
	should be true    ${PM_counter_value_Pcell2}==2
	should be true    ${PM_counter_value_Pcell3}==4
	should be true    ${PM_counter_value_Pcell4}==2
    should be true    ${PM_counter_value_Scell}==2	
Attach LTE UE2
    Airphone Nsa Attach    ${UE_ID_2}    profile_id=None
    airphone_execute_egate_command    ue_measurement_send_nr id\=12 meas_id\=3 event\=A1 rs_type\=ssb srsrp_nr\=50
Attach LTE UE3
    Airphone Nsa Attach    ${UE_ID3}
    airphone_execute_egate_command    ue_measurement_send_nr id\=13 meas_id\=3 event\=A1 rs_type\=ssb srsrp_nr\=50
Attach LTE UE4
    Airphone Nsa Attach    ${UE_ID4}    profile_id=None
    airphone_execute_egate_command    ue_measurement_send_nr id\=14 meas_id\=3 event\=A1 rs_type\=ssb srsrp_nr\=50	
Modify counter Swconfig
	Add GNB swconfig     0x9D0000 :15  
    Modify GNB swconfig	    0x9D0000 :15
Set '${uenum}' RI
    airphone_execute_egate_command    ${RI}
	: FOR    ${num}    IN RANGE    11    ${uenum}+1
    \    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=csi_override action\=activate profile_id\=1 scell\=8-9
Online change dlMimoMode
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
    Perform online change value    MRBTS-1/NRBTS-2/NRCELL-1    dlMimoMode    2x2 Closed Loop Spatial Multiplexing    online
    Perform online change value    MRBTS-1/NRBTS-2/NRCELL-2    dlMimoMode    2x2 Closed Loop Spatial Multiplexing    online	
    Wait '2s' for stabible
    TAF_ADMIN.teardown admin    connection=online	
