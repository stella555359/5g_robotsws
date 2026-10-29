*** Settings ***
Documentation
...     [Author]            "Punith K"
...     [Maintenance]       "TRS I & V Tools Bangalore Team"
...     [Procedure]         "The test case covers ipsec failure counter verification for vdu and vcu with certificate"
...     [Date]              "21-10-2024"
...     [QC_Path]           "QC_Path in Test Plan"
...     [QC_ID]             "TRS_CB010465_5GC002215_ipsec_failure_counterVerification_for_vdu_and_vcu"
...     [Funtion_Hash_Tags]     "TRS - Security"
...     [Feature_ID]            "CB010465"
...     [Requirement ID]        ""
...     [Validation_Status] "Validated"
...     [Validated_TestLine]    "TL006"
...     [Config]            "This testcase needs basic scf with ipsec configuration"

Resource        ${CURDIR}/resources/common_keywords_CB010465.robot

Force Tags      CA_E2ET_BTSTRSPZ        vCUCNF00      vCUCNF23R3     4G_FDD       QCD_MN_RAN        QCP_RAN_VRF        CRT

*** Test cases ***
[1]CB010465-G-b_TRS_CB010465_5GC002215_ipsec_failure_counterVerification_for_vdu_and_vcu
    Perform ipsec configuration on vcu and vdu
    Sleep   120
    Certificate Configuration on vcu and vdu    RSA     dbts    cbts
    Perform ipsec configuration on VM
    Verify ipsec status
    Call Setup    5g=5g_basic_setup_cfg:data      parallel=${False}      verify_attach=${False}    attach=${False}     timeout=120
    Attach UE and send ul dl traffic
    Create Bypass Policy and Verify sentPacketMatchBypassPol and receivedPacketMatchBypassPol Counter
    Send ESP packets with different SPI value and Verify ipsecSaNotFound counter
    Send Unencrypted packets and Verify recvUnprotPacketMatchProtPol counter
    Create Discard Policy and Verify setPacketMatchDiscPol and receivedPacketMatchDiscPol Counter
    Verify failedSAEstablishments counter