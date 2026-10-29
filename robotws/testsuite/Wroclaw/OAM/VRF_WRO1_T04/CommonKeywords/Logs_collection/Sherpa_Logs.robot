*** Settings ***
Documentation
...    Author:          Jakub Klein
...    Maintainer:      TA team
...    Contact:         jakub.klein@nokia.com
...    Team in charge:  I_EXT_PZ_1_WRO_6_GMS
...    Description:     The following keywords allows to set and start sherpa logs collecting and collect basically parameters
...    from micro__l1l2Trace.csv file for DL or UL PrbPoolingAllocationReport from TEXT column. Note that mplane of BTS
...    must be ipv4 version. Sherpa logs are collecting only with attached UE/UEs.

Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    taf.collectors.l2stream3    WITH NAME    l2stream3
Library    taf.collectors.core    WITH NAME    core
Library    taf.collectors.btslog    WITH NAME   btslog
Library    taf.converters.sherpa     WITH NAME    sherpa
Library    taf.analyzer.sherpa     WITH NAME    sherpa_analyzer
Library    taf.transport.ssh    WITH NAME    ssh
Library    ./Logs_resources/SherpaKeywords.py

Resource    ../Commissioning_preparation/Commissioning.robot

*** Keywords ***
Set Sherpa
    [Documentation]    This keyword set actInternalTrace parameter to value indicated by user. If value indicated is
    ...    currently set then plan is not sending. actordeact takes value: true (activate) or false (deactivate)
    [Arguments]    ${actordeact}
    Get SCF File From BTS
    ${trace}=    Get Value From SCF    dist_name=MRBTS-${tl.gnbs[0].instance_id}/MNL-1/MNLENT-1/TRBLCADM-1    param_name=actInternalTrace
    Run Keyword If    '${trace}'=='False' and '${actordeact}'=='true'
    ...    admin_cli.perform parameter recommissioning    dist_name=MRBTS-${tl.gnbs[0].instance_id}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    parameter=actInternalTrace    value=${actordeact}    operation=update
    ...    ELSE IF    '${trace}'=='True' and '${actordeact}'=='false'
    ...    admin_cli.perform parameter recommissioning    dist_name=MRBTS-${tl.gnbs[0].instance_id}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    parameter=actInternalTrace    value=${actordeact}    operation=update

Create Sherpa Logs File
    [Documentation]    This keyword create file where log files will be saved, under path: path_logs_file
    [Arguments]    ${path_logs_file}=/home/ute/Sherpa_Logs
    ${exist}=    Run Keyword and return status    File Should Exist    ${path_logs_file}
    Run Keyword Unless    ${exist}    Run    mkdir ${path_logs_file}
    [Return]    ${path_logs_file}

Start Sherpa
    [Documentation]    This keyword in first step check whether actInternalTrace is set to true then collector is set and
    ...    started. Keyword takes four arguments:
    ...    mplaneip: it is mplaneip of bts with attached UE from logs are collected which. mplaneip must be ipv4 version
    ...    destinationip: default is set as ip of tl vm where logs are sending
    ...    log_directory: directory where log file .pcap will be saved
    ...    log_name: name of .pcap file with sherpa logs
    ...    Keyword returns path with name of .pcap file
    [Arguments]    ${mplaneip}    ${destinationip}=${tl.test_pc.default_ssh_connection_details.addr}
    ...    ${log_directory}=/home/ute/Sherpa_Logs    ${log_name}=trace
    ${SW}=      admin_cli.get_sw_version
    ${SW1}=     fetch from left    ${SW}    _
    ${dscp}=    Run Keyword If  '${SW1}'=='SBTS23R2'  Set Variable  15  ELSE IF  '${SW1}'=='SBTS23R1'  Set Variable  15
    ...    ELSE IF  '${SW1}'=='SBTS22R4'  Set Variable  46  ELSE IF  '${SW1}'=='SBTS22R3'  Set Variable  46
    Create Sherpa Logs File    ${log_directory}
    Set Sherpa    true
    tcpdump.create tcpdump collector
    ...  name=tcpdump
    ...  options=-i any -v -n port 5678 -w ${log_directory}/${log_name}.pcap
    ...  sudo_password=ute
    ${executor}=    Create Dictionary
    ...  host=192.168.255.1
    ...  user=Nemuadmin
    ...  password=nemuuser
    ...  port=443
    ${l2_stream_config_2}=    Create Dictionary
    ...  trace_type=Sherpa
    @{l2_stream_configuration}    Create List    ${l2_stream_config_2}
    l2stream3.create sbts l2stream collector
    ...  name=l2stream3
    ...  webservice=${executor}
    ...  source_ip_addr=${mplaneip}
    ...  destination_ip_addr=${destinationip}
    ...  dscp=${dscp}
    ...  collector=tcpdump
    ...  l2_stream_configuration=${l2_stream_configuration}
    btslog.set_suite_alias     l2stream3
    core.setup_collectors    names=l2stream3
    core.start_collectors    names=l2stream3
    Log to console    TTI Trace started...
    [Return]    ${log_directory}/${log_name}

