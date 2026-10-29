*** Settings ***
Documentation
...  Resource for RF scanning

Library     taf.selenium.sbts  WITH NAME  selenium_coam

*** Keywords ***

Step${step_number}: Preconditions

    Logging With Timestamp
    ...  message=Step${step_number}: Preconditions
    ...  style=STEP
    ...  frame=${TRUE}

    IF  '${RMOD_SN}'=='${EMPTY}'
      Fail  Variable RMOD_SN cannot be empty !
    END
    Set Test Variable  ${BTS_ID}  ${CFG['primary_node_bts_id']}
    RM Verify Serial Number  ${RMOD_SN}  connection=${BTS_ID}
    Logging With Timestamp  RMOD with SN -> ${RMOD_SN} found in HW Configuration
    Set Test Variable  ${ACTIVE_TDS}  ${FALSE}

    ${rmods_info}  admin.Get FRM  60  ${BTS_ID}
    FOR  ${rmod}  IN  @{rmods_info}
      Continue For Loop If  '${RMOD_SN}' not in '${rmod['serialNumber']}'
      Set Test Variable  ${RMOD_DISTNAME_ID}  ${rmod['id']['internal']}
      Set Test Variable  ${RMOD_CONFIG_ID}  ${rmod['id']['configuration']}
      Set Test Variable  ${RMOD_PRODUCT_NAME}  ${rmod['productName']}
    END

    Set Test Variable  ${OBJECT_VARIABLE_RFI}  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1

    Logging With Timestamp  Activating RF Interference testing function by parameter recommissioning, please wait !${\n}
    admin.Perform Parameter Recommissioning  ${OBJECT_VARIABLE_RFI}  actRfiTesting  update  true  connection=${BTS_ID}
    STATE Check If All Cells Are OnAir  ${BTS_ID}
    Logging With Timestamp  Activating R&D Mode, please wait !${\n}
    admin.Change Bts Rad Parameters  component=69  params=39:1  connection=${BTS_ID}

Step${step_number}: Enter To Test Dedicated State

    Logging With Timestamp
    ...  message=Step${step_number}: Enter To Test Dedicated State
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp  Resetting to TDS State...
    admin.Reset To Test Dedicated  timeout=1200  connection=${BTS_ID}

    Logging With Timestamp  Reset To Test Dedicated Test procedure completed, waiting for MRBTS state -> Test ...${\n}
    Wait Until Keyword Succeeds  10min  10s  STATE Verify BTS Procedural State  expected_BTS_status=Test  node_id=${BTS_ID}
    Set Test Variable  ${ACTIVE_TDS}  ${TRUE}

Step${step_number}: Cells Mapping By Antenna Lines

    Logging With Timestamp
    ...  message=Step${step_number}: Cells Mapping By Antenna Lines
    ...  style=STEP
    ...  frame=${TRUE}

    ${wcdma_cells_distnames}  RM Get Cells Mapping By RMOD Id  WCDMA  ${RMOD_DISTNAME_ID}  connection=${BTS_ID}
    ${lte_cells_distnames}  RM Get Cells Mapping By RMOD Id  LTE  ${RMOD_DISTNAME_ID}  connection=${BTS_ID}
    ${nr_cells_distnames}  RM Get Cells Mapping By RMOD Id  NR  ${RMOD_DISTNAME_ID}  connection=${BTS_ID}

    Set Test Variable  ${WCDMA_CELLS_DISTNAMES}
    Set Test Variable  ${LTE_CELLS_DISTNAMES}
    Set Test Variable  ${NR_CELLS_DISTNAMES}

    ${dict_of_wncel_with_ants}  Evaluate  ({i:[] for i in ${WCDMA_CELLS_DISTNAMES}})
    ${dict_of_lncel_with_ants}  Evaluate  ({i:[] for i in ${LTE_CELLS_DISTNAMES}})
    ${dict_of_nr_with_ants}  Evaluate  ({i:[] for i in ${NR_CELLS_DISTNAMES}})

    Set Test Variable  ${DICT_OF_WNCEL_WITH_ANTS}
    Set Test Variable  ${DICT_OF_LNCEL_WITH_ANTS}
    Set Test Variable  ${DICT_OF_NR_WITH_ANTS}

    Verify Antenna Lines For Cell  WNCEL  RX  ${WCDMA_CELLS_DISTNAMES}  ${DICT_OF_WNCEL_WITH_ANTS}
    Verify Antenna Lines For Cell  WNCEL  TX  ${WCDMA_CELLS_DISTNAMES}  ${DICT_OF_WNCEL_WITH_ANTS}
    Verify Antenna Lines For Cell  LNCEL  RX  ${LTE_CELLS_DISTNAMES}  ${DICT_OF_LNCEL_WITH_ANTS}
    Verify Antenna Lines For Cell  LNCEL  TX  ${LTE_CELLS_DISTNAMES}  ${DICT_OF_LNCEL_WITH_ANTS}
    Verify Antenna Lines For Cell  NR  RX  ${NR_CELLS_DISTNAMES}  ${DICT_OF_NR_WITH_ANTS}
    Verify Antenna Lines For Cell  NR  TX  ${NR_CELLS_DISTNAMES}  ${DICT_OF_NR_WITH_ANTS}

