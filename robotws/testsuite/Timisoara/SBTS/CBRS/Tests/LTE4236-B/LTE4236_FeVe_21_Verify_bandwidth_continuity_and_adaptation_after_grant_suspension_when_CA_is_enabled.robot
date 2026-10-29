*** Settings ***
Documentation
...    = Author =
...    piotr.lukaszewicz@nokia.com
...    = Maintainer =
...    piotr.lukaszewicz@nokia.com
...    = Reviewer =
...    lukasz.lechowicz@nokia.com
...    aleksandra.chudzik@nokia.com
...    karol.sadowski@nokia.com
...    = Summary =
...    Purpose: Verify bandwidth continuity and resources adaptation after grant suspension, when CA is enabled.

*** Keywords ***
LTE4236_FeVe_21_Verify_bandwidth_continuity_and_adaptation_after_grant_suspension_when_CA_is_enabled
    [Documentation]  Requirement: OM_GEN_SFS_CBRS.314; EDA 02149469 ACTION

    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${alias}   Set Variable    RAT_1ST
    &{expected_alarm_1}   Create Dictionary    fault_id=6832    fault_name=SAS Server Communication Failure    severity=Critical
    &{expected_alarm_2}   Create Dictionary    fault_id=6825    fault_name=SAS Grant Suspension Failure    severity=Critical
    ...                                          reason=responseCode : 501 transmitExpireTime expires.
    ${expected_alarms_list}      Create List    ${expected_alarm_1}    ${expected_alarm_2}
    ${expected_alarms_objects}   Create Watchdog Alarm List    ${expected_alarms_list}

    Disable CBRS Feature On eNB
    Kill All SAS Processes
    Check If Cells Are Disabled    ${enb_id}

    Set Bandwidth To 10 MHz For All Cells    enb_id=${enb_id}    alias=${alias}
    Enable Carrier Aggregation    enb_id=${enb_id}    alias=${alias}

    # Check if whole CBRS spectrum is available in supportedSpectrumV2
    ${is_whole_spectrum_available}   Run Keyword And Return Status    Query Infomodel    alias=${alias}
    ...    query=check /MRBTS-1/RAT-1/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-${enb_id}/LNBTS_A-${enb_id}/CBSD_A-* is [supportedSpectrumV2=1073741823]
    IF  '${is_whole_spectrum_available}'=='False'  Restore Supported Spectrum  bts_id=${enb_id}

    Start Watchdog Alarm Detection    expected_alarms=${expected_alarms_objects}

    Log To Console    ${\n}Scenario 1. Suspend grant from a pool at the beginning of a CBRS band
    ${start_bw_main_chan_cand}   Create List    3590000000_3600000000
    ${start_bw_alt_chan_cand}   Create List
    ...    3600000000_3610000000    3610000000_3620000000    3620000000_3630000000    3630000000_3640000000
    ...    3640000000_3650000000    3650000000_3660000000    3660000000_3670000000    3670000000_3680000000
    ...    3680000000_3690000000
    Trigger New Resource Negotiation    enb_id=${enb_id}    sas_cfg_name=Channels_at_the_beginning    alias=${alias}
    ...    main_candidates_list=${start_bw_main_chan_cand}    alt_candidates_list=${start_bw_alt_chan_cand}
    ...    suspend_candidate=3570000000_3580000000

    Log To Console    ${\n}Scenario 2. Suspend random grant from a pool in the middle of a CBRS band
    ${mid_bw_main_chan_cand}   Create List    3590000000_3600000000    3640000000_3650000000
    ${mid_bw_alt_chan_cand}   Create List
    ...    3550000000_3560000000    3560000000_3570000000    3570000000_3580000000    3580000000_3590000000
    ...    3650000000_3660000000    3660000000_3670000000    3670000000_3680000000    3680000000_3690000000
    ...    3690000000_3700000000
    ${initial_grants}   Create List
    ...    3600000000_3610000000    3610000000_3620000000    3620000000_3630000000    3630000000_3640000000
    ${random_grant_for_suspension}   Evaluate    random.choice(${initial_grants})    modules=random
    Trigger New Resource Negotiation    enb_id=${enb_id}    sas_cfg_name=Channels_in_the_middle    alias=${alias}
    ...    main_candidates_list=${mid_bw_main_chan_cand}    alt_candidates_list=${mid_bw_alt_chan_cand}
    ...    suspend_candidate=${random_grant_for_suspension}

    Log To Console    ${\n}Scenario 3. Suspend grant from a pool at the end of a CBRS band
    ${end_bw_main_chan_cand}   Create List    3650000000_3660000000
    ${end_bw_alt_chan_cand}   Create List
    ...    3570000000_3580000000    3580000000_3590000000    3590000000_3600000000    3600000000_3610000000
    ...    3610000000_3620000000    3620000000_3630000000    3630000000_3640000000    3640000000_3650000000
    Trigger New Resource Negotiation    enb_id=${enb_id}    sas_cfg_name=Channels_at_the_end    alias=${alias}
    ...    main_candidates_list=${end_bw_main_chan_cand}    alt_candidates_list=${end_bw_alt_chan_cand}
    ...    suspend_candidate=3660000000_3670000000

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Kill All SAS Processes

