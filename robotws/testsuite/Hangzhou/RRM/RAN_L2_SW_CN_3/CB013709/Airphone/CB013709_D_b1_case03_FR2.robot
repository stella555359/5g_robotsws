*** Settings ***
Documentation     Author:
...
Test Timeout      120 minutes
Suite Setup       Common Suite Setup
#Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_LO_AP_LOD    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G

Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot


*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}          scfc_13709_case03.xml
${AIRPHONE_NAME}      iphy_13709_case03.xml
${WTS_NAME}           wts_13709_case03.cfg
#${COMAVALUE}          ${CURDIR}/../../resources/sg11/internal_resource/config/AP/ap_coma.txt
@{LOG_NAME_LIST}      gnb_snapshot    egatelog

${UE_ID1}          1
${PDU_ID1}         1
${GW_ID1}          1
${SLICE_ID}       1
${UE_NUM_SA}         5
${UE_NUM_SA_VONR}         2
${UE_NUM_NSA}        2
${UE_NUM_NSA_ID}        12
${EGATE_TAG}      MUmimo
${TTI_TAG}      tti
${TTI_TAG_BLER}      tti_bler
&{GNBMIRRORINGCONFIGS}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'
...    NUMBER_OF_FILES=30
#LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
@{Rdparameter}    0x420062:1  0x800057:0
${par_of_bsr_name}       BSR_AEHC_6_H6_ALN60
${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=1 step\=5 trigger_puxch_update\=0 test_type=SRS
${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0 test_type=SRS
${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 step\=5 trigger_puxch_update\=0 test_type=SRS
${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0 test_type=SRS
${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=1 step\=5 trigger_puxch_update\=0 test_type=SRS
${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0 test_type=SRS
${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=1 step\=5 trigger_puxch_update\=0 test_type=SRS
${PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id\=8 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0 test_type=SRS
${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
${SET_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
${SET_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
${SET_PROFILE5}    ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5
${SET_PROFILE6}    ue_testmode_set_nr id\=6 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=6
${SET_PROFILE7}    ue_testmode_set_nr id\=7 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=7
${SET_PROFILE8}    ue_testmode_set_nr id\=8 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=8


*** Test Cases ***
CB013709_D_b3_case08_Verfication_actPdcpRlcBufCongOvlMech_bufferOverflow_PDCP_RLC_buffer_congestion_Counter
    Add RD parameter
    Add 13079 config
    Get and Update BSR File    par_of_bsr_name=BSR_AEHC_6_H5H1_ALN60_ARP60_P00_COVERAGE_00448_00001
    Prepare gnb onair
    Execute AP Command before attach
    Start capture gnb and ap syslog in 'after_onair' file
    Attach '${UE_NUM_SA}' SA UE
    Send Non GBR data to SA UE
    Start collect f1ap    cplane
    Add bearer for all UEs
    Stop collect f1ap    cplane

    Collect AP egate log    ${EGATE_TAG}

    [Teardown]    Stop capture gnb and ap syslog in 'after_onair' file

*** Keywords ***

step3:site reset and check starup time
    ${total_times}     set variable    10
    ${pre_times}    set variable    0
    :FOR    ${times}    IN RANGE    0    ${total_times}
        Perform BTS Site Reset
        Wait '30s' for stabible
        ${start_time}=    Get Time    epoch
        Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair
        ${end_time}=    Get Time    epoch
        ${execution_time}=    Evaluate    ${end_time}-${start_time}
        ${delta}    Evaluate    ${execution_time} - ${pre_times} if ${pre_times} != 0 else 0
        ${previous_time}    Set Variable    ${execution_time}
    END

    ${start_time_1}=    Get Time    epoch
    Wait Until Keyword Succeeds     ${timeout}     15     _sim_state_is_active
    ${end_time_1}=    Get Time    epoch
    ${used_time_1}=    Evaluate    ${end_time_1}-${start_time_1}
    ${timeout_1}=    Evaluate    ${timeout}-${used_time_1}
    Airphone Get Gnb Id
    ${cell_id_list}=    Airphone Get Cell Id List
    ${used_time_2}=    Set Variable    0
    : FOR    ${cell_id}    IN    @{cell_id_list}
    \    ${timeout_2}=    Evaluate    ${timeout_1}-${used_time_2}
    \    ${start_time_2}=    Get Time    epoch
    \    Airphone Wait Until Sib1 Received    cell_id=${cell_id}    timeout=${timeout_2}
    \    ${end_time_2}=    Get Time    epoch
    \    ${used_time_2}=    Evaluate    ${end_time_2}-${start_time_2}

Check UE '${num}' rrc log aperidic
    Airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/egate_UE_${num}    unzip=TRUE
    ${ret}     file match all       ${TEST_LOG_DIRECTORY()}/All/egate_UE_${num}/egate_console.log    .*crnti: (\\d+)
    set suite variable     ${ue_rnti}    ${ret[0]}
    run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/RRC_AperidicSRS_SA.ini    log_need_to_check=p
   ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_${num}


check TP and bler with ttitrace
    [Arguments]    ${throughput}    ${time_avg}    ${tti_file}    ${ini_file}
    ${a}  get_ues_tbsize_by_sfn   ${test_log_directory()}/All/${tti_file}/tti_dl.csv
    ...        ${test_log_directory()}/All/${tti_file}/tti_dl_new.csv   ${time_avg}   filter=dlFdSchedData.ackNack\=ACK
    @{keys}  Get Dictionary Keys   ${a}
    FOR      ${key}     IN     @{keys}
        ${result}   evaluate  ${a[${key}]}/${time_avg}/1024/1000
        log to console   result is ${result}
        log to console   TP is ${throughput}
        should be true  ${result}>${throughput}
    END

    Log To Console    ${ini_file}
#    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${ini_file}.ini    log_need_to_check=i
#    ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_file}/


Add 13079 config
	#0x580962 = 0 #CB013709 -A: rdActExtendedUpOverloadHandling
    Add GNB swconfig    0x5a0605:1 #rdDebugBufferConsumption
    Add GNB swconfig    0x5a008f:1 #rdBufferCongestionTracingEnabled
    Add GNB swconfig    0x5a0616:1 #rdDebugPacketRetention
    Add GNB swconfig    0x5902CA:1 #rdEnableCB013709DUpd001
    Add GNB swconfig    0x5902BA:1 #rdEnableCB013709
    Add GNB swconfig    0x6601EF:1 #rdEnableCB013709
    Add GNB swconfig    0x6601F0:1 #rdEnableCB013709DUpd001
    Add GNB swconfig    0x5A0614:1 #rdDebugBearerManagement
    Add GNB swconfig    0x5A0605:1 #rdDebugBufferConsumption
    Add GNB swconfig    0x5A0616:1
    Add GNB swconfig    0x5B0615:1




Check SA UE throughput
    Wait until keyword succeeds    60s    5s    Verify multi SA UEs throughput

Verify multi SA UEs throughput
    FOR    ${num}    IN RANGE    1    8+1
        ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
        Run Keyword If    ${num}!=${7} and ${num}!=${8}    should_be_true    ${dl_throughput_pcell}>200000
    END

Add RD parameter
     Add GNB swconfig    0x9D0000:15
     #CP-RT log level (default 1 in 19B, 2 in 20A, 0 = disable 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
     Add GNB swconfig    0x590072:1
     #CP-NRT log level (avaiable after 19B, default = 2, 0 = disable 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
     Add GNB swconfig    0x41001b:1
     #CP-RT log level (default 1 in 19B, 2 in 20A, 0 = disable 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
     Add GNB swconfig    0x590072:1
     #CP-NRT log level (default = 2, 0 = disable 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
     Add GNB swconfig    0x66001b:1
     #CP-NB log level (default = 2, 0 = trace 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
     Add GNB swconfig    0x890001:1
     #CP-SB log level (default = 2, 0 = trace 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
     Add GNB swconfig    0x890002:1
     #CP-UE log level (default = 2, 0 = trace 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
     Add GNB swconfig    0x890003:1
     #CP-CL log level (default = 2, 0 = trace 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
     Add GNB swconfig    0x890004:1
     #CP-IF log level (default = 2, 0 = trace 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
     Add GNB swconfig    0x890005:1
     #CP-SCTP log level (default = 2, 0 = trace 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
     Add GNB swconfig    0x890006:1
     Add GNB swconfig    0x5B0605:1



Airphone SA Stop Data Traffic And Detach UE
     FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
        Airphone SA Detach    ue_id=${num}
     END


Attach '${UE_NUM_SA}' SA UE
     FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
       airphone_cleanup_egate_console_log
       Airphone SA Attach    ue_id=${num}
       Wait '2s' for stabible
       Airphone Set Traffic Type    ue_id=${num}    pdu_id= ${num}    type=internal
       Wait '2s' for stabible
       Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${num}   nwslice_id=1   gw_id=${num}
       Wait '2s' for stabible
       Collect AP egate log    ${EGATE_TAG}_${num}
       Wait '3s' for stabible
     END

UE PDU Session Modify to Add
  [Arguments]  ${ue_id}=1   ${pdu}=1   ${set_qosflow_id}=2    ${fiveQi}=1    ${qfi}=2
  ${ret1}=  airphone_execute_egate_command  ue_pdu_session_modify ue\=${ue_id} pdu\=${pdu} qosflows_to_add\=${set_qosflow_id} by\=amf
  ...  pass_regexp=QoS Routing Table
  Log To Console   fiveQi=${fiveQi}   qfi=${qfi}
#  Should Contain  ${ret1}  Created FiveQi:Qfi mapping fiveQi ${fiveQi} qfi ${qfi}
#  Should Contain  ${ret1}  discardTimer ms150

UE PDU Session Modify to Del
  [Arguments]  ${ue_id}=1  ${pdu}=1
  ${ret1}=  Execute Egate Command  ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_del=2 by=amf
  ...  rrcReconfigurationComplete
  Should Contain  ${ret1}  Removed FiveQi:Qfi mapping fiveQi 1 qfi 2

UE PDU Session Setup with Multi Qosflow
  [Arguments]  ${additional_qosflows_to_activate}=2  ${fiveQi_1}=5  ${fiveQi_2}=1  ${ue_id}=1  ${gw}=1  ${pdu}=1
  airphone_execute_egate_command  smf_param id\=1 reset
  airphone_execute_egate_command  smf_param id\=1 additional_qosflows_to_activate\=${additional_qosflows_to_activate}
  ${ret1}=  airphone_execute_egate_command  ue_pdu_session_setup pdu\=${pdu} ue\=${ue_id} nwslice\=1 gw\=${gw}
  ...  pass_regexp=QoS Routing Table
  Log To Console    fiveQi_1=${fiveQi_1}    fiveQi_2=${fiveQi_2}
#  Should Contain  ${ret1}  Created FiveQi:Qfi mapping fiveQi ${fiveQi_1} qfi 1
#  Should Contain  ${ret1}  Created FiveQi:Qfi mapping fiveQi ${fiveQi_2} qfi 2
  airphone_execute_egate_command  smf_param id\=1 reset

Send Non GBR data to SA UE
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
        SA send mutiple trf dl data    ${num}    1   175M   ${num}
#        SA send mutiple trf ul data    ${num}    1    20M   ${num}
    END

Send GBR data to SA UE
    [Arguments]  ${ue_id}=1  ${pdu}=1    ${qfi}=2
    airphone_execute_egate_command    trf_data_start ue\=${ue_id} pdu\=${pdu} qfi\=${qfi} trf_id\=5 mbps\=50 dir\=dl
#    airphone_execute_egate_command    trf_data_start ue\=${ue_id} pdu\=${pdu} qfi\=${qfi} trf_id\=5 mbps\=5 dir\=ul
    Wait '1s' for stabible

Add bearer for all UEs
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
        Add GBR bearer    ue_id=${num}    set_qfi_low=3    set_qfi_high=4    qfi_start=2
        Add nonGBR bearer    ue_id=${num}    set_qfi_low=8    set_qfi_high=10    qfi_start=4
    END
#        UE PDU Session Modify to Add    ue_id=1  pdu=1    set_qosflow_id=2    fiveQi=1    qfi=2
#        UE PDU Session Modify to Add    ue_id=1  pdu=1    set_qosflow_id=3    fiveQi=2    qfi=3
#    UE PDU Session Modify to Add    ue_id=1  pdu=1    set_qosflow_id=4    fiveQi=3    qfi=4
#    UE PDU Session Modify to Add    ue_id=1  pdu=1    set_qosflow_id=5    fiveQi=4    qfi=5
#    UE PDU Session Modify to Add    ue_id=1  pdu=1    set_qosflow_id=6    fiveQi=5    qfi=6
#    UE PDU Session Modify to Add    ue_id=1  pdu=1    set_qosflow_id=8    fiveQi=7    qfi=7
#    UE PDU Session Modify to Add    ue_id=1  pdu=1    set_qosflow_id=9    fiveQi=8    qfi=8
#    UE PDU Session Modify to Add    ue_id=1  pdu=1    set_qosflow_id=10    fiveQi=9    qfi=9
#    Send GBR data to SA UE   ue_id=1  pdu=1     qfi=2
#    Send GBR data to SA UE   ue_id=1   pdu=1    qfi=3
#    Send GBR data to SA UE   ue_id=1   pdu=1    qfi=4
#    Send GBR data to SA UE   ue_id=1   pdu=1    qfi=5
#    Send GBR data to SA UE   ue_id=1   pdu=1    qfi=6
#    Send GBR data to SA UE   ue_id=1   pdu=1    qfi=7
#    Send GBR data to SA UE   ue_id=1   pdu=1    qfi=8
#    Send GBR data to SA UE   ue_id=1   pdu=1    qfi=9

Add GBR bearer
    [Arguments]  ${ue_id}=1    ${set_qfi_low}=1    ${set_qfi_high}=1    ${qfi_start}=2
    FOR    ${set_qfi}    IN RANGE    ${set_qfi_low}    ${set_qfi_high}+1
         ${five_qi}    set variable    ${set_qfi}+1
         UE PDU Session Modify to Add    ue_id=${ue_id}  pdu=${ue_id}    set_qosflow_id=${set_qfi}    fiveQi=${five_qi}    qfi=${qfi_start}
         Wait '1s' for stabible
         Send GBR data to SA UE    ue_id=${ue_id}    pdu=${ue_id}    qfi=${qfi_start}
         ${qfi_start}    evaluate    ${qfi_start}+1
    END

Add nonGBR bearer
    [Arguments]  ${ue_id}=1    ${set_qfi_low}=8    ${set_qfi_high}=11    ${qfi_start}=2
    FOR    ${set_qfi}    IN RANGE    ${set_qfi_low}    ${set_qfi_high}+1
         ${five_qi}    set variable    ${set_qfi}-1
         UE PDU Session Modify to Add    ue_id=${ue_id}  pdu=${ue_id}    set_qosflow_id=${set_qfi}    fiveQi=${five_qi}    qfi=${qfi_start}
         Send GBR data to SA UE    ue_id=${ue_id}    pdu=${ue_id}    qfi=${qfi_start}
         ${qfi_start}    evaluate    ${qfi_start}+1
    END

Execute AP Command before attach
    airphone_cleanup_egate_console_log
#    Airphone Setup X2 Connection


Release VONR
    [Arguments]    ${UE_ID}
    Airphone Pdu Session Modify    ${UE_ID}    ${UE_ID}    qosflows_to_del=2
    Airphone Pdu Session Modify    ${UE_ID}    ${UE_ID}    qosflows_to_del=3
	Wait '5s' for stabible


UE '${ue_id}' fix RANK1
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 cqi_mode\=fixed ri\=0 ri_mode\=fixed
    airphone_execute_egate_command    ue_testmode_set_nr id\=${ue_id} testmode\=csi_override action\=activate profile_id\=1 scell\=0

UE '${ue_id}' fix RANK2
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 cqi_mode\=fixed ri\=1 ri_mode\=fixed
    airphone_execute_egate_command    ue_testmode_set_nr id\=${ue_id} testmode\=csi_override action\=activate profile_id\=2 scell\=0


UE '${ue_id}' fix RANK3
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=3 cqi\=15 cqi_mode\=fixed ri\=2 ri_mode\=fixed
    airphone_execute_egate_command    ue_testmode_set_nr id\=${ue_id} testmode\=csi_override action\=activate profile_id\=3 scell\=0





Check ttitrace
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_case08.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/


Check PM counters
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
	${M55308C34019_PRB_DL_MU_MIMO_12LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34019    cell_id=1
    ${M55308C34009_PRB_DL_MU_MIMO_6LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34009    cell_id=1
    ${M55308C34011_PRB_DL_MU_MIMO_8LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34011    cell_id=1
    ${M55308C34015_PRB_DL_MU_MIMO_6PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34025   cell_id=1
    log to console     ${M55308C34019_PRB_DL_MU_MIMO_12LAYER}
    log to console     ${M55308C34011_PRB_DL_MU_MIMO_8LAYER}
    log to console     ${M55308C34009_PRB_DL_MU_MIMO_6LAYER}
    log to console     ${M55308C34015_PRB_DL_MU_MIMO_6PAIR_UE}
    should_be_true    ${M55308C34011_PRB_DL_MU_MIMO_8LAYER}>0
    should_be_true    ${M55308C34015_PRB_DL_MU_MIMO_6PAIR_UE}>0


