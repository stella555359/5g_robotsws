*** Settings ***
Documentation    This file is for  for siso cloud related cases
...              Please do not modify the file without notification to author
...              Author: Zhou Qiang
...              Contact: qiang.1.zhou@nokia-sbell.com
...              Squad: SRAN HZ SISO
Library    ./sigspark.py
Library    sigspark.SigSpark      WITH NAME    spark
Library    ../../../RAN_PZ_HAZ_34/python/ue.py
Library    ./utils/others.py
Resource   ../../../RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource   ../../../RAN_PZ_HAZ_34/robot/aasyslog.robot
Resource   ./UEs/askey_order.robot
Resource   ./ue_patch.robot
Resource   ./UEs/andriod_phone.robot


*** Variables ***
${iperf_server_ip}    ${tl.appserver.iperf_details.ssh_connection_details.addr}
${iperf_server_username}    ${tl.appserver.iperf_details.ssh_connection_details.username}
${iperf_server_password}    ${tl.appserver.iperf_details.ssh_connection_details.password}
${iperf_server_network_interface}    ${tl.appserver.iperf_details.network_interface_address}
${appserver_log_path}    /home/tdlte-tester/UDP
${ctrl_pc_addr}     ${tl.test_pc.default_ssh_connection_details.addr}
${ctrl_pc_username}   ${tl.test_pc.default_ssh_connection_details.username}

*** Keywords ***

Dingli.Prepare UE
    [Arguments]    ${ue_alias}    ${ue_index}=${0}    ${reset_sol}=${None}    ${reset_app}=${False}
    [Documentation]    This kw is used to Prepare UE with dingli.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | no | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | ue_alias | no | <str> store ue by ue_alias |
    ...    | reset_sol | no | ue has three choose (none, pc_reset, pb_reset): |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Dingli.Prepare UE | ${ue_alias} | ue_index=${0} | reset_sol=${None} |
    ...
    spark.require_ue    ue_alias=${ue_alias}    index=${ue_index}    reset_sol=${reset_sol}     reset_app=${reset_app}

################################## STEP2: UE ATTACH ##################################
Dingli.UE Attach
    [Arguments]    ${ue_alias}=UE_${0}
    [Documentation]    This kw is used to attach UE with dingli.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_alias | no | <str> store ue by ue_alias |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Dingli.UE Attach | ${ue_alias} |
    ...
    Run keyword and ignore error     spark.power_off    ue_alias=${ue_alias}
    sleep    60s
    Run keyword and ignore error     spark.power_on    ue_alias=${ue_alias}

Dingli.Get Attach Status
    [Arguments]    ${bts_id}    ${pci}     ${ue_alias}=UE_${0}
    [Documentation]    This kw is used to attach UE with dingli.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_alias | no | <str> store ue by ue_alias |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Dingli.UE Attach | ${ue_alias} |
    ...
    spark.get_attach_status    ue_alias=${ue_alias}    bts_id=${bts_id}      pci=${pci}


################################## STEP3: START DATA TRANSFER ##################################
Dingli.Start traffic
    [Arguments]    ${direction}=dl    ${duration}=60    ${throughput}=100    ${ue_index}=${0}
    ...            ${ue_alias}=UE_${0}    ${dt_name}=download
    ...            ${iperf_port}=default    ${protocal}=UDP    ${multidrb_QoS_dest}=${None}
    ...            ${connection_type}=APPserver    ${apn}=wap2.nokia.com
   [Documentation]    This kw is used for start traffic
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | no | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | ue_alias | no | <str> store ue by ue_alias |
    ...    | direction | no | The traffic direction, ul or dl |
    ...    | duration | no | Duration of traffic |
    ...    | throughput | no | Throughput of new data transfer |
    ...    | protocal | no | Traffic protocal type. E.G udp/tcp |
    ...    | iperf_port | no | port number used for traffic start via iperf |
    ...    | dt_name | no | alias name for created data transfer |
    ...    | multidrb_QoS_dest | no |  <optional> default None |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Dingli.Start traffic | ue_index=${0} | direction=dl | dt_index=${0} | throughput=110M | duration=600 |
	...
    ${default_port}    set variable    ${tl.ues[${ue_index}].iperf_details.port}
    ${port}    set variable if    '${iperf_port}' == 'default'    ${default_port}    ${iperf_port}
    spark.start_data_transfer    ue_alias=${ue_alias}    direction=${direction}    dt_name=${dt_name}
    ...                          duration=${duration}    throughput=${throughput}/sec    iperf_port=${port}
    ...                          protocol=${protocal}    multidrb_QoS_dest=${multidrb_QoS_dest}
    ...                          connectiontype=${connection_type}      apn_address=${apn}

