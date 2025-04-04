## GitHub Issues Service

Serviço para recuperação de issues e contribuidores de repositórios GitHub, com processamento assíncrono e notificação via webhook.
Funcionalidades

    Recupera issues de um repositório GitHub
    Recupera lista de contribuidores
    Processa dados de forma assíncrona (24h de delay)*
    Envia resultados via webhook

Requisitos

    Elixir 1.14+
    Phoenix 1.7+

Instalação

# Clone o repositório
    git clone https://github.com/seu-usuario/github_issues_service

    cd github_issues_service

# Configure o ambiente
    cp .env.example .env

# Configure o webhook URL no arquivo .env
    WEBHOOK_URL=https://webhook.site/seu-endpoint-aqui

# Instale as dependências
    mix deps.get

# Execute os testes
    mix test

# Inicie o servidor
    mix phx.server

Uso da API
Endpoint

POST /api/repositories

Exemplos de Chamadas

# Requisição básica
    curl -X POST http://localhost:4000/api/repositories \
      -H "Content-Type: application/json" \
      -d '{
        "user": "elixir-lang",
        "repository": "elixir"
      }'

# Com repositório completo do GitHub
    curl -X POST http://localhost:4000/api/repositories \
      -H "Content-Type: application/json" \
      -d '{
        "user": "elixir-lang",
        "repository": "https://github.com/elixir-lang/elixir"
      }'

Insomnia

    Crie uma nova requisição POST
    URL: http://localhost:4000/api/repositories
    Headers:
        Content-Type: application/json
    Body (JSON):

    {
      "user": "phoenixframework",
      "repository": "phoenix"
    }
    
    Respostas
    Sucesso (202 Accepted)
    
    {
      "message": "Request accepted, webhook will be sent in 24 hours",
      "details": {
        "user": "phoenixframework",
        "repository": "phoenix"
      }
    }

Erro - Repositório não encontrado (404)

    {
      "error": "Repository not found",
      "details": [
        "Please ensure that:",
        "1. The repository exists",
        "2. The repository is public",
        "3. The user name is correct",
        "4. The repository name is correct"
      ]
    }

Webhook Payload

O serviço enviará o seguinte payload para o webhook configurado após 24 horas:

    {
      "user": "phoenixframework",
      "repository": "phoenix",
      "issues": [
        {
          "title": "Issue Title",
          "author": "username",
          "labels": ["bug", "feature"]
        }
      ],
      "contributors": [
        {
          "name": "Contributor Name",
          "user": "username",
          "qtd_commits": 123
        }
      ]
    }

Configuração do Webhook

1. Obtenha uma URL de webhook:
   - Acesse https://webhook.site/
   - Copie a URL fornecida

2. Configure o webhook:
   ```bash
   # Copie o arquivo de exemplo
   cp .env.example .env
   
   # Edite o arquivo .env e adicione sua URL do webhook
   WEBHOOK_URL=https://webhook.site/sua-url-aqui

Testes

# Executa todos os testes
    mix test

# Executa testes com cobertura
    mix test --cover

# Análise estática
    mix dialyzer
ps.: o processamento assíncrono está configurado para enviar o webhook imediatamente para teste, vide função:
      ```GithubIssuesService.Repositories.Repository.fetch_repository_data```
      
Contribuição

    Fork o projeto
    Crie sua feature branch (git checkout -b feature/nova-feature)
    Commit suas mudanças (git commit -m 'Adiciona nova feature')
    Push para a branch (git push origin feature/nova-feature)
    Abra um Pull Request

Licença

MIT
