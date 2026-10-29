# Copyright (c) 2024 Nokia. All rights reserved.

import argparse
import sqlite3
import pathlib
import json
import zlib
import base64
import sys
import logging

from contextlib import closing

logger = logging.getLogger(__name__)

OAM_CONNECT_RETRY = 3
_DB_TIMEOUT = 10.0
_DB_INSERT_PATH = None


def connect_to_database(db="test.db"):
    global _DB_INSERT_PATH
    _DB_INSERT_PATH = db
    conn = None
    try:
        conn = sqlite3.connect(_DB_INSERT_PATH, timeout=_DB_TIMEOUT)
    except sqlite3.OperationalError as e:
        logger.error("connect_to_database sqlite3.OperationalError %s", e)
        return False
    finally:
        try:
            conn.close()
        except UnboundLocalError:
            pass
    return True


# CREATE
def insert_testcase(data):
    header, value = generate_csv_for_data(data)
    return insert_to_db(f"""
    INSERT INTO testcase ({header})
        VALUES ({value});
    """)


def update_testcase_pass(testcase_id, verdict=-1):
    return insert_to_db(f"""
    UPDATE testcase
        SET pass='{verdict}'
    WHERE testcase_id='{testcase_id}';
    """)


def insert_testresults_cell(testcase_id, data):
    return insert_common_testcase_format('testresults_cell', testcase_id, data)


def insert_testline(testcase_id, data):
    return insert_common_testcase_format('testline', testcase_id, data)


def insert_testcase_parameter(testcase_id, data):
    return insert_common_testcase_format('testcase_parameter', testcase_id, data)


def insert_software(testcase_id, data):
    return insert_common_testcase_format('software', testcase_id, data)


def insert_testcase_flags(testcase_id, data):
    if data['testcase_flags_value'] != 'null':
        return insert_common_testcase_format('testcase_flags', testcase_id, data)


def insert_testcase_parameter2_with_args(testcase_id, testcase_parameter2_name, testcase_parameter2_value):
    return insert_common_testcase_format('testcase_parameter2', testcase_id, {
        'testcase_parameter2_name': testcase_parameter2_name,
        'testcase_parameter2_value': testcase_parameter2_value
    })


def insert_testcase_results_with_args(testcase_id, testcase_results_name, testcase_results_value):
    return insert_common_testcase_format('testcase_results', testcase_id, {
        'testcase_results_name': testcase_results_name,
        'testcase_results_value': testcase_results_value
    })


def insert_pmcounters_dict(testcase_id, pm_dictionary, ignore_zero=True):
    """
    {
        '< pm Name: str >' : {
            "distnames" : {
                < distname: str > : < INT >,
                ...
            }
        },
        ...
    }
    """
    if not isinstance(pm_dictionary, dict):
        return -1
    cmd = r"INSERT INTO 'pmcounter' ('testcase_id', 'piid_name', 'piid_value', 'distname') VALUES"
    for piid, data in pm_dictionary.items():
        if ignore_zero and data['distnames'].get('mean', 0) == 0:
            continue
        for distname, value in data['distnames'].items():
            cmd = f"{cmd}\n ( '{testcase_id}', '{piid}', '{value}', '{distname}' ),"
    cmd = cmd[:-1]
    cmd = f"{cmd};"
    return insert_to_db(cmd)


def insert_pmcounters(testcase_id, data):
    return insert_common_testcase_format('pmcounter', testcase_id, data)


def insert_testcase_jenkins_data(testcase_id, data):
    return insert_common_testcase_format('testcase_jenkins_data', testcase_id, data)


def insert_kpi_dict(testcase_id, data, ignore_zero=True):
    """
    :data:
        {
            '< KPI ID: str >': {
                'name': < str >,
                'description': < str >,
                'distnames': {
                        < distname: str > :  < INT >
                    }
                }
            },
            ...
            ...
        }
    """
    logger.debug("insert_kpi_dict")
    if not isinstance(data, dict):
        return -1
    cmd = r"INSERT INTO 'kpi' ('testcase_id', 'kpi_id', 'kpi_name', 'kpi_value', 'kpi_distname') VALUES"
    for kpi_id, kpi_data in data.items():
        if ignore_zero and kpi_data['distnames'].get('mean', 0.0) == 0.0:
            continue
        for distname, value in kpi_data['distnames'].items():
            try:
                value = float(value)
                cmd = f"{cmd}\n ( '{testcase_id}', '{kpi_id}', '{kpi_data['name']}', '{value}', '{distname}' ),"
            except TypeError:
                logger.error("TypeError [%s] (%s) %s", kpi_id, distname, value)
    cmd = cmd[:-1]
    cmd = f"{cmd};"
    return insert_to_db(cmd)


def insert_kpi(testcase_id, data):
    return insert_common_testcase_format('kpi', testcase_id, data)


def insert_emperf_dict(testcase_id, data):
    for container in data['emperf']:
        emperf_id = insert_emperf(testcase_id, {
            'container': container
        })
        for disp in data['emperf'][container]:
            insert_disp(emperf_id, disp)


def insert_emperf(testcase_id, data):
    return insert_common_testcase_format('emperf', testcase_id, data)


def insert_disp(emperf_id, data):
    return insert_common_testcase_format('disp', emperf_id, data, pk_name='emperf_id')


def insert_common_testcase_format(table, pk_id, data, pk_name='testcase_id'):
    header, value = generate_csv_for_data(data)
    return insert_to_db(f"""
    INSERT INTO '{table}' ('{pk_name}', {header})
        VALUES ('{pk_id}', {value});
    """)


def insert_testline_type(topology, variant):
    return insert_to_db(f"""
INSERT INTO testline_type(testline_topology, testline_variant) VALUES
    ('{topology}', '{variant}')
""")


