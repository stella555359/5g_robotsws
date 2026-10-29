*** Settings ***
Documentation    ...
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Suite Setup    Common Suite Setup 2
#Test Setup    Common Test Setup 2
#Test Teardown    Common Test Teardown 2
#Suite Teardown    Common Suite Teardown 2
#Resource          ./keywords_1070_common_AP.robot
#Force Tags        Classical    FR1    IPV4    5GC001070    Owner_yuema    RAN_5G_TDD
#...               CRT    RAN_5G    SBTS00    SBTS23R1    SBTS22R4
#...               CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#...               CLOUD_5G_I_MO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#*** Variables ***
#${GNBCUTYPE}           NSA
#${SCF_PATH}            ${CURDIR}/config
#${RESOURCE_PATH}       ${CURDIR}/resources
#${JSON_PATH}           ${CURDIR}
#@{log_name_list}       btslog
#${SCS_SSB_REG}         <subcarrierSpacingSSB>[0-9]+</subcarrierSpacingSSB>
#${PRACH_FORMAT_REG}    <prachPreambleFormat>[0-9]+</prachPreambleFormat>
#${SSB_PERIOD_REG}      <ssBurstSetPeriod>[0-9]+</ssBurstSetPeriod>
#${NUM_OFTSSB_REG}      <numberOfTransmittedSsBlocks>[0-9]+</numberOfTransmittedSsBlocks>
#${TDD_FSTYPE_REG}      <tddFrameStructureType>[0-9]+</tddFrameStructureType>
#${UE_ID}               11
#${PROFILE_ID}          1
#${GNB_ID}              2
#${CELL_ID}             1
#${BEARER_ID}           2
#*** Test Cases ***
#
#5GC001070-B-4016-Single UE scheduling with DBF in FR1-n78-100MHz with GP2Symbols with B4 prach 161 and 1ssb
#    [Tags]    case1
#    Delta Commission With SCF File    ${JSON_PATH}/delta_4016.json
#    Reboot TL And Check Configured
#    Start WTS And Check OnAir
#    Attach NSA UE and Get Throughput    UE_ID=101
#
#5GC001070-B-4017-Single UE scheduling with DBF in FR1-n78-100MHz with GP2Symbols with B4 prach 162 and 2ssb
#    [Tags]    case2
#    Delta Commission With SCF File    ${JSON_PATH}/delta_4017.json
#    Reboot TL And Check Configured
#    Start WTS And Check OnAir
#    Attach NSA UE and Get Throughput    UE_ID=101
#
#*** Keywords ***
#
#
#
#
