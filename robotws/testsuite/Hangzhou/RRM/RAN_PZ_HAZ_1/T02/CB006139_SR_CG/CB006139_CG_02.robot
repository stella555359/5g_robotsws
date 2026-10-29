*** Settings ***
Documentation
...                 author:  Liu AnAn

Resource    ./Resource_CB006139.robot

Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    CA_RAN_PZ_HAZ_1     CLOUD_5G_I_BOO_AP_LOO

*** Variables ***
${config_tag}  cg_02

*** Test Cases ***
Load_Configuration
    Setup_for_CB006139  config_tag=${config_tag}

CB006139_CG_02
# [1]CB006139_CG_02 B6 gNB-CU ignores buffer criterion notification from gNB-DU
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    Setup_eGate_Env
    detach_ue_with_power_off  ue_id=1
    delete_rlq_profile

    ute_wtssim.Execute Egate Command
    ...    cmd=smf_param id=1 reset
    ute_wtssim.Execute Egate Command
    ...    cmd=qosflow_modify qos_flow=15 default=on

    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=2
    CB006139_Change_UE_Capability  ue_capability=ue_capability_cg_02  ue_id=1

    start_log_collection

    attach_ue_and_activate_pdu  ue_id=1
    sleep  5

    # Precondition: UE in CA with Cell-1 as SCell, buffer monitoring is activated
    start_ue_big_data_traffic  ue_id=1  dl_rate=600  ul_rate=50
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=5
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=1

    stop ue_big_data_traffic  ue_id=1
    sleep  15
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=1
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=1

    # Trigger 5QI-1 setup for B1 measurement conifguration
    ute_wtssim.Execute Egate Command
    ...    cmd=smf_param id=1 additional_qosflows_to_activate=1

    ute_wtssim.Execute Egate Command
    ...    cmd=qosflow_modify qos_flow=11 default=on

    ute_wtssim.Execute Egate Command
    ...    cmd=ue_pdu_session_setup pdu=2 ue=1 gw=1 nwslice=1

    # Step 1: Increase data transmission rate
    start_ue_big_data_traffic  ue_id=1  dl_rate=1200  ul_rate=50
    sleep  5
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=1
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=1

    # Post-processing
    sleep  10
    ${ue_state}  CB006139_Get_UE_State  ue_id=1
    Should Be Equal  ${ue_state}  IDLE
    ute_wtssim.Execute Egate Command
    ...    cmd=smf_param id=1 reset

    ute_wtssim.Execute Egate Command
    ...    cmd=qosflow_modify qos_flow=15 default=on

    detach_ue_with_power_off  ue_id=1

    [Teardown]  Teardown_for_CB006139