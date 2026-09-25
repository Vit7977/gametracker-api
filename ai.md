# GameTracker API — AI Development Guide

## 1. Objetivo do projeto

Criar e manter uma API REST para o **GameTracker**, um sistema de acompanhamento de jogos.

A API deve permitir que usuários:

- consultem jogos e plataformas;
- relacionem jogos às plataformas em que estão disponíveis;
- adicionem jogos à sua biblioteca;
- acompanhem o status de cada jogo;
- registrem nota e ranking;
- registrem sessões de jogo;
- acompanhem progresso e tempo jogado;
- obtenham dados para estatísticas e seções do sistema;
- gerenciem sua própria conta.

A API deve ser organizada, previsível, segura e compatível com a estrutura de pastas existente.

---

## 2. Stack obrigatória

O projeto utiliza:

- Node.js
- Express 5
- MySQL
- mysql2
- Zod
- JSON Web Token (`jsonwebtoken`)
- Argon2 (`argon2`)
- CORS
- dotenv
- Nodemon em desenvolvimento
- ES Modules (`"type": "module"`)

Não introduzir frameworks ou bibliotecas adicionais sem necessidade real.

### package.json atual

```json
{
  "name": "gametracker-api",
  "version": "1.0.0",
  "description": "",
  "main": "src/server.js",
  "scripts": {
    "dev": "nodemon ."
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "type": "module",
  "dependencies": {
    "argon2": "^0.45.1",
    "cors": "^2.8.6",
    "dotenv": "^18.0.3",
    "express": "^5.2.1",
    "jsonwebtoken": "^9.0.3",
    "mysql2": "^3.24.4",
    "zod": "^4.6.5"
  },
  "devDependencies": {
    "nodemon": "^3.1.14"
  }
}
```

---

## 3. Estrutura do projeto

Manter a arquitetura por feature:

```text
├── package-lock.json
├── package.json
├── src
│   ├── allRoutes.js
│   ├── core
│   │   ├── db.sql
│   │   └── pool.js
│   ├── features
│   │   ├── game
│   │   │   ├── controller.js
│   │   │   ├── dto.js
│   │   │   ├── repository.js
│   │   │   ├── routes.js
│   │   │   └── service.js
│   │   ├── game_platform
│   │   │   ├── controller.js
│   │   │   ├── dto.js
│   │   │   ├── repository.js
│   │   │   ├── routes.js
│   │   │   └── service.js
│   │   ├── platform
│   │   │   ├── controller.js
│   │   │   ├── dto.js
│   │   │   ├── repository.js
│   │   │   ├── routes.js
│   │   │   └── service.js
│   │   ├── session
│   │   │   ├── controller.js
│   │   │   ├── dto.js
│   │   │   ├── repository.js
│   │   │   ├── routes.js
│   │   │   └── service.js
│   │   ├── user
│   │   │   ├── controller.js
│   │   │   ├── dto.js
│   │   │   ├── repository.js
│   │   │   ├── routes.js
│   │   │   └── service.js
│   │   └── user_game_platform
│   │       ├── controller.js
│   │       ├── dto.js
│   │       ├── repository.js
│   │       ├── routes.js
│   │       └── service.js
│   ├── middlewares
│   ├── server.js
│   └── utils
│       └── asyncHandler.js
└── tree.txt
```

### Responsabilidade dos arquivos

Cada feature deve seguir, preferencialmente, o fluxo:

```text
routes
  ↓
controller
  ↓
service
  ↓
repository
  ↓
MySQL
```

O `dto.js` deve concentrar os schemas de validação usando Zod.

### Routes

Responsáveis apenas por:

- declarar endpoints;
- definir middlewares;
- encaminhar a requisição para o controller.

Não colocar regra de negócio nas rotas.

### Controller

Responsável por:

- receber `req` e `res`;
- extrair parâmetros, query e body;
- utilizar o service;
- retornar respostas HTTP.

Não colocar queries SQL no controller.

### Service

Responsável por:

