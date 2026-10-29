*** Settings ***
Documentation   SWR test case wth kpi2i/j, kpi2o/p and examples for kpi57(e/f, g/h) compare TCs.
Force Tags      QCD_MN_RAN  QCP_RAN_ST  ${ENB_BRANCH}  SRAN  CLOUD_SRAN_LWG_1342_1ASIA__2ABIA_1AHEGB_1AHFIC
Library         XML  use_lxml=True

Suite Teardown    Save kpi results

Resource    ../../KPI/test_resources/KPI__Compare_KPI.robot
Resource    ../../KPI/test_resources/KPI__SW_download_and_activation__SBTS_to_SBTS.robot

Variables    targets.py


*** Variables ***
${SCF_ID}           01
${TIM_DIRECTORY_PATH_ON_ROTTA}    SBTS1Vrf/OAM_KPI/CRT
${REFERENCE_CONFIGURATION_ID}     CNF_SRAN_10342

*** Test Cases ***
[1][1.0] Airscale_Local_Software_Download_and_Activation
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}  SBTS00_ENB_9999_250723_000008_release_BTSSM_downloadable_A54
    ...    AND    Set Test Variable    ${Target SW dir}   /media/BuildShareTimi01/SBTS/Trunk
    ...    AND    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Setup
    ...    AND    Modify Resource Search Order    KPI__SW_download_and_activation__SBTS_to_SBTS
    TC__KPI__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    KPI__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order


[1][1.0]KPI#2i/j SWR_SW - Last cell down to first cell up
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    ${SWR_LAST_CELL_DOWN_FIRST_CELL_UP_KPI_2}
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    KPI__Compare_KPI.TC Teardown


[1][1.0]KPI#2o/p SWR_SW - Last cell down to first cell up
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    ${SWR_LAST_CELL_DOWN_FIRST_CELL_UP_KPI_2}
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    KPI__Compare_KPI.TC Teardown


[1][1.0]KPI#57e/f RU Independent SW - Last cell down to first cell up
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    ${SWR_LAST_CELL_DOWN_FIRST_CELL_UP_KPI_57}
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    KPI__Compare_KPI.TC Teardown


[1][1.0]KPI#57g/h RU Independent SW - Last cell down to first cell up
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    ${SWR_LAST_CELL_DOWN_FIRST_CELL_UP_KPI_57}
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    KPI__Compare_KPI.TC Teardown