################################## STEP4: CHECK THROUGHPUT ##################################
Dingli.Check throughput
    [Arguments]    ${ue_alias}    ${ul}     ${dl}     ${during}=120
    [Documentation]    This kw is used to Check throughput with dingli
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_alias | no | <str> store ue by ue_alias |
    ...    | direction | no | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | expected_throughput | no |<str> store ue by ue_alias |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Dingli.Check throughput | ue_alias=UE_${0} | direction=dl | expected_throughput=100 |
    ...
    ${output}    spark.check_throughput_on_ue    ue_alias=${ue_alias}   ul=${ul}     dl=${dl}    during=${during}


################################## STEP5: STOP DATA TRANSFER ##################################
Dingli.Stop traffic
    [Arguments]    ${direction}=dl    ${ue_alias}=UE_${0}
    ...            ${dt_name}=download    ${ue_index}=${0}    ${iperf_port}=default
    [Documentation]    This kw is for Stop data transfer with dingli.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | direction | no | The traffic direction, ul or dl |
    ...    | ue_alias | no | <str> store ue by ue_alias |
    ...    | dt_name | no | <str> store traffic by ue_alias |
    ...    | iperf_port | no | The port value of traffic, only used in stop DL traffic eg: 50001 |
    ...
    ${default_port}    set variable    ${tl.ues[${ue_index}].iperf_details.port}
    ${port}    set variable if    '${iperf_port}' == 'default'    ${default_port}    ${iperf_port}
    spark.stop_data_transfer    ue_alias=${ue_alias}    dt_name=${dt_name}    direction=${direction}
    ...     iperf_port=${port}

################################## STEP6: UE DETACH ##################################
Dingli.UE Detach
    [Arguments]    ${ue_alias}=UE_${0}
    [Documentation]    This kw is used to dettach UE with dingli.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_type | no | The type of target UE, given in lowercase. E.G  huawei / Huawei.sigspark |
    ...    | ue_index | no | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | ue_alias | no | <str> store ue by ue_alias |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Dingli.UE Detach | ue_alias=UE_${0} |
    ...
    spark.detach_ue    ue_alias=${ue_alias}

################################## STEP6: power on ##################################
Dingli.UE power on
    [Arguments]    ${ue_alias}=UE_${0}
    [Documentation]    This kw is used to power on UE with dingli.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_alias | no | <str> store ue by ue_alias |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Dingli.UE power on | ue_alias=UE_${0} |
    ...
    spark.power_on    ue_alias=${ue_alias}

################################## STEP6: power off ##################################
Dingli.UE power off
    [Arguments]    ${ue_alias}=UE_${0}
    [Documentation]    This kw is used to power off UE with dingli.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_alias | no | <str> store ue by ue_alias |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Dingli.UE power off | ue_alias=UE_${0} |
    ...
    spark.power_off    ue_alias=${ue_alias}
    Sleep    60s

################################## STEP6: start log##################################
Dingli.start log
    [Arguments]    ${ue_alias}=UE_${0}
    [Documentation]    This kw is used to start log with dingli.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_alias | no | <str> store ue by ue_alias |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Dingli.start log | ue_alias=UE_${0} |
    ...
    spark.start_log    ue_alias=${ue_alias}

