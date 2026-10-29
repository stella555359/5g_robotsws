*** Settings ***
Documentation
...    author: Luo Tina
...    contact: tina.luo@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_cu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_vdu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_state.robot
Library     taf.analyzer.pcap     WITH NAME    cap
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/common_trans.robot
#Resource    ./vdu_log_other.robot
Library      ./csv_analyse.py
Resource     ./variables.robot
Resource     testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/RRM/Resources/AIC_BTS.robot

Library     taf.gnb.oam.commissioning    WITH NAME    commissioning
Library     taf.hw.rf_attenuator    WITH NAME    att
Library             taf.sw.dcap.rd		                  WITH NAME	   DCAP


*** Variables ***
${SCF_Template_path_DU}     ${commissionings_path}/HGZ/${testline_name}/SCF_0.300_vDU.xml
${SCF_Template_path_CU_TL}  ${commissionings_path}/HGZ/${testline_name}/SCF_0.250_vCU.xml
${SUITE_LOG_PATH}    /home/ute/Downloads/
${TS_LOG_PATH_BASE}    /home/ute/Downloads/
${gnb_index}    0
${sudo}    sudo
${ue_type}    ${tl.ues[0].capabilities[1]}
${att_port_0_0}              ${tl.gnbs[0].dus[0].fhgws[0].rus[0].attenuation_ports[0].port_no}
${att_port_0_1}              ${tl.gnbs[0].dus[0].fhgws[0].rus[0].attenuation_ports[1].port_no}
${att_port_0_2}              ${tl.gnbs[0].dus[0].fhgws[0].rus[0].attenuation_ports[2].port_no}
${att_port_0_3}              ${tl.gnbs[0].dus[0].fhgws[0].rus[0].attenuation_ports[3].port_no}
${att_port_1_0}              ${tl.gnbs[0].dus[0].fhgws[0].rus[1].attenuation_ports[0].port_no}
${att_port_1_1}              ${tl.gnbs[0].dus[0].fhgws[0].rus[1].attenuation_ports[1].port_no}
${att_port_1_2}              ${tl.gnbs[0].dus[0].fhgws[0].rus[1].attenuation_ports[2].port_no}
${att_port_1_3}              ${tl.gnbs[0].dus[0].fhgws[0].rus[1].attenuation_ports[3].port_no}
&{bts_vdu}      host=${tl.gnbs[0].dus[0].oam_http_connection_details.addr}
 ...            username=${tl.gnbs[0].dus[0].oam_http_connection_details.username}
 ...            password=${tl.gnbs[0].dus[0].oam_http_connection_details.password}
 ...            port=${tl.gnbs[0].dus[0].oam_http_connection_details.port}

*** Keywords ***
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
    set_vdu_pod_container_suite_variables
    ${nf_type}  Get VCU NF Type
    Run Keyword If   "${nf_type}"=="VNF"     CU Verify All VMs Are Online
    All DUs Container Status Should Be Normal
    #CU Verify All Cells Status Are Onair
    vDU Verify All Cells Status Should Be Onair For All DUs
    ${ACTIVE_ALARM_LST_PRE_CU}=  run keyword and continue on failure  CU Get Active Alarms
    ${HISTORICAL_ALARM_LST_PRE_CU}   run keyword and ignore error   CU Get Historical Alarms
    set test variable  ${ACTIVE_ALARM_LST_PRE_CU}
    set test variable  ${HISTORICAL_ALARM_LST_PRE_CU}
    set test variable  ${ACTIVE_ALARM_LST_PRE_DU}       tbd
    set test variable  ${ACTIVE_ALARM_LST_PRE_FHGW}     tbd

Get wait value minutes
    [Arguments]    ${interval}
    ${interval_seconds}    Get Interval Seconds    ${interval}
    ${interval_minutes}    evaluate    ${interval_seconds}/60
    ${origin_time}    Get time from vDU
    ${origin_time}    convert_date    ${origin_time}   datetime
    ${minutes}    set variable    ${origin_time.minute}
    ${wait_time}    evaluate    ${interval_minutes}-${minutes}%${interval_minutes}+1
    [Return]    ${wait_time}

Adjust HBTE ATT Values seperate
    [Arguments]      ${attenuation_values_of_all_ports}     ${pa_index}=${0}
    ...    ${attenuation_port_numbers}=${1}    ${max_attenuation_value}=${127}
    log to console    Adjust HBTE ATT Value
    ${ip_addr}    set variable    ${tl.attenuators[${pa_index}].ip_addr}
    ${api_port}    set variable    ${tl.attenuators[${pa_index}].port}
    ${vendor}      set variable    ${tl.attenuators[${pa_index}].vendor}
    att.setup_attenuator    ip_addr=${ip_addr}    port=${api_port}
    ...    attenuation_port_numbers=${attenuation_port_numbers}   max_attenuation=${max_attenuation_value}    vendor=${vendor}
    FOR  ${port_num}    IN RANGE    0    4
        ${att_value}    set variable    ${attenuation_values_of_all_ports['atten_value_of_port${port_num}']}
#        att.set_attenuation    port=${att_port_${port_num}}    value=${att_value}
#        ${value_port}    att.read_attenuation    port=${att_port_${port_num}}
        att.set_attenuation    port=${att_port_${pa_index}_${port_num}}    value=${att_value}
        ${value_port}    att.read_attenuation    port=${att_port_${pa_index}_${port_num}}
        should be equal    ${value_port}    ${att_value}
    END

Test Case set up
    ${START_TIME}=    Get time    exclude_millis=yes
    Set Suite Variable    ${START_TIME}
    ${SUITE_LOG_DIRECTORY}=    Get A Directory
    Set Suite Variable    ${SUITE_LOG_DIRECTORY}
    set_vdu_pod_container_suite_variables

Get Interval Seconds
    [Documentation]  Author: tingting.zhong@nokia-sbell.com
    [Arguments]  ${interval}
    ${num}    get substring    ${interval}     0    -3
    ${num}    convert to integer    ${num}
    ${interval_seconds}    evaluate    ${num}*60
    [Return]  ${interval_seconds}

Get time from vDU
    [Arguments]    ${vdu_index}=0    ${gnb_index}=0   ${alias}=default
    Connect To K8s Master
    csn.send command    command=date +%F-%T    connection=${alias}
    ${date_time}    csn.read output    connection=${alias}
    ${date_time}    Strip String   ${date_time}
    [Return]    ${date_time}

