*** Settings ***

Documentation
...     [Author]                "Madhumitha R"
...     [Maintenance]           "TRS I & V Tools Bangalore Team"
...     [Date]                  "21:02:2023"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"
...     [Feature_ID]            "CB010762"
...     [Funtion_Hash_Tags]     "Ransharing NSA"
...     [Procedure]             "Verification of NSA Ransharing"


Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/../resources/common_keywords.robot


Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops


*** Test Cases ***


[1]TRS_CB010762_A_B1_Verification_for_10_operators_with_NSA


    Perform Commissioning    scf_file=${Ipsec_scf}    skip_parameter_relation_errors=${True}     verify_bts_status=${False}   timeout=8000
    Sleep    800
    Traffic Capture Start       capture_device=oam_device      mode=file    uplane_capturing=True
    ...     measurement_point=Transport_Interface      timeout=180     alias=point_B
    Sleep       30
	Reset      operation=reset_rat      rat=lte     should_be_onair=${False}
    sleep  400
    Verify Bts Status       req_rat=lte     should_be_onair=${True}     wait_for=600
    Verify X2Link status is up
   ${filemode_capture}=    Traffic Capture Stop    mode=file   timeout=120     alias=point_B
   Verify x2 link status    ${filemode_capture}

*** keywords ***


Verify x2 link status
    [Arguments]     ${pcap_filename}
     Analyse Pcap    pcap_filename=${pcap_filename}    analysis=verify_ENDCX2SetupRequest
     Analyse Pcap    pcap_filename=${pcap_filename}    analysis=verify_ENDCX2SetupResponse

Verify X2Link status is up

    ${LteEnb_moc}=   Query Admin Infomodel   query=get object ${LTEENB_moc_path}
    ${X2Link_status}=  Get From Dictionary     dictionary=${LteEnb_moc}     key=x2ToGnbLinkStatus
    Should Be Equal     ${X2Link_status}       available