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
Library    taf.collectors.l1l2bip   WITH NAME  l1l2bip
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Library     taf.hw.rf_attenuator    WITH NAME    att
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Variables     CB010774_scf_parameters.py
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/sigspark_yiyuan_multiUE.py
Library     sigspark_yiyuan_multiUE.SigSparkMutiUE    WITH NAME    sparkMultiUE_yiyuan




*** Variables ***
${gNB_ip}                 ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${gNB_username}                 ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}                 ${tl.gnbs[0].cu.oam_http_connection_details.password}
${gnb_index}    0
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
${artifactory_hz1_key}    AKCp5ekHjrLLExc8Wa7MSZiKStNXNjfnyCmV5eAAk6m16dKiXWyLkrTkjd3UBCDXarokL5chh
*** Keywords ***

Test case prepare
    Get Stream and SW full version for mcshark
    Download MCShark To UTE

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

SCF Commission to cell on air
    [Arguments]    ${scf_name}
    COAM Create log directory
	Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${scf_file_template_path}/${scf_name}     timeout=600s
   	Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=GNB_OAM
    Run Keyword And Ignore Error    ssh.force_reconnect    connection=ASIK Master
   [Teardown]    COAM Teardown gnb connections

UE Prepare
    [Arguments]      ${ue_index}=${0}
    Log To Console    \n ### Prepare UE ${ue_index}###
	Run keyword if    '${UE_TYPE}'!='xiaomi'     power_ue.Prepare UE    ue_type=${UE_TYPE}    ue_index=${ue_index}
	Run keyword if    '${UE_TYPE}'=='xiaomi'     UE Prepare for xiaomi

UE Prepare for xiaomi
    Log To Console    \n ### Prepare UE ${ue_index}###
	power_ue.Prepare UE    ue_type=${UE_TYPE}  ui_version=${ui_version}

Attach UE
    [Arguments]      ${ue_index}=${0}
    Log To Console    \n ### UE Attach ${ue_index}###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}   ue_type=${UE_TYPE}    log_type=Aasyslog
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=False

UE start traffic
    [Arguments]    ${tp_direction}=both    ${ul_tp}=100M    ${dl_tp}=100M   ${appserver}=10.57.162.3
    ...           ${iperf_port_dl}=50227    ${iperf_port_ul}=43107
    log to console    UE start traffic
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'   power_ue.Start traffic    ue_index=${0}
    ...     direction=dl    throughput=${dl_tp}   duration=900000    ue_type=${ue_type}    buffer_size=1400B
    ...     appserver=${appserver}        iperf_port=${iperf_port_dl}
    sleep    3s
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Start traffic    ue_index=${0}
    ...    direction=ul    throughput=${ul_tp}    duration=900000    ue_type=${ue_type}    iperf_type=via_command
    ...    appserver=${appserver}        iperf_port=${iperf_port_ul}

UE capability check
    [Arguments]    ${ue_capability}=samsung
    Run keyword if    '${ue_capability}'=='samsung'    set test variable    ${UE_TYPE}    ${tl.ues[-1].capabilities[0]}
    ...      ELSE IF      '${ue_capability}'=='xiaomi'      set test variable    ${UE_TYPE}    ${tl.ues[-1].capabilities[1]}

Detach UE
    [Arguments]      ${ue_index}=${0}
    Log To Console    \n ### UE Detach ${ue_index} ###
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_index=${ue_index}    ue_type=${UE_TYPE}

Andriod UE adb disable mobile data services
    [Arguments]    ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc via cygwin    ue_index=${ue_index}
    csn.send_command     command=adb -s ${serial_number} shell svc data disable   connection=cygwin
    sleep    3s
    [Teardown]   csn.Disconnect   connection=cygwin

Make a VoNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}==${0}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82
    ...    connection=cygwin${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cygwin${ue_index}
    sleep   2s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:${phone_number}
    ...    connection=cygwin${ue_index}
    sleep    20s

Answer VoNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    wait until keyword succeeds   5m   30s
    ...    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 5    connection=cygwin${ue_index}
    sleep    5s
Modify NIDD parameter on gnb
    [Arguments]    ${parameters_to_update}    ${gnb_index}=${0}    ${timeout}=${60}
    Connect to gnb coam via ssl   connection=GNB_OAM    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters_to_update}    timeout=${timeout}
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Start L1-L2 BIP
    [Documentation]
    ...                :param target_file_name: (str) – name of collector
    ...                :param interface: (str) – L1-L2 or L2Hi-L2Lo
    ...                :param destination : (str) – Local or Remote
    ...                :param webservice: (dict) – Configuration of collector/host: base url IP/user: username, defaults to “Nemuadmin”
    ...                                            password: password, defaults to “nemuuser”/port: port, default 443
    ...                :param nr_phy_cell_ids: str) (nr_phy_cell_ids Union(list,) – (Optional) list of physical cell ids.
    ...                          If given ensure cell is on air before running the setup. If not given it will check nr_cell_dns
    ...                          like: 50,51, (Select max 8 cells), if nr_phy_cell_ids set as "None", means collect the logs of all cells.
    [Arguments]    ${target_dir}=${EXECDIR}
    ...            ${nr_phy_cell_ids}=487
    ...            ${gnb_index}=0
    ...            ${timeout}=600
    ...            ${interface}=L1-L2
    ...            ${destination}=Local
    ...            ${host_ip}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...            ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
	 Run   rm -rf ${target_dir}/${target_file_name}/*.pcap
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
	log to console    \n###Collect Interface Mirroring Bip Collector during Paging###
    core.Set Suite Alias     ${target_file_name}
Stop L1-L2 BIP
    [Arguments]  ${target_dir}=${EXECDIR}
    core.stop_collectors        names=${target_file_name}
    core.collect_collectors    names=${target_file_name}   target_dir=${target_dir}
    core.teardown_collectors    names=${target_file_name}

Get paging SFN and Slot from BIP log
    [Arguments]    ${pcap_file_path}=${EXECDIR}/l1l2bip_log/*.pcap
    ${all_packets}=    cap.Load Pcap File    pcap_file=${pcap_file_path}   alias=test
	${filter_expression}=    Catenate    nr-rrc.pagingRecordList == 1 && 3gpp.subcellid == ${subcell_id}

    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test

    ${paging_slot}=    cap.get_field_value_by_name    field_name=_3gpp.slot    attribute_name=show    pcap_parser=test
	${paging_sfn}=    cap.get_field_value_by_name    field_name=_3gpp.sfn    attribute_name=show    pcap_parser=test
    set test variable    ${paging_slot}
	set test variable    ${paging_sfn}