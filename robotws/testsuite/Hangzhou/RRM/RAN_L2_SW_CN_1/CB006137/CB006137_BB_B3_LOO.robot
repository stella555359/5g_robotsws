*** Settings ***
Documentation    ...
#Resource           ./CB006137_resource.robot
#Resource           ./resources/CB006137_BB_resource.robot
#Resource           ./../CUDU_L2/common_setup_teardown.robot
#Suite Setup        CB006137_BB_resource.Common Suite Setup 2
#Test Teardown      Run Keywords    Send Swconfig for GNB    ${gnb_swconfig}
#...                AND    Common Test Teardown 2
#Suite Teardown     Common Suite Teardown 2
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT    RAN_5G_TDD    RAN_5G
#...               SBTS00    CN1_SG09_SM1    CB006137
#
#*** Variables ***
#${SCF_PATH}                 ${CURDIR}/config/SCF
#${LOCAL_WTS_DIR}            ${CURDIR}/config/WTS/
#${WTS_DIR}                  /opt/iphy/latest
#${6137_BB016_SCF}           ${SCF_PATH}/CB006137_BB016_LOO.xml
#${6137_BB020_SCF}           ${SCF_PATH}/CB006137_BB020_LOO.xml
#${6137_BB027_SCF}           ${SCF_PATH}/CB006137_BB027_LOO.xml
#${IPHY_7737}                ${CURDIR}/config/WTS/iphy_7737_LOO.xml
#${IPHY_2F_2T_LOO}           ${CURDIR}/config/WTS/iphy_2F_2T_LOO.xml
#${gnb_swconfig}             /home/ute/.ute-ca/executions/1/configs/topology_configs/SANSA_FS_ECPRI_CMWV_FDD+TDD/swconfig_gnb.txt
#${SWCONFIG_PARAM_BB016}     0x58057F=16;0x580497=1;
#${SWCONFIG_PARAM}           0x58057F=16;
#${WTS_CFG_BB016}            CB006137_7737_LOO.cfg
#${WTS_CFG_BB027}            CB006137_BB027.cfg
#${WTS_CFG_BB039}            CB006137_BB039.cfg
#${WTS_AP_XML}               airphone.xml
#${UE_ID}                    3
#&{GNB_ASIK}                 ip=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
#
#
#*** Test Cases ***
#CB006137-ET-BB016_4CC_capable_UE_call_with_pcell_and_scell_intra_core
#    [Tags]     caseBB016    dguan    Owner_dguan
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_BB016}
#    ...        AND    Suite Setup Update GNB    scf_file=${6137_BB016_SCF}    iphy_file=${IPHY_7737}    swconfig_param=${SWCONFIG_PARAM_BB016}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Start UTE WTS And Check Cell Setup    ${wts_cfg}    enb_id=2    target_id=1
#    ...        AND    Common Test Setup 2
#    SA Attach    1
#    Start SA UL Big Traffic Internal    ue_id=1    mbps=200
#    Start SA DL Big Traffic Internal    ue_id=1    mbps=800
#    Check Scell Active Status    cell_nums=4    scell_active_status=activated
#    Capture And Decode TTItrace    log_id=BB016
#    ta_a2a.Check Log With Au2anlysis    ${CURDIR}/A2A/CB006137_7737.ini
#    ...    i    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace/BB016
#    Check UL DTXCRC Rate    ${TEST_LOG_DIRECTORY}/ttitrace/BB016/
#    Check DL DTXNACK Rate    ${TEST_LOG_DIRECTORY}/ttitrace/BB016/
#    SA Stop Data Traffic Internal    ue_id=1    pdu_id=1
#    Sleep    3s    reason=Wait for traffic stable
#    Check Scell Active Status    cell_nums=4    scell_active_status=deactivated
#    Start SA UL Big Traffic Internal    ue_id=1    mbps=200
#    Start SA DL Big Traffic Internal    ue_id=1    mbps=800
#    Sleep    3s    reason=Wait for traffic stable
#    Check Scell Active Status    cell_nums=4    scell_active_status=activated
#
#CB006137-ET-BB020_Overheating_handing_with_CQI_equal_0
#    [Tags]     caseBB020    dguan
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_BB039}
#    ...        AND    Suite Setup Update GNB    scf_file=${6137_BB020_SCF}    iphy_file=${IPHY_2F_2T_LOO}    swconfig_param=${SWCONFIG_PARAM}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Start UTE WTS And Check Cell Setup    ${wts_cfg}
#    ...        AND    Common Test Setup 2
#    SA Attach    1
#    Scell Addition Triggered By A1 Event    ue_id=1    srsrp_nr=120
#    Start SA UL Big Traffic Internal    ue_id=1    mbps=100
#    Start SA DL Big Traffic Internal    ue_id=1    mbps=600
#    Sleep    10s    reason=Wait for traffic stable
#    Check Scell Active Status    cell_nums=4    scell_active_status=activated
#    Check DL TP On Target    1    0    1-3    300
#    Check UL TP On Target    1    0    1-3    70
#    Capture And Decode TTitrace    log_id=BB020_1
#    Check UL DTXCRC Rate    ${TEST_LOG_DIRECTORY}/ttitrace/BB020_1/
#    Check Scell Suspend Resume When CQI overheating for BB020
#    SA 5G Detach    1
#
#CB006137-ET-BB027_Overheating_Assistance_Information_report_asking_to_activate_scell
#    [Tags]     caseBB027    haiyliu    Owner_haiyliu
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_BB027}
#    ...        AND    Suite Setup Update GNB    scf_file=${6137_BB027_SCF}    iphy_file=${IPHY_2F_2T_LOO}    swconfig_param=${SWCONFIG_PARAM}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Start UTE WTS And Check Cell Setup    ${wts_cfg}
#    ...        AND    Common Test Setup 2
#    SA Attach    1
#    Scell Addition Triggered By A1 Event    1    1    120
#    Start SA UL Big Traffic Internal    ue_id=1    mbps=200
#    Start SA DL Big Traffic Internal    ue_id=1    mbps=600
#    Sleep    10s    reason=Wait for logs
#    Check UL TP On Target    1    0    3    60
#    Check DL TP On Target    1    0    1-3    550
#    Capture And Decode TTItrace    log_id=1
#    Check UL DTXCRC Rate    ${TEST_LOG_DIRECTORY}/ttitrace/1
#    Check DL DTXNACK Rate    ${TEST_LOG_DIRECTORY}/ttitrace/1
#    Send Send Assistance Information And Check Scell Active Status    2    1    2    1    1    deactivated
#    Start Small Data And Check Scell Deactive    3    1    200    600
#    Start Big Data And Check Scell Active    4    1    200    600
#    Send Send Assistance Information And Check Scell Active Status    5    1    3    1    1
#    Send Send Assistance Information And Check Scell Active Status    6    1    0    0    3    deactivated
#*** Keywords ***
