*** Settings ***
Force Tags    CLOUD_5GC_dRNIC_1vDU_P_AP_LO_SWFH    CONFIGURED    RAN_5G    CRT    SBTS00    PY310    NoResUsage

Documentation    :copyright: Nokia
...              :author: Katarzyna Wisniewska
...              :contact: katarzyna.wisniewska@nokia.com

Resource    ../../../../resources/airphone/5G_SW_WRO_Keywords.robot
Library     ta5g_admin_operations
Library     ta5g_egate

Suite Setup    Run Keywords    Enable Cloud
...            AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_cloud.cfg
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Deregister Ue Without Confirmation    ue_id=1
...               AND             Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
5GC000865_E_1_5GC000866_E_1_Security_Mode_Failure_During_Initial_As_Security_Activation

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Perform Parameter Commissioning Aic    parameter=nullFallback    value=true    dist_name=MRBTS-1/NRBTS-1
    ...        AND             Configure Rule For SecurityModeCommand Messages    ue_id=1    rule=failure

    Attach UE    ue_id=1
    Establish PDU Session Without Confirmation    ue_id=1    pdu_id=1    gw_id=1
    Verify Ngap Messages
    ...    packet_filter=${NGAP_INITIAL_CONTEX_SETUP_FAILURE} && ${FAILURE_IN_RADIO_INTERFACE_PROCEDURE}
    Verify Ngap Messages    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMPLETE}
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMPLETE}

    [Teardown]    Run Keywords    Perform Parameter Commissioning Aic    parameter=nullFallback    value=false    dist_name=MRBTS-1/NRBTS-1
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
