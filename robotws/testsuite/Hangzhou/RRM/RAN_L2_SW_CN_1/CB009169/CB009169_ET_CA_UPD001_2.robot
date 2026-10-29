*** Settings ***
Documentation    ...
#Resource    ./Resources/CB009169_C_resource.robot
#Resource    ./../CUDU_L2/common_setup_teardown.robot
#Resource    ./../CUDU_L2/common_log_capture.robot
#Resource    ./../CB006137/resources/6137_BO_lib.robot
#Resource    ./../CB006137/resources/CB006137_BB_resource.robot
#Resource    ./../CB006137/resources/CB006137_BC_resource.robot
#Test Teardown    Common Test Teardown 2
#Suite Teardown    Common Suite Teardown 2
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    SBTS00    CN1_SG09_SM2
#...                RAN_5G    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD    CRT    AP_REG
#
#*** Variables ***
#${UE_ID}               1
#${PROFILE_ID}          1
#${GNB_ID}              2
#${CELL_ID}             1
#${BEARER_ID}           2
#${Egatelog_path}       ${CURDIR}
#${LOCAL_WTS_DIR}       ${CURDIR}/Config/CB009169_C
#${SCF_DIR}             ${CURDIR}/Config/CB009169_C
#${9169_RD}             0x4B000F=1
#${UPD006_RD}           0x4B000F=1;0x58056B=1;0x580497=1;0x58062d=1;0x580692=1
#${UPD017_RD}           0x4B000F=1;0x5900B9=1
#${IPHY_UPD010}          ${LOCAL_WTS_DIR}/iphy_CA_UPD001_010.xml
#${IPHY_UPD013}         ${LOCAL_WTS_DIR}/iphy_UPD013.xml
#${IPHY}                ${LOCAL_WTS_DIR}/iphy_UPD014.xml
#${IPHY_UPD017}         ${LOCAL_WTS_DIR}/iphy_UPD017.xml
#${9169_UPD006_SCF}     ${SCF_DIR}/SCF_UPD006.xml
#${9169_UPD010_SCF}      ${SCF_DIR}/SCF_C_CA_UPD001_010_SRS.xml
#${9169_UPD011_SCF}     ${SCF_DIR}/SCF_UPD011.xml
#${9169_UPD013_SCF}     ${SCF_DIR}/SCF_UPD013.xml
#${9169_UPD014_SCF}     ${SCF_DIR}/SCF_UPD014.xml
#${9169_UPD017_SCF}     ${SCF_DIR}/SCF_UPD017.xml
#${WTS_CFG_UPD006}      basic_setup_UPD006.cfg
#${WTS_CFG_UPD010}       basic_setup_CA_UPD001_010_SRS.cfg
#${WTS_CFG_UPD011}      basic_setup_UPD011.cfg
#${WTS_CFG_UPD013}      basic_setup_UPD013.cfg
#${WTS_CFG_UPD014}      basic_setup_UPD014.cfg
#${WTS_CFG_UPD017}      basic_setup_UPD017.cfg
#${1T1F_SCELLS}         ('2', '52', '71')
#${1T1F_SCELLS_2}       ('1', '50', '71')
#${1T2F_SCELLS}         ('1', '51', '71'), ('2', '53', '25')
#${2T2F_SCELLS}         ('1', '51', '25'), ('2', '52', '66'), ('3', '61', '41')
#${3T1F_SCELLS}         ('1', '51', '25'), ('2', '60', '77'), ('3', '62', '41')
#${2T2F_SCELLS_011}     ('1', '51', '25'), ('2', '52', '66'), ('3', '61', '41')
#${2T2F_SCELLS_014}     ('1', '50', '71'), ('2', '52', '66'), ('3', '60', '77')
#${1208DL_SLOT}         [0, 1, 2, 3, 5, 6, 7, 8, 10, 11, 12, 13, 15, 16, 17, 18]
#${1070DL_SLOT}         [0, 1, 2, 3, 5, 6, 7, 10, 11, 12, 13, 15, 16, 17]
#${1116_0UL_SLOT}       [4, 5, 14, 15]
#${1208_DL_UNMUTE_SLOT}       [1, 2, 3, 6, 7, 8, 10, 11, 12, 13]
#${1208_UL_UNMUTE_SLOT}       [4, 14]
#${SCRIPT_PATH}        /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_1/CUDU_L2/scripts/
#${lfs}                lfs-nw_switch-mirror-tool.sh
#${BIP_FILTER1}        dldata_pdcchsendreq&&!(3gpp.rnti == 65535)
#${BIP_FILTER2}        3gpp.subcellid
#${BIP_FILTER3}        itf_l2_ps_peerctrl_ScellDrxInactivityTimerStatusInd_t.sCellNrCellIdentity
#${force_reboot}        ${True}
#
#*** Test Cases ***
#CB009169-CA-UPD001-013_UL_CA_T+F_interworking_with_3TDD_+_1FDD_DL_CA_TDD_as_PCell_-_different_TDD_frame_struct
#    [Documentation]
#    ...    Precondition:
#    ...      FR1 TDD PCell and 2 FR1 TDD SCells can have different frame structure (e.g. tdLte with 0ms shift + semi-static4:1 + semi-static7:3)
#    ...      SCellAdditionMethod is set to ‘blind’ for all NRREL objects of all cells
#    ...    Test Steps:
#    ...      Step1: Attach UE to the TDD FR1 cell
#    ...      Step2: Start enough DL/UL traffic
#    ...      Step3: UE detach
#    ...    Check point：
#    ...      1. Attach successfully
#    ...      2. UE is configured with DL 4CCs (3TDD + 1FDD) and UL 2CCs (1TDD + 1FDD) successfully
#    ...      3. UE performs periodic CSI Measurements on PCell and SCells,report CQI measurements via PUCCH on PCell or multiplexed in PUSCH on PCell
#    ...      4. Beamforming is enabled on TDD FR1 cells, send Beam management reports for TDD FR1 cells via PUCCH or multiplexed in PUSCH on PCell
#    ...      5. TDD data schedule is correct according their own frame structure
#    ...      6. UE detached
#    [Tags]    caseCAUPD001-013    Manual_xinwang    TA_xinwang
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_UPD013}
#    ...        AND    Suite Setup Update GNB    force_reboot=${force_reboot}    scf_file=${9169_UPD013_SCF}
#    ...               iphy_file=${IPHY_UPD013}    swconfig_param=${9169_RD}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Suite Setup Start WTS And Check OnAir    log=${False}
#    ...        AND    Common Test Setup 2
#    #Step1
#    SA 5G Attach    ue_id=1
#    SA Set Traffic Type To Internal    ue_id=1    pdu_id=1
#    SA 5G PDU Session Setup    ue_id=1
#    Sleep    2s    reason=Wait for log
#    #Checkpoint1 2
#    Get And Check Scell Infos    ${3T1F_SCELLS}
#    #Step2
#    Start SA UE Big UL Traffic Internal    1    mbps=150
#    Start SA UE Big DL Traffic Internal    1    mbps=1000
#    CUDU_L2 Capture And Decode TTitrace    1    1
#    #Checkpoint3 4
#    Check Pcsi And BeamManagementReport    ${TEST_LOG_DIRECTORY}/ttitrace/1
#    #Checkpoint5
#    Check Slot For TDDFrame    ${TEST_LOG_DIRECTORY}/ttitrace/1/output_dl.csv    dlFdSchedData.numOfPrb    60    ${1208DL_SLOT}
#    Check Slot For TDDFrame    ${TEST_LOG_DIRECTORY}/ttitrace/1/output_dl.csv     dlFdSchedData.numOfPrb    62    ${1070DL_SLOT}
#    Check Slot For TDDFrame    ${TEST_LOG_DIRECTORY}/ttitrace/1/output_ul.csv    ulFdSchedData.numOfPrb    61    ${1116_0UL_SLOT}
#    #Step3
#    SA 5G Detach    ue_id=1