- regras de negócio;
- validações que dependem de dados externos;
- composição de operações;
- controle do fluxo da aplicação.

Não colocar SQL diretamente no service quando a operação puder ficar no repository.

### Repository

Responsável por:

- comunicação com MySQL;
- queries SQL;
- inserts;
- updates;
- deletes;
- selects.

Utilizar sempre queries parametrizadas.

### DTO

Responsável por:

- validar `body`;
- validar parâmetros;
- validar query params;
- definir formatos esperados;
- impedir dados inválidos de chegarem à regra de negócio.

---

# 4. Banco de dados

Banco:

```text
GameTracker
```

## 4.1 Platform

```sql
CREATE TABLE IF NOT EXISTS platform(
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(50) NOT NULL,
    logo VARCHAR(255) NOT NULL
);
```

Representa uma plataforma onde um jogo pode estar disponível.

Exemplos:

- Playstation
- Xbox
- Steam
- Epic Games
- Nintendo Switch

---

## 4.2 Game

```sql
CREATE TABLE IF NOT EXISTS game(
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(100) NOT NULL,
    capa VARCHAR(255) NOT NULL,
    descricao TEXT NULL,
    data_lancamento DATE NOT NULL,
    genero VARCHAR(200) NOT NULL,
    tempo_estimado SMALLINT UNSIGNED NULL
);
```

Representa o jogo em si.

Campos:

| Campo | Tipo | Regra |
|---|---|---|
| id | INT | PK |
| titulo | VARCHAR(100) | obrigatório |
| capa | VARCHAR(255) | obrigatório |
| descricao | TEXT | opcional |
| data_lancamento | DATE | obrigatório |
| genero | VARCHAR(200) | obrigatório |
| tempo_estimado | SMALLINT UNSIGNED | opcional |

---

## 4.3 Game Platform

```sql
CREATE TABLE IF NOT EXISTS game_platform(
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    platform INT UNSIGNED NOT NULL,
    game INT UNSIGNED NOT NULL,
    UNIQUE KEY uq_game_platform(game, platform),
    FOREIGN KEY (game) REFERENCES game(id) ON DELETE CASCADE,
    FOREIGN KEY (platform) REFERENCES platform(id) ON DELETE CASCADE
);
```

É a tabela de relacionamento entre jogo e plataforma.

Um mesmo jogo pode estar em várias plataformas.

Uma plataforma pode possuir vários jogos.

A combinação:

```text
game + platform
```

não pode ser duplicada.

---

## 4.4 User

```sql
CREATE TABLE IF NOT EXISTS user(
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    senha VARCHAR(255) NOT NULL,
    avatar VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

Representa os usuários.

### Segurança

A senha **nunca deve ser armazenada em texto puro**.

Utilizar `argon2` para:

- criar hash da senha;
- verificar senha durante login.

A senha também nunca deve ser retornada nas respostas da API.

---

## 4.5 User Game Platform

```sql
CREATE TABLE IF NOT EXISTS user_game_platform(
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user INT UNSIGNED NOT NULL,
    game_platform INT UNSIGNED NOT NULL,
    status ENUM("lista de desejos", "jogando", "zerado", "100%", "replay") NOT NULL DEFAULT "lista de desejos",
    nota TINYINT UNSIGNED CHECK (nota BETWEEN 1 AND 10) NULL,
    ranking SMALLINT UNSIGNED NULL,
    adicionado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_user_game_platform (user, game_platform),
    FOREIGN KEY (user) REFERENCES user(id) ON DELETE CASCADE,
    FOREIGN KEY (game_platform) REFERENCES game_platform(id)
);
```

Essa tabela representa a relação entre:

```text
usuário → jogo → plataforma
```

Ela é a principal tabela da biblioteca pessoal do usuário.

### Status permitidos

```text
lista de desejos
jogando
zerado
100%
replay
```

### Regras

Um usuário não pode adicionar duas vezes o mesmo `game_platform`.

A combinação:

```text
user + game_platform
```

deve ser única.

---

## 4.6 Session

```sql
CREATE TABLE IF NOT EXISTS session(
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_game_platform INT UNSIGNED NOT NULL,
    data DATE NOT NULL,
    duracao_min SMALLINT UNSIGNED NOT NULL,
    progresso TINYINT UNSIGNED CHECK (progresso BETWEEN 0 AND 100) DEFAULT 0,
    comentario TEXT NULL,
    FOREIGN KEY (user_game_platform) REFERENCES user_game_platform(id)
);
```

Representa uma sessão de jogo realizada pelo usuário.

Cada sessão possui:

- data;
- duração em minutos;
- progresso;
- comentário.

---

# 5. Relacionamentos

O modelo conceitual é:

```text
USER
 │
 │ 1:N
 ▼
