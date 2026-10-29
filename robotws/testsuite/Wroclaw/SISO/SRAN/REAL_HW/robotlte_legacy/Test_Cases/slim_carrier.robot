*** Settings ***

Documentation
...  Maintainer:  Author




*** Keywords ***
Slim Carrier L3 Call
  Common Test Setup
  Log To Console  ${REPETITION_COUNT}
  Slim Carrier L3 Call Procedure  ${REPETITION_COUNT}
  [Teardown]    Common Test Teardown


Slim Carrier L3 Call Procedure
  [Arguments]  ${repetition_index}
  Log To Console  ${repetition_index}
  LG Hot Remove Precondition
  Prepare Test Variable  alias=${alias}  HWF_delete=False
  Run Keyword If  ${repetition_index}==1  Set Test Variable  ${SELECTED_CELLS_COPY}  ${SELECTED_CELLS}
  Set Test Variable  ${TESTED_CELLS}  ${SELECTED_CELLS_COPY}
  Set Test Variable  ${SELECTED_CELLS}  ${SELECTED_CELLS_COPY}
  SiSo Convert Id to Runtime Distname  connection=any
  ${out_lcr_id_list}=  SCFC Create LcrId List  scfc_file_path=${OUT_SCFC_CURRENT_FILE_PATH}
  Set Suite Variable  ${OUT_LCR_ID_LIST_FOR_FR_UNDER_TEST}  ${out_lcr_id_list}
  ${out_lncel_id_list}=  SCFC Create LncelId List For LcrdId List
  ...  scfc_file_path=${OUT_SCFC_CURRENT_FILE_PATH}
  ...  lcr_id_list=${out_lcr_id_list}
  ${out_lcr_id_technology_list}=  Create LcrId List With Technology Type  ${OUT_SCFC_CURRENT_FILE_PATH}
  ...  ${out_lcr_id_list}  FDD
  Info Model Wait For Cell Count in Specific States  operationalState=Enabled
  ...  availabilityStatus=Online
  ...  proceduralState=OnAirDone
  ...  expected_cell_count=${OUT_CELL_COUNT_FOR_CONFIGURATION}
  ...  timeout=120  alias=${alias}
  SiSo L3 Call  cells_input=${SELECTED_CELLS}  # deviation=50%
  Set test variable  ${DL_THROUGHPUTS_1}  ${DL_THROUGHPUTS}
  Set test variable  ${UL_THROUGHPUTS_1}  ${UL_THROUGHPUTS}
  ${frmb_present}  ${frmb_sn}=  Run Keyword And Ignore Error  Check RMOD Name  FRMB
  Run Keyword If  '${frmb_present}'=='PASS'  Run Keywords
  ...  Log  Switching on the flag on FRMB  console=True
  ...  AND  Switch On Off The Flag  ${frmb_sn}  0x1e2  1
  ...  ELSE  Log  FRMB rmod not found, flag not set.${\n}  level=warn
  Sleep  60s
  Slim Carrier Activation  eutra_id_list=${TESTED_CELLS}  numBlankDlPrbsDown=${numBlankDlPrbsDown}
  ...  numBlankDlPrbsUp=${numBlankDlPrbsUp}  slimChBw=${slimChBw}
  SiSo L3 Call  cells_input=${SELECTED_CELLS}
  Set test variable  ${DL_THROUGHPUTS_2}  ${DL_THROUGHPUTS}
  Set test variable  ${UL_THROUGHPUTS_2}  ${UL_THROUGHPUTS}
  Sleep  60s
  Slim Carrier Deactivation  eutra_id_list=${TESTED_CELLS}
  Run Keyword If  '${frmb_present}'=='PASS'  Run Keywords
  ...  Log  Switching on the flag on FRMB  console=True
  ...  AND  Switch On Off The Flag  ${frmb_sn}  0x1e2  0
  Info Model Wait For Cell Count in Specific States  operationalState=Enabled
  ...  availabilityStatus=Online
  ...  proceduralState=OnAirDone
  ...  expected_cell_count=${OUT_CELL_COUNT_FOR_CONFIGURATION}
  ...  timeout=120  alias=${alias}
  SiSo L3 Call  cells_input=${SELECTED_CELLS}
  Set test variable  ${DL_THROUGHPUTS_3}  ${DL_THROUGHPUTS}
  Set test variable  ${UL_THROUGHPUTS_3}  ${UL_THROUGHPUTS}
  Throughput Comparison L3 Call  slimChBw=${slimChBw}
  [Teardown]  Detected additional faults  alias=${alias}

