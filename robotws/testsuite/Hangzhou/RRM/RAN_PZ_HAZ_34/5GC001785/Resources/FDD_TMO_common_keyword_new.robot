*** Settings ***
Documentation
...    author: Andy Cheng, Ming Shi
...    contact: huimin.1.cheng@nokia-sbell.com, ming.shi@nokia-sbell.com
...    squad group: SG_03
...    feature : TMO_FDD

Library      OperatingSystem
Library      Process
Library      Collections
Library      String
Library      BuiltIn
Library      taf.collectors.btslog   WITH NAME   btslog
Library      taf.collectors.core   WITH NAME    core
Library      taf.transport.ssh    WITH NAME    csn
Library    taf.analyzer.pcap   WITH NAME    cap
Library    taf.hw.rf_attenuator    WITH NAME   atten
Variables    ../Resources/FDD_TMO_case_commission/__init__.py
Library    taf.gnb.oam.commissioning    WITH NAME    commissioning
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource     taf/rfrl/common_resources/robot/gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
#Resource    TDD_FDD_HO_common_keyword_new.robot
Library      taf.rfrl.common_resources.python.SWConfig    WITH NAME    swconf


*** Variables ***
${cpc_index}     0
${gnb_path}    /tmp/
${tshark_path}      /usr/bin/tshark
${luashark_path}      /home/ute/tmp/luashark/generated_luashark/luashark.lua
${command_template_N}       {tshark_path} -r {input_file} -Y  \"ngap\"  -T pdml > {output_file}
${test_pc}    ${tl.test_pc.default_ssh_connection_details.addr}
${TS_LOG_PATH_BASE}      /opt/workspace/CIT/Master/Case_Logs
${tl_scf_dir_path}    /opt/workspace/CIT/Master/SCF_file/
${tl_scf_filename}    Full_Configuration_scf_MRBTS_TMO_FDD.xml
${tl_scf_filename_5mhz}    Full_Configuration_scf_MRBTS_TMO_FDD_5Mhz.xml
${tl_scf_filename_10mhz}    Full_Configuration_scf_MRBTS_TMO_FDD_10Mhz.xml
${tl_scf_filename_15mhz}    Full_Configuration_scf_MRBTS_TMO_FDD_15Mhz.xml
${tl_scf_filename_20mhz}    Full_Configuration_scf_MRBTS_TMO_FDD_20Mhz.xml
${WEBUI_COAM}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_NAME}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${ENB_ADDRESS}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${asik_addr}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${asik_username}    ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${asik_password}    ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${enb_MRBTS_id}     ${tl.enbs[0].instance_id}
${enb_NRBTS_id}     ${tl.enbs[0].global_bts_id}
${gnb_instance}     ${tl.gnbs[0].instance_id}
${enbx2_dist}    MRBTS-${enb_MRBTS_id}/LNBTS-${enb_NRBTS_id}/LNADJGNB-0
${enbx2_para}    administrativeState
${lnrel_dist}    MRBTS-${enb_MRBTS_id}/LNBTS-${enb_NRBTS_id}/LNCEL-4
${lnrel_para}    defaultLnRelGnbCellId
${f1_sctp_port}    38472
${x2_sctp_port}    29211
${atten_ip}    ${tl.attenuator[0].ip_addr}
${att_api_port}    ${tl.attenuator[0].port}
${max_attenuation_value}    ${127}
${vendor}    ${tl.attenuators[0].vendor}
${5Gcell1_ANT1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${5Gcell1_ANT2}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${5Gcell2_ANT1}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}
${5Gcell2_ANT2}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no}
${5Gcell3_ANT1}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[0].port_no}
${5Gcell3_ANT2}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[1].port_no}
${5Gcell4_ANT1}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[0].port_no}
${5Gcell4_ANT2}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[1].port_no}
${5Gcell5_ANT1}    ${tl.gnbs[1].dus[0].rus[1].attenuation_ports[0].port_no}
${5Gcell5_ANT2}    ${tl.gnbs[1].dus[0].rus[1].attenuation_ports[1].port_no}
${5Gcell6_ANT1}    ${tl.gnbs[1].dus[0].rus[2].attenuation_ports[0].port_no}
${5Gcell6_ANT2}    ${tl.gnbs[1].dus[0].rus[2].attenuation_ports[1].port_no}
${4Gcell2_ANT1}    ${tl.gnbs[0].dus[0].rus[3].attenuation_ports[0].port_no}
${4Gcell2_ANT2}    ${tl.gnbs[0].dus[0].rus[3].attenuation_ports[1].port_no}
${4Gcell1_ANT1}    ${tl.gnbs[1].dus[0].rus[3].attenuation_ports[0].port_no}
${4Gcell1_ANT2}    ${tl.gnbs[1].dus[0].rus[3].attenuation_ports[1].port_no}}
${vmute_addr}    ${tl.test_pc.default_ssh_connection_details.addr}
${vmute_user}    ${tl.test_pc.default_ssh_connection_details.username}
${vmute_pwd}    ${tl.test_pc.default_ssh_connection_details.password}
${enb_instance}     ${tl.enbs[0].instance_id}
${enbcell_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL
${mcc}            ${tl.core.mcc}
${mnc}            ${tl.core.mnc}
${AT_script_path}    C:/Tools/AT
${ue_index}    ${0}
${COM_port}    ${tl.ues[${ue_index}].serial_com}
${NGap_log_default}    SA_qci7_ngap_default.pcap


*** Keywords ***
UE prepare for attach
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    #ui_version=S21UI3.1
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    reset_sol=${True}    ui_version=S20UI2.5
#    ${ue_status}    run keyword and return status    SA L3 call attach
#    run keyword if    ${ue_status}==${False}    ue attach with force at command
    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}

