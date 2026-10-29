*** Settings ***
Force Tags       CLOUD_5G_I_LOO_AP_LOOO    RAN_5G_TDD_FDD    RAN_5G    CONFIGURED
Documentation    :copyright:   Nokia
...              :author:  Bhakti Patel
...              :contact: bhakti.ka_patel@nokia.com
...              Test suite CB014093_B: RACH parameter online modification with SA-capable UEs in NR RRC IDLE/INACTIVE.
...              This suite performs multiple handovers (intra/inter frequency), IRAT HOs, SCell add/release,
...              and verifies traffic and re-establishment behavior as per QC_196577.
Library          BuiltIn
Library          Collections
Resource         resources/CB014093_KW.robot
Suite Setup      Updated Suite Setup
Suite Teardown   Common Suite Teardown



*** Variables ***
@{UE_D}          1    2    21    31    41    51    71   81   91
${DL_RT}         10
${UL_RT}         10
${IRAT_HO_PATTERN_CHECK}    IRAT Handover from NR to EUTRA completed
${SCELL_8}       physCellId 58
${SCELL_11}      physCellId 61
${SYSLOG}        syslog_14093_B
${IntraENB_HO_1_7}        UE2: Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.7
${IntraENB_HO_7_1}        UE2: Intra-eNB handover from EXT_ENB-2.7 to EXT_ENB-2.1
${IntraENB_HO_2_4}        UE21: Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB
${IntraENB_HO_4_2}        UE21: Intra-eNB handover from EXT_ENB-2.4 to EXT_ENB
${IntraENB_HO_10_11}      UE81: Intra-eNB handover from EXT_ENB-2.10 to EXT_ENB
${IntraENB_HO_11_10}      UE81: Intra-eNB handover from EXT_ENB-2.11 to EXT_ENB
${Inactive}       UE2: Is INACTIVE
${UE2}            2
${RRCResume}      UE performed resume procedure
${RRCreconfig}    rrcReconfigurationComplete
${Eutra}          SCG-split to MCG is successful
${UE72}         72
${UE4}          4
${UE101}        101


