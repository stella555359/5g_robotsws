*** Settings ***
Documentation     author: linjiangjing
...               Group: HGZ_SG8
...               contact: jiangjing.lin@nokia-sbell.com

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG08_keywords_cloud.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_ru.robot
Library    ../lib/CB010411.py
Variables    ../TestData/10411_variables.py

*** Variables ***
${SBTS_RM_MAX_TEMPERATURE}    M40008C1
${SBTS_SFP_RM_AVG_TEMPERATURE}    M40005C2
${MRBTS_ID}    ${tl.gnbs[0].cu.instance_id}
${NRBTS_ID}    ${tl.gnbs[0].cu.global_bts_id}
${SBTS_RM_MAX_TEMPERATURE_DIST}    MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
${SBTS_SFP_RM_AVG_TEMPERATURE_DIST}    MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1/SFP-1
${ns}    ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.namespace}
${ue_type_NR}    askey_vran20
${namespace_vdu}    ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.namespace}
${service_user_password}    bobuWrUHk7Xq7WPpY9ZcjEi8zNdX3plZ+/y420RZ7W4=
${CB010411_json_path}    ${CURDIR}/json
${enabled_counter}    ${CB010411_json_path}/enabled_counters_paramters.json
${swap_mMimoAntArrayMode}    ${CB010411_json_path}/swap_mMimoAntArrayMode_value.json
${disabled_counter_mtSBTSRMODTemperature}    ${CB010411_json_path}/disabled_counter_mtSBTSRMODTemperature.json
${disabled_counter_mtSBTSSfpRMOD}    ${CB010411_json_path}/disabled_counter_mtSBTSSfpRMOD.json
${enabled_parameter_sfpOperatorMode}    ${CB010411_json_path}/enabled_parameter_sfpOperatorMode.json
*** Keywords ***
activate and deactivate rmod max temperature counter
    sleep    15min
    ${date}    Get Current Date
    ${split_date}=    Split String    ${date}    :
    ${current_minute_number}=    Convert To String    ${split_date}[1]
    @{handler_minute_number}    create list     00    14    15    29    30    44    45    59
    ${status}=    Run Keyword And Return Status    List Should Contain Value    ${handler_minute_number}    ${current_minute_number}
    Run Keyword If    ${status}==True    sleep    2min
    ${counter_before}    Get Pointed Counter For vDU    counter_id=${SBTS_RM_MAX_TEMPERATURE}    dimension_dn=${SBTS_RM_MAX_TEMPERATURE_DIST}
    log to console    counter info before sleep 15min: ${counter_before}
    sleep    15min
    log to console    ******check counter the first time*********
    ${counter_after}    Get Pointed Counter For vDU    counter_id=${SBTS_RM_MAX_TEMPERATURE}    dimension_dn=${SBTS_RM_MAX_TEMPERATURE_DIST}
    log to console    counter info after sleep 15min: ${counter_after}
    Should Be Equal      ${counter_before[-1]}    ${counter_after[-2]}
    #Should Not Be Equal    ${counter_after[-1]['value']}    ${Null}
    Should Be True    ${counter_after[-1]['value']}<100
    sleep    15min
    log to console    *****check counter the second time**********
    ${counter_last}    Get Pointed Counter For vDU    counter_id=${SBTS_RM_MAX_TEMPERATURE}    dimension_dn=${SBTS_RM_MAX_TEMPERATURE_DIST}
    log to console    counter info after the second sleep 15min: ${counter_last}
    Should Be Equal      ${counter_after[-1]}    ${counter_last[-2]}
    #Should Not Be Equal    ${counter_last[-1]['value']}    ${Null}
    Should Be True    ${counter_last[-1]['value']}<100
    log to console    set mtSBTSRMODTemperature to disabled
#    ${mo_dn}    set variable    MRBTS-${mrbtsID}/MNL-1/MNLENT-1/PMMNL-1
#    &{parameter_dict}    Create Dictionary   mtSBTSRMODTemperature=disabled
#    vDU Login SG8
#    ${value}    Online Get VDU Parameter Value    mo_dn=${mo_dn}    para_name=mtSBTSRMODTemperature
#    run keyword if    '${value}'!='disabled'    VDU Online Modify Parameters By Delta Plan REST    mo_dn=${mo_dn}
#    ...    updated_paras_list=${parameter_dict}
    VDU Delta recommission update parameters by M2M API    delta_file=${disabled_counter_mtSBTSRMODTemperature}    wait_for_completion=True
    ${counter_before}    Get Pointed Counter For vDU    counter_id=${SBTS_RM_MAX_TEMPERATURE}    dimension_dn=${SBTS_RM_MAX_TEMPERATURE_DIST}
    log to console    counter info before sleep 15min: ${counter_before}
    sleep    15min
    log to console    ******check counter*********
    ${counter_after}    Get Pointed Counter For vDU    counter_id=${SBTS_RM_MAX_TEMPERATURE}    dimension_dn=${SBTS_RM_MAX_TEMPERATURE_DIST}
    log to console    counter info after sleep 15min: ${counter_after}
    Should Be Equal      ${counter_before[-1]}    ${counter_after[-1]}
#    sleep    15min
#    log to console    *****check counter**********
#    ${counter_last}    Get Pointed Counter For vDU    counter_id=${SBTS_RM_MAX_TEMPERATURE}    dimension_dn=${SBTS_RM_MAX_TEMPERATURE_DIST}
#    log to console    counter info after the second sleep 15min: ${counter_last}
#    Should Be Equal      ${counter_after[-1]}    ${counter_last[-1]}
    [Teardown]    run keyword and ignore error    vDU Logout SG8

activate and deactivate sfp rm avg temperature counter
    sleep    15min
    ${date}    Get Current Date
    ${split_date}=    Split String    ${date}    :
    ${current_minute_number}=    Convert To String    ${split_date}[1]
    @{handler_minute_number}    create list     00    14    15    29    30    44    45    59
    ${status}=    Run Keyword And Return Status    List Should Contain Value    ${handler_minute_number}    ${current_minute_number}
    Run Keyword If    ${status}==True    sleep    2min
    ${counter_before}    Get Pointed Counter For vDU    counter_id=${SBTS_SFP_RM_AVG_TEMPERATURE}    dimension_dn=${SBTS_SFP_RM_AVG_TEMPERATURE_DIST}
    log to console    counter info before sleep 15min: ${counter_before}
    sleep    15min
    log to console    ******check counter the first time*********
    ${counter_after}    Get Pointed Counter For vDU    counter_id=${SBTS_SFP_RM_AVG_TEMPERATURE}    dimension_dn=${SBTS_SFP_RM_AVG_TEMPERATURE_DIST}
    log to console    counter info after sleep 15min: ${counter_after}
    Should Be Equal      ${counter_before[-1]}    ${counter_after[-2]}
    #Should Not Be Equal    ${counter_after[-1]['value']}    ${Null}
    Should Be True    ${counter_after[-1]['value']}<100
    sleep    15min
    log to console    *****check counter the second time**********
    ${counter_last}    Get Pointed Counter For vDU    counter_id=${SBTS_SFP_RM_AVG_TEMPERATURE}    dimension_dn=${SBTS_SFP_RM_AVG_TEMPERATURE_DIST}
    log to console    counter info after the second sleep 15min: ${counter_last}
    Should Be Equal      ${counter_after[-1]}    ${counter_last[-2]}
    #Should Not Be Equal    ${counter_last[-1]['value']}    ${Null}
    Should Be True    ${counter_last[-1]['value']}<100
    log to console    set mtSBTSSfpRMOD to disabled
#    ${mo_dn}    set variable    MRBTS-${mrbtsID}/MNL-1/MNLENT-1/PMMNL-1
#    &{parameter_dict}    Create Dictionary   mtSBTSSfpRMOD=disabled
#    vDU Login SG8
#    ${value}    Online Get VDU Parameter Value    mo_dn=${mo_dn}    para_name=mtSBTSSfpRMOD
#    run keyword if    '${value}'!='disabled'    VDU Online Modify Parameters By Delta Plan REST    mo_dn=${mo_dn}
#    ...    updated_paras_list=${parameter_dict}
    VDU Delta recommission update parameters by M2M API    delta_file=${disabled_counter_mtSBTSSfpRMOD}    wait_for_completion=True
    ${counter_before}    Get Pointed Counter For vDU    counter_id=${SBTS_SFP_RM_AVG_TEMPERATURE}    dimension_dn=${SBTS_SFP_RM_AVG_TEMPERATURE_DIST}
    log to console    counter info before sleep 15min: ${counter_before}
    sleep    15min
    log to console    ******check counter*********
    ${counter_after}    Get Pointed Counter For vDU    counter_id=${SBTS_SFP_RM_AVG_TEMPERATURE}    dimension_dn=${SBTS_SFP_RM_AVG_TEMPERATURE_DIST}
    log to console    counter info after sleep 15min: ${counter_after}
    Should Be Equal      ${counter_before[-1]}    ${counter_after[-1]}
#    sleep    15min
#    log to console    *****check counter**********
#    ${counter_last}    Get Pointed Counter For vDU    counter_id=${SBTS_SFP_RM_AVG_TEMPERATURE}    dimension_dn=${SBTS_SFP_RM_AVG_TEMPERATURE_DIST}
#    log to console    counter info after the second sleep 15min: ${counter_last}
#    Should Be Equal      ${counter_after[-1]}    ${counter_last[-1]}
    [Teardown]    run keyword and ignore error    vDU Logout SG8

