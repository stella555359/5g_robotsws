*** Settings ***
Documentation   Generic gNB Commissioning: CB006139 DB
...             This is a Robot Test Suite for feature: CB006139 DB
...             Feature:  CB006139 Buffer-based step-wise NR FR1 SCell addition
...             Author:  Antje Jooss
...             Team: I_MN_RAN_RD_VRF_ULM_VT2_GMS
...             Email: I_MN_RAN_RD_VRF_ULM_VT2@internal.nsn.com


Resource    ../resources/syve_commissioning.robot
Resource    ../resources/scf_info.robot
Library     taf.config.scf


*** Keywords ***
Execute gNB Delta Commission JSON For CB006139_DB gnb-0
    [Arguments]    ${nrbts_id}  ${gnb_id}  ${target_scf_name_gnb}  ${delta_scf_recommissioning_name}
    [Documentation]    Commissioning of gnb-0 for CB006139_DB, create new updated SCF with delta changes.
    ...    Only one file is required for updating gnb with delta changes.

    Log To Console  Start commissioning for gnb-${source_node_id}
    scf.Load SCF  ${basic_scf_name_gnb_${source_node_id}}


    # !!! sepecial attention to  \$ after e.g.  NRCELL-1  !!! if this is not given also NRCELL-11, NRCELL-15 ... are modified!
    # this wildcard behavior is not clear from taf documentation.

    @{GNB_PARAMS_IN_SCF}   Create List
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}\$:sCellExcludelistTimerFr1=0
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}\$:drbInactivityTimerSA=0
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}\$:actMfbiNrCaSupportFr1=false
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}\$:actSCellReleaseForInactiveSCell=disabled
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}\$:actSCellReleaseBadSCellRlq=disabled
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}\$:actBufferBasedSCellAddition=oneShot_stepWise_Dl_Fr1
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRPMRNL-1\$:miNrPowerSavingBwp=5min
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-11\$:actAperCsi=false
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-11\$:a1MeasSCellAddEnabled=rsrp
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-11\$:actPowerSavingBWP=true
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-11:a2MeasSCellRelEnabled=rsrp
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-11\$:a1ThresholdSCellAddSsbRsrpFDD=80
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-11\$:a2ThresholdSCellRelSsbRsrp=56
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-2:a2MeasSCellRelEnabled=rsrp
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-2\$:sCellDeactivationTimerGNB=ms1280
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4\$:sCellDeactivationTimerGNB=ms1280

    FOR  ${nrrel_id}    IN    2  4
        Collections.Append To List  ${GNB_PARAMS_IN_SCF}
        ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-11/NRREL-${nrrel_id}:sCellAdditionMethod=covBasedA1
        ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-11/NRREL-${nrrel_id}:sCellOperationalMode=dlOnly
    END

    scf.Perform SCF Modification    modification_strings=${GNB_PARAMS_IN_SCF}
    scf.Save SCF  ${target_scf_name_gnb}

    scf.Modify Scf Element
    ...  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/BWP_PROFILE-1007
    ...  dist_name=MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-11
    ...  list_name=cellBwpList
    ...  p_name=bwpDN
    ...  index=0

    scf.Modify Scf Element
    ...  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/BWP_PROFILE-10077
    ...  dist_name=MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-11
    ...  list_name=cellBwpList
    ...  p_name=bwpDN
    ...  index=1

    ${cellBwpList_elements}  Create Dictionary
    ...  actUpperThrAckNackFiltering    true
    ...  actUpperThrAckNackHrFiltering  true
    ...  actPdcchCceFragmentControl     false
    ...  bwpDN                          MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/BWP_PROFILE-10076
    ...  cellBwpId                      2
    ...  pdcchResourcePreference        peakRate

    scf.Add Item To List
    ...  dist_name=MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-11
    ...  list_name=cellBwpList
    ...  elements=${cellBwpList_elements}

    scf.Save SCF  ${target_scf_name_gnb}
    scf.Calculate Delta SCF
    ...  target_scf_path=${target_scf_name_gnb}
    ...  actual_scf_path=${basic_scf_name_gnb_${source_node_id}}
    ...  delta_scf_path=${delta_scf_recommissioning_name}

    syve_commissioning.Execute Recommissioning With Delta SCF File
    ...  node_type=gnb  node_id=${gnb_id}  delta_scf_recommissioning_name=${delta_scf_recommissioning_name}