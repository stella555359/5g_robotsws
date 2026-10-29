*** Settings ***
Documentation
...   author: Sylwia Swiatkiewicz
...   contact: sergiu.alecu@nokia.com
...   Feature 5GC001546-AA in 5G19A program

Library     String
Library     Process
Library     DateTime
Library     Collections

Library     taf.sbts.oam.coam.admin     WITH NAME   admin_cli

Resource    ./resources/keywords.robot
Resource    ../../resources/pretest_posttest.robot


Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN   SBTS00   SBTS22R4   SBTS23R1    master_classicalbts_all
...   CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CA_BTS_OAM_FMRECOV
#21A_classicalbts  QCP_BTS_OAM    QCD_MN_BTS_OAM    #SBTS21B  SBTS22R1

Suite Setup  Run keywords
...     Suite Preconditions  AND
...     Set mrbtsId and nrbtsId variables  AND
...     Branch or Trunk  AND
...     Run Keyword If  '${sw_version}' == 'SBTS22R3'  Temporary SCF Validation 2

Suite Teardown   Suite Postconditions

*** Test Cases ***
5GC001546_AA_7_Configuration of reporting interval via WebEM
    [Tags]       CIT   CIT__WITH__SBTS00   SBTS22R1   SBTS22R2   SBTS22R3
   [Documentation]
    ...     reportingIntervalPm set for 5mins and checked if collects measurement of ethernetLinkInterval after 5 mins
    [Setup]  Change Time Zone    (GMT+1) Europe/Warsaw
    set test variable    ${counter_id_main}    M51301C
    set test variable    ${numer_of_measurements}    1
    Modify the scf for measurement to be gathered in minute intervals    5min    ${mrbtsId}/MNL-1/MNLENT-1/PMCADM-1    reportingIntervalPm
#    Differences between SBTS00 and SBTS21B Branch
#    Run Keyword If  '${build_flag}' == '${9999}'  Run Keyword
#    ...     Modify the SCF for measurement to be gathered in minute intervals   5min   ${mrbtsId}/TNLSVC-1/PMTNLINT-1   ethernetLinkInterval
#    ...     ELSE  Run Keyword
#    ...     Modify the SCF for measurement to be gathered in minute intervals   5min   ${mrbtsId}/TNLSVC-1/TNL-1/PMTNL-1   ethernetLinkInterval
    Modify the SCF for measurement to be gathered in minute intervals   5min   ${mrbtsId}/TNLSVC-1/PMTNLINT-1   ethernetLinkInterval
    Wait for counter to be gathered after guard peroid   interval=${5}
    Check if counter group is fully collected M51301C1
    ...    counter_id_main=${counter_id_main}   numer_of_measurements=${numer_of_measurements}   interval=5
    PM Wait To Nearest Measurement Period    interval=${5}


5GC001546_AA_5_Configuration of measurement interval for parameters under PMTNL object via WebEM
    [Tags]       CRT
    [Documentation]
    ...    This test case shall check if modifying the reporting interval to 5 min time is working fine in PMTNL tree
    [Setup]  Change Time Zone    (GMT+1) Europe/Warsaw
    set test variable    ${counter_id_main}    M51301C
    set test variable    ${numer_of_measurements}    3
#    Differences between SBTS00 and SBTS21B Branch
#    Run Keyword If  '${build_flag}' == '${9999}'  Run Keyword
#    ...     Modify the SCF for measurement to be gathered in minute intervals   5min   ${mrbtsId}/TNLSVC-1/PMTNLINT-1   ethernetLinkInterval
#    ...     ELSE  Run Keyword
#    ...     Modify the SCF for measurement to be gathered in minute intervals   5min   ${mrbtsId}/TNLSVC-1/TNL-1/PMTNL-1   ethernetLinkInterval
    Modify the SCF for measurement to be gathered in minute intervals   5min   ${mrbtsId}/TNLSVC-1/PMTNLINT-1   ethernetLinkInterval
    Wait for counter to be gathered after guard peroid   interval=${15}
    Check if counter group is fully collected M51301C1
    ...    counter_id_main=${counter_id_main}   numer_of_measurements=${numer_of_measurements}   interval=15
    PM Wait To Nearest Measurement Period    interval=${15}


#5GC001546_AA_1_Configuration of measurement interval for parameters under NRPMRNL object via WebEM
#    [Tags]       CRT
#    [Documentation]
#    ...    This test case shall check if modifying the reporting interval to 5 min time is working fine in NRPMRNL tree
#    [Setup]  Change Time Zone    (GMT+1) Europe/Warsaw
#    set test variable    ${counter_id_main}    M55110C000
#    set test variable    ${numer_of_measurements}    3
#    Modify the SCF for measurement to be gathered in minute intervals    5min    ${nrbtsId}/NRPMRNL-1    miNrX2CB
#    Wait for counter to be gathered after guard peroid   interval=${15}
#    Check if counter group is fully collected
#    ...   counter_id_main=${counter_id_main}    numer_of_measurements=${numer_of_measurements}    interval=15
#    PM Wait To Nearest Measurement Period    interval=${15}

