*** Settings ***
Documentation
...    author: Rebecca.Liu & criscai
...    contact:jia-rebecca.liu@nokia-sbell.com
...    squad group: SG_03
...    feature : 5GC000470-O 5GC000519

Library    OperatingSystem
Library    Collections
Library    String
Library    BuiltIn
Library    DateTime
Library    taf.transport.ssh    WITH NAME    csn
Library    taf.sbts.oam.coam.admin   WITH NAME    wmplte
Library    taf.transport.ssh                 WITH NAME       ssh
Library    taf.config.scf    WITH NAME    scf
#Library    taf.analyzer.pcap
Library     taf.rfrl.common_resources.python.SWConfig
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    taf/rfrl/common_resources/robot/gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot


*** Variables ***
${WEBUI_COAM}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_NAME}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${ENB_ADDRESS}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${asik_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asik_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${TestPC_addr}    ${tl.test_pc.default_ssh_connection_details.addr}
${TestPC_username}    ${tl.test_pc.default_ssh_connection_details.username}
${TestPC_password}    ${tl.test_pc.default_ssh_connection_details.password}
${gnb0_BTS_host}             ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${gnb_BTS_username}          ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gnb_BTS_password}          ${tl.gnbs[0].cu.oam_http_connection_details.password}
${gnb_path}    /tmp/
${APPserver_username}    root
${APPserver_password}    APPpass
${iperf_path}    /cygdrive/c/iperf
${tl_scf_filename}    Full_Configuration_scf_TL232.xml
${tl_scf_filename_EIF2}    Full_Configuration_scf_TL232_EIF2.xml
${enbx2_dist}    MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNADJGNB-0
${enbx2_para}    administrativeState
${test_path}    /home/ute/SQ3project/
${epc_log_path}    /home/ute/SQ3project/
${f1_sctp_port}    38472
${x2_sctp_port}    36422
${gnb_instance}    ${tl.gnbs[0].instance_id}
${gnb_dist}    MRBTS-${gnb_instance}/NRBTS-${gnb_instance}
${enb_instance}    ${tl.enbs[0].instance_id}
${QPSTexe}    "/cygdrive/c/Program Files (x86)/Qualcomm/QPST/bin/QPSTConfig.exe"
${enb_path}    /user/toor4nsn
${MAX_WAIT_TIME_COAM_CONFIGURED}     10 min
${Retry_interval_COAM_CONFIGURED}     30 s

*** Keywords ***

##BTS keyword
Start To Capture Wireshark Logs
    [Arguments]     ${filename}    ${connection}    ${interface}
    csn.send command    command=tcpdump sctp -i ${interface} -w ${gnb_path}${filename}   connection=${connection}

gNB connections
    csn.Connect To    hostname=${asik_addr}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=gnb
TestPC connections
    csn.Connect To    hostname=${TestPC_addr}
    ...               username=${TestPC_username}
    ...               password=${TestPC_password}
    ...               alias=TestPC

eNB connections
    csn.Connect To    hostname=${ENB_ADDRESS}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=enb

Stop and download Logs
    [Arguments]    ${logname}    ${connection}
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    3
    csn.download_file   ${gnb_path}${logname}   ${epc_log_path}${logname}   connection=${connection}
    sleep    3

