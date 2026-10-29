*** Settings ***
Documentation
...     description:    Keywords for test cases for the CB007962-B feature.

Resource   ../../../common_resources/netact/netact_operations.robot

Library    ../../../common_resources/netact/netact_operations.py
Library    ../Resources/audit_trail_logs.py
Library    ../Resources/test_specific_keywords.py

*** Keywords ***
Get cleaned ATL logs
    [Arguments]  ${atl_path}  ${logs_age_in_s}=300  ${output_file}=filtered_cleaned_logs.txt  ${enable_filtering}=${FALSE}
    ${netact_conn}=  netact_operations.Connect to NetAct
    get_audit_trail_logs  ${netact_conn}                adaptation_version=MRBTS-${BTS_ID}
    ...                   path=${atl_path}
    netact_operations.Disconnect from NetAct  ${netact_conn}
    ${atl_logs}=  recreate_trail_logs_with_filtering  trail_log_file=${atl_path}  output_file=${output_file}
    Run keyword if  ${enable_filtering} == ${TRUE}  ${atl_logs}=  filter_trail_logs_for_date  trail_log_file=${atl_logs}
    ...                                                                                       logs_age_in_s=${logs_age_in_s}
    ...                                                                                       output=${output_file}
    [Return]  ${atl_logs}

Create ssh keys and upload on bts
    [Arguments]  ${connection}  ${dn}
    ${private_key_path}=  generate_ssh_login_keys
    ${public_key_path}=  Set variable  ${private_key_path}.pub
    ${public_key_value}=  get_public_key_value  public_key_path=${public_key_path}
    set_ssh_public_key_on_bts   connection=${connection}   value=${public_key_value}   dist_name=${dn}
    [Return]  ${private_key_path}

Change parameter to value via Netact
    [Arguments]  ${dist_name}   ${parameter}   ${value}    ${connection}    ${scf}
    &{param}=                   Create dictionary  ${parameter}  ${value}
    Log                         Changing ${parameter} parameter to "${value}"    console=True
    Set parameter using netact  dist_name=${dist_name}
    ...                         param_changes=${param}
    ...                         path_to_scf=${scf}
    ...                         na_instance=${connection}
    Sleep                       time_=30s                  reason=Waiting for delta commissioning to finish....
