gcloud compute scp install-rhel-cp.sh control-plane:/var/tmp
gcloud compute scp kube-ps1.sh control-plane:/var/tmp
gcloud compute scp install-rhel-worker.sh  worker-node01:/var/tmp
#gcloud compute scp install-worker.sh  worker-node02:/var/tmp
