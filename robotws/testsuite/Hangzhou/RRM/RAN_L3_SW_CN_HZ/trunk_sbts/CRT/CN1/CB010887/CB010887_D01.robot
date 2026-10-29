*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_[MP][MP]_AP_[LOOO]
...    team-VRF3_6        release-SBTS24R3
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}
${cfg}    wts.cfg
${rdSrsCodebookAndTas}    0x590103
${rdPriorSrsForDlBm}    0x590104
${rdEnableSym13ForCBSrs}    0x590223
${rdEnableMainSBSrsPool}    0x590224
${rdEnableOneCBSrsUePerSymbol}    0x590225
${rdSrsSymPolicy}    0x590244
@{PARAMS_IN_SWCONFIG}
#...    ${rdSrsCodebookAndTas}=1
#...    ${rdPriorSrsForDlBm}=0
...    ${rdEnableSym13ForCBSrs}=1
...    ${rdEnableMainSBSrsPool}=0
...    ${rdEnableOneCBSrsUePerSymbol}=0
...    ${rdSrsSymPolicy}=0
@{PARAMS_IN_SWCONFIG_GNB2}
#...    ${rdSrsCodebookAndTas}=1
#...    ${rdPriorSrsForDlBm}=0
...    ${rdEnableSym13ForCBSrs}=1
...    ${rdEnableMainSBSrsPool}=1
...    ${rdEnableOneCBSrsUePerSymbol}=0
...    ${rdSrsSymPolicy}=0
@{PARAMS_IN_VENDOR}
...    actEcpri72e=Ecpri72eUL    betaEc=13    xEc=14

@{PARAMS_IN_VENDOR_GNB2}
...    actEcpri72e=Ecpri72eUL    betaEc=13    xEc=14

@{PARAMS_IN_SCF}
...    NRCELL:actDlSrsBm=true
...    NRCELL:actUlSrsBm=true
...    NRADJNRCELL-13:nrarfcn=636666
...    NRADJNRCELL-13:ssbFrequency=636576
...    NRBTS:rrcReestabTypeSA=sameGNB
...    NRBTS:actInterGnbRREPreparedCell=true
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:timerXnDataFwdGuard=250
...    NRBTS/NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL-1:srsForBeamMgmt:srsTypeAllocForDlBm=codebook
...    NRCELL-1:srsForBeamMgmt:srsUePeriodicity=slots40
...    NRCELL-1/NRREL-2:actA4ToA1BasedSCellFallbackNsa=false
...    NRCELL-1/NRREL-2:gNbId=2
...    NRCELL-1/NRREL-2:lcrId=2
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:absThreshSsbRsrpConsolidation=0
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms640
...    NRBTS:actCustomBsr=true
...    NRBTS/NRCELL-1:beamSet:customBeamSetName=BSR_AVQL_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00002
...    NRBTS/NRCELL-1:beamSet:leftEdgeAngle=60
...    NRBTS/NRCELL-1:beamSet:rightEdgeAngle=60
...    NRBTS/NRCELL-1:beamSet:lowerEdgeAngle=135
...    NRBTS/NRCELL-1:beamSet:upperEdgeAngle=80
...    NRBTS/NRCELL-1:beamSet:beamsMuted=0
...    NRBTS/NRCELL-1:beamSet:tiltOffset=0

@{PARAMS_IN_SCF_GNB2}
...    NRCELL:actDlSrsBm=true
...    NRCELL:actUlSrsBm=true
...    NRADJNRCELL-21:nrarfcn=636666
...    NRADJNRCELL-21:ssbFrequency=636576
...    NRBTS:rrcReestabTypeSA=sameGNB
...    NRBTS:actInterGnbRREPreparedCell=true
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:timerXnDataFwdGuard=250
...    NRBTS/NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL-2:srsForBeamMgmt:srsTypeAllocForDlBm=antenna switching
...    NRCELL-2:srsForBeamMgmt:srsUePeriodicity=slots40
...    NRCELL-2/NRREL-1:actA4ToA1BasedSCellFallbackNsa=false
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:absThreshSsbRsrpConsolidation=0
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms640
...    NRCELL-2:tddFrameStructure:ulDlDataSlotRatio=3/7
...    NRBTS:actCustomBsr=true
...    NRBTS/NRCELL-2:beamSet:customBeamSetName=BSR_AVQL_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00002
...    NRBTS/NRCELL-2:beamSet:leftEdgeAngle=60
...    NRBTS/NRCELL-2:beamSet:rightEdgeAngle=60
...    NRBTS/NRCELL-2:beamSet:lowerEdgeAngle=135
...    NRBTS/NRCELL-2:beamSet:upperEdgeAngle=80
...    NRBTS/NRCELL-2:beamSet:beamsMuted=0
...    NRBTS/NRCELL-2:beamSet:tiltOffset=0

