*** Settings ***
Documentation   Generic eNB Commissioning: CB012121
...             This is a Robot Test Suite for feature: CB012121
...             Feature:  CB012121
...             Author:  Antje Jooss
...             Team: 'I_MN_RAN_RD_VRF_ULM_VT2_GMS'
...             Email: 'I_MN_RAN_RD_VRF_ULM_VT2@internal.nsn.com'


Resource    ../resources/sqd63/common_keywords.robot
Resource    ../resources/syve_commissioning.robot
Library     taf.sbts.oam.coam.admin            WITH NAME      admin
Library     Collections


*** Keywords ***
Execute GNB Delta Commission JSON For CB012121_A GNB-0
    [Arguments]    ${nrbts_id}  ${gnb_id}  ${target_scf_name_gnb}  ${delta_scf_recommissioning_name}
    [Documentation]    Commissioning of gnb for CB012121_A, create new updated SCF with delta changes.
    ...    Only one file is required for updating gnb with delta changes.

    Log To Console  Start commissioning for gnb-0
    scf.Load Scf  ${basic_scf_name_gnb_${source_node_id}}

    # !!! sepecial attention to  \$ after e.g.  NRCELL-1  !!! if this is not given also NRCELL-11, NRCELL-15 ... are modified!
    # this wildcard behavior is not clear from taf documentation.

    @{GNB_PARAMS_IN_SCF}   Create List
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3\$:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=70
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3\$:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=60
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRPMRNL-1\$:miNrMobilityReport=5min
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRPMRNL-1\$:miNrMobilityReportCu=5min
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRPMRNL-1\$:miNrRANS=5min
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRPMRNL-1\$:miNrNRMOP=5min

    IF    '${TL_NAME}' in ${TL_LIST}
        IF    'CB012121_A_05_TMO' in ${TEST TAGS}
            Collections.Append To List  ${GNB_PARAMS_IN_SCF}
            ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3/NRREL-102\$:handoverAllowedSA=forbidden
            ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3\$:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
            ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3\$:a3MeasSsbRsrp:a3OffsetSsbRsrp=3
            ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3\$:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
            ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRPMRNL-1\$:miNrNRMOP=5min
            ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRPMRNL-1\$:miNrNGCC=5min
            FOR  ${nrhoifid}    IN  5  8
                Collections.Append To List  ${GNB_PARAMS_IN_SCF}
                ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3/NRHOIF-${nrhoifid}\$:a3MeasEnabled=rsrp
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3/NRHOIF-${nrhoifid}:a3MeasSsbRsrp
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3/NRHOIF-${nrhoifid}:a3MeasSsbRsrp:{"a3HysteresisSsbRsrp":"0"}
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3/NRHOIF-${nrhoifid}:a3MeasSsbRsrp:a3OffsetSsbRsrp=3
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3/NRHOIF-${nrhoifid}:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
                ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3/NRHOIF-${nrhoifid}\$:a5MeasEnabled=rsrp
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3/NRHOIF-${nrhoifid}:a5MeasSsbRsrp
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3/NRHOIF-${nrhoifid}:a5MeasSsbRsrp:{"a5HysteresisSsbRsrp":"2"}
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3/NRHOIF-${nrhoifid}:a5MeasSsbRsrp:a5Threshold1SsbRsrp=55
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3/NRHOIF-${nrhoifid}:a5MeasSsbRsrp:a5Threshold2SsbRsrp=50
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3/NRHOIF-${nrhoifid}:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms256
            END
        ELSE IF    'CB012121_A_11' in ${TEST TAGS}
            Collections.Append To List  ${GNB_PARAMS_IN_SCF}
            ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3\$:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
            ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3\$:a3MeasSsbRsrp:a3OffsetSsbRsrp=3
            ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3\$:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
            ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRPMRNL-1\$:miNrNRMOP=5min
            ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRPMRNL-1\$:miNrNGCC=5min
            ...  delete:NRBTS-${nrbts_id}/NRCELL-3/NRREL-4
            ...  delete:NRBTS-${nrbts_id}/NRCELL-3/NRREL-10
            FOR  ${nrhoifid}    IN  2  4
                Collections.Append To List  ${GNB_PARAMS_IN_SCF}
                ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3/NRHOIF-${nrhoifid}\$:a3MeasEnabled=rsrp
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3/NRHOIF-${nrhoifid}:a3MeasSsbRsrp
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3/NRHOIF-${nrhoifid}:a3MeasSsbRsrp:{"a3HysteresisSsbRsrp":"0"}
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3/NRHOIF-${nrhoifid}:a3MeasSsbRsrp:a3OffsetSsbRsrp=3
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3/NRHOIF-${nrhoifid}:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
                ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3/NRHOIF-${nrhoifid}\$:a5MeasEnabled=rsrp
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3/NRHOIF-${nrhoifid}:a5MeasSsbRsrp
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3/NRHOIF-${nrhoifid}:a5MeasSsbRsrp:{"a5HysteresisSsbRsrp":"2"}
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3/NRHOIF-${nrhoifid}:a5MeasSsbRsrp:a5Threshold1SsbRsrp=55
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3/NRHOIF-${nrhoifid}:a5MeasSsbRsrp:a5Threshold2SsbRsrp=50
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3/NRHOIF-${nrhoifid}:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms256
            END
        END
    ELSE
        IF    'CB012121_A_05' in ${TEST TAGS}
            Collections.Append To List  ${GNB_PARAMS_IN_SCF}
            ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3/NRREL-4\$:handoverAllowedSA=forbidden
        ELSE IF    'CB012121_A_11' in ${TEST TAGS}
            Collections.Append To List  ${GNB_PARAMS_IN_SCF}
            ...  delete:NRBTS-${nrbts_id}/NRCELL-3/NRREL-1
            ...  delete:NRBTS-${nrbts_id}/NRCELL-3/NRREL-2
        END
    END

    scf.Perform SCF Modification    modification_strings=${GNB_PARAMS_IN_SCF}

    scf.Modify SCF Element
    ...  cellQuality
    ...  dist_name=MRBTS-${nrbts_id}/NRBTS-${nrbts_id}
    ...  p_name=actMeasurementStrategy

    scf.Modify SCF Element
    ...  10000
    ...  dist_name=MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3
    ...  p_name=bestCellWaitTimer


    scf.Save SCF  ${target_scf_name_gnb}

    # create delta to check if modify_scf_element or perform_scf_modification worked correct by glance at generated delta
    # Node: for deleting sCellAdditionMethod "calculate delta scf" creates an 'update' with empty value. 'update' with
    # empty value does also remove the parameter. But correction alredy done in taf. Next taf version
    # creates the expected 'delete'
    scf.calculate delta scf
    ...  target_scf_path=${target_scf_name_gnb}
    ...  actual_scf_path=${basic_scf_name_gnb_${source_node_id}}
    ...  delta_scf_path=${delta_scf_recommissioning_name}

    # if you want to do a delta_recommissioning instead of full commissioning following may work for you:
    # when built up the scf.xml file for the testcase, get current scf file, calculate delta scf and do a delta commissioning.
    # if no reboot is needed, delta_recommissioning is faster.

    syve_commissioning.Execute Recommissioning With Delta SCF File
    ...  node_type=gnb  node_id=${gnb_id}  delta_scf_recommissioning_name=${delta_scf_recommissioning_name}

