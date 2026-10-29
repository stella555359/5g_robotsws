*** Settings ***
Documentation
...  Author:        Maciej Cupial, Adam Tokarski
...  Contact:       maciej.cupial@nokia.com, adam.tokarski@nokia.com
...  Feature owner: Karol Malutkiewicz, Witold Galka
...  Description:   Power Saving feature for 5G site, part 2
...                 Feature Corner:     https://feature-corner.nsn-net.net/materials/clchjwwcs374404xkzix2h4shg

Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/pcap_common.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/keywords_SFE.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/multi_UE.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB010442/resources/keywords_10442.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB010443/resources/keywords_10443.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/logs_collection.robot
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/counters.py        WITH NAME   link_wro4_pm
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/tracing.py         WITH NAME   link_wro4_tracing

*** Variables ***
${ue_alias}              UE_1
@{LTE_CELLS}             ${13}    ${14}    ${15}    ${16}
@{UE}                  UE_3
${tput_deviation}       10%
${tput_dl_100Mhz}          780 Mbits/sec
${tput_ul_100Mhz}           58 Mbits/sec
${tput_min_dl_100Mhz}          1 Mbits/sec
${tput_min_ul_100Mhz}          1 Mbits/sec

*** Keywords ***
CB010442_A#B1_One_X2_link_MeNB_requests_to_switch_on_one_NSA_NR_cell_and_feature_CB010442_is_activated
    ${lte_cells_ids}        Get LTE Cells Ids
    ${global_5g_cells_ids}  ${5g_cells_ids}    Get Cells Info 10442
    Perform Commissioning 10442 5G    ${global_5g_cells_ids[0]}
    Perform Commissioning 10442 LTE   ${lte_cells_ids}     ${5g_cells_ids[0]}
    Activate 10442
    Activate 10443
    Attenuate Cells 10442    ${LTE_CELLS}
    Wait For LTE And 5G Energy Saving Cells Are In Power Saving State
    ...    ${lte_cells_ids[0]}
    ...    ${global_5g_cells_ids[0]}
    Wait For lbpsGuardTimerNrAct
    Setup Cplane Tcpdump Collector
    Start Cplane Logs
    attach ues to cell  ${UE}
    Start Max ULDL UDP  ue_alias=${UE}[0]  tput_duration=900s
    Wait For LTE And 5G Energy Saving Cells Are On Air
    run keyword and ignore error  Stop ULDL
    run keyword and ignore error  detach ues from cell  ${UE}
    Stop Cplane Logs
    Verify Counters And Pdml AB1    ${global_5g_cells_ids[0]}


CB010442_A#EC1_MeNB_requests_to_switch_on_one_NSA_NR_cell_and_feature_CB010442_is_not_activated
    ${lte_cells_ids}        Get LTE Cells Ids
    ${global_5g_cells_ids}  ${5g_cells_ids}    Get Cells Info 10442
    Perform NRPGRP Delta 10442    ${global_5g_cells_ids[0]}
    Perform Commissioning 10442 LTE
    ...    ${lte_cells_ids}
    ...    ${5g_cells_ids[0]}
    ...    lbpsMaxLoad=17
    ...    lbpsMaxLoadNrAct=1
    ...    lbpsMinLoad=1
    ...    lbpsMinNumEndcCapUeNrAct=0
    Activate 8951 EC1
    Activate 10443
    Attenuate Cells 10442    ${LTE_CELLS}    true
    Log To Console    __Preform site reset
    Site Reset
    Verify if all cells are onair    interval=30sec
    Log To Console                 __Wait for 5G energy saving cell status
    Wait Until Keyword Succeeds    8min    30sec    Check 5G Energy Saving Cell Status     ${global_5g_cells_ids[0]}
    Setup Cplane Tcpdump Collector
    Start Cplane Logs
    Check 5G Energy Saving Cell Status    ${global_5g_cells_ids[0]}
    Verify Counters EC1
    Stop Cplane Logs
    Verify Pdml 10442 EC1


