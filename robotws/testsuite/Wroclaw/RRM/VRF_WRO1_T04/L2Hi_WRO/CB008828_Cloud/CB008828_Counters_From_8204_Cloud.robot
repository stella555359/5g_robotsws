*** Settings ***
Documentation
...    author: Michał Brychcy
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    testline: CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC
...    release: 24R3

*** Variables ***
${TRAFFIC_DURATION_SEC}=   60s

*** Keywords ***
CB008828_Counters_From_CB008204_Should_Be_Incremented_Cloud
    Attach Ue With Sgnb
    Start Low Dl And Ul Data Traffic With Udp
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Bearer Stats
    Verify If Specyfic CB008204 Dl Pdcp Sdus Were Transmitted For Nsa Bearer
    Verify If Specyfic CB008204 Pdcp Sdu Pm Counters Are Incremented With Cb008828
    Detach Ue    ue_id=11


Enable 25 Snssai and Slicing
    Perform DU Delta Commissioning    ${CURDIR}/config/enable_8828_vdu.json
    Perform CU Delta Commissioning    ${CURDIR}/config/enable_8828_vcu.json

Start Low Dl And Ul Data Traffic With Udp
    ta5g_throughput.Start Data Traffic    ues=11    bearer_id=2    direction=dl    throughput=5mbps    optional_parameters=protocol=udp
    ta5g_throughput.Start Data Traffic    ues=11    bearer_id=2    direction=ul    throughput=5mbps    optional_parameters=protocol=udp

Force Packet Losts On X2-U
    Execute Egate Command    cmd=bearer_ue_gnb_param ue=11 id=2 dud_retx_indication=on
    Execute Egate Command    cmd=ue_enb_endc_param id=11 bearer=5 dud_drop_cfg=5:5

Verify If Specyfic CB008204 Dl Pdcp Sdus Were Transmitted For Nsa Bearer
    Wait For Next PM counters Interval
    Verify CU Counter Value Is Bigger Than The Given Value
    ...    value=0    local_moid=MRBTS-1/NRBTS-1    counter_id=M55319C02009
    Verify CU Counter Value Is Bigger Than The Given Value
    ...    value=0    local_moid=MRBTS-1/NRBTS-1    counter_id=M55319C01009

Verify If Specyfic CB008204 Pdcp Sdu Pm Counters Are Incremented With Cb008828
    Verify CU Counter Value Is Bigger Than The Given Value
    ...    value=0    local_moid=MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-1    counter_id=M55352C02001
    Verify CU Counter Value Is Bigger Than The Given Value
    ...    value=0    local_moid=MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-1    counter_id=M55352C02003
    Verify CU Counter Value Is Bigger Than The Given Value
    ...    value=0    local_moid=MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-1    counter_id=M55352C02005
    Verify CU Counter Value Is Bigger Than The Given Value
    ...    value=0    local_moid=MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-1    counter_id=M55352C02006
