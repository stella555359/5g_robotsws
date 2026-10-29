*** Settings ***
Documentation
...    Provides additional PCMD reporting covering radio resource consumption packet drop and delay statistics – supporting instant UE
...    QoS tracking including VoNR.
...    Monitoring of the PCMD content related to MAC layer metrics in MBA Trace Session.
...
...   TEST SET NAME: CB010361-SR A 5G PCMD additional radio resource usage and quality of service metrics
...
...   TESTING SCOPE:  CB010361-SR-A
...
...   gNB Configuration:
...     - TDD cmW (FR1) eCPRI or FDD cmW (FR1) CPRI.
...     - SA or NSA Mode
...     - DL and UL CA are enabled in gNB
...
...   DEPENDENCIES:  5GC001097 Basic PCMD For NSA
...
...     CONTACT: RAN_PZ_NPS_SG02_ST_OAM
...     AUTHOR: Abderrahmane NEZROUK
...

Suite Setup       CB010361-A Test Suite Setup
Suite Teardown    CB010361-A Test Suite Teradown



Library         BuiltIn
Library	        OperatingSystem
Library	        taf.ue                                 WITH NAME    taf_ue
Library	        taf.transport.ssh          		        WITH NAME    ssh
Library	        taf.collectors.btslog      		        WITH NAME    btslog
Library	        taf.collectors.core        		        WITH NAME    core
Library         taf.analyzer.iperf_throughput           WITH NAME    tput
Library         taf.sbts.oam.coam.admin                  WITH NAME  coam_admin
Library         taf.selenium.sbts                        WITH NAME  selenium_sbts
Library         taf.hw.pdu                               WITH NAME  pdu
Library			ArchiveLibrary
Library			DateTime
Library			Collections
Library			String
Library         Process
Library         taf.sw.reporting_portal
Library         taf.rfrl.utilities.tl_config                             WITH NAME  tl_config
Library         taf.internal.wireshark.installation                      WITH NAME  wireshark_installer


Library         ../resources/vrf_nps_2/python/utilities.py
Library         ../resources/vrf_nps_2/python/radParams_handler.py           WITH NAME  radParams
Library         ../resources/vrf_nps_2/python/useful_keywords.py             WITH NAME  useful_keywords
Library         ../resources/vrf_nps_2/python/tti_trace_collector.py         WITH NAME  tti_trace_collector
Library         ../resources/vrf_nps_2/python/tti_trace_tool_installer.py    WITH NAME  tti_tool_installer
Library         ../resources/vrf_nps_2/python/ue/IperfSvrManager.py          WITH NAME  IperfSvrManager
Library         ../resources/vrf_nps_2/python/ue/UePcManager.py              WITH NAME  UePcManager
Library         ../../../resources/ST/python/scout_utils.py                  WITH NAME  scout_utils

Resource        taf/rfrl/common_resources/common_step/interface.robot
Resource        taf/rfrl/bts/robot/common/gnb_alarm.robot
Resource        taf/rfrl/bts/robot/common/gnb_bbu.robot
Resource        taf/rfrl/bts/robot/common/gnb_cell.robot
Resource        taf/rfrl/bts/robot/common/gnb_ru.robot
Resource        taf/rfrl/bts/robot/common/gnb_log.robot
Resource        taf/rfrl/bts/robot/common/gnb_scf.robot

Resource        ./CB010361_Keywords/CB010361_A_Keywords.robot
Resource        ../resources/vrf_nps_2/robot/Test_Suite_Preparation.robot
Resource        ../resources/vrf_nps_2/robot/var_test_suite.robot
Resource        ../resources/vrf_nps_2/robot/logs_collector.robot
Resource        ../resources/vrf_nps_2/robot/scf_utilities.robot
Resource        ../resources/vrf_nps_2/robot/common_useful_keywords.robot

Force Tags      CA_RAN_VRF_NPS   QCD_MN_RAN   QCP_RAN_ST   SBTS00   SBTS25R1

