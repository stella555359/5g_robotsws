*** Settings ***
Documentation  Collecting various logs
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    String
Library    OperatingSystem
Library    Collections
Library    ute_admin_infomodel
Library    taf.sbts.oam.coam.admin    WITH NAME    admin
Library    taf.sw.syslog    WITH NAME    syslog

*** Variables ***
${egate_log_files_path}=  /opt/iphy/latest

*** Keywords ***
Create Folders
    [Documentation]
    ...  Description:
    ...  Keyword creates folders where logs and additional files generated during the test will be saved.
    ...  The folder paths are defined in the "variables.robot" file.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Create Directory  path=${remaining_logs}
    Create Directory  path=${general_files}
    Create Directory  path=${backup_files}
    Create Directory  path=${temp_files}

Set Folder Variables
    [Documentation]
    ...  Description:
    ...  Keyword sets suite variables that refer to the folders path.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Set Suite Variable  ${REMAINING_PATH}  ${remaining_logs}
    Set Suite Variable  ${GENERAL_PATH}  ${general_files}
    Set Suite Variable  ${BACKUP_PATH}  ${backup_files}
    Set Suite Variable  ${TEMP_PATH}  ${temp_files}

Create Logs And Files Folders
    [Documentation]
    ...  Description:
    ...  Keyword creates folders where logs and additional files generated during the test will be saved.
    ...  The folder paths are defined in the "sbts_variables.robot" file.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Create Directory  path=${REMAINING_LOGS_PATH}
    Create Directory  path=${GENERAL_FILES_PATH}
    Create Directory  path=${BACKUP_FILES_PATH}

Start Syslog For All CUS
    [Arguments]  ${list_of_cus_ips}  ${logs_dir_path}  ${file_name}=syslog
    [Documentation]
    ...  Description:
    ...  Keyword starts collecting syslog for all CUS controllers.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | list_of_cus_ips        | Yes  | List of CUS IP addresses where service should listen.                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | logs_dir_path          | Yes  | Path to directory where syslog file should be stored.                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | file_name              | Yes  | Syslog file name.                                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    FOR  ${cus_ip}  IN  @{list_of_cus_ips}
      ${cus_number}=  Fetch From Right  string=${cus_ip}  marker=.
      ${syslog_ip_last_octet}=  Evaluate  125+${cus_number}
      ${syslog_port}=  Evaluate  51600+${cus_number}
      Start CUS Syslog
      ...  syslog_ip=192.168.200.${syslog_ip_last_octet}
      ...  logs_dir_path=${logs_dir_path}
      ...  file_name=${file_name}
      ...  ports=${syslog_port}
      ...  alias=CUS${cus_number}
    END

Start CUS Syslog
    [Arguments]  ${syslog_ip}  ${logs_dir_path}  ${file_name}  ${ports}=51601  ${alias}=CUS1
    [Documentation]
    ...  Description:
    ...  Keyword starts collecting syslog for CUS controller.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | syslog_ip              | Yes  | IP address where service should listen e.g. 192.168.200.126.               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | logs_dir_path          | Yes  | Path to directory where syslog file should be stored.                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | file_name              | Yes  | Syslog file name.                                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | ports                  | Yes  | Single or list of ports which will be used to collect syslog data.         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alias                  | Yes  | Name of syslog alias.                                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    syslog.Start Syslog
    ...  log_dir=${logs_dir_path}
    ...  log_name=${alias}_${file_name}.log
    ...  ip=${syslog_ip}
    ...  ports=${ports}
    ...  alias=${alias}

Start eNB Syslog
    [Arguments]  ${logs_dir_path}  ${temp_dir}=/tmp  ${file_name}=ENB_syslog  ${alias}=default
    [Documentation]
    ...  Description:
    ...  Keyword starts collecting syslog for eNB.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | logs_dir_path          | Yes  | Path to directory where syslog files should be stored.                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | temp_dir               | Yes  | Path to directory where syslog files should be temporarily stored.         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | file_name              | Yes  | Syslog file name.                                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alias                  | Yes  | Name of syslog alias.                                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    syslog.Start Syslog
    ...  log_dir=${logs_dir_path}
    ...  log_name=${file_name}.log
    ...  ip=192.168.255.126
