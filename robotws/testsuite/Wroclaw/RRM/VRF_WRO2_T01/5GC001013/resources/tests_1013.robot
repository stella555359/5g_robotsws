# robocop: disable=not-allowed-char-in-name
*** Settings ***
Documentation
...  author:        Damian Matusiak
...  contact:       damian.matusiak@nokia.com
...  maintainer:    damian.matusiak@nokia.com
...  description:   This user scenario describes the gNB behaviour, to release the MeNB configured measurement gap
...                 during SgNB Modification procedure. The DRX will be reconfigured after the measurement gap is
...                 released if it was released during the measurement gap setup in SgNB. The SgNB Modification
...                 procedure is supported by 5GC000575. For this use scenario, please refer to 5GC000575-B#B2: SgNB
...                 Modification support to change the SCG configuration at SgNB (without PSCell change)
...                 [5G_RAN_USR_5200] for more details..

Library         taf.ue
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/5GC001013/resources/keywords.robot


*** Variables ***
${scf_path_branch}      commissionings/RRM/WRO_RRM9/AHLOA_CLASS041/7_16_UTE5G286CLASS041_SCF_AHLOA_branch.xml
${scf_path_trunk}       commissionings/RRM/WRO_RRM9/AHLOA_CLASS041/7_16_UTE5G286CLASS041_SCF_AHLOA_trunk.xml
@{lines_cell1_5G}       1    2    3    4
@{lines_cell2_5G}       5    6    7    8
@{lines_cell3_5G}       9    10   11   12
@{lines_cell1_LTE}      13   14
@{lines_cell2_LTE}      15   16
@{slots_not_expected}   20    21    22    23    24
${loop_count}           20


*** Keywords ***
[1]5GC001013-A.B1_FDD_RRM_Classical_MG_setup_SgNB_Modification_noDRX_CP
    [Documentation]
    ...     Description: The purpose of this test is the measurement gap release during SgNB modification procedure
    ...     when DRX is not configured. This test consists in checking CP messages exchanged on X2, F1, Uu interfaces.
    ${status}    Run keyword and ignore error    5GC001013-A.B1_noDRX    version=1
    Run keyword if    '${status[0]}'=='FAIL'    Run keywords
    ...            Log to console    \nTest result: ${status[1]}\n __Repeating test...\n    AND
    ...            5GC001013-A.B1_noDRX    version=2
    [Teardown]    Move logs to test folder 1013

[1]5GC001013-A.B1_FDD_RRM_Classical_MG_setup_SgNB_Modification_DRX_CP
    Log to console  [1]5GC001013-A.B1_FDD_RRM_Classical_MG_setup_SgNB_Modification_DRX_CP
    Run keyword if  '${tl.gnbs[0].instance_id}'=='50041'
    ...             A_B1_DRX_CP_TL041
    ...             ELSE
    ...             A_B1_DRX_CP
    [Teardown]    Move logs to test folder 1013

[1]5GC001013-A.B2_FDD_RRM_Classical_MG_setup_SgNB_Addition_CP
    [Tags]  CDRT
    Log to console  [1]5GC001013-A.B2_FDD_RRM_Classical_MG_setup_SgNB_Addition_CP
    Run keyword if  '${tl.gnbs[0].instance_id}'=='50041'
    ...             A_B2_Addition_CP_TL041
    ...             ELSE
    ...             A_B2_Addition_CP
    [Teardown]    Move logs to test folder 1013

[1]5GC001013-A.B4_FDD_RRM_Classical_MG_ setup_SgNB_intraDU_PSCell_Change_A3_SRB1_X2_CP
    Commissioning for X2
    Perform commissioning 1013
    ...                 srb3SupportEnabled=false
    ...                 a3MeasEnabled=rsrp
    ...                 a5MeasEnabled=rsrp
    ...                 actIntraFreqIntraGnbMobilityNSA=true
    ...                 enDcSyncStatus=synchronous
    ...                 actCDrx=false
    ...                 option=B4
    Set cells for 1013
    PSCellChange attenuation setup