Check the gnb cell status onair
    selenium_coam.enable_virtual_display
    wait until keyword succeeds    5min   30s    selenium_coam.login    ${WEBUI_COAM}    ${WEBUI_NAME}    ${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${cell_status} =    selenium_coam.get_cell_info
    sleep    8s
    selenium_coam.logout
    5GC000519_coam_common_keywords.Get info status check    ${cell_status}

Get info status check
    [Arguments]    ${info_status}
    ${Status} =    get from dictionary    ${info_status}    Status
    ${opr_state} =   get from dictionary    ${status}    Operational state
    should be equal    ${opr_state}    Enabled
    ${avi_state} =   get from dictionary    ${status}   Availability status
    should be equal    ${avi_state}    Online
    ${adm_state} =   get from dictionary    ${status}    Administrative state
    should be equal    ${adm_state}    Unlocked

Check gnb COAM classical start normally
    [Arguments]    ${bts_host}=${gnb_BTS_host}    ${username}=${gnb_BTS_username}
    ...    ${password}=${gnb_BTS_password}
#    Check Airscale HW module status
    #wait until keyword succeeds    10min   30s    Check the sctp port UP    ${f1_sctp_port}
#    sleep    5s
    #Check the gnb RU status ready
#    wait until keyword succeeds    10min   30s    Check the sctp port UP    ${x2_sctp_port}
    COAM Wait for gnb ready    bts_host=${bts_host}    username=${username}    password=${password}
    Wait Until Keyword Succeeds     10min     30s     5GC000519_coam_common_keywords.COAM Check GNB cell on air

COAM Wait for gnb ready
    [Documentation]
    ...              Description: Wait until GNB status ready.
    [Timeout]  30 min
    [Arguments]  ${timeout}=10 min    ${connection}=GNB_OAM    ${bts_host}=${bts_host}    ${username}=${username}    ${password}=${password}
    Wait until keyword succeeds    ${timeout}    20 sec    Connect to gnb coam via ssl    connection=${connection}
    ...                    bts_host=${bts_host}
    ...                    username=${username}
    ...                    password=${password}
    Wait until keyword succeeds    ${timeout}    20 sec    COAM Check GNB ABIL status    connection=${connection}
    Wait until keyword succeeds    ${timeout}    20 sec    COAM Check GNB ASIK status    connection=${connection}
    Wait until keyword succeeds    ${timeout}    20 sec    COAM Check GNB RU status    connection=${connection}

COAM Check GNB cell on air
    [Documentation]
    ...              Description: Check if GNB is in cell on air status
    [Arguments]    ${connection}=GNB_OAM
    ${bts_status}    coam.get_bts_statuses    connection=${connection}
    ${gnb_cell_status}    Set variable  ${bts_status['proceduralState']}
    Should be equal as strings    ${gnb_cell_status}    OnAir    msg=GNB is not on air, Current status is ${gnb_cell_status}
    ...                      ignore_case=${True}

Check the sctp port UP
    [Arguments]    ${port_num}
    Connect to BB1 master    alias=BB1
    ssh.sendCommand    command=netstat -anl |grep sctp    connection=BB1
    sleep    3s
    ${sctp_status} =    ssh.read_output    connection=BB1
    ssh.disconnect     connection=BB1
    should contain     ${sctp_status}     ${port_num}

Check the gnb RU status ready
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${ru_status} =    selenium_coam.get_ru_info
    sleep    8s
    selenium_coam.logout
    5GC000519_coam_common_keywords.Get info status check    ${ru_status}

Perform full commission for COAM gnb
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.load_commissioning_file_and_check_load_status    ${tl_scf_dir_path}${tl_scf_filename}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    8s
    selenium_coam.logout
    sleep    1min

Prepare the classical COAM BTS cell onair
    ${cell_status}    ${cell_value} =    Run Keyword And Ignore Error    Prepare with COAM classical BTS cell onair
    set suite variable    ${cell_status}

Prepare with COAM classical BTS cell onair
    5GC000519_coam_common_keywords.Perform full commission for COAM gnb
    Precondition for UE Control PC
    sleep    5min
    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=locked
    5GC000519_coam_common_keywords.Check gnb COAM classical start normally
    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=unlocked
    sleep    5min
    5GC000519_coam_common_keywords.Check the gnb cell status onair

##Iperf server
Common Suite Setup for COAM 519
    COAM Create log directory    ${False}
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}/${time_stamp}/
    Create directory    ${epc_log_path}

Common Suite Setup for COAM
    COAM Create log directory    ${False}
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}/${time_stamp}/
    Create directory    ${epc_log_path}

