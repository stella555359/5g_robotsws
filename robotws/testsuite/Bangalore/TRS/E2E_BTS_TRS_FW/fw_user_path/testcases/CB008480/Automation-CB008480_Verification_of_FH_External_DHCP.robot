*** Settings ***
Documentation
...     [Procedure]             "Simultaneous support of SOAP/RP1 and O-RAN RF module"
...     For simulatneous support of ORU and SOAP/RP1, as prerequisite for Oru bringup
...     1. Add Default Netconf Account in webem and make sure Interface must be up between BBMOD
...        and Airframe server(RM17 HW Centos installed with Docker Libraries)
...     2. Follow the instructions
...        https://confluence.ext.net.nokia.com/display/MNRANL2SW3BLR/ORU-Bringup?flashId=1683285316
...     [Author]                "Sahana TC"
...     [Maintenance]           "TRS I & V Tools Bangalore Team"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 ". . . ."
...     [Feature_ID]            "CB008480-G"
...     [Requirement ID]        "OM_GEN_SFS_RNWINT.6723,TT_TTSEC.2214,TT_TTSEC.2340,WBTS_SEC_59515,WBTS_SEC_59532,
...                              WBTS_SEC_59600,TT_TTSEC.2233,TT_TTSEC.2234,WBTS_SEC_59565,WBTS_SEC_59583"
...     [Funtion_Hash_Tags]     "Security"
...     [Domain_Hash_Tags]      "Fronthaul IPsec"
...     [Validated_TestLine]    "3783"
...     [Config]                ""
...     [Runtime param]         "bts_id is provided at run time."


Variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/common_CB008480_keywords.robot

Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops

*** Test Cases ***
[2]Automation-External DHCP Server assigning IP to RU

    Perform Commissioning       scf_file=${ext_dhcp_aweuc}   verify_bts_status=${False}     timeout=800     alias=default
    Log    Verify RF is up and IP is assigned to RF via ext dhcp server
    Setup Remote Access     remote_device=bts     alias=co
    BuiltIn.Sleep   10
    Rfmodule Setup      config_device=rf_module     rf_ip_distname=${dist}     fhnet_login_only=${True}      timeout=60      alias=conn2
    Get RF IPs
    Rfmodule Teardown       alias=conn2
    Teardown Remote Access     alias=conn2