#    Start L1L2 logs gathering    time=250
    Start tcpdump on gnb ASIK master
    Attach to lte cell
    Start throughput    duration=110s
    Perform PSCellChange
    Attenuate lte cell for MeasGap    ${lines_cell1_LTE}    ${lines_cell2_LTE}
    Perform PSCellChange
    Stop throughput
    Wait for counters   sleep_timer=60s
    ${pcap_path}  Stop pcap collection in gNB ASIK master
#    Stop L1L2 logs gathering and download pcap    time=5
    Check pcap    option=B4    event_id=3  path=${pcap_path}
    [Teardown]    Move logs to test folder 1013

[1]5GC001013-A.B4_FDD_RRM_Classical_MG_ setup_SgNB_intraDU_PSCell_Change_A3_SRB3_CP
    [Documentation]
    ...     This TC requires Mediatek with srb3 support
    [Tags]    MediaTek
    taf.ue.Stop using ue    AT_BASED_UE_1
    taf.ue.Require Ue       AT_BASED_UE_1  capabilities=Mediatek
    Commissioning for X2
    Perform commissioning 1013
    ...                 srb3SupportEnabled=true
    ...                 a3MeasEnabled=rsrp
    ...                 a5MeasEnabled=rsrp
    ...                 actIntraFreqIntraGnbMobilityNSA=true
    ...                 enDcSyncStatus=synchronous
    ...                 actCDrx=false
    ...                 option=B4
    Set cells for 1013
    PSCellChange attenuation setup
#    Start L1L2 logs gathering    time=250
    Start tcpdump on gnb ASIK master
    Attach to lte cell
    Start throughput    duration=110s
    Perform PSCellChange
    Attenuate lte cell for MeasGap    ${lines_cell1_LTE}    ${lines_cell2_LTE}
    Perform PSCellChange
    Stop throughput
    Wait for counters   sleep_timer=60s
    ${pcap_path}  Stop pcap collection in gNB ASIK master
#    Stop L1L2 logs gathering and download pcap    time=5
    Check pcap    option=B4    event_id=3    srb3=${TRUE}  path=${pcap_path}
    [Teardown]    Move logs to test folder 1013

[1]5GC001013-A.B4_FDD_RRM_Classical_MG_ setup_SgNB_intraDU_PSCell_Change_A5_SRB1_X2_CP
    Commissioning for X2
    Perform commissioning 1013
    ...                 srb3SupportEnabled=false
    ...                 a3MeasEnabled=rsrp
    ...                 a5MeasEnabled=rsrp
    ...                 actIntraFreqIntraGnbMobilityNSA=true
    ...                 enDcSyncStatus=synchronous
    ...                 actCDrx=false
    ...                 option=B4
    Set cells for 1013
    PSCellChange attenuation setup
#    Start L1L2 logs gathering    time=250
    Start tcpdump on gnb ASIK master
    Attach to lte cell
    Start throughput    duration=110s
    Perform PSCellChange
    Attenuate lte cell for MeasGap    ${lines_cell1_LTE}    ${lines_cell2_LTE}
    Perform PSCellChange
    Stop throughput
    Wait for counters   sleep_timer=60s
    ${pcap_path}  Stop pcap collection in gNB ASIK master
#    Stop L1L2 logs gathering and download pcap    time=5
    Check pcap    option=B4    event_id=5  path=${pcap_path}
    [Teardown]    Move logs to test folder 1013

[1]5GC001013-B#B1_01_FDD_Classical_MG_release_during_SgNB_Modification_noDRX_offSRB3_CP
    ${status}    Run keyword and ignore error    5GC001013-B#B1_01    version=1
    Run keyword if    '${status[0]}'=='FAIL'    Run keywords
    ...            Log to console    \nTest result: ${status[1]}\n __Repeating test...\n    AND
    ...            5GC001013-B#B1_01    version=2
    [Teardown]    Move logs to test folder 1013

