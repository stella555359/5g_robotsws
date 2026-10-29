*** Settings ***
Documentation
...     [Author]        "Shweta"
...     [Maintenance]   "TRS ET Bangalore Team"
...     [Procedure]     "Common keyword file for CB06533 feature"
...     [Date]          "22-11-2024"
...     [Feature_ID]    "CB006533"
...     [Requirement ID]    "TT_IPT.3037"
...     [Config]    "This script requires basic SCF loading."
...     [RunTime Parameters]    "bts_id used is 6533"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"


Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot


*** Variables ***
${tc_variables}     testcase_variables.json

***keywords***
GET IPS
    Setup Remote Access     remote_device=bts   alias=bts
    ${MPLANE_IP}=   Remote Command Execute     command=${mplane_RU_ip}   alias=bts
    Set Suite Variable  ${MPLANE_IP}    ${MPLANE_IP}
    ${SMO}=      Get Parameter   param_path=${smo_ip_path}
    ${SMO_IP}=      Set Variable    ${SMO}[0]
    ${SMO_ip1}=      Set Variable    ${SMO_IP}[ipv6Address]
    Teardown Remote Access  alias=bts
    Setup Remote Access     remote_device=bts   alias=ssh
    ${output1}=   Execute Interactive Remote Command     command=${oru1_ip}     alias=ssh
    ${ORU1_IP}=     Get Line    ${output1}  -2
    Teardown Remote Access  alias=ssh
    Setup Remote Access     remote_device=secondary_vm   alias=sec_vm
    Execute Interactive Remote Command     command=${dut_login}     alias=sec_vm
    ${output2}=   Execute Interactive Remote Command     command=${oru2_ip}     alias=sec_vm
    ${ORU2_IP}=     Get Line    ${output2}  -2
    Teardown Remote Access  alias=sec_vm
    Set Suite Variable  ${ORU2_IP}  ${ORU2_IP}
    Set Suite Variable  ${ORU1_IP}  ${ORU1_IP}
    Set Suite Variable  ${SMO_ip1}  ${SMO_ip1}
    Set Suite Variable  ${MPLANE_IP}  ${MPLANE_IP}


check routes in smo
    Setup Remote Access     remote_device=SMO
    ${routes}=   Remote Command Execute     command=${route_check}
    ${status}=  Run Keyword And Return Status   Should Contain  ${routes}   ${ORU1_IP} via ${MPLANE_IP} dev
    ...     ${smo_interface}
    Teardown Remote Access
    Run Keyword If      '${status}'=='False'   Run Keywords    Setup Remote Access     remote_device=SMO
    ...   AND   Remote Command Execute     command=ip route add ${ORU1_IP} via ${MPLANE_IP} dev ${smo_interface}
    ...   AND   Teardown Remote Access
    Setup Remote Access     remote_device=SMO  alias=fh
    ${routes}=   Remote Command Execute     command=${route_check}  alias=fh
    ${status}=  Run Keyword And Return Status   Should Contain  ${routes}   ${ORU2_IP} via ${MPLANE_IP} dev ${smo_interface}
    Teardown Remote Access  alias=fh
    Run Keyword If      '${status}'=='False'   Run Keywords    Setup Remote Access     remote_device=SMO  alias=fh
    ...   AND   Remote Command Execute     command=ip route add ${ORU2_IP} via ${MPLANE_IP} dev ${smo_interface}  alias=fh
    ...   AND   Teardown Remote Access  alias=fh

SMO initiated traffic verification on 1st ORU
     Traffic capture start           capture_device=ORU_ens1f0     alias=default
     Traffic Setup           device=SMO
     Run Keyword And Continue On Failure    Traffic Start   profile=smo_initiated
     ${filename}=  Traffic Capture Stop    capture_device=ORU_ens1f0    alias=default
     Analyse Pcap        pcap_filename=${filename}        analysis=verify_smotraffic

