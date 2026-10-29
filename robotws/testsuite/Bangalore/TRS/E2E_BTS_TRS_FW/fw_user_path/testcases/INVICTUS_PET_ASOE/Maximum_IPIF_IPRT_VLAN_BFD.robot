*** Settings ***
Documentation
...                 [Procedure]    "The test case is to verify BFD configurations both Ipv4 and Ipv6 with maximum session support
...                 as part of first case.The second case to verify maximum alarm support"
...                 [Date]    "25-05-20"
...                 [Author]    "Madhu Chinthakindi"
...                 [QC_Path]    "QC_Path in Test Plan"
...                 [QC_ID]    "QC_ID in Test Lab for reporting"
...                 [Funtion_Hash_Tags]    "FIPR","BFD"
...                 [Feature_ID]    "5GC000986"
...                 [Validation_status]    "Validated and Passed"
...                 [Validated_TestLine]    "5G-9008"
...                 [Config]    "No BFD configurations should have the preloaded scf as BFD configuration are cretaed by delta for this case"

Variables           ta_e2e_bts_trs_fw
Resource            ${CURDIR}/../resources/Common_BFD.robot
Resource            ${CURDIR}/../resources/common_keywords.robot
Resource            ${CURDIR}/../resources/Admin_Common_Library.robot
Library             random

# Suite Setup    Pre-conditions for testsuite
# Suite Teardown    Post-conditions for testteardown
Suite Setup         Setup Oamops
Suite Teardown      Teardown Oamops


*** Test Cases ***
[1]CB010762-B_B1_Feature_10_operators_MAX_CA_MAX_CRL.
    # Perform Commissioning    scf_file=${Basic_Minimum_scf}    verify_bts_status=False    timeout=400    alias=default
    # Sleep    360
    Perform Recommissioning    type=delta    delta_file=${Maximum_VLANIF}    timeout=300
    Sleep    30
    Perform Recommissioning    type=delta    delta_file=${Maximum_IPIF}    timeout=300
    Sleep    90
    Perform Recommissioning    type=delta    delta_file=${Maximum_IPRT}    timeout=300
    Sleep    30
    Perform Recommissioning    type=delta    delta_file=${Maximum_IPRTv6}    timeout=300
    Sleep    30
    Add routes on Vm for Maximum Vlan

*** Keywords ***
Add routes on Vm for Maximum Vlan
    Run    bash -c 'for i in {3209..3344}; do sudo ip link add link eth3 name eth3.$i type vlan id $i; done'
    Run    bash -c 'for i in {16..151}; do j=$((i + 3193)); sudo ip a a 10.0.$i.1/24 dev eth3.$j; done'
    Run    bash -c 'for i in {16..151}; do j=$((i + 3193)); sudo ip -6 a a fc00::$i:1/120 dev eth3.$j; done'
    Run    bash -c 'for i in {3209..3344}; do sudo ip link set dev eth3.$i up; done'