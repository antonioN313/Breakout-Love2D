local PupSpawn = math.random(10)
local PupPlay = false
local KPupSpawn = math.random(10)
local KPupPlay = false

local Ponce = true
local Konce = true

local AllowKeyPowerUp = false
PlayState = Class({ __includes = BaseState })

function PlayState:enter(params)
	self.paddle = params.paddle
	self.bricks = params.bricks
	self.health = params.health
	self.score = params.score
	self.highScores = params.highScores
	self.ball = params.ball
	self.level = params.level

	self.recoverPoints = params.recoverPoints
	self.growPoints = params.growPoints

	self.Pup = Powerup(1)
	self.keyUp = Powerup(2)
	self.balltwo = Ball()
	self.ballthree = Ball()

	self.balltwo.skin = math.random(7)
	self.ballthree.skin = math.random(7)

	self.ball.dx = math.random(-200, 200)
	self.ball.dy = math.random(-50, -60)

	self.BallPup = false
	self.PupTimer = 0
	self.Kup = false
	self.KupTimer = 0
	self.balltwo.x = VIRTUAL_WIDTH / 2 - 2
	self.balltwo.y = VIRTUAL_HEIGHT / 2 - 2
	self.ballthree.x = VIRTUAL_WIDTH / 2 - 2
	self.ballthree.y = VIRTUAL_HEIGHT / 2 - 2

	self.balltwo.dx = math.random(-200, 200)
	self.balltwo.dy = math.random(-50, -60)
	self.ballthree.dx = math.random(-200, 200)
	self.ballthree.dy = math.random(-50, -60)
end

