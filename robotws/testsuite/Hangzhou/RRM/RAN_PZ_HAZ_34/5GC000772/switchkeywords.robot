*** Settings ***
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Library           Telnet
Library      taf.transport.ssh    WITH NAME    csn
Variables    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py   WITH NAME   ue
Library                     taf.ul.mobile.ui.android     WITH NAME   android_mobile



*** Variables ***
# Setting of values from parameters in the file __init__.py
${hostname}=    ${tl.ues[0].ssh_connection_details.addr}
${username}=    ${tl.ues[0].ssh_connection_details.username}
${password}=    ${tl.ues[0].ssh_connection_details.password}
${serial_number}=    ${tl.ues[0].serial_number}



*** Keywords ***
Do Attach UE
    [Arguments]           ${attach_mode}=5G_NSA    ${5Gstatus}=PASS    ${ue_index}=${0} 
    Log to console         UE Attached
    ${5Grach_ed}    power_ue.UE Attach    ue_type=huawei    ue_index=${ue_index}    log_type=Aasyslog    attach_mode=${attach_mode}
    ${power_status}    Run Keyword And Return Status  power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    
    ...     5Gstatus=${5Gstatus}    ue_index=${ue_index}
    Run Keyword If   ${power_status} ==False  and '${attach_mode}'=='5G_NSA'    Verify attach by adb   ue_index=${ue_index}


Verify attach by adb
    [Arguments]    ${ue_index}=${0}    ${sleep_time_before_read_output}=${None}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc enhanced    ${ue_index}
    csn.send command
    ...    command=adb -s ${serial_number} shell dumpsys telephony.registry |grep -E "mCellIdentity=CellIdentityLte|mTelephonyDisplayInfo"
    ...    connection=cpc_${ue_index}
    ...    timeout=15
    run keyword if    '${sleep_time_before_read_output}'!='${None}'    BuiltIn.sleep    ${sleep_time_before_read_output}
    ${result} =    csn.read output    connection=cpc_${ue_index}
    Should contain  ${result}    override=NR_NSA    mCi=2579969
    Log to console    \nINFO:UE ATTACH NSA successfully.
    [Teardown]  Run keyword and ignore error    csn.disconnect   connection=cpc_${ue_index}
  
Connect to control pc
    [Documentation]  connect the control PC
    ...   :param cpc_ip: the ip address of control PC
    ...   :param cpc_usrname:  the user name to login in control PC
    ...   :param cpc_passwd: the user password to login in control PC
    [Arguments]    ${cpc_ip}    ${cpc_usrname}   ${cpc_passwd}  ${alias}=test
    ${connection}=    csn.Connect to   ${cpc_ip}    ${cpc_usrname}    ${cpc_passwd}    alias=${alias}
    [Return]   ${connection}


Do Detach UE
    power_ue.UE Detach    ue_type=huawei    
    Log         UE Detached

Disconnect to control pc
    [Arguments]   ${connection}=cygwin
    Run keyword and ignore error    csn.Disconnect	connection=${connection}

Set Display Mode
    [Arguments]    ${connection}    ${serial_number}
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 224    connection=${connection}
    sleep   2s
    csn.send_command    command=adb -s ${serial_number} shell input swipe 300 1000 300 500    connection=${connection}
    sleep   2s
    csn.disconnect      connection=${connection}

Connect to control pc enhanced
    [Documentation]  This keyword's is to connect to the UE control PC, add WA to restart the ssh servers.
    [Arguments]    ${ue_index}=${0}   ${telnet}=${true}
    ...             ${cpc_ip}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...             ${cpc_usrname}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...             ${cpc_passwd}=${tl.ues[${ue_index}].ssh_connection_details.password}

    switchkeywords.Connect to control pc    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}    alias=test


Kill ADB2 application

    switchkeywords.Connect to control pc enhanced
    csn.send_command    command=taskkill /F /IM "adb2.exe"    connection=test
    Sleep    10s
    csn.disconnect    connection=test
    log to console   kill ADB2 application successfully


ADB Reboot UE
    [Documentation]  Use adb command to reboot the android ue device
    [Arguments]     ${serial_number}
	
	switchkeywords.Connect to control pc enhanced
	csn.execute    command=adb -s ${serial_number} reboot   connection=test
	csn.disconnect      connection=test
    sleep    20s
    log to console   ADB Reboot UE successfully


