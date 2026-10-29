*** Settings ***
Documentation
...   author: Pawel Zabawczuk
...   contact: pawel.k.zabawczuk@nokia.com


Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB011041/resources/counters.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/tput_keywords.robot
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB006449/resources/specific_keywords_6449.py    WITH NAME    ulca
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC001167/resources/pcap_verifiers.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/l1l2_verifiers.py
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils   WITH NAME    AdminUtils
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.gnb_mirroring.L1L2     WITH NAME    L1L2
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB006449/resources/ulca_pm_counters.py


*** Variables ***
${ul_tput_duration}              180
${tput_packet_size}              1360
${avg_tput_deviation}            10   # in percentage
${ul_volume_deviation}           15   # in percentage
@{add_key}                       SST
${a1ThresholdPCellSwitch}        -62
${reportAmountCA}                1    # 1 if actBufferBasedSCellAddition=disabled

*** Keywords ***
CB006449_UL_CA_2CC
    [Documentation]   This test case checks UL 2CC and verify counters related to pcell and scell
    # PRECONDITIONS
    ulca.prepare_startup_values
    Set Test Variable   ${pcell}      400
    Set Test Variable   ${scell}      410
    Set Test Variable   ${scell_2}    700
    Set Test Variable   ${scells_num}   2
    set_preferred_cell   cell_id=${pcell}
    Set Test Variable   ${ue}   MEDIATEK
    # Log To Console   \n Reboot ${ue} before test execution, can take a while
    Require Ue   ${ue}  capabilities=${ue}
    # Reboot Ue    ue_alias=${ue}   timeout=180

    wro4_pm.sync_to_next_reporting_interval   offset=1
    ${pm_start_time}   Get Time  epoch

    Show Text on Console   Attach UE to PCell, run TCP Uplink traffic and verify sCell addition durring attach

    logs.Start Tracing On SMOD   smod slave=False
    Attach Ue    ${ue}
    ${attach_time}   Get Time  epoch
    ${pci}   Verify 5G SA Attach   ${ue}
    Should Be Equal As Strings   ${pcell}  ${pci}   ${ue} not attached to primary cell: ${pcell}

    ${start_tput}   Get Time  epoch
    Start Data Transfer In Given Direction   ${ue}  direction=DLUL  duration=${ul_tput_duration}s
    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   stop_tracing=NO
    scells_added   pcap_file=${logs_path}  num_of_scells=${scells_num}  scells_id=${scell},${scell_2}
    Log To Console   \n Two scells added, tput in both directions onging...

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
    ...    GNB_DL_SCELL_2_CONFIG_REQ_SA
    ...    GNB_DL_SCELL_2_CONFIG_SUCC_SA
    ...    GNB_DU_DL_SCELL_2_ADMI_REQ_SA
    ...    GNB_DU_DL_SCELL_2_ADMI_SUCC_SA
    ...    MAX_UE_PCELL_2_CONF_SCEL_DL_SA
    ...    RRC_RECONF_ADD2DLSCELL_ATT_SA
    ...    RRC_RECONF_ADD2DLSCELL_SUCC_SA
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
    ...   UE_PCELL_2_CONF_SCELL_DL_SA
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


