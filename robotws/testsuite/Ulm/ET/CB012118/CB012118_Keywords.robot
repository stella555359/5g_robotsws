*** Settings ***

Documentation
...    author: Ulm SQD 65
...    Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...    Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
...    Description: Keywords for CB012118

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library     taf.config.wts        WITH NAME    wts_conf
Resource    ../resources/SQD65/sqd65_keywords.robot
Resource    ../resources/SQD65/sqd65_commissioning.robot
Resource    CB012118_Commissioning.robot
Resource    ./CB012118_PM_RD.robot

*** Variables ***

${EGATE_CONSOLE_LOG}         /opt/iphy/latest/egate_console.log

${WTS_ALIAS}                 ap_egate           # from wts_ue.robot

#This UE Capability supports band_2 and band_3
${UE_CAPAB}                  SEPARATOR=
...                          ue_nr_capabilities=E1A00000074E5A031E000383A000F04983200021E12006201A0130080C0700EA8D851AC10143404B2CA261A007AD8202020E
...                          1DE38720C38002064F1F57001FF001C007FC00162001DB800040000000380004000000001546C4CD6080A1A025965130D003D6C10101070EF1C3906
...                          1C00103278FAB800FF800E003FE000B1000EDC000200000001C0002000000000AA3626EB04050D012CB28986801EB608080838778E1C830E0008193
...                          C7D5C007FC007001FF0005880076E000100000000E0001000000000551B13B582028680965944C3400F5B0404041C3BC70E418700040C9E3EAA0000
...                          0A000002C4003B70000800000007000080000000000420E268000000010134540003804044F617001800140E0A00E06013003800341F00000000000
...                          0072A68000800004B2CA801A55542C007000B000000040080118B130001020304050607080B101112131921252627284A0

#This UE Capability supports band_2 and band_3
${UE_CAPAB_2}                SEPARATOR=
...                          ue_nr_capabilities=E1A00000074E5A031E000384A0003C1260C80008785800C40340260300C0700EA8D851AC10143404B2CA261E003D6C101010
...                          70EF1C39061C00103278FAB800FF800E003FE000C100076E000100000000E0001000000000551B133582028680965944C3C007AD8202020E1DE3872
...                          0C38002064F1F57001FF001C007FC00182000EDC000200000001C0002000000000AA2626EB04050D012CB28987800F5B0404041C3BC70E418700040
...                          C9E3EB800FF800E003FE000C100076E000100000000E0001000000000551B13B582028680965944C3C007AD8202020E1DE38720C38002064F1F5500
...                          000500000182000EDC000200000001C00020000000000108389A00000000404D1900003804044FE2280006C003000281C1401C0C026007000683E00
...                          00000000000E54D000100000965950034AAA868007000B000000040080118B130001020304050607080B101112131921252627284A

#This UE Capability supports band_2 only
${UE_CAPAB_EC1_ALT1}         SEPARATOR=
...                          ue_nr_capabilities=E1A00000074E5A031E00038520001E09306400043C2C006201A0130180603807546C28D6080A1A0259651311000F5B040404
...                          1C3BC70E418700040C9E3EAE003FE003800FF80038400076E000100000000E0001000000000551B133582028680965944C44003D6C10101070EF1C3
...                          9061C00103278FAB800FF800E003FE000E10001DB800040000000380004000000001546C4DD6080A1A0259651311000F5B0404041C3BC70E4187000
...                          40C9E3EAE003FE003800FF80038400076E000100000000E0001000000000551B13B582028680965944C44003D6C10101070EF1C39061C00103278FA
...                          A800002800000E10001DB8000400000003800040000000000210713400000000809A3A00001C020227B118001800140E0A00E06013003800341F000
...                          000000000072A68000800004B2CA801A55543C001C002C000000100200462C4800040C1014181C202C4044484C648494989CA128

#UE supports power class 3 for freq band 78
${UE_CAPA_PC3_NR78_B_B1_2}   SEPARATOR=
...                          ue_nr_capabilities=E1A00000074E5A031E00038520001E09306400043C2C006201A0130180603807546C28D6080A1A0259651311000F5B040404
...                          1C3BC70E418700040C9E3EAE003FE003800FF80038400076E000100000000E0001000000000551B133582028680965944C44003D6C10101070EF1C3
...                          9061C00103278FAB800FF800E003FE000E10001DB800040000000380004000000001546C4DD6080A1A0259651311000F5B0404041C3BC70E4187000
...                          40C9E3ECE003FE003800FF80038400076E000100000000E0001000000000551B13B582028680965944C44003D6C10101070EF1C39061C00103278FA
...                          A800002800000E10001DB8000400000003800040000000000210713400000000809A3A00001C020227B118001800140E0A00E06013003800341F000
...                          000000000072A68000800004B2CA801A55543C001C002C000000100200462C4C0004080C1014181C202C4044484C648494989CA128