*** Test Cases ***
[1][1.0] CB014093_B_B2_RACH_parameter_online_modification_for_the_cell_with_SA_capable_UE_in_NR_RRC_IDLE_or_RRC_INACTIVE_state
    [Tags]    QC_238397    QCD_MN_RAN    QCP_RAN_VRF
    [Documentation]
    ...    After performing multiple Ping-Pong intra-frequency and inter-frequency handovers using A2, A3
    ...    and A5 measurement reports, IRAT HO using A2 and B2 measurement reports and SCell add/release
    ...    using A1 and A2 measurement reports.
    [Setup]    Prepare For CB014093_B
    Start Syslog    log_dir=${Log_Path}    log_name=${SYSLOG}    add_line_number=${True}    alias=sys1

    FOR    ${ueid}    IN    @{UE_D}
        UE Register Should Be Successful For SA    ${ueid}
        Log To Console    \nStarting Downlink And Uplink Traffic For UE ${ueid}
        DL Traffic Should Be Successful    ${DL_RT}    ${ueid}
        UL Traffic Should Be Successful    ${UL_RT}    ${ueid}
        Log To Console    \nStarting DL And UL Traffic For UE ${ueid} For Diff QoS
    END

    UE Disp
    Log To Console    \nAll UEs Registered.....

    Log To Console    \nIRAT HO From 5G To 4G
    UE Meas CFG Disp    id=1
    UE Measurement Send NR    id=1    meas_id=1    event=A2
    ...    srs_result=0:18:18:20    phycell_id=51
    Sleep    10s
    UE Meas CFG Disp    id=1
    UE Measurement Send NR    id=1    meas_id=9    event=B2
    ...    srs_result=1:0:18:18    phycell_id=12    nrsrp_nr=35    nrsrq_nr=30
    Verify IRAT HO    ${IRAT_HO_PATTERN_CHECK}
    Sleep    10s

    Log To Console    \nTriggering Intra GNB Inter Freq HO From TDD To FDD
    UE Meas CFG Disp    id=2
    Change prachRootSequenceIndex And zeroCorrelationZoneConfig Value Online    MRBTS-1/NRBTS-1/NRCELL-7
    UE Measurement Send NR    id=2    meas_id=1    event=A2
    ...    srs_result=2:5:5:5    rs_type=ssb
    Sleep    10s
    UE Meas CFG Disp    id=2
    UE Measurement Send NR    id=2    meas_id=6    event=A3
    ...    srs_result=3:10:15:9    phycell_id=57    nrsrp_nr=30
    Verify A3 HO    ${IntraENB_HO_1_7}
    Sleep    10s

    Log To Console    \nTriggering Intra GNB Inter Freq HO From FDD To TDD
    UE Meas CFG Disp    id=2
    Change prachRootSequenceIndex And zeroCorrelationZoneConfig Value Online    MRBTS-1/NRBTS-1/NRCELL-1
    UE Measurement Send NR    id=2    meas_id=9    event=A2
    ...    srs_result=0:18:18:18    rs_type=ssb
    Sleep    10s
    UE Meas CFG Disp    id=2
    UE Measurement Send NR    id=2    meas_id=16    event=A5
    ...    srs_result=0:25:26:27    phycell_id=51    nrsrp_nr=30
    Verify A3 HO    ${IntraENB_HO_7_1}
    Sleep    10s

    Log To Console    \nTriggering HO Intra GNB Intra Freq TDD To TDD
    UE Meas CFG Disp    id=21
    Change prachRootSequenceIndex And zeroCorrelationZoneConfig Value Online    MRBTS-1/NRBTS-1/NRCELL-4
    UE Measurement Send NR    id=21    meas_id=4    event=A5
    ...    srs_result=4:30:30:30    phycell_id=54    srsrp_nr=10    srsrq_nr=10    nrsrp_nr=30
    Verify A3 HO    ${IntraENB_HO_2_4}
    Sleep    10s

    Log To Console    \nTriggering HO Intra GNB Intra Freq TDD To TDD
    UE Meas CFG Disp    id=21
    Change prachRootSequenceIndex And zeroCorrelationZoneConfig Value Online    MRBTS-1/NRBTS-1/NRCELL-2
    UE Measurement Send NR    id=21    meas_id=3    event=A3
    ...    srs_result=3:40:39:38    phycell_id=52    srsrp_nr=10    srsrq_nr=10    nrsrp_nr=30
    Verify A3 HO    ${IntraENB_HO_4_2}
    Sleep    10s

    Log To Console    \nCA: Addition Of SCell, PCell=TDD And SCell=FDD
    Change prachRootSequenceIndex And zeroCorrelationZoneConfig Value Online    MRBTS-1/NRBTS-1/NRCELL-8
    UE Measurement Send NR    id=31    meas_id=5    event=A1
    ...    srs_result=5:30:45:41    rs_type=ssb    srsrp_nr=127
    Verify Scell Addition    ${SCELL_8}
    Sleep    10s

    Log To Console    \nSCell Release
    UE Meas CFG Disp    id=31
    UE Measurement Send NR    id=31    meas_id=6    event=A2
    ...    srs_result=2:52:54:59    scell=1    scell_rsrp=40    scell_rsrq=0
    Verify Scell Release
    Sleep    10s

    Log To Console    \nCA: Addition Of SCell, PCell=FDD And SCell=TDD
    UE Meas CFG Disp    id=71
    Change prachRootSequenceIndex And zeroCorrelationZoneConfig Value Online    MRBTS-1/NRBTS-1/NRCELL-11
    UE Measurement Send NR    id=71    meas_id=5    event=A1
    ...    srs_result=0:40:66:100    srsrp_nr=127    rs_type=ssb
    Verify Scell Addition    ${SCELL_11}
    Sleep    10s

    UE Meas CFG Disp    id=71
    UE Measurement Send NR    id=71    meas_id=6    event=A2
    ...    srs_result=0:30:50:49    scell=1    scell_rsrp=40    scell_rsrq=0
    Verify Scell Release
    Sleep    10s

    Log To Console    \nTriggering HO Intra GNB Intra Freq From FDD To FDD
    UE Meas CFG Disp    id=81
    Change prachRootSequenceIndex And zeroCorrelationZoneConfig Value Online    MRBTS-1/NRBTS-1/NRCELL-11
    UE Measurement Send NR    id=81    meas_id=4    event=A5
    ...    srs_result=0:110:103:108    phycell_id=61    srsrp_nr=10    srsrq_nr=10    nrsrp_nr=30
    Verify A3 HO    ${IntraENB_HO_10_11}
    Sleep    10s

    Log To Console    \nTriggering HO Intra GNB Intra Freq From FDD To FDD
    UE Meas CFG Disp    id=81
    Change prachRootSequenceIndex And zeroCorrelationZoneConfig Value Online    MRBTS-1/NRBTS-1/NRCELL-10
    UE Measurement Send NR    id=81    meas_id=3    event=A3
    ...    srs_result=0:126:127:127    phycell_id=60    srsrp_nr=10    srsrq_nr=10    nrsrp_nr=30
    Verify A3 HO    ${IntraENB_HO_11_10}

    FOR    ${ueid}    IN    @{UE_D}
        UE Deregister Should Be Successful For SA    ${ueid}
        Log To Console    \nDe-Registered UE ${ueid}
    END

    CB014093 B RRC Inactive State
    CB01493_B_RRC_ReEstablishment
    CB01493_B_Eutra_Inact
    [Teardown]    Teardown For CB014093_B

