*** Settings ***
Documentation
...  TC is waiting for new entire reporting interval time period and counts the number of PM counters from last SBTS report.
...  Specified number must be the same on PM report generated on NetAct.

Resource  ../../common_resources/ca_PM_general.robot


*** Variables ***
# COUNTERS_MATCH variables can be string or list of strings delimited by commas. They are counters prefix, e.g: M80 or M800,M801.
${NR_COUNTERS_MATCH}  M55
${LTE_COUNTERS_MATCH}  M80
${WCDMA_COUNTERS_MATCH}  M50
${TNL_COUNTERS_MATCH}  M51
${CMWAS_SERVICE_IP}  ${EMPTY}  #Mandatory. IP address of cmwas service.
${WEB_URL}  ${EMPTY}  #Mandatory. Web url of Mantaray lab (e.g: srnclab2007lbwas.srnblr.nsn-rdnet.net)


*** Keywords ***
TC__PM__Check_Counters_Number_On_NetAct_Reports
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29014
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 02.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29014 - Initial TAT creation
    ...  - 24.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29607 - Fix netact pm reports path
    ...  - 18.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30219 - Add integration to NetAct and check LTE Avail meas in NetAct report
    ...  - 19.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30356 - Add faults for watchdog
    ...  - 08.01.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30362 - Fix month error
    ...  - 12.01.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30384 - Fix day error

    Set Tags  CA-PM  OWNER-mohamad.al_hamwi@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com  GROUP_IN_CHARGE-TIM_1_Vrf

    Step0: TC Precondition
    Step1: Set Counters Number From SBTS Report
    Step2: Set Counters Number From NetAct Report
    Step3: Compare Counters Number From SBTS And NetAct Reports
    Step4: Check Cell Availability Counter Presence in NetAct Report


Step0: TC Precondition
    ${netact_info}  coam.Get Nms State
    ${sbts_not_integrated_to_netact}  Run Keyword And Return Status  Should Be Empty  ${netact_info}[0][managerInfo]
    IF  ${sbts_not_integrated_to_netact}  Integrate SBTS To NetAct With NetAct Data Provided By User  ${CMWAS_SERVICE_IP}  ${WEB_URL}

    ${rat_list}  Create List  NR  LTE  WCDMA
    FOR  ${rat}  IN  @{rat_list}
        IF  ${SCF_COUNT_${rat}}  CONTINUE
        Remove Values From List  ${rat_list}  ${rat}
    END
    Set Test Variable  ${RAT_LIST}

    ${param_list}  Create List  reportingIntervalPm
    ${parameter}  Get Parameter By Distname  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMCADM-1  ${param_list}
    ${reporting_interval}  Set Variable  ${parameter}[0][parameters][reportingIntervalPm]
    IF  '${reporting_interval}'!='60min'
        Perform Parameter Recommissioning  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMCADM-1  reportingIntervalPm  update  60min
        ...  skip_parameter_relation_errors=True
        Sleep Until New Cycle  minutes_for_cycle=60min
        Sleep  1min  TC will wait until PM report is loaded.
        RETURN
    END

    SSHLibrary.Open Connection  ${OAM_BTS_IP}  prompt=:~ >  alias=pm_statistics
    SSHLibrary.Login  ${SMOD1}[USERNAME]  ${SMOD1}[PASSWORD]
    ${pm_gz_files}  SSHLibrary.List Files In Directory  /rom/uri/PERFMON_FILES  PM.*\.xml\.gz
    ${list_is_empty}  Run Keyword And Return Status  Should Be Empty  ${pm_gz_files}
    IF  ${list_is_empty}
        Sleep Until New Cycle  minutes_for_cycle=60min
        Sleep  1min  TC will wait until PM report is loaded.
    END

    [Teardown]  Run Keyword And Ignore Error  SSHLibrary.Close Connection


Step1: Set Counters Number From SBTS Report
    Log  \nStep1: Set Counters Number From SBTS Report  console=true
    SSHLibrary.Open Connection  ${OAM_BTS_IP}  prompt=:~ >  alias=pm_statistics
    SSHLibrary.Login  ${SMOD1}[USERNAME]  ${SMOD1}[PASSWORD]

    ${xml_file}  ${counters_dict}  Get PM File And Counters Number For TNL And List Of RATs  ${RAT_LIST}
    ${pm_file_name}  Remove String  ${xml_file}  test_
    Log  \nSBTS PM report: ${pm_file_name}.  console=true
    SSHLibrary.Get File  /rom/uri/PERFMON_FILES/${xml_file}  ${BTS_FILES}/PM_Report_From_SBTS.xml
    Log  \nNumber of counters from SBTS report for each technology: \n${counters_dict}.  console=true
    Set Test Variable  ${SBTS_COUNTERS_DICT}  ${counters_dict}

    [Teardown]  Run Keywords  SSHLibrary.Execute Command  rm /rom/uri/PERFMON_FILES/${xml_file}  AND  SSHLibrary.Close Connection


