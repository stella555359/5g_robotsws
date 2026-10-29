# *** Settings ***
# Documentation
# ...    author: ChenXu
# ...    contact: xu.2.chen@nokia-sbell.com
# ...    squad group: 5G_PZ_MMW_HZ_5_SG
# ...    Feature CNI-84152
# 
# Resource    ./CNI-84152_KW.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
# #Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
# 
# Library        ./Resources/getParameter.py
# 
# #Suite Setup     CNI-84152_KW.Common Suite Setup For Sbts       bts_type=gnb
# #Suite Teardown  Common Suite Teardown For Sbts
# 
# 
# #Suite Setup    CI_interface.Common Suite Setup
# #Suite Setup    Common Setup
# #Suite Teardown
# 
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Suite Setup     robot_common_operations.Common Suite Setup
# Suite Teardown   robot_common_operations.Common Suite Teardown
# Test Setup       robot_common_operations.Common Case Setup
# Test Teardown    robot_common_operations.Common Case Teardown
# 
# 
# 
# *** Variables ***
# ${ultp}    280
# ${dltp}    300
# ${FLAG}    ${False}
# #${virtual_enable}=    ${True}
# 
# 
# ${loop_times}    1
# ${5G_cell_num}    1
# ${4G_cell_num}    3
# 
# ${allowed_faults_sbts}=    61524 61648 61649 61652 4654 4655 4681 6261 6450   7311
# ${allowed_faults_asir}=    61648
# ${GNB_Conn}=    sbts_gnb
# 
# #${allowed_history_gnb_ResetHUBMOD}=    7300 7319 61648
# #${allowed_history_asir_ResetHUBMOD}=    4480
# #${required_history_asir_ResetHUBMOD}=    10
# 
# 
# *** Test Cases ***
# #CNI_84152_B-02_Cell_setup_with_splitmode_N78_2T2R_100M_B1_20M_B3_20M_15M_RFC_N78_100M_100M_B1_20M_20M_B3_20M_20M
# #    [Documentation]
# #    ...    The purpose of this case is to L3 call with split mode.
# #    [Tags]    CRT_TRUNK    CRT_23R1
# #	Set Library Search Order    CNI-84152_KW    bts_coam
# #	Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
# #	Connect to gnb coam via ssl    connection=GNB_OAM2    gnb_index=1
# #	${list_of_cell_id_1916}    Get List of NR Cell ID    connection=GNB_OAM
# #	${list_of_cell_id_1917}    Get List of NR Cell ID    connection=GNB_OAM2
# #	Verify all cells should be onair    connection=GNB_OAM    cell_type=nr
# #	Verify all cells should be onair    connection=GNB_OAM    cell_type=lte
# #	Verify all cells should be onair    connection=GNB_OAM2    cell_type=nr
# #	Verify all cells should be onair    connection=GNB_OAM2    cell_type=lte
# #
# #	log to console    \n ... check configuredSplitModePrrhCount in TL1916 \n
# #	${value}    get param value by asirmod id    param=configuredSplitModePrrhCount    asirmod_id=1    oam_ip=10.71.209.7
# #	should be equal    ${value}   1
# #	log to console    \n ... check configuredSplitModePrrhCount in TL1917 \n
# #	${value}    get param value by asirmod id    param=configuredSplitModePrrhCount    asirmod_id=1    oam_ip=10.71.209.8
# #	should be equal    ${value}   1
# #	
# #	log to console    \n ... TL1917_call_setup \n
# #	Lock 4G Cells    connection=GNB_OAM
# #	step3: Prepare UE
# #    Step4: UE Attach    gnb_index=1
# #	Step5: Start traffic DL
# #	${log}    power_ue.Collect Tput    ue_type=${ue_type}    gnb_index=1    duration=1m    filter=L2Lo
# #	${all_tp}    power_ue.Check Tput    ue_type=${ue_type}    direction=DL    log=${log}    cells=${list_of_cell_id_1917}
# #    ...    target_throughput=${dltp}    min_percent=0.4    actCarrierAggregation=${True}    actImgGeneration=False
# #    Step7: Stop traffic DL
# #	Step8: UE Detach
# #	Unlock 4G Cells    connection=GNB_OAM
# #	
# #	log to console    \n ... TL1916_call_setup \n
# #	Lock 4G Cells    connection=GNB_OAM2
# #	step3: Prepare UE
# #    Step4: UE Attach    gnb_index=0
# #	Step5: Start traffic DL
# #	${log}    power_ue.Collect Tput    ue_type=${ue_type}    gnb_index=0    duration=1m    filter=L2Lo
# #	${all_tp}    power_ue.Check Tput    ue_type=${ue_type}    direction=DL    log=${log}    cells=${list_of_cell_id_1916}
# #    ...    target_throughput=${dltp}    min_percent=0.4    actCarrierAggregation=${True}    actImgGeneration=False
# #    Step7: Stop traffic DL
# #    Step8: UE Detach
# #	Unlock 4G Cells    connection=GNB_OAM2
# #	[Teardown]   run keyword and ignore error    Run Keywords
# #	...    COAM Teardown gnb connections    connection=GNB_OAM    AND
# #	...    COAM Teardown gnb connections    connection=GNB_OAM2
# #	
# #	  
# #CNI_84152_B-04_Cell_pRRH_operate_with_RFC
# #    [Documentation]
# #    ...    The purpose of this case is to cell operate, Lock Cell, Block RAT, Reset Site, Block pRRH, Reset pRRH.
# #    [Tags]    CRT_TRUNK    CRT_23R1
# #	Set Library Search Order    CNI-84152_KW    bts_coam
# #	Connect to gnb coam via ssl    connection=GNB_OAM2    gnb_index=1
# #	Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
# #
# #	log to console    \n ... Subcase_1_Lock_unlock_Cell \n
# #	Lock 4G Cells    connection=GNB_OAM
# #	FOR  ${i}  IN RANGE  ${loop_times}
# #	  Verify all cells should be onair    connection=GNB_OAM2    cell_type=nr
# #	  Verify all cells should be onair    connection=GNB_OAM2    cell_type=lte
# #      Lock 5G Cells    connection=GNB_OAM2
# #	  Lock 4G Cells    connection=GNB_OAM2
# #      sleep    60s
# #	  Unlock 4G Cells    connection=GNB_OAM2
# #	  Unlock 5G Cells    connection=GNB_OAM2
# #      step3: Prepare UE
# #      Step4: UE Attach    gnb_index=1
# #      Step8: UE Detach
# #	END
# #	Unlock 4G Cells    connection=GNB_OAM
# #	
# #	log to console    \n ... Subcase_2_Block_unblock_RAT \n
# #	Lock 4G Cells    connection=GNB_OAM2
# #	FOR  ${i}  IN RANGE  ${loop_times}
# #	  Verify all cells should be onair    connection=GNB_OAM    cell_type=nr
# #	  Verify all cells should be onair    connection=GNB_OAM    cell_type=lte
# #	  Block RAT    connection=GNB_OAM    rat=NR
# #	  Block RAT    connection=GNB_OAM    rat=LTE
# #	  sleep    10s
# #	  Unblock RAT    connection=GNB_OAM    rat=LTE
# #	  Unblock RAT    connection=GNB_OAM    rat=NR
# #	  step3: Prepare UE
# #      Step4: UE Attach    gnb_index=0
# #      Step8: UE Detach
# #	END
# #	Unlock 4G Cells    connection=GNB_OAM2
# #	
# #	log to console    \n ... Subcase_3_Reset_Site \n
# #	FOR  ${i}  IN RANGE  ${loop_times}
# #	  Verify all cells should be onair    connection=GNB_OAM    cell_type=nr
# #	  Verify all cells should be onair    connection=GNB_OAM    cell_type=lte
# #	  Reset Site    connection=GNB_OAM
# #	  Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
# #	  Lock 4G Cells    connection=GNB_OAM
# #	  step3: Prepare UE
# #      Step4: UE Attach    gnb_index=1
# #      Step8: UE Detach
# #	  Unlock 4G Cells    connection=GNB_OAM
# #	END
# #	COAM Teardown gnb connections    connection=GNB_OAM
# #	COAM Teardown gnb connections    connection=GNB_OAM2
# #
# #	log to console    \n ... Subcase_4_Block_Unblock_pRRH \n
# #	Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
# #	Connect to gnb coam via ssl    connection=GNB_OAM2    gnb_index=1
# #	${list_of_cell_id_1916}    Get List of NR Cell ID    connection=GNB_OAM
# #	${list_of_cell_id_1917}    Get List of NR Cell ID    connection=GNB_OAM2
# #	FOR  ${i}  IN RANGE  ${loop_times}
# #	  Block_ANTMOD    ant_mod_id=2
# #	  sleep    30s
# #	  Unblock_ANTMOD    ant_mod_id=2
# #	  sleep    30s
# #	  Block_ANTMOD    ant_mod_id=1
# #	  sleep    30s
# #	  Unblock_ANTMOD    ant_mod_id=1
# #	  Verify all cells should be onair    connection=GNB_OAM    cell_type=nr
# #	  Verify all cells should be onair    connection=GNB_OAM    cell_type=lte
# #	  Verify all cells should be onair    connection=GNB_OAM2    cell_type=nr
# #	  Verify all cells should be onair    connection=GNB_OAM2    cell_type=lte
# #	  Lock 4G Cells    connection=GNB_OAM
# #	  step3: Prepare UE
# #      Step4: UE Attach    gnb_index=1
# #	  Step5: Start traffic DL
# #	  ${log}    power_ue.Collect Tput    ue_type=${ue_type}    gnb_index=1    duration=1m    filter=L2Lo
# #	  ${all_tp}    power_ue.Check Tput    ue_type=${ue_type}    direction=DL    log=${log}    cells=${list_of_cell_id_1917}
# #      ...    target_throughput=${dltp}    min_percent=0.4    actCarrierAggregation=${True}    actImgGeneration=False
# #      Step7: Stop traffic DL
# #	  Step8: UE Detach
# #	  Unlock 4G Cells    connection=GNB_OAM
# #	END
# #	
# #	log to console    \n ... Subcase_5_Reset_pRRH \n
# #	FOR  ${i}  IN RANGE  ${loop_times}
# #	  Reset_ANTMOD    ant_mod_id=1
# #	  Reset_ANTMOD    ant_mod_id=2
# #	  Verify all cells should be onair    connection=GNB_OAM    cell_type=nr
# #	  Verify all cells should be onair    connection=GNB_OAM    cell_type=lte
# #	  Verify all cells should be onair    connection=GNB_OAM2    cell_type=nr
# #	  Verify all cells should be onair    connection=GNB_OAM2    cell_type=lte
# #	  Lock 4G Cells    connection=GNB_OAM
# #	  step3: Prepare UE
# #      Step4: UE Attach    gnb_index=1
# #	  Step5: Start traffic DL
# #	  ${log}    power_ue.Collect Tput    ue_type=${ue_type}    gnb_index=1    duration=1m    filter=L2Lo
# #	  ${all_tp}    power_ue.Check Tput    ue_type=${ue_type}    direction=DL    log=${log}    cells=${list_of_cell_id_1917}
# #      ...    target_throughput=${dltp}    min_percent=0.4    actCarrierAggregation=${True}    actImgGeneration=False
# #      Step7: Stop traffic DL
# #	  Step8: UE Detach
# #	  Unlock 4G Cells    connection=GNB_OAM
# #	END
# #	run keyword and ignore error    Teardown Admin Connection    connection=${GNB_Conn}
# #	[Teardown]   run keyword and ignore error    Run Keywords
# #	...    COAM Teardown gnb connections    connection=GNB_OAM    AND
# #	...    COAM Teardown gnb connections    connection=GNB_OAM2   
# #
# #CNI_84152_A-05_APHG_operate
# #    [Documentation]
# #    ...    The purpose of this case is to APHG operate, Lock ASiRMOD, Reset ASiRMOD.
# #    [Tags]    CRT_TRUNK    CRT_23R1
# #	Set Library Search Order    CNI-84152_KW    bts_coam
# #    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
# #	Connect to gnb coam via ssl    connection=GNB_OAM2    gnb_index=1
# #	${list_of_cell_id_1916}    Get List of NR Cell ID    connection=GNB_OAM
# #	${list_of_cell_id_1917}    Get List of NR Cell ID    connection=GNB_OAM2
# #	
# #	log to console    \n ... Subcase_1_Lock_unlock_APHG \n
# #	FOR  ${i}  IN RANGE  ${loop_times}
# #      Verify all cells should be onair    cell_type=nr
# #	  Verify all cells should be onair    cell_type=lte
# #	  Lock ASiRMOD    connection=GNB_OAM
# #      sleep    30s
# #      Unlock ASiRMOD    connection=GNB_OAM
# #	  sleep    30s
# #      Lock 4G Cells    connection=GNB_OAM
# #	  step3: Prepare UE
# #      Step4: UE Attach    gnb_index=1
# #	  Step5: Start traffic DL
# #	  ${log}    power_ue.Collect Tput    ue_type=${ue_type}    gnb_index=1    duration=1m    filter=L2Lo
# #	  ${all_tp}    power_ue.Check Tput    ue_type=${ue_type}    direction=DL    log=${log}    cells=${list_of_cell_id_1917}
# #      ...    target_throughput=${dltp}    min_percent=0.4    actCarrierAggregation=${True}    actImgGeneration=False
# #      Step7: Stop traffic DL
# #	  Step8: UE Detach
# #	  Unlock 4G Cells    connection=GNB_OAM
# #	END
# #	
# #	log to console    \n ... Subcase_2_Reset_APHG_via_WEBEM \n
# #	FOR  ${i}  IN RANGE  ${loop_times}
# #	  Verify all cells should be onair    cell_type=nr
# #	  Verify all cells should be onair    cell_type=lte
# #	  Reset ASiRMOD    connection=GNB_OAM
# #	  sleep    30s
# #	  Lock 4G Cells    connection=GNB_OAM
# #	  step3: Prepare UE
# #      Step4: UE Attach    gnb_index=1
# #      Step8: UE Detach
# #	  Unlock 4G Cells    connection=GNB_OAM
# #	END
# #	
# #	log to console    \n ... Subcase_3_Reset_APHG_via_ASiR_WEBEM \n
# #	FOR  ${i}  IN RANGE  ${loop_times}
# #	  Reset_HUBMOD
# #	  sleep    30s
# #	  Lock 4G Cells    connection=GNB_OAM
# #	  step3: Prepare UE
# #      Step4: UE Attach    gnb_index=1
# #	  Step5: Start traffic DL
# #	  ${log}    power_ue.Collect Tput    ue_type=${ue_type}    gnb_index=1    duration=1m    filter=L2Lo
# #	  ${all_tp}    power_ue.Check Tput    ue_type=${ue_type}    direction=DL    log=${log}    cells=${list_of_cell_id_1917}
# #      ...    target_throughput=${dltp}    min_percent=0.4    actCarrierAggregation=${True}    actImgGeneration=False
# #      Step7: Stop traffic DL
# #	  Step8: UE Detach
# #	  Unlock 4G Cells    connection=GNB_OAM
# #	END
# #	run keyword and ignore error    Teardown Admin Connection    connection=${GNB_Conn}
# #	[Teardown]   run keyword and ignore error    Run Keywords
# #	...    COAM Teardown gnb connections    connection=GNB_OAM    AND
# #	...    COAM Teardown gnb connections    connection=GNB_OAM2
# #
# #CNI_84152_B-08_Add_delete_cell
# #    [Documentation]
# #    ...    The purpose of this case is to check the RFC Cell is normal after delete add RFC Cell operate.
# #    [Tags]    CRT_TRUNK    CRT_23R1
# #	Set Library Search Order    CNI-84152_KW    bts_coam
# #	Delete_RFC_Cell    cell_id=1
# #	Delete_RFC_Cell    cell_id=2
# #	Add_RFC_Cell_1
# #	Add_RFC_Cell_2
# #	Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
# #	Connect to gnb coam via ssl    connection=GNB_OAM2    gnb_index=1
# #	${list_of_cell_id_1916}    Get List of NR Cell ID    connection=GNB_OAM
# #	${list_of_cell_id_1917}    Get List of NR Cell ID    connection=GNB_OAM2
# #	Lock 4G Cells    connection=GNB_OAM
# #	step3: Prepare UE
# #    Step4: UE Attach    gnb_index=1
# #	Step5: Start traffic DL
# #	${log}    power_ue.Collect Tput    ue_type=${ue_type}    gnb_index=1    duration=1m    filter=L2Lo
# #	${all_tp}    power_ue.Check Tput    ue_type=${ue_type}    direction=DL    log=${log}    cells=${list_of_cell_id_1917}
# #    ...    target_throughput=${dltp}    min_percent=0.4    actCarrierAggregation=${True}    actImgGeneration=False
# #    Step7: Stop traffic DL
# #	Step8: UE Detach
# #	Unlock 4G Cells    connection=GNB_OAM
# #	run keyword and ignore error    Teardown Admin Connection    connection=${GNB_Conn}
# #	[Teardown]   run keyword and ignore error    Run Keywords
# #	...    COAM Teardown gnb connections    connection=GNB_OAM    AND
# #	...    COAM Teardown gnb connections    connection=GNB_OAM2
# #
# #CNI_84152_B-03_pRRH_unplug_plug_with_RFC
# #    [Documentation]
# #    ...    The purpose of this case is to check pRRH can recover when plug out and plugin PoE.
# #    [Tags]    CRT_TRUNK    CRT_23R1
# #	Set Library Search Order    CNI-84152_KW    bts_coam
# #	pRRH_unplug    port_id=3
# #	sleep    60s
# #	pRRH_plug    port_id=3
# #	Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
# #	Connect to gnb coam via ssl    connection=GNB_OAM2    gnb_index=1
# #	${list_of_cell_id_1916}    Get List of NR Cell ID    connection=GNB_OAM
# #	${list_of_cell_id_1917}    Get List of NR Cell ID    connection=GNB_OAM2
# #	Lock 4G Cells    connection=GNB_OAM
# #	step3: Prepare UE
# #    Step4: UE Attach    gnb_index=1
# #	Step5: Start traffic DL
# #	${log}    power_ue.Collect Tput    ue_type=${ue_type}    gnb_index=1    duration=1m    filter=L2Lo
# #	${all_tp}    power_ue.Check Tput    ue_type=${ue_type}    direction=DL    log=${log}    cells=${list_of_cell_id_1917}
# #    ...    target_throughput=${dltp}    min_percent=0.4    actCarrierAggregation=${True}    actImgGeneration=False
# #    Step7: Stop traffic DL
# #	Step8: UE Detach
# #	Unlock 4G Cells    connection=GNB_OAM
# #	run keyword and ignore error    Teardown Admin Connection    connection=${GNB_Conn}
# #	[Teardown]   run keyword and ignore error    Run Keywords
# #	...    COAM Teardown gnb connections    connection=GNB_OAM    AND
# #	...    COAM Teardown gnb connections    connection=GNB_OAM2
# 
# 
# *** Keywords ***
# 
#     