######################################################

Execute GNB Delta Commission JSON For CB012121_A GNB-1
    [Documentation]    Commissioning of gnb for TC CB012121_A gnb-1, create new updated SCF with delta changes.
    ...            Only one file is required for updating gnb with delta changes.
    [Arguments]    ${nrbts_id}  ${gnb_id}  ${target_scf_name_gnb}  ${delta_scf_recommissioning_name}

    Log To Console    Start Commissioning for gnb-1
    scf.Load Scf  ${basic_scf_name_gnb_${target_node_id}}

    @{GNB_PARAMS_IN_SCF}   Create List

    IF    '${TL_NAME}' in ${TL_LIST}
        IF    'CB012121_A_05_TMO' in ${TEST TAGS}
            Collections.Append To List  ${GNB_PARAMS_IN_SCF}
            ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4\$:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=70
            ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4\$:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=60
            ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-2\$:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=70
            ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-2\$:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=60
            ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRPMRNL-1\$:miNrMobilityReport=5min
            ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRPMRNL-1\$:miNrMobilityReportCu=5min
            ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRPMRNL-1\$:miNrRANS=5min
            ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRPMRNL-1\$:miNrNRMOP=5min
            ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRPMRNL-1\$:miNrNGCC=5min
            ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4/NRHOIF-1\$:a3MeasEnabled=rsrp
            ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4/NRHOIF-1:a3MeasSsbRsrp
            ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4/NRHOIF-1:a3MeasSsbRsrp:{"a3HysteresisSsbRsrp":"0"}
            ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=3
            ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
            ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4/NRHOIF-1\$:a5MeasEnabled=rsrp
            ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4/NRHOIF-1:a5MeasSsbRsrp
            ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4/NRHOIF-1:a5MeasSsbRsrp:{"a5HysteresisSsbRsrp":"2"}
            ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=55
            ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=50
            ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms256
            ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-2/NRHOIF-1\$:a3MeasEnabled=rsrp
            ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-2/NRHOIF-1:a3MeasSsbRsrp
            ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:{"a3HysteresisSsbRsrp":"0"}
            ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=3
            ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms256
            ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-2/NRHOIF-1\$:a5MeasEnabled=rsrp
            ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-2/NRHOIF-1:a5MeasSsbRsrp
            ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-2/NRHOIF-1:a5MeasSsbRsrp:{"a5HysteresisSsbRsrp":"2"}
            ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-2/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=55
            ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-2/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=50
            ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-2/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms256
        END
    ELSE
        Collections.Append To List  ${GNB_PARAMS_IN_SCF}
        ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-2\$:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=70
        ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-2\$:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=60
    END

    scf.Perform Scf Modification    modification_strings=${GNB_PARAMS_IN_SCF}
    scf.Save SCF  ${target_scf_name_gnb}

    scf.Calculate Delta Scf
    ...  target_scf_path=${target_scf_name_gnb}
    ...  actual_scf_path=${basic_scf_name_gnb_${target_node_id}}
    ...  delta_scf_path=${delta_scf_recommissioning_name}

    syve_commissioning.Execute Recommissioning With Delta SCF File
    ...  node_type=gnb  node_id=${gnb_id}  delta_scf_recommissioning_name=${delta_scf_recommissioning_name}

