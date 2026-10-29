*** Settings ***

Documentation
...	    [Procedure]	           "NCDR Test Execution"
... 	[Date]		           "27-03-2024"
...	    [Author]	           "Malika"
...     [Scrum]                "TRS VRF-2"
...     [Config_Comments]      "IPSEC should be established"
...     [Precondition]         "ENodeB should be integrated to Netact"


Resource          ${CURDIR}/../resources/Common_IPSEC_Operations.robot
Resource          ${CURDIR}/../resources/common_keywords.robot


Suite Setup             Run Keywords    Suite Setup Preconditions
...             AND             Setup Oamops
Suite Teardown     Run Keywords         Suite Teardown Postconditions
...             AND             Teardown Oamops

*** Variables ***
${profile3}       SBTS25R2_ENB_0000_000606_000000_release_BTSSM_downloadable_A54.zip

*** Test Cases ***
[1][1.0] ASIB_ASIA_Static_and_Dynamic_IPSEC_NCDR
    Precondition-1
    Installation_of_VSR_Cert
    Verify Ipsec Tunnels Status
    Multiple Modification of IPSECP encryptionMethod and verify IKE authentication failure alarm
    Verify DPD and IKE Auth Alarm should not exist
    Multiple Ikep modification
    Verify DPD and IKE Auth Alarm should not exist
    Multiple secpol deletion and addition
    Verify DPD and IKE Auth Alarm should not exist
    Verify Ipsec Tunnels Status
    Enable FH IPSEC
    Verify FH IPSEC status
    Verify Ipsec Tunnels Status
    send traffic through scapy
    Make UE call
    Verify IPSEC PM counters
    Install 4k certificate
    Restore Vendor Certificates
    Installation_of_VSR_Cert
    Verify Ipsec Tunnels Status
    Add concurrent IPSEC
    Verify Ipsec Tunnels Status
    Verify IKE SA failure Alarm should not exist
    Verify DPD and IKE Auth Alarm should not exist
    Install Additional CA Certificate
    verify Unexpected alarms should not exist
    Verify Ipsec Tunnels Status
    verify coredumbs
    [Teardown]  Teardown Ems  config_device=netact2005  alias=lab2005

*** Keywords ***

Precondition-1
     perform software upgrade to 25R2 Release       ${profile3}
     Setup Oamops   bts_host=${mplane_ip}   alias=initial_mplane
     Perform Commissioning       scf_file=${SBTS25R1-release-scfc}       verify_bts_status=True        timeout=1200            alias=initial_mplane
     ...     wait_for_bts_to_be_ready=300
     Setup Ems  config_device=netact2005   alias=lab2005
     Cm Upload   config_device=netact2005   alias=lab2005
     verify Unexpected alarms should not exist
     BuiltIn.Sleep  100

Install Additional CA Certificate
    Setup Oamops   bts_host=${mplane_ip}   alias=initial_mplane
    Perform Commissioning       scf_file=${Add_cert}       verify_bts_status=True        timeout=1200            alias=initial_mplane
    Certificate Configure      operation=restore_vendor_certificate       alias=default
    Run Keyword And Ignore Error     certificate configure        operation=delete_cert       all_certs=${True}
    Certificate Configure     operation=install_cmp_certificate       timeout=120
    Certificate Configure     operation=install_certificate     cert_file=${Additional_cert}   cert_type=AdditionalCa     cert_format=PEM
    BuiltIn.Sleep  30
    verify Unexpected alarms should not exist
    Verify DPD and IKE Auth Alarm should not exist

Installation_of_VSR_Cert
    Certificate Configure    operation=install_certificate    cert_file=${cert}    cert_type=BtsTrustChain     cert_format=P12     password=${Pwd}
    BuiltIn.Sleep   60

Activate Dynamic ipsec config
    Perform Commissioning       scf_file=${Dynamic_ipsec_SCF}     verify_bts_status=True        timeout=900      alias=default
    BuiltIn.Sleep   400
    verify Unexpected alarms should not exist

Change ikeEncryptionMethod
    Perform Recommissioning     type=delta      delta_file=${ikep_delta_mod}        skip_parameter_relation_errors=True     timeout=300

