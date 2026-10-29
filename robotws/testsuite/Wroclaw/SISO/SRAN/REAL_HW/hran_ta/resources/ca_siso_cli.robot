*** Settings ***
Documentation
...  Resource for CLI

Library    Python/admin_cli.py  WITH NAME  admin_cli
Resource   ca_siso_general.robot

#*** Variables ***
#${ADMIN_CLI_KEY}  AKCp8pQH3kiEZTWFo45FwbG5KEcVjNmU99bucUfxV33JhaEGZ81wVMsj6oRdM48DLBJjfXrw5  # espoo 2

*** Keywords ***
Siso Check Admin CLI Feature Enabled
    [Documentation]  This keyword check if Admin CLI feature is enabled if no, this keyword enable this feature.
    ...  | Original KW -> Check If Admin CLI Feature Check Is Enabled
    ...  | Original resource -> ca_cli_resource.robot
    ...  | **Author:** artur.juszczak@nokia.com
    ...  | **Maintainer:** daniel.bartkowiak@nokia.com
    ...
    ...  | **Full description:**
    ...  | This keyword check if Admin CLI feature is enabled if no, this keyword enable this feature.
    ...  | Feature is enabled via set to true parameter actCli under FEATCADM.
    ...
    ...  **Input Parameters:**
    ...
    ...  +-------------------------------+------+---------------------------------------------------------------------+
    ...  | Parameter                     | Man. | Description                                                         |
    ...  +===============================+======+=====================================================================+
    ...  | skip_parameter_relation_errors| No   | This parameter allow or not to skip relation errors, default='False'|
    ...  +-------------------------------+------+---------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block: robotframework
    ...
    ...     Check If Admin CLI Feature Check Is Enabled  True
    ...
    [Arguments]  ${skip_parameter_relation_errors}=False
    admin.Get Current SCF File  ${Test Files}  current_scf.xml  connection=default
    ${actCli}=  SiSo Get Parameter Value From SCF  param_name=actCli  scf_path=${Test Files}/current_scf.xml
    Log  Parameter actCli is set as ${actCli[0]}  console=${True}
    Run Keyword If  '${actCli[0].lower()}'!='true'  Run Keywords
    ...  Log  Setting parameter actCli to "True"  console=${True}
    ...  AND  _Siso Change actCli To True  ${skip_parameter_relation_errors}

_Siso Change actCli To True
    [Documentation]
    ...  | Original KW -> _Change actCli To True
    ...  | Original resource -> ca_cli_resource.robot
    ...  | **Maintainer:** daniel.bartkowiak@nokia.com
    [Arguments]  ${skip_parameter_relation_errors}
    ${bts_id}=  Find BTS ID TAF
    admin.Perform Parameter Recommissioning  MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1  actCli  update   true
    ...  skip_parameter_relation_errors=${skip_parameter_relation_errors}  connection=default

Siso Verify Cli Response Error
    [Documentation]
    ...  | Original KW -> Verify Cli Response Error
    ...  | Original resource -> ca_BSSM_CLI_SFP_resources.robot
    ...  Check if output file is right json format and check response error
    ...
    ...  | **Author:** grzegorz.gulaj@nokia.com
    ...  | **Maintainer:** daniel.bartkowiak@nokia.com
    ...
    ...  | **Full description:**
    ...  | This keyword check if Admin CLI feature is right json format.
    ...  | and verify error codes in json response
    ...
    ...  | KW sets test variable  ${CLI_ERROR_CODE}
    ...
    ...  |  **Input Parameters:**
    ...
    ...    +------------------+--------+--------------------------------------------------+
    ...    | Input Parameters | Man.   | Description                                      |
    ...    +====================+========+================================================+
    ...    | cli_file_content | Yes    | string content of CLI file response              |
    ...    +------------------+--------+--------------------------------------------------+
    ...
    ...   **Example of simple usage:**
    ...
    ...      .. code-block:: robotframework
    ...        verify if output is right json format  ${cli_file_content}

    [Arguments]  ${cli_file_content}
    ${cli_file_content}=   Siso Last Root JSON Part  ${cli_file_content}
    &{cli_error_dict}=  Create Dictionary  1=Miscellaneous problems  2=Invalid operation  3=Invalid parameters  4=Site unreachable  5=Site reserved
    ...  6=Login failed  7=Unexpected error  8=Timeout  9=License not available  69=Operation Rejected  140=Failed to generate SFP information

    Should Not Be Empty  ${cli_file_content}  CLI SFP output file is empty

    ${json_content}=  Evaluate  json.loads("""${cli_file_content}""")  json
    ${error_num}=  Convert To String  ${json_content}[errorCode]
    SET TEST VARIABLE  ${CLI_ERROR_CODE}  ${json_content}[errorCode]
    run keyword if  ${json_content}[errorCode]!=0   Run Keywords  Dictionary Should Contain Key  ${cli_error_dict}  ${error_num}
    ...  CLI request fail with unknown error  AND  Fail  CLI request fail with error: &{cli_error_dict}[${error_num}]

