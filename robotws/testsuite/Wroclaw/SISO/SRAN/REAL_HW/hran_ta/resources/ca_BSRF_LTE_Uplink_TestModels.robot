# robocop: off
*** Settings ***
Documentation
...  Resource for LTE uplink Test Models

Resource          hran_frame_sbts_siso.robot
Resource          ca_siso_hran.robot
Resource          ca_siso_general.robot
Resource          ca_BSRF_general.robot
Library           taf.selenium.sbts  WITH NAME  selenium_coam

*** Variables ***
@{TM_LIST}      A1_1  A1_2  A1_3  A1_4  A1_5  A2_1  A2_2  A2_3
@{RB_OFFSET}    0  10    #Default values Resource block offset
@{A1_1}         1.4 MHz    #Allowed cell bandwidth
@{A1_2}         3 MHz  5 MHz    #Allowed cell bandwidth
@{A1_3}         5 MHz  10 MHz  15 MHz  20 MHz    #Allowed cell bandwidth
@{A1_4}         1.4 MHz    #Allowed cell bandwidth
@{A1_5}         3 MHz    #Allowed cell bandwidth
@{A2_1}         1.4 MHz    #Allowed cell bandwidth
@{A2_2}         3 MHz    #Allowed cell bandwidth
@{A2_3}         5 MHz  10 MHz  15 MHz  20 MHz    #Allowed cell bandwidth
${node}          default
*** Keywords ***

step${step_number}: Set Resource Block Offset

    Log To Console    step${step_number}: Set Resource Block Offset
    ${USER_RB_OFFSET}    Set Variable    0,0
    Set Test Variable    ${USER_RB_OFFSET}

step${step_number}: Set Resource Block Offset for A1_4

    Log To Console    step${step_number}: Set Resource Block Offset
    ${USER_RB_OFFSET}    Set Variable    0,3
    Set Test Variable    ${USER_RB_OFFSET}

step${step_number}: Set Resource Block Offset for A1_5

    Log To Console    step${step_number}: Set Resource Block Offset
    ${USER_RB_OFFSET}    Set Variable    0,6
    Set Test Variable    ${USER_RB_OFFSET}

step${step_number}: Check Input Data for LTE Uplink Test Model ${USER_TM}

    Log To Console    step${step_number}: Check Input Data for LTE Uplink Test Model ${USER_TM}
    Set Test Variable    ${USER_TM}
    Log To Console    Check input data correctness
    Run Keyword If    '${USER_LTE_CELL}'=='${EMPTY}'    ca_BSRF_LTE_Uplink_TestModels.Get Ids For All Cells
    ...  ELSE    ca_BSRF_LTE_Uplink_TestModels.Get Ids For User Cell
    Log To Console    LTE Uplink Test Model ${USER_TM} will be performed for Cell:\n${LTE_CELLS_ID_LIST}
    ca_BSRF_LTE_Uplink_TestModels.Check Possibility Run Test Model
    ${rb_offset_status}=    Run Keyword And Return Status    Should Be Empty    ${USER_RB_OFFSET}
    Run Keyword If    '${rb_offset_status}'=='False'    ca_BSRF_LTE_Uplink_TestModels.Check Rb_Offset Values
    Log To Console    LTE Uplink Test Model ${USER_TM} will be performed for Resource Block Offset:\n${RB_OFFSET}

step${step_number}: Confirm Dedicated State

    Log To Console    step${step_number}: Confirm Dedicated State
    Log To Console  Reset To Test Dedicated Test procedure completed, waiting for MRBTS state -> Test ...${\n}
    Wait Until Keyword Succeeds  10min  10s  Check MrBTS State  expected_state=Test

    Log To Console  MRBTS state -> Test${\n}Waiting for all RAT(s) state -> Test ...${\n}
    Wait Until Keyword Succeeds  5min  10s  Check RAT State from Infomodel  expected_state=Test

    Log To Console  RAT(s) state -> Test${\n}Waiting for all LNCEL proceduralState -> prevalidated ...\n
    Wait Until Keyword Succeeds  5m  10s  admin.Assert Every  LNCEL  proceduralState=regex"(?i)Prevalidated"  search_for_iot_cells=${True}
    Log To Console  LNCELL(s) proceduralState -> Prevalidated\nGoing to next step!

