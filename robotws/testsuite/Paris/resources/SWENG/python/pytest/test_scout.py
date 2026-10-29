import os
import sys
import types
import importlib.util
import pytest
import glob
import pandas as pd
from unittest.mock import MagicMock
from .GetFiles import download_package_using_git

# Global placeholders populated by fixture
Scout = None
ScoutJournal = None

# Paths / constants
BASE_PATH = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(__file__))))
CONSTRAINTS_PATH = os.path.join(
    BASE_PATH, "SWENG", "robot", "examples", "config", "KPI", "constraints")
CONSTRAINTS_FILE_NAME = "Background_13UEs_TMO_15min.csv"
CONSTRAINTS_FILE = os.path.join(CONSTRAINTS_PATH, "SetupEndur2.csv")
CONSTRAINTS_FILE2 = os.path.join(CONSTRAINTS_PATH, CONSTRAINTS_FILE_NAME)
REPORT_FILE = os.path.join("robustCsvFiles", "transversal_robustness_kpis_report.csv")
DEST_PATH = '/tmp/increment_journal.csv'
DEST_PATH2 = '/tmp/testing_journal.csv'
LOCAL_JOURNAL_PATH = os.path.join(os.path.dirname(__file__), "robustCsvFiles", "journal.csv")
LOCAL_KPI_PATH = os.path.join(os.path.dirname(__file__), "robustCsvFiles", "hist_test.csv")
LOCAL_KPI_PATH2 = os.path.join(os.path.dirname(__file__), "robustCsvFiles", "hist_test2.csv")
CONSTRAINTS_CSV = os.path.join(os.path.dirname(__file__), "KPIs", "constraints.csv")

# Scout API token (for testing - can be overridden by SCOUT_API_TOKEN environment variable)
SCOUT_API_TOKEN = os.environ.get('SCOUT_API_TOKEN', 'aa9dc9a5-8ec2-40d3-a1be-9d2b539c7134')


@pytest.fixture(scope="session", autouse=True)
def _load_scout():
    """Minimal bootstrap to import Scout with required stubs."""
    print("[BOOTSTRAP] Initializing Scout test environment")
    # Add SWENG/python to path
    base_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
    if base_dir not in sys.path:
        sys.path.insert(0, base_dir)
        print(f"[BOOTSTRAP] Added to sys.path: {base_dir}")

    # Stub robot BuiltIn (avoid real Robot)
    bi = MagicMock()
    bi.get_variable_value.return_value = "/tmp"
    rb_mod = types.ModuleType("robot.libraries.BuiltIn")
    rb_mod.BuiltIn = lambda: bi
    sys.modules["robot.libraries.BuiltIn"] = rb_mod
    print("[BOOTSTRAP] Stubbed robot.libraries.BuiltIn")

    # Stub ReadConfig (prevent main execution)
    rc_mod = types.ModuleType("ReadConfig")
    rc_mod.main = lambda: MagicMock()
    rc_mod.TLConfig = MagicMock(topo=MagicMock(getBranchName=lambda: "SBTS00"))
    sys.modules["ReadConfig"] = rc_mod
    print("[BOOTSTRAP] Stubbed ReadConfig module")

    # Import Scout lazily
    scout_path = os.path.join(base_dir, "Scout.py")
    print(f"[BOOTSTRAP] Loading Scout module from: {scout_path}")
    spec = importlib.util.spec_from_file_location("Scout", scout_path)
    scout_mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(scout_mod)
    print(f"[BOOTSTRAP] Scout module loaded: {getattr(scout_mod, '__file__', 'N/A')}")

    global Scout, ScoutJournal
    Scout = scout_mod
    ScoutJournal = getattr(scout_mod, "ScoutJournal", None)
    print(f"[BOOTSTRAP] ScoutJournal class detected: {ScoutJournal is not None}")

# ---------------- Fixtures ----------------


@pytest.fixture
def envsetup():
    print("[FIXTURE envsetup] Preparing KPI report data")
    data = [{
        'type': "toto", 'id': '1', 'name': 'toto',
        'start_time': "", 'end_time': "", 'create_time': "",
        'report': [{'field1': 'value1', 'field2': 'value2'}]
    }]
    yield data
    print("[FIXTURE envsetup] Cleanup temp CSV files")
    for f in glob.glob('/tmp/*.csv'):
        try:
            os.remove(f)
        except OSError:
            pass


@pytest.fixture
def envsetup2():
    print("[FIXTURE envsetup2] Stubbing BuiltIn context methods")
    mock_builtin = sys.modules["robot.libraries.BuiltIn"].BuiltIn()
    mock_builtin.set_suite_variable = MagicMock()
    mock_builtin._get_context = MagicMock()