################################## STEP6: stop log##################################
Dingli.stop log
    [Arguments]    ${ue_alias}=UE_${0}    ${logname}=UE_LOG.xml
    [Documentation]    This kw is used to stop log with dingli.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_alias | no | <str> store ue by ue_alias |
    ...    | logname | no | define log name |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Dingli.stop log | ue_alias=UE_${0} | logname=${logname} |
    ...
    spark.stop_log    ue_alias=${ue_alias}    logname=${logname}

################################## STEP2: UE ATTACH ##################################
Dingli.UE Attach1
    [Arguments]    ${ue_alias}=UE_${0}    ${attach_mode}=5G_SA
    [Documentation]    This kw is used to attach UE with dingli.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_alias | no | <str> store ue by ue_alias |
    ...    | attach_mode | 5G_SA/5G_NSA |
    ...
    ...    | Return Value | Description |
    ...    | ${attach_res} | return attach_res |
    ...
    ...    Example
    ...    | Dingli.UE Attach1 | ${ue_alias} |
    ...
    ${attach_res}    spark.attach_ue    ue_alias=${ue_alias}    attach_mode=${attach_mode}
    [Return]    ${attach_res}

Dingli.Get UE IP address
    [Arguments]    ${ue_alias}=UE_${0}    ${apn}=wap1.nokia.com
    [Documentation]    This kw is used to Get UE IP address
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | no | he list index from tl.ues[], it will use the index UE for reserve |
    ...    | apn | no | define which apn is used for your UE |
    ...
    ...    | Return Value | Description |
    ...    | ${UE_IP} | return UE ip address |
    ...
    ...    Example
    ...    | Dingli.Get UE IP address | ue_alias=UE_${ue_index} | apn=${apn} |
    ...
    ${UE_IP}    get_pdu_ip    ue_alias=${ue_alias}    apn=${apn}
    #${UE_IP}     create_pdu_session    ue_alias=${ue_alias}    apn=${apn}
    [Return]    ${UE_IP}

Dingli.teardown
    [Arguments]    ${ue_alias}=UE_${0}
    [Documentation]    This kw is used to stop log with dingli.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_alias | no | <str> store ue by ue_alias |
    ...    | logname | no | define log name |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Dingli.stop log | ue_alias=UE_${0} | logname=${logname} |
    ...
    spark.teardown    ue_alias=${ue_alias}

Dingli Tput
    [Arguments]     ${ue_index}    ${cell_info}
    ...        ${dl_exp}    ${ul_exp}
    ...        ${buffer_size}=1400   ${actual_rate}=0.9
    Log    ${buffer_size}
    ${dl_port}    others.Get Udp Port     DL
    ${ul_port}    others.Get Udp Port     UL
    ${apn}     Set Variable     ${MATCHED_UE_INFO["APN"]}
    ${data_transfer_ul}    evaluate     int(${ul_exp})+5
    ${data_transfer_dl}    evaluate     int(${dl_exp})+10

    ${ul}      evaluate   float(${ul_exp}*${actual_rate})
    ${dl}      evaluate   float(${dl_exp}*${actual_rate})


    ${pci}    Set Variable     ${cell_info["phyCellId"]}
    ${bts_id}   Set Variable    ${cell_info["btsId"]}

    ${iperf_pc_info}=    Create List    ${iperf_server_ip}    ${iperf_server_username}
    ...                                 ${iperf_server_password}    22
    ${reset}    Get Variable Value    ${MATCHED_UE_INFO["RESET"]}    ${False}

    Dingli.Prepare UE    ue_alias=UE_${ue_index}     reset_app=${reset}
    #Dingli.start log     ue_alias=UE_${ue_index}
    Dingli.UE Attach    ue_alias=UE_${ue_index}


    Wait Until Keyword Succeeds    2min    30 sec
    ...      Dingli.Get Attach Status    bts_id=${bts_id}    pci=${pci}     ue_alias=UE_${ue_index}

    ${ue_ip}      Dingli.Get UE IP address       ue_alias=UE_${ue_index}    apn=${apn}

    Dingli.Start traffic      direction=ul    duration=1200    throughput=${data_transfer_ul}Mbits/sec
    ...            ue_index=${ue_index}
    ...            ue_alias=UE_${ue_index}    dt_name=UL Test
    ...            iperf_port=${ul_port}    protocal=UDP
    ...            connection_type=app     apn=${apn}

    siso_data.Start UDP Iperf Client    ${iperf_pc_info}    ${ue_ip}    ${dl_port}
    ...     band_width=${data_transfer_dl}M     bind_host=${iperf_server_network_interface}
    ...     ttl=64     duration=1200    alias=dl_cli

    Sleep    5s
    Dingli.Check throughput     ue_alias=UE_${ue_index}    ul=${ul}     dl=${dl}     during=120

    [Teardown]     Run Keywords    Dingli.Stop traffic     direction=ul       ue_alias=UE_${ue_index}
    ...     dt_name=upload          ue_index=${ue_index}     iperf_port=${ul_port}      AND
    ...     siso_data.Stop Iperf Client    ${iperf_pc_info}    ${dl_port}    alias=dl_client   AND
    ...     Dingli.teardown     ue_alias=UE_${ue_index}

