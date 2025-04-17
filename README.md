# AstroWorld

# Team Members
- Megan Shean (NetID: mes139)
- Teddy Nahoum (NetID: tn129)
- Nelly Garces (NetID: nfg4)

# GitHub Repository
https://github.com/nellygarces/AstroWorld.git

# Game Pitch
AstroWorld is a fast-paced, single-player arcade game where you play as an astronaut named Suni (inspired by Suni Williams), who is free-falling back to Earth after a space mission gone wrong. Dodge asteroid debris, collect gold stars, and survive a timed descent through space, the atmosphere, and sky before making a safe landing back home.

# How to Play
- Arrow Keys: Move the astronaut (Suni) left/right
- X Key: Use thrusters (5 uses per run)
- Collect 50 gold stars by going over them to win
- Avoid asteroid obstacles (3 lives per run)
- Collecting hourglasses triggers a temporary slow-mo
- Goal: Reach Earth safely with 50 stars collected before the 1 minute and 20 second hidden timer runs out.

# Amount & Type of Content Available
- Full game loop with dynamic win/fail states
- 3 environmental layers: space (0–25 sec), the atmosphere (25–50 sec), and sky (50–80 sec)
- A thruster-based movement mechanic with 5 fuel limits
- A slow-motion power-up mechanic (collecting hourglasses)
- Star pickup system with sound effects and a UI counter system
- Endgame condition: house-on-Earth scene if 50 stars are collected within 1 minute and 20 seconds
- Invincibility frames after collisions and 3-lives per run
- Start screen tutorial and interactive game loop
- Intentional game design and UX/UI choices to maintain a retro arcade feel, including pixel art sprites, nostalgic sound effects, and a clean display of game information (thrusters, stars, lives) at the top of the screen

# Lessons Learned
Throughout the development of AstroWorld, our team learned how to translate a narrative idea into interactive mechanics using Lua in the Pico-8 environment and expanding from our Pico-8 skills used earlier in this class. We learned how to build UI overlays, implement power-up logic, and dynamically transition between game states. We also practiced effective debugging and coding collaberation by refinding our mechanics to create an "arcade experience." We also made intentional design choices to preserve the retro aesthetic of the game, even if it meant scaling back or simplifying more modern features we initially considered. We learned the importance of polished background transitions, sound cues, and win screens to elevate a simple prototype into a playable, engaging game.
