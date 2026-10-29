*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS
...               team-DevHZ5_SG6    owner-guangchong.fan    release-SRAN20A
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    LNCEL/LNCEL_FDD-0:dlChBw=1.4 MHz
...    LNCEL/LNCEL_FDD-0:ulChBw=1.4 MHz
...    delete:MRBTS-1/LNBTS-1/LNCEL-1/CDFIM-1:csfbRegParam1xRtt
...    delete:MRBTS-1/LNBTS-1/LNCEL-1/LNHOX-1
...    LNCEL/LNCEL_FDD-0/MPUCCH_FDD-0:cqiPerNp=10ms
...    LNCEL/LNCEL_FDD-0/MPUCCH_FDD-0:riPerM=2
...    LNCEL/LNCEL_FDD-0/MPUCCH_FDD-0:riPerOffset=0
...    LNCEL:cqiAperEnable=false
...    LNCEL:iniPrbsUl=6
...    LNCEL:puschHarqMode=nonAdaptive
...    LNCEL:redBwRbUlConfig:redBwMaxRbUl=6
...    LNCEL/LNCEL_FDD-0:actAutoPucchAlloc=false
...    LNCEL/LNCEL_FDD-0:maxNrSymPdcch=4
...    LNCEL/LNCEL_FDD-0:prachFreqOff=0
...    LNCEL/LNCEL_FDD-0:maxNumQci1Drb=10
...    LNCEL/LNCEL_FDD-0/MPUCCH_FDD-0:deltaPucchShift=1
...    LNCEL/LNCEL_FDD-0/MPUCCH_FDD-0:n1PucchAn=30
...    LNCEL/LNCEL_FDD-0/MPUCCH_FDD-0:nCqiRb=1
...    LNCEL/LNCEL_FDD-0/MPUCCH_FDD-0:addAUeRrHo=10
...    LNCEL/LNCEL_FDD-0/MPUCCH_FDD-0:addAUeTcHo=10
...    LNCEL/LNCEL_FDD-0:maxNumActUE=16
...    LNCEL/LNCEL_FDD-0:maxNumActDrb=200
...    LNCEL/LNCEL_FDD-0:addNumQci1DrbRadioReasHo=10
...    LNCEL/LNCEL_FDD-0:maxNumCaConfUeDc=16
...    LNCEL/LNCEL_FDD-0:maxNumCaConfUe=16
...    LNCEL/LNCEL_FDD-0:maxNumCaConfUe3c=16
...    LNCEL/LNCEL_FDD-0:actSrs14Pos=true
...    LNCEL/LNCEL_FDD-0:prachConfIndex=3
...    LNCEL/LNCEL_FDD-0:prachCS=12
...    LNBTS-1/LNBTS_FDD-0/SRS14PUCCHDPR-0
...    LNCEL:actUlLnkAdp=fUlLa
...    LNCEL/BBPOOLALLOC-0
...    @{PARAMS_FOR_LNREL}
...    LNCEL-1/CATMCEL-0:actCatMSpecMeas=false
...    LNCEL-1/CATMCEL-0:actInterFreqHoCatM=disabled
...    delete:LNCEL-1/MBSFNCEL-0

@{Change_prachConfIndex}
...    LNCEL/LNCEL_FDD-0:prachConfIndex=4
...    MRBTS-1/LNBTS-1:actBbPooling=false

@{Change_prachConfIndex_2}
...    LNCEL/LNCEL_FDD-0:prachConfIndex=5

@{Bbpooling_Enable}
...    MRBTS-1/LNBTS-1:actBbPooling=true
...    LNCEL/LNCEL_FDD-0:prachConfIndex=5

@{PARAMS_FOR_LNREL}
...    LNCEL-1/LNREL-1:ecgiLcrId=2
...    LNCEL-1/LNREL-1:ecgiAdjEnbId=1
...    LNCEL-1/LNREL-1:handoverAllowed=allowed
...    LNBTS-1:tHoOverallD=10
...    LNBTS-1:actIfHo=enabled
...    LNCEL-1/CATMCEL-0:actInterFreqHoCatM=enabled
...    LNCEL-1:a2RedirectQci1=enabled
...    LNCEL-1:threshold2aQci1=73
...    LNCEL-1:hysThreshold2InterFreq=0
...    LNCEL-1:enableBetterCellHo=true
...    LNCEL-1:enableCovHo=true
...    LNCEL-1:threshold3=24
...    LNCEL-1:threshold3a=26
...    LNCEL-1/CATMCEL-0:actCatMSpecMeas=true
...    LNCEL-1/CATMCEL-0:threshold2CatM=40
...    LNCEL-1/CATMCEL-0:threshold2aCatM=43
...    LNCEL-1/LNHOIF-1:a3OffsetRsrpInterFreqCatM=3
...    LNCEL-1/LNHOIF-1:hysA3OffsetRsrpInterFreqCatM=0
...    LNCEL-1/LNHOIF-1:a3TimeToTriggerRsrpInterFreqCatM=320ms

