# *** Settings ***
# Suite Setup          CBRS Suite Setup    UTECloud=${True}
# Suite Teardown       CBRS Suite Teardown
# Test Setup           CBRS Test Setup
# Test Teardown        CBRS Test Teardown
# 
# 
# Resource    ../Resources/5GC001321_E_ET_common_keywords.robot
# 
# 
# Documentation
# ...    Author:wangqingqing
# ...    contact:qingqing.wang@nokia-sbell.com
# ...    squad group:SG_08
# ...    Feature 5GC001321
# 
# Force Tags    SBTS00    CRT_23R1
# ...   PY36    CRT_TRUNK    CRT_UTE    SBTS00    RAN_5G    RAN_5G_TDD    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AZQC    STATE_SW_UPLOADED
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]5GC001321-E-B2_1_Switchover_to_secondarySasServer_when_communication_failure_with_primarySasServer_which_as_current_servingSasServer
#     [Tags]    CRT_TRUNK
#     5GC001321-E-B2_1_Switchover_to_secondarySasServer_when_communication_failure_with_primarySasServer_which_as_current_servingSasServer
