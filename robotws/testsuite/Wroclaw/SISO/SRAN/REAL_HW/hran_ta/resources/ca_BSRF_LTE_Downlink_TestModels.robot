# robocop: off
*** Settings ***
Documentation
...  Resource for LTE Downlink Test Models

Resource          hran_frame_sbts_siso.robot
Resource          ca_siso_hran.robot
Resource          ca_siso_general.robot
Resource          ca_BSRF_general.robot
Library           taf.selenium.sbts  WITH NAME  selenium_coam

*** Variables ***
@{TM_LIST}        E_TM1_1  E_TM1_2  E_TM2  E_TM2a  E_TM3_1a  E_TM3_1  E_TM3_2  E_TM3_3
@{PHY_CELL_ID}    1  503    #Default values Physical Cell Id
${node}           default
*** Keywords ***

step${step_number}: Check Input Data for LTE Downlink Test Model ${USER_TM}

    Log To Console    step${step_number}: Check Input Data for LTE Downlink Test Model ${USER_TM}
    Set Test Variable    ${USER_TM}
    Log To Console    Check input data correctness
    Run Keyword If    '${USER_LTE_CELL}'=='${EMPTY}'    ca_BSRF_LTE_Downlink_TestModels.Get Ids For All Cells
    ...  ELSE    ca_BSRF_LTE_Downlink_TestModels.Get Ids For User Cell
    Log To Console    LTE Downlink Test Model ${USER_TM} will be performed for Cell:\n${LTE_CELLS_ID_LIST}
    ${phy_cell_id_status}=    Run Keyword And Return Status    Should Be Empty    ${USER_PHY_CELL_ID}
    Run Keyword If    '${phy_cell_id_status}'=='False'    ca_BSRF_LTE_Downlink_TestModels.Check Phy_Cell_Id Values
    Log To Console    LTE Downlink Test Model ${USER_TM} will be performed for Physical cell ID:\n${PHY_CELL_ID}

step${step_number}: Start Dedicated State

    Log To Console  ${\n}step${step_number}: Start Dedicated State${\n}
    Log To Console    Reset to Test Dedicated State

    ${is_lte}  Run Keyword And Return Status    admin.Get Ids For All  LNCEL  search_for_iot_cells=${True}
    admin.Reset To Test Dedicated
    ${TDS_status}  Run Keyword And Return Status
    ...  ca_BSRF_LTE_Downlink_TestModels.Check if BTS is in Test Dedicated State  ${is_lte}
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



step${step_number}: Confirm Dedicated State

    Log To Console    step${step_number}: Confirm Dedicated State
    Log To Console  Reset To Test Dedicated Test procedure completed, waiting for MRBTS state -> Test ...${\n}
    Wait Until Keyword Succeeds  10min  10s  Check MrBTS State  expected_state=Test

    Log To Console  MRBTS state -> Test${\n}Waiting for all RAT(s) state -> Test ...${\n}
    Wait Until Keyword Succeeds  5min  10s  Check RAT State from Infomodel  expected_state=Test

    Log To Console  RAT(s) state -> Test${\n}Waiting for all LNCEL proceduralState -> prevalidated ...\n
    Wait Until Keyword Succeeds  5m  10s  admin.Assert Every  LNCEL  proceduralState=regex"(?i)Prevalidated"  search_for_iot_cells=${True}
    Log To Console  LNCELL(s) proceduralState -> Prevalidated\nGoing to next step!



step${step_number}: Check LTE Downlink Test Model

    Log To Console    step${step_number}: Check LTE Downlink Test Model ${USER_TM}
    FOR    ${phy_cell_id}    IN    @{PHY_CELL_ID}
        Log To Console    \nCheck ${USER_TM} for Physical cell ID = ${phy_cell_id}
        ca_BSRF_LTE_Downlink_TestModels.Start Downlink Test Model    ${phy_cell_id}
        ${active_tm_status}=    ca_BSRF_LTE_Downlink_TestModels.Check Active Test Models    ${phy_cell_id}
        ca_BSRF_LTE_Downlink_TestModels.Stop Downlink Test Model    ${phy_cell_id}
        Run Keyword If    '${active_tm_status}'=='FAIL'  Fail  Problem with test models active status
    END

