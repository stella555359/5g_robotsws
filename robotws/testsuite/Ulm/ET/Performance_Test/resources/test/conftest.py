import pytest

from testsuite.Ulm.ET.Performance_Test.resources.test.fixture.scfdummy import ScfDummy


@pytest.fixture(scope="session")
def scf_dummy():
    return ScfDummy().get_scf_content()
