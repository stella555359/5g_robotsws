"""
Pytest tests for PM post-processing functions.
Tests the Python replacement for shell scripts (pos_process.sh and fic_rm.sh).
"""

import os
import sys
import tempfile
import gzip
import importlib.util
from pathlib import Path
import pytest

# Navigate up to the correct base directory (same pattern as test_KPIs.py)
BASE_PATH = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(__file__))))
COUNTERS_PATH = os.path.join(BASE_PATH, "SWENG", "python")


# Load Counters module dynamically to avoid E402
def _get_counters_module():
    """Dynamically load the Counters module"""
    counters_file = os.path.join(COUNTERS_PATH, "Counters.py")
    spec = importlib.util.spec_from_file_location("Counters", counters_file)
    counters = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(counters)
    return counters


# Get the functions we need
_counters = _get_counters_module()
remove_old_pm_files = _counters.remove_old_pm_files
post_process_pm_files = _counters.post_process_pm_files


@pytest.fixture
def pm_test_files():
    """
    Pytest fixture to create sample PM files for testing.
    Creates a temporary directory with compressed PM files.
    """
    with tempfile.TemporaryDirectory() as temp_dir:
        # Create compressed PM files with different timestamps
        files = [
            "A20241205.0900+0000-20241205.0915+0000_1.xml.gz",
            "A20241205.0915+0000-20241205.0930+0000_1.xml.gz",
            "A20241205.0930+0000-20241205.0945+0000_1.xml.gz",  # Latest
            "A20241205.0930+0000-20241205.0945+0000_2.xml.gz",  # Latest
        ]

        xml_content = """<?xml version="1.0"?><OMeS version="2.3">
<measData xmlns="http://www.3gpp.org/ftp/specs/archive/32_series/32.435#measData">
  <measInfo measInfoId="1">
    <measValue measObjLdn="MRBTS-1/NRBTS-1/NRCELL-1">
      <measResults>100 200 300</measResults>
    </measValue>
  </measInfo>
</measData>
</OMeS>"""

        for filename in files:
            filepath = os.path.join(temp_dir, filename)
            with gzip.open(filepath, 'wt') as f:
                f.write(xml_content)

        yield temp_dir, files


class TestRemoveOldPMFiles:
    """Test suite for remove_old_pm_files function"""

    def test_removes_old_files_keeps_latest(self, pm_test_files):
        """Test that old PM files are removed and only latest timestamp files are kept"""
        temp_dir, original_files = pm_test_files

        # Verify all files created
        assert len(os.listdir(temp_dir)) == 4

        # Remove old files
        latest_date = remove_old_pm_files(temp_dir)

        # Verify return value
        assert latest_date == "20241205.0930+0000"

        # Verify only 2 files remain (both with latest timestamp)
        remaining = os.listdir(temp_dir)
        assert len(remaining) == 2

        # Verify remaining files have latest timestamp
        for filename in remaining:
            assert "20241205.0930+0000" in filename

    def test_handles_empty_directory(self):
        """Test that function handles empty directory gracefully"""
        with tempfile.TemporaryDirectory() as temp_dir:
            latest_date = remove_old_pm_files(temp_dir)
            assert latest_date == ""

    def test_handles_invalid_directory(self):
        """Test that function raises error for non-existent directory"""
        with pytest.raises(ValueError, match="does not exist"):
            remove_old_pm_files("/nonexistent/directory")


