*** Settings ***
Suite Setup         Suite Setup 8927
Suite Teardown      Suite Teardown 8927

Documentation
...    author: Li Na
...    contact: na.li@nokia-sbell.com


Resource        ./Resources/CB008927_common_keyword.robot
Variables       ./Resources/CB008927_modify_para.py




*** Test Cases ***
[1]CB008927-G-B2-02-Robustness_multi_time_HO_bi_derection_Rat0_Rat1_MUE
    [Tags]    Trunk
    [Setup]    Case Suit Setup HR1
    modify the parameter case B2
    Block and unblock Gnb1&Gnb2 cell B2
    UE3 Attach Gnb1 and check throughput
    UE3 Attach Gnb1-Gnb2 Switch twice
    log to console    CB008927-G-IWK17
    [Teardown]    G_B2_Case_Teardown

[1]CB008927-G-IWK12-01-initial_DeltaCqi_clamp_VONR_HO_A3_Rat1
    [Tags]    Trunk
    [Setup]    Case Suit Setup HR1
    modify the parameter case IWK12
    Block and unblock Gnb1&Gnb2 cell
    Adjust PA and 3UE attach Gnb2
    UE123 Attach Gnb1-Gnb2 and check log&throughput
    log to console    CB008927-G-IWK17
    [Teardown]    IWK12_Case_Teardown

[1]CB008927-G-IWK15-01-VONR_HO_A3_From_RAT1_To_RAT1
    [Tags]    Trunk
    [Setup]    Case Suit Setup HR1
    modify the parameter case IWK15
    Adjust PA and Block cell IWK15
    UE Attach and start traffic
    UE Attach Gnb1-Gnb2 and check log&throughput case iwk15
    log to console    CB008927-G-IWK17
    [Teardown]    IWK15_Case_Teardown


[1]CB008927-G-IWK17-01-multi-GBR-schedule-new-UE-add-RAT1
    [Tags]    Trunk
    [Setup]    Case Suit Setup IWK17
    modify the parameter case IWK17
    Adjust PA and Block cell case IWK17
    UE1234 Attach Gnb1 and check log&throughput case iwk17
    log to console    CB008927-G-IWK17
    [Teardown]    IWK17_Case_Teardown


[1]CB008927-G-HR1-01-MCS-upsizing-for-NGBR-HR-DRBs-Setup-RAT1
    [Tags]    Trunk
    [Setup]    Case Suit Setup HR1
    modify the parameter case HR1
    Adjust PA and Block cell case HR1
    UE3 Attach Gnb1 and check log&throughput case HR1
    log to console    CB008927-G-IWK17
    [Teardown]    HR1_Case_Teardown


[1]CB008927-G-IWK9-02-multi-GBR-Small_BWP_accept_RAT1
    [Tags]    Trunk
    [Setup]    Case Suit Setup IWK17
    log to console    CB008927-G-IWK17
    [Teardown]    IWK9_Case_Teardown


*** Keywords ***
UE3 Attach Gnb1-Gnb2 Switch twice
    UE3 Attach Gnb1-Gnb2 and check log&throughput    ho_direction=GNB1_TO_GNB2
    UE3 Attach Gnb1-Gnb2 and check log&throughput
    ...    port_list_2=${port_list[4:8]}    filename0=Tcpdump_Gnb02    filename1=Tcpdump_Gnb12
    ...    text_name_source=Tcpdump_Gnb12    resourceAllocation_target=${resourceAllocation_1}
    ...    text_name_target=Tcpdump_Gnb02    attached_pci=${attached_pci_244}
    ...    gnb_index=0    cell_check_list=${cell_list_gnb1[2:4]}
    ...    ho_direction=GNB2_TO_GNB1
    [Teardown]    detach and stop tup B2
