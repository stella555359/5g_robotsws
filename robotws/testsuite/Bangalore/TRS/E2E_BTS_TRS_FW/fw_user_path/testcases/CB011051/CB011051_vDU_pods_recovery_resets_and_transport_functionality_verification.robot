*** Settings ***
Documentation
...     [Author]            "Punith K"
...     [Maintenance]       "TRS I & V Tools Bangalore Team"
...     [Procedure]         "The test case covers rannic reset and pods recovery with ipsec configuration"
...     [Date]              "21-10-2024"
...     [QC_Path]           "QC_Path in Test Plan"
...     [QC_ID]             "-"
...     [Funtion_Hash_Tags]     "TRS"
...     [Feature_ID]            "CB011051"
...     [Requirement ID]        ""
...     [Validation_Status] "Validated"
...     [Validated_TestLine]    "TL006"
...     [Config]            "This testcase needs basic scf with ipsec configuration"

Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/common_keywords_CB011051.robot

Force Tags      CLOUD_F    CA_VRF_BLR2        vDUCNF00        vDUCNF25R3    SBTS24R3      QCD_MN_RAN       QCP_RAN_VRF        CRT

***Test cases***
[1]CB011051_vDU_pods_recovery_resets_and_transport_functionality_verification.
    Setup Oamops    dut=vdu_465    alias=vdu_465
    Setup Oamops    dut=vcu_465    alias=vcu_465
    Perform Commissioning on vcu and vdu    ${SCFC_vCU}  ${SCFC_vDU}
    Sleep   300
    Perform Concurrent ipsec configuration on vcu and vdu
    Sleep   120
    Perform PSK Configuration on vcu and vdu
    Perform ipsec configuration for PSK on VM
    Sleep   60
    Verify ipsec status
    Call Setup    5g=5g_basic_setup_cfg:data    parallel=${False}   verify_attach=${False}  attach=${False}  timeout=120
    Attach UE and send ul dl traffic
    Sleep   60
    Send Traffic and Verify SentESP and ReceivedESP Counter
    Stop traffic and detach UE
    Reset    operation=reset_rannic     rannic_dn=${RANNIC_MOC}   dut=vdu_465    timeout=100    alias=vdu_465
    Perform Pods Restart    vdu_465
    Sleep   120
    Verify ipsec status
    Call Setup    5g=5g_basic_setup_cfg:data    parallel=${False}   verify_attach=${False}  attach=${False}  timeout=120
    Attach UE and send ul dl traffic
    Sleep   60
    Send Traffic and Verify SentESP and ReceivedESP Counter
    Stop traffic and detach UE