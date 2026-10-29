import os
import sys
import types
import pytest
import importlib
from pathlib import Path
from unittest.mock import MagicMock, patch
from .GetFiles import download_package_using_git

# Navigate up to the correct base directory
BASE_PATH = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(__file__))))
ROBOTWS_PATH = os.path.dirname(os.path.dirname(os.path.dirname(BASE_PATH)))

# Construct the paths
CONSTRAINTS_PATH = os.path.join(
    BASE_PATH,
    "SWENG",
    "robot",
    "examples",
    "config",
    "KPI",
    "constraints")
PM_PATH = os.path.join(
    BASE_PATH,
    "SWENG",
    "robot",
    "config",
    "KPI",
    "constraints")
KPIS_PATH = os.path.join(
    BASE_PATH,
    "SWENG",
    "python",
    "pytest",
    "KPIs")
# File paths
CONSTRAINTS_FILE = os.path.join(CONSTRAINTS_PATH, "SetupEndur2.csv")
CONSTRAINTS_FILE2 = os.path.join(CONSTRAINTS_PATH, "Background_13UEs_TMO_15min.csv")
PM_FILE = os.path.join(PM_PATH, "PM.BTS-1.20220618.113000.ANY.xml")
REPORT_FILE = os.path.join("robustCsvFiles", "transversal_robustness_kpis_report.csv")
PM_FILE2 = os.path.join(KPIS_PATH, "PM.BTS-1.20250926.120000.ANY.xml")
CONSTRAINTS_FILE3 = os.path.join(KPIS_PATH, "CB014386-B_B5_Before_Activation.csv")
PM_FILE3 = os.path.join(KPIS_PATH, "PM.BTS-1.20251001.132500.ANY.xml")
CONSTRAINTS_FILE4 = os.path.join(KPIS_PATH, "CB010980_PMQAP.csv")
CONSTRAINTS_FILE5 = os.path.join(KPIS_PATH, "CB010980_PMQAP2.csv")
PM_FILE4 = os.path.join(KPIS_PATH, "PM.BTS-1.20251014.131500.ANY.xml")
KPI_DEF_PRIVATE = os.path.join(ROBOTWS_PATH, "testsuite/Paris/RRM/ET/transversal_robustness/config/counter",
                               "KPI_Definitions_TOPKPI_25R3_withoutMissingCounter.csv")


@pytest.fixture(scope="session", autouse=True)
def _load_kpis_api():
    # Stub ReadConfig before loading KPIs
    dummy_topo = types.SimpleNamespace(
        GetBranchName=lambda: "SBTS00",
        getBranchName=lambda: "SBTS00",
        GetTestLineName=lambda: "",
        getBB=lambda: "ALL",
    )
    dummy_TLConfig = types.SimpleNamespace(topo=dummy_topo, isVranTl=False, setVMType=lambda: None)
    stub_readconfig = types.ModuleType("ReadConfig")
    stub_readconfig.TLConfig = dummy_TLConfig
    stub_readconfig.main = lambda: dummy_TLConfig
    sys.modules["ReadConfig"] = stub_readconfig

    # Minimal BuiltIn mock
    bi = MagicMock()
    bi.get_variable_value.return_value = "/tmp"
    built_in_mod = types.ModuleType("robot.libraries.BuiltIn")
    built_in_mod.BuiltIn = lambda: bi
    sys.modules["robot.libraries.BuiltIn"] = built_in_mod

    # Ensure path contains directory of KPIs.py
    kpis_path = Path(__file__).resolve().parent.parent
    sys.path.insert(0, str(kpis_path))

    import importlib.util
    kpis_file = kpis_path / "KPIs.py"
    spec = importlib.util.spec_from_file_location("KPIs", kpis_file)  # use real module name
    kpis = importlib.util.module_from_spec(spec)
    sys.modules["KPIs"] = kpis
    spec.loader.exec_module(kpis)

    LogClass = kpis.Log

    def _dummy_init(self, *a, **kw):
        # Accept the original signature (path only) but skip file creation.
        self.path = a[0] if a else None
        self.file = None

    def _dummy_trace(*a, **kw):  # static style
        return

    def _dummy_fulltrace(*a, **kw):
        return

    def _dummy_close():
        return

    # Patch methods
    LogClass.__init__ = _dummy_init
    LogClass.trace = staticmethod(_dummy_trace)
    LogClass.fullTrace = staticmethod(_dummy_fulltrace)
    if hasattr(LogClass, "close"):
        LogClass.close = staticmethod(_dummy_close)

    # Some code references Log.Driver()
    if not hasattr(LogClass, "Driver"):
        LogClass.Driver = staticmethod(lambda: MagicMock())

    globals().update({
        "ConstraintFile": kpis.ConstraintFile,
        "CounterDefFile": kpis.CounterDefFile,
        "KpiDefFile": kpis.KpiDefFile,
        "State": kpis.State,
        "Constraint": kpis.Constraint,
        "evaluateConstraints": kpis.evaluateConstraints,
        "get_last_constraints": kpis.get_last_constraints
    })
    return kpis


