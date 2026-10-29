*** Settings ***
Documentation     author: linjiangjing
...               Group: HGZ_SG8
...               contact: jiangjing.lin@nokia-sbell.com

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG08_keywords_cloud.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_ru.robot
Library    ../lib/124756.py
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common.py
Variables    ../TestData/124756_variables.py

*** Variables ***
${scf_path_cu}    ${commissionings_path}/HGZ/${testline_name}/gnbs_0/cu
${scf_path_du}    ${commissionings_path}/HGZ/${testline_name}/gnbs_0/dus_0

*** Keywords ***
CNI124756_09_PS function verification_IWK with 5GC001991 inCB010683_cloud_RF6.1_nonVET
    [Arguments]    ${NRPGRP_index}=0
    log to console    this is CNI124756_09_PS function verification_IWK with 5GC001991 inCB010683_cloud_RF6.1_nonVET

Prepare scf for cases
    set suite variable    ${scf_name_cu_20M}    SCF_SBTS${release_cu}_${version_cu}_20M.xml
    set suite variable    ${scf_name_du_20M}    SCF_SBTS${release_du}_${version_du}_20M.xml

Check Energy saving state for cell
    [Arguments]    ${expected_status}    ${vdu_index}=0    ${alias}=default
    vDU Login    vdu_index=${vdu_index}
    sleep    1s
    ${cells_status}    vdu.get_vdu_cells_status     vdu_connection=${alias}
    should be equal as strings    ${cells_status[0]['energy_saving_state']}    ${expected_status}
    [Teardown]  vDU Logout

Check Operational state for RU
    [Arguments]  ${expected_status}    ${vdu_index}=0    ${alias}=default
    vDU Login    vdu_index=${vdu_index}
    ${rmods_status}    vdu.get_rmods_status    vdu_connection=${alias}
    should be equal as strings    ${rmods_status[0]['operational_state']}    ${expected_status}
    [Teardown]  vDU Logout

Check Power state for RU
    [Arguments]  ${expected_status}    ${vdu_index}=0    ${alias}=default
    vDU Login    vdu_index=${vdu_index}
    ${rmods_status}    vdu.get_rmods_status    vdu_connection=${alias}
    should be equal as strings    ${rmods_status[0]['power_state']}    ${expected_status}
    [Teardown]  vDU Logout


Get Power state for RU
    [Arguments]  ${vdu_index}=0    ${alias}=default
    vDU Login    vdu_index=${vdu_index}
    ${rmods_status}    vdu.get_rmods_status    vdu_connection=${alias}
    [Return]    ${rmods_status[0]['power_state']}
    [Teardown]  vDU Logout
