*** Settings ***
Documentation     author: jiang johnny
...                 contact: johnny.1.jiang@nokia-sbell.com
...                 squad group: SG_07
...                 feature : 5GC002426

Library           OperatingSystem
Library           Collections
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.config.scf    WITH NAME    scf
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
#Library           taf.ul.oam.selenium_coam    WITH NAME    selenium_coam
Library           taf.ul.oam.selenium_megazone    WITH NAME    selenium_megazone
Resource          taf/rfrl/common_resources/robot/connections.robot
Resource          taf/rfrl/common_resources/robot/gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    ..${/}..${/}CB007105${/}resources${/}common.robot
Resource    ..${/}..${/}common${/}L3_Call.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/sigspark.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Library           taf.gnb.oam.coam.admin   WITH NAME    coam
Library           taf.analyzer.pcap   WITH NAME    parser
Library           taf.hw.rf_attenuator    WITH NAME    attenuator
Library    testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.sigspark.SigSpark    WITH NAME    spark
Library           taf.ue.plugin.mtk
Library           taf.ul.messaging.mtk      WITH NAME    mtk
Library           taf.collectors.btslog    WITH NAME   btslog
Library           taf.collectors.core   WITH NAME   core
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
Library           taf.hw.rf_attenuator    WITH NAME    att
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/siso_common.robot

*** Variables ***
${nrbts_id}=    NRBTS-${tl.gnbs[0].instance_id}
${BTS_ID}=    ${tl.gnbs[0].global_bts_id}
${plan_copy_from}=   CURRENT_BTS_CONF-1
${connection}    gnb
${LOCAL_MASTER_IP}    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_NAME}         ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}          ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_COAM}     https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${asik2_addr}    ${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
${WEBUI2_NAME}    ${tl.gnbs[1].cu.oam_http_connection_details.username}
${WEBUI2_PWD}     ${tl.gnbs[1].cu.oam_http_connection_details.password}
${bts_distname}      MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}
${LOG_PATH}             ${OUTPUT DIR}/Logs
${TS_LOG_PATH_BASE}    /opt/workspace/CIT/Master/Case_Logs/
${tshark_path}      /usr/bin/tshark
${LUA_SCRIPT_PATH}          /opt/workspace/CIT/Master/luashark/generated_luashark/luashark.lua
${command_template_Y}       {tshark_path} -r {input_file} -Y  \"ngap||f1ap\"  -T pdml > {output_file}
${command_template_S1}       {tshark_path} -r {input_file} -Y  \"s1ap\"  -T pdml > {output_file}
${command_template_Y_xnap}       {tshark_path} -r {input_file} -Y  \"ngap||xnap\"  -T pdml > {output_file}
${gnb_path}                 /tmp
${tl_scf_dir_path}    /opt/workspace/CIT/Master/SCF_file/
${ui_version}=    petrus
${AT_script_path}    C:tool
${int_time_list}    00/05/10/15/20/25/30/35/40/45/50/55
&{ct_path}   M55139C00013=CELLS/NRCELL-1/RSADU/SGNB_SA_DU_RAC_REJ_DUE_RRC
...          M55139C00010=CELLS/NRCELL-1/RSADU/SGNB_SA_DU_RAC_REJ_DUE_PUCCH
...          M55139C00014=CELLS/NRCELL-1/RSADU/SGNB_SA_DU_RAC_REJ_DUE_NGBR
...          M55139C00503=CELLS/NRCELL-1/RSADU/SA_DU_GBR_REJ_LACK_DRB
...          M55139C03501=CELLS/NRCELL-1/RSADU/SA_DU_RAC_FAIL_BBPOOL_NR_GBR
...          M55139C03503=CELLS/NRCELL-1/RSADU/SA_DU_RAC_FAIL_BBPOOL_NR_DRB
...          M55139C03502=CELLS/NRCELL-1/RSADU/SA_DU_RAC_FAIL_BBPOOL_NR_USER
...          M55139C03505=CELLS/NRCELL-1/RSADU/SA_DU_RAC_FAIL_BBPOOL_NR_SR
...          M55139C03504=CELLS/NRCELL-1/RSADU/SA_DU_RAC_FAIL_BBPOOL_NR_PCSI
${vendor}   HBTE
${max_attenuation_value}     ${127}
${att_ipaddr}                ${tl.attenuator[0].ip_addr}
${att_connection_port}       ${tl.attenuator[0].attenuator_ports[1]}
${att_api_port}              ${tl.attenuator[0].port}
${att_port_1}                ${tl.attenuator[0].attenuator_ports[1]}
${att_port_2}                ${tl.attenuator[0].attenuator_ports[2]}
${att_port_3}                ${tl.attenuator[0].attenuator_ports[3]}
${att_port_4}                ${tl.attenuator[0].attenuator_ports[4]}
${att_port_5}                ${tl.attenuator[0].attenuator_ports[5]}
${att_port_6}                ${tl.attenuator[0].attenuator_ports[6]}
${att_port_9}                ${tl.attenuator[0].attenuator_ports[9]}
${att_port_10}                ${tl.attenuator[0].attenuator_ports[10]}
${att_port_11}                ${tl.attenuator[0].attenuator_ports[11]}
${att_port_12}                ${tl.attenuator[0].attenuator_ports[12]}
${att_port_13}                ${tl.attenuator[0].attenuator_ports[13]}
${att_port_14}                ${tl.attenuator[0].attenuator_ports[14]}
${power_on}    at+CFUN=1
${power_off}    at+CFUN=0
@{com_port_arr}   75   69   67   81   77   79   74   72
&{month}   Jan=01   Feb=02   Mar=03   Apr=04   May=05   Jun=06   Jul=07   Aug=08   Sep=09   Oct=10   Nov=11   Dec=12


*** Keywords ***
Common Suite Setup for COAM
    robot_common_operations.Common Suite Setup
    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}
    Create directory    ${epc_log_path}
    Prepare Env For 2426
    ${gnb_release}     Get gnb release    host=${LMP_ADDR}
    Set Suite Variable    ${gnb_release}
    Run keyword if   '${gnb_release}'!='SBTS23R1'      Set Suite Variable    ${comma}   ,
    ...   ELSE    Set Suite Variable   ${comma}    ${EMPTY}

Prepare Env For 2426
    Reboot UE For 2426   ue_index=${8}
#    Reboot UE For 2426   ue_index=${9}
#    Reboot PC For 2426   ue_index=${0}
    Reboot PC For 2426   ue_index=${8}
    sleep    180s
#    Check UE For 2426   ue_index=${0}
    Check UE For 2426   ue_index=${8}

Reboot UE For 2426
    [Arguments]    ${ue_type}=xiaomi   ${ue_index}=${8}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Log To Console    ue_type:${ue_type}
    log to console    ue_reboot
    Run Keyword And Ignore Error   csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=${connection}
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} reboot
    ...   connection=${connection}
    Run Keyword And Ignore Error   csn.disconnect      connection=${connection}

Reboot PC For 2426
    [Arguments]    ${ue_type}=xiaomi   ${ue_index}=${8}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Log To Console    ue_type:${ue_type}  serial_number:${serial_number}
    log to console    ue_reboot
    Run Keyword And Ignore Error   csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=${connection}
    Run Keyword And Ignore Error    csn.send_command    command=shutdown /r /f /t 0
    ...   connection=${connection}
    Run Keyword And Ignore Error   csn.disconnect      connection=${connection}

Check UE For 2426
    [Arguments]    ${ue_type}=xiaomi   ${ue_index}=${8}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Log To Console    ue_type:${ue_type}
    log to console    check_ue_status
    Run Keyword And Ignore Error   csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=${connection}
    Run Keyword And Ignore Error    csn.send_command    command=adb devices
    ...   connection=${connection}
    sleep    5s
    ${status}    run keyword and return status
    ...    csn.Read Output Until    connection=${connection}   match=${serial_number}   timeout=30
    Run Keyword And Ignore Error   csn.disconnect      connection=${connection}

