*** Settings ***

Documentation   This is a Robot Test Suite for subfeature 5GC000480-B 'RAC for the SgNB addition and release
...             cases with parameters and counters for basic call' testing
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
#-------------------------------------------------------------------------------------------------------------
Library         taf.config.wts    WITH NAME    wts
Resource        ../keywordbook-480.robot
Resource        ../keywordbook-480-resourceUsage.robot
Resource        ../../resources/SQD60/keywords-tracing.robot
Resource        ../../../resources/Common/reporting.robot



Suite Setup     Suite Setup 5GC000480-B
Suite Teardown  Suite Teardown 5GC000480-B

*** Variables ***

${cell_distName}           NRCELL-1
${nrcellgrp0_distName}     NRCELLGRP-0

${logs_collected}          False
${TCPDUMP_RUNNING}         false


*** Test Cases ***

5GC000480_B_Successful_SgNB_Addition_with_RAC_and_UEs_in_same_cell
    [Documentation]    This Test Scenario verifies the counters M55114C00001, M55114C00002, M55114C00003,
    ...                M55114C00004, M55114C00006, M55114C00007, M55114C00020, M55115C00002, M55115C00003
    [Tags]    succ

    [Setup]    Perform Preconditions of Test Scenario 480-B

    prepare counters and expected values succCase
    update parameter values with delta commissioning

    get resources taken before_test

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    Log To Console    \nwaiting for new measurement period to start
    wait for next measurement interval

    sleep   2s

    Attach and detach

    Log To Console    \nwaiting for measurement period to stop
    wait for next measurement interval

    Run Keyword And Warn On Failure         dcap tracing stop
    get resources taken after_test

    collect pm file and verify counter values

    Verify wireshark succ
    no check of resource postTimerWheel
    verify resource usage


    [Teardown]    Perform Postconditions of Test Scenario 480-B




5GC000480_B_Unsuccessful_SgNB_Addition_with_RAC_due_to_no_user_capacity
    [Documentation]    This Test Scenario verifies the counters M55114C00001, M55114C00002, M55114C00003,
    ...                M55114C00004, M55114C00006, M55114C00007, M55114C00020, M55115C00002, M55115C00003

    [Tags]    NoUser

    [Setup]    Perform Preconditions of Test Scenario 480-B

    prepare counters and expected values noUser
    update parameter values with delta commissioning

    get resources taken before_test

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    Log To Console    \nwaiting for new measurement period to start
    wait for next measurement interval

    sleep   2s

    Attach NoUser and detach

    Log To Console    \nwaiting for measurement period to stop
    wait for next measurement interval

    Run Keyword And Warn On Failure         dcap tracing stop
    get resources taken after_test

    collect pm file and verify counter values

    Verify wireshark noUser noBearer
    no check of resource postTimerWheel
    verify resource usage


    [Teardown]    Perform Postconditions of Test Scenario 480-B



5GC000480_B_Unsuccessful_SgNB_Addition_with_RAC_due_to_no_bearer_capacity
    [Documentation]    This Test Scenario verifies the counters M55114C00001, M55114C00002, M55114C00003,
    ...                M55114C00004, M55114C00006, M55114C00007, M55114C00020, M55115C00002, M55115C00003
    [Tags]    NoBearer    AP_REG

    [Setup]    Perform Preconditions of Test Scenario 480-B

    prepare counters and expected values noBearer
    update parameter values with delta commissioning

    get resources taken before_test

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    Log To Console    \nwaiting for new measurement period to start
    wait for next measurement interval

    sleep   2s

    Attach multiBearer and detach

    Log To Console    \nwaiting for measurement period to stop
    wait for next measurement interval

    Run Keyword And Warn On Failure         dcap tracing stop
    get resources taken after_test

    collect pm file and verify counter values

    Verify wireshark noUser noBearer
    no check of resource postTimerWheel
    verify resource usage


    [Teardown]    Perform Postconditions of Test Scenario 480-B