Step2: Set Counters Number From NetAct Report
    Log  \nStep2: Set Counters Number From NetAct Report  console=true

    SSHLibrary.Open Connection  ${CMWAS_SERVICE_IP}
    SSHLibrary.Login  ${NETACT_USER}  ${NETACT_PASSWORD}

    ${gz_report_path}  Get Last Gz PM Report From Last Directory On NetAct
    ${xml_report_path}  Remove String  ${gz_report_path}  .gz
    SSHLibrary.Execute Command  gzip -d -c ${gz_report_path} > ${xml_report_path}
    SSHLibrary.Execute Command  sed -i "s/></>\\n</g" ${xml_report_path}
    SSHLibrary.Get File  ${xml_report_path}  ${BTS_FILES}/PM_Report_From_NetAct.xml
    ${error_msg}  Catenate  ${xml_report_path} from NetAct lab does not contain info about MRBTS-${BTS_ID}.
    ...  Please check /etc/opt/nokia/oss/custom/conf/pm/etlexpmx.filter file from NetAct ssh connection.
    ${mrbts_matches}  SSHLibrary.Execute Command  cat ${xml_report_path} | grep MRBTS-${BTS_ID} | wc -l
    Should Not Be True  ${mrbts_matches}==0  ${error_msg}

    ${netact_counters_dict}  Create Dictionary
    FOR  ${rat}  IN  @{RAT_LIST}
        ${counters_on_rat}  Get Counters Dictionaries Based On XML PM File  ${${rat}_COUNTERS_MATCH}  ${xml_report_path}
        Set To Dictionary  ${netact_counters_dict}  ${rat}=${counters_on_rat}
    END
    ${tnl_counters}  Get Counters Dictionaries Based On XML PM File  ${TNL_COUNTERS_MATCH}  ${xml_report_path}
    Set To Dictionary  ${netact_counters_dict}  TNL=${tnl_counters}
    Log  \nNumber of counters from NetAct report for each technology: \n${netact_counters_dict}.  console=true
    Set Test Variable  ${NETACT_COUNTERS_DICT}

    [Teardown]  Run Keywords  SSHLibrary.Execute Command  rm ${xml_report_path}  AND  SSHLibrary.Close Connection


Step3: Compare Counters Number From SBTS And NetAct Reports
    Log  \nStep3: Compare Counters Number From SBTS And NetAct Reports  console=true
    FOR  ${tech}  IN  @{NETACT_COUNTERS_DICT}
        ${expected_counters_number}  Set Variable  ${SBTS_COUNTERS_DICT}[${tech}][counters_number]
        ${expected_counters_set_on_0}  Set Variable  ${SBTS_COUNTERS_DICT}[${tech}][counters_set_on_0]
        ${netact_counters_number}  Set Variable  ${NETACT_COUNTERS_DICT}[${tech}][counters_number]
        ${netact_counters_set_on_0}  Set Variable  ${NETACT_COUNTERS_DICT}[${tech}][counters_set_on_0]

        ${counters_set_on_0_status}  Run Keyword And Return Status  Should Be Equal As Integers  ${netact_counters_set_on_0}
        ...  ${expected_counters_set_on_0}
        IF  not ${counters_set_on_0_status}
            ${counters_diff}  Get Counters Differences Between 2 XML Files  ${BTS_FILES}/PM_Report_From_SBTS.xml
            ...  ${BTS_FILES}/PM_Report_From_NetAct.xml  ${${tech}_COUNTERS_MATCH}  counters_type=set_on_0
            Log  Number of ${tech} counters set on 0 differ. \nFollowing counters are different:\n${counters_diff}.  level=ERROR
            Set Test Failed  Number of ${tech} counters set on 0 differ. \nFollowing counters are different:\n${counters_diff}.
        END

        ${all_counters_status}  Run Keyword And Return Status  Should Be Equal As Integers  ${netact_counters_number}  ${expected_counters_number}
        IF  not ${all_counters_status}
            ${counters_diff}  Get Counters Differences Between 2 XML Files  ${BTS_FILES}/PM_Report_From_SBTS.xml
            ...  ${BTS_FILES}/PM_Report_From_NetAct.xml  ${${tech}_COUNTERS_MATCH}  counters_type=all
            Log  Number of all ${tech} counters differ. \nFollowing ${tech} counters are different:\n${counters_diff}.  level=ERROR
            Set Test Failed  Number of all ${tech} counters differ. \nFollowing counters are different:\n${counters_diff}.
        END
    END


