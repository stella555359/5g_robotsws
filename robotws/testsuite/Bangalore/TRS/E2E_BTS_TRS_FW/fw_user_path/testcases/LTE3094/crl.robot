*** Settings ***
Documentation
...     [Author]                "Madhumitha R"
...     [Maintenance]           "TRS I & V Tools Bangalore Team"
...     [Date]                  "20-10-2024"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"
...     [Feature_ID]            "LTE3094"
...     [Funtion_Hash_Tags]     "CRL DownloadWithSha256 hash Algorithm"
...     [Procedure]             "CRL DownloadWithSha256 hash Algorithm"


Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/../resources/common_keywords.robot


Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops


*** Test Cases ***

[1][1.0] TRS_5GC001050_CRL DownloadWithSha256 hash Algorithm

    Restore Vendor Certificates
    Sleep    30
    Configure CrlDp Certificate and Install Certificate
    Sleep    90
    Update CRL List
    Sleep   30
    Get CRL List
    Sleep   60
    Verify hash Algorithm

*** keywords ***

Verify hash Algorithm
    Setup Remote Access      remote_device=bts
    Execute command on ENodeB      command= openssl crl -in /ffs/run/trs_data/active/keystorage/certs/crl_*.pem -text
    Should Match Regexp    ${stdout}    Signature Algorithm: sha256WithRSAEncryption
    [Teardown]      Teardown Remote Access

Restore Vendor Certificates
    Certificate Configure      operation=restore_vendor_certificate       alias=default

Configure CrlDp Certificate and Install Certificate
	Perform Commissioning    scf_file=${scf}    skip_parameter_relation_errors=${True}      verify_bts_status=${False}     timeout=800

Verification_Of_cmpInitializeCertificate
        Certificate Configure     operation=install_cmp_certificate       timeout=120

Update CRL List

    Certificate configure   operation=update_certificate_revocation_list    rat=5g    domain_type=3GPP   alias=default    timeout=1200

Get CRL List

    Certificate configure       operation=get_certificate_revocation_list   rat=5g   domain_type=3GPP    alias=default   timeout=1200
