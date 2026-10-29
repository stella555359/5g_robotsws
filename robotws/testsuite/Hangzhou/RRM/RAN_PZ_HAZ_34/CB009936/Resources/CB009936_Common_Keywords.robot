*** Settings ***
Documentation    Author:jia-rebecca.liu@nokia-sbell.com


Library           Collections
Variables         ../Resources/CB009936_variables.py
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/dingli_multiUE.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/72e_switch.robot
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py     WITH NAME    nrdim
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/get_counters_from_pm_file.py    WITH NAME   get_counter
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/spark_multiUE.robot

*** Variables ***
####----PATH----####
${TS_LOG_PATH_BASE}                           /opt/workspace/CRT/Master/Case_Logs/
${tshark_path}                                /usr/bin/tshark
####----BTS----####
${CB009936_SCF_11006_SBTS25R2_ENB_9999}      MRBTS-11006_TL374_golden_SCF_trunk_CA.xml
${CB009936_SCF_11006_SBTS25R1_ENB_0000}      MRBTS-11006_TL374_golden_SCF_25R1_CA.xml
${CB009936_SCF_11006_SBTS25R2_ENB_0000}      MRBTS-11006_TL374_golden_SCF_25R2_CA.xml
${gnb_instance}                              ${tl.gnbs[0].instance_id}
${gnb_global_bts_id}                         ${tl.gnbs[0].global_bts_id}
${UEPC_host}                                 ${tl.ues[0].ssh_connection_details.addr}
${UEPC_username}                             ${tl.ues[0].ssh_connection_details.username}
${UEPC_password}                             ${tl.ues[0].ssh_connection_details.password}
${MRBTS1_ID}                                 ${tl.gnbs[0].instance_id}
${MRBTS2_ID}                                 ${tl.gnbs[1].instance_id}
####----UE----####
${ue_type_dingli}                            ${tl.ues[0].capabilities[1]}
${DL_PORT_dingli}                            ${tl.ues[0].iperf_details.port}
${ATI_Atcommand}                               ati
####----M80----####
${appserver_addr_mtk80}           ${tl.ues[8].iperf_details.ssh_connection_details.addr}
####----PA----####
${model}                          ${tl.attenuator[1].model}
${att_ipaddr_11006}               ${tl.attenuator[1].ip_addr}

${att_port_1_cell3_11006}         ${tl.attenuator[1].attenuator_ports[1]}
${att_port_2_cell3_11006}         ${tl.attenuator[1].attenuator_ports[2]}
${att_port_3_cell3_11006}         ${tl.attenuator[1].attenuator_ports[3]}
${att_port_4_cell3_11006}         ${tl.attenuator[1].attenuator_ports[4]}
${att_port_1_cell2_11006}         ${tl.attenuator[1].attenuator_ports[5]}
${att_port_2_cell2_11006}         ${tl.attenuator[1].attenuator_ports[6]}
${att_port_enb_cell1_11006}       ${tl.attenuator[1].attenuator_ports[7]}
*** Keywords ***
Common Suite Setup for 9936
    [Arguments]
    ...            ${asik_addr}=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...            ${asik_username}=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...            ${asik_password}=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...            ${scf_path}=/opt/workspace/SCF/
    ...            ${gnb_index}=${0}
    ...            ${cell_index}=${37401}
    Common Suite Setup for COAM
    Get gnb_release title for SCF     asik_addr=${asik_addr}
    ...                               asik_username=${asik_username}
    ...                               asik_password=${asik_password}
#    ${release_info_title}    Get sagnb release title
#    set suite variable    ${release_info_title}
    ${cell1_nrcellid}    NRCellid Set suit varaible    cellid=${2}    gnb_index=${0}
    ${cell2_nrcellid}    NRCellid Set suit varaible    cellid=${4}    gnb_index=${0}
#    ${cell3_nrcellid}    NRCellid Set suit varaible    cellid=${3}    gnb_index=${0}
    set suite variable    ${cell1_nrcellid}
    set suite variable    ${cell2_nrcellid}
#    set suite variable    ${cell3_nrcellid}
    ${physical_cellid}    Get physCellId from SCF     golden_scf_name=MRBTS-${MRBTS1_ID}_${gnb_release}.xml
    ...                                               gnb_index=${gnb_index}
    ...                                               cell_index=${cell_index}
    ...                                               scf_path=${scf_path}
    set suite variable    ${physical_cellid}
    Common Case TestLine Setup
    ...                            is_commission=True
    ...                            golden_scf_name=MRBTS-${MRBTS1_ID}_${gnb_release}.xml

Common Suite Teardown for 9936
    Common Suite Teardown for COAM


Get gnb_release title for SCF
    [Documentation]    the keyword return realse format : SBTS24R3_ENB_9999
    [Arguments]     ${asik_addr}     ${asik_username}     ${asik_password}
    csn.Connect To   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}   alias=release_info
    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
    ${gnb_release}     set variable    ${info.split('_')[1]}_${info.split('_')[2]}_${info.split('_')[3]}
    set suite variable    ${gnb_release}
    [Return]    ${gnb_release}
    [Teardown]   csn.Disconnect   connection=release_info

