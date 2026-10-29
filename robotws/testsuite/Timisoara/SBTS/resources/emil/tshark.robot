*** Settings ***
Documentation   AUTHOR_johnny.1.jiang@nokia-sbell.com
Library    OperatingSystem
Library   Collections
Library   String
Library    taf.transport.ssh   WITH NAME   csn
Variables   ../libraries/sherpa_server_1.py
Library     ../libraries/snapshot_files.py
Library    taf.analyzer.pcap   WITH NAME   wireshark
Resource   decode.robot

*** Variables ***
${tshark_path}      /usr/bin/tshark
${luashark_path}    /home/ute/interfaces_lua/luashark.lua

*** Keywords ***
Copy Luashark to Local
    Csn.Connect to   hostname=${sherpa_server_ip}    username=${sherpa_server_username}    password=${sherpa_server_password}
    ...    alias=sherpa_vm
    csn.execute    command=cd /cygdrive/c/Users/nokia5g/AppData/Roaming/NOKIA/Sherpa5G_18/;cp -r interfaces_lua /home/nokia5G/
    ...    connection=sherpa_vm
    csn.execute    command=cd /home/nokia5G/interfaces_lua;tar -cvf luashark.tar *     connection=sherpa_vm
    csn.Download File   remote_path=/home/nokia5G/interfaces_lua/luashark.tar   local_path=/home/ute/luashark.tar   connection=sherpa_vm
    run    cd /home/ute;sudo rm -rf interfaces_lua;mkdir interfaces_lua;tar xf /home/ute/luashark.tar -C /home/ute/interfaces_lua
    [Teardown]    csn.Disconnect    connection=sherpa_vm

Load Pcap File with Filter
    [Arguments]    ${input_file}    ${filter}=L2Log_StreamInd_t.utcTimeStampMicro==868590
    ...   ${filter_expression}=L2Log_StreamInd_t.utcTimeStampMicro == 868590 && L2Log_StreamIndSherpa_t.traceSeqNum == 16665
    ${command_template_with_Y}   set variable
    ...   {tshark_path} -r {input_file} -X lua_script:${luashark_path} -Y ${filter} -T pdml > {output_file}
    ${all_packets}    wireshark.load_pcap_file    pcap_file=${input_file}
    ...   tshark_path=${tshark_path}   command_template=${command_template_with_Y}
    ${filtered_packets}=    wireshark.filter_packets_by_expression
    ...   filter_expression=${filter_expression}
    [Return]   ${filtered_packets}

Check Bit length of parameters by name in wireshark
    [Arguments]    ${input_file}     #${field_name}
    ${command_template_with_Y}   set variable   {tshark_path} -r {input_file} -X lua_script:${luashark_path} -T pdml > {output_file}
    ${all_packets}    wireshark.load_pcap_file    pcap_file=${input_file}
    ...   tshark_path=${tshark_path}   command_template=${command_template_with_Y}
    ${tshark_value}=    wireshark.get_field_value_by_name
    ...   field_name=DU_L2LO_PDU_DL_REPORT_t.tbSizev2   attribute_name=showname
    ${tshark_value}   Replace String   ${tshark_value[0].split('=')[0]}   ${space}   ${empty}
    ${tshark_value}   Split String To Characters   ${tshark_value}
    ${count}   set variable   ${0}
    FOR   ${index}  IN   @{tshark_value}
       Run Keyword if   '${index}'=='0' or '${index}'=='1'   Set Suite Variable    ${count}      ${count+1}
    END
    [Return]   ${all_packets}    ${count}

Check Bit length of parameters in wireshark
    [Arguments]    ${input_file}   ${xpath}   ${filter}   ${filter_expression}
    ${filtered_packets}   Load Pcap File with Filter    input_file=${input_file}   filter=${filter}
    ...   filter_expression=${filter_expression}
    ${tshark_value}=    wireshark.get_field_value_by_xpath    pdml_list=${filtered_packets}   xpath=${xpath}   attribute_name=showname
    ${tshark_value}   Replace String   ${tshark_value[0].split('=')[0]}   ${space}   ${empty}
    ${tshark_value}   Split String To Characters   ${tshark_value}
    ${count}   set variable   ${0}
    FOR   ${index}  IN   @{tshark_value}
       Run Keyword if   '${index}'=='0' or '${index}'=='1'   Set Suite Variable    ${count}      ${count+1}
    END
    [Return]    ${count}

Check value in wireshark with sharpa log
    [Arguments]   ${input_file}   ${xpath}   ${filter}   ${filter_expression}
    ${filtered_packets}   Load Pcap File with Filter
    ...   input_file=${input_file}   filter=${filter}   filter_expression=${filter_expression}
    ${tshark_value}=    wireshark.get_field_value_by_xpath    pdml_list=${filtered_packets}   xpath=${xpath}
    [Return]     ${tshark_value}

