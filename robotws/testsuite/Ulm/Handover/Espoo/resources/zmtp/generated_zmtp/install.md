
ZMTP cp protobuf dissector
=============================

This script is describe how to use gnb_zmtp_cp.zip on Windows


How to use gnb_zmtp_cp.zip on Windows
---------------------------------
1. download Wireshark LTE&5G : https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=779796371
2. unpack gnb_zmtp_cp.zip to `path\to\gnb_zmtp_cp`
3. copy `path\to\gnb_zmtp_cp\cplane` to Wireshark `global_conf_path\protobuf` or `personal_conf_path\protobuf`
    e.g. Wireshark is installed to `C:\Program Files\Wireshark`, then
    `global_conf_path` is `C:\Program Files\Wireshark\protobuf`
    `personal_conf_path` is `%APPDATA%\Wireshark\protobuf`
4. launch Wireshark with follwoing command
    "c:\Program Files\Wireshark\Wireshark.exe" -X lua_script:"path\to\gnb_zmtp_cp\zmtp.lua" cplane.pcap

Please check the detailed usage here: https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=819076761

