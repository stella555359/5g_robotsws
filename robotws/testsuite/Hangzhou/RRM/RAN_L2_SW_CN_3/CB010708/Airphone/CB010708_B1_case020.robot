*** Settings ***
Documentation     Author: mao.qin@nokia-sbell.com
...
...               QC case full name:
...               CB010708_B1_case020_8RX_PUCCH_receiver_F1_F3_1116_3ms_beamSet_6_PM_counter
...               change to frame 5GC001070
...

Test Timeout    240 minutes
Suite Setup        Common Suite Setup
#Suite Teardown    Common Suite Teardown
Test Setup         Common Test Setup
Test Teardown      Common Test Teardown
Force Tags    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_mqin    CLOUD_5G_I_MP_AP_LO

Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot
Library     taf.transport.ssh    WITH NAME    TAF_SSH
Library     ta_a2a

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}          scfc_10708_B1_case020.xml
${AIRPHONE_NAME}      10708_iphy_TDD_eCPRI_7_2e.xml
${WTS_NAME}           10887basic_setup_TDD_eCPRI_7_2e.cfg
@{LOG_NAME_LIST}    egatelog    gnb_snapshot
#sosreport    

${ECPRI72E}	   Ecpri72eUL
${BETAEC}	   13
${XEC}	       14

${PROFILE1}    beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=3,0,1,2 ssbeam_bestbeam=3 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-50
${SET_PROFILE1}    ue_testmode_set_nr id=1 testmode=beam_control action=activate profile_id=1 beamaction=attach

${PROFILE2}    ul_ue_beam_pos_nr profile_id=2 power=-200,-200,-200,-200,-200,-200,-200,-200
${SET_PROFILE2}    ue_testmode_set_nr id=1 testmode=ue_ul_beam_position action=activate profile_id=2

${PROFILE3}    ul_ue_beam_pos_nr profile_id=3 power=-600,-600,-600,-600,-600,-600,-600,-600
${SET_PROFILE3}    ue_testmode_set_nr id=1 testmode=ue_ul_beam_position action=activate profile_id=3

${PROFILE4}    ul_ue_beam_pos_nr profile_id=1 num_beam_paths=2 azimuth=-70,70 zenith=-40,40 power=-849,-130
${SET_PROFILE4}    ue_testmode_set_nr id=1 testmode=ul_ue_beam_pos_nr action=activate profile_id=4


${pattern1}    CA_P2_8x4_t2r4_n2

*** Test Cases ***
CB010708_B1_case020_8RX_PUCCH_receiver_F1_1116_0ms_beamSet_2_2_PM_counter_NSA
    Step1:Commission configurations on WebUI
    Step2:Attach UE1
    Step3:Send DL UL data
    Step4:Stop UL data

*** Keywords ***
Step1:Commission configurations on WebUI
    Get and Update BSR File    par_of_bsr_name=BSR_AVQL_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00002
    Modify vendor file 72e and full commission for onair

Step2:Attach UE1
    Start capture GNB and AP Syslog in 'Step2_attach' File	
    ${capacity_units}=  Create List    ABIO
    Configure Bip Collection   l1_type=FS
    ...                        gNB_common_unit=ASIB
    ...                        gNB_capacity_units=${capacity_units}
    ...                        use_script=True
    ...                        script_parameters=--bb_slot_1='true' --bb_slot_2='false' --bb_slot_3='false'

    Airphone Execute Egate Command    ${PROFILE2}
    Airphone Execute Egate Command    ${SET_PROFILE2}

    #Start Bip Trace
    #Start GNB Ttitrace With Streaming Mode
    run keyword and continue on failure    Attach UE to cell1    1    ${pattern1}
    run keyword and continue on failure    Send trf for UE    1    DL    10M    1
    Wait '1s' for stable
    #${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
    #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    #Stop Bip Trace   target_dir=${save_log}
    #Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
	[Teardown]    Stop capture GNB and AP Syslog in 'Step2_attach' File
	
Step3:Send DL UL data
    Start capture GNB and AP Syslog in 'Step3_Send_DL_UL_data' File	
    run keyword and continue on failure    Send trf for UE    1    DL    150M    8
    run keyword and continue on failure    Send trf for UE    1    UL    150M    2
    Wait '2000s' for stable
    #Start Bip Trace
    Start GNB Ttitrace With Streaming Mode
    Wait '2s' for stable
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_Send_DL_UL_data
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    #Stop Bip Trace   target_dir=${save_log}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
    run keyword and continue on failure
    ...    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/CB010708_B1_case020_step3_dl_tti.ini    log_need_to_check=i
    ...    save_log_directory=${save_log}
    run keyword and continue on failure
    ...    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/CB010708_B1_case020_step3_ul_tti.ini    log_need_to_check=i
    ...    save_log_directory=${save_log}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}conter_files${/}
    ${DL_throughput}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55309C12001    cell_id=1
    ${UL_throughput}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55309C12002    cell_id=1
    ${DL_tput}    evaluate    ${DL_throughput}*8/1024/1024
    ${UL_tput}    evaluate    ${UL_throughput}*8/1024/1024
    run keyword and continue on failure    should be true    ${DL_tput} > 750
    run keyword and continue on failure    should be true    ${UL_tput} > 200
	[Teardown]    Stop capture GNB and AP Syslog in 'Step3_Send_DL_UL_data' File

