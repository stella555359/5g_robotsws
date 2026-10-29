*** Settings ***
Documentation
...  Resource for WCDMA downlink TestModels

Resource          hran_frame_sbts_siso.robot

*** Keywords ***

step${step_number}: Check Input Data for WCDMA Downlink Test Model ${USER_TM}

     ## VARIABLES ##

    Set Test Variable  @{TM_LIST}    TM_1  TM_2  TM_3  TM_4  TM_5  TM_6
    Set Test Variable  @{PRIMARY_SCR_CODE}    0  1             #Default values Primary scrambling code
    Set Test Variable  @{TM_1_DPCH}    16  32  64              #Number of DPCH
    Set Test Variable  ${TM_2_DPCH}    3                       #Number of DPCH
    Set Test Variable  @{TM_2_DPCHPower}    -28  -3            #DPCH power
    Set Test Variable  @{TM_3_DPCH}    16  32                  #DPCH power
    Set Test Variable  @{TM_4_PCCPCH_SCH}    -6  -15  -26      #P-CCPCH + SCH power
    Set Test Variable  ${TM_4_DPCH}    0                       #Number of DPCH
    Set Test Variable  @{TM_5_HS_PDSCH}    2=6  4=14  8=30     #Number of HS-PDSCH and corresponding to them Number of DPCH
    Set Test Variable  @{TM_6_HS_PDSCH}    8=30                #Number of HS-PDSCH and corresponding to them Number of DPCH

     ## END OF VARIABLES ##

    Log to console  ${PRIMARY_SCR_CODE}
    Log To Console    step${step_number}: Check Input Data for WCDMA Downlink Test Model ${USER_TM}${\n}
    Set Test Variable    ${USER_TM}
    Log To Console    Check input data correctness${\n}
    ${wcdma_configured}=    Run Keyword And Return Status
    ...  ute_admin_infomodel.Query infomodel  query=check /MRBTS-1/RAT-*/MCTRL-*/BBTOP_M-*/MRBTS_M-*/WNBTS_M-1 is [stateInfo.proceduralState=Test]
    Run Keyword If    ${wcdma_configured}==False  Fail  No WCDMA cell in configuration
    Run Keyword If    '${USER_WCDMA_CELL}'=='${EMPTY}'    ca_BSRF_WCDMA_Downlink_TestModels.Get Ids For All Cells
    ...  ELSE    ca_BSRF_WCDMA_Downlink_TestModels.Get Ids For User Cell
    Log To Console    WCDMA Downlink Test Model ${USER_TM} will be performed for Cell:\n${WCDMA_CELLS_ID_LIST}${\n}
    ${primary_scr_code_status}=    Run Keyword And Return Status    Should Not Be Empty    ${USER_PRIMARY_SCR_CODE}
    Run Keyword If    '${primary_scr_code_status}'=='True'    ca_BSRF_WCDMA_Downlink_TestModels.Set PRIMARY_SCR_CODE Values
    Log To Console    WCDMA Downlink Test Model ${USER_TM} will be performed for Primary scrambling code:\n${PRIMARY_SCR_CODE}${\n}
    Check MCP For Cells
    Check TX Antenna Lines For WNCEL

step${step_number}: Confirm Dedicated State

    Log To Console    step${step_number}: Confirm Dedicated State${\n}
    ${TDS_status}=    Run Keyword And Return Status    ca_BSRF_WCDMA_Downlink_TestModels.Check if BTS is in Test Dedicated State
    Run Keyword If    ${TDS_status}==False  Fail  Set BTS in Test Dedicated State before run TC
    Log to console    BTS is in Test Dedicated State ! ${\n}

step${step_number}: Check WCDMA Downlink Test Model

    Log To Console    step${step_number}: Check WCDMA Downlink Test Model ${USER_TM}
    FOR    ${scr_code_id}    IN    @{PRIMARY_SCR_CODE}
        Log To Console    \nTest Model ${USER_TM} will be checked for Primary scrambling codes: @{PRIMARY_SCR_CODE}
        Run Keyword If    '${USER_TM}'=='TM_1' or '${USER_TM}'=='TM_3'   Check TM_1 or TM_3    ${scr_code_id}
        Run Keyword If    '${USER_TM}'=='TM_2'    Check TM_2    ${scr_code_id}
        Run Keyword If    '${USER_TM}'=='TM_4'    Check TM_4    ${scr_code_id}
        Run Keyword If    '${USER_TM}'=='TM_5' or '${USER_TM}'=='TM_6'    Check TM_5 Or TM_6    ${scr_code_id}
    END

