*** Settings ***
Test Timeout    120 minutes
Suite Setup    Common Suite Setup
#Suite Teardown    Common Suite Teardown
Test Setup    Common Test Setup
Test Teardown    Common Test Teardown
Force Tags    owner_menzheng    AP    SBTS00    RAN_5G_TDD    RAN_5G    CLOUD_5G_I_BOO_AP_LOO
Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot


*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}      SCFC_9928_A1_Switch.xml
${AIRPHONE_NAME}    IPHY_2T2F_8x4.xml
${WTS_NAME}    WTS_9928.cfg

@{LOG_NAME_LIST}    gnb_snapshot    egatelog    

${FILTER_f1ap}    itf_l2_ps_user_usersetupreq
@{titles_f1ap}    3gpp.rnti    itf_l2_ps_UeCapability.dlShortTermBeamformingCapability_item
${FILTER_pusch}    uldata_puschreceivereq||uldata_srsreceivereq
@{titles_pusch}    UlData_puschReceiveReqGrant_t.numOfPuschSymbols    UlData_srsReceiveReqSubcell_t.srsBwvEnable    3gpp.subcellid    3gpp.sfn
...    3gpp.slot
${FILTER_pdsch}    uldata_srsreceivereq||dldata_pdschsendreq
@{titles_pdsch}    DlData_PdschGrant.numOfPdschSymbols    UlData_srsReceiveReqSubcell_t.srsBwvEnable    3gpp.subcellid    3gpp.sfn    3gpp.slot
...    3gpp.rnti
${EGATE_TAG}      MUmimo
${UE_ID}      11
${BIP_TAG}    8322_bip
${BIP_TAG_1}    8322_bip_1
&{GNBMIRRORINGCONFIGS}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'
...    NUMBER_OF_FILES=30
${PROFILE1}    ue_measurement_send_nr id\=11 meas_id\=3 event\=A1 srsrp_nr\=11 srsrq_nr\=11 scell\=9 scell_rsrp\=100 scell_rsrq\=100
${PROFILE2}    ue_measurement_send_nr id\=11 meas_id\=4 event\=A1 srsrp_nr\=11 srsrq_nr\=11 scell\=9 scell_rsrp\=100 scell_rsrq\=100


*** Test Cases ***
CB009928_C_B2_311_A1_measurement_based_Pcell_switch_from_T_to_F_NSA_DL_2CC_CA_KPI_PMCounter
    Add RD
    Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
    Prepare gnb onair
    Start capture gnb and ap syslog in 'SA_ue' file
    Attach LTE UE
	UE11 handover to FDD scell
	UE11 handover to TDD scell
    Stop capture gnb and ap syslog in 'SA_ue' file
    
*** Keywords ***
Add RD
	Add GNB swconfig    0x9D0000:15		#whether to skip FR1 CA UE on FDD SCell for slot (symbol 6) CB
	Wts Execute Aashell Command   
	...   confmgmtdefscli set --domain NrUeDlPhy --name radPdcchApplyToSeparateStreams_AP --value 1 --change-type persistent --timeout 5

#==========NSA=======================
Execute AP Command before attach
    airphone_cleanup_egate_console_log
    Airphone Setup X2 Connection
 
Attach LTE UE
    Execute AP Command before attach
    Airphone Nsa Attach    ${UE_ID}
    NSA send ue '${UE_ID}' mutiple trf '7' for each '175M' DL data
    Wait '3s' for stabible
    airphone_execute_egate_command    ue_measurement_send_nr id\=11 meas_id\=2 event\=A1 srsrp_nr\=100
    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_data_UE_${UE_ID}   unzip=TRUE
    Wait '3s' for stabible
    Start collect ttitrace
    Wait for '1s' to stop ttitrace with name'tti'
    Start collect bip log for LOOO
    Wait for '1s' to stop bip log with name'bip'	

#check tti
Check ttitrace
    Log To Console    Check Bler
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_ul.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti1_dl.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti1_ul.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti3_dl.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti3_ul.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
	
#check RRC
check UE '${ue_id}' SRS in RRC log
    Log To Console   check UE ${ue_id} SRS in RRC log
    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}   unzip=TRUE
    run keyword and continue on failure    check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/ini/RRC_ue${ue_id}_case3.ini    log_need_to_check=p
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}

Start collect UE f1ap
    [Arguments]     ${bip_file}
    Log To Console    Start collect '${bip_file}' tcpdump
    ${executor_oam_vm}    Create Dictionary    host=192.168.255.1    user=toor4nsn    password=oZPS0POrRieRtu
    Start Tcpdump    name=${bip_file}    options= -i any -C 300    remote_info=${executor_oam_vm}

