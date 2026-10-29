*** Settings ***
Documentation
...   author: Pawel Zabawczuk
...   contact: pawel.k.zabawczuk@nokia.com


Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/tput_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB011041/resources/counters.robot
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB005935/resources/specific_keywords_5935.py    WITH NAME    overheat
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB005935/resources/specific_keywords_5935.py    WITH NAME    dlca
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB006449/resources/specific_keywords_6449.py    WITH NAME    ulca
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/l1l2_collector.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/l1l2_verifiers.py


*** Variables ***
${reportAmountCA}    1    # 1 if actBufferBasedSCellAddition=disabled
${oh_msg_no}         ${0}


*** Keywords ***
CB005935_UL_CA_2CC
    [Documentation]   This test case checks UL 2CC (F+F), DL 4CC (2F+2T), voNR and verify counters related to pcell and scell
    # PRECONDITIONS
    dlca.prepare_startup_values
    Set Test Variable   ${pcell}     100
    Set Test Variable   ${scell}     700
    Set Test Variable   ${scell_2}   400
    Set Test Variable   ${scell_3}   410
    Set Test Variable   ${scells_num}  3
    set_preferred_cell   cell_id=${pcell}

    Set Test Variable   ${ue}   SAMSUNG_5
    Require Ue   ${ue}  capabilities=${ue}

    wro4_pm.sync_to_next_reporting_interval   offset=1
    ${pm_start_time}   Get Time  epoch

    Show Text on Console   Attach UE to PCell and SCells, run TCP Downlink and Uplink traffic

    logs.Start Tracing On SMOD   smod slave=False
    Attach Ue    ${ue}
    ${attach_time}   Get Time  epoch
    ${pci}   Verify 5G SA Attach   ${ue}
    Should Be Equal As Strings   ${pcell}  ${pci}   ${ue} not attached to primary cell: ${pcell}

    ${start_tput}   Get Time  epoch
    Start Data Transfer In Given Direction   ${ue}  direction=DLUL  duration=${ul_tput_duration}s
    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   stop_tracing=NO
    scells_added   pcap_file=${logs_path}  num_of_scells=${scells_num}  scells_id=${scell},${scell_2},${scell_3}
    Log To Console   \n Three scells added, tput in both directions onging...

    ulca.increase_counters
    ...    PCELL_UE_CAP_2_CC_UL_MAX_SA
    ...    MAX_UE_PCELL_1_CONF_SCEL_UL_SA
    ...    RRC_RECONF_ADD1ULSCELL_ATT_SA
    ...    RRC_RECONF_ADD1ULSCELL_SUCC_SA
    ...    GNB_DU_UL_SCELL_1_ADMI_REQ_SA
    ...    GNB_DU_UL_SCELL_1_ADMI_SUCC_SA
    ...    GNB_UL_SCELL_1_ADMI_REQ_SA
    ...    GNB_UL_SCELL_1_ADMI_SUCC_SA
    ...    GNB_UL_SCELL_1_CONFIG_REQ_SA
    ...    GNB_UL_SCELL_1_CONFIG_SUCC_SA
    ...    MAX_PSCELL_UE_1_ACT_SCELL_UL
    ...    GNB_DL_SCELL_3_CONFIG_REQ_SA
    ...    GNB_DL_SCELL_3_CONFIG_SUCC_SA
    ...    GNB_DU_DL_SCELL_3_ADMI_REQ_SA
    ...    GNB_DU_DL_SCELL_3_ADMI_SUCC_SA
    ...    MAX_UE_PCELL_3_CONF_SCEL_DL_SA
    ...    RRC_RECONF_ADD3DLSCELL_ATT_SA
    ...    RRC_RECONF_ADD3DLSCELL_SUCC_SA
    ...    cell=${pcell}

    ulca.increase_counters
    ...    NRRCC_MEAS_A1_REC
    ...    multiplier=${reportAmountCA}
    ...    cell=${pcell}

    ulca.increase_counters
    ...    A1_SCELL_ADDED_SA
    ...    multiplier=${scells_num}
    ...    cell=${pcell}

    ulca.increase_counters
    ...    GNB_DU_SCELL_ADMI_REQ_SA
    ...    GNB_DU_SCELL_ADMI_SUCC_SA
    ...    cell=${scell}

    ulca.increase_counters
    ...    GNB_DU_SCELL_ADMI_REQ_SA
    ...    GNB_DU_SCELL_ADMI_SUCC_SA
    ...    cell=${scell_2}

    ulca.increase_counters
    ...    GNB_DU_SCELL_ADMI_REQ_SA
    ...    GNB_DU_SCELL_ADMI_SUCC_SA
    ...    cell=${scell_3}

    ${start_vonr}   Get Time  epoch
    Start Voice Call    vc_alias=call    ue_alias=${ue}    to=0105
    BuiltIn.Sleep   10s   wait call started
    ${status}   check_voice_call_state   vc_alias=call
    Run Keyword And Continue On Failure    Should Be Equal   ${status}   active
    Log To Console   \n VoNR has started, call status: ${status.upper()}

    ${avg_dl_tput}  ${avg_ul_tput}   Wait Downlink and Uplink Traffic Finish
    ${stop_tput}   Get Time  epoch
    ${ue_with_active_scell}   Evaluate   ${stop_tput} - ${start_tput}

    ulca.increase_counters
    ...   PSCELL_UE_1_ACT_SCELL_UL
    ...   PCELL_UE_1_ACT_SCELL_UL_SA
    ...   multiplier=${ue_with_active_scell}
    ...   cell=${pcell}

    ${stop_vonr}   Get Time  epoch
    Stop Voice Call    vc_alias=call
    ${call_duration}   Evaluate   (${stop_vonr} - ${start_vonr}) * 1000   # calculate to ms
    Log To Console   \n VoNR has stopped

    ulca.increase_counters
    ...   NG_FLOW_IN_SESSON_DUR_VONR
    ...   NG_FLOW_SESSION_DUR_NORM_5QI1
    ...   multiplier=${call_duration}
    ...   cell=${pcell}

    Detach Ue   ${ue}
    ${detach_time}   Get Time  epoch
    ${ue_with_configured_scell}   Evaluate   ${detach_time} - ${attach_time}

    ulca.increase_counters
    ...   PCELL_UL_1_SCELL_CONFIG_DUR_SA
    ...   UE_PCELL_1_CONF_SCELL_UL_SA
    ...   PCELL_UE_CAP_4_CC_DL_SA
    ...   UE_PCELL_3_CONF_SCELL_DL_SA
    ...   multiplier=${ue_with_configured_scell}
    ...   cell=${pcell}
    ulca.increase_counters
    ...   UE_SCELL_1_CONF_SCELL_UL_SA
    ...   multiplier=${ue_with_configured_scell}
    ...   cell=${scell}

    wro4_pm.sync_to_next_reporting_interval  offset=0
    wro4_pm.sync_to_next_reporting_interval
    ${pm_stop_time}   Get Time   epoch
    ${log_path}   logs.Stop Tracing And Download Logs From SMOD

    ${counter_values}   Collect Counters from Given Time    ${pm_start_time}  ${pm_stop_time}  ULCA_PM_COUNTERS
    Compare Tput from PM Counters with NAA value    ${counter_values}  ${avg_dl_tput}  ${avg_ul_tput}
    Verification PM Counters   ${counter_values}  ULCA_PM_COUNTERS

    [Teardown]   Run Keywords
    ...         Stop Data Transfer   DT_UL_${ue}
    ...   AND   Detach Ue   ${ue}
    ...   AND   logs.Stop Tracing On SMOD
    ...   AND   unset_preferred_cell


