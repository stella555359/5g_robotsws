# @Time    : 2024/9/20 9:14
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @Group   : NSB MN RAN RD VRF HAZ3 5
# @File    : CB0010653.robot
# @Software: PyCharm
# @Doc     : This is common robot cases template
*** Settings ***
Documentation
...    author: Chen Jian
...    contact: jian.1.chen@nokia-sbell.com
...    squad group: NSB MN RAN RD VRF HAZ3 5
...    Feature CB010653-SR NR Counters for SRS Beam Forming and MIMO Layer Usages

#Suite Setup    Common Suite Setup
#Suite Teardown    Common Suite Teardown
#Test Setup    Common Test Setup
#Test Teardown    Common Test Teardown
Test Setup    Run Keywords    Common Suite Setup    AND    Common Test Setup
Test Teardown    Run Keywords    Common Test Teardown
...    AND    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    5min    5s    Verify BTS Is Onair
...    AND    Common Suite Teardown
...    AND    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'before_onair' file '${None}'
Force Tags    AP    CRT    SBTS00   CLOUD_5G_I_LO_AP_LO
Resource    ../../RAN_L2_SW_CN_3/resources/KISS/robot/common_resource.robot
Resource    ../../RAN_L2_SW_CN_3/resources/sg10/internal_resource/internal_resource.robot
Library    check_tti.py
Library    taf.config.scf    WITH NAME    scf

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config

