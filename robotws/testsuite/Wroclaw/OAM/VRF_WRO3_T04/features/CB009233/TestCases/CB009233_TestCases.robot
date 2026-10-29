*** Settings ***
Documentation    Suite for CB009233 Wireless LMP testcases for ASOF.
...              author:    Patryk Tatarek
...              contact:   patryk.tatarek@nokia.com

Resource  ../../../common_resources/admin/admin.robot
Resource  ../../../common_resources/alarms/alarm.robot
Resource  ../../../common_resources/ip_traffic/ip_traffic.robot
Resource  ../../../common_resources/pcap_analysis/pcap_analysis.robot
Resource  ../../../common_resources/wifi/Wifi_Keywords.robot
Resource  ../../../common_resources/netact/netact_operations.robot

Library   taf.sbts.oam.coam.admin    WITH NAME   coam_admin
Library   OperatingSystem
Library   String

*** Variables ***
${JSON_PATH}=    /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/VRF_WRO3_T04/features/CB009233/Resources/CB009233_settings.json

*** Keywords ***
CB009233_Wifi_User_Label_Format
    Run    mkdir -p ${OUTPUT_DIR}/${TEST_NAME}
    Check User Label - Too Short
    Check User Label - Too Long
    Check User Label - First Character Is Upper
    Check User Label - No Mix Of Numbers And Lower Case Letters
    Check User Label - Same As Factory User   factory_userlabel=wifiuser00a
    Check User Label - Same As Other User Label

CB009233_Wifi_password_complexity_requirements_WPA2
    Run    mkdir -p ${OUTPUT_DIR}/${TEST_NAME}
    Check Password Complexity WPA2 - Too Short
    Check Password Complexity WPA2 - Too Long    ${JSON_PATH}
    Check Password Complexity WPA2 - Only Lower Case Letters
    Check Password Complexity WPA2 - Only Upper Case Letters
    Check Password Complexity WPA2 - Only Digits
    Check Password Complexity WPA2 - Only Special Characters
    Check Password Complexity WPA2 - Contains User Label
    Check Password Complexity WPA2 - Contains Reversed User Label

CB009233_Wifi_password_complexity_requirements_WPA3
    Run    mkdir -p ${OUTPUT_DIR}/${TEST_NAME}
    Check Password Complexity WPA3 - Too Short
    Check Password Complexity WPA3 - Too Long    ${JSON_PATH}
    Check Password Complexity WPA3 - Only Lower Case Letters
    Check Password Complexity WPA3 - Only Upper Case Letters
    Check Password Complexity WPA3 - Only Digits
    Check Password Complexity WPA3 - Only Special Characters
    Check Password Complexity WPA3 - Contains User Label
    Check Password Complexity WPA3 - Contains Reversed User Label