SMO initiated traffic verification on 2nd ORU
    Traffic capture start           capture_device=ORU_ens6f1     alias=ORU2
    Traffic Setup           device=SMO     alias=ORU2
    Run Keyword And Continue On Failure    Traffic Start   profile=smo_initiated1     alias=ORU2
    ${filename}=  Traffic Capture Stop    capture_device=ORU_ens6f1    alias=ORU2
    Analyse Pcap        pcap_filename=${filename}        analysis=verify_smotraffic_ORU2     alias=ORU2
    Traffic Teardown
    Traffic Teardown    alias=ORU2

ORU initiated traffic verification
    Traffic capture start           capture_device=SMO_enp6s0f0     alias=default
    Sleep    100
    ${filename}=  Traffic Capture Stop    capture_device=SMO_enp6s0f0   alias=default
    Analyse Pcap        pcap_filename=${filename}        analysis=verify_eventcontroller

SSH traffic verification
    Traffic capture start           capture_device=SMO_enp6s0f0     alias=ssh
    Setup Remote Access     remote_device=ORU_simulator     alias=ssh
    Execute Interactive Remote Command  command=${sudo}  alias=ssh
    Execute Interactive Remote Command  command=${password}   alias=ssh
    ${container}=   Execute Interactive Remote Command    command=${ORU1_container}    alias=ssh
    ${container_ID}=    Get Line   ${container}     2
    @{SSH_ORU1}=  Create List  ssh_ORU1
    ${ssh1_cmd}=  Get Config Variable  ${SSH_ORU1}
    ${output}=   Execute Interactive Remote Command  command=${ssh1_cmd}   alias=ssh
    ${filename}=  Traffic Capture Stop    capture_device=SMO_enp6s0f0   alias=ssh
     Analyse Pcap        pcap_filename=${filename}        analysis=verify_ssh1

    Traffic capture start           capture_device=SMO_enp6s0f0     alias=ssh1
    Setup Remote Access     remote_device=ORU_simulator     alias=ssh1
    Execute Interactive Remote Command  command=${sudo}  alias=ssh1
    ${container2}=   Execute Interactive Remote Command    command=${ORU2_CONTAINER}    alias=ssh1
    ${container_ID2}=    Get Line   ${container2}     2
    @{SSH_ORU2}=    Create List     ssh_ORU2
    ${ssh2_cmd}=  Get Config Variable  ${SSH_ORU2}
    ${output2}=   Execute Interactive Remote Command  command=${ssh2_cmd}   alias=ssh1
    ${filename}=  Traffic Capture Stop    capture_device=SMO_enp6s0f0    alias=ssh1
    Analyse Pcap        pcap_filename=${filename}        analysis=verify_ssh_ORU2

RU Reset
    Reset      operation=reset_unit  dist_name=${RMOD-2}      reset_type=warm   should_be_onair=False   timeout=300
    Reset      operation=reset_unit  dist_name=${RMOD-4}      reset_type=warm  should_be_onair=False   timeout=300


SSH traffic verification after RU reset
    Traffic capture start           capture_device=SMO_enp6s0f0     alias=ssh2
    Setup Remote Access     remote_device=ORU_simulator     alias=ssh2
    Execute Interactive Remote Command  command=${sudo}  alias=ssh2
    ${container}=   Execute Interactive Remote Command    command=${ORU1_container}    alias=ssh2
    ${container_ID}=    Get Line   ${container}     2
    @{SSH_ORU1}=  Create List  ssh_ORU1
    ${ssh1_cmd}=  Get Config Variable  ${SSH_ORU1}
    ${output}=   Execute Interactive Remote Command  command=${ssh1_cmd}   alias=ssh2
    ${filename}=  Traffic Capture Stop    capture_device=SMO_enp6s0f0   alias=ssh2
    Analyse Pcap        pcap_filename=${filename}        analysis=verify_ssh1

    Traffic capture start           capture_device=SMO_enp6s0f0     alias=ssh3
    Setup Remote Access     remote_device=ORU_simulator     alias=ssh3
    Execute Interactive Remote Command  command=${sudo}  alias=ssh3
    ${container2}=   Execute Interactive Remote Command    command=${ORU2_CONTAINER}    alias=ssh3
    ${container_ID2}=    Get Line   ${container2}     2
    @{SSH_ORU2}=    Create List     ssh_ORU2
    ${ssh2_cmd}=  Get Config Variable  ${SSH_ORU2}
    ${output2}=   Execute Interactive Remote Command  command=${ssh2_cmd}   alias=ssh3
    ${filename}=  Traffic Capture Stop    capture_device=SMO_enp6s0f0   alias=ssh3
    Analyse Pcap        pcap_filename=${filename}        analysis=verify_ssh_ORU2

