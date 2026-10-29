# CB008127: Measurement profiles
Robot test suite for feature CB008127.

## Test line requirements
Band available on which we have UE with power class 2 supported in test line.
For first test cases preferred band is n41 because this is TMO US band and this feature will be delivered to TMO even
before releasing full scope of the feature for lab testing only. Two NR SA cells connected via programmable 
attenuator to UE with power class 2. RRC establishment procedure is enabled in NR BTS or in delta for test cases.

### Example configuration
ASIL+ABIO+2xAEHC 

#### Cell config
AEHC/AZHL:
* Cell1 - reference to the cell in test suite and test case: GNB_55014_CELL_2 - [Band n41]: 
  Cell type: NR SA, Purpose: Target cell where RRC re-establishment procedure will be performed.
AEHC/AZHL:
* Cell2 - reference to the cell in test suite and test case: GNB_55014_CELL_3 - [Band n41]: 
  Cell type: NR SA, Purpose: Source cell from which UE starts with RRC attach procedure and DL traffic
  to enter target cell without typical HO procedure (RRC Re-establishment is enabled and forced by attenuation level).

### Required initial BTS config (not to be checked but provided directly from SCF)
* Feature CB008127 activated (actMeasurementProfile = SA).
* SA RRC Re-establishment feature is set to same GNB. (rrcReestabTypeSA=sameGNB)
* Following parameters related to PM counters for Measurement Profile are set to 5min: 
  miNrMeasProfileMappingSA=5min
  miNrMeasProfileIntraFreq=5min
* Create main object for Measurement Profiles feature: NRBTS-/NRMEAS_PROFILE-1.
* Under main object create object for Intra-Frequency: NRBTS-/NRMEAS_PROFILE-1/NRMEASPR_IAF-1 with some non-default values defined below:
  a1HysteresishoSsbRsrp=1
  a1ThresholdhoSsbRsrp=96
  a1TimeToTriggerhoSsbRsr=ms512
  a2HysteresishoSsbRsrp=2
  a2ThresholdhoSsbRsrp=67
  a2TimeToTriggerhoSsbRsrp=ms640
  a3HysteresisSsbRsrp=3
  a3OffsetSsbRsrp=10
  a3TimeToTriggerSsbRsrp=ms256
  a5HysteresisSsbRsrp=5
  a5Threshold1SsbRsrp=60
  a5Threshold2SsbRsrp=65
  a5TimeToTriggerSsbRsrp=ms160
  others leave with default values under this object.
  The same parameter as configured in NRMEASPR_IAF-1 object are also under NRCELL object please check if NRCELL parameters
  have different values than from NRMEASPR_IAF-1.
* Under main object create object SA Mapping: NRBTS-/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-1 with some non-default values defined below:
  nrMeasPrIafDN=MRBTS-X/NRBTS-X/NRMEAS_PROFILE-1/NRMEASPR_IAF-1 ( for X you need to put your own SBTS and NRBTS ID)
  with DN for earlier created NRBTS-/NRMEAS_PROFILE-1/NRMEASPR_IAF-1 object.
  freqBandIndicatorNR=96
  uePowerClass=ue-PowerClass2
  others leave with default values under this object.

## Test cases

### CB008127-E_B1_Selection_of_measurement_profile_based_on_PLMN_NSSAI_slice
This case is to verify the functionality of Measurement Profile for power class 2 UE for defined NSSAI and PLMN.

* Owner: krzysztof.mirecki@nokia.com
* Author: krzysztof.mirecki@nokia.com
* Maintainer: szymon.startek@nokia.com

#### Test scenario defined by owner
* Step1: Start Wireshark Log And Attach UE
  Description:
  Wireshark is started and after it UE attach is launched. Used NR cell is verified from NAA application.
* Step 2: Start Data Transfer
  Description:
  After UE attach DL traffic is started and stabilized.
