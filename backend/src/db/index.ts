import { Pool } from "pg";
import { drizzle } from "drizzle-orm/node-postgres";

const pool= new Pool({
    connectionString: "postgresql://postgres:test123@db:5432/mydb" //This is the URL that specifies how to connect to the PostgreSQL database.

});

export const  db=drizzle(pool);