*** Keywords ***

Prepare TL for CB012118
    Sqd65 Common Setup
    Fetch Nidd Version From SCF File
    Prepare WTS Config
    Commissioning for A
    Bring Airphone TL to on Air status   cfg_file=basic_setup_CB012118_new.cfg

Prepare TL for CB012118-B and -G
    Sqd65 Common Setup
    Fetch Nidd Version From SCF File
    Prepare WTS Config for Sub-feature B
    Commissioning for Sub-feature B
    Bring Airphone TL to on Air status   cfg_file=basic_setup_CB012118_new.cfg

Perform Preconditions of Test Scenario
    Create Testcase Log Directory
    IF    '${PREV_TEST_STATUS}'=='FAIL'
    ...               Perform Preconditions of Test Scenario in Case of Previous TC failed
    ${SCF_TC_Setup}=               Get SCF from gNB
    Start Logging
    Set Suite Variable  ${SCF_TC_Setup}
    Smf Param Reset
    IF    'CB012118-A' in '${TEST NAME}'    AMF Param to Default

Perform Postconditions of Test Case
    run_keyword_and_warn_on_failure    Stop logging
    Collect AP Sos Report and Snapshots
    Revert Delta Commissioning

Perform Preconditions of Test Scenario in Case of Previous TC failed
    Teardown Egate Connection for Airphone
    Teardown Edaemon Connection for Airphone
    Bring Airphone TL to on Air status   cfg_file=basic_setup_CB012118_new.cfg

Revert Delta Commissioning
    ${log_dir}=                Get Testcase Log Directory
    ${curr_scf}=               Get SCF from gNB  target_dir=${log_dir}
    ${revert_file}=            Set Variable  ${log_dir}/revert.json
    scf.calculate_delta_scf    ${SCF_TC_Setup}  ${curr_scf}  ${revert_file}
    Config gNB with delta scf  ${revert_file}

Prepare WTS Config
    wts_conf.load_wts_cfg    file_path=${P_ORIG_WTS_CONFIG}

    #SA UE Configuration Part
    #UE1 - Cell-1
    wts_conf.modify              ue_param id=1     modification=${UE_CAPAB}
    #UE2 - Cell-1
    wts_conf.modify              ue_param id=2     modification=${UE_CAPAB_2}

    #UE3 - Cell-1
    wts_conf.modify              ue_param id=3     modification=${UE_CAPAB_EC1_ALT1}

    wts_conf.insert              amf_param id=1 voice_fallback=on  after    amf_param id=1 ims_voice_3gpp=on

    wts_conf.save_wts_cfg    file_path=${tl.core.dir_path}/basic_setup_CB012118_new.cfg

    ${ts_conf_dir}=              Get Test Suite Config Directory
    Copy File                    ${tl.core.dir_path}/basic_setup_CB012118_new.cfg  ${ts_conf_dir}

