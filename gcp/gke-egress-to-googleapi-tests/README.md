# GKE Egress Testing: Google API Routing

This project contains a Python application (`main.py`) designed to test egress to Google Cloud Storage. It has been built and deployed to a GKE Autopilot cluster.

## Workload Identity Setup

To allow the application to access Google Cloud Storage, follow these steps to configure Workload Identity:

1.  **Create a Google Service Account (GSA)**:
    ```bash
    gcloud iam service-accounts create gcs-egress-tester-sa --display-name="GCS Egress Tester SA"
    ```

2.  **Grant IAM Roles to the GSA**:
    Grant the GSA permission to view objects in your bucket:
    ```bash
    gcloud projects add-iam-policy-binding <YOUR_PROJECT_ID> \
        --member="serviceAccount:gcs-egress-tester-sa@<YOUR_PROJECT_ID>.iam.gserviceaccount.com" \
        --role="roles/storage.objectViewer"
    ```

3.  **Allow Kubernetes Service Account (KSA) to Impersonate GSA**:
    Bind the KSA in the `default` namespace to the GSA:
    ```bash
    gcloud iam service-accounts add-iam-policy-binding gcs-egress-tester-sa@<YOUR_PROJECT_ID>.iam.gserviceaccount.com \
        --role="roles/iam.workloadIdentityUser" \
        --member="serviceAccount:<YOUR_PROJECT_ID>.svc.id.goog[default/gcs-egress-tester-sa]"
    ```

4.  **Update and Apply Kubernetes Manifest**:
    Ensure `k8s-manifest.yaml` includes the `ServiceAccount` with the proper annotation and the Deployment uses `serviceAccountName: gcs-egress-tester-sa`.
    ```bash
    kubectl apply -f k8s-manifest.yaml
    ```

## Deployment Steps

1.  **Manifest Update**: Updated `k8s-manifest.yaml` to point to the correct Artifact Registry image:
    `us-central1-docker.pkg.dev/<YOUR_PROJECT_ID>/repo-name/gcs-egress-tester:latest`
2.  **Container Build**: Built and pushed the Docker image using Google Cloud Build:
    ```bash
    gcloud builds submit --tag us-central1-docker.pkg.dev/<YOUR_PROJECT_ID>/repo-name/gcs-egress-tester:latest . --project <YOUR_PROJECT_ID>
    ```
    *Rationale: Cloud Build was used because the local environment lacked a Docker daemon.*
3.  **Cluster Configuration**: Configured `kubectl` to connect to the GKE Autopilot cluster:
    ```bash
    gcloud container clusters get-credentials autopilot-cluster-1 --region us-central1 --project <YOUR_PROJECT_ID>
    ```
4.  **Deployment**: Applied the Kubernetes manifests to the cluster:
    ```bash
    kubectl apply -f k8s-manifest.yaml
    ```

## Verification

1. **Check Pod and Service Status**:
   ```bash
   kubectl get pods
   kubectl get svc gcs-egress-tester-svc
   ```

2. **Test GCS Egress via Curl**:
   Once the service has an `EXTERNAL-IP`, you can test the connectivity to a specific GCS bucket:
   ```bash
   # Get the External IP
   EXTERNAL_IP=$(kubectl get svc gcs-egress-tester-svc -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

   # Test GCS access
   curl "http://${EXTERNAL_IP}/test-gcs?bucket=<YOUR_BUCKET_NAME>"
   ```

   **Expected Success Response**:
   ```json
   {
     "blobs_found": 1,
     "bucket": "<YOUR_BUCKET_NAME>",
     "elapsed_seconds": 0.1833,
     "message": "Successfully connected to Google Cloud Storage API.",
     "status": "success"
   }
   ```

   **Expected Permission Denied (403) Response**:
   If the IAM roles are not correctly applied, you will see a `403` error:
   ```json
   {
     "bucket": "<YOUR_BUCKET_NAME>",
     "error_message": "403 GET ...: Caller does not have storage.objects.list access...",
     "status": "error"
   }
   ```

Note: On GKE Autopilot, it may take a few minutes for pods to transition from `Pending` to `Running` as the cluster automatically provisions necessary compute resources.
