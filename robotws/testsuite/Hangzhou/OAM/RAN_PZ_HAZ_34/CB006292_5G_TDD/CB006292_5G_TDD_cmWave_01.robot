# *** Settings ***
# Force Tags    PY36
# Documentation
# ...   author: annie.hu@nokia-sbell.com
# ...   contact: annie.hu@nokia-sbell.com
# ...   Description: To verify gNB basic operations on NOM
# 
# 
# Suite Setup     SISO Coam Suite Setup
# Suite Teardown    SISO Coam Suite Teardown
# 
# Test Timeout    60 minutes
# 
# Resource         ./Resource/CB006292_common_keywords.robot
# #Library          ./Resources/CB006292_common_vars.py
# Library          String
# Library           Collections
# Library          taf.selenium.nms.nom                  WITH NAME    nom_selenium
# #Library          taf.nms.nom              WITH NAME    nom
# Library          taf.sbts.oam.coam.admin       WITH NAME    coam
# Library          OperatingSystem
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# #Resource          ../common/coam_resource.robot
# 
# *** Variables ***
# #${NOM_7_WEBUI_LINK}      https://neo-hosting-page.srncnms08.srnblr.nsn-rdnet.net/
# #${NOM_7_connect_LINK}     https://user-mgmt.srncnms08.srnblr.nsn-rdnet.net
# ##${NOM_7_WEBUI_LINK}     https://neo-hosting-page.srncnms07.srnblr.nsn-rdnet.net/
# ##${NOM_7_connect_LINK}      https://user-mgmt.srncnms07.srnblr.nsn-rdnet.net
# #${USER_NAME_NOM7}       cnms01
# #${PASSWORD_NOM7}      Qwer_1234
# #${NOM_version}      nom_v1
# 
# ${TS_LOG_PATH_BASE}        /home/ute/workspace/CIT
# #${scf_template_path}        /opt/ute/scf/SCF_SG5_TL${tl.gnbs[0].instance_id}_4T2R.xml
# #${scf_file_path}           /opt/ute/scf/Configuration_scf_TL59.xml
# #${SCF_DEFAULT_FILE_PATH}          /opt/ute/scf/SCF_SG5_TL${tl.gnbs[0].instance_id}_4T2R.xml
# #${REINTEGRATE_FLAG}     ${False}
# 
# 
# *** Test Cases ***
# [1]CB006292_5G_TDD_cmWave_01_General_SiSo_Commissioning_BTS_Template_Commissioning
#     [Tags]  CRT_22R2   CRT_trunk
#     [Setup]   Test Case Setup
#     Step1: Import Commission plan via NOM
#     Step2: Activation Commission plan via NOM
#     Step3: Check Commission with scf file via nom
#    [Teardown]   Test Case Teardown
# 
# 
# 
# *** Keywords ***
# Test Case Setup
#     Check gNB Should Be Normal
#     Set Suite Variable   ${BTS_ID}  ${tl.gnbs[0].instance_id}
#     Set Suite Variable   ${MO_NAME}   MRBTS-${BTS_ID}
#     Set Suite Variable   ${DN}   PLMN-PLMN/${MO_NAME}
#     Set Suite Variable   ${NOM_NAME}   ${SET_NOM_NAME}
#     Get ALL Suite Variables
#     #${status}   Run Keyword And Return Status   NOM Login
#     ${status}   Run Keyword And Return Status   NOM Login
#     Run Keyword Unless   ${status}   Run Keywords
#     ...   Run Keyword And Ignore Error   NOM Logout   AND
#     ...   NOM Login
#     Run Keyword If   ${REINTEGRATE_FLAG}   ReIntegrate GNB To NOM
#     Log ALL Suite Variables
#     #NOM Logout    client_id=${client_id}
#    
# Step1: Import Commission plan via NOM
#     log to console   Step1: Import Commission plan via NOM
#     COAM Create log directory
#     ${scf_file_name}    Fetch from right    ${scf_path}    /
#     #${scf_dir_path}    String.Replace string    ${scf_file_path}    /${scf_file_name}    ${EMPTY}
#     ${file_name_without_extention}    String.Replace string    ${scf_file_name}    .xml    ${EMPTY}
#     #${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
#     #${unique_plan_file_name}    catenate  SEPARATOR=${EMPTY}    ${file_name_without_extention}    _${timestamp}_updated.xml
#     #${PLAN_PATH}   Copy file    source=${scf_file_path}    destination=${TS_CASE_LOG_PATH}/${unique_plan_file_name}
# 
#     set test variable  ${PLAN_NAME}    ${file_name_without_extention}
#     set test variable  ${PLAN_PATH}    ${scf_path}
# 
#     NOM Import Plan   path_to_plan=${PLAN_PATH}     name=${PLAN_NAME}
#     sleep    10
# 
# 
# Step2: Activation Commission plan via NOM
#     #[Arguments]   ${plan_name}=${PLAN_NAME}
#     log to console  Step2: Activation Commission plan via NOM
#     #NOM Login
#     ${status}   Run Keyword And Return Status   NOM Login
#     Run Keyword Unless   ${status}   Run Keywords
#     ...   Run Keyword And Ignore Error   NOM Logout   AND
#     ...   NOM Login
#     #Operate Plan From NOM  ${PLAN_NAME}_${import_plantime[1]}  true  true  true
#     ${operation_deintegrate_id}   nom.provision_plan     plan_name=${PLAN_NAME}     timeout=300
#    [Teardown]  Run Keyword And Ignore Error   NOM Logout
# 
# 
# Check gNB Should Be Normal
#     Log To Console  Check gNB Should Be Normal
#     Run Keyword And Ignore Error    WEBUI Logout
#     WEBUI Login
#     run keyword and ignore error    selenium_coam.close_start_up_view_window
#     run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
#     run keyword and ignore error    selenium_coam.disable_message_box
#     run keyword and ignore error    selenium_coam.refresh_page
#     Wait Until Keyword Succeeds    15min    1min    check gNB Staus onAir
#     ...  dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}    search_text=Operational state
#     sleep    5s
#     Run Keyword And Ignore Error    WEBUI Logout
# 
# 
# Step3: Check Commission with scf file via nom
#     log to console  Step3: To check Commission with scf file via nom successfully
#     Wait Until Keyword Succeeds  10 min  1s  Check if gNB is not pingable
#     #Wait Until Keyword Succeeds  4 min  2s  Check if gNB is pingable With ASIL
#     Wait Until Keyword Succeeds  15 min  1s  Check if gNB is pingable
#     #WebUI Login
#     sleep  300s
#    Check gNB Should Be Normal
#    #[Teardown]  WebUI Logout
# 
# 
# 
# Check gNB and Cell onAir
#     Run Keyword And Ignore Error    WEBUI Logout
#     WEBUI Login
#     #Wait Until Keyword Succeeds    15min    1min    check RU STATUS
#     Wait Until Keyword Succeeds    15min    1min    Check Cell is UP
#     Wait Until Keyword Succeeds    15min    1min
#     ...    check gNB Staus onAir    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}    search_text=Operational state
#     WEBUI Logout
# 
# 
# 
# Gnb Cell Should Be Onair
#     [Arguments]  ${alias}=default  ${cell_type }=nr
#     [Documentation]  Gnb Cell Should Be Onair, check method is via REST
#     ${status}      coam.Get_Bts_Statuses   connection=${alias}
#     ${operationalState}    Get From Dictionary    ${status}    operationalState
#     Should Be Equal    ${operationalState}    Enabled
#     ${blockingState}   Get From Dictionary    ${status}    blockingState
#     Should Be Equal    ${blockingState}    Unblocked
#     ${proceduralState}   Get From Dictionary    ${status}   proceduralState
#     Should Be Equal    ${proceduralState}    OnAir
#     ${cell_status}     coam.Get_Cells_Info   cell_type=${cell_type}
#     ${Status}    Get From Dictionary    ${cell_status[0]}    status
#     ${tmp}   Get From Dictionary    ${status}    operationalState
#     Should Be Equal    ${tmp}    Enabled
#     ${tmp}   Get From Dictionary    ${status}   availabilityStatus
#     Should Be Equal    ${tmp}    Online
#     ${tmp}   Get From Dictionary    ${status}  administrativeState
#     Should Be Equal    ${tmp}    Unlocked
#     ${tmp}   Get From Dictionary    ${status}  blockingState
#     Should Be Equal    ${tmp}    Unblocked
#     ${tmp}   Get From Dictionary    ${status}  usageState
#     Should Be Equal    ${tmp}    Active
# 
# Check if gNB is not pingable	
#     ${output}   Run       ping -c 1 -W 10 192.168.255.129
#     Should contain      ${output}   1 packets transmitted, 0 received
# 	
# Check if gNB is pingable
#     ${output}   Run       ping -c 1 -W 10 192.168.255.129
#     Should contain      ${output}   1 packets transmitted, 1 received
# 
# Test Case Teardown
#     #${client_id}=  get unique id
#     Run Keyword And Ignore Error    NOM Logout
#     selenium logout and close browser
#     #CI_interface.Common Case Teardown
