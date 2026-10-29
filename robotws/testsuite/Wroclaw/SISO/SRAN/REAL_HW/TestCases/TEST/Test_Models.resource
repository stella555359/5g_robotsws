*** Settings ***
Documentation
...  Resource for Simultaneously NR LTE TestModels

*** Keywords ***

Step${step_number}: Check Input Data for NR Downlink Test Model

    ## NR ##
    Set Test Variable  @{NR_DL_TM_LIST}   TM1_1  TM1_2  TM2  TM2A  TM3_1  TM3_1A  TM3_2  TM3_3  TM3_1N
    @{BEAM_PATTERN_ID}  Create list  ${1}
    Set Test Variable  ${BEAM_PATTERN_ID}
    Set Test Variable  ${POLARIZATION}  P_both
    Set Test Variable  ${POWER_BACKOFF}  0
    Set Test Variable  ${RU_MODE}  NR_Only
    Set Test Variable  ${PHY_NR_CELL_ID}  1  #Default values Physical Cell Id
    Set Test Variable  ${codebook_2_antports}  0
    Set Test Variable  ${i11_codebook_4_antports}  0
    Set Test Variable  ${i2_codebook_4_antports}  0
    Set Test Variable  ${i13_codebook_4_antports}  0
    Set Test Variable  ${MIMO_RANK}  1

    Logging With Timestamp
    ...  message=Step${step_number}: Check Input Data for NR Downlink Test Model
    ...  style=STEP
    ...  frame=${TRUE}

    Set Test Variable  ${USER_NR_DL_TM}
    ${tm_select_status}  Run Keyword And Return Status  Should Contain  ${NR_DL_TM_LIST}  ${USER_NR_DL_TM}
    IF  ${tm_select_status}==False
      Fail  Input name Test Model '${USER_NR_DL_TM}' is incorrect. Possible input is one element from the list: ${NR_DL_TM_LIST}
    END
    IF  '${USER_NR_CELL}'=='${EMPTY}'
      Test_Models.Get Ids For All NR Cells
    ELSE
      Test_Models.Get Ids For User NR Cell
    END
    Logging With Timestamp  NR Downlink Test Model ${USER_NR_DL_TM} will be performed for Cell:\n${NR_CELLS_ID_LIST}

Step${step_number}: Check Input Data for NR Uplink Test Model

    Set Test Variable  @{NR_UL_TM_LIST}   G_FR1_A1_1  G_FR1_A1_2  G_FR1_A1_4  G_FR1_A1_5  G_FR1_A1_7
    ...  G_FR1_A2_1  G_FR1_A2_4  G_FR1_A2_5  GFR2_A1_2  G_FR2_A1_3
    Set Test Variable  ${INTERVAL}  1
    Set Test Variable  ${PRB_OFFSET}  0

    Logging With Timestamp
    ...  message=Step${step_number}: Check Input Data for NR Uplink Test Model
    ...  style=STEP
    ...  frame=${TRUE}

    Set Test Variable  ${USER_NR_UL_TM}
    ${tm_select_status}  Run Keyword And Return Status  Should Contain  ${NR_UL_TM_LIST}  ${USER_NR_UL_TM}
    IF  ${tm_select_status}==False
      Fail  Input name Test Model '${USER_NR_UL_TM}' is incorrect. Possible input is one element from the list: ${LTE_UL_TM_LIST}
    END
    Logging With Timestamp  LTE Uplink Test Model ${USER_NR_UL_TM} will be performed for Cell:\n${NR_CELLS_ID_LIST}
    Logging With Timestamp  LTE Uplink Test Model ${USER_NR_UL_TM} will be performed for Resource Block Offset -> ${PRB_OFFSET}

Step${step_number}: Check Input Data for LTE Downlink Test Model
    ## LTE ##
    Set Test Variable  @{LTE_DL_TM_LIST}   E_TM1_1  E_TM1_2  E_TM2  E_TM2a  E_TM3_1a  E_TM3_1  E_TM3_2  E_TM3_3
    Set Test Variable  ${PHY_CELL_ID}  1    #Default values Physical Cell Id

    Set Test Variable  @{LTE_UL_TM_LIST}   A1_1  A1_2  A1_3  A1_4  A1_5  A2_1  A2_2  A2_3
    Set Test Variable  ${RB_OFFSET_ID}    0    #Default values Resource block offset
    Set Test Variable  @{A1_1}         1.4 MHz    #Allowed cell bandwidth
    Set Test Variable  @{A1_2}         3 MHz  5 MHz    #Allowed cell bandwidth
    Set Test Variable  @{A1_3}         5 MHz  10 MHz  15 MHz  20 MHz    #Allowed cell bandwidth
    Set Test Variable  @{A1_4}         1.4 MHz    #Allowed cell bandwidth
    Set Test Variable  @{A1_5}         3 MHz    #Allowed cell bandwidth
    Set Test Variable  @{A2_1}         1.4 MHz    #Allowed cell bandwidth
    Set Test Variable  @{A2_2}         3 MHz    #Allowed cell bandwidth
    Set Test Variable  @{A2_3}         5 MHz  10 MHz  15 MHz  20 MHz    #Allowed cell bandwidth

    Logging With Timestamp
    ...  message=Step${step_number}: Check Input Data for LTE Downlink Test Model
    ...  style=STEP
    ...  frame=${TRUE}

    Set Test Variable  ${USER_LTE_DL_TM}
    ${tm_select_status}  Run Keyword And Return Status  Should Contain  ${LTE_DL_TM_LIST}  ${USER_LTE_DL_TM}
    IF  ${tm_select_status}==False
      Fail  Input name Test Model '${USER_LTE_DL_TM}' is incorrect. Possible input is one element from the list: ${LTE_DL_TM_LIST}
    END
    IF  '${USER_LTE_CELL}'=='${EMPTY}'
      Test_Models.Get Ids For All LTE Cells
    ELSE
      Test_Models.Get Ids For User LTE Cell
    END
    Logging With Timestamp  LTE Downlink Test Model ${USER_LTE_DL_TM} will be performed for Cell:\n${LTE_CELLS_ID_LIST}
    Logging With Timestamp  LTE Downlink Test Model ${USER_LTE_DL_TM} will be performed for Physical cell ID -> ${PHY_CELL_ID}

