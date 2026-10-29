*** Settings ***
Documentation    this suite is used for CB010680 5G Precise Positioning SiSo for Shikra pRRH and mRRH
                ...    1. 5G SA TDD Cells with Maximum 100MHz Bandwidth
                ...    2. RF 6.2 Made2 B0 based non-BF RRHs with eCPRI 7.2a fronthaul
                ...    3. periodical UL-SRS reporting with NDM SRS configuration
                ...    author: Li Na
                ...    contact: na.lig@nokia-sbell.com
                ...    squad group: HAZ3_4

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/SISO_common_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/common_variables.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/UE_start_traffic.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/bip_common_keyword.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB010680/Resource/CB010680_A_Common_KW.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB010680/Resource/CB010680_B_Common_KW.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB010680/Resource/CB010680_UE.robot
Library      testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB010680/Resource/CB010680_SRS_BIP.py
Library     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008927-N/Resources/CB008927_common_keyword.py
Variables    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB010680/Resource/CB010680_Params.py
Library     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007306_OTA/Resources/CB007306_common.py

Suite Setup    Common Suit Setup CB10680
Suite Teardown    robot_common_operations.Common Suite Teardown

*** Variables ***
${LOOP_TIMES}    ${2}
@{cell_id_list}    4    5    6    7    8
@{RMOD_id_list}    7    8
@{CHANNEL_id_list}    1    3    5    7
@{NRCELL_List}    1    2    3    4    5    6
#trp selection low precision position
#@{degreesOfLatitude_lst}    2850385    2850385    2849370    2849370    2849790    2849790
#@{degreesOfLongitude_lst}    4849850    4849850    4850332    4850332    4850470    4850470
#trp slection high precision position
@{degreesOfLatitude_lst}    2850210    2850629    2851049    2851469    2851889    2852309    2852729    2853148
@{degreesOfLongitude_lst}    4850609    4850747    4850886    4851024    4851163    4851301   4851440    4851578
@{nrcellId_list}    616218625    616218626    616218627    616218628    616218629    616218630    616218631    616218632
@{counter_name}        NUEQN    NUEQN
@{counter_name_003}    RSANB
${att_ipaddr}             ${tl.attenuator.ip_addr}
${att_api_port}           ${tl.attenuator.port}
${att_connection_port}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${model}                     ${tl.attenuator.model}
${UTE_ADDRESS}            ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}           ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}           ${tl.test_pc.default_ssh_connection_details.password}
@{port_list_0}    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}    ${7}    ${8}    ${9}    ${10}    ${11}    ${12}
@{port_list_1}    ${13}    ${14}    ${15}   ${16}
@{port_list_cell5}    ${13}    ${14}    ${16}


*** Test Cases ***
[1]CB007880-B-001_precise_postioning_RU_Access_supercell3+3_ABIP_with_shared_TRP
    [Tags]    CB010680_G    T714
    [Setup]    robot_common_operations.Common case Setup
    configuration 6nom to 2super3sub within one shared trp group
    UE Attach and check log
    [Teardown]    CB010680_A Common Teardown With TMO SCF Restore


[1]CB007880-G-001_Precise_Position_with_intra_freq_intra_gnb_HO
    [Tags]    CB007880    T714
    [Setup]    robot_common_operations.Common case Setup
    Log To Console    CB007880-B-001
    configuration 6 normal cell within one shared trp group
    UE Attach and check log CB007880-G-001
    [Teardown]    Case Teardown CB007880-G-001


[1]CB007880-C-002_dedicated_BWP_switch_to_Power_saving_BWP_with_normalcell
    [Setup]    robot_common_operations.Common case Setup
    [Tags]    CB007880    T714
    Log To Console    CB007880-C-002
    Log To Console    default SCF aleady enable actPowerSavingBWP, so skip online change
    # online enable actPowerSavingBWP for all 6 normal cells
    [Teardown]    CB010680_A Common Teardown With TMO SCF Restore


[1][1.0]CB007880-C-005_Precise_Positioning_normalcell_with_PRB_Blanking_enable
    [Tags]    TL749_CASE
    [Setup]    robot_common_operations.Common case Setup
    configuration 6 AWHQN NRCELLs into one shared trp group
    Check CB007880-C-005 counters
    [Teardown]    Common Teardown


[1]CB007880-B-005_precise_postioning_RU_Access_normallcell_with_shared_TRP
    [Tags]    TL749_CASE
    [Setup]    robot_common_operations.Common case Setup
    configuration 2 shared trp group with 6 AWHQN and 3 AWHQ2
    UE Attach and check log
    [Teardown]    Common Teardown

[1]CB007880-D-0012_Precise_Position_RU_Access_RU_SRS_with_share_TRP_different_reuseGroupNumber
    [Tags]    TL714_CASE
    [Setup]    robot_common_operations.Common case Setup
    configuration CB007880-D-0012 parameter to 2NR2NRPOSCELL
    UE Attach and check log
    configuration 2NR2NRPOSCELL parameter to 3NR3NRPOSCELL
    ${NRCELL_list_lock}    Create List
    ...    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-1
    ...    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-2
     Lock and Unlock NRCELL    lock_cell_list=${NRCELL_list_lock}
    UE Attach and check log
    [Teardown]    CB010680_A Common Teardown With TMO SCF Restore

[1]CB007880-D-0013_Precise_Position_RU_Access_RU_SRS_with_share_TRP_change_nrPosDN
    [Tags]    T714_CASE
    [Setup]    robot_common_operations.Common case Setup
    Configuration CB007880-D-0013 Parameter To 4NR4NRPOSCELL
    UE Attach and check log
    [Teardown]    CB010680_A Common Teardown With TMO SCF Restore

[1]CB007880-I-B1-001_precise_postioning_RU_Access_supercell_with_shared_TRP_stop_positioning_report_for_locked_RU
    [Tags]    TL714_CASE
    [Setup]    robot_common_operations.Common case Setup
    configuration 6nom to 2super3sub within one shared trp group
#    UE Attach and check log
    UE Attach and check log CB007880-I-B1
    [Teardown]    CB010680_A Common Teardown With TMO SCF Restore

*** Keywords ***
Common Suit Setup CB10680
    robot_common_operations.Common Suite Setup
    CI_interface.Common Suite Setup
    Adjust PA    value_0=${10}    value_1=${0}    port_list_0=${port_list_0}    port_list_1=${port_list_1}
    Setup Commission SCF
    Run Keyword And Ignore Error    Check GNB on air And alarm    bts_host=${gNB_ip}
    ...    allowed_list=${allowed_alarm_list}    time=20min

Common Suit Teardown CB10680
    robot_common_operations.Common Suite Teardown

Common Teardown
    SISO_common_operation.Common Case Teardown    bts_host=${gNB_ip}
    Run Keyword If    "${TEST_STATUS}"=="FAIL"    Save Snapshot    bts_host=${gNB_ip}
    Run Keyword And Ignore Error    Setup Commission SCF
    Run Keyword And Ignore Error    Check GNB on air And alarm    bts_host=${gNB_ip}
    ...    allowed_list=${allowed_alarm_list}    time=20min

