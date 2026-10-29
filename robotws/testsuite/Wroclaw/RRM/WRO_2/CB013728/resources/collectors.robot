*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS ==
...      - Dawid Chuchnowski <dawid.chuchnowski@nokia.com>
...      == MAINTAINER ==
...      - Dawid Chuchnowski <dawid.chuchnowski@nokia.com>

Library    Collections
Library    OperatingSystem
Library    Process
Library    taf.collectors.tcpdump       WITH NAME    tcpdump
Library    taf.collectors.l1l2bip       WITH NAME    l1l2bip
Library    taf.collectors.core          WITH NAME    core
Library    taf.collectors.l2stream3     WITH NAME    l2stream3
Library    taf.converters.eventdecoder  WITH NAME    eventdecoder
Library    ta_logcollector
Library    taf.ul.gnb.bip.collection    WITH NAME    bip_collection
Library    taf.collectors.syscomdump    WITH NAME    syscomdump
Library    taf.collectors.tshark        WITH NAME    tshark


*** Variables ***
${gnb_host}=        192.168.255.1
${gnb_user}=        Nemuadmin
${gnb_password}=    nemuuser

*** Keywords ***
Start TTI trace
    [Documentation]    Starts TTI trace collection
    ${configurations}=  core.Load Configurations
    ...  ${CURDIR}/ttitrace_collectors.yaml
    core.Create collectors
    ...  names=l2stream3
    ...  configurations=${configurations['collectors']}
    l2stream3.Set suite alias
    ...  alias=l2stream3
    core.Setup collectors
    ...  names=l2stream3
    core.Start collectors
    ...  names=l2stream3

Stop TTI trace
    [Arguments]    ${target_dir}=${OUTPUTDIR}/${TESTNAME}   ${delay}=0
    [Documentation]    Stops tti trace collecting and saves pcap at specified directory
    ...     -   :param target_dir:           Target directory for saved pcap
    ...     -   :param delay:       Time to wait before collecting the logs
    Sleep  ${delay}
    core.Stop collectors
    ...  names=l2stream3
    core.Collect collectors
    ...  names=l2stream3
    ...  target_dir=${target_dir}
    core.Teardown collectors
    ...  names=l2stream3

Convert TTI trace pcap
    [Arguments]    ${input}=${OUTPUTDIR}/${TESTNAME}/l2stream3/tcpdump/tcpdump.pcap
    ...            ${output}=${OUTPUTDIR}/${TESTNAME}/output
    ...            ${format}=excelCsv
    ...            ${conversion_filter}=None
    [Documentation]    This keyword converts tti trace pcap to csv
    ...     -   :param input:           Path to tcpdump.pcap
    ...     -   :param output:          Target directory for generated csv
    ...     -   :param format:          excelCsv (default) or json

    eventdecoder.Create eventDecoder converter
    ...  name=ttitrace_converter
    ...  input_file_path=${input}
    ...  output_file_format=${format}
    ...  output_file_path=${output}
    ...  conversion_filter=${conversion_filter}
    eventdecoder.Convert
    ...  name=ttitrace_converter

Start syscomdump collection
    [Documentation]  Starts syscomdump logs collection
    ${executor_oam_vm}=    Create Dictionary
    ...    host=192.168.255.129
    ...    user=toor4nsn
    ...    password=oZPS0POrRieRtu
    syscomdump.create_syscomdump_collector
    ...    name=syscomdump
    ...    options=-i any
    ...    executor=${executor_oam_vm}
    core.Set suite alias
    ...  alias=syscomdump
    core.setup_collectors    names=syscomdump
    core.start_collectors    names=syscomdump

Stop syscomdump collection
    [Arguments]   ${target_dir}=${OUTPUTDIR}/${TESTNAME}    ${delay}=0
    [Documentation]  Stops syscomdump logs collection  and saves pcap at specified directory
    ...    -  :param target_dir:    Target directory for saved pcap
    ...    -  :param delay:         Time to wait before collecting the logs
    Sleep  ${delay}
    core.stop_collectors
    ...  names=syscomdump
    core.collect_collectors
    ...  names=syscomdump
    ...  target_dir=${target_dir}
    core.teardown_collectors
    ...  names=syscomdump

Start Tshark collection from local machine
    [Arguments]    ${options}=-i any
    [Documentation]  Start Tshark collection from local machine
    ...  +------------------+-------+------------+------------+------------+------------+
    ...  |     Example                                                                  |
    ...  +==================+=======+============+============+============+============+
    ...  | Start Tshark collection from local machine  options=-i eth4                  |
    ...  +------------------+-------+------------+------------+------------+------------+
    ...  :param options:        tshark options (except for "-w"), default: -i any

    tshark.create_tshark_collector
    ...    name=tshark
    ...    options=${options}
    ...    sudo_password=${tl.test_pc.default_ssh_connection_details.password}
    core.set_suite_alias     alias=tshark
    core.setup_collectors    names=tshark
    core.start_collectors    names=tshark


Stop Tshark collection from local machine
    [Arguments]    ${outputPath}=${OUTPUTDIR}/${TESTNAME}
    [Documentation]  Stop Tshark collection from local machine and saves pcap at specified directory
    ...  +------------------+-------+------------+------------+------------+------------+
    ...  |     Example                                                                  |
    ...  +==================+=======+============+============+============+============+
    ...  | Stop Tshark collection from local machine                                    |
    ...  +------------------+-------+------------+------------+------------+------------+
    ...  :param outputPath:    (optional) path of tshark executable, default value: ${OUTPUTDIR}/${TESTNAME}

    core.stop_collectors       names=tshark
    core.collect_collectors    names=tshark	 target_dir=${outputPath}
    core.teardown_collectors   names=tshark
