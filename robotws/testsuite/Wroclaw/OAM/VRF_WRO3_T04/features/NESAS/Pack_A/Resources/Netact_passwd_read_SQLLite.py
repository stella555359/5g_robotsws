#!/usr/bin/env python3

import sqlite3


def create_connection(db_file):
    """ create a database connection to the SQLite database
        specified by the db_file
    :param db_file: database file
    :return: Connection object or None
    """
    conn = None
    try:
        conn = sqlite3.connect(db_file)
    except Error as e:
        print(e)

    return conn


def select_all_rows(conn):
    """
    Query all rows in the wsuser table
    :param conn: the Connection object
    :return:
    """
    cur = conn.cursor()
    cur.execute("SELECT * FROM TBL_WSUSER")

    rows = cur.fetchall()

    for row in rows:
        print(row)


def main():
    database = r"/ffs/run/config/ne3sadapt/configs/ne3sadaptdata.db"

    # create a database connection
    conn = create_connection(database)
    with conn:
        print("Query WSUSER passwd from SQLite DB:")
        select_all_rows(conn)


if __name__ == '__main__':
    main()
