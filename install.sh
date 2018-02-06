# NOTE: This script assumes that the dotfiles repo is checked out as:
#  ~/dotfiles/
# You can change this by modifying the REPO_LOCATION variable.

REPO_LOCATION=~/dotfiles

for i in bash.d bash_logout bashrc inputrc profile pythonrc.py screenrc vim vimrc
do
	if [ -e ~/.${i} ]; then
		mv ~/.${i} ~/.${i}.orig
	fi
	ln -s ${REPO_LOCATION}/${i} ~/.${i}
done
