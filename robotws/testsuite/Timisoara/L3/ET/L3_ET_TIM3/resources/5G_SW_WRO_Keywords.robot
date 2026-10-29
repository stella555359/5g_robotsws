*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Michal Fluder
...              :contact: michal.fluder@nokia.com


Variables    ta5g_global_var
Resource     scripts/libraries_instances.robot
Library      ta5g_tshark
Library      ta5g_commissioning
Library      taf.ul.hanging_resources.listener    ${False}

*** Variables ***
${delta_set_collecting_counters_to_five_minutes}=
    ...    /home/ute/test_repository/testsuite/Wroclaw/RRM/5G_SW_WRO/resources/config/SBTS23R2/delta_set_collecting_counters_to_five_minutes.json
${dist_name}    MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1

*** Keywords ***
# Setup custom SCF file
Setup Custom SCF
    [Arguments]     ${scf}
    Get Scfc File    output_filepath=${CURDIR}/_scf.xml
    Send Full Commissioning    input_filepath=${scf}
    ${vlanId}=    ta5g_enb.Get Value From Scf    dist_name=${dist_name}    parameter_name=vlanId    scfc_filepath=${CURDIR}/_scf.xml
    check radios availability
    Perform Parameter Commissioning    dist_name=MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1    parameter=vlanId    value=${vlanId}

# Setup custom IPHY file
Setup Custom IPHY
    [Arguments]     ${iphy}
    Update Iphy Configuration And Modify Swconfig    iphy_xml_filepath=${iphy}

# Get VM IP address
Get VM IP
    ${ip}=  Run  ip a | grep eth0 -A 2 | grep -w inet | awk {'print $2'} | awk -F/ {'print $1'}
    Set Suite Variable  ${UTE_SSH_IP}  ${ip}

# Get VM info
Get VM Password
   [Documentation]  Get Current Vm password (also in singe run) needed to run syslog on remote nodes.
   set suite variable  ${KEYWORD_NAME}  Get VM Password
   ${password}=  run process  sudo cat /etc/ute/vncpasswd  shell=True
   set suite variable  ${UTE_SSH_PASSWORD}  ${password.stdout}

#Timezone
Sync Local Timezone For GNB AP And WTS
    OperatingSystem.Run    sudo timedatectl set-timezone "Europe/Bucharest"
    Sleep    5s    wait for timezone is changed.
    ${get_time_cmd}=    Set Variable    echo $(date "+%Y-%m-%d %H:%M:%S").$((`date "+%N"`/1000000))
    ${vm_date}=    Run    ${get_time_cmd}
    ${gnb_date}=    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 ${get_time_cmd} 2>/dev/null
    ${ap_date}=    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.200.1 ${get_time_cmd} 2>/dev/null
    Log    vm_time:${vm_date},gnb_time:${gnb_date},ap_time:${gnb_date}    console=True
#    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 timedatectl set-timezone "Europe/Bucharest"
#    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.200.1 timedatectl set-timezone "Europe/Bucharest"

# Tshark keywords
Verify Ngap Messages
    [Documentation]    Verification of captured messages transfered with NGAP protocol (NG interface: between GnB and AMF, WTS eth3).
    ...                By default keyword validates exact one occurrence of message.
    [Arguments]     ${packet_filter}    ${number_of_messages}=1    ${pcap_file_path}=${None}    ${timeout}=16    ${relation_symbol}= ==
    ...            ${alias}=${DEFAULT_NG_XN_TSHARK_ALIAS}    ${continue_on_failure}=${True}
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
    ...    pass_criteria=${relation_symbol}${number_of_messages}
    ...    pcap_file_path=${pcap_file_path}
    ...    timeout=${timeout}
    ...    continue_on_failure=${continue_on_failure}

Verify Uu Messages
    [Documentation]  Verification of messages captured on UU interface (between GnB and UE, WTS eth4).
    ...              By default keyword validates exact one occurrence of message.
    [Arguments]     ${packet_filter}    ${number_of_messages}=1    ${pcap_file_path}=${None}    ${timeout}=16    ${relation_symbol}= ==
    ...            ${alias}=${DEFAULT_UU_TSHARK_ALIAS}    ${continue_on_failure}=${True}
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
    ...    pass_criteria=${relation_symbol}${number_of_messages}
    ...    pcap_file_path=${pcap_file_path}
    ...    timeout=${timeout}
    ...    continue_on_failure=${continue_on_failure}

