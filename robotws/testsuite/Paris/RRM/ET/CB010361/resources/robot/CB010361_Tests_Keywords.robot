*** Settings ***
Documentation     [SUITE PURPOSE]  TCs and KWs of CB010361
...               PCMD additional radio resource usage and quality of service metrics
...               Test Case Scenario authors   : martial.hummel@nokia.com;marie-laurence.le_borgne@nokia.com
...               Creation Date               : 01-October-2024



Resource                            ./CB010361_Keywords.robot
Resource                            ../../../resources/common/TtiTrace/ttitrace.robot
Resource                            ../../../resources/robot/KeyWordMarket.robot
Resource                            ../../../../../resources/SWENG/robot/GenericTest.robot
Resource                            ../../../../../resources/SWENG/robot/Restart.robot    # to be removed AFTER

*** Variables ***

${gnb_alias}                          gnb_under_test
@{CellList}                           1    3
${port_trace}                         49148
${ip_trace}                           10.0.1.1
${BtsLogStarted}                      ${False}  #will be set to True in KeyWordMarket.robot if {userneed_Btslog}=${True}
${VMmonitoring}                       ${False}  #will create a MONITORING directory, collect Top info each 20s and do a preprocessing of data
@{DODlist}                                      # list empty for now will contain all DOD corner
${NL}                                 Nested_List
${recursion_limit}                    1000   # 1000 is the default value



${ntrstr_timeOfUeSchedMimo_Pcell}   SEPARATOR=
...      (nsetapx.timeOfUeSchedMimo > 0)

${ntrstr_sumOfMacPduTxTime_Pcell}   SEPARATOR=
...      (nsetapx.sumOfMacPduTxTime > 0)

${ntrstr_sumOfInitTxTime_Pcell}   SEPARATOR=
...      (nsetapx.sumOfInitTxTime > 0)

${ntrstr_numOfInitTxSamples_Pcell}   SEPARATOR=
...      (nsetapx.numOfInitTxSamples > 0)

${ntrstr_sumOfMacPduRxTime_Pcell}   SEPARATOR=
...      (nsetapx.sumOfMacPduRxTime > 0)

${ntrstr_sumOfInitRxTime_Pcell}   SEPARATOR=
...      (nsetapx.sumOfInitRxTime > 0)

${ntrstr_numOfInitRxSamples_Pcell}   SEPARATOR=
...      (nsetapx.numOfInitRxSamples > 0)

${ntrstr_sumOfOverAirDelay_Pcell}   SEPARATOR=
...      (nsetapx.sumOfOverAirDelay > 0)

*** Keywords ***

########################################################
################## Test Case Update
########################################################

TC_CB010361-SA-DL-MIMO
    [Documentation]                Generic KW for CB10361 TL Preparation and TC execution
    [Arguments]                    ${param}        ${deltaScf}
    Run Keyword                    dated log       =====>CB010361 Update SCF with PCMD .json file
    Run Keyword                    CB010361 Set SCF PCMD Params        ${deltaScf}    ${gnb_alias}
    sleep    120s

    Run Keyword                    Configure PCMD in Wireshark

    Init Sequence                  ${param}

    Step                           kwmkt_Create_Test_Suite_Folder
    Critical Step                  kwmkt_Cell_setup         ${CellList}


    Step                           Start Netcat for tracing
    Step                           Start pcmd report Pcap
    sleep                          20s

    Critical Step                  kwmkt_run_script_once    ${CURDIR}/../egCmd/egCmd_attach_traffic_DL_MUMIMO_2UEs.sce

    Step                           Run Keyword If           ${userneed_TTI}          Get TTI Logs

    ${status_nbr_timeOfUeSchedMimo}         Run Keyword        Verify PCMD Trace Records Pcell timeOfUeSchedMimo
    ...                            packet_filter=${ntrstr_timeOfUeSchedMimo_Pcell}
    ${status_nbr_sumOfMacPduTxTime}         Run Keyword        Verify PCMD Trace Records Pcell sumOfMacPduTxTime
    ...                            packet_filter=${ntrstr_sumOfMacPduTxTime_Pcell}
    ${status_nbr_sumOfInitTxTime}           Run Keyword        Verify PCMD Trace Records Pcell sumOfInitTxTime
    ...                            packet_filter=${ntrstr_sumOfInitTxTime_Pcell}
    ${status_nbr_numOfInitTxSamples}         Run Keyword       Verify PCMD Trace Records Pcell numOfInitTxSamples
    ...                            packet_filter=${ntrstr_numOfInitTxSamples_Pcell}

    Step                           Stop Netact for tracing
    Step                           Stop pcmd report Pcap

    Critical Step                  kwmkt_run_script_once    ${CURDIR}/../egCmd/egCmd_traffic_DL_stop_Detach_2UEs.sce

    Step                           Run Keyword If           ${BtsLogStarted}       kwmkt_Stop Btslog    ${logsDir}

    Dated log                      dod global vision: status_nbr_timeOfUeSchedMimo:${status_nbr_timeOfUeSchedMimo}
    Dated log                      dod global vision: status_nbr_sumOfMacPduTxTime:${status_nbr_sumOfMacPduTxTime}
    Dated log                      dod global vision: status_nbr_sumOfInitTxTime:${status_nbr_sumOfInitTxTime}
    Dated log                      dod global vision: status_nbr_numOfInitTxSamples:${status_nbr_numOfInitTxSamples}
    Append to List                 ${DODlist}    ${status_nbr_timeOfUeSchedMimo}     ${status_nbr_sumOfMacPduTxTime}
    ...                                          ${status_nbr_sumOfInitTxTime}       ${status_nbr_numOfInitTxSamples}

    Dated log                                           DOD_10361: DodIsSet:${DodIsSet} res:${DODlist}
    Run Keyword If                  ${DodIsSet}         kwmkt_Check_For_False_In_${NL}    ${DODlist}
    #Step                            Get Snaphot Sos Report

    [Teardown]             Display diagnosis



