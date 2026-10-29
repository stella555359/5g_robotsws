*** Settings ***
Documentation
...                 author:  Liu AnAn

Resource    ./Resource_CB006139.robot

Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    CA_RAN_PZ_HAZ_1     CLOUD_5G_I_BOO_AP_LOO

*** Variables ***
${config_tag}  cg_15

&{RAD_HEXs}
...    rdOverloadHighThreshold=0x89006f
...    rdFailDuAdmissionControl=0x590249

*** Test Cases ***
Load_Configuration
    Setup_for_CB006139  config_tag=${config_tag}

CB006139_CG_15
# [1]CB006139_CG_15 IWK5 Interaction with CB009059 to restrict stepwise addition or buffer monitoring activation
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    Setup_eGate_Env
    detach_ue_with_power_off  ue_id=1
    delete_rlq_profile
    Change RnD Flags By aaShell
    ...    ${RAD_HEXs['rdFailDuAdmissionControl']}    0

    start_log_collection

    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=2
    CB006139_Change_UE_Capability  ue_capability=ue_capability_6cc  ue_id=1
    create_rlq_profile

    # Step 1: UE attach and activate PDU session with multiple DRB-1/2/3
    smf_config_additional_qfi  add_qosflow=12,13  amf_id=1
    attach_ue_and_activate_pdu  ue_id=1
    sleep  5

    # Step 1-5: Cell F1/2/3/4/5 added as SCell
    start_ue_dl_data_traffic_enh  ue_id=1  pdu=1  qfi=1  trf_id=1  dl_rate=175
    start_ue_dl_data_traffic_enh  ue_id=1  pdu=1  qfi=3  trf_id=1  dl_rate=50
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=5

    # Step 5: Trigger SCell Release Inactivity Timer expired for Cell-1
    stop_ue_dl_data_traffic_enh  ue_id=1  pdu=1  qfi=1  trf_id=1
    sleep  15
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=4

    # Step 6: remove DRB-1/3 and add new DRB-4 but failed due to gNB-DU failure
    Change RnD Flags By aaShell
    ...    ${RAD_HEXs['rdFailDuAdmissionControl']}    1
    Log to Console  \n Remove QOS Flow mapping to DRB-1 and DRB-3
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=14 qosflows_to_del=12,15 by=amf

    sleep  10
    start_ue_big_data_traffic_enh  ue_id=1  pdu=1  qfi=3  dl_rate=900  ul_rate=10
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=4

    detach_ue_with_power_off  ue_id=1
    Change RnD Flags By aaShell
    ...    ${RAD_HEXs['rdFailDuAdmissionControl']}    0

    [Teardown]  Teardown_for_CB006139

CB006139_CG_31
# [1]CB006139_CG_31 IWK5_ATL1 Buffer monitoring is not started when SCell is released while UE has no FR1 CA eligible DRB
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    Setup_eGate_Env
    detach_ue_with_power_off  ue_id=1
    delete_rlq_profile
    Change RnD Flags By aaShell
    ...    ${RAD_HEXs['rdFailDuAdmissionControl']}    0

    start_log_collection

    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=2
    CB006139_Change_UE_Capability  ue_capability=ue_capability_6cc  ue_id=1
    create_rlq_profile

    # Step 1: UE attach and activate PDU session with multiple DRB-1/2/3
    smf_config_additional_qfi  add_qosflow=12,13  amf_id=1
    attach_ue_and_activate_pdu  ue_id=1
    sleep  5

    # Step 1-5: Cell F1/2/3/4/5 added as SCell
    # start_ue_dl_data_traffic_enh  ue_id=1  pdu=1  qfi=1  trf_id=1  dl_rate=175
    start_ue_big_data_traffic_enh  ue_id=1  pdu=1  qfi=1  dl_rate=900  ul_rate=50
    start_ue_dl_data_traffic_enh  ue_id=1  pdu=1  qfi=3  trf_id=1  dl_rate=100
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=5

    # Step 6: remove DRB-1/3 and add new DRB-4 but failed due to gNB-DU failure
    Change RnD Flags By aaShell
    ...    ${RAD_HEXs['rdFailDuAdmissionControl']}    1
    Log to Console  \n Remove QOS Flow mapping to DRB-1 and DRB-3
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=14 qosflows_to_del=12,15 by=amf

    # Step 9: Trigger SCell Release Inactivity Timer expired for Cell-1
    sleep  15
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=4

    start_ue_big_data_traffic_enh  ue_id=1  pdu=1  qfi=3  dl_rate=900  ul_rate=10
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=4

    detach_ue_with_power_off  ue_id=1
    Change RnD Flags By aaShell
    ...    ${RAD_HEXs['rdFailDuAdmissionControl']}    0

    [Teardown]  Teardown_for_CB006139

