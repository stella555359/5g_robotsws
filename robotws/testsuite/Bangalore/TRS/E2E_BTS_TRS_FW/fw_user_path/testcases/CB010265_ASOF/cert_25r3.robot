*** Settings ***
Documentation
...     [Author]                "Madhumitha R"
...     [Maintenance]           "TRS I & V Tools Bangalore Team"
...     [Date]                  "21:06:2023"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"
...     [Feature_ID]            "CB010265"
...     [Funtion_Hash_Tags]     "manual installation of SHA1, SHA384 and keylength less than 2K certificates"
...     [Procedure]             "manual installation of SHA1, SHA384 and keylength less than 2K certificates"

Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/../resources/common_keywords.robot

Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops

*** Test cases ***

[1]CB010265_TRS_A_Verifictaion of manual installation of SHA1, SHA384 and keylength less than 2K certificates

   Restore Vendor Certificates
   Perform Commissioning    scf_file=${scf_25r3}    skip_parameter_relation_errors=${True}      verify_bts_status=${False}     timeout=800
   sleep      300
   Manual_Installation_of_SHA384_Cert
   Sleep    10
   Manual_Installation_of_1K_Cert
   Sleep    10
    Perform Recommissioning      type=param     rat=nr      param_path=${Block_lessthan1K_cert_flag_path}     operation=update        value=true
   Sleep    10
    Run Keyword and Expect Error        *Certificate validation - key length is not supported        Manual_Installation_of_1K_Cert
    Perform Recommissioning      type=param     rat=nr      param_path=${Block_lessthan1K_cert_flag_path}     operation=update        value=false
   Sleep    10
   Restore Vendor Certificates
   Manual_Installation_of_SHA1_Cert
   Sleep    10
	Perform Recommissioning		 type=param 	rat=nr  	param_path=${Block_Sha1_cert_flag_path} 	operation=update    	value=true
   Sleep    10
    Run Keyword and Expect Error        *Certificate validation - Unsupported/weak signature algorithm      Manual_Installation_of_SHA1_Cert
   Sleep    10
    Perform Recommissioning      type=param     rat=nr      param_path=${Block_Sha1_cert_flag_path}     operation=update        value=false
   Sleep    10
   Restore Vendor Certificates

*** keywords ***

Restore Vendor Certificates
    Certificate Configure      operation=restore_vendor_certificate       alias=default


Manual_Installation_of_SHA1_Cert
    Certificate Configure    operation=install_certificate    cert_file=${SHA1_Cert}
    ...     cert_type=BtsTrustChain     cert_format=P12     password=${Pswd}

Manual_Installation_of_SHA384_Cert
    Certificate Configure    operation=install_certificate    cert_file=${SHA384_Cert}
    ...     cert_type=BtsTrustChain     cert_format=P12     password=${Pswd}

Manual_Installation_of_1K_Cert
    Certificate Configure    operation=install_certificate    cert_file=${1K_Cert}
    ...     cert_type=BtsTrustChain     cert_format=P12     password=${Pswd}

