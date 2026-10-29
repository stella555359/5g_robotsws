*** Settings ***

Documentation   This is a Robot Test Suite for subfeature 5GC000480-G keywords
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
#-------------------------------------------------------------------------------------------------------------
Library         taf.config.wts    WITH NAME    wts
Resource        ../../../resources/Common/reporting.robot


*** Variables ***
${TCPDUMP_RUNNING}         false
${1st_NSA_UE_in_basic_wts}    101
${last_NSA_UE_in_basic_wts}   110
${last_IMSI}                  21645409


*** Keywords ***

Perform Preconditions of Test Scenario
    Create a Test Scenario Folder


Update wts file for TC 480G classical
    [Documentation]    [PRIVATE]    update wts cfg file
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts cfg
    ${wtsconfig}   Get WTS Config    target_dir=${resultBaseDir}
    wts.Load Wts Cfg             ${wtsconfig}

    ${UEs_to_existing}   Evaluate   ${last_NSA_UE_in_basic_wts}-${1st_NSA_UE_in_basic_wts}+1
    ${UEs_to_create}     Evaluate   ${maxNumOfAttaches}-${UEs_to_existing}+1
    FOR   ${index}   IN RANGE   1    ${UEs_to_create}
       ${id}     Evaluate  110+${index}
       ${imsi}   Evaluate   21645409+${index}
       wts.Clone and Modify    set_ue simulated id=110    id=${id} imsi=311:489:${imsi}
       wts.Clone and Modify    ue_param id=110            id=${id}
       wts.Clone and Modify    set_bearer id=2 ue=110     ue=${id} ip=4.7.254.${id}
    END
    wts.Save Wts Cfg             ${resultBaseDir}/basic_wts_480G.cfg
    Log To Console    \nwts cfg saved as ${resultBaseDir}/basic_wts_480G.cfg


prepare counters and expected values
    [Documentation]    [PRIVATE]    prepare counters and expected values
    ...       :Autor: Sylvia Schneider
    Set Test Variable    @{M55114C00001}    SGNB_NSA_ADMISSION_REQ              ${maxNumOfAttaches}        ${cell_distName}   RACCU
    Set Test Variable    @{M55114C00002}    SGNB_NSA_ADMISSION_SUCC             ${maxNumOfAttaches}        ${cell_distName}   RACCU
    Set Test Variable    @{M55114C00003}    SGNB_NSA_NGBR_DRB_REQ               ${maxNumOfAttaches}        ${cell_distName}   RACCU
    Set Test Variable    @{M55114C00004}    SGNB_NSA_NGBR_DRB_SUCC              ${maxNumOfAttaches}        ${cell_distName}   RACCU
    Set Test Variable    @{M55114C00010}    PEAK_NUMBER_OF_NSA_USERS            ${maxNumOfAttaches}        ${cell_distName}   RACCU
    Set Test Variable    @{M55114C00036}    PEAK_NUMBER_OF_NSA_USERS_GR         ${maxNumOfAttaches}        ${cell_distName}   RACCU
    Set Test Variable    @{M55115C00002}    SGNB_DU_NSA_ADMISSION_REQ           ${maxNumOfAttaches}        ${cell_distName}   RACDU
    Set Test Variable    @{M55115C00003}    SGNB_DU_NSA_ADMISSION_SUCC          ${maxNumOfSuccAttaches}    ${cell_distName}   RACDU
    Set Test Variable    @{M55115C00004}    SGNB_DU_NSA_ADMISSION_UNSUCC          1                        ${cell_distName}   RACDU
    Set Test Variable    @{M55115C00005}    SGNB_DU_NSA_ADMISSION_NO_PUCCH        1                        ${cell_distName}   RACDU
    Set Test Variable    ${measurement_period_in_min}      5


Start tcpdump trace
    [Documentation]    [PRIVATE]    start tcpdump trace
    ...       :Autor: Sylvia Schneider
    Log To Console    \ntcpdump started
    Start Tcpdump on TestPc
    ...  options=-i any sctp or icmp
    ...  collector=dump_testpc
    Set Suite Variable      ${TCPDUMP_RUNNING}    true


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
    Set Suite Variable      ${TCPDUMP_RUNNING}    false


Attach many UEs on classical
    Start tcpdump trace
    Log To Console  ${maxNumOfAttaches} UE attaches on LTE with gNB addition
    ${last_UE}    Evaluate   ${maxNumOfSuccAttaches}+${1st_NSA_UE_in_basic_wts}
    FOR   ${index}   IN RANGE   ${1st_NSA_UE_in_basic_wts}    ${last_UE}
        Sleep     1s
        Attach UE    ${index}
    END
    Log To Console  Expect unsuccessful gNB Addition for UE ${last_UE}
    Attach UE unsuccessful gNB addition   UE=${last_UE}
    Sleep     1s
    Stop tcpdump trace


Release all UEs
    ${last_UE}    Evaluate   ${maxNumOfAttaches}+${1st_NSA_UE_in_basic_wts}
    FOR   ${index}   IN RANGE   ${1st_NSA_UE_in_basic_wts}    ${last_UE}
        Sleep     1s
        Detach UE    ${index}
    END


Verify wireshark many attaches
    Log to console    \nverify SgNBAdditionRequestReject with cause no-radio-resources-available present
    ${filter_cause}        Set Variable  x2ap.Cause==0
    setup tshark    eth1
    read_pcap_and_save_to_file
    ...   filename=${resultDir}/X2_cause.xml
    ...   packet_filter=${filter_cause}
    ...   output_type=pdml
    ...   pcap_file_path=${resultDir}/wireshark.pcap
    ${pdml_xml}    Parse Xml    ${resultDir}/X2_cause.xml
    ${xpath_param}       Get From Dictionary    ${xpath_vars_wireshark}    SgNBAdditionRequestReject_radioNetwork
    Run Keyword And Continue On Failure   Element Attribute Should Match    ${pdml_xml}
    ...    showname
    ...    *no-radio-resources-available*
    ...    xpath=${xpath_param}
    [Teardown]    teardown tshark


Perform Postconditions of Test Scenario
    [Documentation]    contains sosreport if testcase fails
    Run Keyword And Continue On Failure   Set SCOUT TC ID for Reporting
    Run Keyword And Continue On Failure   stop tcpdump trace     wireshark_store=${resultDir}/wireshark_test_teardown.pcap
    Run Keyword And Continue On Failure   Teardown Egate Connection for Airphone
    Run Keyword And Continue On Failure   Teardown Edaemon Connection for Airphone    edaemon_alias=edaemon
    IF    '${TEST STATUS}'=='FAIL'    Collect Snapshot And SOS Report Data     ${resultDir}
