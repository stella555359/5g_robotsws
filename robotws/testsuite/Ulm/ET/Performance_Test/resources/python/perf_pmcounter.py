from robot.libraries.BuiltIn import BuiltIn

import traceback
import re
import scripts
import operator

from collections import defaultdict

from testsuite.Ulm.resources.Common.python import pmcounters
from testsuite.Ulm.ET.Performance_Test.resources.python import autohtml
from testsuite.Ulm.ET.Performance_Test.resources.db import db_interface_retrieve
from testsuite.Ulm.ET.Performance_Test.resources.db import db_interface_insert

rbi = BuiltIn()

db_insert_conn = None
db_retrieve_conn = None

piid_dictionary = {
    # Throughput
    "M55326C00501": "PDCP SDU user DL data volume per PLMN-ID for SA user - SA_DL_TPUT_COUNTER",
    "M55326C00502": "PDCP SDU user UL data volume per PLMN-ID for SA user - SA_UL_TPUT_COUNTER",

    # TTI
    "M55308C17001": "Accumulated number of scheduled (FDM and MU-MIMO) UEs on PDSCH per slot",
    "M55308C18001": "Accumulated number of scheduled (FDM and MU-MIMO) UEs on PUSCH per slot",
    "M55308C17002": "Maximum number of scheduled (FDM and MU-MIMO) UEs on PDSCH per slot",
    "M55308C18002": "Maximum number of scheduled (FDM and MU-MIMO) UEs on PUSCH per slot",

    # Beamforming
    "M55305C01001": "UL_SERV_BEAM_ID_BEAM_00",
    "M55305C01002": "UL_SERV_BEAM_ID_BEAM_01",
    "M55305C00001": "DL_SERV_BEAM_ID_BEAM_00",
    "M55305C00002": "DL_SERV_BEAM_ID_BEAM_01",
}

actFlowControlLoadBalance_counters = {
    "M55308C02000": "Accumulated number of UEs with DL DRB data buffered",
    "M55308C02002": "Accumulated number of UEs with UL DRB data buffered",
    "M55328C00006": "DL PDCP SDU delay per slice per PLMN"
}

all_piid_dictionary = defaultdict(lambda: "TBA")
all_piid_dictionary.update({
    **piid_dictionary,
    **actFlowControlLoadBalance_counters,
})


def connect_db():
    try:
        global db_insert_conn
        global db_retrieve_conn
        db_path = rbi.get_variable_value("${TP.DB_SQLITE3_DATABASE}")
        if db_insert_conn is None:
            db_insert_conn = db_interface_insert.connect_to_database(db_path)
        if db_retrieve_conn is None:
            db_retrieve_conn = db_interface_retrieve.connect_to_database(db_path)
    except Exception as e:
        rbi.log(f"Unable to connect to db: {db_path}, e={e}\n{traceback.format_exc()}", level='WARN')


def initialize_pmcounter_dictionary(counters, distnames, console=False):
    pm_dictionary = {}
    rbi.log(f"    initialize_pmcounter_dictionary: {pm_dictionary}", console=console)
    for counter in counters:
        pm_dictionary[f'{counter}'] = {}
        for distname in distnames:
            rbi.log(f"          {counter}, {distname}", console=console)
            pm_dictionary[f'{counter}'][f'{distname}'] = None
    return pm_dictionary


def get_all_counters(pi_dir, refresh_counters=False):
    """Generates a dictionary with all pmcounters in the following format
            Format e.x.: {
                             "M55326C00501" : {"MRBTS-1/NRBTS-1" : 0, "MRBTS-1/NRBTS-2" : 0 },
                             "M55326C00502" : {"MRBTS-1/NRBTS-1" : 0, "MRBTS-1/NRBTS-2" : 0 },
                         }
    """
    qos_counters = create_pm_counter_range(55310, 5001, 5020)  # DL RLC DELAY L QOS GRP

    all_piid_list = [
        *piid_dictionary.keys(),
        *actFlowControlLoadBalance_counters.keys(),
        *qos_counters,
    ]
    cdict = get_counter_dictionary(pi_dir, all_piid_list, refresh_counters=refresh_counters)
    return cdict


