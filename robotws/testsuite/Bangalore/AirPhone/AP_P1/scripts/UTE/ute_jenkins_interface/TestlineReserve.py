import ute_cloud_reservation_api.api
import time
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()


class TestlineReserve():
    API_TOKEN = '87c05ce2bb42730f223940e85a721647b0f17889'
    TAG_TO_BRANCH = {'5G_RAN_TDD': 'master_classicalbts_all'}

    def __init__(self):
        self.ute_reservation = ute_cloud_reservation_api.api.CloudReservationApi(self.API_TOKEN)

    def reserve(self, testline_type, gnb_build, tags=[], duration=240):
        gnb_build = self.check_and_get_gnb_build(gnb_build, tags[0])
        logger.info('Reserving TL of Type:{} with GNB Build {}'.format(testline_type,
                                                                       gnb_build))
        reservation_id = self.ute_reservation.create_reservation(testline_type,
                                                                 gnb_build,
                                                                 duration=duration,
                                                                 tags=tags)
        return reservation_id

    def wait_for_testline_state(self, reservation_id, state, wait_time_in_seconds):
        initial_time = current_time = int(time.time())
        while (current_time - initial_time) < wait_time_in_seconds:
            current_status = self.ute_reservation.get_reservation_status(reservation_id)
            if current_status == state:
                logging.info('TL State is succesfully set to {}'.format(current_status))
                return True
            logger.info('Elapsed Time is {}'.format(current_time - initial_time))
            logger.info('Current Reservation Status is {}'.format(current_status))
            time.sleep(10)
            current_time = int(time.time())
        return False

    def wait_for_testline_assigned(self, reservation_id, wait_time_in_seconds):
        return self.wait_for_testline_state(reservation_id, 'Testline assigned',
                                            wait_time_in_seconds)

    def wait_for_testline_confirmed(self, reservation_id, wait_time_in_seconds):
        return self.wait_for_testline_state(reservation_id, 'Confirmed',
                                            wait_time_in_seconds)

    def get_reservation_details(self, reservation_id):
        return self.ute_reservation.get_reservation_details(reservation_id)

    def release_reservation(self, reservation_id):
        return self.ute_reservation.release_reservation(reservation_id)

    def check_and_get_gnb_build(self, gnb_build, tag):
        branch = self.TAG_TO_BRANCH[tag]
        build = self.ute_reservation.list_enb_builds(branch=branch, name=gnb_build)
        if build:
            return build[0]['name']
        return self.get_latest_build_branch(branch)

    def get_latest_build_branch(self, branch):
        return self.ute_reservation.list_enb_builds(branch=branch)[0]['name']