Check TM_1 or TM_3
    [Arguments]    ${scr_code_id}
    [Documentation]
    ...  TM_1 or TM_3 check procedure
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW Starts downlink test model TM_1, checks if Test model TM_1 is active,
    ...  | stops active test models and checks if active test models were stoped properly.
    ...  | This KW Starts downlink test model TM_3, checks if Test model TM_3 is active,
    ...  | stops active test models and checks if active test models were stoped properly.
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+-------------------------+
    ...  | Parameter name | Man. | Description             |
    ...  +================+======+=========================+
    ...  | scr_code_id    | yes  | Primary scrambling code |
    ...  +----------------+------+-------------------------+

    FOR    ${number_of_dpch}    IN    @{${USER_TM}_DPCH}
        Log To Console    ${\n}----------------------------------------------------------------------
        Log To Console    Check ${USER_TM} for Primary scrambling code: ${scr_code_id} and Number of DPCH: ${number_of_dpch}
        Log To Console    ----------------------------------------------------------------------${\n}
        ${active_tm_list}  ca_BSRF_WCDMA_Downlink_TestModels.Start Downlink Test Model TM_1 or TM_3    ${scr_code_id}    ${number_of_dpch}
        ${not_active_tm_list}  ca_BSRF_WCDMA_Downlink_TestModels.Stop Downlink Test Model
        ${active_tm_list_status}=    Run Keyword And Return Status    Should Not Contain    ${active_tm_list}    ${False}
        ${not_active_tm_list_status}=    Run Keyword And Return Status    Should Not Contain    ${not_active_tm_list}    ${True}
        Run Keyword If    '${active_tm_list_status}'=='False'
        ...  Fail  ${USER_TM} was not activated on all selected WCDMA cells or RMOD power output is wrong !
        Run Keyword If    '${not_active_tm_list_status}'=='False'
        ...  Fail  ${USER_TM} was not stop properly on selected WCDMA cells or RMOD power output is wrong !
    END

Check TM_2
    [Arguments]    ${scr_code_id}
    [Documentation]
    ...  TM_2 check procedure
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW Starts downlink test model TM_2, checks if Test model TM_2 is active,
    ...  | stops active test models and checks if active test models were stoped properly.
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+-------------------------+
    ...  | Parameter name | Man. | Description             |
    ...  +================+======+=========================+
    ...  | scr_code_id    | yes  | Primary scrambling code |
    ...  +----------------+------+-------------------------+

    Log To Console    ${\n}------------------------------------------------------------------------------------
    Log To Console    Check ${USER_TM} for Primary scrambling code: ${scr_code_id} and values of DPCHPower: @{${USER_TM}_DPCHPower}
    Log To Console    ------------------------------------------------------------------------------------${\n}
    FOR    ${dpch_power}    IN    @{${USER_TM}_DPCHPower}
        Log To Console    ====================================================================================${\n}
        Log To Console    Check ${USER_TM} for Primary scrambling code: ${scr_code_id} and value of DPCHPower: ${dpch_power}${\n}
        Set Test Variable  ${DPCH_POWER}
        ${active_tm_list}  ca_BSRF_WCDMA_Downlink_TestModels.Start Downlink Test Model TM_2    ${scr_code_id}    ${TM_2_DPCH}    ${dpch_power}
        ${not_active_tm_list}  ca_BSRF_WCDMA_Downlink_TestModels.Stop Downlink Test Model
        ${active_tm_list_status}=    Run Keyword And Return Status    Should Not Contain    ${active_tm_list}    ${False}
        ${not_active_tm_list_status}=    Run Keyword And Return Status    Should Not Contain    ${not_active_tm_list}    ${True}
        Run Keyword If    '${active_tm_list_status}'=='False'
        ...  Fail  ${USER_TM} was not activated on all selected WCDMA cells or RMOD power output is wrong!
        Run Keyword If    '${not_active_tm_list_status}'=='False'
        ...  Fail  ${USER_TM} was not stop properly on selected WCDMA cells or RMOD power output is wrong!
    END

Check TM_4
    [Arguments]    ${scr_code_id}
    [Documentation]
    ...  TM_4 check procedure
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW Starts downlink test model TM_4, checks if Test model TM_4 is active,
    ...  | stops active test models and checks if active test models were stoped properly.
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+-------------------------+
    ...  | Parameter name | Man. | Description             |
    ...  +================+======+=========================+
    ...  | scr_code_id    | yes  | Primary scrambling code |
    ...  +----------------+------+-------------------------+

    Log To Console    ${\n}----------------------------------------------------------------------------------------------------
    Log To Console    Check ${USER_TM} for Primary scrambling code: ${scr_code_id} and values of P-CCPCH + SCH power: @{${USER_TM}_PCCPCH_SCH}
    Log To Console    ----------------------------------------------------------------------------------------------------${\n}
    FOR    ${pccpch_sch_power}    IN    @{${USER_TM}_PCCPCH_SCH}
        Log To Console    ====================================================================================${\n}
        Log To Console    Check ${USER_TM} for Primary scrambling code: ${scr_code_id} and value of P-CCPCH + SCH power: ${pccpch_sch_power}${\n}
        Set Test Variable  ${PCCPCH_SCH_POWER}
        ${active_tm_list}  ca_BSRF_WCDMA_Downlink_TestModels.Start Downlink Test Model TM_4    ${scr_code_id}    ${TM_4_DPCH}    ${pccpch_sch_power}
        ${not_active_tm_list}  ca_BSRF_WCDMA_Downlink_TestModels.Stop Downlink Test Model
        ${active_tm_list_status}=    Run Keyword And Return Status    Should Not Contain    ${active_tm_list}    ${False}
        ${not_active_tm_list_status}=    Run Keyword And Return Status    Should Not Contain    ${not_active_tm_list}    ${True}
        Run Keyword If    '${active_tm_list_status}'=='False'
        ...  Fail  ${USER_TM} was not activated on all selected WCDMA cells or RMOD power output is wrong!
        Run Keyword If    '${not_active_tm_list_status}'=='False'
        ...  Fail  ${USER_TM} was not stop properly on selected WCDMA cells or RMOD power output is wrong!
    END

