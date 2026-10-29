*** Settings ***

Documentation
...     [Documentation]
...     [Author]        "Sushma R"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Procedure] "The test case checks the support for TWAMP rate limiting functionality on vCU"
...     [Date]      "30-05-2023"
...     [QC_Path]   "QC_Path in Test Plan"
...     [QC_ID]     "Verify rate limiting on vCU for TWAMP"
...     [Funtion_Hash_Tags] "Rate Limiting"
...     [Feature_ID]            "CB009373-A"
...     [Requirement ID]    "TT_TTSEC.1839"
...     [Validation_Status]    "Validated"
...     [Validated_TestLine]    "9373"
...     [Config]    "This testcase requires basic configuration with oam IP and TWAMP MOC"
...     [scf_file]  "Actual_configuration_scf_MRBTS-5562_vCU5562_20230620-1614_Netact.xml"


Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../CB007406/resources/common_keywords_7406.robot

Suite Setup     Setup Oamops    dut=vcu_1    alias=vcu
Suite Teardown  Teardown Oamops    dut=vcu_1     alias=vcu


*** Test Cases ***
[1][1.0] CB007406_J_vcu_ip_ping_application_with_webem_ip

     Vcu Deploy Successfully, All Pods/Containers Startup Normally

     Alarm 61661 VLAN_MATCHING_FAILURE Is Not Raised

     Re-commissioning SCF Which Contains Unspecific Vlan Interface Name and verifying alarm

     verify Ping connectivity for reachable IP

    verify Ping connectivity for Unreachable IP
