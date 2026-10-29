*** Settings ***
Documentation
...   author: Tomasz Godlewski
...   contact: tomasz.godlewski@nokia.com

Resource   testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC001167/resources/keywords.robot
Resource   testsuite/Wroclaw/RRM/VRF_WRO2_T04/CLOUD/CB010414/resources/keywords_CB010414.robot
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC001167/resources/pcap_verifiers.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/l1l2_verifiers.py    WITH NAME    l1l2_ver
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/cloud/bip_collection.py
Library    testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.cloud.tcpdump_aic.tcpdump_f1_aic
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CLOUD/CB010414/resources/pcap_verifiers_5934.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/cloud/counters_aic.py
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CLOUD/CB006449/resources/keywords_6449.robot
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T04/CLOUD/CB006449/resources/keywords_6449.py
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/cloud/aic_ue.robot
Library    ute_ue

*** Variables ***
${AHFII_CELL_21}    21
${AQQQA_CELL_30}    30
${AEHC_CELL_40}    40
${AEHC_CELL_41}    41

*** Keywords ***
TC03_AA_B3_AB_B2 Successful_intra_band_FR1_TDD_TDD_UL_CA_configuration_via_blind_SCell_addition_with_A2_MR_based_SCell_release_with_delta_A2
    Set Default Values On Attenuator for Test 35MHz
    counters.Wait For Pm Counters Interval    offset=30
    ${attach_pcap}    Attach UE Aic    UE_5    num_of_scells=2
    ...    scells_id=${AEHC_CELL_40},${AHFII_CELL_21}
    Ul Scell Configured    ${attach_pcap}    scell_id=1

    Start DL Traffic For Ue    UE_5    dl_tput=1400Mbits/sec    duration=120s    protocol=udp
    Start UL Traffic For Ue    UE_5    ul_tput=85Mbits/sec    duration=120s    protocol=udp

    BuiltIn.Sleep    10
    @{pcaps}    Collect Bip Log Aic    filename=ca_3cc    num_of_sec=3
    ${l1l2_3cc}    Bip File Selector    ${pcaps}    l2rt

    Verify DL Tput For Ue    UE_5
    Verify UL Tput For Ue    UE_5

    Run Keyword And Continue On Failure    Dl Data Scheduled On Pcell And Scells      ${l1l2_3cc}
    ...    scells=${AEHC_CELL_40},${AHFII_CELL_21}    pcell_id=${AEHC_CELL_41}
    Run Keyword And Continue On Failure    Ul Data Scheduled On Pcell And Scells      ${l1l2_3cc}
    ...    scells=${AEHC_CELL_40}    pcell_id=${AEHC_CELL_41}
    Detach Ue   UE_5
    Verify 6449 counters

    Set Att For Cell With Id    ${AEHC_CELL_41}    attenuation=45dB
    Change Scell Addition Method For Nrrels    cell_id=${AEHC_CELL_41}
    ...    nrrels=${AEHC_CELL_40},${AHFII_CELL_21},${AQQQA_CELL_30}    scell_add_method=covBasedA1
    ${attach_pcap}    Attach UE Aic    UE_5    num_of_scells=0

    Start F1c And Ngc Tcpdump    filename=scell_add_a1.pcap
    Show Text on Console    Triggering scells addition  colour=${GREEN}  show_timestamp=no
    Trigger Scell Addition Based On A1    cell_id=${AEHC_CELL_41}    attenuation=20dB
    Check Cell And Signal Strength For Ue    UE_5
    ${scell_add_a1}=    Stop F1c And Ngc Tcpdump

    Start F1c And Ngc Tcpdump    filename=scell_release.pcap
    Show Text on Console    Triggering scell ${AEHC_CELL_40} release  colour=${GREEN}  show_timestamp=no
    Trigger Scell Release    ${AEHC_CELL_40}    attenuation=55dB
    Check Cell And Signal Strength For Ue    UE_5
    ${scell_rel}=    Stop F1c And Ngc Tcpdump
    Detach Ue   UE_5
    counters.Wait For Pm Counters Interval    offset=120
    Run Keyword And Continue On Failure
    ...    Vcu Counter Incremented Successfully For Cell    M55118C11095    cell_id=${AEHC_CELL_41}
    Run Keyword And Continue On Failure
    ...    Vcu Counter Incremented Successfully For Cell    M55118C11096    cell_id=${AEHC_CELL_41}
    Scells Added    ${scell_add_a1}    num_of_scells=2
    ...    scells_id=${AEHC_CELL_40},${AHFII_CELL_21}
    Ul Scell Configured    ${scell_add_a1}    scell_id=1
    Scell Released    ${scell_rel}    2
    [Teardown]    Run Keywords
    ...    Detach Ue   UE_5    AND
    ...    Change Scell Addition Method For Nrrels    cell_id=41    nrrels=21,30,40    scell_add_method=blind


