*** Settings ***
Documentation    Suite for CB009233 and CB013432 Wireless LMP testcases for ASOF, ASOH.
...              author:    Patryk Tatarek
...              contact:   patryk.tatarek@nokia.com

Resource       ../../common_resources/admin/admin.robot
Resource       ../../common_resources/connections/connections.robot
Resource       ../../common_resources/commissioning/parameters.robot

Library        taf.sbts.oam.coam.admin      WITH NAME   coam_admin
Library        taf.transport.ssh            WITH NAME   ssh
Library        ./Wifi_Keywords.py       WITH NAME   9233

*** Variables ***
${TestPC_IP}=    192.168.255.36

*** Keywords ***
Enable Wi-fi on BTS
    Change Parameter On BTS     dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...                         param_name=actWifiLmp
    ...                         param_value=Enable

Disable Wi-Fi on BTS
    Change Parameter On BTS     dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...                         param_name=actWifiLmp
    ...                         param_value=Disable

Restart Wi-Fi on BTS and TestPC
    ${connection}=  Connect To TestPC
    Log    Restarting Wi-Fi on BTS...    console=${TRUE}
    Disable Wi-Fi on BTS
    Sleep    60s    reason=Seit reset is ongoing
    Wait until Keyword Succeeds    5x    30s    Enable Wi-Fi on BTS
    Sleep    30sec
    Log    Restarting NetworkManager...    console=${TRUE}
    ${console_output}=  ssh.Execute  command=sudo systemctl restart NetworkManager &
    ...                              connection=${connection}
    Sleep    30sec
    [Teardown]    Disconnect From TestPC   connection=${connection}

Connect To Wi-Fi Over CLI
    [Arguments]    ${SSID}  ${network_password}  ${network_interface}
    ${connection}=  Connect To TestPC
    Log  List available network interfaces  console=${TRUE}
    ${console_output}=  ssh.Execute  command=nmcli device
    ...                              connection=${connection}
    Log  ${console_output}  console=${TRUE}
    Should Contain  ${console_output}  ${network_interface}
    Log  Network interface detected  console=${TRUE}

    Log  List available wi-fi networks  console=${TRUE}
    ${console_output}=  ssh.Execute  command=nmcli device wifi list | cat
    ...                              connection=${connection}
    Log  ${console_output}  console=${TRUE}
    Should Contain  ${console_output}  ${SSID}
    Log  Network (${SSID}) is visible  console=${TRUE}

    Log  Connecting to ${SSID} network...  console=${TRUE}
    ${console_output}=  ssh.Execute  command=sudo nmcli device wifi connect ${SSID} password ${network_password}
    ...                              connection=${connection}
    Log  ${console_output}  console=${TRUE}
    Should Contain  ${console_output}  successfully activated
    Log  Successfuly conntected to ${SSID} network  console=${TRUE}
    [Teardown]    Disconnect From TestPC   connection=${connection}

Connect To BTS Wi-Fi Network
    [Arguments]    ${JSON_PATH}    ${SSID}  ${username}  ${network_interface}=wlan0
    ${connection}=  Connect To TestPC
    ${network_password}=  9233.get_factory_user_password  ${JSON_PATH}    ${BTS_ID}  ${username}
    Log  Start NetworkManager  console=${TRUE}
    ssh.Execute  command=sudo systemctl status NetworkManager &
    ...          connection=${connection}
    FOR  ${attempt}  IN RANGE    10
        Log    Login attempt: ${attempt+1}    console=${TRUE}
        ${status}=    Run Keyword And Return Status    Connect To Wi-fi Over CLI    ${SSID}
        ...                                                                         ${network_password}
        ...                                                                         ${network_interface}
        Set Test Variable    ${connection_status}    ${status}
        Exit For Loop If    '${status}'=='True'
        Restart Wi-Fi on BTS and TestPC
    END
    Should Be True    ${connection_status}
    [Teardown]    Disconnect From TestPC   connection=${connection}