Common Suite Teardown for COAM
    Connect to gnb coam via ssl
    COAM Download scf from cluster    scf_dir_path=${epc_log_path}
    COAM Save snapshot via rest api    log_path=${epc_log_path}
    COAM Teardown gnb connections
    CI_interface.Common Case Teardown

Close iperf progress
    [Arguments]    ${ue_index}=${0}    ${dl_port}=${dl_port}    ${ul_port}=${ul_port}
    Close the iperf process on APPserver    ${dl_port}
    Close the iperf process on APPserver    ${ul_port}
    Close the iperf process on Qualcomm    ${ue_index}

Precondition for UE control PC
    [Arguments]    ${ue_num}=1
    FOR    ${i}    IN RANGE    0    ${ue_num}
        Reset UE Control PC    ue_index=${i}
    END

##ENB Keyword
Start To Capture ENB Logs
    [Arguments]     ${filename}  ${connection}=ENB
    wait until keyword succeeds    5 min    10 sec    Connect to ENB    alias=ENB
    csn.send command    command=tcpdump -i br1 -w ${enb_path}${filename}   connection=${connection}

Stop and download ENB Logs
    [Arguments]     ${filename}=enblog.pcap  ${connection}=ENB
    wait until keyword succeeds    5 min    10 sec    Connect to ENB    alias=ENB
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    5
    csn.download_file   ${enb_path}${filename}   ${epc_log_path}${filename}   connection=${connection}

Connect to local master
    [Arguments]    ${alias}=Local gNB
    csn.Connect to    hostname=${LOCAL_MASTER_IP}
    ...    username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...    alias=${alias}

Remove lists From Scf
    [Arguments]    ${input_scf}    ${output_scf}    ${parameters_lists}
    scf.Load Scf    ${input_scf}
    FOR    ${item}    IN    @{parameters_lists}
        scf.remove list from scf    dist_name=${item}[dist_name]    list_name=${item}[list_name]
    END
    scf.Save Scf    ${output_scf}

Remove Elements From Scf
    [Arguments]    ${input_scf}    ${output_scf}    ${parameters_lists}
    scf.Load Scf    ${input_scf}
    FOR    ${parameters_list}    IN    @{parameters_lists}
        scf.Remove Element From Scf    &{parameters_list}
    END
    scf.Save Scf    ${output_scf}

Add objects to scf
    [Arguments]    ${input_scf}    ${output_scf}    ${parameters_lists}
    scf.Load scf    ${input_scf}
    FOR    ${item}    IN    @{parameters_lists}
        scf.add object to scf  class_name=${item}[class_name]    dist_name=${item}[dist_name]   version=${item}[version]
    END
    scf.Save scf    ${output_scf}

Add elements to object
    [Arguments]    ${input_scf}    ${output_scf}    ${parameters_lists}
    scf.Load scf    ${input_scf}
    FOR    ${item}    IN    @{parameters_lists}
        scf.add element to scf  dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    scf.Save scf    ${output_scf}

Add lists to object
    [Arguments]    ${input_scf}    ${output_scf}    ${parameters_lists}
    scf.Load scf    ${input_scf}
    FOR    ${item}    IN    @{parameters_lists}
        scf.add list to scf  dist_name=${item}[dist_name]   list_name=${item}[list_name]
    END
    scf.Save scf    ${output_scf}

Add items to list
    [Arguments]    ${input_scf}    ${output_scf}    ${parameters_lists}
    scf.Load scf    ${input_scf}
    FOR    ${item}    IN    @{parameters_lists}
        scf.add item to list  dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    scf.Save scf    ${output_scf}

Add elements to list
    [Arguments]    ${input_scf}    ${output_scf}    ${parameters_lists}
    scf.Load scf    ${input_scf}
    FOR    ${item}    IN    @{parameters_lists}
        scf.add elements to list  dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    scf.Save scf    ${output_scf}

disconect all connections
    run keyword and ignore error    csn.disconnect    connection=TestPC
    sleep    8s
    run keyword and ignore error    selenium_coam.logout
    csn.disconnect    connection=gnb
    csn.disconnect    connection=enb

