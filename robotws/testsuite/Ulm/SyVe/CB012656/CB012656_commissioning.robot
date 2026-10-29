*** Settings ***
Documentation   covers the commissioning for the CB012656 TCs

...

#-----------------------------------------------------------------------------------------------------------------------------------[150 characters]
Resource    ../../resources/Common/testline.robot
Library    taf.sbts.oam.coam.admin          WITH NAME   admin
Library    taf.config.scf                   WITH NAME   scf


*** Keywords ***
Commissioning gNB
   [Arguments]   ${test_name}

   run keyword  Commissioning gNB for ${test_name}

######

Commissioning gNB for CB012656-A-004_NR_UL_CA_aware_Idle_mode_mobility_steering_WRR_Prim_Sec_gNBinitiatedRRCRelease
    [Documentation]    Commissioning of gnb for ${test_name}
    [Arguments]        ${gnb_id}=${0}
    ${configSuiteDir}=    testline.Get test suite config directory
    Log to Console  Start commissioning for gnb
    scf.load_scf  file_path=${configSuiteDir}/SCFC_gNB${gnb_id}_DU.xml
    set test variable  ${tc_number}  A004

    #to overcome the 150 sign limitiation
    ${nrbts_nidd}=   Set Variable    MRBTS-${nrbts_id_${gnb_id}}/NRBTS-${nrbts_id_${gnb_id}}
    ${nrsysinfo_profile}  Set Variable  MRBTS-${nrbts_id_${gnb_id}}/NRBTS-${nrbts_id_${gnb_id}}/NRSYSINFO_PROFILE-6

    @{GNB_PARAMS_IN_SCF}   create list
    #  parameter changes
    ...  modify:${nrbts_nidd}\$:actUlCaAwareIMMSteering=true
    ...  modify:${nrbts_nidd}\$:actMobilityProfile=false
    ...  modify:${nrbts_nidd}\$:actIdleMMSteering=false
    ...  modify:${nrbts_nidd}\$:actIdlMMEnDcSteering=false
    ...  modify:${nrbts_nidd}/NRCELL-${cell}\$:idleMMSteeringAlgo=UL CA aware
    ...  modify:${nrbts_nidd}/NRCELL-${cell}\$:idleMMSteeringPercentageOfUes=100
    ...  modify:${nrbts_nidd}/NRCELL-${cell}\$:idleMMSteeringWRREnabled=true
    ...  modify:${nrbts_nidd}/NRCELL-${cell}\$:idleMMSteeringWRREnabledSec=UL CA aware
    ...  modify:${nrbts_nidd}\$:drbInactivityTimerSA=5
    ...  modify:${nrbts_nidd}\$:srbInactivityTimerSA=10
    ...  modify:${nrbts_nidd}/NRCELL-${cell}\$:nrSysInfoProfileDN=${nrsysinfo_profile}
    ...  add:${nrbts_nidd}/NRCELL-${cell}:ulCaAwareIMMServCelResWeight=30
    #all counters needs to be changed from 5min to 15min, otherwise the keyword cannot not find the counters -> keyword limitiation
    ...  modify:MRBTS-${nrbts_id_${gnb_id}}/MNL-1/MNLENT-1/PMCADM-1:reportingIntervalPm=15min
    ...  modify:MRBTS-${nrbts_id_${gnb_id}}/MNL-1/MNLENT-1/PMMNL-1:eCpriMasterStatisticsInterval=15min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrRRCC=15min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrCaCu=15min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrEirp=15min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrHighRlcCell=15min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrHighRlcCellNrpmqap=15min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrPDCPCell=15min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrRSACU=15min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrRSADU=15min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrRacCu=15min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrRacDu=15min

    scf.perform_scf_modification    modification_strings=${GNB_PARAMS_IN_SCF}
    scf.save_scf  ${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_mod.xml

    scf.calculate delta scf
    ...  target_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_mod.xml
    ...  actual_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id_}_DU.xml
    ...  delta_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_delta.xml

    ${oam_alias}=   connect.Setup OAM http session   node_id=${gnb_id}
    ${file1}=  get file  ${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_delta.xml
    IF  ${file1} != []
    ...  admin.Perform_Delta_Recommissioning    delta_file=${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_delta.xml
    ...  skip_parameter_relation_errors=${True}
    ...  connection=${oam_alias}

    ${enb_alias}  Setup OAM http session  node_type=enb  node_id=${enb_id}
    admin.block_all_cells  rat=LTE  timeout=${20}  connection=${enb_alias}

Commissioning gNB for CB012656-A-026_NR_UL_CA_aware_Idle_mode_mobility_steering_Weight_based_gNBinitiatedRRCRelease
    [Documentation]    Commissioning of gnb for test1
    [Arguments]       ${gnb_id}=${0}
    ${configSuiteDir}=    testline.Get test suite config directory
    Log to Console  Start commissioning for gnb
    scf.load_scf  file_path=${configSuiteDir}/SCFC_gNB${gnb_id}_DU.xml
    set test variable  ${tc_number}  B026

    #to overcome the 150 sign limitiation
    ${nrbts_nidd}=   Set Variable    MRBTS-${nrbts_id_${gnb_id}}/NRBTS-${nrbts_id_${gnb_id}}
    ${nrsysinfo_profile}  Set Variable  MRBTS-${nrbts_id_${gnb_id}}/NRBTS-${nrbts_id_${gnb_id}}/NRSYSINFO_PROFILE-6

    @{GNB_PARAMS_IN_SCF}   create list
    #  parameter changes
    ...  modify:${nrbts_nidd}\$:actUlCaAwareIMMSteering=true
    ...  modify:${nrbts_nidd}\$:actMobilityProfile=false
    ...  modify:${nrbts_nidd}\$:actIdleMMSteering=false
    ...  modify:${nrbts_nidd}\$:actIdlMMEnDcSteering=false
    ...  modify:${nrbts_nidd}/NRCELL-${cell}\$:idleMMSteeringAlgo=UL CA aware
    ...  modify:${nrbts_nidd}/NRCELL-${cell}\$:idleMMSteeringPercentageOfUes=100
    ...  modify:${nrbts_nidd}/NRCELL-${cell}\$:idleMMSteeringWRREnabled=false
    ...  modify:${nrbts_nidd}/NRCELL-${cell}\$:idleMMSteeringWRREnabledSec=Disabled
    ...  modify:${nrbts_nidd}\$:drbInactivityTimerSA=5
    ...  modify:${nrbts_nidd}\$:srbInactivityTimerSA=10
    ...  modify:${nrbts_nidd}/NRCELL-${cell}\$:nrSysInfoProfileDN=${nrsysinfo_profile}
    ...  add:${nrbts_nidd}/NRCELL-${cell}:ulCaAwareIMMServCelResWeight=30
    #all counters needs to be changed from 5min to 15min, otherwise the keyword cannot not find the counters -> keyword limitiation
    ...  modify:MRBTS-${nrbts_id_${gnb_id}}/MNL-1/MNLENT-1/PMCADM-1:reportingIntervalPm=15min
    ...  modify:MRBTS-${nrbts_id_${gnb_id}}/MNL-1/MNLENT-1/PMMNL-1:eCpriMasterStatisticsInterval=15min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrRRCC=15min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrCaCu=15min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrEirp=15min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrHighRlcCell=15min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrHighRlcCellNrpmqap=15min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrPDCPCell=15min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrRSACU=15min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrRSADU=15min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrRacCu=15min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrRacDu=15min

    scf.perform_scf_modification    modification_strings=${GNB_PARAMS_IN_SCF}
    scf.save_scf  ${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_mod.xml

    scf.calculate delta scf
    ...  target_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_mod.xml
    ...  actual_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id_}_DU.xml
    ...  delta_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_delta.xml

    ${oam_alias}=   connect.Setup OAM http session   node_id=${gnb_id}
    ${file1}=  get file  ${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_delta.xml
    IF  ${file1} != []
    ...  admin.Perform_Delta_Recommissioning    delta_file=${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_delta.xml
    ...  skip_parameter_relation_errors=${True}
    ...  connection=${oam_alias}

    ${enb_alias}  Setup OAM http session  node_type=enb  node_id=${enb_id}
    admin.block_all_cells  rat=LTE  timeout=${20}  connection=${enb_alias}

Commissioning gNB for CB012656-B-006_NR_UL_CA_aware_Idle_mode_mobility_steering_WRR_Prim_Sec_RRC_Inactive_with_MobProfile
    [Documentation]    Commissioning of gnb for ${test_name}
    [Arguments]        ${gnb_id}=${0}  ${enb_id}=${0}
    ${configSuiteDir}=    testline.Get test suite config directory
    Log to Console  Start commissioning for gnb
    scf.load_scf  file_path=${configSuiteDir}/SCFC_gNB${gnb_id}_DU.xml
    set test variable  ${tc_number}  B006

    #to overcome the 150 sign limitiation
    ${nrbts_nidd}=   Set Variable    MRBTS-${nrbts_id_${gnb_id}}/NRBTS-${nrbts_id_${gnb_id}}
    ${nrsysinfo_profile}  Set Variable  MRBTS-${nrbts_id_${gnb_id}}/NRBTS-${nrbts_id_${gnb_id}}/NRSYSINFO_PROFILE-6

    @{GNB_PARAMS_IN_SCF}   create list
    #  parameter changes
    ...  modify:${nrbts_nidd}\$:actUlCaAwareIMMSteering=true
    ...  modify:${nrbts_nidd}\$:actMobilityProfile=true
    ...  modify:${nrbts_nidd}\$:actIdleMMSteering=false
    ...  modify:${nrbts_nidd}\$:actIdlMMEnDcSteering=false
    ...  modify:${nrbts_nidd}/NRCELL-${cell}\$:idleMMSteeringAlgo=UL CA aware
    ...  modify:${nrbts_nidd}/NRCELL-${cell}\$:idleMMSteeringPercentageOfUes=100
    ...  modify:${nrbts_nidd}/NRCELL-${cell}\$:idleMMSteeringWRREnabled=true
    ...  modify:${nrbts_nidd}/NRCELL-${cell}\$:idleMMSteeringWRREnabledSec=UL CA aware
    ...  modify:${nrbts_nidd}\$:drbInactivityTimerSA=5
    ...  modify:${nrbts_nidd}\$:srbInactivityTimerSA=10
    ...  modify:${nrbts_nidd}/NRCELL-${cell}\$:nrSysInfoProfileDN=${nrsysinfo_profile}
    ...  modify:${nrbts_nidd}\$:rrcInactIMMSteeringEnabled=true
    ...  modify:${nrbts_nidd}\$:drbRrcInactInactivityTimerSA=10
    #all counters needs to be changed from 5min to 15min, otherwise the keyword cannot not find the counters -> keyword limitiation
    ...  modify:MRBTS-${nrbts_id_${gnb_id}}/MNL-1/MNLENT-1/PMCADM-1:reportingIntervalPm=15min
    ...  modify:MRBTS-${nrbts_id_${gnb_id}}/MNL-1/MNLENT-1/PMMNL-1:eCpriMasterStatisticsInterval=15min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrRRCC=15min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrCaCu=15min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrEirp=15min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrHighRlcCell=15min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrHighRlcCellNrpmqap=15min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrPDCPCell=15min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrRSACU=15min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrRSADU=15min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrRacCu=15min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrRacDu=15min

    scf.perform_scf_modification    modification_strings=${GNB_PARAMS_IN_SCF}
    scf.save_scf  ${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_mod.xml

    scf.calculate delta scf
    ...  target_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_mod.xml
    ...  actual_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id_}_DU.xml
    ...  delta_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_delta.xml

    ${oam_alias}=   connect.Setup OAM http session   node_id=${gnb_id}
    ${file1}=  get file  ${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_delta.xml
    IF  ${file1} != []
    ...  admin.Perform_Delta_Recommissioning    delta_file=${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_delta.xml
    ...  skip_parameter_relation_errors=${True}
    ...  connection=${oam_alias}

    gnb.Wait Until Node To Be Onair State   node_id=${gnb_id}
    admin.block_cell  dist_name=MRBTS-${nrbts_id_${gnb_id}}/NRBTS-${nrbts_id_${gnb_id}}/NRCELL-2  connection=${oam_alias}

    ${enb_alias}  Setup OAM http session  node_type=enb  node_id=${enb_id}
    admin.block_all_cells  rat=LTE  timeout=${20}  connection=${enb_alias}

Commissioning gNB for CB012656-D-006_NR_DL_CA_aware_Idle_mode_mobility_steering_WRR_Prim_Sec_RRC_Inactive_CB012656_enabled_withMob_Profile
    [Documentation]    Commissioning of gnb for ${test_name}
    [Arguments]        ${gnb_id}=${0}  ${enb_id}=${0}
    ${configSuiteDir}=    testline.Get test suite config directory
    Log to Console  Start commissioning for gnb
    scf.load_scf  file_path=${configSuiteDir}/SCFC_gNB${gnb_id}_DU.xml
    set test variable  ${tc_number}  D006

    #to overcome the 150 sign limitiation
    ${nrbts_nidd}=   Set Variable    MRBTS-${nrbts_id_${gnb_id}}/NRBTS-${nrbts_id_${gnb_id}}
    ${nrsysinfo_profile}  Set Variable  MRBTS-${nrbts_id_${gnb_id}}/NRBTS-${nrbts_id_${gnb_id}}/NRSYSINFO_PROFILE-6

    @{GNB_PARAMS_IN_SCF}   create list
    #  parameter changes
    ...  modify:${nrbts_nidd}\$:actUlCaAwareIMMSteering=true
    ...  modify:${nrbts_nidd}\$:actMobilityProfile=true
    ...  modify:${nrbts_nidd}\$:actIdleMMSteering=true
    ...  modify:${nrbts_nidd}\$:actIdlMMEnDcSteering=false
    ...  modify:${nrbts_nidd}/NRCELL-${cell}\$:idleMMSteeringAlgo=UL and DL CA aware
    ...  modify:${nrbts_nidd}/NRCELL-${cell}\$:idleMMSteeringPercentageOfUes=100
    ...  modify:${nrbts_nidd}/NRCELL-${cell}\$:idleMMSteeringWRREnabled=true
    ...  modify:${nrbts_nidd}/NRCELL-${cell}\$:idleMMSteeringWRREnabledSec=UL and DL CA aware
    ...  modify:${nrbts_nidd}\$:drbInactivityTimerSA=5
    ...  modify:${nrbts_nidd}\$:srbInactivityTimerSA=10
    ...  modify:${nrbts_nidd}/NRCELL-${cell}\$:nrSysInfoProfileDN=${nrsysinfo_profile}
    ...  modify:${nrbts_nidd}\$:rrcInactIMMSteeringEnabled=true
    ...  modify:${nrbts_nidd}\$:drbRrcInactInactivityTimerSA=10
    ...  add:${nrbts_nidd}/NRSYSINFO_PROFILE-6/NRIRFIM-3:idleMMNrCelResWeight=40
    ...  add:${nrbts_nidd}/NRSYSINFO_PROFILE-6/NRIRFIM-4:idleMMNrCelResWeight=50
    #all counters needs to be changed from 5min to 15min, otherwise the keyword cannot not find the counters -> keyword limitiation
    ...  modify:MRBTS-${nrbts_id_${gnb_id}}/MNL-1/MNLENT-1/PMCADM-1:reportingIntervalPm=15min
    ...  modify:MRBTS-${nrbts_id_${gnb_id}}/MNL-1/MNLENT-1/PMMNL-1:eCpriMasterStatisticsInterval=15min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrRRCC=15min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrCaCu=15min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrEirp=15min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrHighRlcCell=15min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrHighRlcCellNrpmqap=15min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrPDCPCell=15min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrRSACU=15min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrRSADU=15min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrRacCu=15min
    ...  modify:${nrbts_nidd}/NRPMRNL-1:miNrRacDu=15min

    scf.perform_scf_modification    modification_strings=${GNB_PARAMS_IN_SCF}
    scf.save_scf  ${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_mod.xml

    scf.calculate delta scf
    ...  target_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_mod.xml
    ...  actual_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id_}_DU.xml
    ...  delta_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_delta.xml

    ${oam_alias}=   connect.Setup OAM http session   node_id=${gnb_id}
    ${file1}=  get file  ${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_delta.xml
    IF  ${file1} != []
    ...  admin.Perform_Delta_Recommissioning    delta_file=${configSuiteDir}/SCFC_gNB${gnb_id}_${tc_number}_delta.xml
    ...  skip_parameter_relation_errors=${True}
    ...  connection=${oam_alias}

    gnb.Wait Until Node To Be Onair State   node_id=${gnb_id}
    admin.block_cell  dist_name=MRBTS-${nrbts_id_${gnb_id}}/NRBTS-${nrbts_id_${gnb_id}}/NRCELL-2  connection=${oam_alias}

    ${enb_alias}  Setup OAM http session  node_type=enb  node_id=${enb_id}
    admin.block_all_cells  rat=LTE  timeout=${20}  connection=${enb_alias}
