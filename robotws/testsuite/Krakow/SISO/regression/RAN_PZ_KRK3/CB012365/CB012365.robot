*** Settings ***
Documentation
...   Test suite for regression testing of feature CB012365 (CBRS channel bonding of PAL and GAA channels)
...   author: Marek Bodziony
...   contact: marek.bodziony@nokia.com

Resource    ./resources/CB012365_keywords.robot

Force Tags    STATE_SW_UPLOADED    CRT

Suite Setup         Common Suite Setup with TestLine Preparation and Certificates for CBRS
Suite Teardown      Common Suite Teardown

*** Test Cases ***
[1][1.0] CB012365-B1_04_Frequency_Selection_Algorithm_when_final_combined_chBw_is_not_listed_in_supportedChBw
    [Setup]     Run keywords
    ...         Upload SASsim configuration for B1_TC04
    ...         CBRS configuration for B1_TC04
    ...         Common Preconditions With Watching Alarms for CBRS
    ...         Start SASsim
    ...         Update value of parameter 'supportedChBw' to [20MHz, 30MHz, 40MHz, 60MHz, 70MHz] for CBSD
    Enable CBRS and wait for onAir
    Check correct Grant parameters for CBSD cell via GUI    type=MIX  state=Authorized  low_freq=3600   high_freq=3640
    Perform L3 call
    [Teardown]      Run keywords
    ...             Common Postconditions With Watching Alarms
    ...             Disable CBRS
    ...             Set basic CBRS configuration
    ...             Stop SASsim

[1][1.0] CB012365-B1_05_Grant_Procedure_PAL_and_GAA_success
    [Setup]     Run keywords
    ...         Upload SASsim configuration for B1_TC05
    ...         Common Preconditions With Watching Alarms for CBRS
    ...         Start SASsim
    Enable CBRS and wait for onAir
    Download 'SAS_Sim.log' from SASsim
    Check if there's only 1 'grantRequest' message(s) in SAS_Sim.log
    Check if 'grantRequest' message for PAL channels have correct parameters
    ...             cbsdId=Nokia_1000_EB2313R0115.NRsector1
    ...             groupId=NOKIA_groupId_1
    ...             groupType=NOKIA_groupType
    ...             measReport_elements=15
    ...             accepted_maxEirp=8.0
    ...             highFrequency=3630000000
    ...             lowFrequency=3600000000
    Check if 'grantRequest' message for GAA channels have correct parameters
    ...             cbsdId=Nokia_1000_EB2313R0115.NRsector1
    ...             groupId=NOKIA_groupId_1
    ...             groupType=NOKIA_groupType
    ...             measReport_elements=15
    ...             accepted_maxEirp=13
    ...             highFrequency=3640000000
    ...             lowFrequency=3630000000
    Check if there's only 1 'grantResponse' message(s) in SAS_Sim.log
    Check if 'grantResponse' message for PAL channels have correct parameters
    ...             cbsdId=Nokia_1000_EB2313R0115.NRsector1
    ...             grantId=3600000000_3630000000
    ...             channelType=PAL
    ...             responseCode=0
    ...             responseMessage=CBSD request is approved by SAS
    Check if 'grantResponse' message for GAA channels have correct parameters
    ...             cbsdId=Nokia_1000_EB2313R0115.NRsector1
    ...             grantId=3630000000_3640000000
    ...             channelType=GAA
    ...             responseCode=0
    ...             responseMessage=CBSD request is approved by SAS
    Check correct Grant parameters for CBSD cell via GUI    type=MIX  state=Authorized  low_freq=3600  high_freq=3640
    [Teardown]      Run keywords
    ...             Common Postconditions With Watching Alarms
    ...             Disable CBRS
    ...             Stop SASsim