def get_counter_dictionary(pi_dir, counters, all_counters=rbi.get_variable_value("${ALL_COUNTERS_DICTIONARY}"),
                           refresh_counters=False):
    rbi.log(f"==========  start: get_counter_dictionary ==========")
    if all_counters is None or refresh_counters:
        rbi.log(f"    refresh_counters: {refresh_counters}",
                level='DEBUG')
        rbi.log(f"    get_counter_dictionary, all_counters is set to empty dictionary",
                level='DEBUG')
        all_counters = {}
    try:
        counters_to_add = []  # avoid getting counters that are already fetched
        for counter in counters:
            if counter not in list(all_counters.keys()):
                counters_to_add.append(counter)
        pi_dict = pmcounters.get_pi_dict(pi_dir, counters_to_add)
    except Exception as e:
        rbi.log(f"""    counters_to_add: {counters_to_add}: e={e} {traceback.format_exc()}""",
                level='WARN', console=False)
        return all_counters

    # convert all to integers
    try:
        new_counters = pi_dict[sorted(pi_dict.keys())[-1]]
        for piid in new_counters:
            for dn in new_counters[piid]:
                new_counters[piid][dn] = int(new_counters[piid][dn])
    except Exception as e:
        rbi.log(f"failed to convert pmcounters to int: {pi_dir}, pi_dict: {pi_dict}, \n{e}\n {traceback.format_exc()}",
                level='WARN', console=False)

    all_pm_counters = all_counters | new_counters
    rbi.set_test_variable("$ALL_COUNTERS_DICTIONARY", all_pm_counters)
    rbi.log(f"    get_counter_dictionary, counters_to_add: {counters_to_add}\nall_pm_counters: {all_pm_counters}",
            level='DEBUG')
    rbi.log(f"==========  end: get_counter_dictionary ==========")
    return all_pm_counters


def create_pm_counter_range(measurement_id, start, end):
    counters = []
    for i in range(int(start), int(end)+1):
        number = "{:0>5}".format(i)
        counters.append(f"M{measurement_id}C{number}")
    return counters


def create_pm_counter_comparison_dictionary(current_tcid, prev_testcase_id, all_counters,
                                            ignore_zero=True, active_cells='all'):
    rbi.log(f"==========  start: create_pm_counter_comparison_dictionary ==========", console=False)
    connect_db()
    try:
        jenkins_url = db_interface_retrieve.get_jenkins_url(prev_testcase_id)
        turandot_link = db_interface_retrieve.get_turandot_link(prev_testcase_id)
        turandot_link_curr = db_interface_retrieve.get_turandot_link(current_tcid)
        turandot_url = f"http://turandot.dynamic.nsn-net.net/share/Performance_Logs/{turandot_link}"
        turandot_url_curr = f"http://turandot.dynamic.nsn-net.net/share/Performance_Logs/{turandot_link_curr}"
    except Exception as e:
        turandot_url = ''
        jenkins_url = ''
        turandot_link_curr = ''
        turandot_url_curr = ''
        rbi.log(f"    {e}", level='WARN', console=False)
    pm_counter_comparison_dictionary = {
        'current_testcase_id': current_tcid,
        'current_turandot_url': turandot_url_curr,
        'prev_testcase_id': prev_testcase_id,
        'prev_jenkins_url': jenkins_url,
        'prev_turandot_url': turandot_url,
        'pm': {},
    }
    piids = sorted(all_counters.keys(), key=natural_sort)
    for piid in piids:
        pm_counter_comparison_dictionary['pm'].update({
            piid: {}
        })
        sum = 0
        prev_sum = 0
        total_dn = len(all_counters[piid].keys())
        for distname in all_counters[piid].keys():
            if not scripts.is_cell_included_in_distname(distname, active_cells):
                total_dn = total_dn - 1
                continue
            try:
                row = db_interface_retrieve.get_pmcounter(prev_testcase_id, piid_name=piid, distname=distname)
                current_piid_value = 0
                percent = None

                if row is None:
                    rbi.log(f"Database returned empty for PM Counter: {piid}, {distname}")
                    total_dn = total_dn - 1
                    prev_piid_value = 'n/a'
                else:
                    prev_piid_value = int(0) if row[0][4] is None else int(row[0][4])

                if all_counters[piid][distname] is not None:
                    current_piid_value = int(all_counters[piid][distname])

                if ignore_zero and (current_piid_value == 0 and prev_piid_value == 0):
                    total_dn = total_dn - 1
                    continue

                percent_str, percent = scripts.get_percent_difference(current_piid_value, prev_piid_value)
                pm_counter_comparison_dictionary['pm'][piid][distname] = {
                    'current': current_piid_value,
                    'previous': prev_piid_value,
                    'difference': int(current_piid_value - prev_piid_value) if prev_piid_value != 'n/a' else 'n/a',
                    'percent': percent,
                    'percent_str': percent_str
                }

                sum = sum + current_piid_value
                prev_sum = (prev_sum + prev_piid_value) if prev_piid_value != 'n/a' else 'n/a'
            except Exception as e:
                total_dn = total_dn - 1
                rbi.log(f"    create_pm_counter_comparison_dictionary e={e}\n {traceback.format_exc()}", console=False)
        if total_dn > 1:
            current = round((float(sum) / total_dn))
            previous = round((float(prev_sum) / total_dn))
            percent_str, percent = scripts.get_percent_difference(current, previous)
            pm_counter_comparison_dictionary['pm'][piid]['average'] = {
                'current': int(current),
                'previous': int(previous),
                'difference': int(current - previous),
                'percent': percent,
                'percent_str': percent_str
            }

    rbi.log(f"==========  end: create_pm_counter_comparison_dictionary ==========", console=False)
    return pm_counter_comparison_dictionary


