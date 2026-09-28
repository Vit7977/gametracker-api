import GameRepository from "./repository.js";

const GameService = {
  async create(data) {
    return await GameRepository.create(data);
  },
};

export default GameService;