* Step 3: Stop Data Transfer
  Description:
  Collecting tcpdumps is stopped and variable ${STARTED_TCPDUMP} is set to false. After all data traffic is stopped on NR_UE.
* Step 4: Tcpdump Verification
  Description:
  Collected tcpdumps are checked by three wireshark filters. 
  By first filtering it is checked if InitialContextSetupRequest with proper NSSAI and PLMN was performed.
  By second wireshark filtering (variable ${filter1}) it is checked if intra frequency measurements A2, A3 and A5 have values defined
  in Measurement Profile (NRMEASPR_IAF-1) configuration.
  NRMEASPR_IAF-1 can be found in BTS configuration under MRBTS-XYZ/NRBTS-XYZ/NRMEAS_PROFILE-1
  By third wireshark filtering (variable ${filter2}) it is checked if inter frequency measurements A3 and A5 have values defined
  in BTS configuration under MRBTS-XYZ/NRBTS-XYZ/NRCELL-X/NRHOIF-1.
  NRCELL-X is the NR cell where UE performed attach.

#### Pass Criteria
* Step 1: Wireshark logs are started successfully and UE is in defined cell.
* Step 2: Commands to perform given throughput were successful.
* Step 3: No error during stopping and coping wireshark logs and no error related to UE connection.
* Step 4: The number of packet for all defined filters is above 0.

#### Automatic TC steps
* Step1: Start Wireshark Log And Attach UE
  Description:
  Wireshark is started and after it UE attach is launched. Used NR cell is verified from NAA application.
* Step 2: Start Data Transfer
  Description:
  After UE attach DL traffic is started and stabilized.
* Step 3: Stop Data Transfer
  Description:
  Collecting tcpdumps is stopped and variable ${STARTED_TCPDUMP} is set to false. After all data traffic is stopped on NR_UE.
* Step 4: Tcpdump Verification
  Description:
  Collected tcpdumps are checked by three wireshark filters. 
  By first filtering it is checked if InitialContextSetupRequest with proper NSSAI and PLMN was performed.
  By second wireshark filtering (variable ${filter1}) it is checked if intra frequency measurements A2, A3 and A5 have values defined
  in Measurement Profile (NRMEASPR_IAF-1) configuration.
  NRMEASPR_IAF-1 can be found in BTS configuration under MRBTS-XYZ/NRBTS-XYZ/NRMEAS_PROFILE-1.
  The measurement values used to be in UEContextSetupRequest but after CNI-102699 they are no longer there, but they are still in RRC Reconfiguration.
  By third wireshark filtering (variable ${filter2}) it is checked if inter frequency measurements A3 and A5 have values defined
  in BTS configuration under MRBTS-XYZ/NRBTS-XYZ/NRCELL-X/NRHOIF-1.
  NRCELL-X is the NR cell where UE performed attach.

