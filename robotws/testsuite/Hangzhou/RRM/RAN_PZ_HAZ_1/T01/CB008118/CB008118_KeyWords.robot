*** Settings ***
Documentation
...   Author: zhifu.xu@nokia-sbell.com
...   Contact: zhifu.xu@nokia-sbell.com
...   Description: This user scenario describes

Library     ute_wtssim
Library     String
Library     OperatingSystem
Library     Collections
Library     ta5g_ue_measurements
Library     taf.config.wts        WITH NAME    wts_conf


Resource    ../../../../resources/RAN_PZ_HAZ_1/Module/Module.robot
Resource          ../../Resources/Classical/RRM_Common_Resource.robot

*** Variables ***
${carrier_freq_NR}    ${520110}
${carrier_freq_LTE}    ${2200}
&{dcap_info}    host=127.0.0.1    port=9443    username=${None}    password=${None}
${nsetapx_plugin_addr}
...   ...  https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/NSETAP_X/nsetapx-1.13.4
${mcshark_plugin_addr}
...   https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/MCShark
${plugin_folder}   /usr/lib/x86_64-linux-gnu/wireshark/plugins
${plugin_folder_utevm}   /home/ute/.local/lib/wireshark/plugins
@{AB1_T01_1}         e1ap.defaultDRB      e1ap.dRB_Inactivity_Timer    _ws.col.Info
${extra_conditions}      -E header=y -E separator=, -E quote=d -E occurrence=a
&{AB1_T01_dict_1}       filter_conditions=e1ap.fiveQI == 69    extra_conditions=${extra_conditions}
...        output_field_names=${AB1_T01_1}
&{AB1_T02_dict_1}       filter_conditions=e1ap.fiveQI == 70    extra_conditions=${extra_conditions}
...        output_field_names=${AB1_T01_1}
@{AB18_T01}         ngap.radioNetwork    _ws.col.Info
&{AB18_T01_dict_1}       filter_conditions=ngap.procedureCode == 42    output_field_names=${AB18_T01}
${nrcell_distname}=    MRBTS-1/NRBTS-1/NRCELL-1
${nrcell_distname_FDD}=    MRBTS-1/NRBTS-1/NRCELL-10
${PMQAP_distname}=    MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-1
${nrbts_distname}=    MRBTS-1/NRBTS-1
${nrbts_distname_PDCP}=    MRBTS-1/NRBTS-1/PDCP2
${counter_distname}=    All
${counter1}=     M55163C00001,M55163C00002
${counter_rule1}=    max(M55163C00001)==3 and max(M55163C00002)==3
${counter2}=     M55125C08501,M55125C08502
${counter_rule2}=    max(M55125C08501)==3 and max(M55125C08502)==3
${counter3}=     M55163C00003,M55163C00504
${counter_rule3}=    max(M55163C00003)>=1 and max(M55163C00504)==1
${counter4}=     M55310C19003
${counter_rule4}=    max(M55310C19003)>=1000
${counter5}=     M55320C20015
${counter_rule5}=    max(M55320C20015)>=1000
${counter6}=     M55320C06016
${counter_rule6}=    max(M55320C06016)>=1000
${counter7}=    M55124C04503
${counter_rule7}=    max(M55124C04503)==0
${counter8}=    M55125C06001
${counter_rule8}=    max(M55125C06001)==0
${counter9}=    M55124C00037,M55124C00038
${counter_rule9}=    max(M55124C00037)==1 and max(M55124C00038)==1

*** Keywords ***
Case Precondition
    Airphone Operation    operation=edaemon_egate_teardown    product_type=${None}    traffic_info_dic=${None}
    ...                   tag=${None}    cmd=${None}    pass_regexp=${None}    timeout=100s
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=env_setup_sa
    ...                   product_type=gnb
    ...                   traffic_info_dic=${None}
    ...                   tag=CB008118
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=12000s
    ...                   customer=TMO
    Common Test Setup For RRM
    Start Btslog Collect    names=btslog1

Case Precondition For Branch
    Airphone Operation    operation=edaemon_egate_teardown    product_type=${None}    traffic_info_dic=${None}
    ...                   tag=${None}    cmd=${None}    pass_regexp=${None}    timeout=100s
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=env_setup_sa
    ...                   product_type=gnb
    ...                   traffic_info_dic=${None}
    ...                   tag=CB008118_branch
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=12000s
    ...                   customer=TMO
    Common Test Setup For RRM
    Start Btslog Collect    names=btslog1

