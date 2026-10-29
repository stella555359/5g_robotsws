*** Settings ***
Documentation	[Maintenance]   "TRS I & V Tools Bangalore Team"
...     	[Procedure] "The test case is planned to check Ipsec tunnel status and corresponding alarms are rasied and cleared as expected"
...     	[Date]      "20-03-24"
...     	[Author]        "Chiranjeevi V "
...     	[QC_Path]   "Root\Test_Sets\Trunk\VRF_BLR2\BB_TRS_VRF_ET\CRT\NF_Automated_Regression\TRSIV_NFTR_vRAN4.0"
...     	[QC_ID]     "347014"
...     	[Funtion_Hash_Tags] "SWN CLOUD"
...     	[Feature_ID]            "CB010265"
...     [	Validated_TestLine]    "10265"
...     [	Requirements]  "WBTS_SEC_55225;WBTS_SEC_61952"


Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/resources/25R3_CB010265_common_keyword_vDU.robot

Suite Setup     Run Keywords    Setup Oamops    dut=vdu_user    alias=vdu
...     AND     Setup Oamops    dut=vcu_user    alias=vcu
Suite Teardown  Run Keywords    Setup Oamops    dut=vdu_user      alias=vdu   AND   Setup Oamops    dut=vcu_user
...     alias=vcu   AND     Collect Snapshot    dut=vdu_user    operation_timeout=300   alias=vdu
...     AND     Run Keyword And Ignore Error    Teardown Oamops     dut=vdu_user    alias=vdu
...     AND     Run Keyword And Ignore Error    Teardown Oamops     dut=vcu_user    alias=vcu

*** Test Cases ***
[1]CB010265_CB005999_Verification_of_IPSEC_interaction_with_ECDSA_Certs_vDU
    Perform Commissioning      scf_file=${vdu_CB010265_base_scf_4}      timeout=300      dut=vdu_user    alias=vdu
    Perform Commissioning      scf_file=${vcu_CB010265_base_scf_2}      timeout=300      dut=vcu_user    alias=vcu
    Sleep   250
    Triger CMP IR to install certificates on vDU    RSA     ECDSA
    Restore default certificates and check ipsec status
    Sleep   30
    Verify alarms should exist as soon as no cert
    Triger CMP IR to install certificates on vDU    RSA     ECDSA
    Check Ipsec tunnel status in vDU
    Verify alarms should not exist in vDU
    Restore default certificates and configure different cert
    Sleep   30
    Verify alarms should exist in vDU after differetn delta cert
    Restore default certificates and configure correct cert
    Sleep   300
    Check Ipsec tunnel status in vDU after correct delat cert
    Verify alarms should not exist in vDU after correct delat cert
    Perform vDU reset
    Sleep   300
    Check Ipsec tunnel status in vDU after reboot
    Verify alarms should not exist in vDU after reboot
    Teardown Oamops    dut=vdu_user     alias=default
    [Teardown]     Teardown Oamops     dut=vcu_user     alias=vcu
