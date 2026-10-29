# *** Settings ***
# Force Tags    PY36
# Documentation
# ...    Author:
# ...    Contact:
# ...    squad
# ...    Feature
# 
# Suite Setup         Setup Suite
# Suite Teardown      Teardown Suite
# Resource          Resource/CB009444_V_B3_Resources.robot
# *** Variables ***
# 
# 
# *** Test Cases ***
# [1]ST__Basics__RU_Stability_test_run
#     [Documentation]
#     [Tags]    CRT_TRUNK    CRT_23R3
#     [Setup]    Setup case
#     [Teardown]  Teardown case
#     TC.ST__Basics__RU_Stability_test_run    times=3   cells=${CASE_INPUT_CB009444['CB009444']['cell2']}
# 
# [1]ST__Basics__RF_lock_and_unlock_SA
#     [Documentation]
#     [Tags]    CRT_TRUNK    CRT_23R3
#     [Setup]    Setup case
#     [Teardown]  Teardown case
#     TC.ST__Basics__RF_lock_and_unlock_SA    rmods=${CASE_INPUT_CB009444['CB009444']['rmod_ids']}
#     ...    cells=${CASE_INPUT_CB009444['CB009444']['cell2']}
# 
# [1]ST__Basics__RF_reset_SA
#     [Documentation]
#     [Tags]    CRT_TRUNK    CRT_23R3
#     [Setup]    Setup case
#     [Teardown]  Teardown case
#     TC.ST__Basics__RF_reset_SA  rmods=${CASE_INPUT_CB009444['CB009444']['rmods']}
#     ...    cells=${CASE_INPUT_CB009444['CB009444']['cell2']}
