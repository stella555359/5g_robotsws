*** Settings ***
Documentation
...     [Author]                "Madhumitha R"
...     [Maintenance]           "TRS I & V Tools Bangalore Team"
...     [Date]                  "21:02:2023"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"
...     [Feature_ID]            "CB010762"
...     [Funtion_Hash_Tags]     "IPv4 SCTP Multihoming"
...     [Procedure]             "Testcase check LTE - SCTP Multihoming and both primary and secondary MME IPs with proper routes"

*** keywords ***

Install Maximum Additional CA Certificates for CRL
	FOR		${index}	IN RANGE	1	70
		Certificate Configure     operation=install_certificate     cert_file=${CA_name}_${index}.pem    cert_type=AdditionalCa     cert_format=PEM
		Sleep	5
	END

Install Maximum Additional TA Certificates for CRL
    FOR     ${index}    IN RANGE    1   11
        Certificate Configure     operation=install_certificate     cert_file=${TA_name}_${index}.pem    cert_type=AdditionalCa     cert_format=PEM
        Sleep   5
    END

Install Maximum Additional CA Certificates
    FOR     ${index}    IN RANGE    1   85
        Certificate Configure     operation=install_certificate     cert_file=${CA_name}_${index}.pem    cert_type=AdditionalCa     cert_format=PEM
        Sleep   5
    END

Install Maximum Additional TA Certificates
    FOR     ${index}    IN RANGE    1   21
        Certificate Configure     operation=install_certificate     cert_file=${TA_name}_${index}.pem    cert_type=AdditionalCa     cert_format=PEM
        Sleep   5
    END

Verify S1Link status is up for all IPV6 10 operators

    ${LNMME_moc}=   Query Admin Infomodel   query=get object ${LNMME_moc_path_v6_op1}
    ${s1Link_status}=  Get From Dictionary     dictionary=${LNMME_moc}     key=s1LinkStatus
    Should Be Equal     ${s1Link_status}       available

    ${LNMME_moc}=   Query Admin Infomodel   query=get object ${LNMME_moc_path_v6_op2}
    ${s1Link_status}=  Get From Dictionary     dictionary=${LNMME_moc}     key=s1LinkStatus
    Should Be Equal     ${s1Link_status}       available

    ${LNMME_moc}=   Query Admin Infomodel   query=get object ${LNMME_moc_path_v6_op3}
    ${s1Link_status}=  Get From Dictionary     dictionary=${LNMME_moc}     key=s1LinkStatus
    Should Be Equal     ${s1Link_status}       available

    ${LNMME_moc}=   Query Admin Infomodel   query=get object ${LNMME_moc_path_v6_op4}
    ${s1Link_status}=  Get From Dictionary     dictionary=${LNMME_moc}     key=s1LinkStatus
    Should Be Equal     ${s1Link_status}       available

    ${LNMME_moc}=   Query Admin Infomodel   query=get object ${LNMME_moc_path_v6_op5}
    ${s1Link_status}=  Get From Dictionary     dictionary=${LNMME_moc}     key=s1LinkStatus
    Should Be Equal     ${s1Link_status}       available

    ${LNMME_moc}=   Query Admin Infomodel   query=get object ${LNMME_moc_path_v6_op6}
    ${s1Link_status}=  Get From Dictionary     dictionary=${LNMME_moc}     key=s1LinkStatus
    Should Be Equal     ${s1Link_status}       available

    ${LNMME_moc}=   Query Admin Infomodel   query=get object ${LNMME_moc_path_v6_op7}
    ${s1Link_status}=  Get From Dictionary     dictionary=${LNMME_moc}     key=s1LinkStatus
    Should Be Equal     ${s1Link_status}       available

    ${LNMME_moc}=   Query Admin Infomodel   query=get object ${LNMME_moc_path_v6_op8}
    ${s1Link_status}=  Get From Dictionary     dictionary=${LNMME_moc}     key=s1LinkStatus
    Should Be Equal     ${s1Link_status}       available

    ${LNMME_moc}=   Query Admin Infomodel   query=get object ${LNMME_moc_path_v6_op9}
    ${s1Link_status}=  Get From Dictionary     dictionary=${LNMME_moc}     key=s1LinkStatus
    Should Be Equal     ${s1Link_status}       available

    ${LNMME_moc}=   Query Admin Infomodel   query=get object ${LNMME_moc_path_v6_op10}
    ${s1Link_status}=  Get From Dictionary     dictionary=${LNMME_moc}     key=s1LinkStatus
    Should Be Equal     ${s1Link_status}       available

Verify S1Link status is up for all 10 operators

    ${LNMME_moc}=   Query Admin Infomodel   query=get object ${LNMME_moc_path_op1}
    ${s1Link_status}=  Get From Dictionary     dictionary=${LNMME_moc}     key=s1LinkStatus
    Should Be Equal     ${s1Link_status}       available

    ${LNMME_moc}=   Query Admin Infomodel   query=get object ${LNMME_moc_path_op2}
    ${s1Link_status}=  Get From Dictionary     dictionary=${LNMME_moc}     key=s1LinkStatus
    Should Be Equal     ${s1Link_status}       available

    ${LNMME_moc}=   Query Admin Infomodel   query=get object ${LNMME_moc_path_op3}
    ${s1Link_status}=  Get From Dictionary     dictionary=${LNMME_moc}     key=s1LinkStatus
    Should Be Equal     ${s1Link_status}       available

    ${LNMME_moc}=   Query Admin Infomodel   query=get object ${LNMME_moc_path_op4}
    ${s1Link_status}=  Get From Dictionary     dictionary=${LNMME_moc}     key=s1LinkStatus
    Should Be Equal     ${s1Link_status}       available

    ${LNMME_moc}=   Query Admin Infomodel   query=get object ${LNMME_moc_path_op5}
    ${s1Link_status}=  Get From Dictionary     dictionary=${LNMME_moc}     key=s1LinkStatus
    Should Be Equal     ${s1Link_status}       available

    ${LNMME_moc}=   Query Admin Infomodel   query=get object ${LNMME_moc_path_op6}
    ${s1Link_status}=  Get From Dictionary     dictionary=${LNMME_moc}     key=s1LinkStatus
    Should Be Equal     ${s1Link_status}       available

    ${LNMME_moc}=   Query Admin Infomodel   query=get object ${LNMME_moc_path_op7}
    ${s1Link_status}=  Get From Dictionary     dictionary=${LNMME_moc}     key=s1LinkStatus
    Should Be Equal     ${s1Link_status}       available

    ${LNMME_moc}=   Query Admin Infomodel   query=get object ${LNMME_moc_path_op8}
    ${s1Link_status}=  Get From Dictionary     dictionary=${LNMME_moc}     key=s1LinkStatus
    Should Be Equal     ${s1Link_status}       available

    ${LNMME_moc}=   Query Admin Infomodel   query=get object ${LNMME_moc_path_op9}
    ${s1Link_status}=  Get From Dictionary     dictionary=${LNMME_moc}     key=s1LinkStatus
    Should Be Equal     ${s1Link_status}       available

    ${LNMME_moc}=   Query Admin Infomodel   query=get object ${LNMME_moc_path_op10}
    ${s1Link_status}=  Get From Dictionary     dictionary=${LNMME_moc}     key=s1LinkStatus
    Should Be Equal     ${s1Link_status}       available


