*** Settings ***
Documentation    This contains basic dss related keywords which are needed to run the Airphone TC.
...              :author Rakshitha

Library    String
Library    ute_wtssim
Library    OperatingSystem

Resource   ../Variables/Common_Variables.robot

*** Variables ***
${egate_console_log}    /opt/wts/latest/egate_console.log


*** Keywords ***
Update cell parameter
    [Arguments]    ${enb_id}    &{kwargs}
    ${mandatory_args}    Catenate    SEPARATOR=${SPACE}    enb=${enb_id}
    ${final_args}    Set Final args list    ${mandatory_args}    &{kwargs}
    Execute Egate Command    cmd=enb_cell_param ${final_args}

Enable Cell DSS Feature
    [Arguments]    ${cell_id}    ${enb_id}    &{kwargs}
    ${mandatory_args}    Catenate    SEPARATOR=${SPACE}    id=${cell_id}    enb=${enb_id}
    ${final_args}    Set Final args list    ${mandatory_args}    &{kwargs}
    Execute Egate Command    cmd=enb_cell_dss_feature ${final_args}    timeout=1s

Update DSS cell parameter
    [Arguments]    ${enb_id}    &{kwargs}
    ${mandatory_args}    Catenate    SEPARATOR=${SPACE}   enb=${enb_id}
    ${final_args}    Set Final args list    ${mandatory_args}    &{kwargs}
    Execute Egate Command    cmd=enb_cell_dss_param ${final_args}

Enabling DSS Feature Flag
    [Arguments]    ${enb_id}    &{kwargs}
    ${mandatory_args}    Catenate    SEPARATOR=${SPACE}    id=${enb_id}
    ${final_args}    Set Final args list    ${mandatory_args}    &{kwargs}
    Execute Egate Command    cmd=enb_dss_param ${final_args}

Update Common Ressource Manager parameters
    [Arguments]    ${enb_id}    &{kwargs}
    ${mandatory_args}    Catenate    SEPARATOR=${SPACE}    id=${enb_id}
    ${final_args}    Set Final args list    ${mandatory_args}    &{kwargs}
    Execute Egate Command    cmd=enb_crm_param ${final_args}

Configure dss partnership
    [Arguments]    ${enb_id}    ${cell_id}    ${dss_peer}
    ${mandatory_args}    Catenate    SEPARATOR=${SPACE}    enb=${enb_id}    cell=${cell_id}    dss_peer=${dss_peer}
    ${final_args}    Set Final args list    ${mandatory_args}
    Execute Egate Command    cmd=enb_dss_configure_partnership ${final_args}

Set CRM cell resource reservation for DL and UL
    [Arguments]    ${enb_id}    ${cell_id}    ${tgt_enb}    ${tgt_cell}    &{kwargs}
    ${mandatory_args}    Catenate    SEPARATOR=${SPACE}    enb=${enb_id}    cell=${cell_id}    tgt_enb=${tgt_enb}    tgt_cell=${tgt_cell}
    ${final_args}    Set Final args list    ${mandatory_args}    &{kwargs}
    Execute Egate Command    cmd=enb_crm_cell_resource_reservation ${final_args}

Establish a DSS partnership between two cells
    [Arguments]    ${enb_id}    ${cell_id}    ${tgt_enb}    ${tgt_cell}
    ...    ${pass_regexp}=EN DSS UL Cell Subcarrier Resource Coordination success on remote NE    ${timeout}=30    &{kwargs}
    ${mandatory_args}    Catenate    SEPARATOR=${SPACE}    enb=${enb_id}    cell=${cell_id}    tgt_enb=${tgt_enb}    tgt_cell=${tgt_cell}
    ${final_args}    Set Final args list    ${mandatory_args}    &{kwargs}
    Execute Egate Command    cmd=enb_dss_establish_partnership ${final_args}    pass_regexp=${pass_regexp}   timeout=${timeout}

Configure cells for DSS DL Cell Subframe Resource Coordination
    [Arguments]    ${cell_id}    ${enb_id}    &{kwargs}
    ${mandatory_args}    Catenate    SEPARATOR=${SPACE}    cell=${cell_id}    enb=${enb_id}
    ${final_args}    Set Final args list    ${mandatory_args}    &{kwargs}
    Execute Egate Command    cmd=enb_dss_dl_cell_resource_reservation ${final_args}

Reset Reservation for DSS3
    [Arguments]    ${cell_id}    ${enb_id}    ${dir}=dl
    ${dl_command}    Set Variable    enb_dss_dl_cell_resource_reservation enb=${enb_id} cell=${Cellid} reset
    ${ul_command}    Set Variable    enb_dss_ul_cell_resource_reservation enb=${enb_id} cell=${Cellid} reset
    Run Keyword If    "${dir}" == "dl"    ute_wtssim.Execute Egate Command    ${dl_command}
    ...    ELSE    ute_wtssim.Execute Egate Command    ${ul_command}

Configure cells for DSS UL Cell Subframe Resource Coordination
    [Arguments]    ${cell_id}    ${enb_id}    &{kwargs}
    ${mandatory_args}    Catenate    SEPARATOR=${SPACE}    cell=${cell_id}    enb=${enb_id}
    ${final_args}    Set Final args list    ${mandatory_args}    &{kwargs}
    Execute Egate Command    cmd=enb_dss_ul_cell_resource_reservation ${final_args}

Request a cell resource coordination to CRM
    [Arguments]    ${enb_id}    ${cell_id}    ${tgt_enb}    ${tgt_cell}
    ...    ${pass_regexp}=EN DSS DL Cell Resource Area Coordination*    ${timeout}=30    &{kwargs}
    ${mandatory_args}    Catenate    SEPARATOR=${SPACE}    enb=${enb_id}    cell=${cell_id}    tgt_enb=${tgt_enb}    tgt_cell=${tgt_cell}
    ${final_args}    Set Final args list    ${mandatory_args}    &{kwargs}
    Execute Egate Command and wait for data    cmd=enb_dss_cell_resource_coordination ${final_args}    pass_regexp=${pass_regexp}
    ...    timeout=${timeout}

Displays per Cell CRM related status
    [Arguments]    ${enb_id}    &{kwargs}
    ${mandatory_args}    Catenate    SEPARATOR=${SPACE}    enb=${enb_id}
    ${final_args}    Set Final args list    ${mandatory_args}    &{kwargs}
    Execute Egate Command    cmd=enb_crm_status ${final_args}

Request a cell DSS resource allocation to the CRM
    [Arguments]    ${enb_id}    ${cell_id}    ${tgt_enb}    ${tgt_cell}    ${pass_regexp}    ${timeout}=30    &{kwargs}
    ${mandatory_args}    Catenate    SEPARATOR=${SPACE}    enb=${enb_id}    cell=${cell_id}    tgt_enb=${tgt_enb}    tgt_cell=${tgt_cell}
    ${final_args}    Set Final args list    ${mandatory_args}    &{kwargs}
    Execute Egate Command and wait for data    cmd=enb_dss_resource_allocation ${final_args}    pass_regexp=${pass_regexp}
    ...    timeout=${timeout}