Get IPS for Intnode
    Setup Remote Access     remote_device=SMO
    ${SMO_IP}=   Remote Command Execute     command=${smo_ip}
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
    ${MPLANE_IP}=   Remote Command Execute     command=${mplane_ip}  alias=bts
    Set Suite Variable  ${MPLANE_IP}    ${MPLANE_IP}
    Teardown Remote Access  alias=bts
    Setup Remote Access     remote_device=bts   alias=bbmod
    Execute Interactive Remote Command     command=${bbmod_login_primary}   alias=bbmod
    Execute Interactive Remote Command  command=${password1}  alias=bbmod
    ${output2}=    Execute Interactive Remote Command      command=${bbmod_ip}     alias=bbmod
    ${BBMOD_IP}=   Get Line    ${output2}   -2
    Teardown Remote Access  alias=bbmod
    Set Suite Variable  ${BBMOD_IP}     ${BBMOD_IP}

check routes in int node and smo
    Setup Remote Access     remote_device=SMO
    ${routes}=   Remote Command Execute     command=${route_check}
    ${status}=  Run Keyword And Return Status   Should Contain  ${routes}   ${INT_IP} via ${MPLANE_IP} dev
    ...     ${smo_interface}
    Teardown Remote Access
    Run Keyword If      '${status}'=='False'   Run Keywords    Setup Remote Access     remote_device=SMO
    ...   AND   Remote Command Execute     command=ip route add ${INT_IP} via ${MPLANE_IP} dev ${smo_interface}
    ...   AND   Teardown Remote Access
    Setup Remote Access     remote_device=int_node
    ${routes1}=   Remote Command Execute     command=${route_check}
    ${status1}=  Run Keyword And Return Status   Should Contain  ${routes1}   ${SMO_IP} via ${BBMOD_IP} dev
    ...     ${intnode_interface}
    Teardown Remote Access
    Run Keyword If      '${status1}'=='False'   Run Keywords    Setup Remote Access     remote_device=int_node
    ...     alias=intnode
    ...   AND   Remote Command Execute     command=ip route del ${SMO_IP}  alias=intnode
    ...   AND   Remote Command Execute     command=ip route add ${SMO_IP} via ${BBMOD_IP} dev ${intnode_interface}
    ...     alias=intnode
    ...   AND   Teardown Remote Access  alias=intnode
    Setup Remote Access     remote_device=int_node  alias=fh
    ${routes2}=   Remote Command Execute     command=${route_check}  alias=fh
    ${status2}=  Run Keyword And Return Status   Should Contain  ${routes2}   ${FH_IP} via ${BBMOD_IP} dev
    ...     ${intnode_interface}
    Teardown Remote Access  alias=fh
    Run Keyword If      '${status1}'=='False'   Run Keywords    Setup Remote Access     remote_device=int_node  alias=fh
    ...   AND   Remote Command Execute     command=ip route del ${FH_IP}  alias=fh
    ...   AND   Remote Command Execute     command=ip route add ${FH_IP} via ${BBMOD_IP} dev ${intnode_interface}  alias=fh
    ...   AND   Teardown Remote Access  alias=fh

SMO initiated traffic verification
    Traffic capture start           capture_device=int_enp6s0f0_120     alias=default
    Traffic Setup           device=SMO
    Run Keyword And Continue On Failure    Traffic Start   profile=smo_initiated_splitA
    ${filename}=  Traffic Capture Stop    capture_device=int_enp6s0f0_120    alias=default
    Analyse Pcap        pcap_filename=${filename}        analysis=splitA_smo_initiated
    Traffic Teardown   alias=default

