*** Settings ***
Documentation
...     [Author]        "Vivin"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"


Resource        ${CURDIR}/../../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/../../resources/common_keywords.robot
Resource        ${CURDIR}/../../resources/Common_BFD.robot
Library			ute_fsmaccess
Library			Collections
Library			String
Library     	XML     lxml=True



*** Keywords ***
Get Ipsec Tunnels Status
    [Documentation]     This test case keyword is to verify IPSec tunnels status
    @{parent_tunnel_moc_list} =     Query Admin Infomodel       query=get list ${ike_sa_l_moc_path}
    FOR     ${ike_tunnel}       IN      @{parent_tunnel_moc_list}
        ${parent_tunnel_stateInfo}=     Get From Dictionary     dictionary=${ike_tunnel}        key=stateInfo
        ${parent_tunnel_proceduralState}=   Get From Dictionary     dictionary=${parent_tunnel_stateInfo}       key=proceduralState
        Should Be True  '${parent_tunnel_proceduralState}'=='Established'    timeout=800
    END

    @{child_tunnel_moc_list} =  Query Admin Infomodel       query=get list ${ipsec_sa_l_moc_path}
    FOR     ${child_tunnel}         IN      @{child_tunnel_moc_list}
        ${child_tunnel_stateInfo}=      Get From Dictionary     dictionary=${child_tunnel}      key=stateInfo
        ${child_tunnel_proceduralState}=    Get From Dictionary     dictionary=${child_tunnel_stateInfo}        key=proceduralState
        Should Be True  '${child_tunnel_proceduralState}'=='Installed'   timeout=800
    END


Verify ping test success of IPv4 address
    FOR     ${i}    IN RANGE    16   149
        ${output}=      Run     ping 10.0.${i}.2 -I 10.0.${i}.1 -c 2
        Should contain     ${output}        0% packet loss
    END


Verify ping test success of IPv6 address
    FOR     ${i}    IN RANGE    16   149
        ${output}=      Run     ping fc00::${i}:2 -I fc00::${i}:1 -c 2
        Should contain     ${output}        0% packet loss
    END


Verification of Egress Alarm raise and clear
    Block udp traffic of Egress BFD alarm
    Sleep    60
    VerifyEgressAlarm
    UnBlock udp traffic of Egress BFD alarm
    Sleep    10
    VerifyNoBFDAndBFDGRPAlarm


Verification of Ingress Alarm raise and clear
    Block udp traffic of Ingress BFD alarm
    Sleep    60
    VerifyIngressAlarm
    UnBlock udp traffic of Ingress BFD alarm
    Sleep    60
    VerifyNoBFDAndBFDGRPAlarm


Block udp traffic of Ingress BFD alarm
    FOR     ${i}        IN RANGE    16   24
        Run     sudo bfdd-control session local 10.0.${i}.1 remote 10.0.${i}.2 suspend
        Run     sudo bfdd-control session local fc00::${i}:1 remote fc00::${i}:2 suspend
    END


UnBlock udp traffic of Ingress BFD alarm
    FOR     ${i}        IN RANGE    16   24
        Run     sudo bfdd-control session local 10.0.${i}.1 remote 10.0.${i}.2 resume
        Run     sudo bfdd-control session local fc00::${i}:1 remote fc00::${i}:2 resume
    END


Block udp traffic of Egress BFD alarm
    FOR     ${i}        IN RANGE    16   24
        Run   sudo iptables -I INPUT -p udp --source-port 3784 -s 10.0.${i}.2 -j DROP
        Run   sudo ip6tables -I INPUT -p udp --source-port 3784 -s fc00::${i}:2 -j DROP
    END

UnBlock udp traffic of Egress BFD alarm
    FOR     ${i}        IN RANGE    16   24
        Run   sudo iptables -D INPUT -p udp --source-port 3784 -s 10.0.${i}.2 -j DROP
        Run   sudo ip6tables -D INPUT -p udp --source-port 3784 -s fc00::${i}:2 -j DROP
    END


VerifyIngressAlarm
    Verify Alarm    faultid=61605    occurrences=16    should_exist=True    alarm_type=active
    Verify Alarm    faultid=61022    occurrences=16    should_exist=True    alarm_type=active
    Verify Alarm    faultid=61606    should_exist=${False}

VerifyEgressAlarm
    Verify Alarm    faultid=61606    occurrences=16    should_exist=True    alarm_type=active
    Verify Alarm    faultid=61022    occurrences=16    should_exist=True    alarm_type=active
    Verify Alarm    faultid=61605    occurrences=${0}    should_exist=${False}


VerifyNoBFDAndBFDGRPAlarm
    Verify Alarm    faultid=61605    should_exist=${False}
    Verify Alarm    faultid=61022    should_exist=${False}
    Verify Alarm    faultid=61606    should_exist=${False}


Bring Down Primary Session
      Run     sudo bfdd-control session local ${primary_bfd_remote_ip} remote ${primary_bfd_source_ip} suspend
      sleep   5

Bring Up Primary Session
      Run     sudo bfdd-control session local ${primary_bfd_remote_ip} remote ${primary_bfd_source_ip} resume
      sleep   5


Start All BFD session on VM
    GetBFDCount
    Get_BFD_Src_IPs
    Run     sudo bfdd-beacon
    FOR    ${value}     IN RANGE     0   16
        Run    sudo bfdd-control connect local ${bfdDestIpAddr_list}[${value}] remote ${bfdSrcAddr_list}[${value}]
        Sleep       1
        Run     sudo bfdd-control session local ${bfdDestIpAddr_list}[${value}] remote ${bfdSrcAddr_list}[${value}] set mintx 1000 ms
        Sleep       1
        Run     sudo bfdd-control session local ${bfdDestIpAddr_list}[${value}] remote ${bfdSrcAddr_list}[${value}] set minrx 1000 ms
        Sleep       1
        Run     sudo bfdd-control session local ${bfdDestIpAddr_list}[${value}] remote ${bfdSrcAddr_list}[${value}] set multi 3
        Sleep       1
        Run     sudo bfdd-control status local ${bfdDestIpAddr_list}[${value}] remote ${bfdSrcAddr_list}[${value}] level 5
    END
    Sleep  30
    Verify Alarm    faultid=61605      should_exist=${False}

Restore all Certificate
    certificate configure    operation=restore_vendor_certificate
    Sleep       10
    certificate configure    operation=delete_cert    all_certs=${True}
    Sleep     150

Install Max CA/TA certs
    FOR     ${i}        IN RANGE    1   68
        Certificate Configure       operation=install_certificate       cert_file=${Cert_${i}}      cert_type=AdditionalCa      cert_format=PEM
        Sleep   20
    END

Configure and verify max crl
    Perform Recommissioning     type=delta      delta_file=${max_crl}       skip_parameter_relation_errors=${True}      timeout=300
    Sleep   400
    Certificate Configure       operation=get_certificate_revocation_list
    Sleep   100
    CRL Download success

CRL Download success
    Wait Until Keyword Succeeds    5 min    30      Verify Alarm        faultid=61074      should_exist=${False}