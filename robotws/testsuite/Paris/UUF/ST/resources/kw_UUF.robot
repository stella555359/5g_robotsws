*** Settings ***
Documentation
...  Keyword for UUF4ALL and Customer UUF DevOps

Library     DateTime
Library     OperatingSystem
Library     Process
Library     taf.rfrl.bts.commissioning
Resource    Bi-Directional_Throughput_1-DRB_OTA.robot
Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Library     taf.rfrl.utilities.tl_config

Library     ute_admin
Library     ute_fsmaccess
Library     ute_reporting_portal
Library     ute_syslog

Library     kw_UUF.py


*** Variables ***
@{5G_initOnAirCells}
@{4G_initOnAirCells}

${request_software}
${5G_rollback_software}
${4G_rollback_software}
${5G_initial_software}
${4G_initial_software}
${5G_init_passive_sw}
${4G_init_passive_sw}

${5G_GNB_IP}                  192.168.255.1
${4G_ENB_IP}                  ${None}

${with4G}                     ${False}
${min_time_between_boot}=      600

${capabilities}         REAL_UE
${duration}             300s
${protocol}             udp
${deviation}            10%
${tput_dl}              1630 Mbits/sec
${tput_ul}              245 Mbits/sec
${size_packet_dl}       1400B
${size_packet_ul}       1330B
${parallel_streams_dl}  1
${parallel_streams_ul}  1
${buffer_client_dl}     4M
${buffer_server_dl}     4M
${buffer_client_ul}     2M
${buffer_server_ul}     2M
${interval}             1
${reboot_ue}            True
${timeout_reboot_ue}    100
${FILES_BASE}           http://files.ute.nsn-rdnet.net/builds/enb/base/

@{ALLOWED_FAULTS}=  61649  61652  61524  61510  4459  6455  4657  4655  6554  4654  1300  4681  4687  4389
# Allowed Fault's Definition
#  "61649" - LMP access via port xx
#  "61652" - R&D Service Port enabled
#  "61524" - SSH enabled
#  "61510" - Automatic BTS Operator Certificate retrieval unsuccessful  /ipsec
#  "4459" - User Account has Default Password
#  "6455" - Service account root access is enabled
#  "4657"  - unsupported SFP
#  "4655" - Service account root access is enabled (from 21B)
#  "4654" - Ethernet port security is disabled (from 21B)
#  "4389" -  OTDOA PRS transmission disabled
#  "1300" - open door


*** Keywords ***
Set Current Software Version
    ${5G_curent_sw}=     get_software_version
    log to console with time   5G gNB, Active:${5G_curent_sw['Active']}, Passive: ${5G_curent_sw['Passive']}
    Set Suite Variable     ${5G_SOURCE_SW}    ${5G_curent_sw['Active']}
    Set Suite Variable     ${5G_SOURCE_PASSIVE_SW}     ${5G_curent_sw['Passive']}

Software Upgrade
    Set Suite Variable           ${LOG_DIR}    ${OUTPUTDIR}/logs/SoftwareUpgrade
    Update gNB Software     sw_package_dir=${sw_package_path}     timeout=1200
    Control Cells OnAir and NB      ${request_software}


Software Upgrade and Rollback
    Set Suite Variable           ${LOG_DIR}    ${OUTPUTDIR}/logs/SoftUpRollback

    log to console            \n\n
    log to console with time    Software Upgrade and Rollback: Begin
    log to console            \n

    Software Update and Rollback
    ...         sw_request=${request_software}
    ...         5G_sw_rollback=${5G_rollback_software}
    ...         4G_sw_rollback=${4G_rollback_software}
    ...         enb_ip=${4G_ENB_IP}

    log to console            \n
    log to console with time    Software Upgrade and Rollback: End
    log to console            \n


Software Upgrade and Rollback in loop
    [Arguments]       ${loop_nb}=5

    Set Suite Variable           ${LOG_DIR}    ${OUTPUTDIR}/logs/SoftUpRollbackInLoop
    log to console            \n\n
    log to console with time    Software Upgrade and Rollback in loop: Begin
    FOR   ${loop_id}    IN RANGE    ${loop_nb}

        log to console            \n
        Software Update and Rollback
        ...         sw_request=${request_software}
        ...         5G_sw_rollback=${5G_rollback_software}
        ...         4G_sw_rollback=${4G_rollback_software}
        ...         enb_ip=${4G_ENB_IP}
        ...         loop_nb=${loop_id}
    END
    log to console            \n
    log to console with time    Software Upgrade and Rollback in loop: End
    log to console            \n


Reset of eNB without HWF in loop
    [Arguments]       ${loop_nb}=5

    Set Suite Variable           ${LOG_DIR}    ${OUTPUTDIR}/logs/ResetInLoop
    log to console            \n\n
    log to console with time    Reset of eNB without HWF in loop: Begin
    FOR   ${loop_id}  IN RANGE    ${loop_nb}

       log to console            \n
       Soft Reset gNB         ${request_software}    ${loop_nb}

    END
    log to console            \n
    log to console with time    Reset of eNB without HWF in loop: End
    log to console            \n