#### Test case developer notes
* Verification is done by packet filtering for NGAP and F1AP protocols.
  First packet filtering is to check if in InitialContextSetupRequest (NGAP protocol) values of NSSAI and PLMN are
  as those defined in NRMEASPR_MA_SA-1. This is only precondition for event verification and if this filtering is not passing
  you need to check object NRMEASPR_MA_SA-1 and what values for NSSAI and PLMN are defined there.
  Second packet filtering ( variable ${filter1} in test case) is to check if intra frequency measurements A2, A3 and A5
  have values from object NRMEASPR_IAF-1.
  Third packet filtering ( variable ${filter2} in test case) is to check if inter frequency measurements A3 and A5
  have values from HOIF object related to test cell where attach was performed (GNB_55014_CELL_2). Those measurements are
  not configured in NRMEASPR_MA_SA-1 so should be untouched by CB008127 Measurement Profiles feature.
  * Example of mapping between filter parameters and SCF parameters for test line Beamskupin:
    * packet_filter=(((((ngap)&&(ngap.sD==d1:43:a5))&&(ngap.procedureCode==14))&&(ngap.sST==01))&&(e212.guami.mcc==001))&&(e212.guami.mnc==01)
      * Parameters can be found under object MRBTS-55014/NRBTS-55014/SNSSAI-1
        * ngap.sD==d1:43:a5 -> sd = 13714341
        * ngap.sST==01 -> sst = 1
      * Parameters can be found under object MRBTS-55014/NRBTS-55014/NRPLMN-1
        * e212.guami.mcc==001  -> mcc = 1
        * e212.guami.mnc==01   -> mnc = 1
    * Filter 1:((((((((((((nr-rrc.hysteresis == 6)) &&
    ...  (nr-rrc.eventId == 2)) && (nr-rrc.timeToTrigger == 7)) && (nr-rrc.eventId == 4)) &&
    ...  (nr-rrc.timeToTrigger == 6)) && (nr-rrc.hysteresis == 10)) && (nr-rrc.measTriggerQuantity.rsrp == 60))
    ...  && (nr-rrc.measTriggerQuantity.rsrp == 65)) && (nr-rrc.eventId == 1)) && (nr-rrc.hysteresis == 4))
    ...  && (nr-rrc.timeToTrigger == 11)) && (nr-rrc.measTriggerQuantity.rsrp == 67)
      * Parameters can be found under object MRBTS-55014/NRBTS-55014/NRMEAS_PROFILE-1/NRMEASPR_IAF-1
        * nr-rrc.hysteresis == 6  -> a3HysteresisSsbRsrp = 3
        * nr-rrc.timeToTrigger == 7 -> a3TimeToTriggerSsbRsrp = ms256
        * nr-rrc.timeToTrigger == 6 -> a5TimeToTriggerSsbRsrp = ms160
        * nr-rrc.hysteresis == 10 -> a5HysteresisSsbRsrp = 5
        * nr-rrc.measTriggerQuantity.rsrp == 60 -> a5Threshold1SsbRsrp = 60
        * nr-rrc.measTriggerQuantity.rsrp == 65 -> a5Threshold2SsbRsrp = 65
        * nr-rrc.hysteresis == 4 -> a2HysteresishoSsbRsrp = 2
        * nr-rrc.timeToTrigger == 11 -> a2TimeToTriggerhoSsbRsrp = ms640
        * nr-rrc.measTriggerQuantity.rsrp == 67 -> a2ThresholdhoSsbRsrp = 67
    * Filter 2:((((((((((nr-rrc.timeToTrigger == 3) && (nr-rrc.hysteresis == 8)) && (nr-rrc.measTriggerQuantity.rsrp == 65))
    ...  && (nr-rrc.measTriggerQuantity.rsrp == 60))) && (nr-rrc.eventId == 4)) && (nr-rrc.eventId == 2)) && (nr-rrc.hysteresis == 12))
    ...  && (nr-rrc.timeToTrigger == 12)) && (nr-rrc.measTriggerQuantityOffset.rsrp == 0)) && (f1ap.procedureCode == 7)
      * Parameters can be found under object MRBTS-55014/NRBTS-55014/NRCELL-3/NRHOIF-1
        * nr-rrc.timeToTrigger == 3 -> a5TimeToTriggerSsbRsrp= ms80
        * nr-rrc.hysteresis == 8 -> a5HysteresisSsbRsrp = 4
        * nr-rrc.measTriggerQuantity.rsrp == 65 -> a5Threshold2SsbRsrp = 65
        * nr-rrc.measTriggerQuantity.rsrp == 60 -> a5Threshold1SsbRsrp = 60
        * nr-rrc.hysteresis == 12 -> a3HysteresisSsbRsrp = 6
        * nr-rrc.timeToTrigger == 12 -> a3TimeToTriggerSsbRsrp = ms1024
        * nr-rrc.measTriggerQuantityOffset.rsrp == 0 -> a3OffsetSsbRsrp = 0
