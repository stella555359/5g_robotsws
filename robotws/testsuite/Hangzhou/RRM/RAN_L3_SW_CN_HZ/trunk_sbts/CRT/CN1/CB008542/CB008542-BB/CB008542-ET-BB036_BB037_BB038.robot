*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags  QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    CLOUD_5G_I_BOO_AP_LOO
...    team-CN1ET    owner-zora.wang    owner-christine.chen    owner-jolin.fan    release-5G22R3    CB008542
Resource  ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${BTS_STARTUP_RETRY}    2
${DEBUG_LOG_LEVEL}    4
${cell_id}    1,2,11
@{PARAMS_IN_SCF}
...    NRBTS:actFdmScheduling=true
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS/NRDU-1:actInterNumerologyCa=true
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CA_support_list}
...    NRCELL-1:actCDrx=false
...    NRCELL-1:pucchModeSelect=longPucch
...    NRCELL-1:actK1Opt=intra-gNB
...    NRCELL-2:pucchModeSelect=longPucch
...    NRCELL-2:actK1Opt=intra-gNB
...    NRCELL-11:actK1Opt=intra-gNB
...    NRCELL-11:pucchModeSelect=longPucch
...    NRCELL-1:actCaAwarePsCellSelectionFr1=true
...    NRCELL-2:actCaAwarePsCellSelectionFr1=true
...    NRCELL-11:actCaAwarePsCellSelectionFr1=true
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-10:gNbId=1
...    NRCELL-1/NRREL-10:gNbIdLength=22
...    NRCELL-1/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-10:lcrId=2
...    NRCELL-1/NRREL-10:removeNotAllowed=false
...    NRCELL-1/NRREL-10:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=75
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=95
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=0ms
...    NRCELL-1:a2MeasSCellRelEnabled=rsrp
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-10:gNbId=1
...    NRCELL-11/NRREL-10:gNbIdLength=22
...    NRCELL-11/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-10:lcrId=1
...    NRCELL-11/NRREL-10:removeNotAllowed=false
...    NRCELL-11/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-11:a1MeasSCellAddEnabled=rsrp
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=75
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=95
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=0ms
...    NRCELL:sCellDeactivationTimerGNB=infinity
${CA_support_list}  ca_Fr1Tdd_Fdd_Nsa,ca_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Nsa

@{OnlineParam_BB036}
...    NRCELL-11/NRREL-10:lcrId=1
...    NRCELL-1/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-10:lcrId=11
...    NRCELL-11:a2MeasSCellRelEnabled=rsrp
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms

@{OnlineParam_BB037}
...    NRCELL-2/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-10:gNbId=1
...    NRCELL-2/NRREL-10:gNbIdLength=22
...    NRCELL-2/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-10:lcrId=11
...    NRCELL-2/NRREL-10:removeNotAllowed=false
...    NRCELL-2/NRREL-10:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-10:gnbPlmn:mncLength=3

@{OnlineParam_BB038}
...    NRCELL-11/NRREL-10:lcrId=1
...    NRCELL-11/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-10:lcrId=11
...    NRCELL-1/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-1:a2MeasSCellRelEnabled=rsrp
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-2:a1MeasSCellAddEnabled=rsrp
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=75
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=95
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=0ms
...    NRCELL-2/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-10:gNbId=1
...    NRCELL-2/NRREL-10:gNbIdLength=22
...    NRCELL-2/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-10:lcrId=1
...    NRCELL-2/NRREL-10:removeNotAllowed=false
...    NRCELL-2/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-10:gnbPlmn:mncLength=3

