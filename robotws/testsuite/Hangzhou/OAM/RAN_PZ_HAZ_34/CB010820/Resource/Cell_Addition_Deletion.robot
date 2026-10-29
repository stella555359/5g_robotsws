*** Settings ***
Resource   Common.robot


*** Variables ***


*** Keywords ***
Cell List Deletion Common Keyword
    [Arguments]   ${cell_id_list}   ${connection}=Cell_Addition_Deletion
    ...   ${scf_local_dir}=${OUTPUT_DIR}   ${scf_file_name}=Cell_Addition_Deletion_BACK.xml
    COAM Login   alias=${connection}
    COAM Backup SCF   local_dir=${scf_local_dir}   file_name=${scf_file_name}   connection=${connection}
    COAM Get All Addition Deletion Infomation From SCF   scf_path=${scf_local_dir}/${scf_file_name}
    FOR   ${cell_id}   IN   @{cell_id_list}
        COAM ADMIN Cell Deletion   cell_id=${cell_id}   connection=${connection}
    END
    Wait Until Keyword Succeeds   10m   1m   COAM ADMIN Check Cell Onair   connection=${connection}
    [Teardown]   COAM Logout   connection=${connection}


Cell List Addition Common Keyword
    [Arguments]   ${cell_id_list}   ${connection}=Cell_Addition_Deletion
    ...   ${scf_local_dir}=${OUTPUT_DIR}   ${scf_file_name}=Cell_Addition_Deletion_BACK.xml

    COAM Login   alias=${connection}
    COAM Get All Addition Deletion Infomation From SCF   scf_path=${scf_local_dir}/${scf_file_name}
    FOR   ${cell_id}   IN   @{cell_id_list}
        COAM WEBEM Cell Addition   cell_id=${cell_id}   scf_path=${scf_local_dir}/${scf_file_name}
    END
    [Teardown]   COAM Logout   connection=${connection}


Cell List Addition Deletion Common Keyword
    [Arguments]   ${cell_id_list}   ${connection}=Cell_Addition_Deletion
    ...   ${scf_local_dir}=${OUTPUT_DIR}   ${scf_file_name}=Cell_Addition_Deletion_BACK.xml

    COAM Login   alias=${connection}
    COAM Backup SCF   local_dir=${scf_local_dir}   file_name=${scf_file_name}   connection=${connection}
    COAM Get All Addition Deletion Infomation From SCF   scf_path=${scf_local_dir}/${scf_file_name}
    FOR   ${cell_id}   IN   @{cell_id_list}
        COAM ADMIN Cell Deletion   cell_id=${cell_id}   connection=${connection}
        Wait Until Keyword Succeeds   10m   1m   COAM ADMIN Check Cell Onair   connection=${connection}

        Wait Until Keyword Succeeds   3x   10s
        ...   COAM WEBEM Cell Addition   cell_id=${cell_id}   scf_path=${scf_local_dir}/${scf_file_name}
        Wait Until Keyword Succeeds   10m   1m   COAM ADMIN Check Cell Onair   connection=${connection}
    END
    [Teardown]   COAM Logout   connection=${connection}


Cell Addition Deletion Common Keyword
    [Arguments]   ${cell_id}   ${connection}=Cell_Addition_Deletion
    ...   ${scf_local_dir}=${OUTPUT_DIR}   ${scf_file_name}=Cell_Addition_Deletion_BACK.xml

    COAM Login   alias=${connection}
    COAM Backup SCF   local_dir=${scf_local_dir}   file_name=${scf_file_name}   connection=${connection}
    COAM Get All Addition Deletion Infomation From SCF   scf_path=${scf_local_dir}/${scf_file_name}
    COAM ADMIN Cell Deletion   cell_id=${cell_id}   connection=${connection}
    Wait Until Keyword Succeeds   10m   1m   COAM ADMIN Check Cell Onair   connection=${connection}

    COAM WEBEM Cell Addition   cell_id=${cell_id}   scf_path=${scf_local_dir}/${scf_file_name}
    Wait Until Keyword Succeeds   10m   1m   COAM ADMIN Check Cell Onair   connection=${connection}

    [Teardown]   COAM Logout   connection=${connection}


