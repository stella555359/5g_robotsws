*** Settings ***
Force Tags    CLOUD_5G_I_LOO_AP_LOOO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65    CONFIGURED
...           SBTS00    RAN_5G    CRT    PY311
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Kornel Dluzniewsi
...              :contact: kornel.dluzniewski@nokia.com,

Resource    CB010741_Keywords_And_Variables.robot

Suite Setup        Run Keywords
...                                Update And Put Iphy Xml         input_filepath=${IPHY}
...                AND             Find Scfc And Fix And Send Full Commissioning
...                                scfc_filename=${SCFC}
...                AND             Reach Onair    lua_cfg=${cfg}

Suite Teardown   Run Keyword       Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${SCFC}=                           scfc.xml
${cfg}=                            ${CURDIR}/config/basic_setup.cfg
${iphy}=                           ${CURDIR}/config/iphy_CB010471.xml


*** Test Cases ***
CB010741_B_B6A1_UL_Buffer_Monitoring_Activation_Upon_CaBackoffTimerUeOh_Expiry_When_A1_SCell_Addition_In_Use
    [Setup]    Start Default Logging    output_dirpath=${OUTPUT_DIR}/

    ta5g_ue_mobility.Attach UE    ue_id=1
    Set Internal Traffic Type For UE    ue=1    pdu=1
    Establish PDU Session    ue_id=1    pdu_id=1    gw_id=1
    Start Data Traffic    ues=1    direction=dl    pdu=1    throughput=10Mbps    traffic_id=1
    Execute egate command  cmd=ue_measurement_send_nr id=1 meas_id=2 event=A1 srsrp_nr=95
    sleep   10s
    Start Data Traffic    ues=1    direction=ul    pdu=1    throughput=150Mbps    traffic_id=1
    Start Data Traffic    ues=1    direction=ul    pdu=1    throughput=150Mbps    traffic_id=2
    Start Data Traffic    ues=1    direction=ul    pdu=1    throughput=150Mbps    traffic_id=3
    Send ue assistance for Overheatin
    Stop Data Traffic    ues=1
    Sleep  200s
    Execute egate command  cmd=ue_measurement_send_nr id=1 meas_id=4 event=A1 srsrp_nr=95
    sleep   10s
    Start Data Traffic    ues=1    direction=ul    pdu=1    throughput=150Mbps    traffic_id=1
    Start Data Traffic    ues=1    direction=ul    pdu=1    throughput=150Mbps    traffic_id=2
    Start Data Traffic    ues=1    direction=ul    pdu=1    throughput=150Mbps    traffic_id=3
    Verify Messages


    [Teardown]    Run Keywords    Deregister Ue Without Confirmation   ue_id=1
        ...       AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Keywords ***
Send ue assistance for Overheatin
    Execute egate command   cmd=ue_assistance_send_nr ue_id=1 forOverheating=yes reducedCCsUL=0

