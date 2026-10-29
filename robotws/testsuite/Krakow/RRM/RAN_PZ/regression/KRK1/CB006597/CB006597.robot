*** Settings ***
Documentation
...   Test suite for regression testing of feature CB006597
...   author: Radoslaw Serafin, Julia Luszcz
...   contact: radoslaw.serafin@nokia.com, julia.luszcz@nokia.com

Library     ute_ue
Library     taf.collectors.tcpdump                WITH NAME   tcpdump
Library     taf.rfrl.ue.logs.qxdm_logs.LicenseKeeperKeywords  WITH NAME  LicenseKeeperKeywords
Library     taf.rfrl.ue.logs.qxdm_logs.QxdmLogsCollector      WITH NAME  QxdmLogsCollector
Library     taf.rfrl.bts.devices.du.logs_collecting.basic_logs.GnbLog     WITH NAME   gnb_log
Library     taf.rfrl.bts.devices.du.logs_collecting.btslog_collector.GnbBtslogCollector     WITH NAME   GnbBtslogCollector
Library     taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter     WITH NAME   GnbPmCounter
Library     testsuite/Krakow/resources/qxdm_collection.py
Library     ./resources/pcap_parser.py
Library     ./resources/resources_CB006597.py

Resource    taf/rfrl/ue/robot/REAL_UE.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    taf/rfrl/bts/robot/gnb.robot
Resource    resources/resources_CB006597.robot

Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py


Force Tags    STATE_SW_UPLOADED    RAN_5G    CRT
...  SBTS22R4__WITH__CLOUD_5G_CLASSICAL_MULTIGNB_SA_2xANDROID_ASILR_ABIOB4_AHEB
...  SBTS00__WITH__CLOUD_5G_CLASSICAL_MULTIGNB_SA_2xANDROID_ASILL_ABIOB1_AHEB


Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
Suite Teardown    Common Suite Teardown

*** Variables ***
${alias}                UE
${lkc_path}             /cygdrive/c/Users/user-lab0/Desktop/QPM_LK1.5.1
${lkc_login}            ${None}
${lkc_password}         ${None}

${file}=                CB006597.pcap
${interface}=           br0

${ngap_value}=          unspecified (0)
${capabilities}=        SDx65

${expect_error}         KeyError: 'nonCriticalExtension'

${path_M55124C08501}    CELLS/NRCELL-1/NRRCC/ACC_UAI_RRC_REL_PREF_CONF_UES
${path_M55124C08505}    CELLS/NRCELL-1/NRRCC/UAI_PREF_OUTCONN_REP

@{ports_gnb1}           9   10
@{ports_gnb2}           11   12

*** Test Cases ***
[1][1.0] USCB006597-A#B1 Activation of UE Assistance Information to report preference on the RRC state
    [Setup]    Run Keywords         Common Preconditions
    ...                             AND
    ...                             Prepare UE              ${alias}
    ...                                                     capabilities=${capabilities}
    Set Test Variable               ${counter_id}    M55124C08501
    gnb_counter.Wait for next PM period                     interval=5
    ${counter_value_before}   GnbPmCounter.Get pm counter info via gui
    ...                                                     counter_id=${counter_id}
    Should Be Equal As Numbers      ${counter_value_before}    0
    Start QXDM collection           collection_time=30
    Sleep                           7s
    ute_ue.Attach Ue                ${alias}
    Sleep                           3s
    ute_ue.Detach UE                ue_alias=${alias}
    gnb_counter.Wait for next PM period                     interval=5
    ${counter_value_after}  GnbPmCounter.Get pm counter info via gui
    ...                                                     counter_id=${counter_id}
    Check if counter in range       counter=${counter_value_after}
    ...                             counter_min=${1}
    ...                             counter_max=${12}
    Download QXDM log               log_dir=${LOG_PATH}
    Validate releasePreference in qxdm log                  file_path=${LOG_PATH}/qxdm.txt
    Validate releasePreferenceProhibitTimer in qxdm log     file_path=${LOG_PATH}/qxdm.txt
    [Teardown]  Common Postconditions With Restore Configuration If Test Failed

[1]USCB006597-A#B5 gNB releases the RRC connection of UE when UE reports an RRC preferred state of outOfConnected
    [Setup]    Run Keywords         Common Preconditions
    ...                             AND
    ...                             Prepare UE              ${alias}
    ...                                                     capabilities=${capabilities}
    Set Test Variable               ${counter_id}    M55124C08505
    gnb_counter.Wait for next PM period                     interval=5
    ${counter_value_before}   GnbPmCounter.Get pm counter info via gui
    ...                                                     counter_id=${counter_id}
    Should Be Equal As Numbers      ${counter_value_before}    0
    Start QXDM collection           collection_time=50
    gnb_log.start_tcpdump_on_smod   interface=${interface}
    ...                             capture_file=${file}
    ...                             background=${True}
    GnbBtslogCollector.start_collecting_btslog
    ute_ue.Attach Ue                ${alias}
    Sleep                           30s
    log to console                  ${LOG_PATH}
    gnb_counter.Wait for next PM period                     interval=5
    ${counter_value_after}    GnbPmCounter.Get pm counter info via gui
    ...                                                     counter_id=${counter_id}
    Should Be Equal As Numbers      ${counter_value_after}    1
    Download QXDM log               log_dir=${LOG_PATH}
    gnb_log.stop_tcpdump_on_smod
    ${directory}=   gnb_log.download_tcpdump_from_bts       interface=FCT
    ...                                                     log_file_name=${file}
    GnbBtslogCollector.stop_collecting_btslog               log_dir=${directory}
    Validate OutOfConnected in qxdm log                     file_path=${LOG_PATH}/qxdm.txt
    Check ngap messages in pcap     directory=${directory}
    Check CB006597 syslog messages                          directory=${directory}
    [Teardown]  Common Postconditions With Restore Configuration If Test Failed

