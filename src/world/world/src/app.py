from flask import Flask
from flask import request
from time import sleep
import os
# from opentelemetry import trace
# from opentelemetry.sdk.trace import TracerProvider
# from opentelemetry.sdk.trace.export import (
#     BatchSpanProcessor,
#     ConsoleSpanExporter,
# )
# from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
# from opentelemetry.sdk.resources import SERVICE_NAME, Resource
# from opentelemetry.sdk.trace import TracerProvider
# from opentelemetry.sdk.trace.export import BatchSpanProcessor
# from opentelemetry.trace.propagation.tracecontext import \
#     TraceContextTextMapPropagator

app = Flask(__name__)

# resource = Resource(attributes={
#       "service.name": "world",
#       "application": "doodle-tracer"
# })
# endpoint  = os.environ.get('OTEL_EXPORTER_OTLP_ENDPOINT', "localhost")

# provider = TracerProvider(resource=resource)
# processor = BatchSpanProcessor(OTLPSpanExporter(endpoint=endpoint))
# provider.add_span_processor(processor)
# trace.set_tracer_provider(provider)

# tracer = trace.get_tracer("hello-world.tracer")

@app.route("/")
def hello_world():
    shard = os.environ.get('SHARD', "na")
    print("SHARD: " + shard)
    # print("traceparent: " +  request.headers['traceparent'] )
    # carrier = {}
    # carrier.update({'traceparent': request.headers['traceparent'] })
    # ctx = TraceContextTextMapPropagator().extract(carrier=carrier)
    # print("carrier after extracting span context", carrier)
    # with tracer.start_as_current_span("return_world", context=ctx) as span:
    #     # do some work that 'span' will track
    #     # When the 'with' block goes out of scope, 'span' is closed for you
    #     print("do some work here...")
    #     sleep( 50 / 1000 )
    return "World (" + shard + ")" 

@app.route("/hash")
def get_hash():
    return "<p>1234</p>"