CB005935_Interworking_with_3GPP_based_overheating_handling
    [Documentation]   Interaction with CB008697 deactivation and activation scells scheduling based on UE Overheating Information,
     ...              checking traffic scheduling and counters verification
    # PRECONDITIONS
    overheat.prepare_startup_values_for_oh_pm
    Set Test Variable   ${ue}   MEDIATEK
    Set Test Variable   ${pcell}     100
    Set Test Variable   ${scell_1}   700
    Set Test Variable   ${scell_2}   400
    Set Test Variable   ${scell_3}   410
    set_preferred_cell   cell_id=${pcell}

    Require Ue   ${ue}  capabilities=${ue}

    wro4_pm.sync_to_next_reporting_interval   offset=1
    ${pm_start_time}   Get Time  epoch

    Show Text on Console   Attach UE to PCell and SCells, run TCP Downlink and Uplink traffic

    logs.Start Tracing On SMOD   filename=attach_${ue}  smod slave=False
    Attach Ue    ${ue}
    ${attach_time}   Get Time  epoch
    ${pci}   Verify 5G SA Attach   ${ue}
    Should Be Equal As Strings   ${pcell}  ${pci}   ${ue} not attached to primary cell: ${pcell}

    Start Data Transfer In Given Direction   ${ue}  direction=DLUL  duration=1800s   offset=20s
    ${log_path}   logs.Stop Tracing And Download Logs From SMOD   filename=attach_${ue}
    scells_added   pcap_file=${log_path}  num_of_scells=3  scells_id=${scell_1},${scell_2},${scell_3}
    Log To Console   \n Three scells added, tput in both directions onging...
    Check Average Tput for both directions

    Show Text on Console   OVERHEATING SIMULATION, DEACTIVATE ONE DL SCELL, PCI:${scell_2}
    Trigger UE Overheating Assistance Command   OH_opeation=enter  dl_scells=2  ul_scells=1
    overheat.increase_counters
    ...   SCELL_DEACT_UE_OVH_REPORTS
    ...   multiplier=1
    ...   cell=${pcell}
    overheat.increase_counters
    ...   SCELL_DL_DEACT_UEOVHT_SA
    ...   cell=${scell_2}
    # Verify Tput in L1L2 Logs   expected_dl_scells=${scell_1},${scell_3}   expected_ul_scells=${scell_1}   dropped_dl_scells=${scell_2}
    Check Average Tput for both directions

    Show Text on Console   OVERHEATING SIMULATION, DEACTIVATE NEXT ONE DL SCELL, PCI:${scell_3}
    Trigger UE Overheating Assistance Command   OH_opeation=enter  dl_scells=1  ul_scells=1
    overheat.increase_counters
    ...   SCELL_DEACT_UE_OVH_REPORTS
    ...   multiplier=1
    ...   cell=${pcell}
    overheat.increase_counters
    ...   SCELL_DL_DEACT_UEOVHT_SA
    ...   cell=${scell_3}
    # Verify Tput in L1L2 Logs   expected_dl_scells=${scell_1}   expected_ul_scells=${scell_1}   dropped_dl_scells=${scell_2},${scell_3}
    Check Average Tput for both directions

    Show Text on Console   OVERHEATING SIMULATION, ACTIVATE ALL DL AND UL SCELLS
    Trigger UE Overheating Assistance Command   OH_opeation=enter  dl_scells=3  ul_scells=1
    # Verify Tput in L1L2 Logs   expected_dl_scells=${scell_1},${scell_2},${scell_3}   expected_ul_scells=${scell_1}
    Check Average Tput for both directions

    Show Text on Console   OVERHEATING SIMULATION, DEACTIVATE ALL DL AND UL SCELLS
    Trigger UE Overheating Assistance Command   OH_opeation=enter  dl_scells=0  ul_scells=0
    overheat.increase_counters
    ...   SCELL_DEACT_UE_OVH_REPORTS
    ...   multiplier=3
    ...   cell=${pcell}
    overheat.increase_counters
    ...   SCELL_DL_DEACT_UEOVHT_SA
    ...   cell=${scell_1}
    overheat.increase_counters
    ...   SCELL_DL_DEACT_UEOVHT_SA
    ...   cell=${scell_2}
    overheat.increase_counters
    ...   SCELL_DL_DEACT_UEOVHT_SA
    ...   cell=${scell_3}
    overheat.increase_counters
    ...   SCELL_UL_DEACT_UEOVHT_SA
    ...   cell=${scell_1}
    # Verify Tput in L1L2 Logs   dropped_dl_scells=${scell_1},${scell_2},${scell_3}   dropped_ul_scells=${scell_1}
    Check Average Tput for both directions

    Show Text on Console   OVERHEATING SIMULATION, ACTIVATE UL SCELL, PCI:${scell_1}
    Trigger UE Overheating Assistance Command   OH_opeation=enter  dl_scells=1  ul_scells=1
    # Verify Tput in L1L2 Logs   expected_dl_scells=${scell_1}   expected_ul_scells=${scell_1}  dropped_dl_scells=${scell_2},${scell_3}
    Check Average Tput for both directions

    Show Text on Console   OVERHEATING SIMULATION, ACTIVATE ALL DL AND UL SCELLS
    Trigger UE Overheating Assistance Command   OH_opeation=enter  dl_scells=2  ul_scells=1
    # Verify Tput in L1L2 Logs   expected_dl_scells=${scell_1},${scell_2},${scell_3}   expected_ul_scells=${scell_1}
    Check Average Tput for both directions

    Show Text on Console   OVERHEATING SIMULATION, PERFORM COMMAND OVERHEATING ASSISTANCE NO LONGER OCCURS
    Trigger UE Overheating Assistance Command   OH_opeation=leave  dl_scells=0  ul_scells=0
    # Verify Tput in L1L2 Logs   expected_dl_scells=${scell_1},${scell_2},${scell_3}   expected_ul_scells=${scell_1}
    Check Average Tput for both directions

    Detach Ue   ${ue}
    ${detach_time}   Get Time  epoch
    ${ue_configured_for_oh}   Evaluate   ${detach_time} - ${attach_time}
    overheat.increase_counters
    ...   SUM_CONF_UE_OVH_REPORTS
    ...   multiplier=${ue_configured_for_oh}
    ...   cell=${pcell}

    wro4_pm.sync_to_next_reporting_interval  offset=0
    wro4_pm.sync_to_next_reporting_interval
    ${pm_stop_time}   Get Time   epoch

    ${pm_intervals_number}   wro4_pm.calculate_pm_intervals_number   ${pm_start_time}  ${pm_stop_time}
    overheat.increase_counters
    ...   MAX_CONFG_UE_OVH_REPORTS
    ...   multiplier=${pm_intervals_number}   # in every pm interval one UE
    ...   cell=${pcell}

    ${counter_values}   Collect Counters from Given Time    ${pm_start_time}  ${pm_stop_time}  OH_PM_COUNTERS
    Verification PM Counters   ${counter_values}  OH_PM_COUNTERS

    [Teardown]   Run Keywords
    ...         Set Mtk Gmc Feature   ${ue}   oh_op=0   cc_dl=0   cc_ul=0
    ...   AND   Detach Ue   ${ue}
    ...   AND   logs.Stop Tracing On SMOD
    ...   AND   unset_preferred_cell