def insert_hash_if_not_exists(hash_name, hash_value, hash_content, overwrite=False, compress=True):
    query = get_hash(hash_name, hash_value)
    if query is not None and not overwrite:
        logger.info("hash exists: %s, %s", hash_name, hash_value)
        return 'exists'
    hash_content_compressed = base64.b64encode(zlib.compress(bytes(hash_content, 'utf-8'))).decode()
    if sys.getsizeof(hash_content_compressed) < sys.getsizeof(hash_content) and compress:
        content = hash_content_compressed
    else:
        content = hash_content.replace("'", '').replace("\"", '')
    insert_to_db(f"""
INSERT INTO hash(hash_name, hash_value, hash_content) VALUES
    ('{hash_name}', '{hash_value}', '{content}')
""")
    if query is not None and overwrite:
        return query[0][3]
    return 'new'


def insert_to_db(insert_cmd):
    global _DB_INSERT_PATH
    if _DB_INSERT_PATH is None:
        logger.error("DB not initialized")
        return None
    try:
        with closing(sqlite3.connect(_DB_INSERT_PATH, timeout=_DB_TIMEOUT)) as conn:
            with closing(conn.cursor()) as cursor:
                logger.debug("[insert_to_db] \n%s", insert_cmd)
                cursor.execute(insert_cmd)
                rowid = cursor.lastrowid
                logger.debug("[rowid] %s", rowid)
            conn.commit()
    except sqlite3.OperationalError as e:
        logger.error("insert_to_db sqlite3.OperationalError %s", e)
        return None
    except sqlite3.ProgrammingError as e:
        logger.error("insert_to_db sqlite3.ProgrammingError %s", e)
        return None
    return rowid


def generate_csv_for_data(data):
    header = ''
    value = ''
    for key in data:
        header = f"{header},'{key}'"
        value = f"{value},'{data[key]}'"
    return (header[1:], value[1:])


def get_hash(hash_name, hash_value, limit=0):
    result = execute_select_cmd(f"""
    SELECT  hash.hash_name, hash.hash_value, hash.hash_date, hash.hash_content
    FROM hash
    WHERE
        hash.hash_name='{hash_name}'
        AND hash.hash_value='{hash_value}'
    ORDER BY hash.hash_date ASC
    """, limit=limit, fetch='fetchall')
    if result is None:
        return None
    return None if len(result) == 0 else result


def execute_select_cmd(cmd, limit=0, fetch='fetchone'):
    global _DB_INSERT_PATH
    if _DB_INSERT_PATH is None:
        logger.error("DB not initialized")
        return None
    limit_query = '' if limit == 0 else f"LIMIT {limit}"
    cmd = f"""
    {cmd}
    {limit_query};
    """
    logger.debug("execute_select_cmd \n%s", cmd)
    ret = None
    try:
        with closing(sqlite3.connect(_DB_INSERT_PATH, timeout=_DB_TIMEOUT)) as conn:
            with closing(conn.cursor()) as cursor:
                if fetch is not None:
                    ret = getattr(cursor.execute(cmd), fetch)()
                else:
                    ret = cursor.execute(cmd)
    except sqlite3.OperationalError as e:
        logger.error("sqlite3.OperationalError %s", e)
        return None
    except sqlite3.ProgrammingError as e:
        logger.error("sqlite3.ProgrammingError %s", e)
        return None
    return ret


# TEST
def insert_full_testcase(json_path, testname=None):
    with open(json_path) as f:
        data = json.load(f)
    if testname is not None:
        data['testcase']['testname'] = testname

    testcase_id = insert_testcase(data['testcase'])
    insert_testcase_parameter(testcase_id, data['testcase_parameter'])

    insert_software(testcase_id, data['software'])

    insert_testline(testcase_id, data['testline'])

    for hash in data['hash']:
        insert_hash_if_not_exists(hash['hash_name'], hash['hash_value'], hash['hash_content'])

    for testcase_flags in data['testcase_flags']:
        insert_testcase_flags(testcase_id, testcase_flags)

    for testcase_parameter2 in data['testcase_parameter2']:
        insert_testcase_parameter2_with_args(testcase_id,
                                             testcase_parameter2["testcase_parameter2_name"],
                                             testcase_parameter2["testcase_parameter2_value"]
                                             )

    for testcase_results in data['testcase_results']:
        insert_testcase_results_with_args(testcase_id,
                                          testcase_results["testcase_results_name"],
                                          testcase_results["testcase_results_value"]
                                          )

    for piid in data['pmcounters']:
        insert_pmcounters(testcase_id, piid)

    insert_testcase_jenkins_data(testcase_id, data['testcase_jenkins_data'])

    for kpi in data['kpi']:
        for kpi in data['kpi']:
            insert_kpi(testcase_id, kpi)

    for container in data['emperf']:
        emperf_id = insert_emperf(testcase_id, {
            'container': container
        })
        for disp in data['emperf'][container]:
            insert_disp(emperf_id, disp)


def main():
    logging.basicConfig(
        format="%(asctime)s|%(levelname)-5.5s|%(module)s.%(funcName)s:%(lineno)d:%(message)s",
        encoding='utf-8',
        level=logging.DEBUG
    )
    logger.info('start db_interface_insert.py')

    parser = argparse.ArgumentParser(description='db_interface_insert.py')
    parser.add_argument('--json')
    parser.add_argument('--database', default='test.db')
    parser.add_argument('--testname', default=None)
    args = parser.parse_args()

    json_file = pathlib.Path(__file__).parent.resolve().joinpath(
        'testcase_dummy.json') if args.json == 'dummy' else args.json

    connect_to_database(db=args.database)
    insert_full_testcase(json_file, testname=args.testname)
    logger.info('end db_interface_insert.py')


if __name__ == "__main__":
    main()
