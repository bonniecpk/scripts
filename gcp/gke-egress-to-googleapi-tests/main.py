import os
import time
from flask import Flask, request, jsonify
from google.cloud import storage
from google.api_core.exceptions import GoogleAPIError

app = Flask(__name__)

@app.route("/", methods=["GET"])
def index():
    return jsonify({
        "service": "GCS Egress Routing Tester",
        "status": "running",
        "usage": "Send a GET request to /test-gcs?bucket=<your-bucket-name> to test GCS access."
    })

@app.route("/test-gcs", methods=["GET"])
def test_gcs():
    bucket_name = request.args.get("bucket")
    if not bucket_name:
        return jsonify({"error": "Please provide a 'bucket' query parameter"}), 400

    print(f"Testing GCS access for bucket: {bucket_name}", flush=True)
    start_time = time.time()
    try:
        # Initialize a GCS client
        client = storage.Client()
        
        # Retrieve the bucket reference
        bucket = client.bucket(bucket_name)
        
        # List blobs as a connectivity/read test (limit to 1 to be fast and lightweight)
        print(f"Attempting to list blobs for bucket: {bucket_name}", flush=True)
        blobs = list(client.list_blobs(bucket, max_results=1))
        print(f"Successfully listed blobs in bucket: {bucket_name}", flush=True)
        
        elapsed_time = time.time() - start_time

        msg = {
            "status": "success",
            "bucket": bucket_name,
            "elapsed_seconds": round(elapsed_time, 4),
            "blobs_found": len(blobs),
            "message": "Successfully connected to Google Cloud Storage API."
        }
        print("Success message: {}".format(msg), flush=True)
        return jsonify(msg)
    except GoogleAPIError as e:
        print(f"GoogleAPIError testing bucket {bucket_name}: {str(e)}", flush=True)
        elapsed_time = time.time() - start_time
        return jsonify({
            "status": "error",
            "bucket": bucket_name,
            "elapsed_seconds": round(elapsed_time, 4),
            "error_message": str(e)
        }), 500
    except Exception as e:
        print(f"Unexpected error testing bucket {bucket_name}: {str(e)}", flush=True)
        elapsed_time = time.time() - start_time
        return jsonify({
            "status": "error",
            "bucket": bucket_name,
            "elapsed_seconds": round(elapsed_time, 4),
            "error_message": f"Unexpected error: {str(e)}"
        }), 500

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8080))
    app.run(host="0.0.0.0", port=port)
