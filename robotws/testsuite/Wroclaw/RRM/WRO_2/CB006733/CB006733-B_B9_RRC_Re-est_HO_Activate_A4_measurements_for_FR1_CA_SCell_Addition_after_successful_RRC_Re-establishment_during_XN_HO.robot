*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation    :copyright: Nokia
...              :authors: Kamil Dabkowski
...              :contact: kamil.dabkowski@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     ../5GC000705/5GC000705_keywords.robot
Resource     taf/ul/ettf/main.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/traffic.robot
Resource     ../keywords/L3_Call.robot
Resource     ./verify_ta_messaging/verify_UEContextModification.robot
Resource     ta_messaging/flow.robot
Resource     Keywords_CB006733.robot
Library      ta5g_tshark
Library      ta_messaging
Library      taf.ul.ettf.retry_context
Library      taf.ul.ettf.setups
Library      ta5g_testline_management
Library      ta5g_ue_mobility
Library      ta5g_iphy
Library      ta5g_egate
Library      taf.ul.ettf.setups
Library      ta5g_pm_counters
Variables    CB006733_messaging_filters.py
Variables    logging_policy.py
Variables    ta5g_global_var
Library      ./verify_ta_messaging/CB006733.py

Suite Setup    Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_xml_6733.xml
...            AND             With Gnb Configuration    commissioning=${SCFC}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             Check Radios Availability
...            AND             With Simulated Network Interface    name=eth3:GNB3_NG_ADDR    ip=10.0.1.3/24
...            AND             With Simulated Network Interface    name=eth3:GNB3_XN_ADDR    ip=10.0.1.4/24
...            AND             With Simulated Network Interface    name=eth3:AMF_NG    ip=10.0.1.1/24
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/wts_6733_BB9.cfg
...            AND             Wait For Next Full Pm Interval

*** Variables ***
${SCFC}=                        scf_CB006733_BB9.xml
${COUNTER_M55118C00030}=        M55118C00030
${COUNTER_A4_MEASUR_ACT_SCELL_ADD_SA}=           A4_MEASUR_ACT_SCELL_ADD_SA
${LOCAL_MOID}=                  PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4
${UE_ID}=                       4
${TARGET_GNB_ID}=               2
${SOURCE_GNB_ID}=               3
${SOURCE_CELL_ID}=              8
${SOURCE_PHYSICAL_CELL_ID}=     58
${TARGET_CELL_ID}=              4
${TARGET_PHYSICAL_CELL_ID}=     54
${MEASUREMENT_ID}=              7
${PDU_ID}=                      3
${MEASUREMENT_NRSRP}=           100
${MEASUREMENT_SRSRP}=           19
${PCELL_ID}=                    1
${A4_RETRY_TIMER}=              5
${NWSLICE_ID}=                  1
${GW_ID}=                       3
${UE_NR_RRC_RECONF_PARAM} =    SEPARATOR=
...                            id=${ue_id} if_contains=any action=reestablish gnb=${target_gnb_id} cell=${target_cell_id}${SPACE}
...                            crnti=source nth=1 cause=handoverFailure num_reestablishment_reqs=1


*** Test Cases ***
CB006733-B_B9_RRC_Re-est_HO_Activate_A4_measurements_for_FR1_CA_SCell_Addition_after_successful_RRC_Re-establishment_during_XN_HO
    Set Traffic Type To UE      gnb_id=${SOURCE_GNB_ID}    pdu_id=${PDU_ID}    ue_id=${UE_ID}
    Change UE location and set integrity protection    ${SOURCE_GNB_ID}    ${UE_ID}    ${PCELL_ID}
    Create AMF device with alias 'AMF1' identified by ip=10.0.1.1
    Register UE To source gNB    ue_id=${UE_ID}    target_gnb_id=${TARGET_GNB_ID}    pdu_id=${PDU_ID}    gw_id=${GW_ID}    nwslice_id=${NWSLICE_ID}
    Prepare and trigger XN handover with reestablishment request
    ...    ${ue_id}    ${pdu_id}    ${SOURCE_GNB_ID}    ${target_gnb_id}    ${target_cell_id}
    ...    ${MEASUREMENT_ID}    ${MEASUREMENT_SRSRP}    ${TARGET_PHYSICAL_CELL_ID}    ${MEASUREMENT_NRSRP}
    ...    ${SOURCE_PHYSICAL_CELL_ID}    ${PCELL_ID}    ${UE_NR_RRC_RECONF_PARAM}

    Verify that UEContextModificationRequest_1 of 6 contains measConfig with A2,3,5 events during XN HO for gNB2
    Verify that UEContextModificationRequest_4 of 6 contains measConfig with A2,3,4,5 events after XN HO for gNB2
    Verify that UEContextModificationResponse_4 of 6 contains measGapConfig for gNB2
    Verify if UE4 RRCReconfiguration 2 of 2 contains A4 configuration after Inter-gNB with reestablishment HO via Xn

    Verify if UE4 RRCReconfiguration 1 of 2 contains A2,3,5 without A4 events during reestablishment HO via Xn
    Verify RRC Reestablishment Request Message Content
    ...    ue_id=${ue_id}    source_phy_cell_id=${SOURCE_PHYSICAL_CELL_ID}    reest_cause="handoverFailure"

    Verify Pm Counters 6733    ue_id=${UE_ID}    counter_id=${COUNTER_M55118C00030}
    ...   counter_name=${COUNTER_A4_MEASUR_ACT_SCELL_ADD_SA}    local_moid=${LOCAL_MOID}
    [Teardown]    Release UE    ue_id=${UE_ID}    pdu_id=${PDU_ID}
