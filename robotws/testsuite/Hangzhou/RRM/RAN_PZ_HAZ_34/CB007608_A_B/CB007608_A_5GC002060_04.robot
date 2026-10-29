# *** Settings ***
# Documentation                          Suite description
# 
# Force Tags                             CRT_TRUNK     CRT_22R4    CRT_22R2
# ...    PY36
# 
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Suite Setup    Run Keywords    CI_interface.Common Suite Setup
# ...    AND     Generic Suite Setup
# ...    AND     robot_common_operations.Common Suite Setup
# 
# 
# Suite Teardown   Run Keywords      robot_common_operations.Common Suite Teardown
# ...  AND       QCT Generic Suite Teardown
# Test Setup       robot_common_operations.Common Case Setup
# Test Teardown    robot_common_operations.Common Case Teardown
# 
# 
# 
# 
# 
# #Variables                              ${CURDIR}/../../../../resources/sites/NPS/PROD/python/custom.py
# #Variables                              /home/ute/Projects/robotws5g/resources/sites/NPS/PROD/python/custom.py
# #Variables                              %{ABSTRACT_LIB_CONFIG}
# 
# 
# 
# #Variables    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000772/resources/Cockpit/Cockpit_Config.py
# Resource     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000772/resources/keywords_cOAM.robot
# Resource     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000772/resources/5GC000772_Variables.robot
# Resource     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000772/resources/5GC000772_Keywords.robot
# Library      ../5GC000772/resources/5GC000772_Resources.py        WITH NAME       mylib772
# 
# Library                                taf.transport.ssh                                 WITH NAME       ssh
# Library                                BuiltIn
# Library                                String
# Library                                ute_reporting_portal
# Library                                OperatingSystem
# Library                                DateTime
# Library                                XML
# Library                                ute_ue
# Resource           testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000772/resources/5GC000772_MCshark.robot
# 
# *** Variables ***
# 
# ${CAMPAIGN_NAME}=                      5GC000772_A_05_09_12
# 
# # List of State Machine To Be Executed:
# #@{SM_TO_BE_RUN}=                       feature1877_772_C_NSA_X2_CallEstablishmentAndRelease.sm
# #@{SM_TO_BE_RUN_20A}=                   feature1877_772_C_NSA_F1_CallEstablishmentAndRelease.sm
# 
# 
# *** Test Cases ***
# [1]CB007608_A_5GC002060_04_NSA_mmw_TDD_StaticCall_LTE_SRB1_DLC160_MidULDLThroughput
# 
#     Log                                Test Result is : ${checkDrx160ms}
#     #Run Keyword Unless                 '${result}'=='SKIP'    Set Tags    CRT
#     should be equal as strings      '${checkDrx160ms}'    '0'
# 
# 
# 
# *** Keywords ***
# 
# Generic Suite Setup
#     Set Library Search Order    5GC000772_MCshark    ru_log
#     gNB Get CellId and BTSId DN in SCF
#     Campaign Test Setup                ${CAMPAIGN_NAME}    ${False}       ${False}
#     Set Default DRX Settings From SCF  ${CELL_NUMBER}
#     Display New Default DRX Settings
#     Activate LONG DRX                       ${CELL_NUMBER}
#     Run Keyword and Ignore Error       Activate DRX        ${CELL_FOR_HO}
#     Deactivate SRB3
#     power_ue.Prepare UE    ue_type=samsung
#     Wait For Next Counter Files
# 
#     QCT Launch Test With Traffic and Analysis       ${QCT_UE_ID_1}      ${CAMPAIGN_NAME}
# 
# 
#     Wait For Next Counter Files
#     Get and Check Counters Files II
#     #QCT Launch The Use Case Detector
#     Check 772 X2AP Msg
#     ...  bip_file=${log_path_tcpdumpngx2ap}
#     ...  csv_file2=${log_path_tcpdumpngx2ap_pre}/SgNBAdditionRequest.csv
#     ...  csv_file3=${log_path_tcpdumpngx2ap_pre}/SgNBReconfigurationCompleteRRCReconfigurationComplete.csv
#     ...  csv_file4=${log_path_tcpdumpngx2ap_pre}/SgNBReleaseRequest.csv
#     ...  csv_file5=${log_path_tcpdumpngx2ap_pre}/SgNBModificationConfirmRRCReconfigurationComplete.csv
#     ...  csv_file6=${log_path_tcpdumpngx2ap_pre}/SgNBModificationRequiredRRCReconfiguration.csv
#     ...  csv_file7=${log_path_tcpdumpngx2ap_pre}/SNStatusTransfer.csv
#     ...  csv_file8=${log_path_tcpdumpngx2ap_pre}/SgNBAdditionRequestAcknowledgeRRCReconfiguration.csv
#     ...  csv_file9=${log_path_tcpdumpngx2ap_pre}/SgNBReleaseRequestAcknowledge.csv
#     ...  csv_file10=${log_path_tcpdumpngx2ap_pre}/UEContextRelease.csv
# 
#     Check 772 F1AP Msg NSA
#     ...  bip_file=${log_path_tcpdumpngx2ap}
#     ...  csv_file1=${log_path_tcpdumpngx2ap_pre}/UEContextSetupResponse.csv
#     ...  csv_file2=${log_path_tcpdumpngx2ap_pre}/UEContextModificationResponse.csv
#     ...  csv_file3=${log_path_tcpdumpngx2ap_pre}/UEContextReleaseComplete_f1ap.csv
