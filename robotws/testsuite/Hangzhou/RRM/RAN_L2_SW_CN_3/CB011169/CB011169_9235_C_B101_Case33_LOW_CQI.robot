*** Settings ***
Documentation     Author: shuiheng.he@nokia-sbell.com
...
...               QC case full name:
...               CB009235_C_B101_Case33_DL_MU-MIMO_Enhanced_Unpair_PM_counters_with_Invalid_SRS_and_LOW_CQI

Test Timeout      60 minutes
Suite Setup       AiC Common Suite Setup
Suite Teardown    AiC Common Suite Teardown
Test Setup        AiC Common Test Setup
Test Teardown     AiC Common Test Teardown
Resource          ../resources/KISS/robot/common_resource.robot
Resource          ../resources/sg10/internal_resource/internal_resource.robot
Library           ../CB009235/Airphone/py_check/power_boosting_check.py
Resource          ../resources/sg11/internal_resource/robot/modify_configuration.robot
Resource          ../resources/sg11/internal_resource/robot/internal_ap_operate.robot
Resource          ../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
Resource          ../resources/sg11/internal_resource/robot/internal_capture_log.robot


*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${DU_SCF}        DU_11169_9235_case33.xml
#${DU_SCF}        DU_basic.xml
${CU_SCF}        CU_11169_9235.xml
#${CU_SCF}        CU_basic.xml
${AIRPHONE_NAME}    iphy_AEQE_DC.xml
#${AIRPHONE_NAME}    iphy_basic.xml
${WTS_CFG}       wts_11169_9235_1cell_SA_NSA_case20.lua
#${WTS_CFG}       basic_setup.cfg
@{LOG_NAME_LIST}    egatelog
#${SET_PROFILE9}    ul_mimo_srs_beam_pos_nr profile_id\=9 mode\=fixed test_type\=SRS init_quad_pos\=0 init_sub_quad_pos\=0
#...    dtx_start\=10 num_dtx\=255 trigger_puxch_update\=0
#${SET_PROFILE10}    ul_mimo_srs_beam_pos_nr profile_id\=10 mode\=fixed test_type\=SRS init_quad_pos\=0 init_sub_quad_pos\=0
#...    dtx_start\=10 num_dtx\=255 trigger_puxch_update\=0
${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0
${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=1 step\=5 trigger_puxch_update\=0
${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=2 step\=5 trigger_puxch_update\=0
${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0
${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 step\=5 trigger_puxch_update\=0
${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=2 step\=5 trigger_puxch_update\=0
${PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id\=8 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
${PROFILE9}    ul_mimo_srs_beam_pos_nr profile_id\=9 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0
${PROFILE10}    ul_mimo_srs_beam_pos_nr profile_id\=10 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=1 step\=5 trigger_puxch_update\=0
${PROFILE11}    ul_mimo_srs_beam_pos_nr profile_id\=11 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 step\=5 trigger_puxch_update\=0
${PROFILE12}    ul_mimo_srs_beam_pos_nr profile_id\=12 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
${PROFILE13}    ul_mimo_srs_beam_pos_nr profile_id\=13 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0
${PROFILE14}    ul_mimo_srs_beam_pos_nr profile_id\=14 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=1 step\=5 trigger_puxch_update\=0
${PROFILE15}    ul_mimo_srs_beam_pos_nr profile_id\=15 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 step\=5 trigger_puxch_update\=0
${PROFILE16}    ul_mimo_srs_beam_pos_nr profile_id\=16 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
${SET_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
${SET_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
${SET_PROFILE5}    ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5
${SET_PROFILE6}    ue_testmode_set_nr id\=6 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=6
${SET_PROFILE7}    ue_testmode_set_nr id\=7 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=7
${SET_PROFILE8}    ue_testmode_set_nr id\=8 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=8
${SET_PROFILE9}    ue_testmode_set_nr id\=9 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=9
${SET_PROFILE10}    ue_testmode_set_nr id\=10 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=10
${SET_PROFILE11}    ue_testmode_set_nr id\=11 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=11
${SET_PROFILE12}    ue_testmode_set_nr id\=12 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=12
${SET_PROFILE13}    ue_testmode_set_nr id\=13 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=13
${SET_PROFILE14}    ue_testmode_set_nr id\=14 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=14
${SET_PROFILE15}    ue_testmode_set_nr id\=15 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=15
${SET_PROFILE16}    ue_testmode_set_nr id\=16 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=16
${deactive_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=1
${deactive_PROFILE1_2}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=2
${delete_PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 delete\=true
${delete_PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 delete\=true
${delete_PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 delete\=true
${delete_PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 delete\=true
${delete_PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 delete\=true
${delete_PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 delete\=true
${delete_PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 delete\=true
${delete_PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id\=8 delete\=true
${delete_PROFILE9}    ul_mimo_srs_beam_pos_nr profile_id\=9 delete\=true
${delete_PROFILE10}    ul_mimo_srs_beam_pos_nr profile_id\=10 delete\=true
${delete_PROFILE11}    ul_mimo_srs_beam_pos_nr profile_id\=11 delete\=true
${delete_PROFILE12}    ul_mimo_srs_beam_pos_nr profile_id\=12 delete\=true
${delete_PROFILE13}    ul_mimo_srs_beam_pos_nr profile_id\=13 delete\=true
${delete_PROFILE14}    ul_mimo_srs_beam_pos_nr profile_id\=14 delete\=true
${delete_PROFILE15}    ul_mimo_srs_beam_pos_nr profile_id\=15 delete\=true
${delete_PROFILE16}    ul_mimo_srs_beam_pos_nr profile_id\=16 delete\=true
# online change param
${MO_DN_1}    MRBTS-1/NRBTS-1/NRCELL-1/NRDLMUMIMO-1
@{MO_DN_LIST}      ${MO_DN_1}
&{UPDATED_PARAS_DICT_0}    dlMuMimoCqiThd=10
@{UPDATED_PARAS_DICT_LIST}		${UPDATED_PARAS_DICT_0}
&{UPDATED_PARAS_DICT_1}    dlMuPairingPrbRatio=0.3
@{UPDATED_PARAS_DICT_LIST_1}		${UPDATED_PARAS_DICT_1}
&{UPDATED_PARAS_DICT_2}    dlMuPairingPrbRatio=0
@{UPDATED_PARAS_DICT_LIST_2}		${UPDATED_PARAS_DICT_2}

*** Test Cases ***
CB009235_C_B101_Case33_DL_MU-MIMO_Enhanced_Unpair_PM_counters_with_Invalid_SRS_and_LOW_CQI
	Step1:Commission And Reach Onair
	Step2:attach 6 ues at 6 pos
	Step3:UE1-UE6 start little DL and UL nonGBR traffic
	Step4:check PM counter
	Step5:UE1-UE6 start full buffer DL and UL nonGBR traffic
	Step6:check PM counter again
	Step7:change UE1-UE2 SRS power and UE3-UE4 CQI less than dlMuMimoCqiTh
	Step8:check PM counter again
	#dettach UEs

*** Keywords ***
Step1:Commission And Reach Onair
    AIC Get and Update BSR File         BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
	AIC Perform Full Commission And Reach Onair DC    ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/SCF/${DU_SCF}
	...    ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/WTS/${WTS_CFG}     ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/SCF/${CU_SCF}

Step2:attach 6 ues at 6 pos
    Attach '6' SA UEs
    set SA UEs Pos

Attach '${UE_NUM_SA}' SA UEs
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
        Attach SA ue with capability    ${num}    CA_P2_8x4_t2r4_n2
	#    Airphone SA Attach    ue_id=${num}
	    ${gw_pdu_r}    evaluate    ${num}%10+1
	    airphone_set_traffic_type   ${num}    ${gw_pdu_r}    internal
	    Airphone Pdu Session Setup    ${num}    ${gw_pdu_r}    1    ${gw_pdu_r}
	    Wait Throughput Timer    0.1
	END

set SA UEs Pos   #per position 4ues
    log to console    ste ues pos
	FOR    ${num}    IN RANGE    1    7
        airphone_execute_egate_command    ${PROFILE${num}}
	    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${num}
    END

Step3:UE1-UE6 start little DL and UL nonGBR traffic
    Log To Console    \n\r==================step3 do little tarffic==================\n\r
	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_do_liitle_traffic
	FOR    ${i}    IN RANGE    1    7
	   ${gw_pdu_r}    evaluate    ${i}%10+1
        Airphone SA Start Data Traffic    ${i}    DL    5M    trf_id=1    pdu_id=${gw_pdu_r}    duration=${3600}
	    Airphone SA Start Data Traffic    ${i}    UL    1M    trf_id=1    pdu_id=${gw_pdu_r}    duration=${3600}
    END
	${trace_id}     VDU Start TTiTrace Log
    Wait '1s' for stabible
    VDU Stop TTiTrace Log    ${trace_id}
    VDU Decode TTiTrace Log    csv_dir=${save_log}/tti
	#run keyword and continue on failure    check_power_boosting    ${save_log}/tti_dl.csv

Step4:check PM counter
    Log To Console    \n\r==================step4 check PM connter==================\n\r
	${Counter_list}    get DL UL tput from PM counter and get MU counter
	${FAIL_LOW_PRB_counter}    Set Variable    ${Counter_list}[19]
	run keyword and continue on failure    should_be_true    ${FAIL_LOW_PRB_counter}>0

Step5:UE1-UE6 start full buffer DL and UL nonGBR traffic
    Log To Console    \n\r==================step5 do large tarffic==================\n\r
	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step5_do_large_traffic
	FOR    ${i}    IN RANGE    1    7
	   ${gw_pdu_r}    evaluate    ${i}%10+1
        Airphone SA Start Data Traffic    ${i}    DL    175M    trf_id=1    pdu_id=${gw_pdu_r}    duration=${3600}
	    Airphone SA Start Data Traffic    ${i}    UL    150M    trf_id=1    pdu_id=${gw_pdu_r}    duration=${3600}
	    Airphone SA Start Data Traffic    ${i}    DL    175M    trf_id=2    pdu_id=${gw_pdu_r}    duration=${3600}
	    Airphone SA Start Data Traffic    ${i}    UL    150M    trf_id=2    pdu_id=${gw_pdu_r}    duration=${3600}
    END
	${trace_id}     VDU Start TTiTrace Log
    Wait '1s' for stabible
    VDU Stop TTiTrace Log    ${trace_id}
    VDU Decode TTiTrace Log    csv_dir=${save_log}/tti

Step6:check PM counter again
    Log To Console    \n\r==================step6 check PM counter again==================\n\r
	${Counter_list}    get DL UL tput from PM counter and get MU counter
	${FAIL_LOW_PRB_counter}    Set Variable    ${Counter_list}[19]
	#run keyword and continue on failure    should_be_true    ${FAIL_LOW_PRB_counter}>0

Step7:change UE1-UE2 SRS power and UE3-UE4 CQI less than dlMuMimoCqiTh
    Log To Console    \n\r==================step7 change UE3-UE4 CQI less than dlMuMimoCqiTh==================\n\r
	#VDU Online Change Parameters      ${MO_DN_LIST}     ${UPDATED_PARAS_DICT_LIST}
	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step7_change_CQI
	airphone_execute_egate_command    csi_override_testmode_nr profile_id\=10 cqi\=3 cqi_mode\=fixed
    Airphone Execute Egate Command    ue_testmode_set_nr id\=3 testmode\=csi_override action\=activate profile_id\=10
    Airphone Execute Egate Command    ue_testmode_set_nr id\=4 testmode\=csi_override action\=activate profile_id\=10
	${trace_id}     VDU Start TTiTrace Log
    Wait '1s' for stabible
    VDU Stop TTiTrace Log    ${trace_id}
    VDU Decode TTiTrace Log    csv_dir=${save_log}/tti

Step8:check PM counter again
    Log To Console    \n\r==================step8 check PM counter again==================\n\r
	${Counter_list}    get DL UL tput from PM counter and get MU counter
	${FAIL_SRS_BEAM_counter}    Set Variable    ${Counter_list}[17]
	${FAIL_LOW_CQI_counter}    Set Variable    ${Counter_list}[18]
	#run keyword and continue on failure    should_be_true    ${FAIL_SRS_BEAM_counter}>0
	run keyword and continue on failure    should_be_true    ${FAIL_LOW_CQI_counter}>0


get DL UL tput from PM counter and get MU counter
    Wait Throughput Timer    300
	${PM_counter_DL_value}    VDU Get PM Counter Value   counter_id=M55309C12001   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
	${DL_throughput}    evaluate    ${PM_counter_DL_value}*8/1024/1024
	${PM_counter_UL_value}    VDU Get PM Counter Value   counter_id=M55309C12002   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
	${UL_throughput}    evaluate    ${PM_counter_UL_value}*8/1024/1024
	${PM_counter_16layers}=    VDU Get PM Counter Value   counter_id=M55308C34023   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
	${PM_counter_16layers}=    Convert To Integer   ${PM_counter_16layers}
	${PM_counter_12layers}=    VDU Get PM Counter Value   counter_id=M55308C34019   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
	${PM_counter_12layers}=    Convert To Integer   ${PM_counter_12layers}
	${PM_counter_8layers}=    VDU Get PM Counter Value   counter_id=M55308C34011   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
	${PM_counter_8layers}=    Convert To Integer   ${PM_counter_8layers}
	${PM_counter_6layers}=    VDU Get PM Counter Value   counter_id=M55308C34009   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
	${PM_counter_6layers}=    Convert To Integer   ${PM_counter_6layers}
	${PM_counter_4layers}=    VDU Get PM Counter Value   counter_id=M55308C34007   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
	${PM_counter_4layers}=    Convert To Integer   ${PM_counter_4layers}
	${PM_counter_2layers}=    VDU Get PM Counter Value   counter_id=M55308C34005   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
	${PM_counter_2layers}=    Convert To Integer   ${PM_counter_2layers}
	${SU_MIMO_4layer}=    VDU Get PM Counter Value   counter_id=M55308C34004   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
	${SU_MIMO_4layer}=    Convert To Integer   ${SU_MIMO_4layer}
	${SU_MIMO_2layer}=    VDU Get PM Counter Value   counter_id=M55308C34002   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
	${SU_MIMO_2layer}=    Convert To Integer   ${SU_MIMO_2layer}
	${MU_MIMO_NOPAIR_UE}=    VDU Get PM Counter Value   counter_id=M55308C34012   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
	${MU_MIMO_NOPAIR_UE}=    Convert To Integer   ${MU_MIMO_NOPAIR_UE}
	${MU_MIMO_2PAIR_UE}=    VDU Get PM Counter Value   counter_id=M55308C34013   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
	${MU_MIMO_2PAIR_UE}=    Convert To Integer   ${MU_MIMO_2PAIR_UE}
	${MU_MIMO_3PAIR_UE}=    VDU Get PM Counter Value   counter_id=M55308C34014   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
	${MU_MIMO_3PAIR_UE}=    Convert To Integer   ${MU_MIMO_3PAIR_UE}
	${MU_MIMO_4PAIR_UE}=    VDU Get PM Counter Value   counter_id=M55308C34015   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
	${MU_MIMO_4PAIR_UE}=    Convert To Integer   ${MU_MIMO_4PAIR_UE}
	${DL_SUCC_counter}=    VDU Get PM Counter Value   counter_id=M55308C34030   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
	${DL_SUCC_counter}=    Convert To Integer   ${DL_SUCC_counter}
	${FAIL_BWP_counter}=    VDU Get PM Counter Value   counter_id=M55308C34031   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
	${FAIL_BWP_counter}=    Convert To Integer   ${FAIL_BWP_counter}
	${FAIL_TRAF_TYPE_counter}=    VDU Get PM Counter Value   counter_id=M55308C34032   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
	${FAIL_TRAF_TYPE_counter}=    Convert To Integer   ${FAIL_TRAF_TYPE_counter}
	${FAIL_SRS_BEAM_counter}=    VDU Get PM Counter Value   counter_id=M55308C34033   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
	${FAIL_SRS_BEAM_counter}=    Convert To Integer   ${FAIL_SRS_BEAM_counter}
	${FAIL_LOW_CQI_counter}=    VDU Get PM Counter Value   counter_id=M55308C34034   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
	${FAIL_LOW_CQI_counter}=    Convert To Integer   ${FAIL_LOW_CQI_counter}
	${FAIL_LOW_PRB_counter}=    VDU Get PM Counter Value   counter_id=M55308C34035   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
	${FAIL_LOW_PRB_counter}=    Convert To Integer   ${FAIL_LOW_PRB_counter}
	${FAIL_HIGH_CORR_counter}=    VDU Get PM Counter Value   counter_id=M55308C34036   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
	${FAIL_HIGH_CORR_counter}=    Convert To Integer   ${FAIL_HIGH_CORR_counter}
	${FAIL_SE_counter}=    VDU Get PM Counter Value   counter_id=M55308C34037   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
	${FAIL_SE_counter}=    Convert To Integer   ${FAIL_SE_counter}
	${FAIL_OTHER_counter}=    VDU Get PM Counter Value   counter_id=M55308C34038   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
	${FAIL_OTHER_counter}=    Convert To Integer   ${FAIL_OTHER_counter}
    [Return]    ${DL_throughput}    ${UL_throughput}    ${PM_counter_16layers}    ${PM_counter_12layers}    ${PM_counter_8layers}
	...    ${PM_counter_6layers}    ${PM_counter_2layers}    ${SU_MIMO_4layer}   ${SU_MIMO_2layer}    ${PM_counter_4layers}
	...    ${MU_MIMO_NOPAIR_UE}    ${MU_MIMO_2PAIR_UE}    ${MU_MIMO_3PAIR_UE}    ${MU_MIMO_4PAIR_UE}   ${DL_SUCC_counter}
	...    ${FAIL_BWP_counter}    ${FAIL_TRAF_TYPE_counter}    ${FAIL_SRS_BEAM_counter}    ${FAIL_LOW_CQI_counter}   ${FAIL_LOW_PRB_counter}
	...    ${FAIL_HIGH_CORR_counter}    ${FAIL_SE_counter}    ${FAIL_OTHER_counter}

dettach UEs
    FOR    ${num}    IN RANGE    1    7
        airphone_execute_egate_command    ${delete_PROFILE${num}}
    END
    DeRegister UE from '1' to '6'

Add FreeRbg RD to swconfig
    ${vdu_version}    Get VDU SW version
	Log To Console    ${vdu_version}
	${hostname}    Get Host Name
	Log To Console    ${hostname}
	#${host_name}    Replace String    ${hostname}    -    _
	#Log To Console    ${host_name}
	VDU Master Login
    ${swconfig_l2rt}    SSH.Execute
    ...    command=sed -i '$a\0x5805c3=1 #free RBGs RD' /var/home/core/${hostname}/vDUCNF00_${vdu_version}/0/l2rt/swconfig_l2rt.txt
	...    connection=vdu_master
	Log To Console    ${swconfig_l2rt}
	SSH.Disconnect    connection=vdu_master

Register_UE1
	UE from '1' to '1' SA Register
	Set UE1 position_1
	Wait '2s' for stabible
	send DLUL data from UE '1' to '1'

Register_UE2
	UE from '2' to '2' SA Register
	Set UE2 position
	Wait '2s' for stabible
	send DLUL data from UE '2' to '2'

Register_UE3
	UE from '3' to '3' SA Register
	Set UE3 position
	Wait '2s' for stabible
	send DLUL data from UE '3' to '3'

Register_UE4
	UE from '4' to '4' SA Register
	Set UE4 position
	Wait '2s' for stabible
	send DLUL data from UE '4' to '4'

Set UE1 position_1
    Airphone Execute Egate Command    ${PROFILE1}
    Airphone Execute Egate Command    ${SET_PROFILE1}

Set UE2 position
    Airphone Execute Egate Command    ${PROFILE2}
    Airphone Execute Egate Command    ${SET_PROFILE2}

Set UE3 position
    Airphone Execute Egate Command    ${PROFILE3}
    Airphone Execute Egate Command    ${SET_PROFILE3}

Set UE4 position
    Airphone Execute Egate Command    ${PROFILE4}
    Airphone Execute Egate Command    ${SET_PROFILE4}

delete profile_1_2_3_4
	Airphone Execute Egate Command    ${delete_PROFILE1}
	Airphone Execute Egate Command    ${delete_PROFILE2}
	Airphone Execute Egate Command    ${delete_PROFILE3}
	Airphone Execute Egate Command    ${delete_PROFILE4}

UE from '${lo}' to '${hi}' SA Register
    FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
    #   airphone_cleanup_egate_console_log
       Log To Console   ${\n}-----register UE ${num} ------

       Airphone SA Attach    ue_id=${num}
	   Wait '1s' for stabible
       Airphone Set Traffic Type    ${num}    ${num}    internal
       Airphone Pdu Session Setup    ${num}    ${num}    1    ${num}
       Wait '2s' for stabible
	END

send DLUL data from UE '${lo}' to '${hi}'
	FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
       DL and UL data to '${num}'
    END
DL and UL data to '${UE_ID}'
    Airphone SA Start Data Traffic    ${UE_ID}    DL   175M   pdu_id=${UE_ID}   duration=3600   trf_id=1
    Airphone SA Start Data Traffic    ${UE_ID}    UL   60M   pdu_id=${UE_ID}   duration=7200   trf_id=1
    Wait '4s' for stabible
    ${dl_tput_kb}    ${ul_tput_kb}    Obtain one sa ue dl and ul throught    ${UE_ID}  	pdu_id= ${UE_ID}
    ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
	${dl_tput_Mb}    evaluate    ${dl_tput_kb}/1000
    Log To Console		UE${UE_ID}_dl_ul ${dl_tput_Mb} ${ul_tput_Mb}

check throughput from UE '${low}' to '${hi}' with tp '${lo_tp}' to '${hi_tp}'
	Wait '5s' for stabible
	${cell_tp_ul}	  evaluate	0
    FOR    ${num}    IN RANGE    ${low}    ${hi}+1
       Log To Console    Check throughput UE${num}
          ${ul_tput_kb}=    airphone_get_throughput_on_specific_scell    ${num}    0    type=pusch    tput_type=ave
          ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
          Log To Console		ul ${ul_tput_Mb}
		  ${cell_tp_ul}    evaluate    ${cell_tp_ul}+${ul_tput_Mb}
    END
    Log To Console		=====ul_cell_tp ${cell_tp_ul}=====
    run keyword and continue on failure    should be true    ${cell_tp_ul}>${lo_tp}
	run keyword and continue on failure    should be true    ${cell_tp_ul}<${hi_tp}

DeRegister UE from '${low}' to '${hi}'
    FOR    ${num}    IN RANGE    ${low}    ${hi}+1
       airphone_sa_detach    ue_id=${num}    timeout=5
       Wait '4s' for stabible
	END
