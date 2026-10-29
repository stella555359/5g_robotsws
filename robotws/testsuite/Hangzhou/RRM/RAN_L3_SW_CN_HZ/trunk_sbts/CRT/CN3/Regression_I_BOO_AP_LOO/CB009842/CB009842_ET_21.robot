*** Settings ***
Documentation
...    author: Geng lishuo
...    contact: lishuo.geng@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT_no_cloud    CLOUD_5G_I_BOO_AP_LOO
...    team-CN3ET    owner-lixia.zhou    release-5G24R2     CB009842
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{9842_enable}
...    NRCELL:actUlNrEcIdTAdv=true

@{8281_enable}
...    NRCELL:actUlNrEcIdPosMethod=true
...    NRBTS:timerRRCGuard=6000
...    NRBTS:nrEcidMeasSupervisionTimer=6500

${NRARFCN127180}    127210
@{PARAMS_IN_SCF}
...    @{9842_enable}
...    @{8281_enable}
...    NRCELL-12/NRCELL_FDD-1:nrarfcnUl=134980
...    NRCELL-12/NRCELL_FDD-1:nrarfcnDl=127180
...    NRCELL-12:freqBandIndicatorNR=71
...    NRCELL-12:gscnOrSsPbchArfcn=1589
...    NRCELL-12/NRCELL_FDD-1:chBwDl=20MHz
...    NRCELL-12/NRCELL_FDD-1:chBwUl=20MHz
...    NRBTS-1:srb3SupportEnabled=false
...    NRBTS:actIncXn=true
...    NRBTS:actConflictConfiguration=true
...    NRBTS:actInterFreqHoSA=true
...    NRBTS:actIntraFreqHoSA=false
...    NRBTS:actInterRatHoSA=true
...    NRBTS:timerXnDataFwdGuard=250
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS-1/NRPMRNL-1:miNrRelReportCu=5min
...    NRBTS:sCellActivationMethod=blind
...    NRCELL-12:a1MeashoEnabledSA=rsrp
...    NRCELL-12:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-12:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=40
...    NRCELL-12:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms0
...    delete:NRCELL-12:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr
...    delete:NRCELL-12:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr
...    NRCELL-12:a2MeashoEnabledSA=rsrp
...    NRCELL-12:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL-12:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-12:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL-12:actCDrx=true

...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Sa
...    NRBTS-1:actCarrierAggregation=true
...    NRBTS-1:caConfigurationSupport=2CCDL_2CCUL
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:absThreshSsbRsrqConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=1

...    NRCELL-12:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    NRCELL-12:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=34
...    NRCELL-12:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480
...    NRCELL-12:a2MeasRedirectSsbRsrq:a2HysteresisRedirectSsbRsrq=0
...    NRCELL-12:a2MeasRedirectSsbRsrq:a2ThresholdRedirectSsbRsrq=31
...    NRCELL-12:a2MeasRedirectSsbRsrq:a2TimeToTriggerRedirectSsbRsrq=ms480
...    NRCELL-12:a2MeasReleaseSsbRsrp:a2HysteresisReleaseSsbRsrp=0
...    NRCELL-12:a2MeasReleaseSsbRsrp:a2ThresholdReleaseSsbRsrp=75
...    NRCELL-12:a2MeasReleaseSsbRsrp:a2TimeToTriggerReleaseSsbRsrp=ms0
...    NRCELL-12:a2MeasReleaseSsbRsrq:a2HysteresisReleaseSsbRsrq=0
...    NRCELL-12:a2MeasReleaseSsbRsrq:a2ThresholdReleaseSsbRsrq=75
...    NRCELL-12:a2MeasReleaseSsbRsrq:a2TimeToTriggerReleaseSsbRsrq=ms0

...    NRCELL-12/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-3:gNbId=1
...    NRCELL-12/NRREL-3:gNbIdLength=22
...    NRCELL-12/NRREL-3:lcrId=3
...    NRCELL-12/NRREL-3:removeNotAllowed=false
...    NRCELL-12/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-12:nrhoirDNList=MRBTS-1/NRBTS-1/NRHOIR-1
...    NRCELL-12/NRREL-3:sCellOperationalMode=dlOnly

...    NRBTS-1/NRHOIR-1:allowedMeasBandwidth=mbw100
...    NRBTS-1/NRHOIR-1:b2MeashoEnabled=rsrp
...    NRBTS-1/NRHOIR-1:b2Threshold1hoRsrp=35
...    NRBTS-1/NRHOIR-1:b2Threshold1hoRsrpVoNr=35
...    NRBTS-1/NRHOIR-1:b2Threshold1hoRsrq=50
...    NRBTS-1/NRHOIR-1:b2Threshold1hoRsrqVoNr=50
...    NRBTS-1/NRHOIR-1:earfcnValue=1
...    NRBTS-1/NRHOIR-1:eutraFreqQOffsetRange=0dB
...    NRBTS-1/NRHOIR-1:presenceAntennaPort1=false
...    NRBTS-1/NRHOIR-1:reportAmount=r8
...    NRBTS-1/NRHOIR-1:reportInterval=ms240
...    NRBTS-1/NRHOIR-1:widebandRsrqMeas=false
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrp=0
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrpVoNr=0
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrp=18
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrpVoNr=18
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrp:b2TimeToTriggerhoRsrp=ms480
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrp:b2TimeToTriggerhoRsrpVoNr=ms480
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrq:b2HysteresishoRsrq=0
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrq:b2HysteresishoRsrqVoNr=0
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrq:b2Threshold2hoRsrq=2
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrq:b2Threshold2hoRsrqVoNr=2
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrq:b2TimeToTriggerhoRsrq=ms480
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrq:b2TimeToTriggerhoRsrqVoNr=ms480

