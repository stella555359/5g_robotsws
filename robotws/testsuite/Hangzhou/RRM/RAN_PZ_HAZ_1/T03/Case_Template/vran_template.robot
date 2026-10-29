*** Settings ***
Documentation
...   author: winnie he
...   contact: winnie.he@nokia-sbell.com
...   Description: this is one reference case template, purpose for unified style.

Resource           ../Resources/vran_resource.robot
Library    taf.selenium.sbts    WITH NAME      sbts
Suite Setup       Common Suite Setup For AIC
Test Setup        Common Test Setup For AIC
# Test Setup        Run Keywords    Common Test Setup For AIC    AND
# ...     AIC Case Setup    airphone_config_tag=CLOUD_NSA
# ...    base_path=${CURDIR}/Airphone
Test Teardown     Common Test Teardown For AIC
Suite Teardown    Common Suite Teardown For AIC
Force Tags        CRT/CIT/CDRT     #Tag Item
...      RAN_5G                    #Product [RAN_5G]
# ...      CLOUD_5G_CLASSICAL_2xANDROID_ASIBL_ABIAB1_ASIBR_ABILB1_AEQE_ENB   #TLtype, it is for auto trigger by ute cloud
...      SBTS00           # it is for auto trigger by ute cloud with the release
...      RAN_PZ_HAZ_1             #Competence Area
...      RAN_PZ_HAZ1_SG07_ST_RRM  #Organization
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]


Test Timeout    180 minutes

*** Variables ***
@{Ohter_Allow_Alarms}
${FLAG_USE_UE_MODULE}    ${True}
*** Test Cases ***
#test case name should be same with qc case name without space and special characters
KW test
    ${vdu_scf}    Create List    ${None}
    ${scf}    Create Dictionary     vCU=${None}    vDU=${vdu_scf}
    # Setup Ap Env    local_wts_dir=${None}
    # ...    scf_file_path=${scf}
    Log To Console    \nStart to test the BTS Operation module ...\n
    Start Wireshark Log In vCU   gnb_index=${0}
    ...                          container_name=nwmgmt
    ...                          pod_name=cpif
    ...                          timeout=${10}
    ...                          protocol=sctp
    ...                          interface=any
    sleep    20s
    ${wireshark_local_file_path_1}    Stop Wireshark Log And Download To K8s Master In vCU   gnb_index=${0}
    ...                                                                                    container_name=nwmgmt
    ...                                                                                    pod_name=cpif
    ...                                                                                    timeout=${10}
    ...                                                                                    log_name=test_tcpdump
    # Analysis Wireshark Log    ${wireshark_local_file_path_1}
    run keyword and ignore error    Analysis Wireshark Log    ${wireshark_local_file_path_1}    append_cmd=-T pdml
    run keyword and ignore error    Analysis Wireshark Log    ${wireshark_local_file_path_1}

SWFH Onair
    [Setup]    Run Keywords    Common Test Setup For AIC    AND
    ...     AIC Case Setup    airphone_config_tag=CLOUD
    ...    base_path=${CURDIR}/Airphone
    ${vdu_scf}    Create List    ${None}
    ${scf}    Create Dictionary     vCU=${None}    vDU=${vdu_scf}
    # Setup Ap Env    local_wts_dir=${None}
    # ...    scf_file_path=${scf}
    Log To Console    \n CLOUD_5GC_dRNIC_1vDU_P_AP_LO_SWFH Onair ...\n

DC Onair
    [Setup]    Run Keywords    Common Test Setup For AIC    AND
    ...     AIC Case Setup    airphone_config_tag=CLOUD_DC
    ...    base_path=${CURDIR}/Airphone
    ${vdu_scf}    Create List    ${None}
    ${scf}    Create Dictionary     vCU=${None}    vDU=${vdu_scf}
    # Setup Ap Env    local_wts_dir=${None}
    # ...    scf_file_path=${scf}
    Log To Console    \n CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC Onair ...\n

Config Wts Until Onair
    [Setup]    Run Keywords    Common Test Setup For AIC    AND
    ...     AIC Case Setup
    ${vdu_scf}    Create List    ${None}
    ${scf}    Create Dictionary     vCU=${None}    vDU=${vdu_scf}
    # Setup Ap Env    local_wts_dir=${None}
    # ...    scf_file_path=${scf}
    Log To Console    \n CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC Onair ...\n

