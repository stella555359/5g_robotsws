"""
:copyright: Nokia
:author: dariusz.maciocha@nokia.com
:maintainer: dariusz.maciocha@nokia.com
"""

from robot.libraries.BuiltIn import BuiltIn
from pathlib import Path
from taf.rfrl.utilities.logger.custom_logger import log_info_to_console, log_warn_to_console
import re

WHITELIST = {
    r"AaSyslog buffer \d+ \(\w+\) (reached|dropped to) LoadLevel2, Info, Warning, Error and Vip logs will be accepted",
    r"AaSyslog buffer LoadLevel2: INF, WRN, ERR and VIP logs will be accepted",
    r"dhcpd:.*",
    r"AaSyslog buffer \d+ \(\w+\) (reached|dropped to) LoadLevel3, Error and Vip logs will be accepted",
    r"AaSyslog buffer LoadLevel3: ERR and VIP logs will be accepted",
    r"kernel: \[\s*\d+\.\d+\] EXT4-fs \(sda\d\): warning: maximal mount count reached, running e2fsck is recommended",
    r"extSrioPortStateControl:.*SFP absent",
    r"rsyslogd: .* try http://www.rsyslog.com/e/2027",
    r"kauditd_printk_skb: \d+ callbacks suppressed",
    r"Please check if cell is already deactivated in RF but cell is not deleted yet in UL PHY and MAC PS",
    r"WRN/CCS/AaSysCom, Detected looped message from SysComSocket, probably container is not up yet. Message dropped "
    r"Msg",
    r"WRN\/CCS\/AaIPC, sendData\([0-9]+\):FAILED in send errno=.* socketFd=.* nid=.* cpid=.* dataLenght.* retSend",
    r"WRN\/HWA\/SUM, \[SumLinkRp3\] LCV error in the header of a message \(link: RP3 ., LCV: .*, LCV total: .*\)",
    r"WRN\/HWA\/SUM, \[SumLinkRp3\] 10b8b byte error counter has hit the threshold count \(link: RP3 ., LCV: .*, LCV "
    r"total: .*\)",
    r"WRN/LTS/LTS, \[CorePoolDependencies\] .* became offline, but won't cause core pool failure.",
    r"^.*ERROR.*after.*ReadyToLock",
    r"WRN/BStat/PM, \[CPmLomAgentMgr:\] \[sendCounterConfigReq\] PmLomAgent::sendConfigReq is not triggered for .*",
    r"cgroup: Disabled controller 'freezer'",
    r"WARNING: memory leak will occur if overlay removed, property: .*",
    r"adk_netd: adk_netd_idc_get_eeprom_len:124: Error: invalid peerdev",
    r"bmuq_regmap.*\(-6\)",
    r"xiic_process.*nack",
    r"hpd.*(No such device or address|No such file or directory)",
    r"^(.*) kernel: \[\s*(.+)\] WARNING: CPU: \d+ PID: \d+ at (.+):\d+ do_sve_acc\+(.*)$",
    r"EM ERROR:0x00000002  ESCOPE:0xFF000201",
    r"WRN/CCS/AaSysComKernelGw, isPeerAllowed\(\).*Matching route entry not found. Peer is not allowed.",
    r"Valkey is now ready to exit, bye bye",
    r"Received TIM_AF_BKT_SKIP_INTX",
    r"AaConfigRadSlav WRN/FlushRingBuffer",
    r"pmd_set_huge: Cannot satisfy \[mem 0x.*-0x.*\] with a huge-page mapping due to MTRR override.",
    r"ERR/AIF2 Aif2_Error_DbFifoOverflowCheckCallback",
    r"received SSO_AF_ERR2 irq|Workslot operation found no HWGRP PF_FUNC mapping for supplied guest "
    r"group|SSO_AF_UNMAP_INFO2",
    r"Daemon: NOTIFY_SOCKET was not set,no status data could be sent !!!",
    r"handle::davici_read\(mConn\)|Service has been closed with FAILED state|tryFileEventsDispatcher: \(.*\) unhandled "
    r"exception caught: Service port::.* timeouted!",
    r"page_pool_release_retry\(\) stalled pool shutdown .* inflight .* sec",
    r"WRN\/Syscon\/ResetCtrl, Performing radio reset|ERR\/coco\/PortControl, p[0-9]+::RfoePortStateFetcher:: "
    r"rfoe[0-9]+ not exist!|ERR\/coco\/PortControl, p[0-9]+::isRxFifoFull:: oth_rx_packets counter fetching is empty",
    r"ERR\/L2-PS\/src\/ul\/sch\/fd\/Scheduler\.cpp:[0-9*]{3} msg:0x[a-f0-9]{4} sfn:[0-9]{1,4} "
    r"slot:[0-9]{1,2} GetUlSubCellMode failure",
    r"ACPI Warning: \\\_SB.PCI0.BR2C._PRT: Return Package has no elements \(empty\) \(\d+/nsprepkg-\d+\)",
    r"platform regulatory.0: Direct firmware load for regulatory.db failed with error -2|"
    r"cfg80211: failed to load regulatory.db",
    r"Message send failed \(recipient has not been registered\). Contact the owner of destination CPID or message id",
    r"ERR\/coco\/General, SnapshotManager::failed to unregister snapshot manager properly"
    r"\. AaTrblFileUnregister returns: [0-9]+",
    r"^.*WRN\/NRTS\/Core, \[.*?\/CellCounters\](?: Counters set isn't complete:| "
    r"(?:Counters )?\d+(?:, \d+)*(?: are missed)?).*$",
    r"ERR\/TUPC\/TupcL3MessageHandler.cpp#([0-9]+) Forwarding of a dedicated L3 message for uecContextId: ([0-9]+), "
    r"connectionId: ([0-9]+) failed because correct SCTP stream cannot be derived - "
    r"discarding message on link: ([0-9]+)",
    r"Cannot lookup ethdev shared data",
    r"watchdog did not stop!",
    r"Unit uses CPUShares=; please use CPUWeight= instead\. Support for CPUShares= will be removed soon\.",
    r"A TPM error (256) occurred attempting the self test",
    r"WRN.LFS.LinuxSyslog.*udev-worker.*Could not generate persistent MAC address: No data available",
    r".*kernel: cpri(\d+) {cpri(\d+) lmac(\d+)} link down, drop pkt",
    r"NewSoapGateway is disabled! Message won't be sent",
    r"WRN\/AaSysComCountLivingReceivers\(\): EU 0x[0-9a-fA-F]+ \(\S+\) EE 0x[0-9a-fA-F]+ \(\S+\) "
    r"did not shutdown on time as expected by EU 0x[0-9a-fA-F]+ EE 0x[0-9a-fA-F]+|"
    r"WRN\/AaSysComSendOutEeShutdownNotifMsgs\(\): Shutdown message sent to \d+ receivers, "
    r"\d+ successfully shut down \(\d+ CPIDs have been reclaimed\)"
}


