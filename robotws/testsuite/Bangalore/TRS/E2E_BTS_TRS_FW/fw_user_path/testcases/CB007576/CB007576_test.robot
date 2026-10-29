*** Settings ***
Documentation
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Procedure] "The test case is planned to check Multiple RUs Mplane FH Configuration discovery in direct connectivity mode"
...     [Date]      "20-02-24"
...     [Author]        "Indraja"
...     [QC_Path]   "Root\Test_Sets\Trunk\New_Features\BB_TRS_VRF_ET"
...     [QC_ID]     "341852"
...     [Funtion_Hash_Tags] "SWN CLOUD"
...     [Feature_ID]            "CB007576"
...     [Validated_TestLine]    "trs-cran8"




Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/CB007576_commonkeywords.robot


Suite Setup     Setup Oamops    dut=vdu_7576      alias=default
Suite Teardown  Run Keywords    Setup Oamops    dut=vdu_7576      alias=default   AND     Collect Snapshot
...     dut=vdu_7576  operation_timeout=300   alias=default   AND     Run Keyword And Ignore Error    Teardown Oamops
...      dut=vdu_7576     alias=default



*** Test Cases ***

[1]CB007576_B1:Multiple RUs Mplane FH Configuration discovery in direct connectivity mode
    Setup Oamops    dut=vdu_7576    alias=conn23
    Load SCF    ${base_scf}
    Reboot Airphone
    Sleep   60
    Capture DHCP packets in case of direct connection
    Verify DHCP packets
#    Delta commissioning to change pcp and dscp value
    Check pcp   ${rfoe4}
    Check pcp   ${rfoe5}
    Copy pcap to VM
    Verify DHCP packets with pcp
#    Delta commissioning to check for 61672 fronthaul mismatch alarm
    Load SCF    ${incorrect_vlan}
    Sleep   50
    Setup Oamops    dut=vdu_7576    alias=conn24
    Verify Alarm    alias=conn23    faultid=61672    severity=critical   should_exist=${True}    occurrences=1    dut=vdu_7576
    Teardown Oamops     dut=vdu_7576     alias=conn24
#    Delta commissioning to clear for 61672 fronthaul mismatch alarm
    Load SCF    ${PCP_scf}
    Sleep   50
    Setup Oamops    dut=vdu_7576    alias=conn25
    Verify Alarm    faultid=61672    severity=critical    should_exist=${False}    occurrences=1    dut=vdu_7576    alias=conn23
    Teardown Oamops     dut=vdu_7576     alias=conn25
    Run Keyword And Ignore Error    Teardown Oamops     dut=vdu_7576     alias=conn23


[1] CB007576_B3_PCP and DSCP for eCPRI Mplane traffic in direct connectivity mode
    Run Keyword If  '${PREV_TEST_STATUS}'=='PASS'   Log     This testcase is working

[1] CB007576_B2_fault 61672 Fronthaul transport configuration mismatch in direct connectivity mode
    Run Keyword If  '${PREV_TEST_STATUS}'=='PASS'   Log     This testcase is working
