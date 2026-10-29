*** Settings ***
Documentation
...  Resource for RF scanning

Library     taf.selenium.sbts  WITH NAME  selenium_coam
Resource    hran_frame_sbts_siso.robot
Resource    ca_BSRF_general.robot
Resource    ca_siso_cli.robot

*** Keywords ***

step${step_number}: Preconditions

    Log to console  --------------------
    Log to console  step${step_number}: Preconditions
    Log to console  --------------------${\n}

    Run Keyword If  '${RMOD_SN}'=='${EMPTY}'
    ...  Fail  Variable RMOD_SN cannot be empty !
    Verify Serial Number  ${RMOD_SN}
    Log To Console  RMOD with SN -> ${RMOD_SN} found in HW Configuration
    Set Test Variable  ${ACTIVE_TDS}  ${FALSE}

    ${rmods_info}  admin.Get FRM  60  ${node}
    FOR  ${rmod}  IN  @{rmods_info}
        Continue For Loop If  '${RMOD_SN}' not in '${rmod['serialNumber']}'
        Set Test Variable  ${RMOD_DISTNAME_ID}  ${rmod['id']['internal']}
        Set Test Variable  ${RMOD_CONFIG_ID}  ${rmod['id']['configuration']}
        Set Test Variable  ${RMOD_PRODUCT_NAME}  ${rmod['productName']}
    END

    ${bts_obj}  admin.Get parameters for all  BTS  connection=${node}
    ${bts_id}  Convert to string  ${bts_obj[0].btsId}
    Set Test Variable  ${OBJECT_VARIABLE_RFI}  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1

    Log to console  Preparing CLI connection ...${\n}
    ${status}  Run Keyword And Return Status
    ...  admin_cli.Setup Admin CLI  ${active SW version}  ${MPLANE_IP}  port=443
    Run Keyword If  '${status}'=='False'  Fail  Cannot setup Admin CLI!
    ...  ELSE  Log to console  Setup Admin CLI completed !${\n}

    Log to console  Activating RF Interference testing function by parameter recommissioning, please wait !${\n}
    admin.Perform Parameter Recommissioning  ${OBJECT_VARIABLE_RFI}  actRfiTesting  update  true  alias=${node}
    Check If All Cells Are OnAir
    Siso Check Admin CLI Feature Enabled
    Check If All Cells Are OnAir

step${step_number}: Enter To Test Dedicated State

    Log to console  -------------------------------------
    Log to console  step${step_number}: Enter To Test Dedicated State
    Log to console  -------------------------------------${\n}

    Log to console  Resetting to TDS State...
    admin.Reset To Test Dedicated  timeout=1200  connection=${node}

    Log To Console  Reset To Test Dedicated Test procedure completed, waiting for MRBTS state -> Test ...${\n}
    Wait Until Keyword Succeeds  10min  10s  Check MrBTS State  expected_state=Test
    Set Test Variable  ${ACTIVE_TDS}  ${TRUE}

step${step_number}: Cells Mapping By Antenna Lines

    Log To Console  ${\n}----------------------------------------
    Log To Console  step${step_number}: Cells Mapping By Antenna Lines
    Log To Console  ----------------------------------------${\n}

    ${wcdma_cells_distnames}  Get Cells Mapping By RMOD ID  WCDMA  ${RMOD_DISTNAME_ID}
    ${lte_cells_distnames}  Get Cells Mapping By RMOD ID  LTE  ${RMOD_DISTNAME_ID}
    ${nr_cells_distnames}  Get Cells Mapping By RMOD ID  NR  ${RMOD_DISTNAME_ID}

    Set Test Variable  ${WCDMA_CELLS_DISTNAMES}
    Set Test Variable  ${LTE_CELLS_DISTNAMES}
    Set Test Variable  ${NR_CELLS_DISTNAMES}

    ${dict_of_wncel_with_ants}  Evaluate  ({i:[] for i in ${WCDMA_CELLS_DISTNAMES}})
    ${dict_of_lncel_with_ants}  Evaluate  ({i:[] for i in ${LTE_CELLS_DISTNAMES}})
    ${dict_of_nr_with_ants}  Evaluate  ({i:[] for i in ${NR_CELLS_DISTNAMES}})

    Set Test Variable  ${DICT_OF_WNCEL_WITH_ANTS}
    Set Test Variable  ${DICT_OF_LNCEL_WITH_ANTS}
    Set Test Variable  ${DICT_OF_NR_WITH_ANTS}

    ${all_ants_tx}  Create List
    Set Test Variable  ${ALL_ANTS_TX}
    ${all_ants_rx}  Create List
    Set Test Variable  ${ALL_ANTS_RX}

    Check Antenna Lines For Cell  WNCEL  RX  ${WCDMA_CELLS_DISTNAMES}  ${DICT_OF_WNCEL_WITH_ANTS}
    Check Antenna Lines For Cell  WNCEL  TX  ${WCDMA_CELLS_DISTNAMES}  ${DICT_OF_WNCEL_WITH_ANTS}
    Check Antenna Lines For Cell  LNCEL  RX  ${LTE_CELLS_DISTNAMES}  ${DICT_OF_LNCEL_WITH_ANTS}
    Check Antenna Lines For Cell  LNCEL  TX  ${LTE_CELLS_DISTNAMES}  ${DICT_OF_LNCEL_WITH_ANTS}
    Check Antenna Lines For Cell  NR  RX  ${NR_CELLS_DISTNAMES}  ${DICT_OF_NR_WITH_ANTS}
    Check Antenna Lines For Cell  NR  TX  ${NR_CELLS_DISTNAMES}  ${DICT_OF_NR_WITH_ANTS}

    ${ALL_ANTS_TX}  Remove Duplicates  ${ALL_ANTS_TX}
    Set Test Variable  ${ALL_ANTS_TX}
    ${ALL_ANTS_RX}  Remove Duplicates  ${ALL_ANTS_RX}
    Set Test Variable  ${ALL_ANTS_RX}

