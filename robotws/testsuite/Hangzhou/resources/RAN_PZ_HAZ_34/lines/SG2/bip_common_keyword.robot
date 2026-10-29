*** Settings ***
Documentation    This is for BIP log capture
...              Contacts: tong.chen@nokia-sbell.com

Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    taf.collectors.core       WITH NAME    core
Library    taf.collectors.btslog     WITH NAME    btslog
Library    taf.analyzer.pcap        WITH NAME    pcap
Library    taf.collectors.l1l2bip    WITH NAME    l1l2bip
Library    taf.config.testline.info.testline_info.TestlineInfo    WITH NAME    testline_info
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot
Resource          taf/rfrl/common_resources/robot/coam_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    taf/rfrl/common_resources/robot/TTI_Trace.robot
Variables         patternID_list.py


*** Variables ***
${TSHARK_PATH}    /usr/bin/tshark
${luashark_path}    /home/ute/generated_luashark/luashark.lua

${max_ue_num}    16


#template demo
#${pdsch_template}    {tshark_path} -r {input_file} -X lua_script:{luashark_path} -Y \"dldata_pdschsendreq\" -T pdml > {output_file}
#${pusch_template}   \"uldata_puschreceivereq\"

#21B pdsch filter demo
#${pdsch_sfn_field_name}    DlData_PdschSendReq.PdschSendReq.sfn
#${pdsch_slot_field_name}    DlData_PdschSendReq.PdschSendReq.slot
#${pdsch_rnti_field_name}    DlData_PdschSendReq.grants_item_15.rnti
#${pdsch_patternID_0_filed_name}    DlData_PdschSendReq.patternId.patternId_item_0

#pusch filter demo
#${pusch_sfn_filed_name}    UlData_PuschReceiveReq.PuschReceiveReq.sfn
#${pusch_slot_filed_name}    UlData_PuschReceiveReq.PuschReceiveReq.slot
#${pusch_rnti_xpath_name}    .//UlData_PuschReceiveReq.grants_item_15.rnti
#${pusch_patternID_xpath_name}    .//UlData_PuschReceiveReq.patternId.patternId_item_0


*** Keywords ***
Load BIP Log with Lua Script
    [Arguments]    ${pcap_file}    ${luashark_path}=${luashark_path}    ${tshark_path}=${TSHARK_PATH}    ${alias}=${None}
    pcap.load_pcap_file    pcap_file=${pcap_file}
    ...                    tshark_path=${tshark_path}
    ...                    luashark_path=${luashark_path}
    ...                    alias=${alias}

Load BIP Log with Template Command
    [Arguments]    ${pcap_file}    ${command_template}    ${tshark_path}=${TSHARK_PATH}    ${alias}=${None}
    pcap.load_pcap_file    pcap_file=${pcap_file}
    ...                    tshark_path=${tshark_path}
    ...                    command_template=${command_template}
    ...                    alias=${alias}

Filter Packets By Expression
    [Arguments]    ${filter_expression}    ${pcap_parser}=${None}
    pcap.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=${pcap_parser}

Check expression in Bip Log by Name
    [Arguments]    ${filter_expression}    ${field_name}    ${pcap_parser}=${None}
    Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=${pcap_parser}
    ${values}    pcap.get_field_value_by_name    field_name=${field_name}    pcap_parser=${pcap_parser}
    should not be empty    ${values}
    [Return]    ${values}

Check expression in Bip Log by Xpath
    [Arguments]    ${filter_expression}    ${field_xpath}    ${pcap_parser}=${None}
    Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=${pcap_parser}
    ${values}    pcap.get_field_value_by_xpath    xpath=${field_xpath}    pcap_parser=${pcap_parser}
    should not be empty    ${values}

Get value from Bip Log
    [Arguments]    ${field_name}    ${pcap_parser}=${None}
    ${value}    pcap.get_field_value_by_name    field_name=${field_name}    pcap_parser=${pcap_parser}
    [Return]    ${value}

Get value from Bip Log by xpath
    [Arguments]    ${xpath}    ${pcap_parser}=${None}
    ${value}    pcap.get_field_value_by_xpath    xpath=${xpath}    pcap_parser=${pcap_parser}
    [Return]    ${value}