COAM Get All Addition Deletion Infomation From SCF
    [Arguments]   ${scf_path}=${OUTPUT_DIR}/old_commission.xml
    ${scf_xml}   XML.Parse XML   ${scf_path}


    ${MRBTS_DN}   XML.Get Element Attribute   ${scf_xml}   name=distName   xpath=cmData/managedObject[@class="com.nokia.srbts:MRBTS"]
    ${NRBTS_DN}   XML.Get Element Attribute   ${scf_xml}   name=distName   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]
    Set Suite Variable   ${MRBTS_DN}
    Set Suite Variable   ${NRBTS_DN}

    # Get Cell Related Values
    &{ALL_VAR_INFO}   Create Dictionary

    @{all_cell_list}    Create List
    ${NRCELL_elem_list}   XML.Get Elements   ${scf_xml}   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]
    FOR   ${NRCELL_elem}   IN   @{NRCELL_elem_list}
        ${NRCELL_DN}   XML.Get Element Attribute   ${NRCELL_elem}   name=distName   xpath=.
        ${cell_index}    Fetch From Right    ${NRCELL_DN}    -
        Append to list    ${all_cell_list}    ${cell_index}
    END
    Log To Console   all_cell_list: ${all_cell_list}
    Set To Dictionary   ${ALL_VAR_INFO}   all_cell_list=${all_cell_list}


    @{all_cellgrp_list}    Create List
    @{realtime_cellgrp_list}    Create List
    ${NRCELLGRP_elem_list}   XML.Get Elements   ${scf_xml}   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCELLGRP"]
    FOR   ${NRCELLGRP_elem}   IN   @{NRCELLGRP_elem_list}
        ${NRCELLGRP_DN}   XML.Get Element Attribute   ${NRCELLGRP_elem}   name=distName   xpath=.
        ${cellgrp_index}    Fetch from right    ${NRCELLGRP_DN}    -
        Append to list    ${all_cellgrp_list}    ${cellgrp_index}
        Append to list    ${realtime_cellgrp_list}    ${cellgrp_index}
    END
    Log To Console   all_cellgrp_list: ${all_cellgrp_list}
    Log To Console   realtime_cellgrp_list: ${realtime_cellgrp_list}
    Set To Dictionary   ${ALL_VAR_INFO}   all_cellgrp_list=${all_cellgrp_list}
    Set To Dictionary   ${ALL_VAR_INFO}   realtime_cellgrp_list=${realtime_cellgrp_list}


    &{cellid_cellgrp_mapping}   Create Dictionary
    FOR   ${cell_index}   IN   @{all_cell_list}
        ${NRCELLGRP_DN}   XML.Get Element Attribute   ${scf_xml}   name=distName
        ...   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCELLGRP"]/list[@name="nrCellList"]/p[text()="${cell_index}"]/../../.
        ${cellgrp_index}    Fetch from right    ${NRCELLGRP_DN}    -
        Set To Dictionary   ${cellid_cellgrp_mapping}   ${cell_index}=${cellgrp_index}
    END
    Log To Console   cellid_cellgrp_mapping: ${cellid_cellgrp_mapping}
    Set To Dictionary   ${ALL_VAR_INFO}   cellid_cellgrp_mapping=${cellid_cellgrp_mapping}

    &{cellid_lcrid_mapping}   Create Dictionary
    FOR   ${cell_index}   IN   @{all_cell_list}
        ${lcrId}   XML.Get Element Text   ${scf_xml}
        ...   xpath=cmData/managedObject[@distName="${NRBTS_DN}/NRCELL-${cell_index}"]/p[@name="lcrId"]
        Set To Dictionary   ${cellid_lcrid_mapping}   ${cell_index}=${lcrId}
    END
    Log To Console   cellid_lcrid_mapping: ${cellid_lcrid_mapping}
    Set To Dictionary   ${ALL_VAR_INFO}   cellid_lcrid_mapping=${cellid_lcrid_mapping}

    Set Suite Variable   ${ALL_VAR_INFO}


