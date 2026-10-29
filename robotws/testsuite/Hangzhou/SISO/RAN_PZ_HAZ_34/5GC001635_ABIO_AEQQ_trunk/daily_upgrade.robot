# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# 
# Documentation
# ...    Author: jiangjing.lin
# ...    Contact: jiangjing.lin@nokia-sbell.com
# ...    squad group:SG_08
# ...    Feature CB005770
# 
# Force Tags            RAN_5G_TDD    5G_RAN_TDD    SBTS00    RAN_5G    5G_RAN    CRT_UTE	   STATE_SW_UPLOADED
# ...   PY36
# ...    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQN_5GC002374
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]software upgrade
#    [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
#    log to console    this is for software upgrade
