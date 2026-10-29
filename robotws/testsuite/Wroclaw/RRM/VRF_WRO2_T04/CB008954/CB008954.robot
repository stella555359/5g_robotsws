*** Settings ***
Documentation
...   Tests for CB008954 feature - Up to 3 BWP for UE with different bandwidth capabilities

Resource   ../5GC001167/resources/keywords.robot
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB008281/resources/pcap_verifiers_8281.py
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB008954/resources/keywords_cb008954.robot
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC001167/resources/pcap_verifiers.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB008954/resources/keywords_8954.py
Library    testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.gnb_mirroring.L1L2     WITH NAME    L1L2

*** Variables ***
${UE_BWP_LARGE}     UE_1
${UE_BWP_MEDIUM}    UE_4
${UE_BWP_SMALL}     UE_3

@{COUNTERS_8954}    M55139C04001    M55139C04002    M55139C04511    M55139C04512    M55139C04513

*** Keywords ***
CB008954_Multi_Draft_ABE
    Remove Scell Addition Method    ${PCELL_106}    ${SCELL_100},${SCELL_101}
    Set Preferred Cell     102
    Set Initial Attenuation For Test
    counters.Wait For Pm Counters Interval    offset=40
    ${pcap_UE1}    Attach UE To Pcell And Scell    ${UE_BWP_LARGE}    num_of_scells=1    scells_id=106    alias=${UE_BWP_LARGE}
    Start DL Traffic For Ue    ${UE_BWP_LARGE}    100Mbits/sec    duration=300s
    ${pcap_UE4}    Attach UE To Pcell And Scell    ${UE_BWP_MEDIUM}    num_of_scells=1    scells_id=106    alias=${UE_BWP_MEDIUM}
    Start DL Traffic For Ue    ${UE_BWP_MEDIUM}    100Mbits/sec    duration=300s
    ${pcap_UE3}    Attach UE To Pcell And Scell    ${UE_BWP_SMALL}    num_of_scells=1    scells_id=106    alias=${UE_BWP_SMALL}
    Start DL Traffic For Ue    ${UE_BWP_SMALL}    100Mbits/sec    duration=300s
    Tcpdump.Start Tcpdump On Smod    filename=after_attach.pcap
    &{counters_values}=     Get Scell Add Counter Values    ${COUNTERS_8954}
    ${pcap_file}=    Tcpdump.Stop Tcpdump and download logs from SMOD
    Counter Incremented Successfully    M55139C04001    cell_id=102    counter_dict=counters_values    operator===
    ...    value=2
    Counter Incremented Successfully    M55139C04002    cell_id=102    counter_dict=counters_values    operator===
    ...    value=1
    Counter Incremented Successfully    M55139C04511    cell_id=106    counter_dict=counters_values    operator===
    ...    value=1
    Counter Incremented Successfully    M55139C04512    cell_id=106    counter_dict=counters_values    operator===
    ...    value=1
    Counter Incremented Successfully    M55139C04513    cell_id=106    counter_dict=counters_values    operator===
    ...    value=1
    Run Keyword And Continue On Failure    Verify DL Tput For Ue    ${UE_BWP_LARGE}
    Run Keyword And Continue On Failure    Verify DL Tput For Ue    ${UE_BWP_MEDIUM}
    Run Keyword And Continue On Failure    Verify DL Tput For Ue    ${UE_BWP_SMALL}

    Detach Ue    ${UE_BWP_LARGE}
    Detach Ue    ${UE_BWP_MEDIUM}
    Detach Ue    ${UE_BWP_SMALL}

    Set Preferred Cell     ${PCELL_106}
    ${pcap_UE1}    Attach UE To Pcell And Scell    ${UE_BWP_LARGE}    num_of_scells=0    alias=${UE_BWP_LARGE}
    Run Keyword And Continue On Failure    Check BWP   Large    ${pcap_UE1}
    Start DL Traffic For Ue    ${UE_BWP_LARGE}    400Mbits/sec    duration=60s    dt=second
    Start UL Traffic For Ue    ${UE_BWP_LARGE}    200Mbits/sec    duration=60s
    L1L2.Start GnbMirroring    capturing_time_seconds=2    filename=${UE_BWP_LARGE}_L1L2.pcap
    BuiltIn.Sleep    2
    ${l1l2_single}=    L1L2.stop_gnbmirroring_and_download_logs
    Start Voice Call    vc_alias=call1    ue_alias=${UE_BWP_LARGE}    to=0105    duration=20s
    Await Voice Call Finish    vc_alias=call1
    Run Keyword And Continue On Failure    Verify DL Tput For Ue    ${UE_BWP_LARGE}    dt=second
    Run Keyword And Continue On Failure    Verify UL Tput For Ue    ${UE_BWP_LARGE}

    ${pcap_UE4}    Attach UE To Pcell And Scell    ${UE_BWP_MEDIUM}    num_of_scells=0    alias=${UE_BWP_MEDIUM}
    Run Keyword And Continue On Failure    Check BWP   Medium    ${pcap_UE4}
    Start DL Traffic For Ue    ${UE_BWP_MEDIUM}    250Mbits/sec    duration=60s    dt=second
    Start UL Traffic For Ue    ${UE_BWP_MEDIUM}    100Mbits/sec    duration=60s
    L1L2.Start GnbMirroring    capturing_time_seconds=2    filename=${UE_BWP_MEDIUM}_L1L2.pcap
    BuiltIn.Sleep    2
    ${l1l2_single}=    L1L2.stop_gnbmirroring_and_download_logs
    Start Voice Call    vc_alias=call2    ue_alias=${UE_BWP_MEDIUM}    to=0105    duration=20s
    Await Voice Call Finish    vc_alias=call2
    Run Keyword And Continue On Failure    Verify DL Tput For Ue    ${UE_BWP_MEDIUM}    dt=second
    Run Keyword And Continue On Failure    Verify UL Tput For Ue    ${UE_BWP_MEDIUM}

    ${pcap_UE3}    Attach UE To Pcell And Scell    ${UE_BWP_SMALL}    num_of_scells=0    alias=${UE_BWP_SMALL}
    Run Keyword And Continue On Failure    Check BWP   Small    ${pcap_UE3}
    Start DL Traffic For Ue    ${UE_BWP_SMALL}    180Mbits/sec    duration=60s    dt=second
    Start UL Traffic For Ue    ${UE_BWP_SMALL}    80Mbits/sec    duration=60s
    L1L2.Start GnbMirroring    capturing_time_seconds=2    filename=${UE_BWP_SMALL}_L1L2.pcap
    BuiltIn.Sleep    2
    ${l1l2_single}=    L1L2.stop_gnbmirroring_and_download_logs
    Start Voice Call    vc_alias=call3    ue_alias=${UE_BWP_SMALL}    to=0105    duration=20s
    Await Voice Call Finish    vc_alias=call3
    Run Keyword And Continue On Failure    Verify DL Tput For Ue    ${UE_BWP_SMALL}    dt=second
    Run Keyword And Continue On Failure    Verify UL Tput For Ue    ${UE_BWP_SMALL}

    [Teardown]    Run Keywords
    ...    Detach Ue    ${UE_BWP_LARGE}    AND
    ...    Detach Ue    ${UE_BWP_MEDIUM}    AND
    ...    Detach Ue    ${UE_BWP_SMALL}    AND
    ...    Add Scell Addition Method    ${PCELL_106}    ${SCELL_100},${SCELL_101}
