*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...      - Dawid Krawczuk <dawid.krawczuk@nokia.com>
...      - Michal Szymakowski <michal.szymakowski@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Resource    CB008083_common_keywords.robot
Resource    ta_messaging/single_message_observer.robot

*** Variables ***
${lua_cfg_file_TC1}=   ${CURDIR}/../config/SA_TDD_2c_1gNBSim_guamiType_mapped.lua
${lua_cfg_file_TC2}=   ${CURDIR}/../config/SA_TDD_2c_1gNBSim_guamiType_native.lua
${lua_cfg_file_TC3}=   ${CURDIR}/../config/SA_TDD_2c_1gNBSim_guamiType_other.lua
${yaml_enable_1AMF}=   ${CURDIR}/../config/yaml_config/setup_1AMF.yaml

*** Keywords ***
Prepare test environment A-B1-4
    Configure actEnhancedNgRanSupport flag to true value
    start_collecting_syslog     prefix=A-B1-4 TC
    Observe NG-C link messages and update database

Prepare test environment A-B1-5
    Configure actEnhancedNgRanSupport flag to true value
    start_collecting_syslog     prefix=A-B1-5 TC
    Observe NG-C link messages and update database

Prepare test environment A-B1-6
    Configure actEnhancedNgRanSupport flag to true value
    start_collecting_syslog     prefix=A-B1-6 TC

    Observe NG-C link messages and update database

Prepare test environment A-B2-7
        Configure   ${yaml_enable_1AMF}
    Observe NG-C link messages and update database
    Configure actEnhancedNgRanSupport flag to true value
    start_collecting_syslog     prefix=A-B2-7 TC
    Omit when SKIP_COUNTERS present
    ...         start collecting counters

Prepare test environment A-B2-8
    Configure actEnhancedNgRanSupport flag to true value
    start_collecting_syslog     prefix=A-B2-8 TC
    Observe NG-C link messages and update database
    Omit when SKIP_COUNTERS present
    ...  start collecting counters

Prepare test environment A-B2-9
    Configure actEnhancedNgRanSupport flag to true value
    start_collecting_syslog     prefix=A-B2-8 TC
    Observe NG-C link messages and update database
    Omit when SKIP_COUNTERS present
    ...  start collecting counters

Prepare test environment B-TC1
    Configure maxNumOfNgSetupRequestRetries to 110 value
    Configure ngSetupRespTmr to 1 value
    Set AMF1 to force NG setup fail for 110 times
    Set AMF2 to force NG setup fail for 111 times
    Set AMF3 to ignore NGSetupRequest from gNB for 110 times
    Set AMF4 to ignore NGSetupRequest from gNB for 111 times

    Omit when SKIP_COUNTERS present
    ...  start collecting counters

Prepare test environment D-TC1
    Configure actEnhancedNgRanSupport flag to True value
    Configure gNbCuName to gNBCN1
    EXPECT FLOW[timeout=1200]: AMF1 NGAP nGSetup
    EXPECT FLOW[timeout=1200]: AMF2 NGAP nGSetup
    EXPECT FLOW[timeout=1200]: AMF3 NGAP nGSetup
    Run Setup     number_of_amfs=3     gnbcuname='gNBCN2'    setup_aliases=False
    PASS FLOW[timeout=1200]: AMF1 NGAP nGSetup
    PASS FLOW[timeout=1200]: AMF2 NGAP nGSetup
    PASS FLOW[timeout=1200]: AMF3 NGAP nGSetup
    Verify that NG Setup Request to AMF1 contains RANNodeName set to gNBCN2
    Verify that NG Setup Request to AMF2 contains RANNodeName set to gNBCN2
    Verify that NG Setup Request to AMF3 contains RANNodeName set to gNBCN2
#    Setup egate  egate_port=20000  alias=default

    Omit when SKIP_COUNTERS present
    ...  start collecting counters

Prepare test environment C-TC1
    Lock NGAP link to AMF1

Prepare test environment C-TC2
    Execute Egate Command  cmd=enb_x2_link_up enb=1 target=2    pass_regexp=is up

Cleanup after test C-TC1
    Execute egate command  cmd=ue_detach id=16

Cleanup after test C-TC2
    Execute egate command  cmd=ue_detach id=16

Cleanup after test B-TC1
    Set AMF1 to force NG setup fail for 1 time
    Set AMF2 to force NG setup fail for 1 time
    Set AMF3 to ignore NGSetupRequest from gNB for 1 time
    Set AMF4 to ignore NGSetupRequest from gNB for 1 time
    Reset NG link to AMF1
    Reset NG link to AMF2
    Reset NG link to AMF3
    Reset NG link to AMF4

Cleanup after test A-B1
    Configure actEnhancedNgRanSupport flag to True value
    Unlock NGAP links

Cleanup after test A-B2
    Configure actEnhancedNgRanSupport flag to True value
    Unlock NGAP links

Cleanup after test A-B3
    Configure actEnhancedNgRanSupport flag to True value
    Unlock NGAP links

Cleanup after test A-B4
    Configure actEnhancedNgRanSupport flag to True value
    Unlock NGAP links

Cleanup after test A-B5
    Configure actEnhancedNgRanSupport flag to True value
    Unlock NGAP links

Cleanup after test D-TC1
    Configure actEnhancedNgRanSupport flag to True value

Cleanup after test C-B5-B6
    Configure actEnhancedNgRanSupport flag to True value
