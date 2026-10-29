*** Settings ***
Documentation   Generic eNB Commissioning: CB006139
...             This is a Robot Test Suite for feature: CB006139
...             Feature:  CB006139 Buffer-based step-wise NR FR1 SCell addition
...             Author:  Antje Jooss
...             Team: I_MN_RAN_RD_VRF_ULM_VT2_GMS
...             Email: I_MN_RAN_RD_VRF_ULM_VT2@internal.nsn.com


Resource    ../resources/syve_commissioning.robot
Resource    ../resources/scf_info.robot
Library     taf.config.scf


*** Keywords ***
Execute GNB Delta Commission JSON For CB006139_AA GNB-0
    [Arguments]    ${nrbts_id}  ${gnb_id}  ${target_scf_name_gnb}  ${delta_scf_recommissioning_name}
    [Documentation]    Commissioning of gnb for CB006139_AA, create new updated SCF with delta changes.
    ...    Only one file is required for updating gnb with delta changes.

    Log To Console  Start commissioning for gnb-${SOURCE_NODE_ID}
    scf.Load SCF  ${basic_scf_name_gnb_${SOURCE_NODE_ID}}


    # !!! sepecial attention to  \$ after e.g.  NRCELL-1  !!! if this is not given also NRCELL-11, NRCELL-15 ... are modified!
    # this wildcard behavior is not clear from taf documentation.

    @{GNB_PARAMS_IN_SCF}   Create List
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}\$:sCellExcludelistTimerFr1=12
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}:actSCellReleaseForInactiveSCell=timer_based_Fr1
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}\$:actBufferBasedSCellAddition=oneShot_Dl_Fr1
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}\$:sCellActivationMethod=blind
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}\$:actOverheatingAssistance=false
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRPMRNL-1\$:miNrCaDu=5min

    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1\$:sCellInactivityReleaseTimer=300
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-5\$:sCellInactivityReleaseTimer=300
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-10\$:sCellInactivityReleaseTimer=90
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-15\$:sCellInactivityReleaseTimer=100
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-20\$:sCellInactivityReleaseTimer=300

    FOR  ${nrcell}  IN RANGE  1  25
        Collections.Append To List  ${GNB_PARAMS_IN_SCF}
        ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}:sCellDeactivationTimerGNB=infinity
    END

    FOR  ${nrrel_id}    IN    5  10  15  20
        Collections.Append To List  ${GNB_PARAMS_IN_SCF}
        ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRREL-${nrrel_id}:sCellAdditionMethod=blind
        ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRREL-${nrrel_id}:sCellOperationalMode=dlOnly
    END



    scf.Perform SCF Modification    modification_strings=${GNB_PARAMS_IN_SCF}

    scf.Save SCF  ${target_scf_name_gnb}

    # create delta to check if modify_scf_element or perform_scf_modification worked correct by glance at generated delta
    # Node: for deleting sCellAdditionMethod "calculate delta scf" creates an 'update' with empty value. 'update' with
    # empty value does also remove the parameter. But correction alredy done in taf. Next taf version
    # creates the expected 'delete'
    scf.Calculate Delta SCF
    ...  target_scf_path=${target_scf_name_gnb}
    ...  actual_scf_path=${basic_scf_name_gnb_${SOURCE_NODE_ID}}
    ...  delta_scf_path=${delta_scf_recommissioning_name}

    # if you want to do a delta_recommissioning instead of full commissioning following may work for you:
    # when built up the scf.xml file for the testcase, get current scf file, calculate delta scf and do a delta commissioning.
    # if no reboot is needed, delta_recommissioning is faster.

    syve_commissioning.Execute Recommissioning With Delta SCF File
    ...  node_type=gnb  node_id=${gnb_id}  delta_scf_recommissioning_name=${delta_scf_recommissioning_name}

################################################

