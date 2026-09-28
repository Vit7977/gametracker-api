import pool from "../../core/pool.js";

const GameRepository = {
  async create(game) {
    return await pool.execute(
      `INSERT INTO game(titulo, capa, descricao, data_lancamento, genero, tempo_estimado) 
        VALUES(?, ?, ?, ?, ?, ?);`,
      [
        game.titulo,
        game.capa,
        game.descricao,
        game.data_lancamento,
        game.genero,
        game.tempo_estimado,
      ],
    );
  },
};

export default GameRepository;
