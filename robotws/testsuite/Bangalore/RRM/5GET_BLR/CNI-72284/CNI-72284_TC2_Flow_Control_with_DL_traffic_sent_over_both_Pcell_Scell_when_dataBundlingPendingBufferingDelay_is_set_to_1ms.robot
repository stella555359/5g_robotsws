*** Settings ***
Force Tags      CLOUD_5G_I_BOO_AP_LOO   SBTS00    SBTS23R1    CONFIGURED    5G_RAN    RAN_5G    CRT    PY36
#...             CONFIGS_Bangalore/RRM/ET/ABOO_2Cells_Configs/ABOO_2Cells_Config_new.yml

Documentation
...
...     INTRODUCTION:  CNI-72284 - Flow Control improvements for peak throughput with QC UEs
...     This CNI is to help the Qcom UE not to crash when the CA is enables and gNB sends alternating SNs on different cells.
...     so we are helping Qcom by bundling the data to ensure that we send atleast 1ms worth of data on one cell before
...     we switch to another cell for data split
...
...     RRM domain:
...     Just that we building 1ms of data on each leg before selecting a different leg so that flow control is not alternating
...     the PDUs on each cell
...
...     TEST SET NAME:  CNI-72284
...
...     TESTING SCOPE: Prerequisite : GNB and Airphone should be installed
...     Scope : CNI-72284 : Flow Control improvements for peak throughput with QC UEs
...
...     PRECONDITIONS:  GNB and Airphone should be installed
...
...     DEPENDENCIES:  Req ID :ALG_5777
...
...     TEST INSTANCE SPECIFIC NOTES:
...        Case 1: CNI-72284_TC2_Flow_Control_with_DL_traffic_sent_over_both_Pcell_Scell_when_dataBundlingPendingBufferingDelay_is_set_to_1ms
...        TC NAME: CNI-72284_TC2_Flow_Control_with_DL_traffic_sent_over_both_Pcell_Scell_when_dataBundlingPendingBufferingDelay_is_set_to_1ms
...        Purpose: The aim of this test is to check the flow control when dataBundlingPendingBufferingDelay is set to 1ms when both Pcell and
...       Scell DL Traffic is sent and check the maximum Tput achievable and behavior/performance compared to before CNI solution.
...
...     CONTACTS:
...     Coll Review:
...         https://collab.ext.net.nokia.com/ui#review:id=842229
...
...     CP2 Requirements Path:
...          /5G System/5G_RAn/Specifications/User Plane
...
...     ALG_5777
...          Estimate the RLC PDU delivery delay (defined in 5G_UP_ALG_5784), for the corresponding
...          5G-L2-LO instance for primary 5G-L2-LO instance and secondary 5G-L2-LO instance(s)
...
...     Focal point Link:
...         https://jira3.ext.net.nokia.com/browse/CNI-72284
...
...     Test Plan Coll Review link:
...         https://collab.ext.net.nokia.com/ui#review:id=843328
...
...     Scripts Review Coll review:
...         https://collab.ext.net.nokia.com/ui#review:id=848608
...
...     REFERENCES:  CNI-72284 (ALG_5777)
...
...     TERMS AND ABBREVIATIONS:  -
...
...     HISTORY:  History, current status and TC description is available in repository:
...                [20.12.2021] - Created TCs
...                [18.01.2021] - Updates to Test suite documentation update and Keywords done
...                [18.01.2022] - Test suite documentation update.
...                [21.12.2021] - TC code review completed
...
...               Test Case Scenario author   : vandana.b@nokia.com
...               Test Case Scenario contact  : vandana.b@nokia.com
...               Test Case automation author : vandana.b@nokia.com
...               Test Case automation contact: vandana.b@nokia.com
...               Creation Date               : 21-December-2021
...               Modified Date               : 18-January-2022
...               Updated Date                : 21-June-2022/11-Aug-2022
...               Last Modified by            : lavanya.p@nokia.com

