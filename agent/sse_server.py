from fastmcp import FastMCP

mcp = FastMCP("Cloud-GKE-Tool")

@mcp.tool()
def fetch_logs(cluster_name: str) -> str:
    return f"Logs for {cluster_name}: [System Healthy]"

# Instead of mcp.run(), we use 'mcp.run("sse")' for web transport
if __name__ == "__main__":
    mcp.run(transport="sse")