${COMMON_PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed
${COMMON_PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed
${COMMON_PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed
${COMMON_PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed

${209_UE1_PROFILE1}    ${COMMON_PROFILE1} init_quad_pos\=1 init_sub_quad_pos\=1 step\=5 trigger_puxch_update\=0 test_type\=SRS
${209_UE2_PROFILE1}    ${COMMON_PROFILE2} init_quad_pos\=3 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0 test_type\=SRS
${209_UE3_PROFILE1}    ${COMMON_PROFILE3} init_quad_pos\=0 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0 test_type\=SRS
${209_UE1_PROFILE2}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
${209_UE2_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
${209_UE3_PROFILE2}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3

${205_UE1_PROFILE1}    ${COMMON_PROFILE1} init_quad_pos\=0 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0 test_type\=SRS
${205_UE2_PROFILE1}    ${COMMON_PROFILE2} init_quad_pos\=1 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0 test_type\=SRS
${205_UE3_PROFILE1}    ${COMMON_PROFILE3} init_quad_pos\=2 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0 test_type\=SRS
${205_UE4_PROFILE1}    ${COMMON_PROFILE3} init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0 test_type\=SRS
${205_UE1_PROFILE2}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
${205_UE2_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
${205_UE3_PROFILE2}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
${205_UE4_PROFILE2}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4

# for 203
${COMMON_PROFILE_203}    step\=5 trigger_puxch_update\=0 test_type\=SRS srs_transmit_power_per_port\=-200,-200,-200,-200
${203_UE1_PROFILE1}    ${COMMON_PROFILE1} init_quad_pos\=2 init_sub_quad_pos\=3 ${COMMON_PROFILE_203}
${203_UE2_PROFILE1}    ${COMMON_PROFILE2} init_quad_pos\=3 init_sub_quad_pos\=3 ${COMMON_PROFILE_203}
${203_UE3_PROFILE1}    ${COMMON_PROFILE3} init_quad_pos\=0 init_sub_quad_pos\=0 ${COMMON_PROFILE_203}
${203_UE4_PROFILE1}    ${COMMON_PROFILE4} init_quad_pos\=1 init_sub_quad_pos\=0 ${COMMON_PROFILE_203}
${203_UE1_PROFILE2}    ue_testmode_set_nr id\=11 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
${203_UE2_PROFILE2}    ue_testmode_set_nr id\=12 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
${203_UE3_PROFILE2}    ue_testmode_set_nr id\=13 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
${203_UE4_PROFILE2}    ue_testmode_set_nr id\=14 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4

${213_UE1_PROFILE1}    ${COMMON_PROFILE1} init_quad_pos\=1 init_sub_quad_pos\=1 step\=5 trigger_puxch_update\=0 test_type\=SRS
${213_UE1_PROFILE2}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
${213_UE2_PROFILE1}    ${COMMON_PROFILE2} init_quad_pos\=3 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0 test_type\=SRS
${213_UE2_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2

${220_UE1_PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=UL_MIMO
${220_UE1_PROFILE2}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
${220_UE2_PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 test_type\=UL_MIMO
${220_UE2_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
${220_UE3_PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 test_type\=UL_MIMO
${220_UE3_PROFILE2}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
${220_UE4_PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 test_type\=UL_MIMO
${220_UE4_PROFILE2}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4

${30N_UE1_PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=UL_MIMO
${30N_UE1_PROFILE2}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
${30N_UE2_PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 test_type\=UL_MIMO
${30N_UE2_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
${30N_UE3_PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 test_type\=UL_MIMO
${30N_UE3_PROFILE2}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
${30N_UE4_PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 test_type\=UL_MIMO
${30N_UE4_PROFILE2}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
${30N_UE5_PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 test_type\=UL_MIMO
${30N_UE5_PROFILE2}    ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5
${30N_UE2_PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 test_type\=UL_MIMO
${30N_UE2_PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=UL_MIMO
${30N_UE2_PROFILE5}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
#CB010630_case105
${105_UE1_PROFILE1}    ul_ue_beam_pos_nr profile_id\=1 num_beam_paths\=2 azimuth\=0,20 zenith\=0,0 power=-300,-300
${105_UE1_PROFILE2}    ue_testmode_set_nr id\=1 testmode\=ue_ul_beam_position profile_id\=1 action\=activate
${105_UE2_PROFILE1}    ul_ue_beam_pos_nr profile_id\=2 num_beam_paths\=2 azimuth\=-30,30 zenith\=0,0 power\=-300,-300
${105_UE2_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ue_ul_beam_position profile_id\=2 action\=activate
${BETAEC}	13
${XEC}	14

#For A105
@{A_105_AP_CMDS_WITH_SLEEP_TIME_STEP1}
...    ue_register id\=1    3s
...    set_pdu_param ue\=1 pdu\=1 trf_type\=internal    3s
...    ue_pdu_session_setup pdu\=1 ue\=1 nwslice\=1 gw\=1    3s
...    ue_register id\=2    3s
...    set_pdu_param ue\=2 pdu\=1 trf_type\=internal    3s
...    ue_pdu_session_setup pdu\=1 ue\=2 nwslice\=1 gw\=2    3s
...    ue_register id\=3    3s
...    set_pdu_param ue\=3 pdu\=1 trf_type\=internal    3s
...    ue_pdu_session_setup pdu\=1 ue\=3 nwslice\=1 gw\=3    3s
@{A_105_AP_CMDS_WITH_SLEEP_TIME_STEP2}
...    ue_deregister id\=1 ue_deregister_type\=switch_off    3s
...    ue_deregister id\=2 ue_deregister_type\=switch_off    3s
...    ue_deregister id\=3 ue_deregister_type\=switch_off    3s

#For A106
@{A_106_AP_CMDS_WITH_SLEEP_TIME_STEP1}
...    ue_attach id\=11 profile\=1    1s
...    ue_dc_enb_start ue\=11 target_gnb\=2 target_cells\=1 bearer\=2 type\=split_scg    1s
...    trf_data_start ue\=11 id\=2 dir\=dl mbps\=173 trf_id\=1    1s
...    trf_data_start ue\=11 id\=2 dir\=dl mbps\=173 trf_id\=2    1s
...    trf_data_start ue\=11 id\=2 dir\=dl mbps\=173 trf_id\=3    1s
...    trf_data_start ue\=11 id\=2 dir\=dl mbps\=173 trf_id\=4    1s
...    trf_data_start ue\=11 id\=2 dir\=dl mbps\=173 trf_id\=5    1s
...    trf_data_start ue\=11 id\=2 dir\=dl mbps\=173 trf_id\=6    1s
...    trf_data_start ue\=11 id\=2 dir\=dl mbps\=173 trf_id\=7    1s
...    trf_data_start ue\=11 id\=2 dir\=dl mbps\=173 trf_id\=8    1s
...    trf_data_start ue\=11 id\=2 dir\=dl mbps\=173 trf_id\=9    1s
...    ue_stats_nr id\=11 type\=pdsch scell\=8,9    1s
...    ue_attach id\=12 profile\=1    1s
...    ue_dc_enb_start ue\=12 target_gnb\=2 target_cells\=1 bearer\=2 type\=split_scg    1s
...    trf_data_start ue\=12 id\=2 dir\=dl mbps\=150 trf_id\=1    1s
...    trf_data_start ue\=12 id\=2 dir\=dl mbps\=150 trf_id\=2    1s
...    trf_data_start ue\=12 id\=2 dir\=dl mbps\=150 trf_id\=3    1s
...    ue_stats_nr id\=12 type\=pdsch scell\=8,9    1s
...    ue_attach id\=13 profile\=1    1s
...    ue_dc_enb_start ue\=13 target_gnb\=2 target_cells\=1 bearer\=2 type\=split_scg    1s
...    trf_data_start ue\=13 id\=2 dir\=dl mbps\=173 trf_id\=1    1s
...    trf_data_start ue\=13 id\=2 dir\=dl mbps\=173 trf_id\=2    1s
...    trf_data_start ue\=13 id\=2 dir\=dl mbps\=173 trf_id\=3    1s
...    trf_data_start ue\=13 id\=2 dir\=dl mbps\=173 trf_id\=4    1s
...    trf_data_start ue\=13 id\=2 dir\=dl mbps\=173 trf_id\=5    1s
...    trf_data_start ue\=13 id\=2 dir\=dl mbps\=173 trf_id\=6    1s
...    trf_data_start ue\=13 id\=2 dir\=dl mbps\=173 trf_id\=7    1s
...    trf_data_start ue\=13 id\=2 dir\=dl mbps\=173 trf_id\=8    1s
...    ue_stats_nr id\=13 type\=pdsch scell\=8,9    1s

*** Test Cases ***
CB010653_B_301_Verify_Counter_for_UE_that_cannot_be_Paired_UL_MU_MIMO_because_of_Retransmission
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/09/29 13:20
    [Tags]    301
    Set Test Variable    ${SCFC_NAME}            301_2.xml
    Set Test Variable    ${AIRPHONE_NAME}        301_ap.xml
    Set Test Variable    ${WTS_NAME}             301_wts.cfg
    Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001
    Set Test Variable    ${GNBCUTYPE}    ${EMPTY}
    Prepare gnb onair

    wait_until_next_5_min
    Start GNB Ttitrace With Streaming Mode
    UE from '1' to '1' SA Register
    Set UE position    ${30N_UE1_PROFILE1}    ${30N_UE1_PROFILE2}
    Airphone SA Start Data Traffic    1    ul   70M   pdu_id=1    trf_id=1
    UE from '2' to '2' SA Register
    Set UE position    ${30N_UE2_PROFILE1}    ${30N_UE2_PROFILE2}
    Airphone SA Start Data Traffic    2    ul   175M   pdu_id=1    trf_id=3
    UE from '3' to '3' SA Register
    Set UE position    ${30N_UE3_PROFILE1}    ${30N_UE3_PROFILE2}
    Airphone SA Start Data Traffic    3    ul   90M   pdu_id=1    trf_id=3

    airphone_execute_egate_command    bler_testmode_nr profile_id\=1 ul_bler\=400,500
    airphone_execute_egate_command    ue_testmode_set_nr id\=2 scell\=0 testmode\=bler profile_id\=1 action\=activate
    airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=1 sinr_target_pusch\=-250
    airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_sinr action\=activate profile_id\=1
    Sleep    2s

    Airphone SA Stop Data Traffic    1    UL
    Airphone SA Stop Data Traffic    2    UL
    Airphone SA Stop Data Traffic    3    UL
    airphone_execute_egate_command    ue_deregister id\=1 ue_deregister_type\=switch_off
    airphone_execute_egate_command    ue_deregister id\=2 ue_deregister_type\=switch_off
    airphone_execute_egate_command    ue_deregister id\=3 ue_deregister_type\=switch_off
    airphone_execute_egate_command    ue_testmode_set_nr id\=2 scell\=0 testmode\=bler profile_id\=1 action\=deactivate
    airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_sinr action\=deactivate profile_id\=1
    Sleep    2s
    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
    Decoder Tttirace From Pcap To Csv    ${pcap_path}    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump
    ${num}    check_target_mustatus_num    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump_ul.csv    type=MUNONELIGIBLE_RETX_ATB
    ${num2}    check_target_mustatus_num    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump_ul.csv    type=MUNONPAIRED_RETXLOWERMUSINR
    ${num3}    check_target_mustatus_num    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump_ul.csv    type=MUNONELIGIBLE_RETX_DTX
    wait_until_next_5_min    extra_sleep_time=60
    coam.connect_to    name=GNB_OAM
    ${counters}    coam.get_pm_counters    counter_ids=M55308C00100    connection=GNB_OAM
    coam.teardown    connection=GNB_OAM
    ${counter}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NCELA']['M55308C00100']}
    ${sum}    Evaluate    ${num}+${num2}+${num3}
    Should Be True    '${sum}'=='${counter}'


    Set Test Variable    ${SCFC_NAME}            301.xml
    Set Test Variable    ${AIRPHONE_NAME}        301_ap.xml
    Set Test Variable    ${WTS_NAME}             301_wts.cfg
    Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001
    Prepare gnb onair

    Start GNB Ttitrace With Streaming Mode
    UE from '1' to '1' SA Register
    Set UE position    ${30N_UE1_PROFILE1}    ${30N_UE1_PROFILE2}
    Airphone SA Start Data Traffic    1    ul   70M   pdu_id=1    trf_id=1
    UE from '2' to '2' SA Register
    Set UE position    ${30N_UE2_PROFILE1}    ${30N_UE2_PROFILE2}
    Airphone SA Start Data Traffic    2    ul   175M   pdu_id=1    trf_id=3
    UE from '3' to '3' SA Register
    Set UE position    ${30N_UE3_PROFILE1}    ${30N_UE3_PROFILE2}
    Airphone SA Start Data Traffic    3    ul   90M   pdu_id=1    trf_id=3
    UE from '4' to '4' SA Register
    Set UE position    ${30N_UE4_PROFILE1}    ${30N_UE4_PROFILE2}
    Airphone SA Start Data Traffic    4    ul   90M   pdu_id=1    trf_id=4

    airphone_execute_egate_command    bler_testmode_nr profile_id\=1 ul_bler\=200,100
    airphone_execute_egate_command    ue_testmode_set_nr id\=2 scell\=0 testmode\=bler profile_id\=1 action\=activate
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 scell\=0 testmode\=bler profile_id\=1 action\=activate

    UE from '5' to '5' SA Register
    Set UE position    ${30N_UE5_PROFILE1}    ${30N_UE5_PROFILE2}
    Airphone SA Start Data Traffic    5    ul   90M   pdu_id=1    trf_id=1
    Sleep    3s
    airphone_execute_egate_command    ue_deregister id\=1 ue_deregister_type\=switch_off
    airphone_execute_egate_command    ue_deregister id\=2 ue_deregister_type\=switch_off
    airphone_execute_egate_command    ue_deregister id\=3 ue_deregister_type\=switch_off
    airphone_execute_egate_command    ue_deregister id\=4 ue_deregister_type\=switch_off
    airphone_execute_egate_command    ue_deregister id\=5 ue_deregister_type\=switch_off
    airphone_execute_egate_command    ue_testmode_set_nr id\=2 scell\=0 testmode\=bler profile_id\=1 action\=deactivate
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 scell\=0 testmode\=bler profile_id\=1 action\=deactivate
    Sleep    3s

    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
    Decoder Tttirace From Pcap To Csv    ${pcap_path}    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump
    ${num}    check_target_mustatus_num    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump_ul.csv    type=MUNONELIGIBLE_RETX_DMRS
    ${num2}    check_target_mustatus_num    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump_ul.csv    type=MUNONPAIRED_RETXLARGERPAIREDLAYER
    ${num3}    check_target_mustatus_num    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump_ul.csv    type=MUNONELIGIBLE_RETX_DTX

    wait_until_next_5_min    extra_sleep_time=60
    coam.connect_to    name=GNB_OAM
    ${counters}    coam.get_pm_counters    counter_ids=M55308C00100    connection=GNB_OAM
    coam.teardown    connection=GNB_OAM
    ${counter}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NCELA']['M55308C00100']}
    ${sum}    Evaluate    ${num}+${num2}+${num3}
    Should Be True    '${sum}'=='${counter}'

CB010653_B_302_Verify_Counter_for_UE_that_cannot_be_Paired_UL_MU_MIMO_because_of_a_Low_SINR_Value
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/09/13 10:30 p
    [Tags]    302
    Set Test Variable    ${SCFC_NAME}            302.xml
    Set Test Variable    ${AIRPHONE_NAME}        302_ap.xml
    Set Test Variable    ${WTS_NAME}             302_wts.cfg
    Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001
    Set Test Variable    ${GNBCUTYPE}    ${EMPTY}
    Prepare gnb onair

    wait_until_next_5_min
    UE from '1' to '1' SA Register
    Set UE position    ${30N_UE1_PROFILE1}    ${30N_UE1_PROFILE2}
    UE from '2' to '2' SA Register
    Set UE position    ${30N_UE2_PROFILE1}    ${30N_UE2_PROFILE2}
    Start GNB Ttitrace With Streaming Mode
    Airphone SA Start Data Traffic    1    ul   175M   pdu_id=1    trf_id=1
    Airphone SA Start Data Traffic    2    ul   175M   pdu_id=1    trf_id=3

    airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=1 sinr_target_pusch\=-350
    airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_sinr action\=activate profile_id\=1
    Sleep    3s
    airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_sinr action\=deactivate profile_id\=1
    Airphone SA Stop Data Traffic    1    UL
    Airphone SA Detach    1
    Airphone SA Stop Data Traffic    2    UL
    Airphone SA Detach    2

    Verify UE No Pair Counter Normal    type=MUNONELIGIBLE_LOWSINR    counter_id=M55308C00101

CB010653_B_303_Verify_Counter_for_UE_that_cannot_be_Paired_UL_MU_MIMO_because_of_the_SINR_Difference_Value
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/09/17 14:36 p
    [Tags]    303
    Set Test Variable    ${SCFC_NAME}            303.xml
    Set Test Variable    ${AIRPHONE_NAME}        303_ap.xml
    Set Test Variable    ${WTS_NAME}             303_wts.cfg
    Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001
    Set Test Variable    ${GNBCUTYPE}    ${EMPTY}
    Prepare gnb onair

    wait_until_next_5_min
    Start GNB Ttitrace With Streaming Mode

    UE from '1' to '1' SA Register
    Set UE position    ${30N_UE1_PROFILE1}    ${30N_UE1_PROFILE2}
    Airphone SA Start Data Traffic    1    ul   100M   pdu_id=1    trf_id=1

    UE from '2' to '2' SA Register
    Set UE position    ${30N_UE2_PROFILE1}    ${30N_UE2_PROFILE2}
    Airphone SA Start Data Traffic    2    ul   90M   pdu_id=1    trf_id=2
    Airphone SA Start Data Traffic    2    ul   90M   pdu_id=1    trf_id=3

    UE from '3' to '3' SA Register
    Set UE position    ${30N_UE3_PROFILE1}    ${30N_UE3_PROFILE2}
    Airphone SA Start Data Traffic    3    ul   90M   pdu_id=1    trf_id=1

    airphone_execute_egate_command    ue_stats_nr id\=1-3 type\=pusch
    Sleep    2s
    airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=1 sinr_target_pusch\=-360
    Sleep    2s
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=1
    Sleep    2s

    airphone_execute_egate_command    ue_deregister id\=1 ue_deregister_type\=switch_off
    airphone_execute_egate_command    ue_deregister id\=2 ue_deregister_type\=switch_off
    airphone_execute_egate_command    ue_deregister id\=3 ue_deregister_type\=switch_off

    Sleep    1s
    Verify UE No Pair Counter Normal    type=MUNONPAIRED_SINRDIFF    counter_id=M55308C00102

CB010653_B_304_Verify_Counter_for_UE_that_cannot_be_Paired_UL_MU_MIMO_because_of_Invalid_SRS_Beams
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/09/13 13:49 p
    [Tags]    304
    Set Test Variable    ${SCFC_NAME}            304.xml
    Set Test Variable    ${AIRPHONE_NAME}        304_ap.xml
    Set Test Variable    ${WTS_NAME}             304_wts.cfg
    Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001
    Set Test Variable    ${GNBCUTYPE}    ${EMPTY}
	Prepare gnb onair

    wait_until_next_5_min
    Start GNB Ttitrace With Streaming Mode
    UE from '1' to '1' SA Register
    Set UE position    ${30N_UE1_PROFILE1}    ${30N_UE1_PROFILE2}
    UE from '2' to '2' SA Register
    Set UE position    ${30N_UE2_PROFILE1}    ${30N_UE2_PROFILE2}
    Airphone SA Start Data Traffic    1    ul   90M   pdu_id=1    trf_id=1
    Airphone SA Start Data Traffic    2    ul   90M   pdu_id=1    trf_id=3
    Set Test Variable    ${cmd1}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 test_type\=UL_MIMO
    Set Test Variable    ${cmd2}    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=15 zenith\=0
    airphone_execute_egate_command    ${cmd1} ${cmd2} srs_transmit_power_per_port\=-660,-660,-660,-660
    airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
    Sleep    3s
    airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=4
    airphone_execute_egate_command      reset
    Sleep    2s
    #Airphone SA Stop Data Traffic    1    UL
    #Airphone SA Stop Data Traffic    2    UL
    #Airphone SA Detach    1
    #Airphone SA Detach    2

    Verify UE No Pair Counter Normal    type=MUNONELIGIBLE_NOSRSBEAM    counter_id=M55308C00103

CB010653_B_305_Verify_Counter_for_UE_that_cannot_be_Paired_UL_MU_MIMO_because_of_GBR_Bears
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/09/13 22:24 p
    [Tags]    305
    Set Test Variable    ${SCFC_NAME}            305.xml
    Set Test Variable    ${AIRPHONE_NAME}        305_ap.xml
    Set Test Variable    ${WTS_NAME}             305_wts.cfg
    Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001
    Set Test Variable    ${GNBCUTYPE}    ${EMPTY}
	Prepare gnb onair

    wait_until_next_5_min
    Start GNB Ttitrace With Streaming Mode
    UE from '1' to '1' SA Register
    Set UE position    ${30N_UE1_PROFILE1}    ${30N_UE1_PROFILE2}
    Airphone SA Start Data Traffic    1    ul   80M   pdu_id=1    trf_id=1

    Airphone SA Attach    ue_id=2
    Airphone Set Traffic Type    2    2    internal
    Airphone Pdu Session Setup    2    2    1    2
    Set UE position    ${30N_UE2_PROFILE1}    ${30N_UE2_PROFILE2}
    Airphone SA Start Data Traffic    2    ul   80M   pdu_id=2    trf_id=3

    Airphone Pdu Session Modify    ue_id=2    pdu_id=2    qosflows_to_add=2    by=amf
    Airphone Pdu Session Modify    ue_id=2    pdu_id=2    qosflows_to_add=3    by=amf
    airphone_execute_egate_command    trf_data_start ue\=2 pdu\=2 qfi\=2 dir\=ul trf_id\=3 mbps\=1
    airphone_execute_egate_command    trf_data_start ue\=2 pdu\=2 qfi\=3 dir\=ul trf_id\=3 mbps\=70
    Sleep    3s
    airphone_execute_egate_command    trf_data_stop ue\=2 pdu\=2 qfi\=2 dir\=ul trf_id\=3
    airphone_execute_egate_command    trf_data_stop ue\=2 pdu\=2 qfi\=3 dir\=ul trf_id\=3
    Airphone Pdu Session Modify    ue_id=2    pdu_id=2    qosflows_to_del=2    by=amf
    Airphone Pdu Session Modify    ue_id=2    pdu_id=2    qosflows_to_del=3    by=amf
    Sleep    3s

    #airphone_execute_egate_command    trf_data_stop ue\=1 pdu\=1 dir\=ul
    #airphone_execute_egate_command    trf_data_stop ue\=2 pdu\=2 dir\=ul
    #Airphone SA Detach    1
    #Airphone SA Detach    2
    airphone_execute_egate_command      reset
    Sleep    3s
    Verify UE No Pair Counter Normal    type=MUNONELIGIBLE_NOTNONGBR    counter_id=M55308C00104

CB010653_B_307_Verify_Counter_for_UE_that_cannot_be_Paired_UL_MU_MIMO_because_of_bad_Correlation
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/09/14 11:06
    [Tags]    307
    Set Test Variable    ${SCFC_NAME}            307.xml
    Set Test Variable    ${AIRPHONE_NAME}        307_ap.xml
    Set Test Variable    ${WTS_NAME}             307_wts.cfg
    Get and Update BSR File		par_of_bsr_name=BSR_AEQV_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    Set Test Variable    ${GNBCUTYPE}    ${EMPTY}
	Prepare gnb onair

    wait_until_next_5_min
    Start GNB Ttitrace With Streaming Mode
    UE from '1' to '1' SA Register
    Set Test Variable    ${cmd1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed
    Airphone Execute Egate Command    ${cmd1} init_quad_pos\=2 init_sub_quad_pos\=2 test_type\=UL_MIMO
    Airphone Execute Egate Command    ${30N_UE1_PROFILE2}
    airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=ul trf_id\=1 mbps\=175

    UE from '2' to '2' SA Register
    Set Test Variable    ${cmd1}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed
    Airphone Execute Egate Command    ${cmd1} init_quad_pos\=2 init_sub_quad_pos\=3 test_type\=UL_MIMO
    Airphone Execute Egate Command    ${30N_UE2_PROFILE2}
    airphone_execute_egate_command    trf_data_start ue\=2 pdu\=1 qfi\=1 dir\=ul trf_id\=2 mbps\=175
    Sleep    3s
    Set Test Variable    ${cmd1}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed
    Airphone Execute Egate Command    ${cmd1} init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=UL_MIMO
    Airphone Execute Egate Command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3

    Airphone Execute Egate Command    ul_sinr_testmode_nr profile_id\=4 sinr_target_pusch\=-350
    Airphone Execute Egate Command    ue_testmode_set_nr id\=2 testmode\=ul_sinr action\=activate profile_id\=4
    Airphone Execute Egate Command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
    Sleep    3s
    Airphone Execute Egate Command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=2
    Airphone Execute Egate Command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
    Sleep    3s
    airphone_execute_egate_command    trf_data_stop ue\=1 pdu\=1 dir\=ul
    airphone_execute_egate_command    trf_data_stop ue\=2 pdu\=2 dir\=ul
    Airphone SA Detach    1
    Airphone SA Detach    2

    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
    Decoder Tttirace From Pcap To Csv    ${pcap_path}    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump
    ${num}    check_target_mustatus_num    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump_ul.csv    type=MUNONPAIRED_BADCORR
    ${num1}    check_target_mustatus_num    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump_ul.csv
    ...    type=MUNONPAIRED_BADCORRORSINRDIFF
    ${sum}    Evaluate    ${num}+${num1}

    wait_until_next_5_min    extra_sleep_time=60
    coam.connect_to    name=GNB_OAM
    ${counters}    coam.get_pm_counters    counter_ids=M55308C00106    connection=GNB_OAM
    coam.teardown    connection=GNB_OAM
    ${counter}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NCELA']['M55308C00106']}
    Should Be True    '${sum}'=='${counter}'

CB010653_B_309_Verify_Counter_for_UE_that_cannot_be_Paired_UL_MU_MIMO_because_of_Low_Number_PRB
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/09/14 21:26    p
    [Tags]    309
    Set Test Variable    ${SCFC_NAME}            309.xml
    Set Test Variable    ${AIRPHONE_NAME}        309_ap.xml
    Set Test Variable    ${WTS_NAME}             309_wts.cfg
    Get and Update BSR File		par_of_bsr_name=BSR_AEQV_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    Set Test Variable    ${GNBCUTYPE}    ${EMPTY}
	Prepare gnb onair

    wait_until_next_5_min
    UE from '1' to '1' SA Register
    Set UE position    ${30N_UE1_PROFILE1}    ${30N_UE1_PROFILE2}
    Airphone SA Start Data Traffic    1    ul   175M   pdu_id=1    trf_id=1
    Airphone SA Attach    ue_id=2
    Airphone Set Traffic Type    2    2    internal
    Airphone Pdu Session Setup    2    2    1    2
    Wait '2s' for stabible
    Set UE position    ${30N_UE2_PROFILE1}    ${30N_UE2_PROFILE2}
    Airphone SA Start Data Traffic    2    ul   175M   pdu_id=2    trf_id=1

    wait_until_next_5_min
    wait_until_next_5_min
    Start GNB Ttitrace With Streaming Mode
    airphone_execute_egate_command    trf_data_stop ue\=2 pdu\=2 dir\=ul trf_id\=1
    Airphone SA Start Data Traffic    2    ul   1M   pdu_id=2    trf_id=3
    Sleep    3s
    Airphone SA Start Data Traffic    2    ul   175M   pdu_id=2    trf_id=4
    Sleep    3s
    airphone_execute_egate_command    trf_data_stop ue\=2 pdu\=1 dir\=ul
    Airphone SA Detach    2
    airphone_execute_egate_command    trf_data_stop ue\=1 pdu\=1 dir\=ul
    Airphone SA Detach    1
    Sleep    3s

    Verify UE No Pair Counter Normal    type=MUNONELIGIBLE_LOWPRBREQ    counter_id=M55308C00108

CB010653_B_310_Verify_Counter_for_UE_that_cannot_be_Paired_UL_MU_MIMO_because_of_Other_Reason
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/09/14 21:39 p
    [Tags]    310
    Set Test Variable    ${SCFC_NAME}            310.xml
    Set Test Variable    ${AIRPHONE_NAME}        310_ap.xml
    Set Test Variable    ${WTS_NAME}             310_wts.cfg
    Get and Update BSR File		par_of_bsr_name=BSR_AEQV_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    Set Test Variable    ${GNBCUTYPE}    ${EMPTY}
	Prepare gnb onair

    wait_until_next_5_min
    UE from '1' to '1' SA Register
    Set UE position    ${30N_UE1_PROFILE1}    ${30N_UE1_PROFILE2}
    airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=ul trf_id\=1 mbps\=175
    UE from '2' to '2' SA Register
    Set UE position    ${30N_UE2_PROFILE1}    ${30N_UE2_PROFILE2}
    airphone_execute_egate_command    trf_data_start ue\=2 pdu\=1 qfi\=1 dir\=ul trf_id\=1 mbps\=175

    UE from '3' to '3' SA Register
    wait_until_next_5_min
    Start GNB Ttitrace With Streaming Mode
    Set UE position    ${30N_UE3_PROFILE1}    ${30N_UE3_PROFILE2}
    airphone_execute_egate_command    trf_data_start ue\=3 pdu\=1 qfi\=1 dir\=ul trf_id\=1 mbps\=175
    Sleep    3s
    airphone_execute_egate_command    trf_data_stop ue\=3 pdu\=1 dir\=ul
    Airphone SA Detach    3
    Verify UE No Pair Counter Normal    type=MUNONELIGIBLE_MAXLAYERREACHED    counter_id=M55308C00109

    airphone_execute_egate_command    trf_data_stop ue\=2 pdu\=1 dir\=ul
    Airphone SA Detach    2
    airphone_execute_egate_command    trf_data_stop ue\=1 pdu\=1 dir\=ul
    Airphone SA Detach    1
    Sleep    2s

CB010653_B_220_Verify_Counter_about_PRB_Usage_for_4_Layer_DL_SU_MIMO_Based_PMQAP and UL_SU_MIMO_Based_PMQAP with 2 _Virtual_Ues
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/11/19 10:19
    [Tags]    220
    Set Test Variable    ${SCFC_NAME}      220_dl.xml
    Set Test Variable    ${AIRPHONE_NAME}    220_apdl.xml
    Set Test Variable    ${WTS_NAME}    220_wts.cfg
    Get and Update BSR File		par_of_bsr_name=BSR_AEQV_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    Set Test Variable    ${GNBCUTYPE}    ${EMPTY}
    Prepare gnb onair

    wait_until_next_5_min
    Set UE position    ${205_UE1_PROFILE1}    ${205_UE1_PROFILE2}
    Set UE position    ${205_UE2_PROFILE1}    ${205_UE2_PROFILE2}
    Set UE position    ${205_UE3_PROFILE1}    ${205_UE3_PROFILE2}
    Set UE position    ${205_UE4_PROFILE1}    ${205_UE4_PROFILE2}
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=1
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1
    airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=csi_override action\=activate profile_id\=1
    airphone_execute_egate_command    ue_testmode_set_nr id\=3 testmode\=csi_override action\=activate profile_id\=1
    airphone_execute_egate_command    ue_testmode_set_nr id\=4 testmode\=csi_override action\=activate profile_id\=1

    Airphone SA Attach    ue_id=1
    airphone_execute_egate_command    set_pdu_param ue\=1 pdu\=1 trf_type\=internal qfi\=1
    Airphone Pdu Session Setup    1    1    1    1
    airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 dir\=dl trf_id\=1 mbps\=175
    airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 dir\=dl trf_id\=2 mbps\=175
    Sleep    1s

    Start GNB Ttitrace With Streaming Mode
    Airphone SA Attach    ue_id=2
    airphone_execute_egate_command    set_pdu_param ue\=2 pdu\=2 trf_type\=internal qfi\=2
    Airphone Pdu Session Setup    2    2    1    2
    airphone_execute_egate_command    trf_data_start ue\=2 pdu\=2 dir\=dl trf_id\=1 mbps\=175
    airphone_execute_egate_command    trf_data_start ue\=2 pdu\=2 dir\=dl trf_id\=2 mbps\=175
    Sleep    1s

    Airphone SA Attach    ue_id=3
    airphone_execute_egate_command    set_pdu_param ue\=3 pdu\=3 trf_type\=internal qfi\=3
    Airphone Pdu Session Setup    3    3    1    3
    airphone_execute_egate_command    trf_data_start ue\=3 pdu\=3 dir\=dl trf_id\=1 mbps\=175
    airphone_execute_egate_command    trf_data_start ue\=3 pdu\=3 dir\=dl trf_id\=2 mbps\=175
    Sleep    1s

    Airphone SA Attach    ue_id=4
    airphone_execute_egate_command    set_pdu_param ue\=4 pdu\=4 trf_type\=internal qfi\=4
    Airphone Pdu Session Setup    4    4    1    4
    airphone_execute_egate_command    trf_data_start ue\=4 pdu\=4 dir\=dl trf_id\=1 mbps\=175
    airphone_execute_egate_command    trf_data_start ue\=4 pdu\=4 dir\=dl trf_id\=2 mbps\=175
    Sleep    1s

    Airphone SA Detach    1
    Airphone SA Detach    2
    Airphone SA Detach    3
    Airphone SA Detach    4
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=deactivate profile_id\=1
    airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=csi_override action\=deactivate profile_id\=1
    airphone_execute_egate_command    ue_testmode_set_nr id\=3 testmode\=csi_override action\=deactivate profile_id\=1
    airphone_execute_egate_command    ue_testmode_set_nr id\=4 testmode\=csi_override action\=deactivate profile_id\=1

    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
    Decoder Tttirace From Pcap To Csv    ${pcap_path}    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump
    ${tti_count}    parse_234ue_dl_csv    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump_dl.csv    ${1}    ${4}

    wait_until_next_5_min    extra_sleep_time=60
    Verify PMQAP Counter Normal    counter_id=M55356C00016    tti_count=${tti_count[4]}    pmqap=4

    Set Test Variable    ${SCFC_NAME}      220_ul.xml
    Set Test Variable    ${AIRPHONE_NAME}    220_apul.xml
    Set Test Variable    ${WTS_NAME}    220_wts.cfg
    Get and Update BSR File		par_of_bsr_name=BSR_AEQV_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    Set Test Variable    ${GNBCUTYPE}    ${EMPTY}
    Prepare gnb onair

    Start GNB Ttitrace With Streaming Mode    filter_mimo=False
    Airphone SA Attach    ue_id=1
    airphone_execute_egate_command    set_pdu_param ue\=1 pdu\=1 trf_type\=internal
    Airphone Pdu Session Setup    1    1    1    1
    Set UE position    ${220_UE1_PROFILE1}    ${220_UE1_PROFILE2}
    airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=ul trf_id\=1 mbps\=90
    Sleep    1s

    Airphone SA Attach    ue_id=2
    airphone_execute_egate_command    set_pdu_param ue\=2 pdu\=1 trf_type\=internal
    Airphone Pdu Session Setup    2    1    1    2
    Set UE position    ${220_UE2_PROFILE1}    ${220_UE2_PROFILE2}
    airphone_execute_egate_command    trf_data_start ue\=2 pdu\=1 qfi\=1 dir\=ul trf_id\=1 mbps\=90
    Sleep    1s

    Airphone SA Attach    ue_id=3
    airphone_execute_egate_command    set_pdu_param ue\=3 pdu\=1 trf_type\=internal
    Airphone Pdu Session Setup    3    1    1    3
    Set UE position    ${220_UE3_PROFILE1}    ${220_UE3_PROFILE2}
    airphone_execute_egate_command    trf_data_start ue\=3 pdu\=1 qfi\=1 dir\=ul trf_id\=1 mbps\=90
    Sleep    1s
    Airphone SA Attach    ue_id=4
    airphone_execute_egate_command    set_pdu_param ue\=4 pdu\=1 trf_type\=internal
    Airphone Pdu Session Setup    4    1    1    4
    Set UE position    ${220_UE4_PROFILE1}    ${220_UE4_PROFILE2}
    airphone_execute_egate_command    trf_data_start ue\=4 pdu\=1 qfi\=1 dir\=ul trf_id\=1 mbps\=90
    Sleep    1s

    Airphone SA Detach    1
    Airphone SA Detach    2
    Airphone SA Detach    3
    Airphone SA Detach    4

    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
    Decoder Tttirace From Pcap To Csv    ${pcap_path}    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump
    ${tti_count}    parse_4ue_ul_csv    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump_ul.csv    ${1}    ${4}

    wait_until_next_5_min    extra_sleep_time=60
    Verify PMQAP Counter Normal    counter_id=M55356C00031    tti_count=${tti_count[4]}    pmqap=4

CB010653_B_215_Verify_Counter_about_PRB_Usage_for_2_Layer_DL_and_UL_MU_MIMO_Based_PMQAP_and_None_PMQAP
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/09/29 13:32
    [Tags]    215
    Set Test Variable    ${SCFC_NAME}      215.xml
    Set Test Variable    ${AIRPHONE_NAME}    215_ap.xml
    Set Test Variable    ${WTS_NAME}    215_wts.cfg
    Get and Update BSR File		par_of_bsr_name=BSR_AEQV_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    Set Test Variable    ${GNBCUTYPE}    ${EMPTY}
    Prepare gnb onair

    wait_until_next_5_min
    Set UE position    ${213_UE1_PROFILE1}    ${213_UE1_PROFILE2}
    Set UE position    ${213_UE2_PROFILE1}    ${213_UE2_PROFILE2}
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=0
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1
    airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=csi_override action\=activate profile_id\=1

    Start GNB Ttitrace With Streaming Mode
    Airphone SA Attach    ue_id=1
    airphone_execute_egate_command    set_pdu_param ue\=1 pdu\=1 trf_type\=internal qfi\=1
    Airphone Pdu Session Setup    1    1    1    1
    Airphone Pdu Session Modify    ue_id=1    pdu_id=1    qosflows_to_add=2    by=amf
    get UE '1' rnti in RRC log
    Sleep    2s
    Airphone SA Attach    ue_id=2
    airphone_execute_egate_command    set_pdu_param ue\=2 pdu\=1 trf_type\=internal qfi\=3
    Airphone Pdu Session Setup    2    1    1    2
    Airphone Pdu Session Modify    ue_id=2    pdu_id=1    qosflows_to_add=4    by=amf
    get UE '2' rnti in RRC log

    airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl trf_id\=1 mbps\=175 seconds\=3600
    airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl trf_id\=2 mbps\=175 seconds\=3600
    airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl trf_id\=3 mbps\=175 seconds\=3600
    airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=2 dir\=dl trf_id\=1 mbps\=100 seconds\=3600
    airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=2 dir\=dl trf_id\=2 mbps\=100 seconds\=3600
    airphone_execute_egate_command    trf_data_start ue\=2 pdu\=1 qfi\=1 dir\=dl trf_id\=1 mbps\=175 seconds\=3600
    airphone_execute_egate_command    trf_data_start ue\=2 pdu\=1 qfi\=1 dir\=dl trf_id\=2 mbps\=175 seconds\=3600
    airphone_execute_egate_command    trf_data_start ue\=2 pdu\=1 qfi\=1 dir\=dl trf_id\=3 mbps\=175 seconds\=3600
    airphone_execute_egate_command    trf_data_start ue\=2 pdu\=1 qfi\=1 dir\=dl trf_id\=4 mbps\=175 seconds\=3600
    airphone_execute_egate_command    trf_data_start ue\=2 pdu\=1 qfi\=2 dir\=dl trf_id\=1 mbps\=100 seconds\=3600
    airphone_execute_egate_command    trf_data_start ue\=2 pdu\=1 qfi\=2 dir\=dl trf_id\=2 mbps\=100 seconds\=3600
    Sleep    2s
    Airphone SA Detach    1
    Airphone SA Detach    2

    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
    Decoder Tttirace From Pcap To Csv    ${pcap_path}    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump
    ${tti_count}    parse_2ue_dl_csv    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump_dl.csv    ${1}    ${2}

    wait_until_next_5_min    extra_sleep_time=60
    coam.connect_to    name=GNB_OAM
    ${counters}    coam.get_pm_counters    counter_ids=M55356C00014    connection=GNB_OAM
    coam.teardown    connection=GNB_OAM
    ${p1}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-1']['UESPQ']['M55356C00014']}
    ${p2}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-2']['UESPQ']['M55356C00014']}
    ${p3}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-3']['UESPQ']['M55356C00014']}
    ${p4}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-4']['UESPQ']['M55356C00014']}
    Compare Values Within Range    ${p1}    ${tti_count[${rnti_1}][4]}
    Compare Values Within Range    ${p2}    ${tti_count[${rnti_1}][5]}
    Compare Values Within Range    ${p3}    ${tti_count[${rnti_2}][4]}
    Compare Values Within Range    ${p4}    ${tti_count[${rnti_2}][5]}

    Set Test Variable    ${SCFC_NAME}      215_ul.xml
    Set Test Variable    ${AIRPHONE_NAME}    215_apul.xml
    Set Test Variable    ${WTS_NAME}    215_wts.cfg
    Get and Update BSR File		par_of_bsr_name=BSR_AEQV_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    Prepare gnb onair

    Start GNB Ttitrace With Streaming Mode    filter_mimo=False
    Set UE position    ${30N_UE1_PROFILE1}    ${30N_UE1_PROFILE2}
    Airphone SA Attach    ue_id=1
    airphone_execute_egate_command    set_pdu_param ue\=1 pdu\=1 trf_type\=internal qfi\=1
    Airphone Pdu Session Setup    1    1    1    1
    Airphone Pdu Session Modify    ue_id=1    pdu_id=1    qosflows_to_add=2    by=amf
    get UE '1' rnti in RRC log
    Sleep    2s
    Airphone SA Attach    ue_id=2
    airphone_execute_egate_command    set_pdu_param ue\=2 pdu\=1 trf_type\=internal qfi\=3
    Airphone Pdu Session Setup    2    1    1    2
    Airphone Pdu Session Modify    ue_id=2    pdu_id=1    qosflows_to_add=4    by=amf
    get UE '2' rnti in RRC log
    Set UE position    ${30N_UE2_PROFILE1}    ${30N_UE2_PROFILE2}
    airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=ul trf_id\=1 mbps\=175
    airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=2 dir\=ul trf_id\=1 mbps\=175
    airphone_execute_egate_command    trf_data_start ue\=2 pdu\=1 qfi\=1 dir\=ul trf_id\=1 mbps\=175
    airphone_execute_egate_command    trf_data_start ue\=2 pdu\=1 qfi\=2 dir\=ul trf_id\=1 mbps\=175
    Sleep    3s
    Airphone SA Detach    1
    Airphone SA Detach    2
    Sleep    1s
    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
    Decoder Tttirace From Pcap To Csv    ${pcap_path}    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump
    ${tti_count}    parse_2ue_ul_csv    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump_ul.csv    ${1}    ${2}

    wait_until_next_5_min    extra_sleep_time=60
    coam.connect_to    name=GNB_OAM
    ${counters}    coam.get_pm_counters    counter_ids=M55356C00029    connection=GNB_OAM
    coam.teardown    connection=GNB_OAM
    ${p1}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-1']['UESPQ']['M55356C00029']}
    ${p2}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-2']['UESPQ']['M55356C00029']}
    ${p3}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-3']['UESPQ']['M55356C00029']}
    ${p4}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-4']['UESPQ']['M55356C00029']}
    Compare Values Within Range    ${p1}    ${tti_count[${rnti_1}][4]}
    Compare Values Within Range    ${p2}    ${tti_count[${rnti_1}][5]}
    Compare Values Within Range    ${p3}    ${tti_count[${rnti_2}][4]}
    Compare Values Within Range    ${p4}    ${tti_count[${rnti_2}][5]}

CB010653_B_213_Verify_Counter_about_PRB_Usage_for_4_Layer_DL_MU_MIMO_Based_PMQAP_and_None_PMQAP
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/09/11 22:39 p
    [Tags]    213
    Set Test Variable    ${SCFC_NAME}      213.xml
    Set Test Variable    ${AIRPHONE_NAME}    213_ap.xml
    Set Test Variable    ${WTS_NAME}    213_wts.cfg
    Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001
    Set Test Variable    ${GNBCUTYPE}    ${EMPTY}
    Prepare gnb onair

    wait_until_next_5_min
    Set UE position    ${213_UE1_PROFILE1}    ${213_UE1_PROFILE2}
    Set UE position    ${213_UE2_PROFILE1}    ${213_UE2_PROFILE2}
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=1
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1
    airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=csi_override action\=activate profile_id\=1

    UE from '1' to '1' SA Register
    Start GNB Ttitrace With Streaming Mode
    UE from '2' to '2' SA Register
    Airphone SA Start Data Traffic    1    DL   170M   pdu_id=1    duration=3600   trf_id=1
    Airphone SA Start Data Traffic    1    DL   100M   pdu_id=1    duration=3600   trf_id=2
    Airphone SA Start Data Traffic    2    DL   170M   pdu_id=1    duration=3600   trf_id=1
    Airphone SA Start Data Traffic    2    DL   100M   pdu_id=1    duration=3600   trf_id=2
    Airphone SA Stop Data Traffic    1    DL
    Airphone SA Stop Data Traffic    2    DL
    Sleep    2s
    Airphone SA Detach    1
    Airphone SA Detach    2

    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
    Decoder Tttirace From Pcap To Csv    ${pcap_path}    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump
    ${tti_count}    parse_2ue_dl_csv    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump_dl.csv    ${1}    ${4}    False

    wait_until_next_5_min    extra_sleep_time=60
    Verify PMQAP Counter Normal    counter_id=M55356C00016    tti_count=${tti_count[44]}    pmqap=5

CB010653_B_210_Verify_Counter_about_PRB_Usage_for_7_Layer_DL_MU_MIMO_Based_PMQAP_and_None_PMQAP
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/09/20 09:30
    [Tags]    210
    Set Test Variable    ${SCFC_NAME}            210.xml
    Set Test Variable    ${AIRPHONE_NAME}        210_ap.xml
    Set Test Variable    ${WTS_NAME}             210_wts.cfg
    Get and Update BSR File		par_of_bsr_name=BSR_AEQV_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    Set Test Variable    ${GNBCUTYPE}    ${EMPTY}
    Prepare gnb onair

    wait_until_next_5_min
    Set UE position    ${209_UE1_PROFILE1}    ${209_UE1_PROFILE2}
    Set UE position    ${209_UE2_PROFILE1}    ${209_UE2_PROFILE2}
    Set UE position    ${209_UE3_PROFILE1}    ${209_UE3_PROFILE2}

    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=3
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 ri\=2
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1
    airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=csi_override action\=activate profile_id\=2

    Start GNB Ttitrace With Streaming Mode
    Airphone SA Attach    ue_id=1
    airphone_execute_egate_command    set_pdu_param ue\=1 pdu\=1 trf_type\=internal qfi\=1
    Airphone Pdu Session Setup    1    1    1    1
    Airphone Pdu Session Modify    ue_id=1    pdu_id=1    qosflows_to_add=2    by=amf
    Sleep    2s
    Airphone SA Attach    ue_id=3
    airphone_execute_egate_command    set_pdu_param ue\=3 pdu\=1 trf_type\=internal qfi\=3
    Airphone Pdu Session Setup    3    1    1    3
    Airphone Pdu Session Modify    ue_id=3    pdu_id=1    qosflows_to_add=4    by=amf
    airphone_execute_egate_command    trf_data_start ue\=3 pdu\=1 qfi\=1 dir\=ul trf_id\=3 mbps\=10
    airphone_execute_egate_command    trf_data_start ue\=3 pdu\=1 qfi\=2 dir\=ul trf_id\=3 mbps\=90
    Sleep    2s
    Airphone SA Attach    ue_id=2
    airphone_execute_egate_command    set_pdu_param ue\=2 pdu\=1 trf_type\=internal qfi\=1
    Airphone Pdu Session Setup    2    1    1    2
    Airphone Pdu Session Modify    ue_id=2    pdu_id=1    qosflows_to_add=2    by=amf
    Sleep    2s
    airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl trf_id\=1 mbps\=175 seconds\=3600
    airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl trf_id\=2 mbps\=175 seconds\=3600
    airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl trf_id\=3 mbps\=175 seconds\=3600
    airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl trf_id\=4 mbps\=175 seconds\=3600
    airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl trf_id\=5 mbps\=175 seconds\=3600
    airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl trf_id\=6 mbps\=175 seconds\=3600
    Sleep    2s
    airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=2 dir\=dl trf_id\=1 mbps\=175 seconds\=3600
    airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=2 dir\=dl trf_id\=2 mbps\=175 seconds\=3600
    airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=2 dir\=dl trf_id\=3 mbps\=175 seconds\=3600
    airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=2 dir\=dl trf_id\=4 mbps\=175 seconds\=3600
    airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=2 dir\=dl trf_id\=5 mbps\=175 seconds\=3600
    Sleep    2s
    airphone_execute_egate_command    trf_data_start ue\=2 pdu\=1 qfi\=1 dir\=dl trf_id\=1 mbps\=175 seconds\=3600
    airphone_execute_egate_command    trf_data_start ue\=2 pdu\=1 qfi\=1 dir\=dl trf_id\=2 mbps\=175 seconds\=3600
    airphone_execute_egate_command    trf_data_start ue\=2 pdu\=1 qfi\=1 dir\=dl trf_id\=3 mbps\=175 seconds\=3600
    airphone_execute_egate_command    trf_data_start ue\=2 pdu\=1 qfi\=1 dir\=dl trf_id\=4 mbps\=175 seconds\=3600
    airphone_execute_egate_command    trf_data_start ue\=2 pdu\=1 qfi\=1 dir\=dl trf_id\=5 mbps\=175 seconds\=3600
    Sleep    2s
    airphone_execute_egate_command    trf_data_start ue\=2 pdu\=1 qfi\=2 dir\=dl trf_id\=1 mbps\=175 seconds\=3600
    airphone_execute_egate_command    trf_data_start ue\=2 pdu\=1 qfi\=2 dir\=dl trf_id\=2 mbps\=175 seconds\=3600
    airphone_execute_egate_command    trf_data_start ue\=2 pdu\=1 qfi\=2 dir\=dl trf_id\=3 mbps\=175 seconds\=3600
    airphone_execute_egate_command    trf_data_start ue\=2 pdu\=1 qfi\=2 dir\=dl trf_id\=4 mbps\=175 seconds\=3600
    Sleep    3s

    airphone_execute_egate_command    ue_deregister id\=1 ue_deregister_type\=switch_off
    airphone_execute_egate_command    ue_deregister id\=2 ue_deregister_type\=switch_off
    airphone_execute_egate_command    ue_deregister id\=3 ue_deregister_type\=switch_off
    Sleep    5s

    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
    Decoder Tttirace From Pcap To Csv    ${pcap_path}    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump
    ${tti_count}    parse_2ue_dl_csv    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump_dl.csv    lcrId=${1}    layer=${7}

    wait_until_next_5_min    extra_sleep_time=60
    Verify PMQAP Counter Normal    counter_id=M55356C00019    tti_count=${tti_count[44]}    pmqap=4
    Verify PMQAP Counter Normal    counter_id=M55356C00019    tti_count=${tti_count[55]}    pmqap=3

CB010653_B_209_Verify_Counter_about_PRB_Usage_for_8_Layer_DL_MU_MIMO_Based_PMQAP_and_None_PMQAP
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/09/10 13:20
    [Tags]    209
    Set Test Variable    ${SCFC_NAME}            209.xml
    Set Test Variable    ${AIRPHONE_NAME}        209_ap.xml
    Set Test Variable    ${WTS_NAME}             209_wts.cfg
    Get and Update BSR File		par_of_bsr_name=BSR_AEQV_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    Set Test Variable    ${GNBCUTYPE}    ${EMPTY}
    Prepare gnb onair

    wait_until_next_5_min
    Set UE position    ${209_UE1_PROFILE1}    ${209_UE1_PROFILE2}
    Set UE position    ${209_UE2_PROFILE1}    ${209_UE2_PROFILE2}
    Set UE position    ${209_UE3_PROFILE1}    ${209_UE3_PROFILE2}
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=3
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 ri\=1
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1
    airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=csi_override action\=activate profile_id\=2
    airphone_execute_egate_command    ue_testmode_set_nr id\=3 testmode\=csi_override action\=activate profile_id\=2

    UE from '1' to '1' SA Register
    UE from '2' to '2' SA Register
    Start GNB Ttitrace With Streaming Mode
    UE from '3' to '3' SA Register

    Airphone SA Start Data Traffic With Multi TRF    trf_num=5    ue=1    pdu=1
    Airphone SA Start Data Traffic With Multi TRF    trf_num=3    ue=2    pdu=1
    Airphone SA Start Data Traffic With Multi TRF    trf_num=2    ue=3    pdu=1
    Sleep    1s
    Airphone SA Detach    1
    Sleep    1s
    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
    Decoder Tttirace From Pcap To Csv    ${pcap_path}    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump
    ${tti_count}    parse_3ue_dl_csv    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump_dl.csv    lcrId=${1}    layer=${8}
    ${tti2_count}    parse_3ue_dl_csv    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump_dl.csv    lcrId=${2}    layer=${8}

    airphone_execute_egate_command    ue_testmode_set_nr id\=2 scell\=0,1 testmode\=csi_override action\=activate profile_id\=1
    Airphone SA Start Data Traffic    2    DL   100M   pdu_id=1    duration=3600   trf_id=4
    Airphone SA Detach    2
    Airphone SA Detach    3

    wait_until_next_5_min    extra_sleep_time=60
    coam.connect_to    name=GNB_OAM
    ${counters}    coam.get_pm_counters    counter_ids=M55308C34009,M55356C00018,M55356C00020    connection=GNB_OAM
    coam.teardown    connection=GNB_OAM
    ${counter}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-3']['UESPQ']['M55356C00020']}
    ${counter2}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-2']['NRPMQAP-3']['UESPQ']['M55356C00020']}
    Should Be True    '${tti_count[8]}'=='${counter}'
    Should Be True    '${tti2_count[8]}'=='${counter2}'
    ${counter09}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NCELA']['M55308C34009']}
    ${counter18}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-3']['UESPQ']['M55356C00018']}
    Should Be True    0.99<${counter09}/${counter18}<1.01

    ${counter09}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-2']['NCELA']['M55308C34009']}
    ${counter18}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-2']['NRPMQAP-3']['UESPQ']['M55356C00018']}
    Should Be True    0.99<${counter09}/${counter18}<1.01

CB010653_B_205_Verify_Counter_about_PRB_Usage_for_12_Layer_DL_MU_MIMO_Based_PMQAP_and_None_PMQAP
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/09/20 13:13
    [Tags]    205
    Set Test Variable    ${SCFC_NAME}            205.xml
    Set Test Variable    ${AIRPHONE_NAME}        205_ap.xml
    Set Test Variable    ${WTS_NAME}             205_wts.cfg
    Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001
    Set Test Variable    ${GNBCUTYPE}    ${EMPTY}
    Prepare gnb onair

    wait_until_next_5_min
    Set UE position    ${205_UE1_PROFILE1}    ${205_UE1_PROFILE2}
    Set UE position    ${205_UE2_PROFILE1}    ${205_UE2_PROFILE2}
    Set UE position    ${205_UE3_PROFILE1}    ${205_UE3_PROFILE2}
    Set UE position    ${205_UE4_PROFILE1}    ${205_UE4_PROFILE2}
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=3
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 ri\=1
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1
    airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=csi_override action\=activate profile_id\=1
    airphone_execute_egate_command    ue_testmode_set_nr id\=3 testmode\=csi_override action\=activate profile_id\=2
    airphone_execute_egate_command    ue_testmode_set_nr id\=4 testmode\=csi_override action\=activate profile_id\=2

    Airphone SA Attach    ue_id=1
    airphone_execute_egate_command    set_pdu_param ue\=1 pdu\=1 trf_type\=internal qfi\=1
    Airphone Pdu Session Setup    1    1    1    1

    Airphone SA Attach    ue_id=2
    airphone_execute_egate_command    set_pdu_param ue\=2 pdu\=2 trf_type\=internal qfi\=2
    Airphone Pdu Session Setup    2    2    1    2

    Airphone SA Attach    ue_id=3
    airphone_execute_egate_command    set_pdu_param ue\=3 pdu\=3 trf_type\=internal qfi\=3
    Airphone Pdu Session Setup    3    3    1    3

    Start GNB Ttitrace With Streaming Mode
    Airphone SA Attach    ue_id=4
    airphone_execute_egate_command    set_pdu_param ue\=4 pdu\=4 trf_type\=internal qfi\=4
    Airphone Pdu Session Setup    4    4    1    4

    Airphone SA Start Data Traffic With Multi TRF    trf_num=5    ue=1    pdu=1
    Airphone SA Start Data Traffic With Multi TRF    trf_num=3    ue=2    pdu=2
    Airphone SA Start Data Traffic With Multi TRF    trf_num=3    ue=3    pdu=3
    Airphone SA Start Data Traffic With Multi TRF    trf_num=3    ue=4    pdu=4
    Sleep    1s

    airphone_execute_egate_command    ue_stats_nr id\=1-5 type\=pdsch
    Sleep    1s
    airphone_execute_egate_command    bler_testmode_nr profile_id\=1 dl_bler\=50
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 scell\=0 testmode\=bler profile_id\=1 action\=activate
    airphone_execute_egate_command    ue_testmode_set_nr id\=2 scell\=0 testmode\=bler profile_id\=1 action\=activate
    airphone_execute_egate_command    ue_testmode_set_nr id\=3 scell\=0 testmode\=bler profile_id\=1 action\=activate
    airphone_execute_egate_command    ue_testmode_set_nr id\=4 scell\=0 testmode\=bler profile_id\=1 action\=activate
    Sleep    1s
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 scell\=0 testmode\=bler profile_id\=1 action\=deactivate
    airphone_execute_egate_command    ue_testmode_set_nr id\=2 scell\=0 testmode\=bler profile_id\=1 action\=deactivate
    airphone_execute_egate_command    ue_testmode_set_nr id\=3 scell\=0 testmode\=bler profile_id\=1 action\=deactivate
    airphone_execute_egate_command    ue_testmode_set_nr id\=4 scell\=0 testmode\=bler profile_id\=1 action\=deactivate
    airphone_execute_egate_command    ue_testmode_set_nr id\=4 testmode\=csi_override action\=deactivate profile_id\=2
    airphone_execute_egate_command    trf_data_start ue\=4 pdu\=4 dir\=dl trf_id\=4 mbps\=175 seconds\=3600
    Sleep    1s
    airphone_execute_egate_command    ue_testmode_set_nr id\=4 testmode\=csi_override action\=activate profile_id\=2
    Airphone SA Detach    1
    Airphone SA Detach    2
    Airphone SA Detach    3
    Airphone SA Detach    4
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=deactivate profile_id\=1
    airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=csi_override action\=deactivate profile_id\=1
    airphone_execute_egate_command    ue_testmode_set_nr id\=3 testmode\=csi_override action\=deactivate profile_id\=2
    airphone_execute_egate_command    ue_testmode_set_nr id\=4 testmode\=csi_override action\=deactivate profile_id\=2
    Sleep    2s
    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
    Decoder Tttirace From Pcap To Csv    ${pcap_path}    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump

    wait_until_next_5_min    extra_sleep_time=60
    coam.connect_to    name=GNB_OAM
    ${counters}    coam.get_pm_counters    counter_ids=M55356C00024    connection=GNB_OAM
    coam.teardown    connection=GNB_OAM

CB010653_B_203_Verify_Counter_about_PRB_Usage_for_14_Layer_DL_MU_MIMO_Based_PMQAP_and_None_PMQAP
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/09/10 14:50 p
    [Tags]    203
    Set Test Variable    ${SCFC_NAME}      203.xml
    Set Test Variable    ${AIRPHONE_NAME}    203_ap.xml
    Set Test Variable    ${WTS_NAME}    203_wts.cfg
    Get and Update BSR File		par_of_bsr_name=BSR_AQQL_4_H3H1_ALN60_ARP60_P00_COVERAGE_00442_00002
    Set Test Variable    ${GNBCUTYPE}    ${EMPTY}
    Prepare gnb onair

    wait_until_next_5_min
    Set UE position    ${203_UE1_PROFILE1}    ${203_UE1_PROFILE2}
    Set UE position    ${203_UE2_PROFILE1}    ${203_UE2_PROFILE2}
    Set UE position    ${203_UE3_PROFILE1}    ${203_UE3_PROFILE2}
    Set UE position    ${203_UE4_PROFILE1}    ${203_UE4_PROFILE2}
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 ri\=1
    airphone_execute_egate_command    ue_testmode_set_nr id\=14 testmode\=csi_override action\=activate profile_id\=2

    Airphone NSA Attach    ue_id=11
    airphone_execute_egate_command    ue_dc_enb_start ue\=11 target_gnb\=2 target_cells\=1 bearer\=2 type\=split_scg
    Airphone NSA Start Data Traffic    11    DL   175M   trf_id=1
    Airphone NSA Start Data Traffic    11    DL   175M   trf_id=2
    Airphone NSA Start Data Traffic    11    DL   175M   trf_id=3
    Airphone NSA Attach    ue_id=12
    airphone_execute_egate_command    ue_dc_enb_start ue\=12 target_gnb\=2 target_cells\=1 bearer\=2 type\=split_scg
    Airphone NSA Start Data Traffic    12    DL   175M   trf_id=1
    Airphone NSA Start Data Traffic    12    DL   175M   trf_id=2
    Airphone NSA Start Data Traffic    12    DL   175M   trf_id=3
    Airphone NSA Attach    ue_id=13
    airphone_execute_egate_command    ue_dc_enb_start ue\=13 target_gnb\=2 target_cells\=1 bearer\=2 type\=split_scg
    Airphone NSA Start Data Traffic    13    DL   175M   trf_id=1
    Airphone NSA Start Data Traffic    13    DL   175M   trf_id=2
    Airphone NSA Start Data Traffic    13    DL   175M   trf_id=3

    Start GNB Ttitrace With Streaming Mode
    Airphone NSA Attach    ue_id=14
    airphone_execute_egate_command    ue_dc_enb_start ue\=14 target_gnb\=2 target_cells\=1 bearer\=2 type\=split_scg
    Airphone NSA Start Data Traffic    14    DL   175M    trf_id=1
    Airphone NSA Start Data Traffic    14    DL   175M    trf_id=2
    Airphone NSA Start Data Traffic    14    DL   175M    trf_id=3
    Sleep    2s
    Airphone NSA Stop Data Traffic    11    DL
    Airphone NSA Stop Data Traffic    12    DL
    Airphone NSA Stop Data Traffic    13    DL
    Airphone NSA Stop Data Traffic    14    DL
    Sleep    2s
    Airphone NSA Detach    11
    Airphone NSA Detach    12
    Airphone NSA Detach    13
    Airphone NSA Detach    14
    Sleep    2s
    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
    Decoder Tttirace From Pcap To Csv    ${pcap_path}    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump
    ${tti_count}    parse_4ue_dl_csv    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump_dl.csv    lcrId=${1}    layer=${14}

    wait_until_next_5_min    extra_sleep_time=60
    Verify PMQAP Counter Normal    counter_id=M55356C00026    tti_count=${tti_count[12]}    pmqap=1

CB010653_B_201_Verify_Counter_about_PRB_Usage_for_16_Layer_DL_MU_MIMO_Based_PMQAP_and_None_PMQAP
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/09/19 14:53
    [Tags]    201
    Set Test Variable    ${SCFC_NAME}       201.xml
    Set Test Variable    ${AIRPHONE_NAME}   201_ap.xml
    Set Test Variable    ${WTS_NAME}        201_wts.cfg
    Get and Update BSR File		par_of_bsr_name=BSR_AQQL_4_H3H1_ALN60_ARP60_P00_COVERAGE_00442_00002
    Set Test Variable    ${GNBCUTYPE}    ${EMPTY}
    Prepare gnb onair

    wait_until_next_5_min
    201 Common Steps
    Sleep    2s
    Airphone NSA Stop Data Traffic    11    DL
    Airphone NSA Stop Data Traffic    12    DL
    Airphone NSA Stop Data Traffic    13    DL
    Airphone NSA Stop Data Traffic    14    DL
    Sleep    2s
    Airphone NSA Detach    11
    Airphone NSA Detach    12
    Airphone NSA Detach    13
    Airphone NSA Detach    14
    Sleep    2s
    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
    Decoder Tttirace From Pcap To Csv    ${pcap_path}    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump
    ${tti_count}    parse_4ue_dl_csv    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump_dl.csv    lcrId=${1}    layer=${16}

    wait_until_next_5_min    extra_sleep_time=60
    Verify PMQAP Counter Normal    counter_id=M55356C00028    tti_count=${tti_count[16]}    pmqap=1

    Prepare gnb onair
    201 Common Steps    start_tti=False
    Sleep    2s
    Airphone NSA Stop Data Traffic    14    DL
    Sleep    2s
    Airphone NSA Detach    14
    wait_until_next_5_min
    wait_until_next_5_min    extra_sleep_time=60
    coam.connect_to    name=GNB_OAM
    ${counters}    coam.get_pm_counters    counter_ids=M55308C34023,M55356C00028
    ...    connection=GNB_OAM
    coam.teardown    connection=GNB_OAM
    ${counter_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NCELA']}
    Should Be True    ${counter_values['M55308C34023']}==0
    ${counter_values}    Get Recent Multi Counters Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-1']['UESPQ']}
    Should Be True    ${counter_values['M55356C00028']}==0
    Airphone NSA Stop Data Traffic    11    DL
    Airphone NSA Stop Data Traffic    12    DL
    Airphone NSA Stop Data Traffic    13    DL
    Airphone NSA Detach    11
    Airphone NSA Detach    12
    Airphone NSA Detach    13

    Prepare gnb onair
    Start GNB Ttitrace With Streaming Mode    filter_mimo=False
    201 Common Steps    start_tti=False
    Airphone NSA Stop Data Traffic    12    DL
    Airphone NSA Stop Data Traffic    13    DL
    Airphone NSA Stop Data Traffic    14    DL
    Airphone NSA Detach    12
    Airphone NSA Detach    13
    Airphone NSA Detach    14
    Sleep    1s
    Airphone NSA Stop Data Traffic    11    DL
    Airphone NSA Detach    11
    Sleep    2s
    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
    Decoder Tttirace From Pcap To Csv    ${pcap_path}    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump
    wait_until_next_5_min    extra_sleep_time=60
    coam.connect_to    name=GNB_OAM
    ${counters}    coam.get_pm_counters    counter_ids=M55308C00097,M55308C00098,M55356C00011,M55356C00012
    ...    connection=GNB_OAM
    coam.teardown    connection=GNB_OAM
    ${c_97}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NCELA']['M55308C00097']}
    ${c_98}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NCELA']['M55308C00098']}
    ${c_11}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-1']['UESPQ']['M55356C00011']}
    ${c_12}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-1']['UESPQ']['M55356C00012']}
    Compare Values Within Range    ${c_97}    ${c_11}
    ${num}    check_layer_num    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump_ul.csv    RANK1
    Compare Values Within Range    ${c_98}    ${num}
    ${num}    check_rcvd_num    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump_ul.csv
    Compare Values Within Range    ${c_12}    ${num}

CB010653_A_103_Verify_Counters_of_SRS_Power_Distribution_for_TAS_SB_SRS_Beam_When_CA_used
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/09/12 15:29
    [Tags]    103
    Set Test Variable    ${SCFC_NAME}            103.xml
    Set Test Variable    ${AIRPHONE_NAME}        103_ap.xml
    Set Test Variable    ${WTS_NAME}             103_wts.cfg
    Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001
    Set Test Variable    ${GNBCUTYPE}    ${EMPTY}
    Prepare gnb onair

    wait_until_next_5_min
    UE from '1' to '1' SA Register
    Airphone SA Start Data Traffic    1    UL   50M   pdu_id=1
    Airphone SA Start Data Traffic With Multi TRF    trf_num=8

    UE from '2' to '2' SA Register
    Airphone SA Start Data Traffic    2    UL   50M   pdu_id=1
    Airphone SA Start Data Traffic With Multi TRF    trf_num=8    ue=2    pdu=1

    Set Test Variable    ${cmd1}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=1 test_type\=SRS
    Set Test Variable    ${cmd2}    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=15 zenith\=0
    airphone_execute_egate_command     ${cmd1} ${cmd2} srs_transmit_power_per_port\=-153,-153,-153,-153
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
    airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
    wait_until_next_5_min
    wait_until_next_5_min    extra_sleep_time=60
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=2
    airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=2

    coam.connect_to    name=GNB_OAM
    ${counters}    coam.get_pm_counters    counter_ids=M55371C00090,M55371C00128,M55371C00085,M55371C00123
    ...    connection=GNB_OAM
    coam.teardown    connection=GNB_OAM
    ${c1_90}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NSRS']['M55371C00090']}
    ${c1_128}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NSRS']['M55371C00128']}
    ${c2_90}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-2']['NSRS']['M55371C00090']}
    ${c2_128}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-2']['NSRS']['M55371C00128']}
    Compare Values Within Range    ${c1_90}    30000    200
    Compare Values Within Range    ${c1_128}    60000    400
    Should Be True    ${c2_90}==None
    Should Be True    ${c2_128}==None

    Set Test Variable    ${cmd1}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=2 test_type\=SRS
    Set Test Variable    ${cmd2}    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=15 zenith\=0
    airphone_execute_egate_command    ${cmd1} ${cmd2} srs_transmit_power_per_port\=-256,-256,-256,-256
    airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
    wait_until_next_5_min
    wait_until_next_5_min    extra_sleep_time=60
    airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=3

    Airphone SA Stop Data Traffic    1    DL
    airphone_execute_egate_command    trf_data_stop ue\=1 pdu\=1 dir\=ul
    Airphone SA Detach    1
    Airphone SA Stop Data Traffic    2    DL
    airphone_execute_egate_command    trf_data_stop ue\=2 pdu\=1 dir\=ul
    Airphone SA Detach    2

    coam.connect_to    name=GNB_OAM
    ${counters}    coam.get_pm_counters    counter_ids=M55371C00090,M55371C00128,M55371C00085,M55371C00123
    ...    connection=GNB_OAM
    coam.teardown    connection=GNB_OAM
    ${c1_85}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NSRS']['M55371C00085']}
    ${c1_123}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NSRS']['M55371C00123']}
    ${c2_85}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-2']['NSRS']['M55371C00085']}
    ${c2_123}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-2']['NSRS']['M55371C00123']}
    Compare Values Within Range    ${c1_85}    15000    100
    Compare Values Within Range    ${c1_123}    30000    200
    Should Be True    ${c2_85}==None
    Should Be True    ${c2_123}==None

CB010653_A_105_Verify_Counters_For_Count_The_Number_Of_UE_That_Configure_UE_Specific_CSI-RS
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/09/23 10:51
    [Tags]    105
    Set Test Variable    ${SCFC_NAME}            105.xml
    Set Test Variable    ${AIRPHONE_NAME}        105_ap.xml
    Set Test Variable    ${WTS_NAME}             105_wts.cfg
    Get and Update BSR File		par_of_bsr_name=BSR_AQQL_4_H3H1_ALN60_ARP60_P00_COVERAGE_00442_00002
    Set Test Variable    ${GNBCUTYPE}    ${EMPTY}
    Prepare gnb onair

    wait_until_next_5_min
    Batch Execute AP CMDS With Sleep Time    ${A_105_AP_CMDS_WITH_SLEEP_TIME_STEP1}
    Airphone SA Start Data Traffic With Multi TRF    trf_num=2    ue=1
    Airphone SA Start Data Traffic With Multi TRF    trf_num=2    ue=2
    Airphone SA Start Data Traffic With Multi TRF    trf_num=2    ue=3
    wait_until_next_5_min
    wait_until_next_5_min    extra_sleep_time=60
    coam.connect_to    name=GNB_OAM
    ${counters}    coam.get_pm_counters    counter_ids=M55196C00014,M55196C00015,M55196C00016,M55196C00019
    ...    connection=GNB_OAM
    coam.teardown    connection=GNB_OAM
    ${counter_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NBFC']}
    Compare Values Within Range    ${counter_values['M55196C00014']}    600    4
    Compare Values Within Range    ${counter_values['M55196C00015']}    600    4
    Should Be True    ${counter_values['M55196C00016']}==2
    Compare Values Within Range    ${counter_values['M55196C00019']}    300    2
    ${counter_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-2']['NBFC']}
    Should Be True    ${counter_values['M55196C00014']}==0
    Should Be True    ${counter_values['M55196C00015']}==0
    Should Be True    ${counter_values['M55196C00016']}==0
    Compare Values Within Range    ${counter_values['M55196C00019']}    300    2
    Batch Execute AP CMDS With Sleep Time    ${A_105_AP_CMDS_WITH_SLEEP_TIME_STEP2}

    COAM.Setup Admin
    COAM.perform_delta_recommissioning    delta_file=${CURDIR}/config/105_DELTA.json
    COAM.Teardown Admin
    wait_until_next_5_min    extra_sleep_time=60

    Batch Execute AP CMDS With Sleep Time    ${A_105_AP_CMDS_WITH_SLEEP_TIME_STEP1}
    Airphone SA Start Data Traffic With Multi TRF    trf_num=2    ue=1
    Airphone SA Start Data Traffic With Multi TRF    trf_num=2    ue=2
    Airphone SA Start Data Traffic With Multi TRF    trf_num=2    ue=3
    wait_until_next_5_min
    wait_until_next_5_min
    coam.connect_to    name=GNB_OAM
    ${counters}    coam.get_pm_counters    counter_ids=M55196C00014,M55196C00015,M55196C00016,M55196C00017,M55196C00018,M55196C00019
    ...    connection=GNB_OAM
    coam.teardown    connection=GNB_OAM
    ${counter_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NBFC']}
    Should Be True    ${counter_values['M55196C00014']}==0
    Should Be True    ${counter_values['M55196C00015']}==0
    Should Be True    ${counter_values['M55196C00016']}==0
    Should Be True    ${counter_values['M55196C00017']}==0
    Should Be True    ${counter_values['M55196C00018']}==0
    Should Be True    ${counter_values['M55196C00019']}==0
    ${counter_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-2']['NBFC']}
    Should Be True    ${counter_values['M55196C00014']}==0
    Should Be True    ${counter_values['M55196C00015']}==0
    Should Be True    ${counter_values['M55196C00016']}==0
    Should Be True    ${counter_values['M55196C00017']}==0
    Should Be True    ${counter_values['M55196C00018']}==0
    Compare Values Within Range    ${counter_values['M55196C00019']}    300    2
    Batch Execute AP CMDS With Sleep Time    ${A_105_AP_CMDS_WITH_SLEEP_TIME_STEP2}

CB010653_A_106_Verify_Counters_For_Count_The_Number_Of_UE_That_Configure_Cell_Specific_CSI-RS
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/09/23 14:14
    [Tags]    106
    Set Test Variable    ${SCFC_NAME}            106.xml
    Set Test Variable    ${AIRPHONE_NAME}        106_ap.xml
    Set Test Variable    ${WTS_NAME}             106_wts.cfg
    Get and Update BSR File		par_of_bsr_name=BSR_AQQL_4_H3H1_ALN60_ARP60_P00_COVERAGE_00442_00002
    Set Test Variable    ${GNBCUTYPE}    ${EMPTY}
    Prepare gnb onair

    # 2025/07/07 make sure counter will update in on interval
    wait_until_next_5_min    extra_sleep_time=60
    # contact jian.1.chen@nokia-sbell.com

    Batch Execute AP CMDS With Sleep Time    ${A_106_AP_CMDS_WITH_SLEEP_TIME_STEP1}

    wait_until_next_5_min
    wait_until_next_5_min    extra_sleep_time=60
    coam.connect_to    name=GNB_OAM
    ${counters}    coam.get_pm_counters    counter_ids=M55196C00017,M55196C00018,M55196C00019,M55196C00020,M55196C00022,M55196C00023
    ...    connection=GNB_OAM
    coam.teardown    connection=GNB_OAM

    ${counter_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NBFC']}
    Compare Values Within Range    ${counter_values['M55196C00017']}    900    6
    Should Be True    ${counter_values['M55196C00018']}==3
    Compare Values Within Range    ${counter_values['M55196C00019']}    300    2
    ${counter_20}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NBFC']['M55196C00020']}
    Should Be True    ${counter_20}==1
    ${counter_22}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NBFC']['M55196C00022']}
    Should Be True    ${counter_22}==2
    ${counter_23}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NBFC']['M55196C00023']}
    Should Be True    ${counter_23}==3
    ${counter_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-2']['NBFC']}
    Should Be True    ${counter_values['M55196C00017']}==0
    Should Be True    ${counter_values['M55196C00018']}==0
    Compare Values Within Range    ${counter_values['M55196C00019']}    300    2


    airphone_execute_egate_command     trf_data_stop ue\=11 trf_id\=1,2,3,4,5,6,7,8,9
    airphone_execute_egate_command     ue_detach id\=11
    airphone_execute_egate_command     trf_data_stop ue\=12 trf_id\=1,2,3
    airphone_execute_egate_command     ue_detach id\=12
    airphone_execute_egate_command     trf_data_stop ue\=13 trf_id\=1,2,3,4,5,6,7,8
    airphone_execute_egate_command     ue_detach id\=13

CB010653_A_109_Verify_Counters_For_Number_of_Beamforming_Fallback_or_Switch_between_SRS_Beamforming_and_SSB_Beamforming
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/09/18 10:59 p
    [Tags]    109
    Set Test Variable    ${SCFC_NAME}            109.xml
    Set Test Variable    ${AIRPHONE_NAME}        109_ap.xml
    Set Test Variable    ${WTS_NAME}             109_wts.cfg
    Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001
    Set Test Variable    ${GNBCUTYPE}    ${EMPTY}
    Prepare gnb onair

    wait_until_next_5_min
    UE from '1' to '1' SA Register
    Airphone SA Start Data Traffic    1    DL   1M   pdu_id=1
    Airphone SA Start Data Traffic    1    UL   1M   pdu_id=1

    Start GNB Ttitrace With Streaming Mode
    Set Test Variable    ${cmd1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=1 test_type\=SRS
    Set Test Variable    ${cmd2}    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=15 zenith\=0
    airphone_execute_egate_command     ${cmd1} ${cmd2} srs_transmit_power_per_port\=-700,-700,-700,-700
    Sleep    3s
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
    Sleep    3s
    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
    Decoder Tttirace From Pcap To Csv    ${pcap_path}    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump
    ${dl_id}    check_dl_beam_type_id    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump_dl.csv    SSB
    ${ul_id}    check_ul_srs_beam_pattern_id    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump_ul.csv
    Should Be True    '${dl_id}'=='${ul_id}'
    wait_until_next_5_min    extra_sleep_time=60
    coam.connect_to    name=GNB_OAM
    ${counters}    coam.get_pm_counters    counter_ids=M55330C00022,M55330C00024
    ...    connection=GNB_OAM
    coam.teardown    connection=GNB_OAM
    ${counter}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRBF2']['M55330C00022']}
    Should Be True    '1'=='${counter}'
    ${counter}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRBF2']['M55330C00024']}
    Should Be True    '1'=='${counter}'

    Start GNB Ttitrace With Streaming Mode
    Set Test Variable    ${cmd1}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=1 test_type\=SRS
    Set Test Variable    ${cmd2}    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=15 zenith\=0
    airphone_execute_egate_command     ${cmd1} ${cmd2} srs_transmit_power_per_port\=-200,-200,-200,-200
    Sleep    3s
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
    Sleep    2s
    #Airphone SA Detach    1
    airphone_execute_egate_command      reset
    Sleep    2s
    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
    Decoder Tttirace From Pcap To Csv    ${pcap_path}    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump
    ${dl_id}    check_dl_beam_type_id    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump_dl.csv    SSB
#    ${ul_id}    check_ul_srs_beam_pattern_id    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump_ul.csv
#    Should Be True    '${dl_id}'=='${ul_id}'
    wait_until_next_5_min    extra_sleep_time=60
    coam.connect_to    name=GNB_OAM
    ${counters}    coam.get_pm_counters    counter_ids=M55330C00025,M55330C00027
    ...    connection=GNB_OAM
    coam.teardown    connection=GNB_OAM
    ${counter}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRBF2']['M55330C00025']}
    Should Be True    '1'=='${counter}'
    ${counter}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRBF2']['M55330C00027']}
    Should Be True    '1'=='${counter}'

CB010653_A_110_Verify_Counters_For_Number_of_Beamforming_Fallback_or_Switch_between_SRS_Beamforming_and_PMI_Beamforming
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/09/18 10:59 p
    [Tags]    110
    Set Test Variable    ${SCFC_NAME}            110.xml
    Set Test Variable    ${AIRPHONE_NAME}        110_ap.xml
    Set Test Variable    ${WTS_NAME}             110_wts.cfg
    Get and Update BSR File		par_of_bsr_name=BSR_AQQL_4_H3H1_ALN60_ARP60_P00_COVERAGE_00442_00002
    Set Test Variable    ${GNBCUTYPE}    ${EMPTY}
    Prepare gnb onair

    wait_until_next_5_min
    UE from '1' to '1' SA Register
    Airphone SA Start Data Traffic    1    DL   2M   pdu_id=1
    Airphone SA Start Data Traffic    1    UL   2M   pdu_id=1

    Start GNB Ttitrace With Streaming Mode
    Set Test Variable    ${cmd1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=1 test_type\=SRS
    Set Test Variable    ${cmd2}    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=15 zenith\=0
    airphone_execute_egate_command     ${cmd1} ${cmd2} srs_transmit_power_per_port\=-700,-700,-700,-700
    Sleep    3s
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
    Sleep    3s
    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
    Decoder Tttirace From Pcap To Csv    ${pcap_path}    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump
    ${dl_id}    check_dl_beam_type_id    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump_dl.csv    PMI
    ${ul_id}    check_ul_srs_beam_pattern_id    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump_ul.csv
    Should Be True    '${dl_id}'=='${ul_id}'
    wait_until_next_5_min    extra_sleep_time=60
    coam.connect_to    name=GNB_OAM
    ${counters}    coam.get_pm_counters    counter_ids=M55330C00023,M55330C00024
    ...    connection=GNB_OAM
    coam.teardown    connection=GNB_OAM
    ${counter}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRBF2']['M55330C00023']}
    Should Be True    '1'=='${counter}'
    ${counter}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRBF2']['M55330C00024']}
    Should Be True    '1'=='${counter}'

    Start GNB Ttitrace With Streaming Mode
    Set Test Variable    ${cmd1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=1 test_type\=SRS
    Set Test Variable    ${cmd2}    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=15 zenith\=0
    airphone_execute_egate_command     ${cmd1} ${cmd2} srs_transmit_power_per_port\=-200,-200,-200,-200
    Sleep    3s
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
    Sleep    3s
    Airphone SA Detach    1
    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
    Decoder Tttirace From Pcap To Csv    ${pcap_path}    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump
    ${dl_id}    check_dl_beam_type_id    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump_dl.csv    PMI
    ${ul_id}    check_ul_srs_beam_pattern_id    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump_ul.csv
    Should Be True    '${dl_id}'=='${ul_id}'
    wait_until_next_5_min    extra_sleep_time=60
    coam.connect_to    name=GNB_OAM
    ${counters}    coam.get_pm_counters    counter_ids=M55330C00026,M55330C00027
    ...    connection=GNB_OAM
    coam.teardown    connection=GNB_OAM
    ${counter}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRBF2']['M55330C00026']}
    Should Be True    '1'=='${counter}'
    ${counter}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRBF2']['M55330C00027']}
    Should Be True    '1'=='${counter}'

CB010653_A_120_Verify_Counters_For_UE_Angular_distribution_for_DL_Best_SRS_Beamforming_Horixzontal_case10
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/09/19 10:29
    [Tags]    120
    Set Test Variable    ${SCFC_NAME}            120.xml
    Set Test Variable    ${AIRPHONE_NAME}        120_ap.xml
    Set Test Variable    ${WTS_NAME}             120_wts.cfg
    Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001
    Set Test Variable    ${GNBCUTYPE}    ${EMPTY}
    Prepare gnb onair

    wait_until_next_5_min
    UE from '1' to '1' SA Register
    Airphone SA Start Data Traffic    1    DL   10M   pdu_id=1
    Airphone SA Start Data Traffic    1    UL   5M   pdu_id=1
    UE from '2' to '2' SA Register
    Airphone SA Start Data Traffic    2    DL   10M   pdu_id=1
    Airphone SA Start Data Traffic    2    UL   5M   pdu_id=1

    Start GNB Ttitrace With Streaming Mode    filter_events=True
    Set Test Variable    ${cmd1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 test_type\=SRS
    Set Test Variable    ${cmd2}    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-10 zenith\=-2
    airphone_execute_egate_command     ${cmd1} ${cmd2} srs_transmit_power_per_port\=-500,-500,-200,-200
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
    Sleep    1s
    Set Test Variable    ${cmd1}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 test_type\=SRS
    Set Test Variable    ${cmd2}    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=10 zenith\=2
    airphone_execute_egate_command     ${cmd1} ${cmd2} srs_transmit_power_per_port\=-500,-500,-200,-200
    airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
    Sleep    1s
    Set Test Variable    ${cmd1}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 test_type\=SRS
    Set Test Variable    ${cmd2}    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-40 zenith\=-5
    airphone_execute_egate_command     ${cmd1} ${cmd2} srs_transmit_power_per_port\=-500,-500,-200,-200
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
    Sleep    1s
    Set Test Variable    ${cmd1}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 test_type\=SRS
    Set Test Variable    ${cmd2}    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=40 zenith\=5
    airphone_execute_egate_command     ${cmd1} ${cmd2} srs_transmit_power_per_port\=-500,-500,-200,-200
    airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
    Sleep    1s
    Airphone SA Detach    1
    Airphone SA Detach    2
    Sleep    2s
    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
    Decoder Tttirace From Pcap To Csv    ${pcap_path}    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump

    wait_until_next_5_min    extra_sleep_time=60
    coam.connect_to    name=GNB_OAM
    ${counters}    coam.get_pm_counters    counter_ids=M55372C00053,M55372C00055,M55372C00066,M55372C00078
    ...    connection=GNB_OAM
    coam.teardown    connection=GNB_OAM
    ${53_counter}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRAD']['M55372C00053']}
    ${55_counter}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRAD']['M55372C00055']}
    ${66_counter}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRAD']['M55372C00066']}
    ${78_counter}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRAD']['M55372C00078']}
    ${53_num}    ${55_num}    ${66_num}    ${78_num}    check_dl_doah_doav
    ...    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump_dl.csv    ${SW_BRANCH}
    Should Be True    '${53_num}'=='${53_counter}'
    Should Be True    '${55_num}'=='${55_counter}'
    Should Be True    '${66_num}'=='${66_counter}'
    Should Be True    '${78_num}'=='${78_counter}'

CB010630_D_102_Verify_Counters_of_SRS_Power_Distribution_for_TAS_SB_SRS_Beam
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/09/12 15:29
    [Tags]    102
    Set Test Variable    ${SCFC_NAME}            102.xml
    Set Test Variable    ${AIRPHONE_NAME}        102_ap.xml
    Set Test Variable    ${WTS_NAME}             102_wts.cfg
    Get and Update BSR File		par_of_bsr_name=BSR_AVQL_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00002
    Log To Console    modify_vendor_file_for_72eUL
    Modify vendor file 72e and full commission for onair
    Log To Console    wait_until_next_5_min
    wait_until_next_5_min
    Airphone NSA Attach    ue_id=11
    airphone_execute_egate_command     ue_dc_enb_start ue\=11 target_gnb\=2 target_cells\=1 bearer\=2 type\=split_scg
    airphone_execute_egate_command     trf_data_start ue\=11 id\=2 dir\=dl mbps\=173 trf_id\=1
    airphone_execute_egate_command     trf_data_start ue\=11 id\=2 dir\=dl mbps\=173 trf_id\=2
    airphone_execute_egate_command     trf_data_start ue\=11 id\=2 dir\=dl mbps\=173 trf_id\=3
    airphone_execute_egate_command     trf_data_start ue\=11 id\=2 dir\=dl mbps\=173 trf_id\=4
    airphone_execute_egate_command     trf_data_start ue\=11 id\=2 dir\=dl mbps\=173 trf_id\=5
    airphone_execute_egate_command     trf_data_start ue\=11 id\=2 dir\=dl mbps\=173 trf_id\=6
    airphone_execute_egate_command     trf_data_start ue\=11 id\=2 dir\=dl mbps\=173 trf_id\=7
    airphone_execute_egate_command	   trf_data_start ue\=11 id\=2 dir\=ul mbps\=50 trf_id\=3
    Set Test Variable    ${cmd1}       ul_ue_beam_pos_nr profile_id\=1 num_beam_paths\=2
    airphone_execute_egate_command     ${cmd1} azimuth\=-36,-36 zenith\=-5,-5 power\=-500,-500
    airphone_execute_egate_command    ue_testmode_set_nr id\=11 testmode\=ue_ul_beam_position action\=activate profile_id\=1 scell\=8

    wait_until_next_5_min
    wait_until_next_5_min    extra_sleep_time=60
    airphone_execute_egate_command    ul_ue_beam_pos_nr profile_id\=1 delete\=true
    Log To Console    counter_ids=M55371C00121
    coam.connect_to    name=GNB_OAM
    ${counters}    coam.get_pm_counters    counter_ids=M55371C00121
    ...    connection=GNB_OAM
    coam.teardown    connection=GNB_OAM
    ${c1_121}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NSRS']['M55371C00121']}
    Compare Values Within Range    ${c1_121}    60000    200
    Log To Console    counter_ids=M55371C00103
    Set Test Variable    ${cmd1}    ul_ue_beam_pos_nr profile_id\=2 num_beam_paths\=2

    airphone_execute_egate_command    ${cmd1} azimuth\=0,20 zenith\=-0,0 power\=-860,-860
    airphone_execute_egate_command    ue_testmode_set_nr id\=11 testmode\=ue_ul_beam_position action\=activate profile_id\=2 scell\=8
    wait_until_next_5_min
    wait_until_next_5_min    extra_sleep_time=60
    airphone_execute_egate_command    ul_ue_beam_pos_nr profile_id\=2 delete\=true
    coam.connect_to    name=GNB_OAM
    ${counters}    coam.get_pm_counters    counter_ids=M55371C00103
    ...    connection=GNB_OAM
    coam.teardown    connection=GNB_OAM
    ${c1_103}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NSRS']['M55371C00103']}
    Compare Values Within Range    ${c1_103}    60000    200
    Log To Console    counter_ids=M55371C00138
    Set Test Variable    ${cmd1}    ul_ue_beam_pos_nr profile_id\=3 num_beam_paths\=2

    airphone_execute_egate_command    ${cmd1} azimuth\=0,20 zenith\=0,0 power\=-160,-160
    airphone_execute_egate_command    ue_testmode_set_nr id\=11 testmode\=ue_ul_beam_position profile_id\=3 action\=activate scell\=8
    wait_until_next_5_min
    wait_until_next_5_min    extra_sleep_time=60
    airphone_execute_egate_command    ul_ue_beam_pos_nr profile_id\=3 delete\=true
    coam.connect_to    name=GNB_OAM
    ${counters}    coam.get_pm_counters    counter_ids=M55371C00138
    ...    connection=GNB_OAM
    coam.teardown    connection=GNB_OAM
    ${c1_138}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NSRS']['M55371C00138']}
    Compare Values Within Range    ${c1_138}    60000    200
    Log To Console    counter_ids=M55372C00043
    Start GNB Ttitrace With Streaming Mode    filter_events=True
    Set Test Variable    ${cmd1}       ul_ue_beam_pos_nr profile_id\=1 num_beam_paths\=2
    airphone_execute_egate_command     ${cmd1} azimuth\=-36,-36 zenith\=-5,-5 power\=-500,-500
    airphone_execute_egate_command    ue_testmode_set_nr id\=11 testmode\=ue_ul_beam_position action\=activate profile_id\=1 scell\=8
    sleep    1s
    airphone_execute_egate_command    ul_ue_beam_pos_nr profile_id\=1 delete\=true
    Airphone NSA Detach    11
    sleep    1s
    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
    Decoder Tttirace From Pcap To Csv    ${pcap_path}    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump

    wait_until_next_5_min    extra_sleep_time=60
    coam.connect_to    name=GNB_OAM
    ${counters}    coam.get_pm_counters    counter_ids=M55372C00043    connection=GNB_OAM
    coam.teardown    connection=GNB_OAM
    ${43_counter}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRAD']['M55372C00043']}
    ${43_num}    check_dl_doah_doav_25r3
    ...    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump_dl.csv
    Should Be True    '${43_num}'=='${43_counter}'

CB010630_D_105_Verify_Counter_for_UE_that_cannot_be_Paired_UL_MU_MIMO_because_of_Invalid_SRS_Beams
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/09/13 13:49 p
    [Tags]    105_72e
    Set Test Variable    ${SCFC_NAME}            105_72e.xml
    Set Test Variable    ${AIRPHONE_NAME}        105_ap_72e.xml
    Set Test Variable    ${WTS_NAME}             105_wts_72e.cfg
    Get and Update BSR File		par_of_bsr_name=BSR_AVQL_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00002
    Set Test Variable    ${GNBCUTYPE}    ${EMPTY}
  	Log To Console    modify_vendor_file_for_72eUL
    Modify vendor file 72e and full commission for onair
    wait_until_next_5_min
    Start GNB Ttitrace With Streaming Mode
    UE from '1' to '1' SA Register
    Set UE position    ${105_UE1_PROFILE1}    ${105_UE1_PROFILE2}
    UE from '2' to '2' SA Register
    Set UE position    ${105_UE2_PROFILE1}    ${105_UE2_PROFILE2}
    Airphone SA Start Data Traffic    1    ul   90M   pdu_id=1    trf_id=1
    Airphone SA Start Data Traffic    2    ul   90M   pdu_id=1    trf_id=3
    Set Test Variable    ${cmd1}    ul_ue_beam_pos_nr profile_id\=3 num_beam_paths\=2
    airphone_execute_egate_command    ${cmd1} azimuth\=0,20 zenith\=0,0 power\=-900,-900
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ue_ul_beam_position profile_id\=3 action\=activate
    Sleep    3s
    airphone_execute_egate_command    ul_ue_beam_pos_nr profile_id\=3 delete\=true
    airphone_execute_egate_command      reset
    Sleep    2s
    Verify UE No Pair Counter Normal    type=MUNONELIGIBLE_NOSRSBEAM    counter_id=M55308C00103

*** Keywords ***
201 Common Steps
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/10/10 10:08
    [Arguments]    ${start_tti}=True
    Set Test Variable    ${cmd}    step\=5 trigger_puxch_update\=0 test_type\=SRS srs_transmit_power_per_port\=-200,-200,-200,-200
    airphone_execute_egate_command    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 ${cmd}
    airphone_execute_egate_command    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 ${cmd}
    airphone_execute_egate_command    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 ${cmd}
    airphone_execute_egate_command    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 ${cmd}

    airphone_execute_egate_command    ue_testmode_set_nr id\=11 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
    airphone_execute_egate_command    ue_testmode_set_nr id\=12 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
    airphone_execute_egate_command    ue_testmode_set_nr id\=13 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
    airphone_execute_egate_command    ue_testmode_set_nr id\=14 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4

    Airphone NSA Attach    ue_id=11
    airphone_execute_egate_command    ue_dc_enb_start ue\=11 target_gnb\=2 target_cells\=1 bearer\=2 type\=split_scg
    airphone_execute_egate_command    trf_data_start ue\=11 id\=2 dir\=dl mbps\=150 trf_id\=1
    airphone_execute_egate_command    trf_data_start ue\=11 id\=2 dir\=dl mbps\=150 trf_id\=2
    airphone_execute_egate_command    trf_data_start ue\=11 id\=2 dir\=dl mbps\=150 trf_id\=3
    Airphone NSA Attach    ue_id=12
    airphone_execute_egate_command    ue_dc_enb_start ue\=12 target_gnb\=2 target_cells\=1 bearer\=2 type\=split_scg
    airphone_execute_egate_command    trf_data_start ue\=12 id\=2 dir\=dl mbps\=150 trf_id\=1
    airphone_execute_egate_command    trf_data_start ue\=12 id\=2 dir\=dl mbps\=150 trf_id\=2
    airphone_execute_egate_command    trf_data_start ue\=12 id\=2 dir\=dl mbps\=150 trf_id\=3
    Airphone NSA Attach    ue_id=13
    airphone_execute_egate_command    ue_dc_enb_start ue\=13 target_gnb\=2 target_cells\=1 bearer\=2 type\=split_scg
    airphone_execute_egate_command    trf_data_start ue\=13 id\=2 dir\=dl mbps\=150 trf_id\=1
    airphone_execute_egate_command    trf_data_start ue\=13 id\=2 dir\=dl mbps\=150 trf_id\=2
    airphone_execute_egate_command    trf_data_start ue\=13 id\=2 dir\=dl mbps\=150 trf_id\=3

    Run Keyword If    '${start_tti}'=='True'    Start GNB Ttitrace With Streaming Mode
    Airphone NSA Attach    ue_id=14
    airphone_execute_egate_command    ue_dc_enb_start ue\=14 target_gnb\=2 target_cells\=1 bearer\=2 type\=split_scg
    airphone_execute_egate_command    trf_data_start ue\=14 id\=2 dir\=dl mbps\=150 trf_id\=1
    airphone_execute_egate_command    trf_data_start ue\=14 id\=2 dir\=dl mbps\=150 trf_id\=2
    airphone_execute_egate_command    trf_data_start ue\=14 id\=2 dir\=dl mbps\=150 trf_id\=3

Airphone SA Start Data Traffic With Multi TRF
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/09/12 15:32
    [Arguments]    ${trf_num}    ${ue}=1    ${direction}=DL    ${throughput}=175M    ${pdu}=1    ${duration}=3600
    FOR    ${num}    IN RANGE    1    ${trf_num}+1
        Airphone SA Start Data Traffic    ${ue}    ${direction}   ${throughput}   pdu_id=${pdu}    duration=${duration}   trf_id=${num}
    END

Register_UE1
	UE from '1' to '1' SA Register
	Set UE1 position
	send ul data from UE '1' to '1'
Register_UE2
	UE from '2' to '2' SA Register
	Set UE2 position
	send ul data from UE '2' to '2'

Set UE position
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/09/12 09:37
    [Arguments]    ${profile}    ${set_profile}
    Airphone Execute Egate Command    ${profile}
    Airphone Execute Egate Command    ${set_profile}

Set UE1 position
    Airphone Execute Egate Command    ${PROFILE1}
    Airphone Execute Egate Command    ${SET_PROFILE1}
Set UE2 position
    Airphone Execute Egate Command    ${PROFILE2}
    Airphone Execute Egate Command    ${SET_PROFILE2}
Set UE3 position
    Airphone Execute Egate Command    ${PROFILE3}
    Airphone Execute Egate Command    ${SET_PROFILE3}
UE from '${lo}' to '${hi}' SA Register
    FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
    #\   airphone_cleanup_egate_console_log
        Log To Console   ${\n}-----register UE ${num} ------

        Airphone SA Attach    ue_id=${num}
       #set_pdu_param ue=1 pdu=1 trf_type=internal
       #Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
        Airphone Set Traffic Type    ${num}    1    internal
#        Run Keyword If    '${lo}'=='3'
#        ...    airphone_execute_egate_command    set_pdu_param ue\=${UE_ID} pdu\=1 trf_type\=internal qfi\=3
#        ...    ELSE    airphone_execute_egate_command    set_pdu_param ue\=${UE_ID} pdu\=1 trf_type\=internal qfi\=1
        Airphone Pdu Session Setup    ${num}    1    1    ${num}
        Wait '0.5s' for stabible
#        get UE '${num}' rnti in RRC log
    END
get UE '${ue_id}' rnti in RRC log
    Log To Console   ${\n}===get UE'${ue_id}' rnti===
    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}   unzip=TRUE

    ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}/egate_console.log.001   crnti: (\\d+)
    run keyword if    ${ue_id}==1   Set test Variable	 ${rnti_1} 	${rnti_list[-1]}
    run keyword if    ${ue_id}==2   Set test Variable	 ${rnti_2} 	${rnti_list[-1]}
    run keyword if    ${ue_id}==3   Set test Variable	 ${rnti_3} 	${rnti_list[-1]}
send ul data from UE '${lo}' to '${hi}'
	FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
        DL and UL data to '${num}'
    END
DL and UL data to '${UE_ID}'
    Airphone SA Start Data Traffic    ${UE_ID}    DL   175M   pdu_id=1
    ...    duration=3600   trf_id=1
    Airphone SA Start Data Traffic    ${UE_ID}    DL   100M   pdu_id=1    duration=3600   trf_id=2
#    Airphone SA Start Data Traffic    ${UE_ID}    DL   5M   pdu_id=${UE_ID}   duration=3600   trf_id=1
#    run keyword if    ${UE_ID}==1		Airphone SA Start Data Traffic    ${UE_ID}    UL   70M   pdu_id=${UE_ID}
#    ...    duration=7200   trf_id=1
#    run keyword if    ${UE_ID}==2		Airphone SA Start Data Traffic    ${UE_ID}    UL   70M   pdu_id=${UE_ID}
#    ...    duration=7200   trf_id=2
    Wait '1s' for stabible
    ${dl_tput_kb}    ${ul_tput_kb}    Obtain one sa ue dl and ul throught    ${UE_ID}  	pdu_id=1
    ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
    Log To Console		UE${UE_ID}_ul ${ul_tput_Mb}
    Log To Console		UE${UE_ID}_dl ${dl_tput_kb}
Get Recent Single Counter Value
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/01/19 11:18
    ...    Modify 2024/05/10 10:47: remove count
    [Arguments]    ${counters}
    ${time_list}    Get Dictionary Keys    ${counters}
    Reverse List    ${time_list}
    ${counter_value}    Set Variable    0
    FOR    ${time}    IN    @{time_list}
        ${counter_value}    Run Keyword If    ${counters['${time}']}>0
        ...    Set Variable    ${counters['${time}']}
        Exit For Loop If    ${counters['${time}']}>0
    END
    [Return]    ${counter_value}

Get Recent Multi Counters Value
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/09/27 20:13
    [Arguments]    ${counters}
    ${counter_values}    Create Dictionary
    ${counter_names}    Get Dictionary Keys    ${counters}
    FOR    ${counter_name}    IN    @{counter_names}
        ${values}    Get Dictionary Values    ${counters['${counter_name}']}
        Set To Dictionary    ${counter_values}    ${counter_name}=${values[-1]}
    END
    [Return]    ${counter_values}

Start GNB Ttitrace With Streaming Mode
    [Arguments]     ${lcr_cell_id}=All    ${up_sw}=L2Ps     ${name}=l2stream3    ${filter_mimo}=True
    ...    ${filter_events}=False
    [Documentation]    This keyword will collect gnb ttitrace log.
    ...    | Input Parameters | Man. | Description |
    ...    | ${lcr_cell_id} | No | lcr cell id, it can be like 1 or 1,2 or ALL. The default value is ALL. |
    ...    | ${up_sw}       | No | option for capture. Default value is "L2Ps". It can be "L2Ps", "L2Lo", "L2iPdcp", "L2HiRlc"  |
    ...    | ${name}        | No | It can be the same as alias. The default value is l2stream3 |
    ...    Examples(BTS should be Onair and UE attach and data transfer is started. ):
    ...    | Start GNB Ttitrace With Streaming Mode | lcr_cell_id=1,2  | name=myttitrace |
    ...    | ${pacp}=  |  Stop GNB Ttitrace With Streaming Mode  |  save_path=${TEST_LOG_DIRECTORY()} | name=myttitrace |
    ...    or
    ...    | Start GNB Ttitrace With Streaming Mode | | |
    ...    | ${pacp}=  |  Stop GNB Ttitrace With Streaming Mode  |  save_path=${TEST_LOG_DIRECTORY()} |
    ...    | Download Ttitrace Decode Tool  | | |
    ...    | Decoder Tttirace From Pcap To Csv  | pcap_path=${pacp} | output_path_with_tag=${TEST_LOG_DIRECTORY()}nsa_tti |
    @{sw_list}    String.Split String    ${SOFTWARE_INFO}    _
	&{asik_vm}=         Create Dictionary
	...    host=${GNB.ip}
	...    user=Nemuadmin
	...    password=nemuuser
	...    port=443
	...    release=${sw_list[0]}
	${scfc_on_gnb_now}=    common_gnb.Backup Scf     ${test_log_directory()}      scfc_for_tti.xml
	${lcr_cell_id}=     String.Convert To Upper Case       ${lcr_cell_id}
	${nr_phy_cell_ids}=    Run Keyword If     '${lcr_cell_id}'=='ALL'    _Get All PhysCellId In GNB    ${scfc_on_gnb_now}
	...    ELSE    _Get PhysCellId In GNB By LcrdId    ${scfc_on_gnb_now}    ${lcr_cell_id}
	${local_ip_addr}=    _Get localIpAddr Of GNB      ${scfc_on_gnb_now}
	${eth_port}    ${eth_ip}=      _Get EIF Info From Control PC
    ${l2_stream_config_1}=    Create Dictionary       nr_phy_cell_ids=${nr_phy_cell_ids}     up_sw=${up_sw}
    Run Keyword If    '${filter_mimo}'=='True'    Set To Dictionary    ${l2_stream_config_1}
    ...    profile_filter_list=MU_MIMO
    Run Keyword If    '${filter_events}'=='True'    Set To Dictionary    ${l2_stream_config_1}
    ...    profile_filter_list=MU_MIMO,All events
    @{l2_stream_configuration}=    Create List    ${l2_stream_config_1}
	TCPDUMP.Create Tcpdump Collector
	...  name=tcpdump
	...  options=-i ${eth_port} udp and dst ${eth_ip} and dst port 5678
	...  sudo_password=ute
	L2STREAM3.Create Sbts L2stream Collector
	...  name=${name}
	...  destination_ip_addr=${eth_ip}
	...  collector=tcpdump
	...  l2_stream_configuration=${l2_stream_configuration}
	...  webservice=${asik_vm}
    ...  dscp=15
    L2STREAM3.Set Suite Alias    alias=${name}
    CORE.setup_collectors    names=${name}
    CORE.start_collectors    names=${name}
    [Teardown]    Run Keyword And Ignore Error    Run    rm ${scfc_on_gnb_now}

Verify PMQAP Counter Normal
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/09/11 10:43
    [Arguments]    ${counter_id}    ${tti_count}    ${pmqap}    ${nrcell}=1    ${connection}=GNB_OAM
    coam.connect_to    name=${connection}
    ${counters}    coam.get_pm_counters    counter_ids=${counter_id}    connection=${connection}
    coam.teardown    connection=${connection}
    ${counter}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-${nrcell}']['NRPMQAP-${pmqap}']['UESPQ']['${counter_id}']}
    Compare Values Within Range    ${tti_count}    ${counter}

Verify UE No Pair Counter Normal
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/09/16 15:53
    [Arguments]    ${type}    ${counter_id}    ${connection}=GNB_OAM
    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
    Decoder Tttirace From Pcap To Csv    ${pcap_path}    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump
    ${num}    check_target_mustatus_num    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump_ul.csv    type=${type}

    wait_until_next_5_min    extra_sleep_time=60
    coam.connect_to    name=${connection}
    ${counters}    coam.get_pm_counters    counter_ids=${counter_id}    connection=${connection}
    coam.teardown    connection=${connection}
    ${counter}    Get Recent Single Counter Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NCELA']['${counter_id}']}
    Compare Values Within Range    ${num}    ${counter}

Compare Values Within Range
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/10/09 10:13
    [Arguments]    ${value1}    ${value2}    ${range}=20
    ${difference}    Evaluate    abs(${value1} - ${value2})
    ${status}    Evaluate    ${difference} <= ${range}
    Should Be True    ${status}

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

Modify vendor file 72e and full commission for onair
    [Arguments]    ${wait_bts_timeout}=2000    ${wait_rru_timeout}=800    ${wait_onair_timeout}=800
    Modify Swconfig for AP
    Start capture gnb and ap syslog in 'before_onair' file
    Log to console     Change iphy rru version
    Change iphy rru version    ${CONFIG_DIR_PATH}/${SW_BRANCH}/WTS/${AIRPHONE_NAME}
    Log to console         reboot ap
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
    #Modify Vendor 72e XML File    ${vendor_path}
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
    Log to console    celltesttesttest
    sleep        120s
    ${onair_status}=    Run Keyword And Return Status    Start Wts And Wait Bts Until Onair     ${cfg_path}
    ...    timeout=${wait_onair_timeout}
    Log to console    celltesttesttest2
    Stop capture gnb and ap syslog in 'before_onair' file
    Log To Console    BTS is onAir now
    Run Keyword And Ignore Error    Stop collect 'cellsetup' tcpdump

Batch Execute AP CMDS
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/01/20 14:22
    [Arguments]    ${cmd_list}    ${wait_time}=3s
    FOR    ${cmd}    IN    @{cmd_list}
        airphone_execute_egate_command    ${cmd}
        Sleep    ${wait_time}
    END

Batch Execute AP CMDS With Sleep Time
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/06/30 13:27
    [Arguments]    ${cmd_list}
    FOR    ${cmd}    ${wait_time}    IN    @{cmd_list}
        airphone_execute_egate_command    ${cmd}
        Sleep    ${wait_time}
    END
