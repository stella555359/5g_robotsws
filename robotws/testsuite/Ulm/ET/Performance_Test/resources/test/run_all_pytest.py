"""Run Unittests

Returns:
    int: exit code 1 if a test had failed
"""
import sys
import pathlib
import logging
import pytest
import pycodestyle
from typing import Dict

# Navigate 6 levels up from resources/test/ to reach robotws root:
# test -> resources -> Performance_Test -> ET -> Ulm -> testsuite -> robotws
repo_dir = pathlib.Path(__file__).resolve().parents[6].absolute()
logger = logging.getLogger(__name__)

COVERAGE_MINIMUM_PERCENTAGE = 21


def run_tests() -> Dict[str, int]:
    """Execute all test suites: pytest with coverage and pycodestyle checks.

    Returns:
        Dict[str, int]: Dictionary mapping test names to their exit codes (0 = success)
    """
    logger.info("performance_tests")
    tests_dir = repo_dir.joinpath(
        "testsuite", "Ulm", "ET", "Performance_Test", "resources", "test")
    py_dir = repo_dir.joinpath(
        "testsuite", "Ulm", "ET", "Performance_Test", "resources", "python")
    return {
        "run_pytest": run_pytest(tests_dir, py_dir),
        "run_pycodestyle": run_pycodestyle(py_dir),
        "run_pycodestyle_tests": run_pycodestyle(tests_dir),
    }


def run_pytest(testpath: pathlib.Path, cov_dir: pathlib.Path) -> int:
    """Run pytest with coverage analysis.

    Args:
        testpath: Path to test directory
        cov_dir: Path to source code directory for coverage analysis

    Returns:
        int: pytest exit code (0 = success)
    """
    logger.info("run_pytest: %s", testpath.name)
    return pytest.main(['--disable-warnings',
                        f'--cov={cov_dir}',
                        f'--cov-fail-under={COVERAGE_MINIMUM_PERCENTAGE}',
                        '-v',
                        str(testpath)])


def run_pycodestyle(file_path: pathlib.Path) -> int:
    """Run PEP 8 style checks on Python files.

    Modified by AI: 2025-11-28 - Fixed E501 ignore conflict and unified output

    Args:
        file_path: Path to Python file or directory to check

    Returns:
        int: Number of style violations found (0 = success)
    """
    if not file_path.exists():
        logger.error("Path does not exist: %s", file_path)
        return 1

    style_guide = pycodestyle.StyleGuide(
        benchmark=True,
        show_pep8=True,
        show_source=True,
        max_line_length=120,
        ignore=['E121', 'E123', 'E126', 'E226', 'E24', 'E704', 'W503', 'W504'],
        count=True,
        statistics=True
    )
    report = style_guide.check_files([str(file_path)])
    logger.info("\nTotal errors found: %s", report.total_errors)
    if report.counters:
        logger.info("\nStatistics:")
        for error, count in sorted(report.counters.items()):
            logger.info("  %s: %d", error, count)
    return report.total_errors


def main() -> int:
    """Main entry point for test execution.

    Returns:
        int: Exit code (0 = all tests passed, 1 = at least one test failed)
    """
    exit_code = 0
    test_results = run_tests()
    print("\n\n########################################")
    print("test results")
    print("########################################")
    for testname, test_result in test_results.items():
        print(f"{testname}: {test_result}")
        if test_result != 0:
            logger.error("%s: failed!", testname)
            exit_code = 1
    return exit_code


def fix_path() -> None:
    """Configure Python path to include required workspace directories."""
    fix_common_keyword_path()
    fix_robotws_path()


def fix_robotws_path() -> None:
    """Add robotws root directory to Python path.

    Raises:
        ValueError: If the directory is not named 'robotws'
    """
    robotws_dir = repo_dir
    if robotws_dir.name != 'robotws':
        raise ValueError(f"Expected 'robotws' directory, got '{robotws_dir.name}' at {robotws_dir}")
    _add_path(robotws_dir)


def fix_common_keyword_path() -> None:
    """Add common Robot Framework keyword directory to Python path."""
    _add_path(repo_dir.joinpath('testsuite', 'Ulm', 'resources', 'common', 'python'))


def _add_path(path_to_config: pathlib.Path) -> None:
    """Add a directory to Python's module search path.

    Args:
        path_to_config: Path to directory to add to sys.path

    Raises:
        ValueError: If path does not exist or is not a directory
    """
    if not path_to_config.is_dir():
        raise ValueError(f"Path is not a directory: {path_to_config}")
    print(f"appending path: {path_to_config}")
    sys.path.insert(1, str(path_to_config))
    logger.debug(sys.path)


if __name__ == "__main__":
    logging.basicConfig(
        format="%(asctime)s|%(levelname)-5.5s|%(module)s.%(funcName)s:%(lineno)d:%(message)s",
        encoding='utf-8',
        level=getattr(logging, "INFO")  # Changed from ERROR to see info messages
    )
    fix_path()
    sys.exit(main())