Case Postcondition
    log to console    Case Postcondition
    ${btslog_name1}    Stop Btslog Collect    names=btslog1
    Airphone Common Teardown
    Run Keyword If Test Failed    Run Keyword And Ignore Error    Collect Coam Snapshot
    ${DATE}=    Get Current Date    result_format=%Y%m%d_%H%M
    Wait Until Keyword Succeeds    3x    1min    COAM_Admin.Login    alias=SCF_backup
    Run Keyword And Ignore Error    COAM_Admin.BackupSCF    local_dir=${TEST_LOG_DIRECTORY}    file_name=SCF_${DATE}.xml
    ...    connection=SCF_backup
    Run Keyword And Ignore Error    COAM_Admin.Logout    connection=SCF_backup

Start Collect Wireshark For GNB
    ${wireshark_argument}   Create Dictionary   wireshark_options=-i any
    ${dict_argument}   Create Dictionary   argument=${wireshark_argument}
    Log Collection    start    wireshark    product_type=gnb    bts_index=${0}    dict_argument=${dict_argument}

Stop Wireshark log For GNB
    ${local_file_path}    Log Collection    stop_and_download    wireshark    product_type=gnb    bts_index=${0}
    [Return]    ${local_file_path}

UE${ue_id:\d+} Register
    Airphone Execute Egate Command    cmd=ue_register id=${ue_id}    pass_regexp=REGISTRATION COMPLETE

UE${ue_id:\d+} Register with MCS
    Airphone Execute Egate Command    cmd=ue_register id=${ue_id}    pass_regexp=establishmentCause mcs-PriorityAccess,
    sleep    5s

UE${ue_id:\d+} Register with reject
    Airphone Execute Egate Command    cmd=ue_register id=${ue_id}    pass_regexp=rrcReject
    sleep    5s

UE${ue_id:\d+} And PDU Session-${pdu_id:\d+} Gateway-${gw_id:\d+} Setup
    Airphone Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Airphone Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=1 gw=${gw_id}
    ...                                pass_regexp=QoS Routing Table
    sleep    5s

UE${ue_id:\d+} And PDU Session-${pdu_id:\d+} Gateway-${gw_id:\d+} Setup with default qos-${qos_id:\d+}
    Airphone Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal default_qos_flow=${qos_id}
    Airphone Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=1 gw=${gw_id}
    ...                                pass_regexp=QoS Routing Table
    sleep    5s

UE Deregister From gNB
    [Arguments]    ${ue_id}=1
    Airphone Execute Egate Command   cmd=ue_deregister id=${ue_id} ue_deregister_type=switch_off
    sleep   5s

UE PDU Session Modify
    [Documentation]
    ...    Added additional qos flows to pdu session of an UE. By default adds flows 2 and 3, which are pre-configured in
    ...    basic_setup.cfg and necessary for VoNR.
    ...
    ...    | ue_id              | Specified UE ID                                          |
    ...    | pdu                | PDU Session to be modified                               |
    ...    | list qos_flow_list | list of all the used qos_flows that should be added      |
    ...    | by                 | Device type initiating the procedure ue|amf              |
    ...    | pass_regexp        | regexp to pass the KW if found in egate command response |
    ...    | fail_regexp        | regexp to fail the KW if found in egate command response |
    ...
    [Arguments]   ${ue_id}   ${pdu}=1   ${qos_flow_list}=${NONE}   ${by}=amf   ${pass_regexp}=QosFlow with QFI
    ${default_qos_list}   Create List   ${2}   ${3}
    ${qos_flow_list}      Set Variable If   ${qos_flow_list}   ${qos_flow_list}   ${default_qos_list}

    FOR   ${qos_parameter}   IN   @{qos_flow_list}
        ${cmd1}    Catenate    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=${qos_parameter} by=${by}
        Airphone Execute Egate Command    cmd=${cmd1}    pass_regexp=${pass_regexp}
        sleep    2s
    END
    sleep    2s

Start ${traffic_rate:\d+}Mbps Traffic On PDU Session-${pdu_id:\d+} QFI-${qfi_id:\d+} ${direction:(ul|dl)} for UE${ue_id:\d+}
    ${cmd}    Catenate   trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=${direction} mbps=${traffic_rate}
    Airphone Execute Egate Command    cmd=${cmd}
    sleep    3s