Connect To BTS Wi-Fi Network Without Repetitions
    [Arguments]    ${JSON_PATH}    ${SSID}  ${username}  ${network_interface}=wlan0
    ${connection}=  Connect To TestPC
    ${network_password}=  9233.get_factory_user_password  ${JSON_PATH}    ${BTS_ID}  ${username}
    Log  Start NetworkManager  console=${TRUE}
    ssh.Execute  command=sudo systemctl status NetworkManager &
    ...          connection=${connection}
    Log  List available network interfaces  console=${TRUE}
    ${console_output}=  ssh.Execute  command=nmcli device
    ...                              connection=${connection}
    Log  ${console_output}  console=${TRUE}
    Should Contain  ${console_output}  ${network_interface}
    Log  Network interface detected  console=${TRUE}

    Log  List available wi-fi networks  console=${TRUE}
    ${console_output}=  ssh.Execute  command=nmcli device wifi list | cat
    ...                              connection=${connection}
    Log  ${console_output}  console=${TRUE}
    Should Contain  ${console_output}  ${SSID}
    Log  Network (${SSID}) is visible  console=${TRUE}

    Log  Connect to ${SSID} network  console=${TRUE}
    ${console_output}=  ssh.Execute  command=sudo nmcli device wifi connect ${SSID} password ${network_password}
    ...                              connection=${connection}
    Log  ${console_output}  console=${TRUE}
    Should Contain  ${console_output}  successfully activated
    Log  Successfuly conntected to ${SSID} network  console=${TRUE}
    [Teardown]    Disconnect From TestPC   connection=${connection}

Disconnect From BTS Wi-Fi Network
    [Arguments]    ${SSID}
    ${connection}=    Connect To TestPC
    Log  Disconnecting from ${SSID} network   console=${TRUE}
    ssh.Execute  command=sudo nmcli connection down id ${SSID}
    ...          connection=${connection}
    Log  Disconnected!  console=${TRUE}
    [Teardown]    Disconnect from BTS    connection=${connection}

Connect To TestPC
    [Arguments]    ${username}=kali   ${password}=kali
    ${testpc_address}=    get_testpc_address    ${BTS_ID}
    ${connection}=  ssh.Connect To    hostname=${testpc_address}
    ...                               username=${username}
    ...                               password=${password}
    [Return]   ${connection}

Connect To BTS Over Wi-Fi
    [Arguments]    ${JSON_PATH}    ${SSID}    ${username}
#    ${password}=  9233.get_factory_user_password  ${BTS_ID}  ${username}
    Connect To BTS Wi-Fi Network  JSON_PATH=${JSON_PATH}    SSID=${SSID}  username=${username}
    ${proxy_connection}=  Connect To TestPC
    ${connection}=  Connect To BTS  ip_address=192.168.255.36    proxy=${proxy_connection}
    [Return]    ${connection}

Disconnect From BTS Over Wi-Fi
    [Arguments]    ${connection}
    Disconnect From BTS    connection=${connection}

Disconnect From TestPC
    [Arguments]    ${connection}
    ssh.Disconnect    connection=${connection}

Check File Permissions And Owner And Usergroup
    [Arguments]    ${filepath}    ${permissions}    ${owner}    ${usergroup}    ${connection}
    Log     Checking: ${filepath}  console=${TRUE}
    ${console_output}=  ssh.Execute  command=ls -l ${filepath}
    ...                              connection=${connection}
    Should Contain  ${console_output}  ${permissions}

    ${console_output}=  ssh.Execute  command=ls -l ${filepath} | cut -d " " -f 3
    ...                              connection=${connection}
    Should Contain  ${console_output}    ${owner}

    ${console_output}=  ssh.Execute  command=ls -l ${filepath} | cut -d " " -f 4
    ...                              connection=${connection}
    Should Contain  ${console_output}    ${usergroup}

Check Process UID
    [Arguments]    ${filepath}    ${uid}    ${connection}
    Log     Checking: ${filepath}  console=${TRUE}
    ${console_output}=  ssh.Execute  command=ps aux | grep ${filepath}
    ...                              connection=${connection}
    Should Contain  ${console_output}  ${uid}

