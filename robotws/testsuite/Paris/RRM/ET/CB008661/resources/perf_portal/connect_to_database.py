import mysql.connector


class Database:
    def __init__(self):
        self.database = None

    @staticmethod
    def connect():
        print("Database connection begin", flush=True)
        conn = mysql.connector.connect(
            host="perfport.dyn.nesc.nokia.net",
            user="5gwrite_user",
            passwd="5gwrite_PWD",
            database="perf_5g",
            use_pure=True,
        )
        print("Database connection open", flush=True)
        return conn

    def check_connect(self):
        if not self.database:
            self.database = Database.connect()

    def disconnect(self):
        if self.database:
            print("Database disconnection begin", flush=True)
            self.database.close()
            self.database = None
            print("Database disconnected", flush=True)

    def insert(self, table_name, dictionary):
        """
        Get keys and value from a dict to generate mysql insert command
        :param table_name: table name in the database
        :param dictionary: list of key/values to insert
        :return: last row id
        """
        columns = ",".join(sorted(dictionary.keys()))
        values = ",".join(["%s"] * len(dictionary))
        sql = "INSERT INTO {} ({}) VALUES({})".format(table_name, columns, values)

        self.check_connect()

        my_cursor = self.database.cursor()
        my_cursor.execute(sql, tuple(x[1] for x in sorted(dictionary.items())))

        return my_cursor.lastrowid

    def clean_table(self, table_name, where_dict=None):
        self.check_connect()
        my_cursor = self.database.cursor()

        sql = f"DELETE FROM {table_name}"
        if where_dict:
            where_string, cursor_tuple_var = Database.compute_where_statement(where_dict)
            sql += f" WHERE {where_string}" if where_string else ""
            my_cursor.execute(sql, cursor_tuple_var)
        else:
            my_cursor.execute(sql)

    def commit(self):
        if self.database:
            self.database.commit()

    def rollback(self):
        if self.database:
            self.database.rollback()

    @staticmethod
    def manage_where_with_none(str_to_join, where_dict, operator_is_null=True):
        operator = "is" if operator_is_null else "is not"

        for key in where_dict.copy():
            if where_dict[key] is None:
                del where_dict[key]
                str_to_join = " AND ".join(filter(None, (str_to_join, f"{key} {operator} null")))

        return str_to_join

    @staticmethod
    def compute_where_statement(where_dict):
        """
        :param where_dict:
        :return:
        """

        where_string = (
            Database.manage_where_with_none(None, where_dict["="]) if "=" in where_dict else None
        )

        if "!=" in where_dict:
            where_string = Database.manage_where_with_none(
                where_string, where_dict["!="], operator_is_null=False
            )

        cursor_tuple_var = tuple()
        for operator in where_dict:
            if operator == "in":
                where_string = " AND ".join(
                    filter(
                        None,
                        tuple([where_string])
                        + tuple(
                            f"{x[0]} {operator} ({x[1]})"
                            for x in sorted(where_dict[operator].items())
                        ),
                    )
                )

            else:
                where_string = " AND ".join(
                    filter(
                        None,
                        tuple([where_string])
                        + tuple(
                            f"{x[0]} {operator} %s" for x in sorted(where_dict[operator].items())
                        ),
                    )
                )
                cursor_tuple_var += tuple(x[1] for x in sorted(where_dict[operator].items()))

        return where_string, cursor_tuple_var

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
        """
        :param table_name:
        :param select_col:
        :param where_dict: WARNING content can be change by this method
        :param where_str:
        :param order_list:
        :param sort_order:
        :param group_by_str:
        :param limit_result:
        :return:
        """
        where_dict = {} if not where_dict else where_dict
        where_string, cursor_tuple_var = Database.compute_where_statement(where_dict)
        ordered_string = f" {sort_order}, ".join(order_list) if order_list else ""

        if where_str:
            where_string = " AND ".join(filter(None, [where_string, where_str]))

        sql = f"SELECT {','.join(select_col)} FROM {table_name}"
        sql += f" WHERE {where_string}" if where_string else ""
        sql += f" GROUP BY {group_by_str}" if group_by_str else ""
        sql += f" ORDER BY {ordered_string} {sort_order}" if ordered_string else ""
        if limit_result > 0:
            sql += f" LIMIT {limit_result}"

        self.check_connect()

        print(f"Select {select_col} from {table_name}", flush=True)
        my_cursor = self.database.cursor(dictionary=True)
        my_cursor.execute(sql, cursor_tuple_var)

        col_fetch = my_cursor.fetchall()
        print("Select done", flush=True)
        return col_fetch

    def update_one_table(self, table_name, set_dict, where_dict):
        """
        :param table_name:
        :param set_dict:
        :param where_dict:
        :return:
        """
        where_string, cursor_tuple_var = Database.compute_where_statement(where_dict)

        set_tuple_var = tuple(x[1] for x in sorted(set_dict.items()))
        set_string = ", ".join(filter(None, tuple(f"{x[0]}=%s" for x in sorted(set_dict.items()))))

        self.check_connect()

        my_cursor = self.database.cursor(dictionary=True)
        my_cursor.execute(
            f"UPDATE {table_name} SET {set_string} WHERE {where_string}",
            set_tuple_var + cursor_tuple_var,
        )
        self.commit()

        return my_cursor.rowcount
