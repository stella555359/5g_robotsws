*** Settings ***
Documentation
...    author: tina.luo
...    contact:tina.luo@nokia-sbell.com
...    squad group: RAN_PZ_HAZ3_SG03
...    feature : CB006457

Library     taf.sbts.oam.coam.admin   WITH NAME    coam
Library    String
Library    Collections
Library     taf.analyzer.pcap     WITH NAME    cap

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Library     taf.hw.rf_attenuator    WITH NAME    att
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot


Variables   CB006457_scf_modify.py


*** Variables ***
${artifactory_hz1_key}    AKCp5ekHjrLLExc8Wa7MSZiKStNXNjfnyCmV5eAAk6m16dKiXWyLkrTkjd3UBCDXarokL5chh
${gNB_ip}                 ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${gNB_username}                 ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}                 ${tl.gnbs[0].cu.oam_http_connection_details.password}
${num_of_files}   20
${UE_TYPE}    ${tl.ues[-1].capabilities[1]}
${ui_version}    Mi12UI13.0.41
${scf_file_template_path}    ${commissionings_path}/HGZ/${testline_name}
${att_ipaddr}               ${tl.attenuator[0].ip_addr}
${att_port_number}         ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_port_1}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_port_2}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${att_port_3}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${att_port_4}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${att_port_5}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[4].port_no}
${att_port_6}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[5].port_no}
${att_port_7}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[6].port_no}
${att_port_8}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[7].port_no}
${att_port_9}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[8].port_no}
${att_port_10}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[9].port_no}
${att_port_11}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[10].port_no}
${att_port_12}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[11].port_no}
${att_api_port}             ${tl.attenuator[0].port}
${HBTE_max_value}           ${127}
${vendor}                   HBTE
${model}    PA-16-16-6-127-0.5-B-S
*** Keywords ***

SCF Commission to cell on air

    [Arguments]    ${scf_name}
    COAM Create log directory
	Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${scf_file_template_path}/${scf_name}   is_pdl_checking_needed=${False}    timeout=600s
   	Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=GNB_OAM
    Run Keyword And Ignore Error    ssh.force_reconnect    connection=ASIK Master
   [Teardown]    COAM Teardown gnb connections

Modify NIDD parameter on gnb
    [Arguments]    ${parameters_to_update}    ${gnb_index}=${0}    ${timeout}=${60}
    Connect to gnb coam via ssl   connection=GNB_OAM    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters_to_update}    timeout=${timeout}
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

UE Prepare
    Andriod UE adb reboot
    sleep    10s
    Log To Console    \n ### Prepare UE ###
	Run keyword if    '${UE_TYPE}'!='xiaomi'     power_ue.Prepare UE    ue_type=${UE_TYPE}
	Run keyword if    '${UE_TYPE}'=='xiaomi'     UE Prepare for xiaomi

UE Prepare for xiaomi
    Log To Console    \n ### Prepare UE ###
	power_ue.Prepare UE    ue_type=${UE_TYPE}  ui_version=${ui_version}

Attach UE
    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    log_type=Aasyslog
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=False

UE start traffic
    [Arguments]    ${tp_direction}=both    ${ul_tp}=100M    ${dl_tp}=100M
    ...           ${iperf_port_dl}=50227    ${iperf_port_ul}=43107
    log to console    UE start traffic
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'   power_ue.Start traffic    ue_index=${0}
    ...     direction=dl    throughput=${dl_tp}   duration=900000    ue_type=${ue_type}    buffer_size=1400B
    ...     iperf_port=${iperf_port_dl}
    sleep    3s
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Start traffic    ue_index=${0}
    ...    direction=ul    throughput=${ul_tp}    duration=900000    ue_type=${ue_type}    iperf_type=via_command
    ...    iperf_port=${iperf_port_ul}

UE capability check
    [Arguments]    ${ue_capability}=samsung
    Run keyword if    '${ue_capability}'=='samsung'    set test variable    ${UE_TYPE}    ${tl.ues[-1].capabilities[0]}
    ...      ELSE IF      '${ue_capability}'=='xiaomi'      set test variable    ${UE_TYPE}    ${tl.ues[-1].capabilities[1]}

Detach UE
    Log To Console    \n ### UE Detach ###
    Run Keyword And Ignore Error    UE stop traffic
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}