Start traffic and check result
    [Arguments]    ${dltp_expected}=540  ${data_send_dl}=560M    ${data_send_ul}=70M
	...             ${ultp_expected}=50    ${tp_direction}=both    ${sleep_time}=120s   ${vdu_index}=0
    Start traffic according to direction and protocol  data_send_dl=${data_send_dl}    tp_direction=${tp_direction}
    ...            data_send_ul=${data_send_ul}
    ${handle}    vDU Begin K8s Log    ${gnb_index}    ${vdu_index}
    Set test variable    ${handle}
    ${container_prefix}    vDU Get Container Name Prefix
	sleep    ${sleep_time}
	${local_l2rt_file}    vDU End K8s Log      handle=${handle}     pod_abbr=up     container=${container_prefix}l2rt
    ...    gnb_index=${gnb_index}    vdu_index=${vdu_index}
	Set Suite Variable    ${local_l2rt_file}
	${cell_identify}=    Evaluate     16384*${tl.gnbs[0].instance_id}+1
    ${cell_identify}   convert to string   ${cell_identify}
    @{list_of_cell}     Create List         ${cell_identify}
    Set Suite Variable     @{list_of_cell}
    ${all_tput}    Check throughput according to direction and protocol    dltp_expected=${dltp_expected}
    ...    tp_direction=${tp_direction}    ultp_expected=${ultp_expected}     cells=@{list_of_cell}
    [Return]     ${all_tput[0]['average']}

Start traffic according to direction and protocol
    [Arguments]  ${data_send_dl}    ${data_send_ul}=60M     ${tp_direction}=both
    log to console      Start traffic
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Start traffic    ue_index=${0}
    ...    direction=ul    throughput=${data_send_ul}    duration=1400    ue_type=${ue_type}    iperf_type=via_command
    ...    protocol=${protocol}    data_amount=2M
    sleep    1s
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'   power_ue.Start traffic    ue_index=${0}
    ...    direction=dl    throughput=${data_send_dl}    duration=1400
	...    ue_type=${ue_type}   process_num=1
    sleep    20s

Check throughput according to direction and protocol
    [Arguments]    ${dltp_expected}    ${cells}    ${ultp_expected}=58    ${tp_direction}=both
    log to console      Check throughput
	Set Suite Variable     ${local_l2rt_file}
    Run keyword if    '${tp_direction}'=='dl'    Run keyword and continue on failure    Check throughput for DL-direction
    ...       dltp_expected=${dltp_expected}    tp_direction=${tp_direction}    ultp_expected=${ultp_expected}     cells=${cells}
#    Run keyword if    '${tp_direction}'=='ul'    Run keyword and continue on failure    Check throughput for UL-direction
#    ...       dltp_expected=${dltp_expected}    tp_direction=${tp_direction}    ultp_expected=${ultp_expected}     cells=${cells}
    [Return]     ${all_tp}

Check throughput for DL-direction
    [Arguments]    ${dltp_expected}    ${cells}    ${ultp_expected}=58    ${tp_direction}=both
	${all_tp}    Run keyword and continue on failure    power_ue.Check Tput
    ...    ue_type=${ue_type}    direction=DL    log=${local_l2rt_file}    cells=${cells}
    ...    target_throughput=${dltp_expected}    actCarrierAggregation=${False}
	Set Test Variable    ${all_tp}    ${all_tp}

Stop traffic according to direction and protocol
    [Arguments]  ${tp_direction}=both
    log to console      Stop traffic
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Stop traffic    direction=ul
    ...    ue_index=${0}    ue_type=${ue_type}    iperf_type=via_command    protocol=tcp
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'      power_ue.Stop traffic    direction=dl
    ...     ue_index=${0}    ue_type=${ue_type}    protocol=tcp

Check 8955 Performance counter
    [Arguments]   ${IFEligilble}
    Run keyword if    ${IFEligilble}==${True}     Check counter value for Eligilble UE without RBGlimit     counter_id=${du_counter_id_list}
    ...     ELSE         Check counter value for non-Eligilble UE    counter_id=${du_counter_id_list}

Check counter value for Eligilble UE without RBGlimit
    [Arguments]    ${counter_id}
    FOR    ${counter}    IN   @{counter_id}
        ${counter_result}  vDU Get last PM Counter Values    counter_id= ${counter}    dimension_dist_name=${MR_NR_CELL_NAME}
        run keyword if    '${counter}' == 'M55308C00019'   should be true   ${counter_result} > 399000
        ...     ELSE    should be true   ${counter_result} > 104902500
    END

Check counter value for non-Eligilble UE
    [Arguments]    ${counter_id}
    FOR    ${counter}    IN   @{counter_id}
        ${counter_result}  vDU Get last PM Counter Values    counter_id= ${counter}    dimension_dist_name=${MR_NR_CELL_NAME}
        run keyword if    '${counter}' == 'M55308C00019'   should be true   ${counter_result} < 100
        ...     ELSE     should be true   ${counter_result} < 27300
    END

Check counter value greater than 0
    [Arguments]    ${counter_id}
    FOR    ${counter}    IN   @{counter_id}
        ${counter_result}  vDU Get last PM Counter Values    counter_id= ${counter}    dimension_dist_name=${MR_NR_CELL_NAME}
        Run Keyword And Continue On Failure   should be true   ${counter_result} > 0
    END

vDU Get last PM Counter Values
    [Arguments]    ${counter_id}    ${dimension_dist_name}      ${vdu_index}=0
    ${counter_result}    vDU Get PM Counter Values    ${counter_id}    ${dimension_dist_name}    ${vdu_index}
    ${len}    Get Length    ${counter_result}
    @{counter_value_list}=    create list
    FOR  ${i}  IN RANGE  ${len}
       ${temp_dic}    Set Variable   ${counter_result[${i}]}
       ${temp_value}   Get From Dictionary    dictionary=${temp_dic}    key=value
       ${counter_value}    Convert To Integer    ${temp_value}
       append to list   ${counter_value_list}   ${counter_value}
    END
    ${counter_value}    Convert To Integer    ${counter_value_list[-1]}
    [return]    ${counter_value}

vDU Get PM Counter Values
    [Arguments]   ${counter_id}   ${dimension_dist_name}  ${vdu_index}=0
    [Documentation]    Get latest counter value from webUI via rest API.
    ...    firstly, using restapi to get the counter whole info, then get the latest value
    ...    | Input Parameters | Man. | Description |
    ...    | counter_id | Yes | PM counter ID |
    ...    | dimension_dist_name | Yes | the dimension dist name that the counter belongs to, like MRBTS-2072/NRBTS-2072/NRCELL-1/NCELA |
    ...    | vdu_index | No |  vdu index to indicate which vdu will be used, 0 in default  |
    ...    *RETURN VALUE*
    ...    List of counter value
    vDU Rest Login    vdu_index=${vdu_index}
    ${counter_id} =    Replace String    ${counter_id}   ${SPACE}   ${EMPTY}
    ${counter_list}=  vdu.get_counter_values    ${counter_id}   ${dimension_dist_name}
    [return]    ${counter_list}
    [Teardown]   vDU Rest Logout   vdu_index=${vdu_index}

UE attach with DL traffic
    [Arguments]  ${dltarget_throughput}    ${data_send_dl}
    log to console    UE attach with DL traffic
    power_ue.Prepare UE    ue_index=${0}    ue_type=${ue_type}
    power_ue.UE Attach    ue_index=${0}    ue_type=${ue_type}  # attach_mode=5G_NSA
    ${actual_dltput}    Start traffic and check result    dltp_expected=${dltarget_throughput}
    ...     data_send_dl=${data_send_dl}   tp_direction=dl
    [Return]  ${actual_dltput}

