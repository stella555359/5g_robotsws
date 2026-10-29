*** Settings ***
Documentation
...                 author:  Liu AnAn

Resource    ./Resource_CB006139.robot

Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    CA_RAN_PZ_HAZ_1     CLOUD_5G_I_BOO_AP_LOO

*** Variables ***
${config_tag}  cg_10

&{RAD_HEXs}
...    rdMPR=0x5902B7
...    rdFailDuAdmissionControl=0x590249

*** Test Cases ***
Load_Configuration
    Setup_for_CB006139  config_tag=${config_tag}

CB006139_CG_10
# [1]CB006139_CG_10 IWK1 interworking with CB006449 2CC UL CA
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    Setup_eGate_Env
    detach_ue_with_power_off  ue_id=1
    delete_rlq_profile
    deactivate_phr_override  ue_id=1

    start_log_collection

    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=8
    CB006139_Change_UE_Capability  ue_capability=ue_capability_cg_10  ue_id=1
    create_rlq_profile

    attach_ue_and_activate_pdu  ue_id=1
    sleep  5

    start_ue_big_data_traffic  ue_id=1  dl_rate=450  ul_rate=50
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=5
    sleep  1
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=0
    sleep  1

    trigger_scell_rlq_release   ue_id=1  scell_id=3
    sleep  1
    detrigger_scell_rlq_release  ue_id=1  scell_id=3
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=4
    sleep  1
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=0
    sleep  1

    stop_ue_big_data_traffic  ue_id=1
    start_ue_big_data_traffic  ue_id=1  dl_rate=300  ul_rate=50
    # sleep  40

    trigger_scell_rlq_release   ue_id=1  scell_id=4
    sleep  1
    detrigger_scell_rlq_release  ue_id=1  scell_id=4
    stop_ue_big_data_traffic  ue_id=1
    start_ue_big_data_traffic  ue_id=1  dl_rate=150  ul_rate=50
    start_ue_dl_data_traffic  ue_id=1  trf_id=2  dl_rate=20
    trigger_scell_rlq_release   ue_id=1  scell_id=5
    sleep  1
    detrigger_scell_rlq_release  ue_id=1  scell_id=5

    stop_ue_big_data_traffic  ue_id=1
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=2
    sleep  1
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=0

    activate_phr_override  ue_id=1

    sleep  5
    start_ue_big_data_traffic  ue_id=1  dl_rate=1800  ul_rate=50
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=3
    sleep  5

    # There is limitation with AP, when DL only SCell-1/2 added back, UL SCell-1/2 also show as configured
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=2
    ${scell_status}  check_ue_ul_scell_schedule_status  ue_id=1  scell_id=1
    Should Be Equal  ${scell_status}  ${False}
    ${scell_status}  check_ue_ul_scell_schedule_status  ue_id=1  scell_id=2
    Should Be Equal  ${scell_status}  ${False}

    detach_ue_with_power_off  ue_id=1

    [Teardown]  Teardown_for_CB006139

*** Keywords ***
activate_phr_override
    [Arguments]  ${ue_id}
    Log to Console  \nActivate UE-${ue_id} PHR override
    ute_wtssim.Execute Egate Command
    ...  cmd=phr_override_testmode_nr profile_id=6 phr_mode=Fixed phr_start=10 phr_min=10 phr_max=10 pc_max=23
    ute_wtssim.Execute Egate Command
    ...  cmd=ue_testmode_set_nr id=${ue_id} testmode=phr_override profile_id=6 action=activate

deactivate_phr_override
    [Arguments]  ${ue_id}
    Log to Console  \nDeactivate UE-${ue_id} PHR override
    ute_wtssim.Execute Egate Command
    ...  cmd=ue_testmode_set_nr id=${ue_id} testmode=phr_override profile_id=6 action=deactivate
    ute_wtssim.Execute Egate Command
    ...  cmd=phr_override_testmode_nr profile_id=6 delete=yes
