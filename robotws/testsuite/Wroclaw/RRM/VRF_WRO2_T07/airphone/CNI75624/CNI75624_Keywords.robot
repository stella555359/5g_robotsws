*** Settings ***

Documentation    :copyright: Nokia

Resource    ../../../resources/airphone/5G_SW_WRO_Keywords.robot
Library    ta5g_testline_management
Library    ta5g_ue_measurements
Library    ta5g_enb
Library    ta5g_delta

*** Keywords ***

Start Vm Ethernet Interfaces
    Start Vm Ethernet Interface    if_name=eth3:gNB2_XN    ip_with_mask=10.0.1.101/24
    Start Vm Ethernet Interface    if_name=eth3:gNB2_NG    ip_with_mask=10.0.1.102/24
    Start Vm Ethernet Interface    if_name=eth3:S1U_1296    ip_with_mask=10.0.1.21/24
    Start Vm Ethernet Interface    if_name=eth3:S11_1296    ip_with_mask=10.0.1.22/24
    Start Vm Ethernet Interface    if_name=eth3:gNB2_X2    ip_with_mask=10.0.1.3/24

Stop Vm Ethernet Interfaces
    Stop Vm Ethernet Interface    if_name=eth3:gNB2_XN    ip_with_mask=10.0.1.101/24
    Stop Vm Ethernet Interface    if_name=eth3:gNB2_NG    ip_with_mask=10.0.1.102/24
    Stop Vm Ethernet Interface    if_name=eth3:S1U_1296    ip_with_mask=10.0.1.21/24
    Stop Vm Ethernet Interface    if_name=eth3:S11_1296    ip_with_mask=10.0.1.22/24
    Stop Vm Ethernet Interface    if_name=eth3:gNB2_X2    ip_with_mask=10.0.1.3/24
