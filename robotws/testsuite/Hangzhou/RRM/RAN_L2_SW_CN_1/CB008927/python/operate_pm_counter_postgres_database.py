#!/usr/bin/env python3
# document: insert,delete,update,query
# https://cloud.tencent.com/developer/article/1868984
# https://cloud.tencent.com/developer/article/1406447
# https://support.huaweicloud.com/mgtg-dws/dws_01_0120.html
# https://blog.csdn.net/xc_zhou/article/details/82085988

import sys
import importlib
import subprocess
import pkgutil
import datetime
import os
# import pandas
# import psycopg2


def install_package(package):
    try:
        subprocess.call(['pip', 'install', '-U', package])
    except Exception as e:
        raise (AssertionError("Error installing package " + str(e)))


def install_and_import_package(package_name='psycopg2'):
    if not bool(pkgutil.find_loader(package_name)):
        install_package(package_name)
    return importlib.import_module(package_name)


def connect_to_db(db_config_file: str) -> object:
    with open(db_config_file, 'r') as f:
        db_config_str = f.read()

    conn = psycopg2.connect(db_config_str)
    # create a cursor
    cur = conn.cursor()
    return cur, conn


def insert_records_to_logs_table(
        cur,
        conn,
        test_case_id,
        rat_mode,
        pm_counter_id,
        counter_value):
    time_stamp = str(datetime.datetime.now().strftime("%m-%d-%Y %H:%M:%S"))
    print(time_stamp)
    sql_cmd = "insert into pm_counter_results values('{}','{}','{}',{},'{}')".format(
        test_case_id, rat_mode, pm_counter_id, counter_value, time_stamp)
    print(sql_cmd)
    cur.execute(sql_cmd)
    conn.commit()
    print("insert into record sucessfully")


def update_records_on_logs_table(cur, conn):
    time_stamp = str(datetime.datetime.now().strftime("%m-%d-%Y %H:%M:%S"))
    cur.execute(
        "update exec_logs set test_exec_time=%s where enb_id=%s",
        (time_stamp,
         11806))
    cur.execute(
        "update exec_logs set test_exec_time=%s where enb_id=%s",
        (time_stamp,
         11060))
    conn.commit()


def query_db_version(cur):
    print('PostgreSQL database version:')
    cur.execute('SELECT version()')
    all_data = cur.fetchall()
    print(all_data)


def query_db_tables(cur):
    print('PostgreSQL database tables:')
    cur.execute(r"SELECT * from pg_tables where schemaname='public'")
    all_data = cur.fetchall()
    for i in all_data:
        print(i)


def query_db_table_columns(cur, table_name='ta_timemarker_results'):
    print('PostgreSQL database table columns:{}'.format(table_name))
    cur.execute(
        r"select * from information_schema.columns where table_name='{}'".format(table_name))
    all_data = cur.fetchall()
    for i in all_data:
        print(i[3])


def query_all_data_from_table(cur, table_name="ta_timemarker_results"):
    print("PostgreSQL table data:")
    cur.execute("select * from {}".format(table_name))
    all_data = cur.fetchall()
    for i in all_data:
        print(i)


def query_all_data_from_table_by_pandas_0(db_config_file='', table_name=''):
    with open(db_config_file, 'r') as f:
        db_config_str = f.read()
    conn = psycopg2.connect(db_config_str)
    print("PostgreSQL table data query by pandas:")
    data_frame = pandas.read_sql("select * from {}".format(table_name), conn)
    print(data_frame.columns)
    print(data_frame)


def query_all_data_from_table_by_pandas(conn, table_name=''):
    print("PostgreSQL table data query by pandas:")
    data_frame = pandas.read_sql("select * from {}".format(table_name), conn)
    print(data_frame.columns)
    print(data_frame)


def help():
    file_name = __file__
    log = """
        {0} insert [test_case_id] [rat_mode] [pm_counter_id] [counter_value] [time_stamp]
        {0} update
        {0} query
        {0} clear
    """.format(file_name)
    print(log)


def clear_table(cur, conn, table_name="pm_counter_results"):
    cur.execute(
        "truncate table {}".format(table_name))
    conn.commit()


def main(argv) -> int:
    operate_type = 'help'
    try:
        operate_type = argv[1]
        test_case_id = argv[2]
        rat_mode = argv[3]
        pm_counter_id = argv[4]
        counter_value = argv[5]
    except Exception as e:
        print(argv)
        # print(e.args)
        # print(str(e))
        print(repr(e))
        print("Argument is not full.")

    curdir = os.path.dirname(__file__)
    config_file = os.path.join(curdir, 'db-config.secret')
    cur, conn = connect_to_db(config_file)
    if operate_type == 'insert':
        insert_records_to_logs_table(
            cur, conn, test_case_id, rat_mode, pm_counter_id, counter_value)
    elif operate_type == 'update':
        update_records_on_logs_table(cur, conn)
    elif operate_type == 'query':
        query_db_version(cur)
        query_db_tables(cur)
        query_all_data_from_table(cur, 'pm_counter_results')
        query_all_data_from_table_by_pandas(conn, 'pm_counter_results')
    elif operate_type == 'clear':
        clear_table(cur, conn, table_name="pm_counter_results")
    else:
        help()
    print('All operations done successfully.', flush=True)
    return 0


if __name__ == '__main__':
    pandas = install_and_import_package('pandas')
    psycopg2 = install_and_import_package('psycopg2')
    exit(main(sys.argv))
