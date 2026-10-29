# Radio Operations 1.26

Welcome to the **Radio Operations** library!  
This powerful tool is designed to establish SSH connections to radios, enabling a wide range of operations with ease.  
Here's a quick overview of what this library can do for you:

## Key Features:
- **Command Sending and Output Reading**: Send commands effortlessly and read the outputs directly.
- **Predefined Keywords**: Utilize a set of predefined keywords to perform specific operations and retrieve results instantly.
- **Fault Generation Module**: Includes a dedicated module for generating faults, including temperature-related ones.
- **File Operations**: Perform various file operations, including handling snapshots, with dedicated keywords.
- **Detailed Logs**: Extensive logs are provided to allow for manual execution of automated operations.
- **Classical and Cloud Connections**: Seamlessly connect to both Classical SRAN and CloudRAN lines.

## Detailed Functionality:

### Classical Line Connections:
1. **Initial Setup**:
    - Optionally connect to a remote virtual machine for a specific TL.
2. **SSH Tunneling**:
    - Establish an SSH tunnel to the local module at address 192.168.255.1.
    - Search for the radio in `FRIps.txt`.
    - If not found, establish an SSH tunnel to the second module and search `FRIps.txt` again.
3. **Command Execution**:
    - Once the connection path is found, invoke a BASH shell and send commands.

### Cloud Line Connections:
1. **Initial Setup**:
    - Provide the address of the Cloud Server IP for SSH tunneling.
2. **SSH Tunneling**:
    - Establish an SSH tunnel to Cloud server.
    - Search for the radio in `FRIps.txt`.
3. **Command Execution**:
    - Invoke a BASH shell and send commands, including switching to a container.

---


**Usage**:  
Just import RadioOperation.py file from the correct location, e.g.:

```
*** Settings ***
Library    RadioOperations.py  WITH NAME  radio
```


### Keywords:

✔️ - Supported  
❌ - Not supported  
➖ - Not applicable (no SSH connection required)  