[1]5GC001013-B#B1_03_FDD_Classical_MG_release_during_SgNB_Modification_activDRX_offSRB3_CP
     ${status}    Run keyword and ignore error    5GC001013-B#B1_03    version=1
     Run keyword if    '${status[0]}'=='FAIL'    Run keywords
     ...            Log to console    \nTest result: ${status[1]}\n __Repeating test...\n    AND
     ...            5GC001013-B#B1_03    version=2
    [Teardown]    Move logs to test folder 1013

[1]5GC001013-B#B1_05_FDD_Classical_MG_release_during_SgNB_Modification_activDRX_onSRB3_CP
    [Documentation]
    ...     This TC requires Mediatek with srb3 support
    [Tags]    MediaTek
    taf.ue.Stop using ue    AT_BASED_UE_1
    taf.ue.Require Ue       AT_BASED_UE_1  capabilities=Mediatek
    ${status}    Run keyword and ignore error    5GC001013-B#B1_05    version=1
    Run keyword if    '${status[0]}'=='FAIL'    Run keywords
    ...            Log to console    \nTest result: ${status[1]}\n __Repeating test...\n    AND
    ...            5GC001013-B#B1_05    version=2
    [Teardown]    Move logs to test folder 1013

[1][1.0]5GC001013-D#B1_03_FDD_Classical_CSI-Report_Meas-Gap_Collision_during_SgNB_Modification
    Perform commissioning 1013
    ...                 csiReportPeriodicity=slots320
    ...                 lteToNrTimeOffset=0
    Gnb reset
    Set cells for 1013
    Set attenuation and check    lines=@{lines_cell1_LTE}    value=90
#    Start L1L2 logs gathering    time=190
    Start tcpdump on gnb ASIK master
    Attach to lte cell
    Repeat keyword    ${loop_count}    Run keywords
    ...               Set attenuation and check    lines=@{lines_cell1_LTE}    value=0     AND
    ...               Set attenuation and check    lines=${lines_cell2_LTE}    value=17    AND
    ...               Sleep    2s    AND
    ...               Set attenuation and check    lines=@{lines_cell2_LTE}    value=0    AND
    ...               Set attenuation and check    lines=${lines_cell1_LTE}    value=17    AND
    ...               Sleep    2s
    Wait for counters   sleep_timer=30s
    ${pcap_path}  Stop pcap collection in gNB ASIK master
#    Stop L1L2 logs gathering and download pcap    time=5
    Check pcap     option=D1              path=${pcap_path}
    Check slots    ${slots_not_expected}  path=${pcap_path}
    [Teardown]    Move logs to test folder 1013

[1][1.0]5GC001013-D#B2_03_FDD_Classical_CSI-Report_Meas-Gap_Collision_during_SgNB_Addition
    Perform commissioning 1013
    ...                 csiReportPeriodicity=slots320
    ...                 lteToNrTimeOffset=0
    Gnb reset
    Set cells for 1013
    Attenuate lte cell for SgNB Addition
#    Start L1L2 logs gathering    time=450
    Start tcpdump on gnb ASIK master
    Repeat keyword    ${loop_count}
    ...               Attach and detach UE
    Wait for counters   sleep_timer=30s
    ${pcap_path}  Stop pcap collection in gNB ASIK master
#    Stop L1L2 logs gathering and download pcap    time=5
    Check pcap     option=D2              path=${pcap_path}
    Check slots    ${slots_not_expected}  path=${pcap_path}
    [Teardown]    Move logs to test folder 1013

[1][1.0]5GC001013-D#B4_02_FDD_Classical_CSI-Report_Meas-Gap_Collision_during_Intra-DU_PSCell_Change
    Perform commissioning 1013
    ...                 csiReportPeriodicity=slots320
    ...                 lteToNrTimeOffset=0
    Gnb reset
    Set cells for 1013
    PSCellChange attenuation setup
