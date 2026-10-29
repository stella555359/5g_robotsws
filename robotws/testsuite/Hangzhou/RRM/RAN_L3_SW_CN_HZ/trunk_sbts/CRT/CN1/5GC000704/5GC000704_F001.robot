*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags        SBTS00    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    team-L3CN3_SG2
...    release-5G20A    CRT    owner-flora.du    QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_TDD
Resource    ../../../../resources/DevHZ5_resource.robot


*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2cells_ecpri

@{PARAMS_IN_SCF}
...    @{A5_PARAMS}
...    @{HO_PARAMS}
...    @{cipherPrefL}

@{A5_PARAMS}
...    NRCELL-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=75
...    NRCELL-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=85
...    NRCELL-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL-1:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0
...    NRCELL-1:a5MeasSsbRsrq:a5Threshold1SsbRsrq=75
...    NRCELL-1:a5MeasSsbRsrq:a5Threshold2SsbRsrq=85
...    NRCELL-1:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms0

...    NRCELL-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-2:a3MeasSsbRsrq:a3HysteresisSsbRsrq=1
...    NRCELL-2:a3MeasSsbRsrq:a3OffsetSsbRsrq=10
...    NRCELL-2:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms40

@{cipherPrefL}
...    NRBTS-1:cipherPrefL:nea0=9
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=3
...    NRBTS-1:integrityProtPrefL:nia2_128=6
...    NRBTS-1:integrityProtPrefL:nia3_128=9

@{HO_PARAMS}
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS/NRPMRNL-1:miNrRelReportCu=5min
...    NRBTS:timerXnDataFwdGuard=250
...    NRCELL-1:cbraPreamblesPerSsb=n64
...    NRCELL-1:a5MeasEnabled=rsrpAndRsrq

...    NRCELL-2:cbraPreamblesPerSsb=n60
...    NRCELL-2:rsrpThresholdSSB=15
...    NRCELL-2:a3MeasEnabled=rsrqCombined


@{PARAMS_FOR_HO_REPORT}
...    NRBTS-1/NRCELL-1:reportAmountSA=r4
...    NRBTS-1/NRCELL-1:reportInterval=ms640
...    NRBTS-1/NRCELL-1:reportOnLeave=false

...    NRBTS-1/NRCELL-2:reportAmountSA=r8
...    NRBTS-1/NRCELL-2:reportInterval=ms240
...    NRBTS-1/NRCELL-2:reportOnLeave=true

@{DISABLE_HANDOVER}
...    NRBTS:actIntraFreqHoSA=false
...    NRBTS/NRPMRNL-1:miNrRelReportCu=disabled

@{ENABLE_HANDOVER}
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS/NRPMRNL-1:miNrRelReportCu=5min

@{PARAMS_FOR_F013}
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS/NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL-1:a3MeasEnabled=rsrp
...    NRCELL-2:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0
...    NRCELL-2:a3MeasSsbRsrq:a3OffsetSsbRsrq=0
...    NRCELL-2:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms40
...    NRCELL-1:a5MeasEnabled=rsrp
...    NRCELL-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=0
...    NRCELL-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=0
...    NRCELL-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms40

${Ue_capability_ssSINRMeas_fff}    SEPARATOR=
...    E1A03FA047D5FFAEFFFFBAF0140782E0203C126BE7FFF6F800204079DB8080FC7020A2E001FF17847
...    797C1043FEA80467ECA6E91E3127D63127D5C624FA8C49F51079127C245196F9FA28B8017FC5E11DE
...    5F0410FFAA0119FB29BA478C49F58C49F571893EA3127D441E449F091465BE7E8A2E00DFF17847797
...    C1043FEA80467ECA6E91E3127D63127D5C624FA8C49F51079127C245196F9FA28B803FFC5E11DE5F0
...    410FFAA0119FB29BA478C49F58C49F571893EA3127D441E449F091465BE7E8A2E027FF17847797C10
...    43FEA80467ECA6E91E3127D63127D5C624FA8C49F51079127C245196F9FA28B80DFFC5E11DE5F0410
...    FFAA0119FB29BA478C49F58C49F571893EA3127D441E449F091465BE7E8A2E051FF17847797C1043F
...    EA80467ECA6E91E3127D63127D5C624FA8C49F51079127C245196F9F928B826FFC5E11DE5F0410FFA
...    A0119FB29BA478C49F58C49F571893EA3127D441E449F091465BE7E4A2E09DFF17847797C1043FEA8
...    0467ECA6E91E3127D63127D5C624FA8C49F51079127C245196F9F90110389A00000010010134041A0
...    1811B649F03FFFE0000701F00140E020301081C07000783E00990000000C800000200F0A6F2A68020
...    800004B2CA82000032CB2A00E8555D2AAA021B001F37E0380E00F37E0380E00000000C0080180200410