CB009233_Handling_of_sensitive_data
    Change Parameter on BTS     dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/WLAN-1/BSSID-2
    ...                         param_name=limitToBssLocalWebPageOnly
    ...                         param_value=false
    ${connection}=  Connect To BTS Over Wi-Fi    JSON_PATH=${JSON_PATH}    SSID=WPA2KeanuReeves    username=wifiuser01b

    Check File Permissions And Owner And Usergroup    filepath=/etc/hostapd.conf
    ...                                               permissions=-rw-r--r--
    ...                                               owner=root
    ...                                               usergroup=root
    ...                                               connection=${connection}

    Check File Permissions And Owner And Usergroup    filepath=/ffs/fs2/config/safe/wifi.json
    ...                                               permissions=-rw-r--r--
    ...                                               owner=btssw
    ...                                               usergroup=btssw
    ...                                               connection=${connection}

    Check File Permissions And Owner And Usergroup    filepath=/ffs/fs1/config/safe/wifi.json
    ...                                               permissions=-rw-r--r--
    ...                                               owner=btssw
    ...                                               usergroup=btssw
    ...                                               connection=${connection}

    Check Process UID    filepath=/opt/trs/bin/wpa_supplicant
    ...                  uid=root
    ...                  connection=${connection}

    Check Process UID    filepath=/opt/trs/etc/wpa_supplicant_log.sh
    ...                  uid=root
    ...                  connection=${connection}

    Check File Permissions And Owner And Usergroup    filepath=/opt/trs/bin/wpa_supplicant
    ...                                               permissions=-rwxr-xr-x
    ...                                               owner=root
    ...                                               usergroup=root
    ...                                               connection=${connection}

    Check File Permissions And Owner And Usergroup    filepath=/etc/wpa_supplicant/log
    ...                                               permissions=-rw-r-----
    ...                                               owner=root
    ...                                               usergroup=root
    ...                                               connection=${connection}

    Check File Permissions And Owner And Usergroup    filepath=/etc/wpa_supplicant/wpa_supplicant-wired-etheif1.conf
    ...                                               permissions=-rw-r--r--
    ...                                               owner=root
    ...                                               usergroup=root
    ...                                               connection=${connection}

    Check File Permissions And Owner And Usergroup    filepath=/etc/wpa_supplicant/wpa_supplicant-wired-etheif2.conf
    ...                                               permissions=-rw-r--r--
    ...                                               owner=root
    ...                                               usergroup=root
    ...                                               connection=${connection}

    Check File Permissions And Owner And Usergroup    filepath=/etc/wpa_supplicant/wpa_supplicant-wired-etheif3.conf
    ...                                               permissions=-rw-r--r--
    ...                                               owner=root
    ...                                               usergroup=root
    ...                                               connection=${connection}

    Check File Owner And Usergroup In Directory    dirpath=/etc/wpa_supplicant/certs/
    ...                                            owner_and_usergroup=root
    ...                                            connection=${connection}

    Check Process UID    filepath=/opt/trs/bin/trs-wifilmp-d
    ...                  uid=btssw
    ...                  connection=${connection}

    Check Process UID    filepath=/ffs/run/trs_data/active/keystorage/wifilmp/hostapd0.conf
    ...                  uid=btssw
    ...                  connection=${connection}

    Check Process UID    filepath=/ffs/run/trs_data/active/keystorage/wifilmp/hostapd1.conf
    ...                  uid=btssw
    ...                  connection=${connection}

    Check Process UID    filepath=/ffs/run/trs_data/active/keystorage/wifilmp/hostapd2.conf
    ...                  uid=btssw
    ...                  connection=${connection}

    Check Process UID    filepath=/opt/trs/etc/wifilmpdhcpd.leases
    ...                  uid=btssw
    ...                  connection=${connection}

    Check File Permissions And Owner And Usergroup    filepath=/usr/sbin/hostapd
    ...                                               permissions=-rwxr-xr-x
    ...                                               owner=root
    ...                                               usergroup=root
    ...                                               connection=${connection}

    Check File Owner And Usergroup In Directory    dirpath=/ffs/run/trs_data/active/keystorage/wifilmp/
    ...                                            owner_and_usergroup=btssw
    ...                                            connection=${connection}

    Check File Permissions And Owner And Usergroup    filepath=/usr/sbin/dhcpd
    ...                                               permissions=-rwxr-xr-x
    ...                                               owner=root
    ...                                               usergroup=root
    ...                                               connection=${connection}

    Check File Permissions And Owner And Usergroup    filepath=/opt/trs/etc/wifilmpdhcpd.conf
    ...                                               permissions=-rw-r--r--
    ...                                               owner=root
    ...                                               usergroup=root
    ...                                               connection=${connection}

    Check File Permissions And Owner And Usergroup    filepath=/opt/trs/etc/wifilmpdhcpd.leases
    ...                                               permissions=-rw-r--r--
    ...                                               owner=btssw
    ...                                               usergroup=btssw
    ...                                               connection=${connection}

    [Teardown]    Run Keywords  Disconnect From BTS Over Wi-Fi    connection=${connection}
    ...                         AND
    ...                         Disconnect From BTS Wi-Fi Network    SSID=WPA2KeanuReeves
    ...                         AND
    ...                         Change Parameter on BTS     dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/WLAN-1/BSSID-2
    ...                         param_name=limitToBssLocalWebPageOnly
    ...                         param_value=true