######################################################################
# Specific soft update
Software Update and Rollback
    [Arguments]       ${sw_request}   ${5G_sw_rollback}   ${4G_sw_rollback}      ${enb_ip}     ${loop_nb}=-1

    # 4G
    Run Keyword If       ${with4G}       Software Update and Control
    ...                             ${sw_request}      4G   enb_ip=${enb_ip}   with_control=${True}   loop_nb=${loop_nb}
    # 5G
    Software Update and Control     ${sw_request}      5G   enb_ip=${None}     with_control=${True}   loop_nb=${loop_nb}
    # 5G
    Software Rollback and Control   ${5G_sw_rollback}  5G   enb_ip=${None}     with_control=${True}   loop_nb=${loop_nb}
    # 4G
    Run Keyword If       ${with4G}       Software Rollback and Control
    ...                             ${4G_sw_rollback}  4G   enb_ip=${enb_ip}   with_control=${True}   loop_nb=${loop_nb}


Software Update and Control
    [Arguments]       ${sw}    ${tech}    ${enb_ip}=${None}     ${with_control}=${False}     ${loop_nb}=-1

    Wait Time Between Two Boot

    Generate Random Key    ${tech}   ${sw}
    setup ute_syslog

    ${msg}=    Run Keyword If    '${enb_ip}'=='None'     Set Variable     gNB Software Update to ${sw}
    ...            ELSE                                  Set Variable     eNB Software Update to ${sw}
    Run Keyword If       ${loop_nb}>-1         log to console with time    Loop: ${loop_nb}, ${msg}
    ...            ELSE                        log to console with time    ${msg}

    # Update gNB Software     sw_package_dir=${sw_package_path}     timeout=1200
    Run Keyword If    '${enb_ip}'=='None'     nb_update_software    sw_path=${sw_package_path}
    ...       ELSE                            nb_update_software    sw_path=${sw_package_path}    oam_ip=${enb_ip}

    ${last_nb_boot}             Get Current Date
    Set Suite Variable        ${last_nb_boot}

    sleep    120
    Run Keyword If   ${with_control}   Control Cells OnAir and NB         ${sw}     ${enb_ip}
    ...  ELSE IF     '${enb_ip}'=='None'       Control 5G Cells OnAir
    ...  ELSE                                  Control 4G Cells OnAir         ${enb_ip}

    [Teardown]   Teardown One SoftUp and Rollback      ${sw}


Software Rollback and Control
    [Arguments]       ${sw}    ${tech}    ${enb_ip}=${None}   ${with_control}=${False}     ${loop_nb}=-1

    Wait Time Between Two Boot

    Generate Random Key    ${tech}   ${sw}
    setup ute_syslog

    ${msg}=    Run Keyword If    '${enb_ip}'=='None'     Set Variable     gNB Software Rollback to ${sw}
    ...            ELSE                                  Set Variable     eNB Software Rollback to ${sw}
    Run Keyword If       ${loop_nb}>-1         log to console with time    Loop: ${loop_nb}, ${msg}
    ...            ELSE                        log to console with time    ${msg}

    software_rollback         ${enb_ip}

    ${last_nb_boot}             Get Current Date
    Set Suite Variable        ${last_nb_boot}

    sleep    120
    Run Keyword If   ${with_control}   Control Cells OnAir and NB         ${sw}     ${enb_ip}
    ...  ELSE IF     '${enb_ip}'=='None'       Control 5G Cells OnAir
    ...  ELSE                                  Control 4G Cells OnAir         ${enb_ip}

    [Teardown]   Teardown One SoftUp and Rollback      ${sw}


######################################################################
# Specific Reset
Soft Reset gNB
    [Arguments]       ${sw}     ${loop_nb}

    Wait Time Between Two Boot

    Generate Random Key     5G   ${sw}
    setup ute_syslog

    log to console with time      Loop ${loop_nb}: Reset of eNB without HWF
    nb_reset
    ${last_nb_boot}             Get Current Date
    Set Suite Variable        ${last_nb_boot}

    sleep    120
    Control Cells OnAir and NB           ${request_software}
    log to console with time      Loop ${loop_nb}: Reset OK

    [Teardown]  Teardown One Reset      ${sw}


######################################################################
# Setup and Teardown

###################
Suite Setup soft up and reset
    Set Suite Variable     ${5G_GNB_IP}    192.168.255.1
    ${4G_ENB_IP}=          get_enb_ip     ${tl}
    Set Suite Variable     ${4G_ENB_IP}
#    Set Suite Variable     ${4G_ENB_IP}      10.14.48.2      # A refaire lorsque l'info serrt dans init.py
    Set Suite Variable     ${4G_ENB_USER}    Nemuadmin
    Set Suite Variable     ${4G_ENB_PWD}     nemuuser
    ${with4G}=             Evaluate   '${4G_ENB_IP}'!='None'
    Set Suite Variable     ${with4G}

    Set Suite Variable     ${request_software}                ${ENB_BUILD}
    log       Request software: ${request_software}     console=True    html=True

    Suite Setup soft up and reset 5G
    Run Keyword IF      ${with4G}       Suite Setup soft up and reset 4G

    Get Label
    Get Hostname
    ${current_time}=          Get Current Date
    ${last_nb_boot}=         Subtract Time From Date    ${current_time}    00:08:00
    Set Suite Variable        ${last_nb_boot}


Suite Setup soft up and reset 5G
    ${5G_curent_sw}=     get_software_version
    log to console with time   5G gNB, Active:${5G_curent_sw['Active']}, Passive: ${5G_curent_sw['Passive']}
    Set Suite Variable     ${5G_initial_software}    ${5G_curent_sw['Active']}
    Set Suite Variable     ${5G_init_passive_sw}     ${5G_curent_sw['Passive']}

    scf_backup     ${OUTPUT DIR}    gNB_scf_backup.xml


