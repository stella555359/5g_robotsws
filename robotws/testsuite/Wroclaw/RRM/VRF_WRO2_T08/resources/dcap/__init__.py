from .dcap_manager import DCAPManager
from .log_profile import LogProfile
from .zip_extractor import extract_logs

dcap = DCAPManager()
__all__ = ['dcap', 'extract_logs', 'LogProfile']