CB006449_Successful_PCell_switch_in_FR1_TDD_TDD_UL_CA_mode
    [Documentation]   This test case checks PCell switch PCell->SCell and verify A1 HO counters
    ulca.prepare_startup_values_for_ho_pm
    Set Test Variable   ${ul_tput_duration}   1200
    Set Test Variable   ${pcell}   410
    Set Test Variable   ${scell}   400
    Set Test Variable   ${ue}   MEDIATEK
    Set Test Variable   ${ue_slice}   3

    # Log To Console   \n Reboot ${ue} before test execution, can take a while
    Require Ue   ${ue}  capabilities=${ue}
    # Reboot Ue    ue_alias=${ue}   timeout=180
    set_preferred_cell   cell_id=${pcell}
    Set Attenuation and activate PCell switch

    wro4_pm.sync_to_next_reporting_interval   offset=1
    ${pm_start_time}   Get Time  epoch

    Show Text on Console   Attach UE to PCell, run TCP Uplink traffic and verify sCell addition durring attach

    Set Test Variable   ${log_index}  _attach
    logs.Start Tracing On SMOD   smod slave=False
    Attach Ue    ${ue}
    ${attach_time}   Get Time  epoch
    ${pci}   Verify 5G SA Attach   ${ue}
    Should Be Equal As Strings   ${pcell}  ${pci}   ${ue} not attached to primary cell: ${pcell}

    ${start_tput}   Get Time  epoch
    Start Data Transfer In Given Direction   ${ue}  direction=UL  duration=${ul_tput_duration}s
    ${log_path}   logs.Stop Tracing And Download Logs From SMOD
    scells_added   pcap_file=${log_path}  num_of_scells=1  scells_id=${scell}

    wro4_pm.sync_to_next_reporting_interval  offset=0
    ${stop_tput}   Get Time  epoch
    ${tput_duration}   Evaluate   ${stop_tput} - ${start_tput}

    ulca.increase_ho_counters
    ...    PSCELL_UE_1_ACT_SCELL_UL
    ...    key=${pcell}
    ...    multiplier=${tput_duration}

    Log To Console   \n ${ue}: PCell:${pcell}, SCell:${scell} - measured tput duration: ${tput_duration} sec

    ${start_tput}   Get Time  epoch
    Show Text on Console   Clear attenuation to make handover - PCell switch via A1 measurment
    Set Test Variable   ${pcell}     400
    Set Test Variable   ${scell}     410
    Set Test Variable   ${scell_2}   700
    Set Test Variable   ${log_index}  _handover

    logs.Start Tracing On SMOD   smod slave=False
    Set Attenuation  0dB  ${ATTENUATOR['AEHC_1']['ports']}  confirm=${TRUE}
    Wait Until Keyword Succeeds   1min  10s   Verify Handover to Cell   target_cell=${pcell}
    ${log_path}   logs.Stop Tracing And Download Logs From SMOD
    Ue Handovered  ${log_path}    target_cell=${pcell}
    scells_added    pcap_file=${log_path}    num_of_scells=2    scells_id=${scell},${scell_2}

    ${previous_pcell}   Set Variable   ${scell}
    ulca.increase_ho_counters
    ...    ATT_A1_IF_INTRA_DU_HO_SA_PLMN
    ...    SUCC_A1_IF_INTRA_DU_HO_SA_PLMN
    ...    key=${previous_pcell}
    ulca.increase_ho_counters
    ...    ATT_A1_IF_INTRA_DU_HO_SLICE
    ...    SUCC_A1_IF_INTRA_DU_HO_SLICE
    ...    key=${ue_slice}

    wro4_pm.sync_to_next_reporting_interval  offset=0
    ${stop_tput}   Get Time  epoch
    ${tput_duration}   Evaluate   ${stop_tput} - ${start_tput}

    ulca.increase_ho_counters
    ...    PSCELL_UE_1_ACT_SCELL_UL
    ...    key=${pcell}
    ...    multiplier=${tput_duration}

    Log To Console   \n ${ue}: PCell:${pcell}, SCell:${scell} - measured tput duration: ${tput_duration} sec

    wro4_pm.sync_to_next_reporting_interval
    ${pm_stop_time}   Get Time   epoch
    ${counter_values}   Collect Counters from Given Time    ${pm_start_time}  ${pm_stop_time}  ULCA_HO_PM_COUNTERS   ${add_key}
    Verification PM Counters   ${counter_values}  ULCA_HO_PM_COUNTERS
    Verification PM Counters per Slice   ${counter_values}  ULCA_HO_PM_COUNTERS

    [Teardown]   Run Keywords
    ...         Stop Data Transfer   DT_UL_${ue}
    ...   AND   Detach Ue   ${ue}
    ...   AND   logs.Stop Tracing On SMOD
    ...   AND   Set Attenuation  0dB  ${ATTENUATOR['AEHC_1']['ports']}  confirm=${TRUE}
    ...   AND   Update Parameter   param=a1BasedPCellSwitchEnabled   value=false   distname=${bts_prefix}/NRCELL-410/NRHOIF-1
    ...   AND   unset_preferred_cell


