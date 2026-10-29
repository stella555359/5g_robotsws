*** Settings ***

Documentation
...    author: keyu.du
...    contact: keyu.a.du@nokia-sbell.com
...    squad group: RAN_L3_SW_CN_2
...    Feature CB008285 in TRUNK program

Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs

Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS23R4    RAN_5G    RAN_5G_TDD    team-Beam    owner-keyu.a.du
...    CLOUD_5G_I_BOO_AP_LOO    CRT    CB008285    release-SBTS23R4
...    STATE_CONFIGURED    5G_RAN    5G_RAN_TDD

Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${OOO_ue_nr_capabilities}
...    SEPARATOR=
...    E1A27000574F7603560003C42800580F40000980219008120C7A023D801E099321CF916BD055EC12F40CFB027C0F1E238F23CFB1E7D812647
...    BF41DFB06FD8246C69F640FB049D834EC1AF62CF920020301262C011306E412006341A0140601CCE00540B40378E3087000A8F3F1436011FB
...    660AA40078F0021C4002115028FDFC8106400000C00600385C2168800300080400006806A0740050C000401503A0060C008200A83D00000C8
...    000004200801820100105C800740700D8E3C5806C71E2C20D8E3C50A40340002000C00620001000600310000800300187A0B100F801C01000
...    40500603009401800180F80524A00C00000000003925000000724A01C000000000000000000003001BA400810040000000004100000000010
...    4030000000000000010015DA816809C0110080400090840014401010000000000008000000000004000000000000800200400840401002010
...    0400000200C01814294404008D00

@{PARAMS_IN_SCF}
...    @{32SSB}
...    @{CB008285_enable_parameter}
...    @{CB008285_a_sansa_enable}

@{32SSB}
...    NRCELL:actBeamforming=true
...    NRCELL:beamSet:basicBeamSet=beamSetAbf_32A
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=32 beams
...    NRCELLGRP-1:numberOfTransmittedSsBlocks=32 beams
...    NRSYSINFO_PROFILE-1/NRIAFIM-1:numberOfTransmittedSsBlocks=32 beams
...    NRSYSINFO_PROFILE-1/NRIRFIM-1:numberOfTransmittedSsBlocks=32 beams
...    NRSYSINFO_PROFILE-1:systemInformationTargetRate=50

@{CB008285_enable_parameter}
...    NRBTS-1/NRPMRNL-1:miNrInterGnbMobilityNsaPmqap=disabled
...    NRBTS-1/NRPMRNL-1:miNrInterGnbNgMobilitySaPmqap=disabled
...    NRBTS-1/NRPMRNL-1:miNrInterGnbXnMobilitySaPmqap=disabled
...    NRBTS-1/NRPMRNL-1:miNrIntraGnbMobilityNsaPmqap=disabled
...    NRBTS-1/NRPMRNL-1:miNrIntraGnbMobilitySaPmqap=disabled
...    NRBTS-1/NRPMRNL-1:miNrNgcFlexInterface=disabled
...    NRBTS-1/NRPMRNL-1:miNrRelReportCu=disabled
...    NRBTS-1/NRPMRNL-1:miNrMeasProfileInterFreq=disabled
...    NRBTS-1/NRPMRNL-1:miNrMeasProfileInterRat=disabled
...    NRBTS-1/NRPMRNL-1:miNrMeasProfileIntraFreq=disabled
...    NRBTS-1/NRPMRNL-1:miNrMeasProfileMappingSA=disabled
...    NRBTS-1/NRPMRNL-1:miNrMeasProfileMappingNSA=disabled

@{CB008285_a_sansa_enable}
...    NRBTS-1:actFr2Sa=true
...    NRBTS-1:gNbCuType=SA+NSA
...    NRBTS-1:x2LinkSupervisionTmr=3
...    NRBTS-1:actSplitNrEutraUeCapa=true
...    NRCELL-1:cellDepType=NSA
...    NRCELL-2:cellDepType=NSA
...    NRCELL-1:configuredEpsTac=222
...    NRCELL-2:configuredEpsTac=222
...    delete:NRCELL-1:trackingAreaDN
...    delete:NRCELL-2:trackingAreaDN
...    delete:NRCELL:ranAC
...    delete:NRCELL-1:sCellOnlyFr2Sa
...    delete:NRCELL-2:sCellOnlyFr2Sa
...    NRCELL:actCsiResAllocOptList=disabled
...    NRCELL:actOsiMismatchCheck=false
...    NRCELL:actLongPucchResourceOpt=false
...    NRCELL:eblRplCellSelectionWithCA=false
#...    NRCELL:actSmallestRRCSetup=true

@{CB008285_B_20_lock_nsa_para}
...    NRBTS-1/NRCELL-1:administrativeState=Locked
...    NRBTS-1/NRCELL-2:administrativeState=Locked

@{CB008285_B_20_lock_sa_para}
...    NRBTS-1/NRCELL-3:administrativeState=Locked
...    NRBTS-1/NRCELL-4:administrativeState=Locked