Prepare WTS Config for Sub-feature B
    [Documentation]    Modifiy power class capability of ue-2 to pc3 for NR78, amf parameters for voice FB and emergency FB, and add enb cells.
    ${enb_cell_1_param}=    Set Variable        proxy=$DAEMON_IP:12219|$DAEMON_IP:8889 earfcn=2000:20000 tdd_cell=off mandatory_for_activation=off
    ${enb_cell_2_param}=    Set Variable        proxy=$DAEMON_IP:12220|$DAEMON_IP:8889 earfcn=3000:21000 tdd_cell=off mandatory_for_activation=off
    ${enb_cell_3_param}=    Set Variable        proxy=$DAEMON_IP:12221|$DAEMON_IP:8889 earfcn=1000:19000 tdd_cell=off mandatory_for_activation=off
    ${enb_cell_4_param}=    Set Variable        proxy=$DAEMON_IP:12222|$DAEMON_IP:8889 earfcn=300:18300 tdd_cell=off mandatory_for_activation=off
    ${enb_cell_5_param}=    Set Variable        proxy=$DAEMON_IP:12223|$DAEMON_IP:8889 earfcn=900:18900 tdd_cell=off mandatory_for_activation=off
    wts_conf.load_wts_cfg   file_path=${P_ORIG_WTS_CONFIG}
    wts_conf.delete         set_cell id=1 enb=1
    wts_conf.insert         set_cell id=1 enb=1 eci=0x1234601 pci=3:2 tac=222 ${enb_cell_1_param}  after  enb_param id=1
    wts_conf.insert         set_cell id=2 enb=1 eci=0x1234602 pci=4:0 tac=222 ${enb_cell_2_param}  after  set_cell id=1 enb=1
    wts_conf.insert         set_cell id=3 enb=1 eci=0x1234603 pci=4:1 tac=222 ${enb_cell_3_param}  after  set_cell id=2 enb=1
    wts_conf.insert         set_cell id=4 enb=1 eci=0x1234604 pci=4:2 tac=222 ${enb_cell_4_param}  after  set_cell id=3 enb=1
    wts_conf.insert         set_cell id=5 enb=1 eci=0x1234605 pci=5:0 tac=222 ${enb_cell_5_param}  after  set_cell id=4 enb=1
    wts_conf.insert         set_lmf id=1 daemon=$SERVER_IP:$DAEMON_PORT nfId=abcdef01234567gh      after  set_amf id=1
    wts_conf.modify         ue_param id=2     modification=${UE_CAPA_PC3_NR78_B_B1_2}
    wts_conf.modify         amf_param id=1 ims_voice_3gpp=on full_nas_auth=on     modification=voice_fallback=on emergency_service_fallback=on
    wts_conf.insert         nwslice_set id=2 qos_flows=1,2,3 qos_rules=1,2 snssai=0x01:0xD143A6 default=off ue=all amf=1  after  nwslice_set id=1
    wts_conf.insert         nwslice_set id=3 qos_flows=1,2,3 qos_rules=1,2 snssai=0x01:0xD143A7 default=off ue=all amf=1  after  nwslice_set id=2
    wts_conf.save_wts_cfg   file_path=${tl.core.dir_path}/basic_setup_CB012118_new.cfg
    ${ts_conf_dir}=         Get Test Suite Config Directory
    Copy File               ${tl.core.dir_path}/basic_setup_CB012118_new.cfg  ${ts_conf_dir}

Amf Param Update
    [Documentation]    Updating amf parameters to send  ICS always in response to registration request or updating to default values
    [Arguments]       ${send_ics_registration}
    IF  "${send_ics_registration}" == "on"
    ...    Send Egate Command and verify output
    ...        cmd=amf_param id=1 empty_pdu_session_list=on send_ics_registration=on

AMF Param to Default
    Send Egate Command and verify output
    ...   cmd=amf_param id=1 reset
    Send Egate Command and verify output
    ...   cmd=amf_param id=1 full_nas_auth=on ims_voice_3gpp=on voice_fallback=on
    Send Egate Command and verify output
    ...   cmd=amf_ue_ics_param id=1 reset
    Send Egate Command and verify output
    ...   ue_nr_rrc_setup_param id=1 establishment_cause=mo-Signalling

Modifying default QOS flow
    [Documentation]    Modifying the default qosflow for the UE
    [Arguments]   ${ue_id}  ${qos_flow}
    Send Egate Command and verify output    qosflow_modify ue=${ue_id} qos_flow=${qos_flow} default=on

Collect and Verify PM Counters
    [Arguments]   ${test_instance}  ${pm_collector_alias}=gnb_pm_counters
    ...   ${dual_delta_commissioning}=${EMPTY}
    ${pm_files}=   Collect PM Counters  collector_alias=${pm_collector_alias}${dual_delta_commissioning}
    Verify PM Counter Reference table    reference_table=${${test_instance}_PM${dual_delta_commissioning}}  pm_dir=${pm_files}
    ...   distname_suffix=NRCELL-1

Collect PM counters
    [Arguments]    ${collector_alias}
    ${log_dir}=    testline.Get Testcase Log Directory
    pmcounters.Wait until the current Measurement Period stops
    ${pm_files}=    pmcounters.Collect PM Counter    target_dir=${log_dir}    collector_alias=${collector_alias}
    RETURN  ${pm_files}

Add Additional QOS Flows to Activate
    [Documentation]    Add additional qos flows to activate in addition to default qosflow
    [Arguments]    ${id}  ${additional_qosflows}
    Send Egate Command and verify output
    ...   cmd=smf_param id=${id} additional_qosflows_to_activate=${additional_qosflows}
    BuiltIn.Log   Additional QOS flows-${additional_qosflows} added to activate in addition to default qosflow    console=${P_console}

