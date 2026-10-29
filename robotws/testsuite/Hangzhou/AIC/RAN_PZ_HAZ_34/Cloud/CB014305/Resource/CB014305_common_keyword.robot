*** Settings ***
Documentation     author: wang.jiangrong
...               Group: VRF_HAZ3_T02
...               contact: jiangrong.wang@nokia-sbell.com

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG08_keywords_cloud.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
#Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_1/resources/AIC/robot/aic_common_interface.robot
#Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_1/resources/AIC/robot/bts/aic_bts_common_oam.robot


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
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_ru.robot
#Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_cloud.py
#Resource    testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Cloud/CB011039/Resource/CB011039_common_keyword.robot



*** Variables ***
${namespace_vdu}    ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.namespace}
${service_user_password}    bobuWrUHk7Xq7WPpY9ZcjEi8zNdX3plZ+/y420RZ7W4=
${BASIC_PATH_CLOUD}    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/Cloud

${AEQC_ip}    ${tl.gnbs[0].dus[0].fhgws[0].rus[0].default_ssh_connection_details.addr}
${AEQC_username}    ${tl.gnbs[0].dus[0].fhgws[0].rus[0].default_ssh_connection_details.username}
${AEQC_password}    ${tl.gnbs[0].dus[0].fhgws[0].rus[0].default_ssh_connection_details.password}
${snapshot_path}    /home/ute/dtt_log/TESTCASE__[1][3.0]_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot/vdu_snapshot/2025_12_18_11_37_13
*** Keywords ***

commission scf and make call
    [Arguments]    ${vdu_scf_path}    ${cu_scf_path}    ${tput_self_define}    ${target_avg_percent}=0.95
    ...    ${min_percent}=0.85    ${duration}=30    ${process_num}=3
    log to console    commission scf for cu...
    CU Full Commsion By Rest    path_of_commission_file=${cu_scf_path}    plan_name=${mrbtsID}
    log to console    commission scf for du...
    vDU Full Commission SCF    scf_file=${vdu_scf_path}
    log to console    check cell status should be on air for du...
    wait until keyword succeeds     12min    30s    Verify All Cells Status Should Be Onair for vDU
    log to console    check ru status should be normal for du...
    wait until keyword succeeds     12min    30s    Verify All Rmods Status Should Be Normal for vDU
    log to console    check cell status should be on air for cu...
    wait until keyword succeeds     12min    30s    Verify All Cells Are Enabled for CU
    log to console    make call on cells
    data_transfer_common    tput_self_define=${tput_self_define}    target_avg_percent=${target_avg_percent}
    ...    min_percent=${min_percent}    ue_type=${ue_type_NR}    duration=${duration}    process_num=${process_num}
    ...    appserver=APPserversim


Cell_block_and_unblock_and_make_call
    [Arguments]     ${tput_self_define}    ${fault_check}=True
    ${cell_number}    Get vDU Cell numbers
    FOR    ${index}    IN RANGE    1    ${cell_number}+1
        log to console    block cell ${index} for du...
        Block Cell In vDU    cell_id=${index}
        log to console    check cell ${index} should be blocked for du...
        wait until keyword succeeds     3min    5s    Check Cell Should Be Blocked On vDU    cell_id=${index}
        Run keyword If    ${fault_check}==True    Expect Fault Should Present On vDU    fault_id=49
        ...                                       alarming_object=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${index}
    END
    log to console    check cell should be disabled for cu...
    Verify All Cells Are Disabled for CU
    FOR    ${index}    IN RANGE    1    ${cell_number}+1
        log to console    unblock cell ${index} for du...
        Unblock Cell In vDU   cell_id=${index}
    END
    log to console    check cell status should be on air for du...
    wait until keyword succeeds     3min    5s    Verify All Cells Status Should Be Onair for vDU
    log to console    check cell status should be  enabled for cu...
    wait until keyword succeeds     3min    5s    Verify All Cells Are Enabled for CU
    log to console    make call on cells
    data_transfer_common    tput_self_define=${tput_self_define}    target_avg_percent=${target_avg_percent}
    ...    min_percent=${min_percent}    ue_type=${ue_type_NR}    duration=${duration}    process_num=${process_num}
    ...    appserver=APPserversim
    [Teardown]    Run keyword and ignore error    Unblock Cells In vDU