Verify Captured File for Singlehoming_V6
	[Arguments]     ${pcap_filename}
   Read IPV6 Parameters
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_INIT_from_op1
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_INIT_from_op2
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_INIT_from_op3
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_INIT_from_op4
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_INIT_from_op5
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_INIT_from_op6
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_INIT_from_op7
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_INIT_from_op8
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_INIT_from_op9
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_INIT_from_op10

     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_INIT_ACK_from_op1
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_INIT_ACK_from_op2
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_INIT_ACK_from_op3
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_INIT_ACK_from_op4
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_INIT_ACK_from_op5
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_INIT_ACK_from_op6
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_INIT_ACK_from_op7
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_INIT_ACK_from_op8
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_INIT_ACK_from_op9
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_INIT_ACK_from_op10

     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=verify_S1AP_response_from_op1
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=verify_S1AP_response_from_op2
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=verify_S1AP_response_from_op3
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=verify_S1AP_response_from_op4
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=verify_S1AP_response_from_op5
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=verify_S1AP_response_from_op6
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=verify_S1AP_response_from_op7
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=verify_S1AP_response_from_op8
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=verify_S1AP_response_from_op9
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=verify_S1AP_response_from_op10

     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_S1AP_request_from_op1
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_S1AP_request_from_op2
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_S1AP_request_from_op3
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_S1AP_request_from_op4
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_S1AP_request_from_op5
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_S1AP_request_from_op6
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_S1AP_request_from_op7
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_S1AP_request_from_op8
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_S1AP_request_from_op9
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_S1AP_request_from_op10

     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_prim_MME_to_prim_Cplane_for_op1
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_prim_MME_to_prim_Cplane_for_op2
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_prim_MME_to_prim_Cplane_for_op3
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_prim_MME_to_prim_Cplane_for_op4
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_prim_MME_to_prim_Cplane_for_op5
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_prim_MME_to_prim_Cplane_for_op6
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_prim_MME_to_prim_Cplane_for_op7
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_prim_MME_to_prim_Cplane_for_op8
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_prim_MME_to_prim_Cplane_for_op9
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_prim_MME_to_prim_Cplane_for_op10

     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_prim_MME_to_prim_Cplane_for_op1
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_prim_MME_to_prim_Cplane_for_op2
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_prim_MME_to_prim_Cplane_for_op3
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_prim_MME_to_prim_Cplane_for_op4
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_prim_MME_to_prim_Cplane_for_op5
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_prim_MME_to_prim_Cplane_for_op6
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_prim_MME_to_prim_Cplane_for_op7
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_prim_MME_to_prim_Cplane_for_op8
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_prim_MME_to_prim_Cplane_for_op9
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_prim_MME_to_prim_Cplane_for_op10

     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_prim_Cplane_to_Primary_MME_for_op1
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_prim_Cplane_to_Primary_MME_for_op2
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_prim_Cplane_to_Primary_MME_for_op3
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_prim_Cplane_to_Primary_MME_for_op4
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_prim_Cplane_to_Primary_MME_for_op5
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_prim_Cplane_to_Primary_MME_for_op6
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_prim_Cplane_to_Primary_MME_for_op7
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_prim_Cplane_to_Primary_MME_for_op8
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_prim_Cplane_to_Primary_MME_for_op9
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_prim_Cplane_to_Primary_MME_for_op10

     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_prim_Cplane_to_Primary_MME_for_op1
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_prim_Cplane_to_Primary_MME_for_op2
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_prim_Cplane_to_Primary_MME_for_op3
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_prim_Cplane_to_Primary_MME_for_op4
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_prim_Cplane_to_Primary_MME_for_op5
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_prim_Cplane_to_Primary_MME_for_op6
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_prim_Cplane_to_Primary_MME_for_op7
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_prim_Cplane_to_Primary_MME_for_op8
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_prim_Cplane_to_Primary_MME_for_op9
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_prim_Cplane_to_Primary_MME_for_op10

Verify Captured File for Singlehoming_V4
    [Arguments]     ${pcap_filename}
   Read IPV4 Parameters
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_INIT_from_op1
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_INIT_from_op2
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_INIT_from_op3
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_INIT_from_op4
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_INIT_from_op5
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_INIT_from_op6
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_INIT_from_op7
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_INIT_from_op8
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_INIT_from_op9
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_INIT_from_op10

     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_INIT_ACK_from_op1
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_INIT_ACK_from_op2
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_INIT_ACK_from_op3
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_INIT_ACK_from_op4
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_INIT_ACK_from_op5
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_INIT_ACK_from_op6
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_INIT_ACK_from_op7
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_INIT_ACK_from_op8
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_INIT_ACK_from_op9
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_INIT_ACK_from_op10

     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=verify_S1AP_response_from_op1
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=verify_S1AP_response_from_op2
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=verify_S1AP_response_from_op3
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=verify_S1AP_response_from_op4
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=verify_S1AP_response_from_op5
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=verify_S1AP_response_from_op6
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=verify_S1AP_response_from_op7
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=verify_S1AP_response_from_op8
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=verify_S1AP_response_from_op9
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=verify_S1AP_response_from_op10

     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_S1AP_request_from_op1
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_S1AP_request_from_op2
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_S1AP_request_from_op3
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_S1AP_request_from_op4
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_S1AP_request_from_op5
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_S1AP_request_from_op6
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_S1AP_request_from_op7
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_S1AP_request_from_op8
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_S1AP_request_from_op9
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_S1AP_request_from_op10

     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_prim_MME_to_prim_Cplane_for_op1
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_prim_MME_to_prim_Cplane_for_op2
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_prim_MME_to_prim_Cplane_for_op3
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_prim_MME_to_prim_Cplane_for_op4
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_prim_MME_to_prim_Cplane_for_op5
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_prim_MME_to_prim_Cplane_for_op6
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_prim_MME_to_prim_Cplane_for_op7
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_prim_MME_to_prim_Cplane_for_op8
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_prim_MME_to_prim_Cplane_for_op9
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_prim_MME_to_prim_Cplane_for_op10

     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_prim_MME_to_prim_Cplane_for_op1
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_prim_MME_to_prim_Cplane_for_op2
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_prim_MME_to_prim_Cplane_for_op3
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_prim_MME_to_prim_Cplane_for_op4
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_prim_MME_to_prim_Cplane_for_op5
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_prim_MME_to_prim_Cplane_for_op6
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_prim_MME_to_prim_Cplane_for_op7
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_prim_MME_to_prim_Cplane_for_op8
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_prim_MME_to_prim_Cplane_for_op9
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_prim_MME_to_prim_Cplane_for_op10

     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_prim_Cplane_to_Primary_MME_for_op1
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_prim_Cplane_to_Primary_MME_for_op2
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_prim_Cplane_to_Primary_MME_for_op3
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_prim_Cplane_to_Primary_MME_for_op4
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_prim_Cplane_to_Primary_MME_for_op5
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_prim_Cplane_to_Primary_MME_for_op6
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_prim_Cplane_to_Primary_MME_for_op7
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_prim_Cplane_to_Primary_MME_for_op8
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_prim_Cplane_to_Primary_MME_for_op9
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_prim_Cplane_to_Primary_MME_for_op10

     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_prim_Cplane_to_Primary_MME_for_op1
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_prim_Cplane_to_Primary_MME_for_op2
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_prim_Cplane_to_Primary_MME_for_op3
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_prim_Cplane_to_Primary_MME_for_op4
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_prim_Cplane_to_Primary_MME_for_op5
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_prim_Cplane_to_Primary_MME_for_op6
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_prim_Cplane_to_Primary_MME_for_op7
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_prim_Cplane_to_Primary_MME_for_op8
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_prim_Cplane_to_Primary_MME_for_op9
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_prim_Cplane_to_Primary_MME_for_op10

