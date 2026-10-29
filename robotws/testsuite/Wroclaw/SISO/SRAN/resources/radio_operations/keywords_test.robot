*** Settings ***
Documentation   Robot file with examples and for keywords testing - 1.26

Library    RadioOperations.py  WITH NAME  radio
#Library    taf.transport.ssh  WITH NAME  ssh    # for radio snapshot download from smod to local vm

*** Variables ***
# OTHER TLs
#${RU_SERIAL}           BL2331C62X6
#${CLOUD_SERVER_IP}     10.42.126.50   # cloud 706
#${RU_SERIAL}    L1174815324   #  AHCA 706
#${RU_SERIAL}    1M193703395   #  AHNA 706
#${REMOTE_HOST}  	10.44.178.180

#902 DEV
#${RU_SERIAL}    BL2244D50Y4   #  AHLOB
#${RU_SERIAL}    L1181207093   #  AHEB
#${RU_SERIAL}    L1153711225   #  GAIA FXEE
#${RU_SERIAL}    L9150900121   #  WMP FXJB
#${RU_SERIAL}    AH242307925   #  AWHQN
#${RU_SERIAL}    L1253802751   #  AXEGHA TL8667
#${RU_SERIAL}    L1254103133   #  AXEGHA TL8485
${RU_SERIAL}    L1252002712   #  AXEGHA DEV

${REMOTE_HOST}  10.42.184.148    #TL AXEGHA DEV
#${REMOTE_HOST}  ${NONE}
#${MPLANE_IP}    ${NONE}
#${CLOUD_SERVER_IP}  10.44.169.18  # Monika TL8667
#${CLOUD_SERVER_IP}  10.42.126.59  # Magda TL8485

#*** Test Cases ***
#Testing KW "Get Radio Module Hardware Family"
#    radio.Get Radio Module Hardware Family
#    ...    ru_name=${RU_NAME}

#Testing KW "Get Fail Safe Mode Status"
#    radio.Get Fail Safe Mode Status
#    ...    ru_serial_number=${RU_SERIAL}
##    ...    remote_host=${REMOTE_HOST}
##    ...    cloud_server_ip=${CLOUD_SERVER_IP}
#
#Testing KW "Enable RU Fail Safe Mode"
#    radio.Enable Radio Module Fail Safe Mode
#    ...    ru_serial_number=${RU_SERIAL}
##    ...    remote_host=${REMOTE_HOST}

#Testing KW "Disable RU Fail Safe Mode"
#    radio.Disable Radio Module Fail Safe Mode
#    ...    ru_serial_number=${RU_SERIAL}
##    ...    remote_host=${REMOTE_HOST}
#    ...    radio_reset=False

#Testing KW "Get SFP Info From Radio Module"
#    radio.Get SFP Info From Radio Module
#    ...    ru_serial_number=${RU_SERIAL}
#    ...    sfp_id=1
#    ...    remote_host=${REMOTE_HOST}
#    ...    cloud_server_ip=${CLOUD_SERVER_IP}

#Testing KW "Override CRC32 Hash In Integrity File"
#    ${dict}    Create dictionary  0=da6b0a7d  1=4f32ab04  # 2=9263d7b3xx
#    radio.Override CRC32 Hash In Integrity File
#    ...    ru_serial_number=${RU_SERIAL}
#    ...    new_value=${dict}
#    ...    new_value=929f20e5
#    ...    reset_ru=True
#    ...    remote_host=${REMOTE_HOST}

#Testing KW "Get Decoded Binary File"
#    radio.Get Decoded Binary File
#    ...    ru_serial_number=${RU_SERIAL}
#    ...    filename=gc
##    ...    remote_host=${REMOTE_HOST}
#    ...    cloud_server_ip=${CLOUD_SERVER_IP}

