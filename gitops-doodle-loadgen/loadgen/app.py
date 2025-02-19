import requests
import os
import time
from datetime import datetime
import sys


def loadgen():
    front_end = os.environ.get('FRONTEND_HOST', "localhost")
    sleep_time = os.environ.get('SLEEP_TIME', "5000")
    print("FRONTEND_HOST: " + front_end)
    print("SLEEP_TIME: " + sleep_time)
    
    while (True):
        timeString = datetime.now().strftime("%H:%M:%S.%f")[:-3]
        try:
            res = requests.get('http://' + front_end + ':5000', timeout=.5)
            print(timeString + " - [loadgen] - Status: " + str(res.status_code) + " - " + res.text )
        except Exception as e:
            print(timeString + " - [loadgen] - Status: " + repr(e))
        time.sleep( int(sleep_time) / 1000 )

if __name__ == '__main__':
    sys.exit(loadgen())  