Check Item Num Per Slot
    [Documentation]     Descrition: check different ue/beam num per dl/ul slot in BIP log
    ...        :param    packets_all  packets display filter dl: \"dldata_pdschsendreq\"  ul: \"uldata_puschreceivereq\"
    ...        :param    field_name_sfn     can refer to the commented variable at the beginning of the file
    ...        :param    field_name_slot    can refer to the commented variable at the beginning of the file
    ...        :param    item_name         for DL should be field name  e.g.   DlData_PdschSendReq.patternId.patternId_item_0
    ...                                    for UL should be xpath name  e.g.   .//UlData_PuschReceiveReq.grants_item_15.rnti
    [Arguments]    ${field_name_sfn}    ${field_name_slot}    ${item_name}
    ...            ${target_item_num}    ${target_succ_rate}=0.5    ${check_num}=${500}
    ${sfn_list}    Get value from Bip Log    field_name=${field_name_sfn}
    ${slot_list}    Get value from Bip Log    field_name=${field_name_slot}
    ${length}    Get Length    ${sfn_list}
    Run Keyword If    ${length}<${check_num}    Set Test Variable    ${cnt}    ${length}
    ...    ELSE                                 Set Test Variable    ${cnt}    ${check_num}
    Set Test Variable    ${all_slot_cnt}    ${0}
    Set Test Variable    ${succ_slot_cnt}    ${0}
    FOR    ${i}    IN RANGE    ${cnt}
        Run Keyword If    ${sfn_list[${i}]}==${sfn_list[${i-1}]} and ${slot_list[${i}]}==${slot_list[${i-1}]}
        ...    Run Keywords    Continue For Loop
        Set Test Variable    ${all_slot_cnt}    ${${all_slot_cnt}+1}
        ${item_list}    _Get Item in certain Slot    sfn_no=${sfn_list[${i}]}
        ...                                          slot_no=${slot_list[${i}]}    field_name_sfn=${field_name_sfn}
        ...                                          field_name_slot=${field_name_slot}    field_name=${item_name}
        ${item_list}    Remove Duplicates    ${item_list}
        ${item_num}    Get Length    ${item_list}
        Run Keyword If  ${item_num}==${target_item_num}    Set Test Variable    ${succ_slot_cnt}    ${${succ_slot_cnt}+1}
    END
    ${succ_rate}    Evaluate    float(${succ_slot_cnt})/${all_slot_cnt}
    Should Be True    ${succ_rate}>${target_succ_rate}

_Get Item in certain Slot
    [Arguments]    ${sfn_no}    ${slot_no}    ${field_name_sfn}    ${field_name_slot}    ${field_name}
    pcap.filter_packets_by_expression
    ...                 filter_expression=${field_name_sfn}==${sfn_no} and ${field_name_slot}==${slot_no}
	${DL_slot}    Run Keyword And Return Status    Should Contain    ${field_name_slot}    DlData
    ${item_list}=    Run Keyword If     ${DL_slot}
	...              pcap.get_field_value_by_name    field_name=${field_name}
	...  ELSE        _Get UL item in certain Slot    xpath=${field_name}
    [Return]    ${item_list}

_Get UL item in certain Slot
    [Arguments]    ${xpath}
	${status}    Run Keyword And Return Status    Should Contain    ${xpath}    rnti
	${item_list}    Run Keyword If    ${status}==${TRUE}     _Get TRUNK UL RNTI in certain Slot
	...             ELSE                                     pcap.get_field_value_by_xpath    xpath=${xpath}
    [Return]    ${item_list}

_Get TRUNK UL RNTI in certain Slot
    ${rnti_list}    Create List
    FOR   ${cnt}    IN RANGE    ${max_ue_num}
        ${rnti}    pcap.get_field_value_by_name    field_name=UlData_PuschReceiveReq.grants_item_${cnt}.rnti
        Run Keyword If	${rnti}==[]    Exit For Loop
        Append To List    ${rnti_list}    ${rnti}
    END
    [Return]    ${rnti_list}

Download and Unzip Luashark File
    ${ute_env}    run keyword and return status    run keywords
    ...    Variable Should Exist    ${CONFIGURATION}    AND    Variable Should Exist    ${ENB_BUILD}
    ${version}    set variable if    ${ute_env}    ${ENB_BUILD}    ${target_version}
    ${sbts}    run keyword and return status    Should Contain    ${version}    SBTS
    ${lua_url}    set variable if    ${sbts}
    ...    https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build/SBTS00/${version}_luashark.zip
    ...    https://artifactory-espoo1.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release/${version}/luashark-${version}.zip
    ${lua_file}    set variable if    ${sbts}    ${version}_luashark.zip    luashark-${version}.zip
    OperatingSystem.Run    wget ${lua_url} -P ${output_dir}
    OperatingSystem.Run    rm -rf /home/ute/luashark*
    OperatingSystem.Run    rm -rf /home/ute/generated*
    OperatingSystem.Run    unzip ${output_dir}/${lua_file} -d /home/ute