Set Bandwidth To 10 MHz For All Cells
    [Documentation]  Description:           Check if the bandwidth of any current cell is set to 10MHz. If not, prepare
    ...                                     a new delta plan with chBw set to 10MHz for all cells and send it to BTS.${\n}
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                piotr.lukaszewicz@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]      ${enb_id}
    ...              ${alias}

    ${earfcn_list_cells_enb1}    ${cell_count}   List earfcn Values For All Cells    enb_id=${enb_id}
    FOR    ${i}    IN RANGE    ${1}    ${cell_count}+1
        ${chBw_10MHz}   Run Keyword And Return Status    Query Infomodel    alias=RAT_1ST
        ...    query=check /MRBTS-1/RAT-1/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-${i}/LNCEL_M-${i} is [ulChBw=10000000]
        IF  '${chBw_10MHz}'=='False'
            Replace Variables In File  file_path=${CURDIR}/Data/FeVe21/FEVE_21_set_chBw_to_10MHz.json
            ...  file_destination=${OUTPUT_DIR}/FEVE_21_set_chBw_to_10MHz.json  ENB_ID=${enb_id}
            Wait Until BTS Is Not Busy
            Wait Until Keyword Succeeds  3x  60s  Perform Delta Recommissioning
            ...  ${OUTPUT_DIR}/FEVE_21_set_chBw_to_10MHz.json  skip_parameter_relation_errors=${TRUE}  connection=${alias}
            BREAK
        END
    END

Trigger New Resource Negotiation
    [Documentation]  Description:           Check if cells are continuous. Then suspend provided grant and check if new
    ...                                     grant has been chosen from main candidates list (closest to current channels)
    ...                                     or from alternative candidates list (lowest noise power and distance between
    ...                                     adjacent cells is lower or equal 110MHz). If a new channel has been chosen
    ...                                     against those rules, KW fails ${\n}
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                piotr.lukaszewicz@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]      ${enb_id}
    ...              ${sas_cfg_name}
    ...              ${main_candidates_list}
    ...              ${alt_candidates_list}
    ...              ${alias}
    ...              ${suspend_candidate}

    Enable CBRS Feature On eNB    alias=${alias}
    ${sas_pid}    ${sas_logs_dir} =    Start SAS Process    config=${CURDIR}/Data/FeVe21/${sas_cfg_name}.conf
    Wait For All Cells To Be OnAir    alias=${alias}
    Check If Assigned Channels Are Continuous

    # Get grants before suspension
    ${active_grant_list}   List Values of GrantId For All Cells    ${enb_id}
    Sort List    ${active_grant_list}
    Log To Console    Grants before suspension: ${active_grant_list}

    # Grant suspension
    ${cbsd_id}   Fetch CBSD ID    ${enb_id}
    ${grant_suspend_time}   Get Time
    Send Command To SAS Manager    alias=default    command=grant_suspend ${cbsd_id} ${suspend_candidate}
    Wait For Any Cell To Be Dropped
    Log To Console    Grant ${suspend_candidate} suspended
    Wait For All Cells To Be OnAir
    ${bts_on_air_time}   Get Time

    # Get power report and grant list
    ${rcvd_power_meas_reports}   Get Spectrum Inquiry Message    time_start=${grant_suspend_time}
    ...    time_stop=${bts_on_air_time}    sas_log_path=${sas_logs_dir}
    ${new_active_grant_list}   List Values of GrantId For All Cells    ${enb_id}
    Sort List    ${new_active_grant_list}

    # Find a new grant
    ${num_of_list_elem}   Get Length    ${new_active_grant_list}
    ${new_grant}   Create List
    FOR    ${i}    IN RANGE    ${num_of_list_elem}
           ${is_grant_not_new}   Run Keyword And Return Status    Should Contain    ${active_grant_list}
           ...    ${new_active_grant_list}[${i}]
           IF  '${is_grant_not_new}'=='False'
               Append To List  ${new_grant}  ${new_active_grant_list}[${i}]
               BREAK
           END
    END
    Should Not Be Empty    ${new_grant}
    Log To Console    New grant: ${new_grant}[0]

    # Check if only one grant has been changed after suspension
    Remove Values From List    ${active_grant_list}    ${suspend_candidate}
    Remove Values From List    ${new_active_grant_list}    ${new_grant}[0]
    Lists Should Be Equal    ${active_grant_list}    ${new_active_grant_list}

    # Check how new grant has been obtained
    FOR    ${i}    IN RANGE    ${1}
           ${is_main_cand_selected}   Check If Grant Is Included In The List    grant_id=${new_grant}
           ...    grant_list=${main_candidates_list}
           IF  '${is_main_cand_selected}'=='True'
               Log To Console  New grant has been taken from main candidates list
               BREAK
           END
           ${best_alt_channels}   Get Best Channels Based On Spectrum Inquiry Power Report
           ...    candidates_list=${alt_candidates_list}    power_report=${rcvd_power_meas_reports}
           ${is_alt_cand_selected}   Check If Grant Is Included In The List    grant_id=${new_grant}
           ...    grant_list=${best_alt_channels}
           IF  '${is_alt_cand_selected}'=='True'
               Log To Console  New grant has been taken from alternative candidates list
               BREAK
           END
           IF  '${is_main_cand_selected}'=='False' and '${is_alt_cand_selected}'=='False'
               Fail  New grant has been chosen against the channel selection algorithm
           END
    END

    Copy File    /home/ute/SASSim/default/SAS_Sim.log    ${TEST_LOGS_DIR_PATH}/SAS_Sim_${sas_cfg_name}.log
    Send Command To SAS Manager    alias=default    command=grant_free ${cbsd_id} ${suspend_candidate}

    Watchdog Check For Failures
    Disable CBRS Feature On eNB
    Kill All SAS Processes
    Check If Cells Are Disabled    ${enb_id}

