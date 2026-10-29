*** Settings ***
Documentation
...             Common keywords
...             Authors: Michal Wlosek, michal.wlosek@nokia.com
...                      Mariusz Wojcik, mariusz.wojcik@nokia.com

Library   ./scout_operations.py
Library   OperatingSystem
Library   Collections
Resource  ../../common_resources/vm/vm_operations.robot

*** Keywords ***
Request SCF From Scout And Generate Configuration ID
    [Arguments]    ${vm_address}=192.168.255.126
    ${hostname}=          vm_operations.Get VM Hostname    ${vm_address}
    ${process_status}=    Run                              ps -ef | grep CM_EXECUTION_ID
    ${is_ute_run}=        Run Keyword And Return Status    Should Match Regexp    ${process_status}    CM_RESERVATION_ID
    ${scout_scf_id}=      Run Keyword If  ${is_ute_run}    Request SCF From Scout Until Available      ${hostname}
    ...                                                                                                ${False}
    ...                   ELSE                             Request SCF From Scout Until Available      ${hostname}
    ...                                                                                                ${True}
    [Return]              ${scout_scf_id}

Request SCF From Scout Until Available
    [Arguments]    ${hostname}    ${use_internal_id}
    FOR  ${request}  IN RANGE  10
        ${request_status}=    Run Keyword And Ignore Error    request_scf_from_scout    ${hostname}
        ...                                                                             ${use_internal_id}
        ${status}=            Get From List                   ${request_status}         0
        ${scf_id}=            Get From List                   ${request_status}         1
        Exit For Loop If      '${status}' == 'PASS'
    END
    [Return]    ${scf_id}
