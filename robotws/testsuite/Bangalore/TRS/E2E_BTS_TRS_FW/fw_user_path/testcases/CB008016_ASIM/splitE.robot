*** Settings ***
Documentation
...     [Author]        "Mamtha Kshirsagar"
...     [Maintenance]   "TRS ET Bangalore Team"
...     [Procedure]     "Intermediate Node routing based solution for eCPRI M-Plane- SWN-IPV4"
...     [Date]          "12-11-2022"
...     [Feature_ID]    "CB008016"
...     [Requirement ID]    "WgNB_SEC_60532"
...     [Config]    "This script requires basic SCF loading."
...     [RunTime Parameters]    "bts_id used is 80161"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"

variables       ta_e2e_bts_trs_fw

Resource        ${CURDIR}/../resources/common_keywords.robot

Suite Setup     Run Keywords        Suite Setup Preconditions        AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions       AND     Teardown Oamops

*** Test Cases ***
[1][1.0] Intermediate Node routing based solution for eCPRI M-Plane- SWN-IPV4
     Perform Commissioning       scf_file=${splitE_scf}   verify_bts_status=${True}     timeout=350    alias=default
     Sleep  300
     Get IPS
#     check routes in smo and int node
     SMO initiated traffic verification
     intermediate node initiated traffic verification
     SMO initiated SSH traffic verification
     intermediate node initiated SSH traffic verification

***keywords***
Get IPS
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
    ${MPLANE_IP}=   Remote Command Execute     command=${mplane_A_ip}   alias=bts
    Set Suite Variable  ${MPLANE_IP}    ${MPLANE_IP}
    Teardown Remote Access  alias=bts
    Setup Remote Access     remote_device=bts   alias=bbmod
    Execute Interactive Remote Command     command=${bbmod_login}   alias=bbmod
    ${output2}=    Execute Interactive Remote Command      command=${bbmod_E_ip}     alias=bbmod
    ${BBMOD_E_IP}=   Get Line    ${output2}   -2
    Teardown Remote Access  alias=bbmod
    Set Suite Variable  ${BBMOD_E_IP}     ${BBMOD_E_IP}


check routes in smo and int node
    Setup Remote Access     remote_device=SMO
    ${routes}=   Remote Command Execute     command=${route_check}
    ${status}=  Run Keyword And Return Status   Should Contain  ${routes}   ${INT_E_IP} via ${MPLANE_IP} dev enp6s0f0
    Teardown Remote Access
    Run Keyword If      '${status}'=='False'   Run Keywords    Setup Remote Access     remote_device=SMO
    ...   AND   Remote Command Execute     command=ip route add ${INT_E_IP} via ${MPLANE_IP} dev enp6s0f0
    ...   AND   Teardown Remote Access
    Setup Remote Access     remote_device=int_E_node
    ${routes1}=   Remote Command Execute     command=${route_check}
    ${status1}=  Run Keyword And Return Status   Should Contain  ${routes1}   ${SMO_IP} via ${BBMOD_E_IP} dev ens4f1.400
    Teardown Remote Access
    Run Keyword If      '${status1}'=='False'   Run Keywords    Setup Remote Access     remote_device=int_E_node  alias=intnode
    ...   AND   Remote Command Execute     command=ip route del ${SMO_IP}  alias=intnode
    ...   AND   Remote Command Execute     command=ip route add ${SMO_IP} via ${BBMOD_E_IP} dev ens4f1.400  alias=intnode
    ...   AND   Teardown Remote Access  alias=intnode
    Setup Remote Access     remote_device=int_E_node  alias=fh
    ${routes2}=   Remote Command Execute     command=${route_check}     alias=fh
    ${status2}=  Run Keyword And Return Status   Should Contain  ${routes2}   ${FH_IP} via  ${BBMOD_E_IP}dev ens4f1.400     alias=fh
    Run Keyword If      '${status2}'=='False'   Run Keywords    Remote Command Execute     command=ip route del ${FH_IP}  alias=fh
    ...   AND   Remote Command Execute     command=ip route add ${FH_IP} via  ${BBMOD_E_IP}dev ens4f1.400   alias=fh
    ...   AND   Teardown Remote Access  alias=fh

SMO initiated traffic verification
     Traffic capture start           capture_device=int_ens4f0_400     alias=default
     Traffic Setup           device=SMO
     Run Keyword And Continue On Failure    Traffic Start   profile=smo_initiated_splitE
     ${filename}=  Traffic Capture Stop    capture_device=int_ens4f0_400    alias=default
     Analyse Pcap        pcap_filename=${filename}        analysis=splitE_smo_initiated
     Traffic Teardown   alias=default

intermediate node initiated traffic verification
    Traffic capture start           capture_device=SMO_enp6s0f0
    Traffic Setup           device=intnode_ens4f0_400
    Run Keyword And Continue On Failure    Traffic Start   profile=int_initiated_splitE
    ${filename}=  Traffic Capture Stop    capture_device=SMO_enp6s0f0
    Analyse Pcap        pcap_filename=${filename}        analysis=splitE_int_initiated
    Traffic Teardown   alias=default

SMO initiated SSH traffic verification
    Traffic capture start           capture_device=int_ens4f0_400     alias=default
    Setup Remote Access     remote_device=SMO
    Remote Command Execute  command=ssh ${INT_E_IP}
    ${filename}=  Traffic Capture Stop    capture_device=int_ens4f0_400    alias=default
    Analyse Pcap        pcap_filename=${filename}        analysis=splitE_smo_init_ssh

intermediate node initiated SSH traffic verification
    Traffic capture start           capture_device=SMO_enp6s0f0     alias=int
    Setup Remote Access     remote_device=int_E_node      alias=int
    FOR    ${i}   IN RANGE  1   5
        Remote Command Execute  command=ssh ${SMO_IP}   alias=int
    END
    ${filename}=  Traffic Capture Stop    capture_device=SMO_enp6s0f0   alias=int
    Analyse Pcap        pcap_filename=${filename}        analysis=splitE_int_init_ssh   alias=int




