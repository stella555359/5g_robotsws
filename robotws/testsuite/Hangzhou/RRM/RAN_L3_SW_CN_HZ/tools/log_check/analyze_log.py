import re
import sys
import glob
from collections import defaultdict


def normalize_log_line(line):
    match = re.search(r'\b(WRN|ERR|INF)/(.+)', line)
    if not match:
        return None, None

    level = match.group(1)
    log = match.group(2)

    if level != "INF":
        # ----------- 特殊模式归一化 ------------
        # L2HiDu, g0r000n40B3ucp0000t0000h04/Ln(这一串字母会变)
        log = re.sub(r'L2HiDu,.*/Ln', '', log)

        # IPv4 martian source（网卡名/时间浮点/IP）
        log = re.sub(r'kernel:\s+\[\s*\d+\.\d+\]', 'kernel: [N.N]', log)
        log = re.sub(r'on dev \w+', 'on dev DEV', log)
        log = re.sub(r'\b(?:\d{1,3}\.){3}\d{1,3}\b', 'IP', log)

        # ll header 内容（十六进制 MAC 头）
        log = re.sub(r'(ll header:\s+)00000000:([\da-fA-F\s]+)', r'\1HEXDATA', log)

        # vfio-pci PCI 设备地址统一
        log = re.sub(r'vfio-pci\s+[0-9a-fA-F]{4}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}\.[0-9]', 'vfio-pci PCI_ADDR', log)

        # sock_err 错误代码统一
        log = re.sub(r'sock_err\s*=\s*\d+', 'sock_err=N', log)

        # GNSS设备ID归一化
        log = re.sub(r'GNSSDevice\[DEVICE-\d+\]', 'GNSSDevice[DEVICE-x]', log)

        # 通用替换：十六进制、浮点、整数
        log = re.sub(r'0x[0-9a-fA-F]+', '0xHEX', log)
        log = re.sub(r'\d+\.\d+', 'N.N', log)
        log = re.sub(r'\d+', 'N', log)
        return level, log.strip()

    elif log.lower().count("exception caught"):
        return level, log.strip()
    else:
        return None, None


def parse_log_file(filename):
    logs = defaultdict(lambda: {'level': '', 'count': 0, 'first_line': ''})
    if len(glob.glob(filename)) == 0:
        raise Exception("{} doesn't exist".format(filename))
    files = glob.glob(filename)
    files.sort()
    for filepath in files:
        print("analyzing {}".format(filepath))
        # with open(filepath, encoding='utf-8') as f:
        with open(filepath, encoding="utf-8", errors="ignore") as f:
            for line in f:
                level, norm_log = normalize_log_line(line)
                # if line.count("outside of Tx window"):
                #     print("log file after change:")
                #     print(norm_log)
                if level is None:
                    continue
                if norm_log not in logs:
                    logs[norm_log]['level'] = level
                    logs[norm_log]['first_line'] = line.strip()
                logs[norm_log]['count'] += 1
    return logs


def parse_baseline_file(filename):
    # 读取 baseline，分 check / not check
    baseline_check = {}
    baseline_not_check = {}
    current_section = None

    with open(filename, encoding='utf-8') as f:
        for line in f:
            line_strip = line.strip()
            if line_strip.lower() == '[check]':
                current_section = 'check'
                continue
            elif line_strip.lower() == '[not check]':
                current_section = 'not_check'
                continue
            if not line_strip or line_strip.startswith('#'):
                continue
            # 解析行格式: "WRN | 2 occurrences | 28.07 07:58:31.906639 ... log ..."
            parts = line_strip.split('|')
            if len(parts) < 3:
                continue
            level = parts[0].strip()
            count_str = parts[1].strip()
            count_match = re.match(r'(\d+)\s+occurrences', count_str)
            count = int(count_match.group(1)) if count_match else 0
            # 归一化处理该日志内容以保证对比一致，避免时间等变化带来的误差
            raw_log = '|'.join(parts[2:]).strip()

            # 对log内容归一化以匹配key
            _, norm_log = normalize_log_line(raw_log)
            # if line.count("outside of Tx window"):
            #     print("baseline after change:")
            #     print(norm_log)
            if norm_log is None:
                continue

            entry = {'level': level, 'count': count, 'raw_line': line_strip}
            if current_section == 'check':
                baseline_check[norm_log] = entry
            elif current_section == 'not_check':
                baseline_not_check[norm_log] = entry

    return baseline_check, baseline_not_check


