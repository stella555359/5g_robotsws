*** Settings ***
Documentation
    ...     [Procedure]             "IPSEC and top And Sync"
    ...     [Date]                  "18-06-24"
    ...     [Author]                "Madhuri Thokala"
    ...     [Commissioning_comment] "It checks ipsec and top&sync scenario"

#Force Tags    SM TRSIV Test 3    QCD_MN_5G    QCP_5G    CRT
variables      ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/Common_Top_sync.robot
Resource        ${CURDIR}/resources/Common_IPSEC_Operations.robot
Resource        ${CURDIR}/resources/Admin_Common_Library.robot
Suite Setup     Run Keywords    Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown  Run Keywords    Suite Teardown Postconditions
...     AND     Teardown Oamops

*** Test Cases ***
[1]Verification_of_Topf_IPsec_ON_OFF_mode_IPv6
#IPSEC OFF MODE ipsec disable
    Perform Commissioning       scf_file=${topf_ipv6}   verify_bts_status=true     timeout=400     alias=default
#    Perform Commissioning       scf_file=${topf_ipv6}  verify_bts_status=False     timeout=600
    sleep   900
    Get top info details    ${top_first_levele_key}   ${top_second_levele_key}    ${top_third_levele_key}    ${top_availability_status}
    Get top info details    ${top_first_levele_key}   ${top_second_levele_key}    ${top_third_levele_usable_key}    ${top_usability_status}
    Get GPS staus details       operationalState            enabled
    Get TimeSource Info     activeTimeSource        GnssExt
#ENABLE IPSEC
    Perform Commissioning       scf_file=${topf_ipsec_ipv6}  verify_bts_status=False     timeout=600
    sleep   900
    Get top info details    ${top_first_levele_key}   ${top_second_levele_key}    ${top_third_levele_key}    ${top_availability_status}
    Get top info details    ${top_first_levele_key}   ${top_second_levele_key}    ${top_third_levele_usable_key}    ${top_usability_status}
    Get GPS staus details       operationalState            enabled
#    Get Sync Info details       tuningMode    Normal tuning
    Get TimeSource Info     activeTimeSource        GnssExt
#UPGRADE will NOT WORK with LOCAL PASSWORD TRUE
    Perform Recommissioning        type=delta      delta_file=${Modify_TOPP6}       skip_parameter_relation_errors=${True}      timeout=700
    Sleep   900
    Reset Bts  req_rat=NR  should_be_onair=False/true
    sleep   900
    Get GPS staus details       operationalState            enabled
    Get TimeSource Info     activeTimeSource       GnssExt
    Perform Recommissioning        type=delta      delta_file=${UPDATE_TOPP6}       skip_parameter_relation_errors=${True}      timeout=700
    Sleep  900
    Reset Bts  req_rat=NR  should_be_onair=False/true
    sleep   900
    Get top info details    ${top_first_levele_key}   ${top_second_levele_key}    ${top_third_levele_key}    ${top_availability_status}
    Get top info details    ${top_first_levele_key}   ${top_second_levele_key}    ${top_third_levele_usable_key}    ${top_usability_status}
    Get GPS staus details       operationalState            enabled
#    Get Sync Info details       tuningMode    Normal tuning
    Get TimeSource Info     activeTimeSource        GnssExt

*** KeyWords ***
Verify Ipsec Tunnels Status
    [Arguments]    ${dut}=default
    @{parent_tunnel_moc_list} =    Query Admin Infomodel	query=get list ${ike_sa_l_moc_path}	alias=${dut}
    FOR    ${ike_tunnel}	IN      @{parent_tunnel_moc_list}
        ${parent_tunnel_stateInfo}=     Get From Dictionary	dictionary=${ike_tunnel}	key=stateInfo
     	${parent_tunnel_proceduralState}=    Get From Dictionary	dictionary=${parent_tunnel_stateInfo}	key=proceduralState
     	Should Be True	'${parent_tunnel_proceduralState}'=='Established'
    END

Verify NTP status
    [Arguments]    ${NTP}
    ${ntp_info} =       Query Admin Infomodel        query=get object //NTP_R-1
    ${output}=     Get From Dictionary     ${ntp_info}
    ${value}=     Get From Dictionary       ${output}       ntpServerStatusList
    ${ntp_status}=     Get From List      ${value}       0
    ${ntp_ip}=      Get From Dictionary     ${ntp_status}       ntpServerIpAddr
    Should Be Equal       ${ntp_ip}     ${NTP}
    ${ntp_status}=  Get From Dictionary     ${ntp_status}       ntpStatus
    Should Be Equal     ${ntp_status}       Available

Verify Bts Status   should_be_onair=${true}      req_rat=5g

Get Sync Info details
    [Arguments]    ${status}
    ${info}=    Get Sync Info
    ${info1}=    Get From Dictionary    ${info}  activeTimeSource
    ${info2}=    Get From List    ${info1}    0
    ${info3}=    Get From Dictionary    ${info2}    syncInputType
    Should Be Equal    ${info3}     TOPP
    ${info4}=    Get From Dictionary    ${info2}    isActive
    Should Be Equal As Strings    ${info4}     ${Status}
