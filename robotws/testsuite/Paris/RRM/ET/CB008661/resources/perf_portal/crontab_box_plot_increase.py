import json
import glob
import os
import re
from datetime import timedelta
from crontab import Crontab
from report import Report
from context import Context


ROOT_DIR = "/5g_storage/PatchServer/perfport"
DELTA_HOUR_TO_CHECK = 6


class CronBoxPlotIncrease(Crontab):
    def get_default_last_check_date_time(self):
        return self.current_date_time - timedelta(days=2)

    @staticmethod
    def get_endurance_test_info(
        test_name, test_id, software_commit, commit_hash_date, ref_commit_hash_date, path_to_use
    ):

        file_to_search = os.path.sep.join([path_to_use, f"{test_name}_*"])
        test_file_list = []
        for filename in glob.glob(file_to_search):
            if re.match(r".*" + f"{test_name}" + r"_((\d{1,2}_\d{1,2}_\d{4}.)|(COUNT_))", filename):
                test_file_list.append(filename)

        if test_file_list:
            with open(test_file_list[0], "r") as f_h:
                json_content = json.load(f_h)

            test_info = json_content["header"]["scriptParam"]
            test_info["id"] = test_id
            test_info["softwareCommit"] = software_commit
            test_info["formatted_test_name_like"] = f"{test_name}%"
            test_info["commitHashDate"] = commit_hash_date
            test_info["refCommitHashDate"] = ref_commit_hash_date
        else:
            raise FileNotFoundError(f"No file found for {file_to_search}")

        return test_info

    def get_previous_hash_date(
        self, extracted_file_kpi, software_branch, software_commit, software_commit_date
    ):
        if not (
            extracted_file_kpi in self.previous_commit_dict
            and software_branch in self.previous_commit_dict[extracted_file_kpi]
        ):
            previous_commit_list = self.context.select_list_into_one_table(
                "Test",
                select_col=["DISTINCT(softwareCommit) as softwareCommit", "softwareCommitDate"],
                where_dict={
                    "=": {"testType": "Endurance", "softwareBranch": software_branch},
                    "!=": {"softwareCommit": software_commit},
                    "<=": {"softwareCommitDate": software_commit_date},
                    "like": {"fileKPI": f"{extracted_file_kpi}%"},
                },
                order_list=["softwareCommitDate"],
                limit_result=1,
            )

            if len(previous_commit_list) != 1:
                raise ValueError(
                    f"No previous commit found for {software_branch}, {software_commit[:7]}"
                )

            ref_commit_hash_date = (
                f"{previous_commit_list[0]['softwareCommit'][:7]} "
                + f"{previous_commit_list[0]['softwareCommitDate']}"
            )

            previous_list = {
                extracted_file_kpi: {
                    software_branch: {
                        "ref_commit": previous_commit_list[0]["softwareCommit"],
                        "ref_commit_hash_date": ref_commit_hash_date,
                        "ref_value": None,
                    }
                }
            }
            if extracted_file_kpi in self.previous_commit_dict:
                self.previous_commit_dict[extracted_file_kpi].update(
                    previous_list[extracted_file_kpi]
                )
            else:
                self.previous_commit_dict.update(previous_list)

        return self.previous_commit_dict[extracted_file_kpi][software_branch][
            "ref_commit_hash_date"
        ]

    def compute_endurance_box_plot_increase_degradation(self, commit_test_dict):
        commit_hash_date = (
            f"{commit_test_dict['softwareCommit'][:7]} {commit_test_dict['softwareCommitDate']}"
        )
        ref_commit_hash_date = self.get_previous_hash_date(
            commit_test_dict["extracted_fileKPI"],
            commit_test_dict["softwareBranch"],
            commit_test_dict["softwareCommit"],
            commit_test_dict["softwareCommitDate"],
        )
        test_info = CronBoxPlotIncrease.get_endurance_test_info(
            commit_test_dict["extracted_fileKPI"],
            commit_test_dict["id"],
            commit_test_dict["softwareCommit"],
            commit_hash_date,
            ref_commit_hash_date,
            os.path.sep.join(
                [ROOT_DIR, commit_test_dict["testDate"].strftime("%Y/%m/%d/%H.%M.%S")]
            ),
        )

        previous_commit_dict = self.previous_commit_dict[commit_test_dict["extracted_fileKPI"]][
            commit_test_dict["softwareBranch"]
        ]
        kpi_value = self.context.compute_boxplot_increase(
            test_info, previous_commit_dict["ref_commit"], previous_commit_dict["ref_value"]
        )
        self.context.db_commit()
        previous_commit_dict["ref_commit"] = commit_test_dict["softwareCommit"]
        previous_commit_dict["ref_value"] = kpi_value
        previous_commit_dict["ref_commit_hash_date"] = commit_hash_date

    def get_all_commit_and_test_name_to_check(self):
        return self.context.select_list_into_one_table(
            "Test",
            select_col=[
                "DISTINCT(SUBSTRING(fileKPI, 1, LOCATE(configKey, fileKPI)+LENGTH(configKey)-1))"
                " as extracted_fileKPI",
                "softwareBranch",
                "softwareCommit",
                "softwareCommitDate",
                "MAX(testDate) as testDate",
                "MAX(id) as id",
            ],
            where_dict={
                "=": {"testType": "Endurance"},
                ">": {
                    "softwareCommitDate": self.last_check_date_time
                    - timedelta(hours=DELTA_HOUR_TO_CHECK)
                },
                "<=": {
                    "softwareCommitDate": self.current_date_time
                    - timedelta(hours=DELTA_HOUR_TO_CHECK)
                },
            },
            group_by_str="extracted_fileKPI, softwareBranch, softwareCommit, softwareCommitDate",
            order_list=["softwareBranch", "softwareCommitDate"],
            sort_order="ASC",
            limit_result=0,
        )

    def __init__(self, context):
        super().__init__(context, "checkBoxPlotIncrease")

        print(f"#############\n" f"Start at {self.current_date_time} UTC \n", flush=True)

        nb_except = 0
        nb_commmit = 0

        self.previous_commit_dict = {}
        self.commit_hash_date = None

        for commit_test_dict in self.get_all_commit_and_test_name_to_check():
            try:
                nb_commmit += 1
                self.compute_endurance_box_plot_increase_degradation(commit_test_dict)
            except Exception:
                nb_except += 1
                Report().error()

        self.save_new_last_check_date_time()

        self.context.send_alarm()
        print(
            f"Between {self.last_check_date_time - timedelta(hours=DELTA_HOUR_TO_CHECK)} to "
            f"{self.current_date_time - timedelta(hours=DELTA_HOUR_TO_CHECK)} UTC\n"
            f"{nb_except} exception on {nb_commmit} commit",
            flush=True,
        )


if __name__ == "__main__":
    try:
        context = Context(
            zuul_branch="master",
            check_threshold=True,
            insert_into_db=True,
            send_gerrit_comment=False,
            multiprocess=False,
        )
        CronBoxPlotIncrease(context)
    except Exception:
        Report().error()
