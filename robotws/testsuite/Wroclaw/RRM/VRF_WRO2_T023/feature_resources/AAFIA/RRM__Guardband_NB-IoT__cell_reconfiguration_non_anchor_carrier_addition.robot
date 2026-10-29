*** Settings ***
Documentation
...   contact: Oleksandr Kulieshov

Library       SSHLibrary
Library       ute_ue
Library       taf.analyzer.pmcounter
Library       taf.collectors.core
Library       taf.sbts.oam.coam.admin    WITH NAME    admin
Resource      ../../resources/ca_INTER_RAT.robot
Resource      ../../resources/ca_IWK.robot


*** Variables ***
${NB_IOT_CELL_ID}                                              # ID of NB-IoT cell which will be tested.
${LTE_CELL_ID}                                                 # ID of LTE DSS cell which will be tested.
${UE_SERIAL_PORT}      ${EMPTY}                                # Serial port i.e. 21 (without "COM")
${AT_SCRIPT_PATH}      ${EMPTY}                                # Direct path to AT script on the UE PC.
${EXPECTED_M8204C0}                                            # Expected value of M8204C0 counter.
${M8204C3_MIN_VALUE}                                           # Minimum value of M8204C3 counter .
${M8204C6_MIN_VALUE}                                           # Minimum value of M8204C6 counter.
${EXPECTED_M8204C7}                                            # Expected value of M8204C7 counter.

*** Keywords ***
TC__RRM__Guardband_NB-IoT__cell_reconfiguration_non_anchor_carrier_addition

    Set Tags    CA-INTER_RAT    AUTHOR-oleksandr.kulieshov@nokia.com    OWNER-piotr.smolak@nokia.com
    ...         MAINTAINER-oleksandr.kulieshov@nokia.com    PHASE-CRT   SW-SBTS23R1    FEATURE-LTE4852_LTE4529
    ...         GROUP_IN_CHARGE-Pz_2_WRO_3


    Preconditions
    Step 1: Activate Additional Non-Anchor Carriers
    Step 2: Start Data Transfer In NB-IoT cell
    Step 3: Collect And Compare Counters Values

Preconditions
    Log To Console  \n==== Preconditions ====
    Set Test Variable  ${ENB_PARAMETERS_CHANGED}  False
    ${BTS_ID}    Get BTS ID From ADMIN
    Set Test Variable  ${BTS_ID}
    Get Current SCF File  ${LOG_PATH}/misc_logs  SCF_eNB.xml  export_type=configuration
    ${scf_enb}   Parse XML  ${LOG_PATH}/misc_logs/SCF_eNB.xml
    Set Test Variable  ${SCF_ENB}  ${scf_enb}
    ${LNBTS_ID}    Get BTS ID From ADMIN
    Set Test Variable  ${LNBTS_ID}
    Should Not Be Empty  ${UE_SERIAL_PORT}  Please specify serial port.
    Should Not Be Empty  ${FTP_IOT}   Please specify FTP for IoT.
    Check If Non-Anchor Carriers Are Not Configured

Connect To UEPC And FTP
    SSHLibrary.Open Connection  ${PC_IOT['IP']}  alias=uepc
    SSHLibrary.Login  ${PC_IOT['username']}  ${PC_IOT['password']}
    SSHLibrary.Open Connection  ${FTP_IOT['IP']}  alias=ftp
    SSHLibrary.Login  ${FTP_IOT['username']}  ${FTP_IOT['password']}

Check If Non-Anchor Carriers Are Not Configured
    Check Element In SCF  ${SCF_ENB}  NBIOT_FDD  LNCEL-${LTE_CELL_ID}/
    ...  /p[@name='numDlNonAnchCarrierNB']  <p name="numDlNonAnchCarrierNB">0</p>
    Check Element In SCF  ${SCF_ENB}  NBIOT_FDD  LNCEL-${LTE_CELL_ID}/
    ...  /p[@name='numUlNonAnchCarrierNB']  <p name="numUlNonAnchCarrierNB">0</p>

Step 1: Activate Additional Non-Anchor Carriers
    Log To Console  ==== Step 1: Activate Additional Non-Anchor Carriers ====
    Activate/Deativate Additional Non-Anchor Carriers  Activate  3  3


Activate/Deativate Additional Non-Anchor Carriers
    [Arguments]  ${delta_name}  ${DlNonAnch}  ${UlNonAnch}
    Log To Console  ${delta_name} Additional Non-Anchor Carriers
    Create Delta  ${delta_name}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${LTE_CELL_ID}/NBIOT_FDD-0
    ...                               numDlNonAnchCarrierNB
    ...                               ${DlNonAnch}
    ...                               delta_id=${delta_name}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${LTE_CELL_ID}/NBIOT_FDD-0
    ...                               numUlNonAnchCarrierNB
    ...                               ${UlNonAnch}
    ...                               delta_id=${delta_name}
    ${delta}  Get Delta  delta_id=${delta_name}
    Perform Delta Recommissioning  ${delta}
    Set Test Variable  ${ENB_PARAMETERS_CHANGED}  True
    Run Keywords  Log To Console  Checking BTS states and alarms...
    ...  AND  Wait Until Keyword Succeeds  2m  20s  _verify bts states for iwk test helper
    ...  AND  Log To Console  BTS states verification successful. All modules and cells are OnAir, no unexpected alarms appeared.
    Log To Console  Non-Anchor carriers have been successfully ${delta_name}


