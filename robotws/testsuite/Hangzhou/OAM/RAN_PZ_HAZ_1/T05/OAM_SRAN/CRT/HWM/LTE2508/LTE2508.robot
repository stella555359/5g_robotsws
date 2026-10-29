*** Settings ***
Documentation     [PURPOSE]
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Mrat_resource_new.robot
Library           ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/tool_ping.py
Library           taf.sbts.oam.coam.admin
Library           ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/file_operation.py
Library           String
Library           DateTime
Library           OperatingSystem
Library           ute_async


*** Variables ***
${TARGET_SW_NAME}                                   ${None}    # SW package name. If not given, TC will choose newest package in a directory.
${TARGET_SW_DIR}    /home/ute/btsauto/TARGET_SW/    # Directory for sw package. If not given, '/home/ute/btsauto/TARGET_SW' should be used
${UPDATE_TIMEOUT}                                   1500    # Timeout for Download and Activation [sec]
${SW Download Timeout}                              1800
${SW Activation Timeout}                            150  # Given in seconds; That is a timeout for SW download and activation (without reset)
${Ping loss timeout}                                420  # Timeout for ping loss during reset
${Ping regain timeout}                              600  # Timeout for ping regain during reset
${BTS_OnAir_Timeout}                                15  # Timeout for BTS on Air (in minutes)
${Test_Timeout}                                     30  # Test timeout (in minutes)
${onAir Check Number}           60  # Number of checks for proceduralStatus: onAir after RMODs reset is complete; check interval = 10s


*** Keywords ***
LTE2508_ST_01_01_Tri_energy_counter_reporting_Energy_consumption_LTE2508_is_disabled
    [Documentation]    Short description.
    LTE2508 .Upload_interval_change    15min
    LTE2508 .Disable_LTE2508_B_feature_parameter
    taf.sbts.oam.coam.admin.Reset Site    timeout=300    alias=default
#    LTE2508 .Private_delete_PM_file
#    ${sleep_time}    Get Counter File Remaining Time
    ${sleep_time}    set variable    1200s
    sleep    ${sleep_time}
    Verify BTS states
#    sleep    180s
#    LTE2508 .Private_download_new_PM_file
#    ${File_00}    set variable    ${TestFiles}${/}PMCounter.xml
    ${status_M40002C0}    Run Keyword And Return Status    taf.sbts.oam.coam.admin.get_pm_counters    M40002C0
#    ...    Number of cell state changes to "cell is available" (M40002C0)
    Should Be Equal As Strings    ${status_M40002C0}    False

Upload_interval_change
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${interval_upload}: <description>
    [Arguments]    ${interval_upload}
    Run keyword and ignore error    taf.sbts.oam.coam.admin.Perform Parameter Recommissioning
    ...  dist_name=${BTS_INFO.MRBTS}/MNL-1/MNLENT-1/PMCADM-1    parameter=reportingIntervalPm    operation=update    value=${interval_upload}
    ...  skip_parameter_relation_errors=True  should_activate=True  alias=default

Disable_LTE2508_B_feature_parameter
    [Documentation]    Short description.
    Run keyword and ignore error    taf.sbts.oam.coam.admin.Perform Parameter Recommissioning
    ...  dist_name=${BTS_INFO.MRBTS}/MNL-1/MNLENT-1/FEATCADM-1    parameter=actPowerMeter    operation=update    value=false
    ...  skip_parameter_relation_errors=True  should_activate=True  alias=default

Private_delete_PM_file
    [Documentation]    Short description.