######################################################

Execute GNB Delta Commission JSON For CB012121_B_01 GNB-0
    [Arguments]    ${nrbts_id}  ${gnb_id}  ${target_scf_name_gnb}  ${delta_scf_recommissioning_name}
    [Documentation]    Commissioning of gnb for TC B_11 CB012121, create new updated SCF with delta changes.
    ...    Only one file is required for updating gnb with delta changes.

    Log To Console  Start commissioning for gnb-0
    scf.Load Scf  ${basic_scf_name_gnb_${source_node_id}}

    @{GNB_PARAMS_IN_SCF}   create list
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3\$:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=70
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3\$:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=60
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRPMRNL-1\$:miNrMobilityReport=5min
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRPMRNL-1\$:miNrMobilityReportCu=5min
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRPMRNL-1\$:miNrRANS=5min
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRPMRNL-1\$:miNrNRMOP=5min

    IF    '${TL_NAME}' in ${TL_LIST}
        IF    'CB012121_B_01' in ${TEST TAGS}
            FOR  ${nrhoifid}    IN  5  8
                Collections.Append To List  ${GNB_PARAMS_IN_SCF}
                ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3/NRHOIF-${nrhoifid}\$:a3MeasEnabled=rsrp
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3/NRHOIF-${nrhoifid}:a3MeasSsbRsrp
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3/NRHOIF-${nrhoifid}:a3MeasSsbRsrp:{"a3HysteresisSsbRsrp":"0"}
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3/NRHOIF-${nrhoifid}:a3MeasSsbRsrp:a3OffsetSsbRsrp=3
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3/NRHOIF-${nrhoifid}:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
                ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3/NRHOIF-${nrhoifid}\$:a5MeasEnabled=rsrp
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3/NRHOIF-${nrhoifid}:a5MeasSsbRsrp
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3/NRHOIF-${nrhoifid}:a5MeasSsbRsrp:{"a5HysteresisSsbRsrp":"2"}
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3/NRHOIF-${nrhoifid}:a5MeasSsbRsrp:a5Threshold1SsbRsrp=55
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3/NRHOIF-${nrhoifid}:a5MeasSsbRsrp:a5Threshold2SsbRsrp=50
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3/NRHOIF-${nrhoifid}:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms256
            END
            FOR  ${nrcell}    IN  1  2  3
                Collections.Append To List  ${GNB_PARAMS_IN_SCF}
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-2:a3a5Priority=30
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-3:a3a5Priority=30
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-4:a3a5Priority=30
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-5:a3a5Priority=20
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-6:a3a5Priority=30
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-7:a3a5Priority=30
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-8:a3a5Priority=10
            END
            FOR  ${nrcell}    IN  4  6  8
                Collections.Append To List  ${GNB_PARAMS_IN_SCF}
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-1:a3a5Priority=30
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-3:a3a5Priority=30
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-4:a3a5Priority=30
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-5:a3a5Priority=20
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-6:a3a5Priority=30
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-7:a3a5Priority=30
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-8:a3a5Priority=10
            END
            FOR  ${nrcell}    IN  5  7  9
                Collections.Append To List  ${GNB_PARAMS_IN_SCF}
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-1:a3a5Priority=30
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-2:a3a5Priority=30
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-4:a3a5Priority=30
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-5:a3a5Priority=20
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-6:a3a5Priority=30
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-7:a3a5Priority=30
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-8:a3a5Priority=10
            END
            FOR  ${nrcell}    IN  10
                Collections.Append To List  ${GNB_PARAMS_IN_SCF}
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-1:a3a5Priority=30
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-2:a3a5Priority=30
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-3:a3a5Priority=30
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-5:a3a5Priority=20
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-6:a3a5Priority=30
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-7:a3a5Priority=30
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-8:a3a5Priority=10
            END
            FOR  ${nrcell}    IN  11
                Collections.Append To List  ${GNB_PARAMS_IN_SCF}
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-1:a3a5Priority=30
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-2:a3a5Priority=30
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-3:a3a5Priority=30
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-4:a3a5Priority=30
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-6:a3a5Priority=30
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-7:a3a5Priority=30
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-8:a3a5Priority=10
            END
            FOR  ${nrcell}    IN  12
                Collections.Append To List  ${GNB_PARAMS_IN_SCF}
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-1:a3a5Priority=30
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-2:a3a5Priority=30
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-3:a3a5Priority=30
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-4:a3a5Priority=30
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-5:a3a5Priority=20
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-7:a3a5Priority=30
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-8:a3a5Priority=10
            END
            FOR  ${nrcell}    IN  13
                Collections.Append To List  ${GNB_PARAMS_IN_SCF}
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-1:a3a5Priority=30
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-2:a3a5Priority=30
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-3:a3a5Priority=30
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-4:a3a5Priority=30
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-5:a3a5Priority=20
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-6:a3a5Priority=30
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-8:a3a5Priority=10
            END
        END
    ELSE
        IF    'CB012121_B_01' in ${TEST TAGS}
            Collections.Append To List  ${GNB_PARAMS_IN_SCF}
            ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRHOIF-1:a3a5Priority=10
            ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRHOIF-2:a3a5Priority=20
            ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-2/NRHOIF-1:a3a5Priority=10
            ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-2/NRHOIF-2:a3a5Priority=20
            ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3/NRHOIF-1:a3a5Priority=10
            ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3/NRHOIF-2:a3a5Priority=20
        END
    END

    scf.Perform SCF Modification    modification_strings=${GNB_PARAMS_IN_SCF}
    scf.Save SCF  ${target_scf_name_gnb}

    scf.Modify SCF Element
    ...  priority
    ...  dist_name=MRBTS-${nrbts_id}/NRBTS-${nrbts_id}
    ...  p_name=actMeasurementStrategy

    scf.Modify SCF Element
    ...  10000
    ...  dist_name=MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-3
    ...  p_name=priorityWaitTimer


    scf.Save SCF  ${target_scf_name_gnb}

    # create delta to check if modify_scf_element or perform_scf_modification worked correct by glance at generated delta
    # Node: for deleting sCellAdditionMethod "calculate delta scf" creates an 'update' with empty value. 'update' with
    # empty value does also remove the parameter. But correction alredy done in taf. Next taf version
    # creates the expected 'delete'
    scf.calculate delta scf
    ...  target_scf_path=${target_scf_name_gnb}
    ...  actual_scf_path=${basic_scf_name_gnb_${source_node_id}}
    ...  delta_scf_path=${delta_scf_recommissioning_name}

    # if you want to do a delta_recommissioning instead of full commissioning following may work for you:
    # when built up the scf.xml file for the testcase, get current scf file, calculate delta scf and do a delta commissioning.
    # if no reboot is needed, delta_recommissioning is faster.

    syve_commissioning.Execute Recommissioning With Delta SCF File
    ...  node_type=gnb  node_id=${gnb_id}  delta_scf_recommissioning_name=${delta_scf_recommissioning_name}

