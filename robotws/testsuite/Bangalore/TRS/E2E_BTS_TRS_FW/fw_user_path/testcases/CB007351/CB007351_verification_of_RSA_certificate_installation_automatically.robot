*** Settings ***
Documentation
...     [Procedure]             "The testcase verify's installation of RSA certificates and that should be mirror to passive partition"
...     [Date]                  "15-06-2022"
...     [Author]                "Bibhukinkar Behera"
...     [Maintenance]           "TRS ET Bangalore Team"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"
...     [Funtion_Hash_Tags]     "CMP"
...     [Domain_Hash_Tags]      "certificate"
...     [Feature_ID]            "CB007351"
...     [Validation_status]     "Validated and Passed"
...     [Validated_TestLine]    "SBTS-7351"
...     [Config_Comments]       "This script requires basic SCF loading with CMP and CRL server configuration"
...     [RunTime Parameters]    "bts_id used is 7351"

variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/resources/CB007351_common_keywords.robot

#Suite Setup     Run Keywords        Suite Setup Preconditions
#...     AND     Setup Oamops
#Suite Teardown     Run Keywords     Suite Teardown Postconditions
#...     AND     Teardown Oamops

Suite Setup             Run Keywords    Pre-conditions for testsuite
Suite Teardown     Run Keywords         Post-conditions for testteardown

*** Test Cases ***
[1][2.0] CB007351-A-2_Verify Automatically configured valid RSA Certificates to be Mirrored and invalid RSA Certificates not to be Mirrrored
#	Perform Commissioning       scf_file=${config_file}   verify_bts_status=False     timeout=400     alias=default
#    Sleep    300
    Flag verification after enabling the feature
    Read RSA IP Parameters
	Remove if any existing certificate
    Verification certificates both in Active and Passive after vendorcert
    Triger CMP RSA IR to install certificates
    Verify Alarm   faultid=61510   should_exist=${False}
    Sleep   60
#    Enable CRL and verify the LDAP packetes
#	Verify Alarm        faultid=61074     should_exist=${False}
    Verification of RSA certificate details in BTS Active partition
	Verification of RSA certificate details in BTS Passive partition
    Adding the additional RSA TA certificate and verify the certs count in Active and Passive partition
    Comparision of details between Active and passive partition
    RSA CMP Key update and details verification
    Disable the flag and delete the RSA TA certificate
    Enable the flag and verify certificate count in partitions
    [Teardown]     Run Keyword And Ignore Error        Certificate Configure    operation=delete_cert   type=${ta_cert}
    ...		subject=${ta_sub}   source=${source}

#[1]CB007351-C-1_Verify with Automatic configured valid RSA certificates are taken after SW roll-back-fallback so that BTS
#can reconnect to via IPSec or TLS

##    Perform Commissioning       scf_file=${config_file_RSA_roolback}   verify_bts_status=False     timeout=400     alias=default
##    Sleep    300
##    Flag verification after enabling the feature
#    Read RSA IP Parameters
#    Remove if any existing certificate
#    Verification certificates both in Active and Passive after vendorcert
#    Triger CMP RSA IR to install certificates
#    Verify Alarm   faultid=61510   should_exist=${False}
#    Enable CRL and verify the LDAP packetes
#    Verify Alarm        faultid=61074     should_exist=${False}
#    Enable Ipsec on Admin
#    Get Ipsec Tunnels Status
#    Verification of RSA certificate details in BTS Active partition
#    Verification of RSA certificate details in BTS Passive partition
#    Adding the additional RSA TA certificate and verify the certs count in Active and Passive partition
#    Comparision of details between Active and passive partition
#    RSA CMP Key update and details verification
#    Disable the flag and delete the RSA TA certificate
#    Enable the flag and verify certificate count in partitions
#    Verification of RSA certificate details in BTS Active partition Before Roll-Back
#    Rollback Software     verify_bts_status=false   timeout=900      alias=default
#    Sleep    300
#    Comparision of RSA certificates details after Roll-Back
#    [Teardown]     Run Keyword And Ignore Error        Certificate Configure    operation=delete_cert   type=${ta_cert}
#     ...	subject=${ta_sub}   source=${source}