USER_GAME_PLATFORM
 │
 │ N:1
 ▼
GAME_PLATFORM
 │
 ├──────────────► GAME
 │
 └──────────────► PLATFORM

USER_GAME_PLATFORM
 │
 │ 1:N
 ▼
SESSION
```

Outra visão:

```text
User
  │
  └──< UserGamePlatform >── GamePlatform
                                  │
                         ┌────────┴────────┐
                         ▼                 ▼
                       Game             Platform

UserGamePlatform
  │
  └──< Session
```

---

# 6. Autenticação

A API deve utilizar JWT.

Fluxo esperado:

```text
POST /api/user/login
        │
        ▼
verifica email
        │
        ▼
argon2.verify()
        │
        ▼
gera JWT
        │
        ▼
retorna token
```

Endpoints protegidos devem exigir:

```text
Authorization: Bearer <token>
```

Criar um middleware de autenticação dentro de:

```text
src/middlewares
```

O middleware deve:

1. verificar se existe o header Authorization;
2. verificar se utiliza Bearer;
3. extrair o token;
4. validar o JWT;
5. disponibilizar o usuário autenticado em `req.user`;
6. rejeitar token inválido ou expirado.

Não confiar em `user` enviado pelo frontend para determinar o usuário autenticado.

Para operações relacionadas à biblioteca pessoal e sessões, o usuário deve ser obtido do JWT.

---

# 7. Payload do JWT

O payload deve conter somente informações necessárias.

Exemplo conceitual:

```json
{
  "sub": 1,
  "email": "usuario@email.com"
}
```

O campo `sub` representa o `user.id`.

Não colocar senha ou hash de senha no token.

---

# 8. Rotas

O padrão obrigatório de rotas é:

```text
/api/nome_feature
```

As rotas devem ser registradas em:

```text
src/allRoutes.js
```

Exemplo:

```text
/api/game
/api/platform
/api/game_platform
/api/user
/api/user_game_platform
/api/session
```

---

# 9. Endpoints esperados

## 9.1 Game

Base:

```text
/api/game
```

Operações esperadas:

```http
GET    /api/game
GET    /api/game/:id
POST   /api/game
PUT    /api/game/:id
DELETE /api/game/:id
```

O `game` representa dados globais do jogo.

A API pode posteriormente oferecer filtros, por exemplo:

```text
GET /api/game?genero=RPG
GET /api/game?titulo=...
GET /api/game?platform=...
```

Filtros devem ser implementados somente quando necessários.

---

# 10. Platform

Base:

```text
/api/platform
```

Operações:

```http
GET    /api/platform
GET    /api/platform/:id
POST   /api/platform
PUT    /api/platform/:id
DELETE /api/platform/:id
```

As plataformas iniciais estão no `db.sql`.

---

# 11. Game Platform

Base:

```text
/api/game_platform
```

Operações:

```http
GET    /api/game_platform
GET    /api/game_platform/:id
POST   /api/game_platform
PUT    /api/game_platform/:id
DELETE /api/game_platform/:id
```

Exemplo de criação:

```json
{
  "game": 1,
  "platform": 3
}
```

Antes de inserir:

- verificar se o game existe;
- verificar se a platform existe;
- respeitar a restrição única `game + platform`.

---

# 12. User

Base:

```text
/api/user
```

Operações relacionadas a cadastro:

```http
POST /api/user
POST /api/user/login
```

Operações do próprio usuário podem utilizar autenticação:

```http
GET /api/user/me
PUT /api/user/me
```

Não permitir que um usuário autenticado altere arbitrariamente o `id` de outro usuário.

### Cadastro

Payload conceitual:

```json
{
  "nome": "Vitor",
  "email": "vitor@email.com",
  "senha": "senha-segura",
  "avatar": "https://..."
}
```

A senha deve ser transformada em hash antes do INSERT.

### Login

Payload:

```json
{
  "email": "vitor@email.com",
  "senha": "senha-segura"
}
```

Resposta conceitual:

```json
{
  "token": "JWT..."
}
```

Nunca retornar:

```text
senha
```

nem:

```text
senha hash
```

---

# 13. User Game Platform

Base:

```text
/api/user_game_platform
```

É a biblioteca pessoal do usuário.

A maioria das operações deve exigir autenticação.

O `user` deve vir do JWT, e não do body enviado pelo frontend.

### Adicionar jogo à biblioteca

Exemplo:

```http
POST /api/user_game_platform
Authorization: Bearer <token>
```

Body:

```json
{
  "game_platform": 1,
  "status": "lista de desejos"
}
```

Opcionalmente:

```json
{
  "game_platform": 1,
  "status": "jogando",
  "nota": 8,
  "ranking": 10
}
```

O backend deve preencher o usuário autenticado.

Não aceitar como fonte confiável:

```json
{
  "user": 999
}
```

quando o endpoint estiver operando em nome do usuário autenticado.

### Operações esperadas

```http
GET    /api/user_game_platform
GET    /api/user_game_platform/:id
POST   /api/user_game_platform
PUT    /api/user_game_platform/:id
DELETE /api/user_game_platform/:id
```

O GET da biblioteca deve retornar somente registros pertencentes ao usuário autenticado.

---

# 14. Session

Base:

```text
/api/session
```

As sessões também pertencem indiretamente ao usuário por meio de `user_game_platform`.

Todas as operações devem validar que o registro relacionado pertence ao usuário autenticado.

Operações:

```http
GET    /api/session
GET    /api/session/:id
POST   /api/session
PUT    /api/session/:id
DELETE /api/session/:id
```

Exemplo:

```json
{
  "user_game_platform": 15,
  "data": "2026-09-25",
  "duracao_min": 90,
  "progresso": 65,
  "comentario": "Avancei bastante na campanha."
}
```

O backend deve verificar se `user_game_platform = 15` pertence ao usuário autenticado antes de criar ou alterar a sessão.

---

# 15. Estatísticas

O objetivo do projeto inclui fornecer informações para dashboards e seções de estatísticas.

As estatísticas devem ser calculadas preferencialmente no backend utilizando SQL.

Exemplos de informações que a API poderá fornecer:

- quantidade total de jogos na biblioteca;
- quantidade de jogos em cada status;
- quantidade de jogos zerados;
- quantidade de jogos 100%;
- quantidade de jogos em replay;
- quantidade de jogos na lista de desejos;
- quantidade de jogos atualmente jogando;
- tempo total jogado;
- média das notas;
- quantidade de sessões;
- progresso médio;
- jogos por plataforma;
- jogos por gênero;
- jogos mais jogados;
- jogos com maior ranking;
- atividade recente.

Não duplicar dados derivados no banco sem necessidade.

Sempre que possível, calcular estatísticas com consultas SQL.

---

# 16. Endpoint de estatísticas

Pode ser criada uma feature específica caso o projeto necessite de um endpoint dedicado:

```text
/api/statistics
```

Essa feature não precisa seguir obrigatoriamente o mesmo CRUD das demais.

Exemplos:

```http
GET /api/statistics
GET /api/statistics/library
GET /api/statistics/sessions
GET /api/statistics/platforms
GET /api/statistics/genres
```

As estatísticas pessoais devem usar o usuário autenticado.

---

# 17. Regras importantes de segurança

## Senhas

Sempre utilizar Argon2:

```js
const hash = await argon2.hash(senha);
```

Para verificar:

```js
const valido = await argon2.verify(hash, senha);
```

Nunca armazenar senha em texto puro.

---

## SQL Injection

Nunca concatenar dados diretamente na query.

Errado:

```js
pool.execute(`SELECT * FROM game WHERE id = ${id}`);
```

Preferir:

```js
pool.execute(
  "SELECT * FROM game WHERE id = ?",
  [id]
);
```

---

## JWT

Nunca aceitar um `user` arbitrário do frontend quando o usuário autenticado já está disponível no token.

---

## Autorização

Autenticação significa:

```text
"quem é o usuário?"
```

Autorização significa:

```text
"esse usuário pode acessar esse registro?"
```

As duas verificações devem ser consideradas.

Exemplo:

```text
GET /api/session/50
```

Não basta verificar se o token é válido.

Também é necessário verificar se a sessão 50 pertence ao usuário autenticado.

---

# 18. Respostas HTTP

Utilizar códigos HTTP apropriados.

### Sucesso

```text
200 OK
201 Created
204 No Content
```

### Erro do cliente

```text
400 Bad Request
401 Unauthorized
403 Forbidden
404 Not Found
409 Conflict
422 Unprocessable Entity
```

### Erro interno

```text
500 Internal Server Error
```

Não expor stack trace ou detalhes internos do banco em produção.

---

# 19. Formato de respostas

Manter um padrão consistente.

Exemplo de sucesso:

```json
{
  "success": true,
  "data": {
    "id": 1,
    "titulo": "The Witcher 3"
  }
}
```

Lista:

```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "titulo": "The Witcher 3"
    }
  ]
}
```

Erro:

```json
{
  "success": false,
  "message": "Jogo não encontrado."
}
```

Não é obrigatório usar exatamente esse formato caso o projeto já tenha outro padrão consolidado, mas todas as features devem seguir o mesmo padrão.

---

# 20. Validação com Zod

Os DTOs devem validar os dados recebidos.

Exemplo conceitual:

```js
import { z } from "zod";

