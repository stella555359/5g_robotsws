*** Settings ***
Documentation   Keywords regarding BTS commissioning.

Resource        ../admin/admin.robot

Library         ../admin/admin_utils.py
Library         taf.sbts.oam.coam.admin    WITH NAME    coam_admin
Library         taf.config.scf             WITH NAME    scf

*** Variables ***
${TEMP_COMM_CONN}=  temporary_commissioning_connection

*** Keywords ***
Check if BTS is able to be commissioned
    ${current_state}=       Get current BTS state
    Should Contain Any      ${current_state}
    ...                     Configured
    ...                     OnAir
    ...                     IntegratedToRan
    ...                     NotCommissioned

Check if Object Exists in Scf File
    [Documentation]        This keyword checks in SCF if given object already exists
    [Arguments]            ${dist_name}   ${object_name}   ${timeout}=90   ${connection}=${NONE}
    ${connection}          admin_utils.create_connection_if_not_exist
    ...                    connection=${connection}
    ...                    alias=${TEMP_ADMIN_CONN}_LOOP
    coam_admin.get_current_scf_file    local_dir_path=/tmp/
    ...                           file_name=full_scf.xml
    ...                           export_type=configurationAndRuntimeObjects
    ...                           timeout=${timeout}
    ...                           connection=${connection}
    scf.load_scf           /tmp/full_scf.xml
    ${value}=              scf.is_element_in_object    dist_name=${dist_name}   p_name=${object_name}
    Log                    ${object_name} exist status is: ${value}   console=true
    [Return]               ${value}
    [Teardown]             Run Keyword and ignore error
    ...                    coam_admin.Teardown    connection=${TEMP_ADMIN_CONN}_LOOP

Commission SCF
    [Arguments]                     ${scf_file}   ${skip_parameter_relation_errors}=${TRUE}
    ...                             ${timeout}=300    ${connection}=${NONE}
    ${connection}=                  admin_utils.create connection if not exist
    ...                             connection=${connection}
    ...                             alias=${TEMP_COMM_CONN}_loop

    Wait Until Keyword Succeeds     20 min    30 sec
    ...                             coam_admin.perform_commissioning
    ...                             scf_file=${scf_file}
    ...                             skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...                             timeout=${timeout}
    ...                             connection=${connection}

    [Teardown]                      Run keyword and ignore error
    ...                             Disconnect from ADMIN
    ...                             connection=${TEMP_COMM_CONN}_loop

Load SCF and update RU SW if necessary
    [Arguments]                  ${scf_path}   ${connection}=${NONE}
    ${connection}=               admin_utils.create connection if not exist
    ...                          connection=${connection}
    ...                          alias=${TEMP_COMM_CONN}

    ${status}=                   Run Keyword And Return Status
    ...                          Wait Until Keyword Succeeds	 20 min  30 sec
    ...                          Check if BTS is able to be commissioned
    Run Keyword If               not ${status}
    ...                          Wait until BTS reach state
    ...                          state=Commissioned
    Log                          Commissioning with ${scf_path}...
    ...                          console=${TRUE}
    Commission SCF               scf_file=${scf_path}
    ...                          skip_parameter_relation_errors=${False}
    Log                          ${scf_path} has been commissioned into gNB.
    ...                          console=${TRUE}

    [Teardown]                   Run keyword and ignore error
    ...                          Disconnect from ADMIN
    ...                          connection=${TEMP_COMM_CONN}
