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
CBRS_LTE5659-A_FeVe_07_Background_Query_assign_PALchannel_to_other_in_service_cell
    [Documentation]    Tested Requirement: OM_GEN_SFS_CBRS.450, OM_GEN_SFS_CBRS.452
    ...                Purpose: This test case verifies channel (which meets requirements) assignation to other
    ...                PAL cell in service which is not assigned with desiredChBw. cbrsFreqType is set to PAL,
    ...                SAS Query Timer is expired and cbrsFreqPriority is configured to different values.

    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${alias}   Set Variable    RAT_1ST
    &{expected_alarm}   Create Dictionary    fault_id=6823    fault_name=SAS Grant Termination Revocation Failure    severity=Critical
    ${expected_alarms_objects}   Create Watchdog Alarm List    ${expected_alarm}

    Log To Console    Preconditions
    Replace Variables In File    ${CURDIR}/Data/FeVe_07/precondition_delta.json
    ...                          ${OUTPUT_DIR}/precondition_delta.json
    ...                          enb_id=${enb_id}
    Replace Variables In File    ${CURDIR}/Data/FeVe_07/postcondition_delta.json
    ...                          ${OUTPUT_DIR}/postcondition_delta.json
    ...                          enb_id=${enb_id}

    ${required_spectrum}   Create List    3550    3555    3565    3570    3580    3585    3595    3600    3620    3625    3630    3635
    Set Supported Spectrum    bts_id=${enb_id}    target_spectrum_list=${required_spectrum}

    Wait Until BTS Is Not Busy
    Wait Until Keyword Succeeds    5x    30s    Perform Delta Recommissioning    ${OUTPUT_DIR}/precondition_delta.json    connection=${alias}

    Log To Console    Kill SAS if exists
    Kill All SAS Processes
    Disable CBRS Feature On eNB
    Check If Cells Are Disabled    enb_id=${enb_id}

    Log To Console    Step 1. Start SAS, pal_reserved_channel = 3550,3555,3565,3570,3580,3585,3595,3600,3620,3625,3630,3635
    ${sas_pid}    ${sas_logs_dir}   Start SAS Process    config=${CURDIR}/Data/FeVe_07/SAS_Sim.conf

    Enable CBRS Feature On eNB
    Wait For All Cells To Be OnAir
    Start Watchdog Alarm Detection    expected_alarms=${expected_alarms_objects}

    Query Infomodel    alias=${alias}    query=check /MRBTS-1/RAT-1/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-4/LNCEL_M-4 is [ulChBw=20000000]
    ${cbsd_id}   Fetch CBSD ID    ${enb_id}
    ${termination_candidate}   Set Variable    3620000000_3640000000

    Log To Console    Step 2. Terminate grant for chosen cell
    Send Command To SAS Manager    default    grant_terminate ${cbsd_id} ${termination_candidate}
    Wait For Any Cell To Be Dropped
    Wait For All Cells To Be OnAir

    Log To Console    Step 3. Free grant for chosen cell
    Send Command To SAS Manager    default    grant_free ${cbsd_id} ${termination_candidate}

    ${querySasServerPeriod}   Get Value Of querySasServerPeriod    ${enb_id}    ${alias}
    Sleep    ${querySasServerPeriod}    #waiting for periodical spectrumInquiry to check whether spectrum compatible with desiredChBw is available
    #spectrumInquiryRequest should be visible in SASSim.log before cell reconfiguration

    Wait Until Keyword Succeeds    3x    20s    Query Infomodel    alias=${alias}
    ...    query=check /MRBTS-1/RAT-1/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-4/LNCEL_M-4 is [ulChBw=20000000]
    Wait For All Cells To Be OnAir

    Log To Console    Step 4. Read channel types from Infomodel
    ${grantChannelType_cell_1}   Get Channel Type For Cell    enb_id=${enb_id}    cell_number=1
    ${grantChannelType_cell_2}   Get Channel Type For Cell    enb_id=${enb_id}    cell_number=2
    ${grantChannelType_cell_3}   Get Channel Type For Cell    enb_id=${enb_id}    cell_number=3
    ${grantChannelType_cell_4}   Get Channel Type For Cell    enb_id=${enb_id}    cell_number=4

    Should Be Equal    ${grantChannelType_cell_1}    PAL
    Should Be Equal    ${grantChannelType_cell_2}    PAL
    Should Be Equal    ${grantChannelType_cell_3}    PAL
    Should Be Equal    ${grantChannelType_cell_4}    PAL

    ${grant_4}   Fetch Grant ID of selected cell    enb_id=${enb_id}    cell_number=4
    Should Be Equal    ${grant_4}    ${termination_candidate}

    [Teardown]    Run Keywords
    ...    Get SAS Logs To Logs Dir    alias=default    AND
    ...    Wait Until Keyword Succeeds    5x    30s    Perform Delta Recommissioning
    ...        delta_file=${OUTPUT_DIR}/postcondition_delta.json    connection=${alias}    AND
    ...    Wait For All Cells To Be OnAir    AND
    ...    Restore Supported Spectrum    bts_id=${enb_id}    AND
    ...    Stop Watchdog Alarm Detection And Check For Failures    AND
    ...    Kill All SAS Processes    AND
    ...    Check If Cells Are Disabled    enb_id=${enb_id}
