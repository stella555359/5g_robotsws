*** Settings ***
Documentation
    ...  Checks whether ROTTA is mounted on the VM; if not, it will be mounted.
    ...  TC compares latest PM raw XML from BTS with baseline reference stored on NEW ROTTA volume (RAN_VRF).
    ...  If comparison is OK, TC updates the baseline on ROTTA (backup is created).

Resource  ../../common_resources/ca_PM_general.robot
Library   ../../common_resources/python_resources/PM/check_PM_reports.py


*** Variables ***
${REPORTING_INTERVAL}  15min
${WAIT_AFTER_CYCLE}  1min

${ROTTA_MOUNT_PATH}  /media/ROTTA_RAN_VRF

# path to xml file, eg:  __TSR__/VRF_TSR1/PM/SW_BUILD/Initial_PM_Report.xml
${ROTTA_BASELINE_RELATIVE_PATH}  ${EMPTY}


*** Keywords ***
TC__PM__Raw_File_Validation_After_Software_Upgrade
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-30514
    ...
    ...  *******************
    ...  History of changes
    ...  - 13.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30514 - Initial TAT Creation

    Set Tags  CA-PM  OWNER-mohamad.al_hamwi@nokia.com  MAINTAINER-ana.adam@nokia.com  GROUP_IN_CHARGE-TIM_1_Vrf  PHASE-CRT

    Step0: Precondition
    Step1: Get ROTTA Baseline Locally
    Step2: Download Latest PM XML From BTS
    Step3: Compare PM Files With Python
    Step4: Update ROTTA Baseline


Step0: Precondition
    Log  \nStep0: Precondition  console=true

    Should Not Be Empty  ${ROTTA_BASELINE_RELATIVE_PATH}

    ${is_rotta_mounted}  Is Rotta Mounted  ${ROTTA_MOUNT_PATH}
    IF  not ${is_rotta_mounted}
        Log  ROTTA not mounted. Mounting NEW ROTTA (RAN_VRF).  console=true
        Map New Rotta RAN_VRF  ${ROTTA_MOUNT_PATH}
    ELSE
        Log  ROTTA already mounted at ${ROTTA_MOUNT_PATH}.  console=true
    END

    Set Test Variable  ${ROTTA_BASELINE_FULL_PATH}  ${ROTTA_MOUNT_PATH}/${ROTTA_BASELINE_RELATIVE_PATH}
    OperatingSystem.File Should Exist  ${ROTTA_BASELINE_FULL_PATH}
    ...  msg=Baseline file not found on ROTTA: ${ROTTA_BASELINE_FULL_PATH}
    Log  Using baseline: ${ROTTA_BASELINE_FULL_PATH}  console=true


Step1: Get ROTTA Baseline Locally
    Log  \nStep1: Get ROTTA baseline locally  console=true

    Set Test Variable  ${LOCAL_BASELINE_WORK_DIR}  ${BTS_FILES}/rotta_baseline
    Set Test Variable  ${LOCAL_PM_DIFF_REPORT}  ${BTS_FILES}/PM_Raw_Differences_After_Upgrade.txt

    OperatingSystem.Remove Directory  ${LOCAL_BASELINE_WORK_DIR}  recursive=True
    OperatingSystem.Create Directory  ${LOCAL_BASELINE_WORK_DIR}

    ${baseline_filename}  Fetch From Right  ${ROTTA_BASELINE_FULL_PATH}  /
    ${local_baseline_full_path}  Set Variable  ${LOCAL_BASELINE_WORK_DIR}/${baseline_filename}

    OperatingSystem.Copy File  ${ROTTA_BASELINE_FULL_PATH}  ${local_baseline_full_path}
    OperatingSystem.File Should Exist  ${local_baseline_full_path}

    ${file_ext}  Get File Extension  ${local_baseline_full_path}
    IF  '${file_ext}' == 'gz'
        Unpack Archive Content To Directory  ${local_baseline_full_path}  ${LOCAL_BASELINE_WORK_DIR}
        ${unzipped_file}  Fetch From Left  ${local_baseline_full_path}  .gz
        OperatingSystem.File Should Exist  ${unzipped_file}
        OperatingSystem.Copy File  ${unzipped_file}  ${LOCAL_BASELINE_WORK_DIR}/PM_Report_Baseline.xml
    ELSE
        OperatingSystem.Copy File  ${local_baseline_full_path}  ${LOCAL_BASELINE_WORK_DIR}/PM_Report_Baseline.xml
    END

    OperatingSystem.File Should Exist  ${LOCAL_BASELINE_WORK_DIR}/PM_Report_Baseline.xml


