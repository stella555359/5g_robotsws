*** Settings ***
Documentation
...    | Author:        | Michele, Ulm SQD64                          |
...    | Contact:       | I_PZ_ULM_SQD_64@internal.nsn.com            |
...    | Description:   | Keywords for CB010636                       |

Library    taf.ue
Library    ute_tshark
Library    String
Library    Collections

Library    taf.sbts.oam.coam.admin    WITH NAME    admin

Resource    testsuite/Ulm/SyVe/CB010636/resources/CB010636_Workbench_KW.robot


*** Variables ***
${DT_DL}                  DT_DL
${DT_UL}                  DT_UL
${DL_RATE}                20
${UL_RATE}                10
@{REGISTERED_UES}


*** Keywords ***
Init UE With APN And Collect Trace Then Start BGD TPut
    [Documentation]
    ...    | Setup UEs      | with UE ids.             |
    ...    | Return         | UE ALIAS                 |
    ...    | UE_1  is the First UE.  | or UE_0?             |
    ...    | Return         | UE_${UE_id} as ALIAS_UE      |

    [Arguments]   ${UE_id}=${1}    ${APN_name}=ulmsa

    Get PIP LIST For taf-ue    UE_id=${UE_id}
    # ToDo: Send adb reboot -s <SerialDevice>  Take it from __init__.py file.
    ${ALIAS_UE} =    Set Variable    UE_${UE_id}
    Set Test Variable    ${APN_name}

    IF  "${ALIAS_UE}" not in "${REGISTERED_UES}"
        Log To Console    ${\n}Require ${ALIAS_UE}
        # ToDo: instead of UE_1 use 4CC or SDX75 as UE Capability in __init__.py file. Require UE is returning: AndroidUe(TafUeAndroidPool_0)
        ${Require_UE_status}    ${UE_name}    Run Keyword And Warn On Failure    taf.ue.Require UE    ${ALIAS_UE}    capabilities=${ALIAS_UE}
        IF  "${Require_UE_status}" == "FAIL"
            Log To Console    ${\n}Require UE FAIL. Send "adb -s <ue_Serial> reboot" cmd under the NUC PC.  # ToDo: Add adb -s <ue_Serial> reboot
            Log To Console    ${\n}UE_name contain: ${UE_name}
        END
        Log To Console    ${\n}The ${ALIAS_UE} is ${UE_name}
        Append To List    ${REGISTERED_UES}   ${ALIAS_UE}
    ELSE
        Log To Console    ${\n}The ${ALIAS_UE} is already REGISTERED...
        IF  "${PREV_TEST_NAME}" != "${EMPTY}"
            Log To Console    ${\n}... But, at the end of Test is deregistered.
            ${UE_name}    taf.ue.Require UE    ${ALIAS_UE}    capabilities=${ALIAS_UE}
            Log To Console    ${\n}The ${ALIAS_UE} is again Registered as ${UE_name}
        END
    END
    Set Test Variable    ${FirstUE}    ${ALIAS_UE}    # The ${FirstUE} is used in Teardown! BUT it is really needed? will still FAIL or?