*** Keywords ***
Suite Setup 5GC000480-B
    [Documentation]    [PRIVATE]    suite setup for 480-B
    ...       :Autor: Sylvia Schneider
    Create Test Suite Folders
    Get test variables and upload start SCF
    UTE Cloud Workaround
    Store Current WTS Config
    Update wts file for TC480B
    Upload Customized WTS Config    config_path=${resultBaseDir}/basic_wts_480B.cfg


Perform Preconditions of Test Scenario 480-B
    [Documentation]    [PRIVATE]    suite setup for 480-B
    ...       :Autor: Sylvia Schneider
    Create a Test Scenario Folder
    Bring Airphone TL to on Air status
    get_enb_data_from_simulated_eNB


Perform Postconditions of Test Scenario 480-B
    [Documentation]    [PRIVATE]    postconditions for 480-B
    ...       :Autor: Sylvia Schneider
    Run Keyword And Continue On Failure   Set SCOUT TC ID for Reporting
    Run Keyword And Continue On Failure   stop tcpdump trace     wireshark_store=${resultDir}/wireshark_test_teardown.pcap
    Run Keyword And Continue On Failure   end dcap tracing and collect traces
    Run Keyword And Continue On Failure   Teardown Egate Connection for Airphone
    Run Keyword And Continue On Failure   Teardown Edaemon Connection for Airphone    edaemon_alias=edaemon
    IF    '${TEST STATUS}'=='FAIL'    Collect snapshot and sos report data     ${resultDir}


Suite Teardown 5GC000480-B
    IF    '${SUITE STATUS}'=='FAIL' and '${logs_collected}'=='False'    Collect snapshot and sos report data   ${resultBaseDir}
    Reload Stored WTS Config


Update wts file for TC480B
    [Documentation]    [PRIVATE]    update wts cfg file
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts cfg
    ${wtsconfig}   Get WTS Config    target_dir=${resultBaseDir}
    wts.Load wts cfg             ${wtsconfig}
    wts.Insert              set_bearer id=3 ue=103 qci=8   after    set_bearer id=2 ue=103
    wts.Insert              set_bearer id=4 ue=103 qci=7   after    set_bearer id=3 ue=103
    wts.Insert              set_bearer id=5 ue=103 qci=6   after    set_bearer id=4 ue=103
    wts.Save wts cfg              ${resultBaseDir}/basic_wts_480B.cfg
    Log To Console    \nwts cfg saved as ${resultBaseDir}/basic_wts_480B.cfg


prepare counters and expected values succCase
    [Documentation]    [PRIVATE]    define values for counters and parameters successful case
    ...       :Autor: Sylvia Schneider
    set test variable    @{list_of_used_UEs}          101    102    103

    set test variable    @{M55114C00001}    SGNB_NSA_ADMISSION_REQ          3    ${cell_distName}   RACCU
    set test variable    @{M55114C00002}    SGNB_NSA_ADMISSION_SUCC         3    ${cell_distName}   RACCU
    set test variable    @{M55114C00003}    SGNB_NSA_NGBR_DRB_REQ           3    ${cell_distName}   RACCU
    set test variable    @{M55114C00004}    SGNB_NSA_NGBR_DRB_SUCC          3    ${cell_distName}   RACCU
    set test variable    @{M55114C00006}    SGNB_NSA_RAC_REJ_DUE_TO_NSA     0    ${cell_distName}   RACCU
    set test variable    @{M55114C00007}    SGNB_NSA_RAC_REJ_DUE_TO_NGBR    0    ${cell_distName}   RACCU
    set test variable    @{M55114C00020}    SGNB_CU_NSA_ADMISSION_UNSUCC    0    ${cell_distName}   RACCU
    set test variable    @{M55115C00002}    SGNB_DU_NSA_ADMISSION_REQ       3    ${cell_distName}   RACDU
    set test variable    @{M55115C00003}    SGNB_DU_NSA_ADMISSION_SUCC      3    ${cell_distName}   RACDU
    set test variable    ${maxNumOfUsersPerCell}    250
    set test variable    ${maxNumOfSCellAlloc}      250
    set test variable    ${maxNumOfNonGBRBearers}   500
    set test variable    ${maxNumOfUsers}           500

