*** Settings ***
Documentation
...     [Author]        "Shweta Naikodi"
...     [Maintenance]   "TRS ET Bangalore Team"
...     [Procedure]     "Intermediate Node routing based solution for eCPRI M-Plane- SWN-IPV6"
...     [Date]          "15-07-2024"
...     [Feature_ID]    "CB006533"
...     [Requirement ID]    "OM_GEN_SFS_RNWINT.6751;TT_IPT.3039;TT_IPT.3034;OAM_REQ_TRSSEC_144;OAM_REQ_TRSSEC_141;OAM_REQ_TRSSEC_143"
...     [Config]    "This script requires basic SCF loading."
...     [RunTime Parameters]    "bts_id used is 6533"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"

variables       ta_e2e_bts_trs_fw
#Resource        ${CURDIR}/../CB006533_ASIM/resources/Common_6533keyword.robot
Resource        ${CURDIR}/../resources/common_keywords.robot


Suite Setup     Run Keywords        Suite Setup Preconditions        AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions       AND     Teardown Oamops


*** Test Cases ***
[1][1]CB006533_Q_ Verify BTS supports M-plane IP traffic routing between FH and BH with global IPv6 address configured INT node_eCPRI SWN case
     Perform Commissioning       scf_file=${FHNODE_SWN_scf}   verify_bts_status=${True}     timeout=350    alias=default
     Get IPS for intnodeswn
     check routes in smo and int node for swn
     SMO initiated traffic verification for swn
     intermediate node initiated traffic verification for swn
     SMO initiated SSH traffic verification for swn
     intermediate node initiated SSH traffic verification for swn
     bbmod reset
     SMO initiated SSH traffic verification after bbmod reset for swn
     intermediate node initiated SSH traffic verification after bbmod reset for swn
     [Teardown]  Reload BTS

***Keywords***
Get IPS for intnodeswn
    Setup Remote Access     remote_device=SMO
    ${SMO_IP}=   Remote Command Execute     command=${smo_ip}
    Teardown Remote Access
    Setup Remote Access     remote_device=int_E_node
    ${INT_E_IP}=   Remote Command Execute     command=${int_E_ip}
    Teardown Remote Access
    Set Suite Variable      ${SMO_IP}    ${SMO_IP}
    Set Suite Variable      ${INT_E_IP}   ${INT_E_IP}
    Rfmodule Setup      config_device=rf_module          fhnet_login_only=${True}  alias=fronthaul
    ${output}=   Execute Interactive Remote Command     command=${fh_ip}     alias=fronthaul
    ${FH_IP}=   Get Line    ${output}   -3
    Set Suite Variable  ${FH_IP}    ${FH_IP}
    Rfmodule Teardown   alias=fronthaul
    Setup Remote Access     remote_device=bts   alias=bts
    ${MPLANE_IP}=   Remote Command Execute     command=${mplane_E_ip}   alias=bts
    Set Suite Variable  ${MPLANE_IP}    ${MPLANE_IP}
    Teardown Remote Access  alias=bts
    Setup Remote Access     remote_device=bts   alias=bbmod
    Execute Interactive Remote Command     command=${bbmod_login_primary}   alias=bbmod
    Execute Interactive Remote Command  command=yes   alias=bbmod
    Execute Interactive Remote Command  command=${password1}  alias=bbmod
    ${output2}=    Execute Interactive Remote Command      command=${bbmod_E_ip}     alias=bbmod
    ${BBMOD_E_IP}=   Get Line    ${output2}   -2
    Teardown Remote Access  alias=bbmod
    Set Suite Variable  ${BBMOD_E_IP}     ${BBMOD_E_IP}