Slim Carrier Activation
    [Arguments]  ${eutra_id_list}
    ...          ${log_dir_path}=/home/ute/logs    ${numBlankDlPrbsDown}=7  ${numBlankDlPrbsUp}=7
    ...          ${slimChBw}=12.4
    #${out_lcr_id_list}=     SCFC Create LcrId List       scfc_file_path=${OUT_SCFC_CURRENT_FILE_PATH}
    #Set Suite Variable      ${OUT_LCR_ID_LIST_FOR_FR_UNDER_TEST}      ${out_lcr_id_list}
    #${out_lncel_id_list}=   SCFC Create LncelId List For LcrdId List
    #...                                                  scfc_file_path=${OUT_SCFC_CURRENT_FILE_PATH}
    #...                                                  lcr_id_list=${out_lcr_id_list}
    #Set Test Variable      ${OUT_LNCEL_ID_LIST}      ${out_lncel_id_list}
    Log To Console   Slim Carrier Activation
    admin.Create Delta
    ${blankedPucch}=  Evaluate  ${numBlankDlPrbsDown}+${numBlankDlPrbsUp}
    FOR   ${cell}   IN   @{eutra_id_list}
      ${index}=  Get LNCEL From Dictionary Based ON EUTRA Id  ${BTS_ID}  ${cell}
      admin.Append Parameter Update To Delta    dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${index}/LNCEL_FDD-0
       ...    parameter=actDlSlimCarrier   value=true
      admin.Append Parameter Update To Delta   dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${index}
       ...    parameter=dlsDciCch    value=DCI format 1A
      admin.Append Parameter Update To Delta    dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${index}/LNCEL_FDD-0
       ...    parameter=numBlankDlPrbsDown  value=${numBlankDlPrbsDown}
      admin.Append Parameter Update To Delta   dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${index}/LNCEL_FDD-0
       ...    parameter=numBlankDlPrbsUp    value=${numBlankDlPrbsUp}
      admin.Append Parameter Update To Delta    dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${index}/LNCEL_FDD-0
    ...    parameter=slimRfFilterDL	  value=${slimChBw} MHz
      admin.Append Parameter Update To Delta    dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${index}/LNCEL_FDD-0
    ...    parameter=slimRfFilterUL	  value=${slimChBw} MHz
      admin.Append Parameter Update To Delta    dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${index}/LNCEL_FDD-0
    ...    parameter=blankedPucch	  value=${blankedPucch}
    END
    Create Directory                  ${log_dir_path}/slim/
    Save Delta                        ${log_dir_path}/slim/slim_activation.json
    Perform Delta Recommissioning     ${log_dir_path}/slim/slim_activation.json
    ...                               skip_parameter_relation_errors=True
    ...                               alias=${alias}
    [Teardown]   Teardown Delta Recommissioning  ${KEYWORD_STATUS}

Slim Carrier Deactivation
    [Arguments]  ${eutra_id_list}
    ...          ${log_dir_path}=/home/ute/logs
    #${out_lcr_id_list}=     SCFC Create LcrId List       scfc_file_path=${OUT_SCFC_CURRENT_FILE_PATH}
    #Set Suite Variable      ${OUT_LCR_ID_LIST_FOR_FR_UNDER_TEST}      ${out_lcr_id_list}
    #${out_lncel_id_list}=   SCFC Create LncelId List For LcrdId List
    #...                                                  scfc_file_path=${OUT_SCFC_CURRENT_FILE_PATH}
    #...                                                  lcr_id_list=${out_lcr_id_list}
    Log To Console   Slim Carrier Deactivation
    Create Delta
    FOR   ${cell}   IN   @{eutra_id_list}
      ${index}=  Get LNCEL From Dictionary Based ON EUTRA Id  ${BTS_ID}  ${cell}
      admin.Append Parameter Update To Delta    dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${index}/LNCEL_FDD-0
       ...    parameter=actDlSlimCarrier   value=false
      admin.Append Parameter Update To Delta   dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${index}
       ...    parameter=dlsDciCch    value=DCI format 1C
      admin.Append Parameter Update To Delta    dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${index}/LNCEL_FDD-0
       ...    parameter=numBlankDlPrbsDown  value=0
      admin.Append Parameter Update To Delta   dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${index}/LNCEL_FDD-0
       ...    parameter=numBlankDlPrbsUp    value=0
      admin.Append Parameter Update To Delta    dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${index}/LNCEL_FDD-0
       ...    parameter=blankedPucch	  value=0
      admin.Append Parameter Update To Delta    dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${index}/LNCEL_FDD-0
    ...    parameter=slimRfFilterDL	  value=Nominal
      admin.Append Parameter Update To Delta    dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${index}/LNCEL_FDD-0
    ...    parameter=slimRfFilterUL	  value=Nominal
    END
    Create Directory                  ${log_dir_path}/slim/
    admin.Save Delta                        ${log_dir_path}/slim/slim_deactivation.json
    admin.Perform Delta Recommissioning     ${log_dir_path}/slim/slim_deactivation.json
    ...                               skip_parameter_relation_errors=True
    ...                               alias=${alias}
    [Teardown]   Teardown Delta Recommissioning  ${KEYWORD_STATUS}


