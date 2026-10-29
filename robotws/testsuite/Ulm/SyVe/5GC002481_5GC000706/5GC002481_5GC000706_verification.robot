*** Settings ***
Documentation   Robot Test Suite for feature '5GC002481-CIAB-SyVe Test Only for 5GC000706 Inter-frequency handover via Xn (SA option 2)' \n
...             Team: 'MN 5G&SC PZ ULM 2 SqdGp63' \n
...             Email: 'I_MN_5GSC_PZ_ULM_SQD_63@nokia.com' \n
#-----------------------------------------------------------------------------------------------------------------------------------[150 characters]
Resource    ../../resources/Common/testline.robot
Resource    ../../resources/Common/gnb.robot
Resource    ../../resources/Common/tcpdump.robot
Resource    ../../resources/Common/btslog.robot
Resource    ../../resources/Common/connect.robot
Resource    ../../resources/Common/coam_ulm.robot
Resource    ../../resources/Common/snapshot.robot
Resource    ../../resources/Common/log_collection.robot
Resource    ../../resources/Common/util.robot
Resource    ../resources/attenuator_scenario.robot
Library    taf.hw.rf_attenuator      WITH NAME    attenuator
Library    taf.ue
Library    taf.ul.messaging.mtk      WITH NAME    mtk
Library    5GC000706.py
Library    ute_tshark


*** Keywords ***
Convert PCAP2PDML
    util.Convert PCAP To PDML    source=${resultTestDir}/gnb${gnb_id_source}_master/Xn_traces_gnb${gnb_id_source}_master.pcap
    ...     target=${resultTestDir}/Xn_traces_gnb${gnb_id_source}_master.pdml
    util.Convert PCAP To PDML    source=${resultTestDir}/gnb${gnb_id_target}_master/Xn_traces_gnb${gnb_id_target}_master.pcap
    ...     target=${resultTestDir}/Xn_traces_gnb${gnb_id_target}_master.pdml
    IF  'INTER' in ${TEST TAGS}
        ${XNAP}=  tcpdump.Get XNAP Protocol Version  ${tcp_file_gnb_target_master}
        Set Suite Variable  ${XNAP}  ${XNAP}
    END


Check ReconfigurationWithSync
    [Arguments]    ${tcp_file}    ${physCell1}    ${physCell2}
    ${output}    ute_tshark.Read PCAP    packet_filter=nokiaf1ap.procedureCode == 7    output_type=pdml    pcap_file_path=${tcp_file}
    ${spCell}    Get Elements    ${output}    .//field[@name='nr-rrc.spCellConfigCommon_element']//field[@name='nr-rrc.physCellId']
    FOR  ${i}  IN   @{spCell}
        ${showname}  Get Element Attribute  ${i}  showname
        ${showcell}  Get Element Attribute  ${i}  show
        Log To Console  reconfigurationWithSync: ${showname}
        Should Contain Any  ${showcell}  ${physCell1}  ${physCell2}
    END

Check Wireshark For RRCReconfiguration
    [Arguments]    ${physCell}  ${tcp_file}
    ${output}    ute_tshark.Read PCAP    packet_filter=nokiaf1ap.procedureCode == 12    output_type=pdml    pcap_file_path=${tcp_file}
    ${physCellId}    Get Element    ${output}    .//field[@name='nr-rrc.spCellConfigCommon_element']//field[@name='nr-rrc.physCellId']
    ${showname}  Get Element Attribute  ${physCellId}  showname
    Should Contain  ${showname}  ${physCell}


Check Wireshark For a3_Offset
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.Read PCAP    packet_filter=nokiaf1ap.procedureCode == 12    output_type=pdml    pcap_file_path=${tcp_file}
    ${a3_Offset}    Get Elements    ${output}    .//field[@name='nr-rrc.eventTriggered_element']//field[@name='nr-rrc.a3_Offset']
    FOR  ${i}  IN   @{a3_Offset}
        ${showname}  Get Element Attribute  ${i}  showname
        Log To Console  ${showname}
        Should Contain    ${showname}  rsrp
    END


Check Wireshark For ssb_RSRP
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.Read PCAP    packet_filter=nokiaf1ap.procedureCode == 12    output_type=pdml    pcap_file_path=${tcp_file}
    ${ssb_RSRP}    Get Elements    ${output}    .//field[@name='nr-rrc.s_MeasureConfig']//field[@name='nr-rrc.ssb_RSRP']
    FOR  ${i}  IN   @{ssb_RSRP}
        ${showname}  Get Element Attribute  ${i}  showname
        Log To Console  ${showname}
        Should Contain    ${showname}  1
    END