${srs_msg_case1}
...    radioResourceConfigDedicated contains (
...      physicalConfigDedicated contains (
...        srs-HoppingBandwidth eq 'hbw0' and
...        freqDomainPosition eq 0 and
...        duration eq 'TRUE'
...       )
...    )


*** Test Cases ***
LTE5128-A-c_01_01_16_UEs_can_attach_or_handover_to_cell_when_LTE5128_activation
    [Documentation]    Purpose of this test is verification when LTE5128 actived and 16 UE attached, do inter or intra handover failed
    [Tags]
    Delta Commission Parameters And Wait Cells Onair    ${Change_prachConfIndex}
    Attach 13 UE and Start Traffic
    Intra X2 and S1 HO
    Inter cell HO Pass
    Detach UEs    34    50

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD    ue_count=50
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=50    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts

Modify Yaml
    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...    type: simulated
    ...    plmn: '262:03'
    ...    s1: 10.0.1.31
    ...    cells:
    ...        - {'id': 21, technology: lte, duplex_mode: FDD, tac: 33, pci: '3:0', eci: '0x0000215', earfcn: '1400:19400', bw: 20}
    ...        - {'id': 22, technology: lte, duplex_mode: FDD, tac: 33, pci: '3:1', eci: '0x0000216', earfcn: '1700:19700', bw: 20}
    ...        - {'id': 23, technology: lte, duplex_mode: FDD, tac: 33, pci: '3:2', eci: '0x0000217', earfcn: '1400:19400', bw: 20}

Attach 15 UEs And Start Traffic
    FOR    ${ue_id}    IN RANGE    1     16
        Expect Message Flow
        ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${srs_msg_case1})
        ...    alias=srs_msg_case1    overall_timeout=20
        Execute Uex Command    ue_attach id=${ue_id} cell=1
        Execute Uex Command    trf_data_start ue=${ue_id} protocol=udp dir=ul Mbps=1
        Flow Occurred As Expected    alias=srs_msg_case1
    END


Intra Cell HO 40 Times
    [Arguments]    ${ue_id}=15
    FOR    ${i}    IN RANGE    1     41
        Expect Message Flow
        ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${srs_msg_case1})
        ...    alias=intracellho    overall_timeout=20
        Execute Egate Command    ue_reauth id=15    REAUTHENTICATION PROCEDURE IS COMPLETED
        Flow Occurred As Expected    alias=intracellho
    END

Detach UEs
     [Arguments]    ${start_ue_id}    ${end_ue_id}
     FOR    ${local_ue_id}    IN RANGE    ${start_ue_id}    ${end_ue_id} + 1
        Execute Uex Command    ue_detach id=${local_ue_id}
     END

Enable BBpooling
    Delta Commission Parameters And Wait Cells Onair    ${Bbpooling_Enable}

Attach 16 UEs And Start Traffic
    Attach Pre 8 UEs And Start Traffic
    Attach next 8 UEs And Start Traffic


Attach Pre 8 UEs And Start Traffic
    Attach UE And Start Traffic    ue_id=16    Bandwidth=1    ConfigIndex=7    traComb=0    cyclicShift=0
    Attach UE And Start Traffic    ue_id=17    Bandwidth=1    ConfigIndex=12    traComb=0    cyclicShift=0
    Attach UE And Start Traffic    ue_id=18    Bandwidth=1    ConfigIndex=7    traComb=0    cyclicShift=2
    Attach UE And Start Traffic    ue_id=19    Bandwidth=1    ConfigIndex=12    traComb=0    cyclicShift=2
    Attach UE And Start Traffic    ue_id=20    Bandwidth=1    ConfigIndex=7    traComb=0    cyclicShift=4
    Attach UE And Start Traffic    ue_id=21    Bandwidth=1    ConfigIndex=12    traComb=0    cyclicShift=4
    Attach UE And Start Traffic    ue_id=22    Bandwidth=1    ConfigIndex=7    traComb=0    cyclicShift=6
    Attach UE And Start Traffic    ue_id=23    Bandwidth=1    ConfigIndex=12    traComb=0    cyclicShift=6

Attach next 8 UEs And Start Traffic
    Attach UE And Start Traffic    ue_id=24    Bandwidth=3    ConfigIndex=7    traComb=1    cyclicShift=1
    Attach UE And Start Traffic    ue_id=25    Bandwidth=3    ConfigIndex=12    traComb=1    cyclicShift=1
    Attach UE And Start Traffic    ue_id=26    Bandwidth=3    ConfigIndex=7    traComb=1    cyclicShift=3
    Attach UE And Start Traffic    ue_id=27    Bandwidth=3    ConfigIndex=12    traComb=1    cyclicShift=3
    Attach UE And Start Traffic    ue_id=28    Bandwidth=3    ConfigIndex=7    traComb=1    cyclicShift=5
    Attach UE And Start Traffic    ue_id=29    Bandwidth=3    ConfigIndex=12    traComb=1    cyclicShift=5
    Attach UE And Start Traffic    ue_id=30    Bandwidth=3    ConfigIndex=7    traComb=1    cyclicShift=7
    Attach UE And Start Traffic    ue_id=31    Bandwidth=3    ConfigIndex=12    traComb=1    cyclicShift=7

