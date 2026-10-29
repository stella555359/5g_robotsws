*** Settings ***
Documentation    CB009363 TA cases common steps
...              Author: Stella.lin@nokia-sbell.com

Resource    CB009363_common.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/counter_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/For_feature/Keywords_for_9915_10249.robot

*** Variables ***
${MRBTS_ID}    ${tl.gnbs[0].instance_id}
${NRBTS_ID}    ${tl.gnbs[0].global_bts_id}
@{SWCONFIG_9363_B}    0x600018=0    0x5901E5=1    0x59012C=0
@{SWCONFIG_9363_D}    0x600018=0    0x59012C=0
@{SWCONFIG_9363_E}    0x80006D=1
@{scf_update_params_9363_B}    add:NRCELL-1:numberOfRxPucch=8Rx
...                          modify:NRCELL-1:actDlSrsBm=false
...                          modify:NRCELL-1:actUlSrsBm=false
...                          modify:NRCELL-1:actAperCsi=false
...                          modify:NRBTS-${NRBTS_ID}:actBbPoolTddFr1=true
...                          modify:NRBTS-${NRBTS_ID}:actBbPoolTddFr1Enh=false
...                          modify:NRBTS-${NRBTS_ID}:actBbPoolExtensionTddFr1=true
...                          modify:NRBTS-${NRBTS_ID}:actConnRrcPooling=false
...                          modify:NRBTS-${NRBTS_ID}:actScheUePooling=false
...                          modify:NRBTS-${NRBTS_ID}:allowSlowPrbPoolingStatNdmSrs=false
...                          modify:NRBTS-${NRBTS_ID}:actSlowPrbPooling=false
...                          modify:NRBTS-${NRBTS_ID}:actSlowPrbPoolingFddFr1Enh=false
...                          modify:NRBTS-${NRBTS_ID}:actSpatialStreamPooling=false
...                          modify:NRBTS-${NRBTS_ID}:actTddPrePooling=false
...                          modify:NRCELL-1:actLongPucchPhase2=false
...                          modify:NRCELL-1:actUlClosedLoopPwrCtrl=disabled
@{scf_update_params_9363_8}    add:NRCELL-1:numberOfRxPucch=8Rx
...                            add:NRCELL-2:numberOfRxPucch=8Rx
...                            add:NRCELL-3:numberOfRxPucch=8Rx
...                            modify:NRCELL-1:actDlSrsBm=true
...                            modify:NRCELL-1:actUlSrsBm=true
...                            modify:NRCELL-1:actAperCsi=false
...                            modify:NRCELL-2:actDlSrsBm=true
...                            modify:NRCELL-2:actUlSrsBm=true
...                            modify:NRCELL-2:actAperCsi=false
...                            modify:NRCELL-3:actDlSrsBm=true
...                            modify:NRCELL-3:actUlSrsBm=true
...                            modify:NRCELL-3:actAperCsi=false
...                            modify:NRBTS-${NRBTS_ID}:actBbPoolTddFr1=true
...                            modify:NRBTS-${NRBTS_ID}:actBbPoolTddFr1Enh=true
...                            modify:NRBTS-${NRBTS_ID}:actBbPoolExtensionTddFr1=true
...                            modify:NRBTS-${NRBTS_ID}:actConnRrcPooling=false
...                            modify:NRBTS-${NRBTS_ID}:actScheUePooling=false
...                            modify:NRBTS-${NRBTS_ID}:allowSlowPrbPoolingStatNdmSrs=false
...                            modify:NRBTS-${NRBTS_ID}:actSlowPrbPooling=false
...                            modify:NRBTS-${NRBTS_ID}:actSlowPrbPoolingFddFr1Enh=false
...                            modify:NRBTS-${NRBTS_ID}:actSpatialStreamPooling=false
...                            modify:NRBTS-${NRBTS_ID}:actTddPrePooling=false
...                            modify:NRCELL-1:actUlClosedLoopPwrCtrl=pucchPuschSrs
...                            modify:NRCELL-2:actUlClosedLoopPwrCtrl=pucchPuschSrs
...                            modify:NRCELL-3:actUlClosedLoopPwrCtrl=pucchPuschSrs
...                            modify:NRCELL-1:beamSet:basicBeamSet=beamSet_8
...                            modify:NRCELL-2:beamSet:basicBeamSet=beamSet_8
...                            modify:NRCELL-3:beamSet:basicBeamSet=beamSet_8
...                            modify:NRCELLGRP-0:numberOfTransmittedSsBlocks=8 beams
...                            modify:NRCELLGRP-1:numberOfTransmittedSsBlocks=8 beams
...                            modify:NRCELLGRP-2:numberOfTransmittedSsBlocks=8 beams
...                            modify:NRCELL-1:actLongPucchPhase2=true
...                            modify:NRCELL-2:actLongPucchPhase2=true
...                            modify:NRCELL-3:actLongPucchPhase2=true
@{scf_update_params_9363_6}    add:NRCELL-1:numberOfRxPucch=8Rx
...                            add:NRCELL-2:numberOfRxPucch=8Rx
...                            add:NRCELL-3:numberOfRxPucch=8Rx
...                            modify:NRCELL-1:actDlSrsBm=true
...                            modify:NRCELL-1:actUlSrsBm=true
...                            modify:NRCELL-1:actAperCsi=false
...                            modify:NRCELL-2:actDlSrsBm=true
...                            modify:NRCELL-2:actUlSrsBm=true
...                            modify:NRCELL-2:actAperCsi=false
...                            modify:NRCELL-3:actDlSrsBm=true
...                            modify:NRCELL-3:actUlSrsBm=true
...                            modify:NRCELL-3:actAperCsi=false
...                            modify:NRBTS-${NRBTS_ID}:actBbPoolTddFr1=true
...                            modify:NRBTS-${NRBTS_ID}:actBbPoolTddFr1Enh=true
...                            modify:NRBTS-${NRBTS_ID}:actBbPoolExtensionTddFr1=true
...                            modify:NRBTS-${NRBTS_ID}:actConnRrcPooling=false
...                            modify:NRBTS-${NRBTS_ID}:actScheUePooling=false
...                            modify:NRBTS-${NRBTS_ID}:allowSlowPrbPoolingStatNdmSrs=false
...                            modify:NRBTS-${NRBTS_ID}:actSlowPrbPooling=false
...                            modify:NRBTS-${NRBTS_ID}:actSlowPrbPoolingFddFr1Enh=false
...                            modify:NRBTS-${NRBTS_ID}:actSpatialStreamPooling=false
...                            modify:NRBTS-${NRBTS_ID}:actTddPrePooling=false
...                            modify:NRCELL-1:actUlClosedLoopPwrCtrl=pucchPuschSrs
...                            modify:NRCELL-2:actUlClosedLoopPwrCtrl=pucchPuschSrs
...                            modify:NRCELL-3:actUlClosedLoopPwrCtrl=pucchPuschSrs
...                            modify:NRCELL-1:beamSet:basicBeamSet=beamSet_6
...                            modify:NRCELL-2:beamSet:basicBeamSet=beamSet_6
...                            modify:NRCELL-3:beamSet:basicBeamSet=beamSet_6
...                            modify:NRCELLGRP-0:numberOfTransmittedSsBlocks=6 beams
...                            modify:NRCELLGRP-1:numberOfTransmittedSsBlocks=6 beams
...                            modify:NRCELLGRP-2:numberOfTransmittedSsBlocks=6 beams
...                            modify:NRCELL-1:actLongPucchPhase2=true
...                            modify:NRCELL-2:actLongPucchPhase2=true
...                            modify:NRCELL-3:actLongPucchPhase2=true
@{framestructure_prach_index}    modify:NRCELL-1:prachConfigurationIndex=9
...                              modify:NRCELL-2:prachConfigurationIndex=9
...                              modify:NRCELL-3:prachConfigurationIndex=9
@{framestructure_prach_index_SBTS00}    modify:NRCELL-1:prachConfigurationIndex=9
...                                     modify:NRCELL-2:prachConfigurationIndex=9
...                                     modify:NRCELL-3:prachConfigurationIndex=9
...                                     modify:NRCELL-4:prachConfigurationIndex=9
...                                     modify:NRCELL-5:prachConfigurationIndex=9
...                                     modify:NRCELL-6:prachConfigurationIndex=9
@{scf_update_params_9363_8_SBTS00}    modify:NRCELL-1:beamSet:basicBeamSet=beamSet_8
...                                   modify:NRCELL-2:beamSet:basicBeamSet=beamSet_8
...                                   modify:NRCELL-3:beamSet:basicBeamSet=beamSet_8
...                                   modify:NRCELL-4:beamSet:basicBeamSet=beamSet_8
...                                   modify:NRCELL-5:beamSet:basicBeamSet=beamSet_8
...                                   modify:NRCELL-6:beamSet:basicBeamSet=beamSet_8
...                                   modify:NRCELLGRP-0:numberOfTransmittedSsBlocks=8 beams
...                                   modify:NRCELLGRP-1:numberOfTransmittedSsBlocks=8 beams
...                                   modify:NRCELLGRP-2:numberOfTransmittedSsBlocks=8 beams
...                                   modify:NRCELLGRP-3:numberOfTransmittedSsBlocks=8 beams
...                                   modify:NRCELLGRP-4:numberOfTransmittedSsBlocks=8 beams
...                                   modify:NRCELLGRP-5:numberOfTransmittedSsBlocks=8 beams
...                                   modify:NRCELL-1:actSubTRSRateMatch=false
...                                   modify:NRCELL-2:actSubTRSRateMatch=false
...                                   modify:NRCELL-3:actSubTRSRateMatch=false
...                                   modify:NRCELL-4:actSubTRSRateMatch=false
...                                   modify:NRCELL-5:actSubTRSRateMatch=false
...                                   modify:NRCELL-6:actSubTRSRateMatch=false
...                                   modify:NRCELL-1:prachConfigurationIndex=202
...                                   modify:NRCELL-2:prachConfigurationIndex=202
...                                   modify:NRCELL-3:prachConfigurationIndex=202
...                                   modify:NRCELL-4:prachConfigurationIndex=202
...                                   modify:NRCELL-5:prachConfigurationIndex=202
...                                   modify:NRCELL-6:prachConfigurationIndex=202


