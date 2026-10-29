# Copyright (c) 2024 Nokia. All rights reserved.

import argparse
import sqlite3
import zlib
import base64
import logging

from contextlib import closing

logger = logging.getLogger(__name__)


_DB_TIMEOUT = 10.0
_DB_RETRIEVE_PATH = None


def connect_to_database(db="test.db"):
    global _DB_RETRIEVE_PATH
    _DB_RETRIEVE_PATH = db
    try:
        conn = sqlite3.connect(_DB_RETRIEVE_PATH, timeout=_DB_TIMEOUT)
    except sqlite3.OperationalError as e:
        logger.error("connect_to_database sqlite3.OperationalError %s", e)
        return False
    finally:
        try:
            conn.close()
        except UnboundLocalError:
            pass
    return True


def get_last_testcase_id(testcase_name):
    testcase_id = execute_select_cmd(f"""
    SELECT testcase.testcase_id
    FROM testcase
    WHERE
        testname='{testcase_name}'
    ORDER BY testdate DESC, testcase.testcase_id DESC
    """, limit=1)
    if testcase_id is None:
        return None
    return testcase_id[0] if testcase_id is not None else None


def get_last_testcase_id_with_emperf_data(testcase_name):
    testcase_id = execute_select_cmd(f"""
    SELECT testcase.testcase_id
    FROM testcase
    INNER JOIN emperf
            ON emperf.testcase_id=testcase.testcase_id
    WHERE
        testname='{testcase_name}'
    ORDER BY testdate DESC, testcase.testcase_id DESC
    """, limit=1)
    if testcase_id is None:
        return None
    return testcase_id[0] if testcase_id is not None else None


def get_last_testcase_id_with_kpi_data(testcase_name):
    testcase_id = execute_select_cmd(f"""
    SELECT testcase.testcase_id
    FROM testcase
    INNER JOIN kpi
            ON kpi.testcase_id=testcase.testcase_id
    WHERE
        testname='{testcase_name}'
    ORDER BY testdate DESC, testcase.testcase_id DESC
    """, limit=1)
    if testcase_id is None:
        return None
    return testcase_id[0] if testcase_id is not None else None


def get_testcase_id_fiter_with_testcase_flag_name(testcase_name, testcase_flags_name, testcase_flags_value):
    testcase_id = execute_select_cmd(f"""
    SELECT testcase.testcase_id
            FROM testcase
            LEFT JOIN testcase_flags
                ON testcase_flags.testcase_id=testcase.testcase_id
            WHERE testcase_flags_name='{testcase_flags_name}'
              AND testcase_flags_value='{testcase_flags_value}'
              AND testcase.testname='{testcase_name}'
            ORDER BY testcase.testcase_id DESC, testdate DES
            LIMIT 1
    """, limit=1)
    if testcase_id is None:
        return None
    return testcase_id[0] if testcase_id is not None else None


def get_jenkins_url(testcase_id):
    job_url = execute_select_cmd(f"""
    SELECT JOB_URL || BUILD_ID as url
    FROM testcase_jenkins_data
    WHERE
        testcase_id={testcase_id}
    """, limit=1)
    if job_url is None:
        return None
    return job_url[0] if job_url is not None else None


def get_testline_name(testcase_id):
    testline_name = execute_select_cmd(f"""
    SELECT testline_name
    FROM testline
    WHERE
        testcase_id={testcase_id}
    """, limit=1)
    if testline_name is None:
        return None
    return testline_name[0] if testline_name is not None else None


def get_turandot_link(testcase_id):
    turandot_link = execute_select_cmd(f"""
    SELECT testline.testline_name || '/' || testcase.testname || '/' || testcase_jenkins_data.BUILD_ID as turandot_link
    FROM testcase
    INNER JOIN testline
        ON testcase.testcase_id=testline.testcase_id
    INNER JOIN testcase_jenkins_data
        ON testcase.testcase_id=testcase_jenkins_data.testcase_id
    WHERE
        testline.testcase_id={testcase_id}
    """, limit=1)
    if turandot_link is None:
        return None
    return turandot_link[0] if turandot_link is not None else None


def get_testline_type_id(topology, variant):
    testline_type_id = execute_select_cmd(f"""
    SELECT testline_type.testline_type_id
    FROM testline_type
    WHERE
        testline_topology='{topology}'
        AND    testline_variant='{variant}'
    """, limit=1)
    if testline_type_id is None:
        return None
    return testline_type_id[0] if testline_type_id is not None else None


def get_emperf_disps(testcase_id, container=None, disp_number=None, limit=0):
    disp_number_query = '' if disp_number is None else f"AND disp.disp_number = '{disp_number}'"
    container_query = '' if container is None else f"AND emperf.container = '{container}'"
    result = execute_select_cmd(f"""
    SELECT  testcase.testcase_id,
            testname,
            testdate,
            emperf.container,
            disp.disp_number,
            average,
            minimum,
            maximum,
            emperf_map.disp_name
    FROM testcase
        LEFT JOIN emperf
            ON emperf.testcase_id=testcase.testcase_id
        LEFT JOIN disp
            ON disp.emperf_id=emperf.emperf_id
        LEFT JOIN emperf_map
            ON emperf.container=emperf_map.container
            AND disp.disp_number=emperf_map.disp_number
    WHERE
        testcase.testcase_id='{testcase_id}'
        {disp_number_query}
        {container_query}
    ORDER BY
        testdate DESC, emperf.container ASC
    """, limit=limit, fetch='fetchall')
    if result is None:
        return None
    return None if len(result) == 0 else result


