# *** Settings ***
# Force Tags    PY36
# Documentation
# ...    Author:
# ...    Contact:
# ...    squad
# ...    Feature
# 
# Suite Setup         Setup Suite for VRAN
# Suite Teardown      Teardown Suite for VRAN
# Resource          Resource/CB008610_A_Resources.robot
# 
# *** Variables ***
# 
# 
# *** Test Cases ***
# [1]CB007552_5G_5_CB007552-A#IWK2.1.1 - Successful intra-gNB HO with large BWP
#     [Documentation]
#     [Tags]    CRT_TRUNK    CRT_22R3    CRT_22R4    CRT_23R1     CRT_23R2
#     [Setup]    Setup case for VRAN
#     [Teardown]  Teardown case for VRAN
#     TC.CB007552_5G_5_CB007552_Successful intra-gNB HO with large BWP
# 
# [1]CB006898-E_22_CB006898-E-SyVe_22_NSA_Accessability_counters_ERAB_Ack_SgNB_Addition_Ack_or_SgNB_Modification_Ack
#     [Documentation]
#     [Tags]    TA
#     [Setup]    Setup case for VRAN
#     [Teardown]  Teardown case for VRAN
#     TC.CB006898-E_22_NSA_Accessability_counters_ERAB_Ack_SgNB_Addition_Ack_or_SgNB_Modification_Ack
# 
# 
# [1]CB006127_A_03_NSA_Partial_plan_activation_support
#     [Documentation]
#     [Tags]    CRT_TRUNK    CRT_22R3    CRT_23R1     CRT_23R2
#     [Setup]    Setup case for VRAN
#     [Teardown]  Teardown case for VRAN
#     TC.CB006127_A_NSA_enhancedANR_SIB1_cell_activation