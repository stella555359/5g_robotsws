from abc import ABC, abstractmethod
import os
from datetime import datetime, timedelta
from utils_function import get_from_insensitive_key


KPI_PROCESSING_TIME_PER_EO_MAX_LEVEL = 5


class DatabaseTable:
    def __init__(self, context, table_name, auto_increment_name=None):
        self.context = context
        self.table_name = table_name
        self.auto_increment = (
            {} if not auto_increment_name else {"name": auto_increment_name, "value": None}
        )

        self.columns = {}

    def __str__(self):
        return "Table {}: auto_increment={}, columns={}".format(
            self.table_name, self.auto_increment, self.columns
        )

    @staticmethod
    def get_mandatory_value(value):
        if not value:
            raise ValueError("mandatory, non null and non empty str missing")

        return value

    @staticmethod
    def get_mandatory_int(value):
        if not value or int(value) < 1:
            raise ValueError("mandatory and positive int missing")
        return int(value)

    @staticmethod
    def get_mandatory_bool(value):
        if value not in (True, False):
            raise ValueError("mandatory boolean missing")

        return value

    def save_into_db(self):
        if self.auto_increment and self.auto_increment["value"]:
            raise SystemError(f"already inserted into db with id={self.auto_increment['value']}")

        auto_increment_val = self.context.save_into_db(self.table_name, self.columns)
        if self.auto_increment:
            self.auto_increment["value"] = auto_increment_val


class TableRelatedCommit(DatabaseTable):
    def __init__(self, context, branch, commit, commit_date, related_commit):
        super().__init__(context, "RelatedCommit")
        self.columns = {
            "softwareBranch": self.get_mandatory_value(branch),
            "softwareCommit": self.get_mandatory_value(commit),
            "softwareCommitDate": self.get_mandatory_value(commit_date),
            "relatedCommit": self.get_mandatory_value(related_commit),
        }


class TableTest(DatabaseTable):
    def __init__(self, context, header_dictionary):
        DatabaseTable.__init__(self, context, "Test", "id")

        self.columns = {
            "board": self.get_mandatory_value(header_dictionary["snapshotData"]["board"]),
            "CCNumber": self.get_mandatory_value(header_dictionary["TestConfig"]["CCnumber"]),
            "UENumber": self.get_mandatory_value(header_dictionary["TestConfig"]["UEnumber"]),
            "DDtype": self.get_mandatory_value(header_dictionary["TestConfig"]["DDtype"]),
            "TTIDuration": self.get_mandatory_value(header_dictionary["TestConfig"]["TTIduration"]),
            "UESchedNumber": self.get_mandatory_value(header_dictionary["TestConfig"]["UEsched"]),
            "beamNumber": self.get_mandatory_value(header_dictionary["TestConfig"]["BMnumber"]),
            "feature": self.get_mandatory_value(header_dictionary["scriptParam"]["feature"]),
            "configKey": header_dictionary["scriptParam"].get("config"),
            "testNameConfig": self.get_mandatory_value(
                header_dictionary["scriptParam"]["testNameConfig"]
            ),
            "softwareBranch": self.get_mandatory_value(
                header_dictionary["scriptParam"]["softwareBranch"]
            ),
            "softwareCommit": self.get_mandatory_value(
                header_dictionary["snapshotData"]["5gnbSwVersion"]
            ).replace("git-commit:", ""),
            "softwareCommitDate": self.set_software_commit_date(header_dictionary).replace(
                " ", "T"
            ),
            "testDate": self.get_mandatory_value(header_dictionary["scriptParam"]["testDate"]),
            "testType": self.get_mandatory_value(header_dictionary["scriptParam"]["testType"]),
            "testStatus": self.get_mandatory_value(header_dictionary["scriptParam"]["testStatus"]),
            "fileKPI": self.get_mandatory_value(header_dictionary["scriptParam"]["fileKpi"]),
            "fileSnapshot": header_dictionary["scriptParam"].get("fileSnapshot"),
            "userCSL": header_dictionary["scriptParam"].get("userCSL"),
            "jenkinsJob": os.environ.get("JOB_BASE_NAME"),
            "jenkinsJobId": os.environ.get("BUILD_NUMBER"),
            "jenkinsURL": os.environ.get("BUILD_URL"),
        }

    @staticmethod
    def set_software_commit_date(header_dict):
        try:
            return TableTest.get_mandatory_value(header_dict["snapshotData"]["gnbCommitDate"])
        except Exception:
            return TableTest.get_mandatory_value(header_dict["scriptParam"]["testDate"])

    def search_last_id(self):
        keys_to_remove = (
            "softwareCommit",
            "softwareCommitDate",
            "testDate",
            "testType",
            "testStatus",
            "fileKPI",
            "fileSnapshot",
            "jenkinsJob",
            "jenkinsJobId",
            "jenkinsURL",
            "testNameConfig",
        )

        test_selection = {"=": self.columns.copy()}
        for key in keys_to_remove:
            del test_selection["="][key]

        test_selection["!="] = {
            self.auto_increment["name"]: self.auto_increment["value"],
            "testStatus": "FAILED",
            "testType": "Endurance",
        }

        test_selection[">"] = {"softwareCommitDate": datetime.utcnow() - timedelta(days=14)}

        try:
            parent_commit_date = self.context.get_parent_commit_date()
            if parent_commit_date:
                test_selection["<="] = {"softwareCommitDate": parent_commit_date}
        except Exception:
            return []

        return self.context.select_list_into_one_table(
            self.table_name,
            select_col=[
                f'MAX({self.auto_increment["name"]}) as {self.auto_increment["name"]}',
                "MAX(fileKPI) as fileKPI",
                "MAX(softwareCommitDate) as softwareCommitDate",
                "MAX(testDate) as testDate",
            ],
            where_dict=test_selection,
            order_list=["softwareCommitDate", "testDate"],
            group_by_str="softwareCommit",
            limit_result=3,
        )


