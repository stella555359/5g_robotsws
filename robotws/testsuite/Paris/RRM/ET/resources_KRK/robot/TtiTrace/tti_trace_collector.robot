*** Settings ***
Documentation
...   author: Kamil Bucki
...   contact: kamil.bucki@nokia.com
...   description: Krakow Verification Engineering team common ttitrace keywords

Library     ../../python/utilities.py    WITH NAME  logger
Library     Collections
Library     OperatingSystem
Library     taf.collectors.tcpdump       WITH NAME  tct
Library     taf.collectors.l2stream3     WITH NAME  tcl
Library     taf.collectors.core          WITH NAME  tcc
Library     taf.converters.eventdecoder  WITH NAME  tce
Library     testsuite.Paris.RRM.ET.resources_KRK.python.common_gnb    WITH NAME    common_gnb

*** Keywords ***

Start TTI Trace Collection
    [Arguments]    ${collector_name}=l2stream3
    ...            ${yaml_config_path}=${CURDIR}/tti_trace_collectors.yaml
    ...            ${release}=${None}
    ...            ${cell_ids}=${None}

    ${RELEASE_NO_CONV_var_exists} =    Run Keyword And Return Status    Variable Should Exist    ${RELEASE_NO_CONV}
    ${release} =    Run Keyword If    '${release}' == '${None}' and ${RELEASE_NO_CONV_var_exists} == ${False}
    ...                               common_gnb.get_gnb_build_release    convert_to_trunk=${False}
    ...             ELSE IF           '${release}' == '${None}' and ${RELEASE_NO_CONV_var_exists} == ${True}
    ...                               Get Variable Value    ${RELEASE_NO_CONV}
    ...             ELSE              Get Variable Value    ${release}

    ${configurations} =    tcc.Load Configurations    ${yaml_config_path}
    ${webservices} =    Set To Dictionary    ${configurations['webservices'][0]}    release=${release}
    ${configurations} =    Set To Dictionary    ${configurations}    webservices=${webservices}    dscp=${15}
    Run Keyword If      '${cell_ids}' != '${None}'
    ...                 Set To Dictionary    ${configurations['collectors'][1]['l2_stream_configuration'][0]}    nr_phy_cell_ids=${cell_ids}
    tcc.Create Collectors
    ...    names=${collector_name}
    ...    configurations=${configurations['collectors']}
    tcl.Set Test Alias
    ...    alias=${collector_name}
    tcc.Setup Collectors
    ...    names=${collector_name}
    tcc.Start Collectors
    ...    names=${collector_name}
    logger.Logger Console    TTI traces collecting started


Stop TTI Trace Collection
    [Arguments]    ${collector_name}=l2stream3    ${target_path}=${OUTPUT_DIR}/${SUITE_NAME}/${TEST_NAME}
    logger.Logger Console    Stopping TTI traces collecting
    tcc.Stop Collectors
    ...    names=${collector_name}
    tcc.Collect Collectors
    ...    names=${collector_name}
    ...    target_dir=${target_path}
    tcc.Teardown Collectors
    ...    names=${collector_name}


Collect TTI Traces During
    [Arguments]    ${sec}
    Start TTI Trace Collection
    Sleep    ${sec}
    Stop TTI Trace Collection


Relocate TTI Traces Collected
    [Arguments]    ${collector_name}=l2stream3    ${target_path}=${OUTPUT_DIR}/${SUITE_NAME}/${TEST_NAME}
    [Documentation]    This keyword was created for backward compatibility purposes when "Stop TTI trace collection"
    ...                functionality was split into stopping traces collecton and relocating (and cleanup)
    ...                collected pcap files.

    Move File    ${target_path}/${collector_name}/tcpdump/*    ${target_path}
    Remove Directory    ${target_path}/${collector_name}    recursive=True


Convert TTI Trace From Pcap
    [Arguments]    ${target_files_path}
    ...            ${collector_name}=l2stream3
    ...            ${format}=excelCsv
    ...            ${target_filename}=output
    ...            ${source_file_path}=${OUTPUT_DIR}/${SUITE_NAME}/${TEST_NAME}/${collector_name}/tcpdump/tcpdump.pcap
    ...            ${conversion_filter}=${None}

    logger.Logger Console    Converting TTI traces to ${format}
    tce.Create eventDecoder Converter
    ...    name=ttitrace_converter
    ...    input_file_path=${source_file_path}
    ...    output_file_format=${format}
    ...    output_file_path=${target_files_path}/${target_filename}
    ...    conversion_filter=${conversion_filter}
    tce.Convert
    ...    name=ttitrace_converter


Relocate And Cleanup TTI Traces Collected And Converted
    [Arguments]    ${target_path}    ${collector_name}=l2stream3
    [Documentation]    This keyword was created for backward compatibility purposes when "Stop TTI trace collection"
    ...                functionality was split into stopping traces collecton and relocating (and cleanup)
    ...                collected pcap files.

    Move Directory    ${OUTPUT_DIR}/${SUITE_NAME}/${TEST_NAME}/${collector_name}/tcpdump/    ${target_path}
    Remove Directory    ${OUTPUT_DIR}/${SUITE_NAME}/${TEST_NAME}/${collector_name}    recursive=True
