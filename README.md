# Email Parser

Aplicação com Ruby 3.4.3 e Rails 8.0.3 para processar e extrair dados de arquivos .eml, persistir clientes e manter logs com status e detalhes de execução. Filas de background são processadas com Sidekiq e Redis.

- Jobs: [`EmailProcessor::BulkProcessJob`](app/jobs/email_processor/bulk_process_job.rb) e [`EmailProcessor::ProcessJob`](app/jobs/email_processor/process_job.rb)
- Rotas e UI:
  - Upload de .eml: [`ProcessorsController`](app/controllers/processors_controller.rb) (root em `/`)
  - Clientes: [`CustomersController`](app/controllers/customers_controller.rb) em `/customers`
  - Logs: [`LogsController`](app/controllers/logs_controller.rb) em `/logs`
  - Sidekiq Web UI: `/sidekiq` (montado em [`config/routes.rb`](config/routes.rb))
- Models: [`Customer`](app/models/customer.rb), [`Log`](app/models/log.rb)
- Adapter de Jobs em dev: Sidekiq (ver [`config/environments/development.rb`](config/environments/development.rb))

## Requisitos

- Docker e Docker Compose

## Passos para rodar o projeto (via Docker)
O Docker compose está configurado para expor as portas 5432 (PostgreSQL) e 6379 (Redis).
Assim, você pode conectar ferramentas externas, se necessário.
No diretório raiz do projeto:

1) Build das imagens
```sh
docker compose build
```

2) Subir dependências (Postgres e Redis), irá rodar em background
```sh
docker compose up -d
```

#### Executando o script
Com esse comando você já instala dependências, prepara o banco e sobe os serviços web, sidekiq e redis

```sh
bin/setup
```

#### Ou então executando passo a passo
3) Instalar dependências
```sh
bundle install
```

4) Preparar o banco
```sh
bin/rails db:setup
```

5) Subir serviços web, sidekiq e redis
```sh
bin/dev
```

A Aplicação estará disponível em http://localhost:3000

URLs:
- App: http://localhost:3000
- Sidekiq: http://localhost:3000/sidekiq
- Clientes: http://localhost:3000/customers
- Logs: http://localhost:3000/logs


## Como enviar um ou vários e-mail .eml para processamento

- Pela interface web:
  1. Abra http://localhost:3000
  2. Faça upload de um ou mais arquivos `.eml`
  3. O sistema cria `Logs` com status `pending`, anexa o arquivo e enfileira [`EmailProcessor::BulkProcessJob`](app/jobs/email_processor/bulk_process_job.rb), que por sua vez enfileira [`EmailProcessor::ProcessJob`](app/jobs/email_processor/process_job.rb) por log


## Como visualizar os resultados (customers + logs)

- Clientes criados: http://localhost:3000/customers
- Logs de processamento:
  - Lista: http://localhost:3000/logs
  - Detalhe (inclui `extracted_info`, `errors_info` e arquivo .eml): http://localhost:3000/logs/:id
- Filas/Jobs: http://localhost:3000/sidekiq

A criação/atualização de logs é feita pelos componentes de parsing com o concern [`ParserLogger`](app/models/concerns/parser_logger.rb).


## Testes

- Executar specs:
```sh
bundle exec rspec
```

Após rodar os testes, você poderá visulizar a cobertura de testes em `coverage/index.html`. Obtidos através da gem `simplecov`.

## Estrutura relevante

- Jobs: [`EmailProcessor::BulkProcessJob`](app/jobs/email_processor/bulk_process_job.rb), [`EmailProcessor::ProcessJob`](app/jobs/email_processor/process_job.rb)
- Parsing: [`EmailParser::Base`](app/models/email_parser/base.rb), [`EmailParser::Processor`](app/models/email_parser/processor.rb)
- Persistência: [`Customer`](app/models/customer.rb), [`Log`](app/models/log.rb)
- Rotas: [`config/routes.rb`](config/routes.rb)
- Inicialização e server: [`config/puma.rb`](config/puma.rb), [`config.ru`](config.ru)