@{PM_Counters_Check_BB036}
...    NRCELL-1:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-1:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=1
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=1
...    NRCELL-1:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}>0
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-1:NCAC:${A2MEAS_REL1DLSCELL_ATT_NSA}=1
...    NRCELL-1:NCAC:${A2MEAS_REL1DLSCELL_SUCC_NSA}=1
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=1
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=1
...    NRCELL-11:NCAC:${UE_SCELL_1_CONF_SCELL_DL}>0
${SGNB_SCELL_1_ADMISSION_REQ}    M55114C00021
#The number of radio admission requests for 1 Scell
${SGNB_SCELL_1_ADMISSION_SUCC}    M55114C00028
#The number of successful radio admissions for 1 Scell additions.
${RRC_RECONF_1_SCELL_DL_ATT}    M55118C02000
#RRC Reconfigurations attempts for 1 SCell Addition in DL for NSA mode
${RRC_RECONF_1_SCELL_DL_SUCC}    M55118C03000
#Successful RRC Reconfigurations attempts for 1 SCell Addition in DL for NSA mode
${UE_PSCELL_1_CONF_SCELL_DL}    M55118C04000
#Number of CA UEs in the current cell configured as a PSCell, which have 1 configured SCell in DL
${SGNB_DU_SCELL_1_ADMISSION_REQ}    M55115C00008
#The number of radio admission requests for 1 Scell
${SGNB_DU_SCELL_1_ADMISSION_SUCC}    M55115C00015
#The number of successful radio admissions for 1 Scell additions.
${SGNB_DU_SCELL_ADMISSION_REQ}    M55115C00006
#The number of radio admission requests for the Scell
${SGNB_DU_SCELL_ADMISSION_SUCC}    M55115C00007
#The number of successful radio admissions for the Scell
${UE_SCELL_1_CONF_SCELL_DL}    M55118C05000
#Number of CA UEs in the current cell configured as a SCell, which have 1 configured SCell in DL
${A2MEAS_REL1DLSCELL_ATT_NSA}    M55118C06503
#Nbr of RRC Reconfiguration attempts releasing 1 SCell in DL triggered by A2 measurement for NSA
${A2MEAS_REL1DLSCELL_SUCC_NSA}    M55118C06504
#Nbr of successful RRC Reconfigurations releasing 1 SCell in DL triggered by A2 measurement for NSA

@{PM_Counters_Check_BB037}
...    NRCELL-2:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-2:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-2:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=1
...    NRCELL-2:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=1
...    NRCELL-2:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}>0
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=1
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=1
...    NRCELL-11:NCAC:${UE_SCELL_1_CONF_SCELL_DL}>0

@{PM_Counters_Check_BB038}
...    NRCELL-2:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-2:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-2:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=1
...    NRCELL-2:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=1
...    NRCELL-2:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}>0
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=1
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=1
...    NRCELL-1:NCAC:${UE_SCELL_1_CONF_SCELL_DL}>0
...    NRCELL-2:NCAC:${A2MEAS_REL1DLSCELL_ATT_NSA}=1
...    NRCELL-2:NCAC:${A2MEAS_REL1DLSCELL_SUCC_NSA}=1

*** Test Cases ***
CB008542-ET-BB036_verify_TFCA_will_be_selected_when_selection_pool_is_TDD_nonCA_with_highest_frequency_and_FTCA_and_TFCA
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...         US CB008542-BB#B12 Support for FR1 TDD-FDD CA with CNI-71694 CA-aware PSCell selection
    ...         Sort the CellList with the following precedence:
    ...          a. Is FR2 cell
    ...          b. Is FR1 cell AND CNI-71694 is enabled in the cell AND UE can be configured with FR1 CA in the cell,
    ...               i.e. validated gNB-UE band combination list prepared with this cell as PSCell
    ...                (5G_CP_ARC_ALG_269) has at least one entry
    ...          c. Highest frequency
    ...         frequency : cell-2 > cell-1
    ...        cell selection combination:
    ...        FT: config cell-1 as cell-11 scell.(covBasedA1)
    ...        TF: config cell-11 as cell-1 scell.(covBasedA1)(Select)
    ...        T: config cell-2
    ...    2. Test Case Steps:
    ...         a. NSA UE91 attach to NR Cell list 1,2,11,final attach to cell-1
    ...         b. trigger A1 MR to add scell FDD CELL-11
    ...         c. then trigger A2 MR to release scell FDD
    ...         d. all UE detach
    ...    3. Expected Results:
    ...         Step a: NSA UE91 call setup successfully. traffic is ok.
    ...                 IE: on message: SgNBAdditionRequestAcknowledge
    ...                 candidateCellInfoListMN.physCellId = 50
    ...                 candidateCellInfoListMN.physCellId = 51
    ...                 candidateCellInfoListMN.physCellId = 60
    ...         Step b: FDD scell added. Traffic share on scell.
    ...                 IE: on RRC:
    ...                 sCellIndex=9
    ...                 physCellId = 50
    ...                 sCellToAddModList.None.sCellConfigCommon.physCellId = 60
    ...         Step c: FDD scell released.
    ...                 IE: on RRC:
    ...                 sCellIndex=9
    ...                 physCellId = 50
    ...                 sCellToAddModList.None.sCellConfigCommon.physCellId = 60
    ...         Step d: ALL call can be released successfully.
	[Tags]    QC_164109    BB036    zora
	Delta Commission Parameters    ${OnlineParam_BB036}
	Clear Counter Files
	NSA CA UE Attach To Cell and Initial covBaseA1 scelladd and a2scellrelease    91    ${cell_id}
	Stop Traffic And Detach Ue
	Check Wireshark And RRC Logs
	Check Counters    ${PM_Counters_Check_BB036}

