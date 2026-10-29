"""
TODO: Documentation
"""

import logging
import datetime
import argparse
import json
import pathlib
from collections import defaultdict

from testsuite.Ulm.ET.Performance_Test.resources.python import ltepat_manager
from testsuite.Ulm.ET.Performance_Test.resources.python import ltepat_sqlite_inf
from testsuite.Ulm.ET.Performance_Test.resources.python import autohtml

from testsuite.Ulm.ET.Performance_Test.resources.db import db_interface_retrieve


logger = logging.getLogger(__name__)

_CSS_STYLE = """
body {
    font-family: Arial, Helvetica, sans-serif;
    padding: 0em 1em  1em 1em;
}
.kpi_detail {
    color: #005AFF;
    font-family: Arial;
    font-weight: bold;
}

.kpi_description {
    font-size: .8em;
    padding-left: 1em;
}

span {
    font-family: Arial;
}

h1, h2, h3 {
    color: #005AFF;
    font-family: Arial, Helvetica, sans-serif;
}

h4, h5 {
    font-family: Arial, Helvetica, sans-serif;
}

#my-table {
    font-family: Arial, Helvetica, sans-serif;
    border-collapse: collapse;
    color: black
}

#my-table td,
#my-table th {
    border: 1px solid #ddd;
    padding: 8px;
    width: 6em;
    text-align: right;
}

#my-table tr:nth-child(even) {
    background-color: #f2f2f2;
}

#my-table tr:hover {
    background-color: #ddd;
}

#my-table th {
    padding-top: 0.2em;
    padding-bottom: 0.2em;
    text-align: center;
    background-color: #005AFF;
    color: white;
}
"""


def write_to_html(
        current_testcase_id,
        prev_testcase_id,
        kpi_comparison_dictionaries,
        path,
        ignore_zero=True):
    logger.debug("start write_to_html")
    if kpi_comparison_dictionaries == {} or kpi_comparison_dictionaries is None:
        logger.debug("write_to_html() kpi_comparison_dictionaries is None!")
        return
    ahtml = autohtml.Autohtml()
    ahtml.html.head.title.inner_elements.append("KPI Report")
    ahtml.html.head.style.inner_elements.append(_CSS_STYLE)
    prev_jenkins_url = db_interface_retrieve.get_jenkins_url(prev_testcase_id)
    turandot_link = db_interface_retrieve.get_turandot_link(prev_testcase_id)
    prev_turandot_url = f"http://turandot.dynamic.nsn-net.net/share/Performance_Logs/{turandot_link}"
    ahtml.html.body.insert([r"<h1>KPI Report:</h1>"])
    ahtml.html.body.inner_elements.append(
        autohtml.Div().insert([
            f"Testcase ID: {current_testcase_id}, ",
            f"Previous Testcase ID: {prev_testcase_id} ",
            autohtml.A(attribute=f"href=\'{prev_jenkins_url}\'").append(
                ", Jenkins"),
            autohtml.A(attribute=f"href=\'{prev_turandot_url}\'").append(
                ", Turandot")
        ])
    )
    ahtml.html.body.inner_elements.append(autohtml.Br())
    # just mean
    m_table = _get_summary_table(kpi_comparison_dictionaries, ignore_zero=ignore_zero)
    ahtml.html.body.inner_elements.append(
        autohtml.Span(_class='kpi_detail').append("Mean Summary"))
    ahtml.html.body.inner_elements.append(
        _get_summary_table(kpi_comparison_dictionaries, ignore_zero=ignore_zero)
    )
    ahtml.html.body.inner_elements.append(autohtml.Br())
    # detailed report
    ahtml.html.body.inner_elements.append(r"<h3>KPI Detailed Report: </h3>")
    for kpi_name, data in kpi_comparison_dictionaries.items():
        if data["distnames"]['mean']['current'] == 0.0 and ignore_zero:
            continue
        ahtml.html.body.inner_elements.append(
            autohtml.Span(_class='kpi_detail').append(f"{kpi_name}")
        )
        ahtml.html.body.inner_elements.append(autohtml.Br())
        m_table = _get_detailed(data['distnames'])
        ahtml.html.body.inner_elements.append(m_table)
        ahtml.html.body.inner_elements.append(autohtml.Br())
    ahtml.html.body.inner_elements.append(autohtml.Br())
    ahtml.write_to_file(path)