step${step_number}: Start Dedicated State

    Log To Console  ${\n}step${step_number}: Start Dedicated State${\n}
    Log To Console    Reset to Test Dedicated State

    ${is_lte}  Run Keyword And Return Status    admin.Get Ids For All  LNCEL  search_for_iot_cells=${True}
    admin.Reset To Test Dedicated
    ${TDS_status}  Run Keyword And Return Status
    ...  ca_BSRF_LTE_Uplink_TestModels.Check if BTS is in Test Dedicated State  ${is_lte}
    Run Keyword If    ${TDS_status}==False    Fail    Problem with enter to Test Dedicated State
    Log to console  BTS is in Test Dedicated State

Check if BTS is in Test Dedicated State
    [Arguments]    ${is_lte}

    Log To Console  Reset To Test Dedicated Test procedure completed, waiting for MRBTS state -> Test ...${\n}
    Wait Until Keyword Succeeds  10min  10s  Check MrBTS State  expected_state=Test

    Log To Console  MRBTS state -> Test${\n}Waiting for all RAT(s) state -> Test ...${\n}
    Wait Until Keyword Succeeds  5min  10s  Check RAT State from Infomodel  expected_state=Test

    Run Keyword If  ${is_lte}  Wait Until Keyword Succeeds  5m  10s
    ...  admin.Assert Every  LNCEL  proceduralState=regex"(?i)Prevalidated"  search_for_iot_cells=${True}



step${step_number}: Check LTE Uplink Test Model

    ${check_active_tm_info}=    Create List    after start TM action    after stop TM action
    Log To Console    step${step_number}: Check LTE Uplink Test Model ${USER_TM}
    FOR    ${rb_offset_id}    IN    @{RB_OFFSET}
        Log To Console    \nCheck ${USER_TM} for Resource Block Offset = ${rb_offset_id}
        ca_BSRF_LTE_Uplink_TestModels.Start Uplink Test Model    ${rb_offset_id}
        ${active_tm_after_start}=    ca_BSRF_LTE_Uplink_TestModels.Check Active Test Models    ${rb_offset_id}    ${check_active_tm_info[0]}
        ca_BSRF_LTE_Uplink_TestModels.Stop Uplink Test Model    ${rb_offset_id}
        ${active_tm_after_stop}=    ca_BSRF_LTE_Uplink_TestModels.Check Active Test Models    ${rb_offset_id}    ${check_active_tm_info[1]}
        List Should Not Contain Value  ${active_tm_after_start}
        ...  FAIL  msg=Problem with activation Test Model ${USER_TM} for Resource block offset = ${rb_offset_id}
        List Should Not Contain Value  ${active_tm_after_stop}  PASS  msg=Test Model ${USER_TM} is still active after Stop Uplink Test Model action
    END

step${step_number}: Exit Test Dedicated State via WebEM

    Log To Console    ${\n}step${step_number}: Exit Test Dedicated State via WebEM${\n}
    Log to console  Checking Google Chrome and Chrome Driver compatibility !${\n}
    Check And Repair Google Chrome And Chrome Driver Compatibility

    ca_BSRF_LTE_Uplink_TestModels.Selenium Login And Disable Screen Lock TDS
    selenium_coam.Disable Test Dedicated State    timeout=300
    ca_BSRF_LTE_Uplink_TestModels.Selenium Logout And Close Browser TDS
    Log To Console    Reset to Test Dedicated State Disabled succeeds
    Log To Console    Reset BTS to OnAir State
    Log To Console    Check if BTS is in OnAir State
    Wait Until Keyword Succeeds    15 min  15 sec    ca_BSRF_LTE_Uplink_TestModels.Check If Modules And Cells Are OnAir

Check If Modules And Cells Are OnAir
    [Documentation]
    ...  KW checks if all cells are onAir and modules are Enabled
    Check If All Cells Are OnAir
    admin.Assert Every    RMOD    operationalState=regex"(?i)Enabled"
    admin.Assert Every    SMOD    operationalState=regex"(?i)Enabled"

Selenium Login And Disable Screen Lock TDS
    [Arguments]    ${download_dir}=${TestFiles}/selenium   ${screenshot_dir}=${TestFiles}/selenium
    ${browser}=  selenium_coam.Create Firefox Browser  download_dir=${download_dir}  screenshot_dir=${screenshot_dir}  name=firefox_browser
    ${sw_release}    admin.Get Sw Release Name
    selenium_coam.login  https://192.168.255.129/  Nemuadmin  nemuuser  version=${sw_release}  browser=${browser}
    ${view_exists}  selenium_coam.start_up_view_window_exists
    Run Keyword If  ${view_exists}  selenium_coam.close_start_up_view_window
    selenium_coam.disable_message_box
    selenium_coam.disable_screen_lock