Case Teardown CB007880-G-001
    Run Keyword and ignore error    Adjust the HBTE attenuation value    value=${0}    port_list=${port_list_cell5}
    CB010680_A Common Teardown With TMO SCF Restore

########################CB007880-B-001_step###########################
UE Attach and check log
    [Arguments]    ${ue_inex}=0
    ${ue_index_list}    Create List    ${ue_inex}
    CB010680_BIP.Start Catch TCPDUMP SCTP Log    filename=ngc.pcap
    CB010680_UE.UE Attach    gnb_index=${0}    ue_index=${ue_inex}
    Trigger SRS Measurement From LMF   ue_index=${ue_inex}
    ${utc_time}    robot.libraries.DateTime.Get Current Date
    ${log_time}    change_format_for_utr_time    utc_time=${utc_time}
    Set Test Variable    ${log_time}
    ${pcap_log_path_lst}    Common Capture BIP log and download    target_dir=${OUTPUT_DIR}/${TEST NAME}    target_file_name=bip_srs_${log_time}
    ${srsConfig}    ${startPrb}    ${prbNum}    Get srsForPositioning For Specfic Cell    bts_host=${gNB_ip}
    ...     username=${gNB_username}    password=${gNB_password}    cell_id=${1}
    CB010680_BIP.Stop And Copy TCPDUMP To UTE    filename=ngc.pcap
    Check BIP Log SRS TOE Is Expected    pcap_log_path=${pcap_log_path_lst[0]}
    ...    srsUePeriodicity=${srsConfig['srsUePeriodicity']}    csrs=${srsConfig['cSRS']}    expected_startPrb=${startPrb}
    [Teardown]    UE stop traffic and detach    ue_index_list=${ue_index_list}

UE Attach and check log counter
    [Arguments]    ${ue_inex}=0
    ${ue_index_list}    Create List    ${ue_inex}
    CB010680_BIP.Start Catch TCPDUMP SCTP Log    filename=ngc.pcap
    CB010680_UE.UE Attach    gnb_index=${0}    ue_index=${ue_inex}
    Trigger SRS Measurement From LMF   ue_index=${ue_inex}
    sleep    10min
    ${utc_time}    robot.libraries.DateTime.Get Current Date
    ${log_time}    change_format_for_utr_time    utc_time=${utc_time}
    Set Test Variable    ${log_time}
    ${pcap_log_path_lst}    Common Capture BIP log and download    target_dir=${OUTPUT_DIR}/${TEST NAME}    target_file_name=bip_srs_${log_time}
    ${srsConfig}    ${startPrb}    ${prbNum}    Get srsForPositioning For Specfic Cell    bts_host=${gNB_ip}
    ...     username=${gNB_username}    password=${gNB_password}    cell_id=${1}
    CB010680_BIP.Stop And Copy TCPDUMP To UTE    filename=ngc.pcap
    Check BIP Log SRS TOE Is Expected    pcap_log_path=${pcap_log_path_lst[0]}
    ...    srsUePeriodicity=${srsConfig['srsUePeriodicity']}    csrs=${srsConfig['cSRS']}    expected_startPrb=${startPrb}
    [Teardown]    UE stop traffic and detach    ue_index_list=${ue_index_list}

Set Channelgroup Parameter CB10680
    [Arguments]  ${group_id}    ${ru_id}    ${cell_id}=${6}    ${times}=${4}
    Log To Console    set channelgrp parameter
    @{antl_value_list}    create list    ${1}    ${2}    ${3}    ${4}    ${1}    ${2}    ${3}    ${4}
    @{CHANNEL_id}    create list    ${2}    ${4}    ${6}    ${8}    ${1}    ${3}    ${5}    ${7}
    FOR    ${item}    IN RANGE    ${times}
        ${antlDN_value}    set variable    MRBTS-${TL_BTS_ID}/EQM-1/APEQM-1/RMOD-${ru_id}/ANTL-${antl_value_list[${item}]}
        selenium_coam.set_parameter_value
        ...    dist_name=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-${group_id}/CHANNEL-${CHANNEL_id[${item}]}
        ...    filter_param=Distinguished Name of antenna line   new_value=${antlDN_value}    abbr=antlDN
    END


UE attach and check traffic CB010680
    [Arguments]    ${ue_inex}=0    ${nrcellId_list}=${nrcellId_list}
    ${ue_index_list}    Create List    ${ue_inex}
    CB010680_UE.UE Attach    gnb_index=${0}    ue_index=${ue_inex}
    CB010680_UE.UE Start Traffic    ue_index=${ue_inex}    duration=600    dl_tput_sent=1600    ul_tput_sent=250
    ...    if_dl=${True}    if_ul=${True}
    CB010680_UE.UE Check Tput    gnb_index=${0}    log_time=30s    dl_tput_expected=700    ul_tput_expected=100
    ...    if_dl=${True}    if_ul=${True}    dl_cells_list=${nrcellId_list}    ul_cells_list=${nrcellId_list}    ignore_time=15s
    ...    min_percent=0.6    target_avg_percent=0.7
    [Teardown]    UE stop traffic and detach    ue_index_list=${ue_index_list}


configuration 6nom to 2super3sub within one shared trp group
    WEBUI Login    bts_host=${gNB_ip}
    ${Delete_cell_id_list}    Create List    2    3    5    6
    configuration 3nom to 1super3sub
    configuration 3nom to 1super3sub    NRCELL_id=4    LCELNR_id=4
    ######################Delete_NRcell2/3/4/5/6######################
    FOR   ${cell_id}    IN    @{Delete_cell_id_list}
        ${node_index}    Evaluate     7 - ${cell_id}
        selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${cell_id}
        selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELLGRP-${cell_id}
        selenium_coam.remove_element   dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRDU-1
        ...    filter_param=Reference to cell group    node_index= ${node_index}   abbr=refNrCellGroup
    END
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSPR-0
    ...    filter_param=Reuse group number   new_value=2   abbr=reuseGroupNumber
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}
    ...    filter_param=Allow slow static NDM-SRS PRB pooling    new_value=false   abbr=allowSlowPrbPoolingStatNdmSrs
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}
    ...    filter_param=Activate NR RTWP measurement    new_value=false   abbr=actRtwpMeasurement
    selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-1/NRREL-255
    selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-1/NRREL-256
    selenium_coam.save_bts_configuration    save_configuration_type=${0}
    ${error}    selenium_coam.validate_plan
    Log To Console    ${error}
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    [Teardown]    WEBUI Logout