Attach UE And Start Traffic
    [Arguments]    ${ue_id}=16    ${Bandwidth}=1    ${ConfigIndex}=7    ${traComb}=0    ${cyclicShift}=0
    ${srs_msg_case2}    catenate
    ...    radioResourceConfigDedicated contains (
    ...      physicalConfigDedicated contains (
    ...        srs-Bandwidth eq 'bw${Bandwidth}' and
    ...        srs-HoppingBandwidth eq 'hbw0' and
    ...        freqDomainPosition eq 0 and
    ...        duration eq 'TRUE' and
    ...        srs-ConfigIndex eq ${ConfigIndex} and
    ...        transmissionComb eq ${traComb} and
    ...        cyclicShift eq 'cs${cyclicShift}'
    ...       )
    ...    )
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${srs_msg_case2})
    ...    alias=srs_msg    overall_timeout=20
    Execute Uex Command    ue_attach id=${ue_id} cell=1
    Execute Uex Command    trf_data_start ue=${ue_id} protocol=udp dir=ul Mbps=1
    Flow Occurred As Expected    alias=srs_msg

Intra HO Failed
    Expect Message Will Not Occur
    ...    UE_GROUP_30:RRC_RRCConnectionReconfiguration (${srs_msg_case1})
    ...    alias=intracellho_30    overall_timeout=20
    Expect Message Flow
    ...    UE_GROUP_31:RRC_RRCConnectionReconfiguration (${srs_msg_case1})
    ...    alias=intracellho    overall_timeout=20
    Execute Egate Command    ue_reauth id=30    REAUTHENTICATION PROCEDURE IS COMPLETED
    Execute Egate Command    ue_reauth id=31    REAUTHENTICATION PROCEDURE IS COMPLETED
    Flow Occurred As Expected    alias=intracellho
    Flow Not Occurred For Message    alias=intracellho_30

Attach 2 UE and Inter Ho
    Execute Uex Command    ue_attach id=32-33 cell=2
    Expect Message Will Not Occur
    ...    UE_GROUP_32:RRC_RRCConnectionReconfiguration (${srs_msg_case1})
    ...    alias=intracellho_fail    overall_timeout=20
    Execute Uex Command    ue_ho id=32 enb=1 cell=1 expected_result=fail
    Flow Not Occurred For Message    alias=intracellho_fail

Attach 13 UE and Start Traffic
    FOR    ${ue_id}    IN RANGE    34     47
        Expect Message Flow
        ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${srs_msg_case1})
        ...    alias=srs_msg_case1    overall_timeout=20
        Execute Uex Command    ue_attach id=${ue_id} cell=1
        Execute Uex Command    trf_data_start ue=${ue_id} protocol=udp dir=ul Mbps=1
        Flow Occurred As Expected    alias=srs_msg_case1
    END

Intra X2 and S1 HO
    Expect Message Flow
    ...    UE_GROUP_40:RRC_RRCConnectionReconfiguration (${srs_msg_case1})
    ...    alias=intracellho    overall_timeout=20
    Execute Egate Command    ue_reauth id=40    REAUTHENTICATION PROCEDURE IS COMPLETED
    Flow Occurred As Expected    alias=intracellho
    Expect Message Flow
    ...    UE_GROUP_47:RRC_RRCConnectionReconfiguration (${srs_msg_case1})
    ...    UE_GROUP_48:RRC_RRCConnectionReconfiguration (${srs_msg_case1})
    ...    alias=X2S1HO    overall_timeout=30
    Execute Uex Command    ue_attach id=47-48 enb=2 cell=21
    X2 And S1 HO
    Flow Occurred As Expected    alias=X2S1HO


X2 And S1 HO
    [Arguments]    ${ue_id1}=47    ${ue_id2}=48
    Expect Message Flow
    ...    ENB_1:X2AP_HandoverRequest
    ...    ENB_1:X2AP_HandoverRequestAcknowledge
    ...    alias=inter_eNB_HO_flow    overall_timeout=20
    Execute Egate Command    enb_param id=2 ho_source=x2
    Execute Uex Command    ue_ho id=47 enb=1 cell=1
    Flow Occurred As Expected    alias=inter_eNB_HO_flow
    Expect Message Flow
    ...    MME_1:S1AP_HandoverRequestAcknowledge
    ...    MME_1:S1AP_HandoverNotify
    ...    alias=S1HO_flow    overall_timeout=20
    Execute Egate Command    enb_param id=2 ho_source=s1
    Execute Uex Command    ue_ho id=48 enb=1 cell=1
    Flow Occurred As Expected    alias=S1HO_flow

Inter cell HO Pass
    Expect Message Flow
    ...    UE_GROUP_49:RRC_RRCConnectionReconfiguration (${srs_msg_case1})
    ...    alias=intracellho    overall_timeout=20
    Execute Uex Command    ue_attach id=49-50 cell=2
    Execute Uex Command    ue_ho id=49 enb=1 cell=1
    Flow Occurred As Expected    alias=intracellho