| Keyword                                                                                               | Classical                               |  Cloud  |  Description  |
|-------------------------------------------------------------------------------------------------------|-----------------------------------------|  ------  |  ------------  | 
| [`Assert Active Fault In Fault History Log File`](#assert-active-fault-in-fault-history-log-file)     | ✔️ | ✔️ |Assert that there is active fault matching given parameters. 
| [`Assert Fault Event In Fault History Log File`](#assert-fault-event-in-fault-history-log-file)       | ✔️ | ✔️ |Assert that there is fault event matching given parameters.            
| [`Assert Inactive Fault In Fault History Log File`](#assert-inactive-fault-in-fault-history-log-file) | ✔️ | ✔️ |Assert that there is inactive fault matching given parameters.     
| [`Assert Active Alarm In Fault History Log File`](#assert-active-alarm-in-fault-history-log-file)     | ✔️ | ✔️ |Assert that there is active alarm matching given parameters. 
| [`Assert Alarm Event In Fault History Log File`](#assert-alarm-event-in-fault-history-log-file)       | ✔️ | ✔️ |Assert that there is alarm event matching given parameters.            
| [`Assert Inactive Alarm In Fault History Log File`](#assert-inactive-alarm-in-fault-history-log-file) | ✔️ | ✔️ |Assert that there is inactive alarm matching given parameters.     
| [`Check File In ZIP Archive`](#check-file-in-zip-archive)                                             | ➖ | ➖ |Check if file exists in ZIP archive                                
| [`Close SSH Connection`](#close-ssh-connection)                                                       | ✔️ | ✔️ | Close connections to SMOD(s) and RMOD                              
| [`Collect Radio Module Snapshot`](#collect-radio-module-snapshot)                                     | ✔️ | ✔️ | Collect radio module snapshot to zip file                          
| [`Compare Radio Module And WebEm Snapshots`](#compare-radio-module-and-webem-snapshots)               | ➖ | ➖ | Check if all radio module snapshot files are in WebEM snapshot     
| [`Disable Radio Module Fail Safe Mode`](#disable-radio-module-fail-safe-mode)                         | ✔️ | ✔️ | Disable fail safe mode on radio module                             
| [`Disable Root Account On FHS`](#disable-root-account-on-fhs)                                         | ✔️ | ✔️ | Disable root account on FHS module                                 
| [`Enable Radio Module Fail Safe Mode`](#enable-radio-module-fail-safe-mode)                           | ✔️ | ✔️ | Enable fail safe mode on radio module                              
| [`Enable Root Account On FHS`](#enable-root-account-on-fhs)                                           | ✔️ | ✔️ | Enable root account on FHS module                                  
| [`Generate Fault`](#generate-fault)                                                                   | ✔️ | ✔️ | Perform operations on radio module to trigger fault                
| [`Get Active Software Release From ENB`](#get-active-software-release-from-enb)                       | ✔️ | ❌ | Return active software build based on TargetDB file.               
| [`Get AirScale BBMOD Mapping`](#get-airscale-bbmod-mapping)                                           | ✔️ | ❌ | Return dictionary with SMOD(s) and BBMODs mapped to it.            
| [`Get Carriers Data`](#get-carriers-data)                                                             | ✔️ | ✔️ | Return dictionary with information about all carriers on radio module. 
| [`Get Carriers Power`](#get-carriers-power)                                                           | ✔️ | ✔️ | Return dictionary with power for all carriers on radio module.     
| [`Get Decoded Binary File`](#get-decoded-binary-file)                                                 | ✔️ | ✔️ | Return decoded binary file from RU frmon as a dictionary           
| [`Get IP For All Radio Modules`](#get-ip-for-all-radio-modules)                                       | ✔️ | ✔️ | Return dictionary with SMOD(s) and RMODs (with IPs) mapped to it.  
| [`Get Fail Safe Mode Status`](#get-fail-safe-mode-status)                                             | ✔️ | ✔️ | Return status of fail safe mode on radio module                    
| [`Get NR Frequency By NRARFCN`](#get-nr-frequency-by-nrarfcn)                                         | ➖ | ➖ | Return frequency calculated based on NRARFCN       
| [`Get Passive Software Release From ENB`](#get-passive-software-release-from-enb)                     | ✔️ | ❌ | Return passive software build based on TargetDB file.                            
| [`Get Radio Module Hardware Family`](#get-radio-module-hardware-family)                               | ➖ | ➖ | Return radio module hardware family, e.g. '6.2'      
| [`Get Radio Unit Temperature By Sensor`](#get-radio-unit-temperature-by-sensor)                       | ✔️ | ✔ | Return temperature of radio unit based on sensor
| [`Get Radio Unit PSU Measurements`](#get-radio-unit-psu-measurements)                                 | ✔️ | ✔️ | Return dictionary with PSU measurements from radio module
| [`Get SFP Info From Radio Module`](#get-sfp-info-from-radio-module)                                   | ✔️ | ✔️ | Return dictionary with SFP information                             
| [`Get TCS File`](#get-tcs-file)                                                                       | ✔️ | ✔️ | Return TCS file from radio module as a dictionary 
| [`Get Temperature Offset By Sensor Name`](#get-temperature-offset-by-sensor-name)                     | ✔️ | ✔️ | Return temperature offset for given RU sensor                 
| [`Get TX Pipes Power From DAPD`](#get-tx-pipes-power-from-dapd)                                       | ✔️ | ✔️ | Return dictionary with power for all antennas based on DAPD        
| [`Kill Process On Radio Module By Name`](#kill-process-on-radio-module-by-name)                       | ✔️ | ✔️ | Kill process based on name                                         
| [`Open Connection To Radio Module`](#open-connection-to-radio-module)                                 | ✔️ | ✔️ | Open SSH connection to radio module                                
| [`Override CRC32 Hash In Integrity File`](#override-crc32-hash-in-integrity-file)                     | ✔️ | ✔️ | Open and replace CRC32 hash value in integrity file                
| [`Override Values In Binary File`](#override-values-in-binary-file)                                   | ✔️ | ✔️ | Open and replace values in decoded binary file                     
| [`Read Output`](#read-output)                                                                         | ✔️ | ✔️ | Return raw output from terminal                                    
| [`Read Until Prompt`](#read-until-prompt)                                                             | ✔️ | ✔️ | Wait until prompt and return output                                
| [`Read Until Regexp`](#read-until-regexp)                                                             | ✔️ | ✔️ | Wait until regexp and return output                                
| [`Reboot Radio Module`](#reboot-radio-module)                                                         | ✔️ | ✔️ | Reboot radio module using command                                  
| [`Reboot Radio Module And Wait For Ping`](#reboot-radio-module-and-wait-for-ping)                     | ✔️ | ✔️ | Reboot radio module and wait for reconnection                      
| [`Recover Fault`](#recover-fault)                                                                     | ✔️ | ✔️ | Perform fault recovery actions on radio module                     
| [`Remove Radio Module Runtime Config`](#remove-radio-module-runtime-config)                           | ✔️ | ✔️ | Remove runtime config from radio module                            
| [`Send Command`](#send-command)                                                                       | ✔️ | ✔️ | Send command using opened SSH channel                              
| [`Send File Via SCP`](#send-file-via-scp)                                                             | ✔️ | ✔️ | Send file using secury copy utility                                

## `Assert Active Fault In Fault History Log File`

Assertion to fault_history_log.txt on radio module.  
Keyword passes if active fault with severity and fault name was found in file.  
Open and close connection to radio module is included in keyword.  

> ⚠️  Supported radio modules: all WMP, GAIA and 5.1, 6.1, 6.2, 8 defined in RADIO_MODULES in variables.py

#### `Parameters:`
  
* **ru_serial_number** (string) - Serial number for Radio Module  
* **fault_id** (string) - Fault ID (R&D faultID, not WebEM !)  
* **severity** (string) - severity (minor, major, critical, warning) 
* **fault_name** (string) - Fault name (R&D fault name, not WebEM !) 
* **remote_host** (string) - IP to remote host, **default:** None
* **via_mplane** (string) - MPLANE IP to connect instead of local IP, **default:** None 
* **cloud_server_ip** (string) - Cloud server IP, **default:** None

#### `Return:`

None

## `Assert Inactive Fault In Fault History Log File`

Assertion to fault_history_log.txt on radio module.  
Keyword passes if Inactive fault with severity and fault name was found in file.  
Open and close connection to radio module is included in keyword.  

> ⚠️  Supported radio modules: all WMP, GAIA and 5.1, 6.1, 6.2, 8 defined in RADIO_MODULES in variables.py

#### `Parameters:`
* **ru_serial_number** (string) - Serial number for Radio Module  
* **fault_id** (string) - Fault ID (R&D faultID, not WebEM !)  
* **severity** (string) - severity (minor, major, critical, warning)
* **fault_name** (string) - Fault name (R&D fault name, not WebEM !) 
* **remote_host** (string) - IP to remote host, **default:** None
* **via_mplane** (string) - MPLANE IP to connect instead of local IP, **default:** None
* **cloud_server_ip** (string) - Cloud server IP, **default:** None

#### `Return:`

None

## `Assert Fault Event In Fault History Log File`

Assertion to fault_history_log.txt on radio module.    
Keyword passes if event with fault, state, severity and fault name was found in file.   
Open and close connection to radio module is included in keyword.  

> ⚠️  Supported radio modules: all WMP, GAIA and 5.1, 6.1, 6.2, 8 defined in RADIO_MODULES in variables.py

#### `Parameters:`
* **ru_serial_number** (string) - Serial number for Radio Module
* **fault_id** (string) - Fault ID (R&D faultID, not WebEM !)
* **severity** (string) - severity (minor, major, critical, warning)
* **fault_name** (string) - Fault name (R&D fault name, not WebEM !) 
* **state** (string) - State of fault: active or cleared
* **remote_host** (string) - IP to remote host, **default:** None 
* **via_mplane** (string) - MPLANE IP to connect instead of local IP, **default:** None 
* **cloud_server_ip** (string) - Cloud server IP, **default:** None

#### `Return:`

None

## `Assert Active Alarm In Fault History Log File`

Assertion to fault_history_log.txt on radio module.  
Keyword passes if active alarm with severity and alarm name was found in file.  
Open and close connection to radio module is included in keyword.  

> ⚠️  Supported radio modules: all WMP, GAIA and 5.1, 6.1, 6.2, 8 defined in RADIO_MODULES in variables.py

#### `Parameters:`
  
* **ru_serial_number** (string) - Serial number for Radio Module  
* **fault_id** (string) - Fault ID (R&D faultID, not WebEM !)  
* **severity** (string) - severity (minor, major, critical, warning) 
* **fault_name** (string) - Fault name (R&D fault name, not WebEM !) 
* **remote_host** (string) - IP to remote host, **default:** None
* **via_mplane** (string) - MPLANE IP to connect instead of local IP, **default:** None 
* **cloud_server_ip** (string) - Cloud server IP, **default:** None

#### `Return:`

None

## `Assert Inactive Alarm In Fault History Log File`

Assertion to fault_history_log.txt on radio module.  
Keyword passes if Inactive alarm with severity and alarm name was found in file.  
Open and close connection to radio module is included in keyword.  

> ⚠️  Supported radio modules: all WMP, GAIA and 5.1, 6.1, 6.2, 8 defined in RADIO_MODULES in variables.py

#### `Parameters:`
* **ru_serial_number** (string) - Serial number for Radio Module  
* **alarm_id** (string) - Fault ID (R&D faultID, not WebEM !)  
* **severity** (string) - severity (minor, major, critical, warning)
* **alarm_name** (string) - Fault name (R&D fault name, not WebEM !) 
* **remote_host** (string) - IP to remote host, **default:** None
* **via_mplane** (string) - MPLANE IP to connect instead of local IP, **default:** None
* **cloud_server_ip** (string) - Cloud server IP, **default:** None

#### `Return:`

None

## `Assert Alarm Event In Fault History Log File`

Assertion to fault_history_log.txt on radio module.    
Keyword passes if event with alarm, state, severity and alarm name was found in file.   
Open and close connection to radio module is included in keyword.  

> ⚠️  Supported radio modules: all WMP, GAIA and 5.1, 6.1, 6.2, 8 defined in RADIO_MODULES in variables.py

#### `Parameters:`
* **ru_serial_number** (string) - Serial number for Radio Module
* **alarm_id** (string) - Alarm ID (R&D AlarmID, not WebEM !)
* **severity** (string) - severity (minor, major, critical, warning)
* **alarm_name** (string) - Alarm name (R&D alarm name, not WebEM !) 
* **state** (string) - State of fault: active or cleared
* **remote_host** (string) - IP to remote host, **default:** None 
* **via_mplane** (string) - MPLANE IP to connect instead of local IP, **default:** None 
* **cloud_server_ip** (string) - Cloud server IP, **default:** None

#### `Return:`

None

## `Check File In ZIP Archive`

Check if a file exists within a ZIP archive based on a regular expression pattern.

#### `Parameters:`
* **zip_path** (string) - The path to the ZIP archive. 
* **regex_pattern** (string) - The regex pattern used to match file names within the ZIP archive.  

#### `Return:`

None

## `Close SSH Connection`

Keyword for close radio module connection with all SSH tunnels.

#### `Return:`

None

## `Collect Radio Module Snapshot`

Keyword for getting snapshot logs on radio module using command: log -a -z XXX.zip
Collected snapshot is saved in /ram directory on radio module.

> ℹ️ Snapshot file can be transfer to System Module via keyword `Send File Via SCP`

#### `Parameters:`
* **ru_serial_number** (string) - Serial number for Radio Module
* **remote_host** (string) - IP to remote host, **default:** None 
* **via_mplane** (string) - MPLANE IP to connect instead of local IP, **default:** None 
* **cloud_server_ip** (string) - Cloud server IP, **default:** None

#### `Return:`

String with name of snapshot file with timestamp

## `Compare Radio Module And WebEm Snapshots`

Keyword for comparing radio module snapshot and WebEM snapshot.  
The keyword is used to compare the content of a snapshot retrieved directly from the radio  
using the command `log -a -z` with the snapshot from WebEM.  
It checks whether all files from the radio snapshot are included in the snapshot_file_list.txt file.  

> ⚠️ WebEM snapshot must be collected in the "Full" version.

#### `Parameters:`
* **ru_serial_number** (string) - Serial number for Radio Module for WebEM snapshot filtering
* **ru_snapshot_path** (string) - ZIP file with radio module logs, **default:** None 
* **webem_snapshot_path** (string) - ZIP file with WebEM snapshot, **default:** None 

#### `Return:`

None

## `Disable Radio Module Fail Safe Mode`

Keyword for disable fail-safe mode on radio module  
Keyword performs radio module reboot

> ⚠️  Supported radio modules: 5.1, 6.1, 6.2 defined in RADIO_MODULES in variables.py

#### `Parameters:`
* **ru_serial_number** (string) - Serial number for Radio Module
* **remote_host** (string) - IP to remote host, **default:** None 
* **via_mplane** (string) - MPLANE IP to connect instead of local IP, **default:** None 
* **cloud_server_ip** (string) - Cloud server IP, **default:** None

#### `Return:`

None

## `Disable Root Account On FHS`

Keyword for disable root (toor4nsn) account on FHS module
Keyword performs FHS reboot

> ⚠️  Keyword works only if **toor4nsn** account is **actived** on FHS  
> ⚠️  Keyword works only for FHS modules defined in RADIO_MODULES dictionary in radio_variables.py

#### `Parameters:`
* **ru_serial_number** (string) - Serial number for Radio Module
* **remote_host** (string) - IP to remote host, **default:** None 
* **via_mplane** (string) - MPLANE IP to connect instead of local IP, **default:** None
* **cloud_server_ip** (string) - Cloud server IP, **default:** None

#### `Return:`

None

## `Enable Radio Module Fail Safe Mode`

Keyword for enable fail-safe mode on radio module.  
Keyword performs radio module reboot.

> ⚠️  Supported radio modules: 5.1, 6.1, 6.2 defined in RADIO_MODULES in variables.py

#### `Parameters:`
* **ru_serial_number** (string) - Serial number for Radio Module
* **remote_host** (string) - IP to remote host, **default:** None 
* **via_mplane** (string) - MPLANE IP to connect instead of local IP, **default:** None 
* **cloud_server_ip** (string) - Cloud server IP, **default:** None

#### `Return:`

None

## `Enable Root Account On FHS`

Keyword for enable root (toor4nsn) account on FHS module
Keyword performs FHS reboot

> ⚠️  Keyword works only if **toor4nsn** account is **deactived** on FHS  
> ⚠️  Keyword works only for FHS modules defined in RADIO_MODULES dictionary in radio_variables.py

#### `Parameters:`
* **ru_serial_number** (string) - Serial number for Radio Module
* **remote_host** (string) - IP to remote host, **default:** None 
* **via_mplane** (string) - MPLANE IP to connect instead of local IP, **default:** None
* **cloud_server_ip** (string) - Cloud server IP, **default:** None

#### `Return:`

None

## `Generate Fault`

> ⚠️  Supported radio modules >= 5.1  
> List of faults and more information -> [Fault Information](#detailed-information-about-faultgenerator) 

Keyword for trigger fault on radio modules 5.1, 6.1(Scorpio), 6.2(Zodiac) and 8  
[List](#supported-faults) of faults possible to trigger is limited.
Some faults can get more arguments, more information below.

#### `Parameters:`
* **ru_serial_number** (string) - Serial number for Radio Module
* **fault_id** (string) - Fault ID (R&D faultID, not WebEM !)
* **remote_host** (string) - IP to remote host, **default:** None 
* **via_mplane** (string) - MPLANE IP to connect instead of local IP, **default:** None 
* **cloud_server_ip** (string) - Cloud server IP, **default:** None
* **\*\*kwargs** - additional arguments:

**For faults 1927** is **mandatory** to pass argument **severity**(string) with values: 
- "Minor" - means that keyword will exceed `T_1dB` threshold defined in TCS.bin
- "Major" - means that keyword will exceed `T_3dB` threshold defined in TCS.bin

**For faults 1936, 1937 and 1938** is possible to pass argument **code_type**(string) with values:  
- "Temporary"(default) - means that FRMON will code binary files until the radio reboot  
- "Permanent" - means that FRMON will code binary files forever -> then keyword `Recovery Fault` is necessary  

**For fault 1911 and 1933** is possible to pass argument **reboot_timeout**(int) - time in secs to wait for RU after reboot

**For fault 1933** is possible to pass argument **fan_early_notif**(string) with values: 
- "True"(default) - means that change will be applied only for FAN object - SCF actDUFanFailureEarlyNotif should be set to True.
- "False" - means that change will be applied for FAN and temperature Offset - SCF actDUFanFailureEarlyNotif should be set to False.

**For fault 1910** is possible to pass argument **autonomous_reset**(boolean) with values:  
- "True"(default) - means that FRMON will change all calibration_dlpath binary files - RU will perform autonomous reset   
- "False" - means that FRMON will change calibration_dlpath1.bin - FID 1910 will be visible with Critical severity without   autonomus reset

**For faults 2928, 2929, 2931, 4698, 4699, 4700, 4701** is mandatory to pass argument **sfp_id**(string) with sfp_id value e.g. 1 or 2   
**For faults 4698, 4699, 4700, 4701** is mandatory to pass argument **severity**(string) with 'minor' or 'major' value

#### `Return:`

None

## `Get Active Software Release From ENB`

Keyword for getting active software release from Enb based on TargetDB file.

#### `Parameters:`
* **full_build_name** (bool) - True if return full SBTS SW name, **default:** False
* **remote_host** (string) - IP to remote host, **default:** None
* **via_mplane** (string) - MPLANE IP to connect instead of local IP, **default:** None

#### `Return:`

String with active software build

## `Get AirScale BBMOD Mapping`

Keyword for getting BBMOD mapping for based on AirScale module.  

#### `Parameters:`
* **remote_host** (string) - IP to remote host, **default:** None  
* **print_table** (bool) - print table with data, **default:** True 
* **via_mplane** (string) - MPLANE IP to connect instead of local IP, **default:** None 

#### `Return:`

Dictionary with:  
Key: AirScale SMOD name and serial number  
Value: list with mapped BBMOD(s)  

## `Get Carriers Data`

Keyword for getting data for all carriers found on radio module.  
  
> ⚠️  Supported radio modules: all WMP, GAIA and 5.1, 6.1, 6.2 defined in ANTENNA_MAPPING in variables.py

#### `Parameters:`
* **ru_serial_number** (string) - Serial number for Radio Module
* **direction** (string) - TX or RX
* **remote_host** (string) - IP to remote host, **default:** None 
* **return_antennas** (bool) - Return dictionary with antenna lines or no (flat dictionary), **default:** True - applicable only for RU >= 5.1  
* **via_mplane** (string) - MPLANE IP to connect instead of local IP, **default:** None
* **cloud_server_ip** (string) - Cloud server IP, **default:** None

#### `Return:`

Nested dictionary with:  
Key: antenna line number  
Value: dictionary with pair: *{ carrier: informations }*

## `Get Carriers Power`

Keyword for getting power for all carriers found on radio module.  
  
> ⚠️  Supported radio modules: all WMP, GAIA and 5.1, 6.1, 6.2 defined in ANTENNA_MAPPING in variables.py

#### `Parameters:`
* **ru_serial_number** (string) - Serial number for Radio Module
* **direction** (string) - TX or RX
* **remote_host** (string) - IP to remote host, **default:** None 
* **print_table** (bool) - print table with power, **default:** True 
* **return_antennas** (bool) - Return dictionary with antenna lines or no (flat dictionary), **default:** True - applicable only for RU >= 5.1
* **via_mplane** (string) - MPLANE IP to connect instead of local IP, **default:** None  
* **cloud_server_ip** (string) - Cloud server IP, **default:** None

#### `Return:`

Nested dictionary with:  
Key: antenna line number  
Value: dictionary with pair: *{ carrier: power }*

## `Get Decoded Binary File`

Keyword for getting decoded binary file from FRMON.  
All binary files possible to decode are in:  
/run/coma/type on radio module
  
> ⚠️  Supported radio modules: 5.1, 6.1, 6.2, 8 defined in RADIO_MODULES in variables.py

#### `Parameters:`
* **ru_serial_number** (string) - Serial number for Radio Module
* **filename** (string) - Name of binary files
* **remote_host** (string) - IP to remote host, **default:** None  
* **via_mplane** (string) - MPLANE IP to connect instead of local IP, **default:** None  
* **cloud_server_ip** (string) - Cloud server IP, **default:** None

#### `Return:`

Decoded binary to json file in as a dictionary 

## `Get IP For All Radio Modules`

Keyword for getting RMOD(s) IP(s) based on FRIps.txt file  

#### `Parameters:`
* **remote_host** (string) - IP to remote host, **default:** None  
* **print_table** (bool) - print table with data, **default:** True 
* **via_mplane** (string) - MPLANE IP to connect instead of local IP, **default:** None 
* **cloud_server_ip** (string) - Cloud server IP, **default:** None

#### `Return:`

Nested dictionary with:  
Key: AirScale SMOD IP  
Value: dictionary with pair: *{ RU serial number: RU IP address }*  

## `Get Fail Safe Mode Status`

Keyword for getting fail-safe mode status on radio module.
  
> ⚠️  Supported radio modules: 5.1, 6.1, 6.2 defined in RADIO_MODULES in variables.py

#### `Parameters:`
* **ru_serial_number** (string) - Serial number for Radio Module
* **filename** (string) - Name of binary files
* **remote_host** (string) - IP to remote host, **default:** None  
* **via_mplane** (string) - MPLANE IP to connect instead of local IP, **default:** None 
* **cloud_server_ip** (string) - Cloud server IP, **default:** None

#### `Return:`

String: "Disabled" or "Enabled"

## `Get NR Frequency By NRARFCN`

Keyword for getting NR frequency based on NRARFCN value.

#### `Parameters:`
* **nrarfcn** (string) - NRARFCN value

#### `Return:`

String with frequency in MHz

## `Get Passive Software Release From ENB`

Keyword for getting passive software release from Enb based on TargetDB file.

#### `Parameters:`
* **full_build_name** (bool) - True if return full SBTS SW name, **default:** False
* **remote_host** (string) - IP to remote host, **default:** None
* **via_mplane** (string) - MPLANE IP to connect instead of local IP, **default:** None

#### `Return:`

String with passive software build

## `Get Radio Module Hardware Family`

Keyword for getting radio module family.

> ⚠️  Supported radio modules: 5.1, 6.1, 6.2, 8 defined in RADIO_MODULES in variables.py

#### `Parameters:`
* **ru_name** (string) - name of radio module, e.g. AHFIG

#### `Return:`

String with radio module HW family, e.g. '6.2'

## `Get Radio Unit Temperature By Sensor`

Keyword for getting temperature of radio unit based on temperature sensor.  

> ⚠️  Supported radio modules: 5.1, 6.1, 6.2 defined in RADIO_MODULES in variables.py  

> ℹ If you don't know possible sensors, use any name in `sensor` argument and check the output in logs.  

#### `Parameters:`
* **ru_serial_number** (string) - Serial number for Radio Module  
* **sensor** (string) - Sensor name, e.g. '/rf/nahka1'  
* **remote_host** (string) - IP to remote host, **default:** None  
* **via_mplane** (string) - MPLANE IP to connect instead of local IP, **default:** None  
* **cloud_server_ip** (string) - Cloud server IP, **default:** None  

#### `Return:`

String with temperature in Celsius (float type)  

## `Get Radio Unit PSU Measurements`

Keyword for getting PSU measurements from radio module.  
Voltage, Current and Power for all PSUs are returned.

> ⚠️  Supported radio modules: 5.1, 6.1, 6.2 defined in RADIO_MODULES in variables.py  

#### `Parameters:`

* **ru_serial_number** (string) - Serial number for Radio Module
* **number_of_measurements**(string) - Number of measurements to get, **default:** 1
* **interval**(string) - Interval between measurements, **default:** 0
* **remote_host** (string) - IP to remote host, **default:** None
* **via_mplane** (string) - MPLANE IP to connect instead of local IP, **default:** None
* **cloud_server_ip** (string) - Cloud server IP, **default:** None

#### `Return:`

List of dictionaries with keys: voltage, current, power.  

## `Get SFP Info From Radio Module`

Keyword for getting information from radio module about SFP.  
Information returned:
- Part number
- Revision number
- Serial number
- Rx status
- Tx status
- Rx power
- Tx power
- Temperature
- Voltage
- Tx Bias
  
> ⚠️  Supported radio modules: 5.1, 6.1, 6.2 defined in RADIO_MODULES in variables.py

#### `Parameters:`
* **ru_serial_number** (string) - Serial number for Radio Module
* **sfp_id** (string) - Sfp Id, e.g. 1 or 2
* **remote_host** (string) - IP to remote host, **default:** None 
* **via_mplane** (string) - MPLANE IP to connect instead of local IP, **default:** None  
* **cloud_server_ip** (string) - Cloud server IP, **default:** None

#### `Return:`

Dictionary with:  
Key: parameter name  
Value: value of the parameter  

## `Get TCS File`

Keyword for getting TCS.bin file from FRMON.  
TCS file contains e.g.:  
- thresholds e.g. Thigh(FID 1936) and Tdanger (1937/8)
- RPM values for fan fault trigger (1932, 1933)
- Intervals to wait for fault trigger (1940) 
  
> ⚠️  Supported radio modules: 5.1, 6.1, 6.2 defined in RADIO_MODULES in variables.py

#### `Parameters:`
* **ru_serial_number** (string) - Serial number for Radio Module
* **remote_host** (string) - IP to remote host, **default:** None  
* **via_mplane** (string) - MPLANE IP to connect instead of local IP, **default:** None
* **cloud_server_ip** (string) - Cloud server IP, **default:** None

#### `Return:`

Dictionary with:  
Key: parameter name  
Value: value of the parameter  

## `Get Temperature Offset By Sensor Name`

Keyword for getting temperature offset based on RU sensor.  
Offset is read from tempest_inst json file.  
  
> ⚠️  Supported radio modules: 5.1, 6.1, 6.2 defined in RADIO_MODULES in variables.py

#### `Parameters:`
* **ru_serial_number** (string) - Serial number for Radio Module
* **sensor_name** (string) - RU sensor name
* **remote_host** (string) - IP to remote host, **default:** None  
* **via_mplane** (string) - MPLANE IP to connect instead of local IP, **default:** None
* **cloud_server_ip** (string) - Cloud server IP, **default:** None

#### `Return:`

Float with offset value  

## `Get TX Pipes Power From DAPD`

Keyword for getting antenna line TX power for all pipes on radio module using DAPD tools.  
  
> ⚠️  Supported radio modules: 5.1, 6.1, 6.2 defined in ANTENNA_MAPPING in variables.py

#### `Parameters:`
* **ru_serial_number** (string) - Serial number for Radio Module
* **remote_host** (string) - IP to remote host, **default:** None 
* **print_table** (bool) - print table with power, **default:** True 
* **via_mplane** (string) - MPLANE IP to connect instead of local IP, **default:** None 
* **cloud_server_ip** (string) - Cloud server IP, **default:** None

#### `Return:`

Dictionary with:  
Key: antenna line  
Value: power in dBm  

## `Kill Process On Radio Module By Name`

Keyword for killing process on radio module.  
Keyword looking for a process ID for the given process name.  
Open and close connection to radio module is included in keyword.
  
> ⚠️  Supported radio modules: 5.1, 6.1, 6.2, 8 defined in RADIO_MODULES in variables.py

#### `Parameters:`
* **ru_serial_number** (string) - Serial number for Radio Module  
* **process_name** (string) - Process name to kill 
* **remote_host** (string) - IP to remote host, **default:** None 
* **via_mplane** (string) - MPLANE IP to connect instead of local IP, **default:** None 
* **cloud_server_ip** (string) - Cloud server IP, **default:** None

#### `Return:`

None

## `Open Connection To Radio Module`

Keyword for opening SSH connection to radio module.  
As long as the connection to the radio is open, commands can be sent.   
  
> ⚠️  Supported radio modules: all WMP, GAIA and 5.1, 6.1, 6.2, 8 defined in RADIO_MODULES in variables.py

#### `Parameters:`
* **ru_serial_number** (string) - Serial number for Radio Module
* **remote_host** (string) - IP to remote host, **default:** None 
* **via_mplane** (string) - MPLANE IP to connect instead of local IP, **default:** None 
* **cloud_server_ip** (string) - Cloud server IP, **default:** None

#### `Return:`

Keyword returns 4 values:
- radio_module_name - e.g. AHFIB
- radio_module_ip - e.g. 172.16.33.128
- system_module_name - e.g. ASIL
- system_module_ip (IPv4 or alias) - e.g. fct-4a

## `Override CRC32 Hash In Integrity File`

Keyword for open and replace CRC32 hash value in active integrity file.
Helpful for generate NOK scenario in CP40 diagnostic check.
Open and close connection to radio module is included in keyword.
  
> ⚠️  Supported radio modules: 5.1, and 6.2 defined in RADIO_MODULES in variables.py  
> ⚠️  Make sure that you backup the integrity file or save the reference values !

#### `Parameters:`
* **ru_serial_number** (string) - Serial number for Radio Module  
* **new_value** (string) - Value to override
* **reset_ru** (bool) - Define if reset RU should be perform after override, **default**: False
* **remote_host** (string) - IP to remote host, **default:** None 
* **via_mplane** (string) - MPLANE IP to connect instead of local IP, **default:** None 
* **cloud_server_ip** (string) - Cloud server IP, **default:** None

#### `Return:`

Overrided value (use to backup !)

## `Override Values In Binary File`

Keyword for open and replace values for existing keys in decoded binary file.   
All binary files possible to decode are in:  
/run/coma/type on radio module
  
> ⚠️  Supported radio modules: 5.1, 6.1, 6.2, 8 defined in RADIO_MODULES in variables.py  
> ⚠️  Make sure that you backup the binary file or save the reference values !

#### `Parameters:`
* **ru_serial_number** (string) - Serial number for Radio Module  
* **filename** (string) - One of binary files 
* **values_dict** (dictionary) - Dictionary contains one or more pair of key:value -> see use case in keywords_test.robot
* **reset_ru** (bool) - Define if reset RU should be perform after override, **default**: False
* **code_type** (string) -Define type of coding binary file, **default**: Permanent
* **remote_host** (string) - IP to remote host, **default:** None 
* **via_mplane** (string) - MPLANE IP to connect instead of local IP, **default:** None 
* **cloud_server_ip** (string) - Cloud server IP, **default:** None

#### `Return:`

None

## `Read Output`

Keyword for reading output from terminal.  
Connection to radio module must be open before use.

#### `Parameters:`
* **delay** (int) - time to wait before output reading, **default**: 0 

#### `Return:`

String with output from terminal

## `Read Until Prompt`

Keyword for reading output from terminal until prompt.  
A few prompts can be pass in format: '$|#|>'    
Connection to radio module must be open before use.  

#### `Parameters:`
* **prompt** (string) - expected prompts
* **timeout** (int) - time to wait for prompts, **default**: 5s 

#### `Return:`

String with output from terminal

## `Read Until Regexp`

Keyword for reading output from terminal until regexp.      
Connection to radio module must be open before use.  

#### `Parameters:`
* **regexp** (string) - expected regexp
* **timeout** (int) - time to wait for prompts, **default**: 5s 

#### `Return:`

String with output from terminal

## `Reboot Radio Module`

> ⚠️  Supported radio modules >= 5.1  

Keyword for rebooting radio module using:**`/sbin/reboot`** or **`sudo systemctl reboot -i`** command
Connection to radio module must be open before use.

#### `Parameters:`

#### `Return:`

None

## `Reboot Radio Module And Wait For Ping`

> ⚠️  Supported radio modules >= 5.1   

Keyword for rebooting radio module using:**`/sbin/reboot`** or **`sudo systemctl reboot -i`** command  
After reboot, keyword waits for the loss and then for the ping to return to the radio.  
Connection to radio module must be open before use.  

#### `Parameters:`
* **ru_serial_number** (string) - Serial number for Radio Module  
* **reconnect_timeout** (string) - Timeout for ping return, **default**: 120
* **ping_down_timeout** (string) - Timeout for ping loss, **default**: 60
* **remote_host** (string) - IP to remote host, **default:** None 
* **via_mplane** (string) - MPLANE IP to connect instead of local IP, **default:** None 
* **cloud_server_ip** (string) - Cloud server IP, **default:** None

#### `Return:`

None

## `Recover Fault`

> ⚠️  Supported radio modules >= 5.1  
> List of faults and more information -> [Fault Information](#detailed-information-about-faultgenerator) 

Keyword for trigger fault recovery actions on radio modules 5.1, 6.1(Scorpio), 6.2(Zodiac), 8
[List](#supported-faults) of faults possible to trigger is limited. 
Some faults can get more arguments, more information below.

#### `Parameters:`
* **ru_serial_number** (string) - Serial number for Radio Module
* **fault_id** (string) - Fault ID (R&D faultID, not WebEM !)
* **remove_runtime_config** (bool) - Additional remove runtime config after recovery procedure (RU reboot will be performed), **default:** False
* **remote_host** (string) - IP to remote host, **default:** None
* **via_mplane** (string) - MPLANE IP to connect instead of local IP, **default:** None 
* **cloud_server_ip** (string) - Cloud server IP, **default:** None

**For faults 1927, 1936, 1937 and 1938** is possible to pass argument **code_type**(string) with values:  
- "Temporary"(default) - means that FRMON will code binary files until the radio reboot  
- "Permanent" - means that FRMON will code binary files forever -> if `Generate Fault` was used with **code_type=Permanent**, `Recover Fault` must be used with **code_type=Permanent** too  

> ℹ️ If `remove_runtime_config` is set to True, `code_type` may be omitted

#### `Return:`

None

## `Remove Radio Module Runtime Config`

> ⚠️  Supported radio modules >= 5.1    

Keyword for removing runtime configuration on radio module.  

#### `Parameters:`
* **ru_serial_number** (string) - Serial number for Radio Module
* **remote_host** (string) - IP to remote host, **default:** None
* **via_mplane** (string) - MPLANE IP to connect instead of local IP, **default:** None 
* **cloud_server_ip** (string) - Cloud server IP, **default:** None

#### `Return:`

None

## `Send Command`

Keyword for sending command on the radio module.  
Delay parameter means time after command sent.  
Connection to radio module must be open before use.  

#### `Parameters:`
* **command** (string) - command to send in terminal
* **delay** (int) - time to wait after command send, **default**: 0

#### `Return:`

None

## `Send File Via SCP`

Keyword for file transferring between radio module and system module or container in case of CloudRAN.  

  
> ⚠️  Supported radio modules: all WMP, GAIA and 5.1, 6.1, 6.2, 8 defined in ANTENNA_MAPPING in variables.py

#### `Parameters:`
* **ru_serial_number** (string) - Serial number for Radio Module
* **direction** (string) - 'to_smod', 'to_container' or 'to_rmod'
* **file_path** (string) - Path to file with filename and extension
* **destination_directory** (string) - Path to directory where file should be put
* **remote_host** (string) - IP to remote host, **default**: None 
* **via_mplane** (string) - MPLANE IP to connect instead of local IP, **default:** None 
* **cloud_server_ip** (string) - Cloud server IP, **default:** None

#### `Return:`

None



## Detailed information about FaultGenerator:


#### Supported faults:

𝐒 - SRAN  
𝐂 - CRAN

\* check supported Radio Modules in variables.py  
\** waiting for official trigger 

| FaultID             | 5.1*            | 6.2*            | 8*           |
|---------------------|-----------------|-----------------|--------------|
| [1901](#fault-1901) | Supported 𝐒    | Supported 𝐒    | Supported 𝐒 |    
| [1907](#fault-1907) | Not Supported   | Supported 𝐒    | Supported 𝐒 |
| [1910](#fault-1910) | Supported 𝐒    | Not Implemented |              |
| [1911](#fault-1911) | Supported 𝐒    | Supported 𝐒    | Supported S    |
| [1920](#fault-1920) | Not Implemented | Supported 𝐒   | Supported 𝐒   |  
| [1927](#fault-1927) | Supported 𝐂/𝐒 | Implementing** |              |
| [1932](#fault-1932) | Supported 𝐒    | Supported 𝐒    |              |
| [1933](#fault-1933) | Supported 𝐒    | Supported 𝐒    | Supported 𝐒    |
| [1936](#fault-1936) | Supported 𝐂/𝐒 | Supported 𝐂/𝐒 |              |
| [1937](#fault-1937) | Supported 𝐂/𝐒 | Supported 𝐂/𝐒 |              |
| [1938](#fault-1938) | Supported 𝐂/𝐒 | Supported 𝐂/𝐒 |              |
| [1940](#fault-1940) | Supported 𝐂/𝐒 | Supported 𝐂/𝐒 |              |
| [1981](#fault-1981) | Supported 𝐒    | Supported 𝐒    |              |
| [2928](#fault-2928) | Supported 𝐒    | Supported 𝐒    | Supported 𝐒  |
| [2929](#fault-2929) | Supported 𝐒    | Supported 𝐒    | Supported 𝐒  |
| [2931](#fault-2931) | Supported 𝐒    | Supported 𝐒    |              |
| [4656](#fault-4656) |                | Supported 𝐒    | Supported 𝐒  |
| [4698](#fault-4698) | Supported 𝐒    | Supported 𝐒    |              |
| [4699](#fault-4699) | Supported 𝐒    | Supported 𝐒    | Supported 𝐒  |
| [6921](#fault-6921) |                | Supported 𝐒    | Supported 𝐒  |
| [4700](#fault-4700) | Supported 𝐒    | Supported 𝐒    | Supported 𝐒  |
| [4701](#fault-4701) | Supported 𝐒    | Supported 𝐒    | Supported 𝐒  |


#### Fault 1901: 
1. Calibration MD5 file is renamed
2. RU Reboot is performed
3. 3 recovery reboots will be visible in WebEM with severity=Warning,
after that FID 1901 with severity=Critical should be visible

#### Fault 1907:
1. Files in FRMON are decoded to JSONS and TEMPORARY modified (dpdmr_dlpath1.bin or gc.bin)
2. No RU reboot is performed, deactivation and activation of carrier via Webem is required
3. Fault 1907 with severity Warning should be visible in WebEM after carrier activation
4. Recovery RU reset is done autonomously
5. Wait 5 min after RU is rebooted
6. Repeat steps 1-5 three more times to get 1907 Critical severity
> Method for triggering 1907 on RU 5.1 is obsolete. Use it only for RU >= 6.2

#### Fault 1910:
1. Files in FRMON are decoded to JSONS and modified (calibration_dlpathX.bin)  
2. The status of radio module remains unchanged  
3. To generate fault 1910 carriers deactivation and activation is required (e.g. lock/unlock RU)  

> ℹ️ If autonomous reset=False -> FID 1910 is cleared with the radio module reboot (calibration_dlpath1.bin changed)  
> ℹ️ If autonomous reset=True -> FID 1910 is cleared with autonomous recovery action (all calibration files changed)

#### Fault 1911:
1. Files in FRMON are decoded to JSONS
2. RU Reboot is performed
3. Waiting for RU to restore connection.
4. Create RfSynthesizer Agent and force unlock.  

> ⚠️ Due to waiting for RU to reconnect, keyword execution may take take up to 3 minutes !
> ℹ️ One use of "Generate Fault" will generate a single fault 1911 with severity Warning, for Critical use 3x "Generate Fault"

> For 6.2 release file rxsupervision.bin is modified. Radio performs 3x autonomous reset (1911 Warning)
> Fourth autonomous reset brings up 1911 Critical

#### Fault 1920: 
1. File gc.bin is modified TEMPORARY
2. No RU reboot is performed, deactivation and activation of carrier via Webem is required
3. 1920 Major Fault visible after radio reset

> Unfortunately during activating 1920 also 1907 is visible

#### Fault 1927:
  
1. Files in FRMON are decoded to JSONS. (tempest_inst1_default.bin (inst5 for AAFIA) and tcs.bin)
2. Temperature of Pipe defined in variables.py is read from RU runtime logs.
3. Offset is calculated based on T_1dB or T_3dB value in tcs.bin
4. Decoded JSON tempest_inst1_default.json is downloaded to SMOD and edited (tempOffset value).
5. Edited JSON tempest_inst1_default.json is sent to RMOD and coded to binary file.
6. Fault is trigger up to 60s, should be visible in fault_history_log.txt
and in WebEM with **Minor** or **Major** severity.

> ⚠️ FID 1927 with Minor severity will be visible in WebEM only if `actPipePowerDecreased1dBFaults` is set to True !   
> ℹ️ Depends on Thigh level in TCS.bin, additionally **FID 1936** may be visible in the same time in WebEM !

#### Fault 1932:
1. Files in FRMON are decoded to JSONS. (tempest_inst1_default.bin (inst5 for AAFIA) and tcs.bin).
2. In tcs.json values: Nrmp_fail is modified and RU reboot is performed.
3. Fault will be trigger after 30s, **if RU FAN power will be turned off**.
4. Fault will be visible **only** in fault_history_log.txt as `EFaultId_FrFanBrokenEarlyNotifAl (1408)` **Critical**
5. Fault will be clear after 30s, **if RU FAN power will be turned on**. 
6. Use keyword `Recover Fault` to restore JSON on RU.

> ℹ️ Hint: To Turn Off PDU use library [`taf.hw.pdu.interface`].

#### Fault 1933:
1. Files in FRMON are decoded to JSONS. (tempest_inst1_default.bin (inst5 for AAFIA) and tcs.bin)
2. In tcs.json values: Nrmp_fail is modified and RU reboot is performed.
3. Temperature of UNIT defined in variables.py is read from RU runtime logs.
4. Offset is calculated based on Tblock value in tcs.bin.
5. Decoded JSON tempest_inst1_default.json is downloaded to SMOD and edited (tempOffset value).
6. Edited JSON tempest_inst1_default.json is sent to RMOD and coded to binary file.
7. Fan setpoint is modified to value: 0
8. Fault is trigger up to 60s, should be visible in fault_history_log.txt and in WebEM.

> ⚠️ With FID 1933 may be visible FID: **1927, 1936, 1938** depends on Tblock value in TCS file 

#### Fault 1936:
1. Files in FRMON are decoded to JSONS. (tempest_inst1_default.bin (inst5 for AAFIA) and tcs.bin)
2. Temperature of Pipe defined in variables.py is read from RU runtime logs.
3. Offset is calculated based on Thigh value in tcs.bin
4. Decoded JSON tempest_inst1_default.json is downloaded to SMOD and edited (tempOffset value).
5. Edited JSON tempest_inst1_default.json is sent to RMOD and coded to binary file.
6. Fault is trigger almost immediately, should be visible in fault_history_log.txt
and in WebEM, if `enableUnitTemperatureHighAlarm` is set to True.

#### Fault 1937:
1. Files in FRMON are decoded to JSONS. (tempest_inst1_default.bin (inst5 for AAFIA) and tcs.bin)
2. Temperature of Unit defined in variables.py is read from RU runtime logs.
3. Offset is calculated based on Tdanger value in tcs.bin
4. Decoded JSON tempest_inst1_default.json is downloaded to SMOD and edited (tempOffset value).
5. Edited JSON tempest_inst1_default.json is sent to RMOD and coded to binary file.
6. Fault is trigger up to 60s, should be visible in fault_history_log.txt
and in WebEM with Critical severity.

#### Fault 1938:
1. Files in FRMON are decoded to JSONS. (tempest_inst1_default.bin and tcs.bin)
2. Temperature of Pipe defined in variables.py is read from RU runtime logs.
3. Offset is calculated based on Tdanger value in tcs.bin
4. Decoded JSON tempest_inst1_default.json is downloaded to SMOD and edited (tempOffset value).
5. Edited JSON tempest_inst1_default.json is sent to RMOD and coded to binary file.
6. Fault is trigger up to 60s, should be visible in fault_history_log.txt as `EFaultId_PipeOverheat (1169)`  
At the beginning, fault will have severity=Major in fault_history_log.txt and in WebEM.  
After interval `Tt+Tdanger` defined in TCS file, fault will have severity=Critical in fault_history_log.txt  
In WebEM it depends on cells configuration per antenna lines, will remain **Major** or will change to **Critical**.  

> ⚠️ With FID 1938 will be visible **FID 1927** with Major severity because T_3dB threshold is always less than Tdanger  

#### Fault 1940:
1. Create access for ThermometerDevice in FRMON defined in variables.py 
2. Override ThermometerDevice with value `FAULTY`
3. Fault will be visible **only** in fault_history_log.txt as `EFaultId_FrTemperatureValueMissing (1171)`  
Filtering time depens on parameter `NT_fail` in TCS file,  
e.g. if `NT_fail`: 5, it means that fault will be visible in 5x60s = 300s

#### Fault 1981:
1. File in FRMON is decoded to JSON. (syscon_node0.bin)
2. Decoded JSON is downloaded to SMOD and edited.
3. RU reboot is performed.
4. Fault is trigger if process with port::0 will be killed.
> ℹ️ Hint: Use keyword [`Kill Process On Radio Module By Name`](#kill-process-on-radio-module-by-name)

> ℹ️ One use of "[`Kill Process On Radio Module By Name`](#kill-process-on-radio-module-by-name)" will generate a single fault 1981 with severity Warning, for Critical use keyword 3 times

#### Fault 2928:
1. Sfp GPIO is overrided with value TX_FAULT true.

#### Fault 2929:
1. Sfp GPIO is overrided with value SIGNAL_LOSS true.

#### Fault 2931:
1. Sfp GPIO is overrided with value SIGNAL_LOSS true.

#### Fault 4656:
1. Files in FRMON are decoded to JSONS and modified 
   (AWHQN localsfp_inst<port_number>.bin or RF8 port_sfp<port_number>.bin depends on sfp_id)
2. RU Reboot is performed
3. FID 4656 with severity=Critical should be visible

#### Fault 4698:
1. Override Sfp temperature byte - 0x60 in memory[^1]

#### Fault 4699:
1. Override Sfp TX bias byte - 0x64 in memory[^1]

#### Fault 6921:
1. Files in FRMON are decoded to JSONS and modified 
   (AWHQN localsfp_inst<port_number>.bin or RF8 port_sfp<port_number>.bin depends on sfp_id)
2. RU Reboot is performed
3. FID 6921 with severity=Critical should be visible

#### Fault 4700:
1. Override Sfp TX power byte - 0x66 in memory[^1]

#### Fault 4701:
1. Override Sfp RX power byte - 0x68 in memory[^1]



### Sources:

[^1]: [Diagnostic Monitoring Interface For Optical Transceivers](https://nokia.sharepoint.com/sites/1830L2Pkt/Shared%20Documents/Forms/AllItems.aspx?id=%2Fsites%2F1830L2Pkt%2FShared%20Documents%2FSFF%2FSFP%2B%2FSFF%2D8472%2Epdf&parent=%2Fsites%2F1830L2Pkt%2FShared%20Documents%2FSFF%2FSFP%2B)  

[6.1 and 6.2 Temperature Sensors And Parameters ](https://nokia.sharepoint.com/:x:/r/sites/Smart_Radio_RD_Irving/ScorpioProgram/_layouts/15/Doc.aspx?sourcedoc=%7BB439F264-9246-4AD6-B563-F5A36E3CD13D%7D&file=Scorpio%205G_Gen5_LF_TDD%20TCS%20Temp%20Sensors%20and%20Parameters.xlsx&action=default&mobileredirect=true&DefaultItemOpen=1&cid=7f2a522d-35ef-40e8-9415-1eca04f21614)  
[6.1 and 6.2 RF Alarm Handling Specification ](https://nokia.sharepoint.com/:w:/r/sites/5GRFPlatform/_layouts/15/Doc.aspx?sourcedoc=%7B46D8BD9C-82A6-44AA-8A7A-667417D2EE30%7D&file=5G%20RF%20Alarm%20Handling%20Specification.docx&action=default&mobileredirect=true&DefaultItemOpen=1&cid=f07a4c63-5f4b-42dd-97da-8751aec31698)  
[5.1 RF Temperature Sensors And Parameters ](https://nokia.sharepoint.com/:x:/r/sites/RF51Platform/_layouts/15/doc2.aspx?sourcedoc=%7B4182FE0E-7AAC-456E-AF04-AC54EDA86321%7D&file=Galaxy-Quasar-Nova-MiRa%20TCS%20Temp%20Sensors%20and%20Parameters.xlsx&action=default&mobileredirect=true)    
[5.1 RF Alarm Handling Specification](https://nokia.sharepoint.com/:w:/r/sites/RF51Platform/_layouts/15/Doc.aspx?sourcedoc=%7B378d2453-1890-41af-83cc-77d1e996e219%7D&action=default&mobileredirect=true)  
