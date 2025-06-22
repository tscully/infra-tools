gcloud compute scp install-cp.sh control-plane:/var/tmp
gcloud compute scp kube-ps1.sh control-plane:/var/tmp
gcloud compute scp install-worker.sh  worker-node01:/var/tmp
gcloud compute scp install-worker.sh  worker-node02:/var/tmp