@pytest.fixture
def envsetup3():
    print("[FIXTURE envsetup3] Preparing history data")
    data = [
        {'create_time': '2025-04-02T10:00:00Z', 'level': 'NRCELL-11', 'value': 0.0},
        {'create_time': '2025-04-02T10:00:00Z', 'level': 'NRCELL-5', 'value': 0.0},
        {'create_time': '2025-04-02T10:00:00Z', 'level': 'NRCELL-9', 'value': 0.0},
        {'create_time': '2025-04-02T10:00:00Z', 'level': 'NRCELL-10', 'value': 0.0},
        {'create_time': '2025-04-02T10:00:00Z', 'level': 'NRCELL-6', 'value': 0.0},
        {'create_time': '2025-04-02T10:00:00Z', 'level': 'NRCELL-3', 'value': 0.0},
        {'create_time': '2025-04-02T10:00:00Z', 'level': 'NRCELL-8', 'value': 0.0}
    ]
    data_robot = ("PASS", data)
    yield data, data_robot
    print("[FIXTURE envsetup3] Cleanup temp CSV files")
    for f in glob.glob('/tmp/*.csv'):
        try:
            os.remove(f)
        except OSError:
            pass


@pytest.fixture
def env_setup4():
    print("[FIXTURE env_setup4] Creating ScoutJournal instance")
    journal = ScoutJournal()
    yield journal
    print("[FIXTURE env_setup4] Cleanup after journal tests")
    for f in glob.glob('/tmp/*.csv'):
        try:
            os.remove(f)
        except OSError:
            pass


@pytest.fixture
def env_setup5():
    print("[FIXTURE env_setup5] Initializing journal + uploading baseline")
    journal = ScoutJournal()
    ok = journal.upload_journal(LOCAL_JOURNAL_PATH, DEST_PATH)
    print(f"[FIXTURE env_setup5] Initial upload result: {ok}")
    new_entry = {
        'current_date': '2025-05-15 03:50:49',
        'step_name_suffix': 'Background_13UEs_TMO_15min',
        'start_date': '2025-05-15 03:00:00',
        'stop_date': '2025-05-15 03:15:00',
        'testline_name': '7_20_UTE5GCLASSTL059',
        'software_load': 'SBTS00_ENB_9999_250511_000003',
        'evaluation_status': "FAIL",
        'template_id': '5G TOP KPI 25R3'
    }
    yield new_entry, journal
    print("[FIXTURE env_setup5] Teardown journal modifications")
    for p in ('/tmp/test_add_line.csv', '/tmp/test_add_line_new.csv'):
        if os.path.exists(p):
            try:
                os.remove(p)
            except OSError:
                pass
    journal.remove_remote_file(DEST_PATH)


@pytest.fixture
def env_setup6():
    print("[FIXTURE env_setup6] Preparing extract dates test")
    journal = ScoutJournal()
    journal.upload_journal(LOCAL_JOURNAL_PATH, DEST_PATH2)
    yield journal
    print("[FIXTURE env_setup6] Removing remote file")
    journal.remove_remote_file(DEST_PATH2)


@pytest.fixture
def env_setup7():
    print("[FIXTURE env_setup7] Downloading raw scout report if missing")
    if not os.path.exists(os.path.join("/tmp", 'PM.BTS-1.20251014.131500.ANY.xml')):
        download_package_using_git('gitlabe1.ext.net.nokia.com/nps_vrf_8_and_9/bsr.git',
                                   'SWENG/Test_files', 'raw_scout_report.csv',
                                   'NpsVrfToken', 'glpat-4yNB_jaBXxz_BsyeAsgL', target_dir="/tmp")


def get_reference_file(report_id):
    """
    Helper function to download and return reference file path for a given report ID.
    Handles cleanup automatically.

    :param report_id: Report ID (e.g., '1165894', '1162053')
    :return: Path to downloaded reference file
    """
    scout_stuff_dir = os.path.join(os.path.dirname(__file__), "Scout_stuff")
    reference_file = os.path.join(
        scout_stuff_dir,
        f"ComparatorReportDetails_{report_id}.xlsx"
    )

    print(
        f"[HELPER] Downloading reference file for Report ID {report_id}"
    )
    # Download file from git repository
    download_package_using_git(
        'gitlabe1.ext.net.nokia.com/nps_vrf_8_and_9/bsr.git',
        'SWENG/Test_files',
        f'ComparatorReportDetails_{report_id}.xlsx',
        'NpsVrfToken',
        'glpat-4yNB_jaBXxz_BsyeAsgL',
        target_dir=scout_stuff_dir
    )

    print(
        f"[HELPER] Reference file downloaded to {reference_file}"
    )
    return reference_file