[1][1.0] CB012365-B1_08_Second_Grant_Activity
    [Setup]     Run keywords
    ...         Upload SASsim configuration for B1_TC08
    ...         Common Preconditions With Watching Alarms for CBRS
    ...         Start SASsim
    ...         Change value of parameter 'querySasServerPeriod' to '2' for CBSD via GUI
    Enable CBRS and wait for onAir
    Wait until SAS timer expires and Second Grant will be granted
    ...             second_grant_type=MIX
    ...             second_grant_state=Authorized
    ...             second_grant_low_freq=3550
    ...             second_grant_high_freq=3590
    Download 'SAS_Sim.log' from SASsim
    Check if there's only 2 'spectrumInquiryRequest' message(s) in SAS_Sim.log
    Check if there's only 2 'spectrumInquiryResponse' message(s) in SAS_Sim.log
    Check if there's only 2 'grantRequest' message(s) in SAS_Sim.log
    Check if there's only 2 'grantResponse' message(s) in SAS_Sim.log
    Check if 'grantRequest' message for PAL channels have correct parameters
    ...             cbsdId=Nokia_1000_EB2313R0115.NRsector1
    ...             groupId=NOKIA_groupId_1
    ...             groupType=NOKIA_groupType
    ...             measReport_elements=15
    ...             accepted_maxEirp=13
    ...             highFrequency=3630000000
    ...             lowFrequency=3600000000
    ...             messageNum=${first_msg}
    Check if 'grantRequest' message for GAA channels have correct parameters
    ...             cbsdId=Nokia_1000_EB2313R0115.NRsector1
    ...             groupId=NOKIA_groupId_1
    ...             groupType=NOKIA_groupType
    ...             measReport_elements=15
    ...             accepted_maxEirp=13
    ...             highFrequency=3600000000
    ...             lowFrequency=3590000000
    ...             messageNum=${first_msg}
    Check if 'grantResponse' message for PAL channels have correct parameters
    ...             cbsdId=Nokia_1000_EB2313R0115.NRsector1
    ...             grantId=3600000000_3630000000
    ...             channelType=PAL
    ...             responseCode=0
    ...             responseMessage=CBSD request is approved by SAS
    ...             messageNum=${first_msg}
    Check if 'grantResponse' message for GAA channels have correct parameters
    ...             cbsdId=Nokia_1000_EB2313R0115.NRsector1
    ...             grantId=3590000000_3600000000
    ...             channelType=GAA
    ...             responseCode=0
    ...             responseMessage=CBSD request is approved by SAS
    ...             messageNum=${first_msg}
    Check if 'heartbeatResponse' message for GAA channels received with failure
    ...             cbsdId=Nokia_1000_EB2313R0115.NRsector1
    ...             grantId=3590000000_3600000000
    ...             channelType=GAA
    ...             responseCode=501
    ...             responseMessage=The grant is suspended
    ...             messageNum=${first_msg}
    Check if 'grantRequest' message for PAL channels have correct parameters
    ...             cbsdId=Nokia_1000_EB2313R0115.NRsector1
    ...             groupId=NOKIA_groupId_1
    ...             groupType=NOKIA_groupType
    ...             measReport_elements=15
    ...             accepted_maxEirp=13
    ...             highFrequency=3580000000
    ...             lowFrequency=3550000000
    ...             messageNum=${second_msg}
    Check if 'grantRequest' message for GAA channels have correct parameters
    ...             cbsdId=Nokia_1000_EB2313R0115.NRsector1
    ...             groupId=NOKIA_groupId_1
    ...             groupType=NOKIA_groupType
    ...             measReport_elements=15
    ...             accepted_maxEirp=13
    ...             highFrequency=3590000000
    ...             lowFrequency=3580000000
    ...             messageNum=${second_msg}
    Check if 'grantResponse' message for PAL channels have correct parameters
    ...             cbsdId=Nokia_1000_EB2313R0115.NRsector1
    ...             grantId=3550000000_3580000000
    ...             channelType=PAL
    ...             responseCode=0
    ...             responseMessage=CBSD request is approved by SAS
    ...             messageNum=${second_msg}
    Check if 'grantResponse' message for GAA channels have correct parameters
    ...             cbsdId=Nokia_1000_EB2313R0115.NRsector1
    ...             grantId=3580000000_3590000000
    ...             channelType=GAA
    ...             responseCode=0
    ...             responseMessage=CBSD request is approved by SAS
    ...             messageNum=${second_msg}
    Perform L3 call
    [Teardown]      Run keywords
    ...             Common Postconditions With Watching Alarms
    ...             Disable CBRS
    ...             Change value of parameter 'querySasServerPeriod' to '0' for CBSD via GUI
    ...             Stop SASsim

