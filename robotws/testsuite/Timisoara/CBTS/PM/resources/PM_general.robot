*** Settings ***
Documentation  This suite contains KWs used by PM TCs

Library  ta_emss


*** Variables ***
${VM_WITH_PANO_IP}  10.5.47.47
${VM_WITH_PANO_USR}  ute
${VM_WITH_PANO_PASSWD}  UTE.debian12


*** Keywords ***
Sleep Until New Cycle
    [Documentation]  This keyword calculates the minutes it needs to sleep until new [argument] minutes cycle.
    ...  *AUTHOR*: andrada-lavinia.baleti@nokia.com
    ...  *MAINTAINER*: andrada-lavinia.baleti@nokia.com
    [Arguments]  ${minutes_for_cycle}

    ${minutes_for_cycle}  Convert To String  ${minutes_for_cycle}
    ${minutes_for_cycle}  Remove String  ${minutes_for_cycle}  min
    @{time}  Get Time  min sec
    ${minutes_for_cycle}  Set Variable If  '${minutes_for_cycle}'=='5'  0${minutes_for_cycle}  ${minutes_for_cycle}
    ${minutes}  Set Variable  00:${minutes_for_cycle}:00
    ${interval_dict}  Create Dictionary  05=12  15=4  30=2  60=1
    FOR  ${index}  IN RANGE  0  ${interval_dict}[${minutes_for_cycle}]
        Exit For Loop If  '00:${time}[0]:${time}[1]'<'${minutes}'
        ${minutes}  Add Time To Time  ${minutes}  ${minutes_for_cycle}:00  timer  exclude_millis=yes
    END
    ${minutes}  Subtract Time From Time  ${minutes}  00:${time}[0]:${time}[1]  timer  exclude_millis=yes
    Log  Sleep for ${minutes} minutes until new ${minutes_for_cycle} min cycle.  console=true
    Sleep  ${minutes}


Turn ON Pano And Check If Is Connected
    [Documentation]  This keyword is starting pano session on VM dedicated. Two ssh connections are opened. The one with start_pano alias will stay
    ...  opened until the end of test case when pano is turned off by 'pano stop-ves' command. This keyword only close the default ssh connection.
    ...  - robot suite variables: ${VM_WITH_PANO_IP}, ${VM_WITH_PANO_USR}, ${VM_WITH_PANO_PASSWD}
    [Arguments]  ${pano_vm_ip}=${VM_WITH_PANO_IP}  ${pano_vm_usr}=${VM_WITH_PANO_USR}  ${pano_vm_passwd}=${VM_WITH_PANO_PASSWD}

    ${default_connection}  SSHLibrary.Open Connection  ${pano_vm_ip}
    SSHLibrary.Login  ${pano_vm_usr}  ${pano_vm_passwd}

    Set Client Configuration  prompt=$
    SSHLibrary.Write  pano status
    Sleep  10s  Time for status to be written in console output.
    ${msg_pano_status}  SSHLibrary.Read Until Prompt
    ${pano_is_running}  Run Keyword And Return Status
    ...  Should Contain  ${msg_pano_status}  Checking VES statistics:
    Return From Keyword If  ${pano_is_running}

    Log  \nTurn ON Pano  console=true
    SSHLibrary.Open Connection  ${pano_vm_ip}  alias=start_pano
    SSHLibrary.Login  ${pano_vm_usr}  ${pano_vm_passwd}
    SSHLibrary.Write  cd /home/ute/pano; pano start-ves
    Sleep  10s  Time for logs to be written in console output.
    ${msg_pano_start}  SSHLibrary.Read
    Should Contain  ${msg_pano_start}  HTTP Server start...

    SSHLibrary.Switch Connection  ${default_connection}
    SSHLibrary.Write  pano status
    Sleep  10s  Time for status to be written in console output.
    ${msg_pano_status}  SSHLibrary.Read Until Prompt
    Should Contain  ${msg_pano_status}  Checking VES statistics:

    [Teardown]  SSHLibrary.Close Connection


