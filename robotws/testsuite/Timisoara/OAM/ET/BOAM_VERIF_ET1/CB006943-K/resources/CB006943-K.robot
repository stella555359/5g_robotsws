*** Settings ***
Documentation
...    Author: Razvan Purlea
...    Maintainer:razvan.purlea@nokia.com
...    Group in charge: MN
...    References: doors
...    Feature Description:
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_VERIF_ET1/CB006943-K/general_1.robot

Library         String
Library         Telnet
Library         OperatingSystem
Library         Process
Library         SeleniumLibrary
Library         SSHLibrary
Library         OperatingSystem
Library         pcapFiltering.py
Library         DateTime

Resource       ../../resources/admin.robot
Resource       ../../resources/pretest_posttest.robot
Resource       ../../resources/fault_trigger.robot

*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True
${SCF_path}=       ${CURDIR}/Configuration_ORAN_BfActive_4Beams_CellOnAir_scf.xml
${enb_web_alias}    ENB
${enb_admin_alias}  ADMIN
${OUT_MRBTS_ID}=    10616
${reasoning_path}=            /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/RMOD_L-1/RU_L-1
${cell_dist_name}=            MRBTS-${OUT_MRBTS_ID}/NRBTS-1/NRCELL-9
${O-RU_addr}=                    10.5.55.152
${VM_IPaddr}=                    10.5.25.167
${O-RU_username}=                user
${O-RU_password}=                Init_4321
${SYSTEM_ALIAS_ORU}=             oru
${USERNAME}     Nemuadmin
${PASSWORD}     nemuuser
#${outputPathPcap}=      /home/ute/test1-9.pcap
${Key_to_find}=         02:42:ac:11:00:02

${string_odu_encr_test1_test9}=         aes128-ctr,3des-cbc
${string_oru_encr_test1_test9}=         aes128-ctr,aes256-ctr,chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,3des-cbc
${string_odu_mac_test1_test9}=          hmac-sha2-256,hmac-sha1
${string_oru_mac_test1_test9}=          hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,hmac-sha1

${string_odu_encr_test2_test10}=         aes128-ctr,3des-cbc
${string_oru_encr_test2_test10}=         aes128-ctr
${string_odu_mac_test2_test10}=          hmac-sha2-256,hmac-sha1
${string_oru_mac_test2_test10}=          hmac-sha2-256

${string_odu_encr_test3_test11}=         aes128-ctr,3des-cbc
${string_oru_encr_test3_test11}=         3des-cbc
${string_odu_mac_test3_test11}=          hmac-sha2-256,hmac-sha1
${string_oru_mac_test3_test11}=          hmac-sha1


#${command_start_docker}  echo Init_4321 | sudo -S docker run --rm --name=orusim
#     ...    --volume=/home/user/docker_share/orusim:/etc/orusim --detach --privileged
#     ...    --network=bridge airphone-docker-local.artifactory-espoo1.int.net.nokia.com/netopeer2:airphone-o-ran-v1.20.20


${scf_6beams}=                ${CURDIR}/6beamsConfiguration_scf_MRBTS.xml
${scf_4beams}=                ${CURDIR}/4beamsConfiguration_scf_MRBTS.xml
${delta_file}=                ${CURDIR}/Delta_Configuration_beam4_5_delete.json
${sim_file_path_test1_test9}=             /etc/orusim/libssh_server_config_Test1-Test9
${sim_file_path_test2_test10}=             /etc/orusim/libssh_server_config_Test2-Test10
${sim_file_path_test3_test11}=             /etc/orusim/libssh_server_config_Test3-Test11
${sim_file_path_test4_alarm}=             /etc/orusim/libssh_server_config_Test4
${sim_file_path_test12_alarm}=             /etc/orusim/libssh_server_config_Test12




*** Keywords ***