Smf Param Reset
    [Documentation]    Reseting smf parameters to default values
    Send Egate Command and verify output
    ...   cmd=smf_param id=1 reset

Set Emergency Call Priority
    [Arguments]   ${priority}=1  ${ue_id}=1
    Send Egate Command and verify output    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=emergency
    Send Egate Command and verify output    qosflow_modify qos_flow=2 priority=${priority}
    Send Egate Command and verify output    qosflow_modify qos_flow=3 priority=${priority}

Verify B1 measurement event for redirection configured in RRC Reconfiguration
    [Documentation]    To verify if B1 measurement event for redirection is configured by gNB for the UE during RRC Reconfiguration.
    ...   Need to verify that all related redirection parameters provided in RRC message correspond to used one.
    ...   List @{MSG_SEQ_B1_event} must be defined in subfeature suite variable.
    send egate command and verify output    set_log flush
    Verify sequence in Egate file  ${EGATE_CONSOLE_LOG}  @{MSG_SEQ_B1_event}
    BuiltIn.Log    The gNB configures the UE with B1 measurement event for redirection.

Verify RRC Release contains information about redirection target
    [Documentation]    To verify RRC Release contains information about redirection target as per Eutra redirection parameters configured via
    ...   NRBTS/NRCELL/NRREDRT.
    ...   List @{MSG_SEQ_RRC_release} must be defined in subfeature suite variable.
    send egate command and verify output    set_log flush
    Verify sequence in Egate file  ${EGATE_CONSOLE_LOG}  @{MSG_SEQ_RRC_release}
    BuiltIn.Log    RRC release contains information about redirection target as per Eutra redirection parameters configured via NRBTS/NRCELL/NRREDRT.

Verify RRC Release contains information about redirection to B1 target
    [Documentation]    To verify RRC Release contains information about redirection target as per the highest priority B1 target configured
    ...   via NRBTS/NRCELL.b1RedirectList for blind re-direction.
    ...   List @{MSG_SEQ_RRC_release_B1} must be defined in subfeature suite variable.
    send egate command and verify output    set_log flush
    Verify sequence in Egate file  ${EGATE_CONSOLE_LOG}  @{MSG_SEQ_RRC_release_B1}
    BuiltIn.Log    RRC release contains information about redirection target as per the highest priority B1 target configured via b1RedirectList.

Send and verify the measurements report for A_B3_5
    [Arguments]    ${ue_id}=1
    Verify Measurement is configured       event=A2    ue_id=${ue_id}
    Send Measurement Report                event=A2    ue_id=${ue_id}
    Verify Measurement is configured       event=B2    ue_id=${ue_id}
    Verify Measurement is configured       event=A1    ue_id=${ue_id}

Send and verify the measurements report for A_B3_6
    [Arguments]    ${ue_id}=1
    Verify Measurement is configured       event=A2    ue_id=${ue_id}
    Send Measurement Report                event=A2    ue_id=${ue_id}
    Verify Measurement is configured       event=A3    ue_id=${ue_id}
    Verify Measurement is configured       event=A1    ue_id=${ue_id}

Verify Measurement is configured
    [Arguments]  ${event}  ${ue_id}=1
    Send Egate Command and verify output    cmd=ue_meas_cfg_disp id=${ue_id}  pass_regexp=Event${event}

Verify Measurement is absent
    [Arguments]  ${event}  ${ue_id}=1
    ${meas_info}=    Send Egate Command and verify output    cmd=ue_meas_cfg_disp id=${ue_id}  pass_regexp=NR MEASUREMENT IDENTITIES:
    ${status}=  Run Keyword and Return Status
    ...  Should Match Regexp  ${meas_info}  ${event}
    IF  ${status}  Fail  Unexpected ${event} measurement found

Send Measurement Report
    [Arguments]    ${event}  ${meas_values}=${EMPTY}   ${ue_id}=1  ${pass_regexp}=EGATE>  ${fail_regexp}=None
    ${meas_id}=    Get Measurement id      event=${event}  ue_id=${ue_id}
    Send Egate Command and verify output   cmd=ue_meas_cfg_disp id=${ue_id}
    ...                                    pass_regexp=NR MEASUREMENT IDENTITIES:
    ute_wtssim.execute egate command       cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event} ${meas_values}
    ...                                    pass_regexp=${pass_regexp}  fail_regexp=${fail_regexp}   alias=${WTS_ALIAS}
    Sleep   1
    Run Keyword And Ignore Error           Send Egate Command and verify output   cmd=ue_meas_cfg_disp id=${ue_id}
    ...                                    pass_regexp=NR MEASUREMENT IDENTITIES:
    Send Egate Command and verify output   set_log flush

