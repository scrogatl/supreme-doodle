import requests
import os
import time
from datetime import datetime
import sys


def loadgen():
    front_end = os.environ.get('FRONTEND_HOST', "localhost")
    print("FRONTEND_HOST: " + front_end)
    
    while (True):
        timeString = datetime.now().strftime("%H:%M:%S.%f")[:-3]
        try:
            res = requests.get('http://' + front_end + ':5000')
            print(timeString + " - Status: " + str(res.status_code) + " - " + res.text)
        except:
            print(timeString + " - Status: " + str(res.status_code))
        time.sleep(1)


def main() -> int:
    loadgen()
    return 0

if __name__ == '__main__':
    sys.exit(main())  # next section explains the use of sys.exit