function PlayState:update(dt)
	for k, brick in pairs(self.bricks) do
		if brick.keyPlay then
			AllowKeyPowerUp = true
		end
	end

	if Ponce then
		self.PupTimer = self.PupTimer + dt
	else
		self.PupTimer = 0
	end

	if Konce and AllowKeyPowerUp then
		self.KupTimer = self.KupTimer + dt
	else
		self.KupTimer = 0
	end

	if self.PupTimer > PupSpawn then
		PupPlay = true
		Ponce = false
	end

	if PupPlay then
		self.Pup:update(dt)
	end

	if self.KupTimer > KPupSpawn then
		KupPlay = true
		Konce = false
	end

	if KupPlay then
		self.keyUp:update(dt)
	end

	if self.Pup:collides(self.paddle) then
		PupPlay = false
		self.BallPup = true
	end

	if self.keyUp:collides(self.paddle) then
		KupPlay = false
		self.Kup = true
	end

	if self.paused then
		if love.keyboard.wasPressed("space") then
			self.paused = false
			gSounds["pause"]:play()
		else
			return
		end
	elseif love.keyboard.wasPressed("space") then
		self.paused = true
		gSounds["pause"]:play()
		return
	end
	self.paddle:update(dt)
	self.ball:update(dt)

	if self.ball:collides(self.paddle) then
		self.ball.y = self.paddle.y - 8
		self.ball.dy = -self.ball.dy
		if self.ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
			self.ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - self.ball.x))
		elseif self.ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
			self.ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - self.ball.x))
		end

		gSounds["paddle-hit"]:play()
	end
	for k, brick in pairs(self.bricks) do
		if brick.inPlay and self.ball:collides(brick) then
			if brick.keyPlay and self.Kup then
				self.score = self.score + (brick.tier * 500 + brick.color * 25)
				brick:hit()
			elseif brick.solidPlay then
				self.score = self.score + (brick.tier * 200 + brick.color * 25)
				brick:hit()
			end
			if self.score > self.recoverPoints then
				self.health = math.min(3, self.health + 1)
				self.recoverPoints = self.recoverPoints + math.min(100000, self.recoverPoints * 2)
				gSounds["recover"]:play()
			end

			if self.score > self.growPoints then
				self.paddle.size = math.min(4, self.paddle.size + 1)
				self.paddle.width = math.min(128, self.paddle.width + 32)
				self.growPoints = self.growPoints + math.min(100000, self.growPoints * 2)
			end
			if self.ball.x + 2 < brick.x and self.ball.dx > 0 then
				self.ball.dx = -self.ball.dx
				self.ball.x = brick.x - 8
			elseif self.ball.x + 6 > brick.x + brick.width and self.ball.dx < 0 then
				self.ball.dx = -self.ball.dx
				self.ball.x = brick.x + 32
			elseif self.ball.y < brick.y then
				self.ball.dy = -self.ball.dy
				self.ball.y = brick.y - 8
			else
				self.ball.dy = -self.ball.dy
				self.ball.y = brick.y + 16
			end
			if math.abs(self.ball.dy) < 150 then
				self.ball.dy = self.ball.dy * 1.02
			end
			break
		end
	end
	if self.ball.y >= VIRTUAL_HEIGHT then
		self.health = self.health - 1
		gSounds["hurt"]:play()

		if self.health == 0 then
			self.Kup = false
			self.BallPup = false
			self.PupTimer = 0
			self.KupTimer = 0
			PupSpawn = 1
			Ponce = true
			Konce = true
			gStateMachine:change("game-over", {
				score = self.score,
				highScores = self.highScores,
			})
		else
			self.Kup = false
			self.BallPup = false
			self.PupTimer = 0
			self.KupTimer = 0
			PupSpawn = 1
			Ponce = true
			Konce = true
			self.paddle.size = math.max(1, self.paddle.size - 1)
			self.paddle.width = math.max(32, self.paddle.width - 32)
			gStateMachine:change("serve", {
				growPoints = self.growPoints,
				paddle = self.paddle,
				bricks = self.bricks,
				health = self.health,
				score = self.score,
				highScores = self.highScores,
				level = self.level,
				recoverPoints = self.recoverPoints,
			})
		end
	end
	if self.BallPup then
		self.balltwo:update(dt)
		self.ballthree:update(dt)
		if self.balltwo:collides(self.paddle) then
			self.balltwo.y = self.paddle.y - 8
			self.balltwo.dy = -self.balltwo.dy
			if self.balltwo.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
				self.balltwo.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - self.balltwo.x))
			elseif self.balltwo.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
				self.balltwo.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - self.balltwo.x))
			end

			gSounds["paddle-hit"]:play()
		end
		for k, brick in pairs(self.bricks) do
			if brick.inPlay and self.balltwo:collides(brick) then
				if brick.keyPlay and self.Kup then
					self.score = self.score + (brick.tier * 500 + brick.color * 25)
					brick:hit()
				elseif brick.solidPlay then
					self.score = self.score + (brick.tier * 200 + brick.color * 25)
					brick:hit()
				end
				if self.score > self.recoverPoints then
					self.health = math.min(3, self.health + 1)
					self.recoverPoints = self.recoverPoints + math.min(100000, self.recoverPoints * 2)
					gSounds["recover"]:play()
				end

				if self.score > self.growPoints then
					self.paddle.size = math.min(4, self.paddle.size + 1)
					self.paddle.width = math.min(128, self.paddle.width + 32)
					self.growPoints = self.growPoints + math.min(10000, self.growPoints * 2)
				end
				if self.balltwo.x + 2 < brick.x and self.balltwo.dx > 0 then
					self.balltwo.dx = -self.balltwo.dx
					self.balltwo.x = brick.x - 8
				elseif self.balltwo.x + 6 > brick.x + brick.width and self.balltwo.dx < 0 then
					self.balltwo.dx = -self.balltwo.dx
					self.balltwo.x = brick.x + 32
				elseif self.balltwo.y < brick.y then
					self.balltwo.dy = -self.balltwo.dy
					self.balltwo.y = brick.y - 8
				else
					self.balltwo.dy = -self.balltwo.dy
					self.balltwo.y = brick.y + 16
				end
				if math.abs(self.balltwo.dy) < 150 then
					self.balltwo.dy = self.balltwo.dy * 1.02
				end
				break
			end
		end

		if self.balltwo.y >= VIRTUAL_HEIGHT then
			self.health = self.health - 1
			gSounds["hurt"]:play()

			if self.health == 0 then
				self.Kup = false
				self.BallPup = false
				self.PupTimer = 0
				self.KupTimer = 0
				PupSpawn = 1
				Ponce = true
				Konce = true
				gStateMachine:change("game-over", {
					score = self.score,
					highScores = self.highScores,
				})
			else
				self.Kup = false
				self.BallPup = false
				self.PupTimer = 0
				self.KupTimer = 0
				PupSpawn = 1
				Ponce = true
				Konce = true
				self.paddle.size = math.max(1, self.paddle.size - 1)
				self.paddle.width = math.max(32, self.paddle.width - 32)
				gStateMachine:change("serve", {
					growPoints = self.growPoints,
					paddle = self.paddle,
					bricks = self.bricks,
					health = self.health,
					score = self.score,
					highScores = self.highScores,
					level = self.level,
					recoverPoints = self.recoverPoints,
				})
			end
		end
		if self.ballthree:collides(self.paddle) then
			self.ballthree.y = self.paddle.y - 8
			self.ballthree.dy = -self.ballthree.dy
			if self.ballthree.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
				self.ballthree.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - self.ballthree.x))
			elseif self.ballthree.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
				self.ballthree.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - self.ballthree.x))
			end

			gSounds["paddle-hit"]:play()
		end

		for k, brick in pairs(self.bricks) do
			if brick.inPlay and self.ballthree:collides(brick) then
				if brick.keyPlay and self.Kup then
					self.score = self.score + (brick.tier * 500 + brick.color * 25)
					brick:hit()
				elseif brick.solidPlay then
					self.score = self.score + (brick.tier * 200 + brick.color * 25)
					brick:hit()
				end

				if self.score > self.recoverPoints then
					self.health = math.min(3, self.health + 1)

					self.recoverPoints = self.recoverPoints + math.min(100000, self.recoverPoints * 2)

					gSounds["recover"]:play()
				end

				if self.score > self.growPoints then
					self.paddle.size = math.min(4, self.paddle.size + 1)
					self.paddle.width = math.min(128, self.paddle.width + 32)
					self.growPoints = self.growPoints + math.min(10000, self.growPoints * 2)
				end
				if self.ballthree.x + 2 < brick.x and self.ballthree.dx > 0 then
					self.ballthree.dx = -self.ballthree.dx
					self.ballthree.x = brick.x - 8
				elseif self.ballthree.x + 6 > brick.x + brick.width and self.ballthree.dx < 0 then
					self.ballthree.dx = -self.ballthree.dx
					self.ballthree.x = brick.x + 32
				elseif self.ballthree.y < brick.y then
					self.ballthree.dy = -self.ballthree.dy
					self.ballthree.y = brick.y - 8
				else
					self.ballthree.dy = -self.ballthree.dy
					self.ballthree.y = brick.y + 16
				end

				if math.abs(self.ballthree.dy) < 150 then
					self.ballthree.dy = self.ballthree.dy * 1.02
				end

				break
			end
		end

		if self.ballthree.y >= VIRTUAL_HEIGHT then
			self.health = self.health - 1
			gSounds["hurt"]:play()

			if self.health == 0 then
				self.BallPup = false
				self.Kup = false
				self.PupTimer = 0
				PupSpawn = 1
				Ponce = true
				Konce = true
				gStateMachine:change("game-over", {
					score = self.score,
					highScores = self.highScores,
				})
			else
				self.BallPup = false
				self.Kup = false
				self.PupTimer = 0
				self.KupTimer = 0
				PupSpawn = 1
				Ponce = true
				Konce = true
				self.paddle.size = math.max(1, self.paddle.size - 1)
				self.paddle.width = math.max(32, self.paddle.width - 32)
				gStateMachine:change("serve", {
					growPoints = self.growPoints,
					paddle = self.paddle,
					bricks = self.bricks,
					health = self.health,
					score = self.score,
					highScores = self.highScores,
					level = self.level,
					recoverPoints = self.recoverPoints,
				})
			end
		end
	end
	if self:checkVictory() then
		gSounds["victory"]:play()
		self.BallPup = false
		self.PupTimer = 0
		self.KupTimer = 0
		PupSpawn = 1
		Ponce = true
		Konce = true
		AllowKeyPowerUp = false
		gStateMachine:change("victory", {
			growPoints = self.growPoints,
			level = self.level,
			paddle = self.paddle,
			health = self.health,
			score = self.score,
			highScores = self.highScores,
			ball = self.ball,
			recoverPoints = self.recoverPoints,
		})
	end

	for k, brick in pairs(self.bricks) do
		brick:update(dt)
	end

	if love.keyboard.wasPressed("escape") then
		love.event.quit()
	end
end

function PlayState:render()
	if PupPlay then
		self.Pup:render()
	end

	if KupPlay then
		self.keyUp:render()
	end

	if self.BallPup then
		love.graphics.draw(gTextures["main"], gFrames["powerup"][(self.Pup.skin + 8)], 0, VIRTUAL_HEIGHT - 16)
	end
	if self.Kup then
		love.graphics.draw(gTextures["main"], gFrames["powerup"][(self.keyUp.skin + 8)], 16, VIRTUAL_HEIGHT - 16)
	end

	for k, brick in pairs(self.bricks) do
		brick:render()
	end

	for k, brick in pairs(self.bricks) do
		brick:renderParticles()
	end

	self.paddle:render()
	self.ball:render()

	if self.BallPup then
		self.balltwo:render()
		self.ballthree:render()
	end

	renderScore(self.score)
	renderHealth(self.health)

	if self.paused then
		love.graphics.setFont(gFonts["large"])
		love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, "center")
	end
end

function PlayState:checkVictory()
	for k, brick in pairs(self.bricks) do
		if brick.inPlay then
			return false
		end
	end

	self.BallPup = false
	return true
end
