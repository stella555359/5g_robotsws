*** Settings ***

*** Variables ***
${alarms_list}                              ${EMPTY}
@{ALLOWED_ARG}                              True    Yes    Oui    true    yes    oui
@{ALLOWED_ALARMS}=
...                                         4592
...                                         61524
...                                         61649
...								            61652
...                                         4334
...                                         4340
...                                         4654
...                                         4655
...                                         4681
...                                         61524
# [FID:4592]   EFaultId_BtsResetCauseAl
# [FID:61524]  EFaultId_SshEnabled
# [FID:61649]  EFaultId_LmpAccessViaPort
# [FID:61652]  EFaultId_RndServicePortEnabled
# [FID:4334]   EFaultId_SerialConsoleActivatedAl
#Update
# [FID:4654]   Ethernet port security is disabled
# [FID:4655]   Service account root access is enabled
# [FID:61524]  SSH enabled
# [FID:4340]  SSH enabled
# [FID:4681] Sanity Check


*** Keywords ***
# NEEDED LOOP NUMBER PER KPIs and RMOD_BTSLOG collection.
Test Suite Variables Initialisation
  # Update of KPIs
  # Backup SCF and swconfig.txt under test
  gnbbbu.get_bts_configuration_file   bts_id=0  local_dir=${PATH_Storage}  filename=current_scf.xml
  ims_keywords.save_swconfig_file  local_dir=${PATH_Storage}  filename=current_swconfig.txt
  Set Suite Variable    ${ALLOWED_ARG}
  ${bts_info}  gnbbbu.get_bts_info
  Set Suite Variable  ${BRANCH}  ${bts_info['swInfo']['swVersion']}
  ${TL_CONFIGURATION}   gNBhwConf.get_hw_conf   ${bts_info}
  Set Suite Variable    ${TL_CONFIGURATION}
  ${KPIs_Target}=   oam_kpis.get_target_kpis   ${BRANCH}   ${TL_CONFIGURATION}
  Set Suite Variable  ${KPIs_Target}
  ${KPI_1A_NUMBER_OF_TESTS_NEEDED}=  Get Variable Value  ${KPI_1A}  ${0}
  Set Suite Variable  ${KPI_1A_NUMBER_OF_TESTS_NEEDED}
  ${KPI_2_NUMBER_OF_TESTS_NEEDED}=  Get Variable Value  ${KPI_2}  ${0}
  Set Suite Variable  ${KPI_2_NUMBER_OF_TESTS_NEEDED}
  ${KPI_3_NUMBER_OF_TESTS_NEEDED}=  Get Variable Value  ${KPI_3}  ${0}
  Set Suite Variable  ${KPI_3_NUMBER_OF_TESTS_NEEDED}
  ${KPI_51_NUMBER_OF_TESTS_NEEDED}=  Get Variable Value  ${KPI_51}  ${0}
  Set Suite Variable  ${KPI_51_NUMBER_OF_TESTS_NEEDED}
  ${KPI_54_NUMBER_OF_TESTS_NEEDED}=  Get Variable Value  ${KPI_54}  ${0}
  Set Suite Variable  ${KPI_54_NUMBER_OF_TESTS_NEEDED}
  ${KPI_16_NUMBER_OF_TESTS_NEEDED}=  Get Variable Value  ${KPI_16}  ${0}
  Set Suite Variable  ${KPI_16_NUMBER_OF_TESTS_NEEDED}
  ${KPI_5_NUMBER_OF_TESTS_NEEDED}=  Get Variable Value  ${KPI_5}  ${0}
  Set Suite Variable  ${KPI_5_NUMBER_OF_TESTS_NEEDED}
  ${KPI_17_NUMBER_OF_TESTS_NEEDED}=  Get Variable Value  ${KPI_17}  ${0}
  Set Suite Variable  ${KPI_17_NUMBER_OF_TESTS_NEEDED}
  ${KPI_12_NUMBER_OF_TESTS_NEEDED}=  Get Variable Value  ${KPI_12}  ${0}
  Set Suite Variable  ${KPI_12_NUMBER_OF_TESTS_NEEDED}
  ${RMOD_BTSLOG}=  Get Variable Value  ${RMOD_BTSLOG}  ${False}
  ${RMOD_BTSLOG}  Set Variable IF  '${RMOD_BTSLOG}' in @{ALLOWED_ARG}
  ...   ${True}
  ...   ${False}
  Set Suite Variable  ${RMOD_BTSLOG}
  ${ACTIVATE_SNAPSHOT}=  Get Variable Value  ${ACTIVATE_SNAPSHOT}  ${False}
  ${ACTIVATE_SNAPSHOT}  Set Variable IF  '${ACTIVATE_SNAPSHOT}' in @{ALLOWED_ARG}
  ...   ${True}
  ...   ${False}
  Set Suite Variable  ${ACTIVATE_SNAPSHOT}
  ${qc_report}=  Get Variable Value  ${qc_report}  ${False}
  Run Keyword IF  '${QC_REPORT}' in @{ALLOWED_ARG}  qcHandler.generate_qc_file
    ...   ${SUITE NAME}
    ...   ${TL_CONFIGURATION}
    ...   ${SUITE SOURCE}
    ...   ${QC_REPORT}
  ims_keywords.create_csv_file_results  ${PATH_Storage}  ${BRANCH}

Update Allowed Alarms List
  ${ALARMS_LIST}=  Get Variable Value  ${ALLOWED_ALARMS_LIST}  ${EMPTY}
  FOR  ${alarm}  IN  @{ALARMS_LIST.split(',')}
    Run Keyword If  '${alarm}' not in @{ALLOWED_ALARMS}
    ...  Append To List  ${ALLOWED_ALARMS}  ${alarm}
  END
  Log   ${ALLOWED_ALARMS}




