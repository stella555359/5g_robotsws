*** Settings ***
Force Tags      CLOUD_5G_I_MP_AP_LO_VARIANT_SANSA_FS_CPRI_CMWV_FDD_GMC
...             CRT    RAN_5G_FDD     5G_RAN_FDD    5G_RAN     SBTS00    SBTS23R1     CONFIGURED

#Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
#...                 AND     gnb.Perform gNB reboot
#...                 AND     sleep    60

Test Setup       Start_capture_testcase_default_logging
Test Teardown    Run Keywords       Log To console   Teardown_started
#...                 AND     Dump RMOD BBMOD And Cell Status
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

Documentation

...             author:            Samik Sarkar, samik.sarkar@nokia.com
...             maintainer:        Samik Sarkar, samik.sarkar@nokia.com
...
...             INTRODUCTION:      CB007859 Spillover of CB006667 Increased number of FDM scheduled UEs per slot for ABIO
...             TEST SET NAME:     CB007859-A_1_003_DL_UL_Data_transmission_for_enhanced_FDM_users_3cells_per_Loki_FDD_nonDSS_SANSA_10MHz
...                                CB007859-A_2_005_DL_UL_Data_transmission_for_enhanced_FDM_users_6cells_per_Loki_FDD_nonDSS_NSA_10MHz
...                                CB007859-A_3_007_configurable_number_of_PDSCH_PUSCH_allocation_per_slot_FDD_non_DSS_SA_30MHz
...                                CB007859-A_4_011_Enhanced_FDM_of_UCI_on_PUSCH_FDD_SANSA_20MHz.
...                                This case is to verify  the operator configurable number of PDSCH/PUSCH allocation per slot
...                                controls the maximum allocation per slot and Up to 10 CSI on PUSCH allocation per slot  can
...				                   be achieved based on UE attached in tota
...                                maxNumPdschAllocationPerSlot
...                                maxNumPuschAllocationPerSlot
...                                (Due to Airphone limitation and HW availability, test scenario is executed with 1 cell configuraiton
...                                and in L1B mode)

...             TESTING SPLIT:     See CB007859 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB007859 CFAM
...             Requirement ID:     5G_RAN_USR_20449
...             Requirement ID:     5G_RAN_USR_20475
...             Requirement ID:     5G_RAN_USR_20476
...             Requirement ID:     5G_RAN_USR_20536


Resource          ./resources/common/common_setup_teardown.robot
Resource          ./CB007859_Resource.robot
Library           ./resources/python/lib.py
Library           ./resources/python/read_csv.py
Library           taf.sw.scout    WITH NAME     scout

*** Variables ***
${DELTA_FILE}               ${CURDIR}/resources/config/SBTS26R1/SCF/Delta_Conf_CB007859_A_1_003.json
#${DELTA_FILE2}              ${CURDIR}/resources/config/SBTS25R3/SCF/Delta_Conf_CB007859_A_2_005.json
${DELTA_FILE3}              ${CURDIR}/resources/config/SBTS26R1/SCF/Delta_Conf_CB007859_A_3_007_10ue_tmo_NEWW.json
${DELTA_FILE4}              ${CURDIR}/resources/config/SBTS26R1/SCF/Delta_Conf_CB007859_A_4_011.json
${iphy}                     ${CURDIR}/resources/config/AHPF_iphy_working.xml
@{LOG_NAME_LIST}            btslog    snapshot
${LOCAL_WTS_DIR}            ${CURDIR}/resources/wts
${WTS_CFG}                  basic_setup_multiuefdd_updated.cfg
${WTS_CFG3}                 basic_setup_30mhz_capab_sa_working.cfg
${WTS_CFG4}                 basic_setup_multiuefdd_updated_TMO.cfg
${WTS_AP_XML}               AirphoneConfig_multiue_fdd.xml
@{OLD_PARAS_IPHY}           <cell>2.1</cell>    <cell>2.2</cell>    <GSCN>.*</GSCN>
@{NEW_PARAS_IPHY}           <cell>2.1</cell>    <cell>2.2</cell>    <GSCN>1582</GSCN>
@{NEW_PARAS_IPHY3}          <cell>2.1</cell>    <cell>2.2</cell>    <GSCN>1919</GSCN>
&{UE_INFO3}                  profile_id=1    gnb_id=2    cell_id=1    bearer_id=2    dl_traffic=30M    ul_traffic=30M
&{UE_INFO}                   profile_id=1    gnb_id=2    cell_id=1    bearer_id=2    dl_traffic=20M    ul_traffic=20M
&{UE_INFO_DL}                profile_id=1    gnb_id=2    cell_id=1    bearer_id=2    dl_traffic=15M    ul_traffic=0
&{UE_INFO_UL}                profile_id=1    gnb_id=2    cell_id=1    bearer_id=2    dl_traffic=0      ul_traffic=10M
${UE_NUM}                    10
${UE_NUM2}                    8
${UE_NUM4}                   20
${sa_st_ue_id}      ${1}
${sa_en_ue_id}      ${10}
${UE_PER_SLOT}                8
${UE_NUM_CHANGE}              2
${UE_NUM_CHANGE_Dl_1}            5
${UE_NUM_CHANGE_Ul_1}            6
${UE_PER_SLOT_UL}               ${10}
${UE_PER_SLOT_DL}               ${12}
${ACSI_ON_PUSCH}                ${10}

