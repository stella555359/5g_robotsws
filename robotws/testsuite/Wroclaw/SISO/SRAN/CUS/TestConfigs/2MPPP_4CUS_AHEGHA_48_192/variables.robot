*** Settings ***
Documentation    responsible tester: katarzyna.zacharuk@nokia.com

#Variables       config
Library         OperatingSystem
Library         BuiltIn

*** Variables ***

${UE_COUNT}=        1
${UE_IoT_COUNT}=    1
${UE_CATM_COUNT}=   1


######################---------TIMEOUTS ---------######################

${EGATE_CONFIG_TIMEOUT}=                        999
${EGATE_START_TIMEOUT}=                         999
${UPLANE_DEPLOYMENT_TIMEOUT}=                   999
${FR_DETECTION_TIMEOUT_AFTER_BTS_RESET}=        999
${INFOMODEL_CONN_TIMEOUT}=                      999
${EGATE_TO_ONAIR_TIMEOUT}=                      999
${TO_CONFIGURED_TIMEOUT}=                       999
${BUSY_BTS_TIMEOUT}=                            999
${BB_CALC_STATE_TIMEOUT}=                       999
${COMMISSIONING_TIMEOUT}=                       999

######################---------LOG AND CONFIG PATH ---------######################

${ROBOT_DIR}=                                   /home/ute/MN/UTE/robotws
${CONFIG_DIR}=                                  ${ROBOT_DIR}/testsuite/Wroclaw/SISO/SRAN/CUS/resources/config
${SUITE_LOGS_DIR_PATH}=                         ${OUTPUT DIR}
${GENERATED_PATH}=		                        ${EMPTY}
${BACKUP_PATH}=			                        ${EMPTY}
${REMAINING_PATH}=	                            ${EMPTY}
${TEMP_PATH}=	                                ${EMPTY}
${remaining_logs}=                              ${OUTPUT DIR}/remaining_logs
${general_files}=                               ${OUTPUT DIR}/general_logs
${backup_files}=                                ${OUTPUT DIR}/backup_files
${temp_files}=                                  ${OUTPUT DIR}/temp_files

######################---------THROUGHPUT VARIABLES---------######################

#BANDWIDTH     (MHz)        1.4     3       5       10      15      20      0.2     catm
@{BPS_THROUGHPUT}=         Mbps     Mbps    Mbps    Mbps    Mbps    Mbps    kbps    kbps
@{UL_SINGLE_THROUGHPUT}=    2       6       10      25      30      50      5       40
@{DL_SINGLE_THROUGHPUT}=    3       10      17      35      53      75      5       40
@{UL_MIMO_THROUGHPUT}=      2       6       10      25      30      50      5       40
@{DL_MIMO_THROUGHPUT}=      6       18      32      70      90      100     5       40

${DL_HO_TPUT_RATE}=                             17        #value is common for all BW
${UL_HO_TPUT_RATE}=                             10        #value is common for all BW

${THROUGHPUT_MEASUREMENT_TIME}=                 60
${ACCEPTABLE_PACKET_LOSS}=                      30

######################---------ALLOWED ALARMS---------######################

@{ALLOWED_ALARMS}=   BTS reference clock missing
...	                 BTS time not corrected
...                  ToP master service
...                  Synchronisation lost
...                  Synchronization lost
...                  BTS booted at
...                  GTP-U Path Failure
...                  Transport layer connection failure in S1 interface
...                  SSH enabled
...                  Service Port Enabled
...                  R&D Service Port enabled
...                  LMP access via port 443
...                  BTS Reset Cause
...                  Service account root access is enabled
...                  Ethernet port security is disabled
...                  Sanity Check Error
...                  Diagnostic Check Error
...                  S1 interface setup failure

@{ALLOWED_ALARMS_BLOCK_UNBLOCK}=
...                  Cell blocked
...                  SSH enabled
...                  R&D Service Port enabled
...                  LMP access via port 443
...                  BTS Reset Cause
...                  Service account root access is enabled
...                  Ethernet port security is disabled
...                  Sanity Check Error
...                  Diagnostic Check Error

@{ALLOWED_ALARMS_ONAIR}=
...                  BTS booted at
...                  SSH enabled
...                  R&D Service Port enabled
...                  LMP access via port 443
...                  BTS Reset Cause
...                  Service account root access is enabled
...                  Ethernet port security is disabled
...                  Sanity Check Error
...                  Diagnostic Check Error

######################---------TEST MODELS CHECKED DURING TEST---------######################

@{TEST_MODELS_LIST} =      E-TM1.1     E-TM1.2     E-TM2     E-TM2a
...                         E-TM3.1     E-TM3.1a    E-TM3.2   E-TM3.3
@{TEST_MODELS_INFO_MODEL_LIST} =    E_TM1_1     E_TM1_2     E_TM2     E_TM2a
...                         E_TM3_1     E_TM3_1a    E_TM3_2   E_TM3_3

######################---------COMMANDS USED IN EGATE DURING TEST---------######################

${cmd1}=              set_log log_to_file=on
${cmd2}=              debug_log uec=1 level=2
#${cmd3}=              trace protocol=all mme=1 sgw=1 uec=1 pgw=1 on
${cmd3}               trace protocol=rrc uec=1 on
${cmd4}=              proxy_log CA=debug GEN=debug SCH=debug TA=debug ULER=debug NB=debug
${cmd5}=              set_log flush
${cmd6}=              trace protocol=all off

######################---------EGATE PARAMETERS---------######################
${EGATE_PORT}=                                  20000
@{EDAEMON_PORTS}=                               10000    30000
