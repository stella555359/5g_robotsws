*** Settings ***
Documentation
...              test scenario author: Jakub Zapadka
...              contact: jakub.zapadka@nokia.com
...              test automation author: Konrad Krymowski, Tomasz Domagala
...              contact: konrad.krymowski@nokia.com; tomasz.domagala@nokia.com
...              maintenance: Tomasz Domagala    contact: tomasz.domagala@nokia.com

Resource    ../Resources/CB001049_keywords.robot
Resource    ../../CB009131/Resources/9131_Keywords.robot

*** Variables ***
${x2c_ipv4}=    ${tl.gnbs[0].cu.x2c.v4}
${x2u_ipv4}=    ${tl.gnbs[0].cu.x2u.v4}
${xnc_ipv4}=    ${tl.gnbs[0].cu.xnc.v4}
${xnu_ipv4}=    ${tl.gnbs[0].cu.xnu.v4}
${ngc_ipv4}=    ${tl.gnbs[0].cu.ngc.v4}
${ngu_ipv4}=    ${tl.gnbs[0].cu.ngu.v4}

${dummy_ip}=    10.20.30.40

*** Keywords ***
5GC001049-A01_Feature_status_change
    Set actDynamicFirewall Feature Status
    Check Nft Ruleset
    Perform Nmap Scan
    [Teardown]    Run Keywords    Set ActDynamicFirewall Feature Status    status=false    AND
    ...                           Delete All NRADJGNB Objects

Feature_status_change_ASOF
    Load SCF and update RU SW if necessary    scf_path=${CURDIR}/../Resources/new_scf/ASOF_422_T1_T2_T9.xml
    Wait Until Keyword Succeeds               20 min  60sec    Wait until BTS reach Configured or OnAir state
    Set actDynamicFirewall Feature Status     status=true
    Check Nft Ruleset T1
    Check Classifier Table T1
    [Teardown]    Set ActDynamicFirewall Feature Status    status=false

5GC001049-A02_BTS_startup_first_startup_or_after_reset_CPlane
    [Documentation]   Test number 2 have to be directly after Test number 1
    Set actDynamicFirewall Feature Status
    Reboot BTS and wait until available
    Check Nft Ruleset
    Perform Nmap Scan
    [Teardown]    Set ActDynamicFirewall Feature Status    status=false

BTS_startup_first_startup_or_after_reset_CPlane_ASOF
    Load SCF and update RU SW if necessary    scf_path=${CURDIR}/../Resources/new_scf/ASOF_422_T1_T2_T9.xml
    Wait Until Keyword Succeeds               20 min  60sec    Wait until BTS reach Configured or OnAir state
    Set actDynamicFirewall Feature Status     status=true
    Check Nft Ruleset T1
    Reboot BTS and wait until available
    Wait until keyword succeeds               20 min  60sec  Check if BTS status is Configured or OnAir
    Set actDynamicFirewall Feature Status     status=true
    Check Nft Ruleset T1
    [Teardown]    Set ActDynamicFirewall Feature Status    status=false

Adding_new_O&M_controlled_peer_CPlane
    Load SCF and update RU SW if necessary    scf_path=${CURDIR}/../Resources/new_scf/ASOF_422_T5.xml
    Wait Until Keyword Succeeds               20 min  60sec    Wait until BTS reach Configured or OnAir state
    Set actDynamicFirewall Feature Status     status=true

    Log    Adding all XNLINK objects...    console=${TRUE}
    @{xncplane_addresses}=  Create List     ${xnc_ipv4_1}
    ...                                     ${xnc_ipv4_2}
    ...                                     ${xnc_ipv6_1}
    ...                                     ${xnc_ipv6_2}
    ${index}=    Set Variable    0
    @{xnLinkId_list}=  Create List     1  2  3  4
    @{xnTnlId_list}=   Create List     1  2  1  2
    FOR    ${address}    IN    @{xncplane_addresses}
        ${xnlink_string}=  Catenate
        ...    [{'parameterName': 'cPlaneIpAddr', 'operation': 'update', 'value': '${address}'},
        ...    {'parameterName': 'cPlaneIpAddrCtrl', 'operation': 'update', 'value': 'oamControlled'},
        ...    {'parameterName': 'xnLinkId', 'operation': 'update', 'value': ${xnLinkId_list[${index}]}},
        ...    {'parameterName': 'xnTnlId', 'operation': 'update', 'value': ${xnTnlId_list[${index}]}}]
        ${xnlink}=  Evaluate  ${xnlink_string}
        ${index} =    Evaluate    ${index}+1
        Log    Adding XNLINK-${index}...    console=${TRUE}
        Manage Object   object_name=XNLINK-${index}    parameter=${xnlink}    operation=create
    END
    Log    All XNLINK objects added correctly   console=${TRUE}

    Log    Adding missing SERVEDAMF objects (2, 3 and 4)...    console=${TRUE}
    @{servedamf_addresses}=  Create List    ${amfIPv4_2}