sfp power compatibility validation on rmod
    log to console    reset vdu and check cell onair
    Reset vDU With Check Cell On Air
    log to console    check no unexpected alarms
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist For VDU
    ...    allowed_faults=@{ALLOWED_FAULT_VDU}
    should be true    ${alarm_status}
    log to console    collect Snapshot...
    ${Snapshot_path}    Save Local Snapshot In vDU
    log to console    ${Snapshot_path}
    ${snaoshot_file_path}    set variable    ${Snapshot_path}/snapshot_file_list.txt
    ${soap_message_zip_name}    find_soap_message_zip    snapshot_file_path=${snaoshot_file_path}
    ${cmd_unzip}    set variable    unzip ${Snapshot_path}/${soap_message_zip_name} -d ${Snapshot_path}
    OperatingSystem.Run And Return Rc And Output    ${cmd_unzip}
    Sleep    5s
    ${cmd}    set variable    ls -l ${Snapshot_path}| grep SOAPMessageTraceCFG.xml.gz| awk '{print $9}'
    ${rc}    ${output}    OperatingSystem.Run And Return Rc And Output    ${cmd}
    Sleep    2s
    ${cmd_unzip}    set variable    gzip -d ${Snapshot_path}/${output}
    OperatingSystem.Run And Return Rc And Output    ${cmd_unzip}
    Sleep    5s
    ${xml_name}    Replace String    ${output}    .gz    ${EMPTY}
    format_file_to_xml    filepath=${Snapshot_path}/${xml_name}
    ${result}    getValueFromXML    paraName=powerLevelCompatibilityState    soap_path=${Snapshot_path}/${xml_name}
    ...    distname_match=localTransceiver0
    log to console    check soap log parameter powerLevelCompatibilityState in Snapshot
    Should contain    ${result}    COMPATIBLE

sfpOperatorMode enable and SFP28 compliance disable
    log to console    check no unexpected alarms
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist For VDU
    ...    allowed_faults=@{ALLOWED_FAULT_VDU}
    should be true    ${alarm_status}
    log to console    check sfpWhitelist.xml exists under /opt/nokia/OAM
    log to console    login vdu ssh server
    ${alias}  get unique id
    Connect To vDU K8s Master   alias=${alias}
    ${container_name}    set variable    ctr-oamfh
    ${pod_name}    Set Variable   po-oamfh-0
    ${cmd}    set variable    kubectl exec -it ${pod_name} -n ${ns} -c ${container_name} -- bash
    run keyword and ignore error    issh.Execute  command=${cmd}
    ...   check_result=${False}
    ...   alias=${alias}
    sleep    5s
    ${cmd}    set variable    ls -l /opt/nokia/OAM
    ${out}    run keyword and ignore error    issh.Execute  command=${cmd}
    ...   check_result=${False}
    ...   alias=${alias}
    log to console    ${out}
    Should Contain    ${out}[1]    sfpWhitelist.xml
    log to console    set sfpOperatorMode to true and false
#    FOR    ${i}    IN RANGE    0    2
#        &{parameter_dict_true}    Create Dictionary   sfpOperatorMode=true
#        &{parameter_dict_false}    Create Dictionary   sfpOperatorMode=false
#        ${mo_dn}    set variable    MRBTS-${mrbtsID}/EQM-1/APEQM-1
#        vDU Login SG8
#        ${value}    Online Get VDU Parameter Value    mo_dn=${mo_dn}    para_name=sfpOperatorMode
#        run keyword if    '${value}'=='false'    VDU Online Modify Parameters By Delta Plan REST    mo_dn=${mo_dn}
#        ...    updated_paras_list=${parameter_dict_true}    ELSE
#        ...    VDU Online Modify Parameters By Delta Plan REST    mo_dn=${mo_dn}    updated_paras_list=${parameter_dict_false}
#        ${value_after}    Online Get VDU Parameter Value    mo_dn=${mo_dn}    para_name=sfpOperatorMode
#        run keyword if    '${value}'=='false'    Should Be Equal    '${value_after}'    'true'    ELSE
#        ...    Should Be Equal    '${value_after}'    'false'    ELSE
#        wait until keyword succeeds     5min    30s    Verify All Cells Status Should Be Onair for vDU
#    END
    VDU Delta recommission update parameters by M2M API    delta_file=${enabled_parameter_sfpOperatorMode}    wait_for_completion=True
    vDU Login SG8
    ${mo_dn}    set variable    MRBTS-${mrbtsID}/EQM_R-1/APEQM_R-1/RMOD_R-1/SFP_R-1
    ${value}    Online Get VDU Parameter Value    mo_dn=${mo_dn}    para_name=transceiverComplianceCode
    Should Be Equal    '${value}'    '25GBASE_LR'
    [Teardown]    run keywords    run keyword and ignore error  issh.disconnect  alias=${alias}    AND
    ...    run keyword and ignore error    vDU Logout SG8

Initial Parameter Values For 10411
    log to console    set mtSBTSRMODTemperature to 15min
    ${mo_dn}    set variable    MRBTS-${mrbtsID}/MNL-1/MNLENT-1/PMMNL-1
    &{parameter_dict}    Create Dictionary   mtSBTSRMODTemperature=15min
    vDU Login SG8
    ${value}    Online Get VDU Parameter Value    mo_dn=${mo_dn}    para_name=mtSBTSRMODTemperature
    run keyword if    '${value}'!='15min'    VDU Online Modify Parameters By Delta Plan REST
    ...    mo_dn=${mo_dn}    updated_paras_list=${parameter_dict}
    log to console    set mtSBTSSfpRMOD to 15min
    ${mo_dn}    set variable    MRBTS-${mrbtsID}/MNL-1/MNLENT-1/PMMNL-1
    &{parameter_dict}    Create Dictionary   mtSBTSSfpRMOD=15min
    ${value}    Online Get VDU Parameter Value    mo_dn=${mo_dn}    para_name=mtSBTSSfpRMOD
    run keyword if    '${value}'!='15min'    VDU Online Modify Parameters By Delta Plan REST
    ...    mo_dn=${mo_dn}    updated_paras_list=${parameter_dict}
    #sleep    15min
    [Teardown]    run keyword and ignore error    vDU Logout SG8

commission scf and make call
    [Arguments]    ${vdu_scf_path}    ${cu_scf_path}    ${tput_self_define}    ${target_avg_percent}=0.95    ${wait_for_completion}=True
    ...    ${min_percent}=0.85    ${duration}=300    ${process_num}=3
    log to console    commission scf for cu...
    CU Full Commsion By M2M API    scf_file=${cu_scf_path}    wait_for_completion=${wait_for_completion}
    log to console    commission scf for du...
    VDU Full Commsion By M2M API    scf_file=${vdu_scf_path}    wait_for_completion=${wait_for_completion}
    log to console    check cell status should be on air for du...
    wait until keyword succeeds     7min    30s    Verify All Cells Status Should Be Onair for vDU
    log to console    check cell status should be on air for cu...
    wait until keyword succeeds     3min    30s    Verify All Cells Are Enabled for CU
    log to console    make call on cells
    data_transfer_common    tput_self_define=${tput_self_define}    target_avg_percent=${target_avg_percent}
    ...    min_percent=${min_percent}    ue_type=${ue_type_NR}    duration=${duration}    process_num=${process_num}
    ...    appserver=APPserversim

Cell_block_and_unblock_and_make_call
    [Arguments]     ${tput_self_define}    ${target_avg_percent}=0.95
    ...    ${min_percent}=0.85    ${duration}=60    ${process_num}=3    ${fault_check}=True
    ${cell_number}    Get vDU Cell numbers
    FOR    ${index}    IN RANGE    1    ${cell_number}+1
        log to console    block cell ${index} for du...
        Block Cell In vDU    cell_id=${index}
        log to console    check cell ${index} should be blocked for du...
        wait until keyword succeeds     3min    5s    Check Cell Should Be Blocked On vDU    cell_id=${index}
        Sleep    5s
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
    ...    ${min_percent}=0.85    ${duration}=60    ${process_num}=3
    ${rmods}    SG08_keywords_cloud.Get Rmod List
    log to console    lock ru for du...
    lock ru in vdu    rmod_id_list=${rmods}
    log to console    check ru status should be locked for du...
    wait until keyword succeeds     3min    5s    Verify All Rmods Status Should Be Locked for vDU
    log to console    check cell status should be disabled for du..
    wait until keyword succeeds     10s    5s    Verify All Cells Are Disabled for vDU
    log to console    check cell status should be disabled for cu...
    wait until keyword succeeds     10s    5s    Verify All Cells Are Disabled for CU
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
    ...    ${min_percent}=0.85    ${duration}=60    ${process_num}=3
    ${rmods}    SG08_keywords_cloud.Get Rmod List
    log to console    reset ru for du
    SG08_keywords_cloud.Reset Rmod By Rest    rmods_list=${rmods}
    log to console    check cell rmod should be disabled for du...
    wait until keyword succeeds     3min    5s    Verify All RMOD Are Disabled for vDU
    log to console    check cell status should be disabled for du...
    wait until keyword succeeds     3min    5s    Verify All Cells Are Disabled for vDU
    log to console    check cell status should be disabled for cu...
    wait until keyword succeeds     3min    5s    Verify All Cells Are Disabled for CU
#    log to console    check fault 10 reported on du
#    Expect Fault Should Present On vDU    fault_id=10
    log to console    check cell should be on air for du...
    wait until keyword succeeds     6min    5s    Verify All Cells Status Should Be Onair for vDU
    log to console    check cell should be on air for cu...
    wait until keyword succeeds     5min    5s    Verify All Cells Are Enabled for CU
    log to console    check fault 10 canceled on du
    Expect Fault Should Absent On vDU    fault_id=10
    log to console    make call on cells
    data_transfer_common    tput_self_define=${tput_self_define}    target_avg_percent=${target_avg_percent}
    ...    min_percent=${min_percent}    ue_type=${ue_type_NR}    duration=${duration}    process_num=${process_num}
    ...    appserver=APPserversim