Selenium Logout And Close Browser TDS
    Run Keyword And Ignore Error  selenium_coam.logout
    Run Keyword And Ignore Error  selenium_coam.close_browser

Start Uplink Test Model
    [Arguments]    ${rb_offset_id}
    [Documentation]
    ...  Start LTE Uplink Test Model procedure
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW starts LTE uplink test model on selected LTE cells.
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+-------------------------+
    ...  | Parameter name | Man. | Description             |
    ...  +================+======+=========================+
    ...  | rb_offset_id   | yes  | Resource block offset   |
    ...  +----------------+------+-------------------------+

    Log To Console    Test model ${USER_TM} will be started for cell: \n${LTE_CELLS_ID_LIST}
    FOR    ${LTE_cell_ID}    IN    @{LTE_CELLS_ID_LIST}
        ${cell_parameters}=    admin.Get Parameters For    LNCEL    ${LTE_cell_ID}
        Log To Console    Start Uplink Test Model ${USER_TM} for LTE cell ${cell_parameters.id}
        admin.Start Uplink Test    ${LTE_cell_ID}    ${USER_TM}    1    ${rb_offset_id}    ${cell_parameters.earfcnUL}  BinaryHarq
        Sleep    10s
    END

Check Active Test Models
    [Arguments]    ${rb_offset_id}    ${check_active_tm_info}
    [Documentation]
    ...  Check Active Test Models procedure
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW check if LTE TM is Active in Admin Api.
    ...  | KW use Assert Uplink Test Results.
    ...  | If TM is Active, KW append value "PASS" in list ${active_tm_status}.
    ...  | If TM is inActive, KW append value "FAIL" in list ${active_tm_status}.
    ...  | KW returns ${active_tm_status} containing items "PASS" and "FAIL".
    ...
    ...  **Input Parameters:**
    ...
    ...  +---------------------+------+------------------------------------------+
    ...  | Parameter name      | Man. | Description                              |
    ...  +=====================+======+==========================================+
    ...  | rb_offset_id        | yes  | Resource block offset                    |
    ...  +---------------------+------+------------------------------------------+
    ...  | check_active_tm_info| yes  | Active TM Info after start/stop TM       |
    ...  +---------------------+------+------------------------------------------+

    Log To Console    Check Active Test Models ${check_active_tm_info}
    ${active_tm_status}=    Create List
    FOR    ${LTE_cell_ID}    IN    @{LTE_CELLS_ID_LIST}
        ${active_tm}    ${active_tm_msg}=    Run Keyword And Ignore Error    admin.Assert Uplink Test Results    ${LTE_cell_ID}    timeout=10
        Run Keyword If    '${active_tm}'=='FAIL'    Log To Console    No active test model for LTE cell ${LTE_cell_ID}
        Run Keyword If    '${active_tm}'=='PASS'    Log To Console    For LTE cell ${LTE_cell_ID}, Test model ${USER_TM} is active
        Append To List    ${active_tm_status}    ${active_tm}
    END
    [Return]    ${active_tm_status}

Stop Uplink Test Model
    [Arguments]    ${rb_offset_id}
    [Documentation]
    ...  Stop LTE Uplink Test Model
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW stops active test models.
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+-------------------------+
    ...  | Parameter name | Man. | Description             |
    ...  +================+======+=========================+
    ...  | rb_offset_id   | yes  | Resource block offset   |
    ...  +----------------+------+-------------------------+

    Log To Console   Test model ${USER_TM} will be stopped for cell: \n${LTE_CELLS_ID_LIST}
    FOR    ${LTE_cell_ID}    IN    @{LTE_CELLS_ID_LIST}
        ${cell_parameters}=    admin.Get Parameters For    LNCEL    ${LTE_cell_ID}
        Log To Console    Stop Uplink Test Model ${USER_TM} for LTE cell ${cell_parameters.id}
        ${stop_tm_status}    Run Keyword And Return Status    admin.Stop Uplink Test    ${LTE_cell_ID}
        Run Keyword If  '${stop_tm_status}'=='False'  Log To Console  No active Test Model ${USER_TM} for LTE cell ${cell_parameters.id} to stopped
        Run Keyword If  '${stop_tm_status}'=='True'  Log To Console  Test model ${USER_TM} for LTE cell ${LTE_cell_ID} was stopped succesfully.
        Sleep    10s
    END

