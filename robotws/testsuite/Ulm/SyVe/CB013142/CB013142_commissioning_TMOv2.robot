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
    ...  modify:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-4:a4MeasSCellAddEnabled=rsrp
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-4:a4MeasSCellAddSsbRsrp
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-4:a4MeasSCellAddSsbRsrp:{"a4HysteresisSCellAddSsbRsrp":"0"}
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-4:a4MeasSCellAddSsbRsrp:a4ThresholdSCellAddSsbRsrp=65
    ...  add:${nrbts_nidd}/NRCELL-${p_cell_1}/NRHOIF-4:a4MeasSCellAddSsbRsrp:a4TimeToTriggerSCellAddSsbRsrp=ms128
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
    ...  add:${nrbts_nidd}:actMeasurementProfReselForCA=pcInSaUlAndDlCaSupported
    ...  modify:${nrbts_nidd}\$:actMeasBasedSCellAdditionNsa=false
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

    admin.Block Cell  dist_name=${nrbts_nidd}/NRCELL-5  connection=${oam_alias}

    ${enb_alias}  Setup OAM Http Session  node_type=enb  node_id=${enb_id}
    admin.Block All Cells  rat=LTE  timeout=${20}  connection=${enb_alias}