step${step_number}: RF Scanning for NR Composite RX (HBFO) - All Antenna Lines
    [Timeout]  300

    Log to console  ${\n}--------------------------------------------------------------
    Log to console  step${step_number}: RF Scanning for NR Composite RX (HBFO) - All Antenna Lines
    Log to console  --------------------------------------------------------------${\n}
    Log to console  CLI request for RF Scan for ${RMOD_PRODUCT_NAME} NR Composite RX (HBFO) - All Antennas - will perform now!${\n}

    ${path}  Set Variable  NR_Composite_RX_HFBO_${RMOD_PRODUCT_NAME}_ALL_ANTENNAS
    ${rx_combined_all_ants_cli}  Create Requests For All-Ants  NR_FDD  RX_COMBINED
    Check CLI Request Status  ${path}  ${rx_combined_all_ants_cli}  True

step${step_number}: RF Scanning for LTE Composite RX (HBFO) - All Antenna Lines
    [Timeout]  300

    Log to console  ${\n}--------------------------------------------------------------
    Log to console  step${step_number}: RF Scanning for LTE Composite RX (HBFO) - All Antenna Lines
    Log to console  --------------------------------------------------------------${\n}
    Log to console  CLI request for RF Scan for ${RMOD_PRODUCT_NAME} LTE Composite RX (HBFO) - All Antennas - will perform now!${\n}

    ${path}  Set Variable  LTE_Composite_RX_HFBO_${RMOD_PRODUCT_NAME}_ALL_ANTENNAS
    ${rx_combined_all_ants_cli}  Create Requests For All-Ants  LTE_FDD  RX_COMBINED
    Check CLI Request Status  ${path}  ${rx_combined_all_ants_cli}  True

step${step_number}: RF Scanning for WCDMA Composite RX (HBFO) - All Antenna Lines
    [Timeout]  300

    Log to console  ${\n}--------------------------------------------------------------
    Log to console  step${step_number}: RF Scanning for WCDMA Composite RX (HBFO) - All Antenna Lines
    Log to console  --------------------------------------------------------------${\n}
    Log to console  CLI request for RF Scan for ${RMOD_PRODUCT_NAME} WCDMA Composite RX (HBFO) - All Antennas - will perform now!${\n}

    ${path}  Set Variable  WCDMA_Composite_RX_HFBO_${RMOD_PRODUCT_NAME}_ALL_ANTENNAS
    ${rx_combined_all_ants_cli}  Create Requests For All-Ants  WCDMA  RX_COMBINED
    Check CLI Request Status  ${path}  ${rx_combined_all_ants_cli}  True

step${step_number}: RF Scanning for NR Raw Composite Rx (RxADC) - All Antenna Lines
    [Timeout]  300

    Log to console  ${\n}--------------------------------------------------------------
    Log to console  step${step_number}: RF Scanning for NR Raw Composite Rx (RxADC) - All Antenna Lines
    Log to console  --------------------------------------------------------------${\n}
    Log to console  CLI request for RF Scan for ${RMOD_PRODUCT_NAME} NR Raw Composite Rx (RxADC) - All Antennas - will perform now!${\n}

    ${path}  Set Variable  NR_Raw_Composite_Rx_RxADC_${RMOD_PRODUCT_NAME}_ALL_ANTENNAS
    ${rx_combined_all_ants_cli}  Create Requests For All-Ants  NR_FDD  RX_COMBINED_RAW
    Check CLI Request Status  ${path}  ${rx_combined_all_ants_cli}  True

step${step_number}: RF Scanning for LTE Raw Composite Rx (RxADC) - All Antenna Lines
    [Timeout]  300

    Log to console  ${\n}--------------------------------------------------------------
    Log to console  step${step_number}: RF Scanning for LTE Raw Composite Rx (RxADC) - All Antenna Lines
    Log to console  --------------------------------------------------------------${\n}
    Log to console  CLI request for RF Scan for ${RMOD_PRODUCT_NAME} LTE Raw Composite Rx (RxADC) - All Antennas - will perform now!${\n}

    ${path}  Set Variable  LTE_Raw_Composite_Rx_RxADC_${RMOD_PRODUCT_NAME}_ALL_ANTENNAS
    ${rx_combined_all_ants_cli}  Create Requests For All-Ants  LTE_FDD  RX_COMBINED_RAW
    Check CLI Request Status  ${path}  ${rx_combined_all_ants_cli}  True

step${step_number}: RF Scanning for WCDMA Raw Composite Rx (RxADC) - All Antenna Lines
    [Timeout]  300

    Log to console  ${\n}--------------------------------------------------------------
    Log to console  step${step_number}: RF Scanning for WCDMA Raw Composite Rx (RxADC) - All Antenna Lines
    Log to console  --------------------------------------------------------------${\n}
    Log to console  CLI request for RF Scan for ${RMOD_PRODUCT_NAME} WCDMA Raw Composite Rx (RxADC) - All Antennas - will perform now!${\n}

    ${path}  Set Variable  WCDMA_Raw_Composite_Rx_RxADC_${RMOD_PRODUCT_NAME}_ALL_ANTENNAS
    ${rx_combined_all_ants_cli}  Create Requests For All-Ants  WCDMA  RX_COMBINED_RAW
    Check CLI Request Status  ${path}  ${rx_combined_all_ants_cli}  True

