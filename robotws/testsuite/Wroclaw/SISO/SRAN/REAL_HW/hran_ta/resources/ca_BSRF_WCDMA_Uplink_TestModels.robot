*** Settings ***
Documentation
...  Resource for WCDMA uplink TestModels

Resource          hran_frame_sbts_siso.robot
Resource          ca_siso_hran.robot
Resource          ca_siso_general.robot

*** Keywords ***

step${step_number}: Check Input Data for WCDMA Uplink Test Model ${USER_TM}

    ## VARIABLES ##

    Set Test Variable  @{TM_LIST}    BER/BLER
    Set Test Variable  @{PRIMARY_SCR_CODE}    0  1    #Default values scrambling code

    ## END OF VARIABLES ##

    Log To Console    step${step_number}: Check Input Data for WCDMA Uplink Test Model ${USER_TM}
    Set Test Variable    ${USER_TM}
    Log To Console    Check input data correctness
    ${wcdma_configured}=    Run Keyword And Return Status
    ...  ute_admin_infomodel.Query infomodel  query=check /MRBTS-1/RAT-*/MCTRL-*/BBTOP_M-*/MRBTS_M-*/WNBTS_M-1 is [stateInfo.proceduralState=Test]
    Run Keyword If    ${wcdma_configured}==False  Fail  No WCDMA cell in configuration
    Run Keyword If    '${USER_WCDMA_CELL}'=='${EMPTY}'    ca_BSRF_WCDMA_Uplink_TestModels.Get Ids For All Cells
    ...  ELSE    ca_BSRF_WCDMA_Uplink_TestModels.Get Ids For User Cell
    Log To Console    WCDMA Uplink Test Model ${USER_TM} will be performed for Cell:\n${WCDMA_CELLS_ID_LIST}
    ${primary_scr_code_status}=    Run Keyword And Return Status    Should Not Be Empty    ${USER_PRIMARY_SCR_CODE}
    Run Keyword If    '${primary_scr_code_status}'=='True'    ca_BSRF_WCDMA_Uplink_TestModels.Set PRIMARY_SCR_CODE Values
    Log To Console    WCDMA Uplink Test Model ${USER_TM} will be performed for scrambling code:\n${PRIMARY_SCR_CODE}

step${step_number}: Confirm Dedicated State

    Log To Console    step${step_number}: Confirm Dedicated State
    ${TDS_status}=    Run Keyword And Return Status    ca_BSRF_WCDMA_Uplink_TestModels.Check if BTS is in Test Dedicated State
    Run Keyword If    ${TDS_status}==False  Fail  Set BTS in Test Dedicated State before run TC
    Log to console    BTS is in Test Dedicated State

step${step_number}: Check WCDMA Uplink Test Model

    Log To Console    step${step_number}: Check WCDMA Uplink Test Model ${USER_TM}
    FOR    ${scr_code_id}    IN    @{PRIMARY_SCR_CODE}
        Log To Console    \nTest Model ${USER_TM} will be checked for scrambling codes: @{PRIMARY_SCR_CODE}
        Run Keyword If    '${USER_TM}'=='BER/BLER'    ca_BSRF_WCDMA_Uplink_TestModels.Check BER/BLER    ${scr_code_id}
    END

Check BER/BLER
    [Arguments]    ${scr_code_id}
    [Documentation]
    ...  BER/BLER check procedure
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW Starts uplink test model BER/BLER, checks if Test model BER/BLER is active,
    ...  | stops active test models and checks if active test models were stoped properly.
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+-------------------------+
    ...  | Parameter name | Man. | Description             |
    ...  +================+======+=========================+
    ...  | scr_code_id    | yes  | Scrambling code         |
    ...  +----------------+------+-------------------------+

    Log To Console    \nCheck ${USER_TM} for scrambling code: ${scr_code_id}
    ca_BSRF_WCDMA_Uplink_TestModels.Start Uplink Test Model BER/BLER    ${scr_code_id}
    ${active_tm_list}=    ca_BSRF_WCDMA_Uplink_TestModels.Check Active Test Models BER/BLER    ${scr_code_id}
    ca_BSRF_WCDMA_Uplink_TestModels.Stop Uplink Test Model    ${scr_code_id}
    ${not_active_tm_list}=    ca_BSRF_WCDMA_Uplink_TestModels.Check Active Test Models BER/BLER    ${scr_code_id}
    ${active_tm_list_status}=    Run Keyword And Return Status    Should Not Contain    ${active_tm_list}    ${False}
    ${not_active_tm_list_status}=    Run Keyword And Return Status    Should Not Contain    ${not_active_tm_list}    ${True}
    Run Keyword If    '${active_tm_list_status}'=='False'  Fail  ${USER_TM} was not activated on all selected WCDMA cells
    Run Keyword If    '${not_active_tm_list_status}'=='False'  Fail  ${USER_TM} was not stop properly on selected WCDMA cells

