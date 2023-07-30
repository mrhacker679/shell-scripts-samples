#!/bin/bash

# Function to check if a server is reachable
function check_server_reachable() {
    host=$1
    if ping -c 1 "$host" &>/dev/null; then
        echo "Server $host is reachable."
    else
        echo "Server $host is not reachable."
    fi
}

# Function to check if a TCP port is open on a server
function check_port_open() {
    host=$1
    port=$2
    if nc -z "$host" "$port" &>/dev/null; then
        echo "Port $port on $host is open."
    else
        echo "Port $port on $host is closed."
    fi
}

# Check Jenkins Slave
jenkins_slave_host="jenkins-slave-hostname-or-ip"
check_server_reachable "$jenkins_slave_host"

# Check SonarQube Server
sonarqube_host="sonarqube-server-hostname-or-ip"
sonarqube_port=9000  # Change this to the actual port used by SonarQube
check_server_reachable "$sonarqube_host"
check_port_open "$sonarqube_host" "$sonarqube_port"

# Check Kubernetes Cluster
kubectl_cmd="kubectl"  # If kubectl is in a different path or you are using a wrapper script, update this accordingly
if ! command -v "$kubectl_cmd" &>/dev/null; then
    echo "kubectl command not found. Make sure it's installed and in the system PATH."
    exit 1
fi

# Check if kubectl can access the cluster
if "$kubectl_cmd" cluster-info &>/dev/null; then
    echo "Kubernetes cluster is reachable."
else
    echo "Kubernetes cluster is not reachable."
fi

# Check status of nodes and pods in the cluster
echo "Node status:"
"$kubectl_cmd" get nodes

echo "Pod status:"
"$kubectl_cmd" get pods --all-namespaces