def print_pm_counter_dictionary(pm_counter_comparison_dictionary, console=True):
    rbi.log("PM counter Summary: Current ( {} ), DB ( {} )".format(
            pm_counter_comparison_dictionary['current_testcase_id'],
            pm_counter_comparison_dictionary['prev_testcase_id'],
            ), console=console)
    msg = "      {: >15}, {: >18}, {: >18}, {: >18}, {: >8}".format(
        "PIID", "CURRENT", "PREVIOUS", "DIFFERENCE", "% DIFF",
    )
    rbi.log(msg, console=console)
    for piid in pm_counter_comparison_dictionary['pm'].keys():
        if 'average' in pm_counter_comparison_dictionary['pm'][piid].keys():
            dvalues = pm_counter_comparison_dictionary['pm'][piid]['average']
        else:
            distnames = list(pm_counter_comparison_dictionary['pm'][piid].keys())
            if len(distnames) == 0:
                continue
            dvalues = pm_counter_comparison_dictionary['pm'][piid][distnames[0]]
        if dvalues != {}:
            msg = "      {: >15}, {: >18}, {: >18}, {: >18}, {: >8}".format(
                piid,
                dvalues['current'],
                dvalues['previous'],
                dvalues['difference'],
                dvalues['percent_str'],
            )
            rbi.log(msg, console=console)
    rbi.log("", console=console)


def assert_all_counters(pm_counter_comparison_dictionary, tolerance):
    assert_pm_counters(
       pm_counter_comparison_dictionary,
       piid_dictionary,
       operator_cmp='>=',
       tolerance=tolerance
    )


def assert_pm_counters(pm_counter_comparison_dictionary, piid_list, operator_cmp='>', tolerance='null'):
    rbi.log(f"==========  start: assert_pm_counters ==========", console=False)
    if tolerance == 'null':
        return
    if len(pm_counter_comparison_dictionary['pm'].keys()) == 0:
        rbi.log("    Counters Not Collected!", level='ERROR')
        return
    operator_cmp = {
        '>': operator.gt,
        '<': operator.lt,
        '>=': operator.ge,
        '<=': operator.le
    }[operator_cmp]

    for piid in piid_list:
        rbi.log(f"    piid: {piid}", console=False)
        for distname in pm_counter_comparison_dictionary['pm'][piid].keys():
            previous = pm_counter_comparison_dictionary['pm'][piid][distname]['previous']
            previous = int(previous) if previous != 'n/a' else 'n/a'
            current = int(pm_counter_comparison_dictionary['pm'][piid][distname]['current'])

            tolerance100 = float(tolerance) * (-1 if operator_cmp == operator.lt or operator_cmp == operator.le else 1)
            if previous != 'n/a':
                result = operator_cmp(
                    current + (current * tolerance100),
                    previous
                )
            else:
                result = False
            rbi.log(f"        distname: {distname}, tolerance: {tolerance100}", console=False)
            if not result:
                rbi.fail(f"PM Counter Assert Failed: piid({piid}), cur({current}), prev({previous})")
                return
    return