configuration 3nom to 1super3sub
    [Arguments]    ${NRCELL_id}=1    ${LCELNR_id}=1
    FOR    ${item}    IN RANGE    ${2}
        ${LCELNR_id_Copy}    Evaluate     1 + ${item} + ${LCELNR_id}
        ${NRPOSINFO_id}    Evaluate      2 + ${item}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${NRCELL_id}
        ...    filter_param=Activate super cell   new_value=true   abbr=actSuperCell
        wait until keyword succeeds    3x   1min
        ...    selenium_coam.add_object
        ...    object_name=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${LCELNR_id}   object_class_name=CHANNELGROUP
        ...    plan_to_copy_from=CURRENT_BTS_CONF-1
        ...    copy_from=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${LCELNR_id_Copy}/CHANNELGROUP-1
        ...    include_subobject=${TRUE}    id_value=${LCELNR_id_Copy}
        wait until keyword succeeds    3x   1min
        ...    selenium_coam.add_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${NRCELL_id}   object_class_name=NRPOSINFO
        ...    plan_to_copy_from=CURRENT_BTS_CONF-1
        ...    copy_from=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${LCELNR_id_Copy}/NRPOSINFO-1
        ...    include_subobject=${TRUE}    id_value=${NRPOSINFO_id}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${NRCELL_id}
        ...    filter_param=NR Positioning Profile distinguished name
        ...    new_value=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSPR-0   abbr=nrPosDN
        selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${LCELNR_id_Copy}
    END
    Specfic Paramter Setting For TMO IWK From Normal To SupperCell    nrcell_id=${NRCELL_id}



UE Attach start traffic and check log CB10680
    [Arguments]    ${ue_inex}=0    ${nrcellId_list}=${nrcellId_list}
    ${ue_index_list}    Create List    ${ue_inex}
    CB010680_BIP.Start Catch TCPDUMP SCTP Log    filename=ngc.pcap
    CB010680_UE.UE Attach    gnb_index=${0}    ue_index=${ue_inex}
    Trigger SRS Measurement From LMF   ue_index=${ue_inex}
    ${utc_time}    robot.libraries.DateTime.Get Current Date
    ${log_time}    change_format_for_utr_time    utc_time=${utc_time}
    Set Test Variable    ${log_time}
    Start Common Capture BIP log    target_file_name=bip_srs_${log_time}
    Trigger SRS Measurement From LMF   ue_index=${ue_inex}
    Sleep    2s
    ${pcap_log_path_lst}    End Common Capture BIP log and Download    target_dir=${OUTPUT_DIR}/${TEST NAME}    target_file_name=bip_srs_${log_time}
    ${srsConfig}    ${startPrb}    ${prbNum}    Get srsForPositioning For Specfic Cell    bts_host=${gNB_ip}
    ...     username=${gNB_username}    password=${gNB_password}    cell_id=${1}
    CB010680_BIP.Stop And Copy TCPDUMP To UTE    filename=ngc.pcap
    Check BIP Log SRS TOE Is Expected    pcap_log_path=${pcap_log_path_lst[0]}
    ...    srsUePeriodicity=${srsConfig['srsUePeriodicity']}    csrs=${srsConfig['cSRS']}    expected_startPrb=${startPrb}
    CB010680_UE.UE Start Traffic    ue_index=${ue_inex}    duration=600    dl_tput_sent=1600    ul_tput_sent=250
    ...    if_dl=${True}    if_ul=${True}
    CB010680_UE.UE Check Tput    gnb_index=${0}    log_time=30s    dl_tput_expected=700    ul_tput_expected=100
    ...    if_dl=${True}    if_ul=${True}    dl_cells_list=${nrcellId_list}    ul_cells_list=${nrcellId_list}    ignore_time=15s
    ...    min_percent=0.6    target_avg_percent=0.7
    [Teardown]    UE stop traffic and detach    ue_index_list=${ue_index_list}


########################CB007880-C-002_step###########################
online enable actPowerSavingBWP for all 6 normal cells
    WEBUI Login    bts_host=${gNB_ip}
    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}
    ...    filter_param=Activate multiple dedicated bandwidth parts (BWPs)   new_value=true    abbr=actMultipleDedicatedBWPs
    FOR    ${item}    IN RANGE    ${6}
        ${NRCELL_id}    Evaluate      1 + ${item}
        selenium_coam.set_parameter_value
        ...    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${NRCELL_id}
        ...    filter_param=Activate power saving bandwidth part   new_value=true   abbr=actPowerSavingBWP
        selenium_coam.set_parameter_value
        ...    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${NRCELL_id}
        ...    filter_param=PRACH Frequency start   new_value=24   abbr=msg1FrequencyStart
#        selenium_coam.set_parameter_value
#        ...    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${NRCELL_id}
#        ...    filter_param=SRS bandwidth configuration   new_value=10   abbr=cSRS
#        selenium_coam.set_parameter_value
#        ...    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${NRCELL_id}
#        ...    filter_param=Activate power saving bandwidth part   new_value=true   abbr=actPowerSavingBWP
#        selenium_coam.set_parameter_value
#        ...    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${NRCELL_id}
#        ...    filter_param=Activate power saving bandwidth part   new_value=true   abbr=actPowerSavingBWP
    END
    selenium_coam.save_bts_configuration    save_configuration_type=${0}
    ${error}    selenium_coam.validate_plan
    Log To Console    ${error}
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    [Teardown]    WEBUI Logout

modify the parameter case CB007880_C
    [Arguments]    ${bts_host}    ${username}    ${password}    ${connection}=GNB_OAM    ${input_list}=${CB007880_C_parameter}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    ...    connection=${connection}
    Modify Parameters with coam     input_list=${input_list}    connection=${connection}
    [Teardown]   run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}



########################CB007880-C-005_step###########################
configuration 6 AWHQN NRCELLs into one shared trp group
    WEBUI Login    bts_host=${gNB_ip}
    wait until keyword succeeds    3x   1min
    ...    selenium_coam.add_object
    ...    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}   object_class_name=NRPOSPR
    ...    id_value=0
    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSPR-0
    ...    filter_param=Reuse group number   new_value=6   abbr=reuseGroupNumber
    wait until keyword succeeds    3x   1min
    ...    selenium_coam.add_object
    ...    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}   object_class_name=NRPOSPR
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSPR-0
    ...    include_subobject=${TRUE}    id_value=1
    ${nrPosDN_cell_id_list}    Create List    0    1    6    7    8    9
    FOR   ${NRCELL_id}    IN    @{nrPosDN_cell_id_list}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${NRCELL_id}
        ...    filter_param=NR Positioning Profile distinguished name
        ...    new_value=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSPR-0   abbr=nrPosDN
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${NRCELL_id}
        ...    filter_param=Activate PRB blanking
        ...    new_value=true   abbr=actPRBBlanking
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${NRCELL_id}
        ...    filter_param=Number of blanked PRBs in high edge of downlink side
        ...    new_value=5   abbr=nbrOfBlankedPRBsHighEdgeDL
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${NRCELL_id}
        ...    filter_param=Number of blanked PRBs in high edge of uplink side
        ...    new_value=5   abbr=nbrOfBlankedPRBsHighEdgeUL
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${NRCELL_id}
        ...    filter_param=Number of blanked PRBs in low edge of downlink side
        ...    new_value=5   abbr=nbrOfBlankedPRBsLowEdgeDL
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${NRCELL_id}
        ...    filter_param=Number of blanked PRBs in low edge of uplink side
        ...    new_value=5   abbr=nbrOfBlankedPRBsLowEdgeUL
    END
    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}
    ...    filter_param=Allow slow static NDM-SRS PRB pooling   new_value=false   abbr=allowSlowPrbPoolingStatNdmSrs
    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-1
        ...    filter_param=Channel bandwidth
        ...    new_value=100MHz   abbr=chBw
    selenium_coam.save_bts_configuration    save_configuration_type=${0}
    ${error}    selenium_coam.validate_plan
    Log To Console    ${error}
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    [Teardown]    WEBUI Logout


