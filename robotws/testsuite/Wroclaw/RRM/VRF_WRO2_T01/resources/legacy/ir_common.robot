*** Settings ***
Documentation
...  author:        Mateusz Cieciura
...  contact:       mateusz.cieciura@nokia.com
...  maintainer:    mateusz.cieciura@nokia.com
...  description:   Common KWs for IR suites

Library   taf.sbts.oam.coam.admin                                               WITH NAME  coam
Library   taf.transport.ssh                                                     WITH NAME  ssh
Library   testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/ir_common.py      WITH NAME  ircomm
Library   testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common.py
Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/setup_teardown.robot
Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot

*** Keywords ***
Start log collecting and wait for FID
    ssh.Connect to    ${SMOD_IP}  ${SMOD_LOGIN}  ${SMOD_PASS}  alias=${SSH_ALIAS}
    ssh.Send Command  ${KILL_JOBS}     connection=${SSH_ALIAS}
    ssh.Send Command  ${REMOVE_FILES}  connection=${SSH_ALIAS}
    sleep  1s
    ssh.Send Command  ${COMMAND}       connection=${SSH_ALIAS}
    repeat keyword     ${FID_CHECKS} times  FID check in journal TC

FID check in journal TC
    ${alarms}      coam.get alarms  connection=${ALIAS}
    ${fid_active}  check fault id  ${ALARMS}  ${FID}
    Run keyword if  ${fid_active}==${True}  Collect logs from smod
    sleep  ${FID_CHECKS_INTERVAL}

Collect logs from smod
    ssh.download file  ${PS_FILE}       /home/ute/ps.txt          connection=${SSH_ALIAS}
    sleep  5s
    ssh.download file  ${JOURNAL_FILE}  /home/ute/journalctl.txt  connection=${SSH_ALIAS}
    sleep  5s
    ssh.Send Command   ${KILL_JOBS}     connection=${SSH_ALIAS}
    ssh.Send Command   ${REMOVE_FILES}  connection=${SSH_ALIAS}
    sleep  5s
    Fail  msg=FID: ${FID} has been raised!

Power reset
    ircomm.reset_target_rmod  ${PDU_IP}  ${PDU_SLOT}

Soft reset
    coam.reset_unit  dist_name=${RMOD}  timeout=400s  connection=${ALIAS}  reset_type=Soft

Verify operational state
    [Arguments]    ${duration}=900 sec    ${interval}=10 sec
    Wait until keyword succeeds    ${duration}    ${interval}    Check operational state

Check operational state
    ${rmods_objs}        coam.get_managed_objects  class_name=RMOD_R  connection=${ALIAS}
    ${rmod_obj}          ircomm.get_dictionary_from_list  ${rmods_objs}  ${RMOD_SERIAL_NO}
    ${operationalState}  Set variable  ${rmod_obj['parameters']['operationalState']}
    Should be True       '${operationalState}'=='enabled'

FID check
    ${alarms}  coam.get alarms  connection=${ALIAS}
    FOR  ${fid}  IN  @{FIDS}
      Set Test Variable  ${fid}
      ${fid_active}   check fault id  ${alarms}  ${fid}
      Run keyword if  ${fid_active}==${True}  Collect snap and fail test
    END
    sleep  ${FID_CHECKS_INTERVAL}

Collect snap and fail test
    setup_teardown.Collect Snapshot
    Fail  msg=FID: ${fid} has been raised!

# TODO: KWs for LMI TCs
Set Rmod ID
    ${rmods}  coam.get_id_for_current  RMOD   timeout=30s  connection=${ALIAS}
    ${rmod}   ircomm.rmod_filter  ${rmods}  ${RMOD_ID}
    Set Test Variable  ${rmod}

FID check LMI
    ${alarms}      coam.get alarms  connection=${ALIAS}
    ${fid_active}  check fault id  ${alarms}  ${FID}
    Run keyword if  ${fid_active}==${True}  Collect logs from UEPC
    sleep  ${FID_CHECKS_INTERVAL}

Collect logs from UEPC
    Log to console  FID ${FID} did occur.
    Stop and download serial logs from UEPC
    Fail  msg=FID: ${FID} has been raised!

Connect to UEPC
    ${uepc_ip}  ${uepc_login}  ${uepc_password}  Get connection to UEPC
    ssh.Connect to  ${uepc_ip}  ${uepc_login}  ${uepc_password}  alias=${UEPC_ALIAS}

Send script to UEPC
    [Arguments]  ${local}=testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/IRs/lmi_board_scripts/uepc_serial_logger.py
    ...          ${remote}=/cygdrive/c/auto/serial_logger
    ${cmd}  Set Variable  mkdir -p ${remote}
    ssh.Send Command  ${cmd}  connection=${UEPC_ALIAS}
    sleep  5s
    ${cmd}  Set Variable  touch ${remote}/serial_logger.py
    ssh.Send Command  ${cmd}  connection=${UEPC_ALIAS}
    sleep  5s
    ssh.upload file  ${local}  ${remote}/serial_logger.py  connection=${UEPC_ALIAS}
    sleep  5s

Start serial log collection on UEPC
    ${cmd}=  catenate  SEPARATOR=
    ...      cd /cygdrive/c/auto/serial_logger;
    ...      python serial_logger.py ${PORT} ${BAUD} ${RMOD_LOGIN} ${RMOD_PASSWORD} ${COMPONENT_ENTRY} ${iter}
    ssh.Send Command  ${cmd}  connection=${UEPC_ALIAS}
    sleep  5s

Stop and download serial logs from UEPC
    ${remote}  Set Variable  /cygdrive/c/auto/serial_logger/serial_log_iteration_${iter}.log
    ${local}   Set Variable  ${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/serial_log_iteration_${iter}.log
    ${cmd}     Set Variable  touch /cygdrive/c/auto/serial_logger/stop_log_collection.txt
    ssh.Send Command  ${cmd}  connection=${UEPC_ALIAS}
    sleep  5s
    Run  touch ${local}
    ssh.download file  ${remote}  ${local}  connection=${UEPC_ALIAS}
    sleep  5s
#    ${cmd}  Set Variable  rm -rf /cygdrive/c/auto/serial_logger/serial_logger_${iteration}.txt
#    ssh.Send Command    ${cmd}    connection=${UEPC_ALIAS}
    ${cmd}  Set Variable  rm -rf /cygdrive/c/auto/serial_logger/stop_log_collection.txt
    ssh.Send Command    ${cmd}    connection=${UEPC_ALIAS}
    sleep  5s
