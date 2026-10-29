*** Settings ***
Suite Setup       Common Suite Setup
Test Setup    Common Test Setup 2
Test Teardown    Common Test Teardown 2
Suite Teardown    Common Suite Teardown 2
Force Tags        CRT    RAN_5G_TDD
...               FR1    Owner_yuema    PRI-High
...               SBTS00    SBTS23R1    SBTS22R4    RAN_5G
...               CLOUD_5G_I_BOO_AP_LOO_SANSA_ECPRI_CMWV_TDD
Resource          ./../CUDU_L2/common_setup_teardown.robot
Library      ../python/ta_kiss_gnb/    WITH NAME    ta_kiss_gnb
*** Variables ***
${GNB_ID}              2
${CELL_ID}             1
${BEARER_ID}           2
@{LOG_NAME_LIST}       btslog    snapshot
${COUNT}               0
${WTS_CFG}           basic_setup.cfg
${scf}               SCF_1.xml
${2cell_iphy}    iphy.xml
${CELL1_SIB}    eNB 2 cell 1: SystemInformationBlockType2-NR updated

*** Test Cases ***
CNI-72687-ET-A001_Verify_PM_Counter_with_different_CSI-RS_numbers_+_specific_CRI_for_every_UE
    [Tags]    case1
    Start WTS And Check OnAir
    Set CSI Override Testmode
    Attach SA UE    UE_ID=1    dl_tp_set=175    ul_tp_set=20
    Attach SA UE And Change Mode    UE_ID=2    dl_tp_set=175    ul_tp_set=20     profile_id=4
    Attach SA UE And Change Mode    UE_ID=3    dl_tp_set=175    ul_tp_set=20     profile_id=1
    Attach SA UE And Change Mode    UE_ID=4    dl_tp_set=175    ul_tp_set=20     profile_id=4
    Attach SA UE And Change Mode    UE_ID=5    dl_tp_set=175    ul_tp_set=20     profile_id=1
    Attach SA UE And Change Mode    UE_ID=6    dl_tp_set=175    ul_tp_set=20     profile_id=2
    Attach SA UE And Change Mode    UE_ID=7    dl_tp_set=175    ul_tp_set=20     profile_id=3
    Wait For New PM Counter Period
    Get And Check PM Counters For CSI Reports

CNI-72687-ET-A002_Verify_PM_Counter_in_pararrel_with_different_CSI-RS_numbers_+_various_CRI_for_every_UE
    [Tags]    case2
    Reboot TL And Check Configured
    Start WTS And Check OnAir
    Set CSI Override Varying Testmode
    Attach SA UE And Change Mode    UE_ID=2    dl_tp_set=175    ul_tp_set=20     profile_id=5
    Attach SA UE And Change Mode    UE_ID=4    dl_tp_set=175    ul_tp_set=20     profile_id=6
    Wait For New PM Counter Period
    Get And Check PM Counters For CSI Reports Varting CRI

*** Keywords ***
Wait For New PM Counter Period
    ${time}=    ta_kiss_gnb.Get Counter File Remaining Time    counter_refresh_period=5min
    Log To Console    to reach next pm counter update time, need to wait ${time}...
    Sleep    ${time}    wait for pm counter file updated.

Get And Check PM Counters For CSI Reports
    [Documentation]    reportingIntervalPm=5min
    ${time}=    ta_kiss_gnb.Get Counter File Remaining Time    counter_refresh_period=5min
    Log To Console    to reach next pm counter update time, need to wait ${time}...
    Sleep    ${time}    wait for pm counter file updated.
    Sleep    20s    wait pm counter file generated stable.
    ${file_name}=    ta_kiss_gnb.Download Latest Pmcounter    ${OUTPUT_DIR}/test_pmcounter.gz
    ${CSI_reports_1_CSI-RS}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55308C22001    cell_id=1
    ${CSI_reports_2_CSI-RS_CRI_0}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55308C22002    cell_id=1
    ${CSI_reports_2_CSI-RS_CRI_1}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55308C22003    cell_id=1
    ${CSI_reports_4_CSI-RS_CRI_0}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55308C22004    cell_id=1
    ${CSI_reports_4_CSI-RS_CRI_1}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55308C22005    cell_id=1
    ${CSI_reports_4_CSI-RS_CRI_2}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55308C22006    cell_id=1
    ${CSI_reports_4_CSI-RS_CRI_3}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55308C22007    cell_id=1
    Should Be True    ${CSI_reports_1_CSI-RS}>1800
    Should Be True    ${CSI_reports_2_CSI-RS_CRI_0}>1800
    Should Be True    ${CSI_reports_2_CSI-RS_CRI_1}>1800
    Should Be True    ${CSI_reports_4_CSI-RS_CRI_0}>1800
    Should Be True    ${CSI_reports_4_CSI-RS_CRI_1}>1800
    Should Be True    ${CSI_reports_4_CSI-RS_CRI_2}>1800
    Should Be True    ${CSI_reports_4_CSI-RS_CRI_3}>1800

