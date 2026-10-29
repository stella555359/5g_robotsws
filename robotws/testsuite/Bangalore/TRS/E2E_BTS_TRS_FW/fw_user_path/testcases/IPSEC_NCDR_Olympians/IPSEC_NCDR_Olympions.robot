*** Settings ***
Documentation
...     [Procedure]     "Verify IPSEC NCDR"
...     [Author]        "Shankar Manurwar"
...     [Maintenance]   "TRS_VRF"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"
...     [Function_Hash_Tags]    "IPSEC"
...     [Validation_status]     "Validated"
...     [Validated_TestLine]    "ASIM HR"

#Resource    taf/rfrl/trs_e2e_fw/setup/framework.robot
#variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/IPSEC_NCDR_common_keywords.robot

Suite Setup       Setup Oamops
Suite Teardown    Teardown Oamops
#Suite Setup        Run Keywords          Pre-conditions for testsuite
#Suite Teardown     Run Keywords          Post-conditions for testteardown

***Test Cases***
[1]Verification_of_IKE_Re_Keying_and_IPSEC_SA_rekeying_and_Pre_fragmentation_in_UL_and_DL_ASIM

    Preconditions
    Perform Software Download And Update               package=${sw_build_path}        timeout=2600
    Sleep   300
    IPSEC and Strongswan Configuration
    Verify Ipsec Tunnels Status
    Bring up OnAir and verify AMF and BTS status
    Send Pre fragmented traffic and Verify traffic
#    Loop for Ipsec Enable Disable
    Verify Post fragmentation alarm
    Loop for delta and snapshot collection
    M Plane test
    Modify ARW and Re keying and check Tunnel status
    PM Counter Verification
    Jumbo frame verification
    SECPOL Modification scenarios
    [Teardown]     Run Keyword And Ignore Error     Certificate Configure     operation=restore_vendor_certificate
