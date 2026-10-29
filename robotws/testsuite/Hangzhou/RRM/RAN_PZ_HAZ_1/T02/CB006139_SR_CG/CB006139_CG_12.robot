*** Settings ***
Documentation
...                 author:  Liu AnAn

Resource    ./Resource_CB006139.robot

Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    CA_RAN_PZ_HAZ_1     CLOUD_5G_I_BOO_AP_LOO

*** Variables ***
${config_tag}  cg_12

*** Test Cases ***
Load_Configuration
    Setup_for_CB006139  config_tag=${config_tag}

CB006139_CG_12
# [1]CB006139_CG_12 IWK4  Interaction with CB008246 to select SCell during stepwise addition that supports High Reliability
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    Setup_eGate_Env
    detach_ue_with_power_off  ue_id=1
    delete_rlq_profile

    start_log_collection

    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=2
    CB006139_Change_UE_Capability  ue_capability=ue_capability_cg_12  ue_id=1
    create_rlq_profile

    smf_config_additional_qfi  add_qosflow=12  amf_id=1
    attach_ue_and_activate_pdu  ue_id=1
    sleep  5

    # Step 1-3: Cell F1/2/3 added as SCell
    start_ue_dl_data_traffic_enh  ue_id=1  pdu=1  qfi=1  trf_id=1  dl_rate=175
    start_ue_dl_data_traffic_enh  ue_id=1  pdu=1  qfi=2  trf_id=1  dl_rate=10
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=3

    # Step 4-8: Trigger RLQ for Cell F1 and after sCellExcludelistTimerFr1 expires, restore RLQ for Cell F1
    trigger_scell_rlq_release  ue_id=1  scell_id=1
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=2
    detrigger_scell_rlq_release  ue_id=1  scell_id=1

    stop_ue_big_data_traffic_enh  ue_id=1  pdu=1  qfi=1
    sleep  15
    start_ue_big_data_traffic_enh  ue_id=1  pdu=1  qfi=1  dl_rate=900   ul_rate=50
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=3

    smf_config_reset
    detach_ue_with_power_off  ue_id=1
    delete_rlq_profile

    [Teardown]  Teardown_for_CB006139

CB006139_CG_13
# [1]CB006139_CG_13 IWK4-ALT1 Stepwise SCell addition cannot be performed due to no SCell that supports High Reliability
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    Setup_eGate_Env
    detach_ue_with_power_off  ue_id=1
    delete_rlq_profile

    start_log_collection

    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=2
    CB006139_Change_UE_Capability  ue_capability=ue_capability_cg_12  ue_id=1
    create_rlq_profile

    smf_config_additional_qfi  add_qosflow=12  amf_id=1
    attach_ue_and_activate_pdu  ue_id=1
    sleep  5

    # Step 1-3: Cell F1/2/3 added as SCell
    start_ue_dl_data_traffic_enh  ue_id=1  pdu=1  qfi=1  trf_id=1  dl_rate=175
    start_ue_dl_data_traffic_enh  ue_id=1  pdu=1  qfi=2  trf_id=1  dl_rate=10
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=3

    # Step 4: Trigger RLQ for Cell F1 and after sCellExcludelistTimerFr1 expires, restore RLQ for Cell F1
    trigger_scell_rlq_release  ue_id=1  scell_id=1
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=2
    detrigger_scell_rlq_release  ue_id=1  scell_id=1

    # Step 5: Block Cell F1
    BTS Operation    operation=cell_lock    product_type=gnb    bts_index=0
    ...    distname_id=NRCELL-1    need_verify=yes

    stop_ue_big_data_traffic_enh  ue_id=1  pdu=1  qfi=1
    sleep  15
    start_ue_big_data_traffic_enh  ue_id=1  pdu=1  qfi=1  dl_rate=900   ul_rate=50
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=2

    smf_config_reset
    detach_ue_with_power_off  ue_id=1
    delete_rlq_profile
    BTS Operation    operation=cell_unlock    product_type=gnb    bts_index=0
    ...    distname_id=NRCELL-1    need_verify=yes

    [Teardown]  Teardown_for_CB006139

CB006139_CG_14
# [1]CB006139_CG_14 IWK4-ALT2 Stepwise SCell addition can be performed after HR DRB is released
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    Setup_eGate_Env
    detach_ue_with_power_off  ue_id=1
    delete_rlq_profile

    start_log_collection

    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=2
    CB006139_Change_UE_Capability  ue_capability=ue_capability_cg_12  ue_id=1
    create_rlq_profile

    smf_config_additional_qfi  add_qosflow=12  amf_id=1
    attach_ue_and_activate_pdu  ue_id=1
    sleep  5

    # Step 1-3: Cell F1/2/3 added as SCell
    start_ue_dl_data_traffic_enh  ue_id=1  pdu=1  qfi=1  trf_id=1  dl_rate=175
    start_ue_dl_data_traffic_enh  ue_id=1  pdu=1  qfi=2  trf_id=1  dl_rate=10
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=3

    # Step 4: Trigger RLQ for Cell F1 and after sCellExcludelistTimerFr1 expires, restore RLQ for Cell F1
    trigger_scell_rlq_release  ue_id=1  scell_id=1
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=2
    detrigger_scell_rlq_release  ue_id=1  scell_id=1

    # Step 5: Block Cell F1
    BTS Operation    operation=cell_lock    product_type=gnb    bts_index=0
    ...    distname_id=NRCELL-1    need_verify=yes

    stop_ue_big_data_traffic_enh  ue_id=1  pdu=1  qfi=1
    sleep  15
    start_ue_big_data_traffic_enh  ue_id=1  pdu=1  qfi=1  dl_rate=900   ul_rate=50
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=2

    # Step 8: Release HR DRB
    trigger_qosflow_release  ue_id=1  pdu=1  qfi=15
    start_ue_dl_data_traffic_enh  ue_id=1  pdu=1  qfi=2  trf_id=1  dl_rate=175
    trigger_scell_rlq_release  ue_id=1  scell_id=2
    sleep  1
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=1
    detrigger_scell_rlq_release  ue_id=1  scell_id=2

    start_ue_big_data_traffic_enh  ue_id=1  pdu=1  qfi=2  dl_rate=900   ul_rate=50
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=3

    smf_config_reset
    detach_ue_with_power_off  ue_id=1
    delete_rlq_profile
    BTS Operation    operation=cell_unlock    product_type=gnb    bts_index=0
    ...    distname_id=NRCELL-1    need_verify=yes

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