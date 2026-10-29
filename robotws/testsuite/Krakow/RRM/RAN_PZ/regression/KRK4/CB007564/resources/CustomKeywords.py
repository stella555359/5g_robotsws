from moler.util.moler_test import MolerTest
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.MediaTek import MediaTek
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Positioner import Positioner


class CustomKeywords(object):
    """
    The CustomKeywords class provides a set of custom methods for handling various operations.
    """

    def __init__(self):
        """
        Initializes the CustomKeywords class.
        """
        self._positioner = None
        self._mediatek = None

    @property
    def positioner(self):
        """
        Returns the positioner object.

        If the positioner object is not already created, it creates a new instance of the Positioner class.

        Returns:
            Positioner: The positioner object.
        """
        if self._positioner is None:
            self._positioner = Positioner()
        return self._positioner

    @property
    def mediatek(self):
        """
        Returns an instance of the MediaTek class.

        If the instance does not exist, it creates a new instance and returns it.

        Returns:
            MediaTek: An instance of the MediaTek class.
        """
        if self._mediatek is None:
            self._mediatek = MediaTek()
        return self._mediatek

    def attach_ue_with_source_cell_ru_rotation(self, initial_angle=-20, rotation_angle=None, wait_after_attach=5,
                                               wait_after_rotation=2, ue_id=0, ue_serial_com="69"):
        """
        Attaches a UE with a source cell RU rotation.

        This method attaches a UE and rotates the source cell RU.
        It also detaches the UE after the operation.

        Parameters:
            initial_angle (int): The initial angle to set for the positioner before ue attach. Default is -20.
            rotation_angle (int): The angle to rotate the positioner after ue attach if specified. Default is None.
            wait_after_attach (int): The time to wait after attaching the UE. Default is 2.
            wait_after_rotation (int): The time to wait after rotating the source cell. Default is 3.
            ue_id (int): The ID of the UE. Default is 0.
            ue_serial_com (str): The serial COM id of the UE. Default is "69".

        Returns:
            None
            """
        # Master gNB_0 good conditions if angle == -20
        # Slave  gNB_1 good conditions if angle == 30
        self.positioner.set_angle(angle=initial_angle)
        try:
            self.mediatek.attach(ue_id=ue_id, serial_com=ue_serial_com)
            MolerTest.sleep(float(wait_after_attach))
            if rotation_angle:
                self.positioner.set_angle(angle=rotation_angle)
                MolerTest.sleep(wait_after_rotation)
        finally:
            self.mediatek.detach(ue_id=ue_id, serial_com=ue_serial_com)