Step${step_number}: Check Input Data for LTE Uplink Test Model

    Logging With Timestamp
    ...  message=Step${step_number}: Check Input Data for LTE Uplink Test Model
    ...  style=STEP
    ...  frame=${TRUE}
    Set Test Variable  ${USER_LTE_UL_TM}
    ${tm_select_status}  Run Keyword And Return Status  Should Contain  ${LTE_UL_TM_LIST}  ${USER_LTE_UL_TM}
    IF  ${tm_select_status}==False
      Fail  Input name Test Model '${USER_LTE_UL_TM}' is incorrect. Possible input is one element from the list: ${LTE_UL_TM_LIST}
    END
    Logging With Timestamp  LTE Uplink Test Model ${USER_LTE_UL_TM} will be performed for Cell:\n${LTE_CELLS_ID_LIST}
    Test_Models.Check Possibility Run LTE Test Model
    Logging With Timestamp  LTE Uplink Test Model ${USER_LTE_UL_TM} will be performed for Resource Block Offset -> ${RB_OFFSET_ID}

Step${step_number}: Start Dedicated State

    Logging With Timestamp
    ...  message=Step${step_number}: Start Dedicated State
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp  Reset to Test Dedicated State

    ${is_lte}  Run Keyword And Return Status  admin.Get Ids For All  class_name=LNCEL  search_for_iot_cells=${True}  connection=${BTS_ID}
    admin.Reset To Test Dedicated  connection=${BTS_ID}
    ${TDS_status}  Run Keyword And Return Status  Test_Models.Check if BTS is in Test Dedicated State  ${is_lte}
    IF  ${TDS_status}==False
      Fail  Problem with enter to Test Dedicated State
    END
    Logging With Timestamp  BTS is in Test Dedicated State

Check if BTS is in Test Dedicated State
    [Arguments]  ${is_lte}
    [Documentation]
    ...  KW verifies that the target MRBTS (BTS) reaches the **Test (Test Dedicated)** procedural state.
    ...  If LTE is present (is_lte=True), it additionally verifies that all **LNCEL** objects reach
    ...  a **Prevalidated** procedural state.
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+---------------------------------------------------------------+
    ...  | Parameter        | Man. | Description                                                   |
    ...  +==================+======+===============================================================+
    ...  | is_lte           | Yes  | Boolean. If True, assert all LNCEL reach 'Prevalidated'.      |
    ...  +------------------+------+---------------------------------------------------------------+

    Logging With Timestamp  Reset To Test Dedicated Test procedure completed, waiting for MRBTS state -> Test ...
    Wait Until Keyword Succeeds  10min  10s  STATE Verify BTS Procedural State  expected_BTS_status=Test  node_id=${BTS_ID}

    IF  ${is_lte}
      Wait Until Keyword Succeeds  5m  10s  admin.Assert Every
      ...  class_name=LNCEL
      ...  proceduralState=regex"(?i)Prevalidated"
      ...  search_for_iot_cells=${False}
      ...  connection=${BTS_ID}
    END

Step${step_number}: Start Test Models

    Logging With Timestamp
    ...  message=Step${step_number}: Start Test Models
    ...  style=STEP
    ...  frame=${TRUE}

    IF  '5G' in '${USER_RAT_TO_LAUNCH}'
      Test_Models.Start Downlink NR Test Model
      Test_Models.Start Uplink NR Test Model
    END
    IF  '4G' in '${USER_RAT_TO_LAUNCH}'
      Test_Models.Start Downlink LTE Test Model  ${phy_cell_id}
      Test_Models.Start Uplink LTE Test Model  ${rb_offset_id}
    END

Step${step_number}: Check Test Models Status After Start

    Logging With Timestamp
    ...  message=Step${step_number}: Check Test Models Status After Start
    ...  style=STEP
    ...  frame=${TRUE}

    ${active_DL_NR_tm_list}  Run Keyword If  '5G' in '${USER_RAT_TO_LAUNCH}'
    ...  Test_Models.Check Active Downlink Test Models  rat=NR
    ${active_UL_NR_tm_list}  Run Keyword If  '5G' in '${USER_RAT_TO_LAUNCH}'
    ...  Test_Models.Check Active NR Uplink Test Models
    ${active_DL_LTE_tm_list}  Run Keyword If  '4G' in '${USER_RAT_TO_LAUNCH}'
    ...  Test_Models.Check Active Downlink Test Models  rat=LTE
    ${active_UL_LTE_tm_list}  Run Keyword If  '4G' in '${USER_RAT_TO_LAUNCH}'
    ...  Test_Models.Check Active LTE Uplink Test Models  ${rb_offset_id}  check_active_tm_info=after start TM action

    IF  '5G' in '${USER_RAT_TO_LAUNCH}'
      Check Test Model Status After Start  DL_tm=${active_DL_NR_tm_list}  UL_tm=${active_UL_NR_tm_list}  rat=NR
    ELSE IF  '4G' in '${USER_RAT_TO_LAUNCH}'
      Check Test Model Status After Start  DL_tm=${active_DL_LTE_tm_list}  UL_tm=${active_UL_LTE_tm_list}  rat=LTE
    END