Verify Captured File for Multihoming_V6

     [Arguments]     ${pcap_filename}
     Read IPV6 Parameters
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_Sec_Cplane_to_Sec_MME_for_op1
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_Sec_Cplane_to_Sec_MME_for_op2
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_Sec_Cplane_to_Sec_MME_for_op3
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_Sec_Cplane_to_Sec_MME_for_op4
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_Sec_Cplane_to_Sec_MME_for_op5
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_Sec_Cplane_to_Sec_MME_for_op6
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_Sec_Cplane_to_Sec_MME_for_op7
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_Sec_Cplane_to_Sec_MME_for_op8
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_Sec_Cplane_to_Sec_MME_for_op9
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_Sec_Cplane_to_Sec_MME_for_op10

     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_Sec_Cplane_to_Secondary_MME_for_op1
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_Sec_Cplane_to_Secondary_MME_for_op2
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_Sec_Cplane_to_Secondary_MME_for_op3
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_Sec_Cplane_to_Secondary_MME_for_op4
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_Sec_Cplane_to_Secondary_MME_for_op5
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_Sec_Cplane_to_Secondary_MME_for_op6
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_Sec_Cplane_to_Secondary_MME_for_op7
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_Sec_Cplane_to_Secondary_MME_for_op8
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_Sec_Cplane_to_Secondary_MME_for_op9
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_Sec_Cplane_to_Secondary_MME_for_op10

     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_Sec_MME_to_Secondary_Cplane_for_op1
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_Sec_MME_to_Secondary_Cplane_for_op2
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_Sec_MME_to_Secondary_Cplane_for_op3
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_Sec_MME_to_Secondary_Cplane_for_op4
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_Sec_MME_to_Secondary_Cplane_for_op5
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_Sec_MME_to_Secondary_Cplane_for_op6
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_Sec_MME_to_Secondary_Cplane_for_op7
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_Sec_MME_to_Secondary_Cplane_for_op8
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_Sec_MME_to_Secondary_Cplane_for_op9
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_Sec_MME_to_Secondary_Cplane_for_op10

     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_Sec_MME_to_Sec_Cplane_for_op1
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_Sec_MME_to_Sec_Cplane_for_op2
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_Sec_MME_to_Sec_Cplane_for_op3
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_Sec_MME_to_Sec_Cplane_for_op4
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_Sec_MME_to_Sec_Cplane_for_op5
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_Sec_MME_to_Sec_Cplane_for_op6
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_Sec_MME_to_Sec_Cplane_for_op7
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_Sec_MME_to_Sec_Cplane_for_op8
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_Sec_MME_to_Sec_Cplane_for_op9
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_Sec_MME_to_Sec_Cplane_for_op10

Verify Captured File for Multihoming_V4

     [Arguments]     ${pcap_filename}
     Read IPV4 Parameters
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_Sec_Cplane_to_Sec_MME_for_op1
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_Sec_Cplane_to_Sec_MME_for_op2
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_Sec_Cplane_to_Sec_MME_for_op3
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_Sec_Cplane_to_Sec_MME_for_op4
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_Sec_Cplane_to_Sec_MME_for_op5
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_Sec_Cplane_to_Sec_MME_for_op6
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_Sec_Cplane_to_Sec_MME_for_op7
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_Sec_Cplane_to_Sec_MME_for_op8
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_Sec_Cplane_to_Sec_MME_for_op9
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_Sec_Cplane_to_Sec_MME_for_op10

     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_Sec_Cplane_to_Secondary_MME_for_op1
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_Sec_Cplane_to_Secondary_MME_for_op2
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_Sec_Cplane_to_Secondary_MME_for_op3
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_Sec_Cplane_to_Secondary_MME_for_op4
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_Sec_Cplane_to_Secondary_MME_for_op5
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_Sec_Cplane_to_Secondary_MME_for_op6
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_Sec_Cplane_to_Secondary_MME_for_op7
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_Sec_Cplane_to_Secondary_MME_for_op8
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_Sec_Cplane_to_Secondary_MME_for_op9
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_Sec_Cplane_to_Secondary_MME_for_op10

     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_Sec_MME_to_Secondary_Cplane_for_op1
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_Sec_MME_to_Secondary_Cplane_for_op2
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_Sec_MME_to_Secondary_Cplane_for_op3
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_Sec_MME_to_Secondary_Cplane_for_op4
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_Sec_MME_to_Secondary_Cplane_for_op5
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_Sec_MME_to_Secondary_Cplane_for_op6
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_Sec_MME_to_Secondary_Cplane_for_op7
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_Sec_MME_to_Secondary_Cplane_for_op8
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_Sec_MME_to_Secondary_Cplane_for_op9
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_from_Sec_MME_to_Secondary_Cplane_for_op10

     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_Sec_MME_to_Sec_Cplane_for_op1
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_Sec_MME_to_Sec_Cplane_for_op2
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_Sec_MME_to_Sec_Cplane_for_op3
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_Sec_MME_to_Sec_Cplane_for_op4
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_Sec_MME_to_Sec_Cplane_for_op5
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_Sec_MME_to_Sec_Cplane_for_op6
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_Sec_MME_to_Sec_Cplane_for_op7
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_Sec_MME_to_Sec_Cplane_for_op8
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_Sec_MME_to_Sec_Cplane_for_op9
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_SCTP_HEART_BEAT_ACK_from_Sec_MME_to_Sec_Cplane_for_op10


