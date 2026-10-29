*** Settings ***
Documentation    Netact Connection Keywords & Variables.

Resource        ../admin/admin.robot
Library         netact_operations.py
Library         DateTime
Library         String
Library         OperatingSystem

*** Variables ***
${NETACT_USERNAME}=         wsuser
${NETACT_PASSWORD}=         A0zY~rP#8Mx@

*** Keywords ***
Connect to NetAct
    [Arguments]     ${ip_address}=${MPLANE_IPV4}
    ...             ${username}=${NETACT_USERNAME}
    ...             ${password}=${NETACT_PASSWORD}
    ${date}=                DateTime.Get Current Date
    ${random_string}=       Generate Random String    length=4    chars=[LETTERS]
    ${netact_logs_path}=    Set Variable    ${OUTPUT_DIR}/netact_debug_logs/
    Run  mkdir -p ${netact_logs_path}

    ${connection}=  Connect using netact
    ...             ${ip_address}
    ...             debug=${True}
    ...             debug_log_path=${netact_logs_path}/netact_debug_log_${date[11:19]}_${random_string}.txt
    ...             netact_server_address=${VM_IP}
    ...             username=${username}
    ...             password=${password}
    Log to console  Connection via NE3S created
    [Return]        ${connection}

Disconnect from NetAct
    [Arguments]     ${connection}
    Unregister and teardown   ${connection}

NetAct Setup
    Turn Off TLS
    ${netact_conn}       Connect to NetAct
    Set Test Variable    ${NETACT_CONNECTION}    ${netact_conn}

NetAct Teardown
    Run Keyword And Ignore Error       Disconnect from NetAct    ${NETACT_CONNECTION}
    Turn On TLS

Download SCF and create NetAct connection
    ${scf_filepath}=  Download SCF
    log to console  Downloaded SCF
    ${connection}=  Connect to Netact
    Set test variable  ${connection}
    Set test variable  ${scf_filepath}

Get RUEM logs from NetAct
    [Arguments]     ${connection}    ${MRBTS_ID}    ${path}
    Log to console    Collecting RUEM logs
    get_audit_trail_logs    ${connection}    ${MRBTS_ID}    ${path}

Initialize Certificates From NetAct
    [Arguments]                     ${connection}
    ...                             ${server_type}=RSA
    ...                             ${dist_name}=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
    ...                             ${timeout}=400
    ...                             ${retry}=5

    ${release}                      Get Software Release Name
    ${server_type}                  Set Variable If  '${release}'=='SBTS22R2'    ${NONE}   ${server_type}

    Log                             Initializing certificates from NetAct...
    ...                             console=${TRUE}
    Wait Until Keyword Succeeds     ${retry}x      10 sec
    ...                             netact_operations.Initialize Certificate
    ...                             na_instance=${connection}
    ...                             server_type=${server_type}
    ...                             dist_name=${dist_name}
    ...                             timeout=${timeout}

Delete Certificate With NetAct
    [Arguments]                      ${connection}
    ...                              ${fingerprint}
    ...                              ${dist_name}=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
    ...                              ${timeout}=400

    Log                              Deleting certificate with NetAct...
    ...                              console=${TRUE}
    Delete Certificate Using NetAct  na_instance=${connection}
    ...                              cert_dist_name=${dist_name}
    ...                              cert_fingerprint=${fingerprint}
    ...                              timeout=${timeout}

Update CMP Key With NetAct
    [Arguments]                      ${connection}
    ...                              ${server_type}=RSA
    ...                              ${dist_name}=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
    ...                              ${timeout}=400

    Log                              Updating CMP Key with NetAct...
    ...                              console=${TRUE}
    Wait Until Keyword Succeeds      5x     10 sec
    ...                              Update CMP Key Using NetAct
    ...                              na_instance=${connection}
    ...                              server_type=${server_type}
    ...                              dist_name=${dist_name}
    ...                              timeout=${timeout}

Install Certificate With NetAct
    [Arguments]                      ${connection}
    ...                              ${path_to_cert}
    ...                              ${dist_name}=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
    ...                              ${timeout}=400

    Log                              Installing certificate with NetAct...
    ...                              console=${TRUE}
    Wait Until Keyword Succeeds      5x     10 sec
    ...                              Install Certificate Using NetAct
    ...                              na_instance=${connection}
    ...                              cert_dist_name=${dist_name}
    ...                              path_to_cert=${path_to_cert}
    ...                              timeout=${timeout}

Configure CMP Server With NetAct
    [Arguments]                         ${connection}
    ...                                 ${psk}
    ...                                 ${ref_number}
    ...                                 ${server_type}=RSA
    ...                                 ${dist_name}=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
    ...                                 ${timeout}=400
    Log    Configuring CMP with NetAct (PSK: ${psk}, Reference number: ${ref_number})...  console=${TRUE}
    Wait Until Keyword Succeeds         5x      10 sec
    ...                                 Configure CMP Server Using NetAct
    ...                                 na_instance=${connection}
    ...                                 dist_name=${dist_name}
    ...                                 psk=${psk}
    ...                                 ref_number=${ref_number}
    ...                                 server_type=${server_type}
    ...                                 timeout=${timeout}