#Bigger_Configured_beams_in_beam_mapping_table
#     Log to console  Check  O-RU is started
#     Check_and_Start_O-RU
#     Log to console  Perform Commissioning with 6 beams
#     ADMIN Perform Commissioning
#     ...     scf_file=${Scf_6beams}
#     ...     skip_parameter_relation_errors=True
#     Wait Until Keyword Succeeds  240  20    ADMIN Check BTS Configured
#     Wait Until Keyword Succeeds  240  20    ADMIN Check If Alarm Is Active  fault_id=4664
#
### *** To remain with 4 Beams -> Delete Beam4 and Beam5
### *** Also set basicBeamSet=beamSet_4 and numberOfTransmittedSsBlocks=4 beams
#
#     ADMIN Perform Delta Recommissioning     ${delta_file}  True
### *** ${skip_parameter_relation_errors} =True should be deleted when all HW errors will be cleared
#
#     ADMIN Lock Cell   ${cell_dist_name}
#     ADMIN Unlock Cell   ${cell_dist_name}
#     Wait Until Keyword Succeeds  300  20    ADMIN Check BTS onair

Test1_Test9
     Log to console  Check  O-RU is started
     Check_and_Start_O-RU
     Configure SSH server for Test1_Test9
     log to console   O-DU is restarting...
     ADMIN Reset Site
     log to console  O-DU restarted.
     Capture pcap for test1_test9
     Copy test1_test9 pcap logs to VM
     log to console   Waiting for the cell to be on air...
     Wait Until Keyword Succeeds  300  20    ADMIN Check BTS onair
     log to console   Cell is on air.
     Analyze PCAP log for test1_test9      ${string_odu_encr_test1_test9}   2
     Analyze PCAP log for test1_test9      ${string_oru_encr_test1_test9}   2
     Analyze PCAP log for test1_test9      ${string_odu_mac_test1_test9}    4
     Analyze PCAP log for test1_test9      ${string_oru_mac_test1_test9}    2

Test2_Test10
    Log to console  Check  O-RU is started
    Check_and_Start_O-RU
    Configure SSH server for Test2_Test10
    log to console   O-DU is restarting...
    ADMIN Reset Site
    log to console  O-DU restarted.
    Capture pcap for test2_test10
    Copy test2_test10 pcap logs to VM
    log to console   Waiting for the cell to be on air...
    Wait Until Keyword Succeeds  300  20    ADMIN Check BTS onair
    log to console   Cell is on air.
    Analyze PCAP log for test2_test10       ${string_odu_encr_test2_test10}  2
    Analyze PCAP log for test2_test10       ${string_oru_encr_test2_test10}  4
    Analyze PCAP log for test2_test10      ${string_odu_mac_test2_test10}    2
    Analyze PCAP log for test2_test10       ${string_oru_mac_test2_test10}   4

Test3_Test11
    Log to console  Check  O-RU is started
    Check_and_Start_O-RU
    Configure SSH server for Test3_Test11
    log to console   O-DU is restarting...
    ADMIN Reset Site
    log to console  O-DU restarted.
    Capture pcap for test3_test11
    Copy test3_test11 pcap logs to VM
    log to console   Waiting for the cell to be on air...
    Wait Until Keyword Succeeds  300  20    ADMIN Check BTS onair
    log to console   Cell is on air.
    Analyze PCAP log for test3_test11       ${string_odu_encr_test3_test11}  2
    Analyze PCAP log for test3_test11       ${string_oru_encr_test3_test11}  4
    Analyze PCAP log for test3_test11      ${string_odu_mac_test3_test11}    2
    Analyze PCAP log for test3_test11       ${string_oru_mac_test3_test11}   4

Test4
    Log to console  Check  O-RU is started
    Check_and_Start_O-RU
    Configure SSH server for Test4
    log to console   O-DU is restarting...
    ADMIN Reset Site
    log to console  O-DU restarted.
    Capture pcap for test4
    Copy test4 pcap logs to VM
    Wait Until Keyword Succeeds  240  20    ADMIN Check If Alarm Is Active  fault_id=4640
    log to console   Fault ID 4640 is visible due to encryption algorithm negotiation failure
    sleep    60
    Configure SSH server for Test1_Test9
    Wait Until Keyword Succeeds   240  20   ADMIN Is Alarm in Historical Alarms  fault_id=4640
    log to console   FID 4640 is cleared!
    log to console   Restoring default SSH server configuration... Done. Now, waiting for the cell to be on air...
    Wait Until Keyword Succeeds  300  20    ADMIN Check BTS onair
    log to console   Cell is on air.

