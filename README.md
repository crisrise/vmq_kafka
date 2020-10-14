# VerneMQ Kafka Plugin

vmq_kafka: a VerneMQ plugin that sends all published messages to Apache Kafka

## Prerequisites

1. You need to recompile vernemq with support to the brod OTP application: [Brod App](https://github.com/klarna/brod)
    * Modify the rebar.config file in the top directory of VerneMQ and add the brod application as dependancy
    * Example of a modified rebar.config is available here: [rebar.config.vernemq](external/rebar.config.vernemq)
2. In order to have the brod app loadad and configured along with VerneMQ server you need to:
    * Create your own version of [advanced.config](external/advanced.config) where you specify the Kafka host and port (default is localhost:9092)
    * Copy the file [advanced.config](external/advanced.config) in the VerneMQ config directory (same directoru as vernemq.conf)
3. Recompile VerneMQ as described in the [broker documentation](https://vernemq.com/downloads/index.html), in the section build from sources
---

## Configuration variables in vernemq.conf

We assume that the plugin is installed.

The plugin can be started at broker start by adding this line:

    plugins.vmq_kafka = on

The Brod App client (OTP service name) can be changed (needs to match the one in [advanced.config](external/advanced.config)):

    plugins.vmq_kafka.brod_client = my_brod_client_name

The number of partitions can be changed:

    plugins.vmq_kafka.num_partitions = 5

The Kafka topic where all the mqtt pubs are ingested can be changed:

    plugins.vmq_kafka.kafka_topic = my_kafka_topic
---

## Important notes:

0. There is a running Kafka development cluster with anonymous access (example [here](./compose/docker-compose.yml)) 
1. We assume that the configured Kafka topic exist with a number of partitions that matches num_partitions
2. Minumum for num_partitions is 1
3. If num_partitions is more than 1 the producers will send the message to a randomized partition in the interval [0, num_partitions-1]
4. The Kafka key value is now empty
5. The mqtt message is encoded in protobuf using this [schema](./proto/kafka_proto.proto) 
---

## Usage

You must have a recent version of Erlang/OTP installed (it's recommended to use the
same one VerneMQ is compiled with). To compile run:

    rebar3 compile

Then enable the plugin using:

    vmq-admin plugin enable --name vmq_kafka --path <PathToYourPlugin>/vmq_kafka/_build/default

The ``<PathToYourPlugin>`` should be accessible by VerneMQ (file permissions).

---

## Deploy in production

At the moment this plugin is in development stage and not ready for a production environment.
Please refer to VerneMQ [manual](https://docs.vernemq.com/plugindevelopment/introduction) on how to package the plugin for a production environment.

## 