#    ...                                     10.94.232.6
    ...                                     ${amfIPv6_1}
    ...                                     ${amfIPv6_2}
    ${index}=    Set Variable    0
    @{ngTnlId_list}=   Create List     2  1  2
    FOR    ${address}    IN    @{servedamf_addresses}
        ${servedamf_string}=    Catenate
        ...     [{'parameterName': 'administrativeState', 'operation': 'update', 'value': 'Unlocked'},
        ...     {'parameterName': 'defaultAMF', 'operation': 'update', 'value': 'false'},
        ...     {'parameterName': 'amfIPAddress', 'operation': 'update', 'value': '${address}'},
        ...     {'parameterName': 'amfIPAddressTTL', 'operation': 'update', 'value': '1'},
        ...     {'parameterName': 'ngTnlId', 'operation': 'update', 'value': ${ngTnlId_list[${index}]}}]
        ${servedamf}=    Evaluate    ${servedamf_string}
        ${index}=    Evaluate    ${index}+2
        Log     Adding SERVEDAMF-${index}...  console=${TRUE}
        Manage Object   object_name=SERVEDAMF-${index}    parameter=${servedamf}    operation=create
        ${index}=    Evaluate    ${index}-1
    END
    Log    All SERVEDAMF objects added correctly   console=${TRUE}

    Check Nft Ruleset T5

    [Teardown]    Set actDynamicFirewall Feature Status     status=false

Change_of_CP_IP_address_of_O&M_controlled_peer_CPlane
    Load SCF and update RU SW if necessary    scf_path=${CURDIR}/../Resources/new_scf/ASOF_422_T6_T7.xml
    Wait Until Keyword Succeeds               20 min  60sec    Wait until BTS reach Configured or OnAir state
    Set actDynamicFirewall Feature Status     status=true

    @{servedamf_addresses}=  Create List    ${amfIPv4_2}
#    ...                                     10.94.232.6
    ...                                     ${amfIPv6_1}
    ...                                     ${amfIPv6_2}

    scf.Load Scf    ${CURDIR}/../Resources/new_scf/ASOF_422_T6_T7.xml
    @{servedamf_dists_list}=    scf.get_all_dist_names_of_specific_class     com.nokia.srbts.nrbts:SERVEDAMF
    Log    Removing first SERVEDAMF object (cannot be changed)...    console=${TRUE}
    Remove From List   ${servedamf_dists_list}    0
    Log    Creating delta...    console=${TRUE}
    ${delta}=    Set Variable    [
    ${index}=    Set Variable    0
    FOR     ${servedamf_dist}    IN    @{servedamf_dists_list}
            ${new_servedamf_ip}=        Increase Ip Address  ${servedamf_addresses}[${index}]
            ${delta}=    Catenate       ${delta}
            ...                         {'distName': '${servedamf_dist}',
            ...                         'operation': 'update',
            ...                         'parameters': [{
            ...                         'parameterName': 'amfIPAddress',
            ...                         'operation': 'update',
            ...                         'value': '${new_servedamf_ip}'}]},
            ${index}=    Evaluate    ${index}+1
    END
    ${delta}=    Catenate    ${delta}    ]
    ${delta}=    Evaluate    ${delta}
    Log    Created delta: ${delta}    console=${TRUE}

    ${conn}=  Connect To ADMIN
    Recommission Parameters By Delta    ${delta}    connection=${conn}

    Wait Until Keyword Succeeds    10 min    30 sec    Wait until BTS reach state    state=OnAir

    Check Nft Ruleset T6

    [Teardown]  Set actDynamicFirewall Feature Status     status=false

