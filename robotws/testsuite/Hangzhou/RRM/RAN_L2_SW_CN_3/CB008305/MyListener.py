import os


class MyListener:

    ROBOT_LISTENER_API_VERSION = 2

    SUITE_INDENTATION = 0
    TEST_INDENTATION = 2
    KEYWORD_INDENTATION = 4

    def __init__(self, filename='listen.txt'):
        outpath = os.path.join(os.curdir, filename)
        self.outfile = open(outpath, 'w')
        self.keywords = []
        self.indentation = 4

    def start_suite(self, name, attrs):
        self.outfile.write("==============================\n")
        self.outfile.write("%sSuite: %s\n" % (MyListener.SUITE_INDENTATION * ' ', name))
        self.outfile.write("==============================\n")

        print("==============================\n")
        print("%sSuite: %s\n" % (MyListener.SUITE_INDENTATION * ' ', name))
        print("==============================\n")

    def start_test(self, name, attrs):
        self.outfile.write("%sTest: %s\n" % (MyListener.TEST_INDENTATION * ' ', name))
        print("%sTest: %s\n" % (MyListener.TEST_INDENTATION * ' ', name))

    def start_keyword(self, name, attrs):
        if len(self.keywords) > 0 and name != self.keywords[-1]:
            self.outfile.write("\n")

        self.keywords.append(name)
        self.outfile.write("%sKeyword: %s" % (MyListener.KEYWORD_INDENTATION * ' ', name))

        print("%sKeyword: %s" % (MyListener.KEYWORD_INDENTATION * ' ', name))

        MyListener.KEYWORD_INDENTATION += 2

    def end_keyword(self, name, attrs):
        self.keywords.remove(name)
        MyListener.KEYWORD_INDENTATION -= 2
        self.outfile.write("%s| %s |\n" % (MyListener.KEYWORD_INDENTATION * ' ', attrs['status']))

        print("%s| %s |\n" % (MyListener.KEYWORD_INDENTATION * ' ', attrs['status']))

    def end_test(self, name, attrs):
        if attrs['status'] == 'PASS':
            self.outfile.write('  | PASS |\n')
            print('  | PASS |\n')
        else:
            self.outfile.write('  | FAIL | %s\n' % attrs['message'])
            print('  | FAIL | %s\n' % attrs['message'])
        self.outfile.write("------------------------------\n")
        print("------------------------------\n")

    def end_suite(self, name, attrs):
        self.outfile.write('| %s |\n%s\n' % (attrs['status'], attrs['message']))
        print('| %s |\n%s\n' % (attrs['status'], attrs['message']))

    def close(self):
        self.outfile.write('-----ALL ROBOT CASES FINISHED-----')
        print('-----ALL ROBOT CASES FINISHED-----')
        self.outfile.close()
