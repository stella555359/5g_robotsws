*** Settings ***
Force Tags    CLOUD_5GC_dRNIC_1vDU_P_AP_LO_SWFH    VARIANT_SANSA_FS_ECPRI_CMWV_TDD    CONFIGURED    RAN_5G    PY310    CIT
...           NoResUsage


Documentation    :copyright: Nokia
...              :authors: Piotr Pondel
...              :contact: piotr.pondel@nokia.com

Resource    ../../../resources/airphone/5G_SW_WRO_Keywords.robot
Resource    ./resources/CIT_QT_Cloud_BTS_keywords.robot
Resource    ./resources/CIT_QT_Cloud_BTS_variables.robot
Library    ./resources/CIT_QT_Cloud_BTS.py


Suite Setup    Run Keywords    Enable Cloud
...            AND             Get Scfc File Aic    output_filepath=${OUTPUT_DIR}/initial_commissioning_cu.xml
...            AND             Get Scfc File Du Aic    path=${OUTPUT_DIR}
...            AND             Get Iphy Xml File
...            AND             Start Additional Vm Ethernet Interfaces
...            AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/CIT_QT_Cloud_BTS


Suite Teardown    Run Keywords    Stop Additional Vm Ethernet Interfaces
...               AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/CIT_QT_Cloud_BTS
...               AND             Stop Default Processes And Gather Logs And Compress Logs


*** Test Cases ***
CIT_QT_Cloud_BTS_Deploy_Redundant_CnfLayout
    Deploy Redundant Cnf Layout

CIT_QT_Cloud_BTS_Reach_Onair
    Reach Onair    lua_cfg=${CURDIR}/../../../resources/airphone/egate_2c_tdd_sansa_aic.lua

CIT_QT_Cloud_BTS_UE_Attach_SA
    Attach UE    ue_id=${SA_UE1_CELL1}
    Establish PDU Session    ue_id=${SA_UE1_CELL1}    pdu_id=1    gw_id=${SA_UE1_CELL1}
    Verify Uu Messages    packet_filter=${RRC_SETUP_COMPLETE}

CIT_QT_Cloud_BTS_UE_Attach_NSA
    Attach UE To Enb And Gnb    ue_id=${NSA_UE1_CELL1}
    Verify Ngap Messages    packet_filter=${X2AP_SGNB_ADDITION_REQUEST_ACKNOWLEDGE}

CIT_QT_Cloud_BTS_UE_Detach_SA
    Release PDU Session    ue_id=${SA_UE1_CELL1}    pdu_id=1
    Deregister UE    ue_id=${SA_UE1_CELL1}
    Verify Ngap Messages    packet_filter=${NGAP_PDU_SESSION_RESOURCE_RELEASE_RESPONSE}

CIT_QT_Cloud_BTS_UE_Detach_NSA
    Detach UE    ue_id=${NSA_UE1_CELL1}
    Verify Ngap Messages    packet_filter=${X2AP_SGNB_RELEASE_ACKNOWLEDGE}