CB009233_Services_Supported_Over_WiFi_LMP
    Change Parameter on BTS     dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/WLAN-1/BSSID-1
    ...                         param_name=limitToBssLocalWebPageOnly
    ...                         param_value=true
    Change Parameter on BTS     dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/WLAN-1/BSSID-2
    ...                         param_name=limitToBssLocalWebPageOnly
    ...                         param_value=true
    Change Parameter on BTS     dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/WLAN-1/BSSID-3
    ...                         param_name=limitToBssLocalWebPageOnly
    ...                         param_value=true
    Run Keyword and Continue on Failure    Check WiFi Services and Repeat
    ...                                    JSON_PATH=${JSON_PATH}
    ...                                    ehernet_port_security_status=true
    ...                                    rnd_service_port_status=true
    ...                                    wifi_ssid=WPA2KeanuReeves
    ...                                    wifi_username=wifiuser01b
    Run Keyword and Continue on Failure    Check WiFi Services and Repeat
    ...                                    JSON_PATH=${JSON_PATH}
    ...                                    ehernet_port_security_status=true
    ...                                    rnd_service_port_status=false
    ...                                    wifi_ssid=WPA2KeanuReeves
    ...                                    wifi_username=wifiuser01b
    Change Parameter on BTS     dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/WLAN-1/BSSID-2
    ...                         param_name=limitToBssLocalWebPageOnly
    ...                         param_value=false
    Run Keyword and Continue on Failure    Check Services and Repeat
    ...                                    JSON_PATH=${JSON_PATH}
    ...                                    ehernet_port_security_status=true
    ...                                    rnd_service_port_status=true
    ...                                    wifi_ssid=WPA2KeanuReeves
    ...                                    wifi_username=wifiuser01b
    Run Keyword and Continue on Failure    Check Services and Repeat
    ...                                    JSON_PATH=${JSON_PATH}
    ...                                    ehernet_port_security_status=true
    ...                                    rnd_service_port_status=false
    ...                                    wifi_ssid=WPA2KeanuReeves
    ...                                    wifi_username=wifiuser01b
    [Teardown]    Run Keywords  Enable RnD Service Port
    ...                         AND
    ...                         Change Parameter on BTS
    ...                         dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/WLAN-1/BSSID-2
    ...                         param_name=limitToBssLocalWebPageOnly
    ...                         param_value=true

CB009233_Metasploit_Vulnerability_Scan
    Change Parameter on BTS     dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/WLAN-1/BSSID-1
    ...                         param_name=limitToBssLocalWebPageOnly
    ...                         param_value=false
    Connect To BTS Wi-Fi Network    JSON_PATH=${JSON_PATH}    SSID=SecurityArmadilloWPA3    username=wifiuser00a
    ${testpc_connection}=  Connect To TestPC
    ${console_output}=  ssh.Execute  command=msfconsole -q -x " db_nmap -sV --script=vulners.nse 192.168.255.36; vulns; exit;"
    ...                              connection=${testpc_connection}
    Log    ${console_output}    console=${TRUE}
    Should Not Contain  ${console_output.strip().split("Vulnerabilities")[-1]}  192.168.255.36    msg=Nmap vulnerability scan: FAILED
    Log    Nmap vulnerability scan: PASSED    console=${TRUE}
    [Teardown]    Run Keywords  Disconnect From TestPC    connection=${testpc_connection}
    ...                         AND
    ...                         Disconnect From BTS Wi-Fi Network    SSID=SecurityArmadilloWPA3
    ...                         AND
    ...                         Change Parameter on BTS
    ...                         dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/WLAN-1/BSSID-1
    ...                         param_name=limitToBssLocalWebPageOnly
    ...                         param_value=true

CB009233_Wifi_LMP_Handling_Repeated_Authentication_Failure_and_Alarm
    Run    mkdir -p ${OUTPUT_DIR}/${TEST_NAME}
    ${filepath}=    9233.generate new user xml    ${OUTPUT_DIR}/${TEST_NAME}/CB009233_alarmuser.xml
    ...                                           user_label=alarmuser
    ...                                           passphrase=WPA2aaaBBBcccDDDeeeFFF123
    ...                                           auth_type=WPA2-PSK
    ${status}=    Add New Wi-Fi User From File    filepath=${filepath}
    Should Be True  ${status}
    ${users_list}=    Evaluate    ["wifiuser01b", "alarmuser"]
    Change Parameter on BTS     dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/WLAN-1/BSSID-2
    ...                         param_name=wifiUserListAllowed
    ...                         param_value=${users_list}
    ${delays}=    Create List   15sec    30sec    1min    2min    4min
    FOR    ${delay}    IN    @{delays}
        ${connection_status}=    Run Keyword And Return Status    Connect To BTS Wi-Fi Network Without Repetitions
        ...                                                       JSON_PATH=${JSON_PATH}    SSID=WPA2KeanuReeves    username=wrong_username
        Should Not Be True      ${connection_status}
        Log     Waiting ${delay} ...    console=${TRUE}
        Sleep   ${delay}
    END
    ${connection_status}=    Run Keyword And Return Status    Connect To BTS Wi-Fi Network Without Repetitions
    ...                                                       JSON_PATH=${JSON_PATH}    SSID=WPA2KeanuReeves    username=wrong_username
    Should Not Be True      ${connection_status}
    Sleep  1min
    Alarm Should Be Active In BTS    fault_id=61677
    Log    Waiting to unlock ...    console=${TRUE}
    Sleep    9min
    Connect To BTS Wi-Fi Network     JSON_PATH=${JSON_PATH}    SSID=WPA2KeanuReeves  username=alarmuser
    [Teardown]    Run Keywords    Set Test Variable    @{default_users_list}    wifiuser01b
    ...                           AND
    ...                           Change Parameter on BTS
    ...                           dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/WLAN-1/BSSID-2
    ...                           param_name=wifiUserListAllowed
    ...                           param_value=${default_users_list}
    ...                           AND
    ...                           Disconnect From BTS Wi-Fi Network    SSID=WPA2KeanuReeves

