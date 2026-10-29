*** Settings ***
Documentation
...    = Author =
...    Karol.Sadowski@nokia.com
...    = Maintainer =
...    Karol.Sadowski@nokia.com
...    = Reviewer =
...    Lukasz.Lechowicz@nokia.com
...    Piotr.Lukaszewicz@nokia.com
...    Elzbieta.Wlodarczyk@nokia.com
...    Aleksandra.Chudzik@nokia.com
...    Review link: https://l3-sim-krk-serv.dynamic.nsn-net.net/r/1501/

*** Keywords ***
CBRS_CB008735_FeVe_14_ET_cbsdFrequencyGuidance_cleared_since_WF_ENH_GROUP_HANDLING_feature_not_supported
    [Documentation]  Requirement: OAM_REQ_CBRS_134
    ...              Purpose: This test scenario verifies if prievously set frequency guidance will be cleared
    ...                       after not supporting WF_ENH_GROUP_HANDLING feature by SAS.
    ...              Precondition: set chBw=10, desiredChBw=20, maxGrantChBwRed=10
    ...              Step 1: Registration, Pre-TX measurement, grant for given frequency guidance
    ...                      expected 2 cell reconfiguration for 20MHz bw (2x 20MHz = 40MHz band)
    ...              Step 2: SpectrumInquiry called after registration and HB procedure
    ...              Step 3: New grant allocation despite of previous frequency guidance
    ...                      expected rest 2 cell reconfiguration (4x 20MH = 80MHz band)
    ...              Step 4: Check if all cells go onAir

    &{expected_alarms}   Create Dictionary    fault_name=SAS Grant Failure
    ${expected_alarms_object}   Create Watchdog Alarm List     ${expected_alarms}
    ${bts_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${alias}   Set Variable    RAT_1ST

    Log To Console    ${\n}Step 1: Setting preconditions...
    Kill All SAS Processes
    Disable CBRS Feature On eNB
    Enable CBRS Feature On eNB
    Replace Variables In File    ${CURDIR}/Data/FeVe_14/precondition.json
    ...                          ${OUTPUT_DIR}/FeVe_14_precondition.json
    ...                          enb_id=${bts_id}
    Replace Variables In File    ${CURDIR}/Data/FeVe_14/postcondition.json
    ...                          ${OUTPUT_DIR}/FeVe_14_postcondition.json
    ...                          enb_id=${bts_id}
    Wait Until Keyword Succeeds    5x    10s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    Perform Delta Recommissioning    ${OUTPUT_DIR}/FeVe_14_precondition.json    connection=${alias}

    Log To Console    Step 2: Starting SAS simulator...
    ${sas_pid}    ${sas_logs_dir}   Start SAS Process    config=${CURDIR}/Data/FeVe_14/SAS_Sim.conf
    ${log_start_time}   Get Time
    Wait Until Keyword Succeeds    5x    10s    Required CBSD Status Should Be Reached
    ...    expected_status=Registered    enb_id=${bts_id}

    Start Watchdog Alarm Detection    expected_alarms=${expected_alarms_object}
    Wait For All Cells To Be OnAir    wait_time=10min

    @{lncel_param_list}  ute_admin_infomodel.Query Infomodel    alias=RAT_1ST
    ...    query=get list /MRBTS-*/RAT-*/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-${bts_id}/LNBTS_A-${bts_id}/LNCEL_A-*/LNCEL_TDD_A-0
    ${cell_num}  Get Length    ${lncel_param_list}
    FOR    ${i}   IN RANGE    ${cell_num}
        Should Be Equal    ${lncel_param_list[${i}]['chBw']}    20 MHz
        ...    msg=It is expected that cell ${lncel_param_list[${i}]['dist_name']} supposed to be 20MHz
    END

    ${log_end_time}   Get Time

    Log To Console    Step 3: Logs evaluation...
    Wait Until Keyword Succeeds    5x    10s    Check If TS Version Is As Expected    ${bts_id}    ${alias}    2.0
    ${parsed_log_file}   Parse Sas Log File    log_file_name=${sas_logs_dir}
    ...                                          date_start=${log_start_time}
    ...                                          date_stop=${log_end_time}

    ${parsed_SAS_communication}   Communication CBSD SAS    SAS_Sim_log_file=${sas_logs_dir}
    ${count_spectrumInquiry_request}    Get Match Count    ${parsed_SAS_communication}     *spectrumInquiryRequest
    Should Be Equal As Integers    ${count_spectrumInquiry_request}    3    msg=Wrong number of spectrumInquiryRequest visible in SAS_Sim.log
    ${count_featureCapabilityExchange_request}    Get Match Count    ${parsed_SAS_communication}     *featureCapabilityExchangeRequest
    Should Be Equal As Integers    ${count_featureCapabilityExchange_request}    1
    ...    msg=Wrong number of featureCapabilityExchangeRequest visible in SAS_Sim.log

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Disable CBRS Feature On eNB    AND
    ...                           Wait Until Keyword Succeeds    10x    10s   Run Keywords
    ...                                                                       Wait Until BTS Is Not Busy    AND
    ...                                                                       Perform Delta Recommissioning
    ...                                                                       ${OUTPUT_DIR}/FeVe_14_postcondition.json
    ...                                                                       connection=${alias}    AND
    ...                           Kill All SAS Processes    AND
    ...                           Check If Cells Are Disabled    enb_id=${bts_id}