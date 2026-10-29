*** Settings ***
Documentation
...            Integration of eCPRI FDD with APoABIO (O-RAN compliant) - keywords
...            authors:       Wojciech Gicala,    wojciech.gicala@nokia.com
...                           Bartosz Bednarczyk, bartosz.bednarczyk@nokia.com
...            maintainers:   Wojciech Gicala,    wojciech.gicala@nokia.com
...                           Bartosz Bednarczyk, bartosz.bednarczyk@nokia.com

Library         5GC002271-lib.py
Library         taf.wts.config
Library         ute_wtssim
Library         ta5g_enb
Library         taf.sw.scout                               WITH NAME    scout
Library         taf.sw.reporting_portal                    WITH NAME    reporting_portal

Resource        ../../../../resources/SWENG/robot/Setup.robot

Variables       ue-cap-variables.py
Resource        ../../resources_KRK/krk3_common/main_cls.robot

*** Keywords ***
Add 1 NSA UEs with skipUplinkTxDynamic and DRX capabilities
    Load Cfg    ${default_wts_cfg}
    Add Ue      ue_id=15
    ...         ue_type=NSA
    ...         change_sec_key=${False}
    ...         sec_key=0102030405060708090A0B0C0D0EFF00
    ...         ue_nr_capabilities=${skip_uplink_tx_dynamic_fdd_nsa_drx_oran}
    ...         uec=1
    Save Cfg    /opt/wts/latest/basic_setup.cfg

Add UEs from UE-${first_ue} to UE-${last_ue} with skipUplinkTxDynamic and DRX capabilities for NSA TDD
    Load Cfg     ${DEFAULT_WTS_CFG}
    Add Ue      ue_id=${first_ue}-${last_ue}
    ...         ue_type=NSA
    ...         change_sec_key=${False}
    ...         sec_key=0102030405060708090A0B0C0D0EFF00
    ...         ue_nr_capabilities=${skip_uplink_tx_dynamic_tdd_nsa_drx}
    ...         uec=1
    Save Cfg    /opt/wts/latest/basic_setup.cfg

Prepare WTS config files for Multiple UEs SA
    [Documentation]      Add Multiple SA UEs to WTS config files
    Load Cfg     ${DEFAULT_WTS_CFG}
    Add Ue      ue_id=3-10
    ...         ue_type=SA
    ...         change_sec_key=${False}
    ...         sec_key=0102030405060708090A0B0C0D0EFF00
    ...         uec=1
    Save Cfg    /opt/wts/latest/basic_setup.cfg

Set ${timestamp} for proper counters counting
    ${timestamp}    set_timestamp
    [Return]     ${timestamp}

Set ${localtime} for pool verification
    ${localtime}    local_time_counter
    [Return]     ${localtime}

Count time between timestamps
    [Arguments]     ${time0}    ${time1}    ${time2}
    ${counter_p10}     counter_count    ${time0}    ${time1}
    ${counter_p20}     counter_count    ${time1}    ${time2}
    Set test variable     ${counter_p10}
    Set test variable     ${counter_p20}

Verify SR_SLOT_POOL_AS_MAIN for pool 5 10 20 and 40 is correct
    [Arguments]        ${pm_counter_path}     ${localtime1}     ${localtime2}
    ${value_sr5}     Get PM Counter Values from XML File     counter_id=M55165C00007     mo_id=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...                filepath=${pm_counter_path}
    ${value_sr10}     Get PM Counter Values from XML File     counter_id=M55165C00008     mo_id=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...                filepath=${pm_counter_path}
    ${value_sr20}     Get PM Counter Values from XML File     counter_id=M55165C00009     mo_id=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...                filepath=${pm_counter_path}
    ${value_sr40}     Get PM Counter Values from XML File     counter_id=M55165C00010     mo_id=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...                filepath=${pm_counter_path}
    check_pool10_pool20_counters    counter_p10=${counter_p10}    counter_p20=${counter_p20}    value_sr10=${value_sr10}    value_sr20=${value_sr20}
    check_pool_max_counter            localtime=${localtime2}       value_sr=${value_sr40}
    check_pool_min_counter            localtime=${localtime1}       value_sr=${value_sr5}

Verify that ${number_ues} UEs are being allocated with the SR period set to srPeriodicityMin equal to ${periodicity}
    verify_that_slot_pool_in_rrc_is_present_a_number_of_times      expected_pool=${periodicity}
    ...                                                            number_of_ues=${number_ues}
    ...                                                            log_path=${TEST_log_dir}/Egate/egate_console.log

Clean basic_setup.cfg file
    Copy File    ${default_wts_cfg}    /opt/wts/latest/basic_setup.cfg

Add NSA UEs with IDs ${first}-${last} and basic capabilities for ORAN configuraton
    Load Cfg     ${default_wts_cfg}
    Add Ue      ue_id=${first}-${last}
    ...         ue_type=NSA
    ...         change_sec_key=${False}
    ...         sec_key=0102030405060708090A0B0C0D0EFF00
    ...         ue_nr_capabilities=${default_nsa_ue_capability_for_oran_configuration}
    ...         uec=1
    Save Cfg    /opt/wts/latest/basic_setup.cfg

Verify that the sum of SR_SLOT20_POOL_AS_MAIN and SR_SLOT40_POOL_AS_MAIN is equal to full period interval
    [Arguments]     ${value}      ${pm_counter_path}
    ${value_sr20}     Get PM Counter Values from XML File     counter_id=M55165C00009     mo_id=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...                filepath=${pm_counter_path}
    ${value_sr40}     Get PM Counter Values from XML File     counter_id=M55165C00010     mo_id=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...                filepath=${pm_counter_path}
    check_sum          value_1=${value_sr40}     value_2=${value_sr20}     base_value=${value}