@{scf_update_params_1208}    delete:NRCELL-1:fPdcchMonOccsnPo
...                          add:NRCELL-1:fPdcchMonOccsnPo
...                          add:NRCELL-1:fPdcchMonOccsnPo::0
...                          delete:NRCELL-2:fPdcchMonOccsnPo
...                          add:NRCELL-2:fPdcchMonOccsnPo
...                          add:NRCELL-2:fPdcchMonOccsnPo::0
...                          delete:NRCELL-3:fPdcchMonOccsnPo
...                          add:NRCELL-3:fPdcchMonOccsnPo
...                          add:NRCELL-3:fPdcchMonOccsnPo::0
...                          delete:NRCELL-4:fPdcchMonOccsnPo
...                          add:NRCELL-4:fPdcchMonOccsnPo
...                          add:NRCELL-4:fPdcchMonOccsnPo::0
...                          delete:NRCELL-5:fPdcchMonOccsnPo
...                          add:NRCELL-5:fPdcchMonOccsnPo
...                          add:NRCELL-5:fPdcchMonOccsnPo::0
...                          delete:NRCELL-6:fPdcchMonOccsnPo
...                          add:NRCELL-6:fPdcchMonOccsnPo
...                          add:NRCELL-6:fPdcchMonOccsnPo::0
...                          modify:NRCELL-1/NRRIM_PROFILE-1:rsPattern1Period=2.5ms
...                          modify:NRCELL-2/NRRIM_PROFILE-1:rsPattern1Period=2.5ms
...                          modify:NRCELL-3/NRRIM_PROFILE-1:rsPattern1Period=2.5ms
...                          modify:NRCELL-4/NRRIM_PROFILE-1:rsPattern1Period=2.5ms
...                          modify:NRCELL-5/NRRIM_PROFILE-1:rsPattern1Period=2.5ms
...                          modify:NRCELL-6/NRRIM_PROFILE-1:rsPattern1Period=2.5ms
...                          add:NRCELL-1/NRRIM_PROFILE-1:rsPattern2Period=2.5ms
...                          add:NRCELL-2/NRRIM_PROFILE-1:rsPattern2Period=2.5ms
...                          add:NRCELL-3/NRRIM_PROFILE-1:rsPattern2Period=2.5ms
...                          add:NRCELL-4/NRRIM_PROFILE-1:rsPattern2Period=2.5ms
...                          add:NRCELL-5/NRRIM_PROFILE-1:rsPattern2Period=2.5ms
...                          add:NRCELL-6/NRRIM_PROFILE-1:rsPattern2Period=2.5ms
...                          modify:NRBTS-${NRBTS_ID}:actFlexibleBISlotDurationMode=disabled
...                          modify:NRCELL-1:actIncUlPdcchCapacity=false
...                          modify:NRCELL-2:actIncUlPdcchCapacity=false
...                          modify:NRCELL-3:actIncUlPdcchCapacity=false
...                          modify:NRCELL-4:actIncUlPdcchCapacity=false
...                          modify:NRCELL-5:actIncUlPdcchCapacity=false
...                          modify:NRCELL-6:actIncUlPdcchCapacity=false
...                          modify:NRCELL-1:prachConfigurationIndex=202
...                          modify:NRCELL-2:prachConfigurationIndex=202
...                          modify:NRCELL-3:prachConfigurationIndex=202
...                          modify:NRCELL-4:prachConfigurationIndex=202
...                          modify:NRCELL-5:prachConfigurationIndex=202
...                          modify:NRCELL-6:prachConfigurationIndex=202



&{framestructure_1208}    1=1208    2=1208    3=1208
&{framestructure_11160ms}    1=11160ms    2=11160ms    3=11160ms
&{framestructure_11163ms}    1=11163ms    2=11163ms    3=11163ms
&{framestructure_1208_SBTS00}    1=1208    2=1208    3=1208    4=1208    5=1208    6=1208
&{framestructure_11160ms_SBTS00}    1=11160ms    2=11160ms    3=11160ms    4=11160ms    5=11160ms    6=11160ms
&{framestructure_11163ms_SBTS00}    1=11163ms    2=11163ms    3=11163ms    4=11163ms    5=11163ms    6=11163ms
${BSR_Package_Path}    /home/ute/SCF/BSR_AEHC_6_H5H1_ALN60_ARP60_N02_COVERAGE_00384_00002.zip
&{startprb_mapping_table}    0=9    1=21    2=33    3=45    4=57    5=69    6=81    7=93    8=105    9=117
...    10=129    11=141    12=153   13=165    14=177    15=189   16=201    17=213    18=225   19=237

${7_5_UTE5G402T273_HW_TYPE}    GUANGHETONG
${7_5_UTE5G402T272_HW_TYPE}    YIYUAN

*** Keywords ***
CB009363-SR-E_021_checking_the_number_of_PUCCH_when_numberOfRxBeamforming_4RX_and_numberOfRxPucch_8RX
    Run Keyword If   '${STREAM_VERSION}'=='master'    Mcs.Set Phases According To Angles For Two Output Groups
    ...     mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${1}   first_beam_end_output_port=${2}
    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}
    ...    first_beam_horizontal_angle=${-14}    second_beam_horizontal_angle=${-40}    vertical_angle=${-6}
    ...    vertical_distance=${2}    end_input_port=${16}
     Run Keyword If   '25R1' in '${STREAM_VERSION}'    Change 8Rx To 4Rx Via WebUI
    ...    ELSE    Change 8Rx To 4Rx Via WebUI On Trunk
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=1    connection=GNB_OAM    timeout=300
    ${5G_band}    Set Variable    78
#    Run Keyword And Ignore Error    Recover Collect Syslog For Gnb
#    Start To Capture Mix Logs With gNB_logs
#    Sleep    120s
    ${attach_status}    Run Keyword And Return Status    DingLi_Client.UE Attach With Retry    ues_index=${${0}}    5G_band=${5G_band}
#    Stop Capture Mix Logs With gNB_logs
#    Run Keyword And Ignore Error    Get Captured Mixed File
    ${expect_pci}    Set Variable IF    '${STREAM_VERSION}'=='master'    721    732
    Run Keyword If   '${attach_status}'=='${False}'    DingLi_Client.Check PCI In Attach Info
    ...    ues_index=${${0}}    expect_pci=${expect_pci}
    Run Keyword If   '${attach_status}'=='${False}'     FAIL    msg=attach failed.
    DingLi_Client.Start Data Transfer    ues_index=${${0}}
    sleep    30sec
    @{direction_component_list}    Create List    UL    DL
    Run Keyword And Continue On Failure    Check Tput With Power UE    direction_component_list=@{direction_component_list}
    ...                                                                duration=120
    ...                                                                expect_ul_tput=210
    ...                                                                expect_dl_tput=1490
    ...                                                                cellid=1
    ...                                                                target_avg_percent=0.90
    ...                                                                ue_type=huawei_sigspark
    ...                                                                check_source=aasyslog
    ...                                                                min_percent=0
#    Run Keyword And Ignore Error    Capture Mix Logs With gNB_logs
#    Run Keyword And Ignore Error    Get Captured Mixed File
    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog

CB009363-SR-E_013_8Rx_reception_for_PUCCH_F1_F3_1116-0ms_rdRestrictedBeamSetUsed_disabled
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=1    connection=GNB_OAM    timeout=300
    ${5G_band}    Set Variable    78
    ${attach_status}    Run Keyword And Return Status    DingLi_Client.UE Attach With Retry    ues_index=${${0}}    5G_band=${5G_band}
    ${expect_pci}    Set Variable IF    '${STREAM_VERSION}'=='master'    721    732
    Run Keyword If   '${attach_status}'=='${False}'    DingLi_Client.Check PCI In Attach Info
    ...    ues_index=${${0}}    expect_pci=${expect_pci}
    Run Keyword If   '${attach_status}'=='${False}'     FAIL    msg=attach failed.
    #--- low ul traffic --- #
    DingLi_Client.Start Data Transfer    ues_index=${${0}}    whether_start_dl_call=${False}    ul_throughput=20000
    sleep    30sec
    Wait Until Next Counter Update
    Sleep    60sec
    ${dis_name_dir}    set variable    MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}
    ${M55303C14001_full_path}    set variable    ${dis_name_dir}/NRCELL-1/NULSQ/PUCCH_FORMAT1_NON_DTX
    ${M55303C13001_full_path}    set variable    ${dis_name_dir}/NRCELL-1/NULSQ/PUCCH_FORMAT1_DTX
    ${M55303C18001_full_path}    set variable    ${dis_name_dir}/NRCELL-1/NULSQ/PUCCH_FORMAT3_NON_DTX
    ${M55303C17001_full_path}    set variable    ${dis_name_dir}/NRCELL-1/NULSQ/PUCCH_FORMAT3_DTX
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    ${M55303C14001_value}    Get counter latest value    BTS_or_TRS=BTS    counter_id=M55303C14001
    ...                                                  counter_full_path=${M55303C14001_full_path}
    ${M55302C10001_value}    convert to integer     ${M55303C14001_value}
    run keyword and continue on failure    should be true    ${M55302C10001_value}>1
    ${M55303C13001_value}    Get counter latest value    BTS_or_TRS=BTS    counter_id=M55303C13001
    ...                                                  counter_full_path=${M55303C13001_full_path}
    ${M55303C13001_value}    convert to integer     ${M55303C13001_value}
    run keyword and continue on failure    should be true    ${M55303C13001_value}<1
    ${M55303C18001_value}    Get counter latest value    BTS_or_TRS=BTS    counter_id=M55303C18001
    ...                                                  counter_full_path=${M55303C18001_full_path}
    ${M55303C18001_value}    convert to integer     ${M55303C18001_value}
    run keyword and continue on failure    should be true    ${M55303C18001_value}>1
    ${M55303C17001_value}    Get counter latest value    BTS_or_TRS=BTS    counter_id=M55303C17001
    ...                                                  counter_full_path=${M55303C17001_full_path}
    ${M55303C17001_value}    convert to integer     ${M55303C17001_value}
    run keyword and continue on failure    should be true    ${M55303C17001_value}<1
