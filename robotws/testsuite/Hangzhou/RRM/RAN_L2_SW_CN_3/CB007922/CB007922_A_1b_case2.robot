# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    owner_yuqq    AP     SBTS22R4    CRT    SBTS00    RAN_5G_TDD    RAN_5G    SBTS23R1
# ...   CLOUD_5G_KLL_AP_SA_L1B_ECPRI_CMWV
# Resource    ../resources/KISS/robot/common_resource.robot
# Resource    ../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_7922_case2.xml
# ${AIRPHONE_NAME}    IPHY_AEHC_4CELL.xml
# ${WTS_NAME}       WTS_7922_4cell.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${PCELL_THRESHOLD}    300000
# ${SCELL_THRESHOLD}    300000
# ${PCELL_THRESHOLD_NONCA}    500000
# ${UE_ID}    1
# 
# *** Test Cases ***
# CB007922_case02_A_1b_intraL2RT_Feature_deactivation_mixBandWith_NSA    
#     Add GNB swconfig    0x340000:15
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
#     Attach ue and check throughput    ${UE_ID}    ${SCELL_THRESHOLD}    ${PCELL_THRESHOLD}
#     Wait reach threshold   Check pm counter M55310C01009 in cell 1 is expected > 0
#     Wait reach threshold   Check pm counter M55310C01009 in cell 2 is expected > 0
#     Online recommissioning with delta json file    ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/delta_A_1b_case2.json
#     Wait reach threshold   Check pm counter M55310C01009 in cell 1 is expected > 0
#     Wait reach threshold   Check pm counter M55310C01009 in cell 2 is expected > 0
#     Airphone NSA Detach All
#     Attach ue    ${UE_ID}    ${PCELL_THRESHOLD_NONCA}
#     Wait reach threshold   Check pm counter M55310C01009 in cell 1 is expected > 0
#     Wait reach threshold   Check pm counter M55310C01009 in cell 2 is expected == 0
#     Airphone NSA Detach All
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# 
# *** Keywords ***
# Wait reach threshold
#     [Arguments]    ${check_point}
#     Wait Until Keyword Succeeds    200s    10s    ${check_point}
# 
# Attach ue and check throughput
#     [Arguments]    ${ue_id}    ${s}    ${p}
#     NSA attach ue '${ue_id}' with 'TDD_NSA_AP_band41' cap and 'TDD_NSA_AP_band41_eutra' eutra cap to 5g cell
#     NSA send ue '${ue_id}' mutiple trf '6' for each '175M' DL data
#     Wait reach threshold    Check NSA ue '${ue_id}' 'pcell' dl throught should '> ${p}'
#     Wait reach threshold    Check NSA ue '${ue_id}' 'scell' dl throught should '> ${s}'
# 
# Attach ue
#     [Arguments]    ${ue_id}     ${p}
#     NSA attach ue '${ue_id}' with 'TDD_NSA_AP_band41' cap and 'TDD_NSA_AP_band41_eutra' eutra cap to 5g cell
#     NSA send ue '${ue_id}' mutiple trf '6' for each '175M' DL data
#     Wait reach threshold    Check NSA ue '${ue_id}' 'pcell' dl throught should '> ${p}'
# 
# 