*** Keywords ***
start_ue_dl_data_traffic_enh
    [Arguments]  ${ue_id}=1  ${pdu}=1  ${qfi}=1  ${trf_id}=1  ${dl_rate}=150
    Log to Console  \nUE-${ue_id} Start pdu=${pdu} qfi=${qfi} trf_id=${trf_id} DL Data Service: dl_rate=${dl_rate}
    Run Keyword And Ignore Error
    ...  ute_wtssim.Execute Egate Command
    ...  cmd=trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=${trf_id} dir=dl mbps=${dl_rate} seconds=3600
    ...  pass_regexp=Started.*Internal traffic.*on Ue:${ue_id}
    ...  timeout=1s

start_ue_ul_data_traffic_enh
    [Arguments]  ${ue_id}=1  ${pdu}=1  ${qfi}=1  ${trf_id}=1  ${ul_rate}=10
    Log to Console  \nUE-${ue_id} Start pdu=${pdu} qfi=${qfi} trf_id=${trf_id} UL Data Service: ul_rate=${ul_rate}
    Run Keyword And Ignore Error
    ...  ute_wtssim.Execute Egate Command
    ...   cmd=trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=${trf_id} dir=ul mbps=${ul_rate} seconds=3600
    ...  pass_regexp=Started.*Internal traffic.*on Ue:${ue_id}
    ...  timeout=1s

start_ue_dl_ul_data_traffic_enh
    [Arguments]  ${ue_id}=1  ${pdu}=1  ${qfi}=1  ${trf_id}=1  ${dl_rate}=150  ${ul_rate}=10
    Log to Console  \nUE-${ue_id} Start pdu=${pdu} qfi=${qfi} trf_id=${trf_id} DL Data Service: dl_rate=${dl_rate}
    Run Keyword And Ignore Error
    ...  ute_wtssim.Execute Egate Command
    ...   cmd=trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=${trf_id} dir=dl mbps=${dl_rate} seconds=3600
    ...  pass_regexp=Started.*Internal traffic.*on Ue:${ue_id}
    ...  timeout=3s
    Log to Console  \nUE-${ue_id} Start pdu=${pdu} qfi=${qfi} trf_id=${trf_id} UL Data Service: ul_rate=${ul_rate}
    Run Keyword And Ignore Error
    ...  ute_wtssim.Execute Egate Command
    ...  cmd=trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=${trf_id} dir=ul mbps=${ul_rate} seconds=3600
    ...  pass_regexp=Started.*Internal traffic.*on Ue:${ue_id}
    ...  timeout=3s

stop_ue_dl_data_traffic_enh
    [Arguments]  ${ue_id}=1  ${pdu}=1  ${qfi}=1  ${trf_id}=1
    Log to Console  \nUE-${ue_id} Stop pdu=${pdu} qfi=${qfi} trf_id=${trf_id} DL Data Service
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=${trf_id} dir=dl
    # ...    pass_regexp= Stopped.*Internal traffic on Ue:${ue_id}

