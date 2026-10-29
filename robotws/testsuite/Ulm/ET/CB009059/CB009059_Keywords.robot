*** Settings ***

Documentation
...    author: Ulm SQD 65
...    Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...    Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
...    Description: Keywords for CB009059

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Library     taf.config.wts        WITH NAME    wts_conf

Resource    ../resources/SQD65/sqd65_keywords.robot
Resource    ../resources/SQD65/sqd65_commissioning.robot
Resource    CB009059_Commissioning.robot
Resource    ./CB009059_PM_RD.robot

*** Variables ***

${EGATE_CONSOLE_LOG}                /opt/iphy/latest/egate_console.log

*** Keywords ***

Prepare TL for CB009059
    Sqd65 Common Setup
    Bring Airphone TL to on Air status

Prepare TL for CB009059-BA
    Sqd65 Common Setup
    Commissioning for BA
    Bring Airphone TL to on Air status

Reconfigure TL for CB009059-C-B8
    Create Testcase Log Directory
    ${SCF_TC_Setup}=    Get SCF from gNB    scf_name=ORIGINAL_SCF_FILE.xml
    Set Suite Variable  ${SCF_TC_Setup}
    Prepare WTS Config
    Update iphy file for C_B8
    Commissioning for C_B8
    Bring Airphone TL to on Air status    cfg_file=basic_setup_9059-C_B8.cfg
    Start Logging
    Set Suite Variable    ${SECTION}    1

Perform Preconditions of Test Scenario
    Create Testcase Log Directory
    IF    '${PREV_TEST_STATUS}'=='FAIL'    Perform Preconditions of Test Scenario in Case of Previous TC failed
    Start Logging
    ${SCF_TC_Setup}=               Get SCF from gNB
    Set Suite Variable  ${SCF_TC_Setup}
    Smf Param Reset
    Set Suite Variable    ${SECTION}    1

Perform Preconditions of Test Scenario in Case of Previous TC failed
    Teardown Egate Connection for Airphone
    Teardown Edaemon Connection for Airphone
    Bring Airphone TL to on Air status

Perform Postconditions of Test Case
    run_keyword_and_warn_on_failure    Stop logging
    Collect AP Sos Report and Snapshots
    Revert Delta Commissioning
    Combine and Delete Egate Log Files

Reconfigure TL back to Default Config
    run_keyword_and_warn_on_failure    Stop logging
    Collect AP Sos Report and Snapshots
    Combine and Delete Egate Log Files
    Teardown Egate Connection for Airphone
    Teardown Edaemon Connection for Airphone
    Reload original iphy file
    Revert Delta Commissioning
    Bring Airphone TL to on Air status

Revert Delta Commissioning
    ${log_dir}=                Get Testcase Log Directory
    ${curr_scf}=               Get SCF from gNB  target_dir=${log_dir}
    ${revert_file}=            Set Variable  ${log_dir}/revert.json
    scf.calculate_delta_scf    ${SCF_TC_Setup}  ${curr_scf}  ${revert_file}
    Config gNB with delta scf  ${revert_file}

Add Additional QOS Flows to Activate
    [Documentation]    Add additional qos flows to activate in addition to default qosflow
    [Arguments]    ${id}  ${additional_qosflows}
    Send Egate Command and verify output
    ...   cmd=smf_param id=${id} additional_qosflows_to_activate=${additional_qosflows}
    Log   Additional QOS flows-${additional_qosflows} added to activate in addition to default qosflow    console=${P_console}

Smf Param Reset
    [Documentation]    Reseting smf parameters to default values
    Send Egate Command and verify output
    ...   cmd=smf_param id=1 reset

Amf Param Update
    [Documentation]    Updating amf parameters to send  ICS always in response to registration request or updating to default values
    [Arguments]       ${send_ics_registration}
    IF  "${send_ics_registration}" == "on"    Send Egate Command and verify output    cmd=amf_param id=1 send_ics_registration=on
    ...   ELSE IF  "${send_ics_registration}" == "off"    Set amf Param Default as in WTS

Set amf Param Default as in WTS
    [Arguments]
    Send Egate Command and verify output
    ...   cmd=amf_param id=1 reset
    Send Egate Command and verify output
    ...   cmd=amf_param id=1 full_nas_auth=on ims_voice_3gpp=on

Start downlink Data Traffic in Egate on multiple Traffic IDs and QFIs
    [Documentation]    Starting downlink Data Traffic in Egate on multiple traffic IDs and QFIs
    [Arguments]    ${ue_id}  ${trf_id_range_min}  ${trf_id_range_max}  ${mbps}=175  ${start_qfi}=1  ${end_qfi}=1  ${pdu}=1
    FOR    ${trf_id}    IN RANGE    ${trf_id_range_min}   ${${trf_id_range_max}+1}
        Start downlink Data Traffic in Egate on multiple QFIs  ue_id=${ue_id}  trf_id=${trf_id}  start_qfi=${start_qfi}  end_qfi=${end_qfi}
        ...  pdu=${pdu}  mbps=${mbps}
    END

Start downlink Data Traffic in Egate on multiple QFIs
    [Documentation]    Starting downlink Data Traffic in Egate on multiple QFIs
    [Arguments]    ${ue_id}  ${trf_id}  ${pdu}  ${start_qfi}  ${end_qfi}  ${mbps}
    FOR    ${qfi}    IN RANGE    ${start_qfi}  ${${end_qfi}+1}
        Start data traffic in egate  ue_id=${ue_id}  direction=dl  mbps=${mbps}  trf_id=${trf_id}  pdu=${pdu}  qfi=${qfi}
    END

Start uplink Data Traffic in Egate on multiple Traffic IDs and QFIs
    [Documentation]    Starting uplink Data Traffic in Egate on multiple traffic IDs and QFIs
    [Arguments]    ${ue_id}  ${trf_id_range_min}  ${trf_id_range_max}  ${mbps}=175  ${start_qfi}=1  ${end_qfi}=1  ${pdu}=1
    FOR    ${trf_id}    IN RANGE    ${trf_id_range_min}   ${${trf_id_range_max}+1}
        Start uplink Data Traffic in Egate on multiple QFIs  ue_id=${ue_id}  trf_id=${trf_id}  start_qfi=${start_qfi}  end_qfi=${end_qfi}
        ...  pdu=${pdu}   mbps=${mbps}
    END

Start uplink Data Traffic in Egate on multiple QFIs
    [Documentation]    Starting uplink Data Traffic in Egate on multiple QFIs
    [Arguments]    ${ue_id}  ${trf_id}  ${pdu}  ${start_qfi}  ${end_qfi}  ${mbps}
    FOR    ${qfi}    IN RANGE    ${start_qfi}  ${${end_qfi}+1}
        Start data traffic in egate  ue_id=${ue_id}  direction=ul  mbps=${mbps}  trf_id=${trf_id}  pdu=${pdu}  qfi=${qfi}
    END

Start downlink Data Traffic in Egate on multiple Traffic IDs and PDUs
    [Documentation]    Starting downlink Data Traffic in Egate on multiple traffic IDs and PDUs
    [Arguments]    ${ue_id}  ${trf_id_range_min}  ${trf_id_range_max}  ${pdu_count}  ${qfi}  ${mbps}=175
    FOR    ${trf_id}    IN RANGE    ${trf_id_range_min}  ${${trf_id_range_max}+1}
        Start downlink Data Traffic in Egate on multiple PDUs  ue_id=${ue_id}  trf_id=${trf_id}  pdu_count=${pdu_count}  qfi=${qfi}  mbps=${mbps}
    END

Start downlink Data Traffic in Egate on multiple PDUs
    [Documentation]    Starting downlink Data Traffic in Egate on multiple PDUs
    [Arguments]    ${ue_id}  ${trf_id}  ${pdu_count}  ${qfi}  ${mbps}
    FOR    ${pdu}    IN RANGE    1  ${${pdu_count}+1}
        Start data traffic in egate  ue_id=${ue_id}  direction=dl  mbps=${mbps}  trf_id=${trf_id}  pdu=${pdu}  qfi=${qfi}
    END

Start uplink Data Traffic in Egate on multiple Traffic IDs and PDUs
    [Documentation]    Starting uplink Data Traffic in Egate on multiple traffic IDs and PDUs
    [Arguments]    ${ue_id}  ${trf_id_range_min}  ${trf_id_range_max}  ${pdu_count}  ${qfi}
    FOR    ${trf_id}    IN RANGE    ${trf_id_range_min}  ${trf_id_range_max}
        Start uplink Data Traffic in Egate on multiple PDUs  ue_id=${ue_id}  trf_id=${trf_id}  pdu_count=${pdu_count}  qfi=${qfi}
    END

Start uplink Data Traffic in Egate on multiple PDUs
    [Documentation]    Starting uplink Data Traffic in Egate on multiple PDUs
    [Arguments]    ${ue_id}  ${trf_id}  ${pdu_count}  ${qfi}  ${mbps}
    FOR    ${pdu}    IN RANGE    1  ${${pdu_count}+1}
        Start data traffic in egate  ue_id=${ue_id}  direction=ul  mbps=${mbps}  trf_id=${trf_id}  pdu=${pdu}  qfi=${qfi}
    END

Modifying default QOS flow
    [Documentation]    Modifying the default qosflow for the UE
    [Arguments]   ${ue_id}  ${qos_flow}
    Send Egate Command and verify output    qosflow_modify ue=${ue_id} qos_flow=${qos_flow} default=on

