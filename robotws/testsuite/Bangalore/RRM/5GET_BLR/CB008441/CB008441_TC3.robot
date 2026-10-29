*** Settings ***
Force Tags      CLOUD_5G_O_H_AP_LOO
...             CRT    RAN_5G    5G_RAN     SBTS00    SBTS25R1    CONFIGURED

Documentation
...             author:                 samik.sarkar@nokia.com
...             maintainer:             samik.sarkar@nokia.com
...
...             INTRODUCTION:      CB008441_A
...             TEST SET NAME:     [1]CB008441_3_PDCP_Delay_Based_Discarding_PI2_TCP_performance_short_duration_Multiple_stream.robot
...             TESTING SPLIT:     See CB008441 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008441 CFAM
...             REQUIREMENT ID:    5G_RAN_USR_RRM_24120,5G_PM_1530,5G_RAN_USR_RRM_23142

Resource         ./CB008441_resource.robot


Suite Setup         Run keywords
...                 Log To console  SuiteSetup
...                 AND     Prepare TL with all config files with rad_params
...                 AND    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     gnb.Perform gNB reboot
...                 AND    Sleep   600s    reason=wait for RMOD to comeup
...                 AND    Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND    sleep  60s   reason=wait for mib sib

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Run Keyword and Ignore Error    Stop Log     snapshot    #sosreport
...                 AND     Kill WTS processes Using WTS_Runner

*** Variables ***
${SCFC}=        ${CURDIR}/config/SBTS24R3/ASOH_TC3_SCF_MP.xml
${AP_XML}=      ${CURDIR}/config/SBTS24R3/ASOH_TC2_TC3_iphy.xml
${rad_params}   0x5A0622=1,0x5A00B3=4B,0x5A00B3=5

${wts_cfg_file}    ${CURDIR}/config/wts/ASOH_basic_setup_SANSA_FDD_MP-AP-LO.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}     /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}        1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${pathloss_start_dB}        75
${pathloss_end_dB}      130
${epc_log_path}    /tmp/
${TEST_NAME}        TC3
@{Component1}   L2HIPDCP
@{Nrcell}       NRCELL_1

${st_sa_ue}     1
${en_sa_ue}     4
${st_nsa_ue}    0
${en_nsa_ue}    0

*** Test Cases ***
[1][1.0] CB008441_4_PDCP_Delay_Based_Discarding_PI2_TCP_performance_Comparisson_long_duration_Multiple_stream

    set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...
    Increase Buffer Size for VM and IPHY

    X2AP Link Should be UP

