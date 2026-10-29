

import argparse
import pathlib
import logging
import json

from testsuite.Ulm.ET.Performance_Test.resources.python import autohtml
from testsuite.Ulm.ET.Performance_Test.resources.python import pmcounter_sqlite_inf
from testsuite.Ulm.ET.Performance_Test.resources.python import pmcounter_manager

from testsuite.Ulm.ET.Performance_Test.resources.db import db_interface_retrieve

logger = logging.getLogger(__name__)


_HEADER = """
body {
    font-family: Arial, Helvetica, sans-serif;
    padding: 0em 1em  1em 1em;
}
.pm_detail {
    color: #005AFF;
    font-family: Arial;
    font-weight: bold;
}

.pm_description {
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

_PRECISION = 2


def write_to_html(pm_counter_comparison_dictionary, prev_testcase_id, path):
    logger.debug("========== start: write_to_html() ==========")
    ahtml = autohtml.Autohtml()
    ahtml.html.head.title.inner_elements.append("PM Counter Report")
    ahtml.html.head.style.inner_elements.append(_HEADER)
    ahtml.html.body.insert(["<h1>PM Counter Report:</h1>"])

    prev_jenkins_url = db_interface_retrieve.get_jenkins_url(
        prev_testcase_id)
    turandot_link = db_interface_retrieve.get_turandot_link(
        prev_testcase_id)
    prev_turandot_url = f"http://turandot.dynamic.nsn-net.net/share/Performance_Logs/{turandot_link}"

    ahtml.html.body.inner_elements.append(
        autohtml.Div().insert([
            "Testcase ID: TBA",
            f", Previous Testcase ID: {prev_testcase_id} ",
            autohtml.A(attribute=f"href=\'{prev_jenkins_url}\'").append(
                ", Jenkins"
            ),
            autohtml.A(attribute=f"href=\'{prev_turandot_url}\'").append(
                ", Turandot"
            )
        ])
    )
    ahtml.html.body.inner_elements.append(autohtml.Br())
    ahtml.html.body.inner_elements.append(
        autohtml.Span(_class='pm_detail').append("Average Summary")
    )
    # just average
    ahtml.html.body.inner_elements.append(
        _get_average(pm_counter_comparison_dictionary))
    ahtml.html.body.inner_elements.append(autohtml.Br())

    # detailed report
    ahtml.html.body.inner_elements.append(
        "<h3>PM Counter Detailed Report: </h3>")
    for piid, data in pm_counter_comparison_dictionary.items():
        ahtml.html.body.inner_elements.append(
            autohtml.Span(_class='pm_detail').append(f"{piid}")
        )
        ahtml.html.body.inner_elements.append(autohtml.Br())
        ahtml.html.body.inner_elements.append(
            autohtml.Div(_class='pm_description').append(
                "{}".format(data['name'].replace('\n', '<br />')))
        )
        ahtml.html.body.inner_elements.append(_get_detailed(data["distnames"]))
        ahtml.html.body.inner_elements.append(autohtml.Br())
    ahtml.html.body.inner_elements.append(autohtml.Br())
    try:
        ahtml.write_to_file(path)
    except OSError as e:
        logger.exception(e)


def _get_detailed(data):
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
    for distname, values in data.items():
        distname_values_defualt = {
            'current': '-',
            'previous': '-',
            'difference': '-',
            'percent': '-',
        }
        distname_values_defualt.update(values)
        for key, value in distname_values_defualt.items():
            if value not in [None, '-']:
                distname_values_defualt[key] = round(value, _PRECISION)
        style = 'color:#005AFF;' if distname == 'average' else None
        m_table.append(
            autohtml.Tr(_style=style).insert([
                autohtml.Td(_style=style).append(distname),
                autohtml.Td(_style=style).append(distname_values_defualt['current']),
                autohtml.Td(_style=style).append(distname_values_defualt['previous']),
                autohtml.Td(_style=style).append(distname_values_defualt['difference']),
                autohtml.Td(_style=style).append(distname_values_defualt['percent']),
            ]))
    return m_table


def _get_average(pm_counter_comparison_dictionary):
    m_table = autohtml.Table(_id='my-table').append(
        autohtml.Tr().insert(
            [
                autohtml.Th(_style='width: 5em;').insert(["Counter"]),
                autohtml.Th().insert(["Current"]),
                autohtml.Th().insert(["Previous"]),
                autohtml.Th().insert(["Difference"]),
                autohtml.Th().insert(["% Delta"]),
            ]
        )
    )
    for piid, data in pm_counter_comparison_dictionary.items():
        dvalues = data['distnames'].get('mean', {
            'current': '-',
            'previous': '-',
            'difference': '-',
            'percent': '-',
        })
        for key, val in dvalues.items():
            if val not in [None, '-']:
                dvalues[key] = round(val, _PRECISION)
        m_table.append(
            autohtml.Tr().insert([
                autohtml.Td().append(piid),
                autohtml.Td().append(dvalues['current']),
                autohtml.Td().append(dvalues['previous']),
                autohtml.Td().append(dvalues['difference']),
                autohtml.Td().append(dvalues['percent']),
            ]))
    return m_table


def main():
    logger.info("pmcounter_to_html.py")
    parser = argparse.ArgumentParser(description='pmcounter_to_html.py')
    parser.add_argument('--pmdir')
    parser.add_argument('--tcid')
    parser.add_argument(
        '--db', default='/home/ute/DEVELOPMENT/database/performance.sqlite3')
    args = parser.parse_args()

    logging.basicConfig(
        format="%(asctime)s|%(levelname)-5.5s|%(module)s.%(funcName)s:%(lineno)d:%(message)s",
        encoding='utf-8',
        level=logging.DEBUG
    )
    pmdir = pathlib.Path(args.pmdir)
    all_counters = pmcounter_manager.get_all_counters(str(pmdir))
    pmcounter_sqlite_inf.connect_db(args.db)
    pm_counter_comparison = pmcounter_sqlite_inf.get_pm_counter_comparison_dictionary_from_db(all_counters, args.tcid)
    with open(pmdir.joinpath('pmcounter_cmp.json'), 'w', encoding='utf-8') as f:
        json.dump(pm_counter_comparison, f)
    write_to_html(pm_counter_comparison, args.tcid,
                  pmdir.joinpath('pmcounter_cmp.html'))
    print(pmcounter_sqlite_inf.format_cmp_dict_as_table(pm_counter_comparison))
    logger.info(pmdir.joinpath('pmcounter_cmp.html'))


if __name__ == "__main__":
    main()