Adding and deleting QOS Flows to PDU Session
    [Documentation]    Add additional and deleting previous qos flows to pdu session of a UE.
    [Arguments]    ${ue_id}  ${pdu}  ${qosflows_to_add}  ${qosflows_to_del}  ${by}
    Send Egate Command and verify output
    ...   cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=${qosflows_to_add} qosflows_to_del=${qosflows_to_del} by=${by}
    ...   pass_regexp=Added QosFlow with QFI
    Log   ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=${qosflows_to_add} qosflows_to_del=${qosflows_to_del} by=${by}
    ...   console=${P_console}

Deleting QOS Flow in PDU Session
    [Documentation]    Deleting previous qos flow in pdu session of a UE.
    [Arguments]    ${ue_id}  ${pdu}  ${qosflows_to_del}  ${by}  ${pass_regexp}=${None}
    Send Egate Command and verify output
    ...   cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_del=${qosflows_to_del} by=${by}   pass_regexp=${pass_regexp}
    Log   ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_del=${qosflows_to_del} by=${by}
    ...   console=${P_console}

Collect and Verify PM Counters
    [Arguments]   ${test_instance}  ${pm_collector_alias}=gnb_pm_counters  ${dual_delta_commissioning}=${EMPTY}  ${scenario}=3CA  ${CA_Change}=No
    ...   ${pcell}=1  ${scell_1}=2  ${scell_2}=3  ${ul_ca_scenario}=No
    ${pm_files}=   Collect PM Counters  collector_alias=${pm_collector_alias}${dual_delta_commissioning}
    IF    '${ul_ca_scenario}' == 'No'
    ...        PM Counter Verification  PM_dir=${pm_files}  pcell_list=${${test_instance}_PM_PCELL${dual_delta_commissioning}}
    ...        scell_list=${${test_instance}_PM_SCELL${dual_delta_commissioning}}  scenario=${scenario}  CA_Change=${CA_Change}  pcell=${pcell}
    ...        scell_1=${scell_1}  scell_2=${scell_2}
    ...        ELSE
    ...        PM Counter Verification for ULCA   PM_dir=${pm_files}   pcell_list=${${test_instance}_PM_PCELL${dual_delta_commissioning}}
    ...        scell_1_list=${${test_instance}_PM_SCELL_1_${dual_delta_commissioning}}
    ...        scell_2_list=${${test_instance}_PM_SCELL_2_${dual_delta_commissioning}}
    ...        pcell=${pcell}  scell_1=${scell_1}  scell_2=${scell_2}

Collect PM counters
    [Arguments]    ${collector_alias}
    ${log_dir}=    testline.Get Testcase Log Directory
    pmcounters.Wait until the current Measurement Period stops
    ${pm_files}=    pmcounters.Collect PM Counter    target_dir=${log_dir}    collector_alias=${collector_alias}
    RETURN  ${pm_files}

PM Counter Verification for ULCA
    [Documentation]    Verifying PM counters values
    [Arguments]    ${PM_dir}  ${pcell_list}   ${pcell}  ${scell_1}  ${scell_2}  ${scell_1_list}=${EMPTY}   ${scell_2_list}=${EMPTY}
    Verify PM Counter Reference Table  reference_table=${pcell_list}   pm_dir=${PM_dir}   distname_suffix=${pcell}
    Verify PM Counter Reference Table  reference_table=${scell_1_list}   pm_dir=${PM_dir}   distname_suffix=${scell_1}
    Verify PM Counter Reference Table  reference_table=${scell_2_list}   pm_dir=${PM_dir}   distname_suffix=${scell_2}

PM Counter Verification
    [Documentation]    Verifying PM counters values
    [Arguments]    ${PM_dir}  ${pcell_list}   ${pcell}  ${scell_1}  ${scell_2}  ${scenario}  ${CA_Change}  ${scell_list}=${EMPTY}
    Verify PM Counter Reference Table  reference_table=${pcell_list}   pm_dir=${PM_dir}   distname_suffix=${pcell}
    IF  '${CA_Change}' == 'No'
    ...   Verify PM Counter Reference Table  reference_table=${scell_list}   pm_dir=${PM_dir}   distname_suffix=${scell_1}
    IF  '${scenario}' == '3CA' or '${CA_Change}' == 'Yes'
    ...   Verify PM Counter Reference Table  reference_table=${scell_list}   pm_dir=${PM_dir}   distname_suffix=${scell_2}

Check RD counter value equal
    [Documentation]   adapted from Check PM counter value equal:Author: Giangiacomo Guglielmini
    ...        checks that the value of a counter in the last reporting period is equal to a given value
    ...
    ...        :param expected_value is the value compared to counter value
    ...        :param pm_files_location is the path to PM files
    ...        :param pi_id is the PM counter ID e.g. M55112C03001
    ...        :param moc is the class including the counter e.g. NRCELL-1
    ...               it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1
    [Arguments]    ${expected_value}   ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_value}=   Get RD counter value   ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_value}=   convert to integer    ${pi_value}
    ${expected_value}=   convert to integer    ${expected_value}
    should be equal  ${pi_value}   ${expected_value}     PM Counter ${pi_id} expected to be == ${expected_value} but is ${pi_value}

Get RD counter value
    [Documentation]   adapted from Get PM counter value:Author: Giangiacomo Guglielmini
    ...        get the value of a counter in the last reporting period
    ...
    ...        :param pm_files_location is the path to PM files
    ...        :param pi_id is the PM counter ID e.g. M55112C03001
    ...        :param moc is the class including the counter e.g. NRCELL-1
    ...               it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1
    [Arguments]    ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_list}=  Create List
    ...  ${pi_id}
    ${PM_report_dict_list}=  check_pm.get_pi_value
    ...  pi_list=${pi_list}
    ...  pi_dir=${pm_files_location}
    ...  pi_file_pattern=RD.BTS*
    ${last_report}    Get From List   ${PM_report_dict_list}     -1
    ${pi_dict}   Get Dictionary Values   ${last_report}
    ${first_pi}    Get From List   ${pi_dict}     0
    ${cell_dict_list}   Get Dictionary Values   ${first_pi}
    ${cell_dict}   Get From List   ${cell_dict_list}     0
    ${moc_list}   get dictionary keys   ${cell_dict}
    ${full_moc}    Set Variable     empty
    FOR  ${key}  IN   @{moc_list}
       ${key_is_moc}  Run Keyword And Return Status    Should Contain  ${key}   ${moc}
       ${full_moc}  Set Variable If   ${key_is_moc}   ${key}    ${full_moc}
    END
    ${pi_value}     Get From Dictionary      ${cell_dict}    ${full_moc}
    Log    ${pi_id} value: ${pi_value}   console=${P_console}
    RETURN    ${pi_value}

Verify SCELL Addition for UE in RRC Reconfiguration
    [Documentation]    To verify if Scell Additions are configured by gNB for the UE during RRC Reconfiguration.
    [Arguments]    ${sCellOperationalMode}   ${DL_CA_cell_configuration}=3CC DL CA with Cell-2 and Cell-3 as SCells
    ...   ${DLUL_CA_cell_configuration}=3CC DL CA with Cell-2 and Cell-3 as SCells and 2CC UL with Cell-3 as SCell
    IF   '${sCellOperationalMode}' == 'dlonly'
    ...   Verify DL SCELL Addition  DL_CA_cell_configuration=${DL_CA_cell_configuration}
    ...   ELSE IF   '${sCellOperationalMode}' == 'dlAndUl'
    ...   Verify DL and UL SCELL Addition  DLUL_CA_cell_configuration=${DLUL_CA_cell_configuration}

Verify DL SCELL Addition
    [Documentation]    List @{MSG_SEQ_DL} must be defined in subfeature suite variable.
    [Arguments]    ${DL_CA_cell_configuration}
    send egate command and verify output    set_log flush
    Verify sequence in Egate file  ${EGATE_CONSOLE_LOG}  @{MSG_SEQ_DL}
    Log    The gNB configures the UE with ${DL_CA_cell_configuration}.
    ...        console=${P_console}

Verify DL and UL SCELL Addition
    [Documentation]    List @{MSG_SEQ_DLUL} must be defined in subfeature suite variable.
    [Arguments]    ${DLUL_CA_cell_configuration}
    send egate command and verify output    set_log flush
    Verify sequence in Egate file  ${EGATE_CONSOLE_LOG}  @{MSG_SEQ_DLUL}
    Log    The gNB configures the UE with ${DLUL_CA_cell_configuration}.
    ...        console=${P_console}

Verify Reconfiguration of UE in RRC message
    [Documentation]    To verify if SCells are released by gNB for the UE via RRC Reconfiguration message. List @{RECONFIG_MSG_SEQ} must be defined
    ...   in subfeature suite variable.
    [Arguments]    ${reconfig_message}
    send egate command and verify output    set_log flush
    Verify sequence in Egate file  ${EGATE_CONSOLE_LOG}  @{RECONFIG_MSG_SEQ}
    Log    ${reconfig_message} by the gNB for the UE via RRC Reconfiguration message.
    ...        console=${P_console}
    Sleep   1s  reason=wait for gNB to send next RRCReconfiguration message

Verify the gNB configures the UE with NR-DC-SN Cell as PSCell
    [Documentation]    To verify whether the gNB configures NR-DC-SN FR2 Cell as secondary cell group at the UE. List @{NRDC_MSG_SEQ} must be
    ...   defined in subfeature suite variable.
    [Arguments]    ${ue_id}
    send egate command and verify output    set_log flush
    Verify sequence in Egate file  ${EGATE_CONSOLE_LOG}  @{NRDC_MSG_SEQ}
    Log    FR2 Cell (Cell-5) is configured at UE-${ue_id} as psCell by the gNB for the UE via RRC Reconfiguration message.
    ...        console=${P_console}

