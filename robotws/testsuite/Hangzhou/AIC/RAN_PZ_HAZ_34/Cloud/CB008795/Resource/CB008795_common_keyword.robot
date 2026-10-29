*** Settings ***
Documentation     author: linjiangjing
...               Group: HGZ_SG8
...               contact: jiangjing.lin@nokia-sbell.com

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG08_keywords_cloud.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Library    ../lib/CB008795.py


*** Variables ***
${SBTS_RM_MAX_TEMPERATURE}    M40008C1
${SBTS_SFP_RM_AVG_TEMPERATURE}    M40005C2
${MRBTS_ID}    ${tl.gnbs[0].cu.instance_id}
${SBTS_RM_MAX_TEMPERATURE_DIST}    MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
${SBTS_SFP_RM_AVG_TEMPERATURE_DIST}    MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1/SFP-1
${ns}    ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.namespace}

*** Keywords ***
activate and deactivate rmod max temperature counter
    ${date}    Get Current Date
    ${split_date}=    Split String    ${date}    :
    ${current_minute_number}=    Convert To String    ${split_date}[1]
    @{handler_minute_number}    create list     00    15    30    45
    ${status}=    Run Keyword And Return Status    List Should Contain Value    ${handler_minute_number}    ${current_minute_number}
    Run Keyword If    ${status}==True    sleep    1min
    ${counter_before}    Get Pointed Counter For vDU    counter_id=${SBTS_RM_MAX_TEMPERATURE}    dimension_dn=${SBTS_RM_MAX_TEMPERATURE_DIST}
    log to console    counter info before sleep 15min: ${counter_before}
    sleep    15min
    log to console    ******check counter the first time*********
    ${counter_after}    Get Pointed Counter For vDU    counter_id=${SBTS_RM_MAX_TEMPERATURE}    dimension_dn=${SBTS_RM_MAX_TEMPERATURE_DIST}
    log to console    counter info after sleep 15min: ${counter_after}
    Should Be Equal      ${counter_before[-1]}    ${counter_after[-2]}
    Should Not Be Equal    ${counter_after[-1]['value']}    ${Null}
    sleep    15min
    log to console    *****check counter the second time**********
    ${counter_last}    Get Pointed Counter For vDU    counter_id=${SBTS_RM_MAX_TEMPERATURE}    dimension_dn=${SBTS_RM_MAX_TEMPERATURE_DIST}
    log to console    counter info after the second sleep 15min: ${counter_last}
    Should Be Equal      ${counter_after[-1]}    ${counter_last[-2]}
    Should Not Be Equal    ${counter_last[-1]['value']}    ${Null}
    log to console    set mtSBTSRMODTemperature to disabled
    ${mo_dn}    set variable    MRBTS-${mrbtsID}/MNL-1/MNLENT-1/PMMNL-1
    &{parameter_dict}    Create Dictionary   mtSBTSRMODTemperature=disabled
    vDU Login
    ${value}    Online Get VDU Parameter Value    mo_dn=${mo_dn}    para_name=mtSBTSRMODTemperature
    run keyword if    '${value}'!='disabled'    VDU Online Modify Parameters By Delta Plan REST    mo_dn=${mo_dn}
    ...    updated_paras_list=${parameter_dict}
    ${counter_before}    Get Pointed Counter For vDU    counter_id=${SBTS_RM_MAX_TEMPERATURE}    dimension_dn=${SBTS_RM_MAX_TEMPERATURE_DIST}
    log to console    counter info before sleep 15min: ${counter_before}
    sleep    15min
    log to console    ******check counter*********
    ${counter_after}    Get Pointed Counter For vDU    counter_id=${SBTS_RM_MAX_TEMPERATURE}    dimension_dn=${SBTS_RM_MAX_TEMPERATURE_DIST}
    log to console    counter info after sleep 15min: ${counter_after}
    run keyword if    '${value}'=='disabled'    Should Be Equal      ${counter_before[-1]}    ${counter_after[-1]}    ELSE
    ...    Should Be Equal      ${counter_before[-1]}    ${counter_after[-2]}
    sleep    15min
    log to console    *****check counter**********
    ${counter_last}    Get Pointed Counter For vDU    counter_id=${SBTS_RM_MAX_TEMPERATURE}    dimension_dn=${SBTS_RM_MAX_TEMPERATURE_DIST}
    log to console    counter info after the second sleep 15min: ${counter_last}
    Should Be Equal      ${counter_after[-1]}    ${counter_last[-1]}
    [Teardown]    run keyword and ignore error    vDU Logout