Suite Setup soft up and reset 4G
    ${4G_curent_sw}=     get_software_version         ${4G_ENB_IP}
    log to console with time   4G eNB, Active:${4G_curent_sw['Active']}, Passive: ${4G_curent_sw['Passive']}
    Set Suite Variable     ${4G_initial_software}    ${4G_curent_sw['Active']}
    Set Suite Variable     ${4G_init_passive_sw}     ${4G_curent_sw['Passive']}

    scf_backup     ${OUTPUT DIR}    eNB_scf_backup.xml      ${4G_ENB_IP}


Setup New Software Upgrade
    # Only 5G
    ${5G_initOnAirCells}     get_cells_on_air_list
    Should Not Be Empty          ${5G_initOnAirCells}      No 5G Cell OnAir before test
    Set Suite Variable           ${5G_initOnAirCells}

    ${5G_curent_sw}                 get_software_version
    ${same_soft}=      is_same_software_version       ${ENB_BUILD}     ${5G_curent_sw['Active']}
    Should Not Be True      ${same_soft}       ${ENB_BUILD} already active gNB active software


Setup TC Software Upgrade Rollback
    Set Suite Variable           ${LOG_DIR}    ${OUTPUTDIR}/logs/SetupTCSoftUpRoll

    ${sw_package_path}  Download SW Package   sw_version=${ENB_BUILD}
    Set Suite Variable           ${sw_package_path}

    Setup TC Software Upgrade Rollback 5G
    Run Keyword IF      ${with4G}       Setup TC Software Upgrade Rollback 4G


Setup TC Software Upgrade Rollback 5G
    ${5G_initOnAirCells}=    Wait Until Keyword Succeeds   50m   30s    get_cells_on_air_list
    Should Not Be Empty          ${5G_initOnAirCells}      No Cell OnAir before test
    Set Suite Variable           ${5G_initOnAirCells}
    log to console with time     5G Cells OnAir: ${5G_initOnAirCells}

    # 5G
    ${5G_curent_sw}=     Wait Until Keyword Succeeds   50 min    1 min     get_software_version
    log to console with time   5G gNB, Active:${5G_curent_sw['Active']}, Passive: ${5G_curent_sw['Passive']}
    ${same_soft}=      is_same_software_version       ${request_software}     ${5G_curent_sw['Active']}
    Run Keyword If    ${same_soft}    Software Rollback and Control    ${5G_init_passive_sw}   5G
    ${5G_curent_sw}=                  get_software_version
    log to console with time   5G gNB before test, Active:${5G_curent_sw['Active']}, Passive: ${5G_curent_sw['Passive']}
    Set Suite Variable     ${5G_rollback_software}     ${5G_curent_sw['Active']}


Setup TC Software Upgrade Rollback 4G
    ${4G_initOnAirCells}     get_cells_on_air_list         ${4G_ENB_IP}
    Should Not Be Empty          ${4G_initOnAirCells}      No 4G Cell OnAir before test
    Set Suite Variable           ${4G_initOnAirCells}
    log to console with time     4G Cells OnAir: ${4G_initOnAirCells}

    # 4G
    ${4G_curent_sw}=     Wait Until Keyword Succeeds   50 min    1 min     get_software_version    ${4G_ENB_IP}
    log to console with time   4G eNB, Active:${4G_curent_sw['Active']}, Passive: ${4G_curent_sw['Passive']}
    ${same_soft}=      is_same_software_version       ${request_software}     ${4G_curent_sw['Active']}
    Run Keyword If    ${same_soft}     Software Rollback and Control    ${4G_init_passive_sw}  4G  enb_ip=${4G_ENB_IP}

    ${4G_curent_sw}=                   get_software_version        ${4G_ENB_IP}
    log to console with time   4G eNB before test, Active:${4G_curent_sw['Active']}, Passive: ${4G_curent_sw['Passive']}
    Set Suite Variable     ${4G_rollback_software}     ${4G_curent_sw['Active']}


Setup TC Reset
    # Only 5G
    Set Suite Variable           ${LOG_DIR}    ${OUTPUTDIR}/logs/SetupTCReset

    ${5G_initOnAirCells}=    Wait Until Keyword Succeeds   50m   30s    get_cells_on_air_list
    Should Not Be Empty          ${5G_initOnAirCells}      No Cell OnAir before test
    Set Suite Variable           ${5G_initOnAirCells}

    ${c_sw}=     Wait Until Keyword Succeeds   50 min    1 min     get_software_version
    log to console with time   5G gNB, Active:${c_sw['Active']}, Passive: ${c_sw['Passive']}

    ${same_soft_A}=      is_same_software_version       ${request_software}     ${c_sw['Active']}
    ${same_soft_P}=      is_same_software_version       ${request_software}     ${c_sw['Passive']}
    Run Keyword If    ${same_soft_P}                   Software Rollback and Control  ${request_software}  5G
    ...  ELSE   Run Keyword If   not ${same_soft_A}    Setup TC Reset Software Update 5G


Setup TC Reset Software Update 5G
    ${sw_package_path}  Download SW Package   sw_version=${ENB_BUILD}
    Set Suite Variable           ${sw_package_path}
    Software Update and Control    ${request_software}  5G


Suite Teardown soft up and reset
    Set Suite Variable           ${LOG_DIR}    ${OUTPUTDIR}/logs/SuiteTeardown
    Common step trigger
    Suite Teardown soft up and reset 5G
    Run Keyword If   ${with4G}       Suite Teardown soft up and reset 4G


