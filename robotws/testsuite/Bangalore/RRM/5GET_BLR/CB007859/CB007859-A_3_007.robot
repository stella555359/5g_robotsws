*** Settings ***
Force Tags      CLOUD_5G_I_BO_AP_KL_SANSA_FS_CPRI_CMWV_FDD
#...   PY27
...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00    SBTS22R1     SBTS22R2    SBTS22R3    CONFIGURED
Suite Setup       Convert TL Mode And Suite Setup 30Mhz Fdd
Suite Teardown    Common Suite Teardown
Test Setup        Common New Test Setup
Test Teardown     Run keywords      Common New Test Teardown
...               AND    Link SCOUT SCF to Configuration ID for Reporting

Resource          ./resources/common/common_setup_teardown.robot
Resource         ./CB007859_Resource.robot
Library          ./resources/python/lib.py
Library          ./resources/python/read_csv.py
Library    taf.sw.scout    WITH NAME     scout

Documentation
...
...             author:            Akhil K P, akhil.k_p@nokia.com
...             maintainer:        Akhil K P, akhil.k_p@nokia.com
...
...             INTRODUCTION:      CB007859 Spillover of CB006667 Increased number of FDM scheduled UEs per slot for ABIO
...             TEST SET NAME:     CB007859-A_3_007_configurable_number_of_PDSCH_PUSCH_allocation_per_slot_FDD_non_DSS_SA_30MHz.
...                                This case is to verify  the operator configurable number of PDSCH/PUSCH allocation per slot
...                                controls the maximum allocation per slot.
...                                  maxNumPdschAllocationPerSlot
...                                  maxNumPuschAllocationPerSlot

...                                (Due to Airphone limitation and HW availability, test scenario is executed with 1 cell configuraiton
...                                and in L1B mode)

...             TESTING SPLIT:     See CB007859 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB007859 CFAM
...             Requirement ID:     5G_RAN_USR_20476
*** Variables ***
${DELTA_FILE}              Delta_Conf_CB007859_A_3_007_10ue.json
${iphy}              ${CURDIR}/resources/config/AHPF_iphy_working.xml
@{LOG_NAME_LIST}           btslog    snapshot
${LOCAL_WTS_DIR}           ${CURDIR}/resources/wts
${WTS_CFG}                 basic_setup_30mhz_capab_sa_working.cfg
${WTS_AP_XML}              AirphoneConfig_multiue_fdd.xml
@{OLD_PARAS_IPHY}          <cell>2.1</cell>    <cell>2.2</cell>    <GSCN>.*</GSCN>
@{NEW_PARAS_IPHY}          <cell>2.1</cell>    <cell>2.2</cell>    <GSCN>1919</GSCN>
&{UE_INFO}                 profile_id=1    gnb_id=2    cell_id=1    bearer_id=2    dl_traffic=30M    ul_traffic=30M
${UE_NUM}                  10
${UE_PER_SLOT}              8
${UE_NUM_CHANGE}            2
${UE_NUM_CHANGE_Dl_1}            5
${UE_NUM_CHANGE_Ul_1}            6

*** Test Cases ***
[1][1.0] CB007859-A_3_007_configurable_number_of_PDSCH_PUSCH_allocation_per_slot_FDD_non_DSS_SA_30MHz
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...  The purpose of this test is to verify online configuration of maxNumPuschAllocationPerSlot&maxNumPdschAllocationPerSlot for 30mhz
    Online Change MaximumPxschAllocationPerSlot Parameter    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    parameter=maxNumPuschAllocationPerSlot    value=2
    Online Change MaximumPxschAllocationPerSlot Parameter    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    parameter=maxNumPdschAllocationPerSlot    value=2
    SA MultiUE Attach And Do Traffic on SANSA    max_ue_num=${UE_NUM}   dl_tput=35000    ul_tput=25000

    sleep       300s
    Verify fdm max ul and dl Counters   2   2
    Verify max ue per slot after online modification    ${6}     ${5}    ttitrace_after_modification_2/    ${6}     ${5}

    Detach multiple SA UEs      max_ue_num=${UE_NUM}



    Online Change MaximumPxschAllocationPerSlot Parameter    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    parameter=maxNumPuschAllocationPerSlot    value=10
    Online Change MaximumPxschAllocationPerSlot Parameter    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    parameter=maxNumPdschAllocationPerSlot    value=10
        SA MultiUE Attach And Do UL Traffic on SANSA   max_ue_num=${UE_NUM}    ul_tput=25000
    wait for previous action to stabilise ${120}s

	sleep	300s
    Verify fdm max ul Counters   10
    Detach multiple SA UEs      max_ue_num=${UE_NUM}
    sleep    60s
    SA MultiUE Attach And Do DL Traffic on SANSA   max_ue_num=${UE_NUM}    dl_tput=35000
    wait for previous action to stabilise ${120}s

     sleep	300s
    Verify fdm max dl Counters   10

    [Teardown]  Run Keywords   Detach multiple SA UEs      max_ue_num=${UE_NUM}
    ...         AND        Link SCOUT SCF to Configuration ID for Reporting



