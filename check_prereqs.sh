#!/bin/bash

export REQUIRED_CPUS=8

# Check if Kubernetes is enabled and running in Docker Desktop
if ! command -v kubectl &> /dev/null; then
    echo "kubectl is not installed"
    exit 1
fi

contexts=$(kubectl config get-contexts -o name)

# Check if the contexts variable is empty. If it is, kubectl might not be installed
# or there are no contexts configured.
if [ -z "$contexts" ]; then
    echo "No kubectl contexts found. Please ensure 'kubectl' is installed and configured correctly."
    exit 1
fi

# Convert the newline-separated string of contexts into a bash array for easier manipulation.
# This method uses a while loop and is more portable across different systems, including macOS,
# which may not have the `readarray` command.
context_array=()
while IFS= read -r line; do
    context_array+=("$line")
done <<< "$contexts"

# --- Display the contexts to the user ---
echo "--- Available Kubectl Contexts ---"

# Loop through the array and print each context with a number.
# We start the index at 1 for user readability.
for i in "${!context_array[@]}"; do
    # Get the current context and mark it with an asterisk for easy identification.
    current_context=$(kubectl config current-context)
    display_name="${context_array[$i]}"
    
    if [ "$display_name" == "$current_context" ]; then
        echo "$((i+1)). $display_name (current)"
    else
        echo "$((i+1)). $display_name"
    fi
done

# --- Prompt the user for a selection ---
current_context=$(kubectl config current-context)
echo
echo "Enter the number of the context you want to use to install the confluent-demo, or 'q' to quit."
echo "Press Enter to use the current context ($current_context)."
read -p "Your selection: " selection

# --- Handle user input ---
# If the user enters 'q' or 'Q', we exit the script.
if [[ "$selection" =~ ^[qQ]$ ]]; then
    echo "Exiting."
    exit 0
fi

# If the user pressed enter without input, use the current context
if [[ -z "$selection" ]]; then
    selected_context="$current_context"
    echo "Using current context: $selected_context"
else
    # Check if the input is a valid number.
    if ! [[ "$selection" =~ ^[0-9]+$ ]]; then
        echo "Invalid selection. Please enter a number."
        exit 1
    fi

    # Convert the user's input to a 0-based index for the array.
    index=$((selection-1))

    # Check if the index is within the valid range of the array.
    if (( index < 0 || index >= ${#context_array[@]} )); then
        echo "Invalid number. Please enter a number from 1 to ${#context_array[@]}."
        exit 1
    fi

    # --- Switch to the selected context ---
    selected_context="${context_array[$index]}"

    # Only switch if it's different from the current context
    if [ "$selected_context" != "$current_context" ]; then
        echo "Switching to context: $selected_context"

        # Use 'kubectl config use-context' to perform the switch.
        # The output of this command is captured in a variable and then printed.
        switch_output=$(kubectl config use-context "$selected_context")
        echo "$switch_output"

        # Verify that the switch was successful and display the new current context.
        new_current_context=$(kubectl config current-context)
        echo
        echo "Switched successfully. The new current context is: $new_current_context"
    else
        echo "Already using the selected context: $selected_context"
    fi
fi

echo "Checking kubectl connectivity"
if ! kubectl cluster-info &> /dev/null; then
    echo "kubectl is not working. Please check your kubectl configuration."
    exit 1
fi


ALLOCATED_CPUS=$(kubectl get nodes -ojson | jq '[.items[].status.allocatable.cpu | tonumber] | add')

echo "Allocated CPUs: $ALLOCATED_CPUS"

if (( ALLOCATED_CPUS < REQUIRED_CPUS )); then
    echo "Not enough CPUs allocated. Please consider allocating at least ${REQUIRED_CPUS} CPUs."
fi


echo "Checking if keytool is installed"
if ! command -v keytool &> /dev/null; then
    echo "keytool is not installed; try installing a Java runtime (JRE or JDK)"
    exit 1
fi

echo "Checking if helm is installed"
if ! command -v helm &> /dev/null; then
    echo "helm is not installed"
    exit 1
fi

echo "Check if openssl is installed"
if ! command -v openssl &> /dev/null; then
    echo "openssl is not installed"
    exit 1
fi

echo "Check if cfssl is installed"
if ! command -v cfssl &> /dev/null; then
    echo "cfssl is not installed"
    exit 1
fi

echo "Setting up base domain"
echo "The Ingress NGINX controller will be configured to exposed services running on Kubernetes"
echo "If Kubernetes is running locally (e.g., Docker Desktop or OrbStack), ingress-exposed services can be accessed at the IP address of the host machine (127.0.0.1)"
echo "If Kubernetes is running on a remote machine, enter the IP address of the machine"
echo "Press Enter to use the current IP (127.0.0.1)"
read -p "Your selection: " BASE_IP

if [[ -z "$BASE_IP" ]]; then
    BASE_IP="127.0.0.1"
fi

export BASE_IP

# Super simple validation
if [[ "$BASE_IP" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    echo "Using IP ${BASE_IP}"
    export BASE_DOMAIN="$(echo ${BASE_IP} | tr '.' '-').nip.io"
    echo "Setting BASE_DOMAIN in ./.env to ${BASE_DOMAIN}"
    sed -i.bak "s|^export BASE_DOMAIN=.*$|export BASE_DOMAIN=${BASE_DOMAIN}|g" ./.env
else
    echo "${BASE_IP} is not a valid IP"
fi

echo ""
echo "--- Prerequisites ---"

# If we get here, everything is working
echo "✅ Kubernetes is enabled and accessible using context: ${selected_context}"
if (( ALLOCATED_CPUS < REQUIRED_CPUS )); then
    echo "❌ Kubernetes cluster may have insufficient allocatable CPUs (${ALLOCATED_CPUS})"
else
    echo "✅ Kubernetes cluster has enough allocatable CPUs (${ALLOCATED_CPUS})"
fi
echo "✅ keytool is installed"
echo "✅ helm is installed"
echo "✅ openssl is installed"
echo "✅ cfssl is installed"
echo "✅ BASE_DOMAIN is set to ${BASE_DOMAIN}"
echo ""
echo "Confluent Control Center will be accessible at https://controlcenter.${BASE_DOMAIN}"