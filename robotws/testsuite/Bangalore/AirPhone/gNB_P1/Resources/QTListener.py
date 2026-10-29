from AgentFailureEvidenceCollector import AgentFailureEvidenceCollector


class QTListener:
    ROBOT_LISTENER_API_VERSION = 2

    def __init__(self, output_path='/tmp/'):
        self.output_path = output_path
        self.is_evidence_collected = False

    def end_test(self, data, test):
        if self.is_evidence_collected is False:
            if test['status'] == 'FAIL':
                evidence_collector = AgentFailureEvidenceCollector(output_path=self.output_path)
                evidence_collector.collect_symptoms()
                self.is_evidence_collected = True
        return

    def end_suite(self, data, test):
        if self.is_evidence_collected is False:
            if test['status'] == 'FAIL':
                evidence_collector = AgentFailureEvidenceCollector(output_path=self.output_path)
                evidence_collector.collect_symptoms()
        return
