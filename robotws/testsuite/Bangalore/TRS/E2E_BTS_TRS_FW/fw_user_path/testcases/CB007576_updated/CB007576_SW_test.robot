*** Settings ***
Documentation	[Maintenance]   "TRS I & V Tools Bangalore Team"
...     	[Procedure] "The test case is planned to check Multiple RUs Mplane FH Configuration discovery in switched connectivity mode"
...     	[Date]      "20-02-24"
...    		[Author]        "Indraja"
...     	[QC_Path]   "Root\Test_Sets\Trunk\New_Features\BB_TRS_VRF_ET"
...     	[QC_ID]     "341852"
...    		[Funtion_Hash_Tags] "SWN CLOUD"
...     	[Feature_ID]            "CB007576"
...     	[Validated_TestLine]    "trs-cran8"


Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/CB007576_commonkeywords.robot


Suite Setup     Setup Oamops    dut=vdu_7576      alias=default
Suite Teardown  Run Keywords    Setup Oamops    dut=vdu_7576      alias=default   AND     Collect Snapshot
...     dut=vdu_7576  operation_timeout=300   alias=default   AND     Run Keyword And Ignore Error    Teardown Oamops
...      dut=vdu_7576     alias=default



*** Test Cases ***
[1][1.0] Copy_of_CB007576_B1_Multiple RUs Mplane FH Configuration discovery in switched connectivity mode
    Setup Oamops    dut=vdu_7576    alias=conn23
    Load SCF    ${base_SW_scf}
    Reboot Airphone
    Sleep   300
    Capture DHCP packets
    Verify DHCP packets in swn
    Comment	Delta commissioning to change pcp and dscp value
    Perform Recommissioning     dut=vdu_7576    type=delta      delta_file=${delta_to_change_pcp}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=conn23
    Reboot Airphone
    Sleep   60
    Capture DHCP packets
    Verify DHCP packets with pcp in swn
    Comment	Delta commissioning to check for 61672 fronthaul mismatch alarm
    Setup Oamops    dut=vdu_7576    alias=conn22
    Perform Recommissioning     dut=vdu_7576    type=delta      delta_file=${incorrect_vlan_swn_delta}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=conn22
    Sleep   300
    Verify Alarm    alias=conn22    faultid=61672    severity=critical    should_exist=${True}    occurrences=1    dut=vdu_7576
    Teardown Oamops     dut=vdu_7576     alias=conn22
    Setup Oamops    dut=vdu_7576    alias=conn25
    Perform Recommissioning     dut=vdu_7576    type=delta      delta_file=${corrected_vlan_swn_delta}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=conn25
    Sleep   300
    Verify Alarm    faultid=61672    severity=critical    should_exist=${False}    occurrences=1    dut=vdu_7576    alias=conn25
    Teardown Oamops     dut=vdu_7576     alias=conn25
    Run Keyword And Ignore Error    Teardown Oamops     dut=vdu_7576     alias=conn23

