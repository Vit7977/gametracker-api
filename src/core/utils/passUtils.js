import * as argon2 from "argon2";

const PEPPER = process.env.PEPPER;

const Pass = {
    async hash (password) {
      return await argon2.hash(password + PEPPER, {
        type: argon2.argon2id,
        memoryCost: 2 ** 16,
        parallelism: 4,
        timeCost: 3,
      });
    },
    
   async verify (hash, password) {
      return await argon2.verify(hash, password + PEPPER);
    }
}

export default Pass;