step${step_number}: RF Scanning for NR Composite RX (HBFO) - Each Antenna Separately
    [Timeout]  300

    Log to console  ${\n}--------------------------------------------------------------------
    Log to console  step${step_number}: RF Scanning for NR Composite RX (HBFO) - Each Antenna Separately
    Log to console  --------------------------------------------------------------------${\n}

    Log to console  CLI requests for RF Scan for ${RMOD_PRODUCT_NAME} NR Composite RX (HBFO) - Each antenna separately - will perform!${\n}
    ${rx_combined_each_antenna_requests}  Create Requests For Each-Ants  NR_FDD  RX_COMBINED  RX

    FOR  ${request}  IN  @{rx_combined_each_antenna_requests}
        ${antl}  Evaluate  re.search(r'ANTL_R-\\d+', '${request}').group(0)  re
        ${path}  Set Variable  NR_Composite_RX_HFBO_${RMOD_PRODUCT_NAME}_${antl}
        Log to console  Sending request for NR Composite RX (HBFO) ${RMOD_PRODUCT_NAME} ${antl}!${\n}
        Check CLI Request Status  ${path}  ${request}  False
    END

step${step_number}: RF Scanning for LTE Composite RX (HBFO) - Each Antenna Separately
    [Timeout]  300

    Log to console  ${\n}--------------------------------------------------------------------
    Log to console  step${step_number}: RF Scanning for LTE Composite RX (HBFO) - Each Antenna Separately
    Log to console  --------------------------------------------------------------------${\n}

    Log to console  CLI requests for RF Scan for ${RMOD_PRODUCT_NAME} LTE Composite RX (HBFO) - Each antenna separately - will perform!${\n}
    ${rx_combined_each_antenna_requests}  Create Requests For Each-Ants  LTE_FDD  RX_COMBINED  RX

    FOR  ${request}  IN  @{rx_combined_each_antenna_requests}
        ${antl}  Evaluate  re.search(r'ANTL_R-\\d+', '${request}').group(0)  re
        ${path}  Set Variable  LTE_Composite_RX_HFBO_${RMOD_PRODUCT_NAME}_${antl}
        Log to console  Sending request for LTE Composite RX (HBFO) ${RMOD_PRODUCT_NAME} ${antl} !${\n}
        Check CLI Request Status  ${path}  ${request}  False
    END

step${step_number}: RF Scanning for WCDMA Composite RX (HBFO) - Each Antenna Separately
    [Timeout]  300

    Log to console  ${\n}--------------------------------------------------------------------
    Log to console  step${step_number}: RF Scanning for WCDMA Composite RX (HBFO) - Each Antenna Separately
    Log to console  --------------------------------------------------------------------${\n}

    Log to console  CLI requests for RF Scan for ${RMOD_PRODUCT_NAME} WCDMA Composite RX (HBFO) - Each antenna separately - will perform!${\n}
    ${rx_combined_each_antenna_requests}  Create Requests For Each-Ants  WCDMA  RX_COMBINED  RX

    FOR  ${request}  IN  @{rx_combined_each_antenna_requests}
        ${antl}  Evaluate  re.search(r'ANTL_R-\\d+', '${request}').group(0)  re
        ${path}  Set Variable  WCDMA_Composite_RX_HFBO_${RMOD_PRODUCT_NAME}_${antl}
        Log to console  Sending request for WCDMA Composite RX (HBFO) ${RMOD_PRODUCT_NAME} ${antl} !${\n}
        Check CLI Request Status  ${path}  ${request}  False
    END

step${step_number}: RF Scanning for NR Raw Composite Rx (RxADC) - Each Antenna Separately
    [Timeout]  300

    Log to console  ${\n}--------------------------------------------------------------------
    Log to console  step${step_number}: RF Scanning for NR Raw Composite Rx (RxADC) - Each Antenna Separately
    Log to console  --------------------------------------------------------------------${\n}

    Log to console  CLI requests for RF Scan for ${RMOD_PRODUCT_NAME} NR Raw Composite Rx (RxADC) - Each antenna separately - will perform!${\n}
    ${rx_combined_each_antenna_requests}  Create Requests For Each-Ants  NR_FDD  RX_COMBINED_RAW  RX

    FOR  ${request}  IN  @{rx_combined_each_antenna_requests}
        ${antl}  Evaluate  re.search(r'ANTL_R-\\d+', '${request}').group(0)  re
        ${path}  Set Variable  Raw_Composite_Rx_RxADC_${RMOD_PRODUCT_NAME}_${antl}
        Log to console  Sending request for NR Raw Composite Rx (RxADC) ${RMOD_PRODUCT_NAME} ${antl}!${\n}
        Check CLI Request Status  ${path}  ${request}  False
    END

step${step_number}: RF Scanning for LTE Raw Composite Rx (RxADC) - Each Antenna Separately
    [Timeout]  300

    Log to console  ${\n}--------------------------------------------------------------------
    Log to console  step${step_number}: RF Scanning for LTE Raw Composite Rx (RxADC) - Each Antenna Separately
    Log to console  --------------------------------------------------------------------${\n}

    Log to console  CLI requests for RF Scan for ${RMOD_PRODUCT_NAME} LTE Raw Composite Rx (RxADC) - Each antenna separately - will perform!${\n}
    ${rx_combined_each_antenna_requests}  Create Requests For Each-Ants  LTE_FDD  RX_COMBINED_RAW  RX

    FOR  ${request}  IN  @{rx_combined_each_antenna_requests}
        ${antl}  Evaluate  re.search(r'ANTL_R-\\d+', '${request}').group(0)  re
        ${path}  Set Variable  LTE_Raw_Composite_Rx_RxADC_${RMOD_PRODUCT_NAME}_${antl}
        Log to console  Sending request for LTE Raw Composite Rx (RxADC) ${RMOD_PRODUCT_NAME} ${antl} !${\n}
        Check CLI Request Status  ${path}  ${request}  False
    END