Start ${traffic_rate:\d+}kbps Traffic On PDU Session-${pdu_id:\d+} QFI-${qfi_id:\d+} ${direction:(ul|dl)} for UE${ue_id:\d+}
    ${cmd}    Catenate   trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=${direction} kbps=${traffic_rate}
    Airphone Execute Egate Command    cmd=${cmd}
    sleep    3s

Set Parameter For CB008118
    [Arguments]    ${MO}=MRBTS-1/NRBTS-1    ${parameter}=applyPriorityAccess    ${value}=MCS
    @{para_list}    Create List    ${parameter}
    @{mo_list}    Create List    ${MO}
    @{value_list}    Create List    ${value}
    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                      para_list=@{para_list}        value_list=@{value_list}    mo_list=@{mo_list}
    Log To Console    paramter update result: ${out}
    sleep    10s

Delta plan operation for CB008118
    [Arguments]    ${delta_file_path}=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T01/CB008118/delta_plan.json
    ${out}     Parameter Operation    operation=delta_plan_update   product_type=gnb
    ...                               delta_file_path=${delta_file_path}
    Log To Console    delta plan update result: ${out}
    sleep    10s

Check site on air
    wait until keyword succeeds   3x   1min    COAM_Admin.Login
    wait until keyword succeeds    10 min    30 sec    Airphone Verify BTS Status For Classic
    [Teardown]    Run Keyword And Ignore Error    COAM_Admin.Logout

Trigger Radio Link Failure
    [Arguments]    ${ue_id}=1    ${pass_regexp}=Received RRC Release
    Airphone Execute Egate Command    cmd=rlf_testmode_nr profile_id=1 num_stop_csi_report=5000 num_stop_dlharq_tx=5000
    Airphone Execute Egate Command    cmd=rlf_testmode_nr profile_id=1
    Airphone Execute Egate Command    cmd=ue_testmode_set_nr id=${ue_id} testmode=rlf action=activate profile_id=1
    ...        pass_regexp=${pass_regexp}

Trigger Radio Link Failure without check
    [Arguments]    ${ue_id}=1
    Airphone Execute Egate Command    cmd=rlf_testmode_nr profile_id=1 num_stop_csi_report=5000 num_stop_dlharq_tx=5000
    Airphone Execute Egate Command    cmd=rlf_testmode_nr profile_id=1
    Airphone Execute Egate Command    cmd=ue_testmode_set_nr id=${ue_id} testmode=rlf action=activate profile_id=1

Deactive Radio Link Failure Profile
    [Arguments]    ${ue_id}=1
    Airphone Execute Egate Command    cmd=ue_testmode_set_nr id=${ue_id} testmode=rlf action=deactivate profile_id=1
    Airphone Execute Egate Command    cmd=rlf_testmode_nr profile_id=1 delete=1

Send RRC Reestablish with cause
    [Arguments]    ${ue_id}=1    ${cell_id}=4    ${gnb_id}=2    ${cause}=handoverFailure
    ${command} =  catenate   SEPARATOR=
    ...    ue_rrc_reestablish id=${ue_id} gnb=${gnb_id} cell=${cell_id} cause=${cause}
    Airphone Execute Egate Command    cmd=${command}
    sleep    2s

UE Register And PDU Session Setup
    [Arguments]    ${ue_id}=1    ${pass_regexp}=QoS Routing Table    ${ue_gw}=1
    Airphone Execute Egate Command    cmd=ue_register id=${ue_id}
    sleep    5s
    Airphone Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Airphone Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=2 trf_type=internal
    sleep    5s
    Airphone Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_gw}
    ...        pass_regexp=${pass_regexp}
    sleep    5s

UTE DCAP install
    start_dcap_controller_common

Start Email Collect
    [Arguments]    ${NRCELL_ID}=NRCELL_R-1
#    start_dcap_controller_common
    ${dcap_argument}   Create Dictionary   nrCells=${NRCELL_ID}
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}    argument=${dcap_argument}
    Log Collection    start    emil+cell_trace    product_type=gnb    bts_index=${0}    dict_argument=${dict_argument}
    sleep    60s

Start DCAP Collect
    [Arguments]    ${NRCELL_ID}=NRCELL_R-1
