# *** Settings ***
# Documentation
# ...  author: Chen Liang 6
# ...  contact: liang.6.chen@nokia-sbell.com
# 
# Resource   ./Resource/Common.robot
# Resource    ../../../resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Force Tags   SG_07   CA_5G_OAM   STATE_SW_UPDATED   RAN_5G   RAN_5G_TDD
# ...   PY36
# ...   CLOUD_5G_CLASSICAL_ANDROID_SA_ASIKL_ABILB1_AEQN_NETACT   SBTS00
# ...   AUTHOR_liang.6.chen@nokia-sbell.com
# 
# Test Timeout   4h
# 
# Suite Setup   Common Suite Setup
# Suite Teardown   Common Suite Teardown
# 
# *** Variables ***
# ${ue_index}   ${0}
# ${WEBUI_ADDR}   ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
# 
# *** Test Cases ***
# CB007425_001_PCMD_Configuration_Activation_and_Deactivation_Multi_Times
#     [Documentation]   Author: liang.6.chen@nokia-sbell.com
#     [Setup]   Case Setup: B_001
#     001_PCMD_Configuration_Activation_and_Deactivation_Multi_Times
#     [Teardown]   Case Teardown: B_001
# 
# CB007425_002_PCMD_TCE_TCP_Connection_Fault_8000_Raise_And_Clear_Multi_Times
#     [Documentation]   Author: liang.6.chen@nokia-sbell.com
#     [Setup]   Case Setup: B_002
#     002_PCMD_TCE_TCP_Connection_Fault_8000_Raise_And_Clear_Multi_Times
#     [Teardown]   Case Teardown: B_002
# 
# CB007425_003_PCMD_Link_Management_On_Cell_State_Change
#     [Documentation]   Author: liang.6.chen@nokia-sbell.com
#     [Setup]   Case Setup: B_007
#     Run Keyword And Ignore Error    robot_common_operations.Common case setup
#     007_PCMD_Record_DU_UE_Context_Setup
#     [Teardown]   Case Teardown: B_007
# 
# CB007425_004_PCMD_Configuration_Activation_and_Reboot
#     [Documentation]   Author: liang.6.chen@nokia-sbell.com
#     [Setup]   Case Setup: CB007425_004
#     004_PCMD_Configuration_Activation_and_Reboot
#     [Teardown]   Case Teardown: CB007425_004
# 
# CB007425_007_PCMD_Record_DU_UE_Context_Setup
#     [Documentation]   Author: liang.6.chen@nokia-sbell.com
#     [Setup]   Case Setup: B_007
#     007_PCMD_Record_DU_UE_Context_Setup
#     [Teardown]   Case Teardown: B_007
# 
# CB007425_008_PCMD_Record_DU_UE_Context_Release
#     [Documentation]   Author: liang.6.chen@nokia-sbell.com
#     [Setup]   Case Setup: B_008
#     008_PCMD_Record_DU_UE_Context_Release
#     [Teardown]   Case Teardown: B_008
# 
# CB007425_009_PCMD_Record_CU_SgNB_Addition
#     [Documentation]   Author: liang.6.chen@nokia-sbell.com
#     [Setup]   Case Setup: CB007425_009
#     009_PCMD_Record_CU_SgNB_Addition
#     [Teardown]   Case Teardown: CB007425_009
# 
# CB007425_010_PCMD_Record_CU_SgNB_Addition_Rejection
#     [Documentation]   Author: liang.6.chen@nokia-sbell.com
#     [Setup]   Case Setup: B_008
#     Run Keyword And Ignore Error    robot_common_operations.Common case setup
#     008_PCMD_Record_DU_UE_Context_Release
#     [Teardown]   Case Teardown: B_008
# 
# CB007425_011_PCMD_Record_CU_SgNB_Release_MeNB_Initiated
#     [Documentation]   Author: liang.6.chen@nokia-sbell.com
#     [Setup]   Case Setup: B_011
#     011_PCMD_Record_CU_SgNB_Release_MeNB_Initiated
#     [Teardown]   Case Teardown: B_011
# 
# CB007425_012_PCMD_Record_CU_SgNB_Release_SgNB_Initiated
#     [Documentation]   Author: liang.6.chen@nokia-sbell.com
#     [Setup]   Case Setup: CB007425_012
#     012_PCMD_Record_CU_SgNB_Release_SgNB_Initiated
#     [Teardown]   Case Teardown: CB007425_012
# 
# CB007425_013_PCMD_Record_DU_UE_Release_Record
#     [Documentation]   Author: liang.6.chen@nokia-sbell.com
#     [Setup]   Case Setup: CB007425_013
#     013_PCMD_Record_DU_UE_Release_Record
#     [Teardown]   Case Teardown: CB007425_013
# 
# CB007425_014_PCMD_Record_CU_UE_Release_Record
#     [Documentation]   Author: liang.6.chen@nokia-sbell.com
#     [Setup]   Case Setup: CB007425_014
#     013_PCMD_Record_DU_UE_Release_Record
#     [Teardown]   Case Teardown: CB007425_014
# 
# CB007425_015_PCMD_Record_CU_UE_Release_Record_with_cacFailure
#     [Documentation]   Author: liang.6.chen@nokia-sbell.com
#     [Setup]   Case Setup: CB007425_009
#     Run Keyword And Ignore Error    robot_common_operations.Common case setup
#     009_PCMD_Record_CU_SgNB_Addition
#     [Teardown]   Case Teardown: CB007425_009
#     
# CB007425_017_PCMD_Record_Normal_L3_Call_Procedure
#     [Documentation]   Author: liang.6.chen@nokia-sbell.com
#     [Setup]   Case Setup: B_011
#     Run Keyword And Ignore Error    robot_common_operations.Common case setup
#     011_PCMD_Record_CU_SgNB_Release_MeNB_Initiated
#     [Teardown]   Case Teardown: B_011
# 
# CB007425_018_PCMD_Record_CU_UE_Release_SgNB_Initiated_Record
#     [Documentation]   Author: liang.6.chen@nokia-sbell.com
#     [Setup]   Case Setup: CB007425_013
#     Run Keyword And Ignore Error    robot_common_operations.Common case setup
#     013_PCMD_Record_DU_UE_Release_Record
#     [Teardown]   Case Teardown: CB007425_013
# 
# *** Keywords ***
# Common Suite Setup
#     ${TEST_NAME}   Set Variable   Suite_Setup
#     Common Setup 1756
#     Get PCMD Value
#     Make L3 Call and Capture Tcpdump Log
#     #Make L3 Call and Capture Tcpdump Log with NsaInactivityTimer Equal to 0
#     #Make L3 Call and Capture Tcpdump Log with MaxNumOfUsersNRCell Equal to 0
# 
# Common Suite Teardown
#     Run Keyword And Ignore Error   COAM WEBUI Logout
#     Run Keyword And Ignore Error   Run Keyword If Any Tests Failed   Catch Snapshot COAM
#     Common Teardown 1756