#    Run Keyword And Continue On Failure    Collect Interface Mirroring Bip Collector    nr_phy_cell_ids=${expect_pci}
#    ...                                                                                 target_file_name=bip_log_with_low_ul_traffic
#    Sleep    30sec
#    ${bip_log_with_low_ul_traffic}    Run Keyword And Continue On Failure    Get Bip Log Via Interface Mirroring Collector
#    ...                                                                         target_file_name=bip_log_with_low_ul_traffic
    Run Keyword And Ignore Error    DingLi_Client.Stop UL Data Transfer     ues_index=${${0}}
    Run Keyword And Ignore Error    DingLi_Client.Detach    ues_index=${${0}}
    ${attach_status}    Run Keyword And Return Status    DingLi_Client.UE Attach With Retry    ues_index=${${0}}     5G_band=${5G_band}
    Run Keyword If   '${attach_status}'=='${False}'    DingLi_Client.Check PCI In Attach Info
    ...    ues_index=${${0}}    expect_pci=${expect_pci}
    Run Keyword If   '${attach_status}'=='${False}'     FAIL    msg=attach failed.
    Run Keyword If    '${stream}'=='SBTS00'   Update_Param_For_CB011116
    DingLi_Client.Start Data Transfer    ues_index=${${0}}   whether_start_ul_call=${False}   dl_throughput=1800M
    sleep    30sec
#    Capture Logs With gNB_logs    duration=30    log_type=BIP
#    ${bip_log_with_big_dl_traffic}    Get Captured BIP File
#    ${used_bip_file}    Used BIP File Rename    bip_file_path=${bip_log_with_big_dl_traffic[-1]}
#    Run Keyword And Continue On Failure    Collect Interface Mirroring Bip Collector    nr_phy_cell_ids=${expect_pci}
#    ...                                                                                 target_file_name=used_bip_file
#    Sleep    15sec
#    ${used_bip_file}    Run Keyword And Continue On Failure    Get Bip Log Via Interface Mirroring Collector
#    ...                                                                         target_file_name=used_bip_file
    DingLi_Client.Start Data Transfer    ues_index=${${0}}    whether_start_dl_call=${False}    ul_throughput=250000
    @{direction_component_list}    Create List    UL    DL
    ${dl_ttitrace_peak}    Run Keyword If    '${stream}'=='SBTS00'
    ...                       Run Keyword And Continue On Failure     Capture And Decode TTitrace Log    duration=2    direction=dl
    Run Keyword And Continue On Failure    Check Tput With Power UE    direction_component_list=@{direction_component_list}
    ...                                                                duration=120
    ...                                                                expect_ul_tput=204
    ...                                                                expect_dl_tput=1440
    ...                                                                cellid=1
    ...                                                                target_avg_percent=0.90
    ...                                                                ue_type=huawei_sigspark
    ...                                                                check_source=aasyslog
    ...                                                                min_percent=0
    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog
    Run Keyword If    '${stream}'=='SBTS00'    Log to console   staer to check beamType from TTI on trunk
    Run Keyword If    '${stream}'=='SBTS00'    Check DL beamType Status Via TTITrace   ttitrace_filt_path=${dl_ttitrace_peak}
#    Run Keyword And Ignore Error    Capture Mix Logs With gNB_logs
#    Run Keyword And Ignore Error    Get Captured Mixed File
#    ${uldata_pucchreceivereq}    Set Variable If    '${STREAM_VERSION}'=='master'    uldata_pucchreceivereql1sw
#    ...                                             '${STREAM_VERSION}'=='25R2'    uldata_pucchreceivereql1sw
#    ...                                                                            uldata_pucchreceivereq
#    ${UlData_pucchReceiveReqPucchResource_t}    Set Variable If    '${STREAM_VERSION}'=='master'    UlData_pucchReceiveReqPucchResourceL1sw_t
#    ...                                                            '${STREAM_VERSION}'=='25R2'    UlData_pucchReceiveReqPucchResourceL1sw_t
#    ...                                                                                            UlData_pucchReceiveReqPucchResource_t
#    Run Keyword And Continue On Failure    Check eAXCId And PatternId In UlData_PucchReceiveReq
#    ...                                    file_path=${bip_log_with_low_ul_traffic[0]}
#    ...                                    subcell_id=0
#    ...                                    uldata_pucchreceivereq=${uldata_pucchreceivereq}
#    ...                                    UlData_pucchReceiveReqPucchResource_t=${UlData_pucchReceiveReqPucchResource_t}
#    Run Keyword And Continue On Failure    Check eAXCId And PatternId In UlData_PucchReceiveReq
#    ...                                        file_path=${used_bip_file[0]}
#    ...                                        subcell_id=0
#    ...                                        uldata_pucchreceivereq=${uldata_pucchreceivereq}
#    ...                                        UlData_pucchReceiveReqPucchResource_t=${UlData_pucchReceiveReqPucchResource_t}
#    ${uldata_pucchreceiverespps}    Set Variable If    '${STREAM_VERSION}'=='master' or '${STREAM_VERSION}'=='25R3'    uldata_pucchreceiveresppsl1sw
#    ...                                                '${STREAM_VERSION}'=='25R2'    uldata_pucchreceiveresppsl1sw
#    ...                                                                                 uldata_pucchreceiverespps
#    ${UlData_pucchReceiveRespPsPucchResource_t}    Set Variable If
#    ...    '${STREAM_VERSION}'=='master' or '${STREAM_VERSION}'=='25R3'    UlData_pucchReceiveRespPsPucchResourceL1sw_t
#    ...    '${STREAM_VERSION}'=='25R2'    UlData_pucchReceiveRespPsPucchResourceL1sw_t
##    ...                                   UlData_pucchReceiveRespPsPucchResource_t
#    Run Keyword And Continue On Failure    Check DTX And CRC Based On PUCCH Format
#    ...                                    file_path=${bip_log_with_low_ul_traffic[0]}
#    ...                                    subcell_id=0
#    ...                                    pucch_format=13
#    ...                                    uldata_pucchreceiverespps=${uldata_pucchreceiverespps}
#    ...                                    UlData_pucchReceiveRespPsPucchResource_t=${UlData_pucchReceiveRespPsPucchResource_t}
##    Check DTX And CRC Based On PUCCH Format    file_path=${used_bip_file[0]}
#    ...                                        subcell_id=0
#    ...                                        pucch_format=3
#    ...                                        uldata_pucchreceiverespps=${uldata_pucchreceiverespps}
#    ...                                        UlData_pucchReceiveRespPsPucchResource_t=${UlData_pucchReceiveRespPsPucchResource_t}


CB009363-SR-E_006_Rank_switch_and_TPMI_Measurement_on_8Rx_SRS_and_8Rx_PUSCH_FS_1116_0ms_rdUlRiSelectionThresh8Rx
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=1    connection=GNB_OAM    timeout=300
    ${bwpDN_index_dedicate}    Set Variable IF    '${STREAM_VERSION}'=='master' or '${STREAM_VERSION}'=='26R2'    187    87
    Activate PRB Blank For 9915_E006    bwpDN_index_dedicate=${bwpDN_index_dedicate}
    ${5G_band}    Set Variable    78
    ${is_restart_ue}    Set Variable IF    '${STREAM_VERSION}'=='master'    ${False}    ${True}
#    Run Keyword And Ignore Error    Recover Collect Syslog For Gnb
#    Start To Capture Mix Logs With gNB_logs
#    Sleep    120s
    ${attach_status}    Run Keyword And Return Status    DingLi_Client.UE Attach With Retry    ues_index=${${0}}    5G_band=${5G_band}
    ...    is_restart_ue=${is_restart_ue}
#    Stop Capture Mix Logs With gNB_logs
#    Run Keyword And Ignore Error    Get Captured Mixed File
    ${expect_pci}    Set Variable IF    '${STREAM_VERSION}'=='master'    721    732
    Run Keyword If   '${attach_status}'=='${False}'    DingLi_Client.Check PCI In Attach Info
    ...    ues_index=${${0}}    expect_pci=${expect_pci}
    Run Keyword If   '${attach_status}'=='${False}'     FAIL    msg=attach failed.
    #--- start ul/dl traffic --- #
    DingLi_Client.Start Data Transfer    ues_index=${${0}}
    Sleep  30sec
    Log to console    step0:start to test in rank2 situation
#    Capture Logs With gNB_logs    duration=30    log_type=BIP
#    ${bip_log_rank2}    Get Captured BIP File
#    ${used_bip_file_rank2}    Used BIP File Rename    bip_file_path=${bip_log_rank2[-1]}t
#    Run Keyword And Continue On Failure    Collect Interface Mirroring Bip Collector    nr_phy_cell_ids=${expect_pci}
#    ...                                                                                 target_file_name=used_bip_file_rank2
#    Sleep    15sec
#    ${used_bip_file_rank2}    Run Keyword And Continue On Failure    Get Bip Log Via Interface Mirroring Collector
#    ...                                                                         target_file_name=used_bip_file_rank2
    @{direction_component_list}    Create List    UL    DL
    Run Keyword And Continue On Failure    Check Tput With Power UE    direction_component_list=@{direction_component_list}
    ...                                                                duration=120
    ...                                                                expect_ul_tput=193
    ...                                                                expect_dl_tput=1120
    ...                                                                cellid=1
    ...                                                                target_avg_percent=0.90
    ...                                                                ue_type=huawei_sigspark
    ...                                                                check_source=aasyslog
    ...                                                                min_percent=0
#    Run Keyword And Ignore Error    Capture Mix Logs With gNB_logs
#    Run Keyword And Ignore Error    Get Captured Mixed File
#    Connect to gnb coam via ssl    connection=GNB_OAM0  gnb_index=0
#    Run Keyword And Ignore Error    COAM Save snapshot via rest api    connection=GNB_OAM0    timeout=30min
#    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM0
#    Log to console    step1:start to test in -106db rank1 situation
#    Run Keyword If   '${STREAM_VERSION}'=='master'     Mcs.Set ATT Value For Four Output Ports
#    ...                                                    mcs_type=${mcs_type}    mcs_index=${1}     att_value=47
#    ...                                                    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}
#    ...                                                    begin_input_port=${1}    end_input_port=${32}
#    ...    ELSE    Mcs.Set ATT Value For Four Output Ports    mcs_type=${mcs_type}    mcs_index=${1}     att_value=76
#    ...                                                       first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}
#    ...                                                    begin_input_port=${1}    end_input_port=${32}
#    Sleep  30sec
#    Capture Logs With gNB_logs    duration=30    log_type=BIP
#    ${bip_log_rank1_bad1}    Get Captured BIP File
#    ${used_bip_log_rank1_bad1}    Used BIP File Rename    bip_file_path=${bip_log_rank1_bad1[-1]}
#    Run Keyword And Continue On Failure    Collect Interface Mirroring Bip Collector    nr_phy_cell_ids=${expect_pci}
#    ...                                                                                 target_file_name=used_bip_log_rank1_bad1
#    Sleep    15sec
#    ${used_bip_log_rank1_bad1}    Run Keyword And Continue On Failure    Get Bip Log Via Interface Mirroring Collector
#    ...                                                                         target_file_name=used_bip_log_rank1_bad1
    Log to console    step1:start to test in -110db rank1 situation
    ${att_value}    Set Variable IF    '${stream}'=='SBTS00'    25    57
    ${target_att_Value}    Set Variable IF    '${stream}'=='SBTS00'    49    61
    Cycle UPdate ATT Value    att_value=${att_value}    target_att_Value=${target_att_Value}