#Testing KW "Get Temperature Offset By Sensor Name"
#    radio.Get Temperature Offset By Sensor Name
#    ...    ru_serial_number=${RU_SERIAL}
#    ...    sensor_name=module:CORE
#    ...    remote_host=${REMOTE_HOST}
#    ...    cloud_server_ip=${CLOUD_SERVER_IP}
#
#Testing KW "Get Sensors Temperature From RF Logs"
#    ${dict}  Radio.Get Sensors Temperature From RF Logs
#    ...    ru_serial_number=${RU_SERIAL}
#    ...    remote_host=${REMOTE_HOST}
#    ...    cloud_server_ip=${CLOUD_SERVER_IP}
#
#Testing KW "Override Values In Binary File"
#    ${dict1}    Create dictionary  Nrpm_fail=29
#     ${dict}    Create dictionary  tcs=${dict1}
#     radio.Override Values In Binary File
#     ...    ru_serial_number=${RU_SERIAL}
#     ...    filename=tcs_parameters
#     ...    values_dict=${dict}
#     ...    code_type=Temporary
#     ...    reset_ru=False
#     ...    remote_host=${REMOTE_HOST}
#     ...    cloud_server_ip=${CLOUD_SERVER_IP}

#Testing KW "Kill Process On Radio Module"
#    radio.Kill Process On Radio Module By Name
#    ...    ru_serial_number=${RU_SERIAL}
#    ...    process_name=start-syscon-with-user
##    ...    remote_host=${REMOTE_HOST}
#    ...    cloud_server_ip=${CLOUD_SERVER_IP}

#Testing KW "Assert Active Fault"
#    radio.Assert Active Fault In Fault History Log File
#    ...  ru_serial_number=${RU_SERIAL}
#    ...  fault_id=1247
##    ...  severity=critical
#    ...  fault_name=EFaultId_CriticalUnitSpecificFileNotFound
#    ...  remote_host=${REMOTE_HOST}

#testing KW "Assert Inactive Fault"
#    radio.Assert Inactive Fault In Fault History Log File
#    ...  ru_serial_number=${RU_SERIAL}
#    ...  fault_id=10004
#    ...  severity=minor
#    ...  fault_name=EFaultId_CriticalUnitSpecificFileNotFound
##    ...  remote_host=${REMOTE_HOST}
#    ...  cloud_server_ip=${CLOUD_SERVER_IP}

#Testing KW "Assert Active Alarm"
#    radio.Assert Active Alarm In Fault History Log File
#    ...  ru_serial_number=${RU_SERIAL}
#    ...  alarm_id=12
#    ...  severity=critical
#    ...  alarm_name=CriticalFileNotFound
##    ...  remote_host=${REMOTE_HOST}
#
#testing KW "Assert Inactive Alarm"
#    radio.Assert Inactive Alarm In Fault History Log File
#    ...  ru_serial_number=${RU_SERIAL}
#    ...  alarm_id=12
#    ...  severity=critical
#    ...  alarm_name=CriticalFileNotFound
##    ...  remote_host=${REMOTE_HOST}
#    ...  cloud_server_ip=${CLOUD_SERVER_IP}
##
#Testing KW "Assert Fault Event"
#    radio.Assert Fault Event In Fault History Log File
#    ...  ru_serial_number=${RU_SERIAL}
#    ...  fault_id=1247
#    ...  severity=critical
#    ...  state=active
#    ...  fault_name=EFaultId_CriticalUnitSpecificFileNotFound
#    ...  remote_host=${REMOTE_HOST}
##    ...  cloud_server_ip=${CLOUD_SERVER_IP}

#Testing KW "Assert Alarm Event"
#    radio.Assert Alarm Event In Fault History Log File
#    ...  ru_serial_number=${RU_SERIAL}
#    ...  alarm_id=12
#    ...  severity=critical
#    ...  state=active
#    ...  alarm_name=CriticalFileNotFound
#    ...  remote_host=${REMOTE_HOST}
#    ...  cloud_server_ip=${CLOUD_SERVER_IP}

#Testing KW "Open Connection To Radio Module"
##    radio.Open Connection To Radio Module  ru_serial_number=${RU_SERIAL}  remote_host=${REMOTE_HOST}
#    radio.Open Connection To Radio Module  ru_serial_number=${RU_SERIAL}  cloud_server_ip=${CLOUD_SERVER_IP}
#    radio.Close SSH Connection

#Testing KW "Send Command and Read Output"
#    radio.Open Connection To Radio Module
#    ...  ru_serial_number=${RU_SERIAL}
##    ...  remote_host=${REMOTE_HOST}
##    ...  cloud_server_ip=${CLOUD_SERVER_IP}
#    radio.Send Command  sudo devmem 0xFC98025C 32 0x0
#    ${output_3}  radio.Read Output  delay=${4}
#    radio.Close SSH Connection