Step 2: Start Data Transfer In NB-IoT cell
    Log To Console  ==== Step 2: Start Data Transfer In NB-IoT cell ====
    ${waiting_time} =  Count Measurement Period  ${ENB_OAM_IP}  15    delta=-120
    Log To Console  Wait ${waiting_time}s till new period of counters is started
    Sleep  ${waiting_time}s  reason=Wait till new period of counter is started.
    Connect To UEPC And FTP
    Wait Until Keyword Succeeds  3x  5s  Prepare UE For Call
    Start command   iperf -c ${UEIP} -u -b 100K -p 6029 -i 1 -l 1400 -t 2700
    Sleep    120s

Prepare UE For Call
    Log To Console   \nPrepare UE for call...
    ${response}   Wait Until Keyword Succeeds  3x  5s  Run AT Command And Check If Response Is Not Empty  at+cfun=4
    ${response}   Wait Until Keyword Succeeds  3x  5s  Run AT Command And Check If Response Is Not Empty  at+cfun=1
    Sleep  10s  Reason=Wait for UE attach

    Log To Console  Ensure that UE is attached to appropriate NB-IoT cell...
    ${response}   Wait Until Keyword Succeeds  3x  5s  Run AT Command And Check If Response Is Not Empty  AT+CEREG?
    ${verdict}  ${msg}=  Run Keyword And Ignore Error  Should Match Regexp  ${response}  ${NB_IOT_CELL_ID}
    Run Keyword If  '${verdict}'=='PASS'  Log To Console  \nUE attached to ${NB_IOT_CELL_ID}
	...  ELSE  '${verdict}'=='FAIL'  Fail  \nUE is not attached to correct cell, test set to failed.

    Log To Console  \nFetch UE IP Address...
    ${response}   Wait Until Keyword Succeeds  3x  5s  Run AT Command And Check If Response Is Not Empty  AT+CGDCONT?
    ${ip}  Should Match Regexp  ${response}  \\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}  Invalid IP address.
    Set Test Variable  ${UEIP}  ${ip}


Run AT Command And Check If Response Is Not Empty
    [Arguments]  ${at_command}
    ${response} =  AT serial write  ${at_command}
    ${response_length} =  Get Length  ${response}
    Should Be True  ${response_length} > 0  msg=Response is empty for command ${at_command}.
    [Teardown]  Run Keyword If  '${KEYWORD_STATUS}' == 'FAIL'  AT serial write  AT+CFUN=1,1
    [Return]  ${response}

Step 3: Collect And Compare Counters Values
    Log To Console  ==== Step 3: Collect And Compare Counters Values   ====
    ${waiting_time} =  Count Measurement Period  ${ENB_OAM_IP}  15    delta=120
    Log To Console  Wait ${waiting_time}s till new period of counters is started
    Sleep  ${waiting_time}s  reason=Wait till new period of counter is started.
    Wait Until Keyword Succeeds  5x  10s  Collect PM Counters  ${LOG_PATH}/pm_counters  time_interval=30 min  intervals=15
    ${counter_list}   Create List  M8204C0  M8204C3  M8204C6  M8204C7
    ${counters_dict}  Get Values Of Counters From List  ${LOG_PATH}/pm_counters  ${counter_list}
    ...               MRBTS-${LNBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-201/PLMN-PLMN/MCC-001/MNC-01  1

    FOR  ${counter}  IN  @{counter_list}
         ${counters_values}  Get From Dictionary  ${counters_dict}  ${counter}
         ${value_from_list}   Get From List  ${counters_values}  0
         Run Keyword If  '${counter}' == 'M8204C0'  Should Be Equal  ${value_from_list}  ${EXPECTED_M8204C0}
         ...                                        msg=The values of counter M8204C0 is other than ${EXPECTED_M8204C0}
         Run Keyword If  '${counter}' == 'M8204C3'  Should Be True  ${value_from_list} > ${M8204C3_MIN_VALUE}
         ...                                        msg=The values of counter M8204C3 isn't greater than ${M8204C3_MIN_VALUE}
         Run Keyword If  '${counter}' == 'M8204C6'  Should Be True  ${value_from_list} > ${M8204C6_MIN_VALUE}
         ...                                        msg=The values of counter M8204C3 isn't greater than ${M8204C6_MIN_VALUE}
         Run Keyword If  '${counter}' == 'M8204C7'  Should Be Equal  ${value_from_list}  ${EXPECTED_M8204C7}
    END


TC Setup
    IWK Test Setup   single_bts=True


TC Teardown
    [Timeout]  30 min
    Log  \n === TC Teardown ===   console=True
    SSHLibrary.Open Connection  ${PC_IOT['IP']}  alias=uepc
    SSHLibrary.Login  ${PC_IOT['username']}  ${PC_IOT['password']}
    ${response}   Wait Until Keyword Succeeds  3x  5s  Run AT Command And Check If Response Is Not Empty  at+cfun=4
    Run Keyword If  ${ENB_PARAMETERS_CHANGED}  Activate/Deativate Additional Non-Anchor Carriers  Deactivate  0  0
    SSHLibrary.Close All Connections
    IWK Test Teardown  single_bts=True
