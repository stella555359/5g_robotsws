import re


def sum_cnt_above_bin_from_file(file_path: str, bin_threshold: int, per_threshold: float) -> bool:
    with open(file_path, 'r', encoding='utf-8') as f:
        iperf_output = f.read()

    lost_pkts, total_pkts = get_total_packets_from_file(file_path)
    assert lost_pkts == 0, f"Assertion failed: Lost packets is 0 in file {file_path}"
    if total_pkts == -1:
        return False

    # extract bin:cnt
    match = re.search(r'bin\(w=100us\):cnt\((\d+)\)=([^\(]+)', iperf_output)
    if not match:
        return False
    # bin_cnt_str = match.group(1)
    pairs = re.findall(r'(\d+):(\d+)', iperf_output)
    print(pairs)
    # total_cnt = sum(int(cnt) for bin_val, cnt in pairs if int(bin_val) > bin_threshold)
    total_cnt = sum(int(cnt) for bin_val, cnt in pairs if int(bin_val) > bin_threshold)
    print(f"the total count exceeding PDB {total_cnt}")
    print(f"the total packets {total_pkts}")
    percent = total_cnt / total_pkts if total_pkts > 0 else 0
    print(f"the percentage is {percent}")
    return percent <= per_threshold


def get_total_packets_from_file(file_path: str):
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    for idx, line in enumerate(lines):
        if 'Lost/Total' in line:
            if idx + 1 < len(lines):
                next_line = lines[idx + 1]
                # find the characters: ms 0/300071
                match = re.search(r'ms\s+(\d+)/(\d+)', next_line)
                print(f"match.group(0): {match.group(0)}")
                print(f"match.group(1): {match.group(1)}")
                print(f"match.group(2): {match.group(2)}")
                if match:
                    lost_pkts = int(match.group(1))
                    total_pkts = int(match.group(2))
                    print(f"Total packets: {total_pkts}")
                    return lost_pkts, total_pkts
                # if ms not found, try to find just 0/total
                match = re.search(r'(\d+)/(\d+)', next_line)
                if match:
                    lost_pkts = int(match.group(1))
                    total_pkts = int(match.group(2))
                    print(f"Total packets (0/total): {total_pkts}")
                    return lost_pkts, total_pkts
    print("Could not find total packets after Lost/Total.")
    return -1, -1