Collect TTItrace
    log to console   Collect TTItrace
    Start TTI Trace Capture Via DCAP Basic
    sleep   5s
	${Trace_log}=  Stop TTI Trace Capture Via DCAP Basic
    [Return]  ${Trace_log}

Decoder TTITrace
    [Arguments]  ${Trace_log}
    log to console    Decoder TTITrace
    ${vdu_version}=    _Get Running Build Number OCP
	${local_dl_csv}  ${local_ul_csv}=    Decoder TTITrace With Windows PC    ${ttitrace_server_ip}    ${TTI_username}
	...  ${TTI_password}   ${vdu_version}    ${Trace_log}
#	${dl_csv}=    combine_multi_csv_files    ${local_dl_csv}
#	set test variable  ${dl_csv}
    Set test Variable   ${dl_csv}   ${local_dl_csv}/tti_pcap_dl.csv
    [Return]  ${dl_csv}

##### TTI trace Keywords ######
#Start To Collect TTI Trace
#    [Arguments]     ${gnb_index}=${0}    ${vdu_index}=${0}   ${nr_cell_list}=${None}   ${dscp}=0
#    [Documentation]  Start to collect L2RT TTI trace
#    ...    author: lingting.sun@nokia-sbell.com
#    ...    modified by:        <24-Dec-2021>, <lingtsun>, <Initial creation>
#    ...    | Input Parameters | Man. | Description |
#    ...    |  gnb_index        | No   |  the index of cu,  ${0} in default |
#    ...    |  vdu_index        | No   |  the index of vdu,  ${0} in default |
#    ...    |  nr_cell_list     | No   |  the nr cell id list,  ${None} in default, means the 1st cell |
#   ...    |  dscp             | No   |  the dscp value,  0 in default |
#    ...    *RETURN VALUE*
#    ...    None
#    ...    Example
#    ...    |  Start To Collect TTI Trace |  ${0}  |
#    log to console    Start To Collect TTI Trace
#    ${oam_ip}   Get vDU OAM Ip   gnb_index=${gnb_index}   vdu_index=${vdu_index}
#    ${ip_type}   check ip type    ${oam_ip}
#    ${cell_list}   vDU Get Cells ID list
#    ${cell_list_copy}    get slice from list  ${cell_list}   end=1
#    ${nr_Cell_list_copy}  set variable if   ${nr_cell_list} is ${None}   ${cell_list_copy}   ${nr_cell_list}
#    ${dcap_server_ip}=   run keyword if  "${ip_type}"=="ipv4"   set variable   ${DCAP_IP}
#    ...  ELSE    set variable   ${DCAP_IPv6}
#    set test variable    ${ip_type}
#    set test variable    ${dcap_server_ip}
#    _Online Add DCAP Server Route    ${dcap_server_ip}
#    _Start TTI Trace Via UPTrace       ip_type=${ip_type}    gnb_index=${gnb_index}   vdu_index=${vdu_index}
#    ...    nr_cell_list=${nr_Cell_list_copy}   dscp=${dscp}

_Online Add DCAP Server Route
    [Arguments]    ${destIpAddr}
    ${uni_id}   Get Unique Id
    ${scf_path}  Get A Directory  SCF
    VDU Rest Login
    ${scf_full_path}=  vdu.Get Current Plan File  ${scf_path}  full_scf_${uni_id}.xml  include_runtime_data=${True}
    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${scf_full_path}
    set test variable    ${mrbts_id}
    set test variable    ${nrbts_id}
    set test variable    ${scf_full_path}
    ${route_name}  Set Variable If  "${ip_type}"=="ipv4"  IPRT  IPRTV6
    ${dist}   set variable    MRBTS-${mrbts_id}/TNLSVC-1/TNL-3/IPNO-1/${route_name}-1
    ${add_route}   ${gateway}=   _Check Dcap Server Route Exist    ${destIpAddr}    ${dist}
    run keyword if  "${add_route}"=="PASS"  run keywords  log to console   Route to DCAP server is needed, add the route
    ...   AND  Vdu Add Route  ${dist}    ${destIpAddr}  32  ${gateway}

_Check Dcap Server Route Exist
    [Arguments]    ${destIpAddr}    ${dist}
    scf.Load Scf   ${scf_full_path}
    ${route_dstip_name}  Set Variable If  "${ip_type}"=="ipv4"  destIpAddr  destIpv6Addr
    ${route_gateway_name}  Set Variable If  "${ip_type}"=="ipv4"  gateway   gatewayIpv6Addr
    ${res}  ${dest_ip}   Run Keyword And Ignore Error  scf.Get All Values From Scf   dist_name=${dist}
    ...  p_name=${route_dstip_name}
    ${res}  ${gateway}   Run Keyword And Ignore Error  scf.Get All Values From Scf   dist_name=${dist}
    ...  p_name=${route_gateway_name}
    ${res}  ${out}  Run Keyword And Ignore Error   Should Not Contain Match   ${dest_ip}    ${destIpAddr}
    [return]    ${res}    ${gateway[0]}


#_Start TTI Trace Via UPTrace
#    [Arguments]    ${ip_type}     ${gnb_index}    ${vdu_index}   ${nr_cell_list}   ${dscp}=0
##    ${f1u_ip}=   run keyword if  "${ip_type}"=="ipv4"   Get f1uplane Ipv4 Address For vDU
##    ...  ELSE    Get f1uplane Ipv6 Address For vDU
#    ${f1u_ip}=   Get f1uplane Ipv4 Address For vDU
#    Delete Uplane Trace File On Dcap Server For Certain vDU Site    ${f1u_ip}
#    ${cell_list}    create list
#    :FOR   ${cell_id}    IN    @{nr_cell_list}
#    \      ${cell_id}    set variable   MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cell_id}
#    \      append to list   ${cell_list}    ${cell_id}
#    vDU Login   vdu_index=${vdu_index}  #  gnb_index=${gnb_index}
#    Update User Plane Trace Configuration For vDU    uplane_ip_addr=${dcap_server_ip}      uplane_port=55900   dscp=${dscp}
#    ${trace_id}=   Start Uplane Trace For vDU    target_component=L2Ps     nr_cell_dn_list=${cell_list}    trace_type=Component
#    set test variable    ${trace_id}
#    set test variable    ${f1u_ip}
#    [teardown]  vDU Logout

Start TTI Trace Capture Via DCAP Basic
    [Arguments]     ${gnb_index}=${0}    ${vdu_index}=${0}   ${nr_cell_list}=${None}   ${dscp}=0
    [Documentation]  Start to collect L2RT TTI trace
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <24-Dec-2021>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index        | No   |  the index of cu,  ${0} in default |
    ...    |  vdu_index        | No   |  the index of vdu,  ${0} in default |
    ...    |  nr_cell_list     | No   |  the nr cell id list,  ${None} in default, means the 1st cell |
   ...    |  dscp             | No   |  the dscp value,  0 in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Start To Collect TTI Trace |  ${0}  |
    log to console    Start To Collect TTI Trace
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
    DCAP.connect_to     host=${DCAP_IP}    port=${DCAP_port}     username=${DCAP_USER}
    ...     password=${DCAP_PASSWORD}     secure=True
    ${vdu_custom_profile}=     Create List     L2Ps_Component
    ${gnb_custom_profile}=     Create List     cp_5g
    Create Bts On DCAP
    ${output}    DCAP.start_trace     bts=${bts_vdu}     wait_for_activation=${True}
    ...     control_plane_interface=${True}     vdu_custom_profile=${vdu_custom_profile}
    Log    ${output}[id]
    set suite variable    &{output}

