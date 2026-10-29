*** Settings ***
Force Tags    CLOUD_5G_I_BOO_AP_LOO
...           CONFIGURED    CRT    RAN_5G    SBTS00
...           NoResUsage

Resource     CB008246_Variables_and_Keywords.robot


Suite Setup    Run Keywords     Get VM Password
...            AND              Setup Custom IPHY   iphy=${custom-iphy_Q1}
...            AND              Update Requested RnD flags in SW config file
...            AND              log to console    Vm Ethernet Interfaces
...            AND              Start Vm Ethernet Interfaces
...            AND              Setup Custom SCF    scf=${custom-scf8246_Q1}
...            AND              Reach Onair Without Confirmation    lua_cfg=${CURDIR}/config/wts_Q1.lua
...            AND              Start Xn And Ng Interfaces For Second Gnb
...            AND              Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Test Setup     Start Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown   Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown    Run Keywords      log to console    Wait until AirPhone is ready to gather logs
...               AND               Sleep    20s
...               AND               Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***

*** Test Cases ***
2_CB008246_Q1_Link_adaptation_for_High_reliability_DRB_feature_interworking_with_NR_DC_A4_configured
    [Documentation]    Validates the Link adaptation for High reliability DRB interworking with NR-DC (CB008717:
    ...     Intra-gNB FR1-FR2 NR DC with split bearers). High reliability DRB shall be considered as non-splittable DRB
    ...     for NR-DC and PDU session, which contains HR DRB, shall not be selected as set of NR-DC split bearers.
    ...     NonGBR bearers included in another PDU session, which does not include high reliability bearer,
    ...     can be configured as NR-DC split bearers.


    log to console    Attach UE and verify tcpdump A4
    Attach UE and verify tcpdump    ue=1    packet_filter=${A4}    cell_id=1    number_of_messages=0
    log to console    verify tcpdump 64qamLowSe
    Verify tcpdump    ue=1    packet_filter=${64qamLowSe}    cell_id=1    number_of_messages=3
    log to console    Find Scfc and Send Delta Commissioning scfc_filename=Delta_8246_Q1_2.json
    Find Scfc and Send Delta Commissioning    scfc_filename=Delta_8246_Q1_2.json
    log to console    Attach UE and verify tcpdump A4
    Attach UE and verify tcpdump    ue=1    packet_filter=${A4}    cell_id=1    number_of_messages=2
    log to console    verify tcpdump 64qamLowSe
    Verify tcpdump    ue=1    packet_filter=${64qamLowSe}    cell_id=1    number_of_messages=3


