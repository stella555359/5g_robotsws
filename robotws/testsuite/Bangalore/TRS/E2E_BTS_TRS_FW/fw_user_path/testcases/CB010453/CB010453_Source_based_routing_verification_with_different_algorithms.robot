*** Settings ***
Documentation
...     [Author]            "Punith K"
...     [Maintenance]       "TRS I & V Tools Bangalore Team"
...     [Procedure]         "The test case covers source based routing with different algorithms"
...     [Date]              "21-10-2024"
...     [QC_Path]           "QC_Path in Test Plan"
...     [QC_ID]                  "--"
...     [Funtion_Hash_Tags]     "TRS -SBR"
...     [Feature_ID]            "CB010453"
...     [Requirement ID]        ""
...     [Validation_Status]    "Validated"
...     [Validated_TestLine]    "TL006"
...     [Config]               "This testcase needs basic scf"

variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/CB010453_Keywords.robot
Resource 		taf/rfrl/trs_e2e_fw/setup/framework.robot

Force Tags      CLOUD_F    CA_VRF_BLR2        SBTS00    SBTS25R3      QCD_MN_RAN       QCP_RAN_VRF        CRT

Suite Setup                 Pre-conditions for testsuite
Suite Teardown              Post-conditions for testteardown

*** Test cases ***
[1]CB010453_Source_based_routing_verification_with_different_algorithms
    Sends the Egress packet with matching route policy
    Sends the Egress packet without matching route policy
    Sends the Egress packet with matching route policy with route
    Sends the Egress packet with matching route policy without route
    Modify Routing table and verify modified value
    Delete Routing table and verify deleted value
    Reset Bts   verify_bts=True     req_rat=all     should_be_onair=False
    Verify persistent routing tables
    Adding a source based routing policy fails due to no routing table