Turn OFF Pano And Check If Is Disconnected
    [Documentation]  This keyword is closing all pano sessions on VM dedicated.
    ...  - robot suite variables: ${VM_WITH_PANO_IP}, ${VM_WITH_PANO_USR}, ${VM_WITH_PANO_PASSWD}
    [Arguments]  ${pano_vm_ip}=${VM_WITH_PANO_IP}  ${pano_vm_usr}=${VM_WITH_PANO_USR}  ${pano_vm_passwd}=${VM_WITH_PANO_PASSWD}

    Log  \nTurn OFF Pano  console=true
    SSHLibrary.Open Connection  ${pano_vm_ip}
    SSHLibrary.Login  ${pano_vm_usr}  ${pano_vm_passwd}
    SSHLibrary.Execute Command  pano stop-ves
    Sleep  10s  Time for pano server to be fully stopped.
    Set Client Configuration  prompt=$
    SSHLibrary.Write  pano status
    Sleep  10s  Time for status to be written in console output.
    ${msg_pano_status}  SSHLibrary.Read until prompt
    Should Contain  ${msg_pano_status}  Failed to get VES statistics

    [Teardown]  SSHLibrary.Close All Connections


Get Last 3GPP PM File Line From Vdu
    [Documentation]  This KW is opening ssh connection to Vdu and is returning the last 3GPP PM file line
    ...  from /mnt/services/SS_OAM/PMSTAT/pm_result_files_3GPP location.

    Open SSH Connection To VDU And Connect To Openshift
    ${oampm_pod_name}  Get Full Name For Pod  ${VDU_CRAN}  oampm
    ${oampm_container_name}  Get Full Name For Container  ${VDU_CRAN}  oampm
    ${get_pm_reports_comm}  Catenate  oc exec -it ${oampm_pod_name} -n ${VDU_CRAN} -c ${oampm_container_name}
    ...  -- ls -l /mnt/services/SS_OAM/PMSTAT/pm_result_files_3GPP | tail -10 | sort -k6,6 -k7,7 -k8,8
    SSHLibrary.Write  ${get_pm_reports_comm}
    Sleep  10s  Time for all 3GPP files to be logged.
    ${pm_file_lines}  SSHLibrary.Read Until Prompt
    ${pm_file_lines}  Get Lines Containing String  ${pm_file_lines}  .xml.gz
    ${pm_file_lines}  Split To Lines  ${pm_file_lines}
    ${last_pm_file_line}  Split String  ${pm_file_lines}[-1]  ${SPACE}

    [Return]  ${last_pm_file_line}
    [Teardown]  SSHLibrary.Close Connection


Get 3GPP PPM Files Name From Vdu Or Vcu
    [Documentation]  This KW is opening ssh connection to Vdu or Vcu and is returning the PPM files names
    ...  from provided location.
    [Arguments]  ${cbts_instance}  ${ppm_files_location}

    IF  '${cbts_instance}'=='VDU'
        Open SSH Connection To VDU And Connect To Openshift
        ${cran}  Set Variable  ${VDU_CRAN}
    ELSE
        Open SHH Connection To VCU And Connect To Openshift
        ${cran}  Set Variable  ${VCU_CRAN}
    END

    ${oampm_pod_name}  Get Full Name For Pod  ${cran}  oampm
    ${oampm_container_name}  Get Full Name For Container  ${cran}  oampm
    ${get_pm_reports_comm}  Catenate  oc exec -it ${oampm_pod_name} -n ${cran} -c ${oampm_container_name}
    ...  -- ls -l ${ppm_files_location} | sort -k6,6 -k7,7 -k8,8
    SSHLibrary.Write  ${get_pm_reports_comm}
    Sleep  10s  Time for PM files to be logged.
    ${ppm_file_lines}  SSHLibrary.Read Until Prompt
    ${ppm_file_lines}  Get Lines Containing String  ${ppm_file_lines}  .xml.gz
    ${ppm_file_lines}  Split To Lines  ${ppm_file_lines}
    ${count}  Get Length  ${ppm_file_lines}
    Should Be True  ${count}==2  There are not 2 PPM files in ${ppm_files_location} on CBTS.

    ${last_report_from_previous_interval}  Split String  ${ppm_file_lines}[0]  ${SPACE}
    ${last_report_from_current_interval}  Split String  ${ppm_file_lines}[1]  ${SPACE}

    RETURN  ${last_report_from_previous_interval}[-1]  ${last_report_from_current_interval}[-1]


