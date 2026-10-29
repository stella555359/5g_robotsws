# *** Settings ***
# Documentation                          Suite description
# Force Tags                             5G_RAN    5G_RAN_TDD    CRT_TRUNK    CRT_22R4   CRT_22R2
# ...    PY36
# 
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Suite Setup    Run Keywords    CI_interface.Common Suite Setup
# ...    AND   Generic Suite Setup    SCF=${SCF}    SWconfig=${SWconfig}    NumberOfCells=${NumberOfCells}
# ...     AND     Generic Suite Setup For one call during Activating DRX
# ...    CAMPAIGN_NAME=${CAMPAIGN_NAME}    CELL_NUMBER=${CELL_NUMBER}    AND
# ...    Check Cell Availability Status is online after commissioning    ${CELL_NUMBER}
# ...    AND     robot_common_operations.Common Suite Setup
# Suite Teardown   Run Keywords     QCT Generic Suite Teardown
# ...   AND   robot_common_operations.Common Suite Teardown
# Test Setup       robot_common_operations.Common Case Setup
# Test Teardown    Run Keywords     robot_common_operations.Common Case Teardown
# ...  AND   5GC000772_Keywords.Test Teardown    ${result}
# 
# 
# 
# Variables    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/libraries/Cockpit/Cockpit_Config.py
# Resource     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000772/resources/keywords_cOAM.robot
# Resource     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000772/resources/5GC000772_Variables.robot
# Resource     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000772/resources/5GC000772_Keywords.robot
# Library      ../5GC000772/resources/5GC000772_Resources.py        WITH NAME       mylib772
# Library                                taf.transport.ssh                                 WITH NAME       ssh
# Library                                BuiltIn
# Library                                String
# Library                                ute_reporting_portal
# Library                                OperatingSystem
# Library                                DateTime
# Library                                XML
# Library                                ute_ue
# 
# 
# *** Variables ***
# 
# ${CAMPAIGN_NAME}=                      5GC000772_A_05_09_12
# ${SCF}=                                CV_NSA_1Cell_dBF_Off_For_5GC000772_CRT.xml
# ${SWconfig}=                           swconfig_For_5GC000772_CRT.txt
# ${NumberOfCells}=                      1
# # List of State Machine To Be Executed:
# @{SM_TO_BE_RUN}=                       feature1877_772_C_NSA_X2_CallEstablishmentAndRelease.sm
# ...                                    feature1877_772_C_NSA_X2_CallEstablishmentAndReleaseFrom5g.sm
# ...                                    feature1877_772_C_NSA_X2_CallEstablishmentAndReleaseFrom5gsbts.sm
# @{SM_TO_BE_RUN_20A}=                   feature1877_772_C_NSA_F1_CallEstablishmentAndRelease.sm
# ${ue_type}                  samsung
# 
# *** Test Cases ***
# 
# [1]CB007608_A_5GC000772_01_classical_mmw_NSA_CallSetup_MSC_X2_UeSupportsDRX_SRB1
#     Log to console    checkFeature_772_NSA_Call for case2
#     ${result}=                         mylib772.checkFeature_772_NSA_Call    ${5GLoadVersion}    2    ${hw_type}
# 
# 
# [1]CB007608_A_5GC000772_03_classical_mmw_NSA_CallSetup_counters_UeSupportsDRX_SRB1
#     Log to console    checkFeature_772_NSA_Counters for case5 
#     ${result}=                         mylib772.checkFeature_772_NSA_Counters    ${checkDrxRatio}    5
# 
# 
# 
# [1]CB007608_A_5GC000772_05_classical_mmw_NSA_CallRelease_UeSupportsDRX_SRB1
#     ${result}=    case12_NSACallRelease_UeSupportsDRX
# 
# 
# 
# 