Energy Saving with Deep Sleep pronto handling
    Wait For Next PM Counter Interval Starts
    Perform basic NRPGRP Delta 10442
    Add NRPGRP LBPS lists for power saving mode
    Activate 10442 and 10766
    Wait For 5G Energy Saving Cells Are In Power Saving State
    Check if PMs incremented properly for energy saving
    Create Delta for DeepSleep scheduler
    Wait For 5G RU Is In Deep Sleep mode
    Check X2 during Deepsleep
    ${status}	${value} =  Run Keyword And Ignore Error    Wait For 5G RU Is In Deep Sleep mode
                                                            ...    timeout=15min
                                                            ...    retry_interval=90sec
                                                            ...    5g_Radio_modules=AZQJ
                                                            ...    RU_status=AWAKE
    Run Keyword If	'${status}' == 'FAIL'    Wait For 5G RU Is In Deep Sleep mode
                                            ...    timeout=10min
                                            ...    retry_interval=60sec
                                            ...    5g_Radio_modules=AZQJ
                                            ...    RU_status=AWAKE

Energy Saving with SFCCR_1635
    [Documentation]
    ...    TCs due EDA SFCCR-1635 Compare the DL Spectral efficiency, MCS with CB010683 feature enabled (when N41 cell is out of Muting/CSO state)
    ...    versus feature disabled. Loading should fall below 20%, so the N41 cell enters Energy Savings Cell Switch off state. Then increase
    ...    the loading to bring the switched off N41 cells back up and remain consistently up.  Expectation is that between feature off vs on,
    ...    the DL Spectral Efficiency, DL MCS, etc should be comparable when the cells are OUT of the Energy Savings state. To avoid situation
    ...    when DL spectral efficiency stays degraded tput the daytime with the feature enabled even though the CSO/Muting kicks in only
    ...    during nighttime.

    line.write line                     \n _Step_1 allign 1st interval for UE attach and tput with value: ${tput_dl_100Mhz} when features disabled
    link_wro4_pm.sync_to_next_reporting_interval    offset=0     pm_interval=900
    attach ues to cell  ${UE}
    Start Max ULDL UDP  ue_alias=${UE}[0]  tput_duration=1440s    tput_DL_bandwidth=${tput_dl_100Mhz}    tput_UL_bandwidth=${tput_ul_100Mhz}
    ...    dt_DL_name=DL_disabled_max_1     dt_UL_name=UL_disabled_max_1
    line.write line                     \n _Step_2 allign to 2nd 15mins interval, check current date and next KPI interval
    link_wro4_pm.sync_to_next_reporting_interval    offset=0     pm_interval=900
    ${scout_data_collect_start_time}   Get Current Date  result_format=%Y-%m-%d %H:%M
    link_wro4_pm.sync_to_next_reporting_interval    offset=120     pm_interval=900
    line.write line                     \n _Step_3 Verify average tput and KPIs, detach UE from cell
    Get KPIs Report from Scout then Validate them and Send to Reporting Portal   ${scout_data_collect_start_time}    is_enabled=${FALSE}
    run keyword and ignore error      taf.ue.Verify Average Throughput With Deviation   DL_disabled_max_1
    ...    ${tput_dl_100MHz}    ${tput_deviation}   omit=100
    run keyword and ignore error     Stop ULDL    dt_UL_name=UL_disabled_max_1    dt_DL_name=DL_disabled_max_1
    run keyword and ignore error     detach ues from cell  ${UE}
    line.write line                     \n _Step_4 perform delta commissioning where features 5GC000431, CB008133, CB010683 activated
    Add NRPGRP LBPS lists for power saving mode 10683
    ...    lbpsCellDuration=15       lbpsUseExtConfig=true    lbpsCellSOMethod=mixed switch off    actNrExtCellSOMethod=true
    line.write line                     \n _Step_5 Start low value DL TPUT with value: ${tput_min_dl_100Mhz} bellow minimum load
    attach ues to cell  ${UE}
    Start Max ULDL UDP  ue_alias=${UE}[0]  tput_duration=480s    tput_DL_bandwidth=${tput_min_dl_100Mhz}    tput_UL_bandwidth=${tput_min_dl_100Mhz}
    ...    dt_DL_name=DT_DL_2_min_load     dt_UL_name=DT_UL_2_min_load
    line.write line                     \n _Step_6 wait for expected states reducedEnergySaving > energySaving > notEnergySaving and start max tput
    Wait For 5G reduced Energy Saving Cells Are In                 5G_cell=999    check_time=12min
    run keyword and ignore error      Wait For 5G Energy Saving Cells Are In Power Saving State      5G_cell=999    check_time=12min
    run keyword and ignore error      Wait For 5G Energy Saving Cells Are Out Power Saving State     5G_cell=999    check_time=12min
    link_wro4_pm.sync_to_next_reporting_interval    offset=0     pm_interval=900
    Start Max ULDL UDP  ue_alias=${UE}[0]  tput_duration=1440s    tput_DL_bandwidth=${tput_dl_100Mhz}    tput_UL_bandwidth=${tput_dl_100Mhz}
    ...    dt_DL_name=DL_enabled_max_1     dt_UL_name=UL_enabled_max_1
    link_wro4_pm.sync_to_next_reporting_interval    offset=0     pm_interval=900
    ${scout_data_collect_start_time}   Get Current Date  result_format=%Y-%m-%d %H:%M
    line.write line                     \n _Step_7 waiting for final interval for expected check KPIs
    link_wro4_pm.sync_to_next_reporting_interval    offset=120     pm_interval=900
    Get KPIs Report from Scout then Validate them and Send to Reporting Portal   ${scout_data_collect_start_time}    is_enabled=${TRUE}
    line.write line                     \n _Step_8 Verify average tput with KPIs and detach UE from cell
    run keyword and ignore error      taf.ue.Verify Average Throughput With Deviation   DL_enabled_max_1
    ...   ${tput_dl_100MHz}    ${tput_deviation}   omit=100
    run keyword and ignore error  Stop ULDL    dt_UL_name=UL_enabled_max_1    dt_DL_name=DL_enabled_max_1
    [Teardown]    Run Keywords
    ...           detach ues from cell  ${UE}
    ...   AND     Stop ULDL    dt_UL_name=UL_disabled_max_1    dt_DL_name=DL_disabled_max_1
    ...   AND     Stop ULDL    dt_UL_name=UL_enabled_max_1     dt_DL_name=DL_enabled_max_1