Check TM_5 Or TM_6
    [Arguments]    ${scr_code_id}
    [Documentation]
    ...  TM_5 or TM_6 check procedure
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW Starts downlink test model TM_5, checks if Test model TM_5 is active,
    ...  | stops active test models and checks if active test models were stoped properly.
    ...  | This KW Starts downlink test model TM_6, checks if Test model TM_6 is active,
    ...  | stops active test models and checks if active test models were stoped properly.
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+-------------------------+
    ...  | Parameter name | Man. | Description             |
    ...  +================+======+=========================+
    ...  | scr_code_id    | yes  | Primary scrambling code |
    ...  +----------------+------+-------------------------+

    Log To Console   ${\n}---------------------------------------------------------------------------------------------------
    Log To Console   Check ${USER_TM} for Primary scrambling code: ${scr_code_id} and pair values Number of HS-PDSCH and DPCH: @{${USER_TM}_HS_PDSCH}
    Log To Console   --------------------------------------------------------------------------------------------------------${\n}
    FOR    ${pair_hs_pdsch_dpch}    IN    @{${USER_TM}_HS_PDSCH}
        ${pair_hs_pdsch_dpch}    Split String    ${pair_hs_pdsch_dpch}    separator==
        ${number_of_hs_pdsch}    Set Variable    ${pair_hs_pdsch_dpch[0]}
        ${number_of_dpch}    Set Variable    ${pair_hs_pdsch_dpch[1]}
        Log To Console    ===================================================================================================${\n}
        Log To Console    Check ${USER_TM} for Primary scrambling code: ${scr_code_id}, number of DPCH: ${number_of_dpch}
        Log To Console    and number of HS-PDSCH: ${number_of_hs_pdsch}${\n}
        ${active_tm_list}  ca_BSRF_WCDMA_Downlink_TestModels.Start Downlink Test Model TM_5 Or TM_6
        ...    ${scr_code_id}    ${number_of_dpch}    ${number_of_hs_pdsch}
        ${not_active_tm_list}  ca_BSRF_WCDMA_Downlink_TestModels.Stop Downlink Test Model
        ${active_tm_list_status}=    Run Keyword And Return Status    Should Not Contain    ${active_tm_list}    ${False}
        ${not_active_tm_list_status}=    Run Keyword And Return Status    Should Not Contain    ${not_active_tm_list}    ${True}
        Run Keyword If    '${active_tm_list_status}'=='False'
        ...  Fail  ${USER_TM} was not activated on all selected WCDMA cells or RMOD power output is wrong!
        Run Keyword If    '${not_active_tm_list_status}'=='False'
        ...  Fail  ${USER_TM} was not stop properly on selected WCDMA cells or RMOD power output is wrong!
    END

Start Downlink Test Model TM_1 Or TM_3
    [Arguments]    ${scr_code_id}    ${number_of_dpch}
    [Documentation]
    ...  Start Downlink Test Model TM_1 or TM_3 procedure
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW logs Tx power on all RM before activate test model, starts downlink test model TM_1 or TM_3 and
    ...  | logs Tx power on all RM after activate test model.
    ...  | KW set test to Fail, when meet some problem with start WCDMA downlink test.
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+-------------------------+
    ...  | Parameter name | Man. | Description             |
    ...  +================+======+=========================+
    ...  | scr_code_id    | yes  | Primary scrambling code |
    ...  +----------------+------+-------------------------+
    ...  | number_of_dpch | yes  | Number of DPCH          |
    ...  +----------------+------+-------------------------+

    Log To Console    Test model ${USER_TM} will be started for cell: \n${WCDMA_CELLS_ID_LIST}${\n}
    FOR    ${WCDMA_cell_ID}    IN    @{WCDMA_CELLS_ID_LIST}
        ${cellId}=    Split String    ${WCDMA_cell_ID}    separator=-
        ${WCDMA_cell_Id_str}=    Convert To String   ${WCDMA_cell_ID}
        ${WCDMA_cell_Id_scf_object}=    Replace String     ${WCDMA_cell_Id_str}    R    A
        ${cell_parameters}=    Get Infomodel Object    //${WCDMA_cell_Id_scf_object}
        Log To Console    Checking TX carriers with power before start ${USER_TM} for WCDMA cell ${WCDMA_cell_ID}:${\n}
        ${len_of_dict_before}  Check Number of Carriers  ${cellId}[1]
        Log To Console    Start Downlink Test Model ${USER_TM} for WCDMA cell ${WCDMA_cell_ID}${\n}
        ${start_tm_status}    ${start_tm_print}    Run Keyword And Ignore Error
        ...  admin.Start Wcdma Downlink Test  ${WCDMA_cell_ID}  ${cell_parameters.defaultCarrier}  ${USER_TM}  ${scr_code_id}  ${number_of_dpch}
        Run Keyword If    '${start_tm_status}'=='FAIL'  Fail  ${start_tm_print}
        ...  ELSE    Log To Console  Command Start Downlink Test Model ${USER_TM} for WCDMA cell ${WCDMA_cell_ID} has status ${start_tm_status}${\n}
        Sleep  10s
        Log To Console    Checking TX carriers with power after start ${USER_TM} for WCDMA cell ${WCDMA_cell_ID}:${\n}
        ${len_of_dict_after}  Check Number of Carriers  ${cellId}[1]
        ${diff}  Evaluate  (${len_of_dict_after} > ${len_of_dict_before})
        ${active_tm_list}=    ca_BSRF_WCDMA_Downlink_TestModels.Check If Test Model Is Active    tm_ON  ${WCDMA_CELL_ID}
        Append to list  ${active_tm_list}  ${diff}
    END

    [Return]  ${active_tm_list}

