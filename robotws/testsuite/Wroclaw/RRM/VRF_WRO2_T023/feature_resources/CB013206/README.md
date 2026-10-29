# CB013206 - NR PM COUNTERS OF NSA E-RAB ACTIVE DROP KPI
Robot test suite for feature CB013206.

## Test line requirements
This section is taken from automation requests done by Michal Kowalczyk.
* CloudRAN gNB (preferably #6.1 SKT) with GNSS synchronization and 1x TDD FR1 AVQL RU with n78 band,
* Switched fronthaul connection for CloudRAN (FHGW),
* RINLINE2 RAN NIC,
* vDU,
* vCU,
* FHGW,
* GPS antenna - FYGC
* Airphone

## Test cases

### CB013206_CR_C_RAB_REL_NRM_SGNB_INSES_PMQAP_M55162C00012_counter_check
The purpose of the test case is to check a RAB_REL_NRM_SGNB_INSES_PMQAP/M55162C00012 counter.
M55162C00012 counter measures total number of NR DRBs release initiated by SgNB with normal cause
(without any error reason). Only the ERABs that are released after successful SN status
transfer message is received by gNB from MeNB are considered as release/dropped ERABs.  
Normal ERAB release occurs when an ERAB release is triggered upon:
* sending an X2AP: SGNB RELEASE REQUIRED message from the gNB to the MeNB with the list of UEs
  to be released. This counter counts ERABs that are associated with the UEs to be released
* initiating a release after an SN Status Transfer message is successfully received by the gNB
  for the counted ERAB
* initiating a release due to inactivity or an A2 event

#### Test specific Preconditions
* LTE and NR NSA cells are on air.
* Feature flag actNrpmqapProfiles is activated. The PMQAP profile parameter is activated in the PMQAP MOC.
* NRBTS.NRPMRNL.miNrX2ccNrpmqap is activated.

#### Requirements:
* CFAM CB013206
* 5G_PM_256

* Owner: michal.kowalczyk@nokia.com
* Author: monika.ceglarek@nokia.com, wojciech.peciak@nokia.com
* Maintainer: monika.ceglarek@nokia.com

#### Test scenario defined by owner
* Step 1:
  * Description:  
    Start collecting the logs.
  * Expected:  
    Collection of logs has started successfully.
* Step 2:
  * Description:  
    Perform UE attach to 5G NSA network.
  * Expected:  
    Attach is successful.
* Step 3:
  * Description:  
    Add DRB (DRB9 by default for 5QI9) by starting UDP DL bursty data traffic using
    Iperf server and command:  
    watch -n 0.2 iperf -c 10.X.X.X -u -b 1000M -l 1400 -p 5525 -i 1 -t 0.1 
    (send 1000M of data for 0.1 second and repeat the command every 0.2 second,
    in other words: 100 ms of data then 100 ms of pause and all of this in a loop).
  * Expected:
    DRB setup. UDP DL bursty traffic is being transferred to the receiver (UE).
* Step 4:
  * Description:  
    Attenuate the NR cell to achieve SgNB release (release initiated by SgNB).
  * Expected:  
    SgNB release, bearer deleted successfully due to cell NR attenuation (release initiated by SgNB).
* Step 5:
  * Description:  
    Check PM counter after interval.
  * Expected:  
    Counter RAB_REL_NRM_SGNB_INSES_PMQAP/M55162C00012 is incremented correctly in the target cell by L2Hi CU.
* Step 6:
  * Description:  
    Stop collecting the logs.
  * Expected:  
    Collection of logs has stopped successfully.

#### Pass criteria
* RAB_REL_NRM_SGNB_INSES_PMQAP / M55162C00012 counter is incremented correctly by CP-UE.
* Counter is properly assigned to vDU and/or vCU (accordingly with NIDD and MIND).
* Counter activation flag is properly assigned to vDU and or/vCU (accordingly with NIDD and MIND).

#### Automatic TC steps
* Preconditions
* Step 1: Perform Data Transfer
* Step 2: Perform SgNB Release
* Step 3: Check Tcpdump
* Step 4: Collect And Analyze Counters

#### Test case developer notes
* It appears that there is no need for burst traffic and constant traffic is ok as well.
* In case there is a problem with M55162C00012 counter please check if release was done correctly. 
  There should be SgNBReleaseRequired message with cause radioNetwork (0)
  radioNetwork: action-desirable-for-radio-reasons (31), UEContextReleaseCommand with cause radioNetwork (0)
  radioNetwork: normal-release (10) and BearerContextReleaseComplete message
  with dRB-Released-In-Session: released-in-session (0). In case there is an issue that the last message
  indicates that the release was not done in session try changing X2DataFwdGuard to 10ms.
* Screenshots from wireshark were added to ticket IWK-1320.
* A2 event needs to be configured for this test case in SCF.
* Please remember to have correct symlinks for /opt/iphy/latest and /opt/wts/latest. Version of used
  WTS SW can be found in egate_console.log at the top of the file.
* Please have proper keys generated for vDU ssh (SNO+1) and airphone ssh. They may be generated
  using ssh-keygen command e.g. ssh-keygen -f "/home/ute/.ssh/known_hosts" -R "192.168.200.1"

#### History of changes
* 20.08.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1320 - Initial creation
* 18.11.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1362 - Separating NRBTS and MRBTS
* 24.03.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1434 - Fixed issue with vCU/vDU disconnecting after gathering counters
* 27.10.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1579 - Additional logging of UE configured measurement before triggering one of them.
