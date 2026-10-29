*** Settings ***
Documentation
...                 author:  Liu AnAn

Resource    ./Resource_CB006139.robot

Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    CA_RAN_PZ_HAZ_1     CLOUD_5G_I_BOO_AP_LOO

*** Variables ***
${config_tag}  ch

*** Test Cases ***
Load_Configuration
    Setup_for_CB006139  config_tag=${config_tag}

CB006139_CH_EAR3
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    Setup_eGate_Env
    detach_ue_with_power_off  ue_id=1
    delete_rlq_profile
    # CB006139_Change_maxNumOfSCellAlloc  cell_id=1  value=0

    # start_log_collection

    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=5
    CB006139_Change_UE_Capability  ue_capability=ue_capability_ch  ue_id=1

    FOR  ${i}  IN RANGE  1  2
        Log to Console  ------------------------------------Round ${i}-------------------------------------------------
        CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=5
        attach_ue_and_activate_pdu  ue_id=1
        sleep  5
        # UE report A1 to add Cell1 and Cell2 as Scell
        ${meas_id}  CB006139_Get_NR_Meas_Config_Id_enh  ue_id=1  nrarfcn=368190  event_type=A1  rsrp=60
        Should Not Be Equal  ${meas_id}  ${None}
        CB006139_Send_EventA1_For_SCell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=55  rsrp=61

        start_ue_big_data_traffic  ue_id=1  dl_rate=600  ul_rate=50
        sleep  10
        verify_ue_dl_scell_status  ue_id=1  num_of_scells=2

        stop_ue_big_data_traffic  ue_id=1
        ${meas_id_1}  CB006139_Get_NR_Meas_Config_Id_enh  ue_id=1  nrarfcn=126750  event_type=A2  rsrp=50
        Should Not Be Equal  ${meas_id_1}  ${None}
        # A6 for SCell change
        ${meas_id_2}  CB006139_Get_NR_Meas_Config_Id_enh  ue_id=1  nrarfcn=427970  event_type=A6  rsrp=0
        Should Not Be Equal  ${meas_id_2}  ${None}

        CB006139_Send_EventA6_For_SCell_Change  ue_id=1  meas_id=${meas_id_2}  scell_id=2  phycell_id=54
        CB006139_Send_EventA2_For_SCell_Release  ue_id=1  meas_id=${meas_id_1}  scell_id=1


        start_ue_big_data_traffic  ue_id=1  dl_rate=900  ul_rate=50
        sleep  5

        verify_ue_dl_scell_status  ue_id=1  num_of_scells=1

        detach_ue_with_power_off  ue_id=1
    END

    # [Teardown]  Teardown_for_CB006139


CB006139_CH_EAR2
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    Setup_eGate_Env
    detach_ue_with_power_off  ue_id=1
    delete_rlq_profile
    # CB006139_Change_maxNumOfSCellAlloc  cell_id=1  value=0

    # start_log_collection

    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=5
    CB006139_Change_UE_Capability  ue_capability=ue_capability_ch  ue_id=1

    FOR  ${i}  IN RANGE  1  11
        Log to Console  ------------------------------------Round ${i}-------------------------------------------------
        CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=5
        attach_ue_and_activate_pdu  ue_id=1
        sleep  5
        # UE report A1 to add Cell1 and Cell2 as Scell
        ${meas_id}  CB006139_Get_NR_Meas_Config_Id_enh  ue_id=1  nrarfcn=368190  event_type=A1  rsrp=60
        Should Not Be Equal  ${meas_id}  ${None}
        CB006139_Send_EventA1_For_SCell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=55  rsrp=61

        start_ue_big_data_traffic  ue_id=1  dl_rate=600  ul_rate=50
        sleep  10
        verify_ue_dl_scell_status  ue_id=1  num_of_scells=2

        stop_ue_big_data_traffic  ue_id=1
        ${meas_id}  CB006139_Get_NR_Meas_Config_Id_enh  ue_id=1  nrarfcn=126750  event_type=A2  rsrp=50
        Should Not Be Equal  ${meas_id}  ${None}
        CB006139_Send_EventA2_For_SCell_Release  ue_id=1  meas_id=${meas_id}  scell_id=1
        sleep  5

        # A1 for SCell addition
        ${meas_id_1}  CB006139_Get_NR_Meas_Config_Id_enh  ue_id=1  nrarfcn=368190  event_type=A1  rsrp=60
        Should Not Be Equal  ${meas_id_1}  ${None}
        # A1 for PCell switch
        ${meas_id_2}  CB006139_Get_NR_Meas_Config_Id_enh  ue_id=1  nrarfcn=427970  event_type=A1  rsrp=75
        Should Not Be Equal  ${meas_id_2}  ${None}
        # A6 for SCell change
        ${meas_id_3}  CB006139_Get_NR_Meas_Config_Id_enh  ue_id=1  nrarfcn=427970  event_type=A6  rsrp=0
        Should Not Be Equal  ${meas_id_3}  ${None}

        CB006139_Send_EventA1_For_SCell_Addition  ue_id=1  meas_id=${meas_id_1}  phycell_id=55  rsrp=61
        start_ue_big_data_traffic  ue_id=1  dl_rate=300  ul_rate=50
        sleep  1
        CB006139_Send_EventA6_For_SCell_Change  ue_id=1  meas_id=${meas_id_3}  scell_id=2  phycell_id=54
        CB006139_Send_EventA1_For_PCell_Switch  ue_id=1  meas_id=${meas_id_2}  scell_id=1
        CB006139_Send_EventA1_For_PCell_Switch  ue_id=1  meas_id=${meas_id_2}  scell_id=3

        start_ue_big_data_traffic  ue_id=1  dl_rate=900  ul_rate=50
        sleep  5

        verify_ue_dl_scell_status  ue_id=1  num_of_scells=2

        detach_ue_with_power_off  ue_id=1
    END

    # [Teardown]  Teardown_for_CB006139

