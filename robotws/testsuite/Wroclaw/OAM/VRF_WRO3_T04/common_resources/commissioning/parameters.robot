*** Settings ***
Documentation   Keywords designed for BTS parameters management.
...             Author:     Jakub Aniszewski
...             Contact:    jakub.aniszewski@nokia.com
...
...             Note about using ADMIN connection object:
...                 All keywords defined in this file use flexible ADMIN connection
...                 object handling. It provies three connection establishment methods.
...
...                 1. You can conventionally pass ADMIN connection object as a keyword argument.
...                    EXAMPLE:
...                         Test Case
...                             ${admin_conn}             Connect to ADMIN
...                             Change Parameter on BTS   connection=${admin_conn}   dist_name=...
...                             Disconnect from ADMIN     connection=${admin_conn}
...
...                 2. You can also run keyword without providing ADMIN connection object at all.
...                    Exectuted keyword will detect that the `connection` argument is not provided.
...                    In such case, an ADMIN connection will be automatically created at
...                    keyword runtime and closed when execution is finished (regardless of keyword result).
...                    EXAMPLE:
...                         Test Case
...                             Change Parameter on BTS     dist_name=...

Library         ./ParametersCommissioningManager.py     WITH NAME   param_manager
Library         ../admin/admin_utils.py
Library         taf.sbts.oam.coam.admin    WITH NAME   coam_admin

*** Variables ***
${TEMP_ADMIN_CONN}=         temporary_admin_connection

*** Keywords ***
Change Multiple Parameters on BTS
    [Documentation]     Change multiple parameters values within object dist name with only one recommissioning.
    ...
    ...                 This keyword accepts free named arguments and should be used like this:
    ...                 Change Multiple Parameters on BTS    dist_name=<dist_name value>
    ...                 ...                                  <parameter1 name>=<parameter1 value>
    ...                 ...                                  <parameter2 name>=<parameter2 value>
    ...                 ...                                  <parameter3 name>=<parameter3 value>
    ...
    ...                 It is important to place parameters name-value pairs as absolutely last arguments.
    ...                 NOTE: `connection` argument is optional (more in Documentation section)

    [Arguments]         ${dist_name}
    ...                 ${skip_parameter_relation_errors}=${FALSE}
    ...                 ${should_activate}=${TRUE}
    ...                 ${timeout}=900
    ...                 ${retry}=2
    ...                 ${connection}=${NONE}
    ...                 &{kwargs}

    param_manager.recommission_object         dist_name=${dist_name}
    ...                                       operation=update
    ...                                       skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...                                       should_activate=${should_activate}
    ...                                       timeout=${timeout}
    ...                                       retry=${retry}
    ...                                       connection=${connection}
    ...                                       &{kwargs}

Change Parameter on BTS
    [Documentation]  Update single BTS parameter value.
    ...              NOTE: `connection` argument is optional (more in Documentation section)

    [Arguments]      ${dist_name}    ${param_name}
    ...              ${param_value}  ${skip_parameter_relation_errors}=${FALSE}
    ...              ${timeout}=900  ${should_activate}=${TRUE}
    ...              ${retry}=2      ${connection}=${NONE}
    ${connection}=   admin_utils.create_connection_if_not_exist
    ...              connection=${connection}
    ...              alias=${TEMP_ADMIN_CONN}
    ${output}=       param_manager.recommission_parameter   dist_name=${dist_name}
    ...                                                     param_name=${param_name}
    ...                                                     param_value=${param_value}
    ...                                                     operation=update
    ...                                                     timeout=${timeout}
    ...                                                     skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...                                                     should_activate=${should_activate}
    ...                                                     retry=${retry}
    ...                                                     connection=${connection}
    [Teardown]       Run Keyword And Ignore Error           admin.Disconnect from ADMIN
    ...                                                     connection=${TEMP_ADMIN_CONN}
    [Return]         ${output}

Create Multiple Parameters on BTS
    [Documentation]     Create multiple parameters values within object dist name with only one recommissioning.
    ...
    ...                 This keyword accepts free named arguments and should be used like this:
    ...                 Create Multiple Parameters on BTS    dist_name=<dist_name value>
    ...                 ...                                  <parameter1 name>=<parameter1 value>
    ...                 ...                                  <parameter2 name>=<parameter2 value>
    ...                 ...                                  <parameter3 name>=<parameter3 value>
    ...
    ...                 It is important to place parameters name-value pairs as absolutely last arguments.
    ...                 NOTE: `connection` argument is optional (more in Documentation section)

    [Arguments]         ${dist_name}
    ...                 ${skip_parameter_relation_errors}=${FALSE}
    ...                 ${should_activate}=${TRUE}
    ...                 ${timeout}=900
    ...                 ${retry}=2
    ...                 ${connection}=${NONE}
    ...                 &{kwargs}

    param_manager.recommission_object         dist_name=${dist_name}
    ...                                       operation=create
    ...                                       skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...                                       should_activate=${should_activate}
    ...                                       timeout=${timeout}
    ...                                       retry=${retry}
    ...                                       connection=${connection}
    ...                                       &{kwargs}

