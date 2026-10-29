*** Settings ***
Documentation
...    author: Ulm SQD 65
...    Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...    Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
...    Description: Keywords for CB008574

Resource    ../resources/SQD65/sqd65_keywords.robot
Resource    ../resources/SQD65/sqd65_commissioning.robot
Resource    CB008574_Counters.robot
Resource    CB008574_PM.robot

Library     taf.ul.hanging_resources   WITH NAME   resources

*** Variables ***
${NIDD_VERSION}                     NRBTSCL23R3_2309_110
@{DCAP_PROFILE}                     cp_5g
@{IP_LIST_eth3_add}                 10.0.1.200  10.0.1.201
@{IP_LIST_eth4_add}                 10.0.2.90
${EGATE_CONSOLE_LOG}                /opt/iphy/latest/egate_console.log

${TCE_PORT_NUMBER_DU}               49148

@{5qi1_list}                        ${2}

${SRC_GNB}                          2
${SRC_CELL}                         1
${TGT_GNB}                          3
${TGT_CELL}                         3
${PREP_CELL}                        4
${SIM_GNB}                          4
${SIM_CELL}                         5
${TGT_NODE}                         ${1}

*** Keywords ***

Setup TL for CB008574
    Set Console Output
    Sqd65 Common Setup    skip_precheck=${True}
    Bring Airphone TL to F1 up status
    Bring Airphone TL to on Air status without reboot    remove_logs=${True}
    Send Egate Command and verify output    cmd=amf_ue_ng_handover_request_param id=1 ue=all mobility_restriction_list_id=1
    ...                                     fail_regexp=disabled currently
    # WA  dcap start again
    run keyword and warn on failure         dcap.start dcap container for all nodes
    Start Netcat For Tracing
    ${SW_BRANCH}=                           testline.Get gNB SW Branch
    Set Suite Variable                      ${SW_BRANCH}

Bring Up TL for CB008574
    Bring Airphone TL to on Air status      remove_logs=${True}
    Send Egate Command and verify output    cmd=amf_ue_ng_handover_request_param id=1 ue=all mobility_restriction_list_id=1
    ...                                     fail_regexp=disabled currently

CB008574 Teardown
    stop dcap container for all nodes
    Stop Netcat For Tracing

Perform Precondition of Test Scenario
    IF    '${PREV_TEST_STATUS}'=='FAIL'    Bring Up TL For CB008574
    Run Keyword and ignore error  UE Deregister
    Save Counter Reference Tables
    Enable Prepared Cell
    Start Logging                          pmcounter_enabled=${FALSE}
    get resources taken before_test
    Send Egate Command and verify output   cmd=ue_nr_rrc_reconf_param id=1 reset
    Send Egate Command and verify output   cmd=smf_param id=1 reset
    Send Egate Command and verify output   cmd=ue_gnb_ho_param id=1 gnb=4 reset
    Send Egate Command and verify output   cmd=amf_ue_ng_handover_param id=1 reset
    Wait until the next Measurement Period starts

Perform Postconditions of Test Scenario
    IF    '${TEST_STATUS}'=='FAIL'         Collect AP SOS Report And Snapshots
    Deregister UE
    Stop Logging
    Set actForceFullRRCConfigurationSaHo    value=disabled
    Set actFullRRCConfigurationSaHo         value=disabled
    get resources taken after_test
    verify resource usage
    Restore Counter Reference Tables

Start TCE tracing
    tshark.Start Tshark for Trace Session    interface=eth3  trace_port=${TCE_PORT_NUMBER}     collector=trace_session_cu
    tshark.Start Tshark for Trace Session    interface=eth3  trace_port=${TCE_PORT_NUMBER_DU}  collector=trace_session_du

Collect PM counters from both gNBs
    Wait until the current Measurement Period stops
    ${pm_files_src}=  Collect PM Counter    gnb_id=0    collector_alias=gnb_0_pm
    ${pm_files_tgt}=  Collect PM Counter    gnb_id=1    collector_alias=gnb_1_pm
    RETURN  ${pm_files_src}  ${pm_files_tgt}

Collect PM counters from target gNB
    Wait until the current Measurement Period stops
    ${pm_files_tgt}=  Collect PM Counter    gnb_id=${TGT_NODE}    collector_alias=gnb_${TGT_NODE}_pm
    RETURN  ${pm_files_tgt}

UE Change Location
    [Arguments]    ${id}=1    ${enb}=${SRC_GNB}    ${cell}=${SRC_CELL}
    Send Egate Command and verify output    cmd=ue_change_location id=${id} enb=${enb} cell=${cell}
    ...                                     pass_regexp=(location updated to eNB-${enb} cell ${cell})|(already there)
    ...                                     fail_regexp=[Ee]rror.*ENB.*is not configured

UE Attach with VoNR Call and start traffic
    [arguments]    ${ue}=1    ${pdu}=1    ${enb}=2    ${cell}=1
    UE Change Location    id=${ue}  enb=${enb}  cell=${cell}
    Send Egate Command and verify output   ue_nr_rrc_setup_param id=${ue} establishment_cause=mo-VoiceCall
    UE Register    ue_id=${ue}
    Set traffic type   ue_id=${ue}   pdu_id=${pdu}   trf_type=internal
    UE PDU Session Setup   ue_id=${ue}  pdu=${pdu}   pass_regexp=(Pdu Session.*successfully)|(Initial Context Setup Successful)
    UE PDU Session Modify   ue_id=${ue}  pdu=${pdu}  qos_flow_list=@{5qi1_list}  by=amf
    Start data traffic in egate   ue_id=${ue}   direction=dl   protocol=udp   trf_id=1   pdu=${pdu}   qfi=1   mbps=1   size=100
    Start data traffic in egate   ue_id=${ue}   direction=dl   protocol=udp   trf_id=1   pdu=${pdu}   qfi=2   mbps=1   size=100

Start and Stop 850mbps DL for CA Setup and Release
    FOR    ${trf}    IN RANGE    1  6
        Start data traffic in egate   ue_id=1  direction=dl  protocol=udp  trf_id=${trf}  pdu=1  qfi=1  mbps=170
    END
    Sleep    60s    reason=wait for Scell Addition, pm counter is used for verification
    FOR    ${trf}    IN RANGE    1  6
        run keyword and warn on failure  Get Average Data Rate via Egate    ue_id=1  dir=dl  trf_id=${trf}  pdu=1  qfi=1
    END
    run keyword and warn on failure  Get Average Data Rate via Egate    ue_id=1  dir=dl  trf_id=1  pdu=1  qfi=2
    FOR    ${trf}    IN RANGE    1  6
        Stop data traffic in egate    ue_id=1  direction=dl  trf_id=${trf}  pdu=1  qfi=1
    END
    Send Egate Command and verify output    cmd=trf_data_stop ue=1 dir=dl trf_id=1 pdu=1 qfi=2
    ...    timeout=60    pass_regexp=(sCellToReleaseList)|(SCellIndex 1 deactivated successfully)    #Verify Scell Release