Check CB007880-C-005 counters
    ${nrPosDN_cell_id_list}    Create List    0    1    9
    ${befor_counter_all}    Create Dictionary
    ${after_counter_all}    Create Dictionary
    ${befor_counter_003}   Wait Until Keyword Succeeds    5min   1min   get_bts_counters M55140c00003    counter_name_list=${counter_name_003}
    ...    counter_ids=M55140C00003
    FOR   ${NRCELL_id}    IN    @{nrPosDN_cell_id_list}
        ${befor_counter_cell}   Wait Until Keyword Succeeds    5min   1min   get_bts_counters    counter_name_list=${counter_name}
        ...    counter_ids=M55181C00017,M55181C00020    NRCELL_ID=NRCELL-${NRCELL_id}
        set to dictionary    ${befor_counter_all}    ${NRCELL_id}    ${befor_counter_cell}
    END
    UE Attach and check log counter
    ${after_counter_003}   Wait Until Keyword Succeeds    5min   1min   get_bts_counters M55140c00003    counter_name_list=${counter_name_003}
    ...    counter_ids=M55140C00003
    FOR   ${NRCELL_id}    IN    @{nrPosDN_cell_id_list}
        ${after_counter_cell}    get_bts_counters    counter_ids=M55181C00017,M55181C00020
        ...    counter_name_list=${counter_name}    NRCELL_ID=NRCELL-${NRCELL_id}
         set to dictionary    ${after_counter_all}    ${NRCELL_id}    ${after_counter_cell}
    END
    FOR   ${NRCELL_id}    IN    @{nrPosDN_cell_id_list}
        ${befor_counter}    Get From Dictionary    ${befor_counter_all}    ${NRCELL_id}
        ${after_counter}    Get From Dictionary    ${after_counter_all}    ${NRCELL_id}
        ${all_counter_value_list}    Case7_Count_counter_value    befor_counter_list=${befor_counter}    after_counter_list=${after_counter}
        ${M55181C00017_result}    ${M55181C00017_none_zero_result}    Check_list_Only_Contain_one_value
        ...    input_list=${all_counter_value_list[0]}    check_value=0
        ${M55181C00020_result}    ${M55181C00020_none_zero_result}    Check_list_Only_Contain_one_value
        ...    input_list=${all_counter_value_list[1]}    check_value=0
        ${M55181C00017_len}    Get Length    ${M55181C00017_none_zero_result}
        ${M55181C00020_len}    Get Length    ${M55181C00020_none_zero_result}
        ${M55181C00017_last}    Evaluate    ${M55181C00017_len} - 1
        ${M55181C00020_last}    Evaluate    ${M55181C00020_len} - 1
        check cell counter    counter_result=${M55181C00017_none_zero_result}    count_result_exp=${1}
        check cell counter    counter_result=${M55181C00020_none_zero_result}    count_result_exp=${300}
    END
    ${all_counter_value_list}    Case7_Count_counter_value    befor_counter_list=${befor_counter_003}    after_counter_list=${after_counter_003}
    ${M55140c00003_result}    ${M55140c00003_none_zero_result}    Check_list_Only_Contain_one_value
    ...    input_list=${all_counter_value_list[0]}    check_value=0
    ${M55140c00003_len}    Get Length    ${M55140c00003_none_zero_result}
    ${M55140c00003_last}    Evaluate    ${M55140c00003_len} - 1
    check cell counter    counter_result=${M55140c00003_none_zero_result}    count_result_exp=${1}

check cell counter
    [Arguments]    ${counter_result}=${M55181C00017_none_zero_result}    ${count_result_exp}=${1}    ${Result}=${0}
    FOR   ${count}    IN    @{counter_result}
        ${Result}    Run Keyword If    "${count}"=="${count_result_exp}"    Evaluate    ${Result}+1
        ...    ELSE    Evaluate    ${Result}+0
    END
    Run Keyword And Continue On Failure    Should Be True    ${Result}>${0}

get_bts_counters
    [Arguments]    ${counter_ids}    ${counter_name_list}    ${NRCELL_ID}=${NRCELL1_ID}    ${connection}=GNB_OAM
    @{counter_value_list}    Create list
    ${counter_id_list}    Split String    ${counter_ids}    separator=,
    ${counter_len}    Get Length    ${counter_name_list}
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    Log To Console    get bts counter
    ${counter_value}    coam.get_PM_counters    counter_ids=${counter_ids}    connection=${connection}
    FOR  ${item}  IN RANGE    0    ${counter_len}
        ${counter_id}    Set Variable    ${counter_id_list[${item}]}
        ${counter_name}    Set Variable    ${counter_name_list[${item}]}
        ${result}    Set Variable
        ...    ${counter_value['BTS']['MRBTS-${TL_BTS_ID}']['NRBTS-${TL_NRBTS_ID}']['${NRCELL_ID}']['${counter_name}']['${counter_id}']}
        Append To List    ${counter_value_list}    ${result}
    END
    [Return]    ${counter_value_list}
    [Teardown]    run keyword and ignore error    coam.teardown      connection=${connection}

get_bts_counters M55140c00003
    [Arguments]    ${counter_ids}    ${counter_name_list}    ${connection}=GNB_OAM
    @{counter_value_list}    Create list
    ${counter_id_list}    Split String    ${counter_ids}    separator=,
    ${counter_len}    Get Length    ${counter_name_list}
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    Log To Console    get bts counter
    ${counter_value}    coam.get_PM_counters    counter_ids=${counter_ids}    connection=${connection}
    FOR  ${item}  IN RANGE    0    ${counter_len}
        ${counter_id}    Set Variable    ${counter_id_list[${item}]}
        ${counter_name}    Set Variable    ${counter_name_list[${item}]}
        ${result}    Set Variable
        ...    ${counter_value['BTS']['MRBTS-${TL_BTS_ID}']['NRBTS-${TL_NRBTS_ID}']['${counter_name}']['${counter_id}']}
        Append To List    ${counter_value_list}    ${result}
    END
    [Return]    ${counter_value_list}
    [Teardown]    run keyword and ignore error    coam.teardown      connection=${connection}

########################CB007880-G-001###########################
configuration 6 normal cell within one shared trp group
    WEBUI Login    bts_host=${gNB_ip}
    FOR    ${item}    IN RANGE    ${6}
        ${NRCELL_id}    Evaluate    ${item} + 1
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${NRCELL_id}
        ...    filter_param=NR Positioning Profile distinguished name
        ...    new_value=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSPR-0   abbr=nrPosDN
    END
    selenium_coam.save_bts_configuration    save_configuration_type=${0}
    ${error}    selenium_coam.validate_plan
    Log To Console    ${error}
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    [Teardown]    WEBUI Logout