Stop collect UE f1ap
    [Arguments]     ${bip_file}
    Log To Console    Stop collect '${bip_file}' tcpdump
    Stop Tcpdump    ${bip_file}    ${TEST_LOG_DIRECTORY()}/All/${bip_file}
	
check UE f1ap bip
    [Arguments]     ${bip_title}		
    Log To Console   ${\n}---check bip---
    Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/${bip_title}/${bip_title}.pcap
    ...    ${TEST_LOG_DIRECTORY()}/All/${bip_title}/${bip_title}.csv    ${FILTER_f1ap}    ${titles_f1ap}
    Check Log With Au2anlysis    ${CURDIR}/ini/f1ap_case41.ini     i    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${bip_title}

set sctp rto time
    ${output}=    Run    sudo sysctl -w net.sctp.rto_min=100
                                                                                                            
UE11 handover to TDD scell
    airphone_cleanup_egate_console_log
    airphone_execute_egate_command    ue_meas_cfg_disp id\=11 meas_obj_type\=nr
    airphone_execute_egate_command    ${PROFILE1}
	Get And Validate Countersft
    Wait '3s' for stabible	
    airphone_execute_egate_command    ue_measurement_send_nr id\=11 meas_id\=5 event\=A1 srsrp_nr\=120
    Wait '3s' for stabible
    Start collect ttitrace
    Wait for '1s' to stop ttitrace with name'tti3'
    Start collect bip log for LOOO
    Wait for '1s' to stop bip log with name'bip3'
	Check handover f_t
	
UE11 handover to FDD scell
    airphone_cleanup_egate_console_log
    airphone_execute_egate_command    ue_meas_cfg_disp id\=11 meas_obj_type\=nr
    airphone_execute_egate_command    ${PROFILE2}
	Get And Validate Counterstf
    Wait '3s' for stabible
    airphone_execute_egate_command    ue_measurement_send_nr id\=11 meas_id\=5 event\=A1 srsrp_nr\=120
    Start collect ttitrace
    Wait for '1s' to stop ttitrace with name'tti1'
    Start collect bip log for LOOO
    Wait for '1s' to stop bip log with name'bip1'    
	Check handover t_f

Check handover f_t
    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_1_HO_ft   unzip=TRUE
    run keyword and continue on failure    check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/ini/handover_ft_nsa.ini    log_need_to_check=u
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_1_HO_ft

Check handover t_f
    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_1_HO_tf   unzip=TRUE
    run keyword and continue on failure    check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/ini/handover_tf_nsa.ini    log_need_to_check=u
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_1_HO_tf

Get And Validate Countersft
    #[Arguments]    ${save_log}
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}
    ${value_M55145C02005}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55145C02005    cell_id=4
	${value_M55145C02006}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55145C02006    cell_id=4
    ${value_M55145C02007}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55145C02007    cell_id=4
	${value_M55145C02008}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55145C02008    cell_id=4
    ${value_M55145C02009}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55145C02009    cell_id=4
	${value_M55145C02010}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55145C02010    cell_id=4
    ${value_M55145C02011}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55145C02011    cell_id=4
	${value_M55145C02012}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55145C02012    cell_id=4		
    should be true    ${value_M55145C02005} == 1
    should be true    ${value_M55145C02006} == 0
    should be true    ${value_M55145C02007} == 0
    should be true    ${value_M55145C02008} == 0
    should be true    ${value_M55145C02009} == 0
    should be true    ${value_M55145C02010} == 0
    should be true    ${value_M55145C02011} == 0
    should be true    ${value_M55145C02012} == 0

Get And Validate Counterstf
    #[Arguments]    ${save_log}
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}
    ${value_M55145C02005}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55145C02005    cell_id=1
	${value_M55145C02006}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55145C02006    cell_id=1
    ${value_M55145C02007}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55145C02007    cell_id=1
	${value_M55145C02008}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55145C02008    cell_id=1
    ${value_M55145C02009}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55145C02009    cell_id=1
	${value_M55145C02010}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55145C02010    cell_id=1
    ${value_M55145C02011}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55145C02011    cell_id=1
	${value_M55145C02012}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55145C02012    cell_id=1		
    should be true    ${value_M55145C02005} == 1
    should be true    ${value_M55145C02006} == 0
    should be true    ${value_M55145C02007} == 0
    should be true    ${value_M55145C02008} == 0
    should be true    ${value_M55145C02009} == 0
    should be true    ${value_M55145C02010} == 0
    should be true    ${value_M55145C02011} == 0
    should be true    ${value_M55145C02012} == 0