Verify IKE SA failure Alarm should exist
    Verify Alarm      fault_id=${IKE_sa_failure}      should_exist=${True}

Verify DPD and IKE Auth Alarm should not exist
    Verify Alarm      fault_id=${DPD}      should_exist=${False}
    Verify Alarm      fault_id=${IKE_authentication_failure}      should_exist=${False}

perform software upgrade to 25R2 Release
    [Arguments]    ${profile3}
    ${Build_name}=       Run     /home/ute/Downloads/${profile3} | awk 'END{print}' | awk '{print $9}'
    Perform Software Download And Update      package=/home/ute/Downloads/${profile3}      activate_sw=true      update_timeout=4200
    ...     wait_for_bts_to_be_ready=500
    Verify Alarm    faultid=6450        should_exist=${False}
    BuiltIn.Sleep   240

verify Unexpected alarms should not exist
    Verify Alarm    unexpected_alarm=${unexpected_alarm}        should_exist=${False}

Revert ikeEncryptionMethod
    Perform Recommissioning     type=delta      delta_file=${RevertikepModification}        skip_parameter_relation_errors=True     timeout=600
    verify Unexpected alarms should not exist

Verify IKE SA failure Alarm should not exist
    Verify Alarm      fault_id=${IKE_sa_failure}      should_exist=${False}

Enable Ransharing flag
    Perform Recommissioning     type=delta      delta_file=${Ransharing}        skip_parameter_relation_errors=True     timeout=300
    verify Unexpected alarms should not exist

Enable FH IPSEC
    Perform Recommissioning     type=delta      delta_file=${FHIPSEC}        skip_parameter_relation_errors=True     timeout=300
    BuiltIn.Sleep   400
    verify Unexpected alarms should not exist

Add concurrent IPSEC
    Perform Recommissioning     type=delta      delta_file=${concurrent}        skip_parameter_relation_errors=True     timeout=300
    BuiltIn.Sleep   60
    verify Unexpected alarms should not exist

Verify FH IPSEC status
    Setup Remote Access   remote_device=bts     alias=session
    ${stdout_1}          Execute Interactive Remote Command    command=lxc-attach -n 0x3018   alias=session
     ${stdout_2}          Execute Interactive Remote Command    command=ipsec status   alias=session
    Should contain       ${stdout_2}    Security Associations (1 up, 0 connecting)
    [Teardown]     Teardown remote Access         alias=session

Make UE call
    Make 5g Call
    Make LTE Call
    Make WCDMA Call
    Make GSM Call

Make 5g Call
    Call Setup    5g=device_1:data  verify_attach=${False}
    Call Start    5g=device_1:data  profile=udp_10K_dl  iperf_section=device1
    BuiltIn.Sleep    240
    Call Stop     5g=device_1:data  profile=udp_10K_dl  iperf_section=device1
    Call Teardown    5g=device_1:data

Make LTE Call
    Call Setup    lte=device_1:data  verify_attach=${False}
    Call Start    lte=device_1:data  profile=udp_10K_dl  iperf_section=device1
    BuiltIn.Sleep    240
    Call Stop     lte=device_1:data  profile=udp_10K_dl  iperf_section=device1
    Call Teardown    lte=device_1:data

Make GSM Call
    Call Setup    gsm=device_1:data  verify_attach=${False}
    Call Start    gsm=device_1:data  profile=udp_10K_dl  iperf_section=device1
    BuiltIn.Sleep    240
    Call Stop     gsm=device_1:data  profile=udp_10K_dl  iperf_section=device1
    Call Teardown    gsm=device_1:data

Make WCDMA Call
    Call Setup    wcdma=device_1:data  verify_attach=${False}
    Call Start    wcdma=device_1:data  profile=udp_10K_dl  iperf_section=device1
    BuiltIn.Sleep    240
    Call Stop     wcdma=device_1:data  profile=udp_10K_dl  iperf_section=device1
    Call Teardown    wcdma=device_1:data

send traffic through scapy
  Run   sudo expect /home/ute/scapy/gtp.exp 10.58.141.148 10.58.213.45 2152 2152 GTP

Install 4k certificate
    Perform Recommissioning     type=delta      delta_file=${cmp_4k_cert}        skip_parameter_relation_errors=True     timeout=900
    Verify Alarm    faultid=6450        should_exist=${False}

