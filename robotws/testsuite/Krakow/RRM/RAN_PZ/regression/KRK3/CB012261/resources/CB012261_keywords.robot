*** Settings ***
Documentation    Keywords for CB012261
...              authors: Aleksandra Faliszek
...              contact: aleksandra.faliszek@nokia.com

Library     taf.collectors.l2stream3                        WITH NAME  tcl
Library     taf.collectors.core                             WITH NAME  tcc
Library     taf.converters.eventdecoder                     WITH NAME  tce
Library     taf.rfrl.utilities.logger.custom_logger         WITH NAME   logger
Library     CsvVerification.py                              WITH NAME   csv
Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/ue/robot/REAL_UE.robot

*** Variables ***
${COLLECT_LOGS_DURING_DATA_TRANSFER}    False
${ENABLE_RACH_OBSERVER}  ${False}

*** Keywords ***
Enable feature CB012261
    [Documentation]     Enable feature CB012261
    [Arguments]    @{cell_ids}
    FOR    ${cell_id}    IN    @{cell_ids}
        Perform Configuration Parameter Recommissioning On gNB
        ...                                         dist_name=MRBTS-{}/NRBTS-{}/NRCELL-${cell_id}
        ...                                         param_name=actPrachMultiplexingLevel
        ...                                         operation=update
        ...                                         param_value=enabled_Level1
        ...                                         skip_parameter_relation_errors=${false}
        ...                                         timeout=300
        Wait for cell to be OnAir    cell_id=${cell_id}
    END
    logger.Log info To Console  CB012261 Feature enabled

Disable feature CB012261
    [Documentation]     Disable feature CB012261
    [Arguments]    @{cell_ids}
    FOR    ${cell_id}    IN    @{cell_ids}
        Perform Configuration Parameter Recommissioning On gNB
        ...                                         dist_name=MRBTS-{}/NRBTS-{}/NRCELL-${cell_id}
        ...                                         param_name=actPrachMultiplexingLevel
        ...                                         operation=update
        ...                                         param_value=disabled
        ...                                         skip_parameter_relation_errors=${false}
        ...                                         timeout=300
        Wait for cell to be OnAir    cell_id=${cell_id}
    END
    logger.Log info To Console  CB012261 Feature disabled

Verify NSA L3 call
    ue.Reboot Ue    UE      timeout=60
    Log To Console  \n===Attach UE ===
    ue.Attach Ue    UE
    Verify L3 Call One Way Data Transfer    direction=dl    duration=60s    tput=580 Mbits/sec
    Log To Console  \n===Detach UE ===
    ue.Detach UE    UE

Start TTI Trace Collection
    [Arguments]    ${collector_name}=l2stream3
    ...            ${yaml_config_path}=${CURDIR}/tti_trace_collectors.yaml
    ${configurations} =    tcc.Load Configurations    ${yaml_config_path}
    tcc.Create Collectors
    ...    names=${collector_name}
    ...    configurations=${configurations['collectors']}
    tcl.Set Test Alias
    ...    alias=${collector_name}
    tcc.Setup Collectors
    ...    names=${collector_name}
    tcc.Start Collectors
    ...    names=${collector_name}
    logger.Log info To Console    TTI traces collecting started

Stop TTI Trace Collection
    [Arguments]    ${collector_name}=l2stream3    ${target_path}=${OUTPUT_DIR}/${TEST_NAME}
    logger.Log info To Console    Stopping TTI traces collecting
    tcc.Stop Collectors
    ...    names=${collector_name}
    tcc.Collect Collectors
    ...    names=${collector_name}
    ...    target_dir=${target_path}
    tcc.Teardown Collectors
    ...    names=${collector_name}

Convert TTI trace pcap
    [Arguments]    ${input}=${OUTPUTDIR}/${TESTNAME}/l2stream3/tcpdump/tcpdump.pcap
    ...            ${output}=${OUTPUTDIR}/${TESTNAME}/output
    ...            ${format}=excelCsv
    ...            ${conversion_filter}=None
    [Documentation]    This keyword converts tti trace pcap to csv
    ...     -   :param input:           Path to tcpdump.pcap
    ...     -   :param output:          Target directory for generated csv
    ...     -   :param format:          excelCsv (default) or json

    tce.Create eventDecoder converter
    ...  name=ttitrace_converter
    ...  input_file_path=${input}
    ...  output_file_format=${format}
    ...  output_file_path=${output}
    ...  conversion_filter=${conversion_filter}
    tce.Convert
    ...  name=ttitrace_converter

Perform 5G Attach and collect TTI Trace for TDD TC
    Attach Ue      Smawave
    Start Data Transfer     DT_1    Smawave    UL    protocol=udp   throughput=170Mbits/sec    packet=1400B
    Sleep   30s
    Start TTI Trace Collection
    Sleep   5s
    Stop TTI Trace Collection
    Stop Data Transfer     DT_1
    Detach Ue   Smawave
    Convert TTI trace pcap

Perform 5G Attach and collect TTI Trace for FDD TC
    Attach Ue      Smawave
    Start Data Transfer     DT_1    Smawave    UL    protocol=udp   throughput=120Mbits/sec    packet=1400B     apn=5gbothkrk
    Sleep   30s
    Start TTI Trace Collection      yaml_config_path=${CURDIR}/tti_trace_collectors_FDD.yaml
    Sleep   5s
    Stop TTI Trace Collection
    Stop Data Transfer     DT_1
    Detach Ue   Smawave
    Convert TTI trace pcap

Get PRB Values
    [Arguments]    ${filename}
    ${csv_list}=    csv.Create List Of Lists From Csv   ${OUTPUTDIR}/${TESTNAME}/output_ul.csv
    ${result}=      csv.Extract Filtered Prb
    ${output_path}=    Set Variable    ${OUTPUTDIR}/${TESTNAME}/${filename}
    csv.Save Filtered Prb To Csv    ${result}    ${output_path}

Compare PRB Between Two Runs for TDD TC
    csv.Compare PRB Csv Files    ${OUTPUTDIR}/${TESTNAME}/feature_off.csv    ${OUTPUTDIR}/${TESTNAME}/feature_on.csv    slots_filter=8,9,18,19

Compare PRB Between Two Runs for FDD TC
    csv.Compare PRB Csv Files    ${OUTPUTDIR}/${TESTNAME}/feature_off.csv    ${OUTPUTDIR}/${TESTNAME}/feature_on.csv    slots_filter=4