####---------------------------------------UE------------------------------------------####
Prepare pioneer_MultiUE
    [Arguments]    ${host}=${UEPC_host}    ${username}=${UEPC_username}
        ...    ${password}=${UEPC_password}    ${alias}=pioneer    ${ue_alias}=multiUE
        ...    ${until_timeout}=${300}    ${port}=30999    ${UE_mode}=5G_SA
        ...    ${timeout}=${600}
    [Documentation]    Prepare UE for L3 call test.
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for reserve
    client.setup_service     host=${host}
    ...                      port=${port}
    ...                      ssh_username=${username}
    ...                      ssh_password=${password}
    ...                      alias=${alias}
    ...                      timeout=${timeout}
    Run Keyword And Ignore Error    client.stoplog      service=${alias}
    Get imei_list from ue_infos    alias=${alias}
    ${ue_num}=    get length    ${imei_list}
    ${uegroup}    create list
    FOR    ${i}    IN RANGE     ${ue_num}
      client.require_ue    imei=${imei_list}[${i}]    service=${alias}    ue_alias=${ue_alias}${i}
      Append To List     ${uegroup}     ${ue_alias}${i}
    END
    Set Suite Variable    ${uegroup}
    FOR    ${m}    IN     @{uegroup}
        check_dingli_multiUE_status    ue_alias=${m}    until_timeout=${until_timeout}
    END
    ${ati_result}     client.sendat     command=${ATI_Atcommand}    until_timeout=${until_timeout}    ue=${uegroup}[0]
    ${ati_value}     Get Regexp Matches     ${ati_result}[Param][Back]      Revision: (.*?),OK    1
    Run Keyword If     'RG' in '${ati_value}[0]'
    ...     MAKE YiYuan_multiue set SA_NSA mode    UE_mode=${UE_mode}    until_timeout=${until_timeout}
    ...     ELSE IF     'FM' in '${ati_value}[0]'
    ...     MAKE GuangHeTong_multiue set SA_NSA mode    UE_mode=${UE_mode}    until_timeout=${until_timeout}
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    sleep    5s
    client.startlog    logpath=d:/pioneer_logs/${time_stamp}/    logname=ta_log    service=${alias}
    sleep    1s

Dingli_single_multiUE attach
    [Arguments]    ${ue_alias}=${uegroup}[0]    ${until_timeout}=${600}    ${apn}=weistatic
    client.poweron     ue=${ue_alias}    until_timeout=${until_timeout}
    sleep    5s    reason=wait for UE attach
    ${upd_info}    Run keyword and continue on failure    client.getpduinfo    until_timeout=${until_timeout}
    ...                                                                        apn=${apn}     ue=${ue_alias}
    should be true    ${upd_info}[Param][State] == 0
    [Return]     ${upd_info}

dingli_UE_attach_WA
    [Arguments]    ${ue_alias}=${uegroup}[0]    ${until_timeout}=${600}
    run keyword and ignore error    client.poweron     ue=${ue_alias}    until_timeout=${until_timeout}
    sleep    2s
    client.poweroff     ue=${ue_alias}    until_timeout=${until_timeout}


Dingli_multiUEs attach
    [Arguments]    ${ue_alias}=${uegroup}    ${until_timeout}=${600}
    client.poweron     ue=${ue_alias}    until_timeout=${until_timeout}

Dingli_single_multiUE detach
    [Arguments]    ${ue_alias}=${uegroup}[0]    ${until_timeout}=${600}
    client.poweroff     ue=${ue_alias}    until_timeout=${until_timeout}

Dingli_multiUEs detach
    [Arguments]    ${ue_alias}=${uegroup}    ${until_timeout}=${600}
    client.poweroff     ue=${ue_alias}    until_timeout=${until_timeout}


MAKE YiYuan_multiue set SA_NSA mode
    [Arguments]     ${UE_mode}    ${until_timeout}
    FOR     ${n}    IN    @{uegroup}
      YY MULTIUE NSA_SA MODE HO     UE_mode=${UE_mode}     until_timeout=${until_timeout}      ue=${n}
    END

MAKE GuangHeTong_multiue set SA_NSA mode
    [Arguments]     ${UE_mode}    ${until_timeout}
    FOR     ${n}    IN    @{uegroup}
      GHT MULTIUE NSA_SA MODE HO     UE_mode=${UE_mode}     until_timeout=${until_timeout}      ue=${n}
    END

Dingli_UE prepare
    [Arguments]    ${host}=${UEPC_host}    ${username}=${UEPC_username}
    ...            ${password}=${UEPC_password}    ${alias}=pioneer    ${ue_alias}=multiUE
    ...            ${until_timeout}=${300}    ${port}=30999    ${UE_mode}=5G_SA
    Prepare pioneer_MultiUE         host=${host}      username=${username}     password=${password}
    ...                             alias=${alias}    ue_alias=${ue_alias}     until_timeout=${until_timeout}
    ...                             port=${port}      UE_mode=${UE_mode}

check_dingli_multiUE_status
    [Arguments]    ${ue_alias}    ${until_timeout}=${600}
    ${status}    client.get_attach_status    ue=${ue_alias}    until_timeout=${until_timeout}
    Run Keyword If     '${status}[Param][AttachStatus]' == 'Attached'
    ...                client.poweroff     ue=${ue_alias}    until_timeout=${until_timeout}
    [Return]    ${status}

UE attach and capture wiresharklog
    [Arguments]    ${wiresharklog}    ${gNB_index}=${0}
    Start capture wireshark log on master     filename=${wiresharklog}    gNB_index=${gNB_index}
    ${upd_info}    Dingli_single_multiUE attach
    sleep    10s    reason= wait for UE attach complete.
    [Teardown]    Stop and download the wiresharklog from master    filename=${wiresharklog}    gNB_index=${gNB_index}
    [Return]     ${cpif_log_path}    ${upd_info}

attach_detach_multiues_around
    [Arguments]
    Prepare to caculate PM counter
    ${end_time}=    Evaluate    time.time() + 300    modules=time
    WHILE    time.time() < ${end_time}
      Perform Attach Detach
    END
    [Teardown]     run keyword and ignore error     Dingli_multiUEs detach


