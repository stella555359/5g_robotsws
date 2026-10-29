*** Settings ***
Documentation	[Maintenance]   "TRS I & V Tools Bangalore Team"
...     	[Procedure] "The test case is planned to check Multiple RUs Mplane FH Configuration discovery in Direct connectivity mode"
...     	[Date]      "20-02-24"
...    		[Author]        "Indraja "
...     	[QC_Path]   "Root\Test_Sets\Trunk\New_Features\BB_TRS_VRF_ET"
...     	[QC_ID]     "341852"
...     	[Funtion_Hash_Tags] "SWN CLOUD"
...     	[Feature_ID]            "CB007576"
...     	[Validated_TestLine]    "trs-cran8"
...     	[Requirements]  "TT_GEN_COMMON_USCR_141;OAM_REQ_TRSSEC_879;OAM_REQ_TRSSEC_882;OAM_REQ_TRSSEC_1045"

Resource        ${CURDIR}/resources/CB007576_commonkeywords.robot
Resource	${CURDIR}/../resources/common_keywords.robot

Suite Teardown  Run Keywords    Setup Oamops    dut=vdu_7576      alias=default   AND     Collect Snapshot
...     dut=vdu_7576  operation_timeout=300   alias=default   AND     Run Keyword And Ignore Error    Teardown Oamops
...      dut=vdu_7576     alias=default

*** Test Cases ***
[1][1.0] Copy_of_CB007576_B1_Multiple_RUs_Mplane_FH_Configuration_discovery_in_direct_connectivity_mode
    Load SCF    ${base_scf}
    Enabling Rannic ssh
    Reboot Airphone
    Sleep    60
    Capture DHCP packets in case of direct connection
    Verify DHCP packets
    Comment	Delta commissioning to change pcp and dscp value
    Check pcp   ${rfoe4}
    Copy pcap to VM
    Verify DHCP packets with pcp rfoe4
    Delta commissioning to check for 61672 fronthaul mismatch alarm