Set Attenuation and activate PCell switch
    Attach Ue    ${ue}
    ${pci}   Verify 5G SA Attach   ${ue}
    Should Be Equal As Strings   ${pcell}  ${pci}   ${ue} not attached to primary cell: ${pcell}
    ${CELL_INFO}   Get UE Info   ${ue}  CELL_INFO
    ${signal_strength}   Set Variable   ${CELL_INFO}[dbm]
    ${required_signal}   Set Variable   -65
    ${attenuation}   Evaluate   ${signal_strength} - ${required_signal}
    Run Keyword If   ${attenuation} < 1   Fail   Signal strength for PCell lower than A1PcellSwitch threshold, check UE position in shieldbox
    Set Attenuation  ${attenuation}dB  ${ATTENUATOR['AEHC_1']['ports']}  confirm=${TRUE}
    Update Parameter   param=a1BasedPCellSwitchEnabled   value=true   distname=${bts_prefix}/NRCELL-${pcell}/NRHOIF-1
    [Teardown]   Detach Ue   ${ue}


Wait Downlink and Uplink Traffic Finish
    Await Data Transfer Finish    DT_DL_${ue}
    Await Data Transfer Finish    DT_UL_${ue}

    ${avg_tput}   Get Average Throughput   dt_name=DT_DL_${ue}
    ${avg_tput}   Evaluate   ${avg_tput} / 1000
    ${avg_dl_tput}   Evaluate   "%.1f" % ${avg_tput}
    ${avg_tput}   Get Average Throughput   dt_name=DT_UL_${ue}
    ${avg_tput}   Evaluate   ${avg_tput} / 1000
    ${avg_ul_tput}   Evaluate   "%.1f" % ${avg_tput}
    Log To Console   \n Tput in both directions has finished
    [Return]   ${avg_dl_tput}  ${avg_ul_tput}


