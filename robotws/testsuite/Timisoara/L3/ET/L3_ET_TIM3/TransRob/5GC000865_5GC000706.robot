*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Documentation    :copyright: Nokia
...              :author: Alexandru Tancau
...              :contact: alexandru.tancau@nokia.com
...              Transversal Robustness testcases added after creation of MNRCA-63437
...              Link: https://jiradc.ext.net.nokia.com/browse/MNRCA-63437

Resource     ../resources/5G_SW_WRO_Keywords.robot
Resource     TransRob_Variables_Keywords.robot

Suite Setup     Run Keywords    Setup Custom IPHY   iphy=${custom-iphy}
...             AND             Setup Custom SCF    scf=${custom-scf}
...             AND             Start UTE eth3 interfaces
...             AND             Start Default Logging      output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...             AND             Reach Onair
...                             lua_cfg=${CURDIR}/config/wts.cfg     check_edaemon_port=True
...             AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Test Setup        Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown     Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
TransRob_5GC000866-E_4_5GC000706_inter-gNB_HO_MNRCA-63437
    [Documentation]    This case is designed to verify inter-gNB in interaction with feature 5GC000865_E.
    ...                1. UE HO from real gNB to simulated gNB.
    ...                2. During HO, send RRC invalid payload to crash CPUE
    ...                3. UE attach will fail on simulated gNB.
    Add UE History Information List
    Register UE And Check A2 MeasConfig
    UE Triggers Inter-Frequency Inter-gNB HO and Check MeasGap Setup
