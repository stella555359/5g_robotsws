=============
Luashark Space
https://confluence.int.net.nokia.com/display/Wireshark/LuaShark


Prerequisites
=============

LuaShark is a plugin that requires Wireshark LTE&5G to be installed.

Wireshark LTE&5G can be downloaded from
https://confluence.int.net.nokia.com/pages/viewpage.action?pageId=779796371


Using with commands
===================
more information please refer to https://confluence.int.net.nokia.com/display/Wireshark/Using+Luashark

    $ <path_to_wireshark.exe> -X lua_script:<path_to_luashark.lua> <pcap_file>

    Example under Linux
        $ wireshark-gtk -X lua_script:/tmp/generated_luashark/luashark.lua -r trace.pcap
        $ wireshark -X lua_script:/tmp/generated_luashark/luashark.lua -r trace.pcap

    Example under Windows7
        > "C:\Program Files\Wireshark\Wireshark.exe" -X lua_script:"C:\generated_luashark\luashark.lua" trace.pcap

    Example under Cygwin
        $ ./Wireshark.exe -X lua_script:"C:\generated_luashark\luashark.lua" trace.pcap


    $ <path_to_tshark.exe> -X lua_script:<path_to_luashark.lua> -r <pcap_file> (add option -V if you want to show the detail information of message)

    Example under Linux
        $ tshark -X lua_script:/tmp/generated_luashark/luashark.lua -r trace.pcap

    Example under Windows7
        > "C:\Program Files\Wireshark\Tshark.exe" -X lua_script:"C:\generated_luashark\luashark.lua" -r trace.pcap

    Example under Cygwin
        $ ./Tshark.exe -X lua_script:"C:\generated_luashark\luashark.lua" -r trace.pcap