*** Variables ***
${alias_1}=                   UE_1
${capabilities_1}=            REAL_ANDROID_UE
${protocol}                   udp
${server_app}                 iperf
${tput_duration}              600s
${tput_DL}                    400 Mbits/sec
${tput_UL}                    200 Mbits/sec
${qci_dl}                     9
${qci_ul}                     9
${qci_ul_gbr}                 3
${Packet_Size}                1350
${udp_buffer}                 20m
${buffer_client}              20m
${buffer_server}              20m
${deviation}                  8%
${CMD_TIMEOUT}                60
${TCE_IP_ADD}                 ${tl.test_pc.default_ssh_connection_details.addr}
${TCE_PORT_NUM}               48151
${trace_name}
${alarms_list}                              ${EMPTY}
@{headers}=                              nsetapx.numOfPrbsUsed
...                                      nsetapx.sumOfMcsIndexes
...                                      nsetapx.sumOfMacPduTxTime
...                                      nsetapx.sumOfInitTxTime
...                                      nsetapx.numOfInitTxSamples
...                                      nsetapx.sumOfMacPduRxTime
...                                      nsetapx.sumOfInitRxTime
...                                      nsetapx.numOfInitRxSamples
...                                      nsetapx.sumOfOverAirDelay
@{ALLOWED_ALARMS}=                          8000
...                                         4592
...                                         61524
...                                         61649
...								            61652
...                                         4334
...                                         4340
...                                         4654
...                                         4655
...                                         4681
...                                         61524
# [8000] Failure in connection between BTS and 3rd party tool | [MTC_gNB_SA] MRBTS-_/MNL-1/TCEADM-1/TCE-1
# [FID:4592]   EFaultId_BtsResetCauseAl
# [FID:61524]  EFaultId_SshEnabled
# [FID:61649]  EFaultId_LmpAccessViaPort
# [FID:61652]  EFaultId_RndServicePortEnabled
# [FID:4334]   EFaultId_SerialConsoleActivatedAl
#Update
# [FID:4654]   Ethernet port security is disabled
# [FID:4655]   Service account root access is enabled
# [FID:61524]  SSH enabled
# [FID:4340]  SSH enabled
# [FID:4681] Sanity Check
@{custom_patterns}=       critical
...                       err\\/\\|error
...                       wrn\\/\\|warning
...                       unknown
@{custom_msg_to_skip}=    INF
*** Test Cases ***
[1][1.0] A_B101_1_PCMD_Monitoring_MAC_Layer_Number_of_PRB_used_DL
    [Documentation]    The purpose of the test is to monitor in PCMD traces
    ...     at MAC Layer level the number of PRB used during UE DL traffic.
    [Tags]
    [Setup]       TC Setup Action
    [Teardown]    TC Teardown Action

    A_B101_PCMD_Monitoring_MAC_Layer_Check
    ...  ${tput_DL}    DL    PCMD_COUNTER=numOfPrbsUsed    protocol_name=dlSchedulingRecord
    ...  filter_expression=value and value != '0' and value != '0.0'

[1][1.0] A_B101_2_PCMD_Monitoring_MAC_Layer_Sum_of_MCS_used_DL
    [Documentation]    The purpose of the test is to monitor in PCMD traces
    ...    at MAC Layer level the total of MCS during UE DL traffic..
    [Tags]
    [Setup]       TC Setup Action
    [Teardown]    TC Teardown Action

    A_B101_PCMD_Monitoring_MAC_Layer_Check
    ...  ${tput_DL}    DL    PCMD_COUNTER=sumOfMcsIndexes    protocol_name=dlSchedulingRecord
    ...  filter_expression=value and value != '0' and value != '0.0'

[1][1.0] A_B102_1_PCMD_Monitoring_MAC_Layer_DL_delays_Sum_of_InitialTxTime
    [Documentation]    The purpose of the test is to monitor in PCMD traces
    ...    at MAC Layer level the DL delays via the Sum of Initial Tx Time..
    [Tags]
    [Setup]       TC Setup Action
    [Teardown]    TC Teardown Action

    A_B101_PCMD_Monitoring_MAC_Layer_Check
    ...  ${tput_DL}    DL    PCMD_COUNTER=sumOfInitTxTime    protocol_name=dlSchedulingRecord
    ...  filter_expression=value and value != '00:00:00:00:00:00:00:00'