Dingli L3call
    [Arguments]     ${ue_index}    ${cell_info}

    ${apn}     Set Variable     ${MATCHED_UE_INFO["APN"]}


    ${pci}    Set Variable     ${cell_info["phyCellId"]}
    ${bts_id}   Set Variable    ${cell_info["btsId"]}

    ${iperf_pc_info}=    Create List    ${iperf_server_ip}    ${iperf_server_username}
    ...                                 ${iperf_server_password}    22

    ${reset}    Get Variable Value    ${MATCHED_UE_INFO["RESET"]}    ${False}

    Dingli.Prepare UE    ue_alias=UE_${ue_index}     reset_app=${reset}

    Dingli.UE Attach    ue_alias=UE_${ue_index}
    Wait Until Keyword Succeeds    2min    30 sec
    ...      Dingli.Get Attach Status    bts_id=${bts_id}    pci=${pci}     ue_alias=UE_${ue_index}

    ${ue_ip}      Dingli.Get UE IP address       ue_alias=UE_${ue_index}    apn=${apn}

    [Teardown]     Dingli.teardown     ue_alias=UE_${ue_index}
Get all Huawei P40 pointer variable
    Set Suite Variable    ${home}    82
    Set Suite Variable    ${airplane}    1088 446
    Set Suite Variable    ${close_task}    580 2140
    Set Suite Variable    ${Home_button}    82
    Set Suite Variable    ${swipe}    500 2050 500 800
    Set Suite Variable    ${open_iperf_location}    500 2050
    Set Suite Variable    ${iperf_button}    708 408
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${5G}    960 850

Get all Samsung S21 pointer variable
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    960 350
    Set Suite Variable    ${close_task}    535 1755
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    500 2050 500 800
    Set Suite Variable    ${open_iperf_location}    480 860
    Set Suite Variable    ${iperf_button}    724 388
    Set Suite Variable    ${iperf_space}    800 550

Redefine Poniter Variable
    [Arguments]    ${sub_model}
    Run Keyword If    '${sub_model}'=='Huawei P40'    Get all Huawei P40 pointer variable
    Run Keyword If    '${sub_model}'=='Samsung S21'    Get all Samsung S21 pointer variable

Taf Android L3call
    [Arguments]     ${ue_index}    ${require_attach_cell_id}

    ${reset_ret}    Run Keyword And Return Status    Variable Should Exist    ${MATCHED_UE_INFO["RESET"]}
    ${reset}    Run Keyword If    ${reset_ret}    Set Variable    ${MATCHED_UE_INFO["RESET"]}
    ...    ELSE    Set Variable    none
    Run keyword and ignore error    andriod_phone.Prepare UE  ue_index=${ue_index}  reset_sol=${reset}

