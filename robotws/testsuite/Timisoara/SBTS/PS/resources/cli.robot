*** Settings ***
Library     ../../../resources/python_resources/admin_cli.py

Documentation
...  AUTHORS:       artur.juszczak@nokia.com, tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  Internal WRO1 resource library repetitive keywords in multiple tests.
...  ******************
...  History of changes
...  ******************
...  28.07.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-229 - add KW "Collect And Setup ADMIN CLI"
...  29.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-502 - add KW "Get Data From Received CLI Message"
...  xx.xx.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-xxx - xxx
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Variables ***
${cli_port}  443


*** Keywords ***
Collect And Setup ADMIN CLI
    [Documentation]  Collect and setup ADMIN CLI.

    Run  mkdir /home/ute/btsauto
    ${status}  Run Keyword And Return Status  Setup Admin CLI  ${active_sw_version}  ${ENB_MPLANE_IP}  port=${cli_port}
    IF  ${status}  Log  Admin CLI downloading finished  console=${true}


CLI Send Request And Return Status And Error Code
    [Documentation]  Send command via Admin CLI, and rerturn request status and error code.
    ...
    ...  | **Author:** artur.juszczak@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +-------------------------------+------+---------------------------------------------------------------------+
    ...  | Parameter                     | Man. | Description                                                         |
    ...  +===============================+======+=====================================================================+
    ...  | cli_message                   | Yes  | Admin CLI Command                                                   |
    ...  | output_file                   | No   | File path to redirect response to                                   |
    ...  | return_value                  | No   | Return only value of given key                                      |
    ...  | input_file                    | No   | File path with input data                                           |
    ...  +-------------------------------+------+---------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block: robotframework
    ...
    ...  CLI Send Request And Return Status And Error Code  {"requestId":1,"parameters":{"name":"unblock","parameters":{"waitForReconnection":true}}}
    ...
    [Arguments]   ${cli_message}  ${output_file}=${None}  ${return_value}=${None}  ${input_file}=${None}

    Log  Sending command via Admin CLI ...  console=${True}
    ${response}  Send Admin CLI request  ${cli_message}  output_file=${output_file}  return_value=${return_value}  input_file=${input_file}
    ${requestStatus}  Get from Dictionary  ${response}  requestStatus
    ${errorCode}  Get From Dictionary  ${response}  errorCode

    RETURN  ${requestStatus}  ${errorCode}