Start Downlink Test Model TM_2
    [Arguments]    ${scr_code_id}    ${number_of_dpch}    ${dpch_power}
    [Documentation]
    ...  Start Downlink Test Model TM_2 procedure
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW logs Tx power on all RM before activate test model, starts downlink test model TM_2 and
    ...  | logs Tx power on all RM after activate test model.
    ...  | KW set test to Fail, when meet some problem with start WCDMA downlink test.
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+-------------------------+
    ...  | Parameter name | Man. | Description             |
    ...  +================+======+=========================+
    ...  | scr_code_id    | yes  | Primary scrambling code |
    ...  +----------------+------+-------------------------+
    ...  | dpch_power     | yes  | DPCH power              |
    ...  +----------------+------+-------------------------+
    ...  | number_of_dpch | yes  | Number of DPCH          |
    ...  +----------------+------+-------------------------+

    Log To Console    Test model ${USER_TM} will be started for cell: \n${WCDMA_CELLS_ID_LIST}${\n}
    FOR    ${WCDMA_cell_ID}    IN    @{WCDMA_CELLS_ID_LIST}
        ${cellId}=    Split String    ${WCDMA_cell_ID}    separator=-
        ${WCDMA_cell_Id_str}=    Convert To String   ${WCDMA_cell_ID}
        ${WCDMA_cell_Id_scf_object}=    Replace String     ${WCDMA_cell_Id_str}    R    A
        ${cell_parameters}=    Get Infomodel Object    //${WCDMA_cell_Id_scf_object}
        Log To Console    Checking TX carriers with power before start ${USER_TM} for WCDMA cell ${WCDMA_cell_ID}:${\n}
        ${len_of_dict_before}  Check Number of Carriers  ${cellId}[1]
        Log To Console    Start Downlink Test Model ${USER_TM} for WCDMA cell ${WCDMA_cell_ID}${\n}
        ${start_tm_status}  ${start_tm_print}  Run Keyword And Ignore Error  admin.Start Wcdma Downlink Test  dist_name=${WCDMA_cell_ID}
        ...  uarfcn=${cell_parameters.defaultCarrier}  test_model=${USER_TM}  primary_scrambling_code=${scr_code_id}
        ...  number_of_dpch=${number_of_dpch}    dpch_tx_power=${dpch_power}    dpch_tx_pwr_ctrl_step_size=0_0
        Run Keyword If    '${start_tm_status}'=='FAIL'  Fail  ${start_tm_print}
        ...  ELSE    Log To Console  Command Start Downlink Test Model ${USER_TM} for WCDMA cell ${WCDMA_cell_ID} has status ${start_tm_status}${\n}
        Sleep    10s
        Log To Console    Checking TX carriers with power after start ${USER_TM} for WCDMA cell ${WCDMA_cell_ID}:${\n}
        ${len_of_dict_after}  Check Number of Carriers  ${cellId}[1]
        ${diff}  Evaluate  (${len_of_dict_after} > ${len_of_dict_before})
        ${active_tm_list}=    ca_BSRF_WCDMA_Downlink_TestModels.Check If Test Model Is Active    tm_ON  ${WCDMA_CELL_ID}
        Append to list  ${active_tm_list}  ${diff}
    END

    [Return]  ${active_tm_list}

Start Downlink Test Model TM_4
    [Arguments]    ${scr_code_id}    ${number_of_dpch}    ${pccpch_sch_power}
    [Documentation]
    ...  Start Downlink Test Model TM_4 procedure
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW logs Tx power on all RM before activate test model, starts downlink test model TM_4 and
    ...  | logs Tx power on all RM after activate test model.
    ...  | KW set test to Fail, when meet some problem with start WCDMA downlink test.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+-------------------------+
    ...  | Parameter name   | Man. | Description             |
    ...  +==================+======+=========================+
    ...  | scr_code_id      | yes  | Primary scrambling code |
    ...  +------------------+------+-------------------------+
    ...  | pccpch_sch_power | yes  | P-CCPCH + SCH power     |
    ...  +------------------+------+-------------------------+
    ...  | number_of_dpch   | yes  | Number of DPCH          |
    ...  +------------------+------+-------------------------+

    Log To Console    Test model ${USER_TM} will be started for cell: \n${WCDMA_CELLS_ID_LIST}${\n}
    FOR    ${WCDMA_cell_ID}    IN    @{WCDMA_CELLS_ID_LIST}
        ${cellId}=    Split String    ${WCDMA_cell_ID}    separator=-
        ${WCDMA_cell_Id_str}=    Convert To String   ${WCDMA_cell_ID}
        ${WCDMA_cell_Id_scf_object}=    Replace String     ${WCDMA_cell_Id_str}    R    A
        ${cell_parameters}=    Get Infomodel Object    //${WCDMA_cell_Id_scf_object}
        Log To Console    Checking TX carriers with power before start ${USER_TM} for WCDMA cell ${WCDMA_cell_ID}:${\n}
        ${len_of_dict_before}  Check Number of Carriers  ${cellId}[1]
        Log To Console    Start Downlink Test Model ${USER_TM} for WCDMA cell ${WCDMA_cell_ID}${\n}
        ${start_tm_status}  ${start_tm_print}  Run Keyword And Ignore Error  admin.Start Wcdma Downlink Test  dist_name=${WCDMA_cell_ID}
        ...  uarfcn=${cell_parameters.defaultCarrier}  test_model=${USER_TM}  primary_scrambling_code=${scr_code_id}
        ...  number_of_dpch=${number_of_dpch}    primary_ccpch_tx_power=${pccpch_sch_power}
        Run Keyword If    '${start_tm_status}'=='FAIL'  Fail  ${start_tm_print}
        ...  ELSE    Log To Console  Command Start Downlink Test Model ${USER_TM} for WCDMA cell ${WCDMA_cell_ID} has status ${start_tm_status}${\n}
        Sleep    10s
        Log To Console    Checking TX carriers with power after start ${USER_TM} for WCDMA cell ${WCDMA_cell_ID}:${\n}
        ${len_of_dict_after}  Check Number of Carriers  ${cellId}[1]
        ${diff}  Evaluate  (${len_of_dict_after} > ${len_of_dict_before})
        ${active_tm_list}=    ca_BSRF_WCDMA_Downlink_TestModels.Check If Test Model Is Active    tm_ON  ${WCDMA_cell_ID}
        Append to list  ${active_tm_list}  ${diff}
    END

    [Return]  ${active_tm_list}

