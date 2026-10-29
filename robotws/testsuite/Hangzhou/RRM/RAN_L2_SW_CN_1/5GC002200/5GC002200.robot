*** Settings ***
Documentation    ...
#Suite Setup       Common Suite Setup
#Test Setup    Common Test Setup 2
#Test Teardown    Common Test Teardown 2
#Suite Teardown    Common Suite Teardown 2
#Force Tags        CRT    RAN_5G_TDD
#...               FR1    Owner_alicchen    PRI-High
#...               SBTS00    SBTS23R1    RAN_5G
#...               CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Library      ../python/ta_kiss_gnb/    WITH NAME    ta_kiss_gnb
#*** Variables ***
#${GNB_ID}              2
#${CELL_ID}             1
#${BEARER_ID}           2
#@{LOG_NAME_LIST}       btslog    snapshot
#${WTS_CFG}           basic_setup.cfg
#${WTS_CFG_Multi_UE}     basic_step_1cell_10UE_SANSA_8DL4UL_5GC002200.cfg
#${LOCAL_WTS_DIR}    ${CURDIR}/config
#${5GC002200_scf}    SCF_2200.xml
#${MU_MIMO_scf}    MU_MIMO.xml
#${FDM_scf}    FDM.xml
#${EIRP_scf}    EIRP.xml
#${iphy}    AEQE_2200_2x4T2R.xml
#${SWCONFIG_PARAM_N1N2_2X2}    0x590004=4;0x5900a8=1
#${SWCONFIG_PARAM_N1N2_4X1}    0x590004=4;0x5900a8=2
#${CELL1_SIB}    eNB 2 cell 1: SystemInformationBlockType2-NR updated
#
#*** Test Cases ***
#5GC002200-ET-E-B1 001 DL CL MIMO interworking with FDM on N1N2=2x2 mode on SA
#    [Tags]    caseB1_1    AP_REG
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_Multi_UE}
#    ...        AND    Suite Setup Update GNB    scf_file=${LOCAL_WTS_DIR}/${FDM_scf}    iphy_file=${LOCAL_WTS_DIR}/${iphy}
#    ...    swconfig_param=${SWCONFIG_PARAM_N1N2_2X2}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Start UTE WTS And Check Cell Setup    ${wts_cfg}
#    ...        AND    Common Test Setup
#    Set CSI Override Testmode with beaforming for subpanel 2x2    profile_id=1
#    Set CSI Override Testmode with beaforming for subpanel 2x2    profile_id=2
#    Set CSI Override Testmode with beaforming for subpanel 2x2    profile_id=2
#    Set CSI Override Testmode with beaforming for subpanel 2x2    profile_id=4
#    Set CSI Override Testmode with beaforming for subpanel 2x2    profile_id=5
#    Set CSI Override Testmode with beaforming for subpanel 2x2    profile_id=6
#    Set CSI Override Testmode with beaforming for subpanel 2x2    profile_id=7
#    Associate UEs to the created profiles with beaforming    UE_ID=1    profile_id=1
#    Associate UEs to the created profiles with beaforming    UE_ID=2    profile_id=2
#    Associate UEs to the created profiles with beaforming    UE_ID=3    profile_id=3
#    Associate UEs to the created profiles with beaforming    UE_ID=4    profile_id=4
#    Associate UEs to the created profiles with beaforming    UE_ID=5    profile_id=5
#    Associate UEs to the created profiles with beaforming    UE_ID=6    profile_id=6
#    Associate UEs to the created profiles with beaforming    UE_ID=7    profile_id=7
#    Attach and Traffic on SA with Multi UE    UE_ID=1    dl_tp_set=170    ul_tp_set=35
#    Attach and Traffic on SA with Multi UE    UE_ID=2    dl_tp_set=170    ul_tp_set=35
#    Attach and Traffic on SA with Multi UE    UE_ID=3    dl_tp_set=170    ul_tp_set=35
#    Attach and Traffic on SA with Multi UE    UE_ID=4    dl_tp_set=170    ul_tp_set=35
#    Attach and Traffic on SA with Multi UE    UE_ID=5    dl_tp_set=170    ul_tp_set=35
#    Attach and Traffic on SA with Multi UE    UE_ID=6    dl_tp_set=170    ul_tp_set=35
#    Attach and Traffic on SA with Multi UE    UE_ID=7    dl_tp_set=170    ul_tp_set=35
#    Sleep    10s
#    Display Multi UE Throughput    1-7
#    @{ue_id_list}    Create List    1    2    3    4    5    6    7
#    @{exp_dl_tp}     Create List    150
#    Sleep    1s    Wait for egate log
#    Check Multi UE DLCA And ULnonCA L1 Cell tput    ${ue_id_list}    10    ${exp_dl_tp}    1
#
#
#5GC002200-ET-C-B1 003 DL CL MIMO PDSCH interworking with EIRP control on N1N2=2X2 mode with multi UE with online change S(m,s) on SA
#    [Tags]    caseB1_3    AP_REG
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_Multi_UE}
#    ...        AND    Suite Setup Update GNB    scf_file=${LOCAL_WTS_DIR}/${EIRP_scf}    iphy_file=${LOCAL_WTS_DIR}/${iphy}
#    ...    swconfig_param=${SWCONFIG_PARAM_N1N2_2X2}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Start UTE WTS And Check Cell Setup    ${wts_cfg}
#    ...        AND    Common Test Setup
#    Set CSI Override Testmode with beaforming for subpanel 2x2    profile_id=1
#    Set CSI Override Testmode with beaforming for subpanel 2x2    profile_id=2
#    Associate UEs to the created profiles with beaforming    UE_ID=1    profile_id=1
#    Associate UEs to the created profiles with beaforming    UE_ID=2    profile_id=1
#    Attach and Traffic on SA with multi trf    UE_ID=1    dl_tp_set=175    ul_tp_set=175
#    Attach and Traffic on SA with multi trf    UE_ID=2    dl_tp_set=175    ul_tp_set=175
#    Check SA UE Throughput    UE_ID=1    dl_tp_threshold=400    ul_tp_threshold=85    qfi=1
#    Check SA UE Throughput    UE_ID=2    dl_tp_threshold=400    ul_tp_threshold=10    qfi=1
#
#5GC002200-ET-D-B4 001 DL CL MIMO CSI-RS resource set downgrade when sinr continue below threshold the on N1N2=4X1 mode on NSA
#    [Tags]    caseB4_1    AP_REG
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG}
#    ...        AND    Suite Setup Update GNB    scf_file=${LOCAL_WTS_DIR}/${5GC002200_scf}    iphy_file=${LOCAL_WTS_DIR}/${iphy}
#    ...    swconfig_param=${SWCONFIG_PARAM_N1N2_4X1}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Start UTE WTS And Check Cell Setup    ${wts_cfg}
#    ...        AND    Common Test Setup
#    Set CSI Override Varying Testmode with 4X1
#    Associate UEs to the created profiles with beaforming    UE_ID=11    profile_id=1
#    Attach and Traffic on NSA    UE_ID=11    profile_id=1
#    Check D_B4_001 Traffic and detach on NSA    UE_ID=11
#
#*** Keywords ***
#Common Suite Setup
#    Modify UTE SCTP Timeout
#    Modify AP SCTP Timeout
#    Configure UTE ETH3 with MIMO
#
#Cell1 UE SIB Decoding Should Be Successful
#    ta5g_egate.Wait For Egate Console Output    expected_message=${CELL1_SIB}    timeout=300s
#    Log    sib_decoding_is_ok
#
#Set CSI Override Testmode without bbeaforming
#    ${cmd}=    Catenate    csi_override_testmode_nr profile_id\=1 cqi_mode\=fixed cqi\=15 ri_mode\=fixed cqi_min\=0
#    ...    cqi_max\=15 ri\=3 pmi_mode\=fixed pmi\=1
#    ute_wtssim.Execute Egate Command
#    ...    cmd=${cmd}
#
#Associate UEs to the created profiles without beaforming
#    ${cmd}=    Catenate    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=${profile_id} scell\=0
#    ute_wtssim.Execute Egate Command
#    ...    cmd=${cmd}
#
#Set CSI Override Testmode with beaforming for subpanel 2x2
#    [Arguments]    ${profile_id}=3
#    ${cmd}=    Catenate    beam_control_testmode_nr profile_id\=${profile_id} ueBeamIndexInitial\=1\,2\,3\,4\,5\,0
#    ...    ssbeam_bestbeam\=1 ssbeam_rsrp_best\=-44 ssbeam_rsrp_avg\=-50
#    ${cmd1}=    Catenate    csi_override_testmode_nr profile_id\=${profile_id} cqi_mode\=fixed cqi\=15 ri_mode\=fixed cqi_min\=0 cqi_max\=15 ri\=3
#    ...    pmi_mode\=fixed pmi\=852 cri_mode\=fixed cri\=2 li_mode\=fixed li\=0
#    ute_wtssim.Execute Egate Command
#    ...    cmd=${cmd}
#    ute_wtssim.Execute Egate Command
#    ...    cmd=${cmd1}
#
#Set CSI Override Testmode with beaforming for subpanel 4x1
#    ${cmd}=    Catenate    beam_control_testmode_nr profile_id\=1 ueBeamIndexInitial\=1\,2\,3\,4\,5\,6\,7\,0
#    ...    ssbeam_bestbeam\=1 ssbeam_rsrp_best\=-44 ssbeam_rsrp_avg\=-50
#    ${cmd1}=    Catenate    csi_override_testmode_nr profile_id\=1 cqi_mode\=fixed cqi\=15 ri_mode\=fixed cqi_min\=0 cqi_max\=15 ri\=3
#    ...    pmi_mode\=fixed pmi\=260 cri_mode\=fixed cri\=3 li_mode\=fixed li\=0
#    ute_wtssim.Execute Egate Command
#    ...    cmd=${cmd}
#    ute_wtssim.Execute Egate Command
#    ...    cmd=${cmd1}
#
#Associate UEs to the created profiles with beaforming
#    [Arguments]    ${UE_ID}    ${profile_id}=3
#    ${cmd}=    Catenate    ue_testmode_set_nr id=${UE_ID} testmode\=beam_control action\=activate
#    ...    profile_id\=${profile_id} beamaction\=attach
#    ${cmd1}=    Catenate    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate
#    ...    profile_id\=${profile_id} scell\=8
#    ute_wtssim.Execute Egate Command
#    ...    cmd=${cmd}
#    ute_wtssim.Execute Egate Command
#    ...    cmd=${cmd1}
#
#Set CSI Override Varying Testmode with 4X1
#    ${cmd}=    Catenate    beam_control_testmode_nr profile_id\=1 ueBeamIndexInitial\=1\,2\,3\,4\,5\,6\,7\,0
#    ...    ssbeam_bestbeam\=1 ssbeam_rsrp_best\=-44 ssbeam_rsrp_avg\=-50
#    ${cmd1}=    Catenate    csi_override_testmode_nr profile_id\=1 cqi_mode\=fixed cqi\=15 cqi_min\=0 cqi_max\=15 ri_mode\=varying
#    ...    ri\=0\,3 ri_period\=10 pmi_mode\=fixed pmi\=852 cri_mode\=fixed cri\=2 li_mode\=fixed li\=0
#    ute_wtssim.Execute Egate Command
#    ...    cmd=${cmd}
#    ute_wtssim.Execute Egate Command
#    ...    cmd=${cmd1}
#
#Set CSI Override Varying Testmode Rank 1-2-3-4
#    ute_wtssim.Execute Egate Command    cmd=csi_override_testmode_nr profile_id\=1 cri\=0\,1\,2\,3 cri_mode\=varying cri_period\=1
#
#Set CSI Override Varying Testmode Rank 1-2-3-4 with 2X2
#    ${cmd}=    Catenate    beam_control_testmode_nr profile_id\=1 ueBeamIndexInitial\=1\,2\,3\,4\,5\,0
#    ...    ssbeam_bestbeam\=1 ssbeam_rsrp_best\=-44 ssbeam_rsrp_avg\=-50
#    ${cmd1}=    Catenate    csi_override_testmode_nr profile_id\=1 cqi_mode\=fixed cqi\=15 cqi_min\=0 cqi_max\=15 ri_mode\=varying
#    ...    ri\=0\,1\,2\,3 pmi_mode\=fixed pmi\=852 cri_mode\=fixed cri\=2 li_mode\=fixed li\=0
#    ute_wtssim.Execute Egate Command
#    ...    cmd=${cmd}
#    ute_wtssim.Execute Egate Command
#    ...    cmd=${cmd1}
#
#Attach and Traffic on SA with multi trf
#    [Arguments]    ${UE_ID}    ${dl_tp_set}=175    ${ul_tp_set}=175
#    SA 5G Attach    ue_id=${UE_ID}
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=${UE_ID}
#    SA 5G PDU Session Setup with Multi UE    ue_id=${UE_ID}
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=${UE_ID}    mbps=${dl_tp_set}    trf_id=${UE_ID}
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=${UE_ID}    mbps=${dl_tp_set}    trf_id=${${UE_ID}+1}
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=${UE_ID}    mbps=${dl_tp_set}    trf_id=${${UE_ID}+2}
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=${UE_ID}    mbps=${dl_tp_set}    trf_id=${${UE_ID}+3}
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=${UE_ID}    mbps=${dl_tp_set}    trf_id=${${UE_ID}+4}
#    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=${UE_ID}    mbps=${ul_tp_set}    trf_id=${UE_ID}
##    Wait Until Keyword Succeeds    3min    5s    SA UE Check Throughput    ${UE_ID}    ${dl_tp_threshold}    ${ul_tp_threshold}
##    SA Stop Data Traffic Internal    ${UE_ID}    pdu_id=1
##    [Teardown]    SA 5G Detach    ue_id=${UE_ID}
#
#Attach and Traffic on SA with Multi UE
#    [Arguments]    ${UE_ID}    ${dl_tp_set}=175    ${ul_tp_set}=175
#    SA 5G Attach    ue_id=${UE_ID}
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=${UE_ID}
#    SA 5G PDU Session Setup with Multi UE    ue_id=${UE_ID}
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=${UE_ID}    mbps=${dl_tp_set}    trf_id=${UE_ID}
#    Sleep    1s
#    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=${UE_ID}    mbps=${ul_tp_set}    trf_id=${UE_ID}
#    Sleep    1s
#
#Attach and Traffic on NSA
#    [Arguments]    ${UE_ID}    ${profile_id}=3
#    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
#    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
#    NSA Verify If Attach Passed
#    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    175    1
#    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    175    2
#    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    175    3
#    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    175    4
#    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    175    5
#    NSA Start UL Traffic    ${UE_ID}    ${BEARER_ID}    175    1
#
#Check D_B4_001 Traffic and detach on NSA
#    [Arguments]    ${UE_ID}
#    NSA Check Average Traffic bigger than target    ${UE_ID}    ${BEARER_ID}    dl    400
#    NSA Check Average Traffic bigger than target    ${UE_ID}    ${BEARER_ID}    ul    80
#    NSA LTE Detach    ${UE_ID}
#
#Check SA UE Throughput
#    [Arguments]    ${UE_ID}=11    ${dl_tp_threshold}=150    ${ul_tp_threshold}=80    ${qfi}=1
#    ${dl_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=${UE_ID}    dir=dl    qfi=${qfi}
#    ${ul_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=${UE_ID}    dir=ul    qfi=${qfi}
#    log    DL Troughput is ${dl_tp}    console=True
#    log    UL Troughput is ${ul_tp}    console=True
#    ${tp_delta}    Evaluate    ${dl_tp}-${dl_tp_threshold}
#    Should Be True    ${tp_delta}>=0    Throughtput is not in the accetable range
#    Log To Console    The TPUT is bigger than target: ${dl_tp_threshold}M \n
#    ${tp_delta}    Evaluate    ${ul_tp}-${ul_tp_threshold}
#    Should Be True    ${tp_delta}>=0    Throughtput is not in the accetable range
#    Log To Console    The TPUT is bigger than target: ${ul_tp_threshold}M \n
#    [Return]    ${dl_tp}    ${ul_tp}
#
#Configure UTE ETH3 with MIMO
#    Log To Console    configure VM interfaces...
#    OperatingSystem.Run    sudo ip addr add 10.0.1.131/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.132/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.133/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.134/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.135/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.136/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.99/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.2.99/24 dev eth4
#    OperatingSystem.Run    sudo ip addr add 10.0.1.121/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.121/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.137/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.124/32 dev eth3    #gnb3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.125/32 dev eth1    #gnb4
#    OperatingSystem.Run    sudo ip addr add 10.0.1.122/32 dev eth3    #gnb3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.123/32 dev eth1    #gnb4
#    OperatingSystem.Run    sudo ip addr add 10.0.1.138/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.139/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.2.2/24 dev eth3
#
#Start UTE WTS And Check Cell Setup
#    [Documentation]    This keyword is to kill Running WTS Binaries,start edaemon, egate and clean log files.
#    [Arguments]    ${local_wts_cfg}    ${enb_id}=1    ${target_id}=2
#    Log To Console    \nStarting WTS...
#    Run Keyword And Ignore Error    Stop Edaemon Egate
#    ute_wtssim.Setup Edaemon    edaemon_port=22222    tool_dir=${WTS_DIR}    alias=edaemon
#    ute_wtssim.Start Edaemon Process    alias=edaemon
#    ute_wtssim.Setup Egate    egate_port=20000    tool_dir=${WTS_DIR}    save_egate=${True}
#    ute_wtssim.Start Egate Process
#    OperatingSystem.Run    sudo rm -rf ${WTS_DIR}/*.log*
#    ute_wtssim.Execute Egate Command    cfg file\=${WTS_DIR}/${local_wts_cfg}
#    ...    pass_regexp=SystemInformationBlockType4-NR updated    timeout=5min
#    Check All Cells Received SIB2
#    Verify Cell Setup
#    Sleep    60s
#    ute_wtssim.Execute Egate Command    enb_x2_link_up enb\=${enb_id} target\=${target_id}
#    ...    pass_regexp=ENB.*: X2AP Link with GNB.* is up    timeout=5min
#
#SA 5G PDU Session Setup with Multi UE
#    [Arguments]    ${ue_id}
#    [Documentation]    This keyword is used to simulate PDU session setup on 5GNR side.
#    ...    Expected output is: " Initial Context Setup Successful " on eGate.
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...    | ue_id | Yes | ue id |
#    ...    Example:
#    ...    | SA 5G PDU Session Setup | 1 |
#    Log To Console    start 5G PDU Session Setup...
#    ${command}    Set Variable    ue_pdu_session_setup pdu=${ue_id} ue=${ue_id} nwslice=1 gw=${ue_id}
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
#    ...    ${command}    pass_regexp=Initial Context Setup Successful    timeout=3minutes
#    ${output}    String.Get Lines Matching Regexp    ${output}    Initial Context Setup Successful    partial_match=${true}
#    Log To Console    ${output}
#
