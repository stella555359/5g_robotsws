*** Settings ***
Documentation
...    Author: Alexandru Tancau (alexandru.tancau@nokia.com)
...    Maintainer: Alexandru Tancau (alexandru.tancau@nokia.com)
...    Group in charge: RAN BOAM VERIF
...    References: doors
...    Feature Description: TL_SETUP
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log -d
...    results/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/TL_SETUP_vDU/general.robot

Resource    ./resources/TL_SETUP_vDU.robot
Resource    ./resources/keyword.robot

Suite Setup       Run Keywords  Branch or Trunk Jenkins
...               AND           SCF FILE
...               AND           Get last CIT promotion Build vDU

Suite Teardown  Case Postcondition    #delete KUAFU
*** Variables ***

*** Test Cases ***

TL_SETUP_Deployment_vDU
    [Documentation]
    ...     SWR and check BTS on air
    TL_SETUP_Deployment_vDU
