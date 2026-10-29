# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
# Test Timeout         100 min
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
# 
# Documentation
# ...    Author: Annie hu
# ...    Contact: Annie.hu@nokia-sbell.com
# ...    squad group:SG_05
# ...    Feature 5GC002519-MA in 5G21A program
# 
# Force Tags     RAN_5G   RAN_5G_TDD   CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQE   STATE_SW_UPLOADED    SBTS00
# ...    PY36
# 
# *** Variables ***
# #&{MERSURE_INTERVAL_ORIGIN}    dist_name=NRBTS-${btsId}/NRPMRNL-1    parameter=miNrEcpriUpFCp    value=disabled
# #&{MERSURE_INTERVAL_MODIFY}    dist_name=NRBTS-${btsId}/NRPMRNL-1    parameter=miNrEcpriUpFCp    value=5min
# 
# #@{2519_MA_01_para_origin}    &{MERSURE_INTERVAL_ORIGIN}
# #@{2519_MA_01_para_modify}    &{MERSURE_INTERVAL_MODIFY}
# 
# ${miNrEcpriUpFCp}         5min
# 
# *** Test Cases ***
# [1][1.0] 5GC002519_MA_01_eCPRI_U-plane_and_Fast-C-Plane_message_reception_NIDD_PM_counters_M55318C00001_by_RAU
#     [Tags]    master_classicalbts_all   CRT_UTE    CRT_TRUNK   CRT_22R1   CRT_22R2   CRT_22R3   CRT_22R4
#     #[Setup]  SISO Coam Test Setup
#     #[Arguments]  ${miNrEcpriUpFCp}=5min
#      Modify miNrEcpriUpFCp Parameters via API   miNrEcpriUpFCp=${miNrEcpriUpFCp}
#      sleep  ${miNrEcpriUpFCp}
#      selenium login and disable screen lock
#      Wait Until Keyword Succeeds    3x    5min    Check M55318C00001 Counter    change_interval=${miNrEcpriUpFCp}
# 
#     [Teardown]  run keywords  selenium logout and close browser    AND
#     ...    Modify miNrEcpriUpFCp Parameters via API  miNrEcpriUpFCp=disabled
# 
# 
# *** Keywords ***
# Check M55318C00001 Counter
#     [Arguments]    ${change_interval}
#     connect to common unit master
#     #sleep  5min
#     ${M55318C00001_value}    Get PM Counter via Webem    counter_id=M55318C00001    interval=${change_interval}
#     ${M55318C00001_value}    convert to integer     ${M55318C00001_value}
#     Should Be True    ${M55318C00001_value} >0
#     [Teardown]  csn.Disconnect  connection=ASIK Master
