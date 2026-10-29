*** Settings ***
#Force Tags      CLOUD_5G_I_BO_AP_KL_SANSA_FS_CPRI_CMWV_FDD
#...             CONFIGS_Bangalore/RRM/ET/CB007149/CB007149_AHIB_Inter_GNB_HO.yml
#...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_SC_FDD    5G_RAN     SBTS00    SBTS23R1    CONFIGURED

Resource         ./CB007149_Resource.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/WTS_Runner_BF_CA_HO_Keywords.robot
Library          ta5g_commissioning
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
#Library           taf.rfrl.common_resources.python.coam_parameter

Suite Setup         Run keywords        Suite setup from scratch
...                 AND     OperatingSystem.Run     sudo ip addr add 10.0.1.3/24 dev eth3
...                 AND     OperatingSystem.Run     sudo ip addr add 10.0.1.4/24 dev eth3
...                 AND     Change IPHY File Value    AHIB    5314
...                 AND     Change Testline From Fullstack To L1bypass
...                 AND     add_l1bypass_sic_address_in_gnb_bo     ${GNB_ASIK.ip}      ${port}    ${GNB_ASIK.username}     ${GNB_ASIK.password}
#...                 AND     Perform SCF Delta Commissioning with CB007149_Inter_GNB_HO.json
##...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Sleep   180
...                 AND     gnb.Perform gNB reboot
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}
#...                 AND     Run Keyword and Ignore Error    Get Snapshot
#...                 AND     Run Keyword and Ignore Error    Get Sos Report

Documentation
...
...             author:            kavya kavya,kavya.kavya@nokia.com
...             maintainer:        kavya kavya,kavya.kavya@nokia.com
...
...             INTRODUCTION:
...
...             TEST SET NAME:
...
...
...
...             TESTING SPLIT:
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB007149 CFAM
...             Requirement ID:
...

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/7149_intergNB.cfg
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        1
${ue_id}    1
${ue_id2}   2     
${ue_id3}   3
${cell_id}   1
${pdu_id}   1
${Pdu_session_ID}       1
${nwslice_ID}   1
${nwslice_ID}   1
${nw_id}        1
${gw_ID}     1
${TRF_ID}    1
${TRF_ID2}    2
${QFI_ID}    1
${iphy}             ${CURDIR}/config/iphy/iphy_AHFIB.xml
&{WTS}              Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}     /tmp/
${st_ue_id}         ${11}
${en_ue_id}         ${12}
@{OLD_PARAS_IPHY}   <GSCN>.*</GSCN>
@{NEW_PARAS_IPHY}   <GSCN>5274</GSCN>

*** Test Cases ***
[1]CB007149-A-B5_30MHz_Cell_Bandwidth_FR1-FDD_Inter_GNB_HO_AHIB_SA

#Step0:  start capturing logs
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Start Collecting Syslog     NAME=syslog_ue_attach
    X2AP Link Should be UP
    Establish Xn Link To gNB3
    ue location change
    Sleep   20
    UE Register should be Successful simulated gNB    
    Trigger DL Traffic for SA       ue_id=${UE_ID}    Traffic_rate=kbps     dl_rate=64 
    Trigger UL Traffic for SA       ue_id=${UE_ID}    Traffic_rate=kbps     ul_rate=64 
    HO SA A3 UE measurements
    Stop Data Traffic for SA     ue_id=${UE_ID}
    Sleep   20
    UE Deregister   ue_id=${UE_ID}
    Stop Collecting Syslog       NAME=syslog_ue_attach

***keywords***
UE Register
    log to console   UE attach trigerring now...
    Start CPRT Trace Capturing
    UE Register should be Successful     ${UE_ID}
    Sleep    10s
    Run Keyword And Ignore Error     Stop CPRT capture   ${CaptureCPRT}
    Run Keyword And Ignore Error     Move File    ${LOG_PATH}/NODECPRT_GNB.pcap   ${LOG_PATH}/UE_attach_cprt.pcap

start DL and UL data with throughput 10M
    Start CPRT Trace Capturing
    Start L2 BIP Trace Capturing
    Trigger DL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=kbps     dl_rate=10       trf_id=${TRF_ID}      qfi_id=${QFI_ID}
    sleep   5s
    Trigger UL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=kbps     ul_rate=10       trf_id=${TRF_ID2}      qfi_id=${QFI_ID}
    sleep   5s    reason=Wait for successful BWP switch
    Run Keyword And Ignore Error    Stop L1L2 capture  ${CaptureL1L2}
    Run Keyword And Ignore Error    Move File    ${LOG_PATH}/L1L2_GNB_FS_LO.pcap    ${LOG_PATH}/L1L2_GNB_FS_KL_lowdata.pcap
    Run Keyword And Ignore Error     Stop CPRT capture   ${CaptureCPRT}
    Run Keyword And Ignore Error     Move File    ${LOG_PATH}/NODECPRT_GNB.pcap   ${LOG_PATH}/lowdata_cprt.pcap
    Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=0.010     qfi_id=${QFI_ID}

UE Deregister
    [Arguments]    ${ue_id}
    [Documentation]    This keyword checks the message for the UE Deregistration in the output file for the SA variant
    wtsrunner.ue_deregister    id=${ue_id}    ue_deregister_type=switch_off
    Read WTS Output For Pattern And Print matching Lines    ${UE_deregister_pattern}    ${Timeout_SA}
    BuiltIn.Log                ue_deregister_is_ok