Create Bts On DCAP
    [Arguments]    ${bts_mr_id}=2078
    ${bts_info}    DCAP.get_all_bts_info
    #log to console    ${bts_info}
    ${bts_info_length}    get length    ${bts_info}
    FOR    ${index}    IN RANGE    ${bts_info_length}
        ${is_bts_exist}    set variable if    ${bts_info[${index}]['mr_bts_id']} == ${bts_mr_id}    true    false
        Exit For Loop If    '${is_bts_exist}'=='true'
    END
    run keyword if    '${is_bts_exist}' != 'true'    DCAP.create_bts
    ...    host=${tl.gnbs[0].dus[0].oam_http_connection_details.addr}
    ...    password=${tl.gnbs[0].dus[0].oam_http_connection_details.password}
    ...    ELSE    log to console    message=the specific bts is exist

#Stop And Download TTI Trace
#    [Arguments]    ${gnb_index}=${0}    ${vdu_index}=${0}
#    [Documentation]  Stop and downlaod all the tti trace files
#    ...    author: lingting.sun@nokia-sbell.com
#    ...    modified by:        <24-Dec-2021>, <lingtsun>, <Initial creation>
#    ...    | Input Parameters | Man. | Description |
#    ...    |  gnd_index  | No   |  the index of cu,  ${0} in default  |
#    ...    |  vdu_index  | No   |  the index of vdu,  ${0} in default |
#    ...    *RETURN VALUE*
#    ...    trace_path_list in ute
#    ...    Example
#    ...    |  Stop And Download TTI Trace |  ${0}  |  ${0}  |
#    log to console    Stop L2PS TTI trace and download the pcap file from DCAP server
#    vDU Login   vdu_index=${vdu_index}   # gnb_index=${gnb_index}
#    Stop Uplane Trace For vDU    trace_id=${trace_id}
#    ${TTI_local_path}=    Download Newest Uplane Trace Files for vDU From Dcap Server    ${f1u_ip}
#    ${TTI_local_path_list}  create list  ${TTI_local_path}
#    [return]   ${TTI_local_path_list}
#    [teardown]  vDU Logout

Stop TTI Trace Capture Via DCAP Basic
    [Documentation]  Stop TTI Trace Capture Via DCAP Basic
    log to console    Stop TTI Trace Capture Via DCAP Basic
    DCAP.stop_trace    trace_id=${output}[id]
    sleep  300s
    ${downloaded_emil_file_path}    DCAP.get_results    result_id=${output}[id]    target_dir=${TS_LOG_PATH_BASE}
    csn.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=ute
    csn.Execute   command=rm -rf ${TS_LOG_PATH_BASE}dcap_tmp    connection=ute
    csn.Execute   command=unzip ${downloaded_emil_file_path} -d ${TS_LOG_PATH_BASE}dcap_tmp    connection=ute
    csn.Execute   command=rm ${downloaded_emil_file_path}    connection=ute
    ${downloaded_emil_file}=    csn.Execute   command=ls -R ${TS_LOG_PATH_BASE}dcap_tmp | grep .pcap |head -n 1    connection=ute
    ${downloaded_emil_file}   Strip String   ${downloaded_emil_file}    characters=\r\n
    ${downloaded_emil_file_path}=    csn.Execute   command=find ${TS_LOG_PATH_BASE}dcap_tmp -name ${downloaded_emil_file}    connection=ute
    ${downloaded_emil_file_path}   Strip String   ${downloaded_emil_file_path}    characters=\r\n
    ${downloaded_emil_file_path}  create list  ${downloaded_emil_file_path}
    set suite variable    ${downloaded_emil_file_path}
    [return]   ${downloaded_emil_file_path}[0]
    [teardown]  run keywords       csn.Execute   command=rm -rf ${downloaded_emil_file_path}    connection=ute
    ...   AND     csn.disconnect    connection=ute

#Decoder TTITrace With Linux Server
#    [Arguments]  ${ttitrace_server_ip}  ${username}  ${password}  ${vdu_version}  ${ttiTrace_files_list}=${EMPTY}
#    ...  ${alias}=ttiTrace_linux_server
#    ...  ${tool_base_repo}=https://artifactory-espoo1.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release/
#    ...  ${vdu_release}=vDUCNF
#    [Documentation]  decode the tti trace bin.tar.gz files, the ttitrace file name is like 'L2TtiTrace_EventsSnapshot.bin.4.tar.gz'
#    ...    author: calla.wang@nokia-sbell.com
#    ...    | Input Parameters | Man. | Description |
#    ...    | ttitrace_server_ip | Yes |  the ttitrace decoded server ip |
#    ...    | username | Yes |  the server username |
#    ...    | password | Yes |  the server password |
#    ...    | vdu_version | Yes |  vdu build version |
#    ...    | ttiTrace_files_list | Yes | ttitrace bin gz files list, returned from kw-Stop And Download TTI Trace|
#    ...    | alias | NO | the server connection alias, default is ttiTrace_linux_server |
#    ...    | tool_base_repo | NO | the repo of download the ttitrace tool |
#    ...    *RETURN VALUE*
#    ...    the ul csv files folder, the dl csv fils folder
#    ...    Example
#    ...    | Decoder TTITrace With Linux Server | 10.108.229.50 |ute | ute | 0.390.1222 | ${tti_files_list}
#    tafssh.connect_to
#    ...  hostname=${ttitrace_server_ip}
#    ...  username=${username}
#    ...  password=${password}
#    ...  alias=${alias}
#    _Create Related Folders  ${alias}
#    _Get Decode Tool And Untar  ${tool_base_repo}  ${vdu_version}  ${alias}   ${vdu_release}
#    ${local_dl_csv}  ${local_ul_csv}  _Decode TTITRACE Bin Files And Download csv To Local  ${ttiTrace_files_list}  ${alias}
#    [Return]  ${local_dl_csv}  ${local_ul_csv}
#    [Teardown]   run keywords    tafssh.Execute  command=rm -rf ${ttiTrace_Dir}  connection=${alias}
#        ...      AND             tafssh.disconnect  connection=${alias}
 #   [Teardown]   tafssh.disconnect  connection=${alias}