Suite Teardown soft up and reset 5G
    # 5G
    ${5G_curent_sw}=     Wait Until Keyword Succeeds   50 min    1 min     get_software_version
    log to console with time   5G gNB software: ${5G_curent_sw}
    ${same_soft}=      is_same_software_version       ${5G_initial_software}     ${5G_curent_sw['Passive']}
    Run Keyword If      ${same_soft}    Software Rollback and Control   ${5G_curent_sw['Passive']}   5G


Suite Teardown soft up and reset 4G
    # 4G
    ${4G_curent_sw}=     Wait Until Keyword Succeeds   50 min    1 min     get_software_version    ${4G_ENB_IP}
    log to console with time    4G eNB software: ${4G_curent_sw}
    ${same_soft}=      is_same_software_version       ${4G_initial_software}     ${4G_curent_sw['Passive']}
    Run Keyword If    ${same_soft}   Software Rollback and Control   ${4G_curent_sw['Passive']}  4G  enb_ip=${4G_ENB_IP}


Teardown One SoftUp and Rollback
    [Arguments]       ${sw}
    run keyword and ignore error  Log Collector      ${sw}
    run keyword and ignore error  Teardown All Aliases For Syslog
    run keyword if  '${KEYWORD STATUS}'=='PASS'  Report To Reporting Portal  passed
    run keyword if  '${KEYWORD STATUS}'=='FAIL'  Report To Reporting Portal  failed

    #run keyword if  '${KEYWORD STATUS}'=='PASS'
    #...  Run process  sudo rm -rfv ${LOG_DIR}/${SW_LOGS_DIR}/${request_software}/  shell=True


Teardown One Reset
    [Arguments]       ${sw}
    run keyword and ignore error  Log Collector       ${sw}
    run keyword and ignore error  Teardown All Aliases For Syslog
    run keyword if  '${KEYWORD STATUS}'=='PASS'  Report To Reporting Portal  passed
    run keyword if  '${KEYWORD STATUS}'=='FAIL'  Report To Reporting Portal  failed

    #run keyword if  '${KEYWORD STATUS}'=='PASS'
    #...  Run process  sudo rm -rfv ${LOG_DIR}/${SW_LOGS_DIR}/${request_software}/  shell=True


######################################################################
# Control Cell, gNB
Control Cells OnAir and NB
    [Arguments]       ${request_sw_version}    ${enb_ip}=${None}     ${with_traffic}=${False}

    run keyword if  '${enb_ip}'=='None'   5G Control Cells OnAir and GNB  ${request_sw_version}  ${with_traffic}
    ...  ELSE  Run Keyword If  ${with4G}  4G Control Cells OnAir and ENB  ${request_sw_version}  ${enb_ip}  ${with_traffic}


5G Control Cells OnAir and GNB
    [Arguments]       ${request_sw_version}    ${with_traffic}=${False}
    log  ${with_traffic}
    log to console with time   wait 5G gNB ip: ${5G_GNB_IP}
    Wait Until Keyword Succeeds  30m  30s  Address Is Pingable  ${5G_GNB_IP}

    log to console with time   wait 5G gNB active version
    ${curent_sw}=     Wait Until Keyword Succeeds   50m    30s     get_software_version
    log to console with time  5G gNB software, Active:${curent_sw['Active']}, Passive: ${curent_sw['Passive']}
    ${same_soft}=      is_same_software_version       ${curent_sw['Active']}     ${request_sw_version}
    Should Be True      ${same_soft}
    ...     Error: bad 5G gNB software version, request: ${request_sw_version}, active: ${curent_sw['Active']}

    log to console with time   wait 5G Cells OnAir
    Wait Until Keyword Succeeds   50m    30s     test_initial_cells_on_air_list      ${5G_initOnAirCells}

    log to console with time   control 5G gNB unexpected alarm
    ${unexpected_alarm}=   get_unexpected_alarm        ${ALLOWED_FAULTS}
    Should Be Empty    ${unexpected_alarm}     Unexpected alarm: ${unexpected_alarm}

    # Run Keyword If       ${enb_ip} and ${with_traffic}      gNB Verification Check Throughput


4G Control Cells OnAir and ENB
    [Arguments]       ${request_sw_version}    ${enb_ip}    ${with_traffic}=${False}

    log  ${enb_ip}
    log  ${with_traffic}
    log to console with time   wait 4G eNB ip: ${4G_ENB_IP}
    Wait Until Keyword Succeeds  30m  30s  Address Is Pingable  ${4G_ENB_IP}

    log to console with time   wait 4G eNB active version
    ${c_sw}=     Wait Until Keyword Succeeds   50m    30s     get_software_version     ${4G_ENB_IP}
    log to console with time  4G eNB software, Active:${c_sw['Active']}, Passive: ${c_sw['Passive']}
    ${same_soft}=      is_same_software_version       ${c_sw['Active']}     ${request_sw_version}
    Should Be True      ${same_soft}
    ...     Error: bad 4G eNB software version, request: ${request_sw_version}, active: ${c_sw['Active']}

    log to console with time   wait 4G eNB Cells OnAir
    Wait Until Keyword Succeeds   30m    30s     test_initial_cells_on_air_list     ${4G_initOnAirCells}    ${4G_ENB_IP}

    log to console with time   control 4G eNB unexpected alarm
    ${unexpected_alarm}=   get_unexpected_alarm        ${ALLOWED_FAULTS}     ${4G_ENB_IP}
    Should Be Empty    ${unexpected_alarm}     Unexpected alarm: ${unexpected_alarm}


