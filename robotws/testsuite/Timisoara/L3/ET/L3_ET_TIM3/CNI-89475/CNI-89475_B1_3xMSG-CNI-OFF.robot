*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...           CONFIGURED    RAN_5G_TDD    RAN_5G    CRT    SBTS00    SBTS23R1    PY36
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Cristinel Sava
...              :contact: cristinel.sava@nokia.com

Resource     CNI-89475_B1_Keywords.robot
Resource     ../resources/5G_SW_WRO_Keywords.robot
Library      ta5g_throughput
Library      ta5g_bearers

Suite Setup    Run Keywords    Run  /dcap_basic_config/hotfix/DCAP_Basic_controller.sh start
...            AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Configure DCAP Session
...            AND             Create DCAP BTS
...            AND             Start DCAP Tracing
...            AND             Add interfaces    ue_id=11
...            AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_89475_B1_CNI_OFF.json
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/wts.cfg
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown    Run Keywords    Find Scfc and Send Delta Commissioning    scfc_filename=delta_89475_B1_revert_CNI_OFF.json
...             AND               Stop DCAP
...             AND               Get DCAP Results     output_dirpath=${OUTPUT_DIR}/DCAP_Traces
...             AND               Delete DCAP BTS
...             AND               Stop Default Processes And Gather Logs And Compress Logs
...             AND               Run  docker stop $(docker ps -a -q)
...             AND               Del interfaces    ue_id=11

*** Test Cases ***
CNI-89475_B123_Successful_addition_of_SN_terminated_split_bearers_without_PDCP_anchor_change_by_MeNB_initiated_SgNB_Modification_Preparation

    log to console  outdir este:${OUTPUT_DIR}
    Activate CB007512 feature    ue_id=11
    Activate EN-DC    ENB=1
    log to console  Attach Ue And Perform SgNBAdditionRequest
    Attach Ue And Perform SgNBAdditionRequest    ue_id=11
    log to console  check pSCell_id for X2AP_SGNB_ADDITION_REQUEST_ACKNOWLEDGE
    Verify Tcpdump Log       packet_filter=${filter_1}
    sleep  5s
    log to console  pSCell_id for X2AP_SGNB_ADDITION_REQUEST_ACKNOWLEDGE ok
    log to console  Activate intra_LTE_HO
    Activate intra_LTE_HO    ue_id=11
    log to console  check pSCell_id for X2AP_SGNB_MODIFICATION_REQUEST_ACKNOWLEDGE
    Verify Tcpdump Log       packet_filter=${filter_2}
    sleep  5s
    log to console  pSCell_id for X2AP_SGNB_MODIFICATION_REQUEST_ACKNOWLEDGE ok
    log to console  Activate intra_NR_HO
    Activate intra_NR_HO    ue_id=11
    log to console  check pSCell_id for X2AP_SGNB_MODIFICATION_REQUIRED
    Verify Tcpdump Log       packet_filter=${filter_3}
    sleep  5s
    log to console  pSCell_id for X2AP_SGNB_MODIFICATION_REQUIRED ok

