*** Settings ***
Documentation
...   author:  Marcin Bednarski
...   contact: marcin.bednarski@nokia.com

Library         taf.ue
Library         taf.sw.reporting_portal
Library         test_specific_keywords.py
Resource        taf/rfrl/bts/robot/gnb.robot

*** Variables ***
${ABSTRACT_LIB_CONFIG}                  /home/ute/testline_configuration/7_16_UTE5GCLOUDT192/ue_config.yaml
${CELL_1_AHFIG}                         GNB_1_CELL_193
${CELL_2_AHFIG}                         GNB_1_CELL_195
${CELL_3_AHFIG}                         GNB_1_CELL_197


*** Keywords ***
Suite Setup
    @{allowed_alarms}  Create List   SSH enabled   User Account has Default Password   LMP access via port 443
    ...   Service account root access is enabled   Ethernet port security is disabled  R&D Service Port enabled
    ...   Sanity Check Error  NRRELNotConfiguredA3A5
    Verify GNB Is OnAir
    Verify Allowed Alarms On GNB  allowed_alarms=@{allowed_alarms}

Test Setup
    Test Setup PY

Test Teardown
    Test Teardown PY

[1]Bi-Directional_Throughput_noDss_NsaSa_TputNsaSplitUDP_AhficS3_DL4x4CL_UL4x4CL_Bw10MhzAr430000
    Perform And Verify Max Tput   ${CELL_3_AHFIG}   udp

[1]Bi-Directional_Throughput_noDss_NsaSa_TputNsaSplitTCP_AhficS1_DL4x4CL_UL4x4CL_Bw10MhzAr430000
    Perform And Verify Max Tput   ${CELL_1_AHFIG}   tcp

[1]Bi-Directional_Throughput_noDss_NsaSa_TputNsaSplitTCP_AhficS2_DL4x4CL_UL4x4CL_Bw10MhzAr430000
    Perform And Verify Max Tput   ${CELL_2_AHFIG}   tcp

[1]Bi-Directional_Throughput_noDss_NsaSa_TputNsaSplitTCP_AhficS3_DL4x4CL_UL4x4CL_Bw10MhzAr430000
    Perform And Verify Max Tput   ${CELL_3_AHFIG}   tcp

Perform And Verify Max Tput
    [Arguments]  ${cell_alias}  ${protocol}
    Force Good Radio Condition On Cell    ${cell_alias}
    ${logs}=   Perform Max Tput   protocol=${protocol}  test_dir=${OUTPUT_DIR}
    ${tput_dl}=   Verify Max Tput   DL   260Mbits/sec
    ${tput_ul}=   Verify Max Tput   UL   80Mbits/sec
    Report Tput KPIs   ${logs}   ${tput_dl}   ${tput_ul}   ${protocol}
    Verify Max Tput Counters