Trigger UE Overheating Assistance Command
    [Arguments]     ${dl_scells}   ${ul_scells}   ${OH_opeation}=enter
    Log To Console   \n Send UE Assistance Information and verify message\n
    ${oh_op}   Set Variable If   '${OH_opeation}' == 'enter'   1  0
    Set Test Variable   ${oh_msg_no}   ${oh_msg_no+1}
    logs.Start Tracing On SMOD   filename=ue_assistance_information_${oh_msg_no}  smod slave=False
    Set Mtk Gmc Feature   ${ue}   oh_op=${oh_op}   cc_dl=${dl_scells}   cc_ul=${ul_scells}
    ${logs_path}   Tcpdump.Stop tcpdump and download logs from SMOD
    ${log_path}   logs.Stop Tracing And Download Logs From SMOD   filename=ue_assistance_information_${oh_msg_no}
    overheat.verify_ue_assistance_information   pcap_file=${log_path}  oh_op=${OH_opeation}  expected_CCsDL=${dl_scells}  expected_CCsUL=${ul_scells}

    overheat.increase_counters
    ...   NUM_UE_OVH_REPORTS
    ...   cell=${pcell}

    ${max_cc}    Set Variable If    ${dl_scells} >= ${ul_scells}    ${dl_scells}    ${ul_scells}
    IF  ${oh_op} == 1
        overheat.increase_counters
        ...   NUM_REQ_${max_cc}_SCELL_ALLOW_OVH
        ...   cell=${pcell}
    END

    IF  ${oh_op} == 0
        overheat.increase_counters
        ...   NUM_UE_OVH_REPORTS_RECOVERY
        ...   cell=${pcell}
    END