Verify the gNB Releases both SCells at the UE via same Reconfiguration Message when gNB receives A4 MR
    [Documentation]    This keyword can be used to verify the Scell release procedure - whether both SCels are released in same RRC reconfiguration
    ...                message
    [Arguments]    ${ue_id}
    ${pattern_both_scells}=     Set Variable  sCellToReleaseList\\s\\n\\s+{\\n\\s+1,\\n\\s+2\\n\\s+}\\n
    send egate command and verify output    set_log flush
    Sleep   1s   Reason=waiting before fetching the log file, else the log file may miss last part of the messages
    ${log_content}=    Get File    ${EGATE_CONSOLE_LOG}
    ${both_scells_release}=     Run Keyword And Return Status   Should Match Regexp     ${log_content}      ${pattern_both_scells}
    IF    ${both_scells_release}
    ...    Log    The gNB released both SCells at UE-${ue_id} in same RRC Reconfiguration message.
    ...    ELSE   Fail    SCell release failed!

Verify the gNB Released NR-DC Secondary Cell Group at the UE
    [Documentation]    This keyword can be used to verify whether the gNB configures NR-DC-SN cell as PSCell at the UE.
    [Arguments]    ${ue_id}
    ${pattern_pscell}=     Set Variable  nonCriticalExtension\\s\\n\\s+{\\n\\s+mrdc-SecondaryCellGroupConfig\\srelease\\s:\\sNULL\\n\\s+}\\n
    send egate command and verify output    set_log flush
    Sleep   1s   Reason=waiting before fetching the log file, else the log file may miss last part of the messages
    ${log_content}=    Get File    ${EGATE_CONSOLE_LOG}
    ${pscell_configure}=     Run Keyword And Return Status   Should Match Regexp     ${log_content}      ${pattern_pscell}
    IF    ${pscell_configure}
    ...    Log    The gNB has setup NR-DC at the UE-${ue_id} by configuring NR-DC-SN cell as PSCell.
    ...    ELSE   Fail    NR-DC setup at the UE failed!

Check Avg Data Rate from Egate Console
    [Documentation]
    [Arguments]    ${ue_id}    ${cell_group_1}    ${cell_group_2}    ${scell}=0    ${cell}=FR1 PCell
    ${cell_group_list}=     Create List   ${cell_group_1}   ${cell_group_2}
    FOR  ${cell_group}   IN   @{cell_group_list}
        ${scell}    Set Variable If    '${cell_group}'=='SCG'    1            0
        ${cell}     Set Variable If    '${cell_group}'=='SCG'    FR2 PSCell     FR1 PCell
        ${dl_output}=       Display NR UE Statistics    id=${ue_id}    type=pdsch    scell=${scell}    cell_group=${cell_group}
        ${dl_data_rate}=    Convert to Number    ${dl_output}
        IF  ${dl_data_rate} > ${pdsch_data_rate}
        ...  Log     Downlink data traffic over the ${cell} (${cell_group}) is successful --> ${dl_data_rate} Mbps
        ...  ELSE   Fail    Downlink data traffic over the ${cell} (${cell_group}) is too low (${dl_data_rate} Mbps), please check.
        ${ul_output}=       Display NR UE Statistics    id=${ue_id}    type=pusch    scell=${scell}    cell_group=${cell_group}
        ${ul_data_rate}=    Convert to Number    ${ul_output}
        IF  ${ul_data_rate} > ${pusch_data_rate}
        ...  Log     Uplink data traffic over the ${cell} (${cell_group}) is successful --> ${ul_data_rate} Mbps
        ...  ELSE   Fail    Uplink data traffic over the ${cell} (${cell_group}) is too low (${ul_data_rate} Mbps), please check.
    END

Display NR UE Statistics
    [Documentation]
    [Arguments]    ${id}   ${type}   ${scell}   ${cell_group}   ${format}=short   ${size_unit}=bytes
    ${str}=    Catenate     ue_stats_nr id=${id} type=${type} scell=${scell} format=${format} size_unit=${size_unit} cell_group=${cell_group}
    ${output}=          Send Egate Command and verify output    cmd=${str}  pass_regexp=Average
    Sleep    1s         reason=wait command to be executed
    Log         Stats for UE-${id} is displayed    console=${P_console}
    @{data_rate}=    String.Get Regexp Matches    ${output}    (\\d+\\.\\d)(?=\\sMbps|$)
    @{tput_rate}=    String.Get Regexp Matches    ${output}    (\\d+)
    ${avg_data_rate}=    IF         len(${data_rate}) > 0    Evaluate         ${data_rate}[-1]
    ...                  ELSE IF    len(${tput_rate}) > 0    Evaluate         ${tput_rate}[-1]
    ...                  ELSE       Fail    Did not find Average throughput in UE NR Statistics.
    RETURN    ${avg_data_rate}

Verify Measurement Events are Configured at the UE
    [Documentation]
    [Arguments]     ${meas_event_1}  ${meas_event_2}
    Wait Until Current Measurement ID Gets Deconfigured and then Reconfigured   event_type=${meas_event_2}  ue_id=1  action=Verify_A4_Meas_Event
    IF        '${meas_event_1}'=='A1'
          Verify Measurement ID is configured  event_type=${meas_event_1}  ue_id=1  carrier_freq=${NRCELL-1.arfcnSsbPbch}
    ELSE IF   '${meas_event_1}'=='A2'
          Verify Measurement ID is configured  event_type=${meas_event_1}  ue_id=1  carrier_freq=${NRCELL-2.arfcnSsbPbch}
          Verify Measurement ID is configured  event_type=${meas_event_1}  ue_id=1  carrier_freq=${NRCELL-3.arfcnSsbPbch}
    END

Stop Data transfer for all Traffic IDs
    [Documentation]
    [Arguments]     ${ue_id}   ${trf_id_start}   ${trf_id_end}   ${direction}=dl   ${pdu}=1
    FOR  ${trf_id}   IN RANGE  ${trf_id_start}  ${${trf_id_end}+1}
        Stop data traffic in egate  ue_id=${ue_id}  direction=${direction}  trf_id=${trf_id}  pdu=${pdu}
    END

Wait Until Current Measurement ID Gets Deconfigured and then Reconfigured
    [Documentation]     This is to wait until current measurement  ID gets deconfigured, and then reconfigure A4 Measurement event again, else when
    ...                 UE sends MR for A4 event there is a chance for keyword to fail since gNB is keep on doing activation and deactivation of A4
    [Arguments]  ${event_type}=A4  ${ue_id}=1  ${carrier_freq}=${NRCELL-5.arfcnSsbPbch}  ${action}=Verify_A4_Meas_Event
    FOR  ${index}   IN RANGE  1  15
        ${status}  Run Keyword And Return Status   Verify Measurement ID is configured  ${event_type}  ${ue_id}  carrier_freq=${carrier_freq}
        IF  ${status} == False
            Sleep   3s
            Log   Now A4 Measurement is deconfigured at UE, exiting after ${index} iteration
            BREAK
        END
        Sleep   1s
    END
    IF  '${action}' == 'Verify_A4_Meas_Event'
        Verify Measurement ID is configured  event_type=A4  ue_id=${ue_id}  carrier_freq=${NRCELL-5.arfcnSsbPbch}
    ELSE IF   '${action}' == 'Send_A4_Meas_Report'
        Send NR Measurement Report  event=A4  meas_values=phycell_id=55 nrsrp_nr=20 nrsrq_nr=20  ue_id=${ue_id}
        ...      carrier_freq=${NRCELL-5.arfcnSsbPbch}
    END

Verify the UE is not Configured with Carrier Aggregation
    [Documentation]    Ths keyword can be used to verify that gNB does not configure the UE with downlink/uplink carrier aggregation
    [Arguments]     ${ue_id}
    send egate command and verify output    set_log flush
    ${ca_status}  Run Keyword And Return Status   Verify sequence in Egate file  ${EGATE_CONSOLE_LOG}  sCellToAddModList
    IF  ${ca_status} == False
    ...         Log    UE-${ue_id} is not configured with Carrier Aggregation.
    ...         ELSE   Fail   The gNB configured the UE with carrier aggreation, it is an abnormal behaviour.

Verify Carrier Aggregation is still activated at the UE
    [Documentation]    Ths keyword can be used to verify that gNB does not trigger SCell release procedure at the UE and UE is still in DL/UL CA.
    [Arguments]     ${ue_id}    ${ca_scenario}=3CC DL CA
    send egate command and verify output    set_log flush
    ${ca_status}  Run Keyword And Return Status   Verify sequence in Egate file  ${EGATE_CONSOLE_LOG}  sCellToReleaseList
    IF  ${ca_status} == False
    ...         Log    ${ca_scenario} is still activated at the UE-${ue_id}    console=${P_console}
    ...         ELSE   Fail   The gNB triggers SCell Releasse to the UE, it is an abnormal behaviour.

Save Current Section of Egate Console Log and Restart Egate log
    [Documentation]    Save current section of egate console log and restart egate log. To check for specific pattern which reoccurs in egate log.
    [Arguments]  ${name}
    Save EGATE Log  name=${name}
    Restart EGATE Log
    ${section_no} =    Evaluate    ${SECTION} + 1
    Set Suite Variable    ${SECTION}    ${section_no}