######################################################

Execute GNB Delta Commission JSON For CB012121_B_01 GNB-1
    [Arguments]    ${nrbts_id}  ${gnb_id}  ${target_scf_name_gnb}  ${delta_scf_recommissioning_name}
    [Documentation]    Commissioning of gnb for TC B_11 CB012121, create new updated SCF with delta changes.
    ...    Only one file is required for updating gnb with delta changes.

    Log To Console  Start commissioning for gnb-1
    scf.Load Scf  ${basic_scf_name_gnb_${target_node_id}}

    @{GNB_PARAMS_IN_SCF}   Create List
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4\$:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=70
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4\$:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=60
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-2\$:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=70
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-2\$:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=60
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4/NRHOIF-1\$:a3MeasEnabled=rsrp
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4/NRHOIF-1:a3MeasSsbRsrp
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4/NRHOIF-1:a3MeasSsbRsrp:{"a3HysteresisSsbRsrp":"0"}
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=6
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4/NRHOIF-1\$:a5MeasEnabled=rsrp
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4/NRHOIF-1:a5MeasSsbRsrp
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4/NRHOIF-1:a5MeasSsbRsrp:{"a5HysteresisSsbRsrp":"2"}
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=55
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=50
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms256
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-2/NRHOIF-1\$:a3MeasEnabled=rsrp
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-2/NRHOIF-1:a3MeasSsbRsrp
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:{"a3HysteresisSsbRsrp":"0"}
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=6
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms256
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-2/NRHOIF-1\$:a5MeasEnabled=rsrp
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-2/NRHOIF-1:a5MeasSsbRsrp
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-2/NRHOIF-1:a5MeasSsbRsrp:{"a5HysteresisSsbRsrp":"2"}
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-2/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=55
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-2/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=50
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-2/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms256

    scf.Perform SCF Modification    modification_strings=${GNB_PARAMS_IN_SCF}

    scf.Save SCF  ${target_scf_name_gnb}

    # create delta to check if modify_scf_element or perform_scf_modification worked correct by glance at generated delta
    # Node: for deleting sCellAdditionMethod "calculate delta scf" creates an 'update' with empty value. 'update' with
    # empty value does also remove the parameter. But correction alredy done in taf. Next taf version
    # creates the expected 'delete'
    scf.Calculate Delta SCF
    ...  target_scf_path=${target_scf_name_gnb}
    ...  actual_scf_path=${basic_scf_name_gnb_${target_node_id}}
    ...  delta_scf_path=${delta_scf_recommissioning_name}

    # if you want to do a delta_recommissioning instead of full commissioning following may work for you:
    # when built up the scf.xml file for the testcase, get current scf file, calculate delta scf and do a delta commissioning.
    # if no reboot is needed, delta_recommissioning is faster.

    syve_commissioning.Execute Recommissioning With Delta SCF File
    ...  node_type=gnb  node_id=${gnb_id}  delta_scf_recommissioning_name=${delta_scf_recommissioning_name}