#    Perform SCF Delta Commissioning with TC_3_scenario_2.json

    Start Log       btslog  cprt
    ${crnti_list1}      MultiUE SA Register should be Successful Generalised    ${st_sa_ue}    ${en_sa_ue}
    ...    pdu_id=1     nw_id=1  trf_type=external
    log to console      attached-sa-ue-rnti-${crnti_list1}


    Stop Log    cprt    btslog    test_scenario=SCN1/CoDel

    ${path_SCN1_CoDel}    Queueing Discard With Different Scenarios   st_sa_ue=${st_sa_ue}  en_sa_ue=${en_sa_ue}
    ...      st_nsa_ue=${st_nsa_ue}    en_nsa_ue=${en_nsa_ue}
    ...      bytes=1000    duration=600     stream=4
    ...      dir=DL    scenario=SCN1/CoDel  BW=25    protocol=UDP
    log to console      scn1_path-${path_SCN1_CoDel}

    sleep    300s
    ${path_SCN2_CoDel}    Queueing Discard With Different Scenarios   st_sa_ue=${st_sa_ue}  en_sa_ue=${en_sa_ue}
    ...      st_nsa_ue=${st_nsa_ue}    en_nsa_ue=${en_nsa_ue}
    ...      bytes=1000    duration=2     stream=1
    ...      dir=DL    scenario=SCN2/CoDel  BW=100    protocol=UDP
    log to console      scn2_path-${path_SCN2_CoDel}

    ${path_SCN3_CoDel}    Queueing Discard With Different Scenarios   st_sa_ue=${st_sa_ue}  en_sa_ue=${en_sa_ue}
    ...      st_nsa_ue=${st_nsa_ue}    en_nsa_ue=${en_nsa_ue}
    ...      bytes=1000    duration=20     stream=1
    ...      dir=DL    scenario=SCN3/CoDel  BW=100    protocol=UDP
    log to console      sc3_path-${path_SCN3_CoDel}

    ${path_SCN4_CoDel}    Queueing Discard With Different Scenarios   st_sa_ue=${st_sa_ue}  en_sa_ue=${en_sa_ue}
    ...      st_nsa_ue=${st_nsa_ue}    en_nsa_ue=${en_nsa_ue}
    ...      bytes=1000    duration=2     stream=10
    ...      dir=DL    scenario=SCN4/CoDel  BW=10    protocol=UDP
    log to console      scn4_path-${path_SCN4_CoDel}

    ${path_SCN5_CoDel}    Queueing Discard With Different Scenarios   st_sa_ue=${st_sa_ue}  en_sa_ue=${en_sa_ue}
    ...      st_nsa_ue=${st_nsa_ue}    en_nsa_ue=${en_nsa_ue}
    ...      bytes=1000    duration=20     stream=10
    ...      dir=DL    scenario=SCN5/CoDel  BW=10    protocol=UDP
    log to console      scn5_path-${path_SCN5_CoDel}

    MultiUE Deregister should be Successful   ${st_sa_ue}    ${en_sa_ue}


    Perform SCF Delta Commissioning with enable_pi2.json

    Start Log       btslog  cprt
    ${crnti_list1_pi2}      MultiUE SA Register should be Successful Generalised    ${st_sa_ue}    ${en_sa_ue}
    ...     pdu_id=1     nw_id=1  trf_type=external
    log to console      attached-sa-ue-rnti-${crnti_list1_pi2}


    Stop Log    cprt    btslog    test_scenario=SCN1/PI2

    ${path_SCN1_PI2}    Queueing Discard With Different Scenarios   st_sa_ue=${st_sa_ue}  en_sa_ue=${en_sa_ue}
    ...      st_nsa_ue=${st_nsa_ue}    en_nsa_ue=${en_nsa_ue}
    ...      bytes=1000    duration=600     stream=4
    ...      dir=DL    scenario=SCN1/PI2  BW=25    protocol=UDP
    log to console      scn1_path-${path_SCN1_PI2}

    sleep   300s

    ${path_SCN2_PI2}    Queueing Discard With Different Scenarios   st_sa_ue=${st_sa_ue}  en_sa_ue=${en_sa_ue}
    ...      st_nsa_ue=${st_nsa_ue}    en_nsa_ue=${en_nsa_ue}
    ...      bytes=1000    duration=2     stream=1
    ...      dir=DL    scenario=SCN2/PI2  BW=100    protocol=UDP
    log to console      scn2_path-${path_SCN2_PI2}


    ${path_SCN3_PI2}    Queueing Discard With Different Scenarios   st_sa_ue=${st_sa_ue}  en_sa_ue=${en_sa_ue}
    ...      st_nsa_ue=${st_nsa_ue}    en_nsa_ue=${en_nsa_ue}
    ...      bytes=1000    duration=20     stream=1
    ...      dir=DL    scenario=SCN3/PI2  BW=100    protocol=UDP
    log to console      scn3_path-${path_SCN3_PI2}

    ${path_SCN4_PI2}    Queueing Discard With Different Scenarios   st_sa_ue=${st_sa_ue}  en_sa_ue=${en_sa_ue}
    ...      st_nsa_ue=${st_nsa_ue}    en_nsa_ue=${en_nsa_ue}
    ...      bytes=1000    duration=2     stream=10
    ...      dir=DL    scenario=SCN4/PI2  BW=10    protocol=UDP
    log to console      scn4_path-${path_SCN4_PI2}

    ${path_SCN5_PI2}    Queueing Discard With Different Scenarios   st_sa_ue=${st_sa_ue}  en_sa_ue=${en_sa_ue}
    ...      st_nsa_ue=${st_nsa_ue}    en_nsa_ue=${en_nsa_ue}
    ...      bytes=1000    duration=20     stream=10
    ...      dir=DL    scenario=SCN5/PI2  BW=10    protocol=UDP
    log to console      scn5_path-${path_SCN5_PI2}


    MultiUE Deregister should be Successful   ${st_sa_ue}    ${en_sa_ue}

    Comapare CoDel vs PI2   ${path_SCN1_CoDel}[iperf3]    ${path_SCN1_PI2}[iperf3]   ${4}
    Comapare CoDel vs PI2   ${path_SCN2_CoDel}[iperf3]     ${path_SCN2_PI2}[iperf3]   ${4}
    Comapare CoDel vs PI2   ${path_SCN3_CoDel}[iperf3]     ${path_SCN3_PI2}[iperf3]   ${4}
    Comapare CoDel vs PI2   ${path_SCN4_CoDel}[iperf3]     ${path_SCN4_PI2}[iperf3]   ${4}
    Comapare CoDel vs PI2   ${path_SCN5_CoDel}[iperf3]     ${path_SCN5_PI2}[iperf3]   ${4}

    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