#    Log To Console   ${\n}Rebooting ${ALIAS_UE}...    # ToDo: Check if really necessary to Reboot the UE.
#    taf.ue.reboot UE    ${ALIAS_UE}  # ToDo: Send adb reboot -s <SerialDevice>  Take it from __init__.py file.
#    Log To Console   ${\n} Done!

    Log To Console    ${\n}Detach ${ALIAS_UE}
    taf.ue.Detach UE    ${ALIAS_UE}

    Run Keyword And Warn On Failure    CB010636_Workbench_KW.Start Tcpdump On gNB Trace   UE_id=${UE_id}
    Log To Console    ${\n}Attach ${ALIAS_UE}
    taf.ue.Attach UE    ${ALIAS_UE}

    Stop Tcpdump on gNB trace   UE_id=${UE_id}

    Run Keyword And Warn On Failure    taf.ue.Log UE Info    ${ALIAS_UE}

    ${get_UE_Info_Status}  ${get_UE_Info_Dictionary}  Run Keyword And Warn On Failure    taf.ue.Get UE Info    ${ALIAS_UE}

    Set Test Variable    ${${ALIAS_UE}_IDENTITY_DICTIONARY}    ${EMPTY}

    IF  '${get_UE_Info_Status}' == 'PASS'
        Log  The NR_STATE is: ${get_UE_Info_Dictionary['nr_state']}   level=WARN   console=${P_console}
        ${UE_IDENTITY_DICTIONARY} =    Create Dictionary
        Set To Dictionary    ${UE_IDENTITY_DICTIONARY}    device_model    ${get_UE_Info_Dictionary['device_model']}
        Set To Dictionary    ${UE_IDENTITY_DICTIONARY}    commercial_name    ${get_UE_Info_Dictionary['commercial_name']}
        Set To Dictionary    ${UE_IDENTITY_DICTIONARY}    build_version    ${get_UE_Info_Dictionary['build_version']}
        Set To Dictionary    ${UE_IDENTITY_DICTIONARY}    serial    ${get_UE_Info_Dictionary['serial']}
        Set To Dictionary    ${UE_IDENTITY_DICTIONARY}    imei    ${get_UE_Info_Dictionary['imei']}
        Set To Dictionary    ${UE_IDENTITY_DICTIONARY}    imsi    ${get_UE_Info_Dictionary['imsi']}
        Set To Dictionary    ${UE_IDENTITY_DICTIONARY}    cell_id    ${get_UE_Info_Dictionary['cell_id']}
        Set To Dictionary    ${UE_IDENTITY_DICTIONARY}    nr_state    ${get_UE_Info_Dictionary['nr_state']}
        Set To Dictionary    ${UE_IDENTITY_DICTIONARY}    pci    ${get_UE_Info_Dictionary['pci']}
        IF  $get_UE_Info_Dictionary.get('pci') == '-1' and $get_UE_Info_Dictionary.get('cell_info', {}).get('ltePci') is not None
          Set To Dictionary  ${UE_IDENTITY_DICTIONARY}  ltePci  ${get_UE_Info_Dictionary['cell_info']['ltePci']}
        END
        Set To Dictionary    ${UE_IDENTITY_DICTIONARY}    enb_id    ${get_UE_Info_Dictionary['enb_id']}
        Set To Dictionary    ${UE_IDENTITY_DICTIONARY}    signal_strength    ${get_UE_Info_Dictionary['signal_strength']}
        Set To Dictionary    ${UE_IDENTITY_DICTIONARY}    sinr    ${get_UE_Info_Dictionary['sinr']}

        Set Test Variable    ${${ALIAS_UE}_IDENTITY_DICTIONARY}    ${UE_IDENTITY_DICTIONARY}
    ELSE
        Log To Console    ${\n}Please check if the "taf.ue.Get UE Info" is supported for this UE Type.
    END
    ${UE_IDENTITY_DICTIONARY_pretty_str}=    builtin.Evaluate   pprint.pformat(${UE_IDENTITY_DICTIONARY})   modules=pprint
    Log To Console    ${\n}Device ${ALIAS_UE} Identity:${\n}${UE_IDENTITY_DICTIONARY_pretty_str}

    ${contains_correct_APN}    IPS Contains APN Name    UE_id=${ALIAS_UE}    APN_name=${APN_name}

    IF    ${contains_correct_APN} == False
        Log To Console    ${\n}The UE_${UE_id} APN is not set to "${APN_name}"... try to set it automatically...
        Log To Console    OR, Please set the APN manually. (KW not working for all UEs Type)${\n}
        Switch APN    UE_id=${UE_id}    APN_name=${APN_name}
    END

    Log To Console    ${\n}Start DL background traffic. (1MBit/sec)
    Run Keyword and Continue on Failure   taf.ue.Start Data Transfer    dt_name=DL_Background_${ALIAS_UE}    ue_alias=${ALIAS_UE}
    ...    direction=dl
    ...    throughput=1 Mbits/sec
    ...    protocol=udp
    ...    packet=1330
    ...    bearer_alias=UeAutomatic
    ...    parallel=1
    ...    apn=${APN_name}

    RETURN     ${ALIAS_UE}