class TableThresholdAlarm(DatabaseTable):
    def __init__(self, context, threshold_dict):
        DatabaseTable.__init__(self, context, "ThresholdAlarm")
        self.columns = {
            "testId": threshold_dict["testId"],
            "thresholdType": threshold_dict["type"],
            "message": threshold_dict["message"],
            "criticity": threshold_dict["criticity"],
        }


# For new TimeMarkerKpi Format
class TableWithoutSubLevel(ABC, DatabaseTable):
    def __init__(self, context, kpi_env, kpi_dictionary, with_name=True):
        DatabaseTable.__init__(self, context, self.get_table_name(), "id")

        self.columns = {
            "testId": self.get_mandatory_int(kpi_env["testId"]),
            "component": self.get_mandatory_value(kpi_env["component"]),
            "cellGroupInstance": self.get_mandatory_value(kpi_env["cellGroupInstance"]),
            "min": TableWithoutSubLevel.set_min(kpi_dictionary),
            "avg": TableWithoutSubLevel.set_avg(kpi_dictionary),
            "95p": TableWithoutSubLevel.set_95p(kpi_dictionary),
            "max": TableWithoutSubLevel.set_max(kpi_dictionary),
        }

        try:
            self.columns["nbSlots"] = get_from_insensitive_key("nbSlots", kpi_dictionary)
        except KeyError:
            pass

        if with_name:
            self.columns["name"] = self.get_mandatory_value(kpi_env["name"])

    @staticmethod
    @abstractmethod
    def get_table_name():
        raise NotImplementedError("Abstract Method declaration -> return string with table name")

    @staticmethod
    def get_kpi_type():
        raise NotImplementedError("Abstract Method declaration -> return string with table name")

    @staticmethod
    def set_min(kpi_dictionary):
        try:
            return get_from_insensitive_key("min", kpi_dictionary)
        except KeyError:
            return get_from_insensitive_key("minTime_MicroSec", kpi_dictionary)

    @staticmethod
    def set_avg(kpi_dictionary):
        try:
            return get_from_insensitive_key("avg", kpi_dictionary)
        except KeyError:
            return get_from_insensitive_key("avgTime_MicroSec", kpi_dictionary)

    @staticmethod
    def set_95p(kpi_dictionary):
        try:
            return get_from_insensitive_key("95p", kpi_dictionary)
        except KeyError:
            return get_from_insensitive_key("95pTime_MicroSec", kpi_dictionary)

    @staticmethod
    def set_max(kpi_dictionary):
        try:
            return get_from_insensitive_key("max", kpi_dictionary)
        except KeyError:
            return get_from_insensitive_key("maxTime_MicroSec", kpi_dictionary)

    def get_reference_kpi_list(self, key_search, reference_id):
        ref_col_to_delete = ["min", "avg", "95p", "max", "testId", "kpiType", "nbSlots"]

        col_list = [f"max({key_search})"]
        where_dict = self.columns.copy()
        for key in ref_col_to_delete:
            if key in where_dict:
                del where_dict[key]

        result = self.context.select_list_into_one_table(
            self.table_name,
            select_col=col_list,
            where_dict={"=": where_dict, "in": {"testId": reference_id}},
        )
        if result:
            result[0][key_search] = result[0].pop(f"max({key_search})")

        return result


