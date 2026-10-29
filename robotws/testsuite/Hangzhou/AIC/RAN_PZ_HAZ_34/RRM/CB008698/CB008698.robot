# *** Settings ***
# Force Tags    PY36
# Documentation
# ...    Author:
# ...    Contact:
# ...    squad
# ...    Feature
# 
# Suite Setup         Setup Suite for 8698
# Suite Teardown      Teardown Suite for 8698
# Resource          ../CB007199_ABG/Resource/CB007199_ABG_Resources.robot
# Resource          Resource/CB008698_Resources.robot
# *** Variables ***
# 
# 
# *** Test Cases ***
# [1]CB008698_A_2_Lower priority SA UE was released and higher priority UE admitted by cell level ue context preemption
#     [Documentation]
#     [Tags]    TA
#     [Setup]    Setup case for CB008698_A_2
#     [Teardown]  Teardown case
#     TC.CB008698_A_2_Lower priority SA UE was released and higher priority UE admitted by cell level ue context preemption
# 
# [1]CB008698_B_1_Higher priority SA Inter gNB HO UE admitted by cell level ue context preemption
#     [Documentation]
#     [Tags]    TA
#     [Setup]    Setup case for CB008698_B_1
#     [Teardown]  Teardown case
#     TC.CB008698_B_1_Higher priority SA Inter gNB HO UE admitted by cell level ue context preemption
# 
# [1]CB008698_C_1_Lower priority SA UE was released and higher priority UE admitted by cell level DRB preemption
#     [Documentation]
#     [Tags]    TA
#     [Setup]    Setup case for CB008698_C_1
#     [Teardown]  Teardown case
#     TC.CB008698_C_1_Lower priority SA UE was released and higher priority UE admitted by cell level DRB preemption
# 
# [1]CB008698_D_9_Intra gNB HO SA UE is admitted by cell level DRB preemption
#     [Documentation]
#     [Tags]    CRT_TRUNK    CRT_22R4    CRT_23R1    CRT_23R2
#     [Setup]    Setup case for CB008698_D_9
#     [Teardown]  Teardown case
#     TC.CB008698_D_9_Intra gNB HO SA UE is admitted by cell level DRB preemption