Blocking_access_of_O&M_controlled_peer_CPlane
    Load SCF and update RU SW if necessary    scf_path=${CURDIR}/../Resources/new_scf/ASOF_422_T6_T7.xml
    Wait Until Keyword Succeeds               20 min  60sec    Wait until BTS reach Configured or OnAir state
    Set actDynamicFirewall Feature Status     status=true

    ${EMPTY_LIST}=    Create List
    scf.Load Scf    ${CURDIR}/../Resources/new_scf/ASOF_422_T6_T7.xml
    @{servedamf_dists_list}=    scf.get_all_dist_names_of_specific_class     com.nokia.srbts.nrbts:SERVEDAMF
    Log    Detected SERVEDAMF Objects: ${servedamf_dists_list}    console=${TRUE}
    FOR    ${servedamf_dist}    IN    @{servedamf_dists_list}
        ${rest}    ${servedamf_name}=    Split String From Right      ${servedamf_dist}    /    1
        ${rest}    ${servedamf_number}=    Split String From Right      ${servedamf_name}    -    1
        Continue For Loop If    ${servedamf_number} == 1
        Log    Removing SERVEDAMF (${servedamf_name})...    console=${TRUE}
        Manage Object    object_name=${servedamf_name}    parameter=${EMPTY_LIST}    operation=delete
    END

    @{xnlink_dists_list}=    scf.get_all_dist_names_of_specific_class     com.nokia.srbts.nrbts:XNLINK
    Log    Detected XNLINKS Objects: ${xnlink_dists_list}    console=${TRUE}
    FOR    ${xnlink_dist}    IN    @{xnlink_dists_list}
        ${rest}    ${xnlink_name}=    Split String From Right      ${xnlink_dist}    /    1
        Log    Removing XNLINKS (${xnlink_name})...    console=${TRUE}
        Manage Object    object_name=${xnlink_name}    parameter=${EMPTY_LIST}    operation=delete
    END

    Check Nft Ruleset T7

    [Teardown]    Set actDynamicFirewall Feature Status     status=false

5GC001049-A03_Allowing_access_of_gNB_controlled_neighbor_BTS_using_ANR_procedure_CPlane
    Set actDynamicFirewall Feature Status
    ${new_ipv4_address}=    Get New IPv4 Address    ${xnc_ipv4}
    Set IPv4 Address For XN C-plane                 ${new_ipv4_address}
    Run Keyword And Ignore Error    Power Off UE    port=3
    Run Keyword And Ignore Error    Power Off UE    port=5

    Log    FIRST UE HANDOVER...    console=True
    Prepare And Attach UEs    ue_alias=AT_BASED_UE_2    ue_operator=5    pdu_number=5
    Connect To UE PC And Perform Traffic Via SSH    ue_pc_ip=10.42.22.85    ue_serial=129539da    port=2138    ip_addr=10.42.197.170

    Log    SECOND UE HANDOVER...    console=True
    Prepare And Attach UEs    ue_alias=AT_BASED_UE_1    ue_operator=3    pdu_number=3
    Connect To UE PC And Perform Traffic Via SSH    ue_pc_ip=10.42.22.85    ue_serial=f3b53d67    port=2137    ip_addr=10.42.197.170

    Check Nft Ruleset
    Run Keyword And Ignore Error    Power Off UE    port=3
    Run Keyword And Ignore Error    Power Off UE    port=5
    [Teardown]    Run Keywords    Set ActDynamicFirewall Feature Status    status=false
    ...           AND             Set IPv4 Address For XN C-plane          ${xnc_ipv4}
    ...           AND             Delete All NRADJGNB Objects

5GC001049-A04_Blocking_access_of_gNB_controlled_neighbor_BTS_CPlane
    ${new_ipv4_address}=    Get New IPv4 Address    ${xnc_ipv4}
    Set IPv4 Address For XN C-plane                 ${new_ipv4_address}
    Reboot BTS and wait until available
    ${status}=    Run Keyword And Return Status    Check if Object Exists in Scf File
    ...           dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}    object_name=XNLINK
    Run Keyword If    '${status}' == 'False'    Run Keywords
    ...                                         Check Nft Ruleset
    ...                                         Check Addresses Nft After Handover Not Exist
    [Teardown]    Run Keywords    Set ActDynamicFirewall Feature Status    status=false
    ...           AND             Set IPv4 Address For XN C-plane          ${xnc_ipv4}
    ...           AND             Delete All NRADJGNB Objects