# Cell_block_and_unblock
#     [Arguments]    ${fault_check}=True
#     ${cell_number}    Get vDU Cell numbers
#     FOR    ${index}    IN RANGE    1    ${cell_number}+1
#         log to console    block cell ${index} for du...
#         Block Cell In vDU    cell_id=${index}
#         log to console    check cell ${index} should be blocked for du...
#         wait until keyword succeeds     3min    5s    Check Cell Should Be Blocked On vDU    cell_id=${index}
#         Run keyword If    ${fault_check}==True    Expect Fault Should Present On vDU    fault_id=49
#         ...                                       alarming_object=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${index}
#     END
#     log to console    check cell should be disabled for cu...
#     Verify All Cells Are Disabled for CU
#     FOR    ${index}    IN RANGE    1    ${cell_number}+1
#         log to console    unblock cell ${index} for du...
#         Unblock Cell In vDU   cell_id=${index}
#     END
#     log to console    check cell status should be on air for du...
#     wait until keyword succeeds     3min    5s    Verify All Cells Status Should Be Onair for vDU
#     log to console    check cell status should be  enabled for cu...
#     wait until keyword succeeds     3min    5s    Verify All Cells Are Enabled for CU

# Cell_block_and_unblock
#     [Arguments]     ${vdu_index}=0    ${gnb_index}=0
#     log to console    Cell_block_and_unblock\n
#     ${cell_list}    Cloud Get Cells Id List    vdu_index=${vdu_index}    gnb_index=${gnb_index}
#     FOR    ${index}    IN    @{cell_list}
#         log to console    block cell ${index} for du ${vdu_index}...\n
#         SG08_keywords_cloud.Block Cell In vDU    cell_id=${index}    vdu_index=${vdu_index}    gnb_index=${gnb_index}
#         wait until keyword succeeds     3min    5s    SG08_keywords_cloud.Check Cell Should Be Blocked On vDU    cell_id=${index}
#         ...    vdu_index=${vdu_index}    gnb_index=${gnb_index}
#         Wait Until Keyword Succeeds    5min    5s    SG08_keywords_cloud.Expect Fault Should Present On vDU    fault_id=49    vdu_index=${vdu_index}
#         ...     gnb_index=${gnb_index}
#         ...     alarming_object=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${index}
#     END
#     log to console    check cell should be disabled for cu...\n
#     Verify All Cells Are Disabled For VCU    gnb_index=${gnb_index}
#     FOR    ${index}    IN    @{cell_list}
#         log to console    unblock cell ${index} for du ${vdu_index}...\n
#         SG08_keywords_cloud.Unblock Cell In vDU   cell_id=${index}
#     END
#     log to console    check all cell status should be on air for du...\n
#     wait until keyword succeeds     15min    5s    All Cells Should Be Onair For All vDUs
#     log to console    check cell status should be  enabled for cu...\n
#     wait until keyword succeeds     5min    5s    All Cells Should Be Onair For One Specific vCU

Ru_lock_and_unlock
    ${rmods}    cloud_ru.Get Rmod List
    log to console    lock ru for du...
    lock ru in vdu    rmod_id_list=${rmods}
    log to console    check ru status should be locked for du...
    wait until keyword succeeds     10min    5s    Verify All Rmods Status Should Be Locked for vDU
    log to console    check cell status should be disabled for du..
    wait until keyword succeeds     10min    5s    SG08_keywords_cloud.Verify All Cells Are Disabled for vDU
    log to console    check cell status should be disabled for cu...
    wait until keyword succeeds     10min    5s    Verify All Cells Are Disabled for CU
    log to console    unlock ru for du...
    unlock ru in vdu    rmod_id_list=${rmods}
    log to console    check ru status should be normal for ru...
    wait until keyword succeeds     10min    5s    Verify All Rmods Status Should Be Normal for vDU
    log to console    check cell status should be onair for du...
    wait until keyword succeeds     10min    5s    Verify All Cells Status Should Be Onair for vDU
    log to console    check cell status should be enabled for cu...
    wait until keyword succeeds     10min    5s    Verify All Cells Are Enabled for CU
    [Teardown]    Run keyword and ignore error    unlock ru in vdu    rmod_id_list=${rmods}