Start Downlink Test Model TM_5 or TM_6
    [Arguments]    ${scr_code_id}    ${number_of_dpch}    ${number_of_hs_pdsch}
    [Documentation]
    ...  Start Downlink Test Model TM_5 or TM_6 procedure
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW logs Tx power on all RM before activate test model, starts downlink test model TM_5 or TM_6 and
    ...  | logs Tx power on all RM after activate test model.
    ...  | KW set test to Fail, when meet some problem with start WCDMA downlink test.
    ...
    ...  **Input Parameters:**
    ...
    ...  +--------------------+------+-------------------------+
    ...  | Parameter name     | Man. | Description             |
    ...  +====================+======+=========================+
    ...  | scr_code_id        | yes  | Primary scrambling code |
    ...  +--------------------+------+-------------------------+
    ...  | number_of_hs_pdsch | yes  | Number of HS-PDSCH      |
    ...  +--------------------+------+-------------------------+
    ...  | number_of_dpch     | yes  | Number of DPCH          |
    ...  +--------------------+------+-------------------------+

    Log To Console    Test model ${USER_TM} will be started for cell: \n${WCDMA_CELLS_ID_LIST}${\n}
    FOR    ${WCDMA_cell_ID}    IN    @{WCDMA_CELLS_ID_LIST}
        ${cellId}=    Split String    ${WCDMA_cell_ID}    separator=-
        ${WCDMA_cell_Id_str}=    Convert To String   ${WCDMA_cell_ID}
        ${WCDMA_cell_Id_scf_object}=    Replace String     ${WCDMA_cell_Id_str}    R    A
        ${cell_parameters}=    Get Infomodel Object    //${WCDMA_cell_Id_scf_object}
        Log To Console    Checking TX carriers with power before start ${USER_TM} for WCDMA cell ${WCDMA_cell_ID}:${\n}
        ${len_of_dict_before}  Check Number of Carriers  ${cellId}[1]
        Log To Console    Start Downlink Test Model ${USER_TM} for WCDMA cell ${WCDMA_cell_ID}${\n}
        ${start_tm_status}    ${start_tm_print}    Run Keyword And Ignore Error    admin.Start Wcdma Downlink Test    dist_name=${WCDMA_cell_ID}
        ...    uarfcn=${cell_parameters.defaultCarrier}    test_model=${USER_TM}    primary_scrambling_code=${scr_code_id}
        ...    number_of_dpch=${number_of_dpch}    number_of_hs_pdsch=${number_of_hs_pdsch}
        Run Keyword If    '${start_tm_status}'=='FAIL'  Fail  ${start_tm_print}
        ...  ELSE    Log To Console  Command Start Downlink Test Model ${USER_TM} for WCDMA cell ${WCDMA_cell_ID} has status ${start_tm_status}${\n}
        Sleep    10s
        Log To Console    Checking TX carriers with power after start ${USER_TM} for WCDMA cell ${WCDMA_cell_ID}:${\n}
        ${len_of_dict_after}  Check Number of Carriers  ${cellId}[1]
        ${diff}  Evaluate  (${len_of_dict_after} > ${len_of_dict_before})
        ${active_tm_list}=    ca_BSRF_WCDMA_Downlink_TestModels.Check If Test Model Is Active    tm_ON  ${WCDMA_cell_ID}
        Append to list  ${active_tm_list}  ${diff}
    END

    [Return]  ${active_tm_list}