Get Last 3GPP PM File Line From Vcu
    [Documentation]  This KW is opening ssh connection to Vcu and is returning the last 3GPP PM file line
    ...  from /mnt/services/SS_OAM/PMSTAT/pm_result_files_3GPP location.

    Open SHH Connection To VCU And Connect To Openshift
    ${oampm_pod_name}  Get Full Name For Pod  ${VCU_CRAN}  oampm
    ${oampm_container_name}  Get Full Name For Container  ${VCU_CRAN}  oampm
    ${get_pm_reports_comm}  Catenate  oc exec -it ${oampm_pod_name} -n ${VCU_CRAN} -c ${oampm_container_name}
    ...  -- ls -l /mnt/services/SS_OAM/PMSTAT/pm_result_files_3GPP | tail -10 | sort -k6,6 -k7,7 -k8,8
    SSHLibrary.Write  ${get_pm_reports_comm}
    Sleep  10s  Time for all 3GPP files to be logged.
    ${pm_file_lines}  SSHLibrary.Read Until Prompt
    ${pm_file_lines}  Get Lines Containing String  ${pm_file_lines}  .xml.gz
    ${pm_file_lines}  Split To Lines  ${pm_file_lines}
    ${last_pm_file_line}  Split String  ${pm_file_lines}[-1]  ${SPACE}

    [Return]  ${last_pm_file_line}
    [Teardown]  SSHLibrary.Close Connection


Get Last PM File Name From Pano
    [Documentation]  This KW is opening ssh connection to Pano Server and is returning the last
    ...  PM file name from /home/ute/.local/pano/pm_files location.
    [Arguments]  ${mrbts_id}=${VDU_MRBTS_ID}

    SSHLibrary.Open Connection  ${VM_WITH_PANO_IP}
    SSHLibrary.Login  ${VM_WITH_PANO_USR}  ${VM_WITH_PANO_PASSWD}
    ${pano_pm_last_file_line}  SSHLibrary.Execute Command  ls -l /home/ute/.local/pano/pm_files | grep MRBTS-${mrbts_id} | tail -1
    Should Not Be Empty  ${pano_pm_last_file_line}  There are no PM files on Pano server.
    ${pm_file}  Fetch From Right  ${pano_pm_last_file_line}  ${SPACE}
    ${pm_gz_file}  Remove String  ${pm_file}  .validate.ok

    [Return]  ${pm_gz_file}
    [Teardown]  SSHLibrary.Close Connection


Get Last File From PM Report Files From Vdu
    [Documentation]  This KW is opening ssh connection to Vdu and is returning the last PM file line
    ...  from /mnt/services/SS_OAM/PMSTAT/pm_report_files location.

    Open SSH Connection To VDU And Connect To Openshift
    ${oampm_pod_name}  Get Full Name For Pod  ${VDU_CRAN}  oampm
    ${oampm_container_name}  Get Full Name For Container  ${VDU_CRAN}  oampm
    ${get_pm_reports_comm}  Catenate  oc exec -it ${oampm_pod_name} -n ${VDU_CRAN} -c ${oampm_container_name}
    ...  -- ls -l /mnt/services/SS_OAM/PMSTAT/pm_report_files | tail -10 | sort -k6,6 -k7,7 -k8,8
    SSHLibrary.Write  ${get_pm_reports_comm}
    Sleep  10s  Time for PM files to be logged.
    ${pm_file_lines}  SSHLibrary.Read Until Prompt
    ${pm_file_lines}  Get Lines Containing String  ${pm_file_lines}  .xml.gz
    ${pm_file_lines}  Split To Lines  ${pm_file_lines}
    ${last_pm_file_line}  Split String  ${pm_file_lines}[-1]  ${SPACE}

    [Return]  ${last_pm_file_line}
    [Teardown]  SSHLibrary.Close Connection


Get Last File From PM Report Files From Vcu
    [Documentation]  This KW is opening ssh connection to Vcu and is returning the last PM file line
    ...  from /mnt/services/SS_OAM/PMSTAT/pm_report_files location.

    Open SHH Connection To VCU And Connect To Openshift
    ${oampm_pod_name}  Get Full Name For Pod  ${VCU_CRAN}  oampm
    ${oampm_container_name}  Get Full Name For Container  ${VCU_CRAN}  oampm
    ${get_pm_reports_comm}  Catenate  oc exec -it ${oampm_pod_name} -n ${VCU_CRAN} -c ${oampm_container_name}
    ...  -- ls -l /mnt/services/SS_OAM/PMSTAT/pm_report_files | tail -10 | sort -k6,6 -k7,7 -k8,8
    SSHLibrary.Write  ${get_pm_reports_comm}
    Sleep  10s  Time for PM files to be logged.
    ${pm_file_lines}  SSHLibrary.Read Until Prompt
    ${pm_file_lines}  Get Lines Containing String  ${pm_file_lines}  .xml.gz
    ${pm_file_lines}  Split To Lines  ${pm_file_lines}
    ${last_pm_file_line}  Split String  ${pm_file_lines}[-1]  ${SPACE}

    [Return]  ${last_pm_file_line}
    [Teardown]  SSHLibrary.Close Connection