RU_module_Reset_from_Web
    ${rmods}    Get Rmod List
    log to console    reset ru for du
    Reset Rmod By Rest    rmods_list=${rmods}
    log to console    check cell status should be disabled for du...
    wait until keyword succeeds     10min    5s    Verify All Cells Are Disabled for vDU
    log to console    check cell status should be disabled for cu...
    wait until keyword succeeds     10min    5s    Verify All Cells Are Disabled for CU
#    log to console    check fault 10 reported on du
#    Expect Fault Should Present On vDU    fault_id=10
    log to console    check cell should be on air for du...
    wait until keyword succeeds     15min    5s    Verify All Cells Status Should Be Onair for vDU
    log to console    check cell should be on air for cu...
    wait until keyword succeeds     15min    5s    Verify All Cells Are Enabled for CU
    log to console    check fault 10 canceled on du
    Expect Fault Should Absent On vDU    fault_id=10
    #log to console    make call on cells
    #data_transfer_common    tput_self_define=${tput_self_define}    target_avg_percent=${target_avg_percent}
    #...    min_percent=${min_percent}    ue_type=${ue_type_NR}    duration=${duration}    process_num=${process_num}
    #...    appserver=APPserversim



Prepare scf for cases
    set suite variable    ${scf_name_cu_100M}    SCF_SBTS${release_cu}_${version_cu}_100M.xml
    set suite variable    ${scf_name_du_100M}    SCF_SBTS${release_du}_${version_du}_100M.xml
    set suite variable    ${scf_name_cu_20M_20M}    SCF_SBTS${release_cu}_${version_cu}_20M_20M.xml
    set suite variable    ${scf_name_du_20M_20M}    SCF_SBTS${release_du}_${version_du}_20M_20M.xml
    set suite variable    ${scf_name_cu_40M_60M}    SCF_SBTS${release_cu}_${version_cu}_40M_60M.xml
    set suite variable    ${scf_name_du_40M_60M}    SCF_SBTS${release_du}_${version_du}_40M_60M.xml
    set suite variable    ${scf_name_cu_50M_100M}    SCF_SBTS${release_cu}_${version_cu}_50M_100M.xml
    set suite variable    ${scf_name_du_50M_100M}    SCF_SBTS${release_du}_${version_du}_50M_100M.xml
    set suite variable    ${scf_name_cu_100M_100M}    SCF_SBTS${release_cu}_${version_cu}_100M_100M.xml
    set suite variable    ${scf_name_du_100M_100M}    SCF_SBTS${release_du}_${version_du}_100M_100M.xml

Reset vDUs Until All Cells Onair In All vDUs
    [Arguments]    ${vdu_list}=${VDU_LIST}    ${timeout}=${ONAIR_TIME}
    FOR    ${vdu}    IN    @{vdu_list}
        ${cu_index}    ${vdu_index}    Split String    ${vdu}    -
        Login To vDU By Rest    vdu_index=${vdu_index}    cu_index=${cu_index}
        ${out}    vdu.reset_vdu
        ${error_msg}    set variable  ${out["error_message"]}
        should contain    ${error_msg}    No error
        ${out}    Wait Until Keyword Succeeds  60   10   _Check Reset VDU Status As Expected    operation_id=${out["id"]}
        ...                                                                                expected_status=ongoing
    END
    Wait For All Cells Onair In All vDUs    timeout=${timeout}
    Check RU List Status Should Be As Expected
    [Teardown]    Run Keyword And Ignore Error    vDU Rest Login