#    Start L1L2 logs gathering    time=230
    Start tcpdump on gnb ASIK master
    Attach to lte cell
    Perform PSCellChange
    Attenuate lte cell for MeasGap    ${lines_cell1_LTE}    ${lines_cell2_LTE}
    Repeat keyword    ${loop_count}    Perform PSCellChange
    Wait for counters   sleep_timer=30s
    ${pcap_path}  Stop pcap collection in gNB ASIK master
#    Stop L1L2 logs gathering and download pcap    time=5
    Check pcap     option=D4              path=${pcap_path}
    Check slots    ${slots_not_expected}  path=${pcap_path}
    [Teardown]    Move logs to test folder 1013


*** Keywords ***
A_B1_DRX_CP
    ${status}    Run keyword and ignore error    5GC001013-A.B1_DRX    version=1
    Run keyword if    '${status[0]}'=='FAIL'    Run keywords
    ...            Log to console    \nTest result: ${status[1]}\n __Repeating test...\n    AND
    ...            5GC001013-A.B1_DRX    version=2

A_B2_Addition_CP
    Perform commissioning 1013
    ...                 srb3SupportEnabled=false
    ...                 enDcSyncStatus=synchronous
    ...                 actCDrx=false
    Set cells for 1013
    Attenuate lte cell for SgNB Addition
#    Start L1L2 logs gathering    time=170
    Start tcpdump on gnb ASIK master
    Attach to lte cell
    Sleep    5s
    Start throughput
    Stop throughput
    Wait for counters   sleep_timer=60s
    ${pcap_path}  Stop pcap collection in gNB ASIK master
#    Stop L1L2 logs gathering and download pcap    time=5
    Check pcap    option=B2_A  path=${pcap_path}

A_B1_DRX_CP_TL041
    Perform commissioning 1013
    ...                 srb3SupportEnabled=false
    ...                 enDcSyncStatus=synchronous
    ...                 actCDrx=true
    Set cells for 1013
    Set attenuation and check    lines=${lines_cell1_5G}     value=90
    Set attenuation and check    lines=${lines_cell2_5G}     value=90
    Set attenuation and check    lines=${lines_cell3_5G}     value=90
    Set attenuation and check    lines=${lines_cell1_LTE}    value=0
    Set attenuation and check    lines=${lines_cell2_LTE}    value=90
    Start tcpdump on gnb ASIK master
#    Start L1L2 logs gathering    time=10  bb_slot_1=false  bb_slot_2=true  filter=${ABIL_FILTER}
    Attach to lte cell
    Sleep    5s
    Set attenuation and check    lines=${lines_cell1_LTE}    value=10
    Set attenuation and check    lines=${lines_cell2_5G}     value=30
    Start throughput
    Stop throughput
    Wait for counters   sleep_timer=30s
#    Stop L1L2 logs gathering and download pcap
    ${pcap_path}  Stop pcap collection in gNB ASIK master
    Check pcap    option=B1    DRX=${TRUE}  path=${pcap_path}
    [Teardown]    Run keywords
    ...           Unlock all cells      AND
    ...           Turn off attenuation

A_B2_Addition_CP_TL041
    Perform commissioning 1013
    ...                 srb3SupportEnabled=false
    ...                 enDcSyncStatus=synchronous
    ...                 actCDrx=false
    Set cells for 1013
    Set attenuation and check    lines=${lines_cell1_5G}     value=90
    Set attenuation and check    lines=${lines_cell2_5G}     value=90
    Set attenuation and check    lines=${lines_cell3_5G}     value=90
    Set attenuation and check    lines=${lines_cell1_LTE}    value=0
    Set attenuation and check    lines=${lines_cell2_LTE}    value=90
    #    Start L1L2 logs gathering    time=10  bb_slot_1=false  bb_slot_2=true  filter=${ABIL_FILTER}
    Start tcpdump on gnb ASIK master
    Attach to lte cell
    Sleep    5s
    Set attenuation and check    lines=${lines_cell1_LTE}    value=10
    Set attenuation and check    lines=${lines_cell2_5G}     value=30
    Start throughput
    Stop throughput
    Wait for counters   sleep_timer=60s
