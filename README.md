# Artificial-Evolutionary-Life-Simulation

As a computer science major & cognitive science minor, I'm super interested in the field of Artificial Life, because it combines computer and cognitive science. Artificial Life can be biochemical-based, hardware-based, and software-based. My Artificial Evolutionary Life Simulation falls into the software category and is a form of cellular automata. I made this simulation to 1. gain experience in developing the logic behind cellular automata (simple rules lead to complex outcomes), 2. learn to code simulations that can be viewed and experienced by users, and 3. see if I can watch my artificial life evolve in interesting ways! 

Rick's Artificial Evolutionary Life Simulation is a simulation where creatures reproduce and evolve over time. For these creatures, evolutionary actions determine survival. The simulation is broken up into 4 files that house code for roughly 4 main parts of the simulation: the cell class, the map class, the creature class, and a simulation file that has multiple crucial classes and methods.  

The main features of this simulation are below. I won't go into too much detail, as I would say watching the simulation is the best way to understand how it works:
- lots of creatures moving around, eating, dying, reproducing, and mutating.
  - creatures move around on land and water depending on specific genes like land speed, water speed, and turn speeds (how quickly or not they turn towards specific terrain).
  - creatures can eat fruit and seaweed, and they will gain differing amounts of energy depending on their mutations.
  - creatures die if they run out of energy, which is possible because they lose energy by moving around (they don't stop moving) and hitting poison.
  - creatures reproduce asexually if they gain enough energy and they haven't given birth in a minute.
  - creatures' genes are mutated when "born", allowing for evolution. 
- distribution of water & land (multiple land and water biomes).
- two types of food: fruit and seaweed (food has scent that creatures can evolve to "like" or "dislike"), and poison causes them to take damage (decreased energy).
  - creatures' preference and energy levels for fruit and seaweed will mutate, and their "immunity" to poison should mutate as well. 
- creatures have 2 sensing organs (eyes/antennas) that they can navigate the terrain with. These can mutate, along with a few more "genes" I will explain below.
- interesting and nuanced maps that have a central island and surrounding water. This is made using Perlin Noise functions and some math.

To navigate the simulation, I've added: 
- zoom in/out, with limits so the user doesn't clip through the map. 
- stats: population size, map land/water ratio shown in the window.
- the ability to pause/play the simulation to get a better look at some bizzarre looking creatures. 

Potential Add ons:
- epistasis: change the simulation such that particular gene values can’t be measured by itself, evolutionary value depends on multiple other values.
- modeling sight instead of feel: eyes instead of antennas (very hard apparently).
- creatures being able to sense/see each other and interact. 
- sexual reproduction (comes with above).
- potentially separating health and energy into two different values. 
- Add the ability for users to view each creature's gene stats to see what kind of creatures survive.