step${step_number}: RF Scanning for WCDMA Raw Composite Rx (RxADC) - Each Antenna Separately
    [Timeout]  300

    Log to console  ${\n}--------------------------------------------------------------------
    Log to console  step${step_number}: RF Scanning for WCDMA Raw Composite Rx (RxADC) - Each Antenna Separately
    Log to console  --------------------------------------------------------------------${\n}

    Log to console  CLI requests for RF Scan for ${RMOD_PRODUCT_NAME} WCDMA Raw Composite Rx (RxADC) - Each antenna separately - will perform!${\n}
    ${rx_combined_each_antenna_requests}  Create Requests For Each-Ants  WCDMA  RX_COMBINED_RAW  RX

    FOR  ${request}  IN  @{rx_combined_each_antenna_requests}
        ${antl}  Evaluate  re.search(r'ANTL_R-\\d+', '${request}').group(0)  re
        ${path}  Set Variable  WCDMA_Raw_Composite_Rx_RxADC_${RMOD_PRODUCT_NAME}_${antl}
        Log to console  Sending request for WCDMA Raw Composite Rx (RxADC) ${RMOD_PRODUCT_NAME} ${antl} !${\n}
        Check CLI Request Status  ${path}  ${request}  False
    END

step${step_number}: RF Scanning for NR Carrier RX (FIR9)
    [Timeout]  900

    Log to console  ${\n}--------------------------------------------
    Log to console  step${step_number}: RF Scanning for NR Carrier RX (FIR9)
    Log to console  ---------------------------------------------${\n}

    Log to console  CLI requests for RF Scan for ${RMOD_PRODUCT_NAME} NR Carrier RX (FIB9) will perform now, please wait !${\n}
    ${nr_rx_carrier_each_ants_each_cells}  Create List
    FOR  ${cell}  ${antls}  IN ZIP  ${DICT_OF_NR_WITH_ANTS.keys()}  ${DICT_OF_NR_WITH_ANTS.values()}
        Create Requests For Cell-Ants  NR_FDD  RX_CARRIER  ${cell}  ${antls}  ${nr_rx_carrier_each_ants_each_cells}
    END

    Run Keyword If  not ${nr_rx_carrier_each_ants_each_cells}  Log to console  No NR cells on ${RMOD_PRODUCT_NAME}, going to next step!${\n}

    FOR  ${request}  IN  @{nr_rx_carrier_each_ants_each_cells}
        ${antl}  Evaluate  re.search(r'ANTL_R-\\d+', '${request}').group(0)  re
        ${nr}  Evaluate  re.search(r'NRCELL_R-\\d+', '${request}').group(0)  re
        Log to console   *** Sending request for Carrier RX (FIB9) for cell ${nr} on ${antl} for ${RMOD_PRODUCT_NAME}! ***${\n}
        ${path}  Set Variable  NR_Carrier_RX_FIB9_${RMOD_PRODUCT_NAME}_${nr}_${antl}
        Check CLI Request Status  ${path}  ${request}  False
    END

step${step_number}: RF Scanning for LTE Carrier RX (FIR9)
    [Timeout]  900

    Log to console  ${\n}--------------------------------------------
    Log to console  step${step_number}: RF Scanning for LTE Carrier RX (FIR9)
    Log to console  ---------------------------------------------${\n}

    Log to console  CLI requests for RF Scan for ${RMOD_PRODUCT_NAME} LTE Carrier RX (FIB9) will perform now, please wait !${\n}
    ${lncel_rx_carrier_each_ants_each_cells}  Create List
    FOR  ${cell}  ${antls}  IN ZIP  ${DICT_OF_LNCEL_WITH_ANTS.keys()}  ${DICT_OF_LNCEL_WITH_ANTS.values()}
        Create Requests For Cell-Ants  LTE_FDD  RX_CARRIER  ${cell}  ${antls}  ${lncel_rx_carrier_each_ants_each_cells}
    END

    Run Keyword If  not ${lncel_rx_carrier_each_ants_each_cells}  Log to console  No LTE cells on ${RMOD_PRODUCT_NAME}, going to next step!${\n}

    FOR  ${request}  IN  @{lncel_rx_carrier_each_ants_each_cells}
        ${antl}  Evaluate  re.search(r'ANTL_R-\\d+', '${request}').group(0)  re
        ${lncel}  Evaluate  re.search(r'LNCEL_R-\\d+', '${request}').group(0)  re
        Log to console   *** Sending request for Carrier RX (FIB9) for cell ${lncel} on ${antl} for ${RMOD_PRODUCT_NAME}! ***${\n}
        ${path}  Set Variable  LTE_Carrier_RX_FIB9_${RMOD_PRODUCT_NAME}_${lncel}_${antl}
        Check CLI Request Status  ${path}  ${request}  False
    END