${default_scf}     /home/ute/testline_init_results/execution/configs/topology_configs/node_1/SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65/scfc.xml
#${default_iphy}     /home/ute/testline_init_results/execution/configs/topology_configs/node_1/SA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO_5_1/iphy.xml
${AP_XML}=          ${CURDIR}/resources/wts/iphy_default.xml


*** Test Cases ***
[1][1.0] CB007859-A_1_003_DL_UL_Data_transmission_for_enhanced_FDM_users_3cells_per_Loki_FDD_nonDSS_SANSA_10MHz

    [Tags]    TC01
	[Setup]        Run keywords     Convert TL Mode And Suite Setup Fdd
	...                 AND     Common New Test Setup

    SA MultiUE Attach And Do UL Traffic on SANSA   max_ue_num=${UE_NUM}    ul_tput=20000
    wait for previous action to stabilise ${120}s
#    Start And Stop Tti Trace Streaming    ${test_log_directory}/ttitrace_streaming_ul/
#    Convert Tti To Csv Mode     ${test_log_directory}/ttitrace_streaming_ul/
#    Check UL rnti per slot    ${test_log_directory}/ttitrace_streaming_ul/    ${8}
    Start Log        ttitrace
    sleep    1s
    ${scene1}     Stop Log     ttitrace     test_scenario=UL_rnti
    Common TTI PCAP to CSV Converter    UL_rnti   dir=ul
    Check UL rnti per slot    ${scene1}[ttitrace]/output_ul_formated.csv    ${8}

    Verify fdm max ul Counters   8
    Detach multiple SA UEs      max_ue_num=${UE_NUM}
    sleep    60s
    SA MultiUE Attach And Do DL Traffic on SANSA   max_ue_num=${UE_NUM}    dl_tput=20000
    wait for previous action to stabilise ${120}s
#    Start And Stop Tti Trace Streaming    ${test_log_directory}/ttitrace_streaming_dl/
#    Convert Tti To Csv Mode     ${test_log_directory}/ttitrace_streaming_dl/
#    Check DL rnti per slot    ${test_log_directory}/ttitrace_streaming_dl/    ${8}
    Start Log        ttitrace
    sleep    1s
    ${scene2}     Stop Log     ttitrace      test_scenario=DL_rnti
    Common TTI PCAP to CSV Converter    DL_rnti   dir=dl
    Check DL rnti per slot    ${scene2}[ttitrace]/output_dl_formated.csv    ${8}

    Verify fdm max dl Counters   8
    Verify max ue per slot after online modification_A1_003    ${2}     ${2}    after_change/    ${2}     ${2}

    [Teardown]      Run Keywords    Common New Test Teardown
    ...             AND     Common New Test Teardown
    ...             AND     Link SCOUT SCF to Configuration ID for Reporting