2426 Case Setup
    [Arguments]   ${open_spark}=False
    robot_common_operations.Common Case Setup
    COAM Login
    #If use ATcom to control mtu, default value of ${open_spark} is false
    Run Keyword If   '${open_spark}'=='True'   Spark Initial
    Power UE Precondition
#    Power UE Precondition   ue_index=${9}
#    Run keyword and ignore error   MTU detach    ue_num=8
    Run keyword and ignore error   Power UE detach
#    Run keyword and ignore error   Power UE detach   ue_index=${9}
#    Adjust the HBTE attenuation value

Case Teardown and Call Recover
    log to console    case_teardown
    Run keyword and ignore error   COAM Backup SCF   local_dir=${LOG_PATH}/${TESTNAME}
#    Run keyword and ignore error   MTU detach    ue_num=8
    Run keyword and ignore error   Power UE detach
#    Run keyword and ignore error   Power UE detach   ue_index=${9}
    Run keyword and ignore error   __Stop and collect btslog on local machine
    Run keyword and ignore error   Only Stop Capture Wireshark Logs on gNB
    Siso Common Save Logs
    Run keyword and ignore error   COAM Logout
#    Run keyword and ignore error   Adjust the HBTE attenuation value
    #    Run keyword and ignore error   COAM SCF Commission
    Run keyword and ignore error   selenium_coam.logout
    robot_common_operations.Common Case Teardown

Spark Initial
    ${status}   Run Keyword And Return Status   MTU Precondition    ue_num=3
    run keyword if   '${status}'=='False'   Restart Spark App
    run keyword if   '${status}'=='False'   MTU Precondition   ue_num=3

CSN connect
    [Arguments]    ${ue_index}=${8}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin

CSN disconnect
    csn.disconnect      connection=cygwin

Get Cell Technology
    ${nrcell}   COAM Get Managed Objects   class_name=NRCELL_R
    Set Suite Variable   ${nrcell_r}   ${nrcell[0]['distName']}
    ${cell_specific_info}   COAM Get Cell Info   cell_id=${nrcell_r}
    ${cell_technology}   set variable   ${cell_specific_info['technology']}
    [Return]     ${cell_technology}

Modify the COAM parameter with admin API
    [Arguments]    ${parameters}
    log to console    Modify_Parameter
    Connect to gnb coam via ssl    bts_host=${LOCAL_MASTER_IP}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters}   timeout=${150}
    COAM Teardown gnb connections

Restart Spark App
    [Documentation]    Author:jun.8.chen@nokia-sbell.com
    ...                Documentation:Restart Spark APP and disable data service
    [Arguments]    ${ue_index}=${0}
    ...            ${cpc_ip}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...            ${cpc_usrname}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...            ${cpc_passwd}=${tl.ues[${ue_index}].ssh_connection_details.password}
    ...            ${alias}=cpc_tmp
    Wait Until Keyword Succeeds    5min    20s    csn.connect_to    hostname=${cpc_ip}    username=${cpc_usrname}
    ...    password=${cpc_passwd}    alias=${alias}
    ${output1}    csn.execute    command=taskkill /f /im SSSRXX.exe    connection=${alias}
    ${output2}    csn.execute    command=taskkill /f /im adb.exe    connection=${alias}
    ${output3}    csn.execute    command=taskkill /f /im Spark.exe    connection=${alias}
    ${output4}    csn.execute    command=schtasks /end /tn spark    connection=${alias}
    ${output5}    csn.execute    command=schtasks /run /tn spark    connection=${alias}
    Sleep    60 sec
    [Teardown]    csn.disconnect    connection=${alias}

#UE L3call#
Get all xiaomi11 pointer variable
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    1246 2088
    Set Suite Variable    ${close_task}    710 2766
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    1300 2700 1300 2700
    Set Suite Variable    ${open_iperf_location}    500 2050
    Set Suite Variable    ${iperf_button}    730 300
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${5G}    900 960

Get all xiaomi12 pointer variable
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    950 677
    Set Suite Variable    ${close_task}    710 2766
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    1300 2700 1300 2700
    Set Suite Variable    ${open_iperf_location}    500 2050
    Set Suite Variable    ${iperf_button}    730 300
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${5G}    900 960

Power UE Precondition
    [Arguments]    ${ue_type}=xiaomi    ${ue_index}=${8}
    power_ue. Prepare UE   ue_type=${ue_type}    ue_index=${ue_index}    capatibility_index=${0}    reset_sol=none    detach_request=${true}
    Run keyword if   '${ue_type}'=='xiaomi'   Get all xiaomi12 pointer variable

MTU Precondition
    [Arguments]     ${ue_num}=8
    ${testpc_alias}=    Connect to UE PC
    csn.Send command    adb devices    connection=${testpc_alias}
    ${output}=    csn.Read output    connection=${testpc_alias}
    FOR   ${index}    IN RANGE    ${ue_num}
        Should contain    ${output}    ${tl.ues[${index}].serial_number}
        power_ue.Prepare UE    ue_type=huawei_sigspark    ue_index=${index}
     END

Connect to UE PC
    [Arguments]    ${ue_index}=${0}    ${alias}=csn-ue-pc-${ue_index}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}
    ...    alias=${alias}
    [Return]    ${alias}

AT cammand
    [Arguments]    ${command}    ${COM_port}    ${ue_index}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Log To Console    Execute AT cammand for serial_number:${serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
#    csn.send_command
#    ...    command="adb -s ${serial_number} shell "su -c'setprop sys.usb.config diag,adb,serial_cdev'""
#    ...    connection=cygwin${ue_index}
#    sleep   5s
    csn.send_command
    ...    command=cd ${AT_script_path} && python ATcommand.py -p com${COM_port} -c "${command}"
    ...    connection=cygwin${ue_index}
    ${status}    run keyword and return status
    ...    csn.Read Output Until    connection=cygwin${ue_index}   match=${command}   timeout=30
    run keyword if  not ${status}   FAIL
#    ${output}    csn.Read Output Until    connection=cygwin${ue_index}   match=${command}   timeout=30
#    sleep    3s
#    should contain    ${output}    ${command}\\r\\r\\nOK\\r\\n
    [Teardown]   Run Keywords
    ...    run keyword if  not ${status}   Restart spark pc    AND
    ...    Run Keyword And Ignore Error    csn.disconnect      connection=cygwin${ue_index}

Restart spark pc
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    csn.send_command
    ...    command=shutdown /r /f /t 0
    ...    connection=cygwin${ue_index}
    csn.disconnect      connection=cygwin${ue_index}
    sleep    120s

Power UE attach
    [Arguments]    ${ue_type}=xiaomi   ${4g_check}=False    ${gnb_index}=${0}   ${ue_index}=${8}
    Log To Console    Power UE attach with gnb_index:${gnb_index} and 4g_check:${4g_check}
    unlock the screen and close all task    ue_index=${ue_index}
#     ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    gnb_index=${gnb_index}
#    sleep    18s
#    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    ue_index=${ue_index}    gnb_index=${gnb_index}
#    ...                       4G_check=${4g_check}    5Gstatus=PASS
    Preparation and execution for Commercial UE Attach    ue_index=${ue_index}    UE_type=${ue_type}

Power UE detach
    [Arguments]    ${ue_type}=xiaomi   ${ue_index}=${8}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    log to console    ue_detach
    unlock the screen and close all task    ue_index=${ue_index}
    power_ue.UE Detach   ue_type=${ue_type}    ue_index=${ue_index}
    Run Keyword And Ignore Error   csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=${connection}
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}
    ...   connection=${connection}
    Run Keyword And Ignore Error   csn.disconnect      connection=${connection}

