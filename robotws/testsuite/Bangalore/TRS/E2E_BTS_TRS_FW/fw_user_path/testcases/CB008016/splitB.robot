*** Settings ***
Documentation
...     [Author]        "Mamtha Kshirsagar"
...     [Maintenance]   "TRS ET Bangalore Team"
...     [Procedure]     "The test case is planned to verify  verify Nating traffic from SMO to intermediate node and viceversa"
...     [Date]          "22-12-2022"
...     [Feature_ID]    "CB008016"
...     [Requirement ID]    "TT_IPT.3037"
...     [Config]    "This script requires basic SCF loading."
...     [RunTime Parameters]    "bts_id used is 8016"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"

variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot


Suite Setup     Run Keywords        Suite Setup Preconditions        AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions       AND     Teardown Oamops


*** Test Cases ***
[1][1.0] TRS_Route Addition to reach Intermediate Node for NAT based Solution Route Based CB008016
     Perform Commissioning       scf_file=${splitB_scf}    verify_bts_status=False      timeout=400      alias=default
     Get IPS
#     check routes in smo and int node
     check NAT rules
     SMO initiated traffic verification
     intermediate node initiated traffic verification
     SMO initiated SSH traffic verification
     intermediate node initiated SSH traffic verification
     Verify Iptables

***keywords***
Get IPS
    Setup Remote Access     remote_device=SMO
    ${SMO_IP} =    Remote Command Execute       command=${smo_ip}
    Teardown Remote Access
    Setup Remote Access     remote_device=int_node
    ${INT_IP} =    Remote Command Execute       command=${int_ip_B}
    Teardown Remote Access
    Set Suite Variable      ${SMO_IP}    ${SMO_IP}
    Set Suite Variable      ${INT_IP}   ${INT_IP}
    Rfmodule Setup      config_device=rf_module          fhnet_login_only=${True}  alias=fronthaul
    ${output}=   Execute Interactive Remote Command     command=${fh_ip}     alias=fronthaul
    ${FH_IP}=   Get Line    ${output}   -3
    Set Suite Variable  ${FH_IP}    ${FH_IP}
    Rfmodule Teardown   alias=fronthaul
    Setup Remote Access     remote_device=bts   alias=bts
    ${MPLANE_IP} =   Remote Command Execute     command=${mplane_A_ip}   alias=bts
    Set Suite Variable  ${MPLANE_IP}    ${MPLANE_IP}
    Teardown Remote Access  alias=bts
    Setup Remote Access     remote_device=bts   alias=bbmod
    Execute Interactive Remote Command     command=${bbmod_login}   alias=bbmod
     Execute Interactive Remote Command  command=yes  alias=bbmod
    Execute Interactive Remote Command  command=${password1}  alias=bbmod
    ${output2}=    Execute Interactive Remote Command      command=${bbmod_ip_B}     alias=bbmod
    ${BBMOD_IP}=   Get Line    ${output2}   -2
    Teardown Remote Access  alias=bbmod
    Set Suite Variable  ${BBMOD_IP}     ${BBMOD_IP}