step${step_number}: Check LTE Downlink Test Model - General

    Log To Console    step${step_number}: Check LTE Downlink Test Model ${USER_TM}
    FOR    ${phy_cell_id}    IN    @{PHY_CELL_ID}
        Log To Console    \nCheck ${USER_TM} for Physical cell ID = ${phy_cell_id}
        ca_BSRF_LTE_Downlink_TestModels.Start Downlink Test Model    ${phy_cell_id}
        ${active_tm_status}=    ca_BSRF_LTE_Downlink_TestModels.Check Active Test Models    ${phy_cell_id}
        ca_BSRF_LTE_Downlink_TestModels.Stop Downlink Test Model    ${phy_cell_id}
        Run Keyword If    '${active_tm_status}'=='FAIL'  Fail  Problem with test models active status
    END
    [Teardown]    ca_BSRF_LTE_Downlink_TestModels.Reset to OnAir State

step${step_number}: Exit Test Dedicated State via WebEM

    Log To Console    ${\n}step${step_number}: Exit Test Dedicated State via WebEM${\n}
    Log to console  Checking Google Chrome and Chrome Driver compatibility !${\n}
    Check And Repair Google Chrome And Chrome Driver Compatibility

    ca_BSRF_LTE_Downlink_TestModels.Selenium Login And Disable Screen Lock TDS
    selenium_coam.Disable Test Dedicated State    timeout=300
    ca_BSRF_LTE_Downlink_TestModels.Selenium Logout And Close Browser TDS
    Log To Console    Reset to Test Dedicated State Disabled succeeds
    Log To Console    Reset BTS to OnAir State
    Log To Console    Check if BTS is in OnAir State
    Wait Until Keyword Succeeds    15 min  15 sec    ca_BSRF_LTE_Downlink_TestModels.Check If Modules And Cells Are OnAir

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

Start Downlink Test Model
    [Arguments]    ${phy_cell_id}
    [Documentation]
    ...  Start Downlink Test Model procedure
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW logs Tx power on all RM before activate test model, starts downlink test model
    ...  | and logs Tx power on all RM after activate test model.
    ...  | KW set test to Fail, when meet some problem with start LTE downlink test.
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+-------------------------+
    ...  | Parameter name | Man. | Description             |
    ...  +================+======+=========================+
    ...  | phy_cell_id    | yes  | Physical Cell Id        |
    ...  +----------------+------+-------------------------+
    ...  | USER_TM        | yes  | Tesy model from TM_LIST |
    ...  +----------------+------+-------------------------+

    Log To Console    Test model ${USER_TM} will be started for cell: \n${LTE_CELLS_ID_LIST}
    FOR    ${LTE_cell_ID}    IN    @{LTE_CELLS_ID_LIST}
        ${cell_parameters}=    admin.Get Parameters For    LNCEL    ${LTE_cell_ID}
        Log To Console    Power before Start Downlink Test Model ${USER_TM} for LTE cell ${cell_parameters.id}
        Run Keyword And Continue On Failure  Log All Carriers Power    TX
        Log To Console    Start Downlink Test Model ${USER_TM} for LTE cell ${cell_parameters.id}
        admin.Start Downlink Test    ${LTE_cell_ID}    ${USER_TM}    ${cell_parameters.earfcnDL}    phy_cell_id=${phy_cell_id}
        Sleep    10s
        Log To Console    Power after Start Downlink Test Model ${USER_TM} for LTE cell ${cell_parameters.id}
        Run Keyword And Continue On Failure  Log All Carriers Power    TX
    END

Check Active Test Models
    [Arguments]    ${phy_cell_id}
    [Documentation]
    ...  Check Active Test Models procedure
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW check if LTE TM is Active in Admin Api.
    ...  | KW use Get Active Tests. If TM is Active, KW return ${active_tm_status} value "PASS".
    ...  | If TM is inActive, KW return ${active_tm_status} value "FAIL".
    ...
    ...  **Input Parameters:**
    ...
    ...  +--------------------+------+------------------------------------------+
    ...  | Parameter name     | Man. | Description                              |
    ...  +====================+======+==========================================+
    ...  | phy_cell_id        | yes  | Physical Cell Id                         |
    ...  +--------------------+------+------------------------------------------+

    Log To Console    Check Active Test Models
    ${number_LTE_cells}=    Get Length    ${LTE_CELLS_ID_LIST}
    Sleep    10s
    ${active_tm}=    admin.Get Active Tests
    ${active_tm_status}  ${active_tm_msg}=  Run Keyword And Ignore Error  Should Not Be Empty  ${active_tm}  msg=No active Downlink Test Models
    Run Keyword If    '${active_tm_status}'=='FAIL'    Log To Console    ${active_tm_msg}
    ${active_tm_status}  ${active_tm_msg}=  Run Keyword And Ignore Error
    ...  Length Should Be  ${active_tm}  ${number_LTE_cells}  msg=Tested test model is not active on all chosen cells
    Run Keyword If  '${active_tm_status}'=='FAIL'  Log To Console  ${active_tm_msg}
    Run Keyword If  '${active_tm_status}'=='PASS'
    ...  Log To Console  For Physical cell ID = ${phy_cell_id}, ${number_LTE_cells} Downlink Test Model are active
    [Return]    ${active_tm_status}