killall firefox progress
    TestPC connections
    csn.send command    command=killall firefox    connection=TestPC
    csn.send command    command=killall Xvfb    connection=TestPC
    csn.disconnect    connection=TestPC
    sleep    10s

Suite Recover
    killall firefox progress
    CI_interface.Common Case Teardown

Tests Recover
    disconect all connections
    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=unlocked
    active chaining feature tag
    disconect all connections

Restart gNB on webUI
    selenium_coam.enable_virtual_display
    selenium_coam.login    ${WEBUI_COAM}    ${WEBUI_NAME}    ${WEBUI_PWD}
    selenium_coam.reset_site
    sleep    8s
    Run Keyword And Ignore Error    selenium_coam.logout

Tests Recover for SA
    killall firefox progress
    disconect all connections for SA

disconect all connections for SA
    run keyword and ignore error    csn.disconnect    connection=TestPC
    sleep    8s
    run keyword and ignore error    selenium_coam.logout
    run keyword and ignore error    csn.disconnect    connection=ENB
    run keyword and ignore error    csn.disconnect    connection=GNB
    run keyword and ignore error    csn.disconnect    connection=enb
    run keyword and ignore error    csn.disconnect    connection=gnb


Check gnb COAM classical start normally for SA
    #Check Airscale HW module status
    #wait until keyword succeeds    ${MAX_WAIT_TIME_COAM_CONFIGURED}     ${Retry_interval_COAM_CONFIGURED}
    #...     Check The Sctp Port UP    port_num=${f1_sctp_port}
    sleep    time_=315s

Prepare the classical COAM BTS cell onair for SA
    [Arguments]    ${scf_file}    ${bts_host}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ${cell_status}    ${cell_value} =    Run Keyword And Ignore Error    Perform full commission for COAM gnb with scf file
    ...    scf_file=${scf_file}    bts_host=${bts_host}
    set suite variable    ${cell_status}

Perform full commission for COAM gnb with scf file
    [Arguments]    ${scf_file}    ${bts_host}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    Connect to gnb coam via ssl    bts_host=${bts_host}
    COAM Commission with scf file    scf_file_path=${scf_file}    timeout=600     is_pdl_checking_needed=${False}
    COAM Teardown gnb connections

Backup wireshark Files
    [Arguments]     ${connection}    ${wireshark_log_path}
    ${current_time}=   Get Current Date
    ${converted_date}=    Convert Date    date=${current_time}     result_format=%Y%m%d%H%M%S
    TestPC connections
    csn.send command    command=zip ${wireshark_log_path}pcap_files_${converted_date}.zip ${wireshark_log_path}*.pcap
    ...                 connection=${connection}
    sleep    time_=15s

Send traffic from testcenter
    [Arguments]     ${connection}    ${testcenter_tclfile}
    TestPC connections
    csn.send command    command=sudo tclsh ${testcenter_tclfile}    connection=${connection}

Prepare with COAM BTS cell onair with scf
    [Arguments]    ${scf_file}
    Perform full commission for COAM gnb with scf file    scf_file=${scf_file}
    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=locked
    5GC000519_coam_common_keywords.Check gnb COAM classical start normally
    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=unlocked
    wait until keyword succeeds    10min    30s     5GC000519_coam_common_keywords.Check the gnb cell status onair

Prepare with BTS cell onair with scf
    [Arguments]    ${scf_file}
    ${cell_status}    ${cell_value} =    Run Keyword And Ignore Error
    ...                                  Prepare with COAM BTS cell onair with scf    scf_file=${scf_file}
    set suite variable    ${cell_status}