trigger fault 7116
    [Arguments]    ${vdu_index}=0
    log to console    login vdu ssh server
    ${alias}  get unique id
    Connect To vDU K8s Master   vdu_index=${vdu_index}  alias=${alias}
    log to console    get ru ip
    ${ru_ip}    get ru ip    alias=${alias}    ns=${namespace_vdu}
    log to console    login ru
    login ru    alias=${alias}    ru_ip=${ru_ip}    username=serviceuser    password=${service_user_password}
    log to console     execute 10 command
    FOR    ${command}    IN    @{commands}
         ${cmd}    set variable    sudo ${command}
         ${out}    issh.Execute   command=${cmd}    alias=${alias}     check_result=${False}
         sleep    1s
    END
    Sleep    65 minutes
    log to console    check fault 2922 should be reported
    Run Keyword If    '${release_du}'=='25R2'    Check active fault 2922 for 25R2    ELSE    Check active fault 2922 except 25R2
    log to console    check cell should be on air for cu...
    wait until keyword succeeds     5min    5s    Verify All Cells Are Enabled for CU
    [Teardown]    run keyword and ignore error  issh.disconnect  alias=${alias}

Check active fault 2922 for 25R2
    [Arguments]    ${fault_id}=2922    ${alarm_id}=7116    ${severity}=major
    wait until keyword succeeds     5min    5s    Expect Fault Should Present On vDU    fault_id=${fault_id}
    ...    alarm_id=${alarm_id}    severity=${severity}
    log to console    reset ru for du
    ${rmods}    SG08_keywords_cloud.Get Rmod List
    wait until keyword succeeds     3min    5s    Verify All RMOD Are Disabled for vDU
    log to console    check cell status should be disabled for du...
    wait until keyword succeeds     3min    5s    Verify All Cells Are Disabled for vDU
    log to console    check cell status should be disabled for cu...
    wait until keyword succeeds     3min    5s    Verify All Cells Are Disabled for CU
    log to console    check cell should be on air for du...
    wait until keyword succeeds     6min    5s    Verify All Cells Status Should Be Onair for vDU
    Expect Fault Should Absent On vDU    fault_id=${fault_id}    alarm_id=${alarm_id}    severity=${severity}

Check active fault 2922 except 25R2
    [Arguments]    ${fault_id}=2922    ${alarm_id}=7101    ${severity}=warning
    wait until keyword succeeds     5min    5s    Expect history Fault Should Present On vDU    fault_id=${fault_id}
    ...    alarm_id=${alarm_id}    severity=${severity}
    log to console    check cell should be on air for du...
    wait until keyword succeeds     6min    5s    Verify All Cells Status Should Be Onair for vDU
    Expect Fault Should Absent On vDU    fault_id=${fault_id}    alarm_id=${alarm_id}    severity=${severity}

swap cells split mode parameter
    [Arguments]    ${wait_for_completion}=True
    log to console    begin swap cell1 and cell2 mMimoAntArrayMode parameter
    VDU Delta recommission update parameters by M2M API    delta_file=${swap_mMimoAntArrayMode}    wait_for_completion=${wait_for_completion}
    log to console    check cell status should be onair for du...
    wait until keyword succeeds     3min    5s    Verify All Cells Status Should Be Onair for vDU
    log to console    check cell status should be enabled for cu...
    wait until keyword succeeds     3min    5s    Verify All Cells Are Enabled for CU

RANNIC_reset_from_webem
    ${RNIC_Num}    @{RNIC_MOD_List}    Get Rannic Number And ModList    mrbts_id=${MRBTS_ID}
    FOR  ${i}  IN RANGE  1   16
        log to console    ${i} times rannic reset
        Trigger Rannic Reset    rnic_mod_dist_name=${RNIC_MOD_LIST[0]}
        log to console    check RANNIC status should be enabled for du...
        wait until keyword succeeds     6min    5s    Verify RANNIC Status Should enabled for vDU
        log to console    check cell status should be onair for du...
        wait until keyword succeeds     15min    5s    Verify All Cells Status Should Be Onair for vDU
        sleep	2min
    END

RANNIC_reset_RU_lock_unlock_interworking_from_webem
    ${RNIC_Num}    @{RNIC_MOD_List}    Get Rannic Number And ModList    mrbts_id=${MRBTS_ID}
    FOR  ${i}  IN RANGE  1   15
        log to console    ${i} times loop...
        log to console    lock ru for du...
        ${rmods}    SG08_keywords_cloud.Get Rmod List
        lock ru in vdu    rmod_id_list=${rmods}

#        ${alias_ocp}=    Run Keyword If    ${i}>1    get unique id
#        ${alias_pc}=    Run Keyword If    ${i}>1    get unique id
#        Run Keyword If    ${i}>1   Log To Console    login in ocp...
#        Run Keyword If    ${i}>1    Connect To vDU K8s Master   alias=${alias_ocp}
#        Run Keyword If    ${i}>1    Log To Console    login in pc and ru...
#        Run Keyword If    ${i}>1    login_ru_by_control_pc_and_LMI    alias=${alias_pc}
#        Run Keyword If    ${i}>1    issh.Execute
#        ...    command=ns=cran991 && kubectl exec po-$ns-oamfh-0 -n $ns -c ctr-$ns-nwmgmt -- tcpdump -tt -s 0 -i any -n udp -w - > ~/oamfh.pcap
#        ...    alias=${alias_ocp}    check_result=${False}
#        Run Keyword If    ${i}>1    issh.Execute    command=sudo tcpdump -i ecpri0 -w /tmp/ecpri0.pcap
#        ...    alias=${alias_pc}    check_result=${False}
#        Run Keyword If    ${i}>1    issh.Execute    command=sudo tcpdump -i ecpri0 -w /tmp/ecpri0.pcap
#        ...    alias=${alias_pc}    check_result=${False}

        log to console    check ru status should be locked for du...
        wait until keyword succeeds     1min    5s    Verify All Rmods Status Should Be Locked for vDU
        log to console    check cell status should be disabled for du..
        wait until keyword succeeds     20s    5s    Verify All Cells Are Disabled for vDU
        log to console    check cell status should be disabled for cu...
        wait until keyword succeeds     20s    5s    Verify All Cells Are Disabled for CU
        Trigger Rannic Reset    rnic_mod_dist_name=${RNIC_MOD_LIST[0]}
        log to console    check RANNIC status should be enabled for du...
        wait until keyword succeeds     5min    5s    Verify RANNIC Status Should enabled for vDU
        wait until keyword succeeds     15min    5s    Verify All Rmods Status Should Be Locked for vDU
        Sleep    30s
        log to console    unlock ru for du...
        unlock ru in vdu    rmod_id_list=${rmods}

#        Run Keyword If    ${i}>1    sleep    4min
#        ${crtl_c}=    Run Keyword If    ${i}>1    Evaluate    chr(int(3))
#        Run Keyword If    ${i}>1    issh.Execute   command=${crtl_c}   alias=${alias_ocp}     check_result=${False}
#        Run Keyword If    ${i}>1    Sleep    3s
#        Run Keyword If    ${i}>1    issh.Execute   command=${crtl_c}   alias=${alias_ocp}     check_result=${False}
#        Run Keyword If    ${i}>1    Sleep    3s
#        Run Keyword If    ${i}>1    issh.Execute   command=${crtl_c}   alias=${alias_ocp}     check_result=${False}
#        Run Keyword If    ${i}>1    Sleep    3s
#        Run Keyword If    ${i}>1    issh.Execute   command=${crtl_c}   alias=${alias_pc}     check_result=${False}
#        Run Keyword If    ${i}>1    Sleep    3s
#        Run Keyword If    ${i}>1    issh.Execute   command=${crtl_c}   alias=${alias_pc}     check_result=${False}
#        Run Keyword If    ${i}>1    Sleep    3s
#        Run Keyword If    ${i}>1    issh.Execute   command=${crtl_c}   alias=${alias_pc}     check_result=${False}
#        Run Keyword If    ${i}>1    Sleep    3s
#        Run Keyword If    ${i}>1    run keyword and ignore error  issh.disconnect  alias=${alias_ocp}
#        Run Keyword If    ${i}>1    run keyword and ignore error  issh.disconnect  alias=${alias_pc}

        log to console    check ru status should be normal for ru...
        wait until keyword succeeds     12min    5s    Verify All Rmods Status Should Be Normal for vDU
#        Log To Console    check fault1806...
#        Unexpect fault1806 Should Not Exist for special RU
#        Log To Console     check fault10...
#        Unexpect fault10 Should Not Exist for special RU
        log to console    check cell status should be onair for du...
#        ${cell_status}    Run Keyword And Return Status    wait until keyword succeeds     20min    5s
#        ...    Verify All Cells Status Should Be Onair for vDU
#        Run Keyword If    not ${cell_status}    Reset vDU With Check Cell On Air and collect snapshot due to fault6450
        wait until keyword succeeds     10min    5s    Verify All Cells Status Should Be Onair for vDU
#        Log To Console     check fault10...
#        Unexpect fault10 Should Not Exist for special RU
        log to console    check cell status should be enabled for cu...
        wait until keyword succeeds     3min    5s    Verify All Cells Are Enabled for CU
        sleep	1min
    END