Test12
    Log to console  Check  O-RU is started
    Check_and_Start_O-RU
    Configure SSH server for Test4
    log to console   O-DU is restarting...
    ADMIN Reset Site
    log to console  O-DU restarted.
    Capture pcap for test12
    Copy test12 pcap logs to VM
    Wait Until Keyword Succeeds  240  20    ADMIN Check If Alarm Is Active  fault_id=4640
    log to console   Fault ID 4640 is visible due to MAC algorithm negotiation failure
    sleep   60
    Configure SSH server for Test1_Test9
    Wait Until Keyword Succeeds   240  20   ADMIN Is Alarm in Historical Alarms  fault_id=4640
    log to console    FID 4640 is cleared!
    log to console   Restoring default SSH server configuration... Done. Now, waiting for the cell to be on air...
    Wait Until Keyword Succeeds  300  20    ADMIN Check BTS onair
    log to console   Cell is on air.


#     ADMIN Perform Commissioning
#     ...     scf_file=${Scf_4beams}
#     ...     skip_parameter_relation_errors=True
#     Wait Until Keyword Succeeds  600  30    ADMIN Check BTS On Air

Mute_beams_if_number_bigger_than_supported
     Log to console  Check  O-RU is started
     Check_and_Start_O-RU
    ADMIN Perform Commissioning
     ...     scf_file=${Scf_6beams}
     ...     skip_parameter_relation_errors=True
    Wait Until Keyword Succeeds  240  20    ADMIN Check BTS Configured
    ADMIN Perform Delta Recommissioning     ${delta_file_beams_mute}  True
## *** ${skip_parameter_relation_errors} =True should be deleted when all HW errors will be cleared

     ADMIN Lock Cell   ${cell_dist_name}
     ADMIN Unlock Cell   ${cell_dist_name}
     Wait Until Keyword Succeeds  300  20    ADMIN Check BTS onair

Check_and_Start_O-RU

## *** Check if O-RU is started
     ${reply}=  SYSTEM Start Command On o-ru
     ...    command=echo Init_4321 | sudo -S docker ps -a     #sudo docker ps -a
     Log to console  ${reply}

## *** If O-RU is not started ... START O-RU !
     ${status}    Run Keyword And Return Status  Should contain  ${reply}  airphone-docker
     Log to console  O-RU status check is :${status}

     Run Keyword If  '${status}' == 'True'
     ...   Log to console  O-RU already started !
     ...   ELSE IF   '${status}' == 'False'
     ...   SYSTEM Start Command On o-ru  command=${command_start_docker}
     ...   ELSE
     ...   Log to console  Wrong status !

        Sleep  20
## *** If O-RU is not started => fail !
        ${reply}=  SYSTEM Start Command On o-ru
        ...    command=echo Init_4321 | sudo -S docker ps -a     #sudo docker ps -a
        Log to console  ${reply}
        Should contain  ${reply}  airphone-docker

     Log to console  O-RU started successfully!


Connect_to_O-RU

     ${reply}=  SYSTEM Start Command On o-ru
     ...    command=${command_start_docker}  #Start docker
     Log to console  ${reply}
     Sleep  20
     ${reply}=  SYSTEM Start Command On o-ru
     ...    command=echo Init_4321 | sudo -S docker ps -a     #sudo docker ps -a
     Log to console  ${reply}
     Should contain  ${reply}  airphone-docker
     Sleep  20
     ${reply}=  SYSTEM Start Command On o-ru
     ...    command=echo Init_4321 | sudo -S docker stop orusim    #sudo docker kill orusim
    Log to console  ${reply}
    SeleniumLibrary.Close Browser


SYSTEM Start Command On o-ru
    [Arguments]    ${command}
    ...            ${hostname}=${O-RU_addr}
    ...            ${username}=${O-RU_username}
    ...            ${password}=${O-RU_password}
    ...            ${alias}=${SYSTEM_ALIAS_ORU}
    taf.transport.ssh.connect_to
    ...    hostname=${hostname}
    ...    username=${username}
    ...    password=${password}
    ...    alias=${alias}
     ${reply}=  taf.transport.ssh.execute
    ...    command=${command}
    ...    connection=${alias}
    [Return]    ${reply}

Configure SSH server for Test1_Test9
     SYSTEM Open SSH Connection To o-ru
     log to console   Configuring SSH server for required MAC and ciphering algos...
     SSHLibrary.Write            sudo docker exec -it orusim /bin/bash
     SSHLibrary.Read Until       password for user:
     SSHLibrary.Write            Init_4321
     SSHLibrary.Read Until       :/opt/dev#