Read IPV6 Parameters

    ${Primary_MME_V6_op1}=     Get Parameter      param_path=${Primary_MME_V6_IP_op1}
    Set Suite Variable       ${Primary_MME_V6_op1}      ${Primary_MME_V6_op1}
    ${Secondary_MME_V6_op1}=        Get Parameter      param_path=${Secondary_MME_V6_IP_op1}
    Set Suite Variable       ${Secondary_MME_V6_op1}         ${Secondary_MME_V6_op1}
    ${Primary_Cplane_V6_op1}=     Get Parameter      param_path=${Primary_Cplane_V6_IP_op1}
    Set Suite Variable       ${Primary_Cplane_V6_op1}       ${Primary_Cplane_V6_op1}
    ${Secondary_Cplane_V6_op1}=        Get Parameter      param_path=${Secondary_Cplane_V6_IP_op1}
    Set Suite Variable       ${Secondary_Cplane_V6_op1}          ${Secondary_Cplane_V6_op1}

	${Primary_MME_V6_op2}=     Get Parameter      param_path=${Primary_MME_V6_IP_op2}
	Set Suite Variable	     ${Primary_MME_V6_op2}	     ${Primary_MME_V6_op2}
    ${Secondary_MME_V6_op2}=        Get Parameter      param_path=${Secondary_MME_V6_IP_op2}
	Set Suite Variable	     ${Secondary_MME_V6_op2}	      ${Secondary_MME_V6_op2}
    ${Primary_Cplane_V6_op2}=     Get Parameter      param_path=${Primary_Cplane_V6_IP_op2}
	Set Suite Variable	     ${Primary_Cplane_V6_op2}	     ${Primary_Cplane_V6_op2}
    ${Secondary_Cplane_V6_op2}=        Get Parameter      param_path=${Secondary_Cplane_V6_IP_op2}
	Set Suite Variable	     ${Secondary_Cplane_V6_op2}	      ${Secondary_Cplane_V6_op2}

	${Primary_MME_V6_op3}=     Get Parameter      param_path=${Primary_MME_V6_IP_op3}
	Set Suite Variable	     ${Primary_MME_V6_op3}	     ${Primary_MME_V6_op3}
    ${Secondary_MME_V6_op3}=        Get Parameter      param_path=${Secondary_MME_V6_IP_op3}
	Set Suite Variable	     ${Secondary_MME_V6_op3}	      ${Secondary_MME_V6_op3}
    ${Primary_Cplane_V6_op3}=     Get Parameter      param_path=${Primary_Cplane_V6_IP_op3}
	Set Suite Variable	     ${Primary_Cplane_V6_op3}	     ${Primary_Cplane_V6_op3}
    ${Secondary_Cplane_V6_op3}=        Get Parameter      param_path=${Secondary_Cplane_V6_IP_op3}
	Set Suite Variable	     ${Secondary_Cplane_V6_op3}	      ${Secondary_Cplane_V6_op3}

	${Primary_MME_V6_op4}=     Get Parameter      param_path=${Primary_MME_V6_IP_op4}
	Set Suite Variable	     ${Primary_MME_V6_op4}	     ${Primary_MME_V6_op4}
    ${Secondary_MME_V6_op4}=        Get Parameter      param_path=${Secondary_MME_V6_IP_op4}
	Set Suite Variable	     ${Secondary_MME_V6_op4}	      ${Secondary_MME_V6_op4}
    ${Primary_Cplane_V6_op4}=     Get Parameter      param_path=${Primary_Cplane_V6_IP_op4}
	Set Suite Variable	     ${Primary_Cplane_V6_op4}	     ${Primary_Cplane_V6_op4}
    ${Secondary_Cplane_V6_op4}=        Get Parameter      param_path=${Secondary_Cplane_V6_IP_op4}
	Set Suite Variable	     ${Secondary_Cplane_V6_op4}	      ${Secondary_Cplane_V6_op4}

	${Primary_MME_V6_op5}=     Get Parameter      param_path=${Primary_MME_V6_IP_op5}
	Set Suite Variable	     ${Primary_MME_V6_op5}	     ${Primary_MME_V6_op5}
    ${Secondary_MME_V6_op5}=        Get Parameter      param_path=${Secondary_MME_V6_IP_op5}
	Set Suite Variable	     ${Secondary_MME_V6_op5}	      ${Secondary_MME_V6_op5}
    ${Primary_Cplane_V6_op5}=     Get Parameter      param_path=${Primary_Cplane_V6_IP_op5}
	Set Suite Variable	     ${Primary_Cplane_V6_op5}	     ${Primary_Cplane_V6_op5}
    ${Secondary_Cplane_V6_op5}=        Get Parameter      param_path=${Secondary_Cplane_V6_IP_op5}
	Set Suite Variable	     ${Secondary_Cplane_V6_op5}	      ${Secondary_Cplane_V6_op5}

	${Primary_MME_V6_op6}=     Get Parameter      param_path=${Primary_MME_V6_IP_op6}
	Set Suite Variable	     ${Primary_MME_V6_op6}	     ${Primary_MME_V6_op6}
    ${Secondary_MME_V6_op6}=        Get Parameter      param_path=${Secondary_MME_V6_IP_op6}
	Set Suite Variable	     ${Secondary_MME_V6_op6}	      ${Secondary_MME_V6_op6}
    ${Primary_Cplane_V6_op6}=     Get Parameter      param_path=${Primary_Cplane_V6_IP_op6}
	Set Suite Variable	     ${Primary_Cplane_V6_op6}	     ${Primary_Cplane_V6_op6}
    ${Secondary_Cplane_V6_op6}=        Get Parameter      param_path=${Secondary_Cplane_V6_IP_op6}
	Set Suite Variable	     ${Secondary_Cplane_V6_op6}	      ${Secondary_Cplane_V6_op6}

	${Primary_MME_V6_op7}=     Get Parameter      param_path=${Primary_MME_V6_IP_op7}
	Set Suite Variable	     ${Primary_MME_V6_op7}	     ${Primary_MME_V6_op7}
    ${Secondary_MME_V6_op7}=        Get Parameter      param_path=${Secondary_MME_V6_IP_op7}
	Set Suite Variable	     ${Secondary_MME_V6_op7}	      ${Secondary_MME_V6_op7}
    ${Primary_Cplane_V6_op7}=     Get Parameter      param_path=${Primary_Cplane_V6_IP_op7}
	Set Suite Variable	     ${Primary_Cplane_V6_op7}	     ${Primary_Cplane_V6_op7}
    ${Secondary_Cplane_V6_op7}=        Get Parameter      param_path=${Secondary_Cplane_V6_IP_op7}
	Set Suite Variable	     ${Secondary_Cplane_V6_op7}	      ${Secondary_Cplane_V6_op7}

	${Primary_MME_V6_op8}=     Get Parameter      param_path=${Primary_MME_V6_IP_op8}
	Set Suite Variable	     ${Primary_MME_V6_op8}	     ${Primary_MME_V6_op8}
    ${Secondary_MME_V6_op8}=        Get Parameter      param_path=${Secondary_MME_V6_IP_op8}
	Set Suite Variable	     ${Secondary_MME_V6_op8}	      ${Secondary_MME_V6_op8}
    ${Primary_Cplane_V6_op8}=     Get Parameter      param_path=${Primary_Cplane_V6_IP_op8}
	Set Suite Variable	     ${Primary_Cplane_V6_op8}	     ${Primary_Cplane_V6_op8}
    ${Secondary_Cplane_V6_op8}=        Get Parameter      param_path=${Secondary_Cplane_V6_IP_op8}
	Set Suite Variable	     ${Secondary_Cplane_V6_op8}	      ${Secondary_Cplane_V6_op8}

	${Primary_MME_V6_op9}=     Get Parameter      param_path=${Primary_MME_V6_IP_op9}
	Set Suite Variable	     ${Primary_MME_V6_op9}	     ${Primary_MME_V6_op9}
    ${Secondary_MME_V6_op9}=        Get Parameter      param_path=${Secondary_MME_V6_IP_op9}
	Set Suite Variable	     ${Secondary_MME_V6_op9}	      ${Secondary_MME_V6_op9}
    ${Primary_Cplane_V6_op9}=     Get Parameter      param_path=${Primary_Cplane_V6_IP_op9}
	Set Suite Variable	     ${Primary_Cplane_V6_op9}	     ${Primary_Cplane_V6_op9}
    ${Secondary_Cplane_V6_op9}=        Get Parameter      param_path=${Secondary_Cplane_V6_IP_op9}
	Set Suite Variable	     ${Secondary_Cplane_V6_op9}	      ${Secondary_Cplane_V6_op9}

	${Primary_MME_V6_op10}=     Get Parameter      param_path=${Primary_MME_V6_IP_op10}
	Set Suite Variable	     ${Primary_MME_V6_op10}	     ${Primary_MME_V6_op10}
    ${Secondary_MME_V6_op10}=        Get Parameter      param_path=${Secondary_MME_V6_IP_op10}
	Set Suite Variable	     ${Secondary_MME_V6_op10}	      ${Secondary_MME_V6_op10}
    ${Primary_Cplane_V6_op10}=     Get Parameter      param_path=${Primary_Cplane_V6_IP_op10}
	Set Suite Variable	     ${Primary_Cplane_V6_op10}	     ${Primary_Cplane_V6_op10}
    ${Secondary_Cplane_V6_op10}=        Get Parameter      param_path=${Secondary_Cplane_V6_IP_op10}
	Set Suite Variable	     ${Secondary_Cplane_V6_op10}	      ${Secondary_Cplane_V6_op10}