[1][1.0] CB012365-B1_09_Online_change_of_actPalGaaBond_parameter
    [Setup]     Run keywords
    ...         Upload SASsim configuration for B1_TC09
    ...         Common Preconditions With Watching Alarms for CBRS
    ...         Start SASsim
    ...         Change value of parameter 'actPalGaaBond' to 'false' for CBSD via GUI
    Enable CBRS and wait for onAir
    Change value of parameter 'actPalGaaBond' to 'true' for CBSD via GUI
    Wait for Grant and check correct Grant parameters for CBSD cell via GUI    type=MIX  state=Authorized  low_freq=3600  high_freq=3640
    Perform L3 call
    Change value of parameter 'actPalGaaBond' to 'false' for CBSD via GUI
    Wait for Grant and check correct Grant parameters for CBSD cell via GUI    type=PAL  state=Authorized  low_freq=3600  high_freq=3620
    Perform L3 call     ul_throughput=15M
    [Teardown]      Run keywords
    ...             Common Postconditions With Watching Alarms
    ...             Disable CBRS
    ...             Set basic CBRS configuration
    ...             Stop SASsim

[1][1.0] CB012365-B1_10_Online_change_of_supportedChBw_parameter
    [Setup]     Run keywords
    ...         Upload SASsim configuration for B1_TC10
    ...         Common Preconditions With Watching Alarms for CBRS
    ...         Start SASsim
    Enable CBRS and wait for onAir
    Check correct Grant parameters for CBSD cell via GUI    type=MIX  state=Authorized  low_freq=3600   high_freq=3640
    Update value of parameter 'supportedChBw' to [20MHz] for CBSD
    Wait for Grant and check correct Grant parameters for CBSD cell via GUI    type=MIX  state=Authorized  low_freq=3600    high_freq=3620
    Perform L3 call     ul_throughput=15M
    [Teardown]      Run keywords
    ...             Common Postconditions With Watching Alarms
    ...             Disable CBRS
    ...             Update value of parameter 'supportedChBw' to [10MHz, 20MHz, 30MHz, 40MHz, 50MHz, 60MHz, 70MHz, 80MHz, 90MHz, 100MHz] for CBSD
    ...             Stop SASsim

[1][1.0] CB012365-B2_01_Frequency_Selection_Algorithm_PAL_success_GAA_failure_with_responseCode_400
    [Setup]     Run keywords
    ...         Upload SASsim configuration for B2_TC01
    ...         Common Preconditions With Watching Alarms for CBRS
    ...         Start SASsim
    Enable CBRS and wait for onAir
    Download 'SAS_Sim.log' from SASsim
    Check if there's only 1 'grantRequest' message(s) in SAS_Sim.log
    Check if 'grantRequest' message for PAL channels have correct parameters
    ...             cbsdId=Nokia_1000_EB2313R0115.NRsector1
    ...             groupId=NOKIA_groupId_1
    ...             groupType=NOKIA_groupType
    ...             measReport_elements=15
    ...             accepted_maxEirp=8.0
    ...             highFrequency=3630000000
    ...             lowFrequency=3600000000
    Check if 'grantRequest' message for GAA channels have correct parameters
    ...             cbsdId=Nokia_1000_EB2313R0115.NRsector1
    ...             groupId=NOKIA_groupId_1
    ...             groupType=NOKIA_groupType
    ...             measReport_elements=15
    ...             accepted_maxEirp=13
    ...             highFrequency=3600000000
    ...             lowFrequency=3590000000
    Check if there's only 1 'grantResponse' message(s) in SAS_Sim.log
    Check if 'grantResponse' message for PAL channels have correct parameters
    ...             cbsdId=Nokia_1000_EB2313R0115.NRsector1
    ...             grantId=3600000000_3630000000
    ...             channelType=PAL
    ...             responseCode=0
    ...             responseMessage=CBSD request is approved by SAS
    Check if 'grantResponse' message for GAA channels received with failure
    ...             cbsdId=Nokia_1000_EB2313R0115.NRsector1
    ...             channelType=GAA
    ...             responseCode=400
    ...             responseMessage=Requested operation parameters cause too much interference
    Check correct Grant parameters for CBSD cell via GUI    type=PAL  state=Authorized  low_freq=3600   high_freq=3630
    [Teardown]      Run keywords
    ...             Common Postconditions With Watching Alarms
    ...             Disable CBRS
    ...             Stop SASsim

