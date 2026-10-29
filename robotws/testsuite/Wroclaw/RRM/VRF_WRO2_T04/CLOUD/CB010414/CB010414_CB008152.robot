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
${AHFII_CELL}    8
${AEHC_CELL_2}    2
${AEHC_CELL_4}    4
${AQQQA_CELL_3}    3

*** Keywords ***
CB010414_CB008152_35MHz_4cc_DL_CA_1F+3T
    Set Default Values On Attenuator for Test 35MHz
    ${attach_pcap}    Attach UE Aic    UE_5    num_of_scells=3
    ...    scells_id=${AEHC_CELL_2},${AEHC_CELL_4},${AQQQA_CELL_3}
    Start DL Traffic For Ue    UE_5    dl_tput=1600Mbits/sec    duration=260s    protocol=udp
    Start UL Traffic For Ue    UE_5    ul_tput=150Mbits/sec    duration=260s    protocol=udp
    Sleep    30
    @{pcaps}    Collect Bip Log Aic    filename=ca_4cc    num_of_sec=3
    ${ca_4cc}    Bip File Selector    ${pcaps}    l2rt

    Trigger Scell Release    30    attenuation=127dB
    Trigger Scell Release    40    attenuation=127dB
    BuiltIn.Sleep    20

    @{pcaps}    Collect Bip Log Aic    filename=no_scells    num_of_sec=3
    ${no_scells}    Bip File Selector    ${pcaps}    l2rt

    Run Keyword And Continue On Failure    Dl Data Scheduled On Pcell And Scells    pcap_file=${ca_4cc}
    ...    scells=${AEHC_CELL_2},${AEHC_CELL_4},${AQQQA_CELL_3}
    ...    pcell_id=${AHFII_CELL}
    Run Keyword And Continue On Failure    Ul Data Is Scheduled On Pcell    pcap_file=${ca_4cc}
    ...    pcell_id=${AHFII_CELL}
    Run Keyword And Continue On Failure    Dl Data Is Not Scheduled On Scells    pcap_file=${no_scells}
    ...    scells=${AEHC_CELL_2},${AEHC_CELL_4},${AQQQA_CELL_3}

    [Teardown]    Run Keywords
    ...    Detach Ue   UE_5    AND
    ...    Set Default Values On Attenuator