Wait for delayed NG HO to finish
    Send Egate Command and verify output   cmd=info    pass_regexp=:Received UE Context Release Complete from source GNB-2

Set actInterGnbRREPreparedCell
    [Arguments]    ${gnb_id}    ${value}
    ${current_scf}=           Load current SCF   gnb_id=${gnb_id}
    Set Element               dist_name=MRBTS-1/NRBTS-${gnb_id+1}    p_name=actInterGnbRREPreparedCell    value=${value}
    Apply Delta SCF           ${current_scf}  actInterGnbRREPreparedCell_${value}    gnb_id=${gnb_id}

Register UE on srcGnb and start traffic and tracing
    Start TCE tracing
    UE Attach with VoNR Call and start traffic   enb=${SRC_GNB}  cell=${SRC_CELL}
    Send NR Measurement Report  event=A2  carrier_freq=518910

Register UE on simGnb and start traffic
    [arguments]    ${ue}=1  ${enb}=${SIM_GNB}  ${cell}=${SIM_CELL}
    Nullify Source Counters
    UE Attach with VoNR Call and start traffic  enb=${enb}  cell=${cell}
    Send Egate Command and verify output
    ...        cmd=ue_gnb_ho_param id=${ue} gnb=${TGT_GNB} reestab_info=${TGT_CELL}:valid reestab_ncell_info=${PREP_CELL}:valid
    ...        pass_regexp=${PREP_CELL}:valid
    Send Egate Command and verify output
    ...        cmd=ue_gnb_ho_param id=${ue} gnb=${cell} include_security_config=on
    ...        pass_regexp=include_security_config

Register UE and start traffic
    [arguments]    ${ue}=1    ${pdu}=1
    UE Register                   ue_id=${ue}
    Set traffic type              ue_id=${ue}   pdu_id=${pdu}  trf_type=internal
    UE PDU Session Setup          ue_id=${ue}   pdu=${pdu}     pass_regexp=(Pdu Session.*successfully)|(Initial Context Setup Successful)
    Start data traffic in egate   ue_id=${ue}   direction=dl   protocol=udp   trf_id=1   pdu=${pdu}   qfi=1   mbps=1   size=100
    Start data traffic in egate   ue_id=${ue}   direction=dl   protocol=udp   trf_id=1   pdu=${pdu}   qfi=2   mbps=1   size=100

Stop TCE tracing
    ${tce_trc_cu}    Collect trace and stop TCE  collector=trace_session_cu
    ${tce_trc_du}    Collect trace and stop TCE  collector=trace_session_du

    ${tce_trc_du_src}   Convert nsetapx trace to PDML   pcap_file=${tce_trc_du}   pdml_file=trc-src-gnb-du  port=${TCE_PORT_NUMBER_DU}
    ...                                                 filter=ip.addr==10.0.1.2
    ${tce_trc_du_tgt}   Convert nsetapx trace to PDML   pcap_file=${tce_trc_du}   pdml_file=trc-src-gnb-du  port=${TCE_PORT_NUMBER_DU}
    ...                                                 filter=ip.addr==10.0.1.3

    ${tce_trc_cu_src}   Convert nsetapx trace to PDML   pcap_file=${tce_trc_cu}   pdml_file=trc-src-gnb-cu  port=${TCE_PORT_NUMBER}
    ...                                                 filter=ip.addr==10.0.1.2
    ${tce_trc_cu_tgt}   Convert nsetapx trace to PDML   pcap_file=${tce_trc_cu}   pdml_file=trc-src-gnb-cu  port=${TCE_PORT_NUMBER}
    ...                                                 filter=ip.addr==10.0.1.3
    RETURN  ${tce_trc_cu}  ${tce_trc_du}

Deregister UE
    Run Keyword and ignore error  UE Deregister

Setup Reestablishment sent after Measurement and delay Handover Request
    [Arguments]    ${ue}=1  ${cause}=handoverFailure  ${target_cell}=${TGT_CELL}
    Send Egate Command and verify output
    ...        cmd=ue_rrc_reestablish id=${ue} gnb=${TGT_GNB} cell=${target_cell} cause=${cause} send_after=measurement_report time_to_wait=27
    ...        pass_regexp=RRC Reestablishment will be sent after Measurement Report
    Send Egate Command and verify output        cmd=amf_ue_ng_handover_param id=${ue} action=delay_handover_request time_to_wait=60
    Send Egate Command and verify output        cmd=amf_ue_ng_handover_param id=${ue} pass_regexp=60

Ignore RRC Reconfig and Trigger RRCReestablishmentRequest
    [Arguments]    ${ue}=1  ${cause}=reconfigurationFailure  ${tgt_gnb}=${TGT_GNB}  ${target_cell}=${TGT_CELL}
    Send Egate Command and verify output
    ...        cmd=ue_nr_rrc_reconf_param id=${ue} if_contains=any action=reestablish gnb=${tgt_gnb} cell=${target_cell} crnti=source cause=${cause}
    Send Egate Command And Verify Output   cmd=ue_nr_rrc_reconf_param id=${ue}

Ignore RRC Reconf
    Send Egate Command and verify output
    ...        cmd=ue_nr_rrc_reconf_param id=1 if_contains=any action=drop
    Send Egate Command and verify output   cmd=ue_nr_rrc_reconf_param id=1

Setup Invalid Short Mac I for RRC Reestablishment
    Send Egate Command and verify output
    ...        cmd=ue_rrc_reestablish_param id=1 if_contains=any action=invalid_short_mac_I
    Send Egate Command and verify output   cmd=ue_rrc_reestablish_param

Trigger HO
    [Arguments]    ${pass_regexp}=rrcReestablishmentComplete   ${carrier_freq}=518910   ${phycell_id}=21
    ${meas_ids}    sqd65_keywords.Get NR Measurement IDs     event_type=A3  ue_id=1  carrier_freq=${carrier_freq}
    wts_ue.Send Egate Command And Verify Output
    ...            cmd=ue_measurement_send_nr id=1 meas_id=${meas_ids}[0] event=A3 srsrp_nr=19 phycell_id=${phycell_id} nrsrp_nr=100
    ...            pass_regexp=${pass_regexp}

RRC Reestablishment Request
    [Arguments]    ${ue}=1  ${cause}=handoverFailure  ${target_gnb}=${TGT_GNB}  ${target_cell}=${TGT_CELL}  ${action}=none  ${fail_regexp}=${None}
    ${cause_action}    IF  '${action}' != 'none'      Set Variable  ${cause} action=${action}
    ...                ELSE                           Set Variable  ${cause}
    Send Egate Command And Verify Output   cmd=ue_rrc_reestablish id=${ue} gnb=${target_gnb} cell=${target_cell} cause=${cause_action}
    ...                                    pass_regexp=reestablishment complete  fail_regexp=${fail_regexp}

