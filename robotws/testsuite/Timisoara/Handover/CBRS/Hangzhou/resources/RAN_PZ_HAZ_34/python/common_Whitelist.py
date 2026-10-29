"""
# Version: V1.0
# Date: 26/5/2025
# Description: The common whitelist from the confluence
# https://confluence.ext.net.nokia.com/pages/viewpage.action?
# pageId=1637010227#:~:text=and%20requires%20interpretation-,23,
# -%5E(.*)%20kernel%3A%20%5C%5B%5Cs*(.%2B)%5C%5D%20WARNING
# History:
# 29/5/2025 V1.0:  update date 19/5/2025
"""

import os
import sys

from robot.libraries.BuiltIn import BuiltIn

# sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
# print(os.path.abspath(os.path.join(os.path.dirname(__file__))))

confluence_update_date = '2025-09-22'

Whitelist = [
    {
        "No": 1,
        "Regular_expression": (
            "AaSyslog buffer \\d+ \\(\\w+\\) reached "
            "LoadLevel2 , Info, Warning, Error and "
            "Vip logs will be accepted"
        ),
        "Example": (
            "WRN/CCS(MCU) /AaSysLog, AaSyslog buffer 3 (BTSOM) "
            "reached LoadLevel2 , Info, Warning, Error and "
            "Vip logs will be accepted"
        ),
        "Reason": "Valid prints – appear due to extensive logging"
    },
    {
        "No": 2,
        "Regular_expression": "dhcpd:.*",
        "Example": (
            "ERR/LFS /LinuxSyslog, dhcpd: in your dhcpd.conf file for "
            "the network segment"
        ),
        "Reason": "Pronto agreed as CNN"
    },
    {
        "No": 3,
        "Regular_expression": (
            "AaSyslog buffer \\d+ \\(\\w+\\) reached "
            "LoadLevel3 , Error and Vip logs will "
            "be accepted"
        ),
        "Example": (
            "AaSyslog buffer 3 (BTSOM) reached LoadLevel3 , "
            "Error and Vip logs will be accepted"
        ),
        "Reason": "Valid prints – appear due to extensive logging"
    },
    {
        "No": 4,
        "Regular_expression": (
            "buffer LoadLevel3 : ERR and VIP logs will be accepted"
        ),
        "Example": (
            "WRN/LTEL2 buffer LoadLevel3 : ERR and VIP logs will be "
            "accepted."
        ),
        "Reason": "Valid prints – appear due to extensive logging"
    },
    {
        "No": 5,
        "Regular_expression": (
            "kernel: \\[\\s*\\d+\\.\\d+\\] EXT4-fs "
            "\\(sda\\d\\): warning: maximal mount "
            "count reached, running e2fsck is "
            "recommended"
        ),
        "Example": (
            "WRN/LFS /LinuxSyslog, kernel: [ 5213.392876] "
            "EXT4-fs (sda2): warning: maximal mount count "
            "reached, running e2fsck is recommended"
        ),
        "Reason": "Standard Linux check"
    },
    {
        "No": 6,
        "Regular_expression": "extSrioPortStateControl:.*SFP absent",
        "Example": (
            "WRN/HWA/SRIO, extSrioPortStateControl: board 0x10 "
            "portId 0 sfpId 0x10006, SFP absent"
        ),
        "Reason": (
            "OAM periodically tries to open connection to other SM "
            "if no SRIO SFP present this warning occurs."
        )
    },
    {
        "No": 7,
        "Regular_expression": (
            "rsyslogd: .* try "
            "http://www.rsyslog.com/e/2027"
        ),
        "Example": (
            "rsyslogd: file '8' write error: Read-only file "
            "system [v8.29.0 try http://www.rsyslog.com/e/2027 ]"
        ),
        "Reason": "Valid prints – appear due to RAM access error"
    },
    {
        "No": 8,
        "Regular_expression": (
            "kauditd_printk_skb: \\d+ callbacks suppressed"
        ),
        "Example": (
            "WRN/LFS/LinuxSyslog, kernel: [  494.131408] "
            "kauditd_printk_skb: 14 callbacks suppressed"
        ),
        "Reason": (
            "Acceptable due to dropping of low priority prints "
            "without negative impact on the operation of the "
            "system. If the number of suppressed prints is high, "
            "or if print occurs multiple times it can be a valid "
            "problem."
        )
    },
    {
        "No": 9,
        "Regular_expression": (
            "Please check if cell is already deactivated "
            "in RF but cell is not deleted yet in UL "
            "PHY and MAC PS"
        ),
        "Example": (
            "WRN/TDDPS/FID_UL_MEAS/6544/Please check if cell is "
            "already deactivated in RF but cell is not deleted "
            "yet in UL PHY and MAC PS"
        ),
        "Reason": (
            "Valid prints – appear due to invalid measurements "
            "read by ULPHY. Too expensive to change very legacy "
            "functionality for WRN print only (i.e. ROI is too low)."
        )
    },
    {
        "No": 10,
        "Regular_expression": (
            "WRN/CCS/AaSysCom, Detected looped message "
            "from SysComSocket, probably container is "
            "not up yet. Message dropped Msg header:"
        ),
        "Example": (
            "003556 30.06 09:00:25.878 [192.168.255.129] 56 "
            "ASP-243D-0-CCS 2022-06-30T07:00:25.869099Z "
            "169F-SocketReceiverT WRN/CCS/AaSysCom, Detected "
            "looped message from SysComSocket, probably "
            "container is not up yet. Message dropped Msg "
            "header: id 0x111c, snd 0x243d2058, rcv 0x24390615, "
            "size 20, flags 0x0004/0x0000"
        ),
        "Reason": (
            "Print is conditionally whitelisted during start-up "
            "due to the way communication initiation is handled. "
            "WRN can still be reported as ERR/WRN PR if prints "
            "are continuously visible after start-up or more "
            "than 100 prints with the same id, sender, receiver."
        )
    },
    {
        "No": 11,
        "Regular_expression": (
            "WRN/CCS/AaIPC, sendData\\([0-9]+\\):"
            "FAILED in send errno=.* socketFd=.* "
            "nid=.* cpid=.* dataLenght.* retSend"
        ),
        "Example": (
            "WRN/CCS/AaIPC, sendData(505):FAILED in send "
            "errno=Network is unreachable(101) socketFd=34 "
            "nid=0x2011 cpid=0x4B3 dataLenght=28 retSend=-1"
        ),
        "Reason": (
            "Warning can be visible on message sending when "
            "routing is not ready. WRN can still be reported "
            "as ERR/WRN PR if prints are continuously visible "
            "after start-up or more than 100 prints with the "
            "same id, sender, receiver."
        )
    },
    {
        "No": 12,
        "Regular_expression": (
            "WRN/HWA/SUM, \\[SumLinkRp3\\] LCV error in the header of a "
            "message \\(link: RP3 ., LCV: .*, LCV total: .*\\)"
        ),
        "Example": (
            "WRN/HWA/SUM, [SumLinkRp3] LCV error in the header of a "
            "message (link: RP3 0, LCV: 418499, LCV total: 2147483647)"
        ),
        "Reason": (
            "It is expected behavior to see this print during board reset. "
            "When K2 is resetting, RP3 link between Murkku and K2 drops so "
            "it is expected to see LCV error in Murkku side."
        )
    },
    {
        "No": 13,
        "Regular_expression": (
            "WRN/HWA/SUM, \\[SumLinkRp3\\] 10b8b byte error counter has "
            "hit the threshold count \\(link: RP3 ., LCV: .*, "
            "LCV total: .*\\)"
        ),
        "Example": (
            "WRN/HWA/SUM, [SumLinkRp3] 10b8b byte error counter has hit "
            "the threshold count (link: RP3 0, LCV: 418499, "
            "LCV total: 2147483647)"
        ),
        "Reason": (
            "It is expected behavior to see this print during board reset. "
            "When K2 is resetting, RP3 link between Murkku and K2 drops so "
            "it is expected to see 10b8b byte error in Murkku side."
        )
    },
    {
        "No": 14,
        "Regular_expression": (
            "WRN/LTS/LTS, \\[CorePoolDependencies\\] .* became offline, "
            "but won't cause core pool failure."
        ),
        "Example": (
            "WRN/LTS/LTS, [CorePoolDependencies] /MRBTS-1/RAT-1/MCTRL-4/"
            "BBTOP_M-1/SW_NODE_DEPLOYMENT-1/SW_NODE_SCHEMA-16 became "
            "offline, but won't cause core pool failure."
        ),
        "Reason": (
            "Warning can be visible when SW_NODE_L is offline during "
            "creation of CORE POOLs. Due to the nature of the process, "
            "it is not a disruptive failure for the emitter but an "
            "indication of potential issues during further processing."
        )
    },
    {
        "No": 15,
        "Regular_expression": "^.*ERROR.*after.*ReadyToLock",
        "Example": (
            "[13.280] FATAL ERROR: Set boot script after ReadyToLock!!!"
        ),
        "Reason": "Intel S3 feature unused in our system."
    },
    {
        "No": 16,
        "Regular_expression": (
            "WRN/BStat/PM, \\[CPmLomAgentMgr:\\] \\[sendCounterConfigReq\\] "
            "PmLomAgent::sendConfigReq is not triggered for .*"
        ),
        "Example": (
            "WRN/BStat/PM, [CPmLomAgentMgr:] [sendCounterConfigReq] "
            "PmLomAgent::sendConfigReq is not triggered for 0x2011176f"
        ),
        "Reason": (
            "Warning print can be visible at start-up phase after a "
            "reset/upgrade scenario as a one-time occurrence due to "
            "reset slave – cells synchronization needs to be stabilized."
        )
    },
    {
        "No": 17,
        "Regular_expression": "cgroup: Disabled controller 'freezer'",
        "Example": (
            "kernel: [    2.194568] cgroup: Disabled controller 'freezer'"
        ),
        "Reason": (
            "This is triggered by systemd when it's probing which "
            "controllers can be mounted using cgroup1 interface. Freezer "
            "is used through cgroup2 interface and thus attempt to mount "
            "it leads to error."
        )
    },
    {
        "No": 18,
        "Regular_expression": (
            "WARNING: memory leak will occur if overlay removed, "
            "property: .*"
        ),
        "Example": (
            "kernel: [    7.834659] OF: overlay: WARNING: memory leak "
            "will occur if overlay removed, property: /__symbols__/bmux_int0"
        ),
        "Reason": (
            "Due to some limitations in the DT subsystem, the overlay "
            "subsystem private copy of the overlay FDT will not be freed "
            "after use."
        )
    },
    {
        "No": 19,
        "Regular_expression": (
            "adk_netd: adk_netd_idc_get_eeprom_len:124: Error: "
            "invalid peerdev"
        ),
        "Example": (
            "kernel: [    4.524695] adk_netd: "
            "adk_netd_idc_get_eeprom_len:124: Error: invalid peerdev"
        ),
        "Reason": (
            "Emitted by 3rd party driver provided by Intel, no operational "
            "impact. A ticket for Intel to fix this issue should be opened "
            "when the support contract has been reestablished."
        )
    },
    {
        "No": 20,
        "Regular_expression": "bmuq_regmap.*\\(-6\\)",
        "Example": (
            "[err] kernel: [332105.260178] bmuq_regmap 21-0063: "
            "bmuq_read_reg: interface_version failed (-6)"
        ),
        "Reason": (
            "This is an OK (normal) log when FPGA is reconfigured (upgrade "
            "scenarios). Occurrence of up to 10s time span is accepted. "
            "Otherwise, this log signalises a problem and requires "
            "interpretation."
        )
    },
    {
        "No": 21,
        "Regular_expression": (
            "WRN/CCS/AaSysCom, .* SysComSocket .* Message dropped "
            "Msg header: .*"
        ),
        "Example": (
            "WRN/CCS/AaSysCom, Detected looped message from SysComSocket, "
            "probably container is not up yet. Message dropped Msg header: "
            "id 0x111c, snd 0x243d2058, rcv 0x24390615, size 20, "
            "flags 0x0004/0x0000"
        ),
        "Reason": (
            "Print is conditionally whitelisted during start-up due to the "
            "way communication initiation is handled. WRN can still be "
            "reported as ERR/WRN PR if prints are continuously visible "
            "after start-up or more than 100 prints with the same id, "
            "sender, receiver."
        )
    },
    {
        "No": 22,
        "Regular_expression": (
            "kernel: \\[\\s*\\d+\\.\\d+\\] .*EXT4-fs \\(sda\\d\\): "
            "warning: maximal mount count reached.*"
        ),
        "Example": (
            "kernel: [ 5213.392876] EXT4-fs (sda2): warning: maximal "
            "mount count reached, running e2fsck is recommended"
        ),
        "Reason": "Standard Linux check"
    },
    {
        "No": 23,
        "Regular_expression": (
            "rsyslogd: .* try http://www.rsyslog.com/e/2027"
        ),
        "Example": (
            "rsyslogd: file '8' write error: Read-only file system "
            "[v8.29.0 try http://www.rsyslog.com/e/2027 ]"
        ),
        "Reason": "Valid prints – appear due to RAM access error"
    },
    {
        "No": 24,
        "Regular_expression": (
            "WARNING: memory leak will occur if overlay removed, "
            "property: .*"
        ),
        "Example": (
            "kernel: [    7.834659] OF: overlay: WARNING: memory leak "
            "will occur if overlay removed, property: /__symbols__/bmux_int0"
        ),
        "Reason": (
            "Due to some limitations in the DT subsystem, the overlay "
            "subsystem private copy of the overlay FDT will not be freed "
            "after use."
        )
    },
    {
        "No": 25,
        "Regular_expression": (
            "WRN/HWA/SUM, \\[SumLinkRp3\\] .* byte error counter has hit "
            "the threshold count .*"
        ),
        "Example": (
            "WRN/HWA/SUM, [SumLinkRp3] 10b8b byte error counter has hit "
            "the threshold count (link: RP3 0, LCV: 418499, "
            "LCV total: 2147483647)"
        ),
        "Reason": (
            "It is expected behavior to see this print during board reset. "
            "When K2 is resetting, RP3 link between Murkku and K2 drops so "
            "it is expected to see 10b8b byte error in Murkku side."
        )
    },
    {
        "No": 26,
        "Regular_expression": (
            "WRN/LTS/LTS, \\[CorePoolDependencies\\] .* became offline, "
            "but won't cause core pool failure."
        ),
        "Example": (
            "WRN/LTS/LTS, [CorePoolDependencies] /MRBTS-1/RAT-1/MCTRL-4/"
            "BBTOP_M-1/SW_NODE_DEPLOYMENT-1/SW_NODE_SCHEMA-16 became "
            "offline, but won't cause core pool failure."
        ),
        "Reason": (
            "Warning can be visible when SW_NODE_L is offline during "
            "creation of CORE POOLs. Due to the nature of the process, "
            "it is not a disruptive failure for the emitter but an "
            "indication of potential issues during further processing."
        )
    },
    {
        "No": 27,
        "Regular_expression": (
            "adk_netd: adk_netd_idc_get_eeprom_len:.* Error: "
            "invalid peerdev"
        ),
        "Example": (
            "kernel: [    4.524695] adk_netd: "
            "adk_netd_idc_get_eeprom_len:124: Error: invalid peerdev"
        ),
        "Reason": (
            "Emitted by 3rd party driver provided by Intel, no operational "
            "impact. A ticket for Intel to fix this issue should be opened "
            "when the support contract has been reestablished."
        )
    },
    {
        "No": 28,
        "Regular_expression": (
            "WRN/BStat/PM, \\[CPmLomAgentMgr:\\] .* "
            "PmLomAgent::sendConfigReq is not triggered for .*"
        ),
        "Example": (
            "WRN/BStat/PM, [CPmLomAgentMgr:] [sendCounterConfigReq] "
            "PmLomAgent::sendConfigReq is not triggered for 0x2011176f"
        ),
        "Reason": (
            "Warning print can be visible at start-up phase after a "
            "reset/upgrade scenario as a one-time occurrence due to "
            "reset slave – cells synchronization needs to be stabilized."
        )
    },
    {
        "No": 29,
        "Regular_expression": "cgroup: Disabled controller 'freezer'",
        "Example": (
            "kernel: [    2.194568] cgroup: Disabled controller 'freezer'"
        ),
        "Reason": (
            "This is triggered by systemd when it's probing which "
            "controllers can be mounted using cgroup1 interface. Freezer "
            "is used through cgroup2 interface and thus attempt to mount "
            "it leads to error."
        )
    },
    {
        "No": 30,
        "Regular_expression": (
            "WRN/CCS/AaIPC, sendData\\([0-9]+\\):FAILED in send errno=.* "
            "socketFd=.* nid=.* cpid=.* dataLenght.* retSend"
        ),
        "Example": (
            "WRN/CCS/AaIPC, sendData(505):FAILED in send "
            "errno=Network is unreachable(101) socketFd=34 nid=0x2011 "
            "cpid=0x4B3 dataLenght=28 retSend=-1"
        ),
        "Reason": (
            "Warning can be visible on message sending when routing is not "
            "ready. WRN can still be reported as ERR/WRN PR if prints are "
            "continuously visible after start-up or more than 100 prints "
            "with the same id, sender, receiver."
        )
    },
    {
        "No": 31,
        "Regular_expression": (
            "WRN/HWA/SUM, \\[SumLinkRp3\\] .* byte error counter has hit "
            "the threshold count .*"
        ),
        "Example": (
            "WRN/HWA/SUM, [SumLinkRp3] 10b8b byte error counter has hit "
            "the threshold count (link: RP3 0, LCV: 418499, "
            "LCV total: 2147483647)"
        ),
        "Reason": (
            "It is expected behavior to see this print during board reset. "
            "When K2 is resetting, RP3 link between Murkku and K2 drops so "
            "it is expected to see 10b8b byte error in Murkku side."
        )
    },
    {
        "No": 32,
        "Regular_expression": (
            "WRN/LTS/LTS, \\[CorePoolDependencies\\] .* became offline, "
            "but won't cause core pool failure."
        ),
        "Example": (
            "WRN/LTS/LTS, [CorePoolDependencies] /MRBTS-1/RAT-1/MCTRL-4/"
            "BBTOP_M-1/SW_NODE_DEPLOYMENT-1/SW_NODE_SCHEMA-16 became "
            "offline, but won't cause core pool failure."
        ),
        "Reason": (
            "Warning can be visible when SW_NODE_L is offline during "
            "creation of CORE POOLs. Due to the nature of the process, "
            "it is not a disruptive failure for the emitter but an "
            "indication of potential issues during further processing."
        )
    },
    {
        "No": 33,
        "Regular_expression": (
            "adk_netd: adk_netd_idc_get_eeprom_len:.* Error: "
            "invalid peerdev"
        ),
        "Example": (
            "kernel: [    4.524695] adk_netd: "
            "adk_netd_idc_get_eeprom_len:124: Error: invalid peerdev"
        ),
        "Reason": (
            "Emitted by 3rd party driver provided by Intel, no operational "
            "impact. A ticket for Intel to fix this issue should be opened "
            "when the support contract has been reestablished."
        )
    },
    {
        "No": 34,
        "Regular_expression": (
            "WRN/BStat/PM, \\[CPmLomAgentMgr:\\] .* "
            "PmLomAgent::sendConfigReq is not triggered for .*"
        ),
        "Example": (
            "WRN/BStat/PM, [CPmLomAgentMgr:] [sendCounterConfigReq] "
            "PmLomAgent::sendConfigReq is not triggered for 0x2011176f"
        ),
        "Reason": (
            "Warning print can be visible at start-up phase after a "
            "reset/upgrade scenario as a one-time occurrence due to "
            "reset slave – cells synchronization needs to be stabilized."
        )
    },
    {
        "No": 35,
        "Regular_expression": "cgroup: Disabled controller 'freezer'",
        "Example": (
            "kernel: [    2.194568] cgroup: Disabled controller 'freezer'"
        ),
        "Reason": (
            "This is triggered by systemd when it's probing which "
            "controllers can be mounted using cgroup1 interface. Freezer "
            "is used through cgroup2 interface and thus attempt to mount "
            "it leads to error."
        )
    },
    {
        "No": 36,
        "Regular_expression": (
            "WRN/CCS/AaIPC, sendData\\([0-9]+\\):FAILED in send errno=.* "
            "socketFd=.* nid=.* cpid=.* dataLenght.* retSend"
        ),
        "Example": (
            "WRN/CCS/AaIPC, sendData(505):FAILED in send "
            "errno=Network is unreachable(101) socketFd=34 nid=0x2011 "
            "cpid=0x4B3 dataLenght=28 retSend=-1"
        ),
        "Reason": (
            "Warning can be visible on message sending when routing is not "
            "ready. WRN can still be reported as ERR/WRN PR if prints are "
            "continuously visible after start-up or more than 100 prints "
            "with the same id, sender, receiver."
        )
    },
    {
        "No": 37,
        "Regular_expression": (
            "WRN/HWA/SUM, \\[SumLinkRp3\\] .* byte error counter has hit "
            "the threshold count .*"
        ),
        "Example": (
            "WRN/HWA/SUM, [SumLinkRp3] 10b8b byte error counter has hit "
            "the threshold count (link: RP3 0, LCV: 418499, "
            "LCV total: 2147483647)"
        ),
        "Reason": (
            "It is expected behavior to see this print during board reset. "
            "When K2 is resetting, RP3 link between Murkku and K2 drops so "
            "it is expected to see 10b8b byte error in Murkku side."
        )
    },
    {
        "No": 38,
        "Regular_expression": (
            "WRN/LTS/LTS, \\[CorePoolDependencies\\] .* became offline, "
            "but won't cause core pool failure."
        ),
        "Example": (
            "WRN/LTS/LTS, [CorePoolDependencies] /MRBTS-1/RAT-1/MCTRL-4/"
            "BBTOP_M-1/SW_NODE_DEPLOYMENT-1/SW_NODE_SCHEMA-16 became "
            "offline, but won't cause core pool failure."
        ),
        "Reason": (
            "Warning can be visible when SW_NODE_L is offline during "
            "creation of CORE POOLs. Due to the nature of the process, "
            "it is not a disruptive failure for the emitter but an "
            "indication of potential issues during further processing."
        )
    },
    {
        "No": 39,
        "Regular_expression": (
            "adk_netd: adk_netd_idc_get_eeprom_len:.* Error: "
            "invalid peerdev"
        ),
        "Example": (
            "kernel: [    4.524695] adk_netd: "
            "adk_netd_idc_get_eeprom_len:124: Error: invalid peerdev"
        ),
        "Reason": (
            "Emitted by 3rd party driver provided by Intel, no operational "
            "impact. A ticket for Intel to fix this issue should be opened "
            "when the support contract has been reestablished."
        )
    },
    {
        "No": 40,
        "Regular_expression": (
            "WRN/BStat/PM, \\[CPmLomAgentMgr:\\] .* "
            "PmLomAgent::sendConfigReq is not triggered for .*"
        ),
        "Example": (
            "WRN/BStat/PM, [CPmLomAgentMgr:] [sendCounterConfigReq] "
            "PmLomAgent::sendConfigReq is not triggered for 0x2011176f"
        ),
        "Reason": (
            "Warning print can be visible at start-up phase after a "
            "reset/upgrade scenario as a one-time occurrence due to "
            "reset slave – cells synchronization needs to be stabilized."
        )
    },
    {
        "No": 41,
        "Regular_expression": (
            "WRN\\/NRTS\\/Core, \\[.*?Counters.*?\\] Counters set isn't complete:"
            "([\\s\\S]*?)are missed"
        ),
        "Example": (
            "WRN/NRTS/Core, [CntRachSetupAttemptMethod/CellCounters] "
            "Counters set isn't complete:\n"
            "WRN/NRTS/Core, [CntRachSetupAttemptMethod/CellCounters] "
            "Counters 3624534017, 3624534018, 3624534080, 3624540017 are missed\n"
            "WRN/NRTS/Core, [DegradedRrcConnectionSetupAttemptsMethod/CellCounters] "
            "Counters set isn't complete:\n"
            "WRN/NRTS/Core, [DegradedRrcConnectionSetupAttemptsMethod/CellCounters] "
            "Counters 3624540018, 3624544017 are missed\n"
            "WRN/NRTS/Core, [PrachAccessSlotMethod/CellCounters] "
            "Counters set isn't complete:\n"
            "WRN/NRTS/Core, [PrachAccessSlotMethod/CellCounters] "
            "Counters 3624544018, 3624544019 are missed"
        ),
        "Reason": (
            "Log warnings for sleeping cell counters should be disregarded because "
            "software correction is not feasible. WRN only seen and acceptable "
            "shortly after BBMOD restart and related to short Sleeping Cell "
            "Detection timer configuration. Maximal acceptable number of such "
            "prints is ~200-300. If more is visible, it could indicate a real issue."
        )
    },
    {
        "No": 42,
        "Regular_expression": (
            "ERR\\/TUPC\\/TupcL3MessageHandler.cpp#([0-9]+) "
            "Forwarding of a dedicated L3 message for uecContextId: ([0-9]+), "
            "connectionId: ([0-9]+) failed because correct SCTP stream cannot be "
            "derived - discarding message on link: ([0-9]+)"
        ),
        "Example": (
            "FCT-101B-5-TUPcexe <2025-09-10T06:47:19.714944Z> "
            "C5-TupSgnlNwThread ERR/TUPC/TupcL3MessageHandler.cpp#87 "
            "Forwarding of a dedicated L3 message for uecContextId: 4916, "
            "connectionId: 550 failed because correct SCTP stream cannot be derived "
            "- discarding message on link: 338"
        ),
        "Reason": (
            "It is expected to have such errors for the UeContext that was released "
            "because outsync and lost connection with eNB. Flood of such error "
            "(estimated as more than 20 prints/minute) when there are no UEs "
            "released can be the sign of a real functional problem with e.g. link X2."
        )
    },
    {
        "No": 43,
        "Regular_expression": (
            "Cannot lookup ethdev shared data"
        ),
        "Example": (
            "025631 23.09 14:54:01.542 [192.168.255.1] c3 ASP-123D-Y-CCS "
            "<2025-09-23T12:54:01.538598Z> 1B19-LogListener ERR/Rsyslogd/Rsyslogd, "
            "RTHWAPIDaemon[217]: message repeated 8 times: "
            "[ Cannot lookup ethdev shared data]"
        ),
        "Reason": (
            "Harmless DPDK (3rd party SW) internal error which may appear in "
            "shutdown phase if primary process closes all ethernet device ports "
            "before secondary processes exit. If the print appears in runtime, "
            "it might indicate a real issue within DPDK SW and is not expected."
        )
    }
]
