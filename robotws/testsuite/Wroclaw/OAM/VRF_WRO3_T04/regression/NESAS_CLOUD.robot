*** Settings ***
Documentation    Suite for testing Nesas-B on Cloud
...              Authors:    Patryk Tatarek
...              Contact:    patryk.tatarek@nokia.com

Resource        ../features/NESAS/Pack_B/TestCases/NESAS-B_Cloud.robot
Resource        ../features/NESAS/Pack_C/TestCases/NESAS-C_Cloud.robot
Resource        ../../cloud_common_resources/connections/connections.robot
Resource        ../../cloud_common_resources/parameters/parameters.robot
Resource        ../../cloud_common_resources/alarms/alarms.robot
Resource        ../../cloud_common_resources/certificates/certificates.robot
Resource        ../../cloud_common_resources/accounts/accounts.robot
Resource        ../../cloud_common_resources/resets/resets.robot
Resource        ../../cloud_common_resources/logs/logs.robot
Resource        ../cloud_common_resources/dcap/dcap.robot

Library         String
Library         SSHLibrary
Library         Collections
Library         OperatingSystem

*** Test Cases ***
NESAS-B_Handling_of_growing_memory_content_vCU
    Handling_of_growing_memory_content_vCU

NESAS-B_Handling_of_growing_memory_content_vDU
    Handling_of_growing_memory_content_vDU

NESAS-B_Protecting_data_and_information_in_transfer-IPSEC_vCU
    [Setup]       Run Keywords    Adjust XML to specific TL
    ...           ${CURDIR}/../features/NESAS/Pack_B/Resources/Delta_files/IPSEC_config.xml    hw_type=vCU
    ...    AND    Switch localIpAddress in XML to NGU Address from specific TL
    Protecting_data_and_information_in_transfer-IPSEC_vCU

NESAS-B_Authorization_Policy
    Authorization_Policy

NESAS-C_Perform_Mount_Options_Check_vCU
    Perform_Mount_Options_Check_vCU

NESAS-C_Perform_Mount_Options_Check_vDU
    Perform_Mount_Options_Check_vDU

NESAS-C_Unexpected_input_command_in_Aashell_vCU
    Unexpected_input_command_in_Aashell_vCU

NESAS-C-Unexpected_input_command_in_Aashell_vDU
    Unexpected_input_command_in_Aashell_vDU

NESAS-C_Protecion_from_buffer_overflows_vCU
    Protecion_from_buffer_overflows_vCU

NESAS-C_Protecion_from_buffer_overflows_vDU
    Protecion_from_buffer_overflows_vDU

NESAS-C_Traffic_Separation_vCU
    Traffic_Separation_vCU

NESAS-C_Traffic_Separation_vDU
    Traffic_Separation_vDU

NESAS-C_Proxy_ARP_Disabling_vCU
    Proxy_ARP_Disabling_vCU

NESAS-C_Proxy_ARP_Disabling_vDU
    Proxy_ARP_Disabling_vDU

NESAS-C_IP_Multicast_Handling_vCU
    IP_Multicast_Handling_vCU

NESAS-C_IP_Multicast_Handling_vDU
    IP_Multicast_Handling_vDU

NESAS-C_Gratuitous_ARP_Disabling_vCU
    Gratuitous_ARP_Disabling_vCU

NESAS-C_Gratuitous_ARP_Disabling_vDU
    Gratuitous_ARP_Disabling_vDU

NESAS-C_Broadcast_ICMP_Handling_vCU
    Broadcast_ICMP_Handling_vCU

NESAS-C_Broadcast_ICMP_Handling_vDU
    Broadcast_ICMP_Handling_vDU

*** Keywords ***
Test Setup
    [Arguments]           ${hw_type}
    ${dcap_trace_id}=     DCAP Test Setup    hw_type=${hw_type}
    Set Suite Variable    ${dcap_trace_id}

Test Teardown
    [Arguments]                   ${hw_type}
    DCAP Test Teardown            trace_id=${dcap_trace_id}    hw_type=${hw_type}
    Run Keyword if Test Failed    Perform Reset and Wait for Expected State    state=onAir    hw_type=${hw_type}
    Run Keyword if Test Failed    Restore Default Certificates on BTS    hw_type=${hw_type}
    Run Keyword if Test Failed    Delete All Certificates    hw_type=${hw_type}
