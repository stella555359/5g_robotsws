*** Settings ***

Resource         ../CB011114/resources/CB011114_common_resources.robot
Resource         ./resources/CB008370_resources.robot
Resource         ../../../resources/robot/wts_sim_keywords.robot
Resource           ../CB008541/resources/CB008541_Keywords.robot


Documentation
...
...  AUTHOR          :  Kshitij Tyagi
...  MAINTAINER      :  kshitij.tyagi@nokia.com
...  INTRODUCTION    :  This user scenario describes the activation of the feature
...                     “CB008370 PDSCH shared symbol with PDCCH” with multiple UEs in the test.
...  TEST SET NAME   :  CB008370_A_B3_TC12_Activation_of_the_feature
...  CONTACTS        :  kshitij.tyagi@nokia.com
...  REFERENCES      :  CFAM
...  REQUIREMENT ID  :  5G_RAN_USR_RRM_24681

*** Variables ***
${WTS_DIR}          /opt/iphy/latest
${wts_cfg_file}     ${CURDIR}/config/basic_tc11.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${NOKIA_LOGIN}  toor4nsn
${NOKIA_PASS}   oZPS0POrRieRtu
${scell_idx}    0
${ul_ue_ip}    72.23.0.1
${dl_ue_ip}    1.2.4.2
${dl_port}    7073
${ul_port}    7074
${duration}    -t 3600
${bytes}    -n 8000000
${ping_unit}    Kbps
${iperf_unit}    Mbps
${exp_dl_avg_ping}    1.4
${exp_ul_avg_ping}    2.8
${exp_dl_avg_iperf}    450
${exp_ul_avg_iperf}    220
${startMutingParam}    trigger_rf_fault 0
${stopMutingParam}    cancel_rf_fault 0
${nwslice_ID}    1
${gw_ID}     1
${pdu_id}    1
${nw_id}     1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${ue_id}     1
${Pdu_session_ID}    1
${epc_log_path}     /tmp/
${SCFC}=                 ${CURDIR}/config/SCF/SCF_TC11.xml
${AP_XML}=                ${CURDIR}/config/SCF/iphy_TC11.xml
${gscn_value}   1
${st_ue_id}      1
${en_ue_id}      3
@{PDSCH_SLIVs}=    ${98}   ${85}   ${57}   ${70}   ${56}   ${43}   ${27}   ${41}   ${55}   ${83}   ${97}


*** Keywords ***
CB008370_A_B3_TC12_Activation_of_the_feature_with_multiple_UEs_rdUseDAfterUForPdcchSharingTdd
    Set Test Variable   ${st_ue_id}   1
    Set Test Variable   ${en_ue_id}   10
    MUE register flag on
    Trigger MUE data and validate THP
    Collect TTI trace and check PDSCH SLIVs present    ${LOG_PATH}    ${PDSCH_SLIVs}
    Trigger Bler with pktloss
    Collect TTI trace and check PDSCH SLIVs present    ${LOG_PATH}    ${PDSCH_SLIVs}
    Collect Counters
    Check counter Cell1M55335C02019
    Stop Data for Ues
    Trigger Low data
    Collect Counters
    Check counter Cell1M55335C02020 and Cell1M55335C02019
    wts_sim_keywords.MultiUE Deregister should be Successful      ${st_ue_id}    ${en_ue_id}

MUE register flag off
    FOR  ${UE}  IN RANGE   ${st_ue_id}   ${en_ue_id}+1
        ${rnti_1}   UE Register should be Successful And Fetch RNTI and TDRA list    ${UE}     pdu_id=${Pdu_session_ID}     nw_id=${nwslice_ID}
    END
MUE register flag on
    FOR  ${UE}  IN RANGE   ${st_ue_id}   ${en_ue_id}+1
        ${rnti_2}   UE Register should be Successful And Fetch RNTI and TDRA list  ${UE}  pdu_id=${Pdu_session_ID}  nw_id=${nwslice_ID}  8370_flag=1
    END

Check counter Cell1M55335C02019
     Log To Console      ${Cell1M55335C02019_8370_enabled_C3}     ${Cell1M55335C02020_8370_enabled_C4}
     Should Be True     ${Cell1M55335C02019_8370_enabled_C3} > 300000

Check counter Cell1M55335C02020 and Cell1M55335C02019
     Log To Console      ${Cell1M55335C02019_8370_enabled_C3}     ${Cell1M55335C02020_8370_enabled_C4}
     Should Be True     ${Cell1M55335C02020_8370_enabled_C4} > 1500
     Should Be True     ${Cell1M55335C02019_8370_enabled_C3} > 2000

