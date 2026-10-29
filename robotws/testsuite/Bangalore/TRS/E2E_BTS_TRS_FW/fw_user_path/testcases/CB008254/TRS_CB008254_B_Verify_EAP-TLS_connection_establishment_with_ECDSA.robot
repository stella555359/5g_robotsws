*** Settings ***
Documentation
...     [Documentation]
...     [Author]        "Sushma R"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Procedure] "The test case is planned to check the authentication through operator certificate"
...     [Date]      "19-10-2022"
...     [QC_Path]   "QC_Path in Test Plan"
...     [QC_ID]     "Verify_EAP-TLS connection_establishment_with_ECDSA"
...     [Funtion_Hash_Tags] "802.1X Authentication, EAP"
...     [Feature_ID]            "CB008254"
...     [Requirement ID]    "OM_GEN_SFS_Netsec_3200` "
...     [Validation_Status]    "Validated"
...     [Validated_TestLine]    "2205"
...     [Config]    "This testscript expects 802.1X profile to be present in IXR switch"
...     [scf_file]      "[Configuration_scf_MRBTS-2205_Synergy_ASIK_ABIL_5G_20220822-1430_EAP_config.xml]"


Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/common_keywords_cb008254.robot
Resource        ${CURDIR}/resources/common_keywords_cb008254_eap.robot

Suite Setup     Pre-conditions for testsuite
Suite Teardown  Post-conditions for testteardown

*** Variables***

***Test Cases***
[1]CB008254_B_Verify_EAP-TLS connection_establishment_with_ECDSA
    Comment     Load base.xml file
    Perform Commissioning   scf_file=${base_scf}    verify_bts_status=False     timeout=400     alias=default
    Sleep   100
    Comment     Step 2 Check EAP status on interface is Deactivated and EAP is Combined Mode
    Perform Recommissioning     type=param  param_path=${ethlk_path}    value=${ethlk_state_lock}    operation=update
    Sleep    60
    ${status}=            Query Admin Infomodel     query=get param ${EAP_Status}
    Should be equal     ${status}        Deactivated
    ${status}=     Get Parameter           param_path=${EAP_Mode}
    Should Be True      '${status}'=='Combined Authenticator initiated mode and Supplicant initiated mode'
    Comment     Step 3 Enable EAP on the switch and confirm EAP state is passed
    Configure certificate on BTS    ${rsa_cert_juniper}     ${ecdsa_cert}   ${rsa_password_juniper}
    ...     ${ecdsa_password_dcap}
    Install Certificate on Radius Server    ecdsa
    Capture EAP traffic     eap_capture_0
    Get Pcap Details
    Get Pcap details for ecdsa
    Perform Recommissioning     type=param  param_path=${rsakex}    value=${True}   operation=update
    Sleep   60
    Capture EAP traffic     eap_capture_1
    Get Pcap Details for rsakex
    Perform Recommissioning     type=param  param_path=${cbc}   value=${True}   operation=update
    Sleep   60
    Capture EAP traffic     eap_capture_2
    Get Pcap Details for cbc

    Comment     Step 4 Check for RSA certs
    Perform Recommissioning     type=delta      delta_file=${delta_scf_eap_rsa}
    ...     skip_parameter_relation_errors=${True}      timeout=300
    Install Certificate on Radius Server    rsa
    Capture EAP traffic     eap_capture_3
    Get Pcap Details
    Get Pcap details for rsa
    Comment     Step 5 Check for cbc and rsakex
    Perform Recommissioning     type=param  param_path=${rsakex}    value=${True}   operation=update
    Sleep   60
    Capture EAP traffic     eap_capture_4
    Get Pcap Details for rsakex
    Perform Recommissioning     type=param  param_path=${cbc}   value=${True}   operation=update
    Sleep   60
    Capture EAP traffic     eap_capture_5
    Get Pcap Details for cbc
