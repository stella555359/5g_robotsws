*** Settings ***
Documentation    Author: xuemin.ma@nokia-sbell.com
...       throughput check with 1116_3ms_8ssb when enable feature(CA+DLMU+ULMU+8247+1086+12269......)

Test Timeout      90 minutes
Suite Setup       SG13 Common Suite Setup
#Suite Teardown    SG13 Common Suite Teardown
Test Setup        SG13 Common Test Setup
Test Teardown     SG13 Common Test Teardown
Force Tags        qualcomm    owner_xueminm
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG13/robot/common_resource/common_resource.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG13/robot/internal_resource/internal_resource.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py    WITH NAME    nrdim_get_tput
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
#Resource          /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001655/Resources/1347_common_keyword.robot

*** Variables ***
${CONFIG_DIR_PATH}            /home/ute/case/config/
${scfc_configuration}         ${CURDIR}/config/SCFC_BTS1302_ASIB_ABIO_AQQL_2cell.xml
${ATT_FILE_PATH}              att01
${PHASE_FILE_PATH}            phase01
${ATT_FILE_PATH_CA}           att02
${PHASE_FILE_PATH_CA}         phase02
${ATT_FILE_PATH_CA_MU}           att03
${PHASE_FILE_PATH_CA_MU}         phase03
${iperf.port}              5001
${cellDepType}                             text|SA+NSA|//*[@name\="cellDepType"]
${chBw}                                    text|60MHz|//*[@name\="chBw"]
${dlMimoMode}                              text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
${ulMimoMode}                              text|Closed loop Spatial Multiplexing (2x2)|//*[@name\="ulMimoMode"]
${nrCellType}                              text|8DL8UL|//*[@name\="nrCellType"]
${actDl256Qam}                             text|true|//*[@name\="actDl256Qam"]
${actUl256Qam}                             text|true|//*[@name\="actUl256Qam"]
${frameStructureType}                      text|tdLte|//*[@name\="frameStructureType"]
${guardPeriodLength}                       text|6Symbols|//*[@name\="guardPeriodLength"]
${lteToNrFrameShift}                       text|3ms|//*[@name\="lteToNrFrameShift"]
${tdLteUlDlConfig}                         text|tdLteConfig2|//*[@name\="tdLteUlDlConfig"]
${ulDlDataSlotRatio}                       text|1/4|//*[@name\="ulDlDataSlotRatio"]
${prachConfigurationIndex}                 text|98|//*[@name\="prachConfigurationIndex"]
${numberOfTransmittedSsBlocks}             text|6 beams|//*[@name\="numberOfTransmittedSsBlocks"]
${actBeamforming}                          text|true|//*[@name\="actBeamforming"]
${actDlSrsBm}                              text|true|//*[@name\="actDlSrsBm"]
${actUlSrsBm}                              text|true|//*[@name\="actUlSrsBm"]
${actDlSrsSubbandBm}                       text|false|//*[@name\="actDlSrsSubbandBm"]
${actUlMuMimo}                             text|true|//*[@name\="actUlMuMimo"]
${actDlMuMimoEnh}                          text|true|//*[@name\="actDlMuMimoEnh"]
#${carrierAggregationSupportList}           text|ca_Fr1Tdd_Sa|//*[@name\="carrierAggregationSupportList"]
${actTddCsiRsOpt}                          text|true|//*[@name\="actTddCsiRsOpt"]
${actSubTRSRateMatch}                      text|true|//*[@name\="actSubTRSRateMatch"]
${actTddCsiImRm}                           text|true|//*[@name\="actTddCsiImRm"]
${actCDrx}                                 text|true|//*[@name\="actCDrx"]
${actUlClosedLoopPwrCtrl}                  text|puschSrs|//*[@name\="actUlClosedLoopPwrCtrl"]
${miNrSrsQuality}                          text|15min|//*[@name\="miNrSrsQuality"]
${miNrBeamforming2}                        text|15min|//*[@name\="miNrBeamforming2"]
${miNrDlHarq}                              text|15min|//*[@name\="miNrDlHarq"]
${miNrUlHarq}                              text|15min|//*[@name\="miNrUlHarq"]
${miNrDlHarqLowSEMCS}                      text|15min|//*[@name\="miNrDlHarqLowSEMCS"]
${miNrUlHarqLowSEMCS}                      text|15min|//*[@name\="miNrUlHarqLowSEMCS"]
${miNrUlHarqOne}                           text|15min|//*[@name\="miNrUlHarqOne"]