#    ${5Grach_ed}     wait until keyword succeeds     5min     5s     default_andriod_phone.UE Attach
#    ...    ue_index=${ue_index}
    Wait Until Keyword Succeeds    30 sec    10 sec    andriod_phone.UE Attach
    ...    require_attach_cell_id=${require_attach_cell_id}    ue_index=${ue_index}

    andriod_phone.Verify attach    require_attach_cell_id=${require_attach_cell_id}    ue_index=${ue_index}
    [Teardown]    Run Keyword And Ignore Error     andriod_phone.UE Detach
    ...    ue_index=${ue_index}

Taf Android Tput
    [Arguments]     ${ue_index}    ${require_attach_cell_id}
    ...        ${dl_exp}    ${ul_exp}    ${deviation}=5%

    ${dl_port}    others.Get Udp Port     DL
    ${ul_port}    others.Get Udp Port     UL

    ${data_transfer_ul}    evaluate     int(${ul_exp})+1
    ${data_transfer_dl}    evaluate     int(${dl_exp})+10

    ${reset_ret}    Run Keyword And Return Status    Variable Should Exist    ${MATCHED_UE_INFO["RESET"]}
    ${reset}    Run Keyword If    ${reset_ret}    Set Variable    ${MATCHED_UE_INFO["RESET"]}
    ...    ELSE    Set Variable    none
    Run keyword and ignore error    andriod_phone.Prepare UE  ue_index=${ue_index}  reset_sol=${reset}

    Wait Until Keyword Succeeds    60 sec    10 sec    andriod_phone.UE Attach
    ...    require_attach_cell_id=${require_attach_cell_id}    ue_index=${ue_index}

    andriod_phone.Verify attach    require_attach_cell_id=${require_attach_cell_id}    ue_index=${ue_index}

    ${hour}    ${min}    ${sec}    Get Time    hour min sec

    ${time_stamp}   Set Variable    ${hour}_${min}_${sec}
    andriod_phone.Start traffic    require_attach_cell_id=${require_attach_cell_id}
    ...     ue_index=${ue_index}    direction=ul     throughput=${data_transfer_ul}Mbits/sec    tag=${time_stamp}
    ...    duration=30s     iperf_port=${ul_port}     dt_name=dt_ul
    andriod_phone.Start traffic    require_attach_cell_id=${require_attach_cell_id}
    ...    ue_index=${ue_index}
    ...    direction=dl     throughput=${data_transfer_dl}Mbits/sec    tag=${time_stamp}
    ...    duration=30s     iperf_port=${dl_port}     dt_name=dt_dl
    Sleep    3s
    andriod_phone.Check Peak Throughput    total_time=60    theory_dl_peak=${dl_exp}    tag=${time_stamp}
    ...    require_attach_cell_id=${require_attach_cell_id}    theory_ul_peak=${ul_exp}    interval=10
    ...    duration_time_for_once=30s
    ...    acceptable_tput_percentage=${deviation}

    [Teardown]    andriod_phone.UE Detach    ue_index=${ue_index}