######################################################

Execute GNB Delta Commission JSON For CB012121_B_11 GNB-0
    [Arguments]    ${nrbts_id}  ${gnb_id}  ${target_scf_name_gnb}  ${delta_scf_recommissioning_name}
    [Documentation]    Commissioning of gnb for TC B_11 CB012121, create new updated SCF with delta changes.
    ...    Only one file is required for updating gnb with delta changes.

    Log To Console  Start commissioning for gnb-0
    scf.Load SCF  ${basic_scf_name_gnb_${source_node_id}}

    @{GNB_PARAMS_IN_SCF}   Create List
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1\$:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=70
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1\$:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=60
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRPMRNL-1\$:miNrMobilityReport=5min
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRPMRNL-1\$:miNrMobilityReportCu=5min
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRPMRNL-1\$:miNrRANS=5min

    IF    '${TL_NAME}' in ${TL_LIST}
        IF    'CB012121_B_11' in ${TEST TAGS}
            Collections.Append To List  ${GNB_PARAMS_IN_SCF}
            ...  delete:NRBTS-${nrbts_id}/NRCELL-1/NRREL-4
            ...  delete:NRBTS-${nrbts_id}/NRCELL-1/NRREL-101
            ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4\$:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=70
            ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4\$:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=60
            ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1\$:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
            ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1\$:a3MeasSsbRsrp:a3OffsetSsbRsrp=3
            ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1\$:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
            ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRHOIF-2\$:a3MeasEnabled=rsrp
            ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRHOIF-2:a3MeasSsbRsrp
            ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:{"a3HysteresisSsbRsrp":"0"}
            ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=6
            ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
            ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRHOIF-2\$:a5MeasEnabled=rsrp
            ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRHOIF-2:a5MeasSsbRsrp
            ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRHOIF-2:a5MeasSsbRsrp:{"a5HysteresisSsbRsrp":"2"}
            ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRHOIF-2:a5MeasSsbRsrp:a5Threshold1SsbRsrp=55
            ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRHOIF-2:a5MeasSsbRsrp:a5Threshold2SsbRsrp=50
            ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRHOIF-2:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms256
            FOR  ${nrcell}    IN  1  2  3
                Collections.Append To List  ${GNB_PARAMS_IN_SCF}
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-2:a3a5Priority=100
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-3:a3a5Priority=99
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-4:a3a5Priority=55
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-5:a3a5Priority=55
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-6:a3a5Priority=55
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-7:a3a5Priority=55
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-8:a3a5Priority=55
            END
            FOR  ${nrcell}    IN  4  6  8
                Collections.Append To List  ${GNB_PARAMS_IN_SCF}
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-1:a3a5Priority=55
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-3:a3a5Priority=99
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-4:a3a5Priority=55
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-5:a3a5Priority=55
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-6:a3a5Priority=55
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-7:a3a5Priority=55
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-8:a3a5Priority=55
            END
            FOR  ${nrcell}    IN  5  7  9
                Collections.Append To List  ${GNB_PARAMS_IN_SCF}
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-1:a3a5Priority=55
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-2:a3a5Priority=100
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-4:a3a5Priority=55
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-5:a3a5Priority=55
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-6:a3a5Priority=55
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-7:a3a5Priority=55
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-8:a3a5Priority=20
            END
            FOR  ${nrcell}    IN  10
                Collections.Append To List  ${GNB_PARAMS_IN_SCF}
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-1:a3a5Priority=55
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-2:a3a5Priority=100
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-3:a3a5Priority=99
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-5:a3a5Priority=55
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-6:a3a5Priority=55
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-7:a3a5Priority=55
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-8:a3a5Priority=55
            END
            FOR  ${nrcell}    IN  11
                Collections.Append To List  ${GNB_PARAMS_IN_SCF}
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-1:a3a5Priority=55
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-2:a3a5Priority=100
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-3:a3a5Priority=99
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-4:a3a5Priority=55
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-6:a3a5Priority=55
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-7:a3a5Priority=55
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-8:a3a5Priority=55
            END
            FOR  ${nrcell}    IN  12
                Collections.Append To List  ${GNB_PARAMS_IN_SCF}
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-1:a3a5Priority=99
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-2:a3a5Priority=100
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-3:a3a5Priority=55
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-4:a3a5Priority=55
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-5:a3a5Priority=55
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-7:a3a5Priority=55
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-8:a3a5Priority=55
            END
            FOR  ${nrcell}    IN  13
                Collections.Append To List  ${GNB_PARAMS_IN_SCF}
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-1:a3a5Priority=99
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-2:a3a5Priority=100
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-3:a3a5Priority=55
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-4:a3a5Priority=55
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-5:a3a5Priority=55
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-6:a3a5Priority=55
                ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}/NRHOIF-8:a3a5Priority=55
            END
        END
    ELSE
        IF    'CB012121_B_11' in ${TEST TAGS}
            Collections.Append To List  ${GNB_PARAMS_IN_SCF}
            ...  add:NRBTS-${nrbts_id}/NRCELL-1/NRHOIF-1:a3a5Priority=100
            ...  add:NRBTS-${nrbts_id}/NRCELL-1/NRHOIF-2:a3a5Priority=99
            ...  add:NRBTS-${nrbts_id}/NRCELL-2/NRHOIF-1:a3a5Priority=55
            ...  add:NRBTS-${nrbts_id}/NRCELL-2/NRHOIF-2:a3a5Priority=55
            ...  add:NRBTS-${nrbts_id}/NRCELL-3/NRHOIF-1:a3a5Priority=55
            ...  add:NRBTS-${nrbts_id}/NRCELL-3/NRHOIF-2:a3a5Priority=55
            ...  delete:NRBTS-${nrbts_id}/NRCELL-1/NRREL-4
        END
    END

    scf.Perform SCF Modification    modification_strings=${GNB_PARAMS_IN_SCF}

    scf.Modify SCF Element
    ...  priority
    ...  dist_name=MRBTS-${nrbts_id}/NRBTS-${nrbts_id}
    ...  p_name=actMeasurementStrategy

    scf.Modify SCF Element
    ...  10000
    ...  dist_name=MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...  p_name=priorityWaitTimer

    scf.Save SCF  ${target_scf_name_gnb}

    # create delta to check if modify_scf_element or perform_scf_modification worked correct by glance at generated delta
    # Node: for deleting sCellAdditionMethod "calculate delta scf" creates an 'update' with empty value. 'update' with
    # empty value does also remove the parameter. But correction alredy done in taf. Next taf version
    # creates the expected 'delete'
    scf.Calculate Delta SCF
    ...  target_scf_path=${target_scf_name_gnb}
    ...  actual_scf_path=${basic_scf_name_gnb_${source_node_id}}
    ...  delta_scf_path=${delta_scf_recommissioning_name}

    # if you want to do a delta_recommissioning instead of full commissioning following may work for you:
    # when built up the scf.xml file for the testcase, get current scf file, calculate delta scf and do a delta commissioning.
    # if no reboot is needed, delta_recommissioning is faster.

    syve_commissioning.Execute Recommissioning With Delta SCF File
    ...  node_type=gnb  node_id=${gnb_id}  delta_scf_recommissioning_name=${delta_scf_recommissioning_name}