@pytest.fixture
def env_setup8():
    print("[FIXTURE env_setup8] Downloading Scout reference Excel file")
    reference_file = get_reference_file("1165894")

    print(f"[FIXTURE env_setup8] Reference file ready: {reference_file}")
    yield reference_file

    # Cleanup: remove the downloaded file to leave Scout_stuff empty
    print("[FIXTURE env_setup8] Cleaning up downloaded reference file")
    if os.path.exists(reference_file):
        os.remove(reference_file)
        print(f"[FIXTURE env_setup8] Removed {reference_file}")


def check_n_line(file_path, nr_line=2, last_line=False):
    with open(file_path, 'r') as f:
        lines = f.readlines()
    if not lines or len(lines) < nr_line:
        return None
    return (lines[-1] if last_line else lines[nr_line - 1]).strip()


def compare_files(local_path, downloaded_path):
    import filecmp
    return filecmp.cmp(local_path, downloaded_path)


def count_lines_in_csv(file_path):
    with open(file_path, 'r') as f:
        return sum(1 for _ in f)


def compare_excel_dataframes(ref_df, gen_df, verbose=False):
    """
    Compare leftmost columns format in generated Excel vs reference.
    No row count checking - only validates content format.

    :param ref_df: Reference DataFrame
    :param gen_df: Generated DataFrame
    :param verbose: Print detailed differences
    :return: Tuple (success: bool, issues: list of str, details: dict)
    """
    issues = []
    details = {
        'leftmost_cols_present': False,
        'range_format': False,
        'values_format': False
    }

    # Leftmost columns we care about (order is important)
    leftmost_cols = ['Code', 'Dist Name', 'Range', 'Values']

    # Check that leftmost columns exist in both files
    ref_missing = [c for c in leftmost_cols
                   if c not in ref_df.columns]
    gen_missing = [c for c in leftmost_cols
                   if c not in gen_df.columns]

    if ref_missing or gen_missing:
        if ref_missing:
            issues.append(
                f"Reference missing columns: {ref_missing}"
            )
        if gen_missing:
            issues.append(
                f"Generated missing columns: {gen_missing}"
            )
    else:
        details['leftmost_cols_present'] = True

    # Validate Range column format (must contain literal newline)
    if 'Range' in ref_df.columns and 'Range' in gen_df.columns:
        ref_has_newline = (
            any('\n' in str(v)
                for v in ref_df['Range'].unique())
        )
        gen_has_newline = (
            any('\n' in str(v)
                for v in gen_df['Range'].unique())
        )

        if ref_has_newline and gen_has_newline:
            details['range_format'] = True
        else:
            if not ref_has_newline:
                issues.append(
                    "Reference Range column missing "
                    "newline character"
                )
            if not gen_has_newline:
                issues.append(
                    "Generated Range column missing "
                    "newline character"
                )

    # Validate Values column format (must not be empty)
    if 'Values' in ref_df.columns and 'Values' in gen_df.columns:
        ref_values = ref_df['Values']
        gen_values = gen_df['Values']

        ref_not_empty = (ref_values != '').sum()
        gen_not_empty = (gen_values != '').sum()

        if ref_not_empty > 0 and gen_not_empty > 0:
            details['values_format'] = True
            if verbose:
                ref_sample = (
                    ref_values[ref_values != ''].iloc[0]
                )
                gen_sample = (
                    gen_values[gen_values != ''].iloc[0]
                )
                print(
                    f"        Ref Values sample: "
                    f"{repr(str(ref_sample)[:80])}"
                )
                print(
                    f"        Gen Values sample: "
                    f"{repr(str(gen_sample)[:80])}"
                )
        else:
            if ref_not_empty > 0 and not gen_not_empty:
                issues.append(
                    "Generated Values column is empty but "
                    "reference has content"
                )

    success = len(issues) == 0
    return success, issues, details

# ---------------- Tests ----------------


def test_convert_kpis_report_to_csv(envsetup):
    print("[TEST] convert_kpis_report_to_csv")
    file_nm = Scout.convert_kpis_report_to_csv(
        envsetup, "/tmp", "transversal_robustness_kpis_report.csv")
    print(f"[TEST] Generated file: {file_nm}")
    assert os.path.getsize(file_nm) > 0
    assert "id: 1" in check_n_line(file_nm)


