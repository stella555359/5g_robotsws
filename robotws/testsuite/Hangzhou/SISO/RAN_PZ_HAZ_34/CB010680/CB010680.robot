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
Variables    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB010680/Resource/CB010680_Params.py


Suite Setup    Common Suit Setup CB10680
Suite Teardown    Common Suit Teardown CB10680

*** Variables ***
${LOOP_TIMES}    ${2}
@{cell_id_list}    4    5    6    7    8
@{RMOD_id_list}    7    8
@{CHANNEL_id_list}    1    3    5    7
#trp selection low precision position
#@{degreesOfLatitude_lst}    2848950    2848958    2848967    2848975    2848984    2848992    2849000    2849009
#@{degreesOfLongitude_lst}    4850193    4850196    4850199    4850201    4850204     4850207    4850210    4850212
#trp selection high precision position
@{degreesOfLatitude_lst}    2850210    2850629    2851049    2851469    2851889    2852309    2852729    2853148
@{degreesOfLongitude_lst}    4850609    4850747    4850886    4851024    4851163    4851301   4851440    4851578

@{nrcellId_list}    616218625    616218626    616218627    616218628    616218629    616218630    616218631    616218632

*** Test Cases ***
[1]CB010680_E_001_online_add_RU-SRS_Precise_Positioning_NormalCell_for_RU-ACCESS_via_Commissioning_Wizard
    [Tags]    CB010680_G    T714
    [Documentation]    optimization CIT to cover most important function and make sure execution time for branch+trunk
    ...    move some test step from CIT [1][1.0]CB010680_G_RRM_003_different_structure_Prach_index_Ru_Access to CRT
    [Setup]    robot_common_operations.Common case Setup
    Log To Console    modify tdd frame structure to 2
    modify the parameter case CB010680    bts_host=${gNB_ip}    username=${gNB_username}
    ...    password=${gNB_password}   connection=GNB_OAM    input_list=${tddFrameStructure_all_2}
    Check GNB on air And alarm    bts_host=${gNB_ip}    allowed_list=${allowed_alarm_list}    time=20min
    UE Attach and check log    ue_inex=${0}    pci=none    subcell_num=${0}    srs_cell_num=${0}
    [Teardown]    CB010680_A Common Teardown With TMO SCF Restore

[1]CB007880-D-001_Precise_Position_supercell_RU_Access_RU_SRS_wo_share_TRP_central_antenna
    [Tags]    CB007880-D    T714
    [Documentation]    purpose to verify suppercell + nrposcell + cb008046 4:6 framestructure
    [Setup]    robot_common_operations.Common case Setup
    modify the parameter case CB010680    bts_host=${gNB_ip}    username=${gNB_username}
    ...    password=${gNB_password}   connection=GNB_OAM    input_list=${tddFrameStructure_all_cb008406}
    Check GNB on air And alarm    bts_host=${gNB_ip}    allowed_list=${allowed_alarm_list}    time=10min
    configuration 6normal cell to 1super2sub and 4Nrposition
    UE Attach start traffic and check log CB10680    nrcellId_list=${nrcellId_list[0:1]}
    [Teardown]    CB010680_A Common Teardown With TMO SCF Restore

[1][1.0]CB010680_G_002_ABIP_RU_Access_RU_SRS_P_SRS_Reception_supercell_with_PRBblanking
    [Tags]    CB010680_G    T714
    [Setup]    robot_common_operations.Common case Setup
    configuration 6normal cell to 1super2sub and 4Nrposition
    UE Attach start traffic and check log CB10680    nrcellId_list=${nrcellId_list[0:1]}
   [Teardown]    CB010680_A Common Teardown With TMO SCF Restore

[1]CB010680_D_011_NRPOSCELL_Lock_half_ABIQ_3_RU-ACCESS_and_half_6_RU_SRS
    [Tags]    CB010680_G    T714
    [Setup]    robot_common_operations.Common case Setup
    step1-configurate 6 normal cells to 3 normal cells with 2 nrposcells per normal cell
    UE Attach start traffic and check log CB10680    nrcellId_list=${nrcellId_list[0:3]}
    [Teardown]    CB010680_A Common Teardown With TMO SCF Restore