Control 5G Cells OnAir
    log to console with time   wait 5G Cells OnAir
    Wait Until Keyword Succeeds   50m   30s   test_initial_cells_on_air_list   ${5G_initOnAirCells}


Control 4G Cells OnAir
    [Arguments]       ${enb_ip}

    log to console with time   wait 5G Cells OnAir
    Wait Until Keyword Succeeds   50m   30s   test_initial_cells_on_air_list   ${4G_initOnAirCells}     ${enb_ip}


Address Is Pingable
    [Documentation]  Keyword checks if given ip address is pingable.
    [Arguments]  ${NB_IP}=${5G_GNB_IP}
    ${rc}=  Run And Return Rc  ping -c 1 ${NB_IP}
    should be equal as integers  ${rc}  0


gNB Verification Check Throughput
    log to console with time   Check Throughput
    Bi-Directional_Throughput_1-DRB_OTA
    ...                                     capabilities=${capabilities}
    ...                                     duration=${duration}
    ...                                     protocol=${protocol}
    ...                                     deviation=${deviation}
    ...                                     tput_dl=${tput_dl}
    ...                                     tput_ul=${tput_ul}
    ...                                     size_packet_dl=${size_packet_dl}
    ...                                     size_packet_ul=${size_packet_ul}
    ...                                     parallel_streams_dl=${parallel_streams_dl}
    ...                                     parallel_streams_ul=${parallel_streams_ul}
    ...                                     buffer_client_dl=${buffer_client_dl}
    ...                                     buffer_server_dl=${buffer_server_dl}
    ...                                     buffer_client_ul=${buffer_client_ul}
    ...                                     buffer_server_ul=${buffer_server_ul}
    ...                                     interval=${interval}
    ...                                     reboot_ue=${reboot_ue}
    ...                                     timeout_reboot_ue=${timeout_reboot_ue}

    Stop watching alarms


######################################################################
# Report UTE oe Portal
Report To Reporting Portal
    [Documentation]  Keyword send report to reporting portal and return link
    [Arguments]  ${status}=passed  ${build}=${request_software}
    ${test_run}=  convert to string  UUF4ALL_RESET_TEST
    ${ca}=  convert to string  ${tribe}

    # testline name check
    # https://rep-portal.wroclaw.nsn-rdnet.net/reports/test-line/?limit=1000
    #${testline}=  convert to string  5G_${site}_${HOSTNAME}
    ${testline}=  Replace String     5G_${CONFIGURATION}    .   _

    # have to be present in RP report
    ${qc_domain}=  set variable
    ${qc_project}=  set variable
    ${qc_id}=  set variable

    ${comment}=  convert to string  UUF4ALL_${build}
    ${uuf_test}=  convert to string  True
    ${testline_type}=  convert to string  ${LABEL}

    ${link_to_reporting_portal}=
    ...  ute_reporting_portal.report to rp
    ...  name=${test_run}
    ...  result=${status}
    ...  ca=${ca}
    ...  testline=${testline}
    ...  build=${build}
    ...  qc_domain=${qc_domain}
    ...  qc_project=${qc_project}
    ...  qc_id=${qc_id}
    ...  comment=${comment}
    ...  uuf_test=${uuf_test}
    ...  label=${testline_type}
    ...  parameter_1=${build}  # initial build fo UUF view


    set suite variable  ${LINK_TO_RP}  ${link_to_reporting_portal}
    log to console with time  ${LINK_TO_RP}


Get Hostname
    ${rc}  ${hostname_tmp}=  Run And Return Rc And Output  hostname
    ${hostname_tmp}=  Replace String  ${hostname_tmp}  -  _
    ${hostname_tmp}=  convert to string  ${hostname_tmp}
    ${hostname_part}=  split string  ${hostname_tmp}  _
    ${hostname_combined}=  catenate  ${hostname_part[0]}_${hostname_part[1]}_${hostname_part[2]}
    set suite variable  ${HOSTNAME}  ${hostname_combined}


Get Label
    ${label_cmd}=  convert to string  cat /opt/ute/reservation.json | grep -o -P '"testline_type": (".+")' | awk -F '"' '{print $4}'
    ${label}=  Run process  ${label_cmd}  shell=True  cwd=${CURDIR}
    ${label}=  convert to string  ${label.stdout}
    log to console with time  ${label}
    Set Suite Variable  ${LABEL}  ${label}


Generate Random Key
    [Documentation]  Generates ramdom string for log name purpose.
    [Arguments]  ${tech}   ${sw}

    # ${SW_LOGS_DIR} =  String.Generate Random String  5  [UPPER]
    # set suite variable  ${SW_LOGS_DIR}  ${SW_LOGS_DIR}
    @{time}=      Get Time  hour min sec  NOW
    ${time_now}=  Catenate   SEPARATOR=   @{time}[0]  @{time}[1]  @{time}[2]
    set suite variable  ${SW_LOGS_DIR}  ${time_now}_${tech}_${sw}
    log to console with time  Directory Logs: ${SW_LOGS_DIR}


