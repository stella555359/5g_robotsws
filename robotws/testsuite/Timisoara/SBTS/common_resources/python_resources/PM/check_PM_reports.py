import re
import xml.etree.ElementTree as ET
from typing import Dict, Tuple, Set, List, Optional, Union
from robot.api import logger

TECH_PREFIXES = {
    "NR": "M55",
    "LTE": "M80",
    "WCDMA": "M50",
    "TNL": "M51",
}


def _normalize_counter_exception(counter_exception: Optional[Union[str, List[str]]]) -> Set[str]:
    """
    Normalize counter_exception input to a set of counter codes.
    Supported formats:
      - None
      - comma separated string: "M8092C0,M8092C1"
      - list of strings: ["M8092C0", "M8092C1"]
    returns:
      set of counters that are allowed to have different DN without failing the test
    """
    if not counter_exception:
        return set()

    if isinstance(counter_exception, str):
        return {item.strip() for item in counter_exception.split(",") if item.strip()}

    return {str(item).strip() for item in counter_exception if str(item).strip()}


def _is_bbpool_dn(dn: str) -> bool:
    """
    Return True if DN contains BBPOOL object.
    Example:
      PLMN-PLMN/MRBTS-10339/BBPOOL-36
    """
    return "/BBPOOL-" in dn


def _is_bbpool_change(dns_before: List[str], dns_after: List[str]) -> bool:
    """
    Return True only if all DN values before and after belong to BBPOOL objects.
    """
    return (
        bool(dns_before)
        and bool(dns_after)
        and all(_is_bbpool_dn(dn) for dn in dns_before)
        and all(_is_bbpool_dn(dn) for dn in dns_after)
    )


def _parse_xml_metrics(xml_path: str) -> Dict[Tuple[str, str], Set[str]]:
    """
    Parse xml_path provided
    returns:
      (measurementType, metricCode) -> set(DN)
    """
    metric_tag_re = re.compile(r"^M\d+[A-Z]\d+$")
    tree = ET.parse(xml_path)
    root = tree.getroot()

    metrics: Dict[Tuple[str, str], Set[str]] = {}

    for pmres in root.findall(".//PMMOResult"):
        dn_elem = pmres.find(".//MO/DN")
        dn = (dn_elem.text.strip() if dn_elem is not None and dn_elem.text else "").strip()
        if not dn:
            continue

        for child in pmres:
            tag = child.tag
            if not (isinstance(tag, str) and tag.startswith("NE-")):
                continue

            mtype = child.attrib.get("measurementType", "").strip()
            if not mtype:
                continue

            for metric_elem in child:
                mtag = metric_elem.tag
                if not (isinstance(mtag, str) and metric_tag_re.match(mtag)):
                    continue

                key = (mtype, mtag)
                metrics.setdefault(key, set()).add(dn)

    return metrics


def _find_multi_dn(metrics: Dict[Tuple[str, str], Set[str]]) -> List[Tuple[str, str, List[str]]]:
    """
    returns list:
      (measurementType, metricCode, sorted_dns)
    where metric appears on multiple DN in the same file
    """
    out = []
    for (mtype, code), dns in metrics.items():
        if len(dns) > 1:
            out.append((mtype, code, sorted(dns)))
    out.sort()
    return out


def _get_dn_differences(
        metrics1: Dict[Tuple[str, str], Set[str]],
        metrics2: Dict[Tuple[str, str], Set[str]],
) -> List[Tuple[str, str, List[str], List[str]]]:
    """
    returns list:
      (measurementType, metricCode, dns_file1, dns_file2)
    for common metrics where DN differ between files
    """
    out = []
    common_keys = set(metrics1.keys()) & set(metrics2.keys())
    for k in common_keys:
        dns1 = metrics1[k]
        dns2 = metrics2[k]
        if dns1 != dns2:
            mtype, code = k
            out.append((mtype, code, sorted(dns1), sorted(dns2)))
    out.sort()
    return out


def _group_metrics_by_technology(metrics: Dict[Tuple[str, str], Set[str]]) -> Dict[str, List[Tuple[str, str]]]:
    """
    group all counters in a file by technology prefix
    returns:
      tech -> list of (measurementType, metricCode)
    """
    grouped = {}

    for tech in TECH_PREFIXES.keys():
        grouped[tech] = []

    grouped["OTHER"] = []

    for (mtype, code) in metrics.keys():
        matched = False
        for tech, prefix in TECH_PREFIXES.items():
            if code.startswith(prefix):
                grouped[tech].append((mtype, code))
                matched = True
                break
        if not matched:
            grouped["OTHER"].append((mtype, code))

    for tech in grouped:
        grouped[tech].sort(key=lambda x: x[1])

    return grouped


