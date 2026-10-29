*** Settings ***

Documentation    Script for CB015683_Airphone_NR TDD
...   author: Naresh.S@nokia.com
...   Description: CB015683 Counting of H-ARQ ACK of Downgraded MCS Grants in DL Link Adaptation.
...   Exe cmd:robot  --outputdir /home/ute/logs -L TRACE -b debug.log -d ~/logs/CB015683_$(date +%y%m%d) CB015683.robot


Resource          CB015683_resource.robot

Suite setup        Suite Setup
Suite Teardown     Suite Teardown

*** Variables ***
${CSV_PATH}=      ${dlAndUl}/tcpdump_ttitrace.dlAndUl.csv
${dlAndUl}=      ${OUTPUT_DIR}/CB015683/Counting_of_H_ARQ_ACK_of_Downgraded_MCS_Grants_in_DL_Link_Adaptation/l2stream3_ttitrace

*** Test Cases ***

Counting_of_H_ARQ_ACK_of_Downgraded_MCS_Grants_in_DL_Link_Adaptation

    [Tags]    VRF_BLR1    VRF_RRM     CRT
    [Documentation]
    ...    lcrId/cellTechnology/Band/physCellId/NR cell ID/chBw
    ...    cell1    TDD    n78    100MHz
    ${out}    set variable
    ...    ${SUITE_PATH}CB015683/Counting_of_H_ARQ_ACK_of_Downgraded_MCS_Grants_in_DL_Link_Adaptation/l2stream3_ttitrace/tcpdump_ttitrace
    set test variable    ${out}
    create directory     ${out}
    Log to console    \n--BTS Onair--\n
	Check Cells are ON-Air
    Log to console    \n--Started delta Commission--\n
	Feature_Enable_Disable                      ${distname1}    ${parameter1}    ${epevalue1}
    Feature_Enable_Disable1          ${distname1}    ${parameter2}    ${epevalue2}
    Feature_Enable_Disable1                      ${distname1}    ${parameter3}    ${epevalue3}
    Feature_Enable_Disable                      ${distname1}    ${parameter4}    ${epevalue4}
	Feature_Enable_Disable                      ${distname1}    ${parameter5}    ${epevalue5}
    Feature_Enable_Disable                      ${distname1}    ${parameter7}    ${epevalue7}
    Log to console    \n--Completed delta commissioin--\n
    Start the TTI traces      ${pysical_cell_ids}        ${duration}
    Log to console    \n--Started TTI trace 2min--\n
	L3 Call
    Log to console    \n--Started L3 call--\n
    Intiate Bler for Ues and activate with pktloss
    Log to console    \n--Started Pktloss--\n
    SA 5G Detach
    Log to console    \n--Detach the UE--\n
    Stop the TTI traces
    Log to console    \n--Stopped TTI trace--\n
	Eventdecoder To Convert Pcap To Eventcsv
    Log to console    \n--Converting TTI trace to dlul.csv--\n
    ${Event_CSV}     to_event_csv     ${CSV_PATH}
    Log to console    \n--Converted TTI trace to event.csv--\n
    ${result}=    Link Adaption     ${dlAndUl}/dlLaDeltaCqiArray.csv
    Log to console    \n--CB015683 validation completed--\n
    BuiltIn.Log    ${result}



***Keywords***
Check Cells are ON-Air
    ADMIN Assert All NRCells Are In Enabled State    timeout=900
    ADMIN Assert BTS is onAir    timeout=900
    Log to console    \n--Test Completed--\n
