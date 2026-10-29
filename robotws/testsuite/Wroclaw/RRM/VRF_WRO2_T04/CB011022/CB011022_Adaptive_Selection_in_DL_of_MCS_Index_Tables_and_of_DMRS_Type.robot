*** Settings ***
Documentation
...   author: Pawel Zabawczuk
...   contact: pawel.k.zabawczuk@nokia.com


Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB011022/resources/keywords_11022.robot


*** Keywords ***
CB011022_PCell_only_DMRS_MCS_Table_switching_based_on_indication_for_PCell
    [Documentation]   This test case checks adaptive MCS or/and DMRS type selection
    ...            TEST STEPS
    ...             0. Preparation before test
    ...             1. Attach UE in good radio conditions, run traffic, next worsen radio conditions and
    ...                reestablish UE to other cell in good radio conditions, detach UE
    ...             2. Attach UE, run traffic in good radio conditions, next worsen them and verify MCS Table chnage from 256QAM to 64QAM for PCell
    ...             3. Improve radio conditions and verify MCS Table chnage from 64QAM to 256QAM for PCell, detach UE
    ...             4. DISABLE feature, attach UE, run traffic in good radio conditions, next worsen them and verify no changes in MCS Table and
    ...                Type of DMRS, next sync to PM interval and verify tput on PCell from whole interval
    ...             5. Improve radio conditions and verify no changes in MCS Table and Type of DMRS - feature still DISABLED, detach UE
    ...             6. Attach UE and run traffic in good radio conditions starting with DMRS ${dlDmrsTypeAtConnectionDynSel} and MCS 256QAM
    ...             7. Worsen radio conditions and check switching of DMRS to Type1, next sync to PM interval and verify tput on PCell
    ...                from whole interval and compare tputs when feature is disabled and enabled
    ...             8. Improve radio conditions and check switching of DMRS to Type2, detach UE
    ...             9. Attach UE, run traffic and VoNR in good radio conditions, then worsen them and verify no changes due to ongoing call
    ...             10. Collect PM counters and verify them
    Log    ********** PRECONDITIONS **********
    Show Text on Console   Setup BTS before testing
    adapsel.prepare_startup_values
    Set Test Variable   ${ue}   SAMSUNG_5
    set_preferred_cell   cell_id=110,400
    Require Ue   ${ue}  capabilities=${ue}

    wro4_pm.sync_to_next_reporting_interval   offset=1
    ${pm_start_time}   Get Time  epoch

    Log    ********** STEP 1 **********
    Show Text on Console   Attach UE, run traffic in good radio conditions, next worsen them and reestablish UE to other cell (good radio conditions)
    ...     colour=${REDBG}   show_timestamp=no
    Set Test Variable   ${pcell}     110
    Set Test Variable   ${scell_1}   400
    Set Test Variable   ${scell_2}   410
    Set Test Variable   ${scell_3}   700
    Set Test Variable   ${reest_cell}     400
    Get BTSs settings
    Set Attenuation  90dB  ${ATTENUATOR['AEHC_1']['ports']}  confirm=${TRUE}
    logs.Start Tracing on SMOD   filename=CB011022_1_1_attach   smod slave=False
    Attach Ue   ${ue}
    ${pci}   Verify 5G SA Attach   ${ue}
    Should Be Equal As Strings   ${pcell}  ${pci}   ${ue} not attached to primary cell: ${pcell}
    Set Attenuation  0dB  ${ATTENUATOR['AEHC_1']['ports']}  confirm=${TRUE}

    Start Data Transfer In Given Direction   ${ue}   direction=DLUL   duration=600s
    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   filename=CB011022_1_1_attach   stop_tracing=NO
    scells_added   pcap_file=${logs_path}  num_of_scells=3  scells_id=${scell_1},${scell_2},${scell_3}
    Log To Console   \n Three scells added, tput in both directions ongoing...

    Set Bad Radio Condition   on_radio=AHFII_1   required_rsrp=-114
    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   filename=CB011022_1_1_attach
    Run Keyword And Continue On Failure
    ...    verify_rrc_reconfiguration_call_flow   pcap_file=${logs_path}

    adapsel.increase_counters
    ...   NR_DWGRADE_256QAM_ATT
    ...   NR_DWGRADE_256QAM_SUCC
    ...   cell=${pcell}

    logs.Start Tracing on SMOD   filename=CB011022_1_1_reestablish   smod slave=False
    Set Attenuation  90dB  ${ATTENUATOR['AHFII_1']['ports']}  confirm=${TRUE}
    ${pci}   Verify 5G SA Attach   ${ue}
    Should Be Equal As Strings   ${reest_cell}  ${pci}   ${ue} not reestablished to cell: ${reest_cell}
    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   filename=CB011022_1_1_reestablish
    Run Keyword And Continue On Failure
    ...    verify_rrc_reconfiguration_call_flow   pcap_file=${logs_path}

    adapsel.increase_counters
    ...   PDSCH_DMRS_SWITCH_TYPE1TO2_ATT
    ...   PDSCH_DMRS_SWITCH_TYPE1TO2
    ...   REESTAB_RRCRECONFIG_SUCC
    ...   cell=${reest_cell}

    BuiltIn.Sleep   20s
    Stop Data Transfers For All UEs
    Detach Ue   ue_alias=${ue}
    Log To Console   \n UE ${ue} detached
    Set Attenuation  0dB  ${ATTENUATOR['AHFII_1']['ports']}  confirm=${TRUE}

    Log    ********** STEP 2 **********
    Show Text on Console   Attach UE and run traffic in good radio conditions, next worsen them and verify MCS Table chnage from 256QAM to 64QAM
    ...     colour=${REDBG}   show_timestamp=no
    Set Test Variable   ${pcell}     400
    Set Test Variable   ${scell_1}   110
    Set Test Variable   ${scell_2}   410
    Set Test Variable   ${scell_3}   700
    Set Test Variable   ${distname}   MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${pcell}
    change_a2_threshold   cell=${pcell}   value=34
    Update Parameter   param=actDlMcsTableAndDmrsSwitching  value=DL MCS table  distname=${distname}
    Get BTSs settings

    logs.Start Tracing on SMOD   filename=CB011022_1_2_mcs_switch_down   smod slave=False
    Attach Ue   ${ue}
    ${pci}   Verify 5G SA Attach   ${ue}
    Should Be Equal As Strings   ${pcell}  ${pci}   ${ue} not attached to primary cell: ${pcell}

    Start Data Transfer In Given Direction   ${ue}   direction=DLUL   duration=600s
    BuiltIn.Sleep   10s
    Set Bad Radio Condition   on_radio=AEHC_1   required_rsrp=-118
    Verify 5G SA Attach   ue=${ue}
    BuiltIn.Sleep   10s
    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   filename=CB011022_1_2_mcs_switch_down
    Run Keyword And Continue On Failure
    ...    verify_rrc_reconfiguration_call_flow   pcap_file=${logs_path}

    adapsel.increase_counters
    ...   NR_DWGRADE_256QAM_ATT
    ...   NR_DWGRADE_256QAM_SUCC
    ...   cell=${pcell}
    BuiltIn.Sleep   10s

    Log    ********** STEP 3 **********
    Show Text on Console    Improve radio conditions and verify MCS Table chnage from 64QAM to 256QAM
    ...    colour=${REDBG}   show_timestamp=no

    logs.Start Tracing on SMOD   filename=CB011022_1_3_mcs_switch_up   smod slave=False
    Set Attenuation  0dB  ${ATTENUATOR['AEHC_1']['ports']}  confirm=${TRUE}
    Verify 5G SA Attach   ue=${ue}
    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   filename=CB011022_1_3_mcs_switch_up
    Run Keyword And Continue On Failure
    ...    verify_rrc_reconfiguration_call_flow   pcap_file=${logs_path}

    adapsel.increase_counters
    ...   NR_UPGRADE_256QAM_ATT
    ...   NR_UPGRADE_256QAM_SUCC
    ...   cell=${pcell}

    Stop Data Transfers For All UEs
    Detach Ue   ue_alias=${ue}
    Log To Console   \n UE ${ue} detached

    Log    ********** STEP 4 **********
    Show Text on Console
    ...   DISABLE feature, attach UE, run traffic in good radio conditions, next worsen them and verify no changes in MCS Table and Type of DMRS
    ...     colour=${REDBG}   show_timestamp=no
    Update Parameter   param=actDlMcsTableAndDmrsSwitching  value=disabled  distname=${distname}
    Get BTSs settings
    logs.Start Tracing on SMOD   filename=CB011022_1_4_feat_ff   smod slave=False
    Attach Ue   ${ue}
    ${pci}   Verify 5G SA Attach   ${ue}
    Should Be Equal As Strings   ${pcell}  ${pci}   ${ue} not attached to primary cell: ${pcell}

    Start Data Transfer In Given Direction   ${ue}   direction=DLUL   duration=1200s
    BuiltIn.Sleep   10s
    Set Bad Radio Condition   on_radio=AEHC_1   required_rsrp=-118
    Verify 5G SA Attach   ue=${ue}

    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   filename=CB011022_1_4_feat_ff
    Run Keyword And Continue On Failure
    ...    verify_no_changes_in_mcs_table_and_type_of_dmrs   pcap_file=${logs_path}

    Show Text on Console   Sync to next PM interval and check DL tput on PCell in bad radio condition from whole pm interval - feature OFF
    wro4_pm.sync_to_next_reporting_interval   offset=0
    BuiltIn.Sleep   300s
    ${pcell_dl_tput_feat_off}   check_tput_on_pcell   pcell=${pcell}

    Log    ********** STEP 5 **********
    Show Text on Console    Improve radio conditions and verify no changes in MCS Table and Type of DMRS - feature still DISABLED
    ...    colour=${REDBG}   show_timestamp=no

    logs.Start Tracing on SMOD   filename=CB011022_1_5_feat_ff   smod slave=False
    Set Attenuation  0dB  ${ATTENUATOR['AEHC_1']['ports']}  confirm=${TRUE}
    Verify 5G SA Attach   ue=${ue}
    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   filename=CB011022_1_5_feat_ff
    Run Keyword And Continue On Failure
    ...    verify_no_changes_in_mcs_table_and_type_of_dmrs   pcap_file=${logs_path}

    Stop Data Transfers For All UEs
    Detach Ue   ue_alias=${ue}
    Log To Console   \n UE ${ue} detached

    Log    ********** STEP 6 **********
    Show Text on Console    Attach UE and run traffic in good radio conditions starting with DMRS ${dlDmrsTypeAtConnectionDynSel} and MCS 256QAM
    ...    colour=${REDBG}   show_timestamp=no
    Update Parameter   param=actDlMcsTableAndDmrsSwitching  value=DMRS type  distname=${distname}
    Get BTSs settings
    logs.Start Tracing on SMOD   filename=CB011022_1_6_dmrs_switch_at_conn   smod slave=False
    Attach Ue   ${ue}
    ${pci}   Verify 5G SA Attach   ${ue}
    Should Be Equal As Strings   ${pcell}  ${pci}   ${ue} not attached to primary cell: ${pcell}

    Start Data Transfer In Given Direction   ${ue}   direction=DLUL   duration=1200s

    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   filename=CB011022_1_6_dmrs_switch_at_conn
    Run Keyword And Continue On Failure
    ...    verify_rrc_reconfiguration_call_flow   pcap_file=${logs_path}

    adapsel.increase_counters
    ...   PDSCH_DMRS_SWITCH_TYPE1TO2_ATT
    ...   PDSCH_DMRS_SWITCH_TYPE1TO2
    ...   cell=${pcell}
    BuiltIn.Sleep   20s

    Log    ********** STEP 7 **********
    Show Text on Console    Worsen radio conditions and check switching of DMRS to Type1
    ...    colour=${REDBG}   show_timestamp=no

    logs.Start Tracing on SMOD   filename=CB011022_1_7_dmrs_switch_down   smod slave=False
    Set Bad Radio Condition   on_radio=AEHC_1   required_rsrp=-118
    Verify 5G SA Attach   ue=${ue}
    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   filename=CB011022_1_7_dmrs_switch_down
    Run Keyword And Continue On Failure
    ...    verify_rrc_reconfiguration_call_flow   pcap_file=${logs_path}

    adapsel.increase_counters
    ...   PDSCH_DMRS_SWITCH_TYPE2TO1_ATT
    ...   PDSCH_DMRS_SWITCH_TYPE2TO1
    ...   cell=${pcell}

    Show Text on Console   Sync to next PM interval and check DL tput on PCell in bad radio condition from whole pm interval - feature ON
    wro4_pm.sync_to_next_reporting_interval   offset=0
    BuiltIn.Sleep   300s
    ${pcell_dl_tput_feat_on}   check_tput_on_pcell   pcell=${pcell}

    Run Keyword And Continue On Failure   Should Be True   ${pcell_dl_tput_feat_on} > ${pcell_dl_tput_feat_off}
    ${gain}   Evaluate   ((${pcell_dl_tput_feat_on}-${pcell_dl_tput_feat_off}) / ${pcell_dl_tput_feat_off}) * 100
    ${gain}   Evaluate   "%.1f" % ${gain}
    Log To Console
    ...   \nDL TPUT on PCELL in bad radio conditions:\n feature OFF: ${pcell_dl_tput_feat_off}Mbit/s,\n feature ON: ${pcell_dl_tput_feat_on}Mbit/s
    Log To Console   ${SPACE} GAIN: ${gain}%

    Log    ********** STEP 8 **********
    Show Text on Console    Improve radio conditions and check switching of DMRS to Type2
    ...    colour=${REDBG}   show_timestamp=no

    logs.Start Tracing on SMOD   filename=CB011022_1_8_dmrs_switch_up   smod slave=False
    Set Attenuation  0dB  ${ATTENUATOR['AEHC_1']['ports']}  confirm=${TRUE}
    Verify 5G SA Attach   ue=${ue}
    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   filename=CB011022_1_8_dmrs_switch_up
    Run Keyword And Continue On Failure
    ...    verify_rrc_reconfiguration_call_flow   pcap_file=${logs_path}

    adapsel.increase_counters
    ...   PDSCH_DMRS_SWITCH_TYPE1TO2_ATT
    ...   PDSCH_DMRS_SWITCH_TYPE1TO2
    ...   cell=${pcell}

    Stop Data Transfers For All UEs
    Detach Ue   ue_alias=${ue}
    Log To Console   \n UE ${ue} detached

    Log    ********** STEP 9 **********
    Show Text on Console    Attach UE, run traffic and VoNR in good radio conditions, then worsen them and verify no changes due to ongoing call
    ...    colour=${REDBG}   show_timestamp=no
    Update Parameter   param=actDlMcsTableAndDmrsSwitching  value=DL MCS table + DMRS type   distname=${distname}
    Get BTSs settings
    logs.Start Tracing on SMOD   filename=CB011022_1_9_dmrs_switch_at_conn   smod slave=False
    Attach Ue   ${ue}
    ${pci}   Verify 5G SA Attach   ${ue}
    Should Be Equal As Strings   ${pcell}  ${pci}   ${ue} not attached to primary cell: ${pcell}

    Start Data Transfer In Given Direction   ${ue}   direction=DLUL   duration=600s

    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   filename=CB011022_1_9_dmrs_switch_at_conn
    Run Keyword And Continue On Failure
    ...    verify_rrc_reconfiguration_call_flow   pcap_file=${logs_path}

    adapsel.increase_counters
    ...   PDSCH_DMRS_SWITCH_TYPE1TO2_ATT
    ...   PDSCH_DMRS_SWITCH_TYPE1TO2
    ...   cell=${pcell}

    BuiltIn.Sleep   20s
    Start Voice Call    vc_alias=call    ue_alias=${ue}    to=0105
    BuiltIn.Sleep   10s   wait call started
    ${status}   check_voice_call_state   vc_alias=call
    Run Keyword And Continue On Failure    Should Be Equal   ${status}   active
    Log To Console   \n VoNR has started, call status: ${status.upper()}
    Set Test Variable   ${actDlMcsTableAndDmrsSwitching}   disabled   # the same behaviour when call ongoing
    # When call started DMRS change to Type1 - trigger is Not Radio Conditions so counters are not incremented

    logs.Start Tracing on SMOD   filename=CB011022_1_9_vonr_no_changes   smod slave=False
    Set Bad Radio Condition   on_radio=AEHC_1   required_rsrp=-118
    Verify 5G SA Attach   ue=${ue}

    ${status}   check_voice_call_state   vc_alias=call
    Run Keyword And Continue On Failure    Should Be Equal   ${status}   active
    BuiltIn.Sleep   20s
    Set Attenuation  0dB  ${ATTENUATOR['AEHC_1']['ports']}  confirm=${TRUE}
    Verify 5G SA Attach   ue=${ue}

    ${status}   check_voice_call_state   vc_alias=call
    Run Keyword And Continue On Failure    Should Be Equal   ${status}   active

    BuiltIn.Sleep   20s
    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   filename=CB011022_1_9_vonr_no_changes
    Run Keyword And Continue On Failure
    ...    verify_no_changes_in_mcs_table_and_type_of_dmrs   pcap_file=${logs_path}

    logs.Start Tracing on SMOD   filename=CB011022_1_9_vonr_stopped   smod slave=False
    Stop Voice Call    vc_alias=call
    Log To Console   \n VoNR has stopped
    # When call stopped DMRS change to Type2 (good radio condition) - trigger is Radio Conditions so counters are incremented
    Set Test Variable   ${actDlMcsTableAndDmrsSwitching}   DL MCS table + DMRS type

    Stop Data Transfers For All UEs
    Detach Ue   ue_alias=${ue}
    Log To Console   \n UE ${ue} detached

    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   filename=CB011022_1_9_vonr_stopped
    Run Keyword And Continue On Failure
    ...    verify_rrc_reconfiguration_call_flow   pcap_file=${logs_path}

    adapsel.increase_counters
    ...   PDSCH_DMRS_SWITCH_TYPE1TO2_ATT
    ...   PDSCH_DMRS_SWITCH_TYPE1TO2
    ...   cell=${pcell}

    Log    ********** STEP 10 **********
    wro4_pm.sync_to_next_reporting_interval   offset=1
    wro4_pm.sync_to_next_reporting_interval
    ${pm_stop_time}   Get Time   epoch

    ${counter_values}   Collect Counters from Given Time    ${pm_start_time}  ${pm_stop_time}  MCS_DMRS_PM_COUNTERS
    Verification PM Counters   ${counter_values}  MCS_DMRS_PM_COUNTERS

    [Teardown]   Run Keywords
    ...         Stop Data Transfers For All UEs
    ...   AND   Detach Ue   ue_alias=${ue}
    ...   AND   Set Attenuation  0dB  ${ATTENUATOR['AEHC_1']['ports']}  confirm=${TRUE}
    ...   AND   Set Attenuation  0dB  ${ATTENUATOR['AHFII_1']['ports']}  confirm=${TRUE}
    ...   AND   unset_preferred_cell
    ...   AND   change_a2_threshold   cell=${pcell}   value=72
    ...   AND   Update Parameter
    ...             param=actDlMcsTableAndDmrsSwitching
    ...             value=DL MCS table + DMRS type
    ...             distname=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-400
    ...   AND   Stop Tracing On SMOD