check routes in smo and int node for swn
    Setup Remote Access     remote_device=SMO
    ${routes}=   Remote Command Execute     command=${route_check}
    ${status}=  Run Keyword And Return Status   Should Contain  ${routes}   ${INT_E_IP} via ${MPLANE_IP} dev
    ...     ${smo_interface}
    Teardown Remote Access
    Run Keyword If      '${status}'=='False'   Run Keywords    Setup Remote Access     remote_device=SMO
    ...   AND   Remote Command Execute     command=ip route add ${INT_E_IP} via ${MPLANE_IP} dev ${smo_interface}
    ...   AND   Teardown Remote Access
    Setup Remote Access     remote_device=int_E_node
    ${routes1}=   Remote Command Execute     command=${route_check}
    ${status1}=  Run Keyword And Return Status   Should Contain  ${routes1}   ${SMO_IP} via ${BBMOD_E_IP} dev
    ...     ${intnode_E_interface}
    Teardown Remote Access
    Run Keyword If      '${status1}'=='False'   Run Keywords    Setup Remote Access     remote_device=int_E_node  alias=intnode
    ...   AND   Remote Command Execute     command=ip route del ${SMO_IP}  alias=intnode
    ...   AND   Remote Command Execute     command=ip route add ${SMO_IP} via ${BBMOD_E_IP} dev ${intnode_E_interface}  alias=intnode
    ...   AND   Teardown Remote Access  alias=intnode
    Setup Remote Access     remote_device=int_E_node  alias=fh
    ${routes2}=   Remote Command Execute     command=${route_check}  alias=fh
    ${status2}=  Run Keyword And Return Status   Should Contain  ${routes2}   ${FH_IP} via ${BBMOD_E_IP} dev
    ...     ${intnode_E_interface}
    Teardown Remote Access  alias=fh
    Run Keyword If      '${status1}'=='False'   Run Keywords    Setup Remote Access     remote_device=int_E_node  alias=fh
    ...   AND   Remote Command Execute     command=ip route del ${FH_IP}  alias=fh
    ...   AND   Remote Command Execute     command=ip route add ${FH_IP} via ${BBMOD_E_IP} dev ${intnode_E_interface}  alias=fh
    ...   AND   Teardown Remote Access  alias=fh


SMO initiated traffic verification for swn
     Traffic capture start    capture_device=int_ens4f0_400     alias=default
     Traffic Setup           device=SMO
     Run Keyword And Continue On Failure    Traffic Start   profile=smo_initiated_splitE
     ${filename}=  Traffic Capture Stop    capture_device=int_ens4f0_400    alias=default
     Analyse Pcap        pcap_filename=${filename}        analysis=splitE_smo_initiated
     Traffic Teardown   alias=default

intermediate node initiated traffic verification for swn
    Traffic capture start    capture_device=SMO_enp6s0f0
    Traffic Setup           device=intnode_ens4f0_400
    Run Keyword And Continue On Failure    Traffic Start   profile=int_initiated_splitE
    ${filename}=  Traffic Capture Stop    capture_device=SMO_enp6s0f0
    Analyse Pcap        pcap_filename=${filename}        analysis=splitE_int_initiated
    Traffic Teardown   alias=default

SMO initiated SSH traffic verification for swn
    Traffic capture start      capture_device=int_ens4f0_400     alias=default
    Setup Remote Access     remote_device=SMO
    Remote Command Execute  command=ssh ${INT_E_IP}
    ${filename}=  Traffic Capture Stop    capture_device=int_ens4f0_400    alias=default
    Analyse Pcap        pcap_filename=${filename}        analysis=splitE_smo_init_ssh

intermediate node initiated SSH traffic verification for swn
    Traffic capture start    capture_device=SMO_enp6s0f0     alias=int
    Setup Remote Access     remote_device=int_E_node      alias=int
    FOR    ${i}   IN RANGE  1   5
        Remote Command Execute  command=ssh ${SMO_IP}   alias=int
    END
    ${filename}=  Traffic Capture Stop    capture_device=SMO_enp6s0f0   alias=int
    Analyse Pcap        pcap_filename=${filename}        analysis=splitE_int_init_ssh   alias=int

bbmod reset
     Reset   operation=reset_unit  dist_name=${BBMOD-5}    reset_type=warm      timeout=300    verify_bts=${False}
    Sleep       120


SMO initiated SSH traffic verification after bbmod reset for swn
    Traffic capture start    capture_device=int_ens4f0_400     alias=default1
    Setup Remote Access     remote_device=SMO
    Remote Command Execute  command=ssh ${INT_E_IP}
    ${filename}=  Traffic Capture Stop    capture_device=int_ens4f0_400    alias=default1
    Analyse Pcap        pcap_filename=${filename}        analysis=splitE_smo_init_ssh

intermediate node initiated SSH traffic verification after bbmod reset for swn
    Traffic capture start    capture_device=SMO_enp6s0f0     alias=int1
    Setup Remote Access     remote_device=intnode_ens4f0_400      alias=int1
    FOR    ${i}   IN RANGE  1   5
        Remote Command Execute  command=ssh ${SMO_IP}   alias=int1
    END
    ${filename}=  Traffic Capture Stop    capture_device=SMO_enp6s0f0   alias=int1
    Analyse Pcap        pcap_filename=${filename}        analysis=splitE_int_init_ssh   alias=int1

Reload BTS
    Sleep    10
    Run Keyword And Ignore Error       Perform Recommissioning    type=delta    delta_file=${DisableFLAG}
    ...     timeout=200