MTU attach
    [Arguments]     ${first_ue_index}=${0}    ${ue_num}=1   ${4g_check}=False    ${gnb_index}=${0}
    [Timeout]     5m
    log to console    mtu_attach with gnb_index:${gnb_index} and 4g_check:${4g_check}
    FOR   ${index}    IN RANGE    ${ue_num}
        ${final_index}   Evaluate   ${first_ue_index}+${index}
        AT cammand   COM_port=${com_port_arr[${final_index}]}   ue_index=${final_index}   command=${power_off}
        AT cammand   COM_port=${com_port_arr[${final_index}]}   ue_index=${final_index}   command=${power_on}
        sleep   15s
     END
#    :FOR   ${index}    IN RANGE    ${ue_num}
#        ${final_index}   Evaluate   ${first_ue_index}+${index}
#        power_ue.Prepare UE    ue_type=huawei_sigspark    ue_index=${final_index}
#        ${5Grach_ed}    power_ue.UE Attach    ue_type=huawei_sigspark    ue_index=${final_index}    gnb_index=${gnb_index}
#        ...   power_reset=False
#        sleep    18s
#        power_ue.Verify attach    ue_type=huawei_sigspark    5Grach_ed=${5Grach_ed}    ue_index=${final_index}    gnb_index=${gnb_index}
#        ...                       4G_check=${4g_check}    5Gstatus=PASS
#     END

MTU detach
    [Arguments]     ${first_ue_index}=${0}    ${ue_num}=1
    log to console    mtu_detach
    FOR   ${index}    IN RANGE    ${ue_num}
        ${final_index}   Evaluate   ${first_ue_index}+${index}
        AT cammand   COM_port=${com_port_arr[${final_index}]}   ue_index=${final_index}   command=${power_off}
     END
#    :FOR   ${index}    IN RANGE    ${ue_num}
#        ${final_index}   Evaluate   ${first_ue_index}+${index}
#        power_ue.UE Detach   ue_type=huawei_sigspark    ue_index=${final_index}
#     END

unlock the screen and close all task
    [Documentation]   Check UE if need awake
    [Arguments]   ${ue_index}=${8}   ${serial_number}=${tl.ues[${ue_index}].serial_number}   ${connection}=cpc_${ue_index}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=${connection}
    csn.send_command   connection=${connection}
    ...   command=adb -s ${serial_number} shell dumpsys window | grep -E \"mAwake|isStatusBarKeyguard|mShowingLockscreen\"
    sleep   2s
    ${output}   csn.read_output   connection=${connection}
    Run Keyword If   ${output.lower().count('mawake=false')}>0
    ...   csn.send_command   command=adb -s ${serial_number} shell input keyevent 26   connection=${connection}
    sleep    1s
    csn.send_command   command=adb -s ${serial_number} shell input swipe 347 2514 715 400    connection=${connection}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3    connection=${connection}
    sleep   2s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 187    connection=${connection}
    sleep   4s
    #####Turn off all running tasks on the phone#####
    csn.send_command    command=adb -s ${serial_number} shell input tap ${close_task}    connection=${connection}
    [Teardown]    csn.disconnect      connection=${connection}

hold on an VONR
    [Arguments]    ${ue_index}=${8}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...    ${connection}=cpc_${ue_index}
    log to console    vonr_start
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=${connection}
    Run Keyword and Ignore Error   Awake UE if Sleepy   ue_index=${ue_index}
    ...    serial_number=${serial_number}    connection=${connection}
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+6688
    ...    connection=${connection}
    sleep    10s
#    csn.send_command    command=adb -s ${serial_number} shell input tap 716 2886
#    ...    connection=${connection}
#    sleep    10s
    [Teardown]    csn.disconnect      connection=${connection}