export const createGameSchema = z.object({
  titulo: z.string().min(1).max(100),
  capa: z.string().url(),
  descricao: z.string().nullable().optional(),
  data_lancamento: z.coerce.date(),
  genero: z.string().min(1).max(200),
  tempo_estimado: z.number().int().positive().nullable().optional()
});
```

Os schemas devem refletir as restrições do banco.

Não confiar somente no banco para validar entrada.

---

# 21. Variáveis de ambiente

Utilizar `.env`.

Exemplo:

```env
PORT=3000

DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=
DB_NAME=GameTracker

JWT_SECRET=
JWT_EXPIRES_IN=
```

Nunca versionar:

```text
.env
```

Nunca colocar:

- senha do banco;
- JWT secret;
- credenciais;
- tokens

diretamente no código.

---

# 22. Pool MySQL

A conexão deve ser centralizada em:

```text
src/core/pool.js
```

As features devem importar o pool em seus repositories.

Não criar uma nova conexão manual para cada request.

---

# 23. Async Handler

O projeto possui:

```text
src/utils/asyncHandler.js
```

Utilizar essa estratégia para evitar repetição de `try/catch` nos controllers quando apropriado.

Exemplo conceitual:

```js
router.get(
  "/",
  asyncHandler(controller.list)
);
```

Os erros devem ser encaminhados para um middleware global de tratamento de erros.

---

# 24. Middleware global de erros

Criar um middleware centralizado em:

```text
src/middlewares
```

Responsável por:

- tratar erros de validação;
- tratar erros de autenticação;
- tratar erros de regra de negócio;
- tratar erros do MySQL;
- retornar respostas consistentes.

Não repetir tratamento de erros idêntico em todos os controllers.

---

# 25. CORS

Configurar CORS no `server.js`.

Durante desenvolvimento, permitir o frontend utilizado pelo projeto.

Em produção, restringir as origens conforme necessário.

---

# 26. Regras de negócio importantes

## Game

Um jogo é uma entidade global.

Não deve ser duplicado simplesmente porque dois usuários possuem o mesmo jogo.

---

## Game Platform

Um jogo pode possuir várias plataformas.

Exemplo:

```text
God of War
 ├── Playstation
 └── PC/Steam