Check Wireshark For mcs_Table
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.Read PCAP    packet_filter=nokiaf1ap.procedureCode == 12    output_type=pdml    pcap_file_path=${tcp_file}
    ${mcs_Table}    Get Elements    ${output}    .//field[@name='nr-rrc.setup_element']//field[@name='nr-rrc.mcs_Table']
    FOR  ${i}  IN   @{mcs_Table}
        ${showname}  Get Element Attribute  ${i}  showname
        Log To Console  ${showname}
        Should Contain    ${showname}  qam256
    END

Check Wireshark For cfra_element
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.Read PCAP    packet_filter=nokiaf1ap.procedureCode == 12    output_type=pdml    pcap_file_path=${tcp_file}
    ${cfra_element}    Get Elements    ${output}    .//field[@name='nr-rrc.uplink_element']//field[@name='nr-rrc.cfra_element']
    FOR  ${i}  IN   @{cfra_element}
        ${showname}  Get Element Attribute  ${i}  showname
        Log To Console  ${showname}
        Should Contain    ${showname}  cfra
    END

Check RRC Complete Message
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.Read PCAP    packet_filter=nokiaf1ap.procedureCode == 13    output_type=pdml    pcap_file_path=${tcp_file}
    ${rrc}  Get Element Count  ${output}  .//field[@name='nr-rrc.rrcReconfigurationComplete_element']//field[@showname='rrcReconfigurationComplete']
    Should Be True  ${rrc} >= 1

Check HandoverRequest cause
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.read pcap    packet_filter=${XNAP}.procedureCode == 0    output_type=pdml    pcap_file_path=${tcp_file}
    ${cause}  Get Elements  ${output}  .//field[@name='${XNAP}.HandoverRequest_element']//field[@name='${XNAP}.Cause']
    FOR  ${i}  IN   @{cause}
        ${showname}  Get Element Attribute  ${i}  showname
        Log To Console  Handover Request: ${showname}
        Should Contain    ${showname}  radioNetwork
    END

Check HandoverRequest radioNetwork
    [Arguments]    ${tcp_file}
    ${output}  ute_tshark.read pcap  packet_filter=${XNAP}.procedureCode == 0  output_type=pdml  pcap_file_path=${tcp_file}
    ${radioNetwork}    Get Elements    ${output}  .//field[@name='${XNAP}.HandoverRequest_element']//field[@name='${XNAP}.radioNetwork']
    FOR  ${i}  IN   @{radioNetwork}
        ${showname}  Get Element Attribute  ${i}  showname
        Log To Console  Handover Request: ${showname}
        Should Contain    ${showname}  handover-desirable-for-radio-reasons
    END

Check HandoverAcknowledge
    [Arguments]    ${tcp_file}
    ${output}  ute_tshark.read pcap  packet_filter=${XNAP}.procedureCode == 0  output_type=pdml  pcap_file_path=${tcp_file}
    ${releasecomplete}  Get Element Count
    ...    ${output}  .//field[@name='${XNAP}.successfulOutcome_element']//field[@showname='HandoverRequestAcknowledge']
    Should Be True  ${releasecomplete} > ${0}

Check rrcRelease
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.Read PCAP    packet_filter=nokiaf1ap.procedureCode == 6    output_type=pdml    pcap_file_path=${tcp_file}
    ${rrcRelease}    Get Element Count    ${output}    .//field[@name='nr-rrc.rrcRelease_element']
    Should Be True  ${rrcRelease} > ${0}

Check MeasGapSetup
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.read pcap    packet_filter=nokiaf1ap.procedureCode == 12    output_type=pdml    pcap_file_path=${tcp_file}
    ${measGapConfig}    Get Elements    ${output}    .//field[@name='nr-rrc.MeasGapConfig_element']//field[@name='nr-rrc.gapUE']
    FOR  ${i}  IN   @{measGapConfig}
        ${showname}  Get Element Attribute  ${i}  showname
        Log To Console  ${showname}
        Should Contain    ${showname}  gapUE: setup
    END

