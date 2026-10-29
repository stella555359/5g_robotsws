*** Settings ***
Documentation
...     [Author]        "Shivani Patil"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Procedure] "The test case covers basic check for link between Airphone and vDU along with the alarms"
...     [Date]      "07-03-2024"
...     [QC_Path]   "QC_Path in Test Plan"
...     [QC_ID]     "Verify link status between Airphone and vDU"
...     [Funtion_Hash_Tags] "TRS - Security"
...     [Feature_ID]            "CB010411-J-5GC002144"
...     [Requirement ID]    "CLOUD_TRS_24060, CLOUD_TRS_24064, CLOUD_TRS_24046, CLOUD_TRS_24082 "
...     [Validation_Status]    "Validated"
...     [Validated_TestLine]    "6004"
...     [Config]    "This testcase needs basic scf with vDU integrated to RAN state"
...     [scf_file]  "Base_SCF.xml"

Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/SWN_common_keywords_CB010411.robot
Resource        ${CURDIR}/../resources/common_Cloud_keywords.robot

Suite Teardown      Run Keywords    Setup Oamops    dut=vdu_1      alias=default   AND     Collect Snapshot
...     dut=vdu_1  operation_timeout=300   alias=default   AND     Run Keyword And Ignore Error    Teardown Oamops
...      dut=vdu_1     alias=default

*** Test Cases ***
[1][1.0] CB010411-J_5GC002144_D_fhuc_vlanid_and_PCP_configuration_on_swnMultiVlanforvDUuP_for_multiple_ECPRI_RUs_SWN
    Load base scf
    Load LBM configurations
    Change the service account password
    Enable ssh access from rannic
    Sleep   30
    Check BTS status
    Login to RANNIC and capture the LBM traffic at rfoe4 interface and copy
    Verify LBM traffic in the pcap file
    Change the pcp value and verify same in pcap
    Verify Loopback failure alarm
    Clear Loopback alarm
    Disable actLbmOnFronthaul flag