Check gNB Bulid
    ${aliasGNB}                     OAM Connect                             ${AIRSCALE_GNB.oam}
    ${GNB_SW_VERSION}               OAM Get SW Version                      oam=${AIRSCALE_GNB.oam}
    Set Suite Variable    ${GNB_SW_VERSION}

Queueing Discard With Different Scenarios
    [Arguments]    ${st_sa_ue}=0    ${en_sa_ue}=0    ${st_nsa_ue}=0    ${en_nsa_ue}=0    ${bytes}=${EMPTY}    ${duration}=${EMPTY}
    ...     ${stream}=${EMPTY}    ${dir}=DL     ${scenario}=${EMPTY}    ${BW}=0    ${protocol}=TCP

    Start Log      btslog    ttitrace    layer=L2HiPdcp
    Wait until the next Measurement Period starts  additional_time=${0}
#    Start Log Via DCAP  ttitrace  component=${Component1}    CellId=${Nrcell}

    Run Keyword if    '${st_sa_ue}'!='0' and '${en_sa_ue}'!='0' and '${dir}'=='both'
    ...     Start Multiue Iperf3 TCP Sporadic Data      ${st_sa_ue}    ${en_sa_ue}    ${bytes}
    ...     ${duration}   ${stream}   DL    SA    ${BW}   ${protocol}

    Run Keyword if    '${st_sa_ue}'!='0' and '${en_sa_ue}'!='0' and '${dir}'=='both'
    ...     Start Multiue Iperf3 TCP Sporadic Data      ${st_sa_ue}    ${en_sa_ue}    ${bytes}
    ...     ${duration}   ${stream}   UL    SA    ${BW}   ${protocol}

    Run Keyword if    '${st_sa_ue}'!='0' and '${en_sa_ue}'!='0' and '${dir}'!='both'
    ...     Start Multiue Iperf3 TCP Sporadic Data      ${st_sa_ue}    ${en_sa_ue}    ${bytes}
    ...     ${duration}   ${stream}   ${dir}    SA    ${BW}   ${protocol}

    Run Keyword if    '${st_nsa_ue}'!='0' and '${en_nsa_ue}'!='0' and '${dir}'=='both'
    ...     Start Multiue Iperf3 TCP Sporadic Data      ${st_nsa_ue}    ${en_nsa_ue}    ${bytes}
    ...     ${duration}   ${stream}   DL    NSA    ${BW}   ${protocol}

    Run Keyword if    '${st_nsa_ue}'!='0' and '${en_nsa_ue}'!='0' and '${dir}'=='both'
    ...     Start Multiue Iperf3 TCP Sporadic Data      ${st_nsa_ue}    ${en_nsa_ue}    ${bytes}
    ...     ${duration}   ${stream}   UL    NSA    ${BW}   ${protocol}

    Run Keyword if    '${st_nsa_ue}'!='0' and '${en_nsa_ue}'!='0' and '${dir}'!='both'
    ...     Start Multiue Iperf3 TCP Sporadic Data      ${st_nsa_ue}    ${en_nsa_ue}    ${bytes}
    ...     ${duration}   ${stream}   ${dir}    NSA    ${BW}   ${protocol}

    ${duration}    Convert To Integer   ${duration}
    ${sleep}    Evaluate    ${duration}+${10}
    sleep     ${sleep}s
    Stop Iperf3 Traffic

    ${path}    Stop Log    ttitrace    btslog    test_scenario=${scenario}

    Wait until the current Measurement Period stops  additional_time=${0}
    Create Directory        ${LOG_PATH}/${TEST_NAME}/gNB/iperf3/${scenario}
    OperatingSystem.Run      cp /tmp/iperf3_*_DL_*.txt ${LOG_PATH}/${TEST_NAME}/gNB/iperf3/${scenario}
    OperatingSystem.Run      rm -rf /tmp/iperf3_*_DL_*.txt

    Set To Dictionary   ${path}     iperf3      ${LOG_PATH}/${TEST_NAME}/gNB/iperf3/${scenario}
    ${path1}    Stop Log    snapshot     test_scenario=${scenario}
    [return]    ${path}


