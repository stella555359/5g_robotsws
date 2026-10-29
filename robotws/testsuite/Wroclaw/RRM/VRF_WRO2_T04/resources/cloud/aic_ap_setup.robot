*** Settings ***
Documentation   Setup keywords for AP+CLOUD

Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/cloud/aic_commissioning.py
Library    ta5g_iphy
Library    ta5g_cell_operations
Library    ta5g_testline_management

*** Keywords ***
Prepare Full Ap Aic Setup
    [Arguments]    ${ap_config}    ${vdu_scf}    ${vcu_scf}    ${egate_config}    ${alias}
    Run Keywords    Update And Put Iphy Xml Aic    input_filepath=${ap_config}
    ...    AND    Call Ap Console Reboot
    ...    AND    Fix SerialNumberPlanned And ProdCodePlanned And Send Full Commissioning Vdu With Given Scf Filepath
    ...               scfc_filepath=${vdu_scf}
    ...               output_dirpath=${OUTPUT_DIR}
    ...    AND    Perform Commissioning Vcu Aic    path_to_plan_file=${vcu_scf}
    ...    AND    Check Radios Availability Aic     timeout=1800
    ...    AND    Wait For F1 Links To Be Available Aic
    ...    AND    Start Default Logging    output_dirpath=${OUTPUT_DIR}/SetupLogs_${alias}
    ...    AND    Reach Onair    lua_cfg=${egate_config}
    ...    AND    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/SetupLogs_${alias}