Perform Attach Detach
    [Arguments]      ${ATTACH_DETACH_INTERVAL}=5s
    Dingli_multiUEs attach
    sleep    ${ATTACH_DETACH_INTERVAL}
    Dingli_multiUEs detach
    sleep    ${ATTACH_DETACH_INTERVAL}


check_dingli_UE0_tput_aasyslog
    [Arguments]     ${expect_tput}     ${cellid}=${cell1_nrcellid}      ${duration}=2m
    ...     ${target_avg_percent}=0.98     ${min_percent}=0.85
    ${tput_value}=      Check one multiUE traffic with aasyslog    target_throughput=${expect_tput}    cellid=${cellid}
    ...      duration=${duration}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    [Return]    ${tput_value}


# =============================LOG Capture============================= #
Start capture wireshark log on master
    [Arguments]    ${filename}    ${gNB_index}=${0}    ${interface}=any
    wait until keyword succeeds    1min   10s    Connect gNB    gNB_index=${gNB_index}
    sleep    3s
    csn.send command    command=tcpdump -i ${interface} -p sctp -w ${gnb_path}${filename}    connection=gNB${gNB_index}
	sleep    3s
    [Teardown]    csn.disconnect    connection=gNB${gNB_index}

Stop and download the wiresharklog from master
    [Arguments]    ${filename}    ${gNB_index}=${0}
    wait until keyword succeeds    1min   10s    Connect gNB    gNB_index=${gNB_index}
    csn.send command    command=killall tcpdump     connection=gNB${gNB_index}
    sleep    3
    csn.download_file   remote_path=${gnb_path}${filename}   local_path=${epc_log_path}${filename}   connection=gNB${gNB_index}
    sleep    3
    set suite variable     ${cpif_log_path}      ${epc_log_path}${filename}
    [Teardown]    csn.disconnect    connection=gNB${gNB_index}
    [Return]     ${cpif_log_path}




####-----------------------------------------------counter--------------------------------------------------------------####
Get_KPI_value_by_list
    [Arguments]
    ...            ${ip}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...            ${username}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}
    ...            ${gnb_index}=${0}
    ...            ${kpi_file}=${CURDIR}/KPI_Formula_CB009936.txt
#    ...            ${folder_name}=CB009936_B12
#    ${xml_folder_file_list}    get_counter.get_pm_file_from_classical_by_time    ip=${ip}
    ${xml_folder_file_list}    get_counter.get_newest_pm_xml_file                ip=${ip}
    ...                                                                          username=${username}
    ...                                                                          password=${password}
    ...                                                                          connection=gNB_${gnb_index}
    ...                                                                          local_path=${epc_log_path}

#    ${counter_value_dict}    getsum_counter_by_pm_file
#    ...     kpi_file=${kpi_file}    xml_folder_file_list=${xml_folder_file_list}    para_index=${cellindex}
#    ${kpi_value_dict}    calculate_kpi_by_counter    counter_dic_by_name=${counter_value_dict}    kpi_file=${kpi_file}
    ${kpi_value_dict}    get_counter.calculate_dict_kpis_from_pm_file     pm_xml_file=${xml_folder_file_list}
    ...                                                                   kpi_file=${kpi_file}
    ...                                                                   para_index=${1}
    [Return]    ${kpi_value_dict}

