using System.ComponentModel;
using System.Text.Json;
using ModelContextProtocol.Server;

namespace EchoMcpServer.Tools;

[McpServerToolType]
public class ChuckNorrisJokeTool
{
    private readonly HttpClient _httpClient = new();

    /// <summary>
    /// Fetches a random Chuck Norris joke from the Chuck Norris API
    /// </summary>
    [McpServerTool(Name = "chuckNorrisJoke")]
    [Description("Fetches a random Chuck Norris joke from the Chuck Norris API")]
    public async Task<string> GetChuckNorrisJoke()
    {
        try
        {
            var response = await _httpClient.GetAsync("https://api.chucknorris.io/jokes/random");
            var content = await response.Content.ReadAsStringAsync();
            var json = JsonDocument.Parse(content);
            var joke = json.RootElement.GetProperty("value").GetString();
            return joke ?? "Could not fetch joke";
        }
        catch
        {
            return "Failed to fetch Chuck Norris joke";
        }
    }
}
