*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC
...           CONFIGURED    RAN_5G_TDD    RAN_5G    SBTS00    SBTS23R1    PY311
...           NoResUsage

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
    ...         AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_2396_activation.json
    ...         AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_nia_nea_null.json
    ...         AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown   Run Keywords    Find Scfc And Send Delta Commissioning    scfc_filename=delta_nia_nea_revert.json
    ...         AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_2396_deactivation.json
    ...         AND             Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
5GC002396_D_B2_10_Intra_Gnb_Du_Handover_For_Ue_With_Full_Power_Capability_Mode0
    [Tags]    CRT    SBTS23R2
    [Documentation]    Test case verifies gNB behaviour when full power TX mode0 is supported for R16 UE
    ...    for power class 3 when flag actFullPwrMode is activated in commissioning file after inter gNB HO procedure.
    ...	   A3 measurement is performed after PDU session setup together with Traffic and whole procedure is repeated to ensure
    ...    feature is working after successful HO.
    ...    Checks are based mostly on RRC interface where IE ul_FullPowerTransmission_r16 is expected to be present in
    ...    RRC Reconfiguration message three times (after first PDU session setup, during HO and after second PDU session setup).
    ...    Rest of the checkpoints are targeted on UE capabilities (such as codebook/pc/band/mimo layers/srs ports) in
    ...	   F1AP:RRC Reconfigurtaion and NGAP:UERadioCapablityInfoIndicaton messages.
    ...    Expected value of Power Mode IE is 0 and Power Class equals 3 in this testcase
    ...    5G_RAN_USR_RRM_6856, 5G_FIM_435

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
        ...    AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_a3_activation.json
        ...    AND             Setup Custom UE Radio Capabilities    ue_id=1    ue_nr_capabilities=${CAPABILITIES_MODE_0_POWER_CLASS_3}

    Attach Ue    ue_id=1
    Establish PDU Session    ue_id=1    pdu_id=1    gw_id=1
    Start Traffic And Check If Average Throughput Is Reached
    ...    pdu_gw_id=1
    ...    throughput=2m
    ...    duration=20
    ...    direction=ul
    Send UE Measurement NR Event A3 With Aligned Meas ID    ue_id=1    cell_id=2     phycell_id=51     nrsrp_nr=40     srsrp_nr=30
    ...                              pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
    ...                              timeout=7
    Establish PDU Session    ue_id=1    pdu_id=2    gw_id=2
    Start Traffic And Check If Average Throughput Is Reached
    ...    pdu_gw_id=2
    ...    throughput=2m
    ...    duration=20
    ...    direction=ul

    Verify Tcpdump Log    packet_filter=${FULL_POWER_MODE_0}    number_of_messages=3    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${NONCOHERENT_CODEBOOK}    number_of_messages=3    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${NUMBER_OF_SRS_PORTS}    number_of_messages=3    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${MAX_MIMO_LAYERS}    number_of_messages=3    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${PHYS_CELL_ID_AFTER_MEAS}    number_of_messages=1    relation_symbol= >=
    Verify Ngap Messages  packet_filter=${UE_POWER_CLASS_PC3}    number_of_messages=1    relation_symbol= >=

    [Teardown]    Run Keywords    Deregister Ue Without Confirmation    ue_id=1
        ...       AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_a3_revert.json
        ...       AND             Add Scout External Execution ID To Reporting Portal
        ...       AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

