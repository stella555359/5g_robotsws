*** Settings ***
Documentation
...    = Author =
...    _aleksandra.chudzik@nokia.com_
...    = Maintainer =
...    _aleksandra.chudzik@nokia.com_
...    = Reviewer =
...    lukasz.lechowicz@nokia.com
...    piotr.lukaszewicz@nokia.com
...    justyna.durak@nokia.com
...    katarzyna.olszewska@nokia.com

*** Keywords ***
CBRS_LTE5659-A_FeVe_02_Background_Query_assign_matches_GAAchannel_to_cell_with_PALchannel_wINNFTSV_less_than_2
    [Documentation]    Tested Requirement: OM_GEN_SFS_CBRS.450. Purpose: This test case verify GAA channel (which meets requirements)
    ...                assignation to cell with assigned PAL when cbrsFreqType is set to GAA for wINNFTSV less than 2.0.
    ...                TEST SCENARIO
    ...                1. Prepare ENB, set 3xPAL & 1xGAA cell
    ...                2. Terminate GAA, replace by PAL - result 4xPAL
    ...                3. Free terminated GAA grant
    ...                4. W8 for SpectrumInquiry during querySasServerPeriod
    ...                5. Reconfigure back to 3xPAL & 1xGAA

    [Timeout]    20min

    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${expected_alarms}   Create List    SAS Grant Termination Revocation Failure

    Replace Variables In File
    ...    ${CURDIR}/Data/FeVe_02/precondition_delta.json
    ...    ${OUTPUT_DIR}/precondition_delta.json    enb_id=${enb_id}

    Replace Variables In File
    ...    ${CURDIR}/Data/FeVe_02/postcondition_delta.json
    ...    ${OUTPUT_DIR}/postcondition_delta.json    enb_id=${enb_id}

    ${required_spectrum}   Create List    3550    3555    3560    3565    3570    3575    3580    3585    3590    3595
    Set Supported Spectrum    bts_id=${enb_id}    target_spectrum_list=${required_spectrum}

    Wait Until BTS Is Not Busy
    Wait Until Keyword Succeeds    10x    5s    Perform Delta Recommissioning    ${OUTPUT_DIR}/precondition_delta.json    connection=RAT_1ST

    Kill All SAS Processes
    Check If Cells Are Disabled    enb_id=${enb_id}

    Log    Step 1. Start SAS, pal_reserved_channel = 3550,3560,3570,3580    console=True
    ${sas_pid}    ${sas_logs_dir}   Start SAS Process
    ...    config=${CURDIR}/Data/FeVe_02/SAS_Sim.conf
    ...    alias=default    port=4433

    Wait For All Cells To Be OnAir
    Start Capturing Historical Alarms    alias=termination_alarms

    Log    Step 2. Terminate grant for chosen cell    console=True    #terminate GAA

    ${cbsd_id}   Fetch CBSD ID    ${enb_id}
    ${termination_candidate}   Set Variable    3590000000_3600000000

    ${termination_timestamp}   Get Time

    Send Command To SAS Manager    default    grant_terminate ${cbsd_id} ${termination_candidate}
    Wait For Any Cell To Be Dropped

    Save and Check Historical Alarms    alias=termination_alarms    expected_alarms=${expected_alarms}

    IF  '${IS_TRUNK}'=='True'  Wait Until Enhanced Measure Finish  listening_timestamp=${termination_timestamp}

    Wait For All Cells To Be OnAir    # 4xPAL
    Start Capturing Historical Alarms

    Log    Step 3. Free grant for chosen cell    console=True
    Send Command To SAS Manager    default    grant_free ${cbsd_id} ${termination_candidate}

    ${querySasServerPeriod}   Get Value Of querySasServerPeriod    ${enb_id}    RAT_1ST
    Sleep    ${querySasServerPeriod}    #waiting for periodical spectrumInquiry to check whether spectrum compatible with cbrsFreqType is available
    #spectrumInquiryRequest should be visible in SASSim.log before cell reconfiguration

    Wait For All Cells To Be OnAir

    Log    Step 4. Read channel types from Infomodel    console=True
    Wait For All Cells To Be OnAir
    ${grantChannelType_cell_1}   Get Channel Type For Cell    enb_id=${enb_id}    cell_number=1
    ${grantChannelType_cell_2}   Get Channel Type For Cell    enb_id=${enb_id}    cell_number=2
    ${grantChannelType_cell_3}   Get Channel Type For Cell    enb_id=${enb_id}    cell_number=3
    ${grantChannelType_cell_4}   Get Channel Type For Cell    enb_id=${enb_id}    cell_number=4

    ${grantChennelType_infomodel}   Create List
    ...    ${grantChannelType_cell_1}    ${grantChannelType_cell_2}
    ...    ${grantChannelType_cell_3}    ${grantChannelType_cell_4}

    Sort List    ${grantChennelType_infomodel}
    ${required_grantChennelType}   Create List    GAA    PAL    PAL    PAL
    Should Be Equal    ${grantChennelType_infomodel}    ${required_grantChennelType}

    [Teardown]    Run Keywords
    ...    Get SAS Logs To Logs Dir    alias=default    AND
    ...    Wait Until Keyword Succeeds    5x    30s    Perform Delta Recommissioning
           ...    ${OUTPUT_DIR}/postcondition_delta.json    connection=RAT_1ST    AND
    ...    Restore Supported Spectrum    bts_id=${enb_id}    AND
    ...    Run Keyword And Continue On Failure    Save And Check Historical Alarms    expected_alarms=${expected_alarms}    AND
    ...    Kill All SAS Processes    AND
    ...    Check If Cells Are Disabled    enb_id=${enb_id}