Check Counters In PM Report
    [Documentation]  This KW is checking PMQAP and Non-PMQAP counters from txt file to not have 0 value in PM report.
    [Arguments]  ${zero_counter_supp_value}  ${counters_on_0}  ${report_name}

    ${expected_counters}  OperatingSystem.Grep File  ${EXPECTED_COUNTERS_PATH}/${zero_counter_supp_value}_Counters.txt  M55
    ${expected_counters}  Split To Lines  ${expected_counters}

    ${counters_on_0_not_ok}  Evaluate  list(filter(lambda x: x in ${expected_counters}, ${counters_on_0}))
    ${length}  Get Length  ${counters_on_0_not_ok}
    IF  ${length}>0
        Log  Following ${zero_counter_supp_value} from ${report_name}.xml are equal to 0:\n${counters_on_0_not_ok}.  level=ERROR
        Append To List  ${FAIL_MESSAGES}  Following ${zero_counter_supp_value} from ${report_name}.xml are equal to 0:\n${counters_on_0_not_ok}.
        IF  '${TEST_VERDICT}'!='FAIL'  Set Test Variable  ${TEST_VERDICT}  FAIL
    END


Start Emss Simulator
    [Documentation]  This KW is creating ta_emss library instance.
    [Arguments]  ${mrbts_id}  ${oam_ip}

    Disable Firewalls
    Log  Start Emss Simulator  console=true
    Setup Emss  bts_id=${mrbts_id}  bts_ip=${oam_ip}


Disable Firewalls
    [Documentation]  This kw is disabling VM firewalls to be able to connect to EMS Simulator installed on VM.

    Run  sudo iptables -P INPUT ACCEPT
    Run  sudo iptables -P OUTPUT ACCEPT
    Run  sudo iptables -P FORWARD ACCEPT
    Run  sudo iptables -F


Stop Emss Simulator
    [Documentation]  This KW is removing ta_emss library instance.
    [Arguments]  ${mrbts_id}

    Log  Stop Emss Simulator  console=true
    Teardown Emss  bts_id=${mrbts_id}


Wait For New 1 Minute Interval
    [Documentation]  This kw waits until new 1 minute interval starts.

    ${current_time}  Get Current Date  exclude_millis=True  result_format=datetime  time_zone=UTC
    ${wait_time}  Evaluate  int(60-${current_time.second})
    Sleep  ${wait_time}  TC waits until new 1 minute interval.


Get Logs Since Minutes
    [Documentation]  Gets logs from pod/container since N minutes.
    [Arguments]  ${cran}  ${pod}  ${container}  ${since_min}=1

    ${cmd}  Catenate  SEPARATOR=${SPACE}
    ...  kubectl logs -n ${cran} ${pod} -c ${container} --since=${since_min}m
    SSHLibrary.Write  ${cmd}
    ${kubectl_logs_output}  SSHLibrary.Read Until Prompt

    RETURN  ${kubectl_logs_output}


Extract Latest PPM Creation From OAMPM Logs
    [Documentation]  Returns latest created PPM path and extracts interval + BTS from filename.
    [Arguments]  ${cran}  ${oampm_pod}  ${oampm_container}  ${ppm_file}

    ${logs}  Get Logs Since Minutes  ${cran}  ${oampm_pod}  ${oampm_container}
    ${paths}  Get Regexp Matches  ${logs}  ${RE_PPM_CREATE_LINE}
    ${length}  Get Length  ${paths}
    IF  ${length} > 0
        Log  'PPM result file created' found in ${ppm_file}![OK]  console=true
    ELSE
        Fail  'PPM result file created' not found in ${ppm_file}![NOK]
    END
    ${ppm_path}  Set Variable  ${paths}[-1]
    ${file}  Fetch From Right  ${ppm_path}  /
    ${start_list}  Get Regexp Matches  ${file}  ${RE_PPM_FILE_PARTS}  1
    ${end_list}  Get Regexp Matches  ${file}  ${RE_PPM_FILE_PARTS}  2
    ${bts_list}  Get Regexp Matches  ${file}  ${RE_PPM_FILE_PARTS}  3
    ${start}  Set Variable  ${start_list}[0]
    ${end}  Set Variable  ${end_list}[0]
    ${bts}  Set Variable  ${bts_list}[0]

    RETURN  ${ppm_path}  ${start}  ${end}  ${bts}