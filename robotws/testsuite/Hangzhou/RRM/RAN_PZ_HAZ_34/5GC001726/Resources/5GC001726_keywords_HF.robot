*** Settings ***
Documentation    This file is for  for cloud ASOD related cases
...              Please do not modify the file without notification to author
...              Author: lusha zhang
...              Contact: lusha.zhang@nokia-sbell.com
...              Squard: MMW_HZ_2_SG

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/license_manager.robot
Library     ../../common/tp_calculate.py
Library    taf.ul.oam.selenium_megazone    WITH NAME    sm


*** Variables ***
${LKC_LOGIN_USER}            lusha.zhang@nokia-sbell.com
${LKC_LOGIN_PWD}             HZmmw02!
${LKC_CLIENT_PORT}           6006
${5G_QXDM_PATH}              "C:/Program Files (x86)/Qualcomm/QXDM4"
${5G_QXDM_CONFIG_PATH}       "C:/Users/nokia5G/Desktop/qxdm_config"
${LKC_CLIENT_ALIAS}          lkc
${LKC_CLIENT_PATH}           /home/nokia5G
${UE_LOG_PATH_WIN}           "C:/cygwin64/home/nokia5G/UE_log"
${UE_LOG_PATH}               /home/nokia5G/UE_log
${QCAT_EXE_PATH}             "${tl.ues[0].qcat_path}"
${UE_pc_ip}                  ${tl.ues[0].ssh_connection_details.addr}
${UE_pc_user}                ${tl.ues[0].ssh_connection_details.username}
${UE_pc_password}            ${tl.ues[0].ssh_connection_details.password}
${android_ue_type}           SDX50
${qxdmlog_time}              900
${QXDM_log_name}             QXDM_log
${epc_qxdm_path}             /home/ute/qxdm_log
${dl_throughput}             4G
${dl_target}                 3.5
${dl_length}                 1400
${ul_throughput}             200M
${ul_target}                 180
${ul_length}                 1400
${license_time}              2100
${book_interval}             480
${throughput_time}           4000


*** Keywords ***
Kill QXDM QPST and ClientMain process
    [Documentation]  Author: helen.1.chen@nokia-sbell.com
    ...              Descrition：kill QXDM.exe QPST.exe and ClientMain.exe process
    Kill QXDM process    ue_index=${ue_index}
    Kill QPST process    ue_index=${ue_index}
    Kill ClientMain process    ue_index=${ue_index}

###process qxdm log
Turn off UE Airplane Mode
    [Documentation]     This keyword will turn off ue airplane mode
    ${SN} =    set variable    ${tl.ues[${ue_index}].serial_number}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.execute    command=adb -s ${SN} shell "su 0 settings put global airplane_mode_on 0"
    ...    connection=cpc_${ue_index}
    ...    timeout=10
    csn.execute    command=adb -s ${SN} shell "su 0 am broadcast -a android.intent.action.AIRPLANE_MODE"
    ...    connection=cpc_${ue_index}
    ...    timeout=10
    csn.disconnect    connection=cpc_${ue_index}

Close Iperf Progress
    [Documentation]    This keyword kill iperf process on appserver and ue
    Close the iperf process on APPserver    port=${ul_port}
    Close the iperf process on APPserver    port=${dl_port}
    Close the iperf process on Qualcomm    ue_index=${ue_index}

Clear UE Log Tmp Files
    [Documentation]  Author: lusha.zhang@nokia-sbell.com
    ...              Descrition：clear tmp files produced during parsing UE  log
    Connect to control pc enhanced    ue_index=${ue_index}
    Csn.execute    command=rm -rf ${UE_LOG_PATH}/*.isf    connection=cpc_${ue_index}
    Csn.execute    command=rm -rf ${UE_LOG_PATH}/*.txt    connection=cpc_${ue_index}
    Csn.disconnect    connection=cpc_${ue_index}

Tests Recover
    [Documentation]    This keyword will recover test enviorment
    Drop License
    Android UE release
    Turn off UE Airplane Mode
    Kill QXDM QPST and ClientMain process
    Clear UE Log Tmp Files

