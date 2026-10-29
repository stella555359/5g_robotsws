*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    CLOUD_5G_I_MP_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD    team-L3CN3_SG2
...    owner-wen.y.xu    release-5G20A    5GC001008
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2cells_ecpri

@{PARAMS_IN_SCF}    @{HO}    @{NRADJGNB}    @{NRADJNRCELL}    @{NRREL}    @{XNLINK}    @{A3_event}    @{SNSSAI}    @{PLMN}    @{TRACKINGAREA}

@{HO}
...    NRBTS-1:actConflictConfiguration=true
...    NRBTS-1:actIncXn=true
...    NRBTS-1:actIntraFreqHoSA=true
...    NRBTS-1/NRPMRNL-1:miNrRelReportCu=5min
...    NRBTS-1:xnNgRanCfUpNbInfoBackOffTmr=0
...    NRBTS-1:xnNgRanCfUpRdmDelayTmr=0

@{NRADJGNB}
...    NRADJGNB-1:administrativeState=Unlocked
...    NRADJGNB-1:gNbIdLength=22
...    NRADJGNB-1:gNodeBId=36
...    NRADJGNB-1:xnLinkRef=1
...    NRADJGNB-1:gnbPlmn:mcc=311
...    NRADJGNB-1:gnbPlmn:mnc=489
...    NRADJGNB-1:gnbPlmn:mncLength=3

@{NRADJNRCELL}
...    NRADJNRCELL-1:gNbId=36
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:nrarfcn=636666
...    NRADJNRCELL-1:physCellId=48
...    NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRADJNRCELL-1:cellDepType=SA
...    NRADJNRCELL-1:fiveGsTac=0

@{NRREL}
...    NRCELL-1/NRREL-1:gNbId=36
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=1
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3

@{XNLINK}
...    XNLINK-1:cPlaneIpAddr=10.0.1.124

@{A3_event}
...    NRCELL-1:a3MeasEnabled=rsrp
...    NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-1:absThreshSsbRsrpConsolidation=1
...    NRCELL-1:sMeasConfigSsbRsrp=0
...    NRCELL-1:filterCoeffSsbRsrp=fc4

@{SNSSAI}
...    SNSSAI-1:sd=13714341
...    SNSSAI-1:administrativeState=Unlocked
...    SNSSAI-1:sst=1
...    SNSSAI-1:nrPlmnDNList=${NRPLMNDNLIST}
...    SNSSAI-2:sd=13714342
...    SNSSAI-2:administrativeState=Unlocked
...    SNSSAI-2:sst=1
...    SNSSAI-2:nrPlmnDNList=${NRPLMNDNLIST}

@{PLMN}
...    NRPLMN-1:mcc=311
...    NRPLMN-1:mnc=489
...    NRPLMN-1:mncLength=3

@{TRACKINGAREA}
...    TRACKINGAREA-200:fiveGsTac=200
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    NRCELL:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200

${NRPLMNDNLIST}    MRBTS-1/NRBTS-1/NRPLMN-1
@{snssaiDN_1_2}
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2

*** Test Cases ***
5GC001008-ET-TA06_Verify_Xn_NG-RAN_Node_Configuration_Update_procedure_initiated_by_slice_modification_on_RAN_side
    [Documentation]
    ...    1. This user scenario describes the successful NG-RAN Configuration Update initiated by the gNB for slicing configuration modification.
    ...    2. This user scenario describes the gNB behavior, when an inter-gnb Xn handover is rejected at target gnb due to slices not supported,
    ...       with one or multiple PDU sessions. All PDU sessions associated to the same S-NSSAI.
    ...    3. This user scenario describes the successful NG-RAN Configuration Update initiated by the gNB due to slice change of
    ...       administrative state
    ...    4. TAC-200: SLICE1
    ...       AMF-1: SLICE1/SLICE2
    [Tags]    QC_61970
    object should exist    XNLINK-1:xnLinkStatus=available
    add slice2 in TAC
    Add ue history list
    sa ue register and pdu setup    ue_id=1    nwslice=2
    Traffic Should Be OK    ue_id=1    type=sa
    Trigger HO from real-gNB to sim-gNB success
    Lock slice2 and Trigger HO from sim-gNB to real-gNB failed
    Unlock slice2 and Trigger HO from sim-gNB to real-gNB success
    check wireshark log    ${CURDIR}/a2a_TA06/a2a_HO.ini    wait_string=HandoverRequestAcknowledge::2

*** Keywords ***
Modify Cfg
    #sim gnb5
    ${set_gnb5}    catenate    set_gnb id=5 type=simulated plmn=311:489 ng=10.0.1.125 gnb_id=0x24:22 daemon=10.0.2.1:22222
    ...    x2_peers=none xn=10.0.1.124 nssai=0x1:0xd143a6 amf=1
    ${set_gnb5_cell1}    catenate    set_cell id=1 gnb=5 pci=16:0 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.92:9999 nr_arfcn=636666:636666
    ...    gscn=7880 mandatory_for_activation=off
    Update Cfg    ${set_gnb5}
    Update Cfg    ${set_gnb5_cell1}
    Update Cfg    gnb_param id=5 xn_listening_socket=on send_xn_setup=false
    #amf and slice
    Update Cfg    set_amf_region id=1 tac_list=0,200 plmn=311:489
    Update Cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=1 pointer=1
    Update Cfg    set_nwslice id=1 snssai=0x01:0xd143a5 amf=1 default=on ue=all
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 ue=all amf=1

add slice2 in TAC
    delta commission parameters    ${snssaiDN_1_2}

Add ue history list
    ${cmd1}    set variable    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    ${cmd2}    set variable    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=5 time_ue_stayed_in_cell=98
    ${cmd3}    set variable    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=99
    Execute Egate Command    ${cmd1}
    Execute Egate Command    ${cmd2}
    Execute Egate Command    ${cmd3}
    Execute Egate Command    ue_history_information_list id=1 action=commit    committed
    Execute Egate Command    ue_enb_param id=1 ue_history_list=1

sa ue register and pdu setup
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${nwslice}=1    ${cmd_regexp}=NG RM Registered
    Execute Egate Command    ue_register id=${ue_id} nwslice=${nwslice}    ${cmd_regexp}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu} nwslice=${nwslice} gw=${ue_id}    QoS Routing Table

Trigger HO from real-gNB to sim-gNB success
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=11 phycell_id=48 nrsrp_nr=31    Inter-eNB handover

Lock slice2 and Trigger HO from sim-gNB to real-gNB failed
    delta commission parameters    SNSSAI-2:administrativeState=Locked
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=3 event=A3 srsrp_nr=11 phycell_id=50 nrsrp_nr=31    fail_regexp=Inter-eNB handover

Unlock slice2 and Trigger HO from sim-gNB to real-gNB success
    delta commission parameters    SNSSAI-2:administrativeState=Unlocked
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=3 event=A3 srsrp_nr=11 phycell_id=50 nrsrp_nr=31    Inter-eNB handover
