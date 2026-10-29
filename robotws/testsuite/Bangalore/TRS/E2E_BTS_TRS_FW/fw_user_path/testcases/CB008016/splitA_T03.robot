*** Settings ***
Documentation
...     [Author]        "Mamtha Kshirsagar"
...     [Maintenance]   "TRS ET Bangalore Team"
...     [Procedure]     "The test case is planned to verify traffic from SMO to Intermediate node and viceversa"
...     [Date]          "22-11-2022"
...     [Feature_ID]    "CB008016"
...     [Requirement ID]    "TT_IPT.3045,TT_IPT.3040;5G_RAN_USR_COM_14645;OAM_REQ_TRSSEC_144"
...     [Config]    "This script requires basic SCF loading."
...     [RunTime Parameters]    "bts_id used is 8016"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"

variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot


Suite Setup     Run Keywords        Suite Setup Preconditions        AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions       AND     Teardown Oamops


*** Test Cases ***
[1]TRS_Iptables at FH Interface for for SMO intiated Trafic CB008016
     Perform Commissioning       scf_file=${splitA_scf}    verify_bts_status=False      timeout=400      alias=default
     GET IPS
#     Check routes in smo and int node
     SMO initiated SSH traffic verification


***keywords***

Get IPS
    Setup Remote Access     remote_device=SMO
    ${SMO_IP} =    Remote Command Execute       command=${smo_ip}
    Teardown Remote Access
    Setup Remote Access     remote_device=int_node
    ${INT_IP}=   Remote Command Execute     command=${int_ip}
    Teardown Remote Access
    Set Suite Variable      ${SMO_IP}    ${SMO_IP}
    Set Suite Variable      ${INT_IP}   ${INT_IP}
    Rfmodule Setup      config_device=rf_module          fhnet_login_only=${True}  alias=fronthaul
    ${output}=   Execute Interactive Remote Command     command=${fh_ip}     alias=fronthaul
    ${FH_IP}=   Get Line    ${output}   -3
    Set Suite Variable  ${FH_IP}    ${FH_IP}
    Rfmodule Teardown   alias=fronthaul
    Setup Remote Access     remote_device=bts   alias=bts
    ${MPLANE_IP}=   Remote Command Execute     command=${mplane_A_ip}   alias=bts
    Set Suite Variable  ${MPLANE_IP}    ${MPLANE_IP}
    Teardown Remote Access  alias=bts
    Setup Remote Access     remote_device=bts   alias=bbmod
    Execute Interactive Remote Command     command=${bbmod_login}   alias=bbmod
    Execute Interactive Remote Command  command=${password1}  alias=bbmod
    ${output2}=    Execute Interactive Remote Command      command=${bbmod_ip}     alias=bbmod
    ${BBMOD_IP}=   Get Line    ${output2}   -2
    Teardown Remote Access  alias=bbmod
    Set Suite Variable  ${BBMOD_IP}     ${BBMOD_IP}


check routes in smo and int node
    Setup Remote Access     remote_device=SMO
    ${routes}=   Remote Command Execute     command=${route_check}
    ${status}=  Run Keyword And Return Status   Should Contain  ${routes}   ${INT_IP} via ${MPLANE_IP} dev enp6s0f1
    Teardown Remote Access
    Run Keyword If      '${status}'=='False'   Run Keywords    Setup Remote Access     remote_device=SMO
    ...   AND   Remote Command Execute     command=ip route add ${INT_IP} via ${MPLANE_IP} dev enp6s0f0
    ...   AND   Teardown Remote Access
    Setup Remote Access     remote_device=int_node
    ${routes1}=   Remote Command Execute     command=${route_check}
    ${status1}=  Run Keyword And Return Status   Should Contain  ${routes1}   ${SMO_IP} via ${BBMOD_IP} dev enp6s0f1.120
    Teardown Remote Access
    Run Keyword If      '${status1}'=='False'   Run Keywords    Setup Remote Access     remote_device=int_node  alias=intnode
    ...   AND   Remote Command Execute     command=ip route del ${SMO_IP}  alias=intnode
    ...   AND   Remote Command Execute     command=ip route add ${SMO_IP} via ${BBMOD_IP} dev enp6s0f1.120  alias=intnode
    ...   AND   Teardown Remote Access  alias=intnode
    Setup Remote Access     remote_device=int_node  alias=fh
    ${routes2}=   Remote Command Execute     command=${route_check}     alias=fh
    ${status2}=  Run Keyword And Return Status   Should Contain  ${routes2}   ${FH_IP} via  ${BBMOD_IP}dev enp6s0f1.120     alias=fh
    Run Keyword If      '${status2}'=='False'   Run Keywords    Remote Command Execute     command=ip route del ${FH_IP}  alias=fh
    ...   AND   Remote Command Execute     command=ip route add ${FH_IP} via  ${BBMOD_IP}dev enp6s0f1.120   alias=fh
    ...   AND   Teardown Remote Access  alias=fh

SMO initiated SSH traffic verification
    Traffic capture start           capture_device=int_enp6s0f1_120     alias=smo
    Setup Remote Access     remote_device=SMO   alias=smo
    Remote Command Execute  command=ssh ${INT_IP}   alias=smo
    ${filename}=  Traffic Capture Stop    capture_device=int_enp6s0f1_120    alias=default  alias=smo
    Analyse Pcap        pcap_filename=${filename}        analysis=splitA_smo_init_ssh   alias=smo

