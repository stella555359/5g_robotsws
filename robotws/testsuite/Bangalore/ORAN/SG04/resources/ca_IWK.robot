*** Settings ***
Documentation   ---SW Download & Update to NR and LTE BTS---
...			     :copyright: Nokia

Library     OperatingSystem
Library     Collections
Library     String
Library     taf.pdu                 WITH NAME   pdu
Library     taf.transport.ssh       WITH NAME   ssh
Library     taf.collectors.tcpdump  WITH NAME   tcpdump
Library     taf.collectors.btslog   WITH NAME   btslog
Library     taf.collectors.core     WITH NAME   core
Library     taf.collectors.pmcounters
Library     taf.collectors.l2stream3       WITH NAME   l2stream3
Library     taf.converters.eventdecoder    WITH NAME   eventdecoder
#Library     ute_admin_infomodel
#Library     ute_syslog
#Library     taf.sbts.oam.coam.admin  WITH NAME  admin
Resource    ca_INTER_RAT.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot


*** Keywords ***

IWK Test Setup
    [Documentation]
    ...  Test setup for IWK tests. Sets up both eNB and gNB test lines.
    ...
    ...  | **Author:** igor.binkowski@nokia.com
    ...  | **Maintainer:** adam.chamera@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  Test setup for IWK tests, in which 1 BTS (eNB or gNB) is used, or 2 BTSes (eNB and gNB) are used.
    ...
    ...  List of actions:
    ...    - Creates log directories, pointed to by variable ${LOG_PATH}
    ...    - Starts Admin connection under aliases 'default' and 'gNB'
    ...    - Starts InfoModel connection under aliases 'default' and 'gNB'
    ...    - Starts syslog collection under aliases 'default' and 'gNB'
    ...    - Starts wireshark log collection from eNB
    ...    - Prints active SW versions, sets them as test tags
    ...    - Checks cells and modules state and active alarms on both sides, if ${states_check} is not set to False
    ...    - Runs hanging users script (ca_INTER_RAT.Run Hanging Users Script)
    ...    - Sets up PDU for taf.pdu library as first element of 'pdus' list in 'tl'
    ...    - Sets variable ${BTSFiles} and ${BTS_Files} equal to ${LOG_PATH}, for compatibility with some ca_INTER_RAT
    ...      resources
    ...
    ...  Requires correct config file for test line. TestLine object must have properties 'test_pcs', 'enbs' and 'pdus'.
    ...  It is assumed that 'test_pcs' list contains first the TestPc referring to the eNB VM, then gNB VM.
    ...  Similarly, 'enbs' list should contain first the RealEnb object referring to the eNB, and then the gNB. e.g.:
    ...  tl = TestLine(test_pc=_test_pc_1, test_pcs=[_test_pc_1, _test_pc_2], enbs=[_enb_sbts_1, _enb_sbts_2], pdus=[_pdu])
    ...  Variable ${CLOUD} (bool) should be globally set to either 'True' or 'False' depending on whether the line is in
    ...  the cloud or not. It is used for set 'virtualenv_dir' parameter for 'Start Syslog' KW for remote host or not
    ...  and correct extracting eNB,gNB VM IPs from file '__init__.py'
    ...
    ...  **Input Parameters:**
    ...
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...  | Parameter             | Man. | Description                                                         |
    ...  +=======================+======+=====================================================================+
    ...  | states_check          | No   | Parameter strictly for developer usage.                             |
    ...  |                       |      | If set to True, setup will check if all cells and modules are OnAir |
    ...  |                       |      | and if no unexpected alarms appear. Default is True.                |
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...  | start_wireshark       | No   | When set to False, wireshark logs will not start collecting.        |
    ...  |                       |      | Useful in case there is BTS reset occurs in TC.                     |
    ...  |                       |      | Should be used with stop_wireshark=False in TC Teardown.            |
    ...  |                       |      | Default is True.                                                    |
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...  | local_enb_connection  | No   | Boolean value determining if local connection is eNB (True)         |
    ...  |                       |      | or gNB (False). Default is True.                                    |
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...  | single_bts            | No   | Boolean value determining if 2 BTSes (eNB and gNB) are used (False) |
    ...  |                       |      | or single BTS (True). Default is False.                             |
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     TC Setup
    ...         IWK Test Setup

    [Timeout]    15 minutes
    [Arguments]  ${states_check}=True  ${start_wireshark}=True  ${local_enb_connection}=True  ${single_bts}=False

    Log To Console  \n\n=== IWK Test Setup ===

    #Run Keyword If  not ${single_bts}  Extract Variables From Config File
    #...  ELSE IF  ${single_bts} and ${local_enb_connection}  Extract Variables From Config File For eNB
    #...  ELSE IF  ${single_bts} and not ${local_enb_connection}  Extract Variables From Config File For gNB

    Create Log Directories
    ${local_connection} =  Set Variable If  ${local_enb_connection}  default  gNB
    ${remote_connection} =  Set Variable If  ${local_enb_connection}  gNB  default
    ${remote_host} =  Set Variable If  ${local_enb_connection}  ${GNB_VM_IP}  ${ENB_VM_IP}
    ${local_host} =  Set Variable If  ${local_enb_connection}  ${ENB_VM_IP}  ${GNB_VM_IP}
    ${local_string} =  Set Variable If  ${local_enb_connection}  eNB  gNB
    ${remote_string} =  Set Variable If  ${local_enb_connection}  gNB  eNB
    Log Variables   level=DEBUG

    Run Keyword And Ignore Error  Teardown All Aliases For Syslog

    Setup Admin  bts_host=192.168.255.129  admin_api_log_dir=${LOG_PATH}/admin_api_logs  alias=${local_connection}
    Log To Console  Connection to ADMIN on ${local_string} side started.

    Setup Infomodel  address=192.168.255.129  port=443  use_ssl=True  admin_api_log_dir=${LOG_PATH}/admin_api_logs
    ...  alias=${local_connection}
    Connect Infomodel  alias=${local_connection}
    Log To Console  Connection to InfoModel on ${local_string} side started.

    Start Syslog  log_dir=${LOG_PATH}/udp_logs  log_name=UDP_${local_string}  ip=192.168.255.126
    ...  alias=${local_string}
    Log To Console  Syslog on ${local_string} side started.

    Run Keyword If  not ${single_bts}  Run Keywords
    ...  Log To Console  Setup on remote side started.
    ...  AND  Remote Host Setup  ${remote_connection}  ${remote_host}  ${remote_string}

    Run Keyword If  ${start_wireshark} and not ${single_bts}  Start Wireshark Log Collection For IWK Test
    ...  ELSE IF  ${start_wireshark} and ${single_bts}  Start Wireshark Log Collection For IWK Test
    ...  options=-i any host ${local_host} and not udp port 2152 -s 0 -W 1
    ...  replace_enb=False  replace_gnb=False

    ${release_local} =  Get SW Release Name  connection=${local_connection}
    Set Test Variable  ${RELEASE_LOCAL}  ${release_local}
    Log  Release local: ${RELEASE_LOCAL}  console=True

    Add Standard Allowed Alarms  alias=${local_connection}

    Run Keyword If  ${local_enb_connection}  Run Hanging Users Script  ${LOG_PATH}/misc_logs

    ${local_cni-61110_status} =  Run Keyword If  ${local_enb_connection}  Check CNI-61110 Status
    ...  ELSE  Check CNI-61110 Status  alias=gNB

    Run Keyword If  ${local_enb_connection}  Set Test Variable  ${ENB_CNI-61110_STATUS}  ${local_cni-61110_status}
    ...  ELSE                                Set Test Variable  ${GNB_CNI-61110_STATUS}  ${local_cni-61110_status}

    Run Keyword If  not ${single_bts}  Run Keyword If  ${states_check}  Verify BTS States For IWK Test
    ...  ELSE IF  ${single_bts}  _verify bts states for iwk test helper  alias=${local_connection}

    ${local_sw_info}=  Get Software Info  alias=${local_connection}
    Log To Console  Active SW: ${local_sw_info['Active SW version']}
    Set Tags  SBTS_SW-${local_sw_info['Active SW version']}

    ${pdu}  Evaluate  $tl.pdus[0]
    pdu.Setup PDU  ${pdu}

    Set Test Variable  ${BTSFiles}  ${LOG_PATH}
    Set Test Variable  ${BTS_Files}  ${LOG_PATH}
    Set Test Variable  ${Test_Files}  ${LOG_PATH}

    Log Variables   level=DEBUG
    Log to console  IWK Test Setup finished.\n


Remote Host Setup
    [Documentation]
    ...  Separated part of IWK Test Setup for remote host.
    ...
    ...  | **Author:** igor.binkowski@nokia.com
    ...  | **Maintainer:** szymon.kotlinski@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  Part of IWK Test Setup for remote host.
    ...  Variable ${CLOUD} (bool) should be globally set to either 'True' or 'False' depending on whether the line is in
    ...  the cloud or not. It is used for set 'virtualenv_dir' parameter for 'Start Syslog' KW for remote host or not.

    [Arguments]  ${remote_connection}  ${remote_host}  ${remote_string}

    Setup Admin  remote_host=${remote_host}  bts_host=192.168.255.129
    ...  admin_api_log_dir=${LOG_PATH}/admin_api_logs  alias=${remote_connection}
    Log To Console  Connection to ADMIN on ${remote_string} side started.

    Setup Infomodel  remote_host=${remote_host}  port=443  use_ssl=True
    ...  admin_api_log_dir=${LOG_PATH}/admin_api_logs  alias=${remote_connection}
    Connect Infomodel  alias=${remote_connection}
    Log To Console  Connection to InfoModel on ${remote_string} side started.


    Run Keyword If  ${CLOUD}  Start Syslog  log_dir=${LOG_PATH}/udp_logs  log_name=UDP_${remote_string}  ip=192.168.255.126
    ...  host_ip=${remote_host}    alias=${remote_connection}    virtualenv_dir=/home/ute/test_repo/
    ...  ELSE  Start Syslog  log_dir=${LOG_PATH}/udp_logs  log_name=UDP_${remote_string}  ip=192.168.255.126
    ...  host_ip=${remote_host}    alias=${remote_connection}
    Log To Console  Syslog on ${remote_string} side started.

    Add Standard Allowed Alarms  alias=${remote_connection}

    ${release_remote} =  Get SW Release Name  connection=${remote_connection}
    Set Test Variable  ${RELEASE_REMOTE}  ${release_remote}
    Log  Release remote: ${RELEASE_REMOTE}  console=True

    ${remote_cni-61110_status} =  Run Keyword If  '${remote_string}' == 'eNB'  Check CNI-61110 Status
    ...  ELSE  Check CNI-61110 Status  alias=gNB

    Run Keyword If  '${remote_string}' == 'eNB'  Set Test Variable  ${ENB_CNI-61110_STATUS}  ${remote_cni-61110_status}
    ...  ELSE                                    Set Test Variable  ${GNB_CNI-61110_STATUS}  ${remote_cni-61110_status}

    ${remote_sw_info}=  Get Software Info  alias=${remote_connection}
    Log To Console  Active SW: ${remote_sw_info['Active SW version']}
    Set Tags  SBTS_SW-${remote_sw_info['Active SW version']}


Extract Variables From Config File
    [Documentation]
    ...  Extracts certain variables from __init__.py testline config file and sets them as test variables.
    ...
    ...  | **Author:** igor.binkowski@nokia.com
    ...  | **Maintainer:** adam.chamera@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  Part of IWK Test Setup for extract variables.
    ...  Variable ${CLOUD} (bool) should be globally set to either 'True' or 'False' depending on whether the line is in
    ...  the cloud or not. It is used for correct extracting eNB,gNB VM IPs from file '__init__.py'.

    #${enb_vm_ip}=  Run Keyword If  ${CLOUD}  Evaluate  $tl.test_pcs[1].default_ssh_connection_details.addr
    #...  ELSE                                Evaluate  $tl.test_pcs[0].default_ssh_connection_details.addr
    #Set Test Variable  ${ENB_VM_IP}  ${enb_vm_ip}
    ${gnb_vm_ip}=  Run Keyword If  ${CLOUD}  Evaluate  $tl.test_pcs[0].default_ssh_connection_details.addr
    #...  ELSE                                Evaluate  $tl.test_pcs[1].default_ssh_connection_details.addr
    #Set Test Variable  ${GNB_VM_IP}  ${gnb_vm_ip}

    #${ENB_OAM_IP}  Evaluate  $tl.enbs[0].oam_ip.v4
    #et Test Variable  ${ENB_OAM_IP}
    ${GNB_OAM_IP}  Evaluate  $tl.gnbs[0].cu.backhaul_site_oam_ip.v4
    Set Test Variable  ${GNB_OAM_IP}


Extract Variables From Config File For eNB
    [Documentation]
    ...  Extracts certain variables from __init__.py eNB testline config file and sets them as test variables.
    ...
    ...  | **Author:** igor.binkowski@nokia.com
    ...  | **Maintainer:** szymon.kotlinski@nokia.com

    Set Test Variable  ${GNB_VM_IP}  None
    Set Test Variable  ${GNB_OAM_IP}  None
    ${ENB_VM_IP}  Evaluate  $tl.test_pcs[0].default_ssh_connection_details.addr
    Set Test Variable  ${ENB_VM_IP}
    ${ENB_OAM_IP}  Evaluate  $tl.enbs[0].oam_ip.v4
    Set Test Variable  ${ENB_OAM_IP}


Extract Variables From Config File For gNB
    [Documentation]
    ...  Extracts certain variables from __init__.py gNB testline config file and sets them as test variables.
    ...
    ...  | **Author:** igor.binkowski@nokia.com
    ...  | **Maintainer:** szymon.kotlinski@nokia.com

    Set Test Variable  ${ENB_VM_IP}  None
    Set Test Variable  ${ENB_OAM_IP}  None
    ${GNB_VM_IP}  Evaluate  $tl.test_pcs[0].default_ssh_connection_details.addr
    Set Test Variable  ${GNB_VM_IP}
    ${GNB_OAM_IP}  Evaluate  $tl.gnbs[0].cu.backhaul_site_oam_ip.v4
    Set Test Variable  ${GNB_OAM_IP}


Add Standard Allowed Alarms
    [Documentation]
    ...  Adds always present allowed alarms for ute_admin, so that its KWs for alarm checking can be used freely.
    ...
    ...  | **Author:** igor.binkowski@nokia.com
    ...  | **Maintainer:** adam.chamera@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  This KW adds always present alarms as allowed alarms for ute_admin, so that its KWs for alarm checking like
    ...  'Assert No Unexpected Active Alarms' can be used freely.
    ...
    ...  Allowed alarms' faultNames are:
    ...    - SSH enabled
    ...    - R&D Service Port enabled
    ...    - LMP access via port
    ...    - Diagnostic Files collected
    ...
    ...  Also any alarms defined in IGNORED_ALARMS_<alias> variable will be added. Alarm pattern syntax:
    ...  http://doc.ute.nsn-rdnet.net/packages/ute_admin/interfaces/ute_admin.html#assert-alarm-active
    ...
    ...  **Input Parameters:**
    ...
    ...  +-----------+------+-----------------------------------------------+
    ...  | Parameter | Man. | Description                                   |
    ...  +===========+======+===============================================+
    ...  | alias     | No   | Alias of ADMIN connection which will be used. |
    ...  |           |      | Default is 'default'.                         |
    ...  +-----------+------+-----------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     some_library.Raise Alarm  faultId=420  severity=Critical
    ...     ute_admin.Add Allowed Alarm  faultId=420, severity=Critical
    ...     ute_admin.Check If No Unexpected Alarms Appeared
    ...     ute_admin.Clear Allowed Alarms List
    ...     Add Standard Allowed Alarms

    [Arguments]  ${alias}=default

    Add Allowed Alarm  faultName=regex"SSH.enabled"                 alias=${alias}
    Add Allowed Alarm  faultName=regex"R&D.Service.Port.enabled"    alias=${alias}
    Add Allowed Alarm  faultName=regex"LMP.access.via.port"         alias=${alias}
    Add Allowed Alarm  faultName=regex"Diagnostic.Files.collected"  alias=${alias}
    Add Allowed Alarm  faultId=4297                                 alias=${alias}  #NTP Server 10.44.45.199 unavailable
    Add Allowed Alarm  faultId=4592                                 alias=${alias}  #BTS Reset Cause
    Add Allowed Alarm  faultId=6450                                 alias=${alias}  #Diagnostic Files collected
    Add Allowed Alarm  faultId=4340                                 alias=${alias}  #Previously downloaded plan 4215816958 was
                                                                                    #overwritten by a new plan 3324981826
    Add Allowed Alarm  faultId=4655                                 alias=${alias}  #Service account root access is enabled
    Add Allowed Alarm  faultId=4654                                 alias=${alias}  #Ethernet port security is disabled
    Add Allowed Alarm  faultId=4681                                 alias=${alias}  #Sanity Check Error

    ${alias}  Set Variable If  '${alias}'=='default'  eNB  ${alias}

    ${additional_ignored_alarms_defined}  Run Keyword And Return Status
    ...  Variable Should Exist  ${IGNORED_ALARMS_${alias.upper()}}
    Return From Keyword If  not ${additional_ignored_alarms_defined}

    FOR  ${alarm}  IN  @{IGNORED_ALARMS_${alias.upper()}}
        Add Allowed Alarm  ${alarm}  alias=${alias}
    END


IWK Test Teardown
    [Documentation]
    ...  Test teardown for IWK tests. Tears down both eNB and gNB test lines.
    ...
    ...  | **Author:** igor.binkowski@nokia.com
    ...  | **Maintainer:** adam.chamera@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  Test teardown for IWK tests, in which 2 BTSes (eNB and gNB) are used.
    ...
    ...  List of actions:
    ...    - Removes all aliases for delta commissioning through ute_admin
    ...    - Stops all potentially ongoing data transfers
    ...    - Runs hanging users script (ca_INTER_RAT.Run Hanging Users Script)
    ...    - Stops wireshark log collection for eNB
    ...    - Saves InfoModel logs from eNB and gNB to ${LOG_PATH}/infomodel_logs
    ...    - Stops syslogs on eNB and gNB and saves them zipped in .tar.gz to ${LOG_PATH}/udp_logs
    ...    - Saves ADMIN API logs to ${LOG_PATH}/admin_api_logs
    ...    - Collects swconfigs from eNB and gNB and saves them to ${LOG_PATH}/swconfig
    ...    - Collects RawAlarmHistory from eNB and gNB and saves them to ${LOG_PATH}/alarm_history
    ...    - Collects snapshots fron eNB and gNB if test failed and ${collect_snapshot_on_test_fail} is not set to False
    ...    - Tears down InfoModel and ADMIN connections
    ...    - Moves ute_ue logs and hanging users script logs to ${LOG_PATH}/misc_logs
    ...
    ...  **Input Parameters:**
    ...
    ...  +-------------------------------+------+--------------------------------------------------------+
    ...  | Parameter                     | Man. | Description                                            |
    ...  +===============================+======+========================================================+
    ...  | collect_snapshot_on_test_fail | No   | Parameter strictly for developer usage.                |
    ...  |                               |      | When set to False, snapshot will not be collected even |
    ...  |                               |      | when test fails. Default is True.                      |
    ...  +-------------------------------+------+--------------------------------------------------------+
    ...  | stop_wireshark                | No   | When set to False, wireshark logs will not be          |
    ...  |                               |      | collected even when test fails. Useful in case there   |
    ...  |                               |      | is BTS reset occurs in TC.                             |
    ...  |                               |      | Should be used with start_wireshark=False in TC Setup. |
    ...  |                               |      | Default is True.                                       |
    ...  +-------------------------------+------+--------------------------------------------------------+
    ...  | delta_exists                  | No   | Boolean value defining if delta was created in         |
    ...  |                               |      | test case and needs to be removed with 'Remove All     |
    ...  |                               |      | Delta Id'. Default value: True.                        |
    ...  +-------------------------------+------+--------------------------------------------------------+
    ...  | local_enb_connection          | No   | Boolean value determining if local connection          |
    ...  |                               |      | is eNB (True) or gNB (False). Default is True.         |
    ...  +-------------------------------+------+--------------------------------------------------------+
    ...  | single_bts                    | No   | Boolean value determining if 2 BTSes (eNB and gNB) are |
    ...  |                               |      | used (False) or single BTS (True). Default is False.   |
    ...  +-------------------------------+------+--------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     TC Teardown
    ...         IWK Test Teardown

    [Arguments]  ${collect_snapshot_on_test_fail}=True  ${stop_wireshark}=True  ${delta_exists}=True
    ...  ${local_enb_connection}=True  ${single_bts}=False

    Log To Console  \n\n=== IWK Test Teardown ===

    ${local_connection} =  Set Variable If  ${local_enb_connection}  default  gNB
    ${remote_connection} =  Set Variable If  ${local_enb_connection}  gNB  default
    ${local_string} =  Set Variable If  ${local_enb_connection}  eNB  gNB
    ${remote_string} =  Set Variable If  ${local_enb_connection}  gNB  eNB
    Log Variables   level=DEBUG

    Run Keyword If  ${delta_exists}  Remove All Delta Id
    Run Keyword If  ${local_enb_connection}  Run Hanging Users Script  ${LOG_PATH}/misc_logs

    Run Keyword If  ${stop_wireshark}  Stop Wireshark Log Collection For IWK Test

    Save Infomodel Log  filename=${LOG_PATH}/infomodel_logs/InfoModel_log_${local_string}.ims2  alias=${local_connection}
    Log To Console  InfoModel log from ${local_string} saved.

    Collect Syslog Results  unzip=False  alias=${local_string}
    Log To Console  Syslog on ${local_string} closed and saved.

    Run Keyword If  not ${single_bts}  Run Keywords
    ...  Save Infomodel Log  filename=${LOG_PATH}/infomodel_logs/InfoModel_log_${remote_string}.ims2  alias=${remote_connection}
    ...  AND  Log To Console  InfoModel log from ${remote_string} saved.
    ...  AND  Collect Syslog Results  unzip=False  alias=${remote_string}
    ...  AND  Log To Console  Syslog on ${remote_string} closed and saved.

    Run Keyword If  not ${single_bts}  Collect swconfigs and RawAlarmHistory
    ...  ELSE IF  ${single_bts} and ${local_enb_connection}  Collect swconfig and RawAlarmHistory From eNB
    ...  ELSE IF  ${single_bts} and not ${local_enb_connection}  Collect swconfig and RawAlarmHistory From gNB
    Log to console  swconfigs and RawAlarmHistory saved.

    Run Keyword If Test Failed  Run Keyword If  ${collect_snapshot_on_test_fail}  Run Keyword If  not ${single_bts}
    ...  Run Keywords
    ...  Create Directory  ${LOG_PATH}/snapshots  AND
    ...  Collect Snapshot  ${LOG_PATH}/snapshots/enb_snapshot  AND
    ...  Collect Snapshot  ${LOG_PATH}/snapshots/gnb_snapshot  alias=gNB  AND
    ...  Log To Console  Snapshots collected.

    Run Keyword If Test Failed  Run Keyword If  ${collect_snapshot_on_test_fail}  Run Keyword If  ${single_bts}
    ...  Run Keywords
    ...  Create Directory  ${LOG_PATH}/snapshot  AND
    ...  Collect Snapshot  ${LOG_PATH}/snapshot/${local_string}  alias=${local_connection}  AND
    ...  Log To Console  Snapshot collected.

    Create Directory  ${LOG_PATH}/admin_api_logs/
    Teardown All Aliases For Infomodel
    Log To Console  InfoModel connections closed.

    Teardown All Aliases For Admin
    Log To Console  ADMIN connections closed.

    Run  mv ${LOG_PATH}/*.log* ${LOG_PATH}/misc_logs/
    Run  mv ./hanging* ${LOG_PATH}/misc_logs/
    interface.Common step trigger
    Log to console  IWK Test Teardown finished.\n


Create Log Directories
    [Documentation]
    ...  Creates log directories for IWK test.
    ...
    ...  | **Author:** igor.binkowski@nokia.com
    ...  | **Maintainer:** adam.chamera@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  Creates log directories for IWK test.
    ...  Main directory name begins with timestamp and follows with test name.
    ...
    ...  Inside it, following sub-directories are created:
    ...    - udp_logs
    ...    - admin_api_logs
    ...    - infomodel_logs
    ...    - swconfig
    ...    - alarm_history
    ...    - pcap_logs
    ...    - trace
    ...    - misc_logs - e.g. for ute_ue and hanging resource script logs
    ...
    ...  Also, test variable ${LOG_PATH} ponting to the main log directory is set.

    ${timestamp}  OperatingSystem.Run  date +%F_%H-%M-%S
    ${LOG_PATH}   OperatingSystem.Join Path  ${OUTPUT DIR}  ${timestamp}_${TEST NAME}
    Create Directory  ${LOG_PATH}
    Set Test Variable  ${LOG_PATH}

    Create Directory  ${LOG_PATH}/udp_logs
    Create Directory  ${LOG_PATH}/admin_api_logs
    Create Directory  ${LOG_PATH}/infomodel_logs
    Create Directory  ${LOG_PATH}/swconfig
    Create Directory  ${LOG_PATH}/alarm_history
    Create Directory  ${LOG_PATH}/pcap_logs
    Create Directory  ${LOG_PATH}/trace
    Create Directory  ${LOG_PATH}/misc_logs

    Log To Console  Log directory created: ${LOG_PATH}


Print Active SW Versions
    [Documentation]
    ...  Prints active SW versions for both eNB and gNB. Sets them as test tags:
    ...  SBTS_SW-<eNB active SW>, 5G_SW-<gNB active SW>
    ...
    ...  | **Author:** igor.binkowski@nokia.com
    ...  | **Maintainer:** adam.chamera@nokia.com

    ${enb_sw_info}=  Get Software Info
    ${gnb_sw_info}=  Get Software Info  alias=gNB

    Log To Console
    ...  Active SW on eNB side: ${enb_sw_info['Active SW version']}\nActive SW on gNB side: ${gnb_sw_info['Active SW version']}
    Set Tags  SBTS_SW-${enb_sw_info['Active SW version']}  5G_SW-${gnb_sw_info['Active SW version']}


Collect swconfigs and RawAlarmHistory
    [Documentation]
    ...  Downloads swconfig.txt and RawAlarmHistory.txt files from both eNB and gNB through SSH.
    ...
    ...  | **Author:** igor.binkowski@nokia.com
    ...  | **Maintainer:** adam.chamera@nokia.com


    ssh.Connect To  ${ENB_OAM_IP}  toor4nsn  oZPS0POrRieRtu  alias=eNB
    ssh.Connect To  ${GNB_OAM_IP}  toor4nsn  oZPS0POrRieRtu  alias=gNB

    ssh.Download File  /ffs/run/swconfig.txt  ${LOG_PATH}/swconfig/swconfig_enb.txt  connection=eNB
    ssh.Download File  /ffs/run/swconfig.txt  ${LOG_PATH}/swconfig/swconfig_gnb.txt  connection=gNB

    ssh.Download File  /tmp/RawAlarmHistory.txt  ${LOG_PATH}/alarm_history/RawAlarmHistory_enb.txt  connection=eNB
    ssh.Download File  /tmp/RawAlarmHistory.txt  ${LOG_PATH}/alarm_history/RawAlarmHistory_gnb.txt  connection=gNB

    [Teardown]  Run Keywords
    ...  ssh.Disconnect  connection=eNB
    ...  AND  ssh.Disconnect  connection=gNB


Collect swconfig and RawAlarmHistory From eNB
    [Documentation]
    ...  Downloads swconfig.txt and RawAlarmHistory.txt files from eNB through SSH.
    ...
    ...  | **Author:** igor.binkowski@nokia.com
    ...  | **Maintainer:** szymon.kotlinski@nokia.com

    ssh.Connect To  ${ENB_OAM_IP}  toor4nsn  oZPS0POrRieRtu  alias=eNB
    ssh.Download File  /ffs/run/swconfig.txt  ${LOG_PATH}/swconfig/swconfig_enb.txt  connection=eNB
    ssh.Download File  /tmp/RawAlarmHistory.txt  ${LOG_PATH}/alarm_history/RawAlarmHistory_enb.txt  connection=eNB

    [Teardown]  ssh.Disconnect  connection=eNB


Collect swconfig and RawAlarmHistory From gNB
    [Documentation]
    ...  Downloads swconfig.txt and RawAlarmHistory.txt files from gNB through SSH.
    ...
    ...  | **Author:** igor.binkowski@nokia.com
    ...  | **Maintainer:** szymon.kotlinski@nokia.com

    ssh.Connect To  ${GNB_OAM_IP}  toor4nsn  oZPS0POrRieRtu  alias=gNB
    ssh.Download File  /ffs/run/swconfig.txt  ${LOG_PATH}/swconfig/swconfig_gnb.txt  connection=gNB
    ssh.Download File  /tmp/RawAlarmHistory.txt  ${LOG_PATH}/alarm_history/RawAlarmHistory_gnb.txt  connection=gNB

    [Teardown]  ssh.Disconnect  connection=gNB


Start Wireshark Log Collection For IWK Test
    [Documentation]
    ...  KW used to start collection of wireshark logs using tcpdump for IWK tests.
    ...
    ...  | **Author:** igor.binkowski@nokia.com
    ...  | **Maintainer:** adam.chamera@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  KW used to start collection of wireshark logs using tcpdump for IWK tests on both eNB and gNB sides.
    ...  KW arguments let the tester define the options used for tcpdump command. The option string may contain
    ...  string '<bts_ip>' which will be replaced by BTS mPlane address obtained from InfoModel with given alias.
    ...
    ...  **Input Parameters:**
    ...
    ...  +--------------+------+------------------------------------------------------------------------+
    ...  | Parameter    | Man. | Description                                                            |
    ...  +==============+======+========================================================================+
    ...  | options      | No   | Options string for TCPDump collectors. Default is                      |
    ...  |              |      | '-i any host <bts_ip> and not udp port 2152 -s 0 -W 1'.                |
    ...  +--------------+------+------------------------------------------------------------------------+
    ...  | host_ip      | No   | IP of host on which tcpdump should to be collected. Default is:        |
    ...  |              |      | 192.168.255.129.                                                       |
    ...  +--------------+------+------------------------------------------------------------------------+
    ...  | alias        | No   | Alias used for tcpdump. Default: tcpdump.                              |
    ...  +--------------+------+------------------------------------------------------------------------+
    ...  | replace_enb  | No   | Boolean variable defining if string <enb_ip> should be replaced        |
    ...  |              |      | with ${ENB_OAM_IP}. Default: True.                                     |
    ...  +--------------+------+------------------------------------------------------------------------+
    ...  | replace_gnb  | No   | Boolean variable defining if string <gnb_ip> should be replaced        |
    ...  |              |      | with ${GNB_OAM_IP}. Default: True.                                     |
    ...  +--------------+------+------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Run  until ping -c1 192.168.255.129 >/dev/null 2>&1; do :; done
    ...     Start Wireshark Log Collection For IWK Test

    [Arguments]  ${options}=-i any host <enb_ip> or host <gnb_ip> and not udp port 2152 -s 0 -W 1
    ...  ${host_ip}=192.168.255.129  ${alias}=tcpdump  ${replace_enb}=True  ${replace_gnb}=True

    ${options} =  Run Keyword If  ${replace_enb}  Replace String  ${options}  <enb_ip>  ${ENB_OAM_IP}
    ...  ELSE  Set Variable  ${options}
    ${options} =  Run Keyword If  ${replace_gnb}  Replace String  ${options}  <gnb_ip>  ${GNB_OAM_IP}
    ...  ELSE  Set Variable  ${options}

    ${executor}=  Create Dictionary
    ...  host=${host_ip}
    ...  user=toor4nsn
    ...  password=oZPS0POrRieRtu

    tcpdump.Create TCPDump Collector
    ...    name=${alias}
    ...    executor=${executor}
    ...    options=${options}

    core.Setup Collectors    names=${alias}
    core.Start Collectors    names=${alias}
    core.Set Test Alias  ${alias}

    Sleep  10s  reason=Let the log start before proceeding with test

    Log  Wireshark log collection started.  console=True


Stop Wireshark Log Collection For IWK Test
    [Documentation]
    ...  KW used to stop collection of wireshark logs using tcpdump for IWK tests.
    ...
    ...  | **Author:** igor.binkowski@nokia.com
    ...  | **Maintainer:** adam.chamera@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  KW used to stop collection of wireshark logs using tcpdump for IWK tests
    ...  and save it in 'log_directory'. File name will have timestamp added to it
    ...  in this KW. It returns absolute path to saved file.
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+----------------------------------------+
    ...  | Parameter      | Man. | Description                            |
    ...  +================+======+========================================+
    ...  | log_directory  | No   | Directory where logs should be saved.  |
    ...  |                |      | Default is ${LOG_PATH}/pcap_logs.      |
    ...  +----------------+------+----------------------------------------+
    ...  | alias          | No   | Alias used for tcpdump. Has to be the  |
    ...  |                |      | as used during start of logs           |
    ...  |                |      | collection. Default: tcpdump.          |
    ...  +----------------+------+----------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Stop Wireshark Log Collection For IWK Test

    [Arguments]  ${log_directory}=${LOG_PATH}/pcap_logs  ${alias}=tcpdump

    ${timestamp}  Run  date +%H-%M-%S

    core.Stop Collectors      names=${alias}
    core.Collect Collectors   names=${alias}  target_dir=${log_directory}
    core.Teardown Collectors  names=${alias}

    ${pcap_exists} =  Run Keyword And Return Status
    ...  OperatingSystem.File Should Exist  ${log_directory}/${alias}/${alias}.pcap
    Should Be True  ${pcap_exists}
    ...  msg=Tcpdump file does not exist in ${log_directory}/${alias}/${alias}.pcap.
    Return From Keyword If  not ${pcap_exists}  ${NONE}

    Run  mv ${log_directory}/${alias}/${alias}.pcap ${log_directory}/${alias}_${timestamp}.pcap

    Log  Wireshark log collection finished.  console=True
    [Return]  ${log_directory}/${alias}_${timestamp}.pcap


Get Global ID Of NR Cell Related To LTE Cell
    [Documentation]
    ...  KW used to get global (short) ID of NR cell related to given LTE cell (either the anchor, or DSS cell).
    ...
    ...  **Input Parameters:**
    ...
    ...  | **Author:** igor.binkowski@nokia.com
    ...  | **Maintainer:** adam.chamera@nokia.com
    ...
    ...  +-----------------+------+-------------------------------------------------------------------------------+
    ...  | Parameter       | Man. | Description                                                                   |
    ...  +=================+======+===============================================================================+
    ...  | lte_cell_id     | Yes  | ID of LTE cell for which ID of related NR cell should be returned.            |
    ...  +=================+======+===============================================================================+
    ...  | lnrelgnbcell_id | No   | ID of LNRELGNBCELL_A cell for which ID of related NR cell should be returned. |
    ...  |                 |      | Default value is: *                                                           |
    ...  +-----------------+------+-------------------------------------------------------------------------------+
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${nr_cell_id}=  Get Global ID Of NR Cell Related To LTE Cell  ${lte_cell_id}  1

    [Arguments]  ${lte_cell_id}  ${lnrelgnbcell_id}=*  ${alias_gnb}=default

    Return From Keyword If  ${lte_cell_id} == 0  0

    ${lnrelgnbcell_object}=   Query Infomodel  get object //SCF-*//LNCEL_A-${lte_cell_id}/LNRELGNBCELL_A-${lnrelgnbcell_id}  alias=${alias_gnb}
    ${nr_long_cell_id}=  Get From Dictionary  ${lnrelgnbcell_object}  nrCellId
    ${nrcell_l_object}=  Query Infomodel  get object //NRCELL_L-* is [nrCellIdentity=${nr_long_cell_id}]  alias=gNB
    ${nrcell_l_distname}=  Get From Dictionary  ${nrcell_l_object}  dist_name
    ${nr_global_cell_id}=  Fetch From Right  ${nrcell_l_distname}  -

    [Return]  ${nr_global_cell_id}


