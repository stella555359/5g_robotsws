*** Settings ***
Documentation
...     [Procedure]             "The testcase verify's installation of RSA and ECDSA installation"
...     [Date]                  "10-02-2023"
...     [Author]                "Abhishek"
...     [Maintenance]           "TRS"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"
...     [Funtion_Hash_Tags]     "CMP"
...     [Domain_Hash_Tags]      "certificate"
...     [Feature_ID]            "CB007351"
...     [Validation_status]     "Validated and Passed"
...     [Validated_TestLine]    "SBTS-7351"
...     [Config_Comments]       "NA"
...     [RunTime Parameters]    ""

Resource          ${CURDIR}/../resources/Common_IPSEC_Operations.robot
Resource          ${CURDIR}/../resources/common_keywords.robot
Resource          ${CURDIR}/resources/CB007351_Keywords.robot

Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops

Force Tags      CA_E2ET_BTSTRSPZ        SBTS00        SBTS25R2     SBTS25R3   SBTS22R2   4G_FDD       QCD_MN_RAN        QCP_RAN_VRF        CRT


*** Test Cases ***
[1][1.0] CB007351-C-2_Verify with Automatic configured valid ECDSA certificates are taken after SW roll-back-fallback
#Step 1: Load CB007351 Feature configured SCF
    	Preconditions
        Verify Ipsec Tunnels Status
        Verify actsync Flag is enbaled

#Step 5: Verify the Certificates via CLI present in Active and Passive Partition
           Verification of certificate details in BTS Active partition
    	    Verification of certificate details in BTS Passive partition

#Step 8: Compare the deatils of Active and Passive partition and verify if its matching
      	 Comparision of details between Active and passive partition
         Triger CMP IR to install certificates
         Verify cert details in BTS Active partition
         Verify cert details in BTS Passive partition

#Step 6: Rollback Software to previous Build
         Rollback BTS Software

#Step 7: Verify the Certificates via CLI present in Active and Passive Partition after Software Rollback
    Verification of certificate details in BTS Active partition1
	 Verification of certificate details in BTS Passive partition2

#Step 8: Compare the deatils of Active and Passive partition and verify if its matching
      	 Comparision of details between Active and passive partition
        Verify cert details in BTS Active partition-1
        Verify cert details in BTS Passive partition-1

   [Teardown]       Teardown Ems        config_device=netact2005      alias=lab2005