5GC001049-A05_Adding_new_O&M_controlled_peer_CPlane
    Set ActDynamicFirewall Feature Status     status=true
    ${new_ipv4_address}=    Get New IPv4 Address    ${xnc_ipv4}
    Set IPv4 Address For XN C-plane                 ${new_ipv4_address}
    Create Proper XNLINKs On BTS
    Create Proper SERVEDAMFs On BTS
    Check Nft Ruleset
    [Teardown]    Run Keywords    Set ActDynamicFirewall Feature Status    status=false
    ...           AND             Set IPv4 Address For XN C-plane          ${xnc_ipv4}
    ...           AND             Delete All NRADJGNB Objects

5GC001049-A06_Change_of_CP_IP_address_of_O&M_controlled_peer_CPlane
    Set ActDynamicFirewall Feature Status
    ${new_ipv4_address}=    Get New IPv4 Address    ${xnc_ipv4}
    Set IPv4 Address For XN C-plane                 ${new_ipv4_address}
    Change SERVEDAMFs To Fake IPS
    Check Fake Nft Ruleset
    [Teardown]    Run Keywords    Set ActDynamicFirewall Feature Status    status=false
    ...           AND             Set IPv4 Address For XN C-plane          ${xnc_ipv4}
    ...           AND             Delete All NRADJGNB Objects

5GC001049-A07_Blocking_access_of_O&M_controlled_peer_CPlane
    Set ActDynamicFirewall Feature Status
    ${new_ipv4_address}=    Get New IPv4 Address    ${xnc_ipv4}
    Set IPv4 Address For XN C-plane                 ${new_ipv4_address}
    Delete XNLINK objects
    Delete SERVEDAMF objects
    Check Fake Nft Ruleset
    [Teardown]    Run Keywords    Set ActDynamicFirewall Feature Status    status=false
    ...           AND             Set IPv4 Address For XN C-plane          ${xnc_ipv4}
    ...           AND             Delete All NRADJGNB Objects

5GC001049-A08_X2_Addition_Modification_access_on_SgNB_CPlane
    Set ActDynamicFirewall Feature Status
    ${new_ipv4_address}=    Get New IPv4 Address    ${xnc_ipv4}
    Set IPv4 Address For XN C-plane                 ${new_ipv4_address}
    Check if Object Exists in Scf File    dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}    object_name=LTEENB
    Get iptables Output
    Get ip6tables Output
    [Teardown]    Run Keywords    Set ActDynamicFirewall Feature Status    status=false
    ...           AND             Set IPv4 Address For XN C-plane          ${xnc_ipv4}
    ...           AND             Delete All NRADJGNB Objects

Addition_Modification_access_on_SgNB_CPlane_ASOF
    Load SCF and update RU SW if necessary    scf_path=${CURDIR}/../Resources/new_scf/ASOF_422_T8.xml
    Wait Until Keyword Succeeds               20 min  60sec    Wait until BTS reach Configured or OnAir state
    Set actDynamicFirewall Feature Status     status=true
    Wait Until Keyword Succeeds               20 min  60sec    Check if LTEENB object exists
    SSHLibrary.Open Connection    192.168.255.129
    SSHLibrary.Login      toor4nsn  oZPS0POrRieRtu
    Sleep    5            reason=Wait until terminal execute the command

    SSHLibrary.Write      nft list chain "ip filter" CP_TRAFFIC_5G
    Sleep    2            reason=Wait until terminal execute the command
    ${nft_traffic_v4}=    SSHLibrary.Read
    Should Contain Any    ${nft_traffic_v4}    counter packets 1    counter packets 2    counter packets 3
    ...                                        counter packets 4    counter packets 5    counter packets 6
    ...                                        counter packets 7    counter packets 8    counter packets 9

    SSHLibrary.Write      nft list chain "ip filter" NGXN_CHAIN
    Sleep    2            reason=Wait until terminal execute the command
    ${nft_ngxn_v4}=       SSHLibrary.Read
    Should Contain        ${nft_ngxn_v4}    ${x2c_ipv4_1}
    Should Contain        ${nft_ngxn_v4}    accept

    SSHLibrary.Write      nft list chain "ip6 filter" CP_TRAFFIC_5G
    Sleep    2            reason=Wait until terminal execute the command
    ${nft_traffic_v6}=    SSHLibrary.Read
    Should Not Contain    ${nft_traffic_v6}    does not exist

    SSHLibrary.Write      nft list chain "ip6 filter" NGXN_CHAIN
    Sleep    2            reason=Wait until terminal execute the command
    ${nft_ngxn_v6}=       SSHLibrary.Read
    Should Not Contain    ${nft_ngxn_v6}    does not exist
    [Teardown]    Run Keywords    SSHLibrary.Close Connection
    ...    AND                    Set ActDynamicFirewall Feature Status    status=false