Check File Owner And Usergroup In Directory
    [Arguments]    ${dirpath}    ${owner_and_usergroup}    ${connection}
    Log  Checking: ${dirpath}  console=${TRUE}
    ${number_of_files}=  ssh.Execute  command=ls -l ${dirpath} | tail -n +2 | wc -l
    ...                               connection=${connection}
    ${num_of_owner_usergroup_occurs}=  ssh.Execute  command=ls -l ${dirpath} | grep -o ${owner_and_usergroup} | wc -l
    ...                                             connection=${connection}
    ${compare}=    Evaluate     bool((${number_of_files}*2)==${num_of_owner_usergroup_occurs})
    Should Be True    ${compare}

Disable Auto Connect To Wi-Fi Network
    [Arguments]    ${SSID}
    ${connection}=    Connect To TestPC
    ${console_output}=    ssh.Execute    command=sudo nmcli connection modify "${SSID}" connection.autoconnect no
    ...                                  connection=${connection}
    Should Be Empty  ${console_output}
    [Teardown]    Disconnect From TestPC    connection=${connection}

Disable Auto Connect To Wi-Fi Network For All SSIDs
    [Arguments]    ${JSON_PATH}
    ${all_ssids}=    9233.get_all_ssids    ${JSON_PATH}    ${BTS_ID}
    FOR    ${ssid}    IN    @{all_ssids}
        Disable Auto Connect To Wi-Fi Network    SSID=${ssid}
    END

Set Wi-Fi Card To Managed Mode
    [Arguments]    ${interface}=wlan0
    ${connection}=    Connect To TestPC
    ${console_output}=    ssh.Execute    command=sudo ip link set ${interface} down    connection=${connection}
    Should Be Empty    ${console_output}
    ${console_output}=    ssh.Execute    command=sudo iw ${interface} set type managed    connection=${connection}
    Should Be Empty    ${console_output}
    ${console_output}=    ssh.Execute    command=sudo ip link set ${interface} up    connection=${connection}
    Should Be Empty    ${console_output}
    ${console_output}=    ssh.Execute    command=sudo nmcli device set ${interface} managed yes    connection=${connection}
    Should Be Empty    ${console_output}
    Log    Wi-Fi Card has been set to Managed Mode    console=${TRUE}
    [Teardown]    Disconnect From TestPC    connection=${connection}

Set Wi-Fi Card To Monitor Mode
    [Arguments]    ${interface}=wlan0
    ${connection}=    Connect To TestPC
    ${console_output}=    ssh.Execute    command=sudo ip link set ${interface} down    connection=${connection}
    Should Be Empty    ${console_output}
    ${console_output}=    ssh.Execute    command=sudo iw ${interface} set monitor none    connection=${connection}
    Should Be Empty    ${console_output}
    ${console_output}=    ssh.Execute    command=sudo ip link set ${interface} up    connection=${connection}
    Should Be Empty    ${console_output}
    Log    Wi-Fi Card has been set to Monitor Mode    console=${TRUE}
    [Teardown]    Disconnect From TestPC    connection=${connection}

Add New Wi-Fi User
    [Arguments]    ${output_filepath}=/home/ute/CB0092333_wifi_user_test.xml  ${auth_type}=WPA2-PSK
    ...            ${mac_addr_qualifier}=  ${passphrase}=userName1!dddddddddd
    ...            ${userlabel}=user  ${wpa3_sae_pwid_qualifier}=
    ${connection}=    Connect to ADMIN
    ${filepath}=  9233.prepare_new_user_xml  output_filepath=${output_filepath}
    ...                                      auth_type=${auth_type}
    ...                                      mac_addr_qualifier=${mac_addr_qualifier}
    ...                                      passphrase=${passphrase}
    ...                                      userlabel=${userlabel}
    ...                                      wpa3_sae_pwid_qualifier=${wpa3_sae_pwid_qualifier}
    ${status}=  Run Keyword And Return Status  coam_admin.set_ssd_wifi_user     user_file=${filepath}
    ...                                                                         detailed_output=true
    ...                                                                         connection=${connection}
    [Return]    ${status}
    [Teardown]    Disconnect from ADMIN    connection=${connection}

