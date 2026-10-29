# *** Settings ***
# Suite Setup          Run Keywords    CBRS Suite Setup
# #...                  AND     Case Preparation
# Suite Teardown       CBRS Suite Teardown
# Test Setup           CBRS Test Setup
# Test Teardown        CBRS Test Teardown
# 
# Resource    resources/CB008923_common_keywords.robot
# 
# Documentation
# ...    Author: Gao, Melinda
# ...    contact: melinda.gao@nokia-sbell.com
# ...    squad group:SG_08
# ...    Feature CB008923-D
# 
# Force Tags    SBTS00    CRT_23R1
# ...    PY36
# 
# *** Variables ***
# 
# *** Test Cases ***
# 
# [1]CB008923_grant_successful_with_truncated
#     [Tags]    CRT_TRUNK    CRT_22R4
#     CB008923_grant_successful_with_truncated
# 
# *** Keywords ***
