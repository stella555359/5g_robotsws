*** Settings ***
Documentation   Generic gNB Commissioning: CB006139 CG
...             This is a Robot Test Suite for feature: CB006139 CG
...             Feature:  CB006139 Buffer-based step-wise NR FR1 SCell addition
...             Author:  Antje Jooss
...             Team: I_MN_RAN_RD_VRF_ULM_VT2_GMS
...             Email: OU_MN_RAN_RD_VRF_ULM_2_53028393@internal.nsn.com


Resource    ../resources/syve_commissioning.robot
Resource    ../resources/scf_info.robot
Library     taf.config.scf


*** Keywords ***
Execute gNB Delta Commission JSON For CB006139_CG gnb-0
    [Arguments]    ${nrbts_id}  ${gnb_id}  ${target_scf_name_gnb}  ${delta_scf_recommissioning_name}
    [Documentation]    Commissioning of gnb-0 for CB006139_CG, create new updated SCF with delta changes.
    ...    Only one file is required for updating gnb with delta changes.

    scf_info.Set MNL version string for branch    basic_scf_name=${basic_scf_name_gnb_${source_node_id}}
    Log To Console  Start commissioning for gnb-${source_node_id}
    scf.Load SCF  ${basic_scf_name_gnb_${source_node_id}}


    # !!! sepecial attention to  \$ after e.g.  NRCELL-1  !!! if this is not given also NRCELL-11, NRCELL-15 ... are modified!
    # this wildcard behavior is not clear from taf documentation.

    @{GNB_PARAMS_IN_SCF}   Create List
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}\$:sCellActivationMethod=blind
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}\$:actMfbiNrCaSupportFr1=true
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}\$:actMultiFrequencyBandIndicatorNRSupport=true
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}:actMfbiNrCaMeasConfResolv=true
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}\$:actBufferBasedSCellAddition=oneShot_stepWise_Dl_Fr1

    ...  add:[com.nokia.srbts.nrbts:NRCONNECTMODE_PROFILE, MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCONNECTMODE_PROFILE-78, MNL${version}, create]
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCONNECTMODE_PROFILE-78:multiFreqBandIndicatorNR
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-11:nrConnectModeProfileDN=MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCONNECTMODE_PROFILE-78
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-8\$:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-8\$:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=80
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-8\$:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=80
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-8\$:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-8\$:dedicatedSib1=true
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-8\$:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=4000
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-8\$:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=6000
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-8\$:a4PeriodicMeasControlSA:a4MeasActBlockTimer=0
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-8\$:a4PeriodicMeasControlSA:a4MeasActBlockTimer=0
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-8\$:a4PeriodicMeasControlSA:a4RetryTimer=30
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-8\$:a4PeriodicMeasControlSA:a4RetryTimerMultCa=2
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-8/NRHOIF-8\$:a4MeasSCellAddEnabled=rsrp
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-8/NRHOIF-8:a4MeasSCellAddSsbRsrp
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-8/NRHOIF-8:a4MeasSCellAddSsbRsrp:{"a4HysteresisSCellAddSsbRsrp":"0"}
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-8/NRHOIF-8:a4MeasSCellAddSsbRsrp:a4ThresholdSCellAddSsbRsrp=60
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-8/NRHOIF-8:a4MeasSCellAddSsbRsrp:a4TimeToTriggerSCellAddSsbRsrp=ms40
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-8/NRREL-1:sCellAdditionMethod=covBasedA1
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-8/NRREL-1:sCellOperationalMode=dlOnly
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-8/NRREL-11:sCellAdditionMethod=covBasedA4
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-8/NRREL-11:sCellOperationalMode=dlOnly

    scf.Perform SCF Modification    modification_strings=${GNB_PARAMS_IN_SCF}
    scf.Save SCF  ${target_scf_name_gnb}

    ${actMeasBasedSCellAdditionSa_elements}  Create List
    ...    A4-based
    scf.Add Elements To List
    ...  dist_name=MRBTS-${nrbts_id}/NRBTS-${nrbts_id}
    ...  list_name=actMeasBasedSCellAdditionSa
    ...  elements=${actMeasBasedSCellAdditionSa_elements}

    ${multiFreqBandIndicatorNR}  Create List
    ...    78
    scf.Add Elements To List
    ...  dist_name=MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCONNECTMODE_PROFILE-78
    ...  list_name=multiFreqBandIndicatorNR
    ...  elements=${multiFreqBandIndicatorNR}

    scf.Save SCF  ${target_scf_name_gnb}
    scf.Calculate Delta SCF
    ...  target_scf_path=${target_scf_name_gnb}
    ...  actual_scf_path=${basic_scf_name_gnb_${source_node_id}}
    ...  delta_scf_path=${delta_scf_recommissioning_name}

    syve_commissioning.Execute Recommissioning With Delta SCF File
    ...  node_type=gnb  node_id=${gnb_id}  delta_scf_recommissioning_name=${delta_scf_recommissioning_name}