Throughput Comparison L3 Call
  [Arguments]  ${ulChBw}=15  ${slimChBw}=12.4
  ${value}=  SCFC Get Activate Category Alarms Value  ${scfc_file_path}
  Set Suite Variable  ${ACT_CATEGORY_ALARMS}  ${value}
  ${cells_number}=  Get Length  ${OUT_LCR_ID_LIST_FOR_FR_UNDER_TEST}
  FOR  ${cell}  IN  @{TESTED_CELLS}
    ${lncel_id}=  Get LNCEL From Dictionary Based ON EUTRA Id  ${BTS_ID}  ${cell}
    ${ulChBw_real}=  Evaluate Xpath
    ...  ${scfc_file_path}
    ...  .//managedObject[@class='NOKLTE:LNCEL_FDD' and contains(@distName, "LNCEL-${lncel_id}")]/p[@name='ulChBw']/text()
    ${ulChBw}=  Split String  ${ulChBw_real[0]}  ${SPACE}
    ${dl_1}=  Get From Dictionary  ${DL_THROUGHPUTS_1}  ${cell}
    ${dl_1}=  Set Variable  ${dl_1}
    ${ul_1}=  Get From Dictionary  ${UL_THROUGHPUTS_1}  ${cell}
    ${ul_1}=  Set Variable  ${ul_1}
    ${dl_2}=  Get From Dictionary  ${DL_THROUGHPUTS_2}  ${cell}
    ${dl_2}=  Set Variable  ${dl_2}
    ${ul_2}=  Get From Dictionary  ${UL_THROUGHPUTS_2}  ${cell}
    ${ul_2}=  Set Variable  ${ul_2}
    ${dl_3}=  Get From Dictionary  ${DL_THROUGHPUTS_3}  ${cell}
    ${dl_3}=  Set Variable  ${dl_3}
    ${ul_3}=  Get From Dictionary  ${UL_THROUGHPUTS_3}  ${cell}
    ${ul_3}=  Set Variable  ${ul_3}
    ${ul_down}=  Evaluate  ((${slimChBw}*${ul_1})/${ulChBw[0]})*0.8
    ${ul_up}=  Evaluate  ((${slimChBw}*${ul_1})/${ulChBw[0]})*1.3
    ${result_ul2}=  evaluate  ${ul_down}< ${ul_2} < ${ul_up}
    run keyword if  '${result_ul2}'=='True'  LOG  UL:${ul_1} and Slim UL:${ul_2}
    run keyword if  '${result_ul2}'=='False'  run keyword and continue on failure  FAIL
    ${result_ul3}=  evaluate  ${ul_1}*0.9 < ${ul_3} < ${ul_1}*1.1
    run keyword if  '${result_ul3}'=='True'  LOG  UL before:${ul_1} and UL after:${ul_3}
    run keyword if  '${result_ul3}'=='False'  run keyword and continue on failure  FAIL
    ${result_dl3}=  evaluate  ${dl_1}*0.9 < ${dl_3} < ${dl_1}*1.1
    run keyword if  '${result_dl3}'=='True'  LOG  DL before:${dl_1} and DL after:${dl_3}
    run keyword if  '${result_dl3}'=='False'  run keyword and continue on failure  FAIL
    ${dl_down}=  Evaluate  ((${slimChBw}*${dl_1})/${ulChBw[0]})*0.8
    ${dl_up}=  Evaluate  ((${slimChBw}*${dl_1})/${ulChBw[0]})*1.3
    ${result_dl2}=  evaluate  ${dl_down} < ${dl_2} < ${dl_up}
    run keyword if  '${result_dl2}'=='True'  LOG  DL:${dl_1} and Slim DL:${dl_2}
    run keyword if  '${result_dl2}'=='False'  run keywords
    ...  LOG  ${dl_down} < ${dl_2} < ${dl_up}  it's not true  console=true
    ...  AND  run keyword and continue on failure  FAIL
  END

