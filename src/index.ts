import express from "express";
import type {Request, Response} from "express";

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json())

app.get("/", (req: Request, res: Response) => {
    res.json({
        message: "Welcome to Atlas-Microservice"
    });
});

app.get("/health", (req:Request, res: Response) => {
    res.status(200).json({
        status: "UP",
        timestamp:new Date().toISOString() 
    });
});

app.post("/data", (req: Request, res: Response) => {
    const {name} = req.body;
    res.status(201).json({
        message: `Data for ${name} recieved and processed`
    });
});

app.listen(PORT, () => {
    console.log( `Server running on http://localhost:${PORT}`)
})