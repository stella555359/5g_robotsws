*** Settings ***
Documentation    Suite for CB013432 Wireless LMP testcases for ASOH.
...              author:    Piotr Pinderak
...              contact:   piotr.pinderak@nokia.com

Resource  ../../../common_resources/admin/admin.robot
Resource  ../../../common_resources/alarms/alarm.robot
Resource  ../../../common_resources/ip_traffic/ip_traffic.robot
Resource  ../../../common_resources/pcap_analysis/pcap_analysis.robot
Resource  ../../../common_resources/wifi/Wifi_Keywords.robot

Library   taf.sbts.oam.coam.admin    WITH NAME   coam_admin
Library   OperatingSystem
Library   String

*** Variables ***
${JSON_PATH}=    /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/VRF_WRO3_T04/features/CB013432/Resources/CB013432_settings.json

*** Keywords ***
CB013432_CB009233_Services_Supported_Over_Wifi_LMP
    Change Parameter on BTS     dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/WLAN-1/BSSID-3
    ...                         param_name=limitToBssLocalWebPageOnly
    ...                         param_value=false
    Run Keyword and Continue on Failure    Check Services and Repeat
    ...                                    JSON_PATH=${JSON_PATH}
    ...                                    ehernet_port_security_status=true
    ...                                    rnd_service_port_status=true
        ...                                wifi_ssid=WPA2KeanuASOH
    ...                                    wifi_username=wifiuser01b
    Run Keyword and Continue on Failure    Check Services and Repeat
    ...                                    JSON_PATH=${JSON_PATH}
    ...                                    ehernet_port_security_status=true
    ...                                    rnd_service_port_status=false
        ...                                wifi_ssid=WPA2KeanuASOH
    ...                                    wifi_username=wifiuser01b
    [Teardown]    Run Keywords  Enable RnD Service Port
    ...                         AND
    ...                         Change Parameter on BTS
    ...                         dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/WLAN-1/BSSID-3
    ...                         param_name=limitToBssLocalWebPageOnly
    ...                         param_value=true

CB013432_CB009233_Wifi_LMP_Layer_Hardening_And_Best_Practices
    Change Parameter on BTS       dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/WLAN-1/BSSID-2
    ...                           param_name=pmfPolicy
    ...                           param_value=PmfOptional
    Change Parameter on BTS       dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/WLAN-1/BSSID-3
    ...                           param_name=pmfPolicy
    ...                           param_value=PmfOptional
    Disable Auto Connect To Wi-Fi Network For All SSIDs    ${JSON_PATH}
    Set Wi-Fi Card To Monitor Mode
    &{testpc_info}=    get_testpc_address_and_credentials    ${BTS_ID}
    Start Tcpdump Via SSH On TestPC    pcap_file_name=beacon.pcap
    Sleep    1min
    ${beacon_filepath}=  Stop Tcpdump And Download Pcap Via SSH From TestPC
    ...                       source_tcpdump_filepath=/home/kali/beacon.pcap
    ...                       target_pcap_filename=beacon.pcap
    ${all_ssids}=    get_all_ssids    ${JSON_PATH}    ${BTS_ID}
    FOR    ${ssid}    IN    @{all_ssids}
        &{ssid_info}=  get_mfpc_mpfr_values  ${JSON_PATH}    ${BTS_ID}  ${ssid}
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
    Add Multiple Alarms to Watchdog List    61676
    Wait Until Keyword Succeeds  10x  1min    Check EAPOL Packets    JSON_PATH=${JSON_PATH}
    ...                                                              wifi_ssid=WPA2KeanuASOH
    ...                                                              wifi_username=wifiuser01b
    [Teardown]    Run Keywords      Disconnect From BTS Wi-Fi Network    SSID=WPA2KeanuASOH
    ...                             AND
    ...                             Change Parameter on BTS
    ...                             dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/WLAN-1/BSSID-2
    ...                             param_name=pmfPolicy
    ...                             param_value=PmfOptional
    ...                             AND
    ...                             Remove Multiple Alarms from Watchdog List    61676