#    Run Keyword If   '${STREAM_VERSION}'=='master'    Mcs.Set ATT Value For Four Output Ports
#    ...                                                   mcs_type=${mcs_type}    mcs_index=${1}     att_value=51
#    ...                                                   first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}
#    ...                                                   begin_input_port=${1}    end_input_port=${32}
#    ...    ELSE    Mcs.Set ATT Value For Four Output Ports    mcs_type=${mcs_type}    mcs_index=${1}     att_value=80
#    ...                                                       first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}
#    ...                                                    begin_input_port=${1}    end_input_port=${32}
    Sleep  30sec
#    Capture Logs With gNB_logs    duration=30    log_type=BIP
#    ${bip_log_rank1_bad2}    Get Captured BIP File
#    ${used_bip_log_rank1_bad2}    Used BIP File Rename    bip_file_path=${bip_log_rank1_bad2[-1]}
    Run Keyword And Continue On Failure    Collect Interface Mirroring Bip Collector    nr_phy_cell_ids=${expect_pci}
    ...                                                                                 target_file_name=used_bip_log_rank1_bad2
    Sleep    15sec
    ${used_bip_log_rank1_bad2}    Run Keyword And Continue On Failure    Get Bip Log Via Interface Mirroring Collector
    ...                                                                         target_file_name=used_bip_log_rank1_bad2
#    Log to console    step3:start to test in fallback to -106db rank1
#    Run Keyword If   '${STREAM_VERSION}'=='master'     Mcs.Set ATT Value For Four Output Ports
#    ...                                                    mcs_type=${mcs_type}    mcs_index=${1}     att_value=47
#    ...                                                    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}
#    ...                                                    begin_input_port=${1}    end_input_port=${32}
#    ...    ELSE    Mcs.Set ATT Value For Four Output Ports    mcs_type=${mcs_type}    mcs_index=${1}     att_value=76
#    ...                                                       first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}
#    ...                                                   begin_input_port=${1}    end_input_port=${32}
#    Sleep  30sec
#    Capture Logs With gNB_logs    duration=30    log_type=BIP
#    ${fallback_bip_log_rank1_bad1}    Get Captured BIP File
#    ${used_fallback_bip_log_rank1_bad1}    Used BIP File Rename    bip_file_path=${fallback_bip_log_rank1_bad1[-1]}
#    Run Keyword And Continue On Failure    Collect Interface Mirroring Bip Collector    nr_phy_cell_ids=${expect_pci}
#    ...                                                                                 target_file_name=used_fallback_bip_log_rank1_bad1
#    Sleep    15sec
#    ${used_fallback_bip_log_rank1_bad1}    Run Keyword And Continue On Failure    Get Bip Log Via Interface Mirroring Collector
#    ...                                                                         target_file_name=used_fallback_bip_log_rank1_bad1
    Log to console    step2:start to test in fallback to rank2
#    Run Keyword If   '${STREAM_VERSION}'=='master'     Mcs.Set ATT Value For Four Output Ports
#    ...                                                    mcs_type=${mcs_type}    mcs_index=${1}     att_value=5
#    ...                                                    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}
#    ...                                                    begin_input_port=${1}    end_input_port=${32}
#    ...    ELSE    Mcs.Set ATT Value For Four Output Ports    mcs_type=${mcs_type}    mcs_index=${1}     att_value=20
#    ...                                                       first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}
#    ...                                                   begin_input_port=${1}    end_input_port=${32}
    ${att_value}    Set Variable IF    '${stream}'=='SBTS00'    25    45
    ${target_att_Value}    Set Variable IF    '${stream}'=='SBTS00'    6    21
    Cycle Fallback ATT Value  att_value=${att_value}    target_att_Value=${target_att_Value}
    Sleep  30sec
#    Capture Logs With gNB_logs    duration=30    log_type=BIP
#    ${fallback_bip_log_rank2}    Get Captured BIP File
#    ${used_fallback_bip_log_rank2}    Used BIP File Rename    bip_file_path=${fallback_bip_log_rank2[-1]}
    Run Keyword And Continue On Failure    Collect Interface Mirroring Bip Collector    nr_phy_cell_ids=${expect_pci}
    ...                                                                                 target_file_name=used_fallback_bip_log_rank2
    Sleep    15sec
    ${used_fallback_bip_log_rank2}    Run Keyword And Continue On Failure    Get Bip Log Via Interface Mirroring Collector
    ...                                                                         target_file_name=used_fallback_bip_log_rank2
    Run Keyword And Continue On Failure    Check Tput With Power UE    direction_component_list=@{direction_component_list}
    ...                                                                duration=120
    ...                                                                expect_ul_tput=193
    ...                                                                expect_dl_tput=1120
    ...                                                                cellid=1
    ...                                                                target_avg_percent=0.90
    ...                                                                ue_type=huawei_sigspark
    ...                                                                check_source=aasyslog
    ...                                                                min_percent=0
#    Run Keyword And Ignore Error    Capture Mix Logs With gNB_logs
#    Run Keyword And Ignore Error    Get Captured Mixed File
#    Connect to gnb coam via ssl    connection=GNB_OAM0  gnb_index=0
#    Run Keyword And Ignore Error    COAM Save snapshot via rest api    connection=GNB_OAM0    timeout=30min
#    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM0
    #---checkpoint for rank2---#
#    Run Keyword And Continue On Failure    Check StartPrb For SRS    file_path=${used_bip_file_rank2[0]}    subcell_id=0
#    Run Keyword And Continue On Failure    Check UL Rank On UlData_PuschReceiveRespPs    file_path=${used_bip_file_rank2[0]}    subcell_id=0
#    Run Keyword And Continue On Failure    Check UL Rank On UlData_PuschReceiveReq    file_path=${used_bip_file_rank2[0]}    subcell_id=0
#    Run Keyword And Continue On Failure    Check Rxpower And Sinr In UlData_PuschReceiveRespPs
#    ...     file_path=${used_bip_file_rank2[0]}    subcell_id=0
#    Run Keyword And Continue On Failure    Check PatternId In UlData_PuschReceiveReq
#    ...     file_path=${used_bip_file_rank2[0]}    subcell_id=0
    Run Keyword And Continue On Failure    Check UL Rank On UlData_PuschReceiveRespPs
    ...    file_path=${used_fallback_bip_log_rank2[0]}    subcell_id=0
    Run Keyword And Continue On Failure    Check UL Rank On UlData_PuschReceiveReq
    ...    file_path=${used_fallback_bip_log_rank2[0]}    subcell_id=0
#    Run Keyword And Continue On Failure    Check Rxpower And Sinr In UlData_PuschReceiveRespPs
#    ...     file_path=${used_fallback_bip_log_rank2[0]}    subcell_id=0
    Run Keyword And Continue On Failure    Check PatternId In UlData_PuschReceiveReq
    ...     file_path=${used_fallback_bip_log_rank2[0]}    subcell_id=0
    #---checkpoint for rank1 bad1---#
#    Run Keyword And Continue On Failure     Check Values On UlData_SrsReceiveRespPs
#    ...    file_path=${used_bip_log_rank1_bad1[0]}    subcell_id=0
#    Run Keyword And Continue On Failure    Check UL Rank On UlData_PuschReceiveReq
#    ...     file_path=${used_bip_log_rank1_bad1[0]}    subcell_id=0    expect_rank=1
#    Run Keyword And Continue On Failure    Check UlData_SrsReceiveReq Exist    file_path=${used_bip_log_rank1_bad1[0]}    subcell_id=0
#    Run Keyword And Continue On Failure    Check UL Rank On UlData_PuschReceiveRespPs
#    ...    file_path=${used_bip_log_rank1_bad1[0]}    subcell_id=0    expect_rank=255
#    Run Keyword And Continue On Failure    Check Pattern ID In uldata_srsreceivereq
#    ...    file_path=${used_bip_log_rank1_bad1[0]}    subcell_id=0
#    Run Keyword And Continue On Failure    Check PBoost Value On Cell Edge    file_path=${used_bip_log_rank1_bad1[0]}    subcell_id=0
    Run Keyword And Continue On Failure     Check Values On UlData_SrsReceiveRespPs
    ...    file_path=${used_bip_log_rank1_bad2[0]}    subcell_id=0
    Run Keyword And Continue On Failure    Check UL Rank On UlData_PuschReceiveReq
    ...     file_path=${used_bip_log_rank1_bad2[0]}    subcell_id=0    expect_rank=1
    Run Keyword And Continue On Failure    Check UlData_SrsReceiveReq Exist    file_path=${used_bip_log_rank1_bad2[0]}    subcell_id=0
#    Run Keyword And Continue On Failure    Check UL Rank On UlData_PuschReceiveRespPs
#    ...    file_path=${used_bip_log_rank1_bad2[0]}    subcell_id=0    expect_rank=255
    Run Keyword And Continue On Failure    Check Pattern ID In uldata_srsreceivereq
    ...    file_path=${used_bip_log_rank1_bad2[0]}    subcell_id=0
    Run Keyword And Continue On Failure    Check PBoost Value On Cell Edge    file_path=${used_bip_log_rank1_bad2[0]}    subcell_id=0
#    Run Keyword And Continue On Failure     Check Values On UlData_SrsReceiveRespPs
#    ...    file_path=${used_fallback_bip_log_rank1_bad1[0]}    subcell_id=0
#    Run Keyword And Continue On Failure    Check UL Rank On UlData_PuschReceiveReq
#    ...     file_path=${used_fallback_bip_log_rank1_bad1[0]}    subcell_id=0    expect_rank=1
#    Run Keyword And Continue On Failure    Check UlData_SrsReceiveReq Exist
#    ...    file_path=${used_fallback_bip_log_rank1_bad1[0]}    subcell_id=0
##    Run Keyword And Continue On Failure    Check UL Rank On UlData_PuschReceiveRespPs
##    ...    file_path=${used_fallback_bip_log_rank1_bad1[0]}    subcell_id=0    expect_rank=255
#    Run Keyword And Continue On Failure    Check Pattern ID In uldata_srsreceivereq
#    ...    file_path=${used_fallback_bip_log_rank1_bad1[0]}    subcell_id=0
#    Run Keyword And Continue On Failure    Check PBoost Value On Cell Edge
#    ...    file_path=${used_fallback_bip_log_rank1_bad1[0]}    subcell_id=0
    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog

CB009363-SR-F_010_2_UEs_Rank_2_with_non-GBR_high_load_are_paired_with_rdActUlMuMimoNlos_true
    ULMUMIMO.Activate UL MUMIMO
    ULMUMIMO.Modify UL MUMIMO Param ulSinrDiffThreshold
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=1    connection=GNB_OAM    timeout=300
    ${5G_band}    Set Variable    78
    ${used_ues_index}    Set Variable IF    '${STREAM_VERSION}'=='master'    ${${0},${2}}    ${${2},${3}}
    ${is_restart_ue}    Set Variable IF    '${STREAM_VERSION}'=='master'    ${False}    ${True}
    Run Keyword And Ignore Error    Recover Collect Syslog For Gnb
#    Start To Capture Mix Logs With gNB_logs
    Sleep    120s
    ${attach_status}    Run Keyword And Return Status    DingLi_Client.UE Attach With Retry    ues_index=${used_ues_index}
    ...     5G_band=${5G_band}    is_restart_ue=${is_restart_ue}
#    Stop Capture Mix Logs With gNB_logs
#    Run Keyword And Ignore Error    Get Captured Mixed File
    ${expect_pci}    Set Variable IF    '${STREAM_VERSION}'=='master'    721    732
    Run Keyword If   '${attach_status}'=='${False}'    DingLi_Client.Check PCI In Attach Info
    ...    ues_index=${${2}}    expect_pci=${expect_pci}
    Run Keyword If   '${attach_status}'=='${False}'     FAIL    msg=attach failed.
    #--- low ul traffic --- #
    DingLi_Client.Start Data Transfer    ues_index=${used_ues_index}    whether_start_dl_call=${False}    ul_throughput=250000
    sleep    30sec
#    Capture Logs With gNB_logs    duration=30    log_type=BIP
#    ${two_sa_ues_paired_bips}    Get Captured BIP File
#    ${two_sa_ues_paired_bip}    Used BIP File Rename    bip_file_path=${two_sa_ues_paired_bips[-1]}
#    Run Keyword And Continue On Failure    Collect Interface Mirroring Bip Collector    nr_phy_cell_ids=${expect_pci}
#    ...                                                                                 target_file_name=two_sa_ues_paired_bip
#    Sleep    15sec
#    ${two_sa_ues_paired_bip}    Run Keyword And Continue On Failure    Get Bip Log Via Interface Mirroring Collector
#    ...                                                                         target_file_name=two_sa_ues_paired_bip
#    ${two_sa_ues_paired_ttitrace}    Run Keyword And Continue On Failure    Capture TTI with gnb logs
    ${two_sa_ues_paired_ttitrace}    Capture And Decode TTitrace Log
    #--- big dl traffic ---#
    DingLi_Client.Start Data Transfer    ues_index=${used_ues_index}    whether_start_ul_call=${False}    dl_throughput=700M
    sleep    30sec
    @{direction_component_list}    Create List    UL    DL
    Run Keyword And Continue On Failure    Check Tput With Power UE    direction_component_list=@{direction_component_list}
    ...                                                                duration=120
    ...                                                                expect_ul_tput=408
    ...                                                                expect_dl_tput=1000
    ...                                                                cellid=1
    ...                                                                target_avg_percent=0.90
    ...                                                                ue_type=huawei_sigspark
    ...                                                                check_source=aasyslog
    ...                                                                min_percent=0
#    Run Keyword And Ignore Error    Capture Mix Logs With gNB_logs
#    Run Keyword And Ignore Error    Get Captured Mixed File
    #checkpoint
#    Run Keyword And Continue On Failure    ULMUMIMO.Check UE Paried Status Via TTITrace
#    ...                                    ttitrace_filt_path=${two_sa_ues_paired_ttitrace}
#    ...                                    percent_exp=0.94
    Run Keyword And Continue On Failure    ULMUMIMO.Check Single UE Average Tput Via TTITrace
    ...                                    ttitrace_filt_path=${two_sa_ues_paired_ttitrace}
    ...                                    expect_tput_value=204
#    Check eAXCId In UlData_PuschReceiveReq    file_path=${two_sa_ues_paired_bip[0]}    subcell_id=0
    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog

CB009363-SR-F_007_4_UEs_Rank_1_with_non-GBR_high_load_are_paired_with_LOS_and_NLOS_channel
    ULMUMIMO.Activate UL MUMIMO
    ULMUMIMO.Modify UL MUMIMO Param ulSinrDiffThreshold
#    Run Keyword If   '${STREAM_VERSION}'=='master'    WR FOR MUMIMIMO
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=1    connection=GNB_OAM    timeout=300
    Run Keyword If   '${STREAM_VERSION}'=='master'    Mcs.Set Phases According To Angles For Two Output Groups
    ...    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${1}   first_beam_end_output_port=${2}
    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}
    ...    first_beam_horizontal_angle=${-30}    second_beam_horizontal_angle=${-45}    vertical_angle=${-6}
    ...    vertical_distance=${2}    end_input_port=${16}
    Run Keyword If   '${STREAM_VERSION}'=='master'    Mcs.Set Phases According To Angles For Two Output Groups
    ...    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${5}   first_beam_end_output_port=${6}
    ...    second_beam_begin_output_port=${7}    second_beam_end_output_port=${8}
    ...    first_beam_horizontal_angle=${30}    second_beam_horizontal_angle=${50}    vertical_angle=${-6}
    ...    vertical_distance=${2}    end_input_port=${16}
    Run Keyword If   '${STREAM_VERSION}'=='master'    Mcs.Set Phases According To Angles For Two Output Groups
    ...    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${9}   first_beam_end_output_port=${10}
    ...    second_beam_begin_output_port=${11}    second_beam_end_output_port=${12}
    ...    first_beam_horizontal_angle=${2}    second_beam_horizontal_angle=${-15}    vertical_angle=${-6}
    ...    vertical_distance=${2}    end_input_port=${16}
    Run Keyword If   '${STREAM_VERSION}'=='master'    Mcs.Set Phases According To Angles For Two Output Groups
    ...    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${13}   first_beam_end_output_port=${14}
    ...    second_beam_begin_output_port=${15}    second_beam_end_output_port=${16}
    ...    first_beam_horizontal_angle=${7}    second_beam_horizontal_angle=${24}    vertical_angle=${-6}
    ...    vertical_distance=${2}    end_input_port=${16}
    Run Keyword If   '${STREAM_VERSION}'!='master'    Mcs.Set Phases According To Angles For Two Output Groups
    ...    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${1}   first_beam_end_output_port=${2}
    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}
    ...    first_beam_horizontal_angle=${-35}    second_beam_horizontal_angle=${-50}    vertical_angle=${-6}
    ...    vertical_distance=${2}   end_input_port=${16}
#    Run Keyword And Ignore Error    client.poweroff     ue=${uegroup}    until_timeout=${300}
#    sleep    2s
    Run Keyword And Ignore Error    client.poweron     ue=${uegroup}    until_timeout=${300}
    sleep    1min
    DingLi_Client.SA And NSA Mode Change    UE_mode=5G_NSA
    ${5G_band}    Set Variable    78
    ${is_restart_ue}    Set Variable IF    '${STREAM_VERSION}'=='master'    ${False}    ${True}
#    Run Keyword And Ignore Error    Recover Collect Syslog For Gnb
#    Start To Capture Mix Logs With gNB_logs
#    Sleep    120s
    ${attach_status}    Run Keyword And Return Status    DingLi_Client.UE Attach With Retry    ues_index=${${0},${1},${2},${3}}
    ...    UE_mode=5G_NSA
    ...    5G_band=${5G_band}
    ...    is_restart_ue=${is_restart_ue}
#    Stop Capture Mix Logs With gNB_logs
#    Run Keyword And Ignore Error    Get Captured Mixed File
    ${expect_pci}    Set Variable IF    '${STREAM_VERSION}'=='master'    721    732
    Run Keyword If   '${attach_status}'=='${False}'    DingLi_Client.Check PCI In Attach Info
    ...    ues_index=${${0}}    expect_pci=${expect_pci}
    Run Keyword If   '${attach_status}'=='${False}'     FAIL    msg=attach failed.
    #--- low ul traffic --- #
    DingLi_Client.Start Data Transfer    ues_index=${${0},${1},${2},${3}}   whether_start_dl_call=${False}    ul_throughput=130000
    sleep    30sec
#    Capture Logs With gNB_logs    duration=30    log_type=BIP
#    ${four_nsa_ues_paired_bips}    Get Captured BIP File
#    ${four_nsa_ues_paired_bip}    Used BIP File Rename    bip_file_path=${four_nsa_ues_paired_bips[-1]}
#    Run Keyword And Continue On Failure    Collect Interface Mirroring Bip Collector    nr_phy_cell_ids=${expect_pci}
#    ...                                                                                 target_file_name=four_nsa_ues_paired_bip
#    Sleep    15sec
#    ${four_nsa_ues_paired_bip}    Run Keyword And Continue On Failure    Get Bip Log Via Interface Mirroring Collector
#    ...                                                                         target_file_name=four_nsa_ues_paired_bip
#    ${four_nsa_ues_paired_ttitrace}    Run Keyword And Continue On Failure    Capture TTI with gnb logs    duration=10
    ${four_nsa_ues_paired_ttitrace}    Run Keyword And Continue On Failure    Capture And Decode TTitrace Log
    #--- big dl traffic ---#
    DingLi_Client.Start Data Transfer    ues_index=${${0},${1},${2},${3}}    whether_start_ul_call=${False}    dl_throughput=400M
    sleep    30sec
    @{direction_component_list}    Create List    UL    DL
    Run Keyword And Continue On Failure    Check Tput With Power UE    direction_component_list=@{direction_component_list}
    ...                                                                duration=120
    ...                                                                expect_ul_tput=408
    ...                                                                expect_dl_tput=1000
    ...                                                                cellid=1
    ...                                                                target_avg_percent=0.90
    ...                                                                ue_type=huawei_sigspark
    ...                                                                check_source=aasyslog
    ...                                                                min_percent=0
    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog
    run Keyword And Ignore Error    DingLi_Client.Stop Data Transfer
    Update_actUlMuMimoGroupPairing_Values
    DingLi_Client.Start Data Transfer    ues_index=${${0}}   whether_start_dl_call=${False}
    Sleep    5sec
    DingLi_Client.Start Data Transfer    ues_index=${${1},${2},${3}}   whether_start_dl_call=${False}    ul_throughput=10000
    Sleep    10sec
