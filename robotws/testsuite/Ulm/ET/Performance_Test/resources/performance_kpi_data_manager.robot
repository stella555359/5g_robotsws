*** Settings ***
Documentation    Replacement for LTEPAT

Library    python/kpi/kpi_data_manager.py


*** Keywords ***
Get KPI Dictionary
    [Arguments]    ${kpi_list}=${None}    ${pm_counter_directory}=${None}    ${active_cells}=${None}    ${scf}=${None}
    ${TS_UPDATED_SCF}    Get Variable Value    ${TS_UPDATED_SCF}    ${False}
    IF    ${active_cells} is ${None}
        ${active_cells}    Create List   all
    END
    IF    ${pm_counter_directory} is ${None}
        Log    Get KPI Dictionary: pm_counter_directory not supplied, fetching from globals instead   level=DEBUG
        ${pm_counter_directory}    Get Variable Value    ${T_PM_FILES_LOCATION_default_traffic}    ${False}
        IF    "${pm_counter_directory}"=="${False}"
            Log    Get KPI Dictionary: missing pm_counter_directory    level=ERROR
            RETURN   ${none}
        END
    END
    IF    ${scf} is ${None} and """${TS_UPDATED_SCF}"""!="${False}"
        Set Variable    ${TS_UPDATED_SCF}
    END
    ${kpi_dictionary}    kpi_data_manager.Get KPI Dictionary    ${pm_counter_directory}
    ...                                                         kpi_list=${kpi_list}
    ...                                                         active_cells=${active_cells}
    ...                                                         scf=${scf}
    RETURN    ${kpi_dictionary}
