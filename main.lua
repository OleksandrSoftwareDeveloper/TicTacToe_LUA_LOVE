GameState =
{
    PLAYER_TURN = "Your turn",
    NOT_PLAYER_TURN = "Wait for your turn",
    GAME_FINISHED = "Game finished"
}

GameResultOutput =
{
    DRAW = "Draw!",
    PLAYER_VICTORY = "You won!",
    PLAYER_DEFEAT = "You lost!"
}

FieldState =
{
    EMPTY = 1,
    CAPTURED_BY_PLAYER = 2,
    CAPTURED_BY_BOT = 3
}

MouseButton =
{
    LEFT = 1,
    RIGHT = 2,
    MIDDLE = 3
}

PathToImage =
{
    FIELD_BACKGROUND = "square.png",
    CAPTURED_BY_PLAYER_SIGN = "cross.png",
    CAPTURED_BY_BOT_SIGN = "zero.png",
    BUTTON_BACKGROUND = "buttonBackground.png"
}

local fieldBackgroundImage, capturedByPlayerSignImage, capturedByBotSignImage
local fieldBackgrounds, playerSigns, botSigns

local fieldBackgroundSize
local gridRowsQuantity
local spacingBetweenFields
local leftCornerFieldPositionX
local leftCornerFieldPositionY
local currentGameState
local gameResult

local fadingSpeed
local isHighlightingSquareNow
local currentHighlightedFieldRowIndex
local currentHighlightedFieldColumnIndex
local currentTransparencyOfHighlightedField

local colorOfWinningLineR
local colorOfWinningLineG
local colorOfWinningLineB

local fontForHeaderText
local sizeOfHeaderText

local playAgainButton

function love.load()
    math.randomseed(os.time())
    fieldBackgrounds, playerSigns, botSigns = {}, {}, {}
    fieldBackgroundSize = 100
    gridRowsQuantity = 3
    spacingBetweenFields = 5
    leftCornerFieldPositionX = 145
    leftCornerFieldPositionY = 145
    currentGameState = GameState.PLAYER_TURN
    fadingSpeed = 1
    isHighlightingSquareNow = false
    currentTransparencyOfHighlightedField = 0
    colorOfWinningLineR = 0.43
    colorOfWinningLineG = 1
    colorOfWinningLineB = 0.63
    sizeOfHeaderText = 40
    playAgainButton = {}
    playAgainButton.x = 200
    playAgainButton.y = 500
    playAgainButton.width = 200
    playAgainButton.height = 50
    playAgainButton.text = "PLAY AGAIN"
    playAgainButton.fontSize = 20
    playAgainButton.textColorR = 0
    playAgainButton.textColorG = 0
    playAgainButton.textColorB = 0
    fontForHeaderText = love.graphics.newFont(sizeOfHeaderText)
    playAgainButton.font = love.graphics.newFont(playAgainButton.fontSize)
    fieldBackgroundImage = love.graphics.newImage(PathToImage.FIELD_BACKGROUND)
    capturedByPlayerSignImage = love.graphics.newImage(PathToImage.CAPTURED_BY_PLAYER_SIGN)
    capturedByBotSignImage = love.graphics.newImage(PathToImage.CAPTURED_BY_BOT_SIGN)
    playAgainButton.image = love.graphics.newImage(PathToImage.BUTTON_BACKGROUND)
    for rowIndex = 1, gridRowsQuantity
    do
        fieldBackgrounds[rowIndex] = {}
        playerSigns[rowIndex] = {}
        botSigns[rowIndex] = {}
        for columnIndex = 1, gridRowsQuantity
        do
            local x = leftCornerFieldPositionX + (columnIndex - 1) * (fieldBackgroundSize + spacingBetweenFields)
            local y = leftCornerFieldPositionY + (rowIndex - 1) * (fieldBackgroundSize + spacingBetweenFields)
            table.insert(fieldBackgrounds[rowIndex], {x = x, y = y, width = fieldBackgroundSize, height = fieldBackgroundSize, fieldState = FieldState.EMPTY, isInWinningLine = false})
            table.insert(playerSigns[rowIndex], {})
            table.insert(botSigns[rowIndex], {})
        end
    end