[1]CB010680_G_006_1868_detected_with_NRPOSCELL_rescource_limited
    [Tags]    CB010680_G    T714
    [Setup]    robot_common_operations.Common case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=4799
    AlarmWatchdog.add_allow_alarms    fault_id=1868
    step1-configurate CELL-7 AND NRPOSITON-CELL-8
    sleep    5min
    Wait until keyword succeeds    5 min    10 sec    Expect Fault Should Present    faultId=4799    severity=Minor
    ...    alarmId=7115    configObjectName=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${cell_id_list[3]}
    ...    supplementary=Affected positioning cell(s): NRPOSCELL_R-8 (trpIds: 8, nrPosCellIdentity: 616218632)
    Wait until keyword succeeds    5 min    10 sec    Expect Fault Should Present    faultId=1868    severity=Critical
    ...    alarmId=7114    configObjectName=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${cell_id_list[4]}
    ...    supplementary=Not enough DSP resources on baseband HW compatible for NRPOSCELL allocation
#    UE attach and check traffic CB010680    nrcellId_list=${nrcellId_list[0:7]}
    Delete NRPOSCELL-8
    AlarmWatchdog.remove_allow_alarms    fault_id=1868
    AlarmWatchdog.remove_allow_alarms    fault_id=4799
    [Teardown]    CB010680_A Common Teardown With TMO SCF Restore




*** Keywords ***
Common Suit Setup CB10680
        robot_common_operations.Common Suite Setup
        CI_interface.Common Suite Setup

Common Suit Teardown CB10680
    robot_common_operations.Common Suite Teardown

Common Teardown
        Run Keyword If    "${TEST_STATUS}"=="FAIL"    Save Snapshot    bts_host=${gNB_ip}
        Run Keyword And Ignore Error    Check Fault 6832 SAS Server Lost
        Run Keyword And Ignore Error    Setup Commission SCF
        Run Keyword And Ignore Error    Check GNB on air And alarm    bts_host=${gNB_ip}
        ...    allowed_list=${allowed_alarm_list}    time=20min
        SISO_common_operation.Common Case Teardown    bts_host=${gNB_ip}

