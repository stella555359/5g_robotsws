*** Settings ***
Documentation
...            == Purpose ==
...            Library to manage GNB Hardening operations
...
...            == Description ==
...            Proposed keywords will offer these services:
...            - resources information retrieval
...            - resources comparison
...            - resources check
...
...            *Main keywords are:*
...            | ${resources_usage}          | Get Resources               |
...            | ${resources_usage}          | Get Resources By Name       | <res_name>        |
...            | ${result}          | Compare Resources       | <item1>        | <item2>        |
...            | ${result}          | Compare Resources With Tolerance      | <item1_res_usage>        | <item2_res_usage>        |
...                                 | <tolerance_file_path>        |
...            | Check Same Resources   | <item1>        | <item2>        | <exclusion_list>      |
...
...            *Example:*
...                 ${R1} = Get Resources
...
...                 Do some tests
...                 ${R2} = Get Resources
...                 ${delta_R} = Compare Resources    ${R1}   ${R2}
...                 ${areTheSame} = Check Same Resources    ${R1}   ${R2}
...

Library           Collections
Library           ../python/StringTool.py
Library           ../python/OsTool.py
Library           ../python/Hardening.py
Library           taf.ccs.aashell                         WITH NAME                 cli
Resource          Tools.robot

*** Keywords ***
Get Resources
    [Documentation]                 Get resources usage from GNB
    ...
    ...                             Return the current resources usage (result format is a dictionary)
    cli.create_aashell_cli          name=aashell
    cli.setup                       aashell
    ${resources_usage} =            cli.get_resources_usage                 aashell
    [Return]                        ${resources_usage}
    [Teardown]                      cli.teardown                            aashell


Get Resources By Name
    [Documentation]                 Get resources usage part by name from GNB
    ...
    ...                             Return an item included in current resources usage (result format is a dictionary)
    ...
    ...                             *Argument details:*
    ...                              - res_name :resource name
    [Arguments]                     ${res_name}
    cli.create_aashell_cli          name=aashell
    cli.setup                       aashell
    ${resources_usage} =            cli.get_resources_usage                 aashell
    ${result} =                     Get From Dictionary                     ${resources_usage}
    ...                             ${res_name}
    [Return]                        ${result}
    [Teardown]                      cli.teardown                            aashell

Compare Resources
    [Documentation]                 compare 2 items retrieved using Get Resources kw.
    ...
    ...                             The keyword returns a dictionary describing the comparison differences
    ...
    ...                             *Argument details:*
    ...                              - item1 : first element to be compared (format is a dictionary)
    ...                              - item2 : second element to be compared (format is a dictionary)
    ...
    [Arguments]                     ${item1}                               ${item2}
    ${result}                       Hardening.Compare_Resources_Data_Deepdiff
    ...                             ${item1}                                ${item2}
    [Return]                        ${result}

Compare Resources With Tolerance
    [Documentation]                 compare 2 items retrieved using Get Resources kw. Values are filtered using a tolerance
    ...                             file. This file contain a fork of values that is considered valid for changed items.
    ...                             A list containing differences description is returned
    ...
    ...                             The keyword returns a dictionary describing the comparison differences
    ...
    ...                             *Argument details:*
    ...                              - item1_res_usage : first element usage to be compared
    ...                              - item2_res_usage : second element usage to be compared
    ...                              - tolerance_file_path : csv file path defining tolerances
    ...
    [Arguments]                     ${item1_res_usage}                     ${item2_res_usage}
    ...                             ${tolerance_file_path}
    ${result}                       Hardening.diff_resource_usage_with_tolerance
    ...                             ${item1_res_usage}                     ${item2_res_usage}
    ...                             ${tolerance_file_path}
    [Return]                        ${result}

Check Same Resources
    [Documentation]                 This KW usage is optional but may be useful. It compares 2 items retrieved using Get Resources
    ...                             and evaluates if there is no difference (same as TAF Check Resource Usage Equal).
    ...
    ...                             The keyword returns a boolean giving the comparison result
    ...
    ...                             *Argument details:*
    ...                              - item1 : first element to be compared (format is a dictionary)
    ...                              - item2 : second element to be compared (format is a dictionary)
    ...                              - exclusion_list : exclusion list identifying elements not to be compared (format is a list)
    ...
    [Arguments]                     ${item1}                                ${item2}
    ...                             ${exclusion_list}
    ${result}                       Hardening.are_equal_as_resources_multiple_excl
    ...                             ${item1}                                ${item2}
    ...                             ${exclusion_list}
    [Return]                        ${result}