end

function love.draw()
    for rowIndex = 1, gridRowsQuantity
    do
        for columnIndex = 1, gridRowsQuantity
        do
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(fieldBackgroundImage, fieldBackgrounds[rowIndex][columnIndex].x, fieldBackgrounds[rowIndex][columnIndex].y, 0, fieldBackgroundSize / fieldBackgroundImage:getWidth(), fieldBackgroundSize / fieldBackgroundImage:getHeight())
            if isHighlightingSquareNow and rowIndex == currentHighlightedFieldRowIndex and columnIndex == currentHighlightedFieldColumnIndex
            then
                love.graphics.setColor(1, 1, 1, currentTransparencyOfHighlightedField)
                if fieldBackgrounds[rowIndex][columnIndex].fieldState == FieldState.CAPTURED_BY_PLAYER
                then
                    love.graphics.draw(capturedByPlayerSignImage, fieldBackgrounds[rowIndex][columnIndex].x, fieldBackgrounds[rowIndex][columnIndex].y, 0, fieldBackgroundSize / fieldBackgroundImage:getWidth(), fieldBackgroundSize / fieldBackgroundImage:getHeight())
                else
                    love.graphics.draw(capturedByBotSignImage, fieldBackgrounds[rowIndex][columnIndex].x, fieldBackgrounds[rowIndex][columnIndex].y, 0, fieldBackgroundSize / fieldBackgroundImage:getWidth(), fieldBackgroundSize / fieldBackgroundImage:getHeight())
                end
            else
                if not fieldBackgrounds[rowIndex][columnIndex].isInWinningLine
                then
                    love.graphics.setColor(1, 1, 1, 1)
                else
                    love.graphics.setColor(colorOfWinningLineR, colorOfWinningLineG, colorOfWinningLineB, 1)
                end
                if fieldBackgrounds[rowIndex][columnIndex].fieldState == FieldState.CAPTURED_BY_PLAYER
                then
                    love.graphics.draw(capturedByPlayerSignImage, fieldBackgrounds[rowIndex][columnIndex].x, fieldBackgrounds[rowIndex][columnIndex].y, 0, fieldBackgroundSize / fieldBackgroundImage:getWidth(), fieldBackgroundSize / fieldBackgroundImage:getHeight())
                elseif fieldBackgrounds[rowIndex][columnIndex].fieldState == FieldState.CAPTURED_BY_BOT
                then
                    love.graphics.draw(capturedByBotSignImage, fieldBackgrounds[rowIndex][columnIndex].x, fieldBackgrounds[rowIndex][columnIndex].y, 0, fieldBackgroundSize / fieldBackgroundImage:getWidth(), fieldBackgroundSize / fieldBackgroundImage:getHeight())
                end
            end
        end
    end
    love.graphics.setFont(fontForHeaderText)
    love.graphics.setColor(1, 1, 1, 1)
    if currentGameState == GameState.GAME_FINISHED
    then
        love.graphics.printf(gameResult, 50, 50, 500, "center")
        love.graphics.draw(playAgainButton.image, playAgainButton.x, playAgainButton.y, 0, playAgainButton.width / playAgainButton.image:getWidth(), playAgainButton.height / playAgainButton.image:getHeight())
        love.graphics.setFont(playAgainButton.font)
        love.graphics.setColor(playAgainButton.textColorR, playAgainButton.textColorG, playAgainButton.textColorB)
        love.graphics.printf(playAgainButton.text, playAgainButton.x, playAgainButton.y + (playAgainButton.height / 2) - playAgainButton.fontSize / 2, playAgainButton.width, "center")
    else
        love.graphics.printf(currentGameState, 50, 50, 500, "center")
    end
end