Step${step_number}: RF Scanning for NR Composite RX (HBFO) - All Antenna Lines
    [Timeout]  300

    Logging With Timestamp
    ...  message=Step${step_number}: RF Scanning for NR Composite RX (HBFO) - All Antenna Lines
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp  RF Scan for ${RMOD_PRODUCT_NAME} NR Composite RX (HBFO) - All Antennas - will perform now!${\n}

    ${path}  Set Variable  ${CFG.test_logs_path}/NR_Composite_RX_HFBO_${RMOD_PRODUCT_NAME}_ALL_ANTENNAS
    admin.Start Rf Scanning Test  NR_FDD  ${RMOD_DISTNAME_ID}   RX_COMBINED  output_file_name=${path}.zip  connection=${BTS_ID}
    Unzip File  ${path}  all_antennas=True

Step${step_number}: RF Scanning for NRTDD Composite RX (HBFO) - Full Array
    [Timeout]  900

    Logging With Timestamp
    ...  message=Step${step_number}: RF Scanning for NRTDD Composite RX (HBFO) - Full Array
    ...  style=STEP
    ...  frame=${TRUE}

    ${path}  Set Variable  ${CFG.test_logs_path}/NR_Composite_RX_HFBO_${RMOD_PRODUCT_NAME}_Full_Array
    admin.Start Rf Scanning Test  NR_TDD  ${RMOD_DISTNAME_ID}  RX_COMBINED  output_file_name=${path}.zip  antenna_panel=PHYANT_1_Full_Array
    ...  connection=${BTS_ID}
    Unzip File  ${path}  all_antennas=False

Step${step_number}: RF Scanning for LTE Composite RX (HBFO) - All Antenna Lines
    [Timeout]  300

    Logging With Timestamp
    ...  message=Step${step_number}: RF Scanning for LTE Composite RX (HBFO) - All Antenna Lines
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp  RF Scan for ${RMOD_PRODUCT_NAME} LTE Composite RX (HBFO) - All Antennas - will perform now!${\n}

    ${path}  Set Variable  ${CFG.test_logs_path}/LTE_Composite_RX_HFBO_${RMOD_PRODUCT_NAME}_ALL_ANTENNAS
    admin.Start Rf Scanning Test  LTE_FDD  ${RMOD_DISTNAME_ID}  RX_COMBINED  output_file_name=${path}.zip  connection=${BTS_ID}
    Unzip File  ${path}  all_antennas=True

Step${step_number}: RF Scanning for WCDMA Composite RX (HBFO) - All Antenna Lines
    [Timeout]  300

    Logging With Timestamp
    ...  message=Step${step_number}: RF Scanning for WCDMA Composite RX (HBFO) - All Antenna Lines
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp  RF Scan for ${RMOD_PRODUCT_NAME} WCDMA Composite RX (HBFO) - All Antennas - will perform now!${\n}

    ${path}  Set Variable  ${CFG.test_logs_path}/WCDMA_Composite_RX_HFBO_${RMOD_PRODUCT_NAME}_ALL_ANTENNAS
    admin.Start Rf Scanning Test  WCDMA  ${RMOD_DISTNAME_ID}  RX_COMBINED  output_file_name=${path}.zip  connection=${BTS_ID}
    Unzip File  ${path}  all_antennas=True

Step${step_number}: RF Scanning for NR Composite RX (HBFO) - Each Antenna Separately
    [Timeout]  300

    Logging With Timestamp
    ...  message=Step${step_number}: RF Scanning for NR Composite RX (HBFO) - Each Antenna Separately
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp  RF Scan for ${RMOD_PRODUCT_NAME} NR Composite RX (HBFO) - Each antenna separately - will perform!${\n}
    ${cells}  Get Dictionary Keys  ${DICT_OF_NR_WITH_ANTS}
    FOR  ${cell}  IN  @{cells}
      ${antls}  Get From Dictionary  ${DICT_OF_NR_WITH_ANTS}  ${cell}
      ${antls}  Remove Duplicates  ${antls}
    END

    FOR  ${antl}  IN  @{antls}
      ${path}  Set Variable  ${CFG.test_logs_path}/NR_Composite_RX_HFBO_${RMOD_PRODUCT_NAME}_${antl}
      admin.Start Rf Scanning Test  NR_FDD  ${RMOD_DISTNAME_ID}  RX_COMBINED  output_file_name=${path}.zip  antenna_dn=${antl}  connection=${BTS_ID}
      Unzip File  ${path}  all_antennas=False
    END

