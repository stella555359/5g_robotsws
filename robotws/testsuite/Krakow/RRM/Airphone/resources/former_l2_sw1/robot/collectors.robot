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
${gnb_host}=        192.168.255.129
${gnb_user}=        Nemuadmin
${gnb_password}=    nemuuser

*** Keywords ***
Start collecting BIP logs
    [Documentation]     Collect L1L2 BIP Logs using gnbMirroring.sh script V61
    ...     Script repository: https://gitlabe2.ext.net.nokia.com/juhakang/tools/tree/master/gnbMirroring
    ...     -   :param alias:     Alias for l1l2bip which is also a directory name (default L1L2_BIP_Logs)
    [Arguments]
    ...     ${alias}=L1L2_BIP_Logs

    ${webservice}=  Create Dictionary
    ...    host=${gnb_host}
    ...    user=${gnb_user}
    ...    password=${gnb_password}
    ...    port=443
    l1l2bip.create_interface_mirroring_l1l2bip_collector
    ...  name=${alias}
    ...  webservice=${webservice}
    ...  timeout=300
    l1l2bip.Set suite alias  ${alias}
    core.setup_collectors    names=${alias}
    core.start_collectors    names=${alias}
    Log to console  BIP logs collecting started

Stop collecting BIP logs
    [Documentation]     Stop collecting BIP Logs and save them at selected location
    ...     -   :param alias:       Alias for l1l2bip which is also a directory name without spaces (default L1L2_BIP_Logs)
    ...     -   :param dir_path:    Path where BIP logs should be copied (default ${OUTPUT_DIR}/${TEST_NAME})
    ...     -   :param delay:       Time to wait before collecting the logs
    [Arguments]
    ...     ${alias}=L1L2_BIP_Logs
    ...     ${dir_path}=${OUTPUT_DIR}/${TEST_NAME}
    ...     ${delay}=0
    Sleep  ${delay}
    core.stop_collectors  names=${alias}
    core.collect_collectors  names=${alias}  target_dir=/tmp
    core.teardown_collectors  names=${alias}
    ${rc}=    Run And Return Rc  mergecap -a /tmp/${alias}/BTS*.pcap -w /tmp/${alias}/tcpdump.pcap
    Run keyword if    ${rc}!=0    Fail    PCAP merging failed, check if alias does not contain spaces
    Copy File    /tmp/${alias}/tcpdump.pcap    ${dir_path}/${alias}/tcpdump.pcap
    Remove directory    /tmp/${alias}    recursive=True
    Log to console  BIP logs collecting finished

Convert BIP logs pcap to csv
    [Arguments]    ${pcap_path}    ${filter}    ${columns}    ${dir_path}=${OUTPUT_DIR}    ${csv_log_name}=BIP_Logs.csv
    [Documentation]    This keyword converts BIP logs pcap to csv
    ...     -   :param pcap_path:       Path to BIP logs pcap
    ...     -   :param filter:          Filter to reduce file size (e.g. dldata_slottypereq || dldata_pdcchsendreq)
    ...     -   :param dir_path:        Path for output csv file (default OUTPUT_DIR)
    ...     -   :param csv_log_name:    Name for generated csv (default BIP_Logs.csv)
    ...     -   :param columns:         Fields to be displayed in csv columns (list defined in Variables section)
    ...
    ...    Example:
    ...    To get csv column of noisePerPrb_item_122 field the column indicator should be created as follows:
    ...                         <BIP_message_name>.<parent_object_of_needed_field>.<field>
    ...                         UlData_PuschReceiveRespPs.noisePerPrb.noisePerPrb_item_122
    ...
    ...    *** Variables ***
    ...    @{BIP_columns_1st_example}=  DlData_SlotTypeReq.SlotTypeReq.slot  DlData_SlotTypeReq.SlotTypeReq.slotType
    ...    @{BIP_columns_2nd_example}=  UlData_PuschReceiveRespPs.noisePerPrb.noisePerPrb_item_122
    ...                         ...
    ...    Convert BIP logs pcap to csv
    ...    ...  pcap_path=${OUTPUT_DIR}/${TEST_NAME}/L1L2_BIP_Logs/tcpdump.pcap
    ...    ...  filter=dldata_slottypereq || dldata_pdcchsendreq
    ...    ...  dir_path=${OUTPUT_DIR}
    ...    ...  csv_log_name=SlotTypeReq.csv
    ...    ...  columns=@{BIP_columns_1st_example}

    Log to console    Converting BIP Log Pcap to csv...

    ${columns_string}    Catenate    SEPARATOR=${SPACE}-e${SPACE}  @{columns}
    ${cmd}      catenate    tshark
    ...         -r ${pcap_path}
    ...         -Y "${filter}"
    ...         -T fields -e ${columns_string}
    ...         -E header=y -E separator=, -E occurrence=a > ${dir_path}/${csv_log_name}
    ${rc}    OperatingSystem.Run And Return RC    ${cmd}

    Log to console    ...conversion done

    [Return]    ${dir_path}/${csv_log_name}

Start TTI trace
    [Documentation]    Starts TTI trace collection
    ${configurations}=  core.Load Configurations
    ...  ${CURDIR}/../yaml_config/ttitrace_collectors.yaml
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

Start Logcollector
    ${use_logcollector}    Get variable value    ${lc}    "True"
    Run keyword if  ${use_logcollector}=="True"
    ...     Start collecting logs
    ...     ELSE
    ...     Log  Logcollector was omitted by user

Stop Logcollector
    ${use_logcollector}    Get variable value    ${lc}    "True"
    Run keyword if  ${use_logcollector}=="True"
    ...     Stop collecting logs
    ...     ELSE
    ...     Log  Logcollector was omitted by user

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
