*** Settings ***
Documentation	[Author]        "Shivani Patil"
...     	[Maintenance]   "TRS I & V Tools Bangalore Team"
...     [	Procedure] "The test case covers basic check for link between Airphone and vDU along with the alarms"
...     	[Date]      "05-03-2024"
...     	[QC_Path]   "QC_Path in Test Plan"
...     	[QC_ID]     "Verify link status between Airphone and vDU"
...     	[Funtion_Hash_Tags] "TRS - Security"
...     	[Feature_ID]            "CB010411"
...     	[Requirement ID]    "CLOUD_TRS_24060, CLOUD_TRS_24064, CLOUD_TRS_24046, CLOUD_TRS_24082 "
...     	[Validation_Status]    "Validated"
...     	[Validated_TestLine]    "10411"
...     	[Config]    "This testcase needs basic scf with vDU integrated to RAN state"
...     	[scf_file]  "Actual_trscran8_base_scf.xml"


Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/common_keywords_CB010411.robot
Resource        ${CURDIR}/../resources/common_Cloud_keywords.robot

Suite Teardown  Run Keywords    Setup Oamops    dut=vdu_10411      alias=default   AND     Collect Snapshot
...     dut=vdu_10411  operation_timeout=300   alias=default   AND     Run Keyword And Ignore Error    Teardown Oamops
...      dut=vdu_10411     alias=default



*** Test Cases ***
[1][1.0] Copy_of_[1]CB010411_J_5GC002144_Verify_Loopback_mechanism_for_C-U_Plane_transport_connectivity_NFTR
    Load base scf
    Sleep   600
    Change the service account password
    Enable ssh access from rannic
    Login to RANNIC and capture the LBM traffic at rfoe4 interface
    Verify LBM traffic in the pcap file
    Change the pcp value and verify same in pcap
    Verify Alarms
