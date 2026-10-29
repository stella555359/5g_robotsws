*** Settings ***
Documentation
...   contact: Magdalena Swierbutowicz

Force Tags        QCD_MN_RAN    QCP_RAN_ST    CRT
Library     taf.sw.reporting_portal
Library     taf.sw.scout  WITH NAME  scout
Library     ute_wtssim
Library     ta5g_testline_management
Library     ta5g_commissioning
Library     ta5g_cell_operations
Resource    ../../resources/ca_IWK.robot
Resource    ../../resources/attenuator.robot
Resource    ../../feature_resources/CB009527/CB009527-D3_SVD_RZF_based_SB_BF_multiple_cells.robot

Suite Setup       Common Suite Setup


*** Variables ***
${SCOUT_TL_NAME}                  10_16_MRBTS-55309     # Name of TL from SCOUT
${USE_SCOUT_INTERNAL_ID}          False                 # Parameter for 'Request SCF' keyword from taf.sw.scout library
${ABSTRACT_LIB_CONFIG}            /home/ute/testline_configuration/7_16_UTE5GCLOUDU091/ta_ue_config.yaml    # Path to the .yaml file
${SHOULD_BE_REPORTED}             True
${LABEL}                          CLASICAL_5G_ASIM_ABIP_AVHA
${QC_DOMAIN}                      MN_RAN
${QC_PROJECT}                     RAN_VRF
${LOG_LINK}                       \\\\nescrotta.nesc.nokia.net\\rotta\\MN_RAN\\RAN_VRF\\25R3\\VRF_WRO2\\Regression
${CB009527_SCF}                   CB009527_scf_MRBTS-55309_WPT.xml


*** Keywords ***
Common Suite Setup
    Log To Console   Attenuator Setup
    Load Attenuation Config And Require Attenuator Setup  ${ABSTRACT_LIB_CONFIG}

    Setup Admin  bts_host=192.168.255.129  alias=gNB
    ${sw_version} =  Get SW Version  alias=gNB
    Set Suite Variable  ${SW_VERSION}  ${sw_version}
    [Teardown]  Teardown Admin  alias=gNB


Attenuator Teardown
    Log To Console   Attenuator Teardown
    Set Attenuation For All Cells  100%


Report Test Case
    [Arguments]  ${qc_id}  ${name}=${TEST_NAME}  ${ca}=VRF_WRO2  ${testline}=${SCOUT_TL_NAME}  ${build}=${SW_VERSION}
    ...  ${label}=${LABEL}  ${qc_domain}=${QC_DOMAIN}  ${qc_project}=${QC_PROJECT}  ${tool}=WebEM  ${links}=${LOG_LINK}
    ...  ${tc_execution_id}=${TC_EXEC_ID}
    ${result} =  Set Variable If  '${TEST_STATUS}' == 'PASS'  passed  failed
    Report To RP  name=${name}  result=${result}  ca=${ca}  testline=${testline}
    ...  build=${build}  qc_domain=${qc_domain}  qc_project=${qc_project}  qc_id=${qc_id}
    ...  label=${label}  tool=${tool}  links=${links}  tc_execution_id=${tc_execution_id}


*** Test Cases ***
CB009527-D3_SVD_RZF_based_SB_BF_multiple_cells
    [Setup]  Run Keywords
    ...  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Set Library Search Order  CB009527-D3_SVD_RZF_based_SB_BF_multiple_cells  admin
    ...  AND  Set Test Variable  ${NR_CELL_ID_1}        70
    ...  AND  Set Test Variable  ${NR_CELL_ID_2}        71
    ...  AND  Set Test Variable  ${NR_CELL_ID_3}        72
    ...  AND  Set Test Variable  ${NR_CELL_ID_4}        73
    ...  AND  Set Test Variable  ${NR_UE_1_ALIAS}       SA2_OP12
    ...  AND  Set Test Variable  ${APN}                 n26wro
    ...  AND  Find Scfc And Fix And Send Full Commissioning  scfc_filename=${CB009527_SCF}
    ...  AND  Wait For Gnb Icmp Echo Reply And Ssh Service Availability
    ...  AND  Wait For All Cells To Be Enabled
    ...  AND  TC Setup
    Run keyword  TC__${TEST_NAME}
    Map Testcase  [1]${TEST_NAME}
    [Teardown]  Run Keywords
    ...  TC Teardown
    ...  AND  Attenuator Teardown
    ...  AND  Run Keyword If  ${SHOULD_BE_REPORTED}  Report Test Case  qc_id=269477