TC09_CA_IWK7_IWK_8_event_A1_A4_&_bufferBased_CB008311_NR_FR1_SCell_addition_for_SA
    Set Default Values On Attenuator for Test 35MHz
    Set Att For Cell With Id    ${AEHC_CELL_41}    attenuation=45dB
    Change Scell Addition Method For Nrrels    cell_id=${AEHC_CELL_41}
    ...    nrrels=${AEHC_CELL_40},${AHFII_CELL_21},${AQQQA_CELL_30}    scell_add_method=covBasedA1
    Activate Buffer Based Scell Addition

    ${attach_pcap_a1}    Attach UE Aic    UE_5    num_of_scells=0    alias=UE_1_a1
    Start F1c And Ngc Tcpdump    filename=scell_add_a1.pcap
    BuiltIn.Sleep    10
    Show Text on Console    Triggering scells addition  colour=${GREEN}  show_timestamp=no
    Trigger Scell Addition Based On A1    cell_id=${AEHC_CELL_41}    attenuation=15dB
    Start DL Traffic For Ue    UE_5    dl_tput=1400Mbits/sec    duration=60s    protocol=udp
    Start UL Traffic For Ue    UE_5    ul_tput=85Mbits/sec    duration=60s    protocol=udp
    Check Cell And Signal Strength For Ue    UE_5
    ${scell_add_a1}=    Stop F1c And Ngc Tcpdump
    @{pcaps}    Collect Bip Log Aic    filename=ca_3cc    num_of_sec=3
    ${l1l2_3cc}    Bip File Selector    ${pcaps}    l2rt

    Scells Added    ${scell_add_a1}    num_of_scells=2
    ...    scells_id=${AEHC_CELL_40},${AHFII_CELL_21}
    Ul Scell Configured    ${scell_add_a1}    scell_id=1
    Verify DL Tput For Ue    UE_5
    Verify UL Tput For Ue    UE_5
    Run Keyword And Continue On Failure    Assert Buffer Monitoring Was Activated    ${scell_add_a1}
    Run Keyword And Continue On Failure    Assert Buffer Criterion Was Activated    ${scell_add_a1}

    Run Keyword And Continue On Failure    Dl Data Scheduled On Pcell And Scells      ${l1l2_3cc}
    ...    scells=${AEHC_CELL_40},${AHFII_CELL_21}    pcell_id=${AEHC_CELL_41}
    Run Keyword And Continue On Failure    Ul Data Scheduled On Pcell And Scells      ${l1l2_3cc}
    ...    scells=${AEHC_CELL_40}    pcell_id=${AEHC_CELL_41}

    Detach Ue   UE_5

    Change Scell Addition Method For Nrrels    cell_id=${AEHC_CELL_41}
    ...    nrrels=${AEHC_CELL_40},${AHFII_CELL_21},${AQQQA_CELL_30}    scell_add_method=covBasedA4

    counters.Wait For Pm Counters Interval    offset=30
    ${attach_pcap_a4}    Attach UE Aic    UE_5    num_of_scells=0    alias=UE_1_a4
    Start F1c And Ngc Tcpdump    filename=scell_add_a4.pcap
    Start DL Traffic For Ue    UE_5    dl_tput=1400Mbits/sec    duration=120s    protocol=udp
    Start UL Traffic For Ue    UE_5    ul_tput=85Mbits/sec    duration=120s    protocol=udp
    Check Cell And Signal Strength For Ue    UE_5
    @{pcaps}    Collect Bip Log Aic    filename=ca_3cc    num_of_sec=3
    ${l1l2_3cc}    Bip File Selector    ${pcaps}    l2rt
    BuiltIn.Sleep    20
    ${scell_add_a4}=    Stop F1c And Ngc Tcpdump

    Scells Added    ${scell_add_a4}    num_of_scells=2
    ...    scells_id=${AEHC_CELL_40},${AHFII_CELL_21}
    Ul Scell Configured    ${scell_add_a4}    scell_id=1
    Verify DL Tput For Ue    UE_5
    Verify UL Tput For Ue    UE_5
    Detach Ue   UE_5
    Verify 6449 counters
    Run Keyword And Continue On Failure    Assert Buffer Monitoring Was Activated    ${attach_pcap_a4}
    Run Keyword And Continue On Failure    Assert Buffer Criterion Was Activated    ${scell_add_a4}

    Run Keyword And Continue On Failure    Dl Data Scheduled On Pcell And Scells      ${l1l2_3cc}
    ...    scells=${AEHC_CELL_40},${AHFII_CELL_21}    pcell_id=${AEHC_CELL_41}
    Run Keyword And Continue On Failure    Ul Data Scheduled On Pcell And Scells      ${l1l2_3cc}
    ...    scells=${AEHC_CELL_40}    pcell_id=${AEHC_CELL_41}

    [Teardown]    Run Keywords
    ...    Detach Ue   UE_5    AND
    ...    Change Scell Addition Method For Nrrels    cell_id=41    nrrels=21,30,40    scell_add_method=blind    AND
    ...    Disable Buffer Based Scell Addition