#Testing KW "Send Command and Read Until Regexp"
#    radio.Open Connection To Radio Module
#     ...  ru_serial_number=${RU_SERIAL}
##     ...  remote_host=${REMOTE_HOST}
##     ...  cloud_server_ip=${CLOUD_SERVER_IP}
#    radio.Send Command  command=ls /run/coma/type
#    ${output}  radio.Read Until Regexp
#     ...  regexp=Node1|scorpio|Node0|rfsw
#    radio.Close SSH Connection

#Testing KW "Send Command and Read Until Prompt"
#    radio.Open Connection To Radio Module
#     ...  ru_serial_number=${RU_SERIAL}
#     ...  remote_host=${REMOTE_HOST}
#    radio.Send Command  command=frmonShellClient localhost 2000
#    ${output_2}  radio.Read Until Prompt
#     ...  prompt=$|#
#    radio.Close SSH Connection
#
#Testing KW "Get Carriers Data"
#    ${carriers_data}  radio.Get Carriers Data
#    ...  ru_serial_number=${RU_SERIAL}
#    ...  direction=TX
#    ...  return_antennas=False
    #    ...  cloud_server_ip=${CLOUD_SERVER_IP}

#Testing KW "Get Carriers Power"
#    ${carriers_power}   radio.Get Carriers Power
#    ...  ru_serial_number=${RU_SERIAL}
#    ...  direction=TX    #  TX or RX
#    ...  print_table=True
#    ...  return_antennas=True
    #    ...  cloud_server_ip=${CLOUD_SERVER_IP}
##
#Testing KW "Get TX Pipes Power From DAPD"
#        ${tx_dict}  radio.Get TX Pipes Power From DAPD
#        ...  ru_serial_number=${RU_SERIAL}
#        ...  remote_host=${REMOTE_HOST}
#        ...  print_table=True
#        ...  cloud_server_ip=${CLOUD_SERVER_IP}
#
#Testing KW "Generate Fault"
#    radio.Generate Fault
#    ...  fault_id=1911
#    ...  ru_serial_number=${RU_SERIAL}
##    ...  remote_host=${REMOTE_HOST}
#    ...  cloud_server_ip=${CLOUD_SERVER_IP}

#Testing KW "Recover Fault
#    radio.Recover Fault
#    ...  ru_serial_number=${RU_SERIAL}
#    ...  fault_id=1911
##    ...  remote_host=${REMOTE_HOST}
#    ...  cloud_server_ip=${CLOUD_SERVER_IP}
###
#Testing KW "Get TCS File
#    ${tcs_file}  radio.Get TCS File
#    ...  ru_serial_number=${RU_SERIAL}
#    ...  remote_host=${REMOTE_HOST}
#    ...  cloud_server_ip=${CLOUD_SERVER_IP}

#Testing KW "Send File Via SCP" to SMOD/Container
#    radio.Send File Via SCP
#        ...  ru_serial_number=${RU_SERIAL}
#        ...  direction=to_smod           # classical: to_smod  || cloud: to_container
#        ...  file_path=/ram/fault_history_log_temp.txt
#        ...  destination_directory=/ram
#        ...  remote_host=${REMOTE_HOST}
#        ...  cloud_server_ip=${CLOUD_SERVER_IP}
##
#Testing KW "Send File Via SCP" to RMOD
#    radio.Send File Via SCP
#        ...  ru_serial_number=${RU_SERIAL}
#        ...  direction=to_rmod
#        ...  file_path=/rom/config/FRIps.txt  #  classical: /rom/config/FRIps.txt  || cloud: /tmp/syscom_profile.xml
#        ...  destination_directory=/ram
#        ...  remote_host=${REMOTE_HOST}
        #    ...  cloud_server_ip=${CLOUD_SERVER_IP}
##
#Testing KW "Get IP For All Radio Modules
#    ${ips_dict}  radio.Get IP For All Radio Modules
#    ...  print_table=True
#    ...  remote_host=${REMOTE_HOST}
    #    ...  cloud_server_ip=${CLOUD_SERVER_IP}