CB008542-ET-BB037_verify_TFCA_will_be_selected_when_selection_pool_is_TTCA_which_first_TDD_with_lowest_frequency_and_FTCA_and_TFCA
    [Documentation]
    ...    1. The purpose of this test case is to check FR1 TDD-FDD CA with CNI-71694 CA-aware PSCell selection.
    ...         Sort the CellList with the following precedence:
    ...          a. Is FR2 cell
    ...          b. Is FR1 cell AND CNI-71694 is enabled in the cell AND UE can be configured with FR1 CA in the cell,
    ...               i.e. validated gNB-UE band combination list prepared with this cell as PSCell
    ...                (5G_CP_ARC_ALG_269) has at least one entry
    ...          c. Highest frequency
    ...         frequency : cell-2 > cell-1
    ...        cell selection combination:
    ...        FT: config cell-1 as cell-11 scell.(covBasedA1)
    ...        TF: config cell-11 as cell-2 scell.(blind)(Select)
    ...        TT: config cell-2 as cell-1 scell.(blind)
    ...    2. Test Case Steps:
    ...         a. CA NSA UE91 attach to NR Cell 1,2,11,
    ...         b. check UE91 attched to cell2, scell is cell11
    ...         c. all UE detach
    ...    3. Expected Results:
    ...         Step a: NSA UE91 call setup successfully. traffic is ok.
    ...                 IE: on wireshark log:
    ...                 candidateCellInfoListMN.physCellId = 50
    ...                 candidateCellInfoListMN.physCellId = 51
    ...                 candidateCellInfoListMN.physCellId = 60
    ...         Step b: cell2 is selected. Traffic share on scell.
    ...                 IE: on RRC and wireshark log:
    ...                 sCellIndex=9
    ...                 physCellId = 51
    ...                 sCellToAddModList.None.sCellConfigCommon.physCellId = 60
    ...         Step c: ALL call can be released successfully.
	[Tags]    QC_164083    BB037    christine.chen
	Delta Commission Parameters    ${OnlineParam_BB037}
	Clear Counter Files
	NSA CA UE Attach To Cell and Initial blind scelladd    91    ${cell_id}
	Stop Traffic And Detach Ue
	Check Wireshark And RRC Logs    BB037
	Check Counters    ${PM_Counters_Check_BB037}

CB008542-ET-BB038_verify_TTCA_will_be_selected_when_selection_pool_is_TTCA_which_first_TDD_with_highest_frequency_and_FTCA_and_TFCA
    [Documentation]
    ...    1. The purpose of this test case is to check FR1 TDD-FDD CA with CNI-71694 CA-aware PSCell selection.
    ...         Sort the CellList with the following precedence:
    ...          a. Is FR2 cell
    ...          b. Is FR1 cell AND CNI-71694 is enabled in the cell AND UE can be configured with FR1 CA in the cell,
    ...               i.e. validated gNB-UE band combination list prepared with this cell as PSCell
    ...                (5G_CP_ARC_ALG_269) has at least one entry
    ...          c. Highest frequency
    ...         frequency : cell-2 > cell-1
    ...        cell selection combination:
    ...        FT: config cell-1 as cell-11 scell.(covBasedA1)
    ...        TF: config cell-11 as cell-1 scell.(covBasedA1)
    ...        TT: config cell-1 as cell-2 scell.(covBasedA1)(Select)
    ...    2. Test Case Steps:
    ...         a. CA NSA UE91 attach to NR Cell 1,2,11,
    ...         b. check UE91 attched to cell2, scell is cell1
    ...         c. A2 Scell release
    ...         d. all UE detach
    ...    3. Expected Results:
    ...          a: NSA UE91 call setup successfully. traffic is ok.
    ...             IE: on wireshark log:
    ...             candidateCellInfoListMN.physCellId = 50
    ...             candidateCellInfoListMN.physCellId = 51
    ...             candidateCellInfoListMN.physCellId = 60
    ...         b: cell2 is selected. Traffic share on scell.
    ...             IE: on RRC and wireshark log:
    ...             sCellIndex=9
    ...             physCellId = 51
    ...             sCellToAddModList.None.sCellConfigCommon.physCellId = 50
    ...         c: Scell release successfully
    ...         d: ALL call can be released successfully.
	[Tags]    QC_164082    BB038    jifan
	Delta Commission Parameters    ${OnlineParam_BB038}
	Clear Counter Files
	Start RRC Log    BB038_RRC
	NSA CA UE Attach and Start L3 Call successfully    91    ${cell_id}
	covBaseA1 Scelladd and a2Scellrelease successfully    91    633216    518910
	Get RRC Log
	Stop Traffic And Detach Ue
	Check Wireshark And RRC Logs    BB038
	Check Counters    ${PM_Counters_Check_BB038}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