#########-----------------MTK80-----------------#########
Prepare UE For MTK80
    [Documentation]   jia-rebecca.liu@nokia-sbell.com
    ...               Description: Precondtion for mtk ue
    [Arguments]    ${ue_index}=${8}    ${cap_index}=${0}    ${cpc_alias}=cpc_${ue_index}
    ${mtk_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    set suite variable    ${mtk_type}
    CB009936_Common_Keywords.Get UE Airmode status and Turnoff Airplane Mode    ue_index=${ue_index}
    CB009936_Common_Keywords.Enable Mobile Data    ue_index=${ue_index}
    ${mtk_prepare}      run keyword and return status     Wait Until Keyword Succeeds    3 times    5 sec
    ...                 Precondition for MTK ue attach    ue_index=${ue_index}    cap_index=${cap_index}
    ...                 cpc_alias=${cpc_alias}
    Run Keyword If    ${mtk_prepare}==${False}    UE Reboot with adb command    ue_index=${ue_index}
    sleep    60s
    ${mtk_prepare_1}    Run Keyword If    ${mtk_prepare}==${False}       run keyword and return status
    ...                 Wait Until Keyword Succeeds    3 times    5 sec
    ...                 Precondition for MTK ue attach    ue_index=${ue_index}    cap_index=${cap_index}
    ...                 cpc_alias=${cpc_alias}
    Run Keyword If    ${mtk_prepare_1}==${False}      Reset UE Control PC    ue_index=${ue_index}
    sleep    60s
    Run Keyword If    ${mtk_prepare_1}==${False}    Wait Until Keyword Succeeds    3 times    5 sec
    ...               Precondition for MTK ue attach     ue_index=${ue_index}    cap_index=${cap_index}
    ...               cpc_alias=${cpc_alias}

MTK80 Attach and Verify
    [Documentation]    jia-rebecca.liu@nokia-sbell.com
    ...                Description: Attach MTK80 and verify
    [Arguments]        ${ue_index}=${8}
    ...                ${UE_alias}=UE_${ue_index}
    ute_ue.Register    ${UE_alias}
#    power_ue.Verify attach    ue_type=${mtk_type}    ue_index=${ue_index}    4G_check=${4G_check}

Attach UE and Capture wireshark for MTK80
    [Documentation]    qingqing.zhang@nokia-sbell.com
    ...                Description: Attach UE and capture wireshark for MTK80
    [Arguments]    ${logname}     ${ue_index}=${8}    ${gNB_index}=${0}
    Start capture gNB log on master    filename=${logname}   gNB_index=${gNB_index}
    MTK80 Attach and Verify    ue_index=${ue_index}
    sleep    5s
    [Teardown]    Stop and download the Logs    filename=${logname}    gNB_index=${gNB_index}

MTK UE attach and capture wiresharklog
    [Arguments]    ${wiresharklog}    ${ue_index}=${8}
    Start capture wireshark log on master     filename=${wiresharklog}    gNB_index=${gNB_index}
    MTK80 Attach and Verify    ue_index=${ue_index}
    sleep    5s
    [Teardown]    Stop and download the wiresharklog from master    filename=${wiresharklog}    gNB_index=${gNB_index}
    [Return]     ${cpif_log_path}


Start DL traffic for MTK80
    [Documentation]    jia-rebecca.liu@nokia-sbell.com
    ...                Description: Start DL traffic
    [Arguments]    ${get_ip_from_wireshark}
    ...            ${dl_data_transfer}=5M
    ...            ${duration}=6000
    ...            ${ue_index}=${8}
    ...            ${buffer_size}=1400B
    ...            ${appserver}=APPserver
    ...            ${protocol}=udp
    ${UE_IP}     Get UE IP from wirehsark     logname=${get_ip_from_wireshark}
    ${ue_dl_port}    Set Variable    ${tl.ues[${ue_index}].iperf_details.port}
    Set Test Variable    ${DL_PORT}    ${ue_dl_port}
    traffic_via_iperf.Start DL traffic via iperf on Appserver    ue_addr=${UE_IP}
    ...                                                          dl_time=${duration}
    ...                                                          dl_port=${DL_PORT}
    ...                                                          dl_throughput=${dl_data_transfer}
    ...                                                          dl_length=${buffer_size}
    ...                                                          appserver=${appserver}
    ...                                                          protocol=${protocol}
    ...                                                          ue_index=${ue_index}

Start UL traffic via iperf for MTK80
    [Arguments]    ${ue_index}=${8}
    ...    ${ul_time}=6000
    ...    ${ul_throughput}=2M
    ...    ${ul_length}=1400B
    ...    ${appserver}=APPserver
    ...    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${protocol}=udp     ${process_num}=${5}    ${iperf_index}=${2}
    ...    ${cpc_ip}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    ${cpc_usrname}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    ${cpc_passwd}=${tl.ues[${ue_index}].ssh_connection_details.password}
    ...    ${window}=2M
    ...    ${iperf_path}=/data/local/tmp/iperf
    ...    ${appserver_addr}=${appserver_addr_mtk80}
    ${ue_ul_port}    Set Variable    ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    Set Test Variable    ${UL_PORT}    ${ue_ul_port}
    Close the iperf process on android ue    ue_index=${ue_index}    iperf_port=${UL_PORT}    serial_number=${serial_number}
    ...                                      iperf_index=${iperf_index}
    ...                                      cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}
    Connect to control pc enhanced    ue_index=${ue_index}    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}
    ${cmd_ul_traffic}=    run keyword if    '${appserver}'=='APPserver'       catenate    adb -s ${serial_number} shell
    ...     ${iperf_path} -c ${appserver_addr} -u -t ${ul_time} -i 1 -p ${UL_PORT} -P 1 -f m -b ${ul_throughput} -l ${ul_length} -T 64 &
    ...    ELSE IF    '${appserver}'=='APPserversim'     catenate    adb -s ${serial_number} shell
    ...  ${iperf_path} -c ${appserversim_addr} -u -t ${ul_time} -i 1 -p ${UL_PORT} -P ${process_num} -f m -b ${ul_throughput} -l ${ul_length} -T 64 &
    run keyword if    '${protocol}'=='udp'    csn.send_command    command=${cmd_ul_traffic}    connection=cpc_${ue_index}
    ...    ELSE IF    '${protocol}'=='tcp'    Start the tcp UL data via iperf    appserver=${appserver}
    ...    serial_number=${serial_number}    ul_time=${ul_time}    ul_port=${UL_PORT}    ue_index=${ue_index}
    ...    process_num=${process_num}    window=${window}
    sleep    3s
    Check the iperf progress exist    connection=cpc_${ue_index}    port=${UL_PORT}    ue_sn=${serial_number}   iperf_index=${iperf_index}
    [Teardown]    csn.disconnect    connection=cpc_${ue_index}

Start DLUL traffic and check throughput for MTK80
    [Arguments]    ${logname}=NULL    ${scellid}=2   ${pcellid}=1
    ...    ${tput_dl_pcell}=${expected_tput_dl_F}    ${tput_dl_scell}=${expected_tput_dl_T}
    ...    ${tput_ul_pcell}=${expected_tput_ul_F}    ${tput_ul_scell}=${expected_tput_ul_T}    ${duration}=30s
    ...    ${dl_throughput}=${Send_Tput_DL}    ${ul_throughput}=${Send_Tput_UL}    ${ue_index}=${8}
    Start DL and UL traffic for MTK80    get_ip_from_wireshark=${logname}    dl_data_transfer=${dl_throughput}
    ...    ul_throughput=${ul_throughput}    ue_index=${ue_index}
    Check 2CC DLUL tput    scellid=${scellid}    pcellid=${pcellid}    tput_dl_pcell=${tput_dl_pcell}
    ...    tput_dl_scell=${tput_dl_scell}    tput_ul_pcell=${tput_ul_pcell}    tput_ul_scell=${tput_ul_scell}
    ...    duration=${duration}