def _group_dn_differences_by_technology(
        changed: List[Tuple[str, str, List[str], List[str]]]
) -> Dict[str, List[Tuple[str, str]]]:
    """
    group only dn-changed counters by technology prefix
    returns:
      tech -> list of (measurementType, metricCode)
    """
    grouped = {}

    for tech in TECH_PREFIXES.keys():
        grouped[tech] = []

    grouped["OTHER"] = []

    for mtype, code, _, _ in changed:
        matched = False
        for tech, prefix in TECH_PREFIXES.items():
            if code.startswith(prefix):
                grouped[tech].append((mtype, code))
                matched = True
                break
        if not matched:
            grouped["OTHER"].append((mtype, code))

    for tech in grouped:
        grouped[tech].sort(key=lambda x: x[1])

    return grouped


def _get_metric_differences(
        metrics1: Dict[Tuple[str, str], Set[str]],
        metrics2: Dict[Tuple[str, str], Set[str]],
) -> Tuple[List[str], List[str]]:
    """
    arguments:
          metrics1: key=Tuple(mtype, code), value=distNames
          metrics2: key=Tuple(mtype, code), value=distNames
    return:
          metric codes differences from both files
          (missing_in_file2, missing_in_file1)
    """
    codes1 = {code for _, code in metrics1.keys()}
    codes2 = {code for _, code in metrics2.keys()}

    code_missing_in_file2 = sorted(list(codes1 - codes2))
    code_missing_in_file1 = sorted(list(codes2 - codes1))

    return code_missing_in_file2, code_missing_in_file1


def _write_dn_difference_details_to_report(
        report_handle,
        title: str,
        dn_differences: List[Tuple[str, str, List[str], List[str]]],
) -> None:
    """
    Write detailed DN differences section to report file.
    Used for both FAIL differences and WARN/exception differences.
    """
    report_handle.write(f"{title}\n")
    report_handle.write("-" * len(title) + "\n\n")

    if not dn_differences:
        report_handle.write("None\n\n")
        return

    grouped = {}
    for mtype, code, dns_before, dns_after in dn_differences:
        grouped.setdefault(mtype, []).append((code, dns_before, dns_after))

    for mtype in sorted(grouped.keys()):
        items = grouped[mtype]
        items.sort(key=lambda x: x[0])

        report_handle.write("=" * 90 + "\n")
        report_handle.write(f"measurementType: {mtype}   (affected counters: {len(items)})\n")
        report_handle.write("=" * 90 + "\n\n")

        for idx, (code, dns_before, dns_after) in enumerate(items, start=1):
            set_before = set(dns_before)
            set_after = set(dns_after)

            removed = sorted(set_before - set_after)
            added = sorted(set_after - set_before)

            report_handle.write(f"{idx}. counter: {code}\n\n")
            report_handle.write(f"   DN count in file BEFORE reset : {len(dns_before)}\n")
            report_handle.write(f"   DN count in file AFTER  reset : {len(dns_after)}\n\n")

            report_handle.write(
                f"   DNs missing AFTER reset "
                f"(present in BEFORE, not found AFTER): {len(removed)}\n"
            )
            report_handle.write(
                f"   DNs added   AFTER reset "
                f"(not present in BEFORE, found AFTER): {len(added)}\n\n"
            )

            report_handle.write("   dn missing after:\n")
            if removed:
                for dn in removed:
                    report_handle.write(f"     - {dn}\n")
            else:
                report_handle.write("     - (none)\n")

            report_handle.write("\n   dn new after:\n")
            if added:
                for dn in added:
                    report_handle.write(f"     - {dn}\n")
            else:
                report_handle.write("     - (none)\n")

            report_handle.write("\n")

        report_handle.write("\n")


