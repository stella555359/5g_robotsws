*** Settings ***
Documentation
...    = Author =
...    piotr.lukaszewicz@nokia.com
...    = Maintainer =
...    piotr.lukaszewicz@nokia.com
...    = Reviewer =
...    aleksandra.chudzik@nokia.com
...    katarzyna.kadziela@nokia.com
...    lukasz.lechowicz@nokia.com
...    karol.sadowski@nokia.com
...    = Review location =
...    http://krling126.emea.nsn-net.net/r/1048/

*** Keywords ***
CBRS_CB007659-A_FeVe_09_Startup_Spectrum_selection_for_PAL_and_wINNFTSV_less_than_2_in_NR-LTE_RF_Sharing_site
    [Documentation]    Requirement: OM_GEN_SFS_CBRS.480
    ...                Purpose: verify CBSD channels assignment during a startup phase, when CBSD cells are not
    ...                in service in NR-LTE RF Sharing site, while gNB is onAir. Parameter cbrsFreqType is set to PAL,
    ...                wINNFTSV is less than 2.0 and cbrsFreqPriority is configured to different value for each cell.
    ...                LTE cells cannot be assigned to frequency used by gNB.
    ...                This automated testcase is designed only for double BTS (LTE-NR) setup with RF sharing
    [Timeout]    30min

    # Variables setup
    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${enb_mrbts_id}   Set Variable    ${testlines.${testline_id}.mrbts_id}
    ${gnb_id}   Set Variable    ${testlines.${testline_id}.node2.enb_id}
    ${gnb_mrbts_id}   Set Variable    ${testlines.${testline_id}.node2.mrbts_id}
    ${enb_smod_sn}   Get Serial Number Of System Module
    ${gnb_smod_sn}   Get Serial Number Of System Module    alias=RAT_2ND
    ${num_of_enb_cells}   Get Number of Cells    ${enb_id}

    # Make sure there is no active legacy SAS connection
    Kill All SAS Processes
    Check If Cells Are Disabled    enb_id=${enb_id}
    Check If 5G Cells Are Disabled    gnb_id=${gnb_id}    alias=RAT_2ND

    Log To Console    Preconditions on eNB ongoing...
    Replace Variables In File    ${CURDIR}/Data/FeVe_09/precondition_delta.json
    ...                          ${OUTPUT_DIR}/precondition_delta.json
    ...                          enb_id=${enb_id}
    ...                          mrbts_id=${enb_mrbts_id}
    Replace Variables In File    ${CURDIR}/Data/FeVe_09/gnb_precondition_delta.json
    ...                          ${OUTPUT_DIR}/gnb_precondition_delta.json
    ...                          enb_id=${gnb_id}
    ...                          mrbts_id=${gnb_mrbts_id}
    Replace Variables In File    ${CURDIR}/Data/FeVe_09/postcondition_delta.json
    ...                          ${OUTPUT_DIR}/postcondition_delta.json
    ...                          enb_id=${enb_id}
    ...                          mrbts_id=${enb_mrbts_id}
    Replace Variables In File    ${CURDIR}/Data/FeVe_09/gnb_postcondition_delta.json
    ...                          ${OUTPUT_DIR}/gnb_postcondition_delta.json
    ...                          enb_id=${gnb_id}
    ...                          mrbts_id=${gnb_mrbts_id}
    Wait Until Keyword Succeeds    6x    10s    Run Keywords
    ...    Wait Until BTS Is Not Busy    alias=RAT_2ND    AND
    ...    Perform Delta Recommissioning    ${OUTPUT_DIR}/gnb_precondition_delta.json    connection=RAT_2ND
    Wait Until Keyword Succeeds    6x    10s    Run Keywords
    ...    Wait Until BTS Is Not Busy    alias=RAT_1ST    AND
    ...    Perform Delta Recommissioning    ${OUTPUT_DIR}/precondition_delta.json    connection=RAT_1ST

    # Start a new SAS instance on eNB VM
    ${sas_pid}    ${sas_log} =    Start SAS Process    config=${CURDIR}/Data/FeVe_09/SAS_Sim.conf

    # Activate CBRS feature on gNB
    Wait Until BTS Is Not Busy    alias=RAT_2ND
    Enable CBRS Feature On gNB    alias=RAT_2ND    target_gnb=${gnb_id}    target_gnb_mrbts=${gnb_mrbts_id}
    Wait For 5G Cells To Be OnAir    alias=RAT_2ND
    Log To Console    5G CBSD cells are onAir
    Start Watchdog Alarm Detection    alias=RAT_2ND

    # Activate CBRS feature on eNB
    Wait Until BTS Is Not Busy    alias=RAT_1ST
    Enable CBRS Feature On eNB    alias=RAT_1ST
    ${time_start}   Get Time
    Wait For All Cells To Be OnAir    alias=RAT_1ST
    Log To Console    LTE CBSD cells are onAir