${cellid}      9201

*** Test Cases ***
throughput check with 1116_3ms_6ssb when enable feature
    Step1:Commission the above configuration on WebUI
    Step2:UEs attach and start DL UL fullbufer data transmission
    Step3:Detach UEs and unblock cell2

*** Keywords ***
Step1:Commission the above configuration on WebUI
    Start Collecting GNB Syslog in 'Step1_before_onair' File
    Set Suite Variable    ${CONFIG_FILE}    /home/ute/testline_configuration/${TL_NAME}/mcs_config.yml
    modify_swconfig_by_CB008322
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
	copy_file       ${scfc_configuration}    ${scfc_path}
    ${modify_list}    create list
    ...    ${cellDepType}    ${chBw}    ${dlMimoMode}    ${ulMimoMode}    ${nrCellType}
    ...    ${actDl256Qam}    ${actUl256Qam}    ${frameStructureType}    ${guardPeriodLength}    ${lteToNrFrameShift}
    ...    ${tdLteUlDlConfig}    ${ulDlDataSlotRatio}    ${prachConfigurationIndex}    ${numberOfTransmittedSsBlocks}
    ...    ${actBeamforming}    ${actDlSrsBm}    ${actUlSrsBm}    ${actDlSrsSubbandBm}    ${actUlMuMimo}    ${actDlMuMimoEnh}
    ...    ${actTddCsiRsOpt}    ${actSubTRSRateMatch}    ${actTddCsiImRm}
    ...    ${actCDrx}    ${actUlClosedLoopPwrCtrl}    ${miNrSrsQuality}    ${miNrBeamforming2}    ${miNrDlHarq}    ${miNrUlHarq}
    ...    ${miNrDlHarqLowSEMCS}    ${miNrUlHarqLowSEMCS}    ${miNrUlHarqOne}
    modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
    Perform Full Commission     ${scfc_path}
    Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair
    ${dl_peak_tput}   Get theoretical throughput from nrdim    SCF_Path=${scfc_path}
    set suite variable    ${dl_peak_tput}
    Log To Console   \n-------------Theoretical thp is ${dl_peak_tput}---------------
    ${parent_dir}=    Join Path    ${CURDIR}    ..
    set suite variable    ${parent_dir}
    [Teardown]    Stop Collecting GNB Syslog in 'Step1_before_onair' File

modify_swconfig_by_CB008322
    ${cur_relative_dir}    set variable    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/Non_Feature_SG13/TestCases
    ${sw_relative_dir}    set variable    commissionings/HGZ
    ${swconfig_base_path}    String.Replace String    ${CURDIR}    ${cur_relative_dir}    ${sw_relative_dir}
    Log To Console    ${swconfig_base_path}
    setup_txt    src_file=${swconfig_base_path}/${TL_NAME}/swconfig.txt    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    add_txt_node    0x9D0000:3             #as PM counter period update to 15/3=5min
    teardown_txt
    GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt

Step2:UEs attach and start DL UL fullbufer data transmission
    Start Collecting GNB Syslog in 'Step2' File
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2
    #set suite variable    ${parent_dir}     /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/Non_Feature_SG13/
    set ue pos    ${ATT_FILE_PATH_CA_MU}    ${PHASE_FILE_PATH_CA_MU}
    Set suite Variable    ${ue_num}    ${2}
    Multi UE Attach And Send Traffic    num=${ue_num}
    Wait '300s' for stabible
    run keyword and continue on failure    check Multi UE thp
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
    Wait Throughput Timer    ${remaining_time}
    ${counter_file}    download_latest_pmcounter    local_path=${save_log}${/}
    ${MAX_PSCELL_UE_1_ACT_SCELL_DL_cell1}=    get_counter_value_from_counter_file    counter_file=${counter_file}
    ...    counter_id=M55316C05001     cell_id=1
    ${MAX_PSCELL_UE_1_ACT_SCELL_DL_cell2}=    get_counter_value_from_counter_file    counter_file=${counter_file}
    ...    counter_id=M55316C05001     cell_id=2
    ${DL_thp_counter}=      get_counter_value_from_counter_file    counter_file=${counter_file}    counter_id=M55309C12001    cell_id=1
    ${DL_throughput_cell1}    evaluate    ${DL_thp_counter}*8/1024/1024
    ${DL_thp_counter}=      get_counter_value_from_counter_file    counter_file=${counter_file}    counter_id=M55309C12001    cell_id=2
    ${DL_throughput_cell2}    evaluate    ${DL_thp_counter}*8/1024/1024
    ${nopair_ue_prb_dl}=    get_counter_value_from_counter_file    counter_file=${counter_file}    counter_id=M55308C34012    cell_id=1
    ${2pair_ue_prb_dl}=     get_counter_value_from_counter_file    counter_file=${counter_file}    counter_id=M55308C34013    cell_id=1
    ${DL_SUCC_counter}=    get_counter_value_from_counter_file    counter_file=${counter_file}
    ...   counter_id=M55308C34030    cell_id=1
    ${FAIL_BWP_counter}=    get_counter_value_from_counter_file    counter_file=${counter_file}
    ...   counter_id=M55308C34031    cell_id=1
    ${FAIL_TRAF_TYPE_counter}=    get_counter_value_from_counter_file    counter_file=${counter_file}
    ...   counter_id=M55308C34032    cell_id=1
    ${FAIL_SRS_BEAM_counter}=     get_counter_value_from_counter_file    counter_file=${counter_file}
    ...   counter_id=M55308C34033    cell_id=1
    ${FAIL_LOW_CQI_counter}=      get_counter_value_from_counter_file    counter_file=${counter_file}
    ...   counter_id=M55308C34034    cell_id=1
    ${FAIL_LOW_PRB_counter}=      get_counter_value_from_counter_file    counter_file=${counter_file}
    ...   counter_id=M55308C34035    cell_id=1
    ${FAIL_HIGH_CORR_counter}=    get_counter_value_from_counter_file    counter_file=${counter_file}
    ...   counter_id=M55308C34036    cell_id=1
    ${FAIL_SE_counter}=           get_counter_value_from_counter_file    counter_file=${counter_file}
    ...   counter_id=M55308C34037    cell_id=1
    ${FAIL_OTHER_counter}=        get_counter_value_from_counter_file    counter_file=${counter_file}
    ...   counter_id=M55308C34038    cell_id=1
    Start GNB Ttitrace With Streaming Mode
    Wait '5s' for stabible
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti_mu_ca
    should be true    ${DL_throughput_cell1} > 1400
    should be true    ${DL_throughput_cell2} > 1400
    [Teardown]    Stop Collecting GNB Syslog in 'Step2' File

Step3:Detach UEs and unblock cell2
    Start Collecting GNB Syslog in 'Step4' File
    #Unlock Cell2
    Multi UE Detach And Stop Traffic
    [Teardown]    Stop Collecting GNB Syslog in 'Step4' File

set ue pos
    [Arguments]    ${ATT}    ${PHASE}
    Run    cp ${parent_dir}/TestData/${ATT} ${TEST_LOG_DIRECTORY()}/att.csv
    Run    cp ${parent_dir}/TestData/${PHASE} ${TEST_LOG_DIRECTORY()}/phase.csv
    Set Mcs3 Phase And Attenuation by CSV    ${TEST_LOG_DIRECTORY()}/att.csv    ${TEST_LOG_DIRECTORY()}/phase.csv
    ...    frequency=3500_1_ALL

start l3 call
    [Arguments]    ${ue_index}=${1}
    ${ue_type}    translate power ue type from testline    ${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${UE_TYPE}    log_type=Aasyslog
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=False

start send data
    [Arguments]    ${ue_index}=${0}    ${dl_tp}=800M    ${ul_tp}=200M    ${duration}=3600    ${iperf_port}=default
    Log To Console    \n ###UE Start traffic and check TP ###
    ${UE_TYPE}    translate power ue type from testline    ${ue_index}
    power_ue.Start traffic   ue_index=${ue_index}    ue_type=${UE_TYPE}   direction=dl   throughput=${dl_tp}    
    ...    duration=${duration}    iperf_port=${iperf_port}
#    power_ue.Start traffic   ue_index=${ue_index}    ue_type=${UE_TYPE}   direction=ul   throughput=${ul_tp}    duration=${duration}

Detach UE
    [Arguments]    ${ue_index}=${1}
	${ue_type}    translate power ue type from testline    ${ue_index}
    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}