#      ...   SSHlib.command=echo Init_4321 | sudo docker exec -it orusim /bin/bash
#      Log to console  ${reply}
#      log to console  Configuring SSH server to support both options for MAC and ciphering...
      SSHLibrary.Write          cp ${sim_file_path_test1_test9} /etc/ssh/libssh_server_config
      log to console   SSH server configured successfully.
#      Log to console  ${reply}

Configure SSH server for Test2_Test10
     SYSTEM Open SSH Connection To o-ru
     log to console   Configuring SSH server for required MAC and ciphering algos...
     SSHLibrary.Write            sudo docker exec -it orusim /bin/bash
     SSHLibrary.Read Until       password for user:
     SSHLibrary.Write            Init_4321
     SSHLibrary.Read Until       :/opt/dev#
#      ...   SSHlib.command=echo Init_4321 | sudo docker exec -it orusim /bin/bash
#      Log to console  ${reply}
#      log to console  Configuring SSH server to support both options for MAC and ciphering...
      SSHLibrary.Write          cp ${sim_file_path_test2_test10} /etc/ssh/libssh_server_config
      log to console   SSH server configured successfully.
#      Log to console  ${reply}

Configure SSH server for Test3_Test11
     SYSTEM Open SSH Connection To o-ru
     log to console   Configuring SSH server for required MAC and ciphering algos...
     SSHLibrary.Write            sudo docker exec -it orusim /bin/bash
     SSHLibrary.Read Until       password for user:
     SSHLibrary.Write            Init_4321
     SSHLibrary.Read Until       :/opt/dev#
#      ...   SSHlib.command=echo Init_4321 | sudo docker exec -it orusim /bin/bash
#      Log to console  ${reply}
#      log to console  Configuring SSH server to support both options for MAC and ciphering...
      SSHLibrary.Write          cp ${sim_file_path_test3_test11} /etc/ssh/libssh_server_config
      log to console   SSH server configured successfully.
#      Log to console  ${reply}

Configure SSH server for Test4
     SYSTEM Open SSH Connection To o-ru
     log to console   Configuring SSH server for required MAC and ciphering algos...
     SSHLibrary.Write            sudo docker exec -it orusim /bin/bash
     SSHLibrary.Read Until       password for user:
     SSHLibrary.Write            Init_4321
     SSHLibrary.Read Until       :/opt/dev#
#      ...   SSHlib.command=echo Init_4321 | sudo docker exec -it orusim /bin/bash
#      Log to console  ${reply}
#      log to console  Configuring SSH server to support both options for MAC and ciphering...
      SSHLibrary.Write          cp ${sim_file_path_test4_alarm} /etc/ssh/libssh_server_config
      log to console   SSH server configured successfully.

Configure SSH server for Test12
     SYSTEM Open SSH Connection To o-ru
     log to console   Configuring SSH server for required MAC and ciphering algos...
     SSHLibrary.Write            sudo docker exec -it orusim /bin/bash
     SSHLibrary.Read Until       password for user:
     SSHLibrary.Write            Init_4321
     SSHLibrary.Read Until       :/opt/dev#
#      ...   SSHlib.command=echo Init_4321 | sudo docker exec -it orusim /bin/bash
#      Log to console  ${reply}
#      log to console  Configuring SSH server to support both options for MAC and ciphering...
      SSHLibrary.Write          cp ${sim_file_path_test12_alarm} /etc/ssh/libssh_server_config
      log to console   SSH server configured successfully.
SYSTEM Open SSH Connection To o-ru
    SYSTEM Open SSH Connection    host=${O-RU_addr}
    ...                           port=22
    ...                           username=${O-RU_username}
    ...                           password=${O-RU_password}
    ...                           alias=oru

SYSTEM Open SSH Connection
    [Arguments]    ${host}    ${port}    ${username}    ${password}    ${alias}
    SSHLibrary.Open Connection    host=${host}    port=${port}    timeout=20    alias=${alias}
    SSHLibrary.Login    username=${username}    password=${password}    delay=1s