[1]USCB006597-A#B6 Online Change of setting of feature flag for UE Assistance Information to report preference on the RRC state
    [Setup]    Run Keywords         Common Preconditions
    ...                             AND
    ...                             Ping gnb from ue        ue_id=0
    ...                                                     timeout=${300}
    ...                                                     background=${True}
    ...                             AND
    ...                             Prepare UE              ${alias}
    ...                                                     capabilities=${capabilities}
    Start QXDM collection           collection_time=130
    Sleep                           7s
    ute_ue.Attach Ue                ${alias}
    Decommission feature CB006597
    Sleep                           30s
    Download QXDM log               log_dir=${LOG_PATH}
    Validate releasePreference in qxdm log                  file_path=${LOG_PATH}/qxdm.txt
    ${ooc_time}=    Validate OutOfConnected in qxdm log     file_path=${LOG_PATH}/qxdm.txt
    Check if RRCReconfiguration in log after target time    file_path=${LOG_PATH}/qxdm.txt
    ...                                                     target_time=${ooc_time}
    Start QXDM collection           collection_time=40
    Sleep                           7s
    ute_ue.Detach Ue                ${alias}
    Sleep                           3s
    ute_ue.Attach Ue                ${alias}
    Download QXDM log               log_dir=${LOG_PATH}
    Run Keyword And Expect Error    ${expect_error}     Validate releasePreferenceProhibitTimer in qxdm log
    ...                                                     file_path=${LOG_PATH}/qxdm.txt
    Start QXDM collection           collection_time=60
    Sleep                           4s
    ute_ue.Detach Ue                ${alias}
    Commission feature CB006597
    ute_ue.Attach Ue                ${alias}
    Download QXDM log               log_dir=${LOG_PATH}
    Validate releasePreferenceProhibitTimer in qxdm log     file_path=${LOG_PATH}/qxdm.txt
    [Teardown]  Run Keywords        Commission feature CB006597
    ...         AND
    ...         Common Postconditions With Restore Configuration If Test Failed

[1]USCB006597-A#B8 Handover to enabled-disable reporting UE Assistance Information for releasePreference inter gNB
    [Setup]    Run Keywords         Common Preconditions
    ...                             AND
    ...                             Ping gnb from ue        ue_id=0
    ...                                                     timeout=${300}
    ...                                                     background=${True}
    ...                             AND
    ...                             Prepare UE              ${alias}
    ...                                                     capabilities=${capabilities}
    gnb_log.start_tcpdump_on_smod   interface=${interface}
    ...                             capture_file=${file}
    ...                             background=${True}
    Start QXDM collection           collection_time=150
    Sleep                           7s
    ute_ue.Attach Ue                ${alias}
    Attenuate DU                    attenuate_ports=${ports_gnb1}
    ...                             restore_ports=${ports_gnb2}
    gnb_log.stop_tcpdump_on_smod
    Download QXDM log               log_dir=${LOG_PATH}
    ${directory}=   gnb_log.download_tcpdump_from_bts       interface=FCT
    ...                                                     log_file_name=${file}
    Check HO messages               directory=${directory}
    Verify releasePreference after handover                 file_path=${LOG_PATH}/qxdm.txt
    Verify ueAssistanceInformation not in log               file_path=${LOG_PATH}/qxdm.txt
    Ping gnb from ue                ue_id=0
    ...                             timeout=${300}
    ...                             background=${True}
    gnb_log.start_tcpdump_on_smod   interface=${interface}
    ...                             capture_file=${file}
    ...                             background=${True}
    Start QXDM collection           collection_time=150
    Sleep                           5s
    ute_ue.Attach Ue                ${alias}
    Attenuate DU                    attenuate_ports=${ports_gnb2}
    ...                             restore_ports=${ports_gnb1}
    gnb_log.stop_tcpdump_on_smod
    Download QXDM log               log_dir=${LOG_PATH}
    ${directory}=   gnb_log.download_tcpdump_from_bts       interface=FCT
    ...                                                     log_file_name=${file}
    Check HO messages               directory=${directory}
    Validate releasePreference in qxdm log                  file_path=${LOG_PATH}/qxdm.txt
    Validate releasePreferenceProhibitTimer in qxdm log     file_path=${LOG_PATH}/qxdm.txt
    [Teardown]  Run Keywords    Restore attenuation
    ...     AND
    ...     Common Postconditions With Restore Configuration If Test Failed
