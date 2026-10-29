*** Settings ***
Documentation
...     [Author]        "Shivani Patil"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Procedure] "The test case covers pronto scenario for CFM traffic by enabling/disabling actLBm flag"
...     [Date]      "05-03-2024"
...     [QC_Path]   "QC_Path in Test Plan"
...     [QC_ID]     ""
...     [Funtion_Hash_Tags] "TRS - Security"
...     [Feature_ID]            "CB010411"
...     [Requirement ID]    " PR739086 PR768930 PR758410"
...     [Validation_Status]    "Validated"
...     [Validated_TestLine]    "10411"
...     [Config]    "This testcase needs basic scf with vDU integrated to RAN state"
...     [scf_file]  "Actual_trscran8_base_scf.xml"


Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/common_keywords_CB010411.robot
Resource        ${CURDIR}/../resources/common_Cloud_keywords.robot

Suite Teardown  Run Keywords    Setup Oamops    dut=vdu_10411      alias=default   AND     Collect Snapshot
...     dut=vdu_10411  operation_timeout=300   alias=default   AND     Run Keyword And Ignore Error    Teardown Oamops
...      dut=vdu_10411     alias=default

*** Test Cases ***
[1]TC01_CB010411_Verify_Pronto_Scenario_1
    Load base scf
    Load LBM configurations
    Change the service account password
    Enable ssh access from rannic
#    FOR   ${num_iter}    IN RANGE   3
#        [Documentation]        Reset RANNIC keyword is not supported. Jira SMTRS-33186 raised.
#        Reset RANNIC
        Sleep   60
        Setup Oamops    dut=vdu_10411      alias=default_0
        Verify Alarm    faultid=61009    should_exist=${True}   occurrences=2    dut=vdu_10411    alias=default_0
        Teardown Oamops      dut=vdu_10411     alias=default_0
        Disable actLbmOnFronthaul flag
        Setup Oamops    dut=vdu_10411      alias=default_1
        Verify Alarm    faultid=61009    should_exist=${False}    dut=vdu_10411    alias=default_1
        Teardown Oamops      dut=vdu_10411     alias=default_1
        Sleep   30
        Enable ssh access from rannic
        Login to RANNIC and capture the LBM traffic at rfoe4 interface and copy
        Verify CFM traffic in the pcap file
        Enable actLbmOnFronthaul flag
        Sleep   60
        Setup Oamops    dut=vdu_10411      alias=default_3
        Verify Alarm    faultid=61009    should_exist=${False}    dut=vdu_10411    alias=default_3
        Teardown Oamops      dut=vdu_10411     alias=default_3
        Login to RANNIC and capture the LBM traffic at rfoe4 interface and copy
        Verify LBM traffic in the pcap file
#    END
