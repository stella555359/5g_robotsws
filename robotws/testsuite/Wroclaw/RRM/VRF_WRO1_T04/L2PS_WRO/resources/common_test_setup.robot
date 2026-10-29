*** Settings ***
Resource    testsuite/Wroclaw/RRM/resources/logs.robot
Resource    taf/rfrl/common_resources/robot/libraries_instances.robot

Library     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/resources/Python/vendor_file_modifier.py
Library     Collections
Library     OperatingSystem
Library     ute_wtssim
Library     ta5g_admin_operations
Library     ta5g_setups_and_teardowns
Library     taf.sbts.oam.coam.admin          WITH NAME    COAM
Library     taf.transport.ssh                WITH NAME    ssh

Documentation
...    This file contains general keywords used for testing on Classical TL.

*** Variables ***
${ARTIFACTORY_ROTTA_PATH}    https://artifactory-espoo1.ext.net.nokia.com/artifactory/list/mnpute-rotta-local/mkotula/BSR/

*** Keywords ***
Common Test Setup With BSR
    [Arguments]    ${iphy}    ${SWCONFIG_FLAGS}    ${bsr_file_name}    ${scf}
    Update Iphy Configuration And Modify Swconfig
    ...    iphy_xml_filepath=${iphy}
    ...    swconfig_flags_list=@{SWCONFIG_FLAGS}
    Get and Update BSR Files  bsr_file_name=${bsr_file_name}
    Download and Modify Vendor Files and perform commissioning    scf=${scf}

Common Test Setup
    [Arguments]    ${iphy}    ${scf}    ${cfg}    ${skip_relation_errors}=False
    Update Scf And Ap    ${iphy}    ${scf}    ${skip_relation_errors}
    Reach Onair    lua_cfg=${cfg}
    Start Default Logging    output_dirpath=${OUTPUT_DIR}

Common Test Teardown
    [Arguments]    ${iphy}    ${scf}
    Print Active Alarms
    Stop Default Processes And Gather Logs And Compress Logs
    Update Scf And Ap
    ...    iphy=${iphy}
    ...    scf=${scf}
    Check Radios Availability
    Send Configuration ID To Scout

Start Logs And Reach Onair
    [Arguments]    ${cfg}
    Start Default Logging
    Check Radios Availability
    Reach Onair    lua_cfg=${cfg}

Update Scf And Ap
    [Arguments]    ${iphy}    ${scf}    ${skip_relation_errors}=False
    Update And Put Iphy Xml         input_filepath=${iphy}
    Fix And Send Full Commissioning With Given Scf Filepath   scfc_filepath=${scf}
    ...                                                       skip_relation_errors=${skip_relation_errors}

ADMIN Setup Admin
    [Arguments]    ${alias}=${ADMIN_ALIAS}
    taf.sbts.oam.coam.admin.Setup Admin
    ...    alias=${alias}

ADMIN Teardown Admin
    [Arguments]    ${alias}=${ADMIN_ALIAS}
    taf.sbts.oam.coam.admin.Teardown Admin
    ...    connection=${alias}

Get and Update BSR Files
    [Arguments]     ${bsr_file_name}
    ${token}=   get_ca_ute_artifactory_token
    Run  sudo wget -d --header='Authorization:Bearer ${token}' ${ARTIFACTORY_ROTTA_PATH}${bsr_file_name} -O ${OUTPUTDIR}/${bsr_file_name}
    COAM.setup admin
    ${ret}    COAM.Update Software    ${OUTPUTDIR}/${bsr_file_name}
    COAM.teardown admin

Download and Modify Vendor Files and perform commissioning
    [Arguments]    ${scf}
    ${oam_alias}=    connect.Setup OAM session
    ${vendor_path}=    Set Variable    ${OUTPUT_DIR}/vendor_lte.xml
    fix_vlan_id_in_scfc   input_filepath=${scf}
    admin.download_vendor_file    target_file_name=${vendor_path}    connection=${oam_alias}
    Backup Vendor Files  file_path=${vendor_path}
    Modify Vendor Files
    admin.set_vendor_file  vendor_file=${vendor_path}  connection=${oam_alias}
    ${paths} =    List Directory    ${OUTPUT_DIR}    *MOD*.xml
    admin.perform_commissioning    scf_file=${OUTPUT_DIR}/${paths}[0]
    ...                            connection=${oam_alias}
    ...                            skip_parameter_relation_errors=True
    ...                            timeout=600
    connect.Teardown OAM session    connection=${oam_alias}

Backup Vendor Files
    [Arguments]    ${file_path}
    Copy File    ${file_path}  ${file_path}.orig

Modify Vendor Files
    ${filter_criteria}=    Create Dictionary
    ...  xEc=20

    ${data_to_be_modified}=    Create Dictionary
    ...  xEc=14

    ${path_in_xml}=  vendor_file_modifier.get_xml_path_for_xec
    vendor_file_modifier.modify_vendor_file
    ...  filter_criteria=${filter_criteria}
    ...  data_to_be_modified=${data_to_be_modified}
    ...  path_to_reference_vendor_file=${OUTPUT_DIR}/vendor_lte.xml
    ...  path_to_modified_vendor_file=${OUTPUT_DIR}/vendor_lte.xml
    ...  xml_path=${path_in_xml}
