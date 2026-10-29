*** Settings ***
Documentation    ...
#Resource    ./../CUDU_L2/common_setup_teardown.robot
#Suite Setup    Common Suite Setup 2
#Test Setup    Common Test Setup 2
#Test Teardown    Common Test Teardown 2
#Suite Teardown    Common Suite Teardown 2
#Resource          ./keywords_1070_common_AP.robot
#Force Tags        Classical    FR1    IPV4    5GC001070    Owner_yuema    SBTS00    SBTS23R1    SBTS22R4    RAN_5G
#...               RAN_5G_TDD    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#
#*** Variables ***
#${GNBCUTYPE}    NSA
#${SCF_PATH}    ${CURDIR}/config
#${RESOURCE_PATH}       ${CURDIR}/resources
#@{LOG_NAME_LIST}    btslog
#${SCS_SSB_REG}    <subcarrierSpacingSSB>[0-9]+</subcarrierSpacingSSB>
#${PRACH_FORMAT_REG}     <prachPreambleFormat>[0-9]+</prachPreambleFormat>
#${SSB_PERIOD_REG}    <ssBurstSetPeriod>[0-9]+</ssBurstSetPeriod>
#${NUM_OFTSSB_REG}    <numberOfTransmittedSsBlocks>[0-9]+</numberOfTransmittedSsBlocks>
#${TDD_FSTYPE_REG}    <tddFrameStructureType>[0-9]+</tddFrameStructureType>
#${debug}    none
#${UE_ID}               11
#${PROFILE_ID}          1
#${GNB_ID}              2
#${CELL_ID}             1
#${BEARER_ID}           2
#${JSON_PATH}           ${CURDIR}
#
#*** Test Cases ***
#
#5GC001070-B-4014-Single UE scheduling with DBF in FR1-n78-100MHz with GP2Symbols with B4 prach 157 and 6ssb
#    [Tags]    case2
#    #Add Channels if not exist
#    Delta Commission With SCF File    ${JSON_PATH}/delta_4014.json
#    Reboot TL And Check Configured
#    Start WTS And Check OnAir
#    Attach NSA UE and Get Throughput    UE_ID=101
##    Check Slot Type    4014    @{slottype_list_4014}
#
#5GC001070-B-4018-Single UE scheduling with DBF in FR1-n78-100MHz with GP2Symbols with A2 prach 93 and 4ssb
#    [Tags]    case3
#    #Add Channels if not exist
#    Delta Commission With SCF File    ${JSON_PATH}/delta_4018.json
#    Reboot TL And Check Configured
#    Start WTS And Check OnAir
#    Attach NSA UE and Get Throughput    UE_ID=101
##    Check Slot Type    4018    @{slottype_list_4018}
#
#5GC001070-B-4021-Single UE scheduling with DBF in FR1-n78-100MHz with GP2Symbols with A2 prach 98 and 6ssb
#    [Tags]    case4
#    #Add Channels if not exist
#    Delta Commission With SCF File    ${JSON_PATH}/delta_4021.json
#    Reboot TL And Check Configured
#    Start WTS And Check OnAir
#    Attach NSA UE and Get Throughput    UE_ID=101
##    Check Slot Type    4021    @{slottype_list_4021}
#
#*** Keywords ***
#
#
#Add Channels if not exist
#    Backup Scf    ${OUTPUT_DIR}    check
#    ${channel_check}    ${channel5_value}    run keyword and ignore error    Get Single Value From Scf File    ${OUTPUT_DIR}/SCF_check.xml
#    ...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5    direction
#    run keyword if    '${channel_check}'=='FAIL'    Delta Commission With SCF File    ${JSON_PATH}/delta_add_channel.json
#
#Common Suite Setup 2
#    Suite Setup Update GNB    log=${False}    scf_file=scf_1.xml
#    Suite Setup Copy WTS Config Files From QT
#    Modify UTE SCTP Timeout
#    Modify AP SCTP Timeout
#    Configure UTE ETH3
