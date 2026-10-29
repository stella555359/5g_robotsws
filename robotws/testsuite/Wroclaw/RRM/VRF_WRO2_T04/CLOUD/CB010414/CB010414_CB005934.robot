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
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/cloud/aic_ue.robot
Library    ute_ue

*** Variables ***
${AHFII_CELL_1}    20
${AHFII_CELL_2}    21
${AHFII_CELL_3}    22
${AHLOB_CELL_1}    10
${AHLOB_CELL_2}    11

${PCELL_ID_1}    ${AHFII_CELL_1}

*** Keywords ***
CB010414_CB005934_SCell_swap_4FDD_limit_on_SCell_swap_targets+VONR
    Set Default Values On Attenuator
    counters.Wait For Pm Counters Interval    offset=10
    Show Text on Console    Attaching UE_5 to CELL 20    colour=${GREEN}  show_timestamp=no
    ${attach_pcap}    Attach UE Aic    UE_5    num_of_scells=3    vonr=${FALSE}
    ...    scells_id=${AHLOB_CELL_1},${AHLOB_CELL_2},${AHFII_CELL_3}
    Start DL Traffic For Ue    UE_5    dl_tput=315Mbits/sec    duration=100s    protocol=udp    dt=first

    @{pcaps}    Collect Bip Log Aic    filename=ca_4cc
    ${ca_4cc}    Bip File Selector    ${pcaps}    l2rt

    Start F1c And Ngc Tcpdump    filename=a6_first.pcap
    Show Text on Console    Perfmorming scell swap from ${AHFII_CELL_3} to ${AHFII_CELL_2}  colour=${GREEN}  show_timestamp=no
    Perform Scell Swap    src_cell_id=${AHFII_CELL_3}    dst_cell_id=${AHFII_CELL_2}    att_value=20dB
    ${a6_first}=    Stop F1c And Ngc Tcpdump
    Show Text on Console    Perfmorming scell swap from ${AHFII_CELL_2} to ${AHFII_CELL_3}  colour=${GREEN}  show_timestamp=no
    Start F1c And Ngc Tcpdump    filename=a6_second.pcap
    Perform Scell Swap    src_cell_id=${AHFII_CELL_2}    dst_cell_id=${AHFII_CELL_3}    att_value=20dB
    ${a6_second}=    Stop F1c And Ngc Tcpdump

    Scell Swap Performed    ${a6_first}    scell_added_id=21    scell_added_index=4    scell_released_index=3
    Show Text on Console    First scell swap ok  colour=${GREEN}  show_timestamp=no
    Scell Swap Performed    ${a6_second}    scell_added_id=22    scell_added_index=3    scell_released_index=4
    Show Text on Console    Second scell swap ok  colour=${GREEN}  show_timestamp=no

    Start DL Traffic For Ue    UE_5    dl_tput=315Mbits/sec    duration=100s    protocol=udp    dt=second
    Start F1c And Ngc Tcpdump    filename=a6_third.pcap
    Show Text on Console    Perfmorming scell swap from ${AHFII_CELL_3} to ${AHFII_CELL_2}  colour=${GREEN}  show_timestamp=no
    Perform Scell Swap    src_cell_id=${AHFII_CELL_3}    dst_cell_id=${AHFII_CELL_2}    att_value=20dB
    ${a6_third}=    Stop F1c And Ngc Tcpdump
    Log To Console    Performing second scell swap..
    Start F1c And Ngc Tcpdump    filename=a6_fourth.pcap
    Perform Scell Swap    src_cell_id=${AHFII_CELL_2}    dst_cell_id=${AHFII_CELL_3}    att_value=20dB
    Show Text on Console    Perfmorming scell swap from ${AHFII_CELL_2} to ${AHFII_CELL_3}  colour=${GREEN}  show_timestamp=no
    ${a6_fourth}=    Stop F1c And Ngc Tcpdump

    Start F1c And Ngc Tcpdump    filename=scell_release.pcap
    Show Text on Console    Triggering scell ${AHLOB_CELL_1} release  colour=${GREEN}  show_timestamp=no
    Trigger Scell Release    ${AHLOB_CELL_1}    attenuation=100dB
    ${scell_rel}=    Stop F1c And Ngc Tcpdump
    Scell Released    ${scell_rel}    1
    Scell Released    ${scell_rel}    2
    @{pcaps}    Collect Bip Log Aic    filename=ca_2cc
    ${ca_2cc}    bip_file_selector    ${pcaps}    l2rt

    Verify DL Tput For Ue    UE_5    dt=first
    counters.Wait For Pm Counters Interval    offset=100
    Run Keyword And Continue On Failure    Vcu Counter Incremented Successfully For Cell    M55138C03001    ${PCELL_ID_1}
    Run Keyword And Continue On Failure    Vcu Counter Incremented Successfully For Cell    M55138C03002    ${PCELL_ID_1}
    Run Keyword And Continue On Failure    Vdu Counter Incremented Successfully For Cell    M55139C03001    ${PCELL_ID_1}
    Run Keyword And Continue On Failure    Vdu Counter Incremented Successfully For Cell    M55139C03002    ${PCELL_ID_1}
    Run Keyword And Continue On Failure    Vcu Counter Incremented Successfully For Cell    M55118C09503    ${PCELL_ID_1}
    Run Keyword And Continue On Failure    Vcu Counter Incremented Successfully For Cell    M55118C09502    ${PCELL_ID_1}

    Run Keyword And Continue On Failure    Vcu Counter Incremented Successfully For Cell    M55118C06502    ${PCELL_ID_1}
    ...    expected_value=2

    Run Keyword And Continue On Failure    Dl Data Scheduled On Pcell And Scells    pcap_file=${ca_4cc}
    ...    scells=${AHLOB_CELL_1},${AHLOB_CELL_2},${AHFII_CELL_3}
    ...    pcell_id=${AHFII_CELL_1}
    Run Keyword And Continue On Failure    Dl Data Scheduled On Pcell And Scells    pcap_file=${ca_2cc}
    ...    scells=${AHFII_CELL_3}
    ...    pcell_id=${AHFII_CELL_1}

    [Teardown]    Run Keywords
    ...    Detach Ue   UE_5    AND
    ...    Set Default Values On Attenuator
