*** Settings ***
Documentation  Collecting logs keywords.
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    OperatingSystem
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu
Library    taf.gnb.oam.coam.cu.interface.cu      WITH NAME    cu
Library    taf.transport.ssh    WITH NAME    tafssh

Resource    ./common_resources.robot
Resource    ./vdu_oam_operations.robot
Resource    ./vcu_oam_operations.robot
Resource    ./fhgw_operations.robot

*** Keywords ***
vDU Collect Snapshot
    [Arguments]  ${logs_dir_path}  ${compressed_or_not}=True
    [Documentation]
    ...  Description:
    ...  Keyword gets vDU snapshot files.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | logs_dir_path          | Yes  | Path to the directory where vDU snapshot log files should be stored.       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | compressed_or_not      |  No  | Compress or not all files to one zip file.                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${vdu_snapshot_dir}=  Set Variable  ${logs_dir_path}/vdu_snapshot
    Create Directory  path=${vdu_snapshot_dir}
    vDU Rest Login
    Run Keyword And Ignore Error  vdu.Get Local Snapshot  directory=${vdu_snapshot_dir}
    ...  compressed_or_not=${compressed_or_not}
    [Teardown]  Run Keyword And Ignore Error  vDU Rest Logout

vCU Collect Snapshot
    [Arguments]  ${logs_dir_path}  ${compressed_or_not}=True
    [Documentation]
    ...  Description:
    ...  Keyword gets vDU snapshot files.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | logs_dir_path          | Yes  | Path to the directory where vCU snapshot log files should be stored.       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | compressed_or_not      |  No  | Compress or not all files to one zip file.                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    vCU Rest Login
    ${vcu_snapshot_dir}=  Set Variable  ${logs_dir_path}/vcu_snapshot
    Create Directory  path=${vcu_snapshot_dir}
    Run Keyword And Ignore Error  cu.Get Local Snapshot  directory=${vcu_snapshot_dir}
    ...  compressed=${compressed_or_not}
    [Teardown]  Run Keyword And Ignore Error  vCU Rest Logout

Collect Snapshot
    [Arguments]  ${logs_dir_path}  ${compressed_or_not}=True
    [Documentation]
    ...  Description:
    ...  Keyword gets vDU and vCU snapshot files.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | logs_dir_path          | Yes  | Path to the directory where snapshot log files should be stored.           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | compressed_or_not      |  No  | Compress or not all files to one zip file.                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Run Keyword And Ignore Error  vDU Collect Snapshot
    ...  logs_dir_path=${logs_dir_path}  compressed_or_not=${compressed_or_not}
    Run Keyword And Ignore Error  vCU Collect Snapshot
    ...  logs_dir_path=${logs_dir_path}  compressed_or_not=${compressed_or_not}

# FHGW Collect Snapshot
FHGW Collect Snapshot
    [Arguments]  ${logs_dir_path}  ${timeout}=10  ${alias}=default
    [Documentation]
    ...  Description:
    ...  Keyword gets snapshot files from all FHGWs.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | logs_dir_path          | Yes  | Path to the directory where FHGW snapshot log files should be stored.      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Timeout (in minutes) for the FHGW collection operation.                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alias                  |  No  | Alias of ssh connection.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${fhgw_numbers}=  Get FHGW Number From Init File
    Set Log Level  level=ERROR
    FOR   ${fhgw_index}  IN RANGE  ${fhgw_numbers}
      Connect to FHGW  fhgw_index=${fhgw_index}  alias=${alias}
      ${cmd_result}=  issh.Execute  command=fhgwcli snapshot save  alias=${alias}  check_result=False
      ${file_name}=  Get Regexp Matches  string=${cmd_result}  pattern=Snapshot_FHGW-\\d+.+
      ${file_name}=  Set Variable  ${file_name}[0]
      ${file_name}=  Remove String  ${file_name}  \r
      ${fhgw_check_cmd}=  Set Variable  ls /mnt/symptomreport/ | grep ${file_name}
      FOR  ${time}  IN RANGE  ${timeout}
        ${cmd_result}=  issh.Execute  command=${fhgw_check_cmd}  alias=${alias}  check_result=False
        ${is_not_running}=  Run Keyword And Return Status
        ...  Should Not Contain  container=${cmd_result}  item=running
        Exit For Loop If  ${is_not_running}
        Sleep  1m
      END
      ${fhgw_snapshot_dir}=  Set Variable  ${logs_dir_path}/fhgw_${fhgw_index}_snapshot
      Create Directory  path=${fhgw_snapshot_dir}
      ${fhgw_local_file_path}=  Set Variable  ${fhgw_snapshot_dir}/${file_name}.tar
      ${fhgw_remote_file_path}=  Set Variable  /mnt/symptomreport/${file_name}.tar
      issh.Download File  remote_path=${fhgw_remote_file_path}
      ...  local_path=${fhgw_local_file_path}  alias=${alias}
    END
    Set Log Level  level=INFO
    [Teardown]  issh.Disconnect  alias=${alias}