#_Create Related Folders
#    [Arguments]  ${conn_alias}
#    ${home_dir}=  tafssh.execute  command=pwd   connection=${conn_alias}
#    ${timestamp}=    Get Time    epoch
#    ${home_dir}=  Strip String  ${home_dir}
#   # Set test Variable   ${ttiTrace_Dir}   ${home_dir}/ttiTrace_${timestamp}
#    Set suite Variable   ${ttiTrace_Dir}   ${home_dir}/ttiTrace_${timestamp}
#    set test variable  ${tti_bins_dir}   ${ttiTrace_Dir}/tti-dec-bin/ttitrace_bins
#    set test variable   ${decoded_csv}   ${ttiTrace_Dir}/tti-dec-bin/decoded_csv
#    tafssh.Execute  command=mkdir ${ttiTrace_Dir} && mkdir -p ${tti_bins_dir} && mkdir -p ${decoded_csv}
#    ...  connection=${conn_alias}

_Create Related Folders for windows
    [Arguments]  ${conn_alias}
    ${home_dir}=  tafssh.execute  command=pwd   connection=${conn_alias}
    ${timestamp}=    Get Time    epoch
    ${home_dir}=  Strip String  ${home_dir}
    Set suite Variable   ${ttiTrace_Dir}   ${home_dir}/ttiTrace_${timestamp}
    set test variable  ${tti_bins_dir}   ${ttiTrace_Dir}/tti-dec-bin/
    tafssh.Execute  command=mkdir ${ttiTrace_Dir}   connection=${conn_alias}

#_Get Decode Tool And Untar
#    [Arguments]   ${tool_base_repo}  ${vdu_version}  ${conn_alias}  ${vdu_release}=vDUCNF
#    ${vdu_release}=  Get vDU Release Version Via Rest
#    ${decoder_tool_name}=  set variable  ${vdu_release}_${vdu_version}_tti-dec_qemux86-64-static.txz
#    ${tool_url}=  set variable  ${tool_base_repo}${vdu_version}/${decoder_tool_name}
#    ${output}=   tafssh.Execute  command=wget --no-check-certificate ${tool_url} -P ${ttiTrace_Dir}  connection=${conn_alias}
#    should contain    ${output}   200 OK   msg=Download decode tool failed
#    tafssh.Execute  command=cd ${ttiTrace_Dir} && tar -xJvf ${ttiTrace_Dir}/${decoder_tool_name} && rm -f ${decoder_tool_name}
#    ...  connection=${conn_alias}


_Get Decode Tool And Untar for windows
    [Arguments]   ${tool_base_repo}  ${vdu_version}  ${conn_alias}  ${vdu_release}=vDUCNF
    ${vdu_release}=  Get vDU Release Version Via Rest
    ${decoder_tool_name}=  set variable  ${vdu_release}_${vdu_version}_tti-dec_mingw-win32.txz
    ${tool_url}=  set variable  ${tool_base_repo}${vdu_release}/${vdu_release}_${vdu_version}/${decoder_tool_name}
    ${output}=   tafssh.Execute  command=cd ${ttiTrace_Dir} && wget --no-check-certificate ${tool_url}  connection=${conn_alias}
    should contain    ${output}   200 OK   msg=Download decode tool failed
    tafssh.Execute  command=cd ${ttiTrace_Dir} && tar -xJvf ${ttiTrace_Dir}/${decoder_tool_name} && rm -f ${decoder_tool_name}
    ...  connection=${conn_alias}

Decoder TTITrace With Windows PC
    [Arguments]  ${ttitrace_server_ip}  ${username}  ${password}  ${vdu_version}  ${ttiTrace_files_list}=${EMPTY}
    ...  ${alias}=ttiTrace_linux_server
    ...  ${tool_base_repo}=https://artifactory-espoo1.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release/
    ...  ${vdu_release}=vDUCNF
    tafssh.connect_to
    ...  hostname=${ttitrace_server_ip}
    ...  username=${username}
    ...  password=${password}
    ...  alias=${alias}
    _Create Related Folders for windows  ${alias}
    _Get Decode Tool And Untar for windows  ${tool_base_repo}  ${vdu_version}  ${alias}   ${vdu_release}
    ${local_dl_csv}  ${local_ul_csv}  _Decode TTITRACE Bin Files And Download csv To Local for windows  ${ttiTrace_files_list}  ${alias}
    [Return]  ${local_dl_csv}  ${local_ul_csv}
    [Teardown]   run keywords    tafssh.Execute  command=rm -rf ${ttiTrace_Dir}  connection=${alias}
        ...      AND             tafssh.disconnect  connection=${alias}

Get vDU Release Version Via Rest
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Documentation]  Get vDU Release Version Via Rest
    ...    *Author:* lingting.sun@nokia-sbell.com
    ...    *Change History*
    ...    | date | who | waht or how |
    ...    | 2022-2-28 | lingtsun | init create |
    ...    *Arguments Description*
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | No | int, gnb index. |
    ...    | vdu_index | No | int, vdu index. |
    ...    *Example*
    ...    | Get vDU Release Version Via Rest | 0 | 0 |
    ...    *Return*
    ...    - string, vdu release version
    ${trunk}  set variable  23R2
    vDU Rest Login  #  gnb_index=${gnb_index}   vdu_index=${vdu_index}  # alias=get_vdu_release
    ${vdu_info}=   vdu.get_vdu_state_data   # vdu_connection=get_vdu_release
    ${vdu_release_info}=    split string   ${vdu_info["software_version"]}   _
    ${release_version}   set variable if  '${trunk}' in '${vdu_release_info[0]}'   vDUCNF00
    ...        '${trunk}' not in '${vdu_release_info[0]}'    ${vdu_release_info[0]}
    [return]   ${release_version}
    [Teardown]  vDU Logout   # alias=get_vdu_release

_Decode TTITRACE Bin Files And Download csv To Local for windows
    [Arguments]   ${ttitrace_file}   ${conn_alias}
    ${curr_date}    Get Current Date    result_format=%Y%m%d_%H%M%S    exclude_millis=True
    ${local_dl_csv}=  Get A Directory  dl  log_${curr_date}
    ${local_ul_csv}=  Get A Directory  ul  log_${curr_date}
    ${path}  ${bin_file_name}=  OperatingSystem.Split Path  ${ttitrace_file}
    ${rest}  ${bin_file_index}=  Split String From Right  ${bin_file_name}  separator=.  max_split=1
    tafssh.upload_file  local_path=${ttitrace_file}
    ...  remote_path=${tti_bins_dir}/${bin_file_name}  connection=${conn_alias}
    tafssh.Execute  command=cd ${ttiTrace_Dir}/tti-dec-bin && python TtiTraceDecoder.py ${bin_file_name} excelCsv  connection=${conn_alias}
    ${dl_file_exists}=  tafssh.file exists   ${ttiTrace_Dir}/tti-dec-bin/ttiTrace_dl.csv   connection=${conn_alias}
    ${ul_file_exists}=  tafssh.file exists   ${ttiTrace_Dir}/tti-dec-bin/ttiTrace_ul.csv   connection=${conn_alias}
    run keyword if    "${dl_file_exists}"=="True"  tafssh.download file  remote_path=${ttiTrace_Dir}/tti-dec-bin/ttiTrace_dl.csv
    ...  local_path=${local_dl_csv}/tti_${bin_file_index}_dl.csv  connection=${conn_alias}
    run keyword if    "${ul_file_exists}"=="True"  tafssh.download_file  remote_path=${ttiTrace_Dir}/tti-dec-bin/ttiTrace_ul.csv
    ...  local_path=${local_ul_csv}/tti_${bin_file_index}_ul.csv  connection=${conn_alias}
    [Return]  ${local_dl_csv}  ${local_ul_csv}