Stop Sherpa
    [Documentation]    This keyword stops collect sherpa logs.
    core.stop_collectors    names=l2stream3
    core.collect_collectors    names=l2stream3
    core.teardown_collectors    names=l2stream3
    Log to console    TTI Trace stopped...

Convert pcap to sherpa csv
    [Documentation]    This keyword converts .pcap file to dozen .csv files. It takes two argument:
    ...    converting_file_path: path to .pcap file
    ...    output_file_path: path to directory where converted .csv logs are saved
    [Arguments]    ${converting_file_path}=trace.pcap    ${output_file_path}=/home/ute/Sherpa_Logs
    Create Sherpa Logs File  ${output_file_path}
    sherpa.create sherpa converter
        ...    name=sherpa
        ...    file_path_pattern=${output_file_path}/${converting_file_path}
        ...    output_path=${output_file_path}
    sherpa.setup    sherpa
    ${sherpa_converter_status}=    Run Keyword And Return Status    sherpa.convert    sherpa
    Run Keyword Unless    ${sherpa_converter_status}    Manual Sherpa Converter    ${converting_file_path}    ${output_file_path}
    ${result}=  Run Process  command=wc -l < ${output_file_path}/trace/micro__l1l2Trace.csv  shell=yes
    Run Keyword If  ${result.rc}==1 or ${result.rc}==0  Manual Sherpa converter  ${converting_file_path}    ${output_file_path}
    [Teardown]    sherpa.teardown    sherpa
    [Return]    ${output_file_path}