Get And Check PM Counters For CSI Reports Varting CRI
    [Documentation]    reportingIntervalPm=5min
    ${time}=    ta_kiss_gnb.Get Counter File Remaining Time    counter_refresh_period=5min
    Log To Console    to reach next pm counter update time, need to wait ${time}...
    Sleep    ${time}    wait for pm counter file updated.
    Sleep    20s    wait pm counter file generated stable.
    ${file_name}=    ta_kiss_gnb.Download Latest Pmcounter    ${OUTPUT_DIR}/test_pmcounter.gz
    ${CSI_reports_2_CSI-RS_CRI_0}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55308C22002    cell_id=1
    ${CSI_reports_2_CSI-RS_CRI_1}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55308C22003    cell_id=1
    ${CSI_reports_4_CSI-RS_CRI_0}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55308C22004    cell_id=1
    ${CSI_reports_4_CSI-RS_CRI_1}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55308C22005    cell_id=1
    ${CSI_reports_4_CSI-RS_CRI_2}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55308C22006    cell_id=1
    ${CSI_reports_4_CSI-RS_CRI_3}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55308C22007    cell_id=1
    Should Be True    ${CSI_reports_2_CSI-RS_CRI_0}>1000 and ${CSI_reports_2_CSI-RS_CRI_1}>100
    Should Be True    ${CSI_reports_4_CSI-RS_CRI_0}>1000 and ${CSI_reports_4_CSI-RS_CRI_1}>200
    Should Be True    ${CSI_reports_4_CSI-RS_CRI_2}>200 and ${CSI_reports_4_CSI-RS_CRI_3}>200

Display Egate Status
    ${output}=    ute_wtssim.Execute Egate Command    cmd=sim_state_disp    return_output=True
    ${output}=    ute_wtssim.Execute Egate Command    cmd=ue_summary    return_output=True

Common Suite Setup
    Suite Setup Update GNB    scf_file=${CURDIR}/${scf}    iphy_file=${CURDIR}/${2cell_iphy}
    Suite Setup Copy WTS Config Files From Local    ${CURDIR}
    Modify UTE SCTP Timeout
    Modify AP SCTP Timeout
    Configure UTE ETH3

Start WTS And Check OnAir
    [Documentation]    This keyword is to start WTS, wait for onAir
    Start UTE WTS
    Cell1 UE SIB Decoding Should Be Successful
    Verify Cell Setup
    Display Egate Status
    Sleep    60s    wait for 2 cells' sib all come up...

Cell1 UE SIB Decoding Should Be Successful
    ta5g_egate.Wait For Egate Console Output    expected_message=${CELL1_SIB}    timeout=300s
    Log    sib_decoding_is_ok

Set CSI Override Testmode
    ute_wtssim.Execute Egate Command    cmd=csi_override_testmode_nr profile_id\=4 cri\=0
    ute_wtssim.Execute Egate Command    cmd=csi_override_testmode_nr profile_id\=1 cri\=1
    ute_wtssim.Execute Egate Command    cmd=csi_override_testmode_nr profile_id\=2 cri\=2
    ute_wtssim.Execute Egate Command    cmd=csi_override_testmode_nr profile_id\=3 cri\=3

Set CSI Override Varying Testmode
    ute_wtssim.Execute Egate Command    cmd=csi_override_testmode_nr profile_id\=5 cri\=0\,1 cri_mode\=varying cri_period\=2
    ute_wtssim.Execute Egate Command    cmd=csi_override_testmode_nr profile_id\=6 cri\=0\,1\,2\,3 cri_mode\=varying cri_period\=2

Attach SA UE
    [Arguments]    ${UE_ID}    ${dl_tp_set}=175    ${ul_tp_set}=175
    SA 5G Attach    ue_id=${UE_ID}
    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
    SA 5G PDU Session Setup    ue_id=${UE_ID}
    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=1
    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${ul_tp_set}    trf_id=1
#    Wait Until Keyword Succeeds    3min    5s    SA UE Check Throughput    ${UE_ID}    ${dl_tp_threshold}    ${ul_tp_threshold}
#    SA Stop Data Traffic Internal    ${UE_ID}    pdu_id=1
#    [Teardown]    SA 5G Detach    ue_id=${UE_ID}

Attach SA UE And Change Mode
    [Arguments]    ${UE_ID}    ${dl_tp_set}=175    ${ul_tp_set}=175     ${profile_id}=3
    Attach SA UE    UE_ID=${UE_ID}    dl_tp_set=175    ul_tp_set=20
    ute_wtssim.Execute Egate Command    cmd=ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=${profile_id}
