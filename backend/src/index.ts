import express from 'express';
import authRouter from './route/auth';
import taskRouter from './route/task';


const app = express(); // creates an Express application instance.

app.use(express.json());//uses a middleware that only parses json and only looks at requests where the Content-Type header mathches the type option.

app.use("/auth", authRouter);//"Use authRouter for any route that starts with /auth."
app.use("/tasks",taskRouter);


app.get("/", (req, res) => {
    res.send("Welcome to my app");
});
app.listen(8000, () => {
    console.log('SErver started on port 8000');
});
