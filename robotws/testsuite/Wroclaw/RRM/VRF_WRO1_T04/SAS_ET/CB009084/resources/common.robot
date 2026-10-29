*** Settings ***
Documentation
...   author: Kamil Bucki, Adrianna Pienkowska
...   contact: kamil.bucki@nokia.com, adrianna.pienkowska@nokia.com
...   description: Krakow Verification Engineering team common keywords for CB008132 feature

Library    ute_wtssim
Library    ute_fsmaccess
Library    ute_tshark
Library    ta5g_iphy
Library    ta5g_enb
Library    ta5g_egate
Library    ta5g_syslog
Library    taf.ul.ue.sim.env_setup                                                           WITH NAME    env__
Library    suite_kw.py                                                                       WITH NAME    suite__
Library    attach.py                                                                         WITH NAME    attach__
Library    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/common_gnb.py                  WITH NAME    gnb__
Library    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/counters.py                    WITH NAME    counters__
Library    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/common_wts.py                  WITH NAME    wts__
Library    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/bip_management.py              WITH NAME    bip__

Variables    variables.py

*** Keywords ***

Custom Config Setup H GBR
    env__.add_simulator
    ...  sim_type=Airphone
    ...  config=${IPHY_PATH_H_GBR}
    env__.configure_environment

Custom Config Setup
    [Arguments]   ${scf}    ${iphy}
    env__.add_gnb_configuration
    ...  scfc=${scf}
    env__.add_simulator
    ...  sim_type=Airphone
    ...  config=${iphy}
    env__.configure_environment

Custom Config Setup DSS
    Log    Custom Config Setup DSS
    Custom Config Setup
    ...    scf=${SCF_PATH_DSS}
    ...    iphy=${IPHY_PATH_DSS}

Custom Config Setup PRB DSS
    Log    Custom Config Setup PRB DSS
    Custom Config Setup
    ...    scf=${SCF_PATH_PRB_DSS}
    ...    iphy=${IPHY_PATH_PRB_DSS}

Prepare Environment For Tests without rebooting
    [Arguments]         ${tc}
    wts__.Ensure Wts Is Not Running
#    gnb__.Ensure Short Pmstats Flag Existence In Swconfig
    gnb__.Ensure Cplane Flags Existence In Swconfig
    gnb__.Ensure Cp Runtime Ini Has LoggingSeverity Set On Trace
    suite__.Create Output Dir Tc            tc=${tc}
    suite__.remove_admin_logs_if_exists


Teardown Wts And Collect Logs Without GNB Commissioning
    Run Keyword And Ignore Error            BIP Stop
    Run Keyword And Ignore Error            SHERPA Stop
    Run Keyword And Ignore Error            SYSLOG Stop
    Run Keyword And Ignore Error            attach__.stop_iperf
    # suite__.Get AP Snapshot                             output_dir=${OUTPUT_DIR_TC}
    suite__.Get GNB Snapshot                            output_dir=${OUTPUT_DIR_TC}
    Run Keyword And Ignore Error                        wts__.Stop Wts And Clear
    suite__.Save Swconfigs To Files                     output_dir=${OUTPUT_DIR_TC}
    suite__.save_admin_logs_after_tc                    output_dir=${OUTPUT_DIR_TC}
    # suite__.Try To Send Result To Rep Portal            output_dir=${OUTPUT_DIR_TC}

Teardown Wts And Collect Logs
    Teardown Wts And Collect Logs Without GNB Commissioning
    gnb__.Perform GNB Commissioning                     scf_file=${BASIC_SCF_FILE}

Teardown Wts And Collect Logs PRB DSS
    Teardown Wts And Collect Logs Without GNB Commissioning
    gnb__.Perform GNB Commissioning                     scf_file=${BASIC_SCF_FILE_PRB_DSS}

Prepare Environment For DSS Test
    suite__.Set Variables Based On Tc
    Prepare Environment For Tests without rebooting                 tc=EB101_DSS
    gnb__.Reset Units And Wait For Radio Head Online                retry_interval=60
    recom__.Perform Delta Recomissioning                            output_dir=${OUTPUT_DIR}
    ...                                                             delta=${DELTA_DSS}
    gnb__.Reset Units And Wait For Radio Head Online                retry_interval=60


Prepare Environment For PRB And DSS Test
    suite__.Set Variables Based On Tc
    Prepare Environment For Tests without rebooting          tc=EB101_DSS_PRB
    Prepare Environment For PRB                                     vendor_file_path=${VENDOR_PRB_DSS}
    ...                                                             delta=${DELTA_PRB_DSS}

