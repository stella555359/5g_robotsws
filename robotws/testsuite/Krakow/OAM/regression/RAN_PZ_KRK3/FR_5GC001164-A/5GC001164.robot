*** Settings ***
Documentation
...    Author: Krzysztof Domino
...    Maintainer: Krzysztof Domino
...    Group in charge: 5G_PZ_KRK_SG3
...    References: doors
...    Feature Description:5GC001164
...    Based on testcases located in: testsuite/Wroclaw/OAM/cOAM1/5GC001164/ writen by Mateusz Swieton<mateusz.swieton@nokia.com>
...    Sample execution: robot -V /home/ute/testline_configuration/7_7_UTE5GCLOUDT8SK146 -L TRACE -d results/
...    testsuite/Krakow/OAM/regression/RAN_PZ_KRK3/FR_5GC001164-A/5GC001164.robot

Resource    testsuite/Krakow/OAM/regression/RAN_PZ_KRK3/FR_5GC001164-A/resources/keywords.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

Suite Setup       Run Keywords
...               Download Plugins        AND
...               Common Suite Setup With Onair Test Line Preparation  increase_timeout_for_update_sw=3600   AND
...               admin.connect_to    bts_host=${gNB_IP_MPLANE_LOCAL}     bts_port=${gNB_MPLANE_IF_PORT}

Suite Teardown    Run keywords
...               admin.teardown  AND
...               Common Postconditions

Force Tags    CA_5G_OAM    STATE_SW_UPLOADED    RAN_5G_TDD    RAN_5G
...           PY36
...           RAN_5G_MP    RAN_5G_TDD_MP

*** Variables ***
@{allowed_alarms}    SSH enabled
...                  R&D Service Port enabled
...                  LMP access via port 443
...                  LMP access via port 3600
...                  Diagnostic Files collected
...                  Diagnostic Check Error
...                  Radio Diagnostic Files collected
...                  RF module unauthorized
...                  Sanity Check Error
...                  No X2 link available
...                  No X2 link available for a specific LTEENB
...                  Service account root access is enabled
...                  Ethernet port security is disabled

*** Test Cases ***
[1]5GC001164_A_RFM_Plug-in_upload_via_Element_Manager
    5GC001164_A_RFM_Plug-in_upload_via_Element_Manager
    [Teardown]  Run Keyword If Test Failed    Load Plugin Teardown


[1]5GC001164_A_Download_and_activate_Plug-in_modules_using_BTS_Site_Manager
    5GC001164_A_Download_and_activate_Plug-in_modules_using_BTS_Site_Manager
    [Teardown]  Run Keyword If Test Failed    Load Plugin Teardown