prepare counters and expected values noUser
    [Documentation]    [PRIVATE]    define values for counters and parameters no user case
    ...       :Autor: Sylvia Schneider
    set test variable    @{list_of_used_UEs}          101    102    103

    set test variable    @{M55114C00001}    SGNB_NSA_ADMISSION_REQ          3    ${cell_distName}   RACCU
    set test variable    @{M55114C00002}    SGNB_NSA_ADMISSION_SUCC         2    ${cell_distName}   RACCU
    set test variable    @{M55114C00003}    SGNB_NSA_NGBR_DRB_REQ           3    ${cell_distName}   RACCU
    set test variable    @{M55114C00004}    SGNB_NSA_NGBR_DRB_SUCC          2    ${cell_distName}   RACCU
    set test variable    @{M55114C00006}    SGNB_NSA_RAC_REJ_DUE_TO_NSA     1    ${cell_distName}   RACCU
    set test variable    @{M55114C00007}    SGNB_NSA_RAC_REJ_DUE_TO_NGBR    0    ${cell_distName}   RACCU
    set test variable    @{M55114C00020}    SGNB_CU_NSA_ADMISSION_UNSUCC    1    ${cell_distName}   RACCU
    set test variable    @{M55115C00002}    SGNB_DU_NSA_ADMISSION_REQ       2    ${cell_distName}   RACDU
    set test variable    @{M55115C00003}    SGNB_DU_NSA_ADMISSION_SUCC      2    ${cell_distName}   RACDU
    set test variable    ${maxNumOfUsersPerCell}    2
    set test variable    ${maxNumOfSCellAlloc}      2
    set test variable    ${maxNumOfNonGBRBearers}   3
    set test variable    ${maxNumOfUsers}           3


prepare counters and expected values noBearer
    [Documentation]    [PRIVATE]    define values for counters and parameters no bearer case
    ...       :Autor: Sylvia Schneider
    set test variable    @{list_of_used_UEs}          101    103

    set test variable    @{M55114C00001}    SGNB_NSA_ADMISSION_REQ          2    ${cell_distName}   RACCU
    set test variable    @{M55114C00002}    SGNB_NSA_ADMISSION_SUCC         1    ${cell_distName}   RACCU
    set test variable    @{M55114C00003}    SGNB_NSA_NGBR_DRB_REQ           4    ${cell_distName}   RACCU
    set test variable    @{M55114C00004}    SGNB_NSA_NGBR_DRB_SUCC          3    ${cell_distName}   RACCU
    set test variable    @{M55114C00006}    SGNB_NSA_RAC_REJ_DUE_TO_NSA     0    ${cell_distName}   RACCU
    set test variable    @{M55114C00007}    SGNB_NSA_RAC_REJ_DUE_TO_NGBR    1    ${cell_distName}   RACCU
    set test variable    @{M55114C00020}    SGNB_CU_NSA_ADMISSION_UNSUCC    1    ${cell_distName}   RACCU
    set test variable    @{M55115C00002}    SGNB_DU_NSA_ADMISSION_REQ       1    ${cell_distName}   RACDU
    set test variable    @{M55115C00003}    SGNB_DU_NSA_ADMISSION_SUCC      1    ${cell_distName}   RACDU
    set test variable    ${maxNumOfUsersPerCell}    2
    set test variable    ${maxNumOfSCellAlloc}      2
    set test variable    ${maxNumOfNonGBRBearers}   3
    set test variable    ${maxNumOfUsers}           3