Register and Establish PDU Session and then Verify SCell Addition For UEs
    [Documentation]    Register and establish PDU Session for both UEs for user scenario AC_B4
    [Arguments]    ${ue_1}  ${ue_2}
    ${ue_list}=   Create List   ${ue_1}   ${ue_2}
    FOR  ${ue}   IN   @{ue_list}
        IF  '${ue}' == '1'   UE Register  ue_id=${ue}
        ...   ELSE IF   '${ue}' == '4'   UE Register  ue_id=${ue}  nwslice=2
        Modifying default QOS flow   ue_id=${ue}  qos_flow=2
        Set traffic type  ue_id=${ue}  pdu_id=1  trf_type=internal
        Add Additional QOS Flows to Activate  id=1  additional_qosflows=3
        IF  '${ue}' == '1'   UE PDU Session Setup  ue_id=${ue}  pdu=1  gw=${ue}
        ...   ELSE IF   '${ue}' == '4'   UE PDU Session Setup  ue_id=${ue}  pdu=1  nwslice=2  gw=${ue}
        Verify SCELL Addition for UE in RRC Reconfiguration  sCellOperationalMode=dlonly
        Save Current Section of Egate Console Log and Restart Egate log  name=section_${SECTION}
        Smf Param Reset
    END

Establish Second PDU Session for both UEs
    [Documentation]    Establish second PDU Session for both UEs for user scenario AC_B4
    [Arguments]    ${ue_1}  ${ue_2}
    ${ue_list}=   Create List   ${ue_1}   ${ue_2}
    FOR  ${ue}   IN   @{ue_list}
        ${gw}       Evaluate           ${ue} + 1
        Set traffic type  ue_id=${ue}  pdu_id=2  trf_type=internal
        IF        '${ue}' == '1'
           Modifying default QOS flow   ue_id=${ue}  qos_flow=5
           UE PDU Session Setup  ue_id=${ue}  pdu=2  gw=${gw}  pass_regexp=Pdu Session.*successfully
        ELSE IF   '${ue}' == '4'
           Modifying default QOS flow   ue_id=${ue}  qos_flow=1
           UE PDU Session Setup  ue_id=${ue}  pdu=2  nwslice=2  gw=${gw}  pass_regexp=Pdu Session.*successfully
        END
    END

Stop Data transfer for all Traffic IDs and Deregister UE
    [Documentation]    Can be used to stop data transfer for all traffic IDs of PDU session 1 & 2 for multiple UEs and then Deregister all UEs
    [Arguments]    ${trf_start}=1   ${trf_end}=3   ${dir}=dl   &{kwargs}
    ${ue_id_list}=  Get Dictionary Values  dictionary=&{kwargs}
    ${ue_list}=   Evaluate   [int(x) for x in ${ue_id_list}]
    FOR  ${ue}   IN   @{ue_list}
        Stop Data transfer for all Traffic IDs  ue_id=${ue}  trf_id_start=${trf_start}  trf_id_end=${trf_end}  pdu=1  direction=${dir}
        Stop Data transfer for all Traffic IDs  ue_id=${ue}  trf_id_start=${trf_start}  trf_id_end=${trf_end}  pdu=2  direction=${dir}
        UE Deregister  ue_id=${ue}  ue_deregister_type=switch_off
    END

Prepare WTS Config
    [Documentation]    Reconfigure basic_setup.cfg file to change the ARFCN and GSCN of Cell_2 to match the frequency of Cell_1 only for the TI C_B8
    [Arguments]
    ${WTS_CFG_FILE}=             Set Variable   ${tl.core.dir_path}/basic_setup_9059-C_B8.cfg
    wts_conf.load_wts_cfg        ${tl.core.dir_path}/${tl.core.cfg_filename}
    wts_conf.modify              command=set_cell id=2     modification=nr_arfcn=519000:519000 gscn=6468
    wts_conf.save_wts_cfg        ${WTS_CFG_FILE}
    ${tc_conf_dir}               testline.Get Testcase Log Directory
    Copy File                    ${WTS_CFG_FILE}  ${tc_conf_dir}

Update iphy file for C_B8
    [Documentation]    Reconfigure iphy.xml file to change the GSCN of Cell_2 to match the GSCN of Cell_1 only for the test instance C_B8
    [Arguments]
    ${tc_conf_dir}       testline.Get Testcase Log Directory
    ${ap_alias}          Connect to Airphone Common Unit
    ssh.execute          cp /ffs/run/simmode/new_iphy.xml /ffs/run/simmode/new_iphy_orig.xml    connection=${ap_alias}
    ssh.Download File    /rom/simmode/new_iphy.xml        ${tc_conf_dir}/new_iphy.xml           connection=${ap_alias}
    ${contents}          Get File          ${tc_conf_dir}/new_iphy.xml
    ${all_parts}         Split String      ${contents}     </vcell>
    ${update}            Replace String Using Regexp    ${all_parts}[1]      GSCN>.*<\/GSCN>   GSCN>6468<\/GSCN>
    ${new contents}      catenate         SEPARATOR=</vcell>   ${all_parts}[0]  ${update}  ${all_parts}[2]  ${all_parts}[3]  ${all_parts}[4]
    Create File          ${tc_conf_dir}/new_iphy_C_B8.xml    ${new contents}
    ssh.Upload File      ${tc_conf_dir}/new_iphy_C_B8.xml    /rom/simmode/new_iphy.xml   connection=${ap_alias}

Reload original iphy file
    [Documentation]    Reconfigure iphy.xml file to revert the GSCN of Cell_2 which was changed for the test instance C_B8
    [Arguments]
    ${ap_alias}          Connect to Airphone Common Unit
    ssh.execute          cp /ffs/run/simmode/new_iphy_orig.xml /ffs/run/simmode/new_iphy.xml    connection=${ap_alias}

Register and Establish PDU Session
    [Documentation]    Common keyword for user scenario C_B7 and C_B8: Register and establish PDU Session for UEs.
    [Arguments]    ${ue_1}  ${ue_2}
    ${ue_list}=   Create List   ${ue_1}   ${ue_2}
    FOR  ${ue}   IN   @{ue_list}
        IF  '${ue}' == '6' or '${ue}' == '8'   UE Register   ue_id=${ue}
        ...   ELSE IF   '${ue}' == '7' or '${ue}' == '9'   UE Register   ue_id=${ue}  nwslice=2
        Modifying default QOS flow   ue_id=${ue}  qos_flow=2
        Set traffic type  ue_id=${ue}  pdu_id=1  trf_type=internal
        Add Additional QOS Flows to Activate  id=1  additional_qosflows=3
        IF  '${ue}' == '6' or '${ue}' == '8'   UE PDU Session Setup  ue_id=${ue}  pdu=1  gw=${ue}
        ...   ELSE IF   '${ue}' == '7' or '${ue}' == '9'   UE PDU Session Setup  ue_id=${ue}  pdu=1  nwslice=2  gw=${ue}
        Smf Param Reset
    END

Verify A1 Measurement Event Configured and Confirm that UEs are Configured with CA after Sending A1 MR
    [Documentation]    Check whether UE is configured with A1 measurement, then send A1 MR and verify SCell and A1 measurement event configured
    [Arguments]    ${ue_1}  ${ue_2}
    ${ue_list}=   Create List   ${ue_1}   ${ue_2}
    FOR  ${ue}   IN   @{ue_list}
        Verify Measurement ID is configured  event_type=A1  ue_id=${ue}  carrier_freq=${NRCELL-3.arfcnSsbPbch}
        Send NR Measurement Report   event=A1  meas_values=srsrp_nr=55 srsrq_nr=55  ue_id=${ue}  carrier_freq=${NRCELL-3.arfcnSsbPbch}
        Verify Measurement ID is absent   event=A1  ue_id=${ue}  carrier_freq=${NRCELL-4.arfcnSsbPbch}
        Set Suite Variable    @{MSG_SEQ_DL}   @{MSG_SEQ_DL_1}
        Verify SCELL Addition for UE in RRC Reconfiguration  sCellOperationalMode=dlonly    DL_CA_cell_configuration=2CC DL CA with Cell-4 as SCell
        Start downlink Data Traffic in Egate on multiple Traffic IDs and QFIs   ue_id=${ue}  trf_id_range_min=1  trf_id_range_max=5  end_qfi=2
        Sleep   10s  reason=wait for AP to start DL data for all trf_ids
        Save Current Section of Egate Console Log and Restart Egate log  name=section_${SECTION}
    END

Verify A1 Measurement Event Configured and Confirm that SCell Change was Successul at UEs after Sending A1 MR
    [Documentation]    Send A1 MR and verify whether SCell change is successful
    [Arguments]    ${ue_1}  ${ue_2}
    ${ue_list}=   Create List   ${ue_1}   ${ue_2}
    FOR  ${ue}   IN   @{ue_list}
        Verify Measurement ID is configured  event_type=A1  ue_id=${ue}  carrier_freq=${NRCELL-3.arfcnSsbPbch}
        Send NR Measurement Report   event=A1  meas_values=srsrp_nr=65 srsrq_nr=65  ue_id=${ue}  carrier_freq=${NRCELL-3.arfcnSsbPbch}
        Verify Measurement ID is absent   event=A1  ue_id=${ue}  carrier_freq=${NRCELL-2.arfcnSsbPbch}
        Set Suite Variable    @{MSG_SEQ_DL}   @{MSG_SEQ_DL_2}
        Verify SCELL Addition for UE in RRC Reconfiguration  sCellOperationalMode=dlonly    DL_CA_cell_configuration=2CC DL CA with Cell-2 as SCell
        Save Current Section of Egate Console Log and Restart Egate log  name=section_${SECTION}
    END

