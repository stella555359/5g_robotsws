*** Settings ***

Documentation
...   author: y6lu
...   contact: lu.yu@nokia-sbell.com
...   squad group: MMW_SG3
...   Feature CB007199 in 5G22R3 program

Library             Collections
Library             taf.hw.fhgw.cli                       WITH NAME    issh
Library             taf.config.scf                        WITH NAME    scf
Library             OperatingSystem
Library             String
Library             taf.transport.ssh                     WITH NAME    tafssh
Library             Process
Library             taf.analyzer.pcap                     WITH NAME    pcap
Library             taf.gnb.oam.coam.vdu.interface.Vdu      WITH NAME    vdu
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_vdu.robot
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_cu.robot
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_state.robot
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
#Resource            kw_to_be_optimized_py.py
Resource           ./variables.robot
Resource           ./common_trans.robot
Resource           ./cap_log.robot

*** Variables ***
${UE_TYPE}    askey_vran20
@{list_of_cell}    173195265
${alias}    vDU
*** Keywords ***
Make UE Attach
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${UE_TYPE}
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${ue_type}    reset_sol=reboot_ue
    ${attached}=    Run Keyword And Return Status    power_ue.Verify attach    ue_index=${ue_index}    ue_type=${ue_type}
    Run Keyword If    ${attached}==False    Run Keywords
    ...    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${ue_type}    AND
    ...    power_ue.Verify attach    ue_index=${ue_index}    ue_type=${ue_type}

Make UE Detach
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${UE_TYPE}
    power_ue.UE Detach    ue_index=${0}    ue_type=${ue_type}

Start traffic and check result
    [Arguments]    ${gnb_index}=${0}    ${vdu_index}=${0}    ${dltp_expected}=1000  ${data_send_dl}=1.5G    ${data_send_ul}=70M
	...             ${ultp_expected}=50    ${tp_direction}=dl    ${sleep_time}=1m
    Start traffic according to direction and protocol  data_send_dl=${data_send_dl}    tp_direction=${tp_direction}
    ...            data_send_ul=${data_send_ul}
    ${handle}    vDU Begin K8s Log    ${gnb_index}    ${vdu_index}
    Set test variable    ${handle}
    ${container_prefix}    vDU Get Container Name Prefix
	sleep    60s
	${local_l2rt_file}    vDU End K8s Log      handle=${handle}     pod_abbr=up     container=${container_prefix}l2rt
    ...    gnb_index=${gnb_index}    vdu_index=${vdu_index}
	Set Suite Variable    ${local_l2rt_file}
    ${all_tput}=    Check throughput according to direction and protocol    dltp_expected=${dltp_expected}
    ...    tp_direction=${tp_direction}    ultp_expected=${ultp_expected}
    Stop traffic according to direction and protocol   tp_direction=${tp_direction}
    [Return]  ${all_tput[0]['average']}

Start traffic according to direction and protocol
    [Arguments]  ${data_send_dl}    ${data_send_ul}=60M     ${tp_direction}=both    ${protocol}=udp
    log to console      Start traffic
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Start traffic    ue_index=${0}
    ...    direction=ul    throughput=${data_send_ul}    duration=1400    ue_type=${ue_type}    iperf_type=via_command
    ...    protocol=${protocol}    data_amount=2M
    sleep    1s
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'   power_ue.Start traffic    ue_index=${0}
    ...     direction=dl    throughput=${data_send_dl}    duration=1400    ue_type=${ue_type}    protocol=${protocol}
	...    window=32M
    sleep    20s

Check throughput according to direction and protocol
    [Arguments]    ${dltp_expected}    ${ultp_expected}=58    ${tp_direction}=both
    log to console      Check throughput
	Set Suite Variable     ${local_l2rt_file}
	${tp_expect}=    Set Variable If    '${tp_direction}' == 'dl'    ${dltp_expected}    ${ultp_expected}
    ${all_tput}=    Run keyword and continue on failure    power_ue.Check Tput
    ...    ue_type=${ue_type}    direction=${tp_direction}    log=${local_l2rt_file}    cells=@{list_of_cell}
    ...    target_throughput=${tp_expect}    actCarrierAggregation=${False}
    ...    target_avg_percent=1.00    min_percent=0.55
    [Return]    ${all_tput}

Stop traffic according to direction and protocol
    [Arguments]  ${tp_direction}=both
    log to console      Stop traffic
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Stop traffic    direction=ul
    ...    ue_index=${0}    ue_type=${ue_type}    iperf_type=via_command    protocol=tcp
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'      power_ue.Stop traffic    direction=dl
    ...     ue_index=${0}    ue_type=${ue_type}    protocol=tcp

