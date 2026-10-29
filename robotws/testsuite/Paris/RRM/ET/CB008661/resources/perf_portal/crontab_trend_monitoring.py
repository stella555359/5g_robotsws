from datetime import timedelta
from context import Context
from database_table_object import TableRelatedCommit
from crontab import Crontab
from report import Report

NB_COMMIT = 5
BRANCH = "master"
TEST_NAME = "TimeMarkerKPIv2_L2RT_ft000_perfOnFuse_4CC_48UE_TDD125_ABIL_CFG_SA_LA_HARQ_REF_"


class TrendMonitoring(Crontab):
    def __init__(self, context):
        global BRANCH, TEST_NAME

        super().__init__(context, "trendMonitoring")

        self.commit_created_after_last_check = self.context.select_list_into_one_table(
            "Test",
            select_col=["distinct(softwareCommit), softwareCommitDate"],
            where_dict={
                ">=": {"createdDateTime": self.last_check_date_time},
                "=": {"softwareBranch": BRANCH, "testType": "Endurance"},
                "like": {"fileKPI": f"{TEST_NAME}%"},
            },
            order_list=["softwareCommitDate"],
            sort_order="ASC",
            limit_result=0,
        )
        self.related_commit_dict = {}
        self.commit_into_related_table_list = self.get_commit_into_related_table()
        self.make_job()

    def get_default_last_check_date_time(self):
        return self.current_date_time - timedelta(days=3)

    def get_commit_into_related_table(self):
        lst_new_commit_str = ",".join(
            filter(
                None,
                tuple(f"'{x['softwareCommit']}'" for x in self.commit_created_after_last_check),
            )
        )
        db_res = self.context.select_list_into_one_table(
            "RelatedCommit",
            select_col=["softwareCommit"],
            where_dict={
                "in": {"softwareCommit": lst_new_commit_str},
                "=": {"softwareBranch": BRANCH},
            },
            limit_result=0,
        )
        commit_into_related_list = []
        for commit_info in db_res:
            commit_into_related_list.append(commit_info["softwareCommit"])

        return commit_into_related_list

    def compute_related_commit(self, commit_date):
        global BRANCH, TEST_NAME, NB_COMMIT

        related_commit_list = self.context.select_list_into_one_table(
            "Test",
            select_col=["DISTINCT softwareCommit", "softwareCommitDate"],
            where_dict={
                "=": {"testType": "Endurance", "softwareBranch": BRANCH},
                "like": {"fileKPI": f"{TEST_NAME}%"},
                "<=": {"softwareCommitDate": commit_date},
            },
            order_list=["softwareCommitDate"],
            limit_result=(NB_COMMIT + 1),
        )

        return related_commit_list + self.context.select_list_into_one_table(
            "Test",
            select_col=["DISTINCT softwareCommit", "softwareCommitDate"],
            where_dict={
                "=": {"testType": "Endurance", "softwareBranch": BRANCH},
                "like": {"fileKPI": f"{TEST_NAME}%"},
                ">": {"softwareCommitDate": commit_date},
            },
            order_list=["softwareCommitDate"],
            sort_order="ASC",
            limit_result=NB_COMMIT,
        )

    def compute_related_and_save(self, commit_info):
        related_commit_list = self.compute_related_commit(commit_info["softwareCommitDate"])
        need_to_save = True if len(related_commit_list) == 2 * NB_COMMIT + 1 else False
        for related_commit_info in related_commit_list:
            self.related_commit_dict.update(
                {related_commit_info["softwareCommit"]: related_commit_info}
            )
            if need_to_save:
                TableRelatedCommit(
                    self.context,
                    BRANCH,
                    commit_info["softwareCommit"],
                    commit_info["softwareCommitDate"],
                    related_commit_info["softwareCommit"],
                ).save_into_db()

        return need_to_save

    def make_job(self):
        global NB_COMMIT

        if not self.commit_created_after_last_check:
            print("No commit to check", flush=True)
            return

        ignored_commit_list = []
        for commit_info in self.commit_created_after_last_check:
            if commit_info["softwareCommit"] in self.commit_into_related_table_list:
                ignored_commit_list.append(commit_info["softwareCommit"])
            else:
                if not self.compute_related_and_save(commit_info):
                    break

        xor_related_commit_list = list(
            set(self.related_commit_dict.keys()).difference(
                commit_info["softwareCommit"]
                for commit_info in self.commit_created_after_last_check
            )
        ) + list(set(self.related_commit_dict.keys()) & set(ignored_commit_list))

        self.context.delete_into_db(
            "RelatedCommit",
            where_dict={
                "=": {"softwareBranch": BRANCH},
                "in": {
                    "softwareCommit": ",".join(
                        filter(None, [f"'{c_name}'" for c_name in xor_related_commit_list])
                    )
                },
            },
        )

        for commit_name in xor_related_commit_list:
            self.compute_related_and_save(self.related_commit_dict[commit_name])


if __name__ == "__main__":
    try:
        context = Context(
            zuul_branch=BRANCH,
            check_threshold=False,
            insert_into_db=True,
            send_gerrit_comment=False,
            multiprocess=False,
        )

        trend = TrendMonitoring(context)
        trend.save_new_last_check_date_time()
        context.db_commit()
    except Exception:
        Report().error()