def write_to_html(pm_counter_comparison_dictionary, path):
    rbi.log(f"========== start: write_to_html() ==========")
    try:
        ahtml = autohtml.Autohtml()
        ahtml.html.head.title.inner_elements.append("PM Counter Report")
        ahtml.html.head.style.inner_elements.append("""
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
        """)
        ahtml.html.body.insert([f"<h1>PM Counter Report:</h1>"])
        ahtml.html.body.inner_elements.append(
            autohtml.Div().insert([
                f"Testcase ID: {pm_counter_comparison_dictionary['current_testcase_id']}, ",
                f"Previous Testcase ID: {pm_counter_comparison_dictionary['prev_testcase_id']} ",
                autohtml.A(attribute=f"href=\'{pm_counter_comparison_dictionary['prev_jenkins_url']}\'").append(
                    f", Jenkins"
                ),
                autohtml.A(attribute=f"href=\'{pm_counter_comparison_dictionary['prev_turandot_url']}\'").append(
                    f", Turandot"
                )
            ])
        )
        ahtml.html.body.inner_elements.append(autohtml.Br())
        # just average
        mTable = autohtml.Table(_id='my-table').append(
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
        ahtml.html.body.inner_elements.append(
            autohtml.Span(_class='pm_detail').append(f"Average Summary")
        )

        for piid in pm_counter_comparison_dictionary['pm'].keys():
            if 'average' in pm_counter_comparison_dictionary['pm'][piid].keys():
                dvalues = pm_counter_comparison_dictionary['pm'][piid]['average']
            else:
                distnames = list(pm_counter_comparison_dictionary['pm'][piid].keys())
                if len(distnames) == 0:
                    continue
                dvalues = pm_counter_comparison_dictionary['pm'][piid][distnames[0]]
            if dvalues != {}:
                mTable.append(
                    autohtml.Tr().insert([
                        autohtml.Td().append(piid),
                        autohtml.Td().append(dvalues['current']),
                        autohtml.Td().append(dvalues['previous']),
                        autohtml.Td().append(dvalues['difference']),
                        autohtml.Td().append(dvalues['percent_str']),
                    ]))
            else:
                mTable.append(
                    autohtml.Tr().insert([
                        autohtml.Td().append(piid),
                        autohtml.Td().append('-'),
                        autohtml.Td().append('-'),
                        autohtml.Td().insert('-'),
                        autohtml.Td().append('-'),
                    ]))
        ahtml.html.body.inner_elements.append(mTable)
        ahtml.html.body.inner_elements.append(autohtml.Br())

        # detailed report
        ahtml.html.body.inner_elements.append(
            f"<h3>PM Counter Detailed Report: </h3>"
        )
        for piid in pm_counter_comparison_dictionary['pm'].keys():
            ahtml.html.body.inner_elements.append(
                autohtml.Span(_class='pm_detail').append(f"{piid}")
            )
            ahtml.html.body.inner_elements.append(autohtml.Br())
            ahtml.html.body.inner_elements.append(
                autohtml.Div(_class='pm_description').append(
                    "{}".format(all_piid_dictionary[piid].replace('\n', '<br />')))
            )
            mTable = autohtml.Table(_id='my-table').append(
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
            for distname in pm_counter_comparison_dictionary['pm'][piid].keys():
                dvalues = pm_counter_comparison_dictionary['pm'][piid][distname]
                if dvalues != {}:
                    style = 'color:#005AFF;' if distname == 'average' else None
                    mTable.append(
                        autohtml.Tr(_style=style).insert([
                            autohtml.Td(_style=style).append(distname),
                            autohtml.Td(_style=style).append(dvalues['current']),
                            autohtml.Td(_style=style).append(dvalues['previous']),
                            autohtml.Td(_style=style).append(dvalues['difference']),
                            autohtml.Td(_style=style).append(dvalues['percent_str']),
                        ]))
                else:
                    mTable.append(
                        autohtml.Tr().insert([
                            autohtml.Td().append(distname),
                            autohtml.Td().append('-'),
                            autohtml.Td().append('-'),
                            autohtml.Td().insert('-'),
                            autohtml.Td().append('-'),
                        ]))
            ahtml.html.body.inner_elements.append(mTable)
            ahtml.html.body.inner_elements.append(autohtml.Br())
        ahtml.html.body.inner_elements.append(autohtml.Br())
        ahtml.write_to_file(path)
    except Exception as e:
        rbi.log(f"    write_to_html: e={e}, {traceback.format_exc()}", console=True)


def natural_sort(text):
    return [(lambda text: int(text) if text.isdigit() else text)(c) for c in re.split(r'(\d+)', text)]