# Reuse common patch for TLConfig + Log in per-test fixtures
def _patch_runtime():
    return patch.multiple("KPIs.TLConfig.topo",
                          GetBranchName=lambda: "SBTS00",
                          getBranchName=lambda: "SBTS00",
                          GetTestLineName=lambda: "",
                          getBB=lambda: "ALL")


@pytest.fixture(scope="session", autouse=True)
def _load_scout_api():
    # Explicit file-based import to avoid name collision
    kpis_path = Path(__file__).resolve().parent.parent  # .../resources/SWENG/python
    scout_file = kpis_path / "Scout.py"
    spec = importlib.util.spec_from_file_location("scout_module", scout_file)
    scout = importlib.util.module_from_spec(spec)
    sys.modules["scout_module"] = scout
    spec.loader.exec_module(scout)
    globals().update({
        "Scout": scout
    })
    return scout


@pytest.fixture
def envsetup():
    print("Setup")
    mock_builtin = MagicMock()
    sys.modules["robot.libraries.BuiltIn"] = MagicMock(BuiltIn=mock_builtin)
    mock_builtin.return_value.set_suite_variable = MagicMock()
    mock_builtin.return_value._get_context = MagicMock()
    with patch("KPIs.Log.Driver", new=MagicMock()) as mock_driver:
        counter_def_file = CounterDefFile('SBTS00')
        kpi_def_file = KpiDefFile('SBTS00')
    # Mock Log.Driver
    with patch("KPIs.Log.Driver", new=MagicMock()) as mock_driver:
        # Instantiate the class with all required arguments
        constraint_file_obj = ConstraintFile(CONSTRAINTS_FILE, counter_def_file, kpi_def_file, None)
    return constraint_file_obj


@pytest.fixture
def envsetup2():
    print("Setup")
    mock_builtin = MagicMock()
    sys.modules["robot.libraries.BuiltIn"] = MagicMock(BuiltIn=mock_builtin)
    test_df = Scout.get_kpis_report_from_file(REPORT_FILE, "testlines_entry.7_20_UTE5GCLASSTL008.")
    mock_builtin.return_value.set_suite_variable = MagicMock()
    mock_builtin.return_value._get_context = MagicMock()
    with patch("KPIs.Log.Driver", new=MagicMock()) as mock_driver:
        counter_def_file = CounterDefFile('SBTS00')
        kpi_def_file = KpiDefFile('SBTS00')
    # Mock Log.Driver
    with patch("KPIs.Log.Driver", new=MagicMock()) as mock_driver:
        # Instantiate the class with the dataframe only
        constraint_file_obj = ConstraintFile(CONSTRAINTS_FILE2, None, None, test_df)
    return constraint_file_obj, test_df


@pytest.fixture
def envsetup3():
    print("Setup")
    with patch("KPIs.TLConfig.topo.GetBranchName", return_value="SBTS00"), \
         patch("KPIs.TLConfig.topo.GetTestLineName", return_value=""), \
         patch("KPIs.TLConfig.topo.getBB", return_value="ALL"), \
         patch("robot.libraries.BuiltIn.BuiltIn") as mock_bi, \
         patch("KPIs.Log.trace", new=lambda *a, **k: None), \
         patch("KPIs.Log.fullTrace", new=lambda *a, **k: None):
        mock_bi.return_value.get_variable_value.return_value = "/tmp"
        counter_def_file = CounterDefFile('SBTS00')
        kpi_def_file = KpiDefFile('SBTS00')
        constraint_file_obj = ConstraintFile(CONSTRAINTS_FILE3, counter_def_file, kpi_def_file, None)
    return constraint_file_obj


