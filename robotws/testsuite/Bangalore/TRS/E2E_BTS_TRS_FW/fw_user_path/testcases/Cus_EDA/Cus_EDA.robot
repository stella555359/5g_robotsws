*** Settings ***
Documentation
...     [Author]                "Madhumitha R"
...     [Maintenance]           "TRS I & V Tools Bangalore Team"
...     [Date]                  "21:06:2023"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"
...     [Feature_ID]            "TMO_04486158"
...     [Funtion_Hash_Tags]     "Verify Ipsec Tunnel status after End Entity Certificate Renewal"
...     [Procedure]             "Verify Ipsec Tunnel status after End Entity Certificate Renewal"

Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/Common_IPSEC_Operations.robot

Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops

*** Test cases ***

[1]TMO_04486158_Verify Ipsec Tunnel status after End Entity Certificate Renewal

    Precondition
    Perform Commissioning    scf_file=${scf}    skip_parameter_relation_errors=${True}      verify_bts_status=${False}     timeout=8000
    Sleep      300
    Manual_Installation_of_Ipsec_certificate
    sleep   60
    Verify Ipsec Tunnels Status
    Sleep    30
    Install Additional CA Certificate
    Sleep    30
    Setup Remote Access      remote_device=bts      alias=bts
     ${Before_renewal} =     Remote Command Execute       command=ls /etc/swanctl/x509ca/    alias=bts
    Manual_Installation_of_Ipsec_certificate
     ${After_renewal} =     Remote Command Execute       command=ls /etc/swanctl/x509ca/    alias=bts
    Should Contain     '${Before_renewal}'     '${After_renewal}'       alias=bts
    [Teardown]      Teardown Remote Access      alias=bts

*** keywords ***

Restore Vendor Certificates
    Certificate Configure      operation=restore_vendor_certificate       alias=default

Manual_Installation_of_Ipsec_certificate
    Certificate Configure    operation=install_certificate    cert_file=${Ipsec_Cert}   cert_type=BtsTrustChain    cert_format=P12  password=${Pswd}

Install Additional CA Certificate
    FOR     ${index}    IN RANGE    1   5
        Certificate Configure     operation=install_certificate     cert_file=${CA_name}_${index}.pem    cert_type=AdditionalCa     cert_format=PEM
        Sleep   5
    END

Precondition
    Certificate Configure      operation=restore_vendor_certificate       alias=default
     Run Keyword And Ignore Error     certificate configure        operation=delete_cert       all_certs=${True}