*** Settings ***
Documentation
  ...  Keywords for UUF stability run
  ...  Furkan.Tombul@nokia.com

Library  OperatingSystem
Library  Process
Library  String
Library  DateTime
Library  Collections
Library  XML  use_lxml=True

Library  ute_fsmaccess
Library  taf.sbts.oam.coam.admin  WITH NAME  admin
Library  ute_syslog
Library  taf.sw.reporting_portal

Resource    ../../resources/syve_testline.robot
Resource    ../../../resources/Common/snapshot.robot
Resource    ../../resources/enb.robot


*** Variables ***
${PREPARE_UBOOT}=    sshpass -p oZPS0POrRieRtu
    ...    scp /mnt/etfiles/scripts/UUF-scripts/prepare-bts-firmware-before-tests-master/prepare-firmware.sh
    ...    toor4nsn@192.168.255.129:/ffs/run
${RUN_UBOOT}=    sshpass -p oZPS0POrRieRtu
    ...    ssh toor4nsn@192.168.253.20 -J toor4nsn@192.168.255.129 '/ffs/run/prepare-firmware.sh'
${RUN_UBOOT_GNB}=    sshpass -p oZPS0POrRieRtu
    ...    ssh toor4nsn@192.168.253.20 -J toor4nsn@192.168.255.129 '/ffs/run/prepare-firmware.sh'

${BLACKBOX_PATH}=   /ffs/run/config/lifedata/blackbox

# blackbox
@{BLACKBOX_PRINTS}=  Recovery \\(Execute reset.\\)  Spurious reset  Spurious BTS reset  Unknown \\(Execute reset.\\)
${BLACKBOX_DETECTED}=  False

#compare scf
${ADDITIONAL_MESSAGE}=    ${Empty}

# ERR/WRN check
@{BLACK_LIST}=    Correlator.*

@{WHITE_LIST}=  dhcpd: Multiple interfaces match the same
...  Dropped EMPacket due to failed udp checksum validation Memory dump area already exist in DB, no updated to DB
...  init_se_crash_log_block Can't get hostname of 192.168.253.6 reported when LRC startup crashIndAxmAddress
...  handleL2TriggerRlcMaxIndMsg:error cellid and crnti Failed to open file _\d+D_part_\d.zip
...  AaTrblServerTh WRN/CCS/AaTrbl, addFile: memoryBudge commonTimer WRN/ IQ antenna data ZERO
...  latency period is too short udpcp WRN/CCS/AaUdpcpTx, Resending message seqNum
...  WRN/L2TupuUl: PDCP PDU discarded ueId=
...  WRN/L2TupuDl: PdcpHoSnLimit : We could have not forwarded some packets due to genDrbPdcpHeaderReset drbId=
...  CPSCellQueueContext : PSManager receive PS_TX_ANTENNA_CONF_CHANGE
...  ClockSMain WRN/HWA/CLOCKS, PPSRefClockMonitorStrategyLRC ::handleEventTimeoutInd()
...  AaTrblServerMasterT WRN/CCS/AaTrbl, addTrblClient: Client already registered clientSicad
...  reported status 0 - setting to Broken (ERR|WRN).*sleep is not recommended in EO env.* Scell info not right
...  sleep is not recommended in EO env, sleeptime MAC PS receive unreserved dedicated preamble
...  no default route - cannot cope with %defaultroute handlePhyPrachReceiveInd: Received rachIndex in group c for unreserved
...  WRN/LGC/CLIC, CTempMeasUnit : Sensor Flushing 2 messages from nodes queue WRN/CCS/AaUdpcpTx, Peer IP 192.168.253
...  AaSysComGw WRN/CCS/AaSysComGw, Msg delivery failed WRN/CCS/AaSysTime, tickTimerValidityCheck: emTimeCurrTick
...  checkExceptionResult, Both exception flag of NEWTX and RETX detected
...  WRN/CCS/AaSysCom, Message send failed (recipient has not been registered). Msg header
...  WRN/CCS/AaSysCom, Message send failed (destination CPID is invalid)
...  EventCombinerISR _EV WRN/CCS/AaSysCom, Owner of the message
...  Received node poll response, but this isn't trying to do audit
...  RequestOperation [UR - UTC Resync] can't be supported on UTC Did not receive utc response from the node in time!
...  CheckOperationState for operation UTC Resync - SyncError count 0/2 (max)
...  Too many timers tried to create in timer Wheel discarding unexpected message of type 0xfc1 from 0x101104db
...  Align\d+-NOT_COMPLETED ./gtLrcScpHooper.c:
...  AaSyslog buffer \d+ \(\w+\) reached LoadLevel2 , Info, Warning, Error and Vip logs will be accepted
...  (ERR|WRN).*dhcpd.* AaSyslog buffer \d+ \(\w+\) reached LoadLevel3 , Error and Vip logs will be accepted
...  buffer LoadLevel3 : ERR and VIP logs will be accepted
...  kernel: \[\s*\d+\.\d+\] EXT4-fs \(sda\d\): warning: maximal mount count reached, running e2fsck is recommended
...  extSrioPortStateControl:.*SFP absent

${OUTPUT}
${WARNINGS}=  ${Empty}
${MAC_PS}=    ${Empty}
${L2}=    ${Empty}
${PHY}=    ${Empty}
${NEW_ERRORS_AND_WARNINGS} =   ${EMPTY}
${WRN_ERR} =   ${EMPTY}
${ALL_NEW_ERRORS_AND_WARNINGS}=   ${EMPTY}
${FORMATED_NEW_ERRORS_AND_WARNINGS}=   ${EMPTY}

${FAULT_NAME}    SSH enabled
@{ALLOWED_ALARMS} =    SSH enabled
...    Ethernet port security is disabled
...    R&D Service Port enabled
...    LMP access via port 443
...    Service account root access is enabled


*** Keywords ***
gnb UUF checks before
    [Arguments]     ${gnb_id}=0
    #ToDo: Rename KW

    log to console with time      gNB UUF checks before
    gnb.Wait Until Node To Be Onair State   node_id=${gnb_id}    retry_interval=60 sec
    ${current_gNB_sw}=    testline.Fetch Current gNB SW Version    ${gnb_id}
    Run Keyword And Warn On Failure    Get SCF and Validate Plan    gnb_id=${gnb_id}
    log to console with time      Log dir: ${\n}${LOG_DIR}

    Wait Until Keyword Succeeds     1 min      10 sec     gnb.Get SCF from gNB    gnb_id=${gnb_id}
    ...    target_dir=${LOG_DIR}/gNB${gnb_id}_SCF_before

    Log To Console    ${\n}Check if additional reset occurred.
    Check Blackbox Before Upgrade Gnb    gnb_id=${gnb_id}
    start the following gnb logs    gnb_id=${gnb_id}


