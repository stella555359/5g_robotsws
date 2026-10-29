*** Settings ***
Documentation
...     [Author]                "Madhumitha R"
...     [Maintenance]           "TRS I & V Tools Bangalore Team"
...     [Date]                  "21:02:2023"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"
...     [Feature_ID]            "CNI_118677"
...     [Funtion_Hash_Tags]     "Verification_of_Overlapping_of_Ipv6_address_with_other_operator_application address"
...     [Procedure]             "Verification_of_Overlapping_of_Ipv6_address_with_other_operator_application address"

*** keywords ***

Verification_Of_cmpInitializeCertificate
        Certificate Configure     operation=install_cmp_certificate       timeout=120

Verify Addition Of Rule(1500) in BOARD

    Setup Remote Access      remote_device=bts
    ${output}=      Remote Command Execute      command= ip rule show
    ${output1}=      Remote Command Execute      command= ip rule show grep | 0: from all lookup local
    Should Contain     '${output}'     1520:    from all lookup local
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

Verify Captured File_IPv6
    [Arguments]     ${pcap_filename}
    Read IPv6 Parameters
     Analyse Pcap    pcap_filename=${pcap_filename}    analysis=Verify_SCTP_INIT_v6
     Analyse Pcap    pcap_filename=${pcap_filename}    analysis=Verify_SCTP_INIT_ACK_v6
     Analyse Pcap    pcap_filename=${pcap_filename}    analysis=Verify_SCTP_COOKIE_ECHO_v6
     Analyse Pcap    pcap_filename=${pcap_filename}    analysis=Verify_SCTP_COOKIE_ACK_v6
     Analyse Pcap    pcap_filename=${pcap_filename}    analysis=verify_S1AP_request_v6
     Analyse Pcap    pcap_filename=${pcap_filename}    analysis=verify_SCTP_SACK_ACK_from_MME_TO_CPlane_v6
     Analyse Pcap    pcap_filename=${pcap_filename}    analysis=verify_S1AP_response_v6
     Analyse Pcap    pcap_filename=${pcap_filename}    analysis=verify_SCTP_SACK_ACK_from_CPlane_To_MME_v6

Read IP Parameters

    ${Primary_MME}=     Get Parameter      param_path=${Primary_MME_IP}
    Set Suite Variable       ${Primary_MME}      ${Primary_MME}
    ${Primary_Cplane}=     Get Parameter      param_path=${Primary_Cplane_IP}
    Set Suite Variable       ${Primary_Cplane}       ${Primary_Cplane}

Read IPv6 Parameters

    ${Primary_MME_v6}=     Get Parameter      param_path=${Primary_MME_IP_v6}
    Set Suite Variable       ${Primary_MME_v6}      ${Primary_MME_v6}
    ${Primary_Cplane_v6}=     Get Parameter      param_path=${Primary_Cplane_IP_v6}
    Set Suite Variable       ${Primary_Cplane_v6}       ${Primary_Cplane_v6}


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
    ...   cert_type=BtsTrustChain     cert_format=P12     password=${Pswd}


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