def test_history(envsetup3):
    print("[TEST] convert_kpi_history_to_csv")
    data, data_robot = envsetup3
    fp1 = Scout.convert_kpi_history_to_csv("NR_5152a", data, "/tmp", "scout_report_pivot.csv")
    print(f"[TEST] File1: {fp1}")
    assert os.path.exists(fp1) and os.path.getsize(fp1) > 0
    df1 = pd.read_csv(fp1, skiprows=2)
    assert df1.columns.tolist() == ['create_time', 'level', 'value']
    fp2 = Scout.convert_kpi_history_to_csv("NR_5152a", data_robot, "/tmp", "scout_report_pivot2.csv")
    print(f"[TEST] File2: {fp2}")
    df2 = pd.read_csv(fp2, skiprows=2)
    assert df2.columns.tolist() == ['create_time', 'level', 'value']


def test_get_report(envsetup2):
    print("[TEST] get_kpis_report_from_file")
    df = Scout.get_kpis_report_from_file(REPORT_FILE, "testlines_entry.7_20_UTE5GCLASSTL008.")
    print(f"[TEST] DataFrame rows: {len(df) if df is not None else 'None'}")
    assert df is not None and len(df) > 0
    value_cols = [c for c in df.columns if 'value' in c]
    assert len(value_cols) == 2
    assert df.columns.is_unique
    assert len(df) == 116
    assert df['result.value'].equals(df['global_result.value'])


@MagicMock()
def test_evaluate_contraints():
    print("[TEST] evaluateConstraints single file")
    assert Scout.evaluateConstraints(CONSTRAINTS_FILE, REPORT_FILE, logit=False) is False


@MagicMock()
def test_evaluate_contraints2():
    print("[TEST] evaluateConstraints second file")
    assert Scout.evaluateConstraints(CONSTRAINTS_FILE2, REPORT_FILE, logit=False) is False


@MagicMock()
def test_evaluate_constraints3():
    print("[TEST] evaluateConstraintsMulti folder scan")
    res = Scout.evaluateConstraintsMulti(
        CONSTRAINTS_PATH, "bkg_13UEs_SFE_TMO_15min", REPORT_FILE, logit=False)
    assert res is False


def test_evaluate_constraints_with_should_not_calculate():
    print("[TEST] evaluateConstraintsMulti with Should-Not-Calculate verification")
    output_file = "/tmp/test_should_not_calc_output.txt"
    try:
        # Redirect stdout to capture print output
        import sys
        from io import StringIO
        old_stdout = sys.stdout
        sys.stdout = captured_output = StringIO()

        # Run evaluateConstraintsMulti with constraints.csv
        Scout.evaluateConstraints(CONSTRAINTS_CSV, REPORT_FILE, logit=True)

        # Restore stdout
        sys.stdout = old_stdout
        output = captured_output.getvalue()

        # Write output to file for inspection
        with open(output_file, 'w') as f:
            f.write(output)

        print(f"[TEST] Output saved to {output_file}")
        print(f"[TEST] Output length: {len(output)} chars")

        # Verify "Should-Not-Calculate" appears in output
        assert "Should-Not-Calculate" in output or "SHOULD-NOT-CALC" in output, \
            "Expected 'Should-Not-Calculate' or 'SHOULD-NOT-CALC' in output"

        print("[TEST] Successfully verified Should-Not-Calculate in output")
    finally:
        # Clean up output file
        if os.path.exists(output_file):
            os.remove(output_file)
            print(f"[TEST] Cleaned up {output_file}")


def test_upload_journal(env_setup4):
    print("[TEST] upload_journal")
    file_path = "/tmp/test_upload.csv"
    ok = env_setup4.upload_journal(LOCAL_JOURNAL_PATH, file_path)
    print(f"[TEST] upload result={ok}")
    assert ok is True
    listing = env_setup4.list_remote_files("/tmp/")
    print(f"[TEST] remote listing size={len(listing)}")
    assert any("test_upload.csv" in p for p in listing)


def test_upload_journal_invalid(env_setup4):
    print("[TEST] upload_journal invalid path")
    assert env_setup4.upload_journal(LOCAL_JOURNAL_PATH, "/tmp/invalid_path/test_upload.csv") is False