Attach UE${first} to UE${last} to LTE
    FOR    ${ue}    IN RANGE    ${first}    ${last}+1
        NSA UE Attach   ue_id=${ue}
    END

Establish dual connectivity for UE${ue_id} and expect reconfiguration with periodicity ${periodicity}
    ${success_reconf}    Set Variable    Successfully reconfigured dual connectivity
    ${should_contain}    Create List     (?ms)UE${ue_id}\\[NR-RRC\\]: <- gNB.*periodicityAndOffset ${periodicity}.*UE${ue_id}: ${success_reconf}
    NSA LTE-NR Dual Connectivity    ue_id=${ue_id}    should_contain=${should_contain}

Establish dual connectivity for UE${first} to UE${last} with ${interval}s interval and expect reconfigurations with periodicity ${periodicity}
    FOR    ${ue}    IN RANGE    ${first}    ${last}+1
        sleep    ${interval}    reason=user defined time interval between dual connectivities
        Establish dual connectivity for UE${ue} and expect reconfiguration with periodicity ${periodicity}
    END

Wait for ${wait_time}s and check if UE${first} to UE${last} have reconfigured to pool ${periodicity}
    ${output_file}    Set Variable    ${TEST_log_dir}/reconf_${periodicity}.txt

    Execute egate command    cmd=sim_log_set flush
    Execute Egate Command    cmd=sim_log_set file\=${output_file}
    Sleep    ${wait_time}s    reason=user defined log collecting time
    Execute egate command    cmd=sim_log_set flush
    Sleep    2s    reason=Wait for egate to dump all the buffer

    Verify that UEs have reconfigured to correct SR pool    first_ue_id=${first}    last_ue_id=${last}
    ...                                                     periodicity=${periodicity}    egate_log_file=${output_file}

Verify that UEs have reconfigured to correct SR pool
    [Arguments]    ${first_ue_id}   ${last_ue_id}    ${periodicity}    ${egate_log_file}

    ${start_reconf}    Set Variable    Sending RRC Connection Reconfiguration
    ${end_reconf}    Set Variable    Successfully reconfigured dual connectivity
    ${input}     OperatingSystem.Get file    ${egate_log_file}

    ${reconfigurations}    Get Lines Matching Regexp    ${input}
    ...    periodicityAndOffset sl[0-9]+|UE[0-9]+: ${start_reconf}|UE[0-9]+: ${end_reconf}    partial_match=true

    ${shortened_log}    Set Variable    ${egate_log_file}_shortened.txt
    Create File    ${shortened_log}    ${reconfigurations}

    FOR    ${ue}    IN RANGE    ${first_ue_id}    ${last_ue_id}+1
        Should Match Regexp in Files   (?s)UE${ue}: ${start_reconf}.*periodicityAndOffset ${periodicity}.*UE${ue}: ${end_reconf}
        ...    ${shortened_log}    options=-z
    END

Start UL Burst Traffic
    [Arguments]    ${ue_id}    ${burst}    ${size}    ${period}
    Execute Egate Command Ext    trf_data_start    ue=${ue_id}    id=2    dir=ul    period_ms=${period}    size=${size}    burst=${burst}
    ...                          pass_regexp=UDP UL TRF

Start DTX testmode
    [Arguments]    ${ue_id}    ${profile_id}    ${time_vs_interval}
    Execute Egate Command Ext    forced_dtx_testmode_nr     profile_id=${profile_id}     force_dtx_pusch=${time_vs_interval}
    Execute Egate Command Ext    ue_testmode_set_nr     id=${ue_id}    testmode=forced_dtx     profile_id=${profile_id}    action=activate

Convert TTI trace from csv to dict
    [Arguments]    ${ttitrace_csv}
    ${tti_trace_dict}    read_and_parse_tti_data    ${ttitrace_csv}
    [Return]    ${tti_trace_dict}

Split original ttitrace csv to separate files by RNTI
    [Arguments]    ${ttitrace_csv}    ${ttitrace_dict}
    @{separate_tti_file_list}    move_each_rnti_to_separate_tti_trace_csv    parsed_data=${tti_trace_dict}
    ...                                                                      ttitrace_csv=${ttitrace_csv}
    [Return]    @{separate_tti_file_list}

Verify proactive grants assignment for UEs
    [Arguments]    ${ms}    ${ttitrace_csv}    ${ttitrace_dict}
    verify_proactive_grants_assignment    val=${ms}
    ...                                   parsed_data=${ttitrace_dict}
    ...                                   tti_csv=${ttitrace_csv}

Verify that retransmission for proactive grant is not started
    [Arguments]    ${separate_rnti_ttitrace_csv_list}
    FOR    ${separate_csv}    IN    @{separate_rnti_ttitrace_csv_list}
        ${tti_trace_dict}    Convert TTI trace from csv to dict    ttitrace_csv=${separate_csv}
        verify_that_retransmission_for_skippable_grant_is_not_started    tti_trace_dict=${tti_trace_dict}
    END

Verify that there is no skippableDynamic or nonSkippable grant and CSI report in the same slot
    [Arguments]    ${separate_rnti_ttitrace_csv_list}
    FOR    ${separate_csv}    IN    @{separate_rnti_ttitrace_csv_list}
        ${tti_trace_dict}    Convert TTI trace from csv to dict    ttitrace_csv=${separate_csv}
        check_if_there_is_no_skippabledynamic_or_nonskippable_grant_and_csi_report_in_the_same_slot    ttitrace_dict=${tti_trace_dict}
    END

Execute Remote Command on AP
    [Arguments]    ${command}
    Run Process    sshpass  -p oZPS0POrRieRtu  ssh  toor4nsn@192.168.200.1  bsh 1:1  ${command}