${Ue_capability_ssSINRMeas_tff}    SEPARATOR=
...    e1a03fa047d5ffaeffffbaf0140782e0203c126be7fff6f800204079db8080fc7020a2e001ff17847
...    797c1043fea80467eca6e91e3127d63127d5c624fa8c49f51079127c245196f9fa28b8017fc5e11de
...    5f0410ffaa0119fb29ba478c49f58c49f571893ea3127d441e449f091465be7e8a2e00dff17847797
...    c1043fea80467eca6e91e3127d63127d5c624fa8c49f51079127c245196f9fa28b803ffc5e11de5f0
...    410ffaa0119fb29ba478c49f58c49f571893ea3127d441e449f091465be7e8a2e027ff17847797c10
...    43fea80467eca6e91e3127d63127d5c624fa8c49f51079127c245196f9fa28b80dffc5e11de5f0410
...    ffaa0119fb29ba478c49f58c49f571893ea3127d441e449f091465be7e8a2e051ff17847797c1043f
...    ea80467eca6e91e3127d63127d5c624fa8c49f51079127c245196f9f928b826ffc5e11de5f0410ffa
...    a0119fb29ba478c49f58c49f571893ea3127d441e449f091465be7e4a2e09dff17847797c1043fea8
...    0467eca6e91e3127d63127d5c624fa8c49f51079127c245196f9f90110389a00000010010134041a0
...    1811b649f03fffe0000701f00140e020301881c07000783e00990000000c800000200f0a6f2a68020
...    800004b2ca82000032cb2a00e8555d2aaa021b001f37e0380e00f37e0380e00000000c0080180200410

${Ue_capability_ssSINRMeas_ttf}    SEPARATOR=
...    E5A03FA047D5FFAEFFFFBAF0140782E0203C126BE7FFF6F800204079DB8080FC7020A2E001FF17847
...    797C1043FEA80467ECA6E91E3127D63127D5C624FA8C49F51079127C245196F9FA28B8017FC5E11DE
...    5F0410FFAA0119FB29BA478C49F58C49F571893EA3127D441E449F091465BE7E8A2E00DFF17847797
...    C1043FEA80467ECA6E91E3127D63127D5C624FA8C49F51079127C245196F9FA28B803FFC5E11DE5F0
...    410FFAA0119FB29BA478C49F58C49F571893EA3127D441E449F091465BE7E8A2E027FF17847797C10
...    43FEA80467ECA6E91E3127D63127D5C624FA8C49F51079127C245196F9FA28B80DFFC5E11DE5F0410
...    FFAA0119FB29BA478C49F58C49F571893EA3127D441E449F091465BE7E8A2E051FF17847797C1043F
...    EA80467ECA6E91E3127D63127D5C624FA8C49F51079127C245196F9F928B826FFC5E11DE5F0410FFA
...    A0119FB29BA478C49F58C49F571893EA3127D441E449F091465BE7E4A2E09DFF17847797C1043FEA8
...    0467ECA6E91E3127D63127D5C624FA8C49F51079127C245196F9F90110389A00000010010134041A0
...    1811B649F03FFFE0000701F00140E020301881C0700078143E00990000000C800000200F0A6F2A680
...    20800004B2CA82000032CB2A00E8555D2AAA021B001F37E0380E00F37E0380E00000000C0080180200410

${Ue_capability_ssSINRMeas_tft}    SEPARATOR=
...    E7A03FA047D5FFAEFFFFBAF0140782E0203C126BE7FFF6F800204079DB8080FC7020A2E001FF17847
...    797C1043FEA80467ECA6E91E3127D63127D5C624FA8C49F51079127C245196F9FA28B8017FC5E11DE
...    5F0410FFAA0119FB29BA478C49F58C49F571893EA3127D441E449F091465BE7E8A2E00DFF17847797
...    C1043FEA80467ECA6E91E3127D63127D5C624FA8C49F51079127C245196F9FA28B803FFC5E11DE5F0
...    410FFAA0119FB29BA478C49F58C49F571893EA3127D441E449F091465BE7E8A2E027FF17847797C10
...    43FEA80467ECA6E91E3127D63127D5C624FA8C49F51079127C245196F9FA28B80DFFC5E11DE5F0410
...    FFAA0119FB29BA478C49F58C49F571893EA3127D441E449F091465BE7E8A2E051FF17847797C1043F
...    EA80467ECA6E91E3127D63127D5C624FA8C49F51079127C245196F9F928B826FFC5E11DE5F0410FFA
...    A0119FB29BA478C49F58C49F571893EA3127D441E449F091465BE7E4A2E09DFF17847797C1043FEA8
...    0467ECA6E91E3127D63127D5C624FA8C49F51079127C245196F9F90110389A00000010010134041A0
...    1811B649F03FFFE0000701F00140E020301881C0700078050F8026400000032000000803C29BCA9A0
...    082000012CB2A080000CB2CA803A15574AAA8086C007CDF80E03803CDF80E038000000030020060080104