Step${step_number}: Stop Test Models

    Logging With Timestamp
    ...  message=Step${step_number}: Stop Test Models
    ...  style=STEP
    ...  frame=${TRUE}

    IF  '5G' in '${USER_RAT_TO_LAUNCH}'
      Test_Models.Stop Downlink NR Test Model
      Test_Models.Stop Uplink NR Test Model
    ELSE IF  '4G' in '${USER_RAT_TO_LAUNCH}'
      Test_Models.Stop Uplink LTE Test Model  ${rb_offset_id}
      Test_Models.Stop Downlink LTE Test Model  ${phy_cell_id}
    END

Step${step_number}: Check Test Models Status After Stop

    Logging With Timestamp
    ...  message=Step${step_number}: Check Test Models Status After Stop
    ...  style=STEP
    ...  frame=${TRUE}

    ${inactive_DL_NR_tm_list}  Run Keyword If  '5G' in '${USER_RAT_TO_LAUNCH}'
    ...  Test_Models.Check Active Downlink Test Models  rat=NR
    ${inactive_UL_NR_tm_list}  Run Keyword If  '5G' in '${USER_RAT_TO_LAUNCH}'
    ...  Test_Models.Check Active NR Uplink Test Models

    ${inactive_DL_LTE_tm_list}  Run Keyword If  '4G' in '${USER_RAT_TO_LAUNCH}'
    ...  Test_Models.Check Active Downlink Test Models  rat=LTE
    ${inactive_UL_LTE_tm_list}  Run Keyword If  '4G' in '${USER_RAT_TO_LAUNCH}'
    ...  Test_Models.Check Active LTE Uplink Test Models  ${rb_offset_id}  check_active_tm_info=after stop TM action

    IF  '5G' in '${USER_RAT_TO_LAUNCH}'
      Check Test Model Status After Stop  DL_tm=${inactive_DL_NR_tm_list}  UL_tm=${inactive_UL_NR_tm_list}  rat=NR
    ELSE IF  '4G' in '${USER_RAT_TO_LAUNCH}'
      Check Test Model Status After Stop  DL_tm=${inactive_DL_LTE_tm_list}  UL_tm=${inactive_UL_LTE_tm_list}  rat=LTE
    END

Step${step_number}: Exit Test Dedicated State via WebEM

    Logging With Timestamp
    ...  message=Step${step_number}: Exit Test Dedicated State via WebEM
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp  Exiting Test Dedicated State...
    admin.Reset Site  timeout=1200  connection=${BTS_ID}
    Wait Until Keyword Succeeds  40min  10s  STATE Verify BTS Procedural State  expected_BTS_status=OnAir  node_id=${BTS_ID}

    ${cell_status}  Run Keyword And Return Status  STATE Check If All Cells Are OnAir  ${BTS_ID}  timeout=500
    IF  '${cell_status}'=='True'
      Logging With Timestamp  All cells are onAir !${\n}
    ELSE
      Fail  Cells doesn't reach onAir state!
    END

Get RMOD Id And Ants For Cell
    [Arguments]  ${cell}
    [Documentation]
    ...  KW retrieves the **RMOD identifier** and the list of **antenna lines** on which the specified cell is deployed.
    ...  It queries cell-specific information, extracts carrier details, filters for TX direction,
    ...  and returns a unique list of antenna line IDs along with the RMOD ID derived from the first antenna line.
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+---------------------------------------------------------------+
    ...  | Parameter        | Man. | Description                                                   |
    ...  +==================+======+===============================================================+
    ...  | cell             | Yes  | Cell id                                                       |
    ...  +------------------+------+---------------------------------------------------------------+

    ${cell_info}  admin.Get Cell Specific Info  cell_id=${cell}  connection=${BTS_ID}
    ${carriers}  Get From Dictionary  ${cell_info}  carrierList

    ${ants_list}  Create List
    FOR  ${carrier}  IN  @{carriers}
      Continue For Loop If  '${carrier['direction']}'!='TX'
      Append To List  ${ants_list}  ${carrier['antennaLineId']['internal']}
    END

    ${ants_list}  Remove Duplicates  ${ants_list}
    ${rmod_id}  Evaluate  '${ants_list}[0]'.rsplit('/',1)[0]

    [Return]  ${rmod_id}  ${ants_list}

Check Test Model Status After Start
    [Arguments]  ${DL_tm}  ${UL_tm}  ${rat}
    [Documentation]
    ...  KW verifies that **Test Model (TM)** activation succeeded for both **Downlink (DL)** and
    ...  **Uplink (UL)** on the selected cells for the specified **RAT**.
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+------------------------------------------------------------------+
    ...  | Parameter        | Man. | Description                                                      |
    ...  +==================+======+==================================================================+
    ...  | DL_tm            | Yes  | Status/result string for Downlink TM activation.                 |
    ...  | UL_tm            | Yes  | Status/result string for Uplink TM activation.                   |
    ...  | rat              | Yes  | RAT identifier                                                   |
    ...  +------------------+------+------------------------------------------------------------------+

    ${DL_tm_status}  Run Keyword And Return Status  Should Not Contain  ${DL_tm}  FAIL
    IF  '${DL_tm_status}'=='False'
      Fail  ${USER_${rat}_DL_TM} Downlink TM was not activated on all selected ${rat} cells
    END

    ${UL_tm_status}  Run Keyword And Return Status  Should Not Contain  ${UL_tm}  FAIL
    IF  '${UL_tm_status}'=='False'
      Fail  ${USER_${rat}_UL_TM} Uplink TM was not activated on all selected ${rat} cells
    END