Stop Data transfer and Deregister UE
    [Documentation]    Common keyword for user scenario C_B7 and C_B8 to stop data transfer and deregister UEs
    [Arguments]    ${ue_1}  ${ue_2}
    FOR  ${trf_id}   IN RANGE  1  6
        Stop data traffic in egate  ue_id=${ue_1}  direction=dl  trf_id=${trf_id}
        Stop data traffic in egate  ue_id=${ue_2}  direction=dl  trf_id=${trf_id}
    END
    UE Deregister  ue_id=${ue_1}  ue_deregister_type=switch_off
    UE Deregister  ue_id=${ue_2}  ue_deregister_type=switch_off

Verify A1 Measurement Event Configured and Confirm that UEs are Configured with CA & A6 Meas Event after Sending A1 MR
    [Documentation]    Check whether UE is configured with A1 measurement event, then send MR and verify SCell and A6 measurement event configured
    [Arguments]    ${ue_1}  ${ue_2}
    ${ue_list}=   Create List   ${ue_1}   ${ue_2}
    FOR  ${ue}   IN   @{ue_list}
        Verify Measurement ID is configured  event_type=A1  ue_id=${ue}  carrier_freq=${NRCELL-4.arfcnSsbPbch}
        Send NR Measurement Report   event=A1  meas_values=srsrp_nr=55 srsrq_nr=55  ue_id=${ue}  carrier_freq=${NRCELL-4.arfcnSsbPbch}
        Verify Measurement ID is absent   event=A1  ue_id=${ue}  carrier_freq=${NRCELL-4.arfcnSsbPbch}
        Set Suite Variable    @{MSG_SEQ_DL}   @{MSG_SEQ_DL_3}
        Verify SCELL Addition for UE in RRC Reconfiguration  sCellOperationalMode=dlonly    DL_CA_cell_configuration=2CC DL CA with Cell-1 as SCell
        Verify Measurement ID is configured  event_type=A6  ue_id=${ue}  carrier_freq=${NRCELL-1.arfcnSsbPbch}
        Start downlink Data Traffic in Egate on multiple Traffic IDs and QFIs   ue_id=${ue}  trf_id_range_min=1  trf_id_range_max=5  end_qfi=2
        Sleep   10s  reason=wait for AP to start DL data for all trf_ids
        Save Current Section of Egate Console Log and Restart Egate log  name=section_${SECTION}
    END

Send A6 MR and Verify that SCell Swap was Successful at UEs
    [Documentation]    Send A6 MR and verify whether SCell Swap is successful and UE is configured with A6 again
    [Arguments]    ${ue_1}  ${ue_2}  ${scell_index}  ${phycell_id}  ${Cell_Id}
    ${ue_list}=   Create List   ${ue_1}   ${ue_2}
    FOR  ${ue}   IN   @{ue_list}
        Send NR Measurement Report   event=A6  ue_id=${ue}   carrier_freq=${NRCELL-1.arfcnSsbPbch}
        ...   meas_values=scell=${scell_index} scell_rsrp=55 scell_rsrq=55 phycell_id=${phycell_id} nrsrp_nr=57 nrsrq_nr=57
        IF  '${Cell_Id}' == 'Cell-2'   Set Suite Variable    @{MSG_SEQ_DL}   @{MSG_SEQ_DL_2}
        ...   ELSE   Set Suite Variable    @{MSG_SEQ_DL}   @{MSG_SEQ_DL_4}
        Verify SCELL Addition for UE in RRC Reconfiguration  sCellOperationalMode=dlonly  DL_CA_cell_configuration=2CC DL CA with ${Cell_Id} as SCell
        Verify Measurement ID is configured  event_type=A6  ue_id=${ue}  carrier_freq=${NRCELL-1.arfcnSsbPbch}
        Save Current Section of Egate Console Log and Restart Egate log  name=section_${SECTION}
    END

Combine and Delete Egate Log Files
    [Documentation]    Since the egate console logs are being saved and restarted multiple times for verification purpose (multiple UEs), at the end
    ...                of the test, these log files will be combined and then moved all splitted log files to a new folder.
    [Arguments]
	${log_dir}    Get Testcase Log Directory
    ${log_files}=    List Files In Directory    ${log_dir}   *.log
    ${log_files_length}=    Get Length    ${log_files}
    IF    ${log_files_length} > 2    Combine and Delete Egate Section and Part Logs    section_part_log_files=${log_files}

Combine and Delete Egate Section and Part Logs
    [Documentation]    This keyword sorts all splitted log files from the log directory and combine those to a new file. Then the splitted logs will
    ...                be moved to a new folder "Egate_Section_and_Part_Logs_Obsolete", that can be used later to check if necessary.
    [Arguments]    ${section_part_log_files}
	${log_dir}    Get Testcase Log Directory
    ${combined_log_file}=    Set Variable    ${log_dir}/egate_console.log
    ${section_logs}=    Create List
    ${part_logs}=    Create List
    ${os_module}=   Evaluate   __import__('os', fromlist=['path', 'remove', 'basename', 'splitext'])
    BuiltIn.Log   Imported Modules are ${os_module}
    FOR    ${log_file}    IN    @{section_part_log_files}
        ${basename}=    Set variable    ${log_file.split("/")[-1]}
        ${basename_no_extension}=   Set variable    ${basename.split(".log")[0]}
        IF    '${basename_no_extension}'.startswith('egate_console_section')
        ...    Append To List    ${section_logs}    ${log_file}
        ...    ELSE IF    '${basename_no_extension}'.startswith('egate_console_part')
        ...    Append To List    ${part_logs}    ${log_file}
    END
    ${latest_part_log}=    Get Latest Part Log    ${part_logs}
    Append To List    ${section_logs}    ${latest_part_log}
    ${combined_egate_logs}=    Combine Files    @{section_logs}
    Append To File    ${combined_log_file}    ${combined_egate_logs}
    FOR    ${log_file}    IN    @{section_logs}
        IF  '${log_file}'.startswith('egate_console_section')
        ...    Move File    ${log_dir}/${log_file}    ${log_dir}/Egate_Section_and_Part_Logs_Obsolete/
    END
    FOR    ${log_file}    IN    @{part_logs}
        Move File    ${log_dir}/${log_file}    ${log_dir}/Egate_Section_and_Part_Logs_Obsolete/
    END

Combine Files
    [Documentation]    This keyword combines the egate console log files which were splitted during the test execution.
    [Arguments]    @{files_to_combine}
    ${log_dir}    testline.Get Testcase Log Directory
    ${combined_logs}=    Create List
    FOR    ${log_file}    IN    @{files_to_combine}
        ${file_content}=    Get File    ${log_dir}/${log_file}
        Append To List    ${combined_logs}    ${file_content}
    END
    ${combined_section_logs}=   Evaluate    ''.join(${combined_logs})
    RETURN    ${combined_section_logs}

Get Latest Part Log
    [Documentation]    This keyword returns the last element of part logs
    [Arguments]    @{part_logs}
    ${latest_part_log_name}=    Get From List    @{part_logs}    -1
    RETURN    ${latest_part_log_name}

Send A1 Measurement Report and Initiate Data Transfer and then Verify SCells are Configured for UEs
    [Documentation]    UE sends A1 MR for SCell addition and verify whether UE is configured with 3CC DL CA. Then, save and restart egate log as
    ...                egate log is used to verify 3CC DL CA configuration for multiple UEs.
    [Arguments]    &{kwargs}
    ${ue_id_list}=  Get Dictionary Values  dictionary=&{kwargs}
    ${ue_list}=   Evaluate   [int(x) for x in ${ue_id_list}]
    FOR  ${ue}   IN   @{ue_list}
        Send NR Measurement Report  event=A1  ue_id=${ue}  meas_values=srsrp_nr=55 srsrq_nr=55  carrier_freq=${NRCELL-1.nrarfcn_gscn}
        ...  pass_regexp=${None}
        Start downlink Data Traffic in Egate on multiple Traffic IDs and QFIs   ue_id=${ue}  trf_id_range_min=1  trf_id_range_max=3
        Sleep   2s  reason=waiting for UE to get configured with CA by gNB
        Verify SCELL Addition for UE in RRC Reconfiguration  sCellOperationalMode=dlonly
        Save Current Section of Egate Console Log and Restart Egate log  name=section_${SECTION}
    END