Check If Assigned Channels Are Continuous
    [Documentation]  Description:           Check if there is no gap between cells. It is recommended to use this KW
    ...                                     after first resource negotiation between CBSD and SAS, for BTS with CA
    ...                                     enabled. All cells must have 10MHz or 20MHz bandwidth. Mixed bandwidth
    ...                                     is not supported.${\n}
    ...              Return:                lowest and highest channel frequency${\n}
    ...              Output:                { ${string}, ${string} }${\n}
    ...              Author:                lukasz.lechowicz@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]      ${channel_bw}=10

    @{grant_info_list}   ute_admin_infomodel.Query Infomodel
    ...    query=get list /MRBTS-1/RAT-1/SYSADAPTER-*/CBRS-*/CBSD-*/GRANT_INFO-*    alias=RAT_1ST
    ${cell_count}   Get Length    ${grant_info_list}
    ${freq_low_list}   Create List
    ${freq_high_list}   Create List
    FOR    ${i}    IN RANGE    ${cell_count}
        Append To List    ${freq_low_list}    ${grant_info_list[${i}]['grantSpectrumFreqLow']}
        Append To List    ${freq_high_list}    ${grant_info_list[${i}]['grantSpectrumFreqHigh']}
    END
    Sort List    ${freq_low_list}
    Sort List    ${freq_high_list}
    ${last_high_index}   Evaluate    ${cell_count}-1
    ${predicted_highest_freq}   Evaluate    ${freq_low_list[0]}+${cell_count}*${channel_bw}
    Should Be Equal    ${predicted_highest_freq}    ${freq_high_list[${last_high_index}]}
    RETURN    ${freq_low_list[0]}    ${freq_high_list[${last_high_index}]}

