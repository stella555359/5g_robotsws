*** Settings ***

Documentation
...     [Author]                "Madhumitha R"
...     [Maintenance]           "TRS I & V Tools Bangalore Team"
...     [Date]                  "21:02:2023"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"
...     [Feature_ID]            "CA_IPv6_SR002750"
...     [Funtion_Hash_Tags]     "6 operators with dedicated SeGW for different Operators with dedicated PKI and Cross-Signed CA_IPv6_SR002750"
...     [Procedure]             "6 operators with dedicated SeGW for different Operators with dedicated PKI and Cross-Signed CA_IPv6_SR002750"

*** keywords ***

Verification_Of_cmpInitializeCertificate
        Certificate Configure     operation=install_cmp_certificate       timeout=120

Verify Addition Of Rule(1500) in BOARD

    Setup Remote Access      remote_device=bts
    ${output}=      Remote Command Execute      command= ip rule show
    ${output1}=      Remote Command Execute      command= ip rule show grep | 0: from all lookup local
    Should Contain     '${output}'     1500:    from all lookup local
    Should Not Contain         '${output1}'      0: from all lookup local
    [Teardown]      Teardown Remote Access

Verify Deletion Of Rule(1500) in BOARD

    Setup Remote Access      remote_device=bts
    ${output2}=      Remote Command Execute      command= ip rule show
    Should Match Regexp     ${output2}      0:\\tfrom all lookup local
    Should Not Contain         '${output2}'         1500:    from all lookup local
    [Teardown]      Teardown Remote Access

Verify Captured File
    [Arguments]     ${pcap_filename}
    Read IP Parameters
     Analyse Pcap    pcap_filename=${pcap_filename}    analysis=Verify_SCTP_INIT
     Analyse Pcap    pcap_filename=${pcap_filename}    analysis=Verify_SCTP_INIT_ACK
     Analyse Pcap    pcap_filename=${pcap_filename}    analysis=Verify_SCTP_COOKIE_ECHO
     Analyse Pcap    pcap_filename=${pcap_filename}    analysis=Verify_SCTP_COOKIE_ACK
     Analyse Pcap    pcap_filename=${pcap_filename}    analysis=verify_S1AP_request
     Analyse Pcap    pcap_filename=${pcap_filename}    analysis=verify_SCTP_SACK_ACK_from_MME_TO_CPlane
     Analyse Pcap    pcap_filename=${pcap_filename}    analysis=verify_S1AP_response
     Analyse Pcap    pcap_filename=${pcap_filename}    analysis=verify_SCTP_SACK_ACK_from_CPlane_To_MME

Verify x2 link status
    [Arguments]     ${pcap_filename}
     Analyse Pcap    pcap_filename=${pcap_filename}    analysis=verify_ENDCX2SetupRequest
     Analyse Pcap    pcap_filename=${pcap_filename}    analysis=verify_ENDCX2SetupResponse

Read IP Parameters

    ${Primary_MME}=     Get Parameter      param_path=${Primary_MME_IP}
    Set Suite Variable       ${Primary_MME}      ${Primary_MME}
    ${Primary_Cplane}=     Get Parameter      param_path=${Primary_Cplane_IP}
    Set Suite Variable       ${Primary_Cplane}       ${Primary_Cplane}

Verify X2Link status is up

    ${LteEnb_moc}=   Query Admin Infomodel   query=get object ${LTEENB_moc_path}
    ${X2Link_status}=  Get From Dictionary     dictionary=${LteEnb_moc}     key=x2LinkStatus
    Should Be Equal     ${X2Link_status}       available

Verify S1Link status is up

    ${LNMME_moc}=   Query Admin Infomodel   query=get object ${LNMME_moc_path}
    ${s1Link_status}=  Get From Dictionary     dictionary=${LNMME_moc}     key=s1LinkStatus
    Should Be Equal     ${s1Link_status}       available

Verify S1Link status is Down

    ${LNMME_moc}=   Query Admin Infomodel   query=get object ${LNMME_moc_path}
    ${s1Link_status}=  Get From Dictionary     dictionary=${LNMME_moc}     key=s1LinkStatus
    Should Be Equal     ${s1Link_status}       unavailable

Manual_Installation_of_Cert
    Certificate Configure    operation=install_certificate    cert_file=${Ipsec_p12_cert}
    ...    cert_type=BtsTrustChain     cert_format=P12     password=${Pswd}

Restore Vendor Certificates
    Certificate Configure      operation=restore_vendor_certificate       alias=default

Verify PM counters
    PM Counters Start      analysis=verify_ipsec_counters      counter_analysis_file=${counter_analysis_file_name}
    PM Counters Start      analysis=verify_secpol_counters      counter_analysis_file=${counter_analysis_file_name}

Perform Ping Test
    Setup Remote Access         remote_device=bts       alias=conn2
    Remote Command Execute          command=ping ${AMF_IP} -I ${Cplane_Ip} -c ${count}      alias=conn2
    Sleep   20
    [Teardown]      Teardown Remote Access      alias=conn2

Enabling Ipsec
    [Arguments]     ${alias}=default
    Perform Recommissioning     type=param      param_path=MRBTS-2335/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1:ipSecEnabled
    ...      operation=update    value=true      timeout=300     alias=${alias}
    Sleep   120

Disabling Ipsec
    [Arguments]     ${alias}=default
    Perform Recommissioning     type=param      param_path=MRBTS-2335/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1:ipSecEnabled
    ...      operation=update    value=false     timeout=300     alias=${alias}
    Sleep   220
