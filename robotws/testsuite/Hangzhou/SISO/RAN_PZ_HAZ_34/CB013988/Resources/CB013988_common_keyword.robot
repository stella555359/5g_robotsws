*** Settings ***
Documentation      author: Yang Di
...                contact: di.yang@nokia-sbell.com
...                This robot file is for CB013988

Resource   ../../../../resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource   ../../../../resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot

*** Keywords ***
Crash RU
    [Arguments]    ${ru_index}=1
    ${get_internal_counter}  csn.execute  command=cat /mnt/runtime/sw2por_counter  connection=RU_${ru_index}
    ${output}  csn.execute  command=date    connection=RU_${ru_index}
    ${ps_w_output}  csn.execute  command=ps w |grep fan    connection=RU_${ru_index}
    Log  ${ps_w_output}
    ${ps_Killcmd_RU}  csn.execute  command=ps w |grep fan |grep instance | awk '{print $1}' | xargs sudo kill -11 $1
    ...    connection=RU_${ru_index}
    [Teardown]  run keyword and ignore error    csn.Disconnect  connection=RU_${ru_index}

Crash RU to Trigger POOR
    [Arguments]    ${ru_index}=1
    @{FAULT_ID_ALLOW}=    Create List    10     1981     4590
    AlarmWatchdog.add_allow_alarms    fault_id=${FAULT_ID_ALLOW}
    Connect to Common Unit Master
    log to console    ******* Log in RU ********
    Connect to RU With Allocated IP    asik_alias=ASIK Master    ru_alias=RU_${ru_index}    ru_index=${ru_index}
    ${feature_on}  csn.execute  command=ccsShell.sh rad -mpw 0xc001d 0  connection=RU_${ru_index}
    ${check_feature_on}  csn.execute  command=cat /mnt/runtime/swconfig.txt  connection=RU_${ru_index}
    ${output}  csn.execute  command=ls -l /mnt/runtime/RecovPorLogs/  connection=RU_${ru_index}
    ${old_logs}  csn.execute  command=ls -l /mnt/runtime/RecovPorLogs/ |grep zip  connection=RU_${ru_index}
    Crash RU    ru_index=${ru_index}
    Wait For Expect Fault Present    faultId=10    timeout=300
    Wait until Keyword Succeeds  600s  30s  Connect to RU With Allocated IP  asik_alias=ASIK Master
    ...  ru_alias=RU_${ru_index}  ru_index=${ru_index}
    ${POOR_counter}    Check Overall RU Reset Counter    ru_index=${ru_index}
    ##Sleep    60s
    Crash RU    ru_index=${ru_index}
    ${POOR_counter}=    evaluate    ${POOR_counter}+1
    Set test variable    ${COUNTER_OVERALL}    ${POOR_counter}
    Set test variable    ${OLD_RECOV_LOGS}    ${old_logs}

Check if fault is active
    [Arguments]    ${cause}=RecoveryReset(13)    ${resetSignal}=soft_reset(9)
    ${is_soft_reset}    Run Keyword And Return Status    Should Contain    ${resetSignal}    soft_reset
    ${fault_status_1}    Run Keyword If    ${is_soft_reset}    run keyword and return status
    ...    Expect Fault Should Present    faultId=1981    ELSE    set variable    ${False}
    ${fault_status_2}    run keyword and return status    Expect Fault Should Present    faultId=4590
    ...    fault_signature_info=resetCause=${cause},resetSignal=${resetSignal}
    ...    fault_signature_rfmgpp=lastFailedServiceClassId=fans,lastFailedServiceInstanceId=instance1
    Set Test Variable     ${fault_1981_present}   ${fault_status_1}
    Run Keyword If  ${fault_status_1}==${False} and ${fault_status_2}==${False}   Fail   fault is not present on gnb.

Check RU Reset Counter and BBOX Information
    [Arguments]    ${ru_index}=1    ${cause}=RecoveryReset(13)    ${resetSignal}=soft_reset(9)    ${count_internal}=2
    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds   600   10s    Check if fault is active    cause=${cause}    resetSignal=${resetSignal}
#    Run Keyword If  ${fault_1981_present}  Wait For Expect Fault Present    faultId=10    timeout=600
    Wait Until Keyword Succeeds   30min   30s     Run Keywords    coam.Get Active Alarms    connection=GNB_OAM    AND
    ...     Check all cells info should be onair
    Connect to RU With Allocated IP    asik_alias=ASIK Master    ru_alias=RU_${ru_index}    ru_index=${ru_index}
    ${get_internal_counter}  csn.execute  command=cat /mnt/runtime/sw2por_counter  connection=RU_${ru_index}
    run keyword if    ${count_internal}==${2}    Should Be Equal As Strings  ${get_internal_counter}  ${count_internal}
    ${file_name}    Download and Unzip BBOX    ru_index=${ru_index}
    ${last_reset}    Run     grep "Reset\\[0\\]" ${file_name}
    ${reset_reason}    Fetch from left    string=${resetSignal}    marker=(
    ${blackbox_reset_reason}    Run     grep "Reset\\[0\\]" ${file_name}|grep -i reason
    Should contain      ${blackbox_reset_reason}   ${reset_reason}
    ${blackbox_reset_cause}    Run     grep "Reset\\[0\\]" ${file_name}|grep -i cause
    run keyword if    ${count_internal}==${2}    Should contain      ${blackbox_reset_cause}   RecoveryReset
    ${blackbox_failed_service}    Run     grep "Reset\\[0\\]" ${file_name}|grep -i failed
    should contain any      ${blackbox_failed_service}   fans::instance1    N/A
    ${reset_counter}    Run     grep "Reset Counter" ${file_name}
    ${blackbox_overall_counter}    Run     grep "Reset Counter" ${file_name} |head -1
    ${POOR_COUNTER}    Set Variable    ${blackbox_overall_counter.split(' ')}[-1]
    Should Be Equal As Strings  ${POOR_COUNTER}  ${COUNTER_OVERALL}
    run keyword if    ${count_internal}==${2}    Check RU Recov Logs    ru_index=${ru_index}

Check RU Recov Logs
    [Arguments]    ${ru_index}=1
    ${output}    csn.execute  command=ls -l /mnt/runtime/RecovPorLogs/  connection=RU_${ru_index}
    should contain    ${output}    RecovPorLogs1.zip
    ${output}    csn.execute  command=ls -l /mnt/runtime/RecovPorLogs/ |grep zip  connection=RU_${ru_index}
    Should not Be Equal As Strings    ${OLD_RECOV_LOGS}    ${output}

Download and Unzip BBOX
    [Arguments]    ${ru_index}=1
    ${BBOX5_path_on_testPC}    Download RU File To TestPC    ru_file_path=/rpram/BBOX5.zip
    ...                        connection=RU_${ru_index}    download_dir=${TS_CASE_LOG_PATH}
    ${unzip_result}    Run     unzip -o ${BBOX5_path_on_testPC} -d ${TS_CASE_LOG_PATH}
    ${file_name}    Fetch from left    string=${BBOX5_path_on_testPC}    marker=.zip
    [Return]  ${TS_CASE_LOG_PATH}BBOX5

Check Overall RU Reset Counter
    [Arguments]    ${ru_index}=1
    ${file_name}    Download and Unzip BBOX    ru_index=${ru_index}
    ${blackbox_overall_counter}    Run     grep "Reset Counter" ${file_name} |head -1
    ${POOR_COUNTER}    Set Variable    ${blackbox_overall_counter.split(' ')}[-1]
    [Return]  ${POOR_COUNTER}

