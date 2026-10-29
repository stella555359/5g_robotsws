*** Settings ***
Documentation   covers the commissioning for the CB013142 TCs
...             Team: 'MN RAN RD VRF ULM 1'
...             Email: 'ou_mn_ran_rd_vrf_ulm_1_53028392@internal.nsn.com'
#-----------------------------------------------------------------------------------------------------------------------------------[150 characters]
Resource    ../../resources/Common/testline.robot
Library    taf.sbts.oam.coam.admin          WITH NAME   admin
Library    taf.config.scf                   WITH NAME   scf


*** Keywords ***
Commissioning GNB
   [Arguments]   ${test_name}

   Run Keyword  Commissioning GNB For ${test_name}

######

Commissioning GNB For CB013142 A ST TC01 B2 SA A2 Meas Reconfig On PCell For PCell Change Using Meas Profile Based On UE PC Upon SCell Change
    [Documentation]    Commissioning of gnb for CB013142_A_ST_TC01_B2_SA_A2
    [Arguments]        ${gnb_id}=${0}
    ${configSuiteDir}=    testline.Get Test Suite Config Directory
    scf_info.Set MNL Version String For Branch    basic_scf_name=${configSuiteDir}/SCFC_gNB${gnb_id}_DU.xml
    Log To Console  Start commissioning for gnb
    scf.Load SCF  file_path=${configSuiteDir}/SCFC_gNB${gnb_id}_DU.xml
    Set Test Variable  ${tc_number}  A01

    #to overcome the 150 sign limitiation
    ${nrbts_nidd}=   Set Variable    MRBTS-${nrbts_id_${gnb_id}}/NRBTS-${nrbts_id_${gnb_id}}
    ${nrsysinfo_profile}  Set Variable  MRBTS-${nrbts_id_${gnb_id}}/NRBTS-${nrbts_id_${gnb_id}}/NRSYSINFO_PROFILE-6

    @{GNB_PARAMS_IN_SCF}   Create List
    #  parameter changes
    ...  modify:${nrbts_nidd}:actBufferBasedSCellAddition=disabled
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRREL-${s_cell_1}:sCellAdditionMethod=covBasedA1
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRREL-${s_cell_1}:sCellOperationalMode=dlOnly
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRREL-${s_cell_2}:sCellAdditionMethod=covBasedA1
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRREL-${s_cell_2}:sCellOperationalMode=dlOnly
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}:increasePUSCHPrepTimeULCA=false
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_2}:increasePUSCHPrepTimeULCA=false
#    ...  modify:${nrbts_nidd}/NRCELL-${s_cell_2}\$:increasePUSCHPrepTimeULCA=true
    ...  modify:${nrbts_nidd}/NRCELL-${p_cell_1}\$:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=80
    ...  modify:${nrbts_nidd}/NRCELL-${p_cell_1}\$:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}:a2MeasPCellSwitchEnabled=rsrp
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}:a2MeasPCellSwitchSsbRsrp
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}:a2MeasPCellSwitchSsbRsrp:{"a2HysteresisPCellSwitchSsbRsrp":"0"}
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=70
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=480ms
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=0
    ...  modify:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-1\$:a2BasedPCellSwitchEnabled=true
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-1:a2BasedPCellSwitchPriority=2
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-1:thresholdPCellSwitchTargetRsrp=60
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-1:thresholdPCellSwitchTargetRsrq=0
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}:a2MeasSCellRelEnabled=none
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_2}:a2MeasSCellRelEnabled=none
    ...  modify:${nrbts_nidd}\$:actMeasurementProfile=SA
    ...  modify:${nrbts_nidd}\$:actCAMeasInMeasProf=SA
    ...  modify:${nrbts_nidd}\$:actMeasurementProfReselForCA=pcInSaUlAndDlCaSupported
    ...  modify:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-1\$:pcCapabilityList:uePowerClass=ue-PowerClass3
    ...  modify:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-1\$:pcCapabilityList:freqBandIndicatorNR=78