Reset vDU With Check Cell On Air and collect snapshot due to fault6450
    Run Keyword And Ignore Error    unlock ru in vdu    rmod_id_list=${rmods}
    Run Keyword And Ignore Error    Reset vDU With Check Cell On Air
    Run Keyword And Ignore Error    Collect snapshot due to fault6450
    Unexpect fault10 Should Not Exist for special RU
    wait until keyword succeeds     15min    5s    Verify All Cells Status Should Be Onair for vDU

Unexpect fault6450 Should Not Exist for special RU
    [Arguments]      ${vdu_index}=${0}    ${alias}=default
    vDU Login SG8    vdu_index=${vdu_index}
#    ${history_alarms}    vdu.vdu_get_historical_alarms    vdu_connection=${alias}
#    ${history_alarms_list}    Get From Dictionary    ${history_alarms}    alarms
#    ${history_alarms_num}     Get Length    ${history_alarms_list}
    ${active_alarms}    vdu.vdu_get_active_alarms    vdu_connection=${alias}
    ${active_alarms_list}    Get From Dictionary    ${active_alarms}    alarms
    ${active_alarms_num}     Get Length    ${active_alarms_list}
#    FOR  ${history_alarm}  IN  @{history_alarms_list}
#        Exit For Loop If    ${history_alarms_num}==${0}
#        Run Keyword If    '${history_alarm['fault_id']}'=='1926'
#        ...    Fail    fault 4590 reported in history alarm for special RU
#    END
    FOR  ${active_alarm}  IN  @{active_alarms_list}
        Exit For Loop If    ${active_alarms_num}==${0}
        Run Keyword If    '${active_alarm['fault_id']}'=='6450'
        ...    Fail    fault 6450 reported in active alarm for special RU
    END
    [Teardown]    Run Keyword And Ignore Error    vDU Logout SG8

Unexpect fault1806 Should Not Exist for special RU
    [Arguments]      ${vdu_index}=${0}    ${alias}=default
    vDU Login SG8    vdu_index=${vdu_index}
    ${history_alarms}    vdu.vdu_get_historical_alarms    vdu_connection=${alias}    paging=${True}    page_number=${1}    items_per_page=${10}
    ${history_alarms_list}    Get From Dictionary    ${history_alarms}    alarms
    ${history_alarms_num}     Get Length    ${history_alarms_list}
    ${active_alarms}    vdu.vdu_get_active_alarms    vdu_connection=${alias}
    ${active_alarms_list}    Get From Dictionary    ${active_alarms}    alarms
    ${active_alarms_num}     Get Length    ${active_alarms_list}
    FOR  ${history_alarm}  IN  @{history_alarms_list}
        Exit For Loop If    ${history_alarms_num}==${0}
        Run Keyword If    '${history_alarm['fault_id']}'=='1806'
        ...    Fail    fault 1806 reported in history alarm for special RU
    END
    FOR  ${active_alarm}  IN  @{active_alarms_list}
        Exit For Loop If    ${active_alarms_num}==${0}
        Run Keyword If    '${active_alarm['fault_id']}'=='1806'
        ...    Fail    fault 1806 reported in active alarm for special RU
    END
    [Teardown]    Run Keyword And Ignore Error    vDU Logout SG8

Unexpect fault10 Should Not Exist for special RU
    [Arguments]      ${vdu_index}=${0}    ${alias}=default
    vDU Login SG8    vdu_index=${vdu_index}
    ${history_alarms}    vdu.vdu_get_historical_alarms    vdu_connection=${alias}
    ${history_alarms_list}    Get From Dictionary    ${history_alarms}    alarms
    ${history_alarms_num}     Get Length    ${history_alarms_list}
    ${active_alarms}    vdu.vdu_get_active_alarms    vdu_connection=${alias}
    ${active_alarms_list}    Get From Dictionary    ${active_alarms}    alarms
    ${active_alarms_num}     Get Length    ${active_alarms_list}
    FOR  ${history_alarm}  IN  @{history_alarms_list}
        Exit For Loop If    ${history_alarms_num}==${0}
        Run Keyword If    '${history_alarm['fault_id']}'=='10' and '${history_alarm['alarming_object']}'=='MRBTS-991/EQM_R-1/APEQM_R-1/RMOD_R-3'
#        ...    Run Keywords    Cancel ban ru reset flag and rmod power off and power on    AND    Add ban ru reset flag
        ...    Fail    fault 10 reported in active alarm for special RU
    END
    FOR  ${active_alarm}  IN  @{active_alarms_list}
        Exit For Loop If    ${active_alarms_num}==${0}
        Run Keyword If    '${active_alarm['fault_id']}'=='10' and '${active_alarm['alarming_object']}'=='MRBTS-991/EQM_R-1/APEQM_R-1/RMOD_R-3'
#        ...    Run Keywords    Cancel ban ru reset flag and rmod power off and power on    AND    Add ban ru reset flag
        ...    Fail    fault 10 reported in active alarm for special RU
    END
    [Teardown]    Run Keyword And Ignore Error    vDU Logout SG8


Cancel ban ru reset flag and rmod power off and power on
    ${alias_ru}=    get unique id
    Log To Console    login in pc and ru...
    login_ru_by_control_pc_and_LMI    alias=${alias_ru}
    issh.Execute    command=sudo sed -i 's/^0xc0015 = 1//' /mnt/runtime/swconfig.txt    alias=${alias_ru}    check_result=${False}
    Sleep    3s
    issh.Execute    command=sudo sed -i 's/^0xe5 = 2//' /mnt/runtime/swconfig.txt    alias=${alias_ru}    check_result=${False}
    Sleep    3s
    issh.Execute    command=sudo sed -i 's/^0xe1 = 1//' /mnt/runtime/swconfig.txt    alias=${alias_ru}    check_result=${False}
    Sleep    3s
    issh.Execute    command=sudo sed -i 's/^0xe6 = 1//' /mnt/runtime/swconfig.txt    alias=${alias_ru}    check_result=${False}
    Sleep    3s
    issh.Execute    command=sudo sed -i 's/^0xc000c = 1//' /mnt/runtime/swconfig.txt    alias=${alias_ru}    check_result=${False}
    run keyword and ignore error  issh.disconnect  alias=${alias_ru}
    Cloud Perform RU Power Off    ru_index=${2}
    log to console    check fault 10 reported on du
    wait until keyword succeeds    3min    5s    Expect Fault Should Present On vDU    fault_id=10
    Cloud Perform RU Power On    ru_index=${2}
    wait until keyword succeeds     16min    5s    Verify All Cells Status Should Be Onair for vDU

Add ban ru reset flag
    ${alias_ru}=    get unique id
    Log To Console    login in pc and ru...
    login_ru_by_control_pc_and_LMI    alias=${alias_ru}    pc_ip=10.0.176.210
    issh.Execute    command=ccsShell.sh rad -mpw 0xc0015 1    alias=${alias_ru}    check_result=${False}
    Sleep    3s
    issh.Execute    command=ccsShell.sh rad -mpw 0xE5 2    alias=${alias_ru}    check_result=${False}
    Sleep    3s
    issh.Execute    command=ccsShell.sh rad -mpw 0xE1 1    alias=${alias_ru}    check_result=${False}
    Sleep    3s
    issh.Execute    command=ccsShell.sh rad -mpw 0xE6 1    alias=${alias_ru}    check_result=${False}
    Sleep    3s
    issh.Execute    command=ccsShell.sh rad -mpw 0xc000c 1    alias=${alias_ru}    check_result=${False}
    run keyword and ignore error  issh.disconnect  alias=${alias_ru}


Collect snapshot due to fault6450
    [Arguments]      ${vdu_index}=${0}    ${alias}=default
    vDU Login SG8    vdu_index=${vdu_index}
#    ${history_alarms}    vdu.vdu_get_historical_alarms    vdu_connection=${alias}
#    ${history_alarms_list}    Get From Dictionary    ${history_alarms}    alarms
#    ${history_alarms_num}     Get Length    ${history_alarms_list}
    ${active_alarms}    vdu.vdu_get_active_alarms    vdu_connection=${alias}
    ${active_alarms_list}    Get From Dictionary    ${active_alarms}    alarms
    ${active_alarms_num}     Get Length    ${active_alarms_list}
#    FOR  ${history_alarm}  IN  @{history_alarms_list}
#        Exit For Loop If    ${history_alarms_num}==${0}
#        Run Keyword If    '${history_alarm['fault_id']}'=='1926'
#        ...    Fail    fault 4590 reported in history alarm for special RU
#    END
    FOR  ${active_alarm}  IN  @{active_alarms_list}
        Exit For Loop If    ${active_alarms_num}==${0}
        Run Keyword If    '${active_alarm['fault_id']}'=='6450'    Save Local Snapshot In vDU
    END
    [Teardown]    Run Keyword And Ignore Error    vDU Logout SG8

[1]login_ru_by_LMI
    login_ru_by_control_pc_and_LMI    pc_ip=10.0.176.112    pc_username=MN5GRAN    pc_password=nokia123@
    ...    ru_ip=192.168.100.1    ru_username=serviceuser    ru_password=bobuWrUHk7Xq7WPpY9ZcjEi8zNdX3plZ+/y420RZ7W4=


login_ru_by_control_pc_and_LMI
    [Arguments]    ${alias}=alias    ${pc_ip}=10.0.176.112    ${pc_username}=MN5GRAN    ${pc_password}=nokia123@
    log to console    login vdu ssh server
    Login to control PC   pc_ip=${pc_ip}    pc_username=${pc_username}    pc_password=${pc_password}    alias=${alias}
    log to console    login RU in control PC
    login ru by lmi     ru_ip=192.168.100.1    ru_username=serviceuser
    ...    ru_password=kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og=    alias=${alias}
#    [Teardown]    run keyword and ignore error  issh.disconnect  alias=${alias}