Start DL and UL traffic for MTK80
    [Documentation]    jia-rebecca.liu@nokia-sbell.com
    ...                Description: Start DL and UL traffic for MTK80
    [Arguments]        ${get_ip_from_wireshark}
    ...                ${dl_data_transfer}=5M
    ...                ${duration}=6000
    ...                ${ue_index}=${8}
    ...                ${ul_throughput}=2M
    ...                ${iperf_path}=/data/local/tmp/iperf
    ...                ${appserver_addr}=${appserver_addr_mtk80}
    Start DL traffic for MTK80       get_ip_from_wireshark=${get_ip_from_wireshark}
    ...                              dl_data_transfer=${dl_data_transfer}
    ...                              duration=${duration}
    ...                              ue_index=${ue_index}
    Start UL traffic via iperf for MTK80    ue_index=${ue_index}
    ...                                     ul_time=${duration}
    ...                                     ul_throughput=${ul_throughput}
    ...                                     iperf_path=${iperf_path}
    ...                                     appserver_addr=${appserver_addr}

Check 2CC DLUL tput
    [Arguments]    ${tput_dl_pcell}=NULL    ${tput_dl_scell}=NULL
    ...    ${tput_ul_pcell}=NULL    ${tput_ul_scell}=NULL
    ...    ${scellid}=16   ${pcellid}=4    ${gnb_index}=${0}    ${ue_type}=${mtk_type}    ${duration}=30s
    ${nrcellid_pcell}    COAM Get nrcellid with lcrid    lcrid=${pcellid}    gnb_index=${gnb_index}
    ${nrcellid_scell}    COAM Get nrcellid with lcrid    lcrid=${scellid}    gnb_index=${gnb_index}
    ${nrcellid_pcell}    Create list  ${nrcellid_pcell}
    ${nrcellid_scell}    Create list  ${nrcellid_scell}
    ${tput_log}    power_ue.Collect Tput    duration=${duration}   ignore_time=0s    ue_type=${ue_type}    gnb_index=${gnb_index}
    Run keyword If    '${tput_dl_pcell}'!='NULL'
    ...    power_ue.Check Tput    direction=DL    cells=${nrcellid_pcell}    log=${tput_log}    ue_type=${ue_type}
    ...    target_throughput=${tput_dl_pcell}
    Run keyword If    '${tput_dl_scell}'!='NULL'
    ...    power_ue.Check Tput    direction=DL    cells=${nrcellid_scell}    log=${tput_log}    ue_type=${ue_type}
    ...    target_throughput=${tput_dl_scell}
    Run keyword If    '${tput_ul_pcell}'!='NULL'
    ...    power_ue.Check Tput    direction=UL    cells=${nrcellid_pcell}    log=${tput_log}   ue_type=${ue_type}
    ...    target_throughput=${tput_ul_pcell}
    Run keyword If    '${tput_ul_scell}'!='NULL'
    ...    power_ue.Check Tput    direction=UL    cells=${nrcellid_scell}    log=${tput_log}   ue_type=${ue_type}
    ...    target_throughput=${tput_ul_scell}

Stop DLUL traffic and detech for MTK80
    [Documentation]    jia-rebecca.liu@nokia-sbell.com
    ...                Description: stop DL and UL traffic for MTK80, keep attach status
    [Arguments]    ${ue_index}=${8}    ${Stop_DL}=True    ${Stop_UL}=True
    Run keyword If    ${Stop_DL}   Stop DL traffic only     ue_index=${ue_index}
    Run keyword If    ${Stop_UL}    Stop UL traffic only     ue_index=${ue_index}
    [Teardown]    Detach MTK80    ue_index=${ue_index}

Stop UL traffic only
    [Documentation]    jia-rebecca.liu@nokia-sbell.com
    ...                Description: only stop UL traffic for MTK80, keep attach status
    [Arguments]    ${ue_index}=${8}
    Close the iperf process on android ue    ue_index=${ue_index}    iperf_port=${UL_PORT}

Stop DL traffic only
    [Documentation]    jia-rebecca.liu@nokia-sbell.com
    ...                Description: only stop DL traffic for MTK80, keep attach status
    [Arguments]      ${ue_index}=${8}
    ${ue_dl_port}    Set Variable    ${tl.ues[${ue_index}].iperf_details.port}
    Set Test Variable    ${DL_PORT}    ${ue_dl_port}
    Close the iperf process on APPserver    port=${DL_PORT}

Get UE Airmode status and Turnoff Airplane Mode
    [Documentation]  jia-rebecca.liu@nokia-sbell.com
    ...              Description: get ue airplane mode and turn off airplane mode for MTK UE
    [Arguments]    ${ue_index}=${8}
    Check UE device exist    ${ue_index}
    ${airplane_mode}    Get UE Airmode status    ue_index=${ue_index}
    run keyword if    '${airplane_mode}'=='1'    CB009936_common_keywords.Turn Off Airplane Mode    ue_index=${ue_index}
    [Teardown]    Run keyword and ignore error    csn.disconnect    connection=cpc_${ue_index}

Turn Off Airplane Mode
    [Documentation]  jia-rebecca.liu@nokia-sbell.com
    ...              Description: turn off airplane mode for MTK UE
    [Arguments]    ${ue_index}=${8}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.Send Command    adb -s ${serial_number} shell "su 0 settings put global airplane_mode_on 0"
    ...                 connection=cpc_${ue_index}
    ...                 timeout=5
    sleep    3s
    csn.send command    adb -s ${serial_number} shell "su 0 am broadcast -a android.intent.action.AIRPLANE_MODE"
    ...                 connection=cpc_${ue_index}
    ...                 timeout=5
    sleep    5s
    ${result} =    csn.read_output    connection=cpc_${ue_index}
    Should contain    ${result}    result=0
    [Teardown]    Run keyword and ignore error    csn.disconnect    connection=cpc_${ue_index}

