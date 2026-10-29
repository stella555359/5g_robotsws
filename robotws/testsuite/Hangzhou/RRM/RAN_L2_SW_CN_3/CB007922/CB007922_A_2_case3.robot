# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    CRT    SBTS00    RAN_5G_TDD    RAN_5G    SBTS22R2    SBTS22R4    SBTS23R1
# ...   CLOUD_5G_I_BLLL_AP_LOO
# ...    owner_pennwang    AP
# Resource    ../resources/KISS/robot/common_resource.robot
# Resource    ../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# # ${SCFC_NAME}      SCFC_7922_case3.xml
# # ${AIRPHONE_NAME}    IPHY_AEHC_4CELL.xml
# # ${WTS_NAME}       WTS_7922_4cell.cfg
# ${SCFC_NAME}      SCFC_7922_case3_AP_LOO.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_CASE07_AP_LO.xml
# ${WTS_NAME}       WTS_70851_CASE07_AP_LO.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${PCELL_THRESHOLD}    300000
# ${SCELL_THRESHOLD}    300000
# ${PCELL_THRESHOLD_NONCA}    500000
# ${UE_ID}    11
# @{Rdparameter}    0x340000:15
# 
# *** Test Cases ***
# CB007922_case03_A_2_interL2RT_Update_of_CA_association_NSA
#     Modify Swconfig for GNB
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
#     Attach ue and check throughput    ${UE_ID}    ${SCELL_THRESHOLD}    ${PCELL_THRESHOLD}
#     delete sCellAdditionMethod
#     Wait reach threshold   Check pm counter M55310C01009 in cell 1 is expected == 0
#     Wait reach threshold   Check pm counter M55310C01009 in cell 2 is expected == 0
#     Airphone NSA Detach All
#     Attach non ca ue and check throughput    ${UE_ID}    ${PCELL_THRESHOLD_NONCA}
#     update sCellAdditionMethod
#     Wait reach threshold   Check pm counter M55310C01009 in cell 1 is expected > 0
#     Wait reach threshold   Check pm counter M55310C01009 in cell 2 is expected == 0
#     Airphone NSA Detach All
#     Reattach ue and check throughput    ${UE_ID}    ${SCELL_THRESHOLD}    ${PCELL_THRESHOLD}
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# 
# 
# 
# *** Keywords ***
# Wait reach threshold
#     [Arguments]    ${check_point}
#     Wait Until Keyword Succeeds    200s    10s    ${check_point}
# 
# Reattach ue and check throughput
#     [Arguments]    ${ue_id}    ${s}    ${p}
#     Attach ue and check throughput    ${ue_id}    ${s}    ${p}
# 
# Attach ue and check throughput
#     [Arguments]    ${ue_id}    ${s}    ${p}
#     # NSA attach ue '${ue_id}' with 'TDD_NSA_AP_band41' cap and 'TDD_NSA_AP_band41_eutra' eutra cap to 5g cell
#     Airphone Setup X2 Connection
#     Airphone NSA Attach    ${ue_id}
#     NSA send ue '${ue_id}' mutiple trf '6' for each '175M' DL data
#     Wait reach threshold    Check NSA ue '${ue_id}' 'pcell' dl throught should '> ${p}'
#     Wait reach threshold    Check NSA ue '${ue_id}' 'scell' dl throught should '> ${s}'
# 
# Attach non ca ue and check throughput
#     [Arguments]    ${ue_id}    ${p}
#     # NSA attach ue '${ue_id}' with 'TDD_NSA_AP_band41' cap and 'TDD_NSA_AP_band41_eutra' eutra cap to 5g cell
#     Airphone NSA Attach    ${ue_id}
#     NSA send ue '${ue_id}' mutiple trf '6' for each '175M' DL data
#     Wait reach threshold    Check NSA ue '${ue_id}' 'pcell' dl throught should '> ${p}'
# 
# 
# ${operation} sCellAdditionMethod
#     Log To Console    Del sCellAdditionMethod...
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     TAF_ADMIN.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-2/NRCELL-1/NRREL-1    parameter=sCellAdditionMethod
#     ...    operation=${operation}    value=blind    skip_parameter_relation_errors=True    should_activate=True    connection=online
#     TAF_ADMIN.teardown admin    connection=online
#     Wait '30s' for stabible
# 
# Modify Swconfig for GNB
#     Add GNB swconfig    @{Rdparameter}
