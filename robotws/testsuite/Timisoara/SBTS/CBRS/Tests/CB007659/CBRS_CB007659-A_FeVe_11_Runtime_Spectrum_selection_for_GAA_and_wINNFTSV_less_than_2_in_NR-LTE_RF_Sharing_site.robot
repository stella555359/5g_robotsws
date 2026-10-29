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
...    http://krling126.emea.nsn-net.net/r/1054/

*** Keywords ***
CBRS_CB007659-A_FeVe_11_Runtime_Spectrum_selection_for_GAA_and_wINNFTSV_less_than_2_in_NR-LTE_RF_Sharing_site
    [Documentation]    Requirement: OM_GEN_SFS_CBRS.481; 5G_RAN_USR_COM_5595
    ...                Purpose: verify GAA spectrum selection for CBSD at runtime phase when gNB is onAir in a NR-LTE
    ...                RF Sharing site for wINNFTSV less than 2.0.
    ...                Note: CB007659 doesn't support wINNFTSV 2.0
    ...                This automated testcase is designed only for double BTS (LTE-NR) setup with RF sharing
    [Timeout]    30min

    # Variables setup
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

    # Make sure there is no active legacy SAS connection
    Disable CBRS Feature On eNB    alias=RAT_1ST
    Disable CBRS Feature On gNB    alias=RAT_2ND    target_gnb=${gnb_id}
    Kill All SAS Processes
    Check If Cells Are Disabled    enb_id=${enb_id}
    Check If 5G Cells Are Disabled    gnb_id=${gnb_id}    alias=RAT_2ND

    # Start a new SAS instance on eNB VM
    ${sas_pid}    ${sas_log} =    Start SAS Process    config=${CURDIR}/Data/FeVe_11/SAS_Sim.conf

    Log To Console    Delta plans preparation...
    Replace Variables In File    ${CURDIR}/Data/FeVe_11/gnb_precondition_delta.json
    ...                          ${OUTPUT_DIR}/gnb_precondition_delta.json
    ...                          enb_id=${gnb_id}
    Replace Variables In File    ${CURDIR}/Data/FeVe_11/gnb_postcondition_delta.json
    ...                          ${OUTPUT_DIR}/gnb_postcondition_delta.json
    ...                          enb_id=${gnb_id}
    Replace Variables In File    ${CURDIR}/Data/FeVe_11/enb_precondition_delta.json
    ...                          ${OUTPUT_DIR}/enb_precondition_delta.json
    ...                          enb_id=${enb_id}
    Replace Variables In File    ${CURDIR}/Data/FeVe_11/enb_postcondition_delta.json
    ...                          ${OUTPUT_DIR}/enb_postcondition_delta.json
    ...                          enb_id=${enb_id}

    Log To Console    Preconditions on gNB ongoing...    #supportedSpectrumV2 = 3620-3640MHz
    Wait Until Keyword Succeeds    4x    30s    Run Keywords
    ...    Wait Until BTS Is Not Busy    alias=RAT_2ND    AND
    ...    Perform Delta Recommissioning    ${OUTPUT_DIR}/gnb_precondition_delta.json    connection=RAT_2ND
    Enable CBRS Feature On gNB    alias=RAT_2ND    target_gnb=${gnb_id}
    Wait For 5G Cells To Be OnAir    alias=RAT_2ND

    Log To Console    Preconditions on eNB ongoing...    #supportedSpectrumV2 = 3560-3640MHz
    Wait Until Keyword Succeeds    4x    30s    Run Keywords
    ...    Wait Until BTS Is Not Busy    alias=RAT_1ST    AND
    ...    Perform Delta Recommissioning    ${OUTPUT_DIR}/enb_precondition_delta.json    connection=RAT_1ST
    Enable CBRS Feature On eNB    alias=RAT_1ST
    Wait For All Cells To Be OnAir    alias=RAT_1ST

    Start Watchdog Alarm Detection
    Start Watchdog Alarm Detection    alias=RAT_2ND

    Log To Console    Step 1. Terminate one of 20MHz LTE cells
    ${cbsd_id}   Fetch CBSD ID    ${enb_id}
    ${active_grant_list}   List Values of GrantId For All Cells    ${enb_id}
    ${num_of_grants}   Get Length    ${active_grant_list}
    ${termination_candidates}   Create List
    FOR    ${i}    IN RANGE    ${num_of_grants}
        ${chan_low_freq}   Get Substring    ${active_grant_list}[${i}]    start=0    end=10
        ${chan_high_freq}   Get Substring    ${active_grant_list}[${i}]    start=11    end=21
        ${grant_bandwidth}   Evaluate    ${chan_high_freq}-${chan_low_freq}
        IF  '${grant_bandwidth}'=='20000000'  Append To List  ${termination_candidates}  ${active_grant_list}[${i}]
    END
    Should Not Be Empty    ${termination_candidates}    msg=There are no 20MHz cells on eNB
    ${random_grant_to_terminate}   Evaluate    random.choice(${termination_candidates})    modules=random
    ${grant_terminate_start}   Get Time
    Add Fault To Watchdog Ignored List    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                   severity=${expected_alarm}[severity]    reason=${expected_alarm}[reason]
    Terminate Grant And Confirm Cell Drop    cbsd_id=${cbsd_id}    grant_id=${random_grant_to_terminate}
    Wait For Watchdog Alarm Activation    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                   severity=${expected_alarm}[severity]    reason=${expected_alarm}[reason]    timeout=60
    Wait Until Enhanced Measure Finish    listening_timestamp=${grant_terminate_start}
    Wait For Watchdog Alarm Deactivation    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                     severity=${expected_alarm}[severity]    reason=${expected_alarm}[reason]    timeout=90
    Remove Fault From Watchdog Ignored List    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                        severity=${expected_alarm}[severity]    reason=${expected_alarm}[reason]
    Wait For All Cells To Be OnAir    alias=RAT_1ST
    ${grant_terminate_stop}   Get Time
    ${new_active_grant_list}   List Values of GrantId For All Cells    ${enb_id}
    Should Not Be Equal    ${new_active_grant_list}    ${active_grant_list}
    # Check if one of 20MHz cells changed its bandwidth to 10MHz
    ${grants_after_termination}   List Values of GrantId For All Cells    ${enb_id}
    ${grants_with_20mhz_bw}   Create List
    FOR    ${i}    IN RANGE    ${num_of_grants}
        ${chan_low_freq}   Get Substring    ${grants_after_termination}[${i}]    start=0    end=10
        ${chan_high_freq}   Get Substring    ${grants_after_termination}[${i}]    start=11    end=21
        ${grant_bandwidth}   Evaluate    ${chan_high_freq}-${chan_low_freq}
        IF  '${grant_bandwidth}'=='20000000'  Append To List  ${grants_with_20mhz_bw}  ${grants_after_termination}[${i}]
    END
    ${num_of_20mhz_cells}   Get Length    ${grants_with_20mhz_bw}
    Should Be Equal    ${num_of_20mhz_cells}    ${1}    msg=There should be only one 20MHz cell after grant suspension
    Send Command To SAS Manager    alias=default    command=grant_free ${cbsd_id} ${random_grant_to_terminate}

    Log To Console    Step 2. Check if wINNFTSV is below 2.0
    ${is_tech_spec_in_newest_ver}   Run Keyword And Return Status    Check If Inquiry is TS2.0 Compliant
    ...                               enb_id=${enb_id}
    ...                               time_start=${grant_terminate_start}
    ...                               time_stop=${grant_terminate_stop}
    ...                               sas_log_path=${sas_logs_dir}
    ...                               alias=RAT_1ST
    IF  ${is_tech_spec_in_newest_ver}  Fail  Scenario requires TS in version 1.x

    Log To Console    Step 3. Verify channel types for eNB
    ${grantchanneltype_list}   Create List
    FOR    ${i}    IN RANGE    ${1}    ${num_of_enb_cells}+1
        ${channel_type}   Get Channel Type For Cell    enb_id=${enb_id}    cell_number=${i}
        Append To List    ${grantchanneltype_list}    ${channel_type}
    END
    # Prepare a list with expected channel types and compare it with current results
    ${required_grantchanneltype_list}   Create List
    FOR    ${i}    IN RANGE    ${1}    ${num_of_enb_cells}+1
        Append To List    ${required_grantchanneltype_list}    GAA
    END
    Should Be Equal    ${grantchanneltype_list}    ${required_grantchanneltype_list}
    Log To Console    All CBSD cells are GAA

    Log To Console    Step 4. Verify CBRS Frequency Blocks on eNB
    ${enb_freq_block_id}   Get Freq Block Id For A Given Smod Serial Number    smod_serial_num=${enb_smod_sn}
    ${gnb_freq_block_id}   Get Freq Block Id For A Given Smod Serial Number    smod_serial_num=${gnb_smod_sn}
    Verify Cbrs Frequency Block Inside The Info Model    freq_block_id=${enb_freq_block_id}
    ...    alias_for_grant_info=RAT_1ST    alias_for_freq_block=RAT_1ST
    Verify Cbrs Frequency Block Inside The Info Model    freq_block_id=${gnb_freq_block_id}
    ...    alias_for_grant_info=RAT_2ND    alias_for_freq_block=RAT_1ST

    [Teardown]    Run Keywords
    ...    Get SAS Logs To Logs Dir    alias=default    AND
    ...    Stop Watchdog Alarm Detection And Check For Failures    AND
    ...    Stop Watchdog Alarm Detection And Check For Failures    alias=RAT_2ND    AND
    ...    Wait Until BTS Is Not Busy    alias=RAT_1ST    AND
    ...    Wait Until Keyword Succeeds    5x    30s    Perform Delta Recommissioning
           ...        ${OUTPUT_DIR}/enb_postcondition_delta.json    connection=RAT_1ST    AND
    ...    Wait Until BTS Is Not Busy    alias=RAT_2ND    AND
    ...    Wait Until Keyword Succeeds    5x    30s    Perform Delta Recommissioning
           ...        ${OUTPUT_DIR}/gnb_postcondition_delta.json    connection=RAT_2ND    AND
    ...    Kill All SAS Processes
