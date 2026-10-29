*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CONFIGURED    RAN_5G_TDD    RAN_5G    PY36
...           CRT      SBTS00     NoResUsage

Documentation    :copyright: Nokia
...              :authors: Andrei Maria
...              :contact: andrei.maria@nokia.com

Suite Setup       Run Keywords   Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND             Log to console    Start Vm Ethernet Interfaces
...            AND             Run    ${VM_ETH_IFACES}
...            AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_A_B2_TC03.json
...            AND             Check Radios Availability
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_A_B2_TC03.cfg    check_edaemon_port=True
...            AND             Setup X2 Link for gNB4
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Send Full Commissioning    input_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND                Stop Default Processes And Gather Logs And Compress Logs

Resource    ../CB012277_keywords_and_variables.robot

*** Variables ***


*** Test Cases ***
TC03_CB012277_A_B2_Inter_Frequency_inter_en_gNB_PSCell_change_with_CGI_provisioning_without_ANR_for_NSA_Opt_3x
    [Documentation]    This user scenario describes the cgi-Info provisioning in the successful NW based Inter-Frequency inter en-gNB PSCell
    ...    change preparation and execution of a NSA call from a source en-gNB to a target en-gNB without ANR. It shares all info from
    ...    5GC001095-A#B9(5G_RAN_USR_RRM_2997), only newly additional info from this feature will be described in detail.

	[Setup]    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    [Teardown]    Run Keywords    Detach Ue Without Confirmation    ue_id=92    type=switch_off
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

    UE Trigger InterGnb InterFreq Ho    ue_id=92
    Verify Tcpdump Log    packet_filter=${CGI_INFO}    number_of_messages=1     relation_symbol= >=
