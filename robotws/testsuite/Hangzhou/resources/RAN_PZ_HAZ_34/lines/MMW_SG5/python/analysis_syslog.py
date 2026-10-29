# -*- coding: utf-8 -*-
# @Time    : 2023/12/27 9:43
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : analysis_syslog.py
# @Software: PyCharm
import os
import re
syslog_path = "/tmp/btslog2/"


def get_best_beam_ids_syslog():
    files = os.listdir(syslog_path)
    for file in files:
        if file.endswith(".LOG"):
            syslog_file = syslog_path + file
    with open(syslog_file, "r") as fr:
        syslog = fr.read()
        results = re.findall(r'bestPatternId:(\d+)(.*)secondPatternId:(\d+)', syslog)
        beams = []
        for result in results:
            best_beam = result[0]
            if best_beam not in beams:
                beams.append(best_beam)
    return beams


def analysis_syslog_for_cni_111312(syslog="2024-07-02_08_59_04_Aasys_CCS_MCU.txt", cur_nr_cell_id=186335536):
    def _avg_prev_numeric_samples(seq, end_index, n):
        """
        Take average of previous n numeric samples BEFORE end_index (exclusive),
        skipping non-numeric markers like 'tgtMutingRatio = xx'.
        """
        samples = []
        i = end_index - 1
        while i >= 0 and len(samples) < n:
            v = seq[i]
            if isinstance(v, (int, float)):
                samples.append(v)
            i -= 1
        if not samples:
            raise ValueError(f"No numeric samples found before index={end_index}")
        return sum(samples) / len(samples)

    def _avg_next_numeric_samples(seq, start_index, skip_numeric, n):
        """
        Average of next n numeric samples AFTER start_index (exclusive),
        skipping first `skip_numeric` numeric samples; ignores marker strings.
        Example: skip_numeric=10 => start from the 11th numeric sample after start_index.
        """
        samples = []
        i = start_index + 1
        skipped = 0
        while i < len(seq) and len(samples) < n:
            v = seq[i]
            if isinstance(v, (int, float)):
                if skipped < skip_numeric:
                    skipped += 1
                else:
                    samples.append(v)
            i += 1
        if not samples:
            raise ValueError(
                f"No numeric samples found after index={start_index} with skip={skip_numeric}, n={n}"
            )
        return sum(samples) / len(samples)

    results = []
    with open(syslog, "r", encoding="utf-8") as fr:
        lines = fr.readlines()
        for line in lines:
            pattern = re.compile("rfCoolingMode = STARTSLOTBLANKING, tgtMutingRatio = \\d{2}")
            result = pattern.search(line)
            if result and line.split("STARTSLOTBLANKING, ")[1][:-1] not in results:
                results.append(line.split("STARTSLOTBLANKING, ")[1][:-1])
            pattern = re.compile("nrCellId " + str(cur_nr_cell_id) +
                                 " \\[TBS\\|MacCe\\|StatusPdu\\|DataPdu: \\d+\\|\\d+\\|\\d+\\|\\d+\\]")
            result = pattern.search(line)
            if result:
                results.append(int(line.split("|")[-1].split("]")[0]))
    print(results)
    index_20 = results.index("tgtMutingRatio = 20")
    index_38 = results.index("tgtMutingRatio = 38")
    index_53 = results.index("tgtMutingRatio = 53")

    # Use average of multiple samples instead of a single point.
    tp_00_avg = _avg_prev_numeric_samples(results, end_index=index_20, n=20)
    tp_20_avg = _avg_next_numeric_samples(results, start_index=index_20, skip_numeric=5, n=20)
    tp_38_avg = _avg_next_numeric_samples(results, start_index=index_38, skip_numeric=5, n=20)
    tp_53_avg = _avg_next_numeric_samples(results, start_index=index_53, skip_numeric=5, n=20)

    tp_00 = tp_00_avg * 8 / 1000 / 1000
    tp_20 = tp_20_avg * 8 / 1000 / 1000
    tp_38 = tp_38_avg * 8 / 1000 / 1000
    tp_53 = tp_53_avg * 8 / 1000 / 1000
    return tp_00, tp_20, tp_38, tp_53


def analysis_syslog_find_str(syslog_file="2024-10-23_123.txt", target_str="ModifType:START", count=5):
    with open(syslog_file, "r") as fr:
        syslog = fr.read()
        r = re.findall(target_str, syslog)

    found = len(r)
    expected = int(count)
    print(f"found={found}, expected>={expected}, r={r!r}")

    assert found >= expected, (
        "{} is found, The target string '{}' is not enough in the syslog file '{}'".format(
            found, target_str, syslog_file
        )
    )
    return found, r