Step4:Stop UL data
    Start capture GNB and AP Syslog in 'Step4_Stop_UL_data' File	
    Stop UE Traffic    1    UL
    Wait '2000s' for stable
    #Start Bip Trace
    Start GNB Ttitrace With Streaming Mode
    Wait '10s' for stable
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_Stop_UL_data
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    #Stop Bip Trace   target_dir=${save_log}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
    run keyword and continue on failure
    ...    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/CB010708_B1_case020_step3_dl_tti.ini    log_need_to_check=i
    ...    save_log_directory=${save_log}
    run keyword and continue on failure
    ...    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/CB010708_B1_case020_step4_ul_tti.ini    log_need_to_check=i
    ...    save_log_directory=${save_log}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}conter_files${/}
    ${DL_throughput2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55309C12001    cell_id=1
    ${PUCCH_F1_nonDTX}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55303C14001    cell_id=1
    ${PUCCH_F1_DTX}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55303C13001    cell_id=1
    ${PUCCH_F3_nonDTX}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55303C18001    cell_id=1
    ${PUCCH_F3_DTX}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55303C17001    cell_id=1
    ${DL_tput2}    evaluate    ${DL_throughput2}*8/1024/1024
    ${PUCCH_F1_DTX_ratio}    evaluate    ${PUCCH_F1_DTX}/(${PUCCH_F1_DTX}+${PUCCH_F1_nonDTX})
    ${PUCCH_F3_DTX_ratio}    evaluate    ${PUCCH_F3_DTX}/(${PUCCH_F3_DTX}+${PUCCH_F3_nonDTX})
    run keyword and continue on failure    should be true    ${DL_tput2} > 750
    run keyword and continue on failure    should be true    ${PUCCH_F1_DTX_ratio} < 0.007
    run keyword and continue on failure    should be true    ${PUCCH_F3_DTX_ratio} < 0.01
	[Teardown]    Stop capture GNB and AP Syslog in 'Step4_Stop_UL_data' File

	
Modify vendor file 72e and full commission for onair
    [Arguments]    ${wait_bts_timeout}=2000    ${wait_rru_timeout}=800    ${wait_onair_timeout}=800
    Modify Swconfig for AP
    Start capture gnb and ap syslog in 'before_onair' file
    Change iphy rru version    ${CONFIG_DIR_PATH}/${SW_BRANCH}/WTS/${AIRPHONE_NAME}
    OperatingSystem.Run And Return Rc And Output
    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} 'reboot'
    Wait '10s' for stable
    ${scfc_path}    Set variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}/SCF/${SCFC_NAME}
    ${cfg_path}    Set variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}/WTS/${WTS_NAME}
    ${new_scfc}    GNB_BASE.Change Vlan Id In Scfc    ${scfc_path}    ${test_log_directory()}/full_commission/
    Configure TL VM ETH
    TAF_ADMIN.Setup Admin
    ${vendor_path}    Set Variable    ${test_log_directory()}/vendor_ini.xml
    TAF_ADMIN.Download Vendor File    ${vendor_path} 
    Modify Vendor betaec XML File    ${vendor_path}
    Modify Vendor xec XML File    ${vendor_path} 
    Modify Vendor 72e XML File    ${vendor_path}
    TAF_ADMIN.Set Vendor File    ${vendor_path}
    ${connission_status}    Run Keyword And Return Status    TAF_ADMIN.Perform Commissioning
    ...    bts_id=${GNB_IP}
    ...    scf_file=${new_scfc}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=300     
    Log to console    Full Commissioning is ${connission_status}
    TAF_ADMIN.teardown admin
    Wait '120s' for stable
    Run Keyword And Ignore Error    Start collect 'cellsetup' tcpdump
    ${bts_status}=    Run Keyword And Return Status    Wait Unit Bts Configured    ${wait_bts_timeout}
    ${rru_status}=    Run Keyword And Return Status    Wait Until RRU Configured    ${wait_rru_timeout}
    ${onair_status}=    Run Keyword And Return Status    Start Wts And Wait Bts Until Onair     ${cfg_path}
    ...    timeout=${wait_onair_timeout}
    Stop capture gnb and ap syslog in 'before_onair' file
    Log To Console    BTS is onAir now
    Run Keyword And Ignore Error    Stop collect 'cellsetup' tcpdump

