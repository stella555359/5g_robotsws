# *** Settings ***
# Resource    ../../CB007873/Resources/CB007873_keywords.robot
# 
# Documentation    Suite description
# ...   author: Wang Yixiang
# ...   contact: yixiang.x.wang@nokia-sbell.com
# ...   squad group: MMW_SG1
# ...   Feature 5GC001390-D
# 
# Force Tags    5G_RRM
# ...    PY36
# Suite Setup     7873 Suite preparation
# Suite Teardown  run keyword and ignore error    CA Suite teardown
# 
# *** Test Cases ***
# 5GC001390_D_12_FA_B2_simplified_FlowControl_Buffer_based_Scell_Activation_Deactivation_for_FDD_with_Beamforming
#     [Tags]    CRT_21A    CIT_21B     CIT_TRUNK    CIT_22R1    CRT_22R1    CIT_22R3    CDRT_22R2    CIT_22R4
#     ...        CDRT_22R3
#     [Documentation]    Author: Wang Yixiang
#     ...    Description: This case is to verify buffer based scell action and deactivation for multi-times
#     ...    Step1: UE attach with CA
#     ...    Step2: Active scell by start traffic
#     ...    Step3: Deactivate scell by stop traffic
#     ...    Step4: Repeat step2 and step3 three times
#     [Setup]    Common case setup    NSA_SA=SA
#     Buffer_based_Scell_Activation_Deactivation    act_deact_times=${3}
#     [Teardown]    run keyword and ignore error    Common case teardown    detach_ue=${True}