Capture pcap for test1_test9
    SYSTEM Open SSH Connection To o-ru
    log to console   Start capturing pcap logs...
    SSHLibrary.Write            sudo tcpdump -i enp1s0f0 -c 10000 -w /home/user/logs/test1-9.pcap -e -nn |grep SSH
    #SSHLibrary.Write            sudo tcpdump -i enp1s0f0 -c 10000  -A -r /home/user/logs/test1-9.pcap>/home/user/logs/test1-9.txt
    SSHLibrary.Read Until       password for user:
    SSHLibrary.Write            Init_4321
    log to console   Pcap logs are being collected...
    sleep   80
    log to console   PCAP logs captured

Capture pcap for test2_test10
    SYSTEM Open SSH Connection To o-ru
    log to console   Start capturing pcap logs...
    SSHLibrary.Write            sudo tcpdump -i enp1s0f0 -c 10000 -w /home/user/logs/test2-10.pcap -e -nn |grep SSH
    #SSHLibrary.Write            sudo tcpdump -i enp1s0f0 -c 10000  -A -r /home/user/logs/test1-9.pcap>/home/user/logs/test1-9.txt
    SSHLibrary.Read Until       password for user:
    SSHLibrary.Write            Init_4321
    log to console   Pcap logs are being collected...
    sleep   80
    log to console   PCAP logs captured

Capture pcap for test3_test11
    SYSTEM Open SSH Connection To o-ru
    log to console   Start capturing pcap logs...
    SSHLibrary.Write            sudo tcpdump -i enp1s0f0 -c 10000 -w /home/user/logs/test3-11.pcap -e -nn |grep SSH
    #SSHLibrary.Write            sudo tcpdump -i enp1s0f0 -c 10000  -A -r /home/user/logs/test1-9.pcap>/home/user/logs/test1-9.txt
    SSHLibrary.Read Until       password for user:
    SSHLibrary.Write            Init_4321
    log to console   Pcap logs are being collected...
    sleep   80
    log to console   PCAP logs captured

Capture pcap for test4
    SYSTEM Open SSH Connection To o-ru
    log to console   Start capturing pcap logs...
    SSHLibrary.Write            sudo tcpdump -i enp1s0f0 -c 10000 -w /home/user/logs/test4.pcap -e -nn |grep SSH
    #SSHLibrary.Write            sudo tcpdump -i enp1s0f0 -c 10000  -A -r /home/user/logs/test1-9.pcap>/home/user/logs/test1-9.txt
    SSHLibrary.Read Until       password for user:
    SSHLibrary.Write            Init_4321
    log to console   Pcap logs are being collected...
    sleep   80
    log to console   PCAP logs captured

Capture pcap for test12
    SYSTEM Open SSH Connection To o-ru
    log to console   Start capturing pcap logs...
    SSHLibrary.Write            sudo tcpdump -i enp1s0f0 -c 10000 -w /home/user/logs/test12.pcap -e -nn |grep SSH
    #SSHLibrary.Write            sudo tcpdump -i enp1s0f0 -c 10000  -A -r /home/user/logs/test1-9.pcap>/home/user/logs/test1-9.txt
    SSHLibrary.Read Until       password for user:
    SSHLibrary.Write            Init_4321
    log to console   Pcap logs are being collected...
    sleep   80
    log to console   PCAP logs captured

Copy test1_test9 pcap logs to VM
    log to console   Copying the pcap logs from O-RU to VM for analysis...
    SYSTEM Open SSH Connection To o-ru
    SSHLibrary.Write            scp /home/user/logs/test1-9.pcap ute@${VM_IPaddr}:/home/ute
    SSHLibrary.Read Until       ute@${VM_IPaddr}'s password:
    SSHLibrary.Write            ute
    log to console   Pcap logs copied successfully.

Copy test2_test10 pcap logs to VM
    log to console   Copying the pcap logs from O-RU to VM for analysis...
    SYSTEM Open SSH Connection To o-ru
    SSHLibrary.Write            scp /home/user/logs/test2-10.pcap ute@${VM_IPaddr}:/home/ute
    SSHLibrary.Read Until       ute@${VM_IPaddr}'s password:
    SSHLibrary.Write            ute
    log to console   Pcap logs copied successfully.