Enable Mobile Data
    [Documentation]  jia-rebecca.liu@nokia-sbell.com
    ...              Description: enable mobile data for MTK UE
    [Arguments]    ${ue_index}=${8}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.send_command   command=adb -s ${serial_number} shell svc data enable    connection=cpc_${ue_index}
    Sleep    1s
    [Teardown]    Run keyword and ignore error    csn.disconnect    connection=cpc_${ue_index}

Detach MTK80
    [Documentation]   jia-rebecca.liu@nokia-sbell.com
    ...               Description: detach MTK80
    [Arguments]    ${ue_index}=${8}    ${UE_alias}=UE_${ue_index}
    MTK_common_keywords.Ue detach    UE_alias=${UE_alias}

Check ul_dl_tput for MTK80 and return
    [Documentation]    jia-rebecca.liu@nokia-sbell.com
    ...                Description: Check ul and dl traffic for MTK80
    [Arguments]
    ...             ${cellid}=${cell1_nrcellid}
    ...             ${duration}=180
    ...             ${mtk_type}=${mtk_type}
    ...             ${dl_target_throughput}=1000
    ...             ${ul_target_throughput}=100
    ${list_of_cell_ids}    Create list    ${cellid}
    ${tput_file}    power_ue.Collect Tput    ue_type=${mtk_type}     duration=${duration}
    ${dl_output}    power_ue.Check Tput    ue_type=${mtk_type}    direction=DL    cells=${list_of_cell_ids}
    ...                                 target_throughput=${dl_target_throughput}    log=${tput_file}
    Set Test Variable     ${dl_tput_avrage}     ${dl_output}[0][average]
    ${ul_output}    power_ue.Check Tput    ue_type=${mtk_type}    direction=UL    cells=${list_of_cell_ids}
    ...                                 target_throughput=${ul_target_throughput}    log=${tput_file}
    Set Test Variable     ${ul_tput_avrage}     ${ul_output}[0][average]
    [Return]    ${dl_tput_avrage}    ${ul_tput_avrage}

Check ul_dl_tput for dingli_UE and return
    [Documentation]    jia-rebecca.liu@nokia-sbell.com
    ...                Description: Check ul and dl traffic for dingliUE
    [Arguments]
    ...             ${cellid}=${cell1_nrcellid}
    ...             ${duration}=180
    ...             ${dl_target_throughput}=1000
    ...             ${ul_target_throughput}=100
    ${dl_output}    Check one multiUE traffic with aasyslog    target_throughput=${dl_target_throughput}    cellid=${cellid}    duration=${duration}
    ...                                                        direction=DL
    Set Test Variable     ${dl_tput_avrage}     ${dl_output}[0][average]
    ${ul_output}    Check one multiUE traffic with aasyslog    target_throughput=${ul_target_throughput}    cellid=${cellid}    duration=${duration}
    ...                                                        direction=UL
    Set Test Variable     ${ul_tput_avrage}     ${ul_output}[0][average]
    [Return]    ${dl_tput_avrage}    ${ul_tput_avrage}


Make Vonr Call With Command
    [Arguments]    ${ue_index}=${0}
    ...            ${phone_number}=+6688
    ...            ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...            ${cpc_ip}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...            ${cpc_usrname}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...            ${cpc_passwd}=${tl.ues[${ue_index}].ssh_connection_details.password}
    Connect to control pc enhanced    ue_index=${ue_index}    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:${phone_number}
    ...    connection=cpc_${ue_index}
    [Teardown]    csn.disconnect    connection=cpc_${ue_index}

Hang Up Vonr Call With Command
    [Arguments]    ${ue_index}=${0}
    ...            ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...            ${sleep_time}=5sec
    ...            ${cpc_ip}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...            ${cpc_usrname}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...            ${cpc_passwd}=${tl.ues[${ue_index}].ssh_connection_details.password}
    Connect to control pc enhanced    ue_index=${ue_index}    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}
    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_ENDCALL    connection=cpc_${ue_index}
    Sleep    ${sleep_time}
    [Teardown]    csn.disconnect    connection=cpc_${ue_index}

########-------------------MCS&&PA-----------------#########

MCS SETUP AND SET ATT for dingli_UE
    [Arguments]    ${gnb_cell1_PA_value_dingli_UE0}=${90}    ${gnb_cell1_PA_value_dingli_UE1}=${90}
    ...     ${horizontal_1}=${5}    ${horizontal_2}=${15}    ${horizontal_3}=${-5}    ${horizontal_4}=${-15}
    ...     ${is_need_recover}=False
    ${mcs_type}=    mcs_common.Get MCS Type
    set suite variable      ${mcs_type}
    Run keyword if    '${mcs_type}'=='hbte'    HBTE MCS SETUP Phases AND SET ATT for multiUES    mcs_type=${mcs_type}
    ...    att_value1=${gnb_cell1_PA_value_dingli_UE0}    att_value2=${gnb_cell1_PA_value_dingli_UE0}
    ...    att_value3=${gnb_cell1_PA_value_dingli_UE1}    att_value4=${gnb_cell1_PA_value_dingli_UE1}
    ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${horizontal_1}
    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${horizontal_2}
    ...    third_beam_begin_output_port=${5}     third_beam_end_output_port=${6}     third_beam_horizontal_angle=${horizontal_3}
    ...    fourth_beam_begin_output_port=${7}    fourth_beam_end_output_port=${8}    fourth_beam_horizontal_angle=${horizontal_4}
    ...     is_need_recover=${is_need_recover}
    Run keyword if    '${mcs_type}'=='haojin'
    ...    HAOJIN MCS SETUP AND SET ATT for Two UEs with different ATT    mcs_type=${mcs_type}
    ...    att_value_UE0_1=${gnb_cell1_PA_value_dingli_UE0}    att_value_UE0_2=${gnb_cell1_PA_value_dingli_UE0}
    ...    att_value_UE1_1=${gnb_cell1_PA_value_dingli_UE1}    att_value_UE1_2=${gnb_cell1_PA_value_dingli_UE1}
    ...    P1_out=${13}    P2_out=${14}    vertical_1=${96}    horizontal_1=${horizontal_1}
    ...    P3_out=${15}    P4_out=${16}    vertical_2=${96}    horizontal_2=${horizontal_2}
    ...    P5_out=${9}     P6_out=${10}    vertical_3=${96}    horizontal_3=${horizontal_3}
    ...    P7_out=${11}    P8_out=${12}    vertical_4=${96}    horizontal_4=${horizontal_4}
    [Teardown]    mcs_common.Teardown MCS    mcs_type=${mcs_type}


