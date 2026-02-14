# NoMore — Guia de Manutenção e Operação

## O que é o NoMore?
App de accountability comportamental que combate procrastinação através de compromissos com deadline.
Se você não cumpre no prazo, o sistema marca como **FAILED** automaticamente.

---

## Stack Tecnológica
| Tecnologia | Versão | Função |
|---|---|---|
| Ruby | 3.4.1 | Linguagem |
| Rails | 8.1.2 | Framework web (monolito full-stack) |
| PostgreSQL | 16 | Banco de dados |
| Redis | 7 | Cache + filas do Sidekiq |
| Sidekiq | 7.x | Processamento de jobs em background |
| sidekiq-cron | 2.x | Agendamento de jobs recorrentes |
| Hotwire (Turbo + Stimulus) | - | Interações SPA-like sem reload |
| TailwindCSS | 4.x | Estilização |
| Docker | - | Containerização |

---

## Como rodar o projeto

### Com Docker (recomendado)
```bash
# Primeira vez (build + sobe tudo)
docker compose up --build

# Próximas vezes
docker compose up

# Rebuild após mudar Gemfile ou Dockerfile
docker compose up --build

# Restart apenas web e sidekiq (após mudar código Ruby)
docker compose restart web sidekiq

# Derrubar tudo
docker compose down

# Derrubar tudo E apagar dados do banco
docker compose down -v
```

### Sem Docker (local)
```bash
# Instalar dependências
bundle install

# Criar/migrar banco
bin/rails db:prepare

# Iniciar servidor + tailwind watch
bin/dev

# Em outra aba: Sidekiq
bundle exec sidekiq
```

---

## Estrutura do Projeto

### Arquivos Principais
```
app/
├── controllers/
│   ├── application_controller.rb    # Auth helpers (current_user, authenticate_user!)
│   ├── sessions_controller.rb       # Login/logout
│   ├── registrations_controller.rb  # Signup
│   ├── dashboard_controller.rb      # Dashboard principal
│   ├── commitments_controller.rb    # CRUD de commitments
│   └── focus_sessions_controller.rb # Timer Pomodoro
├── models/
│   ├── user.rb                      # has_secure_password, validações de email
│   ├── commitment.rb                # enum status (active/completed/failed)
│   ├── focus_session.rb             # Sessões de foco
│   └── current.rb                   # Request-scoped user (Current.user)
├── services/
│   └── user_analytics.rb            # Cálculos do dashboard (%, streak, etc)
├── jobs/
│   └── expire_commitments_job.rb    # Auto-fail de commitments expirados
├── javascript/controllers/
│   └── timer_controller.js          # Stimulus: timer Pomodoro 25/5 min
└── views/
    ├── layouts/
    │   ├── application.html.erb     # Layout principal (nav, dark theme)
    │   └── auth.html.erb            # Layout de login/signup (centralizado)
    ├── dashboard/show.html.erb      # Dashboard com analytics + commitments
    ├── commitments/                 # new, show, _commitment partial
    ├── focus_sessions/              # index, _controls, _session_row
    ├── sessions/new.html.erb        # Formulário de login
    └── registrations/new.html.erb   # Formulário de signup

config/
├── database.yml                     # Configuração PostgreSQL
├── routes.rb                        # Todas as rotas
├── application.rb                   # Timezone Brasilia
└── initializers/
    └── sidekiq.rb                   # Redis config + cron schedule

docker-compose.yml                   # 4 serviços: db, redis, web, sidekiq
Dockerfile.dev                       # Imagem Docker para desenvolvimento
```

---

## Rotas da Aplicação
| Método | Rota | O que faz |
|---|---|---|
| GET | `/` | Dashboard (requer login) |
| GET | `/login` | Formulário de login |
| POST | `/login` | Autenticar |
| DELETE | `/logout` | Sair |
| GET | `/signup` | Formulário de cadastro |
| POST | `/signup` | Criar conta |
| GET | `/commitments/new` | Novo commitment |
| POST | `/commitments` | Criar commitment |
| GET | `/commitments/:id` | Ver detalhes |
| PATCH | `/commitments/:id/complete` | Marcar como completo |
| GET | `/focus` | Timer Pomodoro |
| POST | `/focus` | Iniciar sessão de foco |
| PATCH | `/focus/:id/stop` | Parar sessão |
| GET | `/sidekiq` | Painel do Sidekiq (jobs) |
| GET | `/up` | Health check |

---

## Sidekiq (Jobs em Background)

### Como acessar o painel
Abra no navegador: **http://localhost:3000/sidekiq**

Lá você vê:
- **Dashboard** — jobs processados, falhados, em fila
- **Cron** — jobs agendados (clique na aba "Cron")
- **Retries** — jobs que falharam e estão tentando de novo
- **Dead** — jobs que falharam demais e foram descartados

### Job configurado
| Job | Frequência | O que faz |
|---|---|---|
| `ExpireCommitmentsJob` | A cada 1 minuto | Busca commitments `active` com deadline passada e marca como `failed` |