#    start_dcap_controller_common
    ${dcap_argument}   Create Dictionary   nrCells=${NRCELL_ID}
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}    argument=${dcap_argument}
    Log Collection    start    emil+tti    product_type=gnb    bts_index=${0}    dict_argument=${dict_argument}

Stop Email Collect
    ${local_file_path}    Log Collection    stop_and_download    emil    product_type=gnb    bts_index=${0}
    Log To Console    \nTTI log: ${local_file_path}

Stop DCAP Collect
    ${local_file_path}    Log Collection    stop_and_download    emil+tti    product_type=gnb    bts_index=${0}
    Log To Console    \nTTI log: ${local_file_path}

New Download wireshark plugin
    sleep    5s
    ${ver}   Run   ls ${plugin_folder}/
    ${exist}   Run   cd ${plugin_folder}/${ver}/epan;ls nsetapx*
    ${exist_mcshark}   Run   cd ${plugin_folder}/${ver}/epan;ls mcshark*
#    ${exist_utevm}   Run   cd ${plugin_folder_utevm}/${ver}/epan;ls nsetapx*
    Run   cd ${plugin_folder}/${ver}/epan;sudo rm mcshark*
    Run   cd ${plugin_folder}/${ver}/epan;sudo rm nsetapx*
    ${mcshark_plugin_path}   Generate Mcshark path
    ${cmd_1}=    Catenate    wget -r -np -nH  ${nsetapx_plugin_addr}/ -P /home/ute/nsetapx
    ${cmd_2}=    Catenate    wget -r -np -nH  ${mcshark_plugin_path}/ -P /home/ute/mcshark
    Run Keyword If    not os.path.exists("/home/ute/nsetapx")   Run  cd /home/ute/;sudo mkdir nsetapx
    Run  cd /home/ute/;sudo chmod 777 nsetapx
    OperatingSystem.Run    command=cd /home/ute/nsetapx
    OperatingSystem.Run    command=sudo rm -rf /home/ute/nsetapx/artifactory
    OperatingSystem.Run    command=${cmd_1}
    Run Keyword If    not os.path.exists("/home/ute/mcshark")   Run  cd /home/ute/;sudo mkdir mcshark
    Run  cd /home/ute/;sudo chmod 777 mcshark
    OperatingSystem.Run    command=cd /home/ute/mcshark
    OperatingSystem.Run    command=sudo rm -rf /home/ute/mcshark/artifactory
    OperatingSystem.Run    command=${cmd_2}
    ${nsetapx_plugin_addr_local}  Replace String    ${nsetapx_plugin_addr}   https://artifactory-hz1.int.net.nokia.com
    ...  /home/ute/nsetapx
    ${nsetapx_plugin_path}=    Run Keyword If   "${ver}"=="4.2"  Catenate   ${nsetapx_plugin_addr_local}/nsetapx-${ver}-*rocky08.so
    ...   ELSE
    ...   Catenate   ${nsetapx_plugin_addr_local}/nsetapx-${ver}-*buster.so
    OperatingSystem.Run    command=sudo cp ${nsetapx_plugin_path} ${plugin_folder}/${ver}/epan
    ${nsetapx_exist}   Run   cd ${plugin_folder}/${ver}/epan;ls nsetapx*
    ${nsetapx_sw_list}    Split String    ${nsetapx_exist}    \n
    ${length}  Get Length   ${nsetapx_sw_list}
    Run Keyword If   ${length}>=2   Delete unused plugin   ${nsetapx_sw_list}   ${length}   ${ver}
    ${mcshark_plugin_addr_local}  Replace String    ${mcshark_plugin_path}   https://artifactory-hz1.int.net.nokia.com
    ...  /home/ute/mcshark
    ${mcshark_plugin_path}=    Run Keyword If   "${ver}"=="4.2"  Catenate   ${mcshark_plugin_addr_local}/mcshark-${ver}-*rocky8.so
    ...   ELSE
    ...   Catenate   ${mcshark_plugin_addr_local}/mcshark-${ver}-*buster.so
    OperatingSystem.Run    command=sudo cp ${mcshark_plugin_path} ${plugin_folder}/${ver}/epan
    ${mcshark_exist}   Run   cd ${plugin_folder}/${ver}/epan;ls mcshark*
    ${mcshark_sw_list}    Split String    ${mcshark_exist}    \n
    ${length}  Get Length   ${mcshark_sw_list}
    Run Keyword If   ${length}>=2   Delete unused plugin   ${mcshark_sw_list}   ${length}   ${ver}

