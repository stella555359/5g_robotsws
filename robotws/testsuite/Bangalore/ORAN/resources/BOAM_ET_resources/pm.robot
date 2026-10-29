*** Settings ***
Documentation    Author: mateusz.porzucek@nokia.com; pawel.linek@nokia.com; dorota.szczepanska@nokia.com
...              Maintainer: mateusz.porzucek@nokia.com; pawel.linek@nokia.com; dorota.szczepanska@nokia.com
...              Description: Testing PM measurements reports in different conditions
...              FT in charge: FTTW22: I_MANO_SOAM1_FTTW22_GMS <I_MANO_SOAM1_FTTW22@internal.nsn.com>
...              Confluence link:
...              References: (documentation link(e.g. doors or sphinx))
...              QualityCenter: (test set url to QC)
...              Sample execution:

Library     String
Library     Process
Library     DateTime
Library     BuiltIn
Library     String
Library     Telnet
Library	    Collections
Library		OperatingSystem
Library     XML  lxml=True
Library     Telnet
Library     ute_admin
Library     taf.sbts.oam.coam.admin
Library     ute_reporting_portal
Library		ute_fsmaccess
Library     ute_wtssim
Library     ute_syslog
Library     ute_tshark
Library     ute_pdu
Library     ute_async
Library     ta_kpi_pm_report_analyzer
Library     ta_pm_counters
Library     ta_scfc
Library     ./configurations/keywords_python.py

Resource    ./emssim.robot
*** Variables ***
${PATH_FSM}=        /home/ute/MN/UTE/robotlte/testsuite/WMP/SOAM1/LTE602/${branchVersion}_FSMr3_PM_BL.xml
${PATH_WRSCMI}=     https://wrscmi.inside.nsn.com/isource/svnroot/robotfiles/branches/${branchVersion}/DevWro2/PM/${branchVersion}_FSMr3_PM_BL.xml
${PATH_SVN}=        https://svne1.access.nsn.com/isource/svnroot/robotfiles/branches/${branchVersion}/DevWro2/PM/${branchVersion}_FSMr3_PM_BL.xml

*** Keywords ***
PM Make Two Calls And Check Parameters
    WTSSIM Make Call In Every Cell And Check Parameters
    Sleep    60
    WTSSIM Make Call In Every Cell And Check Parameters

PM Wait Next Hourly Report Is Done
	Log    PM Wait Next Hourly Report Is Done    console=yes
	Wait Until Keyword Succeeds    61 min
	...                            1 min
	...                            Wait to hour change
	Sleep                          60

PM Wait To Nearest Measurement Period
	Log    PM Wait To Nearest Measurement Period    console=yes
	Wait Until Keyword Succeeds                     16 min
	...	                                            1 min
	...                                             Wait For Right Period
	Sleep                                           60

Wait To Hour Change
	${list}=	      Create List         00
	${actualTime}=    Get Current Date    result_format=%M
	...                                   time_zone=UTC
	${actualHour}=    Get Current Date    result_format=%H
	...                                   time_zone=UTC
	List Should Contain Value             ${list}
	...                                   ${actualTime}
	Log                                   ${actualTime}
	Set Global Variable                   ${actualTime}
	Set Global Variable                   ${actualHour}

Wait For Right Period
	${list}=           Create List         00  15  30  45
	${actualTime}=     Get Current Date    result_format=%M
	...                                    time_zone=UTC
	${actualHour}=     Get Current Date    result_format=%H
	...                                    time_zone=UTC
	${date}=  		   Get Current Date    result_format=%Y-%m-%d
	...                                    time_zone=UTC
	${actualEpoch}=    Convert Date	       ${date} ${actualHour}:${actualTime}:00.000	epoch
	List Should Contain Value	           ${list}  ${actualTime}
	Log                                    ${actualTime}
	Set Global Variable                    ${actualTime}
	Set Global Variable                    ${actualHour}
	Set Global Variable                    ${actualEpoch}
	Set Global Variable                    ${date}

