Overview of Pillars and Achievements: We chose NPC AI/Behavior Trees and Collision Detection. Each NPC has its own unique behavior, AI, and attacks. Collision Detection is omnipresent via attacking/being attacked by the NPCs, and of course there is collision detection on the map itself so that the player can traverse the game. Another notable achievement is that all art and assets were drawn by a member of the group (nothing was taken from online or generated).

Play Test Resolution: We took into account everything that was said in our playtest. We updated the hp bar, updated the enemy attack cooldown, and lowered the difficulty of certain sections of the map. Also addded the swimming animations. 

Technical Post-Mortem:
Biggest architectural or engineering challenges we faced: 
Implementing NPCs was the hardest. From timing the attack frames and the code to actually kill the player, to getting collision boxes just right, the NPCs were definitly the hardest to implement. We intially struggled with getting the ghost mob to actually shoot at the player, and some mobs simply weren't damageable even though we had implemented it.

Any Pivot or cut major features:
At first we wanted multiple levels, but at the end we ended up having one big traversable map similar to Hollow Knight. We had also wanted to implement NPCs in the water level, but we ended up cutting this due to time constraints. 

Reflection of AI tool uses: AI was useful when it came to actually learning how to use GODOT, and learning how each node interacts with eachother. Without it, there definetly would have been a steeper learning curve which would have prolong certain features in the game. 