Set actFullRRCConfigurationSaHo
    [Arguments]    ${gnb_id}=${TGT_NODE}  ${value}=enabled
    ${current_scf}=           Load current SCF   gnb_id=${gnb_id}
    Set Element               dist_name=MRBTS-1/NRBTS-${gnb_id+1}    p_name=actFullRRCConfigurationSaHo    value=${value}
    Apply Delta SCF           ${current_scf}  actFullRRCConfigurationSaHo    gnb_id=${gnb_id}

Set actForceFullRRCConfigurationSaHo
    [Arguments]    ${gnb_id}=${TGT_NODE}   ${value}=enabled
    ${current_scf}=           Load current SCF   gnb_id=${gnb_id}
    Set Element               dist_name=MRBTS-1/NRBTS-${gnb_id+1}    p_name=actForceFullRRCConfigurationSaHo    value=${value}
    Apply Delta SCF           ${current_scf}  actForceFullRRCConfigurationSaHo    gnb_id=${gnb_id}

Remove Qosflow Mapping List in HandOverRequired
    Send Egate Command and verify output   ue_gnb_ho_param id=1 gnb=${SIM_GNB} dRB_To_QosFlowsMappingList_Missing_For_Pdu=1
    ...                                    pass_regexp=modify_qfi

Activate Additional QosFlow
    Send Egate Command and verify output   cmd=smf_param id=1 additional_qosflows_to_activate=2
    Send Egate Command and verify output   cmd=smf_param id=1

Invalid QosFlow Mapping in HandOverRequired
    Send Egate Command and verify output   ue_gnb_ho_param id=1 gnb=${SIM_GNB} drb_id_to_qos_flows_mapping=4:1|2
    ...                                    pass_regexp=4:1,2

Unsupported Extension Type in HandOverRequired
    Send Egate Command and verify output   ue_gnb_ho_param id=1 gnb=${SIM_GNB} unsupported_extension_type=late_non_crit_extn_rrcreconfig

get resources taken before_test
    Log To Console    \nget used resources and save in var "resources_usage_before_test"
    ${resources_usage_before_test}    resources.Get Resources Usage   node_id=${TGT_NODE}    node_type=gnb
    set test variable    ${resources_usage_before_test}

get resources taken after_test
    Sleep    5s    reason=wait until resource clean up
    Log To Console    \nget used resources and save in var "resources_usage_after_test"
    ${resources_usage_after_test}    resources.Get Resources Usage   node_id=${TGT_NODE}     node_type=gnb
    set test variable    ${resources_usage_after_test}

verify resource usage
    [Documentation]  doesn't check postTimerWheel
    Log To Console    \nverify used resources
    resources.Configure Default excluding Resource Paths   add=//postTimerWheel
    Run Keyword And Continue On Failure      resources.Resources Should Be Equal
    ...    ${resources_usage_before_test}
    ...    ${resources_usage_after_test}

Verify B3_1 PM Counters
    ${pm_files_tgt}   Collect PM counters from target gNB
    Verify PM Counter Reference Table  reference_table=${A-B3_1_PM_CU}      pm_dir=${pm_files_tgt}   distname_suffix=NRCELL-1
    Verify PM Counter Reference Table  reference_table=${A-B3B4_1_PM_DU}    pm_dir=${pm_files_tgt}   distname_suffix=NRDU-1
    Verify PM Counter Reference Table  reference_table=${A-PM_CU_PLMN}      pm_dir=${pm_files_tgt}   distname_suffix=1/PLMN-PLMN/MCC-311/MNC-489
    Verify PM Counter Reference Table  reference_table=${A-PM_NRPMQAP}      pm_dir=${pm_files_tgt}   distname_suffix=1/PLMN-PLMN/NRPMQAP-1

Verify B3_2 PM Counters
    ${pm_files_src}  ${pm_files_tgt}   Collect PM counters from both gNBs
    Verify PM Counter Reference Table  reference_table=${A-B3_2_PM_CU}      pm_dir=${pm_files_tgt}   distname_suffix=NRCELL-2
    Verify PM Counter Reference Table  reference_table=${A-B3B4_2_PM_DU}    pm_dir=${pm_files_tgt}   distname_suffix=NRDU-1
    Verify PM Counter Reference Table  reference_table=${A-PM_CU_PLMN}      pm_dir=${pm_files_tgt}   distname_suffix=2/PLMN-PLMN/MCC-311/MNC-489
    Verify PM Counter Reference Table  reference_table=${A-PM_NRPMQAP}      pm_dir=${pm_files_tgt}   distname_suffix=2/PLMN-PLMN/NRPMQAP-1

Verify B4_1 PM Counters
    ${pm_files_src}  ${pm_files_tgt}   Collect PM counters from both gNBs
    Verify PM Counter Reference Table  reference_table=${A-B4_1_PM_CU}      pm_dir=${pm_files_tgt}   distname_suffix=NRCELL-2
    Verify PM Counter Reference Table  reference_table=${A-B3B4_1_PM_DU}    pm_dir=${pm_files_tgt}   distname_suffix=NRDU-1
    Verify PM Counter Reference Table  reference_table=${A-PM_CU_PLMN}      pm_dir=${pm_files_tgt}   distname_suffix=1/PLMN-PLMN/MCC-311/MNC-489
    Verify PM Counter Reference Table  reference_table=${A-PM_NRPMQAP}      pm_dir=${pm_files_tgt}   distname_suffix=1/PLMN-PLMN/NRPMQAP-1

Verify B4_2 PM Counters
    ${pm_files_src}  ${pm_files_tgt}   Collect PM counters from both gNBs
    Verify PM Counter Reference Table  reference_table=${A-B4_2_PM_CU}      pm_dir=${pm_files_tgt}   distname_suffix=NRCELL-1
    Verify PM Counter Reference Table  reference_table=${A-B3B4_2_PM_DU}    pm_dir=${pm_files_tgt}   distname_suffix=NRDU-1
    Verify PM Counter Reference Table  reference_table=${A-PM_CU_PLMN}      pm_dir=${pm_files_tgt}   distname_suffix=2/PLMN-PLMN/MCC-311/MNC-489
    Verify PM Counter Reference Table  reference_table=${A-PM_NRPMQAP}      pm_dir=${pm_files_tgt}   distname_suffix=2/PLMN-PLMN/NRPMQAP-1

