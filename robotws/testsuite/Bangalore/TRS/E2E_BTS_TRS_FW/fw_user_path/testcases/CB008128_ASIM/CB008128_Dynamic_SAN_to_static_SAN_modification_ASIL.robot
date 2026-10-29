***Settings ***
Documentation
    ...     [Procedure]             "verify online modifcation of c and s1u plane"
    ...     [Date]                  "29-01-24"
    ...     [Author]                "Adarsh H N"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Feature_ID]            "CB008128"
    ...     [Validation_status]     "Validated and Passed"
    ...     [Validated_TestLine]    "CLOUD_5G_I_MO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD"

Force Tags 				CA_E2ET_BTSTRSPZ        SBTS00       SBTS26R1       QCD_MN_RAN        QCP_RAN_VRF        CRT

Resource        ${CURDIR}/../resources/common_keywords.robot

Suite Setup     Pre-conditions for testsuite
Suite Teardown     Post-conditions for testteardown
#Suite Setup         Setup Oamops
#Suite Teardown     Teardown Oamops




*** Test Cases ***
[1][1.0] CB008128 The Purpose of this testcase is to configure Dynamic SAN and then change to static SAN and verify BTS sanity and viceversa

    Certificate Configure     operation=restore_vendor_certificate
    Perform Recommissioning     type=delta       delta_file=${CB008128_delta_Config_IPv4}        skip_parameter_relation_errors=${True}
    ...     timeout=300
    Sleep   60
    Configure CMP moc and install certificate and with static SAN
    Verify DPD & IKE Authentication alarm and Tunnel status     static
    Sleep   60
    Certificate Configure     operation=restore_vendor_certificate
    Configure CMP moc and install certificate and with dynamic SAN
    Verify DPD & IKE Authentication alarm and Tunnel status     dynamic
    Sleep   60
    Certificate Configure     operation=restore_vendor_certificate
    Configure CMP moc and install certificate and with static SAN
    Verify DPD & IKE Authentication alarm and Tunnel status     static



***Keywords***

Configure CMP moc and install certificate and with static SAN
    Perform Recommissioning    type=delta   type=delta    delta_file=CMP_RSA_static.xml    timeout=100
    Sleep    30
    Certificate Configure    operation=install_cmp_certificate    key_pool_type=RSA       timeout=600
    Sleep    30

Configure CMP moc and install certificate and with dynamic SAN
    Perform Recommissioning    type=delta   type=delta    delta_file=CMP_RSA_dynamic.xml    timeout=100
    Sleep    30
    Certificate Configure    operation=install_cmp_certificate    key_pool_type=RSA       timeout=600
    Sleep    30

Verify DPD & IKE Authentication alarm and Tunnel status
    [Arguments]     ${State}
    Run     sudo ipsec stop
    Sleep   45
    Verify DPD alarm    True
    Run     sudo cp /etc/ipsec.conf /etc/ipsec_backup.conf
    Run     sudo cp ${CURDIR}/resources/ipsec_IKE.conf /etc/ipsec.conf
    Run     sudo ipsec start --debug-all --nofork > Ipsec_status.txt &
    Sleep   30
    Verify IKE Authentication alarm     True
    Sleep   30
    Run     sudo cp ${CURDIR}/resources/ipsec_${State}_correct.conf /etc/ipsec.conf
    Run     sudo ipsec restart --debug-all --nofork > Ipsec_status.txt &
    Sleep   60
    Verify DPD alarm    False
    Verify IKE Authentication alarm     False
    Verify Ipsec Tunnels Status

Verify DPD alarm
    [Arguments]     ${State}
    Run Keyword If  '${State}' == 'True'   Verify Alarm    faultid=61030    should_exist=${State}      occurrences=8
    ...     ELSE    Verify Alarm    faultid=61030    should_exist=${${State}}

Verify IKE Authentication alarm
    [Arguments]     ${State}
    Run Keyword If  '${State}' == 'True'   Verify Alarm    faultid=61644    should_exist=${State}      occurrences=8
    ...     ELSE    Verify Alarm    faultid=61644    should_exist=${${State}}

Verify IPSEC Status
    [Arguments]     ${State}
    ${ikep_list} =  Query Admin Infomodel   query=get list //IKEP_R-1   timeout=30
    ${len} =    Get Length  ${ikep_list}
    FOR     ${item}     IN      @{ikep_list}
        ${IKEP_state} =  Get From Dictionary    ${item}     ikePeerState
        Should Be Equal     ${IKEP_state}     ${State}
    END


IPSEC Configuration for Strongswan
	Run			sudo cp /etc/ipsec.conf /etc/ipsec_bkup.conf
	Run			sudo cp ${IPSEC_plain_conf} /etc/ipsec.conf
	Run 		sudo ipsec restart
	sleep		120

IPSEC Configuration for Strongswan Down
	Run 		sudo ipsec stop
	sleep		120

IPSEC Configuration for Strongswan Up
	Run 		sudo ipsec restart
	sleep		120


Verify Ipsec Tunnels Status
        @{parent_tunnel_moc_list} =     Query Admin Infomodel           query=get list ${ike_sa_l_moc_path}
        FOR    ${ike_tunnel}   IN      @{parent_tunnel_moc_list}
               ${parent_tunnel_stateInfo}=     Get From Dictionary             dictionary=${ike_tunnel}
        ...         key=stateInfo
               ${parent_tunnel_proceduralState}=       Get From Dictionary
        ...         dictionary=${parent_tunnel_stateInfo}           key=proceduralState
               Should Be True  '${parent_tunnel_proceduralState}'=='Established'
        END

        @{child_tunnel_moc_list} =      Query Admin Infomodel           query=get list ${ipsec_sa_l_moc_path}
        FOR    ${child_tunnel}     IN      @{child_tunnel_moc_list}
               ${child_tunnel_stateInfo}=      Get From Dictionary             dictionary=${child_tunnel}
        ...         key=stateInfo
               ${child_tunnel_proceduralState}=        Get From Dictionary
        ...         dictionary=${child_tunnel_stateInfo}            key=proceduralState
               Should Be True  '${child_tunnel_proceduralState}'=='Installed'
        END

