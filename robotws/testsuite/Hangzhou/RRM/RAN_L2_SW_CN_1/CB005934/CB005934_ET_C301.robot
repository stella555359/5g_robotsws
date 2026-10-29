*** Settings ***
Documentation    ...
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Suite Setup       #Common Suite Setup
##Test Setup       Common Test Setup
#Test Teardown     Common Test Teardown
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD    CRT    RAN_5G_TDD    RAN_5G
#...               SBTS00    CN1_SG06_SM1    CB009169    owner_qiaren
#
#*** Variables ***
#${SCF_PATH}              ${CURDIR}/Config/
#${SCFC_FILE}             CB005934_ET_C301_scfc.xml
#${LOCAL_WTS_DIR}         ${CURDIR}/Config/wts
#${WTS_DIR}               /opt/iphy/latest
#${IPHY_6F}               ${CURDIR}/Config/wts/iphy_6F_803.xml
#${SWCONFIG_PARAM_GNB}    0x89003B=1
##${SWCONFIG_PARAM_AP}    0x70690=1;
#${WTS_CFG}               5934_A803.cfg
#${WTS_AP_XML}            airphone.xml
#${UE_ID}                 2
#${4CC_4F_SCELL}          ('1', '50', '71'), ('2', '51', '25'), ('3', '61', '41')
#&{GNB_ASIK}              ip=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
#@{4CC_DL_TPUT_LIST}      38    180    180    280
#@{2CC_UL_TPUT_LIST}      75    50
#
#*** Test Cases ***
#CB005934_ET_C_IWK301_FDD_DL_4CC_OneShot_Scell_Addition
#    [Setup]    Run Keywords    Suite Setup Update GNB    scf_file=${SCFC_FILE}    iphy_file=${IPHY_6F}    swconfig_param=${SWCONFIG_PARAM_GNB}
#    #...    swconfig_param_AP=${SWCONFIG_PARAM_AP}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    SA 5G CA Attach    ue_id=${UE_ID}    pdu_id=1
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=900
#	  Trigger A1 Scell Addition    ue_id=${UE_ID}    phycell_id=50    srsrp_nr=120    meas_id=1
#    Wait Until Keyword Succeeds    1min    5s    Verify Scells Are Activation    cell_nums=4
#    Wait Until Keyword Succeeds    1min    5s    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_ID}    ${4CC_DL_TPUT_LIST}    4
#    #Capture Logs And Check TTitrace    log_id=1
#
#*** Keywords ***
#Capture Logs And Check TTitrace
#    [Arguments]    ${log_id}
#    Capture BIP Log By Admin Method    capture_time=3s    log_subdir=BIP/${log_id}
#    CUDU L2 Capture And Decode TTitrace    log_id=${log_id}    duration=3
#    CUDU L2 Check DTXNACK Rate    log_id=${log_id}
#    CUDU L2 Check UL DTXCRC Rate    log_id=${log_id}
#
