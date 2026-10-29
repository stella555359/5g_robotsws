import json
import os
import re
from multiprocessing import Value

from connect_to_database import Database
from check import Threshold
from check import UnderThreshold
from check import CPUIncreasePercent
from check import CPUIncreaseAbsolute
from check import BoxPlotIncrease
from report import Report
from gerrit import Gerrit

THRESHOLD_DIR = "threshold"
DECODER_DIR = "decoder"
THRESHOLD_ACTIVE_CONF = "threshold/active_threshold.json"


class ExceptionNotNeedToSendByMail(ValueError):
    pass


class Context:
    def __init__(
        self,
        zuul_branch="master",
        check_threshold=True,
        insert_into_db=True,
        send_gerrit_comment=True,
        multiprocess=False,
    ):

        self.zuul_branch = zuul_branch
        self.database = Database()
        self.severity_levels = ["Critical", "Major", "Minor"]
        self.threshold = None
        self.threshold_message = dict.fromkeys(self.severity_levels, "")
        self.under_threshold = None
        self.under_threshold_message = dict.fromkeys(self.severity_levels, "")
        self.cpu_increase_perc = None
        self.cpu_increase_perc_message = dict.fromkeys(self.severity_levels, "")
        self.cpu_increase_abs = None
        self.cpu_increase_abs_message = dict.fromkeys(self.severity_levels, "")
        self.boxplot_increase_message = dict.fromkeys(self.severity_levels, "")
        self.general_check_active = check_threshold
        self.specific_check_active = Context.get_threshold_active()
        self.threshold_file_content = dict()
        self.threshold_filename = self.get_configurator_content() if check_threshold else None
        self.decode_option_file_content = dict()
        self.decode_option_filename = self.get_configurator_content("DecoderOptions")
        self.insert_into_db = insert_into_db
        self.send_gerrit_comment = send_gerrit_comment
        self.gerrit = self.init_gerrit()
        self.multiprocess = multiprocess
        self.value_to_manage_lock_print = Value("i", 0, lock=True)
        self.is_alarm_critical = False
        self.save_messages()

        self.perf_short_commit = self.gerrit.get_perf_portal_commit() if self.gerrit else None

    # Database interface
    def db_disconnect(self):
        self.database.disconnect()

    def db_reconnect(self):
        self.database.database = self.database.connect()

    def save_into_db(self, table_name, dictionary):
        if self.insert_into_db:
            return self.database.insert(table_name, dictionary)
        return None

    def delete_into_db(self, table_name, where_dict=None):
        if self.insert_into_db:
            self.database.clean_table(table_name, where_dict=where_dict)

    def db_commit(self):
        if self.insert_into_db:
            print("Database commit active", flush=True)
            self.database.commit()

    def update_one_table(self, table_name, set_dict, where_dict):
        return self.database.update_one_table(table_name, set_dict=set_dict, where_dict=where_dict)

    def select_list_into_one_table(
        self,
        table_name,
        select_col=["id"],
        where_dict=None,
        where_str=None,
        order_list=None,
        sort_order="DESC",
        group_by_str=None,
        limit_result=1,
    ):

        # pylint: disable=dangerous-default-value
        return self.database.select_list_into_one_table(
            table_name,
            select_col=select_col,
            where_dict=where_dict,
            where_str=where_str,
            order_list=order_list,
            sort_order=sort_order,
            group_by_str=group_by_str,
            limit_result=limit_result,
        )

    # Check interface
    @staticmethod
    def get_threshold_active():
        active = {}
        try:
            current_dir = os.path.dirname(os.path.realpath(__file__))
            active_conf_full_path = f"{current_dir}/{THRESHOLD_ACTIVE_CONF}"
            with open(active_conf_full_path) as f_h:
                active = json.load(f_h)
        except FileNotFoundError:
            print(f"Warning: conf file {THRESHOLD_ACTIVE_CONF} not found", flush=True)
        return active

    def save_messages(self):
        if self.multiprocess:
            with open("perf_portal_multiprocess_messages", "w") as f_h:
                json.dump(
                    {
                        "threshold_message": self.threshold_message,
                        "under_threshold_message": self.under_threshold_message,
                        "cpu_increase_perc_message": self.cpu_increase_perc_message,
                        "cpu_increase_abs_message": self.cpu_increase_abs_message,
                    },
                    f_h,
                )

    def get_messages(self):
        if self.multiprocess:
            with open("perf_portal_multiprocess_messages", "r") as f_h:
                json_read = json.load(f_h)
            self.threshold_message = json_read["threshold_message"]
            self.under_threshold_message = json_read["under_threshold_message"]
            self.cpu_increase_perc_message = json_read["cpu_increase_perc_message"]
            self.cpu_increase_abs_message = json_read["cpu_increase_abs_message"]
            os.remove("perf_portal_multiprocess_messages")

    def set_content_var(self, file_type, path_config_file):
        with open(path_config_file) as f_h:
            if file_type == "Threshold":
                self.threshold_file_content = json.load(f_h)
            else:
                self.decode_option_file_content = json.load(f_h)

    def get_configurator_content(self, file_type="Threshold"):
        global THRESHOLD_DIR, DECODER_DIR

        root_dir = THRESHOLD_DIR if file_type == "Threshold" else DECODER_DIR
        filename = (
            "threshold_scheduler.json" if file_type == "Threshold" else "configure_options.json"
        )

        default_config_file = f"{root_dir}/{filename}"

        if self.zuul_branch and self.zuul_branch.startswith("rel/"):
            config_file = f"{root_dir}/{self.zuul_branch.replace('rel/', '')}_{filename}"
            try:
                path_config_file = f"{os.path.dirname(os.path.realpath(__file__))}/{config_file}"
                self.set_content_var(file_type, path_config_file)
                return os.path.basename(path_config_file)
            except Exception:
                pass

            release = re.sub(r"rel/(.*)_[^_]*$", r"\1", self.zuul_branch)
            config_file = f"{root_dir}/{release}_{filename}"
            try:
                path_config_file = f"{os.path.dirname(os.path.realpath(__file__))}/{config_file}"
                self.set_content_var(file_type, path_config_file)
                return os.path.basename(path_config_file)
            except Exception:
                pass

        try:
            if os.path.isabs(default_config_file):
                path_config_file = f"{default_config_file}"
            else:
                path_config_file = (
                    f"{os.path.dirname(os.path.realpath(__file__))}/{default_config_file}"
                )
            self.set_content_var(file_type, path_config_file)
            return os.path.basename(path_config_file)
        except Exception:
            Report().error()
            Report().alarm(
                f"\nWarning : {default_config_file} cannot be opened as a JSON file"
                f" to check {file_type}."
            )

        return os.path.basename(default_config_file)

    def get_check_obj(self, check_class, test_info, last_same_test_info=None):
        if test_info["testStatus"] == "FAILED" or (
            self.zuul_branch == "master"
            and not self.specific_check_active.get(check_class.get_check_value(), True)
        ):
            return None
        if check_class != CPUIncreasePercent and check_class != CPUIncreaseAbsolute:
            return check_class(self.threshold_file_content, test_info, self.zuul_branch)
        return check_class(
            self.threshold_file_content, test_info, self.zuul_branch, last_same_test_info
        )

    def init_check(self, test_info, last_same_test_info):
        if self.general_check_active:
            self.threshold = self.get_check_obj(Threshold, test_info)
            self.under_threshold = self.get_check_obj(UnderThreshold, test_info)
            self.cpu_increase_perc = self.get_check_obj(
                CPUIncreasePercent,
                test_info,
                last_same_test_info,
            )
            self.cpu_increase_abs = self.get_check_obj(
                CPUIncreaseAbsolute,
                test_info,
                last_same_test_info,
            )

    def compute_boxplot_increase(self, test_info, previous_commit, previous_commit_kpi=None):
        if not self.threshold_file_content:
            self.get_configurator_content()
        boxplot_increase = BoxPlotIncrease(self.threshold_file_content, test_info, self.zuul_branch)
        current_kpi_mean = boxplot_increase.check_kpi_scheduler(
            previous_commit,
            self.select_list_into_one_table,
            previous_commit_kpi=previous_commit_kpi,
        )
        self.set_message(boxplot_increase, self.boxplot_increase_message)
        return current_kpi_mean

    def launch_check(self, dictionary, get_reference_kpi_list_method, kpi_with_name=False):
        self.check_threshold(dictionary, kpi_with_name=kpi_with_name)
        self.check_under_threshold(dictionary, kpi_with_name=kpi_with_name)
        self.check_cpu_increase_perc(
            dictionary, get_reference_kpi_list_method, kpi_with_name=kpi_with_name
        )
        self.check_cpu_increase_abs(
            dictionary, get_reference_kpi_list_method, kpi_with_name=kpi_with_name
        )

    def check_threshold(self, dictionary, kpi_with_name=False):
        if self.general_check_active and self.threshold:
            self.threshold.check_kpi_scheduler(dictionary, kpi_with_name=kpi_with_name)

    def check_under_threshold(self, dictionary, kpi_with_name=False):
        if self.general_check_active and self.under_threshold:
            self.under_threshold.check_kpi_scheduler(dictionary, kpi_with_name=kpi_with_name)

    def check_cpu_increase_perc(
        self, dictionary, get_reference_kpi_list_method, kpi_with_name=False
    ):
        if self.general_check_active and self.cpu_increase_perc:
            self.cpu_increase_perc.check_kpi_scheduler(
                dictionary, get_reference_kpi_list_method, kpi_with_name=kpi_with_name
            )

    def check_cpu_increase_abs(
        self, dictionary, get_reference_kpi_list_method, kpi_with_name=False
    ):
        if self.general_check_active and self.cpu_increase_abs:
            self.cpu_increase_abs.check_kpi_scheduler(
                dictionary, get_reference_kpi_list_method, kpi_with_name=kpi_with_name
            )

    def set_message(self, check_obj, check_obj_message):
        if check_obj:
            message_dict = check_obj.get_messages(self.insert_into_db, context=self)
            for level in self.severity_levels:
                check_obj_message[level] += message_dict.get(level, "")

    def alarm_threshold(self):
        with self.value_to_manage_lock_print.get_lock():
            self.get_messages()
            if self.general_check_active:
                self.set_message(self.threshold, self.threshold_message)
                self.set_message(self.under_threshold, self.under_threshold_message)
                self.set_message(self.cpu_increase_perc, self.cpu_increase_perc_message)
                self.set_message(self.cpu_increase_abs, self.cpu_increase_abs_message)

            self.save_messages()

    def set_sub_message(self, sub_message, check_obj_message, header, level):
        if check_obj_message[level]:
            if level == "Critical":
                self.is_alarm_critical = True
            return "\n\n".join(filter(None, (sub_message, header + check_obj_message[level])))
        return sub_message

    def send_alarm(self):
        with self.value_to_manage_lock_print.get_lock():
            self.get_messages()

        message_dict = {}
        for level in self.severity_levels:
            sub_message = ""
            sub_message = self.set_sub_message(
                sub_message, self.threshold_message, "<b>Threshold Alarm:</b>", level
            )
            sub_message = self.set_sub_message(
                sub_message, self.under_threshold_message, "<b>Under Threshold Alarm:</b>", level
            )
            sub_message = self.set_sub_message(
                sub_message,
                self.cpu_increase_perc_message,
                "<b>CPU Increase PERC Alarm:</b>",
                level,
            )
            sub_message = self.set_sub_message(
                sub_message, self.cpu_increase_abs_message, "<b>CPU Increase ABS Alarm:</b>", level
            )
            sub_message = self.set_sub_message(
                sub_message, self.boxplot_increase_message, "<b>BoxPlot Increase Alarm:</b>", level
            )

            if sub_message:
                message_dict[level] = sub_message

        if message_dict:
            message_str = Report().alarm(
                message_dict,
                self.threshold_filename,
                perf_portal_short_commit=self.perf_short_commit,
            )
            if self.send_gerrit_comment and self.gerrit and message_str:
                try:
                    self.gerrit.send_comments(message_str)
                except Exception:
                    Report().error()
            else:
                print("No message sent to gerrit", flush=True)

    # Gerrit interface
    def init_gerrit(self):
        try:
            return Gerrit(self.send_gerrit_comment)
        except Exception:
            Report().error()
            return None

    def get_parent_commit_date(self):
        if self.send_gerrit_comment:
            return self.gerrit.parent_commit_date
        return None

    # Git management
    @staticmethod
    def clone_time_marker():
        Gerrit.git_clone_time_marker()

    def get_commit_date(self, commit_hash):
        if self.insert_into_db:
            return self.gerrit.get_commit_date(commit_hash)
        return "2001-01-01 01:01:01"

    # Configure option management
    @staticmethod
    def _compare_test_info(test_info, dict_to_check):
        common_keys = set(dict_to_check).intersection(set(test_info))
        if not common_keys:
            return False
        for key in common_keys:
            if test_info[key] != dict_to_check[key]:
                return False
        return True

    def get_configure_option_list(self, test_info_dict):
        decode_option = dict()
        for config_keys in self.decode_option_file_content:
            for dict_to_check in self.decode_option_file_content[config_keys]:
                if Context._compare_test_info(test_info_dict, dict_to_check):
                    decode_option[config_keys] = True
                    break
        return list(decode_option.keys())
