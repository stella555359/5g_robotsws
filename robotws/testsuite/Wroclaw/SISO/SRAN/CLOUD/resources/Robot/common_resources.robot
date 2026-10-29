*** Settings ***
Documentation  AiC common resources keywords.
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    OperatingSystem
Library    Process
Library    String
Library    Collections
Library    json
Library    ../../../resources/qc.py

Resource    ./vdu_vcu_operations.robot

*** Keywords ***
Create Kpi Results File
    [Arguments]  ${kpi_name}  ${kpi_result_file_path}  ${kpi_dict}  ${target_kpi_value}
    [Documentation]
    ...  Description:
    ...  Keyword creates text file with KPI results.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | kpi_name               | Yes  | Name of KPI (e.g. 17a, 51a, etc.).                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | kpi_result_file_path   | Yes  | Path to the file with the KPI results.                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | kpi_dict               | Yes  | Dictionary with KPI values and names of objects (e.g. cell_identity)       |
    ...  |                        |      | from which KPI (e.g. 17a) were collected, e.g.:                            |
    ...  |                        |      | {'138838017': 4.27, '138838019': 4.226, '138838021': 3.194}                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | target_kpi_value       | Yes  | Target KPI value in seconds.                                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Append To File    ${kpi_result_file_path}    \nSoftware builds:\n
    Append To File    ${kpi_result_file_path}    vCU: ${VCU_SW_VERSION}\n
    Append To File    ${kpi_result_file_path}    vDU: ${VDU_SW_VERSION}\n
    Append To File    path=${kpi_result_file_path}    content=\nKPI ${kpi_name} results:\n
    ${kpi_object_list}=	Get Dictionary Keys  dictionary=${kpi_dict}
    ${kpi_value_list}=	Get Dictionary Values  dictionary=${kpi_dict}
    ${average_kpi}=  Evaluate  expression=round(sum(${kpi_value_list})/len(${kpi_value_list}), 4)
    FOR  ${kpi_object}  IN  @{kpi_object_list}
      ${kpi_value}=  Get From Dictionary  dictionary=${kpi_dict}  key=${kpi_object}
      ${percentage_diff}=  Evaluate  expression=round((((${kpi_value}-${average_kpi})*100)/${average_kpi}), 2)
      Append To File  path=${kpi_result_file_path}  content=${kpi_object}: ${kpi_value}s, Percentage difference: ${percentage_diff}%\n
    END
    Append To File  path=${kpi_result_file_path}  content=\nTarget KPI ${kpi_name} value: ${target_kpi_value}s\n
    Append To File  path=${kpi_result_file_path}  content=Average value (${kpi_name}): ${average_kpi}s\n
    ${max_kpi_value}=  Evaluate  expression=max(${kpi_value_list})
    Append To File  path=${kpi_result_file_path}  content=\nMax KPI ${kpi_name} value: ${max_kpi_value}s\n
    ${min_kpi_value}=  Evaluate  expression=min(${kpi_value_list})
    Append To File  path=${kpi_result_file_path}  content=Min KPI ${kpi_name} value: ${min_kpi_value}s\n

Get Command Result
    [Arguments]  ${cmd_result}
    [Documentation]
    ...  Description:
    ...  Keyword takes the entire result obtained from executing the ssh command and returns a single result.
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cmd_result             | Yes  | The result obtained from executing the ssh command.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${cmd_result_lines}=  Split To Lines  string=${cmd_result}
    Remove From List  ${cmd_result_lines}  0
    Remove From List  ${cmd_result_lines}  -1
    ${cmd_result_length}=  Get Length  item=${cmd_result_lines}
    Should Be True  ${cmd_result_length}==2
    ${final_cmd_result}=  Set Variable  ${cmd_result_lines[-1]}
    [Return]  ${final_cmd_result}

Get Command Result List
    [Arguments]  ${cmd_result}
    [Documentation]
    ...  Description:
    ...  Keyword takes the entire result obtained from executing the ssh command and returns a list result.
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cmd_result             | Yes  | The result obtained from executing the ssh command.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${cmd_result_lines}=  Split To Lines  string=${cmd_result}
    Remove From List  ${cmd_result_lines}  0
    Remove From List  ${cmd_result_lines}  -1
    ${cmd_result_list}=  Set Variable  ${cmd_result_lines}
    [Return]  ${cmd_result_list}