5GC001049-B09_BTS_startup_first_startup_or_after_reset_UPlane
    [Documentation]    Test number 9 have to be directly after Test number 2
    Set ActDynamicFirewall Feature Status
    Check Nft Ruleset
    [Teardown]    Run Keywords    Set ActDynamicFirewall Feature Status    status=false
    ...           AND             Delete All NRADJGNB Objects

BTS_startup_first_startup_or_after_reset_UPlane_ASOF
    Load SCF and update RU SW if necessary    scf_path=${CURDIR}/../Resources/new_scf/ASOF_422_T1_T2_T9.xml
    Wait Until Keyword Succeeds               20 min  60sec    Wait until BTS reach Configured or OnAir state
    Set actDynamicFirewall Feature Status     status=true
    Check Classifier Table T1
    Reboot BTS and wait until available
    Wait until keyword succeeds               20 min  60sec  Check if BTS status is Configured or OnAir
    Set actDynamicFirewall Feature Status     status=true
    Check Classifier Table T1
    [Teardown]    Set ActDynamicFirewall Feature Status    status=false

5GC001049-B10_Adding_new_O&M_controlled_peer_UPlane
    Set ActDynamicFirewall Feature Status
    ${new_ipv4_address}=    Get New IPv4 Address    ${xnu_ipv4}
    Set IPv4 Address For XN U-plane                 ${new_ipv4_address}
    Create Proper NRADJGNBs On BTS
    Check Nft Ruleset
    [Teardown]    Run Keywords    Set ActDynamicFirewall Feature Status    status=false
    ...           AND             Set IPv4 Address For XN U-plane          ${xnu_ipv4}
    ...           AND             Delete All NRADJGNB Objects

Adding_new_O&M_controlled_peer_UPlane_ASOF
    Load SCF and update RU SW if necessary    scf_path=${CURDIR}/../Resources/new_scf/ASOF_422_T1_T2_T9.xml
    Wait Until Keyword Succeeds               20 min  60sec    Wait until BTS reach Configured or OnAir state
    Set actDynamicFirewall Feature Status     status=true
    Check Classifier Table T1
    [Teardown]    Set ActDynamicFirewall Feature Status    status=false

Change_of_O&M_controlled_peer_UPlane_ASOF
    Load SCF and update RU SW if necessary    scf_path=${CURDIR}/../Resources/new_scf/ASOF_422_T1_T2_T9.xml
    Wait Until Keyword Succeeds               20 min  60sec    Wait until BTS reach Configured or OnAir state
    Set actDynamicFirewall Feature Status     status=true
    Change xnLinkRef Parameters
    Check Classifier Table T1
    [Teardown]    Set ActDynamicFirewall Feature Status    status=false

Blocking_access_of_O&M_controlled_peer_UPlane_ASOF
    Load SCF and update RU SW if necessary    scf_path=${CURDIR}/../Resources/new_scf/ASOF_422_T1_T2_T9.xml
    Wait Until Keyword Succeeds               20 min  60sec    Wait until BTS reach Configured or OnAir state
    Set actDynamicFirewall Feature Status     status=true
    Delete NRADJGNB Objects
    Check Classifier Table T12
    [Teardown]    Set ActDynamicFirewall Feature Status    status=false

5GC001049-B11_Change_of_O&M_controlled_peer_UPlane
    Set ActDynamicFirewall Feature Status
    ${new_ipv4_address}=    Get New IPv4 Address    ${xnu_ipv4}
    Set IPv4 Address For XN U-plane                 ${new_ipv4_address}
    Change xnLinkRef Parameters
    Wait Until keyword Succeeds    12x    2min    Check if BTS in given state    state=${state}
    Check Nft Ruleset
    [Teardown]    Run Keywords    Set ActDynamicFirewall Feature Status    status=false
    ...           AND             Set IPv4 Address For XN U-plane          ${xnu_ipv4}
    ...           AND             Delete All NRADJGNB Objects