enb UUF checks before
    [Arguments]    ${enb_id}=0
    log to console with time    eNB UUF checks before
    gnb.Wait Until Node To Be Onair State   node_type=enb   node_id=${enb_id}    timeout=900 sec    retry_interval=60 sec
    Wait Until Keyword Succeeds    1 min    10 sec    enb.Get SCF from eNB    enb_id=${enb_id}
    ...    resultDir=${LOG_DIR}/eNB${enb_id}_SCF_before
    Check Blackbox Before Upgrade Enb    enb_id=${enb_id}
    Start the following enb logs    enb_id=${enb_id}


gnb UUF checks after
    [Arguments]     ${gnb_id}=0
    log to console with time      gNB UUF checks after
    gnb.Wait Until Node To Be Onair State   node_id=${gnb_id}    retry_interval=60 sec
    ${current_gNB_sw}=    testline.Fetch Current gNB SW Version    ${gnb_id}
    Get SCF and Validate Plan    gnb_id=${gnb_id}
    Run Keyword And Continue On Failure     Check Blackbox After Upgrade Gnb     gnb_id=${gnb_id}
    Stop the following gnb logs


enb UUF checks after
    [Arguments]     ${enb_id}=0
    log to console with time      eNB UUF checks after
    gnb.Wait Until Node To Be Onair State   node_type=enb   node_id=${enb_id}    timeout=900 sec    retry_interval=60 sec
    Run Keyword And Continue On Failure     Check Blackbox After Upgrade Enb    enb_id=${enb_id}
    Stop the following enb logs     enb_id=${enb_id}


Check Blackbox Before Upgrade Gnb
    [Arguments]    ${gnb_id}=0    ${du_id}=0    ${comu_id}=0
    log to console with time  ${\n}BlackBox Check Before Upgrade gNB
    ${after_upgrade}=    Set Variable    False
    log to console with time  Checking BlackBox before upgrade
    ${gnb_cu}=    connect.Connect to Node Common Unit    node_id=${gnb_id}    du_id=${du_id}    comu_id=${comu_id}
    ssh.Download File    remote_path=${BLACKBOX_PATH}    local_path=${LOG_DIR}/gnb_blackbox_before_upgrade.txt   connection=${gnb_cu}
    ${Blackbox_output}=  OperatingSystem.Get file  path=${LOG_DIR}/gnb_blackbox_before_upgrade.txt
    Blackbox Checks    ${Blackbox_output}    ${after_upgrade}
    [Teardown]  Run Keyword and Ignore Error    admin.teardown    connection=${gnb_cu}


Check Blackbox Before Upgrade Enb
    [Arguments]    ${enb_id}=0
    log to console with time  ${\n}BlackBox Check Before Upgrade eNB
    ${after_upgrade}=    Set Variable    False
    log to console with time  Checking BlackBox before upgrade
    Setup Enb Fsm Access  host=${tl.enbs[${enb_id}].system_module.common_units[0].lmp_connection.addr}
    ${Blackbox}=  Get Enb File  source=${BLACKBOX_PATH}  destination=${LOG_DIR}/enb_blackbox_before_upgrade.txt
    ${Blackbox_output}=  OperatingSystem.Get file  path=${Blackbox}
    Blackbox Checks    ${Blackbox_output}    ${after_upgrade}
    [Teardown]    Teardown Enb Fsm Access


Teardown For Check Blackbox After Upgrade GNB
    [Arguments]    ${connection}   ${status}
    Run Keyword And Ignore Error    admin.teardown    connection=${connection}
    IF  '${status}'=='FAIL'  Set Suite Variable  ${BLACKBOX_STATUS}  ${True}
    ...  ELSE                Set Suite Variable  ${BLACKBOX_STATUS}  ${False}


Check Blackbox After Upgrade GNB
    [Arguments]    ${gnb_id}=0    ${du_id}=0    ${comu_id}=0
    log to console with time  \n
    ${after_upgrade}=    Set Variable    True
    log to console with time  Checking BlackBox after upgrade
    ${gnb_cu}=    connect.Connect to Node Common Unit    node_id=${gnb_id}    du_id=${du_id}    comu_id=${comu_id}
    ssh.Download File    remote_path=${BLACKBOX_PATH}    local_path=${LOG_DIR}/gnb_blackbox_after_upgrade.txt   connection=${gnb_cu}
    ${Blackbox_output}=  OperatingSystem.Get file  path=${LOG_DIR}/gnb_blackbox_after_upgrade.txt
    Blackbox Checks    ${Blackbox_output}    ${after_upgrade}

    [Teardown]  Teardown For Check Blackbox After Upgrade GNB   connection=${gnb_cu}   status=${KEYWORD STATUS}


Teardown For Check Blackbox After Upgrade ENB
    [Arguments]    ${status}
    Teardown Enb Fsm Access
    IF  '${status}'=='FAIL'  Set Suite Variable  ${BLACKBOX_STATUS}  ${True}
    ...   ELSE   Set Suite Variable  ${BLACKBOX_STATUS}  ${False}


Check Blackbox After Upgrade ENB
    [Arguments]    ${enb_id}=0
    ${after_upgrade}=    Set Variable    True
    log to console with time  Checking BlackBox after upgrade
    Setup Enb Fsm Access   host=${tl.enbs[${enb_id}].system_module.common_units[0].lmp_connection.addr}
    ${Blackbox}=  Get Enb File  source=${BLACKBOX_PATH}   destination=${LOG_DIR}/enb_blackbox_after_upgrade.txt
    ${Blackbox_output}=  OperatingSystem.Get file  path=${Blackbox}
    Blackbox Checks    ${Blackbox_output}    ${after_upgrade}
    [Teardown]  Teardown For Check Blackbox After Upgrade Enb   status=${KEYWORD STATUS}


