from os.path import isfile
from time import sleep

def main():
    while True:
        print('Running app...')

        # readiness and liveliness check
        if not isfile('/var/www/ready'):
            ready_file = None
            try:
                ready_file = open('/var/www/ready', 'w')
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