Energy Saving with SFCCR_2438
    [Documentation]
    ...    TCs due CNI-147674 with SFCCR-2438 PR-04728040
    ${lte_cells_ids}        Get LTE Cells Ids
    ${global_5g_cells_ids}  ${5g_cells_ids}    Get Cells Info 10442
    Perform basic NRPGRP Delta 10442
    Perform Commissioning 10442 LTE   ${lte_cells_ids}     ${5g_cells_ids[3]}
    Add NRPGRP LBPS lists for power saving mode with real test time    lbpsDuration=25
    Activate 10442
    Activate 10443
    Wait For LTE And 5G Energy Saving Cells Are In Power Saving State
    ...    ${lte_cells_ids[0]}
    ...    ${global_5g_cells_ids[3]}
    ...    5G_cell_time=12min
    Create Delta for DeepSleep scheduler
    Wait For 5G RU Is In Deep Sleep mode
    Wait For 5G RU back from Energy Saving and Deep Sleep state to ProceduralStatus Configured     RU_ProceduralStatus=initializing
    ${pcap_file}=   link_wro4_tracing.Start Listening Tcpdump From Smod   filepath=LTE_cordination.pcap
    attach ues to cell  ${UE}
    Attenuate Cells 10442    ${LTE_CELLS}
    Start Max ULDL UDP  ue_alias=${UE}[0]  tput_duration=240s
    Wait For 5G RU back from Energy Saving and Deep Sleep state to ProceduralStatus Configured
    BuiltIn.sleep    30s
    link_wro4_tracing.Stop Listening Tcpdump From Smod
    CHECK TIME
    Run Keyword And Continue On Failure    verify_GNBDUConfigurationUpdate_in_rrc_messages    ${pcap_file}
    ${status}	${value} =  Run Keyword And Ignore Error    Wait For 5G RU Is In Deep Sleep mode
                                                            ...    timeout=15min
                                                            ...    retry_interval=90sec
                                                            ...    5g_Radio_modules=AZQJ
                                                            ...    RU_status=AWAKE
    [Teardown]    detach ues from cell  ${UE}