Step2: Download Latest PM XML From BTS
    Log  \nStep2: Download latest PM xml from BTS  console=true

    ${PM_DIR_ON_BTS}  Set Variable  /rom/uri/PERFMON_FILES
    ${LOCAL_LATEST_PM_XML}  Set Variable  ${BTS_FILES}/PM_Report_After_Upgrade.xml

    Sleep Until New Cycle  minutes_for_cycle=${REPORTING_INTERVAL}
    Sleep  ${WAIT_AFTER_CYCLE}

    SSHLibrary.Open Connection  ${OAM_BTS_IP}  prompt=:~ >  alias=pm_statistics
    SSHLibrary.Login  ${SMOD1}[USERNAME]  ${SMOD1}[PASSWORD]

    ${xml_file}  Extract Last Gz File From SBTS AND Get XML File Name
    SSHLibrary.Get File  ${PM_DIR_ON_BTS}/${xml_file}  ${LOCAL_LATEST_PM_XML}
    SSHLibrary.Execute Command  rm ${PM_DIR_ON_BTS}/${xml_file}

    OperatingSystem.File Should Exist  ${LOCAL_LATEST_PM_XML}

    [Teardown]  Run Keyword And Ignore Error  SSHLibrary.Close Connection


Step3: Compare PM Files With Python
    Log  \nStep3: Compare PM files with python  console=true

    ${baseline_xml}  Set Variable  ${LOCAL_BASELINE_WORK_DIR}/PM_Report_Baseline.xml
    ${latest_pm_xml}  Set Variable  ${BTS_FILES}/PM_Report_After_Upgrade.xml

    ${comparison_passed}  Run Keyword And Return Status
    ...  Check Counters Differences In PM Files  ${baseline_xml}  ${latest_pm_xml}  ${LOCAL_PM_DIFF_REPORT}

    Set Test Variable  ${COMPARE_OK}  ${comparison_passed}

    IF  not ${COMPARE_OK}
        Fail  PM raw differs from baseline. See report: ${LOCAL_PM_DIFF_REPORT}
    END

    Log  PM comparison OK.  console=true


Step4: Update ROTTA Baseline
    Log  \nStep4: Update ROTTA baseline  console=true

    IF  not ${COMPARE_OK}  RETURN

    ${rotta_baseline_path}   Set Variable  ${ROTTA_MOUNT_PATH}/${ROTTA_BASELINE_RELATIVE_PATH}
    ${backup_path}  Set Variable  ${rotta_baseline_path}.bak
    ${baseline_ext}  Get File Extension  ${rotta_baseline_path}
    ${latest_pm_xml}  Set Variable  ${BTS_FILES}/PM_Report_After_Upgrade.xml

    OperatingSystem.Copy File  ${rotta_baseline_path}  ${backup_path}
    OperatingSystem.File Should Exist  ${backup_path}

    IF  '${baseline_ext}' == 'gz'
        ${new_compressed_pm}  Set Variable  ${latest_pm_xml}.gz
        Run  gzip -c ${latest_pm_xml} > ${new_compressed_pm}
        OperatingSystem.File Should Exist  ${new_compressed_pm}
        OperatingSystem.Remove File  ${rotta_baseline_path}
        OperatingSystem.Copy File  ${new_compressed_pm}  ${rotta_baseline_path}
    ELSE
        OperatingSystem.Remove File  ${rotta_baseline_path}
        OperatingSystem.Copy File  ${latest_pm_xml}  ${rotta_baseline_path}
    END

    OperatingSystem.File Should Exist  ${rotta_baseline_path}
    Log  ROTTA baseline updated. Backup saved: ${backup_path}  console=true


Is Rotta Mounted
    [Arguments]  ${mount_point}

    ${dir_ok}  Run Keyword And Return Status  OperatingSystem.Directory Should Exist  ${mount_point}
    IF  not ${dir_ok}  RETURN  ${FALSE}

    ${rc}  ${out}  Run And Return Rc And Output  bash -lc "grep -q \" ${mount_point} \" /proc/mounts"
    IF  ${rc} == 0
        RETURN  ${TRUE}
    END

    RETURN  ${FALSE}


Map New Rotta RAN_VRF
    [Documentation]  Map NEW ROTTA volume (RAN_VRF) on VM using direct CIFS auth (no kerberos).
    [Arguments]  ${rotta_map_path}=/media/ROTTA_RAN_VRF

    Run  sudo mkdir -p ${rotta_map_path}
    Run  sudo chown ute:ute ${rotta_map_path}

    ${rotta_server_line}  Catenate
    ...  sudo mount -t cifs -o username=${COMMON_USER},password=${COMMON_PASSWORD},domain=NSN-INTRA.NET,uid=1000,gid=1000,rw
    ...  //he6rotpsvm02.emea.nsn-net.net/he6rotpsvm02_cifs_ranvrf  ${rotta_map_path}

    ${mount_output}  Run  ${rotta_server_line}

    IF  'Device or resource busy' in '''${mount_output}'''
        Log  ROTTA already mounted (Device or resource busy).  console=true
        RETURN
    END

    IF  'Permission denied' in '''${mount_output}'''
        Fail  Permission denied while mounting NEW ROTTA (RAN_VRF).\n${mount_output}
    END

    IF  'mount error' in '''${mount_output}'''
        Fail  Unable to mount NEW ROTTA (RAN_VRF).\n${mount_output}
    END

    Log  NEW ROTTA (RAN_VRF) mounted successfully at ${rotta_map_path}.  console=true


TC Setup
    Common Test Setup


TC Teardown
    Common Test Teardown