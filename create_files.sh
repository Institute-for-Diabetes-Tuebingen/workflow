#!/bin/bash

create_rmarkdown_script() {
    # if [ "$rmarkdown_flag" = true ]; then
    #     rmd_file="./analysis/${markdown_name:-script}.Rmd"
        cat <<EOF > "$rmd_file"
---
title: "$project_name"
author: ""
date: \`r format(Sys.time(), "%d %B, %Y")\`
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
knitr::opts_hooks$set(eval = function(options) {
  if (options$engine == "bash") {
    options$eval <- FALSE
    options$class.source = 'fold-show'
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
