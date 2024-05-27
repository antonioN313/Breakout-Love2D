PlayState = Class{__includes = BaseState}

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
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
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

        gSounds['paddle-hit']:play()
    end

    for k,brick in pairs(self.bricks) do

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

                gSounds['recover']:play()
            end

            if self.score > self.growPoints then
              self.paddle.size = math.min(4, self.paddle.size + 1)
              self.paddle.width = math.min(128, self.paddle.width + 32)
              self.growPoints = self.growPoints + math.min(100000, self.growPoints * 2)
            end
            
            if self:checkVictory() then
                gSounds['victory']:play()

                gStateMachine:change('victory',{
                    level = self.level,
                    paddle = self.paddle,
                    health = self.health,
                    score = self.score,
                    highScores = self.highScores,
                    ball = self.ball
                })
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
            self.ball.dy = self.ball.dy * 1.02
            break
        end
    end

    if self.ball.y >= VIRTUAL_HEIGHT then
        self.health = self.health - 1
        gSounds['hurt']:play()

        if self.health == 0 then
            gStateMachine:change('game-over', {
                score = self.score,
                highScores = self.highScores
            })
        else
            gStateMachine:change('serve', {
                paddle = self.paddle,
                bricks = self.bricks,
                health = self.health,
                score = self.score,
                highScores = self.highScores,
                level = self.level
            })
        end
    end

    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()

    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    self.paddle:render()
    self.ball:render()

    renderScore(self.score)
    renderHealth(self.health)
    
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end

end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end 
    end

    return true
end