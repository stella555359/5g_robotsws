*** Settings ***
Documentation     author: Yang Liqin
...               contact: liqin.yang@nokia-sbell.com
...               squad group: MMW_SG_05
Library     taf.ul.mobile.ui.android     WITH NAME   android_mobile
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
# Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/l3call.robot



*** Keywords ***
Verify attach by adb
    [Arguments]    ${physCellId}=${None}    ${ue_index}=${0}    ${sleep_time_before_read_output}=5s
    ...   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...   ${attach_mode}=5G_NSA    ${5G_check}=False
    Connect to control pc via cygwin    ue_index=${ue_index}
    csn.send command    command=adb -s ${serial_number} shell svc data enable
    ...    connection=cygwin
    ...    timeout=15
    csn.send command
    ...    command=adb -s ${serial_number} shell dumpsys telephony.registry
    ...    connection=cygwin
    ...    timeout=15
    run keyword if    '${sleep_time_before_read_output}'!='${None}'    BuiltIn.sleep    ${sleep_time_before_read_output}
    ${result} =    csn.read output    connection=cygwin
    Run Keyword If   '${attach_mode}' == '5G_NSA'    Should contain  ${result}    accessNetworkTechnology=LTE
    Run Keyword If  '${attach_mode}' == '5G_NSA' and '${5G_check}'!='False'  Should contain  ${result}  nrState=CONNECTED
    Should contain  ${result}    mDataRegState=0
    Run Keyword If   '${attach_mode}' == '5G_NSA'    Log to console    \nINFO:UE ATTACH NSA successfully.
    Run Keyword If   '${attach_mode}' == '5G_SA'    Should contain  ${result}    accessNetworkTechnology=NR
    Run Keyword If   '${attach_mode}' == '5G_SA'    Should contain  ${result}    mPci = ${physCellId}
    Run Keyword If   '${attach_mode}' == '5G_SA'    Log to console    \nINFO:UE ATTACH SA successfully.
    [Teardown]  Run keyword and ignore error    csn.disconnect   connection=cygwin

Kill ADB application
    [Arguments]    ${ue_index}=${0}
    Connect to control pc via cygwin    ue_index=${ue_index}
    csn.send_command    command=taskkill /F /IM "adb.exe"    connection=cygwin
    Sleep    10s
    log to console   kill ADB application successfully
    [Teardown]  Run keyword and ignore error    csn.disconnect   connection=cygwin

Verify SA UE handover by adb
    [Arguments]    ${target_physCellId}=${None}    ${ue_index}=${0}    ${sleep_time_before_read_output}=5s
    ...   ${serial_number}=${tl.ues[${ue_index}].serial_number}  ${source_physCellId}=${None}
    Connect to control pc via cygwin    ue_index=${ue_index}
    csn.send command
    ...    command=adb -s ${serial_number} shell dumpsys telephony.registry
    ...    connection=cygwin
    ...    timeout=15
    run keyword if    '${sleep_time_before_read_output}'!='${None}'    BuiltIn.sleep    ${sleep_time_before_read_output}
    ${result} =    csn.read output    connection=cygwin
    Should contain  ${result}    mDataRegState=0
    Should contain  ${result}    accessNetworkTechnology=NR
    Should contain  ${result}    mPci = ${target_physCellId}
    Should Not Contain    ${result}    mPci = ${source_physCellId}
    Log to console    \nINFO:UE_${ue_index} Handover from ${source_physCellId} to ${target_physCellId} successfully.
    [Teardown]  Run keyword and ignore error    csn.disconnect   connection=cygwin

Get nrCellIdentity for SA UE
    [Arguments]  ${nrCId}=${None}  ${ue_index}=${0}    ${sleep_time_before_read_output}=5s
    ...   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc via cygwin    ue_index=${ue_index}
    csn.send_command  command=adb -s ${serial_number} shell getprop gsm.network.type    connection=cygwin
    Run Keyword If    '${sleep_time_before_read_output}'!='${None}'    BuiltIn.sleep    ${sleep_time_before_read_output}
    ${result}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=cygwin
    Should contain  ${result}  NR_SA
    csn.send_command  command=adb -s ${serial_number} shell dumpsys telephony.registry|grep mNci|grep -v grep|awk '{print $23}'
    ...    connection=cygwin
    Run Keyword If    '${sleep_time_before_read_output}'!='${None}'    BuiltIn.sleep    ${sleep_time_before_read_output}
    ${out}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=cygwin
    @{output}    Split To Lines    ${out}
    FOR    ${line}    IN    @{output}
      ${pid}=         Get Regexp Matches    ${line}    (-?[1-9]\\d*|0)
      ${length}  Get Length  ${pid}
      ${nrcellid}  Set Variable If  ${length}==1  ${pid}[0]
      Exit For Loop If    ${length}==1
    END
    Run Keyword If  '${nrcellid}'=='${nrCId}'  log to console    \nUE_${ue_index} attach target cell successfully....
    ...  ELSE  log to console    \nUE_${ue_index} attach other cell(${nrcellid}) successfully....
    [Teardown]  Run keyword and ignore error    csn.disconnect   connection=cygwin