login_ru_by_control_pc_and_LMI_thor
    [Arguments]    ${pc_ip}=10.0.176.112    ${pc_username}=MN5GRAN    ${pc_password}=nokia123@    ${alias}=alias
    log to console    login vdu ssh server
    Login to control PC   pc_ip=${pc_ip}    pc_username=${pc_username}    pc_password=${pc_password}    alias=${alias}
    log to console    login RU in control PC
    login ru by lmi     ru_ip=192.168.100.17    ru_username=serviceuser
    ...    ru_password=kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og=    alias=${alias}
#    [Teardown]    run keyword and ignore error  issh.disconnect  alias=${alias}

login_ru_by_control_pc_and_LMI_collect_rulog
    [Arguments]    ${alias}=alias
    log to console    login pc and ru collect ru log
    ${alias}  get unique id
    Login to control PC   pc_ip=10.0.176.112    pc_username=MN5GRAN    pc_password=nokia123@    alias=${alias}
    log to console    login RU in control PC
    login ru by lmi     ru_ip=192.168.100.1    ru_username=serviceuser
    ...    ru_password=bobuWrUHk7Xq7WPpY9ZcjEi8zNdX3plZ+/y420RZ7W4=    alias=${alias}
    log to console     execute collect RUlog command
    ${out}    issh.Execute   command=ccsShell.sh log -a -z rulog_1806.zip    alias=${alias}     check_result=${False}
    Sleep    30s
    [Teardown]    run keyword and ignore error  issh.disconnect  alias=${alias}

Login to control PC
    [Arguments]   ${pc_ip}    ${pc_username}    ${pc_password}    ${alias}=default
    [Documentation]   Connect To control PC
    issh.Connect_To    ip=${pc_ip}    username=${pc_username}    password=${pc_password}
       ...   prompt=\\$
       ...   alias=${alias}
       ...   width=200
       ...   timeout=150


login ru by lmi
    [Arguments]    ${ru_ip}    ${ru_username}    ${ru_password}    ${alias}    ${prompt_ru}=Node0:~#
    ${cmd}    Set Variable    ssh -o StrictHostKeyChecking=no ${ru_username}@${ru_ip}
    ${old_prompt}    issh.get prompt    alias=${alias}
    issh.set prompt   ${old_prompt}|password:   alias=${alias}
    ${out}    issh.Execute   command=${cmd}    alias=${alias}     check_result=${False}
    issh.set prompt   ${old_prompt}|\\$|${prompt_ru}   alias=${alias}
    issh.Execute    command=${ru_password}     alias=${alias}    check_result=${False}

RANNIC_reset_RU_reset_RU_lock_unlock_interworking_from_webem_for_SWN
    ${RNIC_Num}    @{RNIC_MOD_List}    Get Rannic Number And ModList    mrbts_id=${MRBTS_ID}
    FOR  ${i}  IN RANGE  1   5
        log to console    ${i} times loop...
        log to console    lock ru for du...
        ${rmods}    SG08_keywords_cloud.Get Rmod List
        lock ru in vdu    rmod_id_list=${rmods}
        log to console    check ru status should be locked for du...
        wait until keyword succeeds     3min    5s    Verify All Rmods Status Should Be Locked for vDU
        log to console    check cell status should be disabled for du..
        wait until keyword succeeds     10s    5s    Verify All Cells Are Disabled for vDU
        log to console    check cell status should be disabled for cu...
        wait until keyword succeeds     10s    5s    Verify All Cells Are Disabled for CU
        Trigger Rannic Reset    rnic_mod_dist_name=${RNIC_MOD_LIST[0]}
        log to console    check RANNIC status should be enabled for du...
        wait until keyword succeeds     6min    5s    Verify RANNIC Status Should enabled for vDU
        Sleep    30s
        log to console    reset ru for du
        SG08_keywords_cloud.Reset Rmod By Rest    rmods_list=${rmods}
        log to console    check cell rmod should be disabled for du...
        wait until keyword succeeds     3min    5s    Verify All RMOD Are Disabled for vDU
        log to console    check cell status should be disabled for du...
        wait until keyword succeeds     3min    5s    Verify All Cells Are Disabled for vDU
        log to console    check cell status should be disabled for cu...
        wait until keyword succeeds     3min    5s    Verify All Cells Are Disabled for CU
        log to console    check rmod status should be enabled and locked for du after ru reset...
        wait until keyword succeeds     15min    5s    Verify All RMOD Status Should Be enabled and locked for vDU
        Sleep    10s
        log to console    unlock ru for du...
        unlock ru in vdu    rmod_id_list=${rmods}
        log to console    check ru status should be normal for ru...
        wait until keyword succeeds     6min    5s    Verify All Rmods Status Should Be Normal for vDU
        log to console    check cell status should be onair for du...
        wait until keyword succeeds     6min    5s    Verify All Cells Status Should Be Onair for vDU
        log to console    check cell status should be enabled for cu...
        wait until keyword succeeds     6min    5s    Verify All Cells Are Enabled for CU
        sleep	2min
    END

RU_POST_data_verify_in_snapshot
    [Arguments]   ${ru_index}=${1}
    Log To Console    RMOD power off and power on and  reset 3 times start
    ${rmods}    SG08_keywords_cloud.Get Rmod List
    ${post_three_time_date}    Create List
    ${post_three_timestamp}    Create List
    FOR    ${i}    IN RANGE  ${3}
        ${post_check_start_time}    DateTime.Get Current Date    result_format=timestamp
        Log To Console    ${i}th time RMOD power off and power on and  reset
        Cloud Perform RU Power Off
        log to console    check cell status should be disabled for du...
        wait until keyword succeeds    3min    5s    Verify All Cells Are Disabled for vDU
        log to console    check cell status should be disabled for cu...
        wait until keyword succeeds    3min    5s    Verify All Cells Are Disabled for CU
        log to console    check fault 10 reported on du
        wait until keyword succeeds    3min    5s    Expect Fault Should Present On vDU    fault_id=10
        Cloud Perform RU Power On
        log to console    check ru status should be enabled for vcu...
        wait until keyword succeeds     6min    5s    Verify All Rmods Status Should Be Normal for vDU
        log to console    check cell should be on air for du...
        wait until keyword succeeds     6min    5s    Verify All Cells Status Should Be Onair for vDU
        log to console    check cell should be on air for cu...
        wait until keyword succeeds     5min    5s    Verify All Cells Are Enabled for CU
        ${post_check_stop_time}    DateTime.Get Current Date    result_format=timestamp
        Sleep    1min
        SG08_keywords_cloud.Reset Rmod By Rest    rmods_list=${rmods}
        log to console    check cell status should be disabled for du...
        wait until keyword succeeds    3min    5s    Verify All Cells Are Disabled for vDU
        log to console    check cell status should be disabled for cu...
        wait until keyword succeeds    3min    5s    Verify All Cells Are Disabled for CU
        log to console    check cell should be on air for du...
        wait until keyword succeeds     6min    5s    Verify All Cells Status Should Be Onair for vDU
        log to console    check cell should be on air for cu...
        wait until keyword succeeds     5min    5s    Verify All Cells Are Enabled for CU
        Append To List    ${post_three_time_date}    ${post_check_start_time}
        Append To List    ${post_three_time_date}    ${post_check_stop_time}
        ${post_check_start_timestamp}    DateTime.Convert Date    ${post_check_start_time}    result_format=epoch
        ${post_check_stop_timestamp}    DateTime.Convert Date    ${post_check_stop_time}    result_format=epoch
        Append To List    ${post_three_timestamp}    ${post_check_start_timestamp}
        Append To List    ${post_three_timestamp}    ${post_check_stop_timestamp}
    END
    ${Snapshot_file_path}    Save Local Snapshot In vDU    local_snapshot_location=post_snapshot    compressed_or_not=${False}
    should exist    ${Snapshot_file_path}/RU_${ru_index}.zip
    extract zip file    ${Snapshot_file_path}/RU_${ru_index}.zip    ${Snapshot_file_path}/RU_${ru_index}
    ${detail_files}    List Files In Directory    path=${Snapshot_file_path}/RU_${ru_index}
    FOR    ${file_name}  IN  @{detail_files}
        ${result}    Run Keyword And Return Status    Should Contain    ${file_name}    BBOX5
        ${BBOX5_file_name}=    Set Variable If    ${result}    ${file_name}
        Exit For Loop If    ${result}
    END
    extract zip file    ${snapshot_path}/RU_${ru_index}/${BBOX5_file_name}    ${snapshot_path}/RU_${ru_index}/BBOX5_file
    ${post_result_number}    ${post_dict_content}    get_post_result_content_from_file    ${snapshot_path}/RU_${ru_index}/BBOX5_file/BBOX5
    Should Be Equal    ${post_result_number}    ${3}
    ${post_result}    Set Variable    OK
    ${post_type}    Set Variable    NORMAL
    FOR    ${i}    IN RANGE    ${post_result_number}
        ${rmod_three_start_index}    Evaluate    6 - ${i+1} * 2
        ${rmod_three_stop_index}    Evaluate    5 - ${i} * 2
        Should Be Equal    ${post_dict_content['POST[${i}] type']}    ${post_type}
        Should Be Equal    ${post_dict_content['POST[${i}] result']}    ${post_result}
        ${time_zone_align}=    Add Time To Date    ${post_dict_content['POST[${i}] timestamp']}      08:00:00    result_format=%Y-%m-%d %H:%M:%S
        ${post_timestamp}    DateTime.Convert Date    ${time_zone_align}   result_format=epoch
        Run Keyword And Continue On Failure    Should Be True     ${post_timestamp} > ${post_three_timestamp[${rmod_three_start_index}]}
        ...  msg=RMOD ${${3}-${i}}th power off start time ${post_three_time_date[${rmod_three_start_index}]} after post time ${time_zone_align}
        Run Keyword And Continue On Failure    Should Be True     ${post_timestamp} < ${post_three_timestamp[${rmod_three_stop_index}]}
        ...  msg=post time ${time_zone_align} before RMOD ${${3}-${i}}th power off start time ${post_three_time_date[${rmod_three_stop_index}]}
    END