Step${step_number}: RF Scanning for LTE Composite RX (HBFO) - Each Antenna Separately
    [Timeout]  300

    Logging With Timestamp
    ...  message=Step${step_number}: RF Scanning for LTE Composite RX (HBFO) - Each Antenna Separately
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp  RF Scan for ${RMOD_PRODUCT_NAME} LTE Composite RX (HBFO) - Each antenna separately - will perform!${\n}
    ${cells}  Get Dictionary Keys  ${DICT_OF_LNCEL_WITH_ANTS}
    FOR  ${cell}  IN  @{cells}
      ${antls}  Get From Dictionary  ${DICT_OF_LNCEL_WITH_ANTS}  ${cell}
      ${antls}  Remove Duplicates  ${antls}
    END

    FOR  ${antl}  IN  @{antls}
      ${path}  Set Variable  ${CFG.test_logs_path}/LTE_Composite_RX_HFBO_${RMOD_PRODUCT_NAME}_${antl}
      admin.Start Rf Scanning Test  LTE_FDD  ${RMOD_DISTNAME_ID}  RX_COMBINED  output_file_name=${path}.zip  antenna_dn=${antl}
      ...  connection=${BTS_ID}
      Unzip File  ${path}  all_antennas=False
    END

Step${step_number}: RF Scanning for WCDMA Composite RX (HBFO) - Each Antenna Separately
    [Timeout]  300

    Logging With Timestamp
    ...  message=Step${step_number}: RF Scanning for WCDMA Composite RX (HBFO) - Each Antenna Separately
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp  RF Scan for ${RMOD_PRODUCT_NAME} WCDMA Composite RX (HBFO) - Each antenna separately - will perform!${\n}
    ${cells}  Get Dictionary Keys  ${DICT_OF_WNCEL_WITH_ANTS}
    FOR  ${cell}  IN  @{cells}
      ${antls}  Get From Dictionary  ${DICT_OF_WNCEL_WITH_ANTS}  ${cell}
      ${antls}  Remove Duplicates  ${antls}
    END

    FOR  ${antl}  IN  @{antls}
      ${path}  Set Variable  ${CFG.test_logs_path}/WCDMAComposite_RX_HFBO_${RMOD_PRODUCT_NAME}_${antl}
      admin.Start Rf Scanning Test  WCDMA  ${RMOD_DISTNAME_ID}  RX_COMBINED  output_file_name=${path}.zip  antenna_dn=${antl}
      ...  connection=${BTS_ID}
      Unzip File  ${path}  all_antennas=False
    END

Step${step_number}: RF Scanning for NR Carrier RX (FIR9)
    [Timeout]  900

    Logging With Timestamp
    ...  message=Step${step_number}: RF Scanning for NR Carrier RX (FIR9)
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp  RF Scan for ${RMOD_PRODUCT_NAME} NR Carrier RX (FIB9) will perform now, please wait !${\n}

    FOR  ${cell}  ${antls}  IN ZIP  ${DICT_OF_NR_WITH_ANTS.keys()}  ${DICT_OF_NR_WITH_ANTS.values()}
      Check RF Scan For Cell-Ants  NR_FDD  RX_CARRIER  antls_list=${antls}  cell=${cell}
    END

Step${step_number}: RF Scanning for NRTDD Carrier RX (FIR9)
    [Timeout]  900

    Logging With Timestamp
    ...  message=Step${step_number}: RF Scanning for NRTDD Carrier RX (FIR9)
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp  RF Scan for ${RMOD_PRODUCT_NAME} NRTDD Carrier RX (FIB9) will perform now, please wait !${\n}

    FOR  ${cell}  IN ZIP  ${DICT_OF_NR_WITH_ANTS.keys()}
      ${path}  Set Variable  ${CFG.test_logs_path}/NRTDD_Carrier_RX_FIB9_${RMOD_PRODUCT_NAME}_${cell}
      admin.Start Rf Scanning Test  NR_TDD  ${RMOD_DISTNAME_ID}  RX_CARRIER  output_file_name=${path}.zip
      ...  antenna_panel=PHYANT_1_Full_Array  cell_dn=${cell}  connection=${BTS_ID}
      Unzip File  ${path}  all_antennas=False
    END

