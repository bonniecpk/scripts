import asyncio
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client
import json

async def run_inventory_ingestion():
    # Configure the client to talk to the server script
    server_params = StdioServerParameters(
        command="python",
        args=["server.py"],
    )

    async with stdio_client(server_params) as (read, write):
        async with ClientSession(read, write) as session:
            # 1. Standard MCP Handshake
            await session.initialize()

            # 2. Call the tool directly
            # We provide the project_id argument as required by the server's tool
            print("Requesting JSON data from MCP Server...")
            result = await session.call_tool(
                "get_cluster_status", 
                arguments={"project_id": "my-gcp-project-123"}
            )

            # 3. Extract and Parse the JSON Result
            # result.content[0].text contains the returned string from the server
            raw_data_string = result.content[0].text
            json_data = json.loads(raw_data_string)

            # 4. Ingest the data (e.g., print or save to DB)
            print(f"\nSuccessfully Ingested Data for Project: {json_data['project']}")
            for cluster in json_data['clusters']:
                print(f" - Cluster: {cluster['name']} | Status: {cluster['status']}")

if __name__ == "__main__":
    asyncio.run(run_inventory_ingestion())