IPS Contains APN Name
    [Documentation]
    ...    | Check if the IPS contain the APN string     | with UE ids.    |
    [Arguments]   ${UE_id}=${1}    ${APN_name}=ulmsa

    Sleep    30sec    Wait that SIMs is present
    ${IPS_Value}    Run Keyword And Warn On Failure    taf.ue.Get UE Info    ${UE_id}    IPS
    ${IPS_String}=    Convert To String    ${IPS_Value}
    ${contains_correct_APN}=    Run Keyword And Return Status    Should Contain    ${IPS_String}    ${APN_name}/

    RETURN     ${contains_correct_APN}


Switch APN
    [Documentation]
    ...    | Switch APN     | with UE ids.             |
    ...    | APNs should be already present.    |  Please Create your APNs before.       |
    ...    | KW will FAIL if the UE in not able to change the APN.  |  comment this KW if you need to change the APN manually.  |
    [Arguments]   ${UE_id}=${1}    ${APN_name}=ulmsa    ${path_to_apn}=Connections,Mobile networks,Access Point Names
    ${ALIAS_UE} =    Set Variable    UE_${UE_id}

    # https://taf-ue-android.docs.taf.ute.nsn-rdnet.net/en/latest/example/robot/change_network_mode.html
    # https://taf-ue-android.docs.taf.ute.nsn-rdnet.net/en/latest/example/  (continue below! String too long!)
    # robot/change_apn_connect_pdns.html#example-robot-change-apn-connect-pdns--page-root

    Log To Console    ${\n}Switch APN using the UE GUI...

    IPS Contains APN Name    UE_id=${ALIAS_UE}    APN_name=${APN_name}

    # ulmsamqi4.nokia.com.mnc001.mcc540.gprs
    Run Keyword And Warn On Failure    taf.ue.Change Apn    ${ALIAS_UE}  # ToDo: Change to ${APN_name} and Check once the issue is solved...
        ...    ${APN_name}
        ...    apn_switcher_widget=android.widget.RadioButton
        # ...    labels_to_apn_settings="Network & internet,SIMs,Nokia,Access Point Names"    # keep for reference
        ...    labels_to_apn_settings=${path_to_apn}    # ToDo: Check if this labels_to_apn_settings could be taken from __init__.py

    Log To Console    ${\n}Detach ${ALIAS_UE}
    taf.ue.Detach UE    ${ALIAS_UE}
    CB010636_Workbench_KW.Start Tcpdump On gNB Trace   UE_id=${ALIAS_UE}
    Log To Console    ${\n}Attach ${ALIAS_UE} to enable the new APN: ${APN_name}
    taf.ue.Attach UE    ${ALIAS_UE}

    Stop Tcpdump On gNB Trace   UE_id=${ALIAS_UE}

    ${contains_correct_APN}    IPS Contains APN Name    UE_id=${ALIAS_UE}    APN_name=${APN_name}
    IF    ${contains_correct_APN} == False    Fail    APN is not set to "${APN_name}"


Get PIP LIST For taf-ue
    [Arguments]   ${UE_id}=${1}
    ${ue_pc_alias} =    connect.Connect to UE PC    ue_id=${UE_id - 1}
    ${Lib_on_pc} =    ssh.execute  pip list | grep taf.ue    connection=${ue_pc_alias}
    Log To Console    ${\n}Installed Library under the NUC PC of UE_${UE_id}: ${\n}${Lib_on_pc}


Check Multiple UE Info
    [Arguments]   ${UE_id}=${1}
    ${ALIAS_UE} =    Set Variable    UE_${UE_id}
    Set Test Variable    ${ALIAS_UE}

    Run Keyword And Warn On Failure    taf.ue.Validate Ue Info    ${ALIAS_UE}    5G_STATE    5G_SA
    Run Keyword And Warn On Failure    taf.ue.Validate Ue Info    ${ALIAS_UE}    preferred_net_mode    NR_LTE_TDSCDMA_CDMA_EVDO_GSM_WCDMA
    Run Keyword And Warn On Failure    taf.ue.Validate Ue Info    ${ALIAS_UE}    nr_state    5G_SA
    Run Keyword And Warn On Failure    taf.ue.Validate Ue Info    ${ALIAS_UE}    IPS    ulmsa/rmnet_data1