Step${step_number}: RF Scanning for LTE Carrier RX (FIR9)
    [Timeout]  900

    Logging With Timestamp
    ...  message=Step${step_number}: RF Scanning for LTE Carrier RX (FIR9)
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp  RF Scan for ${RMOD_PRODUCT_NAME} LTE Carrier RX (FIB9) will perform now, please wait !${\n}

    FOR  ${cell}  ${antls}  IN ZIP  ${DICT_OF_LNCEL_WITH_ANTS.keys()}  ${DICT_OF_LNCEL_WITH_ANTS.values()}
      Check RF Scan For Cell-Ants  LTE_FDD  RX_CARRIER  antls_list=${antls}  cell=${cell}
    END

Step${step_number}: RF Scanning for WCDMA Carrier RX (FIR9)
    [Timeout]  900

    Logging With Timestamp
    ...  message=Step${step_number}: RF Scanning for WCDMA Carrier RX (FIR9)
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp  RF Scan for ${RMOD_PRODUCT_NAME} WCDMA Carrier RX (FIB9) will perform now, please wait !${\n}

    FOR  ${cell}  ${antls}  IN ZIP  ${DICT_OF_WNCEL_WITH_ANTS.keys()}  ${DICT_OF_WNCEL_WITH_ANTS.values()}
      Check RF Scan For Cell-Ants  WCDMA  RX_CARRIER  antls_list=${antls}  cell=${cell}
    END

Step${step_number}: RF Scanning for NR Feedback Tx (PDRx) - Each Antenna Separately
    [Timeout]  900

    Logging With Timestamp
    ...  message=Step${step_number}: RF Scanning for NR Feedback Tx (PDRx) - Each Antenna Separately
    ...  style=STEP
    ...  frame=${TRUE}

    ${cells_active_TM}  Run Keyword If  ${ACTIVE_TDS}  Start Downlink NR TestModel For Required Antennas

    ${antls}  Remove Duplicates  ${ALL_ANTS_TX_NR}
    FOR  ${antl}  IN  @{antls}
      Logging With Timestamp  RF Scanning for NR Feedback Tx (PDRx) ${RMOD_PRODUCT_NAME} ${antl}!${\n}
      ${path}  Set Variable  ${CFG.test_logs_path}/NR_Feedback_TX_PDRx_${RMOD_PRODUCT_NAME}_${antl}
      admin.Start Rf Scanning Test  NR_FDD  ${RMOD_DISTNAME_ID}  TX_FEEDBACK  output_file_name=${path}.zip  antenna_dn=${antl}  connection=${BTS_ID}
      Unzip File  ${path}  all_antennas=False
    END
    IF  ${ACTIVE_TDS}
      Stop Active Downlink NR TestModel  ${cells_active_TM}
    END

Step${step_number}: RF Scanning for NRTDD Feedback Tx (PDRx)
    [Timeout]  900

    Logging With Timestamp
    ...  message=Step${step_number}: RF Scanning for NRTDD Feedback Tx (PDRx)
    ...  style=STEP
    ...  frame=${TRUE}

    ${path}  Set Variable  ${CFG.test_logs_path}/NRTDD_Feedback_Tx_PDRx_${RMOD_PRODUCT_NAME}_Full_Array
    admin.Start Rf Scanning Test  NR_TDD  ${RMOD_DISTNAME_ID}  TX_FEEDBACK  output_file_name=${path}.zip  antenna_panel=PHYANT_1_Full_Array
    ...  connection=${BTS_ID}  timeout=120
    Unzip File  ${path}  all_antennas=False

Step${step_number}: RF Scanning for LTE Feedback Tx (PDRx) - Each Antenna Separately
    [Timeout]  600

    Logging With Timestamp
    ...  message=Step${step_number}: RF Scanning for LTE Feedback Tx (PDRx) - Each Antenna Separately
    ...  style=STEP
    ...  frame=${TRUE}

    ${cells_active_TM}  Run Keyword If  ${ACTIVE_TDS}  Start Downlink LTE TestModel For Required Antennas
    ${antls}  Remove Duplicates  ${ALL_ANTS_TX_LNCEL}
    FOR  ${antl}  IN  @{antls}
      Logging With Timestamp  Sending request for LTE Feedback Tx (PDRx) ${RMOD_PRODUCT_NAME} ${antl}!${\n}
      ${path}  Set Variable  ${CFG.test_logs_path}/LTE_Feedback_TX_PDRx_${RMOD_PRODUCT_NAME}_${antl}
      admin.Start Rf Scanning Test  LTE_FDD  ${RMOD_DISTNAME_ID}  TX_FEEDBACK  output_file_name=${path}.zip  antenna_dn=${antl}
      ...  connection=${BTS_ID}
      Unzip File  ${path}  all_antennas=False
    END
    IF  ${ACTIVE_TDS}
      Stop Active Downlink LTE TestModel  ${cells_active_TM}
    END