Read IPV4 Parameters

    ${Primary_MME_op1}=     Get Parameter      param_path=${Primary_MME_IP_op1}
    Set Suite Variable       ${Primary_MME_op1}      ${Primary_MME_op1}
    ${Secondary_MME_op1}=        Get Parameter      param_path=${Secondary_MME_IP_op1}
    Set Suite Variable       ${Secondary_MME_op1}         ${Secondary_MME_op1}
    ${Primary_Cplane_op1}=     Get Parameter      param_path=${Primary_Cplane_IP_op1}
    Set Suite Variable       ${Primary_Cplane_op1}       ${Primary_Cplane_op1}
    ${Secondary_Cplane_op1}=        Get Parameter      param_path=${Secondary_Cplane_IP_op1}
    Set Suite Variable       ${Secondary_Cplane_op1}          ${Secondary_Cplane_op1}

	${Primary_MME_op2}=     Get Parameter      param_path=${Primary_MME_IP_op2}
	Set Suite Variable	     ${Primary_MME_op2}	     ${Primary_MME_op2}
    ${Secondary_MME_op2}=        Get Parameter      param_path=${Secondary_MME_IP_op2}
	Set Suite Variable	     ${Secondary_MME_op2}	      ${Secondary_MME_op2}
    ${Primary_Cplane_op2}=     Get Parameter      param_path=${Primary_Cplane_IP_op2}
	Set Suite Variable	     ${Primary_Cplane_op2}	     ${Primary_Cplane_op2}
    ${Secondary_Cplane_op2}=        Get Parameter      param_path=${Secondary_Cplane_IP_op2}
	Set Suite Variable	     ${Secondary_Cplane_op2}	      ${Secondary_Cplane_op2}

	${Primary_MME_op3}=     Get Parameter      param_path=${Primary_MME_IP_op3}
	Set Suite Variable	     ${Primary_MME_op3}	     ${Primary_MME_op3}
    ${Secondary_MME_op3}=        Get Parameter      param_path=${Secondary_MME_IP_op3}
	Set Suite Variable	     ${Secondary_MME_op3}	      ${Secondary_MME_op3}
    ${Primary_Cplane_op3}=     Get Parameter      param_path=${Primary_Cplane_IP_op3}
	Set Suite Variable	     ${Primary_Cplane_op3}	     ${Primary_Cplane_op3}
    ${Secondary_Cplane_op3}=        Get Parameter      param_path=${Secondary_Cplane_IP_op3}
	Set Suite Variable	     ${Secondary_Cplane_op3}	      ${Secondary_Cplane_op3}

	${Primary_MME_op4}=     Get Parameter      param_path=${Primary_MME_IP_op4}
	Set Suite Variable	     ${Primary_MME_op4}	     ${Primary_MME_op4}
    ${Secondary_MME_op4}=        Get Parameter      param_path=${Secondary_MME_IP_op4}
	Set Suite Variable	     ${Secondary_MME_op4}	      ${Secondary_MME_op4}
    ${Primary_Cplane_op4}=     Get Parameter      param_path=${Primary_Cplane_IP_op4}
	Set Suite Variable	     ${Primary_Cplane_op4}	     ${Primary_Cplane_op4}
    ${Secondary_Cplane_op4}=        Get Parameter      param_path=${Secondary_Cplane_IP_op4}
	Set Suite Variable	     ${Secondary_Cplane_op4}	      ${Secondary_Cplane_op4}

	${Primary_MME_op5}=     Get Parameter      param_path=${Primary_MME_IP_op5}
	Set Suite Variable	     ${Primary_MME_op5}	     ${Primary_MME_op5}
    ${Secondary_MME_op5}=        Get Parameter      param_path=${Secondary_MME_IP_op5}
	Set Suite Variable	     ${Secondary_MME_op5}	      ${Secondary_MME_op5}
    ${Primary_Cplane_op5}=     Get Parameter      param_path=${Primary_Cplane_IP_op5}
	Set Suite Variable	     ${Primary_Cplane_op5}	     ${Primary_Cplane_op5}
    ${Secondary_Cplane_op5}=        Get Parameter      param_path=${Secondary_Cplane_IP_op5}
	Set Suite Variable	     ${Secondary_Cplane_op5}	      ${Secondary_Cplane_op5}

	${Primary_MME_op6}=     Get Parameter      param_path=${Primary_MME_IP_op6}
	Set Suite Variable	     ${Primary_MME_op6}	     ${Primary_MME_op6}
    ${Secondary_MME_op6}=        Get Parameter      param_path=${Secondary_MME_IP_op6}
	Set Suite Variable	     ${Secondary_MME_op6}	      ${Secondary_MME_op6}
    ${Primary_Cplane_op6}=     Get Parameter      param_path=${Primary_Cplane_IP_op6}
	Set Suite Variable	     ${Primary_Cplane_op6}	     ${Primary_Cplane_op6}
    ${Secondary_Cplane_op6}=        Get Parameter      param_path=${Secondary_Cplane_IP_op6}
	Set Suite Variable	     ${Secondary_Cplane_op6}	      ${Secondary_Cplane_op6}

	${Primary_MME_op7}=     Get Parameter      param_path=${Primary_MME_IP_op7}
	Set Suite Variable	     ${Primary_MME_op7}	     ${Primary_MME_op7}
    ${Secondary_MME_op7}=        Get Parameter      param_path=${Secondary_MME_IP_op7}
	Set Suite Variable	     ${Secondary_MME_op7}	      ${Secondary_MME_op7}
    ${Primary_Cplane_op7}=     Get Parameter      param_path=${Primary_Cplane_IP_op7}
	Set Suite Variable	     ${Primary_Cplane_op7}	     ${Primary_Cplane_op7}
    ${Secondary_Cplane_op7}=        Get Parameter      param_path=${Secondary_Cplane_IP_op7}
	Set Suite Variable	     ${Secondary_Cplane_op7}	      ${Secondary_Cplane_op7}

	${Primary_MME_op8}=     Get Parameter      param_path=${Primary_MME_IP_op8}
	Set Suite Variable	     ${Primary_MME_op8}	     ${Primary_MME_op8}
    ${Secondary_MME_op8}=        Get Parameter      param_path=${Secondary_MME_IP_op8}
	Set Suite Variable	     ${Secondary_MME_op8}	      ${Secondary_MME_op8}
    ${Primary_Cplane_op8}=     Get Parameter      param_path=${Primary_Cplane_IP_op8}
	Set Suite Variable	     ${Primary_Cplane_op8}	     ${Primary_Cplane_op8}
    ${Secondary_Cplane_op8}=        Get Parameter      param_path=${Secondary_Cplane_IP_op8}
	Set Suite Variable	     ${Secondary_Cplane_op8}	      ${Secondary_Cplane_op8}

	${Primary_MME_op9}=     Get Parameter      param_path=${Primary_MME_IP_op9}
	Set Suite Variable	     ${Primary_MME_op9}	     ${Primary_MME_op9}
    ${Secondary_MME_op9}=        Get Parameter      param_path=${Secondary_MME_IP_op9}
	Set Suite Variable	     ${Secondary_MME_op9}	      ${Secondary_MME_op9}
    ${Primary_Cplane_op9}=     Get Parameter      param_path=${Primary_Cplane_IP_op9}
	Set Suite Variable	     ${Primary_Cplane_op9}	     ${Primary_Cplane_op9}
    ${Secondary_Cplane_op9}=        Get Parameter      param_path=${Secondary_Cplane_IP_op9}
	Set Suite Variable	     ${Secondary_Cplane_op9}	      ${Secondary_Cplane_op9}

	${Primary_MME_op10}=     Get Parameter      param_path=${Primary_MME_IP_op10}
	Set Suite Variable	     ${Primary_MME_op10}	     ${Primary_MME_op10}
    ${Secondary_MME_op10}=        Get Parameter      param_path=${Secondary_MME_IP_op10}
	Set Suite Variable	     ${Secondary_MME_op10}	      ${Secondary_MME_op10}
    ${Primary_Cplane_op10}=     Get Parameter      param_path=${Primary_Cplane_IP_op10}
	Set Suite Variable	     ${Primary_Cplane_op10}	     ${Primary_Cplane_op10}
    ${Secondary_Cplane_op10}=        Get Parameter      param_path=${Secondary_Cplane_IP_op10}
	Set Suite Variable	     ${Secondary_Cplane_op10}	      ${Secondary_Cplane_op10}

