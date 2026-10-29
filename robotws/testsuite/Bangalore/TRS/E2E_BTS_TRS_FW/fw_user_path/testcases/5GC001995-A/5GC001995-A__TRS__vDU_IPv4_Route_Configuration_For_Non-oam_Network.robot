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
Resource        ${CURDIR}/../5GC001995-A/resources/common_keywords_1995-A.robot

Suite Setup     Setup Oamops    dut=vdu_1    alias=vdu
Suite Teardown  Teardown Oamops    dut=vdu_1     alias=vdu



*** Test Cases ***
TRS__vDU_IPv4_Route_Configuration_For_Non-oam_Network__5GC001995-A


     Load scf

     Check PODs IPv4 main static route info via CLI

     Execute IPv4 Packets Engress Testing

