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
CBRS_CB007659-A_FeVe_14_Background_Query_CBRS_spectrum_for_GAA_and_wINNFTSV_less_than_2_while_gNB_onAir
    [Documentation]    Tested Requirement: OM_GEN_SFS_CBRS.485
    ...                Purpose: Test case verifies GAA spectrum selection of cells with different cbrsFreqPriority
    ...                to PAL channels in a NR-LTE RF Sharing site while gNB is operating. cbrsFreqType is set to GAA.
    ...                wINNFTSV is less than 2.0 and Query SAS Server Timer is expired. LTE cell cannot assign to
    ...                frequency blocked by gNB until volatile MOs are removed after grant is relinquished.
    ...                This automated testcase is designed only for double BTS (LTE-NR) setup with RF sharing.

    [Timeout]    35min

    #Variables setup
    Log To Console    ${\n}Preconditions
    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${enb_mrbts_id}   Set Variable    ${testlines.${testline_id}.mrbts_id}
    ${gnb_id}   Set Variable    ${testlines.${testline_id}.node2.enb_id}
    ${gnb_mrbts_id}   Set Variable    ${testlines.${testline_id}.node2.mrbts_id}
    ${enb_smod_sn}   Get Serial Number Of System Module
    ${gnb_smod_sn}   Get Serial Number Of System Module    alias=RAT_2ND
    ${num_of_enb_cells}   Get Number of Cells    enb_id=${enb_id}
    ${num_of_gnb_cells}   Get Number of 5G Cells    gnb_id=${gnb_id}    alias=RAT_2ND    mrbts_gnb_id=${gnb_mrbts_id}

    Replace Variables In File
    ...    ${CURDIR}/Data/FeVe_14/precondition_delta.json
    ...    ${OUTPUT_DIR}/precondition_delta.json    enb_id=${enb_id}    mrbts_id=${enb_mrbts_id}
    Replace Variables In File
    ...    ${CURDIR}/Data/FeVe_14/postcondition_delta.json
    ...    ${OUTPUT_DIR}/postcondition_delta.json    enb_id=${enb_id}    mrbts_id=${enb_mrbts_id}
    Replace Variables In File
    ...    ${CURDIR}/Data/FeVe_14/precondition_delta_5G.json
    ...    ${OUTPUT_DIR}/precondition_delta_5G.json    enb_id=${gnb_id}    mrbts_id=${gnb_mrbts_id}
    Replace Variables In File
    ...    ${CURDIR}/Data/FeVe_14/postcondition_delta_5G.json
    ...    ${OUTPUT_DIR}/postcondition_delta_5G.json    enb_id=${gnb_id}    mrbts_id=${gnb_mrbts_id}

    # Check if number of cells in eNB configuration is supported by test scenario
    IF  '${num_of_enb_cells}'!='${3}'  Fail  Configuration with ${num_of_enb_cells} eNB cell(s) is not supported by this scenario

    # Check if number of cells in gNB configuration is supported by test scenario
    IF  '${num_of_gnb_cells}'!='${1}'  Fail  Configuration with ${num_of_gnb_cells} gNB cell(s) is not supported by this scenario

    Wait Until Keyword Succeeds    4x    30s    Run Keywords
    ...    Wait Until BTS Is Not Busy    alias=RAT_1ST    AND    #supportedSpectrumV2 = 3350-3590MHz
    ...    Perform Delta Recommissioning    ${OUTPUT_DIR}/precondition_delta.json    connection=RAT_1ST
    Wait Until Keyword Succeeds    4x    30s    Run Keywords
    ...    Wait Until BTS Is Not Busy    alias=RAT_2ND    AND    #supportedSpectrumV2 = 3580-3600MHz
    ...    Perform Delta Recommissioning    ${OUTPUT_DIR}/precondition_delta_5G.json    connection=RAT_2ND

    #Make sure there is no active legacy SAS connection
    Kill All SAS Processes
    Disable CBRS Feature On eNB    alias=RAT_1ST
    Check If Cells Are Disabled    enb_id=${enb_id}
    Check If 5G Cells Are Disabled    gnb_id=${gnb_id}    alias=RAT_2ND

    Log To Console    ${\n}Step 1. Start SAS Simulator, pal_reserved_channel = 3550,3560
    ${sas_pid}    ${sas_log} =    Start SAS Process    config=${CURDIR}/Data/FeVe_14/SAS_Sim.conf
    Log To Console    Waiting for onAir state...
    Wait For 5G Cells To Be OnAir    alias=RAT_2ND
    Enable CBRS Feature On eNB    alias=RAT_1ST    #to make sure gNB aquires grant before eNB
    Wait For All Cells To Be OnAir    alias=RAT_1ST
    Start Watchdog Alarm Detection
    Start Watchdog Alarm Detection    alias=RAT_2ND

    Log To Console    ${\n}Read channel types from Infomodel
    ${grantChannelType_cell_1}   Get Channel Type For Cell    enb_id=${enb_id}    cell_number=1
    ${grantChannelType_cell_2}   Get Channel Type For Cell    enb_id=${enb_id}    cell_number=2
    ${grantChannelType_cell_3}   Get Channel Type For Cell    enb_id=${enb_id}    cell_number=3

    Should Be Equal    ${grantChannelType_cell_1}    PAL
    Should Be Equal    ${grantChannelType_cell_2}    PAL
    Should Be Equal    ${grantChannelType_cell_3}    GAA

    Log To Console    ${\n}Step 2. Check creation of "locks" for the corresponding frequency blocks
    ${enb_freq_block_id}   Get Freq Block Id For A Given Smod Serial Number    smod_serial_num=${enb_smod_sn}
    ${gnb_freq_block_id}   Get Freq Block Id For A Given Smod Serial Number    smod_serial_num=${gnb_smod_sn}
    Verify Cbrs Frequency Block Inside The Info Model    freq_block_id=${enb_freq_block_id}
    ...    alias_for_grant_info=RAT_1ST    alias_for_freq_block=RAT_1ST
    Verify Cbrs Frequency Block Inside The Info Model    freq_block_id=${gnb_freq_block_id}
    ...    alias_for_grant_info=RAT_2ND    alias_for_freq_block=RAT_1ST

    Log To Console    ${\n}Step 3. Set actNrCbrs flag on false
    Disable CBRS Feature On gNB    alias=RAT_2ND    target_gnb=${gnb_id}    target_gnb_mrbts=${gnb_mrbts_id}
    Check If 5G Cells Are Disabled    gnb_id=${gnb_id}    alias=RAT_2ND

    Log To Console    ${\n}Step 4. Waiting for querySasServerPeriod expiration...
    ${querySasServerPeriod}   Get Value Of querySasServerPeriod    ${enb_id}    RAT_1ST
    #waiting for periodical spectrumInquiry to check whether spectrum compatible with cbrsFreqType is available
    Sleep    ${querySasServerPeriod+20}

    Log To Console    ${\n}Step 5. Read channel types from Infomodel
    ${grantChannelType_cell_1}   Get Channel Type For Cell    enb_id=${enb_id}    cell_number=1
    ${grantChannelType_cell_2}   Get Channel Type For Cell    enb_id=${enb_id}    cell_number=2
    ${grantChannelType_cell_3}   Get Channel Type For Cell    enb_id=${enb_id}    cell_number=3

    Should Be Equal    ${grantChannelType_cell_1}    PAL
    Should Be Equal    ${grantChannelType_cell_2}    GAA    #channel released by gNB
    Should Be Equal    ${grantChannelType_cell_3}    GAA

    Log To Console    ${\n}Step 6. Check creation of new "locks" for the corresponding frequency blocks
    ${enb_freq_block_id}   Get Freq Block Id For A Given Smod Serial Number    smod_serial_num=${enb_smod_sn}
    Verify Cbrs Frequency Block Inside The Info Model    freq_block_id=${enb_freq_block_id}
    ...    alias_for_grant_info=RAT_1ST    alias_for_freq_block=RAT_1ST

    [Teardown]    Run Keywords
    ...    Get SAS Logs To Logs Dir    alias=default    AND
    ...    Wait Until Keyword Succeeds    5x    30s    Perform Delta Recommissioning
           ...    ${OUTPUT_DIR}/postcondition_delta.json    connection=RAT_1ST    AND
    ...    Wait Until Keyword Succeeds    5x    30s    Perform Delta Recommissioning
           ...    ${OUTPUT_DIR}/postcondition_delta_5G.json    connection=RAT_2ND    AND
    ...    Enable CBRS Feature On gNB    alias=RAT_2ND    target_gnb=${gnb_id}    target_gnb_mrbts=${gnb_mrbts_id}    AND
    ...    Stop Watchdog Alarm Detection And Check For Failures    AND
    ...    Stop Watchdog Alarm Detection And Check For Failures    alias=RAT_2ND    AND
    ...    Kill All SAS Processes