def test_get_journal_file(env_setup4):
    print("[TEST] get_journal_file")
    target = "/tmp/journal.csv"
    if os.path.exists(target):
        os.remove(target)
    assert env_setup4.upload_journal(LOCAL_JOURNAL_PATH, "/tmp/test_upload.csv") is True
    ok = env_setup4.get_journal_file(target, "/tmp/test_upload.csv")
    print(f"[TEST] download result={ok}")
    assert ok is True
    assert os.path.exists(target) and os.path.getsize(target) > 0
    assert compare_files(LOCAL_JOURNAL_PATH, target) is True


def test_add_line_to_journal(env_setup5):
    print("[TEST] add_line_to_journal")
    entry, journal = env_setup5
    temp_file = "/tmp/test_add_line.csv"
    new_file = temp_file.replace('.csv', '_new.csv')
    if os.path.exists(temp_file):
        os.remove(temp_file)
    if os.path.exists(new_file):
        os.remove(new_file)
    ok = journal.add_line_to_journal(entry, temp_file, DEST_PATH)
    print(f"[TEST] add line result={ok}")
    assert ok is True
    lines = count_lines_in_csv(new_file)
    print(f"[TEST] new file lines={lines}")
    assert lines == 4


def test_extract_last_and_previous_dates(env_setup6):
    print("[TEST] extract_last_and_previous_dates")
    result = env_setup6.extract_last_and_previous_dates(LOCAL_JOURNAL_PATH, DEST_PATH2)
    print(f"[TEST] extraction keys={list(result.keys()) if result else 'None'}")
    assert result and result["last_row"]["current_date"] == "2025-05-14 00:56:24"
    assert result["previous_start_date"] == "2025-05-14 00:00:00"
    assert result["previous_stop_date"] == "2025-05-14 00:15:00"


def test_scout_kpi_history_analyzer():
    print("[TEST] scout_kpi_history_analyzer (False case)")
    assert Scout.scout_kpi_history_analyzer(
        "NR_5004", LOCAL_KPI_PATH, CONSTRAINTS_PATH, "bkg_13UEs_SFE_TMO_15min") == 'False'


def test_scout_kpi_history_analyzer2():
    print("[TEST] scout_kpi_history_analyzer (False case with variant suffix)")
    assert Scout.scout_kpi_history_analyzer(
        "NR_5004b", LOCAL_KPI_PATH, CONSTRAINTS_PATH, "bkg_13UEs_SFE_TMO_15min") == 'False'


def test_scout_report_parser(env_setup7):
    print("[TEST] ScoutReportParser conversion and comparison")
    env_setup7
    input_file = "/tmp/raw_scout_report.csv"
    output_file = "/tmp/constraint_raw_scout_report.csv"
    expected_file = "KPIs/constraints.csv"
    # Check source file exists
    assert os.path.exists(input_file), f"Source file not found: {input_file}"
    print(f"[TEST] Copied input csv file to {input_file}")
    # Remove output file if exists
    if os.path.exists(output_file):
        os.remove(output_file)
    # Create parser and convert
    parser = Scout.ScoutReportParser(input_file, output_file)
    result_path = parser.convert()
    print(f"[TEST] Conversion completed: {result_path}")
    # Verify output file was created
    assert os.path.exists(output_file), f"Output file not created: {output_file}"
    assert os.path.getsize(output_file) > 0, "Output file is empty"
    # Compare files
    import filecmp
    if os.path.exists(expected_file):
        files_match = filecmp.cmp(output_file, expected_file, shallow=False)
        if not files_match:
            # Show differences
            import subprocess
            result = subprocess.run(
                ['diff', '-u', output_file, expected_file],
                capture_output=True, text=True
            )
            diff_lines = result.stdout.split('\n')[:50]  # First 50 lines of diff
            print(f"[TEST] Files differ:")
            for line in diff_lines:
                print(f"  {line}")
            assert False, "Output file does not match expected file"
        else:
            print("[TEST] Files match perfectly!")
    print("[TEST] ScoutReportParser validation passed!")