#    Start Capturing Historical Alarms
    Start Watchdog Alarm Detection
    Log To Console    Step 1. Check if wINNFTSV is below 2.0
    ${time_stop}   Get Time
    ${is_tech_spec_in_newest_ver}   Run Keyword And Return Status    Check If Inquiry is TS2.0 Compliant
    ...                               enb_id=${enb_id}
    ...                               time_start=${time_start}
    ...                               time_stop=${time_stop}
    ...                               sas_log_path=${sas_logs_dir}
    ...                               alias=RAT_1ST
    IF  ${is_tech_spec_in_newest_ver}  Fail  Scenario requires TS in version 1.x

    Log To Console    Step 2. Verify channel types for eNB
    ${grantchanneltype_list}   Create List
    FOR    ${i}    IN RANGE    ${1}    ${num_of_enb_cells}+1
        ${channel_type}   Get Channel Type For Cell    enb_id=${enb_id}    cell_number=${i}
        Append To List    ${grantchanneltype_list}    ${channel_type}
    END
    # prepare a list with expected channel types and compare it with current results
    ${required_grantchanneltype_list}   Create List
    FOR    ${i}    IN RANGE    ${1}    ${num_of_enb_cells}+1
        Append To List    ${required_grantchanneltype_list}    PAL
    END
    Should Be Equal    ${grantchanneltype_list}    ${required_grantchanneltype_list}

    Log To Console    Step 3. Verify CBRS Frequency Blocks on eNB
    ${enb_freq_block_id}   Get Freq Block Id For A Given Smod Serial Number    smod_serial_num=${enb_smod_sn}
    ${gnb_freq_block_id}   Get Freq Block Id For A Given Smod Serial Number    smod_serial_num=${gnb_smod_sn}
    Verify Cbrs Frequency Block Inside The Info Model    freq_block_id=${enb_freq_block_id}
    ...    alias_for_grant_info=RAT_1ST    alias_for_freq_block=RAT_1ST
    Verify Cbrs Frequency Block Inside The Info Model    freq_block_id=${gnb_freq_block_id}
    ...    alias_for_grant_info=RAT_2ND    alias_for_freq_block=RAT_1ST

    [Teardown]    Run Keywords
	...    Get SAS Logs To Logs Dir    alias=default    AND
    ...    Stop Watchdog Alarm Detection And Check For Failures    alias=RAT_2ND    AND
    ...    Stop Watchdog Alarm Detection And Check For Failures    AND
    ...    Wait Until BTS Is Not Busy    AND
    ...    Wait Until Keyword Succeeds    5x    30s    Perform Delta Recommissioning
           ...    ${OUTPUT_DIR}/postcondition_delta.json    connection=RAT_1ST    AND
    ...    Wait Until BTS Is Not Busy    alias=RAT_2ND    AND
    ...    Wait Until Keyword Succeeds    5x    30s    Perform Delta Recommissioning
           ...    ${OUTPUT_DIR}/gnb_postcondition_delta.json    connection=RAT_2ND    AND
    ...    Kill All SAS Processes