capture wiresharklog with new way
    [Arguments]    ${wiresharklog}    ${UE_mode}=${SA_attach_mode}    ${nettpye}=0     ${options}=-i any sctp -s 0
    Start Capture CP-IF logs from Container     tcpdump_collector_name=${wiresharklog}    options=${options}
    Wait Throughput Timer    3
#    MultiUE one Attach with client    UE_mode=${UE_mode}    nettype=${nettpye}
    [Teardown]       Stop CP-IF log Collection    tcpdump_collector_name=${wiresharklog}    target_dir=${epc_log_path}
    [Return]     ${cpif_log_path}

Capture Biplog with new way
    [Arguments]     ${dlexpect_tp}=${Expect_dl_enable}    ${bbmod_slots}=1    ${aa_sys_addr}=${aa_sys_addr}
    ...             ${dl_throughput}=${dl_tput_multiue}
    log to console    start to cpature biplog
    ${bip}=    Capture biplog and download    bbmod_slots=${bbmod_slots}
    [Return]     ${bip}

Stop traffic
    [Arguments]    ${ue_index}=${1}
    log to console      Stop traffic
    ${ue_type}    translate power ue type from testline    ${ue_index}
    #power_ue.Stop traffic    direction=ul    ue_index=${ue_index}    ue_type=${ue_type}
    power_ue.Stop traffic    direction=dl    ue_index=${ue_index}    ue_type=${ue_type}

Get theoretical throughput from nrdim
    [Arguments]    ${SCF_Path}
    ${dl_expect_pcell}    nrdim_get_tput.Get Theoretical Throughput
    ...    scf_path=${SCF_Path}    cell_id=1
    [Return]    ${dl_expect_pcell}[0]

check the thp
    [Arguments]    ${ue_no}
    ${tput_log}    power_ue.Collect Tput    ue_type=${UE_TYPE}    duration=5m
    ${cellsid}    create list    ${cellid}
#    power_ue.Check Tput     ue_type=${UE_TYPE}     direction=ul     cells=1    log=${tput_log}
#    ...                     target_throughput=${Expected_Throughput_UL}
    power_ue.Check Tput     ue_type=${UE_TYPE}     direction=dl     cells=${cellsid}    log=${tput_log}    target_throughput=${dl_peak_tput}
    ...    target_avg_percent=0.90    min_percent=0.8    ue_index=${ue_no}

check Multi UE thp
    ${tput_log}    power_ue.Collect Tput    ue_type=${UE_TYPE}    duration=5m
    FOR    ${ue_no}    IN RANGE    ${ue_num}
        ${cellid}    evaluate    ${cellid}+${ue_no}
        ${cellsid}    create list    ${cellid}
        #power_ue.Check Tput     ue_type=${UE_TYPE}     direction=ul     cells=1    log=${tput_log}
        #...                     target_throughput=${Expected_Throughput_UL}
        power_ue.Check Tput     ue_type=${UE_TYPE}     direction=dl     cells=${cellsid}    log=${tput_log}    target_throughput=${dl_peak_tput}
        ...    target_avg_percent=0.90    min_percent=0.8
    END

Block Cell2
    COAM.Connect To    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
    COAM.perform_parameter_recommissioning    dist_name=MRBTS-575/NRBTS-575/NRCELL-2    parameter=administrativeState
    ...    operation=update    value=Locked    skip_parameter_relation_errors=True    should_activate=True    connection=online
    #Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
    COAM.teardown admin    connection=online

Unlock Cell2
    COAM.Connect To    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
    COAM.perform_parameter_recommissioning    dist_name=MRBTS-575/NRBTS-575/NRCELL-2    parameter=administrativeState
    ...    operation=update    value=Unlocked    skip_parameter_relation_errors=True    should_activate=True    connection=online
    Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
    COAM.teardown admin    connection=online

