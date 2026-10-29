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
Resource        ${CURDIR}/../5GC001997-B/resources/common_keywords_1997.robot

Suite Setup     Setup Oamops    dut=vdu_1    alias=vdu
Suite Teardown  Teardown Oamops    dut=vdu_1     alias=vdu



*** Test Cases ***
[1][1.0] TRS__vDU_SCTP_Association_Establishment_And_Termination_Over_IPv4_On_F1_Interface__5GC001997-B

    Configure Value To Parameter:sctpWaitTimeInitSeqRetry

     Perform Commissioning      scf_file=${vdu_sctp_scf}      timeout=300      dut=vdu_1            alias=vdu
     BuiltIn.Sleep          200

   Start Wireshark At vDU f1-C Interface@OAMCP POD:CPRT container To Check DSCP

    F1C Pcap CPRT

    BuiltIn.Sleep     200

    Check The Fault Should Be Reported

    Recover SCTP Packets between vCU and vDU

    BuiltIn.Sleep        120

    Check The Fault Should Be Canceled