@pytest.mark.parametrize("report_id,fixture_name", [
    ("1165894", "env_setup8"),
])
def test_fetch_comparator_report_and_save_excel(
    request, report_id, fixture_name
):
    """
    Test fetch_comparator_report_and_save_excel function.
    Parametrized to test multiple report IDs against their respective reference files.
    Validates Range and Values column format for each report.

    :param report_id: Report ID to test (1165894, 1162053, etc.)
    :param fixture_name: Fixture name to use for reference file download
    """
    msg = (
        f"[TEST] Testing fetch_comparator_report_and_save_excel "
        f"with Report ID {report_id}"
    )
    print(msg)

    # Get the fixture (env_setup8 or env_setup9)
    reference_file = request.getfixturevalue(fixture_name)

    # Output file path
    output_file = f"/tmp/test_comparator_report_{report_id}.xlsx"

    # Aggregated comparator report ID
    comparator_id = report_id

    # Get API token from module constant
    api_token = SCOUT_API_TOKEN
    if not api_token:
        print("[TEST] WARNING: SCOUT_API_TOKEN not set")
        pytest.skip("SCOUT_API_TOKEN not available")
    print(f"[TEST] Using Scout API token: {api_token[:20]}...")
    print(f"[TEST] Report ID: {comparator_id}")

    # Check reference file exists
    assert os.path.exists(reference_file), f"Reference file not found: {reference_file}"
    print(f"[TEST] Reference file found: {reference_file}")

    # Remove output file if exists
    if os.path.exists(output_file):
        os.remove(output_file)

    # Call the function to fetch report from Scout API
    print(f"[TEST] Calling Scout API to fetch comparator report...")
    result = Scout.fetch_comparator_report_and_save_excel(
        comparator_id, output_file, api_token=api_token
    )

    # Verify the API call was successful
    assert result is True, "Failed to fetch comparator report from Scout API"
    print(f"[TEST] Successfully fetched report from Scout API")

    # Verify output file was created
    assert os.path.exists(output_file), f"Output file not created: {output_file}"
    assert os.path.getsize(output_file) > 0, "Output file is empty"
    print(f"[TEST] Output file created: {output_file}")

    # Load both Excel files for detailed comparison
    print("[TEST] Loading Excel files for detailed comparison...")
    ref_df = pd.read_excel(reference_file)
    gen_df = pd.read_excel(output_file)

    print(
        f"[TEST] Reference sheet: {len(ref_df)} rows, "
        f"{len(ref_df.columns)} columns"
    )
    print(
        f"[TEST] Generated sheet: {len(gen_df)} rows, "
        f"{len(gen_df.columns)} columns"
    )

    # Comprehensive comparison
    print("[TEST] Performing comprehensive Excel comparison...")
    success, issues, details = compare_excel_dataframes(
        ref_df, gen_df, verbose=True
    )

    # Report details
    print(f"[TEST] Comparison Details:")
    print(
        f"[TEST]   Leftmost columns present: "
        f"{details['leftmost_cols_present']}"
    )
    print(f"[TEST]   Range format valid: {details['range_format']}")
    print(f"[TEST]   Values format valid: {details['values_format']}")

    # Display sample data
    print(
        f"[TEST] Reference file - first 3 rows (Range, Values columns):"
    )
    if 'Range' in ref_df.columns and 'Values' in ref_df.columns:
        for idx in range(min(3, len(ref_df))):
            range_val = repr(ref_df.iloc[idx]['Range'][:30])
            values_val = repr(ref_df.iloc[idx]['Values'][:50])
            print(
                f"[TEST]   Row {idx+2}: Range={range_val}, "
                f"Values={values_val}"
            )

    print(
        f"[TEST] Generated file - first 3 rows (Range, Values columns):"
    )
    if 'Range' in gen_df.columns and 'Values' in gen_df.columns:
        for idx in range(min(3, len(gen_df))):
            range_val = repr(gen_df.iloc[idx]['Range'][:30])
            values_val = repr(gen_df.iloc[idx]['Values'][:50])
            print(
                f"[TEST]   Row {idx+2}: Range={range_val}, "
                f"Values={values_val}"
            )

    # Verify comparisons passed
    if issues:
        print(f"[TEST] Issues found:")
        for issue in issues:
            print(f"[TEST]   ⚠ {issue}")

    assert success, f"Excel comparison failed: {', '.join(issues)}"

    print("[TEST] ✓ Excel leftmost columns match reference format!")
    print(f"[TEST] Report successfully fetched and saved to {output_file}")