intermediate node initiated traffic verification
    Traffic capture start           capture_device=SMO_enp6s0f0
    Traffic Setup           device=intnode_enp6s0f0_120
    Run Keyword And Continue On Failure    Traffic Start   profile=int_initiated_splitA
    ${filename}=  Traffic Capture Stop    capture_device=SMO_enp6s0f0
    Analyse Pcap        pcap_filename=${filename}        analysis=splitA_int_initiated
    Traffic Teardown   alias=default

SMO initiated SSH traffic verification
    Traffic capture start           capture_device=int_enp6s0f0_120     alias=smo
    Setup Remote Access     remote_device=SMO   alias=smo
    Remote Command Execute  command=ssh ${INT_IP}   alias=smo
    ${filename}=  Traffic Capture Stop    capture_device=int_enp6s0f0_120    alias=default  alias=smo
    Analyse Pcap        pcap_filename=${filename}        analysis=splitA_smo_init_ssh   alias=smo

intermediatenode initiated SSH traffic verification
    Traffic capture start           capture_device=SMO_enp6s0f0     alias=int
    Setup Remote Access     remote_device=int_node      alias=int
    FOR    ${i}   IN RANGE  1   5
        Remote Command Execute  command=ssh ${SMO_IP}   alias=int
    END
    ${filename}=  Traffic Capture Stop    capture_device=SMO_enp6s0f0   alias=int
    Analyse Pcap        pcap_filename=${filename}        analysis=splitA_int_init_ssh   alias=int

bbmod reset
     Reset   operation=reset_unit  dist_name=${BBMOD-3}    reset_type=warm    should_be_onair=False   timeout=300
     BuiltIn.Sleep       300

SMO initiated SSH traffic verification after bbmod reset
    Traffic capture start           capture_device=int_enp6s0f0_120     alias=smo1
    Setup Remote Access     remote_device=SMO   alias=smo1
    Remote Command Execute  command=ssh ${INT_IP}   alias=smo1
    ${filename}=  Traffic Capture Stop    capture_device=int_enp6s0f0_120    alias=default  alias=smo1
    Analyse Pcap        pcap_filename=${filename}        analysis=splitA_smo_init_ssh_reset   alias=smo1

intermediate node initiated SSH traffic verification after bbmod reset
    Traffic capture start           capture_device=SMO_enp6s0f0     alias=int1
    Setup Remote Access     remote_device=int_node      alias=int1
    FOR    ${i}   IN RANGE  1   5
         Remote Command Execute  command=ssh ${SMO_IP}   alias=int1
    END
    ${filename}=  Traffic Capture Stop    capture_device=SMO_enp6s0f0   alias=int1
    Analyse Pcap        pcap_filename=${filename}        analysis=splitA_int_init_ssh_reset   alias=int1

Reload BTS
    Run Keyword And Ignore Error       Perform Recommissioning    type=delta    delta_file=${DisableFLAG}        timeout=200

Verification with NMS
    Setup Ems    config_device=netact1042    alias=lab42
    Cm Upload    config_device=netact1042    alias=lab42
    Configuration Manage    config_device=netact1042    config=enable_params.json    plan_name=enable_ldap
    ...     delete_plan="True"   timeout=300   alias=lab42
    Teardown Ems    config_device=netact1042    alias=lab42


Get IPS for Intnodecombination
    Setup Remote Access     remote_device=SMO
    ${SMO_IP}=   Remote Command Execute     command=${smo_ip}
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
    ${MPLANE_IP}=   Remote Command Execute     command=${mplane_ip}  alias=bts
    Set Suite Variable  ${MPLANE_IP}    ${MPLANE_IP}
    Teardown Remote Access  alias=bts
    Setup Remote Access     remote_device=bts   alias=bbmod
    Execute Interactive Remote Command     command=${bbmod_login_primary}   alias=bbmod
    Execute Interactive Remote Command  command=${password1}  alias=bbmod
    ${output2}=    Execute Interactive Remote Command      command=${bbmod_ip}     alias=bbmod
    ${BBMOD_IP}=   Get Line    ${output2}   -2
    Teardown Remote Access  alias=bbmod
    Set Suite Variable  ${BBMOD_IP}     ${BBMOD_IP}