Create Single Dist Name Json String
    [Arguments]  ${mo_dn}  ${updated_params_dict}  ${distname_operation}
    [Documentation]
    ...  Description:
    ...  Keyword returns a string in JSON format that can define delta commissioning for a single object defined by Distinguished Name.
    ...  A dictionary of parameters can be defined for different parameter operations.
    ...  Example:
    ...  ${updated_params_dict} = {'update': {'actPimCancellation': 'true', 'pimCancellingEnabled': 'true'}, 'create': {'moduleLocation': 'Rack_1'}}
    ...  The function returns two variables.
    ...  The first variable is a list of changed parameters in JSON format for one managed object, for use in delta commissioning, for example.
    ...  The second variable is a dictionary of changed parameters for one managed object.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | mo_dn                  | Yes  | Distinguished Name of managed object.                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | updated_params_dict    | Yes  | Dictionary with parameters and operations performed on parameters.         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | distname_operation     | Yes  | An operation performed on an object defined by Distinguished Name.         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${json_parameters_list}=  Create List
    ${distname_parameters_list}=  Create List
    FOR  ${parameter_operation}  ${distname_parameters}  IN  &{updated_params_dict}
      FOR  ${distname_parameter_name}  ${distname_parameter_value}  IN  &{distname_parameters}
        &{distname_parameter_item}=  Run Keyword If  '${parameter_operation}'=='delete'
        ...  Create Dictionary  parameterName=${distname_parameter_name}  operation=${parameter_operation}
        ...  ELSE
        ...  Create Dictionary  parameterName=${distname_parameter_name}
        ...  value=${distname_parameter_value}  operation=${parameter_operation}
        Append To List  ${distname_parameters_list}  ${distname_parameter_item}
      END
      &{json_parameters}=  Run Keyword If  ${distname_parameters}==&{EMPTY}
      ...  Create Dictionary  distName=${mo_dn}  operation=${distname_operation}
      ...  ELSE
      ...  Create Dictionary  distName=${mo_dn}  operation=${distname_operation}
      ...  parameters=${distname_parameters_list}
    END
    Append To List  ${json_parameters_list}  ${json_parameters}
    ${json_parameters_format}=  Json.Dumps  ${json_parameters_list}
    [Return]  ${json_parameters_format}  ${json_parameters}

Create Json String
    [Arguments]  ${distnames_json_elements}
    [Documentation]
    ...  Description:
    ...  Keyword returns a string in JSON format that can define delta commissioning
    ...  for a different objects defined by Distinguished Name.
    ...  The argument is a list of objects to be changed along with their parameters.
    ...  Example:
    ...  ${distnames_json_elements}=
    ...  [{'distName': 'MRBTS-8474/MNL-1/CMD-1/SWRESETREQ-1',
    ...    'operation': 'create',
    ...    'parameters': [{'operation': 'update',
    ...                    'parameterName': 'swResetLevel',
    ...                    'value': 'resetToTestLevel'}]},
    ...   {'distName': 'MRBTS-8474/EQM-1/APEQM-1/RMOD-1',
    ...    'operation': 'update',
    ...    'parameters': [{'operation': 'update',
    ...                    'parameterName': 'actPimCancellation',
    ...                    'value': 'true'},
    ...                   {'operation': 'update',
    ...                    'parameterName': 'pimCancellingEnabled',
    ...                    'value': 'true'}]}]
    ...  Argument ${distnames_json_elements} can be list of returned ${json_parameters} value from
    ...  "Create Single Dist Name Json String" keyword.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  |distnames_json_elements | Yes  | List of changed parameters for managed objects.                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${json_parameters_list}=  Create List
    FOR  ${distnames_json_element}  IN  @{distnames_json_elements}
      Append To List  ${json_parameters_list}  ${distnames_json_element}
    END
    ${json_parameters_format}=  Json.Dumps  ${json_parameters_list}
    [Return]  ${json_parameters_format}
