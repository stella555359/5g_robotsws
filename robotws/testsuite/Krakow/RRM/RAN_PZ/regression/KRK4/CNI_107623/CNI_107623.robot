*** Settings ***
Documentation
...   Adapted tests for CNI107623 (testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007306_OTA/CB007306_OTA.robot)
...   author/adapter: damian.silkowski@nokia.com
...   maintainer: bartlomiej.kolacz@nokia.com

Force Tags      CRT_TRUNK    PY39

Resource        resources/resource_CNI_107623.robot

Suite Setup       Run Keywords
...               upload_custom_swconfig  path=${CURDIR}/resources/swconfig.txt  AND
...               Common Suite Setup With Commissioning  AND
...               gnb_cells.wait_for_all_cells_to_be_onair  cell_type=lte  timeout=${600}  AND
...               set_attenuation  attenuation_values=${attenuation_values}
Suite Teardown    Common Suite Teardown

*** Variables ***
@{attenuation_values}=  ${0}  ${0}  ${0}  ${0}  ${0}  ${0}  ${0}  ${0}
...    ${110}  ${110}  ${110}  ${110}  ${110}  ${110}  ${110}  ${110}
${REMOTE_PCAP_PATH}         /tmp/tmp.pcap
${filter_cni}               x2ap || s1ap


*** Test Cases ***
CNI_107623_004_ENDC_setup_via_LTE4193_and_B1_setup_when_NRrestrictedinEPSasSecondaryRAT_and_UE_in_FR1_FR2_cross_signal_area
    # 0 attenuation
    # telnet 10.255.40.187 50000
    # command: ATT 1 0, 2 0, 3 0, 4 0, 5 0, 6 0, 7 0, 8 0, 9 110, 10 110, 11 110, 12 110, 13 110, 14 110, 15 110, 16 110
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report
    attenuator.init_attenuator
    attenuator.set_ports_state    ports_to_change=[1, 2, 3, 4, 5, 6, 7, 8]    state=on
    attenuator.set_ports_state    ports_to_change=[9, 10, 11, 12, 13, 14, 15, 16]    state=off
    ${tcpdump_CNI}    set variable    tcpdump_CNI_107623
    wireshark.Start wireshark capture from gNB or Enb    if_gnb=${True}    filename=${tcpdump_CNI}    alias=gnb
    resource_CNI_107623.require_ue
    resource_CNI_107623.attach_ue
    resource_CNI_107623.log_info_ue
    sleep    10
    wireshark.Stop wireshark capture from gNB or Enb    if_gnb=${True}    filename=${tcpdump_CNI}    alias=gnb
    resource_CNI_107623.detach_ue
    wireshark.Convert pcap to text    pacp_filename=${tcpdump_CNI}.pcap    txt_filename=${tcpdump_CNI}.txt    filter=${filter_cni}
    wireshark.Check Wireshark Log for CNI_107623    txt_filename=${tcpdump_CNI}.txt    case_type=b1_fr2
    wireshark.Check wireshark log Parameter    sgnb_chg_ho_message=${nrRestrictionInEPS}    txt_filename=${tcpdump_CNI}.txt
    wireshark.Check wireshark log Parameter    sgnb_chg_ho_message=${attached_pci_4}    txt_filename=${tcpdump_CNI}.txt
    ${tcpdump_CNI_HO_OK}    set variable    tcpdump_CNI_107623_HO_OK
    log to console    HO FR1->FR2 (OK scenario)
    wireshark.Start wireshark capture from gNB or Enb    if_gnb=${True}    filename=${tcpdump_CNI_HO_OK}    alias=gnb
    resource_CNI_107623.attach_ue
    #HO FR1->FR2
    attenuator.set_ports_state    ports_to_change=[1, 2]    state=value    value=50
    resource_CNI_107623.log_info_ue
    sleep    10
    wireshark.Stop wireshark capture from gNB or Enb    if_gnb=${True}    filename=${tcpdump_CNI_HO_OK}    alias=gnb
    resource_CNI_107623.detach_ue
    wireshark.Convert pcap to text    pacp_filename=${tcpdump_CNI_HO_OK}.pcap    txt_filename=${tcpdump_CNI_HO_OK}.txt    filter=${filter_cni}
    wireshark.Check wireshark log Parameter    sgnb_chg_ho_message=${HO_attached_pci_70}    txt_filename=${tcpdump_CNI_HO_OK}.txt
    wireshark.Check Wireshark Message Flow From Txt File    message_dict=${inter_freq_intra_gnb_message_flow}
    ...    txt_file_path=${OUTPUT_DIR}/${tcpdump_CNI_HO_OK}.txt
    # negative scenario
    # restore 0 attenuation
    attenuator.set_ports_state    ports_to_change=[1, 2]    state=on
    resource_CNI_107623.modify_parameter    dist_name=MRBTS-{}/LNBTS-{}
    ...                                     parameter=nrRestrictionOverride
    ...                                     value=FR2
    ${tcpdump_CNI_HO_NOK}    set variable    tcpdump_CNI_107623_HO_NOK
    log to console    HO FR2->FR1 (NOK scenario - no HO sould happened)
    wireshark.Start wireshark capture from gNB or Enb    if_gnb=${True}    filename=${tcpdump_CNI_HO_NOK}    alias=gnb
    resource_CNI_107623.attach_ue
    attenuator.set_ports_state    ports_to_change=[1, 2]    state=value    value=50
    resource_CNI_107623.log_info_ue
    sleep    10
    wireshark.Stop wireshark capture from gNB or Enb    if_gnb=${True}    filename=${tcpdump_CNI_HO_NOK}    alias=gnb
    resource_CNI_107623.detach_ue
    wireshark.Convert pcap to text    pacp_filename=${tcpdump_CNI_HO_NOK}.pcap    txt_filename=${tcpdump_CNI_HO_NOK}.txt    filter=${filter_cni}
    wireshark.Check wireshark log Parameter HO NOK    sgnb_chg_ho_message=${attached_pci_4}    txt_filename=${tcpdump_CNI_HO_NOK}.txt
    wireshark.Check wireshark log Parameter    sgnb_chg_ho_message=${HO_NOT_attached_pci_70}    txt_filename=${tcpdump_CNI_HO_NOK}.txt
    [Teardown]    resource_CNI_107623.modify_parameter    dist_name=MRBTS-{}/LNBTS-{}
    ...                                                   parameter=nrRestrictionOverride
    ...                                                   value=FR1 and FR2