_Check Reset VDU Status As Expected
    [Arguments]    ${operation_id}    ${expected_status}
    ${out}    vdu.get_reset_vdu_operation_status    operation_id=${operation_id}
    Should Be True    "${out["status"]}"=="${expected_status}"
    [Return]    ${out}

vDU Reset
#    [Arguments]    ${timeout}=${ONAIR_TIME}
    vDU Reset VDU And Check Onair For All CUs
    Check RU List Status Should Be As Expected
    Check Alarms In CUs
    Check Alarms In vDUs
    Check Historical Alarms In CUs    additional_allowed_alarms=Matching ServedCell not found over F1-C
    Check Historical Alarms In vDUs

Reset DU
    vDU Rest Login
    Log to console  Reset DUand wait for 3 min ..
    vdu.reset_vdu
    Sleep  180s
    #wait until keyword succeeds    1200s   10s  Get DU F1 Link Status
    log to console    check cell status should be on air for du...
    wait until keyword succeeds     10min    5s    Verify All Cells Status Should Be Onair for vDU
    log to console    check cell status should be  enabled for cu...
    wait until keyword succeeds     10min    5s    Verify All Cells Are Enabled for CU

All vDUs Lock And Unlock
    ${teardown}    Set Variable    ${True}
    vCU Lock All vDU And Check Result For All CUs
    Check Alarms In CUs
    Check Alarms In vDUs
    vCU Unlock All vDU And Check Result For All CUs
    ${teardown}    Set Variable    ${False}
    Wait For All Cells Onair In All vDUs
    Wait For All Cells Onair In All CUs
    [Teardown]    Run Keyword If    ${teardown}    vCU Unlock All vDU And Check Result For All CUs

vCU Lock All vDU And Check Result For All CUs
    [Arguments]    ${cu_list}=${CU_LIST}
    FOR    ${cu_index}    IN    @{cu_list}
        ${du_id_list}=    vCU Get vDU ID List    cu_index=${cu_index}
        vCU Lock vDU And Check Result    ${du_id_list}    cu_index=${cu_index}
    END
    vDU Check All Cells Status    expected_operational_state=disabled    expected_availability_status=off line

vCU Unlock All vDU And Check Result For All CUs
    [Arguments]    ${cu_list}=${CU_LIST}
    FOR    ${cu_index}    IN    @{cu_list}
        ${du_id_list}=    vCU Get vDU ID List    cu_index=${cu_index}
        vCU Unlock vDU And Check Result    ${du_id_list}    cu_index=${cu_index}
    END
    vDU Check All Cells Status    expected_availability_status=on line

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

CU Lock DU
    [Arguments]   ${du_id}  ${gnb_index}=0
    [Documentation]      Lock specified du by du id.
    ...  modified by:        <11-Mar-2020>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...	   |  du_id  | Yes |  DU instance id   |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Lock Specified DU  |   |
    CU Login  ${gnb_index}
    ${return_info}=   cu.lock_du   ${du_id}
    Log    ${return_info}
     #${operation_id}=   set variable    ${return_info}
     #wait until keyword succeeds  60s  5s   CU Check Operation Status For Specified DU Should Be As Expected
     #...    ${du_id}    locked    ${operation_id}   completed   ${gnb_index}
     #CU Check Specified DU Status Should Be As Expected     ${du_id}   locked   ${gnb_index}
    Sleep     30s
    ${result}    cu.get_du_state
    Builtin.Log     ${result['administrative_state']['locked']}
    Should Be Equal    '${result['administrative_state']['locked']}'      '1'