Reboot UE If no UE IP
    [Arguments]  ${ue_index}=${0}  ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc via cygwin    ue_index=${ue_index}
    csn.send command    command=adb -s ${serial_number} shell svc data enable
    ...    connection=cygwin
    ...    timeout=15
    ${status}  Run Keyword And Return Status  Verify UE detach successfully for commerical UE  ue_index=${ue_index}
    Run Keyword If  ${status}  Run Keywords  Log To Console  Reboot UE If no UE IP
    ...  AND  Commercial_mobile_phone_adb_common_keywords.Andriod UE adb reboot  ue_index=${ue_index}
    [Teardown]  Run keyword and ignore error    csn.disconnect   connection=cygwin

UE Prepare
    [Arguments]  ${ue_index}=${0}  ${ue_type}=${ue_type_${ue_index}}  ${iperf_port}=default
    Log To Console  UE Prepare for UE${ue_index}
    Run Keyword And Ignore Error    power_ue.Prepare UE    ue_type=${ue_type}  ue_index=${ue_index}
    Run keyword if   '${ue_type}'=='xiaomi'   Get all xiaomi11 pointer variable
    ${status}  Run Keyword If  '${cpe}'=='False'  Run Keyword And Return Status  Verify UE detach successfully for commerical UE  ue_index=${ue_index}
    Run Keyword If  '${status}'!='True' and '${cpe}'=='False'  Run Keyword And Ignore Error   Dettach UE and Stop traffic
    ...  ue_index=${ue_index}  iperf_port=${iperf_port}

Get all xiaomi11 pointer variable
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    1235 2192
    Set Suite Variable    ${close_task}    710 2766
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    1300 2700 1300 2700
    Set Suite Variable    ${open_iperf_location}    500 2050
    Set Suite Variable    ${iperf_button}    730 300
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${5G}    900 960

Dettach UE and Stop traffic
    [Arguments]  ${iperf_port}=default  ${protocol}=udp    ${ue_index}=${0}  ${ue_type}=${ue_type_${ue_index}}  ${direction}=both  ${Dettach}=${True}
    Log To Console    \n UE${ue_index} Dettach and Stop traffic
    Run Keyword If  ${Dettach}  power_ue.UE Detach     ue_type=${ue_type}    ue_index=${ue_index}
    ${iperf_type}  Set Variable If  '${direction}'!='dl' and '${ue_type}'!='huawei'  via_command  via_app
    power_ue.Stop traffic    direction=ul    ue_index=${ue_index}    ue_type=${ue_type}  iperf_type=${iperf_type}  protocol=${protocol}
    ...  iperf_port=${iperf_port}
    power_ue.Stop traffic    direction=dl    ue_index=${ue_index}    ue_type=${ue_type}  protocol=${protocol}
    ...  iperf_port=${iperf_port}

Switch APN
    [Arguments]  ${ui_version}  ${new_APN}  ${ue_index}=${0}  ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...  ${hostname}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...  ${username}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...  ${password}=${tl.ues[${ue_index}].ssh_connection_details.password}
    ...  ${ue_type}=${ue_type_${ue_index}}
    android_ue.UE Prepare  ue_index=${ue_index}  ue_type=${ue_type}
    sleep                              10s
    Run keyword And Ignore Error    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    android_mobile.setup
    ...   ui_version=${ui_version}
    ...   host=${hostname}
    ...   username=${username}
    ...   password=${password}
    ...   port=22
    ...   serial_number=${serial_number}
    ...   alias=test
    ${apn}=   android_mobile.get_access_point_name    mobile=test
    Log    APN before switching:${apn}
    Run keyword if    '${apn}'!='${new_APN}'    android_mobile.switch_apn
    ...    apn_name=${new_APN}    mobile=test
    ${apn}=   android_mobile.get_access_point_name    mobile=test
    Log    APN before switching:${apn}
    android_mobile.teardown    mobile=test
    Should Be Equal    ${apn}    ${new_APN}
    [Teardown]  power_ue.UE Detach     ue_type=${ue_type}    ue_index=${ue_index}

Verify UE detach successfully for commerical UE
    [Documentation]    author: Liu Zheng
    [Arguments]    ${ue_index}=${0}
    Get Commercial UE IP    ue_index=${ue_index}
	${passed}    Run Keyword And Return Status   Should Contain     ${UE_IP}    127.0.0
	Should be true    ${passed}==${True}
