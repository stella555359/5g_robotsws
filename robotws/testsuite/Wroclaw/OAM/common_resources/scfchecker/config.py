import os
from typing import Dict, Any


class Config:
    """Configuration management for scfchecker module."""

    @staticmethod
    def get_bts_config() -> Dict[str, Any]:
        """Get BTS configuration from environment or defaults."""
        return {
            'host': os.getenv('BTS_HOST', '192.168.255.129'),
            'port': int(os.getenv('BTS_PORT', '443')),
            'timeout': int(os.getenv('BTS_TIMEOUT', '20')),
            'username': os.getenv('BTS_USERNAME', 'admin'),
            'password': os.getenv('BTS_PASSWORD', ''),
        }