Setup ute_syslog
    [Documentation]  Keyword for setting up ute_syslog library.

    # cleanup
    run keyword and ignore error  collect Syslog Results
        ...  destination=${LOG_DIR}/teardown.tar.gz
        ...  unzip=${False}
        ...  alias=main_syslog
    run keyword and ignore error  Teardown All Aliases For Syslog

    log to console with time  Setting Up ute_syslog
    Wait Until Keyword Succeeds  5m  30s
        ...  ute_syslog.start syslog
            ...  log_dir=${LOG_DIR}/${SW_LOGS_DIR}/
            ...  log_name=syslog_backup_${SW_LOGS_DIR}.log
            ...  file_limit=209715200  # 200MB
            ...  add_line_number=True
            ...  alias=main_syslog

    ${start_of_loop}=  Capture Savepoint    alias=main_syslog
    set suite variable  ${START_OF_LOOP}  ${start_of_loop}


Log Collector
    [Documentation]  Gathers syslog, snapshot and Infomodel log.
    [Arguments]  ${sw_build}
    log to console with time  Gathering Logs
    ${admin_3600_status}=  run keyword and return status
        ...  Wait Until Keyword Succeeds  5x  1m  Setup Admin For Alias  admin_logs_3600

    ${OUTPUT_LOG_DIR}=    Set Variable    ${LOG_DIR}/${SW_LOGS_DIR}

    log to console with time  Copy swconfig.txtx
    copy_sw_config        ${OUTPUT_LOG_DIR}    toor4nsn     oZPS0POrRieRtu

    log to console with time  Gathering ute_admin IMS
    run keyword if  ${admin_3600_status}  run keyword and ignore error
        ...  ute_admin.Collect Im Snapshot
            ...  target_file_name=${OUTPUT_LOG_DIR}/IMS_admin_${sw_build}_${SW_LOGS_DIR}_3600.ims2
            ...  alias=admin_logs_3600

    log to console with time  Gathering ute_admin Snapshot
    run keyword if  ${admin_3600_status}  run keyword and ignore error  Wait Until Keyword Succeeds  3x  30s
    ...  ute_admin.Collect Snapshot
        ...  target_file_name=${OUTPUT_LOG_DIR}/snapshot_${sw_build}_${SW_LOGS_DIR}_3600.zip
        ...  timeout=1200
        ...  alias=admin_logs_3600

    log to console with time  Gathering ute_syslog
    run keyword and ignore error  collect Syslog Results
        ...  destination=${OUTPUT_LOG_DIR}/syslog_${sw_build}_${SW_LOGS_DIR}.tar.gz
        ...  unzip=${False}
        ...  alias=main_syslog

    [Teardown]  run keyword
    ...       run keyword if  ${admin_3600_status}  ute_admin.Teardown Admin  alias=admin_logs_3600


######################################################################
# Other
Log to console with time
    [Documentation]  Keyword display,log output with time.
    [Arguments]  ${output}
    @{time}=  Get Time  hour min sec  NOW
    ${time_now}=  Catenate  SEPARATOR=:  @{time}[0]  @{time}[1]  @{time}[2]
    Log  (${time_now}) ${output}  console=True   html=True


Wait Time Between Two Boot
    ${curent_time}=            Get Current Date
    ${diff_time}=              Subtract Date From Date   ${curent_time}   ${last_nb_boot}
    ${wait_time}=              Evaluate        ${min_time_between_boot}-${diff_time}
    Run Keyword If     ${wait_time}>0     Run keywords
    ...            log to console with time    Wait before new boot command: ${wait_time}s
    ...      AND   Sleep    ${wait_time}


Setup Admin For Alias
    [Documentation]  Setups ute_admin library on given alias.
    [Arguments]  ${alias}
    log to console with time  Setting UP ute_admin: ${alias}
    ute_admin.setup admin
        ...  bts_host=${5G_GNB_IP}
        ...  bts_port=3600
        ...  admin_api_log_dir=${LOG_DIR}/admin_logs/
        ...  alias=${alias}
    [Teardown]  run keyword if  '${KEYWORD STATUS}'=='FAIL'  ute_admin.Teardown Admin  alias=${alias}

############################################################################
##4G Cides


Setup 4G TC Reset
    # Only 4G
    ${current_time}=          Get Current Date
    ${last_nb_boot}=         Subtract Time From Date    ${current_time}    00:08:00
    Set Suite Variable        ${last_nb_boot}

    kw_UUF.Get Label
    kw_UUF.Get Hostname

    Log     customers: @{CUSTOMERS_LIST}    console=yes   html=yes
    Set 4G Reporting Portal Variables    @{CUSTOMERS_LIST}

    Set Suite Variable     ${request_software}                ${ENB_BUILD}
    log       Request software: ${request_software}     console=True    html=True

    Set Test Variable   ${request_sw_version}      ${ENB_BUILD}
    log       Request software: ${request_sw_version}     console=True    html=True

    ${4G_ENB_IP}=          get_enb_ip     ${tl}
    Set Suite Variable     ${4G_ENB_IP}
    ${enb_ip}=   Set Variable     ${4G_ENB_IP}
    Set Suite Variable     ${enb_ip}

    Set Suite Variable           ${LOG_DIR}    ${OUTPUTDIR}/logs/SetupTCReset

    ${case_type}=  Convert To String   Reset
    Set Test Variable  ${CASE_TYPE}  ${case_type}

    ${5G_initOnAirCells}=    Wait Until Keyword Succeeds   50m   30s    get_cells_on_air_list    ${enb_ip}
    Should Not Be Empty          ${5G_initOnAirCells}      No Cell OnAir before test
    Set Suite Variable           ${5G_initOnAirCells}

    ${c_sw}=     Wait Until Keyword Succeeds   50 min    1 min     get_software_version     ${enb_ip}
    log to console with time   4G eNB, Active:${c_sw['Active']}, Passive: ${c_sw['Passive']}

    ${same_soft_A}=      is_same_software_version       ${request_software}     ${c_sw['Active']}
    ${same_soft_P}=      is_same_software_version       ${request_software}     ${c_sw['Passive']}
    Set Suite Variable     ${4G_rollback_software}     ${c_sw['Active']}
    Run Keyword If    ${same_soft_P}                   Software Rollback and Control 4G  ${request_software}  4G  ${enb_ip}
    ...  ELSE   Run Keyword If   not ${same_soft_A}    Setup TC Reset Software Update 4G  ${enb_ip}


