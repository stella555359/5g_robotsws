*** Settings ***
Documentation    This is for fading
...              Contacts: jiajian.bi@nokia-sbell.com
Library    taf.analyzer.pcap        WITH NAME    pcap
Resource        1347_common_keyword.robot
Library         fad.py
Library         send.py

*** Variables ***
${tshark_path}    /usr/bin/tshark
${expression_cmas1}    \"uldata_puschreceiverespps\"
${expression_cmas2}    \"uldata_puschreceivereq\"
${command_template1}    {tshark_path} -r {input_file} -X lua_script:{luashark_path} -Y ${expression_cmas1} -T pdml > {output_file}
${command_template2}    {tshark_path} -r {input_file} -X lua_script:{luashark_path} -Y ${expression_cmas2} -T pdml > {output_file}
${time}          frame.time_relative
${field_name1}    UlData_PuschReceiveRespPs.shortTermCfoMetric.I
${field_name2}    UlData_PuschReceiveRespPs.shortTermCfoMetric.Q    
${field_name3}    UlData_PuschReceiveReq.longTermCfoMetric.Re
${field_name4}    UlData_PuschReceiveReq.longTermCfoMetric.Im

*** Keywords ***
Load BIP Log with Template Command
    [Arguments]    ${pcap_file}    ${command_template}    ${tshark_path}=${TSHARK_PATH}    ${luashark_path}=${tmp_lua_dir}
    ${packets}=   pcap.load_pcap_file   pcap_file=${pcap_file}
	...                                 tshark_path=${tshark_path}
    ...                                 luashark_path=${luashark_path}
    ...                                 command_template=${command_template}
    [Return]    ${packets}

Get value from Bip Log
    [Arguments]    ${packets}    ${field_name}
    ${value}    pcap.get_field_value_by_name    field_name=${field_name}
    [Return]    ${value}
	