Delete unused plugin
    [Arguments]   ${plugin_sw_list}   ${length}   ${ver}
    FOR    ${index}    IN RANGE    0    ${length}-1
        Run   cd ${plugin_folder}/${ver}/epan;sudo rm -rf ${plugin_sw_list}[${index}]
    END

Generate Mcshark path
    ${sw_list}    Split String    ${ACTIVE_SW_VERSION}    _
    ${sw_version}  Replace String    ${ACTIVE_SW_VERSION}   ${sw_list[0]}   ${RELEASE}
    ${output}    OperatingSystem.Run    command=tshark -v |grep TShark
    ${lst}    Get Regexp Matches    ${output}    v(\\d{1,3}\.\\d{1,3})\.\\d{1,3}   1
    ${tshark_version}=    set variable    ${lst}[0]
    ${mcshark_plugin_path}    Run Keyword If   "${tshark_version}"=="4.2"
    ...   Set Variable    ${mcshark_plugin_addr}/${sw_version}
    ...   ELSE
    ...   Set Variable   ${mcshark_plugin_addr}/${sw_version}
    [Return]    ${mcshark_plugin_path}

Prepare WTS Config Change Default DRB to 5QI-70
    [Arguments]    ${wts_cfg_name}
    wts_conf.load_wts_cfg    file_path=${wts_cfg_name}
    wts_conf.modify    set_qosflow id=1    modification=5qi=69 default=off
    wts_conf.modify    set_qosflow id=11    modification=5qi=70 ue=all default=on
    wts_conf.save_wts_cfg    file_path=${CURDIR}/APCFG/wts_CB008118.cfg

CB008118 AB1 TC01 Check Ponit 1
    [Arguments]    ${local_file_path}=/home/ute/10.69.104.82_cran1_20230315052629.pcap
    ${result}=    Log Analysis    check    wireshark    ${local_file_path}    ${AB1_T01_dict_1}
    Log To Console    \nAnalyze log: ${result}
    should contain    ${result[${1}]}    "0"
    should contain    ${result[${1}]}    "600"

CB008118 AB1 TC02 Check Ponit 1
    [Arguments]    ${local_file_path}=/home/ute/10.69.104.82_cran1_20230315052629.pcap
    ${result}=    Log Analysis    check    wireshark    ${local_file_path}    ${AB1_T02_dict_1}
    Log To Console    \nAnalyze log: ${result}
    should contain    ${result[${1}]}    "0"
    should contain    ${result[${1}]}    "600"

Start Collect Counter
    [Arguments]    ${distname}    ${counter}    ${counter_rule}
    ${rule1}    Catenate
    ...         Distname: ${distname};
    ...         Counter: ${counter};
    ...         Counter rule: ${counter_rule};
    ${rule_list}    Create List    ${rule1}
    Log To Console    \nThe rule list is: ${rule_list}
    Counter Operation    operation=start_collect_counter    product_type=gnb    bts_index=0    counter_rule=${rule_list}
    ...                  wait_for_next_counter_generate=${true}

Stop Collect Counter and verify PM counters
    ${result}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0    cudu_index=0
    Log To Console    \nCounter Rule Collect and Check Result is: ${result}

Start Collect Counter For Multi Rule
    [Arguments]    ${distname}    ${counter}    ${counter_rule}    ${second_distname}    ${second_counter}
    ...        ${second_counter_rule}
    ${rule1}    Catenate
    ...         Distname: ${distname};
    ...         Counter: ${counter};
    ...         Counter rule: ${counter_rule};
    ${rule2}    Catenate
    ...         Distname: ${second_distname};
    ...         Counter: ${second_counter};
    ...         Counter rule: ${second_counter_rule};
    ${rule_list}    Create List    ${rule1}    ${rule2}
    Log To Console    \nThe rule list is: ${rule_list}
    Counter Operation    operation=start_collect_counter    product_type=gnb    bts_index=0    counter_rule=${rule_list}
    ...                  wait_for_next_counter_generate=${true}

Trigger RRC Reestablish
    [Arguments]    ${ue_id}=1    ${cell_id}=4
    ${command} =  catenate   SEPARATOR=
    ...    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id} cause=otherFailure
    Airphone Execute Egate Command    cmd=${command}    pass_regexp=rrcReconfigurationComplete
    sleep    2s

