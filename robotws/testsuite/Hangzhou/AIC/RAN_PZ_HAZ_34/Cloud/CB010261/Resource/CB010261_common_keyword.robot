*** Settings ***
Documentation     author: Lusha Zhang
...               Group: VRF_HAZ3_T02
...               contact: lusha.zhang@nokia-sbell.com

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    ${BASIC_PATH_CLOUD}/Cloud_Setup_and_Teardown.robot
Resource    ${BASIC_PATH_CLOUD}/General_SiSo_Commissioning_BTS_Template_Commissioning_Cloud.robot
Resource    ${BASIC_PATH_CLOUD}/General_SiSo_Cell_block_and_unblock_Cloud.robot
Resource    ${BASIC_PATH_CLOUD}/Cloud_General_SiSo_vDU_Reset.robot
Resource    ${BASIC_PATH_CLOUD}/General_SiSo_RU_module_reset_from_GUI_Cloud.robot
Resource    ${BASIC_PATH_CLOUD}/Cloud_Manual_SiSo_SM_RF_Module_lock_unlock.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_Common.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_cloud.py


*** Variables ***
${BASIC_PATH_CLOUD}    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/Cloud

*** Keywords ***
Tribe Common Test Setup
    robot_common_operations.Common Case Setup
    Cloud Test Setup

Tribe Common Test Teardown
    robot_common_operations.Common Case Teardown
    Cloud Test Teardown
    #CI interface.Common Case Teardown has been included in Cloud Test Teardown

Tribe Common Test Setup with allowed faults
    [Arguments]    ${allowed_faults_ids}
    robot_common_operations.Common Case Setup    allowed_faults_ids=${allowed_faults_ids}
    Cloud Test Setup

vDU lock Test Teardown
    [Arguments]     ${du_id_list}
    robot_common_operations.Common Case Teardown
    Run Keyword And Ignore Error    vCU Unlock vDU    du_id_list=${du_id_list}
    Cloud Test Teardown
    #CI interface.Common Case Teardown has been included in Cloud Test Teardown

Get_vdu_and_vcu_release_version
    vDU Login
    ${vdu_state_data}    vdu.get_vdu_state_data
    ${du_software_verion}    set variable   ${vdu_state_data['software_version']}
    ${release_du}    ${version_du}    get_relase_and_version    software_verion=${du_software_verion}
    log to console    release of du is: ${release_du}, version of du is: ${version_du}
    set suite variable    ${release_du}
    set suite variable    ${version_du}
    Login To CU By Rest
    ${cu_state_data}    cu.get_cu_state
    ${cu_software_verion}    set variable   ${cu_state_data['software_version']}
    ${release_cu}    ${version_cu}    get_relase_and_version    software_verion=${cu_software_verion}
    log to console    release of cu is: ${release_cu}, version of cu is: ${version_cu}
    set suite variable    ${release_cu}
    set suite variable    ${version_cu}
    [Teardown]    run keywords    vDU Logout    AND    CU Logout

Cell_block_and_unblock
    [Arguments]     ${vdu_index}=0    ${gnb_index}=0
    log to console    Cell_block_and_unblock\n
    ${cell_list}    Cloud Get Cells Id List    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    FOR    ${index}    IN    @{cell_list}
        log to console    block cell ${index} for du ${vdu_index}...\n
        Block Cell In vDU    cell_id=${index}    vdu_index=${vdu_index}    gnb_index=${gnb_index}
        wait until keyword succeeds     3min    5s    Check Cell Should Be Blocked On vDU    cell_id=${index}
        ...    vdu_index=${vdu_index}    gnb_index=${gnb_index}
        Wait Until Keyword Succeeds    5min    5s    Expect Fault Should Present On vDU    fault_id=49    vdu_index=${vdu_index}
        ...     gnb_index=${gnb_index}
        ...     alarming_object=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${index}
    END
    log to console    check cell should be disabled for cu...\n
    Verify All Cells Are Disabled For VCU    gnb_index=${gnb_index}
    FOR    ${index}    IN    @{cell_list}
        log to console    unblock cell ${index} for du ${vdu_index}...\n
        Unblock Cell In vDU   cell_id=${index}
    END
    log to console    check all cell status should be on air for du...\n
    wait until keyword succeeds     15min    5s    All Cells Should Be Onair For All vDUs
    log to console    check cell status should be  enabled for cu...\n
    wait until keyword succeeds     5min    5s    All Cells Should Be Onair For One Specific vCU

vCU Unlock vDU And Check Result
    [Arguments]    ${du_id_list}    ${cu_index}=CU_0
    vCU Unlock vDU    ${du_id_list}    cu_index=${cu_index}
    FOR   ${du_id}   IN   @{du_id_list}
        Wait Until Keyword Succeeds    120s    5s    vCU Get vDU And Check
        ...    ${du_id}    expected_state=unlocked    cu_index=${cu_index}
    END
vCU Lock vDU And Check Result
    [Arguments]    ${du_id_list}    ${cu_index}=CU_0
    vCU Lock vDU    ${du_id_list}    cu_index=${cu_index}
    FOR   ${du_id}   IN   @{du_id_list}
        Wait Until Keyword Succeeds    120s    5s    vCU Get vDU And Check
        ...    ${du_id}    expected_state=locked    cu_index=${cu_index}
    END

vCU Lock vDU
    [Arguments]    ${du_id_list}    ${cu_index}=CU_0
    Login To CU By Rest    cu_index=${cu_index}
    ${return_info}=    cu.lock_du    ${du_id_list}
    Wait Until Keyword Succeeds    60s    3s    vCU Get Lock vDU Opeartion State    ${return_info["id"]}
    [Teardown]    Run Keyword And Ignore Error    Logout To CU By Rest

vCU Unlock vDU
    [Arguments]    ${du_id_list}    ${cu_index}=CU_0
    Login To CU By Rest    cu_index=${cu_index}
    ${return_info}=    cu.unlock_du    ${du_id_list}
    Wait Until Keyword Succeeds    60s    3s    vCU Get Lock vDU Opeartion State    ${return_info["id"]}
    [Teardown]    Run Keyword And Ignore Error    Logout To CU By Rest

vCU Get vDU And Check
    [Arguments]    ${du_id}    ${expected_state}=unlocked    ${cu_index}=CU_0
    Login To CU By Rest    cu_index=${cu_index}
    ${du_info}=    cu.get_du    du_id=${du_id}
    ${administrative_state}    Convert To Lowercase    ${du_info["administrative_state"]}
    Should Be True    "${administrative_state}"=="${expected_state}"
    [Teardown]    Run Keyword And Ignore Error    Logout To CU By Rest

vCU Get Lock vDU Opeartion State
    [Arguments]    ${operation_id}    ${expect_result}=success
    ${opt_info}    cu.get_opeartion_state_of_locking_du    operation_id=${operation_id}
    Should Be True    "${opt_info["status"]}"=="${expect_result}"

Login To CU By Rest
    [Arguments]   ${cu_index}=CU_0   ${alias}=${None}   ${restapi_version}=cuoam_25r2    ${timeout}=120
    ${gnb_index}    Fetch From Right    ${cu_index}    _
    ${host}    set variable  ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    run keyword and ignore error    Logout To CU By Rest
    cu.connect to    host=${host}
    ...    port=${EMPTY}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...    cu_version=${restapi_version}
    ...    secure=${True}
    ...    alias=${alias}
    ...    timeout=${timeout}
    [Return]  ${alias}

Logout To CU By Rest
    [Arguments]    ${connection}=${None}
    cu.disconnect    connection=${connection}
