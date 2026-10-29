***Settings ***

Documentation
     ...    [QC_ID] "QC_ID in Test Lab for reporting"
     ...    [Funtion_Hash_Tags] "IPSEC"
     ...    [Feature_ID] "RP001974"
     ...    [Validation_status] "Validated and Passed"
     ...    [Author]           "Dineshkumar"

Resource        ${CURDIR}/resources/5G000267_common_keywords.robot
Library        taf.sw.scout    WITH NAME   scout

Suite Setup		Pre-conditions for testsuite
Suite Teardown  	Post-conditions for testteardown

*** Variables ***
${IKEP_1}       172.16.210.201
${IKEP_2}       172.16.100.165

***Test Cases***
[1.0] [1]RP001974_FQDN_resolving_with_the_primary_Backup_Tunnel_with_switching_back_Auto_manual_mode

    Perform Commissioning       scf_file=${1974_scf}   verify_bts_status=False
     ...      timeout=400     alias=default     skip_parameter_relation_errors=${True}
    Sleep   400
    Install Certificate
    Verify Bts Status	should_be_onair=${True}		req_rat=lte
    Verify Backup Ipsec in Manual mode
    Verify Backup Ipsec in Auto mode

***Keywords***
Verify Backup Ipsec in Auto mode
    Traffic Capture Start  capture_device=oam_device   mode=file   measurement_point=NE_Terminated
    ...     uplane_capturing=True   timeout=120
    Perform Recommissioning     type=param      param_path=${IKEP1_RTEP_path}  operation=update
    ...     value=${IKEP1_wrong_FQDN_value}	skip_parameter_relation_errors=${True}
   Sleep   60
    Verify Alarm        faultid=61654       occurrences=1     timeout=100
    Sleep     60
    Verify Alarm        faultid=61643       occurrences=1     timeout=100
    Sleep      60
    Verify Secondary tunnel status
    Verify BU_State     SECONDARY_ACTIVE_NO_PROBING_PRIMARY
    Verify Bts Status   should_be_onair=${True}     req_rat=lte
    ${Secondary_auto}=   Traffic Capture Stop   mode=file    timeout=350
    Analyse Pcap    pcap_filename=${Secondary_auto}   analysis=dns_secondary_tunnel
    Analyse Pcap    pcap_filename=${Secondary_auto}   analysis=dns_secondary_switchover
    Traffic Capture Start  capture_device=oam_device   mode=file   measurement_point=NE_Terminated
    ...     uplane_capturing=True   timeout=120
    Perform Recommissioning    type=delta      delta_file=${delta_automode}      skip_parameter_relation_errors=${True}
    Sleep   10
    Perform Recommissioning     type=param      param_path=${IKEP1_RTEP_path}  operation=update
    ...     value=${IKEP1_correct_FQDN_value}    skip_parameter_relation_errors=${True}
    Sleep   60
    Verify Primary tunnel status
    Verify BU_State    PRIMARY_ACTIVE
    Verify Bts Status   should_be_onair=${True}     req_rat=lte
    ${Primary_auto}=   Traffic Capture Stop   mode=file    timeout=350
    Analyse Pcap    pcap_filename=${Primary_auto}   analysis=dns_primary_tunnel
    Analyse Pcap    pcap_filename=${Primary_auto}   analysis=dns_primary_switchover

Verify Backup Ipsec in Manual mode
    Traffic Capture Start  capture_device=oam_device   mode=file   measurement_point=NE_Terminated
    ...     uplane_capturing=True   timeout=120
    Verify Primary tunnel status
    Verify BU_State    PRIMARY_ACTIVE
    Perform Recommissioning     type=param      param_path=${IKEP1_RTEP_path}  operation=update
    ...     value=${IKEP1_wrong_FQDN_value} skip_parameter_relation_errors=${True}
    Sleep   60
    Verify Alarm        faultid=61654       occurrences=1     timeout=100
    Sleep     60
    Verify Alarm        faultid=61643       occurrences=1     timeout=100
    Sleep      120
    Verify Secondary tunnel status
    Verify BU_State    SECONDARY_ACTIVE_PROBING_PRIMARY
    Verify Bts Status   should_be_onair=${True}     req_rat=lte
    ${Secondary_manual}=   Traffic Capture Stop   mode=file    timeout=350
    Analyse Pcap    pcap_filename=${Secondary_manual}   analysis=dns_secondary_tunnel
    Analyse Pcap    pcap_filename=${Secondary_manual}   analysis=dns_secondary_switchover
    Traffic Capture Start  capture_device=oam_device   mode=file   measurement_point=NE_Terminated
    ...     uplane_capturing=True   timeout=120
    Perform Recommissioning     type=param   param_path=IKEPROTGRP-1:switchBackMode     operation=update    value=MANUAL
    Sleep   10
    Perform Recommissioning     type=param      param_path=${IKEP1_RTEP_path}  operation=update
    ...     value=${IKEP1_correct_FQDN_value}       skip_parameter_relation_errors=${True}
    Sleep   60
    Verify failure Primary tunnel status
    Perform Recommissioning    type=delta      delta_file=${delta_switchrequest}      skip_parameter_relation_errors=${True}
    Sleep   120
    Verify Primary tunnel status
    Verify BU_State    PRIMARY_ACTIVE
    Verify Bts Status   should_be_onair=${True}     req_rat=lte
    ${Primary_manual}=   Traffic Capture Stop   mode=file    timeout=350
    Analyse Pcap    pcap_filename=${Primary_manual}   analysis=dns_primary_tunnel
    Analyse Pcap    pcap_filename=${Primary_manual}   analysis=dns_primary_switchover

Verify Primary tunnel status
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_1}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED
    ${remoteTunnelEndpointFQDN}=    Get From Dictionary     dictionary=${dict}      key=remoteTunnelEndpointFQDN
    Should Be Equal As Strings      ${remoteTunnelEndpointFQDN}     bkp1.marvels.com

Verify Secondary tunnel status
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_2}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED
    ${remoteTunnelEndpointFQDN}=    Get From Dictionary     dictionary=${dict}      key=remoteTunnelEndpointFQDN
    Should Be Equal As Strings      ${remoteTunnelEndpointFQDN}     bkp2.marvels.com

Verify failure Primary tunnel status
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointFQDN=bkp1.marvels.com]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     CONNECTING
    ${remoteTunnelEndpointFQDN}=    Get From Dictionary     dictionary=${dict}      key=remoteTunnelEndpointFQDN
    Should Be Equal As Strings      ${remoteTunnelEndpointFQDN}     bkp1.marvels.com

Install Certificate
    Certificate Configure    operation=restore_vendor_certificate
    Sleep   60
    Certificate Configure   operation=install_certificate   cert_file=${Cert_file}    cert_type=BtsTrustChain
    ...     cert_format=P12     password=${Cert_password}
    Sleep   30