[1][1.0] A_B102_2_PCMD_Monitoring_MAC_Layer_DL_delays_Number_of_Initial_Tx_Samples
    [Documentation]    The purpose of the test is to monitor in PCMD traces
    ...    at MAC Layer level the DL delays via the Number of Initial Tx Samples..
    [Tags]
    [Setup]       TC Setup Action
    [Teardown]    TC Teardown Action

    A_B101_PCMD_Monitoring_MAC_Layer_Check
    ...  ${tput_DL}    DL    PCMD_COUNTER=numOfInitTxSamples    protocol_name=dlSchedulingRecord
    ...  filter_expression=value and value != '0' and value != '0.0'

[1][1.0] A_B103_1_PCMD_Monitoring_MAC_Layer_Sum_of_MAC_PDU_Tx_Time_DL
     [Documentation]    The purpose of the test is to monitor in PCMD traces
    ...     at MAC Layer level the sum of MAC PDU Tx Time used during UE UL traffic.
    [Tags]
    [Setup]       TC Setup Action
    # [Teardown]    TC Teardown Action
    [Teardown]    TC With Burst Traffic DL Teardown Action
    A_B101_PCMD_Monitoring_MAC_Layer_Check_WITH_Traffic_Burst_DL
    ...  PCMD_COUNTER=sumOfMacPduTxTime    protocol_name=dlSchedulingRecord
    ...  filter_expression=value and value != '00:00:00:00:00:00:00:00'
    # A_B101_PCMD_Monitoring_MAC_Layer_Check
    # ...  ${tput_DL}    DL    PCMD_COUNTER=sumOfMacPduTxTime    protocol_name=dlSchedulingRecord
    # ...  filter_expression=value and value != '00:00:00:00:00:00:00:00'

[1][1.0] A_B104_1_PCMD_Monitoring_MAC_Layer_Number_of_PRB_used_UL
    [Documentation]    The purpose of the test is to monitor in PCMD traces
    ...     at MAC Layer level the number of PRB used during UE UL traffic.
    [Tags]
    [Setup]       TC Setup Action
    [Teardown]    TC Teardown Action

    A_B101_PCMD_Monitoring_MAC_Layer_Check
    ...  ${tput_UL}    UL    PCMD_COUNTER=numOfPrbsUsed    protocol_name=ulSchedulingRecord
    ...  filter_expression=value and value != '0' and value != '0.0'

[1][1.0] A_B104_2_PCMD_Monitoring_MAC_Layer_Sum_of_MCS_used_UL
    [Documentation]    The purpose of the test is to monitor in PCMD traces
    ...    at MAC Layer level the total of MCS during UE UL traffic..
    [Tags]
    [Setup]       TC Setup Action
    [Teardown]    TC Teardown Action

    A_B101_PCMD_Monitoring_MAC_Layer_Check
    ...  ${tput_UL}    UL    PCMD_COUNTER=sumOfMcsIndexes    protocol_name=ulSchedulingRecord
    ...  filter_expression=value and value != '0' and value != '0.0'

[1][1.0] A_B105_1_PCMD_Monitoring_MAC_Layer_UL_Delays_Sum_of_InitialRxTime
    [Documentation]    The purpose of the test is to monitor in PCMD traces
    ...    at MAC Layer level the UL delays via the Sum of Initial Tx Time..
    [Tags]
    [Setup]       TC Setup Action
    [Teardown]    TC Teardown Action

    A_B101_PCMD_Monitoring_MAC_Layer_Check
    ...  ${tput_DL}    DL    PCMD_COUNTER=sumOfInitRxTime    protocol_name=ulSchedulingRecord
    ...  filter_expression=value and value != '00:00:00:00:00:00:00:00'

[1][1.0] A_B105_2_PCMD_Monitoring_MAC_Layer_UL_Delays_Number_of_InitialRxSamples
    [Documentation]    The purpose of the test is to monitor in PCMD traces
    ...    at MAC Layer level the UL delays via the Number of Initial Tx Samples..
    [Tags]
    [Setup]       TC Setup Action
    [Teardown]    TC Teardown Action

    A_B101_PCMD_Monitoring_MAC_Layer_Check
    ...  ${tput_DL}    DL    PCMD_COUNTER=numOfInitRxSamples    protocol_name=ulSchedulingRecord
    ...  filter_expression=value and value != '0' and value != '0.0'