MCS SETUP AND SET ATT for MTK80
    [Arguments]    ${gnb_cell1_PA_value_MTK80}=${90}
    ...     ${vertical}=${96}    ${horizontal_1}=${10}    ${horizontal_2}=${20}
    ${mcs_type}=    mcs_common.Get MCS Type
    set suite variable      ${mcs_type}
    Run keyword if    '${mcs_type}'=='hbte'      HBTE MCS SETUP Phases AND SET ATT    mcs_type=${mcs_type}
    ...    vertical_distance=${2.0}   horizontal_distance=${0.5}
    ...    att_value1=${gnb_cell1_PA_value_MTK80}    att_value2=${gnb_cell1_PA_value_MTK80}    vertical_angle=${vertical}
    ...    first_beam_begin_output_port=${9}     first_beam_end_output_port=${10}     first_beam_horizontal_angle=${horizontal_1}
    ...    second_beam_begin_output_port=${11}    second_beam_end_output_port=${12}    second_beam_horizontal_angle=${horizontal_2}
    [Teardown]    mcs_common.Teardown MCS    mcs_type=${mcs_type}

Adjust the HBTE attenuation value for MTK80
    [Arguments]     ${tl}=${gnb_instance}     ${gnb_cell2_value}=${127}    ${gnb_cell3_value}=${127}     ${enb_cell1_value}=${127}

    ####create cell list#####
    @{att_ports_gnb_cell2}    Create List    ${att_port_1_cell2_${tl}}     ${att_port_2_cell2_${tl}}
    @{att_ports_gnb_cell3}    Create List    ${att_port_1_cell3_${tl}}     ${att_port_2_cell3_${tl}}
    ...                                      ${att_port_3_cell3_${tl}}     ${att_port_4_cell3_${tl}}

    ####create cell list#####
    @{att_ports_enb_cell1}    Create List    ${att_port_enb_cell1_${tl}}

    ###create value list####
    @{values_gnb_cell2}    Create List    ${gnb_cell2_value}    ${gnb_cell2_value}
    @{values_gnb_cell3}    Create List    ${gnb_cell3_value}    ${gnb_cell3_value}    ${gnb_cell3_value}    ${gnb_cell3_value}

    ###create value list####
    @{values_enb_cell1}    Create List    ${enb_cell1_value}

    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_gnb_cell2}    values=${values_gnb_cell2}
    ...    att_connection_port=${att_port_1_cell3_${tl}}    att_ipaddr=${att_ipaddr_${tl}}
    Set the attenuation value    att_ports=${att_ports_gnb_cell3}    values=${values_gnb_cell3}
    ...    att_connection_port=${att_port_1_cell3_${tl}}    att_ipaddr=${att_ipaddr_${tl}}
    Set the attenuation value    att_ports=${att_ports_enb_cell1}    values=${values_enb_cell1}
    ...    att_connection_port=${att_port_1_cell3_${tl}}    att_ipaddr=${att_ipaddr_${tl}}



#########-----------------wireshark check-----------------#########
Convert cpif_pcap log To Pdml
    [Documentation]    Description: convert to cpif pcap to pdml format, pdml can be used for value check.
    [Arguments]    ${file_path}
    ...            ${filter}=nr-rrc
    ...            ${command_template}={tshark_path} -r {file_path} -Y \"${filter}\" -T pdml
    ...            ${alias}=parser
    cap.load_pcap_file    pcap_file=${file_path}    command_template=${command_template}    alias=${alias}

Get Field Value From Pdml_file
    [Documentation]    Description: get field value from pdml file.
    [Arguments]    ${filter_expression}    ${xpath}    ${attribute_name}=show    ${alias}=parser
    cap.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=${alias}
    ${field_value}=    cap.get_field_value_by_xpath    xpath=${xpath}    attribute_name=${attribute_name}    pcap_parser=${alias}
    [Return]    ${field_value}

Check Target Item Value on cpif_Tcpdump log
    [Documentation]       Description:check target item value on CPIF tcpdump log.
    [Arguments]    ${file_path}
    ...            ${filter_expression}
    ...            ${xpath}
    ...            ${filter}=f1ap||nr-rrc||ngap
    ...            ${command_template}={tshark_path} -r {pcap_file} -Y \"${filter}\" -T pdml
    ...            ${attribute_name}=show
    Convert cpif_pcap log To Pdml    file_path=${file_path}
    ...                              filter=${filter}
    ...                              command_template=${command_template}
    ${filter_output}    Get Field Value From Pdml_file    filter_expression=${filter_expression}
    ...                                              xpath=${xpath}
    ...                                              attribute_name=${attribute_name}
    [Return]    ${filter_output}

