*** Settings ***
Documentation    Test case UUF with security part - nmap, certificates and IPSEC

Resource    ../Resources/Resources.robot
Resource    ../../../common_resources/UUF/upgrade.robot
Library     taf/rfrl/csv4all/CSV4AllTestCases.py

*** Keywords ***
Upgrade_with_Nmap
    Prelimitary upgrade
    Run Keyword and Continue on Failure    Logs Before Security UUF Test
    Run Keyword and Continue on Failure    Nmap
    Run Keyword and Continue on Failure
    ...   Logs After Security UUF Test    after_upgrade    ${OUTPUT_DIR}/${TEST_NAME}/syslog/syslog_after_upgrade.tar.gz
    Rollback test
    Run Keyword and Continue on Failure    Logs Before Security UUF Test
    Run Keyword and Continue on Failure    Nmap
    Run Keyword and Continue on Failure
    ...   Logs After Security UUF Test    after_rollback   ${OUTPUT_DIR}/${TEST_NAME}/syslog/syslog_after_rollback.tar.gz

Upgrade with IPSEC
    Run Keyword and Continue on Failure    IPSEC
    Prelimitary upgrade
    Run Keyword and Continue on Failure    Checking IPSEC Connection
    Rollback test
    Run Keyword and Continue on Failure    Checking IPSEC Connection

Upgrade_with_Certificates
    Prelimitary upgrade
    Run Keyword and Continue on Failure    Logs Before Security UUF Test
    Run Keyword and Continue on Failure    Certificates
    Run Keyword and Continue on Failure
    ...   Logs After Security UUF Test    after_upgrade    ${OUTPUT_DIR}/${TEST_NAME}/syslog/syslog_after_upgrade.tar.gz
    Rollback test
    Run Keyword and Continue on Failure    Logs Before Security UUF Test
    Run Keyword and Continue on Failure    Certificates
    Run Keyword and Continue on Failure
    ...   Logs After Security UUF Test    after_rollback   ${OUTPUT_DIR}/${TEST_NAME}/syslog/syslog_after_rollback.tar.gz

Upgrade with Permissions
    FOR    ${i}    IN RANGE    0    15
        Log   Loop no ${i}   console=true
        Prelimitary upgrade
        Permissions
        Rollback test
        Permissions
    END

Upgrade_with_Security
    Prelimitary upgrade
    Run Keyword and Continue on Failure    Logs Before Security UUF Test
    Run Keyword and Continue on Failure    Nmap
    Run Keyword and Continue on Failure    Certificates
    Run Keyword and Continue on Failure
    ...   Logs After Security UUF Test    after_upgrade    ${OUTPUT_DIR}/${TEST_NAME}/syslog/syslog_after_upgrade.tar.gz
    Rollback test
    Run Keyword and Continue on Failure    Logs Before Security UUF Test
    Run Keyword and Continue on Failure    Nmap
    Run Keyword and Continue on Failure    Certificates
    Run Keyword and Continue on Failure
    ...   Logs After Security UUF Test    after_rollback   ${OUTPUT_DIR}/${TEST_NAME}/syslog/syslog_after_rollback.tar.gz
