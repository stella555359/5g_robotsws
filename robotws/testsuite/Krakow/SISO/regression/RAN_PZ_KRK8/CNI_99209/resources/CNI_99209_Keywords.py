from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.devices.asir.asir_operations import GnbAsirHubOperations
from taf.rfrl.bts.devices.generic_bts import GenericBts
import random


def generate_valid_password() -> str:
    return "!Nokia@".join(random.choices("1234567890", k=3))


def perform_rollback():
    GnbDuOperations().rollback_software()


def perform_asir_commissioning(scf_path: str):
    GnbAsirHubOperations().perform_asir_commissioning(scf_path)


def fix_bts_connection():
    GenericBts().disconnect()
