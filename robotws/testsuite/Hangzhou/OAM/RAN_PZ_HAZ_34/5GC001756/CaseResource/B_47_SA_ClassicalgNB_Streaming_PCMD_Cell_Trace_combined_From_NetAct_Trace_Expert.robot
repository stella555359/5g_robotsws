*** Settings ***
Documentation

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
B_47_SA_ClassicalgNB_Streaming_PCMD_Cell_Trace_combined_From_NetAct_Trace_Expert
    Activate PCMD Configuration From NetAct Trace Expert
    ...   TL${MRBTS_ID}-${NRBTS}-cell-trace   PLMN-PLMN/${INSID}/NRCELL-1   5G Radio Cell Trace for gNB-CU-SG7-PCMD combine
    ...   ${START_PAGE}   ${START_PAGE_USER}   ${START_PAGE_PASSWORD}
    Run Keyword And Ignore Error   Wait Until Keyword Succeeds   3times   10s   Make L3CALL And Get ALL PCMD TCPDUMP File
    Check Cu Record After Activation or Deactivation From NetAct Trace Expert    operation=Activation   tcpdump_file=${TCPDUMP_PATH}
    Check Trace Record After Activation After NetAct Trace Expert   tcpdump_file=${TCPDUMP_PATH}

Case Setup: B_47
    log to console   case setup
    Common Setup 1756
    Remove And Add PCMD Object
    Run Keyword And Ignore Error   COAM Logout
#    Run Keyword And Ignore Error   L3CALL Precondition on Case B_47 Setup
    Run Keyword And Ignore Error   Delete MO via COAM   ${INSID}/NRCTRLTS-1/NRMTRACECU-1
#    Get NetAct Info
    run keyword and ignore error   Remove Trace Plan on NetAct Backend
    [Teardown]  Run Keyword And Ignore Error   COAM Logout

#L3CALL Precondition on Case B_47 Setup
#    Start Tcpdump To Get PCMD   pcmd_file=B_47.pcap
#    Wait Until Keyword Succeeds   3times   10s   L3CALL Precondition
#    Wait Until Keyword Succeeds   3x   10s   Attach UE and Detach
#    Stop Tcpdump To Get PCMD   pcmd_file=B_47.pcap

Case Teardown: B_47
    log to console   case teardown
    run keyword if test passed    Run Keyword And Ignore Error   RUN   rm -rf ${TCPDUMP_PATH}
    Wait Until Keyword Succeeds   10m   1m   COAM Login
    Wait Until Keyword Succeeds   15m   1m   COAM Check All Cells Onair
    Run Keyword And Ignore Error   COAM Logout
    Common Teardown 1756
    [Teardown]  run keyword and ignore error   COAM Logout

Check Trace Record After Activation After NetAct Trace Expert
    [Arguments]  ${tcpdump_file}=${TCPDUMP_PATH}
    log to console     Check Trace Record After Activation After NetAct Trace Expert
    ${xpath_part1}   set variable   .//nsetapx.recordingSessionReportList/nsetapx.cuRecordingSessionReportList//
    ${xpath_part2}   set variable   nsetapx.CuRecordingSessionReport_element/nsetapx.recordList//nsetapx.CuRecord_element/nsetapx.data/
    ${xpath_part3}   set variable   nsetapx.asn1_Data_element/nr-rrc/nr-rrc.UL_CCCH_Message_element/nr-rrc.message/nr-rrc.c1
    ${xpath}   set variable   ${xpath_part1}${xpath_part2}${xpath_part3}
    Load Pcap File with Filter any Expression
            ...   pcap_file=${tcpdump_file}
            ...   any_expression=nr-rrc.c1 == 0
            ...   filter=tcp.dstport==49148

#    Load Pcap File with Filter
#     ...                        pcap_file=${tcpdump_file}
#     ...                        record_type=Cu
#     ...                        input_type=12
#     ...                        filter=tcp.dstport==49148
    ${cu_recode_value}=    wireshark.get_field_value_by_xpath   xpath=${xpath}   attribute_name=showname
    should contain   ${cu_recode_value}   rrcSetupRequest
    Log To Console   check value is OK