Collect list of Alarms Before enabling the feature

    ${alarms_before_feature}             Verify Alarm

    Set Suite Variable       ${alarms_before_feature}        ${alarms_before_feature}

Verify Unexpected alarms After the feature execution

    Verify Alarm      prev_alarms=${alarms_before_feature}      expected_alarms=${expected_alarms}     check_unexpected_alarms=${True}

Verify S1Link status is up for all 6 operators

    ${LNMME_moc_op1}=   Query Admin Infomodel   query=get object ${LNMME_moc_path_op1}
    ${s1Link_status_op1}=  Get From Dictionary     dictionary=${LNMME_moc_op1}     key=s1LinkStatus
    Should Be Equal     ${s1Link_status_op1}       available

    ${LNMME_moc}=   Query Admin Infomodel   query=get object ${LNMME_moc_path_op2}
    ${s1Link_status}=  Get From Dictionary     dictionary=${LNMME_moc}     key=s1LinkStatus
    Should Be Equal     ${s1Link_status}       available

    ${LNMME_moc}=   Query Admin Infomodel   query=get object ${LNMME_moc_path_op3}
    ${s1Link_status}=  Get From Dictionary     dictionary=${LNMME_moc}     key=s1LinkStatus
    Should Be Equal     ${s1Link_status}       available

    ${LNMME_moc}=   Query Admin Infomodel   query=get object ${LNMME_moc_path_op4}
    ${s1Link_status}=  Get From Dictionary     dictionary=${LNMME_moc}     key=s1LinkStatus
    Should Be Equal     ${s1Link_status}       available

    ${LNMME_moc}=   Query Admin Infomodel   query=get object ${LNMME_moc_path_op5}
    ${s1Link_status}=  Get From Dictionary     dictionary=${LNMME_moc}     key=s1LinkStatus
    Should Be Equal     ${s1Link_status}       available

    ${LNMME_moc}=   Query Admin Infomodel   query=get object ${LNMME_moc_path_op6}
    ${s1Link_status}=  Get From Dictionary     dictionary=${LNMME_moc}     key=s1LinkStatus
    Should Be Equal     ${s1Link_status}       available