@pytest.fixture
def envsetup4():
    print("Setup")
    with _patch_runtime():
        counter_def_file = CounterDefFile('SBTS00')
        kpi_def_file = KpiDefFile('SBTS00')
    return counter_def_file, kpi_def_file


@pytest.fixture
def envsetup5():
    print("Setup")
    if not os.path.exists(os.path.join(KPIS_PATH, 'PM.BTS-1.20251001.132500.ANY.xml')):
        download_package_using_git('gitlabe1.ext.net.nokia.com/nps_vrf_8_and_9/bsr.git',
                                   'SWENG/Test_files', 'PM.BTS-1.20251001.132500.ANY.xml',
                                   'NpsVrfToken', 'glpat-4yNB_jaBXxz_BsyeAsgL', target_dir=KPIS_PATH)
    else:
        print(f"File already exists in {KPIS_PATH}.")
    with patch("KPIs.TLConfig.topo.GetBranchName", return_value="SBTS00"), \
         patch("KPIs.TLConfig.topo.GetTestLineName", return_value=""), \
         patch("KPIs.TLConfig.topo.getBB", return_value="ALL"), \
         patch("robot.libraries.BuiltIn.BuiltIn") as mock_bi, \
         patch("KPIs.Log.trace", new=lambda *a, **k: None), \
         patch("KPIs.Log.fullTrace", new=lambda *a, **k: None):
        mock_bi.return_value.get_variable_value.return_value = "/tmp"
    # Yield constraint file path for test
    yield CONSTRAINTS_FILE5
    # Cleanup PM file after test run
    if os.path.exists(PM_FILE3):
        try:
            os.remove(PM_FILE3)
            print(f"Removed PM file after test: {PM_FILE3}")
        except Exception as e:
            print(f"Failed to remove PM file {PM_FILE3}: {e}")


@pytest.fixture
def envsetup6():
    print("Setup")
    if not os.path.exists(os.path.join(KPIS_PATH, 'PM.BTS-1.20251014.131500.ANY.xml')):
        download_package_using_git('gitlabe1.ext.net.nokia.com/nps_vrf_8_and_9/bsr.git',
                                   'SWENG/Test_files', 'PM.BTS-1.20251014.131500.ANY.xml',
                                   'NpsVrfToken', 'glpat-4yNB_jaBXxz_BsyeAsgL', target_dir=KPIS_PATH)
    else:
        print(f"File already exists in {KPIS_PATH}.")
    with patch("KPIs.TLConfig.topo.GetBranchName", return_value="SBTS00"), \
         patch("KPIs.TLConfig.topo.GetTestLineName", return_value=""), \
         patch("KPIs.TLConfig.topo.getBB", return_value="ALL"), \
         patch("robot.libraries.BuiltIn.BuiltIn") as mock_bi, \
         patch("KPIs.Log.trace", new=lambda *a, **k: None), \
         patch("KPIs.Log.fullTrace", new=lambda *a, **k: None):
        mock_bi.return_value.get_variable_value.return_value = "/tmp"
    # Yield constraint file path for test
    yield CONSTRAINTS_FILE2
    # Cleanup PM file after test run
    if os.path.exists(PM_FILE4):
        try:
            os.remove(PM_FILE4)
            print(f"Removed PM file after test: {PM_FILE4}")
        except Exception as e:
            print(f"Failed to remove PM file {PM_FILE4}: {e}")


def test_contraintfile(envsetup):
    constraint_file_obj = envsetup
    # Check if the object is an instance of ConstraintFile
    assert isinstance(constraint_file_obj, ConstraintFile)
    # Check if the constraints attribute is a list
    assert isinstance(constraint_file_obj.constraints, list)
    # Check if the constraints list is not empty
    assert len(constraint_file_obj.constraints) > 0
    print(f"Constraints length: {len(constraint_file_obj.constraints)}")
    # Check if the first constraint is an instance of Constraint
    assert isinstance(constraint_file_obj.constraints[0], Constraint)
    assert len(constraint_file_obj.constraints) == 7