Execute GNB Delta Commission JSON For CB006139_AA GNB-0 Part2
    [Arguments]    ${nrbts_id}  ${gnb_id}  ${target_scf_name_gnb}  ${delta_scf_recommissioning_name}
    [Documentation]    Commissioning of gnb for CB006139_AA, create new updated SCF with delta changes.
    ...    Only one file is required for updating gnb with delta changes.

    Log To Console  Start commissioning for gnb-${SOURCE_NODE_ID}
    scf.Load SCF  ${basic_scf_name_gnb_${SOURCE_NODE_ID}}


    # !!! sepecial attention to  \$ after e.g.  NRCELL-1  !!! if this is not given also NRCELL-11, NRCELL-15 ... are modified!
    # this wildcard behavior is not clear from taf documentation.

    @{GNB_PARAMS_IN_SCF}   Create List
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}\$:actBufferBasedSCellAddition=oneShot_stepWise_Dl_Fr1

    scf.Perform SCF Modification    modification_strings=${GNB_PARAMS_IN_SCF}

    scf.Save SCF  ${target_scf_name_gnb}

    # create delta to check if modify_scf_element or perform_scf_modification worked correct by glance at generated delta
    # Node: for deleting sCellAdditionMethod "calculate delta scf" creates an 'update' with empty value. 'update' with
    # empty value does also remove the parameter. But correction alredy done in taf. Next taf version
    # creates the expected 'delete'
    scf.Calculate Delta SCF
    ...  target_scf_path=${target_scf_name_gnb}
    ...  actual_scf_path=${basic_scf_name_gnb_${SOURCE_NODE_ID}}
    ...  delta_scf_path=${delta_scf_recommissioning_name}

    # if you want to do a delta_recommissioning instead of full commissioning following may work for you:
    # when built up the scf.xml file for the testcase, get current scf file, calculate delta scf and do a delta commissioning.
    # if no reboot is needed, delta_recommissioning is faster.

    syve_commissioning.Execute Recommissioning With Delta SCF File
    ...  node_type=gnb  node_id=${gnb_id}  delta_scf_recommissioning_name=${delta_scf_recommissioning_name}

#################################################################

Execute GNB Delta Commission JSON For CB006139_EA GNB-0
    [Arguments]    ${nrbts_id}  ${gnb_id}  ${target_scf_name_gnb}  ${delta_scf_recommissioning_name}
    [Documentation]    Commissioning of gnb for CB006139_EA, create new updated SCF with delta changes.
    ...    Only one file is required for updating gnb with delta changes.

    Log To Console  Start commissioning for gnb-${SOURCE_NODE_ID}
    scf.Load SCF  ${basic_scf_name_gnb_${SOURCE_NODE_ID}}


    # !!! sepecial attention to  \$ after e.g.  NRCELL-1  !!! if this is not given also NRCELL-11, NRCELL-15 ... are modified!
    # this wildcard behavior is not clear from taf documentation.

    @{GNB_PARAMS_IN_SCF}   Create List
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}\$:actOverheatingAssistance=false
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}\$:sCellExcludelistTimerFr1=12
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}\$:sCellActivationMethod=blind
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}\$:sCellDeactivationBadRlqCount=2
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRDU-1\$:actInterGnbCa=DLOnly
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-10\$:actK1Opt=intraAndInter-gNB
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}:iGnbCaXnCfUpBackOffTmr=0
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}:iGnbCaXnRemovalTmr=10
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}:iGnbCaXnSetupReqTmr=60
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}:iGnbCaXnSetupRespTmr=5
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}:intGnbScellTempBlockTmr=60
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}:weightForIgnbCaSelection=1

    FOR  ${nrcell}  IN RANGE  1  25
        Collections.Append To List  ${GNB_PARAMS_IN_SCF}
        ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}:sCellDeactivationTimerGNB=infinity
    END


    scf.Perform SCF Modification    modification_strings=${GNB_PARAMS_IN_SCF}
    scf.Save SCF  ${target_scf_name_gnb}
    scf.Calculate Delta SCF
    ...  target_scf_path=${target_scf_name_gnb}
    ...  actual_scf_path=${basic_scf_name_gnb_${SOURCE_NODE_ID}}
    ...  delta_scf_path=${delta_scf_recommissioning_name}

    syve_commissioning.Execute Recommissioning With Delta SCF File
    ...  node_type=gnb  node_id=${gnb_id}  delta_scf_recommissioning_name=${delta_scf_recommissioning_name}

################################################################