Taf Android CA Tput
    [Arguments]     ${ue_index}    ${require_attach_cell_ids}
    ...        ${dl_exp}    ${ul_exp}    ${deviation}=5%

    ${dl_port}    others.Get Udp Port     DL
    ${ul_port}    others.Get Udp Port     UL

    ${data_transfer_ul}    evaluate     int(${ul_exp})+1
    ${data_transfer_dl}    evaluate     int(${dl_exp})+10

    ${reset_ret}    Run Keyword And Return Status    Variable Should Exist    ${MATCHED_UE_INFO["RESET"]}
    ${reset}    Run Keyword If    ${reset_ret}    Set Variable    ${MATCHED_UE_INFO["RESET"]}
    ...    ELSE    Set Variable    none
    Run keyword and ignore error    andriod_phone.Prepare UE  ue_index=${ue_index}  reset_sol=${reset}

    Wait Until Keyword Succeeds    60 sec    10 sec    andriod_phone.UE CA Attach
    ...    require_attach_cell_ids=${require_attach_cell_ids}    ue_index=${ue_index}

    ${cell_id}     andriod_phone.Verify CA Attach    require_attach_cell_ids=${require_attach_cell_ids}    ue_index=${ue_index}

    ${hour}    ${min}    ${sec}    Get Time    hour min sec

    ${time_stamp}   Set Variable    ${hour}_${min}_${sec}
    andriod_phone.Start traffic    require_attach_cell_id=${cell_id}
    ...     ue_index=${ue_index}    direction=ul     throughput=${data_transfer_ul}Mbits/sec    tag=${time_stamp}
    ...    duration=30s     iperf_port=${ul_port}     dt_name=dt_ul
    andriod_phone.Start traffic    require_attach_cell_id=${cell_id}
    ...    ue_index=${ue_index}
    ...    direction=dl     throughput=${data_transfer_dl}Mbits/sec    tag=${time_stamp}
    ...    duration=30s     iperf_port=${dl_port}     dt_name=dt_dl
    Sleep    3s
    andriod_phone.Check Peak Throughput    total_time=60    theory_dl_peak=${dl_exp}    tag=${time_stamp}
    ...    require_attach_cell_id=${cell_id}    theory_ul_peak=${ul_exp}    interval=10
    ...    duration_time_for_once=30s
    ...    acceptable_tput_percentage=${deviation}

    [Teardown]    andriod_phone.UE Detach    ue_index=${ue_index}

Make L3 Call And Run Throughput For One Time
    [Arguments]     ${ue_index}    ${cell_index}     ${gnb_ssl_connection}
    ...        ${dl_exp}    ${ul_exp}
    ...        ${buffer_size}=1400   ${actual_rate}=0.7
    ...    ${band}=${EMPTY}    ${iperf_type}=${IPERF_TYPE}
    Log    ${band}
    ${dl_port}    others.Get Udp Port     DL
    ${ul_port}    others.Get Udp Port     UL

    ${data_transfer_ul}    evaluate     int(${ul_exp})+5
    ${data_transfer_dl}    evaluate     int(${dl_exp})+10

#    ${ue_type}     ue.translate_power_ue_type_from_testline     ue_index=${ue_index}
    ${ue_type}    Set Variable     ${MATCHED_UE_INFO["MODEL"]}
    Run Keyword If     '${ue_type}'=='huawei'    Get product brand   ${ue_index}