Verify BTS States For IWK Test
    [Documentation]
    ...  KW used to check if all modules and cells are OnAir, and if no unexpected alarms appeared for IWK tests.
    ...
    ...  | **Author:** igor.binkowski@nokia.com
    ...  | **Maintainer:** adam.chamera@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  This KW will:
    ...    - check if all existing SMODs, RMODs and cells on both eNB and gNB side are OnAir according to Infomodel
    ...      objects SMOD_R, RMOD_R, GNCEL_R, WNCEL_R, LNCEL_R and NRCELL_R.
    ...    - check if no unexpected alarms appeared on both gNB and eNB side. Alarm checking can be customized using
    ...      input parameters.
    ...
    ...  **Input Parameters:**
    ...
    ...  +---------------------+------+---------------------------------------------------+
    ...  | Parameter           | Man. | Description                                       |
    ...  +=====================+======+===================================================+
    ...  | enb_ignored_alarms  | No   | Alarm patterns which will be ignored on eNB side. |
    ...  +---------------------+------+---------------------------------------------------+
    ...  | gnb_ignored_alarms  | No   | Alarm patterns which will be ignored on gNB side. |
    ...  +---------------------+------+---------------------------------------------------+
    ...  | eNB_alias           | No   | Alias for eNB side. Default value: default.       |
    ...  +---------------------+------+---------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Step 10: Check BTS State After Test
    ...         Wait Until Keyword Succeeds  15m  3m  Verify BTS States For IWK Test

    [Arguments]  ${enb_ignored_alarms}=@{EMPTY}  ${gnb_ignored_alarms}=@{EMPTY}  ${eNB_alias}=default

    Log To Console  Checking BTS states and alarms for eNB side...
    ${use_old_admin} =  _check if old admin library is used  connection=${eNB_alias}
    Run Keyword If  ${use_old_admin}  _verify bts states for iwk test helper for old admin  ${enb_ignored_alarms}  alias=${eNB_alias}
    ...  ELSE  _verify bts states for iwk test helper  ${enb_ignored_alarms}  alias=${eNB_alias}
    Log To Console  Checking BTS states and alarms for gNB side...
    ${use_old_admin} =  _check if old admin library is used  connection=gNB
    Run Keyword If  ${use_old_admin}  _verify bts states for iwk test helper for old admin  ${gnb_ignored_alarms}  alias=gNB
    ...  ELSE  _verify bts states for iwk test helper  ${gnb_ignored_alarms}  alias=gNB

    Log To Console  BTS states verification successful. All modules and cells are OnAir, no unexpected alarms appeared.


_verify bts states for iwk test helper
    [Arguments]  ${ignored_alarms}=@{EMPTY}  ${alias}=default
    ${gncels_exist} =   Check If Cells From Specific RAT Exist In ADMIN  gsm    connection=${alias}
    ${wncels_exist} =   Check If Cells From Specific RAT Exist In ADMIN  wcdma  connection=${alias}
    ${lncels_exist} =   Check If Cells From Specific RAT Exist In ADMIN  lte    connection=${alias}
    ${nrcels_exist} =   Check If Cells From Specific RAT Exist In ADMIN  nr     connection=${alias}

	${CNI-61110_STATUS}  Set Variable If  '${alias}'=='default'  ${ENB_CNI-61110_STATUS}  ${GNB_CNI-61110_STATUS}

    ${smod_onair_states}=  Run Keyword If  ${CNI-61110_STATUS}
    ...                    Catenate  SEPARATOR=
    ...                                           operationalState=regex"[Ee]nabled",
    ...                                           administrativeState=regex"[Uu]nlocked"
    ...  ELSE               Catenate  SEPARATOR=  availabilityStatus=Online,
    ...                                           operationalState=Enabled,
    ...                                           administrativeState=Unlocked
    ${rmod_onair_states}=  Run Keyword If  ${CNI-61110_STATUS}
    ...                    Catenate  SEPARATOR=
    ...                                           operationalState=regex"[Ee]nabled",
    ...                                           administrativeState=regex"[Uu]nlocked"
    ...  ELSE               Catenate  SEPARATOR=  availabilityStatus=Online,
    ...                                           operationalState=Enabled,
    ...                                           administrativeState=Unlocked
    ${gln_cell_onair_states}=  Run Keyword If  ${CNI-61110_STATUS}
    ...                    Catenate  SEPARATOR=
    ...                                           operationalState=regex"[Ee]nabled",
    ...                                           administrativeState=regex"[Uu]nlocked",
    ...                                           blockingState=regex"[Uu]nblocked"
    ...  ELSE               Catenate  SEPARATOR=  availabilityStatus=Online,
    ...                                           operationalState=Enabled,
    ...                                           administrativeState=Unlocked,
    ...                                           blockingState=Unblocked
    ${w_cell_onair_states}=  Run Keyword If  ${CNI-61110_STATUS}
    ...                     Catenate  SEPARATOR=
    ...                                           operationalState=regex"[Ee]nabled",
    ...                                           blockingState=regex"[Uu]nblocked"
    ...  ELSE               Catenate  SEPARATOR=  availabilityStatus=Online,
    ...                                           operationalState=Enabled,
    ...                                           blockingState=Unblocked

    ${smods_onair}=
    ...  Run Keyword And Return Status  _check statuses for all objects with or without availabilityStatus
    ...  SMOD  ${smod_onair_states}  connection=${alias}  no_availability_status=${CNI-61110_STATUS}
    ${rmods_onair}=
    ...  Run Keyword And Return Status  _check statuses for all objects with or without availabilityStatus
    ...  RMOD  ${rmod_onair_states}  connection=${alias}  no_availability_status=${CNI-61110_STATUS}
    ${gncels_onair}=  Run Keyword If  ${gncels_exist}
    ...  Run Keyword And Return Status  _check statuses for all objects with or without availabilityStatus
    ...  GNCEL  ${gln_cell_onair_states}  connection=${alias}  no_availability_status=${CNI-61110_STATUS}
    ...  ELSE  Set Variable  ${TRUE}
    ${wncels_onair}=  Run Keyword If  ${wncels_exist}
    ...  Run Keyword And Return Status  _check statuses for all objects with or without availabilityStatus
    ...  WNCEL  ${w_cell_onair_states}  connection=${alias}  no_availability_status=${CNI-61110_STATUS}
    ...  ELSE  Set Variable  ${TRUE}
    ${lncels_onair}=  Run Keyword If  ${lncels_exist}
    ...  Run Keyword And Return Status  _check statuses for all objects with or without availabilityStatus
    ...  LNCEL  ${gln_cell_onair_states}  connection=${alias}  no_availability_status=${CNI-61110_STATUS}
    ...  ELSE  Set Variable  ${TRUE}
    ${nrcells_onair}=  Run Keyword If  ${nrcels_exist}
    ...  Run Keyword And Return Status  _check statuses for all objects with or without availabilityStatus
    ...  NRCEL  ${gln_cell_onair_states}  connection=${alias}  no_availability_status=${CNI-61110_STATUS}
    ...  ELSE  Set Variable  ${TRUE}

    FOR  ${alarm}  IN  @{ignored_alarms}
        Add Allowed Alarm  ${alarm}  alias=${alias}
    END

    ${alarms_status}=  Run Keyword And Return Status  Assert No Unexpected Active Alarms  alias=${alias}

    Run Keyword If  ${ignored_alarms}  Run Keywords
    ...  Clear Allowed Alarms List  alias=${alias}
    ...  AND  Add Standard Allowed Alarms  alias=${alias}

    ${statuses_dictionary}=  Create Dictionary
    ...  smods_onair=${smods_onair}  rmods_onair=${rmods_onair}
    ...  gncels_onair=${gncels_onair}  wncels_onair=${wncels_onair}
    ...  lncels_onair=${lncels_onair}  nrcells_onair=${nrcells_onair}  alarms_status=${alarms_status}
    ${pretty_statuses}=  Evaluate  pprint.pformat(${statuses_dictionary}, indent=4)  modules=pprint

    Should Be True
    ...  ${smods_onair} and ${rmods_onair} and ${gncels_onair} and ${wncels_onair} and ${lncels_onair} and ${nrcells_onair} and ${alarms_status}
    ...  msg=BTS verification failed. Details:\n${pretty_statuses}


_verify bts states for iwk test helper for old admin
    [Arguments]  ${ignored_alarms}=@{EMPTY}  ${alias}=default

    ${gncels_exist}=   Check Infomodel Object  //GNCEL_R-*   alias=${alias}
    ${wncels_exist}=   Check Infomodel Object  //WNCEL_R-*   alias=${alias}
    ${lncels_exist}=   Check Infomodel Object  //LNCEL_R-*   alias=${alias}
    ${nrcells_exist}=  Check Infomodel Object  //NRCELL_R-*  alias=${alias}

	${CNI-61110_STATUS}  Set Variable If  '${alias}'=='default'  ${ENB_CNI-61110_STATUS}  ${GNB_CNI-61110_STATUS}

    ${smod_onair_states}=  Run Keyword If  ${CNI-61110_STATUS}
    ...                    Catenate  SEPARATOR=  [availabilityStatus=empty,
    ...                                           operationalState=regex"[Ee]nabled",
    ...                                           administrativeState=regex"[Uu]nlocked"]
    ...  ELSE               Catenate  SEPARATOR=  [stateInfo.availabilityStatus=Online,
    ...                                           stateInfo.operationalState=Enabled,
    ...                                           stateInfo.administrativeState=Unlocked]
    ${rmod_onair_states}=  Run Keyword If  ${CNI-61110_STATUS}
    ...                    Catenate  SEPARATOR=  [availabilityStatus=empty,
    ...                                           operationalState=regex"[Ee]nabled",
    ...                                           administrativeState=regex"[Uu]nlocked"]
    ...  ELSE               Catenate  SEPARATOR=  [stateInfo.availabilityStatus=Online,
    ...                                           stateInfo.operationalState=Enabled,
    ...                                           stateInfo.administrativeState=Unlocked]
    ${gln_cell_onair_states}=  Run Keyword If  ${CNI-61110_STATUS}
    ...                    Catenate  SEPARATOR=  [availabilityStatus=empty,
    ...                                           operationalState=regex"[Ee]nabled",
    ...                                           administrativeState=regex"[Uu]nlocked",
    ...                                           blockingState=regex"[Uu]nblocked"]
    ...  ELSE               Catenate  SEPARATOR=  [stateInfo.availabilityStatus=Online,
    ...                                           stateInfo.operationalState=Enabled,
    ...                                           stateInfo.administrativeState=Unlocked,
    ...                                           stateInfo.blockingState=Unblocked]
    ${w_cell_onair_states}=  Run Keyword If  ${CNI-61110_STATUS}
    ...                     Catenate  SEPARATOR=  [availabilityStatus=empty,
    ...                                           operationalState=regex"[Ee]nabled",
    ...                                           blockingState=regex"[Uu]nblocked"]
    ...  ELSE               Catenate  SEPARATOR=  [stateInfo.availabilityStatus=Online,
    ...                                           stateInfo.operationalState=Enabled,
    ...                                           stateInfo.administrativeState=Unlocked]

    ${smods_onair}=
    ...  Query Infomodel  every //SMOD_R-* is ${smod_onair_states}  allow_negative_result=True  alias=${alias}
    ${rmods_onair}=
    ...  Query Infomodel  every //RMOD_R-* is ${rmod_onair_states}  allow_negative_result=True  alias=${alias}
    ${gncels_onair}=  Run Keyword If  ${gncels_exist}
    ...  Query Infomodel  every //GNCEL_R-* is ${gln_cell_onair_states}  allow_negative_result=True  alias=${alias}
    ...  ELSE  Set Variable  ${TRUE}
    ${wncels_onair}=  Run Keyword If  ${wncels_exist}
    ...  Query Infomodel  every //WNCEL_R-* is ${w_cell_onair_states}  allow_negative_result=True  alias=${alias}
    ...  ELSE  Set Variable  ${TRUE}
    ${lncels_onair}=  Run Keyword If  ${lncels_exist}
    ...  Query Infomodel  every //LNCEL_R-* is ${gln_cell_onair_states}  allow_negative_result=True  alias=${alias}
    ...  ELSE  Set Variable  ${TRUE}
    ${nrcells_onair}=  Run Keyword If  ${nrcells_exist}
    ...  Query Infomodel  every //NRCELL_R-* is ${gln_cell_onair_states}  allow_negative_result=True  alias=${alias}
    ...  ELSE  Set Variable  ${TRUE}

    FOR  ${alarm}  IN  @{ignored_alarms}
        Add Allowed Alarm  ${alarm}  alias=${alias}
    END

    ${alarms_status}=  Run Keyword And Return Status  Assert No Unexpected Active Alarms  alias=${alias}

    Run Keyword If  ${ignored_alarms}  Run Keywords
    ...  Clear Allowed Alarms List  alias=${alias}
    ...  AND  Add Standard Allowed Alarms  alias=${alias}

    ${statuses_dictionary}=  Create Dictionary
    ...  smods_onair=${smods_onair}  rmods_onair=${rmods_onair}
    ...  gncels_onair=${gncels_onair}  wncels_onair=${wncels_onair}
    ...  lncels_onair=${lncels_onair}  nrcells_onair=${nrcells_onair}  alarms_status=${alarms_status}
    ${pretty_statuses}=  Evaluate  pprint.pformat(${statuses_dictionary}, indent=4)  modules=pprint

    Should Be True
    ...  ${smods_onair} and ${rmods_onair} and ${gncels_onair} and ${wncels_onair} and ${lncels_onair} and ${nrcells_onair} and ${alarms_status}
    ...  msg=BTS verification failed. Details:\n${pretty_statuses}


_check statuses for all objects with or without availabilityStatus
    [Arguments]  ${class_name}  ${states}  ${connection}=default  ${no_availability_status}=True
    Run Keyword If  ${no_availability_status}  Run Keywords  Assert Every  ${class_name}  ${states}  connection=${connection}
    ...  AND  Assert No  ${class_name}  availabilityStatus!=empty  connection=${connection}
    ...  ELSE  Assert Every  ${class_name}  ${states}  connection=${connection}


_check if old admin library is used
    [Arguments]  ${connection}
    ${uses_new_admin} =  Run Keyword And Return Status  Get BTS Info  connection=${connection}
    ${uses_old_admin} =  Run Keyword And Return Status  Get BTS Info  alias=${connection}
    ${uses_old_admin} =  Run Keyword If  not ${uses_new_admin} and not ${uses_old_admin}
    ...  Fail  Get BST Statuses failed for both ADMIN libraries.
    ...  ELSE IF  ${uses_new_admin}  Set Variable  ${FALSE}
    ...  ELSE  Set Variable  ${TRUE}
    [Return]  ${uses_old_admin}


Set Test Variables For LTE4750 Test
    [Documentation]
    ...  KW used to set test variables common for LTE4750 tests.
    ...
    ...  | **Author:** igor.binkowski@nokia.com
    ...  | **Maintainer:** adam.chamera@nokia.com
    ...
    ...  **Full description:**
    ...
    ...  KW used to set test variables common for all LTE4750 tests, based on ${LTE_CELL_ID} and ${LTE_ANCHOR_CELL_ID}.
    ...  If either of these variables is not set in the test, it will be set to 0 for simplicity's sake.
    ...
    ...  Variables which are set:
    ...
    ...  Generic variables:
    ...  - ${LNBTS_ID} - ID of LNBTS object on eNB side
    ...  - ${NR_CELL_ID} - ID of NR cell sharing resources with defined LTE cell
    ...  - ${NR_PHY_CELL_ID} - physical ID of NR cell sharing resources with defined LTE cell
    ...  - ${NRBTS_ID} - ID of NRBTS object on gNB side
    ...  - ${LNBTS_IP} - IP of LNBTS, used for Wireshark log collection
    ...  - ${ONAIR_CELL_STATES} - string used for convenient checking of both LTE and NR cell states
    ...  - ${LTE_DSS_CELL_ID_LIST} - list of all LTE cells with DSS enabled
    ...  - ${NR_DSS_CELL_ID_LIST} - list of all NR cells with DSS enabled
    ...
    ...  ADMIN object distnames:
    ...  - ${LTE_LNBTS_DISTNAME} - e.g. MRBTS-<LNBTS ID>/LNBTS-<LNBTS ID>
    ...  - ${LTE_LNBTS_FDD_DISTNAME} - e.g. MRBTS-<LNBTS ID>/LNBTS-<LNBTS ID>/LNBTS_FDD-0
    ...  - ${LTE_LNCEL_DISTNAME} - e.g. MRBTS-<LNBTS ID>/LNBTS-<LNBTS ID>/LNCEL-<LTE cell ID>
    ...  - ${LTE_LNCEL_PARTIAL_DISTNAME} - Partial DN, e.g. MRBTS-<LNBTS ID>/LNBTS-<LNBTS ID>/LNCEL-
    ...  - ${LTE_LNCEL_RUNTIME_DISTNAME} - e.g. /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-<LNBTS ID>/LNCEL_R-<LTE cell ID>.
    ...    Needed for cell blocking
    ...  - ${LTE_ANCHOR_LNCEL_DISTNAME} -  e.g. MRBTS-<LNBTS ID>/LNBTS-<LNBTS ID>/LNCEL-<anchor LTE cell ID>
    ...  - ${NR_NRBTS_DISTNAME} - e.g. MRBTS-<NRBTS ID>/NRBTS-<NRBTS ID>
    ...  - ${NR_NRCEL_DISTNAME} - e.g. MRBTS-<NRBTS ID>/NRBTS-<NRBTS ID>/NRCELL-<NR cell ID>
    ...  - ${NR_NRCEL_PARTIAL_DISTNAME} - Partial DN, e.g.MRBTS-<NRBTS ID>/NRBTS-<NRBTS ID>/NRCELL-
    ...
    ...  Strings for InfoModel queries:
    ...  - ${ONAIR_CELL_STATES} - OnAir cell states string
    ...  - ${LOCKED_CELL_STATES} - locked cell states string
    ...  - ${BLOCKED_CELL_STATES} - blocked cell states string
    ...
    ...  Flags:
    ...  - ${ENB_PARAMETERS_CHANGED} - indicating that some parameters in eNB were modified
    ...  - ${GNB_PARAMETERS_CHANGED} - indicating that some parameters in gNB were modified
    ...  - ${SWCONFIG_CHANGED} - indicating that swconfig.txt was changed on either side
    ...
    ...  **Input Parameters:**
    ...
    ...  | **Author:** igor.binkowski@nokia.com
    ...  | **Maintainer:** monika.ceglarek@nokia.com
    ...
    ...  +-----------------+------+-------------------------------------------------------------------------------+
    ...  | Parameter       | Man. | Description                                                                   |
    ...  +=================+======+===============================================================================+
    ...  | lnrelgnbcell_id | No   | ID of LNRELGNBCELL_A cell for which ID of related NR cell should be returned. |
    ...  |                 |      | Default value is: *                                                           |
    ...  +-----------------+------+-------------------------------------------------------------------------------+
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Step 0: Preconditions
    ...         Set Test Variables For LTE4750 Test  ${lnrelgnbcell_id}
    ...         Check Preconditions For LTE4750 Test

    [Arguments]  ${lnrelgnbcell_id}=*

    ${LTE_CELL_ID}=  Get Variable Value  ${LTE_CELL_ID}  0
    ${LTE_ANCHOR_CELL_ID}=  Get Variable Value  ${LTE_ANCHOR_CELL_ID}  0

    ${LNBTS_ID}=    Get BTS ID From ADMIN
    Set Test Variable  ${LNBTS_ID}

    ${NR_CELL_ID}=  Get Global ID Of NR Cell Related To LTE Cell  ${LTE_CELL_ID}  ${lnrelgnbcell_id}
    Set Test Variable  ${NR_CELL_ID}
    ${nrcell_a_object}=  Get Infomodel Object  //NRCELL_A-${NR_CELL_ID}  alias=gNB
    Set Test Variable  ${NR_PHY_CELL_ID}  ${nrcell_a_object['physCellId']}

    ${NRBTS_ID}=    Get BTS ID From ADMIN  alias=gNB
    Set Test Variable  ${NRBTS_ID}

    ${enb_ip}=  Get Infomodel Object  //MRBTS_A-${LNBTS_ID}/TNLSVC_A-1/TNL_A-1/IPNO_A-1/IPIF_A-1/IPADDRESSV4_A-1
    Set Test Variable  ${LNBTS_IP}  ${enb_ip['localIpAddr']}
    ${gnb_ip}=  Get Infomodel Object  //MRBTS_A-${NRBTS_ID}/TNLSVC_A-1/TNL_A-1/IPNO_A-1/IPIF_A-1/IPADDRESSV4_A-1  alias=gNB
    Set Test Variable  ${NRBTS_IP}  ${gnb_ip['localIpAddr']}

    ${lte_dss_cells_list} =  Query Infomodel  get list //LNCEL_A-* is [lteNrDssMode=DL_CRS_TDM_UL_FDM]
    ${lte_dss_cell_id_list} =  Create List
    FOR  ${lncel}  IN  @{lte_dss_cells_list}
        ${lte_dss_cell_id} =  Convert Dist Name To ID  ${lncel['dist_name']}
        Append To List  ${lte_dss_cell_id_list}  ${lte_dss_cell_id}
    END
    Set Test Variable  ${LTE_DSS_CELL_ID_LIST}  ${lte_dss_cell_id_list}

    ${nr_dss_cells_list} =  Query Infomodel  get list //SCF-*//NRCELL_A-* is [lteNrDssMode=DL_CRS_TDM_UL_FDM]  alias=gNB
    ${nr_dss_cell_id_list} =  Create List
    FOR  ${nrcel}  IN  @{nr_dss_cells_list}
        ${nr_dss_cell_id} =  Convert Dist Name To ID  ${nrcel['dist_name']}
        Append To List  ${nr_dss_cell_id_list}  ${nr_dss_cell_id}
    END
    Set Test Variable  ${NR_DSS_CELL_ID_LIST}  ${nr_dss_cell_id_list}

    ${enb_ip} =  Get Infomodel Object  //MRBTS_A-${LNBTS_ID}/TNLSVC_A-1/TNL_A-1/IPNO_A-1/IPIF_A-1/IPADDRESSV4_A-1
    Set Test Variable  ${LNBTS_IP}  ${enb_ip['localIpAddr']}

    Set Test Variable  ${LTE_LNBTS_DISTNAME}    MRBTS-${LNBTS_ID}/LNBTS-${LNBTS_ID}
    Set Test Variable  ${LTE_LNBTS_FDD_DISTNAME}    MRBTS-${LNBTS_ID}/LNBTS-${LNBTS_ID}/LNBTS_FDD-0
    Set Test Variable  ${LTE_LNCEL_DISTNAME}    MRBTS-${LNBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${LTE_CELL_ID}
    Set Test Variable  ${LTE_LNCEL_PARTIAL_DISTNAME}    MRBTS-${lnbts_id}/LNBTS-${lnbts_id}/LNCEL-
    Set Test Variable  ${LTE_LNCEL_RUNTIME_DISTNAME}
    ...  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-${lnbts_id}/LNCEL_R-${LTE_CELL_ID}
    Set Test Variable  ${LTE_ANCHOR_LNCEL_DISTNAME}     MRBTS-${LNBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${LTE_ANCHOR_CELL_ID}
    Set Test Variable  ${NR_NRBTS_DISTNAME}     MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}
    Set Test Variable  ${NR_NRCEL_DISTNAME}     MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}
    Set Test Variable  ${NR_NRCEL_PARTIAL_DISTNAME}     MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-

    ${onair_cell_states}=  Run Keyword If  ${ENB_CNI-61110_STATUS}
    ...                    Catenate  SEPARATOR=  [availabilityStatus=empty,
    ...                                           operationalState=regex"[Ee]nabled",
    ...                                           administrativeState=regex"[Uu]nlocked",
    ...                                           blockingState=regex"[Uu]nblocked"]
    ...  ELSE               Catenate  SEPARATOR=  [stateInfo.availabilityStatus=Online,
    ...                                           stateInfo.operationalState=Enabled,
    ...                                           stateInfo.administrativeState=Unlocked,
    ...                                           stateInfo.blockingState=Unblocked]
    ${locked_cell_states}=  Run Keyword If  ${ENB_CNI-61110_STATUS}
    ...                    Catenate  SEPARATOR=  [administrativeState=regex"[lL]ocked",
    ...                                           availabilityStatus=regex"off line",
    ...                                           blockingState=regex"[uU]nblocked",
    ...                                           operationalState=regex"[dD]isabled"]
    ...  ELSE              Catenate  SEPARATOR=  [stateInfo.administrativeState=Locked,
    ...                                           stateInfo.availabilityStatus=Offline,
    ...                                           stateInfo.blockingState=Unblocked,
    ...                                           stateInfo.operationalState=Disabled]
    ${blocked_cell_states}=  Run Keyword If  ${ENB_CNI-61110_STATUS}
    ...                    Catenate  SEPARATOR=   [administrativeState=regex"[Uu]nlocked",
    ...                                            availabilityStatus=regex"off line",
    ...                                            blockingState=regex"[Bb]locked",
    ...                                            operationalState=regex"[Dd]isabled"]
    ...  ELSE              Catenate  SEPARATOR=  [stateInfo.administrativeState=Unlocked,
    ...                                           stateInfo.availabilityStatus=Offline,
    ...                                           stateInfo.blockingState=Blocked,
    ...                                           stateInfo.operationalState=Disabled]


    Set Test Variable  ${ONAIR_CELL_STATES}  ${onair_cell_states}
    Set Test Variable  ${LOCKED_CELL_STATES}  ${locked_cell_states}
    Set Test Variable  ${BLOCKED_CELL_STATES}  ${blocked_cell_states}

    ${gnb_onair_cell_states}=  Run Keyword If  ${GNB_CNI-61110_STATUS}
    ...                    Catenate  SEPARATOR=  [availabilityStatus=empty,
    ...                                           operationalState=regex"[Ee]nabled",
    ...                                           administrativeState=regex"[Uu]nlocked",
    ...                                           blockingState=regex"[Uu]nblocked"]
    ...  ELSE               Catenate  SEPARATOR=  [stateInfo.availabilityStatus=Online,
    ...                                           stateInfo.operationalState=Enabled,
    ...                                           stateInfo.administrativeState=Unlocked,
    ...                                           stateInfo.blockingState=Unblocked]
    ${gnb_locked_cell_states}=  Run Keyword If  ${GNB_CNI-61110_STATUS}
    ...                    Catenate  SEPARATOR=  [administrativeState=regex"[lL]ocked",
    ...                                           availabilityStatus=regex"off line",
    ...                                           blockingState=regex"[uU]nblocked",
    ...                                           operationalState=regex"[dD]isabled"]
    ...  ELSE              Catenate  SEPARATOR=  [stateInfo.administrativeState=Locked,
    ...                                           stateInfo.availabilityStatus=Offline,
    ...                                           stateInfo.blockingState=Unblocked,
    ...                                           stateInfo.operationalState=Disabled]
    ${gnb_blocked_cell_states}=  Run Keyword If  ${GNB_CNI-61110_STATUS}
    ...                    Catenate  SEPARATOR=   [administrativeState=regex"[Uu]nlocked",
    ...                                            availabilityStatus=regex"off line",
    ...                                            blockingState=regex"[Bb]locked",
    ...                                            operationalState=regex"[Dd]isabled"]
    ...  ELSE              Catenate  SEPARATOR=  [stateInfo.administrativeState=Unlocked,
    ...                                           stateInfo.availabilityStatus=Offline,
    ...                                           stateInfo.blockingState=Blocked,
    ...                                           stateInfo.operationalState=Disabled]


    Set Test Variable  ${GNB_ONAIR_CELL_STATES}  ${gnb_onair_cell_states}
    Set Test Variable  ${GNB_LOCKED_CELL_STATES}  ${gnb_locked_cell_states}
    Set Test Variable  ${GNB_BLOCKED_CELL_STATES}  ${gnb_blocked_cell_states}

    Set Test Variable  ${ENB_PARAMETERS_CHANGED}  False
    Set Test Variable  ${GNB_PARAMETERS_CHANGED}  False