Add New Wi-Fi User From File
    [Arguments]    ${filepath}
    ${connection}=    Connect to ADMIN
    ${status}=  Run Keyword And Return Status  coam_admin.set_ssd_wifi_user     user_file=${filepath}
    ...                                                                         detailed_output=true
    ...                                                                         connection=${connection}
    [Return]    ${status}
    [Teardown]    Disconnect from ADMIN    connection=${connection}

Check User Label - Too Short
    ${filepath}=    9233.generate new user xml    ${OUTPUT_DIR}/${TEST_NAME}/CB009233_userlabel_too_short.xml
    ...                                           user_label=s
    ${status}=    Add New Wi-Fi User From File    filepath=${filepath}
    Should Not Be True    ${status}

Check User Label - Too Long
    ${filepath}=    9233.generate new user xml    ${OUTPUT_DIR}/${TEST_NAME}/CB009233_userlabel_too_long.xml
    ...                                           user_label=toolonguserlabeltoolonguserlabelt
    ${status}=    Add New Wi-Fi User From File    filepath=${filepath}
    Should Not Be True    ${status}

Check User Label - First Character Is Upper
    ${filepath}=    9233.generate new user xml    ${OUTPUT_DIR}/${TEST_NAME}/CB009233_userlabel_upper.xml
    ...                                           user_label=userlabel=Upperuserlabel
    ${status}=    Add New Wi-Fi User From File    filepath=${filepath}
    Should Not Be True    ${status}

Check User Label - No Mix Of Numbers And Lower Case Letters
    ${filepath}=    9233.generate new user xml    ${OUTPUT_DIR}/${TEST_NAME}/CB009233_userlabel_mix.xml
    ...                                           user_label=u!DDDD%#@
    ${status}=    Add New Wi-Fi User From File    filepath=${filepath}
    Should Not Be True    ${status}

Check User Label - Same As Factory User
    [Arguments]    ${factory_userlabel}
    ${filepath}=    9233.generate new user xml    ${OUTPUT_DIR}/${TEST_NAME}/CB009233_userlabel_factory.xml
    ...                                           user_label=${factory_userlabel}
    ${status}=    Add New Wi-Fi User From File    filepath=${filepath}
    Should Not Be True    ${status}

Check User Label - Same As Other User Label
    ${status}=    Add New Wi-Fi User From File
    ...    filepath=${OUTPUT_DIR}/testsuite/Wroclaw/TRS/features/CB009233/Resources/CB009233_CustomFiles/dup_user_labels.xml
    Should Not Be True    ${status}

Check Password Complexity WPA2 - Too Short
    ${filepath}=    9233.generate new user xml    ${OUTPUT_DIR}/${TEST_NAME}/CB009233_wpa2_passphrase_too_short.xml
    ...                                           passphrase=tooSHORT123!
    ${status}=    Add New Wi-Fi User From File    filepath=${filepath}
    Should Not Be True    ${status}

Check Password Complexity WPA2 - Too Long
    [Arguments]    ${JSON_PATH}
    ${too_long}=    9233.get_too_long_password    ${JSON_PATH}    WPA2-PSK
    ${filepath}=    9233.generate new user xml    ${OUTPUT_DIR}/${TEST_NAME}/CB009233_wpa2_passphrase_too_long.xml
    ...                                           passphrase=${too_long}
    ${status}=    Add New Wi-Fi User From File    filepath=${filepath}
    Should Not Be True    ${status}

Check Password Complexity WPA2 - Only Lower Case Letters
    ${filepath}=    9233.generate new user xml    ${OUTPUT_DIR}/${TEST_NAME}/CB009233_wpa2_passphrase_only_lower_case.xml
    ...                                           passphrase=onlylowercaseletters
    ${status}=    Add New Wi-Fi User From File    filepath=${filepath}
    Should Not Be True    ${status}

Check Password Complexity WPA2 - Only Upper Case Letters
    ${filepath}=    9233.generate new user xml    ${OUTPUT_DIR}/${TEST_NAME}/CB009233_wpa2_passphrase_only_upper_case.xml
    ...                                           passphrase=onlyuppercaseletters
    ${status}=    Add New Wi-Fi User From File    filepath=${filepath}
    Should Not Be True    ${status}

