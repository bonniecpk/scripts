# Cloud Run Egress Testing: Google API Routing

This document outlines the steps to test and validate whether traffic from a Cloud Run service to Google APIs (e.g., GCS) stays within the Google network or egresses to the internet.

## Scenarios Tested
1.  **Default Egress**: Traffic goes through the Google-managed internet gateway.
2.  **Direct VPC Egress (Private IPs only)**: Only traffic to RFC 1918 ranges goes into the VPC; Google API traffic stays on the default internet path.
3.  **Direct VPC Egress (All Traffic)**: All egress traffic is forced into your VPC. This is where Private Google Access (PGA) becomes critical.

---

## 1. Prerequisites
*   **VPC & Subnet**: A VPC with a subnet in the same region as your Cloud Run service.
*   **PGA**: Private Google Access toggled on/off on the subnet for specific test cases.
*   **Artifact Registry**: Image built and pushed (e.g., `us-central1-docker.pkg.dev/[PROJECT_ID]/repo-name/gcs-egress-tester:latest`).

---

## 2. IAM Configuration

To ensure the service can access GCS, Artifact Registry, and utilize Direct VPC Egress, the following permissions are required.

### Runtime Service Account
This is the identity assigned to the Cloud Run service (e.g., `YOUR_SERVICE_ACCOUNT@[PROJECT_ID].iam.gserviceaccount.com`).
*   **Storage Object Viewer (`roles/storage.objectViewer`)**: Required to list and read objects in the test bucket.
*   **Artifact Registry Writer (`roles/artifactregistry.writer`)**: Required to push or manage images in the repository.
*   **Logs Writer (`roles/logging.logWriter`)**: Standard permission for writing logs to Cloud Logging.

```bash
# Example assignment
gcloud projects add-iam-policy-binding [PROJECT_ID] \
  --member="serviceAccount:YOUR_SERVICE_ACCOUNT@[PROJECT_ID].iam.gserviceaccount.com" \
  --role="roles/storage.objectViewer"

gcloud projects add-iam-policy-binding [PROJECT_ID] \
  --member="serviceAccount:YOUR_SERVICE_ACCOUNT@[PROJECT_ID].iam.gserviceaccount.com" \
  --role="roles/artifactregistry.writer"
```

---

## 3. Deployment Commands

### A. Default Egress (No VPC)
```bash
gcloud run deploy egress-test-default \
  --image us-central1-docker.pkg.dev/[PROJECT_ID]/repo-name/gcs-egress-tester:latest \
  --region us-central1 \
  --allow-unauthenticated
```

### B. Direct VPC Egress (Private Ranges Only)
```bash
gcloud run deploy egress-test-private-only \
  --image us-central1-docker.pkg.dev/[PROJECT_ID]/repo-name/gcs-egress-tester:latest \
  --network=YOUR_VPC_NAME \
  --subnet=YOUR_SUBNET_NAME \
  --vpc-egress=private-ranges-only \
  --region us-central1
```

### C. Direct VPC Egress (All Traffic)
*Note: If PGA is OFF and you have no Cloud NAT, this test will likely fail for GCS access.*
```bash
gcloud run deploy egress-test-all-traffic \
  --image us-central1-docker.pkg.dev/[PROJECT_ID]/repo-name/gcs-egress-tester:latest \
  --network=YOUR_VPC_NAME \
  --subnet=YOUR_SUBNET_NAME \
  --vpc-egress=all-traffic \
  --region us-central1
```

---

## 4. Verification Methods

### Method 1: Internal Connectivity (Custom VM)
This method tests the path from within the same VPC.
1.  **Setup**: Create a VM in the same VPC with **no external IP**.
2.  **Access**: Connect via IAP SSH tunneling.
3.  **Test**: `curl "[SERVICE_URL]/test-gcs?bucket=[YOUR_BUCKET]"`

> **⚠️ Critical Troubleshooting Note (Private VMs & IAP):**
> If your testing VM has no external IP, it depends on **Private Google Access (PGA)** to reach Google APIs (including the Cloud Run endpoint).
> *   **False Failure**: If you turn off PGA on the subnet, the `curl` from the VM to Cloud Run will fail because the VM loses its path to the service. This is an *ingress* failure to the service, not an *egress* failure from it.
> *   **Isolation**: To test Cloud Run egress while PGA is off, use Method 2 (Flow Logs) or Method 3 (Internet).

### Method 2: VPC Flow Logs (TBD to be verified)
To prove traffic is traversing your VPC subnetwork:
1.  **Enable Flow Logs** on the subnet (Aggregation interval: 5s).
2.  **Query Logs Explorer**:
    ```kql
    resource.type="gce_subnetwork"
    log_name:"projects/[PROJECT_ID]/logs/compute.googleapis.com%2Fvpc_flows"
    jsonPayload.connection.src_ip ~ "10.x.x.x"  # Your Subnet Range
    ```
3.  **Observation**: If PGA is ON and Egress is "All Traffic", you will see GCS-bound traffic (Destination IPs in the `142.250.x.x` range) appearing in your VPC flow logs.

### Method 3: Public Internet Testing (Laptop)
Expose Cloud Run to the internet to test connectivity directly from your local machine.
1.  **Expose**: Ensure the service is deployed with `--allow-unauthenticated`.
2.  **Test**: Call the URL from your laptop's terminal:
    ```bash
    curl "[SERVICE_URL]/test-gcs?bucket=[YOUR_BUCKET]"
    ```
3.  **Purpose**: Use this to confirm the application logic and GCS permissions are correct "at baseline" before introducing VPC egress complexity.

---

## 5. Observations & Results
| Scenario | PGA Status | Egress Setting | Expected Path | Result |
| :--- | :--- | :--- | :--- | :--- |
| Default | N/A | N/A | Internal (Google Managed) | Success |
| Direct VPC | Off | private-ranges-only | Internal (Google Managed) | Success |
| Direct VPC | On | all-traffic | **Internal (VPC -> Google Network)** | Success |
| Direct VPC | Off | all-traffic | **VPC -> Blackhole/NAT** | Fail (unless NAT exists) |