#Check if BTS is in Test Dedicated State
#    [Arguments]    ${wcdma_configured}
#    [Documentation]
#    ...  Check if BTS is in Test Dedicated State
#    ...
#    ...  | **Author:** lukasz.wystup@nokia.com
#    ...  | **Maintainer:** lukasz.wystup@nokia.com
#    ...
#    ...  | **Full description:**
#    ...  | This KW check in Info Model if TDS is active. KW failed if can't find information about testing state activity during 1 min.
#
##    Wait until keyword succeeds  1 min  5 sec
##    ...  ute_admin_infomodel.Query infomodel  query=check /MRBTS-1/RAT-*/BTS_L-*/BTS_CONF-1/INTERNAL-* is [resetToTestDedicated=True]
#    Wait until keyword succeeds  1 min  5 sec
#    ...  ute_admin_infomodel.Query infomodel  query=check /MRBTS-1/RAT-*/MCTRL-*/BBTOP_M-1/MRBTS_M-1 is [stateInfo.testingState=Enabled]
#    Run Keyword If  ${wcdma_configured}==True  Wait until keyword succeeds  1 min  5 sec
#    ...  ute_admin_infomodel.Query infomodel  query=check /MRBTS-1/RAT-*/WTS-*/WBTS_L-1 is [stateInfo.testingState=Enabled]

Get Ids For User Cell
    [Documentation]
    ...  Get Ids For User Cell
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW creates list with LNCEL_R-* objects from input string with LTE Cell Ids. If enter Cell Id does not exist in configuration KW Fail.
    ...  | KW create test variable ${LTE_CELLS_ID_LIST}.

    ${user_LTE_cell_list}=    split string    ${USER_LTE_CELL}    separator=,
    ${LTE_CELLS_ID_LIST}=    Create List
    FOR    ${USER_LTE_CELL}    IN    @{user_LTE_cell_list}
        ${exist_LTE_cell_dist}    ${LTE_cell_dist}=   Run Keyword And Ignore Error
        ...  Get Infomodel Object   /MRBTS-1/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-*/LNCEL_R-${USER_LTE_CELL}
        Run Keyword If  '${exist_LTE_cell_dist}'=='PASS'  Append To List  ${LTE_CELLS_ID_LIST}  ${LTE_cell_dist.dist_name}
        Run Keyword If  '${exist_LTE_cell_dist}'=='FAIL'  Fail  Incorrect input data - LTE cell ID ${USER_LTE_CELL} does not exist in configuration
    END
    Set Test Variable    ${LTE_CELLS_ID_LIST}

Get Ids For All Cells
    [Documentation]
    ...  Get Ids For All Cells
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW creates list with LNCEL_R-* objects for LTE Cells in configuration.
    ...  | KW create test variable ${LTE_CELLS_ID_LIST}.

    @{LTE_CELLS_ID_LIST}  admin.Get Ids For All  LNCEL  search_for_iot_cells=${True}
    Set Test Variable    ${LTE_CELLS_ID_LIST}

Check Rb_Offset Values
    [Documentation]
    ...  Check Rb_Offset Values
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW creates list with Resource block offset from input string ${USER_RB_OFFSET}.
    ...  | KW check if elements from ${USER_RB_OFFSET} have proper value - if not set test to NoRun.
    ...  | KW create test variable ${RB_OFFSET}.

    ${RB_OFFSET}=    split string    ${USER_RB_OFFSET}    separator=,
    FOR    ${rb_offset_value}    IN    @{RB_OFFSET}
        Run Keyword If    ${rb_offset_value} > 25  Fail  Invalid value Resource Block Offset = ${rb_offset_value} - use values from 0 to 10!
    END
    Set Test Variable    ${RB_OFFSET}

Check Possibility Run Test Model
    [Documentation]
    ...  Check Possibility Run Test Model
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW check if selected LTE cells have correct ChBw for select LTE Uplink Test Model.
    ...  | If not set test to NoRun.

    FOR    ${LTE_cell_ID}    IN    @{LTE_CELLS_ID_LIST}
        ${cell_parameters}=    admin.Get Parameters For    LNCEL    ${LTE_cell_ID}
        ${bandwidth_correctness}=    Run Keyword And Return Status    Should Contain    ${${USER_TM}}    ${cell_parameters.downlinkChannelBandwidth}
        Run Keyword If  '${bandwidth_correctness}'=='True'  Log To Console
        ...  Bandwidth ${cell_parameters.downlinkChannelBandwidth} cell ${cell_parameters.id} allows run LTE Uplink Test Model ${USER_TM}
    ...  ELSE    Fail    LTE Uplink Test Model ${USER_TM} can be run only for cell bandwidth: ${${USER_TM}}
    END
