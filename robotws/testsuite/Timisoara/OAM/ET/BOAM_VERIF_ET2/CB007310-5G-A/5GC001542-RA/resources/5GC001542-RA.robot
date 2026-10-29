*** Settings ***
Documentation
...    Author: Ioana-Andreea Sandu-Andrei (ioana.sandu-andrei@nokia.com)
...    Maintainer: Izabela Muntean (izabela.muntean@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:5GC000507


Library        SSHLibrary
Library        String
Library        Telnet
Library        OperatingSystem
Library        Process
Library        taf.transport.ssh   WITH NAME   csn



Resource    ../../../resources/admin.robot
Resource   ../../../resources/admin_infomodel.robot
Resource    ../../../resources/pretest_posttest.robot
Resource    ../../../resources/system.robot



*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          False
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True

${LSS_addr}                     10.5.25.106
${LSS_username}                 coam
${LSS_password}                 zO&n1W*ktp7
${SYSTEM_ENB_TRANSPORT_IP}=    192.168.255.129
${SYSTEM_ENB_SSH_USERNAME}=    toor4nsn
${SYSTEM_ENB_SSH_PASSWORD}=    oZPS0POrRieRtu
${reasoning_path}=            /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/RMOD_L-1/RU_L-1
${SW_DESTINATION}     /home/ute
${scf_path}             /tmp/
${scf_name}             scf_file.xml


${delta_LSS_4663_onFaultDet_activate}=       ${CURDIR}/Delta_LSS_4663_onFaultDet_activate.json
${delta_LSS_2087_onFaultDet_activate}=       ${CURDIR}/Delta_LSS_2087_onFaultDet_activate.json
${delta_LSS_onFaultDet_deactivate}=         ${CURDIR}/Delta_LSS_onFaultDet_deactivate.json

${BTS_metadata}=                BTS1_*_metadata.txt

*** Keywords ***

5GC001542_RA_Fault_triggered_automatic_snapshot_to_remote_LSS_via_sftp_when_fault_is_detected_in_BTS
    Remove Snapshot from LSS server
    ADMIN Perform Delta Recommissioning        delta_file=${delta_LSS_2087_onFaultDet_activate}
    ...                                        skip_parameter_relation_errors=True
    ...                                        should_activate=True
    ...                                        timeout=300
    Kill process 'HWRTimeSExe' on BBMOD
    wait until keyword succeeds  600  60  Check if Snapshot is collected on LSS
    Remove Snapshot from LSS server
    sleep  100
    BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Wait Until BTS OnAir


Check if Snapshot is collected on LSS
    Set Suite Variable    ${snapshot_LSS}    Snapshot_MRBTS-10009_${OUT_ADMIN_BTS_NAME}
    csn.connect to    ${LSS_addr}    ${LSS_username}    ${LSS_password}    alias=LSS
    sleep    2s
    csn.send_command    command=ls -l /opt/coam/   connection=LSS
    ${snap_exists}    csn.read output    connection=LSS
    Should contain  ${snap_exists}  ${snapshot_LSS}  connection=LSS
    csn.send_command    command=find ${snapshot_LSS}* | wc -l   connection=LSS
    ${snap_list}    csn.read output    connection=LSS
    ${snap_list}    convert to integer  ${snap_list}
    should be true      ${snap_list}>=7
    csn.disconnect    connection=LSS

Kill process '${process_name}' on BBMOD
    SYSTEM Open SSH Connection To Enb for BBMOD
    SSHLibrary.Write            bsh 2:0
    SSHLibrary.Read Until       :~ >
    SSHLibrary.Write    ps -ef | grep -i "${process_name}" | egrep -v "grep|bash" | awk '{print $2}'
    ${process_pid}=   SSHLibrary.Read Until    expected=>
    SSHLibrary.Write    kill -9 ${process_pid}
    SSHLibrary.Read Until    expected=>
    SSHLibrary.Close Connection

Remove Snapshot from LSS server
    Set Suite Variable    ${snapshot_path_LSS}    /opt/coam/Snapshot_MRBTS-10009_${OUT_ADMIN_BTS_NAME}*
    csn.connect to    ${LSS_addr}    ${LSS_username}    ${LSS_password}    alias=LSS
    sleep    2s
    csn.send_command    command=rm -rf ${snapshot_path_LSS}  connection=LSS
    csn.disconnect    connection=LSS


Kill process '${process_name}' on FCT
#    setup enb fsm access
    ${process_pid}=   execute command on enb    ps -ef | grep -i "${process_name}" | egrep -v "grep|bash" | awk '{print $2}'
    execute command on enb   kill -11 ${process_pid}
#    teardown enb fsm access

Check active fault 6450
    Run Keyword And Continue On Failure  ute_admin_infomodel.Query infomodel  query=${alarm_path} is [faultId=${fault_id_6450}]   timeout=300

Wait for Site is pingable
	Wait Until Host Is Available    192.168.255.1      timeout=300
	Log To Console		The site is pingable


UTE TL Preparation
    [Documentation]  Keyword used for setting up local 5G TLs to onAir state, as UTE reserve it only to sw_upload state
    #TO DO:             Add Check for onAir State. For cases when the Suite is run more than one time
    PREPOST Setup Admin
    ADMIN Change R&D Port Status    status=True
    @{status}   Run Keyword and Ignore Error    ADMIN Check BTS onair
    Run Keyword If  '@{status}[0]' == 'FAIL'   Run Keyword  5GC001542-RA.Configured_SwDownload_SwUpdate_OnAir
    ...     ELSE    Log To Console  --- BTS already onAir ---
    ADMIN Teardown Admin

Configured_SwDownload_SwUpdate_OnAir
    ADMIN Check BTS Not Commisioned
    Get TL Hostname
    Get Software Release
    ADMIN Perform Commissioning
    ...   scf_file=/home/ute/MN/UTE/robotws/custom-config/Timisoara/${tl_hostname}/${sw_release}/${tl_hostname}_SCF.xml
    ${configured}   Run Keyword and Return Status
    ...    BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Check BTS Configured
    Run Keyword If  '${configured}' == 'True'  Sleep  180
    Run Keyword Unless   ${configured}   Run Keywords   admin.ADMIN Reset Site
    ...    AND     BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Check BTS Configured
    ...    AND     Sleep  180
    Log To Console  Fault ID23 Checking...
    ${result}   Run Keyword and Return Status    ADMIN Check If Alarm Is Active  fault_id=23
    BuiltIn.Run Keyword If  '${result}' == 'True'   Run Keywords
    ...    Log To Console  Fault ID23 found. Start RF Software Update
    ...     AND     ADMIN Download And Update Current Software
    ...     ELSE    Log To Console  Fault ID23 not found.
    ${onair}   Run Keyword and Return Status
    ...    BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Wait Until BTS OnAir
    Run Keyword Unless   ${onair}   Run Keywords   admin.ADMIN Reset Site
    ...    AND     BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Wait Until BTS OnAir


SYSTEM Open SSH Connection
    [Arguments]    ${host}    ${port}    ${username}    ${password}    ${alias}
    SSHLibrary.Open Connection    host=${host}    port=${port}    timeout=60    alias=${alias}
    SSHLibrary.Login    username=${username}    password=${password}    delay=1s

SYSTEM Close SSH Connection
    [Arguments]    ${alias}
    SSHLibrary.Switch Connection    index_or_alias=${alias}
    SSHLibrary.Close Connection

SYSTEM Open SSH Connection To Enb for BBMOD
    SYSTEM Open SSH Connection    host=${SYSTEM_ENB_TRANSPORT_IP}
    ...                           port=22
    ...                           username=${SYSTEM_ENB_SSH_USERNAME}
    ...                           password=${SYSTEM_ENB_SSH_PASSWORD}
    ...                           alias=ssh_enb