Start iPerf3 Data Transfer UL DL
    [Arguments]    ${ue_alias}=UE_1    ${ue_UL_Rate}=${UL_RATE}    ${ue_DL_Rate}=${DL_RATE}    ${port_value}=${None}
    Log To Console    ${\n}iPerf3! Start Data Transfer in UL for ${ue_alias} with ${ue_UL_Rate} Mbits/sec
    taf.ue.Start Data Transfer    dt_name=${DT_UL}_${ue_alias}    ue_alias=${ue_alias}
    ...    direction=ul
    ...    throughput=${ue_UL_Rate} Mbits/sec
    ...    protocol=udp
    ...    packet=1330
    ...    bearer_alias=UeAutomatic
    ...    parallel=1
    ...    port=${port_value}
    ...    apn=${APN_name}

    Log To Console    ${\n}iPerf3! Start Data Transfer in DL for ${ue_alias} with ${ue_DL_Rate} Mbits/sec
    taf.ue.Start Data Transfer    dt_name=${DT_DL}_${ue_alias}    ue_alias=${ue_alias}
    ...    direction=dl
    ...    throughput=${ue_DL_Rate} Mbits/sec
    ...    protocol=udp
    ...    packet=1330
    ...    bearer_alias=UeAutomatic
    ...    parallel=1
    ...    port=${port_value}
    ...    apn=${APN_name}


Start iPerf3 TCP Data Transfer UL DL
    # adb shell iperf3 -c 10.47.194.203 -i 1 -M 1400 -l 1400 -tunl -p 50000 --bidir -P 5
    # At AppServer: iperf3 -si1 -p50000
    [Arguments]    ${ue_alias}=UE_1    ${port_value}=${None}  ${duration}=60s  ${parallel_thread}=8
    Log To Console    ${\n}iPerf3! Start TCP Data Transfer in UL for ${duration} using ${ue_alias}...
    taf.ue.Start Data Transfer
    ...    dt_name=TCP_${DT_UL}_${ue_alias}
    ...    ue_alias=${ue_alias}
    ...    direction=ul
    ...    protocol=tcp
    ...    duration=${duration}
    ...    packet=1400B
    ...    port=${port_value}
    ...    version=3
    ...    parallel_thread=${parallel_thread}
    ...    max_segment_size=1400
    ...    apn=${APN_name}

    Log To Console    ${\n}iPerf3! Start TCP Data Transfer in DL for ${duration} using ${ue_alias}...
    taf.ue.Start Data Transfer
    ...    dt_name=TCP_${DT_DL}_${ue_alias}
    ...    ue_alias=${ue_alias}
    ...    direction=dl
    ...    protocol=tcp
    ...    duration=${duration}
    ...    packet=1400B
    ...    port=${port_value}
    ...    version=3
    ...    parallel_thread=${parallel_thread}
    ...    max_segment_size=1400
    ...    apn=${APN_name}


Start iPerf3 Parallel TCP Data Transfer
    # adb shell iperf3 -c 10.47.194.203 -i 1 -M 1400 -l 1400 -tunl -p 50000 --bidir -P 5
    # At AppServer: iperf3 -si1 -p50000
    [Arguments]    ${ue_alias}=UE_1    ${port_value}=${None}  ${duration}=60s
    Log To Console    ${\n}iPerf3! Start TCP Data Transfer in Parallel for ${ue_alias}...
    taf.ue.Start Data Transfer
    ...    dt_name=TCP_${DT_UL}_${ue_alias}
    ...    ue_alias=${ue_alias}
    ...    direction=simultaneous_ul_dl
    ...    protocol=tcp
    ...    duration=${duration}
    ...    packet=1400B
    ...    port=${port_value}
    ...    version=2
    ...    parallel_thread=8
    ...    max_segment_size=1400
    ...    apn=${APN_name}


Start PING
    [Arguments]    ${ue_alias}=UE_1    ${direction}=ul    ${duration}=60s
    Log To Console    ${\n}PING in ${direction} for ${ue_alias}...
    taf.ue.Start Data Transfer
    ...    dt_name=${direction}_PING_${ue_alias}
    ...    ue_alias=${ue_alias}
    ...    direction=${direction}
    ...    protocol=icmp
    ...    duration=${duration}
    ...    ping_host_ip=10.47.194.203
    ...    ping_count=10
    ...    apn=${APN_name}
    #...    allowed_packet_loss=100
    # ToDo: Add Additional Parameters: deadline, count, interval, packet_size