def _get_summary_table(kpi_comparison_dictionaries, ignore_zero=True):
    m_table = autohtml.Table(_id='my-table').append(
        autohtml.Tr().insert(
            [
                autohtml.Th(_style='width: 15em;').insert(["Name"]),
                autohtml.Th(_style='width: 5em;').insert(["KPI"]),
                autohtml.Th().insert(["Current"]),
                autohtml.Th().insert(["Previous"]),
                autohtml.Th().insert(["Difference"]),
                autohtml.Th().insert(["% Delta"]),
            ]
        )
    )
    for kpi_name, data in kpi_comparison_dictionaries.items():
        distnames = data["distnames"]
        if 'mean' in distnames.keys():
            dvalues = distnames['mean']
        else:
            keys = list(distnames.keys())
            if len(keys) > 0:
                dvalues = distnames[keys[0]]
            else:
                dvalues = defaultdict(lambda: "")
        if dvalues != {}:
            if dvalues['current'] == 0.0 and ignore_zero:
                continue
            m_table.append(
                autohtml.Tr().insert([
                    autohtml.Td(
                        _style='font-size: .8em;').append(data['name'].replace('\n', '<br />')),
                    autohtml.Td().append(kpi_name),
                    autohtml.Td().append(dvalues['current']),
                    autohtml.Td().append(dvalues['previous']),
                    autohtml.Td().append(dvalues['difference']),
                    autohtml.Td().append(dvalues['percent']),
                ]))
        else:
            m_table.append(
                autohtml.Tr().insert([
                    autohtml.Td().append('-'),
                    autohtml.Td().append(kpi_name),
                    autohtml.Td().append('-'),
                    autohtml.Td().append('-'),
                    autohtml.Td().insert('-'),
                    autohtml.Td().append('-'),
                ]))
    return m_table


def _get_detailed(distnames, ignore_zero=True):
    m_table = autohtml.Table(_id='my-table').append(
        autohtml.Tr().insert(
            [
                autohtml.Th(_style='width: 20em;').insert(
                    ["Distname"]),
                autohtml.Th().insert(["Current"]),
                autohtml.Th().insert(["Previous"]),
                autohtml.Th().insert(["Difference"]),
                autohtml.Th().insert(["% Delta"]),
            ]
        )
    )
    for distname, dvalues in distnames.items():
        style = 'color:#005AFF;' if distname == 'mean' else None
        if dvalues['current'] == 0 and ignore_zero:
            continue
        m_table.append(
            autohtml.Tr(_style=style).insert([
                autohtml.Td(_style=style).append(distname),
                autohtml.Td(_style=style).append(dvalues['current']),
                autohtml.Td(_style=style).append(dvalues['previous']),
                autohtml.Td(_style=style).append(dvalues['difference']),
                autohtml.Td(_style=style).append(dvalues['percent']),
            ]))
    return m_table


if __name__ == "__main__":
    logging.basicConfig(
        format="%(asctime)s|%(levelname)-5.5s|%(module)s.%(funcName)s:%(lineno)d:%(message)s",
        encoding='utf-8',
        level=logging.DEBUG
    )
    # export PYTHONPATH="${PYTHONPATH}:/home/ute/DEVELOPMENT/robotws/"
    # python /home/ute/DEVELOPMENT/robotws/testsuite/Ulm/ET/Performance_Test/resources/python/ltepat_to_html.py
    parser = argparse.ArgumentParser(description='ltepat_to_html.py')
    ltepat_manager.install()
    parser.add_argument('pi_dirs')
    parser.add_argument('--tcid', required=True)
    parser.add_argument('--release', default=None)
    parser.add_argument('--remote_ip', default=None)
    parser.add_argument('--log_dir', default=None)
    parser.add_argument('--ltepat_pm_dir', default=None)
    parser.add_argument(
        '--db', default='/mnt/etlogs/logs/performance/02_database/performance.sqlite3')
    parser.add_argument('--index', default='-1')
    args = parser.parse_args()

    start_t = datetime.datetime.now()
    if ltepat_sqlite_inf.connect_db(args.db):
        if '.xlsx' in args.pi_dirs:
            ltepat_excel = args.pi_dirs.split(',')
        else:
            ltepat_excel = ltepat_manager.run_ltepat(args.pi_dirs.split(','),
                                                     remote_ip=args.remote_ip,
                                                     log_dir=args.log_dir,
                                                     ltepat_pm_dir=args.ltepat_pm_dir,
                                                     release=args.release)
        print(f"pm_files: {ltepat_excel}")
        new_files = []
        for excel in ltepat_excel:
            excel = pathlib.Path(excel)
            json_file = excel.with_suffix('.json')
            kpi_current = ltepat_manager.get_kpis_all_to_dict(
                str(excel), index=int(args.index))
            with open(json_file, 'w', encoding='utf-8') as f:
                json.dump(kpi_current, f)

            kpi_dictionary_db = ltepat_sqlite_inf.get_kpi_dictionary(args.tcid)
            with open(json_file.with_name(f"tcid_kpi_{args.tcid}.json"), 'w', encoding='utf-8') as f:
                json.dump(kpi_dictionary_db, f)

            kpi_comparison_dictionary = ltepat_sqlite_inf.get_kpi_comparison_dictionary(kpi_current, kpi_dictionary_db)

            write_to_html(0, args.tcid, kpi_comparison_dictionary,
                          excel.with_suffix('.html'))
            print(f"saved: {excel.with_suffix('.html')}")
            with open(json_file.with_name(f"{json_file.stem}_tcid_kpi_{args.tcid}.json"), 'w', encoding='utf-8') as f:
                json.dump(kpi_comparison_dictionary, f)
            new_files.append(str(json_file))
            print(ltepat_sqlite_inf.format_cmp_dict_as_table(kpi_comparison_dictionary))
        print(f"new_files: {new_files}")
    delta_t = datetime.datetime.now() - start_t
    print(f"total time running: {delta_t}")
