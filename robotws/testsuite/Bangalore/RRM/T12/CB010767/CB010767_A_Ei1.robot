*** Settings ***
Documentation   :copyright: Nokia
...             :author   : Amitha
...             :contact  : amitha.kadambi@nokia.com
Library     ute_fsmaccess
Library     ta5g_pm_counters
Library     ta5g_tshark
Resource    ${CURDIR}/resources/Keywords/CB010767_KW.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown


*** Variables  ***
${cellID}       52
${pcap_file_0}    /home/ute/logs/CB010767_A_Ei1/gnbTcpdump0/gnbTcpdump0.pcap
${pcap_file_1}    /home/ute/logs/CB010767_A_Ei1/gnbTcpdump1/gnbTcpdump1.pcap
${pcap_file_2}    /home/ute/logs/CB010767_A_Ei1/gnbTcpdump2/gnbTcpdump2.pcap


*** Test Cases ***
[1][1.0] CB010767_A_Ei1_4_2Verify SIB1 message is configured with 1RX not barred and 2RX not barred when cellbarred redcap = 0
    [Documentation]     This test case shall help verify SIB1 message broadcast for when Redcap feature is enabled
    ...     and cellbarring is set to 0,1,2. This implicilty verifies, Ei1_4,Ei1_5,Ei1_6 and Ei1_7 test cases.
    ...     [covering cell barring 0,1,2 and online feature enabling]
	...		Test scope also covers: CB009384_A_B1_2
#    [Tags]    QC_28314   QCD_MN_RAN    QCP_RAN_VRF
    ${Test_CaseNumber}=     Set Variable    CB010767_A_Ei1
    Link SCOUT SCF to Configuration ID for Reporting
    set test variable    ${Test_status}     False
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Log to Console      \nStarting the test\n
    Log to Console      \nFeature Not enabled yet\n
    Start pcap collection in gNB CU     gnbTcpdump_default
    Start UTE WTS      basic_setup_redcap.cfg
    sleep     30s
    Stop pcap collection in gNB     gnbTcpdump_default      ${Log_Path}
    Flush console logs
    Log to Console      Enable feature with cellbarring=0\n
    Start pcap collection in gNB CU     gnbTcpdump0
    GNB Delta commission     ${CURDIR}/config/gnb_scf/Delta_FeatureEnabled_NoCellBarring.json
    sleep     40s
    Stop pcap collection in gNB     gnbTcpdump0      ${Log_Path}
    Flush console logs
    Log to Console      \nEnable feature with cellbarring=1\n
    Start pcap collection in gNB CU     gnbTcpdump1
    Change CellBarring Online     1RX barring
    sleep     40s
    Stop pcap collection in gNB     gnbTcpdump1      ${Log_Path}
    ${Barring_status_2RX}   ${Barring_status_1RX}          Get cellBarring Status      ${pcap_file_1}      ${cellID}
    Run Keyword If    '${Barring_status_2RX}' == '1'        Log to console      \ncellBarredRedCap2Rx_r17 : notBarred\n
    Run Keyword If    '${Barring_status_1RX}' == '0'        Log to console      cellBarredRedCap1Rx_r17 : barred\n
    Flush console logs
    Log to Console      \nEnable feature with cellbarring=2\n
    Start pcap collection in gNB CU     gnbTcpdump2
    Change CellBarring Online     2RX barring
    sleep     40s
    Stop pcap collection in gNB     gnbTcpdump2      ${Log_Path}
    ${Barring_status_2RX}   ${Barring_status_1RX}          Get cellBarring Status      ${pcap_file_2}      ${cellID}
    Run Keyword If    '${Barring_status_2RX}' == '0'        Log to console      \ncellBarredRedCap2Rx_r17 : barred\n
    Run Keyword If    '${Barring_status_1RX}' == '1'        Log to console      cellBarredRedCap1Rx_r17 : notBarred\n
    [Teardown]     Run Keywords        Delete Basic Interface on UTE
#	...			AND			GNB Delta commission    ${CURDIR}/config/gnb_scf/Delta_FeatureEnabled_NoCellBarring_reverse.json
    ...      AND    Collect Logs For The Test       ${Log_Path}
    ...      AND    RAT Block Unblock

***Keywords***
Change CellBarring Online
    [Arguments]         ${CB_Value}
    admin.Setup admin
    Online NIDD parameter change    paramName=cellBarredRedCap            paramValue=${CB_Value}
    ...                             paramDst=MRBTS-1/NRBTS-1/NRCELL-3
    admin.Teardown admin
