# *** Settings ***
# Suite Setup          CBRS Suite Setup
# Suite Teardown       CBRS Suite Teardown
# Test Setup           CBRS Test Setup
# Test Teardown        CBRS Test Teardown
# 
# Resource    resources/CB007351_common_keywords.robot
# 
# Documentation
# ...    Author:wangqingqing
# ...    contact:qingqing.wang@nokia-sbell.com
# ...    squad group:SG_08
# ...    Feature CB007351
# 
# Force Tags    SBTS00    CRT_22R4    CRT_23R1
# ...    PY36
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]CB007351_Verify_Valid_certificates_are_taken_after_SW_fallback
#     [Tags]    CRT_TRUNK
#     CB007351_Verify_Valid_certificates_are_taken_after_SW_fallback
# 
# *** Keywords ***