TC_CB010361-SA-UL-MIMO
    [Documentation]                Generic KW for CB10361 TL Preparation and TC execution
    [Arguments]                    ${param}        ${deltaScf}
    Run Keyword                    dated log       =====>CB010361 Update SCF with PCMD .json file
    Run Keyword                    CB010361 Set SCF PCMD Params        ${deltaScf}    ${gnb_alias}
    sleep    120s

    Run Keyword                    Configure PCMD in Wireshark

    Init Sequence                  ${param}


    Step                           kwmkt_Create_Test_Suite_Folder
    Critical Step                  kwmkt_Cell_setup         ${CellList}


    Step                           Start Netcat for tracing
    Step                           Start pcmd report Pcap
    Sleep                          20s


    Critical Step                  kwmkt_run_script_once    ${CURDIR}/../egCmd/egCmd_attach_traffic_UL_MUMIMO_2UEs.sce

    Step                           Run Keyword If           ${userneed_TTI}          Get TTI Logs

    ${status_nbr_timeOfUeSchedMimo}         Run Keyword        Verify PCMD Trace Records Pcell timeOfUeSchedMimo
    ...                            packet_filter=${ntrstr_timeOfUeSchedMimo_Pcell}
    ${status_nbr_sumOfMacPduRxTime}         Run Keyword        Verify PCMD Trace Records Pcell sumOfMacPduRxTime
    ...                            packet_filter=${ntrstr_sumOfMacPduRxTime_Pcell}
    ${status_nbr_sumOfInitRxTime}           Run Keyword        Verify PCMD Trace Records Pcell sumOfInitRxTime
    ...                            packet_filter=${ntrstr_sumOfInitRxTime_Pcell}
    ${status_nbr_numOfInitRxSamples}         Run Keyword       Verify PCMD Trace Records Pcell numOfInitRxSamples
    ...                            packet_filter=${ntrstr_numOfInitRxSamples_Pcell}
    ${status_nbr_sumOfOverAirDelay}         Run Keyword       Verify PCMD Trace Records Pcell sumOfOverAirDelay
    ...                            packet_filter=${ntrstr_sumOfOverAirDelay_Pcell}

    Step                           Stop Netact for tracing
    Step                           Stop pcmd report Pcap

    Critical Step                  kwmkt_run_script_once    ${CURDIR}/../egCmd/egCmd_traffic_UL_stop_Detach_2UEs.sce

    Step                           Run Keyword If           ${BtsLogStarted}       kwmkt_Stop Btslog    ${logsDir}

    Dated log                      dod global vision: status_nbr_timeOfUeSchedMimo:${status_nbr_timeOfUeSchedMimo}
    Dated log                      dod global vision: status_nbr_sumOfMacPduRxTime:${status_nbr_sumOfMacPduRxTime}
    Dated log                      dod global vision: status_nbr_sumOfInitRxTime:${status_nbr_sumOfInitRxTime}
    Dated log                      dod global vision: status_nbr_numOfInitRxSamples:${status_nbr_numOfInitRxSamples}
    Dated log                      dod global vision: status_nbr_sumOfOverAirDelay:${status_nbr_sumOfOverAirDelay}
    Append to List                  ${DODlist}    ${status_nbr_timeOfUeSchedMimo}     ${status_nbr_sumOfMacPduRxTime}
    ...                                           ${status_nbr_sumOfInitRxTime}       ${status_nbr_numOfInitRxSamples}
    ...                                           ${status_nbr_sumOfOverAirDelay}

    Dated log                                           DOD_10361: DodIsSet:${DodIsSet} res:${DODlist}
    Run Keyword If                  ${DodIsSet}         kwmkt_Check_For_False_In_${NL}    ${DODlist}
    #Step                            Get Snaphot Sos Report

    [Teardown]             Display diagnosis