#    DingLi_Client.Start Data Transfer    ues_index=${${0},${1},${2},${3}}    whether_start_ul_call=${False}
    Run Keyword If   '${STREAM_VERSION}'=='master'    UPdate All ATT Value FOR All UE RSRP TO 85 on Trunk
    ...    ELSE                                       UPdate All ATT Value FOR All UE RSRP TO 85 on Branch
    Sleep    10sec
#    Run Keyword And Continue On Failure    Collect Interface Mirroring Bip Collector    nr_phy_cell_ids=${expect_pci}
#    ...                                                                                 target_file_name=four_nsa_ues_paired_bip_rsrp_85
#    Sleep    5sec
#    ${four_nsa_ues_paired_bip_85}    Run Keyword And Continue On Failure    Get Bip Log Via Interface Mirroring Collector
#    ...                                                                         target_file_name=four_nsa_ues_paired_bip_rsrp_85
#    ${four_nsa_ues_paired_ttitrace_85}    Run Keyword And Continue On Failure    Capture TTI with gnb logs    duration=5
    ${four_nsa_ues_paired_ttitrace_85}    Run Keyword And Continue On Failure     Capture And Decode TTitrace Log    duration=5
    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog
#    Run Keyword And Ignore Error    Capture Mix Logs With gNB_logs
#    Run Keyword And Ignore Error    Get Captured Mixed File
    #checkpoint
#    Run Keyword And Continue On Failure    ULMUMIMO.Check UE Paried Status Via TTITrace
#    ...                                    ttitrace_filt_path=${four_nsa_ues_paired_ttitrace}
#    ...                                    percent_exp=0.94
    Run Keyword And Continue On Failure    ULMUMIMO.Check Single UE Average Tput Via TTITrace
    ...                                    ttitrace_filt_path=${four_nsa_ues_paired_ttitrace}
    ...                                    expect_tput_value=102
#    Check eAXCId In UlData_PuschReceiveReq    file_path=${four_nsa_ues_paired_bip[0]}   subcell_id=0   ue_numbers=4
    Run Keyword And Continue On Failure    Check MUGroup Paried Status Via TTITrace
    ...                                    ttitrace_filt_path=${four_nsa_ues_paired_ttitrace_85}
    ...                                    group_paird_percent_exp=0

CB009363-SR-I_003_Rank_1_and_PMI_Measurement_on_8Rx_SRS_with_DFT-s-OFDM_FS_1208
#    Update Refine Beam Related Params    nrBtsBeamRefinementP2=true   actUlSrsBm=false
    Disable 2200 And Enable Refine Beam Via WebUI
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=1    connection=GNB_OAM    timeout=300
    Connect to gnb coam via ssl    connection=GNB_0AM   gnb_index=${0}
    ${cur_scf_file}    coam_gnb_classical.COAM Download scf from cluster
    ...    scf_dir_path=${TS_CASE_LOG_PATH}    connection=GNB_0AM
    Update ulTransPrecodeSinrThresh Related Params    cell_index=1
    ${5G_band}    Set Variable    78
#    Run Keyword And Ignore Error    Recover Collect Syslog For Gnb
#    Start To Capture Mix Logs With gNB_logs
#    Sleep    120s
    ${attach_status}    Run Keyword And Return Status    DingLi_Client.UE Attach With Retry    ues_index=${${0}}    5G_band=${5G_band}
#    Stop Capture Mix Logs With gNB_logs
#    Run Keyword And Ignore Error    Get Captured Mixed File
    ${expect_pci}    Set Variable IF    '${STREAM_VERSION}'=='master'    721    732
    Run Keyword If   '${attach_status}'=='${False}'    DingLi_Client.Check PCI In Attach Info
    ...    ues_index=${${0}}    expect_pci=${expect_pci}
    Run Keyword If   '${attach_status}'=='${False}'     FAIL    msg=attach failed.
    #--- start ul/dl traffic --- #
    DingLi_Client.Start Data Transfer    ues_index=${${0}}
    Sleep  30sec
    Run Keyword If   '${STREAM_VERSION}'=='master'    Mcs.Set ATT Value For Four Output Ports
    ...                                                   mcs_type=${mcs_type}    mcs_index=${1}     att_value=39
    ...                                                   first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}
    ...                                                   begin_input_port=${1}    end_input_port=${32}
    ...    ELSE    Mcs.Set ATT Value For Four Output Ports    mcs_type=${mcs_type}    mcs_index=${1}     att_value=76
    ...                                                       first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}
    ...                                                   begin_input_port=${1}    end_input_port=${32}
    Sleep  30sec
#    Capture Logs With gNB_logs    duration=30    log_type=BIP
#    ${bip_log_rank1}    Get Captured BIP File
#    ${used_bip_log_rank1}    Used BIP File Rename    bip_file_path=${bip_log_rank1[-1]}
    Run Keyword And Continue On Failure    Collect Interface Mirroring Bip Collector    nr_phy_cell_ids=${expect_pci}
    ...                                                                                 target_file_name=used_bip_log_rank1
    Sleep    15sec
    ${used_bip_log_rank1}    Run Keyword And Continue On Failure    Get Bip Log Via Interface Mirroring Collector
    ...                                                                         target_file_name=used_bip_log_rank1
#    Check PatternId With Refine Beam In UlData_PuschReceiveReq    file_path=${used_bip_log_rank1[0]}    subcell_id=0
    #check DFT_OFDM
    Sleep    30sec
    Run Keyword And Continue On Failure    Check Vaild Values In UlData_PuschReceiveRespPs    file_path=${used_bip_log_rank1[0]}
    ...    subcell_id=0
#    Run Keyword And Continue On Failure    Check PUSCHTransformPrecoder Enabled    file_path=${used_bip_log_rank1[0]}    subcell_id=0
    Run Keyword If   '${STREAM_VERSION}'=='master'    Mcs.Set ATT Value For Four Output Ports
    ...                                                   mcs_type=${mcs_type}    mcs_index=${1}     att_value=2
    ...                                                   first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}
    ...                                                   begin_input_port=${1}    end_input_port=${32}
    ...    ELSE    Mcs.Set ATT Value For Four Output Ports    mcs_type=${mcs_type}    mcs_index=${1}     att_value=20
    ...                                                       first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}
    ...                                                   begin_input_port=${1}    end_input_port=${32}
    Sleep    10sec
#    Capture Logs With gNB_logs    duration=30    log_type=BIP
#    ${bip_log_disable}    Get Captured BIP File
#    ${used_bip_file_disable}    Used BIP File Rename    bip_file_path=${bip_log_disable[-1]}
#    Run Keyword And Continue On Failure    Collect Interface Mirroring Bip Collector    nr_phy_cell_ids=${expect_pci}
#    ...                                                                                 target_file_name=used_bip_file_disable
#    Sleep    15sec
##    ${used_bip_file_disable}    Run Keyword And Continue On Failure    Get Bip Log Via Interface Mirroring Collector
##    ...                                                                         target_file_name=used_bip_file_disable
#    Run Keyword And Continue On Failure    Check PUSCHTransformPrecoder Enabled    file_path=${used_bip_file_disable[0]}    subcell_id=0
#    ...    enable_disable_flag=0
#    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog
#    [Teardown]    Run Keywords    Update Refine Beam Related Params    AND
#    ...    Update ulTransPrecodeSinrThresh Related Params    cell_index=1    on_thresh=15    off_thresh=35
    [Teardown]    Run Keyword And Ignore Error    Update ulTransPrecodeSinrThresh Related Params
    ...    cell_index=1    on_thresh=15    off_thresh=35

CB009363-SR-J_002_L3_call_with_custom_beam_set
    Log to console    start to activate BSR
    Load And Activate BSR package
    Sleep  30s
    Wait For Onair And Check No Alarm    allowed_faults=${ALLOWED_FAULTS_LIST}
    Activate BSR Via WebEM
    Sleep  10s
    Wait For Onair And Check No Alarm    allowed_faults=${ALLOWED_FAULTS_LIST}
    Check installed BSR Status
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=1    connection=GNB_OAM    timeout=300
    ${5G_band}    Set Variable    78
#    Run Keyword And Ignore Error    Recover Collect Syslog For Gnb
#    Start To Capture Mix Logs With gNB_logs
#    Sleep    120s
    ${attach_status}    Run Keyword And Return Status    DingLi_Client.UE Attach With Retry    ues_index=${${0}}    5G_band=${5G_band}
#    Stop Capture Mix Logs With gNB_logs
#    Run Keyword And Ignore Error    Get Captured Mixed File
    ${expect_pci}    Set Variable IF    '${STREAM_VERSION}'=='master'    721    732
    Run Keyword If   '${attach_status}'=='${False}'    DingLi_Client.Check PCI In Attach Info
    ...    ues_index=${${0}}    expect_pci=${expect_pci}
    Run Keyword If   '${attach_status}'=='${False}'     FAIL    msg=attach failed.
    #--- start ul/dl traffic --- #
    DingLi_Client.Start Data Transfer    ues_index=${${0}}
    Sleep  30sec
    @{direction_component_list}    Create List    UL    DL
    Run Keyword And Continue On Failure    Check Tput With Power UE    direction_component_list=@{direction_component_list}
    ...                                                                duration=120
    ...                                                                expect_ul_tput=204
    ...                                                                expect_dl_tput=1440
    ...                                                                cellid=1
    ...                                                                target_avg_percent=0.90
    ...                                                                ue_type=huawei_sigspark
    ...                                                                check_source=aasyslog
    ...                                                                min_percent=0
#    Run Keyword And Ignore Error    Capture Mix Logs With gNB_logs
#    Run Keyword And Ignore Error    Get Captured Mixed File
    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog
    [Teardown]    Restore For BSR Function

