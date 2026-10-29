*** Settings ***
Documentation    :copyright       : Nokia
                 ...              :author       : Vadivelan Manickavasagam
                 ...              :contact      : vadivlean.manickavasagam@nokia.com
                 ...              :Description  : This file contains
                 ...                              Variables related to CB008235 only
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,11.01.2025,vadivelan.manickavasagam@nokia.com


*** Variables ***
${CFG_GNB_SCF_DELTA_JSON}          AWHNB_2radio.xml
${CFG_AP_IPHY}                     ${CURDIR}/../../config/ap/iphy_2radio.xml
${CFG_WTS_CFG}                     ${CURDIR}/../../config/wts/basic_L3_AWHNB_2radio.cfg
${CFG_CB01485_WTS_CFG_1485_TC02}             ${CURDIR}/../../config/wts/basic_L3_AWHNB_4DL4UL.cfg
${CFG_AP_IPHY_4DL4UL}              ${CURDIR}/../../config/ap/iphy_4DL4UL.xml
${CFG_GNB_SCF_DELTA_JSON_4DL4UL}         AWHNB_4DL4UL.xml
${Log_Path}                        /home/ute/logs
${CM_UE1_DTYPE_INTERNAL}           set_pdu_param ue=1 pdu=1 trf_type=internal
${CM_UE_1_REGISTER}                ue_register id=1
${CM_UE_1_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1
${CM_UE_1_UL_DATA}                 trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=150 trf_id=1
${CM_UE_1_DEREG}                   ue_deregister id=1 ue_deregister_type=switch_off