def test_contraintfile2(envsetup2):
    constraint_file_obj, drop_df = envsetup2
    # Check if the object is an instance of ConstraintFile
    assert isinstance(constraint_file_obj, ConstraintFile)
    # Check if the constraints attribute is a list
    assert isinstance(constraint_file_obj.constraints, list)
    # Check if the constraints list is not empty
    assert len(constraint_file_obj.constraints) > 0
    print(f"Constraints length: {len(constraint_file_obj.constraints)}")
    # Check if the first constraint is an instance of Constraint
    assert isinstance(constraint_file_obj.constraints[0], Constraint)
    assert len(constraint_file_obj.constraints) == 23


@patch("KPIs.TLConfig.topo.GetBranchName", return_value="SBTS00")
@patch("KPIs.TLConfig.topo.GetTestLineName", return_value="")
@patch("KPIs.TLConfig.topo.getBB", return_value="ALL")
@patch("KPIs.Log", new=MagicMock())
def test_stats(mock_get_branch_name, mock_get_test_line_name, mockbb, envsetup):
    constraint_file_obj = envsetup
    fail_on_error = False
    stats_result = constraint_file_obj.stats(fail_on_error)


@patch("KPIs.TLConfig.topo.GetBranchName", return_value="SBTS00")
@patch("KPIs.TLConfig.topo.GetTestLineName", return_value="")
@patch("KPIs.TLConfig.topo.getBB", return_value="ALL")
@patch("KPIs.Log", new=MagicMock())
def test_report(mock_get_branch_name, mock_get_test_line_name, mockbb, envsetup2):
    constraint_file_obj, report_df = envsetup2

    # Test case 1: rootParam not present in report (expect KEY_ERROR)
    constraint = constraint_file_obj.get_constraint(0)
    constraint.id_extension = "NA"
    constraint.type = "not_counter"
    constraint.rootParam = "NR_5152"  # Not present in CSV/report
    constraint.status = State.PASSED
    constraint.val = 10
    constraint.min = 5
    constraint.max = 15
    counter_report = {}
    if hasattr(constraint, "check_fromdf"):
        status = constraint.check_fromdf(report_df)[0]
    else:
        status = constraint.check(constraint.oam_id)
    print(f"Constraint {constraint.rootParam} check() returned: {status}")
    report_result = constraint.report(counter_report)
    print(f"Constraint {constraint.rootParam} report() returned: {report_result}")
    assert status == State.FAILED
    assert report_result is None

    # Test case 2: rootParam in counter_report and reported_value == State.FAILED
    constraint.type = "kpi"
    counter_report = {"NR_5152": (State.FAILED, State.FAILED)}
    status = constraint.check(constraint.oam_id)
    print(f"Constraint {constraint.rootParam} check() returned: {status}")
    report_result = constraint.report(counter_report)
    print(f"Constraint {constraint.rootParam} report() returned: {report_result}")
    assert report_result is None

    # Test case 3: self.status == State.FAILED
    constraint.status = State.FAILED
    counter_report = {}
    status = constraint.check(constraint.oam_id)
    print(f"Constraint {constraint.rootParam} check() returned: {status}")
    report_result = constraint.report(counter_report)
    print(f"Constraint {constraint.rootParam} report() returned: {report_result}")
    assert report_result is None

    # Test case 4: self.status != State.PASSED or self.val == 0
    constraint.status = "NOT_PASSED"
    constraint.val = 0
    counter_report = {}
    status = constraint.check(constraint.oam_id)
    print(f"Constraint {constraint.rootParam} check() returned: {status}")
    report_result = constraint.report(counter_report)
    print(f"Constraint {constraint.rootParam} report() returned: {report_result}")
    assert report_result is None

    # Test case 5: median == 0
    constraint.status = State.PASSED
    constraint.val = 10
    constraint.min = -10
    constraint.max = 10
    counter_report = {}
    status = constraint.check(constraint.oam_id)
    print(f"Constraint {constraint.rootParam} check() returned: {status}")
    report_result = constraint.report(counter_report)
    print(f"Constraint {constraint.rootParam} report() returned: {report_result}")
    assert report_result is None

    # Test case 6: (range / median) > 0.1
    constraint.min = 5
    constraint.max = 15
    counter_report = {}
    status = constraint.check(constraint.oam_id)
    print(f"Constraint {constraint.rootParam} check() returned: {status}")
    report_result = constraint.report(counter_report)
    print(f"Constraint {constraint.rootParam} report() returned: {report_result}")
    assert report_result is None

    # Test case 7: rootParam present in report (expect PASSED or FAILED)
    constraint2 = constraint_file_obj.get_constraint(3)
    print(f"Constraint type: {constraint2.type}")
    print(f"Constraint rootParam: {constraint2.rootParam}")
    checked, val = constraint2.check_fromdf(report_df)
    print(f"Checked: {checked}  -- Value: {val}")
    assert checked in {State.PASSED, State.FAILED}

    # Final status checks for all constraints
    key_errors = [c for c in constraint_file_obj.constraints if getattr(c, "status", None) == State.KEY_ERROR]
    print(f"KEY_ERROR constraints: {[str(c) for c in key_errors]}")
    valid_statuses = {State.PASSED, State.FAILED, State.NOT_CHECKED, State.KEY_ERROR}
    for c in constraint_file_obj.constraints:
        print(f"Constraint {c.rootParam} final status: {getattr(c, 'status', None)}")
        assert getattr(c, "status", None) in valid_statuses, \
            f"Constraint {c} has unexpected status: {getattr(c, 'status', None)}"