Step${step_number}: RF Scanning for WCDMA Feedback Tx (PDRx) - Each Antenna Separately
    [Timeout]  600

    Logging With Timestamp
    ...  message=Step${step_number}: RF Scanning for WCDMA Feedback Tx (PDRx) - Each Antenna Separately
    ...  style=STEP
    ...  frame=${TRUE}

    ${antls}  Remove Duplicates  ${ALL_ANTS_TX_WNCEL}
    FOR  ${antl}  IN  @{antls}
      Logging With Timestamp  Sending request for WCDMA Feedback Tx (PDRx) ${RMOD_PRODUCT_NAME} ${antl}!${\n}
      ${path}  Set Variable  ${CFG.test_logs_path}/LTE_Feedback_TX_PDRx_${RMOD_PRODUCT_NAME}_${antl}
      admin.Start Rf Scanning Test  WCDMA  ${RMOD_DISTNAME_ID}  TX_FEEDBACK  output_file_name=${path}.zip  antenna_dn=${antl}
      ...  connection=${BTS_ID}
      Unzip File  ${path}  all_antennas=False
    END

Step${step_number}: Check Cancel Requests for NRFDD Composite Rx (HBF0)
    [Timeout]  900

    Logging With Timestamp
    ...  message=Step${step_number}: Check Cancel Requests for NRFDD Composite Rx (HBF0)
    ...  style=STEP
    ...  frame=${TRUE}

    Selenium Login And Disable Screen Lock  download_dir=${CFG.test_logs_path}
    Sleep  10
    ${radio_nr}  Fetch From Right  ${RMOD_CONFIG_ID}  -
    Check Cancel Requests For All Antennas  technology=NR FDD  radio=RMOD-${radio_nr} (${RMOD_PRODUCT_NAME})
    ...  capture_type=Composite Rx (HBF0)  atenna=All Antennas
    Selenium Logout And Close Browser

Step${step_number}: Check Cancel Requests for NRTDD Composite Rx (HBF0)
    [Timeout]  900

    Logging With Timestamp
    ...  message=Step${step_number}: Check Cancel Requests for NRTDD Composite Rx (HBF0)
    ...  style=STEP
    ...  frame=${TRUE}

    Selenium Login And Disable Screen Lock  download_dir=${CFG.test_logs_path}/TX_FEEDBACK
    Sleep  10
    ${radio_nr}  Fetch From Right  ${RMOD_CONFIG_ID}  -
    Check Cancel Requests For All Antennas  technology=NR TDD  radio=RMOD-${radio_nr} (${RMOD_PRODUCT_NAME})
    ...  capture_type=Composite Rx (HBF0)  atenna=PHYANT 1  antenna_panel=PHYANT-1 Full Array
    Selenium Logout And Close Browser

Step${step_number}: Exit From Test Dedicated State

    Logging With Timestamp
    ...  message=Step${step_number}: Exit From Test Dedicated State
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp  Exiting Test Dedicated State...

    admin.Reset Site  timeout=1200  connection=${BTS_ID}

    Wait Until Keyword Succeeds  40min  10s  STATE Verify BTS Procedural State  expected_BTS_status=OnAir  node_id=${BTS_ID}

    ${cell_status}  Run Keyword And Return Status  STATE Check If All Cells Are OnAir  ${BTS_ID}  timeout=120
    IF  '${cell_status}'=='True'
      Logging With Timestamp  All cells are onAir !${\n}
    ELSE
      Fail  Cells doesn't reach onAir state!
    END
    Set Test Variable  ${ACTIVE_TDS}  ${FALSE}

Postconditions

    Logging With Timestamp
    ...  message=Postconditions
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp  Deactivating RF Interference testing function by parameter recommissioning, please wait !${\n}
    admin.Perform Parameter Recommissioning  ${OBJECT_VARIABLE_RFI}  actRfiTesting  update  false  connection=${BTS_ID}
    STATE Check If All Cells Are OnAir  ${BTS_ID}
    admin.Change Bts Rad Parameters  component=69  params=39:0    connection=${BTS_ID}
    Logging With Timestamp  All postconditions are met, TC passed!${\n}