step1-configurate 6 normal cells to 3 normal cells with 2 nrposcells per normal cell
    Log To Console    configurate 6 NR-CELLs to 3 NRCELLs + 6 NRPOSCELLs, each NRCELL mapping 2 NRPOSCELLs
    ${CHANNEL_id_list}    Create List    1    3    5    7
    ${RMOD_id_list}    Create List    7    8
    ${NRCELL_id_list}    Create List    1    1    2    2    3    3
    ${Delete_cell_id_list}    Create List    4    5    6
    WEBUI Login    bts_host=${gNB_ip}
    ######################delete_RMOD4/5/6_TX######################
    FOR    ${cell_id}    IN    @{Delete_cell_id_list}
        FOR    ${item}    IN RANGE    ${4}
           Log To Console    remove LCELNR-${cell_id}/CHANNELGROUP-1/CHANNEL-${CHANNEL_id_list[${item}]}
           selenium_coam.remove_object
           ...    object_name=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-1/CHANNEL-${CHANNEL_id_list[${item}]}
        END
    END
    ######################add_RMOD7/8_LCELNR######################
    FOR    ${item}    IN RANGE    2
        Log To Console    add LCELNR-${RMOD_id_list[${item}]} for NRCELL-${RMOD_id_list[${item}]}
        wait until keyword succeeds    3x   1min
        ...    selenium_coam.add_object    object_name=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1   object_class_name=LCELNR
        ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4
        ...    include_subobject=${TRUE}    id_value=${RMOD_id_list[${item}]}
        Set Channelgroup Parameter CB10680    group_id=${1}
        ...    ru_id=${RMOD_id_list[${item}]}    cell_id=${RMOD_id_list[${item}]}
    END
    ######################Delete_NRcell4/5/6######################
    FOR   ${cell_id}    IN    @{Delete_cell_id_list}
        ${node_index}    Evaluate     9 - ${cell_id}
        Log To Console    delete NRCELL-${node_index}
        selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${cell_id}
        selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELLGRP-${cell_id}
        selenium_coam.remove_element   dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRDU-1
        ...    filter_param=Reference to cell group    node_index= ${node_index}   abbr=refNrCellGroup
    END
    ######################add_NRposition_cell4/5/6/7/8######################
    FOR    ${item}    IN RANGE    5
        ${NRPOSCELL_id}    Evaluate    ${item} + 1
        ${trp_id}    Evaluate    ${item} + 3
        Log To Console    add NRPOSCELL-${NRPOSCELL_id} mapping with NRCELL-${NRCELL_id_list[${item}]}
        wait until keyword succeeds    3x   1min
        ...    selenium_coam.add_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}   object_class_name=NRPOSCELL
        ...    id_value=${NRPOSCELL_id}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_id}
        ...    filter_param=Local cell resource identifier of positioning New Radio cell
        ...    new_value=${cell_id_list[${item}]}   abbr=lcrId
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_id}
        ...    filter_param=NR cell configuration identifier
        ...    new_value=${NRCELL_id_list[${item}]}   abbr=nrCellId
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_id}
        ...    filter_param=NR Position Cell Type
        ...    new_value=0DL4UL   abbr=nrPosCellType
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_id}
        ...    filter_param=Antenna mode of NR Position Cell
        ...    new_value=4RX   abbr=antennaMode

        selenium_coam.add_element    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_id}/NRTRPINFO-1
        ...    filter_param=NG RAN access point position    abbr=nGRanAccessPointPosition
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_id}/NRTRPINFO-1
        ...    filter_param=Altitude    new_value=${141}    abbr=altitude
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_id}/NRTRPINFO-1
        ...    filter_param=Degrees of latitude
        ...    new_value=${degreesOfLatitude_lst[${trp_id}]}    abbr=degreesOfLatitude
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_id}/NRTRPINFO-1
        ...    filter_param=Degrees of longitude
        ...    new_value=${degreesOfLongitude_lst[${trp_id}]}   abbr=degreesOfLongitude
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_id}/NRTRPINFO-1
        ...    filter_param=Direction of altitude
        ...    new_value=Height    abbr=directionOfAltitude
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_id}/NRTRPINFO-1
        ...    filter_param=Latitude sign
        ...    new_value=North   abbr=latitudeSign
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_id}/NRTRPINFO-1
        ...    filter_param=Orientation of major axis    new_value=${13}    abbr=orientationOfMajorAxis
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_id}/NRTRPINFO-1
        ...    filter_param=Uncertainty altitude    new_value=${10}    abbr=uncertaintyAltitude
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_id}/NRTRPINFO-1
        ...    filter_param=Uncertainty semi-major   new_value=${98}    abbr=uncertaintySemiMajor
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_id}/NRTRPINFO-1
        ...    filter_param=Uncertainty semi-minor    new_value=${68}    abbr=uncertaintySemiMinor
    END
    selenium_coam.remove_object
    ...    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-1/NRREL-256
    selenium_coam.remove_object
    ...    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-2/NRREL-256
    selenium_coam.save_bts_configuration    save_configuration_type=${0}
    Log To Console    Validate Plan start ...
    selenium_coam.validate_plan
    ${pdl_results}    selenium_coam.get_relation_errors
    Log To Console    Validate Plan result: ${pdl_results}
    Log To Console    Activate Plan start ...
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    Check GNB on air    bts_host=${gNB_ip}    time=6 min
    Check Alarm List on BTS    allowed_list=${allowed_alarm_list}
    [Teardown]   WEBUI Logout


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


