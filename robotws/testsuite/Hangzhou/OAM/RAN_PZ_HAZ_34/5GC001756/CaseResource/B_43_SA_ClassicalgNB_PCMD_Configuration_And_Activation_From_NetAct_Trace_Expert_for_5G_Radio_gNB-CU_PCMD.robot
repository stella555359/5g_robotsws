*** Settings ***
Documentation

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
B_43_SA_ClassicalgNB_PCMD_Configuration_And_Activation_From_NetAct_Trace_Expert_for_5G_Radio_gNB-CU_PCMD
    Activate PCMD Configuration From NetAct Trace Expert   TL${MRBTS_ID}-${NRBTS}-radio   PLMN-PLMN/${INSID}   5G Radio gNB-CU PCMD-SG7_PCMD
    ...   ${START_PAGE}   ${START_PAGE_USER}   ${START_PAGE_PASSWORD}
    Run Keyword And Ignore Error   Wait Until Keyword Succeeds   3times   10s   Make L3CALL And Get ALL PCMD TCPDUMP File
    Check Cu Record After Activation or Deactivation From NetAct Trace Expert    operation=Activation   tcpdump_file=${TCPDUMP_PATH}

Case Setup: B_43
    log to console   case setup
    Common Setup 1756
    Remove And Add PCMD Object
    Run Keyword And Ignore Error   COAM Logout
#    Run Keyword And Ignore Error   L3CALL Precondition on Case B_43 Setup
    run keyword and ignore error   Delete MO via COAM   ${INSID}/NRCTRLTS-1/NRMTRACECU-1
#    Get NetAct Info
    run keyword and ignore error   Remove Trace Plan on NetAct Backend
    [Teardown]  Run Keyword And Ignore Error   COAM Logout

#L3CALL Precondition on Case B_43 Setup
#    Start Tcpdump To Get PCMD   pcmd_file=B_43.pcap
#    Wait Until Keyword Succeeds   3times   10s   L3CALL Precondition
#    Wait Until Keyword Succeeds   3x   10s   Attach UE and Detach
#    Stop Tcpdump To Get PCMD   pcmd_file=B_43.pcap

Case Teardown: B_43
    log to console   case teardown
    run keyword if test passed    Run Keyword And Ignore Error   RUN   rm -rf ${TCPDUMP_PATH}
    Wait Until Keyword Succeeds   10m   1m   COAM Login
    Wait Until Keyword Succeeds   15m   1m   COAM Check All Cells Onair
    Run Keyword And Ignore Error   COAM Logout
    run keyword and ignore error   Common Teardown 1756
    [Teardown]  run keyword and ignore error   COAM Logout