#[1][1.0] CB007859-A_2_005_DL_UL_Data_transmission_for_enhanced_FDM_users_6cells_per_Loki_FDD_nonDSS_NSA_10MHz
#
#    [Tags]    TC02
#	[Setup]        Run keywords     Prepare TL with all config files
#	...                 AND     Convert TL Mode And Suite Setup Fdd_A2_005
#	...                 AND     Common New Test Setup
#
#    log to console     UL CHECK STARTED
#    NSA MultiUE Attach And Do Traffic on SANSA   max_ue_num=${UE_NUM2}    ue_info=${UE_INFO_UL}
#    wait for previous action to stabilise ${300}s
#    Start And Stop Tti Trace Streaming    ${test_log_directory}/ttitrace_streaming_ul/
#    Convert Tti To Csv Mode     ${test_log_directory}/ttitrace_streaming_ul/
#    Check UL rnti per slot    ${test_log_directory}/ttitrace_streaming_ul/    ${5}
#    Verify fdm max ul Counters   5
#    Detach multiple NSA UEs     max_ue_num=${UE_NUM2}
#    sleep    60s
#    log to console     DL CHECK STARTED
#    NSA MultiUE Attach And Do Traffic on SANSA   max_ue_num=${UE_NUM2}    ue_info=${UE_INFO_DL}
#    wait for previous action to stabilise ${300}s
#    Start And Stop Tti Trace Streaming    ${test_log_directory}/ttitrace_streaming_dl/
#    Convert Tti To Csv Mode     ${test_log_directory}/ttitrace_streaming_dl/
#    Check DL rnti per slot    ${test_log_directory}/ttitrace_streaming_dl/    ${6}
#    Verify fdm max dl Counters   6
#    Detach multiple NSA UEs     max_ue_num=${UE_NUM2}
#    log to console     DL CHECK COMPLETED
#    sleep    60s
#    log to console     DL & UL CHECK STARTED
#    NSA MultiUE Attach And Do Traffic on SANSA   max_ue_num=${UE_NUM2}    ue_info=${UE_INFO}
#    wait for previous action to stabilise ${120}s
#    Verify max ue per slot after online modification    ${2}     ${2}    after_change/    ${2}     ${2}
#
#    [Teardown]      Run Keywords    Common New Test Teardown
#    ...             AND     Common New Test Teardown
#    ...             AND     Link SCOUT SCF to Configuration ID for Reporting

[1][1.0] CB007859-A_4_011_Enhanced_FDM_of_UCI_on_PUSCH_FDD_SANSA_20MHz
#
    [Tags]    TC03
#	[Setup]        Run keywords   BuiltIn.Set Suite Variable      ${SCFC}             ${default_scf}
#	...                 AND     Prepare TL with all config files
    	[Setup]        Run keywords     Convert TL Mode And Suite Setup fdd_acsi
	...                 AND     Common New Test Setup

	log to console     UL CHECK STARTED
    SA MultiUE Attach And Do UL Traffic on SANSA   max_ue_num=${UE_NUM4}    ul_tput=20000
    wait for previous action to stabilise ${600}s
    Verify fdm max ul Counters   10
#    Start And Stop Tti Trace Streaming Mod    ${test_log_directory}/ttitrace_streaming_ul/      duration=${2}
#    Convert Tti To Csv Mode     ${test_log_directory}/ttitrace_streaming_ul/
#    Check UL rnti per slot    ${test_log_directory}/ttitrace_streaming_ul/    ${10}

    Start TTI_TRACE custom     ${60}
    sleep     2s
    ${scene1}     Stop Log     ttitrace      test_scenario=UL_counter
    Common TTI PCAP to CSV Converter    UL_counter   dir=dl
    Common TTI PCAP to CSV Converter    UL_counter   dir=ul
    Check UL rnti per slot_A4_011       ${scene1}[ttitrace]/output_ul_formated.csv      ${10}

    Detach multiple SA UEs      max_ue_num=${UE_NUM4}
    ${ret}    Check ACSI per on PUSCH slot    ${scene1}[ttitrace]/output_ul_formated.csv    ${ACSI_ON_PUSCH}    output_ul_formated.csv
    log to console     ACSI on PUSCH per slot is ${ret}
    log to console     UL CHECK COMPLETED

    sleep    60s

    log to console     DL CHECK STARTED
    SA MultiUE Attach And Do DL Traffic on SANSA   max_ue_num=${UE_NUM4}    dl_tput=20000
    wait for previous action to stabilise ${600}s
    Verify fdm max dl Counters   12
