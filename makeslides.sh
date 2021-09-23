# Script that copies selected output into final figures

# To make script executable: chmod a+x Dropbox/Projects/Algorithms/copyfigures.sh

printf "\nMaking slides...\n\n"

# Move to directory
cd Dropbox/Projects/Empirical-io/

# Convert slides
jupyter nbconvert 6_single_agent_dynamics.ipynb --to slides

# Terminate
exit