def print_log_summary(logs):
    # for norm_log, data in sorted(logs.items(), key=lambda x: x[1]['count'], reverse=True):
    with open('log.txt', 'w', encoding='utf-8') as f:
        for norm_log, data in logs.items():
            print(f"{data['level']} | {data['count']} occurrences | {data['first_line']}", file=f)
            print(f"{data['level']} | {data['count']} occurrences | {data['first_line']}")


def compare_logs(current_logs, baseline_check, baseline_not_check):
    errors = []
    new_err_wrn = []
    more_occurrence_err_wrn = []
    disappear_err_wrn = []

    # 检查 baseline check 中的日志, 不能超次数
    for norm_log, base_entry in baseline_check.items():
        base_count = base_entry['count']
        base_level = base_entry['level']
        cur_count = current_logs.get(norm_log, {'count': 0})['count']
        if cur_count == 0:
            disappear_err_wrn.append(base_entry['raw_line'])
        elif cur_count > base_count:
            more_occurrence_err_wrn.append(
                f"Baseline: {base_entry['raw_line']}\nCurrent count: {cur_count}, Baseline count: {base_count}")

    # 检查当前日志中是否有 baseline check 没有的 warn/err 新增日志
    for norm_log, cur_entry in current_logs.items():
        if norm_log not in baseline_check and norm_log not in baseline_not_check:
            if cur_entry['level'] in ('WRN', 'ERR'):
                new_err_wrn.append(cur_entry['first_line'])

    if new_err_wrn + more_occurrence_err_wrn:
        print("\n=== Compare Result: FAIL ===")
        if new_err_wrn:
            print("\nnew ERR/WRN log:")
            for e in new_err_wrn:
                print(e)
        if more_occurrence_err_wrn:
            print("\nERR/WRN log count increased:")
            for e in more_occurrence_err_wrn:
                print(e)
    else:
        print("\n=== Compare Result: PASS ===")

    if disappear_err_wrn:
        print("\nERR/WRN disappeared -- not fail checking:")
        for e in disappear_err_wrn:
            print(e)


def check_flooding(threshold=100, level="ERR", specified_skip_patterns=[]):
    skip_patterns = [
        'WRN/LFS/LinuxSyslog.*martian source',
        'WRN/LFS/LinuxSyslog.*ll header',
        'WRN/LFS/LinuxSyslog.*Adding kernel taint for vfio-noiommu group on device',
        'WRN/cp_sctp_XN/SCTPEndpointFunctions.cpp.*remote server addr.*10.0.1',
        'WRN/cp_sctp_XN/SCTPEndpointFunctions.cpp.*which have drop the package',
        'WRN/CCS/AaSysLog.*Error and Vip logs will be accepted',
        'WRN/CCS/AaSysCom.*Contact the owner of destination CPID or message id',
        # LTE, btslog wrn when capturing emil log
        'FCT-.*-BtsLog.*-TPS_15004.* WRN/CCS/',
        # LTE, CUS issue
        'WRN/ULPHY/PUSCH.*PUSCH UE Request',
        'WRN/TDDPS/FID_MGMT_MSG/.*/received message',
        # PR744125 CNNed by Management Decision
        'ERR/Lim/GEN.*Unknown class',
        # GPS firmware upgrade
        'WRN/HWA/HWASYNC.*Detected quantization error reception problem',
        # ERR/WRN whitelist
        'WRN/CCS/AaSysComKernelGw.*Matching route entry not found. Peer is not allowed',
        'WRN/CCS/AaSysCom, Message send failed',
        'WRN/CCS/AaSysCom, Detected looped message from SysComSocket, probably container is not up yet',
        'ERR/L2-PS',
        # known PRs
        # # PR854768
        # 'WRN/LFS/LinuxSyslog.*redis connecting error',
        # # PR855565
        # 'WRN/ENBC/.*Cannot found uec address',
        # # PR856772 25R2 CNA
        # 'stop forwardingcommon::f1ap::GnbDuStatusIndication to CU',
        # PR845386 25R3 need confirm
        'WRN/CCS/AaSysCom, GetFilterValuesFromRadParams: Invalid filter values',
        # # PR859001
        # 'WRN/TC_SlaveEm.*UE start trace indication received',
    ]
    skip_patterns.extend(specified_skip_patterns)
    skip_patterns = [re.compile(i) for i in skip_patterns]
    occurrence_pattern = re.compile(r'\b(\d+)\s+occurrences\b')

    with open('log.txt', 'r', encoding='utf-8') as f:
        flooding = []
        for line in f:
            # 跳过包含指定内容的行
            if any(p.search(line) for p in skip_patterns):
                continue

            # 匹配并提取 occurrence 数值
            match = occurrence_pattern.search(line)
            if match:
                count = int(match.group(1))
                if count > threshold and line.strip().startswith(level):
                    flooding.append(line.strip())
        if flooding:
            print(f"\n=== Flooding {level} found (occurrences > {threshold})===")
            print("need check whitelist:https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1637010227")
            for log in flooding:
                print(log)
        else:
            print(f"\n=== Flooding {level} not found (occurrences > {threshold})===")