...    NRCELL-12/NRRELE-1:cellIndividualOffset=0dB
...    NRCELL-12/NRRELE-1:eNodeBId=18
...    NRCELL-12/NRRELE-1:eutranCellExcluded=false
...    NRCELL-12/NRRELE-1:lcrId=1
...    NRCELL-12/NRRELE-1:ecgiPlmn:mcc=311
...    NRCELL-12/NRRELE-1:ecgiPlmn:mnc=489
...    NRCELL-12/NRRELE-1:ecgiPlmn:mncLength=3

...    NRBTS-1/NRADJECELL-1:eNodeBId=18
...    NRBTS-1/NRADJECELL-1:ePSTrackingAreaCode=0
...    NRBTS-1/NRADJECELL-1:earfcnValue=1
...    NRBTS-1/NRADJECELL-1:lcrId=1
...    NRBTS-1/NRADJECELL-1:physCellId=11
...    NRBTS-1/NRADJECELL-1:ecgiPlmn:mcc=311
...    NRBTS-1/NRADJECELL-1:ecgiPlmn:mnc=489
...    NRBTS-1/NRADJECELL-1:ecgiPlmn:mncLength=3
...    NRBTS-1/NRADJECELL-1:enbPlmn:mcc=311
...    NRBTS-1/NRADJECELL-1:enbPlmn:mnc=489
...    NRBTS-1/NRADJECELL-1:enbPlmn:mncLength=3
...    NRCELL-2:fPdcchMonOccsnPo=2
...    NRCELL-4:fPdcchMonOccsnPo=2

*** Test Cases ***
CB009842-SR-A-B4_ET_21_01_Verify the measurement result when B2 Inter-RAT mobility during E-CID for TADV along with RSRP and RSRQ
    [Documentation]    This case will verify the measurement result when B2 Inter-RAT mobility during E-CID for
    ...    TADV along with RSRP and RSRQ
    ...    Case steps:
    ...    1.setup SA call for UE1 sucessfully with CA
    ...    2.delay 8s to send MR
    ...    3.egate trigger "E-CID Measurement Initiation request" containing Measurement Quantity requested:SS-RSRP and SS-RSRQ
    ...      and Tadv from LMF to UE1
    ...    4.Send A2 measurement report to configure B2
    ...    5.Trigger B2 measurement report to HO to interRAT LTE
    [Tags]
    Execute Egate Command    sim_trace lmf=1 protocol=nrppa on
    Attach UE for waiting L3 call OK
    Delay Measurement Report from UE
    trigger E-CID Measurement Initiation request
    Report A2 and configured B2 for UE
    Report B2 and Trigger HO from cell12 to lte cell
    Check WireShark Log    ${CURDIR}${/}A2A_A021${/}a2a.ini    wait_string=UEContextRelease::18

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_4T2F

Modify Cfg
    Update Cfg    set_lmf id=1 daemon=$SERVER_IP:$EDAEMON_PORT nfId=abcdef01234567gh
    ${ue_83}    catenate
    ...    set_ue simulated id=83 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nea=null+zuc
    ...    nia=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645483 enb=2 cell=12 mode=nr
    Update Cfg    ${ue_83}
    Update Cfg    set_gnb id=5 type=simulated plmn=311:489 ng=10.0.1.14 daemon=$SERVER_IP:$EDAEMON_PORT gnb_id=0x12:28 nssai=0x01:0xD143A5
    ${V1}    catenate
    ...    set_cell id=1 gnb=5 pci=3:2 earfcn=1:18001 tac=0 proxy=$SERVER_IP:12220 nrci=0x1 tdd_cell=on bw=20MHz technology=lte
    ...    mandatory_for_activation=off
    Update Cfg    ${V1}
    Update Cfg    gnb_param id=5 xn_listening_socket=off

Attach UE for waiting L3 call OK
    [Arguments]    ${ueid}=83
    Execute Egate Command    ue_location_change id=${ueid} enb=2 cell=12
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_register id=${ueid}    Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ueid} pdu=2 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=2 ue=${ueid} nwslice=1 gw=1    SCellIndex 1 activated successfully at airphone

Delay Measurement Report from UE
    [Arguments]    ${ue_id}=83
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=0 report_type=periodical action=send_after_rrc_reconf_complete
    ...    delay=8000 srsrp_nr=40 srsrq_nr=50 srs_result=0:40:50:40
    Execute Egate Command    ${cmd}    pass_regexp=send this meas report

trigger E-CID Measurement Initiation request
    [Arguments]    ${ue_id}=83    ${meas_qty}=SS-RSRP,SS-RSRQ    ${tid}=1
    ${cmd}    Catenate    lmf_send_ecid_meas_req id=1 ue=${ue_id} nrppa_transaction_id=${tid} lmf_ue_measurement_id=${tid}
    ...    report_characteristics=OnDemand meas_qty=${meas_qty},NR_Timing_Advance
    Execute Egate Command    ${cmd}    pass_regexp=saved periodic meas report will be sent after 8000 ms with MeasId

Report A2 and configured B2 for UE
    [Arguments]    ${ue_id}=83    ${ssbfreq}=${NRARFCN127180}
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    ${ssbfreq}    A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=30 srsrq_nr=30
    ...    rrcReconfigurationComplete

Report B2 and Trigger HO from cell12 to lte cell
    [Arguments]    ${ue_id}=83
    ${mea_id}    get nr meas id for specific type and frequency    ${ue_id}    1    B2    EUTRAN
    ${A3_cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${mea_id} event=B2 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=11 nrsrp_nr=30 nrsrq_nr=30
    Execute Egate Command    ${A3_cmd}    Successful handover from EXT_ENB-2.12 to ENB-5.1

