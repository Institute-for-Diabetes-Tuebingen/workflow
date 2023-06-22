#!/bin/bash

show_help() {
echo "----------------------------------------------------------------------------------------------------------------------

    Usage: workflow [options]

    Options:

    -h, --help         Display this help message
    -r, --rmarkdown    Create a new R Markdown
                       Usage: workflow -r
                       ["name"] to give custom name. Defaults to Script.Rmd.
    -p, --publish      Knits markdowns to the publication folder. Also takes ["name"] 
                       if you only want one specific markdown knitted. 
                       Additionally checks for html files (when you knitted from e.g. RStudio files are 
                       automatically stored in the same folder as the markdown) and associated figure folders 
                       and moves them.
-----------------------------------------------------------------------------------------------------------------------
"
}

execute_in_workflow_project() {
    # Get the current directory
    current_dir=$(pwd)

    # Start searching from the current directory
    search_dir="$current_dir"

    # Flag to track whether the "output" folder is found
    found_output_folder=false

    # Loop until the root directory is reached
    while [ "$search_dir" != "/" ]; do
        # Check if "output" folder exists in the current directory
        if [ -d "$search_dir/output" ]; then
            found_output_folder=true
          
            # Execute the provided function within the workflow project directory
            "$@"
            break
        else
            # Move one level up
            search_dir=$(dirname "$search_dir")
        fi
    done

    if [ "$found_output_folder" = false ]; then
        echo "You are not in any workflow project! Please make sure you are in a project directory."
    fi
}

publish_html() {
    source_directory="$search_dir/analysis"
    target_folder=""

    # Check if the "docs" folder exists
    if [ -d "$search_dir/docs" ]; then
        target_folder="$search_dir/docs"
    # Check if the "public" folder exists
    elif [ -d "$search_dir/public" ]; then
        target_folder="$search_dir/public"
    fi

    # Knit the document(s) based on the flags
    if [ -n "$public_name" ]; then
        # Knit a specific public document
        Rscript -e "rmarkdown::render('$source_directory/$public_name.Rmd', output_file = '$target_folder/$public_name.html')"
    else
        # Knit all public .Rmd documents
        for file in "$source_directory"/*.Rmd; do
            base_name=$(basename "$file" .Rmd)
            Rscript -e "rmarkdown::render('$file', output_file = '$target_folder/$base_name.html')"
        done
    fi

    if ls "$source_directory"/*.html &> /dev/null; then
        html_files=$(find "$source_directory" -type f -name "*.html")
        echo "$html_files"
        # Move all HTML files to the target folder
        mv "$source_directory"/*.html "$target_folder/"
        echo "HTML files moved to '$target_folder/'."

        # Search for folders with the same base name as HTML files
        for file in $html_files; do
            folder_name=$(basename "$file" .html)

            if [ -d "$source_directory/$folder_name" ]; then
                mv "$source_directory/$folder_name" "$search_dir/figures/"
                echo "Folder '$folder_name' moved to '$search_dir/figures/'."
            fi
        done
    else
        echo "No HTML files to move."
    fi

    
}

if [ "$found_output_folder" = false ]; then
    echo "You are not in any workflow project! Please make sure you are in a project directory."
fi


create_rmarkdown_script() {

rmd_file="$search_dir/analysis/${markdown_name:-script}.Rmd"

name=`git config --global user.name`

        cat <<EOF > "$rmd_file"
---
title: "$markdown_name"
author: "$name"
date: '\`r format(Sys.time(), "%d %B, %Y")\`'
output:
  html_document:
    toc: true
    toc_depth: 2
    code_folding: "hide"
    toc_float: true
    fig_width: 10
    keep_md: true
editor_options:
  chunk_output_type: console
---
\`\`\`{r include=FALSE, message=FALSE}
knitr::opts_chunk\$set(echo = TRUE)
knitr::opts_chunk\$set(error = TRUE)
knitr::opts_chunk\$set(message = FALSE)
knitr::opts_chunk\$set(warning = FALSE)
knitr::opts_chunk\$set(results = 'asis')
# this function automatically formats bash chunks so they don't run, but are shown.
knitr::opts_hooks\$set(eval = function(options) {
  if (options\$engine == "bash") {
    options\$eval <- FALSE
    options\$class.source = 'fold-show'
  }
  options
})

\`\`\`
EOF

        echo "R Markdown script created."
    
}


create_yaml(){

    #create yaml file in /analysis
    echo "name: \"$project_name\"
    output_dir: ../$outdir
    navbar:
      title: \"$project_name\"
      left:
      - text: Home
        href: index.html
      - text: About
        href: about.html
      - text: License
        href: license.html
    output:
    html_document:
        toc: yes
        toc_float: yes
        theme: cosmo
        highlight: textmate" > ./analysis/_site.yaml
}

create_yml_lab(){ 
  echo "pages:
  stage: deploy
  script:
    - echo 'Nothing to do...'
  artifacts:
    paths:
      - public
  only:
    - main" > .gitlab-ci.yml

}

setup_git(){
    
    # Clone Git repository
    git init

    # Create .gitignore file and add data + output folders
    echo "data/" > .gitignore
    echo "output/" >> .gitignore
    echo "figures/" >> .gitignore

    # Commit and push .gitignore
    git add .gitignore
    git commit -m "Add .gitignore"
    git remote add origin $repository_url
    git push 
}

create_index(){

echo "---
author: "Marlene Ganslmeier"
output:
  html_document:
      toc: false
editor_options:
  chunk_output_type: console
---

## **Welcome!**

- [Name](link.html)" > ./analysis/index.Rmd
}
