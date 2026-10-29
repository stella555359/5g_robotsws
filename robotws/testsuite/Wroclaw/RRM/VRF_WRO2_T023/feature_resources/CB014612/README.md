# CB014612: eCPRI UL Scaling change for Habrok
Robot test suite for features CB014612.

## Test line requirements
* RU equipped with proper HW, RF7.1 MAA 7-2e Radios type
* HW used in manual testing: ASIB + ABIQ
* DU and RU are live and operational
* BTS equipped with proper SISO configuration (supported SISO configuration can refer to SISO
  webtool according to RU types)
* eCPRI RP1/SOAP fronthaul link is operational between DU and RU
* CABLINK.iqCompression eCPRI IQ9_E7 is configured for the subcell of 5G cell
* MNL/MNLENT/FEATCADM.actDisableEcpriUlScalingEnh to 'false' to enable the boost
* scs is set to 30kHz
* Configuration cannot contain ABIL or ABILL even if no RMODs are connected to it.

### Required initial BTS state (not to be checked but provided directly from SCF)
* MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1.actDisableEcpriUlScalingEnh is set to false

## Test cases

### CB014612_A_eCPRI_UL_scaling_change_for_RF_71_scs_30kHz
Purpose of this test case is to verify NR gainCorrection of UL scaling for RF7.1 MAA 7-2e Radios.

#### Test specific Preconditions
* MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1.actDisableEcpriUlScalingEnh is set to false

* Owner: krystian.kozlowski@nokia.com
* Author: monika.ceglarek@nokia.com
* Maintainer: monika.ceglarek@nokia.com


#### Test scenario defined by owner
* Step 1:
  * Description: DU starts carrier setup.
  * Expected: OAM gets the lookup table defined in BPF, DU sends UL scaling values to RU
    via RP1/SOAP M-Plane fronthaul interface (parameter gainCorrection of instances of MO
    LowLevelRxLink used to configure PRACH, PUxCH and SRS reception). L1Hi and RU
    take the value to use to handle UL Scaling on eCPRI interface.
* Step 2:
  * Description: Change actDisableEcpriUlScalingEnh to 'true' to disable the boost.
  * Expected: OAM does not get the lookup table defined in BPF. DU shall not get
    "ru.gain.correct.scs.channel" with different channels and different SCSs from BPF
    for MAA RF7.1 Rus.

* Postconditions
  For actDisableEcpriUlScalingEnh set to 'false' the value of gainCorrection is calculated
  using new parameter "ru_gain_correct_scs_channel". For actDisableEcpriUlScalingEnh set to 'true'
  new parameter "ru_gain_correct_scs_channel" is not taken to use.

#### Pass Criteria
* Difference between values of UL gain correction before and after activating the feature is 12 dB.

#### Automatic TC steps

* Preconditions
* Step 1: Deactivate Feature CB014612
* Step 2: Collect Snapshot
* Step 3: Get UL Gain Correction
* Step 4: Activate Feature CB014612
* Step 5: Collect Snapshot
* Step 6: Get UL Gain Correction
* Step 7: Compare UL Gain Correction Values

#### Test case developer notes
* Logs required for parsing are nested inside multiple different types of archives and directories
  inside of snapshot file. Following algorythm was used in snapshot_analysis.py to find the correct files:
  * Path to snapshot is passed by user/test.
  * From snapshot_file_list.txt name of archive with BTS_part in name and the RMOD L1 runtime archive are found
    by searching the file for strings matching regexp:
    * r'^BTS_part\d+\.zip:$'
    * rf'BTS{mrbts_id}_{rmod_sn}_RMOD_L_.+?_l1-runtime\.tar\.gz'
  * The files with required logs are extracted from the archive. The path is found as follows:
    * The archive with BTS_part in name and RMOD L1 runtime one are taken from the previous step.
    * Next there should be only one archive with extension .txz.
    * Then there should be two directories: var and log.
    * Inside log there should be files with .gz extension which will be extracted to path
      given by user (in test this path is: ${LOG_PATH}/misc_logs/step_${index}).
* To trigger required prints to appear in snapshot the feature is toggled.
  It's best to collect snapshot shortly after toggling.
* Feature is activated by changing MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1.actDisableEcpriUlScalingEnh
  to false.
* Snapshots are saved in ${LOG_PATH}/snapshots/snapshot_${timestamp}.zip path.
* Messages from snapshot are filtered with regexp: r'Ul gain correction of.*?is\s*(-?\d+(?:\.\d+)?)\b'.
* Only prints with timestamp which is newer than the one gathered right before recommissioning
  by test are being taken into consideration when looking for r'Ul gain correction of.*?is\s*(-?\d+(?:\.\d+)?)\b'
  matches. Regexp for extracting time from snapshot logs is: r'^(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z)'.
* Time from snapshot logs and current time collected by test are converted to epoch in UTC timezone.
* In case additional debugging is needed inside snapshot_analysis.py there is function
  _conditional_print_for_debugging called for a few prints. They are not added by default
  since the large amount of prints can make opening logs problematic. If needed those prints
  can each be turned on separately by changing value of 'condition' argument for print that
  should be added to True. Due to this it would either require re-running the test or running
  get_ul_gain_correction function (required parameters: snapshot_path, mrbts_id, rmod_sn,
  min_epoch, destination_dir). Example of how to run the function:
  get_ul_gain_correction('/home/ute/Downloads/snapshot.zip', '6104', 'L1232908043', 1768383669,
  '/home/ute/Downloads/extracted_files').
* Value of UL gain correction for activated feature will be higher than for deactivated feature.
  Values are negative, so e.g. for activated feature we will get -16.851500 and for deactivated
  -28.851500. Those values are the same for all prints for of the same RMOD (as long as the feature
  is not changed - activated or deactivated).


#### History of changes
* 21.01.2026 - https://jiradc.ext.net.nokia.com/browse/IWK-1739 - Initial creation
* 06.02.2026 - https://jiradc.ext.net.nokia.com/browse/IWK-1757 - Fixed test to handle also log files
               in the last directory
             - https://jiradc.ext.net.nokia.com/browse/IWK-1759 - Changed order of searching for regexp
               to improve debugging