Get DL throughput
    [Arguments]      ${st_ue_id}    ${en_ue_id}
	FOR    ${ue_id}    IN RANGE    ${st_ue_id}    ${en_ue_id}+1
        ${pcell_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${ue_id}    scell_idx=0    unit=Mbps
	END

Validate UL throughput
    [Arguments]      ${st_ue_id}    ${en_ue_id}    ${expected_UL_thp}
	FOR    ${ue_id}    IN RANGE    ${st_ue_id}    ${en_ue_id}+1
        ${pcell_tput}=    wts_sim_keywords.Get AVG UL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=0    unit=Mbps
        Should Be True    ${pcell_tput} > ${expected_UL_thp}
    END

Multi ue register and data for featue off
    MUE register flag off
    CB008370_resources.Start Multi UE DL traffic with multiple trafficID      start_ue=${st_ue_id}   end_ue=${en_ue_id}    dl_trf_id=9    qfi_id=1
    CB008370_resources.Start Multi UE UL traffic with multiple trafficID      start_ue=${st_ue_id}    end_ue=${en_ue_id}    ul_trf_id=2    qfi_id=1
    sleep      10s
    ${tp_1}=      Get DL Throughput for Pcell    UE_ID=1    end_UE_ID=3    expected_thp=0
    #${tp_2}=      Get DL throughput     2     3
    start log      biptaf
    Intiate Bler for Ues and activate with pktloss     1   1     dl_bler=100,100,50,50,50,50,50,50
    sleep     3s
    ${tp_3}      Get DL Throughput for Pcell    UE_ID=1    end_UE_ID=3    expected_thp=0
    ${scene2}    Stop log    biptaf     test_scenario=feature_off_bler

Trigger MUE data and validate THP
    log to console   UE attach trigerring now...
    CB008370_resources.Start Multi UE DL traffic with multiple trafficID      start_ue=${st_ue_id}   end_ue=${en_ue_id}    dl_trf_id=3    qfi_id=1
    CB008370_resources.Start Multi UE UL traffic with multiple trafficID      start_ue=${st_ue_id}    end_ue=${en_ue_id}    ul_trf_id=1    qfi_id=1
    sleep       5s
    Get DL Throughput for Pcell    UE_ID=1    end_UE_ID=1    expected_thp=70
    Get DL Throughput for Pcell    UE_ID=2    end_UE_ID=2    expected_thp=70
    Get DL Throughput for Pcell    UE_ID=3    end_UE_ID=3    expected_thp=70
    Get DL Throughput for Pcell    UE_ID=4    end_UE_ID=4    expected_thp=70
    Get DL Throughput for Pcell    UE_ID=5    end_UE_ID=5    expected_thp=70
    Get DL Throughput for Pcell    UE_ID=6    end_UE_ID=6    expected_thp=70
    Get DL Throughput for Pcell    UE_ID=7    end_UE_ID=7    expected_thp=70
    Get DL Throughput for Pcell    UE_ID=8    end_UE_ID=8    expected_thp=70
    Get DL Throughput for Pcell    UE_ID=9    end_UE_ID=9    expected_thp=70
    Get DL Throughput for Pcell    UE_ID=10   end_UE_ID=10   expected_thp=70

Trigger Bler with pktloss
    Add Bler for Ues and activate with pktloss     1   1
    sleep     3s
    Get DL Throughput for Pcell    UE_ID=1    end_UE_ID=1    expected_thp=20
    Get DL Throughput for Pcell    UE_ID=2    end_UE_ID=2    expected_thp=20
    Get DL Throughput for Pcell    UE_ID=3    end_UE_ID=3    expected_thp=20
    Get DL Throughput for Pcell    UE_ID=4    end_UE_ID=4    expected_thp=20
    Get DL Throughput for Pcell    UE_ID=5    end_UE_ID=5    expected_thp=20
    Get DL Throughput for Pcell    UE_ID=6    end_UE_ID=6    expected_thp=20
    Get DL Throughput for Pcell    UE_ID=7    end_UE_ID=7    expected_thp=20
    Get DL Throughput for Pcell    UE_ID=8    end_UE_ID=8    expected_thp=20
    Get DL Throughput for Pcell    UE_ID=9    end_UE_ID=9    expected_thp=20
    Get DL Throughput for Pcell    UE_ID=10   end_UE_ID=10   expected_thp=20

Add Bler for Ues and activate with pktloss
    [Arguments]    ${startue}    ${endue}
    ${profile}	   SET VARIABLE
    ...   bler_testmode_nr profile_id=1 dl_bler=100,100,50,50,50,50,50,50
    ute_wtssim.execute_egate_command    ${profile}
    FOR     ${ue_idx}   IN RANGE    ${startue}    ${endue}+1
    ${activate}	   SET VARIABLE    ue_testmode_set_nr id=${ue_idx} testmode=bler profile_id=1 action=activate
    ute_wtssim.execute_egate_command    ${activate}
    END

Collect Counters
    Log To Console    Collecting legacy & new counters
    ${Cell1M55308C03001_8370_enabled_C1}    ${Cell1M55308C03005_8370_enabled_C2}       ${Cell1M55335C02019_8370_enabled_C3}
    ...    ${Cell1M55335C02020_8370_enabled_C4}     Collect Legacy and New Counters
    Set Suite Variable   ${Cell1M55308C03001_8370_enabled_C1}
    Set Suite Variable   ${Cell1M55308C03005_8370_enabled_C2}
    Set Suite Variable   ${Cell1M55335C02019_8370_enabled_C3}
    Set Suite Variable   ${Cell1M55335C02020_8370_enabled_C4}
    #Log To Console      ${Cell1M55308C03001_8370_disabled_C1}       ${Cell1M55308C03005_8370_disabled_C2}
    Log To Console      ${Cell1M55308C03001_8370_enabled_C1}      ${Cell1M55308C03005_8370_enabled_C2}
    Log To Console      ${Cell1M55335C02019_8370_enabled_C3}     ${Cell1M55335C02020_8370_enabled_C4}

Stop Data for Ues
    Run Keyword And Continue on Failure     Multiue DL TRF Data Stop for SA     1   10     trf_id=1-3
    Run Keyword And Continue on Failure     Multiue UL TRF Data Stop for SA     1   10     trf_id=1

Trigger Low data
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    1   1    Traffic_rate=mbps     dl_rate=10    pdu_id=1      trf_id=1    qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    2   3    Traffic_rate=mbps     ul_rate=5    pdu_id=1      trf_id=1    qfi_id=1
    sleep       5s
    Get DL Throughput for Pcell    UE_ID=1    end_UE_ID=1    expected_thp=9
    Validate UL throughput    2    3    4
