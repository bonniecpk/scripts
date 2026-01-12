import asyncio
from mcp import ClientSession
from mcp.client.sse import sse_client

async def run_remote_task():
    # Connect to the remote MCP server URL
    async with sse_client("http://localhost:8000/sse") as (read, write):
        async with ClientSession(read, write) as session:
            await session.initialize()
            
            # Call the tool over the internet/network
            result = await session.call_tool("fetch_logs", {"cluster_name": "prod-1"})
            print(result.content[0].text)

if __name__ == "__main__":
    asyncio.run(run_remote_task())