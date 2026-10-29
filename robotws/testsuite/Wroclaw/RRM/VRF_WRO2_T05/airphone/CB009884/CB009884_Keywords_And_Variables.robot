*** Settings ***
Documentation    :copyright: Nokia

Resource     ../../../resources/airphone/5G_SW_WRO_Keywords.robot
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_enb
Library      ta5g_ue_measurements
Library      ta5g_pm_counters
Library      ta5g_cell_operations
Library      ta5g_delta
Library      ta5g_admin_operations
Library      ta5g_setups_and_teardowns
Library      ta5g_throughput

*** Variables ***
${NGAP_UE_CONTEXT_RELEASE_ABNORMAL_XN} =    ngap.UEContextReleaseRequest_element && ngap.id == 15
${NGAP_PDU_SESSION_RELEASE} =    ngap.PDUSessionResourceListCxtRelReq && ngap.id == 133
${NGAP_UE_CONTEXT_RELEASE_Interaction_Other_Procedure} =    ngap.UEContextReleaseRequest_element && ngap.radioNetwork == 25
${NGAP_UE_Release_Failure_In_Radio_Interface} =    ngap.radioNetwork ==24
${RESTORE_DEFAULT_CONFIG}=    ${FALSE}
@{Radio_Connection}=    0x5B0236=100

*** Keywords ***
Activate Additional 5QI
    Execute Egate Command    cmd=smf_param id=1 additional_qosflows_to_activate=2

Reset SMF
    Execute Egate Command    cmd=smf_param id=1 reset

Establish X2 Link Between Enbs And Gnb
    Setup X2 Link    initiator_device=1     complementary_device=2
    Setup X2 Link    initiator_device=9     complementary_device=2

Start Gnb Addition Procedure and Generate Traffic
    [Arguments]  ${ue_id}
    Start Gnb Addition Procedure     ue=${ue_id}   target_gnb=2    target_cells=1    bearer=2    dc_type=split_scg
    ...                              pass_regexp=Proxy \\(eNB 2 cell 1\\) reported successful RA
    Start Data Traffic               ues=${ue_id}    direction=both    traffic_id=2    throughput=10kbps    bearer_id=2

Perform Inter ENB HO with change in SCG
    [Arguments]  ${ue_id}
    Execute Egate Command           cmd=ue_enb_endc_param id=${ue_id} candidate_cells_mn_hex_for_menb_ho=092659802198
    Execute Egate Command           cmd=ue_ho id=${ue_id} ho_mode=INTRA_LTE enb=9 cell=9
    ...                             pass_regexp=Message:x2ap::UEContextRelease sent to ENB-2

Start Vm Ethernet Interfaces
    Start Vm Ethernet Interface    if_name=eth3:gNB2_NG     ip_with_mask=10.0.1.139/24
    Start Vm Ethernet Interface    if_name=eth3:ENB9_X2U    ip_with_mask=10.0.1.140/24
    Start Vm Ethernet Interface    if_name=eth3:MME1_S1     ip_with_mask=10.0.1.131/24
    Start Vm Ethernet Interface    if_name=eth3:SERVER      ip_with_mask=10.0.1.132/24
    Start Vm Ethernet Interface    if_name=eth3:S1U         ip_with_mask=10.0.1.133/24
    Start Vm Ethernet Interface    if_name=eth3:S11         ip_with_mask=10.0.1.134/24
    Start Vm Ethernet Interface    if_name=eth3:X2U         ip_with_mask=10.0.1.135/24
    Start Vm Ethernet Interface    if_name=eth3:ENB1_S1     ip_with_mask=10.0.1.136/24
    Start Vm Ethernet Interface    if_name=eth3:ENB1_X2     ip_with_mask=10.0.1.137/24
    Start Vm Ethernet Interface    if_name=eth3:ENB9_S1     ip_with_mask=10.0.1.138/24
    Start Vm Ethernet Interface    if_name=eth3:ENB9_X2     ip_with_mask=10.0.1.139/24

Stop Vm Ethernet Interfaces
    Stop Vm Ethernet Interface    if_name=eth3:gNB2_NG     ip_with_mask=10.0.1.139/24
    Stop Vm Ethernet Interface    if_name=eth3:ENB9_X2U    ip_with_mask=10.0.1.140/24
    Stop Vm Ethernet Interface    if_name=eth3:MME1_S1     ip_with_mask=10.0.1.131/24
    Stop Vm Ethernet Interface    if_name=eth3:SERVER      ip_with_mask=10.0.1.132/24
    Stop Vm Ethernet Interface    if_name=eth3:S1U         ip_with_mask=10.0.1.133/24
    Stop Vm Ethernet Interface    if_name=eth3:S11         ip_with_mask=10.0.1.134/24
    Stop Vm Ethernet Interface    if_name=eth3:X2U         ip_with_mask=10.0.1.135/24
    Stop Vm Ethernet Interface    if_name=eth3:ENB1_S1     ip_with_mask=10.0.1.136/24
    Stop Vm Ethernet Interface    if_name=eth3:ENB1_X2     ip_with_mask=10.0.1.137/24
    Stop Vm Ethernet Interface    if_name=eth3:ENB9_S1     ip_with_mask=10.0.1.138/24
    Stop Vm Ethernet Interface    if_name=eth3:ENB9_X2     ip_with_mask=10.0.1.139/24