### Onde configurar novos jobs
Arquivo: `config/initializers/sidekiq.rb`
```ruby
# Adicionar na array schedule:
{
  "name" => "nome_do_job",
  "cron" => "*/5 * * * *",  # A cada 5 minutos
  "class" => "NomeDoJob",
  "queue" => "default"
}
```

### Troubleshooting Sidekiq
```bash
# Ver logs do sidekiq
docker logs nomore-sidekiq-1 -f

# Restart só o sidekiq
docker compose restart sidekiq

# Rebuild sidekiq (após mudanças no Gemfile)
docker compose up --build sidekiq
```

---

## Autenticação

### Como funciona
- **Sem gems externas** — auth é manual com `has_secure_password` (bcrypt)
- Sessão é um cookie Rails padrão (`session[:user_id]`)
- `current_user` está disponível em todos os controllers e views
- `authenticate_user!` roda antes de toda action (exceto login/signup)
- `Current.user` para acesso em models/services

### Fluxo
1. Usuário faz POST `/signup` ou `/login`
2. Controller verifica credenciais
3. Se OK, grava `session[:user_id]`
4. `current_user` busca o user pelo ID da sessão
5. Logout deleta `session[:user_id]`

---

## Banco de Dados

### Tabelas
| Tabela | Campos importantes |
|---|---|
| `users` | email (unique), password_digest |
| `commitments` | user_id, title, category, deadline, status (0=active, 1=completed, 2=failed), completed_at |
| `focus_sessions` | user_id, started_at, ended_at, duration_seconds |

### Comandos úteis
```bash
# Criar banco
docker compose exec web bin/rails db:create

# Rodar migrations pendentes
docker compose exec web bin/rails db:migrate

# Resetar banco (APAGA TUDO)
docker compose exec web bin/rails db:reset

# Abrir console Rails
docker compose exec web bin/rails console

# Abrir psql direto no banco
docker compose exec db psql -U nomore nomore_development
```

### Criar migration nova
```bash
docker compose exec web bin/rails generate migration AddCampoToTabela campo:tipo
docker compose exec web bin/rails db:migrate
```

---

## Models — Regras de Negócio

### Commitment
- **Status**: `active` (0) → `completed` (1) ou `failed` (2)
- Deadline não pode ser no passado (mínimo 2 min no futuro)
- Não tem edit/update — uma vez criado, ou completa ou falha
- Auto-fail via `ExpireCommitmentsJob` quando deadline passa
- Scope `past_deadline`: busca ativos com deadline expirada

### User
- Email normalizado (lowercase, strip)
- Email único (case-insensitive)
- Senha hasheada com bcrypt

---

## Tailwind / Frontend

### Tema
- Background: `bg-gray-950` (quase preto)
- Cards: `bg-gray-900` com `border-gray-800`
- Accent: `text-red-500` / `bg-red-600`
- Texto: `text-gray-100` (principal), `text-gray-400` (secundário)

### Recompilar CSS
```bash
# Dentro do container
docker compose exec web bin/rails tailwindcss:build

# Ou com watch (desenvolvimento)
docker compose exec web bin/rails tailwindcss:watch
```

---

## Como adicionar funcionalidades

### Novo controller + views
```bash
docker compose exec web bin/rails generate controller NomeDoController action1 action2
```

### Novo model
```bash
docker compose exec web bin/rails generate model NomeDoModel campo:tipo
docker compose exec web bin/rails db:migrate
```

### Novo Stimulus controller
Criar arquivo em `app/javascript/controllers/nome_controller.js`:
```javascript
import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  connect() { }
}
```
Usar na view: `data-controller="nome"`

---

## Timezone
Configurado para **Brasilia** (UTC-3) em `config/application.rb`.
Todas as datas (`Time.current`, `Time.zone.now`) usam esse fuso.
O banco armazena em UTC, Rails converte automaticamente.

---

## Variáveis de Ambiente
| Variável | Descrição | Default (dev) |
|---|---|---|
| `DATABASE_URL` | URL do PostgreSQL | `postgres://nomore:nomore_dev@db:5432/nomore_development` |
| `REDIS_URL` | URL do Redis | `redis://redis:6379/0` |
| `SECRET_KEY_BASE` | Chave secreta do Rails | Gerada para dev |
| `POSTGRES_PASSWORD` | Senha do PostgreSQL | `nomore_dev` |

---

## Problemas Comuns

### "database does not exist"
```bash
docker compose exec web bin/rails db:prepare
```

### Sidekiq não processa jobs
1. Checar logs: `docker logs nomore-sidekiq-1 -f`
2. Verificar Redis: `docker compose exec redis redis-cli ping` (deve retornar PONG)
3. Restart: `docker compose restart sidekiq`

### Mudei código Ruby e não refletiu
O código é montado via volume, então mudanças em controllers/models/views refletem automaticamente.
Mas se mudou `Gemfile`, `config/initializers/`, ou `config/application.rb`:
```bash
docker compose restart web sidekiq
```

### Mudei Gemfile
```bash
docker compose up --build
```

### CSS não atualiza
```bash
docker compose exec web bin/rails tailwindcss:build
```