activate and deactivate sfp rm avg temperature counter
    ${date}    Get Current Date
    ${split_date}=    Split String    ${date}    :
    ${current_minute_number}=    Convert To String    ${split_date}[1]
    @{handler_minute_number}    create list     00    15    30    45
    ${status}=    Run Keyword And Return Status    List Should Contain Value    ${handler_minute_number}    ${current_minute_number}
    Run Keyword If    ${status}==False    sleep    1min
    ${counter_before}    Get Pointed Counter For vDU    counter_id=${SBTS_SFP_RM_AVG_TEMPERATURE}    dimension_dn=${SBTS_SFP_RM_AVG_TEMPERATURE_DIST}
    log to console    counter info before sleep 15min: ${counter_before}
    sleep    15min
    log to console    ******check counter the first time*********
    ${counter_after}    Get Pointed Counter For vDU    counter_id=${SBTS_SFP_RM_AVG_TEMPERATURE}    dimension_dn=${SBTS_SFP_RM_AVG_TEMPERATURE_DIST}
    log to console    counter info after sleep 15min: ${counter_after}
    Should Be Equal      ${counter_before[-1]}    ${counter_after[-2]}
    Should Not Be Equal    ${counter_after[-1]['value']}    ${Null}
    sleep    15min
    log to console    *****check counter the second time**********
    ${counter_last}    Get Pointed Counter For vDU    counter_id=${SBTS_SFP_RM_AVG_TEMPERATURE}    dimension_dn=${SBTS_SFP_RM_AVG_TEMPERATURE_DIST}
    log to console    counter info after the second sleep 15min: ${counter_last}
    Should Be Equal      ${counter_after[-1]}    ${counter_last[-2]}
    Should Not Be Equal    ${counter_last[-1]['value']}    ${Null}
    log to console    set mtSBTSSfpRMOD to disabled
    ${mo_dn}    set variable    MRBTS-${mrbtsID}/MNL-1/MNLENT-1/PMMNL-1
    &{parameter_dict}    Create Dictionary   mtSBTSSfpRMOD=disabled
    vDU Login
    ${value}    Online Get VDU Parameter Value    mo_dn=${mo_dn}    para_name=mtSBTSSfpRMOD
    run keyword if    '${value}'!='disabled'    VDU Online Modify Parameters By Delta Plan REST    mo_dn=${mo_dn}
    ...    updated_paras_list=${parameter_dict}
    ${counter_before}    Get Pointed Counter For vDU    counter_id=${SBTS_SFP_RM_AVG_TEMPERATURE}    dimension_dn=${SBTS_SFP_RM_AVG_TEMPERATURE_DIST}
    log to console    counter info before sleep 15min: ${counter_before}
    sleep    15min
    log to console    ******check counter*********
    ${counter_after}    Get Pointed Counter For vDU    counter_id=${SBTS_SFP_RM_AVG_TEMPERATURE}    dimension_dn=${SBTS_SFP_RM_AVG_TEMPERATURE_DIST}
    log to console    counter info after sleep 15min: ${counter_after}
    run keyword if    '${value}'=='disabled'    Should Be Equal      ${counter_before[-1]}    ${counter_after[-1]}    ELSE
    ...    Should Be Equal      ${counter_before[-1]}    ${counter_after[-2]}
    sleep    15min
    log to console    *****check counter**********
    ${counter_last}    Get Pointed Counter For vDU    counter_id=${SBTS_SFP_RM_AVG_TEMPERATURE}    dimension_dn=${SBTS_SFP_RM_AVG_TEMPERATURE_DIST}
    log to console    counter info after the second sleep 15min: ${counter_last}
    Should Be Equal      ${counter_after[-1]}    ${counter_last[-1]}
    [Teardown]    run keyword and ignore error    vDU Logout

