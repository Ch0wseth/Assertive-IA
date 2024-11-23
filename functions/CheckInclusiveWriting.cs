using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Microsoft.Azure.Functions.Worker.Http;
using Newtonsoft.Json;
using Azure;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;

namespace Chowseth.AssertiveAI
{
    public class CheckInclusiveWriting
    {
        private readonly ILogger<CheckInclusiveWriting> _logger;
        private static readonly HttpClient client = new HttpClient();

        public CheckInclusiveWriting(ILogger<CheckInclusiveWriting> logger)
        {
            _logger = logger;
        }

        [Function("CheckInclusiveWriting")]
        public async Task<HttpResponseData> Run(
            [HttpTrigger(AuthorizationLevel.Function, "post")] HttpRequestData req,
            FunctionContext executionContext)
        {
            var logger = executionContext.GetLogger("CheckInclusiveWriting");
            logger.LogInformation("C# HTTP trigger function processed a request.");

            // Lire le corps de la requête
            string requestBody = await req.ReadAsStringAsync();
            dynamic data = JsonConvert.DeserializeObject(requestBody);
            string text = data?.text;

            if (string.IsNullOrEmpty(text))
            {
                var badRequestResponse = req.CreateResponse(System.Net.HttpStatusCode.BadRequest);
                await badRequestResponse.WriteStringAsync("Text is required.");
                return badRequestResponse;
            }

            // Appeler GPT-4 via Azure OpenAI pour reformuler le texte en écriture inclusive
            string inclusiveText = await GenerateInclusiveTextAsync(text);

            // Créer une réponse avec le texte transformé
            var response = req.CreateResponse(System.Net.HttpStatusCode.OK);
            await response.WriteStringAsync($"{inclusiveText}");

            return response;
        }

        // Fonction pour appeler l'API Azure OpenAI GPT-4
        private async Task<string> GenerateInclusiveTextAsync(string text)
        {
            string apiUrl = "OPENAPI_ENDPOINT";
            string apiKey = "KEY";

            // Créer la charge utile (payload) pour la requête
            var requestContent = new
            {
                model = "gpt-4",
                messages = new object[]
                {
                    new { role = "system",
                        content = "Transforme le texte suivant en écriture inclusive. N'hésite pas à utiliser des tournure passive et neutre, etc et pas que les points médians. Mets a la fin un score d'inclusivité à mon texte de base avec les différents points non inclusifs." },
                    new { role = "user", content = text }
                },
                temperature = 0.7,
                max_tokens = 1000
            };

            var content = new StringContent(JsonConvert.SerializeObject(requestContent), Encoding.UTF8, "application/json");

            // Ajouter l'API Key dans l'en-tête
            client.DefaultRequestHeaders.Add("api-key", apiKey);

            // Envoyer la requête POST à l'API OpenAI GPT-4
            HttpResponseMessage response = await client.PostAsync(apiUrl, content);

            // Vérifier la réponse
            if (!response.IsSuccessStatusCode)
            {
                string errorResponse = await response.Content.ReadAsStringAsync();
                throw new Exception($"API call failed with status code {response.StatusCode}. Error: {errorResponse}");
            }

            // Lire la réponse et retourner le texte transformé
            string responseContent = await response.Content.ReadAsStringAsync();
            dynamic result = JsonConvert.DeserializeObject(responseContent);
            return result.choices[0].message.content.ToString().Trim(); // Retourne le texte transformé
        }
    }
}