Check Password Complexity WPA2 - Only Digits
    ${filepath}=    9233.generate new user xml    ${OUTPUT_DIR}/${TEST_NAME}/CB009233_wpa2_passphrase_only_digits.xml
    ...                                           passphrase=01234567890123456789
    ${status}=    Add New Wi-Fi User From File    filepath=${filepath}
    Should Not Be True    ${status}

Check Password Complexity WPA2 - Only Special Characters
    ${filepath}=    9233.generate new user xml    ${OUTPUT_DIR}/${TEST_NAME}/CB009233_wpa2_passphrase_only_digits.xml
    ...                                           passphrase=!$%^()[]_-~{}.+=!$%^()[]_-~{}.+=
    ${status}=    Add New Wi-Fi User From File    filepath=${filepath}
    Should Not Be True    ${status}

Check Password Complexity WPA2 - Contains User Label
    ${filepath}=    9233.generate new user xml    ${OUTPUT_DIR}/${TEST_NAME}/CB009233_wpa2_passphrase_contains_user_label.xml
    ...                                           user_label=testuser1
    ...                                           passphrase=containsUSERlabel1@testuser1
    ${status}=    Add New Wi-Fi User From File    filepath=${filepath}
    Should Not Be True    ${status}

Check Password Complexity WPA2 - Contains Reversed User Label
    ${filepath}=    9233.generate new user xml    ${OUTPUT_DIR}/${TEST_NAME}/CB009233_wpa2_passphrase_contains_reversed_user_label.xml
    ...                                           user_label=testuser1
    ...                                           passphrase=containsUSERlabel1@1resutset
    ${status}=    Add New Wi-Fi User From File    filepath=${filepath}
    Should Not Be True    ${status}

Check Password Complexity WPA3 - Too Short
    ${filepath}=    9233.generate new user xml    ${OUTPUT_DIR}/${TEST_NAME}/CB009233_wpa3_passphrase_too_short.xml
    ...                                           passphrase=tooSHORT123!
    ...                                           auth_type=WPA3-SAE
    ...                                           wpa3_sae_pwid_qualifier=1
    ${status}=    Add New Wi-Fi User From File    filepath=${filepath}
    Should Not Be True    ${status}

Check Password Complexity WPA3 - Too Long
    [Arguments]    ${JSON_PATH}
    ${too_long}=    9233.get_too_long_password    ${JSON_PATH}    WPA3-SAE
    ${filepath}=    9233.generate new user xml    ${OUTPUT_DIR}/${TEST_NAME}/CB009233_wpa3_passphrase_too_long.xml
    ...                                           passphrase=${too_long}
    ...                                           auth_type=WPA3-SAE
    ...                                           wpa3_sae_pwid_qualifier=1
    ${status}=    Add New Wi-Fi User From File    filepath=${filepath}
    Should Not Be True    ${status}

Check Password Complexity WPA3 - Only Lower Case Letters
    ${filepath}=    9233.generate new user xml    ${OUTPUT_DIR}/${TEST_NAME}/CB009233_wpa3_passphrase_only_lower_case.xml
    ...                                           passphrase=onlylowercaseletters
    ...                                           auth_type=WPA3-SAE
    ...                                           wpa3_sae_pwid_qualifier=1
    ${status}=    Add New Wi-Fi User From File    filepath=${filepath}
    Should Not Be True    ${status}

Check Password Complexity WPA3 - Only Upper Case Letters
    ${filepath}=    9233.generate new user xml    ${OUTPUT_DIR}/${TEST_NAME}/CB009233_wpa3_passphrase_only_upper_case.xml
    ...                                           passphrase=onlyuppercaseletters
    ...                                           auth_type=WPA3-SAE
    ...                                           wpa3_sae_pwid_qualifier=1
    ${status}=    Add New Wi-Fi User From File    filepath=${filepath}
    Should Not Be True    ${status}

Check Password Complexity WPA3 - Only Digits
    ${filepath}=    9233.generate new user xml    ${OUTPUT_DIR}/${TEST_NAME}/CB009233_wpa3_passphrase_only_digits.xml
    ...                                           passphrase=01234567890123456789
    ...                                           auth_type=WPA3-SAE
    ...                                           wpa3_sae_pwid_qualifier=1
    ${status}=    Add New Wi-Fi User From File    filepath=${filepath}
    Should Not Be True    ${status}