${Ue_capability_ssSINRMeas_ftf}    SEPARATOR=
...    E7A03FA047D5FFAEFFFFBAF0140782E0203C126BE7FFF6F800204079DB8080FC7020A2E001FF178477
...    97C1043FEA80467ECA6E91E3127D63127D5C624FA8C49F51079127C245196F9FA28B8017FC5E11DE5F
...    0410FFAA0119FB29BA478C49F58C49F571893EA3127D441E449F091465BE7E8A2E00DFF17847797C10
...    43FEA80467ECA6E91E3127D63127D5C624FA8C49F51079127C245196F9FA28B803FFC5E11DE5F0410F
...    FAA0119FB29BA478C49F58C49F571893EA3127D441E449F091465BE7E8A2E027FF17847797C1043FEA
...    80467ECA6E91E3127D63127D5C624FA8C49F51079127C245196F9FA28B80DFFC5E11DE5F0410FFAA01
...    19FB29BA478C49F58C49F571893EA3127D441E449F091465BE7E8A2E051FF17847797C1043FEA80467
...    ECA6E91E3127D63127D5C624FA8C49F51079127C245196F9F928B826FFC5E11DE5F0410FFAA0119FB2
...    9BA478C49F58C49F571893EA3127D441E449F091465BE7E4A2E09DFF17847797C1043FEA80467ECA6E
...    91E3127D63127D5C624FA8C49F51079127C245196F9F90110389A00000010010134041A01811B649F0
...    3FFFE0000701F00140E020301081C0700078140F8026400000032000000803C29BCA9A0082000012CB
...    2A080000CB2CA803A15574AAA8086C007CDF80E03803CDF80E038000000030020060080104

${Ue_capability_ssSINRMeas_fft}    SEPARATOR=
...    E7A03FA047D5FFAEFFFFBAF0140782E0203C126BE7FFF6F800204079DB8080FC7020A2E001FF178477
...    97C1043FEA80467ECA6E91E3127D63127D5C624FA8C49F51079127C245196F9FA28B8017FC5E11DE5F
...    0410FFAA0119FB29BA478C49F58C49F571893EA3127D441E449F091465BE7E8A2E00DFF17847797C10
...    43FEA80467ECA6E91E3127D63127D5C624FA8C49F51079127C245196F9FA28B803FFC5E11DE5F0410F
...    FAA0119FB29BA478C49F58C49F571893EA3127D441E449F091465BE7E8A2E027FF17847797C1043FEA
...    80467ECA6E91E3127D63127D5C624FA8C49F51079127C245196F9FA28B80DFFC5E11DE5F0410FFAA01
...    19FB29BA478C49F58C49F571893EA3127D441E449F091465BE7E8A2E051FF17847797C1043FEA80467
...    ECA6E91E3127D63127D5C624FA8C49F51079127C245196F9F928B826FFC5E11DE5F0410FFAA0119FB2
...    9BA478C49F58C49F571893EA3127D441E449F091465BE7E4A2E09DFF17847797C1043FEA80467ECA6E
...    91E3127D63127D5C624FA8C49F51079127C245196F9F90110389A00000010010134041A01811B649F0
...    3FFFE0000701F00140E020301081C0700078050F8026400000032000000803C29BCA9A0082000012CB
...    2A080000CB2CA803A15574AAA8086C007CDF80E03803CDF80E038000000030020060080104


