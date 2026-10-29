# *** Settings ***
# Resource   Resource${/}NetAct.robot
# Resource   Resource${/}common_license.robot
# Suite Setup   Run Keywords   COAM commissioning if not onair
# ...   AND    common_license.Common Setup
# ...   AND    COAM Check Units Status Normal   fbb-1   fsm-1
# Suite Teardown   common_license.Common Teardown   restore=${true}
# Force Tags    SG_08    CA_5G_OAM            CIT
# ...    PY36
#
# *** Variables ***
# ${NRcelltype}=    NR Cell type
# ${typevalue}=    nrCellType
# ${output power_ban}=   Maximum output power
# ${power_value}=    26
# ${power_value2}=    35
# ${WEB_DOWNLOAD_DIR}   ${OUTPUT_DIR}
#
# *** Test Cases ***
# [1]5GC000257_License_computation_cmwave RF_TRP reduce for classical BTS
#     [Documentation]
#     ...    *****************
#     ...    Basic information
#     ...    *****************
#     ...    Description in reStructuredText format on what is tested
#     ...    ******************
#     ...    History of changes
#     ...    *******************
#     ...    Test case flowchart
#     ...    *******************
#     [Tags]    AUTHOR_fred.li@nokia-sbell.com
#     [Timeout]   3 hour
#     [Setup]
#     ${cell_numbers}    Get Cell Number
#     set suite variable   ${cell_numbers}
#     Step1: set parameters
#     Step2: Check SWEM Report   cell_numbers=${cell_numbers}
#     Step3: modify The Bandwith
#     Step4: Check SWEM Report   cell_numbers=${cell_numbers}
#     [Teardown]   CI_interface.Common Case Teardown
#
# *** Keywords ***
# Step1: set parameters
#     ${return_celltype}   selenium_coam.get_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#     ...   filter_param=${NRcelltype}
#     Run Keyword If   '${return_celltype}'!='8DL4UL'  _set_parameter_all_index    filter_name=${NRcelltype}   newvalue=8DL4UL
#     ${return_power}   selenium_coam.get_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#     ...   filter_param=${output power_ban}
#     Run Keyword If   '${return_power}'!='35 (dBm)'  _Modify_power_Parameters_all_cell    pmaxvalue=${power_value2}
#     ${flag}   run keyword if   '${return_celltype}'=='8DL4UL' and '${return_power}'=='35 (dBm)'   set variable   false
#     ...   ELSE   set variable   true
#     run keyword if   '${flag}'=='true'   selenium_coam.validate_plan
#     sleep    5s
#     run keyword if   '${flag}'=='true'    selenium_coam.activate_plan   activate_plan_despite_errors=${True}
#     sleep    4min
#     Run Keyword And Ignore Error   selenium_coam.logout
#     Wait Until Keyword Succeeds   15min   3min   Check gnb Detect   gnb_addr=${asik_addr}
#     Wait Until Keyword Succeeds   5 min   1 min  COAM WEBUI Login
#     ...   url=https://${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}
#     selenium_coam.disable_screen_lock
#     ${start_view}   selenium_coam.start_up_view_window_exists
#     Run Keyword If   ${start_view}   selenium_coam.close_start_up_view_window
#     ${return_power}   selenium_coam.get_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#     ...   filter_param=${output power_ban}
#     ${match}   run keyword and return status  Should Match Regexp    ${return_power.split(' ')[0]}   .*35.*
#     should be true   ${match}
#
# Step2: Check SWEM Report
#     [Arguments]   ${cell_numbers}
#     ${value}   Get Licensed Capacity Via CSV   sales_item=5G000007   report_type=detailed
#     ${value}   Convert To Integer   ${value}
#     ${expect_value}=    Evaluate    ${cell_numbers}*2
#     should be equal   ${value}   ${expect_value}
#
# Step3: modify The Bandwith
#     ${return_power}   selenium_coam.get_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#     ...   filter_param=${output power_ban}
#     Run Keyword If   '${return_power}'!='26 (dBm)'  _Modify_power_Parameters_all_cell    pmaxvalue=${power_value}
#     ${flag}   run keyword if   '${return_power}'=='26 (dBm)'   set variable   false
#     ...   ELSE   set variable   true
#     run keyword if   '${flag}'=='true'   selenium_coam.validate_plan
#     sleep    5s
#     run keyword if   '${flag}'=='true'    selenium_coam.activate_plan   activate_plan_despite_errors=${True}
#     sleep    4min
#     Run Keyword And Ignore Error   selenium_coam.logout
#     Wait Until Keyword Succeeds   15min   3min   Check gnb Detect   gnb_addr=${asik_addr}
#     Wait Until Keyword Succeeds   5 min   1 min  COAM WEBUI Login
#     ...   url=https://${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}
#     selenium_coam.disable_screen_lock
#     ${start_view}   selenium_coam.start_up_view_window_exists
#     Run Keyword If   ${start_view}   selenium_coam.close_start_up_view_window
#     ${return_power}   selenium_coam.get_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#     ...   filter_param=${output power_ban}
#     ${match}   run keyword and return status  Should Match Regexp    ${return_power.split(' ')[0]}   .*26.*
#     should be true   ${match}
#
# Step4: Check SWEM Report
#     [Arguments]   ${cell_numbers}
#     ${value}   Get Licensed Capacity Via CSV   sales_item=5G000007   report_type=detailed
#     ${value}   Convert To Integer   ${value}
#     ${expect_value}=    Evaluate    ${cell_numbers}*1
#     should be equal   ${value}   ${expect_value}
# 	${value2}   Get Licensed Capacity Via CSV   sales_item=5G000007
#     ${value2}   Convert To Integer   ${value2}
#     ${expect_value2}=    Evaluate    ${cell_numbers}*2
#     should be equal   ${value2}    ${expect_value2}