*** Settings ***
Documentation
...    Author: Ioana-Andreea Sandu-Andrei (ioana.sandu-andrei@nokia.com)
...    Maintainer: Izabela Muntean (izabela.muntean@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:5GC0001542-CA


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
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True

${SW_DESTINATION}     /home/ute
${SYSTEM_ENB_TRANSPORT_IP}=    192.168.255.129
${SYSTEM_ENB_SSH_USERNAME}=    toor4nsn
${SYSTEM_ENB_SSH_PASSWORD}=    oZPS0POrRieRtu
${LSS_addr}                     10.5.25.106
${LSS_username}                 coam
${LSS_password}                 zO&n1W*ktp7

${reasoning_path}=            /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/RMOD_L-1/RU_L-1

${scf_path}             /tmp/
${scf_name}             scf_file.xml


#${delta_LSS_10_onFaultDet_activate}=          ${CURDIR}/../Delta_LSS_10_onFaultDet_activate.json
#${delta_LSS_6450_onFaultDet_activate}=       ${CURDIR}/../resources/Delta_LSS_6450_onFaultDet_activate.json
${delta_LSS_10_onFaultDet_activate}=       ${CURDIR}/Delta_LSS_10_onFaultDet_activate.json
${delta_LSS_onFaultDet_deactivate}=         ${CURDIR}/../resources/Delta_LSS_onFaultDet_deactivate.json

${BTS_metadata}=                BTS1_*_metadata.txt
${rf_user}                  serviceuser
${rf_password}              Pl(FzaYj5~c5;q

*** Keywords ***

5G1526_TA_Snapshot_collection_is_triggered_by_autonomous_radio_recovery
    BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Wait Until BTS OnAir
    Remove Snapshot from LSS server
    Prepare RMOD for SSH connection
    ADMIN Perform Delta Recommissioning        delta_file=${delta_LSS_10_onFaultDet_activate}
    ...                                        skip_parameter_relation_errors=True
    ...                                        should_activate=True
    ...                                        timeout=300
    Log to console  RF reboot and fault 10 appear
    Reboot RF via SSH command
    wait until keyword succeeds  600  60  Check if Snapshot is collected on LSS
    Remove Snapshot from LSS server
    Sleep  180
    BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Wait Until BTS OnAir



Reboot RF via SSH command
    SYSTEM Open SSH Connection To Enb
    SSHLibrary.Write   cat /ffs/run/config/FRIps.txt
    ${FRIps}=     SSHLibrary.Read Until    expected=>
    ${splitFRIps}=    Split string       ${FRIps}    separator=\;
    ${ip_rmod}=     Get from list       ${splitFRIps}     2
#    SSHLibrary.Write    lxc-attach -n 0x1018
#    SSHLibrary.Read Until    expected=>
    #SSHLibrary.Write    ssh root@172.22.48.10    #cu astea
    #SSHLibrary.Write    ssh serviceuser@172.22.48.2
    SSHLibrary.Write    lxc-ls
    ${virtual_nodes}    SSHLibrary.Read Until    expected=>
    ${split_VN}=    Split string       ${virtual_nodes}    separator=\
    ${fhnet_container}=     Get from list       ${split_VN}     0
    SSHLibrary.Write    lxc-attach -n ${fhnet_container}
    SSHLibrary.Read Until    expected=>
    SSHLibrary.Write    ssh ${rf_user}@${ip_rmod}
    SSHLibrary.Read Until    expected=password:
    SSHLibrary.Write    ${rf_password}
    SSHLibrary.Read Until    expected=$
    SSHLibrary.Write   sudo -i
    SSHLibrary.Read Until     expected=#
    SSHLibrary.Write    reboot
   # SSHLibrary.Read Until    expected=SERVICES.service not loaded.
    #SSHLibrary.Write   exit
    Sleep       10
    #SSHLibrary.Write   exit
    SSHLibrary.Close Connection

Check if Snapshot is collected on LSS
    Set Suite Variable    ${snapshot_LSS}    Snapshot_MRBTS-10009_${OUT_ADMIN_BTS_NAME}
    csn.connect to    ${LSS_addr}    ${LSS_username}    ${LSS_password}    alias=LSS
    sleep    2s
    csn.send_command    command=ls -l /home/coam/   connection=LSS
    ${snap_exists}    csn.read output    connection=LSS
    Should contain  ${snap_exists}  ${snapshot_LSS}  connection=LSS
    csn.send_command    command=find ${snapshot_LSS}* | wc -l   connection=LSS
    ${snap_list}    csn.read output    connection=LSS
    ${snap_list}    convert to integer  ${snap_list}
    should be true      ${snap_list}>=7
    csn.disconnect    connection=LSS


Remove Snapshot from LSS server
    Set Suite Variable    ${snapshot_path_LSS}    /home/coam/Snapshot_MRBTS-10009_${OUT_ADMIN_BTS_NAME}*
    csn.connect to    ${LSS_addr}    ${LSS_username}    ${LSS_password}    alias=LSS
    sleep    2s
    csn.send_command    command=rm -rf ${snapshot_path_LSS}  connection=LSS
    csn.disconnect    connection=LSS


Wait for Site is pingable
	Wait Until Host Is Available    192.168.255.1      timeout=300
	Log To Console		The site is pingable

UTE TL Preparation
    [Documentation]  Keyword used for setting up local 5G TLs to onAir state, as UTE reserve it only to sw_upload state
    #TO DO:             Add Check for onAir State. For cases when the Suite is run more than one time
    PREPOST Setup Admin
    ADMIN Change R&D Port Status    status=True
    @{status}   Run Keyword and Ignore Error    ADMIN Check BTS onair
    Run Keyword If  '@{status}[0]' == 'FAIL'   Run Keyword  5GC001526-TA.Configured_SwDownload_SwUpdate_OnAir
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
    [Arguments]    ${host}    ${port}    ${username}    ${password}
    SSHLibrary.Open Connection    host=${host}    port=${port}    timeout=60
    SSHLibrary.Login    username=${username}    password=${password}    delay=1s

SYSTEM Close SSH Connection
    [Arguments]    ${alias}
    SSHLibrary.Switch Connection    index_or_alias=${alias}
    SSHLibrary.Close Connection

SYSTEM Open SSH Connection To Enb
    SYSTEM Open SSH Connection    host=${SYSTEM_ENB_TRANSPORT_IP}
    ...                           port=22
    ...                           username=${SYSTEM_ENB_SSH_USERNAME}
    ...                           password=${SYSTEM_ENB_SSH_PASSWORD}

Prepare RMOD for SSH connection
    SYSTEM Open SSH Connection To Enb
    SSHLibrary.Write   cat /ffs/run/config/FRIps.txt
    ${FRIps}=     SSHLibrary.Read Until    expected=>
    ${splitFRIps}=    Split string       ${FRIps}    separator=\;
    ${ip_rmod}=     Get from list       ${splitFRIps}     2
    SSHLibrary.Write    lxc-attach -n 0x1018
    SSHLibrary.Read Until    expected=>
    SSHLibrary.Write    rm /user/toor4nsn/.ssh/known_hosts
    SSHLibrary.Read Until    expected=>
    SSHLibrary.Write    ssh ${rf_user}@${ip_rmod}
    SSHLibrary.Read Until    expected=?
    SSHLibrary.Write    yes
    SSHLibrary.Read Until    expected=password:
    SSHLibrary.Close Connection