Perform gNB Cell Lock
    [Documentation]   Auther:jack.zeng@nokia-sbell.com
    [Arguments]    ${cell_idx}=${1}    ${download_dir}=${test_path}
    ...            ${gNB_id}=${0}
    ${cell_idx}  Convert To Integer    ${cell_idx}
    ${gNB_id}  Convert To Integer    ${gNB_id}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${tl.gnbs[${gNB_id}].cu.oam_http_connection_details.addr}
    ...                    username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...                    password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...                    download_dir=${download_dir}
    selenium_coam.disable_message_box
    selenium_coam.lock_cell    cell_idx=${cell_idx}
    Sleep   30 sec
    [Teardown]  selenium_coam.logout

Perform gNB Cell Unlock
    [Documentation]   Auther:jack.zeng@nokia-sbell.com
    [Arguments]    ${cell_idx}=${1}    ${download_dir}=${test_path}
    ...            ${gNB_id}=${0}
    ${cell_idx}  Convert To Integer    ${cell_idx}
    ${gNB_id}  Convert To Integer    ${gNB_id}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${tl.gnbs[${gNB_id}].cu.oam_http_connection_details.addr}
    ...                    username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...                    password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...                    download_dir=${download_dir}
    selenium_coam.disable_message_box
    selenium_coam.unlock_cell    cell_idx=${cell_idx}
    Sleep   30 sec
    [Teardown]  selenium_coam.logout

Change android UE 5Gstatus to
    [Documentation]   Verify 4G UE network type normal by ADB command.
    [Arguments]    ${5Gstatus}     ${ue_index}=${0}    ${sleep_time_before_read_output}=${None}
    Preparation and execution for Commercial UE Attach
    sleep    20s
    ${SN} =    set variable    ${tl.ues[${ue_index}].serial_number}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.send command
    ...    command=adb -s ${SN} shell getprop gsm.network.type
    ...    connection=cpc_${ue_index}
    ...    timeout=5
    run keyword if    '${sleep_time_before_read_output}'!='${None}'    sleep    ${sleep_time_before_read_output}
    ${result} =    csn.read output    connection=cpc_${ue_index}
    csn.disconnect   connection=cpc_${ue_index}
    sleep    30s
    ${Is_5G_on}=    Run Keyword And Return Status    Should contain     container=${result}   item=NR
    run keyword if    '${Is_5G_on}'=='${True}' and '${5Gstatus}'=='Enabled'
    ...               Log    INFO:${UE_type} UE 5G status was already Enabled.
    ...    ELSE IF    '${Is_5G_on}'=='${True}' and '${5Gstatus}'=='Disabled'
    ...               Run Keywords    wait until keyword succeeds    5min    50s    make sure android UE 4G Attached
    ...               AND     Log to console    \nINFO:${UE_type} UE 4G Attached.
    ...    ELSE IF    '${Is_5G_on}'=='${False}' and '${5Gstatus}'=='Disabled'
    ...               Log to console    \nINFO:${UE_type} UE 5G status was already Disabled.
    ...    ELSE IF    '${Is_5G_on}'=='${False}' and '${5Gstatus}'=='Enabled'
    ...               Run Keywords    wait until keyword succeeds    5min    50s    make sure android UE 5G Attached
    ...               AND     Log to console    \nINFO:${UE_type} UE 5G Attached.
    ...    ELSE       Log to console    \nINFO:${UE_type} UE is abnormal.

make sure android UE 4G Attached
    Commercial UE click 5G once
    sleep    45s
    Verify 4G Attach by ADB Command

make sure android UE 5G Attached
    Commercial UE click 5G once
    sleep    45s
    Verify 5G Attach by ADB Command

Verify 5G Attach by ADB Command
    [Documentation]   Verify 5G UE network type normal by ADB command.
    [Arguments]    ${ue_index}=${0}    ${sleep_time_before_read_output}=${None}
    ${SN} =    set variable    ${tl.ues[${ue_index}].serial_number}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.send command
    ...    command=adb -s ${SN} shell getprop gsm.network.type
    ...    connection=cpc_${ue_index}
    ...    timeout=5
    run keyword if    '${sleep_time_before_read_output}'!='${None}'    sleep    ${sleep_time_before_read_output}
    ${result} =    csn.read output    connection=cpc_${ue_index}
    csn.disconnect   connection=cpc_${ue_index}
    Should contain    container=${result}   item=NR
    Log to console    \nINFO:5G UE ATTACH successfully.

