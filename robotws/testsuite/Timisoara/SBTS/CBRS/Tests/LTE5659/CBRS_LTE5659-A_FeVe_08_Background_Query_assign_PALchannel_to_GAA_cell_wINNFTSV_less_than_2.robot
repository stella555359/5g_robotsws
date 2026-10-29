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
CBRS_LTE5659-A_FeVe_08_Background_Query_assign_PALchannel_to_GAA_cell_wINNFTSV_less_than_2
    [Documentation]     Tested Requirement: OM_GEN_SFS_CBRS.450, OM_GEN_SFS_CBRS.452
    ...                 Purpose: This test case verify PAL channel (which meets requirements) assignation to cell assigned
    ...                 with GAA channel which is not assigned with desiredChBw. cbrsFreqType is set to PAL for wINNFTSV less than 2.0
    ...                 and SAS Query Timer is expired.

    [Timeout]    25min
    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${expected_alarms}   Create List    SAS Grant Termination Revocation Failure

    Log    Preconditions    console=True
    Replace Variables In File    ${CURDIR}/Data/FeVe_08/precondition_delta.json
    ...                          ${OUTPUT_DIR}/precondition_delta.json
    ...                          enb_id=${enb_id}
    Replace Variables In File    ${CURDIR}/Data/FeVe_08/postcondition_delta.json
    ...                          ${OUTPUT_DIR}/postcondition_delta.json
    ...                          enb_id=${enb_id}

    ${required_spectrum}   Create List    3550    3555    3560    3565    3600    3605    3620    3625    3640    3645    3660    3665
    Set Supported Spectrum    bts_id=${enb_id}    target_spectrum_list=${required_spectrum}

    Wait Until BTS Is Not Busy
    Wait Until Keyword Succeeds    5x    30s    Perform Delta Recommissioning    ${OUTPUT_DIR}/precondition_delta.json    connection=RAT_1ST

    Log    Kill SAS if exists    console=True
    Kill All SAS Processes
    Check If Cells Are Disabled    enb_id=${enb_id}

    Log    Step 1. Start SAS, pal_reserved_channel = 3550,3560    console=True
    ${sas_pid}    ${sas_logs_dir}   Start SAS Process
    ...                               alias=default
    ...                               port=4433
    ...                               config=${CURDIR}/Data/FeVe_08/SAS_Sim.conf

    Wait For All Cells To Be OnAir
    Start Capturing Historical Alarms

    Query Infomodel    alias=RAT_1ST    query=check /MRBTS-1/RAT-1/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-4/LNCEL_M-4 is [ulChBw=20000000]
    ${cbsd_id}   Fetch CBSD ID    ${enb_id}
    ${termination_candidate}   Set Variable    3550000000_3570000000

    Log    Step 2. Terminate grant for chosen cell    console=True
    Send Command To SAS Manager    default    grant_terminate ${cbsd_id} ${termination_candidate}
    Wait For Any Cell To Be Dropped
    Wait For All Cells To Be OnAir

    Log    Step 3. Free grant for chosen cell    console=True
    Send Command To SAS Manager    default    grant_free ${cbsd_id} ${termination_candidate}

    ${querySasServerPeriod}   Get Value Of querySasServerPeriod    ${enb_id}    RAT_1ST
    Sleep    ${querySasServerPeriod}    #waiting for periodical spectrumInquiry to check whether spectrum compatible with desiredChBw is available
    #spectrumInquiryRequest should be visible in SASSim.log before cell reconfiguration

    Wait Until Keyword Succeeds    3x    10s    Query Infomodel    alias=RAT_1ST
    ...    query=check /MRBTS-1/RAT-1/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-4/LNCEL_M-4 is [ulChBw=20000000]
    Wait For All Cells To Be OnAir

    Log    Step 4. Read channel types from Infomodel    console=True
    ${grantChannelType_cell_1}   Get Channel Type For Cell    enb_id=${enb_id}    cell_number=1
    ${grantChannelType_cell_2}   Get Channel Type For Cell    enb_id=${enb_id}    cell_number=2
    ${grantChannelType_cell_3}   Get Channel Type For Cell    enb_id=${enb_id}    cell_number=3
    ${grantChannelType_cell_4}   Get Channel Type For Cell    enb_id=${enb_id}    cell_number=4

    Should Be Equal    ${grantChannelType_cell_1}    GAA
    Should Be Equal    ${grantChannelType_cell_2}    GAA
    Should Be Equal    ${grantChannelType_cell_3}    GAA
    Should Be Equal    ${grantChannelType_cell_4}    PAL

    ${grant_4}   Fetch Grant ID of selected cell    enb_id=${enb_id}    cell_number=4
    Should Be Equal    ${grant_4}    ${termination_candidate}

    [Teardown]    Run Keywords
    ...    Get SAS Logs To Logs Dir    alias=default    AND
    ...    Wait Until Keyword Succeeds    5x    30s    Perform Delta Recommissioning
           ...    ${OUTPUT_DIR}/postcondition_delta.json    connection=RAT_1ST    AND
    ...    Restore Supported Spectrum    bts_id=${enb_id}    AND
    ...    Run Keyword And Continue On Failure    Save And Check Historical Alarms    expected_alarms=${expected_alarms}    AND
    ...    Kill All SAS Processes    AND
    ...    Check If Cells Are Disabled    enb_id=${enb_id}