OAM Precondition Cell Should Be Onair
    [Documentation]    Do some common thing for every precondition of cases
    ...    any case should include it in test case setup
    ...    it will do following actions
    ...    1) check cell should be onair
    ...    2) initial global test varible
    ...
    ...    *AUTHOR* xianbiao.cheng@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   14.1.2022,chris.l.cao@nokia-sbell.com, remove 'CU Get Cells ID list' to save cell id information
    ...   22.1.2022,chris.l.cao@nokia-sbell.com, remove unused variable ${BACKUP_SCF_PATH_ON_CU} to shorten dryrun time
    ...
    log to console  \n*** OAM Precondition Cell Should Be Onair ... ***

    ${nf_type}  Get VCU NF Type
    Run Keyword If   "${nf_type}"=="VNF"     CU Verify All VMs Are Online

    All DUs Container Status Should Be Normal
    CU Verify All Cells Status Are Onair
    vDU Verify All Cells Status Should Be Onair For All DUs

    ${ACTIVE_ALARM_LST_PRE_CU}=  run keyword and continue on failure  CU Get Active Alarms
    ${HISTORICAL_ALARM_LST_PRE_CU}   run keyword and ignore error   CU Get Historical Alarms
    set test variable  ${ACTIVE_ALARM_LST_PRE_CU}
    set test variable  ${HISTORICAL_ALARM_LST_PRE_CU}
    set test variable  ${ACTIVE_ALARM_LST_PRE_DU}       tbd
    set test variable  ${ACTIVE_ALARM_LST_PRE_FHGW}     tbd

Get f1uplane Ipv4 Address For vDU
    [Documentation]    Get f1uplane Ipv4 Address for vDU
    ...   *AUTHOR* rita.feng@nokia-sbell.com
    ...    modified by:        <03-Aug-2021>, <rifeng>, <Initial creation>
    Connect To K8s master
    ${out}    Kubectl Exec    pod_abbr=up    container=nwmgmt    command=ip addr show f1uplane
    ${f1u_ip}    Parse Ipv4 Address Only From Content    ${out}
    Disconnect From K8s Master
    [Return]    ${f1u_ip}

Get f1uplane Ipv6 Address For vDU
    [Documentation]    Get f1uplane Ip Address for vDU
    ...   *AUTHOR* rita.feng@nokia-sbell.com
    ...    modified by:        <29-Jul-2021>, <rifeng>, <Initial creation>
    Connect To K8s master
    ${out}    Kubectl Exec    pod_abbr=up    container=nwmgmt    command=ip addr show f1uplane
    ${f1u_ip}    ${f1u_mask}    Parse Ipv6 Address    ${out}
    Disconnect From K8s Master
    [Return]    ${f1u_ip}

Start L1L2 Bip Log Capture
    log to console    \n start capture BIP log
    Connect To vDU Node Interactively    pod_abbr=up   alias=${alias}
    ${biplogfullpath}    Begin BIP Log Capture    alias=${alias}
    set test variable    ${biplogfullpath}

Stop L1L2 Bip Log Capture
    log to console    \n Stop capture BIP log
    ${local_file_path}=    Stop BIP Capture And Download
    ...    initial_log_path=${biplogfullpath}   alias=${alias}
    set test variable    ${local_file_path}

Get values from pcap Log
    [Arguments]    ${pcap_filter}    ${filter}    ${xpath}=.//DlData_PdschSendReq.grants_item_0.numOfLayers
    ...    ${pcap_file}=${local_f1_file}
    log to console    \n Get values from pcap Log
    pcap.load_pcap_file    command_template=${pcap_filter}    pcap_file=${pcap_file}
    ${filtered_packets}=    pcap.filter_packets_by_expression    filter_expression=${filter}
    ${values}=    pcap.get_field_value_by_xpath    xpath=${xpath}
    [Return]    ${values}

Start TTI Trace Capture
    [Arguments]     ${gnb_index}=${0}    ${vdu_index}=${0}   ${nr_cell_list}=${None}   ${dscp}=0
    log to console    start capture ttitrace log
    ${oam_ip}   Get vDU OAM Ip   gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${ip_type}   check ip type    ${oam_ip}
    ${cell_list}   vDU Get Cells ID list
    ${cell_list_copy}    get slice from list  ${cell_list}   end=1
    ${nr_Cell_list_copy}  set variable if   ${nr_cell_list} is ${None}   ${cell_list_copy}   ${nr_cell_list}
    ${dcap_server_ip}=   run keyword if  "${ip_type}"=="ipv4"   set variable   ${DCAP_IP}
    ...  ELSE    set variable   ${DCAP_IPv6}
    set test variable    ${ip_type}
    set test variable    ${dcap_server_ip}
    _Online Add DCAP Server Route    ${dcap_server_ip}
    _Start TTI Trace Via UPTrace       ip_type=${ip_type}    gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ...    nr_cell_list=${nr_Cell_list_copy}   dscp=${dscp}

