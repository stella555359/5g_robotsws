*** Settings ***
Documentation    :copyright: Nokia
...              :author: Alok Shastri, Pawel Cebula
...              :contact: alok.shastri@nokia.com, pawel.1.cebula@nokia.com


Variables    python/credentials.py

Library      taf.gnb.oam.coam.admin    WITH NAME    coam.admin
Library      Collections
Library      python/software_version_handler.py     WITH NAME    wro_sweng_soft_ver


*** Keywords ***
Check Cell is on Air
    Log to console    Checking gNB 'On Air' state
    ${BTS_connection}=     coam.admin.Connect To    ${gNB_CLASSICAL_OAM_IP}
    ${status}=     coam.admin.get_bts_statuses     connection=${BTS_connection}
    ${value} =    Get From Dictionary    ${status}    proceduralState
    Should Contain    ${value}     OnAir
    coam.admin.Teardown    connection=${BTS_connection}

Reset gNB
    [Arguments]    ${timeout}=5m    ${wait_for_reconnection}=${true}
    Log to console    Triggering reset site of gNB...
    ${BTS_connection}=     coam.admin.Connect To    ${gNB_CLASSICAL_OAM_IP}
    coam.admin.Reset Site    timeout=${timeout}    connection=${BTS_connection}
    ...                      wait_for_reconnection=${wait_for_reconnection}
    coam.admin.Teardown    connection=${BTS_connection}

Setup coam connection
    ${global_coam_connection_handler}=    coam.admin.Connect To
    Set Suite Variable    ${global_coam_connection_handler}

Get counter value
    [Arguments]    ${BTS_or_TRS}    ${counter}    ${connection}
    Log to console    Gathering value of counter: "${${counter}.name}"
    ${counters_info} =    coam.admin.get_counters_info    connection=${connection}    timeout=120
    ${counter_groups} =    Get From Dictionary    ${counters_info}    ${BTS_or_TRS}
    ${counter_group_keys} =    Split String    ${${counter}.Full_path}    /
    ${counter_groups_length} =    Get Length    ${counter_group_keys}
    Remove From List    ${counter_group_keys}    ${counter_groups_length-1}

    :FOR    ${group}    IN     @{counter_group_keys}
    \    ${counter_groups} =    Get From Dictionary    ${counter_groups}    ${group}

    ${counter_values} =    Get From Dictionary    ${counter_groups}    ${${counter}.id}
    ${key_list} =     Get Dictionary Keys    ${counter_values}
    Reverse List    ${key_list}
    ${latest_value} =    Get From Dictionary    ${counter_values}    ${key_list[0]}
    [return]    ${latest_value}

Get cell status
    [Arguments]     ${status_holder}
    &{cell_statuses} =    wro_sweng_coam_admin.Get parameter value    connection_handler=${global_coam_connection_handler}
    ...    manged_object=NRCELL_R    parameter=stateInfo
    ${cell_status} =    Get From Dictionary    ${cell_statuses}    ${status_holder}
    [return]    ${cell_status}

Get fbb status
    [Arguments]     ${status_holder}
    ${fbb_info_dict_list} =    coam.admin.get_fbb_info    timeout=90    connection=${global_coam_connection_handler}
    ${fbb_statuses_dict} =    Get From List     ${fbb_info_dict_list}    0
    ${fbb_statuses} =    Get From Dictionary    ${fbb_statuses_dict}    status
    ${fbb_status} =    Get From Dictionary    ${fbb_statuses}    ${status_holder}
    [return]    ${fbb_status}

Get frm status
    [Arguments]     ${status_holder}
    ${frm_info_dict_list} =    coam.admin.get_frm    timeout=90    connection=${global_coam_connection_handler}
    ${frm_statuses_dict} =    Get From List     ${frm_info_dict_list}    0
    ${frm_statuses} =    Get From Dictionary    ${frm_statuses_dict}    status
    ${frm_status} =    Get From Dictionary    ${frm_statuses}    ${status_holder}
    [return]    ${frm_status}

Get software version
    ${sw_version} =    coam.admin.Get sw version    timeout=90    connection=${global_coam_connection_handler}
    Should Not Be Empty    ${sw_version}    msg=Taf function Get sw version returned empty response!
    ${sw_version} =    Remove String Using Regexp    ${sw_version}   5G.*_GNB_
    ${sw_version} =    wro_sweng_soft_ver.Prepare software version    ${sw_version}
    [return]    ${sw_version}
