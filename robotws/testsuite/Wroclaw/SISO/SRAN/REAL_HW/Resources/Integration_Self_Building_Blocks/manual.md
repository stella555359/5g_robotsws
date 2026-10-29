# Integration - Self Building Blocks


## Parameters

Except typical parameters used by suite , there two additional variables needed for SBB.
- __${BTS_ID}__  - you must provide MRBTS ID for tested BTS, modules use in this suite do not utilize multiBTS functionality
- __&{PARAMETERS}__ - it is not mandatory, you can pass all parameters needed by block directly, but if
you use the same set of parameters you can put them in this dictionary and they will be used
automatically for each block.
Example:
```
&{PARAMETERS}=\
  ...  states=\${LNCEL_onair_states}\
  ...  class=LNCEL\
  ...  onair=\${True}\
  ...  timeout=240\
  ...  cell=49902\
  ...  ru_sn=L1154809204\
  ...  device_sn=L1154809204  
```
```
states= you can use template as a parameter, for example:
    ...  states=\${LNCEL_onair_states}\
    ...  states=\${NRCEL_onair_states}\
    ...  states=\${WNCEL_onair_states}\
    ...  states=\${GNCEL_onair_states}\
```
or you can pass parameter directly as they are presented in WebEm, for example:
```
    ...  states=administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled", blockingState=regex"(?i)Unblocked"
```
```
${BTS_ID}=   1411
```

-----------
Test Procedure Description
----------------

1. Get Active Alarms On BTS - 
   - Use `Get Active Alarms On BTS` module to retrieve the current active alarms on the BTS.
   - This module will return a list of active alarms, which can be used for further validation or reporting.
   
2. Check BTS STATE IS OnAir - 
   - Use `Check BTS STATE IS OnAir` module to verify that the BTS is in the OnAir state.
   - This module will check the operational state of the BTS and ensure it is functioning as expected.
   - mandatory parameters:
        - `timeout`: The maximum time to wait for the BTS to be in the OnAir state.
3. Check If All Cells Are OnAir - 
   - Use `Check If All Cells Are OnAir` module to verify that all cells in the BTS are in the OnAir state.
   - This module will check the operational state of each cell and ensure they are functioning as expected.
4. Check If Cell Is In Requested State - 
   - Use `Check If Cell Is In Requested State` module to verify that a specific cell is in the requested state.
   - This module will check the operational state of the specified cell and ensure it matches the expected state.
   - mandatory parameters:
        - `class`: The class of the cell to check (e.g., LNCEL, NRCEL, WNCEL, GNCEL).
        - `cell`: The cell ID to check.
        - `onair`: A boolean indicating whether the cell should be in the OnAir state.
        - `timeout`: The maximum time to wait for the cell to be in the requested state.
        - `states`: The expected states for the cell, which can be passed as a parameter or directly.
```
     ex.
     states=${LNCEL_onair_states}
     states=administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled", blockingState=regex"(?i)Unblocked"
     ready to use states:
${LNCEL_onair_states}=  administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled", blockingState=regex"(?i)Unblocked"
${WNCEL_onair_states}=  operationalState=regex"(?i)Enabled", blockingState=regex"(?i)Unblocked", usageState=regex"(?i)Active"
${NRCEL_onair_states}=  administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled", blockingState=regex"(?i)Unblocked"
${GNCEL_onair_states}=  administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled", blockingState=regex"(?i)Unblocked",
...  usageState=regex"(?i)Active"
```

5. Block Cell - 
   - Use `Block Cell` module to block a specific cell in the BTS.
   - This module will change the operational state of the specified cell to blocked.
   - mandatory parameters:
        - `lte_cell_list`: A list of LTE cells to block, which can be passed as a parameter or directly.
        - `nr_cell_list`: A list of NR cells to block, which can be passed as a parameter or directly.
        - `gnb_cell_list`: A list of GSM cells to block, which can be passed as a parameter or directly.
        - `wncel_list`: A list of WCDMA cells to block, which can be passed as a parameter or directly.
        - `timeout`: The maximum time to wait for the cell to be blocked.
    
6. Unblock Cell - 
   - Use `Unblock Cell` module to unblock a specific cell in the BTS.
   - This module will change the operational state of the specified cell to unblocked.
   - mandatory parameters:
        - `lte_cell_list`: A list of LTE cells to unblock, which can be passed as a parameter or
     directly.
        - `nr_cell_list`: A list of NR cells to unblock, which can be passed as a parameter or directly.
        - `gnb_cell_list`: A list of GSM cells to unblock, which can be passed as a parameter or directly.
        - `wncel_list`: A list of WCDMA cells to unblock, which can be passed as a parameter or directly.
        - `timeout`: The maximum time to wait for the cell to be unblocked.
