# Próxima Etapa – Containerização com Docker (Cloud Native – Entrega 2)

## Objetivo
Empacotar e orquestrar com Docker a solução do **App do Aluno – Próxima Etapa**
(painel web administrativo + API REST em Node.js + banco MySQL), garantindo isolamento,
portabilidade e reprodutibilidade com um único comando. Antes, o ambiente rodava no XAMPP
(Apache + MySQL + phpMyAdmin); agora cada peça roda em seu próprio container.

## Arquitetura

```
 Navegador / App Android
          │
          ▼
  ┌───────────────┐   /api/*   ┌───────────────┐   SQL   ┌────────────────┐
  │ web (Nginx)   │ ─────────► │ api (Node.js) │ ──────► │ db (MySQL 8)   │
  │ porta 8080    │            │ porta 3000    │         │ volume:mysqldata│
  └───────────────┘            └───────────────┘         └───────▲────────┘
                                                                  │
                                                      ┌───────────┴────────┐
                                                      │ phpmyadmin (8081)  │
                                                      └────────────────────┘
          └──────────── rede Docker: proxima-net ────────────┘
```

| Serviço | Imagem | Função |
|---------|--------|--------|
| web | Dockerfile próprio (nginx:alpine) | Painel administrativo estático + proxy reverso para a API |
| api | Dockerfile próprio (node:20-alpine, multi-stage, usuário não-root) | API REST (cursos, agenda, presença) |
| db  | mysql:8.0 | Banco com volume persistente e carga automática `db/init.sql` |
| phpmyadmin | phpmyadmin:5 | Administração visual do banco (substitui o do XAMPP) |

## Do XAMPP para o Docker

| XAMPP | Docker |
|-------|--------|
| MySQL em `localhost:3306` | container `db` (a API acessa por `DB_HOST=db`) |
| phpMyAdmin em `localhost/phpmyadmin` | container `phpmyadmin` em `localhost:8081` |
| Apache servindo o painel | container `web` (Nginx) |
| Banco criado/importado manualmente | `db/init.sql` carregado automaticamente na 1ª subida |
| Senha vazia do `root` | credenciais definidas no `.env` |

## Requisitos atendidos
- Dockerfiles próprios com boas práticas: imagem base enxuta (alpine), `.dockerignore`, multi-stage, camadas otimizadas, usuário não-root e HEALTHCHECK.
- `docker-compose.yml` com 4 serviços integrados.
- Volume nomeado `mysqldata` para persistência.
- Rede customizada `proxima-net`; comunicação por nome de serviço (`db`, `api`).
- Configuração por variáveis de ambiente (`.env`), sem credenciais no código.
- Consultas SQL parametrizadas (proteção contra SQL Injection) e dados fictícios (LGPD).

## Como executar
Pré-requisitos: Docker e Docker Compose.

```bash
cp .env.example .env        # edite as senhas
docker compose up --build -d
docker compose ps
```

## Portas
- Web: http://localhost:8080
- API: http://localhost:3000 (no emulador Android: http://10.0.2.2:3000)
- phpMyAdmin: http://localhost:8081 (usuário e senha do `.env`)

## Como testar
```bash
curl http://localhost:3000/health
curl http://localhost:3000/api/courses
curl http://localhost:3000/api/students/1/schedule
curl -X POST http://localhost:3000/api/attendance \
     -H "Content-Type: application/json" \
     -d '{"student_id":1,"session_id":1}'      # 201
# repita o POST acima -> 409 (presença duplicada bloqueada)
```

### Testar persistência
```bash
docker compose down            # remove containers, mantém o volume
docker compose up -d
curl http://localhost:3000/api/courses   # dados continuam lá
```
Para apagar tudo: `docker compose down -v`.

### Testes automáticos
O workflow `.github/workflows/docker-test.yml` (GitHub Actions) faz o build, sobe os containers e executa os testes acima a cada push.

## Estrutura
```
.
├── docker-compose.yml
├── .env.example
├── .github/workflows/docker-test.yml
├── api/    (Dockerfile, .dockerignore, server.js, package.json)
├── web/    (Dockerfile, nginx.conf, index.html)
└── db/     (init.sql)
```

## Integrantes
(Nome e RA de cada integrante do grupo)