check routes in smo and int node
    Setup Remote Access     remote_device=SMO
    ${routes} =    Remote Command Execute       command=${route_check}
    ${status} =  Run Keyword And Return Status   Should Contain  ${routes}   ${INT_IP} via ${MPLANE_IP} dev enp6s0f0
    Teardown Remote Access
    Run Keyword If      '${status}'=='False'   Run Keywords    Setup Remote Access     remote_device=SMO
    ...   AND   Remote Command Execute     command=ip route add ${INT_IP} via ${MPLANE_IP} dev enp6s0f0
    ...   AND   Teardown Remote Access
    Setup Remote Access     remote_device=int_node
    ${routes1} =    Remote Command Execute       command=${route_check}
    ${status1} =  Run Keyword And Return Status   Should Contain  ${routes1}   ${SMO_IP} via ${BBMOD_IP} dev enp6s0f1.120
    Teardown Remote Access
    Run Keyword If      '${status1}'=='False'   Run Keywords    Setup Remote Access     remote_device=int_node  alias=intnode
    ...   AND   Remote Command Execute     command=ip route del ${SMO_IP}  alias=intnode
    ...   AND   Remote Command Execute     command=ip route add ${SMO_IP} via ${BBMOD_IP} dev enp6s0f1.120  alias=intnode
    ...   AND   Teardown Remote Access  alias=intnode
    Setup Remote Access     remote_device=int_node  alias=fh
    ${routes2} =    Remote Command Execute       command=${route_check}     alias=fh
    ${status2} =  Run Keyword And Return Status   Should Contain  ${routes2}   ${FH_IP} via  ${BBMOD_IP} dev enp6s0f1.120     alias=fh
    Run Keyword If      '${status2}'=='False'   Run Keywords    Remote Command Execute     command=ip route del ${FH_IP}  alias=fh
    ...   AND   Remote Command Execute     command=ip route add ${FH_IP} via  ${BBMOD_IP}dev enp6s0f1.120   alias=fh
    ...   AND   Teardown Remote Access  alias=fh

check NAT rules
    Rfmodule Setup      config_device=rf_module          fhnet_login_only=${True}  alias=fronthaul
    ${output}=   Execute Interactive Remote Command     command=${nat_source}     alias=fronthaul
    ${NAT_SOURCE}=  Get Line    ${output}   -3
    Should Be Equal     ${NAT_SOURCE}   ${SMO_IP}
    ${output1}=   Execute Interactive Remote Command     command=${nat_destination}     alias=fronthaul
    ${NAT_DESTINATION}=  Get Line    ${output1}   -3
    Should Be Equal     ${NAT_DESTINATION}   ${MPLANE_IP}
    ${output2}=   Execute Interactive Remote Command     command=${nat_source_snat}     alias=fronthaul
    ${NAT_SOURCE_SNAT}=  Get Line    ${output2}   -3
    Should Be Equal     ${NAT_SOURCE_SNAT}      ${INT_IP}
    ${output3}=   Execute Interactive Remote Command     command=${nat_destination_snat}     alias=fronthaul
    ${NAT_DESTINATION_SNAT}=  Get Line    ${output3}   -3
    Should Be Equal     ${NAT_DESTINATION_SNAT}      ${SMO_IP}
    ${output_port}=     Get Parameter   param_path=${oduextport}
    ${output_nat}=   Execute Interactive Remote Command     command=${nat_rule_oduport}     alias=fronthaul
    ${output_NAT1}=  Get Line    ${output_nat}   -3
    Should Be Equal As Integers     ${output_port}      ${output_NAT1}
    ${fh_port}=   Execute Interactive Remote Command     command=${fhnode_port}     alias=fronthaul
    ${FH_PORT1}=     Get Line    ${fh_port}  -3
    ${output_fhnodeport}=     Get Parameter   param_path=${fhnodeserviceportpath}
    Should Be Equal As Integers     ${FH_PORT1}  ${output_fhnodeport}
    ${INTNODE_IP}=   Execute Interactive Remote Command     command=${intnode_ip}     alias=fronthaul
    ${INT_IP}=  Get Line    ${INTNODE_IP}   -3
    ${FHNODE_IP}=     Get Parameter   param_path=${fhnode_ip_path}
    Should Be Equal     ${INT_IP}   ${FHNODE_IP}
    ${output_POSTROUTING_IP}=   Execute Interactive Remote Command     command=${postrouting_ip}     alias=fronthaul
    ${POSTROUTING_IP}=  Get Line    ${output_POSTROUTING_IP}    -3
    Should Be Equal     ${POSTROUTING_IP}   ${MPLANE_IP}
    ${op_NMS_PORT}=   Execute Interactive Remote Command     command=${nms_port}     alias=fronthaul
    ${NMS_PORT}=    Get Line    ${op_NMS_PORT}  -3
    ${NMS_PORT_scf}=     Get Parameter   param_path=${nms_port_path}
    Should Be Equal As Integers   ${NMS_PORT}     ${NMS_PORT_scf}[0]
    ${op_PORT_RANGE}=   Execute Interactive Remote Command     command=${port_range}     alias=fronthaul
    ${PORT_RANGE}=  Get Line    ${op_PORT_RANGE}    -3
    Should Be Equal     ${PORT_RANGE}   25601-25900
    ${dnat_pckts_before}=   Execute Interactive Remote Command     command=${packets_dnat}     alias=fronthaul
    ${DNAT_packets_before}=     Get Line    ${dnat_pckts_before}    -3
    ${snat_pckts_before}=   Execute Interactive Remote Command     command=${packets_snat}     alias=fronthaul
    ${SNAT_packets_before}=     Get Line    ${snat_pckts_before}    -3
    Set Suite Variable  ${DNAT_packets_before}  ${DNAT_packets_before}
    Set Suite Variable  ${SNAT_packets_before}  ${SNAT_packets_before}
    Rfmodule Teardown   alias=fronthaul