#    ...  modify:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-2\$:pcCapabilityList:uePowerClass=ue-PowerClass1Dot5
    ...  modify:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-2\$:pcCapabilityList:uePowerClass=ue-PowerClass2
    ...  modify:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-2\$:pcCapabilityList:freqBandIndicatorNR=78
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a2MeasPCellSwitchSsbRsrp
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a2MeasPCellSwitchSsbRsrp:{"a2HysteresisPCellSwitchSsbRsrp":"0"}
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=${A2THRESPCELLSWITCH_MEASPR_1}
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=480ms
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=0
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_IAF-2:a2MeasPCellSwitchSsbRsrp
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_IAF-2:a2MeasPCellSwitchSsbRsrp:{"a2HysteresisPCellSwitchSsbRsrp":"0"}
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_IAF-2:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=${A2THRESPCELLSWITCH_MEASPR_2}
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_IAF-2:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=480ms
    ...  modify:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1\$:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=55
    ...  modify:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_IAF-2\$:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=55
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_IAF-2:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=0
    ...  delete:${nrbts_nidd}/NRCELL-${p_cell_1}:nrConnectModeProfileDN
    ...  delete:${nrbts_nidd}/NRCELL-${s_cell_2}:nrConnectModeProfileDN
    ...  modify:${nrbts_nidd}/NRCELL-${p_cell_1}\$:pMaxNROwnCell=31
    ...  modify:${nrbts_nidd}/NRCELL-${s_cell_2}\$:pMaxNROwnCell=31
    ...  modify:${nrbts_nidd}/NRDU-1\$:dlToUlContributionRatio=50
    ...  modify:${nrbts_nidd}/NRCELL-${s_cell_2}\$:chBw=60MHz
    ...  add:[com.nokia.srbts.nrbts:NRHOIF, ${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-2, MNL${version}, create]
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-2:a1BasedPCellSwitchEnabled=false
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-2:a2BasedPCellSwitchEnabled=true
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-2:a2BasedPCellSwitchPriority=2
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-2:a3MeasEnabled=rsrp
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-2:a3MeasSsbRsrp
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-2:a3MeasSsbRsrp:{"a3HysteresisSsbRsrp":"0"}
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=3
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms100
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-2:a4MeasSsbRsrp
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-2:a4MeasSsbRsrp:{"a4HysteresisSsbRsrp":"0"}
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-2:a4MeasSsbRsrp:a4ThresholdSsbRsrp=34
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-2:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-2:a4MeasEnDcSteeringEnabled=none
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-2:a4MeasHigherPrioFreqEnabled=none
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-2:a4MeasNrDcEnabled=none
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-2:a4MeasSCellAddEnabled=none
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-2:a5MeasEnabled=none
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-2:a5MeasSsbRsrp
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-2:a5MeasSsbRsrp:{"a5HysteresisSsbRsrp":"0"}
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-2:a5MeasSsbRsrp:a5Threshold1SsbRsrp=50
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-2:a5MeasSsbRsrp:a5Threshold2SsbRsrp=80
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-2:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms100
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-2:cellDepType=SA+NSA
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-2:freqBandIndicatorNR=66
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-2:ifhoSsbScs=30 KHz
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-2:ifhoSsbSmtcDuration=sf5
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf5
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-2:scs=15 KHz
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-2:ssBurstSetPeriod=20
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-2:ssbFrequency=425790
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-2:thresholdPCellSwitchTargetRsrp=1
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-2:thresholdPCellSwitchTargetRsrq=0
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrMeasProfileIntraFreq=5min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrMeasProfileSCell=5min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrMeasProfileMappingSA=5min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrMeasProfileMappingNSA=5min

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

    admin.Block Cell  dist_name=${nrbts_nidd}/NRCELL-2  connection=${oam_alias}
    admin.Block Cell  dist_name=${nrbts_nidd}/NRCELL-11  connection=${oam_alias}
    admin.Block Cell  dist_name=${nrbts_nidd}/NRCELL-14  connection=${oam_alias}

    ${enb_alias}  Setup OAM Http Session  node_type=enb  node_id=${enb_id}
    admin.Block All Cells  rat=LTE  timeout=${20}  connection=${enb_alias}

Commissioning GNB For CB013142 C ST TC01 B3 NSA Target Cell Radio Quality Evaluation During A2 Based PSCell Change Using Meas Profile
    [Documentation]    Commissioning of gnb for CB013142_C_ST_TC01_B3
    ...                to overcome linter warning in case of unused variables
    [Arguments]        ${gnb_id}=${1}

    ${configSuiteDir}=    testline.Get Test Suite Config Directory
    scf_info.Set MNL Version String For Branch    basic_scf_name=${configSuiteDir}/SCFC_gNB${gnb_id}_DU.xml
    Log To Console  Start commissioning for gnb
    scf.Load SCF  file_path=${configSuiteDir}/SCFC_gNB${gnb_id}_DU.xml
    Set Test Variable  ${tc_number}  C01

    #to overcome the 150 sign limitiation
    ${nrbts_nidd}=   Set Variable    MRBTS-${nrbts_id_${gnb_id}}/NRBTS-${nrbts_id_${gnb_id}}
    ${mpr}=   Set Variable    NRMEAS_PROFILE-1

    @{GNB_PARAMS_IN_SCF}   Create List
    #  parameter changes
    ...  modify:${nrbts_nidd}:actBufferBasedSCellAddition=disabled
    ...  modify:${nrbts_nidd}\$:actAllowedBcListMrdcPrioBcSel=false
    ...  modify:${nrbts_nidd}\$:actExtN77Support=false
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}/NRREL-${p_cell_1}:sCellAdditionMethod=covBasedA1
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}/NRREL-${p_cell_1}:sCellOperationalMode=dlOnly
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRREL-${s_cell_1}:sCellAdditionMethod=covBasedA1
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRREL-${s_cell_1}:sCellOperationalMode=dlOnly
    ...  modify:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-11\$:freqBandIndicatorNR=2
    ...  modify:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-11\$:ssbFrequency=395090
    ...  modify:${nrbts_nidd}/NRCELL-${s_cell_1}/NRREL-${p_cell_1}\$:nrDcAllowed=false
    ...  modify:${nrbts_nidd}/NRCELL-${p_cell_1}/NRREL-${s_cell_1}\$:nrDcAllowed=false
    ...  modify:${nrbts_nidd}/NRCELL-${s_cell_1}\$:freqBandIndicatorNR=2
    ...  modify:${nrbts_nidd}/NRCELL-${p_cell_1}\$:freqBandIndicatorNR=78
    ...  modify:${nrbts_nidd}/NRCELL-${p_cell_1}\$:pMaxNROwnCell=26
    ...  modify:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-11\$:thresholdPCellSwitchTargetRsrp=64
    ...  delete:${nrbts_nidd}/NRCELL-${s_cell_1}:nrConnectModeProfileDN
    ...  modify:${nrbts_nidd}/NRCELL-${s_cell_1}\$:nrSysInfoProfileDN=${nrbts_nidd}/NRSYSINFO_PROFILE-3
    ...  modify:${nrbts_nidd}/NRCELL-${p_cell_1}\$:nrSysInfoProfileDN=${nrbts_nidd}/NRSYSINFO_PROFILE-1
    ...  delete:${nrbts_nidd}/NRCELL-${p_cell_1}:nrMultibandInfoProfileDN
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrCaDu=5min
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}:a2MeasPCellSwitchEnabled=rsrp
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}:a2MeasPCellSwitchSsbRsrp
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}:a2MeasPCellSwitchSsbRsrp:{"a2HysteresisPCellSwitchSsbRsrp":"0"}
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=67
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=480ms
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=0
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}:measPrMaNSAList
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}:measPrMaNSAList:{"measPrPriority":"4"}
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}:measPrMaNSAList:nrMeasPrMaNSADN=${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-2
    ...  modify:${nrbts_nidd}/NRCELL-${p_cell_1}\$:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=80
    ...  modify:${nrbts_nidd}/NRCELL-${p_cell_1}\$:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70
    ...  modify:${nrbts_nidd}/NRCELL-${p_cell_1}\$:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=70
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}:measPrMaNSAList
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}:measPrMaNSAList:{"measPrPriority":"4","nrMeasPrMaNSADN":"${nrbts_nidd}/${mpr}/NRMEASPR_MA_NSA-1"}
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}:measPrMaNSAList:{"measPrPriority":"5","nrMeasPrMaNSADN":"${nrbts_nidd}/${mpr}/NRMEASPR_MA_NSA-2"}
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a2MeasPCellSwitchSsbRsrp
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a2MeasPCellSwitchSsbRsrp:{"a2HysteresisPCellSwitchSsbRsrp":"0"}
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=${A2THRESPCELLSWITCH_MEASPR_1}
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=480ms
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=0
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_IAF-2:a2MeasPCellSwitchSsbRsrp
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_IAF-2:a2MeasPCellSwitchSsbRsrp:{"a2HysteresisPCellSwitchSsbRsrp":"0"}
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_IAF-2:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=${A2THRESPCELLSWITCH_MEASPR_2}
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_IAF-2:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=480ms
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_IAF-2:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=0
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-1:pcCapabilityList:freqBandIndicatorNR=78
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-2:pcCapabilityList:freqBandIndicatorNR=2
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-2:nrMeasPrSCellList
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-2:nrMeasPrSCellList:{"ssbFrequency01":"395090"}
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-2:nrMeasPrSCellList:nrMeasPrSCellDN=${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_SCELL-1
    ...  add:[com.nokia.srbts.nrbts:NRMEASPR_SCELL, ${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_SCELL-1, MNL${version}, create]
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_SCELL-1:thresholdPCellSwitchTargetRsrp=10
    ...  modify:${nrbts_nidd}\$:actCAMeasInMeasProf=SA+NSA
    ...  modify:${nrbts_nidd}\$:actMeasProfPowerCoordNSA=activated
    ...  modify:${nrbts_nidd}\$:actMeasurementProfReselForCA=pcInSaUlAndDlCaSupported
    ...  modify:${nrbts_nidd}\$:actMeasurementProfile=SA+NSA
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrMeasProfileIntraFreq=5min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrMeasProfileSCell=5min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrMeasProfileMappingSA=5min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrMeasProfileMappingNSA=5min

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
    gnb.Wait Until Node To Be Onair State   node_id=${enb_id}
    gnb.Wait Until X2 Link Status Is Available   gnb_id=${gnb_id}

    admin.Block Cell  dist_name=MRBTS-${nrbts_id_${gnb_id}}/NRBTS-${nrbts_id_${gnb_id}}/NRCELL-1  connection=${oam_alias}

Commissioning GNB For CB013142 D ST TC03 B4 NSA A1 Meas Config On SCell For PSCell Change Using NRCELL Config When Matching Profile Mapping Not Found
    [Documentation]    Commissioning of gnb for CB013142_C_ST_TC01_B3
    ...                to overcome linter warning in case of unused variables
    [Arguments]        ${gnb_id}=${1}

    ${configSuiteDir}=    testline.Get Test Suite Config Directory
    scf_info.Set MNL Version String For Branch    basic_scf_name=${configSuiteDir}/SCFC_gNB${gnb_id}_DU.xml
    Log To Console  Start commissioning for gnb
    scf.Load SCF  file_path=${configSuiteDir}/SCFC_gNB${gnb_id}_DU.xml
    Set Test Variable  ${tc_number}  D03

    #to overcome the 150 sign limitiation
    ${nrbts_nidd}=   Set Variable    MRBTS-${nrbts_id_${gnb_id}}/NRBTS-${nrbts_id_${gnb_id}}
    ${mpr}=   Set Variable    NRMEAS_PROFILE-1

    @{GNB_PARAMS_IN_SCF}   Create List
    #  parameter changes
    ...  modify:${nrbts_nidd}:actBufferBasedSCellAddition=disabled
    ...  modify:${nrbts_nidd}\$:actAllowedBcListMrdcPrioBcSel=false
    ...  modify:${nrbts_nidd}\$:actExtN77Support=false
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}/NRREL-${p_cell_1}:sCellAdditionMethod=covBasedA1
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}/NRREL-${p_cell_1}:sCellOperationalMode=dlOnly
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRREL-${s_cell_1}:sCellAdditionMethod=covBasedA1
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRREL-${s_cell_1}:sCellOperationalMode=dlOnly
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}:measGapSelectionSA=favourUeThroughput
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}:ifhoSsbSmtcOffset=0
    ...  modify:${nrbts_nidd}/NRCELL-${s_cell_1}\$:freqBandIndicatorNR=78
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrCaDu=5min
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}:a1MeasPCellSwitchEnabled=rsrp
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}:a2MeasSCellRelEnabled=none
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}:measPrMaNSAList
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}:measPrMaNSAList:{"measPrPriority":"4","nrMeasPrMaNSADN":"${nrbts_nidd}/${mpr}/NRMEASPR_MA_NSA-1"}
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-1:nrMeasPrSCellList
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-1:nrMeasPrSCellList:{"ssbFrequency01":"650016"}
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-1:nrMeasPrSCellList:nrMeasPrSCellDN=${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_SCELL-1
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-1:spid=5
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-1:spidLast=10
    ...  add:[com.nokia.srbts.nrbts:NRMEASPR_SCELL, ${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_SCELL-1, MNL${version}, create]
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_SCELL-1:a1MeasPCellSwitchSsbRsrp
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_SCELL-1:a1MeasPCellSwitchSsbRsrp:{"a1HysteresisPCellSwitchSsbRsrp":"0"}
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_SCELL-1:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=67
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_SCELL-1:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=480ms
    ...  modify:${nrbts_nidd}\$:actCAMeasInMeasProf=SA+NSA
    ...  modify:${nrbts_nidd}\$:actMeasProfPowerCoordNSA=activated
    ...  modify:${nrbts_nidd}\$:actMeasurementProfReselForCA=pcInSaUlAndDlCaSupported
    ...  modify:${nrbts_nidd}\$:actMeasurementProfile=SA+NSA
    ...  modify:${nrbts_nidd}\$:actSPID=true
    ...  add:[com.nokia.srbts.nrbts:NRHOIF, ${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-4, MNL${version}, create]
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-4:a1BasedPCellSwitchEnabled=true
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-4:a2BasedPCellSwitchEnabled=true
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-4:a2BasedPCellSwitchPriority=1
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-4:a3MeasEnabled=rsrp
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-4:a3MeasSsbRsrp
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-4:a3MeasSsbRsrp:{"a3HysteresisSsbRsrp":"2"}
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-4:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-4:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms128
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-4:a4MeasSsbRsrp
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-4:a4MeasSsbRsrp:{"a4HysteresisSsbRsrp":"0"}
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-4:a4MeasSsbRsrp:a4ThresholdSsbRsrp=34
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-4:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-4:a4MeasEnDcSteeringEnabled=none
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-4:a4MeasHigherPrioFreqEnabled=none
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-4:a4MeasNrDcEnabled=none
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-4:a4MeasSCellAddEnabled=none
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-4:a5MeasEnabled=none
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-4:a5MeasSsbRsrp
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-4:a5MeasSsbRsrp:{"a5HysteresisSsbRsrp":"0"}
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-4:a5MeasSsbRsrp:a5Threshold1SsbRsrp=50
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-4:a5MeasSsbRsrp:a5Threshold2SsbRsrp=80
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-4:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms100
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-4:cellDepType=SA+NSA
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-4:freqBandIndicatorNR=78
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-4:ifhoSsbScs=15KHz
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-4:ifhoSsbSmtcDuration=sf5
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-4:ifhoSsbSmtcPeriodicity=sf20
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-4:numberOfTransmittedSsBlocks=32 beams
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-4:scs=15 KHz
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-4:ssBurstSetPeriod=20
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-4:ssbFrequency=650016
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-4:thresholdPCellSwitchTargetRsrp=65
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-4:thresholdPCellSwitchTargetRsrq=1
    #all counters needs to be changed from 5min to 15min, otherwise the keyword cannot not find the counters -> keyword limitiation
    #e.g. in this case search for miNrMeasProfile and change all of them
    ...  modify:MRBTS-${nrbts_id_${gnb_id}}/MNL-1/MNLENT-1/PMCADM-1:reportingIntervalPm=15min
    ...  modify:MRBTS-${nrbts_id_${gnb_id}}/MNL-1/MNLENT-1/PMMNL-1:eCpriMasterStatisticsInterval=15min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrMeasProfileIntraFreq=15min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrMeasProfileSCell=15min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrMeasProfileMappingSA=15min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrMeasProfileMappingNSA=15min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrMeasProfileInterFreq=15min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrMeasProfileInterRat=15min

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
    gnb.Wait Until Node To Be Onair State   node_id=${enb_id}
    gnb.Wait Until X2 Link Status Is Available   gnb_id=${gnb_id}

    admin.Block Cell  dist_name=MRBTS-${nrbts_id_${gnb_id}}/NRBTS-${nrbts_id_${gnb_id}}/NRCELL-1  connection=${oam_alias}

Commissioning GNB For CB013142 D ST TC03 Part2
    [Documentation]    Commissioning of gnb for CB013142_C_ST_TC01_B3
    ...                to overcome linter warning in case of unused variables
    [Arguments]        ${gnb_id}=${1}

    ${configSuiteDir}=    testline.Get Test Suite Config Directory
    scf_info.Set MNL Version String For Branch    basic_scf_name=${configSuiteDir}/SCFC_gNB${gnb_id}_DU.xml
    Log To Console  Start commissioning for gnb
    gnb.Get SCF From GNB  gnb_id=${gnb_id}  target_dir=${configSuiteDir}  scf_name=SCFC_gNB${gnb_id}_DU_part2.xml
    scf.Load SCF  file_path=${configSuiteDir}/SCFC_gNB${gnb_id}_DU_part2.xml
    Set Test Variable  ${tc_number}  D03



    #to overcome the 150 sign limitiation
    ${nrbts_nidd}=   Set Variable    MRBTS-${nrbts_id_${gnb_id}}/NRBTS-${nrbts_id_${gnb_id}}

    @{GNB_PARAMS_IN_SCF}   Create List
    #  parameter changes
    ...  delete:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-1:spidLast
    ...  delete:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-1:spid

    scf.Perform SCF Modification    modification_strings=${GNB_PARAMS_IN_SCF}
    scf.Save SCF  ${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_part2_mod.xml

    scf.Calculate Delta SCF
    ...  target_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_part2_mod.xml
    ...  actual_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id}_DU_part2.xml
    ...  delta_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_part2_delta.xml

    ${oam_alias}=   connect.Setup OAM Http Session   node_id=${gnb_id}
    ${file1}=  Get File  ${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_part2_delta.xml
    IF  ${file1} != []
    ...  admin.Perform Delta Recommissioning    delta_file=${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_part2_delta.xml
    ...  skip_parameter_relation_errors=${True}
    ...  connection=${oam_alias}


Commissioning GNB For CB013142 F ST TC01 B1 SA A1 And A4 Config Meas For SCell Addition Using Selected Meas Profile Based On One Or More Criteria
    [Documentation]    Commissioning of gnb for CB013142_C_ST_TC01_B3
    ...                to overcome linter warning in case of unused variables
    [Arguments]        ${gnb_id}=${0}

    ${configSuiteDir}=    testline.Get Test Suite Config Directory
    scf_info.Set MNL Version String For Branch    basic_scf_name=${configSuiteDir}/SCFC_gNB${gnb_id}_DU.xml
    Log To Console  Start commissioning for gnb
    scf.Load SCF  file_path=${configSuiteDir}/SCFC_gNB${gnb_id}_DU.xml
    Set Test Variable  ${TC_NUMBER}  F01

    #to overcome the 150 sign limitiation
    ${nrbts_nidd}=   Set Variable    MRBTS-${nrbts_id_${gnb_id}}/NRBTS-${nrbts_id_${gnb_id}}

    @{GNB_PARAMS_IN_SCF}   Create List
    #  parameter changes
    ...  modify:${nrbts_nidd}:actBufferBasedSCellAddition=oneShot_Dl_Fr1
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRREL-${s_cell_1}:sCellAdditionMethod=covBasedA1
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRREL-${s_cell_1}:sCellOperationalMode=dlOnly
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRREL-${s_cell_2}:sCellAdditionMethod=covBasedA4
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRREL-${s_cell_2}:sCellOperationalMode=dlOnly
    ...  modify:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-2:freqBandIndicatorNR=78
    ...  modify:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-2:ssbFrequency=631968
    ...  modify:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-2:a4MeasSCellAddEnabled=rsrp
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-2:a4MeasSCellAddSsbRsrp
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-2:a4MeasSCellAddSsbRsrp:{"a4HysteresisSCellAddSsbRsrp":"0"}
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-2:a4MeasSCellAddSsbRsrp:a4ThresholdSCellAddSsbRsrp=65
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-2:a4MeasSCellAddSsbRsrp:a4TimeToTriggerSCellAddSsbRsrp=ms128
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrMeasProfileIntraFreq=5min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrMeasProfileInterFreq=5min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrMeasProfileSCell=5min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrMeasProfileMappingSA=5min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrMeasProfileMappingNSA=5min
    ...  modify:${nrbts_nidd}\$:actMeasurementProfile=SA
    ...  modify:${nrbts_nidd}\$:actCAMeasInMeasProf=SA
    ...  modify:${nrbts_nidd}/NRCELL-${p_cell_1}\$:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=80
    ...  modify:${nrbts_nidd}/NRCELL-${p_cell_1}\$:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=75
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a1MeasSCellAddSsbRsrp
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a1MeasSCellAddSsbRsrp:{"a1HysteresisSCellAddSsbRsrp":"0"}
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=65
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
    ...  modify:${nrbts_nidd}\$:actMeasurementProfReselForCA=pcInSaUlAndDlCaSupported
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_IEF-1:a4MeasSCellAddSsbRsrp
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_IEF-1:a4MeasSCellAddSsbRsrp:{"a4HysteresisSCellAddSsbRsrp":"0"}
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_IEF-1:a4MeasSCellAddSsbRsrp:a4ThresholdSCellAddSsbRsrp=75
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_IEF-1:a4MeasSCellAddSsbRsrp:a4TimeToTriggerSCellAddSsbRsrp=ms320
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-1:nrMeasPrIefList
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-1:nrMeasPrIefList:{"ssbFrequency01":"631968"}
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-1:nrMeasPrIefList:nrMeasPrIefDN=NRMEASPR_IEF-1
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-1:snssaiList
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-1:snssaiList:{"snssaiDN":"${nrbts_nidd}/SNSSAI-2"}
    ...  delete:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-1:pcCapabilityList
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}:measPrMaSAList
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}:measPrMaSAList:{"measPrPriority":"1"}
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}:measPrMaSAList:nrMeasPrMaSADN=${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-1

    scf.Perform SCF Modification    modification_strings=${GNB_PARAMS_IN_SCF}
    ${list_1}=    Create List  A4-based
    scf.Add Elements To List
    ...  dist_name=${nrbts_nidd}
    ...  list_name=actMeasBasedSCellAdditionSa   elements=${list_1}

    scf.Save SCF  ${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_mod.xml

    scf.Calculate Delta SCF
    ...  target_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_mod.xml
    ...  actual_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id}_DU.xml
    ...  delta_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_delta.xml

    ${oam_alias}=   connect.Setup OAM Http Session   node_id=${gnb_id}
    ${file1}=  Get File  ${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_delta.xml
    IF    ${file1} != []
        admin.Perform Delta Recommissioning    delta_file=${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_delta.xml
        ...  skip_parameter_relation_errors=${True}
        ...  connection=${oam_alias}
    END

    gnb.Wait Until Node To Be Onair State   node_id=${gnb_id}

    admin.Block Cell  dist_name=${nrbts_nidd}/NRCELL-2  connection=${oam_alias}
    admin.Block Cell  dist_name=${nrbts_nidd}/NRCELL-3  connection=${oam_alias}
    admin.Block Cell  dist_name=${nrbts_nidd}/NRCELL-12  connection=${oam_alias}

    ${enb_alias}  Setup OAM Http Session  node_type=enb  node_id=${enb_id}
    admin.Block All Cells  rat=LTE  timeout=${20}  connection=${enb_alias}

Commissioning GNB For CB013142 G ST TC01 B2 SA Reconfig Of A1 Meas On PCell For SCell Change Using Meas Profile Upon Setup Of VoNR
    [Documentation]    Commissioning of gnb for CB013142_C_ST_TC01_B3
    ...                to overcome linter warning in case of unused variables
    [Arguments]        ${gnb_id}=${0}

    ${configSuiteDir}=    testline.Get Test Suite Config Directory
    scf_info.Set MNL Version String For Branch    basic_scf_name=${configSuiteDir}/SCFC_gNB${gnb_id}_DU.xml
    Log To Console  Start commissioning for gnb
    scf.Load SCF  file_path=${configSuiteDir}/SCFC_gNB${gnb_id}_DU.xml
    Set Test Variable  ${TC_NUMBER}  F01

    #to overcome the 150 sign limitiation
    ${nrbts_nidd}=   Set Variable    MRBTS-${nrbts_id_${gnb_id}}/NRBTS-${nrbts_id_${gnb_id}}
    ${mpr}=   Set Variable    NRMEAS_PROFILE-1

    @{GNB_PARAMS_IN_SCF}   Create List
    #  parameter changes
    ...  modify:${nrbts_nidd}:actBufferBasedSCellAddition=disabled
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRREL-${s_cell_1}:sCellAdditionMethod=covBasedA1
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRREL-${s_cell_1}:sCellOperationalMode=dlOnly
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRREL-${s_cell_2}:sCellAdditionMethod=covBasedA1
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRREL-${s_cell_2}:sCellOperationalMode=dlOnly
    ...  modify:${nrbts_nidd}/NRCELL-${p_cell_1}\$:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=80
    ...  modify:${nrbts_nidd}/NRCELL-${p_cell_1}\$:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=75
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrMeasProfileIntraFreq=5min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrMeasProfileInterFreq=5min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrMeasProfileSCell=5min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrMeasProfileMappingSA=5min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrMeasProfileMappingNSA=5min
    ...  modify:${nrbts_nidd}\$:actMeasurementProfile=SA
    ...  modify:${nrbts_nidd}\$:actCAMeasInMeasProf=SA
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a1MeasSCellAddSsbRsrp
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a1MeasSCellAddSsbRsrp:{"a1HysteresisSCellAddSsbRsrp":"0"}
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=65
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=66
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_IAF-2:a1MeasSCellAddSsbRsrp
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_IAF-2:a1MeasSCellAddSsbRsrp:{"a1HysteresisSCellAddSsbRsrp":"0"}
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_IAF-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_IAF-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=71
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_IAF-2:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}:measPrMaSAList
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}:measPrMaSAList:{"measPrPriority":"1","nrMeasPrMaSADN":"${nrbts_nidd}/${mpr}/NRMEASPR_MA_SA-1"}
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}:measPrMaSAList:{"measPrPriority":"2","nrMeasPrMaSADN":"${nrbts_nidd}/${mpr}/NRMEASPR_MA_SA-2"}
    ...  delete:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-1:pcCapabilityList
    ...  delete:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-2:pcCapabilityList
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-2:snssaiList
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-2:snssaiList:{"snssaiDN":"${nrbts_nidd}/SNSSAI-2"}
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-1:fiveqiValueList

    scf.Perform SCF Modification    modification_strings=${GNB_PARAMS_IN_SCF}
    ${list_1}=    Create List  1
    scf.Add Elements To List
    ...  dist_name=${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-1
    ...  list_name=fiveqiValueList   elements=${list_1}

    scf.Save SCF  ${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_mod.xml

    scf.Calculate Delta SCF
    ...  target_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_mod.xml
    ...  actual_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id}_DU.xml
    ...  delta_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_delta.xml

    ${oam_alias}=   connect.Setup OAM Http Session   node_id=${gnb_id}
    ${file1}=  Get File  ${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_delta.xml
    IF    ${file1} != []
        admin.Perform Delta Recommissioning    delta_file=${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_delta.xml
        ...  skip_parameter_relation_errors=${True}
        ...  connection=${oam_alias}
    END

    gnb.Wait Until Node To Be Onair State   node_id=${gnb_id}

    admin.Block Cell  dist_name=${nrbts_nidd}/NRCELL-2  connection=${oam_alias}
    admin.Block Cell  dist_name=${nrbts_nidd}/NRCELL-3  connection=${oam_alias}
    admin.Block Cell  dist_name=${nrbts_nidd}/NRCELL-12  connection=${oam_alias}

    ${enb_alias}  Setup OAM Http Session  node_type=enb  node_id=${enb_id}
    admin.Block All Cells  rat=LTE  timeout=${20}  connection=${enb_alias}


Commissioning GNB For CB013142 I ST TC01 B6 NSA A1 Based SCell Addition Based On Mobility Meas Results During PSCell Change Using Meas Profile
    [Documentation]    Commissioning of gnb for CB013142_C_ST_TC01_B3
    ...                to overcome linter warning in case of unused variables
    [Arguments]        ${gnb_id}=${1}

    ${configSuiteDir}=    testline.Get Test Suite Config Directory
    scf_info.Set MNL Version String For Branch    basic_scf_name=${configSuiteDir}/SCFC_gNB${gnb_id}_DU.xml
    Log To Console  Start commissioning for gnb
    scf.Load SCF  file_path=${configSuiteDir}/SCFC_gNB${gnb_id}_DU.xml
    Set Test Variable  ${TC_NUMBER}  I01

    #to overcome the 150 sign limitiation
    ${nrbts_nidd}=   Set Variable    MRBTS-${nrbts_id_${gnb_id}}/NRBTS-${nrbts_id_${gnb_id}}
    ${mpr}=   Set Variable    NRMEAS_PROFILE-1

    @{GNB_PARAMS_IN_SCF}   Create List
    #  parameter changes
    ...  modify:${nrbts_nidd}:actBufferBasedSCellAddition=disabled
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}/NRREL-${p_cell_1}:sCellAdditionMethod=covBasedA1
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}/NRREL-${p_cell_1}:sCellOperationalMode=dlOnly
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRREL-${s_cell_2}:sCellAdditionMethod=covBasedA1
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRREL-${s_cell_2}:sCellOperationalMode=dlOnly
    ...  modify:${nrbts_nidd}/NRCELL-${p_cell_1}\$:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=75
    ...  modify:${nrbts_nidd}/NRCELL-${p_cell_1}\$:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70
    ...  modify:${nrbts_nidd}\$:actHoOptimizationCa=true
    ...  modify:${nrbts_nidd}\$:actExtN77Support=false
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrMeasProfileIntraFreq=5min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrMeasProfileInterFreq=5min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrMeasProfileSCell=5min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrMeasProfileMappingSA=5min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrMeasProfileMappingNSA=5min
    ...  modify:${nrbts_nidd}\$:actMeasurementProfile=SA+NSA
    ...  modify:${nrbts_nidd}\$:actCAMeasInMeasProf=SA+NSA
    ...  modify:${nrbts_nidd}\$:actSPID=true
    ...  modify:${nrbts_nidd}:actSpidBasedSlicingNSA=true
    ...  modify:${nrbts_nidd}/NRCELL-${s_cell_1}:a1ThresholdhoSsbRsrp=65
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}:a2MeasPCellSwitchEnabled=rsrp
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}:a2MeasPCellSwitchSsbRsrp
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}:a2MeasPCellSwitchSsbRsrp:{"a2HysteresisPCellSwitchSsbRsrp":"0"}
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=65
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=480ms
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=0
    ...  modify:${nrbts_nidd}/NRCELL-${s_cell_1}:freqBandIndicatorNR=77
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a1MeasSCellAddSsbRsrp
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a1MeasSCellAddSsbRsrp:{"a1HysteresisSCellAddSsbRsrp":"0"}
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=75
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=80
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}:measPrMaNSAList
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}:measPrMaNSAList:{"measPrPriority":"1","nrMeasPrMaNSADN":"${nrbts_nidd}/${mpr}/NRMEASPR_MA_NSA-1"}
    ...  delete:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-1:pcCapabilityList
    ...  add:${nrbts_nidd}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-1:spid=256
    ...  add:[com.nokia.srbts.nrbts:NRHOIF, ${nrbts_nidd}/NRCELL-${s_cell_1}/NRHOIF-4, MNL${version}, create]
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}/NRHOIF-4:a1BasedPCellSwitchEnabled=false
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}/NRHOIF-4:a2BasedPCellSwitchEnabled=true
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}/NRHOIF-4:a2BasedPCellSwitchPriority=1
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}/NRHOIF-4:a3MeasEnabled=rsrp
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}/NRHOIF-4:a3MeasSsbRsrp
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}/NRHOIF-4:a3MeasSsbRsrp:{"a3HysteresisSsbRsrp":"2"}
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}/NRHOIF-4:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}/NRHOIF-4:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms128
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}/NRHOIF-4:a4MeasEnDcSteeringEnabled=none
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}/NRHOIF-4:a4MeasHigherPrioFreqEnabled=none
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}/NRHOIF-4:a4MeasNrDcEnabled=none
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}/NRHOIF-4:a4MeasSCellAddEnabled=none
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}/NRHOIF-4:a5MeasEnabled=none
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}/NRHOIF-4:cellDepType=SA+NSA
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}/NRHOIF-4:freqBandIndicatorNR=77
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}/NRHOIF-4:ifhoSsbScs=30 KHz
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}/NRHOIF-4:ifhoSsbSmtcDuration=sf5
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}/NRHOIF-4:ifhoSsbSmtcPeriodicity=sf20
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}/NRHOIF-4:numberOfTransmittedSsBlocks=32 beams
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}/NRHOIF-4:scs=30 KHz
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}/NRHOIF-4:ssBurstSetPeriod=20
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}/NRHOIF-4:ssbFrequency=650016
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}/NRHOIF-4:thresholdPCellSwitchTargetRsrp=65
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}/NRHOIF-4:thresholdPCellSwitchTargetRsrq=1
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}/NRHOIF-4:a3a5Priority=100
    ...  add:${nrbts_nidd}/NRCELL-${s_cell_1}/NRHOIF-4:deriveSsbIndexFromCell=true

    scf.Perform SCF Modification    modification_strings=${GNB_PARAMS_IN_SCF}
    scf.Save SCF  ${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_mod.xml

    scf.Calculate Delta SCF
    ...  target_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_mod.xml
    ...  actual_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id}_DU.xml
    ...  delta_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_delta.xml

    ${oam_alias}=   connect.Setup OAM Http Session   node_id=${gnb_id}
    ${file1}=  Get File  ${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_delta.xml
    IF    ${file1} != []
        admin.Perform Delta Recommissioning    delta_file=${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_delta.xml
        ...  skip_parameter_relation_errors=${True}
        ...  connection=${oam_alias}
    END

    gnb.Wait Until Node To Be Onair State   node_id=${gnb_id}
