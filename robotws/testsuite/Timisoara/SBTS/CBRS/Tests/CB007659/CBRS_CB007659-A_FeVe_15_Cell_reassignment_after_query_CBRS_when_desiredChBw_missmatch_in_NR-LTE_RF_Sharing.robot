*** Settings ***
Documentation
...    = Author =
...    _aleksandra.chudzik@nokia.com_
...    = Maintainer =
...    _aleksandra.chudzik@nokia.com_
...    = Reviewer =
...    lukasz.lechowicz@nokia.com
...    piotr.lukaszewicz@nokia.com
...    karol.sadowski@nokia.com
...    katarzyna.kadziela@nokia.com

*** Keywords ***
CBRS_CB007659-A_FeVe_15_Cell_reassignment_after_query_CBRS_when_desiredChBw_missmatch_in_NR-LTE_RF_Sharing
    [Documentation]    Tested Requirement: OM_GEN_SFS_CBRS.485
    ...                Purpose: Test case verifies reassignment of cell which is not assigned with desiredChBw
    ...                when Query SAS Server Timer is expired in a NR-LTE RF Sharing site. cbrsFreqType is set
    ...                to PAL and wINNFTSV is less than 2.0. LTE cell cannot assign to frequency blocked by gNB until
    ...                volatile MOs are removed after grant is relinquished.
    ...                This automated testcase is designed only for double BTS (LTE-NR) setup with RF sharing.

    [Timeout]    40min

    #Variables setup
    Log To Console    ${\n}Preconditions
    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${gnb_id}   Set Variable    ${testlines.${testline_id}.node2.enb_id}
    ${enb_smod_sn}   Get Serial Number Of System Module
    ${gnb_smod_sn}   Get Serial Number Of System Module    alias=RAT_2ND
    &{expected_alarm}   Create Dictionary    fault_id=6823    fault_name=SAS Grant Termination Revocation Failure
    ...                                        severity=Critical    reason=Heartbeat Exception with Reason: 500.
    ${num_of_enb_cells}   Get Number of Cells    enb_id=${enb_id}
    ${num_of_gnb_cells}   Get Number of 5G Cells    gnb_id=${gnb_id}    alias=RAT_2ND

    # Check if number of cells in eNB configuration is supported by test scenario
    IF  '${num_of_enb_cells}'!='${3}'  Fail  Configuration with ${num_of_enb_cells} eNB cell(s) is not supported by this scenario

    # Check if number of cells in gNB configuration is supported by test scenario
    IF  '${num_of_gnb_cells}'!='${1}'  Fail  Configuration with ${num_of_gnb_cells} gNB cell(s) is not supported by this scenario

    #Make sure there is no active legacy SAS connection
    Kill All SAS Processes
    Check If Cells Are Disabled    enb_id=${enb_id}
    Check If 5G Cells Are Disabled    gnb_id=${gnb_id}    alias=RAT_2ND

    Replace Variables In File
    ...    ${CURDIR}/Data/FeVe_15/precondition_delta.json
    ...    ${OUTPUT_DIR}/precondition_delta.json    enb_id=${enb_id}
    Replace Variables In File
    ...    ${CURDIR}/Data/FeVe_15/postcondition_delta.json
    ...    ${OUTPUT_DIR}/postcondition_delta.json    enb_id=${enb_id}
    Replace Variables In File
    ...    ${CURDIR}/Data/FeVe_15/precondition_delta_5G.json
    ...    ${OUTPUT_DIR}/precondition_delta_5G.json    enb_id=${gnb_id}
    Replace Variables In File
    ...    ${CURDIR}/Data/FeVe_15/postcondition_delta_5G.json
    ...    ${OUTPUT_DIR}/postcondition_delta_5G.json    enb_id=${gnb_id}

    Wait Until Keyword Succeeds    4x    30s    Run Keywords
    ...    Wait Until BTS Is Not Busy    alias=RAT_2ND    AND    #supportedSpectrumV2 = 3610-3630MHz
    ...    Perform Delta Recommissioning    ${OUTPUT_DIR}/precondition_delta_5G.json    connection=RAT_2ND
    Disable CBRS Feature On eNB    alias=RAT_1ST    #to make sure gNB aquires grant before eNB

    Log To Console    ${\n}Step 1. Start SAS Simulator, pal_reserved_channel = 3610,3620
    ${sas_pid}    ${sas_log} =    Start SAS Process    config=${CURDIR}/Data/FeVe_15/SAS_Sim.conf
    Log To Console    Waiting for onAir state on gNB...
    Wait For 5G Cells To Be OnAir    alias=RAT_2ND
    Start Watchdog Alarm Detection    alias=RAT_2ND

    Log To Console    Precondition on eNB ongoing and waiting for onAir state...
    Enable CBRS Feature On eNB    alias=RAT_1ST
    #supportedSpectrumV2 = 3550-3560,3570-3580,3590-3600,3610-3630,3650-3670
    Wait Until Keyword Succeeds    4x    30s    Run Keywords
    ...    Wait Until BTS Is Not Busy    alias=RAT_1ST    AND
    ...    Perform Delta Recommissioning    ${OUTPUT_DIR}/precondition_delta.json    connection=RAT_1ST

    Wait For All Cells To Be OnAir    alias=RAT_1ST
    Start Watchdog Alarm Detection

    Log To Console    ${\n}Step 2. Terminate grant for chosen cell
    ${active_grant_list}   List Values of GrantId For All Cells    ${enb_id}
    ${cbsd_id}   Fetch CBSD ID    ${enb_id}
    ${termination_candidate}   Set Variable    3650000000_3670000000
    ${termination_timestamp}   Get Time
    Add Fault To Watchdog Ignored List    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                   severity=${expected_alarm}[severity]    reason=${expected_alarm}[reason]
    Terminate Grant And Confirm Cell Drop    cbsd_id=${cbsd_id}    grant_id=${termination_candidate}
    Wait For Watchdog Alarm Activation    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                   severity=${expected_alarm}[severity]    reason=${expected_alarm}[reason]    timeout=60
    Wait Until Enhanced Measure Finish    listening_timestamp=${termination_timestamp}    wait_time=5min
    Wait For Watchdog Alarm Deactivation    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                     severity=${expected_alarm}[severity]    reason=${expected_alarm}[reason]    timeout=90
    Remove Fault From Watchdog Ignored List    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                        severity=${expected_alarm}[severity]    reason=${expected_alarm}[reason]
    Wait For All Cells To Be OnAir    alias=RAT_1ST

    ${new_active_grant_list}   List Values of GrantId For All Cells    ${enb_id}
    Should Not Be Equal    ${new_active_grant_list}    ${active_grant_list}

    # Check if after grant termination target cell changed chBw to 10MHz
    Wait Until Keyword Succeeds    3x    10s    Query Infomodel    alias=RAT_1ST
    ...    query=check /MRBTS-1/RAT-1/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-1/LNCEL_M-1 is [ulChBw=10000000]

    Log To Console    ${\n}Step 3. Check creation of "locks" for the corresponding frequency blocks
    ${enb_freq_block_id}   Get Freq Block Id For A Given Smod Serial Number    smod_serial_num=${enb_smod_sn}
    ${gnb_freq_block_id}   Get Freq Block Id For A Given Smod Serial Number    smod_serial_num=${gnb_smod_sn}
    Verify Cbrs Frequency Block Inside The Info Model    freq_block_id=${enb_freq_block_id}
    ...    alias_for_grant_info=RAT_1ST    alias_for_freq_block=RAT_1ST
    Verify Cbrs Frequency Block Inside The Info Model    freq_block_id=${gnb_freq_block_id}
    ...    alias_for_grant_info=RAT_2ND    alias_for_freq_block=RAT_1ST

    Log To Console    ${\n}Step 4. Set actNrCbrs flag on false
    Disable CBRS Feature On gNB    alias=RAT_2ND    target_gnb=${gnb_id}
    Check If 5G Cells Are Disabled    gnb_id=${gnb_id}    alias=RAT_2ND

    Log To Console    ${\n}Step 5. Waiting for querySasServerPeriod expiration...
    ${querySasServerPeriod}   Get Value Of querySasServerPeriod    ${enb_id}    RAT_1ST
    #waiting for periodical spectrumInquiry to check whether spectrum compatible with cbrsFreqType and chBw is available
    Sleep    ${querySasServerPeriod+20}

    Log To Console    ${\n}Step 6. Read channel types from Infomodel
    ${grantChannelType_cell_1}   Get Channel Type For Cell    enb_id=${enb_id}    cell_number=1
    ${grantChannelType_cell_2}   Get Channel Type For Cell    enb_id=${enb_id}    cell_number=2
    ${grantChannelType_cell_3}   Get Channel Type For Cell    enb_id=${enb_id}    cell_number=3

    Should Be Equal    ${grantChannelType_cell_1}    PAL    #channel released by gNB
    Should Be Equal    ${grantChannelType_cell_2}    GAA
    Should Be Equal    ${grantChannelType_cell_3}    GAA

    # Check if after querySasServerPeriod target cell is reconfigured and assigned with desiredChBw
    Wait Until Keyword Succeeds    3x    10s    Query Infomodel    alias=RAT_1ST
    ...    query=check /MRBTS-1/RAT-1/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-1/LNCEL_M-1 is [ulChBw=20000000]

    Log To Console    ${\n}Step 7. Check creation of new "locks" for the corresponding frequency blocks
    ${enb_freq_block_id}   Get Freq Block Id For A Given Smod Serial Number    smod_serial_num=${enb_smod_sn}
    Verify Cbrs Frequency Block Inside The Info Model    freq_block_id=${enb_freq_block_id}
    ...    alias_for_grant_info=RAT_1ST    alias_for_freq_block=RAT_1ST

    [Teardown]    Run Keywords
    ...    Get SAS Logs To Logs Dir    alias=default    AND
    ...    Wait Until Keyword Succeeds    5x    30s    taf.sbts.oam.coam.admin.Perform Delta Recommissioning
           ...    ${OUTPUT_DIR}/postcondition_delta.json    connection=RAT_1ST    AND
    ...    Wait Until Keyword Succeeds    5x    30s    taf.sbts.oam.coam.admin.Perform Delta Recommissioning
           ...    ${OUTPUT_DIR}/postcondition_delta_5G.json    connection=RAT_2ND    AND
    ...    Enable CBRS Feature On gNB    alias=RAT_2ND    target_gnb=${gnb_id}    AND
    ...    Stop Watchdog Alarm Detection And Check For Failures    alias=RAT_2ND    AND
    ...    Stop Watchdog Alarm Detection And Check For Failures    AND
    ...    Kill All SAS Processes