Stop TTI Trace Capture
    log to console    stop capture ttitrace log
    ${vdu_version}=    Get Running Build Number
    set test variable    ${vdu_version}

    ${trace_path_list}=    Stop And Download TTI Trace     #${up_pod_name}
    ${local_dl_csv}  ${local_ul_csv}=    Decoder TTITrace With Linux Server     ${ttitrace_server_ip}
    ...    ${TTI_username}  ${TTI_password}  ${vdu_version}  ${trace_path_list}
    set test variable    ${local_dl_csv}
    set test variable    ${local_ul_csv}

Start Capture Wireshark F1 On CU
    log to console    Start tcpdump on F1 interface
    ${handle} =    Begin Wireshark F1 Log On CU
    [Return]  ${handle}

Stop Capture Wireshark F1 On CU
    [Arguments]  ${handle}
    log to console    Stop tcpdump on F1 interface
    ${local_f1_file} =    End Wireshark F1 Log On CU    handle=${handle}   local_pcap_file_name=f1pcapfile.pcap
    Set Test Variable    ${local_f1_file}

Get Delta Plan Number And Delete One If Reach Max Number
    [Documentation]    Check Maximum Delta Plan Number And delete one if reach Maximum number
    ...   Author: mengli yang
    ...   Contact: mengli.yang@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...
    ...   | Return Value | Description |
    ...   | None | NA |
    ...
    ...   Example
    ...  | vDU Login By Rest |
    ...  | Check Maximum Delta Plan Number And delete one if reach Maximum number |
    ...
    ${all_plans}    vdu.Get_Delta_Plan_Info_List
    Should Be True    ${all_plans.__len__()}<=1
    Run Keyword If    ${all_plans.__len__()}==1    Delete Delta Plan By Plan Id In vDU    plan_id=${all_plans[0]["plan_id"]}

Modify 2200 Parameters
    [Arguments]    ${dist}   ${updated_paras_dict}    ${wait_vdu_up}=False
    ${uni_id}   Get Unique Id
	${delta_plan_name}    get unique id    prefix=TA_delta_plan    precise=LOW
	${plan_id}    ${action_id}    Generate Delta Plan    plan_name=${delta_plan_name}    plan_description=TA
	Update Delta Plan Parameter   plan_id=${plan_id}   mo_dn=${dist}   updated_paras_dict=${updated_paras_dict}   operation=replace
    Validate Delta Plan By REST   ${plan_id}
    ${scf_path}  Get A Directory  SCF
    ${delta_filename}  Set Variable   add_route_${uni_id}.xml
    ${delta_scf_fullpath}   vdu.Save Delta Plan File   local_path=${scf_path}   local_filename=${delta_plan_name}
    Activate Delta Plan By REST   ${plan_id}   wait_vdu_up=${wait_vdu_up}

Check RRC message
    [Arguments]    ${resources_num}=${4}    ${pcap_filter}=/usr/bin/tshark -r {pcap_file} -Y "f1ap.UEContextSetupResponse_element" -T pdml
    ...    ${n1_n2_xpath}=.//nr-rrc.two_two_TypeI_SinglePanel_Restriction
    ...    ${n1_n2_value}=ff:ff:ff:ff:ff:ff:ff:ff
    log to console    Get RRC Specific Value
    pcap.load_pcap_file    command_template=${pcap_filter}    pcap_file=/home/ute/${local_f1_file}
    #${filtered_packets}=    pcap.filter_packets_by_expression    filter_expression=nr-rrc.nzp_CSI_RS_ResourceToAddModList
    ${reportQuantity}=    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.reportQuantity
    ${n1_n2}=    pcap.get_field_value_by_xpath    xpath=${n1_n2_xpath}
    ${frequencyDomainAllocation}=    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.other
    ${nrofPorts}=    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.nrofPorts
    ${cdm_Type}=    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.cdm_Type
    ${density}=    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.density
    log to console    Check Values
    should contain    ${n1_n2}    ${n1_n2_value}
    should contain    ${reportQuantity}    7
    #${frequencyDomainAllocation_length}    get length    ${frequencyDomainAllocation}
    #FOR    ${index}    IN RANGE    ${frequencyDomainAllocation}
    FOR    ${freqdo}    IN    @{frequencyDomainAllocation}
        should be true    '${freqdo}' == '0c'
    END
    ${SCI_RS_R_Length}    get length    ${nrofPorts}
    ${sum}    set variable    0
    FOR    ${index}    IN RANGE    ${SCI_RS_R_Length}
        Run Keyword If    ${nrofPorts[${index}]} == 3    Run Keywords
        ...    should be true    ${cdm_Type[${index}]} == 2    AND
        ...    should be true    ${density[${index}]} == 1    AND
        ...    Num Autogain    ${sum}
    END
    should be true    ${sum} == ${resources_num}