#    Set Connection Parameters    ip=${SMOD1['TRS_IP']}    user=${SMOD1['USERNAME']}    password=${SMOD1['PASSWORD']}
#    SSHLibrary.Execute Command    cd /ram
#    SSHLibrary.Execute Command    ls -lh | grep PM.BTS
#    SSHLibrary.Execute Command    rm *PM.BTS-${BTS_INFO.ID}*
#    Run keyword and ignore error  Run Remote Linux Command    cd /ram
    ${status1}  ${Return1}  Run keyword and ignore error  Run Remote Linux Command    ls /ram -lh | grep PM.BTS
    ${status}  ${Return}  Run keyword and ignore error  Run Remote Linux Command    rm /ram/*PM.BTS-${BTS_INFO.ID}*
    Run keyword if  '${status}'=='PASS'  Log  pm file successfully deleted  console=${TRUE}
    ...  ELSE
    ...  Log Important Message  pm file not deleted  level=WARN

Private_download_new_PM_file
    [Documentation]    Short description.
#    Set Connection Parameters    ip=${SMOD1['TRS_IP']}    user=${SMOD1['USERNAME']}    password=${SMOD1['PASSWORD']}
#    Run Remote Linux Command    cd /ram
    ${status1}  ${Return1}  Run keyword and ignore error  Run Remote Linux Command   gunzip \ /ram/PM.BTS-${BTS_INFO.ID}.*.ANY.xml.gz
    ${status}  ${Return}  Run keyword and ignore error  Run Remote Linux Command    ls /ram -lh | grep PM.BTS
    ${match}    ${date}    ${time}    Should Match Regexp    ${Return}    PM.BTS-${BTS_INFO.ID}.(\\d+).(\\d+).ANY.xml
    log    ${match}
    log    ${date}
    log    ${time}
    Run Remote Linux Command    cp /ram/${match} \\PMCounter.xml
#    sftp Download    192.168.255.1    22    toor4nsn    oZPS0POrRieRtu    /ram/${match}    ${TestFiles}${/}${match}
#    sftp Download    192.168.255.1    22    toor4nsn    oZPS0POrRieRtu    /ram/PMCounter.xml    ${TestFiles}${/}PMCounter.xml
    ${copy_status}  Run keyword and return status
    ...  Run  sshpass -p ${SMOD1['PASSWORD']} scp ${SMOD1['USERNAME']}@${SMOD1['TRS_IP']}:'/ram/${match}' '${TestFiles}${/}${match}'
    Run keyword if  ${copy_status}  Log  /ram/${match} file successfully copied  console=${TRUE}
    ...  ELSE
    ...  Log Important Message  /ram/${match} file not copied  level=WARN
    ${copy_status}  Run keyword and return status
    ...  Run  sshpass -p ${SMOD1['PASSWORD']} scp ${SMOD1['USERNAME']}@${SMOD1['TRS_IP']}:'/ram/PMCounter.xml' '${TestFiles}${/}PMCounter.xml'
    Run keyword if  ${copy_status}  Log  /ram/PMCounter.xml file successfully copied  console=${TRUE}
    ...  ELSE
    ...  Log Important Message  /ram/PMCounter.xml file not copied  level=WARN
    Run Remote Linux Command    rm -rf PMCounter.xml

Recover configuration
    [Documentation]    Short description.
    Run keyword and ignore error    taf.sbts.oam.coam.admin.Perform Parameter Recommissioning
    ...  dist_name=${BTS_INFO.MRBTS}/MNL-1/MNLENT-1/FEATCADM-1    parameter=actPowerMeter    operation=update    value=false
    ...  skip_parameter_relation_errors=True  should_activate=True  alias=default

Get_system_start_end_time
    [Documentation]    Short description.
    Login_with_multiway    ${SMOD1['TRS_IP']}    ${SMOD1['USERNAME']}    ${SMOD1['PASSWORD']}
    ${end_time1}    SSHLibrary.Execute Command   date '+%Y-%m-%d %T'
    ${END_TIME}    Get line    ${end_time1}    0
    ${start_time1}    SSHLibrary.Execute Command    date -d "30min ago" '+%Y-%m-%d %T'
    ${START_TIME}    Get line    ${start_time1}    0
    Set Suite Variable    ${START_TIME}
    Set Suite Variable    ${END_TIME}

LTE2508_ST_01_02_Tri_energy_counter_reporting_Energy_consumption_LTE2508_is_enabled_and_RF_support_HW_ASMI
    [Documentation]    Short description.
    LTE2508 .Upload_interval_change    15min
    LTE2508 .Enable_LTE2508_B_feature_parameter
#    LTE2508 .Private_delete_PM_file
#    ${sleep_time}    Get Counter File Remaining Time
    ${sleep_time}    set variable    1800s
    sleep    ${sleep_time}
#    sleep    180s
#    LTE2508 .Private_download_new_PM_file
#    ${File_00}    set variable    ${TestFiles}${/}PMCounter.xml
    ${Counter_M40002C0}    taf.sbts.oam.coam.admin.get_pm_counters    M40002C0
    LTE2508 .Get_system_start_end_time
#    ...   Number of cell state changes to "cell is available" (M40002C0)
    ${conter_values} =    Run Keyword if     '${target_release}' == 'SBTS00'
    ...    Get Dictionary Values      ${Counter_M40002C0}[BTS][${BTS_INFO.MRBTS}][SBTS_Energy_Consumption][M40002C0]
    ...    ELSE    Get Dictionary Values      ${Counter_M40002C0}[BTS][${BTS_INFO.MRBTS}][SBTS_Energy_Consumption][M40002C0]
    ${Counter_M40002C0}=     Set Variable      ${conter_values[-1]}
    ${Counter_NA_M40002C0}    LTE2508 .Get_counter_value_by_NA_name    ${START_TIME}    ${END_TIME}    ENERGY_CONSUMPTION_IN_BTS
#    ...    M40002C2 ENERGY_CONSUMPTION_IN_BTS
    ${Counter_M40002C1}    taf.sbts.oam.coam.admin.get_pm_counters    M40002C1
#    ...    Number of cell state changes to unplanned unavailable (M40002C1)
    LTE2508 .Get_system_start_end_time
    ${conter_values} =    Run Keyword if     '${target_release}' == 'SBTS00'
    ...    Get Dictionary Values      ${Counter_M40002C1}[BTS][${BTS_INFO.MRBTS}][SBTS_Energy_Consumption][M40002C1]
    ...    ELSE    Get Dictionary Values      ${Counter_M40002C1}[BTS][${BTS_INFO.MRBTS}][SBTS_Energy_Consumption][M40002C1]
    ${Counter_M40002C1}=     Set Variable       ${conter_values[-1]}
    ${Counter_NA_M40002C1}    LTE2508 .Get_counter_value_by_NA_name    ${START_TIME}    ${END_TIME}    ENERGY_CONSUMPTION_IN_RF
#    ...    M40002C1 ENERGY_CONSUMPTION_IN_RF
    ${Counter_M40002C2}    taf.sbts.oam.coam.admin.get_pm_counters    M40002C2
#    ...    Samples when the cell is available (M40002C2) --update every second
    LTE2508 .Get_system_start_end_time
    ${conter_values} =    Run Keyword if     '${target_release}' == 'SBTS00'
    ...    Get Dictionary Values      ${Counter_M40002C2}[BTS][${BTS_INFO.MRBTS}][SBTS_Energy_Consumption][M40002C2]
    ...    ELSE    Get Dictionary Values      ${Counter_M40002C2}[BTS][${BTS_INFO.MRBTS}][SBTS_Energy_Consumption][M40002C2]
    ${Counter_M40002C2}=     Set Variable       ${conter_values[-1]}
    ${Counter_NA_M40002C2}    LTE2508 .Get_counter_value_by_NA_name    ${START_TIME}    ${END_TIME}    ENERGY_CONSUMPTION_IN_BTS
#    ...    M40002C2 ENERGY_CONSUMPTION_IN_BTS
    log    ${Counter_M40002C0}
    log    ${Counter_M40002C1}
    log    ${Counter_M40002C2}
    log    ${Counter_NA_M40002C0}
    log    ${Counter_NA_M40002C2}
    log    ${Counter_NA_M40002C1}
    Should Be Equal As Strings    ${Counter_M40002C2}    ${Counter_NA_M40002C2}
    Should Be Equal As Strings    ${Counter_M40002C1}    ${Counter_NA_M40002C1}
    LTE2508 .Disable_LTE2508_B_feature_parameter

Enable_LTE2508_B_feature_parameter
    [Documentation]    Short description.
    Run keyword and ignore error    taf.sbts.oam.coam.admin.Perform Parameter Recommissioning
    ...  dist_name=${BTS_INFO.MRBTS}/MNL-1/MNLENT-1/FEATCADM-1    parameter=actPowerMeter    operation=update    value=true
    ...  skip_parameter_relation_errors=True  should_activate=True  alias=default
    Run keyword and ignore error    taf.sbts.oam.coam.admin.Perform Parameter Recommissioning
    ...  dist_name=${BTS_INFO.MRBTS}/MNL-1/MNLENT-1/PMMNL-1    parameter=mtBtsEnergyMonitoring    operation=update    value=15min
    ...  skip_parameter_relation_errors=True  should_activate=True  alias=default

Get_counter_value_by_NA_name
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${start_time}: <description>
    ...        ${end_time}: <description>
    ...        ${NA_name}: <description>
    ...
    ...    Returns:
    ...        ${counter_value}: <description>
    [Arguments]    ${start_time}    ${end_time}    ${NA_name}
    log     Get_counter_value_by_NA_name
#    SSHLibrary.Open Connection  host=${NETACT_SERVER_INFO.IP}  port= ${NETACT_SERVER_INFO.PORT}
    Login_with_multiway    ${NETACT_SERVER_INFO.IP}    ${NETACT_SERVER_INFO.USERNAME}    ${NETACT_SERVER_INFO.PASSWORD}
#    set client configuration    SQL>
    write    sqlplus omc/omc
    sleep    5s
    write    set heading off
#    SSHLibrary.Execute Command   set heading off
    sleep    5s
    write
    ...    select to_char(co_gid) from utp_common_objects where co_object_instance\=${BTS_INFO.ID} and co_oc_id\=3128;
    ${dn_list}=    Read     delay=3s
    Log To console     ${dn_list}
    ${bts_dn1}    Split String    ${dn_list}
    ${bts_dn}    Get From List    ${bts_dn1}    -2
    ${command}=    Catenate    SEPARATOR=${SPACE}
    ...    select \ ${NA_name} , to_char(period_start_time,'YYYY-MM-DD HH24:MI:SS')
    ...    from NOKMRN_PS_ENC_MRBTS_RAW \ where period_start_time >\= to_date('${start_time}', 'yyyy-mm-dd hh24:mi:ss')
    ...    and period_start_time < to_date('${end_time}', 'yyyy-mm-dd hh24:mi:ss') \ and MRBTS_ID\= ${bts_dn};
    sleep    5s
    write    ${command}
    ${sql_output}=    Read     delay=3s
    ${result}    Split String    ${sql_output}
    ${counter_value}    Get From List    ${result}    -4
    _Remote Command Teardown
    [Return]    ${counter_value}
