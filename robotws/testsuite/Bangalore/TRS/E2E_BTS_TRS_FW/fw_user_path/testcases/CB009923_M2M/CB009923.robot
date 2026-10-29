*** Settings ***
Documentation     Final optimized test suite for fews vCU IP Traffic Capture via M2M
...               Test case names match the QC specification.
Library           traffic_capture_library.py
Library           OperatingSystem
Library           Process
Suite Setup       Clean Up Old Pcap Files
*** Variables ***
${BASE_CU_URL}       https://10.53.8.29
${BASE_DU_URL}       https://10.53.8.27
${USERNAME}       Nemuadmin
${PASSWORD}       Nokia@123
${PYTHON}         python
*** Test Cases ***
[1]CB009923_A08_vCU_Capturing_IP_packet_information_in_PCAP_format_using_M2M_at_Point_B
    ${result}=    Perform Traffic Capture
    ...    base_url=${BASE_CU_URL}
    ...    username=${USERNAME}
    ...    password=${PASSWORD}
    ...    action=full_capture
    ...    plane_type=cplane
    ...    pod_names=po-oamext-0
    ...    measurement_point=Transport_Interface
    ...    pcap_filter=sctp
    Log To Console    \nStatus: ${result}[0], Packet Count: ${result}[1]
    Should Be Equal As Strings    ${result}[0]    SUCCESS
    ${count}=    Convert To Integer    ${result}[1]
    Should Be True    ${count} > 0      msg=FAIL: ESP/ISAKMP packet count was not greater than 0!
[1]CB009923_A08_vDU_Capturing_IP_packet_information_in_PCAP_format_using_M2M_at_Point_B
    ${result}=    Perform Traffic Capture
    ...    base_url=${BASE_DU_URL}
    ...    username=${USERNAME}
    ...    password=${PASSWORD}
    ...    action=full_capture
    ...    plane_type=cplane
    ...    pod_names=po-oamext-0
    ...    measurement_point=Transport_Interface
    ...    pcap_filter=sctp or isakmp
    Log To Console    \nStatus: ${result}[0], Packet Count: ${result}[1]
    Should Be Equal As Strings    ${result}[0]    SUCCESS
    ${count}=    Convert To Integer    ${result}[1]
    Should Be True    ${count} > 0      msg=FAIL: ESP/ISAKMP packet count was not greater than 0!
*** Keywords ***
Clean Up Old Pcap Files
    Log To Console    Cleaning old gNB*.gz
    Remove Files    ${CURDIR}/gNB*.gz