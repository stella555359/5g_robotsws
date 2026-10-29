*** Settings ***
Documentation
...    Author: Yang mengli
...    Email address: mengli.yang@nokia-sbell.com
...    Maintainer: Yang mengli
...    Email address: mengli.yang@nokia-sbell.com
...    Common KWs related to PA.
...    All the bugs/new keyword needs/improvement should be raised in Jira and assign to the Maintainer.
...    Jira link: https://jiradc.ext.net.nokia.com/projects/PZ1HAZTA/issues
...    Guidelines for user: https://confluence.ext.net.nokia.com/display/SRANPRODHZHTA/04.+Module+of+PA+Operation
...    Examples: https://wrgitlab.int.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/Module/Module_Test

Resource          ./library/_PA_Operation.robot

*** Keywords ***
PA Operation
    [Arguments]    ${operation}=HO    ${source}=none    ${target}=none    ${product_type}=vdu    ${wait_sleep}=1s
    ...            ${bts_index}=${0}    ${du_index}=${0}    ${ru_index}=${0}    ${att_index}=${0}
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                The KW is related to PA operation.
    ...    | Input Parameters | Man. | Description |
    ...    | ${source} | No | This parameter defines PA information from the source cell |
    ...    | ${target} | No | This parameter defines PA information from the target cell |
    ...    | Return Value | Description |
    ...    | NA | No |
    ...    Example
    ...    | &{source}  Create Dictionary  product_type=cloud  att_index=0  pa_port=[1,2,3...]  pa_value=[0,50]  step=5 |
    ...    | &{target}  Create Dictionary  product_type=cloud  att_index=0  pa_port=[5,6,7...]  pa_value=[63,20]  step=5 |
    ...    | PA Operation | &{source} | &{target} |
    log    ${att_index} is not used.
    ${output}    Run Keyword If    "${operation}"=="HO" and "${source}"!="none" and "${target}"!="none"    Set PA Value For Source And Target Cell
    ...                                                                                           source=${source}
    ...                                                                                           target=${target}
    ...                                                                                           wait_sleep=${wait_sleep}
    ...    ELSE IF       "${operation}"=="HO" and "${source}"!="none" and "${target}"=="none"    Set PA Value For Source Cell Or Target Cell
    ...                                                                                          source=${source}
    ...                                                                                          target=${target}
    ...                                                                                          wait_sleep=${wait_sleep}
    ...    ELSE IF       "${operation}"=="HO" and "${source}"=="none" and "${target}"!="none"    Set PA Value For Source Cell Or Target Cell
    ...                                                                                          source=${source}
    ...                                                                                          target=${target}
    ...                                                                                          wait_sleep=${wait_sleep}
    ...    ELSE IF       "${operation}"=="Initialize PA Value"    Module Initialize PA Value    operation=Initialize PA Value
    ...                                                                                      source=${source}
    ...    ELSE IF       "${operation}"=="Get PA Port And Value"    Get Attenuation Port From Init File    product_type=${product_type}
    ...                                                                                                    bts_index=${bts_index}
    ...                                                                                                    du_index=${du_index}
    ...                                                                                                    ru_index=${ru_index}
    ...                                                                                                    att_index=${0}
    ...    ELSE IF   "${operation}"=="HO_multiple" and "${source}"!="none" and "${target}"!="none"
    ...                                                                Set PA Value For Source And Target Cell With Multiple Times
    ...                                                                                           source=${source}
    ...                                                                                           target=${target}
    ...    ELSE IF       "${source}"=="none" and "${target}"=="none"    fail    msg=Please provide at least one paramater
    [Return]    ${output}