CB009233_Wifi_LMP_Layer_Hardening_and_Best_Practices
    [Tags]    tc8
    Change Parameter on BTS       dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/WLAN-1/BSSID-2
    ...                           param_name=pmfPolicy
    ...                           param_value=PmfOptional
    Change Parameter on BTS       dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/WLAN-1/BSSID-3
    ...                           param_name=pmfPolicy
    ...                           param_value=PmfOptional
    Disable Auto Connect To Wi-Fi Network For All SSIDs    ${JSON_PATH}
    Set Wi-Fi Card To Monitor Mode
    &{testpc_info}=    9233.get_testpc_address_and_credentials    ${BTS_ID}
    Start Tcpdump Via SSH On TestPC    pcap_file_name=beacon.pcap
    Sleep    1min
    ${beacon_filepath}=  Stop Tcpdump And Download Pcap Via SSH From TestPC
    ...                       source_tcpdump_filepath=/home/kali/beacon.pcap
    ...                       target_pcap_filename=beacon.pcap
    ${all_ssids}=    9233.get_all_ssids    ${JSON_PATH}    ${BTS_ID}
    FOR    ${ssid}    IN    @{all_ssids}
        &{ssid_info}=  9233.get_mfpc_mpfr_values  ${JSON_PATH}    ${BTS_ID}  ${ssid}
        ${local_tshark_filter}=  Catenate  wlan.fc.type_subtype == 0x08 &&
        ...                                wlan.ssid == \"${ssid}\" &&
        ...                                wlan.rsn.capabilities.mfpc == ${ssid_info["mfpc"]} &&
        ...                                wlan.rsn.capabilities.mfpr == ${ssid_info["mfpr"]}
        PCAP Should Contain Message
        ...  tshark_filter=${local_tshark_filter}
        ...  pcap_file=${beacon_filepath}
    END
    Sleep    1min
    Set Wi-Fi Card To Managed Mode
    Wait Until Keyword Succeeds  10x  1min  Check EAPOL Packets    JSON_PATH=${JSON_PATH}
    ...                                                            wifi_ssid=WPA2KeanuReeves
    ...                                                            wifi_username=wifiuser01b
    [Teardown]    Run Keywords      Disconnect From BTS Wi-Fi Network    SSID=WPA2KeanuReeves
    ...                             AND
    ...                             Change Parameter on BTS
    ...                             dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/WLAN-1/BSSID-2
    ...                             param_name=pmfPolicy
    ...                             param_value=PmfOptional

CB009233_Wifi_LMP_User_Account_Definition
    Run    mkdir -p ${OUTPUT_DIR}/${TEST_NAME}
    ${wpa3_user_filepath}=    9233.generate new user xml    ${OUTPUT_DIR}/${TEST_NAME}/CB009233_userdefwpa3.xml
    ...                                                     user_label=userdefwpa3
    ...                                                     passphrase=WPA3aaaBBBcccDDDeeeFFF123
    ...                                                     auth_type=WPA3-SAE
    ${status}=    Add New Wi-Fi User From File    filepath=${wpa3_user_filepath}
    Should Be True  ${status}
    ${users_list}=    Evaluate  ["wifiuser00a", "userdefwpa3"]
    Change Parameter on BTS     dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/WLAN-1/BSSID-1
    ...                         param_name=wifiUserListAllowed
    ...                         param_value=${users_list}
    Connect To BTS Wi-Fi Network    JSON_PATH=${JSON_PATH}    SSID=SecurityArmadilloWPA3  username=userdefwpa3
    ${users_list}=    Evaluate  ["wifiuser00a"]
    Change Parameter on BTS     dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/WLAN-1/BSSID-1
    ...                         param_name=wifiUserListAllowed
    ...                         param_value=${users_list}

    ${wpa2_user_filepath}=    9233.generate new user xml    ${OUTPUT_DIR}/${TEST_NAME}/CB009233_userdefwpa2.xml
    ...                                                     user_label=userdefwpa2
    ...                                                     passphrase=WPA2aaaBBBcccDDDeeeFFF123
    ${status}=    Add New Wi-Fi User From File    filepath=${wpa2_user_filepath}
    Should Be True  ${status}
    ${users_list}=    Evaluate  ["wifiuser01b", "userdefwpa2"]
    Change Parameter on BTS     dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/WLAN-1/BSSID-2
    ...                         param_name=wifiUserListAllowed
    ...                         param_value=${users_list}
    Connect To BTS Wi-Fi Network    JSON_PATH=${JSON_PATH}    SSID=WPA2KeanuReeves  username=userdefwpa2
    ${users_list}=    Evaluate  ["wifiuser01b"]
    Change Parameter on BTS     dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/WLAN-1/BSSID-2
    ...                         param_name=wifiUserListAllowed
    ...                         param_value=${users_list}

    [Teardown]    Run Keywords  Disconnect From BTS Wi-Fi Network    SSID=SecurityArmadilloWPA3
    ...                         AND
    ...                         Disconnect From BTS Wi-Fi Network    SSID=WPA2KeanuReeves
    ...                         AND
    ...                         Set Test Variable    @{default_users_list}    wifiuser00a
    ...                         AND
    ...                         Change Parameter on BTS
    ...                         dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/WLAN-1/BSSID-1
    ...                         param_name=wifiUserListAllowed
    ...                         param_value=${default_users_list}
    ...                         AND
    ...                         Set Test Variable    @{default_users_list}    wifiuser01b
    ...                         AND
    ...                         Change Parameter on BTS
    ...                         dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/WLAN-1/BSSID-2
    ...                         param_name=wifiUserListAllowed
    ...                         param_value=${default_users_list}

