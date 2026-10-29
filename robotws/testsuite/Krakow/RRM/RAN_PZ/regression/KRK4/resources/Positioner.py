from moler.device import DeviceFactory
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl


class Positioner(object):
    """
    Represents a positioner object that can set angles and calibrate.

    Attributes:
        positioner: The positioner device.
        positioner_calibrated: A boolean indicating if the positioner is calibrated.
    """

    def __init__(self):
        self.positioner = None
        self.positioner_calibrated = False

    @load_moler_configuration_from_tl()
    def set_angle(self, angle, positioner_id=0):
        """
        Sets the angle of the positioner.

        Args:
            angle: The angle to set.
            positioner_id: The ID of the positioner.

        Raises:
            TimeoutError: If the command times out.
        """
        self._create_device(positioner_id=positioner_id)
        self._calibrate()
        cmd_set_angle = self.positioner.get_cmd(cmd_name="set_angle", cmd_params={'angle': int(angle)})
        cmd_set_angle(timeout=120)

    def _calibrate(self):
        """
        Calibrates the positioner if it is not already calibrated.

        Raises:
            TimeoutError: If the command times out.
        """
        if not self.positioner_calibrated:
            self.positioner.goto_state(state='POSITIONER', rerun=3)
            cmd_calibrate = self.positioner.get_cmd(cmd_name="calibrate")
            cmd_calibrate(timeout=120)
            self.positioner_calibrated = True

    def _create_device(self, positioner_id):
        """
        Creates the positioner device if it does not exist.

        Args:
            positioner_id: The ID of the positioner.
        """
        if not self.positioner:
            self.positioner = DeviceFactory.get_device(name=f'POSITIONER{positioner_id}')