5GC002396_D_B1_5_Reestablishment_For_Ue_With_Full_Power_Capability_Mode2
    [Tags]    CRT    SBTS23R2
    [Documentation]    Test case verifies gNB behaviour when full power TX mode2 is supported for R16 UE
    ...    for power class 2 when flags actFullPwrMode and rrcReestabTypeSA are activated in commissioning file.
    ...	   After PDU session setup, UE RRC Reestablishment to cell2 is triggered to check if the feature will work
    ...    properly also after the reestablishment.
    ...    Checks are based mostly on RRC interface where IE ul_FullPowerTransmission_r16:fullpowerMode2
    ...    is expected to be present in RRC Reconfiguration message.
    ...    Rest of the checkpoints are targeted on UE capabilities (such as codebook/pc/band/mimo layers/srs ports) in
    ...	   F1AP:RRC Reconfigurtaion and NGAP:UERadioCapablityInfoIndicaton messages.
    ...    Expected value of Power Mode IE is 1 and Power Class equals 1.5 in this testcase
    ...    5G_RAN_USR_RRM_6855, 5G_FIM_635, 5G_RAN_USR_RRM_4271, 5G_RAN_USR_RRM_6852

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
        ...    AND             Perform Parameter Commissioning    parameter=rrcReestabTypeSA  value=sameGNB
        ...    AND             Setup Custom UE Radio Capabilities    ue_id=4    ue_nr_capabilities=${CAPABILITIES_MODE_1_POWER_CLASS_1_5}

    Attach Ue    ue_id=4
    Establish PDU Session    ue_id=4    pdu_id=4    gw_id=4
    Initiate Ue RRc Reestablishment    ue_id=4    gnb=2    cell=2    cause=otherFailure
    Start Traffic And Check If Average Throughput Is Reached
    ...    pdu_gw_id=4
    ...    throughput=2m
    ...    duration=20
    ...    direction=ul

    Verify Tcpdump Log    packet_filter=${FULL_POWER_MODE_1}    number_of_messages=2    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${NONCOHERENT_CODEBOOK}    number_of_messages=2    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${NUMBER_OF_SRS_PORTS}    number_of_messages=2    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${MAX_MIMO_LAYERS}    number_of_messages=2    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${UE_BAND_78}    number_of_messages=1    relation_symbol= >=
    Verify Ngap Messages  packet_filter=${UE_POWER_CLASS_PC1_5}    number_of_messages=1    relation_symbol= >=

    [Teardown]    Run Keywords    Deregister Ue Without Confirmation    ue_id=4
        ...       AND             Perform Parameter Commissioning    parameter=rrcReestabTypeSA  value=deactivated
        ...       AND             Add Scout External Execution ID To Reporting Portal
        ...       AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

5GC002396_D_B3_19_Interworking_With_Ul_Close_Loop_Power_Control_Mode2
    [Tags]    CRT    SBTS23R2
    [Documentation]    Test case verifies gNB behaviour when full power TX mode2 is supported for R16 UE
    ...    for power class 2 when flags actFullPwrMode and actUlCloseLoopPwrCtrl are activated in commissioning file.
    ...	   After PDU session setup, the checks are based mostly on RRC interface where IE ul_FullPowerTransmission_r16:fullpowerMode2
    ...    is expected to be present in RRC Reconfiguration message.
    ...    Rest of the checkpoints are targeted on UE capabilities (such as codebook/pc/band/mimo layers/srs ports) in
    ...	   F1AP:RRC Reconfigurtaion and NGAP:UERadioCapablityInfoIndicaton messages.
    ...    Expected value of Power Mode IE is 0 and Power Class equals 2 in this testcase
    ...    5G_RAN_USR_RRM_6857, 5G_FIM_602, 5G_RAN_USR_RRM_4271, 5G_RAN_USR_RRM_6853

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
        ...    AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_884_activation.json
        ...    AND             Setup Custom UE Radio Capabilities    ue_id=2    ue_nr_capabilities=${CAPABILITIES_MODE_0_POWER_CLASS_2}

    Register Ue And Start Traffic And Deregister UE    ue_id=2    pdu_gw_id=2

    Verify Tcpdump Log    packet_filter=${FULL_POWER_MODE_0}    number_of_messages=1    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${NONCOHERENT_CODEBOOK}    number_of_messages=1    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${NUMBER_OF_SRS_PORTS}    number_of_messages=1    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${MAX_MIMO_LAYERS}    number_of_messages=1    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${UE_BAND_78}    number_of_messages=1    relation_symbol= >=
    Verify Ngap Messages  packet_filter=${UE_POWER_CLASS_PC2}    number_of_messages=1    relation_symbol= >=

    [Teardown]    Run Keywords    Deregister Ue Without Confirmation    ue_id=2
        ...       AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_884_deactivation.json
        ...       AND             Add Scout External Execution ID To Reporting Portal
        ...       AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

