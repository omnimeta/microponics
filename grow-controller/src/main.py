from os.path import isfile
from time import sleep

def main():
    while True:
        print('Running app...')

        # readiness and liveliness check
        ready_path = '/tmp/health/ready'
        live_path = '/tmp/health/alive'
        ready_file = None
        live_file = None
        try:
            if not isfile(ready_path):
                ready_file = open(ready_path, 'w')
                ready_file.write('Ready')

            if not isfile(live_path):
                live_file = open(live_path, 'w')
                live_file.write('Alive')
        except Exception as err:
            print('Error: %s' % str(err))
        finally:
            if ready_file is not None:
                ready_file.close()
            if live_file is not None:
                live_file.close()

        sleep(2)

if __name__ == '__main__':
    main()