check routes in smo and int node for combination case
    Setup Remote Access     remote_device=SMO
    ${routes}=   Remote Command Execute     command=${route_check}
    ${status}=  Run Keyword And Return Status   Should Contain  ${routes}   ${INT_IP} via ${MPLANE_IP} dev
    ...     ${smo_interface}
    Teardown Remote Access
    Run Keyword If      '${status}'=='False'   Run Keywords    Setup Remote Access     remote_device=SMO
    ...   AND   Remote Command Execute     command=ip route add ${INT_IP} via ${MPLANE_IP} dev ${smo_interface}
    ...   AND   Teardown Remote Access
    Setup Remote Access     remote_device=int_node
    ${routes1}=   Remote Command Execute     command=${route_check}
    ${status1}=  Run Keyword And Return Status   Should Contain  ${routes1}   ${SMO_IP} via ${BBMOD_IP} dev
    ...     ${intnode_interface}
    Teardown Remote Access
    Run Keyword If      '${status1}'=='False'   Run Keywords    Setup Remote Access     remote_device=int_node
    ...     alias=intnode
    ...   AND   Remote Command Execute     command=ip route del ${SMO_IP}  alias=intnode
    ...   AND   Remote Command Execute     command=ip route add ${SMO_IP} via ${BBMOD_IP} dev ${intnode_interface}
    ...     alias=intnode
    ...   AND   Teardown Remote Access  alias=intnode
    Setup Remote Access     remote_device=int_node  alias=fh
    ${routes2}=   Remote Command Execute     command=${route_check}  alias=fh
    ${status2}=  Run Keyword And Return Status   Should Contain  ${routes2}   ${FH_IP} via ${BBMOD_IP} dev
    ...     ${intnode_interface}
    Teardown Remote Access
    Run Keyword If      '${status1}'=='False'   Run Keywords    Setup Remote Access     remote_device=int_node  alias=fh
    ...   AND   Remote Command Execute     command=ip route del ${FH_IP}  alias=fh
    ...   AND   Remote Command Execute     command=ip route add ${FH_IP} via ${BBMOD_IP} dev ${intnode_interface}  alias=fh
    ...   AND   Teardown Remote Access  alias=fh

SMO initiated traffic verification for combination case
    Traffic capture start           capture_device=int_enp6s0f0_120     alias=default
    Traffic Setup           device=SMO
    Run Keyword And Continue On Failure    Traffic Start   profile=smo_initiated_splitA
    ${filename}=  Traffic Capture Stop    capture_device=int_enp6s0f0_120    alias=default
    Analyse Pcap        pcap_filename=${filename}        analysis=splitA_smo_initiated
    Traffic Teardown   alias=default

intermediate node initiated traffic verification for combination case
    Traffic capture start           capture_device=SMO_enp6s0f0
    Traffic Setup           device=intnode_enp6s0f0_120
    Run Keyword And Continue On Failure    Traffic Start   profile=int_initiated_splitA
    ${filename}=  Traffic Capture Stop    capture_device=SMO_enp6s0f0
    Analyse Pcap        pcap_filename=${filename}        analysis=splitA_int_initiated
    Traffic Teardown   alias=default

SMO initiated SSH traffic verification for combination case
    Traffic capture start           capture_device=int_enp6s0f0_120     alias=smo
    Setup Remote Access     remote_device=SMO   alias=smo
    Remote Command Execute  command=ssh ${INT_IP}   alias=smo
    ${filename}=  Traffic Capture Stop    capture_device=int_enp6s0f0_120    alias=default  alias=smo
    Analyse Pcap        pcap_filename=${filename}        analysis=splitA_smo_init_ssh   alias=smo

intermediate node initiated SSH traffic verification for combination case
    Traffic capture start           capture_device=SMO_enp6s0f0     alias=int
    Setup Remote Access     remote_device=int_node      alias=int
    FOR    ${i}   IN RANGE  1   5
        Remote Command Execute  command=ssh ${SMO_IP}   alias=int
    END
    ${filename}=  Traffic Capture Stop    capture_device=SMO_enp6s0f0   alias=int
    Analyse Pcap        pcap_filename=${filename}        analysis=splitA_int_init_ssh   alias=int