#    Start And Stop Tti Trace Streaming Mod    ${test_log_directory}/ttitrace_streaming_dl/      duration=${2}
#    Convert Tti To Csv Mode     ${test_log_directory}/ttitrace_streaming_dl/
#    Check DL rnti per slot    ${test_log_directory}/ttitrace_streaming_dl/    ${12}

    Start TTI_TRACE custom     ${60}
    sleep     2s
    ${scene2}     Stop Log     ttitrace      test_scenario=DL_counter
    Common TTI PCAP to CSV Converter    DL_counter   dir=dl
    Common TTI PCAP to CSV Converter    DL_counter   dir=ul
    Check DL rnti per slot_A4_011       ${scene2}[ttitrace]/output_dl_formated.csv      ${12}

    Detach multiple SA UEs      max_ue_num=${UE_NUM4}
    log to console     DL CHECK COMPLETED

    [Teardown]      Run Keywords    Common New Test Teardown
    ...             AND     Common New Test Teardown
    ...             AND     Link SCOUT SCF to Configuration ID for Reporting

[1][1.0] CB007859-A_3_007_configurable_number_of_PDSCH_PUSCH_allocation_per_slot_FDD_non_DSS_SA_30MHz

    [Tags]    TC04
	[Setup]        Run keywords   BuiltIn.Set Suite Variable      ${SCFC}             ${default_scf}
	...                 AND     Prepare TL with all config files
	...                 AND     Convert TL Mode And Suite Setup 30Mhz Fdd
	...                 AND     Common New Test Setup

    Online Change MaximumPxschAllocationPerSlot Parameter    dist_name=MRBTS-1/NRBTS-1/NRCELL-10    parameter=maxNumPuschAllocationPerSlot    value=2
    Online Change MaximumPxschAllocationPerSlot Parameter    dist_name=MRBTS-1/NRBTS-1/NRCELL-10    parameter=maxNumPdschAllocationPerSlot    value=2
    SA MultiUE Attach And Do Traffic on SANSA_A3_007    ${1}     ${10}   dl_tput=35000    ul_tput=25000

    sleep       300s
    Verify fdm max ul and dl Counters   2   2
    Verify max ue per slot after online modification    ${6}     ${5}    ttitrace_after_modification/    ${6}     ${5}
    Detach multiple SA UEs_A3_007      ${sa_st_ue_id}       ${sa_en_ue_id}

    Online Change MaximumPxschAllocationPerSlot Parameter    dist_name=MRBTS-1/NRBTS-1/NRCELL-10    parameter=maxNumPuschAllocationPerSlot    value=10
    Online Change MaximumPxschAllocationPerSlot Parameter    dist_name=MRBTS-1/NRBTS-1/NRCELL-10    parameter=maxNumPdschAllocationPerSlot    value=10
    SA MultiUE Attach And Do UL Traffic on SANSA_A3_007   ${1}     ${10}    ul_tput=25000
    wait for previous action to stabilise ${120}s
	sleep	300s
    Verify fdm max ul Counters   10
    Detach multiple SA UEs_A3_007      ${sa_st_ue_id}       ${sa_en_ue_id}
    sleep    60s
    SA MultiUE Attach And Do DL Traffic on SANSA_A3_007   ${1}     ${10}    dl_tput=35000
    wait for previous action to stabilise ${120}s
    sleep	300s
    Verify fdm max dl Counters   10
    Detach multiple SA UEs_A3_007     ${sa_st_ue_id}       ${sa_en_ue_id}

    [Teardown]      Run Keywords    Common New Test Teardown
    ...             AND     Common New Test Teardown
    ...             AND     Link SCOUT SCF to Configuration ID for Reporting

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
    ${x}=    check_num_of_rnti_per_slot    ul    ${expected_ul}    ${path}
    Should Contain    ${x}    Pass
#    ${y}=    check_num_of_rnti_per_slot    dl    ${expected_dl}    ${path}/output_dl_formated.csv
#    Should Contain    ${y}    Pass

Check DL rnti per slot
    [Arguments]    ${path}  ${expected_dl}

    ${y}=    check_num_of_rnti_per_slot    dl    ${expected_dl}    ${path}
    Should Contain    ${y}    Pass

Check UL rnti per slot_A4_011
    [Arguments]    ${path}  ${expected_ul}
    ${x}=    check_num_of_rnti_per_slot    ul    ${expected_ul}    ${path}
    Should Contain    ${x}    Pass

Check DL rnti per slot_A4_011
    [Arguments]    ${path}    ${expected_dl}
    ${y}=    check_num_of_rnti_per_slot    dl    ${expected_dl}    ${path}
    Should Contain    ${y}    Pass