Get Measurement id
    [Arguments]  ${event}  ${ue_id}=1
    ${measurements}=    Send Egate Command and verify output    cmd=ue_meas_cfg_disp id=${ue_id}  pass_regexp=Event${event}
    ${matching_lines}=  Get Lines Containing String  ${measurements}  Event${event}
    ${first_line}=  Get Line  ${matching_lines}  0
    @{words}=  Split String  ${first_line}
    RETURN  ${words}[0]

Bring TL back to on Air status after delta commissioning and wait for next Measurement Period start
    [Documentation]    When the delta commissioning causes the cells to be blocked, this KW is used to bring them back on air and also start
    ...   the measurement period again for PM Counters collection
    Stop F1AP capturing
    Bring Airphone TL to on Air status   cfg_file=basic_setup_CB012118_new.cfg
    Start F1AP capturing
    Wait until the next Measurement Period starts

Enable Emergency Fallback
    Send Egate Command and verify output   amf_param id=1 emergency_service_fallback=on target_cn=epc

Set Emergency Fallback Params
    [Arguments]   ${ue_id}=1
    Enable Emergency Fallback
    Send Egate Command and verify output   amf_ue_ics_param id=1 emergency_fb=on target_cn=epc include_ue_capabilities=off
    Send Egate Command and verify output   ue_nr_rrc_setup_param id=${ue_id} establishment_cause=emergency

UE Idle
    [Arguments]   ${ue_id}=1  ${pass_regexp}=UE${ue_id}: IS IDLE
    Send Egate Command and verify output  ue_im_entry id=${ue_id} by=ue    pass_regexp=${pass_regexp}   timeout=30s

UE Idle via NAS Release
    [Arguments]   ${ue_id}=1
    Send Egate Command and verify output  ue_ng_ctx_release id=${ue_id} cause=NAS_normal_release
    ...    pass_regexp=Received UE Context Release Complete from GNB   timeout=30s

UE Idle Mode Exit
    [Arguments]   ${ue_id}=1  ${service_type}=data  ${pass_regexp}=UE performed IM exit
    Send Egate Command and verify output    ue_im_exit id=${ue_id} by=ue service_type=${service_type}
    ...                                     pass_regexp=${pass_regexp}

Verify sequence in pcap file
    [Arguments]    ${pcap_file}  @{pattern_list}
    ${contents}    OperatingSystem.Run  tshark -n -V -r ${pcap_file}
    log_check.verify_sequence_in_log  ${contents}  @{pattern_list}

