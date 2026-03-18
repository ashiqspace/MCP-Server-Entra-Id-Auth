# MCP Server with Azure Entra ID Authentication

An MCP (Model Context Protocol) Server built with ASP.NET Core that provides secure, authenticated access to AI tools using Azure Entra ID (Azure AD) for authentication.

## Overview

This project demonstrates a production-ready MCP server with:
- **Azure Entra ID Authentication**: Secure token-based authentication using JWT Bearer tokens
- **Authorization Middleware**: All endpoints require authenticated users
- **Chuck Norris Joke Tool**: A sample tool that fetches random Chuck Norris jokes via API
- **HTTP Transport**: MCP-compliant HTTP transport layer for tool invocation

## Tools

### Chuck Norris Joke Tool

**Name**: `chuckNorrisJoke`

Fetches a random Chuck Norris joke from the public Chuck Norris API (https://api.chucknorris.io/jokes/random).

**Usage**:
- No parameters required
- Returns a string containing a random Chuck Norris joke
- Handles API failures gracefully with fallback messages

## Security Architecture

The security model is implemented in `Program.cs` and includes:

### 1. **Azure Entra ID Authentication**
```csharp
builder.Services
    .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddMicrosoftIdentityWebApi(azureAdConfig);
```
- Validates JWT Bearer tokens issued by Azure Entra ID
- Configuration from `appsettings.json` AzureAd section

### 2. **Authorization Policies**
```csharp
builder.Services.AddAuthorization(options =>
{
    options.FallbackPolicy = new AuthorizationPolicyBuilder()
        .RequireAuthenticatedUser()
        .Build();
});
```
- All endpoints require authenticated users by default
- No anonymous access allowed

### 3. **MCP Endpoint Protection**
```csharp
app.MapMcp("/mcp").RequireAuthorization();
app.MapMcp("/").RequireAuthorization();
```
- Both `/mcp` and `/` endpoints require authentication
- Invalid or missing tokens will return 401 Unauthorized

## Setup Instructions

### Prerequisites
- .NET 8.0 SDK
- An Azure subscription
- An Azure Entra ID application registration

### Step 1: Create Azure Entra ID App Registration

1. Go to [Azure Portal](https://portal.azure.com)
2. Navigate to **Azure Entra ID** → **App registrations** → **New registration**
3. Register your application:
   - Name: `MCP-Server-Entra-Id-Auth`
   - Supported account types: Choose based on your needs
4. Copy the following values:
   - **Application (client) ID** → Use as `ClientId`
   - **Directory (tenant) ID** → Use as `TenantId`

### Step 2: Configure appsettings.json

1. Open `appsettings.json` in the project root
2. Replace the dummy values in the `AzureAd` section with your actual Azure values:

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "AzureAd": {
    "Instance": "https://login.microsoftonline.com/",
    "TenantId": "YOUR_TENANT_ID",
    "ClientId": "YOUR_CLIENT_ID",
    "Audience": "api://YOUR_CLIENT_ID"
  }
}
```

**Configuration Fields**:
- `Instance`: Azure Entra ID login endpoint (keep as is for public cloud)
- `TenantId`: Your Azure AD directory ID
- `ClientId`: Your application's client ID
- `Audience`: The API identifier for your application (format: `api://CLIENT_ID`)

### Step 3: Install Dependencies

```bash
dotnet restore
```

### Step 4: Run the Server

```bash
dotnet run
```

**Output**:
```
info: Microsoft.Hosting.Lifetime[14]
      Now listening on: http://localhost:5096
```

The server will start on `http://localhost:5096`

## Port Forwarding & Public Access

### Local Development
- MCP endpoints available at: `http://localhost:5096/mcp` and `http://localhost:5096/`

### Remote Access / Port Forwarding

If running on a remote machine or container:

#### Using SSH Tunneling (Local Machine)
```bash
ssh -L 5096:localhost:5096 user@remote-host
```
Then access at: `http://localhost:5096/mcp`

#### Using ngrok (Quick Public URL)
```bash
ngrok http 5096
```
This provides a public HTTPS URL forward to your local server.

#### Using Azure App Service
Deploy this as an Azure Web App for automatic HTTPS and public URL:
```bash
dotnet publish -c Release
# Deploy the publish folder to Azure App Service
```

#### Docker Deployment
```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app
COPY . .
RUN dotnet publish -c Release -o out

FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app/out .
EXPOSE 5096
ENTRYPOINT ["dotnet", "MCPServer-EntraId.dll"]
```

```bash
docker build -t mcp-server .
docker run -p 5096:5096 -e ASPNETCORE_URLS=http://+:5096 mcp-server
```

## API Usage

### Authentication

All requests must include a valid JWT Bearer token from Azure Entra ID:

```bash
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  http://localhost:5096/mcp
```

**Getting a Token**:
```bash
# Using Azure CLI
az account get-access-token --resource "api://YOUR_CLIENT_ID"
```

### Calling Tools

Example request to call the Chuck Norris joke tool:
```bash
curl -X POST \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"tool": "chuckNorrisJoke"}' \
  http://localhost:5096/mcp
```

## Project Structure

```
├── src/
│   ├── Program.cs                 # Application setup & security config
│   ├── Tools/
│   │   └── ChuckNorrisTool.cs     # Chuck Norris joke tool implementation
│   ├── Services/                  # Additional services (if any)
│   └── web.config                 # IIS configuration
├── appsettings.json               # Azure AD configuration
├── MCPServer-EntraId.csproj       # Project file
└── README.md                      # This file
```

## Dependencies

- **ModelContextProtocol.AspNetCore** (0.4.0-preview.3): MCP server implementation
- **Microsoft.Identity.Web** (2.16.0): Azure Entra ID integration
- **Microsoft.AspNetCore.Authentication.JwtBearer** (8.0.2): JWT Bearer authentication

## Troubleshooting

### 401 Unauthorized Error
- Verify your JWT token is valid and not expired
- Check that `TenantId` and `ClientId` match your Azure AD app registration
- Ensure the token audience matches the `Audience` in appsettings.json

### Connection Refused
- Verify the server is running on the expected port
- Check firewall/network ACLs if accessing remotely

### Token Generation Issues
- Ensure you've added API permissions in your Azure AD app registration
- Check that your app registration is configured as a web API

## Contributing

Feel free to extend this MCP server with additional tools.

## License

MIT

## Support

For issues or questions, please open a GitHub issue.
