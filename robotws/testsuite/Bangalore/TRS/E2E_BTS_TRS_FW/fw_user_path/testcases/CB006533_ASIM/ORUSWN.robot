*** Settings ***
Documentation
...     [Author]        "Shweta naikodi"
...     [Maintenance]   "TRS ET Bangalore Team"
...     [Procedure]     "The test case is planned to verify ssh from oru to smo and visa versa"
...     [Date]          "10-01-2022"
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
[1] CB006533 based solution for Dual Core configuration to reach O-RU SWN
     Perform Commissioning       scf_file=${oruswn_scf}   verify_bts_status=${True}     timeout=350     alias=default
     GET IPS3
     check routes in smo for O-RU SWN
     SMO initiated traffic verification on ORU
     ORU initiated traffic verification1
     SSH traffic verification1
     [Teardown]  Reload BTS

***keywords***
GET IPS3
    Setup Remote Access     remote_device=bts   alias=bts
    ${MPLANE_IP}=   Remote Command Execute     command=${mplane_RUSWN_ip}   alias=bts
    Set Suite Variable  ${MPLANE_IP}    ${MPLANE_IP}
    Setup Remote Access     remote_device=SMO
    ${SMO_IP}=   Remote Command Execute     command=${SMO_IP}
    Teardown Remote Access
    Set Suite Variable      ${SMO_IP}    ${SMO_IP}
    ${output1}=   Execute Interactive Remote Command     command=${oru1_ip}     alias=bts
    ${ORU1_IP}=     Get Line    ${output1}  -2
    Teardown Remote Access  alias=bts
    Set Suite Variable  ${ORU1_IP}  ${ORU1_IP}
    Set Suite Variable  ${MPLANE_IP}  ${MPLANE_IP}

check routes in smo for O-RU SWN
    Setup Remote Access     remote_device=SMO
    ${routes}=   Remote Command Execute     command=${route_check}
    ${status}=  Run Keyword And Return Status   Should Contain  ${routes}   ${ORU1_IP} via ${MPLANE_IP} dev
...      ${smo_interface}
    Teardown Remote Access
    Run Keyword If      '${status}'=='False'   Run Keywords    Setup Remote Access     remote_device=SMO
    ...   AND   Remote Command Execute     command=ip route add ${ORU1_IP} via ${MPLANE_IP} dev ${smo_interface}
    ...   AND   Teardown Remote Access

SMO initiated traffic verification on ORU
    Traffic capture start    capture_device=ORU_ens1f0        alias=default
    Traffic Setup           device=device_1
    Run Keyword And Continue On Failure    Traffic Start   profile=smo_initiated
    ${filename}=  Traffic Capture Stop    capture_device=ORU_ens1f0    alias=default
    Analyse Pcap        pcap_filename=${filename}        analysis=verify_smotraffic

ORU initiated traffic verification1
    Traffic capture start     capture_device=SMO_enp6s0f0     alias=default
    Sleep    60
    ${filename}=  Traffic Capture Stop    capture_device=SMO_enp6s0f0   alias=default
    Analyse Pcap        pcap_filename=${filename}        analysis=verify_eventcontroller

SSH traffic verification1
    Traffic capture start    capture_device=SMO_enp6s0f0     alias=ssh
    Setup Remote Access     remote_device=ORU_simulator     alias=ssh
    Execute Interactive Remote Command  command=${sudo}  alias=ssh
    Execute Interactive Remote Command  command=${password}   alias=ssh
    ${container}=   Execute Interactive Remote Command    command=${ORU1_container}    alias=ssh
    ${container_ID}=    Get Line   ${container}     2
    @{SSH_ORU1}=  Create List  ssh_ORU1
    ${ssh1_cmd}=  Get Config Variable  ${SSH_ORU1}
    ${output}=   Execute Interactive Remote Command  command=${ssh1_cmd}   alias=ssh
    Analyse Pcap        pcap_filename=${filename}        analysis=verify_ssh

Reload BTS
    Sleep    10
    Run Keyword And Ignore Error       Perform Recommissioning    type=delta    delta_file=${DisableFLAG}
    ...     timeout=200
