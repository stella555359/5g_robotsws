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
${egate_config}                ${CURDIR}/config/wts_212_UEs_NSA.lua
${scfc}                        ${CURDIR}/config/SCFC_2_AWEUC_8_cells.xml
${iphy}                        ${CURDIR}/config/AP_2_AWEUC_8cells.xml
@{BIP_columns_SSB_SLOT_SFN}    dldata_ssblocksendreql1sw    3gpp.sfn    3gpp.slot

*** Test Cases ***
[1][1.0] CB008453-E_B2_Single_UE_scheduling_without_carrier_aggregation_with_PRACH_format_B4_and_11km_cell_range
    CB008453 E_B2 feature enable
    Disable CA

    Position UE107 in distance to cell - 9000m
    Attach UE    UE_ID=107
    SgNB Addition    UE_ID=107    CELL_ID=1    GNB_ID=2    BEARER_ID=2    RRC_CHECK=True

    Verify tdd-UL-DL-ConfigurationCommon on pcell with    guardPeriod=10    pcell_id=51
    Start NSA traffic  ue=107  dir=dl  traffic_rate=200Mbps
    Start NSA traffic  ue=107  dir=ul  traffic_rate=200Mbps

    Sleep    5s    reason=wait for tput stabilization
    Run keyword and continue on failure    Verify NSA traffic    ue=107    dir=DL    expected_traffic=200Mbps    bearer_type=scg
    Run keyword and continue on failure    Verify NSA traffic    ue=107    dir=UL    expected_traffic=200Mbps    bearer_type=mcg

    Start TTI trace
    Stop TTI trace    delay=10    target_dir=${OUTPUT_DIR}/TTI_Trace/TTI_Traces_10s
    Sleep    15s    reason=Wait for env stabilization

    Start TTI trace collection
    Stop and convert TTI trace collection
    ...    directory_name=CB008453_E_B2_tti_trace
    ...    conversion_filter=utcTimestampData|csiSrReportData|csiRsSchedData|dlFdSchedData|dlHarqRxDataArray|ulFdSchedData|ulHarqRxData
    ...    delay=2

    Start collecting BIP logs
    Stop collecting BIP logs    dir_path=${OUTPUT_DIR}/${TEST_NAME}/CB008453_E_B2_BIP    delay=2

    Convert BIP logs pcap to csv
    ...    pcap_path=${OUTPUT_DIR}/${TEST_NAME}/CB008453_E_B2_BIP/L1L2_BIP_Logs/tcpdump.pcap
    ...    filter=dldata_ssblocksendreql1sw
    ...    columns=@{BIP_columns_SSB_SLOT_SFN}
    ...    dir_path=${OUTPUT_DIR}/${TEST_NAME}/CB008453_E_B2_BIP/
    ...    csv_log_name=BIP_Logs.csv

    Run keyword and continue on failure    Verify HARQ feedback on single PUCCH
    ...                                    csv_directory=${OUTPUTDIR}/${TESTNAME}/CB008453_E_B2_tti_trace/
    Run keyword and continue on failure    Verify periodic csi is transmitting
    ...                                    csv_directory=${OUTPUTDIR}/${TESTNAME}/CB008453_E_B2_tti_trace/
    Run keyword and continue on failure    Verify TRS on slots
    ...                                    slots=2,10,18,26,34,42,50,58
    ...                                    csv_directory=${OUTPUTDIR}/${TESTNAME}/CB008453_E_B2_tti_trace/
    Run keyword and continue on failure    Verify SSB on slots
    ...                                    slots=0,1,2,3,10,11,16,17
    ...                                    bip_csv_directory=${OUTPUTDIR}/${TESTNAME}/CB008453_E_B2_BIP/
    ...                                    tti_csv_directory=${OUTPUTDIR}/${TESTNAME}/CB008453_E_B2_tti_trace/

    [Teardown]    Run keywords
    ...           Detach UE
    ...           UE_ID=107
    ...           AND
    ...           Run keyword and ignore error
    ...           setups_and_teardowns_keywords.Add main BTS metadata to report
