*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC
...           CONFIGURED    RAN_5G_TDD    RAN_5G    SBTS00    SBTS23R1    PY311
...           NoResUsage    RF50

Documentation    :copyright: Nokia
...              :authors: Katarzyna Wisniewska
...              :contact: katarzyna.wisniewska@nokia.com
...              :testsuite description: 5GC002396 is mainly to support 3GPP R16 UE with full power TX mode0
...                         for power class 2 and power class 3 and full power mode1 and full power mode2
...                         for power class 2 to enhance the cell edge performance.

Resource    5GC002396_Keywords_And_Variables.robot

Variables    ./config/Capabilities.py

Suite Setup     Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
    ...         AND             Reach OnAir    lua_cfg=${CURDIR}/config/egate_2c_tdd_2c_fdd_sansa_null.lua
    ...         AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_2396_deactivation_1.json
    ...         AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_nia_nea_null.json
    ...         AND             Perform Parameter Commissioning    parameter=actCoverageNonCoherentUes  value=false
    ...         AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Find Scfc And Send Delta Commissioning    scfc_filename=delta_2396_deactivation_1.json
    ...           AND             Perform Parameter Commissioning    parameter=actCoverageNonCoherentUes  value=true
    ...           AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_nia_nea_revert.json
    ...           AND             Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
5GC002396_A_B2_5_Full_Power_Mode0_For_Power_Class_3_Online_Feature_Activation_With_New_RRC_Connection
    [Tags]    CIT    SBTS23R1    SBTS22R4
    [Documentation]    Test case verifies gNB behaviour when full power TX mode0 is supported for
    ...    R16 UE for power class 3 and if feature online activation and deactivation (with a parameter actFullPwrMode)
    ...    is working properly.
    ...    Checks are performed before actFullPwrMode activation and after to ensure
    ...	   the feature is working properly.
    ...	   Before activation we are expecting no ul_FullPowerTransmission_r16:fullpowerMode0 IE
    ...    in RRC Reconfiguration message and after activation mentioned IE shall be present.
    ...    Checkpoints are targeted on UE capabilities (such as codebook/pc/band/mimo layers/srs ports)
    ...    in F1AP:RRC Reconfigurtaion and NGAP:UERadioCapablityInfoIndicaton messages
    ...    Expected value of Power Mode IE is 0 and Power Class equals 3 in this testcase
    ...    5G_RAN_USR_RRM_4271, 5G_RAN_USR_RRM_6852, 5G_RAN_USR_RRM_6853

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
        ...    AND             Setup Custom UE Radio Capabilities    ue_id=1    ue_nr_capabilities=${CAPABILITIES_MODE_0_POWER_CLASS_3_2}

    Register Ue And Start Traffic And Deregister UE    ue_id=1    pdu_gw_id=1
    Verify Tcpdump Log    packet_filter=${FULL_POWER_TRANSMISSION_OFF}    relation_symbol= >=
    Find Scfc And Send Delta Commissioning    scfc_filename=delta_2396_activation_1.json
    Register Ue And Start Traffic And Deregister UE    ue_id=1    pdu_gw_id=1

    Verify Tcpdump Log    packet_filter=${FULL_POWER_MODE_0}    number_of_messages=1    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${NONCOHERENT_CODEBOOK}    number_of_messages=1    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${NUMBER_OF_SRS_PORTS}    number_of_messages=1    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${MAX_MIMO_LAYERS}    number_of_messages=1    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${UE_BAND_78}    number_of_messages=1    relation_symbol= >=
    Verify Ngap Messages  packet_filter=${UE_POWER_CLASS_PC3}    number_of_messages=1    relation_symbol= >=

    Find Scfc And Send Delta Commissioning    scfc_filename=delta_2396_deactivation_1.json
    Register Ue And Start Traffic And Deregister UE    ue_id=1    pdu_gw_id=1
    Verify Tcpdump Log    packet_filter=${FULL_POWER_TRANSMISSION_OFF}    number_of_messages=2    relation_symbol= >=

    [Teardown]    Run Keywords    Deregister Ue Without Confirmation    ue_id=1
        ...       AND             Add Scout External Execution ID To Reporting Portal
        ...       AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