[1][1.0] CB012365-B2_02_Frequency_Selection_Algorithm_GAA_success_PAL_failure_with_responseCode_400
    [Setup]     Run keywords
    ...         Upload SASsim configuration for B2_TC02
    ...         Common Preconditions With Watching Alarms for CBRS
    ...         Start SASsim
    Enable CBRS and wait for onAir
    Download 'SAS_Sim.log' from SASsim
    Check if there's only 2 'grantRequest' message(s) in SAS_Sim.log
    Check if 'grantRequest' message for PAL channels have correct parameters
    ...             cbsdId=Nokia_1000_EB2313R0115.NRsector1
    ...             groupId=NOKIA_groupId_1
    ...             groupType=NOKIA_groupType
    ...             measReport_elements=15
    ...             accepted_maxEirp=8.0
    ...             highFrequency=3620000000
    ...             lowFrequency=3600000000
    Check if 'grantRequest' message for GAA channels have correct parameters
    ...             cbsdId=Nokia_1000_EB2313R0115.NRsector1
    ...             groupId=NOKIA_groupId_1
    ...             groupType=NOKIA_groupType
    ...             measReport_elements=15
    ...             accepted_maxEirp=13
    ...             highFrequency=3640000000
    ...             lowFrequency=3620000000
    Check if there's only 2 'grantResponse' message(s) in SAS_Sim.log
    Check if 'grantResponse' message for PAL channels received with failure
    ...             cbsdId=Nokia_1000_EB2313R0115.NRsector1
    ...             channelType=PAL
    ...             responseCode=400
    ...             responseMessage=Requested operation parameters cause too much interference
    Check if 'grantResponse' message for GAA channels have correct parameters
    ...             cbsdId=Nokia_1000_EB2313R0115.NRsector1
    ...             grantId=3620000000_3640000000
    ...             channelType=GAA
    ...             responseCode=0
    ...             responseMessage=CBSD request is approved by SAS
    Check if CBSD have relinquish Grant
    ...             cbsdId=Nokia_1000_EB2313R0115.NRsector1
    ...             grantId=3620000000_3640000000
    ...             channelType=GAA
    Check correct Grant parameters for CBSD cell via GUI    type=MIX  state=Authorized  low_freq=3560   high_freq=3580
    [Teardown]      Run keywords
    ...             Common Postconditions With Watching Alarms
    ...             Disable CBRS
    ...             Stop SASsim