5GC001049-B12_Blocking_access_of_O&M_controlled_peer_UPlane
    Set ActDynamicFirewall Feature Status
    ${new_ipv4_address}=    Get New IPv4 Address    ${xnu_ipv4}
    Set IPv4 Address For XN U-plane                 ${new_ipv4_address}
    ${empty_list}=    Create List
    Manage Object    object_name=NRADJGNB-1    parameter=${empty_list}    operation=delete
    Manage Object    object_name=NRADJGNB-2    parameter=${empty_list}    operation=delete
    Check Fake Nft Ruleset
    [Teardown]    Run Keywords    Set ActDynamicFirewall Feature Status    status=false
    ...           AND             Set IPv4 Address For XN U-plane          ${xnu_ipv4}
    ...           AND             Delete All NRADJGNB Objects

5GC001049-B13_NG_PDU_Session_Resource_Setup_Modification_UPlane
    Set ActDynamicFirewall Feature Status
    ${new_ipv4_address}=    Get New IPv4 Address    ${xnu_ipv4}
    Set IPv4 Address For XN U-plane                 ${new_ipv4_address}
    Start Tcpdump
    Run Keyword And Ignore Error    Power Off UE    port=3
    Run Keyword And Ignore Error    Power Off UE    port=5

    Log    FIRST UE HANDOVER...    console=True
    Prepare And Attach UEs    ue_alias=AT_BASED_UE_2    ue_operator=5    pdu_number=5
    Connect To UE PC And Perform Traffic Via SSH    ue_pc_ip=10.42.22.85    ue_serial=129539da    port=2138    ip_addr=10.42.197.170

    Log    SECOND UE HANDOVER...    console=True
    Prepare And Attach UEs    ue_alias=AT_BASED_UE_1    ue_operator=3    pdu_number=3
    Connect To UE PC And Perform Traffic Via SSH    ue_pc_ip=10.42.22.85    ue_serial=f3b53d67    port=2137    ip_addr=10.42.197.170

    ${full_pcap_path}=    Stop Tcpdump And Download Pcap    tcpdump_filename=TC13_attach_traffic.pcap
    Log    Full pcap path: ${full_pcap_path}    console=True
    Get Pcap Output    pcap_file=${full_pcap_path}    tshark_filter=ngap
    Check Nft Ruleset
    Run Keyword And Ignore Error    Power Off UE    port=3
    Run Keyword And Ignore Error    Power Off UE    port=5

    [Teardown]    Run Keywords    Set ActDynamicFirewall Feature Status    status=false
    ...           AND             Set IPv4 Address For XN U-plane          ${xnu_ipv4}
    ...           AND             Delete All NRADJGNB Objects

5GC001049-B14_NG_based_Handover_UPlane
    Set ActDynamicFirewall Feature Status
    ${new_ipv4_address}=    Get New IPv4 Address    ${xnu_ipv4}
    Set IPv4 Address For XN U-plane                 ${new_ipv4_address}
    Start Tcpdump
    Run Keyword And Ignore Error    Power Off UE    port=3
    Run Keyword And Ignore Error    Power Off UE    port=5

    Log    FIRST UE HANDOVER...    console=True
    Prepare And Attach UEs    ue_alias=AT_BASED_UE_2    ue_operator=5    pdu_number=5
    Connect To UE PC And Perform Traffic Via SSH    ue_pc_ip=10.42.22.85    ue_serial=129539da    port=2138    ip_addr=10.42.197.170

    Log    SECOND UE HANDOVER...    console=True
    Prepare And Attach UEs    ue_alias=AT_BASED_UE_1    ue_operator=3    pdu_number=3
    Connect To UE PC And Perform Traffic Via SSH    ue_pc_ip=10.42.22.85    ue_serial=f3b53d67    port=2137    ip_addr=10.42.197.170

    ${full_pcap_path}=    Stop Tcpdump And Download Pcap    tcpdump_filename=TC13_attach_traffic.pcap
    Log    Full pcap path: ${full_pcap_path}    console=True
    Get Pcap Output    pcap_file=${full_pcap_path}    tshark_filter=ngap
    Check Nft Ruleset
    Run Keyword And Ignore Error    Power Off UE    port=3
    Run Keyword And Ignore Error    Power Off UE    port=5
    [Teardown]    Run Keywords    Set ActDynamicFirewall Feature Status    status=false
    ...           AND             Set IPv4 Address For XN U-plane          ${xnu_ipv4}
    ...           AND             Delete All NRADJGNB Objects

