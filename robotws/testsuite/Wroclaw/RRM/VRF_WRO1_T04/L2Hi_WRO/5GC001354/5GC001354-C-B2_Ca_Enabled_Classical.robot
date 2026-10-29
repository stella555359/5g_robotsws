*** Settings ***
Resource    CB001354_keywords.robot

Documentation
...    author: Pawel Konieczny
...    maintainer: Michal Brychcy (michal.brychcy@nokia.com)
...    release: 23R1

*** Variables ***
${TRAFFIC_DURATION_SEC}=   60s

*** Keywords ***
5GC001354-C-B2_Nsa_Non_Gbr_Drb_Retransmission_Of_Pdcp_Pdus_Due_To_Rlo_With_Ca_Enabled_Classical
    Attach Ue With Sgnb
    Start 700Mbps Dl Data Traffic With Tcp
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Bearer Stats On Scell 8 And 9
    Verify Traffic Throughput on Scells
    Triggering Attenuation On Scell 8 And 9 For Treshold Counters
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Bearer Stats
    Detach Ue    ue_id=11
    Wait For Next Full Pm Interval
    Verify If 1354-C Threshld 1 Qos Grp 6 X2 Pm Counters Were Incremented
    Verify If 1354-C Threshld 2 Qos Grp 6 X2 Pm Counters Were Incremented
    Verify If 1354-C Treshold 1 Transmission Delay Bin Pm Counters Were Incremented
    Verify If 1354-C Treshold 2 Transmission Delay Bin Pm Counters Were Incremented
    Verify That Due To High Attenuation Some Dl Pdcp Pdus Exceeded Max Delay Allowed For Retransmissioncn Qos Group 06

Start 700Mbps Dl Data Traffic With Tcp
    Execute Egate Command    cmd=debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=11 id=2 dir=dl mbps=175 trf_id=1
    Execute Egate Command    cmd=trf_data_start ue=11 id=2 dir=dl mbps=175 trf_id=2
    Execute Egate Command    cmd=trf_data_start ue=11 id=2 dir=dl mbps=175 trf_id=3
    Execute Egate Command    cmd=trf_data_start ue=11 id=2 dir=dl mbps=175 trf_id=4

Triggering Attenuation On Scell 8 And 9 For Treshold Counters
    Execute Egate Command    cmd=bler_testmode_nr profile_id=1 num_harq_nack=7
    Execute Egate Command    cmd=bler_testmode_nr profile_id=2 dl_bler=2,3,4,5,6,7,8,9
    Execute Egate Command    cmd=ue_testmode_set_nr id=11 testmode=bler action=activate profile_id=1 scell=8
    Execute Egate Command    cmd=ue_testmode_set_nr id=11 testmode=bler action=activate profile_id=2 scell=8
    Execute Egate Command    cmd=ue_testmode_set_nr id=11 testmode=bler action=activate profile_id=1 scell=9
    Execute Egate Command    cmd=ue_testmode_set_nr id=11 testmode=bler action=activate profile_id=2 scell=9

Display Bearer Stats On Scell 8 And 9
    Execute Egate Command And Wait For Data   cmd=ue_stats_nr id=11 type=pdsch scell=8,9
    Execute Egate Command And Wait For Data   cmd=bearer_stats ue=11 id=2 dir=dl

Verify Traffic Throughput on Scells
    Expected Throughput For Ue Should Be Reached    ue_id=11    throughput=340    scells=9    margin=20
    ...    direction=dl    selection_type=average    layer=physical
