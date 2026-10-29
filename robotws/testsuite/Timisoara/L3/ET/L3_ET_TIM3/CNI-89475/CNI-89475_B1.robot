*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...           CONFIGURED    RAN_5G_TDD    RAN_5G    CRT    SBTS00    SBTS23R1    PY36
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Cristinel Sava
...              :contact: cristinel/sava@nokia.com

Resource     CNI-89475_B1_Keywords.robot
Resource     ../resources/5G_SW_WRO_Keywords.robot
Library      ta5g_throughput
Library      ta5g_bearers

Suite Setup     Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Add interfaces    ue_id=11
...            AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_89475_B1.json
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/wts.cfg      
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown    Run Keywords    Stop Default Processes And Gather Logs And Compress Logs
...            AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_89475_B1_revert.json
...            AND             Del interfaces    ue_id=11

*** Test Cases ***
CNI89475-B1_5G_RAN_USR_RRM_21100_Include_Location_Information_at_SgNB_IE_in_SgNB_Addition

    log to console  outdir este:${OUTPUT_DIR}
    Activate CB007512 feature    ue_id=11
    Activate EN-DC    ENB=1
    log to console  Attach Ue And Perform SgNBAdditionRequest
    Attach Ue And Perform SgNBAdditionRequest    ue_id=11
    log to console  check pSCell_id for X2AP_SGNB_ADDITION_REQUEST_ACKNOWLEDGE
    Verify Tcpdump Log       packet_filter=${filter_1}
    sleep  5s