UE stop traffic
    [Arguments]    ${tp_direction}=both    ${iperf_port_dl}=50227    ${iperf_port_ul}=40137
    log to console    UE stop traffic
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'   power_ue.Stop traffic
	...    direction=dl    ue_index=${0}    ue_type=${UE_TYPE}    iperf_port=${iperf_port_dl}
    sleep    3s
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Stop traffic
	...    direction=ul    ue_index=${0}    ue_type=${UE_TYPE}    iperf_port=${iperf_port_ul}

Get Stream and SW full version for mcshark
    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
	set suite variable      ${Active_SW_version}
    ${stream}    get stream from version    ${Active_SW_version}
    set suite variable      ${stream}
	@{version_split}    String . Split String    ${Active_SW_version}    separator=_
	set suite variable      ${SW_VERSION_TOTAL}
	...   ${stream}_${version_split}[1]_${version_split}[2]_${version_split}[3]_${version_split}[4]
    [Return]       ${stream}

Download MCShark To UTE
    [Arguments]    ${sw_version}=${SW_VERSION_TOTAL}
	Run    sudo rm -rf ${EXECDIR}/artifactory/wslte5g_plugins-local/MCShark
	${ulr_mcshark}    set variable    https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/MCShark/${sw_version}/
    Run    wget -r -np -nH --header="Authorization: Bearer ${artifactory_hz1_key}" ${ulr_mcshark}
    ${MCShark}=    Run
    ...   ls ${EXECDIR}/artifactory/wslte5g_plugins-local/MCShark/${sw_version}/mcshark-4.4*bookworm.so
    ${version}=    Run    wireshark -v
    ${output}=    Get Regexp Matches    ${version}    Wireshark (...)    1
	Run    sudo rm /usr/lib/x86_64-linux-gnu/wireshark/plugins/${output[0]}/epan/*bookworm.so
    Run    sudo cp ${MCShark} /usr/lib/x86_64-linux-gnu/wireshark/plugins/${output[0]}/epan/


Get pcap during UE attach
    [Arguments]    ${log_path}    ${log_name}   ${connection}=GNB_OAM    ${gnb_index}=0

	ssh.Connect to
    ...    hostname=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}
    ...    alias=${connection}
    Start Tcpdump for CB006457    log_name=${log_name}   log_path=${log_path}
	Log to console     please attach UE
	Run Keyword And Continue On Failure    Attach UE
    Stop Tcpdump for CB006457
	ssh.download_file    remote_path=${log_path}/${log_name}
    ...                  local_path=${EXECDIR}/${log_name}
    ...                  connection=${connection}
	ssh.execute
    ...    command=rm -rf ${log_path}/${log_name}
    ...    connection=${connection}
	#Detach UE

Start Tcpdump for CB006457
    [Documentation]    Author: xxxx
    ...                Description: Start to collect log by tcpdump command
    [Arguments]    ${log_path}    ${log_name}    ${sudo}=${empty}    ${interface}=etha01.212    ${connection}=GNB_OAM
	...    ${protocol}=${empty}    ${filter}=${empty}
    ${cmd}=  set variable  ${sudo} tcpdump -i ${interface} ${protocol} -w ${log_path}/${log_name} > /dev/null 2>&1 ${filter}&
    ssh.Send Command    ${cmd}    connection=${connection}

Stop Tcpdump for CB006457
    [Documentation]    Author: Tang Jiayi
    ...                Description: Stop collecting log by tcpdump command
    [Arguments]    ${connection}=GNB_OAM
    ssh.execute
    ...    command=kill -2 `ps -ef | grep tcpdump | grep -v grep | grep -i etha01.212 | awk '{print $2}'`
    ...    connection=${connection}


Check the schedulWeight is as expected

     [Arguments]    ${local_pcap_file}=${EXECDIR}/${log_name}    ${field_name}=itf_l2_ps_DrbAddReqPs.schedulWeight
	 ...    ${display_filter}=sctp
      cap.Read Cap    cap_file=${local_pcap_file}    display_filter= ${display_filter}
      ${res_value}        cap.get_field_value_by_name    field_name=${field_name}
	  ${real_value}     convert to integer     ${res_value}[0]
 	 Should be equal    ${real_value}     ${expected_value}