[1][1.0] CB012365-B2_05_Grant_Procedure_PAL_success_GAA_failure_with_responseCode_401
    [Setup]     Run keywords
    ...         Upload SASsim configuration for B2_TC05
    ...         CBRS configuration for B2_TC05
    ...         Common Preconditions With Watching Alarms for CBRS
    ...         Start SASsim
    ...         Update value of parameter 'supportedChBw' to [10MHz, 20MHz, 30MHz, 50MHz, 60MHz, 70MHz] for CBSD
    Enable CBRS and wait for onAir
    Download 'SAS_Sim.log' from SASsim
    Check if there's only 2 'grantRequest' message(s) in SAS_Sim.log
    Check if there's only 2 'grantResponse' message(s) in SAS_Sim.log
    Check if 'grantRequest' message for PAL channels have correct parameters
    ...             cbsdId=Nokia_1000_EB2313R0115.NRsector1
    ...             groupId=NOKIA_groupId_1
    ...             groupType=NOKIA_groupType
    ...             measReport_elements=15
    ...             accepted_maxEirp=10
    ...             highFrequency=3640000000
    ...             lowFrequency=3600000000
    ...             messageNum=${first_msg}
    Check if 'grantRequest' message for GAA channels have correct parameters
    ...             cbsdId=Nokia_1000_EB2313R0115.NRsector1
    ...             groupId=NOKIA_groupId_1
    ...             groupType=NOKIA_groupType
    ...             measReport_elements=15
    ...             accepted_maxEirp=10
    ...             highFrequency=3600000000
    ...             lowFrequency=3570000000
    ...             messageNum=${first_msg}
    Check if 'grantResponse' message for PAL channels have correct parameters
    ...             cbsdId=Nokia_1000_EB2313R0115.NRsector1
    ...             grantId=3600000000_3640000000
    ...             channelType=PAL
    ...             responseCode=0
    ...             responseMessage=CBSD request is approved by SAS
    ...             messageNum=${first_msg}
    Check if 'grantResponse' message for GAA channels received with failure
    ...             cbsdId=Nokia_1000_EB2313R0115.NRsector1
    ...             channelType=GAA
    ...             responseCode=401
    ...             responseMessage=Conflict with an existing grant of the same CBSD
    Check if CBSD have relinquish Grant
    ...             cbsdId=Nokia_1000_EB2313R0115.NRsector1
    ...             grantId=3600000000_3640000000
    ...             channelType=PAL
    Check if 'grantRequest' message for PAL channels have correct parameters
    ...             cbsdId=Nokia_1000_EB2313R0115.NRsector1
    ...             groupId=NOKIA_groupId_1
    ...             groupType=NOKIA_groupType
    ...             measReport_elements=15
    ...             accepted_maxEirp=10
    ...             highFrequency=3640000000
    ...             lowFrequency=3600000000
    ...             messageNum=${second_msg}
    Check if 'grantRequest' message for GAA channels have correct parameters
    ...             cbsdId=Nokia_1000_EB2313R0115.NRsector1
    ...             groupId=NOKIA_groupId_1
    ...             groupType=NOKIA_groupType
    ...             measReport_elements=15
    ...             accepted_maxEirp=10
    ...             highFrequency=3600000000
    ...             lowFrequency=3570000000
    ...             messageNum=${second_msg}
    Check if 'grantResponse' message for PAL channels have correct parameters
    ...             cbsdId=Nokia_1000_EB2313R0115.NRsector1
    ...             grantId=3600000000_3640000000
    ...             channelType=PAL
    ...             responseCode=0
    ...             responseMessage=CBSD request is approved by SAS
    ...             messageNum=${second_msg}
    Check if 'grantResponse' message for GAA channels have correct parameters
    ...             cbsdId=Nokia_1000_EB2313R0115.NRsector1
    ...             grantId=3570000000_3600000000
    ...             channelType=GAA
    ...             responseCode=0
    ...             responseMessage=CBSD request is approved by SAS
    ...             messageNum=${second_msg}
    Check correct Grant parameters for CBSD cell via GUI    type=MIX  state=Authorized  low_freq=3570   high_freq=3640
    [Teardown]      Run keywords
    ...             Common Postconditions With Watching Alarms
    ...             Set basic CBRS configuration
    ...             Disable CBRS
    ...             Stop SASsim