Get LNCEL From Dictionary Based ON EUTRA Id
  [Arguments]  ${bts_id}  ${eutra_id}
  ${lncel_keys}=  Get Dictionary Keys  ${cfg.NODES['${bts_id}']['LNCEL']}
  FOR  ${cell}  IN  @{lncel_keys}
    Exit For Loop If  '${cfg.NODES['${bts_id}']['LNCEL']['${cell}']['scf_eutra_id']}'=='${eutra_id}'
  END
  [Return]  ${cell}

Check RMOD Name
  [Arguments]  ${rmod_name}
  ${rmod_parameters}=  admin.Get Parameters For All  RMOD  alias=${alias}
  FOR  ${rmod}  IN  @{rmod_parameters}
    Run Keyword If  '${rmod['productName']}'=='${rmod_name}'  Run Keywords
    ...  Set Test Variable  ${FRMB_SN}  ${rmod['serialNumber']}
    ...  AND  Return From Keyword  ${FRMB_SN}
    ...  ELSE  Fail  FRMB not found. Flag will not be set.
  END

Switch On Off The Flag
  [Arguments]  ${rmod_sn}  ${flag}  ${value}
  radio.Open Connection To Radio Module  ${rmod_sn}
  radio.Send Command  rad -pw ${flag} ${value}
  ${output}  radio.Read Until Regexp  su(cc|c)e(ss|s)fu(ll|l)y  timeout=30
  Log To Console  ${output}
  radio.Close SSH Connection


Slim Carrier L3 NR
  Common Test Setup
    Set Test Variable   ${LOGS_DIR}   ${test_logs_path}
    Slim Carrier NR L3 Call Procedure  ${REPETITION_COUNT}
  [Teardown]    Common Test Teardown

Slim Carrier NR L3 Call Procedure
    [Arguments]  ${repetition_index}
    Log To Console  ${repetition_index}
    LG Hot Remove Precondition
    Run Keyword If  ${repetition_index}==1  Set Test Variable  ${SELECTED_CELLS_COPY}  ${SELECTED_CELLS}
    Set Test Variable  ${TESTED_CELLS}  ${SELECTED_CELLS_COPY}
    Set Test Variable  ${SELECTED_CELLS}  ${SELECTED_CELLS_COPY}
    FOR  ${cell_id}  IN  @{TESTED_CELLS}
      Slim Carrier NR L3 Call Procedure In All Selected Cells  ${cell_id}
    END

Slim Carrier NR L3 Call Procedure In All Selected Cells
    [Arguments]    ${cell_id}
    Set Test Variable  ${bts_id}  ${cfg.active_bts_list}[0]
    Set Test Variable  ${alias}  ${cfg.active_bts_list}[0]
    ${lcr_id}=  Get From Dictionary  ${cfg.NODES['${bts_id}']['NRCEL']['${cell_id}']}  scf_lcr_id
    ${eutra_id}=  Create List   /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-${bts_id}/NRCELL_R-${lcr_id}
    Verify BTS State    ${bts_id}    ${CONFIGURATION_STARTUP_TIMEOUT}
    SiSo L3 Call  cells_input=${eutra_id}   # deviation=50%
    Set test variable    ${DL_THROUGHPUTS_1}   ${DL_THROUGHPUTS}
    Set test variable    ${UL_THROUGHPUTS_1}   ${UL_THROUGHPUTS}
#    ${frmb_present}  ${frmb_sn}=  Run Keyword And Ignore Error  Check RMOD Name  FRMB
#    Run Keyword If  '${frmb_present}'=='PASS'  Run Keywords
#    ...  Log  Switching on the flag on FRMB  console=True
#    ...  AND  Switch On Off The Flag  ${frmb_sn}  0x1e2  1
#    ...  ELSE  Log  FRMB rmod not found, flag not set.${\n}  level=warn

    Slim Carrier Configuration Change    bts_id=${bts_id}  cell_id=${cell_id}
    Verify BTS State    ${bts_id}    ${CONFIGURATION_STARTUP_TIMEOUT}
    SiSo L3 Call  cells_input=${eutra_id}
    Set test variable    ${DL_THROUGHPUTS_2}   ${DL_THROUGHPUTS}
    Set test variable    ${UL_THROUGHPUTS_2}   ${UL_THROUGHPUTS}

    Force Recommissioning With Current Branch On Every Node
