*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    SBTS22R4    SBTS23R1
    ...    CLOUD_5G_I_BOO_AP_LOO

Documentation    :copyright: Nokia
Resource    testsuite/Wroclaw/RRM/resources/airphone/scout_reporting/reporting_portal.robot
Resource    ../5GC001167/feature_keywords.robot
Library     ta5g_pm_counters

Suite Setup     Run Keywords    Prepare Test Environement And Reach Onair
    ...                             iphy_xml=${CURDIR}/config/iphy_4FDD_10MHz_2TDD_n41_n77_60MHz.xml
    ...                             scfc=scfc_4FDD_10MHz_2TDD_n41_n77_60MHz.xml
    ...                             egate_cfg=${CURDIR}/config/egate_3ue_rac.cfg
    ...                             cell_number=1
    ...          AND            Find Scfc and Send Delta Commissioning    scfc_filename=delta_b3.1.json

Test Setup        Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}
    ...                 AND       Attach Ues To Reach SCell Limit
Test Teardown     Add Scout External Execution ID To Reporting Portal

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${PM_COUNTERS_INTERVAL}=     0x340000=5 # flag to speed up PM counters to 3 minutes
@{SWCONFIG_FLAGS_LIST}=      ${PM_COUNTERS_INTERVAL}    ${rdMergedMeasGapSetupAndDrxRelease}
${UE1_SCELLS}=    nr-rrc.sCellToAddModList == 2 && nr-rrc.physCellId == 51 && nr-rrc.physCellId == 55
${UE2_SCELLS}=    nr-rrc.sCellToAddModList == 2 && nr-rrc.physCellId == 52 && nr-rrc.physCellId == 55

*** Test Cases ***
5GC002640_B_3.1a_Radio_Admission_Control_in_gNB_CU
    Attach UE With PDU Session Setup          ue_id=3    pdu_id=3        gw_id=3
    Wait For Next Full Pm Interval
    Verify PM Counters After Lack Of Resources In Scell Addition

*** Keywords ***
Attach Ues To Reach SCell Limit
    Wait For Next Full Pm Interval
    Attach UE With PDU Session Setup          ue_id=1    pdu_id=1        gw_id=1
    Attach UE With PDU Session Setup          ue_id=2    pdu_id=2        gw_id=2
    Verify Successful 3CC SCell Addition For Ues

Attach UE With PDU Session Setup
    [Arguments]     ${ue_id}    ${pdu_id}    ${gw_id}
    Attach Ue                           ue_id=${ue_id}
    Establish Pdu Session               ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}    nwslice=1

Verify Successful 3CC SCell Addition For Ues
    Verify Tcpdump Log      packet_filter=${UE1_SCELLS}    number_of_messages=2
    Verify Tcpdump Log      packet_filter=${UE2_SCELLS}    number_of_messages=2

Verify PM Counters After Lack Of Resources In Scell Addition
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
        ...    M55138C02501    3    GNB_SCELL_2_ADMI_REQ_SA
        ...    M55138C02502    2    GNB_SCELL_2_ADMI_SUCC_SA
        ...    M55138C01503    1    GNB_SCELL_ADMI_UNSUCC_SA
        ...    M55118C07004    2    RRC_RECONF_ADD2DLSCELL_ATT_SA
        ...    M55118C07003    2    RRC_RECONF_ADD2DLSCELL_SUCC_SA
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${pm_counter_file}

Wait For Airphone To Stabilize
    Sleep    240s
