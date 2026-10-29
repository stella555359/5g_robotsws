# # # # # *** Settings ***
# # # # # Documentation
# # # # # ...    author: y63li
# # # # # ...    contact: ying.15.li@nokia-sbell.com
# # # # # ...    squad group: 5G_PZ_MMW_HZ_3_SG
# # # # # ...    feature : 5GC001349-AA
# # # # # 
# # # # # Force Tags        RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ASIKR_ABILB1_AZQG_ENB   SBTS00   CRT_UTE
# # # # # ...    PY36
# # # # # ...      SBTS21B    SBTS22R1    SBTS22R2
# # # # # 
# # # # # Suite Setup       5GC001349_Common Suite Setup for COAM
# # # # # Suite Teardown    5GC001349_Common Suite Teardown for COAM
# # # # # Test Timeout      180 minutes
# # # # # 
# # # # # Library     OperatingSystem
# # # # # Library     XML   use_lxml=True    WITH NAME    myxml
# # # # # Library     taf.config.scf    WITH NAME    scf
# # # # # Resource    Resources/5GC001349_Common_Keyword_cOAM.robot
# # # # # Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# # # # # 
# # # # # *** Variables ***
# # # # # 
# # # # # *** Test Cases ***
# # # # # [1] 5GC001349_B_1001_Enable_and_Disable_of_PRACH_format0_1116_0ms_PrachConfig_9_14
# # # # #     [Documentation]    This test case is used to test GNB’s supporting of the enable and disable of PRACH format 0 per cell
# # # # #     [Setup]    #Case Setup for 1116-0
# # # # #     PRACH_format0_1116_0ms_PrachConfig_9_14
# # # # #     [Teardown]    Case Teardown
# # # # # 
# # # # # *** Test Cases ***
# # # # # [1] 5GC001349_B_1003_Enable_PRACH_format0_1116_0ms_PrachConfig_9_14_PMCounter_M55306C00001-M55306C00008_M55306C03001_M55306C06001
# # # # #     [Documentation]   This test case is used to PRACH PM counters are increased correctly.
# # # # #     [Setup]
# # # # #     PRACH_format0_1116_0ms_PrachConfig_9_14_PMCounter
# # # # #     [Teardown]    Case Teardown
# # # # # 
# # # # # *** Test Cases ***
# # # # # [1] 5GC001349_B_1005_Enable_and_Disable_of_PRACH_format0_1116_3ms_PrachConfig_3_4_5_6_7_12
# # # # #     [Documentation]    This test case is used to test GNB’s supporting of the enable and disable of PRACH format 0 per cell
# # # # #     [Setup]    Case Setup for 1116-3
# # # # #     PRACH_format0_1116_3ms_PrachConfig_3_4_5_6_7_12
# # # # #     [Teardown]    Case Teardown
# # # # # 
# # # # # *** Test Cases ***
# # # # # [1] 5GC001349_B_1014_Enable_and_Disable_of_PRACH_format0_1070_PrachConfig_0_One_SSB
# # # # #     [Documentation]    This test case is used to test GNB’s supporting of the enable and disable of PRACH format 0 per cell
# # # # #     [Setup]    Case Setup for 1070
# # # # #     PRACH_format0_1070_PrachConfig_0
# # # # #     [Teardown]    Case Teardown
# # # # # 
# # # # # *** Keywords ***
