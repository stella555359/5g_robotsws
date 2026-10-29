*** Settings ***
Documentation   :copyright: Nokia
...             :authors: Marcin Holowinski
...             :contact: marcin.holowinski@nokia.com

Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Library     taf.ul.ettf.retry_context
Library     ta5g_iphy
Library     ta5g_commissioning
Library     taf.ul.ettf.setups
Library     ta5g_enb
Library     ta5g_testline_management
Library     ../resources/custom_config_yaml_to_commissioning.py

*** Keywords ***
Perform Full Commissioning Using Custom Config Yaml
    Get Testline Pdu Details    testline_config_index=${0}    # For ${tl} variable
    ${scfc_filepath}    ${iphy_filepath}     ${swconfig}    Get Filepaths From Custom Config Yaml
    Run Keyword If    "${swconfig}" != "${NONE}"    Put Swconfig File    ${swconfig}
    ${fixed_scfc_filepath}     Run Keyword If
    ...    "${scfc_filepath}" != "${NONE}"         Fix Vlan Id In Scfc    ${scfc_filepath}
    With Retry Context    3
    ...  Run Keyword If  "${iphy_filepath}" != "${NONE}"    Update And Put Iphy Xml    input_filepath=${iphy_filepath}
    ...  AND  Run Keyword If    "${scfc_filepath}" != "${NONE}"     Send Full Commissioning      ${fixed_scfc_filepath}