Trigger Overheating Assistance and Verify Only UEs with CA Eligible DRB are Configured with A1 after SCells are Released
    [Documentation]    UE triggers overheating assistance procedure, then gNB suspends/deactivates the data at all SCells for duration configured for
    ...                sCellInactivityReleaseTimer(10s), then gNB releases all SCells in seperate RRC recinfiguration messages.
    [Arguments]    &{kwargs}
    @{mod_qos_list_for_ue4}    Create List     3
    ${ue_id_list}=  Get Dictionary Values  dictionary=&{kwargs}
    ${ue_list}=   Evaluate   [int(x) for x in ${ue_id_list}]
    FOR  ${ue}   IN   @{ue_list}
        Verify whether the gNB Deactivated both SCells at the UE when UE Triggers Overheating Assistance  ue_id=${ue}
        Verify the gNB Triggers SCell Release Procedure at the UE  ue_id=${ue}
        Send NR Measurement Report  event=A1  ue_id=${ue}  meas_values=srsrp_nr=55 srsrq_nr=55  carrier_freq=${NRCELL-1.nrarfcn_gscn}
        ...    pass_regexp=${None}
        Verify the UE is not Configured with Carrier Aggregation  ue_id=${ue}
        IF    '${ue}' == '1'
            Adding and deleting QOS Flows to PDU Session   ue_id=${ue}  pdu=1  qosflows_to_add=5  qosflows_to_del=2  by=amf
            Start downlink Data Traffic in Egate on multiple Traffic IDs and QFIs   ue_id=${ue}  trf_id_range_min=1  trf_id_range_max=3
            ...    start_qfi=2  end_qfi=2  pdu=1
            Verify Measurement ID Is Configured  event_type=A1  ue_id=${ue}  carrier_freq=${NRCELL-1.nrarfcn_gscn}
            Verify the UE is not Configured with Carrier Aggregation  ue_id=${ue}
        ELSE IF    '${ue}' == '2'
            Adding and deleting QOS Flows to PDU Session   ue_id=${ue}  pdu=1  qosflows_to_add=3  qosflows_to_del=1  by=amf
            Start downlink Data Traffic in Egate on multiple Traffic IDs and QFIs   ue_id=${ue}  trf_id_range_min=1  trf_id_range_max=3
            ...    start_qfi=2  end_qfi=2  pdu=1
            Verify Measurement ID is absent  event_type=A1   ue_id=${ue}   carrier_freq=${NRCELL-1.nrarfcn_gscn}
            Verify the UE is not Configured with Carrier Aggregation  ue_id=${ue}
        ELSE IF    '${ue}' == '4'
            UE PDU Session Modify   ue_id=${ue}  pdu=1  qos_flow_list=@{mod_qos_list_for_ue4}  by=amf
            Start downlink Data Traffic in Egate on multiple Traffic IDs and QFIs   ue_id=${ue}  trf_id_range_min=1  trf_id_range_max=3
            ...    start_qfi=2  end_qfi=2  pdu=1
            Verify Measurement ID is absent  event_type=A1   ue_id=${ue}   carrier_freq=${NRCELL-1.nrarfcn_gscn}
            Verify the UE is not Configured with Carrier Aggregation  ue_id=${ue}
        END
        Sleep   60s  reason=waiting for caBackoffTimerUeOh(60s) to get expired
        IF               '${ue}' == '1'    Verify SCELL Addition for UE in RRC Reconfiguration  sCellOperationalMode=dlonly
        ...    ELSE IF   '${ue}' == '2'    Verify the UE is not Configured with Carrier Aggregation  ue_id=${ue}
        ...    ELSE IF   '${ue}' == '4'    Verify the UE is not Configured with Carrier Aggregation  ue_id=${ue}
        Verify Measurement ID is absent  event_type=A1   ue_id=${ue}   carrier_freq=${NRCELL-1.nrarfcn_gscn}
        Save Current Section of Egate Console Log and Restart Egate log  name=section_${SECTION}
    END

Verify whether the gNB Deactivated both SCells at the UE when UE Triggers Overheating Assistance
    [Documentation]    This keyword can be used to verify whether the SCells are deactivated at the UE when UE triggers overheating assistance
    [Arguments]    ${ue_id}
    Send Egate Command and verify output  cmd=ue_assistance_send_nr ue_id=${ue_id} forOverheating=yes reducedCCsDL=0
    Sleep   2s  reason=waiting for gNB to deactivate SCells due to overheating at UE
    send egate command and verify output    set_log flush
    Sleep   1s  reason=waiting before fetching the log file, else missing some contents in the log file
    ${log_content}=    Get File    ${EGATE_CONSOLE_LOG}
    ${scell_deact_pattern}=    Set Variable   .*SCellIndex \\d deactivated successfully at airphone.*
    ${count}=    Get Regexp Matches    ${log_content}    ${scell_deact_pattern}
    ${scell_deact_count}=    Get Length    ${count}
    IF   ${scell_deact_count} == 2    Log    The gNB deactivated both SCells at the UE, However SCells are not released.
    ...    ELSE   Fail   The gNB did not deactivate the SCells!
    Save Current Section of Egate Console Log and Restart Egate log  name=section_${SECTION}

Verify the gNB Triggers SCell Release Procedure at the UE
    [Documentation]    This keyword can be used to verify the Scell release procedure, also can be verified whether SCells are released in same RRC
    ...                reconfiguration message or seperate RRC Reconfiguration messages
    [Arguments]    ${ue_id}
    Sleep   10s  reason=waiting for gNB to release SCells when sCellInactivityReleaseTimer(10s) expired
    send egate command and verify output    set_log flush
    Sleep   1s  reason=waiting before fetching the log file, else missing some contents in the log file
    ${log_content}=    Get File    ${EGATE_CONSOLE_LOG}
    ${pattern_both_scells}=     Set Variable  sCellToReleaseList\\s\\n\\s+{\\n\\s+1,\\n\\s+2\\n\\s+}\\n
    ${pattern_scell1}=          Set Variable  sCellToReleaseList\\s\\n\\s+{\\n\\s+1\\n\\s+}\\n
    ${pattern_scell2}=          Set Variable  sCellToReleaseList\\s\\n\\s+{\\n\\s+2\\n\\s+}\\n
    ${scell_rel_oh_pattern}=    Set Variable  .*overheatingAssistanceConfig release : NULL
    ${scell1_release}=          Run Keyword And Return Status   Should Match Regexp     ${log_content}      ${pattern_scell1}
    ${scell2_release}=          Run Keyword And Return Status   Should Match Regexp     ${log_content}      ${pattern_scell2}
    ${scell_release_oh}=        Run Keyword And Return Status   Should Match Regexp     ${log_content}      ${scell_rel_oh_pattern}
    ${both_scells_release}=     Run Keyword And Return Status   Should Match Regexp     ${log_content}      ${pattern_both_scells}
    IF   ${scell_release_oh} and ${scell1_release} and ${scell2_release}
    ...    Log    The gNB Released both SCells due to overheating at UE in seperate RRC Reconfiguration messages.
    ...    ELSE IF   ${scell1_release} and ${scell2_release}
    ...    Fail   The gNB Released both SCells at UE in seperate RRC Reconfig messages, however IE: overheatingAssistanceConfig release is missing!
    ...    ELSE IF   ${scell1_release} or ${scell2_release}
    ...    Fail   The gNB released only one SCell
    ...    ELSE IF   ${both_scells_release}
    ...    Fail   The gNB Released both SCells in the same RRC Reconfiguration message!
    ...    ELSE   Fail   The gNB does not trigger SCell release procedure!
    Verify Measurement ID Is Configured  event_type=A1  ue_id=${ue_id}  carrier_freq=${NRCELL-1.nrarfcn_gscn}

Stop Data transfer for all Traffic IDs for Multiple UEs and Deregister UEs
    [Arguments]    ${trf_id_start}   ${trf_id_end}   &{kwargs}
    ${ue_list}=  Get Dictionary Values  dictionary=&{kwargs}
    ${ue_id_list}=   Evaluate   [int(x) for x in ${ue_list}]
    FOR  ${ue}   IN   @{ue_id_list}
        Stop Data transfer for all Traffic IDs  ue_id=${ue}  trf_id_start=${trf_id_start}  trf_id_end=${trf_id_end}
        UE Deregister  ue_id=${ue}  ue_deregister_type=switch_off
    END

Verify A1 Measurement is Absent and A2 Measurement is Configured
    [Arguments]    ${ue_id}
    Verify Measurement ID is absent  event_type=A1  ue_id=${ue_id}  carrier_freq=${NRCELL-1.nrarfcn_gscn}
    Verify Measurement ID Is Configured  event_type=A2  ue_id=${ue_id}  carrier_freq=${NRCELL-2.nrarfcn_gscn}
    Verify Measurement ID Is Configured  event_type=A2  ue_id=${ue_id}  carrier_freq=${NRCELL-3.nrarfcn_gscn}

Verify A2 Measurements are Deactivated and UE is Not Configured with A1 Measurement
    [Arguments]    ${ue_id}
    Verify Measurement ID is absent  event_type=A1  ue_id=${ue_id}  carrier_freq=${NRCELL-1.nrarfcn_gscn}
    Verify Measurement ID is absent  event_type=A2  ue_id=${ue_id}  carrier_freq=${NRCELL-2.nrarfcn_gscn}
    Verify Measurement ID is absent  event_type=A2  ue_id=${ue_id}  carrier_freq=${NRCELL-3.nrarfcn_gscn}

Send A2 Measurement Report and Verify whether gNB Release SCell at the UE
    [Arguments]    ${ue_id}
    FOR  ${scell_id}   IN RANGE  1  3
        IF    ${scell_id} == 1
        ...    Send NR Measurement Report  event=A2  ue_id=${ue_id}  meas_values=scell=${scell_id} scell_rsrp=30 scell_rsrq=45
        ...    carrier_freq=${NRCELL-2.nrarfcn_gscn}
        ...    ELSE     Send NR Measurement Report  event=A2  ue_id=${ue_id}  meas_values=scell=${scell_id} scell_rsrp=30 scell_rsrq=45
        ...    carrier_freq=${NRCELL-3.nrarfcn_gscn}
        Verify the gNB Triggers SCell Release Procedure at the UE for BA  ue_id=${ue_id}  scell=${scell_id}
        IF    ${scell_id} == 1
        ...    Verify Measurement ID is absent  event_type=A1  ue_id=${ue_id}  carrier_freq=${NRCELL-1.nrarfcn_gscn}
    END

