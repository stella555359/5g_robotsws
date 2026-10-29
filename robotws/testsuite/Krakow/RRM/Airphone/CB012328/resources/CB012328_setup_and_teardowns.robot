*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...       - Konrad Krzyzak <konrad.krzyzak@nokia.com>
...       - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...       - Michal Szymakowski 	<michal.szymakowski@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Resource    ../../../resources/Robot/common_settings.robot
Resource    CB012328-common_keywords.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

*** Variables ***
${deconfigure}=      ${CURDIR}/../config/yaml/deconfigure.yaml

*** Keywords ***
Basic prepare
    Wait 60s for cells [1] operationalState change to [enabled]
    short_syslog.start collecting syslog

Basic cleanup
    Trigger UEs from 1 to 20 to send deregister request
    short_syslog.stop collecting syslog
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

Prepare test environment CB012328-A
    Basic prepare

CB012328-SR-A cleanup
    Log    Cleanup
#    Configure    ${deconfigure}
    Basic cleanup

CB012328-SR-EA-IWK0103 cleanup
    Log    Cleanup
    Basic cleanup
    Turn off UE capabilities for UE17 in ICS Request
    Turn off UE capabilities for UE18 in ICS Request
    Turn off UE capabilities for UE19 in ICS Request

Prepare test environment CB012328-EA
    Basic prepare
    ${yaml_paths_to_configure}      Create List
    append to list      ${yaml_paths_to_configure}      ${act_chipsetID_list}
    append to list      ${yaml_paths_to_configure}      ${act_RRC_inactive}
    Configure    ${yaml_paths_to_configure}
    Configure ue_history for UE19 to enable handovers from gNB3
    Configure ue_history for UE17 to enable handovers from gNB3



