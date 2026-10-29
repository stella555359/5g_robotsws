# *** Settings ***
# Suite Setup          Run Keywords    CBRS Suite Setup  AND  Case Preparation for CB007857 ET
# Suite Teardown       CBRS Suite Teardown
# Test Setup           CBRS Test Setup
# Test Teardown        CBRS Test Teardown
# 
# Resource    ./Resources/CB007857-ET_common_keywords.robot
# Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CBRS/resources/cbrs_common_keywords.robot
# 
# Documentation
# ...    Author:Gao, melinda
# ...    contact:melinda.gao@nokia-sbell.com
# ...    squad group:SG_08
# ...    Feature CB007857 ET CBRS
# 
# Force Tags    SBTS00    CRT_TRUNK    CRT_23R1    CRT_23R2
# ...   PY36
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]CB007857-A_06_pmax_exceed_fcc_limitation
#     CB007857-A_06_pmax_exceed_fcc_limitation
# 
# [1]CB007857-A_23_desiredchbw_increased_supportedspectrumv2_widen
#     CB007857-A_23_desiredchbw_increased_supportedspectrumv2_widen
# 
# [1]CB007857-B_29_desiredpmax_decreased
#     CB007857-B_29_desiredpmax_decreased
# *** Keywords ***