UE Attach and check log CB007880-G-001
    [Arguments]    ${ue_inex}=1
    ${message_list}    Create List    id-positioningInformationUpdate
    ${ue_index_list}    Create List    ${ue_inex}
    CB010680_BIP.Start Catch TCPDUMP SCTP Log    filename=Tcpdump.pcap
    CB010680_UE.UE Attach    gnb_index=${0}    ue_index=${ue_inex}
    Trigger SRS Measurement From LMF   ue_index=${ue_inex}
    sleep    30s
    CB010680_BIP.Stop And Copy TCPDUMP To UTE    filename=Tcpdump.pcap
    sleep    3s
    CB010680_BIP.Start Catch TCPDUMP SCTP Log    filename=Tcpdump_HO.pcap
    Adjust the HBTE attenuation value    value=${20}    port_list=${port_list_cell5}
    sleep    1min
    CB010680_BIP.Stop And Copy TCPDUMP To UTE    filename=Tcpdump_HO.pcap
    ${utc_time}    robot.libraries.DateTime.Get Current Date
    ${log_time}    change_format_for_utr_time    utc_time=${utc_time}
    Set Test Variable    ${log_time}
    ${pcap_log_path_lst}    Common Capture BIP log and download    target_dir=${OUTPUT_DIR}/${TEST NAME}    target_file_name=bip_srs_${log_time}
    ${srsConfig}    ${startPrb}    ${prbNum}    Get srsForPositioning For Specfic Cell    bts_host=${gNB_ip}
    ...     username=${gNB_username}    password=${gNB_password}    cell_id=${1}
    Check BIP Log SRS TOE Is Expected    pcap_log_path=${pcap_log_path_lst[0]}
    ...    srsUePeriodicity=${srsConfig['srsUePeriodicity']}    csrs=${srsConfig['cSRS']}    expected_startPrb=${startPrb}
    Pcap chang to txt    pcap_name=Tcpdump_HO.pcap    text_name=Tcpdump_HO.txt
#    Check wireshark log data Flow message    sgnb_chg_flow_message=${sgnb_chg_flow_message}   txt_filename=Tcpdump_HO.txt
    [Teardown]    UE stop traffic and detach    ue_index_list=${ue_index_list}


Adjust PA
    [Arguments]      ${value_0}    ${value_1}    ${port_list_0}    ${port_list_1}
    Adjust the HBTE attenuation value    value=${value_0}    port_list=${port_list_0}
    Adjust the HBTE attenuation value    value=${value_1}     port_list=${port_list_1}

Adjust the HBTE attenuation value
    [Arguments]      ${value}    ${port_list}
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${127}    vendor=HBTE
    ...    model=${model}
    FOR    ${port_num}    IN    @{port_list}
        att.set_attenuation     port=${port_num}    value=${value}
        ${value_port}    att.read_attenuation    port=${port_num}
        should be equal    ${value_port}    ${value}
    END
    sleep  3s

Check wireshark log Parameter
    [Arguments]     ${txt_filename}     ${sgnb_chg_ho_message}      ${logpath}=${OUTPUT_DIR}/${TEST NAME}
    ${val_result}    Check_Wireshark_Parameter_From_Txt    txt_file_path=${logpath}/${txt_filename}
    ...    parameters=${sgnb_chg_ho_message}
    ${val_list}     set variable    ${val_result}[resultList]
    FOR    ${val1}    IN    @{val_list}
        Run Keyword And Continue On Failure    should be equal    ${val1}    ${True}
    END

Pcap chang to txt
    [Arguments]    ${pcap_name}=Tcpdump.pcap    ${text_name}=Tcpdump.txt    ${logpath}=${OUTPUT_DIR}/${TEST NAME}
    Convert pcap to text    source=${logpath}/${pcap_name}    target=${logpath}/${text_name}

Convert pcap to text
    [Arguments]    ${source}    ${target}    ${filter}=ngap
    ssh.Connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}    password=${UTE_PASSWORD}    alias=UTE
    Log To Console    Convert pcap to text
    ssh.send_command
    ...    command=nice tshark -V -r ${source} -T text > ${target} -Y '${filter}'
    ...    connection=UTE
    sleep    10s
    ssh.await execution end    connection=UTE    timeout=10min
    [Teardown]    ssh.disconnect    connection=UTE

Check wireshark log data Flow message
    [Arguments]    ${sgnb_chg_flow_message}   ${txt_filename}     ${logpath}=${OUTPUT_DIR}/${TEST NAME}
    ${val_result}    Check Wireshark Message Flow From Txt    txt_file_path=${logpath}/${txt_filename}  message_dict=${sgnb_chg_flow_message}
    Run Keyword And Continue On Failure    should be equal    ${val_result}    ${True}


########################CB007880-B-005_step###########################
configuration 2 shared trp group with 6 AWHQN and 3 AWHQ2
    WEBUI Login    bts_host=${gNB_ip}
    wait until keyword succeeds    3x   1min
    ...    selenium_coam.add_object
    ...    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}   object_class_name=NRPOSPR
    ...    id_value=0
    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSPR-0
    ...    filter_param=Reuse group number   new_value=6   abbr=reuseGroupNumber
    wait until keyword succeeds    3x   1min
    ...    selenium_coam.add_object
    ...    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}   object_class_name=NRPOSPR
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSPR-0
    ...    include_subobject=${TRUE}    id_value=1
    wait until keyword succeeds    3x   1min
    ...    selenium_coam.add_object
    ...    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}   object_class_name=NRPOSPR
    ...    id_value=1
    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSPR-1
    ...    filter_param=Reuse group number   new_value=6   abbr=reuseGroupNumber
    wait until keyword succeeds    3x   1min
    ...    selenium_coam.add_object
    ...    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}   object_class_name=NRPOSPR
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSPR-1
    ...    include_subobject=${TRUE}    id_value=1
    ${nrPosDN_cell_id_list}    Create List    2    5
    FOR   ${NRCELL_id}    IN    @{nrPosDN_cell_id_list}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${NRCELL_id}
        ...    filter_param=NR Positioning Profile distinguished name
        ...    new_value=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSPR-0   abbr=nrPosDN
    END
    selenium_coam.save_bts_configuration    save_configuration_type=${0}
    ${error}    selenium_coam.validate_plan
    Log To Console    ${error}
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    [Teardown]    WEBUI Logout


