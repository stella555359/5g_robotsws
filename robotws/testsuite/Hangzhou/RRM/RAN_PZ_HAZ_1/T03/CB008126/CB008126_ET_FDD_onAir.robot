*** Settings ***
Documentation
...   author: Dacheng Zhang
...   contact: dacheng.zhang@nokia-sbell.com
...   Description: This script is to switch default UTE ET TDD configuration to FDD configuration.

Resource           ../Resources/common_resource.robot
Resource           ../../Resources/Classical/RRM_MultiBTS_Common_Resource.robot
Resource           ../../Resources/Classical/RRM_Common_Resource.robot
Resource           ../../Resources/Common/Airphone.robot
Suite Setup        Common MultiBTS Suite Setup For RRM
Test Setup         Common MultiBTS Test Setup For RRM
Test Teardown      Common MultiBTS Test Teardown For RRM
Suite Teardown     Common MutliBTS Suite Teardown For RRM
Force Tags         CRT/CIT/CDRT             # Tag Item
# ...              PY27
...                RAN_5G                   # Product [RAN_5G]
# ...              CLOUD_5G_CLASSICAL_2xANDROID_ASIBL_ABIAB1_ASIBR_ABILB1_AEQE_ENB   #TLtype, it is for auto trigger by ute cloud
...                SBTS00                   # it is for auto trigger by ute cloud with the release
# ...              STATE_SKIP_AGENT         # it is for auto trigger by ute cloud with gnb state
...                RAN_PZ_HAZ_1             # Competence Area
...                RAN_PZ_HAZ1_SG07_ST_RRM  # Organization
...                TA_LEVEL_22              # Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout       30 minutes

*** Variables ***
#reduce global paramter as possilbe and automatically got from gNB or __init__

@{Ohter_Allow_Alarms}
# ${DEBUG_MODE}          ${TRUE}
# ${REMOTE_MODE}       ${TRUE}
# ${PATH}              /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_3/5GC001729/config/SBTS24R2
# ${PATH2}               /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T03/CB008126/Airphone

*** Test Cases ***
CB008126 FDD gNB to be onAir
    [Documentation]
    ...    author: Dacheng Zhang
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_FDD_2c_1gNBSim
    ...    base_path=${CURDIR}/Airphone
    ...    call_type=sa
    Delete before PM counter file