Verify Tcpdump Log
    [Documentation]    Verification of messages captured on gNB internal interface with tcpdump tool.
    ...                By default keyword validates exact one occurrence of the message.
    [Arguments]    ${packet_filter}    ${number_of_messages}=1    ${pcap_file_path}=default    ${timeout}=16    ${relation_symbol}= ==
    ...            ${alias}=${DEFAULT_TCPDUMP_ALIAS}    ${continue_on_failure}=${True}
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
    ...    pass_criteria=${relation_symbol}${number_of_messages}
    ...    pcap_file_path=${pcap_file_path}
    ...    timeout=${timeout}
    ...    continue_on_failure=${continue_on_failure}

Verify Loopback Messages
    [Documentation]    Verification of messages captured with tcpdump tool on Loopback (WTS lo) interface.
    ...                By default keyword validates exact one occurrence of message.
    [Arguments]    ${packet_filter}    ${number_of_messages}=1    ${pcap_file_path}=${None}    ${timeout}=16    ${relation_symbol}= ==
    ...            ${alias}=${DEFAULT_LOOPBACK_ALIAS}    ${continue_on_failure}=${True}
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
    ...    pass_criteria= ${relation_symbol}${number_of_messages}
    ...    pcap_file_path=${pcap_file_path}
    ...    timeout=${timeout}
    ...    continue_on_failure=${continue_on_failure}

# ANR Keywords

Verify Created NRADJNRCELL Object
    [Documentation]    Validate NRADJNRCELL object created in network plan by ANR feature.
    ...                Keyword compares requested parameters to values in SCF configuration.
    [Arguments]    ${NRADJNRCELL}    ${mcc}    ${mnc}    ${mncLength}    ${physCellId}    ${cellDepType}    ${nrarfcn}    ${ssbFrequency}
    ...            ${gNbId}    ${gNbIdLength}    ${lcrId}
    Should Be Equal As Integers    ${NRADJNRCELL.gnbPlmn.mcc}    ${mcc}
    Should Be Equal As Integers    ${NRADJNRCELL.gnbPlmn.mnc}    ${mnc}
    Should Be Equal As Integers    ${NRADJNRCELL.gnbPlmn.mncLength}    ${mncLength}
    Should Be Equal As Integers    ${NRADJNRCELL.physCellId}     ${physCellId}
    Should Be Equal    ${NRADJNRCELL.cellDepType}     ${cellDepType}
    Should Be Equal As Integers    ${NRADJNRCELL.nrarfcn}    ${nrarfcn}
    Should Be Equal As Integers    ${NRADJNRCELL.ssbFrequency}    ${ssbFrequency}
    Should Be Equal As Integers    ${NRADJNRCELL.gNbId}    ${gNbId}
    Should Be Equal As Integers    ${NRADJNRCELL.gNbIdLength}    ${gNbIdLength}
    Should Be Equal As Integers    ${NRADJNRCELL.lcrId}    ${lcrId}

Verify Created NRREL Object
    [Documentation]    Validate NRREL object created in network plan by ANR feature.
    ...                Keyword compares requested parameters to values in SCF configuration.
    [Arguments]    ${NRREL}    ${mcc}    ${mnc}    ${mncLength}    ${gNbId}    ${gNbIdLength}    ${lcrId}    ${removeNotAllowed}=${False}
    ...            ${cellIndividualSsbRsrpOffset}=0dB    ${cellIndividualSsbRsrqOffset}=0dB
    Should Be Equal    ${NRREL.cellIndividualSsbRsrpOffset}    ${cellIndividualSsbRsrpOffset}
    Should Be Equal    ${NRREL.cellIndividualSsbRsrqOffset}    ${cellIndividualSsbRsrqOffset}
    Should Be Equal As Integers    ${NRREL.gnbPlmn.mcc}    ${mcc}
    Should Be Equal As Integers    ${NRREL.gnbPlmn.mnc}    ${mnc}
    Should Be Equal As Integers    ${NRREL.gnbPlmn.mncLength}    ${mncLength}
    Should Be Equal As Integers    ${NRREL.gNbId}     ${gNbId}
    Should Be Equal As Integers    ${NRREL.gNbIdLength}     ${gNbIdLength}
    Should Be Equal As Integers    ${NRREL.lcrId}    ${lcrId}
    Should Be Equal    ${NRREL.removeNotAllowed}    ${removeNotAllowed}


# Counters
Set Counter Collecting Interval To Five Minutes
    [Documentation]    Changes the interval for PM Counters to be collected.
    Send Delta Commissioning    input_filepath=${delta_set_collecting_counters_to_five_minutes}