Check Password Complexity WPA3 - Only Special Characters
    ${filepath}=    9233.generate new user xml    ${OUTPUT_DIR}/${TEST_NAME}/CB009233_wpa3_passphrase_only_digits.xml
    ...                                           passphrase=!$%^()[]_-~{}.+=!$%^()[]_-~{}.+=
    ...                                           auth_type=WPA3-SAE
    ...                                           wpa3_sae_pwid_qualifier=1
    ${status}=    Add New Wi-Fi User From File    filepath=${filepath}
    Should Not Be True    ${status}

Check Password Complexity WPA3 - Contains User Label
    ${filepath}=    9233.generate new user xml    ${OUTPUT_DIR}/${TEST_NAME}/CB009233_wpa3_passphrase_contains_user_label.xml
    ...                                           user_label=testuser1
    ...                                           passphrase=containsUSERlabel1@testuser1
    ...                                           auth_type=WPA3-SAE
    ...                                           wpa3_sae_pwid_qualifier=1
    ${status}=    Add New Wi-Fi User From File    filepath=${filepath}
    Should Not Be True    ${status}

Check Password Complexity WPA3 - Contains Reversed User Label
    ${filepath}=    9233.generate new user xml    ${OUTPUT_DIR}/${TEST_NAME}/CB009233_wpa3_passphrase_contains_reversed_user_label.xml
    ...                                           user_label=testuser1
    ...                                           passphrase=containsUSERlabel1@1resutset
        ...                                       auth_type=WPA3-SAE
    ...                                           wpa3_sae_pwid_qualifier=1
    ${status}=    Add New Wi-Fi User From File    filepath=${filepath}
    Should Not Be True    ${status}

Start Tcpdump Via SSH On TestPC
    [Arguments]    ${pcap_file_name}
    ...            ${interface}=wlan0
    ${testpc_connection}=  Connect To TestPC
    ssh.Send Command  command=sudo tcpdump -i ${interface} -w ${pcap_file_name} &>/dev/null &
    ...               connection=${testpc_connection}
    Log    Tcpdump started at ${interface} intreface    console=${TRUE}
    [Teardown]    Disconnect From TestPC    connection=${testpc_connection}

Stop Tcpdump And Download Pcap Via SSH From TestPC
    [Arguments]    ${source_tcpdump_filepath}
    ...            ${target_pcap_filename}
    ${testpc_connection}=  Connect To TestPC
    Log    Stop tcpdump    console=${FALSE}
    ssh.Execute   command=sudo killall tcpdump
    ...           connection=${testpc_connection}
    Run  mkdir -p ${OUTPUT DIR}/${TEST NAME}
    ssh.Download File    remote_path=${source_tcpdump_filepath}
    ...                  local_path=${OUTPUT DIR}/${TEST NAME}/${target_pcap_filename}
    ...                  connection=${testpc_connection}
    Log    Tcpdump stopped and ${target_pcap_filename} file downloaded.    console=${TRUE}
    [Return]    ${OUTPUT DIR}/${TEST NAME}/${target_pcap_filename}
    [Teardown]    Disconnect From TestPC    connection=${testpc_connection}

Check Services and Repeat
    [Arguments]    ${JSON_PATH}
    ...            ${ehernet_port_security_status}
    ...            ${rnd_service_port_status}
    ...            ${wifi_ssid}
    ...            ${wifi_username}
    Wait Until Keyword Succeeds    3x    5min    Check Services
    ...                                          JSON_PATH=${JSON_PATH}
    ...                                          ehernet_port_security_status=${ehernet_port_security_status}
    ...                                          rnd_service_port_status=${rnd_service_port_status}
    ...                                          wifi_ssid=${wifi_ssid}
    ...                                          wifi_username=${wifi_username}

