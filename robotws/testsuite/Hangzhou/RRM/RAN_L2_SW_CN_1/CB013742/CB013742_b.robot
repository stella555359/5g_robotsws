*** Settings ***
Documentation    ...
Suite Teardown    Common Suite Teardown 2
Test Teardown     Common Test Teardown 2
Force Tags        CLOUD_5G_I_BOO_AP_LOO
...               SBTS00    SBTS25R3    Pz4_13    CB0  RAN_5G    RAN_5G_TDD    #CRT
Resource          ./../CUDU_L2/common_setup_teardown.robot
Resource          ./../CB008927/Resources/CB008927_resource.robot
Resource          ./../CB008236/Resources/CB008236_resource.robot
Resource          ./../CUDU_L2/common_setup_teardown.robot
Resource          ./../CUDU_L2/common_log_capture.robot
Resource          ./../5GC001808/AirPhone_common_resource_UTE_CR.robot
Resource          ./../5GC001817/keywords_1817_common_AP.robot
Library           ./../CB008236/Resources/CB008236_resource.py

*** Variables ***
${SCF_PATH}             ${CURDIR}/Config
${CB013742_SCF}          SCF_CB013742.xml
${CB013742_IPHY}         ${WTS_LOCAL}/CB013742_iphy.xml
${CB013742_WTS_CFG}      basic_setup_CB013742.cfg
${WTS_LOCAL}            ${CURDIR}/Config
${RD}                0x58057a=4;0x580580=0x800000
${ttiPath0}          ttitrace0

*** Test Cases ***
CB013742-B#IWK4_1_Multi_BWP_Star_PRB_randomization_when_UE_enter_transient_phase
   [Setup]    Prepare TL w gNB_xml '${CB013742_SCF}' AP_xml '${CB013742_IPHY}' AP_cfg'${CB013742_WTS_CFG}'
    Set egate rrc log 'on'
    UE '1'-'13' Attach to Cell '1' and setup PDU Session '1' with slice '1'
    Start dl Trafficon on UE '1'-'13' PDU ID '1' TRF ID '1' QFI ID '1' with '5'mbps
    Start ul Trafficon on UE '1'-'5' PDU ID '1' TRF ID '1' QFI ID '1' with '1'mbps
    UE '14'-'15' Attach to Cell '1' and setup PDU Session with tti '1' with slice '1'
    Get Egate log and check enter PowerSaving BWP
    Start ul Trafficon on UE '14'-'15' PDU ID '1' TRF ID '1' QFI ID '1' with '100'mbps
    Start dl Trafficon on UE '14'-'15' PDU ID '1' TRF ID '1' QFI ID '1' with '100'mbps
    Get Egate log and check exit PowerSaving BWP

*** Keywords ***

Get Egate log and check enter PowerSaving BWP
    Log To Console    start to check 'PowerSaving BWP' in egate log
    ${PowerSaving_BWP}=    Set Variable    Bwp switch received from bwpId 1 to 2
    ute_wtssim.Execute Egate Command    sim_log_set flush
    Save Egate Log    /opt/iphy/latest/
    ${egate_console_file}=    Set Variable    /opt/iphy/latest/egate_console.log
    Check Egate Log With Message     ${egate_console_file}    ${PowerSaving_BWP}    1

Get Egate log and check exit PowerSaving BWP
    Log To Console    start to check 'PowerSaving BWP' in egate log
    ${PowerSaving_BWP}=    Set Variable    Bwp switch received from bwpId 2 to 1
    ute_wtssim.Execute Egate Command    sim_log_set flush
    Save Egate Log    /opt/iphy/latest/
    ${egate_console_file}=    Set Variable    /opt/iphy/latest/egate_console.log
    Check Egate Log With Message     ${egate_console_file}    ${PowerSaving_BWP}    1

UE '${sid}'-'${eid}' Attach to Cell '${cell_id}' and setup PDU Session with tti '${pdu_id}' with slice '${slice}'
    ${eid}          Evaluate          ${eid}+1
    FOR    ${ue_id}    IN RANGE          ${sid}          ${eid}
        ute_wtssim.Execute Egate Command    cmd=ue_change_location id\=${ue_id} cell\=${cell_id}
        SA 5G Attach    ${ue_id}
        Start capture Ttitrace
        SA Set Traffic Type To Internal    ${ue_id}    ${pdu_id}
        Trigger 5QI'6' Setup on UE '${ue_id}' on pdu '${pdu_id}'w nwslice '${slice}'
        sleep  5s
        Stop capture Ttitrace and convert to Excelcsv to log dir '${ttiPath0}'
        run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}${/}Config${/}ini${/}tti_ul_dci_format.ini   i
     ...   save_log_directory=${TEST_LOG_DIRECTORY}/${ttiPath0}
    END