Verify EC4 PM Counters
    ${pm_files_src}  ${pm_files_tgt}   Collect PM counters from both gNBs
    Verify PM Counter Reference Table  reference_table=${A-EC4_PM_CU}      pm_dir=${pm_files_tgt}   distname_suffix=NRCELL-2
    Verify PM Counter Reference Table  reference_table=${A-EC4_PM_DU}    pm_dir=${pm_files_tgt}   distname_suffix=NRDU-1

Check target gNB PM Counters
    ${pm_files_tgt}   Collect PM counters from target gNB
    run keyword and warn on failure
    ...  Verify PM Counter Reference Table  reference_table=${ALL_PM_COUNTERS}   pm_dir=${pm_files_tgt}   distname_suffix=NRBTS-2/NRCELL-1
    run keyword and return status
    ...  Verify PM Counter Reference Table  reference_table=${ALL_PM_COUNTERS}   pm_dir=${pm_files_tgt}   distname_suffix=NRBTS-2/NRCELL-2
    Verify PM Counter Reference Table  reference_table=${ALL_PM_COUNTERS}   pm_dir=${pm_files_tgt}   distname_suffix=NRBTS-2/NRDU-1

B8 Verification
    [Arguments]    ${target_cell}=${TGT_CELL}  ${cause}=handoverFailure
    Verify FullConfig             ${target_cell}
    Set RRC_REESTAB_FAIL_TARGET_CELL counters                        target_cell=${target_cell}   fail_cause=${cause}
    Set Counter Value             ${RRC_REESTAB_FAIL_TARGET_CELL}    HO_PREP_SUCC_FULLCONF_TRG    1
    Common Counter Verification   target_cell=${target_cell}

B9 Verification
    [Arguments]    ${target_cell}=${TGT_CELL}   ${cause}=handoverFailure
    ${lcid}                      Set Variable If  '${target_cell}' == '${PREP_CELL}'   ${2}  ${1}
    Verify RRCSetup              target_cell=${target_cell}    cause=handoverFailure  src_gnb=${SIM_GNB}  action=reestablish
    Set RRC_REESTAB_FAIL_TARGET_CELL counters  target_cell=${target_cell}   fail_cause=${cause}
    Common Counter Verification  target_cell=${target_cell}

Nullify Source Counters
    FOR  ${entry}  IN RANGE  999
         ${index}=           Get Index From List     ${SOURCE_COUNTERS}                  1
         IF                  ${index} == ${-1}       BREAK
         Set List Value                              ${SOURCE_COUNTERS}  ${index}        0
    END

Set Counter Value
    [Arguments]     ${ref_table}=${RRC_REESTAB_FAIL_TARGET_CELL}  ${counter_name}=NF1CC_UECTXT_REL_CMDSENT  ${value}=0
    ${index}=       Get Index From List       ${ref_table}        ${counter_name}
    Set List Value  ${ref_table}              ${index-1}          ${value}

Set RRC_REESTAB_FAIL_TARGET_CELL counters
    [Arguments]    ${target_cell}=${TGT_CELL}   ${fail_cause}=handoverFailure
    ${target_cell_counters}       Set Variable If  '${target_cell}' == '${PREP_CELL}'   ${RRC_REESTAB_FAIL_PREP_CELL}  ${RRC_REESTAB_FAIL_TARGET_CELL}
    Set Counter Value             ${target_cell_counters}       RRC_REESTAB_FALLBACK            1
    Set Counter Value             ${target_cell_counters}       RRC_REESTAB_ATT_VONR            1
    Set Counter Value             ${target_cell_counters}       REESTAB_ACC_FALLBACK            1
    IF  '${SW_BRANCH}' < 'SBTS26R2' and '${SW_BRANCH}' != 'SBTS00'
       Set Counter Value          ${target_cell_counters}       RRC_REESTAB_DISCARD             1
    END

    ${fail_counter}  IF           '${fail_cause}' == 'handoverFailure'             Set Variable    RRC_REESTAB_HO_FAILURE
    ...              ELSE IF      '${fail_cause}' == 'otherFailure'                Set Variable    RRC_REESTAB_OTHER_FAILURE
    ...              ELSE IF      '${fail_cause}' == 'reconfigurationFailure'      Set Variable    RRC_REESTAB_RECONF_FAILURE
    ...              ELSE         Fail   unknown failure cause: ${fail_cause}
    Set Counter Value            ${target_cell_counters}         ${fail_counter}            1
    Set Counter Value            ${RRC_REESTAB_FAIL_TARGET_DU}   ${fail_counter}_DU         1
    IF    '${SW_BRANCH}'=='SBTS25R1' or '${SW_BRANCH}'=='SBTS24R3'
    ...   Set Counter Value            ${RRC_REESTAB_FAIL_TARGET_DU}   RRC_REESTAB_DISCARD_DU     1

    ${counter_value}             Set Variable If  '${target_cell}' == '${PREP_CELL}'                    2  0
    Set Counter Value            ${RRC_REESTAB_FAIL_PREP_CELL_PMQAP}    NG_FLOW_STP_ATT_RES_IADU_PMQAP  ${counter_value}
    Set Counter Value            ${RRC_REESTAB_FAIL_PREP_CELL_NG_FLOW}  NG_FLOW_STP_ATT_REEST_IADU      ${counter_value}
    ${counter_value}             Set Variable If  '${target_cell}' == '${PREP_CELL}'                    1  0
    Set Counter Value            ${RRC_REESTAB_FAIL_PREP_CELL_NG_FLOW}  NG_FLOW_STP_ATT_RES_IADU_5QI1   ${counter_value}

B4 Verification
    [Arguments]    ${target_cell}=${TGT_CELL}      ${cause}=reconfigurationFailure

    Verify RRCSetup  target_cell=${target_cell}    cause=${cause}  action=reestablish target=${TGT_GNB}:${target_cell} cause=0 crnti=source

    # RRC_REESTAB_RECONF_FAILURE
    ${target_cell_counters}       Set Variable If  '${target_cell}' == '${PREP_CELL}'
    ...                                            ${RRC_REESTAB_FAIL_PREP_CELL}       ${RRC_REESTAB_FAIL_TARGET_CELL}
    @{cu_counters}       Create List               M55124C00503  M55124C00502  M55124C00520  M55124C00515  M55124C00501
    FOR  ${counter}  IN  @{cu_counters}
         ${index}=       Get Index From List       ${target_cell_counters}                ${counter}
         Set List Value                            ${target_cell_counters}                ${index+2}      1
    END

    @{du_counters}       Create List               M55127C00501
    FOR  ${counter}  IN  @{du_counters}
         ${index}=       Get Index From List       ${RRC_REESTAB_FAIL_TARGET_DU}          ${counter}
         Set List Value                            ${RRC_REESTAB_FAIL_TARGET_DU}          ${index+2}      1
    END

    ${counter_value}     Set Variable If           '${target_cell}' == '${PREP_CELL}'     2  0
    ${index}=            Get Index From List       ${RRC_REESTAB_FAIL_PREP_CELL_PMQAP}    M55163C00530
    Set List Value                                 ${RRC_REESTAB_FAIL_PREP_CELL_PMQAP}    ${index+2}      ${counter_value}
    ${index}=            Get Index From List       ${RRC_REESTAB_FAIL_PREP_CELL_NG_FLOW}  M55125C09023
    Set List Value                                 ${RRC_REESTAB_FAIL_PREP_CELL_NG_FLOW}  ${index+2}      ${counter_value}
    ${counter_value}     Set Variable If           '${target_cell}' == '${PREP_CELL}'     1  0
    ${index}=            Get Index From List       ${RRC_REESTAB_FAIL_PREP_CELL_NG_FLOW}  M55125C09531
    Set List Value                                 ${RRC_REESTAB_FAIL_PREP_CELL_NG_FLOW}  ${index+2}      ${counter_value}

    Common Counter Verification   target_cell=${target_cell}
    Verify PCMD Trace             cause=${cause}

