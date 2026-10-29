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

confluence_update_date = '2025-11-07'

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
            "in if no SRIO SFP present this warning occurs."
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
            "WRN can still be reported as ERR/WRN PR if: prints "
            "are continuously visible after start-up, more than "
            "100 prints with same id, sender, receiver (regardless "
            "if it's start-up or not). When investigating it is "
            "recommended for the tester to check the msg id in "
            "Midori and if the name indicates a polling type of "
            "message and the print is short-lived it is most likely "
            "not an indication of a problem."
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
            "as ERR/WRN PR if: prints are continuously visible "
            "after start-up, more than 100 prints with same id, "
            "sender, receiver (regardless if it's start-up or not). "
            "When investigating it is recommended for the tester "
            "to check the msg id in Midori and if the name indicates "
            "a polling type of message and the print is short-lived "
            "it is most likely not an indication of a problem."
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
            "creation of CORE POOLs, Due to the nature of the process, "
            "it is not a disruptive failure for the emitter but an "
            "indication of potential issues during further processing. "
            "In case if SW_NODE_L is not coming up online this can be "
            "reported to the concern team to investigate further"
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
            "reset slave – cells synchronization needs to be stabilized. "
            "WRN can be still reported as ERR / WRN PR if: Prints are "
            "continuously visible after start-up. If we will have many "
            "occurrences per sicaddress"
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
            "it leads to error. The error is correctly handled by systemd. "
            "Systemd could be reworked to look before if freezer is available, "
            "but it's not worth of effort as the whole cgroup1 is obsolete "
            "and will be removed. Switching to cgroup2 depends on "
            "https://jiradc.ext.net.nokia.com/browse/FFB-46120"
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
            "after use; further information can be found here in subsection "
            "\"overlay FDT\": https://elinux.org/Device_Tree_Linux#FDT_Flattened_Device_Tree. "
            "A previous attempt to reduce the log level from error to warning "
            "was rejected by the maintainer, leading to above documentation "
            "improvement: https://patchew.org/linux/VI1PR0701MB68298749C8133A7D69CFDBBFC9F09@"
            "VI1PR0701MB6829.eurprd07.prod.outlook.com/. "
            "As of 2024-01-25, this print is still present in the upstream kernel: "
            "https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/drivers/of/overlay.c?"
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
            "interpretation. For a short time sysfs entries mapped to fpga "
            "registers might be unavailable, hence we would get these errors. "
            "Problem would be if this situation continues after 10s, in which "
            "case yes, this log signalises a problem and requires interpretation"
        )
    },
    {
        "No": 21,
        "Regular_expression": "xiic_process.*nack",
        "Example": (
            "[warning] kernel: [332105.459243] xiic-i2c a5a11000.picasso_i2c_bp: "
            "xiic_process: 0x73: nack (irq/465-a5a1100:4175)"
        ),
        "Reason": (
            "This is an OK (normal) log when FPGA is reconfigured (upgrade "
            "scenarios). Occurrence of up to 10s time span is accepted. "
            "Otherwise, this log signalises a problem and requires "
            "interpretation. For a short time sysfs entries mapped to fpga "
            "registers might be unavailable, hence we would get these errors. "
            "Problem would be if this situation continues after 10s, in which "
            "case yes, this log signalises a problem and requires interpretation."
        )
    },
    {
        "No": 22,
        "Regular_expression": (
            "hpd.*(No such device or address|No such file or directory)"
        ),
        "Example": (
            "ERR/LFS/LinuxSyslog, hpd[9910]: ddal_sysfs_read: error reading "
            "4097 byte(s) from file '/dev/ddal/fpga/board_id_04/board_pwr_support': "
            "No such device or address. ERR/LFS/LinuxSyslog, hpd[9910]: "
            "ddal_utils_open_file: failed to open file '' (No such file or directory)"
        ),
        "Reason": (
            "This is an OK (normal) log when FPGA is reconfigured (upgrade "
            "scenarios). Occurrence of up to 10s time span is accepted. "
            "Otherwise, this log signalises a problem and requires "
            "interpretation. For a short time sysfs entries mapped to fpga "
            "registers might be unavailable, hence we would get these errors. "
            "Problem would be if this situation continues after 10s, in which "
            "case yes, this log signalises a problem and requires interpretation"
        )
    },
    {
        "No": 23,
        "Regular_expression": (
            "^(.*) kernel: \\[\\s*(.+)\\] WARNING: CPU: \\d+ PID: \\d+ "
            "at (.+):\\d+ do_sve_acc\\+(.*)$"
        ),
        "Example": (
            "5a FCT-1011-K-CCS <2024-05-14T17:17:18.360812Z> 26A7-LogListener "
            "WRN/LFS/LinuxSyslog,  kernel: [ 5965.116558] WARNING: CPU: 10 "
            "PID: 18500 at /arch/arm64/kernel/fpsimd.c:950 do_sve_acc+0x70/0xf0"
        ),
        "Reason": "Valid prints – appear due to extensive logging"
    },
    {
        "No": 24,
        "Regular_expression": "EM ERROR:0x00000002  ESCOPE:0xFF000201",
        "Example": (
            "2024-05-31T11:03:13.888462000Z l1_application[1662]: "
            "EM ERROR:0x00000002  ESCOPE:0xFF000201"
        ),
        "Reason": (
            "'EM ERROR:0x00000002 ESCOPE:0xFF000201' print is conditionally "
            "whitelisted during start-up due to the way communication "
            "initiation is handled. The log print can still be reported "
            "as ERR/WRN PR if: prints are continuously visible after start-up, "
            "more than 100 prints, regardless if it's start-up or not, "
            "log existing on a board that is not ABIC"
        )
    },
    {
        "No": 25,
        "Regular_expression": (
            "WRN/CCS/AaSysComKernelGw, isPeerAllowed\\(\\).*Matching route "
            "entry not found. Peer is not allowed."
        ),
        "Example": (
            "WRN/CCS/AaSysComKernelGw, isPeerAllowed()([<CCSMCU_65>"
            "fd5f:4268:2387:a881:40:43ff:fe80:330@184549376</CCSMCU_65>]:29211): "
            "Matching route entry not found. Peer is not allowed."
        ),
        "Reason": (
            "These prints are visible when remote node is connected but route "
            "toward that remote node is not added on local node. In that "
            "situation connection is dropped for security reasons and print "
            "is visible. If remote IP address is a BTS address, the prints "
            "do not indicate a security risk. Otherwise they might indicate "
            "potential security threat. Occurrence of up to 60s time span "
            "is accepted due to the way routes are configured in different "
            "time on various nodes."
        )
    },
    {
        "No": 26,
        "Regular_expression": "Valkey is now ready to exit, bye bye",
        "Example": (
            "4191 2025-01-20T11:38:27.622444Z 192.168.255.129 7c FCT-1011-K-CCS "
            "2025-01-20T11:38:27.622444Z 1E03-LogListener WRN/LFS/LinuxSyslog,  "
            "container-redis[18]:  Valkey is now ready to exit, bye bye..."
        ),
        "Reason": "Printed by 3rd party opensource software."
    },
    {
        "No": 27,
        "Regular_expression": "Received TIM_AF_BKT_SKIP_INTX",
        "Example": (
            "ERR/LFS/LinuxSyslog, kernel [ 4645.261072] rvu_af 0002 01 00.0 "
            "Received TIM_AF_BKT_SKIP_INTX(1) irq 0x2000000000000000."
        ),
        "Reason": (
            "Printed by 3rd party software. Visible on Marvell products. "
            "This print indicates that BKT_SKIP interrupt was generated by "
            "TIM hardware. It means hardware was not able to perform a "
            "bucket traversal and it should be done by software. It is a "
            "normal system behavior and can happen occasionally in runtime."
        )
    },
    {
        "No": 28,
        "Regular_expression": "AaConfigRadSlav WRN/FlushRingBuffer",
        "Example": (
            "WRN/LFS/LinuxSyslog,  em_perf_monitor[586]:  [AaSysLog] "
            "25B-AaConfigRadSlav WRN/FlushRingBuffer(): 2 items were "
            "dropped from 0x3b's ringbuffer"
        ),
        "Reason": (
            "It means AaConfigRadSlave thread of em_perf_monitor process "
            "did not manage to get cpu time to handle pending (startup "
            "related) messages before process terminated. This scenario "
            "is possible for processes with short life-time, such as "
            "em_perf_monitor or other debug tools. Such prints can "
            "occasionally be visible when some of syscom dependent debug "
            "tools are executed. But in general from syscom PoV they may "
            "indicate e.g. that syscom mutex vs. rx queue push/pop are "
            "not in sync, which is faulty situation."
        )
    },
    {
        "No": 29,
        "Regular_expression": (
            "pmd_set_huge: Cannot satisfy \\[mem 0x.*-0x.*\\] with a "
            "huge-page mapping due to MTRR override."
        ),
        "Example": (
            "pmd_set_huge: Cannot satisfy [mem 0x80000000-0x80200000] "
            "with a huge-page mapping due to MTRR override."
        ),
        "Reason": (
            "On both Xeon and Snowfish, when the kernel attempts to create "
            "huge I/O mappings, some address ranges (e.g. the PCIe MMCFG "
            "I/O space) are marked as uncacheable by the BIOS/UEFI via MTRR. "
            "As the MTRR is a legacy feature replaced by PAT, the kernel "
            "resolves this conflict by emitting a warning and creating the "
            "mapping with a smaller page size. Removing the MTRR override "
            "would require BIOS/UEFI modifications by the vendor, but due "
            "to Xeon/Snowfish being mature products, tickets can only be "
            "opened for critical PRs."
        )
    },
    {
        "No": 30,
        "Regular_expression": "ERR/AIF2 Aif2_Error_DbFifoOverflowCheckCallback",
        "Example": (
            "ERR/AIF2 Aif2_Error_DbFifoOverflowCheckCallback:578: "
            "dbFifoOvflStatus = 0, currentAdIschEopCount = 3360, "
            "dbFifoOverflowPtr->adIschEopCount = 1680"
        ),
        "Reason": (
            "This print appears, when there has been AIF2 DB FIFO overflow "
            "situation, after which AIF2 driver has triggered frequent "
            "polling mechanism to check if the overflow is permanent. "
            "Each occurrence of this print is useful for investigation. "
            "In case DB FIFO overflow situation is seen many times enough "
            "i.e. permanently, fault 6710 will be sent out. When the print "
            "appears during site or ABIA startup, it can be ignored."
        )
    },
    {
        "No": 31,
        "Regular_expression": (
            "(received SSO_AF_ERR2 irq|Workslot operation found no HWGRP "
            "PF_FUNC mapping for supplied guest group|SSO_AF_UNMAP_INFO2)"
        ),
        "Example": (
            "87 ASP-223D-K-CCS <2025-05-24T15:19:56.739615Z> 1BA4-LogListener "
            "ERR/LFS/LinuxSyslog,  kernel: [ 2481.559222] rvu_af 0002:01:00.0: "
            "received SSO_AF_ERR2 irq : 0x10000000"
        ),
        "Reason": (
            "Printed by 3rd party software. Visible on Marvell products "
            "when container shutdown is requested. According to Marvell, "
            "NOKIA can ignore those errors from kernel due to the way "
            "UP HWAPI shutdown works."
        )
    },
    {
        "No": 32,
        "Regular_expression": (
            "Daemon: NOTIFY_SOCKET was not set,no status data could be sent !!!"
        ),
        "Example": (
            "ERR/TRSW/TRSWSyslog,  TRS_SW[12011]:  Daemon: NOTIFY_SOCKET "
            "was not set,no status data could be sent !!!"
        ),
        "Reason": (
            "Print is coming from common library framework. It can appear "
            "during startup after site reset procedure when Daemon is "
            "trying to send the notification but the systemd socket is "
            "not yet opened - such error could be seen once per deamon "
            "application during startup and in such scenario the prints "
            "can be ignored. Print severity cannot be changed, because "
            "it can pinpoint valid issue - e.g. during run time if any "
            "communication link fails between applications."
        )
    },
    {
        "No": 33,
        "Regular_expression": (
            "handle::davici_read\\(mConn\\)|Service has been closed with "
            "FAILED state|tryFileEventsDispatcher: \\(.*\\) unhandled "
            "exception caught: Service port::.* timeouted!"
        ),
        "Example": (
            "ERR/coco/IpSec, handle::davici_read(mConn) return: -104"
        ),
        "Reason": (
            "Errors occur because the charon daemon has already been "
            "terminated following the RU reset. When the EthernetControl "
            "service attempts to read from the connection via davici, the "
            "connection is no longer available, resulting in error -104 "
            "(ECONNRESET). The root cause is that the EthernetControl "
            "service, which logs this error, is not aware of the RU "
            "shutdown. When such errors appear during RU reset procedure, "
            "they can be ignored."
        )
    },
    {
        "No": 34,
        "Regular_expression": (
            "page_pool_release_retry\\(\\) stalled pool shutdown .* "
            "inflight .* sec"
        ),
        "Example": (
            "e0 FCT-2011-K-CCS 2025-03-20T05:19:57.096722Z 2688-LogListener "
            "WRN/LFS/LinuxSyslog,  kernel: [ 1431.273390] "
            "page_pool_release_retry() stalled pool shutdown 12 inflight 60 sec"
        ),
        "Reason": (
            "This warning may appear when a user-space application fails "
            "to purge the RX queue after a network interface is restarted. "
            "Once the RX queue is purged or the process holding the buffers "
            "is terminated, the warning disappears. There is no functional "
            "impact and no performance degradation associated with this "
            "message in All known scenarios. So it's Safe to whitelist "
            "this warning message"
        )
    },
    {
        "No": 35,
        "Regular_expression": (
            "WRN/Syscon/ResetCtrl, Performing radio reset|"
            "ERR/coco/PortControl, p[0-9]+::RfoePortStateFetcher:: "
            "rfoe[0-9]+ not exist!|ERR/coco/PortControl, "
            "p[0-9]+::isRxFifoFull:: oth_rx_packets counter fetching is empty"
        ),
        "Example": (
            "<2025-06-17T10:34:38.947438Z> 1978-syscon WRN/Syscon/ResetCtrl, "
            "Performing radio reset..........1"
        ),
        "Reason": (
            "These errors are not harmful in case when RU reset is in "
            "progress. What happens is that CoCo dependency (L1) is "
            "terminated, so ports resources are not available anymore "
            "in the memory. Accessing not existing instances causes these "
            "errors. Unfortunately, RFSW is not able to distinguish "
            "service crash from expected reset, that is why errors "
            "should still be reported."
        )
    },
    {
        "No": 36,
        "Regular_expression": (
            "ERR/L2-PS/src/ul/sch/fd/Scheduler\\.cpp:[0-9*]{3} "
            "msg:0x[a-f0-9]{4} sfn:[0-9]{1,4} slot:[0-9]{1,2} "
            "GetUlSubCellMode failure"
        ),
        "Example": (
            "025927 11.06 12:02:29.069 [192.168.255.129] 02 ASP-1840-Disp_6 "
            "<2025-06-11T10:02:24.429843Z> 381-L2PsSchUl02 ERR/L2-PS/src/ul/sch/fd/Scheduler.cpp:867 "
            "msg:0xd621 sfn:1011 slot:2 GetUlSubCellMode failure"
        ),
        "Reason": (
            "Temporary errors that might appear at startup (or after reset) "
            "when BBRM component has not yet received all resources to "
            "configure pooling. BBRM needs to receive all CellSetupReq "
            "before being able to allocate resources. We can observe lots "
            "of instances of this error, depending on the number of cards "
            "on the gnb and the number of cells. Once BBRM receives all "
            "CellSetupReq, the error disappears - it lasts only a few seconds. "
            "If it is seen during runtime, it might mean a real issue."
        )
    },
    {
        "No": 37,
        "Regular_expression": (
            "ACPI Warning: \\\\_SB.PCI0.BR2C._PRT: Return Package has no "
            "elements \\(empty\\) \\(\\d+/nsprepkg-\\d+\\)"
        ),
        "Example": (
            "ACPI Warning: \\_SB.PCI0.BR2C._PRT: Return Package has no "
            "elements (empty) (20230628/nsprepkg-94)"
        ),
        "Reason": (
            "ACPI warning on Xeon only (ASIK and ABIL) indicating a "
            "malformed package object read during boot, most likely "
            "requiring a BIOS update to be fixed. The malformed package "
            "is gracefully dropped, not affecting further boot. With "
            "Xeon-based boards being legacy products at this point, it "
            "would be unlikely to get permission for a BIOS update on "
            "an uncritical warning, in addition of not being cost effective."
        )
    },
    {
        "No": 38,
        "Regular_expression": (
            "platform regulatory.0: Direct firmware load for regulatory.db "
            "failed with error -2|cfg80211: failed to load regulatory.db"
        ),
        "Example": (
            "platform regulatory.0: Direct firmware load for regulatory.db "
            "failed with error -2"
        ),
        "Reason": (
            "This error print does not have any operational impact as WIFI "
            "is working correctly after startup. Nokia doesn't want to use "
            "the regulatory database provided by the kernel and prefers to "
            "manage its own. Patching the kernel puts us outside the standard "
            "kernel scope and into a very specific use case, with low chances "
            "to be accepted in addition of the high resource cost. Also there "
            "is a high risk that Nokia would have to open-source its own WiFi "
            "implementation/configuration. Additionally, this would be "
            "considered a new feature, so it would need to go through Nokia "
            "FOSS review process."
        )
    },
    {
        "No": 39,
        "Regular_expression": (
            "Message send failed \\(recipient has not been registered\\). "
            "Contact the owner of destination CPID or message id"
        ),
        "Example": (
            "WRN/CCS/AaSysCom, Message send failed (recipient has not been "
            "registered). Contact the owner of destination CPID or message id"
        ),
        "Reason": (
            "These prints can be visible during shutdown due to various "
            "applications being shut down at different moments. As there "
            "are no requirements for graceful shutdown, such WRNs are "
            "acceptable. If observed during startup or runtime, it may "
            "indicate a real issue."
        )
    },
    {
        "No": 40,
        "Regular_expression": (
            "ERR/coco/General, SnapshotManager::failed to unregister "
            "snapshot manager properly\\. AaTrblFileUnregister returns: [0-9]+"
        ),
        "Example": (
            "ERR/coco/General, SnapshotManager::failed to unregister "
            "snapshot manager properly. AaTrblFileUnregister returns: 2"
        ),
        "Reason": (
            "Behavior of various components, including CoCo, during shutdown "
            "is not well defined. As these errors are valid during runtime "
            "and unavoidable during shutdown, they should be exempt until "
            "graceful shutdown is implemented. This exclusion should be "
            "applied only to prints occurring during radio unit shutdown/reset. "
            "If seen during runtime, it might indicate a real issue. Extended "
            "version of regex matching prints between start of radio reset "
            "and error from Coco can be found below, but please remember "
            "that it will catch also all other prints in between: "
            "WRN/Syscon/ResetCtrl, Performing radio reset(.*\\s)*ERR/coco/General, "
            "SnapshotManager::failed to unregister snapshot manager properly\\. "
            "AaTrblFileUnregister returns: [0-9]+"
        )
    },
    {
        "No": 41,
        "Regular_expression": (
            "WRN/NRTS/Core, \\[.*?Counters.*?\\] Counters set isn't "
            "complete:([\\s\\S]*?)are missed"
        ),
        "Example": (
            "WRN/NRTS/Core, [CntRachSetupAttemptMethod/CellCounters] "
            "Counters set isn't complete:"
        ),
        "Reason": (
            "Log warnings for sleeping cell counters should be disregarded "
            "because software correction is not feasible - time synchronization "
            "of the counters would require introducing artificial delays in "
            "many counter providers, resulting in high costs to gain valid "
            "measurements from the first measurement period. The system "
            "specification already warns about cases where counters cannot "
            "be fully collected. WRN only seen and acceptable shortly after "
            "BBMOD restart and related to short Sleeping Cell Detection timer "
            "configuration. They might occur between availability of the "
            "supervised counters and the activation of sleeping cell detection. "
            "Maximal acceptable number of such prints is ~200-300. If more "
            "is visible, it could indicate a real issue."
        )
    },
    {
        "No": 42,
        "Regular_expression": (
            "ERR/TUPC/TupcL3MessageHandler.cpp#([0-9]+) Forwarding of a "
            "dedicated L3 message for uecContextId: ([0-9]+), connectionId: "
            "([0-9]+) failed because correct SCTP stream cannot be derived - "
            "discarding message on link: ([0-9]+)"
        ),
        "Example": (
            "FCT-101B-5-TUPcexe <2025-09-10T06:47:19.714944Z> "
            "C5-TupSgnlNwThread ERR/TUPC/TupcL3MessageHandler.cpp#87 "
            "Forwarding of a dedicated L3 message for uecContextId: 4916, "
            "connectionId: 550 failed because correct SCTP stream cannot "
            "be derived - discarding message on link: 338"
        ),
        "Reason": (
            "It is expected to have such errors for the UeContext that was "
            "released because outsync and lost connection with eNB. It can "
            "happen in runtime and be expected in poor radio connection "
            "testing scenario. Severity should remain ERR as it might mean "
            "a real problem and it helps tracking specific problems in the "
            "customer networks due to bigger buffer for the history of error "
            "logs. Flood of such error (estimated as more than 20 prints/minute) "
            "when there are no UEs released with \"connection with ue lost\" "
            "can be the sign of a real functional problem with e.g. link X2. "
            "Similarly when noticeable degradation between comparable SW "
            "builds is seen."
        )
    },
    {
        "No": 43,
        "Regular_expression": "Cannot lookup ethdev shared data",
        "Example": (
            "025631 23.09 14:54:01.542 [192.168.255.1] c3 ASP-123D-Y-CCS "
            "<2025-09-23T12:54:01.538598Z> 1B19-LogListener ERR/Rsyslogd/Rsyslogd, "
            "RTHWAPIDaemon[217]: message repeated 8 times: [ Cannot lookup "
            "ethdev shared data]"
        ),
        "Reason": (
            "Harmless DPDK (3rd party SW) internal error which may appear "
            "in shutdown phase if primary process closes all ethernet device "
            "ports before secondary processes exit. Any change would need "
            "getting DPDK community agreement and according to Platform it "
            "is not feasible. If the print appears in runtime, it might "
            "indicate a real issue within DPDK SW and is not expected."
        )
    },
    {
        "No": 44,
        "Regular_expression": "watchdog did not stop!",
        "Example": (
            "e5 FSP-146D-K-CCS <2025-07-25T07:29:32.895793Z> 935-LogListener "
            "ERR/LFS/LinuxSyslog,  kernel: [ 9469.666103] watchdog: watchdog0: "
            "watchdog did not stop!"
        ),
        "Reason": (
            "Print comes from upstream kernel (Linux). The reason is that "
            "the davinci watchdog timer running there, handled by the "
            "davinci_wdt upstream driver, cannot be stopped by design. "
            "Such watchdog timers should be marked with a nowayout flag "
            "to indicate that there's no way to stop the watchdog. The "
            "only way to stop such watchdog timers is by the watchdog "
            "timeout itself or by a CPU restart. During Linux shutdown "
            "it is checked whether the watchdog could be stopped. In such "
            "case - due to the nowayout flag - it is not possible and that's "
            "the reason for the \"watchdog did not stop!\" message being "
            "printed. It is just an indication of the fact that the watchdog "
            "timer cannot be stopped by design. It is not an indicator of "
            "a problem and this print is fully expected with the current "
            "design of that upstream driver. Print severity change is not "
            "feasible solution as it would need kernel's update."
        )
    },
    {
        "No": 45,
        "Regular_expression": (
            "Unit uses CPUShares=; please use CPUWeight= instead\\. "
            "Support for CPUShares= will be removed soon\\."
        ),
        "Example": (
            "WRN/LFS/LinuxSyslog, systemd[1]: "
            "/etc/systemd/system.control/user.slice.d/50-CPUShares.conf:4: "
            "Unit uses CPUShares=; please use CPUWeight= instead. Support "
            "for CPUShares= will be removed soon."
        ),
        "Reason": (
            "Problem caused by 3rd party SW (systemd). It is a valid warning, "
            "as with next systemd versions (already in latest stable upstream "
            "release) the use of \"CPUShares\" isn't supported anymore. With "
            "introduction of \"CNI-144793 - Cgroup v2 deployment\" components "
            "need to change this and the warning shouldn't be seen anymore."
        )
    },
    {
        "No": 46,
        "Regular_expression": (
            "A TPM error \\(256\\) occurred attempting the self test"
        ),
        "Example": (
            "kernel: tpm tpm0: A TPM error (256) occurred attempting the self test"
        ),
        "Reason": (
            "Print comes from upstream kernel (Linux). TPM is expected to be "
            "started before kernel. This doesn't happen on our platforms. When "
            "kernel's TPM driver takes over it first tries to run TPM self-tests "
            "because of the expectation that TPM was started before. This results "
            "in the print. After that we fall back into kernel's workaround that "
            "first starts the TPM and then runs self-tests. This doesn't introduce "
            "any security issues and is in-line with TPM usage on our platform and "
            "the print is a natural consequence of it."
        )
    },
    {
        "No": 47,
        "Regular_expression": (
            "WRN.LFS.LinuxSyslog.*udev-worker.*Could not generate persistent MAC address: No data available"
        ),
        "Example": (
            "WRN/LFS/LinuxSyslog, (udev-worker)[9104]: gre30: Could not generate "
            "persistent MAC address: No data available"
        ),
        "Reason": (
            "Emitted by 3rd party open source component as udev code in systemd, "
            "but with no operational impact. A valid mac address is generated and "
            "the interface can be properly used. If not other error logs will appear."
        )
    },
    {
        "No": 48,
        "Regular_expression": (
            "kernel: cpri\\d+ \\{cpri\\d+ lmac\\d+\\} link down, drop pkt"
        ),
        "Example": (
            "1006844 22.09 04:08:55.372 [192.168.255.1] 41 FSP-124D-0 "
            "<2025-09-22T02:08:55.369142Z> 0 ERR/kernel, cpri2 {cpri0 lmac2} "
            "link down, drop pkt"
        ),
        "Reason": (
            "Ownership and monitoring: On Thor/Loki SoCs, the L1 application owns "
            "BPHY and exclusively monitors FH link state (via CPRI sync and SFP RX "
            "levels). The Marvell driver does not know the carrier state on its own "
            "and depends on L1 to signal state changes through an IOCTL. Timing gap "
            "on recovery: After a link recovers, packets can start arriving over the "
            "FH link before L1 has updated the driver about the carrier being \"OK.\" "
            "During this short window, the interface is still considered down by the "
            "driver. Driver behavior: The Marvell driver treats any packet drop while "
            "the interface is down as an error and logs it using net_err_ratelimited, "
            "which surfaces as ERR in the L1 logs. Resulting symptom: ERR prints appear "
            "even in normal link-down/up scenarios, especially if M-plane SOAP messages "
            "are in-flight during a link transition. These prints are useful in real PR "
            "cases (e.g., FID10) to trace where M-plane messages were lost near a link "
            "break. It is L1 view that pursuing the removal of those prints is more "
            "harmful than whitelisting, so no requests will be sent to Marvell to "
            "improve the situation."
        )
    },
    {
        "No": 49,
        "Regular_expression": (
            "NewSoapGateway is disabled! Message won't be sent"
        ),
        "Example": (
            "4006-SoapGatewayThr WRN/LTX/UOM_SoapGW, NewSOAPGateway::sendSoapMessage, "
            "NewSoapGateway is disabled! Message won't be sent"
        ),
        "Reason": (
            "Such warning is possible in tear down phase, as some components shut down "
            "earlier than UOAM, and then the related communication will be failed, e.g. "
            "UDPCP port is closed earlier than UOAM stop all L3 communication. Current "
            "architecture does not control the order of programs being shut down. "
            "In normal runtime situation, if soap message sending is failed, then warning "
            "should be checked by SW team as a potential issue."
        )
    }
]
