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
Execute gNB Delta Commission JSON For CB006139_EC gnb-0
    [Arguments]    ${nrbts_id}  ${gnb_id}  ${target_scf_name_gnb}  ${delta_scf_recommissioning_name}
    [Documentation]    Commissioning of gnb-0 for CB006139_EC, create new updated SCF with delta changes.
    ...    Only one file is required for updating gnb with delta changes.

    Log To Console  Start commissioning for gnb-${source_node_id}
    scf.Load SCF  ${basic_scf_name_gnb_${source_node_id}}


    # !!! sepecial attention to  \$ after e.g.  NRCELL-1  !!! if this is not given also NRCELL-11, NRCELL-15 ... are modified!
    # this wildcard behavior is not clear from taf documentation.

    @{GNB_PARAMS_IN_SCF}   Create List
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}\$:sCellActivationMethod=blind
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}\$:actBufferBasedSCellAddition=oneShot_stepWise_Dl_Fr1
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4\$:dedicatedSib1=true
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4:a1MeasSCellAddEnabled=rsrp
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4:a1MeasSCellAddSsbRsrp
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4:a1MeasSCellAddSsbRsrp:{"a1HysteresisSCellAddSsbRsrp":"0"}
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=80
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=80
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4:a4PeriodicMeasControlSA
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4:a4PeriodicMeasControlSA:{"a4Fr1SupervisionTimer":"4000"}
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=6000
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4:a4PeriodicMeasControlSA:a4MeasActBlockTimer=0
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4:a4PeriodicMeasControlSA:a4MeasMaxNumber=5
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4:a4PeriodicMeasControlSA:a4RetryTimer=30
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4:a4PeriodicMeasControlSA:a4RetryTimerMultCa=2
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4/NRREL-101:sCellAdditionMethod=covBasedA1
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4/NRREL-101:sCellOperationalMode=dlOnly
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4/NRREL-103:sCellAdditionMethod=covBasedA4
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4/NRREL-103:sCellOperationalMode=dlOnly
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4/NRREL-104:sCellAdditionMethod=covBasedA4
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4/NRREL-104:sCellOperationalMode=dlOnly

    FOR  ${nrhoif}    IN    6  7
        Collections.Append To List  ${GNB_PARAMS_IN_SCF}
        ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4/NRHOIF-${nrhoif}:a4MeasSCellAddEnabled=rsrp
        ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4/NRHOIF-${nrhoif}:a4MeasSCellAddSsbRsrp
        ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4/NRHOIF-${nrhoif}:a4MeasSCellAddSsbRsrp:{"a4HysteresisSCellAddSsbRsrp":"0"}
        ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4/NRHOIF-${nrhoif}:a4MeasSCellAddSsbRsrp:a4ThresholdSCellAddSsbRsrp=60
        ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4/NRHOIF-${nrhoif}:a4MeasSCellAddSsbRsrp:a4TimeToTriggerSCellAddSsbRsrp=ms40
    END

    scf.Perform SCF Modification    modification_strings=${GNB_PARAMS_IN_SCF}
    scf.Save SCF  ${target_scf_name_gnb}

    ${actMeasBasedSCellAdditionSa_elements}  Create List
    ...    A4-based

    scf.Add Elements To List
    ...  dist_name=MRBTS-${nrbts_id}/NRBTS-${nrbts_id}
    ...  list_name=actMeasBasedSCellAdditionSa
    ...  elements=${actMeasBasedSCellAdditionSa_elements}

    scf.Save SCF  ${target_scf_name_gnb}
    scf.Calculate Delta SCF
    ...  target_scf_path=${target_scf_name_gnb}
    ...  actual_scf_path=${basic_scf_name_gnb_${source_node_id}}
    ...  delta_scf_path=${delta_scf_recommissioning_name}

    syve_commissioning.Execute Recommissioning With Delta SCF File
    ...  node_type=gnb  node_id=${gnb_id}  delta_scf_recommissioning_name=${delta_scf_recommissioning_name}