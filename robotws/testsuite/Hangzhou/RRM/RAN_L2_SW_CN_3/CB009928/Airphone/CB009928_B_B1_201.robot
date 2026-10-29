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
${SCFC_NAME}      SCFC_9928_A2_Switch.xml
${AIRPHONE_NAME}    IPHY_4T_8x4.xml
${WTS_NAME}    WTS_9928_4T.cfg

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
${UE_NUM_SA}      7
${BIP_TAG}    8322_bip
${BIP_TAG_1}    8322_bip_1
&{GNBMIRRORINGCONFIGS}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'
...    NUMBER_OF_FILES=30
${PROFILE1}    ue_measurement_send_nr id\=1 meas_id\=4 event\=A2 srsrp_nr\=11 srsrq_nr\=11 scell\=1 scell_rsrp\=100 scell_rsrq\=100
${PROFILE2}    ue_measurement_send_nr id\=1 meas_id\=8 event\=A6 srsrp_nr\=11 srsrq_nr\=11 scell\=1 scell_rsrp\=20 scell_rsrq\=20 
...    phycell_id\=52 nrsrp_nr\=63 nrsrq_nr\=20


*** Test Cases ***
CB009928_B_B1_201_A2_measurement_based_Pcell_switch_from_T_to_T_SA_DL_3CC_CA
    Add RD
    Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
    Prepare gnb onair
    Start capture gnb and ap syslog in 'SA_ue' file
    UE1 SA Register
    Stop capture gnb and ap syslog in 'SA_ue' file
    
*** Keywords ***
Add RD
	Add GNB swconfig    0x9D0000:15		#whether to skip FR1 CA UE on FDD SCell for slot (symbol 6) CB
	Wts Execute Aashell Command   
	...   confmgmtdefscli set --domain NrUeDlPhy --name radPdcchApplyToSeparateStreams_AP --value 1 --change-type persistent --timeout 5
 
UE1 SA Register
    UE from '1' to '1' SA Register
    DL and UL data to '1' for dl_trf '13'
    Start collect ttitrace
    Wait for '1s' to stop ttitrace with name'tti'
    Start collect bip log for LOOO
    Wait for '1s' to stop bip log with name'bip'
    scell A1 addition
    UE1 handover to TDD scell
	UE1 scell swap
    SA DeRegister UE '1'
	Check ttitrace

scell A1 addition
    airphone_execute_egate_command    ue_meas_cfg_disp id\=1 meas_obj_type\=nr
    airphone_execute_egate_command    ue_measurement_send_nr id\=1 meas_id\=3 event\=A1 srsrp_nr\=120
    Wait '10s' for stabible
    Start collect ttitrace
    Wait for '1s' to stop ttitrace with name'tti1'
    Start collect bip log for LOOO
    Wait for '1s' to stop bip log with name'bip1'
	
UE send RANK4
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=3 cqi\=15 cqi_mode\=fixed ri\=3 ri_mode\=fixed
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=3 scell\=0-1

SA DeRegister UE '${ue}'
    airphone_sa_detach    ue_id=${ue}    timeout=5
	
#==========SA=======================
UE from '${lo}' to '${hi}' SA Register
	FOR    ${ue}    IN RANGE    ${lo}    ${hi}+1
       airphone_cleanup_egate_console_log
       Log To Console   ${\n}-----register UE ${ue} ------
       SA Register UE ${ue}
       airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue}   unzip=TRUE	
    END
	 
SA Register UE ${UE_ID}
	Airphone SA Attach    ue_id=${UE_ID}
	Airphone Set Traffic Type    ${UE_ID}    ${UE_ID}    internal
	Airphone Pdu Session Setup   ${UE_ID}    ${UE_ID}    1    ${UE_ID}
	Wait '5s' for stabible	

Get SA '${ue}' crnti in RRC log
    Log To Console   check UE RRC log to get ue crnti
    ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue}_HO/egate_console.log.001   crnti: (\\d+)
    [return]     ${rnti_list[0]}