get post result from RMOD
    [Arguments]    ${vdu_index}=0
    log to console    login vdu ssh server
    ${alias}  get unique id
    Connect To vDU K8s Master   vdu_index=${vdu_index}  alias=${alias}
    log to console    get ru ip
    ${ru_ip}    get ru ip    alias=${alias}    ns=${namespace_vdu}
    log to console    login ru
    login ru    alias=${alias}    ru_ip=${ru_ip}    username=serviceuser    password=${service_user_password}    need_login_node=False
    log to console     get post result from BBOX5 file
    ${cmd}    Set Variable    cat /mnt/runtime/BBOX5
    ${BBOX5_str_content}    issh.Execute    command=${cmd}    alias=${alias}     check_result=${False}
    ${post_result_number}    ${post_dict_content}    get_post_result_content_from_str    str_content=${BBOX5_str_content}
    [Return]    ${post_result_number}    ${post_dict_content}
    [Teardown]    run keyword and ignore error  issh.disconnect  alias=${alias}

RU_POST_data_verify_with_controlled_radio_reset
    [Arguments]   ${ru_index}=${1}
    ${rmods}    SG08_keywords_cloud.Get Rmod List
    ${post_three_time_date}    Create List
    ${post_three_timestamp}    Create List
    FOR    ${i}    IN RANGE  ${3}
        ${post_check_start_time}    DateTime.Get Current Date    result_format=timestamp
        SG08_keywords_cloud.Reset Rmod By Rest    rmods_list=${rmods}
        log to console    check cell status should be disabled for du...
        wait until keyword succeeds    3min    5s    Verify All Cells Are Disabled for vDU
        log to console    check cell status should be disabled for cu...
        wait until keyword succeeds    3min    5s    Verify All Cells Are Disabled for CU
        log to console    check cell should be on air for du...
        wait until keyword succeeds     6min    5s    Verify All Cells Status Should Be Onair for vDU
        ${post_check_stop_time}    DateTime.Get Current Date    result_format=timestamp
        log to console    check cell should be on air for cu...
        wait until keyword succeeds     5min    5s    Verify All Cells Are Enabled for CU
        Sleep    30s
        Append To List    ${post_three_time_date}    ${post_check_start_time}
        Append To List    ${post_three_time_date}    ${post_check_stop_time}
        ${post_check_start_timestamp}    DateTime.Convert Date    ${post_check_start_time}    result_format=epoch
        ${post_check_stop_timestamp}    DateTime.Convert Date    ${post_check_stop_time}    result_format=epoch
        Append To List    ${post_three_timestamp}    ${post_check_start_timestamp}
        Append To List    ${post_three_timestamp}    ${post_check_stop_timestamp}
    END
    SG08_keywords_cloud.Reset Rmod By Rest    rmods_list=${rmods}
    wait until keyword succeeds    3min    5s    Verify All Cells Are Disabled for vDU
    log to console    check cell status should be disabled for cu...
    wait until keyword succeeds    3min    5s    Verify All Cells Are Disabled for CU
    log to console    check cell should be on air for du...
    wait until keyword succeeds     6min    5s    Verify All Cells Status Should Be Onair for vDU
    ${Snapshot_file_path}    Save Local Snapshot In vDU    local_snapshot_location=post_snapshot    compressed_or_not=${False}
    should exist    ${Snapshot_file_path}/RU_${ru_index}.zip
    extract zip file    ${Snapshot_file_path}/RU_${ru_index}.zip    ${Snapshot_file_path}/RU_${ru_index}
    ${detail_files}    List Files In Directory    path=${Snapshot_file_path}/RU_${ru_index}
    FOR    ${file_name}  IN  @{detail_files}
        ${result}    Run Keyword And Return Status    Should Contain    ${file_name}    BBOX5
        ${BBOX5_file_name}=    Set Variable If    ${result}    ${file_name}
        Exit For Loop If    ${result}
    END
    extract zip file    ${snapshot_path}/RU_${ru_index}/${BBOX5_file_name}    ${snapshot_path}/RU_${ru_index}/BBOX5_file
    ${post_result_number}    ${post_dict_content}    get_post_result_content_from_file    ${snapshot_path}/RU_${ru_index}/BBOX5_file/BBOX5
    Should Be Equal    ${post_result_number}    ${3}
    ${post_result}    Set Variable    OK
    ${post_type}    Set Variable    NORMAL
    FOR    ${i}    IN RANGE    ${post_result_number}
        ${rmod_three_start_index}    Evaluate    6 - ${i+1} * 2
        ${rmod_three_stop_index}    Evaluate    5 - ${i} * 2
        Should Be Equal    ${post_dict_content['POST[${i}] type']}    ${post_type}
        Should Be Equal    ${post_dict_content['POST[${i}] result']}    ${post_result}
        ${time_zone_align}=    Add Time To Date    ${post_dict_content['POST[${i}] timestamp']}      08:00:00    result_format=%Y-%m-%d %H:%M:%S
        ${post_timestamp}    DateTime.Convert Date    ${time_zone_align}   result_format=epoch
        Should Be True     ${post_timestamp} > ${post_three_timestamp[${rmod_three_start_index}]}
        ...  msg=RMOD ${${3}-${i}}th control reset start time ${post_three_time_date[${rmod_three_start_index}]} after post time ${time_zone_align}
        Should Be True     ${post_timestamp} < ${post_three_timestamp[${rmod_three_stop_index}]}
        ...  msg=post time ${time_zone_align} before RMOD ${${3}-${i}}th control reset start time ${post_three_time_date[${rmod_three_stop_index}]}
    END

RU_POST_data_verify_with_unexpected_radio_reset
    ${rmods}    SG08_keywords_cloud.Get Rmod List
    SG08_keywords_cloud.Reset Rmod By Rest    rmods_list=${rmods}
    wait until keyword succeeds    3min    5s    Verify All Cells Are Disabled for vDU
    log to console    check cell status should be disabled for cu...
    wait until keyword succeeds    3min    5s    Verify All Cells Are Disabled for CU
    log to console    check cell should be on air for du...
    wait until keyword succeeds     5min    5s    Verify All Cells Status Should Be Onair for vDU
    ${first_time_reset_post_result_number}    ${first_time_reset_post_dict_content}    get post result from RMOD
    Cloud Perform RU Power Off
    log to console    check cell status should be disabled for du...
    wait until keyword succeeds    3min    5s    Verify All Cells Are Disabled for vDU
    log to console    check cell status should be disabled for cu...
    wait until keyword succeeds    3min    5s    Verify All Cells Are Disabled for CU
    log to console    check fault 10 reported on du
    wait until keyword succeeds    3min    5s    Expect Fault Should Present On vDU    fault_id=10
    Cloud Perform RU Power On
    log to console    check cell should be on air for du...
    wait until keyword succeeds     5min    5s    Verify All Cells Status Should Be Onair for vDU
    log to console    check cell should be on air for cu...
    wait until keyword succeeds     5min    5s    Verify All Cells Are Enabled for CU
    ${second_time_reset_post_result_number}    ${second_time_reset_post_dict_content}    get post result from RMOD
    Should Be Equal    ${first_time_reset_post_result_number}    ${second_time_reset_post_result_number}
    Dictionaries Should Be Equal    ${first_time_reset_post_dict_content}    ${second_time_reset_post_dict_content}

RU module multiple reset make call
    ${rmods}    SG08_keywords_cloud.Get Rmod List
    FOR  ${i}  IN RANGE  1   6
        log to console    reset ru for du
        SG08_keywords_cloud.Reset Rmod By Rest    rmods_list=${rmods}
        wait until keyword succeeds     3min    5s    Verify All Rmods Status Should Be disabled for vDU
        log to console    check cell status should be disabled for du...
        wait until keyword succeeds     3min    5s    Verify All Cells Are Disabled for vDU
        log to console    check cell status should be disabled for cu...
        wait until keyword succeeds     3min    5s    Verify All Cells Are Disabled for CU
        wait until keyword succeeds     15min    10s    Verify All Rmods Status Should Be Normal for vDU
        log to console    check cell should be on air for du...
        wait until keyword succeeds     6min    5s    Verify All Cells Status Should Be Onair for vDU
        log to console    check cell should be on air for cu...
        wait until keyword succeeds     5min    5s    Verify All Cells Are Enabled for CU
        Sleep    1min
    END

