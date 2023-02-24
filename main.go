package main

import (
	"github.com/gofiber/fiber/v2"
)

func main() {
	app := fiber.New()

	app.Get("/", func(c *fiber.Ctx) error {
		c.Set(fiber.HeaderContentType, fiber.MIMETextHTML)

		return c.SendString("<h1>Hello, World!</h1>")
	})

	app.Listen(":5050")
}
