*** Settings ***
Documentation    Test Case specific keywords for Transversal Robustness

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]



*** Keywords ***


Loop MUE Calls ${number_of_interations} times
    ${non_attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=sa    with_auto_attach=${FALSE}
    ${non_attached_ues_list}=  get dictionary keys  ${non_attached_ues_dict}
    FOR  ${iteration}  IN RANGE  0  ${number_of_interations}
        log to console   ======== Iteration number ${iteration} in progress ========
        Run SA Attach Scripts    ${non_attached_ues_dict}   ignore_auto_attach=${True}
        Call MUE                 ${non_attached_ues_list}
        Detach 5G UE             ${non_attached_ues_dict}   ignore_auto_attach=${True}
    END


Call MUE
    [Arguments]  ${non_attached_ues_list}
    log to console  linter warning unused argument: ${non_attached_ues_list}
    Start Traffic From Traffic List  ${scenario_name}
    ${start_time}=  tools.get_current_time
    ${traffic_duration}=  template.get_max_traffic_length  ${scenario_name}
    Stop Traffic From Traffic List  ${scenario_name}  ${start_time}  ${traffic_duration}

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