Common Counter Verification
    [Arguments]     ${target_cell}=${TGT_CELL}
    ${lcid}               Set Variable If  '${target_cell}' == '${PREP_CELL}'         ${2}  ${1}
    ${pmqap_ref_table}    Set Variable If  '${target_cell}' == '${PREP_CELL}'
    ...                                     ${RRC_REESTAB_FAIL_PREP_CELL_PMQAP}       ${RRC_REESTAB_FAIL_TARGET_CELL_PMQAP}
    ${ng_flow_ref_table}  Set Variable If  '${target_cell}' == '${PREP_CELL}'
    ...                                     ${RRC_REESTAB_FAIL_PREP_CELL_NG_FLOW}     ${RRC_REESTAB_FAIL_TARGET_CELL_NG_FLOW}

    ${pm_files_src}  ${pm_files_tgt}                                 Collect PM counters from both gNBs
    Verify PM Counter Reference Table
    ...       reference_table=${Source_Counters}                     pm_dir=${pm_files_src}   distname_suffix=NRBTS-1/NRCELL-1

    Verify PM Counter Reference Table
    ...       reference_table=${RRC_REESTAB_FAIL_TARGET_CELL}        pm_dir=${pm_files_tgt}   distname_suffix=NRBTS-2/NRCELL-1
    Verify PM Counter Reference Table
    ...       reference_table=${RRC_REESTAB_FAIL_PREP_CELL}          pm_dir=${pm_files_tgt}   distname_suffix=NRBTS-2/NRCELL-2

    Verify PM Counter Reference Table
    ...       reference_table=${pmqap_ref_table}                     pm_dir=${pm_files_tgt}   distname_suffix=NRCELL-${lcid}/PLMN-PLMN/NRPMQAP-1
    Verify PM Counter Reference Table
    ...       reference_table=${ng_flow_ref_table}                   pm_dir=${pm_files_tgt}   distname_suffix=NRBTS-2/NRCELL-${lcid}

    Verify PM Counter Reference Table
    ...       reference_table=${RRC_REESTAB_FAIL_TARGET_DU}          pm_dir=${pm_files_tgt}   distname_suffix=NRBTS-2/NRDU-1

B6 Verification
    [Arguments]     ${target_cell}=${TGT_CELL}  ${cause}=handoverFailure

    Verify RRCSetup                        target_cell=${target_cell}    cause=${cause}

    # RRC_REESTAB_HO_FAILURE_CU + NG_HO_FAIL_TIME_EXP_TRG
    ${target_cell_counters}    Set Variable If    '${target_cell}' == '${PREP_CELL}'   ${RRC_REESTAB_FAIL_PREP_CELL}   ${RRC_REESTAB_FAIL_TARGET_CELL}
    ${cause_counter}           Set Variable If    '${cause}' == 'handoverFailure'      M55124C00504                    M55124C00505
    @{cu_counters}             Create List        M55124C00502  M55124C00515  ${cause_counter}  M55124C00501
    FOR  ${counter}  IN  @{cu_counters}
         ${index}=       Get Index From List      ${target_cell_counters}  ${counter}
         Set List Value  ${target_cell_counters}  ${index+2}               1
    END
    Set Counter Value        ${RRC_REESTAB_FAIL_TARGET_CELL}   NG_HO_FAIL_TIME_EXP_TRG             1
    Common Counter Verification                   target_cell=${target_cell}
    Verify PCMD Trace                             cause=${cause}

Verify PCMD Trace
    [Arguments]    ${cause}=reconfigurationFailure
    ${tce_trc_cu}  ${tce_trc_du}                        Stop TCE tracing

    ${tce_trc_src_cu}   Convert nsetapx trace to PDML   pcap_file=${tce_trc_cu}       pdml_file=trc-src-gnb-cu   filter=ip.addr==10.0.1.2
    Verify PCMD Trace of UE call in source gNB-CU-CP    ${tce_trc_src_cu}
    ${tce_trc_src_du}   Convert nsetapx trace to PDML   pcap_file=${tce_trc_du}       pdml_file=trc-src-gnb-du   filter=ip.addr==10.0.1.2
    ...                                                 port=${TCE_PORT_NUMBER_DU}
    Verify PCMD Trace of UE call in source gNB-DU       ${tce_trc_src_du}

    ${traceRecordingSessionRefsCU}                          Get TraceRecordingSessionRef  ${tce_trc_cu}
    FOR  ${trcRecSesRefCU}  IN  @{traceRecordingSessionRefsCU}
        ${tce_trc_tgt_cu}   Convert nsetapx trace to PDML   pcap_file=${tce_trc_cu}
        ...                 pdml_file=trc-tgt-gnb-cu-${trcRecSesRefCU}
        ...                 filter=ip.addr==10.0.1.3&&nsetapx.traceRecordingSessionRef==${trcRecSesRefCU}
        ${handover}         Run Keyword and Return Status   Verify PCMD Trace of Handover in target gNB-CU-CP   ${tce_trc_tgt_cu}
        ${rrcsetup}         Run Keyword and Return Status   Verify PCMD Trace of RrcSetup in target gNB-CU-CP   ${tce_trc_tgt_cu}  ${cause}
        Should be True      ${handover} or ${rrcsetup}
    END

    ${traceRecordingSessionRefsDU}                          Get TraceRecordingSessionRef  ${tce_trc_du}  filter=ip.addr==10.0.1.3
    FOR  ${trcRecSesRefDU}  IN  @{traceRecordingSessionRefsDU}
        ${tce_trc_tgt_du}   Convert nsetapx trace to PDML   pcap_file=${tce_trc_du}       pdml_file=trc-tgt-gnb-du  port=${TCE_PORT_NUMBER_DU}
        ...                 pdml_file=trc-tgt-gnb-cu-${trcRecSesRefDU}
        ...                 filter=ip.addr==10.0.1.3&&nsetapx.traceRecordingSessionRef==${trcRecSesRefDU}
        ${handover}         Run Keyword and Return Status   Verify PCMD Trace of Handover in target gNB-DU   ${tce_trc_tgt_du}
        ${rrcsetup}         Run Keyword and Return Status   Verify PCMD Trace of RrcSetup in target gNB-DU   ${tce_trc_tgt_du}  ${cause}
        Should be True      ${handover} or ${rrcsetup}
    END