Check Test Model Status After Stop
    [Arguments]  ${DL_tm}  ${UL_tm}  ${rat}
    [Documentation]
    ...  KW verifies that **Test Model (TM)** deactivation succeeded for both **Downlink (DL)** and
    ...  **Uplink (UL)** on the selected cells for the specified **RAT**.
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+------------------------------------------------------------------+
    ...  | Parameter        | Man. | Description                                                      |
    ...  +==================+======+==================================================================+
    ...  | DL_tm            | Yes  | Status/result string for Downlink TM after stop.                 |
    ...  | UL_tm            | Yes  | Status/result string for Uplink TM after stop.                   |
    ...  | rat              | Yes  | RAT identifier                                                   |
    ...  +------------------+------+------------------------------------------------------------------+

    ${DL_tm_status}  Run Keyword And Return Status  Should Not Contain  ${DL_tm}  PASS
    IF  '${DL_tm_status}'=='False'
      Fail  ${USER_${rat}_DL_TM} Downlink TM was not activated on all selected ${rat} cells
    END

    ${UL_tm_status}  Run Keyword And Return Status  Should Not Contain  ${UL_tm}  PASS
    IF  '${UL_tm_status}'=='False'
      Fail  ${USER_${rat}_UL_TM} Uplink TM was not activated on all selected ${rat} cells
    END

Start Downlink NR Test Model
    [Documentation]
    ...  Start Downlink NR Test Model procedure
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW launch NR Downlink test models and logs tx power for all RU in configuration.
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+--------------------------------+
    ...  | Parameter name | Man. | Description                    |
    ...  +================+======+================================+
    ...  | phy_cell_id    | yes  | Physical Cell Id               |
    ...  +----------------+------+--------------------------------+
    ...  | USER_LTE_DL_TM | yes  | Tesy model from LTE_DL_TM_LIST |
    ...  +----------------+------+--------------------------------+

    ${sum_of_ants}  Create List
    Logging With Timestamp  NR Test model ${USER_NR_DL_TM} will be started for cell: \n${NR_CELLS_ID_LIST}
    FOR  ${NR_cell_ID}  IN  @{NR_CELLS_ID_LIST}
      ${cell_parameters}  admin.Get Parameters For  class_name=NRCEL  id_num=${NR_cell_ID}  connection=${BTS_ID}
      ${rmod_id}  ${ants_list}  Get RMOD Id And Ants For Cell  cell=${NR_cell_ID}
      ${diff_ants}  Evaluate  list(set(${ants_list})-set(${sum_of_ants}))
      ${sum_of_ants}  Combine Lists  ${sum_of_ants}  ${ants_list}
      ${rmod_sn}  RM Get RU Serial Number For DistName  rmod_id=${rmod_id}  connection=${BTS_ID}
      IF  '${cfg.RF_INFO['${rmod_sn}']['scf_release_code']}'!='RRH-ORAN'
        Logging With Timestamp  Power before Start 5G Downlink Test Model ${USER_NR_DL_TM} for ${cell_parameters.cellName}
        RM Log All TX Antenna Lines Power  connection=${BTS_ID}
        ${power_before_start}  Get TX Pipes Power From DAPD  ${rmod_sn}
      END
      Logging With Timestamp  Start 5G Downlink Test Model ${USER_NR_DL_TM} for ${cell_parameters.cellName}
      admin.Start 5G Downlink Test  ${NR_cell_id}  ${USER_NR_DL_TM}  ${BEAM_PATTERN_ID}  ${POLARIZATION}  ${POWER_BACKOFF}  ${RU_MODE}
      ...  ${PHY_NR_CELL_ID}  ${codebook_2_antports}  ${i11_codebook_4_antports}
      ...  ${i2_codebook_4_antports}  ${i13_codebook_4_antports}  ${MIMO_RANK}  connection=${BTS_ID}
      Sleep  10s
      IF  '${cfg.RF_INFO['${rmod_sn}']['scf_release_code']}'!='RRH-ORAN'
        Logging With Timestamp  Power after Start 5G Downlink Test Model ${USER_NR_DL_TM} for ${cell_parameters.cellName}
        RM Log All TX Antenna Lines Power  connection=${BTS_ID}
        ${power_after_start}  Get TX Pipes Power From DAPD  ${rmod_sn}
        Compare Power For 5G TM  ${power_before_start}  ${power_after_start}  ${diff_ants}
      END
    END

    Set Test Variable  ${sum_of_ants}