*** Test Cases ***
5GC000704_ET_F001 Verify_reportInterval_reportOnLeave_and_reportAmount_actIntraFreqHoSA_modification
    [Documentation]
    ...    Configuration:
    ...     Cell1: rsrqCombined A5 CFRA    Cell2: rsrpAndRsrq A3 CBRA
    ...    Checkpoint:
    ...     1. Verify reportInterval reportOnLeave and reportAmount modification
    ...     2. Verify the third E1BearerContextModificationRequest is correctly
    ...     3. Verify actIntraFreqHoSA online modification
    ...    Step:
    ...       1. Ue1 Attach successfully, set traffic
    ...          check UEContextSetupRequest reportInterval reportOnLeave and reportAmount as cell1 configured
    ...       2. Ue1 handover to cell2,
    ...          check the UEContextModificationRequest HandoverPreparationInformation as the cell1 configured
    ...          check the UEContextModificationRequest MeasConfig.reportConfigToAddModList as the cell2 configured
    ...       3. Set actIntraFreqHoSA to disabled
    ...          UE1 handover to cell2 successful, then no related measurement id exist, due to RRC reconfiguration.
    ...          UE2 attach successful, and no related measurement id exist
    ...          UE1 traffic OK
    ...       4. Set actIntraFreqHoSA to enable
    ...          UE1 have nothing related measurement id existUE1 handover to cell2 successful,
    ...          then no related measurement id exist, due to RRC reconfiguration.
    ...          UE2 attach successful, handover from cell1 to cell2 and cell2 to cell1 successful
    ...          UE1 traffic OK
    [Tags]    5GC000704_F_001    QC_61777
    Delta Commission Parameters    ${PARAMS_FOR_HO_REPORT}
    UE1 Attach To Cell1
    Send traffic
    Handover should be successful with CFRA or CBRA
    Check Wireshark Log    ${CURDIR}/a2a_F001/a2a.ini    wait_string=UEContextModificationResponse::12
    Start To Capture Wireshark Log    handover_set_flag
    Verify handover when disable the intragnbhandover flag
    Verify handover when enable the intragnbhandover flag
    Verify traffic should no packet drop
    UE1 Deregister From Cell2
    [Teardown]    Rollback F001 paramaters and tear down

*** Keywords ***
Handover should be successful with CFRA or CBRA
    [Arguments]    ${ue_id}=1
    Handover From Cell1 to Cell2 Should be Success with CFRA
    Handover From Cell2 to Cell1 Should be Success with CBRA
    Verify traffic should no packet drop

UE${ue_id} Attach To Cell1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=1
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id}    pass_regexp=QoS Routing Table

Handover From Cell1 to Cell2 Should be Success with CFRA
    [Arguments]    ${ue_id}=1    ${event}=A5
    ${meas_id}    Get the measurement id    ${event}    ${ue_id}
    ${command}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event} srsrp_nr=20 srsrq_nr=20 phycell_id=51
    ...    nrsrp_nr=61 nrsrq_nr=61 rs_type=ssb index=0 nrs_result=30:20:59
    ${ret1}=    Execute Egate Command    ${command}
    ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
    Should Contain    ${ret1}    measConfig
    Should Contain    ${ret1}    measObjectToAddModList
    Should Contain    ${ret1}    measObject measObjectNR
    Should Contain    ${ret1}    physCellId 51
    Should not Contain    ${ret1}    CBRA
    Should Contain    ${ret1}    CFRA
    sleep    2s    reason=wait related output to be finished

Get Measurement ID should be failed
    [Arguments]    ${event}=A5    ${ue_id}=1
    Run Keyword And Expect Error    *    Get the measurement id    ${event}    ${ue_id}

Handover From Cell2 to Cell1 Should be Success with CBRA
    [Arguments]    ${ue_id}=1
    ${meas_id}    Get the measurement id    A3    ${ue_id}
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=20 srsrq_nr=20 phycell_id=50 nrsrp_nr=61 nrsrq_nr=61
    ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.1 performed
    Should Contain    ${ret1}    measConfig
    Should Contain    ${ret1}    measObjectToAddModList
    Should Contain    ${ret1}    measObject measObjectNR
    Should Contain    ${ret1}    physCellId 50
    Should not Contain    ${ret1}    CFRA
    Should Contain    ${ret1}    CBRA
    sleep    2s    reason=wait related output to be finished

UE${ue_id} Deregister From Cell2
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached

Get the measurement id
    [Arguments]    ${event_id}=A3    ${ue_id}=1
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=636576    event_type=${event_id}
    [Return]    ${meas_id}

Verify handover when disable the intragnbhandover flag
    Delta Commission Parameters     ${DISABLE_HANDOVER}
    Origin UE1 handover should be Success From Cell1 to Cell2
    Origin UE1 get measurement id failed after RRC reconfiguration
    Verify traffic should no packet drop
    UE2 Attach To Cell1
    Get Measurement ID should be failed    A5    2
    UE2 Deregister From Cell2

