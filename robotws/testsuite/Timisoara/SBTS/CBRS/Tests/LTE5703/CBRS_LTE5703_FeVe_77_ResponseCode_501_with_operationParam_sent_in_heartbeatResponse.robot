*** Settings ***
Documentation
...    = Author = Valentin Suru
...    _valentin.suru@nokia.com_
...    = Maintainer = Valentin Suru
...    _valentin.suru@nokia.com_

*** Keywords ***
CBRS_LTE5703_FeVe_77_ResponseCode_501_with_operationParam_sent_in_heartbeatResponse
    [Documentation]    The purpose of this test is to verify eNB waits
    ...    for RC:501 in first HB response with decreased maxEirp (20dBm) inside operationParam.
    ...    Also checks if relinquishment was performed and new grantRequest with lowered maxEirp (20dBm) was sent.
    ...    Tested Requirement: OM_GEN_SFS_CBRS.381


#Variables setup

    ${enb_id}=    Set Variable    ${testlines.${testline_id}.enb_id}
    ${alias}=    Set Variable    RAT_1ST
    ${sas_log_feve77}=    Set Variable    /home/ute/SASSim/default/SAS_Sim.log
    &{expected_alarm_1}=    Create Dictionary    fault_id=6825    fault_name=SAS Grant Suspension Failure    severity=Critical
    ...                                          reason=responseCode : 501 transmitExpireTime expires.
    ${expected_alarms_list}=       Create List    ${expected_alarm_1}
    ${expected_alarms_objects}=    Create Watchdog Alarm List    ${expected_alarms_list}

    Log To Console    Kill SAS if exists
    Disable CBRS Feature On eNB
    Kill All SAS Processes
    Start Watchdog Alarm Detection    expected_alarms=${expected_alarms_objects}

    Log To Console    Full Recommissioning is in progress. May take up to 10 minutes.
    Wait Until BTS Is Not Busy
    ${SCF_3cells_10MHz}=    Set Variable    ${CURDIR}/Data/FeVe_77/Configuration_scf_MRBTS-10677_FeVe77_SAS1.xml
    Perform Commissioning    bts_id=${enb_id}
    ...                      scf_file=${SCF_3cells_10MHz}
    ...                      skip_parameter_relation=True
    ...                      timeout=600s
    ...                      connection=RAT_1ST

    Wait Until BTS Is Not Busy
    Log To Console    Recommissioning completed.

    Log To Console    Step 1. Start SAS. Setting SAS to respond 501 in first heartbeat with decreased maxEirp (20dBm) inside operationParam
    ${sas_pid}    ${sas_log}=    Start SAS Process    config=${CURDIR}/Data/FeVe_77/SAS_Sim.conf
    Enable CBRS Feature On eNB
    Log To Console    Wait For All Cells To Be OnAir
    Wait For All Cells To Be OnAir
    ${cbsd_id}=    Wait Until Keyword Succeeds    20x    30s    Get CBSD Id From Infomodel
    ${active_grant_list}=    List Values of GrantId For All Cells    ${enb_id}

    Log To Console    Step 2. Wait for RC:501 in first HB response with decreased maxEirp (20dBm) inside operationParam
    Log To Console    Checking whether heartbeat message with responseCode: 501 is presented in SAS_Sim.log
    ${heartbeatresponse_501}=    Run    grep -n '"responseCode": 501' ${sas_log_feve77} | tail -n1
    Should Not Be Empty    ${heartbeatresponse_501}
    Should Contain X Times    ${heartbeatresponse_501}    ${cbsd_id}    3
    FOR    ${grant}    IN    @{active_grant_list}
        Should Contain X Times    ${heartbeatresponse_501}    ${grant}    1
    END
    Should Contain X Times    ${heartbeatresponse_501}    "responseCode": 501    3
    Log To Console    RC:501 found 3 times in in first HB response!
    Should Contain X Times    ${heartbeatresponse_501}    "operationParam": {"maxEirp": 20    3
    Log To Console    HB response contains 3 operationParam with decreased maxEirp (20dBm)!

    Log To Console    Step 3. Check if relinquishment was performed and new grantRequest with maxEirp 20dBm was sent
    ${relinquishmentRequest}=    Run    grep -n '"relinquishmentRequest"' ${sas_log_feve77} | tail -n1
    Should Not Be Empty    ${relinquishmentRequest}
    Should Contain X Times    ${relinquishmentRequest}    ${cbsd_id}    3
    FOR    ${grant}    IN    @{active_grant_list}
        Should Contain X Times    ${relinquishmentRequest}    ${grant}    1
    END
    Log To Console    Relinquishment was performed after RC:501 found in first HB response!

    ${grantRequest_after_relinquishment}=    Run
    ...    awk '/relinquishmentRequest/ {found=1} found && /grantRequest/ {print; exit}' ${sas_log_feve77}
    Should Not Be Empty    ${grantRequest_after_relinquishment}
    Should Contain X Times    ${grantRequest_after_relinquishment}    ${cbsd_id}    3
    Should Contain X Times    ${grantRequest_after_relinquishment}    "operationParam":{"maxEirp":20.0    3
    Log To Console    New grantRequest with maxEirp=20dBm sent for 3 cells!

    [Teardown]    Run Keywords
    ...    Get SAS Logs To Logs Dir    alias=default    AND
    ...    Stop Watchdog Alarm Detection And Check For Failures    AND
    ...    Wait Until BTS Is Not Busy    alias=${alias}    AND
    ...    Perform Commissioning      bts_id=${testlines.${testline_id}.enb_id}
    ...    scf_file=${SUITE_LOGS_DIR_PATH}/RAT_1ST_SCFC_Before_Suite.xml
    ...    connection=RAT_1ST    AND
    ...    Kill All SAS Processes