Verify S1Link status is up for all IPV6 6 operators

    ${LNMME_moc}=   Query Admin Infomodel   query=get object ${LNMME_moc_path_v6_op1}
    ${s1Link_status}=  Get From Dictionary     dictionary=${LNMME_moc}     key=s1LinkStatus
    Should Be Equal     ${s1Link_status}       available

    ${LNMME_moc}=   Query Admin Infomodel   query=get object ${LNMME_moc_path_v6_op2}
    ${s1Link_status}=  Get From Dictionary     dictionary=${LNMME_moc}     key=s1LinkStatus
    Should Be Equal     ${s1Link_status}       available

    ${LNMME_moc}=   Query Admin Infomodel   query=get object ${LNMME_moc_path_v6_op3}
    ${s1Link_status}=  Get From Dictionary     dictionary=${LNMME_moc}     key=s1LinkStatus
    Should Be Equal     ${s1Link_status}       available

    ${LNMME_moc}=   Query Admin Infomodel   query=get object ${LNMME_moc_path_v6_op4}
    ${s1Link_status}=  Get From Dictionary     dictionary=${LNMME_moc}     key=s1LinkStatus
    Should Be Equal     ${s1Link_status}       available

    ${LNMME_moc}=   Query Admin Infomodel   query=get object ${LNMME_moc_path_v6_op5}
    ${s1Link_status}=  Get From Dictionary     dictionary=${LNMME_moc}     key=s1LinkStatus
    Should Be Equal     ${s1Link_status}       available

    ${LNMME_moc}=   Query Admin Infomodel   query=get object ${LNMME_moc_path_v6_op6}
    ${s1Link_status}=  Get From Dictionary     dictionary=${LNMME_moc}     key=s1LinkStatus
    Should Be Equal     ${s1Link_status}       available

Verify Cplane DSCP Value IPV6
	[Arguments]     ${pcap_filename}
    Read IPV6 Parameters
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_updated_dscp_value_for_op1
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_updated_dscp_value_for_op2
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_updated_dscp_value_for_op3
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_updated_dscp_value_for_op4
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_updated_dscp_value_for_op5
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_updated_dscp_value_for_op6
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_updated_dscp_value_for_op7
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_updated_dscp_value_for_op8
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_updated_dscp_value_for_op9
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_updated_dscp_value_for_op10

Verify Cplane DSCP Value IPV4
    [Arguments]     ${pcap_filename}
    Read IPV4 Parameters
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_updated_dscp_value_for_op1
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_updated_dscp_value_for_op2
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_updated_dscp_value_for_op3
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_updated_dscp_value_for_op4
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_updated_dscp_value_for_op5
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_updated_dscp_value_for_op6
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_updated_dscp_value_for_op7
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_updated_dscp_value_for_op8
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_updated_dscp_value_for_op9
     Analyse Pcap    pcap_filename=${pcap_filename}      analysis=Verify_updated_dscp_value_for_op10

Block Primary Cplane of all IPV4 10 Operators
        Read IPV4 Parameters
	Setup Remote Access      remote_device=bts
	Remote Command Execute      command= iptables -A OUTPUT -s ${Primary_Cplane_op1}/32 -j DROP
	Remote Command Execute      command= iptables -A INPUT -d ${Primary_Cplane_op1}/32 -j DROP
	Remote Command Execute      command= iptables -A OUTPUT -s ${Primary_Cplane_op2}/32 -j DROP
	Remote Command Execute      command= iptables -A INPUT -d ${Primary_Cplane_op2}/32 -j DROP
	Remote Command Execute      command= iptables -A OUTPUT -s ${Primary_Cplane_op3}/32 -j DROP
	Remote Command Execute      command= iptables -A INPUT -d ${Primary_Cplane_op3}/32 -j DROP
	Remote Command Execute      command= iptables -A OUTPUT -s ${Primary_Cplane_op4}/32 -j DROP
	Remote Command Execute      command= iptables -A INPUT -d ${Primary_Cplane_op4}/32 -j DROP
	Remote Command Execute      command= iptables -A OUTPUT -s ${Primary_Cplane_op5}/32 -j DROP
	Remote Command Execute      command= iptables -A INPUT -d ${Primary_Cplane_op5}/32 -j DROP
	Remote Command Execute      command= iptables -A OUTPUT -s ${Primary_Cplane_op6}/32 -j DROP
	Remote Command Execute      command= iptables -A INPUT -d ${Primary_Cplane_op6}/32 -j DROP
	Remote Command Execute      command= iptables -A OUTPUT -s ${Primary_Cplane_op7}/32 -j DROP
	Remote Command Execute      command= iptables -A INPUT -d ${Primary_Cplane_op7}/32 -j DROP
	Remote Command Execute      command= iptables -A OUTPUT -s ${Primary_Cplane_op8}/32 -j DROP
	Remote Command Execute      command= iptables -A INPUT -d ${Primary_Cplane_op8}/32 -j DROP
	Remote Command Execute      command= iptables -A OUTPUT -s ${Primary_Cplane_op9}/32 -j DROP
	Remote Command Execute      command= iptables -A INPUT -d ${Primary_Cplane_op9}/32 -j DROP
	Remote Command Execute      command= iptables -A OUTPUT -s ${Primary_Cplane_op10}/32 -j DROP
	Remote Command Execute      command= iptables -A INPUT -d ${Primary_Cplane_op10}/32 -j DROP
#	[Teardown]      Teardown Remote Access

Unblock Primary Cplane of all IPV4 10 Operators

        Read IPV4 Parameters
	Setup Remote Access      remote_device=bts      alias=UnBlock
	Remote Command Execute      command= iptables -D OUTPUT -s ${Primary_Cplane_op1}/32 -j DROP
	Remote Command Execute      command= iptables -D INPUT -d ${Primary_Cplane_op1}/32 -j DROP
	Remote Command Execute      command= iptables -D OUTPUT -s ${Primary_Cplane_op2}/32 -j DROP
	Remote Command Execute      command= iptables -D INPUT -d ${Primary_Cplane_op2}/32 -j DROP
	Remote Command Execute      command= iptables -D OUTPUT -s ${Primary_Cplane_op3}/32 -j DROP
	Remote Command Execute      command= iptables -D INPUT -d ${Primary_Cplane_op3}/32 -j DROP
	Remote Command Execute      command= iptables -D OUTPUT -s ${Primary_Cplane_op4}/32 -j DROP
	Remote Command Execute      command= iptables -D INPUT -d ${Primary_Cplane_op4}/32 -j DROP
	Remote Command Execute      command= iptables -D OUTPUT -s ${Primary_Cplane_op5}/32 -j DROP
	Remote Command Execute      command= iptables -D INPUT -d ${Primary_Cplane_op5}/32 -j DROP
	Remote Command Execute      command= iptables -D OUTPUT -s ${Primary_Cplane_op6}/32 -j DROP
	Remote Command Execute      command= iptables -D INPUT -d ${Primary_Cplane_op6}/32 -j DROP
	Remote Command Execute      command= iptables -D OUTPUT -s ${Primary_Cplane_op7}/32 -j DROP
	Remote Command Execute      command= iptables -D INPUT -d ${Primary_Cplane_op7}/32 -j DROP
	Remote Command Execute      command= iptables -D OUTPUT -s ${Primary_Cplane_op8}/32 -j DROP
	Remote Command Execute      command= iptables -D INPUT -d ${Primary_Cplane_op8}/32 -j DROP
	Remote Command Execute      command= iptables -D OUTPUT -s ${Primary_Cplane_op9}/32 -j DROP
	Remote Command Execute      command= iptables -D INPUT -d ${Primary_Cplane_op9}/32 -j DROP
	Remote Command Execute      command= iptables -D OUTPUT -s ${Primary_Cplane_op10}/32 -j DROP
	Remote Command Execute      command= iptables -D INPUT -d ${Primary_Cplane_op10}/32 -j DROP
	[Teardown]      Teardown Remote Access