unlocked LTE cell
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
    ...    parameter=administrativeState
    ...    value=unlocked
    sleep    10s

locked LTE cell
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
    ...    parameter=administrativeState
    ...    value=locked
    sleep    10s

make sure enb cell is on air
    Connect to eNB via ssl
    ${Is_Onair}=    Run Keyword And Return Status    Check enb status is in cell on air status
    run keyword if    '${Is_Onair}'=='${False}'    Run Keywords    unlocked LTE cell     AND
    ...                Wait until enb cell on air status

Precondition for power UE
    [Arguments]    ${ue_type}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    capatibility_index=${0}    reset_sol=pc_reset    detach_request=${true}

Attach and check power UE
    [Arguments]    ${ue_type}    ${5Gstatus}=PASS
     ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    5Gstatus=${5Gstatus}

Detach for power UE
    [Arguments]    ${ue_type}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}

##stream parameter##
Case variable set for ${case_key}
    test suite variable set for ${case_key}
#    Set Test Tag

test suite variable set for ${case_key}
    ${release_info}    Get sagnb release
    set suite variable    ${release_info}
    set suite variable    ${qc_id}    ${para_store['${case_key}']['${release_info}']['qc_id']}
    set suite variable    ${scf_file}     ${para_store['${case_key}']['${release_info}']['scf_file']}
    set suite variable    ${vlan_id_100}     ${para_store['${case_key}']['${release_info}']['vlan_id_100']}
    set suite variable    ${vlan_id_1500}    ${para_store['${case_key}']['${release_info}']['vlan_id_1500']}
    set suite variable    ${vlan_id_1000}    ${para_store['${case_key}']['${release_info}']['vlan_id_1000']}
    set suite variable    ${vlan_id_2000}    ${para_store['${case_key}']['${release_info}']['vlan_id_2000']}
    set suite variable    ${vlan_id_2500}    ${para_store['${case_key}']['${release_info}']['vlan_id_2500']}
    set suite variable    ${vlan_ip_100}     ${para_store['${case_key}']['${release_info}']['vlan_ip_100']}
    set suite variable    ${vlan_ip_1500}    ${para_store['${case_key}']['${release_info}']['vlan_ip_1500']}
    set suite variable    ${vlan_ip_1000}    ${para_store['${case_key}']['${release_info}']['vlan_ip_1000']}
    set suite variable    ${vlan_ip_2000}    ${para_store['${case_key}']['${release_info}']['vlan_ip_2000']}
    set suite variable    ${vlan_ip_2500}    ${para_store['${case_key}']['${release_info}']['vlan_ip_2500']}
    set suite variable    ${not priority ip_E07}    ${para_store['${case_key}']['${release_info}']['not priority ip_E07']}
    set suite variable    ${priority ip_E07}           ${para_store['${case_key}']['${release_info}']['priority ip_E07']}
    set suite variable    ${not priority ip_E01}    ${para_store['${case_key}']['${release_info}']['not priority ip_E01']}
    set suite variable    ${priority ip_E01}           ${para_store['${case_key}']['${release_info}']['priority ip_E01']}
    set suite variable    ${testcenter_dscp}    ${para_store['${case_key}']['${release_info}']['testcenter_dscp']}
    set suite variable    ${testcenter_pcp}    ${para_store['${case_key}']['${release_info}']['testcenter_pcp']}


Get sagnb release
    [Arguments]   ${host}=${asik_addr}   ${username}=${asik_username}   ${password}=${asik_password}
    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
#    ${release_info}     set variable    ${info.split('_')[4]}
    ${release_info}     set variable    ${info.split('_')[1]}
    [Return]    ${release_info}
    [Teardown]   csn.Disconnect   connection=release_info