function love.update(dt)
    if isHighlightingSquareNow
    then
        currentTransparencyOfHighlightedField = currentTransparencyOfHighlightedField + dt * fadingSpeed
        if currentTransparencyOfHighlightedField >= 1
        then
            isHighlightingSquareNow = false
            local coordinatesOfFieldsOfWinningLine = {}
            for columnIndex = 1, gridRowsQuantity
            do
                local isThisLineWinning = true
                for rowIndex = 2, gridRowsQuantity
                do
                    if fieldBackgrounds[rowIndex - 1][columnIndex].fieldState ~= fieldBackgrounds[rowIndex][columnIndex].fieldState or fieldBackgrounds[rowIndex][columnIndex].fieldState == FieldState.EMPTY
                    then
                        isThisLineWinning = false
                        break
                    end
                end
                if isThisLineWinning
                then
                    for rowIndex = 1, gridRowsQuantity
                    do
                        coordinatesOfFieldsOfWinningLine[rowIndex] = {rowIndex, columnIndex}
                    end
                    break
                end
            end
            if #coordinatesOfFieldsOfWinningLine == 0
            then
                for rowIndex = 1, gridRowsQuantity
                do
                    local isThisLineWinning = true
                    for columnIndex = 2, gridRowsQuantity
                    do
                        if fieldBackgrounds[rowIndex][columnIndex - 1].fieldState ~= fieldBackgrounds[rowIndex][columnIndex].fieldState or fieldBackgrounds[rowIndex][columnIndex].fieldState == FieldState.EMPTY
                        then
                            isThisLineWinning = false
                            break
                        end
                    end
                    if isThisLineWinning
                    then
                        for columnIndex = 1, gridRowsQuantity
                        do
                            coordinatesOfFieldsOfWinningLine[columnIndex] = {rowIndex, columnIndex}
                        end
                        break
                    end
                end
            end
            if #coordinatesOfFieldsOfWinningLine == 0
            then
                local isThisLineWinning = true
                for indexInPrincipalDiagonal = 2, gridRowsQuantity
                do
                    if fieldBackgrounds[indexInPrincipalDiagonal - 1][indexInPrincipalDiagonal - 1].fieldState ~= fieldBackgrounds[indexInPrincipalDiagonal][indexInPrincipalDiagonal].fieldState or fieldBackgrounds[indexInPrincipalDiagonal][indexInPrincipalDiagonal].fieldState == FieldState.EMPTY
                    then
                        isThisLineWinning = false
                        break
                    end
                end
                if isThisLineWinning
                then
                    for indexInPrincipalDiagonal = 1, gridRowsQuantity
                    do
                        coordinatesOfFieldsOfWinningLine[indexInPrincipalDiagonal] = {indexInPrincipalDiagonal, indexInPrincipalDiagonal}
                    end
                end
            end
            if #coordinatesOfFieldsOfWinningLine == 0
            then
                local isThisLineWinning = true
                for indexInSecondaryDiagonal = 2, gridRowsQuantity
                do
                    if fieldBackgrounds[indexInSecondaryDiagonal - 1][gridRowsQuantity - indexInSecondaryDiagonal + 2].fieldState ~= fieldBackgrounds[indexInSecondaryDiagonal][gridRowsQuantity - indexInSecondaryDiagonal + 1].fieldState or fieldBackgrounds[indexInSecondaryDiagonal][gridRowsQuantity - indexInSecondaryDiagonal + 1].fieldState == FieldState.EMPTY
                    then
                        isThisLineWinning = false
                        break
                    end
                end
                if isThisLineWinning
                then
                    for indexInSecondaryDiagonal = 1, gridRowsQuantity
                    do
                        coordinatesOfFieldsOfWinningLine[indexInSecondaryDiagonal] = {indexInSecondaryDiagonal, gridRowsQuantity - indexInSecondaryDiagonal + 1}
                    end
                end
            end
            for i = 1, #coordinatesOfFieldsOfWinningLine
            do
                fieldBackgrounds[coordinatesOfFieldsOfWinningLine[i][1]][coordinatesOfFieldsOfWinningLine[i][2]].isInWinningLine = true
            end
            if #coordinatesOfFieldsOfWinningLine ~= 0
            then
                local result
                if fieldBackgrounds[coordinatesOfFieldsOfWinningLine[1][1]][coordinatesOfFieldsOfWinningLine[1][2]].fieldState == FieldState.CAPTURED_BY_PLAYER
                then
                    result = GameResultOutput.PLAYER_VICTORY
                else
                    result = GameResultOutput.PLAYER_DEFEAT
                end
                finishGame(result)
            else
                local allEmptyFieldsCoordinates = getAllEmptyFieldsCoordinates()
                if #allEmptyFieldsCoordinates == 0
                then
                    finishGame(GameResultOutput.DRAW)
                elseif fieldBackgrounds[currentHighlightedFieldRowIndex][currentHighlightedFieldColumnIndex].fieldState == FieldState.CAPTURED_BY_PLAYER
                then
                    captureRandomEmptyFieldByBot(allEmptyFieldsCoordinates)
                else
                    currentGameState = GameState.PLAYER_TURN
                end
            end
        end
    end
