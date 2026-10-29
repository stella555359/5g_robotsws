*** Settings ***
Documentation
...    copyright: Nokia

Force Tags    CLOUD_5G_I_LO_AP_LOOO    CRT    SBTS00    RAN_5G    RAN_5G_FDD

Resource    ../resources/5G_SW_WRO_Keywords.robot
Resource    ./resources/CB012528_keywords.robot
Library     ../resources/Python/webem_alarms.py
Resource     ../resources/configuration_id.robot

Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
...                            iphy_xml_filepath=${CURDIR}/config/iphy_12x20_4DL4UL.xml
...            AND             CB012528 Setup
...            AND             Update SCF And Perform Commissioning    scf_file_name=scf_B_C5_12x20_4DL4UL.xml
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/setup_12x20_99UE.lua

Suite Teardown    Run Keywords    Print Active Alarms
...               AND             admin.Teardown All Aliases For Admin
...               AND             Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
CB012528_B_C5_Adjust_cell_load_to_trigger_dynamic_overload_control_on_SNF
    ${subpool_dict}    Check L2 Subpool Assignment    cells_amount=12
    Check If Selected Cells Are Mapped To The Same L2Subpool    subpool_dict=${subpool_dict}
    Attach Multiple UEs And Start Traffic TC CB012528 B C5
    Verify Avg Tput For Multiple UEs    last_ue=260    dir=dl    expected_tput=2    first_ue=100
    Verify Avg Tput For Multiple UEs    last_ue=260    dir=ul    expected_tput=2    first_ue=100
    ${date}    Collect TTI And Convert To CSV
    ...    duration=1
    ...    conversion_filter=dl*
    ...    excel_csv_options=-d dl
    Check DL Overload Control Adjustment    date=${date}    cell_id=50
    Check DL Overload Control Adjustment    date=${date}    cell_id=54
    Check DL Overload Control Adjustment    date=${date}    cell_id=57
    Check DL Overload Control Adjustment    date=${date}    cell_id=59    overloaded=${False}
    [Teardown]    Send Configuration ID To Scout