5GC001049-B15_XN_based_Handover_UPlane
    Set ActDynamicFirewall Feature Status
    ${new_ipv4_address}=    Get New IPv4 Address    ${xnu_ipv4}
    Set IPv4 Address For XN U-plane                 ${new_ipv4_address}
    Start Tcpdump
    Run Keyword And Ignore Error    Power Off UE    port=3
    Run Keyword And Ignore Error    Power Off UE    port=5

    Log    FIRST UE HANDOVER...    console=True
    Prepare And Attach UEs    ue_alias=AT_BASED_UE_2    ue_operator=5    pdu_number=5
    Connect To UE PC And Perform Traffic Via SSH    ue_pc_ip=10.42.22.85    ue_serial=129539da    port=2138    ip_addr=10.42.197.170

    Log    SECOND UE HANDOVER...    console=True
    Prepare And Attach UEs    ue_alias=AT_BASED_UE_1    ue_operator=3    pdu_number=3
    Connect To UE PC And Perform Traffic Via SSH    ue_pc_ip=10.42.22.85    ue_serial=f3b53d67    port=2137    ip_addr=10.42.197.170

    ${full_pcap_path}=    Stop Tcpdump And Download Pcap    tcpdump_filename=TC13_attach_traffic.pcap
    Log    Full pcap path: ${full_pcap_path}    console=True
    Get Pcap Output    pcap_file=${full_pcap_path}    tshark_filter=ngap

    Check Nft Ruleset
    Run Keyword And Ignore Error    Power Off UE    port=3
    Run Keyword And Ignore Error    Power Off UE    port=5
    [Teardown]    Run Keywords    Set ActDynamicFirewall Feature Status    status=false
    ...           AND             Set IPv4 Address For XN U-plane          ${xnu_ipv4}
    ...           AND             Delete All NRADJGNB Objects

5GC001049-B16_X2_Addition_Modification_access_on_SgNB_UPlane
    Set ActDynamicFirewall Feature Status
    ${new_ipv4_address}=    Get New IPv4 Address    ${xnu_ipv4}
    Set IPv4 Address For XN U-plane                 ${new_ipv4_address}
    Start Tcpdump
    Run Keyword And Ignore Error    Power Off UE    port=3
    Run Keyword And Ignore Error    Power Off UE    port=5

    Log    FIRST UE HANDOVER...    console=True
    Prepare And Attach UEs    ue_alias=AT_BASED_UE_2    ue_operator=5    pdu_number=5
    Prepare And Attach UEs    ue_alias=AT_BASED_UE_1    ue_operator=3    pdu_number=3
    Connect To UE PC And Perform Traffic Via SSH    ue_pc_ip=10.42.22.85    ue_serial=f3b53d67    port=2137    ip_addr=10.42.197.170

    ${full_pcap_path}=    Stop Tcpdump And Download Pcap    tcpdump_filename=TC13_attach_traffic.pcap
    Log    Full pcap path: ${full_pcap_path}    console=True
    Get Pcap Output    pcap_file=${full_pcap_path}    tshark_filter=ngap

    Check Nft Ruleset
    Run Keyword And Ignore Error    Power Off UE    port=3
    Run Keyword And Ignore Error    Power Off UE    port=5
    [Teardown]    Run Keywords    Set ActDynamicFirewall Feature Status    status=false
    ...           AND             Set IPv4 Address For XN U-plane          ${xnu_ipv4}
    ...           AND             Delete All NRADJGNB Objects

5GC001049-B17_Robustness_Frequent_addition_removal_of_firewall_rules
    Set ActDynamicFirewall Feature Status
    ${robustness_ips}=    func.Get Robustness Addresses
    FOR    ${index}    IN RANGE    100
        Log    Iteration ${index} of robustness test start!    console=True
        Perform Robustness Test    locXnCTnl1v4=${robustness_ips}[0]    locNgCTnl1v6=${robustness_ips}[1]
        ...                        remXnCTnl1v4=${robustness_ips}[2]    remNgCTnl1v6=${robustness_ips}[3]
        Log    Iteration ${index} of robustness test done!    console=True
    END
    Verify Robustness Test

    [Teardown]    Run Keywords    Set ActDynamicFirewall Feature Status    status=false
    ...           AND             Delete All NRADJGNB Objects