Siso Last Root JSON Part
    [Documentation]
    ...  | Original KW -> Last Root JSON Part
    ...  | Original resource -> ca_BSSM_CLI_SFP_resources.robot
    ...  If JSON contine more then one root part return last part
    ...
    ...  | **Author:** grzegorz.gulaj@nokia.com
    ...  | **Maintainer:** daniel.bartkowiak@nokia.com
    ...
    ...  | **Full description:**
    ...  | This keyword check if Admin CLI feature is right json format.
    ...  | and verify error codes in json response
    ...
    ...  |  **Input Parameters:**
    ...
    ...    +------------------+--------+--------------------------------------------------+
    ...    | Input Parameters | Man.   | Description                                      |
    ...    +====================+========+================================================+
    ...    | cli_file_content | Yes    | string content of CLI file response              |
    ...    +------------------+--------+--------------------------------------------------+
    ...    Return last json root part
    ...   **Example of simple usage:**
    ...
    ...      .. code-block:: robotframework
    ...     ${cli_file_content}=   Last Root JSON Part  ${cli_file_content}

    [Arguments]  ${cli_file_content}
    Should Not Be Empty  ${cli_file_content}  CLI SFP output file is empty
    ${match}=  Get Regexp Matches  ${cli_file_content}  }\\n{
    ${number}=  Get Length  ${match}
    ${cli_response}=  Fetch From Right  ${cli_file_content}  }\n{
    ${cli_response_after corrction}=  Catenate  {  ${cli_response}
    Run Keyword If  ${number}>0   Set Test Variable  ${new}  ${cli_response_after corrction}
    Run Keyword If  ${number}==0  Set Test Variable  ${new}  ${cli_file_content}
    [Return]   ${new}

Siso Last Root JSON Part For Compact Output
    [Documentation]
    ...  | Original KW -> Last Root JSON Part For Compact Output
    ...  | Original resource -> ca_BSSM_CLI_SFP_resources.robot
    ...  If JSON contine more then one root part return last part
    ...
    ...  | **Author:** grzegorz.gulaj@nokia.com
    ...  | **Maintainer:** daniel.bartkowiak@nokia.com
    ...
    ...  | **Full description:**
    ...  | This keyword check if Admin CLI feature is right json format.
    ...  | and verify error codes in json response
    ...
    ...  |  **Input Parameters:**
    ...
    ...    +------------------+--------+--------------------------------------------------+
    ...    | Input Parameters | Man.   | Description                                      |
    ...    +====================+========+================================================+
    ...    | cli_file_content | Yes    | string content of CLI file response              |
    ...    +------------------+--------+--------------------------------------------------+
    ...    Return last json root part
    ...   **Example of simple usage:**
    ...
    ...      .. code-block:: robotframework
    ...     ${cli_file_content}=   Last Root JSON Part  ${cli_file_content}

    [Arguments]  ${cli_file_content}
    Should Not Be Empty  ${cli_file_content}  CLI SFP output file is empty
    ${match}=  Get Regexp Matches  ${cli_file_content}  }{
    ${number}=  Get Length  ${match}
    ${cli_response}=  Fetch From Right  ${cli_file_content}  }{
    ${cli_response_after corrction}=  Catenate  {  ${cli_response}
    Run Keyword If  ${number}>0   Set Test Variable  ${new}  ${cli_response_after corrction}
    Run Keyword If  ${number}==0  Set Test Variable  ${new}  ${cli_file_content}
    [Return]   ${new}


Send CLI Request And Return Response
    [Arguments]  ${request}
    [Documentation]
    ...  KW sends CLI request and returns requestMessage from response.
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    ${response}  admin_cli.Send Admin CLI request  ${request}
    ${requestStatus}  Get from Dictionary  ${response}  requestStatus
    ${errorCode}  Get From Dictionary  ${response}  errorCode
    Run Keyword If  '${requestStatus}'!='completed' or '${errorCode}'!='0'
    ...  Fail  Sending Admin CLI request failed with errorCode ${errorCode} and requestStatus: ${requestStatus}
    ...  ELSE
    ...  Log To Console  Admin CLI request sent correctly ! ${\n}

    ${response_message}  Get From Dictionary  ${response}  requestMessage

    [Return]  ${response_message}