Check WiFi Services and Repeat
    [Arguments]    ${JSON_PATH}
    ...            ${ehernet_port_security_status}
    ...            ${rnd_service_port_status}
    ...            ${wifi_ssid}
    ...            ${wifi_username}
    Wait Until Keyword Succeeds    3x    5min    Check WiFi Services
    ...                                          JSON_PATH=${JSON_PATH}
    ...                                          ehernet_port_security_status=${ehernet_port_security_status}
    ...                                          rnd_service_port_status=${rnd_service_port_status}
    ...                                          wifi_ssid=${wifi_ssid}
    ...                                          wifi_username=${wifi_username}

Check Services
    [Arguments]    ${JSON_PATH}
    ...            ${ehernet_port_security_status}
    ...            ${rnd_service_port_status}
    ...            ${wifi_ssid}
    ...            ${wifi_username}

    Run Keyword If  "${ehernet_port_security_status}"=="true"  Enable Ethernet Port Security
    ...             ELSE                                       Disable Ethernet Port Security
    Run Keyword If  "${rnd_service_port_status}"=="true"  Enable RnD Service Port
    ...             ELSE                                  Disable RnD Service Port

    Add Multiple Alarms to Watchdog List    61676

    ${testpc_connection}=  Connect To TestPC
    Connect To BTS Wi-Fi Network    JSON_PATH=${JSON_PATH}    SSID=${wifi_ssid}    username=${wifi_username}

    ${nmap_results_vm}=      Run  sudo nmap ${LMP_IP} | grep -v closed | grep -v filtered
    ${nmap_results_testpc}=  ssh.Execute  command=sudo nmap ${TestPC_IP} | grep -v closed | grep -v filtered
    ...                                   connection=${testpc_connection}
    Compare Nmap Output    ${nmap_results_vm}    ${nmap_results_testpc}    tcp

    ${nmap_udp_results_vm}=  Run  sudo nmap -sU -p 15001-15006 ${LMP_IP}
    ${nmap_udp_results_testpc}=  ssh.Execute  command=sudo nmap -sU -p 15001-15006 ${TestPC_IP}
    ...                                       connection=${testpc_connection}
    Compare Nmap Output    ${nmap_udp_results_vm}    ${nmap_udp_results_testpc}    udp

    [Teardown]    Run Keywords  Disconnect From TestPC   connection=${testpc_connection}
    ...                         AND
    ...                         Disconnect From BTS Wi-Fi Network    SSID=${wifi_ssid}
    ...                         AND
    ...                         Sleep    30s    reason=Wait until alarm "WiFi Client Connected" disappears
    ...                         AND
    ...                         Remove Multiple Alarms from Watchdog List    61676

Check WiFi Services
    [Arguments]    ${JSON_PATH}
    ...            ${ehernet_port_security_status}
    ...            ${rnd_service_port_status}
    ...            ${wifi_ssid}
    ...            ${wifi_username}

    Run Keyword If  "${ehernet_port_security_status}"=="true"  Enable Ethernet Port Security
    ...             ELSE                                       Disable Ethernet Port Security
    Run Keyword If  "${rnd_service_port_status}"=="true"  Enable RnD Service Port
    ...             ELSE                                  Disable RnD Service Port

    Add Multiple Alarms to Watchdog List    61676

    ${testpc_connection}=  Connect To TestPC
    Connect To BTS Wi-Fi Network    JSON_PATH=${JSON_PATH}    SSID=${wifi_ssid}    username=${wifi_username}

    ${nmap_results_testpc}=  ssh.Execute  command=sudo nmap ${TestPC_IP} | grep -v closed | grep -v filtered
    ...                                   connection=${testpc_connection}

    ${nmap_udp_results_testpc}=  ssh.Execute  command=sudo nmap -sU -p 15001-15006 ${TestPC_IP} | grep -v filtered
    ...                                       connection=${testpc_connection}

    Check WiFi Nmap Output    ${nmap_results_testpc}    ${nmap_udp_results_testpc}

    [Teardown]    Run Keywords  Disconnect From TestPC   connection=${testpc_connection}
    ...                         AND
    ...                         Disconnect From BTS Wi-Fi Network    SSID=${wifi_ssid}
    ...                         AND
    ...                         Sleep    30s    reason=Wait until alarm "WiFi Client Connected" disappears
    ...                         AND
    ...                         Remove Multiple Alarms from Watchdog List    61676

