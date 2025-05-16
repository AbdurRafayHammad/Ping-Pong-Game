🕹️ Ping Pong Game in NASM Assembly
Welcome to the classic Ping Pong game, built from scratch using NASM x86 Assembly Language for real-mode DOS with BIOS interrupts for pixel-level graphics. This project demonstrates how low-level programming can be used to create interactive games with fundamental logic and rendering.

🎮 Features
Player-vs-Player mode with controls for both left and right paddles.

Ball movement with realistic bouncing and scoring system.

Simple collision detection with game restart or exit option.

Real-time screen rendering using INT 10h BIOS interrupts.

Classic 320x200 256-color Mode 13h graphics.

⌨️ Controls
Left Paddle:

Move Up: W or w

Move Down: S or s

Right Paddle:

Move Up: ↑ (Up Arrow)

Move Down: ↓ (Down Arrow)

🧠 How to Run
Install DOSBox

Mount your project directory

Compile and run using NASM and a compatible linker (e.g., TASM or Turbo Linker)

🏁 How to Play
First player to score 5 points wins.

After a win, press Y to restart or N to exit the game.
