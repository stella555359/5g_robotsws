*** Settings ***
Documentation
...

Test Timeout    120 minutes
Suite Setup    Common Suite Setup
#Suite Teardown    Common Suite Teardown
Test Setup    Common Test Setup
Test Teardown    Common Test Teardown
Force Tags    owner_menzheng    AP    SBTS00    RAN_5G_TDD    RAN_5G    CLOUD_5G_I_lO_AP_LO
Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot


*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}      SCFC_LBT27919_ITW_CB009355.xml
${AIRPHONE_NAME}    IPHY_AEHC_ITW_CB009355.xml
${WTS_NAME}    basic_setup_LBT27919_ITW_CB009355.cfg

@{LOG_NAME_LIST}    gnb_snapshot    egatelog
${FILTER_f1ap}    itf_l2_ps_user_usersetupreq
@{titles_f1ap}    3gpp.rnti    itf_l2_ps_UeCapability.dlShortTermBeamformingCapability_item
${FILTER}    DlData_CsiRsResourceL1sw_t.csiRsScramblingSequenceInt
@{titles}    DlData_CsiRsResourceL1sw_t.trsInfo    DlData_CsiRsResourceL1sw_t.startPrb    DlData_CsiRsResourceL1sw_t.numOfPrb
${BIP_TAG}    8322_bip
${BIP_TAG_1}    8322_bip_1
&{GNBMIRRORINGCONFIGS}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'
...    NUMBER_OF_FILES=30


*** Test Cases ***
LBT27919_PR778185_ITW_CB009355_CB009915_CB007552
    Prepare gnb onair
    Start capture gnb and ap syslog in 'SA_ue' file
    Start Bip Trace
    UE1 SA Register to largebwp
    UE2 SA Register to smallbwp
    Stop Bip Trace   ${TEST_LOG_DIRECTORY()}/All/bipnotraffic
    Send DL and UL data
    check throughput from SA UE '1' to '2' with tp '100'
    Start collect ttitrace
    Wait for '1s' to stop ttitrace with name'tti'
    Start Bip Trace
    Wait '1s' for stabible
    Stop Bip Trace   ${TEST_LOG_DIRECTORY()}/All/biptraffic
    Check startPrb and numOfPrb in BIP    bipnotraffic
    Check startPrb and numOfPrb in BIP    biptraffic
    Check ttitrace
    Get And Validate Counters
    DeRegister UE from '1' to '2'
    Stop capture gnb and ap syslog in 'SA_ue' file

*** Keywords ***
Add RD
    Add GNB swconfig    0x9D0000:3		#whether to skip FR1 CA UE on FDD SCell for slot (symbol 6) CB

UE1 SA Register to largebwp
    UE from '1' to '1' SA Register
	run keyword and continue on failure    check_log_with_au2anlysis
      ...    ini_path=${CURDIR}/ini/startingRB_nrofRBs_ITW_CB009355_UE1.ini    log_need_to_check=p
      ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_1			#check RRC

UE2 SA Register to smallbwp
    UE from '2' to '2' SA Register
	run keyword and continue on failure    check_log_with_au2anlysis
      ...    ini_path=${CURDIR}/ini/startingRB_nrofRBs_ITW_CB009355_UE2.ini    log_need_to_check=p
      ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_2			#check RRC

Send DL and UL data
    SA send data '2' UEs
    Wait '10s' for stabible

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
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
        SA send mutiple trf dl data    ${num}    2    125M   ${num}
        SA send mutiple trf ul data    ${num}    1    50M    ${num}
    END

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
    run keyword and continue on failure    should be true    ${cell_tp_dl}>=${dl_cell_tp}	#167.7_168.6_251.9_189.3

DeRegister UE from '${low}' to '${hi}'
    FOR    ${num}    IN RANGE    ${low}    ${hi}+1
       airphone_sa_detach    ue_id=${num}    timeout=5
       Wait '3s' for stabible
    END

#check tti
Check ttitrace
    Log To Console    Check Bler in ttiTrace
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_ul.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All

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

Check startPrb and numOfPrb in BIP
    [Arguments]	${bip_title}
	Merge_pcaps    ${bip_title}
    run keyword and continue on failure    Convert BIP To CSV    ${test_log_directory()}/All/${bip_title}/bip_out.pcap
    ...    ${test_log_directory()}/All/${bip_title}/bip_check.csv    ${FILTER}    ${titles}
    run keyword and continue on failure    Check Log With Au2anlysis    ini_path=${CURDIR}/ini/startprb_numofprb_ITW_CB009355.ini
    ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${bip_title}

Get And Validate Counters
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}counter
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
    ${time}    Evaluate    type(${remaining_time})
    ${remaining_time}     evaluate     ${remaining_time}+300
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${save_log}${/}
    ${value_M55308C29001}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55308C29001    cell_id=1
    ${value_M55308C29003}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55308C29003    cell_id=1
    ${value_M55308C00085}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55308C00085    cell_id=1
    ${value_M55308C29005}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55308C29005    cell_id=1
	should be true    ${value_M55308C29001} > 0
    should be true    ${value_M55308C29003} > 0
    should be true    ${value_M55308C29005} == 0

Merge_pcaps
    [Arguments]     ${bip_title}
	TAF_SSH.Connect To    127.0.0.1    ute    ute    alias=bsh
	TAF_SSH.Execute    cd    connection=bsh
	TAF_SSH.Send Command    cd ${test_log_directory()}/All/${bip_title};mergecap -w bip_out.pcap *.pcap    connection=bsh