Set Test Variables For CB005860 Test
    [Documentation]
    ...  KW used to set test variables common for CB005860 tests.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full description:**
    ...
    ...  KW used to set test variables common for all CB005860 tests, based on ${LTE_CELL_ID} and ${LTE_ANCHOR_CELL_ID}.
    ...  If either of these variables is not set in the test, it will be set to 0 for simplicity's sake.
    ...
    ...  Variables which are set:
    ...
    ...  Generic variables:
    ...  - ${LTE_PHY_CELL_ID} - physical ID of LTE cell
    ...  - ${LNBTS_ID} - ID of LNBTS object on eNB side
    ...  - ${NR_CELL_ID} - ID of NR cell sharing resources with defined LTE cell
    ...  - ${NR_PHY_CELL_ID} - physical ID of NR cell sharing resources with defined LTE cell
    ...  - ${NRBTS_ID} - ID of NRBTS object on gNB side
    ...  - ${ONAIR_CELL_STATES} - string used for convenient checking of both LTE and NR cell states
    ...  - ${LTE_DSS_CELL_ID_LIST} - list of all LTE cells with DSS enabled
    ...  - ${NR_DSS_CELL_ID_LIST} - list of all NR cells with DSS enabled
    ...
    ...  ADMIN object distnames:
    ...  - ${LTE_LNBTS_DISTNAME} - e.g. MRBTS-<LNBTS ID>/LNBTS-<LNBTS ID>
    ...  - ${LTE_LNBTS_FDD_DISTNAME} - e.g. MRBTS-<LNBTS ID>/LNBTS-<LNBTS ID>/LNBTS_FDD-0
    ...  - ${LTE_LNCEL_DISTNAME} - e.g. MRBTS-<LNBTS ID>/LNBTS-<LNBTS ID>/LNCEL-<LTE cell ID>
    ...  - ${LTE_LNCEL_PARTIAL_DISTNAME} - Partial DN, e.g. MRBTS-<LNBTS ID>/LNBTS-<LNBTS ID>/LNCEL-
    ...  - ${LTE_LNCEL_RUNTIME_DISTNAME} - e.g. /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-<LNBTS ID>/LNCEL_R-<LTE cell ID>.
    ...    Needed for cell blocking
    ...  - ${LTE_ANCHOR_LNCEL_DISTNAME} -  e.g. MRBTS-<LNBTS ID>/LNBTS-<LNBTS ID>/LNCEL-<anchor LTE cell ID>
    ...  - ${NR_NRBTS_DISTNAME} - e.g. MRBTS-<NRBTS ID>/NRBTS-<NRBTS ID>
    ...  - ${NR_NRCEL_DISTNAME} - e.g. MRBTS-<NRBTS ID>/NRBTS-<NRBTS ID>/NRCELL-<NR cell ID>
    ...  - ${NR_NRCEL_PARTIAL_DISTNAME} - Partial DN, e.g.MRBTS-<NRBTS ID>/NRBTS-<NRBTS ID>/NRCELL-
    ...
    ...  Strings for InfoModel queries:
    ...  - ${ONAIR_CELL_STATES} - OnAir cell states string
    ...  - ${LOCKED_CELL_STATES} - locked cell states string
    ...  - ${BLOCKED_CELL_STATES} - blocked cell states string
    ...
    ...  Flags:
    ...  - ${ENB_PARAMETERS_CHANGED} - indicating that some parameters in eNB were modified
    ...  - ${GNB_PARAMETERS_CHANGED} - indicating that some parameters in gNB were modified
    ...
    ...  **Input Parameters:**
    ...
    ...  | **Author:** igor.binkowski@nokia.com
    ...  | **Maintainer:** monika.ceglarek@nokia.com
    ...
    ...  +-----------------+------+-------------------------------------------------------------------------------+
    ...  | Parameter       | Man. | Description                                                                   |
    ...  +=================+======+===============================================================================+
    ...  | lnrelgnbcell_id | No   | ID of LNRELGNBCELL_A cell for which ID of related NR cell should be returned. |
    ...  |                 |      | Default value is: *                                                           |
    ...  +-----------------+------+-------------------------------------------------------------------------------+
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Step 0: Preconditions
    ...         Set Test Variables For LTE4750 Test  ${lnrelgnbcell_id}
    ...         Check Preconditions For LTE4750 Test

    [Arguments]  ${lnrelgnbcell_id}=*

    ${scf_path_enb}  ${parsed_scf_enb}=  Save And Parse SCF  SCF_eNB
    Set Test Variable  ${SCF_PATH_ENB}  ${scf_path_enb}
    Set Test Variable  ${PARSED_SCF_ENB}  ${parsed_scf_enb}

    ${scf_path_gnb}  ${parsed_scf_gnb}=  Save And Parse SCF  SCF_gNB  alias=gNB
    Set Test Variable  ${SCF_PATH_GNB}  ${scf_path_gnb}
    Set Test Variable  ${PARSED_SCF_GNB}  ${parsed_scf_gnb}

    ${LTE_CELL_ID}=  Get Variable Value  ${LTE_CELL_ID}  0
    ${LTE_ANCHOR_CELL_ID}=  Get Variable Value  ${LTE_ANCHOR_CELL_ID}  0
    ${lte_phys_cell_id} =  Get Parameter Value From SCF  ${PARSED_SCF_ENB}  LNCEL  LNCEL-${LTE_CELL_ID}  /p[@name='phyCellId']
    ...  dist_name_substring=True
    Set Test Variable  ${LTE_PHY_CELL_ID}  ${lte_phys_cell_id}

    ${LNBTS_ID}=    Get BTS ID From ADMIN
    Set Test Variable  ${LNBTS_ID}

    ${NR_CELL_ID}=  Get Global ID Of NR Cell Related To LTE Cell  ${LTE_CELL_ID}  ${lnrelgnbcell_id}
    Set Test Variable  ${NR_CELL_ID}
    ${nr_phys_cell_id} =  Get Parameter Value From SCF  ${PARSED_SCF_GNB}  NRCELL  NRCELL-${NR_CELL_ID}
    ...  /p[@name='physCellId']  dist_name_substring=True
    Set Test Variable  ${NR_PHY_CELL_ID}  ${nr_phys_cell_id}

    ${NRBTS_ID}=    Get BTS ID From ADMIN  alias=gNB
    Set Test Variable  ${NRBTS_ID}

    ${lncel_dss_xpath} =  Catenate  SEPARATOR=
    ...  .//managedObject[substring(@class, string-length(@class) - string-length('LNCEL') + 1) = 'LNCEL']
    ...  /p[@name='lteNrDssMode'][.='DSS_Phase_III']/..
    ${lncel_dss_elements} =  Get Elements  ${PARSED_SCF_ENB}  ${lncel_dss_xpath}
    ${lte_dss_cell_id_list} =  Create List
    FOR  ${lncel_element}  IN  @{lncel_dss_elements}
        ${lncel_dist_name} =  XML.Get Element Attribute  ${lncel_element}  distName
        ${lte_dss_cell_id} =  Convert Dist Name To ID  ${lncel_dist_name}
        Append To List  ${lte_dss_cell_id_list}  ${lte_dss_cell_id}
    END
    Set Test Variable  ${LTE_DSS_CELL_ID_LIST}  ${lte_dss_cell_id_list}

    ${nrcel_dss_xpath} =  Catenate  SEPARATOR=
    ...  .//managedObject[substring(@class, string-length(@class) - string-length('NRCELL') + 1) = 'NRCELL']
    ...  /p[@name='lteNrDssMode'][.='DSS_Phase_3']/..
    ${nrcel_dss_elements} =  Get Elements  ${PARSED_SCF_GNB}  ${nrcel_dss_xpath}
    ${nr_dss_cell_id_list} =  Create List
    FOR  ${nrcel_element}  IN  @{nrcel_dss_elements}
        ${nrcel_dist_name} =  XML.Get Element Attribute  ${nrcel_element}  distName
        ${nr_dss_cell_id} =  Convert Dist Name To ID  ${nrcel_dist_name}
        Append To List  ${nr_dss_cell_id_list}  ${nr_dss_cell_id}
    END
    Set Test Variable  ${NR_DSS_CELL_ID_LIST}  ${nr_dss_cell_id_list}

    Set Test Variable  ${LTE_LNBTS_DISTNAME}    MRBTS-${LNBTS_ID}/LNBTS-${LNBTS_ID}
    Set Test Variable  ${LTE_LNBTS_FDD_DISTNAME}    MRBTS-${LNBTS_ID}/LNBTS-${LNBTS_ID}/LNBTS_FDD-0
    Set Test Variable  ${LTE_LNCEL_DISTNAME}    MRBTS-${LNBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${LTE_CELL_ID}
    Set Test Variable  ${LTE_LNCEL_PARTIAL_DISTNAME}    MRBTS-${lnbts_id}/LNBTS-${lnbts_id}/LNCEL-
    Set Test Variable  ${LTE_LNCEL_RUNTIME_DISTNAME}
    ...  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-${lnbts_id}/LNCEL_R-${LTE_CELL_ID}
    Set Test Variable  ${LTE_ANCHOR_LNCEL_DISTNAME}     MRBTS-${LNBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${LTE_ANCHOR_CELL_ID}
    Set Test Variable  ${NR_NRBTS_DISTNAME}     MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}
    Set Test Variable  ${NR_NRCEL_DISTNAME}     MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}
    Set Test Variable  ${NR_NRCEL_PARTIAL_DISTNAME}     MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-

    ${onair_cell_states}=  Run Keyword If  ${ENB_CNI-61110_STATUS}
    ...                    Catenate  SEPARATOR=  [availabilityStatus=empty,
    ...                                           operationalState=regex"[Ee]nabled",
    ...                                           administrativeState=regex"[Uu]nlocked",
    ...                                           blockingState=regex"[Uu]nblocked"]
    ...  ELSE               Catenate  SEPARATOR=  [stateInfo.availabilityStatus=Online,
    ...                                           stateInfo.operationalState=Enabled,
    ...                                           stateInfo.administrativeState=Unlocked,
    ...                                           stateInfo.blockingState=Unblocked]
    ${locked_cell_states}=  Run Keyword If  ${ENB_CNI-61110_STATUS}
    ...                    Catenate  SEPARATOR=  [administrativeState=regex"[lL]ocked",
    ...                                           availabilityStatus=regex"off line",
    ...                                           blockingState=regex"[uU]nblocked",
    ...                                           operationalState=regex"[dD]isabled"]
    ...  ELSE              Catenate  SEPARATOR=  [stateInfo.administrativeState=Locked,
    ...                                           stateInfo.availabilityStatus=Offline,
    ...                                           stateInfo.blockingState=Unblocked,
    ...                                           stateInfo.operationalState=Disabled]
    ${blocked_cell_states}=  Run Keyword If  ${ENB_CNI-61110_STATUS}
    ...                    Catenate  SEPARATOR=   [administrativeState=regex"[Uu]nlocked",
    ...                                            availabilityStatus=regex"off line",
    ...                                            blockingState=regex"[Bb]locked",
    ...                                            operationalState=regex"[Dd]isabled"]
    ...  ELSE              Catenate  SEPARATOR=  [stateInfo.administrativeState=Unlocked,
    ...                                           stateInfo.availabilityStatus=Offline,
    ...                                           stateInfo.blockingState=Blocked,
    ...                                           stateInfo.operationalState=Disabled]


    Set Test Variable  ${ONAIR_CELL_STATES}  ${onair_cell_states}
    Set Test Variable  ${LOCKED_CELL_STATES}  ${locked_cell_states}
    Set Test Variable  ${BLOCKED_CELL_STATES}  ${blocked_cell_states}

    ${gnb_onair_cell_states}=  Run Keyword If  ${GNB_CNI-61110_STATUS}
    ...                    Catenate  SEPARATOR=  [availabilityStatus=empty,
    ...                                           operationalState=regex"[Ee]nabled",
    ...                                           administrativeState=regex"[Uu]nlocked",
    ...                                           blockingState=regex"[Uu]nblocked"]
    ...  ELSE               Catenate  SEPARATOR=  [stateInfo.availabilityStatus=Online,
    ...                                           stateInfo.operationalState=Enabled,
    ...                                           stateInfo.administrativeState=Unlocked,
    ...                                           stateInfo.blockingState=Unblocked]
    ${gnb_locked_cell_states}=  Run Keyword If  ${GNB_CNI-61110_STATUS}
    ...                    Catenate  SEPARATOR=  [administrativeState=regex"[lL]ocked",
    ...                                           availabilityStatus=regex"off line",
    ...                                           blockingState=regex"[uU]nblocked",
    ...                                           operationalState=regex"[dD]isabled"]
    ...  ELSE              Catenate  SEPARATOR=  [stateInfo.administrativeState=Locked,
    ...                                           stateInfo.availabilityStatus=Offline,
    ...                                           stateInfo.blockingState=Unblocked,
    ...                                           stateInfo.operationalState=Disabled]
    ${gnb_blocked_cell_states}=  Run Keyword If  ${GNB_CNI-61110_STATUS}
    ...                    Catenate  SEPARATOR=   [administrativeState=regex"[Uu]nlocked",
    ...                                            availabilityStatus=regex"off line",
    ...                                            blockingState=regex"[Bb]locked",
    ...                                            operationalState=regex"[Dd]isabled"]
    ...  ELSE              Catenate  SEPARATOR=  [stateInfo.administrativeState=Unlocked,
    ...                                           stateInfo.availabilityStatus=Offline,
    ...                                           stateInfo.blockingState=Blocked,
    ...                                           stateInfo.operationalState=Disabled]


    Set Test Variable  ${GNB_ONAIR_CELL_STATES}  ${gnb_onair_cell_states}
    Set Test Variable  ${GNB_LOCKED_CELL_STATES}  ${gnb_locked_cell_states}
    Set Test Variable  ${GNB_BLOCKED_CELL_STATES}  ${gnb_blocked_cell_states}

    Set Test Variable  ${ENB_PARAMETERS_CHANGED}  False
    Set Test Variable  ${GNB_PARAMETERS_CHANGED}  False


