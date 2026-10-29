***Settings ***

Documentation

...   [Procedure]          "IPSEC_REAUTH_KEYING"
...   [Date]               "Date of creation 25-9-2024"
...   [Author]             "Abhishek Baburaj"
...   [QC_Path]            "QC_Path in Test Plan"
...   [QC_ID]              "QC_ID in Test Lab for reporting"
...   [Feature_ID]         "RP000749"
...   [Funtion_Hash_Tags]  "IPSEC_REAUTH_ASIM"
...   [Validation_status]  "Passed"
...   [Testline Status]	   "BTS-2020"
...   [Validation Date]    "22-10-2024



Force Tags      CA_E2ET_BTSTRSPZ        SBTS00        SBTS25R3   4G_FDD       QCD_MN_RAN        QCP_RAN_VRF        CRT

variables       ta_e2e_bts_trs_fw
Resource       ${CURDIR}/../resources/common_keywords.robot
Resource       ${CURDIR}/../resources/Admin_Common_Library.robot
Library        ute_fsmaccess
Library 	   String
Resource       ${CURDIR}/../resources/common_keywords.robot
Library	       SSHLibrary
Library	    	ute_pdu
Library	     	Collections
Resource		${CURDIR}/../resources/Admin_Common_Library.robot
Resource		${CURDIR}/../resources/Common_IPSEC_Operations.robot
Resource		${CURDIR}/resources/RP00749_Common_Keywords.robot

Suite Setup             Run Keywords    Suite Setup Preconditions
...             AND             Setup Oamops

Suite Teardown     Run Keywords         Suite Teardown Postconditions
...             AND             Teardown Oamops

*** Test Cases ***
[1][1.0] RP000749_1_Automation_Verification of ipsec tunnels using reauthentication enabled.
    Preconditions
	Disable the reauth flag
	Configure ike rekey as 3600sec
    Verify rekeying
    Verify Ipsec Tunnels Status
    [Teardown]  Teardown Ems  config_device=netact2005  alias=lab2005