Verify CMP Instalize Certificate
    Certificate Configure     operation=install_cmp_certificate       timeout=300

Restore Vendor Certificates
    Certificate Configure      operation=restore_vendor_certificate       alias=default     timeout=60
    Verify Alarm    faultid=6450        should_exist=${False}

Site reset and check BTS status
        Reset_Bts    verify_bts_status=${True}     should_be_onair=${True}
        BuiltIn.Sleep   60
        Verify Bts Status   should_be_onair={True}     wait_for=60     timeout=60      alias=default
        Verify Alarm    faultid=6450        should_exist=${False}

verify Ransharing flags should be true
   ${actRanSharing_value}    Get Parameter   param_path=MRBTS-3611/NRBTS-3611:actRanSharing
    Should Be True    ${actRanSharing_value}
    ${actTrsSepaNSARanSharing_value}    Get Parameter   param_path=MRBTS-3611/NRBTS-3611:actTrsSepaNSARanSharing
    Should Be True    ${actTrsSepaNSARanSharing_value}
    ${actTrsSepaSARanSharing_value}    Get Parameter   param_path=MRBTS-3611/NRBTS-3611:actTrsSepaSARanSharing
    Should Be True    ${actTrsSepaSARanSharing_value}

Verify IPSEC PM counters
    PM Counters Start       analysis=verify_ipsec_counters      counter_analysis_file=${ipsec_counter}
    Verify Pm Counters      analysis=verify_ipsec_counters     counter_analysis_file=${ipsec_counter}
    PM Counters Start       analysis=verify_secpol_counters      counter_analysis_file=${secpol_counter}
   Verify Pm Counters      analysis=verify_secpol_counters     counter_analysis_file=${secpol_counter}

Muliple site reset
       FOR   ${i}   IN RANGE   4
            Reset_Bts    verify_bts=${False}      timeout=1200
            BuiltIn.Sleep   200
            verify Unexpected alarms should not exist
       END

verify coredumbs
    Setup Remote Access   remote_device=bts     alias=session
    ${stdout_1}          Execute Interactive Remote Command    command=cd /ffs/run/logs/ccsdumps/0/A/dumps/   alias=session
    Should not contain       ${stdout_1}    node_0x1011

Multiple Ikep modification
    FOR     ${i}    IN RANGE    5
        Change ikeEncryptionMethod
        verify coredumbs
        Verify IKE authentication failure Alarm should exist
        verify Unexpected alarms should not exist
        Revert ikeEncryptionMethod
        verify coredumbs
        Verify IKE authentication failure Alarm should not exist
        verify Unexpected alarms should not exist
    END

Multiple secpol deletion and addition
    FOR     ${i}    IN RANGE    5
    Perform Recommissioning     type=delta      delta_file=${Secpol_deletion}        skip_parameter_relation_errors=True     timeout=900
    verify coredumbs
    BuiltIn.Sleep   30
    verify Unexpected alarms should not exist
    Perform Recommissioning     type=delta      delta_file=${Secpol_Addition}        skip_parameter_relation_errors=True     timeout=900
    verify coredumbs
    verify Unexpected alarms should not exist
    END

Verify IKE authentication failure Alarm should exist
    Verify Alarm      fault_id=${IKE_authentication_failure}      should_exist=${True}

Verify IKE authentication failure Alarm should not exist
    Verify Alarm      fault_id=${IKE_authentication_failure}      should_exist=${False}


Multiple Modification of IPSECP encryptionMethod and verify IKE authentication failure alarm
    FOR     ${i}    IN RANGE    5
    Perform Recommissioning     type=delta      delta_file=${ipseccmodi}        skip_parameter_relation_errors=True     timeout=900
    BuiltIn.Sleep   30
    verify coredumbs
    verify Unexpected alarms should not exist
    Verify IKE authentication failure Alarm should exist
    Perform Recommissioning     type=delta      delta_file=${revertipseccmoc}        skip_parameter_relation_errors=True     timeout=900
    verify coredumbs
    verify Unexpected alarms should not exist
    Verify IKE authentication failure Alarm should not exist
    END
