*** Settings ***
Documentation
...     [Procedure]     "Verify IPSEC functionality with RSA and ECDSA certificate"
...     [Author]        "Nandini P"
...     [Maintenance]   "TRS_VRF"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"
...     [Function_Hash_Tags]    "CNI92066"
...     [Validation_status]     "Validated"
...     [Validated_TestLine]    "ASIL_Olympians"

Force Tags       CLOUD_R4BANO_CUS  CA_E2ET_BTSTRSPZ        SBTS00    RAN_4G    RAN_4G_FDD       QCD_MN_RAN        QCP_RAN_VRF        CRT

#variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
#Resource        ${CURDIR}/../resources/Admin_Common_Library.robot

#Suite Setup       Setup Oamops
#Suite Teardown    Teardown Oamops
Suite Setup             Run Keywords    Pre-conditions for testsuite
Suite Teardown     Run Keywords         Post-conditions for testteardown



*** Test Cases ***
[1][1.0] CNI_92066_Verify_IPsec_functionality_with_RSA_certificate_and_ECDSA_certificate.

    Precondition
    Bring setup onair
    Configure CMP moc and install certificate and verify     ECDSA
    Configure CMP moc and install certificate and verify     RSA
    Configure IPsec
    Verify DPD & IKE Authentication alarm and Tunnel status
#@    Run Keyword And Ignore Error    Perform software download and update     wft_profile=sbtstrunk_00       package=auto
#@    ...     activate_sw=true    update_timeout=4500
    Run Keyword And Ignore Error    Perform software download and update     wft_profile=sbtsbranch_25R3
    ...     package=auto     activate_sw=true    update_timeout=4500
    Sleep   900
    Wait Until Keyword Succeeds  10 min     1 min    Verify Bts Status   should_be_onair=${True}
    Run Keyword And Ignore Error    Verify Alarm    faultid=6450     should_exist=
    Run     sudo ipsec restart --debug-all --nofork > Ipsec_status.txt &
    Sleep   30
    Verify Certificate status     ECDSA
    Verify Certificate status      RSA
    Verify IPSEC Status     ESTABLISHED
    Verify DPD & IKE Authentication alarm and Tunnel status
    [Teardown]    Keywords to run at end

***Keywords***

Precondition
    Run     sudo ip addr add 10.0.3.209/30 brd 10.0.3.211 dev eth3.${vlan_ids}[0]
    Run     sudo ifconfig eth3.${vlan_ids}[0] inet6 add fc00::3:6/126
    Run     sudo cp /etc/ipsec.conf /etc/ipsec_backup.conf

Keywords to run at end
        Run     sudo killall edaemon egate
        Run     sudo ipsec stop
        Run     sudo ip a d 10.0.3.209/30 dev eth3.${vlan_ids}[0]
        Run     sudo ip a d fc00::3:6/126 dev eth3.${vlan_ids}[0]
