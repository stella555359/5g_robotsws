*** Settings ***
Documentation
...   This is for resource other

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ST.robot
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Library    ./python/sg7_lib.py

Library      OperatingSystem
Library      Process
Library      Collections
Library      String
Library      BuiltIn
Library      taf.transport.ssh    WITH NAME    csn
#Library      taf.sbts.oam.coam.admin    WITH NAME    coam
Library      taf.selenium.sbts      WITH NAME       selenium_coam
Library      taf.rfrl.common_resources.python.SWConfig    WITH NAME    swconf
Library    taf.sw.scout    WITH NAME    scout


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/check_android_ue_l3_call_process.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot


#Resource     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
#
#Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
#Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
#Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
#Variables    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/made_variable.py
*** Variables ***

*** Keywords ***