Setup TC Reset Software Update 4G
    [Arguments]      ${enb_ip}
    ${sw_package_path}  Download SW Package   sw_version=${ENB_BUILD}
    Set Suite Variable           ${sw_package_path}
    Software Update and Control 4G    ${request_software}  4G   ${enb_ip}

Software Update and Control 4G
    [Arguments]       ${sw}    ${tech}    ${enb_ip}=${None}     ${with_control}=${False}     ${loop_nb}=-1

    log  ${with_control}
    Wait Time Between Two Boot

    Generate Random Key    ${tech}   ${sw}

    ${msg}=    Set Variable     eNB Software Update to ${sw}
    Run Keyword If       ${loop_nb}>-1         log to console with time    Loop: ${loop_nb}, ${msg}
    ...            ELSE                        log to console with time    ${msg}

    # Update gNB Software     sw_package_dir=${sw_package_path}     timeout=1200
    nb_update_software    sw_path=${sw_package_path}    oam_ip=${enb_ip}

    ${last_nb_boot}             Get Current Date
    Set Suite Variable        ${last_nb_boot}

    sleep    320
    Control 4G Cells OnAir         ${enb_ip}

Software Rollback and Control 4G
    [Arguments]       ${sw}    ${tech}    ${enb_ip}=${None}   ${with_control}=${False}     ${loop_nb}=-1

    log  ${with_control}
    Wait Time Between Two Boot

    Generate Random Key    ${tech}   ${sw}

    ${msg}=   Set Variable     eNB Software Rollback to ${sw}

    Run Keyword If       ${loop_nb}>-1         log to console with time    Loop: ${loop_nb}, ${msg}
    ...            ELSE                        log to console with time    ${msg}

    kw_uuf.software_rollback         ${enb_ip}

    ${last_nb_boot}             Get Current Date
    Set Suite Variable        ${last_nb_boot}

    sleep    420
    Control 4G Cells OnAir         ${enb_ip}

    ##[Teardown]   Teardown One SoftUp and Rollback      ${sw}

#########################################

Reset of 4G eNB without HWF in loop
    [Arguments]       ${loop_nb}=5

    Set Suite Variable           ${LOG_DIR}    ${OUTPUTDIR}/logs/ResetInLoop
    log to console            \n\n
    log to console with time    Reset of eNB without HWF in loop: Begin
    FOR   ${loop_id}  IN RANGE    ${loop_nb}

       log to console            \n
       Soft Reset eNB         ${request_software}    ${loop_id}

    END
    log to console            \n
    log to console with time    Reset of eNB without HWF in loop: End
    log to console            \n


Soft Reset eNB
    [Arguments]       ${sw}     ${loop_nb}

    Wait Time Between Two Boot

    Generate Random Key     4G   ${sw}

    uuf_rfrl_common_keywords.Get Iteration Start Time
    log to console with time      Loop ${loop_nb}: Reset of eNB without HWF
    #nb_reset    ${enb_ip}
    ${last_nb_boot}             Get Current Date
    Set Suite Variable        ${last_nb_boot}
    uuf_rfrl_common_keywords.Get Iteration End Time

   # sleep    220
    4G Control Cells OnAir  ${request_sw_version}  ${enb_ip}
    log to console with time      Loop ${loop_nb}: Reset OK

    [Teardown]  Teardown 4G      ${sw}


Teardown 4G
    [Arguments]       ${sw}
    run keyword and ignore error  Log Collector       ${sw}
    run keyword and ignore error  Teardown All Aliases For Syslog
    run keyword if  '${KEYWORD STATUS}'=='PASS'  uuf_rfrl_common_keywords.Report To Reporting Portal  Passed
    run keyword if  '${KEYWORD STATUS}'=='FAIL'  uuf_rfrl_common_keywords.Report To Reporting Portal  Failed


4G Control Cells OnAir
    [Arguments]       ${request_sw_version}   ${4G_ENB_IP}

    log to console with time   wait 4G eNB ip: ${4G_ENB_IP}
    Wait Until Keyword Succeeds  30m  30s  Address Is Pingable  ${4G_ENB_IP}

    log to console with time   wait 4G eNB active version
    ${c_sw}=     Wait Until Keyword Succeeds   50m    30s     get_software_version     ${4G_ENB_IP}
    log to console with time  4G eNB software, Active:${c_sw['Active']}, Passive: ${c_sw['Passive']}
    ${same_soft}=      is_same_software_version       ${c_sw['Active']}     ${request_sw_version}
    Should Be True      ${same_soft}
    ...     Error: bad 4G eNB software version, request: ${request_sw_version}, active: ${c_sw['Active']}

    log to console with time   wait 4G eNB Cells OnAir
    Wait Until Keyword Succeeds   30m    30s     test_initial_cells_on_air_list     ${4G_initOnAirCells}    ${4G_ENB_IP}

    log to console with time   control 4G eNB unexpected alarm
    ${unexpected_alarm}=   get_unexpected_alarm        ${ALLOWED_FAULTS}     ${4G_ENB_IP}
    Should Be Empty    ${unexpected_alarm}     Unexpected alarm: ${unexpected_alarm}


