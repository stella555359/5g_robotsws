from abc import ABC, abstractmethod
import re
from datetime import datetime

from report import Report
from database_table_object import TableThresholdAlarm


# pylint: disable=arguments-differ


class Check(ABC):
    def __init__(
        self,
        threshold_file_content,
        test_info,
        branch,
        check_alarm_str,
        need_links=True,
    ):
        self.threshold = threshold_file_content
        self.test_info = test_info
        self.branch = branch
        self.check_value = self.get_check_value()
        self.check_alarm_str = check_alarm_str
        self.severity_levels = ["Critical", "Major", "Minor"]
        self.message = dict.fromkeys(self.severity_levels, "")
        self.columns = {}
        self.previous_test_ids_str = None
        self.previous_kpi_files_str = None
        self.unit = "us"

        self.get_threshold_dict(self.threshold)
        self.columns = self.manage_voting_path_parameter()
        self.need_links = need_links
        if need_links:
            self.powerbi_test_view, self.powerbi_history_view = Check.get_power_bi_url(
                self.test_info
            )

    @staticmethod
    @abstractmethod
    def get_check_value():
        raise NotImplementedError("Abstract Method declaration")

    @staticmethod
    def is_kpi_key(key):
        return key in ["min", "avg", "95p", "max"]

    @staticmethod
    def get_config_key(val):
        if val in ["null", None]:
            return ""
        return f"_{val}"

    def compare_test_info(self, dict_to_check):
        common_keys = set(dict_to_check).intersection(set(self.test_info))
        for key in common_keys:
            if f"{self.test_info[key]}" != f"{dict_to_check[key]}":
                return False
        return True

    def get_voting_value_parameter(self, test_cond):
        if self.branch == "master" and not test_cond.get("voting", True):
            return False
        return True

    def get_threshold_one_key(self, json_val, new_key):
        for test_cond in json_val:
            if self.compare_test_info(test_cond) and self.get_voting_value_parameter(test_cond):
                try:
                    self.columns[new_key] = test_cond[self.check_value]
                except KeyError:
                    pass

    def get_threshold_dict(self, json_dict, threshold_key=""):
        if isinstance(json_dict, dict):
            for json_key, json_val in json_dict.items():
                new_key = f"{threshold_key}{json_key}"
                if json_key == "voting":
                    self.columns[new_key] = json_val
                if Check.is_kpi_key(json_key):
                    self.get_threshold_one_key(json_val, new_key)
                else:
                    self.get_threshold_dict(json_val, f"{new_key}.")

    @staticmethod
    def format_kpi_scheduler_columns(kpi_columns_to_format, kpi_suffix="", kpi_with_name=False):
        root_key = ""
        kpi_keys = [("kpiType", False), ("component", True), ("eoNameAndInstance", False)]
        if kpi_with_name:
            kpi_keys.append(("name", False))
        kpi_keys += [
            ("subComponent1", True),
            ("subComponent2", True),
            ("subComponent3", True),
            ("subComponent4", True),
        ]
        for kpi_key, need_to_break in kpi_keys:
            if (
                kpi_key not in kpi_columns_to_format
                or not kpi_columns_to_format[kpi_key]
                or kpi_columns_to_format[kpi_key] == "All"
            ):
                if need_to_break:
                    break
            else:
                root_key += f"{kpi_columns_to_format[kpi_key]}."
        return {
            f"{root_key}min": kpi_columns_to_format[f"min{kpi_suffix}"],
            f"{root_key}avg": kpi_columns_to_format[f"avg{kpi_suffix}"],
            f"{root_key}95p": kpi_columns_to_format[f"95p{kpi_suffix}"],
            f"{root_key}max": kpi_columns_to_format[f"max{kpi_suffix}"],
        }

    @staticmethod
    def set_components_key_dict(formatted_kpi_key):
        split_keys = formatted_kpi_key.split(".")
        cpt = 0
        result_dict = dict()
        for kpi_key in [
            "component",
            "subComponent1",
            "subComponent2",
            "subComponent3",
            "subComponent4",
        ]:
            if len(split_keys) > cpt:
                result_dict[kpi_key] = split_keys[cpt]
                cpt += 1
            else:
                result_dict[kpi_key] = "All"

        return result_dict

    def manage_voting_path_parameter(self):
        kpi_to_ignore = []
        filtered_columns = self.columns.copy()
        for kpi_key, val in self.columns.items():
            if kpi_key.endswith("voting"):
                if not val and self.branch == "master":
                    kpi_path = kpi_key.rsplit(".", 1)[0]
                    kpi_to_ignore.append(kpi_path)
                filtered_columns.pop(kpi_key)

        if kpi_to_ignore:
            for kpi_key in self.columns.keys():
                if kpi_key.startswith(tuple(kpi_to_ignore)):
                    try:
                        filtered_columns.pop(kpi_key)
                    except KeyError:
                        pass
        return filtered_columns

    @staticmethod
    def get_power_bi_url(info):
        formatted_test_name = (
            f"{info['feature']}_{info['beamNumber']}BM_{info['CCNumber']}CC_"
            f"{info['UENumber']}UE_{info['UESchedNumber']}UEsched_{info['DDtype']}"
            f"{info['TTIDuration']}_{info['board']}{Check.get_config_key(info['configKey'])}"
        )
        test_filter = f"?filter=perf_5g_x0020_Test/FormatedTestName eq '{formatted_test_name}'"
        commit_filter = (
            f"perf_5g_x0020_Test/FormatedCommitShortName eq '{info['softwareCommit'][:7]}'"
        )
        test_view_url = (
            "https://app.powerbi.com/groups/me/apps/4b451a02-844c-47b2-bd6b-e43667c7cf16/"
            "reports/40754105-09ce-460f-8c03-6881db7c58c7/"
            f"ReportSection047c7ac31e9441232f58{test_filter} and {commit_filter}"
        )
        history_view_url = (
            "https://app.powerbi.com/groups/me/apps/4b451a02-844c-47b2-bd6b-e43667c7cf16/reports/"
            f"40754105-09ce-460f-8c03-6881db7c58c7/ReportSection45750c70ce6fd4a0a73d{test_filter}"
        )

        return test_view_url, history_view_url

    def get_file_kpi_link(self):
        link = "https://5gwebserver.dyn.nesc.nokia.net/CinqG/perfport/"
        test_date = datetime.strptime(self.test_info["testDate"], "%Y-%m-%dT%H:%M:%S")
        link += test_date.strftime("%Y/%m/%d/%H.%M.%S/")
        link += self.test_info["fileKPI"]

        return link

    @staticmethod
    @abstractmethod
    def check_kpi_scheduler(*args):
        raise NotImplementedError("Abstract Method declaration")

    @staticmethod
    @abstractmethod
    def check_test_limit_function(val, kpi_key, level):
        raise NotImplementedError(
            "Abstract Method declaration check_test_limit_function(val, kpi_key, level)"
        )

    def get_bold_test_name(self):
        if "formatted_test_name_like" in self.test_info:
            return (
                f"<b>{self.test_info['formatted_test_name_like']}</b>, "
                + f"current commit is <b>{self.test_info['commitHashDate']}</b> and "
                + f"reference commit is <b>{self.test_info['refCommitHashDate']}</b>"
            )
        test_name = re.sub(r"^.*((ft.*)|(cni.*))_[\d_.]{19}_.*$", r"\1", self.test_info["fileKPI"])
        return self.test_info["fileKPI"].replace(test_name, f"<b>{test_name}</b>")

    def get_messages(self, save_into_db=True, context=None):
        print(f"Checking {self.check_alarm_str} active", flush=True)
        if any(self.message.values()):
            for level, message in self.message.items():
                if save_into_db and context and message:
                    TableThresholdAlarm(
                        context,
                        {
                            "testId": self.test_info["id"],
                            "type": self.check_alarm_str,
                            "message": message,
                            "criticity": level,
                        },
                    ).save_into_db()

                warning_or_error = "Error" if level == self.severity_levels[0] else "Warning"

                if self.message[level]:
                    if self.previous_kpi_files_str:
                        self.message[level] = (
                            f"\n{warning_or_error} : {self.get_bold_test_name()} "
                            "with reference test "
                            f"{self.previous_kpi_files_str} :{self.message[level]}"
                        )
                    else:
                        self.message[level] = (
                            f"\n{warning_or_error} : {self.get_bold_test_name()} :"
                            f"{self.message[level]}"
                        )
                    if save_into_db and self.need_links:
                        self.message[level] += (
                            f'\n<a href="{self.powerbi_test_view}">Power BI test view</a>, '
                            f'<a href="{self.powerbi_history_view}">Power BI history view</a>, '
                            f'<a href="{self.get_file_kpi_link()}">Timemarker KPI file</a>\n'
                        )

        return self.message

    def check_limit_exceeded(self, val, kpi_key):
        for level in self.severity_levels:
            try:
                if self.check_test_limit_function(val, kpi_key, level):
                    return
            except Exception:
                pass


