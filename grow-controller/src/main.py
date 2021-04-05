from os.path import isfile
from time import sleep

def main():
    while True:
        print('Running app...')

        # readiness and liveliness check
        ready_path = '/tmp/ready/check'
        if not isfile(ready_path):
            ready_file = None
            try:
                ready_file = open(ready_path, 'w')
                ready_file.write('Ready')
            except Exception as err:
                print('Error: %s' % str(err))
            finally:
                if ready_file is not None:
                    ready_file.close()
            ready_file.close()

        sleep(2)

if __name__ == '__main__':
    main()
