*** Settings ***
Documentation
...  Author: Coras Denisa-Maria (denisa.coras@nokia.com)
...  Maintainer: Coras Denisa-Maria (denisa.coras@nokia.com)
...  Group in charge: MANO_SOAM3
...  References: doors
...  Feature Description:5GC002399-A-a3


Library    SSHLibrary
Library    string
Library    collections
Library    Selenium2Library
Library    XML  lxml=True
Library    Process
Library    taf.sbts.oam.coam.admin

Resource    ../../../resources/system.robot
Resource   ../../../resources/admin.robot

*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True
${address}=                      192.168.255.129

${scf_name}                      scf_file.xml


*** Keywords ***

5GC002399-A-a3_BTS_commissioning_L2RT
    log to console  Start test BTS commissioning L2RT
   ADMIN Collect Scf
    ...             ${OUTPUT_DIR}
    ...             ${scf_name}
    ...             120
    OperatingSystem.File Should Exist     ${OUTPUT_DIR}/${scf_name}
    File Should Not Be Empty              ${OUTPUT_DIR}/${scf_name}
    log to console   perform commissioning  on BTS
    taf.sbts.oam.coam.admin.Perform Commissioning
    ...             scf_file=${OUTPUT_DIR}/${scf_name}
    ...             skip_parameter_relation_errors=true
    Wait Until Keyword Succeeds   300   10
    ...             Ping Mplane
    Wait Until Keyword Succeeds   500   25
    ...             Check If BTS Configured
    Sleep  100
    Verify L2RT container is reachable and running
#    Verify L2RT container is reachable
    log to console  L2RT container is up and running


Ping Mplane
	FOR	${i}	IN RANGE	0	3
         ${output}=  Run  ping -c 5 192.168.255.129
    	  Should contain  	${output}  	5 packets transmitted, 5 received
    END

Check If BTS Configured
    ${bts_statuses_response}=    taf.sbts.oam.coam.admin.Get Bts Info
    ${actual_value}=             Get From Dictionary
    ...    dictionary=${bts_statuses_response['status']}
    ...    key=proceduralState
    Should Be Equal
    ...    first=${actual_value}
    ...    second=Configured

Verify L2RT container is reachable and running
    Open SSH connection
    SSHLibrary.Write            bsh 1:0
    SSHLibrary.Read Until       :~ >
    SSHLibrary.Write    lxc-ls
    ${virtual_node}  SSHLibrary.Read Until    expected=>
    Should contain  ${virtual_node}   0x1730
    SSHLibrary.Write    lxc-info -n0x1730
    ${node_state}  SSHLibrary.Read until  expected=PID:
    Should contain    ${node_state}  RUNNING
    SSHLibrary.Close Connection

Open SSH connection
    SSHLibrary.Open Connection    host=192.168.255.1    port=22    timeout=60
    SSHLibrary.Login    username=toor4nsn    password=oZPS0POrRieRtu    delay=1s