Verify the gNB Triggers SCell Release Procedure at the UE for BA
    [Documentation]    This keyword can be used to verify the Scell release procedure. Only that SCell for UE sends A2 MR will be released.
    [Arguments]    ${ue_id}   ${scell}
    ${pattern_scell1}=          Set Variable  sCellToReleaseList\\s\\n\\s+{\\n\\s+1\\n\\s+}\\n
    ${pattern_scell2}=          Set Variable  sCellToReleaseList\\s\\n\\s+{\\n\\s+2\\n\\s+}\\n
    send egate command and verify output    set_log flush
    Sleep   1s   Reason=waiting before fetching the log file, else the log file may miss last part of the messages
    ${log_content}=    Get File    ${EGATE_CONSOLE_LOG}
    ${scell1_release}=          Run Keyword And Return Status   Should Match Regexp     ${log_content}      ${pattern_scell1}
    ${scell2_release}=          Run Keyword And Return Status   Should Match Regexp     ${log_content}      ${pattern_scell2}
    IF    ${scell} == 1 and ${scell1_release} and not ${scell2_release}
    ...    Log      The gNB Released SCell-${scell} at UE-${ue_id} via RRC Reconfiguration message.
    ...    ELSE IF    ${scell} == 2 and not ${scell1_release} and ${scell2_release}
    ...    Log      The gNB Released SCell-${scell} at UE-${ue_id} via RRC Reconfiguration message.
    ...    ELSE     Fail   The gNB does not trigger SCell-${scell} release procedure at UE-${ue_id}!
    Save Current Section of Egate Console Log and Restart Egate log    name=section_${SECTION}

Verify the gNB Triggers both SCells Release Procedure at the UE via same Reconfiguration Message
    [Documentation]    This keyword can be used to verify the Scell release procedure - whether SCels are released in same RRC reconfiguration
    ...                message in which DRB is establshed
    [Arguments]    ${ue_id}
    ${pattern_both_scells}=     Set Variable  sCellToReleaseList\\s\\n\\s+{\\n\\s+1,\\n\\s+2\\n\\s+}\\n
    send egate command and verify output    set_log flush
    Sleep   1s   Reason=waiting before fetching the log file, else the log file may miss last part of the messages
    ${log_content}=    Get File    ${EGATE_CONSOLE_LOG}
    ${both_scells_release}=     Run Keyword And Return Status   Should Match Regexp     ${log_content}      ${pattern_both_scells}
    ${reconfig_msg}=     Get Regexp Matches     ${log_content}      rrcReconfigurationComplete
    ${reconfig_msg_count}=     Get Length     ${reconfig_msg}
    IF    ${both_scells_release} and ${reconfig_msg_count} == 2
    ...    Log    The gNB released both SCells at UE-${ue_id} in same RRC Reconfiguration message.
    ...    ELSE   Fail    SCell release failed!

Stop data traffic in egate on multiple PDUs
    [Documentation]    This keyword is to stop the data traffic in egate on PDU session 1 and PDU session 2
    [Arguments]     ${ue_id}   ${trf_min}=1   ${pdu_1_trf_max}=4   ${pdu_2_trf_max}=2
    Stop Data transfer for all Traffic IDs  ue_id=${ue_id}  trf_id_start=${trf_min}  trf_id_end=${pdu_1_trf_max}  direction=dl  pdu=1
    Stop Data transfer for all Traffic IDs  ue_id=${ue_id}  trf_id_start=${trf_min}  trf_id_end=${pdu_2_trf_max}  direction=dl  pdu=2

Register and Establish PDU Session for Multiple UEs
    [Arguments]      ${ue_1}   ${ue_2}   ${ue_3}   ${ue_4}
    Amf Param Update  send_ics_registration=on
    UE Register  ue_id=${ue_1}  pass_regexp=Initial Context Setup Successful
    Modifying default QOS flow  ue_id=${ue_1}  qos_flow=2
    Set traffic type  ue_id=${ue_1}  pdu_id=1  trf_type=internal
    Amf Param Update  send_ics_registration=off
    UE Register  ue_id=${ue_2}
    Modifying default QOS flow  ue_id=${ue_2}  qos_flow=3
    Set traffic type  ue_id=${ue_2}  pdu_id=1  trf_type=internal
    UE PDU Session Setup  ue_id=${ue_2}  pdu=1  gw=2
    UE Register  ue_id=${ue_3}
    Modifying default QOS flow  ue_id=${ue_3}  qos_flow=1
    Set traffic type  ue_id=${ue_3}  pdu_id=1  trf_type=internal
    Add Additional QOS Flows to Activate  id=1  additional_qosflows=4
    UE PDU Session Setup  ue_id=${ue_3}  pdu=1  gw=3
    Smf Param Reset
    UE Register  ue_id=${ue_4}  nwslice=2
    Modifying default QOS flow  ue_id=${ue_4}  qos_flow=2
    Set traffic type  ue_id=${ue_4}  pdu_id=1  trf_type=internal
    UE PDU Session Setup  ue_id=${ue_4}  pdu=1  gw=4  nwslice=2
    Modifying default QOS flow  ue_id=${ue_4}  qos_flow=3
    Set traffic type  ue_id=${ue_4}  pdu_id=2  trf_type=internal
    UE PDU Session Setup  ue_id=${ue_4}  pdu=2  gw=5  nwslice=2  pass_regexp=Pdu Session Resource Setup.*successfully
    Save Current Section of Egate Console Log and Restart Egate log  name=section_${SECTION}

Verify UEs are not Configured with A1 Measurement Event
    [Arguments]    ${ue_id_range_min}  ${ue_id_range_max}
    FOR    ${ue_id}    IN RANGE    ${ue_id_range_min}    ${${ue_id_range_max}+1}
        Verify Measurement ID is absent  event_type=A1  ue_id=${ue_id}  carrier_freq=${NRCELL-1.nrarfcn_gscn}
    END

Trigger PDU Session Setup Modify or Release and Verify UEs are now Configured with A1 Event
    [Arguments]    ${ue_id_range_min}  ${ue_id_range_max}
    @{mod_qos_list_for_ue2}    Create List     5
    FOR   ${ue}   IN RANGE   ${ue_id_range_min}   ${${ue_id_range_max}+1}
        IF  ${ue} == 1
        ...   UE PDU Session Setup  ue_id=${ue}  pdu=1  gw=1  pass_regexp=Pdu Session Resource Setup.*successfully
        ...   ELSE IF  ${ue} == 2
        ...     UE PDU Session Modify  ue_id=${ue}  qos_flow_list=@{mod_qos_list_for_ue2}
        ...   ELSE IF  ${ue} == 3
        ...     Deleting QOS Flow in PDU Session  ue_id=${ue}  pdu=1  qosflows_to_del=4  by=amf  pass_regexp=Pdu Session Resource Modify.*successfully
        ...   ELSE IF  ${ue} == 4
        ...     UE PDU Session Release  ue_id=${ue}  pdu=2
        send egate command and verify output    set_log flush
        Sleep  1s  Reason=waiting before fetching the log file, else the log file may miss last part of the messages
        ${log_content}=    Get File    ${EGATE_CONSOLE_LOG}
        ${reconfig_msg}=     Get Regexp Matches     ${log_content}      rrcReconfigurationComplete
        ${reconfig_msg_count}=     Get Length     ${reconfig_msg}
        IF    ${reconfig_msg_count} == 2
        ...   Verify Measurement ID Is Configured  event_type=A1  ue_id=${ue}  carrier_freq=${NRCELL-1.nrarfcn_gscn}
        ...   ELSE  Fail   The gNB does not configure the UE with A1 in the same RRCReconfiguration message for the PDU session setup/modify/release
        IF   ${ue} != 4    Save Current Section of Egate Console Log and Restart Egate log  name=section_${SECTION}
    END

Send A1 Measurement Report and Verify UEs are Configured with Downlink CA and then Start DL data trffic
    [Documentation]    This keyword verifies whether the UEs are configured with 3CC DL CA when UE sends A1 MR for SCell addition, and then check A1
    ...                Event is deconfigured by the gNB
    [Arguments]    ${ue_id_range_min}  ${ue_id_range_max}
    FOR   ${ue_id}   IN RANGE   ${ue_id_range_min}   ${${ue_id_range_max}+1}
        Send NR Measurement Report  event=A1  ue_id=${ue_id}  meas_values=srsrp_nr=55 srsrq_nr=55  carrier_freq=${NRCELL-1.nrarfcn_gscn}
        Verify SCELL Addition for UE in RRC Reconfiguration  sCellOperationalMode=dlonly
        Verify Measurement ID is absent  event_type=A1  ue_id=${ue_id}  carrier_freq=${NRCELL-1.nrarfcn_gscn}
        IF   ${ue_id} == 2
        ...  Start downlink Data Traffic in Egate on multiple Traffic IDs and QFIs  ue_id=${ue_id}  trf_id_range_min=1  trf_id_range_max=3  end_qfi=2
        ...  ELSE
        ...  Start downlink Data Traffic in Egate on multiple Traffic IDs and QFIs  ue_id=${ue_id}  trf_id_range_min=1  trf_id_range_max=3
        Save Current Section of Egate Console Log and Restart Egate log  name=section_${SECTION}
    END