[1][1.0] A_B105_3_PCMD_Monitoring_MAC_Layer_UL_Delays_Sum_of_OverTheAir_delay
    [Documentation]    The purpose of the test is to monitor in PCMD traces
    ...    at MAC Layer level the UL delays via the Sum of over-the-air delay.
    [Tags]
    [Setup]       TC Setup Action
    [Teardown]    TC Teardown Action

    A_B101_PCMD_Monitoring_MAC_Layer_Check
    ...  ${tput_UL}    UL    PCMD_COUNTER=sumOfOverAirDelay    protocol_name=ulSchedulingRecord
    ...  filter_expression=value and value != '0' and value != '0.0'

[1][1.0] A_B106_1_PCMD_Monitoring_MAC_Layer_Sum_of_MAC_PDU_Rx_Time_UL
    [Documentation]    The purpose of the test is to monitor in PCMD traces
    ...    at MAC Layer level the UL delays via the sum of MAC PDU Rx Time.
    [Tags]
    [Setup]       TC Setup Action
    [Teardown]    TC Teardown Action

    A_B101_PCMD_Monitoring_MAC_Layer_Check
    ...  ${tput_UL}    UL    PCMD_COUNTER=sumOfMacPduRxTime    protocol_name=ulSchedulingRecord
    ...  filter_expression=value and value != '00:00:00:00:00:00:00:00'

*** Keywords ***
TC Setup Action
    TCP Server Start
    Wait Until Keyword Succeeds    20s    3s    Check TCE link is Up
    gnbcell.Verify All Cells Are Onair
    gnb_log.Setup gNB Btslog Collector
    Set BTSLog Rad Parameters on Classical gNB
    Test Case Dir Preparation

TC Teardown Action
    Run keyword and ignore error    taf_ue.detach_ue       ue_alias=${alias_1}
    # Run Keyword and Ignore Error    scout_utils.set_scout_config_id_tc    ${BTS_SCOUT_NAME}
    Run Keyword And Ignore Error    TCP Server Stop
    Run Keyword And Ignore Error    ute_tshark.Teardown Tshark  alias=tshark
    Run Keyword and Ignore Error    gnb_log.Teardown gNB Btslog Collector
    BuiltIn.Log   Collecting BTS Snapshot   console=True
    ${is_true}           Evaluate    "${GET_SNAPSHOT}" in ['yes', 'Yes', 'YES']
    Run Keyword If    ${is_true}
    ...  Run Keyword and Ignore Error  gnb_log.Collect Snapshot From gNB  log_dir=${res_path}
    ...  snapshot_coverage=Full  timeout=${SNAPSHOT_TIMEOUT}
    Run Keyword and Ignore Error    gnblog.disconnect
    Run Keyword and Ignore Error    Useful_keywords.instance_disconnect  gnbbbu
    # interface.Common step trigger

TC With Burst Traffic DL Teardown Action
    Run keyword and ignore error    taf_ue.detach_ue       ue_alias=${alias_1}
    UePcManager.Clean Up
    IperfSvrManager.Clean Up
    # Run Keyword and Ignore Error    scout_utils.set_scout_config_id_tc    ${BTS_SCOUT_NAME}
    Run Keyword And Ignore Error    TCP Server Stop
    Run Keyword And Ignore Error    ute_tshark.Teardown Tshark  alias=tshark
    Run Keyword and Ignore Error    gnb_log.Teardown gNB Btslog Collector
    BuiltIn.Log   Collecting BTS Snapshot   console=True
    ${is_true}           Evaluate    "${GET_SNAPSHOT}" in ['yes', 'Yes', 'YES']
    Run Keyword If    ${is_true}
    ...  Run Keyword and Ignore Error  gnb_log.Collect Snapshot From gNB  log_dir=${res_path}
    ...  snapshot_coverage=Full  timeout=${SNAPSHOT_TIMEOUT}
    Run Keyword and Ignore Error    gnblog.disconnect
    Run Keyword and Ignore Error    Useful_keywords.instance_disconnect  gnbbbu
    # interface.Common step trigger

