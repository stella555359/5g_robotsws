# *** Settings ***
# Documentation
# ...  author: Chen Yin 4
# ...  contact: yin.4.chen@nokia-sbell.com   lei.nie@nokia-sbell.com
# 
# Resource   ./Resource/Common.robot
# 
# Force Tags   SG_07   CA_5G_OAM    CRT_UTE   master_classicalbts_all   5G_RAN
# ...    PY36
# ...   5G_RAN_TDD   CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQN_NETACT   STATE_SW_UPLOADED
# ...   AUTHOR_yin.4.chen@nokia-sbell.com   RAN_5G   RAN_5G_TDD   SBTS00
# 
# Test Timeout   2h
# 
# Suite Setup   Wait Until Keyword Succeeds   3x   30s   COAM commissioning if not onair
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]5GC001598_001_Commissioning_Wizard_Create_Plan_Copy
#     [Tags]   AUTHOR_yin.4.chen@nokia-sbell.com
#     [Setup]   Case Setup: Create_Plan_Copy
#     [Teardown]   Case Teardown: Create_Plan_Copy
#     Commissioning_Wizard_Create_Plan_Copy
# 
# [1]5GC001598_002_Commissioning_Wizard_Create_Plan_Multiple
#     [Tags]   AUTHOR_yin.4.chen@nokia-sbell.com
#     [Setup]   Case Setup: Create_Plan_Multiple
#     [Teardown]   Case Teardown: Create_Plan_Multiple
#     Commissioning_Wizard_Create_Plan_Multiple
# 
# [1]5GC001598_003_Commissioning_Wizard_Create_Plan_And_Backup
#     [Tags]   AUTHOR_yin.4.chen@nokia-sbell.com
#     [Setup]   Case Setup: Create_Plan_And_Backup
#     [Teardown]   Case Teardown: Create_Plan_And_Backup
#     Commissioning_Wizard_Create_Plan_And_Backup
# 
# [1]5GC001598_004_Commissioning_Wizard_Load_SCF_And_Edit
#     [Tags]   AUTHOR_yin.4.chen@nokia-sbell.com
#     [Setup]   Case Setup: Load_SCF_And_Edit
#     [Teardown]   Case Teardown: Load_SCF_And_Edit
#     Commissioning_Wizard_Load_SCF_And_Edit
# 
# [1]5GC001598_005_Commissioning_Wizard_Edit_Activate_Plan
#     [Tags]   AUTHOR_yin.4.chen@nokia-sbell.com
#     [Setup]   Case Setup: Edit_Activate_Plan
#     [Teardown]   Case Teardown: Edit_Activate_Plan
#     Commissioning_Wizard_Edit_Activate_Plan
# 
# [1]5GC001598_006_Commissioning_Wizard_Edit_Inactivate_Plan_SCF
#     [Tags]   AUTHOR_yin.4.chen@nokia-sbell.com
#     [Setup]   Case Setup: Edit_Inactivate_Plan_SCF
#     [Teardown]   Case Teardown: Edit_Inactivate_Plan_SCF
#     Commissioning_Wizard_Edit_Inactivate_Plan_SCF
# 
# [1]5GC001598_009_Commissioning_Wizard_Automatically_Commission_Detected_HW
#     [Tags]   AUTHOR_yin.4.chen@nokia-sbell.com
#     [Setup]   Case Setup: Automatically_Commission_Detected_HW
#     [Teardown]   Case Teardown: Automatically_Commission_Detected_HW
#     Commissioning_Wizard_Automatically_Commission_Detected_HW
# 
# [1]5GC001598_010_Commissioning_Wizard_Create_Plan_In_CW_And_Switch_PE_Edit
#     [Tags]   AUTHOR_yin.4.chen@nokia-sbell.com
#     [Setup]   Case Setup: Create_Plan_In_CW_And_Switch_PE_Edit
#     [Teardown]   Case Teardown: Create_Plan_In_CW_And_Switch_PE_Edit
#     Commissioning_Wizard_Create_Plan_In_CW_And_Switch_PE_Edit
# 
# [1]5GC001598_011_Commissioning_Wizard_Create_Plan_In_PE_And_Switch_CW_Edit
#     [Tags]   AUTHOR_yin.4.chen@nokia-sbell.com
#     [Setup]   Case Setup: Create_Plan_In_PE_And_Switch_CW_Edit
#     [Teardown]   Case Teardown: Create_Plan_In_PE_And_Switch_CW_Edit
#     Commissioning_Wizard_Create_Plan_In_PE_And_Switch_CW_Edit
# 
# [1]5GC001598_012_Commissioning_Wizard_Create_Plan_In_Site_View
#     [Tags]   AUTHOR_yin.4.chen@nokia-sbell.com
#     [Setup]   Case Setup: Create_Plan_In_Site_View
#     [Teardown]   Case Teardown: Create_Plan_In_Site_View
#     Commissioning_Wizard_Create_Plan_In_Site_View
# 
# [1]5GC001598_013_Commissioning_Wizard_Create_Plan_In_Modal_View
#     [Tags]   AUTHOR_yin.4.chen@nokia-sbell.com
#     [Setup]   Case Setup: Create_Plan_In_Modal_View
#     [Teardown]   Case Teardown: Create_Plan_In_Modal_View
#     Commissioning_Wizard_Create_Plan_In_Modal_View
# 
# [1]5GC001598_014_Commissioning_Wizard_Create_Plan_With_48_Cells
#     [Tags]   AUTHOR_yin.4.chen@nokia-sbell.com
#     [Setup]   Case Setup: Create_Plan_With_48_Cells
#     [Teardown]   Case Teardown: Create_Plan_With_48_Cells
#     Commissioning_Wizard_Create_Plan_With_48_Cells
# 
# [1]5GC001598_015_Commissioning_Wizard_Create_Plan_With_Default_Values_No_Relation_Errors
#     [Tags]   AUTHOR_yin.4.chen@nokia-sbell.com
#     [Setup]   Case Setup: Create_Plan_With_Default_Values_No_Relation_Errors
#     [Teardown]   Case Teardown: Create_Plan_With_Default_Values_No_Relation_Errors
#     Commissioning_Wizard_Create_Plan_With_Default_Values_No_Relation_Errors
# 
# [1]5GC001598_016_Commissioning_Wizard_Create_Plan_With_Minimal_Relation_Errors
#     [Tags]   AUTHOR_yin.4.chen@nokia-sbell.com
#     [Setup]   Case Setup: Create_Plan_With_Minimal_Relation_Errors
#     [Teardown]   Case Teardown: Create_Plan_With_Minimal_Relation_Errors
#     Commissioning_Wizard_Create_Plan_With_Minimal_Relation_Errors
# 
# [1]5GC001598_017_Commissioning_Wizard_Cell_Addtion_Deletion
#     [Tags]   AUTHOR_yin.4.chen@nokia-sbell.com
#     [Setup]   Case Setup: Cell_Addtion_Deletion
#     [Teardown]   Case Teardown: Cell_Addtion_Deletion
#     Commissioning_Wizard_Cell_Addtion_Deletion
# 
# [1]5GC001598_018_Commissioning_Wizard_Cell_Configuring_multiple_CC
#     [Tags]   AUTHOR_yin.4.chen@nokia-sbell.com
#     [Setup]   Case Setup: Cell_Configuring_multiple_CC
#     [Teardown]   Case Teardown: Cell_Configuring_multiple_CC
#     Commissioning_Wizard_Cell_Configuring_multiple_CC
# 
# [1]5GC001598_019_Commissioning_Wizard_RF_Addition_For_New_Cell
#     [Tags]   AUTHOR_yin.4.chen@nokia-sbell.com
#     [Setup]   Case Setup: RF_Addition_For_New_Cell
#     [Teardown]   Case Teardown: RF_Addition_For_New_Cell
#     Commissioning_Wizard_RF_Addition_For_New_Cell
