*** Settings ***
Documentation
...   Test for CB009842 feature - ANR Timing Advance reporting for UL NR E-CID
...
...   author: Pawel Zabawczuk
...   contact: pawel.k.zabawczuk@nokia.com


Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC001167/resources/keywords.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB008083/CB008083.robot
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB009842/resources/specific_keywords_9842.py    WITH NAME    ecid
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB009842/resources/ecid_trigger.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ue_utils.py
Variables    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB009842/resources/ecid_pm_counters.py


*** Keywords ***
CB009842_NR_Timing_Advance_reporting_for_UL_NR_ECID
    ecid.prepare_startup_values
    Set Test Variable   ${pcell}   410
    Set Test Variable   ${scell}   400
    set_preferred_cell   cell_id=${pcell}

    Set Test Variable   ${ue}  ASUS
    ${imsi}    get_imsi   ASUS
    Require Ue   ${ue}  capabilities=${ue}

    wro4_pm.sync_to_next_reporting_interval   offset=1
    ${pm_start_time}   Get Time  epoch

    Show Text on Console   Attach UE to PCell and verify SCell addition

    Set Test Variable   ${log_index}  _attach_and_trigger
    logs.Start Tracing On SMOD   smod slave=False
    Attach Ue    ${ue}
    ${pci}   Verify 5G SA Attach   ${ue}
    Should Be Equal As Strings   ${pcell}  ${pci}   ${ue} not attached to primary cell: ${pcell}
    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   stop_tracing=NO
    scells_added   pcap_file=${logs_path}  num_of_scells=1  scells_id=${scell}
    Start Data Transfer In Given Direction   ${ue}   direction=DLUL   duration=1800s

    Ecid Trigger    imsi=${imsi}    meas_quantities=TimingAdvanceNR,SS_RSRP,SS_RSRQ,AngleOfArrivalNR      #report_characteristics=Periodic

    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   offset=10s
    verify_ecid_trigger_call_flow    pcap_file=${logs_path}

    ecid.increase_counters
    ...    NRPPA_MEASINIT_REQ_D
    ...    F1_ECID_MEASINIT_REQ
    ...    F1_ECID_MEASINIT_RESP
    ...    NRPPA_MEASINIT_RESP_D
    ...    cell=${pcell}

    Stop data transfers for all ues
    Log To Console   \n Data transfers stopped

    Show Text on Console   Wait UE moves to Inactive state, trigger E-CID and verify resume to connected state

    Set Test Variable   ${log_index}  _inactive_and_trigger
    logs.Start Tracing On SMOD   smod slave=False
    BuiltIn.Sleep   35s
    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   stop_tracing=NO
    is_ue_in_inactive_state   pcap_file=${logs_path}

    Ecid Trigger    imsi=${imsi}    meas_quantities=TimingAdvanceNR

    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   offset=10s
    check_rrc_resume_msg_in_pcap_file   pcap_file=${logs_path}  direction=DL  msg_occurence=1
    verify_ecid_trigger_call_flow    pcap_file=${logs_path}

    ecid.increase_counters
    ...    NRPPA_MEASINIT_REQ_D
    ...    F1_ECID_MEASINIT_REQ
    ...    F1_ECID_MEASINIT_RESP
    ...    NRPPA_MEASINIT_RESP_D
    ...    cell=${pcell}

    Show Text on Console   Perform NG Link shutdown by block all NR cells, than UP it again and trigger E-CID

    block_all_nr_cells
    ${AMF}   Set Variable   cmm-nala
    ${current_status}   get_amf_status
    Verify AMF status   ${current_status}  amf=${AMF}   expected_status=Inactive

    unblock_all_nr_cells
    ${current_status}   get_amf_status
    Verify AMF status   ${current_status}  amf=${AMF}   expected_status=Active
    AdminUtils.wait_for_all_cells_on_air_state

    ${pci}   Verify 5G SA Attach   ${ue}
    Should Be Equal As Strings   ${pcell}  ${pci}   ${ue} not attached to primary cell: ${pcell}

    Set Test Variable   ${log_index}  _nglink_shutdown_and_trigger
    logs.Start Tracing On SMOD   smod slave=False

    Ecid Trigger    imsi=${imsi}    meas_quantities=TimingAdvanceNR,SS_RSRP,SS_RSRQ,AngleOfArrivalNR

    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   offset=10s
    verify_ecid_trigger_call_flow    pcap_file=${logs_path}

    ecid.increase_counters
    ...    NRPPA_MEASINIT_REQ_D
    ...    F1_ECID_MEASINIT_REQ
    ...    F1_ECID_MEASINIT_RESP
    ...    NRPPA_MEASINIT_RESP_D
    ...    cell=${pcell}

    Detach Ue   ${ue}

    Show Text on Console   Send E-CID for different timingAdvanceOffset and verify NR-TADV value (EDA 03947999)   colour=${REDBG}  show_timestamp=no

    Show Text on Console   Attach UE
    Set Test Variable   ${pcell}   700
    set_preferred_cell   cell_id=${pcell}
    Log   Attenuate rest nrcells to avoid cell reselection
    ${rus}   Create List   AHFII  AEHC
    Set Attenuation on Radios   90dB  ${rus}

    Set Test Variable   ${ue}  SAMSUNG_1
    ${imsi}    get_imsi   SAMSUNG_1
    Require Ue   ${ue}  capabilities=${ue}

    Attach Ue    ${ue}
    ${pci}   Verify 5G SA Attach   ${ue}
    Should Be Equal As Strings   ${pcell}  ${pci}   ${ue} not attached to primary cell: ${pcell}

    ${tadv_offset}   Set Variable   25600
    Show Text on Console   Check NR-TADV value for timingAdvanceOffset=${tadv_offset}

    Set Test Variable   ${log_index}  _trigger_tavdoffset_${tadv_offset}
    logs.Start Tracing On SMOD   smod slave=False

    Ecid Trigger    imsi=${imsi}    meas_quantities=TimingAdvanceNR

    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD
    verify_ecid_trigger_call_flow    pcap_file=${logs_path}

    ecid.increase_counters
    ...    NRPPA_MEASINIT_REQ_D
    ...    F1_ECID_MEASINIT_REQ
    ...    F1_ECID_MEASINIT_RESP
    ...    NRPPA_MEASINIT_RESP_D
    ...    cell=${pcell}

    ${nr_tadv_n25600}   check_timing_advance_value   ${logs_path}
    Log To Console   \n NR-TADV for timingAdvanceOffset=${tadv_offset} is ${nr_tadv_n25600}

    ${tadv_offset}   Set Variable   0
    Show Text on Console   Check NR-TADV value for timingAdvanceOffset=${tadv_offset}

    change_timingAdvanceOffset_param   value=n${tadv_offset}
    AdminUtils.wait_for_all_cells_on_air_state
    Wait Until Keyword Succeeds   240  30    verify_x2_link_status   enb_id=${nrbts_id}   expected_status=available
    ${pci}   Verify 5G SA Attach   ${ue}
    Should Be Equal As Strings   ${pcell}  ${pci}   ${ue} not attached to primary cell: ${pcell}

    Set Test Variable   ${log_index}  _trigger_tavdoffset_${tadv_offset}
    logs.Start Tracing On SMOD   smod slave=False

    Ecid Trigger    imsi=${imsi}    meas_quantities=TimingAdvanceNR

    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD
    verify_ecid_trigger_call_flow    pcap_file=${logs_path}

    ecid.increase_counters
    ...    NRPPA_MEASINIT_REQ_D
    ...    F1_ECID_MEASINIT_REQ
    ...    F1_ECID_MEASINIT_RESP
    ...    NRPPA_MEASINIT_RESP_D
    ...    cell=${pcell}

    ${nr_tadv_n0}   check_timing_advance_value   ${logs_path}
    Log To Console   \n NR-TADV for timingAdvanceOffset=${tadv_offset} is ${nr_tadv_n0}

    Run Keyword And Continue On Failure   Run Keywords
    ...        Should Be Equal As Integers   ${nr_tadv_n25600}   ${nr_tadv_n0}   timingAdvanceOffsets are different
    ...   AND  Log To Console   \n NR-TADV values for different timingAdvanceOffsets are EQUAL

    wro4_pm.sync_to_next_reporting_interval    offset=0
    wro4_pm.sync_to_next_reporting_interval
    ${pm_stop_time}   Get Time   epoch

    ${counter_values}   Collect Counters from Given Time    ${pm_start_time}  ${pm_stop_time}  ECID_PM_COUNTERS
    Verification PM Counters   ${counter_values}  ECID_PM_COUNTERS

    [Teardown]   Run Keywords
    ...         Detach Ue   ASUS
    ...   AND   Detach Ue   SAMSUNG_1
    ...   AND   logs.Stop Tracing On SMOD
    ...   AND   Set Attenuation on Radios   0dB  ${rus}
    ...   AND   unset_preferred_cell
    ...   AND   change_timingAdvanceOffset_param   value=n25600
