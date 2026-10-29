import os
from datetime import timedelta
from crontab import Crontab
from report import Report
from context import Context


ROOT_DIR = "/5g_storage/PatchServer/perfport"
DELTA_WEEKS_TO_CHECK = 12


class CronDelFileOnDD(Crontab):
    def get_all_chrome_tracing_file_to_del(self):
        left_time = self.last_check_date_time - timedelta(weeks=DELTA_WEEKS_TO_CHECK)
        right_time = self.current_date_time - timedelta(weeks=DELTA_WEEKS_TO_CHECK)

        print(f"Search chrome tracing file between {left_time} and {right_time}")

        return self.context.select_list_into_one_table(
            "Test",
            select_col=["id", "testDate", "fileChromeTracing"],
            where_dict={
                "!=": {"testType": "Endurance", "fileChromeTracing": None},
                ">": {"softwareCommitDate": left_time},
                "<=": {"softwareCommitDate": right_time},
            },
            limit_result=0,
        )

    def set_chrome_tracing_file_to_null_into_db(self, test_id):
        return self.context.update_one_table(
            "Test", {"fileChromeTracing": None}, {"=": {"id": test_id}}
        )

    def get_default_last_check_date_time(self):
        global DELTA_WEEKS_TO_CHECK
        return self.current_date_time - timedelta(weeks=DELTA_WEEKS_TO_CHECK)

    def __init__(self, context):
        super().__init__(context, "checkDelFileOnDD")

        print(f"#############\n" f"Start at {self.current_date_time} UTC \n", flush=True)

        for file_info in self.get_all_chrome_tracing_file_to_del():
            filename_full_path = os.sep.join(
                [
                    ROOT_DIR,
                    file_info["testDate"].strftime("%Y/%m/%d/%H.%M.%S"),
                    file_info["fileChromeTracing"],
                ]
            )

            try:
                os.remove(filename_full_path)
                self.set_chrome_tracing_file_to_null_into_db(file_info["id"])
                print(f"{filename_full_path} DELETED", flush=True)
            except Exception as exc:
                print(f"Something was wrong with {filename_full_path}: {exc}", flush=True)

        self.save_new_last_check_date_time()


if __name__ == "__main__":
    try:
        context = Context(
            zuul_branch="master",
            check_threshold=False,
            insert_into_db=True,
            send_gerrit_comment=False,
            multiprocess=False,
        )
        CronDelFileOnDD(context)
        context.db_commit()
    except Exception:
        Report().error()