CB006139_CH_EAR
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    Setup_eGate_Env
    detach_ue_with_power_off  ue_id=1
    delete_rlq_profile
    CB006139_Change_maxNumOfSCellAlloc  cell_id=1  value=0

    # start_log_collection

    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=5
    CB006139_Change_UE_Capability  ue_capability=ue_capability_ch  ue_id=1

    FOR  ${i}  IN RANGE  1  11
        Log to Console  ------------------------------------Round ${i}-------------------------------------------------
        attach_ue_and_activate_pdu  ue_id=1
        sleep  5
        # UE report A1 to add Cell1 and Cell2 as Scell
        ${meas_id}  CB006139_Get_NR_Meas_Config_Id_enh  ue_id=1  nrarfcn=368190  event_type=A1  rsrp=60
        Should Not Be Equal  ${meas_id}  ${None}
        CB006139_Send_EventA1_For_SCell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=55  rsrp=61

        start_ue_big_data_traffic  ue_id=1  dl_rate=600  ul_rate=50
        sleep  10
        verify_ue_dl_scell_status  ue_id=1  num_of_scells=2

        stop_ue_big_data_traffic  ue_id=1
        ${meas_id}  CB006139_Get_NR_Meas_Config_Id_enh  ue_id=1  nrarfcn=126750  event_type=A2  rsrp=50
        Should Not Be Equal  ${meas_id}  ${None}
        CB006139_Send_EventA2_For_SCell_Release  ue_id=1  meas_id=${meas_id}  scell_id=1
        sleep  5
        ${meas_id}  CB006139_Get_NR_Meas_Config_Id_enh  ue_id=1  nrarfcn=368190  event_type=A1  rsrp=60
        Should Not Be Equal  ${meas_id}  ${None}
        CB006139_Send_EventA1_For_SCell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=55  rsrp=61
        start_ue_big_data_traffic  ue_id=1  dl_rate=450  ul_rate=50
        sleep  2

        ${meas_id}  CB006139_Get_NR_Meas_Config_Id_enh  ue_id=1  nrarfcn=427970  event_type=A6  rsrp=0
        Should Not Be Equal  ${meas_id}  ${None}
        CB006139_Send_EventA6_For_SCell_Change  ue_id=1  meas_id=${meas_id}  scell_id=2  phycell_id=54
        start_ue_big_data_traffic  ue_id=1  dl_rate=900  ul_rate=50
        sleep  5

        verify_ue_dl_scell_status  ue_id=1  num_of_scells=2

        detach_ue_with_power_off  ue_id=1
    END

    # [Teardown]  Teardown_for_CB006139

