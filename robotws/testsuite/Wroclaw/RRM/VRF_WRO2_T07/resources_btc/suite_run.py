import subprocess

BASE_PATH = '/home/ute/FTTools/'

REPORT_FILE = 'test_reports/junit.xml'


def run_suite(suite):
    _run_fttools(suite)


def _run_fttools(suite):
    suite_path = 'tests/' + suite
    testline = subprocess.check_output('hostname', shell=True).decode().rstrip()
    params = ' '.join([
        '--testline=' + testline,
        '--ute_report',
        '--junitxml=' + REPORT_FILE,
    ])
    subprocess.call('cd %s; tox -r -e cloud -- %s %s' % (BASE_PATH, params, suite_path), shell=True)


def _report_results():
    subprocess.call('cd %s; tox -r -e reports_sender' % BASE_PATH, shell=True)