#### History of changes
* 27.10.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1133 - initial creation
* 20.10.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1354 - change of filters to work with Wireshark 4.2
* 24.10.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1355 - added port 29211 to wireshark log collection options to work with CB007208
* 29.10.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1357 - change of filter1 to check values in RRC Reconfiguration and not UEContextSetupRequest after CNI-102699
* 30.05.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1488 - change of filters to work with Wireshark 4.4

### CB008127-G_B2_Successful_configuration_of_A2_and_intra-freq_A3_A5_during_SgNBAdditionReq
This case is to verify if the priority of Measurement Profile for SPID and PLMN works as expected.
It checks that from 4 definitions of Measurement Profile in SCF proper one will be selected according to
assigned priority to them. Definition of Measurement Profile with first priority is for different SPID 
than used by UE. Definition of Measurement Profile with second priority is for different PLMN than
used by UE. Definition of Measurement Profile with third priority is for the same PLMN and SPID as used
by UE and definition of Measurement Profile with fourth priority is for the same PLMN and SPID as used
by UE but here priority is lower than as for previous Measurement Profile ( third). It is checked that
Measurement Profile assigned to UE is with values from Measurement Profile with third priority as this
is first possible to be assign according to priorities. It is done by wireshark filtering.

* Owner: krzysztof.mirecki@nokia.com
* Author: krzysztof.mirecki@nokia.com
* Maintainer: szymon.startek@nokia.com

#### Test scenario defined by owner
* Step 1: Start Wireshark Log And Attach UE
  Description:
  Wireshark is started and after it UE attach is launched. Used NR cell is verified from NAA application.
* Step 2: Stop Wireshark Logs
  Description: After UE attach is completed wireshark log is stopped.
* Step 3: Tcpdump Verification
  Description:
  Collected tcpdumps are checked by two wireshark filters. 
  By first filtering it is checked if sgNbAdditionRequest is send with SPID and PLMN for which Measurment Profile was defined.
  By second wireshark filtering (variable ${filter1}) it is checked if intra frequency measurements A2, A3, A5 and additional A2 for release 
  have values defined in Measurement Profile (NRMEASPR_IAF-1) configuration.
  NRMEASPR_IAF-1 can be found in BTS configuration under MRBTS-XYZ/NRBTS-XYZ/NRMEAS_PROFILE-1

#### Pass Criteria
* Step 1: Wireshark logs are started successfully and UE is in defined cell.
* Step 2: No error during stopping and coping wireshark logs.
* Step 3: The number of packet for both defined filters is above 0.

#### Automatic TC steps
* Step 1: Start Wireshark Log And Attach UE
  Description:
  Wireshark is started and after it UE attach is launched. Used NR cell is verified from NAA application.
* Step 2: Stop Wireshark Logs
  Description: After attach wireshark log is stopped.
* Step 3: Tcpdump Verification
  Description:
  Collected tcpdumps are checked by two wireshark filters. 
  By first filtering it is checked if sgNbAdditionRequest is send with SPID and PLMN for which Measurment Profile was defined.
  By second wireshark filtering (variable ${filter1}) it is checked if intra frequency measurements A2, A3, A5 and additional A2 for release 
  have values defined in Measurement Profile (NRMEASPR_IAF-1) configuration.
  NRMEASPR_IAF-1 can be found in BTS configuration under MRBTS-XYZ/NRBTS-XYZ/NRMEAS_PROFILE-1