ue attach with force at command
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.send_command   command=taskkill /f /im ATCom.exe    connection=cpc_${ue_index}
    sleep    2s
    csn.send_command   command=cmd /c python ${AT_script_path}/ATcommand.py -p com${COM_port} -c "at+cfun=0"    connection=cpc_${ue_index}
    sleep    2s
    csn.send_command   command=cmd /c python ${AT_script_path}/ATcommand.py -p com${COM_port} -c "at+cfun=1"    connection=cpc_${ue_index}
    sleep    3s
    csn.send command    command=cmd /c python ${AT_script_path}/ATcommand.py -p com${COM_port} -c "at+cops=1,2,${mcc}${mnc}"
    ...    connection=cpc_${ue_index}
    sleep    30s

kill all cli progress
    run    command=ps -ef | grep ute_common_admin | grep -v grep | awk '{print $2}' | xargs kill -9

Site reset with enb site
    Connect to eNB via ssl
    enblte.reset_site    connection=enblte
    [Teardown]    enblte.teardown    connection=enblte

Verify all 5G cells status onair
    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds   3x    30s    Verify all cells should be onair
    [Teardown]    COAM Teardown gnb connections

Check the 5G RU status
    [Arguments]    ${administrativeState}=Unlocked     ${operationalState}=Enabled   ${configured}=configured    ${availabilityStatus}=Online
    Connect to gnb coam via ssl
    COAM Check BTS RU status    administrativeState=${administrativeState}    operationalState=${operationalState}
    ...    configured=${configured}    availabilityStatus=${availabilityStatus}
    [Teardown]    COAM Teardown gnb connections

Check the 4G RU status
    [Arguments]    ${administrativeState}=Unlocked     ${operationalState}=Enabled   ${configured}=configured    ${availabilityStatus}=Online
    Connect to eNB via ssl
    COAM Check BTS RU status    connection=enblte    administrativeState=${administrativeState}    operationalState=${operationalState}
    ...    configured=${configured}    availabilityStatus=${availabilityStatus}
    [Teardown]    enblte.teardown    connection=enblte

COAM Check BTS RU status
    [Arguments]    ${connection}=GNB_OAM    ${ru_sn}=all    ${administrativeState}=Unlocked    ${operationalState}=Enabled
    ...    ${configured}=configured    ${availabilityStatus}=Online
    Log to console    Check RU status from GNB
    ${hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    ${count_RUs}    Get length    ${list_RUs}
    ${ru_item}    Set variable    ${0}
    Should be true    ${count_RUs}>=${1}    msg=Check RU status failed as total RU number is less than 1
    FOR  ${ru}  IN  @{list_RUs}
        Run keyword if    '${ru_sn}'!='all' and '${ru_sn}'!='${ru['serialNumber']}'    continue for loop
        ${ru_item}=    evaluate    ${ru_item}+1
        Run keyword and continue on failure    Should be equal as strings    ${ru['status']['administrativeState']}    ${administrativeState}
                                      ...  msg=Current RU administrativeState is not in Unlocked status    ignore_case=${True}
        Run keyword and continue on failure    Should be equal as strings    ${ru['status']['operationalState']}    ${operationalState}
                                      ...  msg=Current RU operationalState is not in Enabled status    ignore_case=${True}
        Run keyword and continue on failure    Should be equal as strings    ${ru['status']['proceduralStatus']}    ${configured}
                                      ...  msg=Current RU proceduralStatus is not in configured status    ignore_case=${True}
        Run keyword and continue on failure    Should be equal as strings    ${ru['status']['availabilityStatus']}    ${availabilityStatus}
                                      ...  msg=Current RU availabilityStatus is not in Online status    ignore_case=${True}
    END
    should be true    ${ru_item}>${0}    msg=Check RU status failed as no RU found !!!

Operate the enbcell status
    [Arguments]    ${enbcell_dist}    ${cell_status}
    Connect and Modify the parameter on enblte    dist_name=${enbcell_dist}    parameter=${enbx2_para}    value=${cell_status}

Connect to BTS Common master
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}
    wait until keyword succeeds    1 min    10 sec    csn.Connect to
    ...    hostname=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ...    username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    alias=ASIK

Tear down UE traffic and detach
    run keywords
    ...    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    iperf_port=${dl_port}    AND
    ...    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    iperf_port=${ul_port}    AND
    ...    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}

