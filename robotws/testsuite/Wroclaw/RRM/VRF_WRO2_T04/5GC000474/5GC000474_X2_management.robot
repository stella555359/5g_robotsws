*** Settings ***
Documentation
...   author: Pawel Zabawczuk
...   contact: pawel.k.zabawczuk@nokia.com

Resource   testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC000474/resources/keywords_474.robot

*** Variables ***
${lock_unlock_execute}         YES
${partial_reset_execute}       YES
${enb_not_all_execute}         NO
${no_traffic_execute}          NO
${enb_confusion_execute}       NO
${endc_upd_fail_execute}       NO
${err_to_lte_execute}          NO
${enb_not_supp_execute}        NO
${x2_max_num_execute}          NO
${no_setup_req_execute}        NO
${parallel_setup_req_execute}  NO
${iteration}                   1


*** Keywords ***
5GC000474_CNI41523_x2LinkLock-X2_link_reestablishment
    [Documentation]   This testcase verify x2 link behaviour after executed selected scenarios, check pm counters raised by feature
    ...               and activating/clearing alarms
    Run Keyword And Ignore Error   Setup LTEemu environment
    Get BTS Configuration and Setup before Test

    Start Watching Alarms

    wro4_pm.sync_to_next_reporting_interval   offset=1
    ${pm_start_time}   Get Time  epoch

    Start Tracing On SMOD   smod slave=False  filter master=host ${x2_gnb_ip} or host ${x2_enb_ip}
    Attach UE And Start Data Transfer In Both Directions

    #${iteration}   Evaluate   random.randint(1,1)  random
    ${test_scenario}   prepare_scenarios_to_execute   X2_LINK_LOCK_UNLOCK=${lock_unlock_execute}
    ...                                               X2_LINK_PARTIAL_RESET=${partial_reset_execute}
    ...                                               X2_LINK_ENB_NOT_ALLOWED_NO_CELL=${enb_not_all_execute}
    ...                                               X2_LINK_SHUTDOWN_NO_TRAFFIC=${no_traffic_execute}
    ...                                               X2_LINK_ENB_CONFUSION=${enb_confusion_execute}
    ...                                               X2_LINK_ENDC_CONFIGURATION_UPDATE_FAILURE=${endc_upd_fail_execute}
    ...                                               X2_LINK_ERROR_INDICATION_SENT_TO_LTE=${err_to_lte_execute}
    ...                                               X2_LINK_ENB_NOT_SUPPORTED=${enb_not_supp_execute}
    ...                                               X2_LINK_MAX_NUMBER_REACHED=${x2_max_num_execute}
    ...                                               X2_LINK_NO_X2_SETUP_REQ_AFTER_SCTP_CONNECTED=${no_setup_req_execute}
    ...                                               X2_LINK_MAX_PARALLEL_HANDLING_NUMBER_REACHED=${parallel_setup_req_execute}
    ...                                               iteration=${iteration}

    FOR  ${scenario}  IN  @{test_scenario}
        ${scenario_no}   Evaluate   ${scenario_no} + 1
        Show Text on Console   Scenario ${scenario_no}: '${scenario}' is started     colour=${REDBG}  show_timestamp=no

        Run Keyword   ${scenario}

        Check Average Tputs
    END

    wro4_pm.sync_to_next_reporting_interval   offset=1
    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD

    wro4_pm.sync_to_next_reporting_interval
    ${pm_stop_time}   Get Time   epoch
    ${counter_values}   Collect Counters from Given Time    ${pm_start_time}  ${pm_stop_time}  X2_PM_COUNTERS
    x2_474.increase_counters_based_on_msgs_in_pcap_file   serving_cell=NRCELL-700   pcap_file=${logs_path}
    Verification PM Counters   ${counter_values}  X2_PM_COUNTERS

    Check Detected Alarms

    [Teardown]   Run Keywords
    ...         watchdog.Stop Watching Alarms
    ...   AND   Stop Data Transfer   DT_DL
    ...   AND   Stop Data Transfer   DT_UL
    ...   AND   enable_band_config   UE_1   NR_ONLY
    ...   AND   Detach Ue   UE_1
    ...   AND   Clear NAA Storage   UE_1
    ...   AND   Stop Tracing On SMOD

