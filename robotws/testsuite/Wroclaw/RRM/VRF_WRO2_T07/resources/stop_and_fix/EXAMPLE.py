from time import sleep
from testsuite.Wroclaw.RRM.resources.log.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword


@logged_keyword
def test():
    """
    This is a example test during which cell is blocked to create alarm 49 and run stopping testline
    """
    for i in range(60):
        blog(1 + i)
        sleep(1)