#    ...  file_limit=1000000000
	...  temp_dir=${temp_dir}
    ...  alias=${alias}

Capture Syslog Savepoint
    [Arguments]  ${alias}=default
    [Documentation]
    ...  Description:
    ...  Keyword captures the current timestamp on currently processing syslog.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | alias                  | Yes  | Name of syslog alias.                                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${current_savepoint}=  syslog.Capture Savepoint
    ...  alias=${alias}
    Should Not Be Empty  ${current_savepoint}
    [Return]  ${current_savepoint}

Capture Enb Syslog Savepoint
    [Arguments]  ${alias}=default
    [Documentation]
    ...  Description:
    ...  Keyword captures the current timestamp on currently processing syslog for eNB.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | alias                  | Yes  | Name of syslog alias.                                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${savepoint_enb}=  Set Variable
    ${savepoint_enb}=  Run Keyword And Ignore Error
    ...  Wait Until Keyword Succeeds  10  1
    ...  Capture Syslog Savepoint
    ...  alias=${alias}
    [Return]  ${savepoint_enb[1]}

Capture CUS Syslog Savepoint
    [Arguments]  ${list_of_cus_ips}
    [Documentation]
    ...  Description:
    ...  Keyword captures the current timestamp on currently processing syslog for all CUS controllers.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | list_of_cus_ips        | Yes  | List of CUS IP addresses.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${savepoint_dict}=  Create Dictionary
    FOR  ${cus_ip}  IN  @{list_of_cus_ips}
      ${cus_number}=  Fetch From Right  string=${cus_ip}  marker=.
      ${savepoint_cus}=  Run Keyword And Ignore Error
      ...  Wait Until Keyword Succeeds  120  10
      ...  Capture Syslog Savepoint
      ...  alias=CUS${cus_number}
      Set To Dictionary  ${savepoint_dict}  CUS${cus_number}  ${savepoint_cus[1]}
    END
    [Return]  ${savepoint_dict}

Collect Enb Syslog From Savepoint
    [Arguments]  ${savepoint_enb}  ${logs_dir_path}  ${file_name}=ENB_syslog  ${alias}=default
    [Documentation]
    ...  Description:
    ...  Keyword collects logs starting from savepoint until the current saved logs for eNB
    ...  and compress collected logs.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | savepoint_enb          | Yes  | Timestamp that will indicate where to start collect Enb logs.              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | logs_dir_path          | Yes  | Path to directory where syslog file should be stored.                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | file_name              | Yes  | Syslog file name.                                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alias                  | Yes  | Name of syslog alias.                                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

	syslog.Collect From Savepoint
	...  savepoint=${savepoint_enb}
	...  destination_file=${logs_dir_path}/${file_name}.log
#	...  file_limit=1000000000
	...  alias=${alias}
    Run  tar --remove-files -zvcf '${logs_dir_path}'/${file_name}.log.tar.gz '${logs_dir_path}'/${file_name}.log*

Collect CUS Syslog From Savepoint
    [Arguments]  ${savepoint_dict}  ${logs_dir_path}  ${list_of_cus_ips}  ${file_name}=syslog
    [Documentation]
    ...  Description:
    ...  Keyword collects logs starting from savepoint until the current saved logs for all CUS controllers
    ...  and compress collected logs.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | savepoint_dict         | Yes  | Timestamp that will indicate where to start collect CUS logs.              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | logs_dir_path          | Yes  | Path to directory where syslog file should be stored.                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | list_of_cus_ips        | Yes  | List of CUS IP addresses.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | file_name              | Yes  | Syslog file name.                                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    FOR  ${cus_ip}  IN  @{list_of_cus_ips}
      ${cus_number}=  Fetch From Right  string=${cus_ip}  marker=.
      syslog.Collect From Savepoint
      ...  savepoint=${savepoint_dict['CUS${cus_number}']}
      ...  destination_file=${logs_dir_path}/CUS${cus_number}_${file_name}.log
      ...  alias=CUS${cus_number}
      ${syslog_filename}=  Set Variable  ${logs_dir_path}/CUS${cus_number}_${file_name}
      Run  tar --remove-files -zvcf '${syslog_filename}.log.tar.gz' '${syslog_filename}.log'
    END