Verify handover when enable the intragnbhandover flag
    Delta Commission Parameters     ${ENABLE_HANDOVER}
    Get Origin UE1 get measurement id should not exist
    Verify traffic should no packet drop
    UE2 Attach To Cell1
    Handover From Cell1 to Cell2 Should be Success with CFRA    2
    Handover From Cell2 to Cell1 Should be Success with CBRA    2
    UE2 Deregister From Cell2

Send traffic
    Send Throuput    ue_id=1    pdu_id=1
    sleep    3s    reason=sleep for HO limitation
    Verify traffic should no packet drop

Verify Throuput
    [Arguments]    ${Tput_dl}=4    ${Tput_ul}=4    ${ue_id}=1    ${pdu_id}=1
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Send Throuput
    [Arguments]    ${ue_id}    ${pdu_id}    ${Tput}=5
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=${Tput}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=${Tput}

Verify traffic should no packet drop
    sleep    10s    reason=waiting the traffic stablity
    Verify Throuput    Tput_dl=4    Tput_ul=4    ue_id=1    pdu_id=1

Rollback F001 paramaters and tear down
    Run Keyword If Test Failed    Delta Commission Parameters     ${ENABLE_HANDOVER}
    Common Test Teardown And Stop Capture Logs

Origin UE1 handover should be Success From Cell1 to Cell2
    Handover From Cell1 to Cell2 Should be Success with CFRA

Origin UE1 get measurement id failed after RRC reconfiguration
    Run Keyword And Expect Error    *    Get the measurement id    A3

Get Origin UE1 get measurement id should not exist
    Run Keyword And Expect Error    *    Get the measurement id    A3
    Run Keyword And Expect Error    *    Get the measurement id    A5

Set different UeNRCapbility then check SINR for initial context setup and intra gnb HO
    Set UeNRCapbility then check SINR for initial context setup and intra gnb HO
    ...    collector=ssSINRMeas_fff    UeNRCapbility=${Ue_capability_ssSINRMeas_fff}    expect_sinr=false
    Set UeNRCapbility then check SINR for initial context setup and intra gnb HO
    ...    collector=ssSINRMeas_tff    UeNRCapbility=${Ue_capability_ssSINRMeas_tff}    expect_sinr=true
    Set UeNRCapbility then check SINR for initial context setup and intra gnb HO
    ...    collector=ssSINRMeas_ttf    UeNRCapbility=${Ue_capability_ssSINRMeas_ttf}    expect_sinr=true
    Set UeNRCapbility then check SINR for initial context setup and intra gnb HO
    ...    collector=ssSINRMeas_tft    UeNRCapbility=${Ue_capability_ssSINRMeas_tft}    expect_sinr=true
    Set UeNRCapbility then check SINR for initial context setup and intra gnb HO
    ...    collector=ssSINRMeas_ftf    UeNRCapbility=${Ue_capability_ssSINRMeas_ftf}    expect_sinr=true
    Set UeNRCapbility then check SINR for initial context setup and intra gnb HO
    ...    collector=ssSINRMeas_fft    UeNRCapbility=${Ue_capability_ssSINRMeas_fft}    expect_sinr=false

Set UeNRCapbility then check SINR for initial context setup and intra gnb HO
    [Arguments]     ${collector}    ${UeNRCapbility}    ${expect_sinr}
    Ue register with nr capalities    ue_id=1    ue_nr_capabilities=${UeNRCapbility}
    Ue create PDU session
    Send Throuput    ue_id=1    pdu_id=1
    Handover From Cell1 to Cell2 Should be Success with CFRA    event=A3
    Verify traffic should no packet drop
    UE1 Deregister From Cell2
    Location the UE to cell1

Ue register with nr capalities
    [Arguments]     ${ue_nr_capabilities}    ${ue_id}=1
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities}
    ...    pass_regexp=Received REGISTRATION COMPLETE    timeout=10

Ue create PDU session
    [Arguments]    ${ue_id}=1     ${pdu_id}=1    ${nwslice}=1    ${pass_regexp}=Initial Context Setup Successful
	Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=${nwslice} gw=1
    ...    pass_regexp=${pass_regexp}    timeout=10

Location the UE to cell1
    Execute Egate Command    ue_change_location id=1 enb=2 cell=1     pass_regexp=location updated to eNB-2 cell 1 

