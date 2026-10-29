*** Settings ***
Documentation    ...
#Resource    ./../CUDU_L2/common_setup_teardown.robot
#Library      ../python/ta_kiss_gnb/    WITH NAME    ta_kiss_gnb
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${DELTA_FILE}
#...               AND    Suite Setup Copy WTS Config Files From QT
#Test Setup    Common Test Setup 2
#Test Teardown    Common Test Teardown
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_LO_AP_LO_NSA_FS_ECPRI_MMWV_TDD    CIT    RAN_5G    RAN_5G_TDD
#...               SBTS00    SBTS23R1    SBTS22R4    SBTS22R2    SBTS22R3    CDRT
#
#*** Variables ***
#${SCF_PATH}    ${CURDIR}/config
#${DELTA_FILE}          delta.json
#${UE_ID}               11
#${PROFILE_ID}          1
#${GNB_ID}              2
#${CELL_ID}             1
#${BEARER_ID}           2
#@{LOG_NAME_LIST}       btslog    snapshot
#
#*** Test Cases ***
#5GC001127_B_4003_Single UE scheduling in analog BF system 1beam without carrier aggregation
#    Suite Setup Start WTS And Check OnAir
#    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
#    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
#    NSA Start DL Traffic    ue_id=${UE_ID}    bearer_id=2    trf_id=2    mbps=80
#    NSA Start UL Traffic    ue_id=${UE_ID}    bearer_id=2    trf_id=2    mbps=80
#    Check PM counter
#
#*** Keywords ***
#Check PM counter
#    [Documentation]
#    #<p name="reportingIntervalPm">15min</p>
#    ${time}=    ta_kiss_gnb.Get Counter File Remaining Time    counter_refresh_period=5min
#    Log To Console    to reach next pm counter update time, need to wait ${time}...
#    Sleep    ${time}    wait for pm counter file updated.
#    Sleep    20s    wait pm counter file generated stable.
#    ${file_name}=    ta_kiss_gnb.Download Latest Pmcounter    ${OUTPUT_DIR}/test_pmcounter.gz
#    Log To Console    Check Counter M55314C03009
#    ${DL_PDCP_VOL_RCV_F1}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55314C03009
#    Should Be True    "${DL_PDCP_VOL_RCV_F1}">"0"
#    Log To Console    Check Counter M55314C05009
#    ${UL_PDCP_VOL_SNT_F1}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55314C05009
#    Should Be True    "${UL_PDCP_VOL_SNT_F1}">"0"