#vDU Collect Container Logs
vDU Get Container Logs On All Pods
    [Arguments]  ${logs_dir_path}  ${gnb_index}=0  ${vdu_index}=0  ${alias}=default
    [Documentation]
    ...  Description:
    ...  Keyword gets vDU container logs from all pods.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | logs_dir_path          | Yes  | Path to the directory where log files should be stored.                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alias                  |  No  | Alias of ssh connection.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${vdu_pods_dir}=  Set Variable  ${logs_dir_path}/vdu_pod_logs
    Create Directory  path=${vdu_pods_dir}
    Connect To vDU K8s Master Node With Tenant  gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${alias}
    ${ns}=  Get vDU Namespace From Init File  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${remote_logs_dir}=  Set Variable  /tmp/tmp_${ns}
    tafssh.Execute  command=sudo mkdir -p ${remote_logs_dir}  connection=${alias}
    tafssh.Execute  command=sudo chmod -R 777 ${remote_logs_dir}  connection=${alias}
    vDU Get Pods For Namespace  ns=${ns}  local_dir=${vdu_pods_dir}  remote_dir=${remote_logs_dir}
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  connection=${alias}

vDU Get Pods For Namespace
    [Arguments]  ${ns}  ${local_dir}  ${remote_dir}  ${alias}=default
    [Documentation]
    ...  Description:
    ...  Keyword gets vDU container logs from all pods.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | ns                     | Yes  | vDU namespace.                                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | local_dir              | Yes  | Path to the directory on local host where log files should be stored.      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | remote_dir             | Yes  | Path to the directory on remote host where log files should be stored.     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alias                  |  No  | Alias of ssh connection.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${cmd_result}=  tafssh.Execute
    ...  command=kubectl get pod -n ${ns} | awk '{print $1}' | grep -v NAME
    ...  connection=${alias}
    ${vdu_pod_list}=  Split To Lines  string=${cmd_result}  start=1  end=-1
    FOR  ${vdu_pod}  IN  @{vdu_pod_list}
      Log  ${vdu_pod}  console=False
      Run Keyword If  'po-' in '${vdu_pod}' or 'ute-' in '${vdu_pod}'
      ...  vDU Get Logs For One Pod  ns=${ns}  pod=${vdu_pod}   alias=${alias}
      ...  local_dir=${local_dir}  remote_dir=${remote_dir}
    END

vDU Get Logs For One Pod
    [Arguments]  ${ns}  ${pod}  ${local_dir}  ${remote_dir}  ${alias}=default
    [Documentation]
    ...  Description:
    ...  Keyword gets vDU container logs from all pods.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | ns                     | Yes  | vCU namespace.                                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | pod                    | Yes  | Name of vDU pod.                                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | local_dir              | Yes  | Path to the directory on local host where log files should be stored.      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | remote_dir             | Yes  | Path to the directory on remote host where log files should be stored.     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alias                  |  No  | Alias of ssh connection.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${pod_file_name}=  Set Variable  ${ns}_${pod}_kubectl_logs.log
    ${local_file_path}=  Set Variable  ${local_dir}/${pod_file_name}
    ${remote_file_path}=  Set Variable  ${remote_dir}/${pod_file_name}
    ${cmd_result}=  tafssh.Execute
    ...  command=kubectl logs ${pod} -n ${ns} --all-containers > /tmp/tmp_${ns}/${pod_file_name}
    ...  connection=${alias}
    ${cmd_result}=  tafssh.Execute  command=sync  connection=${alias}
    ${cmd_result}=  tafssh.Download File  remote_path=${remote_file_path}  local_path=${local_file_path}
    ...  connection=${alias}

#vCU Collect Container Logs
vCU Get Container Logs On All Pods
    [Arguments]  ${logs_dir_path}  ${gnb_index}=0  ${alias}=default
    [Documentation]
    ...  Description:
    ...  Keyword gets vCU container logs from all pods.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | logs_dir_path          | Yes  | Path to the directory where log files should be stored.                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alias                  |  No  | Alias of ssh connection.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${vcu_pods_dir}=  Set Variable  ${logs_dir_path}/vcu_pod_logs
    Create Directory  path=${vcu_pods_dir}
    Connect To vCU K8s Master Node With Tenant  gnb_index=${gnb_index}  alias=${alias}  timeout=60
    ${ns}=  Get vCU Namespace From Init File  gnb_index=${gnb_index}
    ${remote_logs_dir}=  Set Variable  /tmp/tmp_${ns}
    tafssh.Execute  command=sudo mkdir -p ${remote_logs_dir}  connection=${alias}
    tafssh.Execute  command=sudo chmod -R 777 ${remote_logs_dir}  connection=${alias}
    vCU Get Pods For Namespace  ns=${ns}  local_dir=${vcu_pods_dir}  remote_dir=${remote_logs_dir}
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  connection=${alias}

