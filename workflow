#!/bin/bash

#source all functions
source ~/workflow/aux.sh

# define flag variables
rmarkdown_flag=false
markdown_name=""
public_flag=false
public_name=""


# Parse command-line options
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--version)
            show_version
            exit 0
            ;;
        -r|--rmarkdown)
            rmarkdown_flag=true
            shift
            if [[ $# -gt 0 && ! $1 =~ ^-[^-] ]]; then
                markdown_name="$1"
                shift
            fi
            ;;
       -p|--public)
            public_flag=true
            shift
            if [[ $# -gt 0 && ! $1 =~ ^-[^-] ]]; then
                public_name="$1"
                shift
            fi
            ;;
        *)
            # Unknown option
            shift
            ;;
    esac
done


# Initialize Git repository and perform Git operations if the flag is not set
if [ "$rmarkdown_flag" != true ] && [ "$public_flag" != true ]; then
        

    # Ask for user input
    read -p "Enter the name of the project: " project_name
    read -p "Enter the URL of the repository: " repository_url

    mkdir $project_name
    cd $project_name
    mkdir output data scripts analysis figures

    if echo "$repository_url" | grep -q "gitlab"; then
       mkdir public
       outdir="public"
       create_yml_lab
       setup_gitlab
    else
        mkdir docs
        outdir="docs"
        setup_github
    fi

    # sets up the git repository and pushes the first files
    #setup_git
    #this file specifies the layout of the rmarkdown situation
    create_yaml
    create_index

    
    echo "Git repository setup completed."
    echo "Project setup completed."
    

fi

##########################
# Create R Markdown script if the flag is set
##########################
if [ "$rmarkdown_flag" = true ]; then
    execute_in_workflow_project create_rmarkdown_script
fi      

##########################
# Move all html documents#
##########################
if [ "$public_flag" == true ]; then
    execute_in_workflow_project publish_html
fi