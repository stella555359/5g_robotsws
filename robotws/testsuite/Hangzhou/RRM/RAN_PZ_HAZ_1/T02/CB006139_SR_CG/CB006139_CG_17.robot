*** Settings ***
Documentation
...                 author:  Liu AnAn

Resource    ./Resource_CB006139.robot

Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    CA_RAN_PZ_HAZ_1     CLOUD_5G_I_BOO_AP_LOO

*** Variables ***
${config_tag}  cg_17

*** Test Cases ***
Load_Configuration
    Setup_for_CB006139  config_tag=${config_tag}

CB006139_CG_17
# [1]CB006139_CG_17 IWK15 Interaction with CB013742
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    Setup_eGate_Env
    detach_ue_with_power_off  ue_id=1
    delete_rlq_profile

    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=2
    CB006139_Change_UE_Capability  ue_capability=ue_capability_cg_17  ue_id=1

    # start_log_collection

    attach_ue_and_activate_pdu  ue_id=1
    sleep  5

    start_ue_big_data_traffic  ue_id=1  dl_rate=600  ul_rate=50
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=3

    stop_ue_big_data_traffic  ue_id=1
    sleep  15
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=2

    start_ue_big_data_traffic  ue_id=1  dl_rate=600  ul_rate=50
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=3

    detach_ue_with_power_off  ue_id=1

    # [Teardown]  Teardown_for_CB006139


CB006139_CG_17_Old
# [1]CB006139_CG_17 IWK15 Interaction with CB013742
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    Setup_eGate_Env
    detach_ue_with_power_off  ue_id=1
    delete_rlq_profile

    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=2
    CB006139_Change_UE_Capability  ue_capability=ue_capability_cg_17  ue_id=1

    # start_log_collection

    attach_ue_and_activate_pdu  ue_id=1
    sleep  5

    start_ue_big_data_traffic  ue_id=1  dl_rate=600  ul_rate=50
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=3

    stop_ue_big_data_traffic  ue_id=1
    sleep  15
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=2

    start_ue_big_data_traffic  ue_id=1  dl_rate=600  ul_rate=50
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=3

    detach_ue_with_power_off  ue_id=1

    # [Teardown]  Teardown_for_CB006139