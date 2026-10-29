*** Settings ***
Documentation     author: Bijiajian
...               contact: Jiajian.bi@nokia-sbell.com
...               squad group: SG_02
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/5GC000399_Keyword.robot

*** Variables ***
${ru_index}    1
${ru_username}    ${tl.enbs[0].rms[0].default_ssh_connection_details.username}
${ru_password}    ${tl.enbs[0].rms[0].default_ssh_connection_details.password}
${asik_addr}    ${sbts_addr}
${asik_username}    ${ssh_username}
${asik_password}    ${ssh_password}

*** Keywords ***
General_SiSo_RF_alarms_with_recovery
    Modify Calibration File On RU Unit LTE    current_name=calibration_dlpath1    new_name=calibration_dlpath1_bk
    ...    ru_index=${ru_index}
    Wait until keyword succeeds    20min    120s    RU Status Should Be Failed    ru_index=${ru_index}
    log to console    \n Check Fault 1901 Present on WebUI
    Wait For Expect Fault Present LTE   faultId=${1901}    timeout=1200
	Wait until keyword succeeds    20min    120s    Modify Calibration File On RU Unit LTE    current_name=calibration_dlpath1_bk
    ...    new_name=calibration_dlpath1    ru_index=${ru_index}
    log to console    \n Check Fault 1901 Absent on WebUI
    Wait For Expect Fault To Disappear LTE   faultId=${1901}    timeout=1200
    log to console    \n Check all cell on air
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair    cell_type=${cell_type}
    [Teardown]  Modify Calibration File On RU Unit LTE    current_name=calibration_dlpath1_bk
    ...    new_name=calibration_dlpath1    ru_index=${ru_index}
