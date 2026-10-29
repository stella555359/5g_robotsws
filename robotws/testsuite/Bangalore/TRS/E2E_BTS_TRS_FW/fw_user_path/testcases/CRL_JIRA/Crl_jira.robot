*** Settings ***
Documentation
...     [Author]                " Madhumitha "
...     [Maintenance]           "TRS I & V Tools Bangalore Team"
...     [Date]                  "21:06:2023"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"
...     [Feature_ID]            "CB007967"
...     [Funtion_Hash_Tags]     "verify TLS connection after CRL expiry"
...     [Procedure]             "verify TLS connection after CRL expiry"

Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/../resources/common_keywords.robot

Suite Setup     Run Keywords    Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown  Run Keywords    Suite Teardown Postconditions
...     AND     Teardown Oamops

*** Test cases ***

[1][1.0]SMTRS_3450260 Enhance regression suite to verify TLS connection after CRL expiry

    PreCondition
   Perform Commissioning    scf_file=${scf}    skip_parameter_relation_errors=${True}      verify_bts_status=${False}     timeout=800
   sleep      200
    Install Additional CA Certificate
    Traffic Capture Start     capture_device=oam_device      mode=file       uplane_capturing=True
    ...     measurement_point=NE_Terminated      timeout=300    alias=TLS_Packets
	 Sleep 		30
    Update CRL List
    ${filemode_capture}=    Traffic Capture Stop      mode=file     timeout=120      alias=TLS_Packets
	Verify Captured File   ${filemode_capture}

*** keywords ***


PreCondition
    Log    Certificate Deleted Successfully
      Run Keyword And Ignore Error     certificate configure        operation=delete_cert       all_certs=${True}
    Sleep   30
    Certificate Configure      operation=restore_vendor_certificate       alias=default

Verify Captured File
	[Arguments]     ${pcap_filename}
     Analyse Pcap    pcap_filename=${pcap_filename}    analysis=Verify_client_hello_Request_from_BTS
     Analyse Pcap    pcap_filename=${pcap_filename}    analysis=Verify_server_hello_Response_from_NMS
#     Analyse Pcap    pcap_filename=${pcap_filename}    analysis=Verify_CRL_Cert_expired_Alert_Message
    Analyse Pcap    analysis=Verify_Ldap_Messages_Exchange_after_CRL_Expiry     pcap_filename=${pcap_filename}
    ${rc}   ${stdout}   Run And Return Rc And Output
    ...     tshark -r ${pcap_filename} -Y "((ip.addr == 10.71.249.161) && (ip.addr == 10.43.73.155)) && (ldap)" -T pdml 2>/tmp/stderr.txt
    Should Contain    '${stdout}'
    ...   LDAPMessage searchRequest(3) &quot;CN=NMS_CRL_CERT,OU=CertificateAuthorityRoot,DC=LtmSysVerDnsCrlDpcmp975cert31&quot;
    Should Contain   '${stdout}'
    ...     LDAPMessage searchResEntry(3) &quot;cn=NMS_CRL_CERT,ou=CertificateAuthorityRoot,dc=LtmSysVerDnsCrlDpcmp975cert31&quot;
    Should Contain    '${stdout}'   LDAPMessage searchResDone(3) success

Install Additional CA Certificate
        Certificate Configure     operation=install_certificate     cert_file=${additional_cert_path}    cert_type=AdditionalCa    cert_format=PEM
        Sleep   60

Verification_Of_cmpInitializeCertificate
        Certificate Configure     operation=install_cmp_certificate       timeout=120

Update CRL List

        Run Keyword And Ignore Error      Certificate configure   operation=update_certificate_revocation_list
        ...     rat=nr    domain_type=3GPP   alias=default    timeout=1200