def _get_and_write_test_verdict_in_txt_file(
        has_issues: bool,
        multi_dn1: List[Tuple[str, str, List[str]]],
        multi_dn2: List[Tuple[str, str, List[str]]],
        dn_differences_fail: List[Tuple[str, str, List[str], List[str]]],
        dn_differences_warn: List[Tuple[str, str, List[str], List[str]]],
        metric_missing_in_file2: List[str],
        metric_missing_in_file1: List[str],
        metric_count_file1: int,
        metric_count_file2: int,
        first_xml_file: str,
        second_xml_file: str,
        tech_counts_file1: Dict[str, int],
        tech_counts_file2: Dict[str, int],
        metric_differences_counts_on_tech: Dict[str, int],
        report_file: str,
) -> Tuple[bool, str]:
    """
    always writes in report_file txt.
    returns:
      (True, ok_message) or (False, fail_message)
    """
    with open(report_file, "w", encoding="utf-8") as f:
        f.write("DN/ObjectID diff report\n")
        f.write("=======================\n\n")

        f.write("Summary\n")
        f.write("-------\n")
        f.write(f"file1 path: {first_xml_file}\n")
        f.write(f"file2 path: {second_xml_file}\n\n")
        f.write(f"counters in file1: {metric_count_file1}\n")
        f.write(f"counters in file2: {metric_count_file2}\n")
        f.write(f"DN count in file1: {len(multi_dn1)}\n")
        f.write(f"DN count in file2: {len(multi_dn2)}\n")
        f.write(f"DN changed count (FAIL): {len(dn_differences_fail)}\n")
        f.write(f"DN changed count (WARN): {len(dn_differences_warn)}\n")
        f.write(f"DN changed exists: {has_issues}\n\n")

        f.write("Counters by Technology\n")
        f.write("----------------------\n")
        for tech in list(TECH_PREFIXES.keys()) + ["OTHER"]:
            f.write(
                f"{tech}: file1={tech_counts_file1.get(tech, 0)}  "
                f"file2={tech_counts_file2.get(tech, 0)}  "
                f"dn_differences={metric_differences_counts_on_tech.get(tech, 0)}\n"
            )
        f.write("\n")

        if not has_issues:
            f.write("result: OK\n")
            f.write("----------------------\n")
            if dn_differences_warn:
                f.write(
                    "Counters are the same and no non-excepted counter is reported on a different object.\n"
                    "Only exception counters were found with different DN and were reported as WARN.\n\n"
                )
            else:
                f.write("Counters are the same and no counter is reported on a different object.\n\n")
        else:
            f.write("result: FAIL\n\n")
            f.write("----------------------\n")
            f.write(f"missing counters in file1: {metric_missing_in_file1}\n")
            f.write(f"missing counters in file2: {metric_missing_in_file2}\n")
            f.write("----------------------\n")
            f.write(f"{len(dn_differences_fail)} counters are reported on different objects after reset (FAIL).\n")
            f.write(f"{len(dn_differences_warn)} counters are reported on different objects after reset (WARN).\n\n")

        _write_dn_difference_details_to_report(
            report_handle=f,
            title="FAIL differences (non-excepted counters)",
            dn_differences=dn_differences_fail,
        )

        _write_dn_difference_details_to_report(
            report_handle=f,
            title="WARN differences (excepted counters)",
            dn_differences=dn_differences_warn,
        )

    if not has_issues:
        msg = (
            "Result: OK\n"
            f"Counters in file1: {metric_count_file1}\n"
            f"Counters in file2: {metric_count_file2}\n"
            f"Missing counters in file1: {len(metric_missing_in_file1)}\n"
            f"Missing counters in file2: {len(metric_missing_in_file2)}\n"
            f"DN differences (FAIL): {len(dn_differences_fail)}\n"
            f"DN differences (WARN): {len(dn_differences_warn)}\n"
        )
        if multi_dn1:
            msg += f"{len(multi_dn1)} counters are reported on multiple objects in file1.\n"
        if multi_dn2:
            msg += f"{len(multi_dn2)} counters are reported on multiple objects in file2.\n"
        if dn_differences_warn:
            msg += f"{len(dn_differences_warn)} exception counters are reported on different objects (WARN).\n"
        msg += f"Detailed report saved in: {report_file}"
        return True, msg

    msg = (
        "Result: FAIL\n"
        f"Missing counters in file1: {len(metric_missing_in_file1)}\n"
        f"Missing counters in file2: {len(metric_missing_in_file2)}\n"
        f"DN differences (FAIL): {len(dn_differences_fail)}\n"
        f"DN differences (WARN): {len(dn_differences_warn)}\n"
        f"Counters in file1: {metric_count_file1}\n"
        f"Counters in file2: {metric_count_file2}\n"
        f"Detailed report saved in: {report_file}"
    )
    return False, msg


