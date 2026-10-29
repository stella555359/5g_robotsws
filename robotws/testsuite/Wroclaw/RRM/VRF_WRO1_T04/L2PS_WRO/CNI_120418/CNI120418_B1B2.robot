*** Settings ***
Documentation
...    copyright: Nokia

Force Tags    CLOUD_5G_I_LO_AP_LO    CRT    SBTS00    RAN_5G    RAN_5G_FDD

Resource    ../resources/5G_SW_WRO_Keywords.robot
Resource    ./resources/CNI120418_keywords.robot
Resource    ../resources/configuration_id.robot
Library     ../resources/Python/webem_alarms.py

Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
...                            iphy_xml_filepath=${CURDIR}/config/iphy_3x20_LO_AP_LO.xml
...                            swconfig_flags_list=@{SWCONFIG_FLAGS}
...            AND             CNI120418 Setup
...            AND             Update SCF And Perform Commissioning    scf_file_name=scf_LO_AP_LO_B1B2.xml
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/setup_180UEs.lua

Suite Teardown    Run Keywords    Print Active Alarms
...               AND             admin.Teardown All Aliases For Admin
...               AND             Stop Default Processes And Gather Logs

*** Variables ***
@{SWCONFIG_FLAGS}    0x580934=1    #rdNbProcedureContextsHigh
...                  0x580933=1    #rdNbProcedureContextsLow

*** Test Cases ***
CNI_120418_B1_B2_CPRT_event_throttling_due_to_signaling_overload_in_L2PS_start_stop
    Wait For Next Full Pm Interval
    ${subpool_dict}    Check L2 Pool Assignment    cells_amount=3
    Start Dcap And Syslog Collection
    Setup UEs
    Start Traffic For Multiple UEs    first_UE=103    last_ue=270    dir=dl    mbps=2
    Run Keyword And Ignore Error    Verify Avg Tput For Multiple UEs    last_ue=270    dir=dl    expected_tput=1    first_ue=103
    ${syslog_last_ovl_state_1}    Check If l2RTPool has recovered from overload state
    Attach Multiple UEs And Start Traffic    first_ue=271    last_ue=273    dir=dl    mbps=2
    Verify Avg Tput For Multiple UEs    last_ue=272    dir=dl    expected_tput=1   first_ue=270
    Move UEs to RRC CONNECTED State Using RRCResumeRequest1
    Run Keyword And Continue On Failure
    ...    Check There Were No More Overload State Triggered    ovl_state_timestamp=${syslog_last_ovl_state_1}
    Check PM And RD Counters For CNI120418 B2 Scenario
    [Teardown]    Run Keywords    Stop Syslog    alias=mandatory_log
    ...           AND             Stop Dcap Logs Collection
    ...           AND             Send Configuration ID To Scout