@pytest.mark.parametrize("report_id,fixture_name,expected_kpis", [
    ("1165894", "env_setup8", ['NR_5055c']),
])
def test_fetch_comparator_report_with_kpi_filter(request, report_id, fixture_name, expected_kpis):
    """
    Test fetch_comparator_report_and_save_excel with expected_kpis filter parameter.
    Validates that only specified KPIs are included in the output.

    :param report_id: Report ID to test
    :param fixture_name: Fixture name for reference file
    :param expected_kpis: List of KPI codes to filter
    """
    msg = (
        f"[TEST] Testing fetch_comparator_report_and_save_excel "
        f"with KPI filter {expected_kpis} for Report ID {report_id}"
    )
    print(msg)

    output_file = f"/tmp/test_comparator_report_kpi_filter_{report_id}.xlsx"

    api_token = SCOUT_API_TOKEN
    if not api_token:
        print("[TEST] WARNING: SCOUT_API_TOKEN not set")
        pytest.skip("SCOUT_API_TOKEN not available")
    print(f"[TEST] API token: {api_token[:20]}...")

    # Remove output file if exists
    if os.path.exists(output_file):
        os.remove(output_file)

    # Call the function with KPI filter
    print(f"[TEST] Calling Scout API with KPI filter: {expected_kpis}")
    result = Scout.fetch_comparator_report_and_save_excel(
        report_id, output_file, expected_kpis=expected_kpis, api_token=api_token
    )

    assert result is True, "Failed to fetch comparator report with KPI filter"
    print(f"[TEST] Successfully fetched report with KPI filter")

    # Verify output file was created
    assert os.path.exists(output_file), f"Output file not created: {output_file}"
    assert os.path.getsize(output_file) > 0, "Output file is empty"

    # Load and validate
    gen_df = pd.read_excel(output_file)
    print(f"[TEST] Output file: {len(gen_df)} rows, {len(gen_df.columns)} columns")

    # Verify only expected KPIs are in output
    if 'Code' in gen_df.columns:
        kpis_in_output = gen_df['Code'].unique().tolist()
        print(f"[TEST] KPIs in output: {kpis_in_output}")
        for kpi in kpis_in_output:
            assert kpi in expected_kpis, f"Unexpected KPI {kpi} in output"
        print(f"[TEST] ✓ All KPIs in output match filter!")

    print(f"[TEST] Report successfully fetched with KPI filter")


@pytest.mark.parametrize("report_id,fixture_name,expected_dist_names", [
    ("1165894", "env_setup8", ['bts', 'NRCELL-1']),
])
def test_fetch_comparator_report_with_dist_name_filter(request, report_id, fixture_name, expected_dist_names):
    """
    Test fetch_comparator_report_and_save_excel with expected_dist_names filter parameter.
    Validates that only specified entities are included in the output.

    :param report_id: Report ID to test
    :param fixture_name: Fixture name for reference file
    :param expected_dist_names: List of distribution/entity names to filter
    """
    msg = (
        f"[TEST] Testing fetch_comparator_report_and_save_excel "
        f"with dist_name filter {expected_dist_names} for Report ID {report_id}"
    )
    print(msg)

    output_file = f"/tmp/test_comparator_report_dist_filter_{report_id}.xlsx"

    api_token = SCOUT_API_TOKEN
    if not api_token:
        print("[TEST] WARNING: SCOUT_API_TOKEN not set")
        pytest.skip("SCOUT_API_TOKEN not available")
    print(f"[TEST] API token: {api_token[:20]}...")

    # Remove output file if exists
    if os.path.exists(output_file):
        os.remove(output_file)

    # Call the function with dist_name filter
    print(f"[TEST] Calling Scout API with dist_name filter: {expected_dist_names}")
    result = Scout.fetch_comparator_report_and_save_excel(
        report_id, output_file, expected_dist_names=expected_dist_names, api_token=api_token
    )

    assert result is True, "Failed to fetch comparator report with dist_name filter"
    print(f"[TEST] Successfully fetched report with dist_name filter")

    # Verify output file was created
    assert os.path.exists(output_file), f"Output file not created: {output_file}"
    assert os.path.getsize(output_file) > 0, "Output file is empty"

    # Load and validate
    gen_df = pd.read_excel(output_file)
    print(f"[TEST] Output file: {len(gen_df)} rows, {len(gen_df.columns)} columns")

    # Verify only expected dist_names are in output
    if 'Dist Name' in gen_df.columns:
        dist_names_in_output = gen_df['Dist Name'].unique().tolist()
        print(f"[TEST] Dist names in output: {dist_names_in_output}")
        for dist_name in dist_names_in_output:
            assert dist_name in expected_dist_names, f"Unexpected dist_name {dist_name} in output"
        print(f"[TEST] ✓ All dist_names in output match filter!")

    print(f"[TEST] Report successfully fetched with dist_name filter")