Check If Test Model Is Active
    [Arguments]  ${tm_active_status}  ${WCDMA_cell_ID}
    [Documentation]
    ...  Check if test model is active
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW check if TM is Active in InfoModel and on RMOD carriers.
    ...  | KW check in Info Model if WCDMA_DOWNLINK_TEST has status Active. If TM is Active, KW append value "True" in list ${tm_status_list}.
    ...  | If TM is inActive, KW append value "False" in list ${tm_status_list}.
    ...  | KW check in SysLog if parameter totTrnsPwr for specific cellId has value 95 - 100 % for Active TM_1 (TM_3).
    ...  | If TM is Active, KW append value "True" in list ${tm_status_list}.
    ...  | If TM is inActive, KW append value "False" in list ${tm_status_list}.
    ...  | KW returns ${tm_status_list} containing items "True" and "False".
    ...
    ...  **Input Parameters:**
    ...
    ...  +--------------------+------+------------------------------------------+
    ...  | Parameter name     | Man. | Description                              |
    ...  +====================+======+==========================================+
    ...  | WCDMA_cell_ID      | yes  | WCDMA cell ID                            |
    ...  +--------------------+------+------------------------------------------+
    ...  | tm_active_status   | yes  | Test model status, e. g. tm_OFF, tm_ON   |
    ...  +--------------------+------+------------------------------------------+

    Log To Console    Checking If Test Model for ${WCDMA_cell_ID} is active in infomodel and on RMOD(s) !${\n}

    ${tm_status_list}=    Create List
    ${cellId}=    Split String    ${WCDMA_cell_ID}    separator=-
    ${active_tm_status}=    Run Keyword And Return Status    Wait until keyword succeeds  0 min  15 sec
    ...  ute_admin_infomodel.Query infomodel  query=check //${WCDMA_cell_ID}/WCDMA_DOWNLINK_TEST-* is [stateInfo.usageState=Active]
    Run Keyword If  '${active_tm_status}'=='False'  Log To Console  For WCDMAcell ${WCDMA_cell_ID}, ${USER_TM} Downlink Test Model is NOT active${\n}
    ...  ELSE    Log To Console
    ...  For WCDMA cell ${WCDMA_cell_ID}, ${USER_TM} Downlink Test Model is active in infomodel !${\n}Now checking power on RMOD, please wait!${\n}
    ${active_tm_rmod_status}  Run Keyword And Ignore Error  Check Power On RMOD  ${tm_active_status}  ${USER_TM}  ${cellId}[1]
    Run Keyword If    '${active_tm_rmod_status}[0]'=='PASS'    Log To Console    RMOD power validation OK !${\n}
    ...  ELSE    Log To Console    RMOD power validation incorrect !${\n}
    Run Keyword If    '${active_tm_rmod_status}[0]'=='PASS' and '${tm_active_status}'=='tm_ON'    Append To List    ${tm_status_list}    ${True}
    ...  ELSE IF  '${active_tm_rmod_status}[0]'=='PASS' and '${tm_active_status}'=='tm_OFF'    Append To List    ${tm_status_list}    ${False}
    ...  ELSE IF  '${active_tm_rmod_status}[0]'=='FAIL' and '${tm_active_status}'=='tm_OFF'  Append To List  ${tm_status_list}    ${True}
    ...  ELSE    Append To List    ${tm_status_list}    ${False}
    Append To List    ${tm_status_list}    ${active_tm_status}

    [Return]    ${tm_status_list}

Stop Downlink Test Model
    [Documentation]
    ...  Stop Downlink Test Model
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW stops active test models.

    Log To Console   Test model ${USER_TM} will be stopped for cell: \n${WCDMA_CELLS_ID_LIST}${\n}
    FOR    ${WCDMA_cell_ID}    IN    @{WCDMA_CELLS_ID_LIST}
        ${cellId}=    Split String    ${WCDMA_cell_ID}    separator=-
        ${WCDMA_cell_Id_str}=    Convert To String   ${WCDMA_cell_ID}
        ${WCDMA_cell_Id_scf_object}=    Replace String     ${WCDMA_cell_Id_str}    R    A
        ${cell_parameters}=    Get Infomodel Object    //${WCDMA_cell_Id_scf_object}
        Log To Console    Checking TX carriers with power before stop ${USER_TM} for WCDMA cell ${WCDMA_cell_ID}:${\n}
        ${len_of_dict_before}  Check Number of Carriers  ${cellId}[1]
        Set Test Variable  ${LEN_OF_DICT_BEFORE}
        Log To Console    Stop Downlink Test Model ${USER_TM} for WCDMA cell ${WCDMA_cell_ID}${\n}
        ${stop_tm_status}    Run Keyword And Return Status    admin.Stop Wcdma Downlink Test    ${WCDMA_cell_ID}
        Run Keyword If    '${stop_tm_status}'=='False'   Log To Console    No active Test Model ${USER_TM} for WCDMA cell ${WCDMA_cell_ID} to stoped
        ...  ELSE    Log To Console    Command Stop Downlink Test Model ${USER_TM} for WCDMA cell ${WCDMA_cell_ID} has status ${stop_tm_status}${\n}
        Log To Console    Checking TX carriers with power after stop ${USER_TM} for WCDMA cell ${WCDMA_cell_ID}:${\n}
        ${len_of_dict_after}  Check Number of Carriers  ${cellId}[1]
        ${diff}  Evaluate  (${len_of_dict_after} >= ${len_of_dict_before})
        ${not_active_tm_list}=    ca_BSRF_WCDMA_Downlink_TestModels.Check If Test Model Is Active    tm_OFF  ${WCDMA_cell_ID}
        Append to list  ${not_active_tm_list}  ${diff}
    END
    Log To Console    Test model ${USER_TM} for WCDMA cell ${WCDMA_CELLS_ID_LIST} was stopped succesfully !${\n}

    [Return]  ${not_active_tm_list}

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
    Set Test Variable  ${SHORT_WCDMA_CELLS_LIST}  ${user_WCDMA_cell_list}
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

    ${short_cells}  Create List
    @{WCDMA_CELLS_ID_LIST}=    admin.Get All Items By Class Name    WNCEL
    FOR  ${wncel_cell}  IN  @{WCDMA_CELLS_ID_LIST}
        ${cell}  Fetch From Right  ${wncel_cell}  -
        Append To List  ${short_cells}  ${cell}
    END

    Set Test Variable    ${WCDMA_CELLS_ID_LIST}
    Set Test Variable  ${SHORT_WCDMA_CELLS_LIST}  ${short_cells}

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
        Run Keyword If    not (0 <= ${primary_scr_code_value} <= 511)
        ...  Fail  Invalid value Primary scrambling code = ${primary_scr_code_value} - use values from 0 to 511!
    END
    Set Test Variable    ${PRIMARY_SCR_CODE}


