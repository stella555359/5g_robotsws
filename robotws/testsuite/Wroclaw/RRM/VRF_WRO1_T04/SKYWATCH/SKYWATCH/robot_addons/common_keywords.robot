*** Settings ***
Documentation    :copyright: Nokia
...              :author: Mateusz Bilewicz
...              :contact: mateusz.bilewicz@nokia.com

# Library    OperatingSystem
Library    ute_wtssim
Library    ute_fsmaccess
Library    ta5g_setups_and_teardowns
Library    ta5g_commissioning
Library    ta5g_iphy
Library    ta5g_cell_operations
Library    ta5g_egate
Library    ta5g_enb
Library    ta5g_pm_counters


Library    testsuite/Wroclaw/RRM/VRF_WRO1_T04/SKYWATCH/SKYWATCH/core/scout/kpi_reports.py
Library    testsuite/Wroclaw/RRM/VRF_WRO1_T04/SKYWATCH/SKYWATCH/core/scout/aggr_comparator_analyzer.py
Variables  common_variables.py

*** Keywords ***
Show Gnb Versions
    Log    ${tar_prefix}


Get Actual Software Version
    ${active_sw_tuple}=    Get Software Info
    Log To Console    ${active_sw_tuple}
    Set Global Variable    ${active_sw}    ${active_sw_tuple}[0]
    IF    '${active_sw}' == 'failed'
        Fail
    END


Get Software Version And Check If Update Is Needed
    [Arguments]    ${target_sw_package}
    [Documentation]   Checks if active sw is equal to requested in Robot command
    Wait Until Keyword Succeeds    10 min    5 sec    Get Actual Software Version
    ${update_needed}=    Set Variable If    '${active_sw}' == '${target_sw_package}'    False    True
    RETURN    ${update_needed}


Download And Activate Sw
    [Arguments]    ${update_needed}    ${target_sw_package}
    IF    ${update_needed}
        ${downloaded_sw}=    Download If Not Exist  version=${target_sw_package}  sw_path=${DOWNLOAD_PATH}
        Activate Software    sw_path=${downloaded_sw}
        Wait Until Keyword Succeeds    10 min    5 sec    Get Actual Software Version
        ${sw_versions_equal}=    Set Variable If    '${active_sw}' == '${target_sw_package}'    True    False
    END


Update SCF and Iphy
    Wait For Update Possible
    Update Iphy Configuration And Modify Swconfig    iphy_xml_filepath=${IPHY_CONFIG_FILE_NAME}
    Fix And Send Full Commissioning With Given Scf Filepath    scfc_filepath=${SCF_FILEPATH}
    Check Radios Availability


Reach Onair And Wait For Cells Activation
    Check Radios Availability
    Reach_Onair_Without_Confirmation    lua_cfg=${CONFIG_PATH}/cfg_skywatch_tmo_65.lua    x2_link_start=False
    ${list_of_cells_ids}=    Get List Of All Cells Ids
    Wait Until Cells Are Onair    timeout=${240}    enb_id=${2}    cell_ids=${list_of_cells_ids}


Setup X2
    ${x2_regex}=    Return X2 Regex
    Wait For Egate Console Output    expected_message=${x2_regex}    timeout=${100}


Shutdown Egate Edaemon
    Execute Egate Cmd    cmd=${RESET_CMD}
    Teardown Egate
    Teardown All Aliases For Egate


Prepare KPI Reports
    Connect To Scout    ${api_key}
    Sleep    15min
    Prepare Kpi Report    template_id=${MANDATORY_KPIS_26R3}
    Prepare Kpi Report    template_id=${ADDITIONAL_KPIS_26R3}
    Prepare Kpi Report    template_id=${ADDITIONAL_COUNTERS_26R3}
    Prepare Kpi Comparator Report
    Run Kpi Comparator