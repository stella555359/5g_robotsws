*** Settings ***
Documentation
...     [Author]                "Mamtha Kshirsagar"
...     [Maintenance]           "TRS ET Bangalore Team"
...     [Procedure]             "The test case is planned to verify SOE, world readable file permissions an removal of
...     telenet binary files"
...     [Date]                  "05-01-2022"
...     [Feature_ID]            "CB007962"
...     [Requirement ID]        "WgNB_SEC_59712,WgNB_SEC_60533, WgNB_SEC_49880, WgNB_SEC_49920"
...     [Config]                "This script requires basic SCF loading."
...     [RunTime Parameters]    "bts_id used is 1599"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"

Variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot



Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops


*** Test Cases ***
[1]CB007962-D_Verify that gNB raises & clears alarm when SoE feature is disabled & enabled for LMP
    Perform Recommissioning     type=param      rat=common     param_path=${SOE_path}  operation=update    value=false
    ...     timeout=300   alias=default
    Verify Alarm        faultid=4654     should_exist=${True}   occurrences=${1}
   Perform Recommissioning     type=param      rat=common     param_path=${SOE_path}  operation=update    value=true
   ...      timeout=300   alias=default
   Verify Alarm        faultid=4654     should_exist=${False}
    [Teardown]  Perform Recommissioning     type=param      rat=common
    ...     param_path=SECADM-1:ethernetPortSecurityEnabled  operation=update    value=true     timeout=300   alias=default

[1]CB007962-D_Verify that gNB shall not have world-readable file permissions
    Check sensitive files should not be world-readable
    Verify the Removal of telnet server binary and supporting files
    Perform Software Download And Update    wft_profile=${num}   package=${build}     activate_sw=True
    ...     update_timeout=1800   wait_for_bts_to_be_ready=600      alias=default
    Check sensitive files should not be world-readable
    Verify the Removal of telnet server binary and supporting files
    ${previous_test_run_status}=    Set Variable    PASS
    Set Suite Variable      ${previous_test_run_status}     ${previous_test_run_status}
[1]CB007962-D_Verify the Removal of telnet server binary and supporting files
    ${second_case_run_status}=  Run Keyword And Ignore Error    Run Keyword If      '${previous_test_run_status}'=='PASS'
    ...     Set Variable    PASS
    ...     ELSE    Set Variable    FAIL
    Should Be Equal     '${second_case_run_status}'     '('PASS', u'PASS')'
    ...     msg=This test case failed since previous test resulted in failure   values=False

***Keywords***
Check sensitive files should not be world-readable
      Setup Remote Access    remote_device=bts    session_type=ssh   alias=default
      FOR    ${file}    IN    @{files_list1}
          ${output1}=      Remote Command Execute    command=ls -lrt ${file}|cut -c 8,9,10
          ${line1}=   Get Line    ${output1}  -2
          Should Be True      '${line1}'=='---'
      END
      FOR    ${file2}    IN    @{files_list2}
          ${output2}=      Execute Interactive Remote Command   command=ls -ld ${file2}
          Should Contain     ${output2}     drwxr-xr-x
      END
      Execute Interactive Remote Command  command=bsh 1:2     alias=default
      FOR    ${file3}    IN    @{baseband_files}
         ${output}=      Execute Interactive Remote Command      command=ls -lrt ${file3}|cut -c 8,9,10    alias=default
         ${line}=    Get Line    ${output}   -2
         Should Be True      '${line}'=='---'
      END

Verify the Removal of telnet server binary and supporting files
    Execute command on GNB    find / -name telnetd*
    Should Not Match      ${stderr}    *telnetd*
    Execute command on GNB    find / -name xinetd*
    Should Not Match      ${stderr}    *xinetd*
    Execute command on GNB   busybox telnetd --help
    Should Contain  ${stderr}   telnetd: applet not found
    Execute command on GNB   busybox xinetd --help
    Should Contain      ${stderr}   xinetd: applet not found