CU Unlock DU
    [Arguments]   ${du_id}  ${gnb_index}=0
    [Documentation]      Unlock specified du by du id.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <11-Mar-2020>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...	   |  du_id  | Yes |  DU instance id   |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |

    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Unlock Specified DU  |   |
     CU Login  ${gnb_index}
     ${return_info}=   cu.unlock_du   ${du_id}
     #${operation_id}=   set variable    ${return_info.id}
     #wait until keyword succeeds  60s  5s   CU Check Operation Status For Specified DU Should Be As Expected
     #...    ${du_id}    unlocked    ${operation_id}   completed     ${gnb_index}
     #CU Check Specified DU Status Should Be As Expected     ${du_id}   unlocked   available  ${gnb_index}
     Sleep     30s
    ${result}    cu.get_du_state
    Builtin.Log     ${result['administrative_state']['unlocked']}
    Should Be Equal    '${result['administrative_state']['unlocked']}'      '1'
    Sleep     60s



Login To CU By Rest
    [Arguments]   ${cu_index}=CU_0   ${alias}=${None}   ${restapi_version}=cuoam_23r1    ${timeout}=120
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

CU online modify parameters
    [Arguments]    ${param}    ${value}    ${MO}    ${gnb_index}=${0}
    CU Rest Login  gnb_index=${gnb_index}
    &{restore_list}=   Create Dictionary    operation_type=replace    parameter_path=/${param}    value=${value}
    #@{restore_list}    Create List    ${restore_list}
    CU Online Parameter Change by rest    para_list=${restore_list}    mo_dn=${MO}
    [Teardown]    run keyword and ignore error   CU Logout

cell lock unlock
  [Arguments]    ${cellnum}
  CU online modify parameters param=administrativeState    value=locked
  ...    MO=MRBTS-${tl.gnbs[${gnb_index}].cu.instance_id}/NRBTS-${tl.gnbs[${gnb_index}].cu.instance_id}/NRCELL-${cellnum}
  ...    gnb_index=${gnb_index}

Collect snapshot
    #[Arguments]    ${ru_index}=1    ${ns}=cran1
    log to console   \nsave local snapshot on vDU...
    #sleep    600
    ${snapshot_path}    Trigger And Save Local Snapshot For vDU
    #log to console   \nsnapshot path: ${snapshot_path}
    #${snapshot_path}="/home/ute/dtt_log/TESTCASE__[1][3.0]_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot/vdu_snapshot/2025_12_18_11_37_13"
    Check radio log    ru_index=1    snapshot_path=${snapshot_path}
    #Check radio log    ru_index=2    snapshot_path=${snapshot_path}
    #Check radio log    ru_index=3    snapshot_path=${snapshot_path}

Check radio log
    [Arguments]    ${ru_index}=1    ${snapshot_path}=${None}
    should exist    ${snapshot_path}/RU_${ru_index}.zip
    # extract zip file    ${snapshot_path}/RU_${ru_index}.zip    ${snapshot_path}/RU_logs
    # ${detail_files}    List Files In Directory    path=${snapshot_path}/RU_logs
    # log to console   \nsave ru logs with command...
    # ${download_rfsw_log_path}    Cloud Collect single RU log and Download    ru_index=${ru_index}    ru_log_path=${snapshot_path}    ns=${ns}
    # #${download_rfsw_log_path}    Cloud Collect RU log and Download    ru_index=${ru_index}    ru_log_path=${snapshot_path}    ns=${ns}
    # ${unzip_path}    ${extension}    split extension    ${download_rfsw_log_path}
    # extract zip file    ${download_rfsw_log_path}    ${unzip_path}
    # ${log_on_ru}    List Files In Directory    path=${unzip_path}
    # log to console   \ncompare ru log files collected from command and vDU snapshot...
    # ${not_include_list}    Create List
    # FOR    ${item}  IN  @{log_on_ru}
    #     @{splits}    string.split string    ${item}    separator=_
    #     ${status}  Run Keyword And Return Status  Should Contain Match   ${detail_files}   regexp=.*${splits[1]}.*
    #     run keyword if    not ${status}    append to list    ${not_include_list}    ${splits[1]}
    # END
    # should be empty    ${not_include_list}