Compare Tput from PM Counters with NAA value
    [Arguments]   ${counter_values}  ${naa_dl_tput}  ${naa_ul_tput}
    Log   Calculate average tput in Mbits/sec for PCell and SCell/s from counters (volume in bytes) and compare with value from UE (NAA)
    ${pcell_volume}   Evaluate   ${counter_values}[M55316C14001][NRCELL-${pcell}] * 8 / 1000000
    ${pcell_ul_tput}   Evaluate   ${pcell_volume} / ${ul_tput_duration}
    ${pcell_ul_tput}   Evaluate   "%.1f" % ${pcell_ul_tput}
    ${scell_volume}   Evaluate   ${counter_values}[M55316C14002][NRCELL-${scell}] * 8 / 1000000
    ${scell_ul_tput}   Evaluate   ${scell_volume} / ${ul_tput_duration}
    ${scell_ul_tput}   Evaluate   "%.1f" % ${scell_ul_tput}
    ${pm_ul_tput}   Evaluate   ${pcell_ul_tput} + ${scell_ul_tput}
    ${ul_tput_diff}   Evaluate   abs((${pm_ul_tput} - ${naa_ul_tput}) / ${naa_ul_tput} * 100)
    ${ul_tput_diff}   Evaluate   "%.1f" % ${ul_tput_diff}
    Log To Console   \nUL AVG TPUT measurements: \n NAA iperf: ${naa_ul_tput} Mbits/sec \n PM Volume Counters: ${pm_ul_tput} Mbits/sec
    Log To Console   ${SPACE*3} PCell PCI:${pcell}: ${pcell_ul_tput} Mbits/sec \n${SPACE*3} SCell PCI:${scell}: ${scell_ul_tput} Mbits/sec
    Log To Console   ${SPACE}UL Tput difference: ${ul_tput_diff}% \n

    Run Keyword If   ${ul_tput_diff} < ${avg_tput_deviation}   Run Keywords
    ...    ulca.increase_counters
    ...      UL_RLC_PDU_VOL_RX_PRI_PATH
    ...      RLC_PDU_VOL_RX_PRI_SA_CA
    ...      multiplier=${counter_values}[M55316C14001][NRCELL-${pcell}]
    ...      cell=${pcell}     AND
    ...    ulca.increase_counters
    ...      UL_RLC_PDU_VOL_RX_SEC_PATH
    ...      RLC_PDU_VOL_RX_SCELL_SA_CA
    ...      multiplier=${counter_values}[M55316C14002][NRCELL-${scell}]
    ...      cell=${scell}

    ${pcell_dl_tput}   Evaluate   (${counter_values}[M55310C20001][NRCELL-${pcell}] * 8 / 1000000) / ${ul_tput_duration}
    ${pcell_dl_tput}   Evaluate   "%.1f" % ${pcell_dl_tput}
    ${scell_dl_tput}   Evaluate   (${counter_values}[M55310C20000][NRCELL-${scell}] * 8 / 1000000) / ${ul_tput_duration}
    ${scell_dl_tput}   Evaluate   "%.1f" % ${scell_dl_tput}
    ${scell2_dl_tput}   Evaluate   (${counter_values}[M55310C20000][NRCELL-${scell_2}] * 8 / 1000000) / ${ul_tput_duration}
    ${scell2_dl_tput}   Evaluate   "%.1f" % ${scell2_dl_tput}
    IF  ${scells_num} == 3
        ${scell3_dl_tput}   Evaluate   (${counter_values}[M55310C20000][NRCELL-${scell_3}] * 8 / 1000000) / ${ul_tput_duration}
        ${scell3_dl_tput}   Evaluate   "%.1f" % ${scell2_dl_tput}
        ${pm_dl_tput}   Evaluate   ${pcell_dl_tput} + ${scell_dl_tput} + ${scell2_dl_tput} + ${scell3_dl_tput}
    ELSE
        ${pm_dl_tput}   Evaluate   ${pcell_dl_tput} + ${scell_dl_tput} + ${scell2_dl_tput}
    END
    ${dl_tput_diff}   Evaluate   abs((${pm_dl_tput} - ${naa_dl_tput}) / ${naa_dl_tput} * 100)
    ${dl_tput_diff}   Evaluate   "%.1f" % ${ul_tput_diff}
    Log To Console   DL AVG TPUT measurements: \n NAA iperf: ${naa_dl_tput} Mbits/sec \n PM Volume Counters: ${pm_dl_tput} Mbits/sec
    Log To Console   ${SPACE*3} PCell PCI:${pcell}: ${pcell_dl_tput} Mbits/sec \n${SPACE*3} SCell PCI:${scell}: ${scell_dl_tput} Mbits/sec
    Log To Console   ${SPACE*3} SCell PCI:${scell_2}: ${scell2_dl_tput} Mbits/sec
    IF  ${scells_num} == 3
        Log To Console   ${SPACE*3} SCell PCI:${scell_3}: ${scell3_dl_tput} Mbits/sec
    END
    Log To Console   ${SPACE}DL Tput difference: ${ul_tput_diff}% \n

    Run Keyword If   ${dl_tput_diff} < ${avg_tput_deviation}   Run Keywords
    ...    ulca.increase_counters
    ...      NR_RLC_PDU_DL_VOL_CA_PCELL
    ...      multiplier=${counter_values}[M55310C20001][NRCELL-${pcell}]
    ...      cell=${pcell}     AND
    ...    ulca.increase_counters
    ...      NR_RLC_PDU_DL_VOL_CA_SCELL
    ...      multiplier=${counter_values}[M55310C20000][NRCELL-${scell}]
    ...      cell=${scell}     AND
    ...    ulca.increase_counters
    ...      NR_RLC_PDU_DL_VOL_CA_SCELL
    ...      multiplier=${counter_values}[M55310C20000][NRCELL-${scell_2}]
    ...      cell=${scell_2}
    Run Keyword If   ${dl_tput_diff} < ${avg_tput_deviation} and ${scells_num} == 3
    ...    ulca.increase_counters
    ...      NR_RLC_PDU_DL_VOL_CA_SCELL
    ...      multiplier=${counter_values}[M55310C20000][NRCELL-${scell_3}]
    ...      cell=${scell_3}

    Log   Compare volume on PCell and SCell calculated from counters measured in bytes and PDU units
    ${pcell_volume_from_PDUs}   Evaluate   ${counter_values}[M55316C14003][NRCELL-${pcell}] * ${tput_packet_size} * 8 / 1000000
    ${scell_volume_from_PDUs}   Evaluate   ${counter_values}[M55316C14004][NRCELL-${scell}] * ${tput_packet_size} * 8 / 1000000
    ${ul_ca_vol_from_PDUs}   Evaluate   ${pcell_volume_from_PDUs} + ${scell_volume_from_PDUs}

    ${ul_ca_vol_from_bytes}   Evaluate   ${pcell_volume} + ${scell_volume}
    ${ul_volume_diff}   Evaluate   abs((${ul_ca_vol_from_PDUs} - ${ul_ca_vol_from_bytes}) / ${ul_ca_vol_from_bytes} * 100)
    ${ul_volume_diff}   Evaluate   "%.1f" % ${ul_volume_diff}
    Log To Console   Volume difference calculated from counters measured in bytes vs PDUs is: ${ul_volume_diff}% \n

    Run Keyword And Warn On Failure   Should Be True   ${ul_volume_diff} < ${ul_volume_deviation}
    ...   The differrence could be related to average PDU size - could be smaller due to e.g. poor radio condition \n
    ulca.increase_counters
    ...    UL_RLC_PDU_RX_PRI_PATH
    ...    multiplier=${counter_values}[M55316C14003][NRCELL-${pcell}]
    ...    cell=${pcell}
    ulca.increase_counters
    ...    UL_RLC_PDU_RX_SEC_PATH
    ...    multiplier=${counter_values}[M55316C14004][NRCELL-${scell}]
    ...    cell=${scell}

    Log   Compare SCell volume measured from counters on PCell and SCell
    ${scell_vol_at_pcell}   Set Variable   ${counter_values}[M55349C00025][NRCELL-${pcell}]
    ${scell_vol_at_scell}   Set Variable   ${counter_values}[M55310C02032][NRCELL-${scell}]
    ${scell_volume_diff}   Evaluate   abs((${scell_vol_at_pcell} - ${scell_vol_at_scell}) / ${scell_vol_at_scell} * 100)
    ${scell_volume_diff}   Evaluate   "%.3f" % ${scell_volume_diff}
    Log To Console   SCell volume difference calculated on Pcell and SCell is: ${scell_volume_diff}%

    Run Keyword If   ${scell_volume_diff} < 1
    ...    ulca.increase_counters
    ...      RLC_PDU_VOL_RX_SEC_SA_CA_FR1
    ...      multiplier=${counter_values}[M55349C00025][NRCELL-${pcell}]
    ...      cell=${pcell}


