*** Settings ***
Documentation
...   author: winnie he
...   contact: winnie.he@nokia-sbell.com
...   Description: this is one reference case template, purpose for unified style.

Resource    ../RRM_Common_Resource.robot

Suite Setup            Common Suite Setup For RRM
Suite Teardown         Common Suite Teardown For RRM
Test Setup             Common Test Setup For RRM
Test Teardown          Common Test Teardown For RRM

Force Tags        CRT/CIT/CDRT     #Tag Item
...      RAN_5G                    #Product [RAN_5G]
# ...      CLOUD_5G_CLASSICAL_2xANDROID_ASIBL_ABIAB1_ASIBR_ABILB1_AEQE_ENB   #TLtype, it is for auto trigger by ute cloud
...      SBTS00                   # it is for auto trigger by ute cloud with the release
# ...      STATE_SKIP_AGENT         # it is for auto trigger by ute cloud with gnb state
...      RAN_PZ_HAZ_1             #Competence Area
...      RAN_PZ_HAZ1_SG07_ST_RRM  #Organization
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]


Test Timeout    30 minutes

*** Variables ***
#reduce global paramter as possilbe and automatically got from gNB or __init__
@{Ohter_Allow_Alarms}

*** Test Cases ***
#test case name should be same with qc case name without space and special characters
Test_DCAP_Keyword
    [Documentation]
    ...    author: winnie.he@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    04.08.2021,winnie.he@nokia-sbell.com,case template draft
    Log    Test_DCAP_Keyword
    # dcap.Connect To    bts_s1_ip=10.108.151.44
    # ...    mrBtsId=${5671}
    # ...    bts_type=lte
    # ...    url_ip=10.109.2.184
    # ...    alias=dcap_test
    # ${trace_profile}    dcap.Get Trace Profile Id List    connection=dcap_test
    # dcap.Start Trace    trace_profile=${trace_profile[0]}
    # ...    tag=robot_test    connection=dcap_test
    # sleep    30s
    # dcap.Stop Trace    connection=dcap_test
    # dcap.Get Result File    target_dir=${TEST_LOG_DIRECTORY}     file_name=dcap_log.zip
    # ...    connection=dcap_test
    # dcap.Unzip Result File Return Paths    zipfilepath=${TEST_LOG_DIRECTORY}/dcap_log.zip
    # ...    connection=dcap_test