Nsa Onair
    [Setup]    Run Keywords    Common Test Setup For AIC    AND
    ...     AIC Case Setup    airphone_config_tag=CLOUD_NSA
    ...    call_type=nsa
    ...    base_path=${CURDIR}/Airphone
    ${vdu_scf}    Create List    ${None}
    ${scf}    Create Dictionary     vCU=${None}    vDU=${vdu_scf}
    # Setup Ap Env    local_wts_dir=${None}
    # ...    scf_file_path=${scf}
    Log To Console    \n CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC Onair ...\n
Upgrade test
    AIC Upgrade vCU And vDu by Kuafu For All
UE Test
    # AT.Prepare UE
    # # AT.UE Detach
    # # AT.Reboot UE
    # AT.UE Attach
    # AT.Get UE IP
    # AT.Get UE IP
    # AT Operation    operation=start_traffic    IperfOptions=-u -i 1 -t 300 -b 10M -p 50001
    # ...    direction=ul
    # AT Operation    operation=start_traffic    IperfOptions=-u -i 1 -t 300 -b 10M -p 50001
    # ...    direction=dl
    # AT Operation    operation=stop_traffic    direction=ul
    # AT Operation    operation=stop_traffic    direction=dl
    # #
    # AT.Get IPV4 APN
    # AT.Voice Call
    # AT.End Call
    # AT.Get UE IP
    # AT Operation    operation=get    item=ueip    intf_name=ims
    # AT Operation    operation=exec_at_command    command=AT
    # ${v}    Evaluate    abs(${-1})
    # ADB.Prepare UE
    # Qualcomm.Change APN    apn=mdrb.nokia.com
    # Qualcomm8350.Start UL Traffic By MagicIperf
    # ...    tput_time=3600s      tput_value=50000      server_ip=10.70.177.52
    # sleep    5s
    # Qualcomm8350.Stop UL Traffic By MagicIperf
    # Traffic UE Operation    start traffic    ue_index=0    option=udp_dl      bandwidth=50M    port=50001    duration=9999s
    # Connect To IperfServer From Appservers
    # ADB.Prepare UE
    # Connect To VM
    # ADB.Start Traffic    tput_type=UL
    # ...    server_ip=10.56.221.13
    # ...    server_connection=BTS0_VM
    # ...    client_connection=cpc_0
    # ...    client_iperf_path=/data/iperf
    # ...    tput_port=50001
    # ...    tput_value=100M
    # ...    tput_time=300s
    # Sleep    10s
    # ADB.Stop Traffic
    # Connect To VM
    # Disconnect VM
    ${res}    Run Keyword And Ignore Error
    ...    Get Parameter Detail By Selenium    object_name=MRBTS-11074/NRBTS-11074/NRCELL-1
    ...    filter_param=LTE-NR dynamic spectrum sharing mode
    ...    abbreviation=lteNrDssMode
    ...    product_type=vdu
    ${res}    Run Keyword And Ignore Error
    ...    Get Parameter Detail By Selenium    object_name=MRBTS-11074/NRBTS-11074/NRCELL-1
    ...    filter_param=Activate PRB blanking
    ...    abbreviation=actPRBBlanking
    ...    product_type=vcu
    # ADB.Prepare UE
    # Qualcomm8350.Start UL Traffic By MagicIperf
UE Set APN
    AT Operation    operation=start_call    number=6688
    # AT.UE Detach
    # AT.UE Attach
    # # AT.Voice Call
    # # AT.End Call
    # AT.Get UE IP
    # ${cid}    ${apn}    AT.Get IPV4 APN    pdu=IPV4V6
    # AT.Set IPV4 APN    1    IPV4V6    mdrb.nokia.com
    # ${cid}    ${apn}     AT.Get IPV4 APN    pdu=IPV4V6
    # AT.Set IPV4 APN    1    IPV4V6    stmdrb1106
    # ${cid}    ${apn}    AT.Get IPV4 APN
    # ADB.prepare UE
    # Qualcomm.Change APN    apn=stmdrb1106

