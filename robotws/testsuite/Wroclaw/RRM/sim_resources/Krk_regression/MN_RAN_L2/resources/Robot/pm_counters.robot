*** Settings ***

Documentation
...    author: Mateusz Pajor, Damian Piasecki, Szymon Lange
...    maintainer:  Mateusz Pajor, Damian Piasecki, Szymon Lange
...    team: I_5G_SW_MMW_PLKRK_02
...    contact: mateusz.pajor@nokia.com
...    description: PM counters related keywords

Library    taf.sbts.oam.coam.admin   WITH NAME    admin
Library    taf.config.scf            WITH NAME    scf
Library    ta5g_cell_operations
Library    testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.pm_counters    WITH NAME    pm_counters
Library    testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.common_gnb

*** Keywords ***
Verify if incremented
    [Arguments]    ${prev_counters}    ${current_counters}
    Log to console  Start verification
    Run Keyword  Verify if counters value is incremented  ${prev_counters}  ${current_counters}

Check PM Counters For All Cells
    [Arguments]    ${counter_list}    ${forced_cells}=None
    [Documentation]      Check if counters changed correctly
    ...                  Creation Date: 23.06.2021
    ...                  Modified Date:
    ...                  Last Modified by: szymon.lange@nokia.com

    @{cell_list}=    Run Keyword If    ${forced_cells} is None    Get List Of All Cells Ids
    ...   ELSE   Set Variable    ${forced_cells}
    Check Pm    cells=@{cell_list}    counter_list=${counter_list}

Wait Until The Next Measurement Period Starts
    [Arguments]    ${gnb_id}=0    ${additional_time}=30    ${console}=False
    [Documentation]      This keyword could be used as wait for current Measurement Period stops
    ...                  Creation Date: 16.09.2021
    ...                  Modified Date:
    ...                  Last Modified by: mateusz.pajor@nokia.com
    ...
    ...    :param gnb_id: (default=0) Id/Number of gNB
    ...    :param additional_time: (default=30) additional seconds for waiting

    ${meas_period}=    Get Measurement Period from GNB    gnb_id=${gnb_id}
    pm_counters.Wait next meas period
    ...    meas_period=${meas_period}
    ...    add_time=${additional_time}
    ...    with_console_output=${console}
    ${start_time}=    DateTime.Get Current Date    result_format=%H:%M:%S
    BuiltIn.Log    Start Time Of Measurement Period = ${start_time}    level=DEBUG
    ${start_time}=    DateTime.Convert Time    ${start_time}    result_format=timedelta
    &{P_START_TIME}=    Create Dictionary    gnb_${gnb_id}=${start_time}
    Set Test Variable    ${P_START_TIME}

Wait Until The Current Measurement Period Stops
    [Arguments]    ${gnb_id}=0    ${additional_time}=30    ${console}=False
    [Documentation]
    ...                  Creation Date: 16.09.2021
    ...                  Modified Date:
    ...                  Last Modified by: mateusz.pajor@nokia.com
    ...    :param gnb_id: (default=0) Id/Number of gNB
    ...    :param additional_time: (default=30) additional seconds for waiting

    ${start_time}=    Get Start Time from Test    gnb_id=${gnb_id}
    ${meas_period}=    Get Measurement Period from GNB    gnb_id=${gnb_id}
    ${current_time}=    DateTime.Get Current Date    result_format=%H:%M:%S
    ${current_time}=    DateTime.Convert Time    ${current_time}    result_format=timedelta
    ${time_delay}=    Evaluate    ${current_time.total_seconds()}-${start_time.total_seconds()}
    Return from Keyword If    ${time_delay} >= ${meas_period}
    pm_counters.Wait next meas period
    ...    meas_period=${meas_period}
    ...    add_time=${additional_time}
    ...    with_console_output=${console}

Get Measurement Period from GNB
    [Arguments]    ${gnb_id}=0
    [Documentation]      TODO: Check if this is needed after migration
    ...                  Creation Date: 16.09.2021
    ...                  Modified Date:
    ...                  Last Modified by: mateusz.pajor@nokia.com
    ...    :return: Measurement period in second

    ${meas_period}=    Get Variable Value    ${P_MEAS_PERIOD.gnb_${gnb_id}}
    Run Keyword If    '${meas_period}'=='None'
    ...    Fetch Measurement Period from SCF    gnb_id=${gnb_id}
    [Return]    ${P_MEAS_PERIOD.gnb_${gnb_id}}

Fetch Measurement Period from SCF
    [Arguments]    ${gnb_id}=0    ${scf_path}=/tmp    ${file_name}=scf.xml
    [Documentation]      Collect Measurement Period from SCF
    ...                  Creation Date: 16.09.2021
    ...                  Modified Date:
    ...                  Last Modified by: mateusz.pajor@nokia.com

    admin.Setup Admin    alias=measure
    admin.Get Current Scf File    local_dir_path=${scf_path}    file_name=scf.xml    timeout=30    connection=measure
    admin.Teardown Admin    alias=measure
    scf.Load SCF    file_path=${scf_path}/${file_name}
    ${meas_period}=    scf.Get Value from SCF    p_name=reportingIntervalPm
    scf.Save SCF    file_path=${scf_path}/${file_name}
    ${meas_period}=    Evaluate    int(${meas_period[:-3]}) * 60
    &{P_MEAS_PERIOD}=    Create Dictionary    gnb_${gnb_id}=${meas_period}
    Set Suite Variable    ${P_MEAS_PERIOD}

Get Start Time from Test
    [Documentation]      TODO: Check if this is needed after migration
    ...                  Creation Date: 16.09.2021
    ...                  Modified Date:
    ...                  Last Modified by: mateusz.pajor@nokia.com
    ...
    ...    :return: start time from keyword "Wait until the next Measurement Period starts"

    [Arguments]    ${gnb_id}=0
    ${start_time}=    Get Variable Value    ${P_START_TIME.gnb_${gnb_id}}
    ${msg}=    Catenate      No start time found,
    ...    use 'Wait until the next Measurement Period starts' first,
    ...    before calling 'Wait until the current Measurement Period stops'
    Run Keyword If    '${start_time}'=='None'
    ...    Fail    ${msg}
    [Return]    ${start_time}
