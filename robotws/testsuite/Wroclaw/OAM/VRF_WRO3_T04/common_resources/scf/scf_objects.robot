*** Settings ***
Documentation   The KW to add the structure to the BTS

Resource    ../admin/admin.robot
Resource    ../commissioning/commissioning.robot
Library     ../admin/admin_utils.py
Library     ./scf_edit.py

*** Keywords ***
Add Structure To SCF
    [Arguments]    ${list_elements}    ${dist_name}=MNL-1/MNLENT-1/TRBLCADM-1     ${structure_name}=remoteSyslogConfig
    ${base_scf_path}=    Download SCF
    ${new_scf_path}=     add_populated_list_to_scf    ${base_scf_path}    ${dist_name}    ${structure_name}    ${list_elements}
    Log  Uploading scf...  console=true
    Commission SCF    scf_file=${new_scf_path}    skip_parameter_relation_errors=False    timeout=900
    Log  Scf uploaded  console=true

Remove Structure From SCF
    [Arguments]    ${dist_name}=MNL-1/MNLENT-1/TRBLCADM-1
    ${base_scf_path}=    Download SCF
    ${new_scf_path}=     delete_list_from_scf    ${base_scf_path}    ${dist_name}    remoteSyslogConfig
    Log  Uploading scf...  console=true
    Commission SCF    scf_file=${new_scf_path}    skip_parameter_relation_errors=False    timeout=900
    Log  Scf uploaded  console=true