*** Keywords ***
Verify fdm max dl Counters
     [Arguments]    ${dl_expected}
     [Documentation]    This keyword is to verify the FDM dl&ul counter

     ${counter_dl}           Get Counter Value With Admin          M55308C17002
     Should Be True      ${counter_dl}==${dl_expected}

Verify fdm max ul Counters
     [Arguments]    ${ul_expected}
     [Documentation]    This keyword is to verify the FDM dl&ul counter
     ${counter_ul}           Get Counter Value With Admin          M55308C18002
     Should Be True      ${counter_ul}==${ul_expected}
Check UL rnti per slot
    [Arguments]    ${path}  ${expected_ul}
    ${x}=    check_num_of_rnti_per_slot    ul    ${expected_ul}    ${path}/output_ul_formated.csv
    Should Contain    ${x}    Pass
#    ${y}=    check_num_of_rnti_per_slot    dl    ${expected_dl}    ${path}/output_dl_formated.csv
#    Should Contain    ${y}    Pass

Check DL rnti per slot
    [Arguments]    ${path}  ${expected_dl}

    ${y}=    check_num_of_rnti_per_slot    dl    ${expected_dl}    ${path}/output_dl_formated.csv
    Should Contain    ${y}    Pass

SA MultiUE Attach And Do UL Traffic on SANSA
    [Arguments]    ${max_ue_num}    ${ul_tput}
    FOR    ${ue_id}    IN RANGE    1    ${max_ue_num}+1
    Wait Until Keyword Succeeds    2x   5sec    SA 5G Attach        ${ue_id}
    ute_wtssim.Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    SA 5G PDU Session Setup multiue       ${ue_id}
#    Start DL Traffic        ${ue_id}   ${dl_tput}
    Start UL Traffic        ${ue_id}   ${ul_tput}
    Display average DL and UL data        ${ue_id}
    END
SA MultiUE Attach And Do DL Traffic on SANSA
    [Arguments]    ${max_ue_num}    ${dl_tput}
    FOR    ${ue_id}    IN RANGE    1    ${max_ue_num}+1
    Wait Until Keyword Succeeds    2x   5sec    SA 5G Attach        ${ue_id}
    ute_wtssim.Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    SA 5G PDU Session Setup multiue       ${ue_id}
    Start DL Traffic        ${ue_id}   ${dl_tput}
#    Start UL Traffic        ${ue_id}   ${ul_tput}
    Display average DL and UL data        ${ue_id}
    END

Request Scout SCF
    [Arguments]   ${scout_testline_name}
    [Documentation]    :Author: Michele
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${external_scf_id}=   scout.request_scf   use_scout_internal_id=True
    scout.teardown_scout_api
    [Return]   ${external_scf_id}

Link SCOUT SCF to Configuration ID for Reporting
    [Documentation]
    ...    Associate the SCF to the Configuration ID in Reporting Portal using SCOUT.
    ...
    ...    Example:
    ...     |  Link SCOUT SCF to Configuration ID for Reporting    node_id=${0}    node_type=enb
    ...
    ...     |param node_id | (default=0) Id/Number of Node (eNB or gNB) |
    ...     |param node_type | (default=gnb) Node type; possible values: gnb or enb |
    [Arguments]    ${node_id}=0    ${node_type}=gnb
    ${tl_name_only}      Get Hostname
    ${node_type_Name}        Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF     "${node_type}"=="enb"                   Set Variable  eNB
    ...     ELSE        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb
    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}
    ${scout_testline_name}=    Set Variable    ${tl_name_only}
    ${external_scf_id}=   Request Scout SCF   ${scout_testline_name}
    ${TC_ID}=    Set Variable    ute:id:${external_scf_id}
    Set Tags  ${TC_ID}

Get Hostname
    ${rc}  ${hostname_tmp}=  Run And Return Rc And Output  hostname
    ${hostname_tmp}=  Replace String  ${hostname_tmp}  -  _
    ${hostname_tmp}=  Convert To String  ${hostname_tmp}
    ${hostname_part}=  Split String  ${hostname_tmp}  _
    ${hostname_combined}=  Catenate  ${hostname_part[0]}_${hostname_part[1]}_${hostname_part[2]}
    Set Suite Variable  ${HOSTNAME}  ${hostname_combined}
    [Return]   ${HOSTNAME}

