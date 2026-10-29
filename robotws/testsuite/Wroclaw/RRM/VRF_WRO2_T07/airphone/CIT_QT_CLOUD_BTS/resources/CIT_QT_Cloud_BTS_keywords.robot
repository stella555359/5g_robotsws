*** Settings ***

Documentation    :copyright: Nokia

Resource    ../../../../resources/airphone/5G_SW_WRO_Keywords.robot
Library    ta5g_iphy
Library    ta5g_enb
Library    ta5g_testline_management

*** Keywords ***
Start Additional Vm Ethernet Interfaces
    Start Vm Ethernet Interface    if_name=eth3:GNB3_NG    ip_with_mask=10.0.11.100/24
    Start Vm Ethernet Interface    if_name=eth3:GNB3_XN    ip_with_mask=10.0.12.100/24
    Start Vm Ethernet Interface    if_name=eth3:GNB3_S1U_X2    ip_with_mask=10.0.1.11/24
    Start Vm Ethernet Interface    if_name=eth3:GNB3_PROXY   ip_with_mask=10.0.2.90/24


Stop Additional Vm Ethernet Interfaces
    Stop Vm Ethernet Interface    if_name=eth3:GNB3_NG    ip_with_mask=10.0.11.100/24
    Stop Vm Ethernet Interface    if_name=eth3:GNB3_XN    ip_with_mask=10.0.12.100/24
    Stop Vm Ethernet Interface    if_name=eth3:GNB3_S1U_X2    ip_with_mask=10.0.1.11/24
    Stop Vm Ethernet Interface    if_name=eth3:GNB3_PROXY   ip_with_mask=10.0.2.90/24


Attach UE To Enb And Gnb
    [Arguments]    ${ue_id}=1
    Sleep    5s    reason=Problem with establishing x2ap link
    Attach Ue To Enb    ue_id=${ue_id}    optional_parameters=profile=1
    Start Gnb Addition Procedure    ue=${ue_id}
    ...                             target_gnb=2
    ...                             target_cells=1
    ...                             bearer=2
    ...                             dc_type=split_scg
    ...                             pass_regexp=Proxy \\(eNB 2 cell 1\\) reported successful RA
    Verify Ngap Messages    packet_filter=${SN_STATUS_TRANSFER}    continue_on_failure=${False}