Compare Power For 5G TM
    [Arguments]  ${first_dict}  ${second_dict}  ${sum_of_ants}
    [Documentation]
    ...  KW compares the difference in antenna lines without TX power between two states (before and after
    ...  a 5G Test Model activation/deactivation) and validates that the difference equals the expected
    ...  number of antenna lines. This ensures that TX power is properly restored or removed on all antennas.
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+------------------------------------------------------------------+
    ...  | Parameter        | Man. | Description                                                      |
    ...  +==================+======+==================================================================+
    ...  | first_dict       | Yes  | Dictionary of antenna states before the operation                |
    ...  | second_dict      | Yes  | Dictionary of antenna states after the operation.                |
    ...  | sum_of_ants      | Yes  | List of all antenna lines expected to have TX power restored     |
    ...  +------------------+------+------------------------------------------------------------------+

    ${first_values}  Get Dictionary Values  ${first_dict}
    ${second_values}  Get Dictionary Values  ${second_dict}

    ${off_ants_first}  Get Match Count  ${first_values}  OFF
    ${off_ants_second}  Get Match Count  ${second_values}  OFF

    ${diff}  Evaluate  ${off_ants_first}-${off_ants_second}

    ${ants_count}  Get Length  ${sum_of_ants}

    Run Keyword And Continue On Failure
    ...  Should Be Equal  ${diff}  ${ants_count}
    ...  Lack of TX power on antenna lines !${\n}Power on ${diff} ants, must be on ${ants_count}!${\n}

Stop Downlink NR Test Model
    [Documentation]
    ...  Stop Downlink NR Test Model
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW stops active NR test models.

    Logging With Timestamp  Test model ${USER_NR_DL_TM} will be stopped for cell: \n${NR_CELLS_ID_LIST}
    FOR  ${NR_cell_ID}  IN  @{NR_CELLS_ID_LIST}
      ${cell_parameters}  admin.Get Parameters For  class_name=NRCEL  id_num=${NR_cell_ID}  connection=${BTS_ID}
      ${rmod_id}  ${ants_list}  Get RMOD Id And Ants For Cell  cell=${NR_cell_ID}
      ${rmod_sn}  RM Get RU Serial Number For DistName  rmod_id=${rmod_id}  connection=${BTS_ID}
      IF  '${cfg.RF_INFO['${rmod_sn}']['scf_release_code']}'!='RRH-ORAN'
        Logging With Timestamp  Power before Stop Downlink Test Model ${USER_NR_DL_TM} for NR cell ${cell_parameters.cellName}
        RM Log All TX Antenna Lines Power  connection=${BTS_ID}
        ${power_before_stop}  Get TX Pipes Power From DAPD  ${rmod_sn}
      END
      Logging With Timestamp  Stop Downlink Test Model ${USER_NR_DL_TM} for NR cell ${cell_parameters.cellName}
      ${stop_tm_status}  Run Keyword And Return Status  admin.Stop 5G Downlink Test  ${NR_cell_ID}  connection=${BTS_ID}
      IF  '${stop_tm_status}'=='False'
        Logging With Timestamp  No active Test Model ${USER_NR_DL_TM} for ${cell_parameters.cellName} to stoped
      END
      Sleep  10s
      IF  '${cfg.RF_INFO['${rmod_sn}']['scf_release_code']}'!='RRH-ORAN'
        Logging With Timestamp  Power after Stop Downlink Test Model ${USER_NR_DL_TM} for ${cell_parameters.cellName}
        RM Log All TX Antenna Lines Power  connection=${BTS_ID}
      END
    END

    ${active_tm}  admin.Get Active Tests  connection=${BTS_ID}
    Logging With Timestamp  Test model ${USER_NR_DL_TM} for NR cell ${NR_CELLS_ID_LIST} was stopped succesfully.

Start Uplink NR Test Model
    [Documentation]
    ...  Start Uplink NR Test Model procedure
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW starts NR uplink test model on selected NR cells.
    ...
    ...  **Input Parameters:**

    Logging With Timestamp  Test model ${USER_NR_UL_TM} will be started for cell: \n${NR_CELLS_ID_LIST}
    FOR  ${NR_cell_ID}  IN  @{NR_CELLS_ID_LIST}
      ${cell_parameters}  admin.Get Parameters For  class_name=NRCEL  id_num=${NR_cell_ID}  connection=${BTS_ID}
      Logging With Timestamp  Start 5G Uplink Test Model ${USER_NR_UL_TM} for NR cell ${cell_parameters.cellName}
      admin.Start 5G Uplink Test  ${NR_cell_ID}  ${USER_NR_UL_TM}  ${BEAM_PATTERN_ID}  ${INTERVAL}  ${PRB_OFFSET}
      ...  ${RU_MODE}  ${PHY_NR_CELL_ID}  connection=${BTS_ID}
    END

Stop Uplink NR Test Model
    [Documentation]
    ...  Stop Uplink NR Test Model
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW stops active test models.
    ...
    ...  **Input Parameters:**

    Logging With Timestamp  Test model ${USER_NR_UL_TM} will be stopped for cell: \n${NR_CELLS_ID_LIST}
    FOR  ${NR_cell_ID}  IN  @{NR_CELLS_ID_LIST}
      ${cell_parameters}  admin.Get Parameters For  class_name=NRCEL  id_num=${NR_cell_ID}  connection=${BTS_ID}
      Logging With Timestamp  Stop Uplink 5G Test Model ${USER_NR_UL_TM} for ${cell_parameters.cellName}
      ${stop_tm_status}  Run Keyword And Return Status  admin.Stop 5G Uplink Test  ${NR_cell_ID}  connection=${BTS_ID}
      IF  '${stop_tm_status}'=='False'
        Logging With Timestamp  No active Test Model ${USER_NR_UL_TM} for ${cell_parameters.cellName} to stopped
      ELSE IF  '${stop_tm_status}'=='True'
        Logging With Timestamp  Test model ${USER_NR_UL_TM} for ${cell_parameters.cellName} was stopped succesfully.
      END
      Sleep  10s
    END