NSA CA UE Attach To Cell and Initial blind scelladd
    [Arguments]    ${ue_id}=91    ${cell_id}=1
    Start RRC Log    NSA_UE${ue_id}_blind_scelladd
    NSA UE attach    ${ue_id}    ${cell_id}
    Get RRC Log
    Send And Verify Throuput
    Verify Throuput on Pscell and Scell For BB037

NSA CA UE Attach To Cell and Initial covBaseA1 scelladd and a2scellrelease
    [Arguments]    ${ue_id}=91    ${cell_id}=1
    Start RRC Log    NSA_UE${ue_id}_covBaseA1_scelladd
    NSA UE attach    ${ue_id}    ${cell_id}
    Send And Verify Throuput
    Verify Throuput on Pscell For BB036
    Add gNB Cell As Scell By A1
    Verify Throuput on Pscell and Scell For BB036
    Release gNB Cell Scell By A2
    Verify Throuput on Pscell For BB036    sleep_time=30s
    Get RRC Log

NSA CA UE Attach and Start L3 Call successfully
    [Arguments]    ${ue_id}=91    ${cell_id}=2
    NSA UE attach    ${ue_id}    ${cell_id}
    Send And Verify Throuput
    Verify Throuput on Pscell For BB038

covBaseA1 Scelladd and a2Scellrelease successfully
    [Arguments]    ${ue_id}=91    ${pcellfreq}=633216    ${scellfreq}=518910
    Add gNB Cell As Scell By A1    ${ue_id}    ${pcellfreq}
    Verify Throuput on Pscell and Scell For BB038
    Release gNB Cell Scell By A2    ${ue_id}    ${scellfreq}
    Verify Throuput on Pscell For BB038    sleep_time=30s

NSA UE attach
    [Arguments]    ${ue_id}=91    ${target_cells}=1
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    ${cmd}    catenate    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg
    Execute Egate Command    ${cmd}    successful RA

Add gNB Cell As Scell By A1
    [Arguments]    ${ue_id}=91    ${carrierfreq}=518910
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=91 meas_id=${meas_id} event=A1 srsrp_nr=100
    ...    pass_regexp=SCellIndex 9 activated successfully

Release gNB Cell Scell By A2
    [Arguments]    ${ue_id}=91    ${carrierfreq}=424090
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=9 scell_rsrp=30
    ...    pass_regexp=Sending SgNB Modification Confirm

Check Wireshark And RRC Logs
    [Arguments]    ${case_id}=BB036
    Check RRC log    ${CURDIR}${/}a2a_${case_id}${/}a2a.ini
    check wireshark log    ${CURDIR}${/}a2a_${case_id}${/}a2a.ini

Stop Traffic And Detach Ue
    UE Detach From GNB
    Stop Traffic

Stop Traffic
    Execute Egate Command    trf_data_stop ue=91    pass_regexp=Traffic was stopped

UE Detach From GNB
    [Arguments]    ${expect_string}=${EMPTY}
    Execute Egate Command  ue_detach id=91    ${expect_string}

Send And Verify Throuput
    [Arguments]    ${ue_id}=91    ${sleep_time}=30s
    sleep    ${sleep_time}
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
	Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=50    UE ${ue_id}: UDP UL

Verify Throuput on Pscell For BB036
    [Arguments]    ${ue_id}=91    ${sleep_time}=30s
    sleep    ${sleep_time}
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000>307
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>36

Verify Throuput on Pscell and Scell For BB036
    [Arguments]    ${ue_id}=91    ${sleep_time}=30s
    sleep    ${sleep_time}
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000 > 307
    ${scell9_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=9    type=pdsch    rate_type=ave
    Should Be True    ${scell9_tput}/1000 > 63
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>36

Verify Throuput on Pscell and Scell For BB037
    [Arguments]    ${ue_id}=91    ${sleep_time}=30s
    sleep    ${sleep_time}
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000 > 250
    ${scell9_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=9    type=pdsch    rate_type=ave
    Should Be True    ${scell9_tput}/1000 > 60
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>45

Verify Throuput on Pscell and Scell For BB038
    [Arguments]    ${ue_id}=91    ${sleep_time}=30s
    sleep    ${sleep_time}
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000 > 250
    ${scell9_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=9    type=pdsch    rate_type=ave
    sleep    10s    Wait for stability
    ${scell9_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=9    type=pdsch    rate_type=ave
    Should Be True    ${scell9_tput}/1000 > 200
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>45

Verify Throuput on Pscell For BB038
    [Arguments]    ${ue_id}=91    ${sleep_time}=30s
    sleep    ${sleep_time}
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000>250
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>45