#### Test case developer notes
* Used IMSI should have defined SPID between 20-256 in core network, if not ticket to SRN is needed.
  Verification is done by packet filtering for X2AP and F1AP protocols.
  First packet filtering is to check if in SgNBAdditionRequest (X2AP protocol) values of SPID and PLMN are
  as those defined in NRMEASPR_MA_NSA-1. This is only precondition for event verification and if this filtering is not passing
  you need to check object NRMEASPR_MA_NSA-1 and what values for SPID and PLMN are defined there.
  Second packet filtering ( variable ${filter1} in test case) is to check if intra frequency measurements A2, A3, A5 and A2 for release
  have values from object NRMEASPR_IAF-1.
  * Example of mapping between filter parameters and SCF parameters for test line Beamskupin:
    * packet_filter=((x2ap.SubscriberProfileIDforRFP==20)&&(e212.mcc==001))&&(e212.mnc==01)
      * Parameters can be found under object MRBTS-55014/NRBTS-55014/NRMEAS_PROFILE-1
        * x2ap.SubscriberProfileIDforRFP==20 -> sdid = 20
      * Parameters can be found under object MRBTS-55014/NRBTS-55014/NRPLMN-1
        * e212.mcc==001  -> mcc = 1 
        * e212.mnc==01   -> mnc = 1
    * Filter 1:((((((((((((((((f1ap.procedureCode == 5)&&(nr-rrc.eventId==2))&&(nr-rrc.hysteresis==6)) &&
    ...  (nr-rrc.timeToTrigger==7))&&(nr-rrc.measTriggerQuantityOffset.rsrp==10)) &&
    ...  (nr-rrc.eventId==4))&&(nr-rrc.measTriggerQuantity.rsrp==60)) &&
    ...  (nr-rrc.measTriggerQuantity.rsrp==65))&&(nr-rrc.hysteresis==10)) &&
    ...  (nr-rrc.timeToTrigger==6))&&(nr-rrc.eventId==1))&&(nr-rrc.measTriggerQuantity.rsrp==67)) &&
    ...  (nr-rrc.hysteresis == 4))&&(nr-rrc.timeToTrigger==11))&&(nr-rrc.hysteresis==2)) &&
    ...  (nr-rrc.timeToTrigger==12))&&(nr-rrc.measTriggerQuantity.rsrp==68)
      * Parameters can be found under object MRBTS-55014/NRBTS-55014/NRMEAS_PROFILE-1/NRMEASPR_IAF-1
        * nr-rrc.hysteresis == 6  -> a3HysteresisSsbRsrp = 3
        * nr-rrc.timeToTrigger == 7 -> a3TimeToTriggerSsbRsrp = ms256
        * nr-rrc.measTriggerQuantityOffset.rsrp == 10  -> a3OffsetSsbRsrp = 10
        * nr-rrc.measTriggerQuantity.rsrp == 60 -> a5Threshold1SsbRsrp = 60
        * nr-rrc.measTriggerQuantity.rsrp == 65 -> a5Threshold2SsbRsrp = 65
		* nr-rrc.hysteresis == 10 -> a5HysteresisSsbRsrp = 5		
        * nr-rrc.timeToTrigger == 6 -> a5TimeToTriggerSsbRsrp = ms160
        * nr-rrc.measTriggerQuantity.rsrp == 67 -> a2ThresholdhoSsbRsrp = 67
        * nr-rrc.hysteresis == 4 -> a2HysteresishoSsbRsrp = 2
        * nr-rrc.timeToTrigger == 11 -> a2TimeToTriggerhoSsbRsrp = ms640	
		* nr-rrc.hysteresis == 2 -> a2HysteresisReleaseSsbRsrp = 1
        * nr-rrc.timeToTrigger == 12 -> a2TimeToTriggerReleaseSsbRsrp = ms1024
        * nr-rrc.nr-rrc.measTriggerQuantity.rsrp == 68 -> a2ThresholdReleaseSsbRsrp = 68

#### History of changes
* 27.02.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1216 - initial creation
* 20.10.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1354 - change of filters to work with Wireshark 4.2
* 24.10.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1355 - added port 29211 to wireshark log collection options to work with CB007208
* 30.05.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1488 - change of filters to work with Wireshark 4.4

