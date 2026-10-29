*** Settings ***
Resource    ../../../robot/common_resource.robot

*** Variables ***
${UE_CONFIG}      config/qualcomm_multi_ue.yml
${UE1_ID}         49896eae        #get from "adb devices" command on UE PC
${UE1_DL_PORT}    5003
${UE1_DL_SERVER_LOG}    /tmp/iperf_server_on_ue_log1.txt
${UE1_UL_PORT}    5005
${UE1_UL_SERVER_LOG}    /tmp/iperf_server_on_pc_log1.txt
${UE1_DL_CLIENT_EXTRA_CMD}    -u -t 3600 -i 1 -P 1 -f m -b 740.00M -l 4000B -T 64
${UE2_ID}         e692ee01
${UE2_DL_PORT}    5004
${UE2_DL_SERVER_LOG}    /tmp/iperf_server_on_ue_log2.txt
${UE2_UL_PORT}    5006
${UE2_UL_SERVER_LOG}    /tmp/iperf_server_on_pc_log2.txt
${UE2_DL_CLIENT_EXTRA_CMD}    -u -t 3600 -i 1 -P 1 -f m -b 500.00M -l 2400B -T 64
${EXPORT_GRID}    LTE;Time Grids;Physical Grid;LTE L1 Tput and BLER vs. Time

*** Test Cases ***
Multi Qualcomm UE Test Example
    Qualcomm Setup
    Qualcomm Start Qxdm Trace    ${UE1_ID}
    Qualcomm Start Qxdm Trace    ${UE2_ID}
    Qualcomm Attach With Adb    ${UE1_ID}
    Qualcomm Attach With Adb    ${UE2_ID}
    Qualcomm Start DL Data    ${UE1_ID}    ${UE1_DL_PORT}    ${UE1_DL_SERVER_LOG}    ${UE1_DL_CLIENT_EXTRA_CMD}
    Qualcomm Start DL Data    ${UE2_ID}    ${UE2_DL_PORT}    ${UE2_DL_SERVER_LOG}    ${UE2_DL_CLIENT_EXTRA_CMD}
    Qualcomm Start UL Data    ${UE1_ID}    ${UE1_UL_PORT}    ${UE1_UL_SERVER_LOG}    ${EMPTY}
    Qualcomm Start UL Data    ${UE2_ID}    ${UE2_UL_PORT}    ${UE2_UL_SERVER_LOG}    ${EMPTY}
    Qualcomm Wait Throughput Timer    30
    ${path1}=    Qualcomm Stop Qxdm Trace    ${UE1_ID}    C:\\tmp\\Qualcomm\\    ${False}
    ${path2}=    Qualcomm Stop Qxdm Trace    ${UE2_ID}    C:\\tmp\\Qualcomm\\
    Qualcomm Stop DL Data    ${UE1_ID}    ${UE1_DL_PORT}
    Qualcomm Stop DL Data    ${UE2_ID}    ${UE2_DL_PORT}
    Qualcomm Stop UL Data    ${UE1_ID}    ${UE1_UL_PORT}
    Qualcomm Stop UL Data    ${UE2_ID}    ${UE2_UL_PORT}
    Qualcomm Export To Txt With Qcat     ${path1}.hdf    C:\\tmp\\Qualcomm\\    ${EXPORT_GRID}
    Qualcomm Export To Txt With Qcat     ${path2}.hdf    C:\\tmp\\Qualcomm\\    ${EXPORT_GRID}
    Qualcomm Detach With Adb    ${UE1_ID}
    Qualcomm Detach With Adb    ${UE2_ID}
    Qualcomm Teardown