Blackbox Checks
    [Arguments]    ${Blackbox_output}   ${after_upgrade}
    ${extract_reset_info}=  split string  ${Blackbox_output}  RESET COUNTER:
    ${blackbox_info}=  split string  ${extract_reset_info[1]}  SW VERSION: active:
    @{lines}=  split to lines  ${blackbox_info[0]}
    remove from list  ${lines}  0
    remove from list  ${lines}  0
    @{before_upgrade_prints}=  create list

    FOR  ${line}  IN  @{lines}
       ${list}=  split string  ${line}  ${SPACE}  max_split=1
       ${list_length}=  get length  ${list}
       ${status}  ${index}=  IF  ${list_length}>1   Check if contain  ${list[1]}  ${BLACKBOX_PRINTS}
       @{return_list}=  create list  ${list[0]}  ${index}
       IF  ${status} and ${list_length}>1  append to list  ${before_upgrade_prints}  ${return_list}
    END
    IF    '${after_upgrade}'=='False'    set suite variable  ${BEFORE_UPGRADE_PRINTS}  ${before_upgrade_prints}
    ...   ELSE    set suite variable  ${after_upgrade_prints}  ${before_upgrade_prints}

    @{before_upgrade_counts}=  create list
    FOR  ${index}  ${element}  IN ENUMERATE  @{BLACKBOX_PRINTS}
       ${matches}=  get regexp matches  ${Blackbox_output}  ${element}
       ${length}=  get length  ${matches}
       insert into list  ${before_upgrade_counts}  ${index}  ${length}
    END
    IF    '${after_upgrade}'=='False'    set suite variable  ${COUNTS_BEFORE}  ${before_upgrade_counts}
    log to console with time  Blackbox before upgrade: ${COUNTS_BEFORE}
    IF    '${after_upgrade}'=='True'
        Set Suite Variable    ${after_upgrade_counts}    ${before_upgrade_counts}
        Blackbox Checks after upgrade    ${after_upgrade_counts}    ${BLACKBOX_PRINTS}
    END


Blackbox Checks after upgrade
    [Arguments]    ${after_upgrade_counts}    ${BLACKBOX_PRINTS}
    log to console with time  Blackbox before upgrade refactored: ${COUNTS_BEFORE}
    log to console with time  Blackbox after upgrade: ${after_upgrade_counts}

    FOR  ${index}  ${print}  IN ENUMERATE  @{BLACKBOX_PRINTS}
       ${status}=  run keyword and return status  should be equal as integers  ${COUNTS_BEFORE[${index}]}  ${after_upgrade_counts[${index}]}
       IF   not ${status}
                Log To Console With Time   Blackbox Failed because ${BLACKBOX_PRINTS[${index}]} found after upgrade
                Log To Console With Time   ${Blackbox_output}\n\n
                Set Suite Variable   ${TURN_OFF_BLACKBOX_CHECK_TEMPORARY}   ${True}
                ${blackbox_message}=   Catenate  ${ADDITIONAL_MESSAGE} BLACKBOX: \n${BLACKBOX_PRINTS[${index}]}\n\n
                Set Suite Variable   ${ADDITIONAL_MESSAGE}  ${blackbox_message}=
                Fail   Blackbox Failed because ${BLACKBOX_PRINTS[${index}]} found after upgrade
       END
    END
    Check If Prints Rolled Over  ${before_upgrade_prints}  ${after_upgrade_prints}


Check if contain
    [Arguments]  ${source}  ${prints}
    FOR  ${index}  ${print}  IN ENUMERATE  @{prints}
       ${matches}=  get regexp matches  ${source}  ${print}
       ${matches_length}=  get length  ${matches}
       IF  ${matches_length}>0  RETURN  ${True}  ${index}
    END
    RETURN  ${False}  ${-1}


Check If Prints Rolled Over
    [Arguments]  ${before_up_prints}  ${after_up_prints}
    ${after_as_string}=  convert to string   ${after_up_prints}
    FOR  ${item}  IN  @{before_up_prints}
       ${status}=  Run Keyword And Return Status   Should Contain   ${after_as_string}   ${item[0]}
       IF   not ${status}
                ${temp_var}=   Evaluate   ${COUNTS_BEFORE[${item[1]}]} -1
                Log To Console With Time    no longer in blackbox - deleting entry(because blackbox contain only 10 messages)
                Set List Value   ${COUNTS_BEFORE}   ${item[1]}   ${temp_var}
       END
    END


Compare Scf
    [Arguments]  ${node_type}   ${gnb_id}=None  ${enb_id}=None
    IF    '${node_type}'=='gnb'    Run Keyword And Ignore Error
    ...         gnb.Get SCF from gNB    gnb_id=${gnb_id}    target_dir=${LOG_DIR}/gnb${gnb_id}_scf_after
    ...   ELSE IF    '${node_type}'=='enb'    Run Keyword And Ignore Error
    ...         enb.Get SCF from eNB    enb_id=${enb_id}    resultDir=${LOG_DIR}/enb${enb_id}_scf_after
    Log To Console With Time   Comparing SCF before and after upgrade
    ${delta_scf_path}=    Set Variable    ${LOG_DIR}

    IF    '${node_type}'=='gnb'
            Calculate Delta SCF
            ...   target_scf_path=${LOG_DIR}/gnb${gnb_id}_scf_before/SCFC_gNB${gnb_id}_DU.xml
            ...   actual_scf_path=${LOG_DIR}/gnb${gnb_id}_scf_before/SCFC_gNB${gnb_id}_DU.xml
            ...   delta_scf_path=${delta_scf_path}/gNB${gnb_id}_deltas.xml
            ${deltas}=    calculate delta gnb    ${delta_scf_path}   ${gnb_id}
    ELSE IF    '${node_type}'=='enb'
            Calculate Delta SCF
            ...    target_scf_path=${LOG_DIR}/enb${enb_id}_scf_before/SCFC_eNB${enb_id}.xml
            ...    actual_scf_path=${LOG_DIR}/enb${enb_id}_scf_before/SCFC_eNB${enb_id}.xml
            ...    delta_scf_path=${delta_scf_path}/eNB${enb_id}_deltas.xml
            ${deltas}=    '${node_type}'=='enb'   Calculate Delta ENB    ${delta_scf_path}   ${enb_id}
    END

    IF   '${deltas}'=='None'    Log To Console  no differences found!


calculate delta enb
    [Arguments]  ${delta_scf_path}    ${enb_id}
    log to console with time    List of Differences between SCF file: ${\n}
    ${deltas}=    OperatingSystem.Get File    ${delta_scf_path}/eNB${enb_id}_deltas.xml
    log to console with time    ${deltas}
    RETURN    ${deltas}


