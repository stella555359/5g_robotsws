"""cni140003
"""

import logging
import pathlib
import json
import collections
import time

from robot.libraries.BuiltIn import BuiltIn
from testsuite.Ulm.ET.Performance_Test.resources.python import wts_manager
from testsuite.Ulm.ET.Performance_Test.resources.python import wts_wrapper
from testsuite.Ulm.ET.Performance_Test.resources.python import pmcounter_manager
from testsuite.Ulm.ET.Performance_Test.resources.python import perf_log_collection

logger = logging.getLogger(__name__)

rbi = BuiltIn()


def run_cni140003_tc2(args, json_file="cni140003_tc2.json"):
    """cni140003
    """
    args = _initialize_tc2_local_args(args)
    enable_syslog_grep = args.pop("enable_syslog_grep", False)

    start_id_1 = 1
    start_id_2 = 1
    start_id_3 = (int(args["group2_ue_count"]) * int(args["num_cells"])) + 1
    group_logs = {}
    json_data = _get_json_data(json_file, args)
    wts_manager.send_ue_commands_from_json(pathlib.Path(
        __file__).parent.absolute().joinpath("smf_param.json"))

    if json_data.get('group0'):
        group_logs["group0"] = group_runner(
            name="group0",
            egate_commands=json_data["group0"],
            start=start_id_2,
            active_cells=[args['cell_b']],
            ue_count=args["group0_ue_count"],
            num_cells=args["num_cells"],
            expect_ue_count=[args["cell_1_ue_count"], 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            enable_snapshot=True,
            enable_ttitrace=args["enable_ttitrace"],
            sleep_after_egate_cmd=60,
            enable_syslog_grep=enable_syslog_grep
        )

    group_logs["group1"] = group_runner(
        name="group1",
        egate_commands=json_data["group1"],
        start=start_id_1,
        active_cells=[args['cell_a']],
        ue_count=args["group1_ue_count"],
        num_cells=args["num_cells"],
        expect_ue_count=[args["group1_ue_count"], 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        enable_snapshot=True,
        enable_ttitrace=True,
        enable_syslog_grep=enable_syslog_grep
    )

    group_logs["group2"] = group_runner(
        name="group2",
        egate_commands=json_data["group2"],
        start=start_id_2,
        active_cells=[args['cell_b']],
        ue_count=args["group2_ue_count"],
        num_cells=args["num_cells"],
        expect_ue_count=[args["cell_1_ue_count"], 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        enable_snapshot=True,
        enable_ttitrace=True,
        sleep_after_egate_cmd=60,
        enable_syslog_grep=enable_syslog_grep
    )

    group_3_expect_ue_count = [args["cell_1_ue_count"], 0,
                               args["cell_3_ue_count"], 0, 0, 0, 0, 0, 0, 0, 0, 0]
    group_logs["group3"] = group_runner(
        name="group3",
        egate_commands=json_data["group3"],
        start=start_id_3,
        active_cells=[args['cell_b']],
        ue_count=args["group3_ue_count"],
        num_cells=args["num_cells"],
        expect_ue_count=group_3_expect_ue_count,
        enable_snapshot=True,
        enable_ttitrace=True,
        sleep_before_egate_cmd=30,
        enable_syslog_grep=True
    )
    args["expect_ue_count"] = group_3_expect_ue_count
    if json_data.get('group4'):
        group_logs["group4"] = group_runner(
            name="group4",
            egate_commands=json_data["group4"],
            start=start_id_2,
            active_cells=[args['cell_b']],
            ue_count=args["group4_ue_count"],
            num_cells=args["num_cells"],
            expect_ue_count=[0, 0, args["cell_3_ue_count"], 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            enable_snapshot=True,
            enable_ttitrace=True,
            sleep_after_egate_cmd=60,
            enable_syslog_grep=True
        )
        args["expect_ue_count"] = [0, 0, args["cell_3_ue_count"], 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    _save_group_logs_to_turandot(group_logs)
    return args


def run_cni140003_tc5(args):
    args = run_cni140003_tc2(args)
    json_file = pathlib.Path(__file__).parent.parent.parent.absolute().joinpath(
        "json_scenario", "deregister.json")
    rbi.log_to_console("Start Deregister:")
    wts_manager.send_ue_commands_from_json(str(json_file),
                                           start=(
                                               int(args["group2_ue_count"]) * int(args["num_cells"])) + 1,
                                           num_cells=args["num_cells"],
                                           ue_count=args["group3_ue_count"],
                                           active_cells=[args['cell_b']],
                                           delay_per_ue=0.01)
    rbi.run_keyword(
        "performance_snapshot.Collect Snapshot from gnb and save to turandot", "subfolder=deregister")
    table = wts_wrapper.get_ue_count_per_cell_table(
        num_cells=args["num_cells"],
        active_cells=args["active_cells"],
        expected=[args["cell_1_ue_count"], 0, 0, 0, 0, 0, 0, 0, 0]
    )
    rbi.log_to_console(table)
    return args


def run_cni140003_tc15(args):
    """cni140003
    """
    args = _initialize_tc15_local_args(args)
    enable_syslog_grep = args.pop("enable_syslog_grep", False)

    group_logs = {}
    json_data = _get_json_data("cni140003_tc15.json", args)

    wts_manager.send_ue_commands_from_json(pathlib.Path(
        __file__).parent.absolute().joinpath("smf_param.json"))

    group_logs["group1"] = group_runner(
        name="group1",
        egate_commands=json_data["group1"],
        start=1,
        active_cells=[args['cell_a']],
        ue_count=args["group1_ue_count"],
        num_cells=args["num_cells"],
        expect_ue_count=[args["group1_ue_count"],
                         0, 0, 0, 0, 0, 0, 0, 0],
        enable_ttitrace=None,
        enable_syslog_grep=enable_syslog_grep
    )

    group_logs["group2"] = group_runner(
        name="group2",
        egate_commands=json_data["group2"],
        start=1,
        active_cells=[args['cell_b']],
        ue_count=args["group2_ue_count"],
        num_cells=args["num_cells"],
        expect_ue_count=[args["group1_ue_count"],
                         0,
                         args["group2_ue_count"],
                         0, 0, 0, 0, 0, 0],
        enable_snapshot=True,
        enable_ttitrace=args["enable_ttitrace"],
        enable_syslog_grep=enable_syslog_grep
    )

    group_logs["group3"] = group_runner(
        name="group3",
        egate_commands=json_data["group3"],
        start=(int(args["group2_ue_count"]) * int(args["num_cells"])) + 1,
        active_cells=[args['cell_b']],
        ue_count=args["group3_ue_count"],
        num_cells=args["num_cells"],
        expect_ue_count=[(int(args["group1_ue_count"])),
                         0,
                         int(args["group2_ue_count"]) +
                         int(args["group3_ue_count"]),
                         0, 0, 0, 0, 0, 0],
        enable_ttitrace=None,
        enable_syslog_grep=enable_syslog_grep
    )

    group_logs["group4"] = group_runner(
        name="group4",
        egate_commands=json_data["group4"],
        start=(int(args["group1_ue_count"]) * int(args["num_cells"])) + 1,
        active_cells=[args['cell_a']],
        ue_count=args["group4_ue_count"],
        num_cells=args["num_cells"],
        expect_ue_count=[(int(args["group1_ue_count"]) + int(args["group4_ue_count"])),
                         0,
                         int(args["group2_ue_count"]) +
                         int(args["group3_ue_count"]),
                         0, 0, 0, 0, 0, 0],
        enable_snapshot=True,
        sleep_before_egate_cmd=35,
        enable_ttitrace=args["enable_ttitrace"],
        enable_syslog_grep=enable_syslog_grep
    )

    group_logs["step5"] = group_runner(
        name="step5",
        egate_commands=json_data["step56"],
        start=(int(args["group1_ue_count"]) * int(args["num_cells"])) + 1,
        active_cells=[args['cell_a']],
        ue_count=args["group4_ue_count"],
        num_cells=args["num_cells"],
        expect_ue_count=[(int(args["group1_ue_count"]) + int(args["group4_ue_count"])),
                         0,
                         int(args["group2_ue_count"]) +
                         int(args["group3_ue_count"]),
                         0, 0, 0, 0, 0, 0],
        enable_snapshot=True,
        enable_ttitrace=args["enable_ttitrace"],
        sleep_before_egate_cmd=30,
        sleep_after_egate_cmd=30,
        enable_syslog_grep=enable_syslog_grep
    )

    group_logs["step6"] = group_runner(
        name="step6",
        egate_commands=json_data["step56"],
        start=1,
        active_cells=[args['cell_b']],
        ue_count=args["group2_ue_count"],
        num_cells=args["num_cells"],
        expect_ue_count=[args["group1_ue_count"],
                         0,
                         args["group2_ue_count"],
                         0, 0, 0, 0, 0, 0],
        enable_snapshot=True,
        enable_ttitrace=args["enable_ttitrace"],
        sleep_before_egate_cmd=30,
        sleep_after_egate_cmd=120,
        enable_syslog_grep=enable_syslog_grep
    )

    _save_group_logs_to_turandot(group_logs)
    return args


def group_runner(**kwargs):
    group_name = kwargs.pop("name", "default")
    egate_commands = kwargs.pop("egate_commands", {})
    ue_count = kwargs.pop("ue_count", 1)
    start = kwargs.pop("start", 1)
    num_cells = kwargs.pop("num_cells", 1)
    active_cells = kwargs.pop("active_cells", ["all"])
    expect_ue_count = kwargs.pop("expect_ue_count", ["null"])
    enable_snapshot = kwargs.pop("enable_snapshot", False)
    enable_ttitrace = kwargs.pop("enable_ttitrace", None)
    enable_syslog = kwargs.pop("enable_syslog", True)
    continue_on_failure = kwargs.pop("continue_on_failure", True)
    sleep_before_egate_cmd = kwargs.pop("sleep_before_egate_cmd", 0)
    sleep_after_egate_cmd = kwargs.pop("sleep_after_egate_cmd", 0)
    enable_syslog_grep = kwargs.pop("enable_syslog_grep", False)

    for key, value in kwargs.items():
        logger.error("unknown parameter: %s=%s", key, value)

    rbi.log_to_console(f"Running {group_name}: {ue_count} UEs, "
                       f"cell: {active_cells}")
    if enable_syslog:
        rbi.run_keyword_and_warn_on_failure(
            "performance_log_collection.Start SysLog Collection")

    for trf in egate_commands.get("trf_data_start", {}):
        trf_details = f'kbps: {trf.get("kbps", "")}, qfi: {trf.get("qfi", "")}'
        rbi.log_to_console(
            f'[{group_name}] dir: {trf.get("dir", "")} ({trf.get("trf_id", "")}), {trf_details}')

    if enable_ttitrace is not None:
        rbi.log_to_console("Start TTI Trace\n")
        rbi.run_keyword_and_warn_on_failure("performance_ttitrace.Start TTI Trace Collection",
                                            f"nr_phy_cell_ids={enable_ttitrace}",
                                            f"tti_trace_filename=tti_{group_name}")

    rbi.log_to_console(f"sleep_before_egate_cmd: {sleep_before_egate_cmd}")
    time.sleep(sleep_before_egate_cmd)

    rbi.log_to_console("Running Egate Commands")
    try:
        wts_manager.send_ue_commands(
            start=start,
            num_cells=num_cells,
            active_cells=active_cells,
            ue_count=ue_count,
            **egate_commands
        )
    except ute_wtssim.exception.NoRegexpMatch as e:
        if continue_on_failure:
            logger.warning("[FAIL] %s, %s", group_name, e)
        else:
            raise ute_wtssim.exception.NoRegexpMatch from e

    rbi.log_to_console(f"sleep_after_egate_cmd: {sleep_after_egate_cmd}")
    time.sleep(sleep_after_egate_cmd)

    if enable_ttitrace is not None:
        rbi.log_to_console("Stop TTI Trace\n")
        rbi.run_keyword("performance_ttitrace.Stop TTI Trace Collection",
                        f"tti_trace_filename=tti_{group_name}", f"subfolder={group_name}", "compression_flags=--rm")

    if enable_syslog:
        rbi.run_keyword_and_warn_on_failure(
            "performance_log_collection.Stop SysLog Collection", f"subfolder={group_name}")
        if str(enable_syslog_grep).lower() in ['true', '1', 't', 'y', 'yes']:
            for grep in [
                ("PdschMutingUlOve.*Cs1Size:[^50]", "-H -ae"),
                ("TimingPattern750UsEligibilityUpdater", "-H -ae"),
                ("rrmAvgMaxSizeDlCs1BiSlot.*nrCellGrpId..1,", "-H -m 1 -ae"),
                ("rrmAvgMaxSizeDlCs1BiSlot.*nrCellGrpId..3,", "-H -m 1 -ae"),
                ("rrmAvgMaxSizeDlCs1BiSlot.*nrCellGrpId..11,", "-H -m 1 -ae"),
                ("enter state. PATTERN750", "-H -ae"),
            ]:
                _, message = rbi.run_keyword_and_warn_on_failure(
                    "performance_btslog.Btslog Return Regexp", grep[0], f"args={grep[1]}")
                if message:
                    rbi.log_to_console(
                        f"====================\n{grep}\n====================\n")
                    rbi.log_to_console(message)

    table = wts_wrapper.get_ue_count_per_cell_table(
        num_cells=num_cells,
        active_cells=active_cells,
        expected=expect_ue_count
    )
    rbi.run_keyword_and_warn_on_failure(
        'wts_ue.Collect Egate Log Files',
        f'target_dir={group_name}'
    )
    rbi.log_to_console(table)
    if enable_snapshot:
        rbi.run_keyword("performance_snapshot.Collect Snapshot from gnb and save to turandot",
                        f"subfolder={group_name}")
    interval = rbi.run_keyword("pmcounters.Fetch Measurement Period from SCF")
    rbi.log_to_console(f"Wait for PM Counters: {interval/60} minutes")
    pmcounter = rbi.run_keyword('performance_log_collection.Wait and collect one measurement cycle',
                                f"subfolder={group_name}")
    tput = pmcounter_manager.get_pmc_tput_as_table(
        pmcounter, interval=interval)
    rbi.log_to_console(f"PM Counter:\n{tput}\n")
    return {
        "pmcounter": pmcounter
    }


def _save_group_logs_to_turandot(group_logs):
    logger.debug("_save_group_logs_to_turandot")
    for gr, logs in group_logs.items():
        for log, path in logs.items():
            logger.debug("group: %s, log: %s, path: %s", gr, log, path)
            log_path = pathlib.Path(path)
            log_path = f"{str(log_path)}/*" if log_path.is_dir() else str(log_path)
            perf_log_collection.queue_logs_to_turandot(
                log_path, archive_name=log, subfolder=gr, tar=True
            )


def _get_json_data(json_file, args):
    custom_file = pathlib.Path(args["workspace"]).joinpath(
        "archive", "scenario.json")
    json_file = pathlib.Path(
        __file__).parent.absolute().joinpath(json_file)
    if custom_file.is_file():
        rbi.log(f"using {custom_file}", console=True)
        json_file = custom_file
    with open(json_file, "r", encoding="utf-8") as read_stream:
        return json.load(read_stream, object_pairs_hook=collections.OrderedDict)


def _initialize_tc2_local_args(args):
    default_values = {
        "group1_ue_count": 100,
        "group2_ue_count": 20,
        "group3_ue_count": 200,
    }
    for key, value in default_values.items():
        if key not in args:
            args[key] = value if key not in args else int(args[key])

    args.update({
        "cell_1_ue_count": int(args["group1_ue_count"]) + int(args["group2_ue_count"]),
        "cell_3_ue_count": int(args["group3_ue_count"])
    })
    args.update({
        "expect_ue_count": [args["cell_1_ue_count"], 0, args["cell_3_ue_count"], 0, 0, 0, 0, 0, 0]
    })
    if args["cell_max_ue"] == "null":
        args.update({
            "cell_max_ue": [args["cell_1_ue_count"], 0, args["cell_3_ue_count"], 0, 0, 0, 0, 0, 0]
        })
    return args


def _initialize_tc15_local_args(args):
    default_values = {
        "group1_ue_count": 65,
        "group2_ue_count": 165,
        "group3_ue_count": 65,
        "group4_ue_count": 165,
    }
    for key, value in default_values.items():
        if key not in args:
            args[key] = value if key not in args else int(args[key])

    args.update({
        "cell_1_ue_count": int(args["group1_ue_count"]) + int(args["group4_ue_count"]),
        "cell_3_ue_count": int(args["group2_ue_count"]) + int(args["group3_ue_count"])
    })
    args.update({
        "expect_ue_count": [args["cell_1_ue_count"], 0, args["cell_3_ue_count"], 0, 0, 0, 0, 0, 0]
    })
    if args["cell_max_ue"] == "null":
        args.update({
            "cell_max_ue": [args["cell_1_ue_count"], 0, args["cell_3_ue_count"], 0, 0, 0, 0, 0, 0]
        })
    return args
