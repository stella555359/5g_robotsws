*** Settings ***
Documentation
...  Author:   Michal Fluder, Adrian Wojtyna
...  Mantainer:    marcin.plawny@nokia.com

Resource     ../../../resources/airphone/5G_SW_WRO_Keywords.robot
Library    testsuite/Wroclaw/RRM/resources/scout_report.py
Library    ta5g_testline_management
Library    ta5g_ue_measurements
Library    ta5g_iphy
Library    ta5g_enb
Library    ta5g_delta

*** Variables ***
${NRREL_OBJECT_CREATION_TIME} =    120
${NRCGI_REPORT_SUPPORTED_IN_ENDC_MODE} =    nr-rrc.nr_CGI_Reporting_ENDC == 0

*** Keywords ***
Start Vm Ethernet Interfaces
    Start Vm Ethernet Interface    if_name=eth3:S1U_1296    ip_with_mask=10.0.1.21/24
    Start Vm Ethernet Interface    if_name=eth3:S11_1296    ip_with_mask=10.0.1.22/24
    Start Vm Ethernet Interface    if_name=eth3:gNB2_X2    ip_with_mask=10.0.1.3/24

Stop Vm Ethernet Interfaces
    Stop Vm Ethernet Interface    if_name=eth3:S1U_1296    ip_with_mask=10.0.1.21/24
    Stop Vm Ethernet Interface    if_name=eth3:S11_1296    ip_with_mask=10.0.1.22/24
    Stop Vm Ethernet Interface    if_name=eth3:gNB2_X2    ip_with_mask=10.0.1.3/24

Attach UE To Enb And Gnb
    [Arguments]    ${ue_id}=1
    Sleep  5s   reason=Problem with establishing x2ap link
    Attach Ue To Enb    ue_id=${ue_id}    optional_parameters=profile=1
    Start Gnb Addition Procedure    ue=${ue_id}    target_gnb=2    target_cells=1    bearer=2    dc_type=split_scg
    ...                             pass_regexp=Proxy \\(eNB 2 cell 1\\) reported successful RA
    Verify Ngap Messages       packet_filter=${SN_STATUS_TRANSFER}    continue_on_failure=${False}

Verify UE Supports NRCGI Report
    Verify Ngap Messages       packet_filter=${X2AP_SGNB_ADDITION_REQUEST} && ${NRCGI_REPORT_SUPPORTED_IN_ENDC_MODE}
