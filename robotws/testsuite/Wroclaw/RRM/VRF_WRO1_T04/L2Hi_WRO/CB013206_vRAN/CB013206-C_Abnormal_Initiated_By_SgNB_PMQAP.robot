*** Settings ***
Resource    keywords_CB013206_AiC.robot
Library     ta5g_tshark

Documentation
...    author: Lukasz Filipek
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    release: 25R2

*** Variables ***
${TRAFFIC_DURATION_SEC}=   10s

*** Keywords ***
CB013206-C_Abnorm_Sgnb_Insession_Release_Pmqap_Cloud
    Attach Ue To Enb    ue_id=11
    Execute Egate Command    cmd=ue_dc_enb_start ue=11 target_gnb=2 target_cells=1 bearer=2 type=split_scg
    Start Dl And Ul Data Traffic
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Bearer Stats
    Perform Abnormal Releases Initiated By Sgnb
    Check Pm Counters For Abnormal Releases Initiated By Sgnb

Start Dl And Ul Data Traffic
    ta5g_throughput.Start Data Traffic  ues=11    bearer_id=2    direction=dl    throughput=90mbps
    ta5g_throughput.Start Data Traffic  ues=11    bearer_id=2    direction=ul    throughput=90mbps

Display Bearer Stats
    Execute Egate Command And Wait For Data    cmd=bearer_stats ue=11 id=2

Check Pm Counters For Abnormal Releases Initiated By Sgnb
    Wait For Next PM counters Interval
    Verify CU Counter Value Is Exact As Given Value
    ...    value=1    local_moid=MRBTS-1/NRBTS-1/NRCELL-1/MCC-311/MNC-489/ECI-19088897/MCC-311/MNC-489
    ...    counter_id=${COUNTER_ID_NX2CC_RAB_REL_ABNOR_SGNB_NRREL}
    Verify CU Counter Value Is Exact As Given Value
    ...    value=1    local_moid=MRBTS-1/NRBTS-1/NRCELL-1
    ...    counter_id=${COUNTER_ID_NX2CC_RAB_REL_ABNRM_SGNB_INSES}
    Verify CU Counter Value Is Exact As Given Value
    ...    value=1    local_moid=MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-1
    ...    counter_id=${COUNTER_ID_RAB_REL_ABNRM_SGNB_INSES_PMQAP}