Start Uplink Test Model BER/BLER
    [Arguments]    ${scr_code_id}
    [Documentation]
    ...  Start Uplink Test Model BER/BLER procedure
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW logs Tx power on all RM before activate test model, starts uplink test model BER/BLER
    ...  | and logs Tx power on all RM after activate test model.
    ...  | KW set test to Fail, when meet some problem with start WCDMA uplink test.
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+-------------------------+
    ...  | Parameter name | Man. | Description             |
    ...  +================+======+=========================+
    ...  | scr_code_id    | yes  | Scrambling code         |
    ...  +----------------+------+-------------------------+

    Log To Console    Test model ${USER_TM} will be started for cell: \n${WCDMA_CELLS_ID_LIST}
    FOR    ${WCDMA_cell_ID}    IN    @{WCDMA_CELLS_ID_LIST}
        ${WCDMA_cell_Id_str}=    Convert To String   ${WCDMA_cell_ID}
        ${WCDMA_cell_Id_scf_object}=    Replace String     ${WCDMA_cell_Id_str}    R    A
        ${cell_parameters}=    Get Infomodel Object    //${WCDMA_cell_Id_scf_object}
        Log To Console    Power before Start Uplink Test Model ${USER_TM} for WCDMA cell ${WCDMA_cell_ID}
        Run Keyword And Continue On Failure  Log All Carriers Power    TX
        Log To Console    Start Uplink Test Model ${USER_TM} for WCDMA cell ${WCDMA_cell_ID}
        ${start_tm_status}    ${start_tm_print}    Run Keyword And Ignore Error
        ...  admin.Start Wcdma Uplink Test    ${WCDMA_cell_ID}    ${cell_parameters.defaultCarrier}    ${scr_code_id}
        Run Keyword If    '${start_tm_status}'=='FAIL'  Fail  ${start_tm_print}
        ...  ELSE    Log To Console    Command Start Uplink Test Model ${USER_TM} for WCDMA cell ${WCDMA_cell_ID} has status ${start_tm_status}
        Sleep    10s
        Log To Console    Power after Start Uplink Test Model ${USER_TM} for WCDMA cell ${WCDMA_cell_ID}
        Run Keyword And Continue On Failure  Log All Carriers Power    TX
    END

Check Active Test Models BER/BLER
    [Arguments]    ${scr_code_id}
    [Documentation]
    ...  Check Active Test Models BER/BLER procedure
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW check if TM is Active in Info Model and Admin Api output.
    ...  | KW check in Info Model if WCDMA_UPLINK_TEST has status Active. If TM is Active, KW append value "True" in list ${tm_status_list}.
    ...  | If TM is inActive, KW append value "False" in list ${tm_status_list}.
    ...  | KW check last watch Periodic Result. If TM is Active, KW append value "True" in list ${tm_status_list}
    ...  | If TM is inActive, KW append value "False" in list ${tm_status_list}.
    ...  | KW returns ${tm_status_list} containing items "True" and "False".
    ...
    ...  **Input Parameters:**
    ...
    ...  +--------------------+------+------------------------------------------+
    ...  | Parameter name     | Man. | Description                              |
    ...  +====================+======+==========================================+
    ...  | scr_code_id        | yes  | Scrambling code                          |
    ...  +--------------------+------+------------------------------------------+

    Log To Console    Check Active Test Models
    ${tm_status_list}=    Create List
    FOR    ${WCDMA_cell_ID}    IN    @{WCDMA_CELLS_ID_LIST}
        ${active_tm_status}    Run Keyword And Return Status    Wait until keyword succeeds  0 min  15 sec
        ...  ute_admin_infomodel.Query infomodel  query=check //${WCDMA_cell_ID}/WCDMA_UPLINK_TEST-* is [stateInfo.usageState=Active]
        Run Keyword If  '${active_tm_status}'=='False'  Log To Console  For WCDMA cell ${WCDMA_cell_ID}, ${USER_TM} Uplink Test Model is NOT active
        ...  ELSE    Log To Console    For WCDMA cell ${WCDMA_cell_ID}, ${USER_TM} Uplink Test Model is active
        ${active_tm_admin}  ${active_tm_admin_msg}  Run Keyword And Ignore Error  admin.Watch Periodic Results  ${WCDMA_cell_ID}  watch_time=10
        Run Keyword If  '${active_tm_admin}'=='PASS'
        ...  Log To Console  Admin Api output - active ${USER_TM} for cell ${WCDMA_cell_ID}: \n${active_tm_admin_msg}
        ...  ELSE    Log To Console    Admin Api output - inactive ${USER_TM} for cell ${WCDMA_cell_ID}
        Run Keyword If    '${active_tm_admin}'=='PASS'    Append To List    ${tm_status_list}    ${True}
        ...  ELSE    Append To List    ${tm_status_list}    ${False}
        Append To List    ${tm_status_list}    ${active_tm_status}
    END
    [Return]    ${tm_status_list}