Library        taf.transport.ssh           WITH NAME    taf_ssh
Library        taf.wts.runner              WITH NAME    wtsrunner
Resource       taf/rfrl/common_resources/robot/coam.robot
Resource       robot/5GC002255_Keywords.robot
#Library        luashark_tools.analyzer       WITH NAME       analyzer
#Library        ute_admin                         WITH NAME   ute_adm
Library        taf.collectors.core   WITH NAME   core
Library        taf.collectors.btslog  WITH NAME   btslog
Library        Collections
Library        OperatingSystem
Library        ta5g_tshark
Library        ta5g_commissioning
Resource       taf/rfrl/common_resources/robot/coam.robot
Resource       ../resources/robot/Setup_Env.robot
Resource       ../resources/robot/Airphone.robot
Resource       ../resources/robot/WTS_Runner_Keywords.robot
Library        ../resources/python/BIP_Capture.py
Library        ../resources/python/CPRT_Capture.py
Resource       ../resources/robot/PM_Counters.robot
Resource       ../resources/NPS/SWENG/robot/Counters.robot
Resource        ../resources/NPS/SWENG/Pm/pmc.robot
Library         ./resources/Lib/Snapshot_csv_analyser.py
Library          ute_fsmaccess
Library         ta5g_egate
Library         ta5g_enb
Library         ta5g_iphy
Library         ta5g_pm_counters
Library         ta5g_ue_mobility
Library         ta_egate_cmd_parser
#Library         ute_tshark
Library         ta5g_testline_management
Resource         ../resources/robot/common_log_collection.robot
Resource         ../resources/robot/configuration_id.robot

# Bring up the testline with basic configuration
Suite Setup         Run keywords     Suite setup from scratch
...               AND    add routes
...               AND    Add GNB RadParam TC2
...               AND    Add AP RadParam
#...               AND     Prepare TL with all config files
...               AND     Start Default Logging    output_dirpath=${LOG_PATH}
#...             AND    Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...               AND    5GC002255_Keywords.Perform SCF Delta Commissioning with CNI_72284_1ms.json
...               AND     Initiate Dcap
...               AND    Sleep    2min
...               AND    5GC002255_Keywords.Start WTS Using WTS_Runner      ${wts_cfg_file}

Suite Teardown      Run Keywords     Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}


Test Setup        DCAP Connect To gNB
Test Teardown     Run Keywords     Get DCAP Snapshot    log_dir=${LOG_PATH}
...     AND       DCAP Disconnect To gNB

*** Variables ***
@{Component1}    L2PS   L2HIPDCP   L2HIRLC
${SCFC}     ${CURDIR}/config/ABOO_2Cells_Config_scf_new.xml
${AP_XML}   ${CURDIR}/config/ABOO_2Cells_Config_iphy_new.xml
@{FIELDS_CellSetupReq}     cellBwpList_item_0     cellBwpList_item_1
${AP_FCT_BOARD_TYPE}           ${EMPTY}
${AP_ASP_BOARD_TYPE}           ${EMPTY}
${gnb_swconfig}    ${CURDIR}/config/gnb_swconfig_cni_1ms.txt
${ap_swconfig}    ${CURDIR}/config/ap_swconfig_cni.txt
@{CAslNone}          none
@{CAslFddFr1Tdd}     ca_Fdd_Fr1Tdd_Sa   #branch 0.800.xxx  (trunk)
@{Activated}     true
&{B_18}          carrierAggregationSupportList=${CAslNone}
&{B_20}          actGrflShd=${Activated}
&{B_17}          carrierAggregationSupportList=${CAslFddFr1Tdd}
${CrntiOK}        false
${Crnti}        true
${WTS_AP_XML}              AirphoneConfig_multiue_fdd.xml
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${nwslice_ID}   1
${gw_ID3}     1
${gw_ID2}     2
${gw_ID1}     3
${gw_ID4}     4
${Pdu_session_ID3}       3
${Pdu_session_ID2}       2
${Pdu_session_ID1}       1
${Pdu_session_ID4}       4
${UE_ID3}        3
${UE_ID4}        4
${UE_ID2}        2
${UE_ID1}        1
${QFI_ID}    1
${TRF_ID1}    1
${TRF_ID2}    2
${TRF_ID3}    3
${TRF_ID4}    4
${TRF_ID5}    5
${TRF_ID6}    6
${TRF_ID7}    7
${TRF_ID8}    8
${TRF_ID9}    9
${TRF_ID10}    10
${TRF_ID11}    11
${TRF_ID12}    12
${TRF_ID13}    13
${TRF_ID14}    14
${TRF_ID15}    15
${TRF_ID16}    16
${TRF_ID17}    17
${TRF_ID18}    18
${TRF_ID19}    19
${TRF_ID20}    20
${path}     /opt/iphy/epc_latest/uec_1.log
${UE}       UE3
${UE1}       UE1
${IPHY_XML}                     ${CURDIR}/config/iphy.xml
${file_path}                     ${CURDIR}/config/iphy.xml
${PROFILE_ID}    1
${WTS_DIR}     /opt/iphy/latest
${wts_cfg_file}     ${CURDIR}/config/basic_setup_2cells_config.cfg