Check MCP For Cells
    [Documentation]
    ...  KW checks Maximum Carrier Power for user defined WCDMA cells
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    ${whole_list}=  admin.Get Cell List
    ${mcp_dict}  Create Dictionary
    ${wcdma_cells_info}=  Evaluate  (${whole_list}\['cells']['wcdma'])

    FOR  ${cell_info}  IN  @{wcdma_cells_info}
      ${cell_id_from_admin}  Evaluate  str((${cell_info}\['cellId']))
      Continue For Loop If  '${cell_id_from_admin}' not in ${SHORT_WCDMA_CELLS_LIST}
      ${mcp}  Evaluate  float((${cell_info}\['maximumCarrierPower']))
      ${internal}  Evaluate  (${cell_info}\['carrierList'][0]['antennaLineId']['internal'])
      ${rmod_id}  Evaluate  '${internal}'.rsplit('/', 1)[0]
      Set To Dictionary  ${mcp_dict}  ${cell_id_from_admin}  ${mcp}
    END

    ${rmod_details}  admin.Get parameters For All  RMOD
    FOR  ${rmod}  IN  @{rmod_details}
        Continue For Loop If  '${rmod.id}'=='${rmod_id}'
        ${rmod_sn}  Set Variable  ${rmod.serialNumber}
        Exit For Loop
    END

    Set Test Variable  ${RMOD_ID}  ${rmod_id}
    Set Test Variable  ${RMOD_SN}  ${rmod_sn}
    Set Test Variable  ${CELL_MCP_DICT}  ${mcp_dict}

Get WCDMA TX Carriers Data
    [Arguments]  ${RMOD_ID}
    [Documentation]
    ...  KW gets WCDMA TX Carrier Power from RMOD
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    ${rmod_parameters}=  admin.Get Parameters For  RMOD  ${RMOD_ID}
    ${tx_power}  radio.Get Carriers Power
      ...  ru_serial_number=${rmod_parameters.serialNumber}
      ...  direction=TX
      ...  return_antennas=False

    Log To Console  WCDMA TX power collected successful !${\n}

    [Return]  ${tx_power}

Check Power On RMOD
    [Arguments]  ${power_status}  ${TM}  ${cell}
    [Documentation]
    ...  KW checks the condiiton depending on the given parameter
    ...  If ${power_status} is tm_ON KW perform Validate Power
    ...  If ${power_status} is tm_OFF KW checks if power on RMOD is less than was before deactivation.
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    ${rmod_ids}  Get From Dictionary  ${DICT_OF_CELLS}  ${cell}

    FOR  ${rmod}  IN  @{rmod_ids}
        ${tx_power}  Get WCDMA TX Carriers Data  ${rmod}
        ${values}  Get Dictionary Values  ${tx_power}
        ${values}  Evaluate  [i for i in ${values} if i !='OFF']
        ${len_of_dict}  Evaluate  len(${values})

        Run Keyword If  '${power_status}'=='tm_OFF'  Should be true  ${len_of_dict} < ${LEN_OF_DICT_BEFORE}
        ...  ELSE IF  '${power_status}'=='tm_ON'  Validate Power  ${tx_power}  ${TM}  ${cell}
    END

Validate Power
    [Arguments]  ${tx_power}  ${TM}  ${cell}
    [Documentation]
    ...  KW checks the length of dictionary with power
    ...  and perform power validation depending on the choosen TM
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    Log to console  Found following carriers on RMOD:
    Log to console  ---------------------------------${\n}

    FOR  ${carrier}  ${power}  IN ZIP  ${TX_POWER.keys()}  ${TX_POWER.values()}
        Log To Console  ${carrier}: ${power} dBm
    END

    Log to console  ${\n}---------------------------------${\n}

    ${power_in_dbm}  Get Dictionary Values  ${TX_POWER}
    ${power_in_dbm}  Evaluate  [i for i in ${power_in_dbm} if i !='OFF']
    ${not_empty_status}  Evaluate  len(${power_in_dbm})
    SHould Be True  ${not_empty_status} > 0

    ${mcp}  Get From Dictionary  ${CELL_MCP_DICT}  ${cell}

    Run Keyword If  '${TM}' in ['TM_1','TM_3','TM_5','TM_6']   Validate For TM_1_3_5_6  ${power_in_dbm}  ${mcp}
    ...  ELSE IF  '${TM}'=='TM_2'  Validate For TM_2  ${power_in_dbm}  ${mcp}
    ...  ELSE IF  '${TM}'=='TM_4'  Validate For TM_4  ${power_in_dbm}  ${mcp}