Switch APN to SA

    power_ue.Prepare UE    ue_type=huawei
    Run Keyword And Ignore Error    switchkeywords.Do Detach UE

    sleep                              10s
    Run keyword And Ignore Error    switchkeywords.Do Attach UE
    ${connection}=    switchkeywords.Connect to control pc    cpc_ip=${hostname}    cpc_usrname=${username}   cpc_passwd=${password}    alias=test
    switchkeywords.Set Display Mode    ${connection}    ${serial_number}

    android_mobile.setup
    ...   ui_version=EMUI 11.0.0
    ...   host=${hostname}
    ...   username=${username}
    ...   password=${password}
    ...   port=22
    ...   serial_number=${serial_number}
    ...   alias=test
    ${apn}=   android_mobile.get_access_point_name    mobile=test
    Log    APN before switching:${apn}
    Run keyword if    '${apn}'!='wap1.nokia.com'    android_mobile.switch_apn
    ...    apn_name=wap1.nokia.com    mobile=test
    ${apn}=   android_mobile.get_access_point_name    mobile=test
    Log    APN before switching:${apn}
    android_mobile.teardown    mobile=test
    Should Be Equal    ${apn}    wap1.nokia.com


    switchkeywords.Do Detach UE
    Disconnect to control pc    connection=test

Switch APN to NSA

    power_ue.Prepare UE    ue_type=huawei
    Run Keyword And Ignore Error    switchkeywords.Do Detach UE

    sleep                              10s
    Run keyword And Ignore Error    switchkeywords.Do Attach UE
    ${connection}=    switchkeywords.Connect to control pc    cpc_ip=${hostname}    cpc_usrname=${username}   cpc_passwd=${password}    alias=test
    switchkeywords.Set Display Mode    ${connection}    ${serial_number}

    android_mobile.setup
    ...   ui_version=EMUI 11.0.0
    ...   host=${hostname}
    ...   username=${username}
    ...   password=${password}
    ...   port=22
    ...   serial_number=${serial_number}
    ...   alias=test
    ${apn}=   android_mobile.get_access_point_name    mobile=test
    Log    APN before switching:${apn}
    Run keyword if    '${apn}'!='stdata2'    android_mobile.switch_apn
    ...    apn_name=stdata2    mobile=test
    ${apn}=   android_mobile.get_access_point_name    mobile=test
    Log    APN before switching:${apn}
    android_mobile.teardown    mobile=test
    Should Be Equal    ${apn}    stdata2

    switchkeywords.Do Detach UE
    Disconnect to control pc    connection=test


switch network mode to NSA

    switchkeywords.Kill ADB2 application

	switchkeywords.ADB Reboot UE       ${serial_number}

    ${connection}=    switchkeywords.Connect to control pc    cpc_ip=${hostname}    cpc_usrname=${username}   cpc_passwd=${password}    alias=test
    switchkeywords.Set Display Mode    ${connection}    ${serial_number}


	android_mobile.setup
    ...   ui_version=EMUI 11.0.0
    ...   host=${hostname}
    ...   username=${username}
    ...   password=${password}
    ...   port=22
    ...   serial_number=${serial_number}
    ...   alias=test

    ${network_mode}=   android_mobile.get_network_mode    mobile=test
    Log    network mode before switching:${network_mode}
    Run keyword if    '${network_mode}'!='NSA mode'    android_mobile.switch_network_mode
    ...    mode_name=NSA mode    restart_time=${300}    mobile=test
    ${network_mode}=    android_mobile.get_network_mode    mobile=test
    Log    network mode after switching:${network_mode}
    android_mobile.teardown    mobile=test
    Should Be Equal    ${network_mode}    NSA mode

    switchkeywords.Disconnect to control pc    connection=test


switch network mode to SA

    switchkeywords.Kill ADB2 application

	switchkeywords.ADB Reboot UE    ${serial_number}

    ${connection}=    switchkeywords.Connect to control pc    cpc_ip=${hostname}    cpc_usrname=${username}   cpc_passwd=${password}    alias=test
    switchkeywords.Set Display Mode    ${connection}    ${serial_number}

    android_mobile.setup
    ...   ui_version=EMUI 11.0.0
    ...   host=${hostname}
    ...   username=${username}
    ...   password=${password}
    ...   port=22
    ...   serial_number=${serial_number}
    ...   alias=test


    ${network_mode}=    android_mobile.get_network_mode    mobile=test
    Log    network mode before switching:${network_mode}
    Run keyword if    '${network_mode}'!='SA+NSA mode'    android_mobile.switch_network_mode
    ...    mode_name=SA+NSA mode    restart_time=${300}    mobile=test
    ${network_mode}=    android_mobile.get_network_mode    mobile=test
    Log    network mode after switching:${network_mode}

    android_mobile.teardown    mobile=test

    Should Be Equal    ${network_mode}    SA+NSA mode

    switchkeywords.Disconnect to control pc    connection=test

    
