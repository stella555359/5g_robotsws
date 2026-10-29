import argparse
import re
import os
import json
import glob
import sys
import subprocess
import shutil
from datetime import datetime
from multiprocessing import Pool, Value
from context import Context, ExceptionNotNeedToSendByMail
from report import Report
from save_file import SaveFile
from time_marker_kpi_file import TimeMarkerKPIFile

SUPPORT_MESSAGE = (
    "For any support, contact I_MN_5GSC_SW_ENG_PERF_SERVER@groups.nokia.com\n"
    "Find performance portal at https://app.powerbi.com/"
    "groups/me/apps/4b451a02-844c-47b2-bd6b-e43667c7cf16"
)

PERF_OBJ = None

ENDURANCE_FILTER_LIST = [r"_CFG_SA_LA_HARQ_REF(_BENCHMARK)?$"]

RC_IGNORE_ALARM = 0
RC_MAJOR_CHECK_ALARM = 1
RC_BAD_ARGS = 2
RC_SRUNNER_FILE_NOT_FOUND = 10
RC_NO_SNAPSHOT_FILE = 11

RETURN_CODE_MESSAGE = {
    RC_IGNORE_ALARM: "Alarm ignored",
    RC_MAJOR_CHECK_ALARM: "Critical Alarm detected",
    RC_BAD_ARGS: "Argument error during perf_portal.py calling",
    RC_SRUNNER_FILE_NOT_FOUND: "SRunnner file: perf_portal.json not found",
    RC_NO_SNAPSHOT_FILE: "No snapshot file found",
}


def filter_before_run():

    zuul_pipeline = os.getenv("ZUUL_PIPELINE", "None")
    job_base_name = os.getenv("JOB_BASE_NAME", "None")
    job_name = os.getenv("JOB_NAME", "None")
    metrics_ignore = os.getenv("METRICS_IGNORE", "None")

    print("Perf_portal.filter_before_run use: ", flush=True)
    print(f"PYTHON VERSION: {sys.version}", flush=True)
    print(f"zuul_pipeline:{zuul_pipeline}", flush=True)
    print(f"job_base_name:{job_base_name}", flush=True)
    print(f"job_name:{job_name}", flush=True)
    print(f"metrics_ignore:{metrics_ignore}", flush=True)

    filter_run = zuul_pipeline.lower() not in ["none", "cont"] or metrics_ignore in (True, "true")
    print(f"Need to execute Perf_portal: {not filter_run}", flush=True)
    return filter_run


def init_perf_obj(perf_obj):
    global PERF_OBJ
    PERF_OBJ = perf_obj


def parallelize_ref_file(file):
    PERF_OBJ.context.db_disconnect()
    return PERF_OBJ.parallelize_one_ref_file(file)


class ArgList(list):
    def __contains__(self, other, exactly=True):
        num = 0
        for item in self:
            if (exactly and other.lower() == item.lower()) or (
                not exactly and other.lower() in item.lower()
            ):
                num += 1
            if num > 1:
                return False
        if exactly and num == 0:
            return self.__contains__(other, exactly=False)
        return num == 1

    def find(self, other, exactly=True):
        if not other:
            return other

        for item in self:
            if (exactly and other.lower() == item.lower()) or (
                not exactly and other.lower() in item.lower()
            ):
                return item
        if exactly:
            return self.find(other, exactly=False)
        return None


