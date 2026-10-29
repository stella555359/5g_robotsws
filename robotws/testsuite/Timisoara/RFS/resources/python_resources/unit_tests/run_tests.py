#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Test runner for all unit tests in the unit_tests package.

This script automatically discovers and runs all test files in the unit_tests directory.
It provides options to run specific test modules, show verbose output, and generate coverage reports.

Usage:
    python run_tests.py                    # Run all tests
    python run_tests.py -m test_module     # Run specific test module
    python run_tests.py -v                 # Verbose output
    python run_tests.py --coverage         # Run with coverage report
    python run_tests.py --help             # Show all options
"""

import sys
import os
import unittest
import argparse
from pathlib import Path


def get_test_suite(test_dir=None, pattern='test_*.py', specific_module=None):
    """
    Discover and return a test suite containing all tests.

    :param test_dir: Directory to search for tests (default: current directory)
    :param pattern: Pattern to match test files (default: test_*.py)
    :param specific_module: Run only this specific test module
    :return: unittest.TestSuite object
    """
    if test_dir is None:
        # Get the directory where this script is located (unit_tests folder)
        test_dir = Path(__file__).parent.absolute()

    # Add the test directory and parent directory to Python path
    sys.path.insert(0, str(test_dir))
    sys.path.insert(0, str(test_dir.parent))

    if specific_module:
        # Load specific test module
        try:
            loader = unittest.TestLoader()
            suite = loader.loadTestsFromName(specific_module)
            return suite
        except (ImportError, AttributeError) as e:
            print(f"Error loading test module '{specific_module}': {e}")
            return unittest.TestSuite()
    else:
        # Discover all tests
        loader = unittest.TestLoader()
        suite = loader.discover(str(test_dir), pattern=pattern)
        return suite


def run_tests_with_coverage(test_suite, coverage_config=None):
    """
    Run tests with coverage reporting.

    :param test_suite: Test suite to run
    :param coverage_config: Coverage configuration options
    :return: Test result
    """
    try:
        import coverage

        # Initialize coverage
        cov = coverage.Coverage()
        if coverage_config:
            cov.config.from_args(**coverage_config)

        cov.start()

        # Run tests
        runner = unittest.TextTestRunner(verbosity=2)
        result = runner.run(test_suite)

        # Stop coverage and report
        cov.stop()
        cov.save()

        print("\n" + "="*50)
        print("COVERAGE REPORT")
        print("="*50)
        cov.report()

        # Generate HTML coverage report
        html_dir = Path(__file__).parent / 'coverage_html'
        cov.html_report(directory=str(html_dir))
        print(f"\nHTML coverage report generated in: {html_dir}")

        return result

    except ImportError:
        print("Coverage package not installed. Install with: pip install coverage")
        print("Running tests without coverage...")
        runner = unittest.TextTestRunner(verbosity=2)
        return runner.run(test_suite)


def main():
    """Main entry point for the test runner."""
    parser = argparse.ArgumentParser(
        description='Run unit tests for python_resources modules',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python run_tests.py                           # Run all tests
  python run_tests.py -v                       # Run with verbose output
  python run_tests.py -m test_alarms_analysis   # Run specific module
  python run_tests.py --coverage                # Run with coverage
  python run_tests.py --list                    # List available test modules
        """
    )

    parser.add_argument(
        '-m', '--module',
        help='Run specific test module (e.g., test_alarms_analysis)',
        metavar='MODULE_NAME'
    )

    parser.add_argument(
        '-v', '--verbose',
        action='store_true',
        help='Verbose output (show individual test names)'
    )

    parser.add_argument(
        '--coverage',
        action='store_true',
        help='Run tests with coverage reporting'
    )

    parser.add_argument(
        '--pattern',
        default='test_*.py',
        help='Pattern to match test files (default: test_*.py)'
    )

    parser.add_argument(
        '--list',
        action='store_true',
        help='List available test modules and exit'
    )

    parser.add_argument(
        '--failfast',
        action='store_true',
        help='Stop on first failure'
    )

    args = parser.parse_args()

    # Get test directory (current directory since script is in unit_tests)
    test_dir = Path(__file__).parent.absolute()

    if not test_dir.exists():
        print(f"Error: Test directory '{test_dir}' not found!")
        return 1

    # List available test modules
    if args.list:
        print("Available test modules:")
        for test_file in test_dir.glob(args.pattern):
            if test_file.is_file() and test_file.name != 'run_tests.py':
                module_name = test_file.stem
                print(f"  {module_name}")
        return 0

    # Get test suite
    print("Discovering tests...")
    test_suite = get_test_suite(test_dir, args.pattern, args.module)

    # Count tests
    test_count = test_suite.countTestCases()
    if test_count == 0:
        if args.module:
            print(f"No tests found for module '{args.module}'")
        else:
            print("No tests found!")
        return 1

    print(f"Found {test_count} test(s)")
    print("="*50)

    # Run tests
    if args.coverage:
        result = run_tests_with_coverage(test_suite)
    else:
        verbosity = 2 if args.verbose else 1
        runner = unittest.TextTestRunner(
            verbosity=verbosity,
            failfast=args.failfast
        )
        result = runner.run(test_suite)

    # Print summary
    print("\n" + "="*50)
    print("TEST SUMMARY")
    print("="*50)
    print(f"Tests run: {result.testsRun}")
    print(f"Failures: {len(result.failures)}")
    print(f"Errors: {len(result.errors)}")
    print(
        f"Skipped: {len(result.skipped) if hasattr(result, 'skipped') else 0}")

    if result.failures:
        print(f"\nFAILURES ({len(result.failures)}):")
        for test, traceback in result.failures:
            print(
                f"  {test}: {traceback.split('AssertionError:')[-1].strip()}")

    if result.errors:
        print(f"\nERRORS ({len(result.errors)}):")
        for test, traceback in result.errors:
            print(f"  {test}: {traceback.splitlines()[-1].strip()}")

    # Return appropriate exit code
    if result.failures or result.errors:
        return 1
    else:
        print("\nAll tests passed! ✅")
        return 0


if __name__ == '__main__':
    exit_code = main()
    sys.exit(exit_code)