9363_Suite_SetUp
    [Arguments]    ${is_suite_commission_needed}=${True}    ${swconfig_flag}=${None}    ${is_need_to_kill_mcs}=${True}
    Log    ${is_need_to_kill_mcs}
    Log    ${is_suite_commission_needed}
    robot_common_operations.Common Suite Setup
    run keyword and ignore error    clear vm pid before run case
    @{ue_num}    Set Variable    ${tl.ues}
    ${ue_length}    Get Length    ${ue_num}
    Set Suite Variable    ${UE_LENGTH}    ${ue_length}
    FOR    ${ue_index}    IN RANGE    ${UE_LENGTH}
        ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
        Set Suite Variable    ${UE${ue_index}_TYPE}    ${ue_type}
    END
    ${stream_version}    Get Active SW Version Based On Stream Version
    Set Suite Variable    ${STREAM_VERSION}    ${stream_version}
    ${SCF_Path}    ${result}    Split String From Right    ${CURDIR}    testsuite     1
    ${ute_env}    Run Keyword And Return Status    Run Keywords
    ...    Variable Should Exist    ${CONFIGURATION}    AND    Variable Should Exist    ${ENB_BUILD}
    ${tmp_testline}   Run Keyword If    ${ute_env}    String.Fetch From Right    string=${CONFIGURATION}    marker=.
    ...           ELSE    Set Variable     ${testline_name}
    ${stream}    ${build}     Run Keyword If    ${ute_env}    CI_commssion._Get Stream From Variable    ${ENB_BUILD}
    ...    ELSE   CI_commssion._Get Stream From Variable    ${AF_PATH}
    Set Suite Variable    ${stream}
    ${Golden_SCF_Path}    Set Variable If    '${stream}'!='SBTS25R1'    ${SCF_PATH}commissionings/HGZ/${tmp_testline}/SCF_${stream}.xml
    ...                   ${SCF_PATH}commissionings/HGZ/${tmp_testline}/SCF_${stream}_3S-1CC.xml
    Set Suite Variable    ${Golden_SCF_Path}
#    ${cell_group_indexs}    Create List    1   2
#    ${scf_with_one_cell}    delete_cell_from_scf    cell_indexs=${2,3}
#    ...                                             cell_group_indexs=${cell_group_indexs}
#    ...                                             channel_mapping_lcelnr_indexs=${2,3}
#    ...                                             basic_scf_path=${Golden_SCF_Path}
#    ...                                             update_scf_path=/home/ute/SCF/SCF_${stream}_9363_B_delete.xml
#    ${cell1_celltypoe_dict}    Catenate    {"celltype":"8DL8UL", "cell_index":"1","lcelnr_index":"1",
#    ...    "rmod_index":"1","rx_channel_number":"8","tx_channel_number":"4"}
#    ${cell1_celltypoe_dict_list}    Evaluate    [${cell1_celltypoe_dict}]
#    ${scf_update_with_celltype}    update_celltype_for_cells    celltype_info_dict_list=${cell1_celltypoe_dict_list}
#    ...    basic_scf_path=${scf_with_one_cell}    update_scf_path=/home/ute/SCF/SCF_${stream}_9363_B_delete_update.xml
#    ${scf_with_update_params}    perform_update_scf_params
#    ...                          update_params=@{scf_update_params_9363_B}
#    ...                          basic_scf_path=${scf_update_with_celltype}
#    ...                          update_scf_path=/home/ute/SCF/SCF_${stream}_9363_B_8D8U_FINAL.xml
#    Set Suite Variable    ${BASIC_SCF_PATH}    ${scf_with_update_params}
    Suite Log Path Create
    Run Keyword If    '${swconfig_flag}'!='${None}'     Backup and Modify swconfig file
    ...                                                 swconfig_modify=@{SWCONFIG_9363_${swconfig_flag}}
#    Run Keyword If    ${is_suite_commission_needed}    Perform Commission    scf_file_path=${BASIC_SCF_PATH}
#    ...                                                                      gnb_index=${0}
#    ...                                                                      timeout_for_commission=900
#    ...                                                                      wait_gnb_up_timeout=30 min
#    ...                                                                      is_pdl_checking_needed=${True}
     DingLi_Client.UE Prepare    HW_TYPE=${${testline_name}_HW_TYPE}
     DingLi_Client.SA And NSA Mode Change
     Run Keyword And Ignore Error    client.detach     ue=${uegroup}    until_timeout=${300}     withpdu=1
     sleep    5sec

#9363_Case_SetUp
#    [Arguments]    ${update_params_dict}=${None}
#    Log    ${update_params_dict}
#    robot_common_operations.Common Case Setup    fail_with_alarms=${False}
#    ${gnb_allowed_fault_Before_Commission}   Create List    4203    1838    4741    4681   7311   7331
#    ...                                                     4293    4297    4420    4775   1932   1934    1933
#    Set Test Variable    ${gnb_allowed_fault_Before_Commission}
#    AlarmWatchdog.add_allow_alarms    fault_id=${gnb_allowed_fault_Before_Commission}
#    Create Case Log Path
#    ${scf_name}    Set Variable    ${BASIC_SCF_PATH.split('/')[-1]}
#    copy file    ${BASIC_SCF_PATH}     ${TS_CASE_LOG_PATH}/${scf_name}
#    ${summary_alarm_info}    Get Active Alarms And Save Summary Infomation
#    Set Test Variable    ${summary_alarm_info}
#    ${allowed_faults_list}    Combine Current Active Alarm With White List Alarm List
#    Set Test Variable    ${ALLOWED_FAULTS_LIST}    ${allowed_faults_list}
#    Set MCS Phase And ATT For 9363_B

9363_Case_Teardown
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${swconfig_flag}=${None}
    Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown
    Run Keyword And Ignore Error    Capture Snapshot If Case Failed
    Run Keyword And Continue On Failure     Run Keyword If    '${swconfig_flag}'!='${None}'    Connect to Common Unit Master
    Run Keyword And Continue On Failure     Run Keyword If    '${swconfig_flag}'!='${None}'
    ...    swconf.restore_swConfig_file_on_asik_and_crasign    asik_alias=ASIK Master
    Run Keyword And Continue On Failure     Run Keyword If    '${swconfig_flag}'!='${None}'    Do gNB Reset site and Wait Onair
    Run Keyword And Ignore Error    run    command=ps -ef | grep firefox |awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore Error    mcs_common.Teardown MCS    mcs_index=${1}     mcs_type=${mcs_type}
    Run Keyword And Ignore Error    DingLi_Client.Stop Data Transfer
    Run Keyword And Ignore Error    DingLi_Client.Detach
    Run Keyword And Ignore Error    Common Case Teardown    is_save_snapshot=False
#    Run Keyword And Ignore Error    Capture Snapshot If Case Failed
    Check Whether New Alarm Happened During Running Case    alarm_info_before=${summary_alarm_info}

9363_Suite_Teardown
    [Arguments]    ${swconfig_flag}=${None}
#    Run Keyword If    '${stream}'!='SBTS00'    Run Keyword And Ignore Error    DingLi_Client.Teardown
    Run Keyword And Ignore Error    DingLi_Client.Teardown
    Run Keyword And Continue On Failure     Run Keyword If    '${swconfig_flag}'!='${None}'    Connect to Common Unit Master
    Run Keyword And Continue On Failure     Run Keyword If    '${swconfig_flag}'!='${None}'
    ...    swconf.restore_swConfig_file_on_asik_and_crasign    asik_alias=ASIK Master
    Run Keyword And Continue On Failure     Run Keyword If    '${swconfig_flag}'!='${None}'    Do gNB Reset site and Wait Onair
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM
    robot_common_operations.Common Suite Teardown

9363_D_Case_SetUp
    [Arguments]    ${framestructure}=11160ms    ${update_params}=${None}    ${prachindex_param}=${None}    ${swconfig_flag}=${None}
    robot_common_operations.Common Case Setup    fail_with_alarms=${False}
    ${gnb_allowed_fault_Before_Commission}   Create List    4203    1838    4741    4681   7311   7331
    ...                                                     4293    4297    4420    4775   1932   1934    1933
    Set Test Variable    ${gnb_allowed_fault_Before_Commission}
    AlarmWatchdog.add_allow_alarms    fault_id=${gnb_allowed_fault_Before_Commission}
    Create Case Log Path
#    ${modify_param}    Set Variable If    '${stream}'=='23R1' or '${stream}'=='23R2' or '${stream}'=='23R3'    ${False}    ${True}
    ${cell1_celltypoe_dict}    Catenate
    ...    {"celltype":"16DL8UL", "cell_index":"1","lcelnr_index":"1","rmod_index":"1","rx_channel_number":"8","tx_channel_number":"4"},
    ...    {"celltype":"8DL8UL", "cell_index":"2","lcelnr_index":"2","rmod_index":"2","rx_channel_number":"8","tx_channel_number":"4"},
    ...    {"celltype":"16DL8UL", "cell_index":"3","lcelnr_index":"3","rmod_index":"3","rx_channel_number":"8","tx_channel_number":"4"}
    ${cell1_celltypoe_dict_list}    Evaluate    [${cell1_celltypoe_dict}]
    ${scf_update_with_celltype}    Run Keyword If    '${stream}'=='SBTS25R1'
    ...    update_celltype_for_cells    celltype_info_dict_list=${cell1_celltypoe_dict_list}
    ...                                 basic_scf_path=${Golden_SCF_Path}
    ...                                 update_scf_path=/home/ute/SCF/SCF_${stream}_9363_D_celltype_update.xml
    ${scf_update_with_celltype}    Set Variable If    '${stream}'=='SBTS25R1'    ${scf_update_with_celltype}    ${Golden_SCF_Path}
    ${framestructure}    Set Variable If    '${stream}'=='SBTS25R1'    ${framestructure_${framestructure}}
    ...                                                                ${framestructure_${framestructure}_SBTS00}
     ${whether_do_powersaving_pdcch_modify}    Set Variable If    '${stream}'=='SBTS00' or '${stream}'=='SBTS26R2'    ${True}    ${False}
    ${scf_with_framestructure}    update_framestructure_chbw_pdcch_params    framestructure=${framestructure}
    ...    basic_scf_path=${scf_update_with_celltype}    update_scf_path=/home/ute/SCF/SCF_${stream}_9363_D_framestructure_update.xml
    ...    modify_param=${STREAM_VERSION}
    ...    whether_do_powersaving_pdcch_modify=${whether_do_powersaving_pdcch_modify}
    ${scf_with_update_params}    perform_update_scf_params
    ...                          update_params=${update_params}
    ...                          basic_scf_path=${scf_with_framestructure}
    ...                          update_scf_path=/home/ute/SCF/SCF_${stream}_9363_D_16D8U_update.xml
    ${scf_with_prachindex}    perform_update_scf_params
    ...                       update_params=${prachindex_param}
    ...                       basic_scf_path=${scf_with_update_params}
    ...                       update_scf_path=/home/ute/SCF/SCF_${stream}_9363_D_16D8U_FINAL.xml
    Run Keyword If    '${swconfig_flag}'!='${None}'     Backup and Modify swconfig file
    ...                                                 swconfig_modify=@{SWCONFIG_9363_${swconfig_flag}}
    Perform Commission    scf_file_path=${scf_with_update_params}
    ...                   gnb_index=${0}
    ...                   timeout_for_commission=900
    ...                   wait_gnb_up_timeout=30 min
    ...                   is_pdl_checking_needed=${True}
    ${scf_name}    Set Variable    ${scf_with_update_params.split('/')[-1]}
    copy file    ${scf_with_update_params}     ${TS_CASE_LOG_PATH}/${scf_name}
    ${summary_alarm_info}    Get Active Alarms And Save Summary Infomation
    Set Test Variable    ${summary_alarm_info}
    ${allowed_faults_list}    Combine Current Active Alarm With White List Alarm List
    Set Test Variable    ${ALLOWED_FAULTS_LIST}    ${allowed_faults_list}
    Run Keyword IF    '${STREAM_VERSION}'=='master'    Set MCS Phase And ATT For 9363_E
    ...    ELSE    Set MCS Phase And ATT For 9363_E_24R2
