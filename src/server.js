import express from "express";
import cors from "cors";
import routes from "./allRoutes.js";
import "dotenv/config";

const PORT = process.env.API_PORT ?? 3000;

const api = express();

api.use(express.json());
api.use(cors());

// routes.forEach(({ router, path }) => {
//   api.use(path, router);
// });

api.listen(PORT, () => {
  console.log(`API http://localhost:${PORT}`);
});
