*** Settings ***
Documentation
...     [Author]        "Sahana TC Prajwal K"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Procedure] "The test case covers basic check for link between Airphone and vDU along with the alarms"
...     [Date]      "05-03-2024"
...     [QC_Path]   "QC_Path in Test Plan"
...     [QC_ID]     "Verify FH Ipsec on Non IPsec capable radios and Alarms"
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

Suite Setup     Setup Oamops    dut=vdu_9857     alias=vdu
Suite Teardown  Teardown Oamops    dut=vdu_9857     alias=vdu

*** Test Cases ***
[1][1.0] TC04_CB008817-CR_Verify RU IPSec incapability handling by DU

    Setup Oamops    dut=vdu_9857    alias=vdu
    Load base scf non ipsec capable
    Modify actEcpriRuMPlaneSecurity flag to Enabled_noipsec
    Log    Enabled case with default Plaintext
    sleep   300
    Verify Alarm    faultid=10    should_exist=${True}    dut=vdu_9857       occurrences=1       alias=vdu
    Verify Alarm    faultid=4667    should_exist=${True}    dut=vdu_9857       occurrences=1        alias=vdu
    Log   RU shall be blocked Passed
    Login to oamfh and verify ipsec tunnels for non ipsec capable
    Modify actEcpriRuMPlaneSecurity flag to Disabled_noipsec
    sleep  300
    Verify Alarm    faultid=4667    should_exist=${False}    dut=vdu_9857       occurrences=0        alias=vdu
    Verify Alarm    faultid=10    should_exist=${False}    dut=vdu_9857       occurrences=0       alias=vdu
    FH IPsec tunnel clear for non ipsec radio
    Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      dut=vdu_9857      alias=vdu

    Modify actEcpriRuMPlaneSecurity flag to Optional_noipsec
    Log   Optional case with Plaintext True
    sleep   300
    Verify Alarm    faultid=4667    should_exist=${True}    dut=vdu_9857       occurrences=1        alias=vdu
    Verify Alarm    faultid=10    should_exist=${False}    dut=vdu_9857       occurrences=0       alias=vdu
    Log     RU is online with Fault id 4667 Passed
    Login to oamfh and verify ipsec tunnels for non ipsec capable
    Log   Plaintext False
    sleep   500
    Modify PlainText to False
    sleep   300
    Verify Alarm    faultid=4667    should_exist=${True}    dut=vdu_9857       occurrences=1        alias=vdu
    Verify Alarm    faultid=10    should_exist=${True}    dut=vdu_9857       occurrences=1       alias=vdu
    Log     RU is blocked with Fault ID 10 and Fault ID 4667 Passed
    Modify actEcpriRuMPlaneSecurity flag to Disabled_noipsec
    sleep   900
    Verify Alarm    faultid=4667    should_exist=${False}    dut=vdu_9857       occurrences=0        alias=vdu
    Verify Alarm    faultid=10    should_exist=${False}    dut=vdu_9857       occurrences=0       alias=vdu
    FH IPsec tunnel clear for non ipsec radio
    Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      dut=vdu_9857      alias=vdu
    [Teardown]    Modify actEcpriRuMPlaneSecurity flag to Disabled_noipsec