Delete Parameter From BTS
    [Documentation]  Delete single BTS parameter value.
    ...              NOTE: `connection` argument is optional (more in Documentation section)

    [Arguments]      ${dist_name}                ${param_name}
    ...              ${timeout}=900              ${skip_parameter_relation_errors}=${FALSE}
    ...              ${should_activate}=${TRUE}  ${retry}=2
    ...              ${connection}=${NONE}
    ${connection}=   admin_utils.create_connection_if_not_exist
    ...              connection=${connection}
    ...              alias=${TEMP_ADMIN_CONN}
    param_manager.recommission_parameter   dist_name=${dist_name}
    ...                                    param_name=${param_name}
    ...                                    param_value=${EMPTY}
    ...                                    operation=delete
    ...                                    timeout=${timeout}
    ...                                    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...                                    should_activate=${should_activate}
    ...                                    retry=${retry}
    ...                                    connection=${connection}
    [Teardown]       Run Keyword And Ignore Error           admin.Disconnect from ADMIN
    ...                                                     connection=${TEMP_ADMIN_CONN}

Create Object on BTS
    [Documentation]    Description:    Create single BTS object.
    ...                Input:          param_list = list of dictionaries containing parameters and their values.
    ...                                             this variable should be created like this:
    ...                                             ${param_dict}=    Create Dictionary    parameterName=X
    ...                                                                                    operation=update
    ...                                                                                    value=Y
    ...                                             ${param_list}=    Create List    ${param_dict}
    [Arguments]        ${dist_name}    ${param_list}    ${timeout}=900    ${should_activate}=${TRUE}
    ...                ${skip_parameter_relation_errors}=${FALSE}    ${connection}=${NONE}
    ${connection}=     admin_utils.create_connection_if_not_exist
    ...                connection=${connection}
    ...                alias=${TEMP_ADMIN_CONN}
    coam_admin.Perform Object Recommissioning    dist_name=${dist_name}    parameter=${param_list}
    ...                operation=create    timeout=${timeout}    should_activate=${should_activate}
    ...                skip_parameter_relation_errors=${skip_parameter_relation_errors}    connection=${connection}
    [Teardown]         Run Keyword And Ignore Error    admin.Disconnect from ADMIN    connection=${TEMP_ADMIN_CONN}

Delete Object From BTS
    [Documentation]    Delete single BTS object.
    [Arguments]        ${dist_name}    ${timeout}=900    ${should_activate}=${TRUE}
    ...                ${skip_parameter_relation_errors}=${FALSE}    ${connection}=${NONE}
    ${connection}=     admin_utils.create_connection_if_not_exist
    ...                connection=${connection}
    ...                alias=${TEMP_ADMIN_CONN}
    ${empty_param}=    Create List
    coam_admin.Perform Object Recommissioning    dist_name=${dist_name}    parameter=${empty_param}
    ...    operation=delete    timeout=${timeout}    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...    should_activate=${should_activate}    connection=${connection}
    [Teardown]         Run Keyword And Ignore Error    admin.Disconnect from ADMIN    connection=${TEMP_ADMIN_CONN}

Recommission Parameters By Delta
    [Documentation]     Create, update or delete multiple parameters within multiple objects dist names
    ...                 with only one recommissioning. To use this keyword you have to provide
    ...                 `delta` argument in a form of list of dictionaries with structure
    ...                 specified below.
    ...
    ...                 Delta object structure example:
    ...                     [
    ...                         {
    ...                             'distName': 'MRBTS-51091/MNL-1/CERTH-1/CMP-1',
    ...                             'operation': 'update',
    ...                             'parameters': [
    ...                                 {
    ...                                     'parameterName': 'serverHost',
    ...                                     'operation': 'update',
    ...                                     'value': '3.3.3.3'
    ...                                 },
    ...                                 {
    ...                                     'parameterName': 'serverPath',
    ...                                     'operation': 'update',
    ...                                     'value': 'pkix'
    ...                                 }
    ...                             ]
    ...                         },
    ...                         {
    ...                             'distName': 'MRBTS-51091/MNL-1/CERTH-1/CRLH-1',
    ...                             'operation': 'update',
    ...                             'parameters': [
    ...                                 {
    ...                                     'parameterName': 'crlDownloadProtocol',
    ...                                     'operation': 'update',
    ...                                     'value': 'LDAP_OR_HTTP'
    ...                                 }
    ...                             ]
    ...                         }
    ...                     ]
    ...
    ...                 NOTE: `connection` argument is optional (more in Documentation section)


    [Arguments]         ${delta}
    ...                 ${skip_parameter_relation_errors}=${FALSE}
    ...                 ${should_activate}=${TRUE}
    ...                 ${timeout}=900
    ...                 ${retry}=2
    ...                 ${connection}=${NONE}

    param_manager.recommission_with_delta     delta=${delta}
    ...                                       skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...                                       should_activate=${should_activate}
    ...                                       timeout=${timeout}
    ...                                       retry=${retry}
    ...                                       connection=${connection}

Change R&D Service Port Status
    [Documentation]  Change the value for R&D service port. The possible values for this port is
    ...              True what means enabled and False what means disabled.
    [Arguments]      ${enable}=False    ${timeout}=120    ${connection}=${NONE}
    ${connection}=   admin_utils.create_connection_if_not_exist
    ...              connection=${connection}
    ...              alias=${TEMP_ADMIN_CONN}
    coam_admin.change_rnd_port_security                                enable=${enable}
    ...                                                     timeout=${timeout}
    ...                                                     connection=${connection}
    [Teardown]       Run Keyword And Ignore Error           admin.Disconnect from ADMIN
    ...                                                     connection=${TEMP_ADMIN_CONN}