SA send data '${UE_NUM_SA}' UEs
    FOR    ${num}    IN RANGE    2    ${UE_NUM_SA}+1
        SA send mutiple trf dl data    ${num}    1    20M   ${num}
        SA send mutiple trf ul data    ${num}    1    50M    ${num}
    END
     
DL and UL data to '${UE_ID}' for dl_trf '${num}'
    Log To Console    DL*13 and UL*1 data  to UE ${UE_ID}
	airphone_cleanup_egate_console_log	
    FOR    ${i}    IN RANGE    1    ${num}+1
     	Airphone SA Start Data Traffic    ${UE_ID}   DL   175M   pdu_id=${UE_ID}   duration=3600   trf_id=${i}  
    END
    Airphone SA Start Data Traffic    ${UE_ID}   UL   100M    pdu_id=${UE_ID}   duration=3600   trf_id=1
    Wait '4s' for stabible
    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_data_UE_${UE_ID}   unzip=TRUE	

DL and UL data to '${UE_ID}' little
    Log To Console    DL*4 and UL*3 data  to UE ${UE_ID}
    airphone_cleanup_egate_console_log	
    Airphone SA Start Data Traffic    ${UE_ID}   DL   50M    pdu_id=${UE_ID}   duration=3600   trf_id=1  
    Airphone SA Start Data Traffic    ${UE_ID}   UL   50M    pdu_id=${UE_ID}   duration=3600   trf_id=1
    Wait '4s' for stabible
    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_data_UE_${UE_ID}   unzip=TRUE	
	
check throughput from SA UE '${low}' to '${hi}' with tp '${dl_cell_tp}'
	${cell_tp_dl}	  evaluate	0
    FOR    ${num}    IN RANGE    ${low}    ${hi}+1
       Log To Console    Check throughput UE${num}
          ${dl_tput_kb}=    airphone_get_throughput_on_specific_scell    ${num}    0    type=pdsch    tput_type=ave
          ${dl_tput_Mb}    evaluate    ${dl_tput_kb}/1000
          Log To Console		dl ${dl_tput_Mb}
          ${cell_tp_dl}    evaluate    ${cell_tp_dl}+${dl_tput_Mb}
    END
    Log To Console		=====dl_cell_tp ${cell_tp_dl}=====
    run keyword and continue on failure    should be true    ${cell_tp_dl}>=${dl_cell_tp}

DeRegister UE from '${low}' to '${hi}'
    FOR    ${num}    IN RANGE    ${low}    ${hi}+1
       airphone_sa_detach    ue_id=${num}    timeout=5
       Wait '3s' for stabible
    END

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
                                                                                                            
UE1 handover to TDD scell
    airphone_cleanup_egate_console_log
    airphone_execute_egate_command    ue_meas_cfg_disp id\=1 meas_obj_type\=nr
    airphone_execute_egate_command    ${PROFILE1}
    Wait '3s' for stabible	
    airphone_execute_egate_command    ue_measurement_send_nr id\=1 meas_id\=6 event\=A1 srsrp_nr\=120
    Wait '3s' for stabible
    Start collect ttitrace
    Wait for '1s' to stop ttitrace with name'tti2'
    Start collect bip log for LOOO
    Wait for '1s' to stop bip log with name'bip2'
	Check handover t_t
	
UE1 scell swap
    airphone_cleanup_egate_console_log
    airphone_execute_egate_command    ue_meas_cfg_disp id\=1 meas_obj_type\=nr
    airphone_execute_egate_command    ${PROFILE2}
    Wait '3s' for stabible
    Start collect ttitrace
    Wait for '1s' to stop ttitrace with name'tti3'
    Start collect bip log for LOOO
    Wait for '1s' to stop bip log with name'bip3'    
	Check scell swap

Check handover t_t
    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_1_HO_tt   unzip=TRUE
    run keyword and continue on failure    check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/ini/handover_tt.ini    log_need_to_check=u
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_1_HO_tt

Check scell swap
    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_1_swap   unzip=TRUE
    run keyword and continue on failure    check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/ini/tdd_scell_swap.ini    log_need_to_check=p
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_1_swap
