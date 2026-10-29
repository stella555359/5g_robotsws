*** Settings ***
Documentation    Suite for TL280

Resource        ../features/CB006048-5G-A/TestCases/6048_TestCases.robot
Resource        ../features/5GC001525-GA-5GC000390/TestCases/5GC001525-GA-5GC000390_TestCases.robot
Resource        ../features/CB012224/TestCases/CB012224.robot
Resource        ../features/CB012442/TestCases/CB012442-SR.robot
Resource        ../features/CB008254/TestCases/CB008254.robot

Resource        ../common_resources/gathering_logs/gathering_logs.robot
Resource        ../common_resources/mantaray/mantaray.robot
Resource        ../common_resources/variables/variables.robot

Suite Setup     Suite Setup
Suite Teardown  Suite Teardown

Test Setup      Test Setup
Test Teardown   Test Teardown

*** Variables ***
${NetAct_name}=     srnclab1015

*** Test Cases ***
[1]CB010546_CB006048_Applications_with_external_interfaces_on_all_interfaces_TCP_transport_protocol_v2_ABIQ
    [Tags]    6048    T07    trunk
    CB006048_All_Interfaces_TCP

[1]CB010546_CB006048_Applications_with_external_interfaces_on_m-plane_interface_TCP_UDP_and_SCTP_transport_protocols_ABIQ
    [Tags]    6048    T08    trunk    25R2
    CB006048_Classical  Management plane

[1]CB010546_CB006048_Applications_with_external_interfaces_on_all_interfaces_UDP_and_SCTP_transport_protocols_ABIQ
    [Tags]    6048    T09    trunk    25R2
    CB006048_All_Interfaces_UDP_SCTP

[1]CB008325_5GC000390_1_Validate_instalation_of_Nokia_Vendor_Certificate_on_cOAM_BTS_ABIP
    [Tags]  390    T10    trunk    25R2
	...     [1]CB008325_5GC000390_1_Validate_instalation_of_Nokia_Vendor_Certificate_on_cOAM_BTS_ABIP
    5GC001525_GA_Validate_installation_of_Nokia_Vendor_Certificate_on_cOAM_BTS

[1]CB008325_5GC000390_2_Display_BTS_Vendor_Certificate_and_trust_chain_on_cOAM_BTS_ABIP
    [Tags]  390    T11    trunk    25R2
	...     [1]CB008325_5GC000390_2_Display_BTS_Vendor_Certificate_and_trust_chain_on_cOAM_BTS_ABIP
    5GC001525_GA_2_Display_BTS_Vendor_Certificate_and_trust_chain_on_cOAM_BTS

[1]CB008325_5GC000390_3_Restore_Nokia_Vendor_Certificate_5GgNB-DU_WebEM_ABIP
    [Tags]  390    T12    trunk    25R2
	...     [1]CB008325_5GC000390_3_Restore_Nokia_Vendor_Certificate_5GgNB-DU_WebEM_ABIP
    5GC001525_GA_3_Restore_Vendor_Certificate_and_remove_Operator_Certificate_on_cOAM_BTS

[1]CB012442-B_FeVe_04_usage_of_Nokia_BTS_vendor_SW_certificate_for_WebEm_on_SBTS
    [Tags]  12442  T13    trunk    25R2
    CB012442-B_FeVe_04_usage_of_Nokia_BTS_vendor_SW_certificate_for_WebEm_on_SBTS

[1]CB012224-A_02_Local_user_accounts_status_report-triggering_and_exporting
    [Tags]  12224  T16    trunk
    CB012224-A_02_Local_user_accounts_status_report-triggering_and_exporting

[1]CB012224-A_04_Unsuccessful_local_user_accounts_status_report
    [Tags]  12224  T18    trunk    25R2    25R1_MP
    CB012224-A_04_Unsuccessful_local_user_accounts_status_report

*** Keywords ***
Suite Setup
    Common Gathering Logs for Common Suite Setup
    Change Ethernet Port Security Enabled To True CLASSICAL
    Run Keyword And Ignore Error                  add_headline_to_output_file
    Run Keyword And Continue On Failure           Wait Until BTS Reach Configured Or OnAir State

Suite Teardown
    Common Gathering Logs for Common Suite Teardown
	Run Keyword And Ignore Error                  copy_files_of_nmap_results
	Run Keyword And Ignore Error                  Copy Report Txt File To Output Directory
	Run keyword and ignore error   Collect and send logs for scrambling verification   team_name=PZ3WRO4
    ...                            input_logs_dir=${NONE}

Test Setup
    Common Gathering Logs for Test Setup

Test Teardown
    Common Gathering Logs for Test Teardown

Test Setup NMS
    Common Gathering Logs for Test Setup
    Integrate BTS to MantaRay without TLS    NMS_HOST=${SRNCLAB1015}    LAB_NAME=${NetAct_name}

Test Teardown NMS
    Deintegrate BTS from MantaRay    LAB_NAME=${NetAct_name}
    Wait until BTS reach Configured or OnAir state
    Common Gathering Logs for Test Teardown