*** Test Cases ***
[1][1.0] CNI-72284_TC2_Flow_Control_with_DL_traffic_sent_over_both_Pcell_Scell_when_dataBundlingPendingBufferingDelay_is_set_to_1ms
    # Start CPRT logs
#    5GC002255_Keywords.Start Capture CPRT
    #Start collecting the syslogs
#     5GC002255_Keywords.Start Collecting Syslog     NAME=CNI_1ms
    #Enable the CNI paramaters  - For 5G22R2 actCaDlDataBundling = True,
    #5G22R1 -  MRBTS.NRBTS.tmpActFeat1= bit0 and the dataBundlingPendingBufferingDelay = 1ms
    #Delta Commission With SCF File    ${DELTA_CNI_FILE}
    # Attach CA capable SA UE - UE3
    WTS_Runner_Keywords.UE Register should be Successful     ${UE_ID3}    ${Pdu_session_ID1}    ${nwslice_ID}    ${gw_ID3}
    #Start the traffic with 4 streams to get the better Tput for CA capable SA UE - UE3
#    Generate 300mpbs traffic     ${ue_id3}    ${Pdu_session_ID1}    ${QFI_ID}
    #collect the snasphot for validation of 1ms
#    Get_Snapshot_gNB
    wtsrunner.trf_data_start     ue=3 pdu=1 qfi=1 trf_id=1 mbps=100 dir=dl protocol=tcp
    wtsrunner.trf_data_start     ue=3 pdu=1 qfi=1 trf_id=2 mbps=100 dir=dl protocol=tcp
    wtsrunner.trf_data_start     ue=3 pdu=1 qfi=1 trf_id=3 mbps=100 dir=dl protocol=tcp

    ${Nrcell}   Create List   NRCELL_2
        log to console     l2hitti
    Start Log Via DCAP  ttitrace  component=${Component1}    CellId=${Nrcell}
    sleep    1s
    ${getpath1}  Stop Log Via DCAP  ttitrace  test_scenario=l2hitti
    Move File     ${getpath1}[ttitrace]/tcpdump_ttitrace.pcap    ${OUTPUT DIR}/tcpdump_ttitrace.pcap
#    run    /sbin/tcpdump -r ${getpath1}[ttitrace]/tcpdump.pcap -w ${getpath1}[ttitrace]/tcpdump_ttitrace.pcap -C 50
#    Decode TTI Trace    l2hitti
    Verify l2loindex in pcap        ${OUTPUT DIR}/tcpdump_ttitrace.pcap
