*** Settings ***
Documentation    CB007113
Test Timeout    120 minutes
Suite Setup    Common Suite Setup
#Suite Teardown    Common Suite Teardown
Test Setup    Common Test Setup
Test Teardown    Common Test Teardown
Force Tags    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_ningyang
...   CLOUD_5G_I_LO_AP_LOOO_SANSA_FS_ECPRI_CMWV_TDD
Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}      CB007113_6cell_1116_0ms_100m_aplo_8D8U_mp.xml
${AIRPHONE_NAME}    IPHY_AEQE_6CELL_ABIO_8D8U_mp.xml
${WTS_NAME}    6cell_ue1to4_1layer.cfg
@{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
${COMAVALUE}    ${CURDIR}/coma/case4.txt
${UE_TOTALNUM}    4
${UE_NUM}         4
${UE_ID}          1
${UE_ID2}          2
${UE_ID3}          3
${UE_ID4}          4
${UE_ID5}          5
${UE_ID6}          6
${UE_ID7}          7
${UE_ID8}          8
${SLICE_ID}       1
${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=1 step\=5 trigger_puxch_update\=0
${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 step\=5 trigger_puxch_update\=0
${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 step\=5 trigger_puxch_update\=0
${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 step\=5 trigger_puxch_update\=0
${PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id\=8 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 step\=5 trigger_puxch_update\=0
${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
${SET_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
${SET_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
${SET_PROFILE5}    ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5
${SET_PROFILE6}    ue_testmode_set_nr id\=6 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=6
${SET_PROFILE7}    ue_testmode_set_nr id\=7 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=7
${SET_PROFILE8}    ue_testmode_set_nr id\=8 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=8
${deactive_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=1
${deactive_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=2
${deactive_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=3
${deactive_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=4
${deactive_PROFILE5}    ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=5
${deactive_PROFILE6}    ue_testmode_set_nr id\=6 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=6
${deactive_PROFILE7}    ue_testmode_set_nr id\=7 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=7
${deactive_PROFILE8}    ue_testmode_set_nr id\=8 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=8
*** Test Cases ***
CB007113_I_1_case2_MUMIMO_4layers_with_UL_PRB_pooling_activated_4rank1ue
    Get and Update BSR File    par_of_bsr_name=BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
	Modify 7113 Swconfig
    Prepare gnb onair
    Start capture gnb and ap syslog in 'after_onair_nobler' file
	${err_info}    create list    ERR/l1_application_rt, 5C/ERR RT C4: checkNrPuschPoolingBufferOverflow:
    airphone_cleanup_egate_console_log
    Set multiue traffic type to internal
    Attach '4' ue to 5g cell
	Set ue position
    Internal send data
	#run keyword and continue on failure    check throughput only four rank1
	Start collect ttitrace
	Wait for '2s' to stop ttitrace with name'tti4rk1'
	run keyword and continue on failure     check bler and pair is correct in ttitrace4rk1
	run keyword and continue on failure     Check counter value
	#Y<Ymax
	#Internal send fewer data
	#just for munual test
	#Attach one SU ue and check PRB
	change ue5to8 location
	Attach '4' ue to 5g cell2 and cell3 and send data
    #Internal send ue5to8 data
    Start collect ttitrace
    #Start collect bip log
	Wait for '2s' to stop ttitrace with name'ttiLbyX'
	#Wait for '0s' to stop bip log with name'bip'
 	#run keyword and continue on failure    check TPdecrease
	run keyword and continue on failure     check bler and pair is correct in ttitraceLbyX
	Internal send ue5to8 data 1M
	Start collect ttitrace
	Wait for '1s' to stop ttitrace with name'tti1M'
	run keyword and continue on failure     check bler and pair is correct in ttitrace1M
	#just for munual test
	#Attach one SU ue again and check PRB
	DeRegister UE from '1' to '8'
	Stop capture gnb and ap syslog in 'after_onair_nobler' file '${err_info}'

*** Keywords ***
Prepare test
    #Active GNB L2 feature debug traces
    Modify l1bypass
    Modify 7113 Swconfig
Verify throughput decrease
    ${ultp_pcell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pusch    tput_type=ave
    ${ultp_pcell2}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}    scell_id=0    type=pusch    tput_type=ave
    ${ultp_pcell3}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID3}    scell_id=0    type=pusch    tput_type=ave
    ${ultp_pcell4}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID4}    scell_id=0    type=pusch    tput_type=ave
    #${ultp_pcell5}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID5}    scell_id=0    type=pusch    tput_type=ave
    #${ultp_pcell6}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID6}    scell_id=0    type=pusch    tput_type=ave
    #${ultp_pcell7}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID7}    scell_id=0    type=pusch    tput_type=ave
    #${ultp_pcell8}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID8}    scell_id=0    type=pusch    tput_type=ave
    run keyword and continue on failure     should_be_true     ${ultp_pcell1}+${ultp_pcell2}+${ultp_pcell3}+${ultp_pcell4}>140000
    run keyword and continue on failure     should_be_true     ${ultp_pcell1}+${ultp_pcell2}+${ultp_pcell3}+${ultp_pcell4}<290000
Verify throughput only four rank1
    ${ultp_pcell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pusch    tput_type=ave
    ${ultp_pcell2}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}    scell_id=0    type=pusch    tput_type=ave
    ${ultp_pcell3}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID3}    scell_id=0    type=pusch    tput_type=ave
    ${ultp_pcell4}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID4}    scell_id=0    type=pusch    tput_type=ave
    run keyword and continue on failure     should_be_true     ${ultp_pcell1}+${ultp_pcell2}+${ultp_pcell3}+${ultp_pcell4}>280000
Check TPdecrease
    Wait until keyword succeeds    60s    5s    Verify throughput decrease
check throughput only four rank1
    Wait until keyword succeeds    60s    5s    Verify throughput only four rank1
Internal send data
    FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
        Airphone SA Start Data Traffic    ${num}    UL    100M    pdu_id=${num}    duration=6000s
        ...    trf_id=${num}
        Airphone SA Start Data Traffic    ${num}    DL    10M    pdu_id=${num}    duration=6000s
        ...    trf_id=${num}
    END
    #    Wait '5s' for stabible
Internal send data 50M
    FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
        Airphone SA Start Data Traffic    ${num}    UL    50M    pdu_id=${num}    duration=6000s
        ...    trf_id=${num}
    END
    #    Wait '5s' for stabible
Internal send ue5to8 data
    FOR    ${num}    IN RANGE    5    ${UE_NUM}+5
        Airphone SA Start Data Traffic    ${num}    UL    120M    pdu_id=${num}    duration=6000s
        ...    trf_id=${num}
    END
    #    Wait '5s' for stabible
Internal send ue5to8 data 1M
    FOR    ${num}    IN RANGE    5    ${UE_NUM}+5
        Airphone SA Start Data Traffic    ${num}    UL    1M    pdu_id=${num}    duration=6000s
        ...    trf_id=${num}
        Wait '3s' for stabible
    END
Modify l1bypass
    copy_file    ${COMAVALUE}    ${test_log_directory()}/coma.py
    Import Variables    ${test_log_directory()}/coma.py
    ${extra_modify}    create list
	#...    text|0|//enable_5GC002396
    ...    text|28|//*[@TestProfile\="Profile-1"]//SrsTestParams//ulPmiRank1Sinr
    ...    text|28|//*[@TestProfile\="Profile-1"]//PuschTestParams//ulPmiRank1Sinr
    ...    text|28|//*[@TestProfile\="Profile-2"]//SrsTestParams//ulPmiRank1Sinr
    ...    text|28|//*[@TestProfile\="Profile-2"]//PuschTestParams//ulPmiRank1Sinr
    ...    text|0|//*[@TestProfile\="Profile-1"]//PuschTestParams//puschNumCountSwitchProfile
    ...    text|0|//*[@TestProfile\="Profile-2"]//PuschTestParams//puschNumCountSwitchProfile
    Modify airphone l1bypass coma value for eight ue
    ...    ${Hindex14}    ${Vindex9}    ${Hindex0}    ${Vindex0}
    ...    ${Hindex8}    ${Vindex0}    ${Hindex2}    ${Vindex0}
    ...    ${Hindex19}    ${Vindex0}    ${Hindex6}    ${Vindex0}
    ...    ${Hindex0}    ${Vindex7}    ${Hindex8}    ${Vindex0}
    ...    ${Hindex14}    ${Vindex9}    ${Hindex0}    ${Vindex0}
    ...    ${Hindex8}    ${Vindex0}    ${Hindex3}    ${Vindex0}
    ...    ${Hindex19}    ${Vindex0}    ${Hindex6}    ${Vindex0}
    ...    ${Hindex0}    ${Vindex7}    ${Hindex9}    ${Vindex0}
    ...    srsNumCountSwitchProfile1=0    p1_rank=2    p2_rank=2    p1_sinr=29    p2_sinr=28
    ...    extra_modify=${extra_modify}
Modify 7113 Swconfig

	#control UE rank reported by pusch
	Add AP swconfig    0x1003F:2
	Add AP swconfig    0x10042:0xC0A8C87E
	#Add GNB swconfig    0x58037C:1
	#enable rdactUlMuMimoEnhance
	#Add GNB swconfig     0x58054F:1
   #CB007113 Related Params
   Add GNB swconfig     0x9D0000:15
   #Add GNB swconfig    0x420062:1 # 8940 New CSM rdNewTddCellSlotModel is set to true
   #Add GNB swconfig    0x420068:6 # rdTddPoolingFeaturesEnable
   Add GNB swconfig    0x1003F:1
   #enable ADMIN developer
   #Add GNB swconfig    0x450027=1
   #Admin developement account
   #Add GNB swconfig    0x45000A=1
   #Add GNB swconfig	   0x580550:15
Attach '${uenum}' ue to 5g cell
    FOR    ${num}    IN RANGE    1    ${uenum}+1
        Airphone SA Attach    ue_id=${num}
        Wait '2s' for stabible
        Airphone Pdu Session Setup    ${num}    ${num}    ${SLICE_ID}    ${num}
        Wait '3s' for stabible
    END
Attach '4' ue to 5g cell2 and cell3 and send data
    FOR    ${num}    IN RANGE    5    ${uenum}+5
        Airphone SA Attach    ue_id=${num}
        Wait '2s' for stabible
        Airphone Pdu Session Setup    ${num}    ${num}    ${SLICE_ID}    ${num}
        Airphone SA Start Data Traffic    ${num}    UL    120M    pdu_id=${num}    duration=6000s
        ...    trf_id=${num}
    END
Set multiue traffic type to internal
    FOR    ${num}    IN RANGE    1    ${UE_NUM}+6
        Airphone Set Traffic Type    ${num}    ${num}    internal
    END

UE from '${lo}' to '${hi}' SA Register and check
    FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
       airphone_cleanup_egate_console_log
       Log To Console   ${\n}--register UE ${num} --
       Airphone SA Attach    ue_id=${num}
       #set_pdu_param ue=1 pdu=1 trf_type=internal
       #Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
       Airphone Set Traffic Type    ${num}    ${num}    internal
       Airphone Pdu Session Setup    ${num}    ${num}    1    ${num}
       Wait '3s' for stabible
       UL data to '${num}'
    #   get UE '${num}' rnti in RRC log
    END


get UE '${ue_id}' rnti in RRC log
    Log To Console   ${\n}===get UE'${ue_id}' rnti===
    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}   unzip=TRUE

    ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}/egate_console.log.001   crnti: (\\d+)
    run keyword if    ${ue_id}==1   Set test Variable	 ${rnti_1} 	${rnti_list[0]}
    run keyword if    ${ue_id}==2   Set test Variable	 ${rnti_2} 	${rnti_list[0]}
    run keyword if    ${ue_id}==3   Set test Variable	 ${rnti_3} 	${rnti_list[0]}
check bler and pair is correct in ttitrace4rk1
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_ul_case2_4rk1.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
	#7113_check_file.Check 7113 Cell Rachslot     ${TEST_LOG_DIRECTORY()}/All/tti4rk1_ul.csv       50      15

check port is correct in ttitrace
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_d_case2_port.ini    log_need_to_check=i
	...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
check bler and pair is correct in ttitrace1M
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_case2_1M.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
check bler and pair is correct in ttitraceLbyX
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_ul_case2_LbyX.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
	#7113_check_file.Check 7113 Cell Rachslot     ${TEST_LOG_DIRECTORY()}/All/ttiLbyX_ul.csv       50      15
check bler and pair is correct in ttitraceYmax
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_ul_case2_Ymax.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
change ue5to8 location
    airphone_execute_egate_command	  ue_change_location cell\=2 id\=5
    airphone_execute_egate_command	  ue_change_location cell\=2 id\=6
    airphone_execute_egate_command	  ue_change_location cell\=3 id\=7
    airphone_execute_egate_command	  ue_change_location cell\=3 id\=8
Attach one SU ue and check PRB
    run keyword and continue on failure    airphone_execute_egate_command	  ue_change_location cell\=1 id\=5
    Airphone SA Attach    ue_id=5
    Airphone Pdu Session Setup    5    5   ${SLICE_ID}    5
	Set ue5 position
    Wait '1s' for stabible
	Airphone SA Start Data Traffic    5    UL    50M    pdu_id=5    duration=6000s    trf_id=1
    Start collect ttitrace
	Wait for '2s' to stop ttitrace with name'MUSU'
    run keyword and continue on failure     check bler and PRB is correct in ttitraceMUSU
    airphone_sa_detach    ue_id=5   timeout=5
Attach one SU ue again and check PRB
	Airphone SA Attach    ue_id=9
	Wait '1s' for stabible
    Airphone Pdu Session Setup    9    9   ${SLICE_ID}    9
	Airphone SA Start Data Traffic    9    UL    50M    pdu_id=9   duration=6000s    trf_id=1
	Internal send ue5to8 data
    Wait '1s' for stabible
    Start collect ttitrace
	Wait for '1s' to stop ttitrace with name'MUSU2'
    run keyword and continue on failure     check bler and PRB is correct in ttitraceMUSU2
check bler and PRB is correct in ttitraceMUSU
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_case2_MUSU.ini    log_need_to_check=i
	...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
	7113_check_file.Check 7113 Cell Rachslot     ${TEST_LOG_DIRECTORY()}/All/MUSU_ul.csv       50      15
check bler and PRB is correct in ttitraceMUSU2
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_case2_MUSU2.ini    log_need_to_check=i
	...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
	7113_check_file.Check 7113 Cell Rachslot     ${TEST_LOG_DIRECTORY()}/All/MUSU2_ul.csv       50      15
DeRegister UE from '${low}' to '${hi}'
    FOR    ${num}    IN RANGE    ${low}    ${hi}+1
       airphone_sa_detach    ue_id=${num}    timeout=5
       Wait '3s' for stabible
    END
Check counter value
    Wait until keyword succeeds    180s    30s    counter value
counter value
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}
    ${PM_counter_value_Pcell}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35005    cell_id=1
	${PM_counter_value_Pcell2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35009    cell_id=1
	${PM_counter_value_Pcell3}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C10006    cell_id=1
	${PM_counter_value_Pcell4}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C10002     cell_id=1
    should be true    ${PM_counter_value_Pcell}==${PM_counter_value_Pcell2}
	should be true    ${PM_counter_value_Pcell3}-${PM_counter_value_Pcell4}<=700000
Internal send fewer data
	Internal send data 50M
	Start collect ttitrace
	Wait for '2s' to stop ttitrace with name'ttiYmax'
	run keyword and continue on failure     check bler and pair is correct in ttitraceYmax
Set ue position
    Airphone Execute Egate Command    ${PROFILE1}
    Airphone Execute Egate Command    ${SET_PROFILE1}
    Wait '2s' for stabible
    Airphone Execute Egate Command    ${PROFILE2}
    Airphone Execute Egate Command    ${SET_PROFILE2}
    Wait '2s' for stabible
    Airphone Execute Egate Command    ${PROFILE3}
    Airphone Execute Egate Command    ${SET_PROFILE3}
    Wait '2s' for stabible
    Airphone Execute Egate Command    ${PROFILE4}
    Airphone Execute Egate Command    ${SET_PROFILE4}
    Wait '2s' for stabible
Set ue5 position
    Airphone Execute Egate Command    ${PROFILE5}
    Airphone Execute Egate Command    ${SET_PROFILE5}
deactive profile12345678
	Airphone Execute Egate Command    ${deactive_PROFILE1}
	Airphone Execute Egate Command    ${deactive_PROFILE2}
	Airphone Execute Egate Command    ${deactive_PROFILE3}
	Airphone Execute Egate Command    ${deactive_PROFILE4}
    Airphone Execute Egate Command    ${deactive_PROFILE5}