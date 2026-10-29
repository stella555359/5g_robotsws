*** Settings ***

Documentation
...   This is a test suite used in KW resourceCI running against real classical TL.
...   It verifies proper function of KWs in bsr_package_installation.robot for classical deployments.

Library     OperatingSystem

Resource    ../bsr_package_installation.robot
Resource    ../testline.robot

Test Setup      Setup Logs And Traces


*** Test Cases ***
Test BSR Downloader
    [TAGS]   BSR
    ${user_token}   bsr_package_installation.Get Credentials For Espoo1 Artifactory
    ...   user=ca_ute_artifactory_readonly
    BsrDownloader.Download Matching Zips   user=ca_ute_artifactory_readonly   user_token=${user_token}
    ...   file_name_prefix=BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001
    ...   target_dir=${TARGET_DIR}
    OperatingSystem.File Should Exist   ${TARGET_DIR}/BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001.zip
    OperatingSystem.File Should Not Exist   ${TARGET_DIR}/BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip

Test BSR Downloader Authentication Error Case
    [TAGS]   BSR
    Run Keyword And Expect Error   *Authentication failed or access denied*
    ...   BsrDownloader.Download Matching Zips
    ...   user=ca_ute_artifactory_readonly   user_token=${None}
    ...   file_name_prefix=BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001
    ...   target_dir=${TARGET_DIR}

Test BSR Downloader File Not Found Error Case
    [TAGS]   BSR
    ${user_token}   bsr_package_installation.Get Credentials For Espoo1 Artifactory
    ...   user=ca_ute_artifactory_readonly
    Run Keyword And Expect Error   *No ZIP files found matching the prefix*
    ...   BsrDownloader.Download Matching Zips
    ...   user=ca_ute_artifactory_readonly   user_token=${user_token}
    ...   file_name_prefix=NotExistingFile
    ...   target_dir=${TARGET_DIR}

Test Install All BSR Packages Found In SCF
    [TAGS]   BSR
    bsr_package_installation.Install All BSR Packages Found In SCF
    ...   force_zip=BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471


*** Keywords ***
Setup Logs And Traces
    ${target_dir}   testline.Get Test Case Log Directory
    Set Test Variable   ${TARGET_DIR}   ${target_dir}

