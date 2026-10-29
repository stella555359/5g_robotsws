*** Settings ***
Documentation
...    Author:mengyan
...    Contact:meng.yan@nokia-sbell.com
...    Group: RAN_PZ_HAZ_3
...    Feature: CB010648

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG08_keywords_cloud.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot

*** Variables ***
${MRBTS_ID}    ${tl.gnbs[0].cu.instance_id}
${SBTS_RM_MAX_TEMPERATURE_DIST}    MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
${SBTS_SFP_RM_AVG_TEMPERATURE_DIST}    MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1/SFP-1
${ns}    ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.namespace}
${namespace_vdu}    ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.namespace}
${service_user_password}    bobuWrUHk7Xq7WPpY9ZcjEi8zNdX3plZ+/y420RZ7W4=
*** Keywords ***
Cell_block_and_unblock_10648
    [Arguments]     ${fault_check}=True
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
    #log to console    make call on cells
    #data_transfer_common    tput_self_define=${tput_self_define}    target_avg_percent=${target_avg_percent}
    #...    min_percent=${min_percent}    ue_type=${ue_type_NR}    duration=${duration}    process_num=${process_num}
    #...    appserver=APPserversim
    [Teardown]    Run keyword and ignore error    Unblock Cell In vDU

Ru_lock_and_unlock_10648
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
    [Teardown]    Run keyword and ignore error    unlock ru in vdu    rmod_id_list=${rmods}

RU_module_Reset_from_Web_10648
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