Check MeasGapRelease
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.Read PCAP    packet_filter=nokiaf1ap.procedureCode == 12    output_type=pdml    pcap_file_path=${tcp_file}
    ${measGapConfig}    Get Elements    ${output}    .//field[@name='nr-rrc.MeasGapConfig_element']//field[@name='nr-rrc.gapUE']
    FOR  ${i}  IN   @{measGapConfig}
        ${showname}  Get Element Attribute  ${i}  showname
        Log To Console  ${showname}
        Should Contain    ${showname}  gapUE: release
    END

Check DrxConfig
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.Read PCAP    packet_filter=nokiaf1ap.procedureCode == 7    output_type=pdml    pcap_file_path=${tcp_file}
    ${drxConfig}    Get Elements    ${output}    .//field[@name='nr-rrc.mac_CellGroupConfig_element']//field[@name='nr-rrc.drx_Config']
    FOR  ${i}  IN   @{drxConfig}
        ${showname}  Get Element Attribute  ${i}  showname
        Log To Console    ${showname}
        IF    ('setup' in '${showname}')    Check DRXElements   ${i}
    END

Check DRXElements
    [Arguments]    ${i}
    ${drx_onDurationTimer}  Get Element Count  ${i}  .//field[@name='nr-rrc.setup_element']//field[@name='nr-rrc.drx_onDurationTimer']
    Should Be True  ${drx_onDurationTimer} > ${0}
    ${rdrx_InactivityTimer}  Get Element Count  ${i}  .//field[@name='nr-rrc.setup_element']//field[@name='nr-rrc.drx_InactivityTimer']
    Should Be True  ${rdrx_InactivityTimer} > ${0}
    ${drx_HARQ_RTT_TimerDL}  Get Element Count  ${i}  .//field[@name='nr-rrc.setup_element']//field[@name='nr-rrc.drx_HARQ_RTT_TimerDL']
    Should Be True  ${drx_HARQ_RTT_TimerDL} > ${0}
    ${drx_HARQ_RTT_TimerUL}  Get Element Count  ${i}  .//field[@name='nr-rrc.setup_element']//field[@name='nr-rrc.drx_HARQ_RTT_TimerUL']
    Should Be True  ${drx_HARQ_RTT_TimerUL} > ${0}
    ${drx_RetransmissionTimerDL}  Get Element Count  ${i}  .//field[@name='nr-rrc.setup_element']//field[@name='nr-rrc.drx_RetransmissionTimerDL']
    Should Be True  ${drx_RetransmissionTimerDL} > ${0}
    ${drx_RetransmissionTimerUL}  Get Element Count  ${i}  .//field[@name='nr-rrc.setup_element']//field[@name='nr-rrc.drx_RetransmissionTimerUL']
    Should Be True  ${drx_RetransmissionTimerUL} > ${0}
    ${drx_LongCycleStartOffset}  Get Element Count  ${i}  .//field[@name='nr-rrc.setup_element']//field[@name='nr-rrc.drx_LongCycleStartOffset']
    Should Be True  ${drx_LongCycleStartOffset} > ${0}
    ${drx_SlotOffset}  Get Element Count    ${i}  .//field[@name='nr-rrc.setup_element']//field[@name='nr-rrc.drx_SlotOffset']
    Should Be True  ${drx_SlotOffset} > ${0}

Check SNSStatusTranfer Message
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.Read PCAP    packet_filter=${XNAP}.procedureCode == 1    output_type=pdml    pcap_file_path=${tcp_file}
    ${SNStatusTransfer}    Get Element Count    ${output}    .//field[@name='${XNAP}.SNStatusTransfer_element']
    Should Be True  ${SNStatusTransfer} > ${0}

Check InitialUEmessage
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.read pcap    packet_filter=ngap.procedureCode == 15    output_type=pdml    pcap_file_path=${tcp_file}
    ${InitialUEmessage}    Get Element Count    ${output}    .//field[@name='ngap.InitialUEMessage_element']
    Should Be True  ${InitialUEmessage} > ${0}

Check InitialContextSetupRequest Message
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.read pcap    packet_filter=ngap.procedureCode == 14    output_type=pdml    pcap_file_path=${tcp_file}
    ${InitialContextSetupRequest}    Get Element Count    ${output}    .//field[@name='ngap.InitialContextSetupRequest_element']
    Should Be True  ${InitialContextSetupRequest} > ${0}

