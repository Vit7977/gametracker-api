--DROP DATABASE GameTracker;
CREATE DATABASE GameTracker;
USE GameTracker;

DROP TABLE IF EXISTS platform;
CREATE TABLE IF NOT EXISTS platform(
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(50) NOT NULL,
    logo VARCHAR(255) NOT NULL
);

INSERT INTO platform(nome, logo) VALUES 
("Playstation", "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Playstation_logo_colour.svg/3840px-Playstation_logo_colour.svg.png"), 
("Xbox", "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f9/Xbox_one_logo.svg/960px-Xbox_one_logo.svg.png"), 
("Steam", "https://upload.wikimedia.org/wikipedia/commons/c/c1/Steam_Logo.png"), 
("Epic Games", "https://upload.wikimedia.org/wikipedia/commons/thumb/3/31/Epic_Games_logo.svg/1920px-Epic_Games_logo.svg.png"), 
("Nintendo Switch", "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5d/Nintendo_Switch_Logo.svg/1280px-Nintendo_Switch_Logo.svg.png");

DROP TABLE IF EXISTS game;
CREATE TABLE IF NOT EXISTS game(
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(100) NOT NULL,
    capa VARCHAR(255) NOT NULL,
    descricao TEXT NULL,
    data_lancamento DATE NOT NULL,
    genero VARCHAR(200) NOT NULL,
    tempo_estimado SMALLINT UNSIGNED NULL 
);

DROP TABLE IF EXISTS game_platform;
CREATE TABLE IF NOT EXISTS game_platform(
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    platform INT UNSIGNED NOT NULL,
    game INT UNSIGNED NOT NULL,
    UNIQUE KEY uq_game_platform(game, platform),
    FOREIGN KEY (game) REFERENCES game(id) ON DELETE CASCADE,
    FOREIGN KEY (platform) REFERENCES platform(id) ON DELETE CASCADE 
);

DROP TABLE IF EXISTS user;
CREATE TABLE IF NOT EXISTS user(
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    senha VARCHAR(255) NOT NULL,
    avatar VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS user_game_platform;
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

DROP TABLE IF EXISTS session;
CREATE TABLE IF NOT EXISTS session(
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_game_platform INT UNSIGNED NOT NULL,
    data DATE NOT NULL,
    duracao_min SMALLINT UNSIGNED NOT NULL,
    progresso TINYINT UNSIGNED CHECK (progresso BETWEEN 0 AND 100) DEFAULT 0,
    comentario TEXT NULL,
    FOREIGN KEY (user_game_platform) REFERENCES user_game_platform(id)
);