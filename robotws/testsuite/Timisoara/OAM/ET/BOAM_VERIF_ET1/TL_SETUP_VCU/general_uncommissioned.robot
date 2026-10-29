*** Settings ***
Documentation
...    Author: Alexandru Tancau (alexandru.tancau@nokia.com)
...    Maintainer: Alexandru Tancau (alexandru.tancau@nokia.com)
...    Group in charge: BOAM_VERIF_ET4
...    References: doors
...    Feature Description: TL_SETUP for VCU
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log -d
...    results/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/TL_SETUP_vCU/general.robot

Resource    ./resources/TL_SETUP_vCU.robot
Resource    ./resources/keyword.robot


Suite Setup       Run Keywords  Branch or Trunk Jenkins
...               AND           Get last vCU build from Jenkins
...               AND           Get Deployment Type for vCU from Jenkins
Suite Teardown   Delete KUAFU

Test Timeout      90 minutes
*** Variables ***

*** Test Cases ***

TL_SETUP_Deployment_vCU
    [Documentation]
    ...     SWR and check deploy is successfull
    TL_SETUP_Deployment_VCU_Uncommissioned