Test other case kw
    Set Test Variable    ${ue_num}    ${2}
    Multi UE Attach And Send Traffic    num=${ue_num}
    Multi UE Detach And Stop Traffic
    Multi UE Attach And Send Traffic    num=${ue_num}

Multi UE Attach And Send Traffic
    [Arguments]    ${traffic_ul}=200MKbits/sec    ${traffic_dl}=600MKbits/sec    ${duration}=3600    ${num}=1    ${apn_address}=wap1nokiacom
    FOR    ${ue_no}    IN RANGE    ${num}
        Common UE Attach    ue_index=${ue_no}    power_reset=true
        sleep    3s
#        Run Keyword And Continue On Failure    Common UE Send UL Traffic    ue_index=${ue_no}    send_traffic=${traffic_ul}
#        ...    send_duration=${duration}
#        Run Keyword And Continue On Failure    Common UE Send DL Traffic    ue_index=${ue_no}    send_traffic=${traffic_dl}
#        ...    send_duration=${duration}
       ${ue_type}    Get UE type    ue_index=${ue_no}
       run keyword and ignore error    Get Commercial UE IP     ue_index=${ue_no}
       power_ue.Start traffic    ue_type=${ue_type}    direction=dl    ue_mode=SA    throughput=${traffic_dl}    duration=${duration}
       ...    ue_index=${ue_no}    apn_address=${apn_address}    iperf_port=${iperf.port}+${ue_no}+2
       power_ue.Start traffic    ue_type=${ue_type}    direction=dl    ue_mode=SA    throughput=${traffic_dl}    duration=${duration}
       ...    ue_index=${ue_no}    apn_address=${apn_address}    iperf_port=${iperf.port}+${ue_no}+3
       power_ue.Start traffic    ue_type=${ue_type}    direction=dl    ue_mode=SA    throughput=${traffic_dl}    duration=${duration}
       ...    ue_index=${ue_no}    apn_address=${apn_address}    iperf_port=${iperf.port}+${ue_no}+4
    END

Multi UE Detach And Stop Traffic
    FOR    ${ue_no}    IN RANGE    ${ue_num}
        Run Keyword And Continue On Failure    Common Stop traffic    direction=dl    ue_index=${ue_no}
#        Run Keyword And Continue On Failure    Common Stop traffic    direction=ul    ue_index=${ue_no}
        Run Keyword And Continue On Failure    Common UE Detach    ue_index=${ue_no}    power_reset=true
    END

Common UE Attach
    [Arguments]    ${ue_index}=${0}    ${attach_mode}=5G_SA    ${power_reset}=False
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    power_reset=${power_reset}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    power_reset=${power_reset}    attach_mode=${attach_mode}
    Run keyword and ignore error    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False

Common UE Send UL Traffic
    [Arguments]    ${ue_index}=${0}    ${send_traffic}=10MKbits/sec    ${send_duration}=300    ${ue_mode}=SA    ${apn_address}=wap1nokiacom
    ${ue_type}    Get UE type    ue_index=${ue_index}
    run keyword and ignore error    Get Commercial UE IP     ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}    ue_mode=${ue_mode}
    ...    throughput=${send_traffic}    duration=${send_duration}    connection_type=current    apn_address=${apn_address}

Common UE Send DL Traffic
    [Arguments]    ${ue_index}=${0}    ${send_traffic}=50MKbits/sec    ${send_duration}=300    ${ue_mode}=SA    ${apn_address}=wap1nokiacom
    ${ue_type}    Get UE type    ue_index=${ue_index}
    run keyword and ignore error    Get Commercial UE IP     ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    ue_mode=${ue_mode}    throughput=${send_traffic}    duration=${send_duration}
    ...    ue_index=${ue_index}    apn_address=${apn_address}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    ue_mode=${ue_mode}    throughput=${send_traffic}    duration=${send_duration}
    ...    ue_index=${ue_index}    apn_address=${apn_address}    iperf_port=${tl.appserver.iperf_details.port}

Common Stop traffic
    [Arguments]    ${direction}    ${ue_index}=${0}    ${ue_mode}=SA
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=${direction}    ue_index=${ue_index}    ue_mode=${ue_mode}

Common UE Detach
    [Arguments]    ${ue_index}=${0}    ${power_reset}=False
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}    power_reset=${power_reset}
