*** Settings ***
Library    OperatingSystem
Library    Collections
Library    DateTime

Library           String
Library           OperatingSystem
Library           Collections
Library           taf.ul.oam.selenium_megazone    WITH NAME    sm
Library           taf.transport.ssh    WITH NAME    ssh
Resource          taf/rfrl/common_resources/robot/connections.robot

*** Variables ***
${pm_min_period}    15

*** Keywords ***
Clear PMCounter Temps
    #Connect to OAM via SSH
	Connect to OAM
    ${outcome}    csn.execute     ls -lrt /mnt/services/mzoam/config/5G*/pm/reports/|head -2| awk '{print $9}'        connection=OAM
    ${outcome}    Strip String    ${outcome}
    csn.send command    cd /mnt/services/mzoam/config/5G*/pm/reports/;ls |grep -v ${outcome} |xargs rm -f    connection=OAM
    csn.disconnect    connection=OAM

Connect to ASOD_ASIK
    [Arguments]    ${alias}=ASOD_ASIK    ${proxy}=${null}

    Set Variable    ${host_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    Set Variable    ${host_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    Set Variable    ${host_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}

    Connect via root if passed username fails    hostname=${host_addr}    username=${host_username}
    ...     password=${host_password}
    ...     alias=${alias}    proxy=${proxy}

Get Curr Period Time
    Connect to ASOD ASIK
    ${curr_sec_str}=    csn.execute    date -u +"%s"    connection=ASOD_ASIK
    ${curr_sec}=    Convert To Integer    ${curr_sec_str}
    log to console    ${curr_sec}
    ${begin_str}=    Convert Date    ${curr_sec}    result_format=%Y-%m-%dT%H:%M    date_format=%s
    log    ${begin_str}
    [Return]    ${begin_str}

Get Curr Utc Period Time
    Connect to ASOD ASIK
    ${curr_utc_str}=    csn.execute    date -u +"%Y-%m-%d %H:%M:%S%z"    connection=ASOD_ASIK
    log to console    ${curr_utc_str}
    [Return]    ${curr_utc_str}

Get Curr Periodes Time with Added Pm Periods
    [Arguments]    ${number_pm_period}
    Connect to ASOD ASIK
    ${curr_sec_str}=    csn.execute    date -u +"%s"    connection=ASOD_ASIK
    ${curr_sec}=    Convert To Integer    ${curr_sec_str}
    Log    ${curr_sec_str}
    ${number_pm_period} =    Convert To Integer    ${number_pm_period}
    Log    ${number_pm_period}
    ${final_sec}=    Evaluate    ${curr_sec}+${pm_min_period}*${number_pm_period}*60
    ${final_sec}=    Convert Date    ${final_sec}    result_format=%Y-%m-%dT%H:%M    date_format=%s
    log    ${final_sec}
    [Return]    ${final_sec}
