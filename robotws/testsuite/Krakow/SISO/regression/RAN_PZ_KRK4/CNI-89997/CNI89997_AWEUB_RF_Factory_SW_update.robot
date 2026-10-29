*** Settings ***
Documentation
...    author: Rafal Kawa
...    contact: rafal.kawa@nokia.com
...    description: CNI-89997 AWEUB RF Factory SW update

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
&{AWEUB_FACTORY_RFSW_CREDENTIALS}=  username=root
...                                 password=asmr
&{SWMAN_CMD_PARAMS}=                build_name=5GW50.10.R16
...                                 build_version=5GW50.10.R16
...                                 file_name=rfsw-package-5g-jabco-w5-x21_0x21FF1A84.tar
...                                 file_version=0x21FF1A84
...                                 checksum=0x21FF1A84
${RFSW}=  BTS_D_RF/5GW5/tags/5GW50.10.R16/C_Element/SE_RFM/SS_5GW5/Target/rfsw-package-5g-jabco-w5-x21_0x21FF1A84.tar

*** Test Cases ***
Automated__SiSo__FV_Testing_RF_Factory_SW_update
    Load Factory RFSW on RU  factory_rfsw_credentials=${AWEUB_FACTORY_RFSW_CREDENTIALS}  svne1_path_rfsw=${RFSW}
    ...  swman_cmd_params=${SWMAN_CMD_PARAMS}  gnb_id=${0}  du_id=${0}  ru_id=${0}  cu_id=${0}  common_unit_id=${0}
    ...  capacity_unit_id=${0}