Start Downlink LTE Test Model
    [Arguments]  ${phy_cell_id}
    [Documentation]
    ...  Start Downlink LTE Test Model procedure
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW start downlink LTE test model.
    ...  | KW set test to Fail, when meet some problem with start LTE downlink test.
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+--------------------------------+
    ...  | Parameter name | Man. | Description                    |
    ...  +================+======+================================+
    ...  | phy_cell_id    | yes  | Physical Cell Id               |
    ...  +----------------+------+--------------------------------+
    ...  | USER_LTE_DL_TM | yes  | Tesy model from LTE_DL_TM_LIST |
    ...  +----------------+------+--------------------------------+

    Logging With Timestamp  ${\n}LTE Test model ${USER_LTE_DL_TM} will be started for cell: \n${LTE_CELLS_ID_LIST}
    FOR  ${LTE_cell_ID}  IN  @{LTE_CELLS_ID_LIST}
      ${cell_name}  Evaluate  '${LTE_cell_ID}'.split('/')[-1]
      ${cell_parameters}  admin.Get Parameters For  class_name=LNCEL  id_num=${LTE_cell_ID}  connection=${BTS_ID}
      Logging With Timestamp  Start Downlink Test Model ${USER_LTE_DL_TM} for LTE cell ${cell_name}
      admin.Start Downlink Test  ${LTE_cell_ID}  ${USER_LTE_DL_TM}  ${cell_parameters.earfcnDL}  phy_cell_id=${phy_cell_id}  connection=${BTS_ID}
    END

Start Uplink LTE Test Model
    [Arguments]  ${rb_offset_id}
    [Documentation]
    ...  Start Uplink LTE Test Model procedure
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

    Logging With Timestamp  Test model ${USER_LTE_UL_TM} will be started for cell: \n${LTE_CELLS_ID_LIST}
    FOR  ${LTE_cell_ID}  IN  @{LTE_CELLS_ID_LIST}
      ${cell_parameters}  admin.Get Parameters For  class_name=LNCEL  id_num=${LTE_cell_ID}  connection=${BTS_ID}
      ${cell_name}  Evaluate  '${LTE_cell_ID}'.split('/')[-1]
      Logging With Timestamp  Start Uplink Test Model ${USER_LTE_UL_TM} for LTE cell ${cell_name}
      admin.Start Uplink Test  ${LTE_cell_ID}  ${USER_LTE_UL_TM}  1  ${rb_offset_id}  ${cell_parameters.earfcnUL}  BinaryHarq  connection=${BTS_ID}
    END

Stop Uplink LTE Test Model
    [Arguments]  ${rb_offset_id}
    [Documentation]
    ...  Stop Uplink LTE Test Model
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

    Logging With Timestamp  Test model ${USER_LTE_UL_TM} will be stopped for cell: \n${LTE_CELLS_ID_LIST}
    FOR  ${LTE_cell_ID}  IN  @{LTE_CELLS_ID_LIST}
      ${cell_parameters}  admin.Get Parameters For  class_name=LNCEL  id_num=${LTE_cell_ID}  connection=${BTS_ID}
      Logging With Timestamp  Stop Uplink Test Model ${USER_LTE_UL_TM} for LTE cell ${cell_parameters.id}
      ${stop_tm_status}  Run Keyword And Return Status  admin.Stop Uplink Test  ${LTE_cell_ID}  connection=${BTS_ID}
      IF  '${stop_tm_status}'=='False'
        Logging With Timestamp  No active Test Model ${USER_LTE_UL_TM} for LTE cell ${cell_parameters.id} to stopped
      ELSE IF  '${stop_tm_status}'=='True'
        Logging With Timestamp  Test model ${USER_LTE_UL_TM} for LTE cell ${LTE_cell_ID} was stopped succesfully
      END
      Sleep  10s
    END

Stop Downlink LTE Test Model
    [Arguments]  ${phy_cell_id}
    [Documentation]
    ...  Stop Downlink LTE Test Model
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

    Logging With Timestamp  Test model ${USER_LTE_DL_TM} will be stopped for cell: \n${LTE_CELLS_ID_LIST}
    FOR  ${LTE_cell_ID}  IN  @{LTE_CELLS_ID_LIST}
      ${cell_parameters}  admin.Get Parameters For  class_name=LNCEL  id_num=${LTE_cell_ID}  connection=${BTS_ID}
      Logging With Timestamp  Stop Downlink Test Model ${USER_LTE_DL_TM} for LTE cell ${cell_parameters.id}
      ${stop_tm_status}  Run Keyword And Return Status  admin.Stop Downlink Test  ${LTE_cell_ID}  connection=${BTS_ID}
      IF  '${stop_tm_status}'=='False'
        Logging With Timestamp  No active Test Model ${USER_LTE_DL_TM} for LTE cell ${cell_parameters.id} to stoped
      END
    END
    ${active_tm}  admin.Get Active Tests  connection=${BTS_ID}
    Logging With Timestamp  Test model ${USER_LTE_DL_TM} for LTE cell ${LTE_CELLS_ID_LIST} was stopped succesfully.