@{srsTypeAllocForDlBm_2}
...    NRCELL:srsForBeamMgmt:srsTypeAllocForDlBm=antenna switching or codebook

@{srsTypeAllocForDlBm_0}
...    NRCELL:srsForBeamMgmt:srsTypeAllocForDlBm=antenna switching

@{srsTypeAllocForDlBm_1}
...    NRCELL:srsForBeamMgmt:srsTypeAllocForDlBm=codebook

@{startPosition_0}
...    startPosition 0
...    Initial Context Setup Successful

@{startPosition_1}
...    startPosition 1
...    rrcReconfigurationComplete

@{startPosition_1_RRE}
...    startPosition 1
...    NR RRC Reestablishment sucessfully completed

@{startPosition_0_RRE}
...    startPosition 0
...    NR RRC Reestablishment sucessfully completed

@{startPosition_0_InterRRE}
...    startPosition 0
...    PATH SWITCH REQUEST ACK

#BAND78: maxNumberSRS-Ports-PerResource=n1; maxNumberPeriodicSRS-PerBWP-PerSlot=6; supportedSRS-TxPortSwitch=t1r1;
${ue_nr_cap_SA_UE1}  SEPARATOR=
...    E1A00000074E5A031E000384A0003C1260C80008785800C40340260300C0700EA8D851AC10143404B2CA261E003D6C10101070EF1C39061C
...    00103278FAB800FF800E003FE000C100076E000100000000E0001000000000551B133582028680965944C3C007AD8202020E1DE38720C380
...    02064F1F57001FF001C007FC00182000EDC000200000001C0002000000000AA3626EB04050D012CB28987800F5B0404041C3BC70E4187000
...    40C9E3EAE003FE003800FF800304001DB800040000000380004000000001546C4ED6080A1A025965130F001EB608080838778E1C830E0008
...    193C7D5400001400000608003B70000800000007000080000000000420E268000000010134640000E010123D86C003000281C1401C0C0260
...    07000683E0000000000000E54D000100000965940034AA2868007000B000000040080118B130001020304050607080B10111213192125262
...    7284A0

#BAND78: maxNumberSRS-Ports-PerResource=n2; maxNumberPeriodicSRS-PerBWP-PerSlot=6; supportedSRS-TxPortSwitch=t2r2;
${ue_nr_cap_SA_UE2}  SEPARATOR=
...    E1A00000074E5A031E000384A0003C1260C80008785800C40340260300C0700EA8D851AC10143404B2CA261E003D6C10101070EF1C39061C
...    00103278FAB800FF800E003FE000C100076E000100000000E0001000000000551B133582028680965944C3C007AD8202020E1DE38720C380
...    02064F1F57001FF001C007FC00182000EDC000200000001C0002000000000AA3626EB04050D012CB28987800F5B0404041C3BC70E4187000
...    40C9E3EAE003FE003800FF800304001DB800040000000380004000000001546C4ED6080A1A025965130F001EB608080838778E1C830E0008
...    193C7D5400001400000608003B70000800000007000080000000000420E268000000010134640000E01012BD86C003000281C1401C0C0260
...    07000683E0000000000000E54D000100000965950034AA2868007000B000000040080118B130001020304050607080B10111213192125262
...    7284A0

${cmd}    SEPARATOR=
...    cp /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L3_SW_CN_HZ/trunk_sbts/CRT/CN1/CB010887/
...    BSR_AVQL_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00002.zip /home/ute/bsr_package