Manual Sherpa Converter
    [Arguments]    ${converting_file_path}=trace.pcap    ${output_file_path}=/home/ute/Sherpa_Logs
    Run    mkdir -p /tmp/SherpaLogs_sherpa/trace
    Run    cp ${output_file_path}/${converting_file_path} /tmp/SherpaLogs_sherpa/trace/trace.pcap
    Run    sudo /opt/Nokia/Sherpa_5G_18/Sherpa.run --version
    Run    sudo ls -lrt /tmp/SherpaLogs_sherpa/trace/trace.pcap
    Run    sudo /opt/Nokia/Sherpa_5G_18/Sherpa.run --outputdir /tmp/SherpaLogs_sherpa/trace -d 120 -p micro_ /tmp/SherpaLogs_sherpa/trace/trace.pcap
    Run    sudo /opt/Nokia/Sherpa_5G_18/Sherpa.run --outputdir /tmp/SherpaLogs_sherpa/trace -p macro_ -M 1000 /tmp/SherpaLogs_sherpa/trace/trace.pcap
    Run    echo /tmp/SherpaLogs_sherpa/trace/{*.csv,*.pcap}
    Run    sudo cp /tmp/SherpaLogs_sherpa/trace/* ${output_file_path}/trace
    Run    sudo rm -r /tmp/SherpaLogs_sherpa/trace

Remove Sherpa Logs
    [Tags]    WIP
    [Documentation]    This keyword removes .pcap and directory with .csv files if remove is set to ALL
    ...    If remove is set to PCAP then kw removes only .pcap file
    ...    If remove is set to CONVERTED then kw removes only directory with .csv file
    ...    path_for_all: path to directory with .csv files and pcaps
    ...    additional_path: for .csv file saved in another directory than path_for_all
    ...    log_name: name of pcap file and directory with .csv files if additional_path is not specified
    [Arguments]    ${path_for_all}=/home/ute/Sherpa_Logs    ${additional_path}=NONE    ${log_name}=trace    ${remove}=ALL
    ${command}=  Set Variable
    ...  ${path_for_all}/${log_name}.pcap ${path_for_all}/${log_name}/${log_name}.pcap ${additional_path}/${log_name}/${log_name}.pcap
    Run Keyword If    '${remove}'=='PCAP'
    ...    ssh.Execute
    ...    Run  rm -rf ${command}
    ...    ELSE IF    '${remove}'=='CONVERTED' and '${additional_path}'!='NONE'
    ...    Run  rm -rf ${additional_path}/${log_name}
    ...    ELSE IF    '${remove}'=='CONVERTED' and '${additional_path}'=='NONE'
    ...    Run  rm -rf ${path_for_all}/${log_name}
    ...    ELSE IF    '${remove}'=='ALL'  Run Keyword
    ...    Run  rm -rf ${path_for_all} ${additional_path}

Proper Report Name
    [Arguments]    ${dl_or_ul}    ${reports}
    ${reports}=    Get Matches    ${reports}    regexp=${dl_or_ul} PrbPo.+?lingAllocationReport
    ${reports}=    Remove Duplicates    ${reports}
    ${reports}=    Fetch from left    ${reports[0]}    (
    Log    ${reports}
    [Return]    ${reports}

Grep L1L2 File For Parameter
    [Arguments]    ${source}    ${target}    ${parameter}
    Run    head -1 ${source} > ${target}
    Run    cat ${source} | grep -i ${parameter} >> ${target}

Get Value For Parameter
    [Documentation]    As argument this keyword takes:
    ...    path_to_csv: path to direcotory with converted .csv files
    ...    dl_or_ul: with this argument user can specify downlink or uplink PrbPoolingAllocationReport version.
    ...    This argument as default is set to "Dl" for downlink and can be set as "Ul" for uplink
    ...    parameter: this argument specify which parameter from downlink or uplink PrbPoolingAllocationReport for column TEXT is returned
    ...    This keyword returns dictionary with this pattern: sequence::subPoolId::cellId::value(value of indicated parameter)
    [Arguments]    ${path_to_csv}=/home/ute/Sherpa_Logs/trace  ${path_to_grep_file}=${path_to_csv}
    ...    ${dl_or_ul}=Dl    ${report}=PrbPoolingAllocationReport    ${parameter}=PrbAllocated
    ...    ${pattern1}=(?<=SEQ', ')\\d+|(?<=PoolId.)\\d+|(?<=SubPoolId.)\\d+|(?<=PrbAllocated.)\\d+|(?<=NRCellid.).+?\\b
    ...    ${pattern2}=(?<=SEQ', u')\\d+|(?<=PoolId.)\\d+|(?<=SubPoolId.)\\d+|(?<=PrbAllocated.)\\d+|(?<=NRCellid.).+?\\b
    Grep L1L2 File For Parameter    ${path_to_csv}/micro__l1l2Trace.csv    ${path_to_grep_file}/grep_file.csv    ${parameter}
    sherpa_analyzer.Setup Reader    ${path_to_grep_file}/grep_file.csv
    ${reports}=    sherpa_analyzer.Get Values For Column    MSGID
    ${report}=    Run Keyword If    '${report}'!='PrbPoolingAllocationReport'    Set Variable    ${report}
    ...    ELSE IF    '${report}'=='PrbPoolingAllocationReport'    Proper Report Name    ${dl_or_ul}    ${reports}
    ${rows_to_analyze}=    sherpa_analyzer.Get Rows For Matching Column    MSGID    ${report}
    ${text_of_rows}=    Convert To String    ${rows_to_analyze}
    ${subpoolid}=    Get Regexp Matches    ${text_of_rows}    (?<=SubPoolId=).+?\\b
    ${subpoolid}=    Remove Duplicates    ${subpoolid}
    ${l1poolid}=    Get Regexp Matches    ${text_of_rows}    (?<=,PoolId=)\\d+
    ${l1poolid}=    Remove Duplicates    ${l1poolid}
#    ${l1poolid}=    Evaluate    min($l1poolid)
    ${l1poolid_len}=    Get Length    ${l1poolid}
    ${l1poolid}=    Run Keyword If    ${l1poolid_len}==1    Set Variable    ${l1poolid}[0]    ELSE    Set Variable    9
    ${list_of_sequence}=    Create List
    ${dict_of_value}=    Create Dictionary
    ${full_dict}=  Create Dictionary
    FOR  ${item}  IN  @{subpoolid}
        ${temp}=  Create Dictionary
        Set To Dictionary  ${full_dict}  id_${item}  ${temp}
    END
    ${dict_of_value}  ${list_of_sequence}=  get_specify_values
    ...    ${rows_to_analyze}  ${dict_of_value}  ${list_of_sequence}  ${l1poolid}  ${full_dict}  ${pattern1}  ${pattern2}
    [Return]    ${dict_of_value}  ${list_of_sequence}

#Get Value For Parameter
#    [Documentation]    As argument this keyword takes:
#    ...    path_to_csv: path to direcotory with converted .csv files
#    ...    dl_or_ul: with this argument user can specify downlink or uplink PrbPoolingAllocationReport version.
#    ...    This argument as default is set to "Dl" for downlink and can be set as "Ul" for uplink
#    ...    parameter: this argument specify which parameter from downlink or uplink PrbPoolingAllocationReport for column TEXT is returned
#    ...    This keyword returns dictionary with this pattern: sequence::subPoolId::cellId::value(value of indicated parameter)
#    [Arguments]    ${path_to_csv}=/home/ute/Sherpa_Logs/trace  ${path_to_grep_file}=${path_to_csv}
#    ...    ${dl_or_ul}=Dl    ${report}=PrbPoolingAllocationReport    ${parameter}=PrbAllocated
#    Grep L1L2 File For Parameter    ${path_to_csv}/micro__l1l2Trace.csv    ${path_to_grep_file}/grep_file.csv    ${parameter}
#    sherpa_analyzer.Setup Reader    ${path_to_grep_file}/grep_file.csv
#    ${reports}=    sherpa_analyzer.Get Values For Column    MSGID
#    ${report}=    Run Keyword If    '${report}'!='PrbPoolingAllocationReport'    Set Variable    ${report}
#    ...    ELSE IF    '${report}'=='PrbPoolingAllocationReport'    Proper Report Name    ${dl_or_ul}    ${reports}
#    ${rows_to_analyze}=    sherpa_analyzer.Get Rows For Matching Column    MSGID    ${report}
#    ${text_of_rows}=    Convert To String    ${rows_to_analyze}
#    ${l1subpoolid}=    Get Regexp Matches    ${text_of_rows}    (?<=l1SubPoolId=).+?
#    ${l1subpoolid}=    Remove Duplicates    ${l1subpoolid}
#    ${l1poolid}=    Get Regexp Matches    ${text_of_rows}    (?<=,PoolId=)\\d+
#    ${l1poolid}=    Remove Duplicates    ${l1poolid}
#    ${l1poolid}=    Evaluate    min($l1poolid)
#    ${list_of_sequence}=    Create List
#    ${dict_of_value}=    Create Dictionary
#    ${full_dict}=  Create Dictionary
#    :FOR  ${item}  IN  @{l1subpoolid}
#        ${temp}=  Create Dictionary
#        Set To Dictionary  ${full_dict}  id_${item}  ${temp}
#    END
#    :FOR    ${item}    IN    @{rows_to_analyze}
#        ${item}=    Convert To String    ${item}
#        ${l1subpoolid}=    Get Regexp Matches    ${item}    (?<=l1SubPoolId=).+?
#        ${l1subpoolid}=    Convert To String  ${l1subpoolid[0]}
#        ${parameter_value}=    Get Regexp Matches    ${item}
#        ...    (?<=SEQ', ')\\d+|(?<=PoolId=)\\d+|(?<=l1SubPoolId=)\\d+|(?<=PrbAllocated=)\\d+|(?<=NRCellid=)\\d+
#        ${number_of_data}=    Get Length    ${parameter_value}
#        ${parameter_value}=    Run Keyword If  ${number_of_data}!=5    Get Regexp Matches    ${item}
#        ...    (?<=SEQ', u')\\d+|(?<=PoolId=)\\d+|(?<=l1SubPoolId=)\\d+|(?<=PrbAllocated=)\\d+|(?<=NRCellid=)\\d+
#        ...    ELSE    Set Variable    ${parameter_value}
#        Run Keyword If  ${parameter_value[1]}==${l1poolid} and ${parameter_value[2]}==${l1subpoolid}
#        ...    Set To Dictionary    ${full_dict.id_${l1subpoolid}}     @{parameter_value[4:2:-1]}
#        Run Keyword If  ${parameter_value[1]}==${l1poolid} and ${parameter_value[2]}==${l1subpoolid}
#        ...    Set To Dictionary    ${dict_of_value}    ${parameter_value[0]}    ${full_dict}
#        Run Keyword If  ${parameter_value[1]}==${l1poolid} and ${parameter_value[2]}==${l1subpoolid}
#        ...   Append to list  ${list_of_sequence}    ${parameter_value[0]}
#    END
#    ${list_of_sequence}=    Remove Duplicates    ${list_of_sequence}
#    Log To Console   Stop get value
#    [Return]    ${dict_of_value}  ${list_of_sequence}