Convert nsetapx trace to PDML
    [Arguments]  ${pcap_file}  ${filter}=nsetapx  ${port}=${TCE_PORT_NUMBER}  ${pdml_file}=None
    ${pcap.folder}  ${pcap.filename}  String.Split String From Right    ${pcap_file}        separator=/    max_split=1
    ${filename}     ${extension}      String.Split String From Right    ${pcap.filename}    separator=.    max_split=1
    OperatingSystem.Run
    ...    tshark -o ntrstr.defragment:TRUE -o ntrstr.port:${port} -T pdml -Y '${filter}' -n -V -r ${pcap_file} > ${pcap.folder}/${pdml_file}.pdml
    RETURN  ${pcap.folder}/${pdml_file}.pdml

Get TraceRecordingSessionRef
    [Arguments]  ${tce_pcap_file}  ${filter}=ip.addr==10.0.1.3  ${port}=${TCE_PORT_NUMBER}
    ${tce_pdml_file}               Convert nsetapx trace to PDML   pcap_file=${tce_pcap_file}     filter=${filter}   port=${port}
    ${traceRecordingSessionRefs}   Grep File                       ${tce_pdml_file}               nsetapx.traceRecordingSessionRef
    ${traceRecordingSessionRefs}   Get Regexp Matches              ${traceRecordingSessionRefs}   .*show="(\[0-9a-f\]{2}:\[0-9a-f\]{2})".*  1
    ${traceRecordingSessionRefs}   Remove Duplicates               ${traceRecordingSessionRefs}
    RETURN  ${traceRecordingSessionRefs}

verify PCMD Trace of UE call in source gNB-CU-CP
    [Arguments]  ${pcmd_file}
    @{pattern_list}=         Create List
    ...                      CuVendorExtensionRecordDataType: ngHoSrcRecord
    ...                      result: miscFailure
    ...                      stopRecordingSession
    Verify Sequence in File  ${pcmd_file}  @{pattern_list}

Verify PCMD Trace of UE call in source gNB-DU
    [Arguments]  ${pcmd_file}
    @{pattern_list}=         Create List
    ...                      stopRecordingSession
    Verify Sequence in File  ${pcmd_file}  @{pattern_list}

Verify PCMD Trace of Handover in target gNB-CU-CP
    [Arguments]  ${pcmd_file}
    @{pattern_list}=         Create List
    ...                      startRecordingSession
    ...                      CuVendorExtensionRecordDataType: pduSessionResourceInfoRecord
    ...                      trigger: handover
    ...                      result: miscFailure
    ...                      CuVendorExtensionRecordDataType: ueSetupRecord
    ...                      result: miscFailure
    ...                      trigger: other
    ...                      CuVendorExtensionRecordDataType: ngHoTgtRecord
    ...                      result: miscFailure
    ...                      stopRecordingSession
    Verify Sequence in File  ${pcmd_file}  @{pattern_list}

Verify PCMD Trace of Handover in target gNB-DU
    [Arguments]  ${pcmd_file}
    @{pattern_list}=         Create List
    ...                      startRecordingSession
    ...                      DlRadioBearerRlcMeasData
    ...                      endMarker: True
    ...                      DlRadioBearerRlcMeasData
    ...                      endMarker: True
    ...                      UlRadioBearerRlcMeasData
    ...                      endMarker: True
    ...                      UlRadioBearerRlcMeasData
    ...                      endMarker: True
    ...                      stopRecordingSession
    Verify Sequence in File  ${pcmd_file}  @{pattern_list}
    @{pattern_list}=         Create List
    ...                      startRecordingSession
    ...                      DuVendorExtensionRecordDataType: ulSchedulingRecord
    ...                      endMarker: True
    ...                      stopRecordingSession
    Verify Sequence in File  ${pcmd_file}  @{pattern_list}
    @{pattern_list}=         Create List
    ...                      startRecordingSession
    ...                      DuVendorExtensionRecordDataType: dlSchedulingRecord
    ...                      endMarker: True
    ...                      stopRecordingSession
    Verify Sequence in File  ${pcmd_file}  @{pattern_list}

Verify PCMD Trace of RrcSetup in target gNB-CU-CP
    [Arguments]  ${pcmd_file}  ${cause}=reconfigurationFailure
    @{pattern_list}=         Create List
    ...                      startRecordingSession
    ...                      CuVendorExtensionRecordDataType: ueDuConnectivityRecord
    ...                      initialUeRrcMessageTransferRcvTime
    ...                      seconds: \[1-9\]\\d+
    ...                      CuVendorExtensionRecordDataType: rrcSetupRecord
    ...                      reestablishmentCause: ${cause}
    ...                      CuVendorExtensionRecordDataType: ueSetupRecord
    ...                      result: success
    ...                      trigger: rrcReestFallbackToRrcSetup
    ...                      CuVendorExtensionRecordDataType: ueDuConnectivityRecord
    ...                      DuUeCtxSetupData
    ...                      result: success
    ...                      ueCtxSetupReqSndTime
    ...                      ueCtxSetupCmplRcvTime
    ...                      CuVendorExtensionRecordDataType: pduSessionResourceInfoRecord
    ...                      trigger: initialCtxSetup
    ...                      result: success
    Verify Sequence in File  ${pcmd_file}  @{pattern_list}

Verify PCMD Trace of RrcSetup in target gNB-DU
    [Arguments]  ${pcmd_file}   ${cause}=reconfigurationFailure
    @{pattern_list}=         Create List
    ...                      startRecordingSession
    ...                      DuVendorExtensionRecordDataType: ueCtxSetupRecord
    ...                      initialUeRrcMessageTransferSndTime
    ...                      DuVendorExtensionRecordDataType: rrcSetupRecord
    ...                      reestablishmentCause: ${cause}
    ...                      DuVendorExtensionRecordDataType: ueCtxSetupRecord
    ...                      ueCtxSetupReqRcvTime
    ...                      ueCtxSetupCmplSndTime
    ...                      DuVendorExtensionRecordDataType: bearerRecord
    ...                      DuVendorExtensionRecordDataType: dlRbRlcMeasRecord
    ...                      DuVendorExtensionRecordDataType: ulRbRlcMeasRecord
    Verify Sequence in File  ${pcmd_file}  @{pattern_list}
    @{pattern_list}=         Create List
    ...                      startRecordingSession
    ...                      DuVendorExtensionRecordDataType: timingAdvanceRecord
    Verify Sequence in File  ${pcmd_file}  @{pattern_list}