def test_evaluate_constraints(envsetup3):
    pmfile = PM_FILE2
    with patch("KPIs.BuiltIn", autospec=True) as mock_bi:
        mock_bi.return_value.get_variable_value.return_value = "/tmp"
        ok = evaluateConstraints(pmfile, envsetup3.path)
    cf = get_last_constraints()
    assert cf is not None, "ConstraintFile not captured"
    passed_cnt = sum(1 for c in cf.constraints if c.status == State.PASSED)
    assert ok, "evaluateConstraints returned False"
    assert passed_cnt == 24, f"Expected 24 PASSED constraints, got {passed_cnt}"


def test_constraintfile3(envsetup4):
    counter_def_file, kpi_def_file = envsetup4
    constraint_file_obj = ConstraintFile(CONSTRAINTS_FILE4, counter_def_file, kpi_def_file, None)
    # Check if the object is an instance of CounterDefFile
    assert isinstance(counter_def_file, CounterDefFile)
    # Check if the object is an instance of KpiDefFile
    assert isinstance(kpi_def_file, KpiDefFile)
    assert isinstance(constraint_file_obj, ConstraintFile)
    # Check if the constraints attribute is a list
    assert isinstance(constraint_file_obj.constraints, list)
    # Check if the constraints list is not empty
    assert len(constraint_file_obj.constraints) > 0
    print(f"Constraints length: {len(constraint_file_obj.constraints)}")
    # Check if the first constraint is an instance of Constraint
    assert isinstance(constraint_file_obj.constraints[0], Constraint)
    assert len(constraint_file_obj.constraints) == 7


def test_constraintfile4(envsetup4):
    counter_def_file, kpi_def_file = envsetup4
    constraint_file_obj = ConstraintFile(CONSTRAINTS_FILE5, counter_def_file, kpi_def_file, None)
    # Check if the object is an instance of CounterDefFile
    assert isinstance(counter_def_file, CounterDefFile)
    # Check if the object is an instance of KpiDefFile
    assert isinstance(kpi_def_file, KpiDefFile)
    assert isinstance(constraint_file_obj, ConstraintFile)
    # Check if the constraints attribute is a list
    assert isinstance(constraint_file_obj.constraints, list)
    # Check if the constraints list is not empty
    assert len(constraint_file_obj.constraints) > 0
    print(f"Constraints length: {len(constraint_file_obj.constraints)}")
    # Check if the first constraint is an instance of Constraint
    assert isinstance(constraint_file_obj.constraints[0], Constraint)
    assert len(constraint_file_obj.constraints) == 16