#_Decode TTITRACE Bin Files And Download csv To Local
#    [Arguments]   ${ttiTrace_files_list}   ${conn_alias}
#    ${curr_date}    Get Current Date    result_format=%Y%m%d_%H%M%S    exclude_millis=True
#    ${local_dl_csv}=  Get A Directory  dl  log_${curr_date}
#    ${local_ul_csv}=  Get A Directory  ul  log_${curr_date}
##    ${cmd_1}   Catenate    pip3 install numpy -i https://artifactory-hz1.ext.net.nokia.com/artifactory/api/pypi/ta-lib-5g-virtual/simple
##    ...    --extra-index-url   http://pypi.ute.nsn-rdnet.net/ --trusted-host artifactory-hz1.ext.net.nokia.com --trusted-host pypi.ute.nsn-rdnet.net
##    tafssh.execute  command=${cmd_1}    connection=${conn_alias}
##    ${cmd_2}   Catenate    pip3 install pandas -i https://artifactory-hz1.ext.net.nokia.com/artifactory/api/pypi/ta-lib-5g-virtual/simple
##    ...   --extra-index-url   http://pypi.ute.nsn-rdnet.net/ --trusted-host artifactory-hz1.ext.net.nokia.com --trusted-host pypi.ute.nsn-rdnet.net
##    tafssh.execute  command=${cmd_2}    connection=${conn_alias}
#    :For  ${ttitrace_file}  IN  @{ttiTrace_files_list}
#    \  ${path}  ${gz_file_name}=  OperatingSystem.Split Path  ${ttitrace_file}
#    \  ${bin_file_name}=  Fetch From Left  ${gz_file_name}  marker=.tar.gz
#    \  ${rest}  ${bin_file_index}=  Split String From Right  ${bin_file_name}  separator=.  max_split=1
#    \  tafssh.upload_file  local_path=${ttitrace_file}
#    ...  remote_path=${tti_bins_dir}/${gz_file_name}  connection=${conn_alias}
#    \  tafssh.Execute  command=cd ${tti_bins_dir} && tar -zxvf ${gz_file_name} && rm -f ${gz_file_name}
#    ...  connection=${conn_alias}
#    \  ${decode_cmd}  Catenate  cd ${ttiTrace_Dir}/tti-dec-bin;
#    ...  python3 TtiTraceDecoder.py ${tti_bins_dir}/${bin_file_name} excelCsv -o ${decoded_csv}/tti_${bin_file_index}
#    \  tafssh.execute  command=${decode_cmd}   connection=${conn_alias}
#    \  ${dl_file_exists}=  tafssh.file exists   ${decoded_csv}/tti_${bin_file_index}_dl.csv   connection=${conn_alias}
#    \  ${ul_file_exists}=  tafssh.file exists   ${decoded_csv}/tti_${bin_file_index}_ul.csv   connection=${conn_alias}
#    \  run keyword if    "${dl_file_exists}"=="True"  tafssh.download file  remote_path=${decoded_csv}/tti_${bin_file_index}_dl.csv
#    ...  local_path=${local_dl_csv}/tti_${bin_file_index}_dl.csv  connection=${conn_alias}
#    \  run keyword if    "${ul_file_exists}"=="True"  tafssh.download_file  remote_path=${decoded_csv}/tti_${bin_file_index}_ul.csv
#    ...  local_path=${local_ul_csv}/tti_${bin_file_index}_ul.csv  connection=${conn_alias}
#    [Return]  ${local_dl_csv}  ${local_ul_csv}

Update User Plane Trace Configuration For vDU
    [Arguments]    ${uplane_ip_addr}    ${uplane_port}      ${dscp}=0
    [Documentation]   Update User Plane Trace Configuration
    ...   *AUTHOR* rita.feng@nokia-sbell.com
    ...   modified by:        <27-Jul-2021>, <rifeng>, <Initial creation>
    ...   | Input Parameters    | Man. | Description |
    ...   | uplane_ip_addr      | yes | destination ip for dcap |
    ...   | uplane_port       | yes | user plane trace port in dcap |
    ...   | dscp              | yes | default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    return vdu_connection.update_uplane_configuration(uplane_ip_addr=uplane_ip_addr,
    ...                                   uplane_port=uplane_port,dscp=dscp,timeout=timeout)
    ...
    ...   Example
    ...   | VDU Rest Login |
    ...   | Update User Plane Trace Configuration | uplane_ip_addr=10.110.95.16  |  uplane_port=55900 |
    ...   | VDU Rest Logout |
    ${uplane_port_1}    Convert To Integer    ${uplane_port}
    ${dscp_1}    Convert To Integer    ${dscp}
    ${res1}    vdu.update_uplane_configuration
    ...    uplane_ip_addr=${uplane_ip_addr}    uplane_port=${uplane_port_1}    dscp=${dscp_1}
    sleep    10s
    ${res2}    vdu.get_trs_api_operation_status    operation_id=${res1}
    [Return]    ${res2}

Start Uplane Trace For vDU
    [Arguments]    ${target_component}    ${nr_cell_dn_list}    ${trace_type}=Component
    [Documentation]   Start uplane Trace
    ...   *AUTHOR* rita.feng@nokia-sbell.com
    ...   modified by:        <27-Jul-2021>, <rifeng>, <Initial creation>
    ...   | Input Parameters    | Man. | Description |
    ...   | target_component    | yes | which component trace: L2HiRlc/L2Lo/L2Ps|
    ...   | nr_cell_dn_list     | yes | which cell |
    ...   | trace_type          | yes | which trace type:Component/Sherpa |
    ...
    ...   *RETURN VALUE*
    ...   return vdu_connection.start_uplane_trace_stream(trace_type=trace_type,
    ...    target_component=target_component, nr_cell_dn_list=nr_cell_dn_list,timeout=timeout)
    ${res1}    vdu.start_uplane_trace_stream
    ...    target_component=${target_component}    nr_cell_dn_list=${nr_cell_dn_list}    trace_type=${trace_type}
    Log To Console    ${res1}
    sleep    3s
    ${res2}    vdu.get_active_trace_streams
    Log To Console    ${res2[0]['trace_id']}
    [Return]    ${res2[0]['trace_id']}

Stop Uplane Trace For vDU
    [Arguments]    ${trace_id}
    [Documentation]   Stop uplane Trace
    ...   *AUTHOR* rita.feng@nokia-sbell.com
    ...   modified by:        <27-Jul-2021>, <rifeng>, <Initial creation>
    ...   | Input Parameters    | Man. | Description |
    ...   | trace_id            | yes | which component trace |

    ${res1}    vdu.stop_uplane_trace_stream    trace_id=${trace_id}
    sleep    3s
    Log To Console    ${res1}