class TableKpiLeadTime(TableWithoutSubLevel):
    @staticmethod
    def get_table_name():
        return "KpiLeadTime"

    @staticmethod
    def get_kpi_type():
        return "LeadTime"


class TableKpiProcessingTime(TableWithoutSubLevel):
    @staticmethod
    def get_table_name():
        return "KpiProcessingTime"

    @staticmethod
    def get_kpi_type():
        return "ProcessingTime"


class TableKpiMiddleware(TableWithoutSubLevel):
    @staticmethod
    def get_table_name():
        return "KpiMiddleware"

    @staticmethod
    def get_kpi_type():
        return "Middleware"


class TableWithSubLevel(TableWithoutSubLevel):
    def __init__(self, context, kpi_env, kpi_dictionary):
        TableWithoutSubLevel.__init__(self, context, kpi_env, kpi_dictionary, with_name=False)

        self.max_level = 2
        self.columns.update(
            {
                "ventilated": kpi_env.get("ventilated", False),
                "subComponent1": self.get_mandatory_value(kpi_env["subComponent1"]),
                "subComponent2": kpi_env.get("subComponent2"),
            }
        )

    @staticmethod
    @abstractmethod
    def get_table_name():
        raise NotImplementedError("Abstract Method declaration -> return string with table name")

    def set_ventilated_tag(self):
        if self.columns["ventilated"]:
            cpt = self.max_level
            while cpt > 0:
                if self.columns.get(f"subComponent{cpt}"):
                    val = self.columns.get(f"subComponent{cpt}")
                    self.columns[f"subComponent{cpt}"] = f"[{val}]"
                    return
                cpt -= 1


class TableKpiValues(TableWithSubLevel):
    def __init__(self, context, kpi_env, kpi_dictionary):
        TableWithSubLevel.__init__(self, context, kpi_env, kpi_dictionary)
        self.set_ventilated_tag()

    @staticmethod
    def get_table_name():
        return "KpiValues"

    @staticmethod
    def get_kpi_type():
        return "Values"


class TableKpiProcessingTimePerEO(TableWithSubLevel):
    def __init__(self, context, kpi_env, kpi_dictionary):
        global KPI_PROCESSING_TIME_PER_EO_MAX_LEVEL

        TableWithSubLevel.__init__(self, context, kpi_env, kpi_dictionary)
        self.max_level = KPI_PROCESSING_TIME_PER_EO_MAX_LEVEL
        self.columns.update(
            {
                "coreId": self.get_mandatory_value(kpi_env["coreId"]),
                "eoNameAndInstance": self.get_mandatory_value(kpi_env["eoNameAndInstance"]),
                "isProbe": self.get_mandatory_bool(kpi_env["isProbe"]),
                "subComponent1": TableKpiProcessingTimePerEO.get_sub_component(
                    kpi_env.get("subComponent1")
                ),
                "subComponent2": TableKpiProcessingTimePerEO.get_sub_component(
                    kpi_env.get("subComponent2")
                ),
                "subComponent3": TableKpiProcessingTimePerEO.get_sub_component(
                    kpi_env.get("subComponent3")
                ),
                "subComponent4": TableKpiProcessingTimePerEO.get_sub_component(
                    kpi_env.get("subComponent4")
                ),
                "subComponent5": TableKpiProcessingTimePerEO.get_sub_component(
                    kpi_env.get("subComponent5")
                ),
            }
        )
        self.set_ventilated_tag()

    @staticmethod
    def get_sub_component(sub_component_val):
        if sub_component_val:
            return sub_component_val.replace("EO_L2_PS_", "")
        return None

    @staticmethod
    def get_table_name():
        return "KpiProcTimePerEO"

    @staticmethod
    def get_kpi_type():
        return "ProcessingTimePerEO"
