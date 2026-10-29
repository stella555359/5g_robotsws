*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_TDD    SBTS00

Documentation
...    author: Wiktoria Janik
...    contact: wiktoria.janik@nokia.com

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
[1][1.0] CB008453-A_B3_Single_UE_scheduling_without_carrier_aggregation_with_different_PRACH_config_index
    CB008453 feature enable
    Disable CA

    Set prach configuration index    prachConfigurationIndex=32
    Wait for enb on air    timeout=600

    Attach ue and start traffic
    Verify TTI traces    prach_index=${prachConfigurationIndex}    TRS_Slots=3,11,19,27,35,43,51,59    SSB_Slots=0,1,2,3,10,11,16,17
    Detach UE    UE_ID=107

    Cells locked
    Set prach configuration index    prachConfigurationIndex=55
    Cells unlocked

    Attach ue and start traffic
    Verify TTI traces    prach_index=${prachConfigurationIndex}    TRS_Slots=3,11,19,27,35,43,51,59    SSB_Slots=0,1,2,3,10,11,16,17
    Detach UE    UE_ID=107

    Cells locked
    Set prach configuration index    prachConfigurationIndex=147
    Cells unlocked

    Attach ue and start traffic
    Verify TTI traces    prach_index=${prachConfigurationIndex}    TRS_Slots=3,11,19,27,35,43,51,59    SSB_Slots=0,1,2,3,10,11,16,17
    Detach UE    UE_ID=107

    Cells locked
    Set prach configuration index    prachConfigurationIndex=162
    Cells unlocked

    Attach ue and start traffic
    Verify TTI traces    prach_index=${prachConfigurationIndex}    TRS_Slots=3,11,19,27,35,43,51,59    SSB_Slots=0,1,2,3,10,11,16,17
    Detach UE    UE_ID=107

    Cells locked
    Set prach configuration index    prachConfigurationIndex=180
    Cells unlocked

    Attach ue and start traffic
    Verify TTI traces    prach_index=${prachConfigurationIndex}    TRS_Slots=3,11,19,27,35,43,51,59    SSB_Slots=0,1,2,3,10,11,16,17
    Detach UE    UE_ID=107

    Cells locked
    Set prach configuration index    prachConfigurationIndex=198
    Cells unlocked

    Attach ue and start traffic
    Verify TTI traces    prach_index=${prachConfigurationIndex}    TRS_Slots=3,11,19,27,35,43,51,59    SSB_Slots=0,1,2,3,10,11,16,17

    [Teardown]    Run keywords
    ...           Detach UE
    ...           UE_ID=107
    ...           AND
    ...           Run keyword and ignore error
    ...           setups_and_teardowns_keywords.Add main BTS metadata to report

*** Keywords ***
Attach ue and start traffic
    Attach UE    UE_ID=107
    SgNB Addition    UE_ID=107    CELL_ID=1    GNB_ID=2    BEARER_ID=2    RRC_CHECK=True
    Verify tdd-UL-DL-ConfigurationCommon on pcell with    guardPeriod=2    pcell_id=51
    Start NSA traffic    ue=107    dir=dl    traffic_rate=200Mbps
    Start NSA traffic    ue=107    dir=ul    traffic_rate=50Mbps

    Sleep    5s    reason=wait for tput stabilization
    Run keyword and continue on failure    Verify NSA traffic    ue=107    dir=DL    expected_traffic=200Mbps    bearer_type=scg
    Run keyword and continue on failure    Verify NSA traffic    ue=107    dir=UL    expected_traffic=50Mbps    bearer_type=mcg

Cells locked
    ${cell_administrativeState}=    Set variable    Locked
    Set enb parameter value
    ...  param_path=cell_administrativeState
    ...  value=${cell_administrativeState}
    ...  bts_id=1
    Configure and wait    ${CURDIR}/config/cells_administrativeState.yaml

Cells unlocked
    ${cell_administrativeState}=    Set variable        Unlocked
    Set enb parameter value
    ...  param_path=cell_administrativeState
    ...  value=${cell_administrativeState}
    ...  bts_id=1
    Configure and wait    ${CURDIR}/config/cells_administrativeState.yaml
    Wait for enb on air    timeout=600

Set prach configuration index
    [Arguments]    ${prachConfigurationIndex}
    Set test variable    ${prachConfigurationIndex}
    Set enb parameter value
    ...  param_path=prachConfigurationIndex
    ...  value=${prachConfigurationIndex}
    ...  bts_id=1
    Configure    ${CURDIR}/config/prachConfigurationIndex_8cells.yaml

Verify TTI traces
    [Arguments]    ${prach_index}    ${TRS_Slots}    ${SSB_Slots}
    Start TTI trace collection
    Stop and convert TTI trace collection
    ...    directory_name=CB008453_E_B1_tti_trace_${prach_index}
    ...    conversion_filter=utcTimestampData|csiSrReportData|csiRsSchedData|dlFdSchedData|dlHarqRxDataArray|ulFdSchedData|ulHarqRxData
    ...    delay=1

    Start collecting BIP logs
    Stop collecting BIP logs    dir_path=${OUTPUT_DIR}/${TEST_NAME}/CB008453_E_B1_BIP_${prach_index}    delay=1

    Convert BIP logs pcap to csv
    ...    pcap_path=${OUTPUT_DIR}/${TEST_NAME}/CB008453_E_B1_BIP_${prach_index}/L1L2_BIP_Logs/tcpdump.pcap
    ...    filter=dldata_ssblocksendreql1sw
    ...    columns=@{BIP_columns_SSB_SLOT_SFN}
    ...    dir_path=${OUTPUT_DIR}/${TEST_NAME}/CB008453_E_B1_BIP_${prach_index}/
    ...    csv_log_name=BIP_Logs.csv

    Run keyword and continue on failure    Verify HARQ feedback on single PUCCH
    ...                                    csv_directory=${OUTPUTDIR}/${TESTNAME}/CB008453_E_B1_tti_trace_${prach_index}/
    Run keyword and continue on failure    Verify periodic csi is transmitting
    ...                                    csv_directory=${OUTPUTDIR}/${TESTNAME}/CB008453_E_B1_tti_trace_${prach_index}/
    Run keyword and continue on failure    Verify TRS on slots
    ...                                    slots=${TRS_Slots}
    ...                                    csv_directory=${OUTPUTDIR}/${TESTNAME}/CB008453_E_B1_tti_trace_${prach_index}/
    Run keyword and continue on failure    Verify SSB on slots
    ...                                    slots=${SSB_Slots}
    ...                                    bip_csv_directory=${OUTPUTDIR}/${TESTNAME}/CB008453_E_B1_BIP_${prach_index}/
    ...                                    tti_csv_directory=${OUTPUTDIR}/${TESTNAME}/CB008453_E_B1_tti_trace_${prach_index}/
