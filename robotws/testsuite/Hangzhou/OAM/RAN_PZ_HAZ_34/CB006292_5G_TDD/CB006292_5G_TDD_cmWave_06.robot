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
# Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource     ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# #Resource          ../common/coam_resource.robot
# Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
# Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
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
# 
# 
# ${alarm_filter}     7111
# 
# 
# *** Test Cases ***
# [1]CB006292_5G_TDD_cmWave_06_General_SiSo_RF_alarms_with_recovery
#     [Tags]  CRT_22R2   CRT_trunk
#     [Setup]   Test Case Setup
#     Modify Calibration File On RU Unit    current_name=calibration_dlpath1    new_name=calibration_dlpath1_bk    ru_index=${1}
#     Wait until keyword succeeds    20min    30s    RU Status Should Be Failed    ru_index=${1}
#     log to console    \n Check Alarm Exist in WebEM
#     #Wait until keyword succeeds    10min    30s    Check Alarm Exist in RawAlarmHistory    alarm_filter=1901
#     Wait For Expect Fault Present    faultId=1901     timeout=1200
#     sleep    20S
#     wait until keyword succeeds    5min    10s   Nom get active alarms and Check alarm 1901
#     #should be equal as strings    ${fault_id_nom}    ${1901}
#     Recovery alarm
#     #${return_fault}   Nom get the active alarm and Check fault 1901  DN_NAME=${DN_NAME}
#     #${fault_id_list}      Login Du and Get Alarm Info     timeout=1
#     #Lists Should be equal    ${fault_id_list}    ${return_fault}
#    [Teardown]  Modify Calibration File On RU Unit    current_name=calibration_dlpath1_bk    new_name=calibration_dlpath1    ru_index=${1}
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
#     #${status}   Run Keyword And Return Status   NOM Login
#     #Run Keyword Unless   ${status}   Run Keywords
#     #...   Run Keyword And Ignore Error   NOM Logout   AND
#     #...   NOM Login
#     Run Keyword If   ${REINTEGRATE_FLAG}   ReIntegrate GNB To NOM
#     Log ALL Suite Variables
#     #NOM Logout    client_id=${client_id}
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
# 
# Test Case Teardown
#     #${client_id}=  get unique id
#     Run Keyword And Ignore Error    NOM Logout
#     selenium logout and close browser
#     #CI_interface.Common Case Teardown
# 
# Check alarm upload by NOM
#     log to console    \n Check Alarm Exist on NOM
#     ${return_fault_nom}    upload alarm via connect_to_nom and check Fault     DN_NAME=${DN_NAME}
# 
# Nom get active alarms and Check alarm 1901
#     #[Arguments]   ${DN_NAME}
#     #${client_id}     Connect to NOM
#     ${status}   Run Keyword And Return Status   NOM Login
#     Run Keyword Unless   ${status}   Run Keywords
#     ...   Run Keyword And Ignore Error   NOM Logout   AND
#     ...   NOM Login
#     #${DN_NAME}     Create List    ${DN_NAME}
#     #${status}      Run Keyword And Ignore Error   nom.upload_alarms    ${DN_NAME}     timeout=60
#     #${alarms_info}   nom.get_alarms_from_integrated_ne  integrated_id=${DN_NAME[0]}    only_active=${True}
#     #sleep  10s
#     ${alarm_list}=  NOM Get Active Alarms Via Rest    MRBTS-${MRBTS_ID}
#     #${alarms_info}=  nom.get_alarms_from_integrated_ne  integrated_id=${integrated_id}    only_active=${True}
#     log to console    ${alarm_list}
#     #${alarms_info["alarms"]}    remove duplicates   ${alarms_info["alarms"]}
#     #sort list  ${return_fault_nom}
#     should not be empty     ${alarm_list}
#     FOR   ${alarm}   IN  @{alarm_list}
#         ${alarm_id}   set variable   ${alarm['specific_problem']}
#         log to console    ${alarm_id}
#         #Should Contain  ${alarm_id}   ${alarm_filter}
#         Exit For Loop IF    '${alarm_id}'=='${alarm_filter}'
#     END
# 
#    [Teardown]   Run Keyword And Ignore Error   NOM Logout
#    #[Return]  ${alarms_info["alarms"]}
# 
# NOM Get Active Alarms Via Rest
#    [Arguments]    ${integrated_id}
#    ${status}   Run Keyword And Return Status   NOM Login
#    Run Keyword Unless   ${status}    Run Keywords
#     ...    Run Keyword And Ignore Error   NOM Logout   AND
#     ...   NOM Login
#     ${alarms_info}=  nom.get_alarms_from_integrated_ne  integrated_id=${integrated_id}    only_active=${True}
# 
#     [Return]   ${alarms_info["alarms"]}
# 
# 
# Recovery alarm
#     #Wait Until Keyword Succeeds    20min    30s    COAM Wait for gnb ready and cell setup
# 
#     Wait until keyword succeeds    20min    120s    Modify Calibration File On RU Unit    current_name=calibration_dlpath1_bk
#     ...    new_name=calibration_dlpath1    ru_index=${1}
#     log to console    \n Check Fault 1901 Absent on WebUI
#     Wait until keyword succeeds    10min    30s    Expect Fault Should Absent    faultId=1901
#     log to console    \n Check GNB cell on air
#     coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'