Robustness_Frequent_addition_removal_of_firewall_rules_ASOF
    Wait Until Keyword Succeeds               20 min  60sec    Wait until BTS reach Configured or OnAir state
    Set actDynamicFirewall Feature Status     status=true
    FOR    ${index}    IN RANGE    100
        Sleep    2s
        Log    Iteration ${index} of robustness test start!    console=True
        Perform Robustness Test    locXnCTnl1v4=${xnc_ipv4_1}    locNgCTnl1v6=${ngc_ipv6_1}
        ...                        remXnCTnl1v4=${xnc_ipv4_2}    remNgCTnl1v6=${ngc_ipv6_2}
        Log    Iteration ${index} of robustness test done!    console=True
        Sleep    2s
    END
    Verify Robustness Test
    [Teardown]    Set ActDynamicFirewall Feature Status    status=false

Dynamic_Firewall_Basic_TC
    Log    Step 1: Turn on Dynamic Firewall    console=true
    Set actDynamicFirewall Feature Status     status=true
    Log    Step 2: Gather addresses that should be filtered by firewall    console=true
    ${NGC_list}=    Check current parameter value
    ...             dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/SERVEDAMF-1
    ...             param_name=amfIPAddress
    ${XNC_list}=    Check current parameter value
    ...             dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/XNLINK-1
    ...             param_name=cPlaneIpAddr
    ${X2C_list}=    Check current parameter value
    ...             dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRX2LINK_TRUST-259
    ...             param_name=ipV4Addr
    ${NGC_addr}=    Get From List    ${NGC_list}    ${0}
    ${XNC_addr}=    Get From List    ${XNC_list}    ${0}
    ${X2C_addr}=    Get From List    ${X2C_list}    ${0}
    Log    Step 3: Check if firewall contains necessary filters    console=true
    Wait Until Keyword Succeeds    5min    10s    Check if firewall filters are correct
    ...                                           ${NGC_addr}    ${XNC_addr}    ${X2C_addr}
    Log    Step 4: Perform site reset    console=true
    Reset Site And Reconnect
    Wait until BTS reach Configured or OnAir state
    Log    Step 5: Check if firewall contains necessary filters    console=true
    Wait Until Keyword Succeeds    5min    10s    Check if firewall filters are correct
    ...                                           ${NGC_addr}    ${XNC_addr}    ${X2C_addr}
    [Teardown]    Set actDynamicFirewall Feature Status     status=false

Dynamic_Firewall_Advance_TC
    Log    Step 1: Turn on Dynamic Firewall    console=true
    Set actDynamicFirewall Feature Status     status=true
    Log    Step 2: Gather NGC ip address that should be filtered by firewall    console=true
    ${NGC_list}=    Check current parameter value
    ...             dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/SERVEDAMF-1
    ...             param_name=amfIPAddress
    ${NGC_addr}=    Get From List    ${NGC_list}    ${0}
    Log    Step 3: Make sure that NGC address is present in firewall rules    console=true
    Wait Until Keyword Succeeds    5min    10s    Check if firewall filters contain NGC address    ${NGC_addr}
    Log    Step 4: Change NGC address to some dummy ip    console=true
    Change Parameter On BTS    dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/SERVEDAMF-1
    ...                        param_name=amfIPAddress
    ...                        param_value=${dummy_ip}
    Log    Step 5: Make sure that dummy NGC address is present in firewall rules    console=true
    Wait Until Keyword Succeeds    5min    10s    Check if firewall filters contain NGC address    ${dummy_ip}
    Log    Step 6: Restore correct NGC address and check if firewall filters were updated    console=true
    Change Parameter On BTS    dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/SERVEDAMF-1
    ...                        param_name=amfIPAddress
    ...                        param_value=${NGC_addr}
    Wait Until Keyword Succeeds    5min    10s    Check if firewall filters contain NGC address    ${NGC_addr}
    [Teardown]    Run Keywords    Change Parameter On BTS    dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/SERVEDAMF-1
    ...                           param_name=amfIPAddress    param_value=${NGC_addr}
    ...    AND                    Set actDynamicFirewall Feature Status     status=false