Check InitialContextSetupResponse Message
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.read pcap    packet_filter=ngap.procedureCode == 14    output_type=pdml    pcap_file_path=${tcp_file}
    ${UEContextRelease}    Get Element Count    ${output}    .//field[@name='ngap.InitialContextSetupResponse_element']
    Should Be True  ${UEContextRelease} > ${0}

Check UEContextRelease Message
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.read pcap  packet_filter=${XNAP}.procedureCode == 6  output_type=pdml  pcap_file_path=${tcp_file}
    ${UEContextRelease}    Get Element Count    ${output}    .//field[@name='${XNAP}.UEContextRelease_element']
    Should Be True  ${UEContextRelease} > ${0}

Check UEContextReleaseCommand Message
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.Read PCAP    packet_filter=nokiaf1ap.procedureCode == 6    output_type=pdml    pcap_file_path=${tcp_file}
    ${UEContextReleaseCommand}    Get Element Count    ${output}    .//field[@name='nokiaf1ap.UEContextReleaseCommand_element']
    Should Be True  ${UEContextReleaseCommand} > ${0}

Check Wireshark For RRC reconfiguration - a2HysteresisRedirectSsbRsrp
    [Arguments]   ${tcp_file}
    ${output}    ute_tshark.Read PCAP    packet_filter=nokiaf1ap.procedureCode == 12    output_type=pdml    pcap_file_path=${tcp_file}
    ${hysteresis}    Get Elements    ${output}    .//field[@name='nr-rrc.eventA2_element']//field[@name='nr-rrc.hysteresis']
    Should Not Be Empty  ${hysteresis}
    FOR  ${i}  IN   @{hysteresis}
        ${showname}  Get Element Attribute  ${i}  showname
        IF  '${showname}' == 'hysteresis: 0dB (0)'   BREAK
        Should Contain  ${showname}  (0)
    END


Check Wireshark For RRC reconfiguration - a2MeasRedirectEnabled
    [Arguments]   ${tcp_file}
    ${output}    ute_tshark.Read PCAP    packet_filter=nokiaf1ap.procedureCode == 12    output_type=pdml    pcap_file_path=${tcp_file}
    ${a2_Threshold}    Get Elements    ${output}    .//field[@name='nr-rrc.eventA2_element']//field[@name='nr-rrc.a2_Threshold']
    Should Not Be Empty  ${a2_Threshold}
    FOR  ${i}  IN   @{a2_Threshold}
        ${showname}  Get Element Attribute  ${i}  showname
        IF  '${showname}' == 'a2-Threshold: rsrp (0)'   BREAK
        Should Contain  ${showname}  rsrp
    END

Check Wireshark For RRC reconfiguration - a2TimeToTriggerRedirectSsbRsrp
    [Arguments]   ${tcp_file}
    ${output}    ute_tshark.Read PCAP    packet_filter=nokiaf1ap.procedureCode == 12    output_type=pdml    pcap_file_path=${tcp_file}
    ${timeToTrigger}    Get Elements    ${output}    .//field[@name='nr-rrc.eventA2_element']//field[@name='nr-rrc.timeToTrigger']
    Should Not Be Empty  ${timeToTrigger}
    FOR  ${i}  IN   @{timeToTrigger}
        ${showname}  Get Element Attribute  ${i}  showname
        IF  '${showname}' == 'timeToTrigger: ms128 (5)'   BREAK
        Should Contain  ${showname}  ms128
    END

Check Wireshark For RRC reconfiguration - a2ThresholdRedirectSsbRsrp
    [Arguments]   ${tcp_file}
    ${output}    ute_tshark.Read PCAP    packet_filter=nokiaf1ap.procedureCode == 12    output_type=pdml    pcap_file_path=${tcp_file}
    ${rsrp}    Get Elements    ${output}    .//field[@name='nr-rrc.eventA2_element']//field[@name='nr-rrc.rsrp']
    Should Not Be Empty  ${rsrp}
    FOR  ${i}  IN   @{rsrp}
        ${showname}  Get Element Attribute  ${i}  showname
        IF  '${showname}' == 'rsrp: -92dBm &lt;= SS-RSRP &lt; -91dBm (65)'   BREAK
        Should Contain  ${showname}  (65)
    END

Check UEContextReleaseComplete Message
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.Read PCAP    packet_filter=nokiaf1ap.procedureCode == 6    output_type=pdml    pcap_file_path=${tcp_file}
    ${UEContextReleaseComplete}    Get Element Count    ${output}
    ...    .//field[@showname='successfulOutcome']//field[@name='nokiaf1ap.UEContextReleaseComplete_element']
    Should Be True  ${UEContextReleaseComplete} > ${0}