class TestPostProcessPMFiles:
    """Test suite for post_process_pm_files function"""

    def test_creates_consolidated_pm_xml(self, pm_test_files):
        """Test that PM files are decompressed, merged, and consolidated into PM.xml"""
        temp_dir, original_files = pm_test_files

        # First remove old files
        remove_old_pm_files(temp_dir)

        # Post-process remaining files
        vpm_local = "vDU_PM_20241205-120000"
        pm_xml_path = post_process_pm_files(temp_dir, vpm_local)

        # Verify PM.xml was created
        assert os.path.exists(pm_xml_path)
        assert pm_xml_path == os.path.join(temp_dir, "PM.xml")

        # Verify PM.xml content
        with open(pm_xml_path, 'r') as f:
            content = f.read()

        assert '<?xml version="1.0"?>' in content
        assert '<OMeS>' in content
        assert '</OMeS>' in content
        assert 'NRCELL' in content
        assert 'measResults' in content

    def test_removes_individual_xml_files(self, pm_test_files):
        """Test that individual A*.xml files are cleaned up after processing"""
        temp_dir, original_files = pm_test_files

        remove_old_pm_files(temp_dir)
        vpm_local = "vDU_PM_20241205-120000"
        post_process_pm_files(temp_dir, vpm_local)

        # Verify no A*.xml files remain (only PM.xml)
        a_xml_files = [f for f in os.listdir(temp_dir) if f.startswith('A') and f.endswith('.xml')]
        assert len(a_xml_files) == 0

        # Verify PM.xml exists
        assert os.path.exists(os.path.join(temp_dir, "PM.xml"))

    def test_creates_marker_file(self, pm_test_files):
        """Test that marker file is created in parent directory"""
        temp_dir, original_files = pm_test_files

        remove_old_pm_files(temp_dir)
        vpm_local = "vDU_PM_20241205-120000"
        post_process_pm_files(temp_dir, vpm_local)

        # Check marker file in parent directory
        parent_dir = os.path.dirname(temp_dir)
        marker_files = [f for f in os.listdir(parent_dir) if f.startswith('DIR___')]

        # At least one marker file should exist
        assert len(marker_files) > 0

        # Verify marker file format
        marker_found = False
        for marker in marker_files:
            if 'vDU_PM' in marker and '20241205-120000' in marker:
                marker_found = True
                break
        assert marker_found

    def test_handles_vcu_prefix(self, pm_test_files):
        """Test that vCU prefix is handled correctly"""
        temp_dir, original_files = pm_test_files

        remove_old_pm_files(temp_dir)
        vpm_local = "vCU_PM_20241205-130000"
        pm_xml_path = post_process_pm_files(temp_dir, vpm_local)

        assert os.path.exists(pm_xml_path)

        # Check marker file has vCU prefix
        parent_dir = os.path.dirname(temp_dir)
        marker_files = [f for f in os.listdir(parent_dir) if f.startswith('DIR___') and 'vCU' in f]
        assert len(marker_files) > 0

    def test_handles_invalid_directory(self):
        """Test that function raises error for non-existent directory"""
        with pytest.raises(ValueError, match="does not exist"):
            post_process_pm_files("/nonexistent/directory", "vDU_PM_test")


class TestIntegration:
    """Integration tests for complete PM post-processing workflow"""

    def test_full_workflow_vdu(self, pm_test_files):
        """Test complete workflow: create files -> remove old -> post-process"""
        temp_dir, original_files = pm_test_files

        # Step 1: Remove old files
        latest_date = remove_old_pm_files(temp_dir)
        assert latest_date == "20241205.0930+0000"
        assert len(os.listdir(temp_dir)) == 2

        # Step 2: Post-process
        vpm_local = "vDU_PM_20241205-120000"
        pm_xml_path = post_process_pm_files(temp_dir, vpm_local)

        # Step 3: Verify final state
        assert os.path.exists(pm_xml_path)

        with open(pm_xml_path, 'r') as f:
            content = f.read()

        # Verify proper XML structure
        assert content.startswith('<?xml version="1.0"?>\n<OMeS>')
        assert content.strip().endswith('</OMeS>')

        # Verify only PM.xml remains
        files_in_dir = os.listdir(temp_dir)
        assert files_in_dir == ['PM.xml']

    def test_full_workflow_vcu(self, pm_test_files):
        """Test complete workflow with vCU prefix"""
        temp_dir, original_files = pm_test_files

        latest_date = remove_old_pm_files(temp_dir)
        vpm_local = "vCU_PM_20241205-140000"
        pm_xml_path = post_process_pm_files(temp_dir, vpm_local)

        assert os.path.exists(pm_xml_path)
        assert os.listdir(temp_dir) == ['PM.xml']