PM Retrieve PM File
    [Teardown]  Teardown Enb Fsm Access
    Setup Enb Fsm Access
    Run             rm /tmp/PM/*
    Get Enb File    source=/ram/PM*
    ...             destination=/tmp/PM/
    ${extnsion}=    Run    ls -l /tmp/PM/ | awk '{print $9}'| tail -n 1 | cut -d'.' -f7
    ${unpack}    Set Variable If    "${extnsion}"=="xz"    unxz
    ...                            "${extnsion}"=="gz"    gunzip
    Run    ${unpack} /tmp/PM/PM*

PM Verify PM Counters Reports From BTSSM
    [Arguments]    ${bts_id}=1
	Log    PM Verify PM Counters Reports From BTSSM    console=yes
	${actualYear}=    Get Current Date    result_format=%Y
	...                                   time_zone=UTC
	${actualMonth}=   Get Current Date    result_format=%m
	...                                   time_zone=UTC
	${actualDay}=     Get Current Date    result_format=%d
	...                                   time_zone=UTC
	Set Test Variable                     ${actualYear}
	Set Test Variable                     ${actualMonth}
	Set Test Variable                     ${actualDay}
    Run    /home/ute/test_repository/testsuite/WMP/DevWro2/CRT/xL17SP/PM/Commissioning/raw_to_xml_change.sh
	Run Keyword and Continue on Failure
    ...    OperatingSystem.File Should Exist  /tmp/PM/PM.BTS-${bts_id}.${actualYear}${actualMonth}${actualDay}.${actualHour}${actualTime}00.ANY.xml

PM Create List Of Ignored Measurements For Synch Source
    [Arguments]    ${typeOfSynch}
    @{IGNORED_MEASUREMENTS}=    Run Keyword If    '${typeOfSynch}'=='Default'    Create List    @{IGNORED_MEASUREMENTS_DEFAULT}
    ...                                ELSE IF    '${typeOfSynch}'=='GPS'        Create List    @{IGNORED_MEASUREMENTS_GPS}
    Set Global Variable    @{IGNORED_MEASUREMENTS}

PM Verify If Counter Has Expected Values For All Cells
    [Arguments]    ${counter_id}
    ...            ${value}
    ...            ${number_of_occurence}
    ...            ${path}=PMSetup[@interval="15" or @interval="30" or @interval="60"]/
    ...            ${value_max}=Null
    ...            ${bts_id}=1
    ${xml}=     Parse XML
    ...         source=/tmp/PM/PM.BTS-${bts_id}.${actual_year}${actual_month}${actual_day}.${actual_hour}${actual_time}00.ANY.xml
    ${valuesReport}=    Get Elements Texts
    ...                 source=${xml}
    ...                 xpath=.//${path}PMMOResult/NE-WBTS_1.0/${counter_id}
    ${valuesReportLength}=    Get Length
    ...                       ${valuesReport}
    Run Keyword and Continue On Failure    Should Be True
    ...                                    ${valuesReportLength} == ${number_of_occurence}
    :FOR    ${position}    IN RANGE    0  ${valuesReportLength}
    \       ${valueReport}=    Evaluate    int(${valuesReport}[${position}])
    \       Run Keyword And Continue On Failure
           ...    run keyword if  '${value_max}'!='Null'  Should Be True    ${value} < ${valueReport} < ${value_max}
           ...    ELSE
           ...    Should Be True    ${valueReport} == ${value}

PM Verify Number Of Occurence For Counters
    [Arguments]    ${counter_id}
    ...            ${number_of_occurence}
    ${xml}=    Parse XML
    ...        source=/tmp/PM/PM.BTS-1.${actual_year}${actual_month}${actual_day}.${actual_hour}${actual_time}00.ANY.xml
    ${valuesReport}=    Get Elements Texts
    ...                 source=${xml}
    ...                 xpath=.//PMSetup[@interval="15" or @interval="30" or @interval="60"]/PMMOResult/NE-WBTS_1.0/${counter_id}
    ${valuesReportLength}=    Get Length
    ...                       ${valuesReport}

    Run Keyword And Continue On Failure
    ...    Should Be True
    ...    ${valuesReportLength} == ${number_of_occurence}
    :FOR    ${position}    IN RANGE    0  ${valuesReportLength}
    \    ${valueReport}=    Evaluate    int(${valuesReport}[${position}])


PM Get Counter Value For LocalMoid
    [Arguments]    ${counter}
    ${xml}=   Parse XML
    ...       source=/tmp/PM/PM.BTS-1.${actual_year}${actual_month}${actual_day}.${actual_hour}${actual_time}00.ANY.xml
    ${PM_counter_value}=    Evaluate Xpath  ${xml}
    ...                     sum(.//PMMOResult[MO/localMoid = '${localMoid}']//${counter})
    ${PM_counter_value}=    Convert To Integer  ${PM_counter_value}
    Return From Keyword     ${PM_counter_value}

    Report Pm Counter
    ...    id=${counter}
    ...    value=${PM_counter_value}
    ...    result=Passed

PM Check Intervals Of Measurement Types For ReportingIntervalPm And Synch
    [Arguments]    ${intervalTime}
    ...            ${reportingIntervalPmToCheck}
    ...            ${ntpOrGps}
	Log    Check intervals of measurement types    console=yes
	taf.sbts.oam.coam.admin.Setup Admin
	...    bts_host=192.168.255.1
	...    bts_port=443
	...    use_ssl=True
    Get Current Scf File
    ...    /home/ute/Downloads/
    ...    192.168.255.129_scf.xml
	taf.sbts.oam.coam.admin.Teardown Admin
	PM Validate Intevals Of Measurment In SCFC
	...    intervalTime=${intervalTime}
    ...    reportingIntervalPmToCheck=${reportingIntervalPmToCheck}
    ...    ntpOrGps=${ntpOrGps}
	PM Validate Intevals Of Measurment In TRS
	...    intervalTime=${intervalTime}

PM Validate Intevals Of Measurment In SCFC
    [Arguments]    ${intervalTime}
    ...            ${reportingIntervalPmToCheck}
    ...            ${ntpOrGps}
    ${xml}=   Parse XML
    ...       source=/home/ute/Downloads/192.168.255.129_scf.xml
 	${attribNameList}=            Create List    mtBtsEnergyMonitoring  mtCellAvailability  mtCellLoad  mtCellRes  mtCellThruput  mteNBload
    ...  mtEPSBearer  mtEutraFrequency  mtLTEHo  mtHoRlf  mtInterSysHoEhrpdBc  mtIntereNBHo  mtInterSysHoGsmNb  mtInterSysHoUtranNb  mtInterSysHo
    ...  mtIntraeNBHo   mtM3SctpStatistics  mtMAC  mtMBMS  mtMobilityEvents  mtMroUtranFrequency  mtintraLTEHoNb  mtPowQualDL  mtPowQualUL  mtQoS
    ...  mtRadBearer  mtRRC  mtS1SctpStatistics  mtS1AP  mtSINR  mtTranspLoad  mtUEandServiceDiff  mtUEstate  mtX2SctpStatistics  mtX2AP
    ...  mtVoLTEBLERHist  mtSfp  mtSIMonitoring  mtRanSharing  mtRSRPRSRQHist  mtRLFPMQAPProfile  mtGNSS
	${attribNameListDisabled}=    Create List    mtERABPMQAPProfile  mtProSe  mtDataVolThrPMQAPProfile
	${attribNameListGPS}=         Create List    mtInterHomeeNBHo  mtUEQuantity  mtActUsersLatencyPMQAPProfile
	Validate Intervals Of Measurment In SCF      ${attribNameList}    ${intervalTime}
    ...     .//*[@class='PMRNL'][@distName='MRBTS-1/LNBTS-1/PMRNL-1']/    /home/ute/Downloads/192.168.255.129_scf.xml
	Validate Intervals Of Measurment In SCF      ${attribNameListDisabled}    disabled
    ...    .//*[@class='PMRNL'][@distName='MRBTS-1/LNBTS-1/PMRNL-1']/    /home/ute/Downloads/192.168.255.129_scf.xml
	Run Keyword If    '${ntpOrGps}'=='NTP'       Validate Intervals Of Measurment In SCF    ${attribNameListGPS}    disabled
    ...    .//*[@class='PMRNL'][@distName='MRBTS-1/LNBTS-1/PMRNL-1']/    /home/ute/Downloads/192.168.255.129_scf.xml
	Run Keyword If    '${ntpOrGps}'=='GPS'       Validate Intervals Of Measurment In SCF    ${attribNameListGPS}    ${intervalTime}
    ...    .//*[@class='PMRNL'][@distName='MRBTS-1/LNBTS-1/PMRNL-1']/    /home/ute/Downloads/192.168.255.129_scf.xml
	Validate Intervals Of Measurment In SCF      reportingIntervalPm    ${reportingIntervalPmToCheck}
    ...    .//*[@class='PMCADM'][@distName='MRBTS-1/PMCADM-1']/    /home/ute/Downloads/192.168.255.129_scf.xml

PM Validate Intevals Of Measurment In TRS
    [Arguments]    ${intervalTime}
 	${attribNameList}=          Create List      lte_IP_Stats_Interval  lte_PHB_Stats_Interval  lte_Ethernet_Link_Interval  lte_IPSec_Interval
    ...  lte_IP_Filtering_Interval  lte_VLAN_IP_Stats_Interval  lte_VLAN_PHB_Stats_Interval  lte_VLAN_Stats_Interval  lte_ETHIF_Stats_Interval
    ...  lte_TWAMP_Stats_Interval  lte_TAC_Statistics_Interval  lte_TOP_FreqSync_Stats_Interval  lte_TOP_PhaseSync_Stats_Interval
    ...  lte_VLAN_IPv4_PHB_Stats_Interval  lte_VLAN_IPv4_Stats_Interval  lte_VLAN_IPv6_PHB_Stats_Interval  lte_VLAN_IPv6_Stats_Interval
    ...  lte_IPv6_Stats_Interval  lte_IPv6_PHB_Stats_Interval  lte_IPv4_Stats_Interval  lte_IPv4_PHB_Stats_Interval
	Validate Intervals Of Measurment In SCF      ${attribNameList}    ${intervalTime}
    ...    .//*[@class='PMTNL'][@distName='MRBTS-1/LNBTS-1/FTM-1/PMTNL-1']/    /home/ute/Downloads/192.168.255.129_scf.xml


PM Check The File Extension Of PM Reports On BTS
    Setup Enb Fsm Access
    ${files}=    Execute Command on Enb
    ...          ls -l /ram/ | grep -i 'PM.BTS' | awk '{ print $9 }'
    ${extension}    Set Variable If    "@{release}[0]_@{release}[1]"=="FL19A_FSM4"       .xz     .gz
    Run Keyword And Continue On Failure    Check Files Extension    ${files}    ${extension}
    Teardown Enb Fsm Access

PM Check If PM File Has Been Transferred To OMS
    [Arguments]    ${trueOrFalse}
    ...            ${typeOfTest}
	Log    Check If PM File Has Been Transferred To OMS
    ${getStatus}=    Run Keyword And Return Status    Evaluate    int(${numberOfReportsSent})
    ${previousNumberOfReportsSent}=    Run Keyword If    '${getStatus}'=='False'
    ...     Set Variable     0       ELSE    Evaluate    int(${numberOfReportsSent})
    Run    ls -l /home/flexi1/UPLOADS/KEYSTATS/
    Run    cat /home/flexi1/emssim_log.log | grep -a PM.BTS | grep -v 'http' > /tmp/PM_OMS_test.log
    Run    cat /tmp/PM_OMS_test.log
    ${grepLogFile}=            Grep File   /tmp/PM_OMS_test.log   PM.BTS
    ${numberOfReportsSent}=    Get Count   ${grepLogFile}         PM.BTS
    Set Test Variable     ${numberOfReportsSent}
    ${checkCondition}=    Run Keyword If     '${trueOrFalse}'=='True'
    ...    Evaluate   ${previousNumberOfReportsSent} < ${numberOfReportsSent} < int(${numberOfReportsSent} + 1)    ELSE
    ...    Evaluate   '${previousNumberOfReportsSent}'=='${numberOfReportsSent}'
    ${checkCondition}=    Evaluate           str(${checkCondition})
    Run Keyword And Continue On Failure      Should Be True    '${checkCondition}'=='${trueOrFalse}'
    ${getActualHour}=   Get Current Date     result_format=%H
    ${getActualHourUTC}=   Get Current Date     result_format=%H  time_zone=UTC

    ${getActualHour}=   Convert To Integer   ${getActualHour}
    ${getActualHourUTC}=   Convert To Integer   ${getActualHourUTC}
    ${timeZoneDifference}=  Run Keyword If  ${getActualHour}==0  Convert To Integer  ${24-${getActualHourUTC}}
	...    ELSE  Convert To Integer  ${${getActualHour}-${getActualHourUTC}}
    Set Test Variable    ${getActualHour}
    :FOR                 ${index}       IN RANGE    1    ${${numberOfReportsSent}+1}
    \   ${exitHour}=      Run     sed -n '${index}p' /tmp/PM_OMS_test.log | awk -F':' '{print $1}'
    \   ${exitMinutes}=   Run     sed -n '${index}p' /tmp/PM_OMS_test.log | awk -F':' '{print $2}'
    \   ${exit2Hour}=     Run     sed -n '${index}p' /tmp/PM_OMS_test.log | awk -F'.' '{print $4}' | cut -c 1-2
    \   ${exit2Minutes}=  Run     sed -n '${index}p' /tmp/PM_OMS_test.log | awk -F'.' '{print $4}' | cut -c 3-4
    \   ${exitHour}=      Convert To Integer   ${exitHour}
    \   ${exit2Hour}=     Convert To Integer   ${exit2Hour}
    \   ${exitMinutes}=   Convert To INteger    ${exitMinutes}
    \   ${exit2Minutes}=   Convert To INteger    ${exit2Minutes}
    \   Run Keyword If    '${typeOfTest}'=='Common'    Run Keyword And Continue On Failure    Should Be True    '${exitHour}'=='${exit2Hour}'
    \   Run Keyword If    '${typeOfTest}'=='Common'
		...				  Run Keyword And Continue On Failure
	    ...               Should Be True     ${${exit2Minutes}-5} < ${exitMinutes} < ${${exit2Minutes}+14}
    \   Run Keyword If    '${index}'=='${${numberOfReportsSent}-1}' and '${trueOrFalse}'=='True'
       ...      Run Keyword And Continue On Failure    Should Be True    '${getActualHour}'=='${exitHour}' and '${getActualHour}'=='${exit2Hour}'
    \   Run Keyword If    '${index}'=='${numberOfReportsSent}' and '${trueOrFalse}'=='True'
        ...     Run Keyword And Continue On Failure    Should Be True    '${getActualHour}'=='${exitHour}' and '${getActualHour}'=='${exit2Hour}'
    \   Run Keyword If    '${typeOfTest}'=='Retrieval failure 15min - restored'    Run Keyword And Continue On Failure
        ...    check if PM file has been transferred to OMS - Retrieval failure 15min - restored
    \   ... '${index}' '${exitMinutes}' '${exit2Minutes}' '${exitHour}' '${exit2Hour}'
    \   Run Keyword If    '${typeOfTest}'=='Retrieval failure 15min - after restored'    Run Keyword And Continue On Failure
        ...    check if PM file has been transferred to OMS - Retrieval failure 15min - after restored
        ... '${index}' '${exitMinutes}' '${exit2Minutes}' '${exitHour}' '${exit2Hour}'
    \   Run Keyword If    '${typeOfTest}'=='Retrieval failure 60min - restored'    Run Keyword And Continue On Failure
        ...    check if PM file has been transferred to OMS - Retrieval failure 60min - restored
        ... '${index}' '${exitHour}' '${exit2Hour}' '${exitMinutes}' '${exit2Minutes}'
    \   Run Keyword If    '${typeOfTest}'=='Retrieval failure 60min - after restored'    Run Keyword And Continue On Failure
        ...    check if PM file has been transferred to OMS - Retrieval failure 60min - after restored
        ... '${index}' '${exitHour}' '${exit2Hour}' '${exitMinutes}' '${exit2Minutes}'

PM Load Measurement File From OMS BtsfilesBU Folder And Check It_PM Upload Period Changed
    [Arguments]    ${testType}
    Log    Load measurement file from OMS btsfilesBU folder and check it - PM upload period changed to '${testType}'    console=yes
	PM Verify PM Counters Reports From BTSSM
	PM Check Measurements
	PM Unzip PM Counters From OMS
	PM Verify PM Counters Reports From OMS
	Run Keyword If    '${testType}'=='15min'    Diff PM files - PM Upload Period Changed To 15min
	Run Keyword If    '${testType}'=='60min'    Diff PM files


PM Load Measurement File From OMS BtsfilesBU Folder And Check It_The First Intermediate Period Test Edition
	Log    Load measurement file from OMS btsfilesBU folder and check it - the first intermediate period test edition    console=yes
	PM Unzip PM Counters From BTSSM
	PM Verify PM Counters Reports From BTSSM
	PM Check Measurements - Do Not Check Intervals Test Edition
	PM Check If Proper Time Intervals Are Present In PM Report After BTS Reset
	PM Unzip PM Counters From OMS
	PM Verify PM Counters Reports From OMS
	Diff PM files - PM Upload Period Changed To 15min

PM Check If Proper Time Intervals Are Present In PM Report After BTS Reset
    Check If Proper Time Intervals Are Present In PM Report
    ...    /tmp/PM/PM.BTS-1.${actualYear}${actualMonth}${actualDay}.${actualHour}${actualTime}00.ANY.xml


PM Unzip PM Counters From BTSSM
    Log    unzip PM counters from BTSSM    console=yes
    Run    unzip /tmp/192.168.255.129_PMFiles.zip -d /tmp/PM

PM Check Measurements - Do Not Check Intervals Test Edition
	Log To Console  Checking measurements
	${measurementList} =	Create List
	${missingMeasurementslist} =	Create List
	${resultIntervals} =	Create List
	${cellObjects} =	Create List
	${startTimes} =	Create List
	Set Test Variable   ${measurementList}
	Set Test Variable   ${missingMeasurementslist}
	Set Test Variable   ${resultIntervals}
	Set Test Variable   ${cellObjects}
	Set Test Variable   ${startTimes}
	${actualHourToInt2h}=    Convert To Integer    ${actualHour}
	${actualHour+1h}=    Run Keyword If    ${actualHourToInt2h}==0     Set Variable    23
	...    ELSE    Evaluate    int(${actualHourToInt2h}+2)
	${actualHour+1h}=    Convert To String   ${actualHour+1h}
	${getLengthh+1}=    Get Length    ${actualHour+1h}
	${actualHour+1h}=    Run Keyword If    ${getLengthh+1} == 1    Set Variable    0${actualHour+1h}
	...    ELSE    Set Variable    ${actualHour+1h}
	${actualHour+1h}=   Convert To Integer  ${actualHour+1h}
	Set Test Variable    ${actualHour+1h}
	${ignoredMeas} =	Create List  @{IGNORED_MEASUREMENTS}
	${xml}=             Parse XML       source=${BASELINE_FILE}
	${xml2}=             Parse XML       source=/tmp/PM/PM.BTS-1.${actualYear}${actualMonth}${actualDay}.${actualHour}${actualTime}00.ANY.xml
	${presentReportName}=    Set Variable    PM.BTS-1.${actualYear}${actualMonth}${actualDay}.${actualHour}${actualTime}00.ANY.xml
	Set Test Variable	${presentReportName}
	${presentReportName2}=    Set Variable    PM.BTS-1.${actualYear}${actualMonth}${actualDay}.${actualHour+1h}${actualTime}00.LTE.xml
	Set Test Variable	${presentReportName2}
	@{measurementList}=  Get Elements    source=${xml}      xpath=.//Measurement
	Set Test Variable	@{measurementList}
	@{PMResultList}=  Get Elements    source=${xml2}      xpath=.//PMMOResult
	Set Test Variable   @{PMResultList}
	:FOR   ${measurement}    IN    @{measurementList}
    \       ${measName}=    Get Element text   source=${measurement}      xpath=./Name
    \		Set Test Variable   ${measName}
    \		Set Test Variable   ${measurement}
    \		Append To List  ${measurementList}  ${measName}
    \       ${status}	${value} =	Run Keyword And Ignore Error  List Should Not Contain Value  ${ignoredMeas}  ${measName}
    \	   	Run keyword if    '${status}'=='FAIL'     Continue For Loop
    \       PM Find The Measurement From The Result File Do Not Check Intervals Test
    Run Keyword And Continue On Failure		Should Be Empty  ${missingMeasurementslist}
    Run Keyword And Continue On Failure		Should Be Empty  ${missingCountersList}
    PM Checking extra measurements

Load Measurement File From OMS BtsfilesBU Folder And Check It_Concurrent PM Upload Test
    Log    Load Measurement File From OMS BtsfilesBU Folder And Check It_Concurrent PM Upload Test    console=yes
    PM Verify PM Counters Reports From BTSSM
    PM Check Measurements New
	PM Unzip PM Counters From OMS
	PM Verify PM Counters Reports From OMS
	Diff PM files - PM Upload Period Changed To 15min

PM Check Measurements
	Log    Checking Measurements    console=yes
	${measurementList} =	        Create List
	${missingMeasurementslist} =	Create List
	${resultIntervals} =	        Create List
	${cellObjects} =	            Create List
	${startTimes} =	                Create List
	Set Test Variable    ${measurementList}
	Set Test Variable    ${missingMeasurementslist}
	Set Test Variable    ${resultIntervals}
	Set Test Variable    ${cellObjects}
	Set Test Variable    ${startTimes}
	${ignoredMeas} =	 Create List    @{IGNORED_MEASUREMENTS}
	${xml}=              Parse XML      source=${BASELINE_FILE}
	${xml2}=             Parse XML      source=/tmp/PM/PM.BTS-1.${actualYear}${actualMonth}${actualDay}.${actualHour}${actualTime}00.ANY.xml
	${presentReportName}=    Set Variable    PM.BTS-1.${actualYear}${actualMonth}${actualDay}.${actualHour}${actualTime}00.ANY.xml
	Set Test Variable	     ${presentReportName}
	${presentReportName2}=    Set Variable    PM.BTS-1.${actualYear}${actualMonth}${actualDay}.${actualHour}${actualTime}00.LTE.xml
	Set Test Variable	${presentReportName2}
	@{measurementList}=      Get Elements    source=${xml}    xpath=.//Measurement
	Set Test Variable	     @{measurementList}
	@{PMResultList}=         Get Elements    source=${xml2}    xpath=.//PMMOResult
	Set Test Variable        @{PMResultList}
	:FOR    ${measurement}    IN    @{measurementList}
    \       ${measName}=      Get Element text   source=${measurement}      xpath=./Name
    \		Set Test Variable   ${measName}
    \		Set Test Variable   ${measurement}
    \		Append To List  ${measurementList}  ${measName}
    \       ${status}	${value} =	Run Keyword And Ignore Error  List Should Not Contain Value  ${ignoredMeas}  ${measName}
    \	   	Run keyword if    '${status}'=='FAIL'     Continue For Loop
    \       PM Find The Measurement From The Result File
    ${missingMeasurementslist}=    Evaluate    [i for i in ${missingMeasurementslist} if i not in ${ignoredMeas}]
    Run Keyword And Continue On Failure		   Should Be Empty  ${missingMeasurementslist}
    Run Keyword And Continue On Failure		   Should Be Empty  ${missingCountersList}
    PM Checking Extra Measurements

PM Find The Measurement From The Result File
	${found}=    set variable    ${false}
	${missingCountersList} =	 Create List
	${extraCountersList} =	     Create List
	${duplicateCountersList} =	 Create List
	${ignoredCountersList} =	 Create List
	Set Test Variable   ${found}
	Set Test Variable   ${missingCountersList}
	Set Test Variable   ${extraCountersList}
	Set Test Variable   ${duplicateCountersList}
	Set Test Variable   ${ignoredCountersList}
	:FOR   ${PMResult}    IN    @{PMResultList}
    \			${measurementType}=  Get Element Attribute	source=${PMResult}	 name=measurementType	xpath=.//NE-WBTS_1.0
    \		    Set Test Variable   ${PMResult}
    \			Run Keyword If  '${measurementType}'=='${measName}'   PM Check Measurement Content
	Run keyword if   '${found}'=='${false}'  Append To List    ${missingMeasurementslist}  ${measName}
	Run Keyword And Continue On Failure      Run Keyword If   '${found}'=='${true}'  PM Check Intervals

PM Check Measurement Content
	${found}=    set variable   ${true}
	Set Test Variable   ${found}
	PM Check Counters
	PM Check Cell Objects

PM Check Counters
	${baselineCounterList}=    Create List
	${counterList}=	           Create List
	${duplicateSet}=	       Create List
	@{counters}=               Get Elements   source=${measurement}      xpath=./PI
	:FOR    ${counter}    IN    @{counters}
	\		${status}	${value} =	Run Keyword And Ignore Error  Get Child Elements  source=${measurement}      xpath=./Original_release
    \	   	Run Keyword If    '${status}'=='FAIL'     Continue For Loop
    \		${pt}=  Get Elements Texts		source=${counter}      xpath=.//Product_Type
    \		${status}	${value} =	Run Keyword And Ignore Error	List Should Contain Value  ${pt}	FSM-r3 FDD
    \	   	Run Keyword If    '${status}'=='FAIL'     Continue For Loop
    \ 		${c}=  Get Element text   source=${counter}      xpath=.//PI_ID
    \       ${status}	${value} =	Run Keyword And Ignore Error  List Should Not Contain Value  ${ignoredCounters}  ${c}
    \	   	Run Keyword If    '${status}'=='FAIL'     Continue For Loop
    \		Append To List  ${baselineCounterList}  ${c}
	\		${status}	${value} =	Run Keyword And Ignore Error  Element Should Exist    source=${PMResult}      xpath=.//${c}
    \	   	Run Keyword If    '${status}'=='FAIL'     Append To List  ${missingCountersList}  ${c}
    @{resultCounters}=    Get Child Elements   source=${PMResult}      xpath=.//NE-WBTS_1.0
    :FOR   ${resultCounter}    IN    @{resultCounters}
    \	   ${c}=  Evaluate Xpath   source=${resultCounter}  expression=name(.)
    \	   Append To List  ${counterList}  ${c}
	Sort List    ${baselineCounterList}
	Sort List    ${counterList}
    List Should Not Contain Duplicates    ${counterList}
    Check_If_Piid_From_Report_Are_In_Baseline  ${baselineCounterList}  ${counterList}  ${IGNORED_PIIDS}

PM Check Cell Objects
    Setup Enb Fsm Access    alias=enb1
    ${enb_sw_version}    Get Enb Sw Version    alias=enb1
    Log    \nActive SW: ${enb_sw_version}    console=yes
    @{release}    split_string    ${enb_sw_version}    _
    Set Test Variable  @{release}
    Run Keyword If    "@{release}[0]" == "SBTS22R1"    Add New Project Tags
    Run Keyword If    "@{release}[0]" == "SBTS22R2"    Add New Project Tags
    Run Keyword If    "@{release}[0]" == "SBTS22R3"    Add New Project Tags
    Teardown Enb Fsm Access    alias=enb1
	${pmSetupList}=    Evaluate Xpath	${PMResult}     ..
	${PMSetup}=        Get From List  ${pmSetupList}    0
	${interval}=       Get Element Attribute  	source=${PMSetup}	  name=interval  	xpath=.
	Append To List     ${resultIntervals}  ${interval}
	${startTime}=      Get Element Attribute  	source=${PMSetup}	  name=startTime  	xpath=.
	Append To List     ${startTimes}  ${startTime}
    ${xpath}=          Set Variable If    "@{release}[0]_@{release}[1]"=="FL19A_FSM4"    .//localMoid       .//MO[1]/DN[1]
	${localMoid}=      Get Element Text         source=${PMResult}      xpath=${xpath}
	${cellRegex}=      Set Variable             LNCEL-[0-9]+
    ${eciRegex}=   	   Set Variable 	        LNCEL-[0-9]+/.+/ECI-[0-9]+
    ${tciRegex}=   	   Set Variable	            LNCEL-[0-9]+/.+/TCID-[0-9]+
 	${status}    ${value}=    Run Keyword And Ignore Error      Should Match Regexp	${localMoid}	${eciRegex}
    Run Keyword If    '${status}'=='PASS'     Append To List    ${cellObjects}  ${measName}+${localMoid}+${startTime}
 	${status}	${value} =	Run Keyword And Ignore Error        Should Match Regexp	 ${localMoid}   ${cellRegex}
    Run Keyword If    '${status}'=='PASS'     Append To List    ${cellObjects}  ${measName}+${localMoid}+${startTime}
    ${status}	${value} =	Run Keyword And Ignore Error        Should Match Regexp	${localMoid}	${tciRegex}
    Run Keyword If    '${status}'=='PASS'     Append To List    ${cellObjects}  ${measName}+${localMoid}+${startTime}
    List Should Not Contain Duplicates    ${cellObjects}

PM Check Intervals
	Log                        ${measName}
	Log                        ${startTimes}
	Remove Values From List    ${resultIntervals}    15
	Should Be Empty            ${resultIntervals}

Diff PM files - PM Upload Period Changed To 15min
	${rcFor15min}=    Run And Return Rc     diff --brief /tmp/PM/${presentReportName} /home/flexi1/UPLOADS/KEYSTATS/${presentReportName2}
	Run Keyword And Continue On Failure     Should Be Equal As Integers	  ${rcFor15min}	  0

PM Unzip PM Counters From OMS
    Run    sudo rm /home/flexi1/UPLOADS/KEYSTATS/*.xml
    Run    sudo rm /home/flexi1/UPLOADS/KEYSTATS/*.raw
    ${extnsion}=    Run    ls -l /home/flexi1/UPLOADS/KEYSTATS/ | awk '{print $9}'| tail -n 1 | cut -d'.' -f7
    ${unpack}    Set Variable If    "${extnsion}"=="xz"    unxz
    ...                             "${extnsion}"=="gz"    gunzip
    Run    sudo ${unpack} /home/flexi1/UPLOADS/KEYSTATS/*
    Run    sudo rename 's/\.raw/\.xml/' /home/flexi1/UPLOADS/KEYSTATS/*.raw
    OperatingSystem.List Files In Directory    /home/flexi1/UPLOADS/KEYSTATS/

PM Verify PM Counters Reports From OMS
	${actualYear}=    Get Current Date     result_format=%Y    time_zone=UTC
	${actualMonth}=   Get Current Date     result_format=%m    time_zone=UTC
	${actualDay}=     Get Current Date     result_format=%d    time_zone=UTC
	${actualHourToInt2h}=    Convert To Integer    ${actualHour}
	${actualHour+1h}=    Run Keyword If    ${actualHourToInt2h}==0     Set Variable    23
	...    ELSE    Evaluate    int(${actualHourToInt2h}+2)
	${actualHour+1h}=    Convert To String   ${actualHour+1h}
	${getLengthh+1}=    Get Length    ${actualHour+1h}
	${actualHour+1h}=    Run Keyword If    ${getLengthh+1} == 1    Set Variable    0${actualHour+1h}
	...    ELSE    Set Variable    ${actualHour+1h}
	${actualHour+1h}=   Convert To Integer  ${actualHour+1h}
	Set Test Variable    ${actualHour+1h}
	Run Keyword And Continue On Failure    OperatingSystem.Wait Until Created
	...     path=/home/flexi1/UPLOADS/KEYSTATS/PM.BTS-1.${actualYear}${actualMonth}${actualDay}.${actualHour+1h}${actualTime}00.LTE.xml
    ...     timeout=200
PM Get Baseline From Robotfiles Repositorium For Branch
    [Arguments]    ${branchVersion}
    ${checkIfExists}=    Run Keyword and Return Status    OperatingSystem.File Should Exist  ${PATH_FSM}
    Run Keyword If      '${checkIfExists}'=='True'        Log To Console    the baseline xml file is already on the hd
    Run Keyword If      '${checkIfExists}'=='False'       Run  svn export --username ca_ute_test --password utetest ${PATH_WRSCMI} ${PATH_FSM}
    Run Keyword If      '${checkIfExists}'=='False'       Run  svn export --username ca_ute_test --password utetest ${PATH_SVN} ${PATH_FSM}
    OperatingSystem.Wait Until Created
    ...                 path=${PATH_FSM}
    ...                 timeout=200
    OperatingSystem.File Should Exist    ${PATH_FSM}

PM Pretest Actions For Type Of Synch, Branch Version And Test Line Type
    [Arguments]    ${typeOfSynch}
    ...            ${branchVersion}
    PM Create List Of Ignored Measurements For Type Of Synch Source    typeOfSynch=${typeOfSynch}
    PM Get Baseline From Robotfiles Repositorium                       branchVersion=${branchVersion}

Change Synch Source To GPS
    [Arguments]    ${testLineType}
    Perform Full Commissioning To GPS And Wait For Reset               testLineType=${testLineType}
    ADMIN Assert MRBTS State Is In Configured State                    mrbts_id=${OUT_MRBTS_ID}
    ...                                                                timeout=500

PM Checking Extra Measurements
	Remove Duplicates   ${measurementList}
	:FOR    ${PMResult}    IN    @{PMResultList}
	\		${measurementType}=     Get Element Attribute	source=${PMResult}	 name=measurementType	xpath=.//NE-WBTS_1.0
	\       ${status}	${value} =	Run Keyword And Ignore Error  List Should Not Contain Value  ${ignoredMeas}  ${measurementType}
    \	   	Run Keyword If    '${status}'=='FAIL'     Continue For Loop
    \		Run Keyword And Continue On Failure		  List Should Contain Value  ${measurementList}  ${measurementType}

Perform Full Commissioning To GPS And Wait For Reset
    [Arguments]       ${testLineType}
  #  Run Keyword If    '${testLineType}'=='CLOUD_F'     ADMIN Migrate Scf    ${COMMISSIONING_FILE_CLOUD_F}    ${COMMISSIONING_FILE_CLOUD_F_NEW}
  #  Run Keyword If    '${testLineType}'=='CLOUD_FC'    ADMIN Migrate Scf    ${COMMISSIONING_FILE_CLOUD_FC}   ${COMMISSIONING_FILE_CLOUD_FC_NEW}

    ADMIN INFOMODEL Wait Till CPLANE Will Be Ready To Perfom Commissioning
    Run Keyword If    '${testLineType}'=='CLOUD_F'     Perform Commissioning
    ...    alias=15min
    ...    scf_file=${COMMISSIONING_FILE_CLOUD_F}    bts_id=1   skip_parameter_relation_errors=${True}   timeout=15min
    ...    ELSE IF    '${testLineType}'=='CLOUD_FC'    Perform Commissioning
    ...    alias=GPS    scf_file=${COMMISSIONING_FILE_CLOUD_FC}   bts_id=1   skip_parameter_relation_errors=${True}   timeout=15min

PM Create List Of Ignored Measurements For Type Of Synch Source
    [Arguments]    ${typeOfSynch}
    @{IGNORED_MEASUREMENTS}=    Run Keyword If    '${typeOfSynch}'=='Default'    Create List    @{IGNORED_MEASUREMENTS_DEFAULT}
    ...                         ELSE IF           '${typeOfSynch}'=='GPS'        Create List    @{IGNORED_MEASUREMENTS_GPS}
    Set Global Variable         @{IGNORED_MEASUREMENTS}

PM Get Baseline From Robotfiles Repositorium
    [Arguments]    ${branchVersion}
    ${checkIfExists}=    Run Keyword and Return Status    OperatingSystem.File Should Exist  ${PATH_FSM}
    Run Keyword If    '${checkIfExists}'=='True'          Log    the baseline xml file is already on the hd    console=yes
    Run Keyword If    '${checkIfExists}'=='False'         Run    svn export --username ca_ute_test --password utetest ${PATH_WRSCMI} ${PATH_FSM}
    Run Keyword If    '${checkIfExists}'=='False'         Run    svn export --username ca_ute_test --password utetest ${PATH_SVN} ${PATH_FSM}
    OperatingSystem.Wait Until Created
    ...                 path=${PATH_FSM}
    ...                 timeout=200
    OperatingSystem.File Should Exist    ${PATH_FSM}

PM Verify Value Of Counter For Cell
    [Arguments]    ${cell}
	${counters}=    Run Keyword If    '${cell}'=='1'    Run Keyword    Create Dictionary    M8020C0=1
    ...                                                                                     M8020C1=1
    ...                                                                                     M8020C2=0
    ...                                                                                     M8020C3=${unblocked_unlocked}
    ...                                                                                     M8020C4=${blocked_locked}
    ...                                                                                     M8020C5=0
    ...                                                                                     M8020C6=900
	...    ELSE    Run Keyword    Create Dictionary    M8020C0=0
	...                                                M8020C1=0
	...                                                M8020C2=0
	...                                                M8020C3=900
	...                                                M8020C4=0
	...                                                M8020C5=0
	...                                                M8020C6=900
    :FOR    ${key}    IN    @{counters.keys()}
        \   ${value}=            Get From Dictionary    ${counters}    ${key}
        \   Log    ${key}, ${value}
        \   ${path}=    Set Variable If    "@{release}[0]_@{release}[1]"=="FL19A_FSM4"
            ...    sum(.//PMMOResult[MO/localMoid = 'DN:NE-LNBTS-1/LNCEL-${cell}/MCC-244/MNC-09']//${key})
            ...       sum(.//PMMOResult[MO/DN = 'PLMN-PLMN/MRBTS-1/LNBTS-1/LNCEL-${cell}']//${key})
        \   ${xml}=              Parse XML
            ...                  source=/tmp/PM/PM.BTS-1.${actual_year}${actual_month}${actual_day}.${actual_hour}${actual_time}00.ANY.xml
        \   ${counter_value}=    Evaluate Xpath
            ...                  ${xml}
            ...                  ${path}
        \   ${counter_value}=    Convert to Integer  ${counter_value}
        \   ${value_int}=        Convert to Integer  ${value}
        \   Run Keyword If       '${value}'=='${unblocked_unlocked}' or '${value}'=='${blocked_locked}'
            ...                  Run Keyword And Continue On Failure
            ...                  Should Be True    ${${value_int}-5} < ${counter_value} < ${${value_int}+5}
            ...                  ELSE
            ...                  Run Keyword And Continue On Failure
            ...                  Should Be True    ${counter_value} == ${value_int}

PM Check Intervals Of Measurement Types For ReportingIntervalPm And Synch In Admin
    [Arguments]    ${intervalTime}
	...			   ${reportingIntervalPmToCheck}
    ...            ${ntpOrGps}

	Log To Console    Check Intervals Of Measurement Types In Admin
    taf.sbts.oam.coam.admin.Setup Admin
	...    bts_host=192.168.255.1
	...    bts_port=443
	...    use_ssl=True
    Get Current Scf File
    ...    /home/ute/Downloads/
    ...    192.168.255.129_scf.xml
	taf.sbts.oam.coam.admin.Teardown Admin
	PM Validate Intevals Of Measurment In SCFC In Admin                     intervalTime=${intervalTime}
	...			                                                            reportingIntervalPmToCheck=${reportingIntervalPmToCheck}
    ...                                                                     ntpOrGps=${ntpOrGps}
	PM Validate Intevals Of Measurment In TRS In Admin                      intervalTime=${intervalTime}

PM Validate Intevals Of Measurment In SCFC In Admin
    [Arguments]    ${intervalTime}
	...			   ${reportingIntervalPmToCheck}
    ...            ${ntpOrGps}
    ${xml}=    Parse XML    source=/home/ute/Downloads/192.168.255.129_scf.xml
 	${attribNameList}=            Create List    mtBtsEnergyMonitoring  mtCellAvailability  mtCellLoad  mtCellRes  mtCellThruput  mteNBload
    ...  mtEPSBearer  mtEutraFrequency  mtLTEHo  mtHoRlf  mtInterSysHoEhrpdBc  mtIntereNBHo  mtInterSysHoGsmNb  mtInterSysHoUtranNb  mtInterSysHo
    ...  mtIntraeNBHo   mtM3SctpStatistics  mtMAC  mtMBMS  mtMobilityEvents  mtMroUtranFrequency  mtintraLTEHoNb  mtPowQualDL  mtPowQualUL  mtQoS
    ...  mtRadBearer  mtRRC  mtS1SctpStatistics  mtS1AP  mtSINR  mtTranspLoad  mtUEandServiceDiff  mtUEstate  mtX2SctpStatistics  mtX2AP
    ...  mtVoLTEBLERHist  mtSfp  mtSIMonitoring  mtRanSharing  mtRSRPRSRQHist  mtRLFPMQAPProfile  mtGNSS
	${attribNameListDisabled}=    Create List    mtERABPMQAPProfile  mtProSe  mtDataVolThrPMQAPProfile
	${attribNameListGPS}=         Create List    mtInterHomeeNBHo  mtUEQuantity  mtActUsersLatencyPMQAPProfile
	Validate Intervals Of Measurment In SCF      ${attribNameList}    ${intervalTime}
    ...    .//*[@class='PMRNL'][@distName='MRBTS-1/LNBTS-1/PMRNL-1']/    /home/ute/Downloads/192.168.255.129_scf.xml
	Validate Intervals Of Measurment In SCF      ${attribNameListDisabled}    disabled
    ...    .//*[@class='PMRNL'][@distName='MRBTS-1/LNBTS-1/PMRNL-1']/    /home/ute/Downloads/192.168.255.129_scf.xml
	Run Keyword If    '${ntpOrGps}'=='NTP'       Validate Intervals Of Measurment In SCF    ${attribNameListGPS}    disabled
    ...    .//*[@class='PMRNL'][@distName='MRBTS-1/LNBTS-1/PMRNL-1']/    /home/ute/Downloads/192.168.255.129_scf.xml
	Run Keyword If    '${ntpOrGps}'=='GPS'       Validate Intervals Of Measurment In SCF    ${attribNameListGPS}    ${intervalTime}
    ...    .//*[@class='PMRNL'][@distName='MRBTS-1/LNBTS-1/PMRNL-1']/    /home/ute/Downloads/192.168.255.129_scf.xml
	Validate Intervals Of Measurment In SCF      reportingIntervalPm    ${reportingIntervalPmToCheck}
    ...    .//*[@class='PMCADM'][@distName='MRBTS-1/PMCADM-1']/    /home/ute/Downloads/192.168.255.129_scf.xml

PM Validate Intevals Of Measurment In TRS In Admin
    [Arguments]    ${intervalTime}
 	${attribNameList}=    Create List          lte_IP_Stats_Interval  lte_PHB_Stats_Interval  lte_Ethernet_Link_Interval  lte_IPSec_Interval
    ...  lte_IP_Filtering_Interval  lte_VLAN_IP_Stats_Interval  lte_VLAN_PHB_Stats_Interval  lte_VLAN_Stats_Interval  lte_ETHIF_Stats_Interval
    ...  lte_TWAMP_Stats_Interval  lte_TAC_Statistics_Interval  lte_TOP_FreqSync_Stats_Interval  lte_TOP_PhaseSync_Stats_Interval
    ...  lte_VLAN_IPv4_PHB_Stats_Interval  lte_VLAN_IPv4_Stats_Interval  lte_VLAN_IPv6_PHB_Stats_Interval  lte_VLAN_IPv6_Stats_Interval
    ...  lte_IPv6_Stats_Interval  lte_IPv6_PHB_Stats_Interval  lte_IPv4_Stats_Interval  lte_IPv4_PHB_Stats_Interval
	Validate Intervals Of Measurment In SCF    ${attribNameList}    ${intervalTime}
    ...    .//*[@class='PMTNL'][@distName='MRBTS-1/LNBTS-1/FTM-1/PMTNL-1']/    /home/ute/Downloads/192.168.255.129_scf.xml

PM Check If OAM Link Status Is True
    [Arguments]    ${linkState}
    Setup Enb Fsm Access
    ${oamStatusLink}=    Execute command on enb    ss -anp | grep 10.0.1.1:8102 | tail -n 1 | awk '{print $2}'
    Run Keyword If    ('${oamStatusLink}'=='ESTAB')    Set Suite Variable  ${oamStatus}    TRUE
    Run Keyword If    ('${oamStatusLink}'!='ESTAB')    Set Suite Variable  ${oamStatus}    FALSE
    Teardown Enb Fsm Access
    Run Keyword If    ('${linkState}' == '${oamStatus}')     Log    Connect to OAM OK    console=yes
    Run Keyword If    ('${linkState}' != '${oamStatus}')     Fatal Error

PM Check If Measurements Are Not Present In PM Report For Interval
    [Arguments]    ${pmReportTime}
    @{missingMeasurements}=    Run Keyword If    '${pmReportTime}'=='15min'    Run Keyword    Create List    LTE_Cell_Avail  LTE_Radio_Bearer
    ...  LTE_Cell_Load  LTE_UE_State
    ...    ELSE IF        '${pmReportTime}'=='30min'
    ...    Run Keyword    Create List    LTE_Cell_Load  LTE_UE_State
    @{listMeasurementType}=   Get Elements   source=${parsed_pm_report}      xpath=.//PMSetup//PMMOResult/NE-WBTS_1.0/@measurementType
    :FOR    ${attempt}    IN    @{missingMeasurements}
    \    Run Keyword And Continue On Failure    List Should Not Contain Value    ${listMeasurementType}    ${attempt}

PM Check Counters Values And Missing Measurements For 15 Min Interval
    ${parsed_pm_report}=    Parse XML
    ...    source=/tmp/PM/PM.BTS-1.${actual_year}${actual_month}${actual_day}.${actual_hour}${actual_time}00.ANY.xml
    Set Test Variable    ${parsed_pm_report}
    PM Check If Measurements Are Not Present In PM Report For Interval    15min
    PM Verify If Counter Has Expected Values For All Cells                counter_id=M8018C9
    ...                                                                   value=900
    ...                                                                   number_of_occurence=1
    PM Verify If Counter Has Expected Values For All Cells                counter_id=M8006C0
    ...                                                                   value=2
    ...                                                                   number_of_occurence=3
    PM Verify If Counter Has Expected Values For All Cells                counter_id=M8006C1
    ...                                                                   value=2
    ...                                                                   number_of_occurence=3

PM Check Counters Values And Missing Measurements For 30 Min Interval
    ${parsed_pm_report}=    Parse XML
    ...    source=/tmp/PM/PM.BTS-1.${actual_year}${actual_month}${actual_day}.${actual_hour}${actual_time}00.ANY.xml
    Set Test Variable    ${parsed_pm_report}
    PM Check If Measurements Are Not Present In PM Report For Interval    30min
    PM Verify If Counter Has Expected Values For All Cells                counter_id=M8018C9
    ...                                                                   value=900
    ...                                                                   number_of_occurence=1
    PM Verify If Counter Has Expected Values For All Cells                counter_id=M8006C0
    ...                                                                   value=2
    ...                                                                   number_of_occurence=3
    PM Verify If Counter Has Expected Values For All Cells                counter_id=M8006C1
    ...                                                                   value=2
    ...                                                                   number_of_occurence=3
    PM Verify If Counter Has Expected Values For All Cells                counter_id=M8020C3
    ...                                                                   value=1800
    ...                                                                   number_of_occurence=3
    PM Verify If Counter Has Expected Values For All Cells                counter_id=M8020C6
    ...                                                                   value=1800
    ...                                                                   number_of_occurence=3
    PM Verify If Counter Has Expected Values For All Cells                counter_id=M8007C0
    ...                                                                   value=4
    ...                                                                   number_of_occurence=3
    PM Verify If Counter Has Expected Values For All Cells                counter_id=M8007C1
    ...                                                                   value=4
    ...                                                                   number_of_occurence=3

PM Check Counters Values And Missing Measurements For 60 Min Interval
    ${parsed_pm_report}=    Parse XML
    ...    source=/tmp/PM/PM.BTS-1.${actual_year}${actual_month}${actual_day}.${actual_hour}${actual_time}00.ANY.xml
    Set Test Variable    ${parsed_pm_report}
    PM Verify If Counter Has Expected Values For All Cells                counter_id=M8018C9
    ...                                                                   value=900
    ...                                                                   number_of_occurence=4
    PM Verify If Counter Has Expected Values For All Cells                counter_id=M8006C0
    ...                                                                   value=2
    ...                                                                   number_of_occurence=12
    PM Verify If Counter Has Expected Values For All Cells                counter_id=M8006C1
    ...                                                                   value=2
    ...                                                                   number_of_occurence=12
    PM Verify If Counter Has Expected Values For All Cells                counter_id=M8020C3
    ...                                                                   value=1800
    ...                                                                   number_of_occurence=6
    PM Verify If Counter Has Expected Values For All Cells                counter_id=M8020C6
    ...                                                                   value=1800
    ...                                                                   number_of_occurence=6
    PM Verify If Counter Has Expected Values For All Cells                counter_id=M8007C0
    ...                                                                   value=4
    ...                                                                   number_of_occurence=6
    PM Verify If Counter Has Expected Values For All Cells                counter_id=M8007C1
    ...                                                                   value=4
    ...                                                                   number_of_occurence=6
    PM Verify If Counter Has Expected Values For All Cells                counter_id=M8013C45
    ...                                                                   value=8
    ...                                                                   number_of_occurence=3
    PM Verify If Counter Has Expected Values For All Cells                counter_id=M8013C47
    ...                                                                   value=8
    ...                                                                   number_of_occurence=3

PM Check TNL Counters And Missing Measurements For 15 Min Interval
    ${parsed_pm_report}=    Parse XML
    ...    source=/tmp/PM/PM.BTS-1.${actual_year}${actual_month}${actual_day}.${actual_hour}${actual_time}00.ANY.xml
    Set Test Variable    ${parsed_pm_report}
    PM Verify Number Of Occurence For Counters                            counter_id=M51321C1
    ...                                                                   number_of_occurence=1
    PM Verify Number Of Occurence For Counters                            counter_id=M51321C3
    ...                                                                   number_of_occurence=1

PM Check TNL Counters And Missing Measurements For 30 Min Interval
    ${parsed_pm_report}=    Parse XML
    ...    source=/tmp/PM/PM.BTS-1.${actual_year}${actual_month}${actual_day}.${actual_hour}${actual_time}00.ANY.xml
    Set Test Variable    ${parsed_pm_report}
    PM Verify Number Of Occurence For Counters                            counter_id=M51321C1
    ...                                                                   number_of_occurence=1
    PM Verify Number Of Occurence For Counters                            counter_id=M51321C3
    ...                                                                   number_of_occurence=1
    PM Verify Number Of Occurence For Counters                            counter_id=M51301C3
    ...                                                                   number_of_occurence=1
    PM Verify Number Of Occurence For Counters                            counter_id=M51301C3
    ...                                                                   number_of_occurence=1

PM Check TNL Counters And Missing Measurements For 60 Min Interval
    ${parsed_pm_report}=    Parse XML
    ...    source=/tmp/PM/PM.BTS-1.${actual_year}${actual_month}${actual_day}.${actual_hour}${actual_time}00.ANY.xml
    Set Test Variable    ${parsed_pm_report}
    PM Verify Number Of Occurence For Counters                            counter_id=M51321C1
    ...                                                                   number_of_occurence=4
    PM Verify Number Of Occurence For Counters                            counter_id=M51321C3
    ...                                                                   number_of_occurence=4
    PM Verify Number Of Occurence For Counters                            counter_id=M51301C1
    ...                                                                   number_of_occurence=2
    PM Verify Number Of Occurence For Counters                            counter_id=M51301C1
    ...                                                                   number_of_occurence=2
    PM Verify Number Of Occurence For Counters                            counter_id=M51300C2
    ...                                                                   number_of_occurence=2
    PM Verify Number Of Occurence For Counters                            counter_id=M51300C4
    ...                                                                   number_of_occurence=2

PM Check Snapshot Creation
    [Arguments]  ${snapshot_name}
    Run Keyword And Continue On Failure
    ...    OperatingSystem.File Should Exist
    ...    ${EXEC_DIR}/${snapshot_name}
    ${get_snapshot_size}=    Run         ls -l ${EXEC_DIR}/ | grep -i '${snapshot_name}' | awk '{print $5}'
    ${size_status}=          Evaluate    8000000 < ${get_snapshot_size} < 40000000
    Run Keyword and Continue on Failure
    ...    Should Be True    '${size_status}'=='True'

Check Measurements From BTS
    [Arguments]  ${expectError}=True
    ...    ${testType}=60min
	PM Verify PM Counters Reports From BTSSM
    Run Keyword If   '${testType}'=='60min'    PM Check Measurements New
    Run Keyword If    '${expectError}'=='False' and '${testType}'=='15min'    Check If Both PM Result Files Have Been Sent To OMS  upladPeriod=15min
    Run Keyword If    '${expectError}'=='False' and '${testType}'=='60min'    Check If Both PM Result Files Have Been Sent To OMS  upladPeriod=60min
    Run Keyword If    '${expectError}'=='False' and '${testType}'=='15min'    Diff PM files  uploadPeriod=15min
    Run Keyword If    '${expectError}'=='False' and '${testType}'=='60min'    Diff PM files  uploadPeriod=60min

Check If Both PM Result Files Have Been Sent To OMS
    [Documentation]
    ...   Author: Lukasz Rumak
    [Arguments]  ${upladPeriod}=60min
	${actualYear}=   Get Current Date  result_format=%Y   time_zone=UTC
	${actualMonth}=   Get Current Date  result_format=%m   time_zone=UTC
	${actualDay}=   Get Current Date  result_format=%d   time_zone=UTC
	${actualHourToInt}=    Convert To Integer    ${actualHour}
	${actualHour-1}=    Run Keyword If    ${actualHourToInt}==0     Set Variable    23
	...    ELSE    Evaluate    int(${actualHourToInt}-1)
	${actualHour-1}=    Convert To String   ${actualHour-1}
	${getLength-1}=    Get Length    ${actualHour-1}
	${actualHour-1}=    Run Keyword If    ${getLength-1} == 1    Set Variable    0${actualHour-1}    ELSE    Set Variable    ${actualHour-1}
	${actualHourToInt2}=    Convert To Integer    ${actualHour}
	${actualHour+1}=    Run Keyword If    ${actualHourToInt2}==0     Set Variable    23
	...    ELSE    Evaluate    int(${actualHourToInt2}+1)
	${actualHour+1}=    Convert To String   ${actualHour+1}
	${getLength+1}=    Get Length    ${actualHour+1}
	${actualHour+1}=    Run Keyword If    ${getLength+1} == 1    Set Variable    0${actualHour+1}    ELSE    Set Variable    ${actualHour+1}
    ${actualHourToInt3}=    Convert To Integer    ${actualHour}
	${actualHour+2}=    Run Keyword If    ${actualHourToInt3}==0     Set Variable    23
	...    ELSE    Evaluate    int(${actualHourToInt3}+2)
	${actualHour+2}=    Convert To String   ${actualHour+2}
	${getLength+2}=    Get Length    ${actualHour+2}
	${actualHour+2}=    Run Keyword If    ${getLength+2} == 1    Set Variable    0${actualHour+2}    ELSE    Set Variable    ${actualHour+2}
    Set Test Variable    ${actualYear}
	Set Test Variable    ${actualMonth}
	Set Test Variable    ${actualDay}
	Set Test Variable    ${actualHour-1}
    Set Test Variable    ${actualHour+1}
    Set Test Variable    ${actualHour+2}

Diff PM files
    [Arguments]  ${upladPeriod}=60min
    ${extnsion}=    Run    ls -l /home/flexi1/UPLOADS/KEYSTATS/ | awk '{print $9}'| tail -n 1 | cut -d'.' -f7
    ${unpack}    Set Variable If    "${extnsion}"=="xz"    unxz
    ...                             "${extnsion}"=="gz"    gunzip
    Run    sudo ${unpack} /home/flexi1/UPLOADS/KEYSTATS/*
    ${rcActualHour1}=    Run And Return Rc    diff --brief /tmp/PM/PM.BTS-1.${actualYear}${actualMonth}${actualDay}.${actualHour-1}0000.ANY.xml
    ...  /home/flexi1/UPLOADS/KEYSTATS/PM.BTS-1.${actualYear}${actualMonth}${actualDay}.${actualHour-1}0000.LTE.xml
	Run Keyword and Continue on Failure    Should Be Equal As Integers	  ${rcActualHour1}	  0
    ${rcActualHour}=    Run And Return Rc    diff --brief /tmp/PM/PM.BTS-1.${actualYear}${actualMonth}${actualDay}.${actualHour}0000.ANY.xml
    ...  /home/flexi1/UPLOADS/KEYSTATS/PM.BTS-1.${actualYear}${actualMonth}${actualDay}.${actualHour}0000.LTE.xml
	Run Keyword and Continue on Failure    Should Be Equal As Integers	  ${rcActualHour}	  0

PM Find The Measurement From The Result File Do Not Check Intervals Test
	${found}=  set variable   ${false}
	${missingCountersList} =	Create List
	${extraCountersList} =	Create List
	${duplicateCountersList} =	Create List
	${ignoredCountersList} =	Create List
	Set Test Variable   ${found}
	Set Test Variable   ${missingCountersList}
	Set Test Variable   ${extraCountersList}
	Set Test Variable   ${duplicateCountersList}
	Set Test Variable   ${ignoredCountersList}
	:FOR   ${PMResult}    IN    @{PMResultList}
    \			${measurementType}=  Get Element Attribute	source=${PMResult}	 name=measurementType	xpath=.//NE-WBTS_1.0
    \		    Set Test Variable   ${PMResult}
    \			Run keyword if  '${measurementType}'=='${measName}'   PM Check Measurement Content
	Run keyword if   '${found}'=='${false}'  Append To List  ${missingMeasurementslist}  ${measName}

PM Check Measurements New
	Log    Checking Measurements    console=yes
	${measurementList} =	        Create List
	${missingMeasurementslist} =	Create List
	${resultIntervals} =	        Create List
	${cellObjects} =	            Create List
	${startTimes} =	                Create List
	Set Test Variable    ${measurementList}
	Set Test Variable    ${missingMeasurementslist}
	Set Test Variable    ${resultIntervals}
	Set Test Variable    ${cellObjects}
	Set Test Variable    ${startTimes}
	${actualHourToInt2h}=    Convert To Integer    ${actualHour}
	${actualHour+1h}=    Run Keyword If    ${actualHourToInt2h}==0     Set Variable    23
	...    ELSE    Evaluate    int(${actualHourToInt2h}+1)
	${actualHour+1h}=    Convert To String   ${actualHour+1h}
	${getLengthh+1}=    Get Length    ${actualHour+1h}
	${actualHour+1h}=    Run Keyword If    ${getLengthh+1} == 1    Set Variable    0${actualHour+1h}
	...    ELSE    Set Variable    ${actualHour+1h}
	${actualHour+1h}=   Convert To Integer  ${actualHour+1h}
	Set Test Variable    ${actualHour+1h}
	${ignoredMeas}=	     Create List    @{IGNORED_MEASUREMENTS_GPS}
	${xml}=              Parse XML      source=${BASELINE_FILE}
	${xml2}=             Parse XML      source=/tmp/PM/PM.BTS-1.${actualYear}${actualMonth}${actualDay}.${actualHour}${actualTime}00.ANY.xml
	${presentReportName}=    Set Variable    PM.BTS-1.${actualYear}${actualMonth}${actualDay}.${actualHour}${actualTime}00.ANY.xml
	Set Test Variable	     ${presentReportName}
	${presentReportName2}=    Set Variable    PM.BTS-1.${actualYear}${actualMonth}${actualDay}.${actualHour+1h}${actualTime}00.LTE.xml
	Set Test Variable	${presentReportName2}
    @{measurementList}=      Get Elements Texts   source=${xml}    xpath=.//Measurement/Name
	Set Test Variable	     @{measurementList}
	@{PMResultList}=         Get Elements   source=${xml2}    xpath=.//PMMOResult/NE-WBTS_1.0/@measurementType
	Set Test Variable        @{PMResultList}
	${baselineMeasurements}=    Create List    @{measurementList}
	${resultsMeasurements}=    Create List    @{PMResultList}
	${resultsAnsIgnored}=    Combine Lists    ${resultsMeasurements}    ${ignoredMeas}
	Remove Duplicates    ${resultsAnsIgnored}
	${missing}=    Run Keyword And Continue On Failure    List Should Contain Sublist    ${resultsAnsIgnored}  ${baselineMeasurements}

PM Verify Value Of Counter For Cell New
    [Arguments]    ${cell}
    ${counters}=    Run Keyword If    '${cell}'=='1'    Create Dictionary    M8020C0=1
    ...                                                                      M8020C1=1
    ...                                                                      M8020C2=0
    ...                                                                      M8020C3=${unblocked_time}
    ...                                                                      M8020C4=${blocked_time}
    ...                                                                      M8020C5=0
    ...                                                                      M8020C6=900
    ...    ELSE IF    '${cell}'=='2'    Create Dictionary    M8020C0=1
    ...                                                      M8020C1=1
    ...                                                      M8020C2=0
    ...                                                      M8020C3=${unlocked_time}
    ...                                                      M8020C4=${locked_time}
    ...                                                      M8020C5=0
    ...                                                      M8020C6=900
    ...    ELSE    Create Dictionary    M8020C0=0
    ...                                 M8020C1=0
    ...                                 M8020C2=0
    ...                                 M8020C3=900
    ...                                 M8020C4=0
    ...                                 M8020C5=0
    ...                                 M8020C6=900
    :FOR    ${key}    IN    @{counters.keys()}
    \    ${value}=    Get From Dictionary    ${counters}    ${key}
    \    Log    ${key}, ${value}
    \    ${path}=    Set Variable If     "@{release}[0]_@{release}[1]"=="FL19A_FSM4"
        ...    sum(.//PMMOResult[MO/localMoid = 'DN:NE-LNBTS-1/LNCEL-${cell}/MCC-244/MNC-09']//${key})
        ...     sum(.//PMMOResult[MO/DN = 'PLMN-PLMN/MRBTS-1/LNBTS-1/LNCEL-${cell}']//${key})
    \    ${xml}=    Parse XML
         ...        source=/tmp/PM/PM.BTS-1.${actual_year}${actual_month}${actual_day}.${actual_hour}${actual_time}00.ANY.xml
    \    ${counter_value}=    Evaluate Xpath
         ...                  ${xml}
         ...                  ${path}
    \    ${counter_value}=    Convert To Integer    ${counter_value}
    \    ${value_int}=        Convert To Integer    ${value}
    \    Run Keyword If       '${key}'=='M8020C3' or '${key}'=='M8020C4'
         ...                  Run Keyword And Continue On Failure
         ...                  Should Be True    ${${value_int}-10} < ${counter_value} < ${${value_int}+10}
         ...                  ELSE
         ...                  Run Keyword And Continue On Failure
         ...                  Should Be True    ${counter_value} == ${value_int}
