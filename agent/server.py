from fastmcp import FastMCP
import json

# Initialize the MCP server
mcp = FastMCP("GKE-Inventory-Server")

@mcp.tool()
def get_cluster_status(project_id: str) -> dict:
    """
    Fetches GKE cluster status for a given project.
    Returns a raw dictionary (JSON) of cluster metadata.
    """
    # In a real GCP environment, you would use the google-cloud-container library here.
    # For this example, we return structured JSON data directly.
    mock_data = {
        "project": project_id,
        "clusters": [
            {"name": "prod-cluster-01", "status": "RUNNING", "version": "1.27.3-gke.100"},
            {"name": "staging-cluster-01", "status": "RECONCILING", "version": "1.26.5-gke.200"}
        ],
        "region": "us-central1"
    }
    
    # We return the dict; FastMCP handles the conversion to a JSON string for transport.
    return mock_data

if __name__ == "__main__":
    mcp.run(transport="stdio")