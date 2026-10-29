*** Settings ***

Resource     ../../resources/5G_SW_WRO_Keywords.robot
Library      ta5g_tshark
Library      ta5g_egate
Library      ta5g_enb
Library      ta5g_testline_management
Library      ta5g_cell_operations
Library      ta5g_pm_counters
Library      ta5g_setups_and_teardowns
Library      ta5g_iphy
Variables    ta5g_global_var

*** Keywords ***

Send AMF Configuration Update With AMF TNLAssociationToRemoveList
    Execute Egate Command    cmd=amf_config_update id=1 remove_tnla=192.168.0.1:ue

Send RAN Configuration Update Failure With Retries And Time To Wait
    Execute Egate Command    cmd=amf_ran_config_update_param id=1 action=force_failure ntimes=indefinite time_to_wait=2

Attach UE And Trigger NG Reset With Valid And Invalid UE
    Attach Ue    ue_id=1    pass_regexp=UE performed Registration type INITIAL_REGISTRATION
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Attach Ue    ue_id=2    pass_regexp=UE performed Registration type INITIAL_REGISTRATION
    Establish Pdu Session    ue_id=2    pdu_id=1    gw_id=2
    sleep    10
    Execute Egate Command    cmd=link_ng_reset by=amf:1 ue=2 inject_invalid_ue_id=on