RU module multiple lock reset unlock make call
    ${rmods}    SG08_keywords_cloud.Get Rmod List
    FOR  ${i}  IN RANGE  1   6
        log to console    lock ru for du
        SG08_keywords_cloud.Lock RU In vDU    rmod_id_list=${rmods}
        Log To Console    check RU state should be locked...
        wait until keyword succeeds     1min    5s    Verify All Rmods Status Should Be Locked for vDU
        log to console    check cell status should be disabled for du...
        wait until keyword succeeds     3min    5s    Verify All Cells Are Disabled for vDU
        log to console    check cell status should be disabled for cu...
        wait until keyword succeeds     3min    5s    Verify All Cells Are Disabled for CU
        log to console    reset ru for du
        SG08_keywords_cloud.Reset Rmod By Rest    rmods_list=${rmods}
        wait until keyword succeeds     3min    5s    Verify All Rmods Status Should Be disabled for vDU
        log to console    check cell status should be disabled for du...
        wait until keyword succeeds     3min    5s    Verify All Cells Are Disabled for vDU
        log to console    check cell status should be disabled for cu...
        wait until keyword succeeds     3min    5s    Verify All Cells Are Disabled for CU
        wait until keyword succeeds     15min    5s    Verify All Rmods Status Should Be Locked for vDU
        Sleep    30s
        Log To Console    check RU state should be unlocked...
        SG08_keywords_cloud.Unlock RU In vDU    rmod_id_list=${rmods}
        wait until keyword succeeds     6min    5s    Verify All Rmods Status Should Be Normal for vDU
        log to console    check cell should be on air for du...
        wait until keyword succeeds     6min    5s    Verify All Cells Status Should Be Onair for vDU
        log to console    check cell should be on air for cu...
        wait until keyword succeeds     5min    5s    Verify All Cells Are Enabled for CU
        Sleep    1min
    END


RMOD Lock Unlock VDU reset
    ${rmods}    SG08_keywords_cloud.Get Rmod List
    FOR  ${i}  IN RANGE  1   6
        log to console    lock ru for du
        SG08_keywords_cloud.Lock RU In vDU    rmod_id_list=${rmods}
        Log To Console    check RU state should be locked...
        wait until keyword succeeds     1min    5s    Verify All Rmods Status Should Be Locked for vDU
        log to console    check cell status should be disabled for du...
        wait until keyword succeeds     3min    5s    Verify All Cells Are Disabled for vDU
        log to console    check cell status should be disabled for cu...
        wait until keyword succeeds     3min    5s    Verify All Cells Are Disabled for CU
        Reset vDU With Check Cell On Air    need_check_on_air=False
        wait until keyword succeeds     15min    5s    Verify All Rmods Status Should Be Locked for vDU
        Log To Console    check RU state should be unlocked...
        SG08_keywords_cloud.Unlock RU In vDU    rmod_id_list=${rmods}
        wait until keyword succeeds     8min    5s    Verify All Rmods Status Should Be Normal for vDU
        log to console    check cell should be on air for du...
        wait until keyword succeeds     8min    5s    Verify All Cells Status Should Be Onair for vDU
        log to console    check cell should be on air for cu...
        wait until keyword succeeds     5min    5s    Verify All Cells Are Enabled for CU
        Sleep    1min
    END

RU module multiple lock unlock make call
    ${rmods}    SG08_keywords_cloud.Get Rmod List
    FOR  ${i}  IN RANGE  1   6
        log to console    lock ru for du
        SG08_keywords_cloud.Lock RU In vDU    rmod_id_list=${rmods}
        Log To Console    check RU state should be locked...
        wait until keyword succeeds     1min    5s    Verify All Rmods Status Should Be Locked for vDU
        log to console    check cell status should be disabled for du...
        wait until keyword succeeds     3min    5s    Verify All Cells Are Disabled for vDU
        log to console    check cell status should be disabled for cu...
        wait until keyword succeeds     3min    5s    Verify All Cells Are Disabled for CU
        Sleep    30s
        Log To Console    check RU state should be unlocked...
        SG08_keywords_cloud.Unlock RU In vDU    rmod_id_list=${rmods}
        wait until keyword succeeds     6min    5s    Verify All Rmods Status Should Be Normal for vDU
        log to console    check cell should be on air for du...
        wait until keyword succeeds     6min    5s    Verify All Cells Status Should Be Onair for vDU
        log to console    check cell should be on air for cu...
        wait until keyword succeeds     5min    5s    Verify All Cells Are Enabled for CU
        Sleep    1min
    END

Rmod multiple power off power on
    FOR    ${i}    IN RANGE  1    6
        Log To Console    ${i}th time RMOD power off and power on and  reset
        Mutiple RU power off
        log to console    check cell status should be disabled for du...
        wait until keyword succeeds    3min    5s    Verify All Cells Are Disabled for vDU
        log to console    check cell status should be disabled for cu...
        wait until keyword succeeds    3min    5s    Verify All Cells Are Disabled for CU
        log to console    check fault 10 reported on du
        Mutiple RU check special fault
        Mutiple RU power on
        log to console    check cell should be on air for du...
        wait until keyword succeeds     15min    5s    Verify All Cells Status Should Be Onair for vDU
        log to console    check cell should be on air for cu...
        wait until keyword succeeds     5min    5s    Verify All Cells Are Enabled for CU
        Sleep    1min
    END

Mutiple RU check special fault
    [Arguments]  ${vdu_index}=0    ${alias}=default    ${fault_id}=10
    vDU Login SG8    vdu_index=${vdu_index}
    ${rmods_status}=    vdu.get_rmods_status    vdu_connection=${alias}
    ${ru_nums}    Get Length    ${rmods_status}
    FOR    ${i}    IN RANGE    ${ru_nums}
        wait until keyword succeeds    3min    5s    Expect Fault Should Present On vDU    fault_id=${fault_id}
        ...    alarming_object=${rmods_status[${i}]['dist_names']['runtime']}
    END
    [Teardown]  Run Keyword And Ignore Error    vDU Logout SG8

Mutiple RU power off
    ${rmods_num}    Get vDU Ru numbers
    FOR    ${i}    IN RANGE    ${rmods_num}
        Cloud Perform RU Power Off    ru_index=${i}
        sleep    2s
    END

Mutiple RU power on
    ${rmods_num}    Get vDU Ru numbers
    FOR    ${i}    IN RANGE    ${rmods_num}
        Cloud Perform RU Power On    ru_index=${i}
        sleep    2s
    END

Lock unlock VDU in VCU side
    FOR    ${i}    IN RANGE    1  6
        Log To Console    lock vdu from vcu side...
        Lock DU in VCU side
        log to console    check cell status should be disabled for du...
        wait until keyword succeeds    3min    5s    Verify All Cells Are Disabled for vDU
        log to console    check cell status should be disabled for cu...
        wait until keyword succeeds    3min    5s    Verify All Cells Are Disabled for CU
        Sleep    1min
        Log To Console    unlock vdu from vdu side ...
        Unlock VDU in VCU side
        log to console    check cell should be on air for du...
        wait until keyword succeeds     3min    5s    Verify All Cells Status Should Be Onair for vDU
        log to console    check cell should be on air for cu...
        wait until keyword succeeds     3min    5s    Verify All Cells Are Enabled for CU
        Sleep    1min
    END

Lock unlock NG link in VCU side
    FOR    ${i}    IN RANGE    1  6
        Lock NG link in VCU side
        log to console    check cell status should be disabled for du...
        wait until keyword succeeds    3min    5s    Verify All Cells Are Disabled for vDU
        log to console    check cell status should be disabled for cu...
        wait until keyword succeeds    3min    5s    Verify All Cells Are Disabled for CU
        Sleep    1min
        Expect Fault Should Present On VCU    fault_id=7107
        Log To Console    unlock NG link from vdu side ...
        Unlock NG link in VCU side
        wait until keyword succeeds     3min    5s    Verify All Cells Status Should Be Onair for vDU
        log to console    check cell should be on air for cu...
        wait until keyword succeeds     3min    5s    Verify All Cells Are Enabled for CU
        Sleep    1min
    END

Lock unlock cells in VCU side
    FOR    ${i}    IN RANGE    1  6
        Log To Console    lock cells from vcu side...
        Lock cells in VCU side
        log to console    check cell status should be disabled for du...
        wait until keyword succeeds    3min    5s    Verify All Cells Are Disabled for vDU
        log to console    check cell status should be disabled for cu...
        wait until keyword succeeds    3min    5s    Verify All Cells Are Disabled for CU
        Sleep    1min
        Log To Console    unlock cells from vdu side ...
        Unlock cells in VCU side
        log to console    check cell should be on air for du...
        wait until keyword succeeds     3min    5s    Verify All Cells Status Should Be Onair for vDU
        log to console    check cell should be on air for cu...
        wait until keyword succeeds     3min    5s    Verify All Cells Are Enabled for CU
        Sleep    1min
    END

RU lock power off unlock power on interworking
    ${rmods}    SG08_keywords_cloud.Get Rmod List
    FOR  ${i}  IN RANGE  1   6
        log to console    lock ru for du
        SG08_keywords_cloud.Lock RU In vDU    rmod_id_list=${rmods}
        Log To Console    check RU state should be locked...
        wait until keyword succeeds     1min    5s    Verify All Rmods Status Should Be Locked for vDU
        Mutiple RU power off
        wait until keyword succeeds     1min    10s    Mutiple RU check special fault
        Mutiple RU power on
        wait until keyword succeeds     10min    5s    Verify All Rmods Status Should Be Locked for vDU
        Log To Console    check RU state should be unlocked...
        SG08_keywords_cloud.Unlock RU In vDU    rmod_id_list=${rmods}
        wait until keyword succeeds     2min    5s    Verify All Rmods Status Should Be Normal for vDU
        log to console    check cell should be on air for du...
        wait until keyword succeeds     15min    5s    Verify All Cells Status Should Be Onair for vDU
        log to console    check cell should be on air for cu...
        wait until keyword succeeds     5min    5s    Verify All Cells Are Enabled for CU
        Sleep    1min
    END

