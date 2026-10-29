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
CBRS_LTE5659-A_FeVe_09_Grant_Procedure_modification_grantResponse_with_code_402
    [Documentation]     This scenario verifies CBSD reaction for grantResposne with responseCode = 402.
    ...                 eNB should report failure and start new spectrum and grant negotiation
    ...                 Tested Requirement: OM_GEN_SFS_CBRS.297
    [Timeout]    30min

    Set Suite Variable      ${ims_alias}    RAT_1ST
    ${enb_id}             Set Variable    ${testlines.${testline_id}.enb_id}
    ${mandatory_alarms}   Create List     {'faultId': '6828', 'faultName': 'SAS Grant Failure', 'severity': 'Critical'}
    @{allowed_alarms}     Set Variable    ${enb_allowed_alarms}
    ${expected_alarms}    Create List     SAS Grant Failure


    Disable CBRS Feature On eNB
    Kill All SAS Processes

    Log    Step 1.Start SAS processes, set preconditions    console=true

    Replace Variables In File    ${CURDIR}/Data/FeVe_09/precondition_delta.json
    ...                          ${OUTPUT_DIR}/precondition_delta.json
    ...                          enb_id=${enb_id}
    Replace Variables In File    ${CURDIR}/Data/FeVe_09/postcondition_delta.json
    ...                          ${OUTPUT_DIR}/postcondition_delta.json
    ...                          enb_id=${enb_id}

    Wait Until BTS Is Not Busy
    ${AEQM_present}   Run Keyword And Return Status    Query Infomodel    timeout=30    alias=RAT_1ST
    ...                 query=check /MRBTS-*/RAT-*/BTS_L-*/EQM_L-*/RMOD_L-* is [productName=regex"(?i)AEQM"]

    Wait Until Keyword Succeeds    5x    30s    Perform Delta Recommissioning
    ...                             ${OUTPUT_DIR}/precondition_delta.json
    ...                             connection=RAT_1ST

    ${sas_config}   Set Variable If     ${AEQM_present}     SAS_Sim_AEQM.conf     SAS_Sim.conf

    ${sas_pid}    ${sas_log}   Start SAS Process    config=${CURDIR}/Data/FeVe_09/${sas_config}

    ${start_time}   Get Time

    Wait Until BTS Is Not Busy
    Enable CBRS Feature On eNB
    Start Capturing Historical Alarms

    Log    Step 2.Checking whether mandatory alarm occured
    Wait Until Keyword Succeeds     40x    5s    Admin Alarms Get And Check
    ...                                          mandatory=${mandatory_alarms}
    ...                                          allowed=${allowed_alarms}
    ...                                          alias=${ims_alias}

	Sleep and Display progress    50    s
    Wait For All Cells To Be OnAir
    ${cbsdid}   Get CBSDID From Infomodel
    ${end_time}   Get Time

    ${parsed_log_file}   Parse Sas Log File    log_file_name=${sas_log}
    ...                                          date_start=${start_time}
    ...                                          date_stop=${end_time}

    Log    Step 3.Checking whether grantResposne with 402 occured    console=True
    ${grantResponse_responseCode}   Extract Values From Sas Log    log_name=${parsed_log_file}
    ...                                                              parameter=responseCode
    ...                                                              data_type=grantResponse
    ...                                                              start_from=registrationRequest
    ...                                                              packet_amount=1
    Log     ${grantResponse_responseCode}
	${grantResponse_responseCode}   remove duplicates    ${grantResponse_responseCode}
	Should Contain X times  item1='${grantResponse_responseCode}'  item2=402  count=1

    ${grantResponse_responseMessage}   Extract Values From Sas Log    log_name=${parsed_log_file}
    ...                                                                 parameter=responseMessage
    ...                                                                 data_type=grantResponse
    ...                                                                 start_from=registrationRequest
    Log    ${grantResponse_responseMessage}
    ${grantResponse_responseMessage}   remove duplicates    ${grantResponse_responseMessage}
    Should Contain X times
    ...    item1='${grantResponse_responseMessage}'
    ...    item2='The frequency range requested is NOT completely inside the SAS assigned range for the CBSD, for the purpose of GAA Coexistence'
    ...    count=1

    Log    Step 4.Checking whether new spectrum inquiry and grant negotiation started    console=True
	${cbsdId_spectrumInquiryRequest}   Extract Values From Sas Log    log_name=${parsed_log_file}
    ...                                                                 parameter=cbsdId
    ...                                                                 data_type=spectrumInquiryRequest
    ...                                                                 skip_packets=1
    Log    ${cbsdId_spectrumInquiryRequest}
	Should Be Equal As Strings    ${cbsdId_spectrumInquiryRequest[0]}    ${cbsdid}

	${cbsdId_grantRequest}   Extract Values From Sas Log    log_name=${parsed_log_file}
	...                                                       parameter=cbsdId
	...                                                       data_type=grantRequest
	...                                                       skip_packets=1
    Log    ${cbsdId_grantRequest}
    Should Be Equal As Strings    ${cbsdId_grantRequest[0]}    ${cbsdid}

    Log    All good, time for teardown    console=true
    [Teardown]    Run Keywords
    ...    Get SAS Logs To Logs Dir    alias=default    AND
    ...    Wait Until BTS Is Not Busy    AND
    ...    Wait Until Keyword Succeeds    5x    30s    Perform Delta Recommissioning
           ...    ${OUTPUT_DIR}/postcondition_delta.json    connection=RAT_1ST    AND
    ...    Run Keyword And Continue On Failure    Save And Check Historical Alarms    expected_alarms=${expected_alarms}    AND
    ...    Kill All SAS Processes    AND
    ...    Check If Cells Are Disabled    enb_id=${enb_id}