Verify UE is configured with B1 Measurement event based on B1 Measurement Priority
    [Documentation]    This is a common keyword for Measurement profile, Mobility profile or both Measurement and Mobility Profile scenarios.
    ...     However, arguments should be provided (from the correct profile) based on B1 measurement priority and the measurement and or mobility
    ...     profile configuration whilie calling this keyword.
    [Arguments]   ${earfcn_1}  ${wideband_meas_1}  ${b1MeasRedir_1}  ${b1Threshold_1}  ${hyst_1}  ${time_to_trig_1}  ${earfcn_2}  ${wideband_meas_2}
    ...           ${b1MeasRedir_2}  ${b1Threshold_2}  ${hyst_2}  ${time_to_trig_2}  ${report_1}=2  ${report_2}=3  ${measid_1}=2  ${measid_2}=3
    ...           ${test_instance}=${EMPTY}
    # String to use as regex for measurement object id
    ${measObjectId_str_1}=      Catenate     SEPARATOR=${empty}       measObjectId\\s2,\\n\\s+measObject\\smeasObjectEUTRA\\s:\\s\\n\\s+{\\n\\s+
    ...     carrierFreq\\s${earfcn_1},(?:.|\\n)*?widebandRSRQ-Meas\\s${wideband_meas_1}
    ${measObjectId_str_2}=      Catenate     SEPARATOR=${empty}       measObjectId\\s3,\\n\\s+measObject\\smeasObjectEUTRA\\s:\\s\\n\\s+{\\n\\s+
    ...     carrierFreq\\s${earfcn_2},(?:.|\\n)*?widebandRSRQ-Meas\\s${wideband_meas_2}
    ${measObjectId_1}=          Set Variable   ${measObjectId_str_1}
    ${measObjectId_2}=          Set Variable   ${measObjectId_str_2}
    # String to use as regex for report Config Id
    ${reportConfigId_str_1}=    Catenate     SEPARATOR=${empty}       reportConfigId\\s${report_1},(?:.|\\n)*?eventId\\seventB1\\s:\\s\\n\\s+{\\n\\s+
    ...     b1-ThresholdEUTRA\\s${b1MeasRedir_1}\\s:\\s${b1Threshold_1},(?:.|\\n)*?hysteresis\\s${hyst_1},\\n\\s+timeToTrigger\\s${time_to_trig_1}\n
    ${reportConfigId_str_2}=    Catenate     SEPARATOR=${empty}       reportConfigId\\s${report_2},(?:.|\\n)*?eventId\\seventB1\\s:\\s\\n\\s+{\\n\\s+
    ...     b1-ThresholdEUTRA\\s${b1MeasRedir_2}\\s:\\s${b1Threshold_2},(?:.|\\n)*?hysteresis\\s${hyst_2},\\n\\s+timeToTrigger\\s${time_to_trig_2}\n
    ${reportConfigId_1}=        Set Variable   ${reportConfigId_str_1}
    ${reportConfigId_2}=        Set Variable   ${reportConfigId_str_2}
    # String to use as regex for measurement add mod id
    ${measids}=                 Catenate     SEPARATOR=${empty}       measObjectId\\s3,\\n\\s+reportConfigId\\s3\\n\\s+},\\n\\s+{\\n\\s+measId\\s4,
    ...     \\n\\s+measObjectId\\s4,\\n\\s+reportConfigId\\s4\\n\\s+},\\n\\s+{\\n\\s+measId\\s5,\\n\\s+measObjectId\\s5,\\n\\s+reportConfigId\\s5\\n
    ${other_b1_measids}=  Set Variable If  $test_instance in ['B_B2_4', 'B_B2_5']  ${measids}  ${EMPTY}
    ${measIdToAddMod_str}=      Catenate     SEPARATOR=${empty}       measIdToAddModList\\s\\n\\s+{\\n\\s+{\\n\\s+measId\\s${measid_1},\\n\\s+
    ...     measObjectId\\s2,\\n\\s+reportConfigId\\s${report_1}\\n\\s+},\\n\\s+{\\n\\s+measId\\s${measid_2},\\n\\s+${other_b1_measids}
    ${measIdToAddMod}=          Set Variable   ${measIdToAddMod_str}
    @{measEvent}=               Create List    ${measObjectId_1}   ${measObjectId_2}   ${reportConfigId_1}   ${reportConfigId_2}   ${measIdToAddMod}

    wts_ue.Send Egate Command and verify output    set_log flush
    Sleep   1s   Reason=waiting before fetching the log file, else the log file may miss last part of the messages
    ${log_content}=             Get File       ${EGATE_CONSOLE_LOG}
    ${event_index}=             Set Variable   0
    FOR   ${event}    IN    @{measEvent}
        ${event_present}=   Run Keyword And Return Status   Should Match Regexp     ${log_content}      ${event}
        IF      ${event_present} == False    FAIL    Expected measurement profile not present in RRC reconfiguration measurement config
        ${event_index} =    Evaluate    ${event_index} + 1
    END

Update AMF Initial Context Setup RFSP parameter
    [Documentation]    To update online changeable AMF Initial Context Setup RFSP parameter to send RFSP during context setup
    [Arguments]   ${ue_id}  ${indexToRFSP}
    Send Egate Command and verify output  cmd=amf_ue_ics_param id=1 ue=${ue_id} indexToRFSP=${indexToRFSP}

Trigger UE Context Modification procedure with Emergency Fallback Indicator IE
    [Documentation]    Adds optional Emergency Fallback Indicator IE in UE Context Modification Request message, when emergency_fb set to on.
    [Arguments]   ${ue_id}  ${emergency_fb}
    Send Egate Command and verify output  cmd=ue_ctx_ng_mod id=${ue_id} emergency_fb=${emergency_fb} target_cn=epc

Verify UE is neither configured with B1 Measurement Event nor redirected blindly to EUTRA
    [Documentation]    This keyword verifies that UE is not configured with B1 measurement for redirecting to LTE, also checks UE is not blindly
    ...   redirected to LTE.
    send egate command and verify output    set_log flush
    Verify sequence in Egate file  ${EGATE_CONSOLE_LOG}  @{MSG_SEQ_B1_event}
    BuiltIn.Log    The gNB configures the UE with B1 measurement event for redirection.

Verify gNB Triggers RRC Release with Redirected Eutra Carrier Info
    [Documentation]    This keyword verifies whether gNB releases the UE with redirected EUTRA Carrier info.
    [Arguments]   ${redir_carrier}
    @{redirected_carrier_info}=     create list
    ...  message c1 : rrcRelease :  redirectedCarrierInfo eutra :  eutraFrequency ${redir_carrier}  Redirected carrier info is present in RRC Release
    send egate command and verify output    set_log flush
    Verify sequence in Egate file  ${EGATE_CONSOLE_LOG}  @{redirected_carrier_info}
    BuiltIn.Log    UE receives RRC release with redirected Carrier Info for fall back to an EUTRA target Frequency ${redir_carrier}

Fetch Nidd Version From SCF File
    [Documentation]    This keyword fetches the NIDD version of NRBTS from current SCF file and create a suite variable with this NIDD version
    [Arguments]
    ${scf_file}=         Get File    ${P_ORIG_SCF}
    ${nrbts_nidd_ver}=	 Get Lines Containing String       ${scf_file}	    com.nokia.srbts.nrbts:NRBTS
    ${nrbts_nidd_list}   Split String      ${nrbts_nidd_ver}     "
    ${NIDD_VERSION}=     Evaluate    "${nrbts_nidd_list}[5]".replace("'", "")
    Set Suite Variable   ${NIDD_VERSION}

Register and Establish PDU Session for Multiple UEs
    [Documentation]    Register and establish PDU Session for UEs.
    [Arguments]    ${ue_1}  ${ue_2}  ${ue_3}  ${ue_4}
    ${ue_list}=   Create List   ${ue_1}   ${ue_2}   ${ue_3}   ${ue_4}
    FOR  ${ue}   IN   @{ue_list}
        Modifying default QOS flow  ue_id=${ue}  qos_flow=2
        Set traffic type  ue_id=${ue}  pdu_id=1  trf_type=internal
        Add Additional QOS Flows to Activate  id=1  additional_qosflows=1
        UE PDU Session Setup  ue_id=${ue}  pdu=1  gw=${ue}
    END
    Smf Param Reset
    Start data traffic in egate  ue_id=${ue_id}  direction=dl  mbps=${mbps}  trf_id=${trf_id}  pdu=${pdu}  qfi=${qfi}

Verify gNB neither Configures B1 Event nor Triggers RRC Release with Redirected Eutra Carrier Info for UE
    [Documentation]    This keyword verifies that gNB neither triggers RRC Reconfiguration with B1 event release nor RRC Release.
    @{redirected_carrier_info}=     create list
    ...  message c1 : rrcRelease :  redirectedCarrierInfo eutra :  eutraFrequency  Redirected carrier info is present in RRC Release
    Sleep  10s  Reason=wait before set_log flush
    send egate command and verify output    set_log flush
    ${redir_status}  Run Keyword And Return Status   Verify sequence in Egate file  ${EGATE_CONSOLE_LOG}  @{redirected_carrier_info}
    IF  not ${redir_status}
    ...   BuiltIn.Log   UE is not configured with B1 meas for redirection & redirection release is not triggered since voice FB mode is not enabled.
    ...   ELSE          Fail   UE receives RRC release with redirected Carrier Info for fall back to an EUTRA target Frequency.

Start Capturing NGAP PCAP Traces and Initiate Downlink NRPPa Transport ECID Measurement Request
    [Documentation]    This keyword captures NGAP PCAP traces and triggers ECID Measurement Initiation Request from LMF to gNB via AMF over NRPPA
    ...    interface.
    [Arguments]    ${send_mr_delay}=10000
    Start Tcpdump on TestPC  options=-i eth3 sctp  collector=NGAP
    ${nrecid_meas_report}    Catenate    ue_measurement_send_nr id=1 meas_id=0 report_type=periodical action=send_after_rrc_reconf_complete
    ...    delay=${send_mr_delay}  srsrp_nr=30 srsrq_nr=30 srs_result=0:50:50
    Send Egate Command and verify output  cmd=${nrecid_meas_report}
    ${ecid_meas_initiation_req}    Catenate    lmf_send_ecid_meas_req id=1 ue=1 nrppa_transaction_id=1 lmf_ue_measurement_id=1
    ...    report_characteristics=OnDemand meas_qty=SS-RSRP,SS-RSRQ
    Send Egate Command and verify output  cmd=${ecid_meas_initiation_req}  pass_regexp=rrcReconfigurationComplete

Verify IEs in NGAP PCAP Traces in Received Uplink NRPPa ECID Measurement Initiation Message
    [Documentation]    This keyword verifies the IEs according to Acceptance Criteria in the received Uplink UE Associated NRPPa Transfer ECID
    ...    Measurement Response.
    [Arguments]    ${test_instance}
    Sleep  3s  Reason=wait before stopping tcpdump, else pcap file may miss last part of the messages
    ${ngap_pcap}=       Stop Tcpdump on TestPC    collector=NGAP
    @{nrppa_trace1}=    create list
    ...                 E-CIDMeasurementInitiationResponse
    ...                 Item 0: id-LMF-UE-Measurement-ID
    ...                 Item 1: id-RAN-UE-Measurement-ID
    ...                 Item 2: id-E-CID-MeasurementResult
    ...                 measuredResults: 1 item
    ...                 id: id-ResultSS-RSRP
    ...                 ResultSS-RSRP: 1 item
    ...                 nR-PCI: 50
    ...                 nR-ARFCN: 636666
    ...                 cGI-NR
    ...                 pLMN-Identity: 134198
    ...                 nRcellIdentifier: 0000040010
    ...                 valueSS-RSRP-Cell: 40

    @{nrppa_trace2}=    create list
    ...                 E-CIDMeasurementInitiationResponse
    ...                 Item 0: id-LMF-UE-Measurement-ID
    ...                 Item 1: id-RAN-UE-Measurement-ID
    ...                 Item 2: id-E-CID-MeasurementResult
    ...                 measuredResults: 2 items
    ...                 id: id-ResultSS-RSRP
    ...                 ResultSS-RSRP: 1 item
    ...                 nR-PCI: 50
    ...                 nR-ARFCN: 636666
    ...                 cGI-NR
    ...                 pLMN-Identity: 134198
    ...                 nRcellIdentifier: 0000040010
    ...                 valueSS-RSRP-Cell: 30
    ...                 sS-RSRP-PerSSB: 1 item
    ...                 ResultSS-RSRP-PerSSB-Item
    ...                 sSB-Index: 0
    ...                 valueSS-RSRP: 50
    ...                 id: id-ResultSS-RSRQ
    ...                 ResultSS-RSRQ: 1 item
    ...                 valueSS-RSRQ-Cell: 30
    ...                 sS-RSRQ-PerSSB: 1 item
    ...                 ResultSS-RSRQ-PerSSB-Item
    ...                 sSB-Index: 0
    ...                 valueSS-RSRQ: 50

    @{nrppa_trace3}=    create list
    ...                 E-CIDMeasurementInitiationFailure
    ...                 Item 0: id-LMF-UE-Measurement-ID
    ...                 Cause: radioNetwork
    ...                 radioNetwork: requested-item-temporarily-not-available

    IF    '${test_instance}' == 'G_B1_1'
    ...   Verify sequence in pcap file  ${ngap_pcap}  @{nrppa_trace1}
    ...   ELSE IF    '${test_instance}' == 'G_B1_4'    Verify sequence in pcap file  ${ngap_pcap}  @{nrppa_trace2}
    ...   ELSE    Verify sequence in pcap file  ${ngap_pcap}  @{nrppa_trace3}

Verify nrEcidMeasSupervisionTimer Status in Sys Log
    [Documentation]    This keyword verifies the nrEcidMeasSupervisionTimer status in syslog file.
    [Arguments]    ${nrEcidMeas_SupervisionTimer}  ${timer_expired}=False
    ${log_dir}=         testline.Get Testcase Log Directory
    Copy File           /tmp/btslog2/SYSLOG_1.LOG    ${log_dir}/nrEcidMeasTimer_syslog/
    ${syslog_content}=  Get File    ${log_dir}/nrEcidMeasTimer_syslog/SYSLOG_1.LOG
    @{nrEcidMeasSupervisionTimerList}=    create list
    ...                 Starting nrEcidMeasSupervision Timer ${nrEcidMeas_SupervisionTimer} ms
    ...                 nrEcidMeasSupervision Timer is started with ${nrEcidMeas_SupervisionTimer} milliseconds.
    ...                 Timer nrEcidMeasSupervision deleted.
    log_check.verify_sequence_in_log  ${syslog_content}  @{nrEcidMeasSupervisionTimerList}
    IF    ${timer_expired}    Should Contain    ${syslog_content}    nrEcidMeasSupervision Timer expired for UE
    ...    ELSE    Should Not Contain    ${syslog_content}    nrEcidMeasSupervision Timer expired for UE