step${step_number}: RF Scanning for WCDMA Carrier RX (FIR9)
    [Timeout]  900

    Log to console  ${\n}--------------------------------------------
    Log to console  step${step_number}: RF Scanning for WCDMA Carrier RX (FIR9)
    Log to console  ---------------------------------------------${\n}

    Log to console  CLI requests for RF Scan for ${RMOD_PRODUCT_NAME} WCDMA Carrier RX (FIB9) will perform now, please wait !${\n}
    ${wncel_rx_carrier_each_ants_each_cells}  Create List
    FOR  ${cell}  ${antls}  IN ZIP  ${DICT_OF_WNCEL_WITH_ANTS.keys()}  ${DICT_OF_WNCEL_WITH_ANTS.values()}
        Create Requests For Cell-Ants  WCDMA  RX_CARRIER  ${cell}  ${antls}  ${wncel_rx_carrier_each_ants_each_cells}
    END

    Run Keyword If  not ${wncel_rx_carrier_each_ants_each_cells}  Log to console  No WCDMA cells on ${RMOD_PRODUCT_NAME}, going to next step!${\n}

    FOR  ${request}  IN  @{wncel_rx_carrier_each_ants_each_cells}
        ${antl}  Evaluate  re.search(r'ANTL_R-\\d+', '${request}').group(0)  re
        ${wncel}  Evaluate  re.search(r'WNCEL_R-\\d+', '${request}').group(0)  re
        Log to console   *** Sending request for Carrier RX (FIB9) for cell ${wncel} on ${antl} for ${RMOD_PRODUCT_NAME}! ***${\n}
        ${path}  Set Variable  WCDMA_Carrier_RX_FIB9_${RMOD_PRODUCT_NAME}_${wncel}_${antl}
        Check CLI Request Status  ${path}  ${request}  False
    END

step${step_number}: RF Scanning for NR Feedback Tx (PDRx)
    [Timeout]  900

    Log to console  ${\n}--------------------------------------------------------------------
    Log to console  step${step_number}: RF Scanning for NR Feedback Tx (PDRx)
    Log to console  --------------------------------------------------------------------${\n}

    ${cells_active_TM}  Run Keyword If  ${ACTIVE_TDS}  Start Downlink NR TestModel For Required Antennas
    Selenium Login And Disable Screen Lock
    selenium_coam.change_bts_rnd_parameters  69  Dynamic changes  [{"paramIndexNumber":39, "paramValue":1}]   timeout=${100}
    Sleep  30
    Selenium Logout And Close Browser
    Sleep  10
    Selenium Login And Disable Screen Lock  download_dir=${TestFiles}/TX_FEEDBACK
    Sleep  10
    ${radio_nr}  Fetch From Right  ${RMOD_CONFIG_ID}  -
    FOR  ${antl}  IN  @{ALL_ANTS_TX}
        Log to console  Sending request for NR Feedback Tx (PDRx) ${RMOD_PRODUCT_NAME} ${antl}!${\n}
        ${antl_nr}  Fetch From Right  ${antl}  -
        Check TX Requests For Each-Ants  technology=NR FDD  radio=RMOD-${radio_nr} (${RMOD_PRODUCT_NAME})
        ...  capture_type=Feedback Tx (PDRx)  atenna=ANT ${antl_nr}
    END
    Selenium Logout And Close Browser
    Run Keyword If  ${ACTIVE_TDS}  Stop Active Downlink NR TestModel  ${cells_active_TM}

step${step_number}: RF Scanning for LTE Feedback Tx (PDRx)
    [Timeout]  600

    Log to console  ${\n}--------------------------------------------------------------------
    Log to console  step${step_number}: RF Scanning for LTE Feedback Tx (PDRx)
    Log to console  --------------------------------------------------------------------${\n}

    ${cells_active_TM}  Run Keyword If  ${ACTIVE_TDS}  Start Downlink LTE TestModel For Required Antennas
    Selenium Login And Disable Screen Lock
    selenium_coam.change_bts_rnd_parameters  69  Dynamic changes  [{"paramIndexNumber":39, "paramValue":1}]   timeout=${100}
    Sleep  30
    Selenium Logout And Close Browser
    Sleep  10
    Selenium Login And Disable Screen Lock  download_dir=${TestFiles}/TX_FEEDBACK
    Sleep  10
    ${radio_nr}  Fetch From Right  ${RMOD_CONFIG_ID}  -
    FOR  ${antl}  IN  @{ALL_ANTS_TX}
        Log to console  Sending request for LTE Feedback Tx (PDRx) ${RMOD_PRODUCT_NAME} ${antl}!${\n}
        ${antl_nr}  Fetch From Right  ${antl}  -
        Check TX Requests For Each-Ants  technology=LTE FDD  radio=RMOD-${radio_nr} (${RMOD_PRODUCT_NAME})
        ...  capture_type=Feedback Tx (PDRx)  atenna=ANT ${antl_nr}
    END
    Selenium Logout And Close Browser
    Run Keyword If  ${ACTIVE_TDS}  Stop Active Downlink LTE TestModel  ${cells_active_TM}

step${step_number}: RF Scanning for WCDMA Feedback Tx (PDRx)
    [Timeout]  600

    Log to console  ${\n}--------------------------------------------------------------------
    Log to console  step${step_number}: RF Scanning for WCDMA Feedback Tx (PDRx)
    Log to console  --------------------------------------------------------------------${\n}

    Selenium Login And Disable Screen Lock
    selenium_coam.change_bts_rnd_parameters  69  Dynamic changes  [{"paramIndexNumber":39, "paramValue":1}]   timeout=${100}
    Sleep  30
    Selenium Logout And Close Browser
    Sleep  10
    Selenium Login And Disable Screen Lock  download_dir=${TestFiles}/TX_FEEDBACK
    Sleep  10
    ${radio_nr}  Fetch From Right  ${RMOD_CONFIG_ID}  -
    FOR  ${antl}  IN  @{ALL_ANTS_TX}
        Log to console  Sending request for WCDMA Feedback Tx (PDRx) ${RMOD_PRODUCT_NAME} ${antl}!${\n}
        ${antl_nr}  Fetch From Right  ${antl}  -
        Check TX Requests For Each-Ants  technology=WCDMA  radio=RMOD-${radio_nr} (${RMOD_PRODUCT_NAME})
        ...  capture_type=Feedback Tx (PDRx)  atenna=ANT ${antl_nr}
    END
    Selenium Logout And Close Browser

