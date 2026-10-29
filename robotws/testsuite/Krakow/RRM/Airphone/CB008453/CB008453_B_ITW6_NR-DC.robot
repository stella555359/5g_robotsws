*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_TDD    SBTS00

Documentation
...    author: Arkadiusz Sobejko
...    contact: arkadiusz.sobejko@nokia.com

Resource    resources/CB008453_resources.robot

Suite Setup       Prepare NR-DC suite environment setup
Suite Teardown    Clean suite environment

*** Variables ***
${egate_config}                ${CURDIR}/config/wts_2c_n78_n257_TDD_SA.cfg
${SCF_gnb2_MN}                 ${CURDIR}/config/SCFC_gNB1_MN_FR1_NRDC.xml
${SCF_gnb3_SN}                 ${CURDIR}/config/SCFC_gNB2_SN_FR2_NRDC.xml
${AP_XML}                      ${CURDIR}/config/AP_MN_FR1_SN_FR2_NRDC.xml
${gnb_host}                    10.0.1.4
@{BIP_columns_SSB_SLOT_SFN}    dldata_ssblocksendreql1sw    3gpp.sfn    3gpp.slot

*** Test Cases ***
[1][1.0] CB008453-B_ITW6_Single_UE_scheduling_in_NR-DC
    CB008453 B_ITW6 feature enable
    Configure intrafreq A3 RSRP HO NR-DC configuration

    Set pdu param for internal traffic    UE_ID=1
    Register UE    UE_ID=1    CELL_ID=1
    Configure ICS param for AMF

    Establish PDU session    UE_ID=1    RRC_CHECK=True

    Start observer for SNodeAddition
    UE1 sends A4 measurement for NR-DC PSCell addition
    Verify NR-DC setup correctly
    Verify tdd-UL-DL-ConfigurationCommon on pscell NR-DC with    guardPeriod=2    scell_id=54
    Start SA traffic     ue=1    dir=dl    traffic_rate=200Mbps
    Start SA traffic     ue=1    dir=ul    traffic_rate=200Mbps

    Sleep    5s    reason=wait for tput stabilization
    Run keyword and continue on failure    Verify SA traffic    ue=1    dir=DL    expected_traffic=200Mbps
    Run keyword and continue on failure    Verify SA traffic    ue=1    dir=UL    expected_traffic=200Mbps

    Start TTI trace for NRDC
    Stop and convert TTI trace collection
    ...    directory_name=CB008453_B_ITW6_tti_trace
    ...    conversion_filter=utcTimestampData|csiSrReportData|csiRsSchedData|dlFdSchedData|dlHarqRxDataArray|ulFdSchedData|ulHarqRxData
    ...    delay=2

    Start collecting BIP logs
    Stop collecting BIP logs    dir_path=${OUTPUT_DIR}/${TEST_NAME}/CB008453_B_ITW6_BIP    delay=2

    Convert BIP logs pcap to csv
    ...    pcap_path=${OUTPUT_DIR}/${TEST_NAME}/CB008453_B_ITW6_BIP/L1L2_BIP_Logs/tcpdump.pcap
    ...    filter=dldata_ssblocksendreql1sw
    ...    columns=@{BIP_columns_SSB_SLOT_SFN}
    ...    dir_path=${OUTPUT_DIR}/${TEST_NAME}/CB008453_B_ITW6_BIP/
    ...    csv_log_name=BIP_Logs.csv

    Run keyword and continue on failure    Verify HARQ feedback on single PUCCH
    ...                                    csv_directory=${OUTPUTDIR}/${TESTNAME}/CB008453_B_ITW6_tti_trace/
    Run keyword and continue on failure    Verify periodic csi is transmitting
    ...                                    csv_directory=${OUTPUTDIR}/${TESTNAME}/CB008453_B_ITW6_tti_trace/
    Run keyword and continue on failure    Verify TRS on slots
    ...                                    slots=3,11,19,27,35,43,51,59
    ...                                    csv_directory=${OUTPUTDIR}/${TESTNAME}/CB008453_B_ITW6_tti_trace/
    Run keyword and continue on failure    Verify SSB on slots
    ...                                    slots=0,1,2,3,10,11,16,17
    ...                                    bip_csv_directory=${OUTPUTDIR}/${TESTNAME}/CB008453_B_ITW6_BIP/
    ...                                    tti_csv_directory=${OUTPUTDIR}/${TESTNAME}/CB008453_B_ITW6_tti_trace/

    [Teardown]    Run keywords
    ...           Deregister UE
    ...           UE_ID=1
    ...           AND
    ...           Run keyword and ignore error
    ...           setups_and_teardowns_keywords.Add main BTS metadata to report

*** Keywords ***
Start TTI trace for NRDC
    [Documentation]    Starts TTI trace collection
    ${configurations}=    core.Load Configurations
    ...    ${CURDIR}/config/ttitrace_collectors_NRDC.yaml
    core.Create collectors
    ...    names=l2stream3
    ...    configurations=${configurations['collectors']}
    l2stream3.Set suite alias
    ...    alias=l2stream3
    core.Setup collectors
    ...    names=l2stream3
    core.Start collectors
    ...    names=l2stream3

Start observer for SNodeAddition
    Expect message flow
    ...    gNB3:XNAP_SNodeAdditionRequest
    ...    gNB3:XNAP_SNodeAdditionRequestAcknowledge
    ...    gNB2:E1AP_BearerContextModificationRequest
    ...    gNB2:E1AP_BearerContextModificationResponse
    ...    gNB3:XNAP_XnUAddressIndication
    ...    UE_1:NR-RRC_RRCReconfiguration as RRCReconfiguration
    ...    UE_1:NR-RRC_RRCReconfigurationComplete
    ...    gNB3:XNAP_SNodeReconfigurationComplete
    ...    alias=NR-DC_flow  overall_timeout=10

UE1 sends A4 measurement for NR-DC PSCell addition
    Execute egate command    cmd=ue_meas_cfg_disp id=1 meas_obj_type=nr
    Sleep    1s    reason=wait for egate command
    ${command}    Catenate    ue_measurement_send_nr id=1 meas_id=1 event=A4 srsrp_nr=19 srsrq_nr=10
    ...                       phycell_id=54 nrsrp_nr=85 nrsrq_nr=31 index=0 nrs_result=30:30:0
    Execute egate command    cmd=${command}

Verify NR-DC setup correctly
    Run keyword and continue on failure    Flow occurred as expected  alias=NR-DC_flow
    Verify dc state    ue_id=1    state=ACTIVE

Configure ICS param for AMF
    Execute egate command    cmd=amf_ue_ics_param id=1 ue=1 indexToRFSP=1

Verify tdd-UL-DL-ConfigurationCommon on pscell NR-DC with
    [Arguments]    ${guardPeriod}=10    ${scell_id}=52
    ${SS_downlink_symbols} =      Evaluate    12 - ${guardPeriod}
    Verify that message fulfills query
    ...                               (spCellConfig contains (physCellId eq ${scell_id}))
    ...                               and
    ...                               (tdd-UL-DL-ConfigurationCommon contains (
    ...                                     pattern1 contains (
    ...                                         dl-UL-TransmissionPeriodicity eq 'ms1' and
    ...                                         nrofDownlinkSlots eq 3 and
    ...                                         nrofDownlinkSymbols eq ${SS_downlink_symbols} and
    ...                                         nrofUplinkSlots eq 4 and
    ...                                         nrofUplinkSymbols eq 2
    ...                                     )
    ...                                 )
    ...                               )
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=NR-DC_flow