Verify Antenna Lines For Cell
    [Arguments]  ${rat}  ${search_direction}  ${cell_distnames}  ${dict_with_ants}
    [Documentation]
    ...  KW verifies which antenna lines are used for TX or RX carriers for a given set of cells.
    ...  It filters cells based on the specified RAT, then iterates through
    ...  each cell's carrier list to extract antenna line IDs that match the given transmission direction
    ...  and RMOD identifier. The results are stored in a dictionary for further use.
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+------------------------------------------------------------------+
    ...  | Parameter        | Man. | Description                                                      |
    ...  +==================+======+==================================================================+
    ...  | rat              | Yes  | Supported values: 'LNCEL', 'NR', 'WCDMA'.                        |
    ...  | search_direction | Yes  | Transmission direction - 'TX' or 'RX'.                           |
    ...  | cell_distnames   | Yes  | List of cell id to be checked.                          |
    ...  | dict_with_ants   | Yes  | Dictionary to store antenna line IDs per cell.                   |
    ...  +------------------+------+------------------------------------------------------------------+
    ...  **Return:**
    ...  +-------------------------+------------------------------------------------------------------+
    ...  | Return Value            | Description                                                      |
    ...  +=========================+==================================================================+
    ...  | dict_with_ants          | Dictionary updated with antenna line IDs per cell.               |
    ...  +-------------------------+------------------------------------------------------------------+

    ${whole_list}  admin.Get Cell List  connection=${BTS_ID}
    ${rat_cells_info}  Run Keyword If  '${rat}'=='LNCEL'  Evaluate  (${whole_list}\['cells']['lte'])
    ...  ELSE IF  '${rat}'=='NR'  Evaluate  (${whole_list}\['cells']['nr'])
    ...  ELSE  Evaluate  (${whole_list}\['cells']['wcdma'])

    FOR  ${cell_info}  IN  @{rat_cells_info}
      ${cell_distname}  Evaluate  ${cell_info}\['id']['internal']
      Continue For Loop If  '${cell_distname}' not in ${cell_distnames}
      ${carriers_list}  Evaluate  (${cell_info}\['carrierList'])
      Extract Antenna Lines From Carrier List  ${carriers_list}  ${cell_distname}  ${dict_with_ants}  ${search_direction}  ${rat}
    END

Extract Antenna Lines From Carrier List
    [Arguments]  ${carrier_list}  ${cell_id_from_admin}  ${DICT_CELL_ANTS}  ${search_direction}  ${rat}
    [Documentation]
    ...  KW extracts antenna line IDs from a carrier list for a specific cell, based on the desired
    ...  transmission direction and RMOD match. Appends valid antenna lines to the provided dictionary
    ...  and sets a test variable if any matching lines are found.
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                      |
    ...  +========================+======+==================================================================+
    ...  | carrier_list           | Yes  | List of carrier objects associated with the cell.                |
    ...  | cell_id_from_admin     | Yes  | Internal cell identifier .|
    ...  | DICT_CELL_ANTS         | Yes  | Dictionary to store antenna line IDs per cell.                   |
    ...  | search_direction       | Yes  | Transmission direction - 'TX' or 'RX'.                     |
    ...  | rat                    | Yes  | Supported values: 'LNCEL', 'NR', 'WCDMA'.           |
    ...  +------------------------+------+------------------------------------------------------------------+
    ...  **Return:**
    ...  +-------------------------+------------------------------------------------------------------+
    ...  | Return Value            | Description                                                      |
    ...  +=========================+==================================================================+
    ...  | ALL_ANTS_direction_rat  | Dynamic list of matching antenna line IDs (if any found).        |
    ...  +-------------------------+------------------------------------------------------------------+

    ${all_ants_temp}   Create List
    FOR  ${carrier}  IN  @{carrier_list}
      ${direction}  Get From Dictionary  ${carrier}  direction
      Continue For Loop If  '${direction}'!='${search_direction}'
      ${antl}  Evaluate  (${carrier}\['antennaLineId']['internal'])
      ${rmod_dst}  Evaluate  '${antl}'.rsplit('/', 1)[0]
      Continue For Loop If  '${rmod_dst}'!='${RMOD_DISTNAME_ID}'
      Append To List  ${DICT_CELL_ANTS}[${cell_id_from_admin}]  ${antl}
      Append To List  ${all_ants_temp}  ${antl}
    END
    ${is_not_empty}  Evaluate  len(${all_ants_temp}) > 0
    IF  ${is_not_empty}
      Set Test Variable  ${ALL_ANTS_${search_direction}_${rat}}  ${all_ants_temp}
    END

Check RF Scan For Cell-Ants
    [Arguments]  ${technology}  ${captureType}  ${antls_list}  ${cell}  ${antenna_panel}=${NONE}

    ${antls_list}  Remove Duplicates  ${antls_list}
    FOR  ${antl}  IN  @{antls_list}
      ${path}  Set Variable  ${CFG.test_logs_path}/${technology}_${captureType}_${RMOD_PRODUCT_NAME}
      admin.Start Rf Scanning Test  ${technology}  ${RMOD_DISTNAME_ID}  ${captureType}  output_file_name=${path}.zip
      ...  antenna_dn=${antl}  antenna_panel=${antenna_panel}  cell_dn=${cell}  connection=${BTS_ID}
      Unzip File  ${path}  all_antennas=False
    END