CB011022_PCell_and_SCell_DMRS_MCS_Table_switching_based_on_indication_for_PCell
    [Documentation]   This test case checks adaptive MCS or/and DMRS type selection
    ...            TEST STEPS
    ...             0. Preconditions to test - dlMcsTabAndDmrsSwitchImpCells set to PCellandSCellsOnPCellTrig
    ...             1. Attach UE in good radio conditions - for TDD cells DMRS Type is change from 1 to 2 (at connection), next worsen radio
    ...                conditions on PCell and DMRS and MCS table change on PCell and for all SCells where
    ...                actDlMcsTableAndDmrsSwitching is not disabled
    ...             2. Improve radio conditions and check DMRS and MCS table changes for PCell and SCells
    ...             3. Stop tput, wait UE moves to IDLE mode, then set bad radio conditions on new PCell (reselection during release) and
    ...                start tput - MCS Table changes from 256 to 64qam for PCell and SCells where actDlMcsTableAndDmrsSwitching is not disabled.
    ...             4. Improve radio conditions, new TDD scells are replaced so MCS table upgrade only on PCell, SCells added with 256qam  -
    ...                no need to upgrade, DMRS no chnaged beacse PCell is trigger and it's FDD cell so on MCS Table could be change
    ...             5. Collect PM counters and verify them
    Log    ********** PRECONDITIONS **********
    Show Text on Console   Setup BTS before testing
    adapsel.prepare_startup_values
    Set Test Variable   ${ue}   SAMSUNG_5
    set_preferred_cell   cell_id=400,700
    Require Ue   ${ue}  capabilities=${ue}

    wro4_pm.sync_to_next_reporting_interval   offset=1
    ${pm_start_time}   Get Time  epoch

    Log    ********** STEP 1 **********
    Show Text on Console   Attach UE and run traffic in good radio conditions, next worsen them and verify changes on Pcell and SCells
    ...     colour=${REDBG}   show_timestamp=no
    Set Test Variable   ${pcell}     400
    Set Test Variable   ${scell_1}   110
    Set Test Variable   ${scell_2}   410
    Set Test Variable   ${scell_3}   700
    Change APN   ue_name=SAMSUNG_S25   apn_name=5gsawro
    change_a2_threshold   cell=${pcell}   value=34
    Update Parameter   param=dlMcsTabAndDmrsSwitchImpCells  value=PCellandSCellsOnPCellTrig
    Update Parameter
    ...   param=actDlMcsTableAndDmrsSwitching
    ...   value=disabled
    ...   distname=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${scell_1}
    Log  to add fdd scells in bad radio conditions when the cell will be pcell during test
    change_a1_scell_add_threshold   cell=${scell_3}   value_fdd=37
    Get BTSs settings

    Set Attenuation  90dB  ${ATTENUATOR['AHLOB_1']['ports']}  confirm=${TRUE}
    logs.Start Tracing on SMOD   filename=CB011022_2_1_atach   smod slave=False
    Attach Ue   ${ue}
    ${pci}   Verify 5G SA Attach   ${ue}
    Should Be Equal As Strings   ${pcell}  ${pci}   ${ue} not attached to primary cell: ${pcell}
    Set Attenuation  0dB  ${ATTENUATOR['AHLOB_1']['ports']}  confirm=${TRUE}

    Start Data Transfer In Given Direction   ${ue}   direction=DLUL   duration=600s   interface_name=5gsawro
    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   filename=CB011022_2_1_atach
    scells_added   pcap_file=${logs_path}  num_of_scells=3  scells_id=${scell_1},${scell_2},${scell_3}
    Log To Console   \n Three scells added, tput in both directions ongoing...

    Run Keyword And Continue On Failure
    ...    verify_rrc_reconfiguration_call_flow   pcap_file=${logs_path}

    adapsel.increase_counters
    ...   PDSCH_DMRS_SWITCH_TYPE1TO2_ATT
    ...   PDSCH_DMRS_SWITCH_TYPE1TO2
    ...   cell=${pcell}
    adapsel.increase_counters
    ...   PDSCH_DMRS_SWITCH_TYPE1TO2_ATT
    ...   PDSCH_DMRS_SWITCH_TYPE1TO2
    ...   cell=${scell_2}
    BuiltIn.Sleep   20s

    logs.Start Tracing on SMOD   filename=CB011022_2_2_down_radio_cond_pcell_trig   smod slave=False
    Set Bad Radio Condition   on_radio=AEHC_1   required_rsrp=-120
    Verify 5G SA Attach   ue=${ue}
    BuiltIn.Sleep   10s
    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   filename=CB011022_2_2_down_radio_cond_pcell_trig
    Run Keyword And Continue On Failure
    ...    verify_rrc_reconfiguration_call_flow   pcap_file=${logs_path}

    adapsel.increase_counters
    ...   PDSCH_DMRS_SWITCH_TYPE2TO1_ATT
    ...   PDSCH_DMRS_SWITCH_TYPE2TO1
    ...   NR_DWGRADE_256QAM_ATT
    ...   NR_DWGRADE_256QAM_SUCC
    ...   cell=${pcell}
    adapsel.increase_counters
    ...   PDSCH_DMRS_SWITCH_TYPE2TO1_ATT
    ...   PDSCH_DMRS_SWITCH_TYPE2TO1
    ...   NR_DWGRADE_256QAM_ATT
    ...   NR_DWGRADE_256QAM_SUCC
    ...   cell=${scell_2}
    adapsel.increase_counters
    ...   NR_DWGRADE_256QAM_ATT
    ...   NR_DWGRADE_256QAM_SUCC
    ...   cell=${scell_3}
    BuiltIn.Sleep   10s

    Log    ********** STEP 2 **********
    Show Text on Console    Improve radio conditions and verify changes on Pcell and SCells
    ...    colour=${REDBG}   show_timestamp=no

    logs.Start Tracing on SMOD   filename=CB011022_2_3_up_radio_cond_pcell_trig   smod slave=False
    Set Attenuation  0dB  ${ATTENUATOR['AEHC_1']['ports']}  confirm=${TRUE}
    Verify 5G SA Attach   ue=${ue}
    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   filename=CB011022_2_3_up_radio_cond_pcell_trig
    Run Keyword And Continue On Failure
    ...    verify_rrc_reconfiguration_call_flow   pcap_file=${logs_path}

    adapsel.increase_counters
    ...   PDSCH_DMRS_SWITCH_TYPE1TO2_ATT
    ...   PDSCH_DMRS_SWITCH_TYPE1TO2
    ...   NR_UPGRADE_256QAM_ATT
    ...   NR_UPGRADE_256QAM_SUCC
    ...   cell=${pcell}
    adapsel.increase_counters
    ...   PDSCH_DMRS_SWITCH_TYPE1TO2_ATT
    ...   PDSCH_DMRS_SWITCH_TYPE1TO2
    ...   NR_UPGRADE_256QAM_ATT
    ...   NR_UPGRADE_256QAM_SUCC
    ...   cell=${scell_2}
    adapsel.increase_counters
    ...   NR_UPGRADE_256QAM_ATT
    ...   NR_UPGRADE_256QAM_SUCC
    ...   cell=${scell_3}
    BuiltIn.Sleep   10s

    Log    ********** STEP 3 **********
    Show Text on Console    Stop traffic, wait UE moves to IDLE mode, set bad radio conditions and run traffic - verify changes on Pcell and SCells
    ...    colour=${REDBG}   show_timestamp=no

    Stop Data Transfers For All UEs
    Set Test Variable   ${pcell}     700
    Set Test Variable   ${scell_1}   100
    Set Test Variable   ${scell_2}   110
    Set Test Variable   ${scell_3}   400
    Set Test Variable   ${scell_4}   410
    logs.Start Tracing on SMOD   filename=CB011022_2_4_idle_mode   smod slave=False
    BuiltIn.Sleep   60s   wait for idle mode
    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   filename=CB011022_2_4_idle_mode
    verify_rrc_release   pcap_file=${logs_path}
    ${pci}   Verify 5G SA Attach   ${ue}
    Should Be Equal As Strings   ${pcell}  ${pci}   ${ue} not attached to primary cell: ${pcell}


    Set Bad Radio Condition   on_radio=AHLOB_1   required_rsrp=-118
    Verify 5G SA Attach   ue=${ue}

    logs.Start Tracing on SMOD   filename=CB011022_2_5_down_radio_cond_pcell_trig   smod slave=False
    Start Data Transfer In Given Direction   ${ue}   direction=DLUL   duration=600s   interface_name=5gsawro
    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   filename=CB011022_2_5_down_radio_cond_pcell_trig
    scells_added   pcap_file=${logs_path}  num_of_scells=2  scells_id=${scell_1},${scell_2}
    Run Keyword And Continue On Failure
    ...    verify_rrc_reconfiguration_call_flow   pcap_file=${logs_path}

    adapsel.increase_counters
    ...   NR_DWGRADE_256QAM_ATT
    ...   NR_DWGRADE_256QAM_SUCC
    ...   cell=${pcell}
    adapsel.increase_counters
    ...   NR_DWGRADE_256QAM_ATT
    ...   NR_DWGRADE_256QAM_SUCC
    ...   cell=${scell_1}
    BuiltIn.Sleep   10s

    Log    ********** STEP 4 **********
    Show Text on Console    Improve radio conditions and verify changes on Pcell, add new TDD SCells, no changes on MCS Table - started with 256qam
    ...    colour=${REDBG}   show_timestamp=no

    logs.Start Tracing on SMOD   filename=CB011022_2_6_up_radio_cond_pcell_trig   smod slave=False
    Set Attenuation  0dB  ${ATTENUATOR['AHLOB_1']['ports']}  confirm=${TRUE}
    Verify 5G SA Attach   ue=${ue}
    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   filename=CB011022_2_6_up_radio_cond_pcell_trig
    scells_added   pcap_file=${logs_path}  num_of_scells=2  scells_id=${scell_3},${scell_4}   index_start=${3}
    Run Keyword And Continue On Failure
    ...    verify_rrc_reconfiguration_call_flow   pcap_file=${logs_path}

    adapsel.increase_counters
    ...   NR_UPGRADE_256QAM_ATT
    ...   NR_UPGRADE_256QAM_SUCC
    ...   cell=${pcell}
    BuiltIn.Sleep   10s

    Stop Data Transfers For All UEs

    Detach Ue   ue_alias=${ue}
    Log To Console   \n UE ${ue} detached

    Log    ********** STEP 5 **********
    wro4_pm.sync_to_next_reporting_interval   offset=1
    wro4_pm.sync_to_next_reporting_interval
    ${pm_stop_time}   Get Time   epoch

    ${counter_values}   Collect Counters from Given Time    ${pm_start_time}  ${pm_stop_time}  MCS_DMRS_PM_COUNTERS
    Verification PM Counters   ${counter_values}  MCS_DMRS_PM_COUNTERS

    [Teardown]   Run Keywords
    ...         Stop Data Transfers For All UEs
    ...   AND   Change APN   ue_name=SAMSUNG_S25   apn_name=internet
    ...   AND   Detach Ue   ue_alias=${ue}
    ...   AND   Set Attenuation  0dB  ${ATTENUATOR['AEHC_1']['ports']}  confirm=${TRUE}
    ...   AND   unset_preferred_cell
    ...   AND   change_a2_threshold   cell=${pcell}   value=72
    ...   AND   change_a1_scell_add_threshold   cell=700
    ...   AND   Update Parameter   param=dlMcsTabAndDmrsSwitchImpCells  value=onlyPcell
    ...   AND   Update Parameter
    ...             param=actDlMcsTableAndDmrsSwitching
    ...             value=DL MCS table
    ...             distname=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-110
    ...   AND   Stop Tracing On SMOD