*** Test Cases ***
CB010887-ET-D01_1208_sym13_HO_RRE_1070_sym12
    [Tags]    QC_364081    D001
    Online change before case
    SA UE attach    ue_id=1    cell_id=1    enb_id=2
    Intra Freq HO    phycell_id=51    ue_id=1
    IntraGNB Reestablish    ue_id=1    enb_id=3    cell_id=2    pass_regexp=${startPosition_1_RRE}
    OnlineParamChange    ${srsTypeAllocForDlBm_2}
    InterGNB Reestablish    ue_id=1    enb_id=2    cell_id=1
    OnlineParamChange for GNB2    ${srsTypeAllocForDlBm_2}
    IntraGNB Reestablish    ue_id=1    enb_id=2    cell_id=1    pass_regexp=${startPosition_0_RRE}
    IntraGNB Reestablish    ue_id=1    enb_id=2    cell_id=1    pass_regexp=${startPosition_0_RRE}
    Release ues    ue_type=all
    SA UE attach    ue_id=1    cell_id=1    enb_id=2
    Intra Freq HO    phycell_id=51    ue_id=1
    Release ues    ue_type=all
    Online change before case
    SA UE attach    ue_id=2    cell_id=1    enb_id=2
    Intra Freq HO    phycell_id=51    ue_id=2
    IntraGNB Reestablish    ue_id=2    enb_id=3    cell_id=2    pass_regexp=${startPosition_1_RRE}
    OnlineParamChange    ${srsTypeAllocForDlBm_2}
    InterGNB Reestablish    ue_id=2    enb_id=2    cell_id=1
    OnlineParamChange for GNB2    ${srsTypeAllocForDlBm_2}
    IntraGNB Reestablish    ue_id=2    enb_id=2    cell_id=1    pass_regexp=${startPosition_0_RRE}
    IntraGNB Reestablish    ue_id=2    enb_id=2    cell_id=1    pass_regexp=${startPosition_0_RRE}
    Release ues    ue_type=all
    SA UE attach    ue_id=2    cell_id=1    enb_id=2
    Intra Freq HO    phycell_id=51    ue_id=2
    Release ues    ue_type=all 


*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Install eNB Package via WEBEM
    Install eNB Package via WEBEM In GNB2
    Setup 2Airphone Env    tdd_sansa_cmwv/tdd_gnb1_tdd_gnb2_7_2e    cfg=wts.cfg    ue_count=3

SA UE attach
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${enb_id}=2
    FOR    ${I}    IN RANGE    ${ue_id}    ${ue_id}+1
        Log to console    ${\n}-----register UE ${I} ------
        Execute Egate Command    ue_change_location id=${I} cell=${cell_id} enb=${enb_id}
        Execute Egate Command    ue_register id=${I}    UE now in NG RM Registered state.
        Execute Egate Command    set_pdu_param ue=${I} pdu=1 trf_type=internal
        Execute Egate Command    ue_pdu_session_setup pdu=1 gw=1 ue=${I} nwslice=1    pass_regexp=${startPosition_0}
#    \    Send And Verify Throuput    ue_id=${I}
    END

Send And Verify Throuput
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=1 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=1 trf_id=1    UE ${ue_id}: UDP UL
    Verify Throughput    ue_id=${ue_id}

Verify Throughput
    [Arguments]    ${ue_id}=1    ${Tput_dl}=63    ${Tput_ul}=9.5    ${sleep_time}=10s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
#    log to console    UE${ue_id} dl: ${dl_throughput}
#    log to console    UE${ue_id} ul: ${ul_throughput}
#    \    Should Be True    ${dl_throughput}/1000>${Tput_dl}
#    \    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Online change before case
    OnlineParamChange    ${srsTypeAllocForDlBm_1}
    OnlineParamChange for GNB2    ${srsTypeAllocForDlBm_0}

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=1 ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Install eNB Package via WEBEM
    [Arguments]    ${bsr_name}=BSR_AVQL_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00002.zip    ${bsr_path}=/home/ute/bsr_package
    Execute Cmd On Pc    rm -rf ${bsr_path}
    Execute Cmd On Pc    mkdir ${bsr_path}
    Execute Cmd On Pc    git clone https://gitlabe1.ext.net.nokia.com/hz_ran_l2_sw3_ta/ta_kiss_golden_files.git ${bsr_path}
    update_software    sw_package=${bsr_path}/BSR_FILE/${bsr_name}    timeout=60

