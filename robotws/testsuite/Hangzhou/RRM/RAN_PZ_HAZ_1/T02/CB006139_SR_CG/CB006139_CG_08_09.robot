*** Settings ***
Documentation
...                 author:  Liu AnAn

Resource    ./Resource_CB006139.robot

Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    CA_RAN_PZ_HAZ_1     CLOUD_5G_I_LOO_AP_LOO

*** Variables ***
${config_tag}  cg_08

*** Test Cases ***
Load_Configuration
    Setup_for_TMOUS  config_tag=${config_tag}

CB006139_CG_08_09
# [1]CB006139_CG_08 B13 Measurement profile selection for A2 configuration for SCell change
# [1]CB006139_CG_09 B13 SCell change during stepwise SCell addition
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    Setup_eGate_Env
    detach_ue_with_power_off  ue_id=1
    delete_rlq_profile

    # start_log_collection

    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=8
    CB006139_Change_UE_Capability  ue_capability=ue_capability_cg_08  ue_id=1

    attach_ue_and_activate_pdu  ue_id=1
    sleep  5

    # Step2: UE report A1 to add FDD Cell F1 and F2 as SCell
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id_enh2  ue_id=1  nrarfcn=387630  event_type=A1  report_on_leave=true  rsrp=75
    Should Not Be Equal  ${meas_id}  ${None}
    CB006139_Send_EventA1_For_SCell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=58  rsrp=76

    start_ue_big_data_traffic  ue_id=1  dl_rate=900  ul_rate=50
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=2

    ${meas_id}  CB006139_Get_NR_Meas_Config_Id_enh2  ue_id=1  nrarfcn=396970  event_type=A2  report_on_leave=false  rsrp=50
    Should Not Be Equal  ${meas_id}  ${None}
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id_enh2  ue_id=1  nrarfcn=125290  event_type=A2  report_on_leave=false  rsrp=50
    Should Not Be Equal  ${meas_id}  ${None}

    # Step 6: UE report A1 for SCell Addition and SCell Change
    ${meas_id_1}  CB006139_Get_NR_Meas_Config_Id_enh2  ue_id=1  nrarfcn=387630  event_type=A1  report_on_leave=true  rsrp=80
    Should Not Be Equal  ${meas_id_1}  ${None}
    ${meas_id_2}  CB006139_Get_NR_Meas_Config_Id_enh2  ue_id=1  nrarfcn=387630  event_type=A1  report_on_leave=false  rsrp=80
    Should Not Be Equal  ${meas_id_2}  ${None}
    CB006139_Send_EventA1_For_SCell_Addition  ue_id=1  meas_id=${meas_id_1}  phycell_id=58  rsrp=81
    CB006139_Send_EventA1_For_SCell_Addition  ue_id=1  meas_id=${meas_id_2}  phycell_id=58  rsrp=81

    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=3

    ${meas_id_1}  CB006139_Get_NR_Meas_Config_Id_enh2  ue_id=1  nrarfcn=387630  event_type=A1  report_on_leave=true  rsrp=80
    Should Be Equal  ${meas_id_1}  ${None}
    ${meas_id_2}  CB006139_Get_NR_Meas_Config_Id_enh2  ue_id=1  nrarfcn=387630  event_type=A1  report_on_leave=false  rsrp=80
    Should Be Equal  ${meas_id_2}  ${None}

    # [Teardown]  Teardown_for_CB006139

*** Keywords ***
CB006139_Send_EventA1_For_SCell_Addition
    [Arguments]  ${ue_id}  ${meas_id}  ${phycell_id}  ${rsrp}
    ${output}    Airphone Operation    operation=send_common_command
    ...  product_type=${None}
    ...  traffic_info_dic=${None}
    ...  tag=${None}
    ...  cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${rsrp} phycell_id=${phycell_id}
    ...  pass_regexp=EGATE>
    ...  timeout=5s

CB006139_Send_EventA2_For_SCell_Release
    [Arguments]  ${ue_id}  ${meas_id}  ${scell_id}
    ${output}    Airphone Operation    operation=send_common_command
    ...  product_type=${None}
    ...  traffic_info_dic=${None}
    ...  tag=${None}
    ...  cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=${scell_id} scell_rsrp=49
    ...  pass_regexp=EGATE>
    ...  timeout=5s