Check wireshark log
    [Arguments]    ${logname}    ${message_filter}    ${xpath}    ${attribute_name}=show    ${epc_log_path}=${epc_log_path}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    alias=test6
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${filtered_result}=     cap.get_field_value_by_xpath    attribute_name=${attribute_name}    xpath=${xpath}    pcap_parser=test6
    [Return]    ${filtered_result}

Check wireshark log for 2CC
    [Arguments]    ${logname}    ${scell_index}=${2}    ${pcell_index}=${1}    ${scell_gnb_index}=${0}
    ...    ${message_filter}=f1ap.procedureCode ==7 and nr-rrc.sCellToAddModList == 1
    ...    ${xpath_filter}=.//nr-rrc.physCellId
    ${scell_list}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath_filter}
    ${pci_cclist}    Create List
    ${pcell_PCI}=    get required cell info   required_info=physicalCellId
    ...    cell_index=${pcell_index}   gnb_index=${scell_gnb_index}
    ${pcell_PCI}=    Convert To String    ${pcell_PCI}
    ${scell_PCI}=    get required cell info   required_info=physicalCellId
    ...    cell_index=${scell_index}   gnb_index=${scell_gnb_index}
    ${scell_PCI}=    Convert To String    ${scell_PCI}
    Append to list    ${pci_cclist}    ${pcell_PCI}    ${scell_PCI}
    List should Contain Sub List    ${scell_list}    ${pci_cclist}

Get UE IP from wirehsark
    [Arguments]    ${logname}    ${apn}=wap1.nokia.com
    ...    ${message_filter}=nas-5gs.cmn.dnn == "${apn}" and nas-5gs.sm.5qi == 7
    ...    ${xpath}=.//nas-5gs.sm.pdu_addr_inf_ipv4
    Log    Get UE IP from wirehsark
    ${UE_IP}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    [Return]    ${UE_IP}[-1]

check dldmrsconfigtype from biplog
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}     ${physical_cellid}=${physical_cellid}    ${dmrs_config_value}=DMRS_CONFIG_2
    ${dlDmrsConfigType_pre}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter=dldata_pdschsendreql1sw and 3gpp.rnti != 65535
    ...            filter_expression=DlData_PdschGrantL1sw.pdschScramblingSeqInit == ${physical_cellid}
    ...            xpath=.//DlData_PdschGrantL1sw.dlDmrsConfigType
    ...            attribute_name=showname
    ${dlDmrsConfigType_pre}    Remove Duplicates     ${dlDmrsConfigType_pre}
    ${dlDmrsConfigType_pre_num}    get length    ${dlDmrsConfigType_pre}
    should be equal     ${dlDmrsConfigType_pre_num}    ${1}
    ${dlDmrsConfigType}     String.Split String     ${dlDmrsConfigType_pre}[0]    ${SPACE}
    should contain     ${dlDmrsConfigType}[2]    ${dmrs_config_value}


check dmrs_supported from wireshark
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}
    ${supportedDMRS_TypeDL_pre}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter=nr-rrc
    ...            filter_expression=nr-rrc.UE_NR_Capability_element
    ...            xpath=.//nr-rrc.supportedDMRS_TypeDL
    ...            attribute_name=showname
    ${supportedDMRS_TypeUL_pre}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter=nr-rrc
    ...            filter_expression=nr-rrc.UE_NR_Capability_element
    ...            xpath=.//nr-rrc.supportedDMRS_TypeUL
    ...            attribute_name=showname
    ${supportedDMRS_TypeDL}     String.Split String     ${supportedDMRS_TypeDL_pre}[0]    ${SPACE}
    ${supportedDMRS_TypeUL}     String.Split String     ${supportedDMRS_TypeUL_pre}[0]    ${SPACE}
    should be true    '${supportedDMRS_TypeDL}[1]' == 'type1And2' and '${supportedDMRS_TypeUL}[1]' == 'type1And2'

check dmrs_type from wireshark
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}
    ${dmrs_type_pre}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter=nr-rrc
    ...            filter_expression=nr-rrc.dmrs_DownlinkForPDSCH_MappingTypeA
    ...            xpath=.//nr-rrc.dmrs_Type
    ...            attribute_name=showname
    ${dmrs_type}     String.Split String     ${dmrs_type_pre}[0]    ${SPACE}
    should be true    '${dmrs_type}[1]' == 'type2'

Check VONR setup from wireshark log
    [Arguments]    ${file_path}
    ####VONR setup
    Log To Console    check VONR setup
    ${vonr_setup}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter=ngap
    ...            filter_expression=ngap.procedureCode == 26 and ngap.fiveQI == 1
    ...            xpath=.//ngap.fiveQI
    should be equal    ${vonr_setup[0]}    1
    ####VONR PDU modify complete
    Log To Console    check VONR modify complete
    ${vonr_modify}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter=ngap||f1ap
    ...            filter_expression=ngap.procedureCode == 46 and nas-5gs.sm.message_type == 0xcc
    ...            xpath=.//nas-5gs.sm.message_type
    should be equal    ${vonr_modify[-1]}    0xcc

Check VONR hangup from wireshark log
    [Arguments]    ${file_path}
    Log To Console    check VONR hangup
    ${vonr_hangup}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter=ngap
    ...            filter_expression=ngap.procedureCode == 26
    ...            xpath=.//ngap.nas
    should be equal    ${vonr_hangup[0]}    0