COAM ADMIN Cell Deletion
    [Arguments]   ${cell_id}   ${connection}
    Log To Console   COAM ADMIN Cell Deletion
    #==============================================================================================================================================
    # # Delete Cell Admin
    #==============================================================================================================================================
    ${cell_grp_id}   Get Variable Value   ${ALL_VAR_INFO["cellid_cellgrp_mapping"]["${cell_id}"]}
    # ${realtime_cellgrp_list}   Get Variable Value   ${ALL_VAR_INFO["realtime_cellgrp_list"]}
    Remove Values From List   ${ALL_VAR_INFO["realtime_cellgrp_list"]}   ${cell_grp_id}
    Log To Console   ${ALL_VAR_INFO["realtime_cellgrp_list"]}

    # ${after_delete_all_cell_grp}   Evaluate   [i for i in ${realtime_cellgrp_list} if i!="${cell_grp_id}"]
    # Log To Console   ${after_delete_all_cell_grp}

    ${delta_file}   Catenate   SEPARATOR=
    ...   [{
    ...       "distName":"${MRBTS_DN}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}",
    ...       "operation":"delete",
    ...       "parameters":[]
    ...   },{
    ...       "distName":"${NRBTS_DN}/NRCELL-${cell_id}",
    ...       "operation":"delete",
    ...       "parameters":[]
    ...   },{
    ...       "distName":"${NRBTS_DN}/NRCELLGRP-${cell_grp_id}",
    ...       "operation":"delete",
    ...       "parameters":[]
    ...   },{
    ...       "distName":"${NRBTS_DN}/NRDU-1",
    ...       "operation":"update",
    ...       "parameters":[{
    ...           "parameterName": "refNrCellGroup",
    ...           "value": ${ALL_VAR_INFO["realtime_cellgrp_list"]},
    ...           "operation": "update"
    ...       }]
    ...   }]
    ${delta_file}   Set Variable   ${delta_file.replace("'","\"")}
    Log To Console   ${delta_file}
    # COAM Perform Delta Recommission   delta_file=${delta_file}   connection=${connection}
    coam.perform_delta_recommissioning
    ...   delta_file=${delta_file}
    ...   skip_parameter_relation_errors=${false}
    ...   should_activate=${true}
    ...   timeout=${600}
    ...   connection=${connection}


COAM WEBEM Cell Addition
    [Arguments]   ${cell_id}   ${scf_path}=${OUTPUT_DIR}/old_commission.xml
    Log To Console   COAM WEBEM Cell Addition
    #==============================================================================================================================================
    # Add Cell Webem
    #==============================================================================================================================================
    ${cell_grp_id}   Get Variable Value   ${ALL_VAR_INFO["cellid_cellgrp_mapping"]["${cell_id}"]}
    # ${all_cell_grp}   Get Variable Value   ${ALL_VAR_INFO["all_cellgrp_list"]}
    ${lcrId}   Get Variable Value   ${ALL_VAR_INFO["cellid_lcrid_mapping"]["${cell_id}"]}
    ${realtime_cellgrp_list}   Get Variable Value   ${ALL_VAR_INFO["realtime_cellgrp_list"]}
    Append To List   ${ALL_VAR_INFO["realtime_cellgrp_list"]}   ${cell_grp_id}
    Sort List   ${ALL_VAR_INFO["realtime_cellgrp_list"]}
    Log To Console   ${ALL_VAR_INFO["realtime_cellgrp_list"]}

    COAM WebEM Login
    selenium_sbts.load_commissioning_file_and_check_load_status    file_path=${scf_path}
    selenium_sbts.get_planned_parameter_value    dist_name=${MRBTS_DN}   filter_param=BTS name   abbr=btsName
    ...    bts_configuration=Current
    selenium_sbts.add_object    object_name=${MRBTS_DN}/MNL-1/MNLENT-1/CELLMAPPING-1
    ...    object_class_name=LCELNR    plan_to_copy_from=CONF-1
    ...    copy_from=${MRBTS_DN}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}
    ...    include_subobject=${True}   id_value=${cell_id}    timeout=15
    selenium_sbts.add_object    object_name=${NRBTS_DN}
    ...    object_class_name=NRCELL    plan_to_copy_from=CONF-1
    ...    copy_from=${NRBTS_DN}/NRCELL-${cell_id}
    ...    include_subobject=${True}   id_value=${cell_id}    timeout=15
    selenium_sbts.add_object    object_name=${NRBTS_DN}
    ...    object_class_name=NRCELLGRP    plan_to_copy_from=CONF-1
    ...    copy_from=${NRBTS_DN}/NRCELLGRP-${cell_grp_id}
    ...    id_value=${cell_grp_id}    timeout=15
    selenium_sbts.set_parameter_value    dist_name=${NRBTS_DN}/NRCELL-${cell_id}
    ...    filter_param=Local cell resource ID    abbr=lcrId    new_value=${lcrId}
    # recover NRDU-1 as prev
    selenium_sbts.add_element    dist_name=${NRBTS_DN}/NRDU-1
    ...    abbr=refNrCellGroup    filter_param=Reference to cell group
    ...    timeout=15

    ${cell_grp_len}   Get Length   ${ALL_VAR_INFO["realtime_cellgrp_list"]}
    FOR  ${index}   IN RANGE   ${cell_grp_len}
        selenium_sbts.set_parameter_value    dist_name=${NRBTS_DN}/NRDU-1
        ...    filter_param=Reference to cell group   new_value=${ALL_VAR_INFO["realtime_cellgrp_list"][${index}]}
        ...    node_index=${index}
    END
    selenium_sbts.validate_plan
    selenium_sbts.activate_plan    activate_plan_despite_errors=${False}
    [Teardown]   Run Keyword And Ignore Error   COAM WebEM Logout