@{CB008285_B_20_para}
...    NRBTS-1/NRCELL-1:administrativeState=Unlocked
...    NRBTS-1/NRCELL-3:administrativeState=Unlocked
...    NRBTS-1/NRCELL-2:administrativeState=Unlocked
...    NRBTS-1/NRCELL-4:administrativeState=Unlocked

@{CB008285_B_20_unlock_nsa_para}
...    NRBTS-1/NRCELL-1:administrativeState=Unlocked
...    NRBTS-1/NRCELL-2:administrativeState=Unlocked

@{CB008285_B_20_unlock_sa_para}
...    NRBTS-1/NRCELL-3:administrativeState=Unlocked
...    NRBTS-1/NRCELL-4:administrativeState=Unlocked

*** Test Cases ***
CB008285_B_20_2498_A004_Verified_SA_F1_reset_not_trigger_X2_reset
    [Documentation]    This case test scenario when SA Cell F1 reset not triggers X2 reset
    ...    NSA FR2 NRCELL-1&2 OnAir & NSA UE Attached
    ...    SA FR2 NRCELL-3&4 OnAir
    ...    Trigger F1 Reset by Lock NSA FR2 NRCELL-1&2
    ...    F1 Reset & trigger X2 reset, E1 reset NSA UE Context Release.
    ...    Recover with Unlock NSA FR2 NRCELL-1&2
    ...    Trigger F1 Reset by Lock SA FR2 NRCELL-3&4
    ...    F1 Reset & not trigger X2 reset, no E1 Reset.
    ...    Recover with Unlock SA FR2 NRCELL-3&4
    ...
    Set Parameter    para=${CB008285_B_20_para}
    UE attach and Start traffic
    ...    ue_id=82    cell_id=3     pdu_id=1    qfi_id=1    nwslice_id=1    gw_id=1    dl_tp=20    ul_tp=20
    ...    duration=${5}    trf_id=1
    F1 Link Reset by LockUnlock nsa FR2 Cell
    ...    ue_id=91     cell_id=1
    F1 Link Reset by LockUnlock sa FR2 Cell
    ...    ue_id=91     cell_id=1
    Check WireShark Log    a2a_ini_file=${CURDIR}${/}a2a_CB008285_20${/}a2a.ini
    ...    wait_string=UEContextReleaseComplete::4

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sa_mmwv/FS/4cells_4T

Set Parameter
    [Arguments]    ${para}=${EMPTY}
    Execute Egate Command    enb_x2_link_up enb=1 target=2    is up
    OnlineParamChange    ${para}

F1 Link Reset by LockUnlock sa FR2 Cell
    [Arguments]    ${ue_id}=91    ${cell_id}=1
    Start To Capture Wireshark Log    saF1Reset_CB008285_B_20
    Sleep    5s    wait wireshark log collecting
    Attach UE and setup EN-DC    ${ue_id}     ${cell_id}
    Trigger F1 link reset by lock cell CB008285_B_20_lock_sa
    Sleep    10s    wait wireshark log collecting
    Trigger F1 link setup and wait eNB onair CB008285_B_20_unlock_sa
    Stop Capture Wireshark Log    saF1Reset_CB008285_B_20
    UE Detach From eNB    ${ue_id}

F1 Link Reset by LockUnlock nsa FR2 Cell
    [Arguments]    ${ue_id}=91    ${cell_id}=1
    Start To Capture Wireshark Log    nsaF1Reset_CB008285_B_20
    Sleep    5s    wait wireshark log collecting
    Execute Egate Command    enb_x2_link_up enb=1 target=2    is up
    Sleep    2s    wait x2 link up
    Attach UE and setup EN-DC    ${ue_id}     ${cell_id}
    Trigger F1 link reset by lock cell CB008285_B_20_lock_nsa
    Trigger F1 link setup and wait eNB onair CB008285_B_20_unlock_nsa
    Stop Capture Wireshark Log    nsaF1Reset_CB008285_B_20
    UE Detach From eNB    ${ue_id}
    Execute Egate Command    enb_x2_link_up enb=1 target=2    is up

Attach UE and setup EN-DC
    [Arguments]
    ...    ${ue_id}=1     ${cell_id}=1
    Execute Egate Command    ue_attach id=${ue_id} profile=1    UE IS ACTIVE    timeout=20s
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${cell_id} bearer=2 type=split_scg
    ...    successful RA    timeout=20s
    Sleep    2s    wait nsa attach

UE Detach From eNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_detach id=${ue_id}    detached

Trigger F1 link reset by lock cell CB008285_B_20_lock_nsa
    Delta Commission Parameters    ${CB008285_B_20_lock_nsa_para}
    Cell Should Be Locked    ${CB008285_B_20_lock_nsa_para[0].split(':')[0][-1]}
    Cell Should Be Locked    ${CB008285_B_20_lock_nsa_para[0].split(':')[0][-1]}
    Sleep    1min    wait Delta Commissioning finished and wireshark log collecting