TCPDUMP Capture
    [Arguments]    ${scenario}
    Create Directory        ${LOG_PATH}/${TEST_NAME}/gNB/NGAP/${scenario}
    OperatingSystem.Run     nohup sudo tcpdump -i any port 2152 -s0 -w ${LOG_PATH}/${TEST_NAME}/gNB/NGAP/${scenario}/test.pcap >/dev/null&
    OperatingSystem.Run     ps -eaf|grep test.pcap > ${OUTPUT_DIR}/abc.txt


###########
Get UE Stats for UDP Traffic
    [Arguments]    ${filePath}  ${numUE}
    ${jitter}    Set Variable   ${0}
    ${bitrate}   Set Variable   ${0}
    ${loss}      Set Variable   ${0}

    FOR     ${ue_idx}   IN RANGE   ${1}     ${numUE}+${1}
    ${file}     Set variable    ${filePath}/iperf3_c_DL_${ue_idx}.txt
    ${single_strem_jitter}   set variable    |grep -i mbytes.*receiver|awk '{print $9}'
    ${multi_stream_jitter}   set variable    |grep -i sum.*receiver|awk '{print $8}'

    ${single_strem_bitrate}   set variable    |grep -i mbytes.*receiver|awk '{print $7}'
    ${multi_stream_bitrate}   set variable    |grep -i sum.*receiver|awk '{print $6}'

    ${single_strem_loss}   set variable    |grep -i mbytes.*receiver|awk '{print $11}'|awk -F '/' '{print $1}'
    ${multi_stream_loss}   set variable    |grep -i sum.*receiver|awk '{print $10}'|awk -F '/' '{print $1}'

    ${stream}     Run    cat ${file}|grep -i start.*test|awk '{print $5}'

    ${pattern_jitter}    set variable if  ${stream}==${1}    ${single_strem_jitter}   ${multi_stream_jitter}
    ${jitter_upd}     Run      cat ${file}${pattern_jitter}

    ${pattern_bitrate}    set variable if  ${stream}==${1}    ${single_strem_bitrate}   ${multi_stream_bitrate}
    ${bitrate_upd}     Run      cat ${file}${pattern_bitrate}

    ${pattern_loss}    set variable if  ${stream}==${1}    ${single_strem_loss}   ${multi_stream_loss}
    ${loss_upd}     Run      cat ${file}${pattern_loss}

    ${jitter}    Evaluate   ${jitter} + ${jitter_upd}
    ${bitrate}   Evaluate   ${bitrate} + ${bitrate_upd}
    ${loss}      Evaluate   ${loss} + ${loss_upd}
    END
    [Return]    ${jitter}   ${bitrate}    ${loss}

Comapare CoDel vs PI2
    [Arguments]   ${path_CoDel}    ${path_PI2}      ${numUE}
    ${jitter_CoDel}   ${bitrate_CoDel}    ${loss_CoDel}     Get UE Stats for UDP Traffic   ${path_CoDel}    ${numUE}
    ${jitter_PI2}   ${bitrate_PI2}    ${loss_PI2}           Get UE Stats for UDP Traffic   ${path_PI2}      ${numUE}
    log to console      CODEL_jitter-${jitter_CoDel}_bitrate-${bitrate_CoDel}_loss-${loss_CoDel}
    log to console      PI2_jitter-${jitter_PI2}_bitrate-${bitrate_PI2}_loss-${loss_PI2}
    ${per_loss}    Run Keyword if   ${loss_CoDel}!=${0}
    ...     Evaluate        ${loss_PI2}/${loss_CoDel}
    ...     ELSE
    ...     Set Variable    None
    Run Keyword if   ${per_loss}!=None
    ...     Should be True      ${per_loss}<=150

    ${per_bitrate}    Evaluate        ${bitrate_PI2}/${bitrate_CoDel}
    Should be True      0.90<=${per_bitrate}

    ${per_jitter}       Evaluate    ${jitter_PI2}/${jitter_CoDel}
    Should be True      ${per_jitter}<=1.5