Verify FullConfig
    [Arguments]    ${target_cell}=${TGT_CELL}
    @{cfg_vals}=   Create List
    ...            Received Handover Required from GNB-${SIM_GNB}
    ...            Received Handover Request Acknowledge
    ...            rrcReconfiguration
    ...            fullConfig true
    ...            Hit on error cases presence=any action=reestablish target=${TGT_GNB}:${target_cell} cause=1 crnti=source
    ...            rrcReestablishmentRequest
    ...            reestablishmentCause handoverFailure
    ...            rrcSetup
    ...            rrcSetupComplete
    ...            T_NG_RELOC_Overall Timeout. UE Context Release Requested
    ...            1\\s+INT\\s+ACTIVE\\s+<inactive>\\s+<inactive>\\s+${TGT_GNB}.${target_cell}
    Send Egate Command and verify output     cmd=ue_disp                   pass_regexp=Configured UEs
    Send Egate Command and verify output     set_log flush
    Verify sequence in file  ${EGATE_CONSOLE_LOG}  @{cfg_vals}

Verify RRCSetup
    [Arguments]    ${target_cell}=${TGT_CELL}  ${src_gnb}=${SRC_GNB}  ${cause}=reconfigurationFailure  ${action}=drop
    @{cfg_vals}=   Create List
    ...            Received Handover Required from GNB-${SRC_GNB}
    ...            Received Handover Request Acknowledge
    ...            rrcReconfiguration
    ...            Hit on error cases presence=any action=${action}
    ...            rrcReestablishmentRequest
    ...            reestablishmentCause ${cause}
    ...            rrcSetup
    ...            rrcSetupComplete
    ...            UE CONTEXT RELEASE REQUEST: gNB=${SRC_GNB}
    ...            1\\s+INT\\s+ACTIVE\\s+<inactive>\\s+<inactive>\\s+${TGT_GNB}.${target_cell}
    Send Egate Command and verify output     cmd=ue_disp                   pass_regexp=Configured UEs
    Send Egate Command and verify output     set_log flush
    Verify sequence in file  ${EGATE_CONSOLE_LOG}  @{cfg_vals}

Set maxNumOfNonGBRBearersSA
    [Arguments]    ${gnb_id}    ${cell_id}    ${value}
    ${current_scf}=           Load current SCF   gnb_id=${gnb_id}
    Set Element               dist_name=MRBTS-1/NRBTS-${gnb_id+1}/NRCELL-${cell_id}    p_name=maxNumOfNonGBRBearersSA    value=${value}
    Apply Delta SCF           ${current_scf}  maxNumOfNonGBRBearersSA_${value}    gnb_id=${gnb_id}

Set trackingAreaDN in prepared cell
    [Arguments]    ${value}
    ${current_scf}=           Load current SCF   gnb_id=1
    Set Element               dist_name=MRBTS-1/NRBTS-2/NRCELL-2/NRPLMNSET_SA-1  p_name=trackingAreaDN  value=MRBTS-1/NRBTS-2/${value}
    Apply Delta SCF           ${current_scf}  trackingAreaDN_${value}    gnb_id=1

Test Setup for EC4_2
    [Documentation]  remove NRPLMNSET_SA-1 and bring TL on air
    Wait For Minimum Required State For Cell Setup for all gNBs
    ${current_scf}=           Load current SCF   gnb_id=1
    Remove Object             dist_name=MRBTS-1/NRBTS-2/NRCELL-2/NRPLMNSET_SA-1
    Apply Delta SCF           ${current_scf}  remove_NRPLMNSET_SA_1    gnb_id=1
    Bring Up TL for CB008574
    Start Logging                          pmcounter_enabled=${FALSE}
    get resources taken before_test
    Wait until the next Measurement Period starts

Test Teardown for EC4_2
    Perform Postconditions of Test Scenario
    ${current_scf}=             Load current SCF   gnb_id=1
    ${nrPlmnDNList}=            Create List                   MRBTS-1/NRBTS-2/NRPLMN-1
    Add NRPLMNSET_SA to cell    dist_name=MRBTS-1/NRBTS-2/NRCELL-2/NRPLMNSET_SA-1
    ...                         trackingAreaDN=MRBTS-1/NRBTS-2/TRACKINGAREA-200    nrPlmnDNList=${nrPlmnDNList}
    Apply Delta SCF             ${current_scf}  add_back_NRPLMNSET_SA_1  gnb_id=1

Test Setup for EC4_3
    [Documentation]  to use SNSSAI-2 on and bring TL on air
    Wait For Minimum Required State For Cell Setup for all gNBs
    Set trackingAreaDN in prepared cell    value=TRACKINGAREA-100
    Bring Up TL for CB008574
    Start Logging                          pmcounter_enabled=${FALSE}
    get resources taken before_test
    Wait until the next Measurement Period starts

Test Teardown for EC4_3
    Perform Postconditions of Test Scenario
    Set trackingAreaDN in prepared cell    value=TRACKINGAREA-200

Disable Prepared Cell
    [Arguments]               ${gnb_id}=${0}    ${cell_id}=${SRC_CELL}
    ${current_scf}=           Load current SCF   gnb_id=${gnb_id}
    Set Element               dist_name=NRBTS-${gnb_id+1}/NRCELL-${cell_id}/NRREL-3    p_name=handoverAllowedSA    value=forbidden
    Apply Delta SCF           ${current_scf}  disable_prepared_cell    gnb_id=${gnb_id}

Enable Prepared Cell
    [Arguments]               ${gnb_id}=${0}    ${cell_id}=${SRC_CELL}
    IF    ${TGT_NODE} == ${gnb_id}   RETURN
    ${current_scf}=           Load current SCF   gnb_id=${gnb_id}
    Set Element               dist_name=NRBTS-${gnb_id+1}/NRCELL-${cell_id}/NRREL-3    p_name=handoverAllowedSA    value=XnHoNotAllowed
    Apply Delta SCF           ${current_scf}  enable_prepared_cell    gnb_id=${gnb_id}

