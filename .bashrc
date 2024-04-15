# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi
# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1) /'
}

PS1="\[\e[01;32m\]\u@\h\[\e[00m\]:\[\e[01;96m\]\W\[\e[00m\]\$ "

odoo_host='8996239@pegasuscontrol-pruebas-valentin-8996239.dev.odoo.com'
alias odoo-server="ssh $odoo_host"
#actualizar modulo
alias odoo-update="odoo-server odoo-bin -u"

odoo-logs () {
	while true; do
		odoo-server tail -f logs/odoo.log
	done
}

odoo-sync() {
	# syncronize pegasus-control folders with odoo-server using rsync.
	# Detects automatically if it is being working on a module and
	# sync only that module, otherwise it will sync everything
	
	_src=/home/voreapc/Documentos/odoo/addons/
	_dest=/home/odoo/src/user

	# check the CWD
	case $PWD/ in
		$_src*) 
			# this will run if the CWD is somewhere inside the source
			# _inner_path is everything after the source path
			_inner_path=${PWD##*"${_src}"}
			# _module_name is exactly the path after the source path, everything
			# after the first / will be ignored
			_module_name=${_inner_path%%'/'*}
			;;
		*) 
			;;
	esac

	# if $_module_name is not empty, update the source and destination
	# paths
	if [[ -n $_module_name ]]; then
		_src="$_src$_module_name/"
		_dest+="/$_module_name"
	fi

	echo "[SYNCHRONIZING...]"
	echo "$_src -> (remote) $_dest"
	rsync $_src $odoo_host:$_dest -r --exclude='.git/*' --exclude='UML/*'
	echo "[DONE]"

	# if there is a module, update it
	if [[ -n $_module_name ]]; then
		echo "[UPDATING MODULE...]"
		odoo-update $_module_name
		echo "[DONE]"
	fi
}

