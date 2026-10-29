*** Settings ***
Force Tags    CLOUD_5G_I_[MP][MP]_AP_[LOOO]

Documentation   :copyright: Nokia
...             :authors: Kornel Dluzniewski
...             :contact: kornel.dluzniewski@nokia.com
...             :topology: CLOUD_5G_I_[MP][MP]_AP_[LOOO]
...             :variant: custom configs

Resource     CB009103_Keywords_And_Variables.robot
Library      CB009103_Keywords.py

Suite Setup        Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Set
...                AND             Get Iphy Xml File    output_filepath=${OUTPUT_DIR}/iphy.xml
...                AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/SN_initial_commissioning.xml    remote_host=${REMOTE_HOST_1_IP}
...                AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/MN_initial_commissioning.xml
...                AND             Update And Put Iphy Xml         input_filepath=${iphy9103_C_B6}
...                AND             Find Scfc And Fix And Send Full Commissioning
...                                scfc_filename=${SCFC_GNB_SN_C_B6}    remote_host=${REMOTE_HOST_1_IP}
...                AND             Find Scfc And Fix And Send Full Commissioning
...                                scfc_filename=${SCFC_GNB_MN_C_B6}
...                AND             Reach Onair    lua_cfg=${C_B6}    remote_hosts=${REMOTE_HOSTS}
...                AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

*** Variables ***
${EXTERNAL_GNB_DELTA_A_B6}=             Prime_scfc_9103_B6.json
${PRIME_GNB_DELTA_A_B6}=             External_scfc_9103_B6.json

*** Test Cases ***
CB009103_C_B6_A4_Measurement_Configuration_After_Partial_SCell_Release
    [Documentation]
    ...    The test case checks counters for new intra_SCell addition
    ...    For UE which is already configured with two ext_SCells
    ...    miNrCaCu=5min
    ...    miNrNGCC=5min
    ...    miNrCaDuCp=5min
    ...    actBufferBasedSCellAddition=oneShot_stepWise_Dl_Fr1
    ...    sCellActivationMethod=blind
    ...    Req: 5G_PM_2488, 5G_RAN_USR_RRM_28790

    [Setup]    Run Keywords     Start Default Logging And Mark New Test
    Attach Ue    ue_id=1
    Establish PDU Session With Traffic    ue_id=1    pdu_id=1    gw_id=1
    Start Traffic To Trigger SCells Addition
    Wait For Event A4 And Send UE Measurement Nr With Aligned Meas Id    ue_id=1    carrier_freq=368430    phycell_id=51    nrsrp_nr=80
    Wait For Event A4 And Send UE Measurement Nr With Aligned Meas Id    ue_id=1    carrier_freq=651648    phycell_id=53    nrsrp_nr=80
    Wait For Event A4 And Send UE Measurement Nr With Aligned Meas Id    ue_id=1    carrier_freq=126750    phycell_id=55    nrsrp_nr=80
    Verify Tcpdump Log    packet_filter=${F1AP_DL_BUFFER}    number_of_messages=0       relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${F1AP_4CC}       number_of_messages=0       relation_symbol= >=
    Sleep    60s
    Send UE Measurement Nr Event A2 Scell Release With Aligned Meas Id
         ...    ue_id=1    scell_id=4    scell=2    scell_rsrp=1   scell_sinr=1   scell_rsrq=1
         ...    pass_regexp=message c1 : rrcReconfigurationComplete
    Verify Tcpdump Log    packet_filter=${F1AP_3CC}       pcap_file_path=${OUTPUT_DIR}/tshark/gnb_F1_E1_RRC.pcap
    ...    number_of_messages=0    relation_symbol= >=
    Sleep    60s
    Wait For Event A4 And Send UE Measurement Nr With Aligned Meas Id    ue_id=1    carrier_freq=651648    phycell_id=53    nrsrp_nr=80
    Verify Tcpdump Log    packet_filter=${F1AP_4CC}       pcap_file_path=${OUTPUT_DIR}/tshark/gnb_F1_E1_RRC.pcap
    ...    number_of_messages=0    relation_symbol= >=
    [Teardown]    Run Keywords    Deregister Ue Without Confirmation   ue_id=1
        ...       AND             Add Scout Scf Id To Test Data
        ...       AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