update parameter values with delta commissioning
    [Documentation]    [PRIVATE]    execute delta commissioning with predefined values
    ...       :Autor: Sylvia Schneider
    set test variable    ${measurement_period_in_min}      5

    ${param_list}     Create List    @{EMPTY}
    FOR    ${obj}     ${param}     ${value}     IN
    ...    ${bts_distName}/${cell_distName}          maxNumOfUsersPerCell     ${maxNumOfUsersPerCell}
    ...    ${bts_distName}/${cell_distName}          maxNumOfSCellAlloc       ${maxNumOfSCellAlloc}
    ...    ${bts_distName}/${nrcellgrp0_distName}    maxNumOfNonGBRBearers    ${maxNumOfNonGBRBearers}
    ...    ${bts_distName}/${nrcellgrp0_distName}    maxNumOfUsers            ${maxNumOfUsers}
    ...    ${pmcadm_distName}                        reportingIntervalPm      ${measurement_period_in_min}min
    ...    ${bts_distName}/NRPMRNL-1                 miNrRacCu                ${measurement_period_in_min}min
    ...    ${bts_distName}/NRPMRNL-1                 miNrRacDu                ${measurement_period_in_min}min
    ...    ${bts_distName}                           actMultiDrbNSA           true
       ${param_dict}      create dictionary
       ...    dist_name    ${obj}
       ...    parameter    ${param}
       ...    value        ${value}
       Append To List   ${param_list}     ${param_dict}
    END
    json delta commissioning coam        ${param_list}


Start tcpdump trace
    [Documentation]    [PRIVATE]    start tcpdump trace
    ...       :Autor: Sylvia Schneider
    Log To Console    \ntcpdump started
    Start Tcpdump on TestPc
    ...  options=-i any sctp or icmp
    ...  collector=dump_testpc
    Set suite variable      ${TCPDUMP_RUNNING}    true


Stop tcpdump trace
    [Documentation]    [PRIVATE]    stop tcpdump trace
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_store}=${resultDir}/wireshark.pcap
    IF    '${TCPDUMP_RUNNING}'=='false'   RETURN
    ${tcpdump_file}    Stop Tcpdump on TestPc
    ...  collector=dump_testpc
    ...  target_dir=${resultDir}
    Run Keyword And Continue On Failure  Move File    ${tcpdump_file}    ${wireshark_store}
    Log To Console    \ntcpdump stopped
    Set suite variable      ${TCPDUMP_RUNNING}    false


Attach and detach
    [Documentation]    [PRIVATE]    start tcpdump, attach UEs from list, stop tcpdump - successful case
    ...       :Autor: Sylvia Schneider
    Start tcpdump trace
    sleep     2s
    FOR    ${actual_UE}    IN    @{list_of_used_UEs}
        Attach UE    ${actual_UE}
        Sleep    3s
    END
    Log To Console    \nwaiting 45 seconds
    sleep    45s
    Detach UEs
    Stop tcpdump trace


Attach NoUser and detach
    [Documentation]    [PRIVATE]    start tcpdump, attach UEs from list, stop tcpdump - no user case
    ...       :Autor: Sylvia Schneider
    Start tcpdump trace
    sleep     2s
    ${UE_succ}   copy list    ${list_of_used_UEs}
    ${UE_unsucc}   Remove From List    ${UE_succ}    -1
    FOR    ${actual_UE}    IN    @{UE_succ}
        Attach UE    ${actual_UE}
        Sleep    3s
    END
    Log To Console    \nAttach UE ${UE_unsucc} with unsuccessful gNB addition
    Attach UE unsuccessful gNB addition   UE=${UE_unsucc}
    Log To Console    \nwaiting 45 seconds
    sleep    45s
    Detach UEs
    Stop tcpdump trace


Attach multiBearer and detach
    [Documentation]    [PRIVATE]    start tcpdump, attach UEs from list, stop tcpdump - no bearer case
    ...       :Autor: Sylvia Schneider
    Start tcpdump trace
    sleep     2s
    Attach UEs noBearerCapacity
    Log To Console    \nwaiting 45 seconds
    sleep     45s
    Detach UEs
    sleep     2s
    Stop tcpdump trace


Attach UEs noBearerCapacity
    [Documentation]    [PRIVATE]    attach UEs - no bearer case
    ...       :Autor: Sylvia Schneider
    Log To Console    \nAttach UE103 with 3 bearer
    run keyword and ignore error    ute_wtssim.execute egate command and wait for data    cmd=enb_param id=1 endc_capable_qci=all    alias=ap_egate
    Sleep    2s
    Attach UE to LTE    ue_id=103
    Sleep    3s
    ute_wtssim.execute egate command and wait for data    cmd=bearer_add ue=103 id=3 filter=0 precedence=0    alias=ap_egate
    Sleep    3s
    ute_wtssim.execute egate command and wait for data    cmd=bearer_add ue=103 id=4 filter=0 precedence=1    alias=ap_egate
    Sleep    3s
    Trigger LTE-NR dual connectivity for bearers    ue_id=103    bearer_id=2,3,4
    Sleep    3s

    Log To Console    \nAttach UE101 with 1 bearer with unsuccessful gNB addition
    Attach UE unsuccessful gNB addition   UE=101