##############################################################

Execute GNB Delta Commission JSON For CB012121_B_11 GNB-1
    [Arguments]    ${nrbts_id}  ${gnb_id}  ${target_scf_name_gnb}  ${delta_scf_recommissioning_name}
    [Documentation]    Commissioning of gnb for TC B_11 CB012121, create new updated SCF with delta changes.
    ...    Only one file is required for updating gnb with delta changes.

    Log To Console  Start commissioning for gnb-1
    scf.Load SCF  ${basic_scf_name_gnb_${target_node_id}}

    @{GNB_PARAMS_IN_SCF}   Create List
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1\$:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=70
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1\$:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=60

    scf.Perform SCF Modification    modification_strings=${GNB_PARAMS_IN_SCF}
    scf.Save SCF  ${target_scf_name_gnb}

    # create delta to check if modify_scf_element or perform_scf_modification worked correct by glance at generated delta
    # Node: for deleting sCellAdditionMethod "calculate delta scf" creates an 'update' with empty value. 'update' with
    # empty value does also remove the parameter. But correction alredy done in taf. Next taf version
    # creates the expected 'delete'
    scf.Calculate Delta SCF
    ...  target_scf_path=${target_scf_name_gnb}
    ...  actual_scf_path=${basic_scf_name_gnb_${target_node_id}}
    ...  delta_scf_path=${delta_scf_recommissioning_name}

    # if you want to do a delta_recommissioning instead of full commissioning following may work for you:
    # when built up the scf.xml file for the testcase, get current scf file, calculate delta scf and do a delta commissioning.
    # if no reboot is needed, delta_recommissioning is faster.

    syve_commissioning.Execute Recommissioning With Delta SCF File
    ...  node_type=gnb  node_id=${gnb_id}  delta_scf_recommissioning_name=${delta_scf_recommissioning_name}