########################[1]CB007880-D-0012_step###########################
configuration CB007880-D-0012 parameter to 2NR2NRPOSCELL
    WEBUI Login    bts_host=${gNB_ip}
    ADD NRPOSCELL    NRPOSCELL_NUM=${2}
    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSPR-0
    ...    filter_param=Reuse group number   new_value=2   abbr=reuseGroupNumber
    FOR   ${item}    IN RANGE    ${2}
        ${id}    Evaluate    1 + ${item}
        ${lcrId}    Evaluate    2 - ${item}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${id}
        ...    filter_param=NR Positioning Profile distinguished name
        ...    new_value=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSPR-0   abbr=nrPosDN
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${id}/NRREL-256
        ...    filter_param=Local cell resource identifier of related neighbor cell
        ...    new_value=${lcrId}    abbr=lcrId
    END
    Delete NRCELL    CELL_NUM=${4}    NRCELL_start_id=${3}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}
    ...    filter_param=Allow slow static NDM-SRS PRB pooling
    ...    new_value=false    abbr=allowSlowPrbPoolingStatNdmSrs
    selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-2/NRREL-255
    selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-2/NRREL-256
    selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-1/NRREL-255
    selenium_coam.save_bts_configuration    save_configuration_type=${0}
    ${error}    selenium_coam.validate_plan
    Log To Console    ${error}
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    [Teardown]    WEBUI Logout

configuration 2NR2NRPOSCELL parameter to 3NR3NRPOSCELL
    WEBUI Login    bts_host=${gNB_ip}
    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSPR-0
    ...    filter_param=Reuse group number   new_value=3   abbr=reuseGroupNumber
    ADD NRPOSCELL single
    ${add_NRcell_id}    set variable    3
    Log To Console    add NRCELL-${add_NRcell_id}
    wait until keyword succeeds    3x   1min
    ...    selenium_coam.add_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}   object_class_name=NRCELL
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-1
    ...    include_subobject=${TRUE}    id_value=${add_NRcell_id}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${add_NRcell_id}
    ...    filter_param=Local cell resource ID   new_value=${add_NRcell_id}   abbr=lcrId
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${add_NRcell_id}
    ...    filter_param=Physical cell identifier   new_value=67   abbr=physCellId
    wait until keyword succeeds    3x   1min
    ...    selenium_coam.add_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}   object_class_name=NRCELLGRP
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELLGRP-1
    ...    include_subobject=${TRUE}    id_value=$${add_NRcell_id}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELLGRP-${add_NRcell_id}
    ...    filter_param=List of NR cells assigned to cell group   node_index=${0}    new_value=${add_NRcell_id}   abbr=nrCellList
    selenium_coam.add_element    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRDU-1
    ...    filter_param=Reference to cell group    abbr=refNrCellGroup
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRDU-1
    ...    filter_param=Reference to cell group    new_value=${add_NRcell_id}   node_index=${2}  abbr=refNrCellGroup

    wait until keyword succeeds    3x   1min
    ...    selenium_coam.add_object    object_name=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1   object_class_name=LCELNR
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1
    ...    include_subobject=${TRUE}    id_value=${add_NRcell_id}
    Set Channelgroup Parameter CB10680    group_id=${1}
    ...    ru_id=${add_NRcell_id}    cell_id=${add_NRcell_id}    times=${8}
    selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-3/NRREL-255
    selenium_coam.save_bts_configuration    save_configuration_type=${0}
    ${error}    selenium_coam.validate_plan
    Log To Console    ${error}
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    [Teardown]    WEBUI Logout

ADD NRPOSCELL
    [Arguments]     ${NRPOSCELL_start_ID}=${1}    ${NRPOSCELL_NUM}=${2}
    FOR   ${item}    IN RANGE    ${NRPOSCELL_NUM}
        ${NRPOSCELL_ID}    Evaluate    ${NRPOSCELL_start_ID} + ${item}
        ${RU_ID}    Evaluate    ${9} - ${NRPOSCELL_ID}
        wait until keyword succeeds    3x   1min
        ...    selenium_coam.add_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}   object_class_name=NRPOSCELL
        ...    id_value=${NRPOSCELL_id}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_ID}
        ...    filter_param=Local cell resource identifier of positioning New Radio cell
        ...    new_value=${RU_ID}  abbr=lcrId
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_ID}
        ...    filter_param=NR cell configuration identifier
        ...    new_value=${NRPOSCELL_ID}   abbr=nrCellId
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_ID}
        ...    filter_param=NR Position Cell Type
        ...    new_value=0DL4UL   abbr=nrPosCellType
        # 26R3 default value antennaMode 4RX to Not configured
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_ID}
        ...    filter_param=Antenna mode of NR Position Cell
        ...    new_value=4RX   abbr=antennaMode
        selenium_coam.add_element    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_ID}/NRTRPINFO-1
        ...    filter_param=NG RAN access point position    abbr=nGRanAccessPointPosition
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_ID}/NRTRPINFO-1
        ...    filter_param=Altitude    new_value=${141}    abbr=altitude
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_ID}/NRTRPINFO-1
        ...    filter_param=Degrees of latitude
        ...    new_value=${degreesOfLatitude_lst}[${NRPOSCELL_ID}]    abbr=degreesOfLatitude
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_ID}/NRTRPINFO-1
        ...    filter_param=Degrees of longitude
        ...    new_value=${degreesOfLongitude_lst}[${NRPOSCELL_ID}]   abbr=degreesOfLongitude
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_ID}/NRTRPINFO-1
        ...    filter_param=Direction of altitude
        ...    new_value=Height    abbr=directionOfAltitude
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_ID}/NRTRPINFO-1
        ...    filter_param=Latitude sign
        ...    new_value=North   abbr=latitudeSign
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_ID}/NRTRPINFO-1
        ...    filter_param=Orientation of major axis    new_value=${13}    abbr=orientationOfMajorAxis
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_ID}/NRTRPINFO-1
        ...    filter_param=Uncertainty altitude    new_value=${10}    abbr=uncertaintyAltitude
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_ID}/NRTRPINFO-1
        ...    filter_param=Uncertainty semi-major   new_value=${98}    abbr=uncertaintySemiMajor
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_ID}/NRTRPINFO-1
        ...    filter_param=Uncertainty semi-minor    new_value=${68}    abbr=uncertaintySemiMinor

        wait until keyword succeeds    3x   1min
        ...    selenium_coam.add_object    object_name=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1   object_class_name=LCELNR
        ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1
        ...    include_subobject=${TRUE}    id_value=${RU_ID}

        FOR   ${item}    IN RANGE    ${4}
            ${id}    Evaluate     1 + ${item} * 2
            ${id1}    Evaluate     1 + ${id}
            ${ant_id}    Evaluate     1 + ${item}
            selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${RU_ID}/CHANNELGROUP-1/CHANNEL-${id}
            selenium_coam.set_parameter_value
            ...    dist_name=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${RU_ID}/CHANNELGROUP-1/CHANNEL-${id1}
            ...    filter_param=Distinguished Name of antenna line   new_value=MRBTS-37611/EQM-1/APEQM-1/RMOD-${RU_ID}/ANTL-${ant_id}   abbr=antlDN
        END
    END

