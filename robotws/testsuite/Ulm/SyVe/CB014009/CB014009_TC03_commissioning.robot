*** Settings ***
Documentation   Generic gNB Commissioning: CB014009 TC03
...             This is a Robot Test Suite for feature: CB014009 TC03
...             Feature:  CB014009 Buffer-based step-wise NR FR1 SCell addition
...             Author:  Antje Jooss
...             Team: I_MN_RAN_RD_VRF_ULM_VT2_GMS
...             Email: I_MN_RAN_RD_VRF_ULM_VT2@internal.nsn.com


Resource    ../resources/syve_commissioning.robot
Resource    ../resources/scf_info.robot
Library     taf.config.scf


*** Keywords ***
Execute gNB Delta Commission JSON For CB014009_TC03 gnb-0
    [Arguments]    ${nrbts_id}  ${gnb_id}  ${target_scf_name_gnb}  ${delta_scf_recommissioning_name}
    [Documentation]    Commissioning of gnb-0 for CB014009_TC03, create new updated SCF with delta changes.
    ...    Only one file is required for updating gnb with delta changes.

    Log To Console  Start commissioning for gnb-${source_node_id}
    scf.Load SCF  ${basic_scf_name_gnb_${source_node_id}}


    # !!! sepecial attention to  \$ after e.g.  NRCELL-1  !!! if this is not given also NRCELL-11, NRCELL-15 ... are modified!
    # this wildcard behavior is not clear from taf documentation.

    @{GNB_PARAMS_IN_SCF}   Create List
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}\$:sCellExcludelistTimerFr1=12
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}\$:actSCellReleaseForInactiveSCell=timer_based_Fr1
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}\$:actSCellReleaseBadSCellRlq=disabled
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}\$:actBufferBasedSCellAddition=oneShot_stepWise_Dl_Fr1
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}\$:drbInactivityTimerSA=180
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRPMRNL-1\$:miNrCaDu=5min
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRPMRNL-1\$:miNrCaCu=5min
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRPMRNL-1\$:miNrRSADU=5min
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRPMRNL-1\$:miNrRSACU=5min
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-2\$:actAperCsi=false
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-2\$:sCellDeactivationTimerGNB=ms1280

    FOR  ${nrrel_id}    IN    102  103  104
        Collections.Append To List  ${GNB_PARAMS_IN_SCF}
        ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-2/NRREL-${nrrel_id}:sCellAdditionMethod=blind
        ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-2/NRREL-${nrrel_id}:sCellOperationalMode=dlOnly
    END

    scf.Perform SCF Modification    modification_strings=${GNB_PARAMS_IN_SCF}
    scf.Save SCF  ${target_scf_name_gnb}
    scf.Calculate Delta SCF
    ...  target_scf_path=${target_scf_name_gnb}
    ...  actual_scf_path=${basic_scf_name_gnb_${source_node_id}}
    ...  delta_scf_path=${delta_scf_recommissioning_name}

    syve_commissioning.Execute Recommissioning With Delta SCF File
    ...  node_type=gnb  node_id=${gnb_id}  delta_scf_recommissioning_name=${delta_scf_recommissioning_name}

#############################################################################

Execute gNB Delta Commission JSON For CB014009_TC03 gnb-1
    [Arguments]    ${nrbts_id}  ${gnb_id}  ${target_scf_name_gnb}  ${delta_scf_recommissioning_name}
    [Documentation]    Commissioning of gnb-1 for CB014009_TC03, create new updated SCF with delta changes.
    ...    Only one file is required for updating gnb with delta changes.

    Log To Console  Start commissioning for gnb-${target_node_id}
    scf.Load SCF  ${basic_scf_name_gnb_${target_node_id}}


    # !!! sepecial attention to  \$ after e.g.  NRCELL-1  !!! if this is not given also NRCELL-11, NRCELL-15 ... are modified!
    # this wildcard behavior is not clear from taf documentation.

    @{GNB_PARAMS_IN_SCF}   Create List
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRPMRNL-1\$:miNrRSADU=5min
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRPMRNL-1\$:miNrRSACU=5min
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}\$:actSCellReleaseForInactiveSCell=timer_based_Fr1
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}\$:actSCellReleaseBadSCellRlq=disabled
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-2\$:sCellInactivityReleaseTimer=30
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3\$:sCellInactivityReleaseTimer=60
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4\$:sCellInactivityReleaseTimer=90

    FOR  ${nrcell_id}    IN    2  3  4
        Collections.Append To List  ${GNB_PARAMS_IN_SCF}
        ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}\$:actAperCsi=false
    END

    scf.Perform SCF Modification    modification_strings=${GNB_PARAMS_IN_SCF}
    scf.Save SCF  ${target_scf_name_gnb}
    scf.Calculate Delta SCF
    ...  target_scf_path=${target_scf_name_gnb}
    ...  actual_scf_path=${basic_scf_name_gnb_${target_node_id}}
    ...  delta_scf_path=${delta_scf_recommissioning_name}

    syve_commissioning.Execute Recommissioning With Delta SCF File
    ...  node_type=gnb  node_id=${gnb_id}  delta_scf_recommissioning_name=${delta_scf_recommissioning_name}