CB006139_CH_05
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    Setup_eGate_Env
    detach_ue_with_power_off  ue_id=1
    delete_rlq_profile
    CB006139_Change_maxNumOfSCellAlloc  cell_id=1  value=250

    start_log_collection
    # PM_2113/PM_1631
    Wait_for_Next_5min_Period
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     counter_rule=${CURDIR}/counter_rule_ch05.txt
    ...                                                     wait_for_next_counter_generate=${False}

    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=5
    CB006139_Change_UE_Capability  ue_capability=ue_capability_ch  ue_id=1
    attach_ue_and_activate_pdu  ue_id=1
    sleep  5

    # UE report A1 to add Cell1 and Cell2 as Scell
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id_enh  ue_id=1  nrarfcn=368190  event_type=A1  rsrp=60
    Should Not Be Equal  ${meas_id}  ${None}
    CB006139_Send_EventA1_For_SCell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=55  rsrp=61

    start_ue_big_data_traffic  ue_id=1  dl_rate=600  ul_rate=50
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=2

    # UE report A2 for Cell1 to relesae Cell1 as SCell-1
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id_enh  ue_id=1  nrarfcn=368190  event_type=A1  rsrp=60
    Should Be Equal  ${meas_id}  ${None}
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id_enh  ue_id=1  nrarfcn=392410  event_type=A2  rsrp=50
    Should Not Be Equal  ${meas_id}  ${None}
    CB006139_Send_EventA2_For_SCell_Release  ue_id=1  meas_id=${meas_id}  scell_id=1
    sleep  5
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=1

    # Change maxnumofScell of Cell1 to disable Cell1 added as SCell, and UE report A1 to add Cell3 as SCell-1
    CB006139_Change_maxNumOfSCellAlloc  cell_id=1  value=0
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id_enh  ue_id=1  nrarfcn=368190  event_type=A1  rsrp=60
    Should Not Be Equal  ${meas_id}  ${None}
    CB006139_Send_EventA1_For_SCell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=55  rsrp=61
    start_ue_big_data_traffic  ue_id=1  dl_rate=900  ul_rate=50
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=2

    ${meas_id}  CB006139_Get_NR_Meas_Config_Id_enh  ue_id=1  nrarfcn=126750  event_type=A1  rsrp=75
    Should Not Be Equal  ${meas_id}  ${None}
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id_enh  ue_id=1  nrarfcn=427970  event_type=A1  rsrp=75
    Should Not Be Equal  ${meas_id}  ${None}
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id_enh  ue_id=1  nrarfcn=427970  event_type=A6  rsrp=0
    Should Not Be Equal  ${meas_id}  ${None}
    # CB006139_Send_EventA6_For_SCell_Swap  ue_id=1  meas_id=${meas_id}  scell_id=1  phycell_id=54

    # UE report A2 for Cell1 to relesae Cell3 as SCell-1
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id_enh  ue_id=1  nrarfcn=368190  event_type=A1  rsrp=60
    Should Be Equal  ${meas_id}  ${None}
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id_enh  ue_id=1  nrarfcn=427970  event_type=A2  rsrp=50
    Should Not Be Equal  ${meas_id}  ${None}
    CB006139_Send_EventA2_For_SCell_Release  ue_id=1  meas_id=${meas_id}  scell_id=1
    sleep  5
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=1

    # Change maxnumofScell of Cell3 to disable Cell3 added as SCell, and UE report A1 to add Cell4 as SCell-1
    CB006139_Change_maxNumOfSCellAlloc  cell_id=3  value=0
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id_enh  ue_id=1  nrarfcn=427970  event_type=A6  rsrp=0
    Should Be Equal  ${meas_id}  ${None}
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id_enh  ue_id=1  nrarfcn=368190  event_type=A1  rsrp=60
    Should Not Be Equal  ${meas_id}  ${None}
    CB006139_Send_EventA1_For_SCell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=55  rsrp=61
    start_ue_big_data_traffic  ue_id=1  dl_rate=900  ul_rate=50
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=2

    # Change maxnumofScell of Cell3 to disable Cell4 added as SCell and Change maxnumofScell of Cell1 to enable Cell1 added as SCell
    CB006139_Change_maxNumOfSCellAlloc  cell_id=4  value=0
    CB006139_Change_maxNumOfSCellAlloc  cell_id=1  value=250
    # UE report A2 to release Cell4 as SCell-1
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id_enh  ue_id=1  nrarfcn=368190  event_type=A1  rsrp=60
    Should Be Equal  ${meas_id}  ${None}
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id_enh  ue_id=1  nrarfcn=427970  event_type=A2  rsrp=50
    Should Not Be Equal  ${meas_id}  ${None}
    CB006139_Send_EventA2_For_SCell_Release  ue_id=1  meas_id=${meas_id}  scell_id=1
    sleep  5
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=1

    #  UE report A1 to add Cell1 as SCell-1
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id_enh  ue_id=1  nrarfcn=427970  event_type=A6  rsrp=0
    Should Be Equal  ${meas_id}  ${None}
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id_enh  ue_id=1  nrarfcn=368190  event_type=A1  rsrp=60
    Should Not Be Equal  ${meas_id}  ${None}
    CB006139_Send_EventA1_For_SCell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=55  rsrp=61
    start_ue_big_data_traffic  ue_id=1  dl_rate=900  ul_rate=50
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=2

    detach_ue_with_power_off  ue_id=1

    Wait_for_Next_5min_Period
    Wait_for_Next_5min_Period
    ${value}    Counter Operation    operation=collect_counter_and_calculate    product_type=gnb    bts_index=0    cudu_index=0

    [Teardown]  Teardown_for_CB006139