@pytest.mark.parametrize("report_id,fixture_name", [
    ("1165894", "env_setup8"),
])
def test_scout_comparator_analyzer(request, report_id, fixture_name):
    """
    Test ScoutComparatorAnalyzer - Python implementation of VBA createConstraintFile_inline.vba.
    Parametrized to analyze comparator Excel reports for multiple report IDs.
    Generates constraint CSV file from each reference file.

    :param report_id: Report ID being tested (1165894, 1162053, etc.)
    :param fixture_name: Fixture name to use for reference file download
    """
    msg = f"[TEST] Testing ScoutComparatorAnalyzer for Report ID {report_id}"
    print(msg)

    # Get the fixture (env_setup8 or env_setup9)
    excel_file = request.getfixturevalue(fixture_name)

    # Output constraint file
    output_file = f"/tmp/test_constraint_from_comparator_{report_id}.csv"

    # Check input file exists
    assert os.path.exists(excel_file), f"Excel file not found: {excel_file}"
    print(f"[TEST] Input Excel file: {excel_file}")

    # Create analyzer instance (auto-detect sheet)
    print("[TEST] Creating ScoutComparatorAnalyzer instance...")
    analyzer = Scout.ScoutComparatorAnalyzer(excel_file, sheet_name=None, legacy_mode=False)

    # Load data
    print("[TEST] Loading Chart Data sheet...")
    load_success = analyzer.load_data()
    assert load_success, "Failed to load Chart Data sheet"
    print(f"[TEST] ✓ Data loaded successfully")

    # Analyze data
    print("[TEST] Analyzing chart data...")
    analyze_success = analyzer.analyze_chart_data()
    assert analyze_success, "Failed to analyze chart data"
    print(f"[TEST] ✓ Analyzed {len(analyzer.data_dict)} unique entries")

    # Generate constraint file
    print("[TEST] Generating constraint CSV file...")
    result_file = analyzer.generate_constraint_file(output_file)
    assert result_file is not None, "Failed to generate constraint file"
    assert os.path.exists(output_file), f"Output file not created: {output_file}"
    assert os.path.getsize(output_file) > 0, "Output file is empty"
    print(f"[TEST] ✓ Constraint file generated: {output_file}")

    # Verify file structure
    print("[TEST] Verifying constraint file structure...")
    with open(output_file, 'r') as f:
        lines = f.readlines()

    # Check header
    assert lines[0].startswith("#oam_id"), "Header line not found"
    print(f"[TEST] ✓ Header line present")

    # Check for family sections
    family_lines = [line for line in lines if line.startswith("# =====")]
    assert len(family_lines) > 0, "No family sections found"
    print(f"[TEST] ✓ Found {len(family_lines)} family sections")

    # Check for constraint entries (non-comment lines)
    constraint_lines = [line for line in lines if not line.startswith("#") and line.strip()]
    assert len(constraint_lines) > 0, "No constraint entries found"
    print(f"[TEST] ✓ Found {len(constraint_lines)} constraint entries")

    # Verify format of a few constraint lines
    sample_lines = [line for line in constraint_lines[:5]]
    for line in sample_lines:
        parts = line.split(';')
        assert len(parts) >= 6, f"Invalid constraint line format: {line}"
        # Verify OAM ID format
        oam_id = parts[0].strip()
        assert 'NRCELL' in oam_id or 'NRBTS' in oam_id, f"Invalid OAM ID: {oam_id}"

    print(f"[TEST] ✓ Constraint line format validated")

    # Display sample output
    print(f"[TEST] Sample constraint lines:")
    for i, line in enumerate(sample_lines[:3], 1):
        print(f"  {i}. {line.strip()}")

    # Test legacy mode
    print("[TEST] Testing legacy mode...")
    output_file_legacy = f"/tmp/test_constraint_legacy_{report_id}.csv"
    analyzer_legacy = Scout.ScoutComparatorAnalyzer(
        excel_file, sheet_name=None, legacy_mode=True
    )
    analyzer_legacy.load_data()
    analyzer_legacy.analyze_chart_data()
    result_legacy = analyzer_legacy.generate_constraint_file(output_file_legacy)

    assert result_legacy is not None, "Failed to generate legacy constraint file"
    assert os.path.exists(output_file_legacy), "Legacy output file not created"

    # Check for commented lines in legacy mode
    with open(output_file_legacy, 'r') as f:
        legacy_lines = f.readlines()

    # Verify some lines are commented (NRBTS or None/None)
    commented_data_lines = [
        line for line in legacy_lines
        if line.startswith("# NRBTS") or line.startswith("# NRCELL")
    ]
    print(
        f"[TEST] ✓ Legacy mode: {len(commented_data_lines)} lines commented"
    )

    # Cleanup
    if os.path.exists(output_file):
        os.remove(output_file)
    if os.path.exists(output_file_legacy):
        os.remove(output_file_legacy)

    print(
        f"[TEST] ✓ All ScoutComparatorAnalyzer tests passed "
        f"for Report ID {report_id}!"
    )