Num Autogain
    [Arguments]  ${sum}
    ${sum}=    Evaluate    ${sum}+1
    Set Test Variable    ${sum}

Preconditions
    ${START_TIME}=    Get time    exclude_millis=yes
    Set Suite Variable    ${START_TIME}
    Set Vdu Pod Container Suite Variables
    Wait Until Keyword Succeeds   600  20   OAM Precondition Cell Should Be Onair

Delete Delta Plan MO
    [Arguments]  ${plan_id}   ${mo_dn}    ${timeout}=60
    [Documentation]   Delete Delta Plan MO
    ...   *AUTHOR* zhaori.deng@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_id    | yes | plan_id |
    ...   | mo_dn      | yes | mo_dn   |
    ...   | timeout    | no | timeout, default is 60, unit is second   |
    ...
    ...   *RETURN VALUE*
    ...    status dictionary of operation, its content as below,
    ...    {'status': 'success', 'error_message': None, 'revision': '1594282403383843372',
    ...     'links': None, 'action_id': 'a_0b884e65-83a3-445c-a1ff-1fadc26cd767'  }
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | ${validation_id} | Delete Delta Plan MO | plan_id=<my_plan_id> | mo_dn=MRBTS-5233/TNLSVC-1/TNL-1/IPNO-1/PINGREQ-1 |
    ...
    ${timeout}   convert to integer  ${timeout}
    ${out}  vdu.delete_mo_of_delta_plan   delta_plan_id=${plan_id}  mo_dn=${mo_dn}   timeout=${timeout}
    ${action_id}  set variable  ${out["action_id"]}
    ${out}     Delete Delta Plan MO Should Be Successful   plan_id=${plan_id}   action_id=${action_id}
    [Return]  ${out}

Delete Delta Plan MO Should Be Successful
    [Arguments]  ${plan_id}   ${action_id}
    [Documentation]   Delete Delta Plan MO Should Be Successful
    ...   *AUTHOR* zhaori.deng@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id    | yes | operation_id |
    ...   | plan_id         | yes | plan_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Delete Delta Plan MO Should Be Successful | plan_id=<my_plan_id> | operation_id=<my_operation_id> |
    ...
    ${rtn}  wait until keyword succeeds  20   2
    ...   _Delete Delta Plan MO Should Be Expected   plan_id=${plan_id}   action_id=${action_id}   expected_status=success
    [Return]  ${rtn}

_Delete Delta Plan MO Should Be Expected
    [Arguments]   ${plan_id}   ${action_id}   ${expected_status}
    [Documentation]    _Delete Delta Plan MO Should Be Expected
    ...   *AUTHOR* zhaori.deng@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | expected_status | yes | expected_status |
    ...   | plan_id         | yes | plan_id |
    ...   | action_id    | yes | action_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | _Delete Delta Plan MO Should Be Expected | plan_id=<my_plan_id> | action_id=<my_action_id> | expected_status=success |
    ...
    ${out}   vdu.get_deleting_mo_action_state_of_delta_plan      delta_plan_id=${plan_id}  action_id=${action_id}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}


#
#_Excute ADB Command On UE PC
#    [Documentation]  This KW is for Inseego only
#    ...  it should be called after every attach action
#    ...  :param ue_index:  It is the index of tl.ues
#    [Arguments]    ${command}    ${connection}=cpc_0    ${timeout}=${10}
#    #${output}=    csn.execute    command=${command}    connection=${connection}    timeout=${timeout}
#    csn.send_command    command=${command}    connection=${connection}
#    ${output}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=${connection}
#    [Return]    ${output}
#
#_Reboot UE
#    [Arguments]    ${serial}=${serial}    ${connection}=cpc_0    ${timeout}=${10}
#    _Excute ADB Command On UE PC     command=adb -s ${serial} reboot    connection=${connection}    timeout=${timeout}
#    wait until keyword succeeds    3 min    10s    _UE_Exist    connection=${connection}
#
#_UE Exist
#    [Arguments]    ${connection}=cpc_0    ${timeout}=${10}
#    ${ue_info}=    _Excute ADB Command On UE PC    command=adb devices    connection=${connection}    timeout=${timeout}
#    Should Contain    ${ue_info}    ${serial}