def test_evaluate_constraints2(envsetup5):
    constraint_file_path = envsetup5
    pmfile = PM_FILE3
    print(f"PM file used: {pmfile}")
    print(f"Constraint file used: {constraint_file_path}")
    with patch("KPIs.BuiltIn", autospec=True) as mock_bi:
        mock_bi.return_value.get_variable_value.return_value = "/tmp"
        ok = evaluateConstraints(pmfile, constraint_file_path, usePMQAP=True)
    cf = get_last_constraints()
    assert cf is not None, "ConstraintFile not captured (PMQAP run)"
    passed_cnt = sum(1 for c in cf.constraints if c.status == State.PASSED)
    failed_cnt = sum(1 for c in cf.constraints if c.status == State.FAILED)
    key_err_cnt = sum(1 for c in cf.constraints if c.status == State.KEY_ERROR)
    total_cnt = len(cf.constraints)
    print(f"PMQAP constraints total={total_cnt} passed={passed_cnt} failed={failed_cnt} key_error={key_err_cnt}")

    # Expectations for current PMQAP dataset
    assert total_cnt == 16, f"Expected 16 constraints, got {total_cnt}"
    assert passed_cnt == 13, f"Expected 13 PASSED, got {passed_cnt}"
    assert failed_cnt == 3, f"Expected 3 FAILED, got {failed_cnt}"
    assert key_err_cnt == 0, f"Expected 0 KEY_ERROR, got {key_err_cnt}"
    # evaluateConstraints should return False because not all passed
    assert ok is False, "evaluateConstraints should return False when a constraint FAILED"

    failed_roots = [c.rootParam for c in cf.constraints if c.status == State.FAILED]
    errated_list = ['M55161C00001', 'M55160C00001', 'M55373C00003']
    assert failed_roots == errated_list, f"Unexpected failed rootParams: {failed_roots}"


def test_evaluate_constraints3(envsetup6):
    constraint_file_path = envsetup6
    pmfile = PM_FILE4
    print(f"PM file used: {pmfile}")
    print(f"Constraint file used: {constraint_file_path}")
    with patch("KPIs.BuiltIn", autospec=True) as mock_bi:
        mock_bi.return_value.get_variable_value.return_value = "/tmp"
        ok = evaluateConstraints(pmfile, constraint_file_path, localKpiFile=KPI_DEF_PRIVATE, usePMQAP=True)
    cf = get_last_constraints()
    assert cf is not None, "ConstraintFile not captured (PMQAP run)"
    passed_cnt = sum(1 for c in cf.constraints if c.status == State.PASSED)
    failed_cnt = sum(1 for c in cf.constraints if c.status == State.FAILED)
    key_err_cnt = sum(1 for c in cf.constraints if c.status == State.KEY_ERROR)
    total_cnt = len(cf.constraints)
    print(f"PMQAP constraints total={total_cnt} passed={passed_cnt} failed={failed_cnt} key_error={key_err_cnt}")

    # Expectations for current PMQAP dataset
    assert total_cnt == 78, f"Expected 77 constraints, got {total_cnt}"
    assert passed_cnt == 59, f"Expected 59 PASSED, got {passed_cnt}"
    assert failed_cnt == 14, f"Expected 14 FAILED, got {failed_cnt}"
    assert key_err_cnt == 5, f"Expected 5 KEY_ERROR, got {key_err_cnt}"
    # evaluateConstraints should return False because not all passed
    assert ok is False, "evaluateConstraints should return False when a constraint FAILED"


def test_reportToPortal(monkeypatch, tmp_path):
    import types
    import KPIs
    from KPIs import State, PMParser
    # Build fake parser with a prepared counterReport
    parser = types.SimpleNamespace()
    parser.counterReport = {
        "M12345C00001": (State.PASSED, 150.0),
        "M12345C00002": (State.FAILED, 75.0),
        "M12345C00003": (State.KEY_ERROR, 0.0)  # should be skipped
    }

    calls = []

    def fake_report_pm_counter(cid, val, res):
        calls.append((cid, val, res))

    monkeypatch.setattr(KPIs, "RP_PORTAL", types.SimpleNamespace(report_pm_counter=fake_report_pm_counter))
    # Attach method from class (needs self)
    parser.reportToPortal = PMParser.reportToPortal.__get__(parser, PMParser)
    parser.reportToPortal()

    assert len(calls) == 3
    assert ("M12345C00001", 150.0, "PASSED") in calls
    assert ("M12345C00002", 75.0, "FAILED") in calls
