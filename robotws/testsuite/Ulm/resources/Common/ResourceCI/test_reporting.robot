*** Settings ***

Documentation
...   This is a test suite used in KW resourceCI running against real classical TL.
...   It verifies proper function of KWs in reporting.robot for classical deployments.

Library     ../python/reporting.py     WITH NAME    reporting
Resource    ../reporting.robot


*** Variables ***
${P_console}  ${True}


*** Test Cases ***
Test Set SCOUT TC ID For Reporting with ConnectionException
  [Documentation]
  ...   TC should return errormessage since our TLs are not registered to SCOUT
  ...
  ${id}=  Set SCOUT TC ID For Reporting
  ${TEST_STATUS}       Set Variable  Passed
  reporting.Online Reporting To ReP   [1]BipTraceCollectionEvaluation
  ...                       tsResult=${TEST_STATUS}
  ...                       qcFilePath=testsuite/Ulm/resources/Common/ResourceCI/bipcollectionevaluation.qc
  Should Contain  ${id}  ConnectionException


Test Set SCOUT TC ID For Reporting with ConnectionException With Tag
  [Documentation]
  ...   TC should return errormessage since our TLs are not registered to SCOUT
  ...   id should contain error message although ute:id: tag is set  (singlerun case)
  ...
  Set Tags  ute:id:execution_id_set_by_singlerun
  ${id}=  Set SCOUT TC ID For Reporting
  ${TEST_STATUS}       Set Variable  Passed
  reporting.Online Reporting To ReP   [1]BipTraceCollectionEvaluation
  ...                       tsResult=${TEST_STATUS}
  ...                       qcFilePath=testsuite/Ulm/resources/Common/ResourceCI/bipcollectionevaluation.qc
  Should Contain  ${id}  ConnectionException


Test Set SCOUT TC ID For Reporting With Testlinename
  [Documentation]
  ...   TC should return number  since we hichack an existing TL
  ...
  ${id}=  Set SCOUT TC ID For Reporting  scout_tl_name=7_15_TL101_gNB1
  ${TEST_STATUS}       Set Variable  Passed
  reporting.Online Reporting To ReP   [1]BipTraceCollectionEvaluation
  ...                       tsResult=${TEST_STATUS}
  ...                       qcFilePath=testsuite/Ulm/resources/Common/ResourceCI/bipcollectionevaluation.qc
  Should Not Contain  ${id}  ConnectionException


Test Set SCOUT TC ID For Reporting With Testlinename And Existing Tag
  [Documentation]
  ...   TC should return number  since we hichack an existing TL
  ...   tc_id should be "execution_id_set_by_singlerun"
  ...
  Set Tags  ute:id:execution_id_set_by_singlerun
  ${id}=  Set SCOUT TC ID For Reporting  scout_tl_name=7_15_TL101_gNB1
  ${TEST_STATUS}       Set Variable  Passed
  reporting.Online Reporting To ReP   [1]BipTraceCollectionEvaluation
  ...                       tsResult=${TEST_STATUS}
  ...                       qcFilePath=testsuite/Ulm/resources/Common/ResourceCI/bipcollectionevaluation.qc
  Should Not Contain  ${id}  ConnectionException


Test Reporting With Qc_domain Qc_project Qc_id
  [Documentation]
  ...   Instead of using qc file this test uses the qc_id qc_project
  ...   and qc_domain to identify the qc instance in rep/QC
  ...
  ${enb_id}            Set Variable     0
  ${gnb_id}            Set Variable     0
  ${qc_id}             Set Variable     160883
  ${qc_project}        Set Variable     RAN_ET
  ${qc_domain}         Set Variable     MN_RAN
  @{CUSTOMERS_LIST}    Create List      DTAG
  ${kpi_results}       Set Variable     ${EMPTY}
  ${features_covered}  Set Variable     ${EMPTY}
  ${pm_counters}       Set Variable     ${EMPTY}
  ${tl_name}           Set Variable     7_15_TL101_gNB1

  ${TEST_STATUS}       Set Variable  PASS
  ${id}=  Set SCOUT TC ID For Reporting  scout_tl_name=${tl_name}

  ${enb_sw_version}=   Get ENB SW Version If ENB Is Present   ${enb_id}
  ${gnb_sw_version}=   Get GNB SW Build Version   ${gnb_id}
  ${sw_build}=   Construct SW Build From   ${gnb_sw_version}   ${enb_sw_version}

  Report Results To ReP             tcName=BipTraceCollectionEvaluation
  ...                               tc_execution_id=${id}
  ...                               tsResult=${TEST STATUS}
  ...                               swBuild=${sw_build}
  ...                               testLine=${tl_name}
  ...                               suitePath=${SUITE SOURCE}
  ...                               customers=@{CUSTOMERS_LIST}
  ...                               qc_domain=${qc_domain}
  ...                               qc_project=${qc_project}
  ...                               qc_id=${qc_id}
  ...                               ca=VRF_ULM
  ...                               organization=RAN_L2_SW_ULM_SG66
  ...                               location=VRF_ULM
  ...                               qcTestlabPath=None
  ...                               qcTestSetName=None
  ...                               featuresCovered=${features_covered}
  ...                               isForDebugging=no
  ...                               kpi_results=${kpi_results}
  ...                               pmCounters=${pm_counters}
