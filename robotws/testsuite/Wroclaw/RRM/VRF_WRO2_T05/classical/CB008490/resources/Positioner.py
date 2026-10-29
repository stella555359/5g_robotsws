from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from moler.exceptions import MolerException
from moler.util.moler_test import MolerTest
from moler.device import DeviceFactory


class Positioner(object):
    def __init__(self):
        self.positioner = None

    def _create_device(self):
        self.positioner = DeviceFactory.get_device(name="POSITIONER0")

    def _calibrate(self):
        cmd_calibrate = self.positioner.get_cmd(cmd_name="calibrate")
        try:
            cmd_calibrate(timeout=120)
        except Exception as e:
            self.positioner.goto_state(state="UNIX_REMOTE", rerun=3)
            MolerTest.error(
                "Positioner calibration error. Exception occurred: {}".format(e),
                raise_exception=True,
            )

    def _verify_angle(self, angle, deviation):
        angle = int(angle)
        current_angle = None
        cmd_get_angle = self.positioner.get_cmd(cmd_name="get_angle")
        try:
            current_angle = cmd_get_angle(timeout=120)["angle"]
        except Exception as e:
            self.positioner.goto_state(state="UNIX_REMOTE", rerun=3)
            MolerTest.error(
                "Cannot get angle on positioner: '{}'. Exception occurred: {}".format(
                    self.positioner.name, e
                ),
                raise_exception=True,
            )
        MolerTest.info(
            "Current angle:{}, Expected angle:{}".format(current_angle, angle)
        )
        if abs(int(current_angle) - angle) > deviation:
            MolerTest.warning(
                "Positioner angle verification warning. Current angle: {}, Expected angle {}".format(
                    current_angle, angle
                )
            )

    def set_angle_and_verify(self, angle, deviation=3, verify_angle=True):
        self.positioner.goto_state(state="POSITIONER", rerun=3)
        self._calibrate()
        cmd_angle = self.positioner.get_cmd(
            cmd_name="set_angle", cmd_params={"angle": int(angle)}
        )
        try:
            cmd_angle(timeout=120)
        except MolerException:
            self.positioner.goto_state(state="UNIX_REMOTE", rerun=3)
            MolerTest.error(
                "Cannot set angle '{}' on positioner: '{}'.".format(
                    angle, self.positioner.name
                ),
                raise_exception=True,
            )
        if verify_angle:
            self._verify_angle(angle, deviation)
        self.positioner.goto_state(state="UNIX_REMOTE", rerun=3)

    def set_angle(self, angle):
        cmd_angle = self.positioner.get_cmd(
            cmd_name="set_angle", cmd_params={"angle": int(angle)}
        )
        try:
            cmd_angle(timeout=120)
        except MolerException:
            self.positioner.goto_state(state="UNIX_REMOTE", rerun=3)
            MolerTest.error(
                "Cannot set angle '{}' on positioner: '{}'.".format(
                    angle, self.positioner.name
                ),
                raise_exception=True,
            )

    @MolerTest.raise_background_exceptions(check_steps_end=False)
    @load_moler_configuration_from_tl()
    def initialize_positioner(self):
        self._create_device()
        self.positioner.goto_state(state="POSITIONER", rerun=3)
        self._calibrate()
        self.set_angle(angle=30)

    def teardown_positioner(self):
        self.set_angle(angle=30)
        self.positioner.goto_state(state="UNIX_REMOTE", rerun=3)