Delete Uplane Trace File On Dcap Server For Certain vDU Site
    [Arguments]    ${ip}
    [Documentation]  Delete Uplane Trace File On Dcap Server For Certain vDU Site
    ...    author: rita.feng@nokia-sbell.com
    ...    modified by:        <29-Jul-2021>, <rifeng>, <Initial creation>
    ...    modified by:        <4-Aug-2021>, <rifeng>, <add argument ip>
    ...    modified by:        <18-Dec-2021>, <huilxu>, <add docker restart UDPTracer>
    ...    | Input Parameters | Man. | Description |
    ...    |  ip  | Tes |  ip for f1uplane |
    ...    *RETURN VALUE*
    ...    dcap log file path on server
    ...    Example
    ...    |  Delete Uplane Trace File On Dcap Server For Certain vDU Site    ${ip}|
    ${alias}  get unique id
    Connect To DCAP   alias=${alias}
    ${session_ls}   issh.Execute   command=ls /sharedvolume/udptracer/   alias=${alias}
    ${match}    Get Regexp Matches    _data    ${session_ls}
    run keyword if   ${match} != []      Delete Uplane Trace File On Dcap Server    ${ip}   ${alias}
    [Teardown]   run keyword and ignore error   disconnect interactive connection  alias=${alias}

Delete Uplane Trace File On Dcap Server
    [Arguments]    ${ip}   ${alias}
    ${sessions}   issh.Execute   command=cd ${DCAP_UP_LOG_DIR}   alias=${alias}
    ${trace_files}   issh.Execute   command=find ${DCAP_UP_LOG_DIR} -name \"\*${ip}\*\" -exec rm -rfv {} \\;    alias=${alias}
    sleep    10s
    ${trace_files}   issh.Execute   command=find ${DCAP_UP_LOG_DIR} -name \"\*${ip}\*\"    alias=${alias}
    ${trace_files}   convert to string    ${trace_files}
    Should Not Contain    ${trace_files}    ${ip}

Get Latest Uplane Trace File Name for vDU On Dcap Server
    [arguments]    ${ip}
    [Documentation]  Get Latest Uplane Trace File Name for vDU On Dcap Server
    ...    author: rita.feng@nokia-sbell.com
    ...    modified by:        <4-Aug-2021>, <rifeng>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  ip  | Tes |  ip for f1uplane |
    ...    *RETURN VALUE*
    ...    dcap log file path on server
    ...    Example
    ...    |  Get Latest Uplane Trace File Name for vDU On Dcap Server    ${ip}|
    ${alias}    get unique id
    Connect To DCAP   alias=${alias}
    ${sessions}    issh.Execute    command=cd ${DCAP_UP_LOG_DIR}    alias=${alias}
    ${trace_files}    issh.Execute    command=find ${DCAP_UP_LOG_DIR} -name \"\*${ip}\*\" | xargs ls --sort=time   alias=${alias}
    ${trace_files}  set variable  ${trace_files.replace("\r\n"," ")}
    ${trace_files}   Set Variable   ${trace_files.split()}
    Run Keyword If   ${trace_files.__len__()}>=1   Remove From List  ${trace_files}   index=-1
    Run Keyword If   ${trace_files.__len__()}>=1   Remove From List  ${trace_files}   index=-1
    Return From Keyword If    len(${trace_files})==0 or (len(${trace_files})==1 and """${trace_files[0]}"""=="""""")    ${EMPTY}
    [Return]    ${trace_files[0]}
    [Teardown]    run keyword and ignore error    disconnect interactive connection  alias=${alias}

Download Newest Uplane Trace Files for vDU From Dcap Server
    [arguments]    ${ip}
    [Documentation]  Download Newest Uplane Trace Files for vDU From Dcap Server
    ...    author: rita.feng@nokia-sbell.com
    ...    modified by:        <4-Aug-2021>, <rifeng>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  ip  | Tes |  ip for f1uplane |
    ...    *RETURN VALUE*
    ...    local dcap log file path or ${EMPTY}
    ...    Example
    ...    |  Download Newest Uplane Trace Files for vDU From Dcap Server    ${ip}|
    ${curr_date}    Get Current Date    result_format=%Y%m%d_%H%M%S    exclude_millis=True
    ${local_dir}    Get A Directory    dcap_log    log_${curr_date}
    ${trace_file}    Get Latest Uplane Trace File Name for vDU On Dcap Server    ${ip}
    Return From Keyword If    """${trace_file}"""=="""${EMPTY}"""
    ${trace_dir}    ${trace_file_name}    Split Path    ${trace_file}
    ${trace_file_name}    Set Variable    ${trace_file_name.replace(":", "")}
    ${alias}  get unique id
    Connect To DCAP    alias=${alias}
    issh.download file    remote_path=${trace_file}    local_path=${local_dir}/${trace_file_name}   alias=${alias}
    [Return]    ${local_dir}/${trace_file_name}
    [Teardown]    run keyword and ignore error    disconnect interactive connection  alias=${alias}

Get f1uplane Ipv4 Address For vDU
    [Documentation]    Get f1uplane Ipv4 Address for vDU
    ...   *AUTHOR* rita.feng@nokia-sbell.com
    ...    modified by:        <03-Aug-2021>, <rifeng>, <Initial creation>
    Connect To K8s master
    ${out}    Kubectl Exec    pod_abbr=up    container=nwmgmt    command=ip addr show f1uplane
    ${f1u_ip}    Parse Ipv4 Address Only From Content    ${out}
    Disconnect From K8s Master
    [return]    ${f1u_ip}

Online Set prbAllocationDirection To high2low
    &{parameter_dict}    Create Dictionary   dlInterferenceAvoidance/0/prbAllocationDirection=highPerforming_High2low
    vdu rest login
    VDU Online Modify Parameters By Delta Plan REST   mo_dn=${MR_NR_CELL_NAME}
	...                                          updated_paras_list=${parameter_dict}
	...                                          operation=replace
	...                                          activate=${True}
    ...                                          force_reset=${False}
    ...                                          auto_lock_cells=${True}
    ...                                          wait_vdu_up=${False}
    vDU Rest Logout

Modify DU 8955 Parameter
    [Arguments]  ${Modify_Params1_key}    ${Modify_Params1_value}
    vdu rest login
    ${plan_id}   ${action_id}   Generate delta plan     CB008955
    set suite variable    ${plan_id}
    &{param_dict}   Create Dictionary    actDlInterferenceAvoidance=true
    Update Delta Plan Parameter    plan_id=${plan_id}    mo_dn=${MR_NR_CELL_NAME}    updated_paras_dict=${param_dict}    operation=replace
    ${paras_list}    Create Dictionary   /dlInterferenceAvoidance=${EMPTY}
    Update Delta Plan Parameter   plan_id=${plan_id}   mo_dn=${MR_NR_CELL_NAME}      updated_paras_dict=${paras_list}   operation=add
    &{parameter_dict}     Generate Parameter     ${Modify_Params1_key}    ${Modify_Params1_value}
    Update Delta Plan Parameter    plan_id=${plan_id}    mo_dn=${MR_NR_CELL_NAME}    updated_paras_dict=${parameter_dict}    operation=add
    ${scf_path}  Get A Directory  scf
    set suite variable    ${scf_path}
    ${delta_filename}   Set Variable   CB008955.xml
    ${delta_scf_fullpath}   vdu.Save Delta Plan File   local_path=${scf_path}   local_filename=${delta_filename}
    Activate Delta Plan By REST   ${plan_id}   wait_vdu_up=False
    wait until keyword succeeds   600  30   OAM Precondition Cell Should Be Onair