step${step_number}: Check Cancel Requests for NR Composite Rx (HBF0)
    [Timeout]  900

    Log to console  ${\n}--------------------------------------------------------------------
    Log to console  step${step_number}: Check Cancel Requests for NR Composite Rx (HBF0)
    Log to console  --------------------------------------------------------------------${\n}

    Selenium Login And Disable Screen Lock  download_dir=${TestFiles}/TX_FEEDBACK
    Sleep  10
    ${radio_nr}  Fetch From Right  ${RMOD_CONFIG_ID}  -
    Check Cancel Requests For All Antennas  technology=NR FDD  radio=RMOD-${radio_nr} (${RMOD_PRODUCT_NAME})
    ...  capture_type=Composite Rx (HBF0)  atenna=All Antennas
    Selenium Logout And Close Browser

step${step_number}: Exit From Test Dedicated State

    Log to console  --------------------------------------
    Log to console  step${step_number}: Exit From Test Dedicated State
    Log to console  --------------------------------------${\n}

    Log to console  Exiting Test Dedicated State...

    admin.Reset Site  timeout=1200  connection=${node}

    Wait Until Keyword Succeeds  40min  10s  Check MrBTS State  expected_state=OnAir

    ${cell_status}  Run Keyword And Return Status  Check If All Cells Are onAir  alias=${node}  timeout=120
    Run Keyword If  '${cell_status}'=='True'
    ...  Log to console  All cells are onAir !${\n}
    ...  ELSE
    ...  Fail  Cells doesn't reach onAir state!
    Set Test Variable  ${ACTIVE_TDS}  ${FALSE}

step${step_number}: Postconditions

    Log to console  ${\n}----------------------
    Log to console  step${step_number}: Postconditions
    Log to console  ----------------------${\n}

    Log to console  Deactivating RF Interference testing function by parameter recommissioning, please wait !${\n}
    admin.Perform Parameter Recommissioning  ${OBJECT_VARIABLE_RFI}  actRfiTesting  update  false  alias=${node}
    Check If All Cells Are OnAir

    Log to console  Deactivating Admin CLI Feature, please wait !${\n}
    admin.Perform Parameter Recommissioning  ${OBJECT_VARIABLE_RFI}  actCli  update  false  alias=${node}
    Check If All Cells Are OnAir

    Log to console  All postconditions are met, TC passed!${\n}

Check Antenna Lines For Cell
    [Documentation]  KW checks on which antenna lines given CELL has TX/RX carriers.
    [Arguments]  ${rat}   ${search_direction}  ${cell_distnames}  ${dict_with_ants}

    ${whole_list}  admin.Get Cell List  connection=${node}
    ${wcdma_cells_info}  Run Keyword If  '${rat}'=='LNCEL'  Evaluate  (${whole_list}\['cells']['lte'])
    ...  ELSE IF  '${rat}'=='NR'  Evaluate  (${whole_list}\['cells']['nr'])
    ...  ELSE  Evaluate  (${whole_list}\['cells']['wcdma'])

    FOR  ${cell_info}  IN  @{wcdma_cells_info}
      ${cell_distname}  Evaluate  ${cell_info}\['id']['internal']
      Continue For Loop If  '${cell_distname}' not in ${cell_distnames}
      ${carriers_list}  Evaluate  (${cell_info}\['carrierList'])
      Carrier List Iterator For Antenna Lines  ${carriers_list}  ${cell_distname}  ${dict_with_ants}  ${search_direction}
    END

Carrier List Iterator For Antenna Lines
    [Arguments]  ${carrier_list}  ${cell_id_from_admin}  ${DICT_CELL_ANTS}  ${search_direction}

    FOR  ${carrier}  IN  @{carrier_list}
        ${direction}  Get From Dictionary  ${carrier}  direction
        Continue For Loop If  '${direction}'!='${search_direction}'
        ${antl}  Evaluate  (${carrier}\['antennaLineId']['internal'])
        ${rmod_dst}  Evaluate  '${antl}'.rsplit('/', 1)[0]
        Continue For Loop If  '${rmod_dst}'!='${RMOD_DISTNAME_ID}'
        Append To List  ${DICT_CELL_ANTS}[${cell_id_from_admin}]  ${antl}
        Append To List  ${ALL_ANTS_${search_direction}}  ${antl}
    END

Create Requests For Cell-Ants
    [Arguments]  ${technology}  ${captureType}  ${cell}  ${antls_list}  ${list_with_requests}

    FOR  ${antl}  IN  @{antls_list}
        ${rx_carrier_one_ant_one_cell}  Catenate
        ...  {
        ...      "requestId": 1,
        ...      "requestType": "procedure",
        ...      "parameters": {
        ...          "name": "startRFScanningTest",
        ...          "parameters": {
        ...              "technology": "${technology}",
        ...              "radioDN": "${RMOD_DISTNAME_ID}",
        ...              "antennaDN": "${antl}",
        ...              "captureType": "${captureType}",
        ...              "cellDN": "${cell}"
        ...          }
        ...      }
        ...  }
        Append to list  ${list_with_requests}  ${rx_carrier_one_ant_one_cell}
    END

Create Requests For All-Ants
    [Arguments]  ${technology}  ${captureType}
    ##### RF Scanning for RX_COMBINED - ALL ANTENNA LINES #####
    ${rx_combined_all_ants_cli}  Catenate
    ...  {
    ...      "requestId": 1,
    ...      "requestType": "procedure",
    ...      "parameters": {
    ...          "name": "startRFScanningTest",
    ...          "parameters": {
    ...              "technology": "${technology}",
    ...              "radioDN": "${RMOD_DISTNAME_ID}",
    ...              "captureType": "${captureType}"
    ...          }
    ...      }
    ...  }

    [Return]  ${rx_combined_all_ants_cli}