Check PathSwitchRequest Message
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.read pcap    packet_filter=ngap.procedureCode == 25    output_type=pdml    pcap_file_path=${tcp_file}
    ${PathSwitchRequest}    Get Element Count    ${output}    .//field[@name='ngap.PathSwitchRequest_element']
    Should Be True  ${PathSwitchRequest} > ${0}

Check PathSwitchRequestAck Message
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.read pcap    packet_filter=ngap.procedureCode == 25    output_type=pdml    pcap_file_path=${tcp_file}
    ${PathSwitchRequestAck}  Get Element Count  ${output}
    ...    .//field[@showname='successfulOutcome']//field[@name='ngap.PathSwitchRequestAcknowledge_element']
    Should Be True  ${PathSwitchRequestAck} > ${0}

Check Wireshark For A5 hysteresis
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.Read PCAP    packet_filter=nokiaf1ap.procedureCode == 12    output_type=pdml    pcap_file_path=${tcp_file}
    ${hysteresis}    Get Elements    ${output}    .//field[@name='nr-rrc.eventA5_element']//field[@name='nr-rrc.hysteresis']
    FOR  ${i}  IN   @{hysteresis}
        ${showname}  Get Element Attribute  ${i}  showname
        Log To Console  A5 Hysteresis: ${showname}
        Should Contain    ${showname}  0
    END

Check Wireshark For A5 timeToTrigger
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.Read PCAP    packet_filter=nokiaf1ap.procedureCode == 12    output_type=pdml    pcap_file_path=${tcp_file}
    ${timeToTrigger}    Get Elements    ${output}    .//field[@name='nr-rrc.eventA5_element']//field[@name='nr-rrc.timeToTrigger']
    FOR  ${i}  IN   @{timeToTrigger}
        ${showname}  Get Element Attribute  ${i}  showname
        Log To Console  A5 timeToTrigger: ${showname}
        Should Contain    ${showname}  ms320
    END

Check Wireshark For a5_Threshold1
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.Read PCAP    packet_filter=nokiaf1ap.procedureCode == 12    output_type=pdml    pcap_file_path=${tcp_file}
    ${a5_Threshold1}    Get Elements    ${output}    .//field[@name='nr-rrc.a5_Threshold1']//field[@name='nr-rrc.rsrp']
    FOR  ${i}  IN   @{a5_Threshold1}
        ${showname}  Get Element Attribute  ${i}  showname
        Log To Console  A5 Threshold1: ${showname}
        Should Contain    ${showname}  60
    END

Check Wireshark For a5_Threshold2
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.Read PCAP    packet_filter=nokiaf1ap.procedureCode == 12    output_type=pdml    pcap_file_path=${tcp_file}
    ${a5_Threshold2}    Get Elements    ${output}    .//field[@name='nr-rrc.a5_Threshold2']//field[@name='nr-rrc.rsrp']
    FOR  ${i}  IN   @{a5_Threshold2}
        ${showname}  Get Element Attribute  ${i}  showname
        Log To Console  A5 Threshold2: ${showname}
        Should Contain    ${showname}  70
    END

Check Wireshark For a5_Threshold1 rsrp
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.Read PCAP    packet_filter=nokiaf1ap.procedureCode == 12    output_type=pdml    pcap_file_path=${tcp_file}
    ${rsrp}    Get Element    ${output}    .//field[@name='nr-rrc.eventA5_element']//field[@name='nr-rrc.a5_Threshold1']
    ${showname}  Get Element Attribute  ${rsrp}  showname
    Log To Console  A5 Threshold1 rsrp:  ${showname}
    Should Contain  a5_Threshold1 rsrp:  ${showname}  rsrp

Check Wireshark For ssbSubcarrierSpacing
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.Read PCAP    packet_filter=nokiaf1ap.procedureCode == 12    output_type=pdml    pcap_file_path=${tcp_file}
    ${ssbSubcarrierSpacing}    Get Elements    ${output}    .//field[@name='nr-rrc.measObjectNR_element']//field[@name='nr-rrc.ssbSubcarrierSpacing']
    FOR  ${i}  IN   @{ssbSubcarrierSpacing}
        ${showname}  Get Element Attribute  ${i}  showname
        Log To Console  ${showname}
        Should Contain    ${showname}  kHz15
    END
