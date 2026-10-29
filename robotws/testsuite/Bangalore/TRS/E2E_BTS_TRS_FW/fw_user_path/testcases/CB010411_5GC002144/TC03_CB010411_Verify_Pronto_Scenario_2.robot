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
...     [Requirement ID]    " PR755270 PR631197"
...     [Validation_Status]    "Validated"
...     [Validated_TestLine]    "10411"
...     [Config]    "This testcase needs basic scf with vDU integrated to RAN state"
...     [scf_file]  "Actual_trscran8_base_scf.xml"


Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/common_keywords_CB010411.robot

Suite Teardown  Run Keywords    Setup Oamops    dut=vcu_10411      alias=default   AND     Collect Snapshot
...     dut=vcu_10411  operation_timeout=300   alias=default   AND     Run Keyword And Ignore Error    Teardown Oamops
...      dut=vcu_10411     alias=default

*** Test Cases ***
[1]TC01_CB010411_Verify_Pronto_Scenario_2
    Load base scf
    Load LBM configurations
    Change the service account password
    Enable ssh access from rannic
    Compare vlanID for LCELNR
    Login to RANNIC and capture the LBM traffic at rfoe4 interface and copy
    Verify LBM traffic for both vlans
    Perform warm reset from WebEM
    Sleep   300
    Change the service account password
    Enable ssh access from rannic
    Login to RANNIC and capture the LBM traffic at rfoe4 interface and copy
    Verify LBM traffic for both vlans