Check Active Downlink Test Models
    [Arguments]  ${rat}
    [Documentation]
    ...  Check Active NR Downlink Test Models procedure
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW check if NR TM is Active in Admin Api.
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

    Logging With Timestamp  Checking active ${rat} Downlink Test Models ...${\n}
    IF  '${rat}'=='NR'
      ${number_cells}  Get Length  ${NR_CELLS_ID_LIST}
    ELSE
      ${number_cells}  Get Length  ${LTE_CELLS_ID_LIST}
    END
    Sleep  10s
    ${active_tm}  admin.Get Active Tests  connection=${BTS_ID}
    ${active_tm_str}  Convert To String  ${active_tm}
    IF  '${rat}'=='NR'
      ${active_downlink_tm}  Get Regexp Matches  ${active_tm_str}  NR_DOWNLINK
    ELSE
      ${active_downlink_tm}  Get Regexp Matches  ${active_tm_str}  LTE_DOWNLINK
    END
    ${active_tm_status}  ${active_tm_msg}  Run Keyword And Ignore Error
    ...  Should Not Be Empty  ${active_tm}  msg=No active ${rat} Downlink Test Models
    IF  '${active_tm_status}'=='FAIL'  Logging With Timestamp  ${active_tm_msg}
    ${active_tm_status}  ${active_tm_msg}  Run Keyword And Ignore Error
    ...  Length Should Be  ${active_downlink_tm}  ${number_cells}  msg=Tested ${rat} Downlink Test Model is not active on all chosen cells
    IF  '${active_tm_status}'=='FAIL'  Logging With Timestamp  ${active_tm_msg}
    IF  '${active_tm_status}'=='PASS'  Logging With Timestamp  ${rat} Downlink Test Model(s) is active for ${number_cells} cells !${\n}
    [Return]  ${active_tm_status}

Check Active NR Uplink Test Models
    [Documentation]
    ...  Check Active LTE Uplink Test Models procedure
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

    Logging With Timestamp  Check Active NR Uplink Test Models${\n}
    ${active_tm_status}  Create List
    FOR  ${NR_cell_ID}  IN  @{NR_CELLS_ID_LIST}
      ${cell_parameters}  admin.Get Parameters For  class_name=NRCEL  id_num=${NR_cell_ID}  connection=${BTS_ID}
      ${active_tm}  ${active_tm_msg}  Run Keyword And Ignore Error
      ...  admin.Watch 5G Uplink Test Results  ${NR_cell_ID}  timeout=10  connection=${BTS_ID}
      IF  '${active_tm}'=='FAIL'  Logging With Timestamp  No active NR Uplink Test Model for ${cell_parameters.cellName}!
      IF  '${active_tm}'=='PASS'  Logging With Timestamp  NR Uplink Test Model ${USER_NR_UL_TM} for ${cell_parameters.cellName} is active!
      Append To List  ${active_tm_status}  ${active_tm}
    END
    Logging With Timestamp  ${\n}

    [Return]  ${active_tm_status}

Check Active LTE Uplink Test Models
    [Arguments]  ${rb_offset_id}  ${check_active_tm_info}
    [Documentation]
    ...  Check Active LTE Uplink Test Models procedure
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

    Logging With Timestamp  Check Active LTE Uplink Test Models ${check_active_tm_info}
    ${active_tm_status}  Create List
    FOR  ${LTE_cell_ID}  IN  @{LTE_CELLS_ID_LIST}
      ${cell_name}  Evaluate  '${LTE_cell_ID}'.split('/')[-1]
      ${cell_parameters}  admin.Get Parameters For  class_name=LNCEL  id_num=${LTE_cell_ID}  connection=${BTS_ID}
      ${active_tm}  ${active_tm_msg}  Run Keyword And Ignore Error
      ...  admin.Assert Uplink Test Results  ${LTE_cell_ID}  timeout=10  connection=${BTS_ID}
      IF  '${active_tm}'=='FAIL'  Logging With Timestamp  No active LTE Uplink Test Model for LTE cell ${LTE_cell_ID}
      IF  '${active_tm}'=='PASS'  Logging With Timestamp  LTE Uplink Test Model ${USER_LTE_UL_TM} or ${cell_name} is active!
      Append To List  ${active_tm_status}  ${active_tm}
    END
    [Return]  ${active_tm_status}

Get Ids For User NR Cell
    [Documentation]
    ...  Get Ids For User NR Cell
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW creates list with NRCEL_R-* objects from input string with NR Cell Ids.
    ...  | If enter Cell Id does not exist in configuration KW Fail.
    ...  | KW create test variable ${NR_CELLS_ID_LIST}.

    ${user_NR_cell_list}  Split String  ${USER_NR_CELL}  separator=,
    ${NR_CELLS_ID_LIST}  Create List
    @{all_NR_cell_list}  admin.Get Ids For All  class_name=NRCEL  connection=${BTS_ID}
    FOR  ${USER_NR_CELL}  IN  @{user_NR_cell_list}
      ${cell_distname}  Get NR Cell Id  USER_NR_CELL=${USER_NR_CELL}  all_NR_cell_list=${all_NR_cell_list}
      IF  '${cell_distname}'=='None'
        Fail  Incorrect input data - NR cell ID ${USER_NR_CELL} does not exist in configuration.
      END
      Append To List  ${NR_CELLS_ID_LIST}  ${cell_distname}
    END
    Set Test Variable  ${NR_CELLS_ID_LIST}