### CB008127-F_B5_Successful_configuration_of_intra-freq_A2_A3_A5_using_meas_profiles_upon_setup_VoNR
This case is to verify the functionality of Measurement Profile for VoNR setup.

* Owner: krzysztof.mirecki@nokia.com
* Author: krzysztof.mirecki@nokia.com
* Maintainer: szymon.startek@nokia.com

#### Test scenario defined by owner
* Step 1: Checking Delay And Start Wireshark Log
  Description:
  Preparation for collection counters M55187C00001, M55190C00001 requires to synchronize start of the test case
  to beginning of the PM counter period. For that time in BTS is checked and proper delay calculated. 
  Wireshark is started and and variable ${STARTED_TCPDUMP} is set to true.
* Step 2: Perform VoNR
  Description:
  UE is attached to defined cell and voice call is started.
* Step 3: Stop Wireshark Log
  Description:
  Collecting tcpdumps is stopped and variable ${STARTED_TCPDUMP} is set to false.
* Step 4: Tcpdump Verification
  Description:
  Collected tcpdumps are checked by two wireshark filters. 
  By first filtering it is checked if VoNR was started by verifying NGAP protocol and fields qosFlowIdentifier and NGAP_PDU 
  which has to be 1.
  By second wireshark filtering (variable ${filter1}) it is checked if intra frequency measurements A2
  ( both A2 types for HO and redirection), A3 and A5 have values defined in Measurement Profile (NRMEASPR_IAF-2) configuration.
  NRMEASPR_IAF-2 can be found in BTS configuration under MRBTS-XYZ/NRBTS-XYZ/NRMEAS_PROFILE-1
* Step 5: Collect Counters
  Description:
  To collect value for counters M55187C00001, M55190C00001 we need to wait whole PM measurement period and after that
  values of counters are assigned to variables.
* Step 6: Check Counters Values
  Description:
  M55187C00001 is counting how many attempts of Measurement Profile assignment were for intra frequency configuration.
  M55190C00001 is counting how many attempts of Measurement Profile assignment were for NR SA configuration.
  Expected value for both of them is 1 as in the same PM measurement period we performed one VoNR call.

#### Pass Criteria
* Step 1: Wireshark logs are started successfully and defining of delay to start of PM measurement period was successful.
* Step 2: Commands to perform UE attach and staring a voice call are executed without any errors and 
  UE can find defined cell.
* Step 3: No error during stopping and coping wireshark logs.
* Step 4: The number of packet for all defined filters is above 0.
* Step 5: PM file exists on BTS and counters: M55187C00001, M55190C00001 are available in PM file.
* Step 6: M55187C00001 and M55190C00001 have value 1.

#### Automatic TC steps
* Step 1: Checking Delay And Start Wireshark Log
  Description:
  Preparation for collection counters M55187C00001, M55190C00001 requires to synchronize start of the test case
  to beginning of the PM counter period. For that time in BTS is checked and proper delay calculated. 
  Wireshark is started and and variable ${STARTED_TCPDUMP} is set to true.
* Step 2: Perform VoNR
  Description:
  UE is attached to defined cell and voice call is started.
* Step 3: Stop Wireshark Log
  Description:
  Collecting tcpdumps is stopped and variable ${STARTED_TCPDUMP} is set to false.
* Step 4: Tcpdump Verification
  Description:
  Collected tcpdumps are checked by two wireshark filters. 
  By first filtering it is checked if VoNR was started by verifying NGAP protocol and fields qosFlowIdentifier and NGAP_PDU 
  which has to be 1.
  By second wireshark filtering (variable ${filter1}) it is checked if intra frequency measurements A2
  ( both A2 types for HO and redirection), A3 and A5 have values defined in Measurement Profile (NRMEASPR_IAF-2) configuration.
  NRMEASPR_IAF-2 can be found in BTS configuration under MRBTS-XYZ/NRBTS-XYZ/NRMEAS_PROFILE-1
