*** Settings ***
Documentation
...     [Author]            "Punith"
...     [Maintenance]       "TRS I & V Tools Bangalore Team"
...     [Procedure]         "The test case covers basic check for concurrent configuration with ipsec on vCU with psk and verifies Ipsec alarms"
...     [Date]              "21-10-2024"
...     [QC_Path]           "QC_Path in Test Plan"
...     [QC_ID]             "CB010465-D-c_TRS_CB010465_5GC002215_ipv4_ipv6_concurrent_ipsec_tunnels"
...     [Funtion_Hash_Tags]     "TRS -IPSEC"
...     [Feature_ID]            "CB010465"
...     [Requirement ID]        ""
...     [Validation_Status] "Validated"
...     [Validated_TestLine]    "TL006"
...     [Config]            "This testcase needs basic scf with ipsec configuration"
...     [scf_file]          "basic_scfc_vcu_ipsec.xml"

Resource        ${CURDIR}/resources/common_keywords_CB010465.robot

Force Tags      CA_E2ET_BTSTRSPZ        vCUCNF00      vCUCNF25R1     4G_FDD       QCD_MN_RAN        QCP_RAN_VRF      CRT

***Test cases***
[1]CB010465-D-c_TRS_CB010465_5GC002215_ipv4_ipv6_concurrent_ipsec_tunnels
    Perform Concurrent ipsec configuration on vcu and vdu
    Sleep   120
    Perform PSK Configuration on vcu and vdu
    Perform ipsec configuration for PSK on VM
    Sleep   60
    Verify ipsec status
    Call Setup    5g=5g_basic_setup_cfg:data      parallel=${False}      verify_attach=${False}    attach=${False}     timeout=120
    Attach UE and send ul dl traffic
    Send Traffic and Verify SentESP and ReceivedESP Counter
    Perform PMTU Discovery Configuration on vcu and vdu
    Verify IPSEC Alarms