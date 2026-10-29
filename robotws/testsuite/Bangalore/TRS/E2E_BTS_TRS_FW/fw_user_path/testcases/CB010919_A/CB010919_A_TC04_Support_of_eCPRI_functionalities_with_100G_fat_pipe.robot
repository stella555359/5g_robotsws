*** Settings ***
Documentation
...     [Documentation]
...     [Author]        "Aditya M"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Procedure] "Support of eCPRI functionalities with 100G fat pipe"
...     [Date]      "08-03-2024"
...     [QC_Path]   "Root\Test_Sets\Trunk\BB_TRS_VRF_ET\CRT\NF_Automated_Regression"
...     [QC_ID]     "353204"
...     [Funtion_Hash_Tags] "100G fat pipe"
...     [Feature_ID]            "CB010919-A"
...     [Requirement ID]    "TT_GEN_COMMON_USCR_744"
...     [Validation_Status]    "Validated"
...     [Validated_TestLine]    "trs-cran6_vDU"
...     [Config]    "This testcase requires basic configuration with RANNIC TNL"
...     [scf_file]  "CB010919_basic_scf.xml"


Library         OperatingSystem
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/common_keywords_CB010919.robot

Suite Setup     Setup Oamops    dut=vdu_10919      alias=default
Suite Teardown  Run Keywords    Setup Oamops    dut=vdu_10919      alias=default   AND     Collect Snapshot
...     dut=vdu_10919  operation_timeout=300   alias=default   AND     Run Keyword And Ignore Error    Teardown Oamops
...      dut=vdu_10919     alias=default



*** Test Cases ***

[1]CB010919-A-TC04 Support of eCPRI functionalities with 100G fat pipe

    Verify 100G fat pipe is Enabled

#    Verify RANNIC sync status is Locked

    Verify F1c link is UP

    comment    Verifying RUs and vDU DHCP communication with 100G fat pipe enabled

    Reset Airphone

    Reset vDU in WebEM and Capture DHCP packets in OAMFH pod

    Verify DHCP packets between RU and OAMFH

    comment    Verifying LBM traffic in RANNIC interface with 100G fat pipe enableid

    Change the service account password

    Enable ssh access from rannic

#    Configure OAMMA OAMMD mocs and enable LBM flag

    Login to RANNIC and capture the LBM traffic at rfoe4 interface

    Verify LBM traffic in the pcap file