Check GBR UE Tput
    [Arguments]    ${ue_id}=1    ${dir}=dl
    ${max_tput}    ${ave_tput}    ${min_tput}    Module AP Get Average Throughput    ue_id=${ue_id}
    ...                                                  qfi=1    dir=${dir}    trf_id=1    type=l3
    ...                                                  call_type=SA    pdu_id=1
    ${ave_tput_str}    Convert To String    ${ave_tput}
    log_to_console     UE${ue_id} DL/UL ave tput is ${ave_tput_str.lower()}
    [Return]    ${ave_tput_str}

Send A2 Measurement
    [Arguments]  ${ue_id}=1    ${carrier_freq}=628608    ${pass_regexp}=rrcReconfigurationComplete
    ${meas_id_A2}=    Get Measurement Id For Frequency    ue_id=${ue_id}    event_type=EventA2    carrier_freq=${carrier_freq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_A2} event=A2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
    ${output}=    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${cmd}
    ...                   pass_regexp=${pass_regexp}
    ...                   timeout=100s

Get Measurement Id For Frequency
    [Arguments]  ${ue_id}=1  ${event_type}=EventA3  ${carrier_freq}=0  ${trigger}=rsrp
    get_ue_measurement_configuration  ue_id=${ue_id}  alias=${ue_id}_meas
    ${meas_id}    get_meas_id_for_measurement_on_frequency  event_type=${event_type}  carrier_freq=${carrier_freq}
    ...    alias=${ue_id}_meas  trigger=${trigger}
    #Log to console  MeasId for ${event_type} on carrier freq ${carrier_freq} is: ${meas_id}
    [Return]    ${meas_id}

Send A3 Measurement And Attempt Handover
    [Arguments]  ${ue_id}=1    ${phycell_id}=721    ${carrier_freq}=643008    ${pass_regexp}=${None}
    ${meas_id}=    Get Measurement Id For Frequency    ue_id=${ue_id}    event_type=EventA3    carrier_freq=${carrier_freq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
    ...   phycell_id=${phycell_id} nrsrp_nr=60 nrsrq_nr=30 rs_type=ssb index=0 nrs_result=30:20:59
#    Airphone Execute Egate Command    cmd=${cmd}    pass_regexp=Received HandoverNotify
    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${cmd}
    ...                   pass_regexp=${pass_regexp}
    ...                   timeout=100s
    sleep    100ms

CB008118 AB18 TC01 Check Ponit
    [Arguments]    ${local_file_path}=/home/ute/10.69.104.82_cran1_20230315052629.pcap
    ${result}=    Log Analysis    check    wireshark    ${local_file_path}    ${AB18_T01_dict_1}
    Log To Console    \nAnalyze log: ${result}
    should contain    ${result[${1}]}    "20"

Kill node
    OperatingSystem.Run    sudo pkill -9 node

Send A2 Measurement For IRAT
    [Arguments]  ${ue_id}=1
    ${meas_id_A2}=    Get Measurement Id For Frequency    ue_id=${ue_id}    event_type=EventA2    carrier_freq=${carrier_freq_NR}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_A2} event=A2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
#    Airphone Execute Egate Command    cmd=${cmd}
    ${output}=    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${cmd}
    ...                   pass_regexp=${None}
    ...                   timeout=100s

Trigger inter-RAT Handover
    [Arguments]  ${ue_id}=1    ${phycell_id}=11
    Send A2 Measurement For IRAT    ue_id=${ue_id}
    Sleep   2s
    Send B2 Measurement And Attempt Handover    ue_id=${ue_id}    phycell_id=${phycell_id}

Send B2 Measurement And Attempt Handover
    [Arguments]  ${ue_id}=1    ${phycell_id}=11
    ${meas_id}=    Get Measurement Id For Frequency    ue_id=${ue_id}    event_type=EventB2    carrier_freq=${carrier_freq_LTE}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=B2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
    ...   phycell_id=${phycell_id} nrsrp_nr=60 nrsrq_nr=30 rs_type=ssb index=0 nrs_result=60:30:0
#    Airphone Execute Egate Command    cmd=${cmd}    pass_regexp=Received HandoverNotify
    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${cmd}
    ...                   pass_regexp=Received HandoverNotify
    ...                   timeout=100s
