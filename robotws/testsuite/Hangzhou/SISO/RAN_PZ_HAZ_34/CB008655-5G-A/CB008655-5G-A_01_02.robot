# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup
# Test Teardown        
# Test Timeout         60min
# 
# Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource      ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource      testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC000430_B_Master/Resource/5GC000430_B_Master_KW.robot
# Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
# 
# Documentation
# ...    Author:annie.hu
# ...    contact:annie.hu@nokia-sbell.com
# ...    squad group:SG_05
# ...    Feature Owner: Jin, Ming-Jim
# ...    Feature CB008655 in SBTS00 program
# 
# Force Tags            RAN_5G     RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY36    master_classicalbts_all
# 
# *** Variables ***
# ${if_pdl_check}       False
# 
# *** Test Cases ***
# # TL687
# 
# [1]CB008655-5G-A_01_02_Enabling_microDTXAdvanced_on_Megatron_cMAAr6.2_64T64R_Radio
#    [Tags]        1S-1CC-8D4U_A8_20M_C2-195_2089-41    CLOUD_5G_CLASSICAL_ASIBR_ABIOB4_AQQL_ENB   CIT_22R4
#    [Setup]   SISO Coam Test Setup
#        General_Feature_Micro-DTX_activate_microDtxEnabled_true
#        General_Feature_Micro-DTXAdvanced_activate_advancedMicroDtxEnabled_true
#    [Teardown]   SISO Coam Test Teardown
# 
# 
# *** Keywords ***
# General_Feature_Micro-DTXAdvanced_activate_advancedMicroDtxEnabled_true
#     [Documentation]
#     ...    *****************
#     ...    [TEST PURPOSE] The purpose of this test is to verify microDTXAdvanced activation
#     ...    ******************
#     ...    History of changes
#     ...    ******************
#     ...    - 05.08.2022 - - Created
#     ...    *******************
#     ...    Owner_annie.hu@nokia-sbell.com
#     log to console   \n*** set precondition: microDTXAdvanced deactivate ***
#     Selenium Login And Disable Screen Lock
#     Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
#     ...    filter_param=Activate micro discontinued transmission advanced    abbr=actMicroDTXAdvanced    new_value=true
#     Connect to gnb coam via ssl
#     ${ru_index_list}  Get All RU Index
#     :FOR  ${ru_index}  IN  @{ru_index_list}
#     \    Connect to Common Unit Master    alias=ASIK Master
#     \    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}
#     \    ${soap_path}    Download soap Log from RU    ru_alias=RU_${ru_index}
#     \    Check SOAP message for microDTXAdvanced status    soapLog_path=${soap_path}    advancedMicroDtxEnabled=${TRUE}
#     \    ${soap_file_path}    Run Keyword And Ignore Error    OperatingSystem.Copy File    ${soap_path}    ${SAVE LOG DIRECTORY}
#     \    csn.Disconnect    connection=ASIK Master
# 
# Check SOAP message for microDTXAdvanced status
#     [Arguments]   ${soapLog_path}    ${advancedMicroDtxEnabled}=${TRUE}
#     log to console  \n*** Check microDTXAdvanced status in SOAP message ***
#     soapp.check_soapmsg_parvaluechangeind    log_path=${soapLog_path}    class_value=TxArray
#     ...     parameterName=advancedMicroDtxEnabled    newValue=${advancedMicroDtxEnabled}
