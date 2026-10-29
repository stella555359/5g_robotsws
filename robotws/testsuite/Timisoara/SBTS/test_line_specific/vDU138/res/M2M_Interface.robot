*** Keywords ***
Run M2M Command
    [Documentation]  This keyword runs command with M2M Interface.
    ...  Mandatory arguments are:
    ...  ${request_type} - Specific type for request (e.g. POST, GET, DELETE, etc)
    ...  ${url} - The entire url (e.g. https://xx.x.xx.xx/api/licensed/v1/counters/rawDataFiles)
    ...  ${auth_type} - Specific type for authentication (e.g. Basic, Bearer)
    ...  ${auth_token} - Specific token for authentication (e.g sahdvfaASDFFBSDKA283AFVASFVAdkdfvcndv)
    ...  @{optional} - List with other parameters (e.g. --output All_PM_Data.zip, --version)
    ...  After the command is run, KW returns the output.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    ...  *MAINTAINER*: andreea.burtic@nokia.com
    [Arguments]  ${request_type}  ${url}  ${auth_type}  ${auth_token}  @{optional}

    ${optional_value}  Run Keyword If  ${optional}
    ...  Catenate  SEPARATOR=${SPACE}  @{optional}
    ...  ELSE
    ...  Set Variable  ${EMPTY}
    ${command}  Catenate  SEPARATOR=  curl -k -X ${request_type} ${url} -H "Accept: application/json" -H "Content-Type: application/
    ...  json" -H "Authorization: ${auth_type} ${auth_token}" ${optional_value}
    ${output}  Run  ${command}

    [Return]  ${output}


Login Using M2M Interface
    [Documentation]  This keyword is used for login in M2M Interface.
    ...  ${oam_ip} is mandatory and it's vDCU/vCU OAM IP.
    ...  This KW generates the specific token for commands to run.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    ...  *MAINTAINER*: andreea.burtic@nokia.com
    [Arguments]  ${oam_ip}

    Log  Login using M2M Interface!  console=true
    ${login_output}  Run M2M Command  POST  https://${oam_ip}:443/api/licensed/sec/v1/login  Basic  TmVtdWFkbWluOk5va2lhQDEyMw==
    ${string}  Fetch From Right  ${login_output}  "Token": "
    ${token}  Fetch From Left  ${string}  ",
    #${token_v} == ${token}
    Log to console    tokenul are valorarea ${token}
    #Log to console    token_v are valorarea ${token_v}
    Set Global Variable  ${TOKEN}
    Log to console    tokenul are valorarea ${token}
    Log  The token was generated and login was successfully completed!  console=true


Logout Using M2M Interface
    [Documentation]  This keyword is used for logout in M2M Interface.
    ...  ${oam_ip} is mandatory and it's vDCU/vCU OAM IP.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    ...  *MAINTAINER*: andreea.burtic@nokia.com
    [Arguments]  ${oam_ip}

    Log  Logout using M2M Interface!  console=true
    Run M2M Command  POST  https://${oam_ip}:443/api/licensed/sec/v1/logout  Bearer  ${TOKEN}


Get Operation Id Value
    [Documentation]  This keyword is used to get operation id value
    [Arguments]  ${request_output}

    ${operation_id}  Should Match Regexp  ${request_output}  "id":".*"
    ${operation_id}  Fetch From Right  ${operation_id}  "id":"
    ${operation_id}  Fetch From Left  ${operation_id}  ",

    [Return]  ${operation_id}


Remove M2M Output Noise
    [Documentation]  This keyword is used in order to remove unnecessary output that is generated when using
    ...  a M2M interface command, unlike in the case of manually running the same command. This is done using
    ...  regular expressions.
    ...  Arguments are:
    ...  ${output} - represents the output obtained from a Run M2M command keyword
    ...  *AUTHOR*: victor.banicioiu@nokia.com
    ...  *MAINTAINER*: victor.banicioiu@nokia.com
    [Arguments]  ${output}

    ${output}  Remove String Using Regexp  ${output}  ( )*%([A-Z]*[a-z]* *%*(\\n)*)+
    ${output}  Remove String Using Regexp  ${output}  (\\n)*([0-9]+[a-z]*${SPACE}+)+(((-)*(:)*(${SPACE})*)+()+([0-9?k]+)(\\n)*)*

    [Return]  ${output}


Get Operation Id Value - Longer Version
    [Documentation]  This keyword is used to get operation id value
    [Arguments]  ${request_output}

    ${operation_id}  Should Match Regexp  ${request_output}  "operationId":".*"
    ${operation_id}  Fetch From Right  ${operation_id}  "operationId":"
    ${operation_id}  Fetch From Left  ${operation_id}  ",

    [Return]  ${operation_id}
