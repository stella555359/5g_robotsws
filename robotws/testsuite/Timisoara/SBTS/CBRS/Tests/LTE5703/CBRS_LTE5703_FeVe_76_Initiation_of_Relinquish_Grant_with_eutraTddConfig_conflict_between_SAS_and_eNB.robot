*** Settings ***
Documentation
...    = Author =
...    justyna.durak@nokia.com
...    = Maintainer =
...    justyna.durak@nokia.com
...    = Reviewer =
...    aleksandra.chudzik@nokia.com
...    katarzyna.olszewska@nokia.com
...    lukasz.lechowicz@nokia.com
...    piotr.lukaszewicz@nokia.com

*** Keywords ***
CBRS_LTE5703_FeVe_76_Initiation_of_Relinquish_Grant_with_eutraTddConfig_conflict_between_SAS_and_eNB
    [Documentation]    Requirements: OM_GEN_SFS_CBRS.298, OM_GEN_SFS_CBRS_367
    ...                This scenario verifies if eutraTddConfig is included in the response message, the eNB/CBSD checks the its
    ...                values of ulDlConfig equal to LNCEL_TDD::tddFrameConf, and ssfConfig equal to LNCEL_TDD::tddSpecSubfConf
    ...                Scenario also verifies CBSD reaction to different eutraTddConfig in SAS response and for authorized Grant.
    ...                eNB should report failure with specific reason and start Grant Relinquish and new Spectrum Inquiry procedure.
    ...                eutraTddConfig conflict between SAS and eNB is relized by specific SAS simulator configuration, which requires
    ...                SAS v2.0 and WINNF Technical Specification Version 2.0.

    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${alias}   Set Variable    RAT_1ST
    &{expected_alarm}   Create Dictionary    fault_id=6829    fault_name=SAS Heartbeat Failure    severity=Critical
    ...                                        reason=eutraTddConfig conflicts between CBSD and SAS(ulDlConfig:2;ssfConfig:7)
    ${expected_alarms_objects}   Create Watchdog Alarm List    ${expected_alarm}
    ${bts_side}   Set Variable    *

    Log To Console    Step 1.Preconditions
    Replace Variables In File    ${CURDIR}/Data/FeVe76/preconditions.json
    ...                          ${OUTPUT_DIR}/preconditions.json
    ...                          enb_id=${enb_id}
    Replace Variables In File    ${CURDIR}/Data/FeVe76/delta.json
    ...                          ${OUTPUT_DIR}/delta.json
    ...                          enb_id=${enb_id}
    Wait Until Keyword Succeeds    12x    10s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    Perform Delta Recommissioning    ${OUTPUT_DIR}/preconditions.json    connection=${alias}

    Log To Console    Step 2.Kill SAS if exists
    Kill All SAS Processes
    Check If Cells Are Disabled    enb_id=${enb_id}
    Disable CBRS Feature On eNB
    Start Watchdog Alarm Detection    expected_alarms=${expected_alarms_objects}

    Log To Console    Step 3. Start SAS
    ${sas_pid}    ${sas_log} =    Start SAS Process    config=${CURDIR}/Data/FeVe76/SAS_Sim.conf

    ${time_start}   Get Time
    Enable CBRS Feature On eNB
    Start Capturing Historical Alarms

    Log To Console    Step 4.Checking whether mandatory alarm occured
    ${cbsd_ids}   Get CBSD IDs    ${enb_id}    ${bts_side}    ${alias}
    Wait For Watchdog Alarm Activation    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                   severity=${expected_alarm}[severity]    reason=${expected_alarm}[reason]    timeout=120

    Wait Until Keyword Succeeds    12x    10s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    Perform Delta Recommissioning    ${OUTPUT_DIR}/delta.json    connection=${alias}

    Wait For Watchdog Alarm Deactivation    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                     severity=${expected_alarm}[severity]    reason=${expected_alarm}[reason]    timeout=180
    Wait For All Cells To Be OnAir
    Remove Fault From Watchdog Ignored List    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                        severity=${expected_alarm}[severity]    reason=${expected_alarm}[reason]

    ${time_stop}   Get Time

    Log To Console    Step 5.Checking whether relinquishments for all cells occured
    ${parsed_log_file}   Parse Sas Log File    log_file_name=${sas_log}
    ...                                          date_start=${time_start}
    ...                                          date_stop=${time_stop}

    ${grantId_list}   Extract Values From Sas Log    log_name=${parsed_log_file}
    ...                                                parameter=grantId
    ...                                                data_type=grantResponse
    ...                                                packet_amount=1
    Log To Console    Grant ID list: ${grantId_list}

    ${relinquished_grant_list}   Extract Values From Sas Log    log_name=${parsed_log_file}
    ...                                                           parameter=grantId
    ...                                                           data_type=relinquishmentRequest
    ...                                                           packet_amount=4
    Log To Console    Relinquished grant list: ${relinquished_grant_list}

    Sort List    ${grantId_list}
    Sort List    ${relinquished_grant_list}
    Should Be Equal    ${relinquished_grant_list}    ${grantId_list}

    Log To Console    Step 6.Checking whether new spectrum inquiry started
    ${secondSpectrumInquiryRequest}   Extract Values From Sas Log    log_name=${parsed_log_file}
    ...                                                          parameter=cbsdId
    ...                                                          data_type=spectrumInquiryRequest
    ...                                                          skip_packets=1
    Should Not Be Empty    ${secondSpectrumInquiryRequest}

    Log To Console    All good, time for teardown

    [Teardown]    Run Keywords
    ...    Get SAS Logs To Logs Dir    alias=default    AND
    ...    Check If CBSD Is Registered As TS2.0 Compliant    alias=${alias}    AND
    ...    Stop Watchdog Alarm Detection And Check For Failures    AND
    ...    Kill All SAS Processes    AND
    ...    Check If Cells Are Disabled    enb_id=${enb_id}
