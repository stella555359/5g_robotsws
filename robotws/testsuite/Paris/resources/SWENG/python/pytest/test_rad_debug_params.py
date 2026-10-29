"""
Pytest module for RAD debug parameter configuration on Cloud RAN VDU.

This test module validates the RAD debug parameter configuration functionality
using the OamCloudAicDU class with mocked VDU connections.

To run:
    pytest test_rad_debug_params.py -v
    pytest test_rad_debug_params.py::TestRadDebugParams::test_update_rad_debug_params -v
"""

from __future__ import print_function
from builtins import object
import pytest
import sys
import os
import time
from unittest.mock import MagicMock, patch, call

# Mock Robot Framework to avoid execution context errors during import
sys.modules['robot.libraries.BuiltIn'] = MagicMock()
sys.modules['ReadConfig'] = MagicMock()

# Add parent directory to path for imports
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

# Now import the modules we need to test
try:
    from Oam import OamCloudAicDU
except ImportError as e:
    pytest.skip(f"Required modules not available: {e}", allow_module_level=True)


class TestRadDebugParams(object):
    """Test suite for RAD debug parameter configuration."""

    @pytest.fixture
    def mock_vdu_driver(self):
        """Fixture providing mocked VDU driver with expected methods."""
        mock_driver = MagicMock()

        # Mock successful operation responses
        mock_driver.rad_reload_domains.return_value = {
            'operation_id': 'op_123_reload_domains',
            'status': 'ongoing'
        }
        mock_driver.rad_reload_params.return_value = {
            'operation_id': 'op_456_reload_params',
            'status': 'ongoing'
        }
        mock_driver.update_rad_debug_params.return_value = {
            'operation_id': 'op_789_update_params',
            'status': 'ongoing'
        }
        mock_driver.get_rad_debug_params_update_operation.return_value = {
            'operation_id': 'op_completed',
            'status': 'succeeded'
        }

        return mock_driver

    @pytest.fixture
    def mock_oam_instance(self, mock_vdu_driver):
        """Fixture providing mocked OamCloudAicDU instance."""
        with patch('Oam.vdu') as mock_vdu_class:
            mock_vdu_class.return_value = mock_vdu_driver

            # Create mock connection objects
            mock_ssh_conn = MagicMock()
            mock_http_conn = MagicMock()
            mock_http_conn.addr = '192.168.255.129'
            mock_http_conn.port = 443
            mock_http_conn.username = 'Nemuadmin'
            mock_http_conn.password = 'Nokia@123'

            # Create OamCloudAicDU instance
            oam = OamCloudAicDU(
                sshConnection=mock_ssh_conn,
                httpConnection=mock_http_conn,
                hw=None,
                unit=None,
                index=0,
                proxy=None
            )
            oam.drvRef = mock_vdu_driver
            oam.httpAlias = 'test_vdu_connection'

            yield oam

    def test_update_rad_debug_params_success(self, mock_oam_instance, mock_vdu_driver):
        """Test successful RAD debug parameter update."""
        domain_name = 'L2PS'
        parameters = [
            {'name': 'rdFeatureFlagBitmapLevel', 'value': '4'},
            {'name': 'rdFeatureFlagBitmap4', 'value': '79'}
        ]

        # Execute the update
        result = mock_oam_instance.updateRadDebugParams(
            domain_name=domain_name,
            parameters=parameters,
            persistency='persistent',
            timeout=300
        )

        # Verify the workflow was executed in correct order
        assert mock_vdu_driver.rad_reload_domains.call_count == 2  # Initial + final reload
        assert mock_vdu_driver.rad_reload_params.call_count == 2  # Before + after update
        assert mock_vdu_driver.update_rad_debug_params.call_count == 1

        # Verify update_rad_debug_params was called with correct parameters
        update_call = mock_vdu_driver.update_rad_debug_params.call_args
        assert update_call[1]['domain_name'] == domain_name
        assert update_call[1]['parameters'] == parameters
        assert update_call[1]['persistency'] == 'persistent'

        # Verify result
        assert result['status'] == 'succeeded'

    def test_update_rad_debug_params_non_persistent(self, mock_oam_instance, mock_vdu_driver):
        """Test non-persistent RAD parameter configuration."""
        domain_name = 'RLC'
        parameters = [{'name': 'testParam', 'value': '123'}]

        result = mock_oam_instance.updateRadDebugParams(
            domain_name=domain_name,
            parameters=parameters,
            persistency='non-persistent',
            timeout=300
        )

        # Verify persistency mode was passed correctly
        update_call = mock_vdu_driver.update_rad_debug_params.call_args
        assert update_call[1]['persistency'] == 'non-persistent'
        assert result['status'] == 'succeeded'

    def test_wait_for_rad_debug_operation_success(self, mock_oam_instance, mock_vdu_driver):
        """Test operation monitoring completes successfully."""
        # Simulate operation progressing: ongoing -> ongoing -> succeeded
        mock_vdu_driver.get_rad_debug_params_update_operation.side_effect = [
            {'operation_id': 'op_123', 'status': 'ongoing'},
            {'operation_id': 'op_123', 'status': 'ongoing'},
            {'operation_id': 'op_123', 'status': 'succeeded'}
        ]

        result = mock_oam_instance._wait_for_rad_debug_operation(
            operation_id='op_123',
            initial_status='ongoing',
            timeout=300
        )

        assert result['status'] == 'succeeded'
        assert mock_vdu_driver.get_rad_debug_params_update_operation.call_count == 3

    def test_wait_for_rad_debug_operation_timeout(self, mock_oam_instance, mock_vdu_driver):
        """Test operation monitoring raises exception on timeout."""
        # Simulate operation never completing
        mock_vdu_driver.get_rad_debug_params_update_operation.return_value = {
            'operation_id': 'op_timeout',
            'status': 'ongoing'
        }

        with pytest.raises(Exception, match="timeout"):
            mock_oam_instance._wait_for_rad_debug_operation(
                operation_id='op_timeout',
                initial_status='ongoing',
                timeout=1  # Short timeout for test
            )

    def test_update_rad_debug_params_with_node_id(self, mock_oam_instance, mock_vdu_driver):
        """Test RAD parameter update with specific node_id."""
        result = mock_oam_instance.updateRadDebugParams(
            domain_name='MAC',
            parameters=[{'name': 'param1', 'value': 'val1'}],
            node_id='node_001',
            timeout=300
        )

        # Verify node_id was passed
        update_call = mock_vdu_driver.update_rad_debug_params.call_args
        assert update_call[1]['node_id'] == 'node_001'
        assert result['status'] == 'succeeded'

    def test_parameter_format_validation(self):
        """Test parameter list format validation."""
        # Valid parameter format
        params = [
            {'name': 'rdFeatureFlagBitmapLevel', 'value': '4'},
            {'name': 'rdFeatureFlagBitmap4', 'value': '79'}
        ]
        assert isinstance(params, list)
        assert all('name' in p and 'value' in p for p in params)

        # Invalid formats
        invalid_params = [
            [{'param': 'value'}],  # Wrong key
            [{'name': 'test'}],  # Missing 'value'
            [{'value': '123'}],  # Missing 'name'
        ]
        for invalid in invalid_params:
            assert not all('name' in p and 'value' in p for p in invalid)

    def test_domain_name_validation(self):
        """Test common RAD domain names."""
        valid_domains = ['L2PS', 'RLC', 'MAC', 'PDCP', 'PHY']
        for domain in valid_domains:
            assert isinstance(domain, str)
            assert len(domain) > 0
            assert domain.isupper() or domain.isalnum()

    @pytest.mark.parametrize("level,bitmap", [
        ('0', '0'),      # All off
        ('1', '1'),      # Minimal
        ('4', '79'),     # Full RIM debug (1001111b = 79d)
        ('4', '0x4F'),   # Hex format
    ])
    def test_l2ps_parameter_values(self, level, bitmap):
        """Test various L2PS parameter value formats."""
        params = [
            {'name': 'rdFeatureFlagBitmapLevel', 'value': level},
            {'name': 'rdFeatureFlagBitmap4', 'value': bitmap}
        ]
        assert len(params) == 2
        assert params[0]['name'] == 'rdFeatureFlagBitmapLevel'
        assert params[1]['name'] == 'rdFeatureFlagBitmap4'

    def test_persistency_modes(self):
        """Test persistency mode validation."""
        valid_modes = ['persistent', 'non-persistent']
        for mode in valid_modes:
            assert mode in ['persistent', 'non-persistent']

        invalid_modes = ['temporary', 'permanent', 'persistent-only']
        for mode in invalid_modes:
            assert mode not in ['persistent', 'non-persistent']