class Threshold(Check):
    def __init__(
        self,
        threshold_file_content,
        test_info,
        branch,
        check_alarm_str="threshold",
    ):
        super().__init__(threshold_file_content, test_info, branch, check_alarm_str)

    def check_kpi_scheduler(self, raw_kpi_columns, kpi_with_name=False):
        kpi_dict = Threshold.format_kpi_scheduler_columns(
            raw_kpi_columns, kpi_with_name=kpi_with_name
        )

        self.unit = raw_kpi_columns["unit"] if ("unit" in raw_kpi_columns) else " us"
        for kpi_key, kpi_val in kpi_dict.items():
            self.check_limit_exceeded(kpi_val, kpi_key)

    def check_test_limit_function(self, kpi_val, kpi_key, level):
        if float(kpi_val) > float(self.columns[kpi_key][level]):
            self.message[level] += (
                f"\n{kpi_key} = {kpi_val}{self.unit} exceeds threshold value "
                f"{self.columns[kpi_key][level]}{self.unit}."
            )
            return True
        return False

    @staticmethod
    def get_check_value():
        return "threshold_value"


class UnderThreshold(Threshold):
    def __init__(self, threshold_file_content, test_info, branch):
        super().__init__(
            threshold_file_content,
            test_info,
            branch,
            check_alarm_str="under or egal KPI threshold",
        )

    def check_test_limit_function(self, kpi_val, kpi_key, level):
        if float(kpi_val) <= float(self.columns[kpi_key][level]):
            self.message[level] += (
                f"\n{kpi_key} = {kpi_val}{self.unit} is {self.check_alarm_str} "
                f"{self.columns[kpi_key][level]}{self.unit}."
            )
            return True
        return False

    @staticmethod
    def get_check_value():
        return "under_threshold"