Install eNB Package via WEBEM In GNB2
    [Arguments]    ${bsr_path}=/home/ute/bsr_package    ${bsr_name}=BSR_AVQL_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00002.zip
    set suite variable    ${GNB2_PC_IP}    ${tl.test_pcs[1].default_ssh_connection_details.addr}
    Execute Cmd On Pc Gnb2    rm -rf /home/ute/bsr_package/
    Execute Cmd On Pc Gnb2    mkdir ${bsr_path}
    Execute Cmd On Pc Gnb2    git clone https://gitlabe1.ext.net.nokia.com/hz_ran_l2_sw3_ta/ta_kiss_golden_files.git ${bsr_path}
    ${bts_port}    ${use_ssl}    Define Admin Port
    Setup Admin    bts_port=${bts_port}    use_ssl=${use_ssl}    admin_api_log_dir=${SAVE LOG DIRECTORY}/gnb2/admin_logs
    ...    timeout=120    remote_host=${GNB2_PC_IP}    alias=${GNB2_ALIAS}
    update_software    sw_package=${bsr_path}/BSR_FILE/${bsr_name}    alias=${GNB2_ALIAS}    timeout=20

OnlineParamChange
    [Arguments]    ${Online_Param}
    log to console    ${\n}-----start online change for GNB1------
    log to console    ${\n}-----${Online_Param}------
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir
    log to console    ${\n}-----cell on air ------

OnlineParamChange for GNB2
    [Arguments]    ${Online_Param}
    log to console    ${\n}-----start online change for GNB2------
    log to console    ${\n}-----${Online_Param}------
    Delta Commission Parameters GNB2    ${Online_Param}
    Cells Should Be Onair
    log to console    ${\n}-----cell on air ------

Intra Freq HO
    [Arguments]    ${phycell_id}=51    ${ue_id}=81
    FOR    ${I}    IN RANGE    ${ue_id}    ${ue_id}+1
        log to console    ${\n}-----UE${I} start Handover ------
        ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${I}    carrierfreq=636576    event_type=A3
        ${ret1}=     Execute Egate Command
        ...    ue_measurement_send_nr id=${I} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id} nrsrp_nr=60 nrsrq_nr=60
        ...    pass_regexp=${startPosition_1}
        Verify Throughput    ue_id=${I}
    END

IntraGNB Reestablish
    [Arguments]    ${ue_id}    ${enb_id}=3    ${cell_id}=2    ${pass_regexp}=${startPosition_1_RRE}
    FOR    ${I}    IN RANGE    ${ue_id}    ${ue_id}+1
        log to console    ${\n}-----UE${I} start intra GNB RRE to ${enb_id}.${cell_id}------
        ${ret1}=    Execute Egate Command    ue_rrc_reestablish id=${I} gnb=${enb_id} cell=${cell_id} cause=reconfigurationFailure
        ...    pass_regexp=${pass_regexp}    timeout=20s
        Verify Throughput    ue_id=${I}
    END

InterGNB Reestablish
    [Arguments]    ${ue_id}    ${enb_id}=3    ${cell_id}=2    ${phycell_id}=50    ${pass_regexp}=${startPosition_0_InterRRE}
    FOR    ${I}    IN RANGE    ${ue_id}    ${ue_id}+1
        log to console    ${\n}-----UE${I} start Inter GNB RRE to ${enb_id}.${cell_id}------
        ${cmd}    Catenate    ue_nr_rrc_reconf_param id=${I} if_contains=reconfiguration_with_sync action=reestablish cause=otherFailure
        ...    cell=${cell_id} gnb=${enb_id} crnti=source
        Execute Egate Command    ${cmd}
        ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${I}    carrierfreq=636576    event_type=A3
        ${ret1}=     Execute Egate Command
        ...    ue_measurement_send_nr id=${I} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id} nrsrp_nr=60 nrsrq_nr=60
        ...    pass_regexp=${pass_regexp}
        Verify Throughput    ue_id=${I}
    END

