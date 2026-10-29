import unittest
from unittest.mock import patch
from datetime import datetime
from crontab import Crontab


class TestCrontab(unittest.TestCase):
    def setUp(self):
        self.current_datetime = datetime(2022, 1, 1, 0, 0, 0, 0)
        self.mock = {
            "datetime": patch("crontab.datetime", autospec=True).start(),
            "context": patch("context.Context", autospec=True).start(),
        }

        self.mock["datetime"].utcnow.return_value = self.current_datetime
        self.mock["context"].return_value.select_list_into_one_table.side_effect = [ConnectionError]

        self.addCleanup(patch.stopall)

    def test_instanciate_nok(self):
        self.assertRaisesRegex(TypeError, "abstract", Crontab, "dummy_context", "dummy_action")

    def test_derived_class_without_get_default_last_check_date_time_method(self):
        class BadDerivedFromCrontab(Crontab):
            pass

        self.assertRaisesRegex(TypeError, "abstract", BadDerivedFromCrontab)

    def test_derived_class_and_save_ok(self):
        class GoodDerivedFromCrontab(Crontab):
            def __init__(self, context):
                super().__init__(context, "my_dummy_action")

            def get_default_last_check_date_time(self):
                return "my_dummy_default_value"

        good_crontab_obj = GoodDerivedFromCrontab(self.mock["context"].return_value)
        self.assertIsInstance(good_crontab_obj, GoodDerivedFromCrontab)
        self.assertIsInstance(good_crontab_obj, Crontab)
        self.assertEqual(self.current_datetime, good_crontab_obj.current_date_time)
        self.mock["context"].return_value.select_list_into_one_table.assert_called_once_with(
            "CrontabLastRefresh",
            select_col=["lastRefreshDate"],
            where_dict={"=": {"action": "my_dummy_action"}},
        )
        self.assertEqual(good_crontab_obj.last_check_date_time, "my_dummy_default_value")

        good_crontab_obj.save_new_last_check_date_time()
        self.mock["context"].return_value.update_one_table.assert_called_once_with(
            "CrontabLastRefresh",
            set_dict={"lastRefreshDate": self.current_datetime},
            where_dict={"=": {"action": "my_dummy_action"}},
        )