calculate delta gnb
    [Arguments]  ${delta_scf_path}    ${gnb_id}
    log to console with time    List of Differences between SCF file: ${\n}
    ${deltas}=    OperatingSystem.Get File    ${delta_scf_path}/gNB${gnb_id}_deltas.xml
    log to console with time    ${deltas}
    RETURN    ${deltas}


ERR/WRN checking
    [Arguments]    ${target_dir}
    List of ERR/WRN based on black list    ${target_dir}


List of ERR/WRN based on black list
    [Arguments]    ${target_dir}=None
    ${warn_err}=    Check Syslog Pattern   ${BLACK_LIST}   ${target_dir}
#    IF  '${warn_err[0]}'=='True'    Split prints from syslog to items  ${warn_err[1]}


Split prints from syslog to items
    [Arguments]    ${data}
    @{all_new_errors_and_warnings}=   create list
    ${new_value}=    Split string   ${data}  \n
    FOR  ${item}  IN   @{new_value}
       ${alarm}=   Compare with white list and return new prints    ${item}
       ${status}=  Run Keyword And Ignore Error   Active alarm exist  ${alarm}
       IF  '${status[0]}'=='PASS'
            ${active_alarm}=    Set Variable   ${alarm}
            Append To List   ${all_new_errors_and_warnings}    ${active_alarm}
       END
    END
    ${amount_of_alarms}=    Get length  ${all_new_errors_and_warnings}
    ${err_wrn_length}=  IF   ${amount_of_alarms}>0   Check Alarm Data  ${all_new_errors_and_warnings}


Active alarm exist
   [Arguments]   ${alarm}
   Should End With   ${alarm}   ] active


Compare with white list and return new prints
    [Arguments]   ${element}
    FOR  ${item}  IN  @{WHITE_LIST}
       ${status}=   Run keyword and ignore error   Print err/wrn  ${element}   ${item}
       IF  '${status[0]}'=='PASS'   BREAK
    END
    RETURN   ${element}


Print err/wrn
   [Arguments]   ${element}  ${item}
   Should Not Contain  ${element}  ${item}


Check Alarm Data
    [Arguments]   ${all_new_errors_and_warnings}
    FOR  ${item}  IN   @{all_new_errors_and_warnings}
       ${formated_new_errors_and_warnings}=   Catenate  SEPARATOR=\n\n   ${formated_new_errors_and_warnings}    ${item}
    END
    set suite variable   ${WRN_ERR}   ${formated_new_errors_and_warnings}
#    Send Email with ERR/WRN RESULTS   ${TARGET_SW_VERSION_GNB}    ${TARGET_SW_VERSION_ENB}    # is this needed? check in future

    ${err_wrn_length}=  get length  ${WRN_ERR}
    ${err_wrn_msg}=  IF  ${err_wrn_length}>0  Catenate  ${ADDITIONAL_MESSAGE} ERR/WRN: \n${WRN_ERR}\n\n
    set suite variable   ${ADDITIONAL_MESSAGE}  ${err_wrn_msg}

    set suite variable  ${ERR_WRN_LENGTH}  ${err_wrn_length}
    IF  ${err_wrn_length}>0
        Set Suite Variable  ${TURN_OFF_ERR_WRN_CHECK_TEMPORARY}  ${True}
        Set Suite Variable  ${ERR_WRN_STATUS}  ${True}
    END


Log to console with time
    [Documentation]    :Author: Furkan Tombul
    ...   Keyword display,log output with time
    ...   Improvement in future - measure time for various test steps
    [Arguments]  ${output}
    @{time}=  Get Time  hour min sec  NOW
    ${time_now}=  Catenate  SEPARATOR=:  ${time}[0]  ${time}[1]  ${time}[2]
    Log  (${time_now}) ${output}  console=True


Execute shell command on gnb CU
    [Documentation]    :Author: Furkan Tombul
    ...    used for UUF Tests
    ...    connects to given CU and removes given file
    ...    **Example:**
    ...    | Execute shell command on CU    rm /ffs/run/config/hwf.bin.gz
    ...    :param gnb_id:    Id of gnb    [0.. ]  default=0
    ...    :param du_id:    Id of DU    [0.. ]  default=0
    ...    :param comu_id:    Id of Common Unit    [0..1]  default=0
    ...    :param shell_command    Command to send
    ...
    [Arguments]    ${gnb_id}=${0}    ${du_id}=${0}    ${comu_id}=${0}   ${shell_command}=${ls -la}
    ${comu_alias}=    connect.Connect to Node Common Unit    node_id=${gnb_id}    du_id=${du_id}    comu_id=${comu_id}
    ${output}=    ssh.execute    ${shell_command}    connection=${comu_alias}
    log to console    gnb-${gnb_id}:${shell_command}
    RETURN    ${output}


Execute shell command on enb CU
    [Documentation]    :Author: Furkan Tombul
    ...    used for UUF Tests
    ...    connects to given CU and removes given file
    ...    **Example:**
    ...    | Execute shell command on CU    rm /ffs/run/config/hwf.bin.gz
    ...
    ...    :param gnb_id:    Id of gnb    [0.. ]  default=0
    ...    :param comu_id:    Id of Common Unit    [0..1]  default=0
    ...
    [Arguments]    ${enb_id}=${0}    ${comu_id}=${0}   ${shell_command}=${ls -la}
    ${enb_alias}=   Set variable    enb${enb_id}
    ${comu_alias}=    connect.Connect to Node Common Unit   node_type=enb  node_id=${enb_id}    comu_id=${comu_id}
    log to console    enb-${enb_id}:${shell_command}
    ssh.execute    ${shell_command}    connection=${comu_alias}
### ToDo: to be done: close connection ?


Perform uboot downgrade procedure
    [Documentation]
    ...    used for UUF Tests
    ...    Script: https://gitlabe1.ext.net.nokia.com/boot_team/prepare-bts-firmware-before-tests/-/tree/master
    [Arguments]    ${enb_id}=99    ${gnb_id}=99
    #ToDo: Skip this part on non customer Testlines!!!
    Log To Console    ToDo: Skip this part on non customer Testlines!!!
    ${testpc_alias}=    Connect to this TestPC   enb_id=${enb_id}   gnb_id=${gnb_id}
    ssh.execute    command=${PREPARE_UBOOT}    connection=${testpc_alias}
    sleep   15s
    ssh.execute    command=${RUN_UBOOT}    connection=${testpc_alias}
    sleep   120s


