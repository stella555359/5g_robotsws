*** Settings ***

Resource     ../../resources/5G_SW_WRO_Keywords.robot
Library      ta5g_tshark
Library      ta5g_egate
Library      ta5g_pm_counters
Library      ta5g_admin_operations
Library      ta5g_enb
Library      ta5g_iphy
Library      ta5g_testline_management
Variables    ta5g_global_var

*** Keywords ***

Invoke Error Indication on NGSetupRequest
    Execute Egate Command    cmd=amf_ng_setup_param id=1 gnb=2 action=error_indication

Invoke Error Indication On RAN Configuration Update
    Execute Egate Command    cmd=amf_ran_config_update_param id=1 gnb=2 action=error_indication

Invoke NG Full Reset By Breaking Sctp On F1 Interface
    Execute Enb Command    cmd=ip6tables -t filter -A OUTPUT -p sctp --dport 38472 -j DROP

Restore Sctp On F1 Interface
    Execute Enb Command    cmd=ip6tables -t filter -D OUTPUT -p sctp --dport 38472 -j DROP

Change Amf Name
    ${new_amf_name} =    Generate Random String    50    [NUMBERS][LETTERS]()+,-.?:/=
    Set Suite Variable    ${new_amf_name}
    Execute Egate Command    cmd=amf_config_update id=1 name=${new_amf_name}

Invoke Error Indication on AMF Configuration Update Acknowledge
    Execute Egate Command    cmd=amf_config_update_param id=1 gnb=2 action=error_indication
    Change Amf Name
