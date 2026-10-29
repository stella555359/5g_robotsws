*** Settings ***
Documentation     author: Bijiajian
...               contact: Jiajian.bi@nokia-sbell.com
...               squad group: SG_02
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/5GC000399_Keyword.robot

*** Variables ***
${ru_index}    1
#${Tdanger_target}    30.0
${ru_username}    ${tl.enbs[0].rms[0].default_ssh_connection_details.username}
${ru_password}    ${tl.enbs[0].rms[0].default_ssh_connection_details.password}

*** Keywords ***
General_SiSo_RF_alarms_without_recovery
    [Arguments]  ${Tdanger_target}=30    ${tcs_file}=tcs_parameters
    ${Tdanger_init}    Get Tdanger Value from Json File LTE    ru_index=${ru_index}   tcs_file=${tcs_file}
    log to console   \n init Tdanger value:${Tdanger_init}
    log to console    \n Trigger Alarm 1937
    Modify Tdanger Value In Json File with RU reset LTE    init_value=${Tdanger_init}    target_value=${Tdanger_target}
    ...    cmd=touch    ru_index=${ru_index}    tcs_file=${tcs_file}
    log to console   \n Check Alarm 1937 Appear On WebEM
    Wait until keyword succeeds    10min    30s    Wait For Expect Fault Present LTE    faultId=${1937}    timeout=180
    log to console    \n Recovery Alarm 1937
    Modify Tdanger Value In Json File with RU reset LTE    init_value=${Tdanger_target}    target_value=${Tdanger_init}
    ...    cmd=rm -rf    ru_index=${ru_index}    tcs_file=${tcs_file}
    log to console    \n Check Alarm 1937 Disappear On WebEM
    Wait until keyword succeeds    10min    30s    Wait For Expect Fault To Disappear LTE    faultId=${1937}    timeout=180
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair    cell_type=${cell_type}
    [Teardown]    run keywords    Modify Tdanger Value In Json File with RU reset LTE    init_value=${Tdanger_target}
    ...    target_value=${Tdanger_init}    tcs_file=${tcs_file}    cmd=rm -rf    ru_index=${ru_index}    AND
    ...    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair    cell_type=${cell_type}


