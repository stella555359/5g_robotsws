*** Settings ***
Documentation     author: Annie Hu
...               Group: HGZ_SG5
...               contact: Annie.hu@nokia-sbell.com

Resource          ../../common/coam_resource.robot

*** Variables ***

*** Keywords ***
get mrbtsid
    ${mrbtsid}    selenium_coam.get_bts_id
    set suite variable    ${mrbtsid}

change fault 61652 trigger param
   [Arguments]      ${new_value}    #it will trigger fault 61652 if paramater is true
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsid}/MNL-1/MNLENT-1/SECADM-1
    ...    filter_param=Activate service port state    new_value=${new_value}    abbr=actServicePortState
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}

trigger fault 61652
    ${result}    run keyword and ignore error    check fault is not in active alarms    alarm_filter=61652
    run keyword if    '${result[0]}'=='FAIL'    change fault 61652 trigger param    new_value=false
    run keyword if    '${result[0]}'=='FAIL'    wait until keyword succeeds    1min    10s    check fault is not in active alarms
    ...    alarm_filter=61652
    change fault 61652 trigger param    new_value=true
    ${fault_61652}    wait until keyword succeeds    1min    10s    check fault is in active alarms    alarm_filter=61652
    [Return]   ${fault_61652}

check fault is in active alarms
    [Arguments]      ${alarm_filter}
    @{alarms}    selenium_coam.get_active_alarm_info    alarm_filter=${alarm_filter}
    should not be empty    ${alarms}
    [Return]    ${alarms}

check fault is not in active alarms
    [Arguments]      ${alarm_filter}
    @{alarms}    selenium_coam.get_active_alarm_info    alarm_filter=${alarm_filter}
    should be empty    ${alarms}

gNB reset via WEBUI
    selenium_coam.reset_site
    sleep    2min

check flag not in swconfig
    [Arguments]      ${connection}    ${flag_exp}
    ${swconfig_file}    csn.execute    command=cat /ffs/run/swconfig.txt    connection=${connection}
    ${result}    run keyword and ignore error    should not contain    ${swconfig_file}    ${flag_exp}
    [Return]    ${result}

crasign swconfig file
    [Arguments]    ${connection}
    csn.execute    command=crasign ${swconfig_path}    connection=${connection}
    csn.execute    command=reboot    connection=${connection}
    sleep     2min

reconnect gNB and check ASIK status
    wait until keyword succeeds      6min    10s     WEBUI Login
    wait until keyword succeeds      8min    10s     Check ASIK is UP

remove flag and update swconfig
    [Arguments]      ${connection}    ${flag_exp}
    csn.execute    command=sed -i -e '/${flag_exp}/d' ${swconfig_path}    connection=${connection}
    ${result}    check flag not in swconfig    connection=${connection}    flag_exp=${flag_exp}
    run keyword if    '${result[0]}'=='PASS'    crasign swconfig file    connection=${connection}
    reconnect gNB and check ASIK status