Set Test Variables For CB005860 Test Single BTS
    [Documentation]
    ...  KW used to set test variables common for CB005860 tests and Single BTS.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full description:**
    ...
    ...  KW used to set test variables common for all CB005860 tests, based on ${LTE_CELL_ID} and ${LTE_ANCHOR_CELL_ID}.
    ...  If either of these variables is not set in the test, it will be set to 0 for simplicity's sake.
    ...
    ...  Variables which are set:
    ...
    ...  Generic variables:
    ...  - ${LTE_PHY_CELL_ID} - physical ID of LTE cell
    ...  - ${LNBTS_ID} - ID of LNBTS object on eNB side
    ...  - ${NR_CELL_ID} - ID of NR cell sharing resources with defined LTE cell
    ...  - ${NR_PHY_CELL_ID} - physical ID of NR cell sharing resources with defined LTE cell
    ...  - ${NRBTS_ID} - ID of NRBTS object on gNB side
    ...  - ${ONAIR_CELL_STATES} - string used for convenient checking of both LTE and NR cell states
    ...  - ${LTE_DSS_CELL_ID_LIST} - list of all LTE cells with DSS enabled
    ...  - ${NR_DSS_CELL_ID_LIST} - list of all NR cells with DSS enabled
    ...
    ...  ADMIN object distnames:
    ...  - ${LTE_LNBTS_DISTNAME} - e.g. MRBTS-<LNBTS ID>/LNBTS-<LNBTS ID>
    ...  - ${LTE_LNBTS_FDD_DISTNAME} - e.g. MRBTS-<LNBTS ID>/LNBTS-<LNBTS ID>/LNBTS_FDD-0
    ...  - ${LTE_LNCEL_DISTNAME} - e.g. MRBTS-<LNBTS ID>/LNBTS-<LNBTS ID>/LNCEL-<LTE cell ID>
    ...  - ${LTE_LNCEL_PARTIAL_DISTNAME} - Partial DN, e.g. MRBTS-<LNBTS ID>/LNBTS-<LNBTS ID>/LNCEL-
    ...  - ${LTE_LNCEL_RUNTIME_DISTNAME} - e.g. /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-<LNBTS ID>/LNCEL_R-<LTE cell ID>.
    ...    Needed for cell blocking
    ...  - ${LTE_ANCHOR_LNCEL_DISTNAME} -  e.g. MRBTS-<LNBTS ID>/LNBTS-<LNBTS ID>/LNCEL-<anchor LTE cell ID>
    ...  - ${NR_NRBTS_DISTNAME} - e.g. MRBTS-<NRBTS ID>/NRBTS-<NRBTS ID>
    ...  - ${NR_NRCEL_DISTNAME} - e.g. MRBTS-<NRBTS ID>/NRBTS-<NRBTS ID>/NRCELL-<NR cell ID>
    ...  - ${NR_NRCEL_PARTIAL_DISTNAME} - Partial DN, e.g.MRBTS-<NRBTS ID>/NRBTS-<NRBTS ID>/NRCELL-
    ...
    ...  Strings for InfoModel queries:
    ...  - ${ONAIR_CELL_STATES} - OnAir cell states string
    ...  - ${LOCKED_CELL_STATES} - locked cell states string
    ...  - ${BLOCKED_CELL_STATES} - blocked cell states string
    ...
    ...  Flags:
    ...  - ${ENB_PARAMETERS_CHANGED} - indicating that some parameters in eNB were modified
    ...  - ${GNB_PARAMETERS_CHANGED} - indicating that some parameters in gNB were modified
    ...
    ...  **Input Parameters:**
    ...
    ...  | **Author:** igor.binkowski@nokia.com
    ...  | **Maintainer:** monika.ceglarek@nokia.com
    ...
    ...  +-----------------+------+-------------------------------------------------------------------------------+
    ...  | Parameter       | Man. | Description                                                                   |
    ...  +=================+======+===============================================================================+
    ...  | lnrelgnbcell_id | No   | ID of LNRELGNBCELL_A cell for which ID of related NR cell should be returned. |
    ...  |                 |      | Default value is: *                                                           |
    ...  +-----------------+------+-------------------------------------------------------------------------------+
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Step 0: Preconditions
    ...         Set Test Variables For LTE4750 Test  ${lnrelgnbcell_id}
    ...         Check Preconditions For LTE4750 Test

    [Arguments]  ${lnrelgnbcell_id}=*

    ${scf_path_enb}  ${parsed_scf_enb}=  Save And Parse SCF  SCF_eNB  alias=gNB
    Set Test Variable  ${SCF_PATH_ENB}  ${scf_path_enb}
    Set Test Variable  ${PARSED_SCF_ENB}  ${parsed_scf_enb}

    ${scf_path_gnb}  ${parsed_scf_gnb}=  Save And Parse SCF  SCF_gNB  alias=gNB
    Set Test Variable  ${SCF_PATH_GNB}  ${scf_path_gnb}
    Set Test Variable  ${PARSED_SCF_GNB}  ${parsed_scf_gnb}

    ${LTE_CELL_ID}=  Get Variable Value  ${LTE_CELL_ID}  0
    ${LTE_ANCHOR_CELL_ID}=  Get Variable Value  ${LTE_ANCHOR_CELL_ID}  0
    ${lte_phys_cell_id} =  Get Parameter Value From SCF  ${PARSED_SCF_ENB}  LNCEL  LNCEL-${LTE_CELL_ID}  /p[@name='phyCellId']
    ...  dist_name_substring=True
    Set Test Variable  ${LTE_PHY_CELL_ID}  ${lte_phys_cell_id}

    ${NR_CELL_ID}=  Get Global ID Of NR Cell Related To LTE Cell  ${LTE_CELL_ID}  ${lnrelgnbcell_id}  alias_gnb=gNB
    Set Test Variable  ${NR_CELL_ID}
    ${nr_phys_cell_id} =  Get Parameter Value From SCF  ${PARSED_SCF_GNB}  NRCELL  NRCELL-${NR_CELL_ID}
    ...  /p[@name='physCellId']  dist_name_substring=True
    Set Test Variable  ${NR_PHY_CELL_ID}  ${nr_phys_cell_id}

    ${NRBTS_ID}=    Get BTS ID From ADMIN  alias=gNB
    Set Test Variable  ${NRBTS_ID}

    ${lnbts_id} =  Get Parameter Value From SCF  ${PARSED_SCF_GNB}  NRDSSLTE  NRCELL-${NR_CELL_ID}/NRDSSLTE-1
    ...  /p[@name='eNodeBId']  dist_name_substring=True
    Set Test Variable  ${LNBTS_ID}

    ${lncel_dss_xpath} =  Catenate  SEPARATOR=
    ...  .//managedObject[substring(@class, string-length(@class) - string-length('LNCEL') + 1) = 'LNCEL']
    ...  /p[@name='lteNrDssMode'][.='DSS_Phase_III']/..
    ${lncel_dss_elements} =  Get Elements  ${PARSED_SCF_ENB}  ${lncel_dss_xpath}
    ${lte_dss_cell_id_list} =  Create List
    FOR  ${lncel_element}  IN  @{lncel_dss_elements}
        ${lncel_dist_name} =  XML.Get Element Attribute  ${lncel_element}  distName
        ${lte_dss_cell_id} =  Convert Dist Name To ID  ${lncel_dist_name}
        Append To List  ${lte_dss_cell_id_list}  ${lte_dss_cell_id}
    END
    Set Test Variable  ${LTE_DSS_CELL_ID_LIST}  ${lte_dss_cell_id_list}

    ${nrcel_dss_xpath} =  Catenate  SEPARATOR=
    ...  .//managedObject[substring(@class, string-length(@class) - string-length('NRCELL') + 1) = 'NRCELL']
    ...  /p[@name='lteNrDssMode'][.='DSS_Phase_3']/..
    ${nrcel_dss_elements} =  Get Elements  ${PARSED_SCF_GNB}  ${nrcel_dss_xpath}
    ${nr_dss_cell_id_list} =  Create List
    FOR  ${nrcel_element}  IN  @{nrcel_dss_elements}
        ${nrcel_dist_name} =  XML.Get Element Attribute  ${nrcel_element}  distName
        ${nr_dss_cell_id} =  Convert Dist Name To ID  ${nrcel_dist_name}
        Append To List  ${nr_dss_cell_id_list}  ${nr_dss_cell_id}
    END
    Set Test Variable  ${NR_DSS_CELL_ID_LIST}  ${nr_dss_cell_id_list}

    Set Test Variable  ${LTE_LNBTS_DISTNAME}    MRBTS-${NRBTS_ID}/LNBTS-${LNBTS_ID}
    Set Test Variable  ${LTE_LNBTS_FDD_DISTNAME}    MRBTS-${NRBTS_ID}/LNBTS-${LNBTS_ID}/LNBTS_FDD-0
    Set Test Variable  ${LTE_LNCEL_DISTNAME}    MRBTS-${NRBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${LTE_CELL_ID}
    Set Test Variable  ${LTE_LNCEL_PARTIAL_DISTNAME}    MRBTS-${NRBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-
    Set Test Variable  ${LTE_LNCEL_RUNTIME_DISTNAME}
    ...  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-${LNBTS_ID}/LNCEL_R-${LTE_CELL_ID}
    Set Test Variable  ${LTE_ANCHOR_LNCEL_DISTNAME}     MRBTS-${NRBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${LTE_ANCHOR_CELL_ID}

    Set Test Variable  ${NR_NRBTS_DISTNAME}     MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}
    Set Test Variable  ${NR_NRCEL_DISTNAME}     MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}
    Set Test Variable  ${NR_NRCEL_PARTIAL_DISTNAME}     MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-

    ${gnb_onair_cell_states}=  Run Keyword If  ${GNB_CNI-61110_STATUS}
    ...                    Catenate  SEPARATOR=  [availabilityStatus=empty,
    ...                                           operationalState=regex"[Ee]nabled",
    ...                                           administrativeState=regex"[Uu]nlocked",
    ...                                           blockingState=regex"[Uu]nblocked"]
    ...  ELSE               Catenate  SEPARATOR=  [stateInfo.availabilityStatus=Online,
    ...                                           stateInfo.operationalState=Enabled,
    ...                                           stateInfo.administrativeState=Unlocked,
    ...                                           stateInfo.blockingState=Unblocked]
    ${gnb_locked_cell_states}=  Run Keyword If  ${GNB_CNI-61110_STATUS}
    ...                    Catenate  SEPARATOR=  [administrativeState=regex"[lL]ocked",
    ...                                           availabilityStatus=regex"off line",
    ...                                           blockingState=regex"[uU]nblocked",
    ...                                           operationalState=regex"[dD]isabled"]
    ...  ELSE              Catenate  SEPARATOR=  [stateInfo.administrativeState=Locked,
    ...                                           stateInfo.availabilityStatus=Offline,
    ...                                           stateInfo.blockingState=Unblocked,
    ...                                           stateInfo.operationalState=Disabled]
    ${gnb_blocked_cell_states}=  Run Keyword If  ${GNB_CNI-61110_STATUS}
    ...                    Catenate  SEPARATOR=   [administrativeState=regex"[Uu]nlocked",
    ...                                            availabilityStatus=regex"off line",
    ...                                            blockingState=regex"[Bb]locked",
    ...                                            operationalState=regex"[Dd]isabled"]
    ...  ELSE              Catenate  SEPARATOR=  [stateInfo.administrativeState=Unlocked,
    ...                                           stateInfo.availabilityStatus=Offline,
    ...                                           stateInfo.blockingState=Blocked,
    ...                                           stateInfo.operationalState=Disabled]


    Set Test Variable  ${GNB_ONAIR_CELL_STATES}  ${gnb_onair_cell_states}
    Set Test Variable  ${GNB_LOCKED_CELL_STATES}  ${gnb_locked_cell_states}
    Set Test Variable  ${GNB_BLOCKED_CELL_STATES}  ${gnb_blocked_cell_states}

    Set Test Variable  ${ENB_PARAMETERS_CHANGED}  False
    Set Test Variable  ${GNB_PARAMETERS_CHANGED}  False


Check Preconditions For LTE4750 Test
    [Documentation]
    ...  KW used to check preconditions common for all LTE4750 tests.
    ...
    ...  | **Author:** igor.binkowski@nokia.com
    ...  | **Maintainer:** adam.chamera@nokia.com
    ...
    ...  **Full description:**
    ...
    ...  KW used to check preconditions common for all LTE4750 tests.
    ...  Needs test variables created by KW 'Set Test Variables For LTE4750 Test' to work.
    ...
    ...  On eNB side:
    ...      In LNBTS_A:
    ...          - actLteNrDss=true
    ...      In LNCEL_A:
    ...          - lteNrDssMode=DL_CRS_TDM_UL_FDM
    ...      In LNCEL_A/LNCEL_FDD_A-0:
    ...          - blankedPucch = 0 if PRB blanking is not configured
    ...          - selectOuterPuschRegion = 'None' or 'UpperEdge'
    ...      In LNCEL_A/APUCCH_FDD_A-0:
    ...          - selectPrachRegion = InnerUpperEdge
    ...      LNCEL_A/DSSNR_A-0 exists.
    ...
    ...  On gNB side:
    ...      In NRBTS_A:
    ...          - actLteNrDss=true
    ...          - ulDataPath=ulOverNr
    ...      In NRCELL_A:
    ...          - lteNrDssMode=DL_CRS_TDM_UL_FDM
    ...
    ...  **Input parameters:**
    ...
    ...  +-----------------+------+-----------------------------------------------------+
    ...  | Parameter       | Man. | Description                                         |
    ...  +=================+======+=====================================================+
    ...  | blanking        | No   | When set to True the KW does not check if the value |
    ...  |                 |      | of blankedPucch is zero. Default value is False.    |                                    |
    ...  +-----------------+------+-----------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Step 0: Preconditions
    ...         Set Test Variables For LTE4750 Test
    ...         Check Preconditions For LTE4750 Test

    [Arguments]  ${blanking}=False

    Variable Should Exist  ${LTE_CELL_ID}
    Variable Should Exist  ${LNBTS_ID}
    Variable Should Exist  ${NR_CELL_ID}
    Variable Should Exist  ${NRBTS_ID}

    Query Infomodel  //LNBTS_A-${LNBTS_ID} is [actLteNrDss=true]
    Query Infomodel  //LNCEL_A-${LTE_CELL_ID} is [lteNrDssMode=DL_CRS_TDM_UL_FDM]
    Run Keyword If  not ${blanking}  Query Infomodel  //LNCEL_A-${LTE_CELL_ID}/LNCEL_FDD_A-0 is [blankedPucch=0]
    Query Infomodel  //LNCEL_A-${LTE_CELL_ID}/LNCEL_FDD_A-0 is [selectOuterPuschRegion=regex"None|UpperEdge"]
    Query Infomodel  //LNCEL_A-${LTE_CELL_ID}/LNCEL_FDD_A-0/APUCCH_FDD_A-0 is [selectPrachRegion=InnerUpperEdge]
    Query Infomodel  //LNCEL_A-${LTE_CELL_ID}/DSSNR_A-0

    Query Infomodel  //NRBTS_A-${NRBTS_ID} is [actLteNrDss=true]             alias=gNB
    Query Infomodel  //NRCELL_A-${NR_CELL_ID} is [lteNrDssMode=DL_CRS_TDM_UL_FDM]  alias=gNB
    ${gnb_is_nsa} =  Query Infomodel  //NRBTS_A-${NRBTS_ID} is [gNbCuType=NSA]  allow_negative_result=True  alias=gNB

    Run Keyword If  ${gnb_is_nsa}
    ...  Query Infomodel  every //NRBTS_A-${NRBTS_ID}/NRDRB_A-* is [nsaDrbParam.ulDataPath=ulOverNr]  alias=gNB

    Log  All precondition parameters for LTE4750 are correct.  console=True


Check Preconditions For CB005860 Test
    [Documentation]
    ...  KW used to check preconditions common for all CB005860 tests.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full description:**
    ...
    ...  KW used to check preconditions common for all CB005860 tests.
    ...  Needs test variables created by KW 'Set Test Variables For CB005860 Test' to work.
    ...  With default setting it checks:
    ...  On eNB side:
    ...      In LNBTS:
    ...          - actLteNrDss=true
    ...      In LNCEL_A:
    ...          - lteNrDssMode=DSS_Phase_III
    ...      In LNCEL/LNCEL_FDD-0:
    ...          - blankedPucch = 0
    ...          - selectOuterPuschRegion = 'None' or 'UpperEdge'
    ...      In LNCEL/APUCCH_FDD-0:
    ...          - selectPrachRegion = InnerUpperEdge
    ...      LNCEL/DSSNR-0 exists.
    ...
    ...  On gNB side:
    ...      In NRBTS:
    ...          - actLteNrDss=true
    ...          - ulDataPath=ulOverNr
    ...      In NRCELL:
    ...          - lteNrDssMode=DSS_Phase_3
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | blanked_pucch          | No   | Expected value for 'blankedPucch' parameter. Default value: 0.             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | select_prach_region    | No   | Expected value for 'selectOuterPuschRegion' parameter. Checked             |
    ...  |                        |      | as regular expression. Default value: (None|UpperEdge).                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | select_prach_region    | No   | Expected value for 'selectPrachRegion' parameter. Default value:           |
    ...  |                        |      | InnerUpperEdge.                                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | ul_data_path           | No   | Expected value for 'ulDataPath' parameter. Default value: ulOverNr.        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | superfast_active       | No   | Boolean value defining if superfast feature should also be checked.        |
    ...  |                        |      | Default value: False.                                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Preconditions
    ...         Set Test Variables For CB005860 Test
    ...         Check Preconditions For CB005860 Test

    [Arguments]  ${blanked_pucch}=0  ${select_outer_pusch_region}=(None|UpperEdge)
    ...  ${select_prach_region}=InnerUpperEdge  ${ul_data_path}=ulOverNr  ${superfast_active}=False

    Variable Should Exist  ${LTE_CELL_ID}
    Variable Should Exist  ${LNBTS_ID}
    Variable Should Exist  ${NR_CELL_ID}
    Variable Should Exist  ${NRBTS_ID}

    Check Element In SCF  ${PARSED_SCF_ENB}  LNBTS  LNBTS-${LNBTS_ID}  /p[@name='actLteNrDss']
    ...  <p name="actLteNrDss">true</p>  dist_name_substring=True
    Check Element In SCF  ${PARSED_SCF_ENB}  LNCEL  LNCEL-${LTE_CELL_ID}  /p[@name='lteNrDssMode']
    ...  <p name="lteNrDssMode">DSS_Phase_III</p>  dist_name_substring=True
    Check Element In SCF  ${PARSED_SCF_ENB}  LNCEL_FDD  LNCEL-${LTE_CELL_ID}/  /p[@name='blankedPucch']
    ...  <p name="blankedPucch">${blanked_pucch}</p>
    Check Element In SCF  ${PARSED_SCF_ENB}  LNCEL_FDD  LNCEL-${LTE_CELL_ID}/
    ...  /p[@name='selectOuterPuschRegion']  <p name="selectOuterPuschRegion">${select_outer_pusch_region}</p>  True
    Check Element In SCF  ${PARSED_SCF_ENB}  APUCCH_FDD  LNCEL-${LTE_CELL_ID}/  /p[@name='selectPrachRegion']
    ...  <p name="selectPrachRegion">${select_prach_region}</p>
    Check If Element Exists In SCF  ${PARSED_SCF_ENB}  DSSNR  LNCEL-${LTE_CELL_ID}/DSSNR-
    Check Element In SCF  ${PARSED_SCF_GNB}  NRBTS  NRBTS-${NRBTS_ID}  /p[@name='actLteNrDss']
    ...  <p name="actLteNrDss">true</p>  dist_name_substring=True
    Check Element In SCF  ${PARSED_SCF_GNB}  NRCELL  NRCELL-${NR_CELL_ID}  /p[@name='lteNrDssMode']
    ...  <p name="lteNrDssMode">DSS_Phase_3</p>  dist_name_substring=True
    ${gnb_cu_type} =  Get Parameter Value From SCF  ${PARSED_SCF_GNB}  NRBTS  NRBTS-${NRBTS_ID}  /p[@name='gNbCuType']
    ...  dist_name_substring=True
    Run Keyword If  '${gnb_cu_type}' == 'NSA'
    ...  Check Every Element In SCF  ${PARSED_SCF_GNB}  NRDRB  NRBTS-${NRBTS_ID}
    ...  /list[@name='nsaDrbParam']/item/p[@name='ulDataPath']  <p name="ulDataPath">${ul_data_path}</p>
    ...  dist_name_substring=True

    ${enb_superfast_activated} =  Run Keyword And Return Status  Check Element In SCF  ${PARSED_SCF_ENB}
    ...  DSSNR  LNCEL-${LTE_CELL_ID}/  /p[@name='actLteNrDssFastAlloc']  <p name="actLteNrDssFastAlloc">true</p>
    ${gnb_superfast_activated} =  Run Keyword And Return Status  Check Element In SCF  ${PARSED_SCF_GNB}
    ...  NRDSSLTE  NRCELL-${NR_CELL_ID}/  /p[@name='actLteNrDssFastAlloc']  <p name="actLteNrDssFastAlloc">true</p>
    Run Keyword If  ${superfast_active}  Should Be True  ${enb_superfast_activated} and ${gnb_superfast_activated}
    ...  msg=Superfast featrure is not active on eNB (${enb_superfast_activated}) or gNB (${gnb_superfast_activated}).

    Log  All precondition parameters for CB005860 are correct.  console=True


Setup TTI Decoder
    [Documentation]
    ...  KW used to setup tti decoder.
    ...
    ...  | **Author:** mariusz.makuch@nokia.com
    ...  | **Maintainer:** monika.ceglarek@nokia.com
    ...
    ...  **Full description:**
    ...
    ...  KW used to setup *_tti-dec.deb package installed, which is available for every build
    ...  **Input parameters:**
    ...
    ...  +------------------------+------+----------------------------------------------------+
    ...  | Parameter              | Man. | Description                                        |
    ...  +========================+======+====================================================+
    ...  | is_trunk_sw            | Yes  | Boolean if tested sw is trunk                      |
    ...  +------------------------+------+----------------------------------------------------+
    ...  | alias                  | No   | Alias for KW. Default value: gNB                   |
    ...  +------------------------+------+----------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...     Setup TTI Decoder  True

    [Arguments]  ${is_trunk_sw}=${IS_TRUNK_SW}  ${alias}=gNB

    Log  \nSetting up TTI decoder  console=True
    ${sw_version}=  Get SW Version  ${IS_TRUNK_SW}  alias=${alias}
    ${tti_dec_dir}=  Set Variable  http://files.ute.nsn-rdnet.net/builds/enb/base/${sw_version}/${sw_version}_tti-dec.deb
    ${download_dir}=  Set Variable  /home/ute/Downloads
    OperatingSystem.Run  wget ${tti_dec_dir} -O ${download_dir}/tti_dec.deb
    OperatingSystem.Run  sudo dpkg -i ${download_dir}/tti_dec.deb
    Log  \nNew version of TTI decoder was successfully installed  console=True


Collect NR TTI Trace General
    [Documentation]
    ...  KW used to collect and convert NR TTI traces to csv file.
    ...
    ...  | **Author:** filip.plosinski@nokia.com
    ...  | **Maintainer:** igor.kleschenok@nokia.com
    ...
    ...  **Full description:**
    ...
    ...  KW used to collect NR TTI traces and convert them to csv file.
    ...  It requires *_tti-dec.deb package installed, which is available
    ...  for every build.
    ...  **Input parameters:**
    ...
    ...  +------------------------+------+----------------------------------------------------+
    ...  | Parameter              | Man. | Description                                        |
    ...  +========================+======+====================================================+
    ...  | nr_phy_cell_ids        | Yes  | List of physical NR cell IDs                       |
    ...  +------------------------+------+----------------------------------------------------+
    ...  | destination_ip_addr    | Yes  | IP of VM where logs are being collected.           |
    ...  +------------------------+------+----------------------------------------------------+
    ...  | gnb_oam_ip             | No   | OAM IP of gNB. Defaults to global variable         |
    ...  |                        |      | ${GNB_OAM_IP} which is created in IWK Test Setup.  |
    ...  +------------------------+------+----------------------------------------------------+
    ...  | tti_output_dir         | No   | Path to where logs are being collected. Defaults   |
    ...  |                        |      | to ${OUTPUT_DIR}/misc_logs.                        |
    ...  +------------------------+------+----------------------------------------------------+
    ...  | output_filename        | No   | Path to where logs are being collected. Defaults   |
    ...  |                        |      | to tcpdump.                                        |
    ...  +------------------------+------+----------------------------------------------------+
    ...  | output_format          | No   | TTI output format. Defaults to excelCsv            |
    ...  +------------------------+------+----------------------------------------------------+
    ...  | release                | No   | SW release. Defaults to ${RELEASE_REMOTE}          |
    ...  +------------------------+------+----------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...     Collect NR TTI Trace  50  ${ENB_VM_IP}

    [Arguments]  ${nr_phy_cell_ids}  ${destination_ip_addr}  ${gnb_oam_ip}=${GNB_OAM_IP}
    ...          ${tti_output_dir}=${OUTPUT_DIR}/misc_logs     ${output_filename}=tcpdump    ${output_format}=excelCsv
    ...          ${release}=${RELEASE_REMOTE}

    Log  \nCollecting TTI traces  console=True
    ${executor}=  Create Dictionary
    ...  host=${GNB_OAM_IP}
    ...  user=Nemuadmin
    ...  password=nemuuser
    ...  port=443
    ...  release=${release}
    ${curl_options}=  Create Dictionary
    ...  nr_phy_cell_ids=${nr_phy_cell_ids}
    ${curl_list}=  Create List  ${curl_options}

    tcpdump.Create Tcpdump Collector
    ...  name=tcpdump
    ...  options=-i any udp -s 0 -W 1

    l2stream3.Create Sbts L2stream Collector
    ...  name=l2stream3
    ...  webservice=${executor}
    ...  source_ip_addr=${gnb_oam_ip}
    ...  destination_ip_addr=${destination_ip_addr}
    ...  collector=tcpdump
    ...  l2_stream_configuration=@{curl_list}
    core.Setup Collectors  names=l2stream3
    core.Start Collectors  names=l2stream3
    Sleep  10s
    core.Stop Collectors  names=l2stream3
    core.Collect Collectors  names=l2stream3  target_dir=${tti_output_dir}
    core.Teardown Collectors  names=l2stream3
    eventdecoder.Create eventDecoder Converter
    ...  name=converter
    ...  input_file_path=${tti_output_dir}/l2stream3/tcpdump/tcpdump.pcap
    ...  output_file_path=${tti_output_dir}/${output_filename}
    ...  output_file_format=${output_format}
    eventdecoder.Convert
    ...  name=converter

    Log  \nDone  console=True
    [Return]  ${tti_output_dir}/${output_filename}


Collect PM Counters
    [Documentation]
    ...  This KW collects PM files from BTS.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  This KW collects PM files from BTS. All files are saved at first and based on
    ...  xml_files_left parameter the amount of .xml files that will not be removed
    ...  is determined. Additionally all saved .raw files are not removed from disc.
    ...
    ...  **Input Parameters:**
    ...
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | Parameter           | Man. | Description                                                             |
    ...  +=====================+======+=========================================================================+
    ...  | target_dir_path     | No   | Path where directory with PM files will be saved. Last directory        |
    ...  |                     |      | name will also be alias name for counters collector.                    |
    ...  |                     |      | Default value: LOG_PATH/pm_counters.                                    |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | xml_files_left      | No   | Number of .xml PM files that will not be removed from disc              |
    ...  |                     |      | Default value: 1.                                                       |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | host                | No   | IP of host for webservice. Default value: 192.168.255.129.              |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | user                | No   | Username for webservice. Default value: Nemuadmin.                      |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | password            | No   | Password for webservice. Default value: nemuuser.                       |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | port                | No   | Port for webservice. Default value: 443.                                |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | intervals           | No   | Counters intervals. Default value: 1,2,4                                |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Collect PM Counters

    [Arguments]  ${target_dir_path}=${LOG_PATH}/pm_counters  ${xml_files_left}=1  ${host}=192.168.255.129
    ...          ${user}=Nemuadmin  ${password}=nemuuser  ${port}=443  ${time_interval}=3 min  ${intervals}=1,2,4

    ${target_dir}  ${name}=  Split String From Right  ${target_dir_path}  separator=/  max_split=1
    ${webservice} =  Create Dictionary
    ...  host=${host}
    ...  user=${user}
    ...  password=${password}
    ...  port=${port}
    taf.collectors.pmcounters.Create PM Collector
    ...  name=${name}
    ...  webservice=${webservice}
    ...  for_last=${time_interval}
    ...  intervals=${intervals}
    taf.collectors.pmcounters.Setup Collectors
    ...  names=${name}
    taf.collectors.pmcounters.Collect Collectors
    ...  names=${name}
    ...  target_dir=${target_dir}
    Run  find ${target_dir}/${name} -name '*.xml' | sort -nk1 | head -n -${xml_files_left}| xargs rm -rf
    [Teardown]  taf.collectors.pmcounters.Teardown Collectors  names=${name}


Compare Counters Values
    [Documentation]
    ...  This KW checks if values of specified counter are the same as expected.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  This KW checks if values of specified counter are the same as expected.
    ...
    ...  **Input Parameters:**
    ...
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | Parameter           | Man. | Description                                                             |
    ...  +=====================+======+=========================================================================+
    ...  | files_path          | Yes  | Path to saved PM files.                                                 |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | counter             | Yes  | Counter's name.                                                         |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | dist_name           | Yes  | Dist name under which specified counter can be found.                   |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | expected_values     | Yes  | Expected value or list of expected values in order from earliest        |
    ...  |                     |      | to most recent. Needs to be the same length as number of vaues          |
    ...  |                     |      | verified.                                                               |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | counters_amount     | No   | Number of last periods for which counter values should                  |
    ...  |                     |      | be comparised. Default value 'all' means all values of specified        |
    ...  |                     |      | counter will be verified.                                               |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${values_list} =  Create List  11  25  38  17  20
    ...     Compare Counters Values  ${LOG_PATH}/pm_counters  M8029C217  MRBTS-12345/LNBTS-12345/LNCEL-111222
    ...     ...  ${values_list}  5

    [Arguments]  ${files_path}  ${counter}  ${dist_name}  ${expected_values}  ${counters_amount}=all
    Log  Checking values for counter ${counter}  console=True

    ${counter_list} =  Create List  ${counter}
    ${pi_dict} =  Get PI Value
    ...  pi_list=${counter_list}
    ...  pi_dir=${files_path}
    ...  pi_file_pattern=PM*

    ${pi_dict} =  Set Variable If  '${counters_amount}'.lower() == 'all'
    ...                             ${pi_dict}
    ...                             ${pi_dict[-${counters_amount}:]}
    ${all_counters_dicts} =  Evaluate  [list(x.values())[0] for x in ${pi_dict}]
    ${counter_values} =  Evaluate  [x['${counter}']['${dist_name}'] for x in ${all_counters_dicts} if '${counter}' in x.keys()]

    ${expected_values}=  Run Keyword If  type(${expected_values}) is list  Set Variable  ${expected_values}
    ...  ELSE  Create List  ${expected_values}
    Lists Should Be Equal  ${counter_values}  ${expected_values}  msg=Counter values are different than expected.
    Log  All counter ${counter} values ${counter_values} are correct.  console=True


Get Values Of Counters From List
    [Documentation]
    ...  This KW returns dictionary of counters (keys) and list of their values (value).
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  This KW returns dictionary of counters (keys) and list of their values (value).
    ...  All counters must be under the same managed object (the same value in 'dist_name' argument).
    ...
    ...  **Input Parameters:**
    ...
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | Parameter           | Man. | Description                                                             |
    ...  +=====================+======+=========================================================================+
    ...  | files_path          | Yes  | Path to saved PM files.                                                 |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | counter_list        | Yes  | List of counter's IDs.                                                  |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | dist_name           | Yes  | Dist name under which counters from 'counter_list' can be found.        |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | counters_amount     | No   | Number of last periods for which counter values should                  |
    ...  |                     |      | be comparised. Default value 'all' means all values of specified        |
    ...  |                     |      | counter will be verified.                                               |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${counter_list} =  Create List  M8029C217  M8029C225  M8029C238  M8029C210
    ...     Get Values Of Counters From List  ${LOG_PATH}/pm_counters  ${counter_list}
    ...     ...  MRBTS-12345/LNBTS-12345/LNCEL-111222  5

    [Arguments]  ${files_path}  ${counter_list}  ${dist_name}  ${counters_amount}=all
    Log  Getting values for counters: ${counter_list}  console=True

    ${counters_dict} =  Create Dictionary
    FOR  ${counter}  IN  @{counter_list}
        ${counter_in_list} =  Create List  ${counter}
        ${pi_dict} =  Get PI Value
        ...  pi_list=${counter_in_list}
        ...  pi_dir=${files_path}
        ...  pi_file_pattern=PM*

        ${pi_dict} =  Set Variable If  '${counters_amount}'.lower() == 'all'
        ...                             ${pi_dict}
        ...                             ${pi_dict[-${counters_amount}:]}
        ${all_counters_dicts} =  Evaluate  [list(x.values())[0] for x in ${pi_dict}]
        Log  Getting values for counter: ${counter}  console=True
        ${counter_values} =  Evaluate  [x['${counter}']['${dist_name}'] for x in ${all_counters_dicts} if '${counter}' in x.keys()]
        Set To Dictionary  ${counters_dict}  ${counter}=${counter_values}
        Log  Values: ${counter_values}  console=True
    END
    [Return]  ${counters_dict}


Testline Recovery
    [Documentation]
    ...  This KW performs recovery for 5G and non-5G TLs.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  This KW performs recovery for 5G and non-5G TLs by uploading SCF(s) to BTS(es). This keyword should
    ...  be used in teardown of test cases in testsuite. Recovery is performed if BTS state
    ...  is incorrect - it uses '_verify bts states for iwk test helper' (non-5g) or 'Verify BTS States
    ...  For IWK Test' (5g) to check the state.
    ...  Since logs may be required for first failed TC the recovery will be performed in the next
    ...  test case in testsuite as long as BTS status is still failed.
    ...
    ...  **Input Parameters:**
    ...
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | Parameter           | Man. | Description                                                             |
    ...  +=====================+======+=========================================================================+
    ...  | is_5g_tl            | No   | Boolean value defining if TL is 5G TL or non-5G TL.                     |
    ...  |                     |      | Default value: True.                                                    |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | recovery_off        | No   | Boolean value defining if recovery should be turned off.                |
    ...  |                     |      | Default value: False.                                                   |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | scf_path_non_5g     | No   | Absolute path to SCF file for non-5G BTS (4G for 5G TLs).               |
    ...  |                     |      | Default value: ${COMMISSIONING_PATH}                                    |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | scf_path_5g         | No   | Absolute path to SCF file for 5G BTS                                    |
    ...  |                     |      | Default value: ${EMPTY}                                                 |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | on_air_timeout      | No   | Timeout for cells to go on air after commissioning.                     |
    ...  |                     |      | Default value: 11 min.                                                  |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Testline Recovery  is_5g_tl=False

    [Arguments]  ${is_5g_tl}=True  ${recovery_off}=False  ${scf_path_non_5g}=${COMMISSIONING_PATH}
    ...          ${scf_path_5g}=${EMPTY}  ${on_air_timeout}=11 min
    ${recovery_counter_exists} =  Run Keyword And Return Status  Variable Should Exist  ${RECOVERY_COUNTER}
    Run Keyword Unless  ${recovery_counter_exists}  Set Suite Variable  ${RECOVERY_COUNTER}  0

    Run Keyword If  '${TEST STATUS}' == 'PASS' or ${recovery_off}
    ...  Run Keywords  Set Suite Variable  ${RECOVERY_COUNTER}  0
    ...  AND           Return From Keyword

    Add Standard Allowed Alarms
    Run Keyword If  ${is_5g_tl}  Add Standard Allowed Alarms  alias=gNB
    ${correct_bts_state} =  Run Keyword If  ${is_5g_tl}
    ...  Run Keyword And Return Status  Verify BTS States For IWK Test
    ...  ELSE  Run Keyword And Return Status  _verify bts states for iwk test helper
    ${RECOVERY_COUNTER} =  Run Keyword If  ${correct_bts_state}  Set Variable  0
    ...                    ELSE                                  Evaluate  ${RECOVERY_COUNTER} + 1
    Set Suite Variable  ${RECOVERY_COUNTER}

    Run Keyword If  ${RECOVERY_COUNTER} > 1 and ${is_5g_tl}
    ...             recovery for 5G tl  ${scf_path_non_5g}  ${scf_path_5g}  ${on_air_timeout}
    ...  ELSE IF    ${RECOVERY_COUNTER} > 1 and not ${is_5g_tl}
    ...             recovery for non-5G tl  ${scf_path_non_5g}  ${on_air_timeout}
    [Teardown]  Set Test Variable  ${RECOVERY_PASSED}  ${KEYWORD_STATUS}

_recovery for non-5G tl
    [Arguments]  ${scf_path}=${COMMISSIONING_PATH}  ${on_air_timeout}=11 min
    Import Library  XML  use_lxml=True
    ${scf} =  Parse XML  ${scf_path}
    ${lnbts_dist_name} =  XML.Get Element Attribute  ${scf}  distName
    ...  .//managedObject[substring(@class, string-length(@class) - string-length('LNBTS') + 1) = 'LNBTS']

    ${lnbts_id} =  Fetch From Right  ${lnbts_dist_name}  marker=-
    Log  Perform commissioning LNBTS ID=${lnbts_id}, SCF path: ${scf_path}  console=True
    Perform Commissioning  ${lnbts_id}  ${scf_path}  timeout=360
    Log  Commissioning finished.\n Waiting for BTS to go on air.  console=True
    Add Standard Allowed Alarms
    Wait Until Keyword Succeeds  ${on_air_timeout}  10 min  _verify bts states for iwk test helper

_recovery for 5G tl
    [Arguments]  ${scf_path_4g}  ${scf_path_5g}  ${on_air_timeout}=11 min
    Import Library  XML  use_lxml=True
    ${scf_4g} =  Parse XML  ${scf_path_4g}
    ${lnbts_dist_name} =  XML.Get Element Attribute  ${scf_4g}  distName
    ...  .//managedObject[substring(@class, string-length(@class) - string-length('LNBTS') + 1) = 'LNBTS']
    ${lnbts_id} =  Fetch From Right  ${lnbts_dist_name}  marker=-

    ${scf_5g} =  Parse XML  ${scf_path_5g}
    ${nrbts_dist_name} =  XML.Get Element Attribute  ${scf_5g}  distName
    ...  .//managedObject[substring(@class, string-length(@class) - string-length('NRBTS') + 1) = 'NRBTS']
    ${nrbts_id} =  Fetch From Right  ${nrbts_dist_name}  marker=-

    Log  LTE site commissioning for LNBTS ID=${lnbts_id}, SCF path: ${scf_path_4g} ongoing...  console=True
    Log  \nLTE site recommissioning ongoing  console=True
    Perform Commissioning  ${lnbts_id}  ${scf_path_4g}  timeout=360
    Log  5G site commissioning for NRBTS ID=${nrbts_id}, SCF path: ${scf_path_5g} ongoing...  console=True
    Perform Commissioning  ${nrbts_id}  ${scf_path_5g}  timeout=360  alias=gNB
    Log  Commissioning finished.\n Waiting for BTS to go on air.  console=True

    Add Standard Allowed Alarms
    Add Standard Allowed Alarms  alias=gNB
    Wait Until Keyword Succeeds  ${on_air_timeout}  10 min  Verify BTS States For IWK Test


Start Collecting Syscomdump
    [Documentation]
    ...  This KW starts syscomdump logs collection.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +---------------------+------+-----------------------------------------------------------+
    ...  | Parameter           | Man. | Description                                               |
    ...  +=====================+======+===========================================================+
    ...  | options             | No   | Filter for collecting syscomdump (options argument in     |
    ...  |                     |      | taf.collectors.syscomdump.Create Syscomdump Collector     |
    ...  |                     |      | Default value: ${NONE}.                                   |
    ...  +---------------------+------+-----------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Start Collecting Syscomdump
    ...     Stop Collecting Syscomdump

    [Arguments]  ${options}=${NONE}

    Log  Starting syscomdump collection...  console=True

    ${executor}=  Create Dictionary
    ...  host=192.168.255.129
    ...  user=toor4nsn
    ...  password=oZPS0POrRieRtu

    taf.collectors.syscomdump.Create Syscomdump Collector
    ...    syscomdump_path=syscomdump
    ...    name=syscomdump
    ...    options=${options}
    ...    executor=${executor}

    core.Setup Collectors    names=syscomdump
    core.Start Collectors    names=syscomdump
    core.Set Test Alias  syscomdump

    Log  Syscomdump logs collection started.  console=True


Stop Collecting Syscomdump
    [Documentation]
    ...  This KW stops syscomdump logs collection.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  This KW stops syscomdump logs collection and saves them to path defined in 'log_directory'.
    ...  File name will have timestamp added to it in this KW. It returns absolute path to saved file.
    ...
    ...  **Input Parameters:**
    ...
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | Parameter           | Man. | Description                                                             |
    ...  +=====================+======+=========================================================================+
    ...  | log_directory       | No   | Absolute path where syscomdump logs should be saved.                    |
    ...  |                     |      | Default value: ${LOG_PATH}/pcap_logs.                                   |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Start Collecting Syscomdump
    ...     Stop Collecting Syscomdump

    [Arguments]  ${log_directory}=${LOG_PATH}/pcap_logs

    Log  Stopping syscomdump collection...  console=True

    ${timestamp}  Run  date +%H-%M-%S

    core.Stop Collectors      names=syscomdump
    core.Collect Collectors   names=syscomdump  target_dir=${log_directory}
    core.Teardown Collectors  names=syscomdump

    ${pcap_exists} =  Run Keyword And Return Status
    ...  OperatingSystem.File Should Exist  ${log_directory}/syscomdump/syscomdump.pcap
    Should Be True  ${pcap_exists}
    ...  msg=syscomdump file does not exist in ${log_directory}/syscomdump/syscomdump.pcap.
    Return From Keyword If  not ${pcap_exists}  ${NONE}

    Run  mv ${log_directory}/syscomdump/syscomdump.pcap ${log_directory}/syscomdump_${timestamp}.pcap

    Log  Syscomdump logs collection finished.  console=True
    [Return]  ${log_directory}/syscomdump_${timestamp}.pcap


Check Element In SCF
    [Documentation]
    ...  This KW checks if element in SCF is the same as expected.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  This KW checks if element in SCF is the same as expected. Xpath under which the element is searched
    ...  looks as follows:
    ...  './/managedObject[substring(@class, string-length(@class) - string-length('${class}') + 1) = '${class}']
    ...  [contains(@distName, '${contains_in_dist_name}')]${xpath_end}'.
    ...  If 'dist_name_substring' is set to True [contains(@distName, '${contains_in_dist_name}')] part
    ...  is replaced with:
    ...  [substring(@distName, string-length(@distName) - string-length('${contains_in_dist_name}') + 1) =
    ...  '${contains_in_dist_name}']
    ...  This KW requires XML robot library.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | parsed_scf             | Yes  | SCF parsed with 'XML.Parse XML'.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | class                  | Yes  | Value in 'class' attribute of managed object, e.g. LNCEL, RMOD,            |
    ...  |                        |      | CLOCK, etc.                                                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | contains_in_dist_name  | Yes  | Fragment of string in 'dist_name' attribute of managed object.             |
    ...  |                        |      | It may be different than what is in 'class'.                               |
    ...  |                        |      | E.g. LNCEL-12345, LNBTS-1234/LNCEL-12345.                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | xpath_end              | Yes  | The remaining part of xpath. Usually xpath to the parameter.               |
    ...  |                        |      | E.g. /list[@name='lteNrDssDlRatio']/item/p[@name='dssLteRelSchedWeight'],  |
    ...  |                        |      | /p[@name='lcrId'].                                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | expected_element       | Yes  | Element which schould be found in SCF under given xpath.                   |
    ...  |                        |      | E.g. <p name="actLteNrDssVoNr">true</p>.                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | is_regexp              | No   | Boolean value defining if element should be equal to string (False)        |
    ...  |                        |      | or matched using regular expression. Default value: False.                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | dist_name_substring    | No   | Boolean value defining if in xpath substring or contains should            |
    ...  |                        |      | be used for distName. Default value: False.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Collect Scf  ${LOG_PATH}/misc_logs/SCF_eNB_VoNR_enabled.xml  export_type=configuration
    ...     ${scf_enb} =  Parse XML  ${LOG_PATH}/misc_logs/SCF_eNB_VoNR_enabled.xml
    ...     Check Element In SCF  ${scf_enb}  DSSNR  LNCEL-${LTE_CELL_ID}  /p[@name='actLteNrDssVoNr']
    ...     <p name="actLteNrDssVoNr">true</p>


    [Arguments]  ${parsed_scf}  ${class}  ${contains_in_dist_name}  ${xpath_end}  ${expected_element}
    ...  ${is_regexp}=False  ${dist_name_substring}=False

    ${contains_or_substring} =  Set Variable If  ${dist_name_substring}
    ...  [substring(@distName, string-length(@distName) - string-length('${contains_in_dist_name}') + 1) = '${contains_in_dist_name}']
    ...  [contains(@distName, '${contains_in_dist_name}')]

    ${xpath} =  Catenate  SEPARATOR=
    ...  .//managedObject[substring(@class, string-length(@class) - string-length('${class}') + 1) = '${class}']
    ...  ${contains_or_substring}${xpath_end}
    ${scf_element} =  XML.Get Element  ${parsed_scf}  ${xpath}
    Run Keyword If  not ${is_regexp}  XML.Elements Should Be Equal  ${scf_element}  ${expected_element}
    ...  ELSE                         Elements Should Match Regexp  ${scf_element}  ${expected_element}
    Log  SUCCESS! Element is equal to expected: ${expected_element}  console=True


Get Parameter Value From SCF
    [Documentation]
    ...  This KW gets text of element in SCF.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  This KW gets text of element in SCF. Xpath under which the element is searched looks as follows:
    ...  './/managedObject[substring(@class, string-length(@class) - string-length('${class}') + 1) = '${class}']
    ...  [contains(@distName, '${contains_in_dist_name}')]${xpath_end}'.
    ...  If 'dist_name_substring' is set to True [contains(@distName, '${contains_in_dist_name}')] part
    ...  is replaced with:
    ...  [substring(@distName, string-length(@distName) - string-length('${contains_in_dist_name}') + 1) =
    ...  '${contains_in_dist_name}']
    ...  If 'return_list' is set to True this keyword will be able to return list of multiple parameter values
    ...  available under created xpath.
    ...  This KW requires XML robot library.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | parsed_scf             | Yes  | SCF parsed with 'XML.Parse XML'.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | class                  | Yes  | Value in 'class' attribute of managed object, e.g. LNCEL, RMOD,            |
    ...  |                        |      | CLOCK, etc.                                                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | contains_in_dist_name  | Yes  | Fragment of string in 'dist_name' attribute of managed object.             |
    ...  |                        |      | It may be different than what is in 'class'.                               |
    ...  |                        |      | E.g. LNCEL-12345, LNBTS-1234/LNCEL-12345.                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | xpath_end              | Yes  | The remaining part of xpath. Usually xpath to the parameter.               |
    ...  |                        |      | E.g. /list[@name='lteNrDssDlRatio']/item/p[@name='dssLteRelSchedWeight'],  |
    ...  |                        |      | /p[@name='lcrId'].                                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | dist_name_substring    | No   | Boolean value defining if in xpath substring or contains should            |
    ...  |                        |      | be used for distName. Default value: False.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | return_list            | No   | Boolean value defining if result should be retunred in a list.             |
    ...  |                        |      | Should be used when multiple results are expected. Default value: False.   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Collect Scf  ${LOG_PATH}/misc_logs/SCF_gNB_VoNR_enabled.xml  export_type=configuration  alias=gNB
    ...     ${scf_gnb} =  Parse XML  ${LOG_PATH}/misc_logs/SCF_gNB_VoNR_enabled.xml
    ...     ${nr_lcr_id} =  Get Parameter Value From SCF  ${scf_gnb}  NRCELL  NRCELL-${NR_CELL_ID}  /p[@name='lcrId']

    [Arguments]  ${parsed_scf}  ${class}  ${contains_in_dist_name}  ${xpath_end}  ${dist_name_substring}=False
    ...  ${return_list}=False

    ${contains_or_substring} =  Set Variable If  ${dist_name_substring}
    ...  [substring(@distName, string-length(@distName) - string-length('${contains_in_dist_name}') + 1) = '${contains_in_dist_name}']
    ...  [contains(@distName, '${contains_in_dist_name}')]

    ${xpath} =  Catenate  SEPARATOR=
    ...  .//managedObject[substring(@class, string-length(@class) - string-length('${class}') + 1) = '${class}']
    ...  ${contains_or_substring}${xpath_end}
    ${parameter_value} =  Run Keyword If  ${return_list}  _get elements parameter value  ${parsed_scf}  ${xpath}
    ...  ELSE  XML.Get Element Text  ${parsed_scf}  ${xpath}
    [Return]  ${parameter_value}


_get elements parameter value
    [Arguments]  ${parsed_scf}  ${xpath}
    ${elements} =  Get Elements  ${parsed_scf}  ${xpath}
    ${parameter_value_list} =  Create List
    FOR  ${element}  IN  @{elements}
        ${parameter_value} =  XML.Get Element Text  ${element}
        Append To List  ${parameter_value_list}  ${parameter_value}
    END
    [Return]  ${parameter_value_list}


Perform 5G Data Transfer And Verify Average Throughput
    [Documentation]
    ...  This KW performs NR data transfer and verifies the throughput.
    ...
    ...  | **Author:** igor.kleschenok@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  This KW performs NR data transfer and verifies the throughput. It also creates file under specified
    ...  ${file_path} with results from each loop and average throughput from all repetitions.
    ...
    ...  **Input Parameters:**
    ...
    ...  +-------------------------------+------+----------------------------------------------------------------------------+
    ...  | Parameter                     | Man. | Description                                                                |
    ...  +===============================+======+============================================================================+
    ...  | cell_id                       | Yes  | ID of cell for NR data transfer.                                           |
    ...  +-------------------------------+------+----------------------------------------------------------------------------+
    ...  | user_direction                | Yes  | 'Start Data Transfer' parameter defining type of data transfer.            |
    ...  |                               |      | ('DL', 'UL'). It may also be set to 'both' in that case both DL and UL     |
    ...  |                               |      | are run at the same time.                                                  |
    ...  +-------------------------------+------+----------------------------------------------------------------------------+
    ...  | throughput                    | Yes  | 'Start Data Transfer' parameter defining iperf throughput.                 |
    ...  |                               |      | (Desired data transfer throughput in iperf string format)                  |
    ...  +-------------------------------+------+----------------------------------------------------------------------------+
    ...  | min_expected_tput             | Yes  | Value of minimal expected average 5G throughput in [Mbit/sec]. If          |
    ...  |                               |      | 'user_direction' is set to 'both' this refers to DL average throughput.    |
    ...  +-------------------------------+------+----------------------------------------------------------------------------+
    ...  | protocol                      | Yes  | 'Start Data Transfer' parameter defining type of used protocol             |
    ...  |                               |      | ('tcp' or 'udp').                                                          |
    ...  +-------------------------------+------+----------------------------------------------------------------------------+
    ...  | duration                      | Yes  | 'Start Data Transfer' parameter defining duration of data transfer.        |
    ...  +-------------------------------+------+----------------------------------------------------------------------------+
    ...  | packet_size                   | No   | 'Start Data Transfer' parameter defining packet size for                   |
    ...  |                               |      |  'udp' data transfer. Default value: 1400                                  |
    ...  +-------------------------------------------------------------------------------------------------------------------|
    ...  | max_segment_size              | No   | 'Start Data Transfer' parameter defining max_segment_size for              |
    ...  |                               |      |  'tcp' DL data transfer. Default value: 1400                               |
    ...  +-------------------------------+------+----------------------------------------------------------------------------+
    ...  | buffer                        | No   | 'Start Data Transfer' parameter defining buffer size. Default value: 32M   |
    ...  +-------------------------------+------+----------------------------------------------------------------------------+
    ...  | port_num                      | No   | 'Start Data Transfer' parameter defining port number. Default value: 5004  |
    ...  +-------------------------------+------+----------------------------------------------------------------------------+
    ...  | num_of_repetitions            | No   | Number of times data transfer procedure should be repeated.                |
    ...  |                               |      | Default value: 1                                                           |
    ...  +-------------------------------+------+----------------------------------------------------------------------------+
    ...  | additional_string             | No   | Additional string added at the start to file with results.                 |
    ...  |                               |      | Default value: ${EMPTY}                                                    |
    ...  +-------------------------------+------+----------------------------------------------------------------------------+
    ...  | file_path                     | No   | Path to file with results. Default value:                                  |
    ...  |                               |      | ${LOG_PATH}/average_throughput_results/average_throughput_results.txt      |
    ...  +-------------------------------+------+----------------------------------------------------------------------------+
    ...  | additional_min_expected_tput  | No   | Value of minimal expected average 5G UL throughput in [Mbit/sec]. This is  |
    ...  |                               |      | only required if 'user_direction' is set to 'both'. Default vaue: 0.0      |
    ...  +-------------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Perform 5G Data Transfer And Verify Average Throughput  cell_id=12345  num_of_repetitions=2
    ...     ...  user_direction=DL  throughput=150 Mbits/sec  protocol=tcp  duration=100s  packet_size=1400
    ...     ...  buffer=32M  port_num=5004  min_expected_tput=100  additional_string=Step 1

    [Arguments]  ${cell_id}  ${user_direction}  ${throughput}  ${min_expected_tput}  ${protocol}  ${duration}
    ...  ${packet_size}=1400  ${max_segment_size}=1400  ${buffer}=32M  ${port_num}=5004  ${num_of_repetitions}=1
    ...  ${additional_string}=${EMPTY}  ${file_path}=${LOG_PATH}/average_throughput_results/average_throughput_results.txt
    ...  ${additional_min_expected_tput}=0.0

    ${nr_tput_list} =  Create List
    ${additional_nr_tput_list} =  Create List
    ${num_of_rep} =  Evaluate  ${num_of_repetitions}+1
    Run Keyword If  '${additional_string}' != ''  Append To File  ${file_path}  ${additional_string}
    ${direction} =  Set Variable If  '${user_direction}' =='both'  DL  ${user_direction}

    FOR  ${ind}  IN RANGE  1  ${num_of_rep}
        Log  \n== Attempt Number ${ind} ==  console=True
        Log  \n==== Prepare UE For Data Transfer  console=True
        Prepare UE For Data Transfer  NR_UE  ${cell_id}
        Log  \n==== Start ${direction} data transfer with ${protocol} data flow  console=True
        Run Keyword If  '${protocol}' == 'udp'  Start Data Transfer  NR_DT  NR_UE  ${direction}  throughput=${throughput}  packet_size=${packet_size}
        ...                  duration=${duration}  buffer=${buffer}  protocol=${protocol}  port=${port_num}
        ...  ELSE            Start Data Transfer  NR_DT  NR_UE  ${direction}  throughput=${throughput}  max_segment_size=${max_segment_size}
        ...                  duration=${duration}  buffer=${buffer}  protocol=${protocol}  port=${port_num}
        Run Keyword If  '${user_direction}' == 'both'  Run Keywords
        ...       Log  \n==== Start UL data transfer with ${protocol} data flow  console=True
        ...  AND  Start Data Transfer  NR_UL_DT  NR_UE  UL  throughput=${throughput}  packet_size=${packet_size}
        ...                            duration=${duration}  buffer=${buffer}  protocol=${protocol}  port=${port_num}
        Log  \n==== ${direction} 5G data transfer with ${protocol} data flow started  console=True
        _finish performing 5G data transfer for performance tests helper  NR_DT  ${nr_tput_list}  ${file_path}  ${ind}
        ...    ${direction}  ${protocol}
        Run Keyword If  '${user_direction}' == 'both'
        ...  _finish performing 5G data transfer for performance tests helper  NR_UL_DT  ${additional_nr_tput_list}  ${file_path}  ${ind}
        ...    UL  ${protocol}
        Detach UE  NR_UE
    END

    ${average_tput} =  _get 5G average throughput for performance tests helper  ${nr_tput_list}
    ...                ${num_of_repetitions}  ${file_path}  ${direction}
    ${additional_average_tput} =  Run Keyword If  '${user_direction}' == 'both'
    ...                _get 5G average throughput for performance tests helper  ${additional_nr_tput_list}
    ...                ${num_of_repetitions}  ${file_path}  UL

    ${msg_for_both} =  Catenate  SEPARATOR=${SPACE}
    ...  Average T-put for DL and UL 5G data transfer with ${protocol} data flow has unexpected result
    ...  ${average_tput} >= ${min_expected_tput} and ${additional_average_tput} >= ${additional_min_expected_tput}!
    ${msg_for_one} =  Catenate  SEPARATOR=${SPACE}
    ...  Average T-put for ${user_direction} 5G data transfer with ${protocol} data flow has unexpected result
    ...  ${average_tput} >= ${min_expected_tput}!
    Run Keyword If  '${user_direction}' == 'both'
    ...        Should Be True  ${average_tput} >= ${min_expected_tput} and ${additional_average_tput} >= ${additional_min_expected_tput}
    ...  msg=${msg_for_both}
    ...  ELSE  Should Be True  ${average_tput} >= ${min_expected_tput}
    ...  msg=${msg_for_one}

    [Teardown]  Run Keywords  Stop Datatransfer  NR_DT
                ...  AND      Run Keyword If  '${user_direction}' == 'both'  Stop Datatransfer  NR_UL_DT
                ...  AND      Detach UE  NR_UE


_finish performing 5G data transfer for performance tests helper
    [Arguments]  ${tput_alias}  ${nr_tput_list}  ${file_path}  ${ind}  ${direction}  ${protocol}
    Await Data Transfer Finish  ${tput_alias}
    Log  \n==== Get average throughput of ${direction} 5G data transfer with ${protocol} data flow  console=True
    ${nr_tput} =  Get Average Throughput  ${tput_alias}  10
    ${nr_tput} =  Convert To Number  ${nr_tput}  precision=1
    Append To List  ${nr_tput_list}  ${nr_tput}
    Append To File  ${file_path}  Attempt Number ${ind}\tDirection:${direction}\tResult:${nr_tput} Kbits/sek \n
    [Teardown]  Stop Datatransfer  ${tput_alias}


_get 5G average throughput for performance tests helper
    [Arguments]  ${nr_tput_list}  ${num_of_repetitions}  ${file_path}  ${direction}
    ${average_tput} =  Evaluate  sum(${nr_tput_list})/${num_of_repetitions}
    ${average_tput} =  Evaluate  ${average_tput}/1000
    ${average_tput} =  Convert To Number  ${average_tput}  precision=1
    Log  \n==== Average 5G ${direction} Throughput: ${average_tput} Mbits/sek ====  console=True
    Append To File  ${file_path}  Average 5G ${direction} Throughput ${average_tput} Mbits/sek \n
    [Return]  ${average_tput}


Get SW Version
    [Documentation]
    ...  This KW returns current software version.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  This KW returns current software version. For trunk SW the name of the SW is changed: string
    ...  matching regular expression 'SBTS[a-zA-Z1-9]+_' is replaced by 'SBTS00_'. If user passed sw version
    ...  on their own, then the KW just returns it.
    ...
    ...  **Input Parameters:**
    ...
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | Parameter           | Man. | Description                                                             |
    ...  +=====================+======+=========================================================================+
    ...  | is_trunk_sw         | Yes  | Boolean value defining if SW version is for branch or trunk.            |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | user_sw_version     | No   | SW version provided by user. Default value: ${EMPTY}                    |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | alias               | No   | Alias for 'Get Software Info' KW. Default value: default                |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Get SW Version  True

    [Arguments]  ${is_trunk_sw}  ${user_sw_version}=${EMPTY}  ${alias}=default

    Return From Keyword If  '${user_sw_version}' != ''  ${user_sw_version}
    ${sw_info} =  Get Software Info  alias=${alias}
    ${sw_version} =  Run Keyword If  ${is_trunk_sw}  Replace String Using Regexp  ${sw_info['Active SW version']}
    ...                                                                           SBTS[a-zA-Z1-9]+_
    ...                                                                           SBTS00_
    ...              ELSE                            Set Variable  ${sw_info['Active SW version']}
    [Return]  ${sw_version}


Save And Parse SCF
    [Documentation]
    ...  This KW returns path zto saved SCF and parsed SCF object.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  This KW returns path zto saved SCF and parsed SCF object. This KW requires taf.sbts.oam.coam.admin
    ...  imported as 'admin'.
    ...
    ...  **Input Parameters:**
    ...
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | Parameter           | Man. | Description                                                             |
    ...  +=====================+======+=========================================================================+
    ...  | scf_name            | Yes  | Name of SCF file (without '.xml').                                      |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | scf_path            | No   | Path to directory where SCF will be saved. Default value:               |
    ...  |                     |      | ${LOG_PATH}/misc_logs                                                   |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | alias               | No   | Alias for 'Collect Scf' KW. Default value: default                      |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | export_type         | No   | Argument 'export_type' for 'Get Current SCF File' KW. Default value:    |
    ...  |                     |      | configuration.                                                          |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | strip_namespaces    | No   | Argument 'strip_namespaces' for 'Parse XML' KW. Default value: True     |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Save And Parse SCF  scf_enb

    [Arguments]  ${scf_name}  ${scf_path}=${LOG_PATH}/misc_logs  ${alias}=default  ${export_type}=configuration
    ...  ${strip_namespaces}=True

    #TODO Modify when new admin is used everywhere
    ${use_old_admin} =  _check if old admin library is used  connection=${alias}
    Run Keyword If  ${use_old_admin}  Collect Scf  ${scf_path}/${scf_name}.xml  export_type=${export_type}  alias=${alias}
    ...  ELSE  Get Current SCF File  ${scf_path}  ${scf_name}.xml  export_type=${export_type}  connection=${alias}

    ${parsed_scf} =  Parse XML  ${scf_path}/${scf_name}.xml  strip_namespaces=${strip_namespaces}
    [Return]  ${scf_path}/${scf_name}.xml  ${parsed_scf}


Check If Every Element From List Exists In SCF
    [Documentation]
    ...  This KW checks if every element from list exists in SCF.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  This KW checks if every element from list exists in SCF. Elements need to be from the same class.
    ...  Xpath under which the element is searched looks as follows:
    ...  './/managedObject[substring(@class, string-length(@class) - string-length('${class}') + 1) = '${class}']
    ...  [contains(@distName, '${contains_in_dist_name}')]${xpath_end}'.
    ...  If 'dist_name_substring' is set to True [contains(@distName, '${contains_in_dist_name}')] part
    ...  is replaced with:
    ...  [substring(@distName, string-length(@distName) - string-length('${contains_in_dist_name}') + 1) =
    ...  '${contains_in_dist_name}']
    ...  This KW requires XML robot library.
    ...  This keyword checks if every item passed in 'contains_in_dist_name' exists with every item passed in
    ...  'xpath_end' list and returns boolean value - true if all elements exist or false if they do not.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | parsed_scf             | Yes  | SCF parsed with 'XML.Parse XML'.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | class                  | Yes  | Value in 'class' attribute of managed object, e.g. LNCEL, RMOD,            |
    ...  |                        |      | CLOCK, etc.                                                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | contains_in_dist_name  | Yes  | Fragment of string in 'dist_name' attribute of managed object.             |
    ...  |                        |      | It may be different than what is in 'class'. This may be a list.           |
    ...  |                        |      | It cannot be empty. E.g. LNCEL-12345, LNBTS-1234/LNCEL-12345.              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | xpath_end              | No   | The remaining part of xpath. Usually xpath to the parameter.               |
    ...  |                        |      | E.g. /list[@name='lteNrDssDlRatio']/item/p[@name='dssLteRelSchedWeight'],  |
    ...  |                        |      | /p[@name='lcrId']. This may be a list. Default value: ${EMPTY}             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | dist_name_substring    | No   | Boolean value defining if in xpath substring or contains should            |
    ...  |                        |      | be used for distName. Default value: False.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Collect Scf  ${LOG_PATH}/misc_logs/SCF_eNB_VoNR_enabled.xml  export_type=configuration
    ...     ${scf_enb} =  Parse XML  ${LOG_PATH}/misc_logs/SCF_eNB_VoNR_enabled.xml
    ...     Check If Every Element From List Exists In SCF  ${scf_enb}  DSSNR  LNCEL-${LTE_CELL_ID}

    [Arguments]  ${parsed_scf}  ${class}  ${contains_in_dist_name}  ${xpath_end}=${EMPTY}  ${dist_name_substring}=False

    ${is_list} =  Run Keyword And Return Status  Should Not Be String  ${contains_in_dist_name}
    ${contains_in_dist_name_list} =  Run Keyword If  ${is_list}  Set Variable  ${contains_in_dist_name}
    ...  ELSE  Create List  ${contains_in_dist_name}

    ${is_list} =  Run Keyword And Return Status  Should Not Be String  ${xpath_end}
    ${xpath_end_list} =  Run Keyword If  ${is_list} or '''${xpath_end}''' == '''${EMPTY}'''  Set Variable  ${xpath_end}
    ...  ELSE  Create List  ${xpath_end}

    ${length} =  Get Length  ${contains_in_dist_name_list}
    Should Be True  ${length} > 0  msg=There were no items in list 'contains_in_dist_name'.
    Run Keyword If  '''${xpath_end}''' == '''${EMPTY}'''  Run Keyword And Return  _check if every element exists in list helper
    ...  ${parsed_scf}  ${class}  ${contains_in_dist_name_list}  dist_name_substring=${dist_name_substring}

    ${elements_exist} =  Set Variable  True
    FOR  ${xpath_end}  IN  @{xpath_end_list}
        ${element_exists} =  _check if every element exists in list helper
        ...  ${parsed_scf}  ${class}  ${contains_in_dist_name_list}  xpath_end=${xpath_end}  dist_name_substring=${dist_name_substring}
        ${elements_exist} =  Evaluate  ${elements_exist} and ${element_exists}
    END
    [Return]  ${elements_exist}


_check if every element exists in list helper
    [Arguments]  ${parsed_scf}  ${class}  ${contains_in_dist_name_list}  ${xpath_end}=${EMPTY}  ${dist_name_substring}=False
	log    ${xpath_end}
    ${elements_exist} =  Set Variable  True
    FOR  ${contains_in_dist_name}  IN  @{contains_in_dist_name_list}
        ${element_exists} =  Run Keyword And Return Status
        ...  Check If Element Exists In SCF  ${parsed_scf}  ${class}  ${contains_in_dist_name}
        ...  dist_name_substring=${dist_name_substring}
        ${elements_exist} =  Evaluate  ${elements_exist} and ${element_exists}
    END
    [Return]  ${elements_exist}


Check If Element Exists In SCF
    [Documentation]
    ...  This KW checks if element in SCF specified by the user exists.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  This KW checks if element in SCF specified by the user exists.
    ...  Xpath under which the element is searched looks as follows:
    ...  './/managedObject[substring(@class, string-length(@class) - string-length('${class}') + 1) = '${class}']
    ...  [contains(@distName, '${contains_in_dist_name}')]${xpath_end}'.
    ...  If 'dist_name_substring' is set to True [contains(@distName, '${contains_in_dist_name}')] part
    ...  is replaced with:
    ...  [substring(@distName, string-length(@distName) - string-length('${contains_in_dist_name}') + 1) =
    ...  '${contains_in_dist_name}']
    ...  This KW requires XML robot library.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | parsed_scf             | Yes  | SCF parsed with 'XML.Parse XML'.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | class                  | Yes  | Value in 'class' attribute of managed object, e.g. LNCEL, RMOD,            |
    ...  |                        |      | CLOCK, etc.                                                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | contains_in_dist_name  | Yes  | Fragment of string in 'dist_name' attribute of managed object.             |
    ...  |                        |      | It may be different than what is in 'class'.                               |
    ...  |                        |      | E.g. LNCEL-12345, LNBTS-1234/LNCEL-12345.                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | xpath_end              | No   | The remaining part of xpath. Usually xpath to the parameter.               |
    ...  |                        |      | E.g. /list[@name='lteNrDssDlRatio']/item/p[@name='dssLteRelSchedWeight'],  |
    ...  |                        |      | /p[@name='lcrId']. Default value: ${EMPTY}                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | dist_name_substring    | No   | Boolean value defining if in xpath substring or contains should            |
    ...  |                        |      | be used for distName. Default value: False.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Collect Scf  ${LOG_PATH}/misc_logs/SCF_eNB_VoNR_enabled.xml  export_type=configuration
    ...     ${scf_enb} =  Parse XML  ${LOG_PATH}/misc_logs/SCF_eNB_VoNR_enabled.xml
    ...     Check If Element Exists In SCF  ${scf_enb}  DSSNR  LNCEL-${LTE_CELL_ID}

    [Arguments]  ${parsed_scf}  ${class}  ${contains_in_dist_name}  ${xpath_end}=${EMPTY}  ${dist_name_substring}=False

    ${contains_or_substring} =  Set Variable If  ${dist_name_substring}
    ...  [substring(@distName, string-length(@distName) - string-length('${contains_in_dist_name}') + 1) = '${contains_in_dist_name}']
    ...  [contains(@distName, '${contains_in_dist_name}')]

    ${xpath} =  Catenate  SEPARATOR=
    ...  .//managedObject[substring(@class, string-length(@class) - string-length('${class}') + 1) = '${class}']
    ...  ${contains_or_substring}${xpath_end}
    XML.Element Should Exist  ${parsed_scf}  ${xpath}
    Log  SUCCESS! Element ${xpath} exists.  console=True


Check Every Element In SCF
    [Documentation]
    ...  This KW checks if every element in SCF specified by the user is the same as expected.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  This KW checks if every element in SCF specified by the user is the same as expected.
    ...  Xpath under which the element is searched looks as follows:
    ...  './/managedObject[substring(@class, string-length(@class) - string-length('${class}') + 1) = '${class}']
    ...  [contains(@distName, '${contains_in_dist_name}')]${xpath_end}'.
    ...  If 'dist_name_substring' is set to True [contains(@distName, '${contains_in_dist_name}')] part
    ...  is replaced with:
    ...  [substring(@distName, string-length(@distName) - string-length('${contains_in_dist_name}') + 1) =
    ...  '${contains_in_dist_name}']
    ...  This KW requires XML robot library.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | parsed_scf             | Yes  | SCF parsed with 'XML.Parse XML'.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | class                  | Yes  | Value in 'class' attribute of managed object, e.g. LNCEL, RMOD,            |
    ...  |                        |      | CLOCK, etc.                                                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | contains_in_dist_name  | Yes  | Fragment of string in 'dist_name' attribute of managed object.             |
    ...  |                        |      | It may be different than what is in 'class'.                               |
    ...  |                        |      | E.g. LNCEL-12345, LNBTS-1234/LNCEL-12345.                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | xpath_end              | Yes  | The remaining part of xpath. Usually xpath to the parameter.               |
    ...  |                        |      | E.g. /list[@name='lteNrDssDlRatio']/item/p[@name='dssLteRelSchedWeight'],  |
    ...  |                        |      | /p[@name='lcrId'].                                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | expected_element       | Yes  | Element which schould be found in SCF under given xpath.                   |
    ...  |                        |      | E.g. <p name="actLteNrDssVoNr">true</p>.                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | is_regexp              | No   | Boolean value defining if Element should be equal to string (False)        |
    ...  |                        |      | or matched using regular expression. Default value: False.                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | dist_name_substring    | No   | Boolean value defining if in xpath substring or contains should            |
    ...  |                        |      | be used for distName. Default value: False.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     admin.Get Current SCF File  ${LOG_PATH}/misc_logs  SCF_eNB.xml  export_type=configuration
    ...     ${scf_enb} =  Parse XML  ${LOG_PATH}/misc_logs/SCF_eNB.xml
    ...     Check Every Element In SCF  ${scf_enb}  DSSNR  LNCEL  /p[@name='actLteNrDssVoNr']
    ...     <p name="actLteNrDssVoNr">(true|false)</p>  is_regexp=True

    [Arguments]  ${parsed_scf}  ${class}  ${contains_in_dist_name}  ${xpath_end}  ${expected_element}
    ...  ${is_regexp}=False  ${dist_name_substring}=False

    ${contains_or_substring} =  Set Variable If  ${dist_name_substring}
    ...  [substring(@distName, string-length(@distName) - string-length('${contains_in_dist_name}') + 1) = '${contains_in_dist_name}']
    ...  [contains(@distName, '${contains_in_dist_name}')]
    ${xpath} =  Catenate  SEPARATOR=
    ...  .//managedObject[substring(@class, string-length(@class) - string-length('${class}') + 1) = '${class}']
    ...  ${contains_or_substring}${xpath_end}
    ${scf_element_list} =  XML.Get Elements  ${parsed_scf}  ${xpath}
    FOR  ${scf_element}  IN  @{scf_element_list}
        Run Keyword If  not ${is_regexp}  XML.Elements Should Be Equal  ${scf_element}  ${expected_element}
        ...  ELSE                         Elements Should Match Regexp  ${scf_element}  ${expected_element}
    END
    Log  SUCCESS! All elements are equal to expected: ${expected_element}.  console=True


Elements Should Match Regexp
    [Documentation]
    ...  This KW checks if XML element matches given regular expression.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  This KW checks if XML element matches given regular expression. It is important to note that
    ...  namespaces will be included during comparision unless they are strippedwhen using 'parse xml' KW.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | checked_element        | Yes  | XML element which will be checked. It will be converted to string.         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | expected_element       | Yes  | Expected element in string form.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     admin.Get Current SCF File  ${LOG_PATH}/misc_logs  SCF_eNB.xml  export_type=configuration
    ...     ${scf_enb} =  Parse XML  ${LOG_PATH}/misc_logs/SCF_eNB.xml
    ...     ${element} =  Get Element ${scf_enb}  .//p[@name='selectOuterPuschRegion']
    ...     Elements Should Match Regexp  ${element}  <p name="selectOuterPuschRegion">(None|UpperEdge)</p>

    [Arguments]  ${checked_element}  ${expected_element}
    ${checked_element_string} =  XML.Element To String  ${checked_element}
    Should Match Regexp  ${checked_element_string}  ${expected_element}


Get LteNrDssDlRatio/LteNrDssUlRatio Dictionary From SCF
    [Documentation]
    ...  This KW gets list of parameters with values of LteNrDssDlRatio/LteNrDssUlRatio from SCF and returns them as dictionary.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  This KW gets list of parameters with values of LteNrDssDlRatio/LteNrDssUlRatio from SCF and returns them as dictionary.
    ...  Xpath under which the element is searched looks as follows:
    ...  './/managedObject[substring(@class, string-length(@class) - string-length('${class}') + 1) = '${class}']
    ...  [contains(@distName, '${contains_in_dist_name}')]${xpath_end}'.
    ...  If 'dist_name_substring' is set to True [contains(@distName, '${contains_in_dist_name}')] part
    ...  is replaced with:
    ...  [substring(@distName, string-length(@distName) - string-length('${contains_in_dist_name}') + 1) =
    ...  '${contains_in_dist_name}']
    ...  This KW requires XML robot library.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | parsed_scf             | No   | SCF parsed with 'XML.Parse XML'. Default value: ${PARSED_SCF_ENB}          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | class                  | No   | Value in 'class' attribute of managed object, e.g. LNCEL, RMOD,            |
    ...  |                        |      | CLOCK, etc. Default value: DSSNR.                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | scf_object_path        | No   | Path to DSSNR object in SCF. Default value:                                |
    ...  |                        |      | ${LTE_LNBTS_DISTNAME}/LNCEL-${LTE_CELL_ID}/DSSNR-0                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | ul_dl_ratio_name       | No   | Name of list parameter for DSS ratio. Can be either 'lteNrDssDlRatio'      |
    ...  |                        |      | or 'lteNrDssUlRatio'. Default value: lteNrDssDlRatio.                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | dist_name_substring    | No   | Boolean value defining if in xpath substring or contains should            |
    ...  |                        |      | be used for distName. Default value: False.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     admin.Get Current SCF File  ${LOG_PATH}/misc_logs  SCF_eNB.xml  export_type=configuration
    ...     ${scf_enb} =  Parse XML  ${LOG_PATH}/misc_logs/SCF_eNB.xml
    ...     Get LteNrDssDlRatio/LteNrDssUlRatio Dictionary From SCF  ${scf_enb}
    ...     ...  MRBTS-19841/LNBTS-19841/LNCEL-17742/DSSNR-0  lteNrDssDlRatio

    [Arguments]  ${parsed_scf}=${PARSED_SCF_ENB}  ${class}=DSSNR  ${scf_object_path}=${LTE_LNBTS_DISTNAME}/LNCEL-${LTE_CELL_ID}/DSSNR-0
        ...  ${ul_dl_ratio_name}=lteNrDssDlRatio  ${dist_name_substring}=False

    ${ratio_dict} =  Get Parameter List As Dictionary From SCF  parsed_scf=${parsed_scf}  class=${class}
    ...  scf_object_path=${scf_object_path}  list_name=${ul_dl_ratio_name}  dist_name_substring=${dist_name_substring}
    [Return]  ${ratio_dict}

Get Parameter List As Dictionary From SCF
    [Documentation]
    ...  This KW gets list of parameters with values from SCF and returns them as dictionary.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  This KW gets list of parameters with values from SCF and returns them as dictionary.
    ...  Xpath under which the element (managed object) is searched
    ...  './/managedObject[substring(@class, string-length(@class) - string-length('${class}') + 1) = '${class}']
    ...  ${contains_or_substring}/list[@name='${list_name}']/item/p'.
    ...  If 'dist_name_substring' is set to True [contains(@distName, '${contains_in_dist_name}')] part
    ...  is replaced with:
    ...  [substring(@distName, string-length(@distName) - string-length('${contains_in_dist_name}') + 1) =
    ...  '${contains_in_dist_name}']
    ...  This KW requires XML robot library.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | parsed_scf             | Yes  | SCF parsed with 'XML.Parse XML'.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | class                  | Yes  | Value in 'class' attribute of managed object, e.g. LNCEL, RMOD, CLOCK, etc.|
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | scf_object_path        | Yes  | Path to object of 'class' in SCF.                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | list_name              | Yes  | Name of parameter list.                                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | dist_name_substring    | No   | Boolean value defining if in xpath substring or contains should            |
    ...  |                        |      | be used for distName. Default value: False.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     admin.Get Current SCF File  ${LOG_PATH}/misc_logs  SCF_eNB.xml  export_type=configuration
    ...     ${scf_enb} =  Parse XML  ${LOG_PATH}/misc_logs/SCF_eNB.xml
    ...     Get List As Dictionary From SCF  ${scf_enb}  NRCELL  MRBTS-55014/NRBTS-55014/NRCELL-0  periodicCsiAcquisition
    [Arguments]  ${parsed_scf}  ${class}  ${scf_object_path}  ${list_name}  ${dist_name_substring}=False

    ${contains_or_substring} =  Set Variable If  ${dist_name_substring}
    ...  [substring(@distName, string-length(@distName) - string-length('${scf_object_path}') + 1) = '${scf_object_path}']
    ...  [contains(@distName, '${scf_object_path}')]
    ${xpath} =  Catenate  SEPARATOR=
    ...  .//managedObject[substring(@class, string-length(@class) - string-length('${class}') + 1) = '${class}']
    ...  ${contains_or_substring}/list[@name='${list_name}']/item/p
    ${dl_ratio_elements} =  Get Elements  ${parsed_scf}  ${xpath}
    ${ratio_dict} =  Create Dictionary
    FOR  ${el}  IN  @{dl_ratio_elements}
        ${name} =   Get Element Attribute   ${el}  name
        ${value} =  Get Element Text	    ${el}
        Log  Adding ${name}=${value} to dictionary.  console=True
        Set To Dictionary  ${ratio_dict}  ${name}  ${value}
    END
    [Return]  ${ratio_dict}


Remove Flag From Swconfig
    [Documentation]
    ...  This KW removes specified flag from swconfig.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW removes specified flag from swconfig. It can connect to BTS directly or through proxy.
    ...  | This KW does not perform reset.
    ...
    ...  **Input Parameters:**
    ...
    ...  +--------------------------------+------+----------------------------------------------------------+
    ...  | Parameter                      | Man. | Description                                              |
    ...  +================================+======+==========================================================+
    ...  | ip                             | Yes  | IP of BTS for which flag should be removed from          |
    ...  |                                |      | swconfig.                                                |
    ...  +--------------------------------+------+----------------------------------------------------------+
    ...  | flag                           | Yes  | Flag with value that should be removed from swconfig     |
    ...  |                                |      | file, e.g. 0x670016=0x10.                                |
    ...  +--------------------------------+------+----------------------------------------------------------+
    ...  | proxy_ip                       | No   | Proxy through which connection is made, e.g. IP of 5G    |
    ...  |                                |      | VM. Default value: ${EMPTY}.                             |
    ...  +--------------------------------+------+----------------------------------------------------------+
    ...  | proxy_username                 | No   | Username for proxy. Default value: ute.                  |
    ...  +--------------------------------+------+----------------------------------------------------------+
    ...  | proxy_password                 | No   | Password for proxy. Default value: ute.                  |
    ...  +--------------------------------+------+----------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Remove Flag From Swconfig  12.34.56.78  0x670016=0x10  proxy_ip=11.22.33.44

    [Arguments]  ${ip}  ${flag}  ${proxy_ip}=${EMPTY}  ${proxy_username}=ute  ${proxy_password}=ute

    Run Keyword If  '${proxy_ip}' != ''  Run Keywords
    ...  ssh.Connect To  ${proxy_ip}  ${proxy_username}  ${proxy_password}  alias=proxy_connection
    ...  AND  ssh.Connect To  ${ip}  toor4nsn  oZPS0POrRieRtu  proxy=proxy_connection  alias=default
    ...  ELSE  ssh.Connect To  ${ip}  toor4nsn  oZPS0POrRieRtu  alias=default
    _send command read output and error  sed -i '/${flag}/d' /ffs/run/swconfig.txt
    _send command read output and error  cat /ffs/run/swconfig.txt
    _send command read output and error  cat /ffs/run/swconfig.txt |grep ${flag}
    [Teardown]  Run Keywords  ssh.Disconnect  connection=default
    ...  AND  Run Keyword If  '${proxy_ip}' != ''  ssh.Disconnect  connection=proxy_connection


Add Flag To Swconfig
    [Documentation]
    ...  This KW adds specified flag to swconfig.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW adds specified flag to swconfig. It can connect to BTS directly or through proxy.
    ...  | This KW does not perform reset.
    ...
    ...  **Input Parameters:**
    ...
    ...  +--------------------------------+------+----------------------------------------------------------+
    ...  | Parameter                      | Man. | Description                                              |
    ...  +================================+======+==========================================================+
    ...  | ip                             | Yes  | IP of BTS for which flag should be added to swconfig.    |
    ...  +--------------------------------+------+----------------------------------------------------------+
    ...  | flag                           | Yes  | Flag with value that should be added to swconfig file,   |
    ...  |                                |      | e.g. 0x670016=0x10.                                      |
    ...  +--------------------------------+------+----------------------------------------------------------+
    ...  | proxy_ip                       | No   | Proxy through which connection is made, e.g. IP of 5G    |
    ...  |                                |      | VM. Default value: ${EMPTY}.                             |
    ...  +--------------------------------+------+----------------------------------------------------------+
    ...  | proxy_username                 | No   | Username for proxy. Default value: ute.                  |
    ...  +--------------------------------+------+----------------------------------------------------------+
    ...  | proxy_password                 | No   | Password for proxy. Default value: ute.                  |
    ...  +--------------------------------+------+----------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Add Flag To Swconfig  12.34.56.78  0x670016=0x10  proxy_ip=11.22.33.44

    [Arguments]  ${ip}  ${flag}  ${proxy_ip}=${EMPTY}  ${proxy_username}=ute  ${proxy_password}=ute

    Run Keyword If  '${proxy_ip}' != ''  Run Keywords
    ...  ssh.Connect To  ${proxy_ip}  ${proxy_username}  ${proxy_password}  alias=proxy_connection
    ...  AND  ssh.Connect To  ${ip}  toor4nsn  oZPS0POrRieRtu  proxy=proxy_connection  alias=default
    ...  ELSE  ssh.Connect To  ${ip}  toor4nsn  oZPS0POrRieRtu  alias=default
    _send command read output and error  echo '''\n${flag}''' >> /ffs/run/swconfig.txt
    _send command read output and error  cat /ffs/run/swconfig.txt
    _send command read output and error  cat /ffs/run/swconfig.txt |grep ${flag}
    [Teardown]  Run Keywords  ssh.Disconnect  connection=default
    ...  AND  Run Keyword If  '${proxy_ip}' != ''  ssh.Disconnect  connection=proxy_connection


_send command read output and error
    [Arguments]  ${command}  ${connection}=default
    ssh.Send Command  ${command}  connection=${connection}
    ssh.Read Output  connection=${connection}
    ${err} =  ssh.Read Error  connection=${connection}
    Should Be True  '${err}' == ''  msg=There were errors during execution of '${command}' command: ${err}


Save Swconfigs And Check If Flag Exists For Specified BTS
    [Documentation]
    ...  This KW saves swconfig and checks if given flag with specified value exists.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW saves swconfig for SMOD and checks if given flag with specified value exists.
    ...  | The file is saved under path: ${LOG_PATH}/swconfig/swconfig_${string}.txt.
    ...  | It also checks if flag exists and depending on value of 'flag_should_exist' fails
    ...  | if it does not exist (for flag_should_exist=True) or fails if it exists
    ...  | (for flag_should_exist=False).
    ...
    ...  **Input Parameters:**
    ...
    ...  +--------------------------------+------+----------------------------------------------------------+
    ...  | Parameter                      | Man. | Description                                              |
    ...  +================================+======+==========================================================+
    ...  | string                         | Yes  | String added to swconfig name.                           |
    ...  +--------------------------------+------+----------------------------------------------------------+
    ...  | ip                             | Yes  | IP of BTS for which flag should be checked in swconfig.  |
    ...  +--------------------------------+------+----------------------------------------------------------+
    ...  | flag                           | Yes  | Flag with value that should or should not be found       |
    ...  |                                |      | in swconfig file depending on 'flag_should_exist' value, |
    ...  |                                |      | e.g. 0x670016=0x10.                                      |
    ...  +--------------------------------+------+----------------------------------------------------------+
    ...  | flag_should_exist              | No   | Boolean value defining if flag should be found inside    |
    ...  |                                |      | swconfig or not. Default value=False.                    |
    ...  +--------------------------------+------+----------------------------------------------------------+
    ...  | proxy_ip                       | No   | Proxy through which connection is made, e.g. IP of 5G    |
    ...  |                                |      | VM. Default value: ${EMPTY}.                             |
    ...  +--------------------------------+------+----------------------------------------------------------+
    ...  | proxy_username                 | No   | Username for proxy. Default value: ute.                  |
    ...  +--------------------------------+------+----------------------------------------------------------+
    ...  | proxy_password                 | No   | Password for proxy. Default value: ute.                  |
    ...  +--------------------------------+------+----------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Save Swconfigs And Check If Flag Exists For Specified BTS  new_swconfig.txt  12345=0

    [Arguments]  ${string}  ${ip}  ${flag}  ${flag_should_exist}=False
    ...  ${proxy_ip}=${EMPTY}  ${proxy_username}=ute  ${proxy_password}=ute

    ${file_path} =  _collect swconfig for specified bts  ${string}  ${ip}  proxy_ip=${proxy_ip}
    ...  proxy_username=${proxy_username}  proxy_password=${proxy_password}
    ${swconfig_name} =  OperatingSystem.Get File  ${file_path}
    ${flag_verification} =  Evaluate  ("${flag}" in """${swconfig_name}""") == ${flag_should_exist}
    Should Be True  ${flag_verification}  msg=Error during flag existence verification in swconfig.


_collect swconfig for specified bts
    [Arguments]  ${string}  ${ip}  ${proxy_ip}=${EMPTY}  ${proxy_username}=ute  ${proxy_password}=ute
    Run Keyword If  '${proxy_ip}' != ''  Run Keywords
    ...  ssh.Connect To  ${proxy_ip}  ${proxy_username}  ${proxy_password}  alias=proxy_connection
    ...  AND  ssh.Connect To  ${ip}  toor4nsn  oZPS0POrRieRtu  proxy=proxy_connection  alias=default
    ...  ELSE  ssh.Connect To  ${ip}  toor4nsn  oZPS0POrRieRtu  alias=default
    ssh.Download File  /ffs/run/swconfig.txt  ${LOG_PATH}/swconfig/swconfig_${string}.txt
    ...  connection=default
    [Teardown]  Run Keywords  ssh.Disconnect  connection=default
    ...  AND  Run Keyword If  '${proxy_ip}' != ''  ssh.Disconnect  connection=proxy_connection
    [Return]  ${LOG_PATH}/swconfig/swconfig_${string}.txt


Analyze Time Difference Of CRM Prints
    [Documentation]
    ...  This KW checks if time difference between CRM prints for Superfast feature is equal to or lower than 10ms
    ...  and returns percent of such prints.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | syslog_msg             | No   | Syslog string with CRM prints, thy need to contain date in format:         |
    ...  |                        |      | <%Y-%m-%dT%H:%M:%S.%fZ>.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${syslog_msg} =  Wait For Message In Syslog File
    ...     ...  regexp=CRMexe.*CRM\\/e3E9c0g2AF9c0\\/(Init|Alloc|Initial)\\s(\\[([0-9]+|,|:|\\s)+\\]){15,30}
    ...     ...  timeout=30s  alias=eNB
    ...     Analyze Time Difference Of CRM Prints  ${syslog_msg}

    [Arguments]  ${syslog_msg}
    ${less_than_10_ms_counter} =  Set Variable  0
    ${syslog_list} =  Str.Split To Lines  ${syslog_msg}
    ${all_prints} =  Get Length  ${syslog_list}
    Should Be True  ${all_prints} > 1  msg=There was only one print found in syslog.
    FOR  ${index}  ${msg}  IN ENUMERATE  @{syslog_list[:-1]}
        ${current_line_time} =  Get Regexp Matches  ${msg}
        ...  <[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-2][0-9]:[0-5][0-9]:[0-5][0-9]\\.[0-9]{6}Z>
        ${next_line} =  Evaluate  ${index} + 1
        ${next_line_time} =  Get Regexp Matches  ${syslog_list[${next_line}]}
        ...  <[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-2][0-9]:[0-5][0-9]:[0-5][0-9]\\.[0-9]{6}Z>
        ${difference} =  Subtract Date From Date  ${next_line_time[0]}  ${current_line_time[0]}
        ...  date1_format=<%Y-%m-%dT%H:%M:%S.%fZ>  date2_format=<%Y-%m-%dT%H:%M:%S.%fZ>
        ${less_than_10_ms_counter} =  Run Keyword If  ${difference} <= 0.010  Evaluate  ${less_than_10_ms_counter} + 1
        ...  ELSE  Set Variable  ${less_than_10_ms_counter}
    END
    Log  All prints: ${all_prints}\nPrints with difference less or equal 10ms: ${less_than_10_ms_counter}  console=True
    ${percent} =  Evaluate  ( float(${less_than_10_ms_counter}) / float(${all_prints}) ) * 100
    Log  Percent of prints with time difference less or equal 10ms: ${percent}%  console=True
    [Return]  ${percent}


Create And Activate Delta For Simple ChBw Change
    [Documentation]
    ...  This KW creates delta for recommissioning of channel bandwidth on eNB and gNB side and activates it.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  This KW creates delta for recommissioning of channel bandwidth on eNB and gNB side and activates it.
    ...  It is possible to turn off activation by setting 'without_activation' to False. This KW returns contents
    ...  of delat for eNB and gNB. The channel bandwidth will be set the same for UL and DL for both eNB and gNB.
    ...
    ...  **Input Parameters:**
    ...
    ...  +--------------------------+------+----------------------------------------------------------------------------+
    ...  | Parameter                | Man. | Description                                                                |
    ...  +==========================+======+============================================================================+
    ...  | delta_name               | Yes  | Name for created delta. ENB delta will have suffix '_eNB' and gNB will     |
    ...  |                          |      | have suffix '_gNB'.                                                        |
    ...  +--------------------------+------+----------------------------------------------------------------------------+
    ...  | lte_cell_id              | Yes  | ID of LTE cell where change should be made.                                |
    ...  +--------------------------+------+----------------------------------------------------------------------------+
    ...  | nr_cell_id               | Yes  | ID of NR cell where change should be made.                                 |
    ...  +--------------------------+------+----------------------------------------------------------------------------+
    ...  | chbw                     | Yes  | Numerical value for dlChBw, ulChBw for eNB and chBwDl, chBwUl for gNB      |
    ...  |                          |      | ( without 'MHz'), e.g. 15.                                                 |
    ...  +--------------------------+------+----------------------------------------------------------------------------+
    ...  | bwp_id_initial           | Yes  | ID of initial BWP profile that should be prepared beforehand in SCF,       |
    ...  |                          |      | e.g. 7.                                                                    |
    ...  +--------------------------+------+----------------------------------------------------------------------------+
    ...  | bwp_id_dedicated         | Yes  | ID of dedicated BWP profile that should be prepared beforehand in SCF,     |
    ...  |                          |      | e.g. 8.                                                                    |
    ...  +--------------------------+------+----------------------------------------------------------------------------+
    ...  | msg1_frequency_start     | Yes  | Value for msg1FrequencyStart, e.g. 7.                                      |
    ...  +--------------------------+------+----------------------------------------------------------------------------+
    ...  | blanked_pucch            | No   | Value for blankedPucch, e.g. 2. If no value is given this parameter        |
    ...  |                          |      | will be skipped. Default value: ${EMPTY}.                                  |
    ...  +--------------------------+------+----------------------------------------------------------------------------+
    ...  | recommissioning_timeout  | No   | Timeout for performing recommissioning. Default value: 600.                |
    ...  +--------------------------+------+----------------------------------------------------------------------------+
    ...  | on_air_timeout           | No   | Timeout for whole BTS to go back on air. Default value: 10m.               |
    ...  +--------------------------+------+----------------------------------------------------------------------------+
    ...  | without_activation       | No   | Boolean value defining if recommissining should not be preformed.          |
    ...  |                          |      | If value is False recommissioning will be performed. Default value: False. |
    ...  +--------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${syslog_msg} =  Wait For Message In Syslog File
    ...     ...  regexp=CRMexe.*CRM\\/e13D8c2gCF5Bc1\\/(Init|Alloc|Initial)\\s(\\[([0-9]+|,|:|\\s)+\\]){15,30}
    ...     ...  timeout=30s  alias=eNB
    ...     Analyze Time Difference Of CRM Prints  ${syslog_msg}

    [Arguments]  ${delta_name}  ${lte_cell_id}  ${nr_cell_id}  ${chbw}  ${bwp_id_initial}  ${bwp_id_dedicated}
    ...  ${msg1_frequency_start}  ${blanked_pucch}=${EMPTY}  ${recommissioning_timeout}=600  ${on_air_timeout}=10m
    ...  ${without_activation}=False
    Log  Create and activate delta for simple ChBw change.  console=True

    Create Delta  ${delta_name}_eNB
    _simple eNB delta for chbw  ${delta_name}_eNB  ${lte_cell_id}  ${chbw}  blanked_pucch=${blanked_pucch}
    ${delta_enb} =  Get Delta  delta_id=${delta_name}_eNB
    Log  Delta contents for eNB side:\n${delta_enb}  console=True

    Create Delta  ${delta_name}_gNB
    _simple gNB delta for chbw  ${delta_name}_gNB  ${nr_cell_id}  ${chbw}  ${bwp_id_initial}  ${bwp_id_dedicated}
    ...  ${msg1_frequency_start}
    ${delta_gnb} =  Get Delta  delta_id=${delta_name}_gNB
    Log  Delta contents for gNB side:\n${delta_gnb}  console=True

    Return From Keyword If  ${without_activation}  ${delta_enb}  ${delta_gnb}

    Log  Perform recommissioning on eNB side...  console=True
    Perform Delta Recommissioning  ${delta_enb}  timeout=${recommissioning_timeout}
    Log  Perform recommissioning on gNB side...  console=True
    Perform Delta Recommissioning  ${delta_gnb}  timeout=${recommissioning_timeout}  alias=gNB

    Wait Until Keyword Succeeds  ${on_air_timeout}  1m  Verify BTS States For IWK Test
    Log  ChBw recommissioning completed.  console=True
    [Return]  ${delta_enb}  ${delta_gnb}


_simple eNB delta for chbw
    [Arguments]  ${delta_name}  ${lte_cell_id}  ${chbw}  ${blanked_pucch}=${EMPTY}
    ${_}  ${parsed_scf_enb}=  Save And Parse SCF  SCF_eNB_before_chBW_change

    ${lncel_fdd_dist_name} =  Get DistName Attribute From SCF  ${parsed_scf_enb}  LNCEL_FDD  LNCEL-${lte_cell_id}/
    Append Parameter Update To Delta  ${lncel_fdd_dist_name}  dlChBw  ${chbw} MHz  delta_id=${delta_name}
    Append Parameter Update To Delta  ${lncel_fdd_dist_name}  ulChBw  ${chbw} MHz  delta_id=${delta_name}
    Run Keyword If  '${blanked_pucch}' != ''  Append Parameter Update To Delta  ${lncel_fdd_dist_name}
    ...  blankedPucch  ${blanked_pucch}  delta_id=${delta_name}


_simple gNB delta for chbw
    [Arguments]  ${delta_name}  ${nr_cell_id}  ${chbw}  ${bwp_id_initial}  ${bwp_id_dedicated}  ${msg1_frequency_start}
    ${_}  ${parsed_scf_gnb}=  Save And Parse SCF  SCF_gNB_before_chBW_change  alias=gNB

    ${nrcell_fdd_dist_name} =  Get DistName Attribute From SCF  ${parsed_scf_gnb}  NRCELL_FDD  NRCELL-${nr_cell_id}/
    ${nrcell_dist_name} =  Get DistName Attribute From SCF  ${parsed_scf_gnb}  NRCELL  NRCELL-${nr_cell_id}
    ...  dist_name_substring=True
    ${nrbts_id} =  Get BTS ID From ADMIN  alias=gNB
    ${nrbts_dist_name} =  Get DistName Attribute From SCF  ${parsed_scf_gnb}  NRBTS  NRBTS-${nrbts_id}
    ...  dist_name_substring=True
    Append Complex Item To Delta  ${nrcell_dist_name}  list_name=cellBwpList
    ...                           cellBwpId=0
    ...                           bwpDN=${nrbts_dist_name}/BWP_PROFILE-${bwp_id_initial}
    ...                           delta_id=${delta_name}
    Append Complex Item To Delta  ${nrcell_dist_name}  list_name=cellBwpList
    ...                           cellBwpId=1
    ...                           bwpDN=${nrbts_dist_name}/BWP_PROFILE-${bwp_id_dedicated}
    ...                           delta_id=${delta_name}
    Append Parameter Update To Delta  ${nrcell_dist_name}  msg1FrequencyStart  ${msg1_frequency_start}
    ...  delta_id=${delta_name}
    Append Parameter Update To Delta  ${nrcell_fdd_dist_name}  chBwDl  ${chbw}MHz  delta_id=${delta_name}
    Append Parameter Update To Delta  ${nrcell_fdd_dist_name}  chBwUl  ${chbw}MHz  delta_id=${delta_name}


Get DistName Attribute From SCF
    [Documentation]
    ...  This KW gets attribute distName of object in SCF.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  This KW gets text of distName of object in SCF. Xpath under which the element is searched looks as follows:
    ...  './/managedObject[substring(@class, string-length(@class) - string-length('${class}') + 1) = '${class}']
    ...  [contains(@distName, '${contains_in_dist_name}')]${xpath_end}'.
    ...  If 'dist_name_substring' is set to True [contains(@distName, '${contains_in_dist_name}')] part
    ...  is replaced with:
    ...  [substring(@distName, string-length(@distName) - string-length('${contains_in_dist_name}') + 1) =
    ...  '${contains_in_dist_name}']
    ...  If 'return_list' is set to True this keyword will be able to return list of multiple distnames
    ...  available under created xpath.
    ...  This KW requires XML robot library.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | parsed_scf             | Yes  | SCF parsed with 'XML.Parse XML'.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | class                  | Yes  | Value in 'class' attribute of managed object, e.g. LNCEL, RMOD,            |
    ...  |                        |      | CLOCK, etc.                                                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | contains_in_dist_name  | Yes  | Fragment of string in 'dist_name' attribute of managed object.             |
    ...  |                        |      | It may be different than what is in 'class'.                               |
    ...  |                        |      | E.g. LNCEL-12345, LNBTS-1234/LNCEL-12345.                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | xpath_end              | No   | The remaining part of xpath. Usually xpath to the parameter.               |
    ...  |                        |      | E.g. /list[@name='lteNrDssDlRatio']/item/p[@name='dssLteRelSchedWeight'],  |
    ...  |                        |      | /p[@name='lcrId']. Default value: ${EMPTY}.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | dist_name_substring    | No   | Boolean value defining if in xpath substring or contains should            |
    ...  |                        |      | be used for distName. Default value: False.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | return_list            | No   | Boolean value defining if result should be retunred in a list.             |
    ...  |                        |      | Should be used when multiple results are expected. Default value: False.   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Collect Scf  ${LOG_PATH}/misc_logs/SCF_gNB_VoNR_enabled.xml  export_type=configuration  alias=gNB
    ...     ${scf_gnb} =  Parse XML  ${LOG_PATH}/misc_logs/SCF_gNB_VoNR_enabled.xml
    ...     ${nr_lcr_id} =  Get DistName Attribute From SCF  ${scf_gnb}  NRCELL  NRCELL-${NR_CELL_ID}  /p[@name='lcrId']

    [Arguments]  ${parsed_scf}  ${class}  ${contains_in_dist_name}  ${xpath_end}=${EMPTY}  ${dist_name_substring}=False
    ...  ${return_list}=False

    ${contains_or_substring} =  Set Variable If  ${dist_name_substring}
    ...  [substring(@distName, string-length(@distName) - string-length('${contains_in_dist_name}') + 1) = '${contains_in_dist_name}']
    ...  [contains(@distName, '${contains_in_dist_name}')]

    ${xpath} =  Catenate  SEPARATOR=
    ...  .//managedObject[substring(@class, string-length(@class) - string-length('${class}') + 1) = '${class}']
    ...  ${contains_or_substring}${xpath_end}
    ${dist_name} =  Run Keyword If  ${return_list}  _get elements attribute  ${parsed_scf}  distName  ${xpath}
    ...  ELSE  XML.Get Element Attribute  ${parsed_scf}  distName  ${xpath}
    [Return]  ${dist_name}


_get elements attribute
    [Arguments]  ${parsed_scf}  ${attribute_name}  ${xpath}
	log    ${attribute_name}
    ${elements} =  Get Elements  ${parsed_scf}  ${xpath}
    ${attribute_list} =  Create List
    FOR  ${element}  IN  @{elements}
        ${dist_name} =  XML.Get Element Attribute  ${element}  distName
        Append To List  ${attribute_list}  ${dist_name}
    END
    [Return]  ${attribute_list}



Check CNI-61110 Status
    [Documentation]
    ...  This KW returns status of CNI-61110
    ...
    ...  | **Author:** mariusz.makuch@nokia.com
    ...  | **Maintainer:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  This KW checks if CNI-61110 is activated on current SW.
    ...
    ...  **Input Parameters:**
    ...
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | Parameter           | Man. | Description                                                             |
    ...  +=====================+======+=========================================================================+
    ...  | alias               | No   | Alias for 'Get Software Info' KW. Default value: default                |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Check CNI-61110 Status

    [Arguments]  ${alias}=default

    ${sw_version} =  Get SW Version  False  alias=${alias}
    ${status} =   Run Keyword And Return Status  Should Not Match Regexp  ${sw_version}  (SBTS\\d{2}[^Rr].*)|(SBTS22R[12].*)|(5G.*)
    [Return]  ${status}


Check If Availability Status Exists
    [Documentation]
    ...  This KW checks if availability status exist in infomodel
    ...
    ...  | **Author:** mariusz.makuch@nokia.com
    ...  | **Maintainer:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  This KW checks if availability status exist in infomodel for current software.
    ...
    ...  **Input Parameters:**
    ...
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | Parameter           | Man. | Description                                                             |
    ...  +=====================+======+=========================================================================+
    ...  | class               | Yes  | Value in 'class' attribute of managed object, e.g. LNCEL, RMOD,         |
    ...  |                     |      | CLOCK, etc.                                                             |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | item_id             | Yes  | Infomodel path to object to be checked                                  |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | time                | No   | Time to wait for positive procedure result. Default value: 10s          |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...  | alias               | No   | Alias for  KW. Default value: default                                   |
    ...  +---------------------+------+-------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Check If Availability Status Exists  LNCEL  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-14246/LNCEL_R-23594

    [Arguments]  ${class}  ${item_id}  ${timeout}=10s  ${alias}=default

    ${parameters} =  Get Parameters For  ${class}  ${item_id}  timeout=${timeout}   connection=${alias}
    ${no_state_in_parameters} =  Run Keyword And Return Status  Dictionary Should Not Contain Key  ${parameters}  availabilityStatus
    Should Be True  ${no_state_in_parameters}  msg=AvailabilityStatus exists, but it should not (due to CNI-61110 changes).


Inter RAT Test Setup
    [Documentation]
    ...  Test setup for Inter RAT tests. Sets up both master and slave for test lines.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  Test setup for Inter RAT tests, in which 1 BTS with master and slave is used.
    ...
    ...  List of actions:
    ...    - Creates log directories, pointed to by variable ${LOG_PATH}
    ...    - Starts Admin connection under aliase 'default'
    ...    - Starts InfoModel connection under aliase 'default'
    ...    - Starts syslog collection under aliases 'default' and 'slave'
    ...    - Prints active SW version, sets them as test tag
    ...    - Checks cells and modules state and active alarms, if ${states_check} is not set to False
    ...    - Runs hanging users script (ca_INTER_RAT.Run Hanging Users Script)
    ...    - Sets up PDU for taf.pdu library as first element of 'pdus' list in 'tl'
    ...    - Sets variable ${BTSFiles} and ${BTS_Files} equal to ${LOG_PATH}, for compatibility with some ca_INTER_RAT
    ...      resources
    ...
    ...  Requires correct config file for test line. TestLine object must have properties 'test_pcs', 'enbs', 'rncs',
    ...  'bscs' and 'pdus'. It is assumed that 'test_pcs' list contains first the TestPc referring to the master VM,
    ...  then slave VM. Similarly, 'enbs' list should contain first the RealEnb object referring to the master,
    ...  and then slave.
    ...  e.g.: tl = TestLine(test_pc=_test_pc_1, test_pcs=[_test_pc_1, _test_pc_2], enbs=[_enb_sbts_1, _enb_sbts_2], pdus=[_pdu])
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------------+------+---------------------------------------------------------------------+
    ...  | Parameter            | Man. | Description                                                         |
    ...  +======================+======+=====================================================================+
    ...  | states_check         | No   | Parameter strictly for developer usage.                             |
    ...  |                      |      | If set to True, setup will check if all cells and modules are OnAir |
    ...  |                      |      | and if no unexpected alarms appear. Default is True.                |
    ...  +----------------------+------+---------------------------------------------------------------------+
    ...  | start_old_infomodel  | No   | Boolean value determining if infomodel from ute-admin-infomodel     |
    ...  |                      |      | library should be started. Default value: False.                    |
    ...  +----------------------+------+---------------------------------------------------------------------+
    ...  | bsc_exists           | No   | Boolean value determining if BSC object is defined                  |
    ...  |                      |      | in __init__.py file. Default value: True.                           |
    ...  +----------------------+------+---------------------------------------------------------------------+
    ...  | rnc_exists           | No   | Boolean value determining if RNC object is defined                  |
    ...  |                      |      | in __init__.py file. Default value: True.                           |
    ...  +----------------------+------+---------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     TC Setup
    ...         Inter RAT Test Setup

    [Timeout]    15 minutes
    [Arguments]  ${states_check}=True  ${start_old_infomodel}=False  ${bsc_exists}=True  ${rnc_exists}=True

    Log To Console  \n\n=== Inter RAT Test Setup ===

    Log Variables   level=DEBUG
    Extract Variables From Config File For Legacy TL  ${bsc_exists}  ${rnc_exists}
    ${master_user} =  Evaluate  $tl.test_pcs[0].default_ssh_connection_details.username
    ${master_password} =  Evaluate  $tl.test_pcs[0].default_ssh_connection_details.password
    ${slave_user} =  Evaluate  $tl.test_pcs[1].default_ssh_connection_details.username
    ${slave_password} =  Evaluate  $tl.test_pcs[1].default_ssh_connection_details.password
    Create Log Directories
    Log Variables   level=DEBUG


    Run Keyword And Ignore Error  core.Teardown Collectors  btslog,btslog_slave

    Setup Admin  bts_host=${SMOD1['IP']}  admin_api_log_dir=${LOG_PATH}/admin_api_logs
    ${release_master} =  Get SW Release Name  connection=default
    Teardown All Aliases For Admin
    Set Test Variable  ${RELEASE_MASTER}  ${release_master}
    Log  Release master: ${RELEASE_MASTER}  console=True

    Setup Admin  bts_host=${SMOD1['IP']}  admin_api_log_dir=${LOG_PATH}/admin_api_logs  release=${RELEASE_MASTER}
    Log To Console  Connection to ADMIN on master side started.

    Run Keyword If  ${start_old_infomodel}  Run Keywords
    ...  Setup Infomodel  address=${SMOD1['IP']}  port=443  use_ssl=True  admin_api_log_dir=${LOG_PATH}/admin_api_logs
    ...  AND  Connect Infomodel
    ...  AND  Log To Console  Connection to InfoModel on master side started.

    Start Collecting BTSLog  login=${master_user}  password=${master_password}
    Log To Console  Syslog on master side started.

    Start Collecting BTSLog  alias=btslog_slave  host_ip=${PC_IP2}  login=${slave_user}  password=${slave_password}
    Log To Console  Syslog on slave side started.

    Add Standard Allowed Alarms
    Add Allowed Alarm  faultId=181  alias=default

    Run Hanging Users Script  ${LOG_PATH}/misc_logs

    ${ENB_CNI-61110_STATUS}=  Check CNI-61110 Status
    Set Test Variable  ${ENB_CNI-61110_STATUS}
    Set Test Variable  ${CNI-61110_STATUS}  ${ENB_CNI-61110_STATUS}

    Run Keyword If  ${states_check}  Run Keywords  Log To Console  Checking BTS states and alarms...
    ...  AND  _verify bts states for iwk test helper
    ...  AND  Log To Console  BTS states verification successful. All modules and cells are OnAir, no unexpected alarms appeared.

    ${sw_info}=  Get Software Info
    Log To Console  Active SW: ${sw_info['Active SW version']}
    Set Tags  SBTS_SW-${sw_info['Active SW version']}

    ${pdu}  Evaluate  $tl.pdus[0]
    pdu.Setup PDU  ${pdu}

    Set Test Variable  ${BTSFiles}  ${LOG_PATH}
    Set Test Variable  ${BTS_Files}  ${LOG_PATH}
    Set Test Variable  ${Test_Files}  ${LOG_PATH}

    Log Variables   level=DEBUG
    Log to console  Inter RAT Test Setup finished.\n


Inter RAT Test Teardown
    [Documentation]
    ...  Test teardown for Inter RAT tests. Tears down both master and slave for test lines.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  Test teardown for Inter RAT tests, in which 1 BTS with master and slave is used.
    ...
    ...  List of actions:
    ...    - Runs hanging users script (ca_INTER_RAT.Run Hanging Users Script)
    ...    - Saves InfoModel logs from to ${LOG_PATH}/infomodel_logs
    ...    - Stops syslogs on master and slave and saves them zipped in .tar.gz to ${LOG_PATH}/udp_logs
    ...    - Saves ADMIN API logs to ${LOG_PATH}/admin_api_logs
    ...    - Collects swconfigs from master and slave and saves them to ${LOG_PATH}/swconfig
    ...    - Collects RawAlarmHistory from master and slave and saves them to ${LOG_PATH}/alarm_history
    ...    - Collects snapshots fron master and slave if test failed and ${collect_snapshot_on_test_fail}
    ...      is not set to False
    ...    - Tears down InfoModel and ADMIN connections
    ...    - Moves ute_ue logs and hanging users script logs to ${LOG_PATH}/misc_logs
    ...
    ...  **Input Parameters:**
    ...
    ...  +-------------------------------+------+--------------------------------------------------------+
    ...  | Parameter                     | Man. | Description                                            |
    ...  +===============================+======+========================================================+
    ...  | collect_snapshot_on_test_fail | No   | Parameter strictly for developer usage.                |
    ...  |                               |      | When set to False, snapshot will not be collected even |
    ...  |                               |      | when test fails. Default is True.                      |
    ...  +-------------------------------+------+--------------------------------------------------------+
    ...  | start_old_infomodel           | No   | Boolean value determining if infomodel                 |
    ...  |                               |      | from ute-admin-infomodel library should be started.    |
    ...  |                               |      | Default value: False.                                  |
    ...  +-------------------------------+------+--------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     TC Teardown
    ...         Inter RAT Test Teardown

    [Arguments]  ${collect_snapshot_on_test_fail}=True  ${stop_old_infomodel}=False

    Log To Console  \n\n=== Inter RAT Test Teardown ===

    Run Hanging Users Script  ${LOG_PATH}/misc_logs

    Run Keyword If  ${stop_old_infomodel}  Save Infomodel Log  filename=${LOG_PATH}/infomodel_logs/InfoModel_log.ims2
    # TODO: Remove 'Save Infomodel Log' after fully moving from infomodel library to admin library
    Collect Infomodel Log From Current Session  target_file_name=${LOG_PATH}/infomodel_logs/InfoModel_admin_log.ims2
    Log To Console  InfoModel log from saved.

    Stop Collecting BTSLog
    Log To Console  Syslog on master closed and saved.


    ${status}  ${msg} =  Run Keyword And Ignore Error  Stop Collecting BTSLog  alias=btslog_slave
    ${archive_is_empty} =  Run Keyword And Return Status  Should Match Regexp  ${msg}
    ...  .*Cowardly refusing to create an empty archive.*
    Run Keyword If  '${status}' == 'PASS'  Log To Console  Syslog on slave closed and saved.
    ...  ELSE IF  ('${status}' == 'FAIL' and ${archive_is_empty})  Log  Syslog on slave is empty.  level=WARN
    ...  ELSE  Fail  A problem occured during collecting logs from syslog on slave. See above logs for more details.


    ${slave_user} =  Evaluate  $tl.test_pcs[1].default_ssh_connection_details.username
    Collect swconfigs and RawAlarmHistory From Specific SMOD  ${SMOD1['IP']}  master
    ...  smod_username=${SMOD1['USERNAME']}  smod_password=${SMOD1['PASSWORD']}
    ${slave_password} =  Evaluate  $tl.test_pcs[1].default_ssh_connection_details.password
    Collect swconfigs and RawAlarmHistory From Specific SMOD  ${SMOD2['IP']}  slave
    ...  smod_username=${SMOD2['USERNAME']}  smod_password=${SMOD2['PASSWORD']}  proxy_ip=${PC_IP2}
    ...  host_username=${slave_user}  host_password=${slave_password}
    Log to console  swconfigs and RawAlarmHistory saved.

    Run Keyword If Test Failed  Run Keyword If  ${collect_snapshot_on_test_fail}  Run Keywords
    ...  Log To Console  Collecting snapshots...
    ...  Create Directory  ${LOG_PATH}/snapshots  AND
    ...  Collect Snapshot  ${LOG_PATH}/snapshots/snapshot  timeout=1h  AND
    ...  Log To Console  Snapshot collected.

    Create Directory  ${LOG_PATH}/admin_api_logs/
    Run Keyword If  ${stop_old_infomodel}  Run Keywords  Teardown All Aliases For Infomodel
    ...  AND  Log To Console  InfoModel connections closed.

    Teardown All Aliases For Admin
    Log To Console  ADMIN connections closed.

    Run  mv ${LOG_PATH}/*.log* ${LOG_PATH}/misc_logs/
    Run  mv ./hanging* ${LOG_PATH}/misc_logs/

    Log to console  Inter RAT Test Teardown finished.\n


Collect swconfigs and RawAlarmHistory From Specific SMOD
    [Documentation]
    ...  Downloads swconfig.txt and RawAlarmHistory.txt files from specified SMOD through SSH.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +-------------------------------+------+--------------------------------------------------------+
    ...  | Parameter                     | Man. | Description                                            |
    ...  +===============================+======+========================================================+
    ...  | connection_ip                 | Yes  | IP of SMOD to which connection needs to be made.       |
    ...  +-------------------------------+------+--------------------------------------------------------+
    ...  | alias                         | Yes  | Alias for connection and part of saved file names.     |
    ...  +-------------------------------+------+--------------------------------------------------------+
    ...  | smod_username                 | Yes  | Username for connecting to specific SMOD.              |
    ...  +-------------------------------+------+--------------------------------------------------------+
    ...  | smod_password                 | Yes  | Password for connecting to specific SMOD.              |
    ...  +-------------------------------+------+--------------------------------------------------------+
    ...  | proxy_ip                      | No   | Proxy for connecting to specified SMOD.                |
    ...  |                               |      | Default value: ${None}.                                |
    ...  +-------------------------------+------+--------------------------------------------------------+
    ...  | host_username                 | No   | Username for connecting to specified SMOD. Only used   |
    ...  |                               |      | if proxy_ip is defined. Default value: ute.            |
    ...  +-------------------------------+------+--------------------------------------------------------+
    ...  | host_password                 | No   | Password for connecting to specified SMOD. Only used   |
    ...  |                               |      | if proxy_ip is defined. Default value: uteUTE!.        |
    ...  +-------------------------------+------+--------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Collect swconfigs and RawAlarmHistory From Specific SMOD  ${SMOD2['IP']}  slave
    ...     ...  smod_username=${SMOD2['USERNAME']}  smod_password=${SMOD2['PASSWORD']}  proxy_ip=${PC_IP2}

    [Arguments]  ${connection_ip}  ${alias}  ${smod_username}  ${smod_password}  ${proxy_ip}=${None}  ${host_username}=ute
    ...  ${host_password}=uteUTE!

    Run Keyword If  '${proxy_ip}' != '${None}'  Run Keywords  ssh.Connect To  ${proxy_ip}  ${host_username}
    ...  ${host_password}  alias=proxy_connection
    ...  AND   ssh.Connect To  ${connection_ip}  ${smod_username}  ${smod_password}  proxy=proxy_connection  alias=${alias}
    ...  ELSE  ssh.Connect To  ${connection_ip}  ${smod_username}  ${smod_password}  alias=${alias}

    ssh.Download File  /ffs/run/swconfig.txt  ${LOG_PATH}/swconfig/swconfig_${alias}.txt  connection=${alias}

    ssh.Download File  /tmp/RawAlarmHistory.txt  ${LOG_PATH}/alarm_history/RawAlarmHistory_${alias}.txt  connection=${alias}

    [Teardown]  Run Keywords  ssh.Disconnect  connection=${alias}
    ...  AND  Run Keyword If  '${proxy_ip}' != '${None}'  ssh.Disconnect  connection=proxy_connection


Start Collecting BTSLog
    [Documentation]
    ...  KW used to start collection of BTSLog logs.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  KW used to start collection of BTSLog logs. Parameter 'host_ip' can be used to collect BTSLog
    ...  on remote VM or PC. While using this keyword BTSLog application cannot be used
    ...  otherwise collecting will fail (usually on KW 'core.Stop Collectors'). Example of error
    ...  due to BTSLog running in the background:
    ...  'ValueError: unexpected PID value observed : 22265
    ...  22266
    ...  25212
    ...  Please ensure single BTSLog collector instance at a time.
    ...  Ensure not to start or terminate BTSLog tool manually with BTSLog collector instance'
    ...
    ...  **Input Parameters:**
    ...
    ...  +--------------+------+------------------------------------------------------------------------+
    ...  | Parameter    | Man. | Description                                                            |
    ...  +==============+======+========================================================================+
    ...  | host_ip      | No   | IP of host (VM/PC) on which BTSLog should to be collected.             |
    ...  |              |      | Default is: ${None}.                                                   |
    ...  +--------------+------+------------------------------------------------------------------------+
    ...  | alias        | No   | Alias used for BTSLog. Default: btslog.                                |
    ...  +--------------+------+------------------------------------------------------------------------+
    ...  | login        | No   | Login for host (VM/PC) on which BTSLog should to be collected.         |
    ...  |              |      | Default is: ute.                                                       |
    ...  +--------------+------+------------------------------------------------------------------------+
    ...  | password     | No   | Password for host (VM/PC) on which BTSLog should to be collected.      |
    ...  |              |      | Default is: uteUTE!.                                                   |
    ...  +--------------+------+------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${slave_vm_ip} =  Evaluate  $tl.test_pcs[1].default_ssh_connection_details.addr
    ...     Start Collecting BTSLog  alias=btslog_slave  host_ip=${slave_vm_ip}

    [Arguments]  ${host_ip}=${None}  ${alias}=btslog  ${login}=ute  ${password}=uteUTE!

    _create_default_log_dir  ${host_ip}  ${login}  ${password}

    ${executor}=  Create Dictionary
    ...  host=${host_ip}
    ...  user=${login}
    ...  password=${password}

    Run Keyword If  '${host_ip}' != '${None}'  btslog.Create BTSLog Collector
    ...                         name=${alias}
    ...                         executor=${executor}
    ...  ELSE                   btslog.Create BTSLog Collector
    ...                         name=${alias}

    core.Setup Collectors    names=${alias}
    core.Start Collectors    names=${alias}
    core.Set Test Alias  ${alias}

    Log  Logs collection for BTSlog with alias=${alias} started.  console=True


_create_default_log_dir
    [Arguments]  ${host_ip}=${None}  ${login}=ute  ${password}=ute

    SSHLibrary.Open Connection  ${host_ip}
    Login  ${login}  ${password}
    Set Variable If  '${host_ip}' != '${None}'  127.0.0.1  ${host_ip}
    ${directory_exists} =  Run Keyword And Return Status  SSHLibrary.Directory Should Exist  /tmp/btslog2
    Return From Keyword If  ${directory_exists}

    ${stdout}  ${stderr}  ${rc} =  SSHLibrary.Execute Command  mkdir /tmp/btslog2  return_stderr=True  return_rc=True
    Should Be Equal As Integers  ${rc}  0    msg=RC is not equal to 0.
    Should Be Empty  ${stderr}  msg=${stderr}

    [Teardown]  SSHLibrary.Close Connection


Stop Collecting BTSLog
    [Documentation]
    ...  KW used to stop collection of BTSLog logs.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  KW used to stop collection of BTSLog logs and save it in 'log_directory'
    ...  and save it in 'log_directory'. File name will have timestamp added to it
    ...  in this KW. It returns absolute path to saved file.
    ...  While using this keyword BTSLog application cannot be used
    ...  otherwise collecting will fail (usually on KW 'core.Stop Collectors'). Example of error
    ...  due to BTSLog running in the background:
    ...  'ValueError: unexpected PID value observed : 22265
    ...  22266
    ...  25212
    ...  Please ensure single BTSLog collector instance at a time.
    ...  Ensure not to start or terminate BTSLog tool manually with BTSLog collector instance'
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+----------------------------------------+
    ...  | Parameter      | Man. | Description                            |
    ...  +================+======+========================================+
    ...  | log_directory  | No   | Directory where logs should be saved.  |
    ...  |                |      | Default is: ${LOG_PATH}/udp_logs.      |
    ...  +----------------+------+----------------------------------------+
    ...  | alias          | No   | Alias used for BTSLog. Has to be the   |
    ...  |                |      | same as the one used during start      |
    ...  |                |      | of logs collection. Default: btslog.   |
    ...  +----------------+------+----------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Stop Collecting BTSLog  alias=btslog_slave

    [Arguments]  ${log_directory}=${LOG_PATH}/udp_logs  ${alias}=btslog

    ${timestamp}  Run  date +%H-%M-%S

    core.Stop Collectors      names=${alias}
    core.Collect Collectors   names=${alias}  target_dir=${log_directory}
    core.Teardown Collectors  names=${alias}

    ${btslog_exists} =  Run Keyword And Return Status
    ...  OperatingSystem.File Should Exist  ${log_directory}/${alias}/syslog_files.tgz
    Should Be True  ${btslog_exists}
    ...  msg=BTSLog file does not exist in ${log_directory}/${alias}/syslog_files.tgz.
    Return From Keyword If  not ${btslog_exists}  ${NONE}

    Run  mv ${log_directory}/${alias}/syslog_files.tgz ${log_directory}/${alias}_${timestamp}.tgz

    Log  Logs collection for BTSLog with alias=${alias} finished.  console=True
    [Return]  ${log_directory}/${alias}_${timestamp}.tgz


Extract Variables From Config File For Legacy TL
    [Documentation]
    ...  KW used for extracting variables from config file for legacy TL.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  KW used for extracting variables from config file for legacy TL.
    ...  Variables created in this KW (and set as test variables):
    ...  BSC, RNC, PC_IP1, PC_IP2, MPLANE_IP, SMOD1, SMOD2.
    ...  BSC and RNC are only created if BSC and RNC objects respectively exist
    ...  in __init__.py. This should be set with 'bsc_exists' and 'rnc_exists' variables.
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------------+------+---------------------------------------------------------------------+
    ...  | Parameter            | Man. | Description                                                         |
    ...  +======================+======+=====================================================================+
    ...  | bsc_exists           | No   | Boolean value determining if BSC object is defined                  |
    ...  |                      |      | in __init__.py file. Default value: True.                           |
    ...  +----------------------+------+---------------------------------------------------------------------+
    ...  | rnc_exists           | No   | Boolean value determining if RNC object is defined                  |
    ...  |                      |      | in __init__.py file. Default value: True.                           |
    ...  +----------------------+------+---------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Extract Variables From Config File For Legacy TL

    [Arguments]  ${bsc_exists}=True  ${rnc_exists}=True

    ${pc_ip1} =  Evaluate  $tl.test_pcs[0].default_ssh_connection_details.addr
    ${pc_ip2} =  Evaluate  $tl.test_pcs[1].default_ssh_connection_details.addr

    Run Keyword If  ${bsc_exists}  _get bsc data helper
    Run Keyword If  ${rnc_exists}  _get rnc data helper

    ${mplane_ip} =  Evaluate  $tl.enbs[0].oam_ip.v4
    ${master_hw_type} =  Evaluate  $tl.enbs[0].system_module.common_units[0].hardware_type
    ${master_ip} =  Evaluate  $tl.enbs[0].system_module.common_units[0].lmp_connection.addr
    ${master_im_ip} =  Evaluate  $tl.enbs[0].system_module.common_units[0].lmp_connection.addr
    ${master_user} =  Evaluate  $tl.enbs[0].system_module.common_units[0].lmp_connection.username
    ${master_password} =  Evaluate  $tl.enbs[0].system_module.common_units[0].lmp_connection.password
    ${master} =  Create Dictionary  USERNAME=${master_user}  HW_TYPE=${master_hw_type}  IP=${master_ip}
    ...                          IM_IP=${master_ip}  PASSWORD=${master_password}

    ${slave_hw_type} =  Evaluate  $tl.enbs[1].system_module.common_units[0].hardware_type
    ${slave_ip} =  Evaluate  $tl.enbs[1].system_module.common_units[0].lmp_connection.addr
    ${slave_im_ip} =  Evaluate  $tl.enbs[1].system_module.common_units[0].lmp_connection.addr
    ${slave_user} =  Evaluate  $tl.enbs[1].system_module.common_units[0].lmp_connection.username
    ${slave_password} =  Evaluate  $tl.enbs[1].system_module.common_units[0].lmp_connection.password
    ${slave} =  Create Dictionary  USERNAME=${slave_user}  HW_TYPE=${slave_hw_type}  IP=${slave_ip}
    ...                          IM_IP=${slave_ip}  PASSWORD=${slave_password}


    Set Test Variable  ${PC_IP1}  ${pc_ip1}
    Set Test Variable  ${PC_IP2}  ${pc_ip2}
    Set Test Variable  ${MPLANE_IP}  ${mplane_ip}
    Set Test Variable  ${SMOD1}  ${master}
    Set Test Variable  ${SMOD2}  ${slave}


_get bsc data helper
    ${bsc_id} =  Evaluate  $tl.bscs[0].name
    ${bsc_ip} =  Evaluate  $tl.bscs[0].logging_telnet_connection_details.addr
    ${bsc_user} =  Evaluate  $tl.bscs[0].logging_telnet_connection_details.username
    ${bsc_password} =  Evaluate  $tl.bscs[0].logging_telnet_connection_details.password
    ${bsc} =  Create Dictionary  ip=${bsc_ip}  password=${bsc_password}  ID=${bsc_id}  user=${bsc_user}
    Set Test Variable  ${BSC}  ${bsc}


_get rnc data helper
    ${rnc} =  Evaluate  $tl.rncs[0]
    ${rnc_id} =  Evaluate  $tl.rncs[0].rnc_id
    ${oms_ip} =  Evaluate  $tl.rncs[0].oms_ip.v4
    ${rnc_ip} =  Evaluate  $tl.rncs[0].logging_ssh_connection_details.addr
    ${rnc_user} =  Evaluate  $tl.rncs[0].logging_ssh_connection_details.username
    ${rnc_password} =  Evaluate  $tl.rncs[0].logging_ssh_connection_details.password
    ${rnc} =  Create Dictionary  RNC_PASSWORD=${rnc_password}  OMS_IP=${oms_ip}  RNC_LOGIN=${rnc_user}
    ...                          ID=${rnc_id}  RNC_IP=${rnc_ip}
    Set Test Variable  ${RNC}  ${rnc}


Check If Cells From Specific RAT Exist In ADMIN
    [Documentation]
    ...  KW used for checking if any cells from given RAT exist in ADMIN.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+----------------------------------------------------------------------+
    ...  | Parameter      | Man. | Description                                                          |
    ...  +================+======+======================================================================+
    ...  | rat            | Yes  | Lowercase name of RAT for which cells should be checked, e.g. lte.   |
    ...  +----------------+------+----------------------------------------------------------------------+
    ...  | connection     | No   | Alias of admin connection for which cells should be checked.         |
    ...  |                |      | Default value: default.                                              |
    ...  +----------------+------+----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Check If Cells From Specific RAT Exist In ADMIN  nr

    [Arguments]  ${rat}  ${connection}=default

    ${cell_objects} =  Get Cells Info  ${rat}  connection=${connection}
    ${cells_exist} =  Run Keyword And Return Status  Should Not Be Empty  ${cell_objects}
    [Return]  ${cells_exist}


Check If Feature CB008392 Is Active
    [Documentation]
    ...  KW used for checking if feature CB008392 is active.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  KW used for checking if feature CB008392 is active.
    ...  It sets test suite variables: ENERGY_SAVING_ON (boolean value determining
    ...  if CB008392 is turned on by checking if actNrLBRTXPowerSaving=true) and
    ...  CB008392_ACTIVATION_CHECKED (boolean value determining if it was verified
    ...  whether CB008392 is active). It uses SCF for verification, which is saved under:
    ...  ${LOG_PATH}/misc_logs/feature_check_SCF_gNB.xml
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Check If Feature CB008392 Is Active

    ${nrbts_id} =  Get BTS ID From ADMIN  alias=gNB
    ${_}  ${parsed_scf_gnb}=  Save And Parse SCF  feature_check_SCF_gNB  alias=gNB
    ${energy_saving_on} =  Run Keyword And Return Status
    ...  Check Element In SCF  ${parsed_scf_gnb}  NRBTS  NRBTS-${nrbts_id}  /p[@name='actNrLBRTXPowerSaving']
    ...  <p name="actNrLBRTXPowerSaving">true</p>  dist_name_substring=True
    Run Keyword If  ${energy_saving_on}  Run Keywords  Set Suite Variable  ${ENERGY_SAVING_ON}  True
    ...  AND  Set Suite Variable  ${CB008392_ACTIVATION_CHECKED}  True
    ...  ELSE  Run Keywords  Set Suite Variable  ${ENERGY_SAVING_ON}  False
    ...  AND  Set Suite Variable  ${CB008392_ACTIVATION_CHECKED}  True
    ...  AND  Fail  msg=Energy saving feature CB008392 is not activated.


Get NR Global Cell ID From NR Cell ID
    [Documentation]
    ...  KW used to get global NR cell ID from NR cell ID.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+----------------------------------------------------------------------+
    ...  | Parameter      | Man. | Description                                                          |
    ...  +================+======+======================================================================+
    ...  | nr_cell_id     | Yes  | NR cell ID for cell for which global NR cell ID is needed.           |
    ...  +----------------+------+----------------------------------------------------------------------+
    ...  | connection     | No   | Alias of admin connection for which global cell ID will be returned. |
    ...  |                |      | Default value: gNB.                                                  |
    ...  +----------------+------+----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Get NR Global Cell ID From NR Cell ID  1

    [Arguments]  ${nr_cell_id}  ${connection}=gNB
    ${nr_cells} =  Get Parameters For All  NRCEL  connection=${connection}
    ${nr_global_id} =  Evaluate  [x['nrCellIdentity'] for x in ${nr_cells} if ${nr_cell_id} == x['configurationId']]
    [Return]  ${nr_global_id[0]}


Check Energy Saving State For NR Cell
    [Documentation]
    ...  KW used to check energy saving state for NR cell.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                          |
    ...  +========================+======+======================================================================+
    ...  | bts_id                 | Yes  | ID of MRBTS and NRBTS for cell which is checked.                     |
    ...  +------------------------+------+----------------------------------------------------------------------+
    ...  | nr_cell_id             | Yes  | NR cell ID for cell for which global NR cell ID is needed.           |
    ...  +------------------------+------+----------------------------------------------------------------------+
    ...  | expected_saving_state  | Yes  | Expected energy saving state for cell. Possible values:              |
    ...  |                        |      | reducedEnergySaving and notEnergySaving.                             |
    ...  +------------------------+------+----------------------------------------------------------------------+
    ...  | connection             | No   | Alias of admin connection for which global cell ID will be returned. |
    ...  |                        |      | Default value: gNB.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Check Energy Saving State For NR Cell  12345  1  reducedEnergySaving  gNB

    [Arguments]  ${bts_id}  ${nr_cell_id}  ${expected_saving_state}  ${connection}=gNB
    ${nr_cell1_info} =  Get Cell Specific Info  MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${nr_cell_id}  connection=${connection}
    Log  \nFor cell ${nr_cell_id}: \nCurrent energy saving state: ${nr_cell1_info['energySavingState']}.  console=True
    Log  \nExpected energy saving state: ${expected_saving_state}  console=True
    Should Be Equal As Strings  ${nr_cell1_info['energySavingState']}  ${expected_saving_state}
    ...  msg=Current energy saving state: ${nr_cell1_info['energySavingState']} is different than expected: ${expected_saving_state}



Analyze Power Group Load From Syslog For CB008392
    [Documentation]
    ...  KW used to check check power group load for CB008392 feature based on syslog prints.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  KW used to check check power group load for CB008392 feature based on syslog prints.
    ...  If keyword fails it prints 'Analyzing power group load failed - retrying...' in teardown
    ...  since in most cases it will be run multiple times, before print's time and load of power
    ...  group is correct. It checks if time for print is newer than time passed in 'start_time'
    ...  argument and fails if no newer prints appeared. Load (pg_load) is compared to specific
    ...  conditions based on value passed in 'condition' argument:
    ...  NoTpt - 0 <= pg_load < min_treshold
    ...  Lower - 0 < pg_load < min_treshold
    ...  InRange - min_treshold <= pg_load <= max_treshold
    ...  Higher - max_treshold < pg_load
    ...  InRangeORHigher - pg_load > min_treshold
    ...  If condition is not fulfilled this keyword will fail.
    ...  This keyword returns value of pgload extracted from last print.
    ...  This keyword requires DateTime robot framework library to work correctly.
    ...
    ...  **Input Parameters:**
    ...
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...  | Parameter         | Man. | Description                                                               |
    ...  +===================+======+===========================================================================+
    ...  | pwr_gr_id         | Yes  | ID of checked power group.                                                |
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...  | start_time        | Yes  | Time from which it should be checked if new prints appeared.              |
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...  | condition         | Yes  | Condition which power group load should fulfill. Possible values:         |
    ...  |                   |      | NoTpt (no data transfer is currently performed in power group and power   |
    ...  |                   |      | group load is lower than min threshold, can be equal to 0),               |
    ...  |                   |      | Lower (power group load is lower than min threshold, but should be        |
    ...  |                   |      | greater than 0),                                                          |
    ...  |                   |      | InRange (power group load is greater than min hreshold, but lower than max|
    ...  |                   |      | threshold, but lower than max threshold),                                 |
    ...  |                   |      | Higher (power group load is greater than max threshold)                   |
    ...  |                   |      | InRangeORHigher (the power group load is between the min and max          |
    ...  |                   |      | thresholds, or, greater than the max threshold ).                         |                  |
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...  | min_treshold      | No   | Min threshold for power group load. Default value: ${LBPS_RTX_MIN_LOAD}.  |
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...  | min_treshold      | No   | Max threshold for power group load. Default value: ${LBPS_RTX_MAX_LOAD}.  |
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...  | alias             | No   | Alias for syslog. Default value: gNB.                                     |
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${start_time} =  Get Time From BTS
    ...     Analyze Power Group Load From Syslog For CB008392  1  ${start_time}

    [Arguments]  ${pwr_gr_id}  ${start_time}  ${condition}  ${min_treshold}=${LBPS_RTX_MIN_LOAD}
    ...  ${max_treshold}=${LBPS_RTX_MAX_LOAD}  ${alias}=gNB

    ${syslog_msg} =  Run Keyword And Continue On Failure  Wait For Message In Syslog File
    ...  regexp=EnergySavingAlgorithm.*powerGroup\\.id:\\s${pwr_gr_id},\\spgLoad:.*  timeout=10s  alias=${alias}
    ${debug_syslog_msg} =  Run Keyword And Continue On Failure  Wait For Message In Syslog File
    ...  regexp=EnergySavingAlgorithm.*powerGroup.*  timeout=10s  alias=${alias}

    ${syslog_list} =  Split To Lines  ${syslog_msg}
    ${all_prints} =  Get Length  ${syslog_list}
    Should Be True  ${all_prints} > 0  msg=There were no prints found in syslog.

    ${current_line_time} =  Get Regexp Matches  ${syslog_list[-1]}
    ...  ^\\d+:([0-9]{2}\\.[0-9]{2}\\s[0-2][0-9]:[0-5][0-9]:[0-5][0-9]\\.[0-9]{6})  1
    ${current_time} =  Convert Date  ${current_line_time[0]}  date_format=%d.%m %H:%M:%S.%f  result_format=%d.%m %H:%M:%S
    ${difference} =  Subtract Date From Date  ${current_time}  ${start_time}
    ...  date1_format=%d.%m %H:%M:%S  date2_format=%d.%m %H:%M:%S
    Should Be True  ${difference} > 0  msg=Timestamp is not older than start time.

    ${current_line_pgload} =  Run Keyword And Continue On Failure    Get Regexp Matches  ${syslog_list[-1]}
    ...  EnergySavingAlgorithm.*powerGroup\\.id:\\s${pwr_gr_id},\\spgLoad:\\s(\\d+)  1
    Log  \nPower group load for PG${pwr_gr_id}=${current_line_pgload[0]}  console=True
    ${pg_load} =  Set Variable  ${current_line_pgload[0]}
    Run Keyword If  '${condition}' == 'NoTpt'  Should Be True  0 <= ${pg_load} < ${min_treshold}
    ...  msg=Power group load for PG${pwr_gr_id} (${pg_load}) is not lower than min treshold (${min_treshold}).
    ...  ELSE IF  '${condition}' == 'Lower'  Should Be True  0 < ${pg_load} < ${min_treshold}
    ...  msg=Power group load for PG${pwr_gr_id} (${pg_load}) is not in range (0;min treshold) (0;${min_treshold}).
    ...  ELSE IF  '${condition}' == 'InRange'  Should Be True  ${min_treshold} <= ${pg_load} <= ${max_treshold}
    ...  msg=Power group load for PG${pwr_gr_id} (${pg_load}) is not in range of <min treshold;max threshold> <${min_treshold};${max_treshold}>.
    ...  ELSE IF  '${condition}' == 'Higher'  Should Be True  ${max_treshold} < ${pg_load}
    ...  msg=Power group load for PG${pwr_gr_id} (${pg_load}) is not higher than max treshold (${max_treshold}).
    ...  ELSE IF  '${condition}' == 'InRangeORHigher'  Should Be True  ${min_treshold} < ${pg_load}
    ...  msg=Power group load for PG${pwr_gr_id} (${pg_load}) is not higher than the min treshold (${min_treshold}).
    ...  ELSE  Fail  msg=Incorrect condition.
    [Return]  ${pg_load}
    [Teardown]  Run Keyword If  '${KEYWORD_STATUS}' == 'FAIL'  Log  Analyzing power group load failed - retrying...  console=True


Get Time From BTS
    [Documentation]
    ...  KW used to get time from BTS.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  KW used to get time from BTS. As default values it uses variables from __init__.py file,
    ...  therefore it is recommended to have them filled. It runs command: date +\"${date_time_format}\"
    ...  and returns stdout. Argument 'date_time_format' has default value '%d.%m %H:%M:%S'.
    ...  If stderr is not empty or rc is different from 0, this KW will fail.
    ...  It closes current connection in teardown.
    ...
    ...  **Input Parameters:**
    ...
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...  | Parameter         | Man. | Description                                                               |
    ...  +===================+======+===========================================================================+
    ...  | host_ip           | No   | IP for BTS from which time is read. Default value:                        |
    ...  |                   |      | ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}.                         |
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...  | user              | No   | Username for BTS from which time is read. Default value:                  |
    ...  |                   |      | ${tl.gnbs[0].cu.oam_ssh_connection_details.username}.                     |
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...  | password          | No   | Password for BTS from which time is read. Default value:                  |
    ...  |                   |      | ${tl.gnbs[0].cu.oam_ssh_connection_details.password}.                     |
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...  | date_time_format  | No   | Format for date and time fetched from BTS it should follow the same       |
    ...  |                   |      | rules as 'date' command. Default value: %d.%m %H:%M:%S.                   |
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${start_time} =  Get Time From BTS

    [Arguments]  ${host_ip}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}  ${user}=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...  ${password}=${tl.gnbs[0].cu.oam_ssh_connection_details.password}  ${date_time_format}=%d.%m %H:%M:%S

    SSHLibrary.Open Connection  ${host_ip}
    Login  ${user}  ${password}
    ${stdout}  ${stderr}  ${rc} =  SSHLibrary.Execute Command  date +\"${date_time_format}\"  return_stderr=True  return_rc=True
    Should Be Equal As Integers  ${rc}  0    msg=RC is not equal to 0.
    Should Be Empty  ${stderr}  msg=${stderr}
    [Return]  ${stdout}
    [Teardown]  SSHLibrary.Close Connection



Collect 4G TTI Trace
    [Documentation]
    ...  KW used to collect LTE TTI Traces.
    ...
    ...  | **Author:** tomasz.stawowczyk@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  KW used for collecting LTE TTI Traces. KW creates TtiTraceServer4g.
    ...  It internally runs TTITraceStreamingClient.linux command in setup and closes command session at teardown.
    ...  Default path to server is '/opt/TtiTraceServer/TTITraceServer.linux'
    ...  KW creates TtiTrace4GCollector. It internally runs TTITraceStreamingClient.linux command in start and stop.
    ...  Mandatory argument is cell_id which indicates cell with ongoing call.
    ...  Optional agruments are trace_time (default 5s) it is collection time, output_path ${LOG_PATH}/trace
    ...  and enb_ip with default value '192.168.255.1'
    ...  Under output_path KW creates folder /ttitrace and inside tti_stream_cell_trace_file_cellid_UL_date.dat,
    ...  tti_stream_cell_trace_file_cellid_DL_date.dat and tti_stream_cell_trace_file_cellid_PDCCH_date.dat
    ...
    ...  **Input Parameters:**
    ...
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...  | Parameter         | Man. | Description                                                               |
    ...  +===================+======+===========================================================================+
    ...  | cell_id           | Yes  | global cell id configured in eNB for TtiTrace collection                  |
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...  | trace_time        | No   | collection time (needs to have unit), default is 5s                       |
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...  | output_path       | No   | a path where traces will be saved, default is ${LOG_PATH}/trace           |
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...  | enb_ip            | No   | eNB IP address, default value is '192.168.255.1'                          |
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Collect 4G TTI Trace  17742  10s

    [Arguments]  ${cell_id}  ${trace_time}=5s  ${output_path}=${LOG_PATH}/trace  ${enb_ip}=192.168.255.1

    ttitrace_4g.Create Ttitrace Server 4g
    ...    name=ttiserver
    ...    enb_ip=${enb_ip}
    ttitrace_4g.Create Ttitrace 4g Collector
    ...    name=ttitrace
    ...    tool=ttiserver
    ...    global_cell_id=${cell_id}
    core.Setup Collectors      names=ttitrace
    core.Start Collectors      names=ttitrace
    Sleep  ${trace_time}
    core.Stop Collectors       names=ttitrace
    core.Collect Collectors    names=ttitrace  target_dir=${output_path}
    core.Teardown Collectors   names=ttitrace


Parse 4G TTI Trace
    [Documentation]
    ...  KW used to parse LTE TTI Traces.
    ...
    ...  | **Author:** tomasz.stawowczyk@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  KW used for parsing collected LTE TTI Traces from .dat to .txt.
    ...  If ${install_decoder}=True KW installs TTI decoder under path '/opt/TtiTracer',
    ...  from url='http://files.ute.nsn-rdnet.net/builds/enb/base'
    ...  Build name is required as argument. In case of trunk, build name should strat from SBTS00.
    ...  KW can be used to parse UL or DL TTI traces, default direction is DL.
    ...  KW requires path to collected log, default path is the same as in Collect 4G TTI Trace.
    ...  KW changes name of collected trace from tti_stream_cell_trace_file_cellid_direction_date.dat
    ...  to lte_tti_direction.dat
    ...  KW creates files lte_tti_direction.txt and lte_tti_direction.txt.harq
    ...  Adjustment provided in IWK-1087 enables parsing logs collected from TDD cells (introduced argument 'duplex')
    ...
    ...  **Input Parameters:**
    ...
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...  | Parameter         | Man. | Description                                                               |
    ...  +===================+======+===========================================================================+
    ...  | sw_build          | Yes  | name of SW build for which TTI was collected                              |
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...  | direction         | No   | indicate which direction call was ongoing, default is DL,                 |
    ...  |                   |      | should be given uppercase letters DL/UL                                   |
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...  | dict_path         | No   | a path where traces are collected,                                        |
    ...  |                   |      | default is ${LOG_PATH}/trace/ttitrace                                     |
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...  | install_decoder   | No   | value True/False,                                                         |
    ...  |                   |      | if True KW installs TTI decoder under path '/opt/TtiTracer'               |
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...  | pars_name         | No   | name of TTI trace to parse                                                |
    ...  |                   |      | default is lte_tti_${direction}.dat                                       |
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...  | duplex            | No   | argument defining cell technology, should be lowercase (fdd/tdd)          |
    ...  |                   |      | default is 'fdd'                                                          |
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Parse 4G TTI Trace  SBTS00_ENB_9999_221128_000005  UL

    [Arguments]  ${sw_build}  ${direction}=DL  ${dict_path}=${LOG_PATH}/trace/ttitrace
    ...          ${install_decoder}=True  ${pars_name}=lte_tti_${direction}.dat  ${duplex}=fdd
    [Timeout]  10min

    Run Keyword If  ${install_decoder}  taf.converters.ttitracer.Install Ttitracer  version=${sw_build}  force=True
    Move File  ${dict_path}/tti_stream_*_${direction}*.dat  ${dict_path}/${pars_name}
    taf.converters.ttitracer.Create Ttitracer Converter
    ...          name=converter_1
    ...          file_path_pattern=${dict_path}/${pars_name}
    ...          duplex=${duplex}
    taf.converters.ttitracer.Setup     converter_1
    taf.converters.ttitracer.Convert   converter_1
    taf.converters.ttitracer.Teardown  converter_1


Add Configuration ID to Reporting Portal Report
    [Documentation]
    ...  KW used to add configuration ID from SCOUT to Reporting Portal report.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  KW used to add configuration ID from SCOUT to Reporting Portal report.
    ...  It requires taf.sw.scout imported with name scout and ute_reporting_portal libraries.
    ...  Accorfing to current documentation of taf.sw.scout library 'use_scout_internal_id'
    ...  should have value True for non-UTE TLs and False for UTE TLs for more details
    ...  please refer to library documentation. 'Add To Test Data' KW will only be run for TLs
    ...  that are not in UTE, this is determined by 'use_scout_internal_id' value as well.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                     |
    ...  +========================+======+=================================================================+
    ...  | scout_testline_name    | Yes  | Name of testline from SCOUT.                                    |
    ...  +------------------------+------+-----------------------------------------------------------------+
    ...  | use_scout_internal_id  | No   | Parameter for 'Request SCF' keyword from taf.sw.scout library.  |
    ...  |                        |      | Refer to the library documentation for full description.        |
    ...  +------------------------+------+-----------------------------------------------------------------+
    ...  | timeout                | No   | Timeout for 'Request SCF' keyword from taf.sw.scout library     |
    ...  |                        |      | given in seconds. Default value: 60s.                           |
    ...  +------------------------+------+-----------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Add Configuration ID to Reporting Portal Report  scout_testline_name=10_16_MRBTS-5080

    [Arguments]  ${scout_testline_name}  ${use_scout_internal_id}=True  ${timeout}=60
    scout.Setup Scout  scout_testline_name=${scout_testline_name}
    ${scout_id} =  scout.Request SCF   use_scout_internal_id=${use_scout_internal_id}
    ...  timeout=${timeout}
    Run Keyword If  ${use_scout_internal_id}  Add To Test Data  data={"tc_execution_id": "${scout_id}"}


Check Parameters For TtiSchedulingAnalysis
    [Documentation]
    ...  KW used to check parameters related with blanking in TtiSchedulingAnalysis.py.
    ...
    ...  | **Author:** tomasz.stawowczyk@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  KW used to check parameters related with blanking in eNB_SCF and gNB_SCF.
    ...  KW requires path to downloaded SCFs from gNB and eNB (lte_scf_path, nr_scf_path).
    ...  Default path are lte_scf_path = ${LOG_PATH}/misc_logs/SCF_eNB.xml and nr_scf_path = ${LOG_PATH}/misc_logs/SCF_gNB.xml.
    ...  Mandatory paramteres are lncel_id and nrcel_id, those are Global cell IDs of LTE and NR cells for which parameters will be checked.
    ...  KW returns dictionary of checked parameters, keys are listed below:
    ...  LTE:
    ...  num_blank_dl_prbs_down, num_blank_dl_prbs_up, blanked_pucch, outer_pusch_region, dl_ch_bw
    ...  NR:
    ...  nbr_of_blanked_prbs_low_edge_dl, nbr_of_blanked_prbs_low_edge_ul, nbr_of_blanked_prbs_high_edge_dl, nbr_of_blanked_prbs_high_edge_ul
    ...
    ...  **Input Parameters:**
    ...
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...  | Parameter         | Man. | Description                                                               |
    ...  +===================+======+===========================================================================+
    ...  | lncel_id          | Yes  | ID of LTE cell for which parameters will be checked (Global cell ID)      |
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...  | nrcel_id          | Yes  | ID of NR cell for which parameters will be checked (Global cell ID)       |
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...  | lte_scf_path      | No   | a path where LTE SCF is collected,                                        |
    ...  |                   |      | default is ${LOG_PATH}/misc_logs/SCF_eNB.xml                              |
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...  | nr_scf_path       | No   | a path where LTE SCF is collected,                                        |
    ...  |                   |      | default is ${LOG_PATH}/misc_logs/SCF_gNB.xml                              |
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Check Parameters For TtiSchedulingAnalysis  17742  18001

    [Arguments]  ${lncel_id}  ${nrcel_id}  ${lte_scf_path}=${LOG_PATH}/misc_logs/SCF_eNB.xml  ${nr_scf_path}=${LOG_PATH}/misc_logs/SCF_gNB.xml

    ${num_blank_dl_prbs_down}   Get Parameter Value From SCF  ${lte_scf_path}
    ...    LNCEL_FDD  LNCEL-${lncel_id}/  /p[@name='numBlankDlPrbsDown']
    ${num_blank_dl_prbs_up}     Get Parameter Value From SCF  ${lte_scf_path}
    ...    LNCEL_FDD  LNCEL-${lncel_id}/  /p[@name='numBlankDlPrbsUp']
    ${blanked_pucch}            Get Parameter Value From SCF  ${lte_scf_path}
    ...    LNCEL_FDD  LNCEL-${lncel_id}/  /p[@name='blankedPucch']
    ${outer_pusch_region}       Get Parameter Value From SCF  ${lte_scf_path}
    ...    LNCEL_FDD  LNCEL-${lncel_id}/  /p[@name='selectOuterPuschRegion']
    ${dl_ch_bw}                 Get Parameter Value From SCF  ${lte_scf_path}
    ...    LNCEL_FDD  LNCEL-${lncel_id}/  /p[@name='dlChBw']
    ${nbr_of_blanked_prbs_low_edge_dl}    Get Parameter Value From SCF  ${nr_scf_path}  NRCELL
    ...    NRCELL-${nrcel_id}  /p[@name='nbrOfBlankedPRBsLowEdgeDL']  dist_name_substring=True
    ${nbr_of_blanked_prbs_low_edge_ul}    Get Parameter Value From SCF  ${nr_scf_path}  NRCELL
    ...    NRCELL-${nrcel_id}  /p[@name='nbrOfBlankedPRBsLowEdgeUL']  dist_name_substring=True
    ${nbr_of_blanked_prbs_high_edge_dl}   Get Parameter Value From SCF  ${nr_scf_path}  NRCELL
    ...    NRCELL-${nrcel_id}  /p[@name='nbrOfBlankedPRBsHighEdgeDL']  dist_name_substring=True
    ${nbr_of_blanked_prbs_high_edge_ul}   Get Parameter Value From SCF  ${nr_scf_path}  NRCELL
    ...    NRCELL-${nrcel_id}  /p[@name='nbrOfBlankedPRBsHighEdgeUL']  dist_name_substring=True

    &{parametrs_dict}   Create Dictionary  num_blank_dl_prbs_down=${num_blank_dl_prbs_down}  num_blank_dl_prbs_up=${num_blank_dl_prbs_up}
    ...  blanked_pucch=${blanked_pucch}  outer_pusch_region=${outer_pusch_region}  dl_ch_bw=${dl_ch_bw}
    ...  nbr_of_blanked_prbs_low_edge_dl=${nbr_of_blanked_prbs_low_edge_dl}
    ...  nbr_of_blanked_prbs_low_edge_ul=${nbr_of_blanked_prbs_low_edge_ul}
    ...  nbr_of_blanked_prbs_high_edge_dl=${nbr_of_blanked_prbs_high_edge_dl}
    ...  nbr_of_blanked_prbs_high_edge_ul=${nbr_of_blanked_prbs_high_edge_ul}

    [Return]  &{parametrs_dict}


Calculate Delta Between SCFs
    [Documentation]
    ...  KW used to calculate delta between two SCFs.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  KW used to calculate delta between two SCFs. It calculates two deltas: one for path1-path2
    ...  and the other for path2-path1. It returns paths for both saved deltas. Deltas are saved under:
    ...  ${LOG_PATH}/misc_logs/${json}.json and ${LOG_PATH}/misc_logs/${json}_revert.json.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                     |
    ...  +========================+======+=================================================================+
    ...  | path1                  | Yes  | Absolute path for original SCF.                                 |
    ...  +------------------------+------+-----------------------------------------------------------------+
    ...  | path2                  | Yes  | Absolute path for modified SCF.                                 |
    ...  +------------------------+------+-----------------------------------------------------------------+
    ...  | json                   | Yes  | Name for json file. The calculation for reverting changes       |
    ...  |                        |      | will save delta with name ${json}_revert.                       |
    ...  +------------------------+------+-----------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Calculate Delta Between SCFs  ${LOG_PATH}/misc_logs/SCF_original.xml  ${LOG_PATH}/misc_logs/SCF_modified.xml
    ...     ...  NBIoT_delta

    [Arguments]  ${path1}  ${path2}  ${json}
    Calculate Delta SCF  ${path2}  ${path1}  ${LOG_PATH}/misc_logs/${json}.json
    Log  Delta saved under: ${LOG_PATH}/misc_logs/${json}.json  console=True
    Calculate Delta SCF  ${path1}  ${path2}   ${LOG_PATH}/misc_logs/${json}_revert.json
    Log  Delta saved under: ${LOG_PATH}/misc_logs/${json}_revert.json  console=True
    [Return]  ${LOG_PATH}/misc_logs/${json}.json  ${LOG_PATH}/misc_logs/${json}_revert.json


Count Measurement Period
    [Documentation]
    ...  KW used to calculate measurement period for counters.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  KW used to calculate measurement period for counters.
    ...  It gets time from BTS and counts number of seconds left until next counter period.
    ...  It is possible to add delta to the value counted by this KW with parameter 'delta'.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | ip                     | Yes  | IP used for connecting with BTS.                                      |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | counter_period         | Yes  | Absolute path for modified SCF.                                       |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | user                   | No   | Username for connecting with BTS. Default value:                      |
    ...  |                        |      | ${tl.enbs[0].system_module.common_units[0].lmp_connection.username}.  |                     |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | password               | No   | Username for connecting with BTS. Default value:                      |
    ...  |                        |      | ${tl.enbs[0].system_module.common_units[0].lmp_connection.password}.  |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | delta                  | No   | Additional value added to waiting period. Default value: 0.           |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Count Measurement Period  12.123.123.123  15

    [Arguments]  ${ip}
    ...          ${counter_period}
    ...          ${user}=${tl.enbs[0].system_module.common_units[0].lmp_connection.username}
    ...          ${password}=${tl.enbs[0].system_module.common_units[0].lmp_connection.password}
    ...          ${delta}=0

    ${current_time_on_sbts} =  Get Time From BTS  host_ip=${ip}
    ...                                           user=${user}
    ...                                           password=${password}
    ...                                           date_time_format=%M:%S
    ${minutes_now}  ${seconds_now} =  Split String  ${current_time_on_sbts}  separator=:
    ${waiting_time} =  Evaluate
    ...  ${counter_period} * 60 - ( int("${minutes_now}") % ${counter_period} * 60 + int("${seconds_now}") ) + ${delta}

    [Return]  ${waiting_time}