def get_testcase_details(testcase_id, limit=1):
    result = execute_select_cmd(f"""
    SELECT *
    FROM view_detailed_testcase
    WHERE
        testcase_id='{testcase_id}'
    """, limit=limit, fetch='fetchall')
    return None if len(result) == 0 else result


def get_kpi(testcase_id, kpi_name=None, kpi_distname=None, limit=0):
    kpi_query = '' if kpi_name is None else f"AND kpi_name LIKE '{kpi_name}'"
    kpi_distname_query = '' if kpi_name is None else f"AND kpi_distname = '{kpi_distname}'"
    result = execute_select_cmd(f"""
    SELECT  testcase.testcase_id,
            testname,
            testdate,
            kpi_name,
            kpi_distname,
            kpi_value
    FROM testcase
        LEFT JOIN kpi
            ON kpi.testcase_id=testcase.testcase_id
    WHERE
        testcase.testcase_id='{testcase_id}'
        {kpi_query}
        {kpi_distname_query}
    ORDER BY testdate DESC, kpi_name ASC
    """, limit=limit, fetch='fetchall')
    if result is None:
        return None
    return None if len(result) == 0 else result


def get_pmcounter(testcase_id, piid_name=None, distname=None, limit=0):
    piid_name_query = '' if piid_name is None else f"AND pmcounter.piid_name = '{piid_name}'"
    distname_query = '' if distname is None else f"AND pmcounter.distname = '{distname}'"
    result = execute_select_cmd(f"""
    SELECT  testcase.testcase_id,
            testcase.testname,
            testcase.testdate,
            pmcounter.piid_name,
            pmcounter.piid_value,
            pmcounter.distname
    FROM testcase
        LEFT JOIN pmcounter
            ON pmcounter.testcase_id=testcase.testcase_id
    WHERE
        testcase.testcase_id='{testcase_id}'
        {piid_name_query}
        {distname_query}
    ORDER BY testcase.testdate DESC, pmcounter.piid_name ASC, pmcounter.distname ASC
    """, limit=limit, fetch='fetchall')
    if result is None:
        return None
    return None if len(result) == 0 else result


def get_hash(hash_name, hash_value, limit=0):
    result = execute_select_cmd(f"""
    SELECT  hash.hash_name, hash.hash_value, hash.hash_date
    FROM hash
    WHERE
        hash.hash_name='{hash_name}'
        AND hash.hash_value='{hash_value}'
    ORDER BY hash.hash_date ASC
    """, limit=limit, fetch='fetchall')
    if result is None:
        return None
    return None if len(result) == 0 else result[0]


def decode_hash_content(hash_value, hash_name=None, limit=0):
    hashes = get_hash(hash_name=hash_name, hash_value=hash_value, limit=limit)
    decoded = []
    for hashval in hashes:
        try:
            row = {
                "name": hashval[0],
                "value": hashval[1],
                "content": hashval[2],
                "date": hashval[3],
                "decoded": hashval[2],
            }
            row['decoded'] = zlib.decompress(
                base64.b64decode(row['content'])).decode()
        except KeyError as e:
            logger.error("decode_hash_content KeyError %s", e)
        decoded.append(row)
    return decoded


def execute_select_cmd(cmd, limit=0, fetch='fetchone'):
    global DB_RETRIEVE_PATH
    if _DB_RETRIEVE_PATH is None:
        logger.error('DB not initialized')
        return None
    limit_query = '' if limit == 0 else f"LIMIT {limit}"
    cmd = f"""
    {cmd}
    {limit_query};
    """
    logger.debug("[command] %s", str(cmd))
    ret = None
    try:
        with closing(sqlite3.connect(_DB_RETRIEVE_PATH, timeout=_DB_TIMEOUT)) as conn:
            with closing(conn.cursor()) as cursor:
                if fetch is not None:
                    ret = getattr(cursor.execute(cmd), fetch)()
                else:
                    ret = cursor.execute(cmd)
    except sqlite3.OperationalError as e:
        logger.error("sqlite3.OperationalError %s", e)
    except sqlite3.ProgrammingError as e:
        logger.error("sqlite3.ProgrammingError %s", e)
    logger.debug("[return] %s", str(ret))
    return ret


def main():
    print('start db_interface_retrieve.py')
    parser = argparse.ArgumentParser(description='db_interface_retrieve.py')
    parser.add_argument('--database')
    parser.add_argument('--testname')
    args = parser.parse_args()

    connect_to_database(db=args.database)
    result = get_testcase_details(get_last_testcase_id(args.testname))
    print(result)

    print('end db_interface_retrieve.py')


if __name__ == "__main__":
    main()
