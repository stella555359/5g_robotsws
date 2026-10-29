# *** Settings ***
# Documentation    author: Lu Ming    Wang Sujuan
# ...               contact: ming.lu@nokia-sbell.com
# ...               squad group: SG_01
# ...               feature : 5GC002056-BHAH
# Suite Setup       Run Keywords    robot_common_operations.Common Suite Setup    AND    TestSuite.Init
# Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown    AND   TestSuite.Destroy
# Force Tags            
# ...    PY36
# Resource          ../5GC000742/Resources/5GC000742_Resources.robot
# 
# 
# *** Variables ***
# 
# ########################END of alias Define#######################################
# *** Test Cases ***
# [1][1.0] 5GC000742_C_023_Reconfiguration of SIBs (MCS9)
#     [Documentation]  Main test Steps:
#     ...   1) modify parameter for SIB2-SIB5 in SCF and commission and wait cell on air
#     ...   2) modify parameter for SIB2-SIB5 by WEBUI and active
#     ...   3) start Huawei UE to attach(should be success)
#     ...   3) check modified parameter in SIB2-SIB5 from UE logs
#     [Tags]    5GC000742_B    CRT_20A    CRT_TRUNK    CRT_22R1      CRT_21B    CRT_22R2    CRT_22R4
#     [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    KW.CaseInit
#     [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    KW.CaseDestroy
#     TC.5GC000742_C_023_Reconfiguration of SIBs (MCS9)
# 
# #[1][1.0] 5GC000742_B_005_Dynamic reconfiguration of SA cell in MIB and SIB1
# #    [Documentation]  Main test Steps:
# #    ...   1) modify cell to barred and wait cell on air
# #    ...   2) start Huawei UE to attach(should be fail)
# #    ...   3) Check MIB from UE log(should be barred)
# #    ...   4) modify cell to notBarred and wait cell on air
# #    ...   5) start Huawei UE to attach(should be success)
# #    ...   4) modify parameter for SIB1 and wait cell on air
# #    ...   5) start Huawei UE to attach and check modified parameter in SIB1
# #    [Tags]    5GC000742_B    CRT_22R1       CRT_21B
# #    [Setup]    KW.CaseInit
# #    [Teardown]  KW.CaseDestroy
# #    TC.5GC000742_B_005_Dynamic reconfiguration of SA cell in MIB and SIB1
# 
# *** Keywords ***
# TestSuite.Init
#      KW.TestSuiteInit
# TestSuite.Destroy
#     KW.TestSuiteDestroy
