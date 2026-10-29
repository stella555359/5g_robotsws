*** Settings ***
Documentation
...   contact: Oleksandr Kulieshov

Library    Process
Library    taf.sbts.oam.coam.admin  WITH NAME  admin
Resource   ../../feature_resources/CB008322/CB008322-G_Beamforming_counters_verification.robot
Resource   ../../feature_resources/CB008322/CB008322-G2_Enhancement_for_dynamic_fallback_SB_BF_CONF_REL_RANK.robot
Resource   ../../feature_resources/CB008322/CB008322-G2_Enhancement_for_dynamic_fallback_SB_BF_CONF_REL_SCHED_PRB.robot
Resource   ../../feature_resources/CB008322/CB008322-G2_Enhancement_for_dynamic_fallback_SB_BF_CONF_REL_SRS_POWER.robot

Suite Setup  Run Keywords  Setup Leoni  AND  Prepare Testline Configuration
Suite Teardown  Run Keyword If All Tests Passed  Restore Original Configuration

*** Variables ***
${TRUNK_SW}                 True                 # Defining if SW version is for branch or trunk

*** Keywords ***
Setup Leoni
    ${result}  Run Process  python  testsuite/Wroclaw/RRM/VRF_WRO2_T023/feature_resources/CB008322/resources/leoni.py  2
    Log              ${result.stdout}    console=True
    Should Be Empty  ${result.stderr}
    Should Be Equal AS Integers  0  ${result.rc}  msg=RC is different from 0.
    Log  === Optical Switch Leoni Is Set! ===  console=True

Prepare Testline Configuration
    Log  === Prepare Testline Configuration ===  console=True
    Setup Admin  bts_host=192.168.255.129  alias=gNB
    ${nrbts_id}  Get BTS ID From ADMIN  alias=gNB
    Set Suite Variable  ${NRBTS_ID}  ${nrbts_id}
    ${scf_path_gnb}  ${_}  Save And Parse SCF  Original_SCF  scf_path=/home/ute/Downloads  alias=gNB
    Set Suite Variable  ${ORIGINAL_SCF_PATH_GNB}  ${scf_path_gnb}
    Perform Commissioning  ${NRBTS_ID}
    ...  /home/ute/testline_configuration/7_16_UTE5GCLOUDU066/CB008322/MRBTS-50560_8305_AEQE_8322_Counters_ABIO_v2.xml
    ...  timeout=600  connection=gNB
    Add Standard Allowed Alarms  alias=gNB
    Wait Until Keyword Succeeds  5m  1m  _Verify Bts States For Iwk Test Helper  alias=gNB
    [Teardown]    Teardown Admin  alias=gNB

Restore Original Configuration
    Log  === Restoring Original Configuration ... ===  console=True
    Setup Admin  bts_host=192.168.255.129  alias=gNB
    Perform Commissioning  ${NRBTS_ID}  ${ORIGINAL_SCF_PATH_GNB}  timeout=600  connection=gNB
    [Teardown]    Teardown Admin  alias=gNB

*** Test Cases ***
CB008322-G_Beamforming_counters_verification
    [Setup]  Run Keywords        Set Library Search Order  CB008322-G_Beamforming_counters_verification
    ...  AND  Set Test Variable  ${NR_CELL_ID}         1
    ...  AND  Set Test Variable  ${PS_CONFIG_PATH}
    ...       testsuite/Wroclaw/RRM/VRF_WRO2_T023/feature_resources/CB008322/resources/PS_conf_8322_Counters.csv
    ...  AND  Set Test Variable  ${NR_CALL_CELL_ID}    828375041
    ...  AND  Set Test Variable  ${CAPABILITY_NR_UE1}  REAL_UE_1
    ...  AND  Set Test Variable  ${CAPABILITY_NR_UE2}  REAL_UE_2
    ...  AND  TC Setup
    Run keyword  TC__${TEST_NAME}
    [Teardown]  TC Teardown

CB008322-G2_Enhancement_for_dynamic_fallback_SB_BF_CONF_REL_RANK
    [Setup]  Run Keywords        Set Library Search Order  CB008322-G2_Enhancement_for_dynamic_fallback_SB_BF_CONF_REL_RANK
    ...  AND  Set Test Variable  ${NR_CELL_ID}         1
    ...  AND  Set Test Variable  ${PS_CONFIG_PATH}
    ...       testsuite/Wroclaw/RRM/VRF_WRO2_T023/feature_resources/CB008322/resources/PS_conf_8322_Counters.csv
    ...  AND  Set Test Variable  ${NR_CALL_CELL_ID}    828375041
    ...  AND  Set Test Variable  ${CAPABILITY_NR_UE}   REAL_UE_1
    ...  AND  Set Test Variable  ${ITERATIONS_NUMBER}  5
    ...  AND  Set Test Variable  ${PHY_LAYER_CELL_ID}  51
    ...  AND  Set Test Variable  ${GNB_IS_TRUNK_SW}    True
    ...  AND  Set Test Variable  ${DOWNLOAD_TTI_DEC}   True
    ...  AND  TC Setup
    Run keyword  TC__${TEST_NAME}
    [Teardown]  TC Teardown

CB008322-G2_Enhancement_for_dynamic_fallback_SB_BF_CONF_REL_SCHED_PRB
    [Setup]  Run Keywords        Set Library Search Order  CB008322-G2_Enhancement_for_dynamic_fallback_SB_BF_CONF_REL_SCHED_PRB
    ...  AND  Set Test Variable  ${NR_CELL_ID}         1
    ...  AND  Set Test Variable  ${NR_CALL_CELL_ID}    828375041
    ...  AND  Set Test Variable  ${CAPABILITY_NR_UE}   REAL_UE_1
    ...  AND  Set Test Variable  ${ITERATIONS_NUMBER}  5
    ...  AND  TC Setup
    Run keyword  TC__${TEST_NAME}
    [Teardown]  TC Teardown

CB008322-G2_Enhancement_for_dynamic_fallback_SB_BF_CONF_REL_SRS_POWER
    [Setup]  Run Keywords        Set Library Search Order  CB008322-G2_Enhancement_for_dynamic_fallback_SB_BF_CONF_REL_SRS_POWER
    ...  AND  Set Test Variable  ${NR_CELL_ID}         1
    ...  AND  Set Test Variable  ${PS_CONFIG_PATH}
    ...       testsuite/Wroclaw/RRM/VRF_WRO2_T023/feature_resources/CB008322/resources/PS_conf_8322_Counters.csv
    ...  AND  Set Test Variable  ${NR_CALL_CELL_ID}    828375041
    ...  AND  Set Test Variable  ${CAPABILITY_NR_UE}   REAL_UE_1
    ...  AND  Set Test Variable  ${DEDICATED_ATT}      40.0
    ...  AND  Set Test Variable  ${ITERATIONS_NUMBER}  5
    ...  AND  TC Setup
    Run keyword  TC__${TEST_NAME}
    [Teardown]  TC Teardown
