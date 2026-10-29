*** Settings ***
Documentation    :copyright: Nokia

Force Tags    CLOUD_5G_I_LO_AP_LOOO    CRT    SBTS00    RAN_5G    RAN_5G_FDD

Resource    ../resources/5G_SW_WRO_Keywords.robot
Resource    ./resources/CB012528_keywords.robot
Library     ../resources/Python/webem_alarms.py
Resource     ../resources/configuration_id.robot

Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
...                            iphy_xml_filepath=${CURDIR}/config/iphy_6x20_4DL4UL.xml
...            AND             CB012528 Setup
...            AND             Update SCF And Perform Commissioning    scf_file_name=scf_B_C1C2_1x20_4DL4UL.xml
...            AND             Delta Preparation For TC CB012528
...            AND             Start Syslog For Enb    log_filename_prefix=syslog    alias=core_id_check
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/setup_6x20_6UE.lua

Suite Teardown    Run Keywords    Print Active Alarms
...               AND             admin.Teardown All Aliases For Admin
...               AND             Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${delta_cell_addition_path}    ${OUTPUT DIR}/delta_cell_addition.json

*** Test Cases ***
CB012528_B_C1_L2PS_UL_and_DL_scheduler_locates_on_separate_CPUcores_SNF
    Check Core Mapping    cell_amount=1
    admin.Setup Admin
    FOR   ${int}    IN RANGE    2    7
        Run Keyword If    ${int}!=2    Modify Json Delta
        ...    input_path=${delta_cell_addition_path}
        ...    output_path=${delta_cell_addition_path}
        ...    cell_id=${int}
        admin.perform_delta_recommissioning
        ...    delta_file=${delta_cell_addition_path}
        ...    skip_parameter_relation_errors=False
        ...    should_activate=True
    END
    Check L2 Subpool Assignment    cells_amount=6
    Check Core Mapping    cell_amount=6
    Stop Syslog    alias=core_id_check
    Attach Multiple UEs And Start Traffic    last_ue=6    dir=dl    mbps=50
    Start Traffic For Multiple UEs           last_ue=6    dir=ul    mbps=50
    Sleep    30s    reason=Wait for throughput stabilization
    Verify Avg Tput For Multiple UEs    last_ue=6    dir=dl    expected_tput=40
    Verify Avg Tput For Multiple UEs    last_ue=6    dir=ul    expected_tput=40
    [Teardown]    Send Configuration ID To Scout