step1-configurate CELL-7 AND NRPOSITON-CELL-8
    Log To Console    configurate CELL-7 AND NRPOSITON-CELL-8
    ${CHANNEL_id_list}    Create List    1    3    5    7
    WEBUI Login    bts_host=${gNB_ip}
    ######################add_RMOD7/8_LCELNR######################
    FOR    ${item}    IN RANGE    2
        wait until keyword succeeds    3x   1min
        ...    selenium_coam.add_object    object_name=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1   object_class_name=LCELNR
        ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1
        ...    include_subobject=${TRUE}    id_value=${RMOD_id_list[${item}]}
        Set Channelgroup Parameter CB10680    group_id=${1}
        ...    ru_id=${RMOD_id_list[${item}]}    cell_id=${RMOD_id_list[${item}]}    times=${8}
    END
    FOR    ${item1}    IN RANGE    ${4}
        Log To Console    remove MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-8/CHANNELGROUP-1/CHANNEL-${CHANNEL_id_list[${item1}]}
        selenium_coam.remove_object
        ...    object_name=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-8/CHANNELGROUP-1/CHANNEL-${CHANNEL_id_list[${item1}]}
    END
    ######################add_NRCELL_7######################
    ${add_NRcell_id}    set variable    7
    Log To Console    add NRCELL-${add_NRcell_id}
    wait until keyword succeeds    3x   1min
    ...    selenium_coam.add_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}   object_class_name=NRCELL
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-1
    ...    include_subobject=${TRUE}    id_value=${cell_id_list[3]}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${cell_id_list[3]}
    ...    filter_param=Local cell resource ID   new_value=${cell_id_list[3]}   abbr=lcrId
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${cell_id_list[3]}
    ...    filter_param=Physical cell identifier   new_value=67   abbr=physCellId
    wait until keyword succeeds    3x   1min
    ...    selenium_coam.add_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}   object_class_name=NRCELLGRP
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELLGRP-1
    ...    include_subobject=${TRUE}    id_value=${cell_id_list[3]}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELLGRP-${cell_id_list[3]}
    ...    filter_param=List of NR cells assigned to cell group   node_index=${0}    new_value=${cell_id_list[3]}   abbr=nrCellList
    selenium_coam.add_element    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRDU-1
    ...    filter_param=Reference to cell group    abbr=refNrCellGroup
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRDU-1
    ...    filter_param=Reference to cell group    new_value=${cell_id_list[3]}   node_index=${6}  abbr=refNrCellGroup
    ######################add_NRposition_cell_8######################
    Log To Console    add NRPOSCELL-${cell_id_list[4]} mapping with NRCELL-${cell_id_list[3]}
    wait until keyword succeeds    3x   1min
    ...    selenium_coam.add_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}   object_class_name=NRPOSCELL
    ...    id_value=${cell_id_list[4]}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${cell_id_list[4]}
    ...    filter_param=Local cell resource identifier of positioning New Radio cell
    ...    new_value=${cell_id_list[4]}}   abbr=lcrId
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${cell_id_list[4]}
    ...    filter_param=NR cell configuration identifier
    ...    new_value=${cell_id_list[3]}   abbr=nrCellId
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${cell_id_list[4]}
    ...    filter_param=NR Position Cell Type
    ...    new_value=0DL4UL   abbr=nrPosCellType
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${cell_id_list[4]}
    ...    filter_param=Antenna mode of NR Position Cell
    ...    new_value=4RX   abbr=antennaMode

    selenium_coam.add_element    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${cell_id_list[4]}/NRTRPINFO-1
    ...    filter_param=NG RAN access point position    abbr=nGRanAccessPointPosition
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${cell_id_list[4]}/NRTRPINFO-1
    ...    filter_param=Altitude    new_value=${141}    abbr=altitude
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${cell_id_list[4]}/NRTRPINFO-1
    ...    filter_param=Degrees of latitude
    ...    new_value=${degreesOfLatitude_lst[${7}]}    abbr=degreesOfLatitude
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${cell_id_list[4]}/NRTRPINFO-1
    ...    filter_param=Degrees of longitude
    ...    new_value=${degreesOfLongitude_lst[${7}]}   abbr=degreesOfLongitude
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${cell_id_list[4]}/NRTRPINFO-1
    ...    filter_param=Direction of altitude
    ...    new_value=Height    abbr=directionOfAltitude
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${cell_id_list[4]}/NRTRPINFO-1
    ...    filter_param=Latitude sign
    ...    new_value=North   abbr=latitudeSign
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${cell_id_list[4]}/NRTRPINFO-1
    ...    filter_param=Orientation of major axis    new_value=${13}    abbr=orientationOfMajorAxis
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${cell_id_list[4]}/NRTRPINFO-1
    ...    filter_param=Uncertainty altitude    new_value=${10}    abbr=uncertaintyAltitude
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${cell_id_list[4]}/NRTRPINFO-1
    ...    filter_param=Uncertainty semi-major   new_value=${98}    abbr=uncertaintySemiMajor
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${cell_id_list[4]}/NRTRPINFO-1
    ...    filter_param=Uncertainty semi-minor    new_value=${68}    abbr=uncertaintySemiMinor
    Log To Console    save current plan...
    selenium_coam.save_bts_configuration    save_configuration_type=${0}
    Log To Console    Validate Plan start ...
    selenium_coam.validate_plan
    ${pdl_results}    selenium_coam.get_relation_errors
    Log To Console    Validate Plan result: ${pdl_results}
    Log To Console    Activate Plan start ...
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    [Teardown]   WEBUI Logout

