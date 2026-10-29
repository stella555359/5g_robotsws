import unittest
from unittest.mock import patch, call
import connect_to_database


class TestDatabase(unittest.TestCase):
    def setUp(self):
        self.mock_connect = patch("mysql.connector.connect", autospec=True).start()
        self.mock_connection = self.mock_connect.return_value
        self.mock_cursor = self.mock_connection.cursor.return_value
        self.mock_cursor.fetchall.return_value = [{"id": 1}]
        self.mock_stdout = patch("sys.stdout.write").start()  # Not checked
        self.addCleanup(patch.stopall)

        self.fixture_dict = {"id": None, "param1": 2, "param2": "A string", "param3": "param3"}
        self.expect_credentials = {
            "host": "perfport.dyn.nesc.nokia.net",
            "user": "5gwrite_user",
            "passwd": "5gwrite_PWD",
            "database": "perf_5g",
            "use_pure": True,
        }
        self.test_info = {
            "board": "ABIL",
            "CCNumber": 1,
            "UENumber": 1,
            "DDtype": "TDD",
            "TTIDuration": 125,
            "UESchedNumber": 1,
            "beamNumber": 1,
            "feature": "ft000",
            "configKey": "SA",
            "softwareBranch": "master",
            "softwareCommit": "commit95",
        }

    def test_given_a_single_database_when_sql_insert_then_execute_returns_all_dict(self):
        database = connect_to_database.Database()
        database.insert("my_table_name", self.fixture_dict)
        database.commit()
        database.disconnect()

        self.mock_connect.assert_called_once_with(**self.expect_credentials)
        self.mock_cursor.execute.assert_called_once_with(
            "INSERT INTO my_table_name (id,param1,param2,param3) VALUES(%s,%s,%s,%s)",
            (None, 2, "A string", "param3"),
        )
        self.mock_connection.commit.assert_called_once_with()
        self.mock_connection.rollback.assert_not_called()
        self.mock_connection.close.assert_called_once_with()

    def test_clean_table(self):
        database = connect_to_database.Database()
        database.clean_table("tableToClean", where_dict={"in": {"softwareCommit": "'c1', 'c3'"}})
        database.clean_table("tableToClean")
        database.commit()
        database.disconnect()

        self.mock_connect.assert_called_once_with(**self.expect_credentials)
        self.mock_cursor.execute.assert_has_calls(
            [
                call("DELETE FROM tableToClean WHERE softwareCommit in ('c1', 'c3')", ()),
                call("DELETE FROM tableToClean"),
            ]
        )
        self.assertEqual(self.mock_cursor.execute.call_count, 2)

        self.mock_connection.commit.assert_called_once_with()
        self.mock_connection.rollback.assert_not_called()
        self.mock_connection.close.assert_called_once_with()

    def test_update_one_table(self):
        database = connect_to_database.Database()
        table_name = "Test"
        set_dict = {"set_key_string": "set_val_string", "set_key_num": 10}
        where_dict = {
            "=": {"where_equal_key_string": "where_equal_val_string", "where_equal_key_int": 100},
            "<": {"where_inf_date": "2020-07-29 10:00:00"},
        }
        database.update_one_table(table_name, set_dict, where_dict)
        database.disconnect()

        self.mock_cursor.execute.assert_called_once_with(
            f"UPDATE {table_name} SET set_key_num=%s, set_key_string=%s WHERE "
            "where_equal_key_int = %s AND where_equal_key_string = %s AND where_inf_date < %s",
            (10, "set_val_string", 100, "where_equal_val_string", "2020-07-29 10:00:00"),
        )
        self.mock_connection.commit.assert_called_once_with()
        self.mock_connection.rollback.assert_not_called()
        self.mock_connection.close.assert_called_once_with()

    def test_select_list_into_one_table(self):
        database = connect_to_database.Database()

        table_name = "Test"
        select_values = {"b": "ABIL", "C": 1, "valIsNone": None}
        except_values = {"id": 1234, "ex2": "exclude2", "exIsNone": None}
        ordered_desc_fields = ["ord1", "ord2"]

        self.assertListEqual(
            database.select_list_into_one_table(
                table_name,
                where_dict={"=": select_values.copy(), "in": {"testId": "10, 20"}},
                where_str="id=100",
                order_list=ordered_desc_fields,
            ),
            [{"id": 1}],
        )

        database.select_list_into_one_table(
            table_name,
            where_dict={"=": select_values.copy(), "!=": except_values.copy()},
            order_list=ordered_desc_fields,
        )

        ordered_desc_fields = []
        self.assertListEqual(
            database.select_list_into_one_table(
                table_name,
                where_dict={"=": select_values.copy(), "!=": except_values.copy()},
                order_list=ordered_desc_fields,
                limit_result=5,
            ),
            [{"id": 1}],
        )

        database.select_list_into_one_table(
            table_name, where_dict={"!=": except_values.copy()}, limit_result=5
        )

        database.select_list_into_one_table(
            table_name, where_dict={}, order_list=ordered_desc_fields, limit_result=5
        )

        database.select_list_into_one_table(
            table_name,
            select_col=["max(id)", "col1", "col02"],
            order_list=ordered_desc_fields,
            limit_result=5,
        )

        database.rollback()

        database.disconnect()

        self.mock_cursor.execute.assert_has_calls(
            [
                call(
                    "SELECT id FROM Test WHERE valIsNone is null AND C = %s AND b = %s AND "
                    "testId in (10, 20) AND id=100 ORDER BY ord1 DESC, ord2 DESC LIMIT 1",
                    (1, "ABIL"),
                ),
                call(
                    "SELECT id FROM Test WHERE valIsNone is null AND exIsNone is not null AND C = %"
                    "s AND b = %s AND ex2 != %s AND id != %s ORDER BY ord1 DESC, ord2 DESC LIMIT 1",
                    (1, "ABIL", "exclude2", 1234),
                ),
                call(
                    "SELECT id FROM Test WHERE valIsNone is null AND exIsNone is not null AND "
                    "C = %s AND b = %s AND ex2 != %s AND id != %s LIMIT 5",
                    (1, "ABIL", "exclude2", 1234),
                ),
                call(
                    "SELECT id FROM Test WHERE exIsNone is not null AND "
                    "ex2 != %s AND id != %s LIMIT 5",
                    ("exclude2", 1234),
                ),
                call("SELECT id FROM Test LIMIT 5", ()),
                call("SELECT max(id),col1,col02 FROM Test LIMIT 5", ()),
            ],
            any_order=False,
        )

        self.mock_connection.commit.assert_not_called()
        self.mock_connection.rollback.assert_called_once_with()
        self.mock_connection.close.assert_called_once_with()
