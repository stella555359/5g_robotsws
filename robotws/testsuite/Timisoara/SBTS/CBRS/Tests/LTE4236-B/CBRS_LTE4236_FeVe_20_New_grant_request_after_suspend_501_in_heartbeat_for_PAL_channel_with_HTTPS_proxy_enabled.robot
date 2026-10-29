*** Settings ***
Documentation
...    = Author =
...    michal.moskala@nokia.com
...    = Maintainer =
...    Lukasz.lechowicz@nokia.com
...    = Reviewer =
...    Artur.Czainski@nokia.com
...    Lukasz.lechowicz@nokia.com
...    = Summary =
...    Purpose: Verify the behavior of acquiring new grant when receiving suspension in heartbeat response during https usage with a
...    short connection timeout and connection latency

*** Keywords ***
CBRS_LTE4236_FeVe_20_New_grant_request_after_suspend_501_in_heartbeat_for_PAL_channel_with_HTTPS_proxy_enabled
    [Documentation]  Requirement: OM_GEN_SFS_CBRS.314

    ${enb_id}                    Set Variable         ${testlines.${testline_id}.enb_id}
    ${proxy_ip}                  Set Variable         ${testlines.${testline_id}.vm_ip}
    ${HTTPS_proxy_port}          Set Variable         4434
    ${connectToSasMode}          Set Variable         connect through https proxy
    ${primaryHttpsProxyServer}   Catenate             SEPARATOR=:    ${proxy_ip}    ${HTTPS_proxy_port}
    ${alias}                     Set Variable         RAT_1ST
    &{expected_alarm}            Create Dictionary    fault_id=6825    fault_name=SAS Grant Suspension Failure    severity=Critical
    ${expected_alarms_objects}   Create Watchdog Alarm List    ${expected_alarm}

    Kill All SAS Processes

    ${AEQM_present}   Run Keyword And Return Status    Query Infomodel
    ...                 query=check /MRBTS-*/RAT-*/BTS_L-*/EQM_L-*/RMOD_L-* is [productName=regex"(?i)AEQM"]
    ...                 timeout=30
    ...                 alias=${alias}

    ${sas_pid}    ${sas_logs_dir} =    Start SAS Process    config=${CURDIR}/Data/FeVe20/SAS_Sim.conf

    ${sas_proxy_pid}    ${sas_proxy_log_dir}   Start SAS HTTPS Proxy With Timeout    alias=default
    Wait For All Cells To Be OnAir
    Wait Until BTS Is Not Busy
    ${precondition_plan}   Replace Variables In File
    ...                      file_path=${CURDIR}/Data/FeVe20/FEVE_20_Precond_delta_tmp.json
    ...                      file_destination=${OUTPUT DIR}/FEVE_20_Precond_delta.json
    ...                      connectToSasMode=${connectToSasMode}
    ...                      primaryHttpsProxyServer=${primaryHttpsProxyServer}
    ...                      enb_id=${enb_id}

    ${postcondition_plan}   Replace Variables In File
    ...                       file_path=${CURDIR}/Data/FeVe20/FEVE_20_Postcond_delta_tmp.json
    ...                       file_destination=${OUTPUT DIR}/FEVE_20_Postcond_delta.json
    ...                       enb_id=${enb_id}
    Perform Delta Recommissioning    ${precondition_plan}    connection=${alias}
    Sleep And Display Progress    60    s
    Wait For All Cells To Be On Air
    Start Watchdog Alarm Detection    expected_alarms=${expected_alarms_objects}

    ${ca_status}   Run Keyword And Return Status    Query Infomodel    alias=${alias}
    ...    query=check /MRBTS-1/RAT-1/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-${enb_id}/LNBTS_A-${enb_id} is [actDLCAggr=true]


    ${cbsd_id}   Fetch CBSD ID    ${enb_id}
    FOR    ${i}    IN RANGE    10
        ${active_grant_list}   List Values of GrantId For All Cells    ${enb_id}
        ${random_grant_to_suspend}   evaluate    random.choice(${active_grant_list})    modules=random
        ${grant_suspend_time}   Get Time
        Send Command To SAS Manager    alias=default    command=grant_suspend ${cbsd_id} ${random_grant_to_suspend}
        Append To File    ${TEST_LOGS_DIR_PATH}/GrantSuspendingHistory.txt
        ...    ${grant_suspend_time} Grant ${random_grant_to_suspend} -- SUSPENDED ${\n}
        Log To Console    Grant ${random_grant_to_suspend} suspended on ${grant_suspend_time}
        Wait For Any Cell To Be Dropped    wait_time=8min
        IF  '${ca_status}'=='False'  Continously Check If Number Of Enabled Cells Is Adequate
        Wait For All Cells To Be OnAir
        ${new_active_grant_list}   List Values of GrantId For All Cells    ${enb_id}
        IF  '${AEQM_present}'=='False'  Should Not Be Equal  ${new_active_grant_list}  ${active_grant_list}
        ${grant_free_time}   Get Time
        Send Command To SAS Manager    alias=default    command=grant_free ${cbsd_id} ${random_grant_to_suspend}
        Append To File    ${TEST_LOGS_DIR_PATH}/GrantSuspendingHistory.txt
        ...    ${grant_free_time} Grant ${random_grant_to_suspend} -- suspension cleared ${\n}
        Log To Console    Grant ${random_grant_to_suspend} freed on ${grant_free_time}
        Watchdog Check For Failures
    END
    Remove Fault From Watchdog Ignored List    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                        severity=${expected_alarm}[severity]
    Repeat Keyword    15    Check If Cell Status Remains Onair

    [Teardown]    Run Keywords
    ...    Get SAS Logs To Logs Dir    alias=default    AND
    ...    Get SAS Proxy Logs To Logs Dir    alias=default    AND
    ...    Stop Watchdog Alarm Detection And Check For Failures    AND
    ...    Kill All SAS Processes    AND
    ...    Run    kill ${sas_proxy_pid}    AND
    ...    Wait Until BTS Is Not Busy    AND
    ...    Perform Delta Recommissioning    ${postcondition_plan}    connection=${alias}


Start SAS HTTPS Proxy With Timeout
    [Arguments]    ${alias}=default
    [Documentation]    Author: michal.kosicki@nokia.com
    ...                Maintainer: Michal Kosicki
    ${result}   Run    cp ${CURDIR}/Data/FeVe20/HttpsProxy2Damo.py /home/ute/SASSim/${alias}/
    ${handle}   Start Process    python    /home/ute/SASSim/${alias}/HttpsProxy2Damo.py
    ${pid}   Get Process Id    ${handle}
    ${https_logs_path}   Set Variable    /home/ute/SASSim/${alias}/HttpsProxy.log
    RETURN    ${pid}    ${https_logs_path}
