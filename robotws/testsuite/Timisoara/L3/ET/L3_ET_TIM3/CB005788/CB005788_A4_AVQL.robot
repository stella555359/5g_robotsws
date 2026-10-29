#*** Settings ***
#
#Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#...           CONFIGURED    RAN_5G_TDD    RAN_5G    SBTS00    PY36
#...           CONFIGS_Timisoara/RAN_L3_SW_TIM/2_CELLS_SA_TDD_AVQL/iphy_and_scfc.yaml
#...           NoResUsage
#
#Documentation    :copyright: Nokia
#...              :authors: Eduard Lungu     Denisa Coras
#...              :contact: eduard.lungu@nokia.com       denisa.coras@nokia.com
#
#Resource     ../resources/5G_SW_WRO_Keywords.robot
#Resource     ToBeCompletedIfNeeded
#Suite Setup     Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
#...             AND             Start Xn And Ng Interfaces For Second Gnb
#...             AND             Reach OnAir    lua_cfg=ToBeCompleted!!!
#...             AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
#
#Test Setup        Start Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
#Suite Teardown    Run Keywords     ToBeCompleted
#
#*** Test Cases ***
#CB005788_On-lineCellAddingForRFUwhichIsAlreadyHot_AVQL_A4
#    [Tags]    CRT
#    [Documentation]     This test verify the behavior when a new cell is added to the RFU which is already hot.
#
#    ToBeCompleted