def check_exception():
    with open('log.txt', 'r', encoding='utf-8') as f:
        exception = []
        for line in f:
            if re.search(r"(WRN|ERR)/.*(exception caught|Dynamic exception type)", line.lower(), re.I):
                exception.append(line)
        if exception:
            print(f"\n=== Exception found ===")
            for log in exception:
                print(log)
        else:
            print(f"\n=== Exception not found ===")


def check_crash():
    with open('log.txt', 'r', encoding='utf-8') as f:
        crash = []
        for line in f:
            if line.lower().count("please contact the owner") or \
                    line.lower().count("eu name") or \
                    line.count("FATAL DSPHWAPI ERROR") or \
                    line.lower().count("core.xz"):
                crash.append(line)
        if crash:
            print(f"\n=== Crash found ===")
            for log in crash:
                print(log.strip())
        else:
            print(f"\n=== Crash not found ===")


def main():
    if len(sys.argv) == 1:
        print("Usage:")
        print("  python {} -l log_file".format(sys.argv[0]))
        print("  python {} -l log_file -ft threshold -sp xxx -sp yyy ...".format(sys.argv[0]))
        print("  python {} -l log_file -b baseline_file".format(sys.argv[0]))
    else:
        command_options = " ".join(sys.argv[1:])
        # 1. get log file from arguments
        ret = re.search(r"-l ((?!-)\S+)", command_options, re.I)
        if ret:
            log_file = ret.group(1)
        else:
            log_file = None

        # 2. get skip patterns from arguments
        ret = re.findall(r"-sp ((?:(?!-\w).)+)", command_options, re.I)
        if ret:
            sp = [i.strip() for i in ret]
        else:
            sp = []

        # 3. get flooding threshold from arguments
        ret = re.search(r"-ft ([^-\s]+)", command_options, re.I)
        if ret:
            ft = int(ret.group(1))
        else:
            ft = 100

        # 4. get baseline file from arguments
        ret = re.findall(r"-b ([^-\s]+)", command_options, re.I)
        if ret:
            baseline_file = ret[0]
            print("baseline_file:{}".format(baseline_file))
        else:
            baseline_file = None

        current_logs = parse_log_file(log_file)
        print("=== Current ERR/WRN logs summary ===")
        print_log_summary(current_logs)

        if baseline_file:
            baseline_check, baseline_not_check = parse_baseline_file(baseline_file)
            compare_logs(current_logs, baseline_check, baseline_not_check)
        else:
            check_flooding(ft, "ERR", sp)
            check_exception()
            check_crash()


if __name__ == '__main__':
    main()