#    ${yml_index}    Run Keyword And Return Status    Variable Should Exist    ${MATCHED_UE_INFO["INDEX"]}
    ${reset_ret}    Run Keyword And Return Status    Variable Should Exist    ${MATCHED_UE_INFO["RESET"]}
    ${reset}    Run Keyword If    ${reset_ret}    Set Variable    ${MATCHED_UE_INFO["RESET"]}
    ...    ELSE    Set Variable    none
    Run Keyword If    '${ue_type}'=='samsung' and '${reset}'=='TRUE'    Andriod UE adb reboot    ${ue_index}
    Run Keyword If    '${ue_type}'=='nokia_cpe'    Remove Known File In Ue Control PC    ${ue_index}
    Run keyword and ignore error   power_ue.Prepare UE  ue_index=${ue_index}  ue_type=${ue_type}  reset_sol=${reset}
    ${need_wait}    Run Keyword And Return Status    Variable Should Exist    ${MATCHED_UE_INFO["WAIT_UE"]}
    Run Keyword If     '${ue_type}'=='askey' and "${need_wait}"=="True"    sleep    ${MATCHED_UE_INFO["WAIT_UE"]}
    Run Keyword If     '${ue_type}'=='huawei' or '${ue_type}'=='samsung'   Redefine Poniter Variable    ${MATCHED_UE_INFO["SUB_MODEL"]}
    #power_ue.UE Attach     ue_index=${ue_index}    ue_type=${ue_type}
    #Lock UE Band    ue_index=${ue_index}     ue_type=${ue_type}    band=${band}
    ${5Grach_ed}     wait until keyword succeeds     5min     5s     power_ue.UE Attach     ue_type=${ue_type}
    ...    ue_index=${ue_index}
    Run keyword and ignore error     power_ue.Verify attach     ue_type=${ue_type}    ue_index=${ue_index}
    ...    4G_check=False     5Grach_ed=${5Grach_ed}
    Run Keyword And Continue On Failure    power_ue.Start traffic
    ...    ue_type=${ue_type}     ue_index=${ue_index}    direction=ul     throughput=${data_transfer_ul}M
    ...    duration=1200     iperf_port=${ul_port}     buffer_size=${buffer_size}     dt_name=dt_ul    iperf_type=${iperf_type}
    Run Keyword And Continue On Failure    power_ue.Start traffic     ue_type=${ue_type}     ue_index=${ue_index}
    ...     direction=dl     throughput=${data_transfer_dl}M
    ...     duration=1200     iperf_port=${dl_port}     buffer_size=${buffer_size}     dt_name=dt_dl    iperf_type=${iperf_type}
    Sleep   3s
    Run Keyword If     '${ue_type}'=='askey'   Sleep    12s
    power_ue.Check Peak Throughput    ue_type=${ue_type}    total_time=60    theory_dl_peak=${dl_exp}
    ...    theory_ul_peak=${ul_exp}    interval=10    duration_time_for_once=60s    nr_cell_index=${cell_index}
    ...    acceptable_tput_percentage=${actual_rate}    is_need_to_capture_log=${False}
    ...    gnb_ssl_connection=${gnb_ssl_connection}
    #power_ue.Stop traffic     ue_type=${ue_type}     ue_index=${ue_index}    direction=ul     iperf_port=${ul_port}
    #power_ue.Stop traffic     ue_type=${ue_type}     ue_index=${ue_index}     direction=dl     iperf_port=${dl_port}
    power_ue.UE Detach     ue_type=${ue_type}    ue_index=${ue_index}
    [Teardown]    Run Keywords    Recover Syslog Configuration    AND
    ...    power_ue.Stop traffic     ue_type=${ue_type}
    ...    ue_index=${ue_index}    direction=ul     iperf_port=${ul_port}    AND
    ...    power_ue.Stop traffic     ue_type=${ue_type}
    ...    ue_index=${ue_index}    direction=dl     iperf_port=${dl_port}    AND
    ...    Run Keyword And Ignore Error     power_ue.Teardown UE     ue_type=${ue_type}
    ...    ue_index=${ue_index}

Make L3 Call And Run Throughput
    [Arguments]     ${ue_index}    ${cell_index}     ${gnb_ssl_connection}
    ...        ${dl_exp}    ${ul_exp}   ${try_count}
    ...        ${buffer_size}=1400   ${actual_rate}=0.7
    ...    ${band}=${EMPTY}
    Log    ${try_count}
    Log    ${buffer_size}
    Log    ${actual_rate}
#    ${try_loop_count}   Evaluate    ${try_count}+1
#
#    ${try_loop_count}    Set Variable If    '${try_count}'!='1'    ${try_loop_count}
    FOR   ${index}   IN RANGE    ${1}
        ${status}    Run Keyword And Return Status    Make L3 Call And Run Throughput For One Time
        ...    ue_index=${ue_index}    cell_index=${cell_index}
        ...    gnb_ssl_connection=${gnb_ssl_connection}    dl_exp=${dl_exp}    ul_exp=${ul_exp}
        ...    band=${band}
        Exit For Loop If    ${status}
    END

    Should Be True    ${status}

Recover Syslog Configuration
     [Arguments]    ${gnb_index}=${0}     ${aa_sys_mode}=5    ${aa_sys_addr}=0xC0A8FF7E
     ...     ${aa_sys_udp_port}=0xC738
     Aasyslog precondition    gnb_index=${gnb_index}    aa_sys_mode=${aa_sys_mode}
     ...     aa_sys_addr=${aa_sys_addr}     aa_sys_udp_port=${aa_sys_udp_port}

