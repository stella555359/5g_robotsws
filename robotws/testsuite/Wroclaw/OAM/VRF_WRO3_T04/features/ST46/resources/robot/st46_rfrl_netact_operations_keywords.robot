*** Settings ***
Documentation    Netact Connection Keywords & Variables.

Resource        ./st46_rfrl_tls_common_keywords.robot
Library         ../python/st46_rfrl_netact_operations.py
Library         ../python/st46_rfrl_audit_trail_logs.py  WITH NAME  atl
Library         DateTime
Library         String
Library         OperatingSystem

*** Variables ***
${NETACT_USERNAME}=         sbtsoam
${NETACT_PASSWORD}=         A0zY~rP#8Mx@

*** Keywords ***
Connect to NetAct
    [Arguments]     ${ip_address}=${MPLANE_IPV4}
    ...             ${username}=${NETACT_USERNAME}
    ...             ${password}=${NETACT_PASSWORD}
    ${date}=                DateTime.Get Current Date
    ${random_string}=       String.Generate Random String    length=4    chars=[LETTERS]
    ${netact_logs_path}=    Set Variable    ${OUTPUT_DIR}/netact_debug_logs/
    Run  mkdir -p ${netact_logs_path}

    ${connection}=  Connect using netact
    ...             ${ip_address}
    ...             debug=${True}
    ...             debug_log_path=${netact_logs_path}/netact_debug_log_${date[11:19]}_${random_string}.txt
    ...             netact_server_address=${VM_IP}
    ...             username=${username}
    ...             password=${password}
    Log     Connection via NE3S created     console=${TRUE}
    [Return]        ${connection}

Disconnect from NetAct
    [Arguments]     ${connection}
    Unregister and teardown   ${connection}

NetAct Setup
    Set MPLANENW Parameter    oamTls    off
    ${netact_conn}            Connect to NetAct
    Set Test Variable         ${NETACT_CONNECTION}    ${netact_conn}

NetAct Teardown
    Run Keyword And Ignore Error       Disconnect from NetAct    ${NETACT_CONNECTION}
    Set MPLANENW Parameter             oamTls                    forced

Get RUEM logs from NetAct
    [Arguments]     ${connection}    ${MRBTS_ID}    ${path}
    Log    Collecting RUEM logs     console=${TRUE}
    st46_rfrl_netact_operations.Get Audit Trail Logs    ${connection}    ${MRBTS_ID}    ${path}

Get Cleaned ATL Logs from NetAct
    [Arguments]     ${atl_path}  ${logs_age_in_s}=300
    ...             ${output_file}=filtered_cleaned_logs.txt  ${enable_filtering}=${FALSE}
    ${netact_connection}=  Connect to NetAct
    st46_rfrl_netact_operations.Get Audit Trail Logs     ${netact_connection}
    ...                                             adaptation_version=MRBTS-${BTS_ID}
    ...                                             path=${atl_path}
    ${atl_logs}=  atl.Recreate Trail Logs With Filtering     trail_log_file=${atl_path}
    ...                                                                             output_file=${output_file}
    Run Keyword If  ${enable_filtering} == ${TRUE}  ${atl_logs}=  filter_trail_logs_for_date  trail_log_file=${atl_logs}
    ...                                                                                       logs_age_in_s=${logs_age_in_s}
    ...                                                                                       output=${output_file}
    [Return]        ${atl_logs}
    [Teardown]      Disconnect from NetAct  ${netact_connection}