GET IPS for ORUSec
    Setup Remote Access     remote_device=bts   alias=bts
    ${MPLANE_IP}=   Remote Command Execute     command=${mplane_RU_ip_COM}   alias=bts
    Set Suite Variable  ${MPLANE_IP}    ${MPLANE_IP}
    ${SMO}=      Get Parameter   param_path=${smo_ip_path}
    ${SMO_IP}=      Set Variable    ${SMO}[0]
    ${SMO_ip2}=      Set Variable    ${SMO_IP}[ipv6Address]
    Setup Remote Access     remote_device=secondary_vm   alias=sec_vm
    Execute Interactive Remote Command     command=${dut_login}     alias=sec_vm
    ${output2}=   Execute Interactive Remote Command     command=${oru2_ip}     alias=sec_vm
    ${ORU2_IP}=     Get Line    ${output2}  -2
    Teardown Remote Access  alias=sec_vm
    Set Suite Variable  ${ORU2_IP}  ${ORU2_IP}
    Set Suite Variable  ${SMO_ip2}  ${SMO_ip2}
    Set Suite Variable  ${MPLANE_IP}  ${MPLANE_IP}


SMO initiated traffic verification on 2nd ORU for combination case
    Traffic capture start           capture_device=ORU_ens6f1     alias=ORU2
    Traffic Setup           device=SMO     alias=ORU2
    Run Keyword And Continue On Failure    Traffic Start   profile=smo_initiated1   alias=ORU2
    ${filename}=  Traffic Capture Stop    capture_device=ORU_ens6f1    alias=ORU2
    Analyse Pcap        pcap_filename=${filename}        analysis=verify_smotraffic_ORU2_COM   alias=ORU2
    Traffic Teardown    alias=ORU2


ORU initiated traffic verification for combination case
    Traffic capture start           capture_device=SMO_enp6s0f0     alias=default
    Sleep    60
    ${filename}=  Traffic Capture Stop    capture_device=SMO_enp6s0f0   alias=default
    Analyse Pcap        pcap_filename=${filename}        analysis=verify_eventcontroller_COM

SSH traffic verification for combination case
    Traffic capture start           capture_device=SMO_enp6s0f0     alias=ssh
    Setup Remote Access     remote_device=ORU_simulator     alias=ssh1
    Execute Interactive Remote Command  command=${sudo}  alias=ssh1
    Execute Interactive Remote Command  command=${password}   alias=ssh1
    ${container2}=   Execute Interactive Remote Command    command=${ORU2_CONTAINER}    alias=ssh1
    ${container_ID2}=    Get Line   ${container2}     2
    @{SSH_ORU2}=    Create List     ssh_ORU2
    ${ssh2_cmd}=  Get Config Variable  ${SSH_ORU2}
    ${output2}=   Execute Interactive Remote Command  command=${ssh2_cmd}   alias=ssh1
    ${filename}=  Traffic Capture Stop    capture_device=l2_wireshark   alias=ssh
    Analyse Pcap        pcap_filename=${filename}        analysis=verify_ssh_ORU2_COM

Site Reset
    Reset   operation=reset_bts    should_be_onair=True    alias=default
    Sleep   300

SSH traffic verification after site reset
    Traffic capture start           capture_device=SMO_enp6s0f0     alias=ssh
    Setup Remote Access     remote_device=ORU_simulator     alias=ssh1
    Execute Interactive Remote Command  command=${sudo}  alias=ssh1
    Execute Interactive Remote Command  command=${password}   alias=ssh1
    ${container2}=   Execute Interactive Remote Command    command=${ORU2_CONTAINER}    alias=ssh1
    ${container_ID2}=    Get Line   ${container2}     2
    @{SSH_ORU2}=    Create List     ssh_ORU2
    ${ssh2_cmd}=  Get Config Variable  ${SSH_ORU2}
    ${output2}=   Execute Interactive Remote Command  command=${ssh2_cmd}   alias=ssh1
    ${filename}=  Traffic Capture Stop    capture_device=l2_wireshark   alias=ssh
    Analyse Pcap        pcap_filename=${filename}        analysis=verify_ssh_ORU2_COM