Collect And Capture Enb Syslog
    [Arguments]  ${savepoint_enb}  ${logs_dir_path}  ${alias}=default
    [Documentation]
    ...  Description:
    ...  Keyword collects logs starting from savepoint until the current saved logs
    ...  for Enb and captures new timestamp.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | savepoint_enb          | Yes  | Timestamp that will indicate where to start collect Enb logs.              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | logs_dir_path          | Yes  | Path to directory where syslog file should be stored.                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Collect Enb Syslog From Savepoint
    ...  savepoint_enb=${savepoint_enb}
    ...  logs_dir_path=${logs_dir_path}
    ...  alias=${alias}
    ${new_savepoint_enb}=  Capture Enb Syslog Savepoint
    [Return]  ${new_savepoint_enb}

Collect And Capture CUS Syslog
    [Arguments]  ${savepoint_cus}  ${logs_dir_path}  ${list_of_cus_ips}
    [Documentation]
    ...  Description:
    ...  Keyword collects logs starting from savepoint until the current saved logs
    ...  for all CUS controllers and captures new timestamp.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | savepoint_cus          | Yes  | Timestamp that will indicate where to start collect CUS logs.              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | logs_dir_path          | Yes  | Path to directory where syslog file should be stored.                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | list_of_cus_ips        | Yes  | List of CUS IP addresses.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Collect CUS Syslog From Savepoint  savepoint_dict=${savepoint_cus}
    ...  logs_dir_path=${logs_dir_path}  list_of_cus_ips=${list_of_cus_ips}
    ${new_savepoint_cus}=  Capture CUS Syslog Savepoint  list_of_cus_ips=${list_of_cus_ips}
    [Return]  ${new_savepoint_cus}

Stop Enb Syslog
    [Arguments]  ${logs_dir_path}  ${file_name}=ENB_syslog  ${alias}=default
    [Documentation]
    ...  Description:
    ...  Keyword stops syslog and download the created file to the destination path for eNB.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | logs_dir_path          | Yes  | Path to directory where syslog file should be stored.                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | file_name              | Yes  | Syslog file name.                                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alias                  | Yes  | Name of syslog alias.                                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

	syslog.Collect Syslog Results
	...  destination=${logs_dir_path}/${file_name}.log.tar.gz
	...  unzip=false
	...  alias=${alias}

Stop CUS Syslog
    [Arguments]  ${list_of_cus_ips}  ${logs_dir_path}  ${file_name}=syslog
    [Documentation]
    ...  Keyword stops syslog and download the created file to the destination path for all CUS controllers.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | list_of_cus_ips        | Yes  | List of CUS IP addresses.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | logs_dir_path          | Yes  | Path to directory where syslog file should be stored.                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | file_name              | Yes  | Syslog file name.                                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com
	FOR  ${cus_ip}  IN  @{list_of_cus_ips}
      ${cus_number}=  Fetch From Right  string=${cus_ip}  marker=.
	  syslog.Collect Syslog Results  destination=${logs_dir_path}/CUS${cus_number}_${file_name}.log.tar.gz
	  ...  unzip=false  alias=CUS${cus_number}
    END

Collect Tgr Logs
    [Arguments]  ${logs_dir_path}
    [Documentation]
    ...  Description:
    ...  Keyword saves logs from all TRGs.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | logs_dir_path          | Yes  | Path to directory where TGR logs should be stored.                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Run  tar -czvf ${logs_dir_path}/erl_logs.tar.gz /opt/tgr_*/var/log/erl_crash.dump 2> /dev/null
    Run  tar -czvf ${logs_dir_path}/etgr_logs.tar.gz /opt/tgr_*/var/log/etgr-*.log 2> /dev/null

