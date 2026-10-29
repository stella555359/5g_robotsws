from abc import ABC, abstractmethod
from datetime import datetime


class Crontab(ABC):
    def __init__(self, context, action):
        self.context = context
        self.current_date_time = datetime.utcnow()
        self.action = action
        self.last_check_date_time = self.set_last_check_date_time()

    @abstractmethod
    def get_default_last_check_date_time(self):
        pass

    def set_last_check_date_time(self):
        try:
            return self.context.select_list_into_one_table(
                "CrontabLastRefresh",
                select_col=["lastRefreshDate"],
                where_dict={"=": {"action": self.action}},
            )[0]["lastRefreshDate"]
        except Exception:
            return self.get_default_last_check_date_time()

    def save_new_last_check_date_time(self):
        self.context.update_one_table(
            "CrontabLastRefresh",
            set_dict={"lastRefreshDate": self.current_date_time},
            where_dict={"=": {"action": self.action}},
        )