* Step 5: Collect Counters
  Description:
  To collect value for counters M55187C00001, M55190C00001 we need to wait whole PM measurement period and after that
  values of counters are assigned to variables.
* Step 6: Check Counters Values
  Description:
  M55187C00001 is counting how many attempts of Measurement Profile assignment were for intra frequency configuration.
  M55190C00001 is counting how many attempts of Measurement Profile assignment were for NR SA configuration.
  Expected value for both of them is 1 as in the same PM measurement period we performed one VoNR call.
  
#### Test case developer notes
* Verification is done by packet filtering for NGAP and F1AP protocols.
  First packet filtering is to check in NGAP if VoNR call is setup.
  Second packet filtering ( variable ${filter1} in test case) is to check if intra frequency measurements A2, A3, A5 and A2 for redirection
  have values from object NRMEASPR_IAF-2.
  * Example of mapping between filter parameters and SCF parameters for test line Beamskupin:
    * Filter 1:(((((((((((((((nr-rrc.eventId==1)&&(nr-rrc.hysteresis==9))&&(nr-rrc.timeToTrigger==1)) &&
    ...  (nr-rrc.measTriggerQuantity.rsrp==67))&&(nr-rrc.hysteresis==12))&&(nr-rrc.timeToTrigger==13)) &&
    ...  (nr-rrc.measTriggerQuantity.rsrp==32))&&(nr-rrc.eventId==2))&&(nr-rrc.hysteresis==7)) &&
    ...  (nr-rrc.measTriggerQuantityOffset.rsrp==9))&&(nr-rrc.timeToTrigger==3))&&(nr-rrc.eventId==4)) &&
    ...  (nr-rrc.hysteresis==11))&&(nr-rrc.measTriggerQuantity.rsrp==59))&&(nr-rrc.measTriggerQuantity.rsrp==66)) &&
    ...  (nr-rrc.timeToTrigger==0)
      * Parameters can be found under object MRBTS-55014/NRBTS-55014/NRMEAS_PROFILE-1/NRMEASPR_IAF-2
        * nr-rrc.hysteresis == 7  -> a3HysteresisSsbRsrp = 3.5
        * nr-rrc.timeToTrigger == 3 -> a3TimeToTriggerSsbRsrp = ms120
        * nr-rrc.measTriggerQuantityOffset.rsrp == 9  -> a3OffsetSsbRsrp = 9
        * nr-rrc.measTriggerQuantity.rsrp == 59 -> a5Threshold1SsbRsrp = 59
        * nr-rrc.measTriggerQuantity.rsrp == 66 -> a5Threshold2SsbRsrp = 66
		* nr-rrc.hysteresis == 11 -> a5HysteresisSsbRsrp = 5.5		
        * nr-rrc.timeToTrigger == 0 -> a5TimeToTriggerSsbRsrp = ms0
        * nr-rrc.measTriggerQuantity.rsrp == 67 -> a2ThresholdhoSsbRsrp = 67
        * nr-rrc.hysteresis == 9 -> a2HysteresishoSsbRsrp = 4.5
        * nr-rrc.timeToTrigger == 1 -> a2TimeToTriggerhoSsbRsrp = ms40	
		* nr-rrc.hysteresis == 12 -> a2HysteresisRedirectSsbRsrp = 6
        * nr-rrc.timeToTrigger == 13 -> a2TimeToTriggerRedirectSsbRsrp = ms1280
        * nr-rrc.nr-rrc.measTriggerQuantity.rsrp == 32 -> a2ThresholdRedirectSsbRsrp = 32

#### History of changes
* 14.03.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1228 - initial creation
* 24.10.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1355 - added port 29211 to wireshark log collection options to work with CB007208
* 19.01.2026 - https://jiradc.ext.net.nokia.com/browse/IWK-1743 - Modified ${result.stdout} == 1 to Should Be True  ${result.stdout} > 0