vCU Get Pods For Namespace
    [Arguments]  ${ns}  ${local_dir}  ${remote_dir}  ${alias}=default
    [Documentation]
    ...  Description:
    ...  Keyword gets vCU container logs from all pods.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | ns                     | Yes  | vCU namespace.                                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | local_dir              | Yes  | Path to the directory on local host where log files should be stored.      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | remote_dir             | Yes  | Path to the directory on remote host where log files should be stored.     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alias                  |  No  | Alias of ssh connection.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${cmd_result}=  tafssh.Execute
    ...  command=kubectl get pod -n ${ns} | awk '{print $1}' | grep -v NAME  connection=${alias}
    ${vcu_pod_list}=  Split To Lines  string=${cmd_result}
    FOR  ${vcu_pod}  IN  @{vcu_pod_list}
      Log  ${vcu_pod}  console=False
      Run Keyword If  'po-' in '${vcu_pod}' or 'ute-' in '${vcu_pod}'
      ...  vCU Get Logs For One Pod  ns=${ns}  pod=${vcu_pod}   alias=${alias}
      ...  local_dir=${local_dir}  remote_dir=${remote_dir}
    END

vCU Get Logs For One Pod
    [Arguments]  ${ns}  ${pod}  ${local_dir}  ${remote_dir}  ${alias}=default
    [Documentation]
    ...  Description:
    ...  Keyword gets vCU container logs from all pods.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | ns                     | Yes  | vCU namespace.                                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | pod                    | Yes  | Name of vCU pod.                                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | local_dir              | Yes  | Path to the directory on local host where log files should be stored.      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | remote_dir             | Yes  | Path to the directory on remote host where log files should be stored.     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alias                  |  No  | Alias of ssh connection.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${pod_file_name}=  Set Variable  ${ns}_${pod}_kubectl_logs.log
    ${local_file_path}=  Set Variable  ${local_dir}/${pod_file_name}
    ${remote_file_path}=  Set Variable  ${remote_dir}/${pod_file_name}
    ${cmd_result}=  tafssh.Execute
    ...  command=kubectl logs ${pod} -n ${ns} --all-containers=true > /tmp/tmp_${ns}/${pod_file_name}  connection=${alias}
    ${cmd_result}=  tafssh.Execute  command=sync  connection=${alias}
    ${cmd_result}=  tafssh.Download File  remote_path=${remote_file_path}  local_path=${local_file_path}  connection=${alias}

# FHGW Collect Snapshot
#FHGW Collect Snapshot
#    [Arguments]  ${logs_dir_path}  ${timeout}=600  ${alias}=default
#    [Documentation]
#    ...  Description:
#    ...  Keyword gets snapshot files from all FHGWs.
#    ...
#    ...  Arguments:
#    ...  +========================+======+============================================================================+
#    ...  | Argument               | Man. | Description                                                                |
#    ...  +========================+======+============================================================================+
#    ...  | logs_dir_path          | Yes  | Path to the directory where FHGW snapshot log files should be stored.      |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  | timeout                |  No  | Timeout (in seconds) for the FHGW collection operation.                    |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  | alias                  |  No  | Alias of ssh connection.                                                   |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...
#    ...  Author: slawomir.jastrzebski@nokia.com
#    ...  Maintainer: slawomir.jastrzebski@nokia.com
#
#    ${fhgw_numbers}=  Get FHGW Number From Init File
#    Set Log Level  level=ERROR
#    FOR   ${fhgw_index}  IN RANGE  ${fhgw_numbers}
#      ${fhgw_snapshot_dir}=  Set Variable  ${logs_dir_path}/fhgw_${fhgw_index}_snapshot
#      Connect to FHGW  fhgw_index=${fhgw_index}  alias=${alias}
#      ${report_name}=  issh.Fhgw Trigger Symptomreport  alias=${alias}
#      ${report_status}=  issh.Fhgw Check Symptomreport Status  report_name=${report_name}  alias=${alias}
#      FOR  ${time}  IN RANGE  0  ${timeout}  10
#        ${report_status}=  issh.Fhgw Check Symptomreport Status  report_name=${report_name}  alias=${alias}
#        Exit For Loop If  '${report_status}'!='RUNNING'
#        Sleep  10
#      END
#      issh.Fhgw Download Symptomreport  report_name=${report_name}  download_path=${fhgw_snapshot_dir}  alias=${alias}
#    END
#    Set Log Level  level=INFO
#    [Teardown]  issh.Disconnect  alias=${alias}
