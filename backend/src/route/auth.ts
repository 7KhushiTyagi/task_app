import { Router, Request, Response } from "express";
import { db } from "../db";
import { NewUser, users } from "../db/schema";
import { eq } from "drizzle-orm";
import bcryptjs from "bcryptjs";
import jwt from "jsonwebtoken";
import { auth, AuthRequest } from "../middleware/auth";

const authRouter = Router();//authRouter is initialized as a new router to handle authentication-related routes like signup, login, etc.

interface SignUpBody {
    name: string;
    email: string;
    password: string;
}



authRouter.post("/signup", async (req: Request<{}, {}, SignUpBody>, res: Response) => {
    try {
        // get req body
        const { name, email, password } = req.body;


        //check if the user already exist
        const existingUser = await db.select().from(users).where(eq(users.email, email));
        if (existingUser.length) {
            res.status(400).json({ error: "User already exist" });
            return;
        }
        //hash password
        const hashedPassword = await bcryptjs.hash(password, 8);
        const newUser: NewUser = {
            name: name,
            email: email,
            password: hashedPassword,

        };
        const [user] = await db.insert(users).values(newUser).returning();
        res.status(201).json(user);


    } catch (e) {
        res.status(500).json({ error: e })
        return;
    }

});

interface LoginBody {
    email: string;
    password: string;

}

authRouter.post("/login", async (req: Request<{}, {}, LoginBody>, res: Response) => {
    try {
        // get req body
        const { email, password } = req.body;



        const [existingUser] = await db.select().from(users).where(eq(users.email, email));
        if (!existingUser) {
            res.status(400).json({ error: "User with this mail doesn't exist" });
            return;
        }
        //hash password
        const isMatch = await bcryptjs.compare(password, existingUser.password);
        if (!isMatch) {
            res.status(400).json({ error: "Invalid credentials" });
            return;
        }

        const token = jwt.sign({ id: existingUser.id }, "passwordKey");

        res.json({ token, ...existingUser });

        res.status(201).json(existingUser);


    } catch (e) {
        res.status(500).json({ error: e })
    }

});

authRouter.post("/tokenIsValid", async (req, res) => {
    try {
        //get the header token
        const token = req.header("x-auth-token");
        if (!token) {
            res.json(false);
            return;
        }
        //verify if the token is valid
        const verified = jwt.verify(token, "passwordKey");
        if (!verified) {
            res.json(false);
            return;
        }
        //get the user data if the token is valid
        const verifiedToken = verified as { id: string };

        const [user] = await db.select().from(users).where(eq(users.id, verifiedToken.id));
        //if no user, return false
        if (!user) {
            res.json(false);
            return;
        }

        //if user exist return true
        res.json(true);




    } catch (e) {
        res.status(500).json({ error: e })
    }


});

authRouter.get("/",auth, (req: AuthRequest, res) => {

    res.send(req.token);
});

export default authRouter;