#a        Run     sudo unlink /etc/ipsec.conf
#a        certificate configure    operation=delete_cert  all_certs=${True}
        Run     rm -rf ${CURDIR}/execution_logs/*_A54.zip


Bring setup onair
    Run Keyword And Ignore Error    Call Setup      lte=plain_call:data    parallel=${False}    verify_attach=${False}   attach=
    Sleep   60
    Verify BTS status   should_be_onair=${True}

Configure CMP moc and install certificate and verify
    [Arguments]     ${Cert_type_param}
    Set Suite Variable      ${Cert_type_param}      ${Cert_type_param}
    Run keyword If     '${Cert_type_param}'=='ECDSA'      Perform Recommissioning    type=delta    delta_file=CMP_ECDSA.xml    timeout=100
    ...     ELSE    Perform Recommissioning    type=delta    delta_file=CMP_RSA.xml    timeout=100
    Sleep    30
    Certificate Configure    operation=install_cmp_certificate    key_pool_type=${Cert_type_param}       timeout=600
    Sleep    30
    Verify Certificate status      ${Cert_type_param}


Verify Certificate status
    [Arguments]     ${Cert_type_param}
    ${CMP_Moc}=     Run keyword If     '${Cert_type_param}'=='ECDSA'     Query Admin Infomodel    query=get object //CMPECDSA_A-1
    ...     ELSE    Query Admin Infomodel      query=get object //CMP_A-1
    ${caSubjectName_param} =      Get From Dictionary         dictionary=${CMP_Moc}        key=caSubjectName
    Set Suite Variable      ${caSubjectName_param}        ${caSubjectName_param}
    ${serverType_param} =         Get From Dictionary         dictionary=${CMP_Moc}        key=serverType
    Set Suite Variable      ${serverType_parm}     ${serverType_param}
    ${Cert_details}=  Certificate Configure     operation=get_certificate_list        type=TA    timeout=120
    ${Cert_status} =    Set Variable    None
    ${Cert_no} =    Set Variable    0
    @{operator_certs} =     Create List
    FOR     ${Certificate}      IN       @{Cert_details}
            log     ${Certificate}
            ${vendor} =     Get From Dictionary     ${Certificate}   source
            ${Cert_Type} =     Get From Dictionary     ${Certificate}   keyPoolType
            ${cert_name} =      Get From Dictionary      ${Certificate}   issuedTo
            ${Result} =     Remove String       ${cert_name}      ${SPACE}
            ${Cert_no}=     Run Keyword If  '${vendor}' == 'Operator' and '${Cert_type_param}' == '${Cert_Type}'
            ...     and '${caSubjectName_param}' == '${Result}'   Evaluate    ${Cert_no}+1    ELSE    Evaluate    ${Cert_no}+0
            Set Suite Variable      ${Cert_no}      ${Cert_no}
    END
    Should contain     '${Cert_no}'     1




Configure IPsec
    Perform Recommissioning     type=delta       delta_file=${IPIF_IPRT_add_2_IPs}        skip_parameter_relation_errors=${True}      timeout=300
    Perform Recommissioning     type=delta       delta_file=${IPv4_IPv6_IPsec_conf}        skip_parameter_relation_errors=${True}      timeout=300
    Sleep   60
    ${SMOD_Details}=     Run keyword     Query Admin Infomodel    query=get object //SMOD_R-1
    ${SerialNumber_param} =         Get From Dictionary         dictionary=${SMOD_Details}        key=serialNumber
    ${Cert_Details}=    Certificate Configure    operation=get_certificate_details      type=EndEntity      source=Operator     timeout=600
    #${subjectAlternateName} =         Get From Dictionary         dictionary={${Cert_Details}}        key=subjectAlternateName
    #${subjectAlternateName} =         Get Dictionary Items         dictionary=${Cert_Details}




Verify DPD & IKE Authentication alarm and Tunnel status
    Run     sudo ipsec stop
    Sleep   45
    Verify DPD alarm    True
    Run     sudo cp /etc/ipsec.conf /etc/ipsec_backup.conf
    Run     sudo cp ${CURDIR}/resources/ipsec_IKE.conf /etc/ipsec.conf
    Run     sudo ipsec start --debug-all --nofork > Ipsec_status.txt &
    Sleep   30
    Verify IKE Authentication alarm     True
    Sleep   30
    Run     sudo cp ${CURDIR}/resources/ipsec_correct.conf /etc/ipsec.conf
    Run     sudo ipsec restart --debug-all --nofork > Ipsec_status.txt &
    Sleep   60
    Run Keyword And Ignore Error    Verify DPD alarm    False
    Run Keyword And Ignore Error    Verify IKE Authentication alarm     False
    Verify IPSEC Status     ESTABLISHED


Verify DPD alarm
    [Arguments]     ${State}
    Run Keyword If  '${State}' == 'True'   Verify Alarm    faultid=61030    should_exist=${State}      occurrences=4
    ...     ELSE    Verify Alarm    faultid=61030    should_exist=${${State}}

Verify IKE Authentication alarm
    [Arguments]     ${State}
    Run Keyword If  '${State}' == 'True'   Verify Alarm    faultid=61644    should_exist=${State}      occurrences=4
    ...     ELSE    Verify Alarm    faultid=61644    should_exist=${${State}}

Verify IPSEC Status
    [Arguments]     ${State}
    ${ikep_list} =  Query Admin Infomodel   query=get list //IKEP_R-1   timeout=30
    ${len} =    Get Length  ${ikep_list}
    FOR     ${item}     IN      @{ikep_list}
        ${IKEP_state} =  Get From Dictionary    ${item}     ikePeerState
        Should Be Equal     ${IKEP_state}     ${State}
    END