#    Verify l2loindex in pcap        /home/ute/logs1/l2hitti/tcpdump_ttitrace.pcap
    #Check DL RLC data PDU volume transmitted by Low RLC - QoS Group 06 (M55310C01006)
    #Check DL RLC data PDU volume transmitted by Low RLC - QoS Group 06 (M55310C01006)
    #Check DL RLC PDU volume transmitted over secondary path - QoS Group 06 (M55311C44006)
    #Check DL RLC PDUs transmitted over secondary path- QoS Group 06 (M55311C45006)
    #Check DL RLC PDU volume transmitted over primary path - QoS Group 06 (M55311C42006)
    #Check DL RLC PDUs transmitted over primary path- QoS Group 06 (M55311C43006)
    Sleep   60s
    #DL RLC data PDU volume transmitted by Low RLC - QoS Group 06 (M55310C01006)
    ${status} =    5GC002255_Keywords.Get Max PM Counter Value With Admin    M55310C01006   #CELLS/NRCELL-1/NLRLC/DL_RLC_VOL_TX_L_QOS_GRP_06
    Check counter value is non zero     ${status}
    #DL RLC data PDU volume transmitted by Low RLC - QoS Group 06 (M55310C01006)
    ${status} =    5GC002255_Keywords.Get Max PM Counter Value With Admin    M55310C01006   #CELLS/NRCELL-2/NLRLC/DL_RLC_VOL_TX_L_QOS_GRP_06
    Check counter value is non zero     ${status}
    #DL RLC PDU volume transmitted over secondary path - QoS Group 06 (M55311C44006)
    ${status} =    5GC002255_Keywords.Get Max PM Counter Value With Admin    M55311C44006   #BTS/NRBTS-1/NRDU-1/NHRLC/DL_RLC_VOL_TX_SEC_QOS_GRP_06
    Check counter value is non zero     ${status}
    #DL RLC PDUs transmitted over secondary path- QoS Group 06 (M55311C45006)
    ${status} =    5GC002255_Keywords.Get Max PM Counter Value With Admin    M55311C45006   #BTS/NRBTS-1/NRDU-1/NHRLC/DL_RLC_PDU_TX_SEC_QOS_GRP_06
    Check counter value is non zero     ${status}
    #DL RLC PDUs transmitted over primary path- QoS Group 06 (M55311C43006)
    ${status} =    5GC002255_Keywords.Get Max PM Counter Value With Admin    M55311C43006   #BTS/NRBTS-1/NRDU-1/NHRLC/DL_RLC_PDU_TX_PRI_QOS_GRP_06
    Check counter value is non zero     ${status}
    #DL RLC PDU volume transmitted over primary path - QoS Group 06 (M55311C42006)
    ${status} =    5GC002255_Keywords.Get Max PM Counter Value With Admin    M55311C42006   #BTS/NRBTS-1/NRDU-1/NHRLC/DL_RLC_VOL_TX_PRI_QOS_GRP_06
    Check counter value is non zero     ${status}

     Get_Snapshot_gNB
    #stop capturing CPRT
#    5GC002255_Keywords.Stop Capture CPRT
    #stop capturing syslogs
#     5GC002255_Keywords.Stop Collecting Syslog       NAME=CNI_1ms
#    Verify Syslog for Data Bundling Limit
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
Verify Syslog for Data Bundling Limit
#     [Arguments]     ${NAME}
#    ute_syslog.message_should_exist_in_syslog_file
#    ...    regexp=Switching Beam via MAC CE for pdcch. Old Beam: 0 New Beam: 1
#    ...    alias=AP_syslog
    log to console     Verifying syslog the info on Data Bundling Limit
    ${status} =   run    command=sudo cat ${LOG_PATH}/${TEST_NAME}/syslog_CNI_1ms.log | grep -i "caDataBundlingLimit"
    Should contain    ${status}     above recommended limit which is 2ms, it can cause performance degradation
    Log to Console    Verified that Data Bundling limit is seen in syslog about information on performance degrade if set more than 2ms



Verify l2loindex in pcap
    [Arguments]
    ...      ${pcapFile}
    [Documentation]
    ...     Verifies l2loindex is continuous
    ${l2loindex1_counter}=  set Variable   0
    ${pdmlFile}=         Get filtered PDML file from pcap        ${pcapFile}         duhi_itf_l2log_du_hi_events_tx_duflowcontroldecision_t
    @{list_of_values}    get matched packet in a list     duhi_itf_l2log_du_hi_events_tx_duflowcontroldecision_t    ${pdmlFile}   l2LoIndex
#    ${l2loindex_list}               Get Packet Match Dict List
#            ...                   packetMatch=@{list_of_values}
#        ...                   field=l2LoIndex
    FOR      ${prb_packet}     IN      @{list_of_values}

        ${l2loindex1_counter1}      ${packet_l2loindex}              Get Value l2loindex In Packet Match
        ...                   packetMatch=${prb_packet}
        ...                   field=l2LoIndex
        ${l2loindex1_counter}   Evaluate   ${l2loindex1_counter} + ${l2loindex1_counter1}
        ${l2loindex1_counter}   set Variable if     ${packet_l2loindex} == ${0}   ${0}      ${l2loindex1_counter}
        exit for loop if         ${l2loindex1_counter} > ${25}
    END