Verify Tput in L1L2 Logs
    [Arguments]     ${expected_dl_scells}=None   ${expected_ul_scells}=None   ${dropped_dl_scells}=None    ${dropped_ul_scells}=None
    Log To Console   \n Verify traffic on PCell and SCells in L1L2 logs\n
    start_l1l2_collection    filename=bip_${oh_msg_no}.pcap    mirroring_time=2   cell_ids=${pcell},${scell_1},${scell_2}
    ${bip_file}   stop_l1l2_collection
	Run Keyword And Continue On Failure    Run Keywords
    ...        Run Keyword If   '${expected_dl_scells}' != 'None'
    ...            dl_data_scheduled_on_pcell_and_scells   pcap_file=${bip_file}   pcell_id=${pcell}   scells=${expected_dl_scells}
    ...  AND   Run Keyword If   '${expected_ul_scells}' != 'None'
    ...            ul_data_scheduled_on_pcell_and_scells   pcap_file=${bip_file}   pcell_id=${pcell}   scells=${expected_ul_scells}
    ...  AND   Run Keyword If   '${dropped_dl_scells}' != 'None'
    ...            dl_data_is_not_scheduled_on_scells   pcap_file=${bip_file}   scells=${dropped_dl_scells}
    ...  AND   Run Keyword If   '${dropped_ul_scells}' != 'None'
    ...            ul_data_is_not_scheduled_on_scells   pcap_file=${bip_file}   scells=${dropped_ul_scells}


Check Average Tput for both directions
    [Arguments]     ${period_to_analyse}=${30}
    BuiltIn.Sleep   ${period_to_analyse}s
    ${avg_tput}   Get Average Throughput   dt_name=DT_DL_${ue}  from_last=${period_to_analyse}  #tput_collection_src=control_app
    ${avg_tput}   Evaluate   ${avg_tput} / 1000
    ${avg_dl_tput}   Evaluate   "%.1f" % ${avg_tput}
    ${avg_tput}   Get Average Throughput   dt_name=DT_UL_${ue}  from_last=${period_to_analyse}  #tput_collection_src=control_app
    ${avg_tput}   Evaluate   ${avg_tput} / 1000
    ${avg_ul_tput}   Evaluate   "%.1f" % ${avg_tput}
    Log To Console   \n AVERAGE TPUT measurements: \n${SPACE} DL: ${avg_dl_tput} Mbits/sec \n${SPACE} UL: ${avg_ul_tput} Mbits/sec \n
    [Return]   ${avg_dl_tput}  ${avg_ul_tput}