#    Stop L1L2 logs gathering and download pcap
    ${pcap_path}  Stop pcap collection in gNB ASIK master
    Check pcap    option=B2_A  path=${pcap_path}

5GC001013-A.B1_noDRX
    [Arguments]    ${version}=1
    Perform commissioning 1013
    ...                 srb3SupportEnabled=false
    ...                 enDcSyncStatus=synchronous
    ...                 actCDrx=false
    Set cells for 1013
    Run keyword if    ${version}==1
    ...         Set attenuation and check    lines=${lines_cell1_LTE}    value=90
    ...      ELSE
    ...         Set attenuation and check    lines=${lines_cell2_LTE}    value=90
#    Start L1L2 logs gathering    time=150
    Start tcpdump on gnb ASIK master
    Attach to lte cell
    Sleep    5s
    Run keyword if    ${version}==1
    ...         Set attenuation and check    lines=${lines_cell2_LTE}    value=25
    ...      ELSE
    ...         Set attenuation and check    lines=${lines_cell1_LTE}    value=25
    Start throughput
    Stop throughput
    Wait for counters   sleep_timer=30s
    ${pcap_path}  Stop pcap collection in gNB ASIK master
#    Stop L1L2 logs gathering and download pcap    time=5
    Check pcap    option=B1  path=${pcap_path}
    [Teardown]    Run keywords
    ...               Unlock all cells      AND
    ...               Turn off attenuation

5GC001013-A.B1_DRX
    [Arguments]    ${version}=1
    Perform commissioning 1013
    ...                 srb3SupportEnabled=false
    ...                 enDcSyncStatus=synchronous
    ...                 actCDrx=true
    Set cells for 1013
    Run keyword if    ${version}==1
    ...         Set attenuation and check    lines=${lines_cell1_LTE}    value=90
    ...      ELSE
    ...         Set attenuation and check    lines=${lines_cell2_LTE}    value=90
#    Start L1L2 logs gathering    time=150
    Start tcpdump on gnb ASIK master
    Attach to lte cell
    Sleep    5s
    Start throughput
    Stop throughput
    Run keyword if    ${version}==1
    ...         Set attenuation and check    lines=${lines_cell2_LTE}    value=25
    ...      ELSE
    ...         Set attenuation and check    lines=${lines_cell1_LTE}    value=25
    Start throughput
    Stop throughput
    Wait for counters   sleep_timer=30s
    ${pcap_path}  Stop pcap collection in gNB ASIK master
#    Stop L1L2 logs gathering and download pcap    time=5
    Check pcap    option=B1    DRX=${TRUE}  path=${pcap_path}
    [Teardown]    Run keywords
    ...               Unlock all cells      AND
    ...               Turn off attenuation

5GC001013-B#B1_01
    [Arguments]    ${version}=1
    Perform commissioning 1013
    ...                   srb3SupportEnabled=false
    ...                   enDcSyncStatus=synchronous
    ...                   actCDrx=false
    Set cells for 1013
    Run keyword if    ${version}==1
    ...         Set attenuation and check    lines=${lines_cell1_LTE}    value=90
    ...      ELSE
    ...         Set attenuation and check    lines=${lines_cell2_LTE}    value=90
