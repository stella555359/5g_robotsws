*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_TDD    SBTS00

Documentation
...    author: Arkadiusz Sobejko
...    contact: arkadiusz.sobejko@nokia.com

Resource    resources/CB008453_resources.robot

Suite Setup       Run keywords
...               Prepare suite environment
...               scfc=${scfc}
...               egate_config=${egate_config}
...               ap_xml=${iphy}
...               x2=False
...               AND
...               Create aliases
Suite Teardown    Clean suite environment

*** Variables ***
${egate_config}                ${CURDIR}/config/wts_212_UEs_SA.lua
${scfc}                        ${CURDIR}/config/SCFC_2_AWEUC_8_cells_SA.xml
${iphy}                        ${CURDIR}/config/AP_2_AWEUC_8cells.xml
@{BIP_columns_SSB_SLOT_SFN}    dldata_ssblocksendreql1sw    3gpp.sfn    3gpp.slot

*** Test Cases ***
[1][1.0] CB008453-C_ITW1_Single_UE_scheduling_with_8CC_in_SA_mode
    CB008453 feature enable
    Configure and wait    {'MOC': 'NRBTS', 'ID': '1', 'actCarrierAggregationFr2SA': "true", 'caConfigurationSupportFr2SA': "8CCDL_4CCUL"}
    Set maxNumScellsDlFr2SA and maxNumScellsUlFr2SA to value    dl_scells=7    ul_scells=3

    Set pdu param for internal traffic    UE_ID=1
    Register UE    UE_ID=1    CELL_ID=1
    Establish PDU session    UE_ID=1    PDU_ID=1    GW_ID=1    RRC_CHECK=True    CA_CHECK=True
    Verify tdd-UL-DL-ConfigurationCommon on SA pcell with    guardPeriod=2    pcell_id=51    ue_id=1

    Start SA traffic    ue=1    dir=dl    traffic_rate=980Mbps
    Start SA traffic    ue=1    dir=ul    traffic_rate=350Mbps
    Sleep    5s    reason=wait for tput stabilization
    Run keyword and continue on failure    Verify SA traffic    ue=1    dir=DL    expected_traffic=980Mbps
    Run keyword and continue on failure    Verify SA traffic    ue=1    dir=UL    expected_traffic=350Mbps

    Start TTI trace
    Stop TTI trace    delay=10    target_dir=${OUTPUT_DIR}/TTI_Trace/TTI_Traces_10s
    Sleep    15s    reason=Wait for env stabilization

    Start TTI trace collection
    Stop and convert TTI trace collection
    ...    directory_name=CB008453_C_ITW1_TTI_Trace
    ...    conversion_filter=utcTimestampData|csiSrReportData|csiRsSchedData|dlFdSchedData|dlHarqRxDataArray|ulFdSchedData|ulHarqRxData
    ...    delay=2

    Start collecting BIP logs
    Stop collecting BIP logs    dir_path=${OUTPUT_DIR}/${TEST_NAME}/CB008453_C_ITW1_BIP    delay=2

    Convert BIP logs pcap to csv
    ...    pcap_path=${OUTPUT_DIR}/${TEST_NAME}/CB008453_C_ITW1_BIP/L1L2_BIP_Logs/tcpdump.pcap
    ...    filter=dldata_ssblocksendreql1sw
    ...    columns=@{BIP_columns_SSB_SLOT_SFN}
    ...    dir_path=${OUTPUT_DIR}/${TEST_NAME}/CB008453_C_ITW1_BIP/
    ...    csv_log_name=BIP_Logs.csv

    Run keyword and continue on failure    Verify HARQ feedback on single PUCCH
    ...                                    csv_directory=${OUTPUTDIR}/${TESTNAME}/CB008453_C_ITW1_TTI_Trace/
    Run keyword and continue on failure    Verify periodic csi is transmitting
    ...                                    csv_directory=${OUTPUTDIR}/${TESTNAME}/CB008453_C_ITW1_TTI_Trace/
    Run keyword and continue on failure    Verify TRS on slots
    ...                                    slots=2,10,18,26,34,42,50,58
    ...                                    csv_directory=${OUTPUTDIR}/${TESTNAME}/CB008453_C_ITW1_tti_trace/
    Run keyword and continue on failure    Verify SSB on slots
    ...                                    slots=0,1,2,3,10,11,16,17
    ...                                    bip_csv_directory=${OUTPUTDIR}/${TESTNAME}/CB008453_C_ITW1_BIP/
    ...                                    tti_csv_directory=${OUTPUTDIR}/${TESTNAME}/CB008453_C_ITW1_tti_trace/

    [Teardown]    Run keywords
    ...           Deregister UE
    ...           UE_ID=1
    ...           AND
    ...           Run keyword and ignore error
    ...           setups_and_teardowns_keywords.Add main BTS metadata to report