Register and Establish PDU Session for Multiple UEs and Verify UEs are Configured with A1 Measurement Event
    [Arguments]    ${ue_1}   ${ue_2}   ${ue_3}   ${ue_4}
    ${ue_list}=     Create List   ${ue_1}  ${ue_2}  ${ue_3}  ${ue_4}
    ${ue_id_list}=   Evaluate   [int(x) for x in ${ue_list}]
    FOR   ${ue}   IN   @{ue_id_list}
        IF   ${ue} == 4   UE Register  ue_id=${ue}  nwslice=2
        ...   ELSE   UE Register  ue_id=${ue}

        IF    ${ue} == 1 or ${ue} == 4    Modifying default QOS flow  ue_id=${ue}  qos_flow=2
        ...   ELSE IF   ${ue} == 2        Modifying default QOS flow  ue_id=${ue}  qos_flow=1
        ...   ELSE IF   ${ue} == 3        Modifying default QOS flow  ue_id=${ue}  qos_flow=5

        Set traffic type  ue_id=${ue}  pdu_id=1  trf_type=internal
        IF   ${ue} == 4
        ...   UE PDU Session Setup  ue_id=${ue}  pdu=1  gw=${ue}  nwslice=2
        ...   ELSE   UE PDU Session Setup  ue_id=${ue}  pdu=1  gw=${ue}

        Verify Measurement ID Is Configured  event_type=A1  ue_id=${ue}  carrier_freq=${NRCELL-1.nrarfcn_gscn}
    END
    Save Current Section of Egate Console Log and Restart Egate log  name=section_${SECTION}

Trigger PDU Session Setup Modify or Release and Verify UEs are now Deconfigured with A1 Event
    [Arguments]    ${ue_id_range_min}  ${ue_id_range_max}
    FOR   ${ue}   IN RANGE   ${ue_id_range_min}   ${${ue_id_range_max}+1}
        IF  ${ue} == 1
            Modifying default QOS flow   ue_id=${ue}  qos_flow=4
            Set traffic type   ue_id=${ue}  pdu_id=2  trf_type=internal
            UE PDU Session Setup   ue_id=${ue}  pdu=2  gw=5  pass_regexp=Pdu Session Resource Setup.*successfully
        ELSE IF  ${ue} == 2
            Adding and deleting QOS Flows to PDU Session   ue_id=${ue}  pdu=1  qosflows_to_add=3  qosflows_to_del=1  by=amf
        ELSE IF  ${ue} == 3
            UE PDU Session Release   ue_id=${ue}  pdu=1
        ELSE IF  ${ue} == 4
            Apply Config for BA_B3   test_instance=BA_B3
            Modifying default QOS flow   ue_id=${ue}  qos_flow=3
            Set traffic type   ue_id=${ue}  pdu_id=2  trf_type=internal
            UE PDU Session Setup   ue_id=${ue}  pdu=2  gw=6  nwslice=2
            ...  pass_regexp=PDU Session Resource Setup with PDU Session ID 2 was unsuccessful due to RAN radio resources not available
        END
        send egate command and verify output   set_log flush
        Sleep   1s  Reason=waiting before fetching the log file, else the log file may miss last part of the messages
        ${log_content}=    Get File    ${EGATE_CONSOLE_LOG}
        ${reconfig_msg}=     Get Regexp Matches     ${log_content}      rrcReconfigurationComplete
        ${reconfig_msg_count}=     Get Length     ${reconfig_msg}
        IF   ${reconfig_msg_count} != 2 and ${ue} != 4
        ...   Fail   More than expected RRC Reconfiguration message received from the gNB during pdu session setp/modify or rlease
        IF   ${ue} == 4
             Verify Measurement ID Is Configured  event_type=A1  ue_id=${ue}  carrier_freq=${NRCELL-1.nrarfcn_gscn}
        ELSE IF   ${ue} == 3
             Verify Measurement ID Is absent   event_type=A1  ue_id=${ue}  carrier_freq=${NRCELL-1.nrarfcn_gscn}
             UE Deregister  ue_id=3  ue_deregister_type=switch_off
        ELSE IF   ${ue} == 1 or ${ue} == 2
             Verify Measurement ID Is absent   event_type=A1  ue_id=${ue}  carrier_freq=${NRCELL-1.nrarfcn_gscn}
        END
        Save Current Section of Egate Console Log and Restart Egate log   name=section_${SECTION}
    END

Trigger Downlink Data traffic in Egate for multiple Traffic IDs and QFIs to Exceed PCell Tput
    [Arguments]  ${ue_id}  ${trf_id_range_min}  ${trf_id_range_max}  ${start_qfi}=1  ${end_qfi}=3  ${pdu}=1  ${dir}=dl  ${mbps}=100  ${seconds}=60
    FOR    ${trf_id}    IN RANGE    ${trf_id_range_min}   ${${trf_id_range_max}+1}
        Initiate Downlink Data Traffic for Single Traffic ID and QFI  ue_id=${ue_id}  trf_id=${trf_id}  start_qfi=${start_qfi}  end_qfi=${end_qfi}
        ...  pdu=${pdu}  dir=${dir}  mbps=${mbps}  seconds=${seconds}
    END
    Start data traffic in egate  ue_id=${ue_id}  direction=${dir}  mbps=${mbps}  trf_id=1  pdu=${pdu}  qfi=${end_qfi}  seconds=${seconds}
    Sleep  60s  Reason=waiting to stop data traffic after running for ${seconds} seconds

Initiate Downlink Data Traffic for Single Traffic ID and QFI
    [Arguments]    ${ue_id}  ${trf_id}  ${start_qfi}  ${end_qfi}  ${pdu}  ${dir}  ${mbps}  ${seconds}
    FOR    ${qfi}    IN RANGE    ${start_qfi}   ${end_qfi}
        Start data traffic in egate  ue_id=${ue_id}  direction=${dir}  mbps=${mbps}  trf_id=${trf_id}  pdu=${pdu}  qfi=${qfi}  seconds=${seconds}
    END

Trigger Data traffic in Egate for multiple Traffic IDs and QFIs to Exceed PCell Tput
    [Arguments]  ${ue_id}
    FOR    ${trf_id}    IN RANGE    1   4
          Start data traffic in egate  ue_id=${ue_id}  direction=dl  mbps=175  trf_id=${trf_id}  pdu=1  qfi=1  seconds=60
    END
    FOR    ${trf_id}    IN RANGE    1   3
          Start data traffic in egate  ue_id=${ue_id}  direction=dl  mbps=100  trf_id=${trf_id}  pdu=1  qfi=2  seconds=60
          Start data traffic in egate  ue_id=${ue_id}  direction=dl  mbps=50  trf_id=${trf_id}  pdu=1  qfi=3  seconds=60
    END
    Sleep  60s  Reason=waiting to stop data traffic after running for 60 seconds

Verify whether the gNB Releases Radio Link Failure Timer and Constant when VoNR is Released
    [Arguments]    ${ue_id}
    send egate command and verify output   set_log flush
    Sleep   1s   reason=waiting before fetching the log file, else missing some contents in the log file
    ${log_content}=   Get File   ${EGATE_CONSOLE_LOG}
    ${rlf_timer_constant}=   Set Variable   spCellConfig\\s\\n\\s+{\\n\\s+rlf-TimersAndConstants\\srelease\\s:\\sNULL\\n\\s+}\\n
    ${rlf_timer_constant_release}=   Run Keyword And Return Status   Should Match Regexp   ${log_content}   ${rlf_timer_constant}
    IF   ${rlf_timer_constant_release}
    ...    Log   The gNB Released RLF Timer and Constant IE at UE-${ue_id} when VoNR call is released.
    ...    ELSE   Fail   Did not see RLF Timer and Constant Release IE in RRC Reconfiguration when VoNR Call is released!

Trigger Downlink and Uplink Data traffic in Egate for multiple Traffic IDs and QFIs to Exceed PCell Tput
    [Arguments]  ${ue_id}
    FOR    ${trf_id}    IN RANGE    1   3
          Start data traffic in egate  ue_id=${ue_id}  direction=dl  mbps=175  trf_id=${trf_id}  pdu=1  qfi=1
          Start data traffic in egate  ue_id=${ue_id}  direction=ul  mbps=50  trf_id=${trf_id}  pdu=1  qfi=1
          Start data traffic in egate  ue_id=${ue_id}  direction=dl  kbps=100  trf_id=${trf_id}  pdu=1  qfi=2
          IF   ${ue_id} == 2 or ${ue_id} == 5
          ...   Start data traffic in egate  ue_id=${ue_id}  direction=ul  mbps=5  trf_id=${trf_id}  pdu=1  qfi=2
          ...   ELSE   Start data traffic in egate  ue_id=${ue_id}  direction=ul  mbps=10  trf_id=${trf_id}  pdu=1  qfi=2
    END
    Sleep  30s  Reason=waiting for AP to trigger data traffic for all qos flows.

Trigger DL Data traffic in Egate for multiple Traffic IDs and QFIs to Exceed PCell Tput
    [Arguments]  ${ue_id}
    FOR    ${trf_id}    IN RANGE    1   3
          Start data traffic in egate  ue_id=${ue_id}  direction=dl  mbps=175  trf_id=${trf_id}  pdu=1  qfi=1
          Start data traffic in egate  ue_id=${ue_id}  direction=dl  mbps=10  trf_id=${trf_id}  pdu=1  qfi=2
    END
    Sleep  10s  Reason=waiting for AP to trigger data traffic for all qos flows.

Verify the gNB deconfigures A1 A2 A4 Measuremenet Events at the UE
    [Arguments]  ${ue_id}
    Verify Measurement ID is absent  event_type=A4  ue_id=${ue_id}  carrier_freq=${NRCELL-5.arfcnSsbPbch}
    Verify Measurement ID is absent  event_type=A1  ue_id=${ue_id}  carrier_freq=${NRCELL-1.arfcnSsbPbch}
    Verify Measurement ID is absent  event_type=A2  ue_id=${ue_id}  carrier_freq=${NRCELL-2.arfcnSsbPbch}
    Verify Measurement ID is absent  event_type=A2  ue_id=${ue_id}  carrier_freq=${NRCELL-3.arfcnSsbPbch}