Create Requests For Each-Ants
    [Arguments]  ${technology}  ${captureType}  ${direction}
    ##### RF Scanning for RX_COMBINED - EACH ANTENNA LINES SEPARATELY #####
    ${rx_combined_each_antenna_requests}  Create List

    FOR  ${antl}  IN  @{ALL_ANTS_${direction}}
        ${rx_combined_one_ant_cli}  Catenate
        ...  {
        ...      "requestId": 123,
        ...      "requestType": "procedure",
        ...      "parameters": {
        ...          "name": "startRFScanningTest",
        ...          "parameters": {
        ...              "technology": "${technology}",
        ...              "radioDN": "${RMOD_DISTNAME_ID}",
        ...              "antennaDN": "${antl}",
        ...              "captureType": "${captureType}"
        ...          }
        ...      }
        ...  }
        Append to list  ${rx_combined_each_antenna_requests}  ${rx_combined_one_ant_cli}
    END

    [Return]  ${rx_combined_each_antenna_requests}

Check TX Requests For Each-Ants
    [Arguments]    ${technology}  ${radio}  ${capture_type}
    ...   ${atenna}  ${antenna_panel}=${NONE}  ${local_cell}=${NONE}
    Log To Console  \n Start ${technology} RF Scanning ${capture_type}
    selenium_coam.start_rf_scan   ${technology}   ${radio}
	...    ${capture_type}   ${atenna}  ${local_cell}  timeout=${300}
	${path}  selenium_coam.download_rf_scan_files   download_timeout=${120}
	${path_zip}  Fetch From Right  ${path}  /
	${path_zip}  Fetch From Left  ${path_zip}  .
	${mv_result}  Run and Return RC  mv "${path}" "${TestFiles}"
    Run Keyword If  ${mv_result}!=0
    ...  Run Keyword And Continue On Failure  Fail  Cannot move file ${path}.zip, maybe doesn't exists?
	Unzip File  ${path_zip}  all_antennas=False

Check Cancel Requests For All Antennas
    [Arguments]    ${technology}  ${radio}  ${capture_type}
    ...   ${atenna}  ${antenna_panel}=${NONE}  ${local_cell}=${NONE}
    Log To Console  \n Start ${technology} RF Scanning ${capture_type}
    selenium_coam.start_rf_scan   ${technology}   ${radio}
	...    ${capture_type}   ${atenna}  ${local_cell}  timeout=${300}
	Log To Console  \n Cancel ${technology} RF Scanning ${capture_type}
	${path}  Run Keyword And Ignore Error  selenium_coam.cancel_rf_scan
	Run Keyword If  '${path[0]}'=='FAIL'  Run Keyword And Continue On Failure  Fail  Cancel request not stop ongoing RF Scan capturing.
	...  ELSE IF  '${path[1]}'=='Canceled'  Log To Console  Request finished with status Canceled!

Check CLI Request Status
    [Arguments]  ${path}  ${request}  ${all_antennas}

    ${response}  admin_cli.Send Admin CLI request  ${request}  output_file=${TestFiles}/${path}.zip
    ${requestStatus}  Get from Dictionary  ${response}  requestStatus
    ${errorCode}  Get From Dictionary  ${response}  errorCode
    ${errorDesc}  Set ErrorCode  ${errorCode}
    Run Keyword If  '${errorCode}'!='0'  Run Keywords
    ...  Run Keyword And Continue On Failure  Fail  Error when request processing ${path}, errorCode: ${errorCode} - ${errorDesc}
    ...  AND  Return From Keyword
    ...  ELSE  Log to console  Request For ${path} completed successfully!${\n}
    Unzip File  ${path}  all_antennas=${all_antennas}

Unzip File
    [Arguments]  ${path}  ${all_antennas}

    Log to console  Unzipping ${path}.zip ... !${\n}
    ${command_to_unzip}  Set Variable  unzip "${TestFiles}/${path}.zip" -d "${TestFiles}/${path}"
    ${result}  Run and Return RC  ${command_to_unzip}
    Run Keyword If  ${result}!=0  Run Keywords
    ...  Run Keyword And Continue On Failure  Fail  Cannot unzip file ${path}.zip, maybe doesn't exists?
    ...  AND  Return From Keyword
    Run Keyword If  '${all_antennas}'=='True'  Unzip All Subfiles  ${path}
    ...  ELSE  Check RFCap And XML file  ${path}

Unzip All Subfiles
    [Arguments]  ${path}

    Log to console  Unzipping all .zip subfiles !${\n}
    ${list_of_files}  OperatingSystem.List Directory  ${TestFiles}/${path}
    FOR  ${zip_path}  IN  @{list_of_files}
        ${dictionary}  Evaluate  '${zip_path}'.rsplit('.', 1)[0]
        ${command_to_unzip}  Set Variable  unzip "${TestFiles}/${path}/${zip_path}" -d "${TestFiles}/${path}/${dictionary}"
        ${result}  Run and Return RC  ${command_to_unzip}
        Run Keyword If  ${result}!=0  Run Keywords
        ...  Run Keyword And Continue On Failure  Fail  Cannot unzip file ${zip_path}, maybe doesn't exists?
        ...  AND  Continue For Loop
        Check RFCap And XML file  ${path}/${dictionary}
    END

    Remove Unzipped Dictionary  ${path}