#    Run Keyword IF    '${STREAM_VERSION}'=='master'
#    ...    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=19
#    ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}

Modify and Save SCF
    [Arguments]    ${MOsToAdd}='NULL'
    ...            ${ParamterToModify}=${PARAMS_TO_MODIFY_Channels_For_2T8R}
    ...            ${ListParamterToModify}=${LIST_PARAMS_TO_MODIFY_For_2T8R}
    ...            ${ListToAdd}=${LIST_TO_ADD_SYNC_SOURCE_FRAME}
    ...            ${ParameterToDelete}=${PARAMS_TO_DELETE_TOPP_PARAMS}
    ...            ${scf_path}=${SCF_PATH}commissionings/HGZ/${tmp_testline}/SCF_${stream}_1S-1CC_10708.xml
    ${modified_scf_file_path}    Load SCF and Define modified scf path    scf_path=${scf_path}
    Delete Objects in SCF    parameters_lists=${ParameterToDelete}
    Run Keyword If    not ${MOsToAdd}=='NULL'    Add MOs To SCF with Given version    parameters_lists=${MOsToAdd}
    Add and Modify elements to scf    parameters_lists=${ParamterToModify}
    Modify ListElements to scf    parameters_lists=${ListParamterToModify}
    AddLists to SCF    parameters_lists=${ListToAdd}
    scf.Save scf    ${modified_scf_file_path}
    [Return]    ${modified_scf_file_path}

Load SCF and Define modified scf path
    [Documentation]   Author: lei.jia@nokia-sbell.com
    ...              Description: This keyword load scf and return modified scf path for future use.
    [Arguments]      ${scf_file_name}=${None}
    ...               ${scf_path}=${SCF_PATH}commissionings/HGZ/${tmp_testline}/SCF_${stream}_1S-1CC_10708.xml
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    ${default_scf_file_path}    Copy file    source=${scf_path}    destination=${TS_CASE_LOG_PATH}
    ${scf_file_name}    Fetch from right    ${scf_path}    /
    ${scf_dir_path}    String.Replace string    ${scf_path}    /${scf_file_name}    ${EMPTY}
    ${file_name_without_extention}    String.Replace string    ${scf_file_name}    .xml    ${EMPTY}
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${scf_file_name_after_modify}    catenate  SEPARATOR=${EMPTY}    ${file_name_without_extention}    _${timestamp}_updated.xml
    ${modified_scf_file_path}    set variable    ${TS_CASE_LOG_PATH}/${scf_file_name_after_modify}
    scf.Load scf    ${default_scf_file_path}
    [Return]    ${modified_scf_file_path}

Set MCS Phase And ATT For 9363_E
    ${mcs_type}    mcs_common.Get MCS Type    mcs_index=${1}
    Set Test Variable    ${mcs_type}
    mcs_common.Setup MCS    mcs_type=${mcs_type}    frequency=${None}    mcs_index=${1}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${1}   first_beam_end_output_port=${2}
    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}
    ...    first_beam_horizontal_angle=${-35}    second_beam_horizontal_angle=${-50}    vertical_angle=${-6}
    ...    vertical_distance=${2}    end_input_port=${16}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=5
    ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}    end_input_port=${32}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${5}   first_beam_end_output_port=${6}
    ...    second_beam_begin_output_port=${7}    second_beam_end_output_port=${8}
    ...    first_beam_horizontal_angle=${35}    second_beam_horizontal_angle=${50}    vertical_angle=${-6}
    ...    vertical_distance=${2}    end_input_port=${16}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=25
    ...    first_beam_begin_output_port=${5}    second_beam_end_output_port=${8}    end_input_port=${32}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${9}   first_beam_end_output_port=${10}
    ...    second_beam_begin_output_port=${11}    second_beam_end_output_port=${12}
    ...    first_beam_horizontal_angle=${-7}    second_beam_horizontal_angle=${-15}    vertical_angle=${-6}
    ...    vertical_distance=${2}    end_input_port=${16}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=23
    ...    first_beam_begin_output_port=${9}    second_beam_end_output_port=${12}    end_input_port=${32}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${13}   first_beam_end_output_port=${14}
    ...    second_beam_begin_output_port=${15}    second_beam_end_output_port=${16}
    ...    first_beam_horizontal_angle=${7}    second_beam_horizontal_angle=${22}    vertical_angle=${-6}
    ...    vertical_distance=${2}    end_input_port=${16}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=22
    ...    first_beam_begin_output_port=${13}    second_beam_end_output_port=${16}    end_input_port=${32}

    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=90
    ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}
    ...    begin_input_port=${33}    end_input_port=${64}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=90
    ...    first_beam_begin_output_port=${5}    second_beam_end_output_port=${8}
    ...    begin_input_port=${33}    end_input_port=${64}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=90
    ...    first_beam_begin_output_port=${9}    second_beam_end_output_port=${12}
    ...    begin_input_port=${33}    end_input_port=${64}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=90
    ...    first_beam_begin_output_port=${13}    second_beam_end_output_port=${16}
    ...    begin_input_port=${33}    end_input_port=${64}

Set MCS Phase And ATT For 9363_B
    ${mcs_type}    mcs_common.Get MCS Type    mcs_index=${1}
    Set Test Variable    ${mcs_type}
    mcs_common.Setup MCS    mcs_type=${mcs_type}    frequency=${None}    mcs_index=${1}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${1}   first_beam_end_output_port=${2}
    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}
    ...    first_beam_horizontal_angle=${-25}    second_beam_horizontal_angle=${-45}    vertical_angle=${-6}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=22
    ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${5}   first_beam_end_output_port=${6}
    ...    second_beam_begin_output_port=${7}    second_beam_end_output_port=${8}
    ...    first_beam_horizontal_angle=${35}    second_beam_horizontal_angle=${50}    vertical_angle=${-6}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=35
    ...    first_beam_begin_output_port=${5}    second_beam_end_output_port=${8}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${9}   first_beam_end_output_port=${10}
    ...    second_beam_begin_output_port=${11}    second_beam_end_output_port=${12}
    ...    first_beam_horizontal_angle=${-7}    second_beam_horizontal_angle=${-15}    vertical_angle=${-6}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=32
    ...    first_beam_begin_output_port=${9}    second_beam_end_output_port=${12}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${13}   first_beam_end_output_port=${14}
    ...    second_beam_begin_output_port=${15}    second_beam_end_output_port=${16}
    ...    first_beam_horizontal_angle=${7}    second_beam_horizontal_angle=${22}    vertical_angle=${-6}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=22
    ...    first_beam_begin_output_port=${13}    second_beam_end_output_port=${16}

Activate PRB Blank For 9363_E_006
    Activate PRB Blank For 9915    cell_index=1
    ...                            nbrOfBlankedPRBsHighEdgeDL=9
    ...                            nbrOfBlankedPRBsHighEdgeUL=9
    ...                            nbrOfBlankedPRBsLowEdgeDL=9
    ...                            nbrOfBlankedPRBsLowEdgeUL=9
    ...                            skip_parameter_relation_errors=True
    Modify Parameter cSRS

Set MCS Phase And ATT For 9363_E_24R2
    ${mcs_type}    mcs_common.Get MCS Type    mcs_index=${1}
    Set Test Variable    ${mcs_type}
    mcs_common.Setup MCS    mcs_type=${mcs_type}    frequency=${None}    mcs_index=${1}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${1}   first_beam_end_output_port=${2}
    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}
    ...    first_beam_horizontal_angle=${-30}    second_beam_horizontal_angle=${-45}    vertical_angle=${-6}
    ...    vertical_distance=${2}    end_input_port=${16}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=20
    ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}    end_input_port=${32}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${5}   first_beam_end_output_port=${6}
    ...    second_beam_begin_output_port=${7}    second_beam_end_output_port=${8}
    ...    first_beam_horizontal_angle=${35}    second_beam_horizontal_angle=${50}    vertical_angle=${-6}
    ...    vertical_distance=${2}    end_input_port=${16}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=25
    ...    first_beam_begin_output_port=${5}    second_beam_end_output_port=${8}    end_input_port=${32}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${9}   first_beam_end_output_port=${10}
    ...    second_beam_begin_output_port=${11}    second_beam_end_output_port=${12}
    ...    first_beam_horizontal_angle=${-7}    second_beam_horizontal_angle=${-22}    vertical_angle=${-6}
    ...    vertical_distance=${2}    end_input_port=${16}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=25
    ...    first_beam_begin_output_port=${9}    second_beam_end_output_port=${12}    end_input_port=${32}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${13}   first_beam_end_output_port=${14}
    ...    second_beam_begin_output_port=${15}    second_beam_end_output_port=${16}
    ...    first_beam_horizontal_angle=${7}    second_beam_horizontal_angle=${22}    vertical_angle=${-6}
    ...    vertical_distance=${2}    end_input_port=${16}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=25
    ...    first_beam_begin_output_port=${13}    second_beam_end_output_port=${16}    end_input_port=${32}

    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=90
    ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}
    ...    begin_input_port=${33}    end_input_port=${64}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=90
    ...    first_beam_begin_output_port=${5}    second_beam_end_output_port=${8}
    ...    begin_input_port=${33}    end_input_port=${64}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=90
    ...    first_beam_begin_output_port=${9}    second_beam_end_output_port=${12}
    ...    begin_input_port=${33}    end_input_port=${64}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=90
    ...    first_beam_begin_output_port=${13}    second_beam_end_output_port=${16}
    ...    begin_input_port=${33}    end_input_port=${64}


