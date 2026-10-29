*** Settings ***
Documentation
...    author: Rafal Kawa
...    contact: rafal.kawa@nokia.com
...    description: CNI-89997 AEUB RF Factory SW update

Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    testsuite/Krakow/SISO/regression/RAN_PZ_KRK4/CNI-89997/resources/RuFactoryRfsw.robot
Library     taf.rfrl.bts.commissioning
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Force Tags    STATE_SW_UPLOADED    RAN_5G    RAN_5G_MP    PY36

Suite Setup     Run Keywords
...             gnbbbu.upload_swconfig  sw_config_path=commissionings/Krakow/swconfig/default_swconfig.txt
...             AND    Common Suite Setup With Commissioning
Suite Teardown  Common Suite Teardown
Test Setup      Common Preconditions
Test Teardown   Common Postconditions

*** Variables ***
&{AEUB_FACTORY_RFSW_CREDENTIALS}=  username=root
...                                password=umniedziala
&{SWMAN_CMD_PARAMS}=               build_name=5GH41.01.R07
...                                build_version=5GH41.01.R07
...                                file_name=rfsw-package_0xB5810469.tar
...                                file_version=0xB5810469
...                                checksum=0xB5810469
${RFSW}=  BTS_D_RF_2/5GH4/tags/5GH41.01.R07/C_Element/SE_RFM/SS_5G/Target/rfsw-package_0xB5810469.tar

*** Test Cases ***
Automated__SiSo__FV_Testing_RF_Factory_SW_update
    Load Factory RFSW on RU  factory_rfsw_credentials=${AEUB_FACTORY_RFSW_CREDENTIALS}  svne1_path_rfsw=${RFSW}
    ...  swman_cmd_params=${SWMAN_CMD_PARAMS}  gnb_id=${0}  du_id=${0}  ru_id=${0}  cu_id=${0}  common_unit_id=${0}
    ...  capacity_unit_id=${0}