Prepare Environment For PRB
    [Arguments]         ${vendor_file_path}
    ...                 ${delta}
    Run Keyword And Ignore Error            recom__.Perform Delta Recomissioning                            output_dir=${OUTPUT_DIR_TC}
    ...                                                                                                     delta=${delta}
    gnb__.collect_scf_file                                          set_variable=${SET_VARIABLE_DURING_SCF_COLLECTION}
    suite__.rewrite_vendor_file                                     vendor_file_path=${vendor_file_path}
    gnb__.send_vendor_file_and_perform_gnb_commissioning            scf_file=${COLLECTED_SCF_FILE}
    ...                                                             vendor_file=${vendor_file_path}
    gnb__.Reset Units And Wait For Radio Head Online                retry_interval=60


Setup DSS Partnership
    [Arguments]         ${wts_cfg}
    wts__.start_wts                                                 wts_config_filename=${wts_cfg}
    ...                                                             wts_dir_path=${IPHY_DIR_PATH_DEFAULT}
    ...                                                             edaemon_port=${EDAEMON_PORT}
    ...                                                             egate_port=${EGATE_PORT}
    suite__.wait_for_starting_wts_procedure                         seconds=200
    attach__.create_partnership_between_eNB_and_gNB_for_all_cells   egate_log=${EGATE_CONSOLE_LOG}
    attach__.create_partnership_for_many_cells                      egate_log=${EGATE_CONSOLE_LOG}
    ...                                                             cell_lte_list=${SA_3UE_IDS}
    ...                                                             cell_5g_list=${SA_3UE_IDS}
    ...                                                             port=4
    attach__.wait_for_sib_for_all_cells                             sib_reception_list=${SIB_RECEPTION_LIST}
    ...                                                             egate_log=${EGATE_CONSOLE_LOG}


Setup For One Cell DSS Partnership
    [Arguments]         ${wts_cfg}
    wts__.start_wts                                                 wts_config_filename=${wts_cfg}
    ...                                                             wts_dir_path=${IPHY_DIR_PATH_DEFAULT}
    ...                                                             edaemon_port=${EDAEMON_PORT}
    ...                                                             egate_port=${EGATE_PORT}
    attach__.create_partnership_between_eNB_and_gNB_for_all_cells   egate_log=${EGATE_CONSOLE_LOG}
    attach__.create_partnership_for_one_cell                        egate_log=${EGATE_CONSOLE_LOG}
    ...                                                             cell_lte=1
    ...                                                             cell_5g=3
    ...                                                             port=2
    wts__.wait_for_information_block_reception                      sib_reception_dict=${SIB_RECEPTION_DICT_SA_SANSA_3CELL}


SYSLOG Start
    Log    SYSLOG Start
    suite__.Start Syslog Capture          output_dir=${OUTPUT_DIR_TC}

SYSLOG Stop
    Log     SYSLOG Stop
    suite__.Stop Syslog Capture

SHERPA Start
    Log     SHERPA Start
    suite__.Start Sherpa Capture        output_dir=${OUTPUT_DIR_TC}

SHERPA Stop
    Log    SHERPA Stop
    suite__.Stop Sherpa Capture         output_dir_csv=${OUTPUT_DIR_TC}

BIP Start
    Log    BIP Start
    bip__.Start Biplog Collection From Webem

BIP Stop
    Log     BIP Stop
    bip__.Stop And Download Biplog From Webem            output_pcap_path=${OUTPUT_DIR_TC}

LOG SYSLOG BIP SHERPA Start
    SYSLOG Start
    SHERPA Start
    BIP Start

LOG SYSLOG BIP SHERPA Stop
    BIP Stop
    SHERPA Stop
    SYSLOG Stop

LOG SYSLOG BIP Start
    SYSLOG Start
    BIP Start

LOG SYSLOG BIP Stop
    BIP Stop
    SYSLOG Stop

Start Log Collection
    Run Keyword And Ignore Error        SYSLOG Start
    Run Keyword And Ignore Error        SHERPA Start
    Run Keyword And Ignore Error        BIP Start

Perform Delta Recomissioning And Validate Errors
    [Arguments]     ${delta}
    ...             ${error_msg}
    ...             ${output_dir}
    Run Keyword And Ignore Error           recom__.Perform Delta Recomissioning      output_dir=${output_dir}
    ...                                    delta=${delta}
    Sleep     5
    recom__.validate_admin_error           error_msg=${error_msg}

Perform Delta Recomissioning And Validate Errors In Admin Logs
    [Arguments]     ${delta}
    ...             ${error_msg}
    ...             ${output_dir}
    suite__.remove_admin_logs_if_exists
    Run Keyword And Ignore Error           recom__.Perform Delta Recomissioning      output_dir=${output_dir}
    ...                                    delta=${delta}
    Sleep     30
    recom__.validate_admin_error_in_logs          error_msg=${error_msg}
    suite__.save_admin_logs_after_tc       output_dir=${output_dir}
