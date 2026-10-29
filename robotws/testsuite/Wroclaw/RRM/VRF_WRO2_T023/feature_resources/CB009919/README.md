# CB009919-SR eCPRI based 64TRX LTE TDD massive MIMO frame configuration 1
Robot test suite for feature CB009919-SR.

## Test line requirements
This section is taken from automation requests done by Dawid Kurowski.
Required conditions for all TCs:
eCPRI-based 64T64R RRU (e.g,AEHB) is connected with new baseband unit ABIN/O/ASOE via eCPRI FH. 
CABLINK-radioProtocolType is configured as "eCPRI", eCPRI is activated in the eNB. 
LNCEL_TDD-actMMimo is set to 'true' in the cell. 
TDD configuration SA 1(tddFrameConf = 1) and SSF 7 (tddSpecSubfConf = 7).

### Example configuration
HW required:
ASIL/ASIB/ASIM/ASOE/+ABIN/O + AEHC/AQQL/AQNA/AQQN

### Required initial BTS state (not to be checked but provided directly from SCF)
Any LTE band supported with above mentioned RUs. One TDD cell with Chbw = 20MHz

## Test cases

### RRM__Interaction_with_CRG__CB009919-B
The purpose of this test case is to verify allocation of the subframes where PDSCH/PUSCH are scheduled.

Configure object CRGPR with groupshare = 40% (groupid = 1) and groupshare = 60% (groupid =2).
Add 2 different PLMN group list (compatible with corresponding UEs).

Resource group1 is allocated roughly 40% of the subframes where PDSCH/PUSCH are scheduled,
and with that roughly 40% of the available PRBs. 
Resource group2 is allocated roughly 60% of the subframes where PDSCH/PUSCH are scheduled,
and with that roughly 60% of the available PRBs. 


* Owner: tomasz.stawowczyk@nokia.com
* Author: dawid.kurowski@nokia.com
* Maintainer: tomasz.stawowczyk@nokia.com

#### Configuration and mandatory parameters
LNCEL_TDD-dlMimoMode set to TM8 (dual stream beamforming)
LNCEL_TDD-actTmSwitch set to 'false'.
cellResourceSharingMode = DLandUL
Two resource groups are configured with a resource share of 40%(RG1) and 60%(RG2) (CRGPR object)

Note: 
MME PLMN 1-1 10.42.78.34 (trinity)
MME PLMN 244-08 10.44.201.68 (tatra)

Recommended: 
UE 1: SIM PLMN 1-1
UE 2: SIM PLMN 244-08


#### Test scenario defined by owner
* Step 1: Sending the commission data to eNB for configuration via WebEM
* Step 2: Attach UEs to reconfigured cell
* Step 3: Perform DL max data call on UE1 and UE2
* Step 4: Perform UL max data call on UE1 and UE2

#### Pass Criteria
* Expected1: Cell is onAir without unexpected faults. 
* Expected2: UEs attached to cell.
* Expected3: PDSCH are scheduled 40:60 
* Expected4: PUSCH are scheduled 40:60

Note:
Available PRBs allocated to specific UE/ resource group can be verify in TTI trace or in UE logs.
DL TTI: 
Filter via UEindex and verify if 40/60% of PRBs are available for specific UE


#### Automatic TC steps
* Preconditions
* Step 1: Start Calls
* Step 2: Collect TTI Traces
* Step 3: Verify DL TTI Results
* Step 4: Verify UL TTI Results

#### History of changes
* 05.05.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1036 - Initial creation
* 02.06.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1088 - Adjustment TC to parsing logs from TDD cell
* 11.12.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1170 - TL TMO CRT Test Cases bug fixing
* 19.11.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1363 - removed import of old_common_resources_iwk.robot
* 18.12.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1387 - adjustment of test to the Beamskupin TL
* 05.08.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1521 - Remove the argument ${is_trunk_sw} from Get SW Version and use Get Regexp Matches to verify if the Active Version matches the branch regular expression.

### RRM__Interaction_with_LTE907_TTI_Bundling__CB009919-B
The purpose of this test case is to verify if UE can reach bundling mode and then move back to normal state.

Create one UE with QCI1 bearer in good RF condition,
then change the RF condition from good to bad until the criterias to step into TTIB mode are satisfied.
Keep UE in TTIB mode for a period, then change the RF condition from bad to good again.


* Owner: tomasz.stawowczyk@nokia.com
* Author: dawid.kurowski@nokia.com
* Maintainer: tomasz.stawowczyk@nokia.com

