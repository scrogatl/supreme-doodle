from flask import Flask
import requests
from flask import request
import os
from datetime import datetime
from time import sleep
import os

# from opentelemetry import trace
# from opentelemetry.sdk.trace import TracerProvider
# from opentelemetry.sdk.trace.export import BatchSpanProcessor                                        
# from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
# from opentelemetry.trace.propagation.tracecontext import \
#     TraceContextTextMapPropagator
# from opentelemetry.sdk.resources import SERVICE_NAME, Resource


app = Flask(__name__)

helloHost = os.environ.get('HELLO_HOST', "localhost")
worldHost = os.environ.get('WORLD_HOST', "localhost")
endpoint  = os.environ.get('OTEL_EXPORTER_OTLP_ENDPOINT', "localhost")
shard = os.environ.get('SHARD', "na")
print(" [frontend: " + shard + "] - " + " initialized]")

# Service name is required for most backends
# resource = Resource(attributes={
#       "service.name": "frontend",
#       "application": "doodle-tracer"
#     })
# provider = TracerProvider(resource=resource)
# processor = BatchSpanProcessor(OTLPSpanExporter(endpoint=endpoint))
# provider.add_span_processor(processor)
# trace.set_tracer_provider(provider)
# tracer = trace.get_tracer_provider().get_tracer("hello-world.tracer")


@app.route("/")
def front_end():
    timeString = datetime.now().strftime("%H:%M:%S.%f")[:-3]
    resLocal = timeString 
    # with tracer.start_as_current_span("frontend_customer_query") as span:
    #     prop = TraceContextTextMapPropagator()
    #     carrier = {}
    #     prop.inject(carrier=carrier)
    #     print("Carrier after injecting span context", carrier)
    #     headers = carrier
    res = " - [frontend: " + shard + " - hello host: " + helloHost + " ]"
    try:
        resH = requests.get('http://' + helloHost + ':5001')
        if resH.status_code >= 300:
            # res += " hello status: " + str(resH.status_code) + " - " + resH.text + " - " + str(resH.headers)
            res += " hello status: " + str(resH.status_code) + " - " + resH.text 
        else:
            res += " hello status: " + str(resH.status_code) + " - " + resH.text 
    except Exception as e:
        res += " hello status: " + repr(e)

    try: 
        resW = requests.get('http://' + worldHost + ':5002')
        if resW.status_code >= 300:
            res += " | world status: " + str(resW.status_code) + " - " + resW.text + " - " + " | worldHost: " + worldHost
            # res += " | world status: " + str(resW.status_code) + " - " + resW.text + " - " + " | worldHost: " + worldHost + " | " + str(resW.headers)
        else:
            res += " | world status: " + str(resW.status_code) + " - " + resW.text 
    except Exception as e:
        res += " world status:" + repr(e)


    print (resLocal + res)
    # print("Hello status: " + str(resH.status_code))
    # print("Hello text: " + resH.text)
    # print("World status: " + str(resW.status_code))
    # print("World text: " + resW.text)
    return res

@app.route("/hash")
def get_hash():
    return "<p>1234</p>"