Stop Uplink Test Model
    [Arguments]    ${scr_code_id}
    [Documentation]
    ...  Stop Uplink Test Model
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
    ...  | scr_code_id    | yes  | Scrambling code         |
    ...  +----------------+------+-------------------------+

    Log To Console   Test model ${USER_TM} will be stopped for cell: \n${WCDMA_CELLS_ID_LIST}
    FOR    ${WCDMA_cell_ID}    IN    @{WCDMA_CELLS_ID_LIST}
        ${WCDMA_cell_Id_str}=    Convert To String   ${WCDMA_cell_ID}
        ${WCDMA_cell_Id_scf_object}=    Replace String     ${WCDMA_cell_Id_str}    R    A
        ${cell_parameters}=    Get Infomodel Object    //${WCDMA_cell_Id_scf_object}
        Log To Console    Power before Stop Uplink Test Model ${USER_TM} for WCDMA cell ${WCDMA_cell_ID}
        Run Keyword And Continue On Failure  Log All Carriers Power    TX
        Log To Console    Stop Uplink Test Model ${USER_TM} for WCDMA cell ${WCDMA_cell_ID}
        ${stop_tm_status}    Run Keyword And Return Status    admin.Stop Wcdma Uplink Test    ${WCDMA_cell_ID}
        Run Keyword If    '${stop_tm_status}'=='False'   Log To Console    No active Test Model ${USER_TM} for WCDMA cell ${WCDMA_cell_ID} to stoped
        ...  ELSE    Log To Console    Command Stop Uplink Test Model ${USER_TM} for WCDMA cell ${WCDMA_cell_ID} has status ${stop_tm_status}
        Log To Console    Power after Stop Uplink Test Model ${USER_TM} for WCDMA cell ${WCDMA_cell_ID}
        Run Keyword And Continue On Failure  Log All Carriers Power    TX
    END
    Log To Console    Test model ${USER_TM} for WCDMA cell ${WCDMA_CELLS_ID_LIST} was stopped succesfully.

Check if BTS is in Test Dedicated State
    [Documentation]
    ...  Check if BTS is in Test Dedicated State
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW check in Info Model if TDS is active. KW failed if can't find information about TM activity during 1min.

#    Wait until keyword succeeds  1 min  5 sec
#    ...  ute_admin_infomodel.Query infomodel  query=check /MRBTS-1/RAT-*/BTS_L-*/BTS_CONF-1/INTERNAL-* is [resetToTestDedicated=True]
    Wait until keyword succeeds  1 min  5 sec
    ...  ute_admin_infomodel.Query infomodel  query=check /MRBTS-1/RAT-*/MCTRL-*/BBTOP_M-1/MRBTS_M-1 is [stateInfo.testingState=Enabled]
    Wait until keyword succeeds  1 min  5 sec
    ...  ute_admin_infomodel.Query infomodel  query=check /MRBTS-1/RAT-*/WTS-*/WBTS_L-1 is [stateInfo.testingState=Enabled]

Get Ids For User Cell
    [Documentation]
    ...  Get Ids For User Cell
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW creates list with WNCEL_R-* objects from input string with WCDMA Cell Ids.
    ...  | If enter Cell Id does not exist in configuration KW set test Fail.
    ...  | KW create test variable ${WCDMA_CELLS_ID_LIST}.

    ${user_WCDMA_cell_list}=    Split String    ${USER_WCDMA_CELL}    separator=,
    ${WCDMA_CELLS_ID_LIST}=    Create List
    ${all_WCDMA_cell}=    admin.Get All Items By Class Name    WNCEL
    FOR    ${USER_WCDMA_CELL}    IN    @{user_WCDMA_cell_list}
        ${exist_WCDMA_cell_class}=    Run Keyword And Return Status    Should Contain    ${all_WCDMA_cell}    WNCEL_R-${USER_WCDMA_CELL}
        Run Keyword If    '${exist_WCDMA_cell_class}'=='True'    Append To List    ${WCDMA_CELLS_ID_LIST}    WNCEL_R-${USER_WCDMA_CELL}
        Run Keyword If    '${exist_WCDMA_cell_class}'=='False'
        ...  Fail  Incorrect input data - WCDMA cell ID ${USER_WCDMA_CELL} does not exist in configuration
    END
    Set Test Variable    ${WCDMA_CELLS_ID_LIST}

Get Ids For All Cells
    [Documentation]
    ...  Get Ids For All Cells
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW creates list with WNCEL_R-* objects for WCDMA Cells in configuration.
    ...  | KW create test variable ${WCDMA_CELLS_ID_LIST}.

    @{WCDMA_CELLS_ID_LIST}=    admin.Get All Items By Class Name    WNCEL
    Set Test Variable    ${WCDMA_CELLS_ID_LIST}

Set PRIMARY_SCR_CODE Values
    [Documentation]
    ...  Set PRIMARY_SCR_CODE Values
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW creates list with scrambling code from input string ${USER_PRIMARY_SCR_CODE}
    ...  | KW create test variable ${PRIMARY_SCR_CODE}

    ${PRIMARY_SCR_CODE}=    Split String    ${USER_PRIMARY_SCR_CODE}    separator=,
    FOR    ${primary_scr_code_value}    IN    @{PRIMARY_SCR_CODE}
        Run Keyword If    not (0 <= ${primary_scr_code_value} <= 16777215)
        ...  Fail  Invalid value Primary scrambling code = ${primary_scr_code_value} - use values from 0 to 16777215!
    END
    Set Test Variable    ${PRIMARY_SCR_CODE}
