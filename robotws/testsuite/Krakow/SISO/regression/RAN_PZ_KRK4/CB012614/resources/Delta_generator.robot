*** Settings ***
Documentation
...    author: Marcin Szlapa
...    contact: marcin.szlapa@nokia.com
...    Description: SCF delta generator keyword

Library     taf.config.scf.calculations.CoamScfCalculator
Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

*** Variables ***
${scf_path}    ${OUTPUTDIR}/generated_scf/

*** Keywords ***
Generate delta scf
    [Arguments]     ${primary_scf_prefix}    ${secondary_scf_prefix}
    ...             ${scf_path}=${scf_path}   ${asir_hub}=${False}
    Perform Full Commissioning and Wait for onAir    prefix_tag=${primary_scf_prefix}    asir_hub=${asir_hub}
    gnbbbu.get_bts_configuration_file    local_dir=${scf_path}     filename=primary_scf.xml
    Perform Full Commissioning and Wait for onAir    prefix_tag=${secondary_scf_prefix}    asir_hub=${asir_hub}
    gnbbbu.get_bts_configuration_file    local_dir=${scf_path}     filename=secondary_scf.xml
    calculate_delta_scf    ${scf_path}primary_scf.xml   ${scf_path}secondary_scf.xml     ${scf_path}delta_1.json
    calculate_delta_scf    ${scf_path}secondary_scf.xml   ${scf_path}primary_scf.xml     ${scf_path}delta_2.json