Set 4G Reporting Portal Variables
    [Arguments]  @{customers_list}   ${comment}=None
    Log   ${customers_list}
    Run Keyword If  "${LABEL}" == "${None}"   uuf_rfrl_common_keywords.Get Label
    Run Keyword If  "${HOSTNAME}" == "${None}"  uuf_rfrl_common_keywords.Get Hostname
    ${RESERVED_BUILD}=   Convert to String   ${ENB_BUILD}
    Set Test Variable  ${RESERVED_BUILD}
    ${build}=    Set Variable   ${4G_rollback_software}
    ${build}=    Convert To String   ${build}
    ${HW_ID}=    Convert To String   ${4G_HW}
    Set Test Variable  ${HW_ID}
    ${RU_TYPE}=   Convert To String     ${4G_RU}
    ${TDD_FDD_VARIANT}=  Convert To String   ${4G_TECH}
    Set Test Variable  ${RU_TYPE}
    Set Test Variable  ${TDD_FDD_VARIANT}
    Log  List of supported customers: ${RFRL_CUSTOMERS_LIST}
    #${customers_list}=  uuf_rfrl_common.Validate Customers List  @{customers_list}
    uuf_rfrl_common.Add Comment To Report  ${comment}
    Set Test Variable  @{CUSTOMERS_LIST}    @{customers_list}
    &{report_links}=    Create Dictionary
    Set Test Variable  ${REPORT_LINKS}  ${report_links}
    Set Test Variable  ${LOCAL_BTS_TYPE}   ${bts_type}
    Set Test Variable  ${CELL_DOWNTIME}   None

######################################################################################

Setup 4G TC Upgrade
    # Only 4G
    ${current_time}=          Get Current Date
    ${last_nb_boot}=         Subtract Time From Date    ${current_time}    00:08:00
    Set Suite Variable        ${last_nb_boot}

    kw_UUF.Get Label
    kw_UUF.Get Hostname

    Log     customers: @{CUSTOMERS_LIST}    console=yes   html=yes

    Set Suite Variable     ${request_software}                ${ENB_BUILD}
    log       Request software: ${request_software}     console=True    html=True

    Set Test Variable   ${request_sw_version}      ${ENB_BUILD}
    log       Request software: ${request_sw_version}     console=True    html=True

    ${4G_ENB_IP}=          get_enb_ip     ${tl}
    Set Suite Variable     ${4G_ENB_IP}
    ${enb_ip}=   Set Variable     ${4G_ENB_IP}
    Set Suite Variable     ${enb_ip}

    Set Suite Variable           ${LOG_DIR}    ${OUTPUTDIR}/logs/SetupTCReset

    ${case_type}=  Convert To String   Upgrade
    Set Test Variable  ${CASE_TYPE}  ${case_type}

    ${4G_initOnAirCells}=    Wait Until Keyword Succeeds   50m   30s    get_cells_on_air_list    ${enb_ip}
    Should Not Be Empty          ${4G_initOnAirCells}      No Cell OnAir before test
    Set Suite Variable           ${4G_initOnAirCells}

    ${c_sw}=     Wait Until Keyword Succeeds   50 min    1 min     get_software_version     ${enb_ip}
    log to console with time   4G eNB, Active:${c_sw['Active']}, Passive: ${c_sw['Passive']}
	Set Suite Variable     ${4G_rollback_software}     ${c_sw['Active']}
    Set 4G Reporting Portal Variables    @{CUSTOMERS_LIST}
	Setup TC Reset Software Update 4G  ${enb_ip}


Software Upgrade and Rollback in loop 4G
    [Arguments]       ${loop_nb}=5

    Set Suite Variable           ${LOG_DIR}    ${OUTPUTDIR}/logs/SoftUpRollbackInLoop
    log to console            \n\n
    log to console with time    Software Upgrade and Rollback in loop: Begin
    FOR   ${loop_id}    IN RANGE    ${loop_nb}

        log to console            \n
		log to console          Loop: ${loop_id}\n\n
        Software Update and Rollback in 4G
        ...         sw_request=${request_software}
        ...         4G_sw_rollback=${4G_rollback_software}
		...         enb_ip=${enb_ip}
        ...         loop_nb=${loop_id}
    END
    log to console            \n
    log to console with time    Software Upgrade and Rollback in loop: End
    log to console            \n

Software Update and Rollback in 4G
    [Arguments]       ${sw_request}    ${4G_sw_rollback}      ${enb_ip}     ${loop_nb}=-1

    # 4G
    Software Update and Control 4G     ${sw_request}      4G   enb_ip=${enb_ip}   with_control=${True}   loop_nb=${loop_nb}
    Software Rollback and Control 4G   ${4G_sw_rollback}  4G   enb_ip=${enb_ip}   with_control=${True}   loop_nb=${loop_nb}
    [Teardown]  Teardown 4G      ${sw_request}