Validate For TM_1_3_5_6
    [Arguments]  ${power_in_dbm}  ${mcp}
    [Documentation]
    ...  KW validates power on RMOD for TM_1, TM_3, TM_5 and TM_6
    ...  Acceptable power range is +/- 0.5 dBm
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    ${min_allow}  Evaluate  ${mcp} - 0.5
    ${max_allow}  Evaluate  ${mcp} + 0.5

    FOR  ${value}  IN  @{power_in_dbm}
        ${in_range}  Evaluate  ${min_allow} <= ${value} <= ${max_allow}
        Should Be Equal  ${in_range}  ${True}
    END

Validate For TM_2
    [Arguments]  ${power_in_dbm}  ${mcp}
    [Documentation]
    ...  KW validates power on RMOD for TM_2
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    Run Keyword If  ${DPCH_POWER}==-3  Validate For TM_2 -3  ${power_in_dbm}  ${mcp}
    ...  ELSE IF  ${DPCH_POWER}==-28  Validate For TM_2 -28  ${power_in_dbm}  ${mcp}

Validate For TM_2 -3
    [Arguments]  ${power_in_dbm}  ${mcp}
    [Documentation]
    ...  KW validates power on RMOD for TM_2 and DPCH = -3
    ...  Acceptable power range is +/- 0.5 dBm
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    ${min_allow}  Evaluate  ${mcp} - 0.5
    ${max_allow}  Evaluate  ${mcp} + 0.5

    FOR  ${value}  IN  @{power_in_dbm}
        ${in_range}  Evaluate  ${min_allow} <= ${value} <= ${max_allow}
        Should Be Equal  ${in_range}  ${True}
    END

Validate For TM_2 -28
    [Arguments]  ${power_in_dbm}  ${mcp}
    [Documentation]
    ...  KW validates power on RMOD for TM_2 and DPCH = -28
    ...  Acceptable power range is +/- 0.2 dBm
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    ${cor_mcp}  Evaluate  ${mcp} - 3
    ${min_allow}  Evaluate  ${cor_mcp} - 0.2
    ${max_allow}  Evaluate  ${cor_mcp} + 0.2

    FOR  ${value}  IN  @{power_in_dbm}
        ${in_range}  Evaluate  ${min_allow} <= ${value} <= ${max_allow}
        Should Be Equal  ${in_range}  ${True}
    END

Validate For TM_4
    [Arguments]  ${power_in_dbm}  ${mcp}
    [Documentation]
    ...  KW validates power on RMOD for TM_4
    ...  Acceptable power range is +/- 1 dBm
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    ${exp_power}  Evaluate  ${PCCPCH_SCH_POWER}+${mcp}+3
    ${min_allow}  Evaluate  ${exp_power} - 1
    ${max_allow}  Evaluate  ${exp_power} + 1

    FOR  ${value}  IN  @{power_in_dbm}
        ${in_range}  Evaluate  ${min_allow} <= ${value} <= ${max_allow}
        Should Be Equal  ${in_range}  ${True}
    END

Check Number of Carriers
    [Arguments]  ${cell}
    [Documentation]
    ...  KW checks number of carriers on RMOD(s)
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    ${rmod_ids}  Get From Dictionary  ${DICT_OF_CELLS}  ${cell}
    ${sum_len}  Set Variable  ${0}

    FOR  ${rmod}  IN  @{rmod_ids}
        ${tx_power}  Get WCDMA TX Carriers Data  ${rmod}
        ${values}  Get Dictionary Values  ${tx_power}
        ${values}  Evaluate  [i for i in ${values} if i !='OFF']
        ${len}  Evaluate  len(${values})
        ${sum_len}  Evaluate  ${sum_len}+${len}
    END

    [Return]  ${len}

Check TX Antenna Lines For WNCEL
    [Documentation]
    ...  KW create dictionary with cell : rmod_distnames (key : [values])
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    ${rmod_ant_dict}  Create Dictionary
    ${rmod_ant_list}  Create list
    ${whole_list}=  admin.Get Cell List
    ${wcdma_cells_info}=  Evaluate  (${whole_list}\['cells']['wcdma'])

    ${dict_of_cells}  Evaluate  ({i:[] for i in ${SHORT_WCDMA_CELLS_LIST}})
    Set Test Variable  ${DICT_OF_CELLS}

    FOR  ${cell_info}  IN  @{wcdma_cells_info}
      ${cell_id_from_admin}  Evaluate  str(${cell_info}\['cellId'])
      Continue For Loop If  '${cell_id_from_admin}' not in ${SHORT_WCDMA_CELLS_LIST}
      ${carriers_list}  Evaluate  (${cell_info}\['carrierList'])
      ca_BSRF_WCDMA_Downlink_TestModels.Carrier List Iterator For TX Antenna Lines  ${carriers_list}  ${cell_id_from_admin}
    END

Carrier List Iterator For TX Antenna Lines
    [Arguments]  ${carrier_list}  ${cell}
    [Documentation]
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    ${temp_dict}  Create Dictionary
    FOR  ${carrier}  IN  @{carrier_list}
        ${direction}  Get From Dictionary  ${carrier}  direction
        Continue For Loop If  '${direction}'!='TX'
        ${rmod_id}  Evaluate  (${carrier}\['antennaLineId']['internal'])
        ${rmod_distname}  Evaluate  '${rmod_id}'.rsplit('/', 1)[0]
        Run Keyword If  '${rmod_distname}' not in ${DICT_OF_CELLS}[${cell}]  Append to List  ${DICT_OF_CELLS}[${cell}]  ${rmod_distname}
    END