class ValueIncrease(Check):
    def __init__(
        self,
        threshold_file_content,
        test_info,
        branch,
        check_alarm_str,
        delta_unit,
        last_test,
        need_links=True,
    ):
        super().__init__(
            threshold_file_content,
            test_info,
            branch,
            check_alarm_str,
            need_links=need_links,
        )
        self.ref_kpi_value = None
        self.new_kpi_value = None
        self.delta_unit = delta_unit
        self.previous_endurance_commit = None

        if last_test:
            self.previous_test_ids_str = ", ".join(tuple(f'{x["id"]}' for x in last_test))
            self.previous_kpi_files_str = ", ".join(tuple(f'{x["fileKPI"]}' for x in last_test))

    @abstractmethod
    def compute_delta(self):
        # raise NotImplementedError("Abstract Method declaration")
        pass

    def cpu_increase_upper_threshold(self, kpi_key):
        try:
            self.check_limit_exceeded(self.compute_delta(), kpi_key)
        except Exception:
            pass

    def check_test_limit_function(self, delta, kpi_key, level):
        if float(delta) > float(self.columns[kpi_key][level]):
            self.message[level] += (
                f"\n{kpi_key} = {self.new_kpi_value} us exceeds cpu increase of "
                + f"{self.columns[kpi_key][level]}{self.delta_unit} with {self.ref_kpi_value} us"
            )
            return True
        return False

    def check_kpi_scheduler(
        self, raw_kpi_columns, get_reference_kpi_list_method, kpi_with_name=False
    ):
        if not self.previous_test_ids_str:
            return

        kpi_dict = ValueIncrease.format_kpi_scheduler_columns(
            raw_kpi_columns, kpi_with_name=kpi_with_name
        )
        for kpi_key, kpi_val in kpi_dict.items():
            if kpi_key in self.columns:
                try:
                    kpi_to_find = kpi_key.rsplit(".", 1)[1]
                    ref_kpi_values = get_reference_kpi_list_method(
                        kpi_to_find, self.previous_test_ids_str
                    )
                    if not ref_kpi_values:
                        raise LookupError(
                            f"raw_kpi={raw_kpi_columns} and previous_test_id in "
                            f"[{self.previous_test_ids_str}]"
                        )

                    self.ref_kpi_value = ref_kpi_values[0][kpi_to_find]
                    self.new_kpi_value = kpi_val
                    self.cpu_increase_upper_threshold(kpi_key)
                except Exception:
                    Report().error(
                        f"Debug: kpi: {raw_kpi_columns} ref test_id in "
                        f"[{self.previous_test_ids_str}]"
                    )