```

A mesma combinação nunca deve ser cadastrada duas vezes.

---

## Biblioteca do usuário

A biblioteca deve utilizar:

```text
user_game_platform
```

O mesmo usuário pode possuir vários jogos.

O mesmo jogo pode aparecer na biblioteca de muitos usuários.

---

## Sessões

Uma sessão pertence a um registro de:

```text
user_game_platform
```

Logo, uma sessão não deve ser associada diretamente a um usuário diferente do proprietário desse registro.

---

# 27. Integridade das relações

Ao criar `user_game_platform`:

1. verificar se o `game_platform` existe;
2. verificar se a combinação já pertence ao usuário;
3. inserir somente se válida.

Ao criar `session`:

1. verificar se `user_game_platform` existe;
2. verificar se pertence ao usuário autenticado;
3. validar duração;
4. validar progresso;
5. criar a sessão.

Ao atualizar ou excluir:

1. localizar o registro;
2. verificar propriedade;
3. executar a operação.

---

# 28. Status dos jogos

Os valores permitidos são exatamente:

```text
lista de desejos
jogando
zerado
100%
replay
```

Não alterar a grafia sem atualizar o banco e os DTOs.

Exemplo de DTO:

```js
const statusSchema = z.enum([
  "lista de desejos",
  "jogando",
  "zerado",
  "100%",
  "replay"
]);
```

---

# 29. Nota

A nota deve estar entre:

```text
1
```

e:

```text
10
```

inclusive.

O valor é opcional.

Exemplo válido:

```json
{
  "nota": 9
}
```

Exemplos inválidos:

```json
{
  "nota": 0
}
```

```json
{
  "nota": 11
}
```

---

# 30. Progresso

O progresso deve estar entre:

```text
0
```

e:

```text
100
```

inclusive.

Exemplo:

```json
{
  "progresso": 75
}
```

---

# 31. Organização de rotas

O `allRoutes.js` deve centralizar as rotas das features.

Exemplo conceitual:

```js
import gameRoutes from "./features/game/routes.js";
import platformRoutes from "./features/platform/routes.js";
import gamePlatformRoutes from "./features/game_platform/routes.js";
import userRoutes from "./features/user/routes.js";
import userGamePlatformRoutes from "./features/user_game_platform/routes.js";
import sessionRoutes from "./features/session/routes.js";

