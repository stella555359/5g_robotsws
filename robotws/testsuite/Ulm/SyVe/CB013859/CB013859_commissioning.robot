*** Settings ***
Documentation   Generic gNB Commissioning: CB013859
...             This is a Robot Test Suite for feature: CB013859
...             Feature:  CB013859 A03 UE_connection_setup_single_slice
...             Team: I_MN_RAN_RD_VRF_ULM_VT2_GMS
...             Email: I_MN_RAN_RD_VRF_ULM_VT2@internal.nsn.com
#-----------------------------------------------------------------------------------------------------------------------------------[150 characters]
Resource    ../../resources/Common/testline.robot
Library    taf.sbts.oam.coam.admin          WITH NAME   admin
Library    taf.config.scf                   WITH NAME   scf



*** Keywords ***
Commissioning GNB
   [Arguments]   ${test_name}

   Run Keyword  Commissioning GNB For ${test_name}

####

Commissioning GNB For CB013859_A_RE_TC03_B3_UE_connection_setup_single_slice
    [Arguments]        ${gnb_id}=${0}
    [Documentation]    Commissioning of gnb-0 for CB013859_A0, create new updated SCF with delta changes.
    ...                Only one file is required for updating gnb with delta changes.

    ${configSuiteDir}=    testline.Get Test Suite Config Directory
    scf.Load SCF  file_path=${configSuiteDir}/SCFC_gNB${gnb_id}_DU.xml
    Set Test Variable  ${tc_number}  A03


    Log To Console  Start commissioning for gnb-${gnb_id}

    #to overcome the 150 sign limitiation
    ${nrbts_nidd}=   Set Variable    MRBTS-${nrbts_id_${gnb_id}}/NRBTS-${nrbts_id_${gnb_id}}

    # !!! sepecial attention to  \$ after e.g.  NRCELL-1  !!! if this is not given also NRCELL-11, NRCELL-15 ... are modified!
    # this wildcard behavior is not clear from taf documentation.

    @{GNB_PARAMS_IN_SCF}   Create List
    ...  modify:${nrbts_nidd}\$:actSliceAwareScheduler=true
    ...  modify:${nrbts_nidd}\$:actBufferBasedSCellAddition=disabled
    ...  modify:${nrbts_nidd}\$:sCellActivationMethod=bufferBased
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRREL-${s_cell_1}:sCellAdditionMethod=covBasedA1
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRREL-${s_cell_1}:sCellOperationalMode=dlAndUl
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRREL-${s_cell_2}:sCellAdditionMethod=covBasedA1
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRREL-${s_cell_2}:sCellOperationalMode=dlOnly
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRREL-${s_cell_3}:sCellAdditionMethod=covBasedA1
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRREL-${s_cell_3}:sCellOperationalMode=dlOnly
    ...  modify:${nrbts_nidd}/NRCELL-${p_cell_1}\$:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=80
    ...  modify:${nrbts_nidd}/NRCELL-${p_cell_1}\$:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=80
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}:a2MeasSCellRelEnabled=rsrp
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}:a2MeasSCellRelSsbRsrp
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}:a2MeasSCellRelSsbRsrp:{"a2HysteresisSCellRelSsbRsrp":"0"}
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=70
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=480ms
    ...  add:${nrbts_nidd}/NRDU-1:fr1UlCaPreferred=ulCaPreferred
    ...  modify:${nrbts_nidd}\$:drbRrcInactInactivityTimerSA=5
    ...  modify:${nrbts_nidd}\$:srbInactivityTimerSA=10
    ...  modify:${nrbts_nidd}\$:drbInactivityTimerSA=5
    ...  modify:${nrbts_nidd}/NRCELL-${p_cell_1}/NRPLMNSET_SA-1\$:trackingAreaDN=${nrbts_nidd}/TRACKINGAREA-8102
    ...  modify:${nrbts_nidd}/NRCELL-${s_cell_1}/NRPLMNSET_SA-1\$:trackingAreaDN=${nrbts_nidd}/TRACKINGAREA-8105
    ...  modify:${nrbts_nidd}/NRCELL-${s_cell_2}/NRPLMNSET_SA-1\$:trackingAreaDN=${nrbts_nidd}/TRACKINGAREA-8106
    ...  modify:${nrbts_nidd}/NRCELL-${s_cell_3}/NRPLMNSET_SA-1\$:trackingAreaDN=${nrbts_nidd}/TRACKINGAREA-8101

    scf.Perform SCF Modification    modification_strings=${GNB_PARAMS_IN_SCF}
    scf.Save SCF  ${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_mod.xml

    scf.Calculate Delta SCF
    ...  target_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_mod.xml
    ...  actual_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id_}_DU.xml
    ...  delta_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_delta.xml

    ${oam_alias}=   connect.Setup OAM Http Session   node_id=${gnb_id}
    ${file1}=  Get File  ${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_delta.xml
    IF  ${file1} != []
    ...  admin.Perform Delta Recommissioning    delta_file=${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_delta.xml
    ...  skip_parameter_relation_errors=${True}
    ...  connection=${oam_alias}

#    gnb.Wait Until Node To Be Onair State   node_id=${gnb_id}
    Sleep  60s  reason=wait release of resources

    admin.Block Cell  dist_name=${nrbts_nidd}/NRCELL-5  connection=${oam_alias}
    admin.Block Cell  dist_name=${nrbts_nidd}/NRCELL-11  connection=${oam_alias}
    admin.Block Cell  dist_name=${nrbts_nidd}/NRCELL-12  connection=${oam_alias}
    admin.Block Cell  dist_name=${nrbts_nidd}/NRCELL-13  connection=${oam_alias}
    admin.Block Cell  dist_name=${nrbts_nidd}/NRCELL-14  connection=${oam_alias}

    admin.Block All Cells  rat=LTE  timeout=${20}  connection=${oam_alias}

Commissioning GNB For CB013859_A_RE_TC04_B5_UE_conn_setup_PDU_with_multiple_slices_some_not_supp_scells
    [Arguments]        ${gnb_id}=${0}
    [Documentation]    Commissioning of gnb-0 for CB013859_A0, create new updated SCF with delta changes.
    ...                Only one file is required for updating gnb with delta changes.

    ${configSuiteDir}=    testline.Get Test Suite Config Directory
    scf.Load SCF  file_path=${configSuiteDir}/SCFC_gNB${gnb_id}_DU.xml
    Set Test Variable  ${tc_number}  A04


    Log To Console  Start commissioning for gnb-${gnb_id}

    #to overcome the 150 sign limitiation
    ${nrbts_nidd}=   Set Variable    MRBTS-${nrbts_id_${gnb_id}}/NRBTS-${nrbts_id_${gnb_id}}

    # !!! sepecial attention to  \$ after e.g.  NRCELL-1  !!! if this is not given also NRCELL-11, NRCELL-15 ... are modified!
    # this wildcard behavior is not clear from taf documentation.

    @{GNB_PARAMS_IN_SCF}   Create List
    ...  modify:${nrbts_nidd}\$:actSliceAwareScheduler=true
    ...  modify:${nrbts_nidd}\$:actBufferBasedSCellAddition=disabled
    ...  modify:${nrbts_nidd}\$:sCellActivationMethod=bufferBased
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRREL-${s_cell_1}:sCellAdditionMethod=covBasedA1
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRREL-${s_cell_1}:sCellOperationalMode=dlAndUl
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRREL-${s_cell_2}:sCellAdditionMethod=covBasedA1
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRREL-${s_cell_2}:sCellOperationalMode=dlOnly
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRREL-${s_cell_3}:sCellAdditionMethod=covBasedA1
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRREL-${s_cell_3}:sCellOperationalMode=dlOnly
    ...  modify:${nrbts_nidd}/NRCELL-${p_cell_1}\$:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=80
    ...  modify:${nrbts_nidd}/NRCELL-${p_cell_1}\$:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=80
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}:a2MeasSCellRelEnabled=rsrp
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}:a2MeasSCellRelSsbRsrp
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}:a2MeasSCellRelSsbRsrp:{"a2HysteresisSCellRelSsbRsrp":"0"}
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=70
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=480ms
    ...  add:${nrbts_nidd}/NRDU-1:fr1UlCaPreferred=ulCaPreferred
    ...  modify:${nrbts_nidd}\$:drbRrcInactInactivityTimerSA=5
    ...  modify:${nrbts_nidd}\$:srbInactivityTimerSA=10
    ...  modify:${nrbts_nidd}\$:drbInactivityTimerSA=5
    ...  modify:${nrbts_nidd}/NRCELL-${p_cell_1}/NRPLMNSET_SA-1\$:trackingAreaDN=${nrbts_nidd}/TRACKINGAREA-8102
    ...  modify:${nrbts_nidd}/NRCELL-${s_cell_1}/NRPLMNSET_SA-1\$:trackingAreaDN=${nrbts_nidd}/TRACKINGAREA-8105
    ...  modify:${nrbts_nidd}/NRCELL-${s_cell_2}/NRPLMNSET_SA-1\$:trackingAreaDN=${nrbts_nidd}/TRACKINGAREA-8106
    ...  modify:${nrbts_nidd}/NRCELL-${s_cell_3}/NRPLMNSET_SA-1\$:trackingAreaDN=${nrbts_nidd}/TRACKINGAREA-8101

    scf.Perform SCF Modification    modification_strings=${GNB_PARAMS_IN_SCF}
    scf.Save SCF  ${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_mod.xml

    scf.Calculate Delta SCF
    ...  target_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_mod.xml
    ...  actual_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id_}_DU.xml
    ...  delta_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_delta.xml

    ${oam_alias}=   connect.Setup OAM Http Session   node_id=${gnb_id}
    ${file1}=  Get File  ${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_delta.xml
    IF  ${file1} != []
    ...  admin.Perform Delta Recommissioning    delta_file=${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_delta.xml
    ...  skip_parameter_relation_errors=${True}
    ...  connection=${oam_alias}

#    gnb.Wait Until Node To Be Onair State   node_id=${gnb_id}
    Sleep  60s  reason=wait release of resources

    admin.Block Cell  dist_name=${nrbts_nidd}/NRCELL-5  connection=${oam_alias}
    admin.Block Cell  dist_name=${nrbts_nidd}/NRCELL-11  connection=${oam_alias}
    admin.Block Cell  dist_name=${nrbts_nidd}/NRCELL-12  connection=${oam_alias}
    admin.Block Cell  dist_name=${nrbts_nidd}/NRCELL-13  connection=${oam_alias}
    admin.Block Cell  dist_name=${nrbts_nidd}/NRCELL-14  connection=${oam_alias}

    admin.Block All Cells  rat=LTE  timeout=${20}  connection=${oam_alias}

Commissioning GNB For CB013859_B_RE_TC06_IWK_5_interworking_A6_based_SCell_swap_F_to_F
    [Arguments]        ${gnb_id}=${0}
    [Documentation]    Commissioning of gnb-0 for CB013859_A0, create new updated SCF with delta changes.
    ...                Only one file is required for updating gnb with delta changes.

    ${configSuiteDir}=    testline.Get Test Suite Config Directory
    scf.Load SCF  file_path=${configSuiteDir}/SCFC_gNB${gnb_id}_DU.xml
    Set Test Variable  ${tc_number}  B06


    Log To Console  Start commissioning for gnb-${gnb_id}

    #to overcome the 150 sign limitiation
    ${nrbts_nidd}=   Set Variable    MRBTS-${nrbts_id_${gnb_id}}/NRBTS-${nrbts_id_${gnb_id}}

    # !!! sepecial attention to  \$ after e.g.  NRCELL-1  !!! if this is not given also NRCELL-11, NRCELL-15 ... are modified!
    # this wildcard behavior is not clear from taf documentation.

    @{GNB_PARAMS_IN_SCF}   Create List
    ...  modify:${nrbts_nidd}\$:actSliceAwareScheduler=true
    ...  modify:${nrbts_nidd}\$:sCellActivationMethod=blind
    ...  modify:${nrbts_nidd}\$:actOverheatingAssistance=false
    ...  modify:${nrbts_nidd}\$:drbRrcInactInactivityTimerSA=5
    ...  modify:${nrbts_nidd}\$:srbInactivityTimerSA=10
    ...  modify:${nrbts_nidd}\$:drbInactivityTimerSA=5
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRREL-${s_cell_1}:sCellAdditionMethod=covBasedA1
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRREL-${s_cell_1}:sCellOperationalMode=dlOnly
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRREL-${s_cell_2}:sCellAdditionMethod=covBasedA1
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRREL-${s_cell_2}:sCellOperationalMode=dlOnly
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRREL-${s_cell_3}:sCellAdditionMethod=covBasedA1
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRREL-${s_cell_3}:sCellOperationalMode=dlOnly
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRREL-${s_cell_target_2}:sCellAdditionMethod=covBasedA1
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRREL-${s_cell_target_2}:sCellOperationalMode=dlOnly
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRREL-${s_cell_target_3}:sCellAdditionMethod=covBasedA1
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRREL-${s_cell_target_3}:sCellOperationalMode=dlOnly
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRREL-${s_cell_2}:sCellPrio=1
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRREL-${s_cell_3}:sCellPrio=1
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRREL-${s_cell_target_2}:sCellPrio=3
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRREL-${s_cell_target_3}:sCellPrio=3
    ...  modify:${nrbts_nidd}\$:actFlexSCellSelectFr1=true
    ...  modify:${nrbts_nidd}/NRCELL-${p_cell_1}\$:a1MeasSCellAddEnabled=rsrpCombined

    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}:a1MeasSCellAddSsbRsrq
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}:a1MeasSCellAddSsbRsrq:{"a1HysteresisSCellAddSsbRsrq":"0"}
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=20
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}:a1MeasSCellAddSsbRsrq:a1TimeToTriggerSCellAddSsbRsrq=320ms

    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}:a2MeasSCellRelSsbRsrp
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}:a2MeasSCellRelSsbRsrp:{"a2HysteresisSCellRelSsbRsrp":"0"}
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=2560ms

    ...  modify:${nrbts_nidd}/NRCELL-${p_cell_1}/NRPLMNSET_SA-1\$:trackingAreaDN=${nrbts_nidd}/TRACKINGAREA-8102
    ...  modify:${nrbts_nidd}/NRCELL-${s_cell_1}/NRPLMNSET_SA-1\$:trackingAreaDN=${nrbts_nidd}/TRACKINGAREA-8105
    ...  modify:${nrbts_nidd}/NRCELL-${s_cell_2}/NRPLMNSET_SA-1\$:trackingAreaDN=${nrbts_nidd}/TRACKINGAREA-8106
    ...  modify:${nrbts_nidd}/NRCELL-${s_cell_3}/NRPLMNSET_SA-1\$:trackingAreaDN=${nrbts_nidd}/TRACKINGAREA-8101
    ...  modify:${nrbts_nidd}/NRCELL-${s_cell_target_2}/NRPLMNSET_SA-1\$:trackingAreaDN=${nrbts_nidd}/TRACKINGAREA-8106
    ...  modify:${nrbts_nidd}/NRCELL-${s_cell_target_3}/NRPLMNSET_SA-1\$:trackingAreaDN=${nrbts_nidd}/TRACKINGAREA-8101

    FOR    ${nrcell}    IN RANGE  1  25
       Append To List  ${GNB_PARAMS_IN_SCF}
       ...  modify:${nrbts_nidd}/NRCELL-${nrcell}\$:sCellDeactivationTimerGNB=infinity
    END

    FOR    ${nrcell}    IN
    ...      1
    ...     15
    ...     19
    ...     18
    ...     21

       Append To List  ${GNB_PARAMS_IN_SCF}
        ...  add:${nrbts_nidd}/NRCELL-${nrcell}:a6MeasSCellSwapEnabled=rsrp
        ...  add:${nrbts_nidd}/NRCELL-${nrcell}:thresholdSCellSwapSourceRsrp=86
        ...  add:${nrbts_nidd}/NRCELL-${nrcell}:a6MeasSCellSwapSsbRsrp
        ...  add:${nrbts_nidd}/NRCELL-${nrcell}:a6MeasSCellSwapSsbRsrp:{"a6HysteresisSCellSwapSsbRsrp":"0"}
        ...  add:${nrbts_nidd}/NRCELL-${nrcell}:a6MeasSCellSwapSsbRsrp:a6OffsetSCellSwapSsbRsrp=12
        ...  add:${nrbts_nidd}/NRCELL-${nrcell}:a6MeasSCellSwapSsbRsrp:a6TimeToTrigSCellSwapSsbRsrp=ms480
        ...  add:${nrbts_nidd}/NRCELL-${nrcell}:a6MeasSCellSwapSsbRsrp:useAllowedCellListRsrp=false
    END


    scf.Perform SCF Modification    modification_strings=${GNB_PARAMS_IN_SCF}
    scf.Save SCF  ${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_mod.xml

    scf.Calculate Delta SCF
    ...  target_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_mod.xml
    ...  actual_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id_}_DU.xml
    ...  delta_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_delta.xml

    ${oam_alias}=   connect.Setup OAM Http Session   node_id=${gnb_id}
    ${file1}=  Get File  ${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_delta.xml
    IF  ${file1} != []
    ...  admin.Perform Delta Recommissioning    delta_file=${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_delta.xml
    ...  skip_parameter_relation_errors=${True}
    ...  connection=${oam_alias}

    gnb.Wait Until Node To Be Onair State   node_id=${gnb_id}

    admin.Block Cell  dist_name=${nrbts_nidd}/NRCELL-11  connection=${oam_alias}
    admin.Block Cell  dist_name=${nrbts_nidd}/NRCELL-12  connection=${oam_alias}

    admin.Block All Cells  rat=LTE  timeout=${20}  connection=${oam_alias}

Commissioning GNB For CB013859_B_RE_TC07_IWK_6_interworking_inter_gNB_CA
    [Arguments]        ${gnb_id}=${0}
    [Documentation]    Commissioning of gnb-0 for CB013859_A0, create new updated SCF with delta changes.
    ...                Only one file is required for updating gnb with delta changes.

    ${configSuiteDir}=    testline.Get Test Suite Config Directory
    scf.Load SCF  file_path=${configSuiteDir}/SCFC_gNB${gnb_id}_DU.xml
    Set Test Variable  ${tc_number}  B07


    Log To Console  Start commissioning for gnb-${gnb_id}

    #to overcome the 150 sign limitiation
    ${nrbts_nidd}=   Set Variable    MRBTS-${nrbts_id_${gnb_id}}/NRBTS-${nrbts_id_${gnb_id}}

    # !!! sepecial attention to  \$ after e.g.  NRCELL-1  !!! if this is not given also NRCELL-11, NRCELL-15 ... are modified!
    # this wildcard behavior is not clear from taf documentation.

    @{GNB_PARAMS_IN_SCF}   Create List
    ...  modify:${nrbts_nidd}\$:actSCellReleaseBadSCellRlq=disabled
    ...  modify:${nrbts_nidd}\$:actSliceAwareScheduler=true
    ...  modify:${nrbts_nidd}\$:actSliceAwareSchedulerUlAndEnh=true
    ...  modify:${nrbts_nidd}\$:drbInactivityTimerSA=5
    ...  modify:${nrbts_nidd}\$:drbInactivityTimerSA5qi1=5
    ...  modify:${nrbts_nidd}\$:drbInactivityTimerSA5qi5=5
    ...  add:${nrbts_nidd}:iGnbCaXnCfUpBackOffTmr=0
    ...  add:${nrbts_nidd}:iGnbCaXnRemovalTmr=10
    ...  add:${nrbts_nidd}:iGnbCaXnSetupReqTmr=60
    ...  add:${nrbts_nidd}:iGnbCaXnSetupRespTmr=5
    ...  add:${nrbts_nidd}:intGnbScellTempBlockTmr=60
    ...  modify:${nrbts_nidd}\$:sCellDeactivationBadRlqCount=0
    ...  delete:${nrbts_nidd}:sCellExcludelistTimerFr1
    ...  modify:${nrbts_nidd}\$:srbInactivityTimerSA=10
    ...  add:${nrbts_nidd}:weightForIgnbCaSelection=100

    ...  add:${nrbts_nidd}/NRADJGNB-1:weightForIgnbCaSelection=100

    ...  modify:${nrbts_nidd}/NRADJNRCELL-1\$:freqBandIndicatorNR=66
    ...  modify:${nrbts_nidd}/NRADJNRCELL-1\$:nrarfcn=426030

    ...  modify:${nrbts_nidd}/NRADJNRCELL-2\$:freqBandIndicatorNR=2
    ...  modify:${nrbts_nidd}/NRADJNRCELL-2\$:nrarfcn=395090

    ...  modify:${nrbts_nidd}/NRADJNRCELL-4\$:freqBandIndicatorNR=77
    ...  modify:${nrbts_nidd}/NRADJNRCELL-4\$:nrarfcn=650016

    ...  modify:${nrbts_nidd}/NRCELL-1\$:actK1Opt=intraAndInter-gNB
    ...  modify:${nrbts_nidd}/NRCELL-1\$:filterCoeffSsbRsrp=fc4
    ...  modify:${nrbts_nidd}/NRCELL-1\$:sCellBadChannelQualityThreshold=4
    ...  modify:${nrbts_nidd}/NRCELL-1\$:sCellDeactivationTimerGNB=infinity
    ...  modify:${nrbts_nidd}/NRCELL-1\$:sCellGoodChannelQualityThreshold=8
    ...  delete:${nrbts_nidd}/NRCELL-1:sCellInactivityReleaseTimer

    ...  modify:${nrbts_nidd}/NRCELL-1\$:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=80
    ...  modify:${nrbts_nidd}/NRCELL-1\$:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=80

    ...  add:${nrbts_nidd}/NRCELL-1:a2MeasSCellRelEnabled=rsrp
    ...  add:${nrbts_nidd}/NRCELL-1:a2MeasSCellRelSsbRsrp
    ...  add:${nrbts_nidd}/NRCELL-1:a2MeasSCellRelSsbRsrp:{"a2HysteresisSCellRelSsbRsrp":"0"}
    ...  add:${nrbts_nidd}/NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=70
    ...  add:${nrbts_nidd}/NRCELL-1:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=480ms

    ...  modify:${nrbts_nidd}/NRCELL-1/NRPLMNSET_NSA-1\$:configuredEpsTac=8102

    ...  add:${nrbts_nidd}/NRCELL-1/NRREL-101:sCellAdditionMethod=covBasedA1
    ...  add:${nrbts_nidd}/NRCELL-1/NRREL-101:sCellOperationalMode=dlOnly
    ...  add:${nrbts_nidd}/NRCELL-1/NRREL-102:sCellAdditionMethod=covBasedA1
    ...  add:${nrbts_nidd}/NRCELL-1/NRREL-102:sCellOperationalMode=dlOnly
    ...  add:${nrbts_nidd}/NRCELL-1/NRREL-104:sCellAdditionMethod=covBasedA1
    ...  add:${nrbts_nidd}/NRCELL-1/NRREL-104:sCellOperationalMode=dlOnly

    ...  modify:${nrbts_nidd}/NRDU-1\$:actInterGnbCa=DLOnly
    ...  add:${nrbts_nidd}/NRDU-1:fr1UlCaPreferred=ulCaPreferred

    scf.Perform SCF Modification    modification_strings=${GNB_PARAMS_IN_SCF}
    scf.Save SCF  ${configSuiteDir}/SCFC_gNB${gnb_id_0}_${tc_number}_mod.xml

    scf.Calculate Delta SCF
    ...  target_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id_0}_${tc_number}_mod.xml
    ...  actual_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id_0_}_DU.xml
    ...  delta_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id_0}_${tc_number}_delta.xml

    ${oam_alias}=   connect.Setup OAM Http Session   node_id=${gnb_id_0}
    ${file1}=  Get File  ${configSuiteDir}/SCFC_gNB${gnb_id_0}_${tc_number}_delta.xml
    IF  ${file1} != []
    ...  admin.Perform Delta Recommissioning    delta_file=${configSuiteDir}/SCFC_gNB${gnb_id_0}_${tc_number}_delta.xml
    ...  skip_parameter_relation_errors=${True}
    ...  connection=${oam_alias}

#    gnb.Wait Until Node To Be Onair State   node_id=${gnb_id}
    Sleep  60s  reason=wait release of resources

    admin.Block Cell  dist_name=${nrbts_nidd}/NRCELL-5  connection=${oam_alias}
    admin.Block Cell  dist_name=${nrbts_nidd}/NRCELL-11  connection=${oam_alias}
    admin.Block Cell  dist_name=${nrbts_nidd}/NRCELL-12  connection=${oam_alias}
    admin.Block Cell  dist_name=${nrbts_nidd}/NRCELL-13  connection=${oam_alias}
    admin.Block Cell  dist_name=${nrbts_nidd}/NRCELL-14  connection=${oam_alias}

    admin.Block All Cells  rat=LTE  timeout=${20}  connection=${oam_alias}