end

function captureField(rowIndex, columnIndex, newFieldState)
    if fieldBackgrounds[rowIndex][columnIndex].fieldState == FieldState.EMPTY
    then
        currentGameState = GameState.NOT_PLAYER_TURN
        fieldBackgrounds[rowIndex][columnIndex].fieldState = newFieldState
        isHighlightingSquareNow = true
        currentHighlightedFieldRowIndex = rowIndex
        currentHighlightedFieldColumnIndex = columnIndex
        currentTransparencyOfHighlightedField = 0
    end
end

function love.mousepressed(x, y, mouseButton, isTouch, presses)
    if mouseButton == MouseButton.LEFT
    then
        if currentGameState == GameState.PLAYER_TURN
        then
            for rowIndex = 1, gridRowsQuantity
            do
                for columnIndex = 1, gridRowsQuantity
                do
                    if x > fieldBackgrounds[rowIndex][columnIndex].x and x < fieldBackgrounds[rowIndex][columnIndex].x + fieldBackgrounds[rowIndex][columnIndex].width and y > fieldBackgrounds[rowIndex][columnIndex].y and y < fieldBackgrounds[rowIndex][columnIndex].y + fieldBackgrounds[rowIndex][columnIndex].height
                    then
                        captureField(rowIndex, columnIndex, FieldState.CAPTURED_BY_PLAYER)
                    end
                end
            end
        elseif currentGameState == GameState.GAME_FINISHED
        then
            if x > playAgainButton.x and x < playAgainButton.x + playAgainButton.width and y > playAgainButton.y and y < playAgainButton.y + playAgainButton.height
            then
                love.load()
            end
        end
    end
end

function finishGame(result)
    currentGameState = GameState.GAME_FINISHED
    gameResult = result
end

function getAllEmptyFieldsCoordinates()
    local allEmptyFields = {}
    for rowIndex = 1, gridRowsQuantity
    do
        for columnIndex = 1, gridRowsQuantity
        do
            if fieldBackgrounds[rowIndex][columnIndex].fieldState == FieldState.EMPTY
            then
                table.insert(allEmptyFields, {rowIndex = rowIndex, columnIndex = columnIndex})
            end
        end
    end
    return allEmptyFields
end

function captureRandomEmptyFieldByBot(emptyFieldsCoordinates)
    local indexOfCoordinatesOfFieldToBeCaptured = math.random(1, #emptyFieldsCoordinates)
    captureField(emptyFieldsCoordinates[indexOfCoordinatesOfFieldToBeCaptured].rowIndex, emptyFieldsCoordinates[indexOfCoordinatesOfFieldToBeCaptured].columnIndex, FieldState.CAPTURED_BY_BOT)
end