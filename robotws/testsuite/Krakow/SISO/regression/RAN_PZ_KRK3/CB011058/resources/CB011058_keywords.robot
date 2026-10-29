*** Settings ***
Documentation
...   Resource files for regression testing of feature CB011058 Enhanced PDL Validation Service to support HW validation
...   author: Marek Bodziony (marek.bodziony@nokia.com)
...   contact: Piotr Suski (piotr.suski@nokia.com)

Library     taf.rfrl.bts.devices.du.commissioning.GnbCommissioning          WITH NAME   gnb_scf
Library     taf.nms.netact                                                  WITH NAME   MantaRay
Library     taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations       WITH NAME   gnb_cell
Library     testsuite.Krakow.SISO.regression.RAN_PZ_KRK3.CB011058.resources.automation_helper.BtsHelper     WITH NAME   BTS_helper
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Variables ***
${MantaRay_hostname}       ${tl.nms.netact.ssh_connections_info[0].addr}
${MantaRay_username}       ${tl.nms.netact.ssh_connections_info[0].username}
${MantaRay_password}       ${tl.nms.netact.ssh_connections_info[0].password}
${MantaRay_alias}          MantaRay
${TMP_DIR}                      /tmp/

*** Keywords ***
Prepare SW package with PDL plugin and upload to MantaRay
    ${PDL_plugin}                       BTS_helper.download_pdl_plugin
    ${SW_package_with_PDL_plugin}       BTS_helper.prepare_sw_package_with_pdl_plugin
    Upload SW package to MantaRay       SW_package_path=${SW_package_with_PDL_plugin}

Upload SW package to MantaRay
    [Arguments]     ${SW_package_path}
    MantaRay.import_build     build_or_file_path=${SW_package_path}     alias=${MantaRay_alias}

Setup for MantaRay srnclab
    Add Node    cmwas    ${MantaRay_hostname}     ${MantaRay_username}     ${MantaRay_password}    alias=${MantaRay_alias}

Teardown for MantaRay
    Clean All    alias=${MantaRay_alias}

Validate SCF with errors via WebEM and expect failure
    [Arguments]     ${scf_with_errors}
    ${validation_output}    Run Keyword And Ignore Error
    ...                     gnb_scf.validate_configuration  scf_file=${scf_with_errors}
    ${validation_errors}=   BTS_helper.get_scf_validation_errors    validation_output=${validation_output}
    ${validation_errors_list}=   BTS_helper.get_list_of_scf_validation_errors    validation_errors=${validation_errors}
    [Return]        ${validation_errors_list}

Save SCF without errors
    Add parameter 'plannedSWReleaseVersion' to SCF
    ${scf_path}=    BTS_helper.save_active_bts_config
    [Return]        ${scf_path}

Validate and activate SCF without errors via WebEM and expect success
    [Arguments]    ${SCF_without_errors}
    ${output}    gnb_scf.perform_bts_full_commissioning  scf_file=${SCF_without_errors}
    Wait Until Keyword Succeeds	    5 min	15 sec      gnb_cell.verify_all_cells_are_onair

Add parameter 'plannedSWReleaseVersion' to SCF
    ${planned_sw_version}=    BTS_helper.get_bts_sw_version
    gnb_scf.perform_configuration_parameter_recommissioning    operation=update    bts_id=0    du_id=0
    ...     dist_name=MRBTS-${tl.gnbs[0].instance_id}/MNL-1
    ...     parameter=plannedSWReleaseVersion    value=${planned_sw_version}
    ...     skip_parameter_relation_errors=${false}    should_activate=${true}    timeout=${60}

Prepare SCF with errors
    [Arguments]    ${scf_path}
    ${scf_err_path}=    BTS_helper.create_invalid_scf     scf_path=${scf_path}
    [Return]    ${scf_err_path}

Prepare RAML files and import to MantaRay
    [Arguments]    ${scf}    ${scf_with_errors}
    ${raml_plan}                Convert SCF to RAML and import to MantaRay   scf=${scf}
    ${raml_plan_with_errors}    Convert SCF to RAML and import to MantaRay   scf=${scf_with_errors}
    [Return]    ${raml_plan}     ${raml_plan_with_errors}

Convert SCF to RAML and import to MantaRay
    [Arguments]     ${scf_path}
    ${scf_name}     BTS_helper.get_scf_name         scf_path=${scf_path}
    ${raml_name}    BTS_helper.prepare_raml_name    scf_name=${scf_name}
    MantaRay.import_scf     plan_name=${raml_name}  file_name=${scf_name}   local_dir=${TMP_DIR}   alias=${MantaRay_alias}
    [Return]    ${raml_name}

Validate plan in MantaRay
    [Arguments]     ${raml_plan}
    MantaRay.prevalidate_plan       plan_name=${raml_plan}      alias=${MantaRay_alias}

Validate RAML plan without errors in MantaRay and expect success
    [Arguments]     ${raml_without_errors}
    Validate plan in MantaRay   raml_plan=${raml_without_errors}

Validate RAML plan with errors in MantaRay and expect failure
    [Arguments]     ${raml_with_errors}
    Run Keyword And Ignore Error
    ...         Validate plan in MantaRay       raml_plan=${raml_with_errors}
    ${last_operation}           MantaRay.fetch_operation_groups     alias=${MantaRay_alias}    group_count=1
    ${last_operation_id}        BTS_helper.get_last_operation_id    last_operation=${last_operation}
    ${validation_feedback}      MantaRay.fetch_feedback     alias=${MantaRay_alias}    group_id=${last_operation_id}
    ${validation_errors}        BTS_helper.get_raml_validation_errors   validation_feedback=${validation_feedback}
    ${validation_errors_list}        BTS_helper.get_list_of_raml_validation_errors   validation_errors=${validation_errors}
    [Return]    ${validation_errors_list}

Check if SCF and RAML validation errors are the same
    [Arguments]    ${scf_errors}   ${raml_errors}
    BTS_helper.compare_scf_ram_validation_errors    scf_errors=${scf_errors}   raml_errors=${raml_errors}

Remove RAML plan from MantaRay
    [Arguments]    ${plan_to_remove}
    MantaRay.delete_plan    plan_name=${plan_to_remove}     alias=${MantaRay_alias}

Remove SW package with PDL plugin from MantaRay
    ${sw_version}    BTS_helper.get_bts_sw_version
    MantaRay.delete_build     version_ids=${sw_version}     alias=${MantaRay_alias}
