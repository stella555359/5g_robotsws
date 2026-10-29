
# CB010414-AB#10 Radio Performance : Parity with CB010796 - RF cooling by the scheduler
Robot test suite for feature CB010414.

## Test line requirements
This section is taken from automation requests done by Adrian Tomczyk.
* CloudRAN gNB (#6.1 SKT in SA mode) with GNSS synchronization and 1x TDD FR1 AVQL/AVQE RU with n78 band,
* Switched fronthaul connection for CloudRAN (FHGW),
* RINLINE2 RAN NIC,
* vDU,
* vCU,
* GPS antenna - FYGC
* Airphone

### Required initial BTS state (not to be checked but provided directly from SCF)
* Hidden (vendor) parameter on vDU actMicroDtx=True. It is default value.
* Hidden (vendor) parameter on vDU disableSchedAssistRfCooling=False. It is default value.
* Hidden (vendor) parameter on vDU allowGBRMutingForRfCooling=False. It is default value.
* gNB configured with TDD cell (100MHz, n78)

## Test cases

### CB010414_CB010796_Stop_slot_blanking_triggered_by_RFU_for_the_temperature_is_cooling_down_and_counters_check
Purpose of this test case is to verify stop slot blanking procedure along with appropriate counters on vDU.

#### Test specific Preconditions
* R&D Debug Parameters.L2PS.rdFeatureFlagBitmap4.22 - DL.RF_COOLING set to True, for logging events in TTI Traces

#### Requirements:
* 5G_RAN_USR_RRM_21656
* 5G_RAN_USR_RRM_22755
* OAM_REQ_RADIO_2714
* OAM_REQ_RADIO_2715
* OAM_REQ_RADIO_2716
* OAM_REQ_RADIO_1805
* OAM_REQ_RADIO_2101


* Owner: adrian.tomczyk@nokia.com
* Author: wojciech.peciak@nokia.com
* Maintainer: wojciech.peciak@nokia.com

#### Test scenario defined by owner
* Step 1
  * Description:<br>
    Check BTS status.
  * Expected:<br>
    Cell is on air.
* Step 2 
  * Description:<br>
  Check below R&D/internal counters in oampm pod, under pmdataserver container:<br>
      M55601C00016 - NR_CELL_RF_COOL_MODE0_SAMPLES<br>
      M55601C00017 - NR_CELL_RF_COOL_MODE0_CHNG_TO<br>
      M40008CRD700 - NR_RMOD_TEMP_NORMAL_SAMPL<br>
      M40008CRD701 - NR_RMOD_TEMP_INCREASED_SAMPL<br>
      M40008CRD702 - NR_RMOD_TEMP_HIGH_SAMPL<br>
      M55601C00021 - NR_CELL_RF_COOL_MODE1_CHNG_TO<br>
      M55601C00020 - NR_CELL_RF_COOL_MODE1_SAMPLES<br>
      M55601C00019 - NR_CELL_RF_COOL_MODE2_CHNG_TO<br>
      M55601C00018 - NR_CELL_RF_COOL_MODE2_SAMPLES<br>
      M55601C00023 - NR_CELL_RF_COOL_MODE3_CHNG_TO<br>
      M55601C00022 - NR_CELL_RF_COOL_MODE3_SAMPLES
  * Expected:<br>
    Counters that are incremented:<br>
    M55601C00016 - NR_CELL_RF_COOL_MODE0_SAMPLES<br>
    M55601C00017 - NR_CELL_RF_COOL_MODE0_CHNG_TO<br>
    M40008CRD700 - NR_RMOD_TEMP_NORMAL_SAMPL<br>
    Counters that are not incremented when radio is not overheated (save its values for comparison in step 6):<br>
     M40008CRD701 - NR_RMOD_TEMP_INCREASED_SAMPL<br>
     M40008CRD702 - NR_RMOD_TEMP_HIGH_SAMPL<br>
     M55601C00021 - NR_CELL_RF_COOL_MODE1_CHNG_TO<br>
     M55601C00020 - NR_CELL_RF_COOL_MODE1_SAMPLES<br>
     M55601C00019 - NR_CELL_RF_COOL_MODE2_CHNG_TO<br>
     M55601C00018 - NR_CELL_RF_COOL_MODE2_SAMPLES<br>
     M55601C00023 - NR_CELL_RF_COOL_MODE3_CHNG_TO<br>
     M55601C00022 - NR_CELL_RF_COOL_MODE3_SAMPLES
* Step 3
	* Description:<br>
		Attach UE to the cell and start data traffic (non GBR) in the cell (DL, UL),<br>
        trigger overheating of the radio module to start slot blanking.
	* Expected:<br>
		Slot blanking is performed according to the specification,<br> 
        throughput is decreased (you can refer to 5G_RAN_ARC_9617)
* Step 4
	* Description:<br>
		Decrease data traffic (to cool down radio module and stop slot blanking<br>
        after exceeding the proper threshold defined in tcs.json file)
	* Expected:<br>
		According to algorithm slot blanking is stopped <br>
        (when the temperature of the radio module decreases and exceed proper threshold defined in tcs.json file).
* Step 5
	* Description:<br>
		Increase data traffic, trigger overheating of the radio module to start slot blanking and to achieve SB levels: 1, 2, 3.<br>
		SB level should be increased every 5 minutes.<br> 
		So overall data traffic should be sent for over 15 minutes to check all SB levels.
	* Expected:<br>
		Slot blanking is performed according to the specification.
* Step 6
	* Description:<br>
		Check following R&D/internal counters in oampm pod, under pmdataserver container:<br>
		M40008CRD700 - NR_RMOD_TEMP_NORMAL_SAMPL<br>
		M40008CRD701 - NR_RMOD_TEMP_INCREASED_SAMPL<br>
		M40008CRD702 - NR_RMOD_TEMP_HIGH_SAMPL<br>
		M55601C00021 - NR_CELL_RF_COOL_MODE1_CHNG_TO<br>
		M55601C00020 - NR_CELL_RF_COOL_MODE1_SAMPLES<br>
		M55601C00019 - NR_CELL_RF_COOL_MODE2_CHNG_TO<br>
		M55601C00018 - NR_CELL_RF_COOL_MODE2_SAMPLES<br>
		M55601C00023 - NR_CELL_RF_COOL_MODE3_CHNG_TO<br>
		M55601C00022 - NR_CELL_RF_COOL_MODE3_SAMPLES<br>
	* Expected:<br>
		Above counters are incremented according to the specification.
* Step 7
	* Description:<br>
		Set disableSchedAssistRfCooling=true => NOT POSSIBLE TO DO. PARAMETER HIDDEN.
	* Expected:<br>
		disableSchedAssistRfCooling is set to true, slot blanking stopped immediately.


#### Pass criteria
* Slot blanking is stopped in two scenarios:
	1. When the temperature of the radio module decreases and exceed proper threshold defined in tcs.json file.
	2. When feature is deactivated (disableSchedAssistRfCooling=true) => NOT POSSIBLE TO DO. PARAMETER HIDDEN.<br> 
	Disused with test owner that this part was changed after the test scenario creation and will not be verified.
* Counters are properly assigned to vDU and/or vCU (accordingly with NIDD and MIND).
* Counters activation flags are properly assigned to vDU and or/vCU (accordingly with NIDD and MIND).
* Counter are incremented in line with NIDD definition.

#### Automatic TC steps
* Preconditions
* Step 1: Wait For Clean Counters Period
* Step 2: Counters Collection And Verification With No Previous Slot Blanking


* Step 3: Register UE And Start Data Transfer
* Step 4: Trigger RU Increased Temperature And Wait For 20s
* Step 5: Trigger One Lvl Increase In RU Slot Blanking And Wait For 20s
* Step 6: Reset Slot Blanking To Lvl 0 And Wait For 20s
* Step 7: Trigger One Lvl Increase In RU Slot Blanking And Wait For 20s
* Step 8: Reset Slot Blanking To Lvl 0 And Wait For 0s
* Step 9: Counters Collection And Verification With Two Cycles Of Slot Blanking Lvl Increase 


* Step 10: Catch TTI Trace To Confirm Slot Blanking With 0%
* Step 11: Trigger One Lvl Increase In RU Slot Blanking And Wait For 20s
* Step 12: Catch TTI Trace To Confirm Slot Blanking With 17%
* Step 13: Trigger One Lvl Increase In RU Slot Blanking And Wait For 20s
* Step 14: Catch TTI Trace To Confirm Slot Blanking With 35%
* Step 15: Trigger One Lvl Increase In RU Slot Blanking And Wait For 20s
* Step 16: Catch TTI Trace To Confirm Slot Blanking With 50%
* Step 17: Counters Collection And Verification With Slot Blanking Increase To All Lvls


#### Test case developer notes


* Global Variables defined and accessible from test scope:<br>

| Variable 						          | Default value| Description 																								                                                                  |
|--------------------------| ------------ |-------------------------------------------------------------------------------------------------------|
| ${NR_CELL_ID}            | 1    		 | ID of tested NR cell. Default value: 1                                                                |
| ${UE_ID}                 | 1    		 | ID of tested UE. Default value: 1                                                                     |
| ${RMOD_MO_ID}            | 2    		 | ID of tested RMOD in vDU SCF. Default value: 2                                                        |
| ${RMOD_AP_ID}            | 1    		 | ID of tested simulated RMOD in AirPhone OAM. Default value: 1                                         |
| ${NAMESPACE}             |      		 | vDU namespace used for collecting Cplane logs                                                         |
| ${COUNTER_PERIOD}        | 5    		 | Counter collecting interval in minutes. Default value: 5                                              |
| ${COUNTER_PERIOD_IN_SEC} |      		 | Counter collecting interval in seconds. Calculated from ${COUNTER_PERIOD}                             |
| ${PMMNL_DIST_NAME}       |      		 | Dist path to the mtSBTSRMODTemperature parameter MO - PMMNL-1                                         |
| ${PMCADM_DIST_NAME}      |      		 | Dist path to the reportingIntervalPm parameter MO - PMCADM-1                                          |
| ${NRPMRNL_DIST_NAME}     |      		 | Dist path to the miNrCellAvailability parameter MO - NRPMRNL-1                                        |
| ${TRACE_ID}              |      		 | Id of started TTI Trace collection received from UTF tool                                             |
| ${MAX_UTF_LOGS_DELAY}    | 300s 		 | Max time in seconds needed for change of UTF logs collecting status to 'running'. Default value: 300s |
| ${VDU_MRBTS_ID}          |      		 | MRBTS id number in first vDU SCF in current topology                                                  |
| ${NRBTS_ID}              |      		 | NRBTS id number in first vDU SCF in current topology                                                  |
| ${LOG_PATH}              |      		 | Absolute path to logs directories set in Test Setup                                                   |
| ${IGNORED_ALARMS_VCU}    |      		 | List of dictionaries with ignored alarms data for VCU. Created during Test Suite Setup                |
| ${IGNORED_ALARMS_VDU}    |      		 | List of dictionaries with ignored alarms data for VCU. Created during Test Suite Setup                |
| ${WIRESHARK_STARTED}     |      		 | Flag to signalize Start Wireshark Log Collection For VCU KW execution.                                |

* Test was realized with simulator AirPhone, which resulted in different way of triggering slotBlankig.<br>
  Since radios are simulated, overheating is triggered via proper command in aashell on AirPhone module.
  https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1463341040#CB005788:HightemperaturehandlingofRFunitsinRF7.1TDDFR1-OamTerm/AaShellcommand
* SlotBlanking mechanizm occurrence is verified with the use of TTI Trace. 
* To catch dlSlotBlankingInfo events in TTI Trace, R&D flag has to be set True on vDU L2PS component.
  https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1598016601#Prechecks/FaultsTroubleShooting-EnablefromWebEm
* Parameters activating feature are hidden in vendor file on vDU and the feature is active by default,<br>
  so scenario with feature deactivation during slotBlanking is not feasible by the customer.   
* Verified counters belong to R&D counters group which is also hidden from the WebEM point of view.
* MNL.MNLENT.PMMNL.mtSBTSRMODTemperature parameter is set during the test in order to activate RU related counters.
* It was discussed with test owner that counter period can be set as the same for all parameters (e.g. 5min).
* For this test to be able to download tti-dec (for parsing TTI traces) authentication token for artifactory<br>
  needs to exist under path: /etc/token/ca_ute_artifactory_readonly. If it doesn't exist the test will fail.
* In case TTI conversion is taking too many of VM's resources it is possible to modify parameters of event decoder.<br>
  Please refer to following conversation if more information is needed: https://teams.microsoft.com/l/message/
  19:7c14f321090e4594a2d86d5f330db93a@thread.skype/1727972568807?tenantId=5d471751-9675-428d-917b-70f44f9630b0&groupId
  =aaac7a75-7d1a-4bf8-93fb-8da9e50fbc57&parentMessageId=1727972568807&teamName=TAF&channelName=
  %F0%9F%90%9B%20Bugs%20and%20problems&createdTime=1727972568807. <br>
  Currently, eventdecoder_options are set to be:
  * split after 200000 events,
  * filter in only dlSlotBlankingInfo events.<br>
  
  Information can also be found on taf.converters.eventdecoder library page:<br>
  https://taf-converters-eventdecoder.docs.taf.ute.nsn-rdnet.net/en/latest/interfaces/interface.html#taf.converters. <br>
  eventdecoder.interface.eventdecoder.create_eventdecoder_converter.
* When SlotBlankig is not triggered, TTI Trace event decoder is providing no file at all <br>
  since none of dlSlotBlankingInfo events have occurred.
  This behavior is expected and accounted for in the test.


#### History of changes
* 13.12.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1385 - Initial creation
* 04.02.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1418 - Removed explicit delta method in "Perform Parameter Commissioning Vdu Aic" KW
* 19.03.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1438 - Refactor parameters change to one delta recommissioning
* 01.04.2026 - https://jiradc.ext.net.nokia.com/browse/IWK-1818 - Align NR_RMOD_TEMP_*_SAMPL counters naming