ADD NRPOSCELL single
    [Arguments]     ${NRPOSCELL_ID}=${3}    ${RU_ID}=${4}
    wait until keyword succeeds    3x   1min
    ...    selenium_coam.add_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}   object_class_name=NRPOSCELL
    ...    id_value=${NRPOSCELL_id}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_ID}
    ...    filter_param=Local cell resource identifier of positioning New Radio cell
    ...    new_value=${RU_ID}  abbr=lcrId
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_ID}
    ...    filter_param=NR cell configuration identifier
    ...    new_value=${NRPOSCELL_ID}   abbr=nrCellId
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_ID}
    ...    filter_param=NR Position Cell Type
    ...    new_value=0DL4UL   abbr=nrPosCellType
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_ID}
    ...    filter_param=Antenna mode of NR Position Cell
    ...    new_value=4RX   abbr=antennaMode

    selenium_coam.add_element    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_ID}/NRTRPINFO-1
    ...    filter_param=NG RAN access point position    abbr=nGRanAccessPointPosition
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_ID}/NRTRPINFO-1
    ...    filter_param=Altitude    new_value=${141}    abbr=altitude
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_ID}/NRTRPINFO-1
    ...    filter_param=Degrees of latitude
    ...    new_value=${degreesOfLatitude_lst}[${NRPOSCELL_ID}]    abbr=degreesOfLatitude
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_ID}/NRTRPINFO-1
    ...    filter_param=Degrees of longitude
    ...    new_value=${degreesOfLongitude_lst}[${NRPOSCELL_ID}]   abbr=degreesOfLongitude
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_ID}/NRTRPINFO-1
    ...    filter_param=Direction of altitude
    ...    new_value=Height    abbr=directionOfAltitude
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_ID}/NRTRPINFO-1
    ...    filter_param=Latitude sign
    ...    new_value=North   abbr=latitudeSign
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_ID}/NRTRPINFO-1
    ...    filter_param=Orientation of major axis    new_value=${13}    abbr=orientationOfMajorAxis
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_ID}/NRTRPINFO-1
    ...    filter_param=Uncertainty altitude    new_value=${10}    abbr=uncertaintyAltitude
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_ID}/NRTRPINFO-1
    ...    filter_param=Uncertainty semi-major   new_value=${98}    abbr=uncertaintySemiMajor
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_ID}/NRTRPINFO-1
    ...    filter_param=Uncertainty semi-minor    new_value=${68}    abbr=uncertaintySemiMinor

    wait until keyword succeeds    3x   1min
    ...    selenium_coam.add_object    object_name=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1   object_class_name=LCELNR
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1
    ...    include_subobject=${TRUE}    id_value=${RU_ID}

    FOR   ${item}    IN RANGE    ${4}
        ${id}    Evaluate     1 + ${item} * 2
        ${id1}    Evaluate     1 + ${id}
        ${ant_id}    Evaluate     1 + ${item}
        selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${RU_ID}/CHANNELGROUP-1/CHANNEL-${id}
        selenium_coam.set_parameter_value
        ...    dist_name=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${RU_ID}/CHANNELGROUP-1/CHANNEL-${id1}
        ...    filter_param=Distinguished Name of antenna line   new_value=MRBTS-37611/EQM-1/APEQM-1/RMOD-${RU_ID}/ANTL-${ant_id}   abbr=antlDN
    END


ADD NRPOSPR
    [Arguments]     ${NRPOSPR_NUM}    ${reuseGroupNumber}=${2}
    FOR   ${item}    IN RANGE    ${NRPOSPR_NUM}
        ${NRPOSPR_id}    Evaluate     1 + ${item}
        wait until keyword succeeds    3x   1min
        ...    selenium_coam.add_object
        ...    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}   object_class_name=NRPOSPR
        ...    id_value=${NRPOSPR_id}
        selenium_coam.set_parameter_value
        ...    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSPR-${NRPOSPR_id}
        ...    filter_param=Reuse group number   new_value=${reuseGroupNumber}   abbr=reuseGroupNumber
    END

Delete NRCELL
    [Arguments]     ${CELL_NUM}    ${NRCELL_start_id}
    FOR   ${item}    IN RANGE    ${CELL_NUM}
        ${node_index}    Evaluate     6 - ${NRCELL_List}[${item}]
        ${cell_id}    Evaluate     ${NRCELL_start_id} + ${item}
        selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${cell_id}
        selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELLGRP-${cell_id}
        selenium_coam.remove_element   dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRDU-1
        ...    filter_param=Reference to cell group    node_index= ${node_index}   abbr=refNrCellGroup
        selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}
    END


########################[1]CB007880-D-0013_step###########################
configuration CB007880-D-0013 parameter to 4NR4NRPOSCELL
    WEBUI Login    bts_host=${gNB_ip}
    FOR   ${item}    IN RANGE    2
        ${node_index}    Evaluate     6 - ${NRCELL_List}[${item}]
        ${cell_id}    Evaluate     ${5} + ${item}
        selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${cell_id}
        selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELLGRP-${cell_id}
        selenium_coam.remove_element   dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRDU-1
        ...    filter_param=Reference to cell group    node_index= ${node_index}   abbr=refNrCellGroup
    END
    ADD NRPOSCELL    NRPOSCELL_NUM=${2}
    FOR   ${item}    IN RANGE    2
        ${NRPOSCELL_ID}    Evaluate    ${3} + ${item}
        ${RU_ID}    Evaluate    ${9} - ${NRPOSCELL_ID}
        wait until keyword succeeds    3x   1min
        ...    selenium_coam.add_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}   object_class_name=NRPOSCELL
        ...    id_value=${NRPOSCELL_id}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_ID}
        ...    filter_param=Local cell resource identifier of positioning New Radio cell
        ...    new_value=${RU_ID}  abbr=lcrId
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_ID}
        ...    filter_param=NR cell configuration identifier
        ...    new_value=${NRPOSCELL_ID}   abbr=nrCellId
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_ID}
        ...    filter_param=NR Position Cell Type
        ...    new_value=0DL4UL   abbr=nrPosCellType
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_ID}
        ...    filter_param=Antenna mode of NR Position Cell
        ...    new_value=4RX   abbr=antennaMode

        selenium_coam.add_element    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_ID}/NRTRPINFO-1
        ...    filter_param=NG RAN access point position    abbr=nGRanAccessPointPosition
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_ID}/NRTRPINFO-1
        ...    filter_param=Altitude    new_value=${141}    abbr=altitude
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_ID}/NRTRPINFO-1
        ...    filter_param=Degrees of latitude
        ...    new_value=${degreesOfLatitude_lst}[${NRPOSCELL_ID}]    abbr=degreesOfLatitude
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_ID}/NRTRPINFO-1
        ...    filter_param=Degrees of longitude
        ...    new_value=${degreesOfLongitude_lst}[${NRPOSCELL_ID}]   abbr=degreesOfLongitude
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_ID}/NRTRPINFO-1
        ...    filter_param=Direction of altitude
        ...    new_value=Height    abbr=directionOfAltitude
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_ID}/NRTRPINFO-1
        ...    filter_param=Latitude sign
        ...    new_value=North   abbr=latitudeSign
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_ID}/NRTRPINFO-1
        ...    filter_param=Orientation of major axis    new_value=${13}    abbr=orientationOfMajorAxis
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_ID}/NRTRPINFO-1
        ...    filter_param=Uncertainty altitude    new_value=${10}    abbr=uncertaintyAltitude
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_ID}/NRTRPINFO-1
        ...    filter_param=Uncertainty semi-major   new_value=${98}    abbr=uncertaintySemiMajor
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_ID}/NRTRPINFO-1
        ...    filter_param=Uncertainty semi-minor    new_value=${68}    abbr=uncertaintySemiMinor

        FOR   ${item}    IN RANGE    ${4}
            ${id}    Evaluate     1 + ${item} * 2
            selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${RU_ID}/CHANNELGROUP-1/CHANNEL-${id}
        END
    END
    ADD NRPOSPR     NRPOSPR_NUM=${1}    reuseGroupNumber=${2}
    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSPR-0
    ...    filter_param=Reuse group number   new_value=2   abbr=reuseGroupNumber
    ${NRPOSPR_id}    Create List    0    0    1    1
    FOR   ${item}    IN RANGE    ${4}
        ${NRCELL_id}    Evaluate     1 + ${item}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${NRCELL_id}
        ...    filter_param=NR Positioning Profile distinguished name
        ...    new_value=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSPR-${NRPOSPR_id}[${item}]   abbr=nrPosDN
    END
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}
    ...    filter_param=Allow slow static NDM-SRS PRB pooling
    ...    new_value=false    abbr=allowSlowPrbPoolingStatNdmSrs
    selenium_coam.save_bts_configuration    save_configuration_type=${0}
    ${error}    selenium_coam.validate_plan
    Log To Console    ${error}
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    [Teardown]    WEBUI Logout

