function prompt_pwd --description 'Print the current working directory, shortened to fit the prompt'
	set -l args_post
    set -l args_pre
    set -l realhome ~
    echo $PWD | sed -e "s|^$realhome|~|" $args_pre
end
