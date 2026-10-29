*** Settings ***
Documentation
...     [Author]        "Mamtha Kshirsagar"
...     [Maintenance]   "TRS ET Bangalore Team"
...     [Procedure]     "The test case is planned to verify TCP traffic from SMO to ORU and viceversa, callhome from ORUand SSH traffic from ORU"
...     [Date]          "22-11-2022"
...     [Feature_ID]    "CB008016"
...     [Requirement ID]    "TT_TTSEC.2214;TT_TTSEC.2234;TT_TTSEC.2340;TT_IPT.3038;TT_IPT.3039;TT_IPT.3044;TT_IPT.3054;TT_IPT.3059"
...     [Config]    "This script requires ORU configuration, CB008016, CB007255 flags to be enabled."
...     [RunTime Parameters]    "bts_id used is 8016"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"
...     [Topology]              "ASIL+ABIO+ORU ASIL+ABIL+ORU Dual core setup with ORU"
...     [Function_Hash_Tags]    "Traffic, SSH , TCP"

Resource        ${CURDIR}/../resources/common_keywords.robot


Suite Setup     Run Keywords        Suite Setup Preconditions        AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions       AND     Teardown Oamops


*** Test Cases ***
[1][1.0]NAT based solution for Dual Core configuration to reach O-RU
     Perform Commissioning  scf_file=${splitj_scf}
     Sleep  700
     GET IPS
     SMO initiated traffic verification on 1st ORU
     SMO initiated traffic verification on 2nd ORU
     ORU initiated traffic verification
     SSH traffic verification

***keywords***
GET IPS
    Setup Remote Access     remote_device=bts   alias=bts
    ${MPLANE_IP}=   Remote Command Execute     command=${mplane_A_ip}   alias=bts
    Set Suite Variable  ${MPLANE_IP}    ${MPLANE_IP}
    Setup Remote Access     remote_device=SMO
    ${SMO_IP}=   Remote Command Execute     command=${SMO_IP}
    Teardown Remote Access
	Set Suite Variable      ${SMO_IP}    ${SMO_IP}
    ${output1}=   Execute Interactive Remote Command     command=${oru1_ip}     alias=bts
    ${ORU1_IP}=     Get Line    ${output1}  -2
    ${primary_port}=    Get Parameter   param_path=${primary_port_path}
    ${secondary_port}=    Get Parameter   param_path=${secondary_port_path}
    Teardown Remote Access  alias=bts
    Setup Remote Access     remote_device=secondary_vm   alias=sec_vm
    Execute Interactive Remote Command     command=${dut_login}     alias=sec_vm
    ${output2}=   Execute Interactive Remote Command     command=${oru2_ip}     alias=sec_vm
    ${ORU2_IP}=     Get Line    ${output2}  -2
    Teardown Remote Access  alias=sec_vm
    Set Suite Variable  ${ORU2_IP}  ${ORU2_IP}
    Set Suite Variable  ${ORU1_IP}  ${ORU1_IP}
    Set Suite Variable  ${MPLANE_IP}  ${MPLANE_IP}
    Set Suite Variable  ${secondary_port}   ${secondary_port}
    Set Suite Variable  ${primary_port}     ${primary_port}

SMO initiated traffic verification on 1st ORU
     Traffic capture start           capture_device=ORU_ens12f1     alias=default
     Traffic Setup           device=SMO_enp6s0f0
     Run Keyword And Continue On Failure    Traffic Start   profile=smo_initiated
     ${filename}=  Traffic Capture Stop    capture_device=ORU_ens12f1    alias=default
     Analyse Pcap        pcap_filename=${filename}        analysis=verify_smotraffic

SMO initiated traffic verification on 2nd ORU
    Traffic capture start           capture_device=ORU_ens12f0     alias=ORU2
    Traffic Setup           device=SMO_enp6s0f0     alias=ORU2
    Run Keyword And Continue On Failure    Traffic Start   profile=smo_initiated1   alias=ORU2
    ${filename}=  Traffic Capture Stop    capture_device=ORU_ens12f0    alias=ORU2
    Analyse Pcap        pcap_filename=${filename}        analysis=verify_smotraffic_ORU2     alias=ORU2
    Traffic Teardown
    Traffic Teardown    alias=ORU2

ORU initiated traffic verification
    Traffic capture start           capture_device=SMO_enp6s0f0     alias=default
    Sleep    60
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
     Analyse Pcap        pcap_filename=${filename}        analysis=verify_ssh

     Traffic capture start           capture_device=SMO_enp6s0f0     alias=ssh1
    Setup Remote Access     remote_device=ORU_simulator     alias=ssh1
    Execute Interactive Remote Command  command=${sudo}  alias=ssh1
    Execute Interactive Remote Command  command=${password}   alias=ssh1
    ${container2}=   Execute Interactive Remote Command    command=${ORU2_CONTAINER}    alias=ssh1
    ${container_ID2}=    Get Line   ${container2}     2
    @{SSH_ORU2}=    Create List     ssh_ORU2
    ${ssh2_cmd}=  Get Config Variable  ${SSH_ORU2}
    ${output2}=   Execute Interactive Remote Command  command=${ssh2_cmd}   alias=ssh1
    ${filename}=  Traffic Capture Stop    capture_device=SMO_enp6s0f0   alias=ssh1
#    Analyse Pcap        pcap_filename=${filename}        analysis=verify_ssh
    Analyse Pcap        pcap_filename=${filename}        analysis=verify_ssh_ORU2


