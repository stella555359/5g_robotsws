*** Settings ***
Documentation     Author:
...
Test Timeout      120 minutes
Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_LOO_AP_LOOO    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G

Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot


*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}          scfc_eda.xml
${AIRPHONE_NAME}      iphy_6cc_looo.xml
${WTS_NAME}           wts_6cc_looo.lua
@{LOG_NAME_LIST}      gnb_snapshot    egatelog

${UE_ID1}          1
${PDU_ID1}         1
${GW_ID1}          1
${SLICE_ID}       1
${UE_NUM_SA}         1
${UE_NUM_SA_VONR}         2
${UE_NUM_NSA}        2
${UE_NUM_NSA_ID}        12
${EGATE_TAG}      MUmimo
${TTI_TAG}      tti
${TTI_TAG_BLER}      tti_bler
&{GNBMIRRORINGCONFIGS}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'
...    NUMBER_OF_FILES=30
#@{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
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
TMO_EDA_04501427_case01
    Get and Update BSR File    par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00002
    Prepare gnb onair    multi_cells=True
    Start capture gnb and ap syslog in 'after_onair' file
    Attach '${UE_NUM_SA}' SA UE
    Send Non GBR data to SA UE
    Stop capture gnb and ap syslog in 'after_onair' file

*** Keywords ***
check TP and bler with ttitrace
    [Arguments]    ${throughput}    ${time_avg}    ${tti_file}
    ${a}  get_ues_tbsize_by_sfn   ${test_log_directory()}/All/${tti_file}/tti_dl.csv
    ...        ${test_log_directory()}/All/${tti_file}/tti_dl_new.csv   ${time_avg}   filter=dlFdSchedData.ackNack\=ACK
    @{keys}  Get Dictionary Keys   ${a}
    FOR      ${key}     IN     @{keys}
        ${result}   evaluate  ${a[${key}]}/${time_avg}/1024/1000
        log to console   result is ${result}
        log to console   TP is ${throughput}
        should be true  ${result}>${throughput}
    END

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


Send Non GBR data to SA UE
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
        SA send mutiple trf dl data    ${num}    4   175M   ${num}
        SA send mutiple trf ul data    ${num}    1    20M   ${num}
    END

Send GBR data to SA UE
    [Arguments]  ${ue_id}=1  ${pdu}=1    ${qfi}=2
    airphone_execute_egate_command    trf_data_start ue\=${ue_id} pdu\=${pdu} qfi\=${qfi} trf_id\=5 mbps\=5 dir\=dl
    airphone_execute_egate_command    trf_data_start ue\=${ue_id} pdu\=${pdu} qfi\=${qfi} trf_id\=5 mbps\=5 dir\=ul
    Wait '3s' for stabible

Execute AP Command before attach
    airphone_cleanup_egate_console_log
#    Airphone Setup X2 Connection


Release VONR
    [Arguments]    ${UE_ID}
    Airphone Pdu Session Modify    ${UE_ID}    ${UE_ID}    qosflows_to_del=2
    Airphone Pdu Session Modify    ${UE_ID}    ${UE_ID}    qosflows_to_del=3
	Wait '5s' for stabible



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


