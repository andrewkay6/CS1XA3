# Apple Attack!




Apple Attack is an elm game in which you dodge enemies and collect apples. As you increase your apple count/score, more enemies spawn.


# Instructions:
1. SSH into the McMaster 1XA3 server @ max1xa3.ca from the command line (terminal for MacOS/Linux, powershell for Windows).
2. cd into the Project03 folder (cd CS1XA3/Project03)
3. Activate the python virtual environment
4. Enter the command "source bin/activate" and your command line should be preceeded by (python_env) ((python_env)~/CS1XA3/Project03/)
5. Return to the previous directory with (cd .. ) (you should be in ~/CS1XA3/Project03/)
6. cd into the django project folder (cd django_project)
7. Enter the command "python3 manage.py localhost:10028" to run the server.
NOTE: The port (10028) is important, otherwise you might interfere with the projects of other users on the server.
8. Open your web browser and go to https://mac1xa3.ca/u/kaya6/project3.html
9. Once you're finished, quit the server with Ctrl + C and deactivate the environment with deactivate.


# Features
Currently the game isn't fully finished but some features have been implemented:

- Elm/Client Side: GraphicsSVG for basic shapes, collision detection for the enemy circles against the wall, collision detection for the player with the enemy class (lose screen WIP). HTML implementation for the login/register screen.
- Server side: HTTP post requests, login authentication, user registration, data storage on database with SQL (stores usernames and passwords for authentication).   

# Game Instructions
The game is still a work in progress:

- Use the arrow keys to control the green circle (player character)
- Collect the apples (red circles) to increase your score significantly  
- Avoid the increasing amount of blue circles in order to stay alive.


# References
https://github.com/NotAProfDalves/elm_django_examples

http://www.learningaboutelectronics.com/Articles/How-to-sort-a-database-table-by-column-with-Python-in-Django.php

https://guide.elm-lang.org/effects/random.html

https://getbootstrap.com/docs/4.3/getting-started/introduction/

https://gist.github.com/coreytrampe/a120fac4959db7852c0f
https://package.elm-lang.org/packages/MacCASOutreach/graphicsvg/latest/