SA MultiUE Attach And Do UL Traffic on SANSA
    [Arguments]    ${max_ue_num}    ${ul_tput}
    FOR    ${ue_id}    IN RANGE    1    ${max_ue_num}+1
    Wait Until Keyword Succeeds    2x   5sec    SA 5G Attach        ${ue_id}
    ute_wtssim.Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    SA 5G PDU Session Setup multiue       ${ue_id}
    Start UL Traffic        ${ue_id}   ${ul_tput}
    Display average DL and UL data        ${ue_id}
    END

SA MultiUE Attach And Do UL Traffic on SANSA_A3_007
    [Arguments]    ${sa_st_ue_id}       ${sa_en_ue_id}    ${ul_tput}
    FOR    ${ue_id}    IN RANGE     ${sa_st_ue_id}       ${sa_en_ue_id}+1
    Wait Until Keyword Succeeds    2x   5sec    SA 5G Attach        ${ue_id}
    ute_wtssim.Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    SA 5G PDU Session Setup multiue       ${ue_id}
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
    Display average DL and UL data        ${ue_id}
    END

SA MultiUE Attach And Do DL Traffic on SANSA_A3_007
    [Arguments]    ${sa_st_ue_id}       ${sa_en_ue_id}    ${dl_tput}
    FOR    ${ue_id}    IN RANGE      ${sa_st_ue_id}       ${sa_en_ue_id}+1
    Wait Until Keyword Succeeds    2x   5sec    SA 5G Attach        ${ue_id}
    ute_wtssim.Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    SA 5G PDU Session Setup multiue       ${ue_id}
    Start DL Traffic        ${ue_id}   ${dl_tput}
    Display average DL and UL data        ${ue_id}
    END

Start And Stop Tti Trace Streaming Mod
    [Arguments]         ${path}     ${duration}=${3}
    Start Ttitrace With Streaming Mode
    Sleep    ${duration}s    reason=get *L2TtiTrace_EventsSnapshot
    Stop Ttitrace
    Convert Ttitrace From Pcap To Excelcsv        ${path}
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
    log to console      ${node_id}
Get Hostname
    ${rc}  ${hostname_tmp}=  Run And Return Rc And Output  hostname
    ${hostname_tmp}=  Replace String  ${hostname_tmp}  -  _
    ${hostname_tmp}=  Convert To String  ${hostname_tmp}
    ${hostname_part}=  Split String  ${hostname_tmp}  _
    ${hostname_combined}=  Catenate  ${hostname_part[0]}_${hostname_part[1]}_${hostname_part[2]}
    Set Suite Variable  ${HOSTNAME}  ${hostname_combined}
    [Return]   ${HOSTNAME}


Update bsr package
    Run     mkdir ${CURDIR}/BSR
    ${dllink}   Set Variable     https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR
    ${filename}    Set variable     BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    Run     sudo wget ${dllink}/${filename} --user=dheerajn --password=AP33ZXKC1P9cgTCGJmyvY3bv5NA -P ${CURDIR}/BSR
    coam.setup admin    bts_host=192.168.255.129
    ${ret}     coam.Update Software      ${CURDIR}/BSR/BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    coam.teardown admin

Verify max ue per slot after online modification_A1_003
    [Arguments]    ${pusch}     ${pdsch}    ${log_path}     ${pusch_exp}     ${pdsch_exp}
    Online Change MaximumPxschAllocationPerSlot Parameter    MRBTS-1/NRBTS-1/NRCELL-4    maxNumPuschAllocationPerSlot    ${pusch}
    Online Change MaximumPxschAllocationPerSlot Parameter    MRBTS-1/NRBTS-1/NRCELL-4    maxNumPdschAllocationPerSlot    ${pdsch}
    Start Log        ttitrace
    sleep     2s
    ${scene3}     Stop Log     ttitrace      test_scenario=online_modification
    Common TTI PCAP to CSV Converter    online_modification   dir=dl
    Common TTI PCAP to CSV Converter    online_modification   dir=ul
    Check DL rnti per slot       ${scene3}[ttitrace]/output_dl_formated.csv      ${pdsch_exp}
    Check UL rnti per slot       ${scene3}[ttitrace]/output_ul_formated.csv      ${pusch_exp}
    wait for counter update ${600}s
    Verify fdm max ul and dl Counters   ${pusch_exp}   ${pdsch_exp}
    log to console      ${log_path}