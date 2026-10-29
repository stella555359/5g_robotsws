class RobotLibrary:
    _singleton = None
    _initiated = False
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __new__(cls, *args, **kwargs):
        if cls._singleton is None:
            cls._singleton = super().__new__(cls)
        return cls._singleton

    def _library_initiation_guard(self):
        if self._initiated is False:
            self._initiated = True
            return False
        return True
