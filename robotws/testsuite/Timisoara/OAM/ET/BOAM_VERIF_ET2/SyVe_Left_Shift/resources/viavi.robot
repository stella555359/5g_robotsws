*** Settings ***
Documentation
...              Author: krzysztof.gryga@nokia.com, rafal.janik@nokia.com, adam.masztalerz@nokia.com, piotr.pinderak@nokia.com
...              Maintainer: rafal.janik@nokia.com, krzysztof.gryga@nokia.com, adam.masztalerz@nokia.com, piotr.pinderak@nokia.com

Library  taf.ue.tm500.rci
Library  taf.transport.ssh
Library  ./configuration/freq.py

*** Variables ***
${LOCAL_SWCONFIG_PATH}   ${CURDIR}/../bb2_files/swconfig.txt
${TM500_IP}          ${tl.ues[0].tma_host.addr}
${TM500_PORT}        ${tl.ues[0].tma_command_port}
${TM500_USER}        ${tl.ues[0].tma_host.username}
${TM500_PW}          ${tl.ues[0].tma_host.password}
${tm500_alias}=      tm500

${CELL_SEARCH_4G}      FORW 0x00 Ok MTE SETMUERADIOCONTEXTCELL: RETURN CODE:0 SUCCEEDED
${CELL_SEARCH_5G}      FORW 0x00 Ok MTE NRSETMUERADIOCONTEXTCELL: RETURN CODE:0 SUCCEEDED
${ATTACH_4G_5G}        CMPI L2 Random Access Complete

*** Keywords ***
VIAVI Attach
    ${attach_result}=        taf.ue.tm500.rci.Send Script
    ...  filename=testsuite/OAM/Wroclaw/cOAM/resources/configuration/attach.txt
    ...  alias=${tm500_alias}
    log to console  ${attach_result}
    Should contain x times   ${attach_result}   ${ATTACH_4G_5G}   count=2
    sleep    10

VIAVI Calculate Intermediate Frequencies
    ${ul_carrier_freq}    ${dl_carrier_freq}    ${absolute_freq_a}    ${absolute_freq_ssb}    ${gnb_dl_carrier_freq}    calculate_frequencies
    ...    low_carrier_freq=${UL_FREF_MSG_MIN}
    ...    ssref=${SS_REF}
    ...    lowest_carrier_bw=${CH_BW}
    ...    highest_carrier_bw=${CH_BW}
    ...    cell_amount=${OUT_ADMIN_LNCELS_AMOUNT}

    Set Test Variable    ${UL_CARRIER_FREQ}    ${ul_carrier_freq}
    Set Test Variable    ${DL_CARRIER_FREQ}    ${dl_carrier_freq}
    Set Test Variable    ${ABSOLUTE_FREQ_A}    ${absolute_freq_a}
    Set Test Variable    ${ABSOLUTE_FREQ_SSB}    ${absolute_freq_ssb}
    Set Test Variable    ${GNB_DL_CARRIER_FREQ}    ${gnb_dl_carrier_freq}