export default function allRoutes(app) {
  app.use("/api/game", gameRoutes);
  app.use("/api/platform", platformRoutes);
  app.use("/api/game_platform", gamePlatformRoutes);
  app.use("/api/user", userRoutes);
  app.use("/api/user_game_platform", userGamePlatformRoutes);
  app.use("/api/session", sessionRoutes);
}
```

---

# 32. Padrão de implementação de uma feature

Para uma nova feature:

```text
src/features/nova_feature/
├── controller.js
├── dto.js
├── repository.js
├── routes.js
└── service.js
```

Fluxo:

```text
HTTP Request
    ↓
routes.js
    ↓
middleware
    ↓
controller.js
    ↓
dto.js / validação
    ↓
service.js
    ↓
repository.js
    ↓
MySQL
```

---

# 33. O que não fazer

Não:

- colocar SQL dentro do controller;
- colocar regra de negócio complexa dentro das routes;
- retornar senha;
- confiar no `user` enviado pelo frontend para operações autenticadas;
- permitir acesso a registros de outro usuário;
- concatenar valores diretamente em SQL;
- criar conexões MySQL desnecessárias;
- duplicar validações sem motivo;
- duplicar código entre features;
- armazenar secrets no código;
- ignorar erros de banco;
- retornar informações internas da aplicação em produção.

---

# 34. Prioridade de implementação

Implementar preferencialmente nesta ordem:

### Etapa 1 — Infraestrutura

- server;
- Express;
- CORS;
- dotenv;
- pool MySQL;
- tratamento global de erros;
- async handler;
- estrutura de rotas.

### Etapa 2 — Usuário e autenticação

- cadastro;
- hash Argon2;
- login;
- JWT;
- middleware de autenticação;
- `/api/user/me`.

### Etapa 3 — Catálogo

- platform;
- game;
- game_platform.

### Etapa 4 — Biblioteca

- user_game_platform;
- controle de status;
- nota;
- ranking.

### Etapa 5 — Sessões

- criação;
- listagem;
- atualização;
- exclusão;
- validação de propriedade.

### Etapa 6 — Estatísticas

- biblioteca;
- status;
- plataformas;
- gêneros;
- sessões;
- tempo jogado;
- notas;
- atividade recente.

---

# 35. Critérios de qualidade

Antes de considerar uma feature concluída, verificar:

- [ ] possui `routes.js`;
- [ ] possui `controller.js`;
- [ ] possui `service.js`;
- [ ] possui `repository.js`;
- [ ] possui `dto.js`;
- [ ] possui validação Zod;
- [ ] usa queries parametrizadas;
- [ ] possui tratamento de erros;
- [ ] utiliza HTTP status apropriado;
- [ ] respeita autenticação quando necessário;
- [ ] verifica autorização/propriedade;
- [ ] não retorna senha;
- [ ] não possui credenciais hardcoded;
- [ ] respeita os relacionamentos do banco;
- [ ] segue `/api/nome_feature`;
- [ ] não duplica regra de negócio;
- [ ] funciona com o pool MySQL existente.

---

# 36. Diretriz principal para a IA

Ao gerar ou alterar código deste projeto:

1. Analise primeiro o `db.sql`.
2. Respeite os nomes das tabelas e colunas existentes.
3. Respeite a estrutura de pastas existente.
4. Não invente entidades que não sejam necessárias.
5. Não altere o banco sem explicar a necessidade.
6. Utilize a arquitetura `routes → controller → service → repository`.
7. Utilize Zod para entrada de dados.
8. Utilize JWT para autenticação.
9. Utilize Argon2 para senhas.
10. Para dados pessoais, utilize o usuário autenticado do JWT.
11. Verifique autorização antes de acessar registros pertencentes a usuários.
12. Utilize SQL parametrizado.
13. Mantenha respostas HTTP consistentes.
14. Evite dependências adicionais quando a stack atual já resolver o problema.
15. Quando uma alteração envolver várias camadas, atualize todas as camadas necessárias.
16. Não criar código apenas parcialmente implementado.
17. Quando solicitado a criar uma feature, entregar todos os arquivos necessários para que ela funcione.
18. Explicar claramente qualquer alteração no banco de dados.
19. Manter compatibilidade com Node.js usando ES Modules.
20. Priorizar código simples, legível e consistente com as features existentes.

---

# 37. Resultado esperado

O resultado final deve ser uma API REST capaz de sustentar um sistema de tracking de jogos com:

```text
Usuários
   │
   ├── Biblioteca
   │      │
   │      ├── Jogos
   │      ├── Plataformas
   │      ├── Status
   │      ├── Notas
   │      └── Ranking
   │
   └── Sessões
          ├── Data
          ├── Duração
          ├── Progresso
          └── Comentário
```

E fornecer dados suficientes para o frontend construir:

- página inicial;
- biblioteca;
- catálogo de jogos;
- detalhes de jogos;
- jogos por plataforma;
- lista de desejos;
- jogos em andamento;
- jogos zerados;
- jogos 100%;
- jogos em replay;
- histórico de sessões;
- estatísticas;
- perfil do usuário;
- dashboards.

A API deve ser construída pensando em **separação de responsabilidades, segurança, integridade dos dados, escalabilidade e facilidade de manutenção**.