Modify Vendor 72e XML File 
    [Arguments]    ${vendor_path} 
    ${vendor_list72e}    Set Variable    text|${ECPRI72E}|//*[@name\="actEcpri72e"]  
    Modify Xml    ${vendor_path}    ${vendor_path}    ${vendor_list72e}    
Modify Vendor betaec XML File 
    [Arguments]    ${vendor_path}  
    ${vendor_listbetaec}    Set Variable    text|${BETAEC}|//*[@name\="betaEc"]  
    Modify Xml    ${vendor_path}    ${vendor_path}    ${vendor_listbetaec}      
Modify Vendor xec XML File 
    [Arguments]    ${vendor_path} 
    ${vendor_listxec}    Set Variable    text|${XEC}|//*[@name\="xEc"]  
    Modify Xml    ${vendor_path}    ${vendor_path}    ${vendor_listxec}       
Prepare test
    #Modify l1bypass
    #pdcch dftbeam
    Add GNB swconfig    0x580434:0
    Add GNB swconfig    0x450027:1
    Add GNB swconfig    0x5900B9:1

Attach UE to cell1
    [Arguments]    ${ue_id}    ${pattern}
    ${ue_ability}    Obtain Ue Capability    ${pattern}
    ${attach_status}=    run keyword and return status    Airphone SA Attach    ue_id=${ue_id}    timeout=60    ue_capability=${ue_ability}
    Run Keyword If    '${attach_status}'=='False'    Airphone SA Attach    ue_id=${ue_id}    timeout=60    ue_capability=${ue_ability}
    airphone_set_traffic_type    ${ue_id}    1    internal
    ${pdu_id}    evaluate    ${ue_id}%10+1
    ${pdu_status}=    run keyword and return status    Airphone Pdu Session Setup    ${ue_id}    1    1    ${pdu_id}
    #${newNum}=    evaluate    ${ue_id}+8
    Run Keyword If    '${pdu_status}'=='False'    Airphone Pdu Session Setup    ${ue_id}    1    1    5
    Wait '1s' for stable
	
2Attach UE to cell1
    [Arguments]    ${ue_id}
    #${ue_ability}    Obtain Ue Capability    ${pattern}
    ${attach_status}=    run keyword and return status    Airphone SA Attach    ue_id=${ue_id}    timeout=60
    Run Keyword If    '${attach_status}'=='False'    Airphone SA Attach    ue_id=${ue_id}    timeout=60
    airphone_set_traffic_type    ${ue_id}    1    internal
    ${pdu_id}    evaluate    ${ue_id}%10+1
    ${pdu_status}=    run keyword and return status    Airphone Pdu Session Setup    ${ue_id}    1    1    ${pdu_id}
    #${newNum}=    evaluate    ${ue_id}+8
    Run Keyword If    '${pdu_status}'=='False'    Airphone Pdu Session Setup    ${ue_id}    1    1    5

Send trf for UE
    [Arguments]    ${ue_id}    ${DLorUL}    ${mbps}    ${number}
    FOR    ${num}    IN RANGE    1    ${number}+1
        Airphone SA Start Data Traffic    ${ue_id}    ${DLorUL}    ${mbps}    pdu_id=1    duration=10800s    trf_id=${num}
    END
	
Attach UE to cell NSA
    [Arguments]    ${ue_id}    ${pattern}
    ${ue_ability}    Obtain Ue Capability    ${pattern}
    ${attach_status}=    run keyword and return status    Airphone NSA Attach    ue_id=${ue_id}    timeout=60    ue_capability=${ue_ability}
    Run Keyword If    '${attach_status}'=='False'    Airphone SA Attach    ue_id=${ue_id}    timeout=60    ue_capability=${ue_ability}
    airphone_set_traffic_type    ${ue_id}    1    internal
    ${pdu_status}=    run keyword and return status    Airphone Pdu Session Setup    ${ue_id}    1    1    ${ue_id}
    ${newNum}=    evaluate    ${ue_id}+8
    Run Keyword If    '${pdu_status}'=='False'    Airphone Pdu Session Setup    ${ue_id}    1    1    ${ue_id}
    Wait '1s' for stable

Send trf for UE NSA
    [Arguments]    ${ue_id}    ${DLorUL}    ${mbps}    ${number}
    FOR    ${num}    IN RANGE    1    ${number}+1
        Airphone Nsa Start Data Traffic    ${ue_id}    ${DLorUL}    ${mbps}    trf_id=${num}    bearer_id=2    duration=3600
    END
	
Detach UE
    [Arguments]    ${ue_id}
    airphone_sa_detach    ue_id=${ue_id}    timeout=30

Stop UE Traffic
    [Arguments]    ${ue_id}    ${DLorUL}
    airphone_sa_stop_data_traffic    ${ue_id}    ${DLorUL}
