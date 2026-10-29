*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    PY39
...           CONFIGURED    CRT    RAN_5G_TDD    RAN_5G    SBTS00
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: George Medesan
...              :contact: george.medesan@nokia.com


Resource          ../CB012277_keywords_and_variables.robot


Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs/
...            AND             Get Scfc File    output_filepath=/home/ute/initial_commissioning.xml
...            AND             Run    ${VM_ETH_IFACES}
...            AND             Find Scfc And Send Delta Commissioning    scfc_filename=Delta_Configuration_scf_CB012277_A_B1.json
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/wts.cfg   check_edaemon_port=True
...            AND             X2 Link for simulated gNB
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs/


Test Setup       Start Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
Test Teardown    Stop Default Processes And Gather Logs And Compress Logs

Suite Teardown    Send Full Commissioning    input_filepath=/home/ute/initial_commissioning.xml


*** Variables ***

${filter}      x2ap.SgNBChangeRequired_element && nr-rrc.cgi_Info_element && nr-rrc.PLMN_Identity_element &&
        ...    nr-rrc.cellIdentity && nr-rrc.cellReservedForOperatorUse

*** Test Cases ***
TC01_CB012277_A_B1_Intra_Frequency_inter_en_gNB_PSCell_change_with_CGI_provisioning_without_ANR_for_NSA_Opt_3x_Robustness
    [Documentation]
    ...    This user scenario describes the cgi-Info provisioning in the successful Intra-Frequency inter en-gNB PSCell change
    ...    preparation and execution of a NSA call from a source en-gNB to a target en-gNB

    Perform NSA call for UEs ID31-33
    Perform Data Traffic for 10 Minutes
    Perform A3 event HO for UEs ID31-33
    Verify Tcpdump Log       packet_filter=${filter}       number_of_messages= 3    relation_symbol= >=
    Perform Detach for UEs ID31-33
