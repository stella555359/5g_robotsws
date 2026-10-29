*** Settings ***
Documentation     author: linjiangjing
...               Group: HGZ_SG8
...               contact: jiangjing.lin@nokia-sbell.com

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG08_keywords_cloud.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Variables    ../TestData/8964_variables.py


*** Variables ***
${ue_type_NR}    askey_vran20
${namespace_vdu}    ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.namespace}
${service_user_password}    bobuWrUHk7Xq7WPpY9ZcjEi8zNdX3plZ+/y420RZ7W4=
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
    [Arguments]     ${tput_self_define}    ${target_avg_percent}=0.95
    ...    ${min_percent}=0.85    ${duration}=600    ${process_num}=3    ${fault_check}=True
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

Ru_lock_and_unlock_and_make_call
    [Arguments]    ${tput_self_define}    ${target_avg_percent}=0.95
    ...    ${min_percent}=0.85    ${duration}=600    ${process_num}=3
    ${rmods}    Get Rmod List
    log to console    lock ru for du...
    lock ru in vdu    rmod_id_list=${rmods}
    log to console    check ru status should be locked for du...
    wait until keyword succeeds     3min    5s    Verify All Rmods Status Should Be Locked for vDU
    log to console    check cell status should be disabled for du..
    Verify All Cells Are Disabled for vDU
    log to console    check cell status should be disabled for cu...
    Verify All Cells Are Disabled for CU
    log to console    unlock ru for du...
    unlock ru in vdu    rmod_id_list=${rmods}
    log to console    check ru status should be normal for ru...
    wait until keyword succeeds     3min    5s    Verify All Rmods Status Should Be Normal for vDU
    log to console    check cell status should be onair for du...
    wait until keyword succeeds     3min    5s    Verify All Cells Status Should Be Onair for vDU
    log to console    check cell status should be enabled for cu...
    wait until keyword succeeds     3min    5s    Verify All Cells Are Enabled for CU
    log to console    make call on cells
    data_transfer_common    tput_self_define=${tput_self_define}    target_avg_percent=${target_avg_percent}
    ...    min_percent=${min_percent}    ue_type=${ue_type_NR}    duration=${duration}    process_num=${process_num}
    ...    appserver=APPserversim
    [Teardown]    Run keyword and ignore error    unlock ru in vdu    rmod_id_list=${rmods}

RU_module_Reset_from_Web_and_make_call
    [Arguments]    ${tput_self_define}    ${target_avg_percent}=0.95
    ...    ${min_percent}=0.85    ${duration}=30    ${process_num}=3
    ${rmods}    Get Rmod List
    log to console    reset ru for du
    Reset Rmod By Rest    rmods_list=${rmods}
    log to console    check cell status should be disabled for du...
    wait until keyword succeeds     3min    5s    Verify All Cells Are Disabled for vDU
    log to console    check cell status should be disabled for cu...
    wait until keyword succeeds     3min    5s    Verify All Cells Are Disabled for CU
#    log to console    check fault 10 reported on du
#    Expect Fault Should Present On vDU    fault_id=10
    log to console    check cell should be on air for du...
    wait until keyword succeeds     5min    5s    Verify All Cells Status Should Be Onair for vDU
    log to console    check cell should be on air for cu...
    wait until keyword succeeds     5min    5s    Verify All Cells Are Enabled for CU
    log to console    check fault 10 canceled on du
    Expect Fault Should Absent On vDU    fault_id=10
    log to console    make call on cells
    data_transfer_common    tput_self_define=${tput_self_define}    target_avg_percent=${target_avg_percent}
    ...    min_percent=${min_percent}    ue_type=${ue_type_NR}    duration=${duration}    process_num=${process_num}
    ...    appserver=APPserversim

trigger fault 7116
    [Arguments]    ${vdu_index}=0    ${fault_id}=1911    ${alarm_id}=7116    ${severity}=major
    log to console    login vdu ssh server
    ${alias}  get unique id
    Connect To vDU K8s Master   vdu_index=${vdu_index}  alias=${alias}
    log to console    get ru ip
    ${ru_ip}    get ru ip    alias=${alias}    ns=${namespace_vdu}
    log to console    login ru
    login ru    alias=${alias}    ru_ip=${ru_ip}    username=serviceuser    password=${service_user_password}
    log to console     execute 8 command
    FOR    ${command}    IN    @{commands}
         ${cmd}    set variable    sudo ${command}
         ${out}    issh.Execute   command=${cmd}    alias=${alias}     check_result=${False}
         sleep    1s
    END
    log to console    check fault 1911 should be reported
    Wait until keyword succeeds    6min    5sec    Expect Fault Should Present On vDU    fault_id=${fault_id}
    ...    alarm_id=${alarm_id}    severity=${severity}
    [Teardown]    run keywords    run keyword and ignore error  issh.disconnect  alias=${alias}    AND
    ...    Reset vDU With Check Cell On Air    AND
    ...    Expect Fault Should Absent On vDU    fault_id=${fault_id}    alarm_id=${alarm_id}    severity=${severity}

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