Stop the VONR call
    [Arguments]    ${ue_index}=${8}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=911
    ...    ${connection}=cpc_${ue_index}
    log to console    vonr_hangup with phone_number:${phone_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=${connection}
    Run Keyword and Ignore Error   Awake UE if Sleepy   ue_index=${ue_index}
    ...    serial_number=${serial_number}    connection=${connection}
    csn.send_command    command=adb -s ${serial_number} shell input tap 726 2771
    ...    connection=${connection}
    sleep    5s
    [Teardown]    csn.disconnect      connection=${connection}

Start a emergency call
    [Arguments]    ${ue_index}=${8}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=911
    ...    ${connection}=cpc_${ue_index}
    log to console    emer_start with phone_number:${phone_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=${connection}
    Run Keyword and Ignore Error   Awake UE if Sleepy   ue_index=${ue_index}
    ...    serial_number=${serial_number}    connection=${connection}
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.DIAL -d tel:${phone_number}
    ...    connection=${connection}
    sleep    5s
    csn.send_command    command=adb -s ${serial_number} shell input tap 716 2886
    ...    connection=${connection}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 715 480
    ...    connection=${connection}
    sleep    10s
    [Teardown]    csn.disconnect      connection=${connection}

Stop the emergency call
    [Arguments]    ${ue_index}=${8}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=911
    ...    ${connection}=cpc_${ue_index}
    log to console    emer_hangup with phone_number:${phone_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=${connection}
    Run Keyword and Ignore Error   Awake UE if Sleepy   ue_index=${ue_index}
    ...    serial_number=${serial_number}    connection=${connection}
    csn.send_command    command=adb -s ${serial_number} shell input tap 726 2771
    ...    connection=${connection}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 726 2700
    ...    connection=${connection}
    sleep    5s
    [Teardown]    csn.disconnect      connection=${connection}

Power UE start ul
    [Arguments]    ${ue_type}=xiaomi   ${throughput}=10M   ${duration}=90   ${ue_index}=${8}
    power_ue.Start traffic   ue_type=${ue_type}   ue_index=${ue_index}   direction=ul
    ...   throughput=${throughput}Kbits/sec   duration=${duration}   apn_address=wap2nokiacom   ue_mode=SA

Power UE stop ul
    [Arguments]   ${ue_type}=xiaomi   ${ue_index}=${8}
    power_ue.Stop Traffic   ue_type=${ue_type}   ue_index=${ue_index}   direction=ul
    ...   apn_address=wap2nokiacom   ue_mode=SA

MTU start ul
    [Arguments]     ${first_ue_index}=${0}    ${ue_num}=1   ${throughput}=10M   ${duration}=90   ${default_iperf_port}=58867
    FOR   ${index}    IN RANGE    ${ue_num}
        ${final_port}   Evaluate   ${default_iperf_port}+${index}
        ${final_index}   Evaluate   ${first_ue_index}+${index}
        power_ue.Start traffic   ue_type=huawei_sigspark   ue_index=${final_index}   direction=ul   iperf_port=${final_port}
        ...   throughput=${throughput}Kbits/sec   duration=${duration}   apn_address=wap2nokiacom   ue_mode=SA
     END

MTU stop ul
    [Arguments]     ${first_ue_index}=${0}    ${ue_num}=1   ${default_iperf_port}=58867
    FOR   ${index}    IN RANGE    ${ue_num}
        ${final_port}   Evaluate   ${default_iperf_port}+${index}
        ${final_index}   Evaluate   ${first_ue_index}+${index}
        power_ue.Stop Traffic   ue_type=huawei_sigspark   ue_index=${final_index}   direction=ul
        ...   apn_address=wap2nokiacom   ue_mode=SA   iperf_port=${final_port}
     END

#Modify config#
Modify Venfor file
     [Arguments]    ${maxNumOfUserL2Pool}=40   ${maxNumOfDRBL2Pool}=80   ${maxNumOfGBRL2Pool}=20   ${F3PCSI}=2   ${F1SR}=2
     ...   ${Emergency}=2   ${RatioPerCell}=5    ${cellnum}=6
     log to console    Modify_Vendor with Emergency:${Emergency}
     ${VEN_PATH}   set variable   ${LOG_PATH}/${TESTNAME}
     ${vendor_0}   set variable
     ...   cd ${VEN_PATH};sudo sed -i 's|<p name="maxNumOfUserL2Pool">.*</p>|<p name="maxNumOfUserL2Pool">${maxNumOfUserL2Pool}</p>|g' vendor_5g.xml
     ${vendor_1}   set variable
     ...   cd ${VEN_PATH};sudo sed -i 's|<p name="maxNumOfDRBL2Pool">.*</p>|<p name="maxNumOfDRBL2Pool">${maxNumOfDRBL2Pool}</p>|g' vendor_5g.xml
     ${vendor_2}   set variable
     ...   cd ${VEN_PATH};sudo sed -i 's|<p name="maxNumOfGBRL2Pool">.*</p>|<p name="maxNumOfGBRL2Pool">${maxNumOfGBRL2Pool}</p>|g' vendor_5g.xml
     ${vendor_3}   set variable
     ...   cd ${VEN_PATH};sudo sed -i 's|<p name=".*F1SR.*">.*</p>|<p name="maxNumPucchF1SRPerSlotL1Pool">${F1SR}</p>|g' vendor_5g.xml
     ${vendor_4}   set variable
     ...   cd ${VEN_PATH};sudo sed -i 's|<p name=".*F3PCSI.*">.*</p>|<p name="maxNumPucchF3PCSIPerSlotL1Pool">${F3PCSI}</p>|g' vendor_5g.xml
     ${vendor_5}   set variable   ls
#     ...   cd ${VEN_PATH};sudo sed -i 's|<p name=".*PerEmergency.*">.*</p>|<p name="numOfDRBReservedPerEmergency">${Emergency}</p>|g' vendor_5g.xml
     ${vendor_6}   set variable
     ...   cd ${VEN_PATH};sudo sed -i 's|<p name=".*RatioPerC.*">.*</p>|<p name="guaranteedResourceRatioPerCell">${RatioPerCell}</p>|g' vendor_5g.xml
     Wait Until Keyword Succeeds  3x  20s  coam.connect to
     ...   bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
     ...   username=${tl.gnbs[0].cu.oam_http_connection_details.username}
     ...   password=${tl.gnbs[0].cu.oam_http_connection_details.password}    name=coam_admin
     coam.download_vendor_file    target_file_name=${LOG_PATH}/${TESTNAME}/vendor_5g.xml    connection=coam_admin
     Wait Until Keyword Succeeds  3x  20s  Connect to TestPc   alias=TestPc
     csn.execute    ls ${VEN_PATH}    connection=TestPc
     FOR   ${index}    IN RANGE    7
         csn.execute    command=${vendor_${index}}   connection=TestPc
     END
     Wait Until Keyword Succeeds  3x  2m  COAM WEBUI Login
     ${result}   selenium_coam.load_vendor_file_and_validate    file_path=${LOG_PATH}/${TESTNAME}/vendor_5g.xml
     Run keyword if   '${result}'=='Validation failed!'
     ...   selenium_coam.load_vendor_file_and_validate    file_path=${LOG_PATH}/${TESTNAME}/vendor_5g.xml
     sleep   5s
     Run Keyword And Ignore Error  COAM WEBUI Whether Close Start Up View Window
#     selenium_coam.load_commissioning_file_and_check_load_status   file_path=${CURDIR}/TL867_${cellnum}CELL.xml   timeout=${120}
     ${scfname}  Wait Until Keyword Succeeds  3x  30s  Return scf name for release
     selenium_coam.load_commissioning_file_and_check_load_status
     ...   file_path=${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/TL867_${cellnum}Cells_${scfname}.xml   timeout=${120}
     selenium_coam.validate_plan
     Run Keyword And Ignore Error  COAM WEBUI Whether Close Start Up View Window
     selenium_coam.activate_plan   activate_plan_despite_errors=${True}
     Wait Until Keyword Succeeds   10m   30s   gNB not Connected
     Wait Until Keyword Succeeds   7m   15s   Try Connect gNB
     Wait Until Keyword Succeeds   10m   30s   COAM Check All Cells Onair
     [Teardown]    run keywords   Run Keyword And Ignore Error  COAM WEBUI Whether Close Start Up View Window
     ...   AND   Run Keyword And Ignore Error   COAM WEBUI Logout
     ...   AND   Run Keyword And Ignore Error   coam.teardown   connection=coam_admin

Modify SCF file
     [Arguments]    ${cell_index}=${1}   ${maxNumOfUsersNRCell}=20   ${csiReportPeriodicity}=slots20
     ...   ${srPeriodicity}=slots20   ${actEmergencyCall}=${True}   ${numOfRadioResReservForEmergency}=1
     ...   ${actVoNR}=${True}   ${maxNumOfGBRBearersSA}=20
     selenium_coam.enable_virtual_display
     selenium_coam.login    url=https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
     ...   username=${tl.gnbs[0].cu.oam_http_connection_details.username}     password=${tl.gnbs[0].cu.oam_http_connection_details.password}
     selenium_coam.disable_message_box
     ${exists}   selenium_coam.start_up_view_window_exists
     Run Keyword If   ${exists}   selenium_coam.close_start_up_view_window
     run keyword and ignore error   selenium_coam.set_parameter_value    dist_name=${bts_distname}/NRCELL-${cell_index}
     ...    filter_param=Maximum number of SA and NSA users in a New Radio cell    new_value=${maxNumOfUsersNRCell}
     run keyword and ignore error   selenium_coam.set_parameter_value    dist_name=${bts_distname}/NRCELL-${cell_index}
     ...    filter_param=CSI reporting periodicity   new_value=${csiReportPeriodicity}
     run keyword and ignore error   selenium_coam.set_parameter_value    dist_name=${bts_distname}/NRCELL-${cell_index}
     ...    filter_param=Scheduling request periodicity   new_value=${srPeriodicity}
     run keyword and ignore error   selenium_coam.set_parameter_value    dist_name=${bts_distname}/NRCELL-${cell_index}
     ...    filter_param=Activate emergency calls handling   new_value=${actEmergencyCall}
     run keyword and ignore error   selenium_coam.set_parameter_value    dist_name=${bts_distname}/NRCELL-${cell_index}
     ...    filter_param=Number of radio resources reserved for emergency calls   new_value=${numOfRadioResReservForEmergency}
     run keyword and ignore error   selenium_coam.set_parameter_value    dist_name=${bts_distname}/NRCELL-${cell_index}
     ...    filter_param=Activate voice over NR call support in the NR cell.   new_value=${actVoNR}
     run keyword and ignore error   selenium_coam.set_parameter_value    dist_name=${bts_distname}/NRCELL-${cell_index}
     ...    filter_param=Maximum number of GBR data radio bearers in a New Radio cell for SA   new_value=${maxNumOfGBRBearersSA}
     selenium_coam.validate_plan
     Run Keyword And Ignore Error  COAM WEBUI Whether Close Start Up View Window
     selenium_coam.activate_plan   activate_plan_despite_errors=${True}
     sleep   60s
     selenium_coam.logout
     Run Keyword And Ignore Error   selenium_coam.disable_virtual_display

Remove Cells
    [Arguments]     ${index}
    log to console    remove_cell
    ${index}   Convert To Integer   ${index}
    selenium_coam.remove_object     object_name=MRBTS-${BTS_ID}/${nrbts_id}/NRCELL-${index}
    selenium_coam.remove_object     object_name=MRBTS-${BTS_ID}/${nrbts_id}/NRCELLGRP-${index-1}
    selenium_coam.remove_object     object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${index}
    selenium_coam.remove_element    dist_name=MRBTS-${BTS_ID}/${nrbts_id}/NRDU-1
    ...     filter_param=Reference to cell group    node_index=${index-1}

Add Cells
    [Arguments]     ${index}
    log to console    add_cell
    ${index}   Convert To Integer   ${index}
    ${cell_technology}   Get Cell Technology
    selenium_coam.add_object  object_name=MRBTS-${BTS_ID}/${nrbts_id}   object_class_name=NRCELL
     ...   plan_to_copy_from=${plan_copy_from}   is_load_default_values=${false}
     ...   copy_from=MRBTS-${BTS_ID}/${nrbts_id}/NRCELL-1
     ...   id_value=${index}   include_subobject=${true}
     selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/${nrbts_id}/NRCELL-${index}   filter_param=Physical cell identifier
     ...   new_value=${index-1}
     selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/${nrbts_id}/NRCELL-${index}   filter_param=Local cell resource ID
     ...   new_value=${index}
     selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/${nrbts_id}/NRCELL-${index}   filter_param=PRACH configuration index
     ...   new_value=${index+35}
#     selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/${nrbts_id}/NRCELL-${index}   filter_param=List of RMOD distinguished names
#     ...   new_value=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${index}   node_index=${0}
     selenium_coam.add_object  object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1   object_class_name=LCELNR
     ...   plan_to_copy_from=${plan_copy_from}   is_load_default_values=${false}
     ...   copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1
     ...   id_value=${index}   include_subobject=${true}
     Run Keyword If   '${cell_technology}'=='TDD'   Change TDD Cell Parameter   index=${index}
     ...   ELSE   Change FDD Cell Parameter   index=${index}
     selenium_coam.add_element   dist_name=MRBTS-${BTS_ID}/${nrbts_id}/NRDU-1   filter_param=Reference to cell group
     selenium_coam.set_parameter_value
     ...   dist_name=MRBTS-${BTS_ID}/${nrbts_id}/NRDU-1
     ...   filter_param=Reference to cell group
     ...   new_value=${index-1}
     ...   node_index=${index-1}

Add Cell Groups
    [Arguments]     ${index}
    ${index}   Convert To Integer   ${index}
    selenium_coam.add_object  object_name=MRBTS-${BTS_ID}/${nrbts_id}   object_class_name=NRCELLGRP
     ...   plan_to_copy_from=${plan_copy_from}   is_load_default_values=${false}
     ...   copy_from=MRBTS-${BTS_ID}/${nrbts_id}/NRCELLGRP-0
     ...   id_value=${index-1}   include_subobject=${true}
     selenium_coam.set_parameter_value
     ...   dist_name=MRBTS-${BTS_ID}/${nrbts_id}/NRCELLGRP-${index-1}
     ...   filter_param=List of NR cells assigned to cell group
     ...   new_value=${index}
     ...   node_index=${0}

Change TDD Cell Parameter
    [Arguments]    ${index}
    FOR   ${int}    IN RANGE    2
        run keyword and ignore error   selenium_coam.set_parameter_value
        ...   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${index}/CHANNELGROUP-1/CHANNEL-${int+1}
        ...   filter_param=Distinguished Name of resource   new_value=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${index}/PHYANT-1
     END
     FOR   ${int}    IN RANGE    2
        run keyword and ignore error   selenium_coam.set_parameter_value
        ...   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${index}/CHANNELGROUP-1/CHANNEL-${int+3}
        ...   filter_param=Distinguished Name of resource   new_value=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${index}/PHYANT-1
     END

Change FDD Cell Parameter
    [Arguments]    ${index}
    FOR   ${int}    IN RANGE    2
        run keyword and ignore error   selenium_coam.set_parameter_value
        ...   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${index}/CHANNELGROUP-1/CHANNEL-${int+1}
        ...   filter_param=Distinguished Name of antenna line   new_value=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${index}/ANTL-1
     END
     FOR   ${int}    IN RANGE    2
        run keyword and ignore error   selenium_coam.set_parameter_value
        ...   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${index}/CHANNELGROUP-1/CHANNEL-${int+3}
        ...   filter_param=Distinguished Name of antenna line   new_value=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${index}/ANTL-3
     END

#wireshark log#
Start Capture Wireshark Logs on gNB
    [Arguments]     ${nglogname}    ${interface}=any
    log to console    tcpdumplog_start
    RUN KEYWORD AND IGNORE ERROR    gNB connections
    csn.send command    command=tcpdump -i ${interface} sctp -w ${gnb_path}/${nglogname}   connection=${connection}
    sleep    3s
    Run Keyword And Ignore Error    csn.disconnect    connection=gnb

gNB connections
    csn.Connect To    hostname=${asik_addr}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=gnb

Stop Capture Wireshark Logs on gNB
    [Arguments]    ${nglogname}
    log to console    tcpdumplog_stop
    gNB connections
    sleep    5
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    3
    run keyword and ignore error   csn.send command    command=rm ${epc_log_path}/${TESTNAME}/asix.*   connection=${connection}
    Create directory   ${epc_log_path}/${TESTNAME}
    csn.download_file   remote_path=${gnb_path}/${nglogname}   local_path=${epc_log_path}/${TESTNAME}/${nglogname}   connection=${connection}
    sleep    3
    Run Keyword And Ignore Error    csn.disconnect    connection=gnb

Only Stop Capture Wireshark Logs on gNB
    gNB connections
    sleep    5
    csn.send command    command=killall tcpdump     connection=${connection}
    Run Keyword And Ignore Error    csn.disconnect    connection=gnb

Check Wireshark have RRC Reject in DU
    [Arguments]    ${nglogname}
    parser.load_pcap_file    pcap_file=${epc_log_path}/${TESTNAME}/${nglogname}   alias=Wireshark
    ${filter_expression}=     Catenate    (nr-rrc.criticalExtensions == 0) && (f1ap.radioNetwork == 8)
    ${filtered_packets}=    parser.filter_packets_by_expression    pcap_parser=Wireshark    filter_expression=${filter_expression}
    ${result}=    parser.Get Field Value By Xpath    pcap_parser=Wireshark
    ...    xpath=.//f1ap.radioNetwork
    Should Not Be Empty    ${result}

Check Wireshark no RRC Reject in DU
    [Arguments]    ${nglogname}
    parser.load_pcap_file    pcap_file=${epc_log_path}/${TESTNAME}/${nglogname}   alias=Wireshark
    ${filter_expression}=     Catenate    (nr-rrc.criticalExtensions == 0) && (f1ap.radioNetwork == 8)
    ${filtered_packets}=    parser.filter_packets_by_expression    pcap_parser=Wireshark    filter_expression=${filter_expression}
    ${result}=    parser.Get Field Value By Xpath    pcap_parser=Wireshark
    ...    xpath=.//f1ap.radioNetwork
    Should Be Empty    ${result}

Check Wireshark have DRB Fail in DU
    [Arguments]    ${nglogname}
    parser.load_pcap_file    pcap_file=${epc_log_path}/${TESTNAME}/${nglogname}   alias=Wireshark
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 5) && (f1ap.radioNetwork == 8)
    ${filtered_packets}=    parser.filter_packets_by_expression    pcap_parser=Wireshark    filter_expression=${filter_expression}
    ${result}=    parser.Get Field Value By Xpath    pcap_parser=Wireshark
    ...    xpath=.//f1ap.radioNetwork
    ${filter_expression2}=     Catenate    (f1ap.procedureCode == 7) && (f1ap.radioNetwork == 8)
    ${filtered_packets2}=    parser.filter_packets_by_expression    pcap_parser=Wireshark    filter_expression=${filter_expression2}
    ${result2}=    parser.Get Field Value By Xpath    pcap_parser=Wireshark
    ...    xpath=.//f1ap.radioNetwork
    ${condition1}   Run keyword and return status    Should Not Be Empty   ${result}
    Run keyword if   '${condition1}'=='False'   Should Not Be Empty   ${result2}

Check Wireshark no DRB Fail in DU
    [Arguments]    ${nglogname}
    parser.load_pcap_file    pcap_file=${epc_log_path}/${TESTNAME}/${nglogname}   alias=Wireshark
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 5) && (f1ap.radioNetwork == 8)
    ${filtered_packets}=    parser.filter_packets_by_expression    pcap_parser=Wireshark    filter_expression=${filter_expression}
    ${result}=    parser.Get Field Value By Xpath    pcap_parser=Wireshark
    ...    xpath=.//f1ap.radioNetwork
    ${filter_expression2}=     Catenate    (f1ap.procedureCode == 7) && (f1ap.radioNetwork == 8)
    ${filtered_packets2}=    parser.filter_packets_by_expression    pcap_parser=Wireshark    filter_expression=${filter_expression2}
    ${result2}=    parser.Get Field Value By Xpath    pcap_parser=Wireshark
    ...    xpath=.//f1ap.radioNetwork
    Should Be Empty    ${result}
    Should Be Empty    ${result2}

Get UE_ID in Wireshark
    [Arguments]    ${nglogname}
    parser.load_pcap_file    pcap_file=${epc_log_path}/${TESTNAME}/${nglogname}   alias=Wireshark
    ${filter_expression}=     Catenate    nas_5gs.mm.5gs_reg_type == 1
    ${filtered_packets}=    parser.filter_packets_by_expression    pcap_parser=Wireshark    filter_expression=${filter_expression}
    ${result}=    parser.Get Field Value By Xpath    pcap_parser=Wireshark
    ...    xpath=.//f1ap.GNB_CU_UE_F1AP_ID
    ${final_result}    Remove Duplicates   ${result}
    [Return]    ${final_result}

Get Periodicity and Offset
    [Arguments]    ${nglogname}   ${UE_ID}
    parser.load_pcap_file    pcap_file=${epc_log_path}/${TESTNAME}/${nglogname}   alias=Wireshark
    ${filter_expression}=     Catenate    ((nr-rrc.c1 == 0) ||(nr-rrc.c1 == 1)) && (f1ap.GNB_CU_UE_F1AP_ID == ${UE_ID})
    ${filtered_packets}=    parser.filter_packets_by_expression    pcap_parser=Wireshark    filter_expression=${filter_expression}
    ${result}=    parser.Get Field Value By Xpath    pcap_parser=Wireshark
    ...    xpath=.//nr-rrc.SchedulingRequestResourceConfig_element/nr-rrc.periodicityAndOffset
    [Return]    ${result}

Get Rac Reject Time from Wireshark
    [Arguments]    ${nglogname}
    parser.load_pcap_file    pcap_file=${epc_log_path}/${TESTNAME}/${nglogname}   alias=Wireshark
    ${filter_expression}=     Catenate    f1ap.radioNetwork == 8
    ${filtered_packets}=    parser.filter_packets_by_expression    pcap_parser=Wireshark    filter_expression=${filter_expression}
    ${result}=    parser.Get Field Value By Xpath    pcap_parser=Wireshark
    ...    xpath=.//frame.time
    ${date} =	Get Current Date
    ${day}   set variable   ${date.split(' ')[0].split('-')[2]}
    ${day_index}   Split String To Characters   ${day}
    ${reject_month}   set variable   ${result[0].split(' ')[0]}
    Run keyword if   '${day_index[0]}'=='0'   Set Suite Variable   ${reject_hour}   ${result[0].split(' ')[4].split(':')[0]}
    ...   ELSE   Set Suite Variable   ${reject_hour}   ${result[0].split(' ')[3].split(':')[0]}
    Run keyword if   '${day_index[0]}'=='0'   Set Suite Variable   ${reject_min_before}   ${result[0].split(' ')[4].split(':')[1]}
    ...   ELSE   Set Suite Variable   ${reject_min_before}   ${result[0].split(' ')[3].split(':')[1]}
    remove zero min
    Set Suite Variable   ${reject_min}   00
    ${reject_min}   Evaluate   ${reject_min_before}/5
    ${reject_min}   Convert to Integer   ${reject_min}
    ${reject_min}   Evaluate   ${reject_min}*5
    run keyword if   ${reject_min}< 10   add zero min   string=${reject_min}
#    run keyword if   '${reject_min}'=='60'   60 and 00
    ${countertime}=    Run keyword if   '${day_index[0]}'=='0'   Catenate
    ...   SEPARATOR=    ${result[0].split(' ')[3]}    -    ${month['${reject_month}']}    -    ${day}
    ...    ${space}    ${reject_hour}    :    ${reject_min}    :00
    ...   ELSE   Catenate
    ...   SEPARATOR=    ${result[0].split(' ')[2]}    -    ${month['${reject_month}']}    -    ${day}
    ...    ${space}    ${reject_hour}    :    ${reject_min}    :00
    [Return]    ${countertime}

remove zero min
    ${reject_min_before_1}   Convert To Number   ${reject_min_before}
    Set Suite Variable   ${reject_min_before}   ${reject_min_before_1}

#remove zero hour
#    ${reject_hour_before_1}   Convert To Number   ${reject_hour}
#    Set Suite Variable   ${reject_hour}   ${reject_hour_before_1}

add zero min
    [Arguments]     ${string}
    Convert To String   ${string}
    ${reject_min_1}  set variable   0${string}
    Set Suite Variable   ${reject_min}   ${reject_min_1}

#add zero hour
#    [Arguments]     ${string}
#    Convert To String   ${string}
#    ${reject_hour_1}  set variable   0${string}
#    Set Suite Variable   ${reject_hour}   ${reject_hour_1}

#60 and 00
#    Set Suite Variable   ${reject_min}   00
#    remove zero hour
#    ${reject_hour}   Convert to Integer   ${reject_hour}
#    ${reject_hour_1}   Evaluate   ${reject_hour}+1
#    Run Keyword If   ${reject_hour_1}< 10   add zero hour   string=${reject_hour_1}
#    ...   ELSE   Set Suite Variable   ${reject_hour}   ${reject_hour_1}

#BTS log#
Syslog Capture Start
    [Arguments]   ${name}=btslog
    ...           ${bts_logs_dir}=/tmp/btslog2
    log to console    syslog_start
    __Make empty BTS logs dir      ${bts_logs_dir}
#    ${executor_test_vm}  Create Dictionary
#    ...    host=127.0.0.1
#    ...    user=ute
#    ...    password=iW_K#8.ute%A10h0m0ra
    btslog.create_btslog_collector
    ...    name=${name}
    ...    log_dir=${bts_logs_dir}
    ...    start_timeout=${120}
#    ...    executor=${executor_test_vm}
    core.setup_collectors        names=${name}
    core.start_collectors        names=${name}
    btslog.set_suite_alias       ${name}

Get Btslogs from Local machine
    btslog.create_btslog_collector
    ...    name=${name}
    ...    log_dir=${bts_logs_dir}
    ...    start_timeout=${120}
#    ...    executor=${executor_test_vm}
    core.setup_collectors      names=${name}
    core.start_collectors      names=${name}

Syslog Capture Stop and Collect
    [Arguments]  ${bts_logs_dir}=/tmp/btslog2
    log to console    syslog_stop
    run keyword and ignore error    __Stop and collect btslog on local machine
    __Copy btslog to logs dir and clean BTSlog workspace    ${bts_logs_dir}


__Stop and collect btslog on local machine
    [Arguments]   ${name}=btslog
    core.stop_collectors         names=${name}
    core.collect_collectors      names=${name}
    core.teardown_collectors     names=${name}
    Run  rm -rf ${OUTPUTDIR}/5GC*

__Make empty BTS logs dir
    [Arguments]     ${bts_logs_dir}=/tmp/btslog2
    Run  if [ ! -d ${bts_logs_dir} ]; then mkdir ${bts_logs_dir}; else rm ${bts_logs_dir}/*; fi

__Copy btslog to logs dir and clean BTSlog workspace
    [Arguments]     ${bts_logs_dir}=/tmp/btslog2
    Run   if [ ! -d ${LOG_PATH}/${TESTNAME}/BTSlog ]; then mkdir ${LOG_PATH}/${TESTNAME}/BTSlog; else rm ${LOG_PATH}/${TESTNAME}/BTSlog/*; fi
    Run   cat ${bts_logs_dir}/*.LOG > ${bts_logs_dir}/SYSLOG.LOG
    Run   cp ${bts_logs_dir}/SYSLOG.LOG ${LOG_PATH}/${TESTNAME}/BTSlog/SYSLOG.LOG
    Run   rm -rf ${OUTPUTDIR}/5GC*

Print Message
    [Arguments]    ${message_name}=BbPoolingRacAlgorithmCommon.cpp    ${bts_logs_dir}=/tmp/btslog2
    ${message} =    OperatingSystem.Grep File    ${bts_logs_dir}/SYSLOG.LOG    ${message_name}
    log to console   ${message}
    [Return]      ${message}


### check counter ###
Get Current Time for counter at int time
    ${current_time}    Wait Until Keyword Succeeds    6min    20s    Get int time
    ${countertime}=    Catenate    SEPARATOR=    ${current_time}[0]    -    ${current_time}[1]    -    ${current_time}[2]
    ...    ${space}    ${current_time}[3]    :    ${current_time}[4]    :00
    [Return]    ${countertime}

Get int time
    @{current_time} =	Get Time	year month day hour min sec
    Should Contain    ${int_time_list}    ${current_time}[4]    not right time
    [Return]    ${current_time}

Get 2426 Counters
    [Arguments]    ${countertime}=${countertime}
    log to console    getcounter
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${M55139C00013_value}=    Wait Until Keyword Succeeds    6min    30s   Get counter    counter_id=M55139C00013    countertime=${countertime}
    ${M55139C00010_value}=    Get counter    counter_id=M55139C00010    countertime=${countertime}
    ${M55139C00014_value}=    Get counter    counter_id=M55139C00014    countertime=${countertime}
    ${M55139C00503_value}=    Get counter    counter_id=M55139C00503    countertime=${countertime}
    ${M55139C03501_value}=    Get counter    counter_id=M55139C03501    countertime=${countertime}
    ${M55139C03503_value}=    Get counter    counter_id=M55139C03503    countertime=${countertime}
    ${M55139C03502_value}=    Get counter    counter_id=M55139C03502    countertime=${countertime}
    ${M55139C03505_value}=    Get counter    counter_id=M55139C03505    countertime=${countertime}
    ${M55139C03504_value}=    Get counter    counter_id=M55139C03504    countertime=${countertime}
    sleep    5s
    @{2426_list}    create list   ${M55139C00013_value}    ${M55139C00010_value}   ${M55139C00014_value}
    ...   ${M55139C00503_value}   ${M55139C03501_value}   ${M55139C03503_value}
    ...   ${M55139C03502_value}   ${M55139C03505_value}   ${M55139C03504_value}
    [Return]    ${2426_list}
    [Teardown]    Run Keywords
    ...    Run keyword and ignore error    selenium_coam.logout                                  AND
    ...    Run keyword and ignore error    selenium_coam.disable_virtual_display

Get counter
    [Arguments]    ${counter_id}=${counter_id}    ${countertime}=${countertime}
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id}    full_path=${ct_path['${counter_id}']}
    ...   timeout_for_loading_available_counters=180
    ${value}=    Get From Dictionary    ${counters}    ${countertime}
    [Return]    ${value}



##bip log##
Check SIB1 contain emergency from BIP log
    [Arguments]    ${biplog}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${biplog}   tshark_path=${tshark_path}
    ...    luashark_path=${LUA_SCRIPT_PATH}    command_template=${None}
    ${filter_expression}=    Catenate    nr-rrc
    ${filtered_packets}=    parser.filter_packets_by_expression    pdml_list=${all_packets}
    ...    filter_expression=${filter_expression}
    ${ims-emergencysupport}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//nr-rrc.ims_EmergencySupport
    should contain    ${ims-emergencysupport}    0
    [Teardown]    parser.teardown

Check SIB1 not contain emergency from BIP log
    [Arguments]    ${biplog}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${biplog}   tshark_path=${tshark_path}
    ...    luashark_path=${LUA_SCRIPT_PATH}    command_template=${None}
    ${filter_expression}=    Catenate    nr-rrc
    ${filtered_packets}=    parser.filter_packets_by_expression    pdml_list=${all_packets}
    ...    filter_expression=${filter_expression}
    ${ims-emergencysupport}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//nr-rrc.ims_EmergencySupport
    should be empty    ${ims-emergencysupport}
    [Teardown]    parser.teardown

bip capture and check SIB1 contain emergency from BIP log
   [Arguments]    ${biplog}    ${bip_time}=${1}
    Log To Console   Download bip logs with bip_time:${bip_time}
    bip capture on ABIO and download to UTE    biplog=${biplog}    interface=eth1    bip_time=${3}    connection=Local_gnb2
    Check SIB1 contain emergency from BIP log    biplog=${biplog}

bip capture on ABIO and download to UTE
    [Arguments]     ${biplog}    ${interface}    ${connection}    ${bip_time}=${1}
    Log To Console   Download bip logs with bip_time:${bip_time}
    gNB connections to ssh    connection=${connection}    gnb_index=${1}
    Connect to ABIO    proxy=${connection}    asik_slave=ABIO
    csn.send command    command=dbgnac set port 1 loop e t    connection=ABIO
    csn.send command    command=dbgnac mirror sport 12 dport 1 e b    connection=ABIO
    csn.send command    command=dbgnac mirror sport 16 dport 1 e b    connection=ABIO
    csn.send command    command=dbgnac mirror sport 1 dport 20 e b    connection=ABIO
    csn.send command    command=ifconfig ${interface} up    connection=ABIO
    csn.send command    command=tcpdump -i ${interface} -w ${gnb_path}${biplog} -vv    connection=ABIO
    sleep    ${bip_time}s
    csn.send command    command=killall tcpdump     connection=ABIO
    sleep    5s
    csn.send command    command=mv ${gnb_path}${biplog} /ffs/run/config/toor4nsn/     connection=ABIO
    csn.download_file   remote_path=/ffs/run/config/toor4nsn/${biplog}   local_path=${epc_log_path}${biplog}   connection=ABIO
    [Teardown]    csn.disconnect    connection=${connection}

bip capture and check SIB1 not contain emergency from BIP log
    [Arguments]    ${biplog}    ${bip_time}
    Log To Console   Download bip logs with bip_time:${bip_time}
    bip capture on ABIO and download to UTE    biplog=${biplog}    interface=eth1    bip_time=${3}    connection=Local_gnb2
    Check SIB1 not contain emergency from BIP log        biplog=${biplog}

##PA##
Adjust the HBTE attenuation value
    [Arguments]      ${value_1}=${0}    ${value_2}=${0}    ${value_3}=${0}    ${value_4}=${0}
    ...   ${value_5}=${0}    ${value_6}=${0}    ${value_9}=${0}    ${value_10}=${0}
    ...   ${value_11}=${0}    ${value_12}=${0}    ${value_13}=${0}    ${value_14}=${0}
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    att.set_attenuation     port=${att_port1}    value=${value_1}
    att.set_attenuation     port=${att_port2}    value=${value_2}
    att.set_attenuation     port=${att_port3}    value=${value_3}
    att.set_attenuation     port=${att_port4}    value=${value_4}
    att.set_attenuation     port=${att_port5}    value=${value_5}
    att.set_attenuation     port=${att_port6}    value=${value_6}
    att.set_attenuation     port=${att_port9}    value=${value_9}
    att.set_attenuation     port=${att_port10}    value=${value_10}
    att.set_attenuation     port=${att_port11}    value=${value_11}
    att.set_attenuation     port=${att_port12}    value=${value_12}
    att.set_attenuation     port=${att_port13}    value=${value_13}
    att.set_attenuation     port=${att_port14}    value=${value_14}
    ${value_port1}    att.read_attenuation    port=${att_port1}
    should be equal    ${value_port1}    ${value_1}
    ${value_port2}    att.read_attenuation    port=${att_port2}
    should be equal    ${value_port2}    ${value_2}
    ${value_port3}    att.read_attenuation    port=${att_port3}
    should be equal    ${value_port3}    ${value_3}
    ${value_port4}    att.read_attenuation    port=${att_port4}
    should be equal    ${value_port4}    ${value_4}
    ${value_port5}    att.read_attenuation    port=${att_port5}
    should be equal    ${value_port5}    ${value_5}
    ${value_port6}    att.read_attenuation    port=${att_port6}
    should be equal    ${value_port6}    ${value_6}
    ${value_port9}    att.read_attenuation    port=${att_port9}
    should be equal    ${value_port9}    ${value_9}
    ${value_port10}    att.read_attenuation    port=${att_port10}
    should be equal    ${value_port10}    ${value_10}
    ${value_port11}    att.read_attenuation    port=${att_port11}
    should be equal    ${value_port11}    ${value_11}
    ${value_port12}    att.read_attenuation    port=${att_port12}
    should be equal    ${value_port12}    ${value_12}
    ${value_port13}    att.read_attenuation    port=${att_port13}
    should be equal    ${value_port13}    ${value_13}
    ${value_port14}    att.read_attenuation    port=${att_port14}
    should be equal    ${value_port14}    ${value_14}

Modify 2271 parameter
     [Arguments]   ${actAdaptiveSr}=${True}   ${srPeriodicityMin}=slots5
     ...   ${adaptiveSrLoadThresholdUp}=60   ${adaptiveSrLoadThresholdDown}=40   ${lowLatencyReservation}=0
     ...   ${preferredVoNrSrPeriod}=slots20   ${vonrReservation}=0   ${adaptiveSrBlockingMinimization}=0
     selenium_coam.enable_virtual_display
     selenium_coam.login    url=https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
     ...   username=${tl.gnbs[0].cu.oam_http_connection_details.username}     password=${tl.gnbs[0].cu.oam_http_connection_details.password}
     selenium_coam.disable_message_box
     ${exists}   selenium_coam.start_up_view_window_exists
     Run Keyword If   ${exists}   selenium_coam.close_start_up_view_window
     FOR   ${index}    IN RANGE    2
         run keyword and ignore error   selenium_coam.set_parameter_value    dist_name=${bts_distname}/NRCELL-${index+1}
         ...    filter_param=Activate adaptive scheduling request    new_value=${actAdaptiveSr}
         run keyword and ignore error   selenium_coam.set_parameter_value    dist_name=${bts_distname}/NRCELL-${index+1}
         ...    filter_param=Scheduling request periodicity minimum   new_value=${srPeriodicityMin}
         run keyword and ignore error   selenium_coam.set_parameter_value    dist_name=${bts_distname}/NRCELL-${index+1}
         ...    filter_param=Adaptive SR load threshold up   new_value=${adaptiveSrLoadThresholdUp}
         run keyword and ignore error   selenium_coam.set_parameter_value    dist_name=${bts_distname}/NRCELL-${index+1}
         ...    filter_param=Adaptive SR load threshold down   new_value=${adaptiveSrLoadThresholdDown}
         run keyword and ignore error   selenium_coam.set_parameter_value    dist_name=${bts_distname}/NRCELL-${index+1}
         ...    filter_param=Low latency reservation   new_value=${lowLatencyReservation}
         run keyword and ignore error   selenium_coam.set_parameter_value    dist_name=${bts_distname}/NRCELL-${index+1}
         ...    filter_param=Preferred VoNr SR period   new_value=${preferredVoNrSrPeriod}
         run keyword and ignore error   selenium_coam.set_parameter_value    dist_name=${bts_distname}/NRCELL-${index+1}
         ...    filter_param=MVoNR reservation   new_value=${vonrReservation}
         run keyword and ignore error   selenium_coam.set_parameter_value    dist_name=${bts_distname}/NRCELL-${index+1}
         ...    filter_param=Adaptive SR blocking minimization   new_value=${adaptiveSrBlockingMinimization}
     END
     selenium_coam.validate_plan
     COAM WEBUI Whether Close Start Up View Window
     selenium_coam.activate_plan   activate_plan_despite_errors=${True}
     sleep   30s
     Run Keyword And Ignore Error  selenium_coam.logout
     Run Keyword And Ignore Error  selenium_coam.disable_virtual_display

Return name of pool in syslog
       ${gnb_release}   Get gnb release    host=${LMP_ADDR}
       ${nameOfpool}    Run keyword if   '${gnb_release}'=='SBTS22R3'     set variable   common
       ...   ELSE IF    '${gnb_release}'=='SBTS23R3'     set variable   avalible
       ...   ELSE IF    '${gnb_release}'=='SBTS23R4'     set variable   avalible
       ...   ELSE IF    '${gnb_release}'=='SBTS24R1'     set variable   avalible
       ...   ELSE        set variable    available
       [Return]     ${nameOfpool}

L141 result1 check
     Should Be Equal   ${periodicity_log1_UE1[0]}   5
     Should Be Equal   ${periodicity_log1_UE1[1]}   5
     Should Be Equal   ${periodicity_log1_UE2[0]}   5
     Should Be Equal   ${periodicity_log1_UE2[1]}   5
     Should Be Equal   ${periodicity_log2_UE1[0]}   9
     Should Be Equal   ${periodicity_log2_UE2[0]}   9
     Should Be Equal   ${periodicity_log2_UE3[0]}   5
     Should Be Equal   ${periodicity_log2_UE3[1]}   9
     Should Be Equal   ${periodicity_log2_UE3[2]}   9

L141 result2 check
     log to console    result2 check
     Should Be Equal   ${periodicity_log1_UE1[0]}   5
     Should Be Equal   ${periodicity_log1_UE1[1]}   5
     Should Be Equal   ${periodicity_log1_UE2[0]}   5
     Should Be Equal   ${periodicity_log1_UE2[1]}   5
     Should Be Equal   ${periodicity_log2_UE1[0]}   9
     Should Be Equal   ${periodicity_log2_UE1[1]}   7
     Should Be Equal   ${periodicity_log2_UE2[0]}   9
     Should Be Equal   ${periodicity_log2_UE2[1]}   7
     Should Be Equal   ${periodicity_log2_UE3[0]}   5
     Should Be Equal   ${periodicity_log2_UE3[1]}   9
     Should Be Equal   ${periodicity_log2_UE3[2]}   7
     Should Be Equal   ${periodicity_log2_UE3[3]}   7

L143 result1 check
     Should Be Equal   ${periodicity_log1_UE1[0]}   5
     Should Be Equal   ${periodicity_log1_UE1[1]}   5
     Should Be Equal   ${periodicity_log1_UE1[2]}   9
     Should Be Equal   ${periodicity_log1_UE2[0]}   5
     Should Be Equal   ${periodicity_log1_UE2[1]}   5
     Should Be Equal   ${periodicity_log1_UE2[2]}   9
     Should Be Equal   ${periodicity_log1_UE3[0]}   5
     Should Be Equal   ${periodicity_log1_UE3[1]}   9
     Should Be Equal   ${periodicity_log1_UE3[2]}   9
     Should Be Equal   ${periodicity_log2_UE1[0]}   7
     Should Be Equal   ${periodicity_log2_UE1[1]}   5
     Should Be Equal   ${periodicity_log2_UE2[0]}   7

L143 result2 check
     log to console    result2 check
     Should Be Equal   ${periodicity_log1_UE1[0]}   5
     Should Be Equal   ${periodicity_log1_UE1[1]}   5
     Should Be Equal   ${periodicity_log1_UE1[2]}   9
     Should Be Equal   ${periodicity_log1_UE1[3]}   7
     Should Be Equal   ${periodicity_log1_UE2[0]}   5
     Should Be Equal   ${periodicity_log1_UE2[1]}   5
     Should Be Equal   ${periodicity_log1_UE2[2]}   9
     Should Be Equal   ${periodicity_log1_UE2[3]}   7
     Should Be Equal   ${periodicity_log1_UE3[0]}   5
     Should Be Equal   ${periodicity_log1_UE3[1]}   9
     Should Be Equal   ${periodicity_log1_UE3[2]}   7
     Should Be Equal   ${periodicity_log1_UE3[3]}   7
     Should Be Equal   ${periodicity_log2_UE1[0]}   5
     Should Be Empty   ${periodicity_log2_UE2}