[1][1.0] CB012365-B2_07_Grant_Procedure_PAL_and_GAA_failure_with_responseCode_401
    [Setup]     Run keywords
    ...         Upload SASsim configuration for B2_TC07
    ...         CBRS configuration for B2_TC07
    ...         Common Preconditions With Watching Alarms for CBRS
    ...         Start SASsim
    ...         Update value of parameter 'supportedChBw' to [10MHz, 20MHz, 30MHz, 40Mhz, 50MHz, 60MHz] for CBSD
    Enable CBRS and wait for onAir
    Download 'SAS_Sim.log' from SASsim
    Check if there's only 2 'grantRequest' message(s) in SAS_Sim.log
    Check if there's only 2 'grantResponse' message(s) in SAS_Sim.log
    Check if 'grantRequest' message for PAL channels have correct parameters
    ...             cbsdId=Nokia_1000_EB2313R0115.NRsector1
    ...             groupId=NOKIA_groupId_1
    ...             groupType=NOKIA_groupType
    ...             measReport_elements=15
    ...             accepted_maxEirp=10
    ...             highFrequency=3640000000
    ...             lowFrequency=3600000000
    ...             messageNum=${first_msg}
    Check if 'grantRequest' message for GAA channels have correct parameters
    ...             cbsdId=Nokia_1000_EB2313R0115.NRsector1
    ...             groupId=NOKIA_groupId_1
    ...             groupType=NOKIA_groupType
    ...             measReport_elements=15
    ...             accepted_maxEirp=10
    ...             highFrequency=3660000000
    ...             lowFrequency=3640000000
    ...             messageNum=${first_msg}
    Check if 'grantResponse' message for PAL channels received with failure
    ...             cbsdId=Nokia_1000_EB2313R0115.NRsector1
    ...             channelType=PAL
    ...             responseCode=401
    ...             responseMessage=Conflict with an existing grant of the same CBSD
    ...             messageNum=${first_msg}
    Check if 'grantResponse' message for GAA channels received with failure
    ...             cbsdId=Nokia_1000_EB2313R0115.NRsector1
    ...             channelType=GAA
    ...             responseCode=401
    ...             responseMessage=Conflict with an existing grant of the same CBSD
    ...             messageNum=${first_msg}
    Check if 'grantRequest' message for PAL channels have correct parameters
    ...             cbsdId=Nokia_1000_EB2313R0115.NRsector1
    ...             groupId=NOKIA_groupId_1
    ...             groupType=NOKIA_groupType
    ...             measReport_elements=15
    ...             accepted_maxEirp=10
    ...             highFrequency=3580000000
    ...             lowFrequency=3560000000
    ...             messageNum=${second_msg}
    Check if 'grantRequest' message for GAA channels have correct parameters
    ...             cbsdId=Nokia_1000_EB2313R0115.NRsector1
    ...             groupId=NOKIA_groupId_1
    ...             groupType=NOKIA_groupType
    ...             measReport_elements=15
    ...             accepted_maxEirp=10
    ...             highFrequency=3610000000
    ...             lowFrequency=3580000000
    ...             messageNum=${second_msg}
    Check if 'grantResponse' message for PAL channels have correct parameters
    ...             cbsdId=Nokia_1000_EB2313R0115.NRsector1
    ...             grantId=3560000000_3580000000
    ...             channelType=PAL
    ...             responseCode=0
    ...             responseMessage=CBSD request is approved by SAS
    ...             messageNum=${second_msg}
    Check if 'grantResponse' message for GAA channels have correct parameters
    ...             cbsdId=Nokia_1000_EB2313R0115.NRsector1
    ...             grantId=3580000000_3610000000
    ...             channelType=GAA
    ...             responseCode=0
    ...             responseMessage=CBSD request is approved by SAS
    ...             messageNum=${second_msg}
    Check correct Grant parameters for CBSD cell via GUI    type=MIX  state=Authorized  low_freq=3560  high_freq=3610
    [Teardown]      Run keywords
    ...             Common Postconditions With Watching Alarms
    ...             Set basic CBRS configuration
    ...             Disable CBRS
    ...             Stop SASsim