Check RFCap And XML File
    [Arguments]  ${path}

    Log to console  Checking number of RFCap and XML files in zip ${path} ... ${\n}

    ${list_of_files}  OperatingSystem.List Directory  ${TestFiles}/${path}
    ${count_all_files}  Evaluate  len(${list_of_files})

    ${rfcap_files}  Evaluate  [ i for i in ${list_of_files} if i.endswith('.rfcap')]
    ${rfcap_count}  Evaluate  len(${rfcap_files})

    ${xml_files}  Evaluate  [ i for i in ${list_of_files} if i.endswith('.xml')]
    ${xml_count}  Evaluate  len(${xml_files})

    ${rfcap_status}  Run Keyword And Return Status  Should Be Equal As Integers  ${count_all_files}  ${rfcap_count+1}

    ${xml_status}  Run Keyword And Return Status  Should Be Equal As Integers  ${xml_count}  1

    Log to console  Number of .rfcap files: ${rfcap_count}${\n}Number of .xml files: ${xml_count}${\n}

    Run Keyword If  '${rfcap_status}'=='False' or '${xml_status}'=='False'
    ...  Run Keyword And Continue On Failure  Fail  Number of .rfcap files doesn't meet conditions!
    ...  ELSE  Log to console  Number of .rfcap and .xml files is correct !${\n}

    Remove Unzipped Dictionary  ${path}

Remove Unzipped Dictionary
    [Arguments]  ${path}

    Run  rm "${TestFiles}/${path}.zip"
    ${result}  Run and Return RC  rm -r "${TestFiles}/${path}"
    Run Keyword If  ${result}!=0  Log to console  Cannot remove dictionary ${path}!
    ...  ELSE  Log to console  Directory ${path} removed successfully !${\n}

Set ErrorCode
    [Arguments]  ${errorCode}

    ${desc}=  Set Variable If
        ...   ${errorCode}==0  OK
        ...   ${errorCode}==3  Invalid parameters
        ...   ${errorCode}==7  Unexpected error
        ...   ${errorCode}==70  Object not found: used for invalid object DN as input parameter
        ...   ${errorCode}==174  Feature flag 'actRfiTesting' is not true
        ...   ${errorCode}==175  RF Scan is only supported when BTS is in onAir mode or in TDS mode
        ...   ${errorCode}==176  RF scan on the technology value is only supported in onAir mode

    [Return]  ${desc}

Start Downlink NR TestModel For Required Antennas
    @{BEAM_PATTERN_ID}  Create List  ${1}
    @{cells_active_TM}  Create List
    ${cells}  Get Dictionary Keys  ${DICT_OF_NR_WITH_ANTS}
    FOR  ${cell}  IN  @{cells}
        ${antls}  Get From Dictionary  ${DICT_OF_NR_WITH_ANTS}  ${cell}
        ${antls}  Remove Duplicates  ${antls}
        Sort List  ${antls}
        Sort List  ${ALL_ANTS_TX}
        ${tm_antls}  Run Keyword And Return Status  Lists Should Be Equal  ${antls}  ${ALL_ANTS_TX}  ignore_order=True
        Continue For Loop If  '${tm_antls}'=='False'
        admin.Start 5G Downlink Test  ${cell}  TM1_1  ${BEAM_PATTERN_ID}  P_both  0  NR_Only  1  0  0  0  0  1  connection=${node}
        Log To Console  Start Downlink NR TestModel for cell ${cell}.
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
        Sort List  ${ALL_ANTS_TX}
        ${tm_antls}  Run Keyword And Return Status  Lists Should Be Equal  ${antls}  ${ALL_ANTS_TX}  ignore_order=True
        Continue For Loop If  '${tm_antls}'=='False'
        ${cell_parameters}  admin.Get Parameters For  LNCEL  ${cell}  connection=${node}
        admin.Start Downlink Test  ${cell}  E_TM1_1  ${cell_parameters.earfcnDL}  phy_cell_id=1  connection=${node}
        Log To Console  Start Downlink LTE TestModel for cell ${cell}.
        Append To List  ${cells_active_TM}  ${cell}
        Sleep  10s
    END
    [Return]  ${cells_active_TM}

Stop Active Downlink NR TestModel
    [Arguments]  ${cells_active_TM}
    FOR  ${cell}  IN  @{cells_active_TM}
        ${status}  Run Keyword And Return Status  admin.Stop 5G Downlink Test  ${cell}  connection=${node}
        Log To Console  Stop Downlink NR TestModel for cell ${cell}.
        Sleep  10s
        Run Keyword If  not ${status}  Run Keyword And Continue On Failure  Fail  Downlink NR TM doesn't stop correctly!
    END

Stop Active Downlink LTE TestModel
    [Arguments]  ${cells_active_TM}
    FOR  ${cell}  IN  @{cells_active_TM}
        ${status}  Run Keyword And Return Status  admin.Stop Downlink Test  ${cell}  connection=${node}
        Log To Console  Stop Downlink LTE TestModel for cell ${cell}.
        Sleep  10s
        Run Keyword If  not ${status}  Run Keyword And Continue On Failure  Fail  Downlink LTE TM doesn't stop correctly !
    END

Selenium Login And Disable Screen Lock
    [Arguments]    ${download_dir}=${EMPTY}
    selenium_coam.enable_virtual_display
    ${browser}=  selenium_coam.Create Firefox Browser  download_dir=${download_dir}  name=firefox_browser
    ${sw_release}    admin.Get Sw Release Name
    selenium_coam.login   ${WEBUI_URL}   ${WEBUI_NAME}   ${WEBUI_PWD}  download_dir=${download_dir}  version=${sw_release}  browser=${browser}
    Run Keyword And Ignore Error   selenium_coam.close_start_up_view_window
    selenium_coam.disable_message_box
    selenium_coam.disable_screen_lock

Selenium Logout And Close Browser
    Run Keyword And Ignore Error    selenium_coam.logout
#    Run Keyword And Ignore Error    selenium_coam.disable_virtual_display
    Run Keyword And Ignore Error    selenium_coam.close_browser