class syslog_checker:
    def __init__(self):
        self._built_in = BuiltIn()
        self._test_dir: str = f'{self._built_in.get_variable_value("${OUTPUT_DIR}")}/' \
                              f'{self._built_in.get_variable_value("${TEST_NAME}")}'
        self.suspicious_prints: list = []

    def find_suspicious_logs(self, search_folder: Path | str | None = None,
                             syslog_path: Path | str | None = None) -> None:
        """
        Finds suspicious prints in the syslog file.

        :param patterns: Pattern to look for in syslog
        :param search_folder: Folder to recursively search for syslog files
        :param syslog_path: Path to single syslog file (disables recursive search)
        """
        if syslog_path:
            syslog_files = list(syslog_path)
        else:
            if not search_folder:
                search_folder = self._test_dir
            syslog_files = Path(search_folder).rglob('*.[Ll][Oo][Gg]')
            if not syslog_files:
                log_info_to_console("No syslog file found")
                return
        with Path(f'{search_folder}/syslog_report.txt').open("w") as report_file:
            for file in sorted(syslog_files):
                if 'iphy' in file.name:
                    continue
                with file.open(errors='replace') as f:
                    report_file.write(str(file.absolute()) + "\n\n")
                    for line in f:
                        if "ERR/" in line and not \
                                any(re.search(whitelist_pattern, line) for whitelist_pattern in WHITELIST):
                            self.suspicious_prints.append(line)
                            report_file.write(line)
            if self.suspicious_prints:
                log_warn_to_console(f"Found {len(self.suspicious_prints)} suspicious prints. Report stored in "
                                    f"{search_folder}/syslog_report.txt")
