*** Settings ***

Resource     taf/rfrl/procedures/resources/robot/utilities.robot
Variables    ./ecpri_parameters.py


*** Keywords ***
eCPRI sync generic startup at RAU
    [Arguments]    ${dist_name}    ${abbr_group_name}    ${interval}=5min    ${measurments}=1
    ...    ${pm_interval_init}=5min
    Reset gNB
    Wait Until Keyword Succeeds     900 sec     15 sec   Verify gNB is onAir
    Save origin interval value    dist_name=${dist_name}    abbr_group_name=${abbr_group_name}
    Change PM Interval to    dist_name=${dist_name}   abbr_group_name=${abbr_group_name}    interval=${interval}
    gnb_counter.Wait for PM measurements    interval=${interval}    measurements=${measurments}
    gnb_counter.Validate intervals and values counters eCPRI    interval=${interval}    measurements=${measurments}
    Verify gNB Configuration Parameters Have Expected Values    param_dict=&{eCPRI_parameters}
    [Teardown]    Change PM Interval to    dist_name=${dist_name}    abbr_group_name=${abbr_group_name}    interval=${pm_interval_init}