def check_counters_differences_in_PM_files(
        first_xml_file: str,
        second_xml_file: str,
        txt_file_name: str,
        counter_exception: Optional[Union[str, List[str]]] = None,
) -> None:
    """
    main function called in robot file

    arguments:
        first_xml_file: first xml path to PM report
        second_xml_file: second xml path to PM report
        txt_file_name: file which contains differences between the two PM reports
        counter_exception: counters allowed to have different DN without failing the test

    behavior:
        writes txt report to txt_file_name
        raises AssertionError if differences are found for non-excepted counters
        returns normally if ok or only exception counters have different DN
    """
    metrics1 = _parse_xml_metrics(first_xml_file)
    metrics2 = _parse_xml_metrics(second_xml_file)
    report_file = txt_file_name

    exception_counters = _normalize_counter_exception(counter_exception)

    multi_dn1 = _find_multi_dn(metrics1)
    multi_dn2 = _find_multi_dn(metrics2)

    metric_missing_in_file2, metric_missing_in_file1 = _get_metric_differences(metrics1, metrics2)
    metric_changed = bool(metric_missing_in_file2 or metric_missing_in_file1)

    dn_differences = _get_dn_differences(metrics1, metrics2)

    dn_differences_fail = []
    dn_differences_warn = []

    for diff in dn_differences:
        mtype, code, dns_before, dns_after = diff
        if code in exception_counters and _is_bbpool_change(dns_before, dns_after):
            dn_differences_warn.append((mtype, code, dns_before, dns_after))
        else:
            dn_differences_fail.append((mtype, code, dns_before, dns_after))

    dn_changed = bool(dn_differences_fail)
    has_issues = bool(metric_changed or dn_changed)

    metrics1_grouped_by_tech = _group_metrics_by_technology(metrics1)
    metrics2_grouped_by_tech = _group_metrics_by_technology(metrics2)
    metrics_differences_grouped_by_tech = _group_dn_differences_by_technology(dn_differences_fail)

    tech_counts_file1 = {}
    for tech, items in metrics1_grouped_by_tech.items():
        tech_counts_file1[tech] = len(items)

    tech_counts_file2 = {}
    for tech, items in metrics2_grouped_by_tech.items():
        tech_counts_file2[tech] = len(items)

    metric_differences_counts_on_tech = {}
    for tech, items in metrics_differences_grouped_by_tech.items():
        metric_differences_counts_on_tech[tech] = len(items)

    metric_count_file1 = len(metrics1)
    metric_count_file2 = len(metrics2)

    logger.info('Checking PM reports...')
    logger.info('Counters in file1: {}'.format(metric_count_file1))
    logger.info('Counters in file2: {}'.format(metric_count_file2))

    logger.info('Counters by technology in file1:')
    for tech in list(TECH_PREFIXES.keys()) + ["OTHER"]:
        logger.info('{}: {}'.format(tech, tech_counts_file1.get(tech, 0)))

    logger.info('Counters by technology in file2:')
    for tech in list(TECH_PREFIXES.keys()) + ["OTHER"]:
        logger.info('{}: {}'.format(tech, tech_counts_file2.get(tech, 0)))

    if multi_dn1:
        logger.info('Note: {} counters are reported on multiple objects in file1.'.format(len(multi_dn1)))
    if multi_dn2:
        logger.info('Note: {} counters are reported on multiple objects in file2.'.format(len(multi_dn2)))

    if metric_missing_in_file1:
        logger.info('Missing counters in file1 count: {}'.format(len(metric_missing_in_file1)))
    if metric_missing_in_file2:
        logger.info('Missing counters in file2 count: {}'.format(len(metric_missing_in_file2)))

    if dn_differences_warn:
        for mtype, code, dns_before, dns_after in dn_differences_warn:
            logger.warn(
                '[WRN] Counter {} has different DN after reset only between BBPOOL objects. '
                'measurementType={} BEFORE={} AFTER={}'.format(code, mtype, dns_before, dns_after)
            )

    ok, verdict_msg = _get_and_write_test_verdict_in_txt_file(
        has_issues=has_issues,
        multi_dn1=multi_dn1,
        multi_dn2=multi_dn2,
        dn_differences_fail=dn_differences_fail,
        dn_differences_warn=dn_differences_warn,
        metric_missing_in_file2=metric_missing_in_file2,
        metric_missing_in_file1=metric_missing_in_file1,
        metric_count_file1=metric_count_file1,
        metric_count_file2=metric_count_file2,
        tech_counts_file1=tech_counts_file1,
        tech_counts_file2=tech_counts_file2,
        metric_differences_counts_on_tech=metric_differences_counts_on_tech,
        first_xml_file=first_xml_file,
        second_xml_file=second_xml_file,
        report_file=report_file,
    )
    logger.info(verdict_msg)

    if not ok:
        raise AssertionError(verdict_msg)


__all__ = ["check_counters_differences_in_PM_files"]