Execute gNB Delta Commission JSON For CB006139_EA GNB-1
    [Arguments]    ${nrbts_id}  ${gnb_id}  ${target_scf_name_gnb}  ${delta_scf_recommissioning_name}
    [Documentation]    Commissioning of gnb for CB006139_EA, create new updated SCF with delta changes.
    ...    Only one file is required for updating gnb with delta changes.

    Log To Console  Start commissioning for gnb-${TARGET_NODE_ID}
    scf.Load SCF  ${basic_scf_name_gnb_${TARGET_NODE_ID}}


    # !!! sepecial attention to  \$ after e.g.  NRCELL-1  !!! if this is not given also NRCELL-11, NRCELL-15 ... are modified!
    # this wildcard behavior is not clear from taf documentation.

    @{GNB_PARAMS_IN_SCF}   Create List
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}\$:actCarAgPmCount=true
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}\$:actMfbiNrCaSupportFr1=false
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}\$:actOverheatingAssistance=false
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}\$:sCellExcludelistTimerFr1=12
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}\$:sCellDeactivationBadRlqCount=2
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}\$:sCellActivationMethod=blind
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRPMRNL-1\$:miNrCaDu=5min
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-2\$:actAperCsi=false

    scf.Perform SCF Modification    modification_strings=${GNB_PARAMS_IN_SCF}
    scf.Save SCF  ${target_scf_name_gnb}
    scf.Calculate Delta SCF
    ...  target_scf_path=${target_scf_name_gnb}
    ...  actual_scf_path=${basic_scf_name_gnb_${TARGET_NODE_ID}}
    ...  delta_scf_path=${delta_scf_recommissioning_name}

    syve_commissioning.Execute Recommissioning With Delta SCF File
    ...  node_type=gnb  node_id=${gnb_id}  delta_scf_recommissioning_name=${delta_scf_recommissioning_name}

################################################################

Execute GNB Test Commissionion JSON For CB006139_EA GNB-0 Part1
    [Arguments]    ${nrbts_id}  ${gnb_id}  ${target_scf_name_gnb}  ${delta_scf_recommissioning_name}
    [Documentation]    Commissioning of gnb for CB006139_EA, create new updated SCF with delta changes.
    ...    Only one file is required for updating gnb with delta changes.

    Log To Console  Start commissioning for gnb-${SOURCE_NODE_ID} Part1

    Set Suite Variable   ${current_base_scf_${SOURCE_NODE_ID}_Part1_1}
    ...    ${configSuiteDir}/current_updated_scf_gnb_${SOURCE_NODE_ID}_Part1_1.xml
    ${current_base_scf_1}=  scf_info.Collect the Current SCF file  node_id=${gnb_id}  node_type=gnb  file_name=CurrentScfPart1_1.xml

    scf.Load SCF  ${current_base_scf_1}
    FOR  ${nrrel_id}    IN    101  103  104
        scf.Add Element To SCF
        ...  dist_name=MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-10/NRREL-${nrrel_id}
        ...  p_name=sCellAdditionMethod
        ...  value=blind
        scf.Add Element To SCF
        ...  dist_name=MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-10/NRREL-${nrrel_id}
        ...  p_name=sCellOperationalMode
        ...  value=dlOnly
    END

    scf.Save SCF  ${target_scf_name_gnb}
    scf.Calculate Delta SCF
    ...  target_scf_path=${target_scf_name_gnb}
    ...  actual_scf_path=${current_base_scf_1}
    ...  delta_scf_path=${delta_scf_recommissioning_name}

    syve_commissioning.Execute Recommissioning With Delta SCF File
    ...  node_type=gnb  node_id=${gnb_id}  delta_scf_recommissioning_name=${delta_scf_recommissioning_name}

###############################################################

Execute GNB Test Commissionion JSON For CB006139_EA GNB-0 Part2
    [Arguments]    ${nrbts_id}  ${gnb_id}  ${target_scf_name_gnb}  ${delta_scf_recommissioning_name}
    [Documentation]    Commissioning of gnb for CB006139_EA, create new updated SCF with delta changes.
    ...    Only one file is required for updating gnb with delta changes.

    Log To Console  Start commissioning for gnb-${SOURCE_NODE_ID} Part2
    Set Suite Variable   ${current_base_scf_${SOURCE_NODE_ID}_Part2}
    ...    ${configSuiteDir}/current_updated_scf_gnb_${SOURCE_NODE_ID}_Part2.xml

    ${current_base_scf_2}=  scf_info.Collect the Current SCF file  node_id=${gnb_id}  node_type=gnb  file_name=CurrentScfPart2.xml

    scf.Load SCF  ${current_base_scf_2}

    @{GNB_PARAMS_IN_SCF_Part2}   Create List
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}\$:actBufferBasedSCellAddition=oneShot_stepWise_Dl_Fr1

    scf.Perform SCF Modification    modification_strings=${GNB_PARAMS_IN_SCF_Part2}
    scf.Save SCF  ${target_scf_name_gnb}
    scf.Calculate Delta SCF
    ...  target_scf_path=${target_scf_name_gnb}
    ...  actual_scf_path=${current_base_scf_2}
    ...  delta_scf_path=${delta_scf_recommissioning_name}

    syve_commissioning.Execute Recommissioning With Delta SCF File
    ...  node_type=gnb  node_id=${gnb_id}  delta_scf_recommissioning_name=${delta_scf_recommissioning_name}