VIAVI Calculate Required Parameters
    [Documentation]    Taf is going to write KWs which calculate those data
    Open Browser
    ...    url=http://5gtables.eecloud.dynamic.nsn-net.net/NRFreq.php
    ...    browser=chrome
    ...    alias=browser2
    SELENIUM Click Visible Element
    ...    locator=//select[@id="options-band"]
    SELENIUM Click Visible Element
    ...    locator=//select[@id="options-band"]/option[text()="n${FREQ_BAND_INDICATOR_NR}"]
    SELENIUM Click Visible Element
    ...    locator=//select[@id="options-bandwidth"]
    SELENIUM Click Visible Element
    ...    locator=//select[@id="options-bandwidth"]/option[text()="${CH_BW} MHz"]
    SELENIUM Click Visible Element
    ...    locator=//select[@id="options-SCS"]
    SELENIUM Click Visible Element
    ...    locator=//select[@id="options-SCS"]/option[text()="${SCS}kHz"]
    SELENIUM Click Visible Element
    ...    locator=//select[@id="options-SCSSSB"]
    SELENIUM Click Visible Element
    ...    locator=//select[@id="options-SCSSSB"]/option[text()="${SSB_SCS}kHz"]
    SELENIUM Input Text in Visible Element
    ...    text=${NR_ARFCN}
    ...    locator=//input[@id="ULNRef"]
    SELENIUM Input Text in Visible Element
    ...    text=${NR_ARFCN}
    ...    locator=//input[@id="DLNRef"]
    SELENIUM Input Text in Visible Element
    ...    text=${GSCN}
    ...    locator=//input[@id="GSCN"]
    SELENIUM Click Visible Element
    ...    locator=//select[@id="options-gscnAuto"]
    SELENIUM Click Visible Element
    ...    locator=//select[@id="options-gscnAuto"]/option[text()="Manual"]
    SELENIUM Input Text in Visible Element
    ...    text=${5}
    ...    locator=//input[@id="coresetIndex"]
    ${ul_fref_msg_min}    Selenium2Library.Get Element Attribute
    ...    locator=ULFRefMsgMin
    ...    attribute=value
    ${ul_fref_msg_min}    Fetch From Left
    ...    string=${ul_fref_msg_min}
    ...    marker= MHz
    Should Not Be Empty    ${ul_fref_msg_min}
    Set Test Variable    ${UL_FREF_MSG_MIN}    ${ul_fref_msg_min}
    ${ssref}    Selenium2Library.Get Element Attribute
    ...    locator=SSRef
    ...    attribute=value
    ${ssref}    Fetch From Left
    ...    string=${ssref}
    ...    marker= MHz
    Should Not Be Empty    ${ssref}
    Set Test Variable    ${SS_REF}    ${ssref}
    Switch Browser    browser

VIAVI Cell Search
    ${cell_search_result}=   taf.ue.tm500.rci.Send Script
    ...  filename=testsuite/OAM/Wroclaw/cOAM/resources/configuration/cell_search.txt
    ...  alias=${tm500_alias}
    Should contain     ${cell_search_result}    ${CELL_SEARCH_4G}
    Should contain     ${cell_search_result}    ${CELL_SEARCH_5G}
    sleep              10