#    Start L1L2 logs gathering    time=160
    Start tcpdump on gnb ASIK master
    Attach to lte cell
    Sleep    5s
    Run keyword if    ${version}==1
    ...         Set attenuation and check    lines=${lines_cell2_LTE}    value=25
    ...      ELSE
    ...         Set attenuation and check    lines=${lines_cell1_LTE}    value=25
    Start throughput
    sleep    5s
    Run keyword if    ${version}==1
    ...         Set attenuation and check    lines=${lines_cell2_LTE}    value=0
    ...      ELSE
    ...         Set attenuation and check    lines=${lines_cell1_LTE}    value=0
    Stop throughput
    Wait for counters   sleep_timer=30s
    ${pcap_path}  Stop pcap collection in gNB ASIK master
#    Stop L1L2 logs gathering and download pcap    time=5
    Check pcap    option=B1  path=${pcap_path}
    [Teardown]    Run keywords
    ...               Unlock all cells      AND
    ...               Turn off attenuation

5GC001013-B#B1_03
    [Arguments]    ${version}=1
    Perform commissioning 1013
    ...                   srb3SupportEnabled=false
    ...                   enDcSyncStatus=synchronous
    ...                   actCDrx=true
    Set cells for 1013
    Run keyword if    ${version}==1
    ...         Set attenuation and check    lines=${lines_cell1_LTE}    value=90
    ...      ELSE
    ...         Set attenuation and check    lines=${lines_cell2_LTE}    value=90
#    Start L1L2 logs gathering    time=175
    Start tcpdump on gnb ASIK master
    Attach to lte cell
    Sleep    5s
    Start throughput    duration=10s
    Stop throughput
    Start throughput
     Run keyword if    ${version}==1
    ...         Set attenuation and check    lines=${lines_cell2_LTE}    value=25
    ...      ELSE
    ...         Set attenuation and check    lines=${lines_cell1_LTE}    value=25
    Sleep    5
    Run keyword if    ${version}==1
    ...         Set attenuation and check    lines=${lines_cell2_LTE}    value=0
    ...      ELSE
    ...         Set attenuation and check    lines=${lines_cell1_LTE}    value=0
    Stop throughput
    Wait for counters   sleep_timer=30s
    ${pcap_path}  Stop pcap collection in gNB ASIK master
#    Stop L1L2 logs gathering and download pcap    time=5
    Check pcap    option=B1    DRX=${TRUE}  path=${pcap_path}
    [Teardown]    Run keywords
    ...               Unlock all cells      AND
    ...               Turn off attenuation

5GC001013-B#B1_05
    [Arguments]    ${version}=1
    Perform commissioning 1013
    ...                   srb3SupportEnabled=false
    ...                   enDcSyncStatus=synchronous
    ...                   actCDrx=true
    Set cells for 1013
    Run keyword if    ${version}==1
    ...         Set attenuation and check    lines=${lines_cell2_LTE}    value=90
    ...      ELSE
    ...         Set attenuation and check    lines=${lines_cell1_LTE}    value=90
#    Start L1L2 logs gathering    time=175
    Start tcpdump on gnb ASIK master
    Attach to lte cell
    Sleep    5s
    Start throughput    duration=10s
    Stop throughput
    Run keyword if    ${version}==1
    ...         Set attenuation and check    lines=${lines_cell1_LTE}    value=25
    ...      ELSE
    ...         Set attenuation and check    lines=${lines_cell2_LTE}    value=25
    Sleep    5
    Run keyword if    ${version}==1
    ...         Set attenuation and check    lines=${lines_cell1_LTE}    value=0
    ...      ELSE
    ...         Set attenuation and check    lines=${lines_cell2_LTE}    value=0
    Wait for counters   sleep_timer=30s
    ${pcap_path}  Stop pcap collection in gNB ASIK master
#    Stop L1L2 logs gathering and download pcap    time=5
    Check pcap    option=B1    DRX=${TRUE}    srb3=${TRUE}  path=${pcap_path}
    [Teardown]    Run keywords
    ...               Unlock all cells      AND
    ...               Turn off attenuation