Delete NRPOSCELL-8
    WEBUI Login    bts_host=${gNB_ip}
    Log To Console    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${cell_id_list[4]}
    selenium_coam.remove_object
    ...    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${cell_id_list[4]}
    selenium_coam.remove_object
    ...    object_name=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id_list[4]}
    selenium_coam.save_bts_configuration    save_configuration_type=${0}
    Log To Console    Validate Plan start ...
    selenium_coam.validate_plan
    ${pdl_results}    selenium_coam.get_relation_errors
    Log To Console    Validate Plan result: ${pdl_results}
    Log To Console    Activate Plan start ...
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    Check GNB on air    bts_host=${gNB_ip}    time=6 min
    WEBUI Login    bts_host=${gNB_ip}
    Check Alarm List on BTS    allowed_list=${allowed_alarm_list}
    [Teardown]   WEBUI Logout

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


configuration 6normal cell to 1super2sub and 4Nrposition
    [Arguments]    ${NRCELL_id}=1
    WEBUI Login    bts_host=${gNB_ip}
    ${Delete_cell_id_list}    Create List    2    3    4    5    6
    ${CHANNEL_id_list}    Create List    1    3    5    7
    Log To Console    delete NRCELL-2 and add RMOD-2 into NRCELL-1 for 1 supperCell and 2 subcells
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-1
    ...    filter_param=Activate super cell   new_value=true   abbr=actSuperCell
    wait until keyword succeeds    3x   1min
    ...    selenium_coam.add_object    object_name=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1   object_class_name=CHANNELGROUP
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1
    ...    include_subobject=${TRUE}    id_value=2
    selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2
    wait until keyword succeeds    3x   1min
    ...    selenium_coam.add_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-1
    ...    object_class_name=NRPOSINFO    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-2/NRPOSINFO-1
    ...    include_subobject=${TRUE}
    Run Keyword And Ignore Error    selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-1/NRREL-256
      ######################Delete_NRcell2/3/4/5/6######################
    FOR   ${cell_id}    IN    @{Delete_cell_id_list}
        ${node_index}    Evaluate     7 - ${cell_id}
        Log To Console    delete cell id:${node_index} from NRDU refNrCellGroup
        selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${cell_id}
        selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELLGRP-${cell_id}
        selenium_coam.remove_element   dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRDU-1
        ...    filter_param=Reference to cell group    node_index= ${node_index}   abbr=refNrCellGroup
    END
    FOR    ${item1}    IN RANGE    ${4}
        ${id}    Evaluate     1 + ${item1}
        FOR    ${item}    IN RANGE    ${4}
           ${channel}    Set Variable    CHANNEL-${CHANNEL_id_list[${item}]}
           Log To Console    remove LCELNR-${Delete_cell_id_list[${id}]}/CHANNELGROUP-1/CHANNEL-${channel}
           selenium_coam.remove_object
           ...    object_name=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${Delete_cell_id_list[${id}]}/CHANNELGROUP-1/${channel}
        END
    END
        ######################add_NRposition_cell/3/4/5/6######################
    FOR    ${item}    IN RANGE    4
        ${NRPOSCELL_id}    Evaluate    ${item} + 1
        ${trp_id}    Evaluate    ${item} + 2
        Log To Console    add NRPOSCELL-${NRPOSCELL_id} mapping with ${NRCELL_id}
        wait until keyword succeeds    3x   1min
        ...    selenium_coam.add_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}   object_class_name=NRPOSCELL
        ...    id_value=${NRPOSCELL_id}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_id}
        ...    filter_param=Local cell resource identifier of positioning New Radio cell
        ...    new_value=${Delete_cell_id_list[${NRPOSCELL_id}]}   abbr=lcrId
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_id}
        ...    filter_param=NR cell configuration identifier
        ...    new_value=${NRCELL_id}   abbr=nrCellId
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_id}
        ...    filter_param=NR Position Cell Type
        ...    new_value=0DL4UL   abbr=nrPosCellType
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_id}
        ...    filter_param=Antenna mode of NR Position Cell
        ...    new_value=4RX   abbr=antennaMode

        selenium_coam.add_element    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_id}/NRTRPINFO-1
        ...    filter_param=NG RAN access point position    abbr=nGRanAccessPointPosition
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_id}/NRTRPINFO-1
        ...    filter_param=Altitude    new_value=${141}    abbr=altitude
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_id}/NRTRPINFO-1
        ...    filter_param=Degrees of latitude
        ...    new_value=${degreesOfLatitude_lst[${trp_id}]}    abbr=degreesOfLatitude
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_id}/NRTRPINFO-1
        ...    filter_param=Degrees of longitude
        ...    new_value=${degreesOfLongitude_lst[${trp_id}]}   abbr=degreesOfLongitude
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_id}/NRTRPINFO-1
        ...    filter_param=Direction of altitude
        ...    new_value=Height    abbr=directionOfAltitude
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_id}/NRTRPINFO-1
        ...    filter_param=Latitude sign
        ...    new_value=North   abbr=latitudeSign
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_id}/NRTRPINFO-1
        ...    filter_param=Orientation of major axis    new_value=${13}    abbr=orientationOfMajorAxis
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_id}/NRTRPINFO-1
        ...    filter_param=Uncertainty altitude    new_value=${10}    abbr=uncertaintyAltitude
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_id}/NRTRPINFO-1
        ...    filter_param=Uncertainty semi-major   new_value=${98}    abbr=uncertaintySemiMajor
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-${NRPOSCELL_id}/NRTRPINFO-1
        ...    filter_param=Uncertainty semi-minor    new_value=${68}    abbr=uncertaintySemiMinor
    END
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}
    ...    filter_param=Activate NR RTWP measurement    new_value=false   abbr=actRtwpMeasurement
    Specfic Paramter Setting For TMO IWK From Normal To SupperCell
    Log To Console    save current bts configuration
    selenium_coam.save_bts_configuration    save_configuration_type=${0}
    ${error}    selenium_coam.validate_plan
    Log To Console    pdl validation results: ${error}
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    [Teardown]    WEBUI Logout


UE Attach start traffic and check log CB10680
    [Arguments]    ${ue_inex}=0    ${nrcellId_list}=${nrcellId_list}
    ${ue_index_list}    Create List    ${ue_inex}
    CB010680_BIP.Start Catch TCPDUMP SCTP Log    filename=ngc.pcap
    CB010680_UE.UE Attach    gnb_index=${0}    ue_index=${ue_inex}
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
    CB010680_UE.UE Start Traffic    ue_index=${ue_inex}    duration=600    dl_tput_sent=1500    ul_tput_sent=200
    ...    if_dl=${True}    if_ul=${True}
    CB010680_UE.UE Check Tput    gnb_index=${0}    log_time=30s    dl_tput_expected=600    ul_tput_expected=100
    ...    if_dl=${True}    if_ul=${True}    dl_cells_list=${nrcellId_list}    ul_cells_list=${nrcellId_list}    ignore_time=15s
    ...    min_percent=0.5    target_avg_percent=0.6
    [Teardown]    UE stop traffic and detach    ue_index_list=${ue_index_list}