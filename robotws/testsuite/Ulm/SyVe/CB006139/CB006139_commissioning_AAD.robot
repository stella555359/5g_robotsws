*** Settings ***
Documentation   Generic gNB Commissioning: CB006139 AAD
...             This is a Robot Test Suite for feature: CB006139 AAD
...             Feature:  CB006139 Buffer-based step-wise NR FR1 SCell addition
...             Author:  Antje Jooss
...             Team: I_MN_RAN_RD_VRF_ULM_VT2_GMS
...             Email: OU_MN_RAN_RD_VRF_ULM_2_53028393@internal.nsn.com


Resource    ../resources/syve_commissioning.robot
Resource    ../resources/scf_info.robot
Library     taf.config.scf


*** Keywords ***
Execute GNB Delta Commission JSON For CB006139_AAD GNB-0 Part1
    [Arguments]    ${nrbts_id}  ${gnb_id}  ${target_scf_name_gnb}  ${delta_scf_recommissioning_name}
    [Documentation]    Commissioning of gnb-0 for CB006139_AAD Part1, create new updated SCF with delta changes.
    ...    Only one file is required for updating gnb with delta changes.

    Log To Console  Start commissioning for gnb-${source_node_id}
    scf.Load SCF  ${basic_scf_name_gnb_${source_node_id}}


    # !!! sepecial attention to  \$ after e.g.  NRCELL-1  !!! if this is not given also NRCELL-11, NRCELL-15 ... are modified!
    # this wildcard behavior is not clear from taf documentation.

    @{GNB_PARAMS_IN_SCF}   Create List
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRPMRNL-1\$:miNrCaDu=5min
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}\$:actBufferBasedSCellAddition=oneShot_stepWise_Dl_Fr1
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1\$:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=86
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1\$:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=86
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRREL-7:sCellAdditionMethod=covBasedA1
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRREL-7:sCellOperationalMode=dlAndUl
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-7:increasePUSCHPrepTimeULCA=true
    ...  modify:MRBTS-${nrbts_id}/TNLSVC-1/PMTNLINT-1\$:ipV4AddressStatisticsInterval=5min

    FOR  ${nrrel}    IN    4  10  18  19
        Collections.Append To List  ${GNB_PARAMS_IN_SCF}
        ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRREL-${nrrel}:sCellAdditionMethod=covBasedA1
        ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRREL-${nrrel}:sCellOperationalMode=dlOnly
    END

    scf.Perform SCF Modification    modification_strings=${GNB_PARAMS_IN_SCF}
    scf.Save SCF  ${target_scf_name_gnb}

    scf.Calculate Delta SCF
    ...  target_scf_path=${target_scf_name_gnb}
    ...  actual_scf_path=${basic_scf_name_gnb_${source_node_id}}
    ...  delta_scf_path=${delta_scf_recommissioning_name}

    syve_commissioning.Execute Recommissioning With Delta SCF File
    ...  node_type=gnb  node_id=${gnb_id}  delta_scf_recommissioning_name=${delta_scf_recommissioning_name}

########################################################################

Execute GNB Delta Commission JSON For CB006139_AAD GNB-0 Part2
    [Arguments]    ${nrbts_id}  ${gnb_id}  ${target_scf_name_gnb}  ${delta_scf_recommissioning_name}
    [Documentation]    Commissioning of gnb-0 for CB006139_AAD Part2, create new updated SCF with delta changes.
    ...    Only one file is required for updating gnb with delta changes.

    Log To Console  Start commissioning for gnb-${source_node_id} Part2

    Set Suite Variable   ${current_base_scf_${source_node_id}_Part2}
    ...    ${configSuiteDir}/current_updated_scf_gnb_${source_node_id}_Part2.xml
    ${current_base_scf_2}=  scf_info.Collect the Current SCF file  node_id=${gnb_id}  node_type=gnb  file_name=CurrentScfPart2.xml
    scf.Load SCF  ${current_base_scf_2}


    # !!! sepecial attention to  \$ after e.g.  NRCELL-1  !!! if this is not given also NRCELL-11, NRCELL-15 ... are modified!
    # this wildcard behavior is not clear from taf documentation.

    @{GNB_PARAMS_IN_SCF}   Create List
    ...  delete:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRREL-18:sCellAdditionMethod
    ...  delete:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRREL-18:sCellOperationalMode

    scf.Perform SCF Modification    modification_strings=${GNB_PARAMS_IN_SCF}
    scf.Save SCF  ${target_scf_name_gnb}

    scf.Calculate Delta SCF
    ...  target_scf_path=${target_scf_name_gnb}
    ...  actual_scf_path=${current_base_scf_2}
    ...  delta_scf_path=${delta_scf_recommissioning_name}

    syve_commissioning.Execute Recommissioning With Delta SCF File
    ...  node_type=gnb  node_id=${gnb_id}  delta_scf_recommissioning_name=${delta_scf_recommissioning_name}

########################################################################

Execute GNB Delta Commission JSON For CB006139_AAD GNB-0 Part3
    [Arguments]    ${nrbts_id}  ${gnb_id}  ${target_scf_name_gnb}  ${delta_scf_recommissioning_name}
    [Documentation]    Commissioning of gnb-0 for CB006139_AAD Part3, create new updated SCF with delta changes.
    ...    Only one file is required for updating gnb with delta changes.

    Log To Console  Start commissioning for gnb-${source_node_id} Part3
    Set Suite Variable   ${current_base_scf_${source_node_id}_Part3}
    ...    ${configSuiteDir}/current_updated_scf_gnb_${source_node_id}_Part3.xml
    ${current_base_scf_3}=  scf_info.Collect the Current SCF file  node_id=${gnb_id}  node_type=gnb  file_name=CurrentScfPart3.xml
    scf.Load SCF  ${current_base_scf_3}


    # !!! sepecial attention to  \$ after e.g.  NRCELL-1  !!! if this is not given also NRCELL-11, NRCELL-15 ... are modified!
    # this wildcard behavior is not clear from taf documentation.

    @{GNB_PARAMS_IN_SCF}   Create List
    ...  delete:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRREL-10:sCellAdditionMethod
    ...  delete:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRREL-10:sCellOperationalMode

    scf.Perform SCF Modification    modification_strings=${GNB_PARAMS_IN_SCF}
    scf.Save SCF  ${target_scf_name_gnb}

    scf.Calculate Delta SCF
    ...  target_scf_path=${target_scf_name_gnb}
    ...  actual_scf_path=${current_base_scf_3}
    ...  delta_scf_path=${delta_scf_recommissioning_name}

    syve_commissioning.Execute Recommissioning With Delta SCF File
    ...  node_type=gnb  node_id=${gnb_id}  delta_scf_recommissioning_name=${delta_scf_recommissioning_name}