Check Cancel Requests For All Antennas
    [Arguments]  ${technology}  ${radio}  ${capture_type}
    ...  ${atenna}  ${antenna_panel}=${NONE}  ${local_cell}=${NONE}
    Logging With Timestamp  \n Start ${technology} RF Scanning ${capture_type}
    selenium_coam.Start Rf Scan  ${technology}  ${radio}
    ...  ${capture_type}   ${atenna}  ${antenna_panel}  ${local_cell}
    Logging With Timestamp  \n Cancel ${technology} RF Scanning ${capture_type}
    ${path}  Run Keyword And Ignore Error  selenium_coam.Cancel Rf Scan
    IF  '${path[0]}'=='FAIL'
      Run Keyword And Continue On Failure  Fail  Cancel request not stop ongoing RF Scan capturing.
    ELSE IF  '${path[1]}'=='Canceled'
      Logging With Timestamp  Request finished with status Canceled!
    END

Unzip File
    [Arguments]  ${path}  ${all_antennas}
    [Documentation]
    ...  Description:
    ...  Keyword unpacks a ZIP file located in a specified directory.
    ...  The ZIP file is extracted into a subdirectory with the same name as the ZIP file itself.
    ...  After extraction, the keyword either checks RF scanning files or processes all subfiles,
    ...  depending on the value of the `all_antennas` flag.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | path                   | Yes  | Path to the directory where the ZIP file is located.                       |
    ...  | all_antennas           | Yes  | Boolean flag ('True' or 'False') indicating RF scanning type.              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: lukasz.wystup@nokia.com
    ...  Maintainer: lukasz.wystup@nokia.com

    Logging With Timestamp  Unzipping ${path}.zip ... !${\n}
    ${command_to_unzip}  Set Variable  unzip "${path}.zip" -d "${path}"
    ${result}  Run and Return RC  ${command_to_unzip}
    IF  ${result}!=0
      Run Keywords
      ...  Run Keyword And Continue On Failure  Fail  Cannot unzip file ${path}.zip, maybe doesn't exists?
      ...  AND  Return From Keyword
    END
    IF  '${all_antennas}'=='True'
      Unzip All Subfiles  ${path}
    ELSE
      Check RFCap And XML file  ${path}
    END

Unzip All Subfiles
    [Arguments]  ${path}

    Logging With Timestamp  Unzipping all .zip subfiles !${\n}
    ${list_of_files}  OperatingSystem.List Directory  ${path}
    FOR  ${zip_path}  IN  @{list_of_files}
      ${dictionary}  Evaluate  '${zip_path}'.rsplit('.', 1)[0]
      ${command_to_unzip}  Set Variable  unzip "${path}/${zip_path}" -d "${path}/${dictionary}"
      ${result}  Run and Return RC  ${command_to_unzip}
      Run Keyword If  ${result}!=0  Run Keywords
      ...  Run Keyword And Continue On Failure  Fail  Cannot unzip file ${zip_path}, maybe doesn't exists?
      ...  AND  Continue For Loop
      Check RFCap And XML file  ${path}/${dictionary}
    END
    Remove Unzipped Dictionary  ${path}


Check RFCap And XML File
    [Arguments]  ${path}

    Logging With Timestamp  Checking number of RFCap and XML files in zip ${path} ... ${\n}

    ${list_of_files}  OperatingSystem.List Directory  ${path}
    ${count_all_files}  Evaluate  len(${list_of_files})

    ${rfcap_files}  Evaluate  [ i for i in ${list_of_files} if i.endswith('.rfcap')]
    ${rfcap_count}  Evaluate  len(${rfcap_files})

    ${xml_files}  Evaluate  [ i for i in ${list_of_files} if i.endswith('.xml')]
    ${xml_count}  Evaluate  len(${xml_files})

    ${rfcap_status}  Run Keyword And Return Status  Should Be Equal As Integers  ${count_all_files}  ${rfcap_count+1}

    ${xml_status}  Run Keyword And Return Status  Should Be Equal As Integers  ${xml_count}  1

    Logging With Timestamp  Number of .rfcap files: ${rfcap_count}${\n}Number of .xml files: ${xml_count}${\n}

    IF  '${rfcap_status}'=='False' or '${xml_status}'=='False'
      Run Keyword And Continue On Failure  Fail  Number of .rfcap files doesn't meet conditions!
    ELSE
      Logging With Timestamp  Number of .rfcap and .xml files is correct !${\n}
    END
    Remove Unzipped Dictionary  ${path}