Stop Downlink Test Model
    [Arguments]    ${phy_cell_id}
    [Documentation]
    ...  Stop LTE Downlink Test Model
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW stops active LTE test models.
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+-------------------------+
    ...  | Parameter name | Man. | Description             |
    ...  +================+======+=========================+
    ...  | phy_cell_id    | yes  | Physical Cell Id        |
    ...  +----------------+------+-------------------------+

    Log To Console   Test model ${USER_TM} will be stopped for cell: \n${LTE_CELLS_ID_LIST}
    FOR    ${LTE_cell_ID}    IN    @{LTE_CELLS_ID_LIST}
        ${cell_parameters}=    admin.Get Parameters For    LNCEL    ${LTE_cell_ID}
        Log To Console    Power before Stop Downlink Test Model ${USER_TM} for LTE cell ${cell_parameters.id}
        Run Keyword And Continue On Failure  Log All Carriers Power    TX
        Log To Console    Stop Downlink Test Model ${USER_TM} for LTE cell ${cell_parameters.id}
        ${stop_tm_status}    Run Keyword And Return Status    admin.Stop Downlink Test    ${LTE_cell_ID}
        Run Keyword If  '${stop_tm_status}'=='False'  Log To Console  No active Test Model ${USER_TM} for LTE cell ${cell_parameters.id} to stoped
        Sleep    10s
        Log To Console    Power after Stop Downlink Test Model ${USER_TM} for LTE cell ${cell_parameters.id}
        Run Keyword And Continue On Failure  Log All Carriers Power    TX
    END
    ${active_tm}=    admin.Get Active Tests
    Should Be Empty    ${active_tm}   msg= ${USER_TM} didn't stop properly.
    Log To Console    Test model ${USER_TM} for LTE cell ${LTE_CELLS_ID_LIST} was stopped succesfully.

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
    ...  | This KW creates list with LNCEL_R-* objects from input string with LTE Cell Ids.
    ...  | If enter Cell Id does not exist in configuration KW set test Fail.
    ...  | KW create test variable ${LTE_CELLS_ID_LIST}.

    ${user_LTE_cell_list}=    split string    ${USER_LTE_CELL}    separator=,
    ${LTE_CELLS_ID_LIST}=    Create List
    FOR    ${USER_LTE_CELL}    IN    @{user_LTE_cell_list}
        ${exist_LTE_cell_dist}  ${LTE_cell_dist}=  Run Keyword And Ignore Error
        ...  Get Infomodel Object  /MRBTS-1/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-*/LNCEL_R-${USER_LTE_CELL}
        Run Keyword If    '${exist_LTE_cell_dist}'=='PASS'    Append To List    ${LTE_CELLS_ID_LIST}    ${LTE_cell_dist.dist_name}
        Run Keyword If    '${exist_LTE_cell_dist}'=='FAIL'  Fail  Incorrect input data - LTE cell ID ${USER_LTE_CELL} does not exist in configuration
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

Check Phy_Cell_Id Values
    [Documentation]
    ...  Check Phy_Cell_Id Values
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW creates list with Physical Cell Id from input string ${USER_PHY_CELL_ID}.
    ...  | KW check if elements from ${USER_PHY_CELL_ID} have proper value - if not set test to Fail.
    ...  | KW create test variable ${PHY_CELL_ID}.

    ${PHY_CELL_ID}=    split string    ${USER_PHY_CELL_ID}    separator=,
    FOR    ${phy_cell_id_value}    IN    @{PHY_CELL_ID}
        Run Keyword If  not (1 <= ${phy_cell_id_value} <= 503)  Fail  Invalid value Physical cellID= ${phy_cell_id_value} - use values from 1 to 503!
    END
    Set Test Variable    ${PHY_CELL_ID}

Reset to OnAir State
    [Documentation]
    ...  Reset to OnAir State
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW run Site Reset and wait 15 min for OnAir state.
    ...  | If occurs some problems with status cells, modules or alarms, KW set test to Fail.

    Log To Console    Reset to OnAir State
    admin.Reset Site    timeout=900
    Wait Until Keyword Succeeds  15 min  15 sec    Admin Check SBTS cells, modules and alarms
