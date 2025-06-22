gcloud compute ssh control-plane --command="sudo bash /var/tmp/install-rhel-cp.sh"
gcloud compute ssh worker-node01 --command="sudo bash /var/tmp/install-rhel-worker.sh"
gcloud compute ssh worker-node02 --command="sudo bash /var/tmp/install-rhel-worker.sh"

kubeadm token create --print-join-command