#    Run Keyword If  '${frmb_present}'=='PASS'  Run Keywords
#    ...  Log  Switching on the flag on FRMB  console=True
#    ...  AND  Switch On Off The Flag  ${frmb_sn}  0x1e2  0
    Verify BTS State    ${bts_id}    ${CONFIGURATION_STARTUP_TIMEOUT}
    SiSo L3 Call  cells_input=${eutra_id}
    Set test variable    ${DL_THROUGHPUTS_3}   ${DL_THROUGHPUTS}
    Set test variable    ${UL_THROUGHPUTS_3}   ${UL_THROUGHPUTS}
    Throughput Comparison NR L3 Call
    ...  slimRfFilterDL=${slimRfFilterDL}  slimRfFilterUL=${slimRfFilterUL}
#    [Teardown]    Force Recommissioning With Current Branch On Every Node

Slim Carrier Configuration Change
  [Arguments]    ${bts_id}  ${cell_id}
  ${delta_file_name}=  Delta Commissioning Define JSON File Path For 5G slim carrier  ${bts_id}  ${cell_id}
  Perform Delta File Commissioning For 5G slim carrier  ${bts_id}    ${delta_file_name}


Delta Commissioning Define JSON File Path For 5G slim carrier
    [Arguments]    ${bts_id}    ${cell_id}
    ${testsuite_name}=    Fetch From Right
    ...    string=${SUITE_SOURCE}
    ...    marker=/
    ${delta_scf_file}=    Replace String Using Regexp
    ...    string=${SUITE_SOURCE}
    ...    pattern=${testsuite_name}
    ...    replace_with=delta_${bts_id}_slimcarrier_${cell_id}.xml
    ${file_status}=    OperatingSystem.File Should Exist
    ...    path=${delta_scf_file}
    ...    msg=${False}
    [Teardown]    Run Keyword If    '${file_status}'=='${False}'    Fail
    [Return]    ${delta_scf_file}

Perform Delta File Commissioning For 5G slim carrier
    [Arguments]        ${bts_id}    ${delta_scf_file}    ${ignore_errors}=False
#    ${active_file_release}=      Set Variable If    ${cfg.NODES['${bts_id}'].trunk_status}   SBTS00    ${cfg.NODES['${bts_id}']['software_release']}
    Log    \nBTS Delta commissioning procedure on bts_id node=${bts_id} started    console=True
    Log    \nSource File = ${delta_scf_file}.\nProcedure Parameters: Ignore Errors = ${ignore_errors}.    console=True
    Run Keyword And Ignore Error    Wait Sw Update Possible
    ...    bts_ready=True
    ...    readiness_timeout=900
    ...    timeout=1000
    ...    connection=${bts_id}
    ${result}    Run Keyword And Continue On Failure    Perform Commissioning    ${bts_id}    ${delta_scf_file}
    ...    skip_parameter_relation_errors=${ignore_errors}
    ...    should_activate=True
    ...    timeout=${CONFIGURATION_STARTUP_TIMEOUT}
    ...    alias=${bts_id}
    [Teardown]    Log    \nBTS template commissioning procedure on bts_id node=${bts_id} finished.     console=True
    [Return]    ${result}


Throughput Comparison NR L3 Call
    [Arguments]         ${slimRfFilterDL}=17.5   ${slimRfFilterUL}=17.5
    FOR   ${cell}   IN   @{TESTED_CELLS}
        ${dl_bw}=       Get from dictionary    ${cfg.NODES['${BTS_ID}']['NRCEL']['${cell}']}    scf_dl_bw
        ${cell}=  Get From Dictionary  ${cfg.NODES['${bts_id}']['NRCEL']['${cell}']}  scf_eutra_id
        ${dl_bw}=  Remove String Using Regexp  ${dl_bw}  MHz
        ${dl_1}=   Get From Dictionary    ${DL_THROUGHPUTS_1}    ${cell}
        ${dl_1}=   Set Variable   ${dl_1}
        ${ul_1}=   Get From Dictionary    ${UL_THROUGHPUTS_1}    ${cell}
        ${ul_1}=   Set Variable   ${ul_1}
        ${dl_2}=   Get From Dictionary    ${DL_THROUGHPUTS_2}    ${cell}
        ${dl_2}=   Set Variable   ${dl_2}
        ${ul_2}=   Get From Dictionary    ${UL_THROUGHPUTS_2}    ${cell}
        ${ul_2}=   Set Variable   ${ul_2}
        ${dl_3}=   Get From Dictionary    ${DL_THROUGHPUTS_3}    ${cell}
        ${dl_3}=   Set Variable   ${dl_3}
        ${ul_3}=   Get From Dictionary    ${UL_THROUGHPUTS_3}    ${cell}
        ${ul_3}=   Set Variable   ${ul_3}