CB006139_CH_04
# [1]CB006139_CH_04_B3_Stepwise_SCell_addition_interaction_with_A2_measurement_based_PCell_change
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    Setup_eGate_Env
    detach_ue_with_power_off  ue_id=1
    delete_rlq_profile
    CB006139_Change_maxNumOfSCellAlloc  cell_id=1  value=250

    start_log_collection
    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=5
    CB006139_Change_UE_Capability  ue_capability=ue_capability_ch_04  ue_id=1
    attach_ue_and_activate_pdu  ue_id=1
    sleep  5

    ${meas_id}  CB006139_Get_NR_Meas_Config_Id_enh  ue_id=1  nrarfcn=368190  event_type=A1  rsrp=60
    Should Not Be Equal  ${meas_id}  ${None}
    CB006139_Send_EventA1_For_SCell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=55  rsrp=61

    start_ue_big_data_traffic  ue_id=1  dl_rate=600  ul_rate=50
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=2

    ${meas_id}  CB006139_Get_NR_Meas_Config_Id_enh  ue_id=1  nrarfcn=368190  event_type=A1  rsrp=60
    Should Be Equal  ${meas_id}  ${None}
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id_enh  ue_id=1  nrarfcn=368190  event_type=A2  rsrp=60
    Should Be Equal  ${meas_id}  ${None}
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id_enh  ue_id=1  nrarfcn=392410  event_type=A2  rsrp=50
    Should Not Be Equal  ${meas_id}  ${None}
    CB006139_Send_EventA2_For_SCell_Release  ue_id=1  meas_id=${meas_id}  scell_id=1
    sleep  5
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=1

    ${meas_id}  CB006139_Get_NR_Meas_Config_Id_enh  ue_id=1  nrarfcn=368190  event_type=A1  rsrp=60
    Should Not Be Equal  ${meas_id}  ${None}
    CB006139_Change_maxNumOfSCellAlloc  cell_id=1  value=0
    CB006139_Send_EventA1_For_SCell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=55  rsrp=61
    start_ue_big_data_traffic  ue_id=1  dl_rate=900  ul_rate=50
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=2

    ${meas_id}  CB006139_Get_NR_Meas_Config_Id_enh  ue_id=1  nrarfcn=126750  event_type=A1  rsrp=75
    Should Be Equal  ${meas_id}  ${None}
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id_enh  ue_id=1  nrarfcn=427970  event_type=A1  rsrp=75
    Should Not Be Equal  ${meas_id}  ${None}
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id_enh  ue_id=1  nrarfcn=368190  event_type=A2  rsrp=60
    Should Not Be Equal  ${meas_id}  ${None}

    detach_ue_with_power_off  ue_id=1

    stop_log_collection

    # CB006139_Change_maxNumOfSCellAlloc  cell_id=1  value=250

    # [Teardown]  Teardown_for_CB006139

*** Keywords ***
CB006139_Send_EventA1_For_SCell_Addition
    [Arguments]  ${ue_id}  ${meas_id}  ${phycell_id}   ${rsrp}
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
    # ...  pass_regexp=EGATE>
    # ...  timeout=5s

CB006139_Send_EventA6_For_SCell_Change
    [Arguments]  ${ue_id}  ${meas_id}  ${scell_id}  ${phycell_id}
    ${output}    Airphone Operation    operation=send_common_command
    ...  product_type=${None}
    ...  traffic_info_dic=${None}
    ...  tag=${None}
    ...  cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A6 scell=${scell_id} scell_rsrp=70 phycell_id=${phycell_id} nrsrp_nr=75
    # ...  pass_regexp=EGATE>
    # ...  timeout=5s

CB006139_Send_EventA1_For_PCell_Switch
    [Arguments]  ${ue_id}  ${meas_id}  ${scell_id}
    ${output}    Airphone Operation    operation=send_common_command
    ...  product_type=${None}
    ...  traffic_info_dic=${None}
    ...  tag=${None}
    ...  cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=65 scell=${scell_id} scell_rsrp=80
    # ...  pass_regexp=EGATE>
    # ...  timeout=5s