Verification PM Counters per Slice
    [Arguments]   ${counter_values}  ${pm_dict_name}
    ${counters}   Get Dictionary Keys   ${${pm_dict_name}}
    FOR  ${ne_abbr}  IN  @{counters}
        ${pi_id}   Set Variable   ${${pm_dict_name}}[${ne_abbr}][PI_ID]
        ${key}     Set Variable   ${${pm_dict_name}}[${ne_abbr}][key]

        Run Keyword If   '${key}' == 'SST'
        ...     Verification HO Counters
        ...         ${pm_dict_name}
        ...         ${ne_abbr}
        ...         ${pi_id}
        ...         ${counter_values}
    END


Verification HO Counters
    [Arguments]   ${pm_dict_name}  ${ne_abbr}  ${pi_id}  ${counter_values}
    FOR  ${slice}  IN RANGE  ${4}
        ${sst_key}   Set Variable   SST-${slice+1}
        ${expected_value}   Set Variable   ${${pm_dict_name}}[${ne_abbr}][value][${sst_key}]
        ${measured_value}   Set Variable   ${counter_values}[${pi_id}][${sst_key}]
        ${msg_on_console}   Set Variable If   '${measured_value}' == '0'   False   True

        Run Keyword And Continue On Failure   Run Keywords   Should Be Equal As Integers   ${expected_value}  ${measured_value}
        ...    \n ${ne_abbr} (${sst_key}) counter is not correct, \n expected: ${expected_value}, \n current: ${measured_value}   values=False
        ...   AND   Log   ${SPACE} ${ne_abbr} (${sst_key}) counter value: ${measured_value}   console=${msg_on_console}
    END


Verify Handover to Cell
    [Arguments]   ${target_cell}
    ${pci}   Verify 5G SA Attach   ${ue}
    Should Be Equal As Strings   ${target_cell}  ${pci}   ${ue} not attached to target cell: ${target_cell}