Copy test3_test11 pcap logs to VM
    log to console   Copying the pcap logs from O-RU to VM for analysis...
    SYSTEM Open SSH Connection To o-ru
    SSHLibrary.Write            scp /home/user/logs/test3-11.pcap ute@${VM_IPaddr}:/home/ute
    SSHLibrary.Read Until       ute@${VM_IPaddr}'s password:
    SSHLibrary.Write            ute
    log to console   Pcap logs copied successfully.

Copy test4 pcap logs to VM
    log to console   Copying the pcap logs from O-RU to VM for analysis...
    SYSTEM Open SSH Connection To o-ru
    SSHLibrary.Write            scp /home/user/logs/test4.pcap ute@${VM_IPaddr}:/home/ute
    SSHLibrary.Read Until       ute@${VM_IPaddr}'s password:
    SSHLibrary.Write            ute
    log to console   Pcap logs copied successfully.

Copy test12 pcap logs to VM
    log to console   Copying the pcap logs from O-RU to VM for analysis...
    SYSTEM Open SSH Connection To o-ru
    SSHLibrary.Write            scp /home/user/logs/test12.pcap ute@${VM_IPaddr}:/home/ute
    SSHLibrary.Read Until       ute@${VM_IPaddr}'s password:
    SSHLibrary.Write            ute
    log to console   Pcap logs copied successfully.

Stop O-RU
    SYSTEM Open SSH Connection To o-ru
    SSHLibrary.Write            sudo docker exec -it orusim /bin/bash
    SSHLibrary.Read Until       password for user:
    SSHLibrary.Write            Init_4321
    SSHLibrary.Read Until       :/opt/dev#
    SSHLibrary.Write            supervisorctl stop all
    SSHLibrary.Read Until       orusw: stopped
    SSHLibrary.Write            exit
    Wait Until Keyword Succeeds  240  20    ADMIN Check If Alarm Is Active  fault_id=10
    log to console   O-RU is stopped and FID 10 occured...

Start O-RU
    SYSTEM Open SSH Connection To o-ru
    SSHLibrary.Write            sudo docker exec -it orusim /bin/bash
    SSHLibrary.Read Until       password for user:
    SSHLibrary.Write            Init_4321
    SSHLibrary.Read Until       :/opt/dev#
    SSHLibrary.Write            supervisorctl start all
    #Wait Until Keyword Succeeds  300  20    ADMIN Check BTS onair
    #Wait Until Keyword Succeeds  240  20    ADMIN Check If Alarm Is Active  fault_id=10
    #log to console   O-RU is started and cell is onair...

Analyze PCAP log for test1_test9
    [Arguments]
    ...                           ${string_to_search}=default
    ...                           ${nr_of_strings}=2
    ${count1}=  Run   strings ~/test1-9.pcap | grep -c "${string_to_search}"
    log to console  ${count1}
    Run Keyword If      '${count1}' == '${nr_of_strings}'
    ...   log to console  ${string_to_search} is ${count1} - PASS
	...   ELSE
    ...   Fail       String: ${string_to_search} id different from ${nr_of_strings} - FAIL.

#    write  strings test1-9.pcap | grep -c "a${string_oru_encr_test1_test9}"
#    write  strings test1-9.pcap | grep -c "a${string_odu_mac_test1_test9}"
#    write  strings test1-9.pcap | grep -c "a${string_oru_mac_test1_test9}"

Analyze PCAP log for test2_test10
    [Arguments]
    ...                           ${string_to_search}=default
    ...                           ${nr_of_strings}=2
    ${count1}=  Run   strings ~/test2-10.pcap | grep -c "${string_to_search}"
    log to console  ${count1}
    Run Keyword If      '${count1}' == '${nr_of_strings}'
    ...   log to console  ${string_to_search} is ${count1} - PASS
	...   ELSE
    ...   Fail       String: ${string_to_search} is different from ${nr_of_strings} - FAIL.

Analyze PCAP log for test3_test11
    [Arguments]
    ...                           ${string_to_search}=default
    ...                           ${nr_of_strings}=2
    ${count1}=  Run   strings ~/test3-11.pcap | grep -c "${string_to_search}"
    log to console  ${count1}
    Run Keyword If      '${count1}' == '${nr_of_strings}'
    ...   log to console  ${string_to_search} is ${count1} - PASS
	...   ELSE
    ...   Fail       String: ${string_to_search} is different from ${nr_of_strings} - FAIL.
