*** Settings ***
Documentation
...    :copyright: Nokia
...    :contact: I_EXT_MN_RAN_VRF_WRO2_7_T03@internal.nsn.com

Resource     ../../../resources/airphone/5G_SW_WRO_Keywords.robot
Library      ta_pcmd
Library      CB008208_Keywords.py
Library      ta5g_testline_management
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

Setup Bearer
    [Arguments]    ${ue_id}    ${bearer_id}
    Execute Egate Command    cmd=enb_ue_dc_modify ue=${ue_id} bearer_to_add=${bearer_id} by=enb cause=MISC_CauseMisc_unspecified type=split_scg
    ...                      pass_regexp=Successfully reconfigured dual connectivity

Release Bearer
    [Arguments]    ${ue_id}    ${bearer_id}
	Execute Egate Command    cmd=enb_ue_dc_modify ue=${ue_id} bearer_to_release=${bearer_id} by=enb cause=MISC_CauseMisc_unspecified type=split_scg
    ...                      pass_regexp=Successfully reconfigured dual connectivity


Check That Qfi Value From PCMD Record Is Equal To One In PDU Setup Request
    [Arguments]    ${asn_path}
    ${qfiValue}=    Get Qfi Value From Asn Logs    path=${asn_path}    value=qfi
    Verify Ngap Messages    packet_filter=ngap.PDUSessionResourceSetupRequest_element && ngap.qosFlowIdentifier == ${qfiValue}

