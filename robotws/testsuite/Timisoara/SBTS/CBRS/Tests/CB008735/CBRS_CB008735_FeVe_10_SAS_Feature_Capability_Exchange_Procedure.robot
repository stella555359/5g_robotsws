*** Settings ***
Documentation
...    = Author =
...    Lukasz.lechowicz@nokia.com
...    = Maintainer =
...    Lukasz.lechowicz@nokia.com
...    = Reviewer =
...    Karol.Sadowski@nokia.com
...    Piotr.Lukaszewicz@nokia.com
...    Elzbieta.Wlodarczyk@nokia.com
...    Aleksandra.Chudzik@nokia.com
...    Review link: http://l3-sim-krk-serv.dynamic.nsn-net.net/r/1249/

*** Keywords ***
CBRS_CB008735_FeVe_10_SAS_Feature_Capability_Exchange_Procedure
    [Documentation]  Requirement: OM_GEN_SFS_CBRS.377
    ...              Purpose: In this user scenario, a featureCapabilityExchange procedure is verified.
    ...                       It is triggered by the SAS.
    ...              Step 1: Check presence of featureCapabilityExchangeRequests after cells are activated


    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    Kill All SAS Processes

    ${time_start}   Get Time
    ${sas_pid}    ${sas_logs_dir}   Start SAS Process    config=${CURDIR}/Data/Feve10/SAS_Sim.conf

    Log To Console    Waiting For Cells Activation
    Wait For All Cells To Be OnAir
    # Wait for 2nd HB procedure
    Sleep    1min
    Start Watchdog Alarm Detection
    ${time_stop}   Get Time

    Log To Console    Checking presence of featureCapabilityExchangeRequests
    Verify Presence of featureDataExchange After Certain Procedure    start_from=spectrumInquiryResponse
    ...                                                               time_start=${time_start}
    ...                                                               time_stop=${time_stop}
    ...                                                               sas_log_path=${sas_logs_dir}
    Verify Presence of featureDataExchange After Certain Procedure    start_from=grantResponse
    ...                                                               time_start=${time_start}
    ...                                                               time_stop=${time_stop}
    ...                                                               sas_log_path=${sas_logs_dir}
    Verify Presence of featureDataExchange After Certain Procedure    start_from=heartbeatResponse
    ...                                                               time_start=${time_start}
    ...                                                               time_stop=${time_stop}
    ...                                                               sas_log_path=${sas_logs_dir}

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Kill All SAS Processes    AND
    ...                           Check If Cells Are Disabled    enb_id=${enb_id}