Trigger F1 link reset by lock cell CB008285_B_20_lock_sa
    Delta Commission Parameters    ${CB008285_B_20_lock_sa_para}
    Cell Should Be Locked    ${CB008285_B_20_lock_sa_para[0].split(':')[0][-1]}
    Cell Should Be Locked    ${CB008285_B_20_lock_sa_para[0].split(':')[0][-1]}
    Sleep    1min    wait Delta Commissioning finished and wireshark log collecting

Trigger F1 link setup and wait eNB onair CB008285_B_20_unlock_nsa
    OnlineParamChange    ${CB008285_B_20_unlock_nsa_para}

Trigger F1 link setup and wait eNB onair CB008285_B_20_unlock_sa
    OnlineParamChange    ${CB008285_B_20_unlock_sa_para}

UE attach and Start traffic
    [Arguments]
    ...    ${ue_id}=81    ${cell_id}=1    ${pdu_id}=1    ${qfi_id}=1    ${nwslice_id}=1    ${gw_id}=1
    ...    ${dl_tp}=${70}    ${ul_tp}=${10}    ${duration}=${10}    ${trf_id}=1
    SA UE Attach    ue_id=${ue_id}    cell_id=${cell_id}    pdu_id=${pdu_id}    nwslice_id=${nwslice_id}
    ...    gw_id=${gw_id}
    Send And Verify Throuput    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    ...    send_dl=${dl_tp}    send_ul=${ul_tp}    sleep_time=${duration}s    trf_id=${trf_id}
    ...    trf_dir=uldl

onlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Wait Until Keyword Succeeds    15x    30s    NR Cells Should Be OnAir

NR Cells Should Be OnAir
    ${bts_info}    Get Bts Info
    ${cells_list}    Get From Dictionary    ${bts_info['cells']}    nr
    FOR    ${cell}    IN    @{cells_list}
        Should Be Equal    ${cell['status']['operationalState']}    enabled
        Should Be Equal    ${cell['status']['usageState']}    Active
    END

SA UE Attach
    [Arguments]    ${ue_id}    ${cell_id}    ${pdu_id}    ${nwslice_id}    ${gw_id}
    ...    ${pass_regexp}=Created FiveQi:Qfi mapping fiveQi
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
    Execute Egate Command    ue_register id=${ue_id}    is now Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} gw=${gw_id} ue=${ue_id} nwslice=${nwslice_id}
    ...    pass_regexp=${pass_regexp}

Start Trf Traffic ul
    # Invoke Keyword: Send And Verify Throuput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1    ${send_dl}=10    ${send_ul}=10    ${trf_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul trf_id=${trf_id} mbps=${send_ul}

Start Trf Traffic dl
    # Invoke Keyword: Send And Verify Throuput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1    ${send_dl}=10    ${send_ul}=10    ${trf_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl trf_id=${trf_id} mbps=${send_dl}

Start Trf Traffic uldl
    # Invoke Keyword: Send And Verify Throuput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1    ${send_dl}=10    ${send_ul}=10    ${trf_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul trf_id=${trf_id} mbps=${send_ul}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl trf_id=${trf_id} mbps=${send_dl}

Send And Verify Throuput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1    ${send_dl}=0    ${send_ul}=0    ${sleep_time}=20s
    ...     ${trf_id}=1    ${trf_dir}=dl
    FOR    ${n_qfi_id}    IN    @{qfi_id.split(",")}
        Run Keyword    Start Trf Traffic ${trf_dir}
        ...    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=${n_qfi_id}
        ...    send_dl=${send_dl}    send_ul=${send_ul}    trf_id=${trf_id}
    END
    ${dl_threshold}    Evaluate    ${send_dl}*0.9
    ${ul_threshold}    Evaluate    ${send_ul}*0.9

    FOR    ${n_qfi_id}    IN    @{qfi_id.split(",")}
        Verify Throuput    ${ue_id}    ${pdu_id}    ${n_qfi_id}    ${dl_threshold}    ${ul_threshold}    ${sleep_time}
    END

Verify Throuput
    [Arguments]    ${ue_id}    ${pdu_id}    ${qfi_id}    ${Tput_dl}    ${Tput_ul}    ${sleep_time}
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>=${Tput_dl}
    Should Be True    ${ul_throughput}/1000>=${Tput_ul}

Modify Cfg
    Update Cfg    ue_param id=81 ue_nr_capabilities=${OOO_ue_nr_capabilities}
    Update Cfg    ue_param id=82 ue_nr_capabilities=${OOO_ue_nr_capabilities}
    B20 Egate Qosflow Setting B1
    B20 Egate Qosflow Setting B2

B20 Egate Qosflow Setting B1
    Delete Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=1 5qi=1
    Update Cfg    set_qosflow id=2 5qi=2 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=3 5qi=3 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=4 5qi=4 gfbr_ul=720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=5 5qi=5 priority=2

B20 Egate Qosflow Setting B2
    Update Cfg    set_qosflow id=6 5qi=6 default=on priority=1
    Update Cfg    set_qosflow id=7 5qi=7 priority=7
    Update Cfg    set_qosflow id=8 5qi=8 priority=9
    Update Cfg    set_qosflow id=9 5qi=9 priority=9
    Update Cfg    set_qosflow id=10 5qi=80 priority=9
