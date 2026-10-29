# *** Settings ***
# Documentation
# ...    author: Meng Yan
# ...    contact: meng.yan@nokia-sbell.com
# ...    squad group: 5G_PZ_MMW_HZ_2_SG
# Force Tags    STATE_SW_UPLOADED       CLOUD_5G_CLASSICAL_ASIBL_ABIOB1_AEUD_AEUB_ENB    RAN_5G    RAN_5G_TDD 	SBTS00
# ...   PY39
# Resource    ./resources/keywords.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Suite Setup  Test Suite Setup
# Suite Teardown  Test Suite Teardown
# 
# *** Variables ***
# ${TS_LOG_PATH_BASE}   ${OUTPUT DIR}
# #${TS_CASE_LOG_PATH}    /home/ute/
# #${SCF_PATH}   ${commissionings_path}/HGZ/${testline_name}/
# #${scf_name}    7442_22R2_SCF.xml
# 
# *** Test Cases ***
# [1][1.0] L1 5G Loki reset triggered by BTS-OAM on critical failure
#     [Documentation]    Author: wang jiangrong
#     ...                This case describes loki reset tiggered by oam
#     [Tags]    CRT_TRUNK    CRT_UTE
#     [Setup]    Common Test Setup
#     Trigger loki A reset by OAM
#     sleep    30s
#     Check_Cell_on_lokiA_not_onair
#     Check_Cell_on_lokiB_onair
#     Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair  
#     [Teardown]    Common Test Teardown
# 
# [1][1.0] L1 5G Loki autonomous reset on critical failure without L3 call
#     [Documentation]    Author: Yan meng
#     ...                This case describes loki reset tiggered by specific faults(2087)
#     ...                having loki reset as recovery actions
#     [Tags]    CIT_TRUNK    CIT
#     [Setup]    Common Test Setup
#     Trigger loki A auto reset
#     Wait Until Keyword Succeeds    10min    2s    Check certain alarm raised    fault_id=2087
#     Check_Cell_on_lokiA_not_onair
#     Check_Cell_on_lokiB_onair
#     Sleep     120s
#     Wait Until Keyword Succeeds    15min    20s   Verify all cells should be onair
# 
#     [Teardown]    Common Test Teardown
# 
# [1][1.0] A#5 L1 5G Loki A reset on critical failure _ reset escalation procedure _ L3 use case
#     [Documentation]    Author: Yan meng
#     ...                This case describes reset escalation procedure by trigger fault 2087
#     ...                4 times within one hour having BBMOD reset as recovery actions
#     [Tags]    CRT_TRUNK    CRT_UTE    
#     [Setup]    Common Test Setup2
#      #configure for FMCADM_A. actForceUnitAutoResetSet on TRUE
#      Repeat Keyword   3x   L1 5G Loki A reset on critical failure
#      Trigger loki A auto reset
#      Wait Until Keyword Succeeds    10min    2s    Check certain alarm raised by faultId and faultName
#      ...    fault_id=2087    fault_Name=Baseband card autonomous reset as recovery action
#      Sleep     10s
#      Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair
# 
#     [Teardown]    Common Test Teardown
#     
# [1][1.0] B#1 L1 5G RAT reset procedure for capacity or core unit
#     [Documentation]    Author: Wang jiangrong
#     ...                This case describes rat reset tiggered by specific faults(4590) having
#     ...                5G RAT reset as recovery actions
#     [Tags]    CRT_TRUNK    CRT_UTE
#     [Setup]    Common Test Setup
#     trigger fault report after bts reset
#     Sleep     10s
#     Wait Until Keyword Succeeds    20min    2s    Check history alarm raised    fault_id=4590
#     Sleep     10s
#     Wait Until Keyword Succeeds    20min    20s    COAM Check GNB cell on air
#     [Teardown]    Common Test Teardown
# 
# #[1][1.0] C#1 Capacity_core unit 5G L3 SW reset on critical failure
#    #[Documentation]    Author: Yan meng
#    # ...               This case describes CPUE container reset tiggered by specific faults(4383)
#     #[Tags]    CRT_TRUNK    CRT_UTE
#     #[Setup]    Common Test Setup
#     #Trigger CPUE auto reset
#     #Wait Until Keyword Succeeds    10min    2s    Check certain alarm raised    fault_id=4383
#     #Check_Cell_on_lokiA_not_onair
#     #Check_Cell_on_lokiB_onair
#     #Sleep     120s
#     #Wait Until Keyword Succeeds    15min    20s   Verify all cells should be onair
# 
#     #[Teardown]    Common Test Teardown
# 
# [1][1.0] C#2 Capacity_core unit 5G L3 SW reset on critical failure_reset escalation procedure
#     [Documentation]    Author: Yan meng
#     ...                This case describes reset escalation procedure by trigger fault 4383
#     ...                4 times within one hour
#     [Tags]    CRT_TRUNK    CRT_UTE
#     [Setup]    Common Test Setup2
#      #onfigure for FMCADM_A. actForceUnitAutoResetSet on TRUE
#      Repeat Keyword   3x   Capacity_core unit 5G L3 SW reset on critical failure
#      Trigger CPUE auto reset
#      Wait Until Keyword Succeeds    10min    0.1s    Check certain alarm raised by faultId and faultName
#      ...    fault_id=4383    fault_Name=RAT autonomous reset as recovery action
#      Sleep     10s
#      Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair
# 
#     [Teardown]    Common Test Teardown
# 
# #[1][1.0] D#1 Capacity_core unit 5G L2 NRT SW reset on critical failure
#    # [Documentation]    Author: Yan meng
#     #...                This case describes UPUE container reset tiggered by specific faults(4383)
#    # [Tags]    CRT_TRUNK
#     #[Setup]    Common Test Setup
#     #Trigger UPUE auto reset
#     #Wait Until Keyword Succeeds    10min    2s    Check certain alarm raised    fault_id=4383
#    # Check_Cell_on_lokiA_not_onair
#    # Check_Cell_on_lokiB_onair
#    # Sleep     120s
#    # Wait Until Keyword Succeeds    15min    20s   Verify all cells should be onair
# 
#     #[Teardown]    Common Test Teardown
# 
# [1][1.0] D#2 Capacity_core unit 5G L2 NRT SW reset on critical failure- reset escalation procedure
#     [Documentation]    Author: Yan meng
#     ...                This case describes reset escalation procedure by trigger fault 4383
#     ...                4 times within one hour
#     [Tags]    CRT_TRUNK    CRT_UTE
#     [Setup]    Common Test Setup2
#      #onfigure for FMCADM_A. actForceUnitAutoResetSet on TRUE
#      Repeat Keyword   3x   Capacity_core unit 5G L2 NRT SW reset on critical failure
#      Trigger UPUE auto reset
#      Wait Until Keyword Succeeds    10min    0.1s    Check certain alarm raised by faultId and faultName
#      ...    fault_id=4383    fault_Name=RAT autonomous reset as recovery action
#      Sleep     10s
#      Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair
# 
#     [Teardown]    Common Test Teardown
# 
# #[1][1.0] E#1 Capacity_core unit 5G L2 RT SW reset on critical failure
#     #[Documentation]    Author: Yan meng
#     #...                This case describes L2RT container reset tiggered by specific faults(4383)
#     #[Tags]    CRT_TRUNK
#     #[Setup]    Common Test Setup
#     #Trigger L2RT auto reset
#    # Wait Until Keyword Succeeds    10min    2s    Check certain alarm raised    fault_id=4383
#    # Check_Cell_on_lokiA_not_onair
#    # Check_Cell_on_lokiB_onair
#    # Sleep     120s
#    # Wait Until Keyword Succeeds    15min    20s   Verify all cells should be onair
# 
#     #[Teardown]    Common Test Teardown
# 
# [1][1.0] E#2 Capacity_core unit 5G L2 RT SW reset on critical failure_reset escalation procedure
#     [Documentation]    Author: Yan meng
#     ...                This case describes reset escalation procedure by trigger fault 4383
#     ...                4 times within one hour
#     [Tags]    CRT_TRUNK    CRT_UTE    
#     [Setup]    Common Test Setup2
#      #onfigure for FMCADM_A. actForceUnitAutoResetSet on TRUE
#      Repeat Keyword   3x   Capacity_core unit 5G L2 RT SW reset on critical failure
#      Trigger L2RT auto reset
#      Wait Until Keyword Succeeds    10min    0.1s    Check certain alarm raised by faultId and faultName
#      ...    fault_id=4383    fault_Name=RAT autonomous reset as recovery action
#      Sleep     10s
#      Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair
# 
#     [Teardown]    Common Test Teardown
# 
# 
# *** Keywords ***
# Test Suite Setup
#     robot_common_operations.Common Suite Setup
#     Sleep    600s
#     CI_interface.Common Suite Setup
#     Connect to gnb coam via ssl
#     #COAM Commission with scf file    scf_file_path=${SCF_PATH}/${scf_name}
#     #...                              timeout=${600}    is_pdl_checking_needed=${False}
#     Wait Until Keyword Succeeds    10min    20s    COAM Check GNB cell on air
#     
# Test Suite Teardown
#     robot_common_operations.Common Suite Teardown
#     Connect to gnb coam via ssl
#     Wait Until Keyword Succeeds    10min    20s    COAM Check GNB cell on air
#     COAM Teardown gnb connections
#     
# Common Test Setup
#     robot_common_operations.Common Case Setup
#     Connect to gnb coam via ssl
#     Wait Until Keyword Succeeds    10min    20s    COAM Check GNB cell on air
# 
# Common Test Setup2
#     robot_common_operations.Common Case Setup 
#     Connect to gnb coam via ssl
#     coam.reset_site    timeout=20min    connection=GNB_OAM
#     Wait Until Keyword Succeeds    10min    20s    COAM Check GNB cell on air
# 
# Common Test Teardown
#     robot_common_operations.Common Case Teardown
#     COAM Teardown gnb connections
#     Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# Check_Cell_on_lokiA_not_onair
#     All cells in specified cell group should be not_onair    cell_group=NRCELLGRP-0
# 
# Check_Cell_on_lokiB_onair
#     All cells in specified cell group should be onair    cell_group=NRCELLGRP-1
# 
# Check_Cell_on_lokiA_onair
#     All cells in specified cell group should be onair    cell_group=NRCELLGRP-0
