# *** Settings ***
# Resource   Resource${/}NetAct.robot
# Resource   Resource${/}common_license.robot
# Suite Setup   Run Keywords   common_license.Common Setup
# ...   AND    COAM Check Units Status Normal   fbb-1   fsm-1
# Suite Teardown   common_license.Common Teardown   restore=${true}
# Force Tags    SG_08    CA_5G_OAM            CIT
# ...    PY36
#
# *** Variables ***
# ${NRcelltype}=    NR Cell type
# ${typevalue}=    nrCellType
# ${channel_ban}=   Channel bandwidth
# ${band_width}=    60MHz
# ${band_width2}=    40Mhz
# ${WEB_DOWNLOAD_DIR}   ${OUTPUT_DIR}
#
# *** Test Cases ***
# [1]5GC000257_License_computation_cmwave RF_bandwidth usage for classical BTS
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
#     [Setup]
#     [Timeout]   3 hour
#     ${cell_numbers}    Get Cell Number
#     set suite variable    ${cell_numbers}
#     Step1: set parameters
#     Step2: Check SWEM Report
#     Step3: modify The Bandwith
#     Step4: Check SWEM Report
#     [Teardown]   CI_interface.Common Case Teardown
#
# *** Keywords ***
# Step1: set parameters
#     ${return_celltype}   selenium_coam.get_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#     ...   filter_param=${NRcelltype}
#     Run Keyword If   '${return_celltype}'!='8DL4UL'   _set_parameter_all_index   filter_name=${NRcelltype}  newvalue=8DL4UL
#     ${return_bandwidth}   selenium_coam.get_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#     ...   filter_param=${channel_band}
#     Run Keyword If   '${return_bandwidth}'!='${band_width}'   _Modify_Bandwidth_all_cell   bandwidth=${band_width}
#     ${flag}   run keyword if   '${return_celltype}'=='8DL4UL' and '${return_bandwidth}'=='60MHz'   set variable   false
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
#     ${return_bandwith}   selenium_coam.get_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#     ...   filter_param=${channel_band}
#     Should Be Equal   ${return_bandwith}   60MHz
#
# Step2: Check SWEM Report
# #     CM upload 256 feature gNB
# #     sleep   2m
#      ${value}   Get Licensed Capacity Via CSV   sales_item=5G000005   report_type=detailed
#      ${value}   Convert To Integer   ${value}
#      ${expect_value}    set variable   ${${band_width.split('M')[0]}/20}
#      ${expect_value}=    Evaluate    ${cell_numbers}*${expect_value}
#      should be equal   ${value}   ${expect_value}
#
# Step3: modify The Bandwith
#     ${return_bandwidth}   selenium_coam.get_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#     ...   filter_param=${channel_band}
#     Run Keyword If   '${return_bandwidth}'!='${band_width2}'   _Modify_Bandwidth_all_cell   bandwidth=40MHz
#     ${flag}   run keyword if   '${return_bandwidth}'=='40MHz'   set variable   false
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
#     ${return_bandwith}   selenium_coam.get_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#     ...   filter_param=${channel_band}
#     Should Be Equal   ${return_bandwith}   40MHz
#
# Step4: Check SWEM Report
#     ${value}   Get Licensed Capacity Via CSV   sales_item=5G000005   report_type=detailed
#     ${value}   Convert To Integer   ${value}
#      ${expect_value}    set variable   ${${band_width2.split('M')[0]}/20}
#      should be equal   ${value}   ${cell_numbers}*${expect_value}