Block Primary Cplane of all IPV6 10 Operators
    Read IPV6 Parameters
	Setup Remote Access      remote_device=bts      alias=Block
	Remote Command Execute      command= ip6tables -A OUTPUT -s ${Primary_Cplane_V6_op1}/128 -j DROP      alias=Block
	Remote Command Execute      command= ip6tables -A INPUT -d ${Primary_Cplane_V6_op1}/128 -j DROP       alias=Block
	Remote Command Execute      command= ip6tables -A OUTPUT -s ${Primary_Cplane_V6_op2}/128 -j DROP      alias=Block
	Remote Command Execute      command= ip6tables -A INPUT -d ${Primary_Cplane_V6_op2}/128 -j DROP       alias=Block
	Remote Command Execute      command= ip6tables -A OUTPUT -s ${Primary_Cplane_V6_op3}/128 -j DROP      alias=Block
	Remote Command Execute      command= ip6tables -A INPUT -d ${Primary_Cplane_V6_op3}/128 -j DROP       alias=Block
	Remote Command Execute      command= ip6tables -A OUTPUT -s ${Primary_Cplane_V6_op4}/128 -j DROP      alias=Block
	Remote Command Execute      command= ip6tables -A INPUT -d ${Primary_Cplane_V6_op4}/128 -j DROP       alias=Block
	Remote Command Execute      command= ip6tables -A OUTPUT -s ${Primary_Cplane_V6_op5}/128 -j DROP      alias=Block
	Remote Command Execute      command= ip6tables -A INPUT -d ${Primary_Cplane_V6_op5}/128 -j DROP       alias=Block
	Remote Command Execute      command= ip6tables -A OUTPUT -s ${Primary_Cplane_V6_op6}/128 -j DROP      alias=Block
	Remote Command Execute      command= ip6tables -A INPUT -d ${Primary_Cplane_V6_op6}/128 -j DROP       alias=Block
	Remote Command Execute      command= ip6tables -A OUTPUT -s ${Primary_Cplane_V6_op7}/128 -j DROP      alias=Block
	Remote Command Execute      command= ip6tables -A INPUT -d ${Primary_Cplane_V6_op7}/128 -j DROP       alias=Block
	Remote Command Execute      command= ip6tables -A OUTPUT -s ${Primary_Cplane_V6_op8}/128 -j DROP      alias=Block
	Remote Command Execute      command= ip6tables -A INPUT -d ${Primary_Cplane_V6_op8}/128 -j DROP       alias=Block
	Remote Command Execute      command= ip6tables -A OUTPUT -s ${Primary_Cplane_V6_op9}/128 -j DROP      alias=Block
	Remote Command Execute      command= ip6tables -A INPUT -d ${Primary_Cplane_V6_op9}/128 -j DROP       alias=Block
	Remote Command Execute      command= ip6tables -A OUTPUT -s ${Primary_Cplane_V6_op10}/128 -j DROP     alias=Block
	Remote Command Execute      command= ip6tables -A INPUT -d ${Primary_Cplane_V6_op10}/128 -j DROP 		alias=Block
	[Teardown]      Teardown Remote Access      alias=Block

Unblock Primary Cplane of all IPV6 10 Operators
    Read IPV6 Parameters
	Setup Remote Access      remote_device=bts		alias=UnBlock
	Remote Command Execute      command= ip6tables -D OUTPUT -s ${Primary_Cplane_V6_op1}/128 -j DROP		alias=UnBlock
	Remote Command Execute      command= ip6tables -D INPUT -d ${Primary_Cplane_V6_op1}/128 -j DROP		alias=UnBlock
	Remote Command Execute      command= ip6tables -D OUTPUT -s ${Primary_Cplane_V6_op2}/128 -j DROP		alias=UnBlock
	Remote Command Execute      command= ip6tables -D INPUT -d ${Primary_Cplane_V6_op2}/128 -j DROP		alias=UnBlock
	Remote Command Execute      command= ip6tables -D OUTPUT -s ${Primary_Cplane_V6_op3}/128 -j DROP		alias=UnBlock
	Remote Command Execute      command= ip6tables -D INPUT -d ${Primary_Cplane_V6_op3}/128 -j DROP		alias=UnBlock
	Remote Command Execute      command= ip6tables -D OUTPUT -s ${Primary_Cplane_V6_op4}/128 -j DROP		alias=UnBlock
	Remote Command Execute      command= ip6tables -D INPUT -d ${Primary_Cplane_V6_op4}/128 -j DROP		alias=UnBlock
	Remote Command Execute      command= ip6tables -D OUTPUT -s ${Primary_Cplane_V6_op5}/128 -j DROP		alias=UnBlock
	Remote Command Execute      command= ip6tables -D INPUT -d ${Primary_Cplane_V6_op5}/128 -j DROP		alias=UnBlock
	Remote Command Execute      command= ip6tables -D OUTPUT -s ${Primary_Cplane_V6_op6}/128 -j DROP		alias=UnBlock
    Remote Command Execute      command= ip6tables -D INPUT -d ${Primary_Cplane_V6_op6}/128 -j DROP		alias=UnBlock
	Remote Command Execute      command= ip6tables -D OUTPUT -s ${Primary_Cplane_V6_op7}/128 -j DROP	alias=UnBlock
	Remote Command Execute      command= ip6tables -D INPUT -d ${Primary_Cplane_V6_op7}/128 -j DROP		alias=UnBlock
	Remote Command Execute      command= ip6tables -D OUTPUT -s ${Primary_Cplane_V6_op8}/128 -j DROP	alias=UnBlock
	Remote Command Execute      command= ip6tables -D INPUT -d ${Primary_Cplane_V6_op8}/128 -j DROP		alias=UnBlock
	Remote Command Execute      command= ip6tables -D OUTPUT -s ${Primary_Cplane_V6_op9}/128 -j DROP		alias=UnBlock
	Remote Command Execute      command= ip6tables -D INPUT -d ${Primary_Cplane_V6_op9}/128 -j DROP		alias=UnBlock
	Remote Command Execute      command= ip6tables -D OUTPUT -s ${Primary_Cplane_V6_op10}/128 -j DROP	alias=UnBlock
	Remote Command Execute      command= ip6tables -D INPUT -d ${Primary_Cplane_V6_op10}/128 -j DROP		alias=UnBlock
	[Teardown]      Teardown Remote Access		alias=UnBlock