***Settings ***
Documentation
    ...     [Procedure]             "CB010334"
    ...     [Date]                  "25-06-24"
    ...     [Author]                "Sanjay"
    ...     [Commissioning_comment] "[1]CB010334-A_Export_self-test_results_from_WebEM"

variables	   ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot

#Suite Setup       Pre-conditions for testsuite
#Suite Teardown    Post-conditions for test teardown

*** Test Cases ***
[1]CB010334-A_Export_self-test_results_from_WebEM
#Step1 Removing older FIPS report
       Execute command on ENodeB     rm -rf /ffs/run/logs/lfs/selftest/fips_selftest_*.txt
       Execute command on ENodeB     rm -rf /rom/seltTest/fips_selftest_*.txt
##step.2 Activatiing Feature flag for FIPS report generation
       Perform Commissioning       scf_file=${FIPS_true}  verify_bts_status=False     timeout=600
       sleep   600
##Step3 Genearting self test report
       Run        ${Start_Self_Test}
       Run        ${Download_Self_Test_Report}
       Verify Self test report generated in LFS
       Verify Self test report generated in ROM
##Step4 VerIfying both Reports are same
       Compare LFS and ROM Reports
##Step5 Genarating SelfTest report Periodic
#       Set Self Test Interval    120
#       Sleep   180
#       Verify Periodic Self test Report    120

*** Keywords ***
Verify Self test report generated in LFS
    Setup Remote Access         remote_device=bts
    Execute Interactive Remote Command      command=sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129     alias=default
    ${out1}=    Execute Interactive Remote Command      command=ls -l /ffs/run/logs/lfs/selftest/        alias=default
    Log To Console       ${out1}
    Should Match Regexp    ${out1}    fips_selftest_.*\.txt
    Sleep   90

Verify Self test report generated in ROM
    Setup Remote Access         remote_device=bts
    Execute Interactive Remote Command      command=sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129     alias=default
    ${out2}=    Execute Interactive Remote Command      command=ls -l /rom/selfTest       alias=default
    Log To Console       ${out2}
    Should Match Regexp    ${out2}    fips_selftest_.*\.txt
    Sleep   90

Compare LFS and ROM Reports
    Setup Remote Access         remote_device=bts
    Execute Interactive Remote Command      command=sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129     alias=default
    ${out1}=    Execute Interactive Remote Command    command=ls -1 /ffs/run/logs/lfs/selftest/ | grep fips_selftest_    alias=default
    ${out2}=    Execute Interactive Remote Command    command=ls -1 /rom/selfTest | grep fips_selftest_    alias=default

    Log To Console    LFS Output: ${out1}
    Log To Console    ROM Output: ${out2}

    ${file1}=    Split To Lines    ${out1}
    ${file1}=    Get From List    ${file1}    -1

    ${file2}=    Split To Lines    ${out2}
    ${file2}=    Get From List    ${file2}    -1

    Log To Console    LFS Report: ${file1}
    Log To Console    ROM Report: ${file2}

    Should Be Equal As Strings    ${file1}    ${file2}

Set Self Test Interval
    [Arguments]    ${interval}
    Setup Remote Access    remote_device=bts
    Execute Interactive Remote Command
    ...    command=sh admin-cli.sh --bts-username='Nemuadmin' --bts-password='nemuuser' --bts-host='192.168.255.129' --bts-port=443
    ...    --data='{"requestId":1,"parameters":{"name":"configureFIPSTest","parameters":{"interval":${interval}}}}'
    ...    alias=default
    Log To Console    FIPS self-test interval set to ${interval} seconds

Verify Periodic Self test Report
    [Arguments] ${interval}
    Setup Remote Access         remote_device=bts
    Execute Interactive Remote Command      command=sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129     alias=default
    ${periodic_report1}=    Execute Interactive Remote Command    command=ls -1 /ffs/run/logs/lfs/selftest/ | grep fips_selftest_    alias=default
    ${periodic_report2}=    Execute Interactive Remote Command    command=ls -1 /rom/selfTest | grep fips_selftest_    alias=default
    Log To Console    LFS Output: ${periodic_report1}
    Log To Console    ROM Output: ${periodic_report2}

    ${file3}=    Split To Lines    ${periodic_report1}
    ${file3}=    Get From List    ${file3}    -1

    ${file4}=    Split To Lines    ${periodic_report2}
    ${file4}=    Get From List    ${file4}    -1

    Log To Console    LFS Report: ${file3}
    Log To Console    ROM Report: ${file4}

    Should Be Equal As Strings    ${file3}    ${file4}














































































