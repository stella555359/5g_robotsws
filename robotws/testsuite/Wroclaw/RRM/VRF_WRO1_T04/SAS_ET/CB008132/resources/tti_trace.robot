*** Settings ***
Documentation
...   author: Kamil Bucki
...   contact: kamil.bucki@nokia.com
...   description: Krakow Verification Engineering team common ttitrace keywords for CB008132 feature

Library    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/utilities.py  WITH NAME  utilities__
Library     taf.collectors.tcpdump                             WITH NAME       tct
Library     taf.collectors.l2stream3                           WITH NAME       tcl
Library     taf.collectors.core                                WITH NAME       tcc
Library     taf.converters.eventdecoder                        WITH NAME       tce

Resource    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Robot/TtiTrace/tti_trace_collector.robot

*** Keywords ***

Start TTI trace collection
    [Arguments]  ${collector_name}
    ${configurations}=  tcc.Load Configurations
    ...  ${CURDIR}/tti_trace_collectors.yaml
    ${webservices}=  Set To Dictionary    ${configurations['webservices'][0]}    release=${RELEASE_NO_CONV}
    ${configurations}=  Set To Dictionary    ${configurations}    webservices=${webservices}   dscp=${15}
    tcc.Create Collectors
    ...  names=${collector_name}
    ...  configurations=${configurations['collectors']}
    tcl.Set Suite Alias
    ...  alias=${collector_name}
    tcc.Setup Collectors
    ...  names=${collector_name}
    tcc.Start Collectors
    ...  names=${collector_name}
    logger.Logger Console    ${\n}TTI traces collecting started

Start TTI trace collecting
    [Arguments]     ${collector_name}
    utilities__.Logger Console        Starting TTi Trace Collection
    tti_trace.Start TTI trace collection
    ...  collector_name=${collector_name}

Stop TTI trace collecting
    [Arguments]     ${collector_name}   ${target_path}
    utilities__.Logger Console        Stoping TTi Trace Collection
    Stop TTI trace collection
    ...  collector_name=${collector_name}
    ...  target_path=${target_path}
    Relocate TTI traces collected
    ...  collector_name=${collector_name}
    ...  target_path=${target_path}

Convert TTI Trace
    [Arguments]     ${target_path}  ${format}  ${source_file_path}
    utilities__.Logger Console        Conveting TTi Trace logs
    Convert TTI trace from pcap
    ...  format=${format}
    ...  source_file_path=${source_file_path}
    ...  target_files_path=${target_path}