Get Item Num Per Slot
    [Arguments]    ${file_path}    ${dl_or_ul}=dl    ${rnti_num}=4    ${pid_num}=4    ${rnti_rate}=0.5    ${pid_rate}=0.5
    ${rnti_pass_rate}    ${pid_pass_rate}    Run keyword if    '${dl_or_ul}'=='dl'
    ...    get_dl_bip_info_from_pdml    file_path=${file_path}    rnti_traget_num=${rnti_num}    pid_target_num=${pid_num}
    ...    ELSE IF   '${dl_or_ul}'=='ul'
    ...    get_ul_bip_info_from_pdml    file_path=${file_path}    rnti_traget_num=${rnti_num}    pid_target_num=${pid_num}
    Should Be True    ${rnti_pass_rate}>=${rnti_rate}
    Should Be True    ${pid_pass_rate}>=${pid_rate}


Collect Interface Mirroring Bip Collector
    [Documentation]    :param target_file_name: (str)  name of collector
    ...                :param interface: (str)  L1-L2 or L2Hi-L2Lo
    ...                :param destination : (str)  Local or Remote
    ...                :param webservice: (dict)  Configuration of collector/host: base url IP/user: username, defaults to “Nemuadmin”
    ...                                            password: password, defaults to “nemuuser”/port: port, default 443
    ...                :param nr_phy_cell_ids: str) (nr_phy_cell_ids Union(list,)  (Optional) list of physical cell ids.
    ...                          If given ensure cell is on air before running the setup. If not given it will check nr_cell_dns
    ...                          like: 50,51
    [Arguments]    ${target_file_name}=l1l2bip_log
    ...            ${nr_phy_cell_ids}=${None}
    ...            ${gnb_index}=0
    ...            ${timeout}=900
    ...            ${interface}=L1-L2
    ...            ${destination}=Local
    ...            ${host_ip}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...            ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ${webservice}=  Create Dictionary    host=${host_ip}
    ...                                  user=${username}
    ...                                  password=${password}
    ...                                  port=443
    l1l2bip.create_interface_mirroring_l1l2bip_collector    name=${target_file_name}
    ...                                                     webservice=${webservice}
    ...                                                     interface=${interface}
    ...                                                     destination=${destination}
    ...                                                     nr_phy_cell_ids=${nr_phy_cell_ids}
    ...                                                     target_file_name=${target_file_name}
    ...                                                     timeout=${timeout}
    core.setup_collectors    names=${target_file_name}
    core.start_collectors    names=${target_file_name}
    l1l2bip.set_suite_alias    ${target_file_name}

Get Bip Log Via Interface Mirroring Collector
    [Documentation]    keyword is used to collect the log files to default path
    [Arguments]      ${target_file_name}=l1l2bip_log    ${pattern}=*.pcap    ${target_dir}=${TS_CASE_LOG_PATH}
    core.stop_collectors        names=${target_file_name}
    core.collect_collectors   names=${target_file_name}    target_dir=${target_dir}
    core.teardown_collectors    names=${target_file_name}
    @{log_file}   List Files In Directory    path=${target_dir}${/}${target_file_name}    pattern=${pattern}
    Sort List    ${log_file}
    FOR  ${log}  IN  @{log_file}
        ${index}    Get Index From List    ${log_file}    ${log}
        ${next_index}    Evaluate    ${index}+1
        Run Keyword If    '${index}'=='0'    OperatingSystem.Run   command=cd ${target_dir}${/}${target_file_name};touch test_${index}.pcap
        OperatingSystem.Run   command=cd ${target_dir}${/}${target_file_name};mergecap -w test_${next_index}.pcap test_${index}.pcap ${log}
    END
    ${status}    Run Keyword And Return Status
    ...    OperatingSystem.Run   command=cd ${target_dir}${/}${target_file_name};cp test_${next_index}.pcap ${target_file_name}.pcap
    Run Keyword If    ${status}    OperatingSystem.Run   command=cd ${target_dir}${/}${target_file_name};rm test*.pcap
    Run Keyword If    ${status}    OperatingSystem.Run   command=cd ${target_dir}${/}${target_file_name};rm BTS*.pcap
    ${full_log_path}    Create List    ${target_dir}${/}${target_file_name}${/}${target_file_name}.pcap
    [Return]    ${full_log_path}
    [Teardown]    bip_common_keyword.Stop Bip Log Via Interface Mirroring Collector    target_file_name=${target_file_name}

Stop Bip Log Via Interface Mirroring Collector
    [Documentation]    keyword is used to stop collect bip log
    [Arguments]      ${target_file_name}=l1l2bip_log
    core.stop_collectors        names=${target_file_name}
    core.teardown_collectors    names=${target_file_name}

Start Bip Log with Suitable Means
    [Documentation]    Starting to use web catch bip log after 23R1
    [Arguments]    ${target_file_name}=l1l2bip_log
    ...            ${nr_phy_cell_ids}=${None}
    ...            ${gnb_index}=0
    ...            ${timeout}=900
    ...            ${interface}=L1-L2
    ...            ${destination}=Local
    ...            ${host_ip}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...            ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    COAM Navigate to login page via webUI
#    ${current_version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
#    Set Test Variable    ${current_version}    ${current_version['Active']}
#    COAM selenium logout
#    ${stream}    String.Get Substring    ${current_version}    7    8
#    ${stream}    Convert To Integer    ${stream}
#    Set Test Variable    ${current_version_stream}    ${stream}
#    Run Keyword If    ${stream} <= 2 or ${stream} == 4    Collect Interface Mirroring Bip Collector
#    ...                                target_file_name=${target_file_name}
#    ...                                nr_phy_cell_ids=${nr_phy_cell_ids}
#    ...                                gnb_index=${gnb_index}
#    ...                                timeout=${timeout}
#    ...                                interface=${interface}
#    ...                                destination=${destination}
#    ...                                host_ip=${host_ip}
#    ...                                username=${username}
#    ...                                password=${password}
#    ...       ELSE    Bip Capture with gnbMirroring scripts with retry    syscom_mirroring=false
    bip_common_keyword.Collect Interface Mirroring Bip Collector
    ...                                target_file_name=${target_file_name}
    ...                                nr_phy_cell_ids=${nr_phy_cell_ids}
    ...                                gnb_index=${gnb_index}
    ...                                timeout=${timeout}
    ...                                interface=${interface}
    ...                                destination=${destination}
    ...                                host_ip=${host_ip}
    ...                                username=${username}
    ...                                password=${password}

Stop Bip Log with Suitable Means
    [Documentation]    Starting to use web catch bip log after 23R1
    [Arguments]      ${target_file_name}=l1l2bip_log    ${pattern}=*.pcap    ${target_dir}=${TS_CASE_LOG_PATH}
#    ${full_log_path}    Run Keyword If    ${current_version_stream} <= 2 or ${current_version_stream} == 4
#    ...                                                          Get Bip Log Via Interface Mirroring Collector
#    ...                                                                    target_file_name=${target_file_name}
#    ...                                                                    pattern=${pattern}
#    ...                                                                    target_dir=${target_dir}
#    ...       ELSE    Stop BIP capture on ASIK if needed and download BIP Logs to testPC    log_path=${target_dir}
    ${full_log_path}    bip_common_keyword.Get Bip Log Via Interface Mirroring Collector
    ...                                                                    target_file_name=${target_file_name}
    ...                                                                    pattern=${pattern}
    ...                                                                    target_dir=${target_dir}
    Run Keyword And Ignore Error    COAM selenium logout
    [Return]    ${full_log_path}

Capture TTI log
    [Arguments]    ${duration}=1s
    Create default connection
    ${p}    set variable    /opt/tools/ttiTrace/eventsCollect.sh
    ${c}    set variable    lxc-attach -n 0x1730 -- sed "s/(get_port_no)/(netstat -a4up | grep event | awk '{print \\\$4}' | cut -d: -f2)/g" -i ${p}
    csn.send command    command=${c}   connection=${ABIL_ALIAS}
    Start TTI trace log capturing
    sleep    ${duration}
    Stop TTI trace log capturing
    ${local_csv_file_path}    Convert TTI trace log and download combined csv logs to test pc
    [Return]    ${local_csv_file_path}
