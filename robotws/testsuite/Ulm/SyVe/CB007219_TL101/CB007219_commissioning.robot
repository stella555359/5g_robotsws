*** Settings ***
Documentation   covers the commissioning for the CB007219 TCs



#-----------------------------------------------------------------------------------------------------------------------------------[150 characters]
Library    taf.sbts.oam.coam.admin          WITH NAME   admin
Library    taf.config.scf                   WITH NAME   scf
Library    taf.ue

Resource   ../../resources/Common/testline.robot
Resource   ../resources/scf_info.robot

*** Keywords ***
Commissioning gNB
   [Arguments]   ${test_name}

   Log to Console  [Info:] Start commissioning for gNB-${gnb_id} and \n testcase ${test_name}
   run keyword  Commissioning gNB for ${test_name}  gnb_id=${gnb_id}  enb_id=${enb_id}
   Log to Console  [Info:] Commissioning for gNB-${gnb_id} finished

######

Commissioning gNB for TC25_AA_B14_Interaction_with_A1_measurement_based_PCell_switch
    [Documentation]    Commissioning of gnb for TC25
    ...                to overcome linter warning in case of unused variables, variable "enb_id=${enb_id}" was exchanged with "&{_}"
    ...                that means that there can be additional variable or not
    [Arguments]        ${gnb_id}=${0}   &{_}

    ${configDir}=    testline.Get Testcase Log Directory
    scf_info.Set MNL version string for branch    basic_scf_name=${configDir}/SCFC_gNB${gnb_id}_DU.xml
    scf.load_scf  file_path=${configDir}/SCFC_gNB${gnb_id}_DU.xml

    #to overcome the 150 sign limitiation
    ${nrbts_nidd}=   Set Variable    MRBTS-${nrbts_id_${gnb_id}}/NRBTS-${nrbts_id_${gnb_id}}

    #  START - parameter changes
    #  cell mapping 109->101:  1 -> 3 (n66), 688 -> 10 (n78), 691 -> 13 (n78)
    @{GNB_PARAMS_IN_SCF}   create list

    #  NRBTS parameters
    ...  modify:${nrbts_nidd}\$:sCellActivationMethod=blind
    ...  modify:${nrbts_nidd}\$:actOverheatingAssistance=false
    ...  modify:${nrbts_nidd}\$:actExtN77Support=false
    ...  modify:${nrbts_nidd}\$:actHighestEstNrTputBcSel=true
    ...  modify:${nrbts_nidd}\$:actMfbiNrCaMeasConfResolv=false
    ...  modify:${nrbts_nidd}\$:drbInactivityTimerSA=600
    ...  modify:${nrbts_nidd}\$:srbInactivityTimerSA=600
    ...  modify:${nrbts_nidd}\$:actHighestEstNrTputBcSel=true
    ...  modify:${nrbts_nidd}/NRCELL-${p_cell}/NRHOIF-6\$:a1BasedPCellSwitchEnabled=true
    ...  modify:${nrbts_nidd}/NRCELL-${p_cell}/NRHOIF-6\$:ssbFrequency=635712
    ...  modify:${nrbts_nidd}/NRCELL-${p_cell}/NRHOIF-7\$:a1BasedPCellSwitchEnabled=true
    ...  modify:${nrbts_nidd}/NRCELL-${p_cell}/NRHOIF-7\$:ssbFrequency=648672
    ...  modify:${nrbts_nidd}\$:actSCellReleaseBadSCellRlq=disabled
    ...  modify:${nrbts_nidd}\$:actBufferBasedSCellAddition=disabled
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrCaDu=5min

    #  NRCELL-X parameters
    # tbd    ...  modify:${nrbts_nidd}/NRCELL-3\$:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70
    ...  add:${nrbts_nidd}/NRCELL-3:a1MeasPCellSwitchEnabled=none
    ...  modify:${nrbts_nidd}/NRCELL-3\$:ifhoSsbSmtcOffset=0
    ...  modify:${nrbts_nidd}/NRCELL-3\$:measGapSelectionSA=favourUeThroughput
    ...  modify:${nrbts_nidd}/NRCELL-3\$:mgta=ms0dot5
    # tbd    ...  modify:${nrbts_nidd}/NRCELL-3\$:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70
    ...  add:${nrbts_nidd}/NRCELL-10:a6MeasSCellSwapEnabled=rsrp
    ...  add:${nrbts_nidd}/NRCELL-13:ssbSmtc1Duration=sf5
    ...  add:${nrbts_nidd}/NRCELL-13:ssbSmtc1Offset=0
    ...  add:${nrbts_nidd}/NRCELL-13:ssbSmtc1Periodicity=sf20

    FOR    ${nrcell}    IN
    ...     10
    ...     13

        append to list  ${GNB_PARAMS_IN_SCF}
        #  change of nrsysinfoprofile is not needed, because cell 10 and 13 already use profile-4 with band 77 indication
        #  original in TL109:  ...  modify:NRBTS-${nrbts_id_${gnb_id}}/NRCELL-${nrcell}\$:nrSysInfoProfileDN=${nrbts_nidd}/NRSYSINFO_PROFILE-77
        ...  add:${nrbts_nidd}/NRCELL-${nrcell}:thresholdSCellSwapSourceRsrp=76
        ...  add:${nrbts_nidd}/NRCELL-${nrcell}:a2MeasSCellRelSsbRsrp
        ...  add:${nrbts_nidd}/NRCELL-${nrcell}:a2MeasSCellRelSsbRsrp:{"a2HysteresisSCellRelSsbRsrp":"0"}
        ...  add:${nrbts_nidd}/NRCELL-${nrcell}:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=50
        ...  add:${nrbts_nidd}/NRCELL-${nrcell}:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=480ms
        ...  modify:${nrbts_nidd}/NRCELL-${nrcell}\$:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70
        ...  modify:${nrbts_nidd}/NRCELL-${nrcell}\$:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70
        ...  add:${nrbts_nidd}/NRCELL-${nrcell}:a6MeasSCellSwapSsbRsrp
        ...  add:${nrbts_nidd}/NRCELL-${nrcell}:a6MeasSCellSwapSsbRsrp:{"a6HysteresisSCellSwapSsbRsrp":"0"}
        ...  add:${nrbts_nidd}/NRCELL-${nrcell}:a6MeasSCellSwapSsbRsrp:a6OffsetSCellSwapSsbRsrp=6
        ...  add:${nrbts_nidd}/NRCELL-${nrcell}:a6MeasSCellSwapSsbRsrp:a6TimeToTrigSCellSwapSsbRsrp=ms480
        ...  add:${nrbts_nidd}/NRCELL-${nrcell}:a6MeasSCellSwapSsbRsrp:useAllowedCellListRsrp=false
        ...  add:${nrbts_nidd}/NRCELL-${nrcell}:a1MeasPCellSwitchEnabled=rsrp
        ...  add:${nrbts_nidd}/NRCELL-${nrcell}:reportAmountA6MeasSCellSwap=r4
        ...  add:${nrbts_nidd}/NRCELL-${nrcell}:reportIntervalA6MeasSCellSwap=ms1024
        ...  add:${nrbts_nidd}/NRCELL-${nrcell}:a2MeasSCellRelEnabled=none
        ...  modify:${nrbts_nidd}/NRCELL-${nrcell}\$:sCellInactivityReleaseTimer=0
    END

    #  FDD cells  a1MeasPCellSwitchSsbRsrp is not configured for cell-3 in base SCF at all -> has to be added
    FOR    ${nrcell}    IN
    ...      3
       append to list  ${GNB_PARAMS_IN_SCF}
        ...  add:${nrbts_nidd}/NRCELL-${nrcell}:a1MeasPCellSwitchSsbRsrp
        ...  add:${nrbts_nidd}/NRCELL-${nrcell}:a1MeasPCellSwitchSsbRsrp:{"a1HysteresisPCellSwitchSsbRsrp":"0"}
    # for testing...  add:${nrbts_nidd}/NRCELL-${nrcell}:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=75
        ...  add:${nrbts_nidd}/NRCELL-${nrcell}:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=60
        ...  add:${nrbts_nidd}/NRCELL-${nrcell}:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=480ms
        ...  add:${nrbts_nidd}/NRCELL-${nrcell}:a2MeasPCellSwitchEnabled=none
        ...  add:${nrbts_nidd}/NRCELL-${nrcell}:a2MeasPCellSwitchSsbRsrp
        ...  add:${nrbts_nidd}/NRCELL-${nrcell}:a2MeasPCellSwitchSsbRsrp:{"a2HysteresisPCellSwitchSsbRsrp":"0"}
        ...  add:${nrbts_nidd}/NRCELL-${nrcell}:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=65
        ...  add:${nrbts_nidd}/NRCELL-${nrcell}:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=480ms
        ...  add:${nrbts_nidd}/NRCELL-${nrcell}:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=0
        ...  modify:${nrbts_nidd}/NRCELL-${nrcell}\$:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=85
        ...  modify:${nrbts_nidd}/NRCELL-${nrcell}\$:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=40
        # change redirect threshold to pass validation check (40 - 0)/2  >  (34 - 0)/2
        ...  modify:${nrbts_nidd}/NRCELL-${nrcell}\$:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=34
    END

    #  TDD cells a1MeasPCellSwitchSsbRsrp is configured for cell-10 and cell-13 in base SCF -> has to be modified
    FOR    ${nrcell}    IN
    ...     10
    ...     13
       append to list  ${GNB_PARAMS_IN_SCF}
        ...  add:${nrbts_nidd}/NRCELL-${nrcell}:increasePUSCHPrepTimeULCA=true
        ...  modify:${nrbts_nidd}/NRCELL-${nrcell}\$:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0
        ...  modify:${nrbts_nidd}/NRCELL-${nrcell}\$:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=75
        ...  modify:${nrbts_nidd}/NRCELL-${nrcell}\$:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=480ms
        ...  add:${nrbts_nidd}/NRCELL-${nrcell}:a2MeasPCellSwitchEnabled=none
        ...  add:${nrbts_nidd}/NRCELL-${nrcell}:a2MeasPCellSwitchSsbRsrp
        ...  add:${nrbts_nidd}/NRCELL-${nrcell}:a2MeasPCellSwitchSsbRsrp:{"a2HysteresisPCellSwitchSsbRsrp":"0"}
        ...  add:${nrbts_nidd}/NRCELL-${nrcell}:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=65
        ...  add:${nrbts_nidd}/NRCELL-${nrcell}:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=480ms
        ...  add:${nrbts_nidd}/NRCELL-${nrcell}:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=0
        ...  modify:${nrbts_nidd}/NRCELL-${nrcell}\$:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=85
        ...  modify:${nrbts_nidd}/NRCELL-${nrcell}\$:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=40
    END

    #  NRCELL-X/NRREL-Y parameters - activate the scells additionMethod and operationalMode
    FOR    ${nrcell}   ${nrrel}   IN
    ...    3           10
    ...    3           13
        append to list  ${GNB_PARAMS_IN_SCF}
    #  NRCELL-X/NRREL-Y   objects already exist, only the parameters inside has to be added !!!
        ...  add:${nrbts_nidd}/NRCELL-${nrcell}/NRREL-${nrrel}:sCellAdditionMethod=covBasedA1
        ...  add:${nrbts_nidd}/NRCELL-${nrcell}/NRREL-${nrrel}:sCellOperationalMode=dlAndUl
    END
    #  END - parameter changes

    scf.perform_scf_modification    modification_strings=${GNB_PARAMS_IN_SCF}
    scf.save_scf  ${configDir}/SCFC_gNB${gnb_id}_DU_mod.xml

    scf.calculate delta scf
    ...  target_scf_path=${configDir}/SCFC_gNB${gnb_id}_DU_mod.xml
    ...  actual_scf_path=${configDir}/SCFC_gNB${gnb_id_}_DU.xml
    ...  delta_scf_path=${configDir}/SCFC_gNB${gnb_id}_DU_delta.xml

    ${oam_alias}=   connect.Setup OAM http session   node_id=${gnb_id}
    ${file1}=  get file  ${configDir}/SCFC_gNB${gnb_id}_DU_delta.xml
    IF  ${file1} != []
    ...  admin.Perform_Delta_Recommissioning    delta_file=${configDir}/SCFC_gNB${gnb_id}_DU_delta.xml
    ...  skip_parameter_relation_errors=${True}
    ...  connection=${oam_alias}

    gnb.Wait Until Node To Be Onair State   node_id=${gnb_id}

    admin.block_cell  dist_name=${nrbts_nidd}/NRCELL-1  connection=${oam_alias}
    admin.block_cell  dist_name=${nrbts_nidd}/NRCELL-2  connection=${oam_alias}
    admin.block_cell  dist_name=${nrbts_nidd}/NRCELL-4  connection=${oam_alias}
    admin.block_cell  dist_name=${nrbts_nidd}/NRCELL-14  connection=${oam_alias}
    Log to Console  gNB-${gnb_id}: cell 4 and 14 are LOCKED


    ${enb_alias}  Setup OAM http session  node_type=enb  node_id=${enb_id}
    admin.block_all_cells  rat=LTE  timeout=${20}  connection=${enb_alias}
    Log to Console  LTE cells on eNB-${enb_id} are LOCKED
