# import re
from copy import deepcopy
from context import ExceptionNotNeedToSendByMail
from utils_function import get_from_insensitive_key
from database_table_object import TableTest
from database_table_object import TableKpiLeadTime
from database_table_object import TableKpiProcessingTime
from database_table_object import TableKpiValues
from database_table_object import TableKpiProcessingTimePerEO
from database_table_object import KPI_PROCESSING_TIME_PER_EO_MAX_LEVEL
from database_table_object import TableKpiMiddleware


class TimeMarkerKPIFile:
    def __init__(self, json_file_content, context):
        self.content = json_file_content

        self.context = context
        self.test_id = None
        self.header_dict = get_from_insensitive_key("header", self.content)
        self.version = get_from_insensitive_key("version", self.header_dict)
        self.test_type = self.header_dict["scriptParam"]["testType"]

    # @staticmethod
    # def get_from_insensitive_key(key_to_find, into_dict):
    #     if key_to_find in into_dict:
    #         return into_dict[key_to_find]
    #     insensitive_key = key_to_find.casefold()
    #     for key_into_dict in into_dict:
    #         if insensitive_key == key_into_dict.casefold():
    #             return into_dict[key_into_dict]
    #     raise KeyError(f"insensitive key {key_to_find} not found")

    def insert_test_information(self):
        table_test_obj = TableTest(self.context, self.header_dict)
        table_test_obj.save_into_db()
        self.test_id = (
            table_test_obj.auto_increment["value"] if table_test_obj.auto_increment["value"] else 1
        )

        test_info = table_test_obj.columns.copy()
        test_info["id"] = self.test_id
        last_id_db_found = (
            table_test_obj.search_last_id()
            if table_test_obj.columns["testStatus"] != "FAILED"
            else []
        )
        self.context.init_check(test_info, last_id_db_found)

    def get_result_without_sub_level(self, kpi_env, data_content, db_object):
        for key_data in data_content.keys():
            try:
                kpi_data = get_from_insensitive_key("kpi", data_content[key_data])
                kpi_env["name"] = key_data
                kpi_obj = db_object(self.context, kpi_env, kpi_data)
                kpi_obj.save_into_db()
                self.context.launch_check(
                    self.get_obj_columns(kpi_obj),
                    kpi_obj.get_reference_kpi_list,
                    kpi_with_name=True,
                )
            except KeyError:
                pass

    def insert_one_middleware_kpi(self, data_dict):
        try:
            component_instance = get_from_insensitive_key("instance", data_dict)
        except KeyError:
            component_instance = 1

        for component_key, component_value in data_dict.items():
            if component_key.casefold() == "instance":
                continue

            kpi_env = {
                "testId": self.test_id,
                "component": "Middleware",
                "cellGroupInstance": component_instance,
                "name": component_key,
            }
            kpi_sct = TableKpiMiddleware(self.context, kpi_env, component_value)
            kpi_sct.save_into_db()
            self.context.launch_check(
                self.get_obj_columns(kpi_sct), kpi_sct.get_reference_kpi_list, kpi_with_name=True
            )

    def search_ventilated_kpi(self, level, db_obj, kpi_env, data_content):
        kpi_env["ventilated"] = True
        for sub_key in data_content.keys():
            if "kpi_" in sub_key.casefold():
                kpi_env[f"subComponent{level}"] = sub_key[4:]
                db_obj(self.context, kpi_env, data_content[sub_key]).save_into_db()

    @staticmethod
    def get_obj_columns(kpi_obj):
        columns = deepcopy(kpi_obj.columns)
        columns.update({"kpiType": kpi_obj.get_kpi_type()})
        return columns

    def get_result_kpi_values(self, kpi_env, data_content):
        for name in data_content.keys():
            kpi_env["ventilated"] = False
            kpi_env["subComponent1"] = name
            kpi_env["subComponent2"] = None
            try:
                kpi_obj = TableKpiValues(
                    self.context,
                    kpi_env,
                    get_from_insensitive_key("kpi", data_content[name]),
                )
                kpi_obj.save_into_db()
                self.context.launch_check(
                    self.get_obj_columns(kpi_obj), kpi_obj.get_reference_kpi_list
                )
            except KeyError:
                pass

            self.search_ventilated_kpi(2, TableKpiValues, kpi_env, data_content[name])

    @staticmethod
    def get_name_or_id(key_id, key_name, data):
        try:
            return get_from_insensitive_key(key_id, data)
        except KeyError:
            return get_from_insensitive_key(key_name, data)

    def recursive_probe_or_message_id(self, level, kpi_env, data_content):
        try:
            kpi_env[f"subComponent{level}"] = TimeMarkerKPIFile.get_name_or_id(
                "ProbeId", "ProbeName", data_content
            )
            kpi_env["isProbe"] = True
        except KeyError:
            kpi_env[f"subComponent{level}"] = TimeMarkerKPIFile.get_name_or_id(
                "MsgId", "MsgName", data_content
            )
            kpi_env["isProbe"] = False

        kpi_env["ventilated"] = False

        cpt = level + 1
        while cpt < KPI_PROCESSING_TIME_PER_EO_MAX_LEVEL + 1:
            kpi_env[f"subComponent{cpt}"] = None
            cpt += 1

        try:
            kpi_obj = TableKpiProcessingTimePerEO(
                self.context,
                kpi_env,
                get_from_insensitive_key("kpi", data_content),
            )
            kpi_obj.save_into_db()
            self.context.launch_check(self.get_obj_columns(kpi_obj), kpi_obj.get_reference_kpi_list)
        except KeyError:
            pass

        if level < KPI_PROCESSING_TIME_PER_EO_MAX_LEVEL:
            self.search_ventilated_kpi(
                level + 1, TableKpiProcessingTimePerEO, kpi_env, data_content
            )

            try:
                for probe_or_msg in get_from_insensitive_key("sub", data_content):
                    self.recursive_probe_or_message_id(level + 1, kpi_env, probe_or_msg)
            except KeyError:
                pass

    def get_result_processing_time_per_eo(self, kpi_env, data_content):
        try:
            for eo_instance in data_content:
                kpi_env["coreId"] = get_from_insensitive_key("CoreId", eo_instance)
                kpi_env["eoNameAndInstance"] = get_from_insensitive_key(
                    "EoNameAndInstance", eo_instance
                )
                for probe_or_msg in get_from_insensitive_key("KPIs", eo_instance):
                    self.recursive_probe_or_message_id(1, kpi_env, probe_or_msg)
        except Exception as e:
            print(e, flush=True)

    def get_component_results(self, kpi_env, data_content):
        kpi_env_walking = kpi_env.copy()
        self.get_result_without_sub_level(
            kpi_env_walking,
            get_from_insensitive_key("LeadTime", data_content),
            TableKpiLeadTime,
        )
        kpi_env_walking = kpi_env.copy()
        self.get_result_without_sub_level(
            kpi_env_walking,
            get_from_insensitive_key("ProcessingTime", data_content),
            TableKpiProcessingTime,
        )
        kpi_env_walking = kpi_env.copy()
        self.get_result_kpi_values(
            kpi_env_walking, get_from_insensitive_key("Values", data_content)
        )
        kpi_env_walking = kpi_env.copy()
        self.get_result_processing_time_per_eo(
            kpi_env_walking,
            get_from_insensitive_key("ProcessingTimePerEo", data_content),
        )

    def get_l2ps_results(self):
        kpi_env = {"testId": self.test_id}
        for cell_group in get_from_insensitive_key("l2psResults", self.content):
            if not cell_group:
                file_kpi = self.header_dict["scriptParam"]["fileKpi"]
                raise ExceptionNotNeedToSendByMail(f"No KPI data found into {file_kpi}")

            kpi_env["cellGroupInstance"] = get_from_insensitive_key("CellGroupInstance", cell_group)
            for component in ["DL", "UL"]:
                kpi_env["component"] = f"L2PS{component}"
                self.get_component_results(kpi_env, get_from_insensitive_key(component, cell_group))

        try:
            middleware_result = get_from_insensitive_key("middlewareResults", self.content)
            if isinstance(middleware_result, dict):
                self.insert_one_middleware_kpi(middleware_result)
            else:
                for data_dict in middleware_result:
                    self.insert_one_middleware_kpi(data_dict)
        except KeyError:
            pass

    def compute_kpi_file(self):
        self.insert_test_information()
        self.get_l2ps_results()
        self.context.alarm_threshold()
        self.context.db_commit()