class PerfPortal:
    @staticmethod
    def parse():
        # Now only for ET but save old value
        # ["Precheck", "Check", "Gate", "Post", "Continuous", "Endurance", "Manual", "ET"]
        test_type_arg_list = ArgList(["Manual", "ET"])
        parser = argparse.ArgumentParser(
            description="Parse Time Marker JSON files and populate mysql database for Power BI"
        )
        reg_exclu_src = parser.add_mutually_exclusive_group(required=True)
        reg_exclu_src.add_argument("--dirKpi", help="Directory where TimeMarkerKPI JSON file")
        reg_exclu_src.add_argument(
            "--replay", help="repopulate database form json file", action="store_true"
        )
        parser.add_argument("--fileJunit", help="Junit-report xml file", default="junit-report.xml")
        parser.add_argument("--softwareBranch", default="master", help="Software GIT branch")
        parser.add_argument("--softwareCommit", help="Software commit name")
        parser.add_argument("--noMultiProcess", default=False, action="store_true")
        parser.add_argument("--extended", default=False, action="store_true")

        reg_exclu_group = parser.add_mutually_exclusive_group(required=True)
        reg_exclu_group.add_argument("--fileKpi", help="TimeMarkerKPI JSON file")
        reg_exclu_group.add_argument("--testType", choices=test_type_arg_list, help="Test Type")
        parser.add_argument("--userCSL", help="Provide userCSL if test is run manually")

        args = parser.parse_args()
        args.testType = test_type_arg_list.find(args.testType)

        if args.dirKpi and not args.testType:
            parser.error("argument --testType is mandatory with --dirKpi option")
        if args.dirKpi and not args.softwareCommit:
            parser.error("argument --softwareCommit is mandatory with --dirKpi option")
        if args.replay and not args.fileKpi:
            parser.error("argument --fileKpi is mandatory with --replay option")

        return vars(args)

    def update_file_params(self, file_type, compress=True):
        commit_ref = self.params["softwareCommit"][:7]
        if self.params[file_type]:
            file_name, file_extension = os.path.splitext(self.params[file_type])
            self.params[file_type] = os.path.basename(
                f"{file_name}_{self.test_date.strftime('%Y.%m.%d_%H.%M.%S')}_"
                f"{commit_ref}{file_extension}"
            )
            if compress:
                self.params[file_type] += ".xz"

    def update_extended_script_param(self):
        if "KPImode" in self.kpi_file_content["header"]:
            self.params["extended"] = self.kpi_file_content["header"]["KPImode"] == "extended"

    def copy_script_param_into_header(self):
        self.kpi_file_content["header"]["scriptParam"] = self.params
        del self.kpi_file_content["header"]["scriptParam"]["replay"]
        del self.kpi_file_content["header"]["scriptParam"]["fileJunit"]
        del self.kpi_file_content["header"]["scriptParam"]["dirKpi"]
        del self.kpi_file_content["header"]["scriptParam"]["softwareCommit"]

        if "softwareCommitDate" in self.params:
            self.kpi_file_content["header"]["snapshotData"]["gnbCommitDate"] = self.params[
                "softwareCommitDate"
            ]
            del self.kpi_file_content["header"]["scriptParam"]["softwareCommitDate"]

    def store_params_in_kpifile(self, file_kpi):
        with open(file_kpi, mode="w") as f_h:
            json.dump(self.kpi_file_content, f_h, indent=2)

    def save_file(self, filename, dest_filename, compress=True):
        if filename:
            directory = self.test_date.strftime("%Y/%m/%d/%H.%M.%S")
            print(
                f"saving file: {filename} to remote {directory}/"
                f"{dest_filename} compress={compress} - perf_index: {self.file_index}",
                flush=True,
            )
            SaveFile().save(directory, filename, dest_filename, compress)

    def keep_snapshot(self):
        return self.params["testType"] != "Endurance"

    def is_extended_needed(self):
        if self.params["testType"] == "Continuous" or self.params["extended"]:
            return True

        return False

    def is_check_threshold(self):
        no_check_test_type = ["Endurance", "Continuous", "Manual"]
        if (
            os.environ.get("JOB_BASE_NAME") == "SCT.wip.abil"
            or self.params["testType"] in no_check_test_type
        ):
            return False

        return not self.params["replay"]

    def is_insert_into_db(self):
        return self.params["testType"] not in ["Precheck", "Check", "Gate"]

    def is_save_file(self):
        return self.is_insert_into_db() and (
            self.params["userCSL"] is None
            or (self.params["userCSL"] and self.params["testType"] == "Endurance")
        )

    def is_send_comment_to_gerrit(self):
        return self.is_check_threshold() and self.params["testType"] not in [
            "Continuous",
            "Manual",
            "ET",
        ]

    def get_srunner_result_file_param(self, param_name):
        return self.srunner_result_file_content[self.current_ref_file][param_name]

    def set_srunner_result_file_param(self, param_name, param_value):
        self.srunner_result_file_content[self.current_ref_file][param_name] = param_value

    def generate_srunner_test_info(self):
        test_config_dict = {"board": self.get_srunner_result_file_param("Board")}
        test_name = "_".join(
            filter(
                None,
                [
                    self.get_srunner_result_file_param("TestName"),
                    self.get_srunner_result_file_param("VariantName"),
                ],
            )
        )

        (feature, cc_number, ue_number, dd_type, tti_duration, cfg_key) = re.search(
            r".*(?P<ft>(ft|cni|cb|tranrob).+)_(?P<cc>\d+)CC_(?P<ue>\d+)UE_"
            r"(?P<dd>[^\d]+)(?P<tti>\d+)(.*_CFG_(?P<cfg>.*))*",
            test_name,
        ).group("ft", "cc", "ue", "dd", "tti", "cfg")
        test_config_dict.update(
            {
                "feature": feature,
                "CCNumber": cc_number,
                "UENumber": ue_number,
                "DDtype": dd_type,
                "TTIDuration": tti_duration,
                "configKey": cfg_key,
                "testNameConfig": test_name,
            }
        )
        self.set_srunner_result_file_param("config", test_config_dict)

    def get_decode_option_list(self):
        decode_option_list = list()
        self.generate_srunner_test_info()
        decode_option_list += self.context.get_configure_option_list(
            self.get_srunner_result_file_param("config")
        )

        if "--extend" not in decode_option_list and self.is_extended_needed():
            decode_option_list.append("--extended")

        decode_option_list.append("--betaVersion")

        return decode_option_list

    def launch_decode_snapshot(self, snapshot_file):
        self.decode_snapshot_send_message = True
        print(f"decode snapshot active - perf_index: {self.file_index}", flush=True)

        decode_args = [
            "timeMarker/tools/TimeMarkerKPI/script/launch.sh",
            "--gnbCommit",
            self.params["softwareCommit"],
            "--kpiVersion",
            "2",
        ]
        decode_args += self.get_decode_option_list()
        decode_args.append(snapshot_file)

        print(f"TimeMarker decode cmd: {decode_args} - perf_index: {self.file_index}", flush=True)

        proc = subprocess.run(
            decode_args,
            check=False,
            universal_newlines=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        if proc.returncode:
            if (
                self.params["testType"] == "Endurance"
                or "KPI ALGORITHM DID NOT FIND ANY L2PSDL OR L2PSUL LOGGER IN SNAPSHOT!"
                in str(proc.stderr)
                or "snapshot.SnapshotFileName.SnapshotFileNameError" in str(proc.stderr)
            ):
                self.decode_snapshot_send_message = False
                print(f"TimeMarker Decoder return {proc.returncode}, trace:\n{proc.stderr}")

            raise subprocess.CalledProcessError(
                proc.returncode, "TimeMarker Decoder", stderr=proc.stderr
            )

        print(f"TimeMarker decode done - perf_index: {self.file_index}", flush=True)

    def update_feature_and_config_param(self):
        self.params["feature"] = self.get_srunner_result_file_param("config")["feature"]
        self.params["config"] = self.get_srunner_result_file_param("config")["configKey"]
        self.params["testNameConfig"] = self.get_srunner_result_file_param("config")[
            "testNameConfig"
        ]

    def manage_one_test_result(self):
        file_kpi_full = self.params["fileKpi"]
        file_snapshot_full = self.params["fileSnapshot"]

        with open(file_kpi_full, mode="r") as f_h:
            self.kpi_file_content = json.load(f_h)

        if not self.params["replay"]:
            self.update_extended_script_param()

            self.update_file_params("fileKpi", compress=False)
            self.update_file_params("fileSnapshot")
            self.params["testDate"] = self.test_date.isoformat().split(".")[0]

            self.update_feature_and_config_param()
            self.copy_script_param_into_header()

            if self.is_save_file():
                try:
                    self.save_file(file_snapshot_full, self.params["fileSnapshot"])
                except Exception:
                    self.params["fileSnapshot"] = None

                self.store_params_in_kpifile(file_kpi_full)
                self.save_file(file_kpi_full, self.params["fileKpi"], compress=False)

        print(f"TimeMarkerKPIFile object creation - perf_index: {self.file_index}", flush=True)
        TimeMarkerKPIFile(self.kpi_file_content, self.context).compute_kpi_file()
        print(f"TimeMarkerKPIFile computed - perf_index: {self.file_index}", flush=True)

    def parallelize_one_ref_file(self, ref_file):
        self.file_index = self.ref_file_list.index(ref_file) + 1
        print(f"### File: {ref_file} - perf_index: {self.file_index}", flush=True)
        self.current_ref_file = ref_file

        try:
            if not self.params["replay"]:
                self.params["testStatus"] = self.get_srunner_result_file_param("Verdict")

                self.launch_decode_snapshot(ref_file)

                self.params["fileSnapshot"] = ref_file if self.keep_snapshot() else None

                kpi_file_list = glob.glob(ref_file.replace("TimeMarkerSnapshot", "TimeMarkerKPIv2"))
                if not kpi_file_list:
                    raise FileNotFoundError(f"No KPI file found for {ref_file}")

                self.params["fileKpi"] = kpi_file_list[0]

            self.manage_one_test_result()
        except ExceptionNotNeedToSendByMail as exc:
            print(
                "WARNING an error occur but eror mail will not be sent for:"
                f" perf_index: {self.file_index} => {exc}",
                flush=True,
            )

            with self.file_error_counter.get_lock():
                self.file_error_counter.value += 1

        except Exception as exc:
            if self.params["testStatus"] == "FAILED" or not self.decode_snapshot_send_message:
                print(
                    f"WARNING an error occur but test status is FAILED or NA for endurance: {exc}"
                    f" - perf_index: {self.file_index}",
                    flush=True,
                )
            else:
                Report().error(
                    exc.stderr if isinstance(exc, subprocess.CalledProcessError) else None
                )

            with self.file_error_counter.get_lock():
                self.file_error_counter.value += 1

        self.params = self.saved_params.copy()

    def get_srunner_result(self, lookup_dir):
        with open(f"{lookup_dir}/perf_portal.json") as f_h:
            srunner_result_list = json.load(f_h)

        for result in srunner_result_list:
            if result["timeMarkerSnapshotPresent"] and (
                self.params["testType"] == "Endurance" or result["Last"]
            ):
                if result["timeMarkerSnapshotPath"].startswith(lookup_dir):
                    snap_file = result["timeMarkerSnapshotPath"]
                else:
                    snap_file = f'{lookup_dir}/{result["timeMarkerSnapshotPath"]}'

                self.srunner_result_file_content[snap_file] = result

        return self.srunner_result_file_content.keys()

    def filter_endurance_test_name(self, filename):
        if self.params["testType"] == "Endurance":
            test_name_variant = ".".join(
                [
                    self.srunner_result_file_content[filename]["TestName"],
                    self.srunner_result_file_content[filename]["VariantName"],
                ]
            )

            for filename_filter in ENDURANCE_FILTER_LIST:
                if re.search(filename_filter, test_name_variant):
                    return True
            return False
        return True

    def get_file_list(self, lookup_dir):
        result_list = self.get_srunner_result(lookup_dir)
        return list(filter(self.filter_endurance_test_name, result_list))

    def manage_one_directory(self):

        try:
            self.params["softwareCommitDate"] = self.context.get_commit_date(
                self.params["softwareCommit"]
            )
        except ValueError:
            self.params["softwareCommitDate"] = self.test_date.strftime("%Y-%m-%dT%H:%M:%S")
            print(
                f"commit {self.params['softwareCommit']} "
                "is not a real one so test date is used as commit date"
            )

        lookup_dir = os.path.abspath(self.params["dirKpi"])
        self.params["dirKpi"] = None

        try:
            self.ref_file_list = self.get_file_list(lookup_dir)
        except Exception:
            basename = os.getenv("JOB_BASE_NAME", "None")
            if basename and "wip" in basename:
                sys.exit(RC_IGNORE_ALARM)

            sys.exit(RC_SRUNNER_FILE_NOT_FOUND)

        if not self.ref_file_list:
            print(
                f"Warning: No TimeMarker file found into {lookup_dir}/perf_portal.json",
                flush=True,
            )
            # todo: ready to block jobs if no timemarker files found
            # sys.exit(RC_NO_SNAPSHOT_FILE)
            return

        self.context.clone_time_marker()

        self.saved_params = self.params.copy()

        if self.multiprocess:
            nb_process = 8 if os.cpu_count() == 2 and self.is_save_file() else os.cpu_count()
            if __name__ == "__main__":
                child_pool = Pool(
                    processes=nb_process,
                    maxtasksperchild=1,
                    initializer=init_perf_obj,
                    initargs=(self,),
                )
                child_pool.map(parallelize_ref_file, self.ref_file_list)

        else:
            for ref_file in self.ref_file_list:
                self.parallelize_one_ref_file(ref_file)

        shutil.rmtree("timeMarker/")

    def __init__(self):

        self.kpi_file_content = None
        self.srunner_result_file_content = {}
        self.current_ref_file = None
        self.saved_params = None
        self.test_date = datetime.utcnow()
        self.file_error_counter = Value("i", 0, lock=True)
        print("perf_portal.py start ...", flush=True)
        self.params = PerfPortal.parse()
        self.decode_snapshot_send_message = True
        self.file_index = None
        self.ref_file_list = None

        # Multiprocess init
        self.multiprocess = not self.params["noMultiProcess"]
        del self.params["noMultiProcess"]

        self.params["fileSnapshot"] = None

        print(f"param was {self.params}", flush=True)

        self.context = Context(
            zuul_branch=self.params["softwareBranch"],
            check_threshold=self.is_check_threshold(),
            insert_into_db=self.is_insert_into_db(),
            send_gerrit_comment=self.is_send_comment_to_gerrit(),
            multiprocess=self.multiprocess,
        )

        if self.params["dirKpi"]:
            self.manage_one_directory()
        else:
            self.manage_one_test_result()

        self.context.send_alarm()

        if self.file_error_counter.value:
            print(
                f"perf_portal.py ends with {self.file_error_counter.value} "
                "snapshot file process in error",
                flush=True,
            )
            print(SUPPORT_MESSAGE, flush=True)
        else:
            print("perf_portal.py ends successfully", flush=True)

        self.context.db_disconnect()

        if self.context.is_alarm_critical:
            sys.exit(RC_MAJOR_CHECK_ALARM)


if __name__ == "__main__":
    try:
        if not filter_before_run():
            PerfPortal()
    except SystemExit as sysex:
        if sysex.code in RETURN_CODE_MESSAGE:
            print(RETURN_CODE_MESSAGE[sysex.code], flush=True)
        else:
            Report().error()
        print(SUPPORT_MESSAGE, flush=True)

        raise
    except Exception:
        Report().error()
        print(SUPPORT_MESSAGE, flush=True)
