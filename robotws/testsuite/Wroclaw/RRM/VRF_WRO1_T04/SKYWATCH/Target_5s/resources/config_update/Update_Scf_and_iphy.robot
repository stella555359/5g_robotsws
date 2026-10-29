*** Settings ***
Documentation    :copyright: Nokia
...              :author: Mateusz Bilewicz
...              :contact: mateusz.bilewicz@nokia.com
Library    ute_wtssim
Library    ute_fsmaccess
Library    ta5g_setups_and_teardowns
Library    ta5g_commissioning
Library    ta5g_iphy
Library    Process
Library    ta5g_egate


*** Variables ***
${skywatch_path}=  ${EXECDIR}/testsuite/Wroclaw/RRM/VRF_WRO1_T04/SKYWATCH/Target_5s
${config_path}=  ${skywatch_path}/config_65
${iphy_config_file_name}=  ${skywatch_path}/config_65/iphy_skywatch.xml
${scf_filepath}=  ${skywatch_path}/config_65/UTE_129_skywatch.xml


*** Test Cases ***
Update SCF and Iphy
    [Documentation]   Fixes SCF, update iphy.xml and apply. Then waiting for TL to OnAir.
    Update Iphy Configuration And Modify Swconfig    iphy_xml_filepath=${iphy_config_file_name}
    Fix And Send Full Commissioning With Given Scf Filepath    scfc_filepath=${scf_filepath}
    Check Radios Availability
    Reach_Onair_Without_Confirmation    lua_cfg=${config_path}/cfg_skywatch_tmo_65.lua

Run Skywatch Main Script
    Run Process    python  ${skywatch_path}/resources/asyncio_scenario_runner.py  stdout=STDOUT  stderr=STDERR
