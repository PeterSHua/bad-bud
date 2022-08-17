function copyGameDetails() {
  const gameDateSpan = document.querySelector("#gameDate");
  const gameDate = gameDateSpan.textContent;

  const gameTimeSpan = document.querySelector("#gameTime");
  const gameTime = gameTimeSpan.textContent;

  const gameLocationSpan = document.querySelector("#gameLocation");
  const gameLocation = gameLocationSpan.textContent;

  const gameLevelSpan = document.querySelector("#gameLevel");
  const gameLevel = gameLevelSpan.textContent;

  const gameSlotsSpan = document.querySelector("#gameSlots");
  const gameSlots = gameSlotsSpan.textContent;

  const gameFeeSpan = document.querySelector("#gameFee");
  const gameFee = gameFeeSpan.textContent;

  const gameURL = window.location.href

  const gameDetails = `${gameDate}\n${gameTime}\n${gameLocation}\n${gameLevel}\n${gameSlots}\n${gameFee}\nSignup: ${gameURL}`

  navigator.clipboard
    .writeText(gameDetails)
    .then(() => {
      alert("Copied to clipboard");
    });
}