#        ${calculated_drop}=  Evaluate    ((${slimRfFilterUL}*100)/${ChBw})
#        ${ul_calculated_drop_step_2}=    Evaluate   ((${ul_1}-${ul_2})/${ul_1}*100)
#        ${ul_calculated_drop_step_3}=    Evaluate   ((${ul_1}-${ul_3})/${ul_1}*100)
#
#        ${dl_calculated_drop_step_2}=    Evaluate   ((${dl_1}-${dl_2})/${dl_1}*100)
#        ${dl_calculated_drop_step_3}=    Evaluate   ((${dl_1}-${dl_3})/${dl_1}*100)

#        ${result_ul2}=        evaluate  ${ul_calculated_drop_step_2} < ${calculated_drop}
#        run keyword if    '${result_ul2}'=='True'     LOG  UL:${ul_1} and Slim UL:${ul_2}
#        run keyword if    '${result_ul2}'=='False'    run keyword and continue on failure    FAIL
#
#        ${result_ul3}=        evaluate  ${ul_calculated_drop_step_3} > ${calculated_drop}
#        run keyword if    '${result_ul3}'=='True'     LOG  UL before:${ul_1} and UL after:${ul_3}
#        run keyword if    '${result_ul3}'=='False'    run keyword and continue on failure    FAIL
#
#        ${result_dl2}=        evaluate  ${dl_calculated_drop_step_2} < ${calculated_drop}
#        run keyword if    '${result_dl2}'=='True'     LOG  UL:${dl_1} and Slim UL:${dl_2}
#        run keyword if    '${result_dl2}'=='False'    run keyword and continue on failure    FAIL
#
#        ${result_dl3}=        evaluate  ${dl_calculated_drop_step_3} > ${calculated_drop}
#        run keyword if    '${result_dl3}'=='True'     LOG  UL before:${dl_1} and UL after:${dl_3}
#        run keyword if    '${result_dl3}'=='False'    run keyword and continue on failure    FAIL
        ${ul_down}=    Evaluate   ((${slimRfFilterDL}*${ul_1})/${dl_bw})*0.8
        ${ul_up}=      Evaluate   ((${slimRfFilterDL}*${ul_1})/${dl_bw})*1.3
        ${result_ul2}=        evaluate  ${ul_down}< ${ul_2} < ${ul_up}
        run keyword if    '${result_ul2}'=='True'     LOG  UL:${ul_1} and Slim UL:${ul_2}
        run keyword if    '${result_ul2}'=='False'    run keyword and continue on failure    FAIL
        ${result_ul3}=        evaluate  ${ul_1}*0.9 < ${ul_3} < ${ul_1}*1.1
        run keyword if    '${result_ul3}'=='True'     LOG  UL before:${ul_1} and UL after:${ul_3}
        run keyword if    '${result_ul3}'=='False'    run keyword and continue on failure    FAIL
        ${result_dl3}=        evaluate  ${dl_1}*0.9 < ${dl_3} < ${dl_1}*1.1
        run keyword if    '${result_dl3}'=='True'     LOG  DL before:${dl_1} and DL after:${dl_3}
        run keyword if    '${result_dl3}'=='False'    run keyword and continue on failure    FAIL
        ${dl_down}=    Evaluate   ((${slimRfFilterUL}*${dl_1})/${dl_bw})*0.8
        ${dl_up}=      Evaluate   ((${slimRfFilterUL}*${dl_1})/${dl_bw})*1.3
        ${result_dl2}=        evaluate  ${dl_down} < ${dl_2} < ${dl_up}
        run keyword if    '${result_dl2}'=='True'     LOG  DL:${dl_1} and Slim DL:${dl_2}
        run keyword if    '${result_dl2}'=='False'    run keywords
         ...    LOG    ${dl_down} < ${dl_2} < ${dl_up} it's not true   console=true
         ...    AND    run keyword and continue on failure    FAIL
    END
