import threading
import time


class coam(object):
    def __init__(self, init_args):
        init_args.pop('self')
        self.init_args = init_args
        self.__dict__.update(self.init_args)

    def connect(self):
        raise NotImplementedError

    def disconnect(self):
        raise NotImplementedError

    def get_snapshot(self, path, coverage, timeout):
        raise NotImplementedError

    @staticmethod
    def _collect_snapshot(path, admin, **init_args):
        obj = admin(**init_args)
        obj.connect()
        try:
            obj.get_snapshot(path=path, coverage='Full', timeout=300)
        except Exception:
            raise
        finally:
            obj.disconnect()

    def check_snapshot_rejected_by_another(self, path1, path2, reject_msg):
        params = self.init_args
        params['alias'] = 't1'
        t1 = threading.Thread(target=self._collect_snapshot, args=(
            path1, self.__class__, ), kwargs=params)
        t1.start()

        time.sleep(10)

        params['alias'] = 't2'
        try:
            self._collect_snapshot(path2, self.__class__, **params)
        except Exception as e:
            if reject_msg in str(e):
                return True
        finally:
            t1.join()
        return False
