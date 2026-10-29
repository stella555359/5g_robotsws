# *** Settings ***
# Resource           ./../Resources/7077_keywords.robot
# 
# Documentation    Suite description
# ...   author: Ren Biyao
# ...   contact: biyao.ren@nokia-sbell.com
# ...   squad group: MMW_SG1
# 
# Force Tags    5G_RAN_TDD
# ...    PY36
# Suite Setup     7077 Suite setup     is_need_to_require_ue=${False}    is_pdl_checking_needed=${True}
# Suite Teardown  Run keyword and ignore error    Suite teardown common
# 
# *** Test Cases ***
# [1]5GC002478_A_11_Cell_deactivation_when_last_X2_link_is_disabled_by_using_NRRELLTE
#     [Tags]    CIT_21A    CRT_21B     CRT_22R1   CRT_TRUNK     CRT_22R2    CRT_22R3    CRT_22R4    CRT_23R1
#     [Documentation]    Author: Ren Biyao
#     ...    This scenario addresses gNB behavior for the case wherein all associated NG and X2 links of a cell operating in mixed mode fail.
#     ...    covered by [1]CB007077_A_07
#     [Setup]    Common case setup    is_log_required=${True}
#     Lock or unlock x2 link on gnb side    parameters_to_update_via_api=${GNB_LOCK_VIA_API}
#     Lock or unlock AMF on gnb side    parameters_to_update_via_api=${AMF1_LOCK_VIA_API}
#     Lock or unlock AMF on gnb side    parameters_to_update_via_api=${AMF2_LOCK_VIA_API}
#     Connect to gnb coam via ssl
#     wait until keyword succeeds    10 min    5s      Cell Should Be Disabled
#     [Teardown]    run keywords
#     ...    Lock or unlock x2 link on gnb side    parameters_to_update_via_api=${GNB_UNLOCK_VIA_API}    AND
#     ...    Lock or unlock AMF on gnb side    parameters_to_update_via_api=${AMF1_UNLOCK_VIA_API}    AND
#     ...    Lock or unlock AMF on gnb side    parameters_to_update_via_api=${AMF2_UNLOCK_VIA_API}
