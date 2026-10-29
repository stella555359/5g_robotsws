*** Settings ***
Documentation

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
B_44_SA_ClassicalgNB_PCMD_Deactivation_From_NetAct_Trace_Expert_for_5G_Radio_gNB-CU_PCMD
    Deactivation PCMD Configuration From NetAct Trace Expert   TL${MRBTS_ID}-${NRBTS}-radio
    ...   ${START_PAGE}   ${START_PAGE_USER}   ${START_PAGE_PASSWORD}
    Run Keyword And Ignore Error   Wait Until Keyword Succeeds   3times   10s   Make L3CALL And Get ALL PCMD TCPDUMP File
    Check Cu Record After Activation or Deactivation From NetAct Trace Expert   operation=Deactivation   tcpdump_file=${TCPDUMP_PATH}

Case Setup: B_44
    log to console   case setup
    Common Setup 1756
    Run Keyword And Ignore Error   COAM Logout
#    Get NetAct Info
    [Teardown]  Run Keyword And Ignore Error   COAM Logout

Case Teardown: B_44
    log to console   case teardown
    run keyword if test passed    Run Keyword And Ignore Error   RUN   rm -rf ${TCPDUMP_PATH}
    Wait Until Keyword Succeeds   10m   1m   COAM Login
    Wait Until Keyword Succeeds   15m   1m   COAM Check All Cells Onair
    Run Keyword And Ignore Error   COAM Logout
    Common Teardown 1756
    [Teardown]  run keyword and ignore error   COAM Logout