#Testing KW "Get AirScale BBMOD Mapping
#    ${bbmod_map_dict}  radio.Get AirScale BBMOD Mapping
#    ...  remote_host=${REMOTE_HOST}
#    ...  print_table=True

#Testing KW "Get Active Software Release From Enb"
#    ${active_soft}  radio.Get Active Software Release From Enb
#    ...  remote_host=${REMOTE_HOST}
#
#Testing KW "Get Passive Software Release From Enb"
#    ${active_soft}  radio.Get Passive Software Release From Enb
#    ...  remote_host=${REMOTE_HOST}

#Testing KW "Collect Radio Module Logs"
#     ${logs_name}  radio.Collect Radio Module Snapshot
#     ...  ru_serial_number=${RU_SERIAL}
#     ...  remote_host=${REMOTE_HOST}
#     ...  coverage=Full
##     ...  cloud_server_ip=${CLOUD_SERVER_IP}
#     Set Suite Variable  ${logs_name}

#Testing KW "Send File Via SCP For Gathering Logs From RU"
#    radio.Send File Via SCP
#    ...  ru_serial_number=${RU_SERIAL}
#    ...  direction=to_smod
#    ...  file_path=/ram/LOGS_Full_L1181207093_060325_1311.zip
#    ...  destination_directory=/ram
#    ...  remote_host=${REMOTE_HOST}
#
##    ...  cloud_server_ip=${CLOUD_SERVER_IP}
#    ssh.connect to  192.168.255.1  username=toor4nsn  password=oZPS0POrRieRtu  alias=master
#    ssh.connect to  fct-4a  username=toor4nsn  password=oZPS0POrRieRtu  proxy=master  alias=secondary
#    ssh.download file  local_path=/home/ute/LOGS_Full_L1181207093_060325_1311.zip
#     ...  remote_path=/ram/LOGS_Full_L1181207093_060325_1311.zip  connection=secondary

#Testing "Compare Radio Module And WebEM Snapshots"
#    radio.Compare Radio Module And WebEM Snapshots
#    ...  ru_serial_number=${RU_SERIAL}
#    ...  webem_snapshot_path=/home/ute/Downloads/Snapshot_MRBTS-1305_Sztosowa 902_SBTS25R2.zip
#    ...  ru_snapshot_path=/home/ute/LOGS_Full_L1181207093_060325_1311.zip

#Testing "Check File In ZIP Archive"
#    radio.Check File In ZIP Archive
#    ...  zip_path=/home/ute/LOGS_BL2244D50Y4_040424_1134.zip
#    ...  regex_pattern=1011_BBOX5

#Testing "Enable Root Account On FHS"
#    radio.Enable Root Account On FHS
#    ...  ru_serial_number=${RU_SERIAL}
#    ...  remote_host=${REMOTE_HOST}

#Testing "Disable Root Account On FHS"
#    radio.Disable Root Account On FHS
#    ...  ru_serial_number=${RU_SERIAL}
#    ...  remote_host=${REMOTE_HOST}

#Testing "Reboot Radio Module And Wait For Ping"
#    radio.Reboot Radio Module And Wait For Ping
#    ...  ru_serial_number=${RU_SERIAL}
#    ...  reconnect_timeout=130
#    ...  ping_down_timeout=70
#    ...  remote_host=${REMOTE_HOST}
#    ...  cloud_server_ip=${CLOUD_SERVER_IP}

#Testing "Remove Radio Module Runtime Configuration
#    radio.Remove Radio Module Runtime Configuration
#    ...  ru_serial_number=${RU_SERIAL}
#    ...  cloud_server_ip=${CLOUD_SERVER_IP}

#Testing "Get Radio Unit Temperature By Sensor"
#    ${temperature}  radio.Get Radio Unit Temperature By Sensor
#    ...  ru_serial_number=${RU_SERIAL}
#    ...  sensor_name=/temp/made1/rf2
#    ...  remote_host=${REMOTE_HOST}
#    ...  cloud_server_ip=${CLOUD_SERVER_IP}

#Testing "Get Radio Unit PSU Measurements"
#    ${psu_measurements}  radio.Get Radio Unit PSU Measurements
#    ...  ru_serial_number=${RU_SERIAL}
#    ...  remote_host=${REMOTE_HOST}
#    ...  cloud_server_ip=${CLOUD_SERVER_IP}