CB009233_Wifi_LMP_Module_Level_Configuration_Mac_Address_ACL_List
    ${testpc_connection}=  Connect To TestPC
    ${admin_connection}=    Connect to ADMIN
    ${testpc_wifi_interface_mac_address}=  ssh.Execute  command=ip a | grep wlan -A 1 | grep ether | cut -d " " -f 6
    ...                                                 connection=${testpc_connection}
    ${testpc_wifi_interface_mac_address}=    9233.trim    ${testpc_wifi_interface_mac_address}

    Change Parameter on BTS     dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/WLAN-1
    ...                         param_name=deniedWifiClientMacAddrList
    ...                         param_value=${testpc_wifi_interface_mac_address}
    Change Parameter on BTS     dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/WLAN-1
    ...                         param_name=wifiClientMacACLPolicy
    ...                         param_value=Accept unless in deny list
    ${connection_status}=    Run Keyword And Return Status    Connect To BTS Wi-Fi Network Without Repetitions
    ...                                                       JSON_PATH=${JSON_PATH}
    ...                                                       SSID=SecurityArmadilloWPA3
    ...                                                       username=wifiuser00a
    Should Not Be True    ${connection_status}
    Change Parameter on BTS     dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/WLAN-1
    ...                         param_name=wifiClientMacACLPolicy
    ...                         param_value=Disabled
    Delete Parameter From BTS     dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/WLAN-1
    ...                           param_name=deniedWifiClientMacAddrList
    ...                           connection=${admin_connection}

    Change Parameter on BTS     dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/WLAN-1
    ...                         param_name=allowedWifiClientMacAddrList
    ...                         param_value=${testpc_wifi_interface_mac_address}
    Change Parameter on BTS     dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/WLAN-1
    ...                         param_name=wifiClientMacACLPolicy
    ...                         param_value=Deny unless in accept list
    ${connection_status}=    Run Keyword And Return Status    Connect To BTS Wi-Fi Network Without Repetitions
    ...                                                       JSON_PATH=${JSON_PATH}
    ...                                                       SSID=SecurityArmadilloWPA3
    ...                                                       username=wifiuser00a
    Should Be True    ${connection_status}

    [Teardown]  Run Keywords    Disconnect From TestPC    connection=${testpc_connection}
    ...                         AND
    ...                         Disconnect From BTS Wi-Fi Network    SSID=SecurityArmadilloWPA3
    ...                         AND
    ...                         Change Parameter on BTS     dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/WLAN-1
    ...                         param_name=wifiClientMacACLPolicy
    ...                         param_value=Disabled
    ...                         AND
    ...                         Delete Parameter From BTS     dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/WLAN-1
    ...                         param_name=deniedWifiClientMacAddrList
    ...                         connection=${admin_connection}
    ...                         AND
    ...                         Disconnect from ADMIN    connection=${admin_connection}

ATL_logs
    ${connection}=                Connect to NetAct
    Get RUEM logs from NetAct     ${connection}    MRBTS-${BTS_ID}    /home/ute/xxx.xml
    File Should Not Be Empty      /home/ute/xxx.xml
    [Teardown]                    Disconnect from NetAct    ${connection}
