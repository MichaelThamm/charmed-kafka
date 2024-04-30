#!/bin/bash

VM_NAME="microstack"
CLOUD_INSTANCE_NAME="demo_node"

echo "Configuring microstack ..."

# Install openstack
multipass exec ${VM_NAME} -- sudo snap install openstack

# Prepare a machine
multipass exec ${VM_NAME} -- bash -c "sudo -i -u ubuntu sunbeam prepare-node-script | bash -x && newgrp snap_daemon < /dev/null"

# Bootstrap OpenStack
multipass exec ${VM_NAME} -- sunbeam cluster bootstrap --accept-defaults

# Configure OpenStack
multipass exec ${VM_NAME} -- sunbeam configure --accept-defaults --openrc demo-openrc

# Launch a cloud instance
multipass exec ${VM_NAME} -- sunbeam launch ubuntu -n ${CLOUD_INSTANCE_NAME}

# Transfer utility scripts into microstack
multipass transfer kafka-create.sh ${VM_NAME}:kafka-create.sh
multipass transfer kafka-config.sh ${VM_NAME}:kafka-config.sh
multipass transfer kafka-topics.sh ${VM_NAME}:kafka-topics.sh
multipass transfer data-integrator.sh ${VM_NAME}:data-integrator.sh
multipass transfer kafka-produce-consume.sh ${VM_NAME}:kafka-produce-consume.sh

# Create kafka
multipass exec ${VM_NAME} -- . kafka-create.sh

# Configure kafka
multipass exec ${VM_NAME} -- . kafka-config.sh

# Create kafka topics
multipass exec ${VM_NAME} -- . kafka-topics.sh

# Create the data-integrator (user management)
multipass exec ${VM_NAME} -- . data-integrator.sh

# Produce and consume messages
multipass exec ${VM_NAME} -- . kafka-produce-consume.sh