Compare Nmap Output
    [Arguments]    ${nmap_output_1}    ${nmap_output_2}    ${type}=tcp
    ${parsed_nmap_output_1}=    Get Regexp Matches    ${nmap_output_1}    [0-9]*\/${type}.*
    ${parsed_nmap_output_1}=    Evaluate    [service.split("/")[0] for service in ${parsed_nmap_output_1}]
    FOR    ${port}    IN    @{parsed_nmap_output_1}
        ${skip}=        Evaluate    19000 <= ${port} <= 19999
        Run Keyword If    ${skip}    Remove Values From List    ${parsed_nmap_output_1}    ${port}
    END
    Log    ${parsed_nmap_output_1}\n\n    console=${TRUE}
    ${parsed_nmap_output_2}=    Get Regexp Matches    ${nmap_output_2}    [0-9]*\/${type}.*
    ${parsed_nmap_output_2}=    Evaluate    [line.strip() for line in ${parsed_nmap_output_2}]
    ${parsed_nmap_output_2}=    Evaluate    [service.split("/")[0] for service in ${parsed_nmap_output_2}]
    Log    ${parsed_nmap_output_2}\n\n    console=${TRUE}
    Should Be Equal  ${parsed_nmap_output_1}  ${parsed_nmap_output_2}

Check WiFi Nmap Output
    [Arguments]    ${nmap_output_tcp}    ${nmap_output_udp}
    ${parsed_nmap_output_tcp}=    Get Regexp Matches    ${nmap_output_tcp}    [0-9]*\/tcp.*
    ${parsed_nmap_output_tcp}=    Evaluate    [line.strip() for line in ${parsed_nmap_output_tcp}]
    ${parsed_nmap_output_tcp}=    Evaluate    [service.split("/")[0] for service in ${parsed_nmap_output_tcp}]
    Log    ${parsed_nmap_output_tcp}\n\n    console=${TRUE}
    ${correct_tcp}=    Create List    443
    Should Be Equal    ${parsed_nmap_output_tcp}    ${correct_tcp}

    ${parsed_nmap_output_udp}=    Get Regexp Matches    ${nmap_output_udp}    [0-9]*\/udp.*
    ${parsed_nmap_output_udp}=    Evaluate    [line.strip() for line in ${parsed_nmap_output_udp}]
    ${parsed_nmap_output_udp}=    Evaluate    [service.split("/")[0] for service in ${parsed_nmap_output_udp}]
    Log    ${parsed_nmap_output_udp}\n\n    console=${TRUE}
    Should Be Empty    ${parsed_nmap_output_udp}

Check EAPOL Packets
    [Arguments]    ${JSON_PATH}    ${wifi_ssid}    ${wifi_username}
    Start Tcpdump Via SSH On TestPC    pcap_file_name=eapol.pcap
    Connect To BTS Wi-Fi Network    JSON_PATH=${JSON_PATH}    SSID=${wifi_ssid}     username=${wifi_username}
    Sleep    1min
    ${eapol_filepath}=  Stop Tcpdump And Download Pcap Via SSH From TestPC
    ...                      source_tcpdump_filepath=/home/kali/eapol.pcap
    ...                      target_pcap_filename=eapol.pcap
    PCAP Should Contain Message    tshark_filter=eapol   pcap_file=${eapol_filepath}
    PCAP Should Contain Message    tshark_filter=wlan_rsna_eapol.keydes.key_info.keydes_version   pcap_file=${eapol_filepath}
    [Teardown]    Disconnect From BTS Wi-Fi Network    SSID=${wifi_ssid}

Enable RnD Service Port
    Change Parameter On BTS     dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                         param_name=actServicePortState
    ...                         param_value=true

Disable RnD Service Port
    Change Parameter On BTS     dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                         param_name=actServicePortState
    ...                         param_value=false

Enable Ethernet Port Security
    Change Parameter on BTS             dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                 param_name=ethernetPortSecurityEnabled
    ...                                 param_value=true

Disable Ethernet Port Security
    Change Parameter on BTS             dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                 param_name=ethernetPortSecurityEnabled
    ...                                 param_value=false