Step4: Check Cell Availability Counter Presence in NetAct Report
    Log  Step4: Check Cell Availability Counter Presence in NetAct Report  console=true

    ${cell_avail_lines_no}  Run  grep -E "measurementType=\\"LTE_Cell_Avail\\"" ${BTS_FILES}/PM_Report_From_NetAct.xml | wc -l
    ${lte_cells}  Get Ids For All  LNCEL  search_for_iot_cells=False
    ${lte_cells_no}  Get Length  ${lte_cells}
    ${result}  Evaluate  ${cell_avail_lines_no}%${lte_cells_no}

    Should Be True  ${result}==0
    ...  LTE_Cell_Avail does not appear for all LTE cells in ${BTS_FILES}/PM_Report_From_NetAct.xml report.
    Log  LTE_Cell_Avail is visible for all ${lte_cells_no} LTE cells in ${BTS_FILES}/PM_Report_From_NetAct.xml report.  console=true


Integrate SBTS To NetAct With NetAct Data Provided By User
    [Arguments]  ${cmwas_ip}  ${web_url}

    Add Node  service_name=cmwas  hostname=${cmwas_ip}  username=${NETACT_USER}  password=${NETACT_PASSWORD}
    Add Web Url  ${web_url}  ${NETACT_USER}  ${NETACT_PASSWORD}
    Set Test Variable  ${MRBTS_DN}  PLMN-PLMN/MRBTS-${BTS_ID}
    Integrate SBTS To NetAct
    Wait Until Keyword Succeeds  180  15  Check SBTS To Be Integrated To NetAct
    Log  SBTS is integrated in NetAct lab ${WEB_URL}.  console=true

    [Teardown]  Delete Node  cmwas


Check SBTS To Be Integrated To NetAct
    ${netact_info}  coam.Get Nms State
    Should Not Be Empty  ${netact_info}[0][managerInfo]  msg=SBTS is not integrated in NetAct!


Get Last Gz PM Report From Last Directory On NetAct
    ${reports_path}  Set Variable  /var/opt/nokia/oss/global/mediation/north/pm/export
    ${date}  Get Current Date  result_format=datetime
    ${month}  Set Variable If  ${date.month}<10  0${date.month}  ${date.month}
    ${day}  Set Variable If  ${date.day}<10  0${date.day}  ${date.day}
    ${hour}  Set Variable If  ${date.hour}<10  0${date.hour}  ${date.hour}

    ${pattern}  Set Variable  ${date.year}${month}${day}${hour}
    ${pm_reports}  SSHLibrary.List Files In Directory  ${reports_path}/${pattern}
    ${list_is_empty}  Run Keyword And Return Status  Should Be Empty  ${pm_reports}
    IF  ${list_is_empty}
        Sleep  3min  TC waits for NetAct PM report to be visible.
        ${pm_reports}  SSHLibrary.List Files In Directory  ${reports_path}/${pattern}
    END
    ${mrbts_report}  Get Matches  ${pm_reports}  *_MRBTS_*
    ${lnbts_report}  Get Matches  ${pm_reports}  *_LNBTS_*
    ${pm_reports}  Combine Lists  ${mrbts_report}  ${lnbts_report}

    ${timestamps}  Create List
    FOR  ${pm_report}  IN  @{pm_reports}
        ${report_name_splitted}  Split String  ${pm_report}  _
        Append To List  ${timestamps}  ${report_name_splitted}[2]
    END
    Sort List  ${timestamps}
    ${report_matches}  Get Matches  ${pm_reports}  *${timestamps}[-1]*
    Log  \nNetAct PM report: ${report_matches}[0].  console=true

    RETURN  ${reports_path}/${pattern}/${report_matches}[0]


TC Setup
    Common Test Setup  tc_name=PM__Check_Counters_Number_On_NetAct_Reports


TC Teardown
    Common Test Teardown
