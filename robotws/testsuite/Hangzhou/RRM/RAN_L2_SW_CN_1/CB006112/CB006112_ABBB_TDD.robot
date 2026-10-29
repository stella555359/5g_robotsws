*** Settings ***
Documentation    ...
#Resource    ./CB006112_resource.robot
#Resource    ./../CUDU_L2/common_setup_teardown.robot
#Library           ./../CUDU_L2/scripts/python/ttitrace_data_parser.py
#Library           ./../CUDU_L2/scripts/python/get_csv_data.py
#Suite Setup        Common Suite Setup 2
#Test Teardown      Common Test Teardown 2
#Suite Teardown     Common Suite Teardown 2
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    SBTS00    SBTS23R1    SBTS22R4
#...                RAN_5G    RAN_5G_TDD    CRT
#*** Variables ***
#${LOCAL_WTS_DIR}          ${CURDIR}/config/WTS_CFG
#${SCF_DIR}                ${CURDIR}/config/
#${6112_scf_ca_fdd_tdd}    ${SCF_DIR}/SCF_VONR_CA_LOO.xml
#${WTS_CFG_CA}             wts_cfg_BOO_AP_LOO_CA.cfg
#${UE1_ID}                 1
#${UE3_ID}                 3
#${PROFILE_ID}             1
#${GNB_ID}                 2
#${CELL_ID}                2
#${BEARER_ID}              2
#${WTS_DIR}                /opt/iphy/latest
#${WTS_AP_XML}             airphone.xml
#
#
#${Egatelog_path}    ${CURDIR}
#*** Test Cases ***
#CB006112-ET-BC-BC01 FDD TDD scell should keep when onduration equal longcylce for voice call
#    [Tags]     case_BC01    Manual_qianwu    TA_qianwu
#    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_CA}
#    ...        AND    Suite Setup Update GNB    scf_file=${6112_scf_ca_fdd_tdd}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_DIR}/Delta_BC01.xml
#    Delta Commission With SCF File    ${json_file}
#    Verify Coam Site Is Ready
#    Suite Setup Start WTS And Check OnAir
#    SA Non GBR Call For Multi UE    ${UE1_ID}
#    Start Gnb Wireshark Log
#    Trigger 5QI 5 Setup    ${UE1_ID}
#    Trigger 5QI 1 Setup    ${UE1_ID}
#    SA Start UDP DL Traffic For Multi UE    ${UE1_ID}    7070    40    16000    600
#    SA Start UDP UL Traffic For Multi UE    ${UE1_ID}    7071    40    16000    600
#    Stop Gnb Wireshark Log
#    ${gnb_wireshark}=    Collect Gnb Wireshark Log
#    Verify Vonr DRX Reject From Pcap    ${gnb_wireshark}
#    Check GBR traffic Interval    ${UE3_ID}
#    Verify Scells Addition    scell_id=52
#    SA Stop Traffic For Multi UE
#
#CB006112-ET-BC-BB01 FDD TDD Initial Context Setup with VONR DRX and Inter band CA enable
#    [Tags]     case_BB01    Manual_yaling    TA_yaling
#    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_CA}
#    ...        AND    Suite Setup Update GNB    scf_file=${6112_scf_ca_fdd_tdd}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_DIR}/Delta_BB01.xml
#    Delta Commission With SCF File    ${json_file}
#    Verify Coam Site Is Ready
#    Suite Setup Start WTS And Check OnAir
#    SA Non GBR Call For Multi UE    ${UE1_ID}
#    Trigger 5QI 5 Setup    ${UE1_ID}
#    Trigger 5QI 1 Setup    ${UE1_ID}
#    SA Start UDP DL Traffic For Multi UE    ${UE1_ID}    7070    40    16000    600
#    SA Start UDP UL Traffic For Multi UE    ${UE1_ID}    7071    40    16000    600
#    Verify Drx Config
#    Check GBR traffic Interval    ${UE3_ID}
#    Verify Scells Addition    scell_id=52
#    SA Stop Traffic For Multi UE
#