########################CB007880-I-B1_step###########################
LOCK RU AND CHECK SYSYLOG
    [Arguments]     ${lock_flag}=${True}    ${unlock_RU_id_list}=${empty_list}    ${lock_RU_id_list}=${empty_list}
    ...    ${command}=${command}
    Lock Or Unlock RU And Check Status    lock_RU_id_list=${lock_RU_id_list}    lock_flag=${lock_flag}
    ...    bts_host=${gNB_ip}    allowed_list=${allowed_alarm_list}    unlock_RU_id_list=${unlock_RU_id_list}
    BTSLOG Start btslog on remote machine
    sleep    5s
    Stop BTSLOG Collect btslog on remote machine
    ${data}    check Btslog    command=${command}
    Run keyword and continue on failure    should not be empty     ${data}

UE Attach and check log CB007880-I-B1
    [Arguments]    ${ue_inex}=0
    ${ue_index_list}    Create List    ${ue_inex}
    CB010680_BIP.Start Catch TCPDUMP SCTP Log    filename=ngc.pcap
    CB010680_UE.UE Attach    gnb_index=${0}    ue_index=${ue_inex}
    Trigger SRS Measurement From LMF   ue_index=${ue_inex}
    ${utc_time}    robot.libraries.DateTime.Get Current Date
    ${log_time}    change_format_for_utr_time    utc_time=${utc_time}
    Set Test Variable    ${log_time}
    ${pcap_log_path_lst}    Common Capture BIP log and download    target_dir=${OUTPUT_DIR}/${TEST NAME}    target_file_name=bip_srs_${log_time}
    ${srsConfig}    ${startPrb}    ${prbNum}    Get srsForPositioning For Specfic Cell    bts_host=${gNB_ip}
    ...     username=${gNB_username}    password=${gNB_password}    cell_id=${1}
    CB010680_BIP.Stop And Copy TCPDUMP To UTE    filename=ngc.pcap
    Check BIP Log SRS TOE Is Expected    pcap_log_path=${pcap_log_path_lst[0]}
    ...    srsUePeriodicity=${srsConfig['srsUePeriodicity']}    csrs=${srsConfig['cSRS']}    expected_startPrb=${startPrb}
    ${RU_List}    Create List    4
    ${command_locked}=
    ...    catenate    grep "PositioningMeasurementPeriodicReportHandler.cpp:394 Ignore PosMeasResultPerTrp for blocked subcell,
    ...    nrCellIdentity: 616218628, posSubcellId: 3"
    LOCK RU AND CHECK SYSYLOG    lock_RU_id_list=${RU_List}    command=${command_locked}
   ${command_unlock}=
    ...    catenate    grep "PositioningMeasurementPeriodicReportHandler.cpp:127
    ...    Convert measurement result, TrpId: 4, posMeasResultPerTrp.ulRtoa"
    LOCK RU AND CHECK SYSYLOG    lock_flag=${false}    unlock_RU_id_list=${RU_List}    command=${command_unlock}
    [Teardown]    UE stop traffic and detach    ue_index_list=${ue_index_list}

########################Start_BTSLOG_check###########################
BTSLOG Start btslog on remote machine
    [Arguments]    ${name}=btslog    ${bts_logs_dir}=/tmp/btslog2    ${alias}=ute
    csn.Connect to    hostname=${UTE_ADDRESS}   username=${UTE_USERNAME}    password=${UTE_PASSWORD}    alias=${alias}
    csn.Send Command  command=rm -rf /tmp/btslog2    connection=ute
    sleep    1s
    csn.send_command  command=if [ ! -d ${bts_logs_dir} ]; then mkdir ${bts_logs_dir}; else rm ${bts_logs_dir}/*; fi    connection=${alias}
    &{executor}=    create dictionary    host=${UTE_ADDRESS}    user=${UTE_USERNAME}    password=${UTE_PASSWORD}
    btslog.create_btslog_collector    name=${name}    log_dir=${bts_logs_dir}    executor=${executor}
    core.setup_collectors        names=${name}
    core.start_collectors        names=${name}
    btslog.set_suite_alias       ${name}

Stop BTSLOG Collect btslog on remote machine
    [Arguments]   ${name}=btslog
    core.stop_collectors         names=${name}
    Wait until keyword succeeds  3x  3s    core.collect_collectors      names=${name}
    core.teardown_collectors     names=${name}
    [Teardown]  Run Keyword And Ignore error    Csn.Disconnect	connection=ute

Check Btslog
    [Arguments]    ${alias}=ute    ${command}=${command}
    ...    ${btslog_path}=${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/btslog
    csn.Connect to     hostname=${UTE_ADDRESS}   username=${UTE_USERNAME}    password=${UTE_PASSWORD}  alias=${alias}
    sleep    1s
    csn.execute    command=tar zxvf ${btslog_path}/syslog_files.tgz -C ${btslog_path}/    connection=${alias}
    sleep    1s
    csn.execute    command=cd ${btslog_path}; mv *.LOG ${btslog_path}/bts_log.log    connection=${alias}
    sleep    1s
    csn.Send Command  command=cat ${btslog_path}/bts_log.log|${command}    connection=ute
    sleep    1s
    ${data}    csn.Read Output    connection=ute
    ${data}    strip_string    ${data}
    csn.Send Command  command=rm -rf /tmp/btslog2    connection=ute
    sleep    1s
    [Return]    ${data}
    [Teardown]    csn.Disconnect   connection=ute
