*** Settings ***
Documentation
...     [Author]        "Shivani Patil"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Procedure] "The test case covers basic check for link between Airphone and vDU along with the alarms"
...     [Date]      "05-03-2024"
...     [QC_Path]   "QC_Path in Test Plan"
...     [QC_ID]     "Verify link status between Airphone and vDU"
...     [Funtion_Hash_Tags] "TRS - Security"
...     [Feature_ID]            "CB010411-J-5GC002144"
...     [Requirement ID]    "CLOUD_TRS_24060, CLOUD_TRS_24064, CLOUD_TRS_24046, CLOUD_TRS_24082 "
...     [Validation_Status]    "Validated"
...     [Validated_TestLine]    "10411"
...     [Config]    "This testcase needs basic scf with vDU integrated to RAN state"
...     [scf_file]  "Base_SCF.xml"


Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/common_keywords_CB010411.robot
Resource        ${CURDIR}/../resources/common_Cloud_keywords.robot

Suite Teardown  Run Keywords    Setup Oamops    dut=vdu_10411      alias=default   AND     Collect Snapshot
...     dut=vdu_10411  operation_timeout=300   alias=default   AND     Run Keyword And Ignore Error    Teardown Oamops
...      dut=vdu_10411     alias=default

*** Test Cases ***
[1]TC01_CB010411_Verify link between Airphone and vDU
    Load base scf
    Load LBM configurations
    Change the service account password
    Enable ssh access from rannic
    Check BTS status
    Login to RANNIC and capture the LBM traffic at rfoe4 interface and copy
    Verify LBM traffic in the pcap file
    Change the pcp value and verify same in pcap
    Verify Alarms

[10]TC02_CB010411_Verify Alarms
    Run Keyword If  '${PREV_TEST_STATUS}'=='PASS'   Log     This testcase is working