Get NR Cell Id
    [Arguments]  ${USER_NR_CELL}  ${all_NR_cell_list}
    [Documentation]
    ...  KW retrieves the full DistName for a specific **NR cell** by matching
    ...  the tail of each DistName in a provided list. It returns the first DistName that ends with
    ...  the pattern: `NRCELL_R-${USER_NR_CELL}`.
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+------------------------------------------------------------------+
    ...  | Parameter        | Man. | Description                                                      |
    ...  +==================+======+==================================================================+
    ...  | USER_NR_CELL     | Yes  | Short NR cell identifier                                         |
    ...  | all_NR_cell_list | Yes  | List of NR cell DistNames to search through.                     |
    ...  +------------------+------+------------------------------------------------------------------+
    ...
    ...  **Return:**
    ...  +-------------------------+------------------------------------------------------------------+
    ...  | Return Value            | Description                                                      |
    ...  +=========================+==================================================================+
    ...  | ${NR_cell_dist}         | The first DistName                                               |
    ...  | None                    | If no matching DistName is found.                                |
    ...  +-------------------------+------------------------------------------------------------------+

    FOR  ${NR_cell_dist}  IN  @{all_NR_cell_list}
      Return From Keyword If  '${NR_cell_dist}'.endswith('NRCELL_R-${USER_NR_CELL}')  ${NR_cell_dist}
    END

Get Ids For All NR Cells
    [Documentation]
    ...  Get Ids For All NR Cells
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW creates list with NRCELL_R-* objects for NR Cells in configuration.
    ...  | KW create test variable ${NR_CELLS_ID_LIST}.

    @{NR_CELLS_ID_LIST}  admin.Get Ids For All  class_name=NRCEL  connection=${BTS_ID}
    Set Test Variable  ${NR_CELLS_ID_LIST}

Get Ids For User LTE Cell
    [Documentation]
    ...  Get Ids For User LTE Cell
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW creates list with LNCEL_R-* objects from input string with LTE Cell Ids.
    ...  | If enter Cell Id does not exist in configuration KW Fail.
    ...  | KW create test variable ${LTE_CELLS_ID_LIST}.

    ${user_LTE_cell_list}  Split String  ${USER_LTE_CELL}  separator=,
    ${LTE_CELLS_ID_LIST}  Create List
    @{all_LTE_cell_list}  admin.Get Ids For All  class_name=LNCEL  connection=${BTS_ID}
    FOR  ${USER_LTE_CELL}  IN  @{user_LTE_cell_list}
      ${cell_distname}  Get LTE Cell Id  USER_LTE_CELL=${USER_LTE_CELL}  all_LTE_cell_list=${all_LTE_cell_list}
      IF  '${cell_distname}'=='None'
        Fail  Incorrect input data - LTE cell ID ${USER_LTE_CELL} does not exist in configuration.
      END
      Append To List  ${LTE_CELLS_ID_LIST}  ${cell_distname}
    END
    Set Test Variable  ${LTE_CELLS_ID_LIST}

Get LTE Cell Id
    [Arguments]  ${USER_LTE_CELL}  ${all_LTE_cell_list}
    [Documentation]
    ...  KW retrieves the full DistName for a specific **LTE cell** by matching
    ...  the tail of each DistName in a provided list. It returns the first DistName that ends with
    ...  the pattern: `LNCEL_R-${USER_LTE_CELL}`.
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+------------------------------------------------------------------+
    ...  | Parameter        | Man. | Description                                                      |
    ...  +==================+======+==================================================================+
    ...  | USER_LTE_CELL    | Yes  | Short LTE cell identifier                                        |
    ...  | all_LTE_cell_list| Yes  | List of LTE cell DistNames to search through.                    |
    ...  +------------------+------+------------------------------------------------------------------+
    ...
    ...  **Return:**
    ...  +-------------------------+------------------------------------------------------------------+
    ...  | Return Value            | Description                                                      |
    ...  +=========================+==================================================================+
    ...  | ${LTE_cell_dist}        | The first DistName ending with `LNCEL_R-${USER_LTE_CELL}`.       |
    ...  | None                    | If no matching DistName is found.                                |
    ...  +-------------------------+------------------------------------------------------------------+

    FOR  ${LTE_cell_dist}  IN  @{all_LTE_cell_list}
      Return From Keyword If  '${LTE_cell_dist}'.endswith('LNCEL_R-${USER_LTE_CELL}')  ${LTE_cell_dist}
    END

Get Ids For All LTE Cells
    [Documentation]
    ...  Get Ids For All LTE Cells
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW creates list with LNCEL_R-* objects for LTE Cells in configuration.
    ...  | KW create test variable ${LTE_CELLS_ID_LIST}.

    @{LTE_CELLS_ID_LIST}  admin.Get Ids For All  class_name=LNCEL  connection=${BTS_ID}
    Set Test Variable  ${LTE_CELLS_ID_LIST}

Check Possibility Run LTE Test Model
    [Documentation]
    ...  Check Possibility Run LTE Test Model
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW check if selected LTE cells have correct ChBw for select LTE Uplink Test Model.
    ...  | If not set test to Fail.

    FOR  ${LTE_cell_ID}  IN  @{LTE_CELLS_ID_LIST}
      ${cell_parameters}  admin.Get Parameters For  class_name=LNCEL  id_num=${LTE_cell_ID}  connection=${BTS_ID}
      ${bandwidth_correctness}  Run Keyword And Return Status
      ...  Should Contain  ${${USER_LTE_UL_TM}}  ${cell_parameters.downlinkChannelBandwidth}
      IF  '${bandwidth_correctness}'=='True'
        Logging With Timestamp
        ...  Bandwidth ${cell_parameters.downlinkChannelBandwidth} cell ${cell_parameters.id} allows run LTE Uplink Test Model ${USER_LTE_UL_TM}
      ELSE
        Fail  LTE Uplink Test Model ${USER_LTE_UL_TM} can be run only for cell bandwidth: ${${USER_LTE_UL_TM}}
      END
    END