Remove Unzipped Dictionary
    [Arguments]  ${path}

    Run  rm "${path}.zip"
    ${result}  Run and Return RC  rm -r "${path}"
    IF  ${result}!=0
      Logging With Timestamp  Cannot remove dictionary ${path}!
    ELSE
      Logging With Timestamp  Directory ${path} removed successfully !${\n}
    END

Start Downlink NR TestModel For Required Antennas
    @{BEAM_PATTERN_ID}  Create List  ${1}
    @{cells_active_TM}  Create List
    ${cells}  Get Dictionary Keys  ${DICT_OF_NR_WITH_ANTS}
    FOR  ${cell}  IN  @{cells}
      ${antls}  Get From Dictionary  ${DICT_OF_NR_WITH_ANTS}  ${cell}
      ${antls}  Remove Duplicates  ${antls}
      Sort List  ${antls}
      Sort List  ${ALL_ANTS_TX_NR}
      ${tm_antls}  Run Keyword And Return Status  Lists Should Be Equal  ${antls}  ${ALL_ANTS_TX_NR}  ignore_order=True
      Continue For Loop If  '${tm_antls}'=='False'
      admin.Start 5G Downlink Test  ${cell}  TM1_1  ${BEAM_PATTERN_ID}  P_both  0  NR_Only  1  0  0  0  0  1  connection=${BTS_ID}
      Logging With Timestamp  Start Downlink NR TestModel for cell ${cell}.
      Append To List  ${cells_active_TM}  ${cell}
      Sleep    10s
    END
    [Return]  ${cells_active_TM}

Start Downlink LTE TestModel For Required Antennas
    @{cells_active_TM}  Create List
    ${cells}  Get Dictionary Keys  ${DICT_OF_LNCEL_WITH_ANTS}
    FOR  ${cell}  IN  @{cells}
      ${antls}  Get From Dictionary  ${DICT_OF_LNCEL_WITH_ANTS}  ${cell}
      ${antls}  Remove Duplicates  ${antls}
      Sort List  ${antls}
      Sort List  ${ALL_ANTS_TX_LNCEL}
      ${tm_antls}  Run Keyword And Return Status  Lists Should Be Equal  ${antls}  ${ALL_ANTS_TX_LNCEL}  ignore_order=True
      Continue For Loop If  '${tm_antls}'=='False'
      ${cell_parameters}  admin.Get Parameters For  LNCEL  ${cell}  connection=${BTS_ID}
      admin.Start Downlink Test  ${cell}  E_TM1_1  ${cell_parameters.earfcnDL}  phy_cell_id=1  connection=${BTS_ID}
      Logging With Timestamp  Start Downlink LTE TestModel for cell ${cell}.
      Append To List  ${cells_active_TM}  ${cell}
      Sleep  10s
    END
    [Return]  ${cells_active_TM}

Stop Active Downlink NR TestModel
    [Arguments]  ${cells_active_TM}
    FOR  ${cell}  IN  @{cells_active_TM}
      ${status}  Run Keyword And Return Status  admin.Stop 5G Downlink Test  ${cell}  connection=${BTS_ID}
      Logging With Timestamp  Stop Downlink NR TestModel for cell ${cell}.
      Sleep  10s
      Run Keyword If  not ${status}  Run Keyword And Continue On Failure  Fail  Downlink NR TM doesn't stop correctly!
    END

Stop Active Downlink LTE TestModel
    [Arguments]  ${cells_active_TM}
    FOR  ${cell}  IN  @{cells_active_TM}
      ${status}  Run Keyword And Return Status  admin.Stop Downlink Test  ${cell}  connection=${BTS_ID}
      Logging With Timestamp  Stop Downlink LTE TestModel for cell ${cell}.
      Sleep  10s
      Run Keyword If  not ${status}  Run Keyword And Continue On Failure  Fail  Downlink LTE TM doesn't stop correctly !
    END

Selenium Login And Disable Screen Lock
    [Arguments]  ${download_dir}=${EMPTY}
    selenium_coam.Enable Virtual Display
    ${browser}  selenium_coam.Create Firefox Browser  download_dir=${download_dir}  name=firefox_browser
    ${sw_release}  admin.Get Sw Release Name  connection=${BTS_ID}
    selenium_coam.Login  ${WEBUI_URL}  ${WEBUI_NAME}  ${WEBUI_PWD}  download_dir=${download_dir}  version=${sw_release}  browser=${browser}
    Run Keyword And Ignore Error   selenium_coam.Close Start Up View Window
    selenium_coam.Disable Message Box
    selenium_coam.Disable Screen Lock

Selenium Logout And Close Browser
    Run Keyword And Ignore Error    selenium_coam.Logout
    Run Keyword And Ignore Error    selenium_coam.Close Browser