stop_ue_ul_data_traffic_enh
    [Arguments]  ${ue_id}=1  ${pdu}=1  ${qfi}=1  ${trf_id}=1
    Log to Console  \nUE-${ue_id} Stop pdu=${pdu} qfi=${qfi} trf_id=${trf_id} UL Data Service
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=ul
    # ...    pass_regexp= Stopping.*Internal traffic on Ue:${ue_id}

stop_ue_dl_ul_data_traffic_enh
    [Arguments]  ${ue_id}=1  ${pdu}=1  ${qfi}=1  ${trf_id}=1
    Log to Console  \nUE-${ue_id} Stop pdu=${pdu} qfi=${qfi} trf_id=${trf_id} DL Data Service
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=${trf_id} dir=dl
    # ...    pass_regexp= Stopped.*Internal traffic on Ue:${ue_id}
    Log to Console  \nUE-${ue_id} Stop pdu=${pdu} qfi=${qfi} trf_id=${trf_id} UL Data Service
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=ul
    # ...    pass_regexp= Stopping.*Internal traffic on Ue:${ue_id}

start_ue_big_data_traffic_enh
    [Arguments]  ${ue_id}=1  ${pdu}=1  ${qfi}=1  ${dl_rate}=450  ${ul_rate}=10
    ${dl_num}  evaluate  ${dl_rate}//150+1
    FOR  ${i}  IN RANGE  1  ${dl_num}  1
        log to console  \nue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=${i} dir=dl mbps=150 seconds=3600
        ute_wtssim.Execute Egate Command
        ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=${i} dir=dl mbps=150 seconds=3600
        # ...    pass_regexp=Started.*Internal traffic.*on Ue:${ue_id}
    END
    ${ul_num}  evaluate  ${ul_rate}//10+1
    FOR  ${i}  IN RANGE  1  ${ul_num}  1
        log to console  \nue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=${i} dir=ul mbps=10 seconds=3600
        ute_wtssim.Execute Egate Command
        ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=${i} dir=ul mbps=10 seconds=3600
        # ...    pass_regexp=Started.*Internal traffic.*on Ue:${ue_id}
    END

stop_ue_big_data_traffic_enh
    [Arguments]  ${ue_id}=1  ${pdu}=1  ${qfi}=1
    Log to Console  \nUE-${ue_id} Stop Data Service for qfi=${qfi}
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=dl
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=ul

stop_ue_all_data_traffic_enh
    [Arguments]  ${ue_id}=1
    Log to Console  \nUE-${ue_id} Stop All Data Service
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue=${ue_id}

smf_config_additional_qfi
    [Arguments]  ${add_qosflow}  ${amf_id}=1
    Log to Console  \n ${add_qosflow} will be added to activate during ICS
    ute_wtssim.Execute Egate Command
    ...    cmd=smf_param id=${amf_id} additional_qosflows_to_activate=${add_qosflow}

smf_config_reset
    [Arguments]  ${amf_id}=1
    Log to Console  \n SMF Configuration Reset
    ute_wtssim.Execute Egate Command
    ...    cmd=smf_param id=${amf_id} reset

trigger_qosflow_release
    [Arguments]  ${ue_id}=1  ${pdu}=1  ${qfi}=1
    Log to Console  \nUE-${ue_id} Trigger QoS Flow Release for pdu=${pdu} qfi=${qfi}
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_pdu_session_modify ue=1 pdu=1 qosflows_to_del=${qfi} by=amf
    ...    pass_regexp=Pdu Session Resource Modify Response Message.*successfully
    ...    timeout=20s

Change RnD Flags By aaShell
    [Arguments]    @{args}    ${is_permanent}=no
    ccs_aashell.create_aashell_cli    name=aashell
    ccs_aashell.setup    aashell
    ccs_aashell.change_rad_params    aashell    ${args}    ${is_permanent}
    Sleep  10s    Wait for r&d param application
    [Teardown]    ccs_aashell.teardown   aashell