SMO initiated traffic verification
     Traffic capture start           capture_device=int_enp6s0f1_120     alias=default
     Traffic Setup           device=SMO
     Run Keyword And Continue On Failure    Traffic Start   profile=smo_initiated_splitB
     ${filename}=  Traffic Capture Stop    capture_device=int_enp6s0f1_120    alias=default
     Analyse Pcap        pcap_filename=${filename}        analysis=splitB_smo_initiated
     Traffic Teardown   alias=default

intermediate node initiated traffic verification
    Traffic capture start           capture_device=SMO_enp6s0f0
    Traffic Setup           device=intnode_enp6s0f1_120
    Run Keyword And Continue On Failure    Traffic Start   profile=int_initiated_splitB
    ${filename}=  Traffic Capture Stop    capture_device=SMO_enp6s0f0
    Analyse Pcap        pcap_filename=${filename}        analysis=splitB_int_initiated
    Traffic Teardown   alias=default

SMO initiated SSH traffic verification
    Traffic capture start           capture_device=int_enp6s0f1_120     alias=smo
    Setup Remote Access     remote_device=SMO   alias=smo
    Remote Command Execute  command=ssh ${MPLANE_IP} -p 25301  alias=smo
    ${filename}=  Traffic Capture Stop    capture_device=int_enp6s0f1_120    alias=default  alias=smo
    Analyse Pcap        pcap_filename=${filename}        analysis=splitB_smo_init_ssh   alias=smo

intermediate node initiated SSH traffic verification
    Traffic capture start           capture_device=SMO_enp6s0f0     alias=int
    Setup Remote Access     remote_device=int_node      alias=int
    FOR    ${i}   IN RANGE  1   5
        Remote Command Execute  command=ssh ${SMO_IP}   alias=int
    END
    ${filename}=  Traffic Capture Stop    capture_device=SMO_enp6s0f0   alias=int
    Analyse Pcap        pcap_filename=${filename}        analysis=splitB_int_init_ssh   alias=int

Verify Iptables
    Rfmodule Setup      config_device=rf_module          fhnet_login_only=${True}  alias=fronthaul
    ${dnat_pckts_after}=   Execute Interactive Remote Command     command=${packets_dnat}     alias=fronthaul
    ${DNAT_packets_after}=      Get Line    ${dnat_pckts_after}    -3
    ${snat_pckts_after}=   Execute Interactive Remote Command     command=${packets_snat}     alias=fronthaul
    ${SNAT_packets_after}=      Get Line    ${snat_pckts_after}    -3
    Should Be True  ${DNAT_packets_after}>${DNAT_packets_before}
    Should Be True  ${SNAT_packets_after}>${SNAT_packets_before}
    Rfmodule Teardown   alias=fronthaul

