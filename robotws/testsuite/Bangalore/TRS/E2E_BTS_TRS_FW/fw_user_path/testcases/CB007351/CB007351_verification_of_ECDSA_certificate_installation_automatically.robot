*** Settings ***
Documentation
...     [Procedure]             "The testcase verify's installation of ECDSA  certificate and that should be mirrior to passive partition"
...     [Date]                  "15-06-2022"
...     [Author]                "Chiranjeevi Vempalle"
...     [Maintenance]           "TRS ET Bangalore Team"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"
...     [Funtion_Hash_Tags]     "CMP"
...     [Domain_Hash_Tags]      "certificate"
...     [Feature_ID]            "CB007351"
...     [Validation_status]     "Validated and Passed"
...     [Validated_TestLine]    "SBTS-7351"
...     [Config_Comments]       "This script requires basic SCF loading with ECDSA CMP and CRL server configuration"
...     [RunTime Parameters]    "bts_id used is 7351"

variables       ta_e2e_bts_trs_fw
#Resource        /home/ute/fw_user_path/testcases/resources/common_keywords.robot
Resource        ${CURDIR}/resources/CB007351_common_keywords.robot

#Suite Setup     Run Keywords        Suite Setup Preconditions
#...     AND     Setup Oamops
#Suite Teardown     Run Keywords     Suite Teardown Postconditions
#...     AND     Teardown Oamops

Suite Setup             Run Keywords    Pre-conditions for testsuite
Suite Teardown     Run Keywords         Post-conditions for testteardown

*** Test Cases ***
[1][1.0] CB007351-B-2_Verify Automatically configured valid ECDSA certificate be mirrored and invalid ECDSA certificates not to be Mirrored
##	Perform Commissioning       scf_file=${ECDSA_config_file}   verify_bts_status=False     timeout=400     alias=default
##	Sleep    300
    Flag verification after enabling the feature
    Read IP Parameters
	Remove if any existing certificate
    Verification certificates both in Active and Passive after vendorcert
    Triger CMP RSA IR to install certificates
    Triger CMP IR to install certificates
    Verify Alarm   faultid=61510   should_exist=${False}
	Enable CRL and verify the LDAP packetes
	Verify Alarm        faultid=61074     should_exist=${False}
    Verification of certificate details in BTS Active partition
	Verification of certificate details in BTS Passive partition
    Adding the additional TA certificate and verify the certs count in Active and Passive partition
    Comparision of details between Active and passive partition
    CMP Key update and details verification
    Disable the flag and delete the TA certificate
    Enable the flag and verify certificate count in partitions
    [Teardown]     Run Keyword And Ignore Error        Certificate Configure    operation=delete_cert   type=${ta_cert}
    ...		subject=${EC_ta_sub}   source=${source}


#[1][1.0] CB007351-C-2_Verify with Automatic configured valid ECDSA certificates are taken after SW roll-back-fallback so that
#BTS can reconnect to via IPSec or TLS
##    Perform Commissioning       scf_file=${ECDSA_config_file}   verify_bts_status=False     timeout=400     alias=default
##    Sleep    200
#    Flag verification after enabling the feature
#    Read IP Parameters
#    Remove if any existing certificate
#    Verification certificates both in Active and Passive after vendorcert
#    Triger CMP RSA IR to install certificates
#    Triger CMP IR to install certificates
#    Verify Alarm   faultid=61510   should_exist=${False}
#    Enable CRL and verify the LDAP packetes
#    Verify Alarm        faultid=61074     should_exist=${False}
#    Verification of certificate details in BTS Active partition
#    Verification of certificate details in BTS Passive partition
#    Adding the additional TA certificate and verify the certs count in Active and Passive partition
#    Comparision of details between Active and passive partition
#    CMP Key update and details verification
#    Disable the flag and delete the TA certificate
#    Enable the flag and verify certificate count in partitions
#    Verification of certificate details in BTS Active partition Before Roll-Back
#    Rollback Software     verify_bts_status=false   timeout=900      alias=default
#    Sleep    300
#    Comparision of certificates details after Roll-Back
#    Rollback Software     verify_bts_status=false   timeout=900      alias=default
#    Sleep    900

#   [Teardown]     Run Keyword And Ignore Error        Certificate Configure    operation=delete_cert   type=${ta_cert}
#    ...    subject=${EC_ta_sub}   source=${source}