Detach UEs
    [Documentation]    [PRIVATE]    detach UEs from list
    ...       :Autor: Sylvia Schneider
    FOR    ${actual_UE}    IN    @{list_of_used_UEs}
        Detach UE    ${actual_UE}
        Sleep    3s
    END


collect pm file and verify counter values
    [Documentation]    [PRIVATE]    upload pm file and verify counter values
    ...       :Autor: Sylvia Schneider
    Sleep     30s
    Collect PM Counters

    ${parsed_xml}    parse xml    ${pmCounter_xml_file}

    &{dict}    Create Dictionary    M55114C00001    ${M55114C00001}    M55114C00002    ${M55114C00002}    M55114C00003    ${M55114C00003}
    ...                             M55114C00004    ${M55114C00004}    M55114C00006    ${M55114C00006}    M55114C00007    ${M55114C00007}
    ...                             M55114C00020    ${M55114C00020}    M55115C00002    ${M55115C00002}    M55115C00003    ${M55115C00003}
    Log Dictionary    ${dict}
    @{dict_keys}    Get Dictionary Keys    ${dict}

    FOR    ${counter}    IN     @{dict_keys}
         @{counterList}    Get From Dictionary    ${dict}    ${counter}
         Verify Counter    ${counter}    ${counterList}    ${parsed_xml}
    END


Verify wireshark succ
    [Documentation]    [PRIVATE]    verify messages for successful case
    ...       :Autor: Sylvia Schneider
    ${filter_SgNBAdditionRequest}              get from dictionary    ${x2ap}      SgNBAddReq_and_SgNBAddReqAck
    ${filter_SgNBReconfigurationComplete}      get from dictionary    ${x2ap}      SgNBReconfCompl
    ${filter_SgNBReleaseRequestAcknowledge}    get from dictionary    ${x2ap}      SgNBrelReq_and_SgNBRelReqAck
    ${filter_UEContextRelease}                 get from dictionary    ${x2ap}      UEContRel

    FOR   ${message}   IN
    ...   SgNBAdditionRequest
    ...   SgNBReconfigurationComplete
    ...   SgNBReleaseRequestAcknowledge
    ...   UEContextRelease
       Log to console    \nverify 3 ${message} present
       ${msg}     Run     tshark -r ${resultDir}/wireshark.pcap -Y "(${filter_${message}})&&(ip.src==${enb_ip})" | wc -l
       Run Keyword And Continue On Failure   Should Be True    ${msg}==${3}
       ...     Wrong number of ${message} messages
    END


Verify wireshark noUser noBearer
    [Documentation]    [PRIVATE]    verify messages for no user and no bearer cases
    ...       :Autor: Sylvia Schneider
    Log to console    \nverify SgNBAdditionRequestReject with cause no-radio-resources-available-in-target-cell present
    set test variable    ${wireshark_xml}             ${resultDir}/X2.xml
    setup tshark    eth1
    read_pcap_and_save_to_file
    ...   filename=${wireshark_xml}
    ...   packet_filter=x2ap
    ...   output_type=pdml
    ...   pcap_file_path=${resultDir}/wireshark.pcap
    ${pdml_xml}    parse xml    ${wireshark_xml}
    ${xpath_param}       get from dictionary    ${xpath_vars_wireshark}    SgNBAdditionRequestReject_radioNetwork
    Run Keyword And Continue On Failure   Element Attribute should match    ${pdml_xml}
    ...    showname
    ...    *no-radio-resources-available-in-target-cell*
    ...    xpath=${xpath_param}
    [Teardown]    teardown tshark
