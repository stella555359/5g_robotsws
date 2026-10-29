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


*** Variables ***
${gnb_host}=        192.168.255.1
${gnb_user}=        Nemuadmin
${gnb_password}=    nemuuser
${devkr_resources_path}=  /home/ute/MN/UTE/robotws/testsuite/Krakow/RRM/DevKr/resources
${gnb_mirroring_path}=  ${devkr_resources_path}/gNB_mirroring/gnbMirroring.sh
${gnb_mirroring_config_path}=  ${devkr_resources_path}/gNB_mirroring/gnbMirroringConfig.sh

*** Keywords ***
Start collecting BIP logs
    [Documentation]     Collect L1L2 BIP Logs using gnbMirroring.sh script V61
    ...     Script repository: https://gitlabe2.ext.net.nokia.com/juhakang/tools/tree/master/gnbMirroring
    ...     -   :param alias:     Alias for l1l2bip which is also a directory name (default L1L2_BIP_Logs)
    ...     -   :param interface: Interface tcpdump (default any)
    ...     -   :param options:   Addtional options for tcpdump e.g. set bip filter (default empty)
    [Arguments]
    ...     ${alias}=L1L2_BIP_Logs
    ...     ${interface}=any
    ...     ${options}=${EMPTY}

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

Start collecting BIP logs for ASIM
    [Documentation]     Collect L1L2 BIP Logs using taf.ul.gnb.bip.collection - scripting approach
    ...     -   :param alias:     Alias for l1l2bip which is also a directory name (default L1L2_BIP_Logs)
    ...     -   :param bb_mods:   List of BB modules to start collection from them, default: [ABIO]
    [Arguments]
    ...     ${alias}=L1L2_BIP_Logs
    ...     ${bb_mods}=[ABIO]

    bip_collection.Configure Bip Collection     l1_type=FS
    ...                                         gNB_common_unit=ASIM
    ...                                         gNB_capacity_units=${bb_mods}
    ...                                         use_script=True
    bip_collection.Start Bip Trace
    Log to console  BIP logs collecting started

Stop collecting BIP logs for ASIM
    [Documentation]     Stop collecting BIP Logs and save them at selected location
    ...     -   :param alias:       Alias for l1l2bip which is also a directory name without spaces (default L1L2_BIP_Logs)
    ...     -   :param dir_path:    Path where BIP logs should be copied (default ${OUTPUT_DIR}/${TEST_NAME})
    ...     -   :param delay:       Time to wait before collecting the logs
    [Arguments]
    ...     ${alias}=L1L2_BIP_Logs
    ...     ${dir_path}=${OUTPUT_DIR}/${TEST_NAME}
    ...     ${delay}=0
    Sleep  ${delay}
    Create directory  path=${dir_path}/${alias}
    Create directory  path=/tmp/${alias}
    bip_collection.Stop Bip Trace   target_dir=/tmp/${alias}
    ${rc}=    Run And Return Rc  mergecap -a /tmp/${alias}/tcpdump*.pcap* -w /tmp/${alias}/tcpdump.pcap
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

    Log to console    Filter and Converting BIP Log Pcap to csv...

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
    ...  ${CURDIR}/yaml_config/ttitrace_collectors.yaml
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

Convert TTI trace from pcap to excelCsv
    [Arguments]    ${input}=${OUTPUTDIR}/${TESTNAME}/l2stream3/tcpdump/tcpdump.pcap
    ...            ${output}=${OUTPUTDIR}/${TESTNAME}/output
    [Documentation]    This keyword converts tti trace pcap to csv
    ...     -   :param input:           Path to tcpdump.pcap
    ...     -   :param output:          Target directory for generated csv

    eventdecoder.Create eventDecoder converter
    ...  name=ttitrace_converter
    ...  input_file_path=${input}
    ...  output_file_format=excelCsv
    ...  output_file_path=${output}
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