VIAVI Collect Required Data
    [Arguments]    ${cell_id}
    ${out_scf_filename_pretest}=    PREPOST Collect Scf File
    ...    file_name=SCF_MRBTS-${OUT_MRBTS_ID}.xml
    ...    alias=${ADMIN_ALIAS}
    ${freqBandIndicatorNR}    SCF Get Parameter Value From SCF File
    ...    scf_file_path=${out_scf_filename_pretest}
    ...    path=.//managedObject[@distName="MRBTS-${OUT_MRBTS_ID}/NRBTS-${OUT_MRBTS_ID}/NRCELL-${cell_id+1}"]/p[@name="freqBandIndicatorNR"]/text()
    Should Not Be Empty    ${freqBandIndicatorNR}
    Set Test Variable    ${FREQ_BAND_INDICATOR_NR}    ${freqBandIndicatorNR}
    ${chBw}    SCF Get Parameter Value From SCF File
    ...    scf_file_path=${out_scf_filename_pretest}
    ...    path=.//managedObject[@distName="MRBTS-${OUT_MRBTS_ID}/NRBTS-${OUT_MRBTS_ID}/NRCELL-${cell_id+1}"]/p[@name="chBw"]/text()
    Should Not Be Empty    ${chBw}
    ${chBw}    Fetch From Left
    ...    string=${chBw}
    ...    marker=MHz
    Set Test Variable    ${CH_BW}    ${chBw}
    ${scs}    SCF Get Parameter Value From SCF File
    ...    scf_file_path=${out_scf_filename_pretest}
    ...    path=.//managedObject[@class="com.nokia.srbts.nrbts:NRCELLGRP"]/p[@name="scs"]/text()
    Should Not Be Empty    ${scs}
    ${scs}    Fetch From Left
    ...    string=${scs}
    ...    marker=KHz
    Set Test Variable    ${SCS}    ${scs}
    ${ssbScs}    SCF Get Parameter Value From SCF File
    ...    scf_file_path=${out_scf_filename_pretest}
    ...    path=.//managedObject[@distName="MRBTS-${OUT_MRBTS_ID}/NRBTS-${OUT_MRBTS_ID}/NRCELL-${cell_id+1}"]/p[@name="ssbScs"]/text()
    Should Not Be Empty    ${ssbScs}
    ${ssbScs}    Fetch From Left
    ...    string=${ssbScs}
    ...    marker=KHz
    Set Test Variable    ${SSB_SCS}    ${ssbScs}
    ${nrarfcn}    SCF Get Parameter Value From SCF File
    ...    scf_file_path=${out_scf_filename_pretest}
    ...    path=.//managedObject[@distName="MRBTS-${OUT_MRBTS_ID}/NRBTS-${OUT_MRBTS_ID}/NRCELL-${cell_id+1}"]/p[@name="nrarfcn"]/text()
    Should Not Be Empty    ${nrarfcn}
    Set Test Variable    ${NR_ARFCN}    ${nrarfcn}
    ${gscn}    SCF Get Parameter Value From SCF File
    ...    scf_file_path=${out_scf_filename_pretest}
    ...    path=.//managedObject[@distName="MRBTS-${OUT_MRBTS_ID}/NRBTS-${OUT_MRBTS_ID}/NRCELL-${cell_id+1}"]/p[@name="gscn"]/text()
    Should Not Be Empty    ${gscn}
    Set Test Variable    ${GSCN}    ${gscn}
    ${phys_cell_id}    SCF Get Parameter Value From SCF File
    ...    scf_file_path=${out_scf_filename_pretest}
    ...    path=.//managedObject[@distName="MRBTS-${OUT_MRBTS_ID}/NRBTS-${OUT_MRBTS_ID}/NRCELL-${cell_id+1}"]/p[@name="physCellId"]/text()
    Should Not Be Empty    ${phys_cell_id}
    Set Test Variable    ${PHYS_CELL_ID}    ${phys_cell_id}

VIAVI Connect To Viavi
    taf.ue.tm500.rci.connect to
    ...  ip=${TM500_IP}
    ...  command_port=${TM500_PORT}
    ...  alias=${tm500_alias}

VIAVI Detach
    ${detach}=   taf.ue.tm500.rci.Send Script
    ...  filename=testsuite/OAM/Wroclaw/cOAM/resources/configuration/detach.txt
    ...  alias=${tm500_alias}
    sleep  7

VIAVI Disconnect Viavi
    taf.ue.tm500.rci.disconnect  alias=${tm500_alias}

VIAVI L3 Call
    Viavi Connect To Viavi
    Viavi Cell Search
    Viavi Attach
    Viavi Detach
    Viavi Disconnect Viavi

VIAVI Prepare Cell To Viavi L3 Call
    [Arguments]    ${cell_id}
    SELENIUM Go To Detailed Site View
    SELENIUM Click Visible Element
    ...    locator=${DETAILED_VIEW_CELL_OBJECT[${cell_id}]}
    VIAVI Collect Required Data
    ...    cell_id=${cell_id}
    VIAVI Calculate Required Parameters
    VIAVI Calculate Intermediate Frequencies
    Run  sed -i '115d' testsuite/OAM/Wroclaw/cOAM/resources/configuration/cell_search.txt
    ${comm_part1}  Set Variable  forw mte NrSetMueRadioContextCell ${cell_id+1} ${PHYS_CELL_ID} ${DL_CARRIER_FREQ} ${CH_BW} [${UL_CARRIER_FREQ}] []
    ${comm_part2}  Set Variable  [2] [${ABSOLUTE_FREQ_A} ${ABSOLUTE_FREQ_SSB}] [${GNB_DL_CARRIER_FREQ}] [4]
    Run  sed -i '115i${comm_part1} ${comm_part2}' testsuite/OAM/Wroclaw/cOAM/resources/configuration/cell_search.txt