Get Best Channels Based On Spectrum Inquiry Power Report
    [Documentation]  Description:           Find the best channel(s) in case of noise level, based on a power report
    ...                                     and the list of channel candidates. Power report needs to be provided
    ...                                     in a Spectrum Inquiry format.${\n}
    ...              Return:                list of channels with best power conditions${\n}
    ...              Output:                { @{list} }${\n}
    ...              Author:                piotr.lukaszewicz@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]      ${candidates_list}
    ...              ${power_report}

    # split elements in power report
    ${power_report_str}   Convert To String    ${power_report}
    ${power_report_cut}   Remove String    ${power_report_str}    {'rcvdPowerMeasReports': [
    ${power_report_list}   Split String    ${power_report_cut}    },
    ${num_of_list_elem}   Get Length    ${candidates_list}

    # get low freq from candidates
    ${cand_list_low_freqs}   Create List
    FOR    ${i}    IN RANGE    ${num_of_list_elem}
           ${chan_low_freq}   Get Substring    ${candidates_list}[${i}]    start=0    end=10
           Append To List    ${cand_list_low_freqs}    ${chan_low_freq}
    END

    # assign power level to specific channel
    ${pow_rep_for_cand}   Create Dictionary
    ${pwr_only_list}   Create List
    FOR    ${i}    IN RANGE    ${num_of_list_elem}
           ${pow_rep_item}   Get Power Report Details For A Specific Channel    chan_low_freq=${cand_list_low_freqs}[${i}]
           ...    power_report_list=${power_report_list}
           ${pow_rep_item_str}   Convert To String    ${pow_rep_item}
           ${pwr_lvl_from_item}   Get Regexp Matches    ${pow_rep_item_str}    (\\-)(\\d*)    2
           ${pwr_lvl_str}   Convert To String    ${pwr_lvl_from_item}[0]
           Set To Dictionary    ${pow_rep_for_cand}    ${cand_list_low_freqs}[${i}]    ${pwr_lvl_str}
           ${pwr_lvl_int}   Convert To Integer    ${pwr_lvl_str}    #needed to sort by integers
           Append To List    ${pwr_only_list}    ${pwr_lvl_int}
    END

    # get the best power level
    Sort List    ${pwr_only_list}
    Log    ${pwr_only_list}
    ${lowest_noise_lvl}   Set Variable    ${pwr_only_list}[-1]
    ${lowest_noise_lvl_str}   Convert To String    ${lowest_noise_lvl}

    # check if more than 1 channel has the best pwr lvl
    ${best_channels_low_freq}   Create List
    FOR    ${key}    IN    @{pow_rep_for_cand.keys()}
           ${is_chan_containing_best_pwr}   Run Keyword And Return Status    Should Be Equal
           ...    ${lowest_noise_lvl_str}    ${pow_rep_for_cand["${key}"]}
           IF  '${is_chan_containing_best_pwr}'=='True'  Append To List  ${best_channels_low_freq}  ${key}
    END

    # convert low freq to grant_id format
    ${num_of_list_elem}   Get Length    ${best_channels_low_freq}
    ${best_channels}   Create List
    FOR    ${i}    IN RANGE    ${num_of_list_elem}
           ${high_freq}   Evaluate    ${best_channels_low_freq}[${i}]+10000000
           ${grant_id}   Catenate	SEPARATOR=_	   ${best_channels_low_freq}[${i}]    ${high_freq}
           Append To List    ${best_channels}    ${grant_id}
    END
    Should Not Be Empty    ${best_channels}
    Log To Console    Best channel(s): ${best_channels}
    RETURN    ${best_channels}

Get Power Report Details For A Specific Channel
    [Documentation]  Description:           Filter power report (in a list format) and return the details for matching
    ...                                     channel (pointed by a low frequency).${\n}
    ...              Return:                power report for specific channel${\n}
    ...              Output:                { @{list} }${\n}
    ...              Author:                piotr.lukaszewicz@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]      ${chan_low_freq}
    ...              ${power_report_list}

    ${power_rep_for_spec_chan}   Create List
    ${num_of_list_elem}   Get Length    ${power_report_list}
    FOR    ${i}    IN RANGE    ${num_of_list_elem}
           ${is_freq_matching_with_power_rep}   Run Keyword And Return Status    Should Contain
           ...    ${power_report_list}[${i}]    ${chan_low_freq}
           IF  '${is_freq_matching_with_power_rep}'=='True'
               Append To List  ${power_rep_for_spec_chan}  ${power_report_list}[${i}]
               BREAK
           END
    END
    RETURN    ${power_rep_for_spec_chan}

Check If Grant Is Included In The List
    [Documentation]  Description:           Check if a specific grant ID is included in the list of grants.${\n}
    ...              Return:                boolean: true or false${\n}
    ...              Output:                { ${string} }${\n}
    ...              Author:                piotr.lukaszewicz@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]      ${grant_id}
    ...              ${grant_list}

    ${num_of_list_elem}   Get Length    ${grant_list}
    FOR    ${i}    IN RANGE    ${num_of_list_elem}
        ${is_grant_incl_in_the_list}   Run Keyword And Return Status    Should Contain    ${grant_id}    ${grant_list}[${i}]
        IF  '${is_grant_incl_in_the_list}'=='True'  BREAK
    END
    RETURN    ${is_grant_incl_in_the_list}
