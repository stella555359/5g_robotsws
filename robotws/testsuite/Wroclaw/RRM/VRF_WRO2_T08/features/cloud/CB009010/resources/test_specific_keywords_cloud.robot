*** Settings ***
Documentation
...    author:  Michal Halucha
...    contact: michal.halucha@nokia.com

Library     taf.sw.syslog
Library     taf.ue
Library     ta_attenuator
Library     taf.sbts.oam.coam.admin   WITH NAME   taf_admin
Library     ./test_specific_keywords_cloud.py
Library     OperatingSystem
Library     DateTime
Library     ute_admin_infomodel
Library     testsuite/Wroclaw/RRM/resources/webUI_operations.py
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.log_collectors.elt_log_collector.EltLogCollector   WITH NAME   ELT
Resource    testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/cloud/CB009010/resources/test_variables_cloud.py


*** Variables ***
${LOG_PATH}          ${OUTPUT DIR}
&{CONFIGURATION}     pyro_port=9092    com_port=COM5    python=python
${CELL_502}          GNB_1_CELL_502
${CELL_602}          GNB_1_CELL_602


*** Keywords ***
CB010414_parity_CB009010_A_CB009010_A_TC19_Inter_vDU_handover
    ELT.Start Log Collecting
    Sleep    5s
    Trigger HO
    Sleep    5s
    ELT.Stop Log Collecting
    ${elt_log}=  ELT.Download Log   ${LOG_PATH}/elt_log_8505.json
    Validate Cell Reserved For Operator    ${LOG_PATH}/elt_log_8505.json   0
    Check Ho Ue Log    ${LOG_PATH}/elt_log_8505.json
    Validate Cell Cgi Rslt    ${LOG_PATH}/elt_log_8505.json
    Sleep    60s
    Verify Anr Relation


Test Setup
    Setup Vcu Parameters    ENABLED
    Setup Vdu Parameters    true
    Run Keywords    ELT.Setup   ${True}    ${CONFIGURATION}   AND    ELT.Set Logging Filter    OTA


Set Initial Attenuation
    ${cell_list}=   Create list   GNB_1_CELL_502    GNB_1_CELL_602
    Set global variable   ${gnb_cells}   ${cell_list}
    Load Attenuation Config    ${ABSTRACT_LIB_CONFIG}
    Require Attenuator Setup Of    ${gnb_cells}


Teardown
    Detach
    ELT.Shutdown
    Run Keyword If Test Failed      Collect Snapshot For Cloud Tl
    Run Keyword And Ignore Error    taf_admin.Teardown Admin    connection=admin_gnb
    Run Keyword And Ignore Error    taf_admin.Teardown All Aliases For Admin
    Setup Vcu Parameters    DISABLED
    Setup Vdu Parameters    false


Prepare Ue
    Require Ue    UE_1    capabilities=REAL_UE
    Detach Ue     UE_1
