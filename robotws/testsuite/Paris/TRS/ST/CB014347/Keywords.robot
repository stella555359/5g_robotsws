*** Settings ***
Documentation
...                 author: David Jollivet
...                 contact: david.jollivet@nokia.com
...                 CB012184: Deep Sleep Mode Support for RF6.1 TDD RRH

Resource            CommonKeywords.robot

*** Variables ***
${cmd_token}    curl https://10.14.48.26/ext/api/auth/v1/login -k -X POST -H "Accept: application/json" -H "Content-Type: application/json"
...    -H "Authorization: Basic TmVtdWFkbWluOm5lbXV1c2Vy" -d '{ "readOnlyMode": false }' -i -w "\nHTTP Status: '%'{http_code}\n"

${cmd_start_cell}   curl https://10.14.48.26/ext/api/sm/v1/cells -k -X GET -H "Accept: application/json" -H "Content-Type: application/json"
...    -H "Authorization: Bearer

${cmd_end}     " -d '{ "readOnlyMode": false }' -i -w "\nHTTP Status: '%'{http_code}\n"

*** Keywords ***
CB014347 Setup
    Log To Console    CB012184 setup
    # BTS is OnAir
    # Run Keyword And Continue on failure    COAM Get Bts status enabled    ${bts_addr}

Test Setup
    Log To Console    Test setup
    # BTS is OnAir
    # Run Keyword And Continue on failure    COAM Get Bts status enabled    ${bts_addr}

    # Start the logs
    # Start All Logs

Test Teardown
    Log To Console    Test teardown
    # Save the logs and get Snapshot
    # Get All Logs

    # BTS is OnAir
    # Run Keyword And Continue on failure    COAM Get Bts status enabled    ${bts_addr}


# [1]Rest Example

Rest Debug

    # Authenticate and get token
    ${output_token}    Run    ${cmd_token}
    ${out}    Fetch From Right    ${output_token}    token":"
    ${token}    Fetch From Left    ${out}    ","type

    # Concatenate command with token
    ${cmd_getcells}    Set Variable    ${cmd_start_cell} ${token}${cmd_end}
    ${output_cells}    Run    ${cmd_getcells}

    Log To Console  ${output_cells}