CB011022_PCell_and_SCell_DMRS_MCS_Table_switching_based_on_indication_for_Serving_Cell
    [Documentation]   This test case checks adaptive MCS or/and DMRS type selection
    ...            TEST STEPS
    ...             0. Preconditions to test - dlMcsTabAndDmrsSwitchImpCells set to servingCell and one TDD scell on disabled
    ...             1. Attach UE in good radio conditions - for TDD cells DMRS Type is change from 1 to 2 (at connection)
    ...             2. Worsen radio condition on FDD scell - verify MCS Table switching
    ...             3. Worsen radio condition on second FDD scell - verify MCS Table switching
    ...             4. Worsen radio condition on PCell - verify MCS Table and DMRS Type switching
    ...             5. Improve radio conditions on PCell and first SCell - verify MCS Table and DMRS Type switching, detach UE - on FDD scell
    ...                still in badradio conditions during release
    ...             6. Collect PM counters and verify them
    Log    ********** PRECONDITIONS **********
    Show Text on Console   Setup BTS before testing
    adapsel.prepare_startup_values
    Set Test Variable   ${ue}   SAMSUNG_5
    Set Test Variable   ${pcell}     400
    Set Test Variable   ${scell_1}   110
    Set Test Variable   ${scell_2}   410
    Set Test Variable   ${scell_3}   700
    Require Ue   ${ue}  capabilities=${ue}
    Check RSRP level on SCells
    set_preferred_cell   cell_id=${pcell}
    change_a2_threshold   cell=${pcell}   value=34
    Update Parameter   param=dlMcsTabAndDmrsSwitchImpCells  value=servingCell
    Update Parameter
    ...   param=actDlMcsTableAndDmrsSwitching
    ...   value=disabled
    ...   distname=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${scell_2}
    Get BTSs settings

    wro4_pm.sync_to_next_reporting_interval   offset=1
    ${pm_start_time}   Get Time  epoch

    Log    ********** STEP 1 **********
    Show Text on Console   Attach UE and run traffic in good radio conditions, verify DMRS change at connection
    ...     colour=${REDBG}   show_timestamp=no

    logs.Start Tracing on SMOD   filename=CB011022_3_1_atach   smod slave=False
    Attach Ue   ${ue}
    ${pci}   Verify 5G SA Attach   ${ue}
    Should Be Equal As Strings   ${pcell}  ${pci}   ${ue} not attached to primary cell: ${pcell}

    Start Data Transfer In Given Direction   ${ue}   direction=DLUL   duration=600s
    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   filename=CB011022_3_1_atach
    scells_added   pcap_file=${logs_path}  num_of_scells=3  scells_id=${scell_1},${scell_2},${scell_3}
    Log To Console   \n Three scells added, tput in both directions ongoing...

    Run Keyword And Continue On Failure
    ...    verify_rrc_reconfiguration_call_flow   pcap_file=${logs_path}

    adapsel.increase_counters
    ...   PDSCH_DMRS_SWITCH_TYPE1TO2_ATT
    ...   PDSCH_DMRS_SWITCH_TYPE1TO2
    ...   cell=${pcell}
    BuiltIn.Sleep   20s

    Log    ********** STEP 2 **********
    Show Text on Console   Worsen radio conditions on FDD scell, PCI:${scell_1} - verify MCS Table switching
    ...     colour=${REDBG}   show_timestamp=no
    logs.Start Tracing on SMOD   filename=CB011022_3_2_bad_radio_cond_scel_1   smod slave=False
    Set Bad Radio Condition   on_radio=AHFII_1   required_rsrp=-114   scell=${scell_1}
    Verify 5G SA Attach   ue=${ue}
    BuiltIn.Sleep   10s
    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   filename=CB011022_3_2_bad_radio_cond_scel_1
    Run Keyword And Continue On Failure
    ...    verify_rrc_reconfiguration_call_flow   pcap_file=${logs_path}

    adapsel.increase_counters
    ...   NR_DWGRADE_256QAM_ATT
    ...   NR_DWGRADE_256QAM_SUCC
    ...   cell=${scell_1}
    BuiltIn.Sleep   10s

    Log    ********** STEP 3 **********
    Show Text on Console   Worsen radio conditions on FDD scell, PCI:${scell_3} - verify MCS Table switching
    ...     colour=${REDBG}   show_timestamp=no
    logs.Start Tracing on SMOD   filename=CB011022_3_3_bad_radio_cond_scel_3   smod slave=False
    Set Bad Radio Condition   on_radio=AHLOB_1   required_rsrp=-116   scell=${scell_3}
    Verify 5G SA Attach   ue=${ue}
    BuiltIn.Sleep   10s
    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   filename=CB011022_3_3_bad_radio_cond_scel_3
    Run Keyword And Continue On Failure
    ...    verify_rrc_reconfiguration_call_flow   pcap_file=${logs_path}

    adapsel.increase_counters
    ...   NR_DWGRADE_256QAM_ATT
    ...   NR_DWGRADE_256QAM_SUCC
    ...   cell=${scell_3}
    BuiltIn.Sleep   10s

    Log    ********** STEP 4 **********
    Show Text on Console   Worsen radio conditions on PCell, PCI:${pcell} - verify DMRS Type and MCS Table switching
    ...     colour=${REDBG}   show_timestamp=no
    logs.Start Tracing on SMOD   filename=CB011022_3_4_bad_radio_cond_pcell   smod slave=False
    Set Bad Radio Condition   on_radio=AEHC_1   required_rsrp=-120
    Verify 5G SA Attach   ue=${ue}
    BuiltIn.Sleep   10s
    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   filename=CB011022_3_4_bad_radio_cond_pcell
    Run Keyword And Continue On Failure
    ...    verify_rrc_reconfiguration_call_flow   pcap_file=${logs_path}

    adapsel.increase_counters
    ...   PDSCH_DMRS_SWITCH_TYPE2TO1_ATT
    ...   PDSCH_DMRS_SWITCH_TYPE2TO1
    ...   NR_DWGRADE_256QAM_ATT
    ...   NR_DWGRADE_256QAM_SUCC
    ...   cell=${pcell}
    BuiltIn.Sleep   10s

    Log    ********** STEP 5 **********
    Show Text on Console    Improve radio conditions on PCell and first FDD SCell - verify DMRS Type and MCS Table switching
    ...    colour=${REDBG}   show_timestamp=no

    logs.Start Tracing on SMOD   filename=CB011022_3_5_up_radio_cond   smod slave=False
    Set Attenuation  0dB  ${ATTENUATOR['AHFII_1']['ports']}  confirm=${TRUE}
    Set Attenuation  0dB  ${ATTENUATOR['AEHC_1']['ports']}  confirm=${TRUE}
    Verify 5G SA Attach   ue=${ue}
    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   filename=CB011022_3_5_up_radio_cond
    Run Keyword And Continue On Failure
    ...    verify_rrc_reconfiguration_call_flow   pcap_file=${logs_path}

    adapsel.increase_counters
    ...   PDSCH_DMRS_SWITCH_TYPE1TO2_ATT
    ...   PDSCH_DMRS_SWITCH_TYPE1TO2
    ...   NR_UPGRADE_256QAM_ATT
    ...   NR_UPGRADE_256QAM_SUCC
    ...   cell=${pcell}
    adapsel.increase_counters
    ...   NR_UPGRADE_256QAM_ATT
    ...   NR_UPGRADE_256QAM_SUCC
    ...   cell=${scell_1}
    BuiltIn.Sleep   10s

    Stop Data Transfers For All UEs
    Detach Ue   ue_alias=${ue}
    Log To Console   \n UE ${ue} detached

    Log    ********** STEP 6 **********
    wro4_pm.sync_to_next_reporting_interval   offset=1
    wro4_pm.sync_to_next_reporting_interval
    ${pm_stop_time}   Get Time   epoch

    ${counter_values}   Collect Counters from Given Time    ${pm_start_time}  ${pm_stop_time}  MCS_DMRS_PM_COUNTERS
    Verification PM Counters   ${counter_values}  MCS_DMRS_PM_COUNTERS

    [Teardown]   Run Keywords
    ...         Stop Data Transfers For All UEs
    ...   AND   Detach Ue   ue_alias=${ue}
    ...   AND   Set Attenuation  0dB  ${ATTENUATOR['AHLOB_1']['ports']}  confirm=${TRUE}
    ...   AND   unset_preferred_cell
    ...   AND   change_a2_threshold   cell=${pcell}   value=72
    ...   AND   Update Parameter   param=dlMcsTabAndDmrsSwitchImpCells  value=onlyPcell
    ...   AND   Update Parameter
    ...             param=actDlMcsTableAndDmrsSwitching
    ...             value=DL MCS table + DMRS type
    ...             distname=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-410
    ...   AND   Stop Tracing On SMOD