5GC002396_D_B4_22_Interworking_With_FR1_DFTs_OFDM_For_TDD_PUSCH_Mode2
    [Tags]    CRT    SBTS23R2
    [Documentation]    Test case verifies gNB behaviour when full power TX mode2 is supported for R16 UE
    ...    for power class 2 when flags actFullPwrMode and actUlDftSOfdmare are activated in commissioning file.
    ...	   After PDU session setup, the checks are based mostly on RRC interface where IE ul_FullPowerTransmission_r16:fullpowerMode2
    ...    is expected to be present in RRC Reconfiguration message.
    ...    Rest of the checkpoints are targeted on UE capabilities (such as codebook/pc/band/mimo layers/srs ports) in
    ...	   F1AP:RRC Reconfigurtaion and NGAP:UERadioCapablityInfoIndicaton messages.
    ...    Expected value of Power Mode IE is 2 and Power Class equals 2 in this testcase
    ...    5G_RAN_USR_RRM_14389, 5G_FIM_650

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
        ...    AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_545_activation.json
        ...    AND             Setup Custom UE Radio Capabilities    ue_id=3    ue_nr_capabilities=${CAPABILITIES_MODE_2_POWER_CLASS_2}

    Wait for all cells to be not locked    timeout=10
    Register Ue And Start Traffic And Deregister UE    ue_id=3    pdu_gw_id=3

    Verify Tcpdump Log    packet_filter=${FULL_POWER_MODE_2}    number_of_messages=1    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${NONCOHERENT_CODEBOOK}    number_of_messages=1    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${NUMBER_OF_SRS_PORTS}    number_of_messages=1    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${MAX_MIMO_LAYERS}    number_of_messages=1    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${UE_BAND_78}    number_of_messages=1    relation_symbol= >=
    Verify Ngap Messages  packet_filter=${UE_POWER_CLASS_PC2}    number_of_messages=1    relation_symbol= >=

    [Teardown]    Run Keywords    Deregister Ue Without Confirmation    ue_id=3
        ...       AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_545_deactivation.json
        ...       AND             Add Scout External Execution ID To Reporting Portal
        ...       AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

5GC002396_D_B5_23_Interworking_With_Coverage_Based_Handling_Of_NonCoherent_MIMO_Ues_Mode2
    [Tags]    CRT    SBTS23R2
    [Documentation]    Test case verifies gNB behaviour when full power TX mode2 is supported for R16 UE
    ...    for power class 2 when flags actFullPwrMode and actCoverageNonCoherentUes are activated in commissioning file.
    ...	   After PDU session setup, the checks are based mostly on RRC interface where IE ul_FullPowerTransmission_r16:fullpowerMode2
    ...    is expected to be present in RRC Reconfiguration message.
    ...    Rest of the checkpoints are targeted on UE capabilities (such as codebook/pc/band/mimo layers/srs ports) in
    ...	   F1AP:RRC Reconfigurtaion and NGAP:UERadioCapablityInfoIndicaton messages.
    ...    Expected value of Power Mode IE is 1 and Power Class equals 2 in this testcase
    ...    5G_RAN_USR_RRM_14480, 5G_FIM_603, 5G_RAN_USR_RRM_4271, 5G_RAN_USR_RRM_6852

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
        ...    AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_CB006086_activation.json
        ...    AND             Setup Custom UE Radio Capabilities    ue_id=5    ue_nr_capabilities=${CAPABILITIES_MODE_1_POWER_CLASS_2}

    Register Ue And Start Traffic And Deregister UE    ue_id=5    pdu_gw_id=5

    Verify Tcpdump Log    packet_filter=${FULL_POWER_MODE_1}    number_of_messages=1    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${NONCOHERENT_CODEBOOK}    number_of_messages=1    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${NUMBER_OF_SRS_PORTS}    number_of_messages=1    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${MAX_MIMO_LAYERS}    number_of_messages=1    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${UE_BAND_78}    number_of_messages=1    relation_symbol= >=
    Verify Ngap Messages  packet_filter=${UE_POWER_CLASS_PC2}    number_of_messages=1    relation_symbol= >=

    [Teardown]    Run Keywords    Deregister Ue Without Confirmation    ue_id=5
        ...       AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_CB006086_deactivation.json
        ...       AND             Add Scout External Execution ID To Reporting Portal
        ...       AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
