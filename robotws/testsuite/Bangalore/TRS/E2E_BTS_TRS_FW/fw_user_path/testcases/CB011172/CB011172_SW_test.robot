*** Settings ***
Documentation
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Procedure] "The test case is planned to check RU Mplane FH Configuration discovery in switched connectivity mode"
...     [Date]      "12-03-25"
...     [Author]        "Shivani Patil"
...     [QC_Path]   "Root\Test_Sets\Trunk\New_Features\BB_TRS_VRF_ST"
...     [QC_ID]     "341852"
...     [Funtion_Hash_Tags] "SWN CLOUD"
...     [Feature_ID]            "CB011172_CB007576"
...     [Validated_TestLine]    "cran202"


Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/CB007576_commonkeywords.robot

Suite Teardown      Run Keywords    Setup Oamops    dut=vdu_7576      alias=default   AND     Collect Snapshot
...     dut=vdu_7576  operation_timeout=300   alias=default   AND     Run Keyword And Ignore Error    Teardown Oamops
...      dut=vdu_7576     alias=default

*** Test Cases ***
[1]CB011172_CB007576_PCP and DSCP for eCPRI Mplane traffic in switched connectivity mode
    Load Base SCF
    Sleep   300
    Delta Commissioning with 7576 changes
    Check actLbmOnFronthaul flag
    Reboot RF
    Sleep   120
    Capture DHCP packets
    Verify DHCP packets in swn
    Delta commissioning to change pcp and dscp value
    Reboot RF
    Sleep   120
    Capture DHCP packets
    Verify DHCP packets with pcp in swn
    Delta commissioning to check 61672 fronthaul mismatch alarm
    Delta commissioning to clear 61672 fronthaul mismatch alarm