Generate Parameter
    [Arguments]   ${list_key}   ${list_value}
    &{parameter_dict}   Create Dictionary
    ${length}=   Get Length   ${list_key}
    FOR   ${index}   IN RANGE   0   ${length}
        Set to Dictionary     ${parameter_dict}    ${list_key[${index}]}     ${list_value[${index}]}
    END
    [Return]    &{parameter_dict}

Check TTI trace for Eligible UE
    [Arguments]  ${local_dl_csv}
    ${rnti_list}   get_rnti_from_csv_file   ${local_dl_csv}
    ${rnti_length}=    get length    ${rnti_list}
    should be true    ${rnti_length} == 1
    ${rnti}   set variable  ${rnti_list}[0]
    ${TTI_result}    create dictionary
    ${dl_tti_mcs_value_list}   get specified column from csv file for rnti   ${local_dl_csv}    dlFdSchedData.rrmDlProposedMcs
    ${dl_tti_buffer_value_list}  get specified column from csv file for rnti    ${local_dl_csv}    dlFdSchedData.rrmtotalDrbBufferedBytes
    ${dl_tti_rank_value_list}  get specified column from csv file for rnti   ${local_dl_csv}    dlFdSchedData.numOfLayers
    ${dl_tti_startPrb_value_list}  get specified column from csv file for rnti    ${local_dl_csv}    dlFdSchedData.startPrb
    ${dl_tti_numPrb_value_list}  get specified column from csv file for rnti    ${local_dl_csv}    dlFdSchedData.numOfPrb
    ${dl_tti_layer_value_list}     set_numoflayers_from_str_to_num    ${dl_tti_rank_value_list}[${rnti}][1:]
    ${TTI_result}      count Eligible UE and non Eligible UE     ${dl_tti_buffer_value_list}[${rnti}][1:]    ${dl_tti_mcs_value_list}[${rnti}][:-1]
    ...     ${dl_tti_layer_value_list}     ${dl_tti_startPrb_value_list}[${rnti}][1:]
    ...     ${dl_tti_numPrb_value_list}[${rnti}][1:]       ${Params2_value}
    [return]    ${TTI_result}

Check TTItrace value for low2high
    [Arguments]  ${TTI_result}
    should be true    ${TTI_result}[numprb][max] <= 256
    should be true    ${TTI_result}[numprb][min] > 0
    should be true    ${TTI_result}[startprb][min] == 0
    should be true    ${TTI_result}[slot_eligible]/${TTI_result}[slot_all] >0.95

Check TTItrace value for high2low
    [Arguments]  ${TTI_result}
    should be true    ${TTI_result}[numprb][max] <= 241
    should be true    ${TTI_result}[numprb][min] > 0
    should be true    ${TTI_result}[startprb][min] == 32
    should be true    ${TTI_result}[slot_eligible]/${TTI_result}[slot_all] >0.95

CU Full Commission Fix Error
    [Arguments]    ${path_of_commission_file}    ${gnb_index}=0
    [Documentation]   vCU commission
    log to console   \n*** Start vCU commission ***
    CU Login  ${gnb_index}
    vCU Load And Active SCF   ${path_of_commission_file}
    [Teardown]    run keyword and ignore error   CU Logout

vCU Load And Active SCF
    [Arguments]     ${path_of_commission_file}    ${wait_active}=${True}
    ${upload_operation_info}=   cu.upload_plan_file     ${path_of_commission_file}
    wait until keyword succeeds    60s   5s  CU Check Plan Upload Status Should Be As Expected
    ...    ${upload_operation_info["action_id"]}    success
    ${fix_err_operation}=   cu.fix_plan_validation_errors    ${upload_operation_info['plan_id']}
    ...   add_missing_objects=${True}   fix_mandatory_parameters=${True}
    sleep   60s
    ${validate_operaition_info}=  cu.plan_validation    ${upload_operation_info["plan_id"]}
    wait until keyword succeeds    60s   5s  CU Check Plan Validate Status Should Be As Expected
    ...    ${upload_operation_info["plan_id"]}   ${validate_operaition_info["action_id"]}    success
    ${activate_operaition_info}=  cu.plan_activation   ${upload_operation_info["plan_id"]}
    run keyword if    ${wait_active}==${True}    wait until keyword succeeds    600s   30s  CU Check Plan Activate Status Should Be As Expected
    ...    ${upload_operation_info["plan_id"]}  ${activate_operaition_info["id"]}    success

vDU Full Commission SCF Fix Error
    [Arguments]     ${path_of_commission_file}     ${vdu_index}=0
    [Documentation]   vCU commission
    log to console   \n*** Start vDU commission ***
    vDU Rest Login
    Check Maximum Plan Number And Delete One If Reach Maximum Number
    vDU Load And Active SCF   ${path_of_commission_file}
    [Teardown]    run keyword and ignore error   vDU Logout

vDU Load And Active SCF
    [Arguments]     ${path_of_commission_file}   ${retries}=1
    [Documentation]   load SCF and active SCF
    ${upload_plan_response}=  vdu.upload_plan    ${path_of_commission_file}
    Upload Plan Status Should Be Successful  operation_id=${upload_plan_response['action_id']}
    ${fix_err_response}=   vdu.fix_vdu_staged_plan_error    ${upload_plan_response['plan_id']}
    wait until keyword succeeds  30s  10s  Fix vDU SCF Validation Errors Should Be Successful
    ...    ${upload_plan_response['plan_id']}  ${fix_err_response['action_id']}
    ${temp_validation_id}   Validate Plan By REST  plan_id=${upload_plan_response['plan_id']}   retries=${retries}
    ${out}   Activate Staged Plan By REST   plan_id=${upload_plan_response['plan_id']}

Fix vDU SCF Validation Errors Should Be Successful
    [Arguments]  ${plan_id}  ${action_id}
    ${fix_err_response}=   vdu.get_fix_vdu_staged_plan_operation_status  ${plan_id}  ${action_id}
    should be equal as strings  ${fix_err_response['status']}  success
    log to console    Fix SCF Errors Success

X2 Link Should be UnLock
    [Arguments]    ${expected_value}=unlocked
    #AIC_BTS.CU Rest Login    gnb_index=${gnb_index}
    CU Login
    wait until keyword succeeds  300s  10s    Check X2 link Operation Should Be Successful    expected_value=${expected_value}
    [Teardown]    Run keyword and ignore error    CU Logout
