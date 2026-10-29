*** Settings ***
Documentation
...   author: Tomasz Godlewski
...   contact: tomasz.godlewski@nokia.com

Resource   ./resources/keywords.robot
Library    ./resources/keywords_1167.py    WITH NAME   python_1167
Library    ./resources/pcap_verifiers.py
Library    ./resources/bufferbased.py
Library    testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.gnb_mirroring.L1L2     WITH NAME    L1L2

*** Keywords ***
5GC001167_I_001_3CC_FDD-FDD_Inter_band_CA_NR_DL_peak_UDP_throughput_band_combination_1
    Set Preferred Cell     ${PCELL_106}
    Set Initial Attenuation For Test
    Attach UE To Pcell And Scell    ${CA_UE}    num_of_scells=2
    Start DL Traffic For Ue    ${CA_UE}    1000Mbits/sec    duration=120s    protocol=udp
    L1L2.Start GnbMirroring    capturing_time_seconds=2    new_l1l2=${TRUE}
    BuiltIn.Sleep    2    Log Collecting
    ${l1l2}=    L1L2.stop_gnbmirroring_and_download_logs
    Verify DL Tput For Ue
    [Teardown]    Detach Ue    ${CA_UE}

5GC001167_I_020_FDD-FDD_inter_band_CA_bufferAndRLQualityBased_Scell_Activation_combination1_(3CC)
    Set Preferred Cell     ${PCELL_106}
    Set Initial Attenuation For Test
    Activate Buffer Based Configuration    bufferAndRLQualityBased

    Attach UE To Pcell And Scell    ${CA_UE}    num_of_scells=2

    Start DL Traffic For Ue    ${CA_UE}    1000Mbits/sec    duration=60s
    L1L2.Start GnbMirroring    capturing_time_seconds=2    filename=all_scells_L1L2.pcap
    BuiltIn.Sleep    2
    ${l1l2_all}=    L1L2.stop_gnbmirroring_and_download_logs

    Verify DL Tput For Ue    ${CA_UE}

    Set Attenuation For Cell With Id    ${SCELL_101}    90db
    Start DL Traffic For Ue    ${CA_UE}    630Mbits/sec    duration=60s
    BuiltIn.Sleep    10
    L1L2.Start GnbMirroring    capturing_time_seconds=2    filename=one_scell_L1L2.pcap
    BuiltIn.Sleep    2
    ${l1l2_single}=    L1L2.stop_gnbmirroring_and_download_logs
    Verify DL Tput For Ue    ${CA_UE}

    Run Keyword And Continue On Failure    DL Data Scheduled On Pcell And Scells    ${l1l2_all}    scells=${SCELL_100},${SCELL_101}
    ...    pcell_id=${PCELL_106}
    Run Keyword And Continue On Failure    DL Data Is Scheduled On Pcell    ${l1l2_single}     pcell_id=${PCELL_106}
    Run Keyword And Continue On Failure    DL Data Is Scheduled On Exact Number Of Scells    ${l1l2_single}    num_of_scells=1
    ...    possible_scells=100,101
    Run Keyword And Continue On Failure    DL Data Is Not Scheduled On Scells    ${l1l2_single}    scells=${SCELL_101}

    [Teardown]    Run Keywords
    ...    Deactivate Buffer Based Configuration    bufferAndRLQualityBased    AND
    ...    Detach Ue    ${CA_UE}
