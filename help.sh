show_help() {
echo "---------------------------------------------------------------------------------------------------------------------------------------------------

    Usage: workflow [options]

    Options:

    -h, --help         Display this help message
    -r, --rmarkdown    Create a new R Markdown
                       Usage: workflow -r
    -n, --name <name>  Optional together with -r, set markdown name
    -p, --publish      Moves htmls to the proper place so they can be deployes with GitHub / GitLab pages.
---------------------------------------------------------------------------------------------------------------------------------------------------
"
}