SA L3 call attach with tcp data peak
    [Arguments]    ${bandwidth}    ${cellid}    ${interval}=${1}
    SA L3 call attach    bandwidth=${bandwidth}    cellid=${cellid}    interval=${interval}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${Send_Tput_DL}   duration=${traffic_duration}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${Send_Tput_UL}   duration=${traffic_duration}
    Check the cell DLUL throughput    bandwidth=${bandwidth}    cellid=${cellid}

Check the cell DLUL throughput
    [Arguments]    ${bandwidth}    ${cellid}    ${gnb_index}=${0}
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    Log to console    bts_host ${bts_host}
    ${nrcellid}    FDD_TMO_common_keyword.COAM Get nrcellid with lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    Wait Until Keyword Succeeds   5x    10s    power_ue.Check Throughput    sample=${6}
    ...    ue_type=${ue_type}    direction=dl    throughput=${dlexpect_TMO_${bandwidth}}    cellid=${nrcellid}    sleep_time=${20}
    Wait Until Keyword Succeeds   5x    10s    power_ue.Check Throughput    sample=${6}
    ...    ue_type=${ue_type}    direction=ul    throughput=${ulexpect_TMO_${bandwidth}}    cellid=${nrcellid}    sleep_time=${20}

SA L3 call attach
    [Arguments]    ${bandwidth}=default    ${cellid}=${1}    ${interval}=${1}    ${gnb_index}=${0}    ${ue_index}=${0}
    ...    ${ui_version}=default
    Log to console    bandwidth ${bandwidth}
    Log to console    interval ${interval}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    ui_version=${ui_version}
    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
    Run Keyword If    ${use_gnb_index}==${1}    Set Test Variable    ${cellid}    6
    Adjust 5Gcell${cellid} Attenuation to ${0}
    sleep    30s
#    Start Capture Classical wiresahrk Logs    bts_type=gnb    interface=fp0    logname=${NGap_log_${bandwidth}}
#    ...    gnb_index=${gnb_index}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    gnb_index=${gnb_index}
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    ue_index=${ue_index}
    ...    gnb_index=${gnb_index}    4G_check=${False}
#    [Teardown]
#    Stop and save Capture Classical wiresahrk Logs    bts_type=gnb    logname=${NGap_log_${bandwidth}}
#    ...    gnb_index=${gnb_index}

At Cmd UE reAttach
    [Arguments]    ${ue_index}=${0}    ${gnb_index}=${0}    ${hwcheck_index}=${1}    ${du_index}=0
    ...    ${log_type}=Aasyslog    ${interval}=${1}    &{kwargs}
    [Documentation]    reAttach UE for L3 call test.
    Log to console    ue_index ${ue_index}
    Log to console    interval ${interval}
    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    Aasyslog precondition    gnb_index=${gnb_index}    du_index=${du_index}
    Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    filter=L2   log_name=5Grach.txt
    ${5Gra_l2lo_counter}    ${5Gra_l2lo_timed}    Get 5GRACH success times on gnb side    gnb_index=${gnb_index}
    ...                                                                          hwcheck_index=${hwcheck_index}
    ...                                                                          log_type=${log_type}
    ...                                                                          log_loca=l2lo
    ${5Gra_l2hidu_counter}    ${5Gra_l2hidu_timed}    Get 5GRACH success times on gnb side    gnb_index=${gnb_index}
    ...                                                                          hwcheck_index=${hwcheck_index}
    ...                                                                          log_type=${log_type}
    ...                                                                          log_loca=l2hidu
    ute_ue.send_at_cmd_to_ue    alias=UE_0    at_cmd=at+cops=1,2,${mcc}${mnc}
    [Return]    ${5Gra_l2lo_counter}    ${5Gra_l2lo_timed}    ${hwcheck_index}    ${log_type}
    ...    ${5Gra_l2hidu_counter}    ${5Gra_l2hidu_timed}

convert the bts addr to hex value
    @{bts_addr}    split string    ${tl.test_pc.default_ssh_connection_details.addr}    .
    ${hex_btsaddr}    set variable    0x
    ${item}    set variable    ${0}
    FOR    ${value}    IN    @{bts_addr}
        ${hex_value}    run keyword if    '${item}'=='${0}'    convert to hex    item=${value}
    ...   ELSE    convert to hex    item=${value}    length=2
        ${hex_btsaddr} =    catenate    ${hex_btsaddr}${hex_value}
        ${item} =    Evaluate    ${item} + 1
    END
    [Return]    ${hex_btsaddr}

Start btslog capture on Remote UTE
    run    command=sudo iptables -F
    ${executor_test_vm}=  Create Dictionary
    ...  host=${vmute_addr}
    ...  user=root
    ...  password=nokia123
    btslog.create_btslog_collector
    ...   name=btslog
    ...   btslog_path=/opt/btslog/btslog
    ...   btslog_launcher_path=/opt/btslog/btslog_launcher
    ...   executor=${executor_test_vm}
    ...   log_dir=/tmp/btslog2
    core.setup_collectors  names=btslog
    core.start_collectors  names=btslog
    sleep  5s
    ${btslog_id}    run    command=ps -ef | grep btslog |grep -v grep | awk '{print $2}'
    should not be empty    ${btslog_id}

