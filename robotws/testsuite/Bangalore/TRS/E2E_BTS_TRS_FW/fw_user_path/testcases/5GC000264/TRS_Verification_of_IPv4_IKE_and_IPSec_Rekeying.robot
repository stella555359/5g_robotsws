*** Settings ***
Documentation
    ...     [Procedure]             "The test case is planned to validate 5G IPSec IPv4 IKE and IPSec Rekeying"
    ...     [Date]                  "28-07-17"
    ...     [Author]                "Shweta"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Funtion_Hash_Tags]     "IPSEC IPv4 IKE IPSec Rekeying"
    ...     [Feature_ID]            "5GC000392"
    ...     [Validation_status]     "Validated and Passed"
    ...     [Validated_TestLine]    "TL-420"
    ...     [Requirement ID]    "TT_TTSEC.896,TT_TTSEC.897,TT_TTSEC.644,TT_TTSEC.699,TT_TTSEC.654,TT_TTSEC.907"
    ...     [Scfc File]    "Configuration_scf_MRBTS-420_ASOD_TL65_20201105-1221_IP_certificate_modi_20201117-0605.xml"
    ...     [Config]    "This script requires IPV4 IPSec with single ipsecp configuration"
    ...     [RunTime Parameters]    "[bts_id]"


variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Common_IPSEC_Operations.robot

Suite Setup     Run Keywords        Suite Setup Preconditions        AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions       AND     Teardown Oamops


*** Test Cases ***
[1][1.0] TRS_5GC000264_Verification_of_IPv4_IKE_and_IPSec_Rekeying
      Certificate Configure    operation=install_certificate    cert_file=${IP_BTSCertp12}    cert_type=BtsTrustChain
      ...     cert_format=P12     password=${IP_BTSCertpass}

      Perform Commissioning       scf_file=${IPSec_commisioning}      verify_bts_status=False      timeout=400
      ...    alias=default
      Get Ipsec Tunnels Status
      Perform Recommissioning     type=param     param_path=${SaMaxTime_moc_path}     operation=update
      ...     value=300     timeout=120
      Execute command on gNB
      ...     ipsec statusall | grep "conn${default_policy}" | tail -3 | head -1 | awk '{ print $8 }''{ print $9 }'
      Set Suite Variable     ${Key_value}       ${stdout}
      BuiltIn.Sleep       100
      Execute command on gNB
      ...     ipsec statusall | grep "conn${default_policy}" | tail -3 | head -1 | awk '{ print $8 }''{ print $9 }'
      Set Suite Variable     ${Key_value_new}       ${stdout}
      Should Be Equal     ${Key_value}            ${Key_value_new}
      BuiltIn.Sleep       180
      Execute command on gNB
      ...     ipsec statusall | grep "conn${default_policy}" | tail -3 | head -1 | awk '{ print $8 }''{ print $9 }'
      Set Suite Variable     ${Key_value_new1}       ${stdout}
      Should Not Be Equal     ${Key_value}            ${Key_value_new1}
      Log to Console    Started Execution
      Ipsec Get Conf Parameter    ike    all    target


***keywords***
Get Ipsec Status
    [Arguments]    ${dut}=default
    @{parent_tunnel_moc_list} =    Query Admin Infomodel    query=get list ${ike_sa_l_moc_path} alias=${dut}
    FOR    ${ike_tunnel}    IN      @{parent_tunnel_moc_list}
        ${parent_tunnel_stateInfo}=     Get From Dictionary dictionary=${ike_tunnel}    key=stateInfo
        ${parent_tunnel_proceduralState}=    Get From Dictionary    dictionary=${parent_tunnel_stateInfo}   key=proceduralState
        Should Be True  '${parent_tunnel_proceduralState}'=='Established'
    END
    @{child_tunnel_moc_list} =      Query Admin Infomodel   query=get list ${ipsec_sa_l_moc_path}   alias=${dut}
    FOR    ${child_tunnel}    IN       @{child_tunnel_moc_list}
        ${child_tunnel_stateInfo}=      Get From Dictionary dictionary=${child_tunnel}  key=stateInfo
        ${child_tunnel_proceduralState}=        Get From Dictionary dictionary=${child_tunnel_stateInfo}    key=proceduralState
        Should Be True  '${child_tunnel_proceduralState}'=='Installed'
    END

Command to execute on board
        [Arguments]      ${command}
        Remote Command Execute      command=${command}