Check Syslog Pattern
    [Arguments]    ${black_list}    ${target_dir}=None
    ${pattern}=   Catenate   SEPARATOR=\\\|    @{black_list}
    ${Syslog_path}=    Get extracted Syslog    target_dir=${target_dir}

    Log To Console    ${\n}Search for "${pattern}" inside SYSLOG.LOG using grep.
    run   cat ${Syslog_path} | grep -ie "${pattern}" > ${LOG_DIR}/${target_dir}/detected_spam.LOG

    ${file_size}=   Get File Size   ${LOG_DIR}/${target_dir}/detected_spam.LOG
    IF  ${file_size}==${0}   Log To Console    ${\n}No Errors found.
    ...   ELSE   Log To Console    ${\n}Some Errors are present.

    Log To Console    ${\n}Compare with white_list.
    ${detected_spam}=   OperatingSystem.Get File    ${LOG_DIR}/${target_dir}/detected_spam.LOG
    Split prints from syslog to items   ${detected_spam}


Get extracted Syslog
    [Arguments]    ${target_dir}=None
    run    ls -la ${LOG_DIR}/${target_dir}/
    run    gunzip -f ${LOG_DIR}/${target_dir}/syslog_files.tgz
    run    ls -la ${LOG_DIR}/${target_dir}/
    run    tar -xvf ${LOG_DIR}/${target_dir}/syslog_files.tar -C ${LOG_DIR}/${target_dir}/
    Log To Console    ${\n}Catenate multiple SYSLOG files to a single one for analysis.
    run    cat ${LOG_DIR}/${target_dir}/*.LOG >> ${LOG_DIR}/${target_dir}/SYSLOG.LOG
    run    ls -la ${LOG_DIR}/${target_dir}/
    RETURN    ${LOG_DIR}/${target_dir}/SYSLOG.LOG


Start the following gnb logs
    [Arguments]    ${gnb_id}=0
    Kill fsyslog process on PC    gnb_id=${gnb_id}
    ${gnb_logpath}=    btslog.Start Btslog
    Set Test Variable    ${gnb_logpath}


Start the following enb logs
    [Arguments]    ${enb_id}=0
    Kill fsyslog process on PC    enb_id=${enb_id}
    ${enb_logpath}=    Start Btslog Enb    ${enb_id}
    Set Test Variable    ${enb_logpath}


Kill fsyslog process on PC
    [Arguments]    ${enb_id}=99    ${gnb_id}=99
    ${testpc_alias}=    IF  ${enb_id}!=99    Connect to this TestPC  enb_id=${enb_id}
    ...    ELSE IF   ${gnb_id}!=99    Connect to this TestPC  gnb_id=${gnb_id}
    ssh.execute    command=pkill fsyslog    connection=${testpc_alias}
    ssh.execute    command=rm -rf /tmp/btslog2/*.LOG   connection=${testpc_alias}
    ssh.disconnect    connection=${testpc_alias}


Stop the following gnb logs
    ${gnb_syslog_files}=    Stop Btslog    target_dir=${LOG_DIR}
    Set Test Variable    ${gnb_syslog_files}
    log to console with time    checking ${gnb_logpath} for spam
    ERR/WRN checking    ${gnb_logpath}


Stop the following enb logs
    [Arguments]    ${enb_id}=1
    ${enb_syslog_files}=    Stop Btslog Enb    enb_id=${enb_id}    target_dir=${LOG_DIR}
    Set Test Variable    ${enb_logpath}
    log to console with time    checking ${enb_logpath} for spam
    ERR/WRN checking    ${enb_logpath}


Start Btslog Enb
    [Documentation]    :Author: Soenke Kullberg
    ...    :Editor: Furkan Tombul
    ...    KW starts Btslog on Testpc with log-collector
    ...
    ...    https://confluence.int.net.nokia.com/display/EE/EE+BTSlog
    ...
    ...    *Note:* KW works only on ute-vm
    ...    *Edit*
    ...    Changes in init file is needed to make this keyword support multiple test_pcs
    [Arguments]    ${enb_id}=0
    Connect to Node Common Unit     node_type=enb   node_id=${enb_id}
    ${enb_test_pc}=    Get Test PC for NodeB   ${tl}    ${tl.enbs[${enb_id}]}
    ${enb_btslog_collector_name}=   Set Variable    btslog_enb${enb_id}
    ${testpc_ssh_config}=  Create Dictionary
    ...    host=${enb_test_pc.default_ssh_connection_details.addr}
    ...    user=${enb_test_pc.default_ssh_connection_details.username}
    ...    password=${enb_test_pc.default_ssh_connection_details.password}
    log to console  ${testpc_ssh_config}
    #
    #   WA until Collectors take PID...
    #
    ssh.Connect_to    hostname=${enb_test_pc.default_ssh_connection_details.addr}
    ...    username=${enb_test_pc.default_ssh_connection_details.username}
    ...    password=${enb_test_pc.default_ssh_connection_details.password}
    ...    alias=vm_enb${enb_id}
    ssh.send_command  command=pkill btslog  connection=vm_enb${enb_id}
    #
    #    END WA
    #
    btslog.create_btslog_collector
    ...    name=${enb_btslog_collector_name}
    ...    executor=${testpc_ssh_config}
    btslog.setup_collectors    names=${enb_btslog_collector_name}
    btslog.start_collectors    names=${enb_btslog_collector_name}
    btslog.set_suite_alias    ${enb_btslog_collector_name}
    RETURN  ${enb_btslog_collector_name}


Stop Btslog Enb
    [Documentation]    :Author: Soenke Kullberg
    ...    :Editor: Furkan Tombul
    ...    Stop and fetch btslog from Testpc
    ...
    ...    *Note:* KW works only on ute-vm
    ...    :return path: Path to btslog file
    ...
    ...    :param target_dir: Directory to store the btslog file
    ...    *Edit*
    ...    Changes in init file is needed to make this keyword support multiple test_pcs
    [Arguments]    ${enb_id}=0    ${target_dir}=None
    Connect to Node Common Unit     node_type=enb   node_id=${enb_id}
    ${enb_test_pc}=    Get Test PC for NodeB   ${tl}    ${tl.enbs[${enb_id}]}
    ${enb_btslog_collector_name}=   Set Variable    btslog_enb${enb_id}
    IF    '${target_dir}'=='None'
        ${target_dir}=    testline.Get Testcase Log Directory
    END
    ${enb_btslog_collector_name}=   Set Variable    btslog_enb${enb_id}
    btslog.stop_collectors    names=${enb_btslog_collector_name}
    # WA for https://jira3.int.net.nokia.com/browse/TALIB-854
    Sleep   15 sec    # wait for btslog to close
    # WA for https://jira3.int.net.nokia.com/browse/TALIB-854
    btslog.collect_collectors    names=${enb_btslog_collector_name}   target_dir=${target_dir}
    btslog.teardown_collectors    names=${enb_btslog_collector_name}
    RETURN    ${enb_btslog_collector_name}


Connect to this TestPC
    [Documentation]   :Author: Furkan Tombul
    ...    Setup ssh connection to Test PC and returns connection handle/alias
    ...    Usage:
    ...    | Connect to this TestPC    enb_id=0
    ...
    [Arguments]    ${enb_id}=99    ${gnb_id}=99
    ${alias}=   IF    ${enb_id}!=99   Connect to test pc proxy for node    node_id=${enb_id}  node_type=enb
    ...   ELSE IF   ${gnb_id}!=99   Connect to test pc proxy for node    node_id=${gnb_id}
    RETURN    ${alias}


Connect to eNB TestPC
    [Documentation]   :Author: Furkan Tombul
    ...    Setup ssh connection to Test PC and returns connection handle/alias
    ...    TO BE DELETED
    ...    | Connect to enb TestPC    enb_id=0
    ...
    [Arguments]    ${enb_id}=0
    Connect to Node Common Unit     node_type=enb   node_id=${enb_id}
    ${enb_test_pc}=    Get Test PC for NodeB   ${tl}    ${tl.enbs[${enb_id}]}
    ${enb_btslog_collector_name}=   Set Variable    btslog_enb${enb_id}
    ssh.Connect_to    hostname=${enb_test_pc.default_ssh_connection_details.addr}
    ...    username=${enb_test_pc.default_ssh_connection_details.username}
    ...    password=${enb_test_pc.default_ssh_connection_details.password}
    ...    alias=vm_enb${enb_id}
    log to console  ${testpc_ssh_config}
    RETURN   ${testpc_ssh_config}


append to log directory
    [Arguments]    ${log_path}
    ${LOG_DIR}=   Get testcase log directory
    ${LOG_DIR}=    Catenate    SEPARATOR=/    ${LOG_DIR}   ${log_path}
    Set Test variable    ${LOG_DIR}
    RETURN    ${LOG_DIR}


UUF Software Upgrade procedure gnb
    [Documentation]    Software Upgrade procedure for UUF tests
    ...    Checks if customer Software is installed - if yes start Target software installation
    ...    Tests are splitted to gnb to provide multi processing and also to lower log sizes
    ${gnb_num}=    Get length    ${tl.gnbs}
    Set Test variable    ${gnb_num}
    @{GNB_SW_UPDATE_NODE_LIST}=	  Split String   ${GNB_SW_UPDATE_NODES}    ,
    Set Test variable    @{GNB_SW_UPDATE_NODE_LIST}
    Log To Console   Check if ${CUSTOMER_SW_VERSION_GNB} is installed on gNB.${\n}
    Log To Console   The Target gNB SW is:"${TARGET_SW_VERSION_GNB}".${\n}
    FOR   ${gnb_node_name}   IN    @{GNB_SW_UPDATE_NODE_LIST}
       ${gnb_id}=  gNB update Check   ${gnb_node_name}    ${CUSTOMER_SW_VERSION_GNB}
       IF   '${software_check}'=='equal_sw'    uboot downgrade and upgrade procedure   ${gnb_node_name}
       ...   ELSE   log to console   !!!!! uboot downgrade and software upgrade not executed !!!!!
    END


uboot downgrade and upgrade procedure
   [Arguments]   ${gnb_node_name}
   ${gnb_id}=  gNB update Check   ${gnb_node_name}    ${CUSTOMER_SW_VERSION_GNB}
   Perform uboot downgrade procedure   gnb_id=${gnb_id}
   perform gNB sw update    gnb_id=${gnb_id}   load_init=false
   Log To Console    ${\n}gNB-${gnb_id} Sw updated successfully


UUF Software Upgrade procedure enb
    [Documentation]    Software Upgrade procedure for UUF tests
    ...    Checks if customer Software is installed - if yes start Target software installation
    ...    Tests are splitted to gnb to provide multi processing and also to lower log sizes
    ${enb_num}=    Get length    ${tl.enbs}
    Set Test variable    ${enb_num}
    @{ENB_SW_UPDATE_NODE_LIST}=	  Split String   ${ENB_SW_UPDATE_NODES}    ,
    Set Test variable    @{ENB_SW_UPDATE_NODE_LIST}
    Log To Console   Check if ${CUSTOMER_SW_VERSION_ENB} is installed on eNB.${\n}
    Log To Console   The Target eNB SW is:"${TARGET_SW_VERSION_ENB}".${\n}
    FOR   ${enb_node_name}   IN    @{ENB_SW_UPDATE_NODE_LIST}
       ${enb_id}=  SBTS update Check   ${enb_node_name}    ${CUSTOMER_SW_VERSION_ENB}
       IF   '${software_check}'=='equal_sw'   Perform uboot downgrade procedure    enb_id=${enb_id}
       gnb.Wait Until Node To Be Onair State   node_type=enb   node_id=${enb_id}    timeout=900 sec    retry_interval=60 sec
       Sleep   300 sec
       perform eNB sw update    enb_id=${enb_id}    load_init=false
       IF   '${software_check}'=='equal_sw'   log to console   ${\n}eNB-${enb_id} Sw updated successfully
    END


UUF Rollback to customer Software
    ${enb_num}=    Get length    ${tl.enbs}
    ${gnb_num}=    Get length    ${tl.gnbs}
    Set Test variable    ${enb_num}
    Set Test variable    ${gnb_num}
    @{ENB_SW_UPDATE_NODE_LIST}=	  Split String   ${ENB_SW_UPDATE_NODES}    ,
    @{GNB_SW_UPDATE_NODE_LIST}=	  Split String   ${GNB_SW_UPDATE_NODES}    ,
    Set Test variable    @{ENB_SW_UPDATE_NODE_LIST}
    Set Test variable    @{GNB_SW_UPDATE_NODE_LIST}
    FOR   ${enb_node_name}   IN    @{ENB_SW_UPDATE_NODE_LIST}
       log to console  in enb loop
       ${enb_id}=  SBTS update Check   ${enb_node_name}    ${TARGET_SW_VERSION_ENB}
       IF   '${software_check}'=='equal_sw'
       ...    Check passive software enb and fallback  ${CUSTOMER_SW_VERSION_ENB}   ${enb_id}
       Log to console    \neNB-${enb_id} Sw rollback done
    END
    FOR   ${gnb_node_name}   IN    @{GNB_SW_UPDATE_NODE_LIST}
       ${gnb_id}=  gNB update Check   ${gnb_node_name}    ${TARGET_SW_VERSION_GNB}
       IF   '${software_check}'=='equal_sw'
       ...    Check passive software gnb and fallback  ${CUSTOMER_SW_VERSION_GNB}   ${gnb_id}
       Log to console    \ngNB-${gnb_id} Sw rollback done
    END


SBTS update Check
    [Arguments]    ${enb_node_name}    ${Customer_software}
    log to console    SBTS update Check
    ${enb_id}=    Fetch from right   ${enb_node_name}   -
    ${current_eNB_sw}=    testline.Get eNB SW Version    ${enb_id}
    ${current_eNB_sw_load}=    Fetch from right    ${current_eNB_sw}    NB_
    ${same_software}=    Run Keyword And Return Status  Should Contain  ${Customer_software}   ${current_eNB_sw_load}
    IF    '${same_software}'=='${True}'    set suite variable  ${software_check}    equal_sw
    ...    ELSE IF    '${same_software}'=='${False}'    set suite variable  ${software_check}    different
    RETURN    ${enb_id}


gNB update Check
    [Arguments]    ${gnb_node_name}    ${Customer_software}
    Log To Console    gNB Update Check...
    ${gnb_id}=    Fetch from right   ${gnb_node_name}   -
    ${current_gNB_sw}=    testline.Fetch Current gNB SW Version    ${gnb_id}
    ${current_gNB_sw_load}=    Fetch from right    ${current_gNB_sw}    NB_
    ${same_software}=    Run Keyword And Return Status  Should Contain  ${Customer_software}   ${current_gNB_sw_load}
    IF    '${same_software}'=='${True}'    set suite variable  ${software_check}    equal_sw
    ...    ELSE IF    '${same_software}'=='${False}'    set suite variable  ${software_check}    different
    RETURN    ${gnb_id}


Check passive software gnb and fallback
    [Arguments]   ${gnb_software}    ${gnb_id}=0
    log to console    check passive software gnb and fallback
    ${alias}=   Connect to Node Common Unit    node_id=${gnb_id}
    log to console    connected to CU and fallback if passive software equals   ${gnb_software}
    ${passive_load}=    Fetch from right    ${gnb_software}  NB_
    ${output}=    ssh.execute    ls /ffs/stb | grep ${passive_load} | head -1    connection=${alias}
    Should Contain  ${output}   ${passive_load}
    ${active_software}=    testline.Fetch Current gNB SW Version    gnb_id=${gnb_id}
    Should Not Contain  ${active_software}   ${passive_load}
    gnb SW rollback  gnb_id=${gnb_id}
    snapshot.Collect snapshot from gNB   ${LOG_DIR}  ${gnb_id}
    ${new_active_software}=    testline.Fetch Current gNB SW Version    gnb_id=${gnb_id}
    Should Contain  ${new_active_software}   ${passive_load}


Check passive software enb and fallback
    [Arguments]   ${enb_software}    ${enb_id}=0
    log to console    check passive software enb and fallback
    ${alias}=   Connect to Node Common Unit     node_type=enb   node_id=${enb_id}
    log to console    connected to CU and fallback if passive software equals ${enb_software}
    ${passive_load}=    Fetch from right    ${enb_software}  NB_
    ${output}=    ssh.execute    ls /ffs/stb | grep ${passive_load} | head -1    connection=${alias}
    Should Contain  ${output}   ${passive_load}
    ${active_software}=    testline.Get eNB SW version    enb_id=${enb_id}
    Should Not Contain  ${active_software}   ${passive_load}
    enb SW rollback  enb_id=${enb_id}
    ${new_active_software}=    testline.Get eNB SW version    enb_id=${enb_id}
    Should Contain   ${new_active_software}   ${passive_load}


gnb SW rollback
    [Arguments]    ${gnb_id}=0
    Log To Console  Start gNB Fallback.
    Log To Console  Setup connection to gNB.
    ${oam_alias}  connect.Setup OAM http session  node_id=${gnb_id}  node_type=gnb
    Log To Console  Perform SW rollback
    admin.rollback_software    timeout=900    connection=${oam_alias}
    Sleep   120 sec
    gnb.Wait Until Node To Be Onair State   node_id=${gnb_id}    retry_interval=60 sec
    [Teardown]  Run Keyword and Ignore Error    admin.teardown    connection=${oam_alias}


enb SW rollback
    [Arguments]    ${enb_id}=0
    Log To Console  Start eNB Rollback.

    Log To Console  ${\n}Wait till "Radio slave has taken temporary radio master role" alarm is cleared.
    gnb.Wait until node to be onair state  node_type=enb    node_id=${enb_id}
    Wait Until Keyword Succeeds  5 min  10 sec    Run Keyword And Expect Error  *does not contain '7116'*
    ...    Check faultId in Node active alarm list    expected_fault_number=7116    node_type=enb    node_id=${enb_id}

    Log To Console  Setup connection to eNB.
    ${oam_alias_for_Rollback}  connect.Setup OAM http session  node_id=${enb_id}  node_type=enb
    Log To Console  Perform SW Rollback.
    admin.rollback_software    timeout=900    connection=${oam_alias_for_Rollback}    detailed_output=${True}

    Log To Console  ${\n}Wait the eNB to "Start" Rollback (PING should be not answered.)...
    ${should be not answered}    Run Keyword And Ignore Error   Wait Until Ping Failed
    ...    ip_addr=${tl.enbs[${enb_id}].oam_ip.v4}  iterations=${10}  ping_count=${30}   ping_deadline=${40}
    IF    '${should be not answered[0]}' == 'FAIL'    Fail    ${\n}eNB Still pingable. Rollback not executed.
    ...    ELSE    Log To Console    ${\n}Rollback in progress...

    Log To Console  ${\n}Wait the PING from eNB...
    FOR     ${iter}     IN RANGE    ${10}
        ${rc}=    Run and return rc    ping ${tl.enbs[${enb_id}].oam_ip.v4} -c 30 -w 40
        IF    ${rc}==${0}      BREAK
        IF    '${iter}' == '${9}'    Fail    ${\n}eNB (PING) not ready.
    END

    Run Keyword and Ignore Error    admin.teardown    connection=${oam_alias_for_Rollback}

    Log To Console  ${\n}Wait the eNB to be available to connect after Rollback.
    gnb.Wait Until Node To Be Onair State   node_type=enb   node_id=${enb_id}    retry_interval=60 sec
    [Teardown]  Run Keyword and Ignore Error    teardown_all_aliases_for_admin


Delete HWF and RESET eNB
    ${delete_hwf}=    set variable    rm -rf /ffs/run/config/hwf.bin.gz
    ${enb_num}=    Get length    ${tl.enbs}
    Set Test variable    ${enb_num}
    @{ENB_SW_UPDATE_NODE_LIST}=	  Split String   ${ENB_SW_UPDATE_NODES}    ,
    Set Test variable    @{ENB_SW_UPDATE_NODE_LIST}
    FOR   ${enb_node_name}   IN    @{ENB_SW_UPDATE_NODE_LIST}
       ${enb_id}=    Fetch from right   ${enb_node_name}   -
       Copy UUF Swconfig from lv1 To eNB    enb_id=${enb_id}
       Execute shell command on enb CU    enb_id=${enb_id}    shell_command=${delete_hwf}
       Sleep  2Sec
       Reset Node  node_type=enb   node_id=${enb_id}
    END

    Log To Console  ${\n}Wait the PING from eNB...
    FOR     ${iter}     IN RANGE    ${15}
        ${rc}=    Run and return rc    ping ${tl.enbs[${enb_id}].oam_ip.v4} -c 30 -w 40
        IF    ${rc}==${0}   BREAK
        IF    '${iter}' == '${9}'
            Log    The eNB PING is taking longer than usual.     WARN    console=${P_console}
        ELSE IF    '${iter}' == '${14}'
            Fail    ${\n}eNB not ready.(PING)
        END
    END

    gnb.Wait Until Node To Be Onair State   node_type=enb   node_id=${enb_id}    timeout=900 sec    retry_interval=60 sec


Delete HWF and RESET gNB
    ${delete_hwf}=    set variable    rm -rf /ffs/run/config/hwf.bin.gz
    ${gnb_num}=    Get length    ${tl.gnbs}
    Set Test variable    ${gnb_num}
    @{GNB_SW_UPDATE_NODE_LIST}=	  Split String   ${GNB_SW_UPDATE_NODES}    ,
    Set Test variable    @{GNB_SW_UPDATE_NODE_LIST}
    FOR   ${gnb_node_name}   IN    @{GNB_SW_UPDATE_NODE_LIST}
       ${gnb_id}=    Fetch from right   ${gnb_node_name}   -
       Copy UUF Swconfig from lv1 To gNB    gnb_id=${gnb_id}
       Execute shell command on gnb CU    gnb_id=${gnb_id}    shell_command=${delete_hwf}
       Sleep  2sec
       gnb.Reset Node    node_type=gnb    node_id=${gnb_id}
    END
    gnb.Wait Until Node To Be Onair State    node_id=${gnb_id}    retry_interval=60 sec


Copy UUF Swconfig from lv1 To gNB
    [Documentation]    copy swconfig based on TL from entity-tools for gNB nodes
    [Arguments]    ${gnb_id}=0    ${side}=active
    ${init_gnb_scf_path}=    syve_testline.Get GNB initial config path    gnb_id=${gnb_id}
    ${gnb_path}=    Fetch from left   ${init_gnb_scf_path}   /scf.xml
    ${gnb_add}    set variable    ${tl.gnbs[${gnb_id}].dus[${0}].airscale.common_units[${0}].lmp_connection.addr}
    ${gnb_user}    set variable    ${tl.gnbs[${gnb_id}].dus[${0}].airscale.common_units[${0}].lmp_connection.username}
    ${gnb_pass}    set variable    ${tl.gnbs[${gnb_id}].dus[${0}].airscale.common_units[${0}].lmp_connection.password}
    IF    '${side}'=='active'
    ...    OperatingSystem.Run   sshpass -p ${gnb_pass} scp ${gnb_path}/swconfig_UUF_hwf.txt ${gnb_user}@${gnb_add}:/ffs/run
    ...    ELSE    OperatingSystem.Run   sshpass -p ${gnb_pass} scp ${gnb_path}/swconfig_UUF_hwf.txt ${gnb_user}@${gnb_add}:/ffs/stb


Copy UUF Swconfig from lv1 To eNB
    [Documentation]    copy swconfig based on TL from entity-tools for gNB nodes
    [Arguments]    ${enb_id}=0    ${side}=active
    ${init_enb_scf_path}=    syve_testline.Get ENB initial config path    enb_id=${enb_id}
    ${enb_path}=    Fetch from left   ${init_enb_scf_path}   /scf.xml
    ${enb_add}    set variable    ${tl.enbs[${enb_id}].system_module.common_units[${0}].lmp_connection.addr}
    ${enb_user}    set variable    ${tl.enbs[${enb_id}].system_module.common_units[${0}].lmp_connection.username}
    ${enb_pass}    set variable    ${tl.enbs[${enb_id}].system_module.common_units[${0}].lmp_connection.password}
    IF    '${side}'=='active'
    ...    OperatingSystem.Run    sshpass -p ${enb_pass} scp ${enb_path}/swconfig_UUF_hwf.txt ${enb_user}@${enb_add}:/ffs/run
    ...    ELSE    OperatingSystem.Run    sshpass -p ${enb_pass} scp ${enb_path}/swconfig_UUF_hwf.txt ${enb_user}@${enb_add}:/ffs/stb


Get SCF and Validate Plan
    [Documentation]    :Author: Michele
    ...    Use for Getting the Running SCF, Connect OaM and Check for NIDD validation succeeded.
    ...    Connection is closed at the end.
    [Arguments]    ${gnb_id}=0
    Log To Console    ${\n}SCF Validate Plan: NIDD validation for gNB=${gnb_id}
    ${scf_file}=    gnb.Get SCF from gNB    gnb_id=${gnb_id}    target_dir=${LOG_DIR}/gnb${gnb_id}_actual_scf
    ${oam_alias}  connect.Setup OAM http session  node_id=${gnb_id}  node_type=gnb
    admin.validate_scf    scf_file=${scf_file}    timeout=900    connection=${oam_alias}
    [Teardown]  Run Keyword and Ignore Error    admin.teardown    connection=${oam_alias}