Stop the btslog catch
    [Arguments]     ${logsave_path}
    run    command=ps -ef | grep btslog |grep -v grep | awk '{print $2}'|xargs sudo kill -9
    sleep    3s
    run    command=scp /tmp/btslog2/*.LOG ${logsave_path}

COAM Get nrcellid with lcrid
    [Arguments]   ${lcrid}    ${gnb_index}=${0}    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    Connect to gnb coam via ssl   bts_host=${bts_host}
    ${cell_info}   coam.get_subcells_info   timeout=20    connection=GNB_OAM
    ${number_of_cell_group_info}    get length    ${cell_info}
#    Set Test Variable    ${used_gnb_index}    ${gnb_index}
#    Run Keyword If    ${used_gnb_index}==${0}    Set Test Variable    ${init_num}    ${0}
#    ...    ELSE IF    ${used_gnb_index}==${1}    Set Test Variable    ${init_num}    ${1}
#    Run Keyword If    ${init_num}==${0}    Set Test Variable    ${number_of_cell_group_info}    ${number_of_cell_group_info}
#    ...    ELSE IF    ${init_num}==${1}    Set Test Variable    ${number_of_cell_group_info}    ${number_of_cell_group_info}+${1}
    FOR  ${index}    IN RANGE    ${number_of_cell_group_info}
        ${cell_from_cellgrp}    Get from Dictionary    ${cell_info}    NRCELLGRP-${index}
        ${nrCellId}    FDD_TMO_common_keyword.Get nrcellid in all cellgroup with lcrid    cell_from_cellgrp=${cell_from_cellgrp}    lcrid=${lcrid}
        exit for loop if    '${nrCellId}'!='None'
    END
    [Return]    ${nrCellId}
    [Teardown]    COAM Teardown gnb connections

Get nrcellid in all cellgroup with lcrid
    [Arguments]   ${cell_from_cellgrp}    ${lcrid}
    ${cell_list}    Get Dictionary Keys    ${cell_from_cellgrp}
    FOR  ${cell}  IN   @{cell_list}
        ${eachcell}    Get from Dictionary    ${cell_from_cellgrp}    ${cell}
        ${lcrid_get} =    set variable    ${eachcell['NRCELL_L']['parameters']['lcrId']}
        ${nrCellIdentity}     run keyword if     '${lcrid_get}'=='${lcrid}'
        ...    set variable    ${eachcell['NRCELL_L']['parameters']['nrCellIdentity']}
    END
    [Return]    ${nrCellIdentity}

Change the SDX55 5G mode
    [Arguments]    ${ue_index}    ${5g_mode}
    ${5g_mode_exp}    run keyword if  '${5g_mode}'=='NSA'  set variable  ${1}    ELSE IF   '${5g_mode}'=='SA'   set variable  ${2}
    ${mode_status}    run keyword and return status    Check the SDX55 5G mode    5g_mode_exp=${5g_mode_exp}    ue_index=${ue_index}
    run keyword if    ${mode_status}==${False}    run keywords
    ...    Set the SDX55 5G mode    5g_mode=${5g_mode_exp}    ue_index=${ue_index}    AND
    ...    UE soft reboot    ue_index=${ue_index}    detach_request=False    AND
    ...    Check the SDX55 5G mode    5g_mode_exp=${5g_mode_exp}    ue_index=${ue_index}

Check the SDX55 5G mode
    [Arguments]    ${5g_mode_exp}    ${ue_index}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.send command    command=adb root    connection=cpc_${ue_index}
    sleep    5s
    csn.send command    command=adb shell getprop persist.vendor.radio.5g_mode_pref_0    connection=cpc_${ue_index}
    Sleep   3s
    ${5g_mode_act}    csn.read output    size=1000    connection=cpc_${ue_index}
    ${5g_mode_act}    evaluate    ${5g_mode_act.strip()}
    should be equal    ${5g_mode_act}   ${5g_mode_exp}
    [Teardown]    csn.Disconnect   connection=cpc_${ue_index}

Set the SDX55 5G mode
    [Arguments]    ${5g_mode}    ${ue_index}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.send command    command=adb root    connection=cpc_${ue_index}
    sleep    5s
    csn.send command    command=adb shell setprop persist.vendor.radio.5g_mode_pref_0 ${5g_mode}    connection=cpc_${ue_index}
    sleep    3s
    [Teardown]    csn.Disconnect   connection=cpc_${ue_index}

PA setup for NSA attach
    Adjust 5Gcell1 Attenuation to ${30}
    Adjust 5Gcell2 Attenuation to ${127}
    Adjust 5Gcell3 Attenuation to ${127}
    Adjust 4Gcell2 Attenuation to ${30}
    sleep    3s

PA setup for LTE attach
    Adjust 5Gcell1 Attenuation to ${127}
    Adjust 5Gcell2 Attenuation to ${127}
    Adjust 5Gcell3 Attenuation to ${127}
    Adjust 4Gcell2 Attenuation to ${30}
    sleep    3s

PA setup for all cell down
    Adjust 5Gcell1 Attenuation to ${127}
    Adjust 5Gcell2 Attenuation to ${127}
    Adjust 5Gcell3 Attenuation to ${127}
    Adjust 5Gcell4 Attenuation to ${127}
    Adjust 5Gcell5 Attenuation to ${127}
    Adjust 5Gcell6 Attenuation to ${127}
#    Adjust 4Gcell1 Attenuation to ${127}
    Adjust 4Gcell2 Attenuation to ${127}
    sleep    3s

PA setup for all cell up
    Adjust 5Gcell1 Attenuation to ${0}
    Adjust 5Gcell2 Attenuation to ${0}
    Adjust 5Gcell3 Attenuation to ${0}
    Adjust 4Gcell2 Attenuation to ${127}
    sleep    3s

PA setup for pingpang HO
    [Arguments]  ${cell1_PA_value}=${10}    ${cell6_PA_value}=${5}
    Adjust 5Gcell1 Attenuation to ${cell1_PA_value}
    Adjust 5Gcell2 Attenuation to ${127}
    Adjust 5Gcell3 Attenuation to ${127}
    Adjust 5Gcell4 Attenuation to ${127}
    Adjust 5Gcell5 Attenuation to ${127}
    Adjust 5Gcell6 Attenuation to ${cell6_PA_value}
#    Adjust 4Gcell1 Attenuation to ${127}
    Adjust 4Gcell2 Attenuation to ${127}
    sleep    3s

PA recover for pingpang HO
    Adjust 5Gcell1 Attenuation to ${0}
    Adjust 5Gcell2 Attenuation to ${127}
    Adjust 5Gcell3 Attenuation to ${127}
    Adjust 5Gcell4 Attenuation to ${127}
    Adjust 5Gcell5 Attenuation to ${127}
    Adjust 5Gcell6 Attenuation to ${127}
#    Adjust 4Gcell1 Attenuation to ${127}
    Adjust 4Gcell2 Attenuation to ${127}
    sleep    3s

Common UE parameter setup
    [Arguments]  ${ue_index}=${0}
    set suite variable    ${ue_type}    ${tl.ues[${ue_index}].capabilities[1]}
    set suite variable    ${serial_number}    ${tl.ues[${ue_index}].serial_number}


Adjust ${cell} Attenuation to ${value}
    Adjust the Attenuation Value    ports=${${cell}_ANT1}    value=${value}
    Adjust the Attenuation Value    ports=${${cell}_ANT2}    value=${value}

Adjust the Attenuation Value
    [Arguments]    ${ports}    ${value}
    atten.setup_attenuator    ip_addr=${atten_ip}    port=${att_api_port}
    ...    attenuation_port_numbers=${ports}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    atten.set_attenuation     port=${ports}    value=${value}
    ${value_read}    atten.read_attenuation    port=${ports}
    should be equal    ${value_read}    ${value}

Stop and save Capture Classical wiresahrk Logs
    [Arguments]    ${logname}    ${bts_type}=gnb    ${gnb_index}=${0}
    run keyword if    '${bts_type}'=='gnb'    Connect to Common Unit Master    alias=${bts_type}    gnb_index=${gnb_index}
    ...    ELSE IF    '${bts_type}'=='enb'    enb connections   alias=${bts_type}
    sleep    3s
    Stop and download Logs    logname=${logname}    connection=${bts_type}

Stop and download Wireshark Logs on gNB Slave
    [Arguments]    ${logname}    ${gnb_index}=${0}
    Connect to Common Unit Slave    gnb_index=${gnb_index}    alias=ASIK${gnb_index}_Slave
    csn.send command    command=killall tcpdump     connection=ASIK${gnb_index}_Slave
    sleep    3
    csn.download_file   remote_path=${gnb_path}${logname}   local_path=${epc_log_path}${logname}   connection=ASIK${gnb_index}_Slave
    sleep    3
    [Teardown]      run keyword and ignore error      Csn.disconnect      connection=ASIK${gnb_index}_Slave

Stop and download Logs
    [Arguments]    ${logname}    ${connection}
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    3
    csn.download_file   remote_path=${gnb_path}${logname}   local_path=${epc_log_path}${logname}   connection=${connection}
    sleep    3

enb connections
    [Arguments]    ${alias}
    csn.Connect To    hostname=${ENB_ADDRESS}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=${alias}

Start Capture Classical wiresahrk Logs
    [Arguments]    ${logname}    ${interface}=fp0    ${bts_type}=gnb    ${gnb_index}=${0}
    run keyword if    '${bts_type}'=='gnb'    Connect to Common Unit Master    alias=${bts_type}    gnb_index=${gnb_index}
    ...    ELSE IF    '${bts_type}'=='enb'    enb connections   alias=${bts_type}
    sleep    3s
    Start To Capture Wireshark Logs    logname=${logname}    connection=${bts_type}    interface=${interface}
    sleep    3s

Start Capture Wireshark Logs on gNB Slave
    [Arguments]    ${logname}    ${gnb_index}=${0}    ${interface}=any
    Connect to Common Unit Slave    gnb_index=${gnb_index}    alias=ASIK${gnb_index}_Slave
    csn.send command    command=tcpdump -i ${interface} -C 25M -w ${gnb_path}${logname}   connection=ASIK${gnb_index}_Slave

Start To Capture Wireshark Logs
    [Arguments]     ${logname}    ${connection}    ${interface}
    csn.send command    command=tcpdump sctp -i ${interface} -w ${gnb_path}${logname}   connection=${connection}

Update the swconfig file
    [Arguments]    ${localFilePath}
    run    command=cp ${localFilePath} ${epc_log_path}swconfig.txt
    wait until keyword succeeds    5min    10s    Connect to Common Unit Master   alias=ASIK
    swconf.Upload SwConfig File To Asik And Crasign     localFilePath=${epc_log_path}swconfig.txt    asik_alias=ASIK
    csn.disconnect     connection=ASIK

Modify scf file for case
    [Arguments]    ${modify_list}    ${tl_scf_file}=${tl_scf_filename}
    run keyword and continue on failure     commissioning.Modify Scf    input_scf=${tl_scf_dir_path}${tl_scf_file}
    ...            output_scf=${epc_log_path}${tl_scf_file}    parameters_lists=${modify_list}

Suite Recovery
    run keyword and ignore error  COAM Teardown gnb connections
    Connect and Modify the parameter on enblte   dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=unlocked
    run keyword and ignore error    csn.disconnect    connection=gnb
    run keyword and ignore error    csn.disconnect    connection=enb

#Common Suite Setup for COAM
#    COAM Create log directory    is_set_to_test_case_level=${False}
#    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
#    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}/${time_stamp}/
#    Create directory    ${epc_log_path}
#    set_suite_documentation    doc=||| All test suite log will save in this VM IP:${test_pc} logPath:${epc_log_path}
#    ...    append=True
Common Suite Setup for COAM
    COAM Create log directory    is_set_to_test_case_level=${False}    response_timeout=30
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}/${time_stamp}/
    Create directory    ${epc_log_path}
    set_suite_documentation    doc=||| All test suite log will save in this VM IP:${test_pc} logPath:${epc_log_path}
    ...    append=True

Common Suite Teardown for COAM
    Connect to gnb coam via ssl
    COAM Download scf from cluster    scf_dir_path=${epc_log_path}
    COAM Save snapshot via rest api    log_path=${epc_log_path}
    [Teardown]    COAM Teardown gnb connections

Prepare with COAM classical BTS cell onair
    [Arguments]    ${lnrel_value}=1    ${scf_filename}=${tl_scf_filename}    ${bts_type}=SA
    Perform full commission for COAM gnb    scf_filename=${scf_filename}
    run keyword if    '${bts_type}'=='NSA'    Connect and Modify the parameter on enblte
    ...    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=locked
    Check gnb COAM classical start normally
    run keyword if    '${bts_type}'=='NSA'    Connect and Modify the parameter on enblte
    ...    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=unlocked
    run keyword if    '${bts_type}'=='NSA'    Connect and Modify the parameter on enblte
    ...    dist_name=${lnrel_dist}    parameter=${lnrel_para}    value=${lnrel_value}
    Check the gnb cell status onair

Power reset For All RU
    [Arguments]    ${ru_reset}=no
    Run Keyword If   '${ru_reset}'!='yes'  return from keyword   ${ru_reset}
    ${ru_num}    get length    ${tl.gnbs[0].dus[0].rus}
    For  ${index}    IN RANGE    ${ru_num}
        ${index}    Evaluate    ${index}+${1}
        ${status}    Run Keyword And Return Status     Perform RU Power Off    ru_index=${index}
        run keyword if  not ${status}    Log    Power Off RU_${index}  failed.
        sleep   3s
        ${status}    Run Keyword And Return Status     Perform RU Power On    ru_index=${index}
        run keyword if  not ${status}    Log    Power On RU_${index}  failed.
    END
    [Return]    ${ru_reset}

Perform full commission for COAM gnb
    [Arguments]    ${scf_filename}    ${is_pdl_checking_needed}=${False}
    Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${epc_log_path}${scf_filename}    is_pdl_checking_needed=${is_pdl_checking_needed}
    [Teardown]    COAM Teardown gnb connections

Check gnb COAM classical start normally
    Check Airscale HW module status
#    ${res} =    Feature 1514 Enabled
#    run keyword if    ${res}==${False}    wait until keyword succeeds    10min   30s    Check the sctp port UP    port_num=${f1_sctp_port}
    Check the gnb RU status ready
#    wait until keyword succeeds    10min   30s    Check the sctp port UP    port_num=${x2_sctp_port}

Check the sctp port UP
    [Arguments]    ${port_num}
    Connect to BB1 master    alias=BB1
    csn.send command    command=netstat -anl |grep sctp    connection=BB1
    sleep    3s
    ${sctp_status} =    csn.read output    connection=BB1
    csn.disconnect     connection=BB1
    should contain     ${sctp_status}     ${port_num}

Check the gnb RU status ready
    Connect to gnb coam via ssl
    wait until keyword succeeds    10min   30s    COAM Check GNB RU status
    [Teardown]    COAM Teardown gnb connections

Check the gnb cell status onair
    Connect to gnb coam via ssl
    wait until keyword succeeds    5min   30s    COAM Check GNB cell on air
    [Teardown]    COAM Teardown gnb connections

Tear down the connections
    Run keyword and ignore error    coam_gnb_classical.COAM Teardown gnb connections
    Run keyword and ignore error    csn.Disconnect    connection=enb
    Run keyword and ignore error    csn.Disconnect    connection=gnb
    Run keyword and ignore error    csn.Disconnect    connection=ASIK Master
    Run keyword and ignore error    csn.Disconnect    connection=BB1

#tcp tput#
SA L3 call attach with tcp data peak_tcp_tput
    [Arguments]    ${bandwidth}    ${cellid}    ${interval}=${1}    ${gnb_index}=${0}
    ${nrcellid}    FDD_TMO_common_keyword.COAM Get nrcellid with lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    SA L3 call attach    bandwidth=${bandwidth}    cellid=${cellid}    interval=${interval}    gnb_index=${gnb_index}
#    ${dl_port} =    evaluate    ${tl.appserver.iperf_details.port} + ${ue_index}
#    ${ul_port} =    evaluate    ${tl.appserver.iperf_details.port} - (${ue_index} + ${1})
#    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${Send_Tput_DL}
#    ...    duration=${traffic_duration}    protocol=tcp    iperf_port=${dl_port}
#    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${Send_Tput_UL}
#    ...    duration=${traffic_duration}    protocol=tcp    iperf_port=${ul_port}
    Prepare all online UE with UL and DL data start with Qcom366    cell_type=SA
#    sleep    30s
#    Check Tput l3call    ue_type=${ue_type}    direction=dl    cells=${nrcellid}    expect=${dlexpect_TMO_${bandwidth}}
#    ...    duration=20s    gnb_index=${gnb_index}
#    Check Tput l3call    ue_type=${ue_type}    direction=ul    cells=${nrcellid}    expect=${ulexpect_TMO_${bandwidth}}
#    ...    duration=20s    gnb_index=${gnb_index}
    Wait Until Keyword Succeeds   5x    10s    power_ue.Check Throughput    sample=${6}
    ...    ue_type=${ue_type}    direction=dl    throughput=${dlexpect_TMO_${bandwidth}}
    ...    gnb_index=${gnb_index}    cellid=${nrcellid}    sleep_time=${20}
    Wait Until Keyword Succeeds   5x    10s    power_ue.Check Throughput    sample=${6}
    ...    ue_type=${ue_type}    direction=ul    throughput=${ulexpect_TMO_${bandwidth}}
    ...    gnb_index=${gnb_index}    cellid=${nrcellid}    sleep_time=${20}

Check Tput l3call
    [Arguments]   ${ue_type}   ${direction}   ${cells}   ${expect}  ${ue_index}=${0}   ${duration}=20s
    ...   ${gnb_index}=${0}
    ${tput_log}   power_ue.Collect Tput   ue_type=${ue_type}   duration=${duration}   ignore_time=1s   gnb_index=${gnb_index}
    ${tput_result}   Run Keyword and Return Status   power_ue.Check Tput   ue_type=${ue_type}   direction=${direction}
    ...   log=${tput_log}   cells=${cells}   target_throughput=${expect}
    run keyword if  not ${tput_result}   power_ue.Check throughput
    ...   ue_type=${ue_type}   ue_index=${ue_index}   direction=${direction}   throughput=${expect}

Start DL TCP traffic and check the TP on EPC with first UE_tcp
    [Arguments]    ${serial_number}    ${capabilities}    ${hostname}    ${username}    ${password}
    ...            ${ue_index}=${0}    ${DL_port}=${tl.ues[${ue_index}].iperf_details.port}    ${time}=10
    ...            ${interval}=1    ${traffic}=10.00M
    ...            ${buffer_size}=1024B
    Log to console    traffic ${traffic}
    Log to console    interval ${interval}
    Log to console    buffer_size ${buffer_size}
    Get Commercial UE IP_tcp    ue_index=${ue_index}    capabilities=${capabilities}    serial_number=${serial_number}
    ...    hostname=${hostname}    username=${username}    password=${password}
    Connect to control pc via cygwin    ue_index=${ue_index}    hostname=${hostname}    username=${username}    password=${password}
    csn.send_command    command=adb -s ${serial_number} root &
    ...    connection=cygwin
    csn.send_command    command=adb -s ${serial_number} shell ps -ef |grep iperf |grep ${DL_port} |grep -v grep |awk '{print $2}'
    ...    connection=cygwin
    ${pid}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=cygwin
    csn.send_command    command=adb -s ${serial_number} shell kill -9 ${pid} &
    ...    connection=cygwin
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell ps -ef |grep iperf |grep ${DL_port} |grep -v grep |awk '{print $2}'
    ...    connection=cygwin
    ${pid}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=cygwin
    ...    connection=cygwin
    csn.send_command    command=adb -s ${serial_number} shell /data/local/tmp/iperf3 -s -p ${DL_port} -i 1 &
    ...    connection=cygwin
    sleep    1s
    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}
    ...    hostname=${hostname}    username=${username}    password=${password}
    csn.send_command    command=ps -ef|grep iperf3|grep -v grep|grep ${DL_port}| awk '{print $2}' |xargs kill -9 &    connection=EPCAPP
    ...    connection=EPCAPP
    sleep    5s
    csn.send_command
    ...    command=iperf3 -c ${UE_IP} -p ${DL_port} -t ${time} -P 16 -w 2M -M 1280 >/dev/null 2>/dev/null &
    ...    connection=EPCAPP
    log to console    .....UE_${ue_index} tcp dl iperf start....
    #[Teardown]    csn.disconnect      connection=EPCAPP}

Get Commercial UE IP_tcp
    [Arguments]    ${serial_number}    ${capabilities}    ${hostname}    ${username}    ${password}
    ...    ${ue_index}=${0}   ${cap_index}=${0}
    Log to console    cap_index ${cap_index}
    Connect to control pc via cygwin    ue_index=${ue_index}    hostname=${hostname}    username=${username}    password=${password}
    run keyword if    '${capabilities}'=='HUAWEI_MATE30PRO'    Get Commercial UE IP with first UE    ue_index=${ue_index}
    ...    command=adb shell ip -f inet addr |grep inet | grep -v ims00 | cut -d '/' -f 1 |tail -n -2 |head -1 |awk '{print $2}'
    ...    ELSE    Get Commercial UE IP with first UE    ue_index=${ue_index}    serial_number=${serial_number}

Start UL TCP traffic via iperf command_tcp
    [Arguments]
    ...    ${capabilities}    ${serial_number}    ${hostname}    ${username}    ${password}    ${EPC_IP}    ${UL_port}
    ...    ${ue_index}=${0}    ${buffer_size}=1024B    ${interval}=1
    ...    ${time}=10
    ...    ${traffic}=10.00M
    ...    ${data_amount}=2M
    Log to console    traffic ${traffic}
    Log to console    interval ${interval}
    Log to console    buffer_size ${buffer_size}
    Log to console    EPC_IP ${EPC_IP}
    log to console    Start UL TCP traffic
    Get Commercial UE IP_tcp    ue_index=${ue_index}    serial_number=${serial_number}    capabilities=${capabilities}
    ...    hostname=${hostname}    username=${username}    password=${password}
    Connect to control pc via cygwin    ue_index=${ue_index}    hostname=${hostname}    username=${username}    password=${password}
    csn.send_command    command=adb -s ${serial_number} root &
    ...    connection=cygwin
    csn.send_command    command=adb -s ${serial_number} shell ps -ef | grep iperf |grep ${UL_port} |grep -v grep |awk '{print $2}'
    ...    connection=cygwin
    ${pid}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=cygwin
    csn.send_command    command=adb -s ${serial_number} shell kill -9 ${pid} &
    ...    connection=cygwin
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell ps -ef | grep iperf |grep ${UL_port} |grep -v grep |awk '{print $2}'
    ...    connection=cygwin
    ${pid}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=cygwin
    csn.send_command    command=adb -s ${serial_number} shell /data/local/tmp/iperf3 -s -p ${UL_port} -i 1 &
    ...    connection=cygwin
    sleep    1s
    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}
    ...    hostname=${hostname}    username=${username}    password=${password}
    sleep   1s
    csn.send_command    command=ps -ef|grep iperf3|grep -v grep|grep ${UL_port}| awk '{print $2}' |xargs kill -9 &   connection=EPCAPP
    sleep    5s
    csn.send_command    command=iperf3 -c ${UE_IP} -p ${UL_port} -t ${time} -R -w ${data_amount} -M 1280 -P 4 >/dev/null 2>/dev/null &
    ...    connection=EPCAPP
    log to console    .....UE_${ue_index} tcp ul iperf start....
    #[Teardown]    csn.disconnect      connection=EPCAPP

Tear down UE traffic and detach_tcp
    [Arguments]      ${ue_num}=${1}
#    run keywords
#    ...    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}    protocol=tcp    AND
#    ...    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}    protocol=tcp    AND
#    ...    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
    Stop all online UE DL data transfer    ue_num=${ue_num}
    Stop all online UE UL data transfer    ue_num=${ue_num}

Detach UE
    [Arguments]      ${ue_index}=${0}
    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}

#stop tcp traffic
#Stop TCP traffic
#    [Arguments]    ${hostname}    ${username}    ${password}    ${port}    ${serial_number}    ${ue_index}=${0}
#    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}
#    ...    hostname=${hostname}    username=${username}    password=${password}
#    csn.send_command    command=ps -ef|grep iperf|grep -v grep|grep ${port}| awk '{print $2}' |xargs kill -9    connection=EPCAPP
#    Stop traffic via iperf command on UE    port=${port}    ue_index=${ue_index}
#    ...    serial_number=${serial_number}    hostname=${hostname}    username=${username}    password=${password}
#    [Teardown]    csn.disconnect      connection=EPCAPP