Collect Egate Logs
    [Arguments]  ${logs_dir_path}
    [Documentation]
    ...  Description:
    ...  Keyword collects egate logs in one compressed file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | logs_dir_path          | Yes  | Path to directory where eagte logs should be stored.                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Create Directory  path=${egate_log_files_path}/egate_logs
    Copy Files  ${egate_log_files_path}/*.log*  ${egate_log_files_path}/egate_logs
    Remove Files  ${egate_log_files_path}/egate_logs/stdout_*.log
    Run  tar -zvcf '${logs_dir_path}/egate.tar.gz' ${egate_log_files_path}/egate_logs
    Remove Directory  path=${egate_log_files_path}/egate_logs  recursive=True

Collect CUS Startup Log
    [Arguments]  ${logs_dir_path}  ${list_of_cus_ips}
    [Documentation]
    ...  Description:
    ...  Keyword downloads startup_DEFAULT.log from all CUS and save it
    ...  to the file startup_DEFAULT_xxx.xxx.xxx.xxx.log.xz'
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | logs_dir_path          | Yes  | Path to directory where startup file should be stored.                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | list_of_cus_ips        | Yes  | List of CUS IP addresses.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com
    FOR  ${cus_ip}  IN  @{list_of_cus_ips}
      Run  scp ${cus_ip}:/tmp/startup_DEFAULT.lo* '${logs_dir_path}/startup_DEFAULT_${cus_ip}.log.xz'
    END

Collect CUS2 Mplane Log
    [Arguments]  ${logs_dir_path}
    [Documentation]
    ...  Description:
    ...  Keyword collect mplane logs in case CUS2.0 version is used
    ...  and move files to target location
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | logs_dir_path          | Yes  | Path to directory where startup file should be stored.                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: jakub.pachana@nokia.com
    ...  Maintainer: jakub.pachana@nokia.com

    ${cus_version}=  Run Executor Command  version
    ${cus2}=  Run Keyword And Return Status
    ...  Should Match Regexp  ${cus_version}[0]  .*CUS_2\.0.*
    Return From Keyword If  not ${cus2}
    Run Executor Command  mplane log collect ctrl-all
    Sleep  200s  Wait for logs collection
    Run  mv /home/cus/logs/MPLANE_CTRL_*.tar.xz "${logs_dir_path}"

Collect SOAP Logs
    [Arguments]  ${logs_dir_path}  ${list_of_cus_ips}
    [Documentation]
    ...  Description:
    ...  Keyword downloads SOAP RMOD logs from all CUS and copies them to the test log directory.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | logs_dir_path          | Yes  | Path to directory where SOAP files should be stored.                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | list_of_cus_ips        | Yes  | List of CUS IP addresses.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    FOR  ${cus_ip}  IN  @{list_of_cus_ips}
      Run  scp ${cus_ip}:/tmp/SOAPMessages* '${logs_dir_path}/'
    END

Collect Snapshot File
    [Arguments]  ${logs_dir_path}  ${file_name}=snapshot.zip
    [Documentation]
    ...  Description:
    ...  Keyword collects Enb snapshot file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | logs_dir_path          | Yes  | Path to directory where snapshot file should be stored.                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | file_name              |  No  | Snapshot file name.                                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${snapshot_result}=  Run Keyword And Return Status
    ...  admin.Collect Snapshot  target_file_name=${logs_dir_path}/${file_name}  timeout=720
    Run Keyword If  not ${snapshot_result}  Log  Snapshot could not be saved!  ERROR  console=True

Info Model Save Logs And Teardown
    [Arguments]  ${logs_dir_path}  ${alias}=default
    [Documentation]
    ...  Description:
    ...  Keyword saves InfoModel log in ims2 format, disconnects from InfoModel and releases used resources.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | logs_dir_path          | Yes  | Path to directory where ims2 file should be stored.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alias                  |  No  | Name of execution alias (context).                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Save Infomodel Log  filename=${logs_dir_path}/IM_infomodel.ims2  timeout=240  alias=${alias}
    Disconnect Infomodel  alias=${alias}
    [Teardown]  Teardown Infomodel  alias=${alias}

Perform Reconnect InfoModel
    [Documentation]
    ...  Description:
    ...  Teardown InfoModel, setup and connect to InfoModel.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Teardown Infomodel
    Setup Infomodel  address=${ENB_IP_ADDR}  port=443
    Connect Infomodel  timeout=180