7. Lock Radio - 
   - Use `Lock Radio` module to lock the radio of the BTS.
   - This module will change the administrative state of the radio to locked.
   - mandatory parameters:
        - `timeout`: The maximum time to wait for the radio to be locked.
        - `ru_sn`: The serial number of the radio unit to lock.
8. Unlock Radio -
   - Use `Unlock Radio` module to unlock the radio of the BTS.
   - This module will change the administrative state of the radio to unlocked.
   - mandatory parameters:
        - `timeout`: The maximum time to wait for the radio to be unlocked.
        - `ru_sn`: The serial number of the radio unit to unlock.
9. BTS Block - 
   - Use `BTS Block` module to block the BTS.
   - This module will change the operational state of the BTS to blocked.
   - mandatory parameters:
        - `timeout`: The maximum time to wait for the BTS to be blocked.
10. BTS Unblock - 
    - Use `BTS Unblock` module to unblock the BTS.
    - This module will change the operational state of the BTS to unblocked.
    - mandatory parameters:
         - `timeout`: The maximum time to wait for the BTS to be unblocked.

11. BTS Reset - 
    - Use `BTS Reset` module to site reset the BTS.
    - This module will reset the BTS
         - `${CONFIGURATION_STARTUP_TIMEOUT}` The maximum time to wait for the BTS to be reset, provided in variables section.
    - optional parameters:
      - `graceful`: A boolean indicating whether the reset should be graceful or not.
     
12. Power Off Unit - 
    - Use `Power Off Unit` module to power off the BTS unit.
    - This module will change the power state of the BTS to off.
    - mandatory parameters:
        - `device_sn`: The serial number of the device to power off.
13. Power On Unit -
    - Use `Power On Unit` module to power on the BTS unit.
    - This module will change the power state of the BTS to on.
    - mandatory parameters:
        - `device_sn`: The serial number of the device to power on.
14. Power Reset Unit - 
    - Use `Power Reset Unit` module to power reset the BTS unit.
    - mandatory parameters:
        - `device_sn`: The serial number of the device to power reset.
        - `time`: The amount of time to wait between on/off procedures.
15. Power Reset BTS - 
    - Use `Power Reset BTS` module to power reset the BTS.
16. Wait Specified Time - 
    - Use `Wait Specified Time` module to wait for a specified amount of time.
    - This module is useful for providing pause in script.
    - mandatory parameters:
        - `time`: The amount of time to wait.
17. Save BTS Snapshot -
    - Use `Save BTS Snapshot` module to save the current snapshot of the BTS.

18. Cell Administrative State Change
    - Use `Cell Administrative State Change` module to change the administrative state of a specific cell.
    - mandatory parameters:
        - `lte_cell_list`: A list of LTE cells to unblock, which can be passed as a parameter or  directly.
        - `nr_cell_list`: A list of NR cells to unblock, which can be passed as a parameter or directly.
        - `gnb_cell_list`: A list of GSM cells to unblock, which can be passed as a parameter or directly.
        - `wncel_list`: A list of WCDMA cells to unblock, which can be passed as a parameter or directly.
        - `value`: The desired administrative state for the cell (e.g., unlocked, locked).

## Test Group Description
Test groups contains more procedures than Test Procedures, they are used to group procedures together and execute them in a specific order. 
Test Procedures contains only one procedure, while Test Groups can contain multiple procedures. This allows for more complex test scenarios and better
organization of test scripts.
This should speed up test script creation when some typical test steps have to be executed.  On  technical level, TG contains the same possibilites
as Test Procedure, so you can use iterations and separate logging directory.
1. Block Unblock Cell TG
    - This test group executes a lock and unlock operations on every provided cells.
        After Lock there is parameter `time` use to wait betewen lock and unlock operations.
    - parameters:
        - `time`: The amount of time to wait between lock and unlock operations.
        - `lte_cell_list`: A list of LTE cells to block and unblock.
        - `nr_cell_list`: A list of NR cells to block and unblock.
        - `gnb_cell_list`: A list of GSM cells to block and unblock.
        - `wncel_list`: A list of WCDMA cells to block and unblock.
        - `timeout`: The maximum time to wait for the cell to be blocked or unblocked.
2. BTS Site Reset TG
    - This test group executes a site reset operation on the BTS. After site reset, it checks the BTS status and performs hardware and cells checks.
    - parameters:
        - `graceful`: A boolean indicating whether the reset should be graceful or not.
        - `${CONFIGURATION_STARTUP_TIMEOUT}`: The maximum time to wait for the BTS to be reset, provided in variables section.
        - `expected_BTS_status`: The expected status of the BTS after the reset operation. Eg: `OnAir`, `Commisioned`, etc.
        - `HW_check`: A boolean indicating whether to perform hardware check after reset.
        - `cells_check`: A boolean indicating whether to check the cells after reset.
        - `timeout`: The maximum time to wait for the BTS to be reset.