sfp power compatibility validation on rmod
    log to console    reset vdu and check cell onair
    Reset vDU With Check Cell On Air
    log to console    check no unexpected alarms
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist For Cloud
    ...    allowed_faults=@{ALLOWED_FAULT_CLOUD}
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
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist For Cloud
    ...    allowed_faults=@{ALLOWED_FAULT_CLOUD}
    should be true    ${alarm_status}
    log to console    check sfpWhitelist.xml exists under /opt/nokia/OAM
    log to console    login vdu ssh server
    ${alias}  get unique id
    Connect To vDU K8s Master   alias=${alias}
    ${container_name}    set variable    ctr-${ns}-oamfh
    ${pod_name}    Set Variable   po-${ns}-oamfh-0
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
    FOR    ${i}    IN RANGE    0    2
        &{parameter_dict_true}    Create Dictionary   sfpOperatorMode=true
        &{parameter_dict_false}    Create Dictionary   sfpOperatorMode=false
        ${mo_dn}    set variable    MRBTS-${mrbtsID}/EQM-1/APEQM-1
        vDU Login
        ${value}    Online Get VDU Parameter Value    mo_dn=${mo_dn}    para_name=sfpOperatorMode
        run keyword if    '${value}'=='false'    VDU Online Modify Parameters By Delta Plan REST    mo_dn=${mo_dn}
        ...    updated_paras_list=${parameter_dict_true}    ELSE
        ...    VDU Online Modify Parameters By Delta Plan REST    mo_dn=${mo_dn}    updated_paras_list=${parameter_dict_false}
        ${value_after}    Online Get VDU Parameter Value    mo_dn=${mo_dn}    para_name=sfpOperatorMode
        run keyword if    '${value}'=='false'    Should Be Equal    '${value_after}'    'true'    ELSE
        ...    Should Be Equal    '${value_after}'    'false'    ELSE
        wait until keyword succeeds     5min    30s    Verify All Cells Status Should Be Onair for vDU
    END
    vDU Login
    ${mo_dn}    set variable    MRBTS-${mrbtsID}/EQM_R-1/APEQM_R-1/RMOD_R-1/SFP_R-1
    ${value}    Online Get VDU Parameter Value    mo_dn=${mo_dn}    para_name=transceiverComplianceCode
    Should Be Equal    '${value}'    '25Gbase_LR'
    [Teardown]    run keywords    run keyword and ignore error  issh.disconnect  alias=${alias}    AND
    ...    run keyword and ignore error    vDU Logout

Initial Parameter Values For 8795
    log to console    set mtSBTSRMODTemperature to 15min
    ${mo_dn}    set variable    MRBTS-${mrbtsID}/MNL-1/MNLENT-1/PMMNL-1
    &{parameter_dict}    Create Dictionary   mtSBTSRMODTemperature=15min
    vDU Login
    ${value}    Online Get VDU Parameter Value    mo_dn=${mo_dn}    para_name=mtSBTSRMODTemperature
    run keyword if    '${value}'!='15min'    VDU Online Modify Parameters By Delta Plan REST    mo_dn=${mo_dn}    updated_paras_list=${parameter_dict}
    log to console    set mtSBTSSfpRMOD to 15min
    ${mo_dn}    set variable    MRBTS-${mrbtsID}/MNL-1/MNLENT-1/PMMNL-1
    &{parameter_dict}    Create Dictionary   mtSBTSSfpRMOD=15min
    ${value}    Online Get VDU Parameter Value    mo_dn=${mo_dn}    para_name=mtSBTSSfpRMOD
    run keyword if    '${value}'!='15min'    VDU Online Modify Parameters By Delta Plan REST    mo_dn=${mo_dn}    updated_paras_list=${parameter_dict}
    sleep    17min
    [Teardown]    run keyword and ignore error    vDU Logout
