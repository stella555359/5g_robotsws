*** Settings ***
Documentation
...    :copyright: Nokia
...    :contact: I_EXT_MN_RAN_VRF_WRO2_7_T03@internal.nsn.com

Resource     ../../../resources/airphone/5G_SW_WRO_Keywords.robot
Library      ta_pcmd
Library      ta5g_testline_management
Library      ta5g_ue_measurements
Library      ta5g_iphy
Library      ta5g_enb
Library      ta5g_delta
Library      ../../../resources/airphone/scout_reporting/ScoutMonitor.py

*** Keywords ***
Start Server Interface
    [Documentation]    Starts interface between gNB and Trace Control Entity
    Start Vm Ethernet Interface    if_name=eth3:SERVER    ip_with_mask=10.0.1.1/24

Setup PCMD
    Configure PCMD    technology=5G    asn1per_decoding=${True}    load_plugin=${False}
    Start collecting PCMD reports

Teardown PCMD
    Stop collecting PCMD reports
    Deconfigure PCMD
