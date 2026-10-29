*** Settings ***
Documentation
...     [Author]        "Sahana TC Prajwal K"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Procedure] "The test case covers basic check for link between Airphone and vDU along with the alarms"
...     [Date]      "05-03-2024"
...     [QC_Path]   "QC_Path in Test Plan"
...     [QC_ID]     "Verify FH Ipsec on IPsec capable radios P2P and Alarms"
...     [Funtion_Hash_Tags] "TRS - Security"
...     [Feature_ID]            "CB008817-CR-D"
...     [Requirement ID]    ""
...     [Validation_Status]    "Validated"
...     [Validated_TestLine]    ""
...     [Config]    "This testcase needs basic scf with vDU and vCU"
...     [scf_file]  "Base_SCF.xml"


Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/common_keywords_CB008817_CR.robot
Resource        ${CURDIR}/../resources/common_Cloud_keywords.robot

Suite Teardown      Run Keywords    Setup Oamops    dut=vdu_1      alias=default   AND     Collect Snapshot
...     dut=vdu_1  operation_timeout=300   alias=default   AND     Run Keyword And Ignore Error    Teardown Oamops
...      dut=vdu_1     alias=default

*** Test Cases ***

[1][1.0] TC02_CB008817_CR_Activation_Ipsec_RuProtectOptional_Fronthaul

    Setup Oamops    dut=vdu_1    alias=con1
    Load base scf       ${base_scf}
    Modify actEcpriRuMPlaneSecurity flag    ${FHIpsecOptional}
    Wait Until Keyword succeeds     10 min   10   Verify Alarm    faultid=10    should_exist=${True}    dut=vdu_1
    ...       occurrences=${alarm1}        alias=con1
    sleep   900
    Login to oamfh and verify ipsec tunnels for optional
    Log    Reset rannic and verify FH ipsec
    Reset RANNIC
    Login to oamfh and verify ipsec tunnels for optional
    Log    Reset vDU and verify FH ipsec
    Reset    operation=reset_bts    rat=5g    dut=vdu_1    alias=default    should_be_onair=${False}     verify_bts=${False}
    Sleep   900
    Setup Oamops    dut=vdu_1    alias=con1
    Login to oamfh and verify ipsec tunnels for optional
    Modify actEcpriRuMPlaneSecurity flag    ${FHIpsecDisabled}
    Wait Until Keyword Succeeds    10 min    10       Verify Alarm    faultid=10    should_exist=${True}    dut=vdu_1
    ...       occurrences=${alarm1}        alias=con1
    FH IPsec tunnel clear
    wait until keyword succeeds    10 min   10     Verify Alarm    faultid=10    should_exist=${False}    dut=vdu_1
    ...       alias=con1
    Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}         dut=vdu_1      alias=con1
    [Teardown]    Disable FH ipsec     ${FHIpsecDisabled}