#### Configuration and mandatory parameters
LNCEL parameters:
actTtiBundling = true
ttibOperMode = sinrBasedTtibOnOffAllowed
And tresholds related with current configuration (examples provided for TMO testline)
ttiBundlingSinrThreshold = 100
ttibSinrThresholdOut = 64
ttibSinrThresholdIn = 40
LNBTS parameter:
enforceTtiBundling = true (set for qciTab1)


#### Test scenario defined by owner
* Step 1: Sending the commission data to eNB for configuration via WebEM.
* Enable actTtiBundling and related parameters if needed.
* Step 2: Attach UE to reconfigured cell
* Step 3: Change the RF condition from good to bad until the criterias to step into TTIB mode are satisfied
* Step 4: Change the RF condition from bad to good again.

#### Pass Criteria
* Expected1: eNB successfully configured. 
* Expected2: UE attached to cell.
* Expected3: Verify if bundle size is fixed to additional 4TTIs (TTI trace) 
* Expected4: Verify if bundle size is fixed to normal size (TTI trace)

Note:
Bundling mode can be verified in syslog prints or LTE TTI Traces.
Discussed with FO Dawid Kurowski, that the best and reliable way are LTE TTI Traces.


#### Automatic TC steps
* Preconditions
* Step 1: Start LTE UL Call
* Step 2: Set Attenuation And Check Bundling Mode
* Step 3: Turn Off Attenuation And Check Results

#### History of changes
* 15.05.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1042 - Initial creation
* 11.12.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1170 - TL TMO CRT Test Cases bug fixing
* 19.11.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1363 - removed import of old_common_resources_iwk.robot
* 18.12.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1387 - adjustment of test to the Beamskupin TL
* 21.01.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1400 - added missing argument to Get Current Scf File in Initial Config
* 05.08.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1521 - Remove the argument ${is_trunk_sw} from Get SW Version and use Get Regexp Matches to verify if the Active Version matches the branch regular expression.

### RRM_UL_256QAM_support_with_channel_quality_monitoring_enabled_CB009919-B
The purpose of this test case is to verify if switching between UL 256/64 QAM modulation working as planned in 'channel quality monitoring' feature.

* Owner: michal.hadrysiak@nokia.com
* Author: dawid.kurowski@nokia.com
* Maintainer: michal.hadrysiak@nokia.com


#### Configuration and mandatory parameters
LNCEL parameters:
actMMimo = true
dlMimoMode = dual stream beamforming
actTmSwitch = false
actModulationSchemeUL = 256QAM
actModulationSchemeDL = 256QAM
actUl256QamChQualEst = true
And tresholds related with current configuration (examples provided for TMO testline)
ul256QamDeactChQualThr = 10
ul256QamReactChQualThr = 15


#### Test scenario defined by owner
* Step 1: Setup cell based on prerequisites. Attach UE and start UL data transfer.
* Step 2: Check quality monitoring.
* Step 3: Change RF condition from good to band to switch to 64QAM.
* Step 4: Change RF condition from bad to good to switch to 256QAM.
* Step 5: Check max T-puts on the cell.


#### Pass Criteria
* Expected1: Cell is onAir without unexpected faults. UE attach to cell and UL data is performed.
* Expected2: Verify if UE is in UL 256QAM mode.
* Expected3: Verify if UE is in UL 64QAM mode.
* Expected4: Verify if UE is in UL 256QAM mode.
* Expected5: T-puts should match 77 Mb/s in DL and 39 Mb/s in UL.


#### Automatic TC steps
* Preconditions
* Step 1: Start UL Call.
* Step 2: Check 256QAM Modulation
* Step 3: Reconfigure To non-256QAM Modulation
* Step 4: Reconfigure To 256QAM Modulation
* Step 5: Verify Max T-puts


#### History of changes
* 05.05.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1035 - Initial creation
* 11.12.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1170 - TL TMO CRT Test Cases bug fixing
* 19.11.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1363 - removed import of old_common_resources_iwk.robot
* 18.12.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1387 - adjustment of test to the Beamskupin TL
* 05.08.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1521 - Remove the argument ${is_trunk_sw} from Get SW Version and use Get Regexp Matches to verify if the Active Version matches the branch regular expression.
* 29.01.2026 - https://jiradc.ext.net.nokia.com/browse/IWK-1753 - added additional parameters to TCP "Start Data Transfer" KW
