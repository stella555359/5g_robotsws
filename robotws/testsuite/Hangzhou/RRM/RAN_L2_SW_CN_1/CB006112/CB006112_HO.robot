*** Settings ***
Documentation    ...
#Resource    ./CB006112_resource.robot
#Resource    ./../CUDU_L2/common_setup_teardown.robot
#Library           ./../CUDU_L2/scripts/python/ttitrace_data_parser.py
#Library           ./../CUDU_L2/scripts/python/get_csv_data.py
#Library           ./../CUDU_L2/scripts/python/streaming_ttitrace_analyzer.py
#Suite Setup       Run Keywords    Prepare QT LOLO Enviroment    TYPE=TDD
#...               AND    Common Suite Setup    ${6112_scf_tdd_ho}
#Suite Teardown    Common Suite Teardown 2
#Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    SBTS00    SBTS23R1    SBTS22R4
#...                RAN_5G    RAN_5G_TDD    CRT
#*** Variables ***
#${DELTA_FILE_A_PA2_10}         none
#${SWCONFIG_PARAM_A_PA2_10}        0x5800F3=1;0x590072=1;0x41001b=1;0x5801d0=0;
#${WTS_CFG_HO}     wts_cfg_ASIL_ABIO_TDD_HO.cfg
#
#${DELTA_FILE_C18}         Delta_Conf_TDD_CB006112_C18.json
#${SWCONFIG_PARAM_C18}        0x5800F3=1;0x590072=1;0x41001b=1;0x5801d0=0;
#
#${SCF_DIR}    ${CURDIR}/config/
#${6112_scf_tdd_ho}    ${SCF_DIR}/SCF_VONR_TDD_HO.xml
#${UE1_ID}             1
#${UE2_ID}             2
#${UE3_ID}             3
#${PROFILE_ID}         1
#${GNB_ID}             2
#${CELL_ID}            2
#${BEARER_ID}          2
#@{LOG_NAME_LIST}      btslog    snapshot
#&{GNB_ASIK}           ip=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
#${UE1_CAPABILITY}     SEPARATOR=${EMPTY}    E1A01000074E5A031E000380A03C1260C8000878180C4034026010180E01951B0A358202868
#...                   0965944C043D6C10101070EF1C39061C00103278FAB80027800E0009E00151B133582028680965944C043D6C10101070E
#...                   F1C39061C00103278FAB80027800E0009E00151B137582028680965944C043D6C10101070EF1C39061C00103278FAB800
#...                   27800E0009E00151B13B582028680965944C043D6C10101070EF1C39061C00103278FAA8000028000000841C4D0000000
#...                   0202682807008089FEAAAAA058060005038180703005807000683E0000000000000E54D000100000965950034AAA8081C
#...                   002C00000010020046AC4C0004080C1014181C202C4044484C648494989CA12986B40
#
#
#${Egatelog_path}    ${CURDIR}
#*** Test Cases ***
#CB006112-ET-A-PA2-10 Verify handover from PA disable cell to PA enable cell
#    [Tags]     Owner_yalsun    case_A_PA2_10
#    [Setup]    Setup TL For Each Case    ${DELTA_FILE_A_PA2_10}    ${SWCONFIG_PARAM_A_PA2_10}    ${WTS_CFG_HO}    ${WTS_XML}
#    Set UE Parameter For Handover
#    UE1 GBR Call Setup
#    Intra-frequency Handover To Sim GNB For UE1
#    SA Non GBR Call For UEs   ${UE2_ID}
#    SA Non GBR Call For UEs    ${UE3_ID}
#    SA Start UDP DL Traffic For Multi UE    ${UE2_ID}    7072    1400    1900M
#    SA Start UDP UL Traffic For Multi UE    ${UE2_ID}    7073    1400    500M
#    SA Start UDP DL Traffic For Multi UE    ${UE3_ID}    7074    1400    1900M
#    SA Start UDP UL Traffic For Multi UE    ${UE3_ID}    7075    1400    500M
#    SA Start UDP DL Traffic For Multi UE    ${UE1_ID}    7070    40    16000    360
#    SA Start UDP UL Traffic For Multi UE    ${UE1_ID}    7071    40    16000    360
#    Intra-frequency Handover To Real GNB For UE1
#    Catch TTitrace With Streaming Mode And Convert To CSV
#    Verify DL PA Timer Enable With Streaming Mode
#    #Start TTI Trace Logs For BO SA FDD
#    #Verify DL PA Timer Enable
#    Stop Data Transfer
#    #Release UE
#    [Teardown]    Recover TL    ${6112_scf_tdd_ho}
#
#CB006112-ET-C-18TDD Voice call Handover reject when GBR load trigger from UP to CP
#    [Tags]     Owner_yalsun    case_C18
#    [Setup]    Setup TL For Each Case    ${DELTA_FILE_C18}    ${SWCONFIG_PARAM_C18}    ${WTS_CFG_HO}    ${WTS_XML}
#    Set UE Parameter For Handover
#    UE1 GBR Call Setup
#    Intra-frequency Handover To Sim GNB For UE1
#    SA GBR Call For UEs    ${UE2_ID}
#    Start UL And DL Voice Traffic For UE2
#    SA GBR Call For UEs    ${UE3_ID}
#    #Check UE3 5QI1 Setup Failed Due To Exceed Available Cell Time Domain Capability
#    Intra-frequency Handover To Real GNB For UE1
#    Stop Data Transfer
#    Release UE
#    [Teardown]    Recover TL    ${6112_scf_tdd_ho}