Save Counter Reference Tables
    ${RRC_REESTAB_FAIL_TARGET_CELL_sav}           Copy List   ${RRC_REESTAB_FAIL_TARGET_CELL}
    Set Suite Variable                            ${RRC_REESTAB_FAIL_TARGET_CELL_sav}
    ${RRC_REESTAB_FAIL_PREP_CELL_sav}             Copy List   ${RRC_REESTAB_FAIL_PREP_CELL}
    Set Suite Variable                            ${RRC_REESTAB_FAIL_PREP_CELL_sav}

    ${RRC_REESTAB_FAIL_TARGET_CELL_PMQAP_sav}     Copy List   ${RRC_REESTAB_FAIL_TARGET_CELL_PMQAP}
    Set Suite Variable                            ${RRC_REESTAB_FAIL_TARGET_CELL_PMQAP_sav}
    ${RRC_REESTAB_FAIL_PREP_CELL_PMQAP_sav}       Copy List   ${RRC_REESTAB_FAIL_PREP_CELL_PMQAP}
    Set Suite Variable                            ${RRC_REESTAB_FAIL_PREP_CELL_PMQAP_sav}

    ${RRC_REESTAB_FAIL_TARGET_CELL_NG_FLOW_sav}   Copy List   ${RRC_REESTAB_FAIL_TARGET_CELL_NG_FLOW}
    Set Suite Variable                            ${RRC_REESTAB_FAIL_TARGET_CELL_NG_FLOW_sav}
    ${RRC_REESTAB_FAIL_PREP_CELL_NG_FLOW_sav}     Copy List   ${RRC_REESTAB_FAIL_PREP_CELL_NG_FLOW}
    Set Suite Variable                            ${RRC_REESTAB_FAIL_PREP_CELL_NG_FLOW_sav}

    ${RRC_REESTAB_FAIL_TARGET_DU_sav}             Copy List   ${RRC_REESTAB_FAIL_TARGET_DU}
    Set Suite Variable                            ${RRC_REESTAB_FAIL_TARGET_DU_sav}

Restore Counter Reference Tables
    ${RRC_REESTAB_FAIL_TARGET_CELL}           Copy List   ${RRC_REESTAB_FAIL_TARGET_CELL_sav}
    Set Suite Variable                        ${RRC_REESTAB_FAIL_TARGET_CELL}
    ${RRC_REESTAB_FAIL_PREP_CELL}             Copy List   ${RRC_REESTAB_FAIL_PREP_CELL_sav}
    Set Suite Variable                        ${RRC_REESTAB_FAIL_PREP_CELL}

    ${RRC_REESTAB_FAIL_TARGET_CELL_PMQAP}     Copy List   ${RRC_REESTAB_FAIL_TARGET_CELL_PMQAP_sav}
    Set Suite Variable                        ${RRC_REESTAB_FAIL_TARGET_CELL_PMQAP}
    ${RRC_REESTAB_FAIL_PREP_CELL_PMQAP}       Copy List   ${RRC_REESTAB_FAIL_PREP_CELL_PMQAP_sav}
    Set Suite Variable                        ${RRC_REESTAB_FAIL_PREP_CELL_PMQAP}

    ${RRC_REESTAB_FAIL_TARGET_CELL_NG_FLOW}   Copy List   ${RRC_REESTAB_FAIL_TARGET_CELL_NG_FLOW_sav}
    Set Suite Variable                        ${RRC_REESTAB_FAIL_TARGET_CELL_NG_FLOW}
    ${RRC_REESTAB_FAIL_PREP_CELL_NG_FLOW}     Copy List   ${RRC_REESTAB_FAIL_PREP_CELL_NG_FLOW_sav}
    Set Suite Variable                        ${RRC_REESTAB_FAIL_PREP_CELL_NG_FLOW}

    ${RRC_REESTAB_FAIL_TARGET_DU}             Copy List   ${RRC_REESTAB_FAIL_TARGET_DU_sav}
    Set Suite Variable                        ${RRC_REESTAB_FAIL_TARGET_DU}

Disable SecurityConfig
    [Arguments]  ${ue}=1  ${gnb}=${SIM_GNB}
    Send Egate Command and verify output
    ...        cmd=ue_gnb_ho_param id=${ue} gnb=${gnb} include_security_config=off
    ...        fail_regexp=include_security_config

Disable Integrity Protection on target gNB
    [Arguments]    ${gnb_id}=${1}
    ${current_scf}=           Load current SCF   gnb_id=${gnb_id}
    ${dist_name}=  Set Variable  MRBTS-1/NRBTS-${gnb_id+1}
    ${list_name}=  Set variable  integrityProtPrefL
    Remove List From SCF  dist_name=${dist_name}  list_name=${list_name}
    ${list_elements}=  Create dictionary   nia0      0
    ...                                    nia1_128  9
    ...                                    nia2_128  0
    ...                                    nia3_128  0
    scf.add_list_to_scf   dist_name=${dist_name}  list_name=${list_name}
    scf.add_item_to_list  dist_name=${dist_name}  list_name=${list_name}  elements=${list_elements}
    Apply Delta SCF           ${current_scf}  disableintegrityprotextion  gnb_id=${gnb_id}

Disable Ciphering on target gNB
    [Arguments]    ${gnb_id}=${1}
    ${current_scf}=           Load current SCF   gnb_id=${gnb_id}
    ${dist_name}=  Set Variable  MRBTS-1/NRBTS-${gnb_id+1}
    ${list_name}=  Set variable  cipherPrefL
    Remove List From SCF  dist_name=${dist_name}  list_name=${list_name}
    ${list_elements}=  Create dictionary   nea0      0
    ...                                    nea1_128  9
    ...                                    nea2_128  0
    ...                                    nea3_128  0
    scf.add_list_to_scf   dist_name=${dist_name}  list_name=${list_name}
    scf.add_item_to_list  dist_name=${dist_name}  list_name=${list_name}  elements=${list_elements}

    Apply Delta SCF           ${current_scf}  disableciphering  gnb_id=${gnb_id}

Setup for CB008574_B_B9
    [Arguments]  ${instance}=${none}
    ${target_dir}=        testline.Get Testcase Log Directory
    ${curr_gnb_scf}       Load current SCF  gnb_id=1  scf_name=before.xml
    Set Suite Variable    ${saved_scf}   ${curr_gnb_scf}
    IF    '${instance}'=='1'   Disable Integrity Protection on target gNB  gnb_id=1
    ...    ELSE                Disable Ciphering on target gNB  gnb_id=1
    Perform Precondition of Test Scenario

Teardown for CB008574_B_B9
    ${current_scf}=       Load current SCF   gnb_id=1  scf_name=after.xml
    scf.load_scf  ${saved_scf}
    Apply Delta SCF  ${current_scf}  restoreoriginal  gnb_id=1
    Perform Postconditions of Test Scenario

Include NewSecurityContextInd
    [Arguments]  ${ue}=1
    Send Egate Command and verify output
    ...        cmd=amf_ue_ng_handover_request_param id=${ue} include_new_sec_ctx_ind=on
    Send Egate Command and verify output
    ...        cmd=amf_ue_ng_handover_request_param id=${ue}
    ...        pass_regexp=include_new_sec_ctx_ind
