*** Settings ***
Documentation     © Nokia
...               Author: Bhakti Patel
...               Contact: bhakti.ka_patel@nokia.com
...               The aim of this feature is to verify successful gNB UE Radio Capability retrieval procedure,
...               ensuring successful exchange of Chipset and RAN Identification information
...               between UE and Network for supporting UEs.
Resource          resources/Keywords/CB009173_KW.robot
Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown


*** Variables ***
${UE_ID}              1
${gw_ID}              1


*** Test Cases ***
[1][1.0] CB009173_D_B1_E2E_Validate_E2E_Call_Flow_With_Correct_Infrastructure_Information_Exchange
    [Documentation]    Verify successful chipset and RAN information exchange between UE and Network.
    [Tags]    QC_244213    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Prepare For Test Case CB009173
    LOG TO CONSOLE    \n Starting the case ...
    Start Pcap Collection In GNB CU    gnbTcpdump0    -i any -s0
    UE Register Should Be Successful For SA    ${UE_ID}    ${gw_ID}
    ${pcap_file0}    Stop Pcap Collection In GNB CU    gnbTcpdump0
    Get Chipset And RAN ID Info From UEcapinfo    ${pcap_file0}
    Get EUTRA Information From UEcapinfo          ${pcap_file0}
    Start Pcap Collection In GNB CU    gnbTcpdump1    -i any -s0
    Sleep    30s
    UE NG CTX Release    by=amf    id=1    cause=NAS_normal_release
    Sleep    10s
    UE IM Exit    id=1
    Sleep    10s
    ${pcap_file1}    Stop Pcap Collection In GNB CU    gnbTcpdump1
    UE Deregister Should Be Successful For SA    ${UE_ID}
    Check For Dummy4 UE Radio Access Cap Information    ${pcap_file1}
    Run Keyword And Ignore Error      Check If UE Cap Enquiry Is Not Sent By GNB           ${pcap_file1}
    [Teardown]    Tear Down For Test Case 9173