NG lock VCU reset NG unlock
    FOR    ${i}    IN RANGE    1  6
        Lock NG link in VCU side
        log to console    check cell status should be disabled for du...
        wait until keyword succeeds    3min    5s    Verify All Cells Are Disabled for vDU
        log to console    check cell status should be disabled for cu...
        wait until keyword succeeds    3min    5s    Verify All Cells Are Disabled for CU
        Sleep    30s
        Expect Fault Should Present On VCU    fault_id=7107
        Reset vCU With Check Cell On Air    need_check_on_air=False
        wait until keyword succeeds    5min    30s    Check VCU should be enabled
        sleep    20s
        Unlock NG link in VCU side
        log to console    check cell should be on air for du...
        wait until keyword succeeds     15min    5s    Verify All Cells Status Should Be Onair for vDU
        log to console    check cell should be on air for cu...
        wait until keyword succeeds     3min    5s    Verify All Cells Are Enabled for CU
        Sleep    1min
    END

VDU lock RU reset VDU unlock
    ${rmods}    SG08_keywords_cloud.Get Rmod List
    FOR    ${i}    IN RANGE    1  6
        Lock DU in VCU side
        log to console    check cell status should be disabled for du...
        wait until keyword succeeds     3min    5s    Verify All Cells Are Disabled for vDU
        log to console    check cell status should be disabled for cu...
        wait until keyword succeeds     3min    5s    Verify All Cells Are Disabled for CU
        SG08_keywords_cloud.Reset Rmod By Rest    rmods_list=${rmods}
        log to console    check cell rmod should be disabled for du...
        wait until keyword succeeds     3min    5s    Verify All RMOD Are Disabled for vDU
        wait until keyword succeeds     15min    5s    Verify All Rmods Status Should Be Normal for vDU
        Unlock VDU in VCU side
        log to console    check cell should be on air for du...
        wait until keyword succeeds     10min    5s    Verify All Cells Status Should Be Onair for vDU
        log to console    check cell should be on air for cu...
        wait until keyword succeeds     3min    5s    Verify All Cells Are Enabled for CU
        Sleep    1min
    END

VDU lock VDU reset VDU unlock
    FOR    ${i}    IN RANGE    1  6
        Lock DU in VCU side
        log to console    check cell status should be disabled for du...
        wait until keyword succeeds     3min    5s    Verify All Cells Are Disabled for vDU
        log to console    check cell status should be disabled for cu...
        wait until keyword succeeds     3min    5s    Verify All Cells Are Disabled for CU
        Reset vDU With Check Cell On Air    need_check_on_air=False
        wait until keyword succeeds     15min    5s    Verify All Rmods Status Should Be Normal for vDU
        Unlock VDU in VCU side
        log to console    check cell should be on air for du...
        wait until keyword succeeds     10min    5s    Verify All Cells Status Should Be Onair for vDU
        log to console    check cell should be on air for cu...
        wait until keyword succeeds     3min    5s    Verify All Cells Are Enabled for CU
        Sleep    1min
    END

NG lock VDU reset NG unlock
    FOR    ${i}    IN RANGE    1  6
        Lock NG link in VCU side
        log to console    check cell status should be disabled for du...
        wait until keyword succeeds     3min    5s    Verify All Cells Are Disabled for vDU
        log to console    check cell status should be disabled for cu...
        wait until keyword succeeds     3min    5s    Verify All Cells Are Disabled for CU
        Sleep    30s
        Expect Fault Should Present On VCU    fault_id=7107
        Reset vDU With Check Cell On Air    need_check_on_air=False
        wait until keyword succeeds     15min    5s    Verify All Rmods Status Should Be Normal for vDU
        Unlock NG link in VCU side
        log to console    check cell should be on air for du...
        wait until keyword succeeds     10min    5s    Verify All Cells Status Should Be Onair for vDU
        log to console    check cell should be on air for cu...
        wait until keyword succeeds     3min    5s    Verify All Cells Are Enabled for CU
        Sleep    1min
    END

NG lock RU reset NG unlock
    ${rmods}    SG08_keywords_cloud.Get Rmod List
    FOR    ${i}    IN RANGE    1  6
        Lock NG link in VCU side
        log to console    check cell status should be disabled for du...
        wait until keyword succeeds     3min    5s    Verify All Cells Are Disabled for vDU
        log to console    check cell status should be disabled for cu...
        wait until keyword succeeds     3min    5s    Verify All Cells Are Disabled for CU
        Sleep    30s
        Expect Fault Should Present On VCU    fault_id=7107
        SG08_keywords_cloud.Reset Rmod By Rest    rmods_list=${rmods}
        wait until keyword succeeds     2min    20s    Verify All Rmods Status Should Be disabled for vDU
        wait until keyword succeeds     15min    5s    Verify All Rmods Status Should Be Normal for vDU
        Unlock NG link in VCU side
        log to console    check cell should be on air for du...
        wait until keyword succeeds     10min    5s    Verify All Cells Status Should Be Onair for vDU
        log to console    check cell should be on air for cu...
        wait until keyword succeeds     3min    5s    Verify All Cells Are Enabled for CU
        Sleep    1min
    END

Cells lock VCU reset Cells unlock
    FOR    ${i}    IN RANGE    1  6
        Lock cells in VCU side
        log to console    check cell status should be disabled for du...
        wait until keyword succeeds    3min    5s    Verify All Cells Are Disabled for vDU
        log to console    check cell status should be disabled for cu...
        wait until keyword succeeds    3min    5s    Verify All Cells Are Disabled for CU
        Sleep    30s
        Reset vCU With Check Cell On Air    need_check_on_air=False
        sleep    1min
        wait until keyword succeeds     3min    5s    Check VCU should be enabled
        wait until keyword succeeds    5min    1min   Unlock cells in VCU side
        log to console    check cell should be on air for du...
        wait until keyword succeeds     15min    5s    Verify All Cells Status Should Be Onair for vDU
        log to console    check cell should be on air for cu...
        wait until keyword succeeds     3min    5s    Verify All Cells Are Enabled for CU
        Sleep    1min
    END

Cells lock VDU reset Cells unlock
    FOR    ${i}    IN RANGE    1  6
        Lock cells in VCU side
        log to console    check cell status should be disabled for du...
        wait until keyword succeeds    3min    5s    Verify All Cells Are Disabled for vDU
        log to console    check cell status should be disabled for cu...
        wait until keyword succeeds    3min    5s    Verify All Cells Are Disabled for CU
        Sleep    30s
        Reset vDU With Check Cell On Air    need_check_on_air=False
        wait until keyword succeeds    5min    1min   Unlock cells in VCU side
        log to console    check cell should be on air for du...
        wait until keyword succeeds     3min    5s    Verify All Cells Status Should Be Onair for vDU
        log to console    check cell should be on air for cu...
        wait until keyword succeeds     3min    5s    Verify All Cells Are Enabled for CU
        Sleep    1min
    END

Cells lock RU reset Cells unlock
    ${rmods}    SG08_keywords_cloud.Get Rmod List
    FOR    ${i}    IN RANGE    1  6
        Lock cells in VCU side
        log to console    check cell status should be disabled for du...
        wait until keyword succeeds    3min    5s    Verify All Cells Are Disabled for vDU
        log to console    check cell status should be disabled for cu...
        wait until keyword succeeds    3min    5s    Verify All Cells Are Disabled for CU
        Sleep    30s
        SG08_keywords_cloud.Reset Rmod By Rest    rmods_list=${rmods}
        log to console    check cell rmod should be disabled for du...
        wait until keyword succeeds     3min    5s    Verify All RMOD Are Disabled for vDU
        wait until keyword succeeds     6min    5s    Verify All Rmods Status Should Be Normal for vDU
        wait until keyword succeeds    5min    1min   Unlock cells in VCU side
        log to console    check cell should be on air for du...
        wait until keyword succeeds     3min    5s    Verify All Cells Status Should Be Onair for vDU
        log to console    check cell should be on air for cu...
        wait until keyword succeeds     3min    5s    Verify All Cells Are Enabled for CU
        Sleep    1min
    END

Cells lock and unlock in VDU
    FOR    ${i}    IN RANGE    1    6
        Log To Console    ${i}th loop...
        Lock Cells In vDU
        log to console    check cell status should be disabled for du...
        wait until keyword succeeds    3min    5s    Verify All Cells Are Disabled for vDU
        log to console    check cell status should be disabled for cu...
        wait until keyword succeeds    3min    5s    Verify All Cells Are Disabled for CU
        Sleep    1min
        Unlock Cells In vDU
        log to console    check cell should be on air for du...
        wait until keyword succeeds     15min    5s    Verify All Cells Status Should Be Onair for vDU
        log to console    check cell should be on air for cu...
        wait until keyword succeeds     3min    5s    Verify All Cells Are Enabled for CU
        Sleep    1min
    END

cell lock unlock and RMOD deepsleep
    commission scf    vdu_scf_path=${scf_path_du}/${scf_name_du_energysaving}
    ...    cu_scf_path=${scf_path_cu}/SCF_SBTS${release_cu}_${version_cu}.xml
    ...    wait_for_completion=True
    FOR    ${i}    IN RANGE    1    4
        Lock Cells In vDU
        log to console    check cell status should be disabled for du...
        wait until keyword succeeds    3min    5s    Verify All Cells Are Disabled for vDU
        log to console    check cell status should be disabled for cu...
        wait until keyword succeeds    3min    5s    Verify All Cells Are Disabled for CU
        Sleep    6min
        wait until keyword succeeds    3min    5s    Verify All RMOD Status Should enter deepsleep for vDU
        Unlock Cells In vDU
        log to console    check cell should be on air for du...
        wait until keyword succeeds     10min    5s    Verify All Cells Status Should Be Onair for vDU
        log to console    check cell should be on air for cu...
        wait until keyword succeeds     3min    5s    Verify All Cells Are Enabled for CU
        Sleep    30s
    END

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
    set suite variable    ${scf_name_du_energysaving}    SCF_SBTS${release_du}_${version_du}_energysaving.xml