class CPUIncreasePercent(ValueIncrease):
    def __init__(self, threshold_file_content, test_info, branch, last_test):
        super().__init__(
            threshold_file_content,
            test_info,
            branch,
            "cpu increase",
            "%",
            last_test,
        )

    def compute_delta(self):
        return (
            (float(self.new_kpi_value) - float(self.ref_kpi_value))
            / float(self.ref_kpi_value)
            * 100.0
        )

    @staticmethod
    def get_check_value():
        return "percent_diff_threshold"


class CPUIncreaseAbsolute(ValueIncrease):
    def __init__(self, threshold_file_content, test_info, branch, last_test):
        super().__init__(
            threshold_file_content,
            test_info,
            branch,
            "cpu increase",
            " us",
            last_test,
        )

    def compute_delta(self):
        return float(self.new_kpi_value) - float(self.ref_kpi_value)

    @staticmethod
    def get_check_value():
        return "absolute_diff_threshold"


class BoxPlotIncrease(ValueIncrease):
    def __init__(self, threshold_file_content, test_info, branch):
        super().__init__(
            threshold_file_content,
            test_info,
            branch,
            "boxplot mean increase",
            " us",
            last_test=None,
            need_links=False,
        )
        self.previous_endurance_commit = None

    @staticmethod
    def get_check_value():
        return "max_boxplot_increase"

    def check_kpi_scheduler(
        self,
        previous_endurance_commit,
        context_select_list_into_one_table_method,
        previous_commit_kpi=None,
    ):
        if not previous_endurance_commit:
            raise SystemError(
                "Debug: no previous_endurance_commit was set to BoxPlotIncrease check"
            )

        self.previous_endurance_commit = previous_endurance_commit

        try:
            new_kpi_dict = {}
            for kpi_key in self.columns:
                kpi_path, kpi_to_find = kpi_key.rsplit(".", 1)
                where_egal_dict = Check.set_components_key_dict(kpi_path)
                where_egal_dict["testType"] = "Endurance"
                where_dict = {
                    "=": where_egal_dict,
                    "like": {"fileKPI": self.test_info["formatted_test_name_like"]},
                }
                if previous_commit_kpi:
                    where_dict["="]["softwareCommit"] = self.test_info["softwareCommit"]
                    self.ref_kpi_value = previous_commit_kpi[kpi_key]
                else:
                    where_dict.update(
                        {
                            "in": {
                                "softwareCommit": f"'{previous_endurance_commit}', "
                                f"'{self.test_info['softwareCommit']}'"
                            }
                        }
                    )

                computed_avg_list = context_select_list_into_one_table_method(
                    table_name="Test AS t, KpiScheduler AS k",
                    select_col=["softwareCommit", f"AVG({kpi_to_find}) as kpi"],
                    where_dict=where_dict,
                    where_str="k.testId=t.id",
                    group_by_str="softwareCommit",
                    limit_result=2,
                )

                for computed_dict in computed_avg_list:
                    if computed_dict["softwareCommit"] == previous_endurance_commit:
                        self.ref_kpi_value = computed_dict["kpi"]
                    else:
                        self.new_kpi_value = computed_dict["kpi"]

                new_kpi_dict[kpi_key] = self.new_kpi_value
                self.cpu_increase_upper_threshold(kpi_key)
        except Exception as exc:
            raise SystemError(
                f"Debug: Endurance kpi check exception for kpi: {kpi_key} "
                f"ref commit id {previous_endurance_commit}"
            ) from exc

        return new_kpi_dict

    def compute_delta(self